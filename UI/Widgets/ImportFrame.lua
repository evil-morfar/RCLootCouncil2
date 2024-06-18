--- @type RCLootCouncil
local addon = select(2, ...)
local AG = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local name = "RCImportFrame"

--- @class DataField
--- @field data string Data pasted into the import frame

--- Remember to set `Object.edit:SetCall("OnEnterPressed")`
--- @class RCImportFrame: AceGUIFrame, UI.embeds
--- @field edit AceGUIMultiLineEditBox | DataField
--- @field label AceGUILabel
--[[ @usage ```lua
	local importFrame = addon.UI:New("RCImportFrame")
	importFrame.label:SetText(L["Accepted imports: 'Player Export' and 'CSV'"])
	importFrame.edit:SetCallback("OnEnterPressed", function()
		addon.Log:D("Import data:", string.sub(importFrame.edit.data, 0, 50))
		self:ImportHistory(importFrame.edit.data)
		importFrame:Hide()
	end)
	importFrame:Show()
	importFrame.edit:SetFocus()
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

	local imp = AG:Create("Window")
	imp:SetLayout("Flow")
	imp:SetTitle("RCLootCouncil Import")
	imp:SetWidth(700)
	imp:SetHeight(360)

	local edit = AG:Create("MultiLineEditBox")
	edit:SetNumLines(20)
	edit:SetFullWidth(true)
	edit:SetLabel(L["import_desc"])
	edit:SetFullHeight(true)

	-- Credit to WeakAura2
	-- Import editbox only shows first 2500 bytes to avoid freezing the game.
	-- Use 'OnChar' event to store other characters in a text buffer
	local textBuffer, i, lastPaste = {}, 0, 0
	edit.data = ""
	edit.editBox:SetScript("OnShow", function(self)
		self:SetText("")
		edit.data = ""
	end)
	local function clearBuffer(self)
		self:SetScript("OnUpdate", nil)
		edit.data = strtrim(table.concat(textBuffer))
		edit.editBox:ClearFocus()
	end
	edit.editBox:SetScript("OnChar", function(self, c)
		if lastPaste ~= GetTime() then
			textBuffer, i, lastPaste = {}, 0, GetTime()
			self:SetScript("OnUpdate", clearBuffer)
		end
		i = i + 1
		textBuffer[i] = c
	end)
	edit.editBox:SetMaxBytes(2500)
	edit.editBox:SetScript("OnMouseUp", nil);

	edit.editBox:SetScript("OnEscapePressed", function(self)
		singleton:Hide()
	end)

	local label = AG:Create("Label")
	label:SetFullWidth(true)

	imp:AddChild(label)
	imp:AddChild(edit)

	imp:Hide()
	singleton = imp
	singleton.edit = edit
	singleton.label = label
	return singleton
end

addon.UI:RegisterElement(Object, name)
