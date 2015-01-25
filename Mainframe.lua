-- Author      : Potdisc
-- Maintainer  : Eriner
-- Create Date : 3/21/2012 3:46:51 PM
-- Mainframe.lua Handles all the masterloot interaction and host/client comms

--_______________________________.
-- TODO:  
--		Test if PARTY_LOOT_METHOD_CHANGED can handle the GetML() and GetCouncil()
--		Random award between equal votes.
--		Implement autopass - will use same tech as stat priority sorting.

--		Alt-Clicking must add items separately in v2.0.
--		All calls (council, mlDB etc. ) should be made by the client.

--		Sort item rolls (optionally) by class stat priority based on item stats.

--		LONG TERM: Clean UI, possibly skin to match UI choices (Blizzard, ElvUI, etc)

--_______________________________.
--[[ CHANGELOG	

====1.7.0 Release
**This version is not backwards compatible.**

	*++Added "Raid Council Members"++
	*Used to add council members from your current raid, but it's primary function is to properly add players from other realms.
	*++Added minimize++
	*You're now able to minimize the RCLootCouncil voting frame - just click the "-" button.
	*++Added Crossrealm support++
	*Crossrealm groups is now fully supported.
	*//Note: This requires everyone to reset their council (notice message included in-game)//.
	
	Bugfixes:
	
	*//Fixed error related to GetRaidRosterInfo() could return nil presumeably due to latency issues.//
	*//The "Filter Passes" message when everyone have passed didn't work as intended.//
	*//Solo tests now better reflects the real thing.//
	*//Initialize now accounts for server delay, thanks guinea pig oblitlol.//
	*//Removed debug spam on whisper stuff (I wonder how long that's been there?)//	
	*//The voting frame now properly sorts all sessions in accordance to responses.//
	*//All localizable fonts are now inherited from GameFont to ensure different locale support.//
		
]]


RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceHook-3.0", "AceTimer-3.0");
RCLootCouncil:SetDefaultModuleLibraries("AceEvent-3.0")
RCLootCouncil:SetDefaultModuleState(false)

RCLootCouncil_Mainframe = {}
RCLootCouncil_LootFrame = {}
RCLootCouncil_RankFrame = {}

local debug = false -- enable printing of debugging messages
local nnp = false
local superDebug = false -- extra debugging (very spammy)
local version = GetAddOnMetadata("RCLootCouncil", "Version")

local playerName, playerFullName
local isMasterLooter = false; -- is the player master looter?
local isCouncil = false; -- is the player in the council?
local isRunning = false; -- should we use the addon?
local isTesting = false; -- are we testing?
local masterLooter = ""; -- name of master looter
local currentCouncil = {} -- The current council of the session
local itemRunning = nil; -- the item in the current session
local guildRank = ""; -- Player's rank in guild
local selection = {}; -- The current selection
local lootNum = 0; -- the number of GetNumLootItems we've reached e.g. which item we're at
local itemsToLootIndex = {}; -- table containing the GetLootSlotLink() indexes that needs to be looted
local lootTable = {} -- table containing the actual items
local hasVerCheck = false; -- used to prevent "please upgrade" spamming
local bossName = "" -- used to get the boss name
local lootFramesCreated = false; -- used to get item info for loot frames
local votersNames = {}; -- contains the names of people that has voted
local currentSession = 1; -- the session the user is currently viewing
local itemsLoaded = true; -- used to test if any item is awaiting info
local hasItemInfo = false -- prevent spamming loot frames from GET_ITEM_INFO_RECEIVED
local channel = "RAID" -- the channel to use for comms, "RAID" normally, "PARTY" for debugging with starter accounts

local MAX_DISPLAY = 11 -- max people to display in council voting window
local MAX_ITEMS = 20 -- max items allowed to be rolled at once (TODO make dynamic)

local entryTable = {}
for i=1, MAX_ITEMS do
	entryTable[i] = {}
end
-- entryTable[i] order: (playerName, rank, role, totalIlvl, response, gear1, gear2, votes, class, color[], haveVoted, voters[], note)

local offset = 0; -- scrollframe offset
local db, buttonsDB, lootDB; -- shortening of self.db.profile(.buttons/.lootDB)
local mlDB; -- the master looter's db
local debugLog;

local sortMethod = 'desc';
local currSortIndex = 0;
local self = RCLootCouncil;
local guildEventUnregister = false; -- used to unregister the guild_roster_update event
local _;
local menuFrame; -- rightclick menu frame
local isMinimized = false -- set minimize to false by default

