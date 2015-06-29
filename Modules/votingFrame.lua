-- Author      : Potdisc
-- Create Date : 12/15/2014 8:54:35 PM
-- DefaultModule	- (relies on ml_core perhaps?)
-- Displays everything related to handling loot for all members. 
--		Will only show certain aspects depending on addon.isMasterLooter, addon.isCouncil and addon.mldb.observe


local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
RCVotingFrame = addon:NewModule("RCVotingFrame", "AceComm-3.0")
local LibDialog = LibStub("LibDialog-1.0")

local ROW_HEIGHT = 20;
local NUM_ROWS = 15;
local db
local session = 1 -- The session we're viewing
local lootTable = {} -- lib-st compatible, extracted from addon's lootTable
local sessionButtons = {}
local moreInfo = false -- Show more info frame?
local active = false -- Are we currently in session?
local candidates = {} -- Candidates for the loot, initial data from the ML
local keys = {} -- Lookup table for cols

function RCVotingFrame:OnInitialize()
	self.scrollCols = {
		{ name = "",							width = 20, },	-- Class
		{ name = "Name",						width = 130,},	-- Candidate Name
		{ name = "Rank",						width = 100,},	-- Guild rank
		{ name = "Role",						width = 60, },	-- Role
		{ name = "Response",					width = 250,},	-- Response
		{ name = "ilvl",						width = 40, },	-- Total ilvl
		{ name = "diff",						width = 40, },	-- ilvl difference
		{ name = "g1",		align = "CENTER",	width = 20, },	-- Current gear 1 
		{ name = "g2",		align = "CENTER",	width = 20, },	-- Current gear 2
		{ name = "Votes",	align = "CENTER",	width = 40, },	-- Number of votes
		{ name = "Vote",	align = "CENTER",	width = 60, },	-- Vote button
		{ name = "Notes",	align = "CENTER",	width = 40, },	-- Note icon
	}
end

function RCVotingFrame:OnEnable()
	self:RegisterComm("RCLootCouncil")
	--printtable(self)
	db = addon:Getdb()
	--self:Show()
	active = true
	self.frame = self:GetFrame()
end

function RCVotingFrame:OnDisable()
	self.frame:Hide()
	--self.frame:SetParent(nil)
	--self.frame = nil
	--wipe(lootTable)
	lootTable = {}
	--sessionButtons = {}
	active = false
	session = 1
	addon:GetActiveModule("masterlooter"):EndSession()
end

function RCVotingFrame:Show()
	if self.frame then
		self.frame:Show()
	else
		addon:Print("No session running")
	end
end

