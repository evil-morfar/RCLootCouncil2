--[[	RCLootCouncil core.lua		by Potdisc

	Contains core elements of the addon


--------------------------------
TODO
	Things marked with "TODO"
		- If we truly want to be able to edit votingframe scrolltable with modules, it needs to have GetRow, GetCol by name
		- autoOpen in defaults - used to toggle if rc should autoopen the voting frame. /rc open if not.
		- Make sure all variables store interchangeable data to allow for fully cross realm/language support i.e UnitFullName, Unlocalized - only change stuff on display
		- Check if modules can be implemented smarter by getting OnModuleCreated event from Ace or something else.
		- The whole "loot from bags" thing (Check if we can make some alt-clicking in bags, and maybe an "add item" command)
		- "Disenchant option when everyone passes"
		- "more info" thingie
		- Revise DB variables
		- lootHistory
		- Save class on award later
		- Need to make a SetCouncilByGuildRank()
--------------------------------
CHANGELOG (WIP)
	-- MOVED TO CHANGELOG.TXT

	*Changed Test mode behavior -- really?
	*Added Obeserve mode. -- FIXME Missing in options!

  	Bugfixes:
			Various taint fixes.

]]

RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceHook-3.0", "AceTimer-3.0");
local LibDialog = LibStub("LibDialog-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local lwin = LibStub("LibWindow-1.1")

RCLootCouncil:SetDefaultModuleState(false)

-- Init shorthands
local db, historyDB, debugLog;-- = self.db.profile, self.lootDB.factionrealm, self.db.global.log
local testItems = {105473,105407,105513,105465,105482,104631,105450,105537,104554,105509,104412,105499,104476,104544,104495,105568,105594,105514,105479,104532,105639,104508,105621,}
-- init modules
local defaultModules = {
		masterlooter =	"RCLootCouncilML",
		lootframe =		"RCLootFrame",
		history =		"RCLootHistory",
		version =		"RCVersionCheck",
		rank =			"RCRankChooser",
		sessionframe =	"RCSessionFrame",
		votingframe =	"RCVotingFrame",
}
local userModules = {
		masterlooter = nil,
		lootframe = nil,
		history = nil,
		version = nil,
		rank = nil,
		sessionframe = nil,
		votingframe = nil,
}

local usage = false -- We want to use the addon for this raid
local frames = {} -- Contains Minimize() and IsMinimized() for all frames

function RCLootCouncil:OnInitialize()
	--IDEA Consider if we want everything on self, or just whatever modules could need.
	-- just init testItems now for zzzzz. Needs better implementation
	for k,v in ipairs(testItems) do
		GetItemInfo(v)
	end
  self.version = GetAddOnMetadata("RCLootCouncil2", "Version")
	self.nnp = true
	self.debug = true
	self.tVersion = "Alpha.1" -- String or nil. Indicates test version, which alters stuff like version check. Is appended to 'version', i.e. "version-tVersion"

	self.playerClass = select(2, UnitClass("player"))
	self.guildRank = L["Unguilded"]
	self.target = nil
	self.isMasterLooter = false -- Are we the ML?
	self.masterLooter = ""  -- Name of the ML
	self.isCouncil = false -- Are we in the Council?
	--self.active = false	-- Session in process (set by ML) EDIT: Aren't we using ml.running for this?
	self.enabled = true -- turn addon on/off
	self.handleLooting = false -- Should we handle the looting? (e.g. Activated)
	self.inCombat = false -- Are we in combat?

	self.unregisterGuildEvent = false
	self.verCheckDisplayed = false -- Have we shown a "out-of-date"?

	self.council = {} -- council from ML
	self.mldb = { v = nil,} -- db recived from ML (v = version of the db)
	self.lootTable = {} -- table of sessions sent from ML containing items and candidate data - used for visuals
	--[[self.lootTable[session] = {
			bagged, lootSlot, announced, awarded, name, link, lvl, type, subType, equipLoc, texture

			candidates[name] = {
				rank, role, totalIlvl, diff, response(=i), gear1, gear2, votes, class, haveVoted, voters[], note
		}	]]

	self.responses = {
		NOTANNOUNCED	= { color = {1,0,1,1},				sort = 501,		text = L["Not announced"],},
		ANNOUNCED		= { color = {1,0,1,1},				sort = 502,		text = L["Loot announced, waiting for answer"], },
		WAIT				= { color = {1,1,0,1},				sort = 503,		text = L["Candidate is selecting response, please wait"], },
		NOTHING			= { color = {0.5,0.5,0.5,1},		sort = 504,		text = L["Offline or RCLootCouncil not installed"], },
		TIMEOUT			= { color = {1,0,0,1},				sort = 505,		text = L["Candidate didn't respond on time"], },
		REMOVED			= { color = {0.8,0.5,0,1},			sort = 506,		text = L["Candidate removed"], },
		PASS				= { color = {0.7, 0.7,0.7,1},		sort = 999,		text = L["Pass"],},
		AUTOPASS			= { color = {0.7,0.7,0.7,1},		sort = 1000,	text = L["Autopass"], },
		--[[1]]			  { color = {0,1,0,1},				sort = 1,		text = L["Mainspec/Need"],},
		--[[2]]			  { color = {1,0.5,0,1},			sort = 2,		text = L["Offspec/Greed"],	},
		--[[3]]			  { color = {0,0.7,0.7,1},			sort = 3,		text = L["Minor Upgrade"],},
		--[[4]]			  { color = {0.7, 0.7,0.7,1},		sort = 5,		text = L["Pass"],},
		--[[5]]			  { color = {0.75,0.75,0.75,1},	sort = 4,		text = L["Button"]..5,},
		--[[6]]			  { color = {0.75,0.75,0.75,1},	sort = 5,		text = L["Button"]..6,},
		--[[7]]			  { color = {0.75,0.75,0.75,1},	sort = 6,		text = L["Button"]..7,},
		--[[8]]			  { color = {0.75,0.75,0.75,1},	sort = 7,		text = L["Button"]..8,},
	}
	self.roleTable = {
		TANK =		L["Tank"],
		HEALER =		L["Healer"],
		DAMAGER =	L["DPS"],
		NONE =		L["None"],
	}

	self.testMode = false; -- tentative?
	self.soloMode = false;

	-- Option table defaults
	self.defaults = {
		global = {
			logMaxEntries = 300,
			log = {}, -- debug log
			localizedSubTypes = {},
		},
		profile = {
			autoStart = false, -- the old autoLooting e.g. just start a session with all eligible items
			autolootEverything = true,
			autolootBoE = true,
			altClickLooting = true,
			acceptWhispers = true,
			--acceptRaidChat = true,
			--advancedOptions = true, -- Redundant?
			selfVote = true,
			multiVote = true,
			anonymousVoting = false,
			showForML = false,
			hideVotes = false, -- Hide the # votes until one have voted
			allowNotes = true,
			autoAward = false,
			autoAwardLowerThreshold = 2,
			autoAwardUpperThreshold = 3,
			autoAwardTo = L["None"],
			autoAwardReason = 1,
			observe = false, -- observe mode on/off
			autoOpen = true, -- auto open the voting frame
			autoEnable = false, -- Skip "Use for this raid?" message
			autoPass = true,
			silentAutoPass = false, -- Show autopass message
			autoPassBoE = true,
			neverML = false, -- Never use the addon as ML
			minimizeInCombat = false,

			UI = { -- stores all ui information
				['*'] = { -- Defaults for Lib-Window
					y		= 0,
					x		= 0,
					point	= "CENTER",
					scale	= 0.8,
				},
			},

			modules = { -- For storing module specific data
				['*'] = {},
			},

			announceAward = true,
			awardText = { -- Just max it at 2 channels
				{ channel = "RAID",	text = L["&p was awarded with &i!"],},
				{ channel = "NONE",	text = "",},
			},
			announceItems = false,
			announceText = L["Items under consideration:"],
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
				{	text = L["Need"],					whisperKey = L["need, mainspec, ms, 1"], },	-- 1
				{	text = L["Greed"],				whisperKey = L["greed, offspec, os, 2"],},		-- 2
				{	text = L["Minor Upgrade"],whisperKey = L["minorupgrade, minor, 3"],},	-- 3
				{	text = L["Pass"],					whisperKey = L["pass, 4"],	},					-- 4
			},
			maxAwardReasons = 8,
			numAwardReasons = 3,
			awardReasons = {
				{ color = {1, 1, 1, 1}, log = true,	sort = 401,	text = L["Disenchant"], },
				{ color = {1, 1, 1, 1}, log = true,	sort = 402,	text = L["Banking"], },
				{ color = {1, 1, 1, 1}, log = false,sort = 403,	text = L["Free"],},
			},

			-- List of items to ignore:
			ignore = {
				109693, -- Draenic Dust
				115502, -- Small Luminous Shard
				111245, -- Luminous Shard
				115504, -- Fractured Temporal Crystal
				113588, -- Temporal Crystal
			},
		},
	} -- defaults end

	-- create the other buttons/responses
	for i = 5, self.defaults.profile.maxButtons do
		tinsert(self.defaults.profile.buttons, i, {
			text = L["Button"].." "..i,
			whisperKey = ""..i,
		})
	end
	-- create the other AwardReasons
	for i = 4, self.defaults.profile.maxAwardReasons do
		tinsert(self.defaults.profile.awardReasons, i, {color = {1, 1, 1, 1}, log = true, sort = 400+i, text = "Reason "..i,})
	end

	-- register chat and comms
	self:RegisterChatCommand("rc", "ChatCommand")
  	self:RegisterChatCommand("rclc", "ChatCommand")
	self:RegisterComm("RCLootCouncil")
	self.db = LibStub("AceDB-3.0"):New("RCLootCouncilDB", self.defaults, true)
	self.lootDB = LibStub("AceDB-3.0"):New("RCLootCouncilLootDB")
	--[[ Format:
	"playerName" = {
		[#] = {"lootWon", "date (d/m/y)", "time (h:m:s)", "instance", "boss", "votes", "itemReplaced1", "itemReplaced2", "response", "responseID"}
	},
	]]
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

	-- add shortcuts
	db = self.db.profile
	historyDB = self.lootDB.factionrealm
	debugLog = self.db.global.log

	-- register the optionstable
	self.options = self:OptionsTable()
	self.options.args.settings.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RCLootCouncil", self.options)

	-- add it to blizz options
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RCLootCouncil", "RCLootCouncil", nil, "settings")
	self.optionsFrame.ml = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RCLootCouncil", "Master Looter", "RCLootCouncil", "mlSettings")
end

function RCLootCouncil:OnEnable()
	-- Register the playername
	local name, realm = UnitFullName("player")
	self.playerName = name.."-"..realm

	-- register events
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", "OnEvent")
	self:RegisterEvent("GUILD_ROSTER_UPDATE","OnEvent")
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED","OnEvent")
	self:RegisterEvent("RAID_INSTANCE_WELCOME","OnEvent")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "EnterCombat")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "LeaveCombat")

	if IsInGuild() then
		-- TODO
		--self:SendCommMessage("RCLootCouncil", "verTest "..version, "GUILD") -- send out a version check
	end
	self.db.global.version = self.version;
	self.db.global.logMaxEntries = self.defaults.global.logMaxEntries -- reset it now for zzz

	if self.tVersion then
		self.db.global.logMaxEntries = 1000 -- bump it for test version
	end
	if self.db.global.tVersion and self.debug then -- recently ran a test version, so reset debugLog
		self.db.global.log = {}
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
		text = L["Do you want to use RCLootCouncil for this raid?"],
		buttons = {
			{	text = L["Yes"],
				on_click = function(self) --TODO Lot of remaking here
					usage = true
					local lootMethod, _, MLRaidID = GetLootMethod()
					if lootMethod ~= "master" then
						RCLootCouncil:Print(L["Changing LootMethod to Master Looting"])
						SetLootMethod("master", RCLootCouncil.playerName) -- activate ML
					end
					if db.autoAward and GetLootThreshold() > db.autoAwardQualityLower then
						RCLootCouncil:Print(L["Changing loot threshold to enable Auto Awarding"])
						SetLootThreshold(db.autoAwardQualityLower)
					end
					RCLootCouncil:Print(L[" now handles looting"])
					RCLootCouncil.isMasterLooter = true
					RCLootCouncil.masterLooter = RCLootCouncil.playerName
					if #db.council < 1 then -- if there's no council
						RCLootCouncil:Print(L["You haven't set a council! You can choose a minimum rank here and/or change it through the options menu."])
						RCLootCouncil:CallModule("rank") -- show the rankframe
					end
				end,
			},
			{	text = L["No"],
				on_click = function(self)
					usage = false;
					RCLootCouncil:Print(L[" is not active in this raid."])
				end,
			},
		},
		hide_on_escape = true,
		show_while_dead = true,
	})
