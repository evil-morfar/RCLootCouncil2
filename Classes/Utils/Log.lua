-- Log.lua Class for handling all addon logging.
-- Creates `RCLootCouncil.LogClass` for registering new Logs, and adds a default Log object in `RCLootCouncil.Log`.
-- @author Potdisc
-- Create Date : 30/01/2019 18:56:31

--- @class RCLootCouncil
local addon = select(2, ...)
--- @class Utils.Log
local UtilsLog = addon.Init("Utils.Log")
local TempTable = addon.Require("Utils.TempTable")
local private = {
	debugLog = {},
	length = 0,
	head = 1,
	maxEntries = 4000, -- Default fallback
}

local Subject = addon.Require("rx.Subject")
---@class OnLog : rx.Subject
---@field subscribe fun(self, onNext: fun(message:string)): rx.Subscription
UtilsLog.OnLog = Subject.create()

local select, tostring, date, time, wipe, tinsert, tremove = select, tostring, date, time, wipe, table.insert,
table.remove
-----------------------------------------------------------
-- Class Definitions
-----------------------------------------------------------
-- Log Class Methods

---@class Log
local Log = {
	prefix = "\t",
	headers = {
		info    = "<INFO>\t",
		debug   = "<DEBUG>\t",
		error   = "<ERROR>\t",
		warning = "<WARNING>\t",
	},
}
--- Message
function Log:Message(...) private:Log(self.headers.info, ...) end

--- Debug logging
function Log:Debug(...) private:Log(self.headers.debug, ...) end

--- Error Logging
function Log:Error(...) private:Log(self.headers.error, ...) end

--- Warnings
function Log:Warning(...) private:Log(self.headers.warning, ...) end

--- Print
function Log:Print(...) private:Print(self.prefix or "", ...) end

--- Custom prefix
--- @param prefix string
function Log:Format(prefix, ...) private:Log(prefix .. self.prefix, ...) end

-- Uppercase variants
-- Manually defined for EmmyLua
Log.M = Log.Message
Log.m = Log.Message
Log.D = Log.Debug
Log.d = Log.Debug
Log.E = Log.Error
Log.e = Log.Error
Log.W = Log.Warning
Log.w = Log.Warning
Log.P = Log.Print
Log.p = Log.Print
Log.F = Log.Format
Log.f = Log.Format

local LOG_MT = {
	__index = Log,
	__newindex = function() error("Log cannot be modified", 2) end,
	__call = function(self, ...)
		private:Log(self.headers.info, ...)
	end,
}
-----------------------------------------------------------
-- Module Functions
-----------------------------------------------------------

--- Create a new Log class
--- @param prefix? string An optional [module] prefix to all messages produced
function UtilsLog:New(prefix)
	local object = {
		prefix = prefix and "[" .. prefix .. "]" or nil,
	}
	if prefix then
		-- Precompute level headers for this instance:
		object.headers = {}
		for k, v in pairs(Log.headers) do
			object.headers[k] = v:gsub("\t", object.prefix)
		end
	end
	return setmetatable(object, LOG_MT)
end

--- Clear all stored logs
function UtilsLog:Clear()
	wipe(private.debugLog)
	private.length = 0
	private.head = 1
end

--- Get static Log
--- This will return a static Log object that can be shared with multiple modules.
--- Useful for not creating too many Log Classes.
--- @return Log Log
function UtilsLog:Get()
	if not private.staticLog then private.staticLog = self:New() end
	return private.staticLog
end

-----------------------------------------------------------
-- Private Functions
-----------------------------------------------------------

--- Private functions that does the real work
---@param header string? Header that goes between time and message. Usually the precomputed header from `LogClass.headers`
---@param ... any? Message arguments, will be added seperated by tabs
function private:Log(header, ...)
	if addon.debug then
		self:Print(header or "", ...)
	end
	if addon.db.profile and addon.db.profile.disableLogging then return end

	local msg = self:EncodeMessage(header, ...)

	self.debugLog[self.head] = msg
	self.head = self.head + 1
	if self.head > self.maxEntries then self.head = 1 end -- Supposedly faster than using modulo
	self.debugLog[self.head] = "END"

	UtilsLog.OnLog(msg)
end

local lastTime, cachedHeader = 0, "<00:00:00>"
local function GetLogHeader()
	local now = time()
	if now ~= lastTime then
		lastTime = now
		cachedHeader = date("<%X> ", now)
	end
	return cachedHeader
end

--- Produces the actual log messages
---@param header string? Precompiled header from Log
---@param ... string?
function private:EncodeMessage(header, ...)
	local t = TempTable:Acquire()
	t[1] = GetLogHeader()
	t[2] = header or ""
	local numArgs = select("#", ...)
	local n = 2
	for i = 1, numArgs do
		n = n + 1
		t[n] = "\t"
		n = n + 1
		t[n] = addon.Utils:SecretsForPrint((select(i, ...)))
	end
	return TempTable:ConcatAndRelease(t)
end

function private:Print(msg, ...)
	-- luacov: disable
	if select("#", ...) > 0 then
		addon:Print("|cffcb6700debug:|r " .. tostring(msg) .. "|cffff6767", ...)
	else
		addon:Print("|cffcb6700debug:|r " .. tostring(msg) .. "|r")
	end
	-- luacov: enable
end

--- Initializes loggin by referencing the local log table to the SV table,
--- and removing old entries.
--- @param logTable table The SV table to store logs in.
--- @param maxEntries? number The maximum number of entries to store (defaults to 2000)
function UtilsLog:InitLogging(logTable, maxEntries)
	assert(logTable, "No log table provided")
	private.maxEntries = maxEntries or private.maxEntries
	private.debugLog = logTable
	private.length = #private.debugLog
	if private.length > private.maxEntries then
		for i = maxEntries + 1, private.length do
			private.debugLog[i] = nil
		end
	end
	private:UpdateHead()
	private.debugLog[private.head] = date("%x")
	private.head = private.head + 1
end

function private:UpdateHead()
	-- find head for circular storage
	for i = 1, #private.debugLog do
		if private.debugLog[i] == "END" then
			self.head = i
			return
		end
	end
	self.head = #private.debugLog + 1
end
