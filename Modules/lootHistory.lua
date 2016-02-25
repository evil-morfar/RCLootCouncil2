-- Author      : Potdisc
-- Create Date : 8/6/2015
-- DefaultModule
-- lootHistory.lua	Adds the interface for displaying the collected loot history

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
LootHistory = addon:NewModule("RCLootHistory")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local lootDB, scrollCols, data, db;
local selectedDate, selectedName, filterDrop;
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
		--[[{name = "", 			width = ROW_HEIGHT, },	-- Expand button
		{name = "Date",		width = 70, 		},	-- Date-time
		{name = "Raid",		width = 100,		},	-- Name of the raid]]
		{name = "",				width = ROW_HEIGHT, },	-- Class icon, should be same row as player
		{name = "Name",		width = 100, 				},	-- Name of the player
		-- The following should all be on 1 row
		--{name = "#",			width = 20, 				},	-- Index of items won by player
		{name = "",				width = ROW_HEIGHT, },	-- Item at index icon
		{name = "Item",		width = 250, 				}, 	-- Item string
		{name = "Reason",		width = 230, comparesort = self.ResponseSort, sort = "asc"},	-- Response aka the text supplied to lootDB...response
	}


	--filterMenu = CreateFrame("Frame", "RCLootCouncil_LootHistory_FilterMenu", UIParent, "Lib_UIDropDownMenuTemplate")
	--Lib_UIDropDownMenu_Initialize(filterMenu, self.FilterMenu, "MENU")
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
	addon:Debug("LootHistory:BuildData()")
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
			if not data[date][name] then
				data[date][name] = {}
			end
			if not data[date][name][i] then
				data[date][name][i] = {}
			end
			for k, t in pairs(v) do
				if k == "class" then -- we need the class at a different level
					data[date][name].class = t
				elseif k ~= "date" then -- We don't need date
					data[date][name][i][k] = t
				end
			end
			if not data[date][name][i].instance then
				data[date][name][i].instance = "Unknown"
			end
		end
	end
	table.sort(data)
	-- Now create a blank data table for lib-st to init with
	self.frame.rows = {}
	local dateData, nameData, insertedNames = {}, {}, {}
	local row = 1;
	for date, v in pairs(data) do
		for name, x in pairs(v) do
			for num, i in pairs(x) do
				self.frame.rows[row] = {
					date = date,
					class = x.class,
					name = name,
					num = num,
					cols = {
						{DoCellUpdate = addon.SetCellClassIcon, args = {x.class}},
						{value = addon.Ambiguate(name), color = addon:GetClassColor(x.class)},
						{DoCellUpdate = self.SetCellGear, args={i.lootWon}},
						{value = i.lootWon},
						{DoCellUpdate = self.SetCellResponse, args = {color = i.color, response = i.response, responseID = i.responseID or 0, isAwardReason = i.isAwardReason}}
					}
				}
				row = row + 1
			end
			if not tContains(insertedNames, name) then -- we only want each name added once
				tinsert(nameData,
					{{DoCellUpdate = addon.SetCellClassIcon, args = {x.class}},
					{value = addon.Ambiguate(name), color = addon:GetClassColor(x.class), name = name}}
				)
				tinsert(insertedNames, name)
			end
		end
		tinsert(dateData, {date})
	end
	self.frame.st:SetData(self.frame.rows)
	self.frame.date:SetData(dateData, true) -- True for minimal data	format
	self.frame.name:SetData(nameData, true)
end

function LootHistory.FilterFunc(table, row)
	if selectedName and selectedDate then
		return row.name == selectedName and row.date == selectedDate
	elseif selectedName then
		return row.name == selectedName
	elseif selectedDate then
		return row.date == selectedDate
	else
		return true -- show all rows when nothing's selected
	end
end

