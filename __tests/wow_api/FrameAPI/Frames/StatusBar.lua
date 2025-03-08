require "/wow_api/FrameAPI/Frames/Frame"
require "wow_api/FrameAPI/Textures/Texture"

local function noop() end

local objectMethods = {
	GetStatusBarTexture = function (self) return self.texture end,
	SetValue = function(self, value) self.value = value end,
}

local noopMethods = {
	"GetFillStyle",
	"GetMinMaxValues",
	"GetOrientation",
	"GetReverseFill",
	"GetRotatesTexture",
	"GetStatusBarColor",
	"GetStatusBarDesaturation",
	"GetValue",
	"IsStatusBarDesaturated",
	"SetColorFill",
	"SetFillStyle",
	"SetMinMaxValues",
	"SetOrientation",
	"SetReverseFill",
	"SetRotatesTexture",
	"SetStatusBarColor",
	"SetStatusBarDesaturated",
	"SetStatusBarDesaturation",
	"SetStatusBarTexture",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

StatusBar = {
	New = function(name, parent)
		local super = parent or _G.Frame.New(name or "")
		local object = {parent = super, texture = _G.Texture.New(name .. "Texture", parent), _type ="StatusBar"}
		local statusbar = setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or self.parent[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
		return statusbar
	end,
}
