-- Log.lua Class for handling all addon logging.
-- Creates `RCLootCouncil.LogClass` for registering new Logs, and adds a default Log object in `RCLootCouncil.Log`.
-- @author Potdisc
-- Create Date : 30/01/2019 18:56:31
--- @type RCLootCouncil
local addon = select(2, ...)
--- @class Utils.Log
local Log = addon.Init("Utils.Log")
local TempTable = addon.Require("Utils.TempTable")
local private = {
   debugLog = {},
   lenght = 0,
}
-----------------------------------------------------------
-- Class Definitions
-----------------------------------------------------------
-- Log Class Methods
local LOG_METHODS = {
   --- Message
   --- @param self Log
   m = function(self, ...) self(...) end,

   --- Debug logging
   --- @param self Log
   d = function(self, ...) private:Log(self,"<DEBUG>", ...) end,

   --- Error Logging
   --- @param self Log
   e = function(self, ...) private:Log(self,"<ERROR>", ...) end,

   --- Warnings
   --- @param self Log
   w = function(self, ...) private:Log(self,"<WARNING>", ...) end,

   --- Print
   --- @param self Log
   p = function(self, ...) private:Print(self.prefix or "",...) end,

   --- Custom prefix
   --- @param self Log
   --- @param prefix string
   f = function(self, prefix, ...) private:Log(self,prefix, ...) end,
}
-- Uppercase variants
-- Manually defined for EmmyLua
LOG_METHODS.M = LOG_METHODS.m
LOG_METHODS.D = LOG_METHODS.d
LOG_METHODS.E = LOG_METHODS.e
LOG_METHODS.W = LOG_METHODS.w
LOG_METHODS.P = LOG_METHODS.p
LOG_METHODS.F = LOG_METHODS.f

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
--- @param prefix An optional prefix to all messages
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

--- Private functions that does the real work
--- @param Log Log
--- @param prefix string
function private:Log(Log,prefix, ...)
   self:Print((Log.prefix or "") .. prefix, ...)
   local t = TempTable:Acquire()
   t[1] = "<"
   t[2] =  date("%X", time())
   t[3] = "> "
   t[4] = (Log.prefix or "")
   t[5] = prefix
   t[6] = "\t"
   for i = 1, select("#", ...) do
      t[(i - 1) * 2 + 7] = "\t"
      t[(i - 1) * 2 + 8] = tostring(select(i, ...))
   end
   local msg = table.concat(t, "")
   TempTable:Release(t)
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
   tinsert(private.debugLog, date("%x"))
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
