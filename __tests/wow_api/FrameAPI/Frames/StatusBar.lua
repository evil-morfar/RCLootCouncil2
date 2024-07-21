require "/wow_api/FrameAPI/Frames/Frame"
require "wow_api/FrameAPI/Textures/Texture"

local function noop() end

local objectMethods = {
	GetStatusBarTexture = function (self) return self.texture end,
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
	"SetValue",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

StatusBar = {
	New = function(name, parent)
		local super = _G.Frame.New(name or "", parent)
		local object = {texture = _G.Texture.New(name .. "Texture", parent)}
		local statusbar = setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
		return statusbar
	end,
}
