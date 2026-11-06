--- lootHistory.lua Adds the interface for displaying the collected loot history.
-- DefaultModule
-- @author Potdisc
-- Create Date : 8/6/2015
--[[ COMMS:
	MAIN:
		history				P - history received from ML on awards.
		delete_history		P - ML tells us to delete specific history entry.
]]

--- @type RCLootCouncil
local addon = select(2, ...)
---@class RCLootHistory : AceModule, AceSerializer-3.0
local LootHistory = addon:NewModule("RCLootHistory", "AceSerializer-3.0")
--- @type RCLootCouncilLocale
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local AG = LibStub("AceGUI-3.0")
local Comms = addon.Require "Services.Comms"
local ItemUtils = addon.Require "Utils.Item"
local Player = addon.Require "Data.Player"
local TempTable = addon.Require "Utils.TempTable"

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
local selectedDate, selectedName, moreInfo, moreInfoData
local ROW_HEIGHT = 20;
local NUM_ROWS = 15;
local useClassFilters = false

LootHistory.wowheadBaseUrl = "https://www.wowhead.com/item="

--globals
local tinsert, tostring, getglobal, pairs, ipairs, tremove, strsplit = tinsert, tostring, getglobal, pairs, ipairs,
	tremove, strsplit

function LootHistory:OnInitialize()
	self.exportSelection = addon.db.profile.defaultHistoryExport or "player"
	-- Pointer to export functions. Expected to return a string containing the export
	self.exports = {
		csv = { func = self.ExportCSV, name = "CSV", tip = L["Standard .csv output."], },
		tsv = { func = self.ExportTSV, name = "TSV (International Excel)", tip = L.history_export_excel_international_tip, },
		sheets = { func = self.ExportGoogleSheets, name = "TSV (Google Sheets & English Excel)", tip = L.history_export_sheets_tip, },
		bbcode = { func = self.ExportBBCode, name = "BBCode", tip = L["Simple BBCode output."], },
		bbcodeSmf = { func = self.ExportBBCodeSMF, name = "BBCode SMF", tip = L["BBCode export, tailored for SMF."], },
		eqxml = { func = self.ExportEQXML, name = "EQdkp-Plus XML", tip = L["EQdkp-Plus XML output, tailored for Enjin import."], },
		player = { func = self.PlayerExport, name = "Player Export", tip = L["A format to copy/paste to another player."], },
		playerNew = { func = self.PlayerExportNew, name = "Player Export (new)", tip = L["A format to copy/paste to another player."], },
		discord = { func = self.ExportDiscord, name = "Discord", tip = L["Discord friendly output."], },
		json = { func = self.ExportJSON, name = "JSON", tip = L["Standard JSON output."], },
		--html = self.ExportHTML
	}
	self.scrollCols = {
		{ name = "",          width = ROW_HEIGHT, sortnext = 2, },                                                -- Class icon, should be same row as player
		{ name = _G.NAME,     width = 100,        sortnext = 3,                    defaultsort = 1, },            -- Name of the player
		{ name = L["Time"],   width = 130,        comparesort = self.DateTimeSort, sort = 2,        defaultsort = 2, }, -- Time of awarding
		{ name = "",          width = ROW_HEIGHT, },                                                              -- Item icon
		{ name = L["Item"],   width = 250,        comparesort = self.ItemSort,     defaultsort = 1, sortnext = 2, }, -- Item string
		{ name = L["Reason"], width = 220,        comparesort = self.ResponseSort, defaultsort = 1, sortnext = 2, }, -- Response aka the text supplied to lootDB...response
		{ name = L["Notes"],  width = 40, },
		{ name = "",          width = ROW_HEIGHT, },                                                              -- Session responses button
		{ name = "",          width = ROW_HEIGHT, },                                                              -- Delete button
	}
	self:SubscribeToPermanentComms()
end

function LootHistory:OnEnable()
	addon.Log("LootHistory:OnEnable()")
	moreInfo = true
	db = addon:Getdb()
	lootDB = addon:GetHistoryDB()
	for _, v in pairs(db.modules["RCLootHistory"].filters.class) do
		if not v then
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
	-- self.frame:SetParent(nil)
	-- self.frame = nil
	data = {}
end

--- Show the LootHistory frame.
function LootHistory:Show()
	addon.Log("LootHistory:Show()")
	moreInfoData = addon:GetLootDBStatistics()
	self.frame:Show()
	self:Update()
end

--- Hide the LootHistory frame.
function LootHistory:Hide()
	self.SessionData:Hide()
	self.frame:Hide()
	self.moreInfo:Hide()
	moreInfo = false
end

function LootHistory:SubscribeToPermanentComms()
	Comms:BulkSubscribe(COMMS_PREFIX, {
		history = function(data)
			self:OnHistoryReceived(unpack(data))
		end,
		delete_history = function(data)
			self:OnHistoryDeleteReceived(unpack(data))
		end,
	})
end

--- Decodes raw SR history string into a useable table
--- @param his table As received from "history" comm.
function LootHistory:DecodeSessionResponses(his)
	his.sessionResponses = {}
	for guid, encoded in pairs(his.SR) do
		local name = Player:Get(guid):GetName()
		local splitted = TempTable:Acquire(string.split("@", encoded))
		if #splitted <= 2 and splitted[1] ~= "" then
			his.sessionResponses[name] = {
				ilvl = splitted[1] and tonumber(splitted[1]) or nil,
				roll = splitted[2] and tonumber(splitted[2]) or nil,
			}
		elseif #splitted > 2 then
			local class = splitted[2] and addon.classIDToFileName[tonumber(splitted[2])] or nil
			-- The note is transmitted last and may itself contain the delimiter
			local note = #splitted > 6 and table.concat(splitted, "@", 6) or splitted[6]
			his.sessionResponses[name] = {
				ilvl = splitted[1] and tonumber(splitted[1]) or nil,
				class = class,
				response = splitted[3] and tonumber(splitted[3]) or nil,
				roll = splitted[4] and tonumber(splitted[4]) or nil,
				votes = splitted[5] and tonumber(splitted[5]) or nil,
				note = note,
			}
		else
			addon.Log:E("Error decoding session responses", name, encoded)
		end
		TempTable:Release(splitted)
	end
end

function LootHistory:OnHistoryReceived(name, history)
	db = addon:Getdb()
	if not db.enableHistory then return end
	if not db.savePersonalLoot then
		if history.responseID == "PL" or history.responseID == "PL_REJECT" then
			addon.Log:D("Not storing personal loot", history.lootWon)
			return
		end
	end
	if not db.saveBonusRolls and history.responseID == "BONUS_ROLL" then
		return addon.Log:D("Not storing bonus rolls", history.lootWon)
	end
	if db.saveSessionResponses and history.SR then -- Both the ML (collection) and each receiver (storage) must opt in
		self:DecodeSessionResponses(history)
	end
	history.SR = nil
	-- v3.15.4 check for old date formats
	local d, m, y = strsplit("/", history.date, 3)
	if #tostring(d) < 4 then
		history.date = string.format("%04d/%02d/%02d", "20" .. y, m, d)
	end
	-- v2.15 Add itemClass and itemSubClass locally:
	local itemID, _, _, _, _, itemClassID, itemSubClassID = C_Item.GetItemInfoInstant(history.lootWon)
	history.tierToken = RCTokenTable[itemID] and true
	history.iClass = itemClassID
	history.iSubClass = itemSubClassID
	if addon.lootDB.factionrealm[name] then
		tinsert(addon.lootDB.factionrealm[name], history)
	else
		addon.lootDB.factionrealm[name] = { history, }
	end
	if self:IsEnabled() then -- Update history frame if it is shown currently.
		self:BuildData()
	end
