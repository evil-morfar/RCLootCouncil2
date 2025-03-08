require "/wow_api/FrameAPI/Abstract/FrameScriptObject"
local function noop() end

Object = {}

local objectMethods = {
	GetDebugName = noop,
	GetParent = function(self) return self.parent end,
	GetParentKey = noop,
	SetParentKey = noop,
}

function Object:New(name)
	local parent = _G.FrameScriptObject.New(name)
	return setmetatable({ parent = parent, name = name, _type = "Object"}, {
		__index = function(self, v)
			local k = objectMethods[v] or parent[v]
			self[v] = k -- Store for easy future lookup
			return k
		end,
	})
end
