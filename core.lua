--[[	RCLootCouncil core.lua		by Potdisc 

	Contains core elements of the addon
	
	
--------------------------------
TODO
	Things marked with "--TODO"
		- ML shouldn't use self.council - it's meant to store the council sent from the ML! All additions to council goes straight to db.council.
			Edit: ML has no need at all for self.council?
		- Altclicking should produce a list of items that should be confirmed before session start. This allows to distribute loot from bags.
			EDIT: Should always produce a list (unless autoStart is true). The player can then choose what he wants to do, or add more loot.
			EDIT2: sessionFrame
		- autoOpen in defaults - used to toggle if rc should autoopen the voting frame. /rc open if not.
		- The whole "observe" thing is handled by votingframe.lua, and is allowed if mldb.observe
		- Make sure all variables store interchangeable data to allow for fully cross realm/language support i.e UnitFullName, Unlocalized - only change stuff on display
		- Check if modules can be implemented smarter by getting OnModuleCreated event from Ace or something else.
		- Consider if we really need 2 comms - it could fit in 1.
	
--------------------------------
CHANGELOG (WIP)
	==== 2.0 Beta
	
	*Changed Test mode behavior  
	*Added status on roll sendouts (not announced, init, offline etc).
	TODO *Added Autopass feature. 
	*Added module support.
		All non-core functions and visual elements is now modules.
	*Added Obeserve mode.
	TODO *Added "Session Setup".
	*Added ability to temporary disable the addon.
	*Using LibDialog-1.0 to avoid UI taint.
	*Updated Options menu (more options and better descriptions).
  	Bugfixes:

]]

RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceHook-3.0", "AceTimer-3.0");
local LibDialog = LibStub("LibDialog-1.0")

RCLootCouncil:SetDefaultModuleState(false)

local db, historyDB, debugLog
local testItems = {105473,105407,105513,105465,105482,104631,105450,105537,104554,105509,104412,105499,104476,104544,104495,105568,105594,105514,105479,104532,105639,104508,105621,}
-- init modules
local defaultModules = {
		masterlooter =	"RCLootCouncilML",
		lootframe =		"RCLootFrame",
		history =		"RCLootHistory",
		version =		"RCVersionCheck",
		rank =			"RCRankChooser",
		sessionFrame =	"RCSessionFrame",
		votingFrame =	"RCVotingFrame",
}
local userModules = {
		masterlooter = nil,
		lootframe = nil,
		history = nil,
		version = nil,	
		rank = nil,
		sessionFrame = nil,
		votingFrame = nil,
}

