require "/wow_api/FrameAPI/Abstract/Object"

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
		local parent = _G.Object.New()
		return setmetatable({name = name}, {
			__index = function(self, v)
				local k = objectMethods[v] or parent[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