end

function RCLootCouncil:OnDisable()
	self:Debug("OnDisable()")
	--NOTE (not really needed as we probably never call .Disable() on the addon)
		-- delete all windows
		-- disable modules(?)
	self:UnregisterAllEvents()
end

function RCLootCouncil:RefreshConfig()
	self:Debug("RefreshConfig")
	db = self.defaults.profile
end

function RCLootCouncil:ConfigTableChanged(val)
	--[[ NOTE By default only ml_core needs to know about changes to the config table,
		  but we'll use AceEvent incase future modules also wants to know ]]
	self:SendMessage("RCConfigTableChanged", val)
end

function RCLootCouncil:CouncilChanged()
	self:SendMessage("RCCouncilChanged")
end

function RCLootCouncil:ChatCommand(msg)
	local input, arg1, arg2 = self:GetArgs(msg,3)
	input = strlower(input or "")
	if not input or input:trim() == "" or input == "help" or input == L["help"] then
		if self.tVersion then print(format(L["chat tVersion string"],self.version, self.tVersion))
		else print(format(L["chat version String"],self.version)) end
		self:Print(L["chat_commands"])
		self:Debug(L["- debug or d - Toggle debugging"])
		self:Debug(L["- log - display the debug log"])
		self:Debug(L["- clearLog - clear the debug log"])

	elseif input == 'config' or input == L["config"] then
		-- Call it twice, because reasons..
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		--LibStub("AceConfigDialog-3.0"):Open("RCLootCouncil")

	elseif input == 'debug' or input == 'd' then
		self.debug = not self.debug
		self:Print("Debug = "..tostring(self.debug))

	elseif input == 'open' or input == L["open"] then
		if self.isCouncil or self.mldb.observe or self.nnp then -- only the right people may see the window during a raid since they otherwise could watch the entire voting
			self:GetActiveModule("votingframe"):Show()
		else
			self:Print(L["You are not allowed to see the Voting Frame right now."])
		end

	elseif input == 'council' or input == L["council"] then
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame.ml)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame.ml)
		LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil", "mlSettings", "councilTab")


	elseif input == 'test' or input == L["test"] then
		--self:Print(db.ui.versionCheckScale)
		self:Test(tonumber(arg1) or 1)

	elseif (input == "add" or input == L["add"]) then
		-- TODO Create the "add" command (don't forget chat_commands)

	elseif input == 'version' or input == L["version"] or input == "v" or input == "ver" then
		self:CallModule("version")

	elseif input == "history" or input == L["history"] or input == "h" or input == "his" then
		self:CallModule("history")

	elseif input == "nnp" then
		self.nnp = not self.nnp
		self:Print("nnp = "..tostring(self.nnp))

	elseif input == "whisper" or input == L["whisper"] then
		self:Print(L["whisper_help"])

	elseif input == "neverml" or input == L["neverml"] then
		db.neverML = not db.neverML
		self:Print(L["neverml"].." = "..tostring(db.neverML))

	elseif input == "award" then -- TODO/REVIEW Complete this and test it
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):SessionFromBags()
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end

	elseif input == "winners" then -- REVIEW
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):PrintAwardedInBags()
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end

	elseif input == "reset" or input == L["reset"] then
		--REVIEW Check if works
		for _, v in pairs(self.db.UI) do
			v.y		= 0
			v.x 		= 0
			v.point	= "CENTER"
			v.scale	= 0.8
		end
		self:Print(L["Windows reset"])

	elseif input == "debuglog" or input == "log" then
		for k,v in ipairs(debugLog) do print(k,v); end

	elseif input == "clearlog" then
		wipe(debugLog)
		self:Print("Debug Log cleared.")

	elseif input == 't' and self.nnp then -- Tester cmd
		self:Print(arg1, arg2)

	else
		self:ChatCommand("help")
	end
