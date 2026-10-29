--- Core.lua Setups module system.
--- Think Dependency Injection similar to AceModules, but simpler, and probably more lightweight.
-- Heavily inspired by TSM!

---@class RCLootCouncil
local addon = select(2, ...)

local private = { modules = {}, initOrder = {}, }
addon.ModuleData = {}
local noop = function() end

local MODULE_MT = {
	--- @class Module
	__index = {
		_name = "Unknown",
		_enabled = false,
		OnInitialize = noop,
		OnEnable = noop,
		Initialize = function(self)
			self:OnInitialize()
		end,
		Enable = function(self)
			if not self._enabled then
				self._enabled = true
				self:OnEnable()
			end
		end,
		Disable = function(self)
			if self._enabled then
				self._enabled = false
				self:OnDisable()
			end
		end,
	},
	__tostring = function(self) return self._name end,
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
	local Module = setmetatable({ _name = path, }, MODULE_MT)
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

function addon:InitializeModules()
	for _, Module in pairs(private.modules) do
		Module:Initialize()
	end
end

function addon:EnableModules()
	for _, Module in pairs(private.modules) do
		Module:Enable()
	end
end
