require "/FrameAPI/Frames/Button"

local function noop() end

local objectMethods = {
	SetChecked = function(self, checked) self.checked = checked end,
	GetChecked = function(self) return self.checked end,
}

local noopMethods = {
	"GetChecked",
	"GetCheckedTexture",
	"GetDisabledCheckedTexture",
	"SetChecked",
	"SetCheckedTexture",
	"SetDisabledCheckedTexture",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

CheckButton = {
	New = function(name, parent)
		local super = _G.Button.New(name or "", parent)
		local object = { checked = false , _type = "CheckButton" }
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
