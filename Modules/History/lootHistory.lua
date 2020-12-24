--- lootHistory.lua Adds the interface for displaying the collected loot history.
-- DefaultModule
-- @author Potdisc
-- Create Date : 8/6/2015
--[[ COMMS:
	MAIN:
		history				P - history received from ML on awards.
		delete_history		P - ML tells us to delete specific history entry.
]]
---@type RCLootCouncil
local _,addon = ...
---@class LootHistory
local LootHistory = addon:NewModule("RCLootHistory", "AceSerializer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local AG = LibStub("AceGUI-3.0")
local Comms = addon.Require "Services.Comms"
local COMMS_PREFIX = addon.PREFIXES.MAIN
local lootDB, data, db
--[[ data structure:
data[date][playerName] = {
	["class"] = CLASS,
	[i] = { -- Num item given to player, lowest first
		-- Remaining content in lootDB[playerName]
	}
}
]]
local selectedDate, selectedName, filterMenu, moreInfo, moreInfoData
local rightClickMenu;
local ROW_HEIGHT = 20;
local NUM_ROWS = 15;
local epochDates = {} -- [DateTime] = epoch
local useClassFilters = false

LootHistory.wowheadBaseUrl = "https://www.wowhead.com/item="

--globals
local tinsert, tostring, getglobal, pairs, ipairs, tremove, strsplit = tinsert, tostring, getglobal, pairs, ipairs, tremove, strsplit

function LootHistory:OnInitialize()
	self.exportSelection = "tsv"
	-- Pointer to export functions. Expected to return a string containing the export
	self.exports = {
		csv = 		{func = self.ExportCSV,			name = "CSV",					tip = L["Standard .csv output."]},
		tsv = 		{func = self.ExportTSV,			name = "TSV (Excel)",		tip = L["A tab delimited output for Excel. Might work with other spreadsheets."]},
		bbcode = 	{func = self.ExportBBCode,		name = "BBCode", 				tip = L["Simple BBCode output."]},
		bbcodeSmf = {func = self.ExportBBCodeSMF, name = "BBCode SMF",			tip = L["BBCode export, tailored for SMF."],},
		eqxml = 		{func = self.ExportEQXML,		name = "EQdkp-Plus XML",	tip = L["EQdkp-Plus XML output, tailored for Enjin import."]},
		player = 	{func = self.PlayerExport,		name = "Player Export",		tip = L["A format to copy/paste to another player."]},
		discord = 	{func = self.ExportDiscord, 	name = "Discord", 			tip = L["Discord friendly output."]},
		json = 		{func = self.ExportJSON,		name = "JSON",					tip = L["Standard JSON output."]},
		--html = self.ExportHTML
	}
	self.scrollCols = {
		{name = "",				width = ROW_HEIGHT, sortnext = 2},																-- Class icon, should be same row as player
		{name = _G.NAME,		width = 100, sortnext = 3, defaultsort = 1,},												-- Name of the player
		{name = L["Time"],	width = 125, comparesort = self.DateTimeSort, sort = 2,defaultsort = 2,},			-- Time of awarding
		{name = "",				width = ROW_HEIGHT, },																				-- Item icon
		{name = L["Item"],	width = 250, comparesort = self.ItemSort, defaultsort = 1, sortnext = 2},			-- Item string
		{name = L["Reason"],	width = 220, comparesort = self.ResponseSort,  defaultsort = 1, sortnext = 2},	-- Response aka the text supplied to lootDB...response
		{name = "",				width = ROW_HEIGHT},																					-- Delete button
	}
	filterMenu = _G.MSA_DropDownMenu_Create("RCLootCouncil_LootHistory_FilterMenu", UIParent)
	rightClickMenu = _G.MSA_DropDownMenu_Create("RCLootCouncil_LootHistory_RightclickMenu", UIParent)
	_G.MSA_DropDownMenu_Initialize(filterMenu, self.FilterMenu, "MENU")
	_G.MSA_DropDownMenu_Initialize(rightClickMenu, self.RightClickMenu, "MENU")
	--MoreInfo
	self.moreInfo = CreateFrame( "GameTooltip", "RCLootHistoryMoreInfo", nil, "GameTooltipTemplate" )

	self:SubscribeToPermanentComms()
end

local tierLookUpTable = { -- instanceMapID to Tier text
	[1530] = L["Tier 19"],
	[1676] = L["Tier 20"],
	[1712] = L["Tier 21"],
}

local difficultyLookupTable = {
	[14] = L["tier_token_normal"],
	[15] = L["tier_token_heroic"],
	[16] = L["tier_token_mythic"],
}

function LootHistory:OnEnable()
	addon.Log("LootHistory:OnEnable()")
	moreInfo = true
	db = addon:Getdb()
	lootDB = addon:GetHistoryDB()
	for _,v in pairs(db.modules["RCLootHistory"].filters.class) do
		if v then
			useClassFilters = true
			break
		end
	end
	self.frame = self:GetFrame()
	self:BuildData()
	self:Show()
end

function LootHistory:OnDisable()
	self:Hide()
	self.frame:SetParent(nil)
	self.frame = nil
	data = {}
end

--- Show the LootHistory frame.
function LootHistory:Show()
	addon.Log("LootHistory:Show()")
	moreInfoData = addon:GetLootDBStatistics()
	self.frame:Show()
end

--- Hide the LootHistory frame.
function LootHistory:Hide()
	self.frame:Hide()
	self.moreInfo:Hide()
	moreInfo = false
end

function LootHistory:SubscribeToPermanentComms ()
	Comms:BulkSubscribe(COMMS_PREFIX, {
		history = function (data)
			self:OnHistoryReceived(unpack(data))
		end,
		delete_history = function(data)
			self:OnHistoryDeleteReceived(unpack(data))
		end
	})
end

function LootHistory:OnHistoryReceived (name, history)
	if not addon:Getdb().enableHistory then return end
	-- v2.15 Add itemClass and itemSubClass locally:
	local _, _, _, _, _, itemClassID, itemSubClassID = GetItemInfoInstant(history.lootWon)
	history.iClass = itemClassID
	history.iSubClass = itemSubClassID
	if addon.lootDB.factionrealm[name] then
		tinsert(addon.lootDB.factionrealm[name], history)
	else
		addon.lootDB.factionrealm[name] = {history}
	end
	if self:IsEnabled() then -- Update history frame if it is shown currently.
		self:BuildData()
	end
end

function LootHistory:OnHistoryDeleteReceived (id)
	if not addon:Getdb().enableHistory then return end
	for _, d in pairs(addon.lootDB.factionrealm) do
		for i = #d, 1, -1 do
			local entry = d[i]
			if entry.id == id then
				tremove(d, i)
				break
			end
		end
	end
	if self:IsEnabled() then -- Update history frame if it is shown currently.
		self:BuildData()
	end
end

function LootHistory:GetLocalizedDate(date) -- date is "DD/MM/YY"
	local d, m, y = strsplit("/", date, 3)
	-- FormatShortDate is defined in SharedXML/Util.lua
	-- "(D)D/(M)M/YY" for EU, "(M)M/DD/YY" otherwise
	return _G.FormatShortDate(d, m, y)
end

function LootHistory:BuildData()
	addon.Log:D("LootHistory:BuildData()")
	data = {}
	local date
	-- We want to rebuild lootDB to the "data" format:
	--local i = 1
	for name, a in pairs(lootDB) do
		-- Now we actually add the data
		for i,v in ipairs(a) do
			date = v.date
			if not date then -- Unknown date
				date = L["Unknown date"]
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
				data[date][name][i].instance = _G.UNKNOWN
			end
		end
	end
	table.sort(data)
	-- Now create a blank data table for lib-st to init with
	self.frame.rows = {}
	local dateData, nameData, insertedNames = {}, {}, {}
	local row = 1;
	for date, v in pairs(data) do --luacheck: ignore
		for name, x in pairs(v) do
			for num, i in pairs(x) do
				if num ~= "class" then
					self.frame.rows[row] = {
						date = date,
						class = x.class,
						name = name,
						num = num, -- That's really the index in lootDB[name]
						response = i.responseID,
						isAwardReason = i.isAwardReason,
						cols = { -- NOTE Don't forget the rightClickMenu dropdown, if the order of these changes
							{DoCellUpdate = addon.SetCellClassIcon, args = {x.class}, value = x.class},
							{value = addon.Ambiguate(name), color = addon:GetClassColor(x.class)},
							{value = self:GetLocalizedDate(date).. "-".. i.time or "", args = {time = i.time, date = date},},
							{DoCellUpdate = self.SetCellGear, args={i.lootWon}},
							{value = i.lootWon},
							{DoCellUpdate = self.SetCellResponse, args = {color = i.color, response = i.response, responseID = i.responseID or 0, isAwardReason = i.isAwardReason}},
							{DoCellUpdate = self.SetCellDelete},
						}
					}
					row = row + 1
				end
			end
			if not insertedNames[name] then -- we only want each name added once
				tinsert(nameData,
					{
						{DoCellUpdate = addon.SetCellClassIcon, args = {x.class}},
						{value = addon.Ambiguate(name), color = addon:GetClassColor(x.class), name = name}
					}
				)
				insertedNames[name] = true
			elseif x.class then -- it already exists, but we might need to add the class which we now have
				for i in pairs(nameData) do
					if nameData[i][2].name == name then
						nameData[i][1].args = {x.class}
					end
				end
			end
		end
		tinsert(dateData, {date})
	end
	-- Insert players in the group who isn't registered in the lootDB
	for name,v in pairs(addon.candidates or {}) do
		if not insertedNames[name] then
			tinsert(nameData, {
				{DoCellUpdate = addon.SetCellClassIcon, args = {v.class}},
				{value = addon.Ambiguate(name), color = addon:GetClassColor(v.class), name = name}
			})
		end
	end
	self.frame.st:SetData(self.frame.rows)
	self.frame.date:SetData(dateData, true) -- True for minimal data	format
	self.frame.name:SetData(nameData, true)
end

function LootHistory:GetAllRegisteredCandidates()
	local names = {}
	lootDB = addon:GetHistoryDB()
	for name, a in pairs(lootDB) do
		for _, v in ipairs(a) do
			if v.class then
				names[name] = {name = addon.Ambiguate(name), color = addon:GetClassColor(v.class)}
				break
			end
		end
	end
	return names
end

---
-- @return table [mapID-difficultyID] = "instance_name"
function LootHistory:GetAllRegisteredInstances()
	local raids = {}
	lootDB = addon:GetHistoryDB()
	for _, a in pairs(lootDB) do
		for _,v in ipairs(a) do
			if v.mapID and v.instance and v.difficultyID then
				raids[v.mapID .. "-" .. v.difficultyID] = v.instance
			end
		end
	end
	table.sort(raids)
	return raids
end

function LootHistory:DeleteAllEntriesByName(name)
	addon.Log:D("Deleting all loot history entries for ", name)
	if not lootDB[name] then return addon.Log:E(name, "wasn't registered in the lootDB!") end
	addon:Print(format(L["Succesfully deleted %d entries from %s"], #lootDB[name], name))
	lootDB[name] = nil
	if self.frame and self.frame:IsVisible() then -- Only update if we're viewing it
		self:BuildData()
		self.frame.st:SortData()
	end
end

function LootHistory:DeleteAllEntriesByMapIDDifficulty(mapID, diff)
	addon.Log:D("Deleting all loot history entires with mapID", mapID, "and difficultyID", diff)
	local item
	local sum = 0
	for _, items in pairs(lootDB) do
		for i = #items, 1, -1 do
			item = items[i]
			if item and item.mapID and item.difficultyID then
				if item.mapID == tonumber(mapID) and item.difficultyID == tonumber(diff) then
					table.remove(items, i)
					sum = sum + 1
				end
			end
		end
	end
	addon:Print(format(L["Succesfully deleted %d entries"], sum))
	if self.frame and self.frame:IsVisible() then
		self:BuildData()
		self.frame.st:SortData()
	end
end

function LootHistory:DeleteEntriesOlderThanEpoch(epoch)
	addon.Log:D("DeleteEntriesOlderThanEpoch", epoch)
	local removal = {} -- Create a list of the entries to be removed
	for name,a in pairs(lootDB) do
		removal[name] = {}
		local num = 1
		for i,v in ipairs(a) do
			local index = v.date..v.time
			if not epochDates[index] then
				local added = false
				-- Prefer using the epoch timestamp from the id
				if v.id then
					local id = strsplit(v.id, "-")
					if id and id ~= "" then
						id = tonumber(id)
						epochDates[index] = id
						added = true
					end
				end
				-- Fallback to recreating the time string from date/time.
				if not added then
					self:AddEpochDate(v.date, v.time)
				end
			end
			if epochDates[index] < epoch then
				removal[name][num] = i
				num = num + 1
			end
		end
	end
	-- Remove the entries in reverse order for a small speed upgrade
	local sum = 0
	for name, v in pairs(removal) do
		for i = #v, 1, -1 do
			tremove(lootDB[name], i)
		end
		sum = sum + #v
	end
	addon:Print(format(L["Succesfully deleted %d entries"], sum))
	if self.frame and self.frame:IsVisible() then
		self:BuildData()
		self.frame.st:SortData()
	end
end

local function filterNameData (name, date)
	local nameAndDate = true -- default to show everything
	if selectedName and selectedDate then
		nameAndDate = name == selectedName and date == selectedDate
	elseif selectedName then
		nameAndDate = name == selectedName
	elseif selectedDate then
		nameAndDate = date == selectedDate
	end
	return nameAndDate
end

local function filterResponse (response, isAwardReason)
	local responseFilter
	if response == "AUTOPASS" or response == "PASS" or type(response) == "number" and not isAwardReason then
		responseFilter = db.modules["RCLootHistory"].filters[response]
	else -- Filter out the status texts
		responseFilter = db.modules["RCLootHistory"].filters["STATUS"]
	end
	return responseFilter
end

local function classFilter (class)
	local classFilter = true -- Don't filter classes if none are selected
	if useClassFilters then
		local classID = addon.classTagNameToID[class]
		classFilter = db.modules["RCLootHistory"].filters.class[classID]
	end
	return classFilter
end

-- Filter function for Lib-ScrollingTable
function LootHistory.FilterFunc(table, row)
	-- Name and Date filters:
	local nameAndDate = filterNameData(row.name, row.date)

	-- Response filters:
	if not db.modules["RCLootHistory"].filters then return nameAndDate end -- db hasn't been initialized
	local responseFilter = filterResponse(row.response, row.isAwardReason)

	-- Class Filters:
	local classFilter = classFilter(row.class)

	return nameAndDate and responseFilter and classFilter -- Either one can filter the entry
end

function LootHistory:FilterForLootDB (winner, entry)
	-- Name and Date filters:
	local nameAndDate = filterNameData(winner, entry.date)

	-- Response filters:
	if not db.modules["RCLootHistory"].filters then return nameAndDate end -- db hasn't been initialized
	local responseFilter = filterResponse(entry.responseID, entry.isAwardReason)

	-- Class Filters:
	local classFilter = classFilter(entry.class)

	return nameAndDate and responseFilter and classFilter -- Either one can filter the entry
end

function LootHistory:GetFilteredDB ()
	local filtered = {}
	for name, items in pairs(lootDB) do
		for _, entry in pairs(items) do
			if self:FilterForLootDB(name, entry) then
				if not filtered[name] then filtered[name] = {} end
				tinsert(filtered[name], entry)
			end
		end
	end
	return filtered
end

-- for date scrolling table
function LootHistory.SetCellDate(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	frame.text:SetText(LootHistory:GetLocalizedDate(data[realrow][column]))
	if table.fSelect then
		if table.selected == realrow then
			table:SetHighLightColor(rowFrame, table:GetDefaultHighlight());
		else
			table:SetHighLightColor(rowFrame, table:GetDefaultHighlightBlank());
		end
	end
end

function LootHistory.SetCellGear(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local gear = data[realrow].cols[column].args[1] -- gear1 or gear2
	if gear then
		--local texture = select(10, GetItemInfo(gear))
		local texture = select(5, GetItemInfoInstant(gear))
		frame:SetNormalTexture(texture)
		frame:SetScript("OnEnter", function() addon:CreateHypertip(gear) end)
		frame:SetScript("OnLeave", function() addon:HideTooltip() end)
		frame:SetScript("OnClick", function()
			if IsModifiedClick() then
			   HandleModifiedItemClick(gear);
	      end
		end)
		frame:Show()
	else
		frame:Hide()
	end
end

function LootHistory.SetCellResponse(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local args = data[realrow].cols[column].args
	frame.text:SetText(args.response)

	if args.color and type(args.color) == "table" then -- Never version saves the color with the entry
		frame.text:SetTextColor(unpack(args.color))
	elseif args.responseID and args.responseID > 0 then -- try to recreate color from ID
		frame.text:SetTextColor(unpack(addon:GetResponse("default", args.responseID).color))
	else -- default to white
		frame.text:SetTextColor(1,1,1,1)
	end
end

function LootHistory.SetCellDelete(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	if not frame.created then
		frame:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		frame:SetScript("OnEnter", function()
			addon:CreateTooltip(L["Double click to delete this entry."])
		end)
		frame:SetScript("OnLeave", function() addon:HideTooltip() end)
		frame.created = true
	end
	frame:SetScript("OnClick", function()
		local name, num = data[realrow].name, data[realrow].num
		if frame.lastClick and GetTime() - frame.lastClick <= 0.5 then
			frame.lastClick = nil
			-- Do deleting
			addon.Log:D("Deleting:", name, lootDB[name][num].lootWon)
			tremove(lootDB[name], num)
			tremove(data, realrow)

			for _, v in pairs(data) do -- Update data[realrow].num for other rows, they are changed !!!
				if v.name == name then
					if v.num >= num then
						v.num = v.num - 1
					end
				end
			end

			table:SortData()
			if #lootDB[name] == 0 then -- last entry deleted
				addon.Log:D("Last Entry deleted, deleting name: ", name)
				lootDB[name] = nil
			end
		else
			frame.lastClick = GetTime()
		end
	end)
end

function LootHistory:AddEpochDate(date, tim)
	local d, m, y = strsplit("/", date, 3)
	local h, min, s = strsplit(":", tim, 3)
	epochDates[date..tim] = self:DateTimeToSeconds(d,m,y,h,min,s)
end

function LootHistory:DateTimeToSeconds (d,m,y,h,min,s)
	return time({year = "20"..y or 10, month = m or 1, day = d or 1, hour = h or 0, min = min or 0, sec = s or 0})
end

function LootHistory.DateTimeSort(table, rowa, rowb, sortbycol)
	local cella, cellb = table:GetCell(rowa, sortbycol), table:GetCell(rowb, sortbycol);
	local indexa, indexb = cella.args.date..cella.args.time, cellb.args.date..cellb.args.time
	if not (epochDates[indexa] and epochDates[indexb]) then
		LootHistory:AddEpochDate(cella.args.date, cella.args.time)
		LootHistory:AddEpochDate(cellb.args.date, cellb.args.time)
	end
	local column = table.cols[sortbycol]
	local a, b = epochDates[indexa], epochDates[indexb]
	if a == b then
		if column.sortnext then
			local nextcol = table.cols[column.sortnext];
			if nextcol and not(nextcol.sort) then
				if nextcol.comparesort then
					return nextcol.comparesort(table, rowa, rowb, column.sortnext);
				else
					return table:CompareSort(rowa, rowb, column.sortnext);
				end
			end
		end
		return false
	else
		local direction = table.cols[sortbycol].sort or table.cols[sortbycol].defaultsort or 1
		if direction == 1 then
			return a < b
		else
			return a > b
		end
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
	local direction = column.sort or column.defaultsort or 1;
	if direction == 1 then
		return aTime < bTime;
	else
		return aTime > bTime;
	end
end

function LootHistory.ResponseSort(table, rowa, rowb, sortbycol)
	local column = table.cols[sortbycol]
	rowa, rowb = table:GetRow(rowa), table:GetRow(rowb);
	local a,b
	local aID, bID = lootDB[rowa.name][rowa.num].responseID, lootDB[rowb.name][rowb.num].responseID

	-- NOTE: I'm pretty sure it can only be an awardReason when responseID is nil or 0
	if aID and aID ~= 0 then
		if lootDB[rowa.name][rowa.num].isAwardReason then
			a = db.awardReasons[aID] and db.awardReasons[aID].sort or 500
		else
			a = addon:GetResponse(nil, aID).sort or 500
		end
	else
		-- 500 will be below award reasons and just above status texts
		a = 500
	end

	if bID and bID ~= 0 then
		if lootDB[rowb.name][rowb.num].isAwardReason then
			b = db.awardReasons[bID] and db.awardReasons[bID].sort or 500
		else
			b = addon:GetResponse(nil, bID).sort or 500
		end

	else
		b = 500
	end
	if a == b then
			if column.sortnext then
				local nextcol = table.cols[column.sortnext];
				if nextcol and not(nextcol.sort) then
					if nextcol.comparesort then
						return nextcol.comparesort(table, rowa, rowb, column.sortnext);
					else
						return table:CompareSort(rowa, rowb, column.sortnext);
					end
				end
			end
			return false
		else
			local direction = table.cols[sortbycol].sort or table.cols[sortbycol].defaultsort or 1
			if direction == 1 then
				return a < b
			else
				return a > b
			end
		end
end

function LootHistory.ItemSort(table, rowa, rowb, sortbycol)
	local column = table.cols[sortbycol]
	rowa, rowb = table:GetRow(rowa), table:GetRow(rowb);
	local a,b = lootDB[rowa.name][rowa.num].lootWon, lootDB[rowb.name][rowb.num].lootWon
	a = addon.Utils:GetItemNameFromLink(a)
	b = addon.Utils:GetItemNameFromLink(b)
	if a == b then
		if column.sortnext then
			local nextcol = table.cols[column.sortnext];
			if nextcol and not(nextcol.sort) then
				if nextcol.comparesort then
					return nextcol.comparesort(table, rowa, rowb, column.sortnext);
				else
					return table:CompareSort(rowa, rowb, column.sortnext);
				end
			end
		end
		return false
	else
		local direction = table.cols[sortbycol].sort or table.cols[sortbycol].defaultsort or 1
		if direction == 1 then
			return a < b
		else
			return a > b
		end
	end
end

function LootHistory:EscapeItemLink(link)
	return gsub(link, "\124", "\124\124")
end

function LootHistory:ExportHistory()
	--debugprofilestart()
	local export = self.exports[self.exportSelection].func(self)
	--addon.Log:D("Export time:", debugprofilestop(), "ms")
	if export and export ~= "" then -- do something
		--debugprofilestart()
		if export:len() < 40000 then
			self.frame.exportFrame:Show()
			self.frame.exportFrame.edit:SetCallback("OnTextChanged", function(self)
				self:SetText(export)
			end)
			self.frame.exportFrame.edit:SetText(export)
			self.frame.exportFrame.edit:SetFocus()
			self.frame.exportFrame.edit:HighlightText()
		else -- Use hugeExportFrame(Single line editBox) for large export to avoid freezing the game.
			self.frame.hugeExportFrame:Show()
			self.frame.hugeExportFrame.edit:SetCallback("OnTextChanged", function(self)
				self:SetText(export)
			end)
			self.frame.hugeExportFrame.edit:SetText(export)
			self.frame.hugeExportFrame.edit:SetFocus()
			self.frame.hugeExportFrame.edit:HighlightText()
		end
		--addonLog:D("Display time:", debugprofilestop(), "ms")
	end
end

function LootHistory:DetermineImportType (import)
   addon.Log:D("His:DetermineImportType")
   -- Check csv
   if import:sub(1, 6) == "player" then
      -- Check for Sheet Copy
      if import:sub(7,7) == "\t" then
         if import:find("\tboss\tgear1") then -- Standard tsv export - not supported
            return "tsv"
         end
         import = import:gsub("\t", ",")
         if import:find("boss,difficultyID,mapID,") then
            return "tsv-csv" -- Copied from Google Sheet
         end
         return "Unknown"
      elseif import:sub(7,7) == "," then
         return "csv"
      end
      return "Unknown"
   elseif import:sub(1, 2) == "^1" then
      return "playerexport"
   else
      return
   end
end

function LootHistory:ImportHistory(import)
	addon.Log:D("Initiating import")
	if type(import) ~= "string" then
      addon:Print(L["import_malformed"])
      addon.Log:W("Malformed string")
      return
   end
	-- WoW seems to translate tabs (\t) into four spaces. Check for that.
	import = import:gsub("    ", "\t")
	local type = self:DetermineImportType(import)

	if not type or type == "Unknown" then
		addon:Print(L["import_not_supported"])
		addon:Print(L["Accepted imports: 'Player Export' and 'CSV'"])
		return
	elseif type == "csv" then
		return self:ImportCSV(import)
	elseif type == "tsv-csv" then
		return self:ImportTSV_CSV(import)
	elseif type == "playerexport" then
		return self:ImportPlayerExport(import)
	else -- Should not happend
		error("Unknown import type")
	end
end

-- REVIEW: Needs updating
function LootHistory:ImportPlayerExport (import)
	lootDB = addon:GetHistoryDB()
	-- Start with validating the import:
	if type(import) ~= "string" then addon:Print("The imported text wasn't a string"); return addon.Log:D("No string") end
	import = gsub(import, "\124\124", "\124") -- De escape itemslinks
	local test, import = self:Deserialize(import)
	if not test then addon:Print("Deserialization failed - maybe wrong import type?"); return addon.Log:D("Deserialization failed") end
	addon.Log:D("Validation completed", #lootDB == 0, #lootDB)
	-- Now import should be a copy of the orignal exporter's lootDB, so insert any changes
	-- Start by seeing if we even have a lootDB
	--if #lootDB == 0 then lootDB = import; return end
	local number = 0
	for name, data in pairs(import) do
		if lootDB[name] then -- We've registered the name, so check all the awards
			for _, v in pairs(data) do
				local found = false
				for _, d in pairs(lootDB[name]) do -- REVIEW This is currently ~O(#lootDB[name]^2). Could probably be improved.
					-- Check if the time matches. If it does, we already have the data and can skip to the next
					if d.time == v.time then found = true; break end
				end
				if not found then -- add it
					tinsert(lootDB[name], v)
					number = number + 1
				end
			end
		else -- It's a new name, so add everything and move on to the next
			lootDB[name] = data
			number = number + #data
		end
	end
	addon.lootDB.factionrealm = lootDB -- save it
	addon:Print(format(L["Successfully imported 'number' entries."], number))
	addon.Log:D("Import successful")
	if self.frame and self.frame:IsVisible() then self:BuildData(); self:Show() end -- Only rebuild data if we're showing
end

function LootHistory:GetWowheadLinkFromItemLink(link)
    local color, itemType, itemID, enchantID, gemID1, gemID2, gemID3, gemID4, suffixID, uniqueID, linkLevel, specializationID, upgradeTypeID, upgradeID, instanceDifficultyID, numBonuses, bonusIDs = addon:DecodeItemLink(link) --luacheck: no unused

    local itemurl = self.wowheadBaseUrl..itemID

	 -- It seems bonus id 1487 (and basically any other id that's -5 below Wowheads first ilvl upgrade doesn't work)
	 -- Neither does Warforged items it seems
	 -- 19/9-17: It seems bonusIDs 3528 and 3336 fucks up Wowhead - however there's no difference with or without those ids ingame (?!).
    if numBonuses > 0 then
        itemurl = itemurl.."&bonus="
        for i, b in pairs(bonusIDs) do
			  if b ~= 3528 and b ~= 3336 then
	            itemurl = itemurl..b
	            if i < numBonuses then
	                itemurl = itemurl..":"
	            end
				end
        end
    end

    return itemurl
end

---------------------------------------------------
-- Visuals.
-- @section Visuals.
---------------------------------------------------
local function IsFiltering()
	for _,v in pairs(db.modules["RCLootHistory"].filters) do
		if not v then return true end
	end
	for _,v in pairs(db.modules["RCLootHistory"].filters.class) do
		if v then return true end
	end
end

function LootHistory:Update()
	self.frame.st:SortData()
	if IsFiltering() then
		self.frame.filter.Text:SetTextColor(0.86,0.5,0.22) -- #db8238
	else
		self.frame.filter.Text:SetTextColor(_G.NORMAL_FONT_COLOR:GetRGB()) --#ffd100
	end
end

function LootHistory:GetFrame()
	if self.frame then return self.frame end
	local f = addon.UI:NewNamed("Frame", UIParent, "DefaultRCLootHistoryFrame", L["RCLootCouncil Loot History"], 250, 480)
	local st = LibStub("ScrollingTable"):CreateST(self.scrollCols, NUM_ROWS, ROW_HEIGHT, { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5 }, f.content)
	st.frame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
	st:SetFilter(self.FilterFunc)
	st:EnableSelection(true)
	st:RegisterEvents({
		["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
			if row or realrow then
				if button == "LeftButton" then
					self:UpdateMoreInfo(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
				elseif button == "RightButton" then
					rightClickMenu.datatable = data[realrow]
					MSA_ToggleDropDownMenu(1,nil,rightClickMenu,cellFrame,0,0)
				end
			end
			return false
		end
	})
	f.st = st

	--Date selection
	f.date = LibStub("ScrollingTable"):CreateST({{name = L["Date"], width = 70, comparesort = self.DateSort, sort = 2, DoCellUpdate = self.SetCellDate}}, 5, ROW_HEIGHT, { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5 }, f.content)
	f.date.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -20)
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
	f.name = LibStub("ScrollingTable"):CreateST({{name = "", width = ROW_HEIGHT},{name = _G.NAME, width = 100, sort = 1}}, 5, ROW_HEIGHT, { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5 }, f.content)
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
	local b1 = addon:CreateButton(_G.CLOSE, f.content)
	b1:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -100)
	b1:SetScript("OnClick", function() self:Disable() end)
	f.closeBtn = b1

	-- More info button
	local b2 = CreateFrame("Button", nil, f.content, "UIPanelButtonTemplate")
	b2:SetSize(25,25)
	b2:SetPoint("BOTTOMRIGHT", b1, "TOPRIGHT", 0, 10)
	b2:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	b2:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	b2:SetScript("OnClick", function(button)
		moreInfo = not moreInfo
		self.frame.st:ClearSelection()
		self:UpdateMoreInfo()
		if moreInfo then -- show the more info frame
			button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
			button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
			self.moreInfo:Show()
		else -- hide it
			button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
			self.moreInfo:Hide()
		end
		addon.Log:D("moreInfo =",moreInfo)
	end)
	b2:SetScript("OnEnter", function() addon:CreateTooltip(L["Click to expand/collapse more info"]) end)
	b2:SetScript("OnLeave", function() addon:HideTooltip() end)
	f.moreInfoBtn = b2

	f.content:SetScript("OnSizeChanged", function()
		self.moreInfo:SetScale(f:GetScale() * 0.6)
	end)

	-- Export
	local b3 = addon:CreateButton(L["Export"], f.content)
	b3:SetPoint("RIGHT", b1, "LEFT", -10, 0)
	b3:SetScript("OnClick", function() self:ExportHistory() end)
	f.exportBtn = b3

	-- Import
	local b5 = addon:CreateButton("Import", f.content)
	b5:SetPoint("RIGHT", b3, "LEFT", -10, 0)
	b5:SetScript("OnClick", function()
		self.frame.importFrame:Show()
		self.frame.importFrame.edit:SetFocus()
	end)
	f.importBtn = b5

	-- Filter
	local b4 = addon:CreateButton(_G.FILTER, f.content)
	b4:SetPoint("RIGHT", f.importBtn, "LEFT", -10, 0)
	b4:SetScript("OnClick", function(self) MSA_ToggleDropDownMenu(1, nil, filterMenu, self, 0, 0) end )
	f.filter = b4
	MSA_DropDownMenu_Initialize(b4, self.FilterMenu)
	f.filter:SetSize(125,25) -- Needs extra convincing to stay at 25px height

	-- Export selection (AceGUI-3.0)
	local sel = AG:Create("Dropdown")
	sel:SetPoint("BOTTOMLEFT", f.importBtn, "TOPLEFT", 0, 10)
	sel:SetPoint("TOPRIGHT", b2, "TOPLEFT", -10, 0)
	local values = {}
	for k, v in pairs(self.exports) do
		values[k] = v.name
	end
	sel:SetList(values)
	sel:SetValue(self.exportSelection)
	sel:SetText(self.exports[self.exportSelection].name)
	sel:SetCallback("OnValueChanged", function(_,_, key)
		self.exportSelection = key
	end)
	sel:SetCallback("OnEnter", function()
		addon:CreateTooltip(self.exports[self.exportSelection].tip)
	end)
	sel:SetCallback("OnLeave", function()
		addon:HideTooltip()
	end)
	sel:SetParent(f)
	sel.frame:Show()
	f.moreInfoDropdown = sel

	-- Clear selection
	local b6 = addon:CreateButton(L["Clear Selection"], f.content)
	b6:SetPoint("RIGHT", sel.frame, "LEFT", -10, 0)
	b6:SetScript("OnClick", function()
		selectedDate, selectedName = nil, nil
		self.frame.date:ClearSelection()
		self.frame.name:ClearSelection()
		self:Update()
	end)
	b6:SetWidth(125)
	f.clearSelectionBtn = b6

	-- Export frame
	local exp = AG:Create("Window")
	exp:SetLayout("Flow")
	exp:SetTitle("RCLootCouncil "..L["Export"])
	exp:SetWidth(700)
	exp:SetHeight(360)

	local edit = AG:Create("MultiLineEditBox")
	edit:SetNumLines(20)
	edit:SetFullWidth(true)
	edit:SetLabel(L["Export"])
	edit:SetFullHeight(true)
	exp:AddChild(edit)
	exp:Hide()
	f.exportFrame = exp
	f.exportFrame.edit = edit

	-- Frame for huge export. Use single line editbox to avoid freezing.
	local hugeExp = AG:Create("Window")
	hugeExp:SetLayout("Flow")
	hugeExp:SetTitle("RCLootCouncil "..L["Export"])
	hugeExp:SetWidth(700)
	hugeExp:SetHeight(100)

	edit = AG:Create("EditBox")
	edit:SetFullWidth(true)
	edit:SetLabel(L["huge_export_desc"])
	edit:SetMaxLetters(0)
	hugeExp:AddChild(edit)
	hugeExp:Hide()
	f.hugeExportFrame = hugeExp
	f.hugeExportFrame.edit = edit

	-- Import frame
	local imp = AG:Create("Window")
	imp:SetLayout("Flow")
	imp:SetTitle("RCLootCouncil Import")
	imp:SetWidth(700)
	imp:SetHeight(360)

	edit = AG:Create("MultiLineEditBox")
	edit:SetNumLines(20)
	edit:SetFullWidth(true)
	edit:SetLabel(L["import_desc"])
	edit:SetFullHeight(true)

	-- Credit to WeakAura2
	-- Import editbox only shows first 2500 bytes to avoid freezing the game.
	-- Use 'OnChar' event to store other characters in a text buffer
	local textBuffer, i, lastPaste = {}, 0, 0
	local pasted = ""
	edit.editBox:SetScript("OnShow", function(self)
		self:SetText("")
		pasted = ""
	end)
	local function clearBuffer(self)
		self:SetScript('OnUpdate', nil)
		pasted = strtrim(table.concat(textBuffer))
		edit.editBox:ClearFocus()
	end
	edit.editBox:SetScript('OnChar', function(self, c)
		if lastPaste ~= GetTime() then
			textBuffer, i, lastPaste = {}, 0, GetTime()
			self:SetScript('OnUpdate', clearBuffer)
		end
		i = i + 1
		textBuffer[i] = c
	end)
	edit.editBox:SetMaxBytes(2500)
	edit.editBox:SetScript("OnMouseUp", nil);

	edit:SetCallback("OnEnterPressed", function()
		self:ImportHistory(pasted)
		imp:Hide()
	end)

	local label = AG:Create("Label")
	label:SetFullWidth(true)
	label:SetText(L["Accepted imports: 'Player Export' and 'CSV'"])
	imp:AddChild(label)
	imp:AddChild(edit)

	imp:Hide()
	f.importFrame = imp
	f.importFrame.edit = edit

	-- Set a proper width
	f:SetWidth(st.frame:GetWidth() + 20)
	return f;
end

--- Returns a table of all the winners of an item.
-- @param item The item to check for.
-- @return A table which values are a numeric table of numLoot, name, class
function LootHistory:GetWinnersOfItem (item)
	local winners = {}
	local count = 1
	local ret = {}
	for name, items in pairs(lootDB) do
		for _,entry in pairs(items) do
			if addon:ItemIsItem(entry.lootWon, item) then
				if not winners[name] then
					winners[name] = count
					ret[count] = {1, name, entry.class}
					count = count + 1
				else
					ret[winners[name]][1] = ret[winners[name]][1] + 1
				end
			end
		end
	end
	return ret
end

function LootHistory:UpdateMoreInfo(rowFrame, cellFrame, dat, cols, row, realrow, column, tabel, button, ...)
	if not dat then return end
	if not moreInfoData then return addon.Log:D("No moreInfoData in UpdateMoreInfo()") end
	local tip = self.moreInfo -- shortening
	tip:SetOwner(self.frame, "ANCHOR_RIGHT")
	local row = dat[realrow]
	local color = addon:GetClassColor(row.class)
	local data = lootDB[row.name][row.num]
	tip:AddLine(addon.Ambiguate(row.name), color.r, color.g, color.b)
	tip:AddLine("")
	tip:AddDoubleLine(L["Time"]..":", (data.time or _G.UNKNOWN) .." ".. row.date or _G.UNKNOWN, 1,1,1, 1,1,1)
	tip:AddDoubleLine(L["Loot won:"], data.lootWon or _G.UNKNOWN, 1,1,1, 1,1,1)
	if data.itemReplaced1 then
		tip:AddDoubleLine(L["Item(s) replaced:"], data.itemReplaced1, 1,1,1)
		if data.itemReplaced2 then
			tip:AddDoubleLine(" ", data.itemReplaced2)
		end
	end
	tip:AddDoubleLine(L["Dropped by:"], data.boss or _G.UNKNOWN, 1,1,1, 0.862745, 0.0784314, 0.235294)
	tip:AddDoubleLine(_G.FROM, data.instance or _G.UNKNOWN, 1,1,1, 0.823529, 0.411765, 0.117647)
	tip:AddDoubleLine(L["Original Owner"], data.owner, 1,1,1, 1,1,1)
	tip:AddDoubleLine(L["Votes"]..":", data.votes or _G.UNKNOWN, 1,1,1, 1,1,1)
	if data.note then
		tip:AddLine(" ")
		tip:AddDoubleLine(_G.LABEL_NOTE..":", data.note, 1,1,1, 1,1,1)
	end
	tip:AddLine(" ")
	tip:AddLine(L["Tokens received"])
	-- Add tier tokens
	for _, v in pairs(moreInfoData[row.name].totals.tokens) do
		if v.mapID and v.difficultyID and tierLookUpTable[v.mapID] then
			tip:AddDoubleLine(tierLookUpTable[v.mapID].." "..difficultyLookupTable[v.difficultyID]..":", v.num, 1,1,1, 1,1,1)
		end
	end
	tip:AddLine(" ")
	tip:AddLine(L["Total awards"])
	table.sort(moreInfoData[row.name].totals.responses, function(a,b) return type(a[4]) == "number" and type(b[4]) == "number" and a[4] < b[4] or false end)
	for _, v in pairs(moreInfoData[row.name].totals.responses) do
		local r,g,b
		if v[3] then r,g,b = unpack(v[3],1,3) end
		tip:AddDoubleLine(v[1], v[2], r or 1, g or 1, b or 1, 1,1,1)
	end
	tip:AddDoubleLine(L["Number of raids received loot from:"], moreInfoData[row.name].totals.raids.num, 1,1,1, 1,1,1)
	tip:AddDoubleLine(L["Total items won:"], moreInfoData[row.name].totals.total, 1,1,1, 0,1,0)
	tip:AddLine(" ")

	-- Other recipient of the item
	local winners = self:GetWinnersOfItem(data.lootWon)
	table.sort(winners, function (a,b)
		return a[2] < b[2]
	end)
	tip:AddLine(format(L["lootHistory_moreInfo_winnersOfItem"], data.lootWon))
	for _, data in ipairs(winners) do
		local c = addon:GetClassColor(data[3])
		tip:AddDoubleLine(addon.Ambiguate(data[2]), data[1], c.r,c.g,c.b, 1,1,1)
	end

	-- Debug stuff
	if addon.debug then
		tip:AddLine("\nDebug:")
		tip:AddDoubleLine("ID:", tostring(data.id), 1,1,1, 1,1,1)
		tip:AddDoubleLine("ResponseID", tostring(data.responseID), 1,1,1, 1,1,1)
		tip:AddDoubleLine("Response:", data.response, 1,1,1, 1,1,1)
		tip:AddDoubleLine("isAwardReason:", tostring(data.isAwardReason), 1,1,1, 1,1,1)
		local r,g,b
		if data.color then r,g,b = unpack(data.color,1,3) end
		tip:AddDoubleLine("color:", data.color and (r..", "..g..", "..b) or "none", 1,1,1, r,g,b)
		tip:AddDoubleLine("DataIndex:", row.num, 1,1,1, 1,1,1)
		tip:AddDoubleLine("difficultyID:", data.difficultyID, 1,1,1, 1,1,1)
		tip:AddDoubleLine("mapID", data.mapID, 1,1,1, 1,1,1)
		tip:AddDoubleLine("groupSize", data.groupSize, 1,1,1, 1,1,1)
		tip:AddDoubleLine("tierToken", data.tierToken, 1,1,1, 1,1,1)
		tip:AddDoubleLine("tokenRoll", tostring(data.tokenRoll), 1,1,1, 1,1,1)
		tip:AddDoubleLine("relicRoll", tostring(data.relicRoll), 1,1,1, 1,1,1)
		tip:AddLine(" ")
		tip:AddDoubleLine("Total LootDB entries:", #self.frame.rows, 1,1,1, 0,0,1)
	end
	tip:SetScale(self.frame:GetScale() * 0.65)
	if moreInfo then
		tip:Show()
	else
		tip:Hide()
	end
	tip:SetAnchorType("ANCHOR_RIGHT", 0, -tip:GetHeight())
end



---------------------------------------------------
-- Dropdowns.
-- @section Dropdowns.
---------------------------------------------------
function LootHistory.FilterMenu(menu, level)
	local info = MSA_DropDownMenu_CreateInfo()
	local value = _G.MSA_DROPDOWNMENU_MENU_VALUE

	if level == 1 then
		-- Build the data table:
		local data = {["STATUS"] = true, ["PASS"] = true, ["AUTOPASS"] = true}
		for i = 1, addon:GetNumButtons() do
			data[i] = i
		end
		if not db.modules["RCLootHistory"].filters then -- Create the db entry
			addon.Log:D("Created LootHistory filters")
			db.modules["RCLootHistory"].filters = {
				class = {}
			}
		end


		info.text = _G.FILTER
		info.isTitle = true
		info.notCheckable = true
		info.disabled = true
		MSA_DropDownMenu_AddButton(info, level)
		info = MSA_DropDownMenu_CreateInfo()

		info.text = _G.CLASS
		info.isTitle = false
		info.hasArrow = true
		info.notCheckable = true
		info.disabled = false
		info.value = "CLASS"
		MSA_DropDownMenu_AddButton(info, level)
		info = MSA_DropDownMenu_CreateInfo()

		info.text = L["Responses"]
		info.isTitle = true
		info.notCheckable = true
		info.disabled = true
		MSA_DropDownMenu_AddButton(info, level)
		info = MSA_DropDownMenu_CreateInfo()


		for k in ipairs(data) do -- Make sure normal responses are on top
			info.text = addon:GetResponse("default",k).text
			info.colorCode = "|cff"..addon.Utils:RGBToHex(addon:GetResponseColor(nil, k))
			info.func = function()
				addon.Log:D("Update Filter")
				db.modules["RCLootHistory"].filters[k] = not db.modules["RCLootHistory"].filters[k]
				LootHistory:Update()
			end
			info.checked = db.modules["RCLootHistory"].filters[k]
			MSA_DropDownMenu_AddButton(info, level)
		end
		for k in pairs(data) do -- A bit redundency, but it makes sure these "specials" comes last
			if type(k) == "string" then
				if k == "STATUS" then
					info.text = L["Status texts"]
					info.colorCode = "|cffde34e2" -- purpleish
				else
					info.text = addon:GetResponse("default",k).text
					info.colorCode = "|cff"..addon.Utils:RGBToHex(addon:GetResponseColor(nil, k))
				end
				info.func = function()
					addon.Log:D("Update Filter")
					db.modules["RCLootHistory"].filters[k] = not db.modules["RCLootHistory"].filters[k]
					LootHistory:Update()
				end
				info.checked = db.modules["RCLootHistory"].filters[k]
				MSA_DropDownMenu_AddButton(info, level)
			end
		end
	elseif level == 2 then
		if value == "CLASS" then
			for id, name in pairs(addon.classIDToDisplayName) do
				local col = addon:GetClassColor(addon.classIDToFileName[id])
				info.text = name
				info.colorCode = "|cff"..addon.Utils:RGBToHex(col.r,col.g,col.b)
				info.func = function()
					addon.Log:D("Update class filter")
					db.modules["RCLootHistory"].filters.class[id] = not db.modules["RCLootHistory"].filters.class[id]
					for _,v in pairs(db.modules["RCLootHistory"].filters.class) do
						if v then
							useClassFilters = true
							break
						end
					end
					LootHistory:Update()
				end
				info.checked = db.modules["RCLootHistory"].filters.class[id]
				MSA_DropDownMenu_AddButton(info, level)
				info = MSA_DropDownMenu_CreateInfo()
			end

			-- Create constants
			info.text = "Deselect All"
			info.notCheckable = true
			info.keepShownOnClick = true
			info.func = function()
				for k in pairs(db.modules["RCLootHistory"].filters.class) do
					db.modules["RCLootHistory"].filters.class[k] = false
					MSA_DropDownMenu_SetSelectedName(filterMenu, addon.classIDToDisplayName[k], false)
					useClassFilters = false
					LootHistory:Update()
				end
			end
			MSA_DropDownMenu_AddButton(info, level)
		end
	end
end


do
--- Entries placed in the rightclick menu.
-- See the example in votingFrame.lua for a detailed explaination.
-- Functions gets the row data as a parameter.
-- See LootHistory:BuildData() for the contents of a row (self.frame.rows[row])
LootHistory.rightClickEntries = {
	{ -- Level 1
		{ -- 1 Title
			text = L["Edit Entry"],
			isTitle = true,
			notCheckable = true,
			disabled = true,
		},
		{ -- 2 Name
			text = _G.NAME,
			value = "EDIT_NAME",
			notCheckable = true,
			hasArrow = true,
		},
		{ -- 3 Response
			text = L["Response"],
			value = "EDIT_RESPONSE",
			notCheckable = true,
			hasArrow = true,
		},
	},
	{ -- Level 2
		{ -- 1 EDIT_NAME
			special = "EDIT_NAME",
		},
		{ -- 2 EDIT_RESPONSE
			special = "EDIT_RESPONSE",
		},
		{ -- 3 Award Reasons ...
			text = L["Award Reasons"] .. " ...",
			onValue = "EDIT_RESPONSE",
			value = "AWARD_REASON",
			hasArrow = true,
			notCheckable = true,
		},
	},
	{ -- Level 3
		{ -- 1 AWARD_REASON
			special = "AWARD_REASON",
		}
	},
}


-- NOTE Changing e.g. a tier token item's response to a non-tier token response is possible display wise,
-- but it will retain it's tier token tag, and vice versa. Can't decide whether it's a feature or bug.
function LootHistory.RightClickMenu(menu, level)
	local info
	local data = menu.datatable

	local value = _G.MSA_DROPDOWNMENU_MENU_VALUE
	if not LootHistory.rightClickEntries[level] then return end
	for i, entry in ipairs(LootHistory.rightClickEntries[level]) do
		info = MSA_DropDownMenu_CreateInfo()
		if not entry.special then
			if not entry.onValue or entry.onValue == value then
				if not (entry.hidden and type(entry.hidden) == "function" and entry.hidden(data.name, data)) or not entry.hidden then
					for name, val in pairs(entry) do
						if name == "func" then
							info[name] = function() return val(data.name, data) end -- This needs to be set as a func, but fed with our params
						elseif type(val) == "function" then
							info[name] = val(data.name, data) -- This needs to be evaluated
						else
							info[name] = val
						end
					end
					MSA_DropDownMenu_AddButton(info, level)
				end
			end

		elseif value == "EDIT_NAME" and entry.special == value then

			if not LootHistory.frame then return end -- This could be nil if LootHistory frame closes before the rightclick menu.
			local sorttable = {unpack(LootHistory.frame.name.sorttable)} -- Copy the name table
			-- 1. If both in the raid , sort by alphabet, ascending
			-- 2. If neither in the raid, sort by time of last loot received, ascending
			-- 3. People in the raid are sorted after people not in the raid.
			table.sort(sorttable, function(a, b)
				local namea, nameb = LootHistory.frame.name.data[a][2].name, LootHistory.frame.name.data[b][2].name
				local isInRaida, isInRaidb = UnitInRaid(Ambiguate(namea, "short")), UnitInRaid(Ambiguate(nameb, "short"))
				if isInRaida ~= isInRaidb then
					return isInRaidb
				elseif isInRaidb then -- Both in the raid
					return namea < nameb
				else -- Neither in the raid
					local epocha, epochb = 0, 0
					if next(lootDB[namea]) then
						local datea = lootDB[namea][#lootDB[namea]].date
						local timea = lootDB[namea][#lootDB[namea]].time
						local d, m, y = strsplit("/", datea, 3)
						local h, min, s = strsplit(":", timea, 3)
						epocha = time({year = "20"..y, month = m, day = d, hour = h, min = min, sec = s})
					end

					if next(lootDB[nameb]) then
						local dateb = lootDB[nameb][#lootDB[nameb]].date
						local timeb = lootDB[nameb][#lootDB[nameb]].time
						local d, m, y = strsplit("/", dateb, 3)
						local h, min, s = strsplit(":", timeb, 3)
						epochb = time({year = "20"..y, month = m, day = d, hour = h, min = min, sec = s})
					end
					return epocha < epochb
				end
			end)

			for _,i in ipairs(sorttable) do --luacheck: ignore
				local v = LootHistory.frame.name.data[i]
				info.text = v[2].value
				local c = addon:GetClassColor(v[1].args[1])
				info.colorCode = "|cff"..addon.Utils:RGBToHex(c.r,c.g,c.b)
				info.notCheckable = true
				info.hasArrow = false
				info.func = function()
					addon.Log:D("Moving award from", data.name, "to", v[2].name)
					-- Since we store data as lootDB[name] = ..., we need to move the entire table to the new recipient
					tinsert(lootDB[v[2].name], tremove(lootDB[data.name], data.num))
					-- Now update the data in our display st, which coincidentally is data
					data.num = #lootDB[v[2].name]
					data.name = v[2].name
					data.class = v[1].args[1]
					-- We also need to update the class saved with the loot:
					lootDB[data.name][data.num].class = data.class
					data.cols[1].args[1] = v[1].args[1]
					data.cols[2] = {value = v[2].value, color = addon:GetClassColor(data.class)}
					LootHistory.frame.st:SortData()
					addon:SendMessage("RCHistory_NameEdit", data)
				end
				MSA_DropDownMenu_AddButton(info, level)
			end
		elseif value == "EDIT_RESPONSE" and entry.special == value then
			local v;
			for i = 1, db.buttons.default.numButtons do --luacheck: ignore
				v = db.responses.default[i]
				info.text = v.text
				info.colorCode = "|cff"..addon.Utils:RGBToHex(unpack(v.color))
				info.notCheckable = true
				info.func = function()
					addon.Log:D("Changing response id @", data.name, "from", data.response, "to", i)
					local entry = lootDB[data.name][data.num] --luacheck: ignore
					entry.responseID = i
					entry.response = addon:GetResponse("default",i).text
					entry.color = {addon:GetResponseColor("default", i)}
					entry.isAwardReason = nil
					entry.tokenRoll = nil
					entry.relicRoll = nil
					data.response = i
					data.cols[6].args = {color = entry.color, response = entry.response, responseID = i}
					LootHistory.frame.st:SortData()
					addon:SendMessage("RCHistory_ResponseEdit", data)
				end
				MSA_DropDownMenu_AddButton(info, level)
			end

			info = MSA_DropDownMenu_CreateInfo()
			for k,responses in pairs(db.responses) do
				addon.Log:D("db.responses:", k)
				if k ~= "default" and k ~= "*" then
					info.text = addon.OPT_MORE_BUTTONS_VALUES[k] or _G.UNKNOWN
					info.isTitle = true
					info.disabled = true
					info.notCheckable = true
					MSA_DropDownMenu_AddButton(info, level)
					for i, v in ipairs(responses) do --luacheck: ignore
						addon.Log:D("responses:", i)
						info.text = v.text
						info.colorCode = "|cff"..addon.Utils:RGBToHex(unpack(v.color))
						info.isTitle = false
						info.disabled = false
						info.notCheckable = true
						info.func = function()
							addon.Log:D("Changing response id @", data.name, "from", data.response, "to", i)
							local entry = lootDB[data.name][data.num] --luacheck: ignore
							entry.responseID = i
							entry.response = addon:GetResponse(k,i).text
							entry.color = {addon:GetResponseColor(k, i)}
							entry.isAwardReason = nil
							entry.tokenRoll = nil
							entry.relicRoll = nil
							data.response = i
							data.cols[6].args = {color = entry.color, response = entry.response, responseID = i}
							LootHistory.frame.st:SortData()
							addon:SendMessage("RCHistory_ResponseEdit", data)
						end
						MSA_DropDownMenu_AddButton(info, level)
					end
				end
			end

			if addon.debug then
				for k,v in pairs(db.responses.default) do --luacheck: ignore
					if type(k) ~= "number" and k ~= "tier" and k ~= "relic" then
						info.text = v.text
						info.colorCode = "|cff"..addon.Utils:RGBToHex(unpack(v.color))
						info.notCheckable = true
						info.func = function()
							addon.Log:D("Changing response id @", data.name, "from", data.response, "to", i)
							local entry = lootDB[data.name][data.num] --luacheck: ignore
							entry.responseID = k
							entry.response = addon:GetResponse("default",k).text
							entry.color = {addon:GetResponseColor("default", k)}
							entry.isAwardReason = nil
							data.response = k
							data.cols[6].args = {color = entry.color, response = entry.response, responseID = k}
							LootHistory.frame.st:SortData()
						end
						MSA_DropDownMenu_AddButton(info, level)
					end
				end
			end

		elseif value == "AWARD_REASON" and entry.special == value then
			for k,v in ipairs(db.awardReasons) do
				if k > db.numAwardReasons then break end
				info.text = v.text
				info.colorCode = "|cff"..addon.Utils:RGBToHex(unpack(v.color))
				info.notCheckable = true
				info.func = function()
					addon.Log:D("Changing award reason id @", data.name, "from", data.response, "to", k)
					local entry = lootDB[data.name][data.num] --luacheck: ignore
					entry.responseID = k
					entry.response = v.text
					entry.color = {unpack(v.color)} -- For some reason it won't just accept v.color (!)
					entry.isAwardReason = true
					entry.tokenRoll = nil
					entry.relicRoll = nil
					data.response = i
					data.cols[6].args = {color = entry.color, response = entry.response, responseID = k}
					LootHistory.frame.st:SortData()
					addon:SendMessage("RCHistory_ResponseEdit", data)
				end
				MSA_DropDownMenu_AddButton(info, level)
			end
		end
	end
end
end

---------------------------------------------------------------
-- Exports.
-- REVIEW A lot of optimizations can be done here.
-- @section Exports.
---------------------------------------------------------------
do
	local export, ret = {},{}

	local function CSVEscape(s)
		s = tostring(s or "")
		if s:find(",") then
			-- Escape double quote in the string and enclose string that can contains comma by double quote
			return "\"" .. gsub(s, "\"", "\"\"") .. "\""
		else
			return s
		end
	end

	local function QuotesEscape (s)
		s = tostring(s or "")
		return gsub(s, "\"", "\\\"")
	end

	--- CSV with all stored data
	-- ~14 ms (74%) improvement by switching to table and concat
	function LootHistory:ExportCSV()
		-- Add headers
		wipe(export)
		wipe(ret)
		local subType, equipLoc
		tinsert(ret, "player,date,time,id,item,itemID,itemString,response,votes,class,instance,boss,difficultyID,mapID,groupSize,gear1,gear2,responseID,isAwardReason,subType,equipLoc,note,owner\r\n")
		for player, v in pairs(self:GetFilteredDB()) do
			for _, d in pairs(v) do
				_,_,subType, equipLoc = GetItemInfoInstant(d.lootWon)
				if d.tierToken then subType = L["Armor Token"] end
				-- We might have commas in various things here :/
				tinsert(export, tostring(player))
				tinsert(export, tostring(self:GetLocalizedDate(d.date)))
				tinsert(export, tostring(d.time))
				tinsert(export, tostring(d.id))
				tinsert(export, CSVEscape(d.lootWon))
				tinsert(export, addon.Utils:GetItemIDFromLink(d.lootWon))
				tinsert(export, addon.Utils:GetItemStringFromLink(d.lootWon))
				tinsert(export, CSVEscape(d.response))
				tinsert(export, tostring(d.votes))
				tinsert(export, tostring(d.class))
				tinsert(export, CSVEscape(d.instance))
				tinsert(export, CSVEscape(d.boss))
				tinsert(export, d.difficultyID or "")
				tinsert(export, d.mapID or "")
				tinsert(export, d.groupSize or "")
				tinsert(export, CSVEscape(self:EscapeItemLink(d.itemReplaced1 or "")))
				tinsert(export, CSVEscape(self:EscapeItemLink(d.itemReplaced2 or "")))
				tinsert(export, tostring(d.responseID))
				tinsert(export, tostring(d.isAwardReason or false))
				tinsert(export, tostring(subType))
				tinsert(export, tostring(getglobal(equipLoc) or ""))
				tinsert(export, CSVEscape(d.note))
				tinsert(export, tostring(d.owner or "Unknown"))
				tinsert(ret, table.concat(export, ","))
				tinsert(ret, "\r\n")
				wipe(export)
			end
		end
		return table.concat(ret)
	end

	--- TSV (Tab Seperated Values) for Excel
	-- Made specificly with excel in mind, but might work with other spreadsheets
	function LootHistory:ExportTSV()
		-- Add headers
		wipe(export)
		wipe(ret)
		local subType, equipLoc, rollType
		tinsert(ret, "player\tdate\ttime\titem\titemID\titemString\tresponse\tvotes\tclass\tinstance\tboss\tgear1\tgear2\tresponseID\tisAwardReason\trollType\tsubType\tequipLoc\tnote\towner\r\n")
		for player, v in pairs(self:GetFilteredDB()) do
			for _, d in pairs(v) do
				_,_,subType, equipLoc = GetItemInfoInstant(d.lootWon)
				if d.tierToken then subType = L["Armor Token"] end
				rollType = (d.tokenRoll and "token") or (d.relicRoll and "relic") or "normal"
				tinsert(export, tostring(player))
				tinsert(export, tostring(self:GetLocalizedDate(d.date)))
				tinsert(export, tostring(d.time))
				tinsert(export, "=HYPERLINK(\""..self:GetWowheadLinkFromItemLink(d.lootWon).."\";\""..tostring(d.lootWon).."\")")
				tinsert(export, addon.Utils:GetItemIDFromLink(d.lootWon))
				tinsert(export, addon.Utils:GetItemStringFromLink(d.lootWon))
				tinsert(export, tostring(d.response))
				tinsert(export, tostring(d.votes))
				tinsert(export, tostring(d.class))
				tinsert(export, tostring(d.instance))
				tinsert(export, tostring(d.boss))
				tinsert(export, d.itemReplaced1 and "=HYPERLINK(\""..self:GetWowheadLinkFromItemLink(tostring(d.itemReplaced1)).."\";\""..tostring(d.itemReplaced1).."\")" or "")
				tinsert(export, d.itemReplaced2 and "=HYPERLINK(\""..self:GetWowheadLinkFromItemLink(tostring(d.itemReplaced2)).."\";\""..tostring(d.itemReplaced2).."\")" or "")
				tinsert(export, tostring(d.responseID))
				tinsert(export, tostring(d.isAwardReason or false))
				tinsert(export, rollType)
				tinsert(export, tostring(subType))
				tinsert(export, tostring(getglobal(equipLoc) or ""))
				tinsert(export, d.note or "")
				tinsert(export, tostring(d.owner or "Unknown"))
				tinsert(ret, table.concat(export, "\t"))
				tinsert(ret, "\r\n")
				wipe(export)
			end
		end
		return table.concat(ret)
	end

	function LootHistory:ExportJSON()
		wipe(export)
		wipe(ret)
		local subType, equipLoc, rollType
		local eligibleEntries = 0;

		for _, v in pairs(self:GetFilteredDB()) do
			for _ in pairs(v) do
					eligibleEntries = eligibleEntries + 1;
			end
		end

		local processedEntries = 0;

		for player, v in pairs(self:GetFilteredDB()) do
			for _, d in pairs(v) do
				_,_,subType, equipLoc = GetItemInfoInstant(d.lootWon)
				if d.tierToken then subType = L["Armor Token"] end
				rollType = (d.tokenRoll and "token") or (d.relicRoll and "relic") or "normal"
				tinsert(export, string.format("\"%s\":\"%s\"", "player", tostring(player)))
				tinsert(export, string.format("\"%s\":\"%s\"", "date", tostring(self:GetLocalizedDate(d.date))))
				tinsert(export, string.format("\"%s\":\"%s\"", "time", tostring(d.time)))
				tinsert(export, string.format("\"%s\":%s", "itemID", addon.Utils:GetItemIDFromLink(d.lootWon)))
				tinsert(export, string.format("\"%s\":\"%s\"", "itemString", addon.Utils:GetItemStringFromLink(d.lootWon)))
				tinsert(export, string.format("\"%s\":\"%s\"", "response", QuotesEscape(d.response)))
				tinsert(export, string.format("\"%s\":%s", "votes", tostring(d.votes or 0)))
				tinsert(export, string.format("\"%s\":\"%s\"", "class", tostring(d.class)))
				tinsert(export, string.format("\"%s\":\"%s\"", "instance", QuotesEscape(d.instance)))
				tinsert(export, string.format("\"%s\":\"%s\"", "boss", QuotesEscape(d.boss)))
				tinsert(export, string.format("\"%s\":\"%s\"", "gear1", QuotesEscape(d.itemReplaced1)))
				tinsert(export, string.format("\"%s\":\"%s\"", "gear2", QuotesEscape(d.itemReplaced2)))
				tinsert(export, string.format("\"%s\":\"%s\"", "responseID", tostring(d.responseID)))
				tinsert(export, string.format("\"%s\":\"%s\"", "isAwardReason", tostring(d.isAwardReason or false)))
				tinsert(export, string.format("\"%s\":\"%s\"", "rollType", rollType))
				tinsert(export, string.format("\"%s\":\"%s\"", "subType", tostring(subType)))
				tinsert(export, string.format("\"%s\":\"%s\"", "equipLoc", tostring(getglobal(equipLoc) or "")))
				tinsert(export, string.format("\"%s\":\"%s\"", "note", QuotesEscape(d.note)))
				tinsert(export, string.format("\"%s\":\"%s\"", "owner", tostring(d.owner or "Unknown")))

				processedEntries = processedEntries + 1;

				if processedEntries < eligibleEntries then
					tinsert(ret, "{" .. table.concat(export, ",") .. "},")
				else
					tinsert(ret, "{" .. table.concat(export, ",") .. "}")
				end
				wipe(export)
			end
		end
		return "[" .. table.concat(ret) .. "]"
	end

	--- Simplified BBCode, as supported by CurseForge
	-- ~24 ms (84%) improvement by switching to table and concat
	function LootHistory:ExportBBCode()
		wipe(export)
		for player, v in pairs(self:GetFilteredDB()) do
			tinsert(export, "[b]"..addon.Ambiguate(player)..":[/b]\r\n")
			tinsert(export, "[list=1]")
			local first = true
			for _, d in pairs(v) do
				if first then
					first = false
				else
					tinsert(export, "[*]")
				end
				tinsert(export, "[url="..self:GetWowheadLinkFromItemLink(d.lootWon).."]"..d.lootWon.."[/url]"
				.." Response: "..tostring(d.response)..".\r\n")
			end
			tinsert(export, "[/list]\r\n\r\n")
		end
		return table.concat(export)
	end

	--- BBCode, as supported by SMF
	function LootHistory:ExportBBCodeSMF()
		wipe(export)
		for player, v in pairs(self:GetFilteredDB()) do
			tinsert(export, "[b]"..addon.Ambiguate(player)..":[/b]\r\n")
			tinsert(export, "[list]")
			for _, d in pairs(v) do
				tinsert(export, "[*]")
				tinsert(export, "[url="..self:GetWowheadLinkFromItemLink(d.lootWon).."]"..d.lootWon.."[/url]")
				tinsert(export, " Response: "..tostring(d.response)..".\r\n")
			end
			tinsert(export, "[/list]\r\n\r\n")
		end
		return table.concat(export)
	end

	--- EQdkp Plus XML, primarily for Enjin import
	function LootHistory:ExportEQXML()
		local export = "<raidlog><head><export><name>EQdkp Plus XML</name><version>1.0</version></export>"
			.."<tracker><name>RCLootCouncil</name><version>"..addon.version.."</version></tracker>"
			.."<gameinfo><game>World of Warcraft</game><language>"..GetLocale().."</language><charactername>"..UnitName("Player").."</charactername></gameinfo></head>\r\n"
			.."<raiddata>\r\n"
		local bossData = "\t<bosskills>\r\n"
		local zoneData = "\t<zones>\r\n"
		local itemsData = "\t<items>\r\n"
		local membersData = {}
		local raidData = {}
		local bossesAdded = {}
		local earliest = 9999999999
		local latest = 0
		for player, v in pairs(self:GetFilteredDB()) do
			for _, d in pairs(v) do
				local day, month, year = strsplit("/", d.date, 3)
				local hour,minute,second = strsplit(":",d.time,3)
				local sinceEpoch = time({year = "20"..year, month = month, day = day,hour = hour,min = minute,sec=second})
				itemsData = itemsData.."\t\t<item>\r\n"
				.."\t\t\t<itemid>" .. addon.Utils:GetItemStringClean(d.lootWon) .. "</itemid>\r\n"
				.."\t\t\t<name>" .. addon.Utils:GetItemNameFromLink(d.lootWon) .. "</name>\r\n"
				.."\t\t\t<member>" .. addon.Ambiguate(player) .. "</member>\r\n"
				.."\t\t\t<time>" .. sinceEpoch .. "</time>\r\n"
				.."\t\t\t<count>1</count>\r\n"
				.."\t\t\t<cost>" .. tostring(d.votes) .. "</cost>\r\n"
				.."\t\t\t<note>" .. tostring(d.response) .. "</note>\r\n"
				membersData[addon.Ambiguate(player)] = true

				local boss = gsub(tostring(d.boss),",","")
				itemsData = itemsData .. (boss and "\t\t\t<boss>" .. boss .. "</boss>\r\n" or "\t\t\t<boss />\r\n")

				if d.instance then
					itemsData = itemsData .. "\t\t\t<zone>" .. gsub(tostring(d.instance),",","") .. "</zone>\r\n"
					raidData[time({year="20"..year,month=month,day=day})] = gsub(tostring(d.instance),",","")
				else
					itemsData = itemsData .. "\t\t\t<zone />\r\n"
				end
				itemsData = itemsData.."\t\t</item>\r\n"

				if not bossesAdded[boss] then
					bossesAdded[boss] = true
					bossData = bossData .. "\t\t<bosskill>\r\n"
					bossData = bossData .. (boss and "\t\t\t<name>"..boss.."</name>\r\n" or "\t\t\t<name>Unknown</name>\r\n")
					bossData = bossData .. (d.instance and "\t\t\t<time>"..sinceEpoch.."</time>\r\n" or "")
					bossData = bossData .. "\t\t</bosskill>\r\n"
				end
				latest = max(latest, sinceEpoch + 600)
			end
		end
		bossData = bossData .."\t</bosskills>\r\n"
		for id, name in pairs(raidData) do
			zoneData = zoneData .. "\t\t<zone>\r\n"
			.. "\t\t\t<enter>"..id.."</enter>\r\n"
			.. "\t\t\t<name>"..name.."</name>\r\n"
			.. "\t\t\t<leave>"..latest.."</leave>\r\n"
			.. "\t\t</zone>\r\n"
			earliest = min(earliest, id)
		end
		zoneData = zoneData .."\t</zones>\r\n"
		itemsData = itemsData.. "\t</items>\r\n"
		export = export..zoneData..bossData..itemsData
		.."\t<members>\r\n"
		for name in pairs(membersData) do
			export = export.. "\t\t<member>\r\n"
			.."\t\t\t<name>"..name.."</name>\r\n"
			.."\t\t\t<times>\r\n"
			.."\t\t\t\t<time type='join'>"..earliest.."</time>\r\n"
			.."\t\t\t\t<time type='leave'>".. latest .."</time>\r\n"
			.."\t\t\t</times>\r\n"
			.."\t\t</member>\r\n"
		end
		export=export.. "\t</members>\r\n</raiddata></raidlog>\r\n"
		return export
	end

	--- Discord friendly output
	function LootHistory:ExportDiscord()
		wipe(export)
		for player, v in pairs(self:GetFilteredDB()) do
			tinsert(export, "__ **")
			tinsert(export,addon.Ambiguate(player))
			tinsert(export, ":** __\r\n")
			for _, d in pairs(v) do
				tinsert(export, "Item: **")
				tinsert(export, d.lootWon)
				tinsert(export, "** - Response: ***")
				tinsert(export, tostring(d.response))
				tinsert(export, "***\r\n")
				tinsert(export, " - View Item: <")
				tinsert(export, self:GetWowheadLinkFromItemLink(d.lootWon))
				tinsert(export, ">\r\n")
			end
			tinsert(export, "\r\n\r\n")
		end
		return table.concat(export)
	end

	function LootHistory:ExportHTML()
		-- local export = "html test"
	end

	--- Generates a serialized string containing the entire DB.
	-- For now it needs to be copied and pasted in another player's import field.
	function LootHistory:PlayerExport()
		return self:EscapeItemLink(self:Serialize(lootDB))
	end
end
