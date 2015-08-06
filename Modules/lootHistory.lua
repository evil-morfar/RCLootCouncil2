-- Author      : Potdisc
-- Create Date : 8/6/2015
-- DefaultModule
-- lootHistory.lua	Adds the interface for displaying the collected loot history

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local LootHistory = addon:NewModule("RCLootHistory")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local lootDB, scrollCols, filterMenu, data, db;
--[[ data structure:
	data[date][instance] = {
		[playerName] = {
			-- Remaining content in lootDB[playerName]
		}
	}
]]
local moreInfo = false
local ROW_HEIGHT = 20;
local NUM_ROWS = 15;

function LootHistory:OnInitialize()
	scrollCols = {
		-- The following should have a row of their own with a expand button
		{name = "", 			width = ROW_HEIGHT, },	-- Expand button
		{name = "Date",		width = 40, 				},	-- Date-time
		{name = "Raid",		width = 100,				},	-- Name of the raid
		{name = "",				width = ROW_HEIGHT, },	-- Class icon, should be same row as player
		{name = "Name",		width = 130, 				},	-- Name of the player
		-- The following should all be on 1 row
		{name = "#",			width = 30, 				},	-- Index of items won by player
		{name = "",				width = ROW_HEIGHT, },	-- Item at index icon
		{name = "Item",		width = 200, 				}, 	-- Item string
		{name = "Reason",	width = 240, 				},	-- Response aka the text supplied to lootDB...response
	}

	filterMenu = CreateFrame("Frame", "RCLootCouncil_LootHistory_FilterMenu", UIParent, "Lib_UIDropDownMenuTemplate")
	Lib_UIDropDownMenu_Initialize(menuFrame, self.FilterMenu, "MENU")
end

function LootHistory:OnEnable()
	db = addon:Getdb()
	lootDB = addon:GetLootDB()
	self.frame = self:GetFrame()
	self:BuildData()
	self:Show()
end

function LootHistory:OnDisable()
	self:Hide()
	self.frame:SetParent(nil)
	self.frame = nil
end

function LootHistory:Show()
	self.frame:Show()
end

function LootHistory:Hide()
	self.frame:Hide()
end

function LootHistory:BuildData()
	local date, instance;
	-- We want to rebuild lootDB to the "data" format:
	local i = 1
	for name, v in ipairs(lootDB) do
		date = v.date
		if not date then -- Unknown date
			date = "Unknown date"
		end
		if not data[date] then -- We haven't added the date to data, do it
			data[date] = {}
		end
		instance = v.instance
		if not instance then
			instance = "Unknown instance"
		end
		if not data[date][instance] then -- We haven't added the instance to data[date] yet!
				data[date][instance] = {}
		end
		if not data[date][instance][name] then
			data[date][instance][name] = {}
		end
		data[date][instance][name][i] = {}
		-- Now we actually add the data
		for k,v in pairs(v) do
			if k == "class" then -- we need the class at a different level
				data[date][instance][name].class = v
			elseif k ~= "date" or k ~= "instance" then -- We don't need date or instance
				data[date][instance][name][i][k] = v
			end
		end
		-- We want an expanded field on each expandable option:
		data[date][instance][name].expanded = false
		data[date][instance].expanded = false
		data[date].expanded = false
		i = i + 1
	end
	-- Now create a blank data table for lib-st to init with
	-- We need the number of rows to match the number of entries in lootDB
	self.frame.rows = {}
	i = 1
	for name in pairs(lootDB) do
		self.frame.rows[i] = function()
			local t = {}
			for j = 1, #scrollCols do
				t[j] = "" -- Set cells as blank, we'll update with our own functions
			end
			return t
		end
		self.frame.rows[i].date = lootDB[name].date or "Unknown date"
		self.frame.rows[i].DoCellUpdate = self.RowUpdate
		i = i + 1
	end
	self.frame.st:SetData(self.frame.rows, true) -- True for minimal data	format
end

---------------------------------------------------
-- Visauls
---------------------------------------------------
function LootHistory:Update()
	self.frame.st:SortData()
end

function LootHistory:GetFrame()
	if self.frame then return self.frame end
	local f = addon:CreateFrame("DefaultRCLootHistoryFrame", "history", L["RCLootCouncil Loot History"], 250, 420)
	local st = LibStub("ScrollingTable"):CreateST(scrollCols, NUM_ROWS, ROW_HEIGHT, { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5 }, f.content)
	st.frame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
	st:SetFilter(self.FilterFunc)
	st:EnableSelection(true)
	f.st = st

	-- Abort button
	local b1 = addon:CreateButton(L["Close"], f.content)
	b1:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -45)
	b1:SetScript("OnClick", function() self:Disable() end)
	f.closeBtn = b1

	-- More info button
	local b2 = CreateFrame("Button", nil, f.content, "UIPanelButtonTemplate")
	b2:SetSize(25,25)
	b2:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -10)
	b2:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	b2:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	b2:SetScript("OnClick", function(button)
		moreInfo = not moreInfo
		if moreInfo then -- show the more info frame
			button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
			button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
		else -- hide it
			button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
		end
	end)
	b2:SetScript("OnEnter", function() addon:CreateTooltip(L["Click to expand/collapse more info"]) end)
	b2:SetScript("OnLeave", addon.HideTooltip)
	f.moreInfoBtn = b2

	-- Filter
	local b3 = addon:CreateButton(L["Filter"], f.content)
	b3:SetPoint("RIGHT", b1, "LEFT", -10, 0)
	b3:SetScript("OnClick", function(self) Lib_ToggleDropDownMenu(1, nil, filterMenu, self, 0, 0) end )
	b3:SetScript("OnEnter", function() addon:CreateTooltip(L["Deselect responses to filter them"]) end)
	b3:SetScript("OnLeave", addon.HideTooltip)
	f.filter = b3

	-- Set a proper width
	f:SetWidth(st.frame:GetWidth() + 20)
	return f;
