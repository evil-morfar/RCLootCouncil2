-- Author      : Potdisc
-- Create Date : 12/15/2014 8:54:35 PM
-- DefaultModule	- (relies on ml_core perhaps?)
-- Displays everything related to handling loot for all members. 
--		Will only shows certain aspects depending on addon.isMasterLooter, addon.isCouncil and addon.mldb.observe

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
RCVotingFrame = addon:NewModule("RCVotingFrame")

local ROW_HEIGHT = 20;
local NUM_ROWS = 15;
local db
local session = 1 -- The session we're viewing
local lootTable = {} -- stTable compatible, extracted from addon's lootTable
local sessionButtons = {}
local moreInfo = false -- Show more info frame?

function RCVotingFrame:OnInitialize()
	self.scrollCols = {
		{ name = "",							width = 20, },	-- Class
		{ name = "Name",						width = 130,},	-- Candidate Name
		{ name = "Rank",						width = 100,},	-- Guild rank
		{ name = "Role",						width = 60, },	-- Role
		{ name = "Response",					width = 250,},	-- Response
		{ name = "ilvl",						width = 40, },	-- Total ilvl
		{ name = "diff",						width = 40, },	-- ilvl difference
		{ name = "g1",							width = 20, },	-- Current gear 1 
		{ name = "g2",							width = 20, },	-- Current gear 2
		{ name = "Votes",	align = "CENTER",	width = 40, },	-- Number of votes
		{ name = "Vote",						width = 60, },	-- Vote button
		{ name = "Notes",						width = 40, },	-- Note icon
	}
end

function RCVotingFrame:OnEnable()
	--printtable(self)
	db = addon:Getdb()
	--self:Show()
end

function RCVotingFrame:OnDisable()
	self.frame:Hide()
	--self.frame.rows = {}
	self.frame:SetParent(nil)
	--self.frame = nil
	lootTable = {}
	sessionButtons = {}
	addon:GetActiveModule("masterlooter"):EndSession()
end

function RCVotingFrame:Show()
	self.frame = self:GetFrame()
	self.frame:Show()
end

function RCVotingFrame:Setup(table)
	self:Show()
	-- Init stLootTable
	for session, t in ipairs(table) do
		lootTable[session] = {rows = {}}
		for k,v in pairs(t) do
			--lootTable[session] = { bagged, lootSlot, announced, awarded, name, link, lvl, type, subType, equipLoc, texture, candidates[]}
			if type(k) ~= "table" then
				lootTable[session][k] = v				
			end
		end
		for name, y in pairs(t.candidates) do
			--[playerName] = {rank, role, totalIlvl, diff, response, gear1, gear2, votes, class, haveVoted, voters[], note}
			tinsert(lootTable[session].rows,
			{	cols = {
					{ value = "",							DoCellUpdate = addon.SetCellClassIcon, args = {y.class}, },
					{ value = addon:Ambiguate(name),		color = addon:GetClassColor(y.class) },
					{ value = y.rank,						color = self:GetResponseColor(y.response) },
					{ value = addon:TranslateRole(y.role),	color = self:GetResponseColor(y.response) },
					{ value = function() if addon.mldb.responses[y.response] then return addon.mldb.responses[y.response].text;	else return addon.responses[y.response].text; end; end,							color = self:GetResponseColor(y.response) },
					{ value = y.totalIlvl,					color = self:GetResponseColor(y.response) },
					{ value = y.diff,						color = self:GetIDiffColor(y.diff), },
					{ value = "",							DoCellUpdate = self.SetCellGear, args = {y.gear1},	},
					{ value = "",							DoCellUpdate = self.SetCellGear, args = {y.gear2},	},
					{ value = y.votes	},
					{ value = "Vote"	},
					{ value = "Note"	},
				}
			})
		end
		
		-- Init session toggle
		sessionButtons[session] = self:UpdateSessionButton(session, t.texture, t.link, t.awarded)
	end

	session = 1
	self:SwitchSession(session)
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

	-- Finally setup the right scrolling table data
	self.frame.st:SetData(t.rows)
	self.frame.st:SortData()
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
		addon:CreateTooltip(nil, lootTable[session].link)
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
	iTxt:SetText("Item name goes here!!!!") -- Set text for reasons
	f.itemText = iTxt
	
	local ilvl = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ilvl:SetPoint("TOPLEFT", iTxt, "BOTTOMLEFT", 0, -10)
	ilvl:SetTextColor(0.5, 1, 1) -- Turqouise
	ilvl:SetText("ilvl: 670")
	f.itemLvl = ilvl

	local iType = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	iType:SetPoint("LEFT", ilvl, "RIGHT", 5, 0)
	iType:SetTextColor(0.5, 1, 1) -- Turqouise
	iType:SetText("Chest, Leather")
	f.itemType = iType
	--#end----------------------------

	-- Abort button
	local b1 = addon:CreateButton("Abort", f)
	b1:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -50)
	b1:SetScript("OnClick", function() self:Disable() end)
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
	b2:SetScript("OnEnter", function() addon:CreateTooltip({"Click to expand/collapse more info"}) end)
	b2:SetScript("OnLeave", addon.HideTooltip)
	f.moreInfoBtn = b2

	-- Filter passes
	local tgl = CreateFrame("CheckButton", nil, f, "ChatConfigCheckButtonTemplate")
	tgl:SetPoint("RIGHT", b1, "LEFT", -10, 0)
	tgl.tooltip = "Check to hide passes"
	tgl:SetChecked(db.filterPasses)
	tgl:SetScript("OnClick", function() db.filterPasses = not db.filterPasses; end )
	-- Create seperate fontstring to move the text to the left
	local txt = tgl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	txt:SetPoint("RIGHT", tgl, "LEFT", -5, 0)
	txt:SetTextColor(1,1,1,1)
	txt:SetText("Filter passes")
	tgl.text = txt
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
	if not texture then
		texture = "Interface\InventoryItems\WoWUnknownItem01"
	end
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
	btn:SetScript("OnEnter", function() addon:CreateTooltip(lines) end)
	btn:SetScript("OnLeave", function() addon:HideTooltip() end)
	return btn
end

function RCVotingFrame:GetIDiffColor(num)
	local green, red, grey = {r=0,g=1,b=0,a=1},{r=1,g=0,b=0,a=1},{r=0.75,g=0.75,b=0.75,a=1}
	if num > 0 then return green end
	if num < 0 then return red end
	return grey		
end

function RCVotingFrame:GetResponseColor(response)
	-- We have to convert indicies for lib-st -.-'
	local r,g,b,a;
	if addon.mldb.responses[response] then
		r,g,b,a = unpack(addon.mldb.responses[response].color)		
	else
		r,g,b,a = unpack(addon.responses[response].color)
	end
	return {["r"]=r,["g"]=g,["b"]=b,["a"]=a}
end

function RCVotingFrame:SetCellGear(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local celldata = data[realrow].cols[column]
	local gear = unpack(celldata.args)
	
	if gear then
		local texture = select(10, GetItemInfo(gear))
		local link = select(2, GetItemInfo(gear))
		frame:SetNormalTexture(texture)
		frame:SetScript("OnEnter", function() addon:CreateTooltip(nil, link) end)
		frame:SetScript("OnLeave", function() addon:HideTooltip() end)
	end
end