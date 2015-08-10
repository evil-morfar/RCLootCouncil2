-- Author      : Potdisc
-- Create Date : 8/6/2015
-- DefaultModule
-- lootHistory.lua	Adds the interface for displaying the collected loot history

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
LootHistory = addon:NewModule("RCLootHistory")
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
		{name = "Date",		width = 70, DoCellUpdate = self.SetCellDate,		},	-- Date-time
		{name = "Raid",		width = 100,		},	-- Name of the raid
		{name = "",				width = ROW_HEIGHT, },	-- Class icon, should be same row as player
		--{name = "Name",		width = 100, 				},	-- Name of the player
		-- The following should all be on 1 row
		{name = "#",			width = 20, 				},	-- Index of items won by player
		{name = "",				width = ROW_HEIGHT, },	-- Item at index icon
		{name = "Item",		width = 200, 				}, 	-- Item string
		{name = "Reason",	width = 240, 				},	-- Response aka the text supplied to lootDB...response
	}

	filterMenu = CreateFrame("Frame", "RCLootCouncil_LootHistory_FilterMenu", UIParent, "Lib_UIDropDownMenuTemplate")
	Lib_UIDropDownMenu_Initialize(filterMenu, self.FilterMenu, "MENU")
end

function LootHistory:OnEnable()
	db = addon:Getdb()
	lootDB = addon:GetHistoryDB()
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
	data = {}
	local date, instance;
	-- We want to rebuild lootDB to the "data" format:
	--local i = 1
	for name, v in pairs(lootDB) do
		-- Now we actually add the data
		for i,v in ipairs(v) do
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
			if not data[date][instance][name][i] then
				data[date][instance][name][i] = {}
			end
			for k, v in pairs(v) do
				if k == "class" then -- we need the class at a different level
					data[date][instance][name].class = v
				elseif k ~= "date" or k ~= "instance" then -- We don't need date or instance
					data[date][instance][name][i][k] = v
				end
			end
		end
		-- We want an expanded field on each expandable option:
		data[date][instance][name].expanded = false
		data[date][instance].expanded = false
		data[date].expanded = false
		--i = i + 1
	end
	-- Now create a blank data table for lib-st to init with
	self.frame.rows = {}
	local function t()
		local t = {} -- Get a table to use as cells
		for j = 1, #scrollCols do
			t[j] = "" -- Set cells as blank, we'll update with our own functions
		end
		return t
	end
	local i = 1
	local reg_dates = {} -- Used to init correct filtered status
	-- We need the number of rows to match the number of entries in lootDB
	for name, j in pairs(lootDB) do
		for _, v in ipairs(j) do
			self.frame.rows[i] = t()
			self.frame.rows[i].filtered = tContains(reg_dates, v.date)
			self.frame.rows[i].date = v.date or "Unknown date"
			tinsert(reg_dates, self.frame.rows[i].date)
			self.frame.rows[i].DoCellUpdate = function() return end -- Override
			i = i + 1
		end
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
	addon:Debug("FilterFunc", row, not row.filtered)
	return not row.filtered
end

function LootHistory.FilterMenu(menu, level)
	if level == 1 then -- Redundant
		-- TODO
	end
end

-----------------------------------------------
-- DoCellUpdates for lib-st
-----------------------------------------------
function LootHistory.SetCellDate(rowFrame, cellFrame, stData, cols, row, realrow, column, fShow, table, ...)
	local date = stData[realrow].date
	if not data[date].drawn then -- We didn't draw this, so unfilter
		stData[realrow].filtered = false
	end
	if stData[realrow].filtered then
		-- If the date is filtered it mean the filter func wasn't called with the updated filters
		LootHistory:Update()

	else -- Not filtered, we need to set filtered status on ALL child rows
		addon:Debug("Showing row", row, realrow, fShow)
		for k = realrow+1, #stData do
			if stData[k].date == date then
				addon:Debug("Filtering", k, not data[date].expanded)
				stData[k].filtered = not data[date].expanded
			end
		end
		cellFrame.text:SetText(date)
		LootHistory:SetExpandButton(true, rowFrame.cols[1], date)
	end
	data[date].drawn = true

	if data[date].expanded then
		local i = 1
		for k,v in pairs(data[date]) do
			LootHistory:SetRowRaid(stData, realrow + i, table.rows[row + i], date, k)
		end
	end
end

function LootHistory:SetRowRaid(stData, realrow, rowFrame, date, raid)
	stData[realrow].filtered = false -- unfilter
	for i = 1, #scrollCols do
		if scrollCols[i].name == "Raid" then
			rowFrame.cols[i].text:SetText(raid)
		else
			rowFrame.cols[i].text:SetText("")
		end
	end
	LootHistory:SetExpandButton(true, rowFrame.cols[1], date)
end

function LootHistory:SetExpandButton(show, frame, date, raid, name)
	if show then
		local t
		if name then t = data[date][raid][name]
		elseif raid then t = data[date][raid]
		else t = data[date] end
		frame:SetScript("OnClick", function() t.expanded = not t.expanded; t.drawn = false; self:Update(); end) -- REVIEW See if expanded actually points to the right object in data
		if t.expanded then -- Show minus
			frame:SetNormalTexture("Interface\\BUTTONS\\UI-MinusButton-Up")
			frame:SetPushedTexture("Interface\\BUTTONS\\UI-MinusButton-Down")
			frame:SetHighlightTexture("Interface\\BUTTONS\\UI-PlusButton-Hilight")
		else -- Show plus
			frame:SetNormalTexture("Interface\\BUTTONS\\UI-PlusButton-Up")
			frame:SetPushedTexture("Interface\\BUTTONS\\UI-PlusButton-Down")
			frame:SetHighlightTexture("Interface\\BUTTONS\\UI-PlusButton-Hilight")
		end
		frame:Show()
	else
		frame:Hide()
	end
end