-- Create the defaults
local defaults = {
	factionrealm = { -- the loot awarded db should be the same for all characters in the same faction on the same realm
		lootDB = {
			--[[ Format:
			"playerName" = {
				[#] = {"lootWon", "date (d/m/y)", "time (h:m:s)", "instance", "boss", "votes", "itemReplaced1", "itemReplaced2", "response", "responseID"}
			},
			]]
		},
	},
	global = { -- debug log
		logMaxEntries = 300,
		log = {},
	},
	profile = {
		council = {},
		awardAnnouncement = true,
		awardMessageChat1 = "RAID",
		awardMessageText1 = "&p was awarded with &i!",
		awardMessageChat2 = "NONE",
		awardMessageText2 = "",
		announceConsideration = false,
		announceText = "The council is currently considering &i!",
		announceChannel = "RAID",		
		autoLooting = true,
		altClickLooting = true,
		lootEverything = true,
		acceptWhispers = true,
		acceptRaidChat = false,
		trackAwards = false,
		sendHistory = true,
		advancedOptions = false,
		autolootBoE = false,
		minRank = -1,
		filterPasses = false,
		otherAwardReasons = { -- Used in "Award for ..." @ the rightclick menu
			{ text = "Disenchating",	log = true},	--1
			{ text = "Banking",			log = true},	--2
			{ text = "Free",			log = false},	--3
		},
		autoAward = false,
		autoAwardQualityLower = 2,
		autoAwardQualityUpper = 3,
		autoAwardTo = "None",
		autoAwardReason = 1,
		autoPass = "NONE",
		-- below is the part of the db that's send to others. Separate section to avoid sending unnecessary data.
		dbToSend = {
			selfVote = true,
			multiVote = true,
			anonymousVoting = false,
			masterLooterOnly = false,
			--autoPass = "false", --feature not yet implemented; will be branched to dev
			allowNotes = true,
			numButtons = 4,
			maxButtons = 8,
			passButton = 4,
			buttons = {
				{	--1
					text = "Mainspec/Need",
					color = {0, 1, 0,1}, -- Green
					response = "Mainspec/Need",
					whisperKey = "need, mainspec, ms, 1",
				},
				{	--2
					text = "Offspec/greed",
					color = {1, 0.5, 0,1}, -- Orange
					response = "Offspec/Greed",
					whisperKey = "greed, offspec, os, 2",
				},
				{	--3
					text = "Minor Upgrade",
					color = {0, 0.75, 0.75,1}, -- LightBlue
					response = "Minor Upgrade",
					whisperKey = "minorupgrade, minor, 3",
				},
				{	--4
					text = "Pass",
					color = {0.75, 0.75,0.75,1}, -- Gray
					response = "Pass",
					whisperKey = "pass, 4",
				},
			},
		},
	},
}
-- create the other buttons
for i = 5, defaults.profile.dbToSend.maxButtons do
	defaults.profile.dbToSend.buttons[i] = {
		text = "Button "..i,
		color = {0.75, 0.75,0.75,1},
		response = "Button "..i.." response",
		whisperKey = ""..i,
	}
end

function RCLootCouncil:OnInitialize()
	self:RegisterChatCommand("rc", "ChatCommand")
    self:RegisterChatCommand("rclc", "ChatCommand")
	self:RegisterComm("RCLootCouncil")
	self.db = LibStub("AceDB-3.0"):New("RCLootCouncilDB", defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	db = self.db.profile
	lootDB = self.db.factionrealm.lootDB
	debugLog = self.db.global.log

	self.options = self:OptionsTable()
	-- register the optionstable
	self.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("RCLootCouncil", self.options)
	
	-- add it to blizz options
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RCLootCouncil", "RCLootCouncil")	
	buttonsDB = db.dbToSend.buttons
end

function RCLootCouncil:OnEnable()
	self:debugS(" ")
	self:debugS("Logged in")
	MainFrame:RegisterEvent("LOOT_OPENED");
	MainFrame:RegisterEvent("LOOT_CLOSED");
	MainFrame:RegisterEvent("GROUP_ROSTER_UPDATE"); -- redundant with PARTY_LOOT_METHOD_CHANGED
	MainFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	MainFrame:RegisterEvent("GUILD_ROSTER_UPDATE");
	MainFrame:RegisterEvent("CHAT_MSG_WHISPER");
	MainFrame:RegisterEvent("CHAT_MSG_RAID");
	MainFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	MainFrame:RegisterEvent("RAID_INSTANCE_WELCOME");
	MainFrame:SetScript("OnEvent", RCLootCouncil.EventHandler);

	if IsInGuild() then
		self:SendCommMessage("RCLootCouncil", "verTest "..version, "GUILD") -- send out a version check
	end
	if self.db.global.version and self.db.global.version < "1.7.0" then -- Their council needs to be updated due to naming changes in 1.7.0
		if db.council and #db.council >= 1 then
			db.council = {}
			self:Print("With v1.7.0 you need to redo your council due to naming changes. Your current council has been wiped.")
		end
	end
	self.db.global.version = version;

	GuildRoster();
	
	local filterFunc = function(_, event, msg, player, ...)
		return strfind(msg, "[[RCLootCouncil]]:")
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterFunc)
	playerFullName = self:GetPlayerFullName()
	playerName = Ambiguate(self:GetPlayerFullName(), "short")
end

function RCLootCouncil:OnDisable()
	self:UnregisterAllEvents()
	MainFrame:UnregisterAllEvents()
end

function RCLootCouncil:RefreshConfig()
	db = self.db.profile
end

------------- MainFrame_OnLoad -----------
-- Loads the MainFrame
------------------------------------------
function RCLootCouncil:MainFrame_OnLoad()
	MainFrame:Hide()
	------ Create content entries --------
	local entry = CreateFrame("Button", "$parentEntry1", ContentFrame, "RCLootCouncil_Entry"); -- Creates the first row
	entry:SetID(1); -- Set the ID
	entry:SetPoint("TOPLEFT", 4, -4) -- Set anchor
	for i = 2, MAX_DISPLAY do -- Create the rest of the rows
		local entry = CreateFrame("Button", "$parentEntry"..i, ContentFrame, "RCLootCouncil_Entry");
		entry:SetID(i);
		entry:SetPoint("TOP", "$parentEntry"..(i-1), "BOTTOM") -- Set the anchor to the row above
	end

	------ Create session switches -------
	for i = 1, MAX_ITEMS do
		local button = CreateFrame("Button", "RCLootCouncil_SessionButton"..i, MainFrame, "RCLootCouncil_SessionToggleButton");
		if i == 1 then
			button:SetPoint("TOPLEFT", MainFrame, "TOPRIGHT", 2, 0)
		elseif mod(i,10) == 1 then
			button:SetPoint("TOPLEFT", "RCLootCouncil_SessionButton"..i-10, "TOPRIGHT", 2, 0)		
		else
			button:SetPoint("TOP", "RCLootCouncil_SessionButton"..i-1, "BOTTOM", 0, -2)
		end
		button:SetID(i)
	end

	------ rightclick menu --------------
	menuFrame = CreateFrame("Frame", "RCLootCouncil_RightClickMenu", MainFrame, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(menuFrame, RCLootCouncil_Mainframe_RightClickMenu, "MENU")

	----------PopUp setups --------------
	-------------------------------------
	StaticPopupDialogs["RCLOOTCOUNCIL_CONFIRM_ABORT"] = {
		text = "Are you sure you want to abort?\nThis will abort for all council members.",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			RCLootCouncil_Mainframe.abortLooting()
			self:SendCommMessage("RCLootCouncil", "stop", channel) -- tell the council to abort as well
			RCLootCouncil_Mainframe.stopLooting()
			CloseButton_OnClick() -- close the frame
			CloseLoot() -- close the lootlist
		end,
		timeout = 0,
		enterClicksFirstButton = true,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3, 
	}

	StaticPopupDialogs["RCLOOTCOUNCIL_CONFIRM_AWARD"] = {
		text = "Are you sure you want to give %s to %s?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			RCLootCouncil_Mainframe.award()
		end,
		timeout = 0,
		enterClicksFirstButton = true,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3, 
	}

	StaticPopupDialogs["RCLOOTCOUNCIL_CONFIRM_USAGE"] = {
		text = "Do you want to use RCLootCouncil for this raid?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			RCLootCouncil:debugS("CONFIRM_USAGE = true")
			isRunning = true;
			masterLooter = RCLootCouncil_Mainframe.getML()
			if db.autoAward and GetLootThreshold() > db.autoAwardQualityLower then
				RCLootCouncil:Print("Changing loot threshold to enable Auto Awarding.")
				SetLootThreshold(db.autoAwardQualityLower)
			end
			self:Print("is active in this raid. You can turn it off in the options menu if you regret.")
			if #db.council < 1 then -- if there's no council
				self:Print("You haven't set a council")
				RCLootCouncil_RankFrame.show() -- show the rankframe
			end
		end,
		OnCancel = function ()
			RCLootCouncil:debugS("CONFIRM_USAGE = false")
			isRunning = false;
			self:Print("is not active in this raid. You can turn it on in the options menu if you regret.")
		end,
		timeout = 0,
		enterClicksFirstButton = true,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3, 
	} 

end

---------- EventHandler -----------------
-- Handles events
-----------------------------------------
function RCLootCouncil.EventHandler(self2, event, ...)
	if event == "LOOT_OPENED" then
		if isMasterLooter and isRunning and (IsInRaid() or nnp) then -- if we're masterlooter and addon is enabled or debug is on
			self:debugS("event = "..event)
			if GetNumLootItems() >= 1 then -- if there's something to loot
				if not InCombatLockdown() then
					bossName = GetUnitName("target") -- extract the boss name before the player can switch targets
					if not bossName then bossName = "Unknown/Chest" end -- check if we really got a boss name, or we just looted a chest
					for i = 1, GetNumLootItems() do -- run through the number of items in the loot window
						if db.altClickLooting then -- hook loot buttons if we use altClickLooting
							local lootButton = getglobal("LootButton"..i)
							if lootButton ~= nil then 
								self:HookScript(lootButton, "OnClick", "LootOnClick") -- hook if we use it
							end
							if XLoot then -- hook XLoot
								lootButton = getglobal("XLootButton"..i)
								if lootButton ~= nil then
									self:HookScript(lootButton, "OnClick", "LootOnClick")
								end
							end if XLootFrame then -- if XLoot 1.0
								lootButton = getglobal("XLootFrameButton"..i)
								if lootButton ~= nil then
									self:HookScript(lootButton, "OnClick", "LootOnClick")
								end
							end if getglobal("ElvLootSlot"..i) then -- if ElvUI
								lootButton = getglobal("ElvLootSlot"..i)
								if lootButton ~= nil then
									self:HookScript(lootButton, "OnClick", "LootOnClick")
								end
							end
						end
						local _, _, lootQuantity, lootRarity = GetLootSlotInfo(i)
						-- check if we should autoAward it, otherwise check if we should loot it
						if db.autoAward and LootSlotHasItem(i) and lootQuantity > 0 and (lootRarity >= db.autoAwardQualityLower and lootRarity <= db.autoAwardQualityUpper) then
							RCLootCouncil:AutoAward(i, db.autoAwardTo, GetLootSlotLink(i))

						elseif db.autoLooting then
							if (LootSlotHasItem(i) or db.lootEverything) and lootQuantity > 0 and lootRarity >= GetLootThreshold() then -- Check wether we want to loot the item or not
								-- now that we know it's an lootable item, lets also check if we should loot BoE's
								if RCLootCouncil:LootBoE(GetLootSlotLink(i)) then
									tinsert(lootTable, GetLootSlotLink(i)) -- add the item link to the table
									tinsert(itemsToLootIndex, i) -- add its index to the lootTable
								end
							elseif lootQuantity == 0 then -- if its coin
								LootSlot(i) -- loot the coin
							end
						end
						
					end
				else -- don't do anything if we're in combat
					self:Print("Couldn't start the loot session because you're in combat.")
					return;
				end
				if #itemsToLootIndex > 0 then -- if there's anything in the table
					lootNum = 1;
					RCLootCouncil_initiateLoot(lootTable[lootNum]); -- initiate the loot
				end
			end
		end
	elseif event == "LOOT_CLOSED" then
		if isMasterLooter then
			self:debugS("event = "..event)
			self:UnhookAll()
			if itemRunning then -- the loot window closed too early
				DEFAULT_CHAT_FRAME:AddMessage("RCLootCouncil cannot loot anything without the loot window being open!", 1, 0.5, 0, 1, 10)
				DEFAULT_CHAT_FRAME:AddMessage("Please restart the looting session.", 1, 0.5, 0, 1, 10)
				RCLootCouncil_Mainframe.abortLooting()
				RCLootCouncil_Mainframe.stopLooting()
				CloseButton_OnClick() -- close the frame
				self:SendCommMessage("RCLootCouncil", "stop", channel) -- tell the council to abort as well
			end
		end
	elseif event == "GROUP_ROSTER_UPDATE" and (IsInRaid() or nnp) then
		masterLooter = RCLootCouncil_Mainframe.getML()
		isCouncil = RCLootCouncil_Mainframe.isCouncil()
		
	elseif event == "RAID_INSTANCE_WELCOME" then
		self:debugS("event = "..event)
		function RCLootCouncil:InstanceInitialize() -- functionize this bitch
			if isRunning then return; end -- don't do shit
			if IsInRaid() or nnp then -- if the player is in a raid
				local lootMethod = GetLootMethod()
				if lootMethod == 'master' then -- if master looter is turned on
					-- just make the call to getML and it'll do the prompting
					masterLooter = RCLootCouncil_Mainframe.getML()
				elseif UnitIsGroupLeader("player") and not isRunning then -- otherwise ask the raid leader
				-- high server-side latency causes the UnitIsGroupLeader("player") condition to fail if queried quickly (upon entering instance) regardless of state.
				-- may add a delay for the above conditional if the issue persists to circumvent issue.
					StaticPopup_Show("RCLOOTCOUNCIL_CONFIRM_USAGE")
				end
			end
		end
		self:ScheduleTimer("InstanceInitialize", 2)
	elseif event == "GUILD_ROSTER_UPDATE" then -- delay the getting of guildRank till it's available
		guildRank = RCLootCouncil:GetGuildRank();
		if guildEventUnregister then
			MainFrame:UnregisterEvent("GUILD_ROSTER_UPDATE"); -- we don't need it any more
			RCLootCouncil:GetGuildOptions() -- get the guild data to the options table now that it's ready
		end
	elseif event == "CHAT_MSG_WHISPER" and isMasterLooter and db.acceptWhispers then
		local msg, sender = ...
		if msg == "rchelp" then
			RCLootCouncil:SendWhisperHelp(sender)
		elseif itemRunning then
			RCLootCouncil:GetItemsFromMessage(msg, sender)
		end
	elseif event == "CHAT_MSG_RAID" and itemRunning and isMasterLooter and db.acceptRaidChat then
		local msg, sender = ...
		RCLootCouncil:GetItemsFromMessage(msg, sender)

	elseif event == "PARTY_LOOT_METHOD_CHANGED" then
		self:debug("PARTY_LOOT_METHOD_CHANGED")
		-- TODO Test this shit

	elseif event == "GET_ITEM_INFO_RECEIVED" then 
		if not lootFramesCreated and #lootTable > 0 then
			itemsLoaded = true
			for i = 1, #lootTable do
				local name = GetItemInfo(lootTable[i])
				if name == nil then
					itemsLoaded = false;
					hasItemInfo = false
				end
			end
			if itemsLoaded then
				if not hasItemInfo then
					self:debugS("RCLootCouncil_LootFrame:Update() - "..event)
					hasItemInfo = true
					lootFramesCreated = true
					RCLootCouncil_LootFrame:Update(lootTable)
					if itemRunning then
						RCLootCouncil_Mainframe.prepareLootFrame(itemRunning);
					end
				end
			end
		end
	end
end


-------- OnCommReceived -------------------
-- Handles communications
-------------------------------------------
function RCLootCouncil:OnCommReceived(prefix, msg, distri, sender)
--[[List of commands:
	start (i)				- ML initiates new looting (number from lootTable we're at)
	lootTable (table)		- ML sends the loot table
	stop					- ML stops looting
	council (table)			- ML sends the council
	mlDB (table)			- ML sends his options database
	vote (string)			- anyone sends a vote
	add (table)				- anyone sends an response on the "roll"
	remove (name)			- ML removes an entry
	change (table)			- ML changes a response
	verTest	(string)		- anyone sends a version test
	verTestReply (table)	- anyone sends a verTest reply
	award(name, table)		- ML sends an award history entrance
	reRoll(table)			- ML says to reroll
	msg						- Message to display
--]]
	if prefix == "RCLootCouncil" then
		local cmd, object = strsplit(" ", msg, 2) -- split the command from the object
		if cmd and object then
			self:debugS("Comm received, cmd: "..cmd..", object: "..object..", sender: "..sender)
		else 
			self:debugS("Comm received, cmd: "..cmd..", sender: "..sender)
		end
		-- Sender is Ambiguated(sender, "none") by AceComm
		if self:UnitIsUnit("player", sender) and distri ~= "WHISPER" then return end; -- don't do anything if we send the message, unless it was a whisper
		if cmd == 'start' and (isCouncil or isMasterLooter) then
			if not isMasterLooter or nnp then
				RCLootCouncil_Mainframe.abortLooting() -- start with aborting, just in case the masterlooter disconnects during looting
				lootNum = tonumber(object);
				self:debug("Added item (council): "..lootTable[lootNum])
				itemRunning = lootTable[lootNum];
				RCLootCouncil_Mainframe:ChangeSession(lootNum) -- just call ChangeSession as it's basicly the same
			else
				self:debug("A non ML called for a start!")
			end
		elseif cmd == "lootTable" then
			if not isMasterLooter or nnp then
				local test, c = self:Deserialize(object)
				if test then
					for i = 1, #c do
						GetItemInfo(c[i]) -- queue the item info
					end
					lootTable = c
					itemsLoaded = true -- test if the item info is queued
					for i = 1, #lootTable do
						local name = GetItemInfo(lootTable[i])
						if name == nil then
							itemsLoaded = false
							hasItemInfo = false
						end
					end
					if itemsLoaded then -- and only call .setupLoot if it is, otherwise wait for it to arrive (Event)
						self:debugS("RCLootCouncil_LootFrame:Update() - "..cmd)
						lootFramesCreated = true
						hasItemInfo = true
						RCLootCouncil_LootFrame:Update(lootTable)
					end
				else
					self:debug("Deserialization on lootTable failed!")
				end
			else
				self:debug("A non ML send a lootTable!")
			end
		elseif cmd == "stop" then
			if not isMasterLooter then
				isRunning = false; -- the ML said stop, so better stop the addon just in case
				self:debug("isRunning = false")
				self:Print("The Master Looter stopped the voting")
				RCLootCouncil_Mainframe.abortLooting()
				RCLootCouncil_Mainframe.stopLooting()
			else
				self:debug("A non ML called for a stop!")
			end
		elseif cmd == 'council' then
			if not isMasterLooter then
				local test, c = self:Deserialize(object)
				if test then
					currentCouncil = c
					isCouncil = RCLootCouncil_Mainframe.isCouncil()
					masterLooter = RCLootCouncil_Mainframe.getML()
				else
					--TODO: perhaps add a callback for another send
					self:debug("Deserialization on counciltable failed!")
				end
			else
				self:debug("A non ML send a councillist!")
			end

		elseif cmd == 'mlDB' then
			if not isMasterLooter then
				local test, c = self:Deserialize(object)
				if test then
					mlDB = c
				else
					--TODO: perhaps add a callback for another send
					self:debug("Deserialization on mlDB failed!")
				end
			else
				self:debug("A non ML send a mlDB!")
			end
		elseif cmd == 'vote' and (isCouncil or isMasterLooter) then
			for i = 1, #currentCouncil +1 do -- make sure we only accept votes from council members (+1 to force it to at least try ML once)
				if self:UnitIsUnit(currentCouncil[i], sender) or self:UnitIsUnit(masterLooter,sender) then
					local session, name, devote = strsplit(" ", object, 3)
					session = tonumber(session)
					if type(session) ~= "number" or session > MAX_ITEMS then -- incompatible version check
						self:Print(sender.." uses an incompatible version and cannot vote.")
						return;
					end
					RCLootCouncil_Mainframe.voteOther(session, name, devote, sender)
					if isMasterLooter then -- insert the voter's name to the table
						if not tContains(votersNames, sender) then
							tinsert(votersNames, sender)
						end
					end
					return;
				end
			end
			self:Print("Rejected a vote from a non councilmember ("..sender..")")

		elseif cmd == 'add' and (isCouncil or isMasterLooter) then
			local test, c = self:Deserialize(object)
				if test then
					tinsert(entryTable[c["i"]], c[1])
					if c["i"] == currentSession then -- only sort incoming rolls on our current page
						RCLootCouncil_Mainframe.sortTable(4, true) -- sort passes away, and let that function call the update
					end
				else
					--TODO: Add a callback for another send
					self:debug("Deserialization on add failed!")
				end
		elseif cmd == 'remove' and (isCouncil or isMasterLooter) then
			if not isMasterLooter then
				local session, name = strsplit(" ", object, 2)
				RCLootCouncil_Mainframe.removeEntry(session, name)
			else
				self:debug("A non ML ("..sender..") send a remove cmd")
			end

		elseif cmd == "change" and isCouncil then
			local test, c = self:Deserialize(object)
				if test then
					entryTable[c[1]][c[2]][5] = c[3]
					RCLootCouncil_Mainframe.Update(true);
				else
					-- new send
					self:debug("Deserialization on change failed!")
				end
		elseif cmd == 'verTest' then
			if version < object and not hasVerCheck then -- if we're outdated and haven't already showed it to the user
				self:Print("Your version: "..version.." is outdated, newer version is: "..object)
				hasVerCheck = true;				
			end
			local _, class = UnitClass("player")
			self:SendCommMessage("RCLootCouncil", "verTestReply "..self:Serialize({class, guildRank, version}) , "WHISPER", sender)

		elseif cmd == 'verTestReply' then
			local test, c = self:Deserialize(object)
			if test then			
				if version < c[3] and not hasVerCheck then -- if we're outdated
					self:Print("Your version: "..version.." is outdated, newest version is: "..c[3])
					hasVerCheck = true;
				end
				tinsert(c, 2, sender) -- insert sender to the table
				RCLootCouncil_VersionFrame:AddPlayer(c) -- and add the data to the versionFrame							
			else -- if old version
				RCLootCouncil_VersionFrame:AddPlayer({nil, sender, "Unknown", object})
			end

		elseif cmd == "award" and db.trackAwards then
			local name, table = string.split(" ", object,2)
			if name and table then -- just to be sure
				local test, c = self:Deserialize(table)
				if test then
					if lootDB[Ambiguate(name, "short")] then -- if the name is already registered in the table
						tinsert(lootDB[Ambiguate(name, "short")], c)
					else -- if it isn't
						lootDB[Ambiguate(name, "short")] = {c};
					end
				else
					self:debug("Deserialization on award failed!")
				end
			else
				self:debug("Couldn't get name or table in award cmd")
			end

		elseif cmd == "reRoll" then
			-- object = item, session
			local test, c = self:Deserialize(object)
			if test then 
				RCLootCouncil_LootFrame:Update(nil, {item = c[1], position = c[2]})
				self:Print(sender.." requested a reroll on "..c[1])
			else
				-- new send
			end

		elseif cmd == "msg" then
			self:Print(tostring(object))
--		else
--			self:debug("Bad command: "..tostring(object))
-- disabled for spamming when (not (isCouncil or isMasterLooter))
		end
	end
end


--------------- debug ---------------------
-- Prints debug messages if turned on
-------------------------------------------
function RCLootCouncil:debug(msg)
	if debug then 
		self:Print("debug: "..msg)
	end
	RCLootCouncil:DebugLogAdd(msg)
end

-------------- superDebug -----------------
-- Prints superDebug messages
-------------------------------------------
function RCLootCouncil:debugS(msg)
	if superDebug then
		self:Print("debugS: "..msg)
	end
	RCLootCouncil:DebugLogAdd(msg)
end

-------------- showMainFrame --------------
-- Shows the Main Frame
-------------------------------------------
function RCLootCouncil_Mainframe.showMainFrame()
	self:debugS("Mainframe.showMainFrame()")
	if itemRunning then -- would hide the entries if a councilmember closes and trys to re open it
		RCLootCouncil_Mainframe.Update(true)
	else -- no items, so we want to hide it
		RCLootCouncil_Mainframe.Update(false)
	end
	MainFrame:Show()
end

-------------- hideMainFrame --------------
-- Hides the Main Frame
-------------------------------------------
function RCLootCouncil_Mainframe.hideMainFrame()
	self:debugS("Mainframe.hideMainFrame()")
	MainFrame:Hide()
end


--------- CloseButton_OnClick -------------
-- When close button is clicked
-------------------------------------------
function CloseButton_OnClick()
	self:debugS("CloseButtion_OnClick()")
	if not isMasterLooter and not isTesting then -- hide if we're not the masterlooter
		RCLootCouncil_Mainframe.hideMainFrame()
	elseif not itemRunning then -- if we are, only hide when nothings running
		RCLootCouncil_Mainframe.hideMainFrame()
	else -- else show confirmation box
		StaticPopup_Show("RCLOOTCOUNCIL_CONFIRM_ABORT") -- will abort for all council
	end
end

--------- minimizeBtOnClick ----------------
-- minimize window to a single bar
--------------------------------------------
function RCLootCouncil_Mainframe.minimizeBtOnClick()
	if not isMinimized then
		RCLootCouncil_Mainframe.minimize("minimize");
	elseif isMinimized then
		RCLootCouncil_Mainframe.minimize("unminimize");
	else --if this condition is reached, something went wrong. Print to chat, unminimize just in case
		self:Print("could not read isMinimized variable. Please report on CurseForge.")
	end
	RCLootCouncil_Mainframe:UpdateSessionButtons() --unconditional update, as state is loaded/cleared based on bool isMinimized
end


-------- minimizeRCLC ----------------------
-- Minimze elements of RCLC without interrupting looting
--------------------------------------------
function RCLootCouncil_Mainframe.minimize(action)
	if action == 'minimize' then
		MainFrame:SetHeight(35)	
		MainFrame:DisableDrawLayer("OVERLAY")
		MainFrame:DisableDrawLayer("ARTWORK") -- disable (unlabled) layer
		CurrentItemHover:Hide()
		ContentFrame:Hide()
		BtClose:Hide()
		BtClear:Hide()
		BtRemove:Hide()
		BtAward:Hide()
		HeaderName:Hide()
		HeaderRank:Hide()
		HeaderSpec:Hide()
		HeaderTotalilvl:Hide()
		HeaderResponse:Hide()
		HeaderCurrentGear:Hide()
		HeaderVotes:Hide()
		HeaderVote:Hide()
		HeaderNotes:Hide()
		DualItemSelection2:Hide()
		DualItemSelection1:Hide()
		CurrentSelectionHover:Hide()
		MainFramePeopleToRollHover:Hide()
		ContentFrame:Hide()
		RCLootCouncil_Mainframe.updateSelection(0,true); -- clear selection, must be at end of hide(s), otherwise bugs ensue
		isMinimized = true; -- variable set in minimize function and not on button press to ensure variable it set correctly
	elseif action == 'unminimize' then
		MainFrame:SetHeight(407)	
		MainFrame:EnableDrawLayer("OVERLAY")
		MainFrame:EnableDrawLayer("ARTWORK") -- disable (unlabled) layer
		CurrentItemHover:Show()
		ContentFrame:Show()
		BtClose:Show()
		BtClear:Show()
		BtRemove:Show()
		BtAward:Show()
		HeaderName:Show()
		HeaderRank:Show()
		HeaderSpec:Show()
		HeaderTotalilvl:Show()
		HeaderResponse:Show()
		HeaderCurrentGear:Show()
		HeaderVotes:Show()
		HeaderVote:Show()
		HeaderNotes:Show()
		DualItemSelection2:Show()
		DualItemSelection1:Show()
		CurrentSelectionHover:Show()
		MainFramePeopleToRollHover:Show()
		ContentFrame:Show()
		RCLootCouncil_Mainframe.updateSelection(0,true); -- also clear on unminimize, just in case
		isMinimized = false; -- variable set in minimize function and not on button press to ensure variable it set correctly
	else --unexpected string passed to minimize function; abort and report
		self:Print("Unexpected string passed to RCLootCouncil_Mainframe.minimize")
		self:Print("Passed variable was %s", action)
		self:Print("Please visit RCLootCouncil's CurseForge and submit a ticket with the message above.")
	end
end
--------- removeBtOnClick ------------------
-- When the remove button is clicked
--------------------------------------------
function RCLootCouncil_Mainframe.removeBtOnClick()
	if selection[1] then
		self:SendCommMessage("RCLootCouncil", "remove "..currentSession.." "..selection[1], channel)
		RCLootCouncil_Mainframe.removeEntry(currentSession, selection[1])
	else
		self:Print("Couldn't remove the player")
	end
end
--------- awardBtOnClick -------------------
-- When the award button is clicked
--------------------------------------------
function RCLootCouncil_Mainframe.awardBtOnClick()
	StaticPopup_Show("RCLOOTCOUNCIL_CONFIRM_AWARD", itemRunning, Ambiguate(selection[1], "short"))
end

------------- abortLooting --------------------
-- Aborts the current looting session
-----------------------------------------------
function RCLootCouncil_Mainframe.abortLooting()
	self:debugS("Mainframe.abortLooting()")
	itemRunning = nil;
	lootFramesCreated = false;
	CurrentItemTexture:Hide();
	CurrentItemLabel:SetText(" ");
	CurrentItemLvl:SetText(" ");
	CurrentItemType:SetText(" ");
	CurrentItemHover:Hide();
	BtClose:SetText("Close");
	EmptyTexture:Show();
	RCLootCouncil_Mainframe.updateSelection(0, true);
	RCLootCouncil_Mainframe.Update(false);
	PeopleToRollLabel:Hide()
	PeopleToRollString:Hide()
	isTesting = false;
end

function RCLootCouncil_Mainframe.stopLooting()
	self:debugS("Mainframe.stopLooting()")
	-- clear the entry table efficiently, but keep some of it, as its needed later on.
	for i = 1, #entryTable do
		wipe(entryTable[i])
	end
	lootNum = 0
	currentSession = 1
	lootTable = {}
	itemsToLootIndex = {}
	votersNames = {}
	currentCouncil = {}
	RCLootCouncil_LootFrame.hide()
	RCLootCouncil_Mainframe.Update(false);
end
------------- ChatCommand ---------------------
-- Handles all the chat commands
-----------------------------------------------
function RCLootCouncil:ChatCommand(msg)
	local input, arg = string.split(" ", msg, 2); -- Separates the command from the rest
	input = input:lower(); -- Lower case command

    if not input or input:trim() == "" or input == 'help' then
		print("RCLootCouncil ver. " .. version)
		self:Print("- config - Open the options frame")
		self:debug("- debug or d - Toggle debugging")
		self:Print("- show - Shows the main loot frame")
		self:Print("- hide - Hides the main loot frame")
		self:Print("- council - displays the current council")
		self:Print("- councilAdd (name) or cAdd - adds a new member to the loot council")
		self:Print("- remove (name) - removes a player from the loot council")
		self:Print("- deleteEntireCouncil - deletes the entire council")
		self:Print("- test (#)  - emulate a loot session (add a number for raid test)")
		self:Print("- version - open the Version Checker (alt. 'v' or 'ver')")
		self:Print("- history - open the Loot History")
		self:Print("- whisper - displays help to whisper commands (alt. 'his')")
		self:Print("- reset - resets the addon's frames' positions")
		self:debug("- log - display the debug log")
		self:debug("- clearLog - clear the debug log")

	elseif input == 'config' or input == 'options' then
		--InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		LibStub("AceConfigDialog-3.0"):Open("RCLootCouncil")
    elseif input == 'debug' or input == 'd' then
		debug = not debug
		if debug then self:Print("Debugging enabled")
		else self:Print("Debugging disabled")
		end

	elseif input == 'show' then
		if not IsInRaid() or isCouncil or isMasterLooter or nnp then -- only the right people may see the window during a raid since they otherwise could watch the entire voting
			RCLootCouncil_Mainframe.showMainFrame()
		else
			self:Print("You are not allowed to see the Voting Frame right now.")
		end

	elseif input == 'hide' then
		RCLootCouncil_Mainframe.hideMainFrame()
	
	elseif input == 'council' then
		if db.council then
			self:Print("Council: ")
			for _,t in ipairs(db.council) do print(t) end
		else
			self:Print("No council exists")
		end

	elseif input == 'counciladd' or input == 'cadd' then
		if arg then
			tinsert(db.council, arg)
			self:Print(""..arg.." was added to the council!")
		else
			self:Print("Please provide a playername")
		end

	elseif input == 'remove' then
		if arg then
			if db.council then
				for k,v in ipairs(db.council) do
					if self:UnitIsUnit(v,arg) then
						tremove(db.council, k)
						self:Print(""..arg.." was removed from the council")
						return
					end
				end
				self:Print("There's noone in the council called "..arg)
			end
		end
			
	elseif input == 'deleteentirecouncil' then
		db.council = {}
		self:Print("Council wiped")

	elseif input == 'test' then
		if (IsInRaid() or nnp) and arg then
			RCLootCouncil_Mainframe.getML()
			RCLootCouncil_Mainframe.raidTestFrames(tonumber(arg))
		else
			if arg then 
				self:Print("You can only raid test when in a raid and are the group leader/assistant.")
				self:Print("Starting solo test.")
			end
			RCLootCouncil_Mainframe.testFrames()
		end

	elseif input == "add" and nnp then
		local _, totalIlvl = GetAverageItemLevel()
		local gear1, gear2 = RCLootCouncil.getCurrentGear(lootTable[currentSession]);
		local _, class = UnitClass("player"); -- non-localized class name
	
		local names = { "AName", "Bname", "CName", "DName", "OName",}
		for k = 1, 10 do
			local toAdd = {
				["i"] = math.random(#lootTable),
					{
						names[math.random(#names)],
						guildRank,
						RCLootCouncil.getPlayerRole(),
						math.floor(totalIlvl),
						tonumber(arg) or 1,
						gear1,
						gear2,
						0,
						class,
						color,
						false,
						{""},
						nil,
				}
			}
			RCLootCouncil:OnCommReceived("RCLootCouncil", "add "..self:Serialize(toAdd), "WHISPER", playerFullName)
		end
	 
	elseif input == 'version' or input == "v" or input == "ver" then
		self:EnableModule("RCLootCouncil_VersionFrame")
	elseif input == "history" or input == "his" then
		self:EnableModule("RCLootHistory")
	elseif input == "nnp" then
		nnp = not nnp
	elseif input == "debugs" and nnp then
		superDebug = not superDebug
	elseif input == "whisper" then
		self:Print("Players can whisper (or through Raidchat if enabled) their current item(s) followed by a keyword to the Master Looter if they doesn't have the addon installed.\nThe keyword list is found under the 'Buttons, Responses and Whispers' optiontab.\nPlayers can whisper 'rchelp' to the Master Looter to retrieve this list.\nNOTE: People should still get the addon installed, otherwise all player information won't be available.")
    
	elseif input == "reset" then
		if RCLootFrame then
			RCLootFrame:ClearAllPoints()
			RCLootFrame:SetPoint("CENTER", 0, -200)
		end
		if MainFrame then
			MainFrame:ClearAllPoints()
			MainFrame:SetPoint("CENTER", 0, 200)
			RCLootCouncil_Mainframe.minimize("unminimize");
		end
		if RCVersionFrame then
			RCVersionFrame:ClearAllPoints()
			RCVersionFrame:SetPoint("CENTER", -400, 0)
		end
		if RCLootHistoryFrame then
			RCLootHistoryFrame:ClearAllPoints()
			RCLootHistoryFrame:SetPoint("CENTER", -400, 0)		
		end	
	
	elseif input == "debuglog" or input == "log" then
		for k,v in ipairs(debugLog) do
			print(k.." - "..v)
		end
	elseif input == "clearlog" then
		wipe(debugLog)
		self:Print("Debug Log cleared.")
	else
        RCLootCouncil:ChatCommand("help")
    end
end 

---------- initiateLoot --------------
-- Start looting an item
--------------------------------------
function RCLootCouncil_initiateLoot(item)
	self:debugS("initiateLoot("..tostring(item)..")")
	if isRunning or nnp then -- only do stuff if we're using the addon or debugging
		if item == nil then -- Be certain we got something here
			self:Print("Item wasn't cached, please restart the session!")
			return;
		end
		for i = 1, #lootTable do
			local name = GetItemInfo(lootTable[i])
			if name == nil then
				self:Print("Items weren't cached, please restart the session!")
				return
			end
		end
		hasItemInfo = true
		
		if itemRunning then -- if we're already trying to handle an item
			self:Print("Can't start a new loot session while an item is being considered");
			self:debug("Trying to start new session while another is being considered!!")
			return;
		else -- we're not running an item
			itemRunning = item;			
			-- create the table of in-raid-councilmembers to send to the councillors
			for _, v in ipairs(db.council) do
				if UnitInRaid(Ambiguate(v, "short")) then
					tinsert(currentCouncil, v)
				end
			end
			self:SendCommMessage("RCLootCouncil", "council "..self:Serialize(currentCouncil), channel) -- let the members know if they're councilmen
			mlDB = db.dbToSend -- create the master looter db
			self:SendCommMessage("RCLootCouncil", "mlDB "..self:Serialize(mlDB), channel) -- and send 
			self:SendCommMessage("RCLootCouncil", "lootTable "..self:Serialize(lootTable), channel) -- tell everyone to do the same
			self:SendCommMessage("RCLootCouncil", "start "..lootNum, channel) -- tell the council we've started
			self:debug("Added item: "..item)			
			BtClose:SetText("Cancel Looting")
			RCLootCouncil:announceConsideration() -- announce it if it's on
			self:debugS("RCLootCouncil_LootFrame:Update() - RCLootCouncil_initiateLoot()")
			RCLootCouncil_LootFrame:Update(lootTable) -- setup our own loot frames
			RCLootCouncil_Mainframe.prepareLootFrame(item)				
		end
	end
end

----------initiateNext ---------------
-- Initiates the next item
--------------------------------------
function RCLootCouncil:initiateNext(item)
	itemRunning = item
	RCLootCouncil:announceConsideration() -- announce it if it's on
	self:SendCommMessage("RCLootCouncil", "start "..lootNum, channel) -- tell the council to start on the next item
	currentSession = lootNum
	RCLootCouncil_Mainframe.prepareLootFrame(item)	
end

---------- prepareLootFrame ----------
-- Prepares the loot frame for an item
--------------------------------------
function RCLootCouncil_Mainframe.prepareLootFrame(item)
	self:debugS("Mainframe.prepareLootFrame("..tostring(item)..")")
	if isMasterLooter or isCouncil or isTesting then
		if not itemRunning then -- double check ;)
			self:debug("prepareLootFrame called without any item running!")
			return
		end
		GetItemInfo(item); -- query up the item
		local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount, thisItemEquipLoc, thisItemTexture = GetItemInfo(item); -- Get the item info
		if thisItemTexture then
			CurrentItemTexture:SetTexture(thisItemTexture); -- Set the texture of the icon box
		else
			CurrentItemTexture:SetTexture("Interface\InventoryItems\WoWUnknownItem01");
		end
	
		if not isMinimized then
			CurrentItemTexture:Show(); -- Open up the icon box
			EmptyTexture:Hide(); -- Hide the empty texture box
		else
			self:debug("Preventing show of CurrentItemTextures because isMinimized == true")
		end

		if iLevel then
			CurrentItemLvl:SetText("ilvl: "..iLevel); -- Show the Item Level
		else
			CurrentItemLvl:SetText("");
		end
	
		if sLink then
			CurrentItemLabel:SetText(sLink); -- Set the item link for color and such
		else
			CurrentItemLabel:SetText("LOADING");
		end

		if sSubType and sSubType ~= "Miscellaneous" and sSubType ~= "Junk" and thisItemEquipLoc ~= "" then
			CurrentItemType:SetText(getglobal(thisItemEquipLoc)..", "..sSubType); -- getGlobal to translate from global constant to localized name
		elseif sSubType ~= "Miscellaneous" and sSubType ~= "Junk" then
			CurrentItemType:SetText(sSubType)
		else
			CurrentItemType:SetText(getglobal(thisItemEquipLoc));
		end

		if not isMinimized then
			CurrentItemHover:Show(); -- Make sure we can hover the item
			MasterlooterLabel:SetText(Ambiguate(masterLooter, "short"));
			PeopleToRollString:Show()
			PeopleToRollLabel:Show()
		else
			self:debugS("Preventing more windows from showing")
		end

		PeopleToRollLabel:SetText(GetNumGroupMembers()) -- set the amount of people missing the rolling
		
		-- Award string
		AwardString:Hide()
		if isMasterLooter or isTesting then
			if currentSession > lootNum then
				AwardString:Show()
				AwardString:SetText("You can't award this item yet!")
				AwardString:SetTextColor(1,0,0,1)
			end	
		end
		if currentSession < lootNum then				
			AwardString:SetText("This item has been awarded.")
			AwardString:SetTextColor(0,1,0,1)
			AwardString:Show()
		end

		RCLootCouncil_Mainframe:UpdateSessionButtons()
		
		if not isMinimized then
			RCLootCouncil_Mainframe.showMainFrame()
		else
			self:debugS("Preventing call of RCLootCouncil_Mainframe.showMainFrame()")
		end
	else
		self:debug("PrepareLootFrame called without a valid initiator!")
	end	
end

--[[
	Used by getCurrentGear to determine slot types
	Inspired by EPGPLootMaster - thanks!
--]]
local INVTYPE_Slots = {
		INVTYPE_HEAD		    = "HeadSlot",
		INVTYPE_NECK		    = "NeckSlot",
		INVTYPE_SHOULDER	    = "ShoulderSlot",
		INVTYPE_CLOAK		    = "BackSlot",
		INVTYPE_CHEST		    = "ChestSlot",
		INVTYPE_WRIST		    = "WristSlot",
		INVTYPE_HAND		    = "HandsSlot",
		INVTYPE_WAIST		    = "WaistSlot",
		INVTYPE_LEGS		    = "LegsSlot",
		INVTYPE_FEET		    = "FeetSlot",
		INVTYPE_SHIELD		    = "SecondaryHandSlot",
		INVTYPE_ROBE		    = "ChestSlot",
		INVTYPE_2HWEAPON	    = {"MainHandSlot","SecondaryHandSlot"},
		INVTYPE_WEAPONMAINHAND	= "MainHandSlot",
		INVTYPE_WEAPONOFFHAND	= {"SecondaryHandSlot",["or"] = "MainHandSlot"},
		INVTYPE_WEAPON		    = {"MainHandSlot","SecondaryHandSlot"},
		INVTYPE_THROWN		    = {"SecondaryHandSlot", ["or"] = "MainHandSlot"},
		INVTYPE_RANGED		    = {"SecondaryHandSlot", ["or"] = "MainHandSlot"},
		INVTYPE_RANGEDRIGHT 	= {"SecondaryHandSlot", ["or"] = "MainHandSlot"},
		INVTYPE_FINGER		    = {"Finger0Slot","Finger1Slot"},
		INVTYPE_HOLDABLE	    = {"SecondaryHandSlot", ["or"] = "MainHandSlot"},
		INVTYPE_TRINKET		    = {"TRINKET0SLOT", "TRINKET1SLOT"}
}

--------- getCurrentGear ------------------------
-- Returns the player's gear in the given slot(s)
-- based on arg (item).
-------------------------------------------------
function RCLootCouncil.getCurrentGear(item)
	local itemID = tonumber(strmatch(item, "item:(%d+):")) -- extract itemID
	-- check if the item is a token, and if it is, return the matching current gear
	if RCTokenTable[itemID] then return GetInventoryItemLink("player", GetInventorySlotInfo(RCTokenTable[itemID])), nil; end
	local _, _, _, _, _, _, _, _, thisItemEquipLoc = GetItemInfo(item);
	local item1, item2;
	local slot = INVTYPE_Slots[thisItemEquipLoc]
	if not slot then return nil, nil; end;
	item1 = GetInventoryItemLink("player", GetInventorySlotInfo(slot[1] or slot))
	if not item1 and slot['or'] then
		item1 = GetInventoryItemLink("player", GetInventorySlotInfo(slot['or']))
	end;
	if slot[2] then
		item2 = GetInventoryItemLink("player", GetInventorySlotInfo(slot[2]))
	end
	return item1, item2;
end

---------- ShowCurrentItemTooltip -------------
-- Shows item running's Tooltip
-----------------------------------------------
function RCLootCouncil_Mainframe.ShowCurrentItemTooltip()
	if itemRunning then
		GameTooltip:SetOwner(MainFrame, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(lootTable[currentSession])
		GameTooltip:Show()
	end
end

---------- ShowCurrentGearTooltip -------------
-- Shows the current gear Tooltip
-----------------------------------------------
function RCLootCouncil_Mainframe.ShowCurrentGearTooltip(id)
	GameTooltip:SetOwner(MainFrame, "ANCHOR_CURSOR")
	if id then
		id = id + offset -- handle the offset
		if entryTable[currentSession][id][6] then
			GameTooltip:SetHyperlink(entryTable[currentSession][id][6])
			GameTooltip:Show()
		end	  			
	elseif selection[6] then
		GameTooltip:SetHyperlink(selection[6])
		GameTooltip:Show()   		
	end
end

---------- ShowCurrentGear2Tooltip -------------
-- Shows the current gear2 Tooltip
-----------------------------------------------
function RCLootCouncil_Mainframe.ShowCurrentGear2Tooltip(id)
	if id then
		id = id + offset -- handle the offset
		if entryTable[currentSession][id][7] then
			GameTooltip:SetOwner(MainFrame, "ANCHOR_CURSOR")
			GameTooltip:SetHyperlink(entryTable[currentSession][id][7])
			GameTooltip:Show()
		end	  			
	elseif selection[7] then
			GameTooltip:SetOwner(MainFrame, "ANCHOR_CURSOR")
			GameTooltip:SetHyperlink(selection[7])
			GameTooltip:Show()
	end
end

------------- toolMouseLeave ----------------------------------------
-- Removes the tooltip when mouse leaves the area
-----------------------------------------------------------------
function RCLootCouncil_Mainframe.toolMouseLeave()
	GameTooltip:Hide()
end


---------- GetGuildRank -------------------
-- returns the player's guild rank
-------------------------------------------
function RCLootCouncil:GetGuildRank()
	self:debugS("GetGuildRank()")
	GuildRoster()
	if IsInGuild() then
		_, rank, _ = GetGuildInfo("player");
		if rank then
			self:debug("Found guild rank: "..rank)
			guildEventUnregister = true; -- make sure we unregister the event
			return rank;
		else
			GuildRoster();
			return "Not Found";
		end
	else
		return "Unguilded";
	end
end

---------- setClassIcon -------------------
-- Sets the class-texture to a given class
-------------------------------------------
function RCLootCouncil_Mainframe.setClassIcon(frame, class)
	if class then
		frame:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"); -- this is the image containing all class icons
		local coords = CLASS_ICON_TCOORDS[class]; -- get the coordinates of the class icon we want
		frame:SetTexCoord(unpack(coords)); -- cut out the region with our class icon according to coords
	else -- if there's no class 
		frame:SetTexture("Interface/ICONS/INV_Sigil_Thorim.png")
	end
end

----------- setCharName -------------------
-- Sets the charName text and color
-------------------------------------------
function RCLootCouncil_Mainframe.setCharName(frame, class, text)
	if frame then -- sanity check
		frame:SetText(text); -- set the text
		local classColor = RAID_CLASS_COLORS[class]; -- get the color code
		if not classColor then
			-- if class not found display epic color.
			classColor = {["r"] = 0.63921568627451, ["g"] = 0.2078431372549, ["b"] = 0.93333333333333, ["a"] = 1.0 }
		else
			classColor.a = 1.0;
		end
		frame:SetTextColor(classColor["r"],classColor["g"],classColor["b"],classColor["a"]); -- set the color
	end
end

---------- setCurrentGear -----------------
-- Sets the items in the given frame(s)
-------------------------------------------
function RCLootCouncil_Mainframe.setCurrentGear(item1, item2, gear1Frame, gear2Frame)
	if item1 then
		local _, _, _, _, _, _, _, _, _, item1Tex = GetItemInfo(item1); -- Get the gear1 item info
		gear1Frame:SetTexture(item1Tex) -- set the texture
		gear1Frame:Show()
		
	else -- hide it, in case we're doing a non-item
		gear1Frame:Hide()
	end
	if item2 then -- If a second item was provided
		local _, _, _, _, _, _, _, _, _, item2Tex = GetItemInfo(item2); -- Get the gear2 item info
		gear2Frame:Show()
		gear2Frame:SetTexture(item2Tex)
	else -- if not, hide, otherwise it would show a previous gear
		gear2Frame:Hide()
	end
end

--------- getPlayerRole ---------------
-- Returns the player's role or none
---------------------------------------
function RCLootCouncil.getPlayerRole(arg)
	local role;
	if not arg then
		role = UnitGroupRolesAssigned("player");
	else
		role = arg
	end
	if role == "TANK" then return "Tank";
	elseif role == "HEALER" then return "Healer";
	elseif role == "DAMAGER" then return "DPS";
	else return "None";	end
end

----------- handleResponse -----------------
-- Handles the response given by LootFrame
--------------------------------------------
function RCLootCouncil.handleResponse(response, frame)
-- entryTable order: (playerName, rank, role, totalIlvl, response, gear1, gear2, votes, class, color[], haveVoted, voters[], note)
	local id, note
	if type(frame) == "table" then
		id = frame.id
		note = frame.note
	else
		id = frame
		note = "autopass"
	end
	RCLootCouncil:debugS("responseID = "..id)
	local _, totalIlvl = GetAverageItemLevel()
	local gear1, gear2 = RCLootCouncil.getCurrentGear(lootTable[id]);
	local _, class = UnitClass("player"); -- non-localized class name
	
	local toAdd = {
		["i"] = id,
			{
				playerFullName,
				guildRank,
				RCLootCouncil.getPlayerRole(),
				math.floor(totalIlvl),
				response,
				gear1,
				gear2,
				0,
				class,
				color,
				false,
				{""},
				note,
		}
	}
	tinsert(entryTable[id], toAdd[1])
	RCLootCouncil_Mainframe.Update(true);
	self:SendCommMessage("RCLootCouncil", "add "..self:Serialize(toAdd), channel) -- tell everyone else to add it
end

 
------------- isSelected ----------------------------------------
-- Tests if they're selected or not.
-----------------------------------------------------------------
function RCLootCouncil_Mainframe.isSelected(id)
	id = id + offset -- handle the offset
	return entryTable[currentSession][id] == selection
end

------------ updateSelection ----------------
-- Selects or updates a given entry
---------------------------------------------
function RCLootCouncil_Mainframe.updateSelection(id, update)
	self:debugS("Mainframe.updateSelection("..tostring(id)..", "..tostring(update)..")");
	id = id + offset -- handle the offset
	if selection then
		for i = 1, MAX_DISPLAY do -- remove any previous selections
			getglobal("ContentFrameEntry"..i.."BG"):Hide()
			selection = nil;
		end
	end
	if not update then -- set the selection if we didn't just want to update
		selection = entryTable[currentSession][id]
	end 
	if selection then -- Check if we should update or user clicked a nonshowing row
		-- Initialize variables
		local sLink, iLevel, thisItemTexture, sLink2, thisItemTexture2;
		if selection[6] then -- if they have the first item link, get its info
			_, sLink, _, iLevel, _, _, _, _, _, thisItemTexture = GetItemInfo(selection[6]);
		end
		if selection[7] then -- if they have 2 item links, then get the second's info
			_, sLink2, _, _, _, _, _, _, _, thisItemTexture2 = GetItemInfo(selection[7]);
		end
		
		-- Remove and award button
		if isMasterLooter or isTesting then
			BtRemove:Show()
			BtAward:Hide()
			if currentSession == lootNum then
				BtAward:Show()
			end	
		else
			BtRemove:Hide()
			BtAward:Hide()
		end
		-- Show the if 1 or 2 items stuff
		if sLink2 then -- if there's two items, show the dual selection and hide the rest
			DualItemTexture1:SetTexture(thisItemTexture)
			DualItemTexture2:SetTexture(thisItemTexture2)
			DualItemLabel1:SetText(sLink)
			DualItemLabel2:SetText(sLink2)
			DualItemLabel1:Show()
			DualItemLabel2:Show()	
			DualItemTexture1:Show()
			DualItemTexture2:Show()
			DualItemSelection1:Show()
			DualItemSelection2:Show()					
			CurrentSelectionLabel:Hide()
			CurrentSelectionIlvl:Hide()
			CurrentSelectionTexture:Hide()
			CurrentSelectionHover:Hide()
			
		elseif sLink then -- Only show 1 item
			CurrentSelectionLabel:SetText(sLink)
			CurrentSelectionIlvl:SetText("ilvl: "..iLevel)
			CurrentSelectionTexture:SetTexture(thisItemTexture)
			CurrentSelectionHover:Show()
			CurrentSelectionLabel:Show()
			CurrentSelectionIlvl:Show()
			CurrentSelectionTexture:Show()		
			DualItemLabel1:Hide()
			DualItemLabel2:Hide()	
			DualItemTexture1:Hide()
			DualItemTexture2:Hide()
			DualItemSelection1:Hide()
			DualItemSelection2:Hide()
		end

		-- show the rest
		BtClear:Show()
	else -- if there's no selection, hide everything
		DualItemLabel1:Hide()
		DualItemLabel2:Hide()	
		DualItemTexture1:Hide()
		DualItemTexture2:Hide()
		DualItemSelection1:Hide()
		DualItemSelection2:Hide()
		CurrentSelectionLabel:Hide()
		CurrentSelectionIlvl:Hide()
		CurrentSelectionTexture:Hide()
		CurrentSelectionHover:Hide()
		BtRemove:Hide()
		BtClear:Hide()
		BtAward:Hide()
	end

end

------------ removeEntry ------------------
-- Removes an entry from the list
-------------------------------------------
function RCLootCouncil_Mainframe.removeEntry(session, name)
	self:debugS("Mainframe.removeEntry("..tostring(session)..", "..tostring(name)..")")
	local id;
	-- find the index of entryTable belonging to name
	for i = 1, #entryTable[session] do
		if self:UnitIsUnit(entryTable[session][i][1],name) then
			id = i
			break;
		end
	end
	if id then
		tremove(entryTable[session], id) -- remove the entry
		RCLootCouncil_Mainframe.Update(true); -- update
		if selection and self:UnitIsUnit(selection[1],name) then
			RCLootCouncil_Mainframe.updateSelection(0, true); -- and clear the selection if we had selected the one to be removed
		end
	else 
		self:debug("Couldn't remove entry/Name wasn't listed")
	end
end

------------ vote -------------------------
-- Adds votes to entrytable
-------------------------------------------
function RCLootCouncil_Mainframe.vote(id)
	self:debugS("Mainframe.vote("..tostring(id)..")")
	if id then
		id = id + offset -- handle the offset
		if entryTable[currentSession][id][11] then -- if unvote
			entryTable[currentSession][id][8] = entryTable[currentSession][id][8] - 1;
			entryTable[currentSession][id][11] = false;
			for k,v in pairs(entryTable[currentSession][id][12]) do -- remove the voter from voters table
				if self:UnitIsUnit(v,"player") then tremove(entryTable[currentSession][id][12], k); end
			end
			
			self:SendCommMessage("RCLootCouncil", "vote "..currentSession.." "..entryTable[currentSession][id][1].." devote", channel) -- tell everyone who you vote for
			if isMasterLooter and tContains(votersNames, masterLooter) then
				for k,v in pairs(votersNames) do
					if self:UnitIsUnit(v,masterLooter) then
						tremove(votersNames, k)
					end
				end
			end
			RCLootCouncil_Mainframe.Update(true); -- update the list
		else -- if vote
			if not mlDB.selfVote and self:UnitIsUnit("player",entryTable[currentSession][id][1]) then -- test that they may vote for themself
				self:Print("The master looter has turned Vote For Self OFF")
				return;
			end
			for i = 1, #entryTable[currentSession] do -- test that they are not multivoting
				 if entryTable[currentSession][i][11] and not mlDB.multiVote then
					 self:Print("The master looter has turned off multivoting")
					 return;
				 end
			end
			entryTable[currentSession][id][8] = entryTable[currentSession][id][8] + 1;
			entryTable[currentSession][id][11] = true
			tinsert((entryTable[currentSession][id][12]), playerFullName) -- add the voter to the voters table
			self:SendCommMessage("RCLootCouncil", "vote "..currentSession.." "..entryTable[currentSession][id][1].." vote", channel) -- tell everyone who you devote for
			if isMasterLooter and not tContains(votersNames, masterLooter) then
				tinsert(votersNames, masterLooter)
			end
			RCLootCouncil_Mainframe.Update(true); -- update the list
		end

	else
		self:debug("False id @.vote")
	end
end

------------- voteOther -----------------
-- Add another player's vote to the entry
-----------------------------------------
function RCLootCouncil_Mainframe.voteOther(session, name, devote, voter)
	self:debugS("Mainframe.voteOther("..tostring(name)..", "..tostring(devote)..", "..tostring(voter)..")")
	if name and session then
		for i = 1, #entryTable[session] do -- find the id belonging to the name
			if self:UnitIsUnit(entryTable[session][i][1],name) then
				if devote == "devote" then
					entryTable[session][i][8] = entryTable[session][i][8] - 1; -- remove the vote
					for k,v in pairs(entryTable[session][i][12]) do -- remove the voter from voters table
						if self:UnitIsUnit(v,voter) then tremove(entryTable[session][i][12], k); end
					end
				else
					entryTable[session][i][8] = entryTable[session][i][8] + 1; -- add the vote
					tinsert((entryTable[session][i][12]), voter) -- add the voter to the voters table
				end
				RCLootCouncil_Mainframe.Update(true); -- update the list
				return;
			end
		end
	else
		self:debug("Bad name ("..tostring(name)..") or session ("..tostring(session).." in voteOther")
	end
end

---------- award ------------------------
-- Gives the item to the selected player
-----------------------------------------
function RCLootCouncil_Mainframe.award(reason)
	self:debugS("Mainframe.award()")
	if not selection or lootNum == 0 then -- if noone is selected or if there's not a loot in the list
		self:debug("award called without selection or with lootNum = 0")
		self:Print("Something went wrong, please try again.")
		return;
	elseif isTesting then
		if IsInRaid() or nnp then -- continue
			self:Print("The item would now be awarded to "..Ambiguate(selection[1], "short"))
			if lootNum < #itemsToLootIndex then -- if there's more items to loot
				RCLootCouncil_Mainframe.abortLooting() -- stop the current looting
				lootNum = lootNum + 1; 
				isTesting = true
				RCLootCouncil:initiateNext(lootTable[lootNum]); -- start it
			else -- if there's not
				self:Print("Raid Test concluded.")
				self:SendCommMessage("RCLootCouncil", "stop", channel) -- tell the council to stop as well
				RCLootCouncil_Mainframe.abortLooting()
				RCLootCouncil_Mainframe.stopLooting()
				CloseButton_OnClick(); 
			end
		else
			self:Print("The item would now be awarded to "..Ambiguate(selection[1], "short").." and the loot session concluded.")
			RCLootCouncil_Mainframe.abortLooting()
			RCLootCouncil_Mainframe.stopLooting()
		end
		return;
	else -- if there are
		for i = 1, GetNumGroupMembers() do
			if self:UnitIsUnit(GetMasterLootCandidate(itemsToLootIndex[lootNum], i),selection[1]) then
				if #itemsToLootIndex > 0 and lootNum > 0 then -- if there really is something to loot
					local _, _, lootQuantity = GetLootSlotInfo(itemsToLootIndex[lootNum])
					if lootQuantity > 0 then -- be certain there's an item
						GiveMasterLoot(itemsToLootIndex[lootNum], i); -- give the item
						self:debug(""..selection[1].." was award with "..itemRunning);
					else
						self:Print("Couldn't award the loot since it has already been awarded!")
						return;
					end				
				else -- the function was called by something else
					self:debug("award called without items!")
					self:Print("Error awarding loot, please restart the looting session.")
					return;
				end
				-- Chat output:
				if db.awardAnnouncement then
					if db.awardMessageChat1 ~= "NONE" then -- if we want to tell who won
						local message = gsub(db.awardMessageText1, "&p", Ambiguate(selection[1], "short"))
						message = gsub(message, "&i", itemRunning)
						SendChatMessage(message, db.awardMessageChat1); -- then do it
					end
					if db.awardMessageChat2 ~= "NONE" then -- if the user is posting to 2 channels
						local message = gsub(db.awardMessageText2, "&p", Ambiguate(selection[1], "short"))
						message = gsub(message, "&i", itemRunning)
						SendChatMessage(message, db.awardMessageChat2);
					end
				end

				-- Item awards history:
				-- lootDB format: "name" = {"lootWon", "date (d/m/y)", "time (h:m:s)", "instance", "boss", "votes", "itemReplaced1", "itemReplaced2"}	
				local instanceName, _, _, difficultyName = GetInstanceInfo()
				local table;
				if reason and reason.log then -- not a roll response
					table = {["lootWon"] = itemRunning, ["date"] = date("%d/%m/%y"), ["time"] = date("%H:%M:%S"), ["instance"] = instanceName.." "..difficultyName, ["boss"] = bossName, ["votes"] = selection[8], ["itemReplaced1"] = selection[6], ["itemReplaced2"] = selection[7], ["response"] = reason.text, ["responseID"] = 0}
				elseif not reason then
					table = {["lootWon"] = itemRunning, ["date"] = date("%d/%m/%y"), ["time"] = date("%H:%M:%S"), ["instance"] = instanceName.." "..difficultyName, ["boss"] = bossName, ["votes"] = selection[8], ["itemReplaced1"] = selection[6], ["itemReplaced2"] = selection[7], ["response"] = buttonsDB[selection[5]]["response"], ["responseID"] = selection[5]}
				end
				-- The ML sends the history, if he wants others to be able to track it.
				if db.sendHistory and table then
					self:SendCommMessage("RCLootCouncil", "award "..Ambiguate(selection[1], "short").." "..self:Serialize(table), channel)
				end

				-- Only store the data if the user wants to
				if db.trackAwards and table then 
					if lootDB[Ambiguate(selection[1], "short")] then -- if the name is already registered in the table
						tinsert(lootDB[Ambiguate(selection[1], "short")], table)
					else -- if it isn't
						lootDB[Ambiguate(selection[1], "short")] = {table};
					end
				end
				
				-- Continue with next item or stop?:
				if lootNum < #itemsToLootIndex then -- if there's more items to loot
					RCLootCouncil_Mainframe.abortLooting() -- stop the current looting
					lootNum = lootNum + 1; 
					RCLootCouncil:initiateNext(lootTable[lootNum]); -- start it
				else -- if there's not
					self:SendCommMessage("RCLootCouncil", "stop", channel) -- tell the council to stop as well
					RCLootCouncil_Mainframe.abortLooting()
					RCLootCouncil_Mainframe.stopLooting()
					CloseButton_OnClick(); 
				end
				return;
			end	
		end
	end
	-- if the function haven't returned by now then it means noone was in the raid (i.e. debug) or an error
	if nnp and GetNumGroupMembers() == 0 then -- not in group and debugging is on
		if #itemsToLootIndex > 0 and lootNum > 0 then
			LootSlot(itemsToLootIndex[lootNum]); -- give to self
		else
			LootSlot(lootNum)
		end
		local instanceName, _, _, difficultyName = GetInstanceInfo()
		local table;
		if reason and reason.log then -- not a roll response
			table = {["lootWon"] = itemRunning, ["date"] = date("%d/%m/%y"), ["time"] = date("%H:%M:%S"), ["instance"] = instanceName.." "..difficultyName, ["boss"] = bossName, ["votes"] = selection[8], ["itemReplaced1"] = selection[6], ["itemReplaced2"] = selection[7], ["response"] = reason.text, ["responseID"] = 0}
		elseif not reason then
			table = {["lootWon"] = itemRunning, ["date"] = date("%d/%m/%y"), ["time"] = date("%H:%M:%S"), ["instance"] = instanceName.." "..difficultyName, ["boss"] = bossName, ["votes"] = selection[8], ["itemReplaced1"] = selection[6], ["itemReplaced2"] = selection[7], ["response"] = buttonsDB[selection[5]]["response"], ["responseID"] = selection[5]}
		end

		-- Only store the data if the user wants to
		if db.trackAwards and table then 
			if lootDB[Ambiguate(selection[1], "short")] then -- if the name is already registered in the table
				tinsert(lootDB[Ambiguate(selection[1], "short")], table)
			else -- if it isn't
				lootDB[Ambiguate(selection[1], "short")] = {table};
			end
		end
		if lootNum < #itemsToLootIndex then -- if there's more items to loot
			RCLootCouncil_Mainframe.abortLooting()
			lootNum = lootNum + 1; 
			RCLootCouncil:initiateNext(lootTable[lootNum]); -- start it
		else
			RCLootCouncil_Mainframe.abortLooting()
			RCLootCouncil_Mainframe.stopLooting()
			CloseButton_OnClick()
		end
		return;
	else
		self:Print("Error awarding the loot");	
	end
	self:debug("Award function finished without conclusion!")
end

------------- getGuildRankNum --------------------
-- Gets the actual rank number for the player
--------------------------------------------------
function RCLootCouncil_Mainframe.getGuildRankNum(playerName)
	GuildRoster();
	if playerName then
		for ci=1, GetNumGuildMembers() do
			local name, rank, rankIndex = GetGuildRosterInfo(ci)
			name = Ambiguate(name, "none")
			if self:UnitIsUnit(name, playerName) then
				return rankIndex, rank
			end
		end
	end
	return 11
end

------------- getLowestItemLevel -----------------
-- Used in sorting
-- Returns the lower of 2 item levels
--------------------------------------------------
function RCLootCouncil_Mainframe.getLowestItemLevel(entry)
	if entry then
		if entry[7] then
			local _, _, _, itemLevel = GetItemInfo(entry[6])
			local _, _, _, itemLevel2 = GetItemInfo(entry[7])
			if itemLevel >= itemLevel2 then
				return itemLevel2
			else
				return itemLevel
			end			
		elseif entry[6] then
			local _, _, _, itemLevel = GetItemInfo(entry[6])
			return itemLevel
		else
			return -1
		end
	end
	return -1
end
			
------------- sortTable --------------------------
-- Sorts the table when you click on a header
--------------------------------------------------
function RCLootCouncil_Mainframe.sortTable(id, specialSort)
	self:debugS("Mainframe.sortTable("..tostring(id)..", "..tostring(specialSort)..")")
	if not specialSort then -- just do it the normal way
		if currSortIndex == id then -- if we're already sorting this one
			if sortMethod == "asc" then -- then switch the order
				sortMethod = "desc"
			else
				sortMethod = "asc"
			end
		elseif id then -- if we got a valid id
			currSortIndex = id -- then initialize our sort index
			sortMethod = "asc"	-- and the order we're sorting in
			if id == 4 then 
				sortMethod = "desc" -- flip rolls since we've already sorted for that
			end
		end
	else
		sortMethod = "asc"
	end
-- entryTable order: (playerName, rank, role, totalIlvl, response, gear1, gear2, votes, class, color[], haveVoted, voters[])
	if (id == 0) then -- Char Name sorting (alphabetically)
		table.sort(entryTable[currentSession], function(v1, v2)
			if v1[5] == mlDB.passButton and db.filterPasses then
				return false;
			elseif v2[5] == mlDB.passButton and db.filterPasses then
				return true
			end
			if sortMethod == "desc" then
				return v1[1] > v2[1]			
			else
				return v1[1] < v2[1]
			end
		end)
		
	elseif (id == 1) then -- Guild Rank sorting (numerically)
		table.sort(entryTable[currentSession], function(v1, v2)
			if v1[5] == mlDB.passButton and db.filterPasses then
				return false;
			elseif v2[5] == mlDB.passButton and db.filterPasses then
				return true
			end
			if sortMethod == "desc" then
				return (v1 and RCLootCouncil_Mainframe.getGuildRankNum(v1[1]) > RCLootCouncil_Mainframe.getGuildRankNum(v2[1]))
			else
				return (v1 and RCLootCouncil_Mainframe.getGuildRankNum(v1[1]) < RCLootCouncil_Mainframe.getGuildRankNum(v2[1]))
			end
		end)
		
	elseif (id == 2) then -- Role sorting (alphabetically)
		table.sort(entryTable[currentSession], function(v1, v2)
			if v1[5] == mlDB.passButton and db.filterPasses then
				return false;
			elseif v2[5] == mlDB.passButton and db.filterPasses then
				return true
			end
			if sortMethod == "desc" then
				return v1[3] > v2[3]		
			else
				return v1[3] < v2[3]
			end
		end)
		
	elseif (id == 3) then -- Totalilvl sorting (numerically)
		table.sort(entryTable[currentSession], function(v1, v2)
			if v1[5] == mlDB.passButton and db.filterPasses then
				return false;
			elseif v2[5] == mlDB.passButton and db.filterPasses then
				return true
			end
			if sortMethod == "desc" then
				return v1[4] > v2[4]		
			else
				return v1[4] < v2[4]
			end
		end)
		
	elseif (id == 4) then -- Response sorting (need/greed/minor/pass)
		table.sort(entryTable[currentSession], function(v1, v2)
			if v1[5] == mlDB.passButton and db.filterPasses then
				return false;
			elseif v2[5] == mlDB.passButton and db.filterPasses then
				return true
			end
			if sortMethod == "desc" then
				return v1[5] > v2[5]		
			else
				return v1[5] < v2[5]
			end				
		end)
		
	elseif (id == 5) then -- Item Level Sorting (lowest item level at the top - largest upgrade so to speak)
		table.sort(entryTable[currentSession], function(v1, v2)
			if v1[5] == mlDB.passButton and db.filterPasses then
				return false;
			elseif v2[5] == mlDB.passButton and db.filterPasses then
				return true
			end
			if sortMethod == "desc" then
				return ((v1 ~= nil) and (v2 == nil or ((RCLootCouncil_Mainframe.getLowestItemLevel(v1) ~= -1) and (RCLootCouncil_Mainframe.getLowestItemLevel(v1) > RCLootCouncil_Mainframe.getLowestItemLevel(v2)))))
			else
				return ((v1 ~= nil) and (v2 == nil or ((RCLootCouncil_Mainframe.getLowestItemLevel(v1) ~= -1) and (RCLootCouncil_Mainframe.getLowestItemLevel(v1) < RCLootCouncil_Mainframe.getLowestItemLevel(v2)))))
			end
		end)
		
	elseif (id == 6) then -- votes sorting (numerically)
		table.sort(entryTable[currentSession], function(v1, v2)
			if v1[5] == mlDB.passButton and db.filterPasses then
				return false;
			elseif v2[5] == mlDB.passButton and db.filterPasses then
				return true
			end
			if sortMethod == "desc" then
				return v1[8] > v2[8]		
			else
				return v1[8] < v2[8]
			end
		end)
	end
	RCLootCouncil_Mainframe.Update(true)
end

------------- getML -----------------------------------
-- returns the masterlooter or the player if debugging
-- or activates masterlooting
-------------------------------------------------------
function RCLootCouncil_Mainframe.getML()
	--self:debugS("Mainframe.getML()")
	if not IsInRaid() and nnp then  -- out of raid and debug on
		isMasterLooter = true;
		return playerFullName
	end
	local lootMethod, _, MLRaidID = GetLootMethod()
	if lootMethod == 'master' then
		local name = GetRaidRosterInfo(MLRaidID)
		isMasterLooter = self:UnitIsUnit(name,"player")
		self:debug("Masterlooter is: "..tostring(name))
		if isMasterLooter and not self:UnitIsUnit(masterLooter, name) and not isRunning then -- we've been elected ML!
			StaticPopup_Show("RCLOOTCOUNCIL_CONFIRM_USAGE")
		end
		return name;
	elseif isRunning and UnitIsGroupLeader("player") then -- if masterlooting isn't on, turn it on, but only if we're running and are the raid leader	
		SetLootMethod("master", playerName)
		self:Print("Looting method changed to \"Master Looter\"")
		isMasterLooter = true
		return playerFullName;
	end
	isMasterLooter = false
	return ""; 
end

------------- isCouncil -------------------------------
-- returns true if the player is in the council
-------------------------------------------------------
function RCLootCouncil_Mainframe.isCouncil()
	--self:debugS("Mainframe.isCouncil()")
	if isMasterLooter then return true; end;
	if #currentCouncil > 0 then
		for _, v in ipairs(currentCouncil) do
			if self:UnitIsUnit(v,"player") then
				self:debug("I am in the council!")
				return true
			end
		end
		return false
	else return false; end
end

------------ setRank -----------------------
-- Gets the minimum rank from RCRankFrame
-- and saves the council accordingly
--------------------------------------------
function RCLootCouncil_Mainframe.setRank(rank)
	db.minRank = rank;
	GuildRoster()
	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex = GetGuildRosterInfo(i) -- get info from all guild members
		if rankIndex + 1 <= db.minRank then -- if the member is the required rank, or above
			table.insert(db.council, name) -- then insert them to the council
		end
	end
end

-------------- Update ------------------
-- Handles the scrollbar visualization
-- and updates the contentFrame
-- arg: true to show, false to hide entries
----------------------------------------
function RCLootCouncil_Mainframe.Update(update)
	-- we don't want to enter this function unless we can actually see the Voting Frame
	if not isMasterLooter and not isCouncil and not isTesting then return; end;
	if update then -- if the table doesn't exist, we want to hide the entries
		FauxScrollFrame_Update(ContentFrame, #entryTable[currentSession], MAX_DISPLAY, 20, nil, nil, nil, nil, nil, nil, true);
	end
	offset = FauxScrollFrame_GetOffset(ContentFrame)

	-- People still to roll string
	if update and ( GetNumGroupMembers() == 0 and #entryTable[currentSession] == 1 and isTesting) or ( GetNumGroupMembers() ~= 0 and #entryTable[currentSession] == GetNumGroupMembers() ) then -- if everybody has rolled or we're alone
		PeopleToRollLabel:SetTextColor(0,1,0,1) -- make the text green
		if (isMasterLooter or isTesting) and #votersNames == #currentCouncil then
			PeopleToRollLabel:SetText("Everyone have rolled and voted!")	
		elseif isMasterLooter or isTesting then
			PeopleToRollLabel:SetText("Everyone have rolled - "..#votersNames.." of "..#currentCouncil.." have voted!")
			PeopleToRollLabel:SetTextColor(1,1,0,1) -- make the text yellow
		else
			PeopleToRollLabel:SetText("Everyone have rolled!")
		end
		
		local passes = 0
		for j = 1, #entryTable[currentSession] do
			if entryTable[currentSession][j][5] == mlDB.passButton then
				passes = passes + 1;
			end
		end

		if db.filterPasses and (( GetNumGroupMembers() == 0 and passes == 1 and isTesting ) or ( passes == GetNumGroupMembers() and isMasterLooter )) then						
			self:Print("Everyone passed! Turn \"Filter Passes\" off in order to distribute the loot.")
		end

		if (GetNumGroupMembers() == 0 and #entryTable[currentSession] == 1 and passes == 1) or not isTesting and passes == GetNumGroupMembers() then
			PeopleToRollLabel:SetText("Everyone have passed!")
			PeopleToRollLabel:SetTextColor(0.75, 0.75,0.75,1) -- make the text gray
		end		

	elseif update then -- if someone haven't rolled
		PeopleToRollLabel:SetTextColor(1,1,1,1) -- make the text white
		if isMasterLooter and #votersNames == #currentCouncil then
			PeopleToRollLabel:SetText(""..GetNumGroupMembers() - #entryTable[currentSession].." - everyone have voted!")
			PeopleToRollLabel:SetTextColor(1,0,0,1) -- make the text red
		elseif isMasterLooter and #votersNames > 0 then
			PeopleToRollLabel:SetText(""..GetNumGroupMembers() - #entryTable[currentSession].." - "..#votersNames.." of "..#currentCouncil.." have voted!")
		elseif isTesting and GetNumGroupMembers() == 0 then 
			PeopleToRollLabel:SetText("1")
		else
			PeopleToRollLabel:SetText(GetNumGroupMembers() - #entryTable[currentSession])					
		end
	end

	for i = 1, MAX_DISPLAY do 
		local line = offset + i; 
		if update and entryTable[currentSession][line] then -- if there's something at a given entry and we want to update
			local entry = entryTable[currentSession][line]
			-- Start setting all the text(ures):
			RCLootCouncil_Mainframe.setCharName(getglobal("ContentFrameEntry"..i.."CharName"),entry[9], Ambiguate(entry[1], "short")) -- set the charName and color
			getglobal("ContentFrameEntry"..i.."Rank"):SetText(entry[2])
			getglobal("ContentFrameEntry"..i.."Role"):SetText(entry[3])
			getglobal("ContentFrameEntry"..i.."Totalilvl"):SetText(entry[4])
			getglobal("ContentFrameEntry"..i.."Response"):SetText(mlDB.buttons[entry[5]]["response"])
			getglobal("ContentFrameEntry"..i.."VoteHoverVotes"):SetText(entry[8])
			RCLootCouncil_Mainframe.setClassIcon(getglobal("ContentFrameEntry"..i.."ClassTexture"), entry[9]); -- set the class-texture
			
			-- set the note button texture
			if entry[13] then -- normal
				getglobal("ContentFrameEntry"..i.."NoteButton"):SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Up.png")
			else -- disabled
				getglobal("ContentFrameEntry"..i.."NoteButton"):SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Disabled.png")
			end
					 			
			-- set the vote button properly
			getglobal("ContentFrameEntry"..i.."BtVote"):Show()
			if entry[11] then
				getglobal("ContentFrameEntry"..i.."BtVote"):SetText("Unvote")
			else
				getglobal("ContentFrameEntry"..i.."BtVote"):SetText("Vote")
			end

			-- set the colors:
			local color = mlDB.buttons[entry[5]]["color"]
			getglobal("ContentFrameEntry"..i.."Rank"):SetTextColor(color[1],color[2],color[3],color[4])
			getglobal("ContentFrameEntry"..i.."Role"):SetTextColor(color[1],color[2],color[3],color[4])
			getglobal("ContentFrameEntry"..i.."Totalilvl"):SetTextColor(color[1],color[2],color[3],color[4])
			getglobal("ContentFrameEntry"..i.."Response"):SetTextColor(color[1],color[2],color[3],color[4])

			-- Set the item textures
			RCLootCouncil_Mainframe.setCurrentGear(entry[6], entry[7], getglobal("ContentFrameEntry"..i.."CurrentGear1HoverCurrentGear1"),getglobal("ContentFrameEntry"..i.."CurrentGear2HoverCurrentGear2"));
			
			-- Only show entries if we don't filter for passes
			if db.filterPasses and entry[5] == mlDB.passButton then
				getglobal("ContentFrameEntry"..i):Hide();
			else
				getglobal("ContentFrameEntry"..i):Show();
			end

		else -- if there's nothing at an entry
			getglobal("ContentFrameEntry"..i):Hide();
		end	
	end
	if isMinimized then RCLootCouncil_Mainframe.minimize("minimize"); end;
end
---------- testFrames ---------------
-- Shows all frames for testing
-------------------------------------
function RCLootCouncil_Mainframe.testFrames()
	self:debugS("Mainframe.testFrames()")
	for j = 1, 9 do
		if j == 4 then j = 5 end; -- skip the shirt
		local itemLink = GetInventoryItemLink("player", j)
		if itemLink ~= nil then				
			lootTable[1] = itemLink	
			lootNum = 1;
			itemRunning = itemLink
			masterLooter = playerFullName
			isTesting = true
			mlDB = db.dbToSend
			--RCLootCouncil:announceConsideration()
			RCLootCouncil_LootFrame:Update(lootTable)	
			RCLootCouncil_Mainframe.prepareLootFrame(itemLink)
			lootFramesCreated = true
			self:Print("Local Solo Test initiated.")
			break;
		end
	end
end
---------- raidTestFrames ---------------
-- Tests the frames
-------------------------------------
function RCLootCouncil_Mainframe.raidTestFrames(arg)
	self:debugS("Mainframe.raidTestFrames("..arg..")")
	if IsInRaid() or nnp then
		if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or nnp then -- if we're the group leader/assistant
			RCLootCouncil_Mainframe.abortLooting()
			RCLootCouncil_Mainframe.stopLooting()
			self:SendCommMessage("RCLootCouncil", "stop", channel) -- tell the council to stop as well
			isRunning = true
			masterLooter = playerFullName

			-- increase MAX_ITEMS or run multiple tests to test large loot table
			local table = {
				105473,
				105407,
				105513,
				105465,
				105482,
				104631,
				105450,
				105537,
				104554,
				105509,
				104412,
				105499,
				104476,
				104544,
				104495,
				105568,
				105594,
				105514,
				105479,
				104532,
				105639,
				104508,
				105621,
			}
			-- get the client to cache all test items
			for i = 1, #table do
				GetItemInfo(table[i])
			end
			-- pick n random items from the test table
			for i = 1, arg do
				if i > #table or i > MAX_ITEMS then break; end
				local j = math.random(1, #table)
				local _, link = GetItemInfo(table[j])
				tinsert(lootTable, link)
				tinsert(itemsToLootIndex, i)
			end

			isTesting = true;
			lootNum = 1;
			hasItemInfo = true
			RCLootCouncil_initiateLoot(lootTable[lootNum])
			self:Print("Raid Test initiated.")

		else
			self:Print("Only Group Leader/assistants can issue a raid test.")	
		end
	else
		self:Print("You cannot raidtest without being in a raid.")
	end
end

----------- isRunning -------------
-- Sets isRunning = true/false
-- or returns the state if arg
---------------------------------------
function RCLootCouncil.isRunning()
	self:debugS("isRunning()")
	isRunning = not isRunning
	if isRunning then
		self:Print("Activated")
		masterLooter = RCLootCouncil_Mainframe.getML()
	else
		self:Print("Deactivated")
	end
end

---------- buttonsToDefault --------------
-- Sets the button/response options back to default
-----------------------------------
function RCLootCouncil:buttonsToDefault()
	for i = 1, db.dbToSend.numButtons do
		self.db.profile.dbToSend.buttons[i]["text"] = defaults.profile.dbToSend.buttons[i]["text"]
		for j = 1, 4 do
			self.db.profile.dbToSend.buttons[i]["color"][j] = defaults.profile.dbToSend.buttons[i]["color"][j]
		end
		self.db.profile.dbToSend.buttons[i]["response"] = defaults.profile.dbToSend.buttons[i]["response"]
		self.db.profile.dbToSend.buttons[i]["whisperKey"] = defaults.profile.dbToSend.buttons[i]["whisperKey"]
	end
	self.db.profile.dbToSend.numButtons = defaults.profile.dbToSend.numButtons;
	self.db.profile.dbToSend.passButton = defaults.profile.dbToSend.passButton;
	self.db.profile.acceptWhispers = defaults.profile.acceptWhispers;
	self.db.profile.acceptRaidChat = defaults.profile.acceptRaidChat;
end

---------- announceToDefault --------------
-- Sets the button/response options back to default
-----------------------------------
function RCLootCouncil:announceToDefault()
	self.db.profile.awardAnnouncement = defaults.profile.awardAnnouncement;
	self.db.profile.awardMessageChat1 = defaults.profile.awardMessageChat1;
	self.db.profile.awardMessageText1 = defaults.profile.awardMessageText1;
	self.db.profile.awardMessageChat2 = defaults.profile.awardMessageChat2;
	self.db.profile.awardMessageText2 = defaults.profile.awardMessageText2;
	self.db.profile.announceText = defaults.profile.announceText;
	self.db.profile.announceChannel = defaults.profile.announceChannel;
end

--------- otherAwardReasonsToDefault ---------
function RCLootCouncil:otherAwardReasonsToDefault()
	self.db.profile.otherAwardReasons = defaults.profile.otherAwardReasons
end

--------- GetVersion -------------
-- Returns the current version
----------------------------------
function RCLootCouncil:GetVersion()
	return version;
end

---------- voteHover -------------
-- Displays the voters
----------------------------------
function RCLootCouncil_Mainframe:voteHover(id)
	if (not mlDB.anonymousVoting or (mlDB.masterLooterOnly and (isMasterLooter or isTesting))) and #entryTable[currentSession][id][12] > 1 then -- check if voting is anonymous
		if id then 
			id = id + offset
			GameTooltip:SetOwner(MainFrame, "ANCHOR_CURSOR")
			GameTooltip:AddLine("Voters\n")
			for k,v in pairs(entryTable[currentSession][id][12]) do
				GameTooltip:AddLine(Ambiguate(v, "short"),1,1,1)
			end
			GameTooltip:Show()
		else
		 self:debug("Bad id in voteHover")
		end
	end
end

---------- PeopleToRollHover ----------------
-- Shows which people there's still to roll
---------------------------------------------
function RCLootCouncil_Mainframe:PeopleToRollHover()
	RCLootCouncil:debugS("Mainframe.PeopleToRollHover()")
	local peopleToRoll = {}	
	for i = 1, GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i)
		local test = true
		for j = 1, #entryTable[currentSession] do
			if self:UnitIsUnit(entryTable[currentSession][j][1], name) then test = false; end			
		end
		if test then tinsert(peopleToRoll, name); end
	end
	GameTooltip:SetOwner(MainFrame, "ANCHOR_CURSOR")
	GameTooltip:AddLine("People still to roll\n")
	if #peopleToRoll >= 1 then
		for k,v in pairs(peopleToRoll) do
			GameTooltip:AddLine(Ambiguate(v, "short"),1,1,1)
		end
	else
		GameTooltip:AddLine("None",1,1,1)
	end
	if isMasterLooter and (not mlDB.anonymousVoting or (mlDB.anonymousVoting and mlDB.masterLooterOnly)) then -- add the voters info
		GameTooltip:AddLine("Voters\n")
		for k,v in pairs(currentCouncil) do
			if tContains(votersNames, v) then
				GameTooltip:AddLine(Ambiguate(v, "short"),0,1,0)
			else
				GameTooltip:AddLine(Ambiguate(v, "short"),1,0,0)
			end
		end
	end
	GameTooltip:Show();
end

---------- LootOnClick ------------------
-- Hooked from LootButton_OnClick
-----------------------------------------
function RCLootCouncil:LootOnClick(button)
	   self:debugS("LootOnClick(button)")
	if InCombatLockdown() and IsAltKeyDown() then 
		self:Print("Cannot initiate loot while in combat")
	elseif db.altClickLooting and IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown() then
		self:debug("LootOnClick called")
		-- check that we don't add an item we're already looting
		for k,v in pairs(itemsToLootIndex) do
			if v == button.slot then -- if we're already looting that slot
				self:Print("That slot is already being looted.")
				return;
			end
		end
		for i = 1, #entryTable do -- clear the entryTable for already received answers
			wipe(entryTable[i])
		end
		if getglobal("ElvLootFrame") then
			button.slot = button:GetID() -- ElvUI hack
		end

		tinsert(lootTable, GetLootSlotLink(button.slot)) -- add the item link to the table
		tinsert(itemsToLootIndex, button.slot) -- add its index to the lootTable		
		
		if #lootTable == 1 then -- only initiate the first item
			lootNum = 1
			RCLootCouncil_initiateLoot(GetLootSlotLink(button.slot))
		else -- redo voting if more items were alt clicked before last item was awarded
			RCLootCouncil_Mainframe.abortLooting()
			self:SendCommMessage("RCLootCouncil", "stop", channel) -- tell the council to stop as well
			
			-- clear items already looted so they aren't rerolled
			if lootNum > 1 then
				for i = lootNum-1, 1, -1  do
					if not lootTable[i] then break end
					tremove(lootTable, i)
					tremove(itemsToLootIndex, i)
				end
			end
			
			currentSession = 1
			lootNum = 1
			RCLootCouncil_initiateLoot(lootTable[lootNum])
--			RCLootCouncil_LootFrame:Update(lootTable)
--			RCLootCouncil_Mainframe:UpdateSessionButtons()
		end
	end
end

------------- GetItemsFromMessage ------------
-- Extracts items from a message and adds them
-- to the entryFrame.
----------------------------------------------
function RCLootCouncil:GetItemsFromMessage(msg, sender)
	RCLootCouncil:debugS("GetItemsFromMessage("..tostring(msg)..", "..tostring(sender)..")")
	if msg == db.announceText or msg == db.awardMessageText1 or msg == db.awardMessageText2 then return; end
	if isMasterLooter then
		local theItem = msg:find("|Hitem:"); -- See if they linked an item	
		if theItem  then -- If they entered a valid item
			self:debugS("item1 might be: "..theItem)
			local actualItemString2; -- Initialize for possibility of 2 item links
			local startLoc = string.find(msg, "Hitem:") -- Make sure they linked an item
			if startLoc > 13 then return; end -- Hitem should start at 12, otherwise it's irrelevant
			local endLoc = string.find(msg, "|r", startLoc)
			local actualItemString = string.match(msg, "|%x+|Hitem:.-|h.-|h|r");
			self:debugS("actualItemString: "..actualItemString)		
			startLoc = string.find(msg, "Hitem:", endLoc) --See if they linked a second item
			
			if startLoc then -- If they did
				self:debugS("Two items found!")
				local laterString = string.sub(msg, endLoc);
				actualItemString2 = string.match(laterString, "|%x+|Hitem:.-|h.-|h|r");
			end
			
			local _, iLink1 = GetItemInfo(actualItemString); -- Get better info for item 1
			local iLink2;
			if actualItemString2 then -- and item 2
				_, iLink2 = GetItemInfo(actualItemString2);
				-- also get the new endLoc so we can check for whisperKeys
				endLoc = string.find(msg, "|r", startLoc)
			end 
			
			-- lets check if they supplied a whisper key
			local responseNum = 1; -- default is Main Spec
			local restOfMsg = string.sub(msg, endLoc)
			local whisperKeys = {}
			for i = 1, mlDB.numButtons do --go through all the button				
				gsub(buttonsDB[i]["whisperKey"], '[%w]+', function(x) tinsert(whisperKeys, {key = x, num = i}) end) -- extract the whisperKeys to a table
			end
			self:debugS("restOfMsg = "..restOfMsg)
			for k,v in ipairs(whisperKeys) do
				self:debugS("whisperKeys["..k.."] = num = "..v.num.." key = "..v.key)
				if strmatch(restOfMsg, v.key) then -- if we found a match
					responseNum = v.num
					break;
				end
			end

			-- now that the items is in place, we need some info on the player, and we need to generate it from only the name
			local name, class, rank, role;
			for i = 1, GetNumGroupMembers() do
				name, _, _, _, _, class = GetRaidRosterInfo(i)
				if self:UnitIsUnit(name, sender) then
					role = UnitGroupRolesAssigned("raid"..i)
					role = RCLootCouncil.getPlayerRole(role)
					_, rank = GetGuildInfo(sender)
					break;
				end
			end	 		
			-- add the entry to the player's own entryTable
			local toAdd = {
				["i"] = lootNum,
				{
					sender,
					rank or "",
					role or "",
					0,
					responseNum,
					iLink1,
					iLink2,
					0,
					class,
					color,
					false,
					{""},
					nil,
				}
			}
			RCLootCouncil_Mainframe.removeEntry(lootNum, sender) -- just remove it right away to avoid doubles (.removeEntry will handle errors)
			self:SendCommMessage("RCLootCouncil", "remove "..lootNum.." "..sender, channel)
			tinsert(entryTable[lootNum], toAdd[1])
			self:SendCommMessage("RCLootCouncil", "add "..self:Serialize(toAdd), channel)	
			RCLootCouncil_Mainframe.Update(true)
			self:Print("Item received and added from "..Ambiguate(sender, "short")..".")
			-- tell the player what they've been added as
			SendChatMessage("[RCLootCouncil]: Acknowledged as \""..buttonsDB[responseNum]["response"].."\"", "WHISPER", nil, sender)
		end
	end
end

------------ NameHover ---------------
-- Creates the tooltip for recent loots
--------------------------------------
function RCLootCouncil_Mainframe:NameHover(id)
	if not id then return; end;
	GameTooltip:SetOwner(MainFrame, "ANCHOR_CURSOR")
	local name = Ambiguate(entryTable[currentSession][id][1], "short")
	GameTooltip:AddLine(name) -- add the name as the first line
	GameTooltip:AddLine(" ")
	-- find the last awarded mainspec item and date
	if lootDB[name] then -- if they're even in the db
		for i = #lootDB[name], 1, -1 do -- start with the end, and count downwards
			if lootDB[name][i]["responseID"] == 1 then -- the last mainspec loot awarded
				local dateString = RCLootCouncil:GetNumberOfDaysFromNow(lootDB[name][i]["date"])
				local firstDateString = RCLootCouncil:GetNumberOfDaysFromNow(lootDB[name][1]["date"])
				GameTooltip:AddDoubleLine("Time since last MainSpec loot:", dateString, 1,1,1, 1,1,1)
				GameTooltip:AddDoubleLine("Loot:",							lootDB[name][i]["lootWon"], 1,1,1, 1,1,1)
				GameTooltip:AddDoubleLine("Dropped by:",					(lootDB[name][i]["boss"] or "Unknown"), 1,1,1, 0.862745, 0.0784314, 0.235294)
				GameTooltip:AddDoubleLine("From:",							lootDB[name][i]["instance"], 1,1,1, 0.823529, 0.411765, 0.117647)
				GameTooltip:AddDoubleLine("Item(s) replaced:",				lootDB[name][i]["itemReplaced1"], 1,1,1, 1,1,1)
				if lootDB[name][i]["itemReplaced2"] ~= "" then
					GameTooltip:AddDoubleLine(" ",				lootDB[name][i]["itemReplaced2"], 1,1,1, 1,1,1)
				end
				local itemsReceivedToday = {}
				local count = 0
				for k = #lootDB[name], 1, -1 do
					if lootDB[name][k]["date"] == date("%d/%m/%y") then -- any loots today?
						if count <= 8 then -- only show the first 8 items
							tinsert(itemsReceivedToday, lootDB[name][k]["lootWon"])
						end
						count = count + 1
					end
				end
				if count > 8 then
					tinsert(itemsReceivedToday, "+"..(count-8).." more.")
				end
				if #itemsReceivedToday > 0 then
					GameTooltip:AddLine(" ")
					GameTooltip:AddDoubleLine("Item(s) received today:",	itemsReceivedToday[1], 1,1,1, 1,1,1)
					for k = 2, #itemsReceivedToday do
						GameTooltip:AddDoubleLine(" ",	itemsReceivedToday[k], 1,1,1, 1,1,1)
					end
				end
			
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(name.." has received a total of "..#lootDB[name].." items over "..firstDateString..".", 1,1,1)
				GameTooltip:Show()
				return;
			end
		end
		-- if it get here, it means, that they've recieved loot, but never mainspec
		GameTooltip:AddLine("Has recieved a total of "..#lootDB[name].." items, but not a single one needed for mainspec.", 1,1,1)
		GameTooltip:Show()
	else -- if they're not
		GameTooltip:AddLine("Has not been logged getting any loot!", 1,1,1)
		GameTooltip:AddLine("Best give 'em some :)", 1,1,1)
		GameTooltip:Show()
	end
end

------------------ GetNumberOfDaysFromNow ---------------------
-- Calculates the number of days and years from today to arg.
-- Returns a formatted string for use in MoreInfoHover.
---------------------------------------------------------------
function RCLootCouncil:GetNumberOfDaysFromNow(date)
	local d, m, y = strsplit("/", date, 3)
	local cDayNumber = time()
	local dayNumber = time({year = "20"..y, month = m, day = d})
	local secondsBetween = cDayNumber - dayNumber;
	local days = (secondsBetween / 3600) /24; -- recalculate from seconds to days
	if days <= 1 then
		return "today";
	elseif days > 30 then
		local years = 0;
		local months = 0;
		for i = 1, 1000 do -- "infinity" loop
			if days > 30 then 	  -- lets say a month = 30 days for good measures
				days = days - 30
				months = months + 1
			end
			if months > 12 then
				years = years + 1
			end
			if days < 30 then
				if years >= 1 then
					return floor(days).." days, "..months.." months and "..years.." years.";
				else
					return floor(days).." days and "..months.." months.";				
				end
			end
		end
	else
		return floor(days).." days.";
	end
end

------------ GetVariable ---------
-- Returns the variable from string arg
----------------------------------
function RCLootCouncil:GetVariable(arg)
	if arg == "isCouncil" then
		return isCouncil;
	elseif arg == "isMasterLooter" then
		return isMasterLooter;
	elseif arg == "isRunning" then
		return isRunning;
	elseif arg == "mlDB" then
		if mlDB then return mlDB; else return db.dbToSend; end;
	end
end

------------ LootBoE -------------------------------
-- Checks if an item is BoE and if we should loot it
----------------------------------------------------
function RCLootCouncil:LootBoE(item)
	if not item then return false; end
	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GameTooltip:SetHyperlink(item)
	if GameTooltip:NumLines() > 1 then -- check that there is something here
		for i = 1, 5 do -- BoE status won't be further away than line 5
			local line = getglobal('GameTooltipTextLeft' .. i)
			if line and line.GetText then
				if line:GetText() == ITEM_BIND_ON_EQUIP then
					GameTooltip:Hide()
					if db.autolootBoE then return true; else return false; end
				end
			end
		end
	end
	GameTooltip:Hide()
	return true; -- it's not a BoE
end

-----------announceConsideration ------------------
function RCLootCouncil:announceConsideration()
	if db.announceConsideration then
		local message = gsub(db.announceText, "&i", itemRunning)
		SendChatMessage(message, db.announceChannel)
	end
end

----------- FilterPasses ---------------
function RCLootCouncil_Mainframe.FilterPasses(get)
	if get then
		getglobal("MainFrameFilterPasses"):SetChecked(db.filterPasses)
	else
		db.filterPasses = not db.filterPasses;
		getglobal("MainFrameFilterPasses"):SetChecked(db.filterPasses)
		RCLootCouncil_Mainframe.Update(true)
	end
end


------------- SendWhisperHelp ---------------
function RCLootCouncil:SendWhisperHelp(target)
	RCLootCouncil:debugS("SendWhisperHelp("..tostring(target)..")")
	local msgToSend, msgToSend1 = "", "[RCLootCouncil]: To be added on the consideration list simply link your item(s) that would be replaced by the item under consideration followed by a keyword from the following list depending on your desire:";
	SendChatMessage(msgToSend1, "WHISPER", nil, target)
	for i = 1, db.dbToSend.numButtons do
		msgToSend = "[RCLootCouncil]: "..buttonsDB[i]["text"]..":      " -- i.e. MainSpec/Need:
		msgToSend = msgToSend..""..buttonsDB[i]["whisperKey"].."." -- need, mainspec, etc
		SendChatMessage(msgToSend, "WHISPER", nil, target)
	end
	self:Print("sent whisper help to "..target)	
end

-------------- DisplayNote -------------------
function RCLootCouncil_Mainframe:DisplayNote(id)
	GameTooltip:SetOwner(MainFrame, "ANCHOR_CURSOR")
	GameTooltip:AddLine("Notes")
	GameTooltip:AddLine(entryTable[currentSession][id][13],1,1,1)
	GameTooltip:Show()
end

-------------- DebugLogAdd --------------------
function RCLootCouncil:DebugLogAdd(msg)
	if not IsInRaid() or nnp then return end -- don't log outside raid
	local time = date("%X", time())
	msg = time.." - "..msg
	if #debugLog < self.db.global.logMaxEntries then
		tinsert(debugLog, msg)
	else
		tremove(debugLog, 1)
		tinsert(debugLog, msg)
	end
end

-------------- ChangeSession ------------------
function RCLootCouncil_Mainframe:ChangeSession(id)
	RCLootCouncil:debugS("Mainframe:ChangeSession("..tostring(id)..")")
	currentSession = id
	RCLootCouncil_Mainframe.updateSelection(0, true);
	RCLootCouncil_Mainframe.prepareLootFrame(lootTable[id])
	RCLootCouncil_Mainframe.sortTable(4, true) -- Make sure we sort on responses 
end

-------------- SessionButtonOnEnter -----------
function RCLootCouncil_Mainframe:SessionButtonOnEnter(id)
	GameTooltip:SetOwner(MainFrame, "ANCHOR_RIGHT")
	if isMasterLooter and id == lootNum then
		GameTooltip:AddLine("This is the next item to award.")
		GameTooltip:AddLine("You must award this item before the others.", 1,1,1)
		GameTooltip:AddLine("All whispers received will be added to this item.",1,1,1)
	elseif id == currentSession then
		GameTooltip:AddLine("This item is currently showed.")
	elseif id < lootNum then 
		GameTooltip:AddLine("This item has been awarded!",1,0,0)
	else
		GameTooltip:AddLine("Click to view the session for:")
		GameTooltip:AddLine(lootTable[id],1,1,1)
		if isMasterLooter then
			GameTooltip:AddLine("You must award the item with a yellow border before awarding this one",1,1,1)
		end
	end
	GameTooltip:Show()
end

------------- UpdateSessionButtons ------------
function RCLootCouncil_Mainframe:UpdateSessionButtons()
	for i = 1, MAX_ITEMS do
		local button = getglobal("RCLootCouncil_SessionButton"..i)
		if lootTable[i] and not isMinimized then
			local _,_,_,_,_,_,_,_,_, texture = GetItemInfo(lootTable[i]);
			if not texture then
				texture = "Interface\InventoryItems\WoWUnknownItem01"
			end
			getglobal("RCLootCouncil_SessionButton"..i.."NormalTexture"):SetVertexColor(1,1,1)
			if i == lootNum then
				button:SetBackdropBorderColor(1,1,0,1) -- yellow
			elseif i == currentSession then
				button:SetBackdropBorderColor(0,0,0,1) -- white
			elseif i < lootNum then
				button:SetBackdropBorderColor(1,0,0,1) -- red
				getglobal("RCLootCouncil_SessionButton"..i.."NormalTexture"):SetVertexColor(0.3, 0.3, 0.3)
			else
				getglobal("RCLootCouncil_SessionButton"..i.."NormalTexture"):SetVertexColor(0.3, 0.3, 0.3)
				button:SetBackdropBorderColor(0,0,0,1) -- white
			end
			button:SetNormalTexture(texture)
			button:Show()
		else
			button:Hide()
		end
	end
end

------------ EntryOnClick ---------------------
function RCLootCouncil_Mainframe:EntryOnclick(frame, button)
	if not RCLootCouncil_Mainframe.isSelected(frame:GetID()) then
		RCLootCouncil_Mainframe.updateSelection(frame:GetID())
	end
	if button == "RightButton" and isMasterLooter then
		ToggleDropDownMenu(1, nil, menuFrame, frame , 0, 0);
	end
end

----------- RightClickMenu -------------------
function RCLootCouncil_Mainframe_RightClickMenu(menu, level)
	if level == 1 then
		UIDropDownMenu_AddButton({text = Ambiguate(selection[1], "short"), isTitle = true, notCheckable = true, disabled = true}, level);
		UIDropDownMenu_AddButton({text = "", notCheckable = true, disabled = true}, level);
		
		if currentSession == lootNum then -- greyout award buttons if we can't award.
			UIDropDownMenu_AddButton({text = "Award", notCheckable = true, func = function() if currentSession == lootNum then StaticPopup_Show("RCLOOTCOUNCIL_CONFIRM_AWARD", itemRunning, Ambiguate(selection[1], "short")); else self:Print("You cannot award this item yet.")end; end, }, level);
			UIDropDownMenu_AddButton({text = "Award for ...", value = "AWARD_FOR", notCheckable = true, hasArrow = true, }, level);
		else
			UIDropDownMenu_AddButton({text = "Award", notCheckable = true, disabled = true, tooltipTitle = "Illegal Award!", tooltipText = "You have to award the item with the yellow border first.", }, level);
			UIDropDownMenu_AddButton({text = "Award for ...", hasArrow = true, notCheckable = true, disabled = true, tooltipTitle = "Illegal Award!", tooltipText = "You have to award the item with the yellow border first.",  }, level);
		end

		UIDropDownMenu_AddButton({text = "", notCheckable = true, disabled = true}, level);
		
		UIDropDownMenu_AddButton({text = "Change Response", value = "CHANGE_RESPONSE", notCheckable = true, hasArrow = true, }, level);		
		UIDropDownMenu_AddButton({text = "Reannounce ...", value = "REANNOUNCE", notCheckable = true, hasArrow = true, }, level)
		UIDropDownMenu_AddButton({text = "Remove from consideration", notCheckable = true, func = function() self:SendCommMessage("RCLootCouncil", "remove "..currentSession.." "..selection[1], channel); RCLootCouncil_Mainframe.removeEntry(currentSession, selection[1]); end, }, level);
	
	elseif level == 2 then
		local value = UIDROPDOWNMENU_MENU_VALUE
		if value == "AWARD_FOR" then
			for k,v in pairs(db.otherAwardReasons) do
				UIDropDownMenu_AddButton({text = v.text, notCheckable = true, func = function() RCLootCouncil_Mainframe.award(v)end, }, level)
			end
		
		elseif value == "CHANGE_RESPONSE" then
			for k,v in pairs(buttonsDB) do
				if k > db.dbToSend.numButtons then break; end
				UIDropDownMenu_AddButton({text = v.response,
					colorCode = "|cff"..string.format("%02x%02x%02x",255*v.color[1], 255*v.color[2], 255*v.color[3]),
					notCheckable = true,
					func = function()
						for x,y in pairs(entryTable[currentSession]) do
							if self:UnitIsUnit(y[1], selection[1]) then 
								entryTable[currentSession][x][5] = k
								RCLootCouncil_Mainframe.Update(true);
								self:SendCommMessage("RCLootCouncil", "change "..self:Serialize({currentSession,x,k}), channel)
								return;
							end
						end
					end,}, level)	
			end

		elseif value == "REANNOUNCE" then
			UIDropDownMenu_AddButton({text = Ambiguate(selection[1], "short"), isTitle = true, notCheckable = true, disabled = true}, level);
			UIDropDownMenu_AddButton({text = "This item", notCheckable = true,
				func = function()
					self:SendCommMessage("RCLootCouncil", "reRoll "..self:Serialize({lootTable[currentSession], currentSession}), "WHISPER", selection[1])
					self:SendCommMessage("RCLootCouncil", "remove "..currentSession.." "..selection[1], channel)
					RCLootCouncil_Mainframe.removeEntry(currentSession, selection[1])
				end,
			}, level);

			UIDropDownMenu_AddButton({text = "All items", notCheckable = true,
				func = function()
					local name = selection[1] -- store it
					self:SendCommMessage("RCLootCouncil", "lootTable "..self:Serialize(lootTable), "WHISPER", name)
					for i = 1, #entryTable do
						self:SendCommMessage("RCLootCouncil", "remove "..i.." "..name, channel)
						RCLootCouncil_Mainframe.removeEntry(i, name)
					end
				end,
			}, level);
			UIDropDownMenu_AddButton({text = "", notCheckable = true, disabled = true}, level);
			UIDropDownMenu_AddButton({text = "All items to ...", value = "REANNOUNCE_TO", notCheckable = true, hasArrow = true,}, level);
		end

	elseif level == 3 then
		if GetNumGroupMembers() > 0 then
			for i = 1, GetNumGroupMembers() do
				local name = GetRaidRosterInfo(i)
				UIDropDownMenu_AddButton({text = Ambiguate(name, "short"), notCheckable = true,
				func = function()
					self:SendCommMessage("RCLootCouncil", "lootTable "..self:Serialize(lootTable), "WHISPER", name)
					for i = 1, #entryTable do
						self:SendCommMessage("RCLootCouncil", "remove "..i.." "..name, channel)
					end
				end,}, level);
			end
		else -- we're alone
			UIDropDownMenu_AddButton({text = playerName, notCheckable = true,
				func = function()
					self:SendCommMessage("RCLootCouncil", "lootTable "..self:Serialize(lootTable), "WHISPER", playerFullName)
					for i = 1, #entryTable do
						RCLootCouncil_Mainframe.removeEntry(i, playerFullName)
					end
				end,}, level);
		end
	end
end

-------------- AutoAward --------------------
function RCLootCouncil:AutoAward(index, awardTo, itemLink)
	self:debugS("AutoAward("..tostring(index)..", "..tostring(awardTo)..")")
	if self:UnitIsUnit("player", awardTo) then -- just take it
		local _, item, lootQuantity = GetLootSlotInfo(index)
		LootSlot(index)
		self:debug(""..awardTo.." was Auto Awarded with "..item);
		self:Print(itemLink.." was Auto Awarded to "..awardTo..". Reason: "..db.otherAwardReasons[db.autoAwardReason].text)
		
		local instanceName, _, _, difficultyName = GetInstanceInfo()
		local table;
		if db.otherAwardReasons[db.autoAwardReason].log then -- only log if the reasoning allows it
			self:debug("table is being created!")
			table = {["lootWon"] = itemLink, ["date"] = date("%d/%m/%y"), ["time"] = date("%H:%M:%S"), ["instance"] = instanceName.." "..difficultyName, ["boss"] = bossName, ["votes"] = nil, ["itemReplaced1"] = nil, ["itemReplaced2"] = nil, ["response"] = db.otherAwardReasons[db.autoAwardReason].text, ["responseID"] = 0,}			
		end

		-- The ML sends the history, if he wants others to be able to track it.
		if db.sendHistory and table then
			self:debug("send history")
			self:SendCommMessage("RCLootCouncil", "award "..awardTo.." "..self:Serialize(table), channel)
		end

		-- Only store the data if the user wants to
		if db.trackAwards and table then 
			self:debug("we're in the logging!")
			if lootDB[awardTo] then -- if the name is already registered in the table
				tinsert(lootDB[awardTo], table)
			else -- if it isn't
				lootDB[awardTo] = {table};
			end
		end
		return;
	end
	for i = 1, GetNumGroupMembers() do
		if self:UnitIsUnit(GetMasterLootCandidate(index, i), awardTo) then
			local _, item, lootQuantity = GetLootSlotInfo(index)
			if lootQuantity > 0 then -- be certain there's an item
				GiveMasterLoot(index, i); -- give the item
				self:debug(""..awardTo.." was Auto Awarded with "..item);
				self:Print(itemLink.." was Auto Awarded to "..awardTo..", Reason: "..db.otherAwardReasons[db.autoAwardReason].text)
			else
				self:Print("Couldn't award the loot since there was no item!")
				return;
			end				
			
			local instanceName, _, _, difficultyName = GetInstanceInfo()
			local table;
			if db.otherAwardReasons[db.autoAwardReason].log then -- only log if the reasoning allows it
				table = {["lootWon"] = itemLink, ["date"] = date("%d/%m/%y"), ["time"] = date("%H:%M:%S"), ["instance"] = instanceName.." "..difficultyName, ["boss"] = bossName, ["votes"] = nil, ["itemReplaced1"] = nil, ["itemReplaced2"] = nil, ["response"] = db.otherAwardReasons[db.autoAwardReason].text, ["responseID"] = 0,}
			end

			-- The ML sends the history, if he wants others to be able to track it.
			if db.sendHistory and table then
				self:SendCommMessage("RCLootCouncil", "award "..awardTo.." "..self:Serialize(table), channel)
			end

			-- Only store the data if the user wants to
			if db.trackAwards and table then 
				if lootDB[awardTo] then -- if the name is already registered in the table
					tinsert(lootDB[awardTo], table)
				else -- if it isn't
					lootDB[awardTo] = {table};
				end
			end
			return;
		end	
	end
end

function RCLootCouncil:GetPlayerFullName()
	if playerFullName then return playerFullName end
	local name, realm = UnitFullName("player")
	return name.."-"..realm
end

-- Blizz UnitIsUnit() doesn't know how to compare unit-realm with unit
-- Seems unit-realm just isn't a valid "unitid"
function RCLootCouncil:UnitIsUnit(unit1, unit2)
	if not unit1 or not unit2 then return nil; end
	-- Remove realm names, if any
	if strfind(unit1, "-", nil, true) ~= nil then
		unit1 = Ambiguate(unit1, "short")
	end
	if strfind(unit2, "-", nil, true) ~= nil then
		unit2 = Ambiguate(unit2, "short")
	end
	return UnitIsUnit(unit1, unit2)
end
