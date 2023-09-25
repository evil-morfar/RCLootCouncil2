--- Core.lua Setups module system.
-- Heavily inspired by TSM!

---@class RCLootCouncil
local addon = select(2, ...)

local private = {modules = {}, initOrder = {}}
addon.ModuleData = {}
local MODULE_MT = {
   __index = {
      _name = "Unknown",
      OnInitialize = addon.noop,
      OnEnable = addon.noop
   },
   __tostring = function(self) return self._name end
}

--- Initializes a shareable module
---@generic T
---@param path `T`
---@return T
function addon.Init(path)
	assert(type(path) == "string")
	if private.modules[path] then
		error("Module already exists for path: " .. tostring(path))
	end
	local Module = setmetatable({_name = path}, MODULE_MT)
	private.modules[path] = Module
   tinsert(private.initOrder, path)
   tinsert(addon.ModuleData, Module)
	return Module
end

--- Returns a module created with .Init
--- @see addon.Init
---@generic T
---@param path `T`
---@return T
function addon.Require(path)
	local Module = private.modules[path]
	if not Module then error("Module doesn't exist for path: " .. tostring(path)) end
	return Module
end

function addon:ModulesOnInitialize()
   for _, Module in pairs(private.modules) do
      if Module.OnInitialize then
         Module:OnInitialize()
      end
   end
end
