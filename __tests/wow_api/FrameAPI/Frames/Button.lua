require "/wow_api/FrameAPI/Frames/Frame"
require "/wow_api/FrameAPI/Textures/Texture"

local function noop() end

local objectMethods = {
	SetNormalTexture = function(self, texture) self.normalTexture = _G.Texture.New(self.name .. "NormalTexture", self) end,
	GetNormalTexture = function(self) return self.normalTexture end,

	SetHighlightTexture = function(self, texture)
		self.highlightTexture = _G.Texture.New(self.name .. "HighlightTexture", self)
	end,

	GetHighlightTexture = function(self) return self.highlightTexture end,

	SetPushedTexture = function(self, texture) self.pushedTexture = _G.Texture.New(self.name .. "PushedTexture", self) end,

	GetPushedTexture = function(self) return self.pushedTexture end,
	GetTextWidth = function(self) return self.Text:GetWidth() end,

}

local noopMethods = {
	"ClearDisabledTexture",
	"ClearHighlightTexture",
	"ClearNormalTexture",
	"ClearPushedTexture",
	"Click",
	"Disable",
	"Enable",
	"GetButtonState",
	"GetDisabledFontObject",
	"GetDisabledTexture",
	"GetFontString",
	"GetHighlightFontObject",
	"GetHighlightTexture",
	"GetMotionScriptsWhileDisabled",
	"GetNormalFontObject",
	"GetNormalTexture",
	"GetPushedTextOffset",
	"GetPushedTexture",
	"GetText",
	"GetTextHeight",
	"IsEnabled",
	"LockHighlight",
	"RegisterForClicks",
	"RegisterForMouse",
	"SetButtonState",
	"SetDisabledAtlas",
	"SetDisabledFontObject",
	"SetDisabledTexture",
	"SetEnabled",
	"SetFontString",
	"SetFormattedText",
	"SetHighlightAtlas",
	"SetHighlightFontObject",
	"SetHighlightLocked",
	"SetHighlightTexture",
	"SetMotionScriptsWhileDisabled",
	"SetNormalAtlas",
	"SetNormalFontObject",
	"SetNormalTexture",
	"SetPushedAtlas",
	"SetPushedTextOffset",
	"SetPushedTexture",
	"SetText",
	"UnlockHighlight",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

Button = {
	New = function(name, parent)
		local super = _G.Frame.New(name or "", parent)
		local text = super:CreateFontString(name .. "Text")
		local object = {normalTexture = nil, highlightTexture = nil, Text = text}
		local button = setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
		-- Button also has a text child, which is also put in the global table
		_G[name .. "Text"] = text
		return button
	end,
}
