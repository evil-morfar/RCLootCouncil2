-- Really derives from "AnimatableObject" and "ScriptObject", but those are condensed into ScriptRegion
require "/FrameAPI/Abstract/Object"
require "/FrameAPI/Animations/Animation"


local function noop() end

local objectMethods = {
	CreateAnimation = function (self, ...)
		return _G.Animation.New(self, ...)
	end
}

local noopMethods = {
	"Finish",
	"GetAnimationSpeedMultiplier",
	"GetAnimations",
	"GetDuration",
	"GetElapsed",
	"GetLoopState",
	"GetLooping",
	"GetProgress",
	"IsDone",
	"IsPaused",
	"IsPendingFinish",
	"IsPlaying",
	"IsReverse",
	"IsSetToFinalAlpha",
	"Pause",
	"Play",
	"RemoveAnimations",
	"Restart",
	"SetAnimationSpeedMultiplier",
	"SetLooping",
	"SetPlaying",
	"SetToFinalAlpha",
	"Stop",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

AnimationGroup = {
	New = function(parent)
		local super = _G.Object.New()
		local object = { parent = parent, }
		return setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
