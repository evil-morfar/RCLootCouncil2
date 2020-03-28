--- Core.lua Setups module system.
-- Heavily inspired by TSM!

local _, addon = ...

local private = {
   modules = {},
   initOrder = {}
}

local MODULE_MT = {
   -- Not yet used
}

--- Initializes a shareable module
function addon.Init (path)
   assert(type(path) == "string")
   if private.modules[path] then
      error("Module already exists for path: "..tostring(path))
   end
   local Module = setmetatable({}, MODULE_MT)
   private.modules[path] = {
      path = path,
      object = Module
   }
   tinsert(private.initOrder, path)
   return Module
end

--- Returns a module created with .Init
function addon.Require (path)
   local Module = private.modules[path]
   if not Module then
      error("Module doesn't exist for path: "..tostring(path))
   end
   return Module.object
end
