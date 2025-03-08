require "/wow_api/FrameAPI/Abstract/Region"

local function noop() end

local objectMethods = {
	SetText = function(self, text) self.text = text end,
	GetText = function(self) return self.text end,
	GetStringWidth = function (self) return self.text:len() * 10 end,
}

local noopMethods = {
	"CalculateScreenAreaFromCharacterSpan",
	"CanNonSpaceWrap",
	"CanWordWrap",
	"FindCharacterIndexAtCoordinate",
	"GetFieldSize",
	"GetFont",
	"GetFontObject",
	"GetIndentedWordWrap",
	"GetJustifyH",
	"GetJustifyV",
	"GetLineHeight",
	"GetMaxLines",
	"GetNumLines",
	"GetRotation",
	"GetShadowColor",
	"GetShadowOffset",
	"GetSpacing",
	"GetStringHeight",
	"GetTextColor",
	"GetTextScale",
	"GetUnboundedStringWidth",
	"GetWrappedWidth",
	"IsTruncated",
	"SetAlphaGradient",
	"SetFixedColor",
	"SetFont",
	"SetFontObject",
	"SetFormattedText",
	"SetIndentedWordWrap",
	"SetJustifyH",
	"SetJustifyV",
	"SetMaxLines",
	"SetNonSpaceWrap",
	"SetRotation",
	"SetShadowColor",
	"SetShadowOffset",
	"SetSpacing",
	"SetTextColor",
	"SetTextHeight",
	"SetTextScale",
	"SetWordWrap",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

FontString = {
	New = function(name, parent, drawLayer, templateName)
		local super = _G.Region.New(name)
		local object = {text = "", parent = parent, values = {drawLayer = drawLayer, templateName = templateName }, name = name, _type = "FontString"}
		return setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or self.parent[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
