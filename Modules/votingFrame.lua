---	votingFrame.lua Displays everything related to handling loot for all members.
--	Will only show certain aspects depending on addon.isMasterLooter, addon.isCouncil and addon.mldb.observe.
-- DefaultModule
-- @author	Potdisc
-- Create Date : 12/15/2014 8:54:35 PM
--[[ Comms:
	MAIN:
		vote					T - Councilmember sends vote.
		change_response 	T - ML changes a response.
		lootAck 				T - Candidate sends lootAck.
		awarded 				T - ML has awarded an item.
		bagged 				T - ML has bagged an item (award later).
		offline_timer 		T - ML sends offline timer.
		response 			T - Candidate sends a response.
		rolls 				T - ML sends random rolls info.
		roll 					T - Candidate sends roll info.
		reconnectData 		T - ML sends reconnectData.
		n_t					T - Candidate received "non-tradeable" loot.
		r_t					T - Candidate "rejected_trade" of loot.
]]
---@type RCLootCouncil
local _,addon = ...
local RCVotingFrame = addon:NewModule("RCVotingFrame", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
local LibDialog = LibStub("LibDialog-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local Comms = addon.Require "Services.Comms"
local Council = addon.Require "Data.Council"
---@type Data.Player
local Player = addon.Require "Data.Player"
---@type Utils.TempTable
local TempTable = addon.Require "Utils.TempTable"
---@type Services.ErrorHandler
local ErrorHandler = addon.Require "Services.ErrorHandler"

local ROW_HEIGHT = 20;
local NUM_ROWS = 15;
local db
local session = 1 -- The session we're viewing - see :GetCurrentSession()
local lootTable = {} -- Table containing all data, lib-st cells pulls data from this
local sessionButtons = {}
local moreInfo = false -- Show more info frame?
local active = false -- Are we currently in session?
local menuFrame -- Right click menu frame
local filterMenu -- Filter drop down menu
local enchanters -- Enchanters drop down menu frame
local guildRanks = {} -- returned from addon:GetGuildRanks()
local GuildRankSort, ResponseSort -- Initialize now to avoid errors
local defaultScrollTableData = {} -- See below
local moreInfoData = {}
local MIN_UPDATE_INTERVAL = 0.2 -- Minimum update interval
local noUpdateTimeRemaining = 0 -- The time until we allow the next update.
local updateFrame = CreateFrame("FRAME") -- to ensure the update operations that does not occur, because it's within min update interval, gets updated eventually
local needUpdate = false -- Does voting frame needs an update after MIN_UPDATE_INTERVAL after the last update?
local PREFIX = addon.PREFIXES.MAIN
local subscriptions = {}

function RCVotingFrame:OnInitialize()
	-- Contains all the default data needed for the scroll table
	-- The default values are in sorted order
	defaultScrollTableData = {
		{ name = "",				DoCellUpdate = RCVotingFrame.SetCellClass,		colName = "class",	sortnext = 2,		width = 20, },										-- 1 Class
		{ name = _G.NAME,			DoCellUpdate = RCVotingFrame.SetCellName,			colName = "name",		defaultsort = 1,	width = 120,},									-- 2 Candidate Name
		{ name = _G.RANK,			DoCellUpdate = RCVotingFrame.SetCellRank,			colName = "rank",		sortnext = 5,		width = 95, comparesort = GuildRankSort,},-- 3 Guild rank
		{ name = _G.ROLE,			DoCellUpdate = RCVotingFrame.SetCellRole,			colName = "role",		sortnext = 5,		width = 55, },										-- 4 Role
		{ name = L["Response"],	DoCellUpdate = RCVotingFrame.SetCellResponse,	colName = "response",sortnext = 13,		width = 240, comparesort = ResponseSort,},-- 5 Response
		{ name = _G.ITEM_LEVEL_ABBR,DoCellUpdate = RCVotingFrame.SetCellIlvl,	colName = "ilvl",		sortnext = 7,		width = 45, },										-- 6 Total ilvl
		{ name = L["Diff"],		DoCellUpdate = RCVotingFrame.SetCellDiff,			colName = "diff",								width = 40, },										-- 7 ilvl difference
		{ name = L["g1"],			DoCellUpdate = RCVotingFrame.SetCellGear,			colName = "gear1",	sortnext = 5,		width = 20, align = "CENTER", },				-- 8 Current gear 1
		{ name = L["g2"],			DoCellUpdate = RCVotingFrame.SetCellGear,			colName = "gear2",	sortnext = 5,		width = 20, align = "CENTER", },				-- 9 Current gear 2
		{ name = L["Votes"], 	DoCellUpdate = RCVotingFrame.SetCellVotes,		colName = "votes",	sortnext = 7,		width = 50, align = "CENTER", },				-- 10 Number of votes
		{ name = L["Vote"],		DoCellUpdate = RCVotingFrame.SetCellVote,			colName = "vote",		sortnext = 10,		width = 60, align = "CENTER", },				-- 11 Vote button
		{ name = L["Notes"],		DoCellUpdate = RCVotingFrame.SetCellNote,			colName = "note",								width = 50, align = "CENTER", },				-- 12 Note icon
		{ name = _G.ROLL,			DoCellUpdate = RCVotingFrame.SetCellRoll, 		colName = "roll",		sortnext = 10,		width = 50, align = "CENTER", },				-- 13 Roll
		-- { name = "",				DoCellUpdate = RCVotingFrame.SetCellCorruption, colName = "corruption", sortnext = 10, width = 30, align = "CENTER",},				-- 14 Corruption (Patch 8.3)
	}
	-- The actual table being worked on, new entries should be added to this table "tinsert(RCVotingFrame.scrollCols, data)"
	-- If you want to add or remove columns, you should do so on your OnInitialize. See RCVotingFrame:RemoveColumn() for removal.
	self.scrollCols = {unpack(defaultScrollTableData)}
	self.nonTradeablesButtons = {}

	menuFrame = _G.MSA_DropDownMenu_Create("RCLootCouncil_VotingFrame_RightclickMenu", UIParent)
	filterMenu = _G.MSA_DropDownMenu_Create("RCLootCouncil_VotingFrame_FilterMenu", UIParent)
	enchanters = _G.MSA_DropDownMenu_Create("RCLootCouncil_VotingFrame_EnchantersMenu", UIParent)
	_G.MSA_DropDownMenu_Initialize(menuFrame, self.RightClickMenu, "MENU")
	_G.MSA_DropDownMenu_Initialize(filterMenu, self.FilterMenu)
	_G.MSA_DropDownMenu_Initialize(enchanters, self.EnchantersMenu)
end

function RCVotingFrame:OnEnable()
	self:RegisterComms()
	self:RegisterBucketEvent({"UNIT_PHASE", "ZONE_CHANGED_NEW_AREA"}, 1, "Update") -- Update "Out of instance" text when any raid members change zone
	self:RegisterMessage("RCLootStatusReceived", "UpdateLootStatus")
	self:RegisterMessage("RCLootTableAdditionsReceived", "OnLootTableAdditionsReceived")
	db = addon:Getdb()
	--active = true
	moreInfo = db.modules["RCVotingFrame"].moreInfo
	moreInfoData = addon:GetLootDBStatistics()
	self:UpdateItemAwardHistory()
	self.frame = self:GetFrame()
	guildRanks = addon:GetGuildRanks()
	addon.Log("RCVotingFrame", "enabled")
	updateFrame:Show()
	needUpdate = false
	noUpdateTimeRemaining = 0
	self.numNonTradeables = 0
end

function RCVotingFrame:OnDisable() -- We never really call this
	self:Hide()
	self.frame:SetParent(nil)
	self.frame = nil
	wipe(addon.lootStatus)
	wipe(lootTable)
	active = false
	session = 1
	updateFrame:Hide()
	needUpdate = false
	noUpdateTimeRemaining = 0
	self.numNonTradeables = 0
	for _,sub in ipairs(subscriptions) do
		sub:unsubscribe()
	end
end

function RCVotingFrame:RegisterComms ()
	subscriptions = Comms:BulkSubscribe(PREFIX, {
		vote = function (data, sender)
			if Council:Contains(Player:Get(sender)) then
				self:HandleVote(sender, unpack(data))
			else
				addon.Log:W("Non-council member (".. tostring(sender) .. ") sent a vote!")
			end
		end,
		change_response = function (data, sender)
			if addon:IsMasterLooter(sender) then
				self:OnChangeResponseReceived(unpack(data))
			end
		end,
		lootAck = function (data, sender)
			self:OnLootAckReceived(sender, unpack(data))
		end,
		awarded = function (data, sender)
			if addon:IsMasterLooter(sender) then
				self:OnAwardedReceived(unpack(data))
			end
		end,
		bagged = function (data, sender)
			if addon:IsMasterLooter(sender) then
				self:OnBaggedReceived(unpack(data))
			end
		end,
		offline_timer = function (_, sender)
			if addon:IsMasterLooter(sender) then
				self:OnOfflineTimerReceived()
			end
		end,
		response = function (data, sender)
			self:OnResponseReceived(sender, unpack(data))
		end,
		rolls = function (data, sender)
			if addon:IsMasterLooter(sender) then
				self:OnRollsReceived(unpack(data))
			else
				addon.Log:W("Non-ML", sender, "sent rolls!")
			end
		end,
		roll = function (data, sender)
			self:OnRollReceived(unpack(data))
		end,
		reconnectData = function (data, sender)
			if addon:IsMasterLooter(sender) then
				self:OnReconnectReceived(unpack(data))
			end
		end,
		n_t = function (data, sender)
			self:AddNonTradeable(sender, "not_tradeable", unpack(data))
		end,
		r_t = function (data, sender)
			self:AddNonTradeable(sender, "rejected_trade", unpack(data))
		end,
	})
end

function RCVotingFrame:Hide()
	addon.Log("Hide VotingFrame")
	self.frame.moreInfo:Hide()
	self.frame:Hide()
end

function RCVotingFrame:Show()
	if self.frame and lootTable[session] then
		if self:HasUnawardedItems() then active = true end
		self.frame:Show()
		self:SwitchSession(session)
	else
		addon:Print(L["No session running"])
	end
end

function RCVotingFrame:HasUnawardedItems ()
	for _,v in pairs(lootTable) do
		if not v.awarded then return true end
	end
	return false
end

function RCVotingFrame:ReceiveLootTable(lt)
	self:HideNonTradeables()
	self.numNonTradeables = 0
	for _,v in ipairs(addon.nonTradeables) do -- We might have received some before getting the lootTable
		self:AddNonTradeable(v.owner, v.reason, v.link)
	end
	active = true
	lootTable = CopyTable(lt)
	self:Setup(lootTable)
	self:UpdateItemAwardHistory()
	if not addon.enabled then return end -- We just want things ready
	if db.autoOpen then
		self:Show()
	else
		addon:Print(L["A new session has begun, type '/rc open' to open the voting frame."])
	end
end

function RCVotingFrame:EndSession(hide)
	if active then -- Only end session once
		addon.Log:D("RCVotingFrame:EndSession", hide)
		active = false -- The session has ended, so deactivate
		self:Update(true)
		if hide then self:Hide() end -- Hide if need be
	end
end

--- Removes a specific entry from the voting frame's columns
-- Takes either index or colName as the identifier, and returns the removed rows
-- if succesful, or nil if not. Should be called before any session begins.
function RCVotingFrame:RemoveColumn(id)
	addon.Log:D("Removing Column", id)
	local removedCol, removedIndex
	if type(id) == "number" then
		removedIndex = id
		removedCol = tremove(self.scrollCols, id)
	else
		removedIndex = self:GetColumnIndexFromName(id)
		assert(removedIndex, "ID is not a valid column name")
		removedCol = tremove(self.scrollCols, removedIndex)
	end
	-- Fix sortnext as they could be broken with the removal
	if removedCol then
		for _,col in ipairs(self.scrollCols) do
			if col.sortnext and col.sortnext > removedIndex then
				col.sortnext = col.sortnext - 1
			end
		end
		return removedCol
	end
end

function RCVotingFrame:GetColumnIndexFromName (name)
	for i,v in ipairs(self.scrollCols) do
      if v.colName == name then
         return i
      end
   end
end

-- Getter/Setter for candidate data
-- Handles errors
function RCVotingFrame:SetCandidateData(session, candidate, data, val)
	local function Set(session, candidate, data, val) -- luacheck: ignore
		lootTable[session].candidates[candidate][data] = val
	end
	local ok, arg = pcall(Set, session, candidate, data, val)
	if not ok then addon.Log:W("Error in 'SetCandidateData':", arg, session, candidate, data, val) end
end

function RCVotingFrame:GetCandidateData(session, candidate, data)
	local function Get(session, candidate, data) -- luacheck: ignore
		return lootTable[session].candidates[candidate][data]
	end
	local ok, arg = pcall(Get, session, candidate, data)
	if not ok then addon.Log:W("Error in 'GetCandidateData':", arg, session, candidate, data)
	else return arg end
end

-- TODO: DEPRECATED - use RCLootCouncil:GetLootTable()
-- REVIEW: This is not in sync with the replacement.
function RCVotingFrame:GetLootTable()
	return lootTable
end

--- Returns the session the user is currently viewing
-- If you want to get the session when it changes, these AceEvent messages are available:
-- "RCSessionChangedPre"	- Delivered before :SwitchSession() is executed, i.e before :GetCurrentSession() is updated.
-- "RCSessionChangedPost"	- Dilvered after :SwitchSession() is executed.
-- @usage RCLootCouncil:RegisterMessage("RCSessionChangedPost", --your_function--) (see AceEvent-3.0 for more.)
function RCVotingFrame:GetCurrentSession()
	return session
end

--- Find an unawarded session.
-- @return number|nil Number of the first session with an un-awarded item, or nil if everything is awarded.
function RCVotingFrame:FetchUnawardedSession ()
	for k,v in ipairs(lootTable) do
		if not v.awarded then return k end
	end
	return nil
end

function RCVotingFrame:SetupSession(session, t)
	t.added = true -- This entry has been initiated
	t.haveVoted = false -- Have we voted for ANY candidate in this session?
	t.candidates = {}
	for name in addon:GroupIterator() do
		local player = Player:Get(name)
		-- REVIEW Seems like we occasionally get wrong/invalid names here.
		-- but we still need to create the candidate, so use the name provided by 
		-- GroupIterator, which should be the same as the one from `Player`.
		name = player and player.name or name
		t.candidates[name] = {
			class = player.class or "Unknown",
			rank = player.rank or "Unknown",
			role = player.role or "NONE",
			response = "ANNOUNCED",
			ilvl = "",
			diff = "",
			gear1 = nil,
			gear2 = nil,
			votes = 0,
			note = nil,
			roll = nil,
			voters = {},
			haveVoted = false, -- Have we voted for this particular candidate in this session?
		}
	end
	-- Init session toggle
	sessionButtons[session] = self:UpdateSessionButton(session, t.texture, t.link, t.awarded)
	sessionButtons[session]:Show()
end

function RCVotingFrame:Setup(table)
	--lootTable[session] = {bagged, lootSlot, awarded, name, link, quality, ilvl, type, subType, equipLoc, texture, boe}
	for session, t in ipairs(table) do -- and build the rest (candidates)
		if not t.added then
			self:SetupSession(session, t)
		end
	end
	-- Hide unused session buttons
	for i = #lootTable+1, #sessionButtons do
		sessionButtons[i]:Hide()
	end
	session = 1
	self:BuildST()
	self:SwitchSession(session)
	if addon.isMasterLooter and db.autoAddRolls then
		self:DoAllRandomRolls()
	end
end

function RCVotingFrame:HandleVote(voter, session, name, vote)
	if not (lootTable[session] and lootTable[session].candidates[name]) then return end
	voter = addon:UnitName(voter)
	-- Do the vote
	lootTable[session].candidates[name].votes = lootTable[session].candidates[name].votes + vote
	-- And update voters names
	if vote == 1 then
		tinsert(lootTable[session].candidates[name].voters, voter)
	else
		tDeleteItem(lootTable[session].candidates[name].voters, voter)
	end
	self.frame.st:Refresh()
	self:UpdatePeopleToVote()
end

-- Get rolls ranged from 1 to 100 for all candidates, and guarantee everyone's roll is different.
function RCVotingFrame:GenerateNoRepeatRollTable(ses)
	local rolls = {}
	for i = 1, 100 do
		rolls[i] = i
	end

	local t = {}
	for name, _ in pairs(lootTable[ses].candidates) do
		if #rolls > 0 then
			local i = math.random(#rolls)
			t[name] = rolls[i]
			tremove(rolls, i)
		else -- We have more than 100 candidates !?!?
			t[name] = 0
		end
	end
	return t
end

function RCVotingFrame:DoRandomRolls(ses)
	local table = self:GenerateNoRepeatRollTable(ses)
	for k, v in ipairs(lootTable) do
		if addon:ItemIsItem(lootTable[ses].link, v.link) then
			addon:Send("group", "rolls", k, table)
		end
	end
end

function RCVotingFrame:DoAllRandomRolls()
	local sessionsDone = {}

	for ses, t in ipairs(lootTable) do
		if not sessionsDone[ses] and not t.isRoll then -- Don't use auto rolls on session that requesting rolls from raid members.
			local table = self:GenerateNoRepeatRollTable(ses)
			for k, v in ipairs(lootTable) do
				if addon:ItemIsItem(t.link, v.link) then
					sessionsDone[k] = true
					addon:Send("group", "rolls", k, table)
				end
			end
		end
	end
end

-----------------------------------------------------------------
-- Comm Handlers
-----------------------------------------------------------------
function RCVotingFrame:OnChangeResponseReceived(ses, name, response)
	self:SetCandidateData(ses, name, "response", response)
	self:Update()
end

function RCVotingFrame:OnLootAckReceived (name, specID, ilvl, sessionData)
	for k,d in pairs(sessionData) do
		for ses, v in pairs(d) do
			if k == "gear1" or k == "gear2" then
				self:SetCandidateData(ses, name, k, addon.Utils:UncleanItemString(v))
			else
				self:SetCandidateData(ses, name, k, v)
			end
		end
	end
	for i = 1, #lootTable do
		self:SetCandidateData(i, name, "specID", specID)
		self:SetCandidateData(i, name, "ilvl", ilvl)
		if not sessionData.response[i] then
			-- We might already have an response, so don't override unless it's announced
			if self:GetCandidateData(i, name, "response") == "ANNOUNCED" then
				self:SetCandidateData(i, name, "response", "WAIT")
			end
		-- This response == true means autopass
		elseif sessionData.response[i] == true then
			self:SetCandidateData(i, name, "response", "AUTOPASS")
		end
	end
	self:Update()
end

function RCVotingFrame:OnAwardedReceived (s, winner)
	self:ScheduleTimer(function()
		moreInfoData = addon:GetLootDBStatistics() -- Just update it on every award
		self:UpdateItemAwardHistory()
	end, 1) -- Make sure we've received the history data before updating
	if not lootTable[s] then return end -- We might not have lootTable - e.g. if we just reloaded
	local oldWinner = lootTable[s].awarded
	for k, v in ipairs(lootTable) do
		if addon:ItemIsItem(v.link, lootTable[s].link) then
			if oldWinner and not addon:UnitIsUnit(oldWinner,winner) then -- reawarded
				self:SetCandidateData(k, oldWinner, "response", self:GetCandidateData(k, oldWinner, "real_response"))
			end
			self:SetCandidateData(k, winner, "real_response", self:GetCandidateData(k, winner, "response"))
			self:SetCandidateData(k, winner, "response", "AWARDED")
		end
	end
	lootTable[s].awarded = winner
	local nextSession = self:FetchUnawardedSession()
	if addon.isMasterLooter and nextSession then -- ML should move to the next item on award
		self:SwitchSession(nextSession)
	else
		self:SwitchSession(session) -- Use switch session to update awardstring
	end
end

function RCVotingFrame:OnBaggedReceived (s)
	self:ScheduleTimer(function()
		moreInfoData = addon:GetLootDBStatistics() -- Just update it on every award
		self:UpdateItemAwardHistory()
	end, 1) -- Make sure we've received the history data before updating
	if not lootTable[s] then return end -- We might not have lootTable - e.g. if we just reloaded
	lootTable[s].bagged = true
	lootTable[s].baggedInSession = true
	if addon.isMasterLooter and session ~= #lootTable then -- ML should move to the next item on award
		self:SwitchSession(session + 1)
	else
		self:SwitchSession(session) -- Use switch session to update awardstring
	end
end

function RCVotingFrame:OnOfflineTimerReceived ()
	for i = 1, #lootTable do
		for name in pairs(lootTable[i].candidates) do
			if self:GetCandidateData(i, name, "response") == "ANNOUNCED" then
				addon.Log:D("No response from:", name)
				self:SetCandidateData(i, name, "response", "NOTHING")
			end
		end
	end
	self:Update()
end

function RCVotingFrame:OnResponseReceived (name, session, data)
	for k,v in pairs(data) do
		self:SetCandidateData(session, name, k, v)
	end
	self:Update()
end

function RCVotingFrame:OnRollsReceived (session, table)
	for name, roll in pairs(table) do
		self:SetCandidateData(session, name, "roll", roll)
	end
	self:Update()
end

function RCVotingFrame:OnRollReceived (name, roll, sessions)
	for _,ses in ipairs(sessions) do
		self:SetCandidateData(ses, name, "roll", roll)
	end
	self:Update()
end

function RCVotingFrame:OnReconnectReceived (rlootTable)
	lootTable = rlootTable
	for _, data in ipairs(rlootTable) do
		for _, cand in pairs(data.candidates) do
			for _, voter in ipairs(cand.voters) do
				if addon:UnitIsUnit(voter, "player") then -- WE've voted
					data.haveVoted = true
					cand.haveVoted = true
				end
			end
		end
	end
	self:Update()
	self:UpdatePeopleToVote()
end

function RCVotingFrame:OnLootTableAdditionsReceived (_, lt)
	local oldLenght = #lootTable
	for k,v in pairs(lt) do
		lootTable[k] = v
	end
	-- Add the sessions in order to avoid messing with SessionButtons
	for i = oldLenght + 1, #lootTable do
		self:SetupSession(i, lootTable[i])
		if addon.isMasterLooter and db.autoAddRolls then
			self:DoRandomRolls(i)
		end
	end
	self:SwitchSession(session)
end

local itemAwardHistoryCache = {}
local function cacheItemAwardHistory(item)
	local itemID = addon.Utils:GetItemIDFromLink(item)
	if not itemID then return end

	local his = addon:GetHistoryDB()
	local ret = TempTable:Acquire()
	for name, data in pairs(his) do
		for _, loot in ipairs(data) do
			if itemID == addon.Utils:GetItemIDFromLink(loot.lootWon) then
				addon.Log:D("Found single winner of ", loot.lootWon, name)
				if not ret[name] then ret[name] = {} end
				tinsert(ret[name], loot)
			end
		end
	end

	itemAwardHistoryCache[item] = {}
	for wname, data in pairs(ret) do
		itemAwardHistoryCache[item][wname] = data
	end

	TempTable:Release(ret)
end

--- items are expected to be a table of from [i] = itemLink
local function cacheMultipleItemAwardHistory(items)
	if not items or #items == 0 then return end

	local itemIDs = TempTable:Acquire()
	local ret = TempTable:Acquire()
	for _, item in ipairs(items) do
		ret[item] = {}
		itemIDs[addon.Utils:GetItemIDFromLink(item)] = item
	end

	local his = addon:GetHistoryDB()
	for name in addon:GroupIterator() do
		if his[name] then -- might not have a history
			for _, loot in ipairs(his[name]) do
				local id = addon.Utils:GetItemIDFromLink(loot.lootWon)
				if itemIDs[id] then
					addon.Log:D("Found winner of ", loot.lootWon, name)
					if not ret[itemIDs[id]][name] then ret[itemIDs[id]][name] = {} end
					tinsert(ret[itemIDs[id]][name], loot)
				end
			end
		end
	end

	for item, data in pairs(ret) do
		itemAwardHistoryCache[item] = data
	end

	TempTable:Release(ret)
	TempTable:Release(itemIDs)
end

--- Fetches recipients of the input item
--- @param item ItemLink|ItemID
--- @return table<name,table<i,HistoryEntry>>
function RCVotingFrame:GetItemAwardHistory(item)
	if not item then return end
	if not itemAwardHistoryCache[item] then -- Not cached, do so
		cacheItemAwardHistory(item)
	end
	return itemAwardHistoryCache[item]
end

--- Fetches item award info for all items in session.
--- Items can be fetched with `GetItemAwardHistory`.
function RCVotingFrame:UpdateItemAwardHistory()
	local items = TempTable:Acquire()
	for i, data in pairs(lootTable) do
		items[i] = data.link
	end
	cacheMultipleItemAwardHistory(items)
	TempTable:Release(items)
end

------------------------------------------------------------------
--	Visuals
-- @section Visuals
------------------------------------------------------------------
--@param forceUpdate If false/nil, updates will be delayed to only happen once every MIN_UPDATE_INTERVAL
function RCVotingFrame:Update(forceUpdate)
	needUpdate = false
	if not forceUpdate and noUpdateTimeRemaining > 0 then needUpdate = true; return end
	if not self.frame then return end -- No updates when it doesn't exist
	if not lootTable[session] then return addon.Log:D("VotingFrame:Update() without lootTable!!") end -- No updates if lootTable doesn't exist.
	noUpdateTimeRemaining = MIN_UPDATE_INTERVAL
	self.frame.st:SortData()
	self.frame.st:SortData() -- It appears that there is a bug in lib-st that only one SortData() does not use the "sortnext" to correct sort the rows.
	-- update awardString
	if lootTable[session] and lootTable[session].awarded then
		self.frame.awardString:SetText(L["Item was awarded to"])
		self.frame.awardString:Show()
		local name = lootTable[session].awarded
		self.frame.awardStringPlayer:SetText(addon.Ambiguate(name))
		local c = addon:GetClassColor(lootTable[session].candidates[name].class)
		self.frame.awardStringPlayer:SetTextColor(c.r,c.g,c.b,c.a)
		self.frame.awardStringPlayer:Show()
		-- Hack-reuse the SetCellClassIcon function
		addon.SetCellClassIcon(nil,self.frame.awardStringPlayer.classIcon,nil,nil,nil,nil,nil,nil,nil, lootTable[session].candidates[name].class)
		self.frame.awardStringPlayer.classIcon:Show()
	elseif lootTable[session] and lootTable[session].baggedInSession then
		self.frame.awardString:SetText(L["The item will be awarded later"])
		self.frame.awardString:Show()
		self.frame.awardStringPlayer:Hide()
		self.frame.awardStringPlayer.classIcon:Hide()
	else
		self.frame.awardString:Hide()
		self.frame.awardStringPlayer:Hide()
		self.frame.awardStringPlayer.classIcon:Hide()
	end
	-- This only applies to the ML
	if addon.isMasterLooter then
		-- Update close button text
		if active then
			self.frame.abortBtn:SetText(L["Abort"])
		else
			self.frame.abortBtn:SetText(_G.CLOSE)
		end
		self.frame.disenchant:Show()
	else -- Non-MLs:
		self.frame.abortBtn:SetText(_G.CLOSE)
		self.frame.disenchant:Hide()
	end
	if #self.frame.st.filtered < #self.frame.st.data then -- Some row is filtered in this session
		self.frame.filter.Text:SetTextColor(0.86,0.5,0.22) -- #db8238
	else
		self.frame.filter.Text:SetTextColor(_G.NORMAL_FONT_COLOR:GetRGB()) --#ffd100
	end
	if db.modules["RCVotingFrame"].alwaysShowTooltip then
		self.frame.itemTooltip:SetOwner(self.frame.content, "ANCHOR_NONE")
		self.frame.itemTooltip:SetHyperlink(lootTable[session].link)
		self.frame.itemTooltip:Show()
		self.frame.itemTooltip:SetPoint("TOP", self.frame, "TOP", 0, 0)
		self.frame.itemTooltip:SetPoint("RIGHT", sessionButtons[#lootTable], "LEFT", 0, 0)
	else
		self.frame.itemTooltip:Hide()
	end
end

updateFrame:SetScript("OnUpdate", function(self, elapsed)
	if noUpdateTimeRemaining > elapsed then
		noUpdateTimeRemaining = noUpdateTimeRemaining - elapsed
	else
		noUpdateTimeRemaining = 0
	end
	if needUpdate and noUpdateTimeRemaining <= 0 then
		RCVotingFrame:Update()
	end
end)

function RCVotingFrame:SwitchSession(s)
	addon.Log:D("SwitchSession", s)
	addon:SendMessage("RCSessionChangedPre", s)
	-- Start with setting up some statics
	session = s
	local t = lootTable[s] -- Shortcut
	self.frame.itemIcon:SetNormalTexture(t.texture)
	self.frame.itemText:SetText(t.link)
	self.frame.iState:SetText(self:GetItemStatus(t.link))
	local bonusText = addon:GetItemBonusText(t.link, "/")
	if bonusText ~= "" then bonusText = "+ "..bonusText end
	self.frame.itemLvl:SetText(_G.ITEM_LEVEL_ABBR..": "..addon.Utils:GetItemLevelText(t.ilvl, t.token))
	-- Set a proper item type text
	self.frame.itemType:SetText(addon:GetItemTypeText(t.link, t.subType, t.equipLoc, t.typeID, t.subTypeID, t.classes, t.token, t.relic))
	self.frame.bonuses:SetText(bonusText)

	-- Owner
	if t.owner and t.candidates[t.owner]then
		-- Hack-reuse the SetCellClassIcon function
		addon.SetCellClassIcon(nil,self.frame.ownerString.icon,nil,nil,nil,nil,nil,nil,nil, t.candidates[t.owner].class)
		self.frame.ownerString.icon:Show()
		self.frame.ownerString.owner:SetText(addon.Ambiguate(t.owner))
		local c = addon:GetClassColor(t.candidates[t.owner].class)
		self.frame.ownerString.owner:SetTextColor(c.r,c.g,c.b,c.a)
		self.frame.ownerString.owner:Show()
	elseif t.owner then -- We have a owner, probably a boss name
		self.frame.ownerString.icon:Hide()
		self.frame.ownerString.owner:SetText(t.owner)
		self.frame.ownerString.owner:SetTextColor(1,1,1,1)
		self.frame.ownerString.owner:Show()
	else -- Assume there's no owner, shouldn't happen
		self.frame.ownerString.icon:Hide()
		self.frame.ownerString.owner:Hide()
	end

	self:UpdateSessionButtons()

	-- Since we switched sessions, we want to sort by response
	local j = 1
	for i in ipairs(self.frame.st.cols) do
		self.frame.st.cols[i].sort = nil
		if self.frame.st.cols[i].colName == "response" then j = i end
	end
	self.frame.st.cols[j].sort = 1
	FauxScrollFrame_OnVerticalScroll(self.frame.st.scrollframe, 0, self.frame.st.rowHeight, function() self.frame.st:Refresh() end) -- Reset scrolling to 0
	self:Update(true)
	self:UpdatePeopleToVote()
	addon:SendMessage("RCSessionChangedPost", s)
end

function RCVotingFrame:BuildST()
	local rows = {}
	local i = 1
	-- We need to build the columns from the data in self.scrollCols
	-- We only really need the colName and value to get added
	for name in addon:GroupIterator() do
		local data = {}
		for num, col in ipairs(self.scrollCols) do
			data[num] = {value = "", colName = col.colName}
		end
		rows[i] = {
			name = name,
			cols = data,
		}
		i = i + 1
	end
	self.frame.st:SetData(rows)
end

function RCVotingFrame:UpdateMoreInfo(row, data)
	local name
	if data and row then
		name  = data[row].name
	else -- Try to extract the name from the selected row
		name = self.frame.st:GetSelection() and self.frame.st:GetRow(self.frame.st:GetSelection()).name or nil
	end

	if not moreInfo or not name then -- Hide the frame
		return self.frame.moreInfo:Hide()
	end

	local awardHistory = self:GetItemAwardHistory(lootTable[session].link)
	-- The names needs sorting
	local sortedAwardHistory = TempTable:Acquire()
	local i = 1
	for cName in pairs(awardHistory) do
		sortedAwardHistory[i] = cName
		i = i + 1
	end
	table.sort(sortedAwardHistory)

	local color = addon:GetClassColor(self:GetCandidateData(session, name, "class"))
	local tip = self.frame.moreInfo -- shortening
	tip:SetOwner(self.frame, "ANCHOR_RIGHT")

	tip:AddLine(addon.Ambiguate(name), color.r, color.g, color.b)
	if moreInfoData and moreInfoData[name] then
		local r,g,b
		tip:AddLine(L["Latest item(s) won"])
		for _, v in ipairs(moreInfoData[name]) do -- extract latest awarded items
			if v[3] then r,g,b = unpack(v[3],1,3) end
			tip:AddDoubleLine(v[1], v[2], nil,nil,nil, r or 1, g or 1, b or 1)
		end
		tip:AddLine(" ") -- spacer
		tip:AddLine(_G.TOTAL)
		for _, v in pairs(moreInfoData[name].totals.responses) do
			if v[3] then r,g,b = unpack(v[3],1,3) end
			tip:AddDoubleLine(v[1], v[2], r or 1,g or 1,b or 1, r or 1,g or 1,b or 1)
		end
		if moreInfoData[name].totals.tokens[addon.currentInstanceName] then
			tip:AddLine(" ")
			tip:AddDoubleLine(L["Tier tokens received from here:"], moreInfoData[name].totals.tokens[addon.currentInstanceName].num, 1,1,1, 1,1,1)
		end
		tip:AddDoubleLine(L["Number of raids received loot from:"], moreInfoData[name].totals.raids.num, 1,1,1, 1,1,1)
		tip:AddDoubleLine(L["Total items received:"], moreInfoData[name].totals.total, 0,1,1, 0,1,1)

		if addon.nnp then
			tip:AddLine(" ")
			tip:AddDoubleLine("Winners of:", lootTable[session].link)
			if #sortedAwardHistory == 0 then
				tip:AddLine(_G.NONE)
			end
			for _, wname in ipairs(sortedAwardHistory) do
				for _, entry in ipairs(awardHistory[wname]) do
					local ilvl = select(4, GetItemInfo(entry.lootWon))
					local player = Player:Get(wname)
					local class = player and player:GetClass()
					local c = addon:GetClassColor(class)
					tip:AddDoubleLine(addon.Ambiguate(wname), entry.response .." |cffffffffilvl: "..ilvl, c.r, c.g,c.b,unpack(entry.color, 1,3))
				end
			end
		end
	else
		tip:AddLine(L["No entries in the Loot History"])
	end
	TempTable:Release(sortedAwardHistory)
	tip:Show()
	tip:SetAnchorType("ANCHOR_RIGHT", 0, -tip:GetHeight())
end

function RCVotingFrame:GetFrame()
	if self.frame then return self.frame end

	-- Container and title
	local f = addon.UI:NewNamed("Frame", UIParent, "DefaultRCLootCouncilFrame", L["RCLootCouncil Voting Frame"], 250, 420)
	-- Scrolling table
	function f.UpdateSt()
		if f.st then -- It might already be created, so just update the cols
			f.st:Hide()
			f.st = nil
		end
		local st = LibStub("ScrollingTable"):CreateST(self.scrollCols, NUM_ROWS, ROW_HEIGHT, { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5 }, f.content)
		st.frame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
		st:RegisterEvents({
			["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
				if button == "RightButton" and row then
					menuFrame.name = data[realrow].name
					MSA_ToggleDropDownMenu(1, nil, menuFrame, cellFrame, 0, 0);
				elseif button == "LeftButton" and row then -- Update more info
					self:UpdateMoreInfo(realrow, data)
					if IsAltKeyDown() then
						local name = data[realrow].name
						LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_AWARD", self:GetAwardPopupData(session, name, lootTable[session].candidates[name]))
					end
				end
				-- Return false to have the default OnClick handler take care of left clicks
				return false
			end,
		})
		-- We also want to show moreInfo on mouseover
		st:RegisterEvents({
			["OnEnter"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
				if row then self:UpdateMoreInfo(realrow, data) end
				-- Return false to have the default OnEnter handler take care mouseover
				return false
			end
		})
		-- We also like to return to the actual selected player when we remove the mouse
		st:RegisterEvents({
			["OnLeave"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
				self:UpdateMoreInfo()
				return false
			end
		})
		st:SetFilter(RCVotingFrame.filterFunc)
		st:EnableSelection(true)
		f.st = st
		f:SetWidth(f.st.frame:GetWidth() + 20)
	end
	f.UpdateSt()

	--[[------------------------------
		Session item icon and strings
	    ------------------------------]]
	local item = addon.UI:New("IconBordered", f.content, "Interface/ICONS/INV_Misc_QuestionMark")
	item:SetMultipleScripts({
		 OnEnter = function()
			 if not lootTable then return; end
			 addon:CreateHypertip(lootTable[session].link)
			 GameTooltip:AddLine("")
			 GameTooltip:AddLine(L["always_show_tooltip_howto"], nil, nil, nil, true)
			 GameTooltip:Show()
		 end,
		 OnLeave = function() addon:HideTooltip() end,
		 OnClick = function()
			 if not lootTable then return; end
			 if ( IsModifiedClick() ) then
				 HandleModifiedItemClick(lootTable[session].link);
			 end
			 if item.lastClick and GetTime() - item.lastClick <= 0.5 then
				 db.modules["RCVotingFrame"].alwaysShowTooltip = not db.modules["RCVotingFrame"].alwaysShowTooltip
				 self:Update()
			 else
				 item.lastClick = GetTime()
			 end
		 end
	 })
	item:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -20)
	item:SetSize(50,50)
	f.itemIcon = item

	f.itemTooltip = addon:CreateGameTooltip("votingframe", f.content)

	local iTxt = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	iTxt:SetPoint("TOPLEFT", item, "TOPRIGHT", 10, 0)
	iTxt:SetText(L["Something went wrong :'("]) -- Set text for reasons
	f.itemText = iTxt

	local ilvl = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ilvl:SetPoint("TOPLEFT", iTxt, "BOTTOMLEFT", 0, -4)
	ilvl:SetTextColor(1, 1, 1) -- White
	ilvl:SetText("")
	f.itemLvl = ilvl

	local iState = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	iState:SetPoint("LEFT", ilvl, "RIGHT", 5, 0)
	iState:SetTextColor(0,1,0,1) -- Green
	iState:SetText("")
	f.iState = iState

	local iType = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	iType:SetPoint("TOPLEFT", ilvl, "BOTTOMLEFT", 0, -4)
	iType:SetTextColor(0.5, 1, 1) -- Turqouise
	iType:SetText("")
	f.itemType = iType

	f.bonuses = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.bonuses:SetPoint("LEFT", f.itemType, "RIGHT", 1, 0)
	f.bonuses:SetTextColor(0.2,1,0.2) -- Green
	--#end----------------------------

	-- Abort button
	local b1 = addon:CreateButton(_G.CLOSE, f.content)
	b1:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -50)
	b1:SetScript("OnClick", function()
		-- This needs to be dynamic if the ML has changed since this was first created
		if addon.isMasterLooter and active then LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_ABORT")
		else self:Hide() end
	end)
	f.abortBtn = b1

	-- More info button
	local b2 = CreateFrame("Button", nil, f.content, "UIPanelButtonTemplate")
	b2:SetSize(25,25)
	b2:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -20)
	if moreInfo then
		b2:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
		b2:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
	else
		b2:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
		b2:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	end
	b2:SetScript("OnClick", function(button)
		moreInfo = not moreInfo
		db.modules["RCVotingFrame"].moreInfo = moreInfo
		if moreInfo then -- show the more info frame
			button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
			button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
		else -- hide it
			button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
		end
		self:UpdateMoreInfo()
	end)
	b2:SetScript("OnEnter", function() addon:CreateTooltip(L["Click to expand/collapse more info"]) end)
	b2:SetScript("OnLeave", function() addon:HideTooltip() end)
	f.moreInfoBtn = b2

	f.moreInfo = CreateFrame( "GameTooltip", "RCVotingFrameMoreInfo", nil, "GameTooltipTemplate" )
	f.content:SetScript("OnSizeChanged", function()
		f.moreInfo:SetScale(f:GetScale() * 0.6)
	end)

	-- Filter
	local b3 = addon:CreateButton(_G.FILTER, f.content)
	b3:SetPoint("RIGHT", b1, "LEFT", -10, 0)
	b3:SetScript("OnClick", function(self) MSA_ToggleDropDownMenu(1, nil, filterMenu, self, 0, 0) end )
	b3:SetScript("OnEnter", function() addon:CreateTooltip(L["Deselect responses to filter them"]) end)
	b3:SetScript("OnLeave", function() addon:HideTooltip() end)
	f.filter = b3

	-- Disenchant button
	local b4 = addon:CreateButton(_G.ROLL_DISENCHANT, f.content)
	b4:SetPoint("RIGHT", b3, "LEFT", -10, 0)
	b4:SetScript("OnClick", function(self) MSA_ToggleDropDownMenu(1, nil, enchanters, self, 0, 0) end )
	--b4:SetNormalTexture("Interface\\Icons\\INV_Enchant_Disenchant")
--	b4:Hide() -- hidden by default
	f.disenchant = b4

	-- Number of votes
	local rf = CreateFrame("Frame", nil, f.content)
	rf:SetWidth(100)
	rf:SetHeight(20)
	if b2 then rf:SetPoint("RIGHT", b2, "LEFT", -10, 0) else rf:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -20) end
	rf:SetScript("OnLeave", function()
		addon:HideTooltip()
	end)
	local rft = rf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	rft:SetPoint("CENTER", rf, "CENTER")
	rft:SetText(" ")
	rft:SetTextColor(0,1,0,1) -- Green
	rf.text = rft
	rf:SetWidth(rft:GetStringWidth())
	f.rollResult = rf

	-- Loot Status
	f.lootStatus = addon.UI:New("Text", f.content, " ")
	f.lootStatus:SetTextColor(1,1,1,1) -- White for now
	f.lootStatus:SetHeight(20)
	f.lootStatus:SetWidth(150)
	f.lootStatus:SetPoint("RIGHT", rf, "LEFT", -10, 0)
	f.lootStatus:SetScript("OnLeave", addon.Utils.HideTooltip)
	f.lootStatus.text:SetJustifyH("RIGHT")

	-- Owner
	f.ownerString = {}
	f.ownerString.icon = addon.UI:New("Icon", f.content)
	f.ownerString.icon:SetPoint("LEFT", f.iState, "RIGHT", 5, 0)
	f.ownerString.icon:SetSize(15,15)
	f.ownerString.icon:Hide()

	f.ownerString.owner = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.ownerString.owner:SetPoint("LEFT", f.ownerString.icon, "RIGHT")
	f.ownerString.owner:Hide()

	-- Award string
	local awdstr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	awdstr:SetPoint("CENTER", f.content, "TOP", 0, -35)
	awdstr:SetText(L["Item was awarded to"])
	awdstr:SetTextColor(1, 1, 0, 1) -- Yellow
	awdstr:Hide()
	f.awardString = awdstr
	awdstr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	awdstr:SetPoint("TOP", f.awardString, "BOTTOM", 7.5, -3)
	awdstr:SetText("PlayerName")
	awdstr:SetTextColor(1, 1, 1, 1) -- White
	awdstr:Hide()
	f.awardStringPlayer = awdstr
	local awdtx = f.content:CreateTexture()
	awdtx:SetTexture("Interface/ICONS/INV_Sigil_Thorim.png")
	function awdtx:SetNormalTexture(tex) self:SetTexture(tex) end
	function awdtx:GetNormalTexture() return self end
	awdtx:SetPoint("RIGHT", awdstr, "LEFT")
	awdtx:SetSize(15,15)
	awdtx:Hide()
	f.awardStringPlayer.classIcon = awdtx

	-- Session toggle
	local stgl = CreateFrame("Frame", nil, f.content)
	stgl:SetWidth(40)
	stgl:SetHeight(f:GetHeight())
	stgl:SetPoint("TOPRIGHT", f, "TOPLEFT", -2, 0)
	f.sessionToggleFrame = stgl
	sessionButtons = {}

	-- Set a proper width
	f:SetWidth(f.st.frame:GetWidth() + 20)
	return f;
end

function RCVotingFrame:UpdateLootStatus()
	if not self.frame then return end -- Might not be created yet
	if not addon.isCouncil then return end

	local status, list = addon:GetLootStatusData()
	self.frame.lootStatus:SetText(L["Loot Status"] .. ": " .. status)
	self.frame.lootStatus:SetScript("OnEnter", function()
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		GameTooltip:AddLine(L["Loot Status"])
		if addon.debug then
			GameTooltip:AddLine("Debug")
			for id, v in pairs(addon.lootStatus) do
				if id ~= addon.lastEncounterID then
					GameTooltip:AddDoubleLine(id, v.num,1,1,1,1,1,1)
				else
					GameTooltip:AddLine("EncounterID: " .. addon.lastEncounterID)
					for player, item in pairs(v) do
						GameTooltip:AddDoubleLine(player, item)
					end
				end
			end
			GameTooltip:AddLine(" ")
		end
		for _, v in ipairs(list) do
			GameTooltip:AddDoubleLine(addon:GetUnitClassColoredName(v.name), v.text)
		end
		GameTooltip:Show()
	end)
end

function RCVotingFrame:UpdatePeopleToVote()
	local hasVoted = TempTable:Acquire()
	local shouldVote = TempTable:Acquire()
	for _, player in pairs(Council:Get()) do
		tinsert(shouldVote, player.name)
	end

	-- Find out who have voted
	for name in pairs(lootTable[session].candidates) do
		for _, voter in pairs(lootTable[session].candidates[name].voters) do
			if not tContains(hasVoted, voter) then
				tinsert(hasVoted, voter)
				tDeleteItem(shouldVote, voter)
			end
		end
	end
	local numCouncil = Council:GetNum()
	if numCouncil == 0 then
		self.frame.rollResult.text:SetText(L["Couldn't find any councilmembers in the group"])
		self.frame.rollResult.text:SetTextColor(1,0,0,1) -- Red
	elseif #shouldVote == 0 then
		self.frame.rollResult.text:SetText(L["Everyone have voted"])
		self.frame.rollResult.text:SetTextColor(0,1,0,1) -- Green
	elseif #shouldVote > 0 then
		self.frame.rollResult.text:SetText(format(L["x out of x have voted"], #hasVoted, numCouncil))
		self.frame.rollResult.text:SetTextColor(1,1,0,1) -- Yellow
	else
		addon.Log:D("#voters > #councilInGroup ?")
	end
	-- Sort the lists
	table.sort(hasVoted)
	table.sort(shouldVote)
	self.frame.rollResult:SetScript("OnEnter", function()
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		GameTooltip:AddLine(L["The following council members have voted"])
		for _,name in ipairs(hasVoted) do
			GameTooltip:AddLine(addon:GetUnitClassColoredName(name))
		end
		if #shouldVote > 0 then
			GameTooltip:AddLine(L["Missing votes from:"])
			for _,name in ipairs(shouldVote) do
				GameTooltip:AddLine(addon:GetUnitClassColoredName(name))
			end
		end
		GameTooltip:Show()
	end)
	self.frame.rollResult:SetWidth(self.frame.rollResult.text:GetStringWidth())
	TempTable:Release(hasVoted)
	TempTable:Release(shouldVote)
end

function RCVotingFrame:UpdateSessionButtons()
	for i, t in ipairs(lootTable) do
		sessionButtons[i] = self:UpdateSessionButton(i, t.texture, t.link, t.awarded)
	end
end

function RCVotingFrame:UpdateSessionButton(i, texture, link, awarded)
	local btn = sessionButtons[i]
	if not btn then -- create the button
		btn = addon.UI:NewNamed("IconBordered", self.frame.sessionToggleFrame, "RCSessionButton"..i, texture)
		if i == 1 then
			btn:SetPoint("TOPRIGHT", self.frame.sessionToggleFrame)
		elseif mod(i,10) == 1 then
			btn:SetPoint("TOPRIGHT", sessionButtons[i-10], "TOPLEFT", -2, 0)
		else
			btn:SetPoint("TOP", sessionButtons[i-1], "BOTTOM", 0, -2)
		end
		btn:SetScript("Onclick", function() RCVotingFrame:SwitchSession(i); end)
	end
	-- then update it
	btn:SetNormalTexture(texture or "Interface\\InventoryItems\\WoWUnknownItem01")
	local lines = { format(L["Click to switch to 'item'"], link) }
	if i == session then
		btn:SetBorderColor("yellow")
	elseif awarded then
		btn:SetBorderColor("green")
		tinsert(lines, L["This item has been awarded"])
	else
		btn:SetBorderColor("white") -- white
	end
	btn:SetScript("OnEnter", function() addon:CreateTooltip(unpack(lines)) end)
	return btn
end

function RCVotingFrame:AddNonTradeable(owner, reason, link)
	self.numNonTradeables = self.numNonTradeables + 1
	local texture = select(5, GetItemInfoInstant(link))
	local b = addon.UI:New("IconBordered", self.frame.content, texture)
	b:Desaturate()
	if self.numNonTradeables == 1 then
		b:SetPoint("TOPLEFT", self.frame.content, "BOTTOMLEFT", 0, -2)
	else
		b:SetPoint("LEFT", self.nonTradeablesButtons[self.numNonTradeables - 1], "RIGHT", 5)
	end
	b:SetScript("OnEnter", function()
		addon:CreateHypertip(link)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Looted by:"], addon:GetUnitClassColoredName(addon.Ambiguate(owner)))
		GameTooltip:AddDoubleLine(L["Non-tradeable reason:"], L["non_tradeable_reason_"..tostring(reason)], nil, nil, nil,1,1,1)
		GameTooltip:Show()
	end)
	if reason == "rejected_trade" then
		b:SetBorderColor("purple")
	else
		b:SetBorderColor("grey")
	end
	b:SetAlpha(0.7)
	b:Show()
	self.nonTradeablesButtons[self.numNonTradeables] = b
end

function RCVotingFrame:HideNonTradeables()
	for _,v in ipairs(self.nonTradeablesButtons) do v:Hide() end
end


----------------------------------------------------------
--	Lib-st data functions (not particular pretty, I know)
-- @section Lib-st data funcs.
----------------------------------------------------------
function RCVotingFrame:GetDiffColor(num)
	if num == "" then num = 0 end -- Can't compare empty string
	local green, red, grey = {0,1,0,1},{1,0,0,1},{0.75,0.75,0.75,1}
	if num > 0 then return green end
	if num < 0 then return red end
	return grey
end

local doOnceChecker = false

function RCVotingFrame.SetCellClass(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	if not (lootTable[session] and lootTable[session].candidates[name] and lootTable[session].candidates[name].specID) then
		addon.Log:E("Missing data for 'SetCellClass'", session, name)
		ErrorHandler:ThrowSilentError(format("SetCellClass: Session: %d Name: %s SpecID: %s", session, name, tostring(lootTable[session].candidates[name] and lootTable[session].candidates[name].specID)))
		if not doOnceChecker then
			doOnceChecker = true
			addon.Log:E("lootTable[1].candidates:")
			for name in pairs(lootTable[1].candidates) do
				addon.Log:E(name)
			end
		end
		return
	end
	local specID = lootTable[session].candidates[name].specID
	local specIcon = specID and select(4, GetSpecializationInfoByID(specID))
	if specIcon and db.showSpecIcon then
	frame:SetNormalTexture(specIcon);
	frame:GetNormalTexture():SetTexCoord(0, 1, 0, 1);
	else
		addon.SetCellClassIcon(rowFrame, frame, data, cols, row, realrow, column, fShow, table, lootTable[session].candidates[name].class)
	end
	data[realrow].cols[column].value = lootTable[session].candidates[name].class or ""
end

function RCVotingFrame.SetCellName(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	if addon:UnitIsUnit(name, lootTable[session].owner) then
		frame.text:SetText("|TInterface\\LOOTFRAME\\LootToast:0:0:0:0:1024:256:610:640:224:256|t"..addon.Ambiguate(name))
	else
		frame.text:SetText(addon.Ambiguate(name))
	end
	local c = addon:GetClassColor(lootTable[session].candidates[name].class)
	frame.text:SetTextColor(c.r, c.g, c.b, c.a)
	data[realrow].cols[column].value = name or ""
end

function RCVotingFrame.SetCellRank(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	frame.text:SetText(lootTable[session].candidates[name].rank)
	frame.text:SetTextColor(addon:GetResponseColor(lootTable[session].typeCode or lootTable[session].equipLoc, lootTable[session].candidates[name].response))
	data[realrow].cols[column].value = lootTable[session].candidates[name].rank or ""
end

function RCVotingFrame.SetCellRole(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	local role = addon.Utils:TranslateRole(lootTable[session].candidates[name].role)
	frame.text:SetText(role)
	frame.text:SetTextColor(addon:GetResponseColor(lootTable[session].typeCode or lootTable[session].equipLoc, lootTable[session].candidates[name].response))
	data[realrow].cols[column].value = role or ""
end

function RCVotingFrame.SetCellResponse(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	local response = addon:GetResponse(lootTable[session].typeCode or lootTable[session].equipLoc, lootTable[session].candidates[name].response)
	local text = response.text
	if (IsInInstance() and select(4, UnitPosition("player")) ~= select(4, UnitPosition(Ambiguate(name, "short"))))
		-- Mark as out of instance if the current player is in an instance and the raider is in other instancemap
		or ((not IsInInstance()) and UnitPosition(Ambiguate(name, "short")) ~= nil) then
		-- If the current player is not in an instance, mark as out of instance if 1st return of UnitPosition is not nil
		-- This function returns nil if the raider is in any instance.
		text = text.." ("..L["Out of instance"]..")"
	end
	frame.text:SetText(text)
	frame.text:SetTextColor(unpack(response.color))
end

function RCVotingFrame.SetCellIlvl(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	frame.text:SetText(db.iLvlDecimal and addon.round(lootTable[session].candidates[name].ilvl,2) or addon.round(lootTable[session].candidates[name].ilvl))
	data[realrow].cols[column].value = lootTable[session].candidates[name].ilvl or ""
end

function RCVotingFrame.SetCellDiff(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	frame.text:SetText(lootTable[session].candidates[name].diff)
	frame.text:SetTextColor(unpack(RCVotingFrame:GetDiffColor(lootTable[session].candidates[name].diff)))
	data[realrow].cols[column].value = lootTable[session].candidates[name].diff or ""
end

function RCVotingFrame.SetCellGear(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local gear = data[realrow].cols[column].colName -- gear1 or gear2
	local name = data[realrow].name
	gear = lootTable[session].candidates[name][gear] -- Get the actual gear
	if gear then
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

function RCVotingFrame.SetCellVotes(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	frame:SetScript("OnEnter", function()
		if not addon.mldb.anonymousVoting or (db.showForML and addon.isMasterLooter) then
			if not addon.mldb.hideVotes or (addon.mldb.hideVotes and lootTable[session].haveVoted) then
				addon:CreateTooltip(L["Voters"], unpack((function ()
					local ret = {}
					for i,name in ipairs(lootTable[session].candidates[name].voters) do
						ret[i] = addon:GetUnitClassColoredName(name)
					end
					return ret
				end)()
			))
			end
		end
	end)
	frame:SetScript("OnLeave", function() addon:HideTooltip() end)
	local val = lootTable[session].candidates[name].votes
	data[realrow].cols[column].value = val -- Set the value for sorting reasons
	frame.text:SetText(val)

	if addon.mldb.hideVotes then
		if not lootTable[session].haveVoted then
			frame.text:SetText(0)
			data[realrow].cols[column].value = 0 -- Don't background sort when we can't see the votes
		end
	end
end

function RCVotingFrame.SetCellVote(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	if not active or lootTable[session].awarded then -- Don't show the vote button if awarded or not active
		if frame.voteBtn then
			frame.voteBtn:Hide()
		end
		return
	end
	if addon.isCouncil or addon.isMasterLooter then -- Only let the right people vote
		if not frame.voteBtn then -- create it
			frame.voteBtn = addon:CreateButton(L["Vote"], frame)
			frame.voteBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
			frame.voteBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
		end
		frame.voteBtn:SetScript("OnClick", function(btn)
			addon.Log:D("Vote button pressed")
			if lootTable[session].candidates[name].haveVoted then -- unvote
				addon:Send("group", "vote", session, name, -1)
				lootTable[session].candidates[name].haveVoted = false

				-- Check if that was our only vote
				local haveVoted = false
				for _, v in pairs(lootTable[session].candidates) do
					if v.haveVoted then haveVoted = true end
				end
				lootTable[session].haveVoted = haveVoted

			else -- vote
				-- Test if they may vote for themselves
				if not addon.mldb.selfVote and addon:UnitIsUnit("player", name) then
					return addon:Print(L["The Master Looter doesn't allow votes for yourself."])
				end
				-- Test if they're allowed to cast multiple votes
				if not addon.mldb.multiVote then
					if lootTable[session].haveVoted then
						return addon:Print(L["The Master Looter doesn't allow multiple votes."])
					end
				end
				-- Do the vote
				addon:Send("group", "vote", session, name, 1)
				lootTable[session].candidates[name].haveVoted = true
				lootTable[session].haveVoted = true
			end
		end)
		frame.voteBtn:Show()
		if lootTable[session].candidates[name].haveVoted then
			frame.voteBtn:SetText(L["Unvote"])
		else
			frame.voteBtn:SetText(L["Vote"])
		end
	end
end

function RCVotingFrame.SetCellNote(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	local note = lootTable[session].candidates[name].note
	local f = frame.noteBtn or CreateFrame("Button", nil, frame)
	f:SetSize(ROW_HEIGHT, ROW_HEIGHT)
	f:SetPoint("CENTER", frame, "CENTER")
	if note then
		f:SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Up.png")
		f:SetScript("OnEnter", function() addon:CreateTooltip(_G.LABEL_NOTE, note)	end) -- _G.LABEL_NOTE == "Note" in English
		f:SetScript("OnLeave", function() addon:HideTooltip() end)
		data[realrow].cols[column].value = 1 -- Set value for sorting compability
	else
		f:SetScript("OnEnter", nil)
		f:SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Disabled.png")
		data[realrow].cols[column].value = 0
	end
	frame.noteBtn = f
end

function RCVotingFrame.SetCellRoll(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	frame.text:SetText(lootTable[session].candidates[name].roll or "")
	data[realrow].cols[column].value = lootTable[session].candidates[name].roll or ""
end

function RCVotingFrame.filterFunc(table, row)
	if not db.modules["RCVotingFrame"].filters then return true end -- db hasn't been initialized, so just show it
	local name = row.name
	if not (lootTable[session] and lootTable[session].candidates[name]) then
		ErrorHandler:ThrowSilentError(string.format("Couldn't get rank at session %d for candidate %s", session, tostring(name)))
		return true
	end
	local rank = lootTable[session].candidates[name].rank
	local rank = lootTable[session].candidates[name] and lootTable[session].candidates[name].rank

	if db.modules["RCVotingFrame"].filters.alwaysShowOwner then
		if addon:UnitIsUnit(name, lootTable[session].owner) then
			return true
		end
	end

	if rank and guildRanks[rank] then
		if not db.modules["RCVotingFrame"].filters.ranks[guildRanks[rank]] then
			return false
		end
	elseif not db.modules["RCVotingFrame"].filters.ranks.notInYourGuild then
		return false
	end

	local response = lootTable[session].candidates[row.name].response
	if not db.modules["RCVotingFrame"].filters.showPlayersCantUseTheItem then
		local v = lootTable[session]
		if addon:AutoPassCheck(v.link, v.equipLoc, v.typeID, v.subTypeID, v.classes, v.token, v.relic, lootTable[session].candidates[row.name].class) then
			return false
		end
	end

	if response == "AUTOPASS" or response == "PASS" or type(response) == "number" then
		return db.modules["RCVotingFrame"].filters[response]
	else -- Filter out the status texts
		return db.modules["RCVotingFrame"].filters["STATUS"]
	end
end

function ResponseSort(table, rowa, rowb, sortbycol)
	local column = table.cols[sortbycol]
	local a, b = table:GetRow(rowa), table:GetRow(rowb);
	if not (lootTable[session].candidates[a.name] and lootTable[session].candidates[a.name].response) or not (lootTable[session].candidates[b.name] and lootTable[session].candidates[b.name].response) then
		return true
	end
	a, b = addon:GetResponse(lootTable[session].typeCode or lootTable[session].equipLoc, lootTable[session].candidates[a.name].response).sort,
			 addon:GetResponse(lootTable[session].typeCode or lootTable[session].equipLoc, lootTable[session].candidates[b.name].response).sort
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
		local direction = column.sort or column.defaultsort or 1
		if direction == 1 then
			return a < b;
		else
			return a > b;
		end
	end
end

function GuildRankSort(table, rowa, rowb, sortbycol)
	local column = table.cols[sortbycol]
	local a, b = table:GetRow(rowa), table:GetRow(rowb);
	-- Extract the rank index from the name, fallback to 100 if not found
	a = guildRanks[lootTable[session].candidates[a.name].rank] or 100
	b = guildRanks[lootTable[session].candidates[b.name].rank] or 100
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
		local direction = column.sort or column.defaultsort or 1
		if direction == 1 then
			return a < b;
		else
			return a > b;
		end
	end
end

--- Function for getting the data passed to RCLOOTCOUNCIL_CONFIRM_AWARD
-- Note reason must be nil for ML:Award() to use responseID (Finicky, I know...)
function RCVotingFrame:GetAwardPopupData(session, name, data, reason)
	return {
		session 		= session,
		winner		= name,
		responseID	= data.response,
		reason		= reason,
		votes			= data.votes,
		gear1 		= data.gear1,
		gear2			= data.gear2,
		isTierRoll	= data.isTier,
		isRelicRoll	= data.isRelic,
		link 			= lootTable[session].link,
		isToken		= lootTable[session].token,
		note		= data.note,
		equipLoc		= lootTable[session].equipLoc,
		texture 		= lootTable[session].texture,
		typeCode 	= lootTable[session].typeCode,
		boss 			= lootTable[session].boss,
	}
end

function RCVotingFrame:GetRerollData(session, isRoll, noAutopass)
	local v = lootTable[session]
	return {
		session 	= session,
		string 		= addon.Utils:GetTransmittableItemString(v.link),
		noAutopass = noAutopass,
		typeCode 	= lootTable[session].typeCode,
		isRoll 		= isRoll
	}
end

-- Do an Reannouncement.
--@param namePred: true or string or func. Determine what candidate should be reannounced. true to reannounce to all candidates. string for specific candidate.
--@param sesPred: true or number or func. Determine what session should be reannounced. true to reannounce to all candidates. \
--		 number k to reannounce to session k and other sessions with the same item as session k.
--@param isRoll: true or false or false. Determine whether we are requesting rolls. true will request rolls and clear the current rolls.
--@param noAutopass: true or false or nil. Determine whether we force no autopass.
--@param announceInChat: true or false or nil. Determine if the reannounce sessions should be announced in chat.
function RCVotingFrame:ReannounceOrRequestRoll(namePred, sesPred, isRoll, noAutopass, announceInChat)
	addon.Log:D("ReannounceOrRequestRoll", namePred, sesPred, isRoll, noAutopass, announceInChat)
	local rerollTable = {}

	for k,v in ipairs(lootTable) do
		local rolls = {}
		if sesPred == true or (type(sesPred)=="number" and addon:ItemIsItem(lootTable[k].link, lootTable[sesPred].link)) or (type(sesPred)=="function" and sesPred(k)) then
			tinsert(rerollTable, RCVotingFrame:GetRerollData(k, isRoll, noAutopass))

			for name, _ in pairs(v.candidates) do
				if namePred == true or (type(namePred)=="string" and name == namePred) or (type(namePred)=="function" and namePred(name)) then
					if not isRoll then
						addon:Send("group", "change_response", k, name, "WAIT")
					end
					rolls[name] = ""
				end
			end
			if isRoll then
				addon:Send("group", "rolls", k, rolls)
			end
		end
	end

	if #rerollTable > 0 then
		if announceInChat then
			addon:GetActiveModule("masterlooter"):AnnounceItems(rerollTable, isRoll)
		end


		if namePred == true then
			addon:Send("group", "reroll", rerollTable)
		else
			for name, _ in pairs(lootTable[session].candidates) do
				if (type(namePred)=="string" and name == namePred) or (type(namePred)=="function" and namePred(name)) then
					addon:Send(Player:Get(name), "reroll", rerollTable)
				end
			end
		end
	end
end

----------------------------------------------------
--	Dropdowns.
-- @section Dropdowns.
----------------------------------------------------
do

	function RCVotingFrame.rennaounceOrRequestRollCreateCategoryButton(category)
		return
		{ -- 3 Reannounce (and request rolls) to candidate
			onValue = function() return _G.MSA_DROPDOWNMENU_MENU_VALUE == "REANNOUNCE" or _G.MSA_DROPDOWNMENU_MENU_VALUE == "REQUESTROLL" end,
			value = function() return _G.MSA_DROPDOWNMENU_MENU_VALUE.."_"..category end,
			text = function(candidateName) return RCVotingFrame.reannounceOrRequestRollText(candidateName, category) end,
			notCheckable = true,
			hasArrow = true,
		}
	end
	-- The text of level2 and header of level 3 button of rennaounce (and request roll)
	--@param category: Used for level2 text to determine what text to shown.
	-- Level 3 text used the value of MSA_DROPDOWNMENU_MENU_VALUE to determine what to show
	function RCVotingFrame.reannounceOrRequestRollText(candidateName, category)
		if type(MSA_DROPDOWNMENU_MENU_VALUE) ~= "string" then return end

		local text = ""
		if category == "CANDIDATE" or MSA_DROPDOWNMENU_MENU_VALUE:find("_CANDIDATE$") then
			text = addon:GetUnitClassColoredName(candidateName)
		elseif category == "GROUP" or MSA_DROPDOWNMENU_MENU_VALUE:find("_GROUP$") then
			text = _G.FRIENDS_FRIENDS_CHOICE_EVERYONE
		elseif category == "ROLL" or MSA_DROPDOWNMENU_MENU_VALUE:find("_ROLL$") then
			text = _G.ROLL..": "..(lootTable[session].candidates[candidateName].roll or "")
		elseif category == "RESPONSE" or MSA_DROPDOWNMENU_MENU_VALUE:find("_RESPONSE$") then
			text = L["Response"]..": ".."|cff"..(addon.Utils:RGBToHex(unpack(addon:GetResponse(lootTable[session].typeCode or lootTable[session].equipLoc, lootTable[session].candidates[candidateName].response).color))
			or "ffffff")..(addon:GetResponse(lootTable[session].typeCode or lootTable[session].equipLoc, lootTable[session].candidates[candidateName].response).text or "").."|r"
		else
			addon.Log:D("Unexpected category or dropdown menu value: "..tostring(category).." ,"..tostring(MSA_DROPDOWNMENU_MENU_VALUE))
		end

		return text
	end

	-- Do reannounce (and request rolls)
	-- whether request rolls, and who to reannounce is determined by the value of MSA_DROPDOWNMENU_MENU_VALUE
	--@param isThisItem true to reannounce on this item, false to reannounce on all items.
	function RCVotingFrame.reannounceOrRequestRollButton(candidateName, isThisItem)
		if type(MSA_DROPDOWNMENU_MENU_VALUE) ~= "string" then return end
		local namePred, sesPred
		if isThisItem then
			sesPred = function(k) return k==session or (not lootTable[k].awarded and addon:ItemIsItem(lootTable[k].link, lootTable[session].link)) end
		else
			sesPred = function(k) return not lootTable[k].awarded end
		end

		local isRoll = _G.MSA_DROPDOWNMENU_MENU_VALUE:find("^REQUESTROLL") and true or false

		local announceInChat = false
		if MSA_DROPDOWNMENU_MENU_VALUE:find("_CANDIDATE$") then
			namePred = candidateName
		elseif MSA_DROPDOWNMENU_MENU_VALUE:find("_GROUP$") then
			announceInChat = true -- Announce in chat when announce to group
			namePred = true
		elseif MSA_DROPDOWNMENU_MENU_VALUE:find("_ROLL$") then
			namePred = function(name) return lootTable[session].candidates[name].roll == lootTable[session].candidates[candidateName].roll end
		elseif MSA_DROPDOWNMENU_MENU_VALUE:find("_RESPONSE$") then
			namePred = function(name) return lootTable[session].candidates[name].response == lootTable[session].candidates[candidateName].response end
		else
			addon.Log:D("Unexpected dropdown menu value: "..tostring(MSA_DROPDOWNMENU_MENU_VALUE))
		end

		local noAutopass = isThisItem and MSA_DROPDOWNMENU_MENU_VALUE:find("_CANDIDATE$") and true or false

		if isThisItem then
			RCVotingFrame:ReannounceOrRequestRoll(namePred, sesPred, isRoll, noAutopass, announceInChat)
			RCVotingFrame.reannounceOrRequestRollPrint(RCVotingFrame.reannounceOrRequestRollText(candidateName), isThisItem, isRoll)
		else -- Need to confirm to reannounce for all items.
			local target = RCVotingFrame.reannounceOrRequestRollText(candidateName)
			LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_REANNOUNCE_ALL_ITEMS", {text=target, isRoll = isRoll,
				func = function()
					RCVotingFrame:ReannounceOrRequestRoll(namePred, sesPred, isRoll, noAutopass, announceInChat)
					RCVotingFrame.reannounceOrRequestRollPrint(target, isThisItem, isRoll)
				end })
		end

	end

	-- Print sth when the button or confirmation dialog is clicked.
	function RCVotingFrame.reannounceOrRequestRollPrint(target, isThisItem, isRoll)
		local itemText = isThisItem and L["This item"] or L["All unawarded items"]
		if isRoll then
			addon:Print(format(L["Requested rolls for 'item' from 'target'"], itemText, target))
		else
			addon:Print(format(L["Reannounced 'item' to 'target'"], itemText, target))
		end
	end
	--- The entries placed in the rightclick menu.
	-- Each level in the menu has it's own indexed entries, and each entry requires a text field as minimum,
	-- but can otherwise have the same values as normal DropDownMenus.
	-- To inject a new button, just call tinsert(RCVotingFrame.rightClickEntries[level], position, {--values})
	-- It shouldn't be nessecary to do more than once, just do it before the first session starts.
	--[[ Notes:
		Any value can be a function, which will be evaluated on creation. Functions gets candidateName and data (the data belonging to the candidate) as parameters.
		The func field also gets candidateName and data as params, but gets delivered as a function to the dropdown.
		There's three special fields to enable this kind of structure:
			onValue :String 				- This entry will only be shown if MSA_DROPDOWNMENU_MENU_VALUE matches onValue. This enables nesting.
			hidden  :boolean/function 	- The entry is only shown if this is false.
			special :String 				- Handles a couple of special cases that wasn't too suitable for the orignal creating (#lazy)
												- Cases: AWARD_FOR, CHANGE_RESPONSE, TIER_TOKENS
	]]
	RCVotingFrame.rightClickEntries = {
		{ -- Level 1
			{ -- 1 Title, player name
				text = function(name) return addon.Ambiguate(name) end,
				isTitle = true,
				notCheckable = true,
				disabled = true,
			},{ -- 2 Spacer
				text = "",
				notCheckable = true,
				disabled = true,
			},{ -- 3 Award
				text = L["Award"],
				notCheckable = true,
				func = function(name, data)
					LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_AWARD", RCVotingFrame:GetAwardPopupData(session, name, data))
				end,
			},{ -- 4 Award for
				text = L["Award for ..."],
				value = "AWARD_FOR",
				notCheckable = true,
				hasArrow = true,
			},{ -- 5 Spacer
				text = "",
				notCheckable = true,
				disabled = true,
			},{ -- 6 Award later
				text = L["Award later"],
				notCheckable = true,
				disabled = function()
					return not lootTable[session] or lootTable[session].bagged or lootTable[session].awarded
				end,
				func = function()
					LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_AWARD_LATER", {session=session, link=lootTable[session].link})
				end,
			},{ -- 7 Change response
				text = L["Change Response"],
				value = "CHANGE_RESPONSE",
				hasArrow = true,
				notCheckable = true,
			},{ -- 8 Reannounce
				text = L["Reannounce ..."],
				value = "REANNOUNCE",
				hasArrow = true,
				notCheckable = true,
			},{ -- 9 Add rolls
				text = L["Add rolls"],
				notCheckable = true,
				func = function() RCVotingFrame:DoRandomRolls(session) end,
			},{ -- 10 Reannounce and request rolls
				text = _G.REQUEST_ROLL.."...",
				value = "REQUESTROLL",
				hasArrow = true,
				notCheckable = true,
			},{ -- 11 Remove from consideration
				text = L["Remove from consideration"],
				notCheckable = true,
				func = function(name)
					addon:Send("group", "change_response", session, name, "REMOVED")
				end,
			},
		},
		{ -- Level 2
			{ -- 1 AWARD_FOR
				special = "AWARD_FOR",
			},{ -- 2 CHANGE_RESPONSE
				special = "CHANGE_RESPONSE",
			}, -- 3,4,5,6,7,8,9 Reannounce (and request rolls) categories
			RCVotingFrame.rennaounceOrRequestRollCreateCategoryButton("CANDIDATE"),
			RCVotingFrame.rennaounceOrRequestRollCreateCategoryButton("GROUP"),
			RCVotingFrame.rennaounceOrRequestRollCreateCategoryButton("ROLL"),
			RCVotingFrame.rennaounceOrRequestRollCreateCategoryButton("RESPONSE"),
		},
		{ -- Level 3
			{ -- 1 Header text of reannounce (and request rolls)
				onValue = function() return type(_G.MSA_DROPDOWNMENU_MENU_VALUE)=="string" and
					(MSA_DROPDOWNMENU_MENU_VALUE:find("^REQUESTROLL") or MSA_DROPDOWNMENU_MENU_VALUE:find("^REANNOUNCE"))
				end,
				text = function(candidateName) return RCVotingFrame.reannounceOrRequestRollText(candidateName) end,
				notCheckable = true,
				isTitle = true,
				func = function(candidateName)
					return RCVotingFrame.reannounceOrRequestRollButton(candidateName, true)
				end,
			},
			{ -- 2 This item
				onValue = function() return type(_G.MSA_DROPDOWNMENU_MENU_VALUE)=="string" and
					(MSA_DROPDOWNMENU_MENU_VALUE:find("^REQUESTROLL") or MSA_DROPDOWNMENU_MENU_VALUE:find("^REANNOUNCE"))
				end,
				text = function()
					if type(_G.MSA_DROPDOWNMENU_MENU_VALUE)=="string" and MSA_DROPDOWNMENU_MENU_VALUE:find("^REQUESTROLL") then
						return L["This item"].." ("..REQUEST_ROLL..")"
					else
						return L["This item"]
					end
				end,
				notCheckable = true,
				func = function(candidateName)
					return RCVotingFrame.reannounceOrRequestRollButton(candidateName, true)
				end,
			},{ -- 3 All unawarded items, only shown for "candidate" and "group" reannounce
				onValue = function() return type(_G.MSA_DROPDOWNMENU_MENU_VALUE)=="string" and
					(MSA_DROPDOWNMENU_MENU_VALUE:find("^REQUESTROLL") or MSA_DROPDOWNMENU_MENU_VALUE:find("^REANNOUNCE")) and
					(MSA_DROPDOWNMENU_MENU_VALUE:find("_CANDIDATE$") or MSA_DROPDOWNMENU_MENU_VALUE:find("_GROUP$"))
				end,
				text = function()
					if type(_G.MSA_DROPDOWNMENU_MENU_VALUE)=="string" and MSA_DROPDOWNMENU_MENU_VALUE:find("^REQUESTROLL") then
						return L["All unawarded items"].." ("..REQUEST_ROLL..")"
					else
						return L["All unawarded items"]
					end
				end,
				notCheckable = true,
				func = function(candidateName)
					return RCVotingFrame.reannounceOrRequestRollButton(candidateName, false)
				end,
			},
		},
		-- More levels can be added with tinsert(RCVotingFrame.rightClickEntries, {-- new level})
	}
	-- NOTE Take care of info[] values when inserting new buttons
	local info = MSA_DropDownMenu_CreateInfo() -- Efficiency :)
	function RCVotingFrame.RightClickMenu(menu, level)
		if not addon.isMasterLooter then return end

		local candidateName = menu.name
		local data = lootTable[session].candidates[candidateName] -- Shorthand

		local value = _G.MSA_DROPDOWNMENU_MENU_VALUE
		for _, entry in ipairs(RCVotingFrame.rightClickEntries[level]) do
			info = MSA_DropDownMenu_CreateInfo()
			if not entry.special then
				if not entry.onValue or entry.onValue == value or (type(entry.onValue)=="function" and entry.onValue(candidateName, data)) then
					if (entry.hidden and type(entry.hidden) == "function" and not entry.hidden(candidateName, data)) or not entry.hidden then
						for name, val in pairs(entry) do
							if name == "func" then
								info[name] = function() return val(candidateName, data) end -- This needs to be set as a func, but fed with our params
							elseif type(val) == "function" then
								info[name] = val(candidateName, data) -- This needs to be evaluated
							else
								info[name] = val
							end
						end
						MSA_DropDownMenu_AddButton(info, level)
					end
				end
			elseif value == "AWARD_FOR" and entry.special == value then
				for k,v in ipairs(db.awardReasons) do
					if k > db.numAwardReasons then break end
					info.text = v.text
					info.notCheckable = true
					info.func = function()
						LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_AWARD", RCVotingFrame:GetAwardPopupData(session, candidateName, data, v))
					end
					MSA_DropDownMenu_AddButton(info, level)
				end
			elseif value == "CHANGE_RESPONSE" and entry.special == value then
				local v;
				for i = 1, addon:GetNumButtons(lootTable[session].typeCode or lootTable[session].equipLoc) do
					v = addon:GetResponse(lootTable[session].typeCode or lootTable[session].equipLoc, i)
					info.text = v.text
					info.colorCode = "|cff"..addon.Utils:RGBToHex(unpack(v.color))
					info.notCheckable = true
					info.func = function()
							addon:Send("group", "change_response", session, candidateName, i)
					end
					MSA_DropDownMenu_AddButton(info, level)
				end
				-- Add pass button as well
				info.text = db.responses.default.PASS.text
				info.colorCode = "|cff"..addon.Utils:RGBToHex(unpack(db.responses.default.PASS.color))
				info.notCheckable = true
				info.func = function()
						addon:Send("group", "change_response", session, candidateName, "PASS")
				end
				MSA_DropDownMenu_AddButton(info, level)
				info = MSA_DropDownMenu_CreateInfo()
				if addon.debug then -- Add all possible responses when debugging
					for k,val in pairs(db.responses.default) do
						if type(k) ~= "number" and k ~= "tier" and k~= "relic" and k ~= "PASS" then
							info.text = val.text
							info.colorCode = "|cff"..addon.Utils:RGBToHex(unpack(val.color))
							info.notCheckable = true
							info.func = function()
									addon:Send("group", "change_response", session, candidateName, k)
							end
							MSA_DropDownMenu_AddButton(info, level)
						end
					end
				end
				info = MSA_DropDownMenu_CreateInfo()
			end
		end
	end

	function RCVotingFrame.FilterMenu(menu, level)
		if level == 1 then -- Redundant

			if not db.modules["RCVotingFrame"].filters then -- Create the db entry
				addon.Log:D("Created VotingFrame filters")
				db.modules["RCVotingFrame"].filters = {}
			end

			-- Build the data table:
			local data = {["STATUS"] = true, ["PASS"] = true, ["AUTOPASS"] = true, default = {}}

			for i = 1, addon:GetNumButtons() do
				data[i] = i
			end

			local info = MSA_DropDownMenu_CreateInfo()
			info.text = _G.GENERAL
			info.isTitle = true
			info.notCheckable = true
			info.disabled = true
			MSA_DropDownMenu_AddButton(info, level)

			info = MSA_DropDownMenu_CreateInfo()
			info.text = L["Always show owner"]
			info.func = function()
				addon.Log:D("Update Filter")
				db.modules["RCVotingFrame"].filters.alwaysShowOwner = not db.modules["RCVotingFrame"].filters.alwaysShowOwner
				RCVotingFrame:Update(true)
			end
			info.checked = db.modules["RCVotingFrame"].filters.alwaysShowOwner
			MSA_DropDownMenu_AddButton(info, level)

			info = MSA_DropDownMenu_CreateInfo()
			info.text = L["Candidates that can't use the item"]
			info.func = function()
				addon.Log:D("Update Filter")
				db.modules["RCVotingFrame"].filters.showPlayersCantUseTheItem = not db.modules["RCVotingFrame"].filters.showPlayersCantUseTheItem
				RCVotingFrame:Update(true)
			end
			info.checked = db.modules["RCVotingFrame"].filters.showPlayersCantUseTheItem
			MSA_DropDownMenu_AddButton(info, level)

			info = MSA_DropDownMenu_CreateInfo()
			info.text = L["Responses"]
			info.isTitle = true
			info.notCheckable = true
			info.disabled = true
			MSA_DropDownMenu_AddButton(info, level)

			info = MSA_DropDownMenu_CreateInfo()
			for k in ipairs(data) do -- Make sure normal responses are on top
				info.text = addon:GetResponse("", k).text
				info.colorCode = "|cff"..addon.Utils:RGBToHex(addon:GetResponseColor(nil,k))
				info.func = function()
					addon.Log:D("Update Filter")
					db.modules["RCVotingFrame"].filters[k] = not db.modules["RCVotingFrame"].filters[k]
					RCVotingFrame:Update(true)
				end
				info.checked = db.modules["RCVotingFrame"].filters[k]
				MSA_DropDownMenu_AddButton(info, level)
			end
			for k in pairs(data) do -- A bit redundency, but it makes sure these "specials" comes last
				if type(k) == "string" and k ~= "tier" and k ~= "relic" then
					if k == "STATUS" then
						info.text = L["Status texts"]
						info.colorCode = "|cffde34e2" -- purpleish
					else
						info.text = addon:GetResponse("",k).text
						info.colorCode = "|cff"..addon.Utils:RGBToHex(addon:GetResponseColor(nil,k))
					end
					info.func = function()
						addon.Log:D("Update Filter")
						db.modules["RCVotingFrame"].filters[k] = not db.modules["RCVotingFrame"].filters[k]
						RCVotingFrame:Update(true)
					end
					info.checked = db.modules["RCVotingFrame"].filters[k]
					MSA_DropDownMenu_AddButton(info, level)
				end
			end

			info = MSA_DropDownMenu_CreateInfo()
			info.text = _G.RANK
			info.isTitle = true
			info.notCheckable = true
			info.disabled = true
			MSA_DropDownMenu_AddButton(info, level)

			info = MSA_DropDownMenu_CreateInfo()
			info.text = _G.RANK.."..."
			info.notCheckable = true
			info.hasArrow = true
			info.value = "FILTER_RANK"
			MSA_DropDownMenu_AddButton(info, level)
		elseif level == 2 then
			if MSA_DROPDOWNMENU_MENU_VALUE == "FILTER_RANK" then
				info = MSA_DropDownMenu_CreateInfo()
				if IsInGuild() then
					for k = 1, GuildControlGetNumRanks() do
						info.text = GuildControlGetRankName(k)
						info.func = function()
							addon.Log:D("Update rank Filter", k)
							db.modules["RCVotingFrame"].filters.ranks[k] = not db.modules["RCVotingFrame"].filters.ranks[k]
							RCVotingFrame:Update(true)
						end
						info.checked = db.modules["RCVotingFrame"].filters.ranks[k]
						MSA_DropDownMenu_AddButton(info, level)
					end
				end

				info.text = L["Not in your guild"]
				info.func = function()
					addon.Log:D("Update rank Filter", "Not in your guild")
					db.modules["RCVotingFrame"].filters.ranks.notInYourGuild = not db.modules["RCVotingFrame"].filters.ranks.notInYourGuild
					RCVotingFrame:Update(true)
				end
				info.checked = db.modules["RCVotingFrame"].filters.ranks.notInYourGuild
				MSA_DropDownMenu_AddButton(info, level)
			end
		end
	end

	function RCVotingFrame.EnchantersMenu(menu, level)
		if level == 1 then
			local added = false
			info = MSA_DropDownMenu_CreateInfo()
			if not db.disenchant then
				return addon:Print(L["You haven't selected an award reason to use for disenchanting!"])
			end
			for name in addon:GroupIterator() do
				local player = Player:Get(name)
				if player.enchanter then
					local c = addon:GetClassColor(player.class)
					info.text = "|cff"..addon.Utils:RGBToHex(c.r, c.g, c.b)..addon.Ambiguate(name).."|r "..tostring(player.enchantingLvl)
					info.notCheckable = true
					info.func = function()
						for _,v1 in ipairs(db.awardReasons) do
							if v1.disenchant then
								local data = lootTable[session].candidates[name] -- Shorthand
								LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_AWARD", RCVotingFrame:GetAwardPopupData(session, name, data, v1))
								return
							end
						end
					end
					added = true
					MSA_DropDownMenu_AddButton(info, level)
				end
			end
			if not added then -- No enchanters available
				info.text = L["No (dis)enchanters found"]
				info.notCheckable = true
				info.isTitle = true
				MSA_DropDownMenu_AddButton(info, level)
			end
		end
	end
end

function RCVotingFrame:GetItemStatus(item)
	-- addon.Log:D("GetitemStatus", item)
	if not item then return "" end
	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GameTooltip:SetHyperlink(item)
	local text = ""
	if GameTooltip:NumLines() > 1 then -- check that there is something here
		local line = getglobal('GameTooltipTextLeft2') -- Should always be line 2
		local t =  line:GetText()
		-- The following color string should be there if we have a green status text
		if t then
			if strfind(t, "cFF 0FF 0") then
				text = t
			end
		end
	end
	GameTooltip:Hide()
	return text
end