end

-- Send a Comm Message to a RCLootCouncil client using AceComm-3.0
-- @param target The receiver of the message. Can be "group", "guild" or "playerName".
-- @param command The command to send.
-- @param vararg Any number of arguments to send along. Will be packaged as a table.
function RCLootCouncil:SendCommand(target, command, ...)
	if self.soloMode then return; end -- don't send commands in solo mode
	-- send all data as a table, and let receiver unpack it
	local toSend = self:Serialize(command, {...})

	if target == "group" then
		local num = GetNumGroupMembers()
		if num > 5 then -- Raid
			self:SendCommMessage("RCLootCouncil", toSend, "RAID")
		elseif num > 0 then -- Party
			self:SendCommMessage("RCLootCouncil", toSend, "PARTY")
		else--if self.testMode then -- Alone (testing)
			self:SendCommMessage("RCLootCouncil", toSend, "WHISPER", self.playerName)
		end

	elseif target == "guild" then
		self:SendCommMessage("RCLootCouncil", toSend, "GUILD")

	else
		if self:UnitIsUnit(target,"player") then -- If target == "player"
			self:SendCommMessage("RCLootCouncil", toSend, "WHISPER", self.playerName)
		else
			self:SendCommMessage("RCLootCouncil", toSend, "WHISPER", target)
		end
	end
