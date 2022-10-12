require "/wow_api/FrameAPI/Abstract/FrameScriptObject"

local function noop() end

local objectMethods = {
	SetScript = function(self, script, handler) self.scripts[script] = handler end,
	GetScript = function(self, script) return self.scripts[script] end,
	Show = function(self) self.isShown = true end,
	Hide = function(self) self.isShown = false end,
	IsShown = function(self) return self.isShown end,

}

local noopMethods = {
	"CanChangeProtectedState",
	"EnableMouse",
	"EnableMouseWheel",
	"GetBottomGetNumPoints",
	"GetCenter",
	"GetHeight",
	"GetLeft",
	"GetRect",
	"GetRight",
	"GetScaledRect",
	"GetScript",
	"GetSize",
	"GetSourceLocation",
	"GetTop",
	"GetWidth",
	"HasScript",
	"Hide",
	"HookScript",
	"IsAnchoringRestricted",
	"IsDragging",
	"IsMouseClickEnabled",
	"IsMouseEnabled",
	"IsMouseMotionEnabled",
	"IsMouseOver",
	"IsMouseWheelEnabled",
	"IsProtected",
	"IsRectValid",
	"IsShown",
	"IsVisible",
	"SetMouseClickEnabled",
	"SetMouseMotionEnabled",
	"SetParent",
	"SetPassThroughButtons",
	"SetScript",
	"SetShown",
	"Show",
	"AdjustPointsOffset",
	"ClearAllPoints",
	"ClearPoint",
	"ClearPointsOffset",
	"GetNumPoints",
	"GetPoint",
	"GetPointByName",
	"SetAllPoints",
	"SetHeight",
	"SetPoint",
	"SetSize",
	"SetWidth",
	"CreateAnimationGroup",
	"GetAnimationGroups",
	"StopAnimating",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

ScriptRegion = {
	New = function(name)
		local parent = _G.FrameScriptObject.New(name)
		local object = {scripts = {}, isShown = false, timer = GetTime()}
		return setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or parent[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
