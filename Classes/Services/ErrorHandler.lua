--- ErrorHandler.lua Class for logging errors to the log.
-- @author Potdisc
-- Create Date: 16/04/2020
---@type RCLootCouncil
local _, addon = ...
---@class Services.ErrorHandler
local ErrorHandler = addon.Init "Services.ErrorHandler"
LibStub("AceEvent-3.0"):Embed(ErrorHandler)

local private = {
   MAX_STACK_DEPTH = 10,
}

local MAX_ERROR_TIME = 60 * 60 * 24 * 7 -- 1 week

function ErrorHandler:OnInitialize ()
   self:RegisterEvent("ADDON_ACTION_BLOCKED", "OnEvent")
   self:RegisterEvent("ADDON_ACTION_FORBIDDEN", "OnEvent")
   self:RegisterEvent("LUA_WARNING", "OnEvent")
   private.log = addon.db.global.errors
   private:ClearOldErrors()
end

-- Temporaryly just print it to log
function ErrorHandler:OnEvent (...)
   -- addon.Log:d(...)
end

function ErrorHandler:LogError (msg)
   msg = private:SanitizeLine(msg)
   addon.Log:e(msg)
   local errObj = private:DoesErrorExist(msg)
   if errObj then -- This is not the first
      private:IncrementErrorCount(errObj)
   else -- new error
      private:NewError(msg)
   end
end

--- Silently throws an error
function ErrorHandler:ThrowSilentError (message)
   local _, err = pcall(function ()
      private.ThrowError(message)
   end)
   self:LogError(err)
end

function private.ThrowError (message)
   error(message or "", 3)
end

function private:NewError (err)
   -- Build Call stack
   local stack = {}
   local i = 5 -- Skips those lines that caused by this class
   while true do
      local line = debugstack(i, 1, 0)
      if not line or line == "" then break end
      -- Exclude a few things from the code
      if not strmatch(line, "CallbackHandler%-1%.0")
      and not strmatch(line, "BugGrabber")
      and not strmatch(line, "%(tail call%)")
      and not strmatch(line, "(=%[C%])") then
         tinsert(stack, (self:SanitizeLine(line)))
         if #stack > self.MAX_STACK_DEPTH then
            break
         end
      end
      i = i + 1
   end
   self.log[#self.log + 1] = {
      msg = err,
      stack = stack,
      count = 1,
      time = GetServerTime()
   }
   addon:DumpDebugVariables() -- REVIEW: Consider make new errors subscribable to avoid this binding.
end

function private:IncrementErrorCount (errObj)
   assert(type(errObj) == "table", "errObj must be an error object.")
   errObj.time = GetServerTime()
   errObj.count = errObj.count + 1
end

function private:SanitizeLine (line)
   return line:gsub("Interface\\AddOns\\", "")
end

function private:DoesErrorExist (err)
   for _, v in ipairs(self.log) do
      if v.msg == err then return v end
   end
   return false
end

function private:IsRCLootCouncilError (line)
   -- Don't track lines related to the error handler
   if strfind(line, "ErrorHandler.lua") then
      return false

   elseif strmatch(line, "RCLootCouncil")
      or strmatch(line, "RCDebugger")
      then
         return true
      end
      return false
   end

   function private:ClearOldErrors ()
      local curTime = GetServerTime()
      for i = #self.log, 1, - 1 do
         if self.log[i].time + MAX_ERROR_TIME < curTime then
            tremove(self.log, i)
         end
      end
   end

   function private:ErrorHandler (msg)
      local msg = strtrim(tostring(msg))
      -- Determine if it's an RCLootCouncil related error
      if not self:IsRCLootCouncilError(msg) then
         local found = false
         -- Check lower stack levels
         for i = 2, self.MAX_STACK_DEPTH do
            local line = debugstack(i, 1, 0)
            if self:IsRCLootCouncilError(line) then
               found = true
               break
            end
         end
         if not found then return end -- Not ours
      end
      -- We should handle it
      ErrorHandler:LogError(msg)
   end

   -- Setup error handler
   do
      local orig_errorhandler = geterrorhandler()
      -- Special case for buggrabber
      if BugGrabber and BugGrabber.RegisterCallback then
         BugGrabber.RegisterCallback({}, "BugGrabber_BugGrabbed", function(_, errObj)
            private:ErrorHandler(errObj.message)
         end)
      else
         seterrorhandler(function(...)
            private:ErrorHandler(...)
            orig_errorhandler(...)
         end)
      end
   end