function RCLootCouncil:OnInitialize()
	--TODO Consider if we want everything on self, or just whatever modules could need. 
	-- just init testItems now for zzzzz. Needs better implementation
	for k,v in ipairs(testItems) do
		GetItemInfo(v)
	end
    self.version = GetAddOnMetadata("RCLC", "Version")
	self.nnp = true
	self.debug = true
	self.tVersion = "Alpha.1" -- String or nil. Indicates test version, which alters stuff like version check. Is appended to 'version', i.e. "version-tVersion"
	
	local name, realm = UnitFullName("player")
	self.playerName = name.."-"..realm
	self.playerClass = select(2, UnitClass("player"))
	self.guildRank = ""
	self.target = nil
	self.isMasterLooter = false -- Are we the ML?
	self.masterLooter = ""  -- Name of the ML
	self.isCouncil = false -- Are we in the Council?
	--self.active = false	-- Session in process (set by ML) EDIT: Aren't we using ml.running for this?
	self.disabled = false -- turn addon on/off
	self.handleLooting = false -- Should we handle the looting? (e.g. Activated)

	self.unregisterGuildEvent = false
	self.verCheckDisplayed = false -- Have we shown a "out-of-date"?

	self.council = {} -- council from ML
	self.mldb = { v = nil,} -- db recived from ML (v = version of the db)
	self.lootTable = {} -- table of sessions sent from ML containing items and candidate data - used for visuals
	--[[self.lootTable[session] = {
			bagged, lootSlot, announced, awarded, name, link, lvl, type, subType, equipLoc, texture
		
			[playerName] = { 
				rank, role, totalIlvl, response(=i), gear1, gear2, votes, class, haveVoted, voters[], note 	
		}	]]

	self.responses = {
		NOTANNOUNCED	= { color = {1,1,1,1},			sort = 501,		text = "Not announced",},
		ANNOUNCED		= { color = {1,1,1,1},			sort = 502,		text = "Loot announced, waiting for answer", },
		NOTHING			= { color = {0,0,0,1},			sort = 503,		text = "Offline or RCLootCouncil not installed", },
		WAIT			= { color = {0,0,0,1},			sort = 504,		text = "Candidate is selecting response, please wait", },
		TIMEOUT			= { color = {0,0,0,1},			sort = 505,		text = "Candidate didn't respond on time", },
		AUTOPASS		= { color = {0.7,0.7,0.7,1},	sort = 1000,	text = "Autopass", },
		--[[1]]			  { color = {0, 1, 0,1},		sort = 1,		text = "Mainspec/Need",},
		--[[2]]			  { color = {1, 0.5, 0,1},		sort = 2,		text = "Offspec/Greed",	},
		--[[3]]			  { color = {0, 0.7, 0.7,1},	sort = 3,		text = "Minor Upgrade",},
		--[[4]]			  { color = {0.7, 0.7,0.7,1},	sort = 999,		text = "Pass",},
		--[[5]]			  { color = {0.75,0.75,0.75,1},	sort = 4,		text = "Button5",},
		--[[6]]			  { color = {0.75,0.75,0.75,1},	sort = 5,		text = "Button6",},
		--[[7]]			  { color = {0.75,0.75,0.75,1},	sort = 6,		text = "Button7",},
		--[[8]]			  { color = {0.75,0.75,0.75,1},	sort = 7,		text = "Button8",},
	}
	self.roleTable = {
		TANK =		"Tank",
		HEALER =	"Healer",
		DAMAGER =	"DPS",
		NONE =		"None",
	}
	
	self.testMode = false; -- tentative?
	self.soloMode = false;

	-- Option table defaults
	self.defaults = {
		factionrealm = {
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
			autoStart = false, -- the old autoLooting e.g. just start a session with all eligible items
			autolootEverything = true,
			autolootBoE = false,
			altClickLooting = true,
			acceptWhispers = true,
			acceptRaidChat = true,
			advancedOptions = false,
			selfVote = true,
			multiVote = true,
			anonymousVoting = false,
			showForML = false,
			allowNotes = true,
			autoAward = false,
			autoAwardLowerThreshold = 2,
			autoAwardUpperThreshold = 3,
			autoAwardTo = "None",
			autoAwardReason = 1,
			observe = false, -- observe mode on/off
			autoOpen = true, -- auto open the voting frame
			autoEnable = true,

			UI = { -- stores all ui information
				['*'] = { -- Defaults for Lib-Window
					y		= 0,
					x		= 0,
					point	= "CENTER",
					scale	= 1,
				},			
			}, 

			announceAward = true,
			awardText = { -- Just max it at 2 channels
				{ channel = "RAID",	text = "&p was awarded with &i!",},
				{ channel = "NONE",	text = "",},
			},
			announceItems = false,
			announceText = "Items under consideration:",
			announceChannel = "RAID",

			responses = self.responses,

			enableHistory = false,
			sendHistory = true,

			filterPasses = false,

			minRank = -1,
			council = {},
			
			maxButtons = 8,
			numButtons = 4,
			passButton = 4,
			buttons = {
				-- 1
				{	text = "Need",	whisperKey = "need, mainspec, ms, 1", },
				-- 2
				{	text = "Greed",	whisperKey = "greed, offspec, os, 2",},
				-- 3
				{	text = "Minor Upgrade",	whisperKey = "minorupgrade, minor, 3",},
				-- 4
				{	text = "Pass",	whisperKey = "pass, 4",	},
			},
			maxAwardReasons = 8, 
			numAwardReasons = 3,
			awardReasons = {
				{ color = {0, 0, 0, 1}, log = true,	sort = 401,	text = "Disenchant", },
				{ color = {0, 0, 0, 1}, log = true,	sort = 402,	text = "Banking", },
				{ color = {0, 0, 0, 1}, log = false,sort = 403,	text = "Free",}, 
			},
		},
	} -- defaults end
	
	-- create the other buttons/responses
	for i = 5, self.defaults.profile.maxButtons do
		tinsert(self.defaults.profile.buttons, i, {
			text = "Button "..i,
			whisperKey = ""..i,
		})
		--tinsert(self.defaults.profile.responses, i) TODO
	end
	-- create the other AwardReasons
	for i = 4, self.defaults.profile.maxAwardReasons do
		tinsert(self.defaults.profile.awardReasons, i, {color = {0, 0, 0, 1}, log = true, sort = 400+i, text = "Reason "..i,})
	end

	-- register chat and comms
	self:RegisterChatCommand("rc", "ChatCommand")
    self:RegisterChatCommand("rclc", "ChatCommand")
	self:RegisterComm("RCLootCouncil")
	self.db = LibStub("AceDB-3.0"):New("RCLootCouncilDB", self.defaults, true)
	self.lootDB = LibStub("AceDB-3.0"):New("RCLootCouncilLootDB")
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	
	-- add shortcuts
	db = self.db.profile
	historyDB = self.lootDB[factionrealm]
	debugLog = self.db.global.log

	-- register the optionstable
	self.options = self:OptionsTable()
	self.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("RCLootCouncil", self.options)
	
	-- add it to blizz options
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RCLootCouncil", "RCLootCouncil")
end



function RCLootCouncil:OnEnable()
	-- register events
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", "OnEvent")
	self:RegisterEvent("GUILD_ROSTER_UPDATE","OnEvent")
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED","OnEvent")
	self:RegisterEvent("RAID_INSTANCE_WELCOME","OnEvent")

	if IsInGuild() then
		-- TODO
		--self:SendCommMessage("RCLootCouncil", "verTest "..version, "GUILD") -- send out a version check
	end
	self.db.global.version = self.version;
	self.db.global.logMaxEntries = self.defaults.global.logMaxEntries -- reset it now for zzz

	if self.tVersion then
		self.db.global.logMaxEntries = 1000 -- bump it for test version
	elseif self.db.global.tVersion then -- recently ran a test version, so reset debugLog
		debugLog = {}
	end

	self.db.global.tVersion = self.tVersion;
	GuildRoster();
	
	local filterFunc = function(_, event, msg, player, ...)
		return strfind(msg, "[[RCLootCouncil]]:")
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterFunc)

	----------PopUp setups --------------
	-------------------------------------	
	LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_USAGE", {
		text = "Do you want to use RCLootCouncil for this raid?",
		buttons = {
			{	text = "Yes",
				on_click = function(self) --TODO Lot of remaking here
					local lootMethod, _, MLRaidID = GetLootMethod()
					if lootMethod ~= "master" then
						RCLootCouncil:Print("Changing LootMethod to Master Looting")
						SetLootMethod("master", RCLootCouncil.playerName) -- activate ML						
					end
					if db.autoAward and GetLootThreshold() > db.autoAwardQualityLower then
						RCLootCouncil:Print("Changing loot threshold to enable Auto Awarding.")
						SetLootThreshold(db.autoAwardQualityLower)
					end
					RCLootCouncil:Print(" now handles looting.")
					RCLootCouncil.use = true
					RCLootCouncil.isMasterLooter = true
					RCLootCouncil.masterLooter = RCLootCouncil.playerName
					if #db.council < 1 then -- if there's no council
						RCLootCouncil:Print("You haven't set a council! You can choose a minimum rank here and/or change it through the options menu.")
						RCLootCouncil:CallModule("rank") -- show the rankframe
					end
				end,
			},
			{	text = "No",
				on_click = function(self)
					RCLootCouncil.use = false;
					RCLootcouncil:Print(" is not active in this raid.")
				end,
			},
		},
		hide_on_escape = true,
		show_while_dead = true,	
	})