end

function LootHistory:OnHistoryDeleteReceived(id)
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

function LootHistory:BuildData()
	addon.Log:D("LootHistory:BuildData()")
	data = {}
	local date
	-- We want to rebuild lootDB to the "data" format:
	--local i = 1
	for name, a in pairs(lootDB) do
		-- Now we actually add the data
		for i, v in ipairs(a) do
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
							{ DoCellUpdate = addon.SetCellClassIcon,      args = { x.class, },                                                                                                 value = x.class, },
							{ value = addon.Ambiguate(name),              color = addon:GetClassColor(x.class), },
							{ value = (date .. "-" .. i.time) or "",      args = { id = i.id, }, },
							{ DoCellUpdate = self.SetCellGear,            args = { i.lootWon, }, },
							{ value = i.lootWon, },
							{ DoCellUpdate = self.SetCellResponse,        args = { color = i.color, response = i.response, responseID = i.responseID or 0, isAwardReason = i.isAwardReason, }, },
							{ DoCellUpdate = self.SetCellNote, },
							{ DoCellUpdate = self.SetCellSessionResponses, },
							{ DoCellUpdate = self.SetCellDelete, },
						},
					}
					row = row + 1
				end
			end
			if not insertedNames[name] then -- we only want each name added once
				tinsert(nameData,
					{
						{ DoCellUpdate = addon.SetCellClassIcon, args = { x.class, }, },
						{ value = addon.Ambiguate(name),         color = addon:GetClassColor(x.class), name = name, },
					}
				)
				insertedNames[name] = true
			elseif x.class then -- it already exists, but we might need to add the class which we now have
				for i in pairs(nameData) do
					if nameData[i][2].name == name then
						nameData[i][1].args = { x.class, }
					end
				end
			end
		end
		tinsert(dateData, { date, })
	end

	self.frame.st:SetData(self.frame.rows)
	self.frame.itemCount:Update()
	self.frame.date:SetData(dateData, true) -- True for minimal data	format
	self.frame.name:SetData(nameData, true)
end

function LootHistory:GetAllRegisteredCandidates()
	local names = {}
	lootDB = addon:GetHistoryDB()
	for name, a in pairs(lootDB) do
		for _, v in ipairs(a) do
			if v.class then
				names[name] = { name = addon.Ambiguate(name), color = addon:GetClassColor(v.class), }
				break
			end
		end
	end
	return names
end

--- Returns a list of all registered instances
--- @return table<string, string> ["mapID-difficultyID"] = "instance_name"
function LootHistory:GetAllRegisteredInstances()
	local raids = {}
	lootDB = addon:GetHistoryDB()
	for _, a in pairs(lootDB) do
		for _, v in ipairs(a) do
			if v.mapID and v.instance and v.difficultyID then
				raids[v.mapID .. "-" .. v.difficultyID] = v.instance
			end
		end
	end
	table.sort(raids)
	return raids
end

--- Reads our history for all registered instances and updates the db with them
function LootHistory:UpdateRegisteredInstances()
	addon.db.profile.registeredInstances = self:GetAllRegisteredInstances()
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
	for name, a in pairs(lootDB) do
		removal[name] = {}
		local num = 1
		for i, v in ipairs(a) do
			local time, counter = string.split("-", v.id or "")
			if tonumber(time) < epoch then
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

local function filterNameData(name, date)
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

---@param response string|integer
---@param isAwardReason boolean?
---@param typeCode string?
---@return boolean responseFilter
local function filterResponse(response, isAwardReason, typeCode)
	if not typeCode then typeCode = "default" end
	local filters = db.modules["RCLootHistory"].filters
	local responseFilter
	if isAwardReason then
		responseFilter = filters.awardReasons and filters.awardReasons[response]
	elseif type(response) == "number" or response == "AUTOPASS" or response == "PASS" or response == "BONUSROLL" then
		responseFilter = filters[typeCode] and filters[typeCode][response]
	else
		responseFilter = filters.default.STATUS
	end
	return responseFilter
end

local function classFilter(class)
	local classFilter = true -- Don't filter classes if none are selected
	if useClassFilters then
		local classID = addon.classTagNameToID[class]
		classFilter = not db.modules["RCLootHistory"].filters.class[classID]
	end
	return classFilter
end

-- Filter function for Lib-ScrollingTable
function LootHistory.FilterFunc(table, row)
	-- Name and Date filters:
	local nameAndDate = filterNameData(row.name, row.date)

	-- Response filters:
	if not db.modules["RCLootHistory"].filters then return nameAndDate end -- db hasn't been initialized
	local responseFilter = filterResponse(row.response, row.isAwardReason,
		lootDB[row.name][row.num].typeCode or "default")

	-- Class Filters:
	local classFilter = classFilter(row.class)

	return nameAndDate and responseFilter and classFilter -- Either one can filter the entry
end

--- Filter for the shown history
---@param winner string Name of the winner
---@param entry HistoryEntry
---@return boolean
function LootHistory:FilterForLootDB(winner, entry)
	-- Name and Date filters:
	local nameAndDate = filterNameData(winner, entry.date)

	-- Response filters:
	if not db.modules["RCLootHistory"].filters then return nameAndDate end -- db hasn't been initialized
	local responseFilter = filterResponse(entry.responseID, entry.isAwardReason, entry.typeCode or "default")

	-- Class Filters:
	local classFilter = classFilter(entry.class)

	return nameAndDate and responseFilter and classFilter -- Either one can filter the entry
end

function LootHistory:GetFilteredDB()
	lootDB = addon:GetHistoryDB()
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
	frame.text:SetText(data[realrow][column])
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
		--local texture = select(10, C_Item.GetItemInfo(gear))
		local texture = select(5, C_Item.GetItemInfoInstant(gear))
		frame:SetNormalTexture(texture or "Interface/ICONS/INV_Sigil_Thorim.png")
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

	if args.color and type(args.color) == "table" and type(args.color[1]) == "number" then  -- Never version saves the color with the entry
		frame.text:SetTextColor(unpack(args.color))
	elseif args.responseID and (type(args.responseID) == "string" or args.responseID > 0) then -- try to recreate color from ID
		frame.text:SetTextColor(unpack(addon:GetResponse("default", args.responseID).color))
	else                                                                                    -- default to white
		frame.text:SetTextColor(1, 1, 1, 1)
	end
end

