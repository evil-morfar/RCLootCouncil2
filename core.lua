--- core.lua Contains core elements of the addon
-- @author Potdisc

--[[AceEvent-3.0 Messages:
	core:
		RCCouncilChanged		-	fires when the council changes.
		RCConfigTableChanged	-	fires when the user changes a settings. args: [val]; a few settings supplies their name.
		RCUpdateDB				-	fires when the user receives sync data from another player.
		RCLootTableAdditionsReceived - fires when additional lootTable data has been received and processed.
	ml_core:
		RCMLAddItem				- 	fires when an item is added to the loot table. args: item, loottable entry
		RCMLAwardSuccess		- 	fires when an item is successfully awarded. args: session, winner, status, link, responseText.
		RCMLAwardFailed		-	fires when an item is unsuccessfully awarded. args: session, winner, status, link, responseText.
		RCMLBuildMLdb       -   fires just before the MLdb is built. arg: MLdb, the master looter db table.
		RCMLLootHistorySend	- 	fires just before loot history is sent out. args: loot_history table (the table sent to users), all arguments from ML:TrackAndLogLoot()
	votingFrame:
		RCSessionChangedPre	-	fires when the user changes the session, just before SwitchSession() is executed. args: sesion.
		RCSessionChangedPost	-	fires when the user changes the session, after SwitchSession() is executed. args: session.
	lootHistory:
		RCHistory_ResponseEdit - fires when the user edits the response of a history entry. args: data (see LootHistory:BuildData())
		RCHistory_NameEdit	-	fires when the user edits the receiver of a history entry. args: data.
	ItemStorage:
		RCItemStorageInitialized - fires when the item storage is initialized. args: #itemStorage.
]]
--[[ Notable Comm messages: (See Classes/Services/Comms.lua for subscribing to comms)
	Comms:
	P: Permanent, T: Temporary
		MAIN:
			StartHandleLoot 	P - Sent whenever RCLootCouncil starts handling loot.
			StopHandleLoot		P - Sent whenever RCLootCouncil stops handling loot.
			council				P - Council received from ML
			session_end 		P - ML has ended the session.
			playerInfoRequest 	P - Request for playerInfo
			pI 					P - Player Info
			n_t					P - Candidate received "non-tradeable" loot.
			r_t					P - Candidate "rejected_trade" of loot.
			lootTable			P - LootTable sent from ML.
			lt_add 				P - Partial lootTable (additions) sent from ML.
			mldb 				P - MLDB sent from ML.
			reroll 				P - (Partial) lootTable with items we should reroll on.
			re_roll				P - (Partial) lootTable and list of candidates that should reroll.
			lootAck 			P - LootAck received from another player. Used for checking if have received the required data.
			Rgear				P - Anyone requests our currently equipped gear.
			bonus_roll 			P - Sent whenever we do a bonus roll.
			getCov 				P - Anyone request or covenant ID.
			history 			P - Sent when an item is awarded to a player.
]]
-- GLOBALS: GetLootMethod, C_AddOns.GetAddOnMetadata, UnitClass
local addonname, addontable = ...
--- @class RCLootCouncil : AceAddon, AceConsole-3.0, AceEvent-3.0, AceHook-3.0, AceTimer-3.0, AceBucket-3.0
_G.RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon(addontable, addonname, "AceConsole-3.0", "AceEvent-3.0",
                                                    "AceHook-3.0", "AceTimer-3.0", "AceBucket-3.0");
local LibDialog = LibStub("LibDialog-1.1")
--- @type RCLootCouncilLocale
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local tooltipForParsing = CreateFrame("GameTooltip", "RCLootCouncil_Tooltip_Parse", nil, "GameTooltipTemplate")
tooltipForParsing:UnregisterAllEvents() -- Don't use GameTooltip for parsing, because GameTooltip can be hooked by other addons.

RCLootCouncil:SetDefaultModuleState(false)

local Comms = RCLootCouncil.Require "Services.Comms"
local Council = RCLootCouncil.Require "Data.Council"
local Player = RCLootCouncil.Require "Data.Player"
local MLDB = RCLootCouncil.Require "Data.MLDB"
local TT = RCLootCouncil.Require "Utils.TempTable"
local ItemUtils = RCLootCouncil.Require "Utils.Item"

-- Init shorthands
local db, debugLog; -- = self.db.profile, self.db.global.log
-- init modules
---@enum (key) DefaultModules
local defaultModules = {
	masterlooter = "RCLootCouncilML",
	lootframe = "RCLootFrame",
	history = "RCLootHistory",
	version = "VersionCheck",
	sessionframe = "RCSessionFrame",
	votingframe = "RCVotingFrame",
	tradeui = "TradeUI",
	sync = "Sync",
}
---@enum (key) UserModules
local userModules = {
	masterlooter = nil,
	lootframe = nil,
	history = nil,
	version = nil,
	sessionframe = nil,
	votingframe = nil,
	tradeui = nil,
}

local unregisterGuildEvent = false
local lootTable = {}

-- Lua
local time, tonumber, unpack, select, wipe, pairs, ipairs, format, table, tinsert, tremove, bit, tostring, type = time,
                                                                                                                  tonumber,
                                                                                                                  unpack,
                                                                                                                  select,
                                                                                                                  wipe,
                                                                                                                  pairs,
                                                                                                                  ipairs,
                                                                                                                  format,
                                                                                                                  table,
                                                                                                                  tinsert,
                                                                                                                  tremove,
                                                                                                                  bit,
                                                                                                                  tostring,
                                                                                                                  type

local playersData = { -- Update on login/encounter starts. it stores the information of the player at that moment.
	gears = {}, -- Gears key: slot number(1-19), value: item link
	relics = {}, -- Relics key: slot number(1-3), value: item link
} -- player's data that can be changed by the player (spec, equipped ilvl, gaers, relics etc)

function RCLootCouncil:OnInitialize()
	self.Log = self.Require "Utils.Log":New()
	-- IDEA Consider if we want everything on self, or just whatever modules could need.
	self.version = C_AddOns.GetAddOnMetadata("RCLootCouncil", "Version")
	self.nnp = false
	self.debug = false
	self.tVersion = nil -- String or nil. Indicates test version, which alters stuff like version check. Is appended to 'version', i.e. "version-tVersion" (max 10 letters for stupid security)

	self.playerClass = select(2, UnitClass("player")) -- TODO: Remove - contained in self.player
	self.guildRank = L["Unguilded"]
	self.guildName = nil
	self.isMasterLooter = false -- Are we the ML?
	---@type Player
	self.masterLooter = nil -- Masterlooter
	self.lootMethod = GetLootMethod() or "personalloot"
	self.handleLoot = false -- Does RC handle loot(Start session from loot window)?
	self.isCouncil = false -- Are we in the Council?
	self.enabled = true -- turn addon on/off
	self.inCombat = false -- Are we in combat?
	self.recentReconnectRequest = false
	self.currentInstanceName = ""
	self.bossName = nil -- Updates after each encounter
	self.lootOpen = false -- is the ML lootWindow open or closed?
	self.lootSlotInfo = {} -- Items' data currently in the loot slot. Need this because inside LOOT_SLOT_CLEARED handler, GetLootSlotLink() returns invalid link.
	self.nonTradeables = {} -- List of non tradeable items received since the last ENCOUNTER_END
	self.lastEncounterID = nil
	self.autoGroupLootWarningShown = false
	self.isInGuildGroup = false -- Is the group leader a member of our guild?
	---@type InstanceDataSnapshot
	self.instanceDataSnapshot = nil -- Instance data from last encounter

	---@type table<string,boolean>
	self.candidatesInGroup = {}
	self.mldb = {} -- db recived from ML
	self.chatCmdHelp = {
		{cmd = "config", desc = L["chat_commands_config"]},
		{cmd = "council", desc = L["chat_commands_council"]},
		{cmd = "history", desc = L["chat_commands_history"]},
		{cmd = "open", desc = L["chat_commands_open"]},
		{cmd = "profile", desc = L.chat_commands_profile, },
		{cmd = "reset", desc = L["chat_commands_reset"]},
		{cmd = "sync", desc = L["chat_commands_sync"]},
		{cmd = "trade", desc = L.chat_commands_trade},
		{cmd = "version", desc = L["chat_commands_version"]},
	}
	self.mlChatCmdHelp = {
		{cmd = "add [item]", desc = L["chat_commands_add"]},
		{cmd = "add all", desc = L["chat_commands_add_all"]},
		{cmd = "award", desc = L["chat_commands_award"]},
		{cmd = "clear", desc = L.chat_commands_clear},
		{cmd = "export", desc = L.chat_commands_export},
		{cmd = "list", desc = L.chat_commands_list},
		{cmd = "remove [index]", desc = L.chat_commands_remove},
		{cmd = "session", desc = L.chat_commands_session},
		{cmd = "start", desc = L.chat_commands_start},
		{cmd = "stop", desc = L.chat_commands_stop},
		{cmd = "test (#)", desc = L["chat_commands_test"]},
		{cmd = "whisper", desc = L["chat_commands_whisper"]},
		
	}

	self.lootGUIDToIgnore = { -- List of GUIDs we shouldn't register loot from
		["317400"] = true, -- Opulence BoD (trash piles)
	}

	-- List of item classes all auto looting should ignore
	-- see https://wow.gamepedia.com/ItemType
	self.blacklistedItemClasses = {
		[0] = { -- Consumables
			all = true,
		},
		[5] = { -- Reagents
			[0] = true, -- Reagent
			[1] = true, -- Keystone
		},
		[7] = { -- Tradeskills
			all = true,
		},
		[12] = { -- Quest
			all = true,
		},
		[15] = { -- Misc
			[1] = true, -- Reagent
			[4] = true, -- Other (Anima)
		},
	}

	-- List of itemIds that should not be blacklisted
	self.blackListOverride = {
		-- [itemId] = true
		[206046] = true, -- Void-Touched Curio
		[210947] = true, -- Flame-Warped Curio
	}

	self.testMode = false;
	-- create the other buttons/responses
	for i = 1, self.defaults.profile.maxButtons do
		if i > self.defaults.profile.buttons.default.numButtons then
			tinsert(self.defaults.profile.buttons.default, {text = L["Button"] .. " " .. i, whisperKey = "" .. i})
			tinsert(self.defaults.profile.responses.default, {color = {0.7, 0.7, 0.7, 1}, sort = i, text = L["Button"] .. i})
		end
	end
	-- create the other AwardReasons
	for i = #self.defaults.profile.awardReasons + 1, self.defaults.profile.maxAwardReasons do
		tinsert(self.defaults.profile.awardReasons,
		        {color = {1, 1, 1, 1}, disenchant = false, log = true, sort = 400 + i, text = "Reason " .. i})
	end

	-- init db
	self.db = LibStub("AceDB-3.0"):New("RCLootCouncilDB", self.defaults, true)
	self:InitLogging()
	self.lootDB = LibStub("AceDB-3.0"):New("RCLootCouncilLootDB")
	--[[ Format:
	"playerName" = {
		[#] = {"lootWon", "date (d/m/y)", "time (h:m:s)", "instance", "boss", "votes", "itemReplaced1", "itemReplaced2", "response", "responseID",
				 "color", "class", "isAwardReason", "difficultyID", "mapID", "groupSize", "tierToken"}
	},
	]]
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateDB")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateDB")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateDB")

	self:ClearOldVerTestCandidates()
	self:InitClassIDs()
	self:InitTrinketData()

	-- add shortcuts
	db = self.db.profile
	debugLog = self.db.global.log

	-- Slash setup
	if db.useSlashRC then -- Allow presevation of readycheck shortcut.
		self:RegisterChatCommand("rc", "ChatCommand")
	end
	self:RegisterChatCommand("rclc", "ChatCommand")
	self.customChatCmd = {} -- Modules that wants their cmds used with "/rc"

	-- Register Core Comms
	Comms:Register(self.PREFIXES.MAIN)
	Comms:Register(self.PREFIXES.VERSION)
	self.Send = Comms:GetSender(self.PREFIXES.MAIN)

	self:SubscribeToPermanentComms()

	-- Add logged in message in the log
	self.Log("Logged In")
	self:ModulesOnInitialize()
end

function RCLootCouncil:OnEnable()
	if not self:IsCorrectVersion() then
		self.Log:e("Wrong game version", WOW_PROJECT_ID)
		self:Print(format("This version of %s is not intended for this game version!\nPlease install the proper version.",
		                  self.baseName))
		return self:Disable()
	end

	-- Register the player's name
	self.realmName = select(2, UnitFullName("player")) -- TODO Remove
	if self.realmName == "" then -- Noticed this happening with starter accounts. Not sure if it's a real problem.
		self:ScheduleTimer(function() self.realmName = select(2, UnitFullName("player")) end, 2)
	end
	self.player = Player:Get("player")
	self.playerName = self.player:GetName() -- TODO Remove
	self.Log(self.playerName, self.version, self.tVersion)

	self.EJLatestInstanceID = self:GetEJLatestInstanceID()
	self:DoChatHook()

	-- register the optionstable
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RCLootCouncil", function() return self:OptionsTable() end)

	-- add it to blizz options
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RCLootCouncil", "RCLootCouncil", nil, "settings")
	self.optionsFrame.ml = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RCLootCouncil", "Master Looter",
	                                                                       "RCLootCouncil", "mlSettings")
	self.playersData = playersData -- Make it globally available

	self:ScheduleTimer("InitItemStorage", 5, self) -- Delay to have a better change of getting correct item info

	-- register events
	for event, method in pairs(self.coreEvents) do self:RegisterEvent(event, method) end
	self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 5, "UpdateCandidatesInGroup")

	if IsInGuild() then
        self.guildName, self.guildRank = GetGuildInfo("player")
        self:ScheduleTimer("SendGuildVerTest", 2) -- send out a version check after a delay
	end

	-- For some reasons all frames are blank until ActivateSkin() is called, even though the values used
	-- in the :CreateFrame() all :Prints as expected :o
	self:ActivateSkin(db.currentSkin)

	if self.db.global.version then -- Intentionally run before updating global.version
		self.Compat:Run() -- Do compatibility changes
	end

	if self:VersionCompare(self.db.global.version, self.version) then self.db.global.oldVersion = self.db.global.version end
	self.db.global.version = self.version

	if self.db.global.tVersion and self.debug then -- recently ran a test version, so reset debugLog
		self.db.global.log = {}
	end
	self.db.global.locale = GetLocale() -- Store locale in log. Important information for debugging.
	self.db.global.regionID = GetCurrentRegion()

	self.db.global.tVersion = self.tVersion;
	self.Utils:GuildRoster()

	local filterFunc = function(_, event, msg, player, ...) return strfind(msg, "[[RCLootCouncil]]:") end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterFunc)
	self:CouncilChanged() -- Call to initialize council