end

function RCLootCouncil:OnCommReceived(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncil" then
		self:DebugLog("Comm received:", serializedMsg, "from:", sender)
		-- data is always a table to be unpacked
		local test, command, data = self:Deserialize(serializedMsg)

		if test then
			if command == "lootTable" then
				if self:UnitIsUnit(sender, self.masterLooter) then
					self:SendCommand(sender, "lootAck", self.playerName) -- send ack

					local lootTable = unpack(data)
					if db.autoPass then
						for ses, v in ipairs(lootTable) do
							if (v.boe and db.autoPassBoE) or not v.boe then
								if self:AutoPassCheck(v.subType) then
									self:Debug("Autopassed on: "..tostring(v.link))
									if not db.silentAutoPass then self:Print(format(L["Autopassed on %s"], v.link)) end
									self:SendCommand("group", "response", self:CreateResponse(ses, tonumber(strmatch(v.link, "item:(%d+):")), v.ilvl, "AUTOPASS"))
									lootTable[ses].autopass = true
								end
							else
								self:Debug("Didn't autopass on: "..v.link.." because it's BoE!")
							end
						end
					end

					-- Show  the LootFrame
					self:CallModule("lootframe")
					self:GetActiveModule("lootframe"):Start(lootTable)

					-- The votingFrame handles lootTable itself

				else -- a non-ML send a lootTable?!
					self:Debug(tostring(sender).." is not ML, but sent lootTable!")
				end

			elseif command == "council" and self:UnitIsUnit(sender, self.masterLooter) then -- only ML sends council
				self.council = unpack(data)
				self.isCouncil = self:IsCouncil(self.playerName)

				-- prepare the voting frame for the right people
				if self.isCouncil or self.mldb.observe then
					self:CallModule("votingframe")
				end

			elseif command == "MLdb" and not self.isMasterLooter then -- ML sets his own mldb
				self.mldb = unpack(data)

			elseif command == "verTest" then
				local otherVersion, tVersion = unpack(data)
				self:SendCommand(sender, "verTestReply", self.playerName, self.playerClass, self.guildRank, self.version, self.tVersion)
				if self.version < otherVersion and not self.verCheckDisplayed and (not (tVersion or self.tVersion)) then
					self:Print(format(L["version_outdated_msg"], self.version, otherVersion))
					self.verCheckDisplayed = true

				-- tVersion check	REVIEW not sure if the < will work
				elseif tVersion and self.tVersion and self.tVersion < tVersion then
					self:Print(format(L["tVersion_outdated_msg"], tVersion))
					self.verCheckDisplayed = true
				end

			elseif command == "verTestReply" then
				local _,_,_, otherVersion, tVersion = unpack(data)
				if self.version < otherVersion and not self.verCheckDisplayed and (not (tVersion or self.tVersion)) then
					self:Print(format(L["version_outdated_msg"], self.version, otherVersion))
					self.verCheckDisplayed = true

				-- tVersion check	REVIEW not sure if the < will work
				elseif tVersion and self.tVersion and self.tVersion < tVersion then
					self:Print(format(L["tVersion_outdated_msg"], tVersion))
					self.verCheckDisplayed = true
				end

			elseif command == "history" and db.enableHistory then
				local name, history = unpack(data)
				if lootDB[name] then
					tinsert(lootDB[name], history)
				else
					lootDB[name] = {history}
				end

			elseif command == "reroll" and self:UnitIsUnit(sender, self.masterLooter) then
				self:CallModule("lootframe")
				self:GetActiveModule("lootframe"):ReRoll(unpack(data))

			elseif command == "playerInfoRequest" then
				local role = self:GetCandidateRole(self.playerName)
				self:SendCommand(sender, "playerInfo", self.playerName, self.playerClass, role, self.guildRank)

			elseif command == "message" then
				self:Print(unpack(data))

			elseif command == "session_end" then
				self:Print(L["The Master Looter has ended the session"])
				self:GetActiveModule("lootframe"):Disable()
				self:GetActiveModule("votingframe"):EndSession()
			end
		else
			self:Debug("Error in deserializing comm:", tostring(command));
		end
	end
end


function RCLootCouncil:Debug(msg, ...)
	if self.debug then
		if select("#", ...) > 0 then
			self:Print("|cffcb6700debug:|r "..tostring(msg).."|cffff6767", ...)
		else
			self:Print("|cffcb6700debug:|r "..tostring(msg).."|r")
		end
	end
	RCLootCouncil:DebugLog(msg, ...)
end

local date_to_debug_log = true
function RCLootCouncil:DebugLog(msg, ...)
	if date_to_debug_log then tinsert(debugLog, date("%x")); date_to_debug_log = false; end
	local time = date("%X", time())
	msg = time.." - ".. tostring(msg)
	for i = 1, select("#", ...) do msg = msg.." ("..tostring(select(i,...))..")" end
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

	self.testMode = true;
	self.isMasterLooter, self.masterLooter = self:GetML()

	-- We must be in a group and not the ML
	if not self.isMasterLooter then
		self:Print(L["You cannot initiate a test while in a group without being the MasterLooter."])
		self.testMode = false
		return
	end

	-- Call ML module and let it handle the rest
	self:CallModule("masterlooter")
	self:GetActiveModule("masterlooter"):NewML(self.masterLooter)
	self:GetActiveModule("masterlooter"):Test(items)
end

function RCLootCouncil:EnterCombat()
	if not db.minimizeInCombat then return end
	self.inCombat = true
	for _,frame in ipairs(frames) do
		if frame:IsVisible() and not frame:IsMinimized() then -- only minimize for combat if it isn't already minimized
			self:Debug("Minimizing for combat")
			frame.combatMinimized = true -- flag it as being minimized for combat
			frame:Minimize()
		end
	end
end

function RCLootCouncil:LeaveCombat()
	if not db.minimizeInCombat then return end
	self.inCombat = false
	for _,frame in ipairs(frames) do -- REVIEW Test this
		self:Debug("Frame minimized = ", frame:IsMinimized())
		if frame.combatMinimized then -- Reshow it
			self:Debug("Reshowing frame")
			frame.combatMinimized = false
			frame:Minimize()
		end
	end
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

function RCLootCouncil:GetPlayersGearFromItemID(itemID)
	self:DebugLog("GetPlayersGearFromItemID("..tostring(itemID)..")")
	if not itemID then return nil, nil; end
	-- check if the item is a token, and if it is, return the matching current gear
	if RCTokenTable[itemID] then
		if RCTokenTable[itemID] == "Trinket" then -- We need to return both trinkets
			return GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET0SLOT")), GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET1SLOT"))
		end
		return GetInventoryItemLink("player", GetInventorySlotInfo(RCTokenTable[itemID])), nil;
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

