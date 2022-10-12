local function noop() end

Object = {}

local mt = {
	__call = function(self, ...) self:New() end,
	__index = {
		parent = "UIParent",
		GetDebugName = noop,
		GetParent = function(self) return self.parent end,
		GetParentKey = noop,
		SetParentKey = noop,
	},
}

function Object:New() return setmetatable({}, mt) end
