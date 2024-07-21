local function noop() end

Object = {}

local objectMethods = {
	GetDebugName = noop,
	GetParent = function(self) return self.parent end,
	GetParentKey = noop,
	SetParentKey = noop,
}

function Object:New()
	return setmetatable({
		[0] = {}, -- Userdata (seems to be present on all objects)
		parent = "UIParent",
	}, {
		__call = function(self, ...) self:New() end,
		__index = function(self, v)
			return objectMethods[v]
		end,
	})
end
