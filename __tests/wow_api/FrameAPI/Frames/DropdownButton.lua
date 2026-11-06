require "/FrameAPI/Frames/Button"

local noop = function() end

local objectMethods = {}

local noopMethods = {}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

DropdownButton = {
	New = function(name, parent)
		local super = _G.Button.New(name or "", parent)
		local object = CreateFromMixins(DropdownButtonMixin)
		object.parent = super
		object._type = "DropdownButton"
		local button = setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
		return button
	end,
}