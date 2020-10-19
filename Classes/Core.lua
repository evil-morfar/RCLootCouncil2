--- Core.lua Setups module system.
-- Heavily inspired by TSM!
---@type RCLootCouncil
local _, addon = ...

local private = {
   modules = {},
   initOrder = {}
}

local MODULE_MT = {
   -- Not yet used
}

--- Initializes a shareable module
---@generic T : string
---@param path string
---@return T
function addon.Init (path)
   assert(type(path) == "string")
   if private.modules[path] then
      error("Module already exists for path: "..tostring(path))
   end
   ---@type T
   local Module = setmetatable({}, MODULE_MT)
   private.modules[path] = {
      path = path,
      object = Module
   }
   tinsert(private.initOrder, path)
   return Module
end

--- Returns a module created with .Init
---@param path string
function addon.Require (path)
   local Module = private.modules[path]
   if not Module then
      error("Module doesn't exist for path: "..tostring(path))
   end
   return Module.object
end
