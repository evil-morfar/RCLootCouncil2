require "/wow_api/FrameAPI/Abstract/ScriptRegion"
require "/wow_api/FrameAPI/Textures/Texture"
require "/wow_api/FrameAPI/Fonts/FontString"

local function noop() end

local objectMethods = {
	RegisterEvent = function(self, event) self.events[event] = true end,
	UnregisterEvent = function(self, event) self.events[event] = nil end,
	UnregisterAllEvents = function(self) for event in pairs(self.events) do self.events[event] = nil end end,

	CreateTexture = function(self, name, drawLayer, templateName, subLevel)
		local texture = _G.Texture.New(name, self, drawLayer, templateName, subLevel)
		if name then _G[name] = texture end
		return texture
	end,

	CreateFontString = function(self, name, drawLayer, templateName)
		return _G.FontString.New(name, self, drawLayer, templateName)
	end,
	SetFrameLevel = function(self, level) self.values.frameLevel = level end,
	GetFrameLevel = function(self) return self.values.frameLevel or 0 end,
}

local noopMethods = {
	"CanChangeAttribute",
	"CreateLine",
	"CreateMaskTexture",
	"DesaturateHierarchy",
	"DisableDrawLayer",
	"DoesClipChildren",
	"EnableDrawLayer",
	"EnableGamePadButton",
	"EnableGamePadStick",
	"EnableKeyboard",
	"ExecuteAttribute",
	"GetAlpha",
	"GetAttribute",
	"GetBoundsRect",
	"GetChildren",
	"GetClampRectInsets",
	"GetDontSavePosition",
	"GetEffectiveAlpha",
	"GetEffectiveScale",
	"GetEffectivelyFlattensRenderLayers",
	"GetFlattensRenderLayers",
	"GetFrameStrata",
	"GetHitRectInsets",
	"GetHyperlinksEnabled",
	"GetID",
	"GetNumChildren",
	"GetNumRegions",
	"GetPropagateKeyboardInput",
	"GetRegions",
	"GetResizeBounds",
	"GetScale",
	"HasFixedFrameLevel",
	"HasFixedFrameStrata",
	"IsClampedToScreen",
	"IsEventRegistered",
	"IsGamePadButtonEnabled",
	"IsGamePadStickEnabled",
	"IsIgnoringParentAlpha",
	"IsIgnoringParentScale",
	"IsKeyboardEnabled",
	"IsMovable",
	"IsObjectLoaded",
	"IsResizable",
	"IsToplevel",
	"IsUserPlaced",
	"IsVisible",
	"Lower",
	"Raise",
	"RegisterAllEvents",
	"RegisterForDrag",
	"RegisterUnitEvent",
	"RotateTextures",
	"SetAlpha",
	"SetAttribute",
	"SetAttributeNoHandler",
	"SetClampRectInsets",
	"SetClampedToScreen",
	"SetClipsChildren",
	"SetDontSavePosition",
	"SetDrawLayerEnabled",
	"SetFixedFrameLevel",
	"SetFixedFrameStrata",
	"SetFlattensRenderLayers",
	"SetFrameStrata",
	"SetHitRectInsets",
	"SetHyperlinksEnabled",
	"SetID",
	"SetIgnoreParentAlpha",
	"SetIgnoreParentScale",
	"SetIsFrameBuffer",
	"SetMovable",
	"SetPropagateKeyboardInput",
	"SetResizable",
	"SetResizeBounds",
	"SetScale",
	"SetShown",
	"SetToplevel",
	"SetUserPlaced",
	"StartMoving",
	"StartSizing",
	"StopMovingOrSizing",

	"GetBackdrop",
	"GetBackdropBorderColor",
	"GetBackdropColor",
	"SetBackdrop",
	"SetBackdropBorderColor",
	"SetBackdropColor",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

Frame = {
	New = function(name, parent)
		local super = _G.ScriptRegion.New(name)
		local object = {parent = parent, events = {}, values = {}}
		return setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