end

function RCLootCouncil:OnDisable()
	self.Log("OnDisable()")
	self:UnregisterChatCommand("rc")
	self:UnregisterChatCommand("rclc")
	self:UnregisterAllEvents()
	Comms:OnDisable()
end

function RCLootCouncil:ConfigTableChanged(val)
	--[[ NOTE By default only ml_core needs to know about changes to the config table,
		  but we'll use AceEvent incase future modules also wants to know ]]
	self:SendMessage("RCConfigTableChanged", val)
end

function RCLootCouncil:CouncilChanged()
	local council = {}
	for _, guid in ipairs(self.db.profile.council) do
		local player = Player:Get(guid)
		if player and player.guid then council[player.guid] = player end
	end
	Council:Set(council)
	self:SendMessage("RCCouncilChanged")
end

local function validateChatFrame() return type(db.chatFrameName) == "string" and getglobal(db.chatFrameName) end

function RCLootCouncil:DoChatHook()
	-- Unhook if already hooked:
	if self:IsHooked(self, "Print") then self:Unhook(self, "Print") end
	if not validateChatFrame() then
		self:Print("Warning: Your chat frame", db.chatFrameName, "doesn't exist. ChatFrame has been reset.")
		self.Log:e("ChatFrameName validation failed, resetting...")
		db.chatFrameName = self.defaults.profile.chatFrameName
	end
	-- Pass our channel to the original function and magic appears.
	self:RawHook(self, "Print", function(_, ...) self.hooks[self].Print(self, getglobal(db.chatFrameName), ...) end, true)
end

function RCLootCouncil:PrintMLChatHelp()
	print ""
	local mlCommandsString = self:IsCorrectVersion() and L.chat_commands_groupLeader_only or L.chat_commands_ML_only
	print("|cFFFFA500" .. mlCommandsString .. "|r")
	for _, y in ipairs(self.mlChatCmdHelp) do
		print("|cff20a200", y.cmd, "|r:", y.desc)
	end
end

function RCLootCouncil:ChatCommand(msg)
	local input = self:GetArgs(msg, 1)
	local args = {}
	local arg
	local startpos = input and #input + 1 or 0
	repeat
		arg, startpos = self:GetArgs(msg, 1, startpos)
		if arg then table.insert(args, arg) end
	until arg == nil
	input = strlower(input or "")
	self.Log:d("/", input, unpack(args))
	if not input or input:trim() == "" or input == "help" or input == string.lower(_G.HELP_LABEL) then
		if self.tVersion then
			print(format(L["chat tVersion string"], self.version, self.tVersion))
		else
			print(format(L["chat version String"], self.version))
		end
		local module, shownMLCommands
		for _, v in ipairs(self.chatCmdHelp) do
			-- Show ML commands beneath regular commands, but above module commands
			if v.module and not shownMLCommands then -- this won't trigger if there's no module(s)
				self:PrintMLChatHelp()
				shownMLCommands = true
			end
			if v.module ~= module then -- Print module name and version
				print "" -- spacer
				if v.module.version and v.module.tVersion then
					print(v.module.baseName, "|cFFFFA500", v.module.version, v.module.tVersion)
				elseif v.module.version then
					print(v.module.baseName, "|cFFFFA500", v.module.version)
				else
					print(v.module.baseName, "|cFFFFA500", C_AddOns.GetAddOnMetadata(v.module.baseName, "Version"))
				end
			end
			if v.cmd then
				print("|cff20a200", v.cmd, "|r:", v.desc)
			else
				print(v.desc) -- For backwards compatibility
			end
			module = v.module
		end
		-- If there's no modules, just print the ML commands now
		if not shownMLCommands then self:PrintMLChatHelp() end
		self.Log:d("- debug or d - Toggle debugging")
		self.Log:d("- log - display the debug log")
		self.Log:d("- clearLog - clear the debug log")

	elseif input == 'config' or input == L["config"] or input == "c" or input == "opt" or input == "options" then
		Settings.OpenToCategory(self.optionsFrame.name)
		-- LibStub("AceConfigDialog-3.0"):Open("RCLootCouncil")

	elseif input == 'debug' or input == 'd' then
		self.debug = not self.debug
		self:Print("Debug = " .. tostring(self.debug))

	elseif input == 'open' or input == L["open"] then
		if self.isCouncil or self.mldb.observe or self.nnp then -- only the right people may see the window during a raid since they otherwise could watch the entire voting
			self:GetActiveModule("votingframe"):Show()
		elseif #lootTable == 0 then
			self:Print(L["No session running"])
		else
			self:Print(L["You are not allowed to see the Voting Frame right now."])
		end

	elseif input == 'council' or input == L["council"] then
		local category = FindValueInTableIf(
			SettingsPanel:GetCategory(self.optionsFrame.name):GetSubcategories(),
			function(v)
				return v and v:GetID() == self.optionsFrame.ml.name
			end)

		if not category then return self.Log:e("Couldn't find category in '/rc council'", category) end
		Settings.OpenToCategory(self.optionsFrame.name)
		SettingsPanel:SelectCategory(category)
		LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil", "mlSettings", "councilTab")

	elseif input == "ml" or input == "cm" or input == "masterlooter" then
		local category = FindValueInTableIf(
			SettingsPanel:GetCategory(self.optionsFrame.name):GetSubcategories(),
			function(v)
				return v and v:GetID() == self.optionsFrame.ml.name
			end)

		if not category then return self.Log:e("Couldn't find category in '/rc ml'", category) end
		Settings.OpenToCategory(self.optionsFrame.name)
		SettingsPanel:SelectCategory(category)

	elseif input == "profile" or input == "profiles" then
		Settings.OpenToCategory(self.optionsFrame.name)
		LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil", "settings", "profiles")

	elseif input == 'test' or input == L["test"] then
		self:Test(tonumber(args[1]) or 1)
	elseif input == 'fulltest' or input == 'ftest' then
		self:Test(tonumber(args[1]) or 1, true)

	elseif input == 'version' or input == L["version"] or input == "v" or input == "ver" then
		if args[1] then -- Print outdated versions
			self:GetActiveModule("version"):PrintOutDatedClients()
		else -- Otherwise open it
			self:CallModule("version")
		end

	elseif input == "history" or input == string.lower(_G.HISTORY) or input == "h" or input == "his" or input == "hist" then
		self:CallModule("history")

	elseif input == "whisper" or input == string.lower(_G.WHISPER) then
		self:Print(L["whisper_help"])

	elseif input == "add" or input == string.lower(_G.ADD) then
		if not args[1] or args[1] == "" then return self:ChatCommand("help") end
		if self.isMasterLooter then
			self:ChatCmdAdd(args)
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end

	elseif input == "award" or input == L["award"] then
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):SessionFromBags()
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

	elseif input == "hidelootframe" or input == "hidelootframes" then
		self.Require "Utils.GroupLoot":HideGroupLootFrames()

	elseif input == "reset" or input == string.lower(_G.RESET) then
		self:ResetUI()
		self:Print(L["Windows reset"])

	elseif input == "start" or input == string.lower(_G.START) then
		if self.Utils:IsPartyLFG() then
			return self:Print(L.chat_command_start_error_start_PartyIsLFG)
		elseif db.usage.never then
			return self:Print(L.chat_command_start_error_usageNever)
		elseif not IsInRaid() and db.onlyUseInRaids then
			return self:Print(L.chat_command_start_error_onlyUseInRaids)
		elseif not self.isMasterLooter then
			return self:Print(L["You cannot use this command without being the Master Looter"])
		end
		-- Simply emulate player entering raid.
		self:OnRaidEnter()

	elseif input == "stop" or input == string.lower(L.Stop) then
		if self.isMasterLooter then
			if self.handleLoot then
				self:StopHandleLoot()
			else
				self:Print(L.chatCommand_stop_error_notHandlingLoot)
			end
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end

	elseif input == "debuglog" or input == "log" then
		for k, v in ipairs(debugLog) do print(k, v); end

	elseif input == "clearlog" then
		wipe(debugLog)
		self:Print("Debug Log cleared.")

	elseif input == "clearcache" then
		self.db.global.cache = {}
		self:Print("Cache cleared")

	elseif input == "sync" then
		self.Sync:Enable()

	elseif input == "session" or input == "ses" or input == "s" then
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):ShowSessionFrame()
		else
			self:Print(L["You cannot use this command without being the Master Looter"])
		end
	elseif input == "trade" then
		self.TradeUI:Show(true)

	elseif input == "safemode" then
		db.safemode = not db.safemode
		self:Print("SafeMode " .. (db.safemode and "On" or "Off"))

	elseif input == "export" then
			self:ExportCurrentSession()

	elseif input == "unlock" then
		if not args[1]then
			return self:Print("Must have 'item' as second argument.")
		end
		self:UnlockItem(args[1])

	--@debug@
	elseif input == "nnp" then
		self.nnp = not self.nnp
		self:Print("nnp = " .. tostring(self.nnp))

	elseif input == "exporttrinketdata" then
		self:ExportTrinketData(tonumber(args[1]), 0, tonumber(args[2]), 1)

	elseif input == "trinkettest" or input == "ttest" then
		self.playerClass = string.upper(args[1])
		self:Test(1, false, true)

	elseif input == "exporttokendata" then
		self:ExportTokenData(tonumber(args[1]))

	elseif input == 't' then -- Tester cmd
		-- Test items with several modifiers. Should probably be added to the regular test func
		for i = 1, GetNumGuildMembers() do
			local info = {GetGuildRosterInfo(i)}
			if (info[9]) then
				local guid = info[17]
				local inGuild = IsInGuild(guid)
				print(Player:Get(guid), "in guild = ", inGuild)
			end
		end
	--@end-debug@
	else
		-- Check if the input matches anything
		for k, v in pairs(self.customChatCmd) do if k == input then return v.module[v.func](v.module, unpack(args)) end end
		self:ChatCommand("help")
	end
end

-- Items in here should not be handled by `UpdateAndSendRecentTradableItem`.
local itemsBeingGroupLooted = {}
RCLootCouncil.Require ("Utils.GroupLoot").OnLootRoll:subscribe(function (link)
	tinsert(itemsBeingGroupLooted, link)
end)

-- Update the recentTradableItem by link, if it is in bag and tradable.
-- Except when the item has been auto group looted.
function RCLootCouncil:UpdateAndSendRecentTradableItem(info, count)
	local index = tIndexOf(itemsBeingGroupLooted, info.link)
	if index then
		-- Remove from list in case we get future similar items.
		tremove(itemsBeingGroupLooted, index)
		return
	end
	local Item = self.ItemStorage:New(info.link, "temp")
	self.ItemStorage:WatchForItemInBags(Item, function() -- onFound
		self:LogItemGUID(Item)
		if Item.time_remaining > 0 then
			Item:Store()
			if self.mldb.rejectTrade and IsInRaid() then
				LibDialog:Spawn("RCLOOTCOUNCIL_KEEP_ITEM", info.link)
				return
			end
			self:Send("group", "tradable", info.link, info.guid)
			return
		end
		-- We've searched every single bag space, and found at least 1 item that wasn't tradeable,
		-- and none that was. We can now safely assume the item can't be traded.
		self:Send("group", "n_t", info.link, info.guid)
		self.ItemStorage:RemoveItem(Item)
	end, function() -- onFail
		-- We haven't found it, maybe we just haven't received it yet, so try again in one second
		Item:Unstore()
		self.Log:e(format("UpdateAndSendRecentTradableItem: %s not found in bags", Item.link))
	end)
end

-- Send the msg to the channel if it is valid. Otherwise just print the messsage.
function RCLootCouncil:SendAnnouncement(msg, channel)
	if channel == "NONE" then return end
	if self.testMode then msg = "(" .. L["Test"] .. ") " .. msg end
	if (not IsInGroup()
					and (channel == "group" or channel == "RAID" or channel == "RAID_WARNING" or channel == "PARTY" or channel
									== "INSTANCE_CHAT")) or channel == "chat" or (not IsInGuild() and (channel == "GUILD" or channel == "OFFICER")) then
		self:Print(msg)
	elseif (not IsInRaid() and (channel == "RAID" or channel == "RAID_WARNING")) then
		SendChatMessage(msg, "PARTY")
	else
		SendChatMessage(msg, self.Utils:GetAnnounceChannel(channel))
	end
end

function RCLootCouncil:ResetReconnectRequest()
	self.recentReconnectRequest = false
	self.Log:d("ResetReconnectRequest")
end