end

function RCLootCouncil:OnDisable()
	--TODO (not really needed as we probably never call .Disable() on the addon)
		-- delete all windows
		-- disable modules(?)
	self:UnregisterAllEvents()
end

function RCLootCouncil:RefreshConfig()
	db = self.db.profile
	if self.isMasterLooter then	RCLootCouncilML:NewML() end		
end

function RCLootCouncil:ChatCommand(msg)
	local input, arg1, arg2 = self:GetArgs(msg,3)
	-- Some commands (cadd, deletecouncil, hide, etc) should probably be removed
	if not input or input:trim() == "" or input == "help" then
		if self.tVersion then print("RCLootCouncil version "..self.version.."-"..self.tVersion)
		else print("RCLootCouncil version "..self.version) end
		self:Print("- config - Open the options frame")
		self:Debug("- debug or d - Toggle debugging")
		self:Print("- show - Shows the main loot frame")
		self:Print("- hide - Hides the main loot frame")
		self:Print("- council - displays the current council")
		self:Print("- councilAdd (name) or cAdd - adds a new member to the loot council")
		self:Print("- remove (name) - removes a player from the loot council")
		self:Print("- deleteEntireCouncil - deletes the entire council")
		self:Print("- test (#)  - emulate a loot session (add a number for raid test)")
		self:Print("- version - open the Version Checker (alt. 'v' or 'ver')")
		self:Print("- history - open the Loot History")
		self:Print("- whisper - displays help to whisper commands")
		self:Print("- reset - resets the addon's frames' positions")
		self:Debug("- log - display the debug log")
		self:Debug("- clearLog - clear the debug log")

	elseif input == 'config' then
		--InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		LibStub("AceConfigDialog-3.0"):Open("RCLootCouncil")

    elseif input == 'debug' or input == 'd' then
		self.debug = not self.debug
		self:Print("Debug = "..tostring(self.debug))

	elseif input == 'show' then
		if not IsInRaid() or self.isCouncil or self.isMasterLooter or self.nnp then -- only the right people may see the window during a raid since they otherwise could watch the entire voting
			RCLootCouncil:ShowVotingFrame()
		else
			self:Print("You are not allowed to see the Voting Frame right now.")
		end

	elseif input == 'hide' then
		RCLootCouncil:HideMainFrame()
	
	elseif input == 'council' then
		if self.council then
			self:Print("Current Council:")
			for k,v in ipairs(self.Council) do print(k,v) end
		elseif db.council then
			self:Print("Council: ")
			for _,t in ipairs(db.council) do print(t) end
		else
			self:Print("No council exists")
		end

	elseif input == 'counciladd' or input == 'cadd' then
		if arg1 then
			tinsert(db.council, arg1)
			self:Print(""..arg1.." was added to the council!")
		else
			self:Print("Please provide a playername.")
		end

	elseif input == 'remove' then
		if arg1 and db.council then
			for k,v in ipairs(db.council) do
				if self:UnitIsUnit(v,arg1) then
					tremove(db.council, k)
					self:Print(""..arg1.." was removed from the council.")
				end
			end
			self:Print(arg1.." isn't a council member.")
		else
			self:Print("Please provide a playername.")
		end
			
	elseif input == 'deleteentirecouncil' then
		db.council = {}
		self:Print("Council wiped")

	elseif input == 'test' then
		--self:Print(db.ui.versionCheckScale)
		self:Test(tonumber(arg1) or 1)

	--elseif input == "add" and self.nnp then
		
	elseif input == 'version' or input == "v" or input == "ver" then
		self:CallModule("version")

	elseif input == "history" or input == "h" or input == "his" then
		self:CallModule("history")

	elseif input == "nnp" then
		self.nnp = not self.nnp
		self:Print("nnp = "..tostring(self.nnp))

	elseif input == "whisper" then
		self:Print("Players can whisper (or through Raidchat if enabled) their current item(s) followed by a keyword to the Master Looter if they doesn't have the addon installed.\nThe keyword list is found under the 'Buttons and Responses' optiontab.\nPlayers can whisper 'rchelp' to the Master Looter to retrieve this list.\nNOTE: People should still get the addon installed, otherwise all player information won't be available.")
    
	elseif input == "reset" then
		--TODO something with this
		--[[
		if RCLootFrame then
			RCLootFrame:ClearAllPoints()
			RCLootFrame:SetPoint("CENTER", 0, -200)
		end
		if MainFrame then
			MainFrame:ClearAllPoints()
			MainFrame:SetPoint("CENTER", 0, 200)
		end
		if RCVersionFrame then
			RCVersionFrame:ClearAllPoints()
			RCVersionFrame:SetPoint("CENTER", -400, 0)
		end
		if RCLootHistoryFrame then
			RCLootHistoryFrame:ClearAllPoints()
			RCLootHistoryFrame:SetPoint("CENTER", -400, 0)		
		end	
	  --]]

	elseif input == "debuglog" or input == "log" then
		for k,v in ipairs(debugLog) do print(k,v); end

	elseif input == "clearlog" then
		wipe(debugLog)
		self:Print("Debug Log cleared.")

	elseif input == 't' and self.nnp then -- Tester cmd
		self:CallModule("votingFrame")

	else
		-- TODO unsure if this works
		self:ChatCommand("help")
	end	
