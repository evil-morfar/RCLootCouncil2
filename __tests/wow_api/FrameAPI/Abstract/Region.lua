require "/wow_api/FrameAPI/Abstract/ScriptRegion"

local function noop() end

local objectMethods = {GetDrawLayer = function(self) return self.values.drawLayer end}

local noopMethods = {
	"GetAlpha",
	"GetEffectiveScale",
	"GetScale",
	"GetVertexColor",
	"IsIgnoringParentAlpha",
	"IsIgnoringParentScale",
	"IsObjectLoaded",
	"SetAlpha",
	"SetDrawLayer",
	"SetIgnoreParentAlpha",
	"SetIgnoreParentScale",
	"SetScale",
	"SetVertexColor",
}

for _, v in ipairs(noopMethods) do objectMethods[v] = noop end

Region = {
	New = function(name)
		local super = _G.ScriptRegion.New(name)
		return setmetatable({}, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