function RCLootCouncil:Timer(type, ...)
	self:Debug("Timer "..type.." passed")
	if type == "LocalizeSubTypes" then
		self:LocalizeSubTypes()
	end
end

-- Classes that should auto pass a subtype
local autopassTable = {
	["Cloth"]					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN"},
	["Leather"] 				= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK"},
	["Mail"] 					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST", "MAGE", "WARLOCK"},
	["Plate"]					= {"DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK"},
	["Shields"] 				= {"DEATHKNIGHT", "DRUID", "MONK", "ROGUE", "HUNTER","PRIEST", "MAGE", "WARLOCK"},
	["Bows"] 					= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK"},
	["Crossbows"] 				= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK"},
	["Daggers"]					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "HUNTER", "SHAMAN", },
	["Guns"]						= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK","SHAMAN", "PRIEST", "MAGE", "WARLOCK"},
	["Fist Weapons"] 			= {"DEATHKNIGHT", "PALADIN",  "PRIEST", "MAGE", "WARLOCK"},
	["One-Handed Axes"]		= {"DRUID", "MONK", "ROGUE", "PRIEST", "MAGE", "WARLOCK"},
	["One-Handed Maces"]		= {"MONK", "HUNTER", "MAGE", "WARLOCK"},
	["One-Handed Swords"] 	= {"DRUID", "SHAMAN", "PRIEST",},
	["Polearms"] 				= {"ROGUE", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK"},
	["Staves"]					= {"WARRIOR", "DEATHKNIGHT", "PALADIN",  "ROGUE", "HUNTER"},
	["Two-Handed Axes"]		= {"DRUID", "ROGUE", "MONK", "PRIEST", "MAGE", "WARLOCK"},
	["Two-Handed Maces"]		= {"MONK", "ROGUE", "HUNTER", "PRIEST", "MAGE", "WARLOCK"},
	["Two-Handed Swords"]	= {"DRUID", "MONK", "ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK"},
	["Wands"]					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN"},
}

