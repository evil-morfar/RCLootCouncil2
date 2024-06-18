--- @type RCLootCouncil
local addon = select(2, ...)
local AG = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local name = "RCHugeExportFrame"
--- @class RCHugeExportFrame: AceGUIFrame, UI.embeds
--- @field edit AceGUIMultiLineEditBox
--[[ @usage ```lua
	local exportFrame = addon.UI:New("RCHugeExportFrame")
	exportFrame:Show()
	exportFrame.edit:SetCallback("OnTextChanged", function(self)
		self:SetText(export)
	end)
	exportFrame.edit:SetText(export)
	exportFrame.edit:SetFocus()
	exportFrame.edit:HighlightText()
	```
]]
local Object = {}

-- There should only ever be one of these, as it can be reused
local singleton

function Object:New()
	if singleton then
		singleton.edit:SetText("")
		singleton:Show()
		return singleton
	end

	local hugeExp = AG:Create("Window")
	hugeExp:SetLayout("Flow")
	hugeExp:SetTitle("RCLootCouncil " .. L["Export"])
	hugeExp:SetWidth(700)
	hugeExp:SetHeight(100)

	local edit = AG:Create("EditBox")
	edit:SetFullWidth(true)
	edit:SetLabel(L["huge_export_desc"])
	edit:SetMaxLetters(0)
	hugeExp:AddChild(edit)
	hugeExp:Hide()
	hugeExp.edit = edit

	edit.editbox:SetScript("OnEscapePressed", function(self)
		singleton:Hide()
	end)

	singleton = hugeExp
	return singleton
end

addon.UI:RegisterElement(Object, name)