function RCLootCouncil:ChatCmdAdd(args)
	if not args[1] or args[1] == "" then return end -- We need at least 1 arg

	-- Add all items in bags with trade timers
	if args[1] == "bags" or args[1] == "all" then
		local items = self:GetAllItemsInBagsWithTradeTimer()
		self:Print(format(L["chat_cmd_add_found_items"], #items))
		local player = self.player:GetName() -- Save the extra calls
		for _, v in ipairs(items) do self:GetActiveModule("masterlooter"):AddUserItem(v, player) end
		return
	end

	-- Add linked items
	local owner
	-- See if one of the args is a owner
	if not args[1]:find("|") and type(tonumber(args[1])) ~= "number" then
		-- First arg is neither an item or a item id, see if it's someone in our group
		owner = self:UnitName(args[1])
		if not (owner and owner ~= "" and self.candidatesInGroup[owner]) then
			self:Print(format(L["chat_cmd_add_invalid_owner"], owner))
			return
		end
		tremove(args, 1)
	end
	-- Now handle the links
	local links = args
	if args[1]:find("|h") then -- Only split links if we have at least one
		links = self:SplitItemLinks(args) -- Split item links to allow user to enter links without space
	end
	for _, v in ipairs(links) do self:GetActiveModule("masterlooter"):AddUserItem(v, owner or self.player:GetName()) end
end

-- if fullTest, add items in the encounterJournal to the test items.
function RCLootCouncil:Test(num, fullTest, trinketTest)
	self.Log:d("Test", num)
	local testItems = {
		-- Tier21 Tokens (Head, Shoulder, Cloak, Chest, Hands, Legs)
		152524,
		152530,
		152517,
		152518,
		152521,
		152527, -- Vanquisher: DK, Druid, Mage, Rogue
		152525,
		152531,
		152516,
		152519,
		152522,
		152528, -- Conqueror : DH, Paladin, Priest, Warlock
		152526,
		152532,
		152515,
		152520,
		152523,
		152529, -- Protector : Hunder, Monk, Shaman, Warrior

		-- Tier21 Armors (Head, Shoulder, Chest, Wrist, Hands, Waist, Legs, Feet)
		152014,
		152019,
		152017,
		152023,
		152686,
		152020,
		152016,
		152009, -- Plate
		152423,
		152005,
		151994,
		152008,
		151998,
		152006,
		152002,
		151996, -- Mail
		151985,
		151988,
		151982,
		151992,
		151984,
		151986,
		151987,
		151981, -- Leather
		151943,
		151949,
		152679,
		151953,
		152680,
		151942,
		151946,
		151939, -- Cloth

		-- Tier21 Miscellaneous
		152283,
		151965,
		151973, -- Neck
		151937,
		151938,
		152062, -- Cloak
		151972,
		152063,
		152284, -- Rings

		-- Tier21 Relics
		152024,
		152025, -- Arcane
		152028,
		152029, -- Blood
		152031,
		152032, -- Fel
		152035,
		152036, -- Fire
		152039,
		152040, -- Frost
		152043,
		152044, -- Holy
		152047,
		152048, -- Iron
		152050,
		152051, -- Life
		152054,
		152055, -- Shadow
		152058,
		152059, -- Storm
	}

	local trinkets = {
		-- Tier21 Trinkets
		154172, -- All classes
		151975,
		151976,
		151977,
		151978,
		152645,
		153544,
		154173, -- Tank
		151974, -- Eye of Shatug. EJ item id is different with the item id actually drops
		151956,
		151957,
		151958,
		151960,
		152289,
		154175, -- Healer
		151964,
		152093, -- Melee DPS
		154176, -- Strength DPS
		154174, -- Agility DPS
		151970, -- Intellect DPS/Healer
		151955,
		151971,
		154177, -- Intellect DPS
		151963,
		151968, -- Melee and ranged attack DPS
		151962,
		151969, -- Ranged attack and spell DPS
	}

	if not trinketTest then for _, t in ipairs(trinkets) do tinsert(testItems, t) end end

	if fullTest then -- Add items from encounter journal which includes items from different difficulties.
		testItems = {}
		C_AddOns.LoadAddOn("Blizzard_EncounterJournal")
		local cached = true
		local difficulties = {14, 15, 16} -- Normal, Heroic, Mythic

		EJ_SelectInstance(self.EJLatestInstanceID)
		EJ_ResetLootFilter()
		for _, difficulty in pairs(difficulties) do
			EJ_SetDifficulty(difficulty)
			self.Log:d("EJ_SetDifficulty()", difficulty)

			local n = EJ_GetNumLoot()
			self.Log:d("EJ_GetNumLoot()", n)

			if not n then cached = false end
			for i = 1, n or 0 do
				local link = C_EncounterJournal.GetLootInfoByIndex(i).link
				if link then
					tinsert(testItems, link)
				else
					cached = false
				end
			end
			if not cached then
				self.Log:d("Retrieving item info from Encounter Journal. Retry after 1s.")
				return self:ScheduleTimer("Test", 1, num, fullTest)
			end
		end
	end

	local items = {};
	-- pick "num" random items
	for i = 1, num do -- luacheck: ignore
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
		self:Print(L.error_test_as_non_leader)
		self.testMode = false
		return
	end
	self:SnapshotInstanceData()
	-- Call ML module and let it handle the rest
	self:CallModule("masterlooter")
	self:GetActiveModule("masterlooter"):NewML(self.masterLooter)
	self:GetActiveModule("masterlooter"):Test(items)
end

function RCLootCouncil:EnterCombat()
	self.inCombat = true
	self.UI:MinimizeFrames()
end

function RCLootCouncil:LeaveCombat()
	self.inCombat = false
	self.UI:MaximizeFrames()
end

function RCLootCouncil:UpdatePlayersGears(startSlot, endSlot)
	startSlot = startSlot or _G.INVSLOT_FIRST_EQUIPPED
	endSlot = endSlot or INVSLOT_LAST_EQUIPPED

	for i = startSlot, endSlot do
		local iLink = GetInventoryItemLink("player", i)
		if iLink then
			local iName = C_Item.GetItemInfo(iLink)
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

-- Update player's data which is changable by the player. (specid, equipped ilvl, specs, gears, etc)
function RCLootCouncil:UpdatePlayersData()
	self.Log("UpdatePlayersData()")
	playersData.specID = GetSpecialization() and GetSpecializationInfo(GetSpecialization())
	playersData.ilvl = select(2, GetAverageItemLevel())
	self:UpdatePlayersGears()
end

-- @param link A gear that we want to compare against the equipped gears
-- @param gearsTable if specified, compare against gears stored in the table instead of the current equipped gears, whose key is slot number and value is the item link of the gear.
-- @return the gear(s) that with the same slot of the input link.
function RCLootCouncil:GetPlayersGear(link, equipLoc, gearsTable)
	self.Log("GetPlayersGear", link, equipLoc)
	local GetInventoryItemLink = GetInventoryItemLink
	if gearsTable and #gearsTable > 0 then -- lazy code
		GetInventoryItemLink = function(_, slotNum) return gearsTable[slotNum] end
	end

	local itemID = ItemUtils:GetItemIDFromLink(link) -- Convert to itemID
	if not itemID then return nil, nil; end
	local item1, item2;
	-- check if the item is a token, and if it is, return the matching current gear
	if RCTokenTable[itemID] then
		if RCTokenTable[itemID] == "MultiSlots" then -- Armor tokens for multiple slots, just return nil
			return
		elseif RCTokenTable[itemID] == "Trinket" then -- We need to return both trinkets
			item1 = GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET0SLOT"))
			item2 = GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET1SLOT"))
		else -- Just return the slot from the tokentable
			item1 = GetInventoryItemLink("player", GetInventorySlotInfo(RCTokenTable[itemID]))
		end
		return item1, item2
	end
	local slot = self.INVTYPE_Slots[equipLoc]
	if not slot then
		-- Check if we have a typecode for it
		slot = self.INVTYPE_Slots[self:GetTypeCodeForItem(link)]

		-- TODO Dirty hack for context tokens. Could do with a better system for both determining typecode and equiploc overrides
		local _, _, _, _, _, itemClassID, itemSubClassID = C_Item.GetItemInfoInstant(link)
		if itemClassID == 5 and itemSubClassID == 2 then slot = self.INVTYPE_Slots.CONTEXT_TOKEN end
	end
	if not slot then return nil, nil end
	item1 = GetInventoryItemLink("player", GetInventorySlotInfo(slot[1] or slot))
	if not item1 and slot['or'] then item1 = GetInventoryItemLink("player", GetInventorySlotInfo(slot['or'])) end
	if slot[2] then item2 = GetInventoryItemLink("player", GetInventorySlotInfo(slot[2])) end
	return item1, item2;
end

--- Generates a "type code" used to determine which set of buttons to use for the item.
--- The returned code can be used directly in `mldb.responses[code]` and `mldb.buttons[code]`.
--- <br>See [Constants.lua](lua://RCLootCouncil.RESPONSE_CODE_GENERATORS)
--- @param item string|integer Any valid input for [`C_Item.GetItemInfoInstant`](lua://C_Item.GetItemInfoInstant).
--- @return string #The typecode for the item.
function RCLootCouncil:GetTypeCodeForItem(item)
	local itemID, _, _, itemEquipLoc, _, itemClassID, itemSubClassID = C_Item.GetItemInfoInstant(item)
	if not itemID then return "default" end -- We can't handle uncached items!

	if not db.enabledButtons[itemEquipLoc] then
		for _, func in ipairs(self.RESPONSE_CODE_GENERATORS) do
			local val = func(item, db, itemID, itemEquipLoc, itemClassID, itemSubClassID)
			if val then return val end
		end
	end
	-- Remaining is simply their equipLoc, if set
	return db.enabledButtons[itemEquipLoc] and itemEquipLoc or "default"
end

-- Sends a response. Uses the gear equipped at the start of most recent encounter or login.
-- @paramsig session [, ...]
-- link, ilvl, equipLoc and subType must be provided to send out gear information.
-- @param target 		The target of response
-- @param session		The session to respond to.
-- @param response		The selected response, must be index of db.responses.
-- @param isTier		Indicates if the response is a tier response. (v2.4.0) - DEPRECATED
-- @param isRelic		Indicates if the response is a relic response. (v2.5.0) - DEPRECATED
-- @param note			The player's note.
-- @param roll 			The player's roll.
-- @param link 			The itemLink of the item in the session.
-- @param ilvl			The ilvl of the item in the session.
-- @param equipLoc		The item in the session's equipLoc.
-- @param relicType     The type of relic
-- @param sendAvgIlvl   Indicates whether we send average ilvl.
-- @param sendSpecID    Indicates whether we send spec id.
function RCLootCouncil:SendResponse(target, session, response, isTier, isRelic, note, roll, link, ilvl, equipLoc,
                                    relicType, sendAvgIlvl, sendSpecID)
	self.Log:d("SendResponse", target, session, response, isTier, isRelic, note, roll, link, ilvl, equipLoc, relicType,
	           sendAvgIlvl, sendSpecID)
	local g1, g2, diff

	if link and ilvl then
		g1, g2 = self:GetGear(link, equipLoc, relicType)
		diff = self:GetIlvlDifference(link, g1, g2)
	end

	self:Send(target, "response", session, {
		gear1 = g1 and ItemUtils:GetItemStringFromLink(g1) or nil,
		gear2 = g2 and ItemUtils:GetItemStringFromLink(g2) or nil,
		ilvl = sendAvgIlvl and playersData.ilvl or nil,
		diff = diff,
		note = note,
		response = response,
		specID = sendSpecID and playersData.specID or nil,
		roll = roll,
	})
end

-- REVIEW Not needed
function RCLootCouncil:GetGear(link, equipLoc)
	return self:GetPlayersGear(link, equipLoc, playersData.gears) -- Use gear info we stored before
end

--- Gets the ilvl difference between an item and the player's equipped gear.
-- If a multislot is compared, the lowest ilvl item is normally selected, unless the player has equipped
-- another version of the same item, in which case that item is compared.
-- @paramsig item [,g1,g2,equipLoc]
-- @param item The item to compare with players gear (Anything accepted by `GetItemInfo`).
-- @param g1 Uses this specific item for the comparison if provided.
-- @param g2 Same as g1, but for multislot items.
-- @return Integer - the difference between the comparison item and the equipped gear.
function RCLootCouncil:GetIlvlDifference(item, g1, g2)
	if not (g1 or g2) then
		self.Log:E("GetIlvlDifference: no gear for item:", item)
		return 0 -- Fallback value incase no gear is provided
	end
	local _, link, _, ilvl, _, _, _, _, equipLoc = C_Item.GetItemInfo(item)

	if not ilvl then
		self.Log:E(format("GetIlvlDifference: item: %s had ilvl %s", tostring(item), tostring(ilvl)))
		return -1
	end

	-- Check if it's a ring or trinket
	if equipLoc == "INVTYPE_TRINKET" or equipLoc == "INVTYPE_FINGER" then
		local id = ItemUtils:GetItemIDFromLink(link)
		if id == ItemUtils:GetItemIDFromLink(g1) then -- compare with it
			local ilvl2 = select(4, C_Item.GetItemInfo(g1))
			return ilvl - ilvl2

		elseif g2 and id == ItemUtils:GetItemIDFromLink(g2) then
			local ilvl2 = select(4, C_Item.GetItemInfo(g2))
			return ilvl - ilvl2
		end
		-- We haven't equipped this item, do it normally
	end
	local diff = 0
	local g1diff, g2diff = g1 and select(4, C_Item.GetItemInfo(g1)), g2 and select(4, C_Item.GetItemInfo(g2))
	if g1diff and g2diff then
		diff = g1diff >= g2diff and ilvl - g2diff or ilvl - g1diff
	elseif g1diff then
		diff = ilvl - g1diff
	elseif g2diff then
		diff = ilvl - g2diff
	end
	return diff
end

---@param link #The itemLink of the item.
---@return #If the item level data is not available, return nil. Otherwise, return the minimum item level of the gear created by the token.
---@deprecated v3.13.0: No longer tracks token ilvl as that's contained on the token.
function RCLootCouncil:GetTokenIlvl(link)
	local id = ItemUtils:GetItemIDFromLink(link)
	if not id then return end
	local baseIlvl = _G.RCTokenIlvl[id] -- ilvl in normal difficulty
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
			for loc, slot in pairs(self.INVTYPE_Slots) do if slot == tokenSlot then return loc end end
		end
	end
	return ""
end

function RCLootCouncil:Timer(type, ...)
	self.Log:d("Timer " .. type .. " passed")
	if type == "MLdb_check" then
		-- If we have a ML
		if self.masterLooter then
			-- But haven't received the mldb, then request it
			if not self.mldb.buttons then self:Send(self.masterLooter, "MLdb_request") end
			-- and if we haven't received a council, request it
			if Council:GetNum() == 0 then self:Send(self.masterLooter, "council_request") end
		end
	end
end

function RCLootCouncil:SendGuildVerTest()
	Comms:Send{prefix = self.PREFIXES.VERSION, target = "guild", command = "v", data = {self.version, self.tVersion}}
end

--- Adds needed variables to the loot table.
-- Should only be called once when the loot table is received (RCLootCouncil:OnCommReceived).
-- v2.15 The current implementation ensures this only gets called when all items are cached - this function relies on that!
function RCLootCouncil:PrepareLootTable(lootTable)
	for ses, v in pairs(lootTable) do
		local _, link, rarity, ilvl, _, _, subType, _, equipLoc, texture, _, typeID, subTypeID, bindType, _, _, _ =
						C_Item.GetItemInfo(ItemUtils:UncleanItemString(v.string))
		local itemID = C_Item.GetItemInfoInstant(link)
		v.link = link
		v.itemID = itemID
		v.quality = rarity
		v.ilvl = self:GetTokenIlvl(v.link) or ilvl
		v.equipLoc = RCTokenTable[itemID] and self:GetTokenEquipLoc(RCTokenTable[itemID]) or equipLoc
		v.subType = subType -- Subtype should be in our locale
		v.texture = texture
		v.token = itemID and RCTokenTable[itemID]
		v.boe = bindType == Enum.ItemBind.OnEquip
		v.typeID = typeID
		v.subTypeID = subTypeID
		v.session = v.session or ses
		v.classes = self:GetItemClassesAllowedFlag(link)
		v.typeCode = v.typeCode or "default"
	end
end

--- Sends a lootAck to the group containing session related data.
-- specID, average ilvl and corruption is sent once.
-- Currently equipped gear and "diff" is sent for each session.
-- Autopass response is sent if the session has been autopassed. No other response is sent.
-- @param skip Only sends lootAcks on sessions > skip or 0
function RCLootCouncil:SendLootAck(table, skip)
	local toSend = {gear1 = {}, gear2 = {}, diff = {}, response = {}, roll = {}}
	local hasData = false
	for k, v in pairs(table) do
		local session = v.session or k
		if session > (skip or 0) then
			hasData = true
			local g1, g2 = self:GetGear(v.link, v.equipLoc, v.relic)
			local diff = self:GetIlvlDifference(v.link, g1, g2)
			toSend.gear1[session] = g1 and ItemUtils:GetItemStringClean(g1) or nil
			toSend.gear2[session] = g2 and ItemUtils:GetItemStringClean(g2) or nil
			toSend.diff[session] = diff
			toSend.response[session] = v.autopass
			toSend.roll[session] = (v.isRoll and v.autopass and "-") or v.isRoll and "?" or nil
		end
	end
	if not next(toSend.roll) then toSend.roll = nil end
	if hasData then self:Send("group", "lootAck", playersData.specID, playersData.ilvl, toSend) end
end

-- Sets lootTable[session].autopass = true if an autopass occurs, and informs the user of the change
-- @param skip Will only auto pass sessions > skip or 0
function RCLootCouncil:DoAutoPasses(table, skip)
	for k, v in pairs(table) do
		local session = v.session or k
		if session > (skip or 0) then
			if db.autoPass and not v.noAutopass then
				if (v.boe and db.autoPassBoE) or not v.boe then
					if self:AutoPassCheck(v.link, v.equipLoc, v.typeID, v.subTypeID, v.classes, v.token, v.relic) then
						self.Log("Autopassed on: ", v.link)
						if not db.silentAutoPass then self:Print(format(L["Autopassed on 'item'"], ItemUtils:GetItemTextWithIcon(v.link))) end
						v.autopass = true
					end
				else
					self.Log("Didn't autopass on: " .. v.link .. " because it's BoE!")
				end
			end
		end
	end
end

function RCLootCouncil:GetLootTable() return lootTable end

--[[
1	Warrior			WARRIOR
2	Paladin			PALADIN
3	Hunter			HUNTER
4	Rogue			ROGUE
5	Priest			PRIEST
6	Death Knight	DEATHKNIGHT
7	Shaman			SHAMAN
8	Mage			MAGE
9	Warlock			WARLOCK
10	Monk			MONK
11	Druid			DRUID
12	Demon Hunter	DEMONHUNTER
13	Evoker 			EVOKER
--]]
function RCLootCouncil:InitClassIDs()
	self.classDisplayNameToID = {} -- Key: localized class display name. value: class id(number)
	self.classTagNameToID = {} -- key: class name in capital english letters without space. value: class id(number)
	self.classIDToDisplayName = {} -- key: class id. Value: localized name
	self.classTagNameToDisplayName = {} --- @type table<string,string> Class File name to display name
	self.classIDToFileName = {} -- key: class id. Value: File name
	for i = 1, self.Utils.GetNumClasses() do
		local info = C_CreatureInfo.GetClassInfo(i)
		if info then -- Just in case class doesn't exists #Classic
			self.classDisplayNameToID[info.className] = i
			self.classTagNameToID[info.classFile] = i
			self.classTagNameToDisplayName[info.classFile] = info.className
		end
	end
	self.classIDToDisplayName = tInvert(self.classDisplayNameToID)
	self.classIDToFileName = tInvert(self.classTagNameToID)
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
		local line = getglobal(tooltipForParsing:GetName() .. 'TextLeft' .. i)
		if line and line.GetText then
			local text = line:GetText() or ""
			local classesText = text:match(itemClassesAllowedPattern)
			if classesText then
				tooltipForParsing:Hide()
				-- After reading the Blizzard code, I suspect that it's maybe not intended for Blizz to use ", " for all locales. (Patch 7.3.2)
				-- The most strange thing is that LIST_DELIMITER is defined first in FrameXML/GlobalStrings.lua as "%s, %s" and it's not the same for all locales.
				-- Then LIST_DELIMITER is redefined to ", " for all locales in FrameXML/MerchantFrame.lua
				-- Try some other delimiter constants in case Blizzard changes it some time in the future.
				if LIST_DELIMITER and LIST_DELIMITER ~= "" and classesText:find(LIST_DELIMITER:gsub("%%s", "")) then
					delimiter = LIST_DELIMITER:gsub("%%s", "")
				elseif PLAYER_LIST_DELIMITER and PLAYER_LIST_DELIMITER ~= "" and classesText:find(PLAYER_LIST_DELIMITER) then
					delimiter = PLAYER_LIST_DELIMITER
				end

				local result = 0
				for className in string.gmatch(classesText .. delimiter, "(.-)" .. delimiter) do
					local classID = self.classDisplayNameToID[className]
					if classID then
						result = result + bit.lshift(1, classID - 1)
					else
						-- sth is wrong (should never happen)
						self.Log:E("Getting classes flag for ", item, " - class does not exist", className)
					end
				end
				return result
			end
		end
	end
	tooltipForParsing:Hide()
	return 0xffffffff -- The item works for all classes
end


--- Extracts all lines from item's tooltip.
--- @param item ItemID|ItemLink|ItemString Item to extract tooltip for.
--- @return string[] #All lines in the tooltip.
function RCLootCouncil:GetTooltipLines(item)
	if not item then return {} end
	if type(item) == "number" then
		item = "item:" .. item
	end
	tooltipForParsing:SetOwner(UIParent, "ANCHOR_NONE") -- This lines clear the current content of tooltip and set its position off-screen
	tooltipForParsing:SetHyperlink(item)             -- Set the tooltip content and show it, should hide the tooltip before function ends
	local ret = {}
	for i = 1, tooltipForParsing:NumLines() or 0 do
		local line = getglobal(tooltipForParsing:GetName() .. "TextLeft" .. i)
		if line and line.GetText then
			local text = line:GetText() or ""
			ret[i] = text
		end
	end
	tooltipForParsing:Hide()
	return ret
end

local classNamesFromFlagCache = {}

--- Gets class names from classes flag.
---@param classesFlag string bitwise flag from GetItemClassesAllowedFlag.
---@return string #Colored class names extracted from flag, seperated by comma.
function RCLootCouncil:GetClassNamesFromFlag(classesFlag)
	if classNamesFromFlagCache[classesFlag] then return classNamesFromFlagCache[classesFlag] end
	local result = TT.Acquire("")
	local j = 1
	for i = 1, self.Utils.GetNumClasses() do
		if bit.band(classesFlag, bit.lshift(1, i - 1)) > 0 then
			local class = self.classIDToFileName[i]
			local classText = self.classIDToDisplayName[i]
			result[(j - 1) * 2 + 1] = _G.GetClassColorObj(class):WrapTextInColorCode(classText)
			result[(j - 1) * 2 + 2] = ", "
			j = j + 1
		end
	end
	result[#result] = nil -- Remove last ", "
	local text = table.concat(result, "")
	TT:Release(result)
	classNamesFromFlagCache[classesFlag] = text
	return text
end

--- Parses an item tooltip looking for corruption stat
-- @param item The item to find corruption for
-- @return 0 or the amount of corruption on the item.
-- COMBAK: This should be part of a generic ToolTip parser system in the future.
function RCLootCouncil:GetCorruptionFromTooltip(item)
	if not item then return 0 end
	tooltipForParsing:SetOwner(UIParent, "ANCHOR_NONE")
	tooltipForParsing:SetHyperlink(item)

	local pattern = _G.ITEM_CORRUPTION_BONUS_STAT:gsub("%%d", "%(%%d%+%)")
	for i = 1, tooltipForParsing:NumLines() do
		local line = getglobal(tooltipForParsing:GetName() .. 'TextLeft' .. i)
		if line and line.GetText then
			local text = line:GetText()
			local found = text:match(pattern)
			if found then return tonumber(found) end
		end
	end
	-- Didn't find anything
	return 0
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
	if not tooltipForParsing:NumLines() or tooltipForParsing:NumLines() == 0 then return 0 end

	local bindTradeTimeRemainingPattern = escapePatternSymbols(BIND_TRADE_TIME_REMAINING) -- Escape special characters in translations
		:gsub("1%%%$", "") -- Remove weird insertion in RU '%1$s'
		:gsub("%%%%s", "%(%.%+%)") -- Create capture group for the time string
	local bounded = false

	for i = 1, tooltipForParsing:NumLines() or 0 do
		local line = getglobal(tooltipForParsing:GetName() .. 'TextLeft' .. i)
		if line and line.GetText then
			local text = line:GetText() or ""
			if text == ITEM_SOULBOUND or text == ITEM_ACCOUNTBOUND or text == ITEM_BNETACCOUNTBOUND or text == ITEM_ACCOUNTBOUND_UNTIL_EQUIP then bounded = true end

			local timeText = text:match(bindTradeTimeRemainingPattern)
			if timeText then -- Within 2h trade window, parse the time text
				tooltipForParsing:Hide()

				for hour = 4, 0, -1 do -- time>=60s, format: "1 hour", "1 hour 59 min", "59 min", "1 min"
					local hourText = ""
					if hour > 0 then hourText = self:CompleteFormatSimpleStringWithPluralRule(INT_SPELL_DURATION_HOURS, hour) end
					for min = 59, 0, -1 do
						local time = hourText
						if min > 0 then
							if time ~= "" then time = time .. TIME_UNIT_DELIMITER end
							time = time .. self:CompleteFormatSimpleStringWithPluralRule(INT_SPELL_DURATION_MIN, min)
						end

						if time == timeText then return hour * 3600 + min * 60 end
					end
				end
				for sec = 59, 1, -1 do -- time<60s, format: "59 s", "1 s"
					local time = self:CompleteFormatSimpleStringWithPluralRule(INT_SPELL_DURATION_SEC, sec)
					if time == timeText then return sec end
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

--- Finds all items in players bags that has a trade timer.
---@return itemLink[] items
function RCLootCouncil:GetAllItemsInBagsWithTradeTimer()
	local items = {}
	for container=0, _G.NUM_BAG_SLOTS do
         for slot=1, self.C_Container.GetContainerNumSlots(container) or 0 do
			local time =self:GetContainerItemTradeTimeRemaining(container, slot)
			if  time > 0 and time < math.huge then
				tinsert(items, self.C_Container.GetContainerItemLink(container, slot))

			end
		 end
	end
	return items
end

function RCLootCouncil:IsItemBoE(item)
	if not item then return false end
	return select(14, C_Item.GetItemInfo(item)) == Enum.ItemBind.OnEquip and not C_Item.IsItemBindToAccountUntilEquip(item)
end

function RCLootCouncil:IsItemBoP(item)
	if not item then return false end
	-- Item binding type: 0 - none; 1 - on pickup; 2 - on equip; 3 - on use; 4 - quest.
	return select(14, C_Item.GetItemInfo(item)) == Enum.ItemBind.OnAcquire
end

function RCLootCouncil:GetPlayersGuildRank()
	self.Log:D("GetPlayersGuildRank()")
	self.Utils:GuildRoster() -- let the event trigger this func
	if IsInGuild() then
		local rank = select(2, GetGuildInfo("player"))
		if rank then
			self.Log:d("Found Guild Rank: " .. rank)
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
-- @return "Name", "Class", "Role", "guildRank", bool isEnchanter, num enchanting_lvl, num ilvl, num specID
function RCLootCouncil:GetPlayerInfo()
	-- Check if the player has enchanting
	local enchant, lvl = nil, 0
	local profs = {GetProfessions()}
	for i = 1, 2 do
		if profs[i] then
			local _, _, rank, _, _, _, id = GetProfessionInfo(profs[i])
			if id and id == 333 then -- NOTE: 333 should be enchanting, let's hope that holds...
				self.Log:d("I'm an enchanter")
				enchant, lvl = true, rank
				break
			end
		end
	end
	local ilvl = select(2, GetAverageItemLevel())
	return self.Utils:GetPlayerRole(), self.guildRank, enchant, lvl, ilvl, playersData.specID
end

--- Send player info to the target/group
---@param target string? Player name or "group". Defaults to "group".
function RCLootCouncil:SendPlayerInfo(target)
	local commsTarget = target and target ~= "group" and Player:Get(target) or "group"
	Comms:Send { target = commsTarget, command = "pI", data = { self:GetPlayerInfo(), }, }
end

--- Returns a lookup table containing GuildRankNames and their index.
-- @return table ["GuildRankName"] = rankIndex
function RCLootCouncil:GetGuildRanks()
	if not IsInGuild() then return {} end
	self.Log:d("GetGuildRankNum()")
	self.Utils:GuildRoster()
	local t = {}
	for i = 1, GuildControlGetNumRanks() do
		local name = GuildControlGetRankName(i)
		t[name] = i
	end
	return t;
end

function RCLootCouncil:UpdateCandidatesInGroup()
	wipe(self.candidatesInGroup)
	local name;
	for i = 1, GetNumGroupMembers() do
		name = GetRaidRosterInfo(i)
		if not name then -- Not ready yet, delay a bit
			self.Log:D("GetRaidRosterInfo returned nil in UpdateCandidatesInGroup")
			self:ScheduleTimer("UpdateCandidatesInGroup", 1)
			return {}
		end
		self.candidatesInGroup[self:UnitName(name)] = true
	end
	-- Ensure we're there
	self.candidatesInGroup[self.player.name] = true
	return self.candidatesInGroup
end

--- Iterates over all group members
---@return fun():string
function RCLootCouncil:GroupIterator()
	-- Get group members
	local groupMembers = {}
	local i = 1
	for name in pairs(self:UpdateCandidatesInGroup()) do
		groupMembers[i] = name
		i = i + 1
	end

	i = 0
	local n = #groupMembers
	return function()
		i = i + 1
		if i <= n then return groupMembers[i] end
	end
end

--- Returns the number of group members, the player included (i.e. min 1).
function RCLootCouncil:GetNumGroupMembers()
	local num = GetNumGroupMembers()
	return num > 0 and num or 1
end

local function CandidateAndNewMLCheck()
	RCLootCouncil:UpdateCandidatesInGroup()
	RCLootCouncil:NewMLCheck()
end

function RCLootCouncil:OnEvent(event, ...)
	if event == "PARTY_LOOT_METHOD_CHANGED" then
		self.Log:d("Event:", event, ...)
		self:ScheduleTimer(CandidateAndNewMLCheck, 2)
	elseif event == "PARTY_LEADER_CHANGED" then
		self.Log:d("Event:", event, ...)
		self:ScheduleTimer(CandidateAndNewMLCheck, 2)
	elseif event == "GROUP_LEFT" then
		self.Log:d("Event:", event, ...)
		self:UpdateCandidatesInGroup()
		self:NewMLCheck()

	elseif event == "RAID_INSTANCE_WELCOME" then
		self.Log:d("Event:", event, ...)
		-- high server-side latency causes the UnitIsGroupLeader("player") condition to fail if queried quickly (upon entering instance) regardless of state.
		-- NOTE v2.0: Not sure if this is still an issue, but just add a 2 sec timer to the MLCheck call
		self:ScheduleTimer("OnRaidEnter", 2)

	elseif event == "PLAYER_ENTERING_WORLD" then
		self.Log:d("Event:", event, ...)
		local isReload = select(2, ...)
		self:UpdatePlayersData()
		self:ScheduleTimer(CandidateAndNewMLCheck, 2)
		self:ScheduleTimer(function() -- This needs some time to be ready
			local instanceName, _, _, difficultyName = GetInstanceInfo()
			self.currentInstanceName = instanceName .. (difficultyName ~= "" and "-" .. difficultyName or "")
			if not isReload then self:SnapshotInstanceData() end -- Will be restored from cache
		end, 5)

		if isReload then
			self.Log("Player relog...")

			-- Don't restore if we're switching to a different character.
			if self.db.global.cache.cachePlayer == self.player:GetName() then
				-- Restore masterlooter from cache, but only if not already set.
				if not self:HasValidMasterLooter() and self.db.global.cache.masterLooter then
					self.masterLooter = Player:Get(self.db.global.cache.masterLooter)
					self.isMasterLooter = self.masterLooter == self.player
					if self.isMasterLooter then
						self:CallModule("masterlooter")
						self:GetActiveModule("masterlooter"):NewML(self.masterLooter)
					end
				end
				self.Log:d("ML, Cached:", self.masterLooter, self.isMasterLooter, self.db.global.cache.masterLooter)

				-- Restore mldb and council
				if self.db.global.cache.mldb then
					self:OnMLDBReceived(self.db.global.cache.mldb)
				end
				if self.masterLooter and self.db.global.cache.council then
					self:OnCouncilReceived(self.masterLooter, self.db.global.cache.council)
				end

				-- Restore handleLoot
				self.Log:D("Cached handleLoot:", self.db.global.cache.handleLoot)
				if self.db.global.cache.handleLoot and self.isMasterLooter then
					self:StartHandleLoot()
				elseif self.db.global.cache.handleLoot then
					self:OnStartHandleLoot()
				end

				self.instanceDataSnapshot = self.db.global.cache.lastEncounterInstanceData
			end
			wipe(self.db.global.cache) -- No reason to store data forever

			-- If we still haven't set masterLooter, try delaying a bit.
			-- but we don't have to wait if we got it from cache.
			-- ? REVIEW: This might not be needed anymore.
			self:ScheduleTimer(function()
				if not self.isMasterLooter and self.masterLooter and self.masterLooter ~= "" then
					self:SendPlayerInfo("group") -- Also send out info, just in case
					self:Send(self.masterLooter, "reconnect")
					self.Log:d("Sent Reconnect Request")
				end
			end, self.masterLooter and 0 or 2.1)
		end
	elseif event == "PLAYER_LOGOUT" then
		self.Log:d("Event:", event, ...)
		if not self.db.global.cache then self.db.global.cache = {} end
		self.db.global.cache.mldb = next(self.mldb) and MLDB:GetForTransmit(self.mldb) or nil
		self.db.global.cache.council = Council:GetNum() > 0 and Council:GetForTransmit() or nil
		self.db.global.cache.masterLooter = self.masterLooter and self.masterLooter:GetGUID()
		self.db.global.cache.handleLoot = self.handleLoot
		self.db.global.cache.instanceData = self.instanceDataSnapshot
		self.db.global.cache.cachePlayer = self.player:GetName()

	elseif event == "ENCOUNTER_START" then
		self.Log:d("Event:", event, ...)
		self:UpdatePlayersData()
	elseif event == "GUILD_ROSTER_UPDATE" then
		self.guildRank = self:GetPlayersGuildRank();
		if unregisterGuildEvent then
			self:UnregisterEvent("GUILD_ROSTER_UPDATE"); -- we don't need it any more
			-- v2.9: Handled in options
			-- self:GetGuildOptions() -- get the guild data to the options table now that it's ready
		end
	elseif event == "ENCOUNTER_END" then
		self.Log:d("Event:", event, ...)
		self.lastEncounterID, self.bossName = ... -- Extract encounter name and ID
		self:SnapshotInstanceData()
		wipe(self.nonTradeables)

	elseif event == "LOOT_CLOSED" then
		if not IsInInstance() then return end -- Don't do anything out of instances
		self.Log:d("Event:", event, ...)
		for k, info in pairs(self.lootSlotInfo) do
			if not info.isLooted and info.guid and info.link then
				if tContains(itemsBeingGroupLooted, info.link) then
					-- Don't bother with group looted items
					return
				end
				if info.autoloot then -- We've looted the item without getting LOOT_SLOT_CLEARED, properly due to FastLoot addons
					return self:OnEvent("LOOT_SLOT_CLEARED", k), self:OnEvent("LOOT_CLOSED")
				end

				return
			end
		end
		self.lootOpen = false

	elseif event == "LOOT_SLOT_CLEARED" then
		local slot = ...
		if self.lootSlotInfo[slot] and not self.lootSlotInfo[slot].isLooted then -- If not, this is the 2nd LOOT_CLEARED event for the same thing. -_-
			local link = self.lootSlotInfo[slot].link
			local quality = self.lootSlotInfo[slot].quality
			self.Log:d("OnLootSlotCleared()", slot, link, quality)
			if quality and quality >= self.Utils:GetLootThreshold() and IsInInstance() then -- Only send when in instance
				-- Note that we don't check if this is master looted or not. We only know this is looted by ourselves.
				self:ScheduleTimer("UpdateAndSendRecentTradableItem", 2, self.lootSlotInfo[slot]) -- Delay a bit, need some time to between item removed from loot slot and moved to the bag.
			end
			self.lootSlotInfo[slot].isLooted = true

			if self.isMasterLooter then self:GetActiveModule("masterlooter"):OnLootSlotCleared(slot, link) end
		end
	elseif event == "ENCOUNTER_LOOT_RECEIVED" then
		self.Log:d("Event:", event, ...)

	elseif event == "LOOT_READY" then
		self.Log:d("Event:", event, ...)
		wipe(self.lootSlotInfo)
		if not IsInInstance() then return end -- Don't do anything out of instances
		if GetNumLootItems() <= 0 then return end -- In case when function rerun, loot window is closed.
		self.lootOpen = true
		for i = 1, GetNumLootItems() do
			if LootSlotHasItem(i) then
				local texture, name, quantity, currencyID, quality = GetLootSlotInfo(i)
				local guid = self.Utils:ExtractCreatureID((GetLootSourceInfo(i)))
				if guid and self.lootGUIDToIgnore[guid] then return self.Log:d("Ignoring loot from ignored source", guid) end
				if texture then
					local link = GetLootSlotLink(i)
					if currencyID or quantity == 0 then
						self.Log:d("Ignoring", link, "as it's a currency")
					elseif not self.Utils:IsItemBlacklisted(link) then
						self.Log:d("Adding to self.lootSlotInfo", i, link, quality, quantity, GetLootSourceInfo(i))
						self.lootSlotInfo[i] = {
							name = name,
							link = link, -- This could be nil, if the item is money.
							quantity = quantity,
							quality = quality,
							guid = guid, -- Boss GUID
							boss = (GetUnitName("target")),
							autoloot = select(1, ...),
						}
					end
				else -- It's possible that item in the loot window is uncached. Retry in the next frame.
					self.Log:d("Loot uncached when the loot window is opened. Retry in the next frame.", name)
					-- Must offer special argument as 2nd argument to indicate this is run from scheduler.
					-- REVIEW: 20/12-18: This actually hasn't been used for a long while - removing "scheduled" arg
					return self:ScheduleTimer("OnEvent", 0, "LOOT_READY")
				end
			end
		end
	else
		self.Log:d("NonHandled Event:", event, ...)
	end
end

function RCLootCouncil:OnBonusRoll(_, type, link, ...)
	self.Log:d("BONUS_ROLL", type, link, ...)
	if type == "item" or type == "artifact_power" then
		-- Only handle items and artifact power
		self:Send("group", "bonus_roll", type, link)
	end
	--[[
		Tests:
		/run RCLootCouncil:OnBonusRoll("", "artifact_power", "|cff0070dd|Hitem:144297::::::::110:256:8388608:3::26:::|h[Talisman of Victory]|h|r")
		/run RCLootCouncil:OnBonusRoll("", "item", "|cffa335ee|Hitem:140851::::::::110:256::3:3:3443:1467:1813:::|h[Nighthold Custodian's Hood]|h|r")

	]]
end

--- Called on event `ACTIVE_PLAYER_SPECIALIZATION_CHANGED`
function RCLootCouncil:OnSpecChanged()
	-- If our role changed, send playerinfo
	if self.player.role ~= self.Utils:GetPlayerRole() then
		self:SendPlayerInfo()
	end
end

---@return InstanceDataSnapshot
function RCLootCouncil:GetInstanceData()
	local instanceName, _, difficultyID, difficultyName, _, _, _, mapID, groupSize = GetInstanceInfo()
	return {
		instanceName = instanceName,
		difficultyID = difficultyID,
		difficultyName = difficultyName,
		mapID = mapID,
		groupSize = groupSize,
		timestamp = GetServerTime(),
	}
end

--- Snapshots and returns the current instance data.
--- Data is cached in `self.instanceDataSnapshot`
function RCLootCouncil:SnapshotInstanceData()
	self.instanceDataSnapshot = self:GetInstanceData()
	return self.instanceDataSnapshot
end

---@param override InstanceDataSnapshot? Defaults to `self.instanceDataSnapshot`
---@return boolean
function RCLootCouncil:IsInstanceDataSnapshotValid(override)
	local data = override or self.instanceDataSnapshot or self:SnapshotInstanceData()
	return data and data.timestamp and data.timestamp > GetServerTime() - self.INSTANCE_DATA_TTL
end

---@return boolean #True if the player is in a guild group or alone.
function RCLootCouncil:IsInGuildGroup()
	local numGroupMembers = GetNumGroupMembers()
	if numGroupMembers == 1 then return true end -- Always when alone
	local guildMembers = 0
	local isInGuild
	local guid
	for name in self:GroupIterator() do
		guid = Player:Get(name):GetGUID()
		if guid and guid ~= "" then
			isInGuild = IsGuildMember(guid)
			guildMembers = guildMembers + (isInGuild and 1 or 0)
		else
			self.Log:e("IsInGuildGroup: No GUID for player", name)
		end
	end
	if numGroupMembers <= 5 then -- party
		return guildMembers >= (numGroupMembers * 0.6)
	else -- raid
		return guildMembers >= (numGroupMembers * 0.8)
	end
end

function RCLootCouncil:HasValidMasterLooter()
	if not self.masterLooter then return false end
	if type(self.masterLooter) == "string" then
		return not (self.masterLooter == "Unknown" or Ambiguate(self.masterLooter, "short"):lower() == _G.UNKNOWNOBJECT:lower())
	elseif type(self.masterLooter) == "table" then
		return self.masterLooter:GetName() ~= ""
	end
	-- Should never reach this
	self.Log:E("Invalid masterlooter:", self.masterLooter)
end

function RCLootCouncil:NewMLCheck()
	local old_ml = self.masterLooter
	local old_lm = self.lootMethod
	self.isMasterLooter, self.masterLooter = self:GetML()
	self.lootMethod = GetLootMethod()
	local instance_type = select(2, IsInInstance())
	if instance_type == "pvp" or instance_type == "arena" or instance_type == "scenario" then return end -- Don't do anything here
	if self.masterLooter and type(self.masterLooter) == "string"
					and (self.masterLooter == "Unknown" or Ambiguate(self.masterLooter, "short"):lower() == _G.UNKNOWNOBJECT:lower()) then
		-- ML might be unknown for some reason
		self.Log:d("Unknown ML")
		return self:ScheduleTimer("NewMLCheck", 0.5)
	end

	if not self.isMasterLooter and self:GetActiveModule("masterlooter"):IsEnabled() then -- we're not ML, so make sure it's disabled
		self:StopHandleLoot()
	end
	if self.Utils:IsPartyLFG() then return end -- We can't use in lfg/lfd so don't bother
	if not self.masterLooter then return end -- Didn't find a leader or ML.
	self.isInGuildGroup = self:IsInGuildGroup()
	if self:UnitIsUnit(old_ml, self.masterLooter) then
		if old_lm == self.lootMethod then
			if self.isMasterLooter and not IsInRaid() and db.onlyUseInRaids then -- We might have switched to party
				if self.handleLoot then self:StopHandleLoot() end
			end
			return -- Both ML and loot method have not changed
		end
	else
		-- At this point we know the ML has changed, so we can wipe the council
		self.Log:d("Resetting council as we have a new ML!")
		self.isCouncil = false
		self.Log("MasterLooter", self.masterLooter, "LootMethod", self.lootMethod)
		-- Check to see if we have recieved mldb within 15 secs, otherwise request it
		self:ScheduleTimer("Timer", 15, "MLdb_check")
		self.handleLoot = false -- Whatever we had from old ML is no longer valid
	end

	if not self.isMasterLooter then -- Someone else has become ML
		return
	else -- REVIEW: Ideally this should only be calle when we've activated addon.
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

	-- New group loot is reported as "personalloot" -.-
	if (self.lootMethod == "group" and db.usage.gl) or (self.lootMethod == "personalloot" and db.usage.gl) then -- auto start
		self:StartHandleLoot()
	elseif (self.lootMethod == "group" and db.usage.ask_gl) or (self.lootMethod == "personalloot" and db.usage.ask_gl) then
		return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")
	end
end

--- Enables the addon to automatically handle looting
function RCLootCouncil:StartHandleLoot()
	-- local lootMethod = GetLootMethod()
	-- if lootMethod ~= "group" and self.lootMethod ~= "personalloot" then -- Set it
	-- 	SetLootMethod("group")
	-- end
	-- We might call StartHandleLoot() without ML being initialized, e.g. with `/rc start`.
	if not self:GetActiveModule("masterlooter"):IsEnabled() then
		self:CallModule("masterlooter")
	end
	self:GetActiveModule("masterlooter"):NewML(self.masterLooter)
	self:Print(L["Now handles looting"])
	self.Log("Start handling loot")
	self.handleLoot = true
	self:Send("group", "StartHandleLoot")
	if #db.council == 0 then -- if there's no council
		self:Print(L["You haven't set a council! You can edit your council by typing '/rc council'"])
	end
end

--- Disables loot handling
function RCLootCouncil:StopHandleLoot()
	self.Log("Stop handling loot")
	self.handleLoot = false
	self:GetActiveModule("masterlooter"):Disable()
	self:Send("group", "StopHandleLoot")
end

function RCLootCouncil:OnRaidEnter()
	-- NOTE: We shouldn't need to call GetML() as it's most likely called on "LOOT_METHOD_CHANGED"
	if self.Utils:IsPartyLFG() or db.usage.never then return end -- We can't use in lfg/lfd so don't bother
	-- Check if we can use in party
	if not IsInRaid() and db.onlyUseInRaids then return end
	if UnitIsGroupLeader("player") then
		if db.usage.gl then
			self:StartHandleLoot()
			-- We must ask the player for usage
		elseif db.usage.ask_gl then
			return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")
		end
	else
		self:ScheduleTimer(CandidateAndNewMLCheck, 1)
	end
end

--- Gets information about the current Master Looter, if any.
-- @return boolean, "ML_Name". (true if the player is ML), (nil if there's no ML).
function RCLootCouncil:GetML()
	self.Log:d("GetML()")
	if self.Utils:IsPartyLFG() then return false, nil end -- Never use in LFG
	if GetNumGroupMembers() == 0 and (self.testMode or self.nnp) then -- always the player when testing alone
		return true, self.player
	end
	-- Set the Group leader as the ML
	local name
	for i = 1, GetNumGroupMembers() or 0 do
		local name2, rank = GetRaidRosterInfo(i)
		if not name2 then -- Group info is not completely ready
			return false, "Unknown"
		end
		if rank == 2 then -- Group leader. Btw, name2 can be nil when rank is 2.
			name = self:UnitName(name2)
			break
		end
	end
	if name then return UnitIsGroupLeader("player"), Player:Get(name) end
	return false, nil;
end

function RCLootCouncil:GetInstalledModulesFormattedData()
	local modules = {}
	-- We're interested in everything that isn't a default module
	local test = function(name) for _, k in pairs(defaultModules) do if k == name then return true end end end
	for k in pairs(self.modules) do if not test(k) then tinsert(modules, k) end end
	-- Now for the formatting
	for num, name in pairs(modules) do
		if self:GetModule(name).version then -- People might not have added version
			modules[num] = self:GetModule(name).baseName .. " - " .. self:GetModule(name).version
			if self:GetModule(name).tVersion then modules[num] = modules[num] .. "-" .. self:GetModule(name).tVersion end
		else
			local ver = C_AddOns.GetAddOnMetadata(self:GetModule(name).baseName, "Version")
			modules[num] = self:GetModule(name).baseName .. " - " .. (ver or _G.UNKNOWN)
		end
	end
	return modules
end

--- Checks if the history entry is available with more info settings.
--- @param entry HistoryEntry
--- @return boolean #True if the entry is not filtered, false if it is.
function RCLootCouncil:IsHistoryEntryAvailableWithMoreInfoSettings(entry)
	return not next(db.moreInfoRaids) or db.moreInfoRaids[entry.mapID .. "-" .. entry.difficultyID]
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
	self.Log:d("GetLootDBStatistics()")
	-- v2.4: This is very sensitive to errors in the loot history, which will most likely crash calling modules,
	-- as in ticket #261. For the sole reason of crash proofing, let's catch any errors:
	local check, ret = pcall(function()
		lootDBStatistics = {}
		local entry, id
		for name, data in pairs(self:GetHistoryDB()) do
			local count, responseText, color, numTokens, raids = {}, {}, {}, {}, {}
			local lastestAwardFound = 0
			lootDBStatistics[name] = {}
			for i = #data, 1, -1 do -- Start from the end
				entry = data[i]
				if self:IsHistoryEntryAvailableWithMoreInfoSettings(entry) then
					id = (entry.isAwardReason and "a" or entry.typeCode or "default") .. entry.responseID

					-- Tier Tokens
					if not numTokens[entry.instance] then
						numTokens[entry.instance] = 0
					end
					if entry.tierToken and not entry.isAwardReason then -- If it's a tierToken, increase the count
						numTokens[entry.instance] = numTokens[entry.instance] + 1
					end
					count[id] = count[id] and count[id] + 1 or 1
					responseText[id] = responseText[id] and responseText[id] or entry.response
					if (not color[id] or tCompare(color[id], {1, 1, 1, 1})) and (entry.color and #entry.color ~= 0) then -- If it's not already added
						color[id] = #entry.color ~= 0 and #entry.color == 4 and entry.color or {1, 1, 1, 1}
					end
					if lastestAwardFound < 5 and type(entry.responseID) == "number" and not entry.isAwardReason
					and (entry.responseID <= db.numMoreInfoButtons) then
						tinsert(lootDBStatistics[name], {
						entry.lootWon, --[[entry.response .. ", "..]]
						format(L["'n days' ago"], self.Utils:GetNumberOfDaysFromNow(entry.date)),
						color[id],
						i,
					})
					lastestAwardFound = lastestAwardFound + 1
					end
					-- Raids:
					raids[entry.date .. entry.instance] =
					raids[entry.date .. entry.instance] and raids[entry.date .. entry.instance] + 1 or 0
				end
			end
			-- Totals:
			local totalNum = 0
			lootDBStatistics[name].totals = {}
			lootDBStatistics[name].totals.tokens = numTokens
			lootDBStatistics[name].totals.responses = {}
			for idx, num in pairs(count) do
				tinsert(lootDBStatistics[name].totals.responses, {responseText[idx], num, color[idx], idx})
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
		self.Log:d(ret)
		self:Print("Something's wrong in your loot history. Please contact the author.")
	else
		return ret
	end
end

function RCLootCouncil:SessionError(...)
	self:Print(L["session_error"])
	self.Log:E(...)
end

function RCLootCouncil:Getdb() return db end

---@return RCLootCouncil.HistoryDB
function RCLootCouncil:GetHistoryDB() return self.lootDB.factionrealm end

function RCLootCouncil:UpdateDB()
	self.Log:D("UpdateDB")
	self.db:RegisterDefaults(self.defaults)
	db = self.db.profile
	self:ActivateSkin(self.db.profile.currentSkin)
	self:SendMessage("RCUpdateDB")
end

function RCLootCouncil:IsCorrectVersion() return WOW_PROJECT_MAINLINE == WOW_PROJECT_ID end

-- The link of same item generated from different players, or if two links are generated between player spec switch, are NOT the same
-- This function compares the raw item strings with link level and spec ID removed.
-- Also compare with unique id removed, because wowpedia says that:
-- "In-game testing indicates that the UniqueId can change from the first loot to successive loots on the same item."
-- Although log shows item in the loot actually has no uniqueId in Legion, but just in case Blizzard changes it in the future.
-- @return true if two items are the same item
function RCLootCouncil:ItemIsItem(item1, item2)
	if type(item1) ~= "string" or type(item2) ~= "string" then return item1 == item2 end
	item1 = self.Utils:DiscardWeaponCorruption(item1)
	item2 = self.Utils:DiscardWeaponCorruption(item2)
	item1 = ItemUtils:GetItemStringFromLink(item1)
	item2 = ItemUtils:GetItemStringFromLink(item2)
	if not (item1 and item2) then return false end -- KeyStones will fail the GetItemStringFromLink
	--[[ REVIEW Doesn't take upgradeValues into account.
		Doing that would require a parsing of the bonusIDs to check the correct positionings.
	]]
	return ItemUtils:NeutralizeItem(item1) == ItemUtils:NeutralizeItem(item2)
end

-- @param links. Table of strings. Any link in the table can contain connected links (links without space in between)
-- @return a list of links that contains all splitted item links
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
	local a1, b1, c1 = string.split(".", ver1)
	local a2, b2, c2 = string.split(".", ver2)
	if not (c1 and c2) then return end -- Check if it exists
	if a1 ~= a2 then
		return tonumber(a1) < tonumber(a2)
	elseif b1 ~= b2 then
		return tonumber(b1) < tonumber(b2)
	else
		return tonumber(c1) < tonumber(c2)
	end
end

function RCLootCouncil:ClearOldVerTestCandidates()
	local oneWeekAgo = time() - 604800
	for name, data in pairs(self.db.global.verTestCandidates) do
		if not data[3] -- Doesn't exist for ooold versions
		or data[3] < oneWeekAgo then self.db.global.verTestCandidates[name] = nil end
	end
end

-- from LibUtilities-1.0, which adds bonus index after bonus ID
-- therefore a patched version is reproduced here
-- replace with LibUtilities when bug is fixed
function RCLootCouncil:DecodeItemLink(itemLink)
	local bonusIDs = {}

	local linkType, itemID, enchantID, gemID1, gemID2, gemID3, gemID4, suffixID, uniqueID, linkLevel, specializationID,
	      upgradeTypeID, instanceDifficultyID, numBonuses, affixes = string.split(":", ItemUtils:GetItemStringFromLink(itemLink), 15)

	-- clean it up
	local color = string.match(itemLink, "|?c?f?f?(%x*)")
	if not color or color == "" then -- probably new custom color link type
		local quality = string.match(itemLink, "|cnIQ(.)")
		if not quality or quality == "" then -- no quality, use default
			color = ITEM_QUALITY_COLORS[0].color:GenerateHexColor()
		else
			color = ColorManager.GetColorDataForItemQuality(quality and tonumber(quality) or 0).color:GenerateHexColor()
		end
	end
	-- local linkType = string.match(itemLink, "|H(.*):")
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

function RCLootCouncil:UnitIsUnit(unit1, unit2) return self.Utils:UnitIsUnit(unit1, unit2) end

function RCLootCouncil:UnitName(unit) return self.Utils:UnitName(unit) end

function RCLootCouncil:IsMasterLooter(unit) return self:UnitIsUnit(unit, self.masterLooter) end

function RCLootCouncil:noop()
	-- Intentionally left empty
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

--- Returns the active module if found or fails silently.
---	Always use this when calling functions in another module.
--- @param module DefaultModules|UserModules Index in self.defaultModules.
--- @return RCLootCouncilML|RCLootFrame|RCLootHistory|VersionCheck|RCSessionFrame|RCVotingFrame|TradeUI|Sync #The module object of the active module or nil if not found. Prioritises userModules if set.
function RCLootCouncil:GetActiveModule(module)
---@diagnostic disable-next-line: return-type-mismatch
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
	for i = 1, select("#", ...) do self.customChatCmd[select(i, ...)] = {module = module, func = funcRef} end
	if cmdDesc then
		tinsert(self.chatCmdHelp, {cmd = cmdDesc, desc = desc, module = module})
	else
		tinsert(self.chatCmdHelp, {cmd = select(1, ...), desc = desc, module = module})
	end
end

-- #end Module support -----------------------------------------------------

function RCLootCouncil:DumpDebugVariables()
	self.Log:D("MasterLooter", self.masterLooter)
	self.Log:D("LootMethod", self.lootMethod)
	self.Log:D("HandleLoot", self.handleLoot)
	self.Log:D("IsCouncil", self.isCouncil)
	self.Log:D("CurrentInstanceName", self.currentInstanceName)
end

---------------------------------------------------------------------------
-- UI Functions used throughout the addon.
-- @section UI.
---------------------------------------------------------------------------

---@class TextButton : Button
---@field text FontString

--- @alias DoCellUpdateFunction fun(rowFrame:Frame, frame: TextButton, cols:table, row: number, realrow: number, column: number, fShow: boolean, table: table, ...: any): any

--- Used as a "DoCellUpdate" function for lib-st
--- @type DoCellUpdateFunction
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
		return {r = 1, g = 1, b = 1, a = 1} -- {["r"] = 0.63921568627451, ["g"] = 0.2078431372549, ["b"] = 0.93333333333333, ["a"] = 1.0 };
	else
		color.a = 1.0
		return color
	end
end

--- Gets a class color wrapped string of the name
---@param name string Name of the player.
function RCLootCouncil:GetUnitClassColoredName(name)
	local player = Player:Get(name)
	if player then
		return player:GetClassColoredName()
	else
		local englishClass = select(2, UnitClass(Ambiguate(name, "short")))
		return self:WrapTextInClassColor(englishClass, self.Ambiguate(name))
	end
end

--- 2/3s of `GetClassColoredTextForUnit` - useful when you have class but not a valid unit.
---@param class ClassFile Class to use color from.
---@param text string Text to wrap.
function RCLootCouncil:WrapTextInClassColor(class, text)
	local color = GetClassColorObj(class)
	return color and color:WrapTextInColorCode(text) or text
end

--- Creates a string with class icon in front of a class colored name of the player.
---@param nameOrPlayer string|Player
---@param size number? Size of the icon, defaults to 12.
function RCLootCouncil:GetClassIconAndColoredName(nameOrPlayer, size)
	local player = type(nameOrPlayer) == "string" and Player:Get(nameOrPlayer) or nameOrPlayer
	size = size or 12
	if not (player and player:GetClass()) then
		self.Log:E("GetClassIconAndColoredName: No class found for ", nameOrPlayer)
		return nameOrPlayer --[[@as string]] or ""
	end
	return format("|W%s|w", self:AddClassIconToText(player:GetClass(), player:GetClassColoredName()))
end

local classAtlasCache = {}

--- Adds class icon in front of text.
---@param class ClassFile Class name to add
---@param text string Text
---@param size number? Size of the icon
function RCLootCouncil:AddClassIconToText(class, text, size)
	size = size or 12
	local id = class..size
	if not classAtlasCache[id] then
		classAtlasCache[id] = CreateAtlasMarkup(self.CLASS_TO_ATLAS[class], size, size)
	end
	return format("%s %s", classAtlasCache[id], text)
end

--- Creates a string with spec icon in front of a class colored name of the player.
--- Uses class icon if specID is not available.
---@param nameOrPlayer string|Player
---@param size number? Size of the icon, defaults to 12.
function RCLootCouncil:GetSpecIconAndColoredName(nameOrPlayer, size)
	local player = type(nameOrPlayer) == "string" and Player:Get(nameOrPlayer) or nameOrPlayer
	size = size or 12
	if not (player and player.specID and type(player.specID) == "number") then
		-- No spec ID, fallback to class
		return self:GetClassIconAndColoredName(player or nameOrPlayer, size)
	end
	return format("|W%s|w", self:AddSpecIconToText(player.specID, player:GetClassColoredName(), size))
end

local specIconCache = {}

---Adds spec icon in front of text.
---@param specID integer SpecID
---@param text string Text
---@param size number? Size of the icon, defaults to 12.
function RCLootCouncil:AddSpecIconToText(specID, text, size)
	size = size or 12
	local specIcon = select(4, GetSpecializationInfoByID(specID))
	local id = specIcon .. "-" .. size
	if not specIconCache[id] then
		specIconCache[id] = CreateSimpleTextureMarkup(specIcon, size)
	end
	return format("%s %s", specIconCache[id], text)
end

-- cName is name of the module
function RCLootCouncil:CreateGameTooltip(cName, parent)
	local itemTooltip = CreateFrame("GameTooltip", cName .. "_ItemTooltip", parent, "GameTooltipTemplate")
	itemTooltip:SetClampedToScreen(false)
	itemTooltip:SetScale(parent and parent:GetScale() * .95 or 1) -- Don't use parent scale
	-- Some addons hook GameTooltip. So copy the hook.
	-- itemTooltip:SetScript("OnTooltipSetItem", GameTooltip:GetScript("OnTooltipSetItem"))

	itemTooltip.shoppingTooltips = {} -- GameTooltip contains this table. Need this to prevent error
	itemTooltip.shoppingTooltips[1] = CreateFrame("GameTooltip", cName .. "_ShoppingTooltip1", itemTooltip,
	                                              "ShoppingTooltipTemplate")
	itemTooltip.shoppingTooltips[2] = CreateFrame("GameTooltip", cName .. "_ShoppingTooltip2", itemTooltip,
	                                              "ShoppingTooltipTemplate")
	return itemTooltip
end

--- Update all frames registered with RCLootCouncil:CreateFrame().
-- Updates all the frame's colors as set in the db.
function RCLootCouncil:UpdateFrames() for _, frame in pairs(self.UI:GetCreatedFramesOfType("RCFrame")) do frame:Update() end end

--- Applies a skin to all frames
-- Skins must be added to the db.skins table first.
-- @param key Index in db.skins.
function RCLootCouncil:ActivateSkin(key)
	self.Log:d("ActivateSkin", key)
	if not db.skins[key] then return end
	for _, v in pairs(db.UI) do
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
	local b = self.UI:New("RCButton", parent)
	b:SetText(text)
	return b
end

--- Displays a tooltip anchored to the mouse with white text.
---@vararg string
function RCLootCouncil:CreateTooltip(...)
	self:CreatedColoredTooltip(1, 1,1, ...)
end

--- Displays a tooltip anchored to the mouse with colored text.
---@param r number Red
---@param g number Green
---@param b number Blue
---@vararg string
function RCLootCouncil:CreatedColoredTooltip(r,g,b, ...)
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	for i = 1, select("#", ...) do GameTooltip:AddLine(select(i, ...), r, g, b) end
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
			if self.tooltip.showing and event == "MODIFIER_STATE_CHANGED" and (arg == "LSHIFT" or arg == "RSHIFT")
							and self.tooltip.link then
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
	if self.tooltip then self.tooltip.showing = false end
	GameTooltip:Hide()
end

function RCLootCouncil:ResetUI()
	db = self:Getdb()
	for name, data in pairs(db.UI) do -- We can't easily reset due to the wildcard in defaults
		for k in pairs(data) do
			if self.defaults.profile.UI[name] and self.defaults.profile.UI[name][k] then
				db.UI[name][k] = self.defaults.profile.UI[name][k]
			else
				db.UI[name][k] = self.defaults.profile.UI["**"][k]
			end
		end
	end
	for _, frame in ipairs(self.UI.minimizeableFrames) do frame:RestorePosition() end
	db.chatFrameName = self.defaults.profile.chatFrameName
end

local itemStatsRet = {}
-- Get item bonus text (socket, leech, etc)
-- Item needs to be cached.
function RCLootCouncil:GetItemBonusText(link, delimiter)
	if not delimiter then delimiter = "/" end
	itemStatsRet = self.C_Item.GetItemStats(link)
	local text = ""
	for k, _ in pairs(itemStatsRet or {}) do
		if k:find("SOCKET") then
			text = L["Socket"]
			break
		end
	end

	if itemStatsRet["ITEM_MOD_CR_AVOIDANCE_SHORT"] then
		if text ~= "" then text = text .. delimiter end
		text = text .. _G.ITEM_MOD_CR_AVOIDANCE_SHORT
	end
	if itemStatsRet["ITEM_MOD_CR_LIFESTEAL_SHORT"] then
		if text ~= "" then text = text .. delimiter end
		text = text .. _G.ITEM_MOD_CR_LIFESTEAL_SHORT
	end
	if itemStatsRet["ITEM_MOD_CR_SPEED_SHORT"] then
		if text ~= "" then text = text .. delimiter end
		text = text .. _G.ITEM_MOD_CR_SPEED_SHORT
	end
	if itemStatsRet["ITEM_MOD_CR_STURDINESS_SHORT"] then -- Indestructible
		if text ~= "" then text = text .. delimiter end
		text = text .. _G.ITEM_MOD_CR_STURDINESS_SHORT
	end
	if itemStatsRet["ITEM_MOD_CORRUPTION"] then
		if text ~= "" then text = text .. delimiter end
		text = "|c" .. _G.CORRUPTION_COLOR:GenerateHexColor() .. text .. _G.ITEM_MOD_CORRUPTION .. "|r"
	end

	return text
end

-- @return a text of the link explaining its type. For example, "Fel Artifact Relic", "Chest, Mail"
function RCLootCouncil:GetItemTypeText(link, subType, equipLoc, typeID, subTypeID, classesFlag, tokenSlot, relicType)
	local id = ItemUtils:GetItemIDFromLink(link)

	if tokenSlot then -- It's a token
		local tokenText
		if bit.band(classesFlag, 0x112) == 0x112 then
			tokenText = L["Conqueror Token"]
		elseif bit.band(classesFlag, 0x45) == 0x45 then
			tokenText = L["Protector Token"]
		elseif bit.band(classesFlag, 0x488) == 0x488 then
			tokenText = L["Vanquisher Token"]
		else
			tokenText = self:GetClassNamesFromFlag(classesFlag)
		end

		if equipLoc == "" then equipLoc = self:GetTokenEquipLoc(tokenSlot) end

		if equipLoc ~= "" and getglobal(equipLoc) then
			return getglobal(equipLoc) .. ", " .. tokenText
		else
			return tokenText
		end
	elseif equipLoc ~= "" and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" and getglobal(equipLoc) then
		if classesFlag and classesFlag ~= 0xffffffff then
			return getglobal(equipLoc) .. ", " .. self:GetClassNamesFromFlag(classesFlag)
		elseif equipLoc == "INVTYPE_TRINKET" then
			local lootSpec = _G.RCTrinketSpecs[id]
			local category = lootSpec and _G.RCTrinketCategories[lootSpec]
			if category then
				return getglobal(equipLoc) .. " (" .. category .. ")"
			else
				return getglobal(equipLoc)
			end
		elseif equipLoc ~= "INVTYPE_CLOAK"
			and
			(
			(not (typeID == Enum.ItemClass.Miscellaneous and subTypeID == Enum.ItemMiscellaneousSubclass.Junk)) -- subType: "Junk"


				and (not (typeID == Enum.ItemClass.Armor and subTypeID == Enum.ItemArmorSubclass.Generic))
				-- subType: "Miscellaneous"


				and (not (typeID == Enum.ItemClass.Weapon and subTypeID == Enum.ItemWeaponSubclass.Generic))) then -- subType: "Miscellaneous"


			return getglobal(equipLoc) .. ", " .. (subType or "") -- getGlobal to translate from global constant to localized name
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
function RCLootCouncil.Ambiguate(name) return db.ambiguate and Ambiguate(name, "none") or Ambiguate(name, "short") end

--- Fetches a response of a given type, based on the group leader's settings if possible
--- @param type string The type of response. Defaults to "default".
--- @param name string|integer The name or index of the response.
--- @see RCLootCouncil.db.responses
--- @return table #A table from db.responses containing the response info
function RCLootCouncil:GetResponse(type, name)
	-- REVIEW With proper inheritance, most of this should be redundant
	-- Check if the type should be translated to something else
	type = type or "default"
	if self.mldb.responses and not self.mldb.responses[type] and self.BTN_SLOTS[type]
					and self.mldb.responses[self.BTN_SLOTS[type]] then type = self.BTN_SLOTS[type] end

	if type == "default" or (self.mldb and self.mldb.responses and not self.mldb.responses[type]) then -- We have a value if mldb is blank
		if db.responses.default[name] or (self.mldb and self.mldb.responses and self.mldb.responses.default[name]) then
			return (self.mldb.responses and self.mldb.responses.default and self.mldb.responses.default[name])
							       or db.responses.default[name]
		else
			self.Log:d("No db.responses.default entry for response:", name)
			return self.defaults.profile.responses.default.DEFAULT -- Use default
		end
	else
		if next(self.mldb) then
			if self.mldb.responses[type] then
				if self.mldb.responses[type][name] then
					return self.mldb.responses[type][name]
				else
					self.Log:d("No mldb.responses[" .. tostring(type) .. "] entry for response:" .. tostring(name))
				end
			else
				-- This type is not enabled, so use default:
				if db.responses.default[name] or self.mldb.responses.default[name] then
					return self.mldb.responses.default and self.mldb.responses.default[name] or db.responses.default[name]
				else
					self.Log:d("Unknown response entry", type, name)
					return db.responses.default.DEFAULT -- Use default
				end
			end
			-- See if we have local settings
		elseif db.responses[type] and db.responses[type][name] then
			return db.responses[type][name]
		else
			self.Log:d("No db or mldb for GetReponse", type, name)
		end
	end
	return {} -- Fallback
end

--- Returns the number of buttons of a specific type
function RCLootCouncil:GetNumButtons(type)
	type = type and type or "default"
	if not next(self.mldb) then
		-- No mldb, so just return the default
		return db.buttons[type] and db.buttons[type].numButtons or 0
	end
	if not self.mldb.buttons[type] and self.BTN_SLOTS[type] and self.mldb.buttons[self.BTN_SLOTS[type]] then
		type = self.BTN_SLOTS[type]
	end
	if type == "default" or not self.mldb.buttons[type] then -- Has special definition
		return self.mldb.buttons.default and self.mldb.buttons.default.numButtons or db.buttons.default.numButtons or 0
	else -- Here we can rely on the responses as we have no defaults
		if self.mldb.buttons[type] then
			return #self.mldb.buttons[type]
		else
			error("No mldb.buttons entry for: " .. tostring(type))
		end
	end
end

--- Returns all buttons of a specific type, defaults to "default"
function RCLootCouncil:GetButtons(type)
	type = type and type or "default"
	self.Log:d("GetButtons", type)
	-- Check if the type should be translated to something else
	if self.mldb and not self.mldb.buttons[type] and self.BTN_SLOTS[type] and self.mldb.buttons[self.BTN_SLOTS[type]] then
		type = self.BTN_SLOTS[type]
		self.Log:d("Setting type to", type)
	end
	return self.mldb and self.mldb.buttons[type] or self.mldb.buttons.default
end

--- Shorthand for :GetResponse(type, name).color
-- @return Returned in an unpacked format for use in SetTextColor functions.
function RCLootCouncil:GetResponseColor(type, name) return unpack(self:GetResponse(type, name).color) end

--- Returns a colored response text.
--- @param type string The type of response. Defaults to "default".
--- @param name string|integer The name or index of the response.
--- @see RCLootCouncil.db.responses
--- @return string #The color wrapped response text.
function RCLootCouncil:GetColoredResponseText(type, name)
	local response = self:GetResponse(type, name)
	if not response then return "" end
	return CreateColor(unpack(response.color)):WrapTextInColorCode(response.text) or response.text
end

-- #end UI Functions -----------------------------------------------------
-- debug func
--@debug@
_G.printtable = function(data, level)
	if not data then return end
	level = level or 0
	local ident = strrep('     ', level)
	if level > 6 then return end
	if type(data) ~= 'table' then print(tostring(data)) end
	for index, value in pairs(data) do
		repeat
			if type(value) ~= 'table' then
				print(ident .. '[' .. tostring(index) .. '] = ' .. tostring(value) .. ' (' .. type(value) .. ')');
				break
			end
			print(ident .. '[' .. tostring(index) .. '] = {')
			_G.printtable(value, level + 1)
			print(ident .. '}');
		until true
	end
end
--@end-debug@

function RCLootCouncil:ExportCurrentSession()
	if not lootTable or #lootTable == 0 then return self:Print(L["No session running"]) end
	local exportData = {"session,item,itemID,ilvl"}
	for session, data in ipairs(lootTable) do
		exportData[session + 1] = table.concat({session, data.link:gsub("|", "||"), data.itemID, data.ilvl}, ",")
	end
	local csv = table.concat(exportData, "\n")
	local exportFrame = self.UI:New("RCExportFrame")
	exportFrame.edit:SetText(csv)
	exportFrame:Show()
end

--- These comms should live all the time
function RCLootCouncil:SubscribeToPermanentComms()
	Comms:BulkSubscribe(self.PREFIXES.MAIN, {
		--
		council = function(data, sender) self:OnCouncilReceived(sender, unpack(data)) end,
		--
		playerInfoRequest = function(_, sender)
			self:SendPlayerInfo(sender)
		end,

		pI = function(data, sender) self:OnPlayerInfoReceived(sender, unpack(data)) end,

		n_t = function(data, sender, command) self:OnTradeableStatusReceived(sender, "not_tradeable", unpack(data)) end,
		r_t = function(data, sender, command) self:OnTradeableStatusReceived(sender, "rejected_trade", unpack(data)) end,

		session_end = function(_, sender) self:OnSessionEndReceived(sender) end,

		lootTable = function(data, sender)
			if not self.Utils:UnitIsUnit(sender, self.masterLooter) then
				return self.Log:d(tostring(sender) .. " is not ML, but sent lootTable!")
			end
			self:OnLootTableReceived(unpack(data))
		end,

		lt_add = function(data, sender)
			if not self.Utils:UnitIsUnit(sender, self.masterLooter) then
				return self.Log:E(tostring(sender), "sent 'lt_add' but was not ML!")
			end
			self:OnLootTableAdditionsReceived(unpack(data))
		end,

		mldb = function(data, sender)
			if self.isMasterLooter then
				return
			elseif self.Utils:UnitIsUnit(sender, self.masterLooter) then
				self:OnMLDBReceived(unpack(data))
			else
				self.Log:w("Non-ML:", sender, "sent Mldb!")
			end
		end,

		reroll = function(data, sender)
			if self.Utils:UnitIsUnit(sender, self.masterLooter) and self.enabled then
				self:OnReRollReceived(sender, unpack(data))
			end
		end,

		---@param data [string[], LootTable] 1: List of transmittable player GUIDs of candidates that should reroll. 2: LootTable.
		re_roll = function (data, sender)
			if self.Utils:UnitIsUnit(sender, self.masterLooter) and self.enabled then
				self:OnNewReRollReceived(sender, unpack(data))
			end
		end,

		lootAck = function() if self.enabled then self:OnLootAckReceived() end end,

		Rgear = function(_, sender) self:OnGearRequestReceived(sender) end,

		getCov = function(_, sender) self:OnCovenantRequest(sender) end,

		StartHandleLoot = function() self:OnStartHandleLoot() end,

		StopHandleLoot = function() self.handleLoot = false end,
		history = function (data, sender)
			if not self.Utils:UnitIsUnit(sender, self.masterLooter) then
				return self.Log:E(tostring(sender), "sent 'history' but was not ML!")
			end
			self:OnHistoryReceived(unpack(data))
		end,
	})
end

-------------------------------------------------------------
-- Comm Handlers
-------------------------------------------------------------
function RCLootCouncil:OnCouncilReceived(sender, council)
	if not self:UnitIsUnit(sender, self.masterLooter) then return self.Log:W("Non ML sent council") end
	self.hasReceivedCouncil = true
	Council:RestoreFromTransmit(council)
	self.isCouncil = Council:Contains(self.player)
	self.Log:D("isCouncil", self.isCouncil)
	-- REVIEW Send a message? Or something else to inform that council is updated.
	if self.isCouncil or self.mldb.observe then
		self:CallModule("votingframe")
	else
		self:GetActiveModule("votingframe"):Disable()
	end
end

function RCLootCouncil:OnPlayerInfoReceived(sender, role, rank, enchanter, lvl, ilvl, specID)
	Player:Get(sender):UpdateFields{
		role = role,
		rank = rank,
		enchanter = enchanter,
		enchantingLvl = lvl,
		ilvl = ilvl,
		specID = specID,
	}
end

function RCLootCouncil:OnTradeableStatusReceived(sender, reason, link)
	tinsert(self.nonTradeables, {link = link, reason = reason, owner = sender})
end

function RCLootCouncil:OnSessionEndReceived(sender)
	if not self.enabled then return end
	if self:UnitIsUnit(sender, self.masterLooter) then
		self:Print(format(L["'player' has ended the session"], self:GetClassIconAndColoredName(self.masterLooter)))
		self:GetActiveModule("lootframe"):Disable()
		lootTable = {}
		if self.isCouncil or self.mldb.observe then -- Don't call the voting frame if it wasn't used
			self:GetActiveModule("votingframe"):EndSession(db.autoClose)
		end
	else
		self.Log:W("Non ML:", sender, "sent end session command!")
	end
end

local function CheckCachedLootTable(lootTable)
	local cached = true
	for _, v in pairs(lootTable) do if not C_Item.GetItemInfo("item:" .. v.string) then cached = false end end
	return cached
end

function RCLootCouncil:OnLootTableReceived(lt)
	-- Send "DISABLED" response when not enabled
	if not self.enabled then
		for i = 1, #lt do
			-- target, session, response, isTier, isRelic, note, roll, link, ilvl, equipLoc, relicType, sendAvgIlvl, sendSpecID
			self:SendResponse("group", i, "DISABLED")
		end
		return self.Log("Sent 'DISABLED' response to", self.masterLooter)
	end

	-- Cache items
	if not CheckCachedLootTable(lt) then
		-- Note: Dont print debug log here. It is spamming.
		return self:ScheduleTimer("OnLootTableReceived", 0, lt)
	end

	lootTable = lt
	self:PrepareLootTable(lootTable)

	-- v2.0.1: It seems people somehow receives mldb without numButtons, so check for it aswell.
	if not self.mldb then -- Really shouldn't happen, but I'm tired of people somehow not receiving it...
		self.Log:w("Received loot table without having mldb :(", self.masterLooter)
		self:Send(self.masterLooter, "MLdb_request")
		return self:ScheduleTimer("OnLootTableReceived", 1, lt)
	end

	-- Check if council is received
	if not Council:Contains(self.masterLooter) then
		self.Log:d("Received loot table without ML in the council", self.masterLooter)
		self:Send(self.masterLooter, "council_request")
	end

	-- Hand the lootTable to the votingFrame
	if self.isCouncil or self.mldb.observe then self:GetActiveModule("votingframe"):ReceiveLootTable(lootTable) end

	-- Out of instance support
	-- assume 8 people means we're actually raiding
	if self.mldb.outOfRaid and GetNumGroupMembers() >= 8 and not IsInInstance() then
		self.Log("NotInRaid respond to lootTable")
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

	-- Hide frames if in combat
	if self.inCombat then
		self.UI:DelayedMinimize()
	end
end

function RCLootCouncil:OnLootTableAdditionsReceived(lt)
	-- Ensure items are cached
	if not CheckCachedLootTable(lt) then return self:ScheduleTimer("OnLootTableAdditionsReceived", 0, lt) end
	-- Setup the additions
	self:PrepareLootTable(lt)
	self:DoAutoPasses(lt)
	self:SendLootAck(lt)
	-- Inject into lootTable
	local oldLenght = #lootTable
	for k, v in pairs(lt) do lootTable[k] = v end

	for i = oldLenght + 1, #lootTable do self:GetActiveModule("lootframe"):AddSingleItem(lootTable[i]) end
	self:SendMessage("RCLootTableAdditionsReceived", lt)

	-- Hide frames if in combat
	if self.inCombat then
		self.UI:DelayedMinimize()
	end
end

function RCLootCouncil:OnMLDBReceived(input)
	self.Log("OnMLDBReceived")
	-- mldb inheritance from db
	self.mldb = MLDB:RestoreFromTransmit(input)
	for type, responses in pairs(self.mldb.responses) do
		for _ in pairs(responses) do
			if not self.defaults.profile.responses[type] then
				setmetatable(self.mldb.responses[type], {__index = self.defaults.profile.responses.default})
			end
		end
	end
	if not self.mldb.responses.default then self.mldb.responses.default = {} end
	setmetatable(self.mldb.responses.default, {__index = self.defaults.profile.responses.default})

	if not self.mldb.buttons.default then self.mldb.buttons.default = {} end
	setmetatable(self.mldb.buttons.default, {__index = self.defaults.profile.buttons.default})

	if self.mldb.observe then
		if not self:GetActiveModule("votingframe"):IsEnabled() then
			self:CallModule("votingframe")
		end
	end
end

function RCLootCouncil:DoReroll(lt)
	self:PrepareLootTable(lt)
	self:DoAutoPasses(lt)
	-- REVIEW Are these needed?
	self:SendLootAck(lt)

	self:CallModule("lootframe")
	self:GetActiveModule("lootframe"):ReRoll(lt)

	-- Hide frames if in combat
	if self.inCombat then
		self.UI:DelayedMinimize()
	end
end

function RCLootCouncil:OnReRollReceived(sender, lt)
	self:Print(format(L["'player' has asked you to reroll"], self:GetClassIconAndColoredName(sender)))
	self:DoReroll(lt)
end

---@param candidates string[] List of transmittable player GUIDs of candidates that should reroll.
---@param lt LootTable
function RCLootCouncil:OnNewReRollReceived(sender, candidates, lt)
	if not tContains(candidates, self.player:GetForTransmit()) then
		self.Log:D("We are not in the reRoll candidate list")
		return
	end
	self:Print(format(L["'player' has asked you to reroll"], self:GetClassIconAndColoredName(sender)))
	self:DoReroll(lt)
end

function RCLootCouncil:OnLootAckReceived()
	-- If we receive a lootAck, but we don't have lootTable, then something's wrong!
	-- REVIEW Is this still needed?
	if not lootTable or #lootTable == 0 then
		self.Log:d("!!!! We got an lootAck without having lootTable!!!!")
		if not self.masterLooter then -- Extra sanity check
			return self.Log:d("We don't have a ML?!")
		end
		if not self.recentReconnectRequest then -- we don't want to do it too often!
			self:Send(self.masterLooter, "reconnect")
			self.recentReconnectRequest = true
			self:ScheduleTimer("ResetReconnectRequest", 5) -- 5 sec break between each try
			self.Log:d("Sent Reconnect Request")
		end
	end
end

function RCLootCouncil:OnGearRequestReceived(sender)
	local data = TT:Acquire()
	self:UpdatePlayersData()
	for i, link in pairs(playersData.gears) do data[i] = ItemUtils:GetTransmittableItemString(link) end
	Comms:Send{prefix = self.PREFIXES.MAIN, target = Player:Get(sender), command = "gear", data = {data}, prio = "BULK"}
	TT:Release(data)
end

function RCLootCouncil:OnCovenantRequest(sender)
	Comms:Send{
		prefix = self.PREFIXES.MAIN,
		target = Player:Get(sender),
		command = "cov",
		data = C_Covenants.GetActiveCovenantID(),
	}
end

function RCLootCouncil:OnStartHandleLoot()
	self.handleLoot = true

	if not self.autoGroupLootWarningShown and db.showAutoGroupLootWarning and self.Require "Utils.GroupLoot":ShouldPassOnLoot() then
		self.autoGroupLootWarningShown = true
		self:Print(L.autoGroupLoot_warning)
	end
end

---@param historyEntry HistoryEntry
function RCLootCouncil:OnHistoryReceived(winner, historyEntry)
	if not next(self.db.profile.moreInfoRaids) then return end -- Nothing selected, no need to do anything
	local id = historyEntry.mapID.."-"..historyEntry.difficultyID
	if self.db.profile.registeredInstances[id] then return end -- Already registered, no need to do anything
	-- We're filtering for instances and this instance is not registered, so register it and enable the filter:
	self.db.profile.registeredInstances[id] = historyEntry.instance
	self.db.profile.moreInfoRaids[id] = true
	self.Log:D("Registered instance", historyEntry.instance, "with ID", id)
end

function RCLootCouncil:GetEJLatestInstanceID()
	local numTiers = EJ_GetNumTiers()
	if numTiers == 0 then return end
	EJ_SelectTier(numTiers - (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and 1 or 0)) -- Last tier is Mythic+
	local index = 1
	local instanceId = EJ_GetInstanceByIndex(index, true)

	while index do
		local id = EJ_GetInstanceByIndex(index + 1, true)
		if id then
			instanceId = id
			index = index + 1
		else
			index = nil
		end
	end

	if not instanceId then instanceId = 1190 end -- default to Castle Nathria if no ID is found
	return instanceId
end

function RCLootCouncil:LogItemGUID(item)
	self.Log:D("Item GUID: " .. tostring(self.ItemStorage:GetItemGUID(item) or nil))
end

--- Unlocks an item. See [`C_Item.UnlockItem`](lua://C_Item.UnlockItem).
---@param item ItemLink|ItemString Item to unlock
function RCLootCouncil:UnlockItem(item)
	local guid = self.ItemStorage:GetItemGUID(item)
	if not guid then return self:Print(format("Couldn't find %s in your inventory.", item)) end
	local Item = Item:CreateFromItemGUID(guid)
	Item:UnlockItem()
	if Item:IsItemLocked() then
		self:Print("Couldn't unlock item")
	else
		self:Print("Item unlocked")
	end
end

---Locks an item - mainly for testing
---@param item ItemLink|ItemString
function RCLootCouncil:LockItem(item)
	local guid = self.ItemStorage:GetItemGUID(item)
	if not guid then return self:Print(format("Couldn't find %s in your inventory.", item)) end
	local Item = Item:CreateFromItemGUID(guid)
	Item:LockItem()
	if Item:IsItemLocked() then
		self:Print("Item locked")
	else
		self:Print("Couldn't lock item")
	end
end

---Fetches the differences between the current profile and the default profile
---with non-exported fields removed.
function RCLootCouncil:GetDBForExport()
	local db = self.Utils:GetTableDifference(self.db.defaults.profile, self.db.profile)
	db.UI = nil -- Remove UI as it's not helpful for other players
	db.itemStorage = nil
	db.baggedItems = nil
	db.modules = nil -- Personal stuff, don't export
	db.moreInfoClampToScreen = nil
	return db
end
