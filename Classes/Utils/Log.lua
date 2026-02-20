-- Log.lua Class for handling all addon logging.
-- Creates `RCLootCouncil.LogClass` for registering new Logs, and adds a default Log object in `RCLootCouncil.Log`.
-- @author Potdisc
-- Create Date : 30/01/2019 18:56:31

--- @class RCLootCouncil
local addon = select(2, ...)
--- @class Utils.Log
local Log = addon.Init("Utils.Log")
local TempTable = addon.Require("Utils.TempTable")
local private = {
	debugLog = {},
	length = 0,
}
-----------------------------------------------------------
-- Class Definitions
-----------------------------------------------------------
-- Log Class Methods

--- @class Log
local LOG_METHODS = {
	--- Message
	--- @param self Log
	m = function(self, ...) self(...) end,

	--- Debug logging
	--- @param self Log
	d = function(self, ...) private:Log(self, "<DEBUG>", ...) end,

	--- Error Logging
	--- @param self Log
	e = function(self, ...) private:Log(self, "<ERROR>", ...) end,

	--- Warnings
	--- @param self Log
	w = function(self, ...) private:Log(self, "<WARNING>", ...) end,

	--- Print
	--- @param self Log
	p = function(self, ...) private:Print(self.prefix or "", ...) end,

	--- Custom prefix
	--- @param self Log
	--- @param prefix string
	f = function(self, prefix, ...) private:Log(self, prefix, ...) end,
	maxEntries = 4000,
}
-- Uppercase variants
-- Manually defined for EmmyLua
LOG_METHODS.M = LOG_METHODS.m
LOG_METHODS.Message = LOG_METHODS.m
LOG_METHODS.D = LOG_METHODS.d
LOG_METHODS.Debug = LOG_METHODS.d
LOG_METHODS.E = LOG_METHODS.e
LOG_METHODS.Error = LOG_METHODS.e
LOG_METHODS.W = LOG_METHODS.w
LOG_METHODS.Warning = LOG_METHODS.w
LOG_METHODS.P = LOG_METHODS.p
LOG_METHODS.Print = LOG_METHODS.p
LOG_METHODS.F = LOG_METHODS.f
LOG_METHODS.Format = LOG_METHODS.f


local LOG_MT = {
	__index = LOG_METHODS,
	__newindex = function() error("Log cannot be modified", 2) end,
	__call = function(self, ...)
		private:Log(self, "<INFO>", ...)
	end,
}


-----------------------------------------------------------
-- Module Functions
-----------------------------------------------------------

--- Create a new Log class
--- @param prefix? string An optional prefix to all messages
--- @param maxEntries? number The maximum number of entries to store
function Log:New(prefix, maxEntries)
	--- \<INFO> Logging
	---@class Log
	---@overload fun(...)
	local object = {
		prefix = prefix and prefix ~= "" and "[" .. prefix .. "]" or "\t",
		maxEntries = maxEntries,
	}
	return setmetatable(object, LOG_MT)
end

--- Clear all stored logs
function Log:Clear()
	wipe(private.debugLog)
	private.length = 0
end

--- Get static Log
--- This will return a static Log object that can be shared with multiple modules.
--- Useful for not creating too many Log Classes.
--- @return Log Log
function Log:Get()
	if not private.staticLog then private.staticLog = self:New() end
	return private.staticLog
end

-----------------------------------------------------------
-- Private Functions
-----------------------------------------------------------

--- Private functions that does the real work
--- @param Log Log
--- @param prefix string
function private:Log(Log, prefix, ...)
	if addon.debug then
		self:Print((Log.prefix or "") .. prefix, ...)
	end
	local t = TempTable:Acquire()
	t[1] = "<"
	t[2] = date("%X", time())
	t[3] = "> "
	t[4] = prefix
	t[5] = (Log.prefix or "")
	for i = 1, select("#", ...) do
		t[(i - 1) * 2 + 6] = "\t"
		t[(i - 1) * 2 + 7] = addon.Utils:SecretsForPrint((select(i, ...)))
	end
	local msg = table.concat(t, "")
	TempTable:Release(t)
	if self.length >= Log.maxEntries then
		tremove(self.debugLog, 1) -- We really want to preserve indicies
		self.length = self.length - 1
	end
	self.length = self.length + 1
	self.debugLog[self.length] = msg
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
function Log:InitLogging(logTable, maxEntries)
	assert(logTable, "No log table provided")
	maxEntries = maxEntries or 2000
	private.debugLog = logTable
	tinsert(private.debugLog, date("%x"))
	private.length = #private.debugLog
	if private.length > maxEntries then
		local tmp = CopyTable(private.debugLog)
		local j = private.length - maxEntries
		j = j > 0 and j or 0
		-- Replace and delete
		for i = 1, private.length do --
			if i > maxEntries then
				private.debugLog[i] = nil
			end
			private.debugLog[i] = tmp[i + j]
		end
		private.length = #private.debugLog
	end
end
