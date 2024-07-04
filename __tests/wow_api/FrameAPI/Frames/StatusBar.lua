require "/wow_api/FrameAPI/Frames/Frame"

local function noop() end

local objectMethods = {
}

local noopMethods = {
	"GetFillStyle",
	"GetMinMaxValues",
	"GetOrientation",
	"GetReverseFill",
	"GetRotatesTexture",
	"GetStatusBarColor",
	"GetStatusBarDesaturation",
	"GetStatusBarTexture",
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
		local object = {}
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