-- Used to find localized subType names
local subTypeLookup = {
	["Cloth"]					= 124168, -- Felgrease-Smudged Robes
	["Leather"] 				= 124265, -- Leggings of Eternal Terror
	["Mail"] 					= 124291, -- Eredar Fel-Chain Gloves
	["Plate"]					= 124322, -- Treads of the Defiler
	["Shields"] 				= 124354, -- Felforged Aegis
	["Bows"] 					= 128194, -- Snarlwood Recurve Bow
	["Crossbows"] 				= 124362, -- Felcrystal Impaler
	["Daggers"]					= 124367, -- Fang of the Pit
	["Guns"]						= 124370, -- Felfire Munitions Launcher
	["Fist Weapons"] 			= 124368, -- Demonblade Eviscerator
	["One-Handed Axes"]		= 128196, -- Limbcarver Hatchet
	["One-Handed Maces"]		= 124372, -- Gavel of the Eredar
	["One-Handed Swords"] 	= 124387, -- Shadowrend Talonblade
	["Polearms"] 				= 124377, -- Rune Infused Spear
	["Staves"]					= 124382, -- Edict of Argus
	["Two-Handed Axes"]		= 124360, -- Hellrender
	["Two-Handed Maces"]		= 124375, -- Maul of Tyranny
	["Two-Handed Swords"]	= 124389, -- Calamity's Edge
	["Wands"]					= 128096, -- Demonspine Wand
}

-- Create localization for autopass
for _, item in pairs(subTypeLookup) do -- Just call GetItemInfo() and do it in 2 secs
	GetItemInfo(item)
end
RCLootCouncil:ScheduleTimer("Timer", 5, "LocalizeSubTypes")

function RCLootCouncil:AutoPassCheck(type)
	if type and autopassTable[self.db.global.localizedSubTypes[type]] then
		return tContains(autopassTable[self.db.global.localizedSubTypes[type]], self.playerClass)
	end
	return false
end

function RCLootCouncil:LocalizeSubTypes()
	if self.db.global.localizedSubTypes.created then return end -- We only need to create it once
	self.db.global.localizedSubTypes = {} -- reset
	self.db.global.localizedSubTypes.created = true
	for name, item in pairs(subTypeLookup) do
		local sType = select(7, GetItemInfo(item))
		if sType then
			self.db.global.localizedSubTypes[sType] = name
			self:DebugLog("Found "..name.." localized as: "..sType)
		else -- Probably not cached, set a timer
			self:ScheduleTimer("Timer", 2, "LocalizeSubTypes")
			self.db.global.localizedSubTypes.created = false
		end
	end
end

function RCLootCouncil:IsItemBoE(item)
	self:DebugLog("IsItemBoe("..item..")")
	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GameTooltip:SetHyperlink(item)
	if GameTooltip:NumLines() > 1 then -- check that there is something here
		for i = 1, 5 do -- BoE status won't be further away than line 5
			local line = getglobal('GameTooltipTextLeft' .. i)
			if line and line.GetText then
				if line:GetText() == ITEM_BIND_ON_EQUIP then
					GameTooltip:Hide()
					return true
				end
			end
		end
	end
	GameTooltip:Hide()
	return false
end

function RCLootCouncil:CreateResponse(session, itemid, ilvl, response, note)
	self:DebugLog("CreateResponse", session, itemid, ilvl, response,tostring(note))
	local g1, g2 = self:GetPlayersGearFromItemID(itemid)
	local diff = nil
	if g1 then diff = (ilvl - select(4, GetItemInfo(g1))) end
	return {
		session = session,
		name = self.playerName,
		data = {
				gear1 = g1,
				gear2 = g2,
				ilvl = math.floor(select(2,GetAverageItemLevel())),
				diff = diff,
				note = note,
				response = response
		}
	}
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
			return L["Not Found"];
		end
	else
		return L["Unguilded"];
	end
end

function RCLootCouncil:GetCandidateRole(candidate)
	return UnitGroupRolesAssigned(candidate)
end

function RCLootCouncil.TranslateRole(role) -- reasons
	return (role and role ~= "") and RCLootCouncil.roleTable[role] or ""
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

-- REVIEW might not be needed, or not valid
function RCLootCouncil:GetLowestItemLevel(item1, item2)
	self:DebugLog("GetLowestItemLevel(...)")
	local ilvl1, ilvl2
	ilvl1 = select(4, GetItemInfo(item1))
	if item2 then
		ilvl2 = select(4, GetItemInfo(item2))
	else return ilvl1; end
	--if ilvl1 < ilvl2 then return ilvl1; else return ilvl2; end
	-- This should work
	return ilvl1 < ilvl2 and ilvl1 or ilvl2
end

function RCLootCouncil:GetNumberOfDaysFromNow(oldDate)
	local d, m, y = strsplit("/", oldDate, 3)
	local sinceEpoch = time({year = "20"..y, month = m, day = d}) -- convert from string to seconds since epoch
	local diff = date("*t", time() - sinceEpoch) -- get the difference as a table
	-- Convert to number of d/m/y
	return diff.day - 1, diff.month - 1, diff.year - 1970
end

function RCLootCouncil:ConvertDateToString(day, month, year)
	local text = format(L["x days"], day)
	if year > 0 then
		text = format(L["days, x months, y years"], text, month, year)
	elseif month > 0 then
		text = format(L["days and x months"], text, month)
	else
		text = text.."."
	end
	return text;
end

