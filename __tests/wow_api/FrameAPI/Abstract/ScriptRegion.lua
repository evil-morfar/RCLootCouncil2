require "/wow_api/FrameAPI/Abstract/FrameScriptObject"

local function noop() end

local objectMethods = {
	SetScript = function(self, script, handler) self.scripts[script] = handler end,
	GetScript = function(self, script) return self.scripts[script] end,
	Show = function(self)
		self.isShown = true
		if self.OnShow then
			self:OnShow()
		end
	end,
	Hide = function(self) self.isShown = false end,
	IsShown = function(self) return self.isShown end,
	SetHeight = function(self, val) self.height = val end,
	GetHeight = function(self) return self.height end,
	SetWidth = function(self, val) self.width = val end,
	GetWidth = function(self) return self.width end,

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
		local object = { scripts = {}, isShown = false, timer = GetTime(), height = 0, width = 0, scale = 1, }
		return setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or parent[v]
				if not k then
					if self.scripts[v] then
						k = self.scripts[v]
					end
				end
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
