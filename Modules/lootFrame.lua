-- Author      : Potdisc
-- Create Date : 12/16/2014 8:24:04 PM
-- DefaultModule
-- lootFrame.lua	Adds the interface for selecting a response to a session


local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local LootFrame = addon:NewModule("RCLootFrame", "AceTimer-3.0")
local LibDialog = LibStub("LibDialog-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local items = {} -- item.i = {name, link, lvl, texture} (i == session)
local entries = {}
local ENTRY_HEIGHT = 75
local MAX_ENTRIES = 5
local numRolled = 0

function LootFrame:Start(table)
	addon:DebugLog("LootFrame:Start()")
	for k = 1, #table do
		if table[k].autopass then
			items[k] = { rolled = true} -- it's autopassed, so pretend we rolled it
			numRolled = numRolled + 1
		else
			items[k] = {
				name = table[k].name,
				link = table[k].link,
				ilvl = table[k].ilvl,
				texture = table[k].texture,
				rolled = false,
				note = nil,
				session = k,
				equipLoc = table[k].equipLoc,
			}
		end
	end
	self:Show()
end

function LootFrame:ReRoll(table)
	addon:DebugLog("LootFrame:ReRoll(#table)", #table)
	for k,v in ipairs(table) do
		tinsert(items,  {
			name = v.name,
			link = v.link,
			ilvl = v.ilvl,
			texture = v.texture,
			rolled = false,
			note = nil,
			session = v.session,
			equipLoc = v.equipLoc,
		})
	end
	self:Show()
end

function LootFrame:OnEnable()
	self.frame = self:GetFrame()
end

function LootFrame:OnDisable()
	self.frame:Hide() -- We don't disable the frame as we probably gonna need it later
	items = {}
	numRolled = 0
end

function LootFrame:Show()
	self.frame:Show()
	self:Update()
end

--function LootFrame:Hide()
--	self.frame:Hide()
--end

function LootFrame:Update()
	local width = 150
	local numEntries = 0
	for k,v in ipairs(items) do
		if numEntries >= MAX_ENTRIES then break end -- Only show a certain amount of items at a time
		if not v.rolled then -- Only show unrolled items
			numEntries = numEntries + 1
			width = 150 -- reset it
			if not entries[numEntries] then entries[numEntries] = self:GetEntry(numEntries) end
			-- Actually update entries
			entries[numEntries].realID = k
			entries[numEntries].link = v.link
			entries[numEntries].icon:SetNormalTexture(v.texture)
			entries[numEntries].itemText:SetText(v.link)
			entries[numEntries].itemLvl:SetText(format(L["ilvl: x"], v.ilvl))
			-- Update the buttons and get frame width
			-- IDEA There might be a better way of doing this instead of SetText() on every update?
			local but = entries[numEntries].buttons[addon.mldb.numButtons+1]
			but:SetWidth(but:GetTextWidth() + 10)
			width = width + but:GetWidth()
			for i = 1, addon.mldb.numButtons do
				but = entries[numEntries].buttons[i]
				but:SetText(addon:GetButtonText(i))
				but:SetWidth(but:GetTextWidth() + 10)
				width = width + but:GetWidth()
			end
			entries[numEntries]:SetWidth(width)
			entries[numEntries]:Show()
		end
	end
	self.frame:SetHeight(numEntries * ENTRY_HEIGHT)
	self.frame:SetWidth(width)
	for i = MAX_ENTRIES, numEntries + 1, -1 do -- Hide unused
		if entries[i] then entries[i]:Hide() end
	end
	if numRolled == #items then -- We're through them all, so hide the frame
		self:Disable()
	end
end

function LootFrame:OnRoll(entry, button)
	addon:Debug("LootFrame:OnRoll", entry, button, "Response:", addon:GetResponseText(button))
	local index = entries[entry].realID

	addon:SendCommand("group", "response", addon:CreateResponse(items[index].session, items[index].link, items[index].ilvl, button, items[index].equipLoc, items[index].note))

	numRolled = numRolled + 1
	items[index].rolled = true
	self:Update()
end

function LootFrame:GetFrame()
	if self.frame then return self.frame end
	addon:DebugLog("LootFrame","GetFrame()")
	return addon:CreateFrame("DefaultRCLootFrame", "lootframe", L["RCLootCouncil Loot Frame"], 250, 375)
end

function LootFrame:GetEntry(entry)
	addon:DebugLog("GetEntry("..entry..")")
	if entry == 0 then entry = 1 end
	local f = CreateFrame("Frame", nil, self.frame.content)
	f:SetWidth(self.frame:GetWidth())
	f:SetHeight(ENTRY_HEIGHT)
	if entry == 1 then
		f:SetPoint("TOPLEFT", self.frame, "TOPLEFT")
	else
		f:SetPoint("TOPLEFT", entries[entry-1], "BOTTOMLEFT")
	end

	local icon = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	icon:SetSize(ENTRY_HEIGHT*2/3, ENTRY_HEIGHT*2/3)
	icon:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -13)
	icon:SetScript("OnEnter", function()
		if not f.link then return; end
		addon:CreateHypertip(f.link)
	end)
	icon:SetScript("OnLeave", function() addon:HideTooltip() end)
	icon:SetScript("OnClick", function()
		if not f.link then return; end
	    if ( IsModifiedClick() ) then
		    HandleModifiedItemClick(f.link);
        end
    end);
	f.icon = icon

	-------- Buttons -------------
	f.buttons = {}
	for i = 1, addon.mldb.numButtons do
		f.buttons[i] = addon:CreateButton(addon:GetButtonText(i), f)
		if i == 1 then
			f.buttons[i]:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 5, 0)
		else
			f.buttons[i]:SetPoint("LEFT", f.buttons[i-1], "RIGHT", 5, 0)
		end
		f.buttons[i]:SetScript("OnClick", function() LootFrame:OnRoll(entry, i) end)
	end
	-- Pass button
	f.buttons[addon.mldb.numButtons + 1] = addon:CreateButton(L["Pass"], f)
	f.buttons[addon.mldb.numButtons + 1]:SetPoint("LEFT", f.buttons[addon.mldb.numButtons], "RIGHT", 5, 0)
	f.buttons[addon.mldb.numButtons + 1]:SetScript("OnClick", function() LootFrame:OnRoll(entry, "PASS") end)

	-------- Note button ---------
	local noteButton = CreateFrame("Button", nil, f)
	noteButton:SetSize(20,20)
   noteButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	noteButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
   noteButton:SetPoint("BOTTOMRIGHT", -12, 12)
	noteButton:SetScript("OnEnter", function()
		if items[entries[entry].realID].note then -- If they already entered a note:
			addon:CreateTooltip(L["Your note:"], items[entries[entry].realID].note, "\nClick to change your note.")
		else
			addon:CreateTooltip(L["Add Note"], L["Click to add note to send to the council."])
		end
	end)
	noteButton:SetScript("OnLeave", function() addon:HideTooltip() end)
	noteButton:SetScript("OnClick", function() LibDialog:Spawn("LOOTFRAME_NOTE", entry) end)
	f.noteButton = noteButton

	----- item text/lvl ---------------
	local iTxt = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	iTxt:SetPoint("TOPLEFT", f.icon, "TOPRIGHT", 5, -5)
	iTxt:SetText("Item name goes here!!!!") -- Set text for reasons
	f.itemText = iTxt

	local ilvl = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ilvl:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -13)
	ilvl:SetTextColor(1, 1, 1) -- White
	ilvl:SetText("ilvl: 670")
	f.itemLvl = ilvl
	return f
end


-- Note button
LibDialog:Register("LOOTFRAME_NOTE", {
	text = L["Enter your note:"],
	editboxes = {
		{
			on_enter_pressed = function(self, entry)
				items[entries[entry].realID].note = self:GetText()
				LibDialog:Dismiss("LOOTFRAME_NOTE")
			end,
			on_escape_pressed = function(self)
				LibDialog:Dismiss("LOOTFRAME_NOTE")
			end,
			auto_focus = true,
		}
	},
})
