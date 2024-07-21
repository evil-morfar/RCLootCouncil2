local function noop() end

local objectMethods = {
}

local noopMethods = {
	"GetFromAlpha",
	"GetToAlpha",
	"SetFromAlpha",
	"SetToAlpha",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

Alpha = {
	New = function(parent, inheritsFrom)
		return setmetatable({ type = "Alpha", inheritsFrom = inheritsFrom, parent = parent, }, {
			__index = function(self, v)
				local k = objectMethods[v] or parent[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
