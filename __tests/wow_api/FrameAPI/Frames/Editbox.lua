require "/FrameAPI/Frames/Frame"

local function noop() end

local objectMethods = {
}

local noopMethods = {
	"AddHistoryLine",
	"ClearFocus",
	"ClearHighlightText",
	"ClearHistory",
	"Disable",
	"Enable",
	"GetAltArrowKeyMode",
	"GetBlinkSpeed",
	"GetCursorPosition",
	"GetDisplayText",
	"GetFont",
	"GetFontObject",
	"GetHighlightColor",
	"GetHistoryLines",
	"GetIndentedWordWrap",
	"GetInputLanguage",
	"GetJustifyH",
	"GetJustifyV",
	"GetMaxBytes",
	"GetMaxLetters",
	"GetNumLetters",
	"GetNumber",
	"GetShadowColor",
	"GetShadowOffset",
	"GetSpacing",
	"GetText",
	"GetTextColor",
	"GetTextInsets",
	"GetUTF8CursorPosition",
	"GetVisibleTextByteLimit",
	"HasFocus",
	"HasText",
	"HighlightText",
	"Insert",
	"IsAutoFocus",
	"IsCountInvisibleLetters",
	"IsEnabled",
	"IsInIMECompositionMode",
	"IsMultiLine",
	"IsNumeric",
	"IsPassword",
	"IsSecureText",
	"SetAltArrowKeyMode",
	"SetAutoFocus",
	"SetBlinkSpeed",
	"SetCountInvisibleLetters",
	"SetCursorPosition",
	"SetEnabled",
	"SetFocus",
	"SetFont",
	"SetFontObject",
	"SetHighlightColor",
	"SetHistoryLines",
	"SetIndentedWordWrap",
	"SetJustifyH",
	"SetJustifyV",
	"SetMaxBytes",
	"SetMaxLetters",
	"SetMultiLine",
	"SetNumber",
	"SetNumeric",
	"SetPassword",
	"SetSecureText",
	"SetSecurityDisablePaste",
	"SetSecurityDisableSetText",
	"SetShadowColor",
	"SetShadowOffset",
	"SetSpacing",
	"SetText",
	"SetTextColor",
	"SetTextInsets",
	"SetVisibleTextByteLimit",
	"ToggleInputLanguage",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

EditBox = {
	New = function(name, parent)
		local super = parent or _G.Frame.New(name or "")
		local object = { parent = super, _type = "EditBox", }
		local editbox = setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or self.parent[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
		return editbox
	end,
}
