--- Core.lua Setups module system.
-- Heavily inspired by TSM!

---@type RCLootCouncil
local _, addon = ...

local private = {modules = {}, initOrder = {}}
addon.ModuleData = {}
local MODULE_MT = {
   __index = {
      OnInitialize = addon.noop,
      OnEnable = addon.noop
   }
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
	--@type T
	local Module = setmetatable({}, MODULE_MT)
	private.modules[path] = Module
   tinsert(private.initOrder, path)
   tinsert(addon.ModuleData, Module)
	return Module
end

--- Returns a module created with .Init
--- @see addon#Init
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
