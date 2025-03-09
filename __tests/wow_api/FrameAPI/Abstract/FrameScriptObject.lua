local function noop() end

local objectMethods = {
		GetName = function(self) return self.name end,
		GetObjectType = noop,
		IsForbidden = noop,
		IsObjectType = noop,
		SetForbidden = noop,
}

FrameScriptObject = {
	New = function(name)
		
		return setmetatable({
			[0] = {}, -- Userdata (seems to be present on all objects)
			parent = "UIParent",
			_type = "FrameScriptObject",
			name = name
		}, {
			__call = function(self, ...) self:New() end,
			__index = function(self, v)
				return objectMethods[v]
			end,
		})
	end,
}