function RCLootCouncil:OnEvent(this, event, ...)
	if event == "PARTY_LOOT_METHOD_CHANGED" then --REVIEW Still not sure this works
		self:Debug("Event:", "PARTY_LOOT_METHOD_CHANGED")
		self:NewMLCheck()

	elseif event == "RAID_INSTANCE_WELCOME" then
		self:Debug("Event:", "RAID_INSTANCE_WELCOME")
		-- high server-side latency causes the UnitIsGroupLeader("player") condition to fail if queried quickly (upon entering instance) regardless of state.
		-- may add a delay for the above conditional if the issue persists to circumvent issue.
		-- NOTE v2.0: Not sure if this is still an issue, but just add a 2 sec timer to the MLCheck call
		self:ScheduleTimer(function() -- REVIEW Check if it can take a function like this
			self:NewMLCheck()
		end, 2)

	elseif event == "GUILD_ROSTER_UPDATE" then
		self:Debug("Event:", "GUILD_ROSTER_UPDATE")
		self.guildRank = self:GetPlayersGuildRank();
		if self.unregisterGuildEvent then
			self:UnregisterEvent("GUILD_ROSTER_UPDATE"); -- we don't need it any more
			self:GetGuildOptions() -- get the guild data to the options table now that it's ready
		end
	elseif event == "GET_ITEM_INFO_RECEIVED" then
			-- REVIEW Not sure we need this
			self:Debug("Event:", "GET_ITEM_INFO_RECEIVED")
	end
end

function RCLootCouncil:NewMLCheck()
	local old_ml = self.masterLooter
	self.isMasterLooter, self.masterLooter = self:GetML()

	if self.isMasterLooter and db.neverML then self:Print(L["neverml_warning"]) end -- neverML logic
	if self:UnitIsUnit(old_ml,self.masterLooter) or db.neverML then return end -- no change
	if not self.isMasterLooter and self.masterLooter then return end -- Someone else is ML

	-- We are ML or could be, lets do stuff
	if self.isMasterLooter and db.autoEnable then -- addon should auto start
		self:Print(L[" now handles looting"])
		if db.autoAward and GetLootThreshold() > db.autoAwardQualityLower then
			RCLootCouncil:Print(L["Changing loot threshold to enable Auto Awarding"])
			SetLootThreshold(db.autoAwardQualityLower)
		end

	elseif self.isMasterLooter and not db.autoEnable then -- addon should not auto start, but ask if it should start since we're ML
		return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")

	elseif not self.isMasterLooter and not self.masterLooter and UnitIsGroupLeader("player") then -- There's no ML, and lootmethod ~= ML, but we are the group leader
		if db.autoEnable then -- the addon should auto start, so change loot method to master, and make the player ML
			SetLootMethod("master", self.playerName)
			self:Print(L[" you are now the Master Looter and RCLootCouncil is now handling looting."])
			if db.autoAward and GetLootThreshold() > db.autoAwardQualityLower then
				RCLootCouncil:Print(L["Changing loot threshold to enable Auto Awarding"])
				SetLootThreshold(db.autoAwardQualityLower)
			end
			self.isMasterLooter = true
			self.masterLooter = self.playerName
		elseif self.enabled then
			return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE") -- ask if we want to use the addon since we're group leader
		end
	end
	-- FIXME Need to handle var usage
	self:CallModule("masterlooter")
	self:GetActiveModule("masterlooter"):NewML(self.masterlooter)
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
	self:DebugLog("IsCouncil("..tostring(name)..")")
	local ret = tContains(self.council, name)
	if self.isMasterLooter or self.nnp then ret = true end -- ML and nnp is always council
	self:DebugLog(ret) -- We want to see it in logs
	return ret
end

function RCLootCouncil:SessionError(...)
	self:Print(L["session_error"])
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

--- Enables a userModule if set, defaultModule otherwise
-- @param module String, must correspond to a index in self.defaultModules
function RCLootCouncil:CallModule(module)
	if not self.enabled then return end -- Don't call modules unless enabled
	self:EnableModule(userModules[module] or defaultModules[module])
end

--- Returns the active module
-- @param module String, must correspond to a index in self.defaultModules
-- @return The module object of the active module or nil if not found. Prioritises userModules if set
function RCLootCouncil:GetActiveModule(module)
	self:Debug("|cff387bac"..module)
	return self:GetModule(userModules[module] or defaultModules[module], false)
end

--- Registers a module that should override a default module
-- The custom module must have all functions that a default module can be called with
-- @param type Index (string) in userModules
-- @param The name passed to AceAddon:NewModule()
function RCLootCouncil:RegisterUserModule(type, name) -- REVIEW Test this
	assert(userModules[type], format("Module %s is not a default module.", tostring(type)))
	userModules[type] = name
end

--#end Module support -----------------------------------------------------


---------------------------------------------------------------------------
-- UI Functions used throughout the addon
---------------------------------------------------------------------------