function LootHistory.SetCellGear(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local gear = data[realrow].cols[column].args[1] -- gear1 or gear2
	if gear then
		local texture = select(10, GetItemInfo(gear))
		frame:SetNormalTexture(texture)
		frame:SetScript("OnEnter", function() addon:CreateHypertip(gear) end)
		frame:SetScript("OnLeave", function() addon:HideTooltip() end)
		frame:Show()
	else
		frame:Hide()
	end
end

function LootHistory.SetCellResponse(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local args = data[realrow].cols[column].args
	if args.responseID and args.responseID ~= 0 and not args.isAwardReason then
		frame.text:SetText(addon.responses[args.responseID].text)
	else
		frame.text:SetText(args.response)
	end
	if args.color then -- Never version saves the color with the entry
		frame.text:SetTextColor(unpack(args.color))
	elseif args.responseID > 0 then -- try to recreate color from ID
		frame.text:SetTextColor(addon:GetResponseColor(args.responseID))
	else -- default to white
		frame.text:SetTextColor(1,1,1,1)
	end
end

function LootHistory.DateSort(table, rowa, rowb, sortbycol)
	local column = table.cols[sortbycol]
	rowa, rowb = table:GetRow(rowa), table:GetRow(rowb);
	local a, b = rowa[1], rowb[1]
	if not (a and b) then return false end
	local d, m, y = strsplit("/", a, 3)
	local aTime = time({year = "20"..y, month = m, day = d})
	d, m, y = strsplit("/", b, 3)
	local bTime = time({year = "20"..y, month = m, day = d})
	local direction = column.sort or column.defaultsort or "asc";
	if direction:lower() == "asc" then
		return aTime < bTime;
	else
		return aTime > bTime;
	end
end

function LootHistory.ResponseSort(table, rowa, rowb, sortbycol)
	local column = table.cols[sortbycol]
	rowa, rowb = table:GetRow(rowa), table:GetRow(rowb);
	local a,b
	local aID, bID = data[rowa.date][rowa.name][rowa.num].responseID, data[rowb.date][rowb.name][rowb.num].responseID
	if aID and aID ~= 0 and bID and bID ~= 0 then
		if data[rowa.date][rowa.name][rowa.num].isAwardReason then
			a = db.awardReasons[aID].sort
			addon:Debug(data[rowa.date][rowa.name][rowa.num].response, "was awardReasons with sort ",a)
		else
			a = addon:GetResponseSort(aID)
		end
		if data[rowb.date][rowb.name][rowb.num].isAwardReason then
			b = db.awardReasons[bID].sort
		else
			b = addon:GetResponseSort(bID)
		end
	else
		return false
	end

	local direction = column.sort or column.defaultsort or "asc";
	if direction:lower() == "asc" then
		return a < b;
	else
		return a > b;
	end
end

---------------------------------------------------
-- Visauls
---------------------------------------------------
function LootHistory:Update()
	self.frame.st:SortData()
end

function LootHistory:GetFrame()
	if self.frame then return self.frame end
	local f = addon:CreateFrame("DefaultRCLootHistoryFrame", "history", L["RCLootCouncil Loot History"], 250, 470)
	local st = LibStub("ScrollingTable"):CreateST(scrollCols, NUM_ROWS, ROW_HEIGHT, { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5 }, f.content)
	st.frame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
	st:SetFilter(self.FilterFunc)
	st:EnableSelection(true)
	f.st = st

	--Date selection
	f.date = LibStub("ScrollingTable"):CreateST({{name = "Date", width = 70, comparesort = self.DateSort, sort = "desc"}}, 5, ROW_HEIGHT, { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5 }, f.content)
	f.date.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -15)
	f.date:EnableSelection(true)
	f.date:RegisterEvents({
		["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
			if button == "LeftButton" and row then
				selectedDate = data[realrow][column] ~= selectedDate and data[realrow][column] or nil
				self:Update()
			end
			return false
		end
	})

	--Name selection
	f.name = LibStub("ScrollingTable"):CreateST({{name = "", width = ROW_HEIGHT},{name = "Name", width = 100, sort = "desc"}}, 5, ROW_HEIGHT, { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5 }, f.content)
	f.name.frame:SetPoint("TOPLEFT", f.date.frame, "TOPRIGHT", 20, 0)
	f.name:EnableSelection(true)
	f.name:RegisterEvents({
		["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
			if button == "LeftButton" and row then
				selectedName = selectedName ~= data[realrow][column].name and data[realrow][column].name or nil
				self:Update()
			end
			return false
		end
	})

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
	Lib_UIDropDownMenu_Initialize(b3, self.DateDrop)

	-- Set a proper width
	f:SetWidth(st.frame:GetWidth() + 20)
	return f;
end

---------------------------------------------------
-- Dropdowns
---------------------------------------------------
function LootHistory.DateDrop(menu, level)
	local info = Lib_UIDropDownMenu_CreateInfo() -- Efficiency :)
	if data then
		for date in pairs(data) do
			info = Lib_UIDropDownMenu_CreateInfo()
			info.text = date
			info.value = date
			info.func = function()
				selectedDate = date
				addon:Debug("Selected date = ", date)
				Lib_UIDropDownMenu_SetSelectedID(RCLootCouncil_LootHistory_DateDrop, RCLootCouncil_LootHistory_DateDrop:GetID())
				LootHistory.frame.st:SortData()
			end
			Lib_UIDropDownMenu_AddButton(info, level)
		end
	end
end
