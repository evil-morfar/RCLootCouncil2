-- Author      : nnp
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
local moreInfo = false -- Show more info frame?

function RCVotingFrame:OnInitialize()
	self.scrollCols = {
		{ name = "",							width = 20, },	-- Class
		{ name = "Name",						width = 130,},	-- Candidate Name
		{ name = "Rank",						width = 100,},	-- Guild rank
		{ name = "Role",						width = 60, },	-- Role
		{ name = "Response",					width = 250,},	-- Response
		{ name = "ilvl",						width = 40, },	-- Total ilvl
		{ name = "Gear",						width = 60, },	-- Current gear (1 or 2)
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
	-- TODO EndSession
end

function RCVotingFrame:Show()
	self.frame = self:GetFrame()
	self.frame:Show()
end

function RCVotingFrame:Setup(table)
	-- Init stLootTable
	for session, t in ipairs(table) do
		lootTable[session] = {rows = {}}
		for k,y in pairs(t) do
			--lootTable[session] = { bagged, lootSlot, announced, awarded, name, link, lvl, type, subType, equipLoc, texture, playerName[]}
			if type(y) ~= "table" then
				lootTable[session][k] = y
			else
				--[playerName] = {rank, role, totalIlvl, response, gear1, gear2, votes, class, haveVoted, voters[], note}
				tinsert(lootTable[session].rows,
				{	cols = {
						{ value = "",					DoCellUpdate = addon.SetCellClassIcon, args = {y.class}, },
						{ value = addon:Ambiguate(k),	color = addon:GetClassColor(y.class) },
						{ value = y.rank,	},
						{ value = y.role	},
						{ value = y.response },
						{ value = y.totalIlvl },
						{ value = "Gear"	},
						{ value = y.votes	},
						{ value = "Vote"	},
						{ value = "Note"	},
					}
				})
			end
		end	
	end

	session = 1
	self:Show()
	self:Update()
end


------------------------------------------------------------------
--	Visuals														--
------------------------------------------------------------------
function RCVotingFrame:Update()
	-- Start with setting up some statics
	local t = lootTable[session] -- Shortcut
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

	-- Finally setup the right scrolling table data
	self.frame.st:SetData(t.rows)
	self.frame.st:SortData()

	printtable(t.rows)
end


function RCVotingFrame:GetFrame()
	if self.frame then return self.frame end

	-- Container and title
	local f = addon:CreateFrame("DefaultRCLootCouncilFrame", "votingFrame", 420)
	f.title = addon:CreateTitleFrame(f, "RCLootCouncil Voting Frame", 250)
	-- Scrolling table
	local st = LibStub("ScrollingTable"):CreateST(self.scrollCols, NUM_ROWS, ROW_HEIGHT, nil, f)
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


	-- Set a proper width and init rows
	f:SetWidth(st.frame:GetWidth() + 20)
	--f.rows = {}
	return f;
end