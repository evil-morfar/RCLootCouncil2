---	votingFrame.lua	Displays everything related to handling loot for all members.
--	Will only show certain aspects depending on addon.isMasterLooter, addon.isCouncil and addon.mldb.observe.
-- DefaultModule
-- @author	Potdisc
-- Create Date : 12/15/2014 8:54:35 PM

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCVotingFrame = addon:NewModule("RCVotingFrame", "AceComm-3.0", "AceTimer-3.0")
local LibDialog = LibStub("LibDialog-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local ROW_HEIGHT = 20;
local NUM_ROWS = 15;
local db
local session = 1 -- The session we're viewing - see :GetCurrentSession()
local lootTable = {} -- Table containing all data, lib-st cells pulls data from this
local sessionButtons = {}
local moreInfo = false -- Show more info frame?
local active = false -- Are we currently in session?
local councilInGroup = {}
local menuFrame -- Right click menu frame
local filterMenu -- Filter drop down menu
local enchanters -- Enchanters drop down menu frame
local guildRanks = {} -- returned from addon:GetGuildRanks()
local GuildRankSort, ResponseSort -- Initialize now to avoid errors
local defaultScrollTableData = {} -- See below
local moreInfoData = {}

function RCVotingFrame:OnInitialize()
	-- Contains all the default data needed for the scroll table
	-- The default values are in sorted order
	defaultScrollTableData = {
		{ name = "",				DoCellUpdate = RCVotingFrame.SetCellClass,		colName = "class",	sortnext = 2,		width = 20, },										-- 1 Class
		{ name = L["Name"],		DoCellUpdate = RCVotingFrame.SetCellName,			colName = "name",								width = 120,},										-- 2 Candidate Name
		{ name = L["Rank"],		DoCellUpdate = RCVotingFrame.SetCellRank,			colName = "rank",		sortnext = 5,		width = 95, comparesort = GuildRankSort,},-- 3 Guild rank
		{ name = L["Role"],		DoCellUpdate = RCVotingFrame.SetCellRole,			colName = "role",		sortnext = 5,		width = 55, },										-- 4 Role
		{ name = L["Response"],	DoCellUpdate = RCVotingFrame.SetCellResponse,	colName = "response",sortnext = 13,		width = 240, comparesort = ResponseSort,},-- 5 Response
		{ name = L["ilvl"],		DoCellUpdate = RCVotingFrame.SetCellIlvl,			colName = "ilvl",		sortnext = 7,		width = 45, },										-- 6 Total ilvl
		{ name = L["Diff"],		DoCellUpdate = RCVotingFrame.SetCellDiff,			colName = "diff",								width = 40, },										-- 7 ilvl difference
		{ name = L["g1"],			DoCellUpdate = RCVotingFrame.SetCellGear,			colName = "gear1",	sortnext = 5,		width = 20, align = "CENTER", },				-- 8 Current gear 1
		{ name = L["g2"],			DoCellUpdate = RCVotingFrame.SetCellGear,			colName = "gear2",	sortnext = 5,		width = 20, align = "CENTER", },				-- 9 Current gear 2
		{ name = L["Votes"], 	DoCellUpdate = RCVotingFrame.SetCellVotes,		colName = "votes",	sortnext = 7,		width = 40, align = "CENTER", },				-- 10 Number of votes
		{ name = L["Vote"],		DoCellUpdate = RCVotingFrame.SetCellVote,			colName = "vote",		sortnext = 10,		width = 60, align = "CENTER", },				-- 11 Vote button
		{ name = L["Notes"],		DoCellUpdate = RCVotingFrame.SetCellNote,			colName = "note",								width = 40, align = "CENTER", },				-- 12 Note icon
		{ name = L["Roll"],		DoCellUpdate = RCVotingFrame.SetCellRoll, 		colName = "roll",		sortnext = 10,		width = 30, align = "CENTER", },				-- 13 Roll
	}
	-- The actual table being worked on, new entries should be added to this table "tinsert(RCVotingFrame.scrollCols, data)"
	-- If you want to add or remove columns, you should do so on your OnInitialize. See RCVotingFrame:RemoveColumn() for removal.
	self.scrollCols = {unpack(defaultScrollTableData)}

	menuFrame = CreateFrame("Frame", "RCLootCouncil_VotingFrame_RightclickMenu", UIParent, "Lib_UIDropDownMenuTemplate")
	filterMenu = CreateFrame("Frame", "RCLootCouncil_VotingFrame_FilterMenu", UIParent, "Lib_UIDropDownMenuTemplate")
	enchanters = CreateFrame("Frame", "RCLootCouncil_VotingFrame_EnchantersMenu", UIParent, "Lib_UIDropDownMenuTemplate")
	Lib_UIDropDownMenu_Initialize(menuFrame, self.RightClickMenu, "MENU")
	Lib_UIDropDownMenu_Initialize(filterMenu, self.FilterMenu)
	Lib_UIDropDownMenu_Initialize(enchanters, self.EnchantersMenu)
end

function RCVotingFrame:OnEnable()
	self:RegisterComm("RCLootCouncil")
	db = addon:Getdb()
	active = true
	moreInfo = db.modules["RCVotingFrame"].moreInfo
	moreInfoData = addon:GetLootDBStatistics()
	self.frame = self:GetFrame()
	self:ScheduleTimer("CandidateCheck", 20)
	guildRanks = addon:GetGuildRanks()
	addon:Debug("RCVotingFrame", "enabled")
end

function RCVotingFrame:OnDisable() -- We never really call this
	self:Hide()
	self.frame:SetParent(nil)
	self.frame = nil
	wipe(lootTable)
	active = false
	session = 1
	self:UnregisterAllComm()
end

function RCVotingFrame:Hide()
	addon:Debug("Hide VotingFrame")
	self.frame.moreInfo:Hide()
	self.frame:Hide()
end

function RCVotingFrame:Show()
	if self.frame and lootTable[session] then
		councilInGroup = addon.council
		self.frame:Show()
		self:SwitchSession(session)
	else
		addon:Print(L["No session running"])
	end
end

function RCVotingFrame:EndSession(hide)
	active = false -- The session has ended, so deactivate
	self:Update()
	if hide then self:Hide() end -- Hide if need be
end

function RCVotingFrame:CandidateCheck()
	if not addon.candidates[addon.playerName] and addon.masterLooter then -- If our own name isn't there, we assume it's not received
		addon:DebugLog("CandidateCheck", "failed")
		addon:SendCommand(addon.masterLooter, "candidates_request")
		self:ScheduleTimer("CandidateCheck", 20) -- check again in 20
	end
end

--- Removes a specific entry from the voting frame's columns
-- Takes either index or colName as the identifier, and returns the removed rows
-- if succesful, or nil if not. Should be called before any session begins.
function RCVotingFrame:RemoveColumn(id)
	addon:Debug("Removing Column", id)
	if type(id) == "number" then
		return tremove(self.scrollCols, id)
	else
		for i, col in ipairs(self.scrollCols) do
			if col.colName == id then
				return tremove(self.scrollCols, i)
			end
		end
	end
end

function RCVotingFrame:OnCommReceived(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncil" then
		-- data is always a table to be unpacked
		local test, command, data = addon:Deserialize(serializedMsg)
		if addon:HandleXRealmComms(self, command, data, sender) then return end

		if test then
			if command == "vote" then
				if addon:IsCouncil(sender) then
					local s, name, vote = unpack(data)
					self:HandleVote(s, name, vote, sender)
				else
					addon:Debug("Non-council member (".. tostring(sender) .. ") sent a vote!")
				end

			elseif command == "change_response" and addon:UnitIsUnit(sender, addon.masterLooter) then
				local ses, name, response, isTier, isRelic = unpack(data)
				self:SetCandidateData(ses, name, "isTier", isTier)
				self:SetCandidateData(ses, name, "isRelic", isRelic)
				self:SetCandidateData(ses, name, "response", response)
				self:Update()

			elseif command == "lootAck" then
				local name = unpack(data)
				for i = 1, #lootTable do
					self:SetCandidateData(i, name, "response", "WAIT")
				end
				self:Update()

			elseif command == "awarded" and addon:UnitIsUnit(sender, addon.masterLooter) then
				self:ScheduleTimer(function()
					moreInfoData = addon:GetLootDBStatistics() -- Just update it on every award
				end, 1) -- Make sure we've received the history data before updating
				local s, winner = unpack(data)
				if not lootTable[s] then return end -- We might not have lootTable - e.g. if we just reloaded
				lootTable[s].awarded = winner
				if addon.isMasterLooter and session ~= #lootTable then -- ML should move to the next item on award
					self:SwitchSession(session + 1)
				else
					self:SwitchSession(session) -- Use switch session to update awardstring
				end

			elseif command == "offline_timer" and addon:UnitIsUnit(sender, addon.masterLooter) then
				for i = 1, #lootTable do
					for name in pairs(lootTable[i].candidates) do
						if self:GetCandidateData(i, name, "response") == "ANNOUNCED" then
							addon:DebugLog("No response from:", name)
							self:SetCandidateData(i, name, "response", "NOTHING")
						end
					end
				end
				self:Update()

			elseif command == "lootTable" and addon:UnitIsUnit(sender, addon.masterLooter) then
				active = true
				local lootTable = unpack(data)
				addon:LocalizeLootTable(lootTable)
				self:Setup(lootTable)
				if not addon.enabled then return end -- We just want things ready
				if db.autoOpen then
					self:Show()
				else
					addon:Print(L["A new session has begun, type '/rc open' to open the voting frame."])
				end

			elseif command == "response" then
				local session, name, t = unpack(data)
				for k,v in pairs(t) do
					self:SetCandidateData(session, name, k, v)
				end
				self:Update()

			elseif command == "rolls" then
				if addon:UnitIsUnit(sender, addon.masterLooter) then
					local session, table = unpack(data)
					for name, roll in pairs(table) do
						self:SetCandidateData(session, name, "roll", roll)
					end
					self:Update()
				else
					addon:Debug("Non-ML", sender, "sent rolls!")
				end

			elseif command == "reconnectData" and addon:UnitIsUnit(sender, addon.masterLooter) then
				-- We assume we always receive a regular lootTable command first
				-- All we need to do is updating the loot table and figure out if we've voted previously
				lootTable = unpack(data)
				for _, data in ipairs(lootTable) do
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
		end
	end
end

-- Getter/Setter for candidate data
-- Handles errors
function RCVotingFrame:SetCandidateData(session, candidate, data, val)
	local function Set(session, candidate, data, val)
		lootTable[session].candidates[candidate][data] = val
	end
	local ok, arg = pcall(Set, session, candidate, data, val)
	if not ok then addon:Debug("Error in 'SetCandidateData':", arg, session, candidate, data, val) end
end

function RCVotingFrame:GetCandidateData(session, candidate, data)
	local function Get(session, candidate, data)
		return lootTable[session].candidates[candidate][data]
	end
	local ok, arg = pcall(Get, session, candidate, data)
	if not ok then addon:Debug("Error in 'GetCandidateData':", arg, session, candidate, data)
	else return arg end
end

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

function RCVotingFrame:Setup(table)
	--lootTable[session] = {bagged, lootSlot, awarded, name, link, quality, ilvl, type, subType, equipLoc, texture, boe}
	lootTable = table -- Extract all the data we get
	for session, t in ipairs(lootTable) do -- and build the rest (candidates)
		lootTable[session].haveVoted = false -- Have we voted for ANY candidate in this session?
		t.candidates = {}
		for name, v in pairs(addon.candidates) do
			t.candidates[name] = {
				class = v.class,
				rank = v.rank,
				role = v.role,
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
	-- Hide unused session buttons
	for i = #lootTable+1, #sessionButtons do
		sessionButtons[i]:Hide()
	end
	session = 1
	self:BuildST()
	self:SwitchSession(session)
	if db.autoAddRolls then for i = 1, #lootTable do self:DoRandomRolls(i) end end
end

function RCVotingFrame:HandleVote(session, name, vote, voter)
	-- Do the vote
	lootTable[session].candidates[name].votes = lootTable[session].candidates[name].votes + vote
	-- And update voters names
	if vote == 1 then
		tinsert(lootTable[session].candidates[name].voters, addon.Ambiguate(voter))
	else
		for i, n in ipairs(lootTable[session].candidates[name].voters) do
			if addon:UnitIsUnit(voter, n) then
				tremove(lootTable[session].candidates[name].voters, i)
				break
			end
		end
	end
	self.frame.st:Refresh()
	self:UpdatePeopleToVote()
end

function RCVotingFrame:DoRandomRolls(ses)
	local table = {}
	for name, v in pairs (lootTable[ses].candidates) do
		table[name] = math.random(100)
	end
	addon:SendCommand("group", "rolls", ses, table)
end

----------------------------------------------------------------- -
--	Visuals
-- @section Visuals
------------------------------------------------------------------
function RCVotingFrame:Update()
	if not self.frame then return end -- No updates when it doesn't exist
	self.frame.st:SortData()
	-- update awardString
	if lootTable[session] and lootTable[session].awarded then
		self.frame.awardString:Show()
		local name = lootTable[session].awarded
		self.frame.awardStringPlayer:SetText(addon.Ambiguate(name))
		local c = addon:GetClassColor(lootTable[session].candidates[name].class)
		self.frame.awardStringPlayer:SetTextColor(c.r,c.g,c.b,c.a)
		self.frame.awardStringPlayer:Show()
		-- Hack-reuse the SetCellClassIcon function
		addon.SetCellClassIcon(nil,self.frame.awardStringPlayer.classIcon,nil,nil,nil,nil,nil,nil,nil, lootTable[session].candidates[name].class)
		self.frame.awardStringPlayer.classIcon:Show()
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
			self.frame.abortBtn:SetText(L["Close"])
		end
		self.frame.disenchant:Show()
	else -- Non-MLs:
		self.frame.abortBtn:SetText(L["Close"])
		self.frame.disenchant:Hide()
	end
end

function RCVotingFrame:SwitchSession(s)
	addon:Debug("SwitchSession", s)
	addon:SendMessage("RCSessionChangedPre", s)
	-- Start with setting up some statics
	local old = session
	session = s
	local t = lootTable[s] -- Shortcut
	self.frame.itemIcon:SetNormalTexture(t.texture)
	self.frame.itemText:SetText(t.link)
	self.frame.iState:SetText(self:GetItemStatus(t.link))
	self.frame.itemLvl:SetText(format(L["ilvl: x"], t.ilvl))
	-- Set a proper item type text

	self.frame.itemType:SetText(addon:GetItemTypeText(t.link, t.subType, t.equipLoc, t.token, t.relic))

	-- Update the session buttons
	sessionButtons[s] = self:UpdateSessionButton(s, t.texture, t.link, t.awarded)
	sessionButtons[old] = self:UpdateSessionButton(old, lootTable[old].texture, lootTable[old].link, lootTable[old].awarded)

	-- Since we switched sessions, we want to sort by response
	local j = 1
	for i in ipairs(self.frame.st.cols) do
		self.frame.st.cols[i].sort = nil
		if self.frame.st.cols[i].colName == "response" then j = i end
	end
	self.frame.st.cols[j].sort = "asc"
	FauxScrollFrame_OnVerticalScroll(self.frame.st.scrollframe, 0, self.frame.st.rowHeight, function() self.frame.st:Refresh() end) -- Reset scrolling to 0
	self:Update()
	self:UpdatePeopleToVote()
	addon:SendMessage("RCSessionChangedPost", s)
end

function RCVotingFrame:BuildST()
	local rows = {}
	local i = 1
	-- We need to build the columns from the data in self.scrollCols
	-- We only really need the colName and value to get added
	for name in pairs(addon.candidates) do
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

	local color = addon:GetClassColor(self:GetCandidateData(session, name, "class"))
	local tip = self.frame.moreInfo -- shortening
	tip:SetOwner(self.frame, "ANCHOR_RIGHT")

	tip:AddLine(addon.Ambiguate(name), color.r, color.g, color.b)
	if moreInfoData and moreInfoData[name] then
		local r,g,b
		tip:AddLine(L["Latest item(s) won"])
		for i, v in ipairs(moreInfoData[name]) do -- extract latest awarded items
			if v[3] then r,g,b = unpack(v[3],1,3) end
			tip:AddDoubleLine(v[1], v[2], nil,nil,nil, r or 1, g or 1, b or 1)
		end
		tip:AddLine(" ") -- spacer
		tip:AddLine(L["Totals"])
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
	else
		tip:AddLine(L["No entries in the Loot History"])
	end
	tip:SetScale(self.frame:GetScale() * 0.6) -- Make it a bit smaller, as it's too wide otherwise
	tip:Show()
	tip:SetAnchorType("ANCHOR_RIGHT", 0, -tip:GetHeight())
end

function RCVotingFrame:GetFrame()
	if self.frame then return self.frame end

	-- Container and title
	local f = addon:CreateFrame("DefaultRCLootCouncilFrame", "votingframe", L["RCLootCouncil Voting Frame"], 250, 420)
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
					if active then
						menuFrame.name = data[realrow].name
						Lib_ToggleDropDownMenu(1, nil, menuFrame, cellFrame, 0, 0);
					else
						addon:Print(L["You cannot use the menu when the session has ended."])
					end
				elseif button == "LeftButton" and row then -- Update more info
					self:UpdateMoreInfo(realrow, data)
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
	local item = CreateFrame("Button", nil, f.content)
	item:EnableMouse()
    item:SetNormalTexture("Interface/ICONS/INV_Misc_QuestionMark")
    item:SetScript("OnEnter", function()
		if not lootTable then return; end
		addon:CreateHypertip(lootTable[session].link)
	end)
	item:SetScript("OnLeave", function() addon:HideTooltip() end)
	item:SetScript("OnClick", function()
		if not lootTable then return; end
	    if ( IsModifiedClick() ) then
		    HandleModifiedItemClick(lootTable[session].link);
        end
    end);
	item:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -20)
	item:SetSize(50,50)
	f.itemIcon = item

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
	--#end----------------------------

	-- Abort button
	local b1 = addon:CreateButton(L["Close"], f.content)
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

	-- Filter
	local b3 = addon:CreateButton(L["Filter"], f.content)
	b3:SetPoint("RIGHT", b1, "LEFT", -10, 0)
	b3:SetScript("OnClick", function(self) Lib_ToggleDropDownMenu(1, nil, filterMenu, self, 0, 0) end )
	b3:SetScript("OnEnter", function() addon:CreateTooltip(L["Deselect responses to filter them"]) end)
	b3:SetScript("OnLeave", function() addon:HideTooltip() end)
	f.filter = b3

	-- Disenchant button
	local b4 = addon:CreateButton(L["Disenchant"], f.content)
	b4:SetPoint("RIGHT", b3, "LEFT", -10, 0)
	b4:SetScript("OnClick", function(self) Lib_ToggleDropDownMenu(1, nil, enchanters, self, 0, 0) end )
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

	-- Award string
	local awdstr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	awdstr:SetPoint("CENTER", f.content, "TOP", 0, -53)
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

function RCVotingFrame:UpdatePeopleToVote()
	local voters = {}
	-- Find out who have voted
	for name in pairs(lootTable[session].candidates) do
		for _, voter in pairs(lootTable[session].candidates[name].voters) do
			if not tContains(voters, voter) then
				tinsert(voters, voter)
			end
		end
	end
	if #councilInGroup == 0 then
		self.frame.rollResult.text:SetText(L["Couldn't find any councilmembers in the group"])
		self.frame.rollResult.text:SetTextColor(1,0,0,1) -- Red
	elseif #voters == #councilInGroup then
		self.frame.rollResult.text:SetText(L["Everyone have voted"])
		self.frame.rollResult.text:SetTextColor(0,1,0,1) -- Green
	elseif #voters < #councilInGroup then
		self.frame.rollResult.text:SetText(format(L["x out of x have voted"], #voters, #councilInGroup))
		self.frame.rollResult.text:SetTextColor(1,1,0,1) -- Yellow
	else
		addon:Debug("#voters > #councilInGroup ?")
	end
	self.frame.rollResult:SetScript("OnEnter", function()
		addon:CreateTooltip(L["The following council members have voted"], unpack(voters))
	end)
	self.frame.rollResult:SetWidth(self.frame.rollResult.text:GetStringWidth())
end

function RCVotingFrame:UpdateSessionButton(i, texture, link, awarded)
	local btn = sessionButtons[i]
	if not btn then -- create the button
		btn = CreateFrame("Button", "RCButton"..i, self.frame.sessionToggleFrame)
		btn:SetSize(40,40)
		--btn:SetText(i)
		if i == 1 then
			btn:SetPoint("TOPRIGHT", self.frame.sessionToggleFrame)
		elseif mod(i,10) == 1 then
			btn:SetPoint("TOPRIGHT", sessionButtons[i-10], "TOPLEFT", -2, 0)
		else
			btn:SetPoint("TOP", sessionButtons[i-1], "BOTTOM", 0, -2)
		end
		btn:SetScript("Onclick", function() RCVotingFrame:SwitchSession(i); end)
		btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
		btn:GetHighlightTexture():SetBlendMode("ADD")
		btn:SetNormalTexture(texture or "Interface\\InventoryItems\\WoWUnknownItem01")
		btn:GetNormalTexture():SetDrawLayer("BACKGROUND")
	end
	-- then update it
	btn:SetNormalTexture(texture or "Interface\\InventoryItems\\WoWUnknownItem01")
	-- Set the colored border and tooltips
	btn:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 18,
		--insets = { left = -4, right = -4, top = -4, bottom = -4 }
	})
	local lines = { format(L["Click to switch to 'item'"], link) }
	if i == session then
		btn:SetBackdropBorderColor(1,1,0,1) -- yellow
		--btn:SetBackdropColor(1,1,1,1)
		btn:GetNormalTexture():SetVertexColor(1,1,1)
	elseif awarded then
		btn:SetBackdropBorderColor(0,1,0,1) -- green
		--btn:SetBackdropColor(1,1,1,0.8)
		btn:GetNormalTexture():SetVertexColor(0.8,0.8,0.8)
		tinsert(lines, L["This item has been awarded"])
	else
		btn:SetBackdropBorderColor(1,1,1,1) -- white
		--btn:SetBackdropColor(0.5,0.5,0.5,0.8)
		btn:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
	end
	btn:SetScript("OnEnter", function() addon:CreateTooltip(unpack(lines)) end)
	btn:SetScript("OnLeave", function() addon:HideTooltip() end)
	return btn
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

function RCVotingFrame.SetCellClass(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
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
	frame.text:SetText(addon.Ambiguate(name))
	local c = addon:GetClassColor(lootTable[session].candidates[name].class)
	frame.text:SetTextColor(c.r, c.g, c.b, c.a)
	data[realrow].cols[column].value = name or ""
end

function RCVotingFrame.SetCellRank(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	local isTier = lootTable[session].candidates[name].isTier
	local isRelic = lootTable[session].candidates[name].isRelic
	frame.text:SetText(lootTable[session].candidates[name].rank)
	frame.text:SetTextColor(addon:GetResponseColor(lootTable[session].candidates[name].response,isTier, isRelic))
	data[realrow].cols[column].value = lootTable[session].candidates[name].rank or ""
end

function RCVotingFrame.SetCellRole(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	local isTier = lootTable[session].candidates[name].isTier
	local isRelic = lootTable[session].candidates[name].isRelic
	local role = addon.TranslateRole(lootTable[session].candidates[name].role)
	frame.text:SetText(role)
	frame.text:SetTextColor(addon:GetResponseColor(lootTable[session].candidates[name].response,isTier,isRelic))
	data[realrow].cols[column].value = role or ""
end

function RCVotingFrame.SetCellResponse(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	local isTier = lootTable[session].candidates[name].isTier
	local isRelic = lootTable[session].candidates[name].isRelic
	frame.text:SetText(addon:GetResponseText(lootTable[session].candidates[name].response, isTier, isRelic))
	frame.text:SetTextColor(addon:GetResponseColor(lootTable[session].candidates[name].response, isTier, isRelic))
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
				addon:CreateTooltip(L["Voters"], unpack(lootTable[session].candidates[name].voters))
			end
		end
	end)
	frame:SetScript("OnLeave", function() addon:HideTooltip() end)
	local val = lootTable[session].candidates[name].votes
	data[realrow].cols[column].value = val -- Set the value for sorting reasons
	frame.text:SetText(val)

	if addon.mldb.hideVotes then
		if not lootTable[session].haveVoted then frame.text:SetText(0) end
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
			addon:Debug("Vote button pressed")
			if lootTable[session].candidates[name].haveVoted then -- unvote
				addon:SendCommand("group", "vote", session, name, -1)
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
				addon:SendCommand("group", "vote", session, name, 1)
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
		f:SetScript("OnEnter", function() addon:CreateTooltip(L["Note"], note)	end)
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
	local response = lootTable[session].candidates[row.name].response
	if response == "AUTOPASS" or response == "PASS" or type(response) == "number" then
		if lootTable[session].token and addon.mldb.tierButtonsEnabled and type(response) == "number" then
			return db.modules["RCVotingFrame"].filters.tier[response]
		else
			return db.modules["RCVotingFrame"].filters[response]
		end
	else -- Filter out the status texts
		return db.modules["RCVotingFrame"].filters["STATUS"]
	end
end

function ResponseSort(table, rowa, rowb, sortbycol)
	local column = table.cols[sortbycol]
	local a, b = table:GetRow(rowa), table:GetRow(rowb);
	a, b = addon:GetResponseSort(lootTable[session].candidates[a.name].response), addon:GetResponseSort(lootTable[session].candidates[b.name].response)
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
		local direction = column.sort or column.defaultsort or "asc";
		if direction:lower() == "asc" then
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
		local direction = column.sort or column.defaultsort or "asc";
		if direction:lower() == "asc" then
			return a > b;
		else
			return a < b;
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
	}
end

----------------------------------------------------
--	Dropdowns.
-- @section Dropdowns.
----------------------------------------------------
do
	--- The entries placed in the rightclick menu.
	-- Each level in the menu has it's own indexed entries, and each entry requires a text field as minimum,
	-- but can otherwise have the same values as normal DropDownMenus.
	-- To inject a new button, just call tinsert(RCVotingFrame.rightClickEntries[level], position, {--values})
	-- It shouldn't be nessecary to do more than once, just do it before the first session starts.
	--[[ Notes:
		Any value can be a function, which will be evaluated on creation. Functions gets candidateName and data (the data belonging to the candidate) as parameters.
		The func field also gets candidateName and data as params, but gets delivered as a function to the dropdown.
		There's three special fields to enable this kind of structure:
			onValue :String 				- This entry will only be shown if LIB_UIDROPDOWNMENU_MENU_VALUE matches onValue. This enables nesting.
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
			},	{ -- 6 Change response
				text = L["Change Response"],
				value = "CHANGE_RESPONSE",
				hasArrow = true,
				notCheckable = true,
			},{ -- 7 Reannounce
				text = L["Reannounce ..."],
				value = "REANNOUNCE",
				hasArrow = true,
				notCheckable = true,
			},{ -- 8 Remove from consideration
				text = L["Remove from consideration"],
				notCheckable = true,
				func = function(name)
					addon:SendCommand("group", "change_response", session, name, "REMOVED")
				end,
			},{ -- 9 Add rolls
				text = L["Add rolls"],
				notCheckable = true,
				func = function() RCVotingFrame:DoRandomRolls(session) end,
			},
		},
		{ -- Level 2
			{ -- 1 AWARD_FOR
				special = "AWARD_FOR",
			},{ -- 2 CHANGE_RESPONSE
				special = "CHANGE_RESPONSE",
			},{ -- 3 REANNOUNCE, 1 title
				onValue = "REANNOUNCE",
				text = function(candidateName) return addon.Ambiguate(candidateName) end,
				isTitle = true,
				notCheckable = true,
				disabled = true,
			},{ -- 3 REANNOUNCE, 2 This item
				onValue = "REANNOUNCE",
				text = L["This item"],
				notCheckable = true,
				func = function(candidateName)
					local t = {
						{	name = lootTable[session].name,
						link = lootTable[session].link,
						ilvl = lootTable[session].ilvl,
						texture = lootTable[session].texture,
						session = session,
						equipLoc = lootTable[session].equipLoc,
						token = lootTable[session].token,
						relic = lootTable[session].relic,
						}
					}
					addon:SendCommand(candidateName, "reroll", t)
					addon:SendCommand("group", "change_response", session, candidateName, "WAIT")
				end,
			},{ -- 3 REANNOUNCE, 3 All items
				onValue = "REANNOUNCE",
				text = L["All items"],
				notCheckable = true,
				func = function(candidateName)
					local t = {}
					for k,v in ipairs(lootTable) do
						if not v.awarded then
							tinsert(t, {
								name = v.name,
								link = v.link,
								ilvl = v.ilvl,
								texture = v.texture,
								session = k,
								equipLoc = v.equipLoc,
								token = v.token,
								relic = v.relic,
							})
							addon:SendCommand("group", "change_response", k, candidateName, "WAIT")
						end
					end
					addon:SendCommand(candidateName, "reroll", t)
				end,
			},
		},
		{ -- Level 3
			{ -- 1 Tier Tokens
				special = "TIER_TOKENS",
			},
			{ -- 2 Relics
				special = "RELICS",
			},
		},
		-- More levels can be added with tinsert(RCVotingFrame.rightClickEntries, {-- new level})
	}
	-- NOTE Take care of info[] values when inserting new buttons
	local info = Lib_UIDropDownMenu_CreateInfo() -- Efficiency :)
	function RCVotingFrame.RightClickMenu(menu, level)
		if not addon.isMasterLooter then return end

		local candidateName = menu.name
		local data = lootTable[session].candidates[candidateName] -- Shorthand

		local value = LIB_UIDROPDOWNMENU_MENU_VALUE
		for i, entry in ipairs(RCVotingFrame.rightClickEntries[level]) do
			info = Lib_UIDropDownMenu_CreateInfo()
			if not entry.special then
				if not entry.onValue or entry.onValue == value then
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
						Lib_UIDropDownMenu_AddButton(info, level)
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
					Lib_UIDropDownMenu_AddButton(info, level)
				end
			elseif value == "CHANGE_RESPONSE" and entry.special == value then
				local v;
				for i = 1, db.numButtons do
					v = db.responses[i]
					info.text = v.text
					info.colorCode = "|cff"..addon:RGBToHex(unpack(v.color))
					info.notCheckable = true
					info.func = function()
							addon:SendCommand("group", "change_response", session, candidateName, i)
					end
					Lib_UIDropDownMenu_AddButton(info, level)
				end
				info = Lib_UIDropDownMenu_CreateInfo()
				if addon.debug then -- Add all possible responses when debugging
					for k,v in pairs(db.responses) do
						if type(k) ~= "number" and k ~= "tier" and k~= "relic" then
							info.text = v.text
							info.colorCode = "|cff"..addon:RGBToHex(unpack(v.color))
							info.notCheckable = true
							info.func = function()
									addon:SendCommand("group", "change_response", session, candidateName, k)
							end
							Lib_UIDropDownMenu_AddButton(info, level)
						end
					end
				end
				info = Lib_UIDropDownMenu_CreateInfo()
				-- Add the tier menu
				if db.tierButtonsEnabled then
					info.text = L["Tier Tokens ..."]
					info.value = "TIER_TOKENS"
					info.hasArrow = true
					info.notCheckable = true
					Lib_UIDropDownMenu_AddButton(info, level)
				end
				-- And relics
				if db.relicButtonsEnabled then
					info.text = L["Relics"].." ..."
					info.value = "RELICS"
					info.hasArrow = true
					info.notCheckable = true
					Lib_UIDropDownMenu_AddButton(info, level)
				end

			elseif value == "TIER_TOKENS" and entry.special == value then
				for k,v in ipairs(db.responses.tier) do
					if k > db.tierNumButtons then break end
					info.text = v.text
					info.colorCode = "|cff"..addon:RGBToHex(unpack(v.color))
					info.notCheckable = true
					info.func = function()
							addon:SendCommand("group", "change_response", session, candidateName, k, true)
					end
					Lib_UIDropDownMenu_AddButton(info, level)
				end

			elseif value == "RELICS" and entry.special == value then
				for k,v in ipairs(db.responses.relic) do
					if k > db.relicNumButtons then break end
					info.text = v.text
					info.colorCode = "|cff"..addon:RGBToHex(unpack(v.color))
					info.notCheckable = true
					info.func = function()
							addon:SendCommand("group", "change_response", session, candidateName, k, false, true)
					end
					Lib_UIDropDownMenu_AddButton(info, level)
				end
			end
		end
	end

	function RCVotingFrame.FilterMenu(menu, level)
		if level == 1 then -- Redundant

			if not db.modules["RCVotingFrame"].filters then -- Create the db entry
				addon:DebugLog("Created VotingFrame filters")
				db.modules["RCVotingFrame"].filters = {}
			end

			-- Build the data table:
			local data = {["STATUS"] = true, ["PASS"] = true, ["AUTOPASS"] = true, tier = {}}

			local isTier = false
			-- If we're viewing a tier token and the ML have it enabled, we want to see it
			if lootTable[session].token and addon.mldb.tierButtonsEnabled then
				isTier = true
				for i = 1, addon.mldb.tierNumButtons or db.tierNumButtons do
					data.tier[i] = i
				end

			else -- otherwise just do the normal buttons
				for i = 1, addon.mldb.numButtons or db.numButtons do
					data[i] = i
				end
			end

			info.text = L["Filter"]
			info.isTitle = true
			info.notCheckable = true
			info.disabled = true
			Lib_UIDropDownMenu_AddButton(info, level)
			info = Lib_UIDropDownMenu_CreateInfo()
			if isTier then -- add tier buttons
				for k in ipairs(data.tier) do
					info.text = addon:GetResponseText(k, isTier)
					info.colorCode = "|cff"..addon:RGBToHex(addon:GetResponseColor(k, isTier))
					info.func = function()
						addon:Debug("Update Filter")
						db.modules["RCVotingFrame"].filters.tier[k] = not db.modules["RCVotingFrame"].filters.tier[k]
						RCVotingFrame:Update()
					end
					info.checked = db.modules["RCVotingFrame"].filters.tier[k]
					Lib_UIDropDownMenu_AddButton(info, level)
				end
			else -- add normal buttons
				for k in ipairs(data) do -- Make sure normal responses are on top
					info.text = addon:GetResponseText(k)
					info.colorCode = "|cff"..addon:RGBToHex(addon:GetResponseColor(k))
					info.func = function()
						addon:Debug("Update Filter")
						db.modules["RCVotingFrame"].filters[k] = not db.modules["RCVotingFrame"].filters[k]
						RCVotingFrame:Update()
					end
					info.checked = db.modules["RCVotingFrame"].filters[k]
					Lib_UIDropDownMenu_AddButton(info, level)
				end
			end
			for k in pairs(data) do -- A bit redundency, but it makes sure these "specials" comes last
				if type(k) == "string" and k ~= "tier" then
					if k == "STATUS" then
						info.text = L["Status texts"]
						info.colorCode = "|cffde34e2" -- purpleish
					else
						info.text = addon:GetResponseText(k)
						info.colorCode = "|cff"..addon:RGBToHex(addon:GetResponseColor(k))
					end
					info.func = function()
						addon:Debug("Update Filter")
						db.modules["RCVotingFrame"].filters[k] = not db.modules["RCVotingFrame"].filters[k]
						RCVotingFrame:Update()
					end
					info.checked = db.modules["RCVotingFrame"].filters[k]
					Lib_UIDropDownMenu_AddButton(info, level)
				end
			end
		end
	end

	function RCVotingFrame.EnchantersMenu(menu, level)
		if level == 1 then
			local added = false
			info = Lib_UIDropDownMenu_CreateInfo()
			if not db.disenchant then
				return addon:Print(L["You haven't selected an award reason to use for disenchanting!"])
			end
			for name, v in pairs(addon.candidates) do
				if v.enchanter then
					local c = addon:GetClassColor(v.class)
					info.text = "|cff"..addon:RGBToHex(c.r, c.g, c.b)..addon.Ambiguate(name).."|r "..tostring(v.enchant_lvl)
					info.notCheckable = true
					info.func = function()
						for k,v in ipairs(db.awardReasons) do
							if v.disenchant then
								local data = lootTable[session].candidates[name] -- Shorthand
								LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_AWARD", RCVotingFrame:GetAwardPopupData(session, name, data, v))
								return
							end
						end
					end
					added = true
					Lib_UIDropDownMenu_AddButton(info, level)
				end
			end
			if not added then -- No enchanters available
				info.text = L["No (dis)enchanters found"]
				info.notCheckable = true
				info.isTitle = true
				Lib_UIDropDownMenu_AddButton(info, level)
			end
		end
	end
end

function RCVotingFrame:GetItemStatus(item)
	-- addon:Debug("GetitemStatus", item)
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
