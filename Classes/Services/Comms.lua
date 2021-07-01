--- Comms.lua Class for handling all addon communication.
-- Creates 'RCLootCouncil.Comms' as a namespace for comms functions.
-- @author Potdisc
-- Create Date : 18/10/2018 13:20:31

-- GLOBALS: error, IsPartyLFG, IsInRaid, IsInGroup, assert
local tostring, pairs, tremove, format, type = tostring, pairs, tremove, format, type
local _, addon = ...
---@class Services.Comms
local Comms = addon.Init("Services.Comms")
local Subject = addon.Require("rx.Subject")
local Log = addon.Require("Utils.Log"):Get()
---@type Utils.TempTable
local TempTable = addon.Require("Utils.TempTable")
---@type Services.ErrorHandler
local ErrorHandler = addon.Require "Services.ErrorHandler"
local ld = LibStub("LibDeflate")

local private = {
   AceComm = {},
   subjects = {},
   compresslevel = {level = 3},
   registered = {}
}

LibStub("AceComm-3.0"):Embed(private.AceComm)
LibStub("AceSerializer-3.0"):Embed(private)

--- Subscribe to a comm  
-- TODO Handle order
--- @param prefix Prefixes The prefix to subscribe to.
--- @param command string The command to subscribe to.
--- @param func fun(data: table, sender: string, command: string, distri: string): void The function that will be called when the command is received. Receives 4 args:
--    data   -- An array of the data sent with the command.
--    sender -- The sender of the command.
--    command -- The command
--    distri -- The command's distribution channel.
--- @return Subscription #A subscription to the Comm
function Comms:Subscribe (prefix, command, func, order)
   assert(prefix, "Prefix must be supplied")
   assert(tInvert(addon.PREFIXES)[prefix], format("%s is not a registered prefix!", tostring(prefix)))
   return private:SubjectHelper(prefix, command):subscribe(func)
end

--- Register multiple Comms at once
--- @param prefix string @The prefix to register
--- @param data table<string,function> @A table of structure ["command"] = function, 
--- @see Comms#Subscribe
--- @return table<number,Subscription> @An array of the created subscriptions
function Comms:BulkSubscribe (prefix, data)
   if type(data) ~= "table" then return error("Error - wrong data supplied.",2) end
   local subs = {}
   local len = 1
   for command, func in pairs(data) do
      subs[len] = self:Subscribe(prefix, command, func)
      len = len + 1
   end
   return subs
end

--- Get a Sender function to send commands on the prefix.
--- The returned function can handle implied selfs.
--- @param prefix string The prefix to send to. This will be registered autmatically if it isn't.
function Comms:GetSender (prefix)
   assert(prefix and prefix~= "", "Prefix must be supplied")
   private:RegisterComm(prefix)
   --- Sends a ace comm to `target`, with `command` and `...` as command arguments.
   --- The command is send using "NORMAL" priority.
   ---@param mod table
   ---@param target Player | '"group"' | '"guild"'
   ---@param command string
   ---@vararg any the data to send
   ---@return void
   return function(mod, target, command, ...)
      if type(mod) == "string" then
         -- Left shift all args
         private:SendComm(prefix, mod, "NORMAL", nil, nil, target, command, ...)
      else
         private:SendComm(prefix, target, "NORMAL", nil, nil, command, ...)
      end
   end
end

--- Registers a new prefix.
-- Is done automatically with Comms:GetSender.
-- This just allows it as well.
function Comms:RegisterPrefix (prefix)
   assert(prefix and prefix~= "", "Prefix must be supplied")
   private:RegisterComm(prefix)
end

Comms.Register = Comms.RegisterPrefix

--- A customizeable sender function.
--- @param args table A Table with the following fields:
---
--- - Required:
---   - command
--- - Optional:
---   - data    - must be an array or a single value
---   - prefix  - defaults to `Prefixes.MAIN`
---   - target  - defaults to `"group"`
---   - prio    - default to `"NORMAL"`
---   - callback
---   - callbackarg
function Comms:Send (args)
   assert(type(args)=="table", "Must supply a table")
   assert(args.command, "Command must be set")
   args.data = type(args.data) == "table" and args.data or {args.data}
   private:SendComm(args.prefix or addon.PREFIXES.MAIN, args.target or "group", args.prio, args.callback, args.callbackarg, args.command, unpack(args.data))
end

function private:SendComm(prefix, target, prio, callback, callbackarg, command, ...)
   local data = TempTable:Acquire(...)
   local serialized = self:Serialize(command, data)
   local compressed = ld:CompressDeflate(serialized, self.compresslevel)
   local encoded    = ld:EncodeForWoWAddonChannel(compressed)

   TempTable:Release(data)

   if target == "group" then
      local channel, player = self:GetGroupChannel()
      self.AceComm:SendCommMessage(prefix, encoded, channel, player, prio, callback, callbackarg)
   elseif target == "guild" then
      self.AceComm:SendCommMessage(prefix, encoded, "GUILD", nil, prio, callback, callbackarg)
   else
      if target:GetRealm() == addon.realmName then -- Our realm
         self.AceComm:SendCommMessage(prefix, encoded, "WHISPER", target:GetName(), prio, callback, callbackarg)
      else
         -- Remake command to be "xrealm" and put target and command in the table
         data = TempTable:Acquire(target:GetName(), command, ...)
         serialized = self:Serialize("xrealm", data)
         compressed = ld:CompressDeflate(serialized, self.compresslevel)
         encoded    = ld:EncodeForWoWAddonChannel(compressed)
         local channel, name = self:GetGroupChannel()
         self.AceComm:SendCommMessage(prefix, encoded, channel, name, prio, callback, callbackarg)
         TempTable:Release(data)
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
   local test, command, data = self:Deserialize(decompressed)
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

function private:FireCmd (prefix, distri, sender, command, data)
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

function private:SubjectHelper (prefix, command)
   local name = prefix..(command or "")
   if not self.subjects[name] then
      self.subjects[name] = Subject.create()
   end
   return self.subjects[name]
end
