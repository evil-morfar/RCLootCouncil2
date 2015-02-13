-- Author      : Potdisc
-- Create Date : 12/16/2014 8:24:04 PM
-- DefaultModule
-- lootFrame.lua	Adds the interface for selecting a response to a session

--TODO Made with AceGUI, not tested

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local LootFrame = addon:NewModule("RCLootFrame", "AceTimer-3.0", "AceComm-3.0")
local AG = LibStub("AceGUI-3.0")

local db, buttons
local isMinimized = false
local items = {} -- item.i = {name, link, lvl, texture} (i == session)

function LootFrame:Start(table)
	for k,v in pairs(table) do
		items[k] = {
			name = v.name,
			link = v.link,
			lvl = v.lvl,
			texture = v.texture,
		}
	end
	self:Show()
end

function LootFrame:OnEnable()
	db = addon.mldb
	buttons = db.buttons	
end

function LootFrame:OnDisable()
	self:Hide()
	items = {}
end

function LootFrame:Show()
	self.frame = self:GetFrame()
end

function LootFrame:Hide()
	self.frame:Release()
	isMinimized = false
end

function LootFrame:MinMaximize()
	if isMinimized then -- maximize
		self.frame:AddChild(self:GetScrollContainer())
		self.frame.children.label:SetText("Click to Minimize")
	else -- minimize
		self.frame.sc:Release()
		self.frame.children.label:SetText("Click to Maximize")
	end
	isMinimized = not isMinimized
	self.frame:DoLayout()
end

function LootFrame:OnRoll(session, button, entry)
	addon:Debug("LootFrame:OnRoll("..session..", "..button)
	local g1, g2 = addon:GetPlayersGearFromItemID(tonumber(strmatch(items[session].link, "item:(%d+):")))
	-- Send response along with "personal" info to the ML
	local toSend = {
		session = session,
		name = addon.playerName,
		ilvl = math.floor(select(2,GetAverageItemLevel())),
		gear1 = g1,
		gear2 = g2,
		note = entry.note,
		response = button,
	}
	addon:SendCommand(addon.masterlooter, "response", toSend)

	-- Clean up
	entry:Release()
	tremove(items, session)
	if #item == 0 then
		self:Disable() -- Disable the module when all items are gone
		return
	end
	self.frame:DoLayout()
end

function LootFrame:GetFrame()
	if self.frame and self.frame:IsVisible() then return self.frame end
	local f = AG:Create("SimpleGroup")
	f:SetLayout("List")
	
	local label = AG:Create("InteractiveLabel")
	label:SetText("Click to minimize")
	label:SetRelativeWidth(0.5)
	label:SetColor(1,1,1)
	label:SetPoint("TOP", f, "TOP")
	label:SetCallback("OnClick", function() self:MinMaximze() end)
	f:AddChild(label)
	f:AddChild(self:GetScrollContainer())
	return f
end

function LootFrame:GetScrollContainer()
	if self.frame.children.sc:IsVisible() then return self.frame.children.sc end

	local sc = AG:Create("SimpleGroup")
	sc:SetHeight(450)
	sc:SetFullWidth(true)
	sc:SetLayout("Fill")

	local sf = AG:Create("ScrollFrame")
	sf:SetLayout("List")
	for k,v in ipairs(items) do
		sf:AddChild(self:GetEntry(k,v))
	end
	sc:AddChild(sf)
	return sc
end

function LootFrame:GetEntry(key, item)
	local entry = AG:Create("SimpleGroup")
	entry:SetHeight(75)
	entry:SetLayout("Flow")

	local icon = AG:Create("Icon")
	icon:SetImage(item.texture)
	icon:SetImageSize(50, 50)
	icon:SetCallback("OnEnter", function() addon:CreateTooltip(nil, item.link) end)
	icon:SetCallback("OnLeave", function() addon:HideTooltip() end)
	icon:SetPoint("TOPLEFT", entry, "TOPLEFT", 12, 12)
	entry:AddChild(icon)

	local ilvl = AG:Create("Label")
	ilvl:SetText(item.ilvl)
	ilvl:SetColor(1,1,1)
	ilvl:SetFont("Fonts\\ARIALN.TTF", 10)
	ilvl:SetPoint("TOPLEFT", entry, "TOPLEFT")
	entry:AddChild(ilvl)

	local name = AG:Create("InteractiveLabel")
	name:SetText(item.link)
	name:SetFont("Fonts\\FRIZQT__.TTF", 16)
	name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 0)
	name:SetCallback("OnEnter", function() addon:CreateTooltip(nil, item.link) end)
	name:SetCallback("OnLeave", function() addon:HideTooltip() end)
	entry:AddChild(name)

	-- Create all the buttons
	local button = {}
	for i = 1, db.numButtons do
		button[i] = AG:Create("Button")
		button[i]:SetText(buttons[i].text)
		if i == 1 then -- First button needs other point
			button[1]:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 10, 0)
		else
			button[i]:SetPoint("LEFT", button[i-1], "RIGHT", 5, 0)
		end
		button[i]:SetCallback("OnClick", function()
			self:OnRoll(key, i, entry) 
			entry:Release()
		end)
		entry:AddChild(button[i])
	end

	-- Note button
	if db.allowNotes then
		local note = AG:Create("InteractiveLabel")
		note:SetImage("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
		note:SetImageSize(25,25)
		note:SetHighlight("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
		note:SetPoint("BOTTOMRIGHT", entry, "BOTTOMRIGHT", -12, 12)
		note:SetCallback("OnEnter", function() addon:CreateTooltip({"Add a note for the council"}) end)
		note:SetCallback("OnLeave", function() addon:HideTooltip() end)
		note:SetCallback("OnClick", function() self:PopupNote(entry) end)
		entry:AddChild(note)
	end
	return entry
end

function LootFrame:PopupNote(entry)
	local frame = AG:Create("InlineGroup")
	frame:SetTitle("Note")
	frame:SetWidth(300)
	frame:SetHeight(150)
	frame:Layout("Flow")
	local box = AG:Create("EditBox")
	box:SetRelativeWidth(0.5)
	box:SetPoint("CENTER", frame)
	box:SetFocus()
	box:SetCallback("OnEnterPressed", function(text)
		entry.note = text
		frame:Release()
	end)
	frame:AddChild(box)
	local cancel = AG:Create("Button")
	button:SetText("Cancel")
	button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)
	button:SetCallback("OnClick", function() frame:Release() end)
	frame:AddChild(button)
end