end



function RCLootCouncil:SendCommand(target, command, ...)
	if self.soloMode then return; end -- don't send commands in solo mode
	-- send all data as a table, and let receiver unpack it
	local toSend = self:Serialize(command, {...})
	
	if target == "raid" then
		self:SendCommMessage("RCLootCouncil_ML", toSend, "RAID")
	else
		if self:UnitIsUnit(target,"player") then
			RCLootCouncilML:OnCommReceived("RCLootCouncil_ML", toSend, "WHISPER", target)
		else
			self:SendCommMessage("RCLootCouncil_ML", toSend, "WHISPER", target)
		end
	end	
end


function RCLootCouncil:OnCommReceived(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncil" then
		self:Debug("Comm received: "..serializedMsg..", from: "..sender)
		-- data is always a table to be unpacked
		local test, command, data = self:Deserialize(serializedMsg)
	
		if test then
			if command == "lootTable" then
				if self:UnitIsUnit(sender,self.masterLooter) then 
					self.lootTable = {} -- clear it
					self.lootTable = data[1]
					self:SendCommand(sender, "lootAck") -- send ack
					
					-- TODO Autopass on items

					-- Show  the LootFrame
					self:CallModule("lootframe")
					self:GetActiveModule("lootframe"):Start(self.lootTable)

					-- show the voting frame to the right people
					if (self.isCouncil or self.mldb.observe) and not self.isMasterLooter then 
						self:CallModule("votingFrame")
						self:GetActiveModule("votingFrame"):Setup(self.lootTable)
					end	

				else -- a non-ML send a lootTable?!
					self:Debug(tostring(sender).." is not ML, but sent lootTable!")
				end
			
			elseif command == "council" and not self.isMasterLooter then -- only ML sends council
				self.council = data[1]
				self.isCouncil = self:IsCouncil()

			elseif command == "MLdb" and not self.isMasterLooter then
				self.mldb = data[1]
				
			elseif command == "MLdb_check" and not self.isMasterLooter then -- ML wants to know if you need a new mlDB
				local current_version = data[1]
				if not self.mldb.v or self.mldb.v ~= current_version then
					self:SendCommand(sender, "MLdb_request")
				end

			elseif command == "verTest" then
				local otherVersion, tVersion = unpack(data)
				self:SendCommand(sender, "verTestReply", self.playerName, self.playerClass, self.guildRank, self.version, self.tVersion)
				if self.version < otherVersion and not self.verCheckDisplayed and (not (tVersion or self.tVersion)) then
					self:Print("Your version "..self.version.." is outdated. Newer version is "..otherVersion..", please update RCLootCouncil.")
					self.verCheckDisplayed = true
				end
				
			elseif command == "verTestReply" then
				local _,_,_, otherVersion, tVersion = unpack(data)
				if self.version < otherVersion and not self.verCheckDisplayed and (not (tVersion or self.tVersion)) then
					self:Print("Your version "..self.version.." is outdated. Newer version is "..otherVersion..", please update RCLootCouncil.")
					self.verCheckDisplayed = true
				end

			elseif command == "history" and db.enableHistory then
				local name, history = unpack(data)
				if lootDB[name] then
					tinsert(lootDB[name], history)
				else
					lootDB[name] = {history}
				end	
			
			elseif command == "reRoll" then
				RCLootCouncil_LootFrame:Update(nil, {unpack(data)})
			
		
			elseif command == "playerInfoRequest" then
				local role = self:TranslateRole(self:GetCandidateRole(self.playerName))
				self:SendCommand(sender, "playerInfo", self.playerName, self.playerClass, role, self.guildRank)	
		
			elseif command == "message" then
				self:Print(unpack(data))	
		
			else
				self:Debug("Bad command - ".. command)
			end
		else
			self:Debug("Error in deserializing comm: "..tostring(command));
		end
	end
end


function RCLootCouncil:Debug(msg)
	if self.debug then
		self:Print("debug: "..tostring(msg))
	end
	RCLootCouncil:DebugLog(msg)
end

function RCLootCouncil:DebugLog(msg)
	local time = date("%X", time())
	msg = time.." - ".. msg
	if #debugLog > self.db.global.logMaxEntries then
		tremove(debugLog, 1)
	end
	tinsert(debugLog, msg)
end

function RCLootCouncil:Test(num)	
	local items = {};
	-- pick "num" random items 
	for i = 1, num do
		if i > #testItems then break; end
		local j = math.random(1, #testItems)
		tinsert(items, testItems[j])
	end

	self:Print(tostring(items[1]))

	self.testMode = true;
	self.isMasterLooter, self.masterLooter = self:GetML()

	-- We must be in a group and not the ML
	if not self.isMasterLooter then
		self:Print("You cannot initiate a test while in a group without being the MasterLooter.")
		self.testMode = false
		return
	end

	-- Call ML module and let it handle the rest
	self:CallModule("masterlooter")
	self:GetActiveModule("masterlooter"):Test(items)
end

--[[
	Used by getCurrentGear to determine slot types
	Inspired by EPGPLootMaster
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

function RCLootCouncil:GetPlayersGearFromItemName(itemName)
	self:DebugLog("GetPlayersGearFromItemName("..tostring(itemName)..")")
	local itemID = self:GetItemID(itemName)
	if not itemID then return nil, nil; end
	-- Extract from RCTokenTable
	if RCTokenTable[itemID] then
		return GetInventoryItemLink("player", GetInventorySlotInfo(RCTokenTable[itemID])), nil
	end
	local thisItemEquipLoc = select(9, GetItemInfo(itemID))
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

function RCLootCouncil:GetPlayersGuildRank()
	self:DebugLog("GetPlayersGuildRank()")
	if IsInGuild() then
		local rank = select(2, GetGuildInfo("player"))
		if rank then 
			self:Debug("Found Guild Rank: "..rank)
			self.UnregisterGuildEvent = true;
			return rank;
		else
			GuildRoster() -- let the event trigger this func
			return "Not Found";
		end
	else
		return "Unguilded?";
	end
end 

function RCLootCouncil:GetCandidateRole(candidate)
	return UnitGroupRolesAssigned(candidate)
end

function RCLootCouncil:TranslateRole(role)
	return self.roleTable[role]
end

function RCLootCouncil:GetGuildRankNum(name)
	self:DebugLog("GetGuildRankNum("..tostring(name)..")")
	GuildRoster()
	for i = 1, GetNumGuildMembers(true) do
		local n, rank, rankIndex = GetGuildRosterInfo(i)
		if n == name then
			return rankIndex, rank;
		end
	end
	return 100; -- fallback
end

-- TODO might not be needed, or not valid
function RCLootCouncil:GetLowestItemLevel(item1, item2)
	self:DebugLog("GetLowestItemLevel(...)")
	local ilvl1, ilvl2
	ilvl1 = select(4, GetItemInfo(item1))
	if item2 then
		ilvl2 = select(4, GetItemInfo(item2))
	else return ilvl1; end
	if ilvl1 < ilvl2 then return ilvl1; else return ilvl2; end
end	

-- Returns boolean, mlName. (true if the player is ML), (nil if there's no ML) 
function RCLootCouncil:GetML()
	self:DebugLog("GetML()")
	if (self.testMode and GetNumGroupMembers() == 0) or self.nnp then -- always the player when testing alone
		return true, self.playerName
	end
	local lootMethod, _, MLRaidID = GetLootMethod()
	if lootMethod == "master" then
		local name = GetRaidRosterInfo(MLRaidID)
		self:Debug("MasterLooter = "..name)
		return self:UnitIsUnit(name,"player"), name
	end
	return false, nil;
end

function RCLootCouncil:IsCouncil(name)
	self:Debug("IsCouncil("..name..")")
	if self.isMasterLooter or self.nnp then return true; end -- ML and nnp is always council
	return tContains(self.council, name)
end

function RCLootCouncil:GetNumberOfDaysFromNow(date)
	local d, m, y = strsplit("/", date, 3)
	local newTime = time()
	local oldTime = time({ year = "20"..y, month = m, day = d})
	local days = math.floor((newTime - oldTime) / 3600 / 24) -- convert to days and round down
	return days % 30, math.floor(days / 30) % 12, math.floor(days / 12)
end

function RCLootCouncil:ConvertDateToString(day, month, year)
	local text = day.." days"
	if year > 0 then
		text = text ..", ".. month .." months and ".. year .." years."
	elseif month > 0 then
		text = text .." and ".. month .." months."
	else
		text = text.."."
	end
	return text;
end

function RCLootCouncil:OnEvent(this, event, ...)
	if event == "PARTY_LOOT_METHOD_CHANGED" then
		self:NewMLCheck()

	elseif event == "RAID_INSTANCE_WELCOME" then
		self:NewMLCheck()

	elseif event == "GUILD_ROSTER_UPDATE" then
		self.guildRank = RCLootCouncil:GetPlayersGuildRank();
		if self.unregisterGuildEvent then
			self:UnregisterEvent("GUILD_ROSTER_UPDATE"); -- we don't need it any more
			RCLootCouncil:GetGuildOptions() -- get the guild data to the options table now that it's ready
		end
	elseif event == "GET_ITEM_INFO_RECEIVED" then	
		
	end
end

function RCLootCouncil:NewMLCheck()
	local old_ml = self.masterLooter
	self.isMasterLooter, self.masterLooter = self:GetML()
		
	if self:UnitIsUnit(old_ml,self.masterLooter) then return; end -- no change
	
	if self.isMasterLooter and db.autoEnable then -- addon should auto start
		self:Print(" is now handling looting.")
		if db.autoAward and GetLootThreshold() > db.autoAwardQualityLower then
			RCLootCouncil:Print("Changing loot threshold to enable Auto Awarding.")
			SetLootThreshold(db.autoAwardQualityLower)
		end
			
	elseif self.isMasterLooter and not db.autoEnable then -- addon should not auto start, but ask if it should start since we're ML
		LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")
			
	elseif not self.isMasterLooter and UnitIsGroupLeader("player") then -- lootMethod ~= ML, but we are group leader
		if db.autoEnable then -- the addon should auto start, so change loot method to master, and make the player ML
			SetLootMethod("master", self.playerName)
			self:Print(" you are now the Master Looter and RCLootCouncil is now handling looting.")
			if db.autoAward and GetLootThreshold() > db.autoAwardQualityLower then
				RCLootCouncil:Print("Changing loot threshold to enable Auto Awarding.")
				SetLootThreshold(db.autoAwardQualityLower)
			end
			self.isMasterLooter = true
			self.masterLooter = self.playerName
		else
			LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE") -- ask if we want to use the addon since we're group leader
		end
			
	end
	
	self:CallModule("masterlooter")
	self:GetActiveModule("masterlooter"):NewML(self.masterlooter)
end		

function RCLootCouncil:SessionError(...)
	self:Print("Something went wrong - please restart the session")
	self:Debug(...)
end

function RCLootCouncil:Getdb()
	return db
end

-- Blizz UnitIsUnit() doesn't know how to compare unit-realm with unit
-- Seems to be because of unit-realm isn't a valid unitid
function RCLootCouncil:UnitIsUnit(unit1, unit2)
	if not unit1 or not unit2 then return; end
	-- Remove realm names, if any
	if strfind(unit1, "-", nil, true) ~= nil then
		unit1 = Ambiguate(unit1, "short")
	end
	if strfind(unit2, "-", nil, true) ~= nil then
		unit2 = Ambiguate(unit2, "short")
	end
	return UnitIsUnit(unit1, unit2)
end

---------------------------------------------------------------------------
-- Custom module support funcs
---------------------------------------------------------------------------

-- Enables a userModule if set, defaultModule otherwise
-- @param module String, must correspond to a index in self.defaultModules
function RCLootCouncil:CallModule(module)
	if self.disabled then return end -- Don't call modules unless enabled

	if userModules[module] then -- someone else have added a module
		self:EnableModule(userModules[module])
	else -- use default module
		self:EnableModule(defaultModules[module])
	end	
end

-- Returns a active module
-- @param module String, must correspond to a index in self.defaultModules
-- @return The active module or nil
function RCLootCouncil:GetActiveModule(module)
	return self:GetModule(userModules[module] or defaultModules[module], true)
end

--#end Module support -----------------------------------------------------


---------------------------------------------------------------------------
-- UI Functions used throughout the addon
---------------------------------------------------------------------------

-- Returns a scaler above the window's title
-- Assumes @param frame is registered to LibWindow-1.1
function RCLootCouncil:GetScaler(frame)
	self:Print("GetScaler")
	local AG = LibStub("AceGUI-3.0")
	local libwin = LibStub("LibWindow-1.1")
	local scaler = AG:Create("Slider")
	scaler:SetValue(frame:GetScale())
	scaler:SetWidth(frame.title:GetWidth()*frame:GetScale())
	scaler:SetPoint("BOTTOM", frame.title, "TOP")
	scaler:SetSliderValues(0.5, 1.5, 0.01)
	scaler:SetIsPercent(true)
	scaler:SetLabel("Drag to scale")
	local mouseUp = false
	scaler:SetCallback("OnMouseUp", function()
		mouseUp = true
		scaler:ClearAllPoints()
		scaler:SetPoint("BOTTOM", frame.title, "TOP")
		self:Print("mouseUp")
	end)	
	scaler:SetCallback("OnValueChanged", function(i,j,v)
		scaler:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", scaler.frame:GetLeft(), scaler.frame:GetBottom()) -- make sure it doesn't move
		libwin.SetScale(frame,v)
	end)
   return scaler
end

-- Adds a standard titleframe to f
function RCLootCouncil:CreateTitleFrame(f, title, width)
	local tf = CreateFrame("Frame", nil, f)
	tf:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
    tf:SetBackdropColor(0,0,0,0.7)
	tf:SetBackdropBorderColor(0,0.595,0.87,1)
    tf:SetHeight(22)
    tf:EnableMouse()
    tf:SetMovable(true)
	tf:SetWidth(width)
    tf:SetPoint("CENTER",f,"TOP",0,-1)
    tf:SetScript("OnMouseDown", function() f:StartMoving() end)
    tf:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

    local text = tf:CreateFontString(nil,"OVERLAY","GameFontNormal")
    text:SetPoint("CENTER",tf,"CENTER")
	text:SetTextColor(1,1,1,1)
    text:SetText(title)
	tf.text = text
	return tf
end

-- Used as a "DoCellUpdate" function for lib-st
function RCLootCouncil:SetCellClassIcon(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local rowdata = table:GetRow(realrow);
	local celldata = table:GetCell(rowdata, column);
	local class = celldata.args[1]
	if class then
		frame:SetNormalTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"); -- this is the image containing all class icons
		local coords = CLASS_ICON_TCOORDS[class]; -- get the coordinates of the class icon we want
		frame:GetNormalTexture():SetTexCoord(unpack(coords)); -- cut out the region with our class icon according to coords
	else -- if there's no class 
		frame:SetNormalTexture("Interface/ICONS/INV_Sigil_Thorim.png")
	end	
end

-- Returns a color table for use with lib-st
function RCLootCouncil:GetClassColor(class)
	local color = RAID_CLASS_COLORS[class]
	if not color then
		-- if class not found, return epic color.
		return {["r"] = 0.63921568627451, ["g"] = 0.2078431372549, ["b"] = 0.93333333333333, ["a"] = 1.0 };
	else
		color.a = 1.0
		return color
	end
end

-- Creates a standard frame for RCLootCouncil
-- @param name Global name of the frame
-- @param cName Name of the module (used for lib-window-1.1 config as db.UI[cName])
-- @param height Height of the frame, defaults to 325
-- @return The frame object
function RCLootCouncil:CreateFrame(name, cName, height)
	local f = CreateFrame("Frame", name, UIParent)
	f:Hide()
	f:SetFrameStrata("DIALOG")
	f:EnableMouse(true)
	f:SetWidth(450)
	f:SetHeight(height or 325)
	f:SetToplevel(true)
	f:SetBackdrop({
        --bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 64, edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
    --f:SetBackdropColor(0.5,0,0,1)
	f:SetBackdropColor(0,0.003,0.21,1)
    f:SetBackdropBorderColor(0.3,0.3,0.5,1)
	LibStub("LibWindow-1.1"):Embed(f)
	f:RegisterConfig(db.UI[cName])
	f:RestorePosition() -- might need to move this to after whereever GetFrame() is called
	f:MakeDraggable()
	f:SetScript("OnMouseWheel", function(f,delta) if IsControlKeyDown() then LibStub("LibWindow-1.1").OnMouseWheel(f,delta) end end)
	return f
end

-- Creates a standard button for RCLootCouncil
-- @param text The button's text
-- @param parent The frame that should hold the button
-- @return The button object
function RCLootCouncil:CreateButton(text, parent)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetText(text)
	b:SetSize(100,25)
	return b
end

-- Displays a tooltip anchored to the mouse
-- @param lines A table containing the lines to add
-- @hyperlink Will set the tooltip as hyperlink if not nil
function RCLootCouncil:CreateTooltip(lines, hyperlink)
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	if hyperlink then 
		GameTooltip:SetHyperlink(hyperlink)
	else
		for k,v in ipairs(lines) do
			GameTooltip:AddLine(v,1,1,1)
		end
	end
	GameTooltip:Show()
end

-- Hide the tooltip created with :CreateTooltip()
function RCLootCouncil:HideTooltip()
	GameTooltip:Hide()
end

-- Removes any realm name from name
-- @param name Name to remove realmname from
-- @return The name without realmname
function RCLootCouncil:Ambiguate(name)
	return Ambiguate(name, "short")
end

--#end UI Functions -----------------------------------------------------

-- debug func
function printtable(table)
	for k,v in pairs(table) do
		addon:Print("["..k.."] = ")
		if type(v) ~= "table" then 
			addon:Print(v)
		else
			printtable(v)
		end
	end
 end