end

function LootHistory.FilterFunc(table, row)
 -- TODO
end

function LootHistory.FilterMenu(menu, level)
	if level == 1 then -- Redundant
		-- TODO
	end
end

-----------------------------------------------
-- DoCellUpdates for lib-st
-----------------------------------------------
function LootHistory.RowUpdate(rowFrame, cellFrame, stData, cols, row, realrow, column, fShow, table, ...)
	local date = stData[realrow].date
	if data[date].drawn then return rowFrame:Hide() end -- We've already made this row
	-- Set the date text
	for i = 1, #cols do
		if cols[i].name == "Date" then
			rowFrame.cols[i].text = date
		else -- everything should be blank
			rowFrame.cols[i].text = ""
		end
	end
	local expanded = data[date].expanded
	if expanded then -- Date expanded, show raids
		local i = 1 -- We need to pass the next rowframe
		for raid in pairs(data[date]) do -- Show the raid row
			LootHistory:SetRowRaid(table, table.rows[row + i], row + i, date, raid)
			i = i + 1
		end
	end
	self:SetExpandButton(frame, expanded)
	data[date].drawn = true -- Make sure we only make each row once
end

function LootHistory:SetRowRaid(table, rowFrame, row, date, raid)
-- we might need some row > NUM_ROWS then rowFrame:Hide()
	-- Set the raid text
	for i = 1, #scrollCols do
		if scrollCols[i].name == "Raid" then
			rowFrame.cols[i].text = raid
		else -- everything should be blank
			rowFrame.cols[i].text = ""
		end
	end
	local expanded = data[date][raid].expanded
	if expanded then -- Raid expanded, show names
		local i = 1
		for name in pairs(data[date][raid]) do
			self:SetRowName(table, table.rows[row + i], row + 1, date, raid, name)
			i = i + 1
		end
	end
	self:SetExpandButton(frame, expanded)
end

function LootHistory:SetRowName(table, rowFrame, row, date, raid, name)
	-- Set the name text
	for i = 1, #scrollCols do
		if scrollCols[i].name == "Name" then
			rowFrame.cols[i].text = addon.Ambiguate(name)
			if data[date][raid][name].class then -- We have a class, so set appropiate color
				local c = addon:GetClassColor(data[date][raid][name].class)
				rowFrame.cols[i].text:SetTextColor(c.r,c.g,c.b,c.a)
			else -- Default to white
				rowFrame.cols[i].text:SetTextColor(1,1,1,1)
			end
		else -- everything should be blank
			rowFrame.cols[i].text = ""
		end
	end
	local expanded = data[date][raid][name].expanded
	if expanded then -- Name expanded, show items
		local i = 1
		for num in pairs(data[date][raid][name]) do
			self:SetRowItem(table.rows[row + i], date, raid, name, num) -- Last one, doesn't need table or row
			i = i + 1
		end
	end
	self:SetExpandButton(frame, expanded)
end

function LootHistory:SetRowItem(rowFrame, date, raid, name, num)
	local t = data[date][raid][name][num] -- Shortcut
	-- t has all the info from lootDB not assigned elsewhere
	for i = 1, #scrollCols do
		if scrollCols[i].name == "#" then
			rowFrame.cols[i] = tostring(num)
		elseif scrollCols[i].name == "Item" then
			rowFrame.cols[i].text = t.lootWon
		elseif scrollCols[i].name == "Response" then
			rowFrame.cols[i].text = t.response or "Error in response"

			if t.color then -- Post v2.0, color will be the color it was when awarded
				rowFrame.cols[i].text:SetTextColor(t.color)
			elseif t.responseID > 0 then -- responseID = 0 if pre v2.0 awardReason
				-- We have an id to fallback on, so use the current color
				rowFrame.cols[i].text:SetTextColor(addon:GetResponseColor(t.responseID))
			else	-- We don't have color info, so default to white
				rowFrame.cols[i].text:SetTextColor(1,1,1,1)
			end
		else -- All other cells should be blank
			rowFrame.cols[i].text = ""
		end
	end
end

function LootHistory:SetExpandButton(frame, expanded)
	frame:SetScript("OnClick", function() expanded = not expanded end) -- REVIEW See if expanded actually points to the right object in data
	if expanded then -- Show minus
		frame:SetNormalTexture("Interface\\BUTTONS\\UI-MinusButton-Up")
		frame:SetPushedTexture("Interface\\BUTTONS\\UI-MinusButton-Down")
		frame:SetHighlightTexture("Interface\\BUTTONS\\UI-MinusButton-Hilight")
	else -- Show plus
		frame:SetNormalTexture("Interface\\BUTTONS\\UI-PlusButton-Up")
		frame:SetPushedTexture("Interface\\BUTTONS\\UI-PlusButton-Down")
		frame:SetHighlightTexture("Interface\\BUTTONS\\UI-PlusButton-Hilight")
	end
end
