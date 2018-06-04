--- 	core.lua	Contains core elements of the addon
-- @author Potdisc

--[[ TODOs/Notes
	Things marked with "todo"
		- Emulate award stuff - i.e. log awards without awarding
		- IDEA Change popups so they only hide on award/probably add the error message to it.
		- TODO/IDEA Change chat_commands to seperate lines in order to have a table of printable cmds.

	Backwards compability breaks:
		- Remove equipLoc, subType, texture from lootTable. They can all be created with GetItemInfoInstant()
		- Remove name from lootTable. This isn't needed at all.
-------------------------------- ]]

--[[CHANGELOG
	-- SEE CHANGELOG.TXT]]

--[[AceEvent-3.0 Messages:
	core:
		RCCouncilChanged		-	fires when the council changes.
		RCConfigTableChanged	-	fires when the user changes a settings. args: [val]; a few settings supplies their name.
		RCUpdateDB				-	fires when the user receives sync data from another player.
	ml_core:
		RCMLAddItem				- 	fires when an item is added to the loot table. args: item, loottable entry
		RCMLAwardSuccess		- 	fires when an item is successfully awarded. args: session, winner, status.
		RCMLAwardFailed		-	fires when an item is unsuccessfully awarded. args: session, winner, status.
		RCMLBuildMLdb       -   fires just before the MLdb is built. arg: MLdb, the master looter db table.
		RCMLLootHistorySend	- 	fires just before loot history is sent out. args: loot_history table (the table sent to users), all arguments from ML:TrackAndLogLoot()
	votingFrame:
		RCSessionChangedPre	-	fires when the user changes the session, just before SwitchSession() is executed. args: sesion.
		RCSessionChangedPost	-	fires when the user changes the session, after SwitchSession() is executed. args: session.
	lootHistory:
		RCHistory_ResponseEdit - fires when the user edits the response of a history entry. args: data (see LootHistory:BuildData())
		RCHistory_NameEdit	-	fires when the user edits the receiver of a history entry. args: data.
]]
--@debug@
--if LibDebug then LibDebug() end
--@end-debug@

-- GLOBALS: GetLootMethod, GetAddOnMetadata, UnitClass

_G.RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceHook-3.0", "AceTimer-3.0");
local LibDialog = LibStub("LibDialog-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local lwin = LibStub("LibWindow-1.1")
local tooltipForParsing = CreateFrame("GameTooltip", "RCLootCouncil_Tooltip_Parse", nil, "GameTooltipTemplate")
tooltipForParsing:UnregisterAllEvents() -- Don't use GameTooltip for parsing, because GameTooltip can be hooked by other addons.

RCLootCouncil:SetDefaultModuleState(false)

-- Init shorthands
local db, historyDB, debugLog;-- = self.db.profile, self.lootDB.factionrealm, self.db.global.log
-- init modules
local defaultModules = {
	masterlooter =	"RCLootCouncilML",
	lootframe =		"RCLootFrame",
	history =		"RCLootHistory",
	version =		"RCVersionCheck",
	sessionframe =	"RCSessionFrame",
	votingframe =	"RCVotingFrame",
	tradeui =		"RCTradeUI",
}
local userModules = {
	masterlooter = nil,
	lootframe = nil,
	history = nil,
	version = nil,
	sessionframe = nil,
	votingframe = nil,
	tradeui = nil,
}

local frames = {} -- Contains all frames created by RCLootCouncil:CreateFrame()
local unregisterGuildEvent = false
local player_relogged = true -- Determines if we potentially need data from the ML due to /rl
local lootTable = {}

local IsPartyLFG = IsPartyLFG
-- Lua
local time, date, tonumber, unpack, select, wipe, pairs, ipairs, format, table, tinsert, tremove, bit, tostring, type
	 = time, date, tonumber, unpack, select, wipe, pairs, ipairs, format, table, tinsert, tremove, bit, tostring, type

local playersData = {-- Update on login/encounter starts. it stores the information of the player at that moment.
	gears = {}, -- Gears key: slot number(1-19), value: item link
	relics = {}, -- Relics key: slot number(1-3), value: item link
} -- player's data that can be changed by the player (spec, equipped ilvl, gaers, relics etc)

function RCLootCouncil:OnInitialize()
	--IDEA Consider if we want everything on self, or just whatever modules could need.
  	self.version = GetAddOnMetadata("RCLootCouncil", "Version")
	self.nnp = false
	self.debug = false
	self.tVersion = "Alpha-1" -- String or nil. Indicates test version, which alters stuff like version check. Is appended to 'version', i.e. "version-tVersion" (max 10 letters for stupid security)

	self.playerClass = select(2, UnitClass("player"))
	self.guildRank = L["Unguilded"]
	self.isMasterLooter = false -- Are we the ML?
	self.masterLooter = ""  -- Name of the ML
	self.lootMethod = GetLootMethod() or "personalloot"
	self.handleLoot = false -- Does RC handle loot(Start session from loot window)?
	self.isCouncil = false -- Are we in the Council?
	self.enabled = true -- turn addon on/off
	self.inCombat = false -- Are we in combat?
	self.recentReconnectRequest = false
	self.currentInstanceName = ""
	self.bossName = nil -- Updates after each encounter
	self.recentTradableItem = nil -- The last tradeable item not below the loot threshold the player gets since the last encounter ends
	self.lootOpen = false 	-- is the ML lootWindow open or closed?
	self.lootSlotInfo = {}  -- Items' data currently in the loot slot. Need this because inside LOOT_SLOT_CLEARED handler, GetLootSlotLink() returns invalid link.

	self.verCheckDisplayed = false -- Have we shown a "out-of-date"?
	self.moduleVerCheckDisplayed = {} -- Have we shown a "out-of-date" for a module? The key of the table is the baseName of the module.

	self.EJLastestInstanceID = 946 -- UPDATE this whenever we change test data.
									-- The lastest raid instance Enouncter Journal id.
									-- Antorus, the Burning Throne.
									-- HOWTO get this number: Open the instance we want in the Adventure Journal. Use command '/dump EJ_GetInstanceInfo()'
									-- The 8th return value is sth like "|cff66bbff|Hjournal:0:946:14|h[Antorus, the Burning Throne]|h|r"
									-- The number at the position of the above 946 is what we want.
	self.candidates = {}
	self.council = {} -- council from ML
	self.mldb = {} -- db recived from ML
	self.responses = {
		AWARDED        = { color = {1,1,1,1},				sort = 0.1,		text = L["Awarded"],},
		NOTANNOUNCED	= { color = {1,0,1,1},				sort = 501,		text = L["Not announced"],},
		ANNOUNCED		= { color = {1,0,1,1},				sort = 502,		text = L["Loot announced, waiting for answer"], },
		WAIT				= { color = {1,1,0,1},				sort = 503,		text = L["Candidate is selecting response, please wait"], },
		TIMEOUT			= { color = {1,0,0,1},				sort = 504,		text = L["Candidate didn't respond on time"], },
		REMOVED			= { color = {0.8,0.5,0,1},			sort = 505,		text = L["Candidate removed"], },
		NOTHING			= { color = {0.5,0.5,0.5,1},		sort = 505,		text = L["Offline or RCLootCouncil not installed"], },
		PASS				= { color = {0.7, 0.7,0.7,1},		sort = 800,		text = _G.PASS,},
		AUTOPASS			= { color = {0.7,0.7,0.7,1},		sort = 801,		text = L["Autopass"], },
		DISABLED			= { color = {0.3,0.35,0.5,1},		sort = 802,		text = L["Candidate has disabled RCLootCouncil"], },
		NOTINRAID		= { color = {0.7,0.6,0,1}, 		sort = 803, 	text = L["Candidate is not in the instance"]},
		DEFAULT			= { color = {1,0,0,1},				sort = 899, 	text = L["Response isn't available. Please upgrade RCLootCouncil."]},
		--[[1]]			  { color = {0,1,0,1},				sort = 1,		text = L["Mainspec/Need"],},
		--[[2]]			  { color = {1,0.5,0,1},			sort = 2,		text = L["Offspec/Greed"],	},
		--[[3]]			  { color = {0,0.7,0.7,1},			sort = 3,		text = L["Minor Upgrade"],},
		tier = {
			--[[1]]		  { color = {0.1,1,0.5,1},			sort = 1,		text = L["4th Tier Piece"],},
			--[[2]]		  { color = {1,1,0.5,1},			sort = 2,		text = L["2nd Tier Piece"],},
			--[[3]]		  { color = {1,0.5,1,1},			sort = 3,		text = L["Tier Piece that doesn't complete a set"],},
			--[[4]]		  { color = {0.5,1,1,1},			sort = 4,		text = L["Upgrade to existing tier/random upgrade"],},
		},
		relic = {}, -- Created further down
	}
	self.chatCmdHelp = {
		{cmd = "config",	desc = L["chat_commands_config"]},
		{cmd = "council", desc = L["chat_commands_council"]},
		{cmd = "history", desc = L["chat_commands_history"]},
		{cmd = "version", desc = L["chat_commands_version"]},
		{cmd = "open", desc = L["chat_commands_open"]},
		{cmd = "reset", desc = L["chat_commands_reset"]},
		{cmd = "test (#)", desc = L["chat_commands_test"]},
		{cmd = "whisper", desc = L["chat_commands_whisper"]},
		{cmd = "add [item]", desc = L["chat_commands_add"]},
		{cmd = "award", desc = L["chat_commands_award"]},
		{cmd = "winners", desc = L["chat_commands_winners"]},
		{cmd = "sync", desc = L["chat_commands_sync"]},
	}

	self.testMode = false;

	-- Option table defaults
	self.defaults = {
		global = {
			logMaxEntries = 2000,
			log = {}, -- debug log
			verTestCandidates = {}, -- Stores received verTests
		},
		profile = {

			baggedItems = {}, -- Items that are stored in MLs inventory for award later.
								-- i = { {link=link, winner=winner, addedTime=sec between UTC epoch to when the item is added to lootInBags, }, bop=Item is BOP?}
			itemStorage = {}, -- See ItemStorage.lua

			usage = { -- State of enabledness
				ml = false,				-- Enable when ML
				ask_ml = true,			-- Ask before enabling when ML
				leader = false,		-- Enable when leader
				ask_leader = true,	-- Ask before enabling when leader
				never = false,			-- Never enable
				state = "ask_ml", 	-- Current state
			},
			onlyUseInRaids = true,
			ambiguate = false, -- Append realm names to players
			autoAddRolls = false,
			autoStart = false, -- start a session with all eligible items
			autoLoot = true, -- Auto loot equippable items
			autolootEverything = true,
			autolootBoE = true,
			autolootOthersBoE = false, -- Auto add BoE looted by others to the session frame
			autoOpen = true, -- auto open the voting frame
			autoClose = false, -- Auto close voting frame on session end
			autoPassBoE = true,
			autoPass = true,
			autoPassTrinket = true,
			altClickLooting = true,
			acceptWhispers = true,
			selfVote = true,
			multiVote = true,
			anonymousVoting = false,
			showForML = false,
			hideVotes = false, -- Hide the # votes until one have voted
			allowNotes = true,
			autoAward = false,
			autoAwardLowerThreshold = 2,
			autoAwardUpperThreshold = 3,
			autoAwardTo = _G.NONE,
			autoAwardReason = 1,
			observe = false, -- observe mode on/off
			silentAutoPass = false, -- Show autopass message
			printResponse = false, -- Print response in chat
			--neverML = false, -- Never use the addon as ML
			minimizeInCombat = false,
			iLvlDecimal = false,
			showSpecIcon = false,
			sortItems = true, -- Sort sessions by item type and item level

			UI = { -- stores all ui information
				['**'] = { -- Defaults
					y		= 0,
					x		= 0,
					point	= "CENTER",
					scale	= 1.1,--0.8,
					bgColor = {0, 0, 0.2, 1},
					borderColor = {0.3, 0.3, 0.5, 1},
					border = "Blizzard Tooltip",
					background = "Blizzard Tooltip",
				},
				lootframe = { -- We want the Loot Frame to get a little lower
					y = -200,
				},
				tradeui = {
					x = -300,
				},
				default = {}, -- base line
			},

			skins = {
				new_blue = {
					name = "Midnight blue",
					bgColor = {0, 0, 0.2, 1}, -- Blue-ish
					borderColor = {0.3, 0.3, 0.5, 1}, -- More Blue-ish
					border = "Blizzard Tooltip",
					background = "Blizzard Tooltip",
				},
				old_red = {
					name = "Old golden red",
					bgColor = {0.5, 0, 0 ,1},
					borderColor = {1, 0.5, 0, 1},
					border = "Blizzard Tooltip",
					background = "Blizzard Dialog Background Gold",
				},
				minimalGrey = {
					name = "Minimal Grey",
					bgColor = {0.25, 0.25, 0.25, 1},
					borderColor = {1, 1, 1, 0.2},
					border = "Blizzard Tooltip",
					background = "Blizzard Tooltip",
				},
				legion = {
					name = "Legion Green",
					bgColor = {0.1, 1, 0, 1},
					borderColor = {0, 0.8, 0, 0.75},
					background = "Blizzard Garrison Background 2",
					border = "Blizzard Dialog Gold",
				},
			},
			currentSkin = "new_blue",

			modules = { -- For storing module specific data
				['*'] = {
					filters = { -- Default filtering is showed
						['*'] = true,
						tier = { -- New section in v2.4.0
							['*'] = true,
						},
						relic = { -- v2.7
							['*'] = true
						},
						ranks = {
							['*'] = true
						},
					},
					alwaysShowTooltip = false,
				},
			},

			announceAward = true,
			awardText = { -- Just max it at 2 channels
				{ channel = "group",	text = L["&p was awarded with &i for &r!"],},
				{ channel = "NONE",	text = "",},
			},
			announceItems = false,
			announceText = L["Items under consideration:"],
			announceChannel = "group",
			announceItemString = "&s: &i", -- The message posted for each item, default: "session: itemlink"

			responses = self.responses,

			enableHistory = true,
			sendHistory = true,

			minRank = -1,
			council = {},

			maxButtons = 10,
			numButtons = 3,
			buttons = {
				{	text = _G.NEED,					whisperKey = L["whisperKey_need"], },	-- 1
				{	text = _G.GREED,				whisperKey = L["whisperKey_greed"],},	-- 2
				{	text = L["Minor Upgrade"],		whisperKey = L["whisperKey_minor"],},	-- 3
			},
			tierButtonsEnabled = true,
			tierNumButtons = 4,
			tierButtons = {
				{	text = L["4 Piece"],					whisperKey = "1, 4tier, 4piece"},		-- 1
				{	text = L["2 Piece"],					whisperKey = "2, 2tier, 2piece"},		-- 2
				{	text = L["Other piece"],			whisperKey = "3, other, tier, piece"}, -- 3
				{	text = _G.UPGRADE,					whisperKey = "4, upgrade, up"},			-- 4
			},
			relicButtonsEnabled = false,
			relicNumButtons = 2,
			relicButtons = {}, -- Created below
			numMoreInfoButtons = 1,
			maxAwardReasons = 10,
			numAwardReasons = 3,
			awardReasons = {
				{ color = {1, 1, 1, 1}, disenchant = true, log = true,	sort = 401,	text = _G.ROLL_DISENCHANT, },
				{ color = {1, 1, 1, 1}, disenchant = false, log = true,	sort = 402,	text = L["Banking"], },
				{ color = {1, 1, 1, 1}, disenchant = false, log = false, sort = 403,	text = L["Free"],},
			},
			disenchant = true, -- Disenchant enabled, i.e. there's a true in awardReasons.disenchant

			timeout = 60,

			-- List of items to ignore:
			ignoredItems = {
				[109693] = true, [115502] = true, [111245] = true, [115504] = true, [113588] = true, -- WoD enchant mats
				[124441] = true, [124442] = true, -- Chaos Crystal (Legion), Leylight Shard (Legion)
				[141303] = true, [141304] = true, [141305] = true, -- Essence of Clarity (Emerald Nightmare quest item)
				[143656] = true, [143657] = true, [143658] = true, -- Echo of Time (Nighthold quest item)
				[132204] = true, [151248] = true, [151249] = true, [151250] = true, -- Sticky Volatile Essence, Fragment of the Guardian's Seal (Tomb of Sargeras)
				[152902] = true, [152906] = true, [152907] = true, [155831] = true, -- Rune of Passage (Antorus shortcut item), Pantheon's Blessing
				[152908] = true, [152909] = true, [152910] = true, -- Sigil of the Dark Titan (Another Antorus shortcut item)
			},
		},
	} -- defaults end

	-- create the other buttons/responses
	for i = 1, self.defaults.profile.maxButtons do
		if i > self.defaults.profile.numButtons then
			tinsert(self.defaults.profile.buttons, {
				text = L["Button"].." "..i,
				whisperKey = ""..i,
			})
			tinsert(self.defaults.profile.responses, {
				color = {0.7, 0.7,0.7,1},
				sort = i,
				text = L["Button"]..i,
			})
		end
		if i > self.defaults.profile.tierNumButtons then
			tinsert(self.defaults.profile.tierButtons, {
				text = L["Button"].." "..i,
				whisperKey = ""..i,
			})
			tinsert(self.defaults.profile.responses.tier, {
				color = {0.7, 0.7,0.7,1},
				sort = i,
				text = L["Button"]..i,
			})
		end
		tinsert(self.defaults.profile.relicButtons, {
			text = L["Button"].." "..i,
			whisperKey = ""..i,
		})
		tinsert(self.defaults.profile.responses.relic, {
			color = {0.7, 0.7,0.7,1},
			sort = i,
			text = L["Button"]..i,
		})
	end
	-- create the other AwardReasons
	for i = #self.defaults.profile.awardReasons+1, self.defaults.profile.maxAwardReasons do
		tinsert(self.defaults.profile.awardReasons, {color = {1, 1, 1, 1}, disenchant = false, log = true, sort = 400+i, text = "Reason "..i,})
	end

	-- register chat and comms
	self:RegisterChatCommand("rc", "ChatCommand")
  	self:RegisterChatCommand("rclc", "ChatCommand")
	self.customChatCmd = {} -- Modules that wants their cmds used with "/rc"
	self:RegisterComm("RCLootCouncil")
	self.db = LibStub("AceDB-3.0"):New("RCLootCouncilDB", self.defaults, true)
	self.lootDB = LibStub("AceDB-3.0"):New("RCLootCouncilLootDB")
	--[[ Format:
	"playerName" = {
		[#] = {"lootWon", "date (d/m/y)", "time (h:m:s)", "instance", "boss", "votes", "itemReplaced1", "itemReplaced2", "response", "responseID",
		 		 "color", "class", "isAwardReason", "difficultyID", "mapID", "groupSize", "tierToken"}
	},
	]]
	self.db.RegisterCallback(self, "OnProfileChanged", ReloadUI)
	self.db.RegisterCallback(self, "OnProfileCopied", ReloadUI)
	self.db.RegisterCallback(self, "OnProfileReset", ReloadUI)

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
	-- reset verTestCandidates
	self.db.global.verTestCandidates = {}
	self.playersData = playersData -- Make it globally available
	self:InitItemStorage()
	-- Add logged in message in the log
	self:DebugLog("Logged In")
end

function RCLootCouncil:OnEnable()
	-- Register the player's name
	self.realmName = select(2, UnitFullName("player"))
	self.playerName = self:UnitName("player")
	self:DebugLog(self.playerName, self.version, self.tVersion)

	-- register events
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", "OnEvent")
	self:RegisterEvent("PARTY_LEADER_CHANGED", "OnEvent")
	self:RegisterEvent("GROUP_LEFT", "OnEvent")
	self:RegisterEvent("GUILD_ROSTER_UPDATE","OnEvent")
	self:RegisterEvent("RAID_INSTANCE_WELCOME","OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "EnterCombat")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "LeaveCombat")
	self:RegisterEvent("ENCOUNTER_START", "OnEvent")
	self:RegisterEvent("ENCOUNTER_END", 	"OnEvent")
	self:RegisterEvent("LOOT_OPENED",		"OnEvent")
	self:RegisterEvent("LOOT_SLOT_CLEARED", "OnEvent")
	self:RegisterEvent("LOOT_CLOSED",		"OnEvent")

	--self:RegisterEvent("GROUP_ROSTER_UPDATE", "Debug", "event")

	if IsInGuild() then
		self.guildRank = select(2, GetGuildInfo("player"))
		self:SendCommand("guild", "verTest", self.version, self.tVersion) -- send out a version check
	end

	-- For some reasons all frames are blank until ActivateSkin() is called, even though the values used
	-- in the :CreateFrame() all :Prints as expected :o
	self:ActivateSkin(db.currentSkin)

	if self.db.global.version and self:VersionCompare(self.db.global.version, self.version) then -- We've upgraded
		if self:VersionCompare(self.db.global.version, "2.7.0") then
			self.db.global.localizedSubTypes = nil -- Removed in 2.7
			self.db.profile.ignore = nil -- Replaced with ignoredItems in 2.7
			self:ScheduleTimer("Print", 2, "v2.7 contains a lot of new features. See the changelog at https://www.curseforge.com/wow/addons/rclootcouncil/changes")
		end

		self.db.global.oldVersion = self.db.global.version
		self.db.global.version = self.version
	else -- Mostly for first time load
		self.db.global.version = self.version;
	end
	self.db.global.logMaxEntries = self.defaults.global.logMaxEntries -- reset it now for zzz

	if self.tVersion then
		self.db.global.logMaxEntries = 4000 -- bump it for test version
	end
	if self.db.global.tVersion and self.debug then -- recently ran a test version, so reset debugLog
		self.db.global.log = {}
	end
	self.db.global.locale = GetLocale() -- Store locale in log. Important information for debugging.

	self.db.global.tVersion = self.tVersion;
	GuildRoster()

	local filterFunc = function(_, event, msg, player, ...)
		return strfind(msg, "[[RCLootCouncil]]:")
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterFunc)
end

function RCLootCouncil:OnDisable()
	self:Debug("OnDisable()")
	--NOTE (not really needed as we probably never call .Disable() on the addon)
		-- delete all windows
		-- disable modules(?)
	self:UnregisterAllEvents()
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
	local input = self:GetArgs(msg,1)
	local args = {}
	local arg, startpos = nil, input and #input + 1 or 0
	repeat
	    arg, startpos = self:GetArgs(msg, 1, startpos)
	    if arg then
	         table.insert(args, arg)
	    end
	until arg == nil
	input = strlower(input or "")
	self:Debug("/", input, unpack(args))
	if not input or input:trim() == "" or input == "help" or input == string.lower(_G.HELP_LABEL) then
		if self.tVersion then print(format(L["chat tVersion string"],self.version, self.tVersion))
		else print(format(L["chat version String"],self.version)) end
		local module
		for _, v in ipairs(self.chatCmdHelp) do
			if v.module ~= module then -- Print module name and version
				print "" -- spacer
				if v.module.version and v.module.tVersion then
					print(v.module.baseName, "|cFFFFA500", v.module.version, v.module.tVersion)
				elseif v.module.version then
					print(v.module.baseName, "|cFFFFA500", v.module.version)
				else
					print(v.module.baseName, "|cFFFFA500", GetAddOnMetadata(v.module.baseName, "Version"))
				end
			end
			if v.cmd then
				print("|cff20a200", v.cmd, "|r:", v.desc)
			else
				print(v.desc) -- For backwards compatibility
			end
			module = v.module
		end
		self:Debug("- debug or d - Toggle debugging")
		self:Debug("- log - display the debug log")
		self:Debug("- clearLog - clear the debug log")

	elseif input == 'config' or input == L["config"] or input == "c" then
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
		elseif #lootTable == 0 then
			self:Print(L["No session running"])
		else
			self:Print(L["You are not allowed to see the Voting Frame right now."])
		end

	elseif input == 'council' or input == L["council"] then
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame.ml)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame.ml)
		LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil", "mlSettings", "councilTab")


	elseif input == 'test' or input == L["test"] then
		self:Test(tonumber(args[1]) or 1)
	elseif input == 'fulltest' or input == 'ftest' then
		self:Test(tonumber(args[1]) or 1, true)

	elseif input == 'version' or input == L["version"] or input == "v" or input == "ver" then
		self:CallModule("version")

	elseif input == "history" or input == string.lower(_G.HISTORY) or input == "h" or input == "his" then
		self:CallModule("history")
