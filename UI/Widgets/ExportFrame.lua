--- @type RCLootCouncil
local addon = select(2, ...)
local AG = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local name = "RCExportFrame"
--- @class RCExportFrame: AceGUIFrame, UI.embeds
--- @field edit AceGUIMultiLineEditBox
--[[ @usage ```lua
	local exportFrame = addon.UI:New("RCExportFrame")
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

	local exp = AG:Create("Window")
	exp:SetLayout("Flow")
	exp:SetTitle("RCLootCouncil " .. L["Export"])
	exp:SetWidth(700)
	exp:SetHeight(360)

	local edit = AG:Create("MultiLineEditBox")
	edit:SetNumLines(20)
	edit:SetFullWidth(true)
	edit:SetLabel(L["Export"])
	edit:SetFullHeight(true)
	exp:AddChild(edit)
	exp.edit = edit

	edit.editBox:SetScript("OnEscapePressed", function(self)
		singleton:Hide()
	end)

	singleton = exp
	return singleton
end

addon.UI:RegisterElement(Object, name)
