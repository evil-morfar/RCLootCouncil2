--- lootFrame.lua Adds the interface for selecting a response to a session.
-- DefaultModule.
-- @author	Potdisc
-- Create Date : 12/16/2014 8:24:04 PM
---@type RCLootCouncil
local _,addon = ...
local LootFrame = addon:NewModule("RCLootFrame", "AceTimer-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local entries = {}
local ENTRY_HEIGHT = 80
local MAX_ENTRIES = 5
local MIN_BUTTON_WIDTH = 40

local sessionsWaitingRollResultQueue = {}
local ROLL_TIMEOUT = 1.5
local ROLL_SHOW_RESULT_TIME = 1

-- Lua
local type, pairs, tinsert, ipairs, string, GetTime, math, ceil, tDeleteItem, next, error, tostring, setmetatable, tremove, format, tonumber =
		type, pairs, tinsert, ipairs, string, GetTime, math, ceil, tDeleteItem, next, error, tostring, setmetatable, tremove, format, tonumber

-- GLOBALS: CreateFrame, RandomRoll, _G, GameTooltip, IsModifiedClick, HandleModifiedItemClick, Ambiguate

local RANDOM_ROLL_PATTERN = RANDOM_ROLL_RESULT
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("[%(%)%-]", "%%%1")
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%s", "%(%.%+%)")
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%d", "%(%%d+%)")
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%%d%$s", "%(%.%+%)") -- for "deDE"
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%%d%$d", "%(%%d+%)") -- for "deDE"

function LootFrame:AddItem (offset, k, item, reRoll)
	self.items[offset+k] = {
	--	name = table[k].name,
		link = item.link,
		ilvl = item.ilvl,
		texture = item.texture,
		rolled = false,
		note = nil,
		equipLoc = item.equipLoc,
		timeLeft = addon.mldb.timeout,
		subType = item.subType,
		typeID = item.typeID,
		subTypeID = item.subTypeID,
		isTier = item.token,
		isRelic = item.relic,
		classes = item.classes,
		sessions = {item.session},
		isRoll = item.isRoll,
		owner = item.owner,
		typeCode = item.typeCode,
	}
end

function LootFrame:CheckDuplicates (lenght, offset)
	for k = offset+1, offset + lenght do -- Only check the entries we added just now.
		if not self.items[k].rolled then
			for j = offset+1, offset + lenght do
				if j ~= k and addon:ItemIsItem(self.items[k].link, self.items[j].link) and not self.items[j].rolled then
					addon.Log:D("LootFrame:", self.items[k].link, "is a dublicate of", self.items[j].link)
					tinsert(self.items[k].sessions, self.items[j].sessions[1])
					self.items[j].rolled = true -- Pretend we have rolled it.
				end
			end
		end
	end
end

function LootFrame:Start(table, reRoll)
	addon.Log("LootFrame:Start", #table, reRoll)

	local offset = 0
	if reRoll then
		offset = #self.items  -- Insert to "items" if reRoll
	elseif #self.items > 0 then  -- Must start over if it is not reRoll(receive lootTable).
		--This is to avoid problem if the lootTable is received when lootFrame is shown. This can happen if ML does a reload.
		self:OnDisable()
	end

	for k = 1, #table do
		if table[k].autopass then
			self.items[offset+k] = { rolled = true} -- it's autopassed, so pretend we rolled it
		else
			self:AddItem(offset, k, table[k], reRoll)
		end
	end

	self:CheckDuplicates(#table, offset)
	self:Show()
end

function LootFrame:AddSingleItem(item)
	if not self:IsEnabled() then self:Enable() end
	addon.Log:D("LootFrame:AddSingleItem", item.link, #self.items)
	if item.autopass then
		self.items[#self.items+1] = { rolled = true}
	else
		self:AddItem(0, #self.items + 1, item)
		-- REVIEW Consider duplicates? It doesn't really work in it's current form here.
		self:Show()
	end
end

function LootFrame:ReRoll(table)
	addon.Log:D("LootFrame:ReRoll(#table)", #table)
	self:Start(table, true)
end

function LootFrame:OnEnable()
	self.items = {} -- item.i = {name, link, lvl, texture} (i == session)
	self.frame = self:GetFrame()
	self:RegisterEvent("CHAT_MSG_SYSTEM")
end

function LootFrame:OnDisable()
	self.frame:Hide() -- We don't disable the frame as we probably gonna need it later
	-- Trash all entries just in case:
	for _,entry in pairs(self.EntryManager.entries) do
		if type(entry) == "table" then
			self.EntryManager:Trash(entry)
		end
	end
	self.items = {}
	self:CancelAllTimers()
end

function LootFrame:Show()
	self.frame:Show()
	self:Update()
end

--function LootFrame:Hide()
--	self.frame:Hide()
--end

function LootFrame:Update()
	local numEntries = 0
	for _,item in ipairs(self.items) do
		if numEntries >= MAX_ENTRIES then break end -- Only show a certain amount of items at a time
		if not item.rolled then -- Only show unrolled items
			numEntries = numEntries + 1
			self.EntryManager:GetEntry(item)
		end
	end
	if numEntries == 0 then
		return self:Disable()
	end
	self.EntryManager:Update()
	self.frame:SetHeight(numEntries * ENTRY_HEIGHT + 7)

	local firstEntry = self.EntryManager.entries[1]
	if firstEntry and addon:Getdb().modules["RCLootFrame"].alwaysShowTooltip then
		self.frame.itemTooltip:SetOwner(self.frame.content, "ANCHOR_NONE")
		self.frame.itemTooltip:SetHyperlink(firstEntry.item.link)
		self.frame.itemTooltip:Show()
		self.frame.itemTooltip:SetPoint("TOPRIGHT", firstEntry.frame, "TOPLEFT", 0, 0)
	else
		self.frame.itemTooltip:Hide()
	end
end

function LootFrame:OnRoll(entry, button)
	local item = entry.item
	if not item.isRoll then
		if addon.mldb and addon.mldb.requireNotes and button ~= "PASS" and button ~= "TIMEOUT" then
			if not item.note or #item.note == 0 then
				addon:Print(format(L["lootFrame_error_note_required"], addon.Ambiguate(addon.masterLooter:GetName())))
				return
			end
		end
		-- Only send minimum neccessary data, because the information of current equipped gear has been sent when we receive the loot table.
		-- target, session, response, isTier, isRelic, note, link, ilvl, equipLoc, relicType, sendAvgIlvl, sendSpecID
		addon.Log:D("LootFrame:Response", button, "Response:", addon:GetResponse(item.typeCode or item.equipLoc, button).text)
		for _, session in ipairs(item.sessions) do
			addon:SendResponse("group", session, button, nil, nil, item.note)
		end
		if addon:Getdb().printResponse then
			addon:Print(string.format(L["Response to 'item'"], addon.Utils:GetItemTextWithCount(item.link, #item.sessions))..
				": "..addon:GetResponse(item.typeCode or item.equipLoc, button).text)
		end
		item.rolled = true
		self.EntryManager:Trash(entry)
		self:Update()
	else
		if button == "ROLL" then
			-- Need to do system roll and wait for its result.
			local entryInQueue = {sessions=item.sessions, entry=entry}
			tinsert(sessionsWaitingRollResultQueue, entryInQueue)
			entryInQueue.timer = self:ScheduleTimer("OnRollTimeout", ROLL_TIMEOUT, entryInQueue) -- In case roll result is not received within time limit, discard the result.
			RandomRoll(1, 100)
			entry.buttons[1]:Disable() -- Disable "roll" button
			entry.buttons[2]:Hide() -- Hide pass button
			-- Hide the frame later
		else
			-- When frame is roll type, and we choose to not roll, but send a "-"
			item.rolled = true
			self.EntryManager:Trash(entry)
			self:Update()
			addon:Send("group", "roll", addon.playerName, "-", item.sessions)
		end
	end

end

function LootFrame:ResetTimers()
	for _, entry in ipairs(entries) do
		entry.timeoutBar:Reset()
	end
end

function LootFrame:GetFrame()
	if self.frame then return self.frame end
	addon.Log:D("LootFrame","GetFrame()")
	self.frame = addon.UI:NewNamed("Frame", UIParent, "DefaultRCLootFrame", L["RCLootCouncil Loot Frame"], 250, 375)
	self.frame.title:SetPoint("BOTTOM", self.frame, "TOP", 0 ,-5)
	self.frame.itemTooltip = addon:CreateGameTooltip("lootframe", self.frame.content)
	return self.frame
end

do
	local entryPrototype = {
		type = "normal",
		Update = function(entry, item)
			if not item then
				return addon.Log:E("Entry update error @ item:", item)
			end
			if item ~= entry.item then
				entry.noteEditbox:Hide()
				entry.noteEditbox:SetText("")
			end
			if item.isRoll then
				entry.noteButton:Hide()
			else
				entry.noteButton:Show()
			end
			if IsCorruptedItem and IsCorruptedItem(item.link) then
				entry.icon:SetBorderColor("purple")
			else
				entry.icon:SetBorderColor("grey")
			end
			entry.item = item
			entry.itemText:SetText((item.isRoll and (_G.ROLL..": ") or "")..addon.Utils:GetItemTextWithCount(entry.item.link or "error", #entry.item.sessions))
			entry.icon:SetNormalTexture(entry.item.texture or "Interface\\InventoryItems\\WoWUnknownItem01")
			entry.itemCount:SetText(#entry.item.sessions > 1 and #entry.item.sessions or "")
			local typeText = addon:GetItemTypeText(item.link, item.subType, item.equipLoc, item.typeID, item.subTypeID, item.classes, item.isTier, item.isRelic)
			local bonusText = addon:GetItemBonusText(item.link, "/")
			if bonusText ~= "" then bonusText = "+ "..bonusText end
			entry.itemLvl:SetText(addon.Utils:GetItemLevelText(entry.item.ilvl, entry.item.isTier).." |cff7fffff"..typeText.."|r")
			entry.bonuses:SetText(bonusText)
			if entry.item.note then
				entry.noteButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
			else
				entry.noteButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
			end
			if addon.mldb.timeout then
				entry.timeoutBar:SetMinMaxValues(0, addon.mldb.timeout or addon.db.profile.timeout)
				entry.timeoutBar:Show()
			else
				entry.timeoutBar:Hide()
			end
			if addon:UnitIsUnit(item.owner, "player") then -- Special coloring
				entry.frame:SetBackdrop({
					edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
				   edgeSize = 20,
					insets = { left = 2, right = 2, top = -2, bottom = -14 }
				})
				entry.frame:SetBackdropBorderColor(0,1,1,1)
			else
				entry.frame:SetBackdrop(nil) -- Remove it again
			end
			entry:UpdateButtons()
			entry:Show()
		end,
		Show = function(entry) entry.frame:Show() end,
		Hide = function(entry) entry.frame:Hide() end,

		-- Constructor for the prototype.
		-- Expects caller to setup buttons and position.
		Create = function(entry, parent)
			entry.width = parent:GetWidth()
			entry.frame = CreateFrame("Frame", "DefaultRCLootFrameEntry("..LootFrame.EntryManager.numEntries..")", parent, "BackdropTemplate")
			entry.frame:SetWidth(entry.width)
			entry.frame:SetHeight(ENTRY_HEIGHT)
			-- We expect entry constructors to place the frame correctly:
			entry.frame:SetPoint("TOPLEFT", parent, "TOPLEFT")

			-------- Item Icon -------------
			entry.icon = addon.UI:New("IconBordered", entry.frame)
			entry.icon:SetBorderColor("grey") -- white
			entry.icon:SetSize(ENTRY_HEIGHT*0.78, ENTRY_HEIGHT*0.78)
			entry.icon:SetPoint("TOPLEFT", entry.frame, "TOPLEFT", 9, -5)
			entry.icon:SetMultipleScripts({
				OnEnter = function()
					if not entry.item.link then return end
					addon:CreateHypertip(entry.item.link)
					GameTooltip:AddLine("")
					GameTooltip:AddLine(L["always_show_tooltip_howto"], nil, nil, nil, true)
					GameTooltip:Show()
				end,
				OnClick = function()
					if not entry.item.link then return end
					if IsModifiedClick() then
						HandleModifiedItemClick(entry.item.link);
					end
					if entry.icon.lastClick and GetTime() - entry.icon.lastClick <= 0.5 then
						addon:Getdb().modules["RCLootFrame"].alwaysShowTooltip = not addon:Getdb().modules["RCLootFrame"].alwaysShowTooltip
						LootFrame:Update()
					else
						entry.icon.lastClick = GetTime()
					end
				end,
			})
			entry.itemCount = entry.icon:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge")
			local fileName, _, flags = entry.itemCount:GetFont()
			entry.itemCount:SetFont(fileName, 20, flags)
			entry.itemCount:SetJustifyH("RIGHT")
			entry.itemCount:SetPoint("BOTTOMRIGHT", entry.icon, "BOTTOMRIGHT", -2, 2)
			entry.itemCount:SetText("error")

			-------- Buttons -------------
			entry.buttons = {}
			entry.UpdateButtons = function(entry) -- luacheck: ignore
				local b = entry.buttons -- shortening
				local numButtons = addon:GetNumButtons(entry.type)
				local buttons = addon:GetButtons(entry.type)
				-- (IconWidth (63) + indent(9)) + pass button (5) + (noteButton(24)  + indent(5+7)) + numButton * space(5)
				local width = 113 + numButtons * 5
				for i = 1, numButtons + 1 do
					if i > numButtons then -- Pass button:
						b[i] = b[i] or addon:CreateButton(_G.PASS, entry.frame)
						b[i]:SetText(_G.PASS) -- In case it was already created
						b[i]:SetScript("OnClick", function() LootFrame:OnRoll(entry, "PASS") end)
					else
						b[i] = b[i] or addon:CreateButton(buttons[i].text, entry.frame)
						b[i]:SetText(buttons[i].text) -- In case it was already created
						b[i]:SetScript("OnClick", function() LootFrame:OnRoll(entry, i) end)
					end
					b[i]:SetWidth(b[i]:GetTextWidth() + 10)
					if b[i]:GetWidth() < MIN_BUTTON_WIDTH then b[i]:SetWidth(MIN_BUTTON_WIDTH) end -- ensure minimum width
					width = width + b[i]:GetWidth()
					if i == 1 then
						b[i]:SetPoint("BOTTOMLEFT", entry.icon, "BOTTOMRIGHT", 5, 0)
					else
						b[i]:SetPoint("LEFT", b[i-1], "RIGHT", 5, 0)
					end
					b[i]:Show()
				end
				-- Check if we've more buttons than we should
				if #b > numButtons + 1 then
					for i = numButtons + 2, #b do b[i]:Hide() end
				end
				-- Store the width of this entry. Our handler will set it
				entry.width = width

				-- Adjust the width to match item text and item level, in case we have few buttons.
				entry.width = math.max(entry.width, 90 + entry.itemText:GetStringWidth())
				entry.width = math.max(entry.width, 89 + entry.itemLvl:GetStringWidth())
			end
			-------- Note button ---------
			entry.noteButton = CreateFrame("Button", nil, entry.frame)
			entry.noteButton:SetSize(24,24)
			entry.noteButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
			entry.noteButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
			entry.noteButton:SetPoint("BOTTOMRIGHT", entry.frame, "TOPRIGHT", -9, -entry.icon:GetHeight()-5)
			entry.noteButton:SetScript("OnEnter", function()
				if entry.item.note then -- If they already entered a note:
					addon:CreateTooltip(L["Your note:"], entry.item.note, "\n"..L["Click to change your note."])
				else
					addon:CreateTooltip(L["Add Note"], L["Click to add note to send to the council."])
				end
			end)
			entry.noteButton:SetScript("OnLeave", function() addon:HideTooltip() end)
			entry.noteButton:SetScript("OnClick", function()
				if not entry.noteEditbox:IsShown() then
					entry.noteEditbox:Show()
				else
					entry.noteEditbox:Hide()
					entry.item.note = entry.noteEditbox:GetText() ~= "" and entry.noteEditbox:GetText()
					entry:Update(entry.item)
				end
			end)

			entry.noteEditbox = CreateFrame("EditBox", nil, entry.frame, "AutoCompleteEditBoxTemplate, BackdropTemplate")
			entry.noteEditbox:SetMaxLetters(64)
			entry.noteEditbox:SetBackdrop(LootFrame.frame.title:GetBackdrop())
			entry.noteEditbox:SetBackdropColor(LootFrame.frame.title:GetBackdropColor())
			entry.noteEditbox:SetBackdropBorderColor(LootFrame.frame.title:GetBackdropBorderColor())
			entry.noteEditbox:SetFontObject(_G.ChatFontNormal)
			entry.noteEditbox:SetJustifyV("BOTTOM")
			entry.noteEditbox:SetWidth(100)
			entry.noteEditbox:SetHeight(24)
			entry.noteEditbox:SetPoint("BOTTOMLEFT", entry.frame, "TOPRIGHT", 0, -entry.icon:GetHeight()-5)
			entry.noteEditbox:SetTextInsets(5, 5, 0, 0)
			entry.noteEditbox:SetScript("OnEnterPressed", function(self)
				self:Hide()
				entry:Update(entry.item)
			end)
			entry.noteEditbox:SetScript("OnTextChanged", function(self)
				entry.item.note = self:GetText() ~= "" and self:GetText()
				-- Change the note button instead of calling entry:Update on every single input
				if entry.item.note then
					entry.noteButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
				else
					entry.noteButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
				end
			end)
			entry.noteEditbox:Hide()

			----- item text/lvl ---------------
			entry.itemText = entry.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
			entry.itemText:SetPoint("TOPLEFT", entry.icon, "TOPRIGHT", 6, -1)
			entry.itemText:SetText("Fatal error!!!!") -- Set text for reasons

			entry.itemLvl = entry.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			entry.itemLvl:SetPoint("TOPLEFT", entry.itemText, "BOTTOMLEFT", 1, -4)
			entry.itemLvl:SetTextColor(1, 1, 1) -- White
			entry.itemLvl:SetText("error")

			entry.bonuses = entry.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			entry.bonuses:SetPoint("LEFT", entry.itemLvl, "RIGHT", 1, 0)
			entry.bonuses:SetTextColor(0.2,1,0.2) -- Green

			------------ Timeout -------------
			entry.timeoutBar = CreateFrame("StatusBar", nil, entry.frame, "TextStatusBar")
			entry.timeoutBar:SetSize(entry.frame:GetWidth(), 6)
			entry.timeoutBar:SetPoint("BOTTOMLEFT", 9,3)
			entry.timeoutBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
			--entry.timeoutBar:SetStatusBarColor(0.1, 0, 0.6, 0.8) -- blue
			entry.timeoutBar:SetStatusBarColor(0.5, 0.5, 0.5, 1) -- grey
			entry.timeoutBar:SetMinMaxValues(0, addon.mldb.timeout or addon:Getdb().timeout or 30)
			entry.timeoutBar:SetScript("OnUpdate", function(this, elapsed)
				if entry.item.timeLeft <= 0 then --Timeout!
					this.text:SetText(L["Timeout"])
					this:SetValue(0)
					return LootFrame:OnRoll(entry, "TIMEOUT")
				end
				entry.item.timeLeft = entry.item.timeLeft - elapsed
				this.text:SetText(_G.CLOSES_IN..": "..ceil(entry.item.timeLeft)) -- _G.CLOSES_IN == "Time Left" for English
				this:SetValue(entry.item.timeLeft)
			end)

			-- We want to update the width of the timeout bar everytime the width of the whole frame changes:
			local main_width = entry.frame.SetWidth
			function entry:SetWidth(width)
				self.timeoutBar:SetWidth(width - 18) -- 9 indent on each side
				main_width(self.frame, width)
				self.width = width
			end

			entry.timeoutBar.text = entry.timeoutBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			entry.timeoutBar.text:SetPoint("CENTER", entry.timeoutBar)
			entry.timeoutBar.text:SetTextColor(1,1,1)
			entry.timeoutBar.text:SetText("Timeout")
		end,
	}

	local mt = { __index = entryPrototype}

	LootFrame.EntryManager = {  -- namespace
		numEntries = 0,
		entries = {},
		trashPool = {},
	}

	-- Hides and stores entries for reuse later
	function LootFrame.EntryManager:Trash(entry)
		addon.Log:D("Trashing entry:", entry.position or 0, entry.item.link)
		entry:Hide()
		if not self.trashPool[entry.type] then self.trashPool[entry.type] = {} end
		self.trashPool[entry.type][entry] = true
		tDeleteItem(self.entries, entry) -- To make tremove(self.entries, entry.position) works, :Update() must be run after every trash.
										 -- entry.position is only used for debugging purpose. Dangerous to rely on a changing index for deletion.
		self.entries[entry.item] = nil
		self.numEntries = self.numEntries - 1
	end

	function LootFrame.EntryManager:Get(type)
		if not self.trashPool[type] then return nil end
		local t = next(self.trashPool[type])
		if t then
			addon.Log:D("Restoring entry:", type, t.position or 0)
			self.trashPool[type][t] = nil
			return t
		end
	end

	-- Updates the order of the entries along with the width of self.frame
	function LootFrame.EntryManager:Update()
		local max = 0 -- We need 150 px + whatever the lenght of the buttons are
		for i, entry in ipairs(self.entries) do
			if entry.width > max then max = entry.width end
			if i == 1 then
				entry.frame:SetPoint("TOPLEFT", LootFrame.frame.content, "TOPLEFT",0,-5)
			else
				entry.frame:SetPoint("TOPLEFT", self.entries[i-1].frame, "BOTTOMLEFT")
			end
			entry.position = i
		end
	--	addon.Log:D("EntryManager:Update(), width = ", max)
		LootFrame.frame:SetWidth(max)
		-- Update the width of all entries after we've found the max width
		for _, entry in ipairs(self.entries) do
			entry:SetWidth(max)
		end
	end

	-- Entries need a item in items[], and will pull anything it needs from that table
	function LootFrame.EntryManager:GetEntry(item)
		if not item then return error("No such item!", tostring(item)) end
		if self.entries[item] then return self.entries[item] end -- It's already been created.
		-- Figure out what type of entry we want
		-- For now we're only handling 2 types: tier and nontier
		local entry
		if item.isRoll then
			entry = self:Get("roll")
		else
			entry = self:Get(item.typeCode or item.equipLoc)
		end
		if entry then -- We restored a previously trashed entry, so just update it to the new item
			entry:Update(item)
		else -- Or just create a new entry
			if item.isRoll then
				entry = self:GetRollEntry(item)
			else
				entry = self:GetNewEntry(item)
			end
		end
		entry:SetWidth(entry.width)
		entry:Show()
		self.numEntries = self.numEntries + 1
		entry.position = self.numEntries
		self.entries[self.numEntries] = entry
		self.entries[item] = entry
		return entry; -- Might not really be needed
	end

	function LootFrame.EntryManager:GetNewEntry(item)
		--addon.Log:D("Creating Entry:", "normal", item.link)
		local Entry = setmetatable({}, mt)
		Entry.type = item.typeCode or item.equipLoc
		Entry:Create(LootFrame.frame.content)
		Entry:Update(item)
		return Entry
	end

	function LootFrame.EntryManager:GetRollEntry(item)
		local Entry = setmetatable({}, mt)
		Entry.type = "roll"
		Entry:Create(LootFrame.frame.content)

		-- Relic entry uses different buttons, so change the function:
		function Entry.UpdateButtons(entry)
			local b = entry.buttons -- shortening
			b[1] = b[1] or CreateFrame("Button", nil, entry.frame) -- ROLL
			b[2] = b[2] or CreateFrame("Button", nil, entry.frame) -- pass
			local roll, pass = b[1], b[2]

			roll:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
			roll:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Highlight")
			roll:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Down")
			roll:SetScript("OnClick", function() LootFrame:OnRoll(entry, "ROLL") end)
			roll:SetSize(32, 32)
			roll:SetPoint("BOTTOMLEFT", entry.icon, "BOTTOMRIGHT", 5, -7)
			roll:Enable()
			roll:Show()

			pass:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
			pass:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight")
			pass:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
			pass:SetScript("OnClick", function() LootFrame:OnRoll(entry, "PASS") end)
			pass:SetSize(32, 32)
			pass:SetPoint("LEFT", roll, "RIGHT", 5, 3)
			pass:Show()

			entry.rollResult = entry.rollResult or entry.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
			entry.rollResult:SetPoint("LEFT", roll, "RIGHT", 5, 3)
			entry.rollResult:SetText("")
			entry.rollResult:Hide()

			local width = 113 + 1 * 5 + 32 + 32
			-- Store the width of this entry. Our handler will set it
			entry.width = width

			-- Adjust the width to match item text and item level, in case we have few buttons.
			entry.width = math.max(entry.width, 90 + entry.itemText:GetStringWidth())
			entry.width = math.max(entry.width, 89 + entry.itemLvl:GetStringWidth())
		end
		Entry:Update(item)

		return Entry
	end
end

-- Process roll message, to send roll with the response.
function LootFrame:CHAT_MSG_SYSTEM(event, msg)
	local name, roll, low, high = string.match(msg, RANDOM_ROLL_PATTERN)
	roll, low, high = tonumber(roll), tonumber(low), tonumber(high)

	if name and low == 1 and high == 100 and addon:UnitIsUnit(Ambiguate(name, "short"), "player") and sessionsWaitingRollResultQueue[1] then
		local entryInQueue = sessionsWaitingRollResultQueue[1]
		tremove(sessionsWaitingRollResultQueue, 1)
		self:CancelTimer(entryInQueue.timer)
		local entry = entryInQueue.entry
		local item = entry.item
		addon:Send("group", "roll", addon.playerName, roll, item.sessions)
		addon:SendAnnouncement(format(L["'player' has rolled 'roll' for: 'item'"], addon.Ambiguate(addon.playerName), roll, item.link), "group")
		entry.rollResult:SetText(roll)
		entry.rollResult:Show()
		self:ScheduleTimer("OnRollTimeout", ROLL_SHOW_RESULT_TIME, entryInQueue)
		-- Hide the frame in "OnRollTimeout"
    end
end

-- Hide roll frame after some time clicks roll
function LootFrame:OnRollTimeout(entryInQueue)
	tDeleteItem(sessionsWaitingRollResultQueue, entryInQueue)
	local entry = entryInQueue.entry
	entry.item.rolled = true
	self.EntryManager:Trash(entry)
	self:Update()
end