--@debug@
	elseif input == "nnp" then
		self.nnp = not self.nnp
		self:Print("nnp = "..tostring(self.nnp))
	elseif input == "exporttrinketdata" then
		self:ExportTrinketData()
	elseif input == 'trinkettest' or input == 'ttest' then
		self.playerClass = string.upper(args[1])
		self:Test(1, false, true)
	elseif input == "exporttokendata" then
		self:ExportTokenData()
--@end-debug@
	elseif input == "whisper" or input == string.lower(_G.WHISPER) then
		self:Print(L["whisper_help"])

	elseif input == "add" or input == string.lower(_G.ADD) then
		if not args[1] or args[1] == "" then return self:ChatCommand("help") end
		if self.isMasterLooter then
			local links = args
			if args[1]:find("|h") then -- Only split links if we have at least one
			 	links = self:SplitItemLinks(args) -- Split item links to allow user to enter links without space
			end
			for _,v in ipairs(links) do
			self:GetActiveModule("masterlooter"):AddUserItem(v, self.playerName)
			end
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end

	elseif input == "award" or input == L["award"] then
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):SessionFromBags()
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end

	elseif input == "winners" or input == L["winners"] then
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):PrintAwardedInBags()
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end

	elseif input == "list" then -- Print db.baggedItems
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):PrintItemsInBags()
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end

	elseif input == "remove" then -- Remove one or more entries from db.baggedItems
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):RemoveItemsInBags(unpack(args))
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end

	elseif input == "clear" then -- Clear db.baggedItems
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):ClearAllItemsInBags()
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end

	elseif input == "reset" or input == string.lower(_G.RESET) then
		for k, v in pairs(db.UI) do -- We can't easily reset due to the wildcard in defaults
			if k == "lootframe" then -- Loot Frame is special
				v.y		= -200
			else
				v.y		= 0
			end
			v.point	= "CENTER"
			v.x 			= 0
			v.scale		= 0.8
		end
		for _, frame in ipairs(frames) do
			frame:RestorePosition()
		end
		self:Print(L["Windows reset"])

	elseif input == "debuglog" or input == "log" then
		for k,v in ipairs(debugLog) do print(k,v); end

	elseif input == "clearlog" then
		wipe(debugLog)
		self:Print("Debug Log cleared.")

	elseif input == "updatehistory" or (input == "update" and args[1] == "history") then
		self:UpdateLootHistory()
	elseif input == "sync" then
		self.Sync:Spawn()
--@debug@
	elseif input == 't' then -- Tester cmd
		-- Test items with several modifiers. Should probably be added to the regular test func
		local items = {
			"item:152159:5442:151583::::::110:256::4:5:3613:42:1808:1472:3337",
			"item:147167::::::::110:256::4:4:3564:41:1487:3337",
			"item:151941::::::::110:256::3:5:3610:42:43:1487:3337",
			"item:134396::::::::110:256::16:4:3418:42:1582:3336",
			"item:147017::::::::110:256::5:4:41:3562:1497:3528",
			"item:151955::::::::110:256::3:4:43:3610:1472:3528",
		}
		self.testMode = true;
		self.isMasterLooter, self.masterLooter = self:GetML()
		-- Call ML module and let it handle the rest
		self:CallModule("masterlooter")
		self:GetActiveModule("masterlooter"):NewML(self.masterLooter)
		self:GetActiveModule("masterlooter"):Test(items)
--@end-debug@
	else
		-- Check if the input matches anything
		for k, v in pairs(self.customChatCmd) do
			if k == input then return v.module[v.func](v.module, unpack(args)) end
		end
		self:ChatCommand("help")
	end
end

-- Update the recentTradableItem by link, if it is in bag and tradable.
function RCLootCouncil:UpdateAndSendRecentTradableItem(link)
	for i = 0, NUM_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			local _, _, _, _, _, _, link2 = GetContainerItemInfo(i, j)
			if link2 and self:ItemIsItem(link, link2)
				and self:GetContainerItemTradeTimeRemaining(i, j) > 0 then
				self.recentTradableItem = link
				self:SendCommand("group", "tradable", link)
				return
			end
		end
	end
end

-- Send the msg to the channel if it is valid. Otherwise just print the messsage.
function RCLootCouncil:SendAnnouncement(msg, channel)
	if channel == "NONE" then return end
	if self.testMode then
		msg = "("..L["Test"]..") "..msg
	end
	if not IsInGroup() and (channel == "group" or channel == "RAID" or channel == "PARTY" or channel == "INSTANCE_CHAT") then
		self:Print(msg)
	elseif not IsInGuild() and (channel == "GUILD" or channel == "OFFICER") then
		self:Print(msg)
	else
		SendChatMessage(msg, self:GetAnnounceChannel(channel))
	end
end

--- Send a RCLootCouncil Comm Message using AceComm-3.0
-- See RCLootCouncil:OnCommReceived() on how to receive these messages.
-- @param target The receiver of the message. Can be "group", "guild" or "playerName".
-- @param command The command to send.
-- @param ... Any number of arguments to send along. Will be packaged as a table.
function RCLootCouncil:SendCommand(target, command, ...)
	-- send all data as a table, and let receiver unpack it
	local toSend = self:Serialize(command, {...})

	if target == "group" then
		if IsInRaid() then -- Raid
			self:SendCommMessage("RCLootCouncil", toSend, IsPartyLFG() and "INSTANCE_CHAT" or "RAID")
		elseif IsInGroup() then -- Party
			self:SendCommMessage("RCLootCouncil", toSend, IsPartyLFG() and "INSTANCE_CHAT" or "PARTY")
		else--if self.testMode then -- Alone (testing)
			self:SendCommMessage("RCLootCouncil", toSend, "WHISPER", self.playerName)
		end

	elseif target == "guild" then
		self:SendCommMessage("RCLootCouncil", toSend, "GUILD")

	else
		if self:UnitIsUnit(target,"player") then -- If target == "player"
			self:SendCommMessage("RCLootCouncil", toSend, "WHISPER", self.playerName)
		else
			-- We cannot send "WHISPER" to a crossrealm player
			if target:find("-") then
				if target:find(self.realmName) then -- Our own realm, just send it
					self:SendCommMessage("RCLootCouncil", toSend, "WHISPER", target)
				else -- Get creative
					-- Remake command to be "xrealm" and put target and command in the table
					-- See "RCLootCouncil:HandleXRealmComms()" for more info
					toSend = self:Serialize("xrealm", {target, command, ...})
					if GetNumGroupMembers() > 0 then -- We're in a group
						self:SendCommMessage("RCLootCouncil", toSend, IsPartyLFG() and "INSTANCE_CHAT" or "RAID")
					else -- We're not, probably a guild verTest
						self:SendCommMessage("RCLootCouncil", toSend, "GUILD")
					end
				end

			else -- Should also be our own realm
				self:SendCommMessage("RCLootCouncil", toSend, "WHISPER", target)
			end
		end
	end