function RCVotingFrame:OnCommReceived(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncil" and active then -- ignore comms if we aren't active
		-- data is always a table to be unpacked
		local test, command, data = addon:Deserialize(serializedMsg)
	
		if test then
			if command == "vote" then
				if tContains(addon.council, sender) or addon:UnitIsUnit(sender, addon.masterLooter) then
					local s, row, vote = unpack(data)
					self:HandleVote(s, row, vote, sender)
				else
					addon:Debug("Non-council member (".. tostring(sender) .. ") sent a vote!")
				end

			elseif command == "change_response" and addon:UnitIsUnit(sender, addon.masterLooter) then 
				local ses, name, response = unpack(data)
				self:SetCandidateData(ses, name, "response", response)
			
			elseif command == "lootAck" then
				local name = unpack(data)
				for i = 1, #lootTable do
					self:SetCandidateData(i, name, "response", "WAIT")
				end
			
			elseif command == "awarded" and self:UnitIsUnit(sender, addon.masterLooter) then
				lootTable[unpack(data)].awarded = true
				self:Update()

			elseif command == "candidates" and addon:UnitIsUnit(sender, addon.masterLooter) then
				candidates = unpack(data)
				
			elseif command == "offline_timer" and addon:UnitIsUnit(sender, addon.masterLooter) then
				for i = 1, #lootTable do
					for row = 1, #lootTable[i].rows do 
						if lootTable[i].rows[row].response == "ANNOUNCED" then -- Faster than calling GetCandidateData()
							lootTable[i].rows[row].response = "NOTHING"
						end
					end
				end

			elseif command == "lootTable" and addon:UnitIsUnit(sender, addon.masterLooter) then
				self:Setup(unpack(data))
				if db.autoOpen then
					self:Show()
				else
					addon:Print('A new session has begun, type "/rc open" to open the voting frame.')
				end

			elseif command == "response" then
				local t = unpack(data)
				for k,v in pairs(t.data) do
					self:SetCandidateData(t.session, t.name, k, v)
				end		
			end
		end
	end
end

function RCVotingFrame:SetCandidateData(ses, candidate, name, data, realrow)
	local row = realrow or lootTable[ses].candidates[candidate]
	if name == "response" then
		lootTable[ses].rows[row].response = data

	elseif name == "voters" then
		tinsert(lootTable[ses].rows[row].voters, data)
	elseif name == "haveVoted" then
		lootTable[ses].rows[row].haveVoted = data
	else
		local val = lootTable[ses].rows[row].cols[keys[name]]
		if type(val.value) == "function" or val.DoCellUpdate then
			val.args = {data}
		else
			val.value = data
		end
	end
	self:Update()
end

function RCVotingFrame:GetCandidateData(ses, candidate, name, realrow)
	local row = realrow or lootTable[ses].candidates[candidate]
	if name == "response" then 
		return lootTable[ses].rows[row].response

	elseif name == "voters" then
		return lootTable[ses].rows[row].voters
	elseif name == "haveVoted" then
		return lootTable[ses].rows[row].haveVoted
	else
		local val = lootTable[ses].rows[row].cols[keys[name]]
		if type(val.value) == "function" or val.DoCellUpdate then
			return unpack(val.args)
		else
			return val.value
		end
	end
	return nil
end

function RCVotingFrame:CreateLookupTable()
	-- We only need to do it once since all the cols are in the same position
	for k,v in ipairs(lootTable[1].rows[1].cols) do
		keys[v.name] = k
	end
end

function RCVotingFrame:Setup(table)
	-- Init stLootTable
	for session, t in ipairs(table) do
		lootTable[session] = {rows = {}, candidates = {}}
		for k,v in pairs(t) do
			--lootTable[session] = { bagged, lootSlot, announced, awarded, name, link, lvl, type, subType, equipLoc, texture}
			lootTable[session][k] = v
		end
		for name, y in pairs(candidates) do
			-- Insert candidates into each row, and set initial data for everything we don't already know
			--[playerName] = {rank, role,  class}
			tinsert(lootTable[session].rows,
			{	response = "ANNOUNCED",
				voters = {},
				haveVoted = false,
				cols = {										
					{ value = "",							DoCellUpdate = addon.SetCellClassIcon,	args = {y.class},		name = "class",},
					{ value = addon.Ambiguate,				color = addon:GetClassColor(y.class), args = {name},			name = "name",},
					{ value = y.rank,						color = self.GetResponseColor,									name = "rank",},
					{ value = addon.TranslateRole,			color = self.GetResponseColor,	args = {y.role},				name = "role",},
					{ value = self.GetResponseText,			color = self.GetResponseColor,									name = "response",},
					{ value = nil,																							name = "ilvl",},
					{ value = 0,							color = self.GetIDiffColor,										name = "diff",},
					{ value = "",							DoCellUpdate = self.SetCellGear, args = {nil},					name = "gear1",},
					{ value = "",							DoCellUpdate = self.SetCellGear, args = {nil},					name = "gear2",},
					{ value = nil,							DoCellUpdate = self.SetCellVote, args = {0},					name = "votes",},
					{ value = "",							DoCellUpdate = self.SetVoteBtn,									name = "vote",},							
					{ value = "",							DoCellUpdate = self.SetNote, args = {nil},						name = "note",},
				}
			})
			-- Insert the row id into lootTable[session].candidates[name] for ease of reference
			lootTable[session].candidates[name] = #lootTable[session].rows
		end
		
		-- Init session toggle
		sessionButtons[session] = self:UpdateSessionButton(session, t.texture, t.link, t.awarded)
		sessionButtons[session]:Show()
	end
	self:CreateLookupTable()
	session = 1
	self:SwitchSession(session)
end

function RCVotingFrame:Update()
	-- Hide unused session buttons
	for i = #lootTable+1, #sessionButtons do
		sessionButtons[i]:Hide()
	end
	self.frame.st:SetData(lootTable[session].rows)
	self.frame.st:SortData()
end

function RCVotingFrame:HandleVote(session, row, vote, voter)
	--addon:Print("HandleVote("..session..", "..row..", "..vote..", "..voter..")")
	-- Do the vote
	self:SetCandidateData(session, nil, "votes", self:GetCandidateData(session, nil, "votes", row) + vote , row)
	-- And update voters names (we'll do it directly as it's a bit faster than calling Get/SetCandidateData()
	if vote == 1 then
		tinsert(lootTable[session].rows[row].voters, voter)
	else
		for i, name in ipairs(lootTable[session].rows[row].voters) do
			if addon:UnitIsUnit(voter, name) then
				tremove(lootTable[session].rows[row].voters, i)
				break
			end
		end
	end
	self:Update()
end

------------------------------------------------------------------
--	Visuals														--
------------------------------------------------------------------
function RCVotingFrame:SwitchSession(s)
	-- Start with setting up some statics
	local old = session
	session = s
	local t = lootTable[s] -- Shortcut
	self.frame.itemIcon:SetNormalTexture(t.texture)
	self.frame.itemText:SetText(t.link)
	self.frame.itemLvl:SetText("ilvl: "..t.ilvl)

	-- Set a proper item type text
	if t.subType and t.subType ~= "Miscellaneous" and t.subType ~= "Junk" and t.equipLoc ~= "" then
		self.frame.itemType:SetText(getglobal(t.equipLoc)..", "..t.subType); -- getGlobal to translate from global constant to localized name
	elseif t.subType ~= "Miscellaneous" and t.subType ~= "Junk" then
		self.frame.itemType:SetText(t.subType)
	else
		self.frame.itemType:SetText(getglobal(t.equipLoc));
	end

	-- Update the session buttons
	sessionButtons[s] = self:UpdateSessionButton(s, t.texture, t.link, t.awarded)
	sessionButtons[old] = self:UpdateSessionButton(old, lootTable[old].texture, lootTable[old].link, lootTable[old].awarded)

	self:Update()	
end


function RCVotingFrame:GetFrame()
	if self.frame then return self.frame end

	-- Container and title
	local f = addon:CreateFrame("DefaultRCLootCouncilFrame", "votingFrame", 420)
	f.title = addon:CreateTitleFrame(f, "RCLootCouncil Voting Frame", 250)
	-- Scrolling table
	local st = LibStub("ScrollingTable"):CreateST(self.scrollCols, NUM_ROWS, ROW_HEIGHT, {r=1,g=0.9,b=0,a=0.5}, f)
	st.frame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
	f.st = st
	--[[------------------------------
		Session item icon and strings
	    ------------------------------]]
	local item = CreateFrame("Button", nil, f) --  TODO MIGHT NEED TO INHERIT SOMETHING
	item:EnableMouse()
    item:SetNormalTexture("Interface/ICONS/INV_Misc_QuestionMark")
    item:SetScript("OnEnter", function()
		if not lootTable then return; end
		addon:CreateHypertip(lootTable[session].link)
	end)
	item:SetScript("OnLeave", addon.HideTooltip)
	item:SetScript("OnClick", function()
		if not lootTable then return; end
	    if ( IsModifiedClick() ) then
		    HandleModifiedItemClick(lootTable[session].link);
        end
    end);
	item:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -20)
	item:SetSize(50,50)
	f.itemIcon = item

	local iTxt = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	iTxt:SetPoint("TOPLEFT", item, "TOPRIGHT", 10, -5)
	iTxt:SetText("Something went wrong :'(") -- Set text for reasons
	f.itemText = iTxt
	
	local ilvl = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ilvl:SetPoint("TOPLEFT", iTxt, "BOTTOMLEFT", 0, -10)
	ilvl:SetTextColor(0.5, 1, 1) -- Turqouise
	ilvl:SetText("ilvl:")
	f.itemLvl = ilvl

	local iType = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	iType:SetPoint("LEFT", ilvl, "RIGHT", 5, 0)
	iType:SetTextColor(0.5, 1, 1) -- Turqouise
	iType:SetText(" ")
	f.itemType = iType
	--#end----------------------------

	-- Abort button
	local b1 = addon:CreateButton("Abort", f)
	b1:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -50)
	if addon.isMasterLooter then
		b1:SetScript("OnClick", function() LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_ABORT") end)
	else
		b1:SetText("Close")
		b1:SetScript("OnClick", function() f:Hide() end)
	end
	f.abortBtn = b1

	-- More info button
	local b2 = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	b2:SetSize(25,25)
	b2:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -20)
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
	b2:SetScript("OnEnter", function() addon:CreateTooltip("Click to expand/collapse more info") end)
	b2:SetScript("OnLeave", addon.HideTooltip)
	f.moreInfoBtn = b2

	-- Filter 
	local tgl = addon:CreateButton("Filter", f)
	tgl:SetPoint("RIGHT", b1, "LEFT", -10, 0)
	tgl:SetScript("OnClick", function() db.filterPasses = not db.filterPasses; end )
	f.filter = tgl

	-- Number of rolls/votes
	local rf = CreateFrame("Frame", nil, f)
	rf:SetWidth(100)
	rf:SetHeight(20)
	rf:SetPoint("RIGHT", b2, "LEFT", -10, 0)
	rf:SetScript("OnEnter", function()
		addon:Print("rf OnEnter")
		-- TODO Make call to a "PeopleStillToRoll" func
	end)
	rf:SetScript("OnLeave", function()
		addon:Print("rf OnLeave")
		-- TODO Make call to a "PeopleStillToRoll" func
	end)
	local rft = rf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	rft:SetPoint("CENTER", rf, "CENTER")
	rft:SetText("Everyone have rolled and voted")
	rft:SetTextColor(0,1,0,1)
	rf.text = rft
	rf:SetWidth(rft:GetStringWidth()) -- TODO This isn't needed here
	f.rollResult = rf

	-- Session toggle
	local stgl = CreateFrame("Frame", nil, f)
	stgl:SetWidth(40)
	stgl:SetHeight(f:GetHeight())
	stgl:SetPoint("TOPRIGHT", f, "TOPLEFT", -2, 0)
	f.sessionToggleFrame = stgl

	-- Set a proper width
	f:SetWidth(st.frame:GetWidth() + 20)
	return f;
