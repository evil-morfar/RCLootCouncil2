--- Comms.lua Class for handling all addon communication.
-- Creates 'RCLootCouncil.Comms' as a namespace for comms functions.
-- @author Potdisc
-- Create Date : 18/10/2018 13:20:31

-- GLOBALS: error, IsPartyLFG, IsInRaid, IsInGroup, assert
local tostring, pairs, tremove, format, type = tostring, pairs, tremove, format, type
--- @type RCLootCouncil
local addon = select(2, ...)
---@class Services.Comms
local Comms = addon.Init("Services.Comms")
local Subject = addon.Require("rx.Subject")
local Log = addon.Require("Utils.Log"):Get()
local TempTable = addon.Require("Utils.TempTable")
local ErrorHandler = addon.Require "Services.ErrorHandler"
local CommsRestrictions = addon.Require "Services.CommsRestrictions"
local ld = LibStub("LibDeflate")

local private = {
	---@type AceComm-3.0
	AceComm = {},
	--- @type table<string, rx.Subject>
	subjects = {},
	compresslevel = { level = 3, },
	registered = {},
	queuedComms = {},
}

LibStub("AceComm-3.0"):Embed(private.AceComm)
LibStub("AceSerializer-3.0"):Embed(private)

CommsRestrictions.OnAddonRestrictionChanged:subscribe(private.OnRestrictionsChanged)

---@alias ReceiverFunction fun(data: table, sender: string, command: string, distri: string): nil

--- Subscribe to a comm
-- TODO Handle order
--- @param prefix Prefixes The prefix to subscribe to.
--- @param command string The command to subscribe to.
--- @param func ReceiverFunction The function that will be called when the command is received. Receives 4 args:
--    data   -- An array of the data sent with the command.
--    sender -- The sender of the command.
--    command -- The command
--    distri -- The command's distribution channel.
--- @return rx.Subscription #A subscription to the Comm
function Comms:Subscribe(prefix, command, func, order)
	assert(prefix, "Prefix must be supplied")
	assert(tInvert(addon.PREFIXES)[prefix], format("%s is not a registered prefix!", tostring(prefix)))
	return private:SubjectHelper(prefix, command):subscribe(func)
end

--- Register multiple Comms at once
--- @param prefix string @The prefix to register
--- @param data table<string,ReceiverFunction> @A table of structure ["command"] = function
--- @see Comms#Subscribe
--- @return table<number,Subscription>? @An array of the created subscriptions
function Comms:BulkSubscribe(prefix, data)
	if type(data) ~= "table" then return error("Error - wrong data supplied.", 2) end
	local subs = {}
	local len = 1
	for command, func in pairs(data) do
		subs[len] = self:Subscribe(prefix, command, func)
		len = len + 1
	end
	return subs
end

---@alias CommTarget '"group"' |'"guild"' | Player

--- Get a Sender function to send commands on the prefix.
--- The returned function can handle implied selfs.
--- @param prefix string The prefix to send to. This will be registered autmatically if it isn't.
function Comms:GetSender(prefix)
	assert(prefix and prefix ~= "", "Prefix must be supplied")
	private:RegisterComm(prefix)
	--- Sends a ace comm to `target`, with `command` and `...` as command arguments.
	--- The command is send using "NORMAL" priority.
	---@param mod table
	---@param target CommTarget
	---@param command string
	---@vararg any the data to send
	return function(mod, target, command, ...)
		if type(mod) == "string" then
			-- Left shift all args
			private:SendComm(prefix, mod, "NORMAL", nil, nil, target, false, command, ...)
		else
			private:SendComm(prefix, target, "NORMAL", nil, nil, command, false, ...)
		end
	end
end

--- Registers a new prefix.
-- Is done automatically with Comms:GetSender.
-- This just allows it as well.
function Comms:RegisterPrefix(prefix)
	assert(prefix and prefix ~= "", "Prefix must be supplied")
	private:RegisterComm(prefix)
end

Comms.Register = Comms.RegisterPrefix

--- @class CommsArgs
--- @field command string #The command to send
--- @field data? string | number | table | boolean Data to send
--- @field prefix? Prefixes Defaults to `Prefixes.MAIN`
--- @field target? CommTarget Target - defaults to `"group"`
--- @field prio? string Defaults to `"NORMAL"`
--- @field callback? fun(callbackarg?: any, bytesSent: number, bytesTotal: number) Function to call as once chunk is sent
--- @field callbackarg? any Supplied to `callback` function

local function AssertCommsArgs(args)
	assert(type(args) == "table", "Must supply a table")
	assert(args.command, "Command must be set")
	args.data = type(args.data) == "table" and args.data or { args.data, }
	return args
end

--- A customizeable sender function.
--- @param args CommsArgs
function Comms:Send(args)
	args = AssertCommsArgs(args)
	private:SendComm(args.prefix or addon.PREFIXES.MAIN, args.target or "group", args.prio, args.callback,
		args.callbackarg, args.command, false, unpack(args.data))
end

--- A customizeable sender function that will guarantee delivery after restrictions ends.
--- Does not support callbacks or prio.
--- @param args CommsArgs
function Comms:SendGuaranteed(args)
	args = AssertCommsArgs(args)
	private:SendComm(args.prefix or addon.PREFIXES.MAIN, args.target or "group", nil, nil,
		nil, args.command, true, unpack(args.data))
end

--- Ends all subscriptions and kills all registered comms.
function Comms:OnDisable()
	-- Complete all Subjects
	for _, subject in pairs(private.subjects) do
		subject:onCompleted()
	end
	-- Clean registries
	wipe(private.subjects)
	wipe(private.registered)
	-- Clear AceComm
	private.AceComm:UnregisterAllComm()
