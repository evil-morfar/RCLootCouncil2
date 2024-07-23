require "/wow_api/FrameAPI/Animations/Alpha"

local function noop() end

local objectMethods = {
}

local noopMethods = {
	"GetDuration",
	"GetElapsed",
	"GetEndDelay",
	"GetOrder",
	"GetProgress",
	"GetRegionParent",
	"GetSmoothProgress",
	"GetSmoothing",
	"GetStartDelay",
	"GetTarget",
	"IsDelaying",
	"IsDone",
	"IsPaused",
	"IsPlaying",
	"IsStopped",
	"Pause",
	"Play",
	"Restart",
	"SetChildKey",
	"SetDuration",
	"SetEndDelay",
	"SetOrder",
	"SetParent",
	"SetPlaying",
	"SetSmoothProgress",
	"SetSmoothing",
	"SetStartDelay",
	"SetTarget",
	"SetTargetKey",
	"SetTargetName",
	"SetTargetParent",
	"Stop",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

Animation = {
	New = function(parent, type, name, inheritsFrom)
		if not _G[type] then
			error(format("No such animation type: %s", type), 3)
		end

		return _G[type].New(setmetatable({parent = parent, name = name}, {
			__index = function(self, v)
				local k = objectMethods[v] or parent[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		}), inheritsFrom)
	end,
}