end

function RCVotingFrame:UpdateSessionButton(i, texture, link, awarded)
	local btn = sessionButtons[i]
	if not btn then -- create the button
		btn = CreateFrame("Button", nil, self.frame.sessionToggleFrame, "UIPanelButtonTemplate")
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
	end	
	-- then update it
	texture = texture or "Interface\InventoryItems\WoWUnknownItem01"
	btn:SetNormalTexture(texture)
	btn:GetNormalTexture():SetBlendMode("ADD")

	---- Set the colored border and tooltips
	btn:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 16,
		})
	local lines = { "Click to switch to", link }
	if i == session then
		btn:SetBackdropBorderColor(1,1,0,1) -- yellow
		btn:GetNormalTexture():SetVertexColor(1,1,1)
	elseif awarded then
		btn:SetBackdropBorderColor(0,1,0,1) -- green
		btn:GetNormalTexture():SetVertexColor(0.3,0.3,0.3)
		tinsert(lines, "This item has been awarded")
	else
		btn:SetBackdropBorderColor(1,1,1,1) -- white
		btn:GetNormalTexture():SetVertexColor(0.3,0.3,0.3)
	end
	btn:SetScript("OnEnter", function() addon:CreateTooltip(unpack(lines)) end)
	btn:SetScript("OnLeave", function() addon:HideTooltip() end)
	return btn