--- Used as a "DoCellUpdate" function for lib-st
function RCLootCouncil.SetCellClassIcon(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local celldata = data[realrow].cols[column]
	local class = celldata.args[1]
	if class then
		frame:SetNormalTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"); -- this is the image containing all class icons
		local coords = CLASS_ICON_TCOORDS[class]; -- get the coordinates of the class icon we want
		frame:GetNormalTexture():SetTexCoord(unpack(coords)); -- cut out the region with our class icon according to coords
	else -- if there's no class
		frame:SetNormalTexture("Interface/ICONS/INV_Sigil_Thorim.png")
	end
end

--- Returns a color table for use with lib-st
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

function RCLootCouncil:RGBToHex(r,g,b)
	return string.format("%02x%02x%02x",255*r, 255*g, 255*b)
end

--- Creates a standard frame for RCLootCouncil
-- 	Put children into frame.content for minimize support
-- @param name Global name of the frame
-- @param cName Name of the module (used for lib-window-1.1 config as db.UI[cName])
-- @param title The title text
-- @param width The width of the titleframe, defaults to 250
-- @param height Height of the frame, defaults to 325
-- @return The frame object
function RCLootCouncil:CreateFrame(name, cName, title, width, height)
	local f = CreateFrame("Frame", name, nil) -- LibWindow seems to work better with nil parent
	f:Hide()
	f:SetFrameStrata("HIGH")
	f:SetWidth(450)
	f:SetHeight(height or 325)
	lwin:Embed(f)
	f:RegisterConfig(db.UI[cName])
	f:RestorePosition() -- might need to move this to after whereever GetFrame() is called
	f:MakeDraggable()
	f:SetScript("OnMouseWheel", function(f,delta) if IsControlKeyDown() then lwin.OnMouseWheel(f,delta) end end)

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
	tf:SetWidth(width or 250)
	tf:SetPoint("CENTER",f,"TOP",0,-1)
	tf:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
	tf:SetScript("OnMouseUp", function(self) -- Get double click by trapping time betweem mouse up
		local frame = self:GetParent()
		frame:StopMovingOrSizing()
		frame:SavePosition()
		if self.lastClick and GetTime() - self.lastClick <= 0.5 then
			frame:Minimize()
			self.lastClick = nil
		else
			self.lastClick = GetTime()
		end
	end)

	local text = tf:CreateFontString(nil,"OVERLAY","GameFontNormal")
	text:SetPoint("CENTER",tf,"CENTER")
	text:SetTextColor(1,1,1,1)
	text:SetText(title)
	tf.text = text
	f.title = tf

	local c = CreateFrame("Frame", nil, f) -- frame that contains the actual content
	c:SetBackdrop({
	     --bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	     tile = true, tileSize = 64, edgeSize = 12,
	     insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	c:EnableMouse(true)
	c:SetWidth(450)
	c:SetHeight(height or 325)
	c:SetBackdropColor(0,0.003,0.21,1)
	c:SetBackdropBorderColor(0.3,0.3,0.5,1)
	c:SetPoint("TOPLEFT")
	c:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
	c:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing(); self:GetParent():SavePosition() end)
	f.content = c
	f.minimized = false
	f.IsMinimized = function(frame) return frame.minimized end
	f.Minimize = function(frame)
		if frame:IsMinimized() then
		  frame.content:Show()
		else
		  frame.content:Hide()
		end
		frame.minimized = not frame.minimized
	end
	-- Support for auto hide in combat:
	tinsert(frames, f)
	local old_setwidth = f.SetWidth
	f.SetWidth = function(self, width) -- Hack so we only have to set width once
		old_setwidth(self, width)
		self.content:SetWidth(width)
	end
	local old_setheight = f.SetHeight
	f.SetHeight = function(self, height)
		old_setheight(self, width)
		self.content:SetHeight(height)
	end
	local old_show = f.Show
	f.Show = function(self)
		old_show(self)
		self:RestorePosition()
	end
	return f
end

--- Creates a standard button for RCLootCouncil
-- @param text The button's text
-- @param parent The frame that should hold the button
-- @return The button object
function RCLootCouncil:CreateButton(text, parent)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetText(text)
	b:SetSize(100,25)
	return b
end

--- Displays a tooltip anchored to the mouse
-- @param ... Lines to be added.
function RCLootCouncil:CreateTooltip(...)
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	for i = 1, select("#", ...) do
		GameTooltip:AddLine(select(i, ...),1,1,1)
	end
	GameTooltip:Show()
end

--- Displays a hyperlink tooltip
-- @param link The link to display
function RCLootCouncil:CreateHypertip(link)
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	GameTooltip:SetHyperlink(link)
end

-- Hide the tooltip created with :CreateTooltip()
function RCLootCouncil:HideTooltip()
	GameTooltip:Hide()
end

--- Removes any realm name from name
-- @param name Name to remove realmname from
-- @return The name without realmname
function RCLootCouncil.Ambiguate(name)
	return Ambiguate(name, "short")
end

--- Returns the text of a button, returning settings from mldb, or default buttons
-- @param i The button's index
function RCLootCouncil:GetButtonText(i)
	return self.mldb.buttons[i] and self.mldb.buttons[i].text or db.buttons[i].text
end

--- The following functions returns the text, sort or color of a response, returning a result from mldb if possible, otherwise the default responses.
-- @param response Index in self.responses
function RCLootCouncil:GetResponseText(response)
	return self.mldb.responses[response] and self.mldb.responses[response].text or self.responses[response].text
end

function RCLootCouncil:GetResponseColor(response)
	-- We have to convert indicies for lib-st -.-'
	local r,g,b,a
	if self.mldb.responses[response] then
		r,g,b,a = unpack(self.mldb.responses[response].color)
	else
		r,g,b,a = unpack(self.responses[response].color)
	end
	return {["r"]=r,["g"]=g,["b"]=b,["a"]=a}
end

function RCLootCouncil:GetResponseSort(response)
	return self.mldb.responses[response] and self.mldb.responses[response].sort or self.responses[response].sort
end

--#end UI Functions -----------------------------------------------------
--@debug@
-- debug func
function printtable( data, level )
	level = level or 0
	local ident=strrep('     ', level)
	if level>6 then return end
	if type(data)~='table' then print(tostring(data)) end;
	for index,value in pairs(data) do repeat
		if type(value)~='table' then
			print( ident .. '['..index..'] = ' .. tostring(value) .. ' (' .. type(value) .. ')' );
			break;
		end
		print( ident .. '['..index..'] = {')
        printtable(value, level+1)
        print( ident .. '}' );
	until true end
end
--@end-debug@