function LootHistory.SetCellNote(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	if not data then return end
	local row = data[realrow]
	local note = lootDB[row.name][row.num].note
	local f = frame.noteBtn or CreateFrame("Button", nil, frame)
	f:SetSize(ROW_HEIGHT, ROW_HEIGHT)
	f:SetPoint("CENTER", frame, "CENTER")
	if note then
		f:SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Up.png")
		f:SetScript("OnEnter", function() addon:CreateTooltip(_G.LABEL_NOTE, note) end) -- _G.LABEL_NOTE == "Note" in English
		f:SetScript("OnLeave", function() addon:HideTooltip() end)
		data[realrow].cols[column].value = 1                                      -- Set value for sorting compability
	else
		f:SetScript("OnEnter", nil)
		f:SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Disabled.png")
		data[realrow].cols[column].value = 0
	end
	frame.noteBtn = f
end

function LootHistory.SetCellSessionResponses(rowFrame, frame, data, cols, rowNum, realrow, column, fShow, table, ...)
	if not data then return end
	local row = data[realrow]
	local entry = lootDB[row.name] and lootDB[row.name][row.num]
	local f = frame.sessionBtn or CreateFrame("Button", nil, frame)
	f:SetSize(ROW_HEIGHT, ROW_HEIGHT)
	f:SetPoint("CENTER", frame, "CENTER")
	if entry and entry.sessionResponses then
		f:SetNormalTexture("Interface/Buttons/UI-GroupLoot-Dice-Up")
		f:SetHighlightTexture("Interface/Buttons/UI-GroupLoot-Dice-Highlight")
		f:SetScript("OnEnter", function()
			LootHistory.SessionData:SessionDetailButtonOnClick(row.name, entry, f)
			addon:CreateTooltip(L["Responses"], L["history_sessionResponses_tip"])
		end)
		f:SetScript("OnLeave", function() addon:HideTooltip() end)
		f:SetScript("OnClick",
			function() LootHistory.SessionData:SessionDetailButtonOnClick(row.name, entry, f) end)
		f:Show()
	else
		f:Hide()
	end
	frame.sessionBtn = f
end

function LootHistory.SetCellDelete(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	if not frame.created then
		frame:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		frame:SetHighlightTexture("Interface/Buttons/UI-GROUPLOOT-PASS-HIGHLIGHT")
		frame:SetPushedTexture("Interface/Buttons/UI-GROUPLOOT-PASS-DOWN")
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
			LootHistory.SessionData:Hide()
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

function LootHistory:DateTimeToSeconds(d, m, y, h, min, s)
	return time({
		year = #tostring(y) == 4 and y or "20" .. y or 10,
		month = m or 1,
		day = d or 1,
		hour = h or 0,
		min =
			min or 0,
		sec = s or 0,
	})
end

function LootHistory.DateTimeSort(table, rowa, rowb, sortbycol)
	local cella, cellb = table:GetCell(rowa, sortbycol), table:GetCell(rowb, sortbycol);
	local idA, idB = cella.args.id, cellb.args.id
	local timeA, counterA = string.split("-", idA or "")
	local timeB, counterB = string.split("-", idB or "")
	if not timeA or not timeB then return false end

	timeA, timeB = tonumber(timeA), tonumber(timeB)
	if timeA == timeB and counterA ~= "" and counterB ~= "" then
		return tonumber(counterA) < tonumber(counterB)
	else
		local direction = table.cols[sortbycol].sort or table.cols[sortbycol].defaultsort or 1
		if direction == 1 then
			return timeA < timeB
		else
			return timeA > timeB
		end
	end
end

function LootHistory.DateSort(table, rowa, rowb, sortbycol)
	local column = table.cols[sortbycol]
	rowa, rowb = table:GetRow(rowa), table:GetRow(rowb);
	local a, b = rowa[1], rowb[1]
	if not (a and b) then return false end
	local y, m, d = addon.Utils:DateSplit(a)
	local aTime = time({ year = y, month = m, day = d, })
	y, m, d = addon.Utils:DateSplit(b)
	local bTime = time({ year = y, month = m, day = d, })
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
	local a, b
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
			if nextcol and not (nextcol.sort) then
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
	local a, b = lootDB[rowa.name][rowa.num].lootWon, lootDB[rowb.name][rowb.num].lootWon
	a = ItemUtils:GetItemNameFromLink(a)
	b = ItemUtils:GetItemNameFromLink(b)
	if a == b then
		if column.sortnext then
			local nextcol = table.cols[column.sortnext];
			if nextcol and not (nextcol.sort) then
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

function LootHistory:ExportHistory(format)
	assert(self.exports[format or self.exportSelection], "Invalid format for exporting history")
	--debugprofilestart()
	local export = self.exports[format or self.exportSelection].func(self)
	--addon.Log:D("Export time:", debugprofilestop(), "ms")
	if export and export ~= "" then -- do something
		--debugprofilestart()
		if export:len() < 40000 then
			local exportFrame = addon.UI:New("RCExportFrame")
			exportFrame:Show()
			exportFrame.edit:SetCallback("OnTextChanged", function(self)
				self:SetText(export)
			end)
			exportFrame.edit:SetText(export)
			exportFrame.edit:SetFocus()
			exportFrame.edit:HighlightText()
		else -- Use hugeExportFrame(Single line editBox) for large export to avoid freezing the game.
			local exportFrame = addon.UI:New("RCHugeExportFrame")
			exportFrame:Show()
			exportFrame.edit:SetCallback("OnTextChanged", function(self)
				self:SetText(export)
			end)
			exportFrame.edit:SetText(export)
			exportFrame.edit:SetFocus()
			exportFrame.edit:HighlightText()
		end
		--addonLog:D("Display time:", debugprofilestop(), "ms")
	end
end

function LootHistory:DetermineImportType(import)
	addon.Log:D("His:DetermineImportType")
	-- Check csv
	if import:sub(1, 6) == "player" then
		-- Check for Sheet Copy
		if import:sub(7, 7) == "\t" then
			if import:find("\tboss\tgear1") then -- Standard tsv export - not supported
				return "tsv"
			end
			import = import:gsub("\t", ",")
			if import:find("boss,difficultyID,mapID,") then
				return "tsv-csv" -- Copied from Google Sheet
			end
			return "Unknown"
		elseif import:sub(7, 7) == "," then
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

	if not type or type == "Unknown" or type == "tsv" then
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

---@param data table|string Either complete history entry, or just the date
local function checkDateFormatting(data)
	local d, m, y = strsplit("/", data.date and data.date or data)
	if #d == 4 then return data end -- is in new format
	if data.date then
		data.date = "20" .. y .. "/" .. m .. "/" .. d
	else
		data = "20" .. y .. "/" .. m .. "/" .. d
	end
	return data
end

-- REVIEW: Needs updating
function LootHistory:ImportPlayerExport(import)
	lootDB = addon:GetHistoryDB()
	-- Start with validating the import:
	if type(import) ~= "string" then
		addon:Print("The imported text wasn't a string"); return addon.Log:D("No string")
	end
	import = gsub(import, "\124\124", "\124") -- De escape itemslinks
	local test, import = self:Deserialize(import)
	if not test then
		addon:Print("Deserialization failed - maybe wrong import type?"); return addon.Log:D("Deserialization failed")
	end
	addon.Log:D("Validation completed", #lootDB == 0, #lootDB)
	-- Now import should be a copy of the orignal exporter's lootDB, so insert any changes
	-- Start by seeing if we even have a lootDB
	--if #lootDB == 0 then lootDB = import; return end
	local number = 0
	for name, data in pairs(import) do
		if lootDB[name] then           -- We've registered the name, so check all the awards
			for _, v in pairs(data) do
				v.SR = nil             -- Just in case anyone has this saved in their history
				local found = false
				for _, d in pairs(lootDB[name]) do -- REVIEW This is currently ~O(#lootDB[name]^2). Could probably be improved.
					-- Check if the id matches. If it does, we already have the data and can skip to the next
					if d.id == v.id then
						found = true; break
					end
				end
				if not found then -- add it
					tinsert(lootDB[name], checkDateFormatting(v))
					number = number + 1
				end
			end
		else -- It's a new name, so add everything and move on to the next
			lootDB[name] = {}
			for _, v in pairs(data) do
				v = checkDateFormatting(v)
				tinsert(lootDB[name], v)
			end
			number = number + #data
		end
	end
	addon.lootDB.factionrealm = lootDB -- save it
	self:UpdateRegisteredInstances()
	addon:Print(format(L["Successfully imported 'number' entries."], number))
	addon.Log:D("Import successful")
	if self.frame and self.frame:IsVisible() then
		self:BuildData(); self:Show()
	end -- Only rebuild data if we're showing
end

function LootHistory:GetWowheadLinkFromItemLink(link)
	local color, itemType, itemID, enchantID, gemID1, gemID2, gemID3, gemID4, suffixID, uniqueID, linkLevel, specializationID, upgradeTypeID, upgradeID, instanceDifficultyID, numBonuses, bonusIDs =
		addon:DecodeItemLink(link) --luacheck: no unused

	local itemurl = self.wowheadBaseUrl .. itemID

	-- It seems bonus id 1487 (and basically any other id that's -5 below Wowheads first ilvl upgrade doesn't work)
	-- Neither does Warforged items it seems
	-- 19/9-17: It seems bonusIDs 3528 and 3336 fucks up Wowhead - however there's no difference with or without those ids ingame (?!).
	if numBonuses > 0 then
		itemurl = itemurl .. "&bonus="
		for i, b in pairs(bonusIDs) do
			if b ~= 3528 and b ~= 3336 then
				itemurl = itemurl .. b
				if i < numBonuses then
					itemurl = itemurl .. ":"
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
function IsFiltering()
	for k, v in pairs(db.modules["RCLootHistory"].filters) do
		if type(v) == "table" then
			for _, x in pairs(v) do
				if not x then return true end
			end
		end
	end
end

function LootHistory:Update()
	self.frame.st:SortData()
	if IsFiltering() then
		self.frame.filter.Text:SetTextColor(0.86, 0.5, 0.22)         -- #db8238
	else
		self.frame.filter.Text:SetTextColor(_G.NORMAL_FONT_COLOR:GetRGB()) --#ffd100
	end
	self.frame.itemCount:Update()
end

function LootHistory:GetFrame()
	if self.frame then return self.frame end
	---@class RCLootHistoryFrame : RCFrame
	local f = addon.UI:NewNamed("RCFrame", UIParent, "DefaultRCLootHistoryFrame", L["RCLootCouncil Loot History"], 250,
		490)
	addon.UI:RegisterForEscapeClose(f, function() if self:IsEnabled() then self:Disable() end end)
	f:SetScript("OnMouseDown", function() self.SessionData:Hide() end)
	local st = LibStub("ScrollingTable"):CreateST(self.scrollCols, NUM_ROWS, ROW_HEIGHT,
		{ ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5, }, f.content)
	st.frame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
	st:SetFilter(self.FilterFunc)
	st:EnableSelection(true)
	st:RegisterEvents({
		["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
			if row or realrow then
				if button == "LeftButton" then
					self:UpdateMoreInfo(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
				elseif button == "RightButton" then
					rowFrame.data = data[realrow]
					MenuUtil.CreateContextMenu(rowFrame, self.CreateRightClickMenu)
				end
			end
			self.SessionData:Hide()
			return false
		end,
	})
	f.st = st

	--Date selection
	f.date = LibStub("ScrollingTable"):CreateST(
		{ { name = L["Date"], width = 74, comparesort = self.DateSort, sort = 2, DoCellUpdate = self.SetCellDate, }, }, 5,
		ROW_HEIGHT, { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5, }, f.content)
	f.date.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -30)
	f.date:EnableSelection(true)
	f.date:RegisterEvents({
		["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
			if button == "LeftButton" and row then
				selectedDate = data[realrow][column] ~= selectedDate and data[realrow][column] or nil
				self:Update()
			end
			return false
		end,
	})

	--Name selection
	f.name = LibStub("ScrollingTable"):CreateST(
		{ { name = "", width = ROW_HEIGHT, }, { name = _G.NAME, width = 100, sort = 1, }, }, 5, ROW_HEIGHT,
		{ ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5, }, f.content)
	f.name.frame:SetPoint("TOPLEFT", f.date.frame, "TOPRIGHT", 10, 0)
	f.name:EnableSelection(true)
	f.name:RegisterEvents({
		["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
			if button == "LeftButton" and row then
				selectedName = selectedName ~= data[realrow][column].name and data[realrow][column].name or nil
				self:Update()
			end
			return false
		end,
	})

	-- Abort button
	local b1 = addon:CreateButton(_G.CLOSE, f.content)
	b1:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -110)
	b1:SetScript("OnClick", function() self:Disable() end)
	f.closeBtn = b1

	-- More info button
	local b2 = CreateFrame("Button", nil, f.content, "UIPanelButtonTemplate")
	b2:SetSize(25, 25)
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
		addon.Log:D("moreInfo =", moreInfo)
	end)
	b2:SetScript("OnEnter", function() addon:CreateTooltip(L["Click to expand/collapse more info"]) end)
	b2:SetScript("OnLeave", function() addon:HideTooltip() end)
	f.moreInfoBtn = b2

	self.moreInfo = CreateFrame("GameTooltip", "RCLootHistoryMoreInfo", f.content, "GameTooltipTemplate")
	self.moreInfo:SetIgnoreParentScale(true)
	self.moreInfo:SetClampedToScreen(addon:Getdb().moreInfoClampToScreen)
	f.content:SetScript("OnSizeChanged", function()
		self.moreInfo:SetScale(Clamp(f:GetScale() * 0.6, .4, .9))
	end)

	local count = f:CreateFontString(nil, "OVERLAY", "GameFontDarkGraySmall")
	count:SetPoint("BOTTOMRIGHT", b2, "TOPRIGHT", 0, 10)
	count:SetTextColor(1, 1, 1, .9)
	f.itemCount = count
	f.itemCount.Update = function(self)
		addon.Log:D("Updating item count")
		self:SetText(format(L.history_frame_numItemsOfItems, #f.st.filtered, #f.st.data))
	end

	-- Export
	local b3 = addon:CreateButton(L["Export"], f.content)
	b3:SetPoint("RIGHT", b1, "LEFT", -10, 0)
	b3:SetScript("OnClick", function() self:ExportHistory() end)
	f.exportBtn = b3

	-- Import
	local b5 = addon:CreateButton("Import", f.content)
	b5:SetPoint("RIGHT", b3, "LEFT", -10, 0)
	b5:SetScript("OnClick", function()
		local importFrame = addon.UI:New("RCImportFrame")
		importFrame.label:SetText(L["Accepted imports: 'Player Export' and 'CSV'"])
		importFrame.edit:SetCallback("OnEnterPressed", function()
			addon.Log:D("Import data:", string.sub(importFrame.edit.data, 0, 50))
			self:ImportHistory(importFrame.edit.data)
			importFrame:Hide()
		end)
		importFrame:Show()
		importFrame.edit:SetFocus()
	end)
	f.importBtn = b5

	-- Filter
	local b4 = CreateFrame("DropdownButton", nil, f.content, "WowStyle1FilterDropdownTemplate")
	b4:SetPoint("TOPRIGHT", f.importBtn, "TOPLEFT", -10, 0)
	b4:SetPoint("BOTTOMLEFT", f.importBtn, "BOTTOMLEFT", -135, 0)
	b4:SetupMenu(self.CreateFilterMenu)
	b4.Text:SetHeight(25)
	-- b4:SetSize(125, 25) -- Needs extra convincing to stay at 25px height
	f.filter = b4

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
	sel:SetCallback("OnValueChanged", function(_, _, key)
		self.exportSelection = key
		db.defaultHistoryExport = key
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

	-- Set a proper width
	f:SetWidth(st.frame:GetWidth() + 20)
	return f;
end

--- Counts the number of items in a RCLootCouncil.HistoryDB database.
---@param db RCLootCouncil.HistoryDB
---@return number #The number of items in the db.
function LootHistory:CountItems(db)
	local total = 0
	for _, items in pairs(db or lootDB) do
		for _ in pairs(items) do
			total = total + 1
		end
	end
	return total
end

--- Returns a table of all the winners of an item.
-- @param item The item to check for.
-- @return A table which values are a numeric table of numLoot, name, class
function LootHistory:GetWinnersOfItem(item)
	local winners = {}
	local count = 1
	local ret = {}
	for name, items in pairs(lootDB) do
		for _, entry in pairs(items) do
			if addon:ItemIsItem(entry.lootWon, item) then
				if not winners[name] then
					winners[name] = count
					ret[count] = { 1, name, entry.class, }
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
	local data = lootDB[row.name][row.num]
	tip:AddLine(addon:GetClassIconAndColoredName(row.name, 16))
	tip:AddLine("")
	tip:AddDoubleLine(L["Time"] .. ":", (data.time or _G.UNKNOWN) .. " " .. row.date or _G.UNKNOWN, 1, 1, 1, 1, 1, 1)
	tip:AddDoubleLine(L["Loot won:"], data.lootWon or _G.UNKNOWN, 1, 1, 1, 1, 1, 1)
	if data.itemReplaced1 then
		tip:AddDoubleLine(L["Item(s) replaced:"], data.itemReplaced1, 1, 1, 1)
		if data.itemReplaced2 then
			tip:AddDoubleLine(" ", data.itemReplaced2)
		end
	end
	tip:AddDoubleLine(L["Dropped by:"], data.boss or _G.UNKNOWN, 1, 1, 1, 0.862745, 0.0784314, 0.235294)
	tip:AddDoubleLine(_G.FROM, data.instance or _G.UNKNOWN, 1, 1, 1, 0.823529, 0.411765, 0.117647)
	tip:AddDoubleLine(L["Original Owner"], addon:GetClassIconAndColoredName(data.owner), 1, 1, 1, 1, 1, 1)
	tip:AddDoubleLine(L["Votes"] .. ":", data.votes or _G.UNKNOWN, 1, 1, 1, 1, 1, 1)
	if data.note then
		tip:AddLine(" ")
		tip:AddDoubleLine(_G.LABEL_NOTE .. ":", data.note, 1, 1, 1, 1, 1, 1)
	end
	tip:AddLine(" ")
	tip:AddLine(L["Tokens received"])
	local tokensSorted = {}
	for n in pairs(moreInfoData[row.name].totals.tokens) do tinsert(tokensSorted, n) end
	table.sort(tokensSorted)
	-- Add tier tokens
	for _, instance in pairs(tokensSorted) do
		local num = moreInfoData[row.name].totals.tokens[instance]
		if num > 0 then
			tip:AddDoubleLine(instance .. ":", num, 1, 1, 1, 1, 1, 1)
		end
	end
	tip:AddLine(" ")
	tip:AddLine(L["Total awards"])
	table.sort(moreInfoData[row.name].totals.responses,
		function(a, b) return type(a[2]) == "number" and type(b[2]) == "number" and a[2] > b[2] or false end)
	for _, v in pairs(moreInfoData[row.name].totals.responses) do
		local r, g, b
		if v[3] then r, g, b = unpack(v[3], 1, 3) end
		tip:AddDoubleLine(v[1], v[2], r or 1, g or 1, b or 1, 1, 1, 1)
	end
	tip:AddDoubleLine(L["Number of raids received loot from:"], moreInfoData[row.name].totals.raids.num, 1, 1, 1, 1, 1, 1)
	tip:AddDoubleLine(L["Total items won:"], moreInfoData[row.name].totals.total, 1, 1, 1, 0, 1, 0)
	tip:AddLine(" ")

	-- Other recipient of the item
	local winners = self:GetWinnersOfItem(data.lootWon)
	table.sort(winners, function(a, b)
		return a[2] < b[2]
	end)
	tip:AddLine(format(L["lootHistory_moreInfo_winnersOfItem"], data.lootWon))
	for _, data in ipairs(winners) do
		local c = addon:GetClassColor(data[3])
		tip:AddDoubleLine(addon:GetClassIconAndColoredName(data[2]), data[1], c.r, c.g, c.b, 1, 1, 1)
	end

	-- Debug stuff
	if addon.debug then
		tip:AddLine("\nDebug:")
		tip:AddDoubleLine("ID:", tostring(data.id), 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine("ResponseID", tostring(data.responseID), 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine("Response:", data.response, 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine("isAwardReason:", tostring(data.isAwardReason), 1, 1, 1, 1, 1, 1)
		local r, g, b
		if data.color then r, g, b = unpack(data.color, 1, 3) end
		tip:AddDoubleLine("color:", data.color and (r .. ", " .. g .. ", " .. b) or "none", 1, 1, 1, r, g, b)
		tip:AddDoubleLine("DataIndex:", row.num, 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine("difficultyID:", data.difficultyID, 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine("mapID", data.mapID, 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine("groupSize", data.groupSize, 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine("tierToken", tostring(data.tierToken), 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine("tokenRoll", tostring(data.tokenRoll), 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine("relicRoll", tostring(data.relicRoll), 1, 1, 1, 1, 1, 1)
		tip:AddDoubleLine("typeCode", tostring(data.typeCode))
		tip:AddLine(" ")
		tip:AddDoubleLine("Total LootDB entries:", #self.frame.rows, 1, 1, 1, 0, 0, 1)
	end
	if moreInfo then
		tip:Show()
	else
		tip:Hide()
	end
	tip:SetAnchorType("ANCHOR_RIGHT", 0, -tip:GetHeight())
end

---@class RecordedResponseInfo
---@field text string
---@field color table|nil

--- Fetches all recorded Responses
--- @return table<typeCode, table<responseID, RecordedResponseInfo>> recordedResponses, table<responseID, RecordedResponseInfo> awardReasons
function LootHistory:GetRecordedResponses()
	local ret, awardReasons = {}, {}
	for _, items in pairs(lootDB) do
		for _, entry in pairs(items) do
			if entry.isAwardReason then
				awardReasons[entry.responseID] = {
					text = entry.response,
					color = entry.color,
				}
			else
				local typeCode = entry.typeCode or "default"
				if not ret[typeCode] then
					ret[typeCode] = {}
				end
				if not ret[typeCode][entry.responseID] then
					ret[typeCode][entry.responseID] = {
						text = entry.response,
						color = entry.color,
					}
				end
			end
		end
	end
	return ret, awardReasons
end

--- Fetches response info from either db, mldb, or recorded responses. In that order.
--- @return ResponseInfo
function LootHistory:GetResponseInfo(recordedResponses, typeCode, responseID)
	return db.responses[typeCode] and rawget(db.responses[typeCode], responseID)
		or addon.mldb.responses and addon.mldb.responses[typeCode] and rawget(addon.mldb.responses[typeCode], responseID)
		or recordedResponses[typeCode] and recordedResponses[typeCode][responseID]
end

---------------------------------------------------
-- Dropdowns.
-- @section Dropdowns.
---------------------------------------------------

--- Creates the filter menu for the loot history frame.
---@param owner DropdownButtonMixin
---@param menu RootMenuDescriptionProxy|SharedMenuDescriptionProxy This is techincally root
function LootHistory.CreateFilterMenu(owner, menu)
--#region class filter
	menu:CreateTitle(_G.FILTER)
	local classMenu = menu:CreateButton(_G.CLASS)

	local IsSelected = function(id) return not db.modules["RCLootHistory"].filters.class[id] end
	local SetSelected = function(id, value, a, b)
		addon.Log:D("Update class filter", id, value)
		db.modules["RCLootHistory"].filters.class[id] = not db.modules["RCLootHistory"].filters.class[id]
		local classFilters = false
		for _, v in pairs(db.modules["RCLootHistory"].filters.class) do
			if not v then
				classFilters = true
				break
			end
		end
		useClassFilters = classFilters
		LootHistory:Update()
	end

	for id, name in pairs(addon.classIDToDisplayName) do
		classMenu:CreateCheckbox(addon:WrapTextInClassColor(addon.classIDToFileName[id], name), IsSelected,
			SetSelected, id)
	end
	classMenu:CreateButton(_G.RESET, function()
		for k in pairs(db.modules["RCLootHistory"].filters.class) do
			db.modules["RCLootHistory"].filters.class[k] = true
		end
		useClassFilters = false
		LootHistory:Update()
		owner:Update()
	end)
	--#endregion
	--#region response filter
	--#region setup
	-- Build the data table:
	local data = { STATUS = true, BONUSROLL = true, AUTOPASS = true, PASS = true, }
	-- Select the typeCode with the most responses
	local recordedResponses, awardReasons = LootHistory:GetRecordedResponses()
	local maxResponses = 0
	for typeCode, _ in pairs(recordedResponses) do
		local c = TableUtil.SafeCountTable(recordedResponses[typeCode], true)
		if c > maxResponses then
			maxResponses = c
		end
	end

	local sortedTypeCodes = {}
	for typeCode in pairs(recordedResponses) do
		tinsert(sortedTypeCodes, typeCode)
	end
	table.sort(sortedTypeCodes, function(a, b)
		if a == "default" then return true end
		if b == "default" then return false end
		return a < b
	end)

	-- Also check our db just to ensure we have all responses covered, even if they haven't been used since the addon was installed (or if the user has cleaned up their loot history)
	for typeCode in pairs(db.responses) do
		local num = addon:GetNumButtons(typeCode)
		if num > maxResponses then
			maxResponses = num
		end
	end
	--#endregion setup
	local IsSelected = function(data)
		local filters = db.modules["RCLootHistory"].filters
		if data.isAwardReason then
			return filters.awardReasons[data.index]
		else
			return filters[data.typeCode][data.index]
		end
	end		
	---@param data {index:number, typeCode:string, isAwardReason:boolean}
	---@param ctx MenuInputData
	---@param proxy MenuProxy
	local SetSelected = function(data, ctx, proxy)
		local filters = db.modules["RCLootHistory"].filters
		if data.isAwardReason then
			filters.awardReasons[data.index] = not filters.awardReasons[data.index]
		else
			filters[data.typeCode][data.index] = not filters[data.typeCode][data.index]
		end
		LootHistory:Update()
		owner:Update()
	end
    for _, typeCode in ipairs(sortedTypeCodes) do
        -- data[typeCode] = true
        local subMenu = menu
        if typeCode == "default" then
            menu:CreateTitle(_G.DEFAULT)
        else
            subMenu = menu:CreateButton(addon.OPT_MORE_BUTTONS_VALUES[typeCode] or _G.UNKNOWN)
        end
        for i = 1, maxResponses do
            local response = LootHistory:GetResponseInfo(recordedResponses, typeCode, i)
            if response then
                local color = "|cff" .. addon.Utils:RGBToHex(unpack(response.color))
                local text = i .. ": " .. color .. response.text
                subMenu:CreateCheckbox(text, IsSelected, SetSelected,
                    { index = i, typeCode = typeCode, isAwardReason = false, })
            end
        end
        if typeCode == "default" then
            local text, color
            -- add the status codes
            for k in pairs(data) do
                if k == "STATUS" then
                    text = L["Status texts"]
                    color = "|cffde34e2" -- purpleish
                else
                    text = addon:GetResponse("default", k).text
                    color = "|cff" .. addon.Utils:RGBToHex(addon:GetResponseColor(nil, k))
                end
                subMenu:CreateCheckbox(color .. text, IsSelected, SetSelected,
                    { index = k, typeCode = "default", isAwardReason = false, })
            end
        end
    end
	if #awardReasons > 0 then
		local ar = menu:CreateButton("|cffffff00"..L["Award Reasons"])
		-- Create award reasons
		for i, v in pairs(awardReasons) do
			local color = "|cff" .. addon.Utils:RGBToHex(unpack(v.color))
			local text = i .. ": " .. color .. v.text
			ar:CreateCheckbox(text, IsSelected, SetSelected, { index = i, typeCode = nil, isAwardReason = true, })
		end
	end
	menu:CreateDivider()
	-- Clear filter
	menu:CreateButton(_G.RESET, function()
		for k, v in pairs(db.modules["RCLootHistory"].filters) do
			if k ~= "class" then
				db.modules["RCLootHistory"].filters[k] = nil
			end
		end
		LootHistory:Update()
		owner:Update()
	end)
	--#endregion response filter
end

--- Creates right click menu
---@param rowFrame Frame
---@param root RootMenuDescriptionProxy|SharedMenuDescriptionProxy This is techincally root
function LootHistory.CreateRightClickMenu(rowFrame, root)
	---@type HistoryDataRow
	local rowData = rowFrame.data

	root:CreateTitle(L["Edit Entry"])
	local nameMenu = root:CreateButton(_G.NAME)
	nameMenu:SetScrollMode(400)
	local responseMenu = root:CreateButton(L["Response"])

	--#region Name menu
	--- @param data {to:string,class:ClassInfo.classFile, row:HistoryDataRow}
	local ChangeRecipient = function(data, menuInput, proxy)
		local row, fromName, fromNum = data.row, data.row.name, data.row.num
		if fromName == data.to then return end

		addon.Log:D("Moving award from", fromName, "to", data.to)
		local sourceItems = lootDB[fromName]
		local entry = sourceItems and tremove(sourceItems, fromNum)
		if not entry then return addon.Log:E("Unable to find history entry", fromName, fromNum) end
		if #sourceItems == 0 then lootDB[fromName] = nil end

		if not lootDB[data.to] then lootDB[data.to] = {} end
		tinsert(lootDB[data.to], entry)
		entry.class = data.class

		-- Removing the entry shifts all later source indices, so keep the remaining rows in sync.
		for _, displayedRow in ipairs(LootHistory.frame.st.data) do
			if displayedRow ~= row and displayedRow.name == fromName and displayedRow.num > fromNum then
				displayedRow.num = displayedRow.num - 1
			end
		end

		row.name = data.to
		row.num = #lootDB[data.to]
		row.class = data.class
		row.cols[1].args[1] = data.class
		row.cols[2] = { value = addon.Ambiguate(data.to), color = addon:GetClassColor(data.class), }
		LootHistory.frame.st:SortData()
		moreInfoData = addon:GetLootDBStatistics()
		addon:SendMessage("RCHistory_NameEdit", data.row)
	end

	local name, color, text
	local names = CopyTable(LootHistory.frame.name.data)
	table.sort(names, function(a, b)
		return a[2].value < b[2].value
	end)
	for _, v in ipairs(names) do
		name = v[2].value
		color = v[2].color
		text = color:WrapTextInColorCode(name)
		nameMenu:CreateButton(text, ChangeRecipient, { to = v[2].name, class = v[1].args[1], row = rowData, })
	end
	--#endregion Name menu
	--#region Response menu
	--- @param data {to:number, row:HistoryDataRow, typeCode:string, isAwardReason:boolean?}
	local ChangeResponse = function(data, menuInput, proxy)
		addon.Log:D("Changing response id @", data.row.name, "from", data.row.response, "to", data.to)
		local entry = lootDB[data.row.name][data.row.num]
		if not data.isAwardReason then
			entry.response = addon:GetResponse(data.typeCode, data.to).text
			entry.color = { addon:GetResponseColor(data.typeCode, data.to), }
		else
			entry.response = db.awardReasons[data.to].text
			entry.color = { unpack(db.awardReasons[data.to].color), }
		end
		entry.responseID = data.to
		entry.isAwardReason = data.isAwardReason or false
		entry.tokenRoll = nil
		entry.relicRoll = nil
		entry.typeCode = data.typeCode
		data.row.response = data.to
		data.row.isAwardReason = data.isAwardReason or false
		data.row.cols[6].args = { color = entry.color, response = entry.response, responseID = data.to, }
		LootHistory.frame.st:SortData()
		moreInfoData = addon:GetLootDBStatistics()
		addon:SendMessage("RCHistory_ResponseEdit", data.row)
	end

	-- Defaults first, as they don't get a submenu, and are the most common responses.
	do
		responseMenu:CreateTitle(_G.DEFAULT)
		local v
		for i = 1, db.buttons.default.numButtons do
			v = db.responses.default[i]
			responseMenu:CreateButton(i .. ": " .. addon.Utils:ColorTableToColor(v.color):WrapTextInColorCode(v.text),
				ChangeResponse,
				{ to = i, row = rowData, typeCode = "default", })
		end
		responseMenu:CreateDivider()
	end
	-- Then the rest, based on which buttons are enabled
	for k, v in pairs(db.responses) do
		if k ~= "default" and k ~= "*" and #v > 0 then
			local menu = responseMenu:CreateButton(addon.OPT_MORE_BUTTONS_VALUES[k] or _G.UNKNOWN)
			for i = 1, #v do
				menu:CreateButton(i .. ": " .. addon.Utils:ColorTableToColor(v[i].color):WrapTextInColorCode(v[i].text),
					ChangeResponse, { to = i, row = rowData, typeCode = k, })
			end
		end
	end
	-- Next award reasons
	if db.numAwardReasons > 0 then
		local menu = responseMenu:CreateButton(L["Award Reasons"])
		for k, v in ipairs(db.awardReasons) do
			if k > db.numAwardReasons then break end
			menu:CreateButton(k .. ": " .. addon.Utils:ColorTableToColor(v.color):WrapTextInColorCode(v.text),
				ChangeResponse, { to = k, row = rowData, typeCode = nil, isAwardReason = true, })
		end
	end
	-- Finally show all "special" responses in debug mode
	if addon.debug then
		responseMenu:CreateDivider()
		local menu = responseMenu:CreateButton("Debug")
		for k, v in pairs(db.responses.default) do
			if type(k) ~= "number" then
				menu:CreateButton(addon.Utils:ColorTableToColor(v.color):WrapTextInColorCode(v.text), ChangeResponse,
					{ to = k, row = rowData, typeCode = "default", })
			end
		end
	end
	--#endregion Response menu
end

---------------------------------------------------------------
-- Exports.
-- REVIEW A lot of optimizations can be done here.
-- @section Exports.
---------------------------------------------------------------
do
	local export, ret = {}, {}

	local function CSVEscape(s)
		s = tostring(s or "")
		if s:find(",") then
			-- Escape double quote in the string and enclose string that can contains comma by double quote
			return "\"" .. gsub(s, "\"", "\"\"") .. "\""
		else
			return s
		end
	end

	local function QuotesEscape(s)
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
		tinsert(ret,
			"player,date,time,id,item,itemID,itemString,response,votes,class,instance,boss,difficultyID,mapID,groupSize,gear1,gear2,responseID,isAwardReason,subType,equipLoc,note,owner\r\n")
		for player, v in pairs(self:GetFilteredDB()) do
			for _, d in pairs(v) do
				_, _, subType, equipLoc = C_Item.GetItemInfoInstant(d.lootWon)
				if d.tierToken then subType = L["Armor Token"] end
				-- We might have commas in various things here :/
				tinsert(export, tostring(player))
				tinsert(export, tostring(d.date))
				tinsert(export, tostring(d.time))
				tinsert(export, tostring(d.id))
				tinsert(export, CSVEscape(d.lootWon))
				tinsert(export, ItemUtils:GetItemIDFromLink(d.lootWon))
				tinsert(export, ItemUtils:GetItemStringFromLink(d.lootWon))
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

	--- TSV for Google Sheets and English Excel versions.
	function LootHistory:ExportGoogleSheets()
		return self:ExportTSV(";")
	end

	--- TSV (Tab Seperated Values) for Excel
	--- Made specificly with excel in mind, but might work with other spreadsheets
	---@param formulaDelimiter ","|";" Delimiter to use in hyperlink formula. Defaults to ",".
	function LootHistory:ExportTSV(formulaDelimiter)
		formulaDelimiter = formulaDelimiter or ","
		-- Add headers
		wipe(export)
		wipe(ret)
		local subType, equipLoc, rollType
		tinsert(ret,
			"player\tdate\ttime\titem\titemID\titemString\tresponse\tvotes\tclass\tinstance\tboss\tgear1\tgear2\tresponseID\tisAwardReason\trollType\tsubType\tequipLoc\tnote\towner\r\n")
		for player, v in pairs(self:GetFilteredDB()) do
			for _, d in pairs(v) do
				_, _, subType, equipLoc = C_Item.GetItemInfoInstant(d.lootWon)
				if d.tierToken then subType = L["Armor Token"] end
				rollType = (d.tokenRoll and "token") or (d.relicRoll and "relic") or "normal"
				tinsert(export, tostring(player))
				tinsert(export, tostring(d.date))
				tinsert(export, tostring(d.time))
				tinsert(export,
					table.concat { "=HYPERLINK(\"", self:GetWowheadLinkFromItemLink(d.lootWon), "\"", formulaDelimiter, "\"", tostring(d.lootWon), "\")", } or
					"")
				tinsert(export, ItemUtils:GetItemIDFromLink(d.lootWon))
				tinsert(export, ItemUtils:GetItemStringFromLink(d.lootWon))
				tinsert(export, tostring(d.response))
				tinsert(export, tostring(d.votes))
				tinsert(export, tostring(d.class))
				tinsert(export, tostring(d.instance))
				tinsert(export, tostring(d.boss))
				tinsert(export,
					d.itemReplaced1 and
					table.concat { "=HYPERLINK(\"", self:GetWowheadLinkFromItemLink(tostring(d.itemReplaced1)), "\"", formulaDelimiter, "\"", tostring(d.itemReplaced1), "\")", } or
					"")
				tinsert(export,
					d.itemReplaced2 and
					table.concat { "=HYPERLINK(\"", self:GetWowheadLinkFromItemLink(tostring(d.itemReplaced2)), "\"", formulaDelimiter, "\"", tostring(d.itemReplaced2), "\")", } or
					"")
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

		local filteredDb = self:GetFilteredDB()
		for _, v in pairs(filteredDb) do
			for _ in pairs(v) do
				eligibleEntries = eligibleEntries + 1;
			end
		end

		local processedEntries = 0;

		for player, v in pairs(filteredDb) do
			for _, d in pairs(v) do
				_, _, subType, equipLoc = C_Item.GetItemInfoInstant(d.lootWon)
				if d.tierToken then subType = L["Armor Token"] end
				rollType = (d.tokenRoll and "token") or (d.relicRoll and "relic") or "normal"
				tinsert(export, string.format("\"%s\":\"%s\"", "player", tostring(player)))
				tinsert(export, string.format("\"%s\":\"%s\"", "date", tostring(d.date)))
				tinsert(export, string.format("\"%s\":\"%s\"", "time", tostring(d.time)))
				tinsert(export, string.format("\"%s\":\"%s\"", "id", tostring(d.id)))
				tinsert(export, string.format("\"%s\":%s", "itemID", ItemUtils:GetItemIDFromLink(d.lootWon)))
				tinsert(export, string.format("\"%s\":\"%s\"", "itemString", ItemUtils:GetItemStringFromLink(d.lootWon)))
				tinsert(export, string.format("\"%s\":\"%s\"", "response", QuotesEscape(d.response)))
				tinsert(export, string.format("\"%s\":%s", "votes", tostring(d.votes or 0)))
				tinsert(export, string.format("\"%s\":\"%s\"", "class", tostring(d.class)))
				tinsert(export, string.format("\"%s\":\"%s\"", "instance", QuotesEscape(d.instance)))
				tinsert(export, string.format("\"%s\":\"%s\"", "boss", QuotesEscape(d.boss)))
				tinsert(export, string.format("\"%s\":\"%s\"", "gear1", QuotesEscape(d.itemReplaced1)))
				tinsert(export, string.format("\"%s\":\"%s\"", "gear2", QuotesEscape(d.itemReplaced2)))
				tinsert(export, string.format("\"%s\":\"%s\"", "responseID", d.responseID))
				tinsert(export, string.format("\"%s\":\"%s\"", "isAwardReason", tostring(d.isAwardReason or false)))
				tinsert(export, string.format("\"%s\":\"%s\"", "rollType", rollType))
				tinsert(export, string.format("\"%s\":\"%s\"", "subType", tostring(subType)))
				tinsert(export, string.format("\"%s\":\"%s\"", "equipLoc", tostring(getglobal(equipLoc) or "")))
				tinsert(export, string.format("\"%s\":\"%s\"", "note", QuotesEscape(d.note)))
				tinsert(export, string.format("\"%s\":\"%s\"", "owner", tostring(d.owner or "Unknown")))
				tinsert(export,
					string.format("\"%s\":\"%s\"", "itemName", QuotesEscape(ItemUtils:GetItemNameFromLink(d.lootWon))))
				tinsert(export, string.format("\"%s\":\"%s\"", "servertime", (strsplit("-", d.id, 2))))

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
			tinsert(export, "[b]" .. addon.Ambiguate(player) .. ":[/b]\r\n")
			tinsert(export, "[list=1]")
			local first = true
			for _, d in pairs(v) do
				if first then
					first = false
				else
					tinsert(export, "[*]")
				end
				tinsert(export, "[url=" .. self:GetWowheadLinkFromItemLink(d.lootWon) .. "]" .. d.lootWon .. "[/url]"
					.. " Response: " .. tostring(d.response) .. ".\r\n")
			end
			tinsert(export, "[/list]\r\n\r\n")
		end
		return table.concat(export)
	end

	--- BBCode, as supported by SMF
	function LootHistory:ExportBBCodeSMF()
		wipe(export)
		for player, v in pairs(self:GetFilteredDB()) do
			tinsert(export, "[b]" .. addon.Ambiguate(player) .. ":[/b]\r\n")
			tinsert(export, "[list]")
			for _, d in pairs(v) do
				tinsert(export, "[*]")
				tinsert(export, "[url=" .. self:GetWowheadLinkFromItemLink(d.lootWon) .. "]" .. d.lootWon .. "[/url]")
				tinsert(export, " Response: " .. tostring(d.response) .. ".\r\n")
			end
			tinsert(export, "[/list]\r\n\r\n")
		end
		return table.concat(export)
	end

	--- EQdkp Plus XML, primarily for Enjin import
	function LootHistory:ExportEQXML()
		local export = "<raidlog><head><export><name>EQdkp Plus XML</name><version>1.0</version></export>"
			.. "<tracker><name>RCLootCouncil</name><version>" .. addon.version .. "</version></tracker>"
			..
			"<gameinfo><game>World of Warcraft</game><language>" ..
			GetLocale() .. "</language><charactername>" .. UnitName("Player") .. "</charactername></gameinfo></head>\r\n"
			.. "<raiddata>\r\n"
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
				local year, month, day = addon.Utils:DateSplit(d.date)
				local hour, minute, second = strsplit(":", d.time, 3)
				local sinceEpoch = time({ year = year, month = month, day = day, hour = hour, min = minute, sec = second, })
				itemsData = itemsData .. "\t\t<item>\r\n"
					.. "\t\t\t<itemid>" .. ItemUtils:GetItemStringClean(d.lootWon) .. "</itemid>\r\n"
					.. "\t\t\t<name>" .. ItemUtils:GetItemNameFromLink(d.lootWon) .. "</name>\r\n"
					.. "\t\t\t<member>" .. addon.Ambiguate(player) .. "</member>\r\n"
					.. "\t\t\t<time>" .. sinceEpoch .. "</time>\r\n"
					.. "\t\t\t<count>1</count>\r\n"
					.. "\t\t\t<cost>" .. tostring(d.votes) .. "</cost>\r\n"
					.. "\t\t\t<note>" .. tostring(d.response) .. "</note>\r\n"
				membersData[addon.Ambiguate(player)] = true

				local boss = gsub(tostring(d.boss), ",", "")
				itemsData = itemsData .. (boss and "\t\t\t<boss>" .. boss .. "</boss>\r\n" or "\t\t\t<boss />\r\n")

				if d.instance then
					itemsData = itemsData .. "\t\t\t<zone>" .. gsub(tostring(d.instance), ",", "") .. "</zone>\r\n"
					raidData[time({ year = year, month = month, day = day, })] = gsub(tostring(d.instance), ",", "")
				else
					itemsData = itemsData .. "\t\t\t<zone />\r\n"
				end
				itemsData = itemsData .. "\t\t</item>\r\n"

				if not bossesAdded[boss] then
					bossesAdded[boss] = true
					bossData = bossData .. "\t\t<bosskill>\r\n"
					bossData = bossData ..
						(boss and "\t\t\t<name>" .. boss .. "</name>\r\n" or "\t\t\t<name>Unknown</name>\r\n")
					bossData = bossData .. (d.instance and "\t\t\t<time>" .. sinceEpoch .. "</time>\r\n" or "")
					bossData = bossData .. "\t\t</bosskill>\r\n"
				end
				latest = max(latest, sinceEpoch + 600)
			end
		end
		bossData = bossData .. "\t</bosskills>\r\n"
		for id, name in pairs(raidData) do
			zoneData = zoneData .. "\t\t<zone>\r\n"
				.. "\t\t\t<enter>" .. id .. "</enter>\r\n"
				.. "\t\t\t<name>" .. name .. "</name>\r\n"
				.. "\t\t\t<leave>" .. latest .. "</leave>\r\n"
				.. "\t\t</zone>\r\n"
			earliest = min(earliest, id)
		end
		zoneData = zoneData .. "\t</zones>\r\n"
		itemsData = itemsData .. "\t</items>\r\n"
		export = export .. zoneData .. bossData .. itemsData
			.. "\t<members>\r\n"
		for name in pairs(membersData) do
			export = export .. "\t\t<member>\r\n"
				.. "\t\t\t<name>" .. name .. "</name>\r\n"
				.. "\t\t\t<times>\r\n"
				.. "\t\t\t\t<time type='join'>" .. earliest .. "</time>\r\n"
				.. "\t\t\t\t<time type='leave'>" .. latest .. "</time>\r\n"
				.. "\t\t\t</times>\r\n"
				.. "\t\t</member>\r\n"
		end
		export = export .. "\t</members>\r\n</raiddata></raidlog>\r\n"
		return export
	end

	--- Discord friendly output
	function LootHistory:ExportDiscord()
		wipe(export)
		for player, v in pairs(self:GetFilteredDB()) do
			tinsert(export, "__ **")
			tinsert(export, addon.Ambiguate(player))
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

--- Old player export without the new sessionData field.
	function LootHistory:PlayerExport()
		local his = CopyTable(lootDB)
		for _, v in pairs(his) do
			for _, d in pairs(v) do
				d.sessionData = nil
			end
		end
		return self:EscapeItemLink(self:Serialize(his))
	end

	--- Generates a serialized string containing the entire DB.
	--- For now it needs to be copied and pasted in another player's import field.
	--- Note: v3.23: Will become the default in the future
	function LootHistory:PlayerExportNew()
		return self:EscapeItemLink(self:Serialize(lootDB))
	end
end