end

function RCVotingFrame.GetIDiffColor(data, cols, realrow, column)
	num = data[realrow].cols[column].value or 0 -- We don't want a nil here
	local green, red, grey = {r=0,g=1,b=0,a=1},{r=1,g=0,b=0,a=1},{r=0.75,g=0.75,b=0.75,a=1}
	if num > 0 then return green end
	if num < 0 then return red end
	return grey		
end

function RCVotingFrame.SetCellGear(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local celldata = data[realrow].cols[column]
	local gear = unpack(celldata.args)
	if gear then
		local texture = select(10, GetItemInfo(gear))
		frame:SetNormalTexture(texture)
		local link = select(2, GetItemInfo(gear))
		frame:SetScript("OnEnter", function() addon:CreateHypertip(link) end)	
		frame:SetScript("OnLeave", function() addon:HideTooltip() end)
		frame:Show()
	else
		frame:Hide()
	end
end

function RCVotingFrame.SetVoteBtn(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	if addon.isCouncil or addon.isMasterLooter then -- Only let the right people vote
		if not frame.voteBtn then -- create it
			frame.voteBtn = addon:CreateButton("Vote", frame)
			frame.voteBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
			frame.voteBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
		end
		frame.voteBtn:SetScript("OnClick", function(btn)
			-- Test if they may vote for themselves
			if not addon.mldb.selfVote and addon:UnitIsUnit("player", self:GetCandidateData(session,nil,"name", realrow)) then
				return addon:Print("The Master Looter doesn't allow votes for yourself.")
			end
			-- Test if they're allowed to cast multiple votes
			if not addon.mldb.multiVote then
				for i = 1, #data do
					if data[i].haveVoted then
						return addon:Print("The Master Looter doesn't allow multiple votes.")
					end
				end
			end
			if data[realrow].haveVoted then -- unvote					
				addon:SendCommand("group", "vote", session, realrow, -1)
			else -- vote					
				addon:SendCommand("group", "vote", session, realrow, 1)
			end
			data[realrow].haveVoted = not data[realrow].haveVoted
		end)
		if data[realrow].haveVoted then
			frame.voteBtn:SetText("Unvote")
		else
			frame.voteBtn:SetText("Vote")
		end
	end
end

function RCVotingFrame.SetNote(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local note = unpack(data[realrow].cols[column].args)
	local f = frame.noteBtn or CreateFrame("Button", nil, frame)
	f:SetSize(ROW_HEIGHT, ROW_HEIGHT)
	f:SetPoint("CENTER", frame, "CENTER")
	if note then
		f:SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Up.png")
		f:SetScript("OnEnter", function() addon:CreateTooltip("Note", note)	end)
		f:SetScript("OnLeave", function() addon:HideTooltip() end)
	else
		f:SetScript("OnEnter", nil)
		f:SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Disabled.png")
	end
	frame.noteBtn = f
end

function RCVotingFrame.GetResponseText(data, cols, realrow)
	-- Extract the response from the row
	return addon:GetResponseText(data[realrow].response)
end

function RCVotingFrame.GetResponseColor(data, cols, realrow)
	return addon:GetResponseColor(data[realrow].response)
end

function RCVotingFrame.SetCellVote(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	if not addon.mldb.anonymousVoting or (db.showForML and addon.isMasterLooter) then
		frame:SetScript("OnEnter", function()
			addon:CreateTooltip("Voters", unpack(data[realrow].voters))
		end)
		frame:SetScript("OnLeave", function() addon:HideTooltip() end)
	end
	frame.text:SetText(data[realrow].cols[column].args[1])
end

--------ML Popups ------------------
LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_ABORT", {
	text = "Are you sure you want to abort?",
	buttons = {
		{	text = "Yes",
			on_click = function(self)
				addon:GetActiveModule("masterlooter"):EndSession()
				RCVotingFrame:Disable()
				CloseLoot() -- close the lootlist
			end,	
		},
		{	text = "No",
		},
	},
	hide_on_escape = true,
	show_while_dead = true,	
})
LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_AWARD", {
	text = "Are you sure you want to give %s to %s?",
	buttons = {
		{	text = "Yes",
			on_click = function(self)
				RCLootCouncil_Mainframe.award() -- TODO
			end,			
		},
		{	text = "No",
			-- TODO check if requires function
		},
	},
	hide_on_escape = true,
	show_while_dead = true,	
})