end

--- Function to actually send the comms
---@param prefix Prefixes The command prefix (usually `addon.PREFIXES.MAIN`)
---@param target "group" | "guild" | Player The target to send to. Can be "group", "guild" or a Player object.
---@param prio string? The priority of the message. See AceComm documentation for options.
---@param callback fun(callbackarg?: any, bytesSent: number, bytesTotal: number)? Function to call as once chunk is sent
---@param callbackarg any? Supplied to `callback` function
---@param command string The command to send
---@param guaranteed boolean Whether to guarantee sending after restrictions end
---@param ... any The data to send
function private:SendComm(prefix, target, prio, callback, callbackarg, command, guaranteed, ...)
	if addon.IsEnabled and not addon:IsEnabled() then return end
	if CommsRestrictions:IsRestricted() then
		if guaranteed then
			Log:w("<Comm>", "Comms are restricted, but sending guaranteed comm:", prefix, target, command, ...)
			local encoded = self:EncodeData(command, ...)
			local key = string.format("%s|%s|%s|%s", prefix, target, command, encoded)
			if tContains(self.queuedComms, key) then
				return Log:w("<Comm>", "Comms already queued, not queueing again:", prefix, target, command, ...)
			end
			tinsert(self.queuedComms, key)
		else
			Log:w("<Comm>", "Comms are restricted, not sending:", prefix, target, command, ...)
		end
		return
	end

	local encoded = self:EncodeData(command, ...)

	if target == "group" then
		local channel, player = self:GetGroupChannel()
		self.AceComm:SendCommMessage(prefix, encoded, channel, player, prio, callback, callbackarg)
	elseif target == "guild" then
		self.AceComm:SendCommMessage(prefix, encoded, "GUILD", nil, prio, callback, callbackarg)
	else
		-- This might happen if we send a message to a specific player that hasn't been loaded.
		-- Just Log and return
		if not target.GetRealm then return Log:e("Invalid target:", target) end
		if not target:GetRealm() then return Log:e("Couldn't get realm for target:", target) end
		if addon.Utils:IsWhisperTarget(target) then
			self.AceComm:SendCommMessage(prefix, encoded, "WHISPER", target:GetName(), prio, callback, callbackarg)
		else
			-- Remake command to be "xrealm" and put target and command in the table
			encoded             = self:EncodeData("xrealm", target:GetName(), command, ...)
			local channel, name = self:GetGroupChannel()
			self.AceComm:SendCommMessage(prefix, encoded, channel, name, prio, callback, callbackarg)
		end
	end
end

function private.ReceiveComm(prefix, encodedMsg, distri, sender)
	local self = private
	local senderName = addon.Utils:UnitName(sender)
	-- Unpack message
	local decoded = ld:DecodeForWoWAddonChannel(encodedMsg)
	local decompressed = ld:DecompressDeflate(decoded)
	Log:f("<Comm>", decompressed, distri, senderName)
	local test, command, data = self:Deserialize(decompressed or "")
	if not test then
		-- luacov: disable
		return Log:e("<Comm>", "Deserialization failed with:", decompressed)
		-- luacov: enable
	end
	if command == "xrealm" then
		local target = tremove(data, 1)
		if target == addon.player:GetName() then
			command = tremove(data, 1)
			self:FireCmd(prefix, distri, senderName, command, data)
		end
	else
		self:FireCmd(prefix, distri, senderName, command, data)
	end
end

function private:EncodeData(command, ...)
	local data       = TempTable:Acquire(...)
	local serialized = self:Serialize(command, data)
	local compressed = ld:CompressDeflate(serialized, self.compresslevel)
	local encoded    = ld:EncodeForWoWAddonChannel(compressed)

	TempTable:Release(data)
	return encoded
end

function private:OnRestrictionsChanged(active)
	if active then return end
	local len = #self.queuedComms
	for _, encoded in ipairs(self.queuedComms) do
		local prefix, target, command, data = strsplit("|", encoded, 4)
		self:SendComm(prefix, target, nil, nil, nil, command, true, data)
	end
	Log:f("<Comm>", string.format("Sent %d queued comms after restrictions lifted.", len))
	if len > #self.queuedComms then
		ErrorHandler:ThrowSilentError("Queued comms modified while sending guaranteed comms!")
	end
	wipe(self.queuedComms)
end

function private:FireCmd(prefix, distri, sender, command, data)
	if addon:Getdb().safemode then
		local subject = self:SubjectHelper(prefix, command)
		local ok, err = pcall(subject.next, subject, data, sender, command, distri)
		if not ok then
			ErrorHandler:ThrowSilentError(err)
		end
	else
		self:SubjectHelper(prefix, command):next(data, sender, command, distri)
	end
end

function private:GetGroupChannel()
	if IsPartyLFG() then
		return "INSTANCE_CHAT"
	elseif IsInRaid() then
		return "RAID"
	elseif IsInGroup() then
		return "PARTY"
	else
		return "WHISPER", addon.player:GetName() -- Fallback
	end
end

function private:RegisterComm(prefix)
	if not addon.PREFIXES[prefix] then
		addon.PREFIXES[prefix] = prefix
	end
	if not self.registered[prefix] then
		self.registered[prefix] = true
		self.AceComm:RegisterComm(prefix, self.ReceiveComm, self)
	end
end

function private:SubjectHelper(prefix, command)
	local name = prefix .. (command or "")
	if not self.subjects[name] then
		self.subjects[name] = Subject.create()
	end
	return self.subjects[name]
end