end

--- Receives RCLootCouncil commands.
-- Params are delivered by AceComm-3.0, but we need to extract our data created with the
-- RCLootCouncil:SendCommand function.
-- @usage
-- --To extract the original data using AceSerializer-3.0:
-- local success, command, data = self:Deserialize(serializedMsg)
-- --'data' is a table containing the varargs delivered to RCLootCouncil:SendCommand().
--
-- -- To ensure correct handling of x-realm commands, include this line aswell:
-- if RCLootCouncil:HandleXRealmComms(self, command, data, sender) then return end
function RCLootCouncil:OnCommReceived(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncil" then
		self:DebugLog("Comm received:" .. serializedMsg, "from:", sender, "distri:", distri)
		-- data is always a table to be unpacked
		local test, command, data = self:Deserialize(serializedMsg)
		-- NOTE: Since I can't find a better way to do this, all xrealms comms is routed through here
		--			to make sure they get delivered properly. Must be included in every OnCommReceived() function.
		if self:HandleXRealmComms(self, command, data, sender) then return end

		if test then
			if command == "lootTable" then
				if self:UnitIsUnit(sender, self.masterLooter) then
					lootTable = unpack(data)
					-- Send "DISABLED" response when not enabled
					if not self.enabled then
						for i = 1, #lootTable do
							-- target, session, response, isTier, isRelic, note, roll, link, ilvl, equipLoc, relicType, sendAvgIlvl, sendSpecID
							self:SendResponse("group", i, "DISABLED")
						end
						return self:Debug("Sent 'DISABLED' response to", sender)
					end

					-- Cache items
					local cached = true
					for k, v in ipairs(lootTable) do
						if not GetItemInfo(v.link) then cached = false end
					end
					if not cached then
						-- Note: Dont print debug log here. It is spamming.
						return self:ScheduleTimer("OnCommReceived", 0, prefix, serializedMsg, distri, sender)
					end

					self:PrepareLootTable(lootTable)

					-- v2.0.1: It seems people somehow receives mldb without numButtons, so check for it aswell.
					if not self.mldb or (self.mldb and not self.mldb.numButtons) then -- Really shouldn't happen, but I'm tired of people somehow not receiving it...
						self:Debug("Received loot table without having mldb :(", sender)
						self:SendCommand(self.masterLooter, "MLdb_request")
						return self:ScheduleTimer("OnCommReceived", 5, prefix, serializedMsg, distri, sender)
					end

					-- Check if council is received
					if not FindInTableIf(self.council, function(v) return self:UnitIsUnit(self.masterLooter, v) end) then
						self:Debug("Received loot table without ML in the council", sender)
						self:SendCommand(self.masterLooter, "council_request")
						return self:ScheduleTimer("OnCommReceived", 5, prefix, serializedMsg, distri, sender)
					end

					-- Hand the lootTable to the votingFrame
					if self.isCouncil or self.mldb.observe then
						self:GetActiveModule("votingframe"):ReceiveLootTable(lootTable)
					end

					-- Out of instance support
					-- assume 8 people means we're actually raiding
					if GetNumGroupMembers() >= 8 and not IsInInstance() then
						self:DebugLog("NotInRaid respond to lootTable")
						for ses, v in ipairs(lootTable) do
							-- target, session, response, isTier, isRelic, note, roll, link, ilvl, equipLoc, relicType, sendAvgIlvl, sendSpecID
							self:SendResponse("group", ses, "NOTINRAID", nil, nil, nil, nil, v.link, v.ilvl, v.equipLoc, v.relic, true, true)
						end
						return
					end

					self:DoAutoPasses(lootTable)
					self:SendLootAck(lootTable)

					-- Show  the LootFrame
					self:CallModule("lootframe")
					self:GetActiveModule("lootframe"):Start(lootTable)

				else -- a non-ML send a lootTable?!
					self:Debug(tostring(sender).." is not ML, but sent lootTable!")
				end

			elseif command == "lt_add" and self:UnitIsUnit(sender, self.masterLooter) then
				-- We can skip most of the normal lootTable checks since a session should running
				local oldLenght = #lootTable
				lootTable = unpack(data)
				self:PrepareLootTable(lootTable)
				self:DoAutoPasses(lootTable, oldLenght)
				self:SendLootAck(lootTable, oldLenght)
				-- NOTE: Somewhat of a hack, but has the desired effect. Could probably do with a dedicated function.
				-- FIXME: This doesn't work if the candidate is already rolling for the original lootTable
				for k,v in ipairs(lootTable) do
					if k <= oldLenght then
						v.autopass = true
					end
				end
				self:CallModule("lootframe")
				self:GetActiveModule("lootframe"):Start(lootTable)
				-- VotingFrame handles this by itself.

			elseif command == "candidates" and self:UnitIsUnit(sender, self.masterLooter) then
				self.candidates = unpack(data)
			elseif command == "council" and self:UnitIsUnit(sender, self.masterLooter) then -- only ML sends council
				self.council = unpack(data)
				self.isCouncil = self:IsCouncil(self.playerName)

				-- prepare the voting frame for the right people
				if self.isCouncil or self.mldb.observe then
					self:CallModule("votingframe")
				else
					self:GetActiveModule("votingframe"):Disable()
				end

			elseif command == "MLdb" and not self.isMasterLooter then -- ML sets his own mldb
				--[[ NOTE: 2.1.7 - While a check for this does make sense, I'm just really tired of mldb problems, and
					noone should really be able to send it without being ML in the first place. So just accept it as is. ]]
				-- [[2.7: Probably should still check this. There are issues otherwise.]]
				if self:UnitIsUnit(sender, self.masterLooter) then
					self.mldb = unpack(data)
				else
					self:Debug("Non-ML:", sender, "sent Mldb!")
				end

			elseif command == "verTest" and not self:UnitIsUnit(sender, "player") then -- Don't reply to our own verTests
				local otherVersion, tVersion = unpack(data)
				-- We want to reply to guild chat if that's where the message is sent
				if distri == "GUILD" then
					sender = "guild"
				end
				self:SendCommand(sender, "verTestReply", self.playerName, self.playerClass, self.guildRank, self.version, self.tVersion, self:GetInstalledModulesFormattedData())
				if strfind(otherVersion, "%a+") then return self:Debug("Someone's tampering with version?", otherVersion) end
				if self:VersionCompare(self.version,otherVersion) and not self.verCheckDisplayed and (not (tVersion or self.tVersion)) then
					self:Print(format(L["version_outdated_msg"], self.version, otherVersion))
					self.verCheckDisplayed = true

				elseif tVersion and self.tVersion and not self.verCheckDisplayed and self.tVersion < tVersion then
					if #tVersion >= 10 then return self:Debug("Someone's tampering with tVersion?", tVersion) end
					self:Print(format(L["tVersion_outdated_msg"], tVersion))
					self.verCheckDisplayed = true
				end

			elseif command == "verTestReply" then
				local name,_,_, otherVersion, tVersion, moduleData = unpack(data)
				self.db.global.verTestCandidates[name] = otherVersion.. "-" .. tostring(tVersion) .. ": - " .. self.playerName
				if strfind(otherVersion, "%a+") then return self:Debug("Someone's tampering with version?", otherVersion) end
				if self:VersionCompare(self.version,otherVersion) and not self.verCheckDisplayed and (not (tVersion or self.tVersion)) then
					self:Print(format(L["version_outdated_msg"], self.version, otherVersion))
					self.verCheckDisplayed = true

				elseif tVersion and self.tVersion and not self.verCheckDisplayed and self.tVersion < tVersion then
					if #tVersion >= 10 then return self:Debug("Someone's tampering with tVersion?", tVersion) end
					self:Print(format(L["tVersion_outdated_msg"], tVersion))
					self.verCheckDisplayed = true
				end
				-- Check modules. Parse the strings.
				if moduleData then
					for _, str in pairs(moduleData) do
						local baseName, otherVersion, tVersion
						baseName, otherVersion, tVersion = str:match("(.+) %- (.+)%-(.+)")
						if not baseName then
							baseName, otherVersion = str:match("(.+) %- (.+)")
						end
						if otherVersion and strfind(otherVersion, "%a+") then
							self:Debug("Someone's tampering with version in the module?", baseName, otherVersion)
						elseif baseName then
							for _, module in pairs(self.modules) do
								if module.baseName == baseName then
									if module.version and self:VersionCompare(module.version, otherVersion) and not self.moduleVerCheckDisplayed[baseName] and (not (tVersion or module.tVersion)) then
										self:Print(format(L["module_version_outdated_msg"], baseName, module.version, otherVersion))
										self.moduleVerCheckDisplayed[baseName] = true
									elseif tVersion and module.tVersion and not self.moduleVerCheckDisplayed[baseName] and module.tVersion < tVersion then
										if #tVersion >= 10 then self:Debug("Someone's tampering with tVersion in the module?", baseName, tVersion) end
										self:Print(format(L["module_tVersion_outdated_msg"], baseName, tVersion))
										self.moduleVerCheckDisplayed[baseName] = true
									end
								end
							end
						end
					end
				end

			elseif command == "history" and db.enableHistory then
				local name, history = unpack(data)
				if historyDB[name] then
					tinsert(historyDB[name], history)
				else
					historyDB[name] = {history}
				end
				if self:GetActiveModule("history"):IsEnabled() then -- Update history frame if it is shown currently.
					self:GetActiveModule("history"):BuildData()
				end

			elseif command == "delete_history" and db.enableHistory then
				local id = unpack(data)
				for name, d in pairs(historyDB) do
					for i = #d, 1, -1 do
						local entry = d[i]
						if entry.id == id then
							tremove(d, i)
							break
						end
					end
				end
				if self:GetActiveModule("history"):IsEnabled() then -- Update history frame if it is shown currently.
					self:GetActiveModule("history"):BuildData()
				end

			elseif command == "reroll" and self:UnitIsUnit(sender, self.masterLooter) and self.enabled then
				self:Print(format(L["'player' has asked you to reroll"], self.Ambiguate(sender)))
				local table = unpack(data)
				self:PrepareLootTable(table)
				self:DoAutoPasses(table)
				self:SendLootAck(table)

				self:CallModule("lootframe")
				self:GetActiveModule("lootframe"):ReRoll(table)

			elseif command == "playerInfoRequest" then
				self:SendCommand(sender, "playerInfo", self:GetPlayerInfo())

			elseif command == "session_end" and self.enabled then
				if self:UnitIsUnit(sender, self.masterLooter) then
					self:Print(format(L["'player' has ended the session"], self.Ambiguate(self.masterLooter)))
					self:GetActiveModule("lootframe"):Disable()
					lootTable = {}
					if self.isCouncil or self.mldb.observe then -- Don't call the voting frame if it wasn't used
						self:GetActiveModule("votingframe"):EndSession(db.autoClose)
					end
				else
					self:Debug("Non ML:", sender, "sent end session command!")
				end

			elseif command == "lootAck" and not self:UnitIsUnit(sender, "player") and self.enabled then
				-- It seems we have message dropping. If we receive a lootAck, but we don't have lootTable, then something's wrong!
				if not lootTable or #lootTable == 0 then
					self:Debug("!!!! We got an lootAck without having lootTable!!!!")
					if not self.masterLooter then -- Extra sanity check
						return self:DebugLog("We don't have a ML?!")
					end
					if not self.recentReconnectRequest then -- we don't want to do it too often!
						self:SendCommand(self.masterLooter, "reconnect")
						self.recentReconnectRequest = true
						self:ScheduleTimer("ResetReconnectRequest", 5) -- 5 sec break between each try
					end
				end

			elseif command == "sync" then
				self.Sync:SyncDataReceived(unpack(data))
			elseif command == "syncRequest" then
				self.Sync:SyncRequestReceived(unpack(data))
			elseif command == "syncAck" then
				self.Sync:SyncAckReceived(unpack(data))
			elseif command == "syncNack" then
				self.Sync:SyncNackReceived(unpack(data))
			end
		else
			-- Most likely pre 2.0 command
			local cmd = strsplit(" ", serializedMsg, 2)
			if cmd and cmd == "verTest" then
				self:SendCommand(sender, "verTestReply", self.playerName, self.playerClass, self.guildRank, self.version, self.tVersion)
				return
			end
			self:Debug("Error in deserializing comm:", command, data);
		end
	end
end

--- Used to make sure "WHISPER" type xrealm comms is handled properly.
-- @usage
-- -- Include this right after unpacking messages. Assumes you use "OnCommReceived" as comm handler:
-- if RCLootCouncil:HandleXRealmComms(self, command, data, sender) then return end
-- @see OnCommReceived
function RCLootCouncil:HandleXRealmComms(mod, command, data, sender)
	if command == "xrealm" then
		local target = tremove(data, 1)
		if self:UnitIsUnit(target, "player") then
			local command = tremove(data, 1)
			mod:OnCommReceived("RCLootCouncil", self:Serialize(command, data), "WHISPER", sender)
		end
		return true
	end
	return false
end

function RCLootCouncil:ResetReconnectRequest()
	self.recentReconnectRequest = false
	self:DebugLog("ResetReconnectRequest")
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
	-- filter out verTestReply spam
	if msg:find("verTestReply") then return end
	local time = date("%X", time())
	msg = time.." - ".. tostring(msg)
	for i = 1, select("#", ...) do msg = msg.." ("..tostring(select(i,...))..")" end
	if #debugLog > self.db.global.logMaxEntries then
		tremove(debugLog, 1)
	end
	tinsert(debugLog, msg)
end

-- if fullTest, add items in the encounterJournal to the test items.
function RCLootCouncil:Test(num, fullTest, trinketTest)
	self:Debug("Test", num)
	local testItems = {
		-- Tier21 Tokens (Head, Shoulder, Cloak, Chest, Hands, Legs)
		152524, 152530, 152517, 152518, 152521, 152527, -- Vanquisher: DK, Druid, Mage, Rogue
		152525, 152531, 152516, 152519, 152522, 152528, -- Conqueror : DH, Paladin, Priest, Warlock
		152526, 152532, 152515, 152520, 152523, 152529, -- Protector : Hunder, Monk, Shaman, Warrior

		-- Tier21 Armors (Head, Shoulder, Chest, Wrist, Hands, Waist, Legs, Feet)
		152014, 152019, 152017, 152023, 152686, 152020, 152016, 152009, -- Plate
		152423, 152005, 151994, 152008, 151998, 152006, 152002, 151996, -- Mail
		151985, 151988, 151982, 151992, 151984, 151986, 151987, 151981, -- Leather
		151943, 151949, 152679, 151953, 152680, 151942, 151946, 151939, -- Cloth

		-- Tier21 Miscellaneous
		152283, 151965, 151973,                                         -- Neck
		151937, 151938, 152062,                                         -- Cloak
		151972, 152063, 152284,                                         -- Rings

		-- Tier21 Relics
		152024, 152025, -- Arcane
		152028, 152029, -- Blood
		152031, 152032, -- Fel
		152035, 152036, -- Fire
		152039, 152040, -- Frost
		152043, 152044, -- Holy
		152047, 152048, -- Iron
		152050, 152051, -- Life
		152054, 152055, -- Shadow
		152058, 152059, -- Storm
	}

	local trinkets = {
		-- Tier21 Trinkets
		154172, 		-- All classes
		151975, 151976, 151977, 151978, 152645, 153544, 154173, -- Tank
		151974, -- Eye of Shatug. EJ item id is different with the item id actually drops
		151956, 151957, 151958, 151960, 152289, 154175,			-- Healer
		151964,	152093,	-- Melee DPS
		154176, 		-- Strength DPS
		154174,			-- Agility DPS
		151970,			-- Intellect DPS/Healer
		151955, 151971, 154177, -- Intellect DPS
		151963, 151968,	-- Melee and ranged attack DPS
		151962, 151969,	-- Ranged attack and spell DPS
	}

	if not trinketTest then
		for _, t in ipairs(trinkets) do
			tinsert(testItems, t)
		end
	end

	if fullTest then -- Add items from encounter journal which includes items from different difficulties.
		LoadAddOn("Blizzard_EncounterJournal")
		local cached = true
		local difficulties = {14, 15, 16} -- Normal, Heroic, Mythic

		EJ_SelectInstance(self.EJLastestInstanceID)
		EJ_ResetLootFilter()
		for _, difficulty in pairs(difficulties) do
			EJ_SetDifficulty(difficulty)
			self:Debug("EJ_SetDifficulty()", difficulty)

			local n = EJ_GetNumLoot()
			self:Debug("EJ_GetNumLoot()", n)

			if not n then
				cached = false
			end
			for i = 1, n or 0 do
				local link = select(7, EJ_GetLootInfoByIndex(i))
				if link then
					tinsert(testItems, link)
				else
					cached = false
				end
			end
			if not cached then
				self:Debug("Retrieving item info from Encounter Journal. Retry after 1s.")
				return self:ScheduleTimer("Test", 1, num, fullTest)
			end
		end
	end

	local items = {};
	-- pick "num" random items
	for i = 1, num do
		local j = math.random(1, #testItems)
		tinsert(items, testItems[j])
	end
	if trinketTest then -- Always test all trinkets.
		items = trinkets
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

local interface_options_old_cancel = InterfaceOptionsFrameCancel:GetScript("OnClick")
function RCLootCouncil:EnterCombat()
	-- Hack to remove CompactRaidGroup taint
	-- Make clicking cancel the same as clicking okay
	InterfaceOptionsFrameCancel:SetScript("OnClick", function()
	 InterfaceOptionsFrameOkay:Click()
	end)
	self.inCombat = true
	if not db.minimizeInCombat then return end
	for _,frame in ipairs(frames) do
		if frame:IsVisible() and not frame.combatMinimized then -- only minimize for combat if it isn't already minimized
			self:Debug("Minimizing for combat")
			frame.combatMinimized = true -- flag it as being minimized for combat
			frame:Minimize()
		end
	end
end

function RCLootCouncil:LeaveCombat()
	-- Revert
	InterfaceOptionsFrameCancel:SetScript("OnClick", interface_options_old_cancel)
	self.inCombat = false
	if not db.minimizeInCombat then return end
	for _,frame in ipairs(frames) do
		if frame.combatMinimized then -- Reshow it
			self:Debug("Reshowing frame")
			frame.combatMinimized = false
			frame:Maximize()
		end
	end
end

--[[
	Used by getCurrentGear to determine slot types
	Inspired by EPGPLootMaster
--]]
RCLootCouncil.INVTYPE_Slots = {
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

function RCLootCouncil:UpdatePlayersGears(startSlot, endSlot)
	startSlot = startSlot or INVSLOT_FIRST_EQUIPPED
	endSlot = endSlot or INVSLOT_LAST_EQUIPPED

	for i = startSlot, endSlot do
		local iLink = GetInventoryItemLink("player", i)
		if iLink then
			local iName = GetItemInfo(iLink)
			if iName then
				playersData.gears[i] = iLink
			else -- Blizzard bug that GetInventoryItemLink returns incomplete link. Retry
				self:ScheduleTimer("UpdatePlayersGears", 1, i, i)
			end
		else
			playersData.gears[i] = nil
		end
	end
end

function RCLootCouncil:UpdatePlayerRelics(startSlot, endSlot)
	startSlot = startSlot or 1
	endSlot = endSlot or 3

	for i = startSlot, endSlot do
		if i <= C_ArtifactUI.GetEquippedArtifactNumRelicSlots() or 0 then
			local iLink = select(4,C_ArtifactUI.GetEquippedArtifactRelicInfo(i))
			if iLink then
				local iName = GetItemInfo(iLink)
				if iName then
					playersData.relics[i] = iLink
				else  -- Uncached. Retry to make sure this is a correct link.
					self:ScheduleTimer("UpdatePlayerRelics", 1, i, i)
				end
			else
				playersData.relics[i] = nil
			end
		else
			playersData.relics[i] = nil
		end
	end
end

-- Update player's data which is changable by the player. (specid, equipped ilvl, specs, gears, etc)
function RCLootCouncil:UpdatePlayersData()
	self:DebugLog("UpdatePlayersData()")
	playersData.specID = GetSpecialization() and GetSpecializationInfo(GetSpecialization())
	playersData.ilvl = select(2,GetAverageItemLevel())
	self:UpdatePlayersGears()
	self:UpdatePlayerRelics()
end

-- @param link A gear that we want to compare against the equipped gears
-- @param gearsTable if specified, compare against gears stored in the table instead of the current equipped gears, whose key is slot number and value is the item link of the gear.
-- @return the gear(s) that with the same slot of the input link.
function RCLootCouncil:GetPlayersGear(link, equipLoc, gearsTable)
	self:DebugLog("GetPlayersGear", link, equipLoc)
	local GetInventoryItemLink = GetInventoryItemLink
	if gearsTable then -- lazy code
		GetInventoryItemLink = function(_, slotNum) return gearsTable[slotNum] end
	end

	local itemID = self:GetItemIDFromLink(link) -- Convert to itemID
	if not itemID then return nil, nil; end
	local item1, item2;
	-- check if the item is a token, and if it is, return the matching current gear
	if RCTokenTable[itemID] then
		if RCTokenTable[itemID] == "MultiSlots" then -- Armor tokens for multiple slots, just return nil
			return
		elseif RCTokenTable[itemID] == "Trinket" then -- We need to return both trinkets
			item1 = GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET0SLOT"))
			item2 = GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET1SLOT"))
		else	-- Just return the slot from the tokentable
			item1 = GetInventoryItemLink("player", GetInventorySlotInfo(RCTokenTable[itemID]))
		end
		return item1, item2
	end
	local slot = self.INVTYPE_Slots[equipLoc]
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

-- This function assumes all items in "relicsTable" to be cached. "link" does not need to be cached if relicType is specified.
-- @param link A relic that we want to compare against the equipped relics
-- @parm relicType the relic type of the item. If not specified, fetch it(need item to be cached)
-- @param relicsTable if specified, compare against relics stored in the table instead of the current equipped relics, whose key is slot number and value is the item link of the relic.
-- @return the relic(s) that with the same type of the input link.
function RCLootCouncil:GetArtifactRelics(link, relicType, relicsTable)
	local id = self:GetItemIDFromLink(link)
	relicType = relicType or select(3, C_ArtifactUI.GetRelicInfoByItemID(id))
	local g1,g2;
	local n = relicsTable and 3 or C_ArtifactUI.GetEquippedArtifactNumRelicSlots() or 0
	for i = 1, n do
		local iLink = relicsTable and relicsTable[i] or select(4,C_ArtifactUI.GetEquippedArtifactRelicInfo(i))
		if iLink and select(3, C_ArtifactUI.GetRelicInfoByItemID(self:GetItemIDFromLink(iLink))) == relicType then
			if g1 then
				g2 = iLink
			else
				g1 = iLink
			end
		end
	end
	return g1, g2
end

-- Sends a response. Uses the gear equipped at the start of most recent encounter or login.
-- @paramsig session [, ...]
-- link, ilvl, equipLoc and subType must be provided to send out gear information.
-- @param target 		The target of response
-- @param session		The session to respond to.
-- @param response		The selected response, must be index of db.responses.
-- @param isTier		Indicates if the response is a tier response. (v2.4.0)
-- @param isRelic		Indicates if the response is a relic response. (v2.5.0)
-- @param note			The player's note.
-- @param roll 			The player's roll.
-- @param link 			The itemLink of the item in the session.
-- @param ilvl			The ilvl of the item in the session.
-- @param equipLoc		The item in the session's equipLoc.
-- @param relicType     The type of relic
-- @param sendAvgIlvl   Indicates whether we send average ilvl.
-- @param sendSpecID    Indicates whether we send spec id.
function RCLootCouncil:SendResponse(target, session, response, isTier, isRelic, note, roll, link, ilvl, equipLoc, relicType, sendAvgIlvl, sendSpecID)
	self:DebugLog("SendResponse", target, session, response, isTier, isRelic, note, roll, link, ilvl, equipLoc, relicType, sendAvgIlvl, sendSpecID)
	local g1, g2, diff

	if link and ilvl then
		g1, g2 = self:GetGear(link, equipLoc, relicType)
		diff = self:GetDiff(g1,g2,ilvl)
	end

	self:SendCommand(target, "response",
		session,
		self.playerName,
		{	gear1 = g1 and self:GetItemStringFromLink(g1) or nil,
			gear2 = g2 and self:GetItemStringFromLink(g2) or nil,
			ilvl = sendAvgIlvl and playersData.ilvl or nil,
			diff = diff,
			note = note,
			response = response,
			isTier = isTier or nil,
			isRelic = isRelic or nil,
			specID = sendSpecID and playersData.specID or nil,
			roll = roll,
		})
end

function RCLootCouncil:GetGear(link, equipLoc, relicType)
	if relicType then
		return self:GetArtifactRelics(link, relicType, playersData.relics) -- Use relic info we stored before
	else
		return self:GetPlayersGear(link, equipLoc, playersData.gears) -- Use gear info we stored before
	end
end

function RCLootCouncil:GetDiff(g1, g2, ilvl)
	local diff = 0
	local g1diff, g2diff = g1 and select(4, GetItemInfo(g1)), g2 and select(4, GetItemInfo(g2))
	-- if g1 and g2 are not nil, g1diff and g2diff should always be returned because :GetArtifactRelics and:GetPlayersGear should always return cached link
	if g1diff and g2diff then
		diff = g1diff >= g2diff and ilvl - g2diff or ilvl - g1diff
	elseif g1diff then
		diff = ilvl - g1diff
	end
	return diff
end

-- @param link The itemLink of the item.
-- @return If the item level data is not available, return nil. Otherwise, return the minimum item level of the gear created by the token.
function RCLootCouncil:GetTokenIlvl(link)
	local id = self:GetItemIDFromLink(link)
	if not id then return end
	local baseIlvl = RCTokenIlvl[id] -- ilvl in normal difficulty
	if not baseIlvl then return end

	-- Pre WoD, item doesn't share id across difficulties.
	if baseIlvl < 600 then return baseIlvl end

	local bonuses = select(17, self:DecodeItemLink(link))
	for _, value in pairs(bonuses) do
   		-- @see epgp/LibGearPoints-1.2.lua
	    if value == 566 or value == 570 then -- Heroic difficulty
	    	return baseIlvl + 15
	    end
	    if value == 567 or value == 569 then -- Mythic difficulty
	    	return baseIlvl + 30
	    end
  	end
  	return baseIlvl -- Normal difficulty
end

function RCLootCouncil:GetTokenEquipLoc(tokenSlot)
	if tokenSlot then
		if tokenSlot == "Trinket" then
			return "INVTYPE_TRINKET"
		else
			for loc, slot in pairs(self.INVTYPE_Slots) do
				if slot == tokenSlot then
					return loc
				end
			end
		end
	end
	return ""
end

function RCLootCouncil:Timer(type, ...)
	self:Debug("Timer "..type.." passed")
	if type == "MLdb_check" then
		-- If we have a ML
		if self.masterLooter then
			-- But haven't received the mldb, then request it
			if not self.mldb.buttons then
				self:SendCommand(self.masterLooter, "MLdb_request")
			end
			-- and if we haven't received a council, request it
			if #self.council == 0 then
				self:SendCommand(self.masterLooter, "council_request")
			end
		end
	end
end

--- Updates the loot table with some local data.
-- 1 Changes the subType in lootTable to our locale.
-- 2 Extracts tokens equipLoc
function RCLootCouncil:PrepareLootTable(lootTable)
	for ses, v in ipairs(lootTable) do
		local _, _, subType, equipLoc, texture, typeID, subTypeID = GetItemInfoInstant(v.link)
		v.subType = subType -- Subtype should be in our locale
		v.token = v.token or RCTokenTable[self:GetItemIDFromLink(v.link)]
		v.equipLoc = v.token and self:GetTokenEquipLoc(v.token) or equipLoc
		v.texture = texture
		v.typeID = typeID
		v.subTypeID = subTypeID
		if not v.classes then -- We didn't receive "classes", because ML is using an old version. Generate it from token data.
			if RCTokenClasses and RCTokenClasses[self:GetItemIDFromLink(v.link)] then
				v.classes = 0
				for _, class in ipairs(RCTokenClasses[self:GetItemIDFromLink(v.link)]) do
					v.classes = v.classes + bit.lshift(1, self.classTagNameToID[class]-1)
				end
			else
				v.classes = self:GetItemClassesAllowedFlag(v.link) -- will return 0xffffffff(usable by all classes) if the item is not cached, but that's fine.
			end
		end
	end
end

--- Sends a lootAck to the group containing session related data.
-- Included is: specID and average ilvl is sent once.
-- Currently equipped gear and "diff" is sent for each session.
-- Autopass response is sent if the session has been autopassed. No other response is sent.
-- @param skip Only sends lootAcks on sessions > skip or 0
function RCLootCouncil:SendLootAck(table, skip)
	local toSend = {gear1 = {}, gear2 = {}, diff = {}, response = {}}
	local hasData = false
	for k, v in ipairs(table) do
		local session = v.session or k
		if session > (skip or 0) then
			hasData = true
			local g1,g2 = self:GetGear(v.link, v.equipLoc, v.relic)
			local diff = self:GetDiff(g1, g2, v.ilvl)
			toSend.gear1[session] = self:GetItemStringFromLink(g1)
			toSend.gear2[session] = self:GetItemStringFromLink(g2)
			toSend.diff[session] = diff
			toSend.response[session] = v.autopass
		end
	end
	if hasData then
		self:SendCommand("group", "lootAck", self.playerName, playersData.specID, playersData.ilvl, toSend)
	end
end

-- Sets lootTable[session].autopass = true if an autopass occurs, and informs the user of the change
-- @param skip Will only auto pass sessions > skip or 0
function RCLootCouncil:DoAutoPasses(table, skip)
	for k,v in ipairs(table) do
		local session = v.session or k
		if session > (skip or 0) then
			if db.autoPass and not v.noAutopass then
				if (v.boe and db.autoPassBoE) or not v.boe then
					if self:AutoPassCheck(v.link, v.equipLoc, v.typeID, v.subTypeID, v.classes, v.token, v.relic) then
						self:Debug("Autopassed on: ", v.link)
						if not db.silentAutoPass then self:Print(format(L["Autopassed on 'item'"], v.link)) end
						v.autopass = true
					end
				else
					self:Debug("Didn't autopass on: "..v.link.." because it's BoE!")
				end
			end
		end
	end
end

function RCLootCouncil:GetLootTable()
	return lootTable
end

--[[
1	Warrior			WARRIOR
2	Paladin			PALADIN
3	Hunter			HUNTER
4	Rogue				ROGUE
5	Priest			PRIEST
6	Death Knight	DEATHKNIGHT
7	Shaman			SHAMAN
8	Mage				MAGE
9	Warlock			WARLOCK
10	Monk				MONK
11	Druid				DRUID
12	Demon Hunter	DEMONHUNTER
--]]
RCLootCouncil.classDisplayNameToID = {} -- Key: localized class display name. value: class id(number)
RCLootCouncil.classTagNameToID = {} -- key: class name in capital english letters without space. value: class id(number)
for i=1, GetNumClasses() do
	RCLootCouncil.classDisplayNameToID[select(1, GetClassInfo(i))] = i
	RCLootCouncil.classTagNameToID[select(2, GetClassInfo(i))] = i
end

-- @return The bitwise flag indicates the classes allowed for the item, as specified on the tooltip by "Classes: xxx"
-- If the tooltip does not specify "Classes: xxx" or if the item is not cached, return 0xffffffff
-- This function only checks the tooltip and does not consider if the item is equipable by the class.
-- Item must have been cached to get the correct result.
--
-- If the number at binary bit i is 1 (bit 1 is the lowest bit), then the item works for the class with ID i.
-- 0b100,000,000,010 indicates the item works for Paladin(classID 2) and DemonHunter(class ID 12)
-- Expected values:
-- Conqueror(Paladin, Priest, Warlock) == 274(0x112)
-- Protector(Warrior, Hunter, Shaman) == 69(0x45)
-- Vanquisher(Rogue, Mage, Druid) == 1160 (0x488)
function RCLootCouncil:GetItemClassesAllowedFlag(item)
	if not item then return 0 end
	tooltipForParsing:SetOwner(UIParent, "ANCHOR_NONE") -- This lines clear the current content of tooltip and set its position off-screen
	tooltipForParsing:SetHyperlink(item) -- Set the tooltip content and show it, should hide the tooltip before function ends

	local delimiter = ", " -- in-game tests show all locales use this as delimiter.
	local itemClassesAllowedPattern = _G.ITEM_CLASSES_ALLOWED:gsub("%%s", "%(%.%+%)")

	for i = 1, tooltipForParsing:NumLines() or 0 do
		local line = getglobal(tooltipForParsing:GetName()..'TextLeft' .. i)
		if line and line.GetText then
			local text = line:GetText() or ""
			local classesText = text:match(itemClassesAllowedPattern)
			if classesText then
				tooltipForParsing:Hide()
				-- After reading the Blizzard code, I suspect that it's maybe not intended for Blizz to use ", " for all locales. (Patch 7.3.2)
				-- The most strange thing is that LIST_DELIMITER is defined first in FrameXML/GlobalStrings.lua as "%s, %s" and it's not the same for all locales.
				-- Then LIST_DELIMITER is redefined to ", " for all locales in FrameXML/MerchantFrame.lua
				-- Try some other delimiter constants in case Blizzard changes it some time in the future.
				if LIST_DELIMITER and LIST_DELIMITER ~= "" and classesText:find(LIST_DELIMITER:gsub("%%s","")) then
					delimiter = LIST_DELIMITER:gsub("%%s","")
				elseif PLAYER_LIST_DELIMITER and PLAYER_LIST_DELIMITER ~= "" and classesText:find(PLAYER_LIST_DELIMITER) then
					delimiter = PLAYER_LIST_DELIMITER
				end

				local result = 0
				for className in string.gmatch(classesText..delimiter, "(.-)"..delimiter) do
					local classID = self.classDisplayNameToID[className]
					if classID then
						result = result + bit.lshift(1, classID-1)
					else
						-- sth is wrong (should never happen)
						self:Debug("Error while getting classes flag of ", item, "Class does not exist", className)
					end
				end
				return result
			end
		end
	end

	tooltipForParsing:Hide()
	return 0xffffffff -- The item works for all classes
end

-- strings contains plural/singular rule such as "%d |4ora:ore;"
-- For example, CompleteFormatSimpleStringWithPluralRule("%d |4ora:ore;", 2) returns "2 ore"
-- Does not work for long string such as "%d |4jour:jours;, %d |4heure:heures;, %d |4minute:minutes;, %d |4seconde:secondes;"
function RCLootCouncil:CompleteFormatSimpleStringWithPluralRule(str, count)
	local text = format(str, count)
	if count < 2 then
		return text:gsub("|4(.+):(.+);", "%1")
	else
		return text:gsub("|4(.+):(.+);", "%2")
	end
end

-- Return the remaining trade time in second for an item in the container.
-- Return math.huge(infinite) for an item not bounded.
-- Return the remaining trade time in second if the item is within 2h trade window.
-- Return 0 if the item is not tradable (bounded and the trade time has expired.)
function RCLootCouncil:GetContainerItemTradeTimeRemaining(container, slot)
	tooltipForParsing:SetOwner(UIParent, "ANCHOR_NONE") -- This lines clear the current content of tooltip and set its position off-screen
	tooltipForParsing:SetBagItem(container, slot) -- Set the tooltip content and show it, should hide the tooltip before function ends
	if not tooltipForParsing:NumLines() or tooltipForParsing:NumLines() == 0 then
		return 0
	end

	local bindTradeTimeRemainingPattern = escapePatternSymbols(BIND_TRADE_TIME_REMAINING):gsub("%%%%s", "%(%.%+%)") -- PT locale contains "-", must escape that.
	local bounded = false

	for i = 1, tooltipForParsing:NumLines() or 0 do
		local line = getglobal(tooltipForParsing:GetName()..'TextLeft' .. i)
		if line and line.GetText then
			local text = line:GetText() or ""
			if text == ITEM_SOULBOUND or text == ITEM_ACCOUNTBOUND or text == ITEM_BNETACCOUNTBOUND then
				bounded = true
			end

			local timeText = text:match(bindTradeTimeRemainingPattern)
			if timeText then -- Within 2h trade window, parse the time text
				tooltipForParsing:Hide()

				for hour=1, 0, -1 do -- time>=60s, format: "1 hour", "1 hour 59 min", "59 min", "1 min"
					local hourText = ""
					if hour > 0 then
						hourText = self:CompleteFormatSimpleStringWithPluralRule(INT_SPELL_DURATION_HOURS, hour)
					end
					for min=59,0,-1 do
						local time = hourText
						if min > 0 then
							if time ~= "" then
								time = time..TIME_UNIT_DELIMITER
							end
							time = time..self:CompleteFormatSimpleStringWithPluralRule(INT_SPELL_DURATION_MIN, min)
						end

						if time == timeText then
							return hour*3600 + min*60
						end
					end
				end
				for sec=59, 1, -1 do -- time<60s, format: "59 s", "1 s"
					local time = self:CompleteFormatSimpleStringWithPluralRule(INT_SPELL_DURATION_SEC, sec)
					if time == timeText then
						return sec
					end
				end
				-- As of Patch 7.3.2(Build 25497), the parser have been tested for all 11 in-game languages when time < 1h and time > 1h. Shouldn't reach here.
				-- If it reaches here, there are some parsing issues. Let's return 2h.
				return 7200
			end
		end
	end
	tooltipForParsing:Hide()
	if bounded then
		return 0
	else
		return math.huge
	end
end

function RCLootCouncil:IsItemBoE(item)
	if not item then return false end
	-- Item binding type: 0 - none; 1 - on pickup; 2 - on equip; 3 - on use; 4 - quest.
	return select(14, GetItemInfo(item)) == LE_ITEM_BIND_ON_EQUIP
end

function RCLootCouncil:IsItemBoP(item)
	if not item then return false end
	-- Item binding type: 0 - none; 1 - on pickup; 2 - on equip; 3 - on use; 4 - quest.
	return select(14, GetItemInfo(item)) == LE_ITEM_BIND_ON_ACQUIRE
end

function RCLootCouncil:IsRelicTypeID(typeID, subTypeID)
	return typeID == LE_ITEM_CLASS_GEM and subTypeID == LE_ITEM_GEM_ARTIFACTRELIC
end

function RCLootCouncil:GetPlayersGuildRank()
	self:DebugLog("GetPlayersGuildRank()")
	GuildRoster() -- let the event trigger this func
	if IsInGuild() then
		local rank = select(2, GetGuildInfo("player"))
		if rank then
			self:Debug("Found Guild Rank: "..rank)
			unregisterGuildEvent = true;
			return rank;
		else
			return L["Not Found"];
		end
	else
		return L["Unguilded"];
	end
end

--- Returns specific info about the player
-- @return "Name", "Class", "Role", "guildRank", bool isEnchanter, num enchanting_lvl, num ilvl
function RCLootCouncil:GetPlayerInfo()
	-- Check if the player has enchanting
	local enchant, lvl = nil, 0
	local profs = {GetProfessions()}
	for i = 1, 2 do
		if profs[i] then
			local _, _, rank, _, _, _, id = GetProfessionInfo(profs[i])
			if id and id == 333 then -- NOTE: 333 should be enchanting, let's hope that holds...
				self:Debug("I'm an enchanter")
				enchant, lvl = true, rank
				break
			end
		end
	end
	local ilvl = select(2,GetAverageItemLevel())
	return self.playerName, self.playerClass, self:GetPlayerRole(), self.guildRank, enchant, lvl, ilvl, playersData.specID
end

function RCLootCouncil:GetPlayerRole()
	return UnitGroupRolesAssigned("player")
end

function RCLootCouncil:TranslateRole(role)
	return (role and role ~= "") and _G[role] or ""
end

--- Returns a lookup table containing GuildRankNames and their index.
-- @return table ["GuildRankName"] = rankIndex
function RCLootCouncil:GetGuildRanks()
	if not IsInGuild() then return {} end
	self:DebugLog("GetGuildRankNum()")
	GuildRoster()
	local t = {}
	for i = 1, GuildControlGetNumRanks() do
		local name = GuildControlGetRankName(i)
		t[name] = i
	end
	return t;
end

--- Calculates how long ago a given date was.
-- Assumes the date is of year 2000+.
-- @param oldDate A string specifying the date, formatted as "dd/mm/yy".
-- @return day, month, year.
function RCLootCouncil:GetNumberOfDaysFromNow(oldDate)
	local d, m, y = strsplit("/", oldDate, 3)
	local sinceEpoch = time({year = "20"..y, month = m, day = d, hour = 0}) -- convert from string to seconds since epoch
	local diff = date("*t", time() - sinceEpoch) -- get the difference as a table
	-- Convert to number of d/m/y
	return diff.day - 1, diff.month - 1, diff.year - 1970
end

--- Takes the return value from :GetNumberOfDaysFromNow() and converts it to text.
-- @see RCLootCouncil:GetNumberOfDaysFromNow
-- @return A formatted string.
function RCLootCouncil:ConvertDateToString(day, month, year)
	local text = format(L["x days"], day)
	if year > 0 then
		text = format(L["days, x months, y years"], text, month, year)
	elseif month > 0 then
		text = format(L["days and x months"], text, month)
	end
	return text;
end

function RCLootCouncil:OnEvent(event, ...)
	if event == "PARTY_LOOT_METHOD_CHANGED" then
		self:Debug("Event:", event, ...)
		self:NewMLCheck()
	elseif event == "PARTY_LEADER_CHANGED" then
		self:Debug("Event:", event, ...)
		self:NewMLCheck()
	elseif event == "GROUP_LEFT" then
		self:Debug("Event:", event, ...)
		self:NewMLCheck()

	elseif event == "RAID_INSTANCE_WELCOME" then
		self:Debug("Event:", event, ...)
		-- high server-side latency causes the UnitIsGroupLeader("player") condition to fail if queried quickly (upon entering instance) regardless of state.
		-- NOTE v2.0: Not sure if this is still an issue, but just add a 2 sec timer to the MLCheck call
		self:ScheduleTimer("OnRaidEnter", 2)

	elseif event == "PLAYER_ENTERING_WORLD" then
		self:Debug("Event:", event, ...)
		self:NewMLCheck()
		self:ScheduleTimer(function() -- This needs some time to be ready
			local instanceName, _, _, difficultyName = GetInstanceInfo()
			self.currentInstanceName = instanceName..(difficultyName ~= "" and "-"..difficultyName or "")
		end, 5)
		if player_relogged then
			-- Ask for data when we have done a /rl and have a ML
			if not self.isMasterLooter and self.masterLooter and self.masterLooter ~= "" and player_relogged then
				self:Debug("Player relog...")
				self:ScheduleTimer("SendCommand", 2, self.masterLooter, "reconnect")
				self:SendCommand(self.masterLooter, "playerInfo", self:GetPlayerInfo()) -- Also send out info, just in case
			end
			self:UpdatePlayersData()
			player_relogged = false
		end
	elseif event == "ENCOUNTER_START" then
			self:DebugLog("Event:", event, ...)
			self:UpdatePlayersData()
	elseif event == "GUILD_ROSTER_UPDATE" then
		self.guildRank = self:GetPlayersGuildRank();
		if unregisterGuildEvent then
			self:UnregisterEvent("GUILD_ROSTER_UPDATE"); -- we don't need it any more
			self:GetGuildOptions() -- get the guild data to the options table now that it's ready
		end
	elseif event == "ENCOUNTER_END" then
		self:DebugLog("Event:", event, ...)
		self.bossName = select(2, ...) -- Extract encounter name

	elseif event == "LOOT_OPENED" then
		self:Debug("Event:", event, ...)
		if select(1, ...) ~= "scheduled" and self.LootOpenScheduled then return end -- When this function is scheduled to run again, but LOOT_OPENDED event fires, return.
		self.LootOpenScheduled = false
		wipe(self.lootSlotInfo)
		if GetNumLootItems() <= 0 then return end-- In case when function rerun, loot window is closed.

		self.lootOpen = true
		for i = 1,  GetNumLootItems() do
			if LootSlotHasItem(i) then
				local texture, name, quantity, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
				local link = GetLootSlotLink(i)
				if texture then
					self.lootSlotInfo[i] = {
						name = name,
						link = link, -- This could be nil, if the item is money.
						quantity = quantity,
						quality = quality,
						locked = locked,
					}
				else -- It's possible that item in the loot window is uncached. Retry in the next frame.
					self:Debug("Loot uncached when the loot window is opened. Retry in the next frame.", link)
					self.LootOpenScheduled = true
					-- Must offer special argument as 2nd argument to indicate this is run from scheduler.
					return self:ScheduleTimer("OnEvent", 0, "LOOT_OPENED", "scheduled")
				end
			end
		end
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):OnLootOpen()
		end
	elseif event == "LOOT_CLOSED" then
		self:Debug("Event:", event, ...)
		self.lootOpen = false
	elseif event == "LOOT_SLOT_CLEARED" then
		local slot = ...
		if self.lootSlotInfo[slot] then -- If not, this is the 2nd LOOT_CLEARED event for the same thing. -_-
			local link = self.lootSlotInfo[slot].link
			local quality = self.lootSlotInfo[slot].quality
			self:Debug("OnLootSlotCleared()", slot, link)
			self.lootSlotInfo[slot] = nil

			if quality and quality >= GetLootThreshold() and IsInInstance() then -- Only send when in instance
				-- Note that we don't check if this is master looted or not. We only know this is looted by ourselves.
				self:ScheduleTimer("UpdateAndSendRecentTradableItem", 1, link) -- Delay a bit, need some time to between item removed from loot slot and moved to the bag.
			end

			if self.isMasterLooter then
				self:GetActiveModule("masterlooter"):OnLootSlotCleared(slot, link)
			end
		end
	end
end

function RCLootCouncil:NewMLCheck()
	local old_ml = self.masterLooter
	local old_lm = self.lootMethod
	self.isMasterLooter, self.masterLooter = self:GetML()
	self.lootMethod = GetLootMethod()
	if self.masterLooter and self.masterLooter ~= "" and (strfind(self.masterLooter, "Unknown") or strfind(self.masterLooter:lower(), _G.UNKNOWNOBJECT:lower())) then
		-- ML might be unknown for some reason
		self:Debug("Unknown ML")
		return self:ScheduleTimer("NewMLCheck", 0.5)
	end

	if not self.isMasterLooter then -- we're not ML, so make sure it's disabled
		self:GetActiveModule("masterlooter"):Disable()
		self.handleLoot = false -- Reset
	end
	if IsPartyLFG() then return end	-- We can't use in lfg/lfd so don't bother
	if not self.masterLooter then return end -- Didn't find a leader or ML.
	if self:UnitIsUnit(old_ml, self.masterLooter) then
		if old_lm == self.lootMethod then return end -- Both ML and loot method have not changed
	else
		-- At this point we know the ML has changed, so we can wipe the council
		self:Debug("Resetting council as we have a new ML!")
		self.council = {}
		self.mldb = {}
		self.isCouncil = false
		self:Debug("MasterLooter = ", self.masterLooter)
		-- Check to see if we have recieved mldb within 15 secs, otherwise request it
		self:ScheduleTimer("Timer", 15, "MLdb_check")
	end

	if not self.isMasterLooter then -- Someone else has become ML
		return
	else
		self:CallModule("masterlooter")
		self:GetActiveModule("masterlooter"):NewML(self.masterLooter)
	end
	-- Check if we can use in party
	if not IsInRaid() and db.onlyUseInRaids then return end

	-- Don't do popups if we're already handling loot
	if self.handleLoot then return end

	-- Don't do pop-ups in pvp
	local _, type = IsInInstance()
	if type == "arena" or type == "pvp" then return end

	-- We are ML and shouldn't ask the player for usage
	if self.lootMethod == "master" and db.usage.ml then -- addon should auto start
		self:StartHandleLoot("masterloot")
	-- We're ML and must ask the player for usage
	elseif self.lootMethod == "master" and db.usage.ask_ml then
		return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")
	elseif self.lootMethod == "personalloot" and db.usage.pl then -- auto start PL
		self:StartHandleLoot("personalloot")
	elseif self.lootMethod == "personalloot" and db.usage.ask_pl then
		return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")
	end
end

--- Enables the addon to automatically handle looting
-- @param method The loot method. Pre BfA this will be either "masterloot" or "personalloot".
-- REVIEW: This should only handle Personal Loot in BFA.
function RCLootCouncil:StartHandleLoot(method)
	--if not self.isMasterLooter or db.usage.never then return end -- Someone else has become ML or we don't want to handle loot
	local lootMethod = GetLootMethod()
	if method == "masterloot" then
		if lootMethod ~= "master" and not self:CanSetML() then return end -- Cant handle loot if we cant use ML loot method.
		if lootMethod ~= "master" then
			SetLootMethod("master", self.Ambiguate(self.playerName)) -- activate ML
			self:Print(L[" you are now the Master Looter and RCLootCouncil is now handling looting."])
		else
			self:Print(L["Now handles looting"])
		end

		if db.autoAward and GetLootThreshold() ~= 2 and GetLootThreshold() > db.autoAwardLowerThreshold  then
			self:Print(L["Changing loot threshold to enable Auto Awarding"])
			SetLootThreshold(db.autoAwardLowerThreshold >= 2 and db.autoAwardLowerThreshold or 2)
		end
	else -- Personal Loot
		if lootMethod ~= "personalloot" then -- Set it
			SetLootMethod("personalloot")
		end
		self:Print(L["Now handles looting"])
	end
	self:Debug("Start handle loot.")
	self.handleLoot = true
	if #db.council == 0 then -- if there's no council
		self:Print(L["You haven't set a council! You can edit your council by typing '/rc council'"])
	end
end

function RCLootCouncil:OnRaidEnter(arg)
	-- NOTE: We shouldn't need to call GetML() as it's most likely called on "LOOT_METHOD_CHANGED"
	-- There's no ML, and lootmethod ~= ML, but we are the group leader
	if IsPartyLFG() or db.usage.never then return end	-- We can't use in lfg/lfd so don't bother
	-- Check if we can use in party
	if not IsInRaid() and db.onlyUseInRaids then return end
	if self.lootMethod ~= "master" and self:CanSetML() then
		-- We don't need to ask the player for usage, so change loot method to master, and make the player ML
		self.handleLoot = false -- Reset

		if db.usage.leader then
			self:StartHandleLoot("masterloot")
		-- We must ask the player for usage
		elseif db.usage.ask_leader then
			return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")
		end
	end
end

--- Gets information about the current Master Looter, if any.
-- @return boolean, "ML_Name". (true if the player is ML), (nil if there's no ML).
function RCLootCouncil:GetML()
	self:DebugLog("GetML()")
	if IsPartyLFG() then return false, nil	end -- Never use in LFG
	if GetNumGroupMembers() == 0 and (self.testMode or self.nnp) then -- always the player when testing alone
		return true, self.playerName
	end
	local lootMethod, mlPartyID, mlRaidID = GetLootMethod()
	self:Debug("LootMethod = ", lootMethod)
	local name;
	if lootMethod == "master" then
		if mlRaidID then 				-- Someone in raid
			name = self:UnitName("raid"..mlRaidID)
		elseif mlPartyID == 0 then -- Player in party
			name = self.playerName
		elseif mlPartyID then		-- Someone in party
			name = self:UnitName("party"..mlPartyID)
		end
		return IsMasterLooter(), name
	else -- Set the Group leader as the ML if the loot method is not master loot
		for i=1, GetNumGroupMembers() or 0 do
			local name2, rank = GetRaidRosterInfo(i)
			if not name2 then -- Group info is not completely ready
				return false, "Unknown"
			end
			if rank == 2 then -- Group leader. Btw, name2 can be nil when rank is 2.
				name = self:UnitName(name2)
			end
		end
		if name then
			return UnitIsGroupLeader("player"), name
		end
	end
	return false, nil;
end

-- Whether or not the player can set master looter
function RCLootCouncil:CanSetML()
	-- Code is from FrameXML/UnitPopup.lua
	local inInstance, instanceType = IsInInstance();
	local isLeader = UnitIsGroupLeader("player")
	return (IsInRaid() or (inInstance and instanceType == "raid")) and isLeader and not HasLFGRestrictions() and IsInGuildGroup();
end

function RCLootCouncil:IsCouncil(name)
	local ret = tContains(self.council, self:UnitName(name))
	if self:UnitIsUnit(name, self.playerName) and self.isMasterLooter
	 or self.nnp or self:UnitIsUnit(name, self.masterLooter) then ret = true end -- ML and nnp is always council
	self:DebugLog(tostring(ret).." =", "IsCouncil", name)
	return ret
end

function RCLootCouncil:GetInstalledModulesFormattedData()
	local modules = {}
	-- We're interested in everything that isn't a default module
	local test = function(name)
		for _, k in pairs(defaultModules) do
			if k == name then return true end
		end
	end
	for k in pairs(self.modules) do
		if not test(k) then tinsert(modules, k) end
	end
	-- Now for the formatting
	for num, name in pairs(modules) do
		if self:GetModule(name).version then -- People might not have added version
			modules[num] = self:GetModule(name).baseName.. " - "..self:GetModule(name).version
			if self:GetModule(name).tVersion then
				modules[num] = modules[num].."-"..self:GetModule(name).tVersion
			end
		else
			modules[num] = self:GetModule(name).baseName.. " - ".._G.UNKNOWN
		end
	end
	return modules
end


--- Returns statistics for use in various detailed views.
-- @return A table formatted as:
--[[ @usage lootDBStatistics[candidate_name] = {
	[item#] = { -- 5 latest items won
		[1] = lootWon,
		[2] = formatted response string,
		[3] = {color}, --see color format in self.responses
		[4] = #index, 	-- Real entry index in historyDB[name][index]
	},
	totals = {
		total = total loot won number,
		tokens = {
			instanceName = { -- E.g Nighthold-Heroic
				num = numTokensReceived,
				mapID = mapID,
				difficultyID = difficultyID,
		},
		responses = {
			[i] = {
				[1] = responseText,
				[2] = number of items won,
				[3] = {color},
				[4] = responseID, -- see index in self.responses. Award reasons gets 100 addded. TierResponses gets 200 added. Relic 300.
			}
		},
		raids = {
			-- Each index is a unique raid ID made by combining the date and instance
			[xxx] = number of loot won in this raid,
			num = the number of raids
		}
	}
}
]]
local lootDBStatistics
function RCLootCouncil:GetLootDBStatistics()
	self:DebugLog("GetLootDBStatistics()")
	-- v2.4: This is very sensitive to errors in the loot history, which will most likely crash calling modules,
	-- as in ticket #261. For the sole reason of crash proofing, let's catch any errors:
	local check, ret = pcall(function()
		lootDBStatistics = {}
		local entry, id
		for name, data in pairs(self:GetHistoryDB()) do
			local count, responseText, color, numTokens, raids = {},{},{},{},{}
			local lastestAwardFound = 0
			lootDBStatistics[name] = {}
			for i = #data, 1, -1 do -- Start from the end
				entry = data[i]
				id = entry.responseID
				if type(id) == "number" then -- ID may be string, e.g. "PASS"
					if entry.isAwardReason then id = id + 100 end -- Bump to distingush from normal awards
					if entry.tokenRoll then id = id + 200 end
					if entry.relicRoll then id = id + 300 end
				end
				-- We assume the mapID and difficultyID is available on any item if at all.
				if not numTokens[entry.instance] then numTokens[entry.instance] = {num = 0, mapID = entry.mapID, difficultyID = entry.difficultyID} end
				if entry.tierToken then -- If it's a tierToken, increase the count
					numTokens[entry.instance].num = numTokens[entry.instance].num + 1
				end
				count[id] = count[id] and count[id] + 1 or 1
				responseText[id] = responseText[id] and responseText[id] or entry.response
				if (not color[id] or unpack(color[id],1,3) == unpack{1,1,1}) and (entry.color and #entry.color ~= 0)  then -- If it's not already added
					color[id] = #entry.color ~= 0 and #entry.color == 4 and entry.color or {1,1,1}
				end
				if lastestAwardFound < 5 and type(id) == "number" and not entry.isAwardReason
				 	and (id <= db.numMoreInfoButtons or (entry.tokenRoll and id - 200 <= db.numMoreInfoButtons)
							or (entry.relicRoll and id - 300 <= db.numMoreInfoButtons)) then
					tinsert(lootDBStatistics[name], {entry.lootWon, --[[entry.response .. ", "..]] format(L["'n days' ago"], self:ConvertDateToString(self:GetNumberOfDaysFromNow(entry.date))), color[id], i})
					lastestAwardFound = lastestAwardFound + 1
				end
				-- Raids:
				raids[entry.date..entry.instance] = raids[entry.date..entry.instance] and raids[entry.date..entry.instance] + 1 or 0
			end
			-- Totals:
			local totalNum = 0
			lootDBStatistics[name].totals = {}
			lootDBStatistics[name].totals.tokens = numTokens
			lootDBStatistics[name].totals.responses = {}
			for id, num in pairs(count) do
				tinsert(lootDBStatistics[name].totals.responses, {responseText[id], num, color[id], id})
				totalNum = totalNum + num
			end
			lootDBStatistics[name].totals.total = totalNum
			lootDBStatistics[name].totals.raids = raids
			totalNum = 0
			for _ in pairs(raids) do totalNum = totalNum + 1 end
			lootDBStatistics[name].totals.raids.num = totalNum
		end
		return lootDBStatistics
	end)
	if not check then
		self:DebugLog(ret)
		self:Print("Something's wrong in your loot history. Please contact the author.")
	else
		return ret
	end
end

function RCLootCouncil:SessionError(...)
	self:Print(L["session_error"])
	self:Debug(...)
end

function RCLootCouncil:Getdb()
	return db
end

function RCLootCouncil:GetHistoryDB()
	return self.lootDB.factionrealm
end

function RCLootCouncil:UpdateDB()
	db = self.db.profile
	self.db:RegisterDefaults(self.defaults)
	self:SendMessage("RCUpdateDB")
end
function RCLootCouncil:UpdateHistoryDB()
	historyDB = self:GetHistoryDB()
end

function RCLootCouncil:GetAnnounceChannel(channel)
	return channel == "group" and (IsInRaid() and "RAID" or "PARTY") or channel
end

function RCLootCouncil:GetItemIDFromLink(link)
	return tonumber(strmatch(link or "", "item:(%d+):"))
end

function RCLootCouncil:GetItemStringFromLink(link)
	return strmatch(link or "", "(item:.-):*|h") -- trim trailing colons
end

function RCLootCouncil:GetItemNameFromLink(link)
	return strmatch(link or "", "%[(.+)%]")
end

-- The link of same item generated from different players, or if two links are generated between player spec switch, are NOT the same
-- This function compares link with link level and spec ID removed.
-- Also compare with unique id removed, because wowpedia says that:
-- "In-game testing indicates that the UniqueId can change from the first loot to successive loots on the same item."
-- Although log shows item in the loot actually has no uniqueId in Legion, but just in case Blizzard changes it in the future.
-- @return true if two items are the same item
function RCLootCouncil:ItemIsItem(item1, item2)
	if type(item1) ~= "string" or type(item2) ~= "string" then return item1 == item2 end
	local pattern = "|Hitem:(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):%d*:%d*:%d*"
	local replacement = "|Hitem:%1:%2:%3:%4:%5:%6:%7:::" -- Compare link with uniqueId, linkLevel and SpecID removed
	return item1:gsub(pattern, replacement) == item2:gsub(pattern, replacement)
end

--@param links. Table of strings. Any link in the table can contain connected links (links without space in between)
--@return a list of links that contains all splitted item links
function RCLootCouncil:SplitItemLinks(links)
	local result = {}
	for _, connected in ipairs(links) do
		local startPos, endPos = 1, nil
		while (startPos) do
			if connected:sub(1, 2) == "|c" then
				startPos, endPos = connected:find("|c.-|r", startPos)
			elseif connected:sub(1, 2) == "|H" then
				startPos, endPos = connected:find("|H.-|h.-|h", startPos)
			else
				startPos = nil
			end
			if startPos then
				tinsert(result, connected:sub(startPos, endPos))
				startPos = startPos + 1
			end
		end
	end
	return result
end

function RCLootCouncil.round(num, decimals)
	if type(num) ~= "number" then return "" end
	return tonumber(string.format("%." .. (decimals or 0) .. "f", num))
end

--- Compares two versions.
-- Assumes strings of format "x.y.z".
-- @return True if ver1 is older than ver2, otherwise false.
function RCLootCouncil:VersionCompare(ver1, ver2)
	if not ver1 or not ver2 then return end
	local a1,b1,c1 = string.split(".", ver1)
	local a2,b2,c2 = string.split(".", ver2)
	if not (c1 and c2) then return end -- Check if it exists
	if a1 ~= a2 then return  tonumber(a1) < tonumber(a2) elseif b1 ~= b2 then return tonumber(b1) < tonumber(b2) else return tonumber(c1) < tonumber(c2) end
end

-- from LibUtilities-1.0, which adds bonus index after bonus ID
-- therefore a patched version is reproduced here
-- replace with LibUtilities when bug is fixed
function RCLootCouncil:DecodeItemLink(itemLink)
    local bonusIDs = {}

    local linkType, itemID, enchantID, gemID1, gemID2, gemID3, gemID4, suffixID, uniqueID, linkLevel, specializationID,
	 upgradeTypeID, instanceDifficultyID, numBonuses, affixes = string.split(":", itemLink, 15)

	 -- clean it up
    local color = string.match(linkType, "|?c?f?f?(%x*)")
    linkType = string.gsub(linkType, "|?c?f?f?(%x*)|?H?", "")
    itemID = tonumber(itemID) or 0
    enchantID = tonumber(enchantID) or 0
    gemID1 = tonumber(gemID1) or 0
    gemID2 = tonumber(gemID2) or 0
    gemID3 = tonumber(gemID3) or 0
    gemID4 = tonumber(gemID4) or 0
    suffixID = tonumber(suffixID) or 0
    uniqueID = tonumber(uniqueID) or 0
    linkLevel = tonumber(linkLevel) or 0
    specializationID = tonumber(specializationID) or 0
    upgradeTypeID = tonumber(upgradeTypeID) or 0
    instanceDifficultyID = tonumber(instanceDifficultyID) or 0
    numBonuses = tonumber(numBonuses) or 0

    if numBonuses >= 1 then
        for i = 1, numBonuses do
            local bonusID = select(i, string.split(":", affixes))
            table.insert(bonusIDs, tonumber(bonusID))
        end
    end

    -- more clean up
	 local upgradeID
	 if affixes then
	    upgradeID = select(numBonuses + 1, string.split(":", affixes)) or 0
	    upgradeID = string.match(upgradeID, "%d*")
	    upgradeID = tonumber(upgradeID) or 0
	 end

    return color, linkType, itemID, enchantID, gemID1, gemID2, gemID3, gemID4, suffixID, uniqueID, linkLevel,
	 		specializationID, upgradeTypeID, upgradeID, instanceDifficultyID, numBonuses, bonusIDs
end

--- Custom, better UnitIsUnit() function.
-- Blizz UnitIsUnit() doesn't know how to compare unit-realm with unit.
-- Seems to be because unit-realm isn't a valid unitid.
function RCLootCouncil:UnitIsUnit(unit1, unit2)
	if not unit1 or not unit2 then return false end
	-- Remove realm names, if any
	if strfind(unit1, "-", nil, true) ~= nil then
		unit1 = Ambiguate(unit1, "short")
	end
	if strfind(unit2, "-", nil, true) ~= nil then
		unit2 = Ambiguate(unit2, "short")
	end
	-- v2.3.3 There's problems comparing non-ascii characters of different cases using UnitIsUnit()
	-- I.e. UnitIsUnit("Potdisc", "potdisc") works, but UnitIsUnit("Æver", "æver") doesn't.
	-- Since I can't find a way to ensure consistant returns from UnitName(), just lowercase units here before passing them.
	return UnitIsUnit(unit1:lower(), unit2:lower())
end

--[[ NOTE I'm concerned about the UnitIsVisible() range thing with UnitName(),
although testing in party doesn't seem to affect it. To counter this, it'll
return any "unit" with something after a "-" (i.e a name from GetRaidRosterInfo())
which means it isn't useable with all the "name-target" unitIDs]]
--- Gets a unit's name formatted with realmName.
-- If the unit contains a '-' it's assumed it belongs to the realmName part.
-- Note: If 'unit' is a playername, that player must be in our raid or party!
-- @param unit Any unit, except those that include '-' like "name-target".
-- @return Titlecased "unitName-realmName"
function RCLootCouncil:UnitName(unit)
	-- First strip any spaces
	unit = gsub(unit, " ", "")
	-- Then see if we already have a realm name appended
	local find = strfind(unit, "-", nil, true)
	if find and find < #unit then -- "-" isn't the last character
		-- Let's give it same treatment as below so we're sure it's the same
		local name, realm = strsplit("-", unit, 2)
		name = name:lower():gsub("^%l", string.upper)
		return name.."-"..realm
	end
	-- Apparently functions like GetRaidRosterInfo() will return "real" name, while UnitName() won't
	-- always work with that (see ticket #145). We need this to be consistant, so just lowercase the unit:
	unit = unit:lower()
	-- Proceed with UnitName()
	local name, realm = UnitName(unit)
	if not realm or realm == "" then realm = self.realmName end -- Extract our own realm
	if not name then return nil end -- Below won't work without name
	-- We also want to make sure the returned name is always title cased (it might not always be! ty Blizzard)
	name = name:lower():gsub("^%l", string.upper)
	return name and name.."-"..realm
end

---------------------------------------------------------------------------
-- Custom module support funcs.
-- @section Modules.
---------------------------------------------------------------------------

--- Enables a userModule if set, defaultModule otherwise.
-- @paramsig module
-- @param module String, must correspond to a index in self.defaultModules.
function RCLootCouncil:CallModule(module)
	if not self.enabled then return end -- Don't call modules unless enabled
	self:EnableModule(userModules[module] or defaultModules[module])
end

--- Returns the active module.
--	Always use this when calling functions in another module.
-- @paramsig module
-- @param module String, must correspond to a index in self.defaultModules.
-- @return The module object of the active module or nil if not found. Prioritises userModules if set.
function RCLootCouncil:GetActiveModule(module)
	return self:GetModule(userModules[module] or defaultModules[module], false)
end

--- Registers a module that should override a default module.
-- The custom module must have all functions that a default module can be called with.
-- @paramsig type, name
-- @param type Index (string) in userModules.
-- @param name The name passed to AceAddon:NewModule().
function RCLootCouncil:RegisterUserModule(type, name)
	assert(defaultModules[type], format("Module \"%s\" is not a default module.", tostring(type)))
	userModules[type] = name
end

-- FIXME DEPRECATED in v2.7.6
function RCLootCouncil:CustomChatCmd(module, funcRef, helpString, ...)
	for i = 1, select("#", ...) do
		self.customChatCmd[select(i, ...)] = {module = module, func = funcRef}
	end
	tinsert(self.chatCmdHelp, {desc = helpString, module = module})
end

--- Enables a module to add chat commands to the "/rc" prefix.
-- @paramsig module, funcRef, cmdDesc, desc, ...
-- @param module 	The object to call func on.
-- @param funcRef The function reference to call on module. Passed with module as first arg, followed by user provided args.
-- @param cmdDesc	A description of the command - added before desc in the help string. If omitted, then the first command will be used instead.
-- @param desc 	A string shown if the user types /rc help or an invalid command
-- @param ... 		The command(s) the user can input. The first is shown with the help string
-- @usage
-- -- For example in GroupGear:
-- RCLootCouncil:ModuleChatCmd(GroupGear, "Show", nil, "Show the GroupGear window (alt. 'groupgear' or 'gear')", "gg", "groupgear", "gear")
-- -- will result in GroupGear:Show() being called if the user types "/rc gg" (or "/rc groupgear" or "/rc gear")
-- -- "/rc help" will get "gg: Show the GroupGear window (alt. 'groupgear' or 'gear')" added.
function RCLootCouncil:ModuleChatCmd(module, funcRef, cmdDesc, desc, ...)
	for i = 1, select("#", ...) do
		self.customChatCmd[select(i, ...)] = {module = module, func = funcRef}
	end
	if cmdDesc then
		tinsert(self.chatCmdHelp, {cmd = cmdDesc, desc = desc, module = module})
	else
		tinsert(self.chatCmdHelp, {cmd = select(1, ...), desc = desc, module = module})
	end
end

--#end Module support -----------------------------------------------------


---------------------------------------------------------------------------
-- UI Functions used throughout the addon.
-- @section UI.
---------------------------------------------------------------------------

--- Used as a "DoCellUpdate" function for lib-st
function RCLootCouncil.SetCellClassIcon(rowFrame, frame, data, cols, row, realrow, column, fShow, table, class)
	local celldata = data and (data[realrow].cols and data[realrow].cols[column] or data[realrow][column])
	local class = celldata and celldata.args and celldata.args[1] or class
	if class then
		frame:SetNormalTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"); -- this is the image containing all class icons
		local coords = CLASS_ICON_TCOORDS[class]; -- get the coordinates of the class icon we want
		frame:GetNormalTexture():SetTexCoord(unpack(coords)); -- cut out the region with our class icon according to coords
	else -- if there's no class
		frame:SetNormalTexture("Interface/ICONS/INV_Sigil_Thorim.png")
	end
end

--- Returns a color table for use with lib-st
-- @param class Global class name, i.e. "PRIEST"
function RCLootCouncil:GetClassColor(class)
	local color = RAID_CLASS_COLORS[class]
	if not color then
		-- if class not found, return epic color.
		return {r=1,g=1,b=1,a=1}--{["r"] = 0.63921568627451, ["g"] = 0.2078431372549, ["b"] = 0.93333333333333, ["a"] = 1.0 };
	else
		color.a = 1.0
		return color
	end
end

function RCLootCouncil:GetUnitClassColoredName(name)
	if self.candidates[name] and self.candidates[name].class then
		local c = self:GetClassColor(self.candidates[name].class)
		return "|cff"..self:RGBToHex(c.r,c.g,c.b)..self.Ambiguate(name).."|r"
	else
		local englishClass = select(2, UnitClass(Ambiguate(name, "short")))
		name = self:UnitName(name)
		if not englishClass or not name then
			return self.Ambiguate(name)
		else
			local color = RAID_CLASS_COLORS[englishClass].colorStr
			return "|c"..color..self.Ambiguate(name).."|r"
		end
	end
end

function RCLootCouncil:RGBToHex(r,g,b)
	return string.format("%02x%02x%02x",255*r, 255*g, 255*b)
end

--- Creates a standard frame for RCLootCouncil with title, minimizing, positioning and scaling supported.
--		Adds Minimize(), Maximize() and IsMinimized() functions on the frame, and registers it for hide on combat.
--		SetWidth/SetHeight called on frame will also be called on frame.content.
--		Minimizing is done by double clicking the title. The returned frame and frame.title is NOT hidden.
-- 	Only frame.content is minimized, so put children there for minimize support.
-- @paramsig name, cName, title[, width, height]
-- @param name Global name of the frame.
-- @param cName Name of the module (used for lib-window-1.1 config in db.UI[cName]).
-- @param title The title text.
-- @param width The width of the titleframe, defaults to 250.
-- @param height Height of the frame, defaults to 325.
-- @return The frame object.
function RCLootCouncil:CreateFrame(name, cName, title, width, height)
	local f = CreateFrame("Frame", name, UIParent) -- LibWindow seems to work better with nil parent
	f:Hide()
	f:SetFrameStrata("DIALOG")
	f:SetWidth(450)
	f:SetHeight(height or 325)
	f:SetScale(db.UI[cName].scale or 1.1)
	lwin:Embed(f)
	f:RegisterConfig(db.UI[cName])
	f:RestorePosition() -- might need to move this to after whereever GetFrame() is called
	f:MakeDraggable()
	f:SetScript("OnMouseWheel", function(f,delta) if IsControlKeyDown() then lwin.OnMouseWheel(f,delta) end end)

	local tf = CreateFrame("Frame", nil, f)
	--tf:SetFrameStrata("DIALOG")
	tf:SetToplevel(true)
	tf:SetBackdrop({
	   --   bgFile = AceGUIWidgetLSMlists.background[db.UI.default.background],
	   --   edgeFile = AceGUIWidgetLSMlists.border[db.UI.default.border],
		bgFile = AceGUIWidgetLSMlists.background[db.skins[db.currentSkin].background],
		edgeFile = AceGUIWidgetLSMlists.border[db.skins[db.currentSkin].border],
	     tile = true, tileSize = 64, edgeSize = 12,
	     insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	tf:SetBackdropColor(unpack(db.skins[db.currentSkin].bgColor))
	tf:SetBackdropBorderColor(unpack(db.skins[db.currentSkin].borderColor))
	tf:SetHeight(22)
	tf:EnableMouse()
	tf:SetMovable(true)
	tf:SetWidth(width or 250)
	tf:SetPoint("CENTER",f,"TOP",0,-1)
	tf:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
	tf:SetScript("OnMouseUp", function(self) -- Get double click by trapping time betweem mouse up
		local frame = self:GetParent()
		frame:StopMovingOrSizing()
		if frame:GetScale() and frame:GetLeft() and frame:GetRight() and frame:GetTop() and frame:GetBottom() then
			frame:SavePosition() -- LibWindow SavePosition has nil error rarely and randomly and I cant really find the root cause. Let's just do a nil check.
		end
		if self.lastClick and GetTime() - self.lastClick <= 0.5 then
			self.lastClick = nil
			if frame.minimized then frame:Maximize() else frame:Minimize() end
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
		  --   bgFile = AceGUIWidgetLSMlists.background[db.UI.default.background],
  	   --   edgeFile = AceGUIWidgetLSMlists.border[db.UI.default.border],
		bgFile = AceGUIWidgetLSMlists.background[db.skins[db.currentSkin].background],
		edgeFile = AceGUIWidgetLSMlists.border[db.skins[db.currentSkin].border],
	   tile = true, tileSize = 64, edgeSize = 12,
	   insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	c:EnableMouse(true)
	c:SetWidth(450)
	c:SetHeight(height or 325)
	c:SetBackdropColor(unpack(db.skins[db.currentSkin].bgColor))
	c:SetBackdropBorderColor(unpack(db.skins[db.currentSkin].borderColor))
	c:SetPoint("TOPLEFT")
	c:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
	c:SetScript("OnMouseUp", function(self)
		local frame = self:GetParent()
		frame:StopMovingOrSizing()
		if frame:GetScale() and frame:GetLeft() and frame:GetRight() and frame:GetTop() and frame:GetBottom() then
			frame:SavePosition() -- LibWindow SavePosition has nil error rarely and randomly and I cant really find the root cause. Let's just do a nil check.
		end
	end)
	f.content = c
	f.minimized = false
	f.IsMinimized = function(frame) return frame.minimized end
	f.Minimize = function(frame)
		self:Debug("Minimize()")
		if not frame.minimized then
		  	frame.content:Hide()
			frame.minimized = true
		end
	end
	f.Maximize = function(frame)
		self:Debug("Maximize()")
		if frame.minimized then
		  	frame.content:Show()
			frame.minimized = false
		end
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
		old_setheight(self, height)
		self.content:SetHeight(height)
	end
	f.Update = function(self)
		RCLootCouncil:Debug("UpdateFrame", self:GetName())
		self.content:SetBackdrop({
			bgFile = AceGUIWidgetLSMlists.background[db.UI[cName].background],
			edgeFile = AceGUIWidgetLSMlists.border[db.UI[cName].border],
			tile = false, tileSize = 64, edgeSize = 12,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		self.title:SetBackdrop({
			bgFile = AceGUIWidgetLSMlists.background[db.UI[cName].background],
			edgeFile = AceGUIWidgetLSMlists.border[db.UI[cName].border],
			tile = false, tileSize = 64, edgeSize = 12,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		self.content:SetBackdropColor(unpack(db.UI[cName].bgColor))
		self.content:SetBackdropBorderColor(unpack(db.UI[cName].borderColor))
		self.title:SetBackdropColor(unpack(db.UI[cName].bgColor))
		self.title:SetBackdropBorderColor(unpack(db.UI[cName].borderColor))
	end
	return f
end

-- cName is name of the module
function RCLootCouncil:CreateGameTooltip(cName, parent)
	local itemTooltip = CreateFrame("GameTooltip", cName.."_ItemTooltip", parent, "GameTooltipTemplate")
	itemTooltip:SetClampedToScreen(false)
	itemTooltip:SetScale(parent and parent:GetScale()*.95 or 1) -- Don't use parent scale
	-- Some addons hook GameTooltip. So copy the hook.
	-- itemTooltip:SetScript("OnTooltipSetItem", GameTooltip:GetScript("OnTooltipSetItem"))

 	itemTooltip.shoppingTooltips = {} -- GameTooltip contains this table. Need this to prevent error
 	itemTooltip.shoppingTooltips[1] = CreateFrame("GameTooltip", cName.."_ShoppingTooltip1", itemTooltip, "ShoppingTooltipTemplate")
 	itemTooltip.shoppingTooltips[2] = CreateFrame("GameTooltip", cName.."_ShoppingTooltip2", itemTooltip, "ShoppingTooltipTemplate")
	return itemTooltip
end

--- Update all frames registered with RCLootCouncil:CreateFrame().
-- Updates all the frame's colors as set in the db.
function RCLootCouncil:UpdateFrames()
	for _, frame in pairs(frames) do
		frame:Update()
	end
end

--- Applies a skin to all frames
-- Skins must be added to the db.skins table first.
-- @param key Index in db.skins.
function RCLootCouncil:ActivateSkin(key)
	self:Debug("ActivateSkin", key)
	if not db.skins[key] then return end
	for k,v in pairs(db.UI) do
		v.bgColor = {unpack(db.skins[key].bgColor)}
		v.borderColor = {unpack(db.skins[key].borderColor)}
		v.background = db.skins[key].background
		v.border = db.skins[key].border
	end
	db.currentSkin = key
	self:UpdateFrames()
end

--- Creates a standard button for RCLootCouncil.
-- @param text The button's text.
-- @param parent The frame that should hold the button.
-- @return The button object.
function RCLootCouncil:CreateButton(text, parent)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetText(text)
	b:SetSize(100,25)
	return b
end

--- Displays a tooltip anchored to the mouse.
-- @paramsig ...
-- @param ... string(s) Lines to be added.
function RCLootCouncil:CreateTooltip(...)
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	for i = 1, select("#", ...) do
		GameTooltip:AddLine(select(i, ...),1,1,1)
	end
	GameTooltip:Show()
end

--- Displays a hyperlink tooltip.
-- @paramsig link
-- @param link The link to display.
function RCLootCouncil:CreateHypertip(link)
	if not link or link == "" then return end
	local function tip() -- Implement shift click compare on all tooltips
		local tip = CreateFrame("GameTooltip", "RCLootCouncil_TooltipEventHandler", UIParent, "GameTooltipTemplate")
		tip:RegisterEvent("MODIFIER_STATE_CHANGED")
		tip:SetScript("OnEvent", function(this, event, arg)
			if self.tooltip.showing and event == "MODIFIER_STATE_CHANGED" and (arg == "LSHIFT" or arg == "RSHIFT") and self.tooltip.link then
				self:CreateHypertip(self.tooltip.link) -- Recall to recreate
			end
		end)
		return tip
	end
	if not self.tooltip then self.tooltip = tip() end
	self.tooltip.showing = true
	self.tooltip.link = link
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	GameTooltip:SetHyperlink(link)
end

--- Hide the tooltip created with :CreateTooltip()
function RCLootCouncil:HideTooltip()
	if self.tooltip then
		self.tooltip.showing = false
	end
	GameTooltip:Hide()
end

function RCLootCouncil:GetItemTextWithCount(link, count)
	return link..(count and count > 1 and (" x"..count) or "")
end

function RCLootCouncil:GetItemLevelText(ilvl, token)
	if not ilvl then return "" end
	if token and ilvl > 600 then -- Armor token warforged is introduced since WoD
		return ilvl.."+"
	else
		return ilvl
	end
end

local itemStatsRet = {}
-- Get item bonus text (socket, leech, etc)
-- Item needs to be cached.
function RCLootCouncil:GetItemBonusText(link, delimiter)
	if not delimiter then delimiter = "/" end
	wipe(itemStatsRet)
	GetItemStats(link, itemStatsRet)
	local text = ""
	for k, _ in pairs(itemStatsRet) do
		if k:find("SOCKET") then
			text = L["Socket"]
			break
		end
	end

	if itemStatsRet["ITEM_MOD_CR_AVOIDANCE_SHORT"] then
		if text ~= "" then text = text..delimiter end
		text = text.._G.ITEM_MOD_CR_AVOIDANCE_SHORT
	end
	if itemStatsRet["ITEM_MOD_CR_LIFESTEAL_SHORT"] then
		if text ~= "" then text = text..delimiter end
		text = text.._G.ITEM_MOD_CR_LIFESTEAL_SHORT
	end
	if itemStatsRet["ITEM_MOD_CR_SPEED_SHORT"] then
		if text ~= "" then text = text..delimiter end
		text = text.._G.ITEM_MOD_CR_SPEED_SHORT
	end
	if itemStatsRet["ITEM_MOD_CR_STURDINESS_SHORT"] then -- Indestructible
		if text ~= "" then text = text..delimiter end
		text = text.._G.ITEM_MOD_CR_STURDINESS_SHORT
	end

	return text
end

-- @return a text of the link explaining its type. For example, "Fel Artifact Relic", "Chest, Mail"
function RCLootCouncil:GetItemTypeText(link, subType, equipLoc, typeID, subTypeID, classesFlag, tokenSlot, relicType)
	local id = self:GetItemIDFromLink(link)

	if tokenSlot then -- It's a token
		local tokenText = L["Armor Token"]
		if bit.band(classesFlag, 0x112) == 0x112 then
			tokenText = L["Conqueror Token"]
		elseif bit.band(classesFlag, 0x45) == 0x45 then
			tokenText = L["Protector Token"]
		elseif bit.band(classesFlag, 0x488) == 0x488 then
			tokenText = L["Vanquisher Token"]
		end

		if equipLoc == "" then
			equipLoc = self:GetTokenEquipLoc(tokenSlot)
		end

		if equipLoc ~= "" and getglobal(equipLoc) then
			return getglobal(equipLoc)..", "..tokenText
		else
			return tokenText
		end
	elseif self:IsRelicTypeID(typeID, subTypeID) then
		relicType = relicType or select(3, C_ArtifactUI.GetRelicInfoByItemID(id)) or ""
		local localizedRelicType = getglobal("RELIC_SLOT_TYPE_" .. relicType:upper()) or ""
		local relicTooltipName = format(RELIC_TOOLTIP_TYPE, localizedRelicType)
		return relicTooltipName
	elseif equipLoc ~= "" and getglobal(equipLoc) then
		if equipLoc == "INVTYPE_TRINKET" then
			local lootSpec = _G.RCTrinketSpecs[id]
			local category = lootSpec and _G.RCTrinketCategories[lootSpec]
			if category then
				return getglobal(equipLoc).." ("..category..")"
			else
				return getglobal(equipLoc)
			end
		elseif equipLoc ~= "INVTYPE_CLOAK" and
				((not (typeID == LE_ITEM_CLASS_MISCELLANEOUS and subTypeID == LE_ITEM_MISCELLANEOUS_JUNK)) -- subType: "Junk"
				and (not (typeID == LE_ITEM_CLASS_ARMOR and subTypeID == LE_ITEM_ARMOR_GENERIC)) -- subType: "Miscellaneous"
				and (not (typeID == LE_ITEM_CLASS_WEAPON and subTypeID == LE_ITEM_WEAPON_GENERIC))) then -- subType: "Miscellaneous"
					return getglobal(equipLoc)..", "..(subType or "") -- getGlobal to translate from global constant to localized name
		else
			return getglobal(equipLoc)
		end
	else
		return subType or ""
	end
end

--- Formats a name with or without realmName.
-- @paramsig name
-- @param name Name with(out) realmname.
-- @return The name, with(out) realmname according to user options.
function RCLootCouncil.Ambiguate(name)
	return db.ambiguate and Ambiguate(name, "none") or Ambiguate(name, "short")
end

--- Returns the text of a button, returning settings from mldb if possible, otherwise from default buttons.
-- @paramsig index [, isTier, isRelic]
-- @param index The button's index.
-- @param isTier True if the response belongs to a tier item.
-- @param isRelic True if the response belongs to a relic item.
function RCLootCouncil:GetButtonText(i, isTier, isRelic)
	if isTier and self.mldb.tierButtonsEnabled and type(i) == "number" then -- Non numbers is status texts, handled as normal response
		return (self.mldb.tierButtons and self.mldb.tierButtons[i]) and self.mldb.tierButtons[i].text or db.tierButtons[i].text
	elseif isRelic and self.mldb.relicButtonsEnabled and type(i) == "number" then
		return (self.mldb.relicButtons and self.mldb.relicButtons[i]) and self.mldb.relicButtons[i].text or db.relicButtons[i].text
	else
		return (self.mldb.buttons and self.mldb.buttons[i]) and self.mldb.buttons[i].text or db.buttons[i].text
	end
end

--- The following functions returns the text, sort or color of a response, returning a result from mldb if possible, otherwise from the default responses.
-- @paramsig response [, isTier, isRelic]
-- @param response Index in db.responses.
-- @param isTier True if the response belongs to a tier item.
-- @param isRelic True if the response belongs to a relic item.
function RCLootCouncil:GetResponseText(response, isTier, isRelic)
	local ret
	if isTier and self.mldb.tierButtonsEnabled and type(response) == "number" then
		ret = (self.mldb.responses.tier and self.mldb.responses.tier[response]) and self.mldb.responses.tier[response].text or db.responses.tier[response].text
	elseif isRelic and self.mldb.relicButtonsEnabled and type(response) == "number" then
		ret = (self.mldb.responses.relic and self.mldb.responses.relic[response]) and self.mldb.responses.relic[response].text or db.responses.relic[response].text
	else
		ret = (self.mldb.responses and self.mldb.responses[response]) and self.mldb.responses[response].text or db.responses[response].text
	end
	return ret or db.responses.DEFAULT.text
end

---
function RCLootCouncil:GetResponseColor(response, isTier, isRelic)
	local color
	if isTier and self.mldb.tierButtonsEnabled and type(response) == "number" then
		color = (self.mldb.responses.tier and self.mldb.responses.tier[response]) and self.mldb.responses.tier[response].color or db.responses.tier[response].color
 	elseif isRelic and self.mldb.relicButtonsEnabled and type(response) == "number" then
		color = (self.mldb.responses.relic and self.mldb.responses.relic[response]) and self.mldb.responses.relic[response].color or db.responses.relic[response].color
 	else
		color = (self.mldb.responses and self.mldb.responses[response]) and self.mldb.responses[response].color or db.responses[response].color
	end
	return unpack(color or db.responses.DEFAULT.color)
end

---
function RCLootCouncil:GetResponseSort(response, isTier, isRelic)
	local ret
	if isTier and self.mldb.tierButtonsEnabled and type(response) == "number" then
		ret = (self.mldb.responses.tier and self.mldb.responses.tier[response]) and self.mldb.responses.tier[response].sort or db.responses.tier[response].sort
	elseif isRelic and self.mldb.relicButtonsEnabled and type(response) == "number" then
		ret = (self.mldb.responses.relic and self.mldb.responses.relic[response]) and self.mldb.responses.relic[response].sort or db.responses.relic[response].sort
	else
		ret = (self.mldb.responses and self.mldb.responses[response]) and self.mldb.responses[response].sort or db.responses[response].sort
	end
	return ret or db.responses.DEFAULT.sort
end

--#end UI Functions -----------------------------------------------------
--@debug@
-- debug func
_G.printtable = function( data, level )
	if not data then return end
	level = level or 0
	local ident=strrep('     ', level)
	if level>6 then return end
	if type(data)~='table' then print(tostring(data)) end;
	for index,value in pairs(data) do repeat
		if type(value)~='table' then
			print( ident .. '['..tostring(index)..'] = ' .. tostring(value) .. ' (' .. type(value) .. ')' );
			break;
		end
		print( ident .. '['..tostring(index)..'] = {')
        printtable(value, level+1)
        print( ident .. '}' );
	until true end
end
--@end-debug@

-- v2.3.1 added some new stuff. This will update old history entries with most of that for english clients.
-- Should be kept for a while so people can update in case their ML is slow to get it done.
function RCLootCouncil:UpdateLootHistory()
	self:Print("Updating Loot History")
	local nighthold, trialofvalor, emeraldnightmare = "The Nighthold", "Trial of Valor", "The Emerald Nightmare"
	local normal, heroic, mythic = "Normal", "Heroic", "Mythic"
	if GetLocale() ~= "enUS" then -- Let's see if we can get creative
		self:Debug("Trying to extract non-english history update data")
		-- If we find a 2.3.1+ entry, we can use that info to update older entries
		for _, data in pairs(historyDB) do
			for _, v in pairs(data) do
				if v.mapID then
					if v.mapID == 1530 then
						nighthold = strsplit("-", v.instance,2)
					elseif v.mapID == 1648 then
						trialofvalor = strsplit("-", v.instance,2)
					elseif v.mapID == 1520 then
						emeraldnightmare = strsplit("-", v.instance,2)
					end
				end
				-- double up just in case mapID or difficultyID are missing
				if v.difficultyID then
					if v.difficultyID == 14 then
						_, normal = strsplit("-", v.instance,2)
					elseif v.difficultyID == 15 then
						_, heroic = strsplit("-", v.instance,2)
					elseif v.difficultyID == 16 then
						_, mythic = strsplit("-", v.instance,2)
					end
				end
			end
		end
		self:Debug("Result:",nighthold, trialofvalor, emeraldnightmare, normal, heroic, mythic)
	end
	for name, data in pairs(historyDB) do
		for i, v in pairs(data) do
			local id = self:GetItemIDFromLink(v.lootWon)
			v.tierToken = id and RCTokenTable[id]
			if strmatch(v.instance, nighthold) then
				v.mapID = 1530
			elseif strmatch(v.instance, trialofvalor) then
				v.mapID = 1648
			elseif strmatch(v.instance, emeraldnightmare) then
				v.mapID = 1520
			end
			if strmatch(v.instance, normal) then
				v.difficultyID = 14
			elseif strmatch(v.instance, heroic) then
				v.difficultyID = 15
			elseif strmatch(v.instance, mythic) then
				v.difficultyID = 16
			end
			-- Fix corruption caused by v2.4-beta:
			if v.color and type(v.color) ~= "table" then
				if v.tokenRoll then
					v.color = {unpack(db.responses.tier[v.responseID].color)}
				else
					v.color = {unpack(db.responses[v.responseID].color)}
				end
				self:DebugLog("Fixed 2.4beta corruption @", name, i)
			end
		end
	end
	self:Print("Done")
end
