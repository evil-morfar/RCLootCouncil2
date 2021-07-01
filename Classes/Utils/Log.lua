-- Log.lua Class for handling all addon logging.
-- Creates `RCLootCouncil.LogClass` for registering new Logs, and adds a default Log object in `RCLootCouncil.Log`.
-- @author Potdisc
-- Create Date : 30/01/2019 18:56:31
local _, addon = ...
--- @class Utils.Log
local Log = addon.Init("Utils.Log")
local private = {
   date_to_debug_log = true,
   debugLog = {},
   lenght = 0,
}
-----------------------------------------------------------
-- Class Definitions
-----------------------------------------------------------
-- Log Class Methods
local LOG_METHODS = {
   --- Message
   m = function(self, ...) self(...) end,

   -- Debug logging
   d = function(self, ...) private:Log(self,"<DEBUG>", ...) end,

   -- Error Logging
   e = function(self, ...) private:Log(self,"<ERROR>", ...) end,

   -- Warnings
   w = function(self, ...) private:Log(self,"<WARNING>", ...) end,

   -- Print
   p = function(self, ...) private:Print(self.prefix or "",...) end,

   -- Custom prefix
   f = function(self, prefix, ...) private:Log(self,prefix, ...) end,

   D = function(self, ...) self:d(...) end,
   E = function(self, ...) self:e(...) end,
   W = function(self, ...) self:w(...) end,
   M = function(self, ...) self:m(...) end,
   P = function(self, ...) self:p(...) end,
   F = function(self, ...) self:f(...) end,
}

local LOG_MT = {
   __index = LOG_METHODS,
   __newindex = function() error("Log cannot be modified", 2) end,
   __call = function(self, ...)
      private:Log(self, "<INFO>", ...)
   end
}


-----------------------------------------------------------
-- Module Functions
-----------------------------------------------------------

--- Create a new Log class
-- @param prefix An optional prefix to all messages
--- @return Log
function Log:New(prefix)
   --- @class Log
   local object = {
      prefix = prefix and "["..prefix.."]" or ""
   }
   return setmetatable(object, LOG_MT)
end

--- Clear all stored logs
function Log:Clear ()
   wipe(private.debugLog)
   private.lenght = 0
end

--- Get static Log
-- This will return a static Log object that can be shared with multiple modules.
-- Useful for not creating too many Log Classes.
--- @return Log Log
function Log:Get ()
   if not private.staticLog then private.staticLog = self:New() end
   return private.staticLog
end


-----------------------------------------------------------
-- Private Functions
-----------------------------------------------------------

-- Private functions that does the real work
function private:Log(Log,prefix, ...)
   self:Print((Log.prefix or "") .. prefix, ...)
   if self.date_to_debug_log then tinsert(self.debugLog, date("%x")); self.date_to_debug_log = false; end
	local time = date("%X", time())
	local msg = "<"..time..">"..(Log.prefix or "")..prefix.."\t"
	for i = 1, select("#", ...) do msg = msg.." "..tostring(select(i,...)) end
	if self.lenght >= addon.db.global.logMaxEntries then
		tremove(self.debugLog, 1) -- We really want to preserve indicies
      self.lenght = self.lenght - 1
	end
   self.lenght = self.lenght + 1
	self.debugLog[self.lenght] = msg
end

function private:Print(msg, ...)
   if addon.debug then
      -- luacov: disable
		if select("#", ...) > 0 then
			addon:Print("|cffcb6700debug:|r "..tostring(msg).."|cffff6767", ...)
		else
			addon:Print("|cffcb6700debug:|r "..tostring(msg).."|r")
		end
      -- luacov: enable
	end
end

function addon:InitLogging()
   private.debugLog = addon.db.global.log
   private.lenght = #private.debugLog -- Use direct table access for better performance.
   addon.db.global.logMaxEntries = addon.defaults.global.logMaxEntries -- reset it now for zzz
   if addon.tVersion then
      addon.db.global.logMaxEntries = 4000 -- bump it for test version
   end
   local max = addon.db.global.logMaxEntries
   if private.lenght > max then
      -- copy
      local tmp = CopyTable(private.debugLog)
      local j = private.lenght - max
      j = j > 0 and j or 0
      -- Replace and delete
      for i = 1, private.lenght do --
         if i > max then
            private.debugLog[i] = nil
         end
         private.debugLog[i] = tmp[i + j]
      end
      private.lenght = #private.debugLog
   end
end
