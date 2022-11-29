--- core.lua Contains core elements of the addon
-- @author Potdisc
--[[ TODOs/Notes
	Things marked with "todo"
		- IDEA Change popups so they only hide on award/probably add the error message to it.
		- Trade status in TradeUI
-------------------------------- ]] --[[CHANGELOG
	-- SEE CHANGELOG.TXT]] --[[AceEvent-3.0 Messages:
	core:
		RCCouncilChanged		-	fires when the council changes.
		RCConfigTableChanged	-	fires when the user changes a settings. args: [val]; a few settings supplies their name.
		RCUpdateDB				-	fires when the user receives sync data from another player.
		RCLootStatusReceived - 	fires when new loot status is received, i.e. when it's safe to call :GetLootStatusData.
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
]] --[[ Notable Comm messages: (See Classes/Services/Comms.lua for subscribing to comms)
	Comms:
	P: Permanent, T: Temporary
		MAIN:
			StartHandleLoot 	P - Sent whenever RCLootCouncil starts handling loot.
			StopHandleLoot		P - Sent whenever RCLootCouncil stops handling loot.
			council				P - Council received from ML
			session_end 		P - ML has ended the session.
			playerInfoRequest 	P - Request for playerInfo
			pI 					P - Player Info
			l	 				P - Received 'looted' from a candidated.
			fakeLoot			P - Candidate left an item on a boss.
			fullbags			P - Candidate couldn't loot boss because of full bags.
			n_t					P - Candidate received "non-tradeable" loot.
			r_t					P - Candidate "rejected_trade" of loot.
			lootTable			P - LootTable sent from ML.
			lt_add 				P - Partial lootTable (additions) sent from ML.
			mldb 				P - MLDB sent from ML.
			reroll 				P - (Partial) lootTable with items we should reroll on.
			lootAck 			P - LootAck received from another player. Used for checking if have received the required data.
			Rgear				P - Anyone requests our currently equipped gear.
			bonus_roll 			P - Sent whenever we do a bonus roll.
			getCov 				P - Anyone request or covenant ID.
]] -- GLOBALS: GetLootMethod, GetAddOnMetadata, UnitClass
local addonname, addontable = ...
--- @class RCLootCouncil : AceAddon-3.0, AceConsole-3.0, AceEvent-3.0, AceHook-3.0, AceTimer-3.0, AceBucket-3.0
_G.RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon(addontable, addonname, "AceConsole-3.0", "AceEvent-3.0",
                                                    "AceHook-3.0", "AceTimer-3.0", "AceBucket-3.0");
local LibDialog = LibStub("LibDialog-1.0")
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

-- Init shorthands
local db, debugLog; -- = self.db.profile, self.db.global.log
-- init modules
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
local player_relogged = true -- Determines if we potentially need data from the ML due to /rl
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
	self.version = GetAddOnMetadata("RCLootCouncil", "Version")
	self.nnp = false
	self.debug = false
	self.tVersion = nil -- String or nil. Indicates test version, which alters stuff like version check. Is appended to 'version', i.e. "version-tVersion" (max 10 letters for stupid security)

	self.playerClass = select(2, UnitClass("player")) -- TODO: Remove - contained in self.player
	self.guildRank = L["Unguilded"]
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

	self.lootStatus = {}
	self.EJLastestInstanceID = RCLootCouncil:GetEJLatestInstanceID()

	---@type table<string,boolean>
	self.candidatesInGroup = {}
	self.mldb = {} -- db recived from ML
	self.chatCmdHelp = {
		{cmd = "config", desc = L["chat_commands_config"]},
		{cmd = "council", desc = L["chat_commands_council"]},
		{cmd = "history", desc = L["chat_commands_history"]},
		{cmd = "version", desc = L["chat_commands_version"]},
		{cmd = "open", desc = L["chat_commands_open"]},
		{cmd = "reset", desc = L["chat_commands_reset"]},
		{cmd = "test (#)", desc = L["chat_commands_test"]},
		{cmd = "whisper", desc = L["chat_commands_whisper"]},
		{cmd = "add [item]", desc = L["chat_commands_add"]},
		{cmd = "award", desc = L["chat_commands_award"]},
		{cmd = "sync", desc = L["chat_commands_sync"]},
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
	self.db.RegisterCallback(self, "OnProfileChanged", ReloadUI)
	self.db.RegisterCallback(self, "OnProfileCopied", ReloadUI)
	self.db.RegisterCallback(self, "OnProfileReset", ReloadUI)

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
        self.guildRank = select(2, GetGuildInfo("player"))
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

	self.db.global.logMaxEntries = self.defaults.global.logMaxEntries -- reset it now for zzz

	if self.tVersion then
		self.db.global.logMaxEntries = 4000 -- bump it for test version
	end
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
	self:RawHook(self, "Print", function(_, ...) self.hooks[self].Print(self, getglobal(db.chatFrameName), ...) end)
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
		Settings.OpenToCategory(self.optionsFrame.ml.name)
		LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil", "mlSettings", "councilTab")

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

	elseif input == "history" or input == string.lower(_G.HISTORY) or input == "h" or input == "his" then
		self:CallModule("history")
		-- @debug@
	elseif input == "nnp" then
		self.nnp = not self.nnp
		self:Print("nnp = " .. tostring(self.nnp))
	elseif input == "exporttrinketdata" then
		self:ExportTrinketData(tonumber(args[1]), 0, tonumber(args[2]), 1)
	elseif input == 'trinkettest' or input == 'ttest' then
		self.playerClass = string.upper(args[1])
		self:Test(1, false, true)
	elseif input == "exporttokendata" then
		self:ExportTokenData()
		-- @end-debug@
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

	elseif input == "reset" or input == string.lower(_G.RESET) then
		for k, v in pairs(db.UI) do -- We can't easily reset due to the wildcard in defaults
			if k == "lootframe" then -- Loot Frame is special
				v.y = -200
			else
				v.y = 0
			end
			v.point = "CENTER"
			v.x = 0
			v.scale = 0.8
		end
		for _, frame in ipairs(self.UI.minimizeableFrames) do frame:RestorePosition() end
		db.chatFrameName = self.defaults.profile.chatFrameName
		self:Print(L["Windows reset"])

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

	elseif input == "trade" then
		self.TradeUI:Show(true)

	elseif input == "safemode" then
		db.safemode = not db.safemode
		self:Print("SafeMode " .. (db.safemode and "On" or "Off"))
		-- @debug@
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
		-- @end-debug@
	else
		-- Check if the input matches anything
		for k, v in pairs(self.customChatCmd) do if k == input then return v.module[v.func](v.module, unpack(args)) end end
		self:ChatCommand("help")
	end
end

-- Update the recentTradableItem by link, if it is in bag and tradable.
function RCLootCouncil:UpdateAndSendRecentTradableItem(info, count)
	local Item = self.ItemStorage:New(info.link, "temp")
	self.ItemStorage:WatchForItemInBags(Item, function() -- onFound
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
		SendChatMessage(msg, "party")
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
		LoadAddOn("Blizzard_EncounterJournal")
		local cached = true
		local difficulties = {14, 15, 16} -- Normal, Heroic, Mythic

		EJ_SelectInstance(self.EJLastestInstanceID)
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
	-- Call ML module and let it handle the rest
	self:CallModule("masterlooter")
	self:GetActiveModule("masterlooter"):NewML(self.masterLooter)
	self:GetActiveModule("masterlooter"):Test(items)

	self:ScheduleTimer(function() self:Send("group", "l", 1234) end, 5)
end

function RCLootCouncil:EnterCombat()
	self.inCombat = true
	if not db.minimizeInCombat then return end
	for _, frame in ipairs(self.UI.minimizeableFrames) do
		if frame:IsVisible() and not frame:IsMinimized() then -- only minimize for combat if it isn't already minimized
			self.Log("Minimizing for combat")
			frame:Minimize(true)
		end
	end
end

function RCLootCouncil:LeaveCombat()
	self.inCombat = false
	if not db.minimizeInCombat then return end
	for _, frame in ipairs(self.UI.minimizeableFrames) do
		if frame:IsMinimized() and frame.autoMinimized then -- Reshow it
			self.Log("Reshowing frame")
			frame:Maximize()
		end
	end
end

function RCLootCouncil:UpdatePlayersGears(startSlot, endSlot)
	startSlot = startSlot or _G.INVSLOT_FIRST_EQUIPPED
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
	if gearsTable then -- lazy code
		GetInventoryItemLink = function(_, slotNum) return gearsTable[slotNum] end
	end

	local itemID = self.Utils:GetItemIDFromLink(link) -- Convert to itemID
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
		local _, _, _, _, _, itemClassID, itemSubClassID = GetItemInfoInstant(link)
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
--- @see Constants.lua#RESPONSE_CODE_GENERATORS.
--- @param item Item @Any valid input for GetItemInfoInstant
--- @return typecode
function RCLootCouncil:GetTypeCodeForItem(item)
	local itemID, _, _, itemEquipLoc, _, itemClassID, itemSubClassID = GetItemInfoInstant(item)
	if not itemID then return "default" end -- We can't handle uncached items!

	for _, func in ipairs(self.RESPONSE_CODE_GENERATORS) do
		local val = func(item, db, itemID, itemEquipLoc, itemClassID, itemSubClassID)
		if val then return val end
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
		gear1 = g1 and self.Utils:GetItemStringFromLink(g1) or nil,
		gear2 = g2 and self.Utils:GetItemStringFromLink(g2) or nil,
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
	if not g1 and g2 then error("You can't provide g2 without g1 in :GetIlvlDifference()") end
	local _, link, _, ilvl, _, _, _, _, equipLoc = GetItemInfo(item)
	if not g1 then g1, g2 = self:GetPlayersGear(link, equipLoc, playersData.gears) end

	-- Check if it's a ring or trinket
	if equipLoc == "INVTYPE_TRINKET" or equipLoc == "INVTYPE_FINGER" then
		local id = self.Utils:GetItemIDFromLink(link)
		if id == self.Utils:GetItemIDFromLink(g1) then -- compare with it
			local ilvl2 = select(4, GetItemInfo(g1))
			return ilvl - ilvl2

		elseif g2 and id == self.Utils:GetItemIDFromLink(g2) then
			local ilvl2 = select(4, GetItemInfo(g2))
			return ilvl - ilvl2
		end
		-- We haven't equipped this item, do it normally
	end
	local diff = 0
	local g1diff, g2diff = g1 and select(4, GetItemInfo(g1)), g2 and select(4, GetItemInfo(g2))
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
	local id = self.Utils:GetItemIDFromLink(link)
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
						GetItemInfo(self.Utils:UncleanItemString(v.string))
		local itemID = GetItemInfoInstant(link)
		v.link = link
		v.quality = rarity
		v.ilvl = self:GetTokenIlvl(v.link) or ilvl
		v.equipLoc = RCTokenTable[itemID] and self:GetTokenEquipLoc(RCTokenTable[itemID]) or equipLoc
		v.subType = subType -- Subtype should be in our locale
		v.texture = texture
		v.token = itemID and RCTokenTable[itemID]
		v.boe = bindType == _G.LE_ITEM_BIND_ON_EQUIP
		v.typeID = typeID
		v.subTypeID = subTypeID
		v.session = v.session or ses
		v.classes = self:GetItemClassesAllowedFlag(link)
	end
end

--- Sends a lootAck to the group containing session related data.
-- specID, average ilvl and corruption is sent once.
-- Currently equipped gear and "diff" is sent for each session.
-- Autopass response is sent if the session has been autopassed. No other response is sent.
-- @param skip Only sends lootAcks on sessions > skip or 0
function RCLootCouncil:SendLootAck(table, skip)
	local toSend = {gear1 = {}, gear2 = {}, diff = {}, response = {}}
	local hasData = false
	for k, v in pairs(table) do
		local session = v.session or k
		if session > (skip or 0) then
			hasData = true
			local g1, g2 = self:GetGear(v.link, v.equipLoc, v.relic)
			local diff = self:GetIlvlDifference(v.link, g1, g2)
			toSend.gear1[session] = g1 and self.Utils:GetItemStringClean(g1) or nil
			toSend.gear2[session] = g2 and self.Utils:GetItemStringClean(g2) or nil
			toSend.diff[session] = diff
			toSend.response[session] = v.autopass
		end
	end
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
						if not db.silentAutoPass then self:Print(format(L["Autopassed on 'item'"], v.link)) end
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
function RCLootCouncil:InitClassIDs()
	self.classDisplayNameToID = {} -- Key: localized class display name. value: class id(number)
	self.classTagNameToID = {} -- key: class name in capital english letters without space. value: class id(number)
	self.classIDToDisplayName = {} -- key: class id. Value: localized name
	self.classIDToFileName = {} -- key: class id. Value: File name
	for i = 1, self.Utils.GetNumClasses() do
		local info = C_CreatureInfo.GetClassInfo(i)
		if info then -- Just in case class doesn't exists #Classic
			self.classDisplayNameToID[info.className] = i
			self.classTagNameToID[info.classFile] = i
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

	local bindTradeTimeRemainingPattern = escapePatternSymbols(BIND_TRADE_TIME_REMAINING):gsub("%%%%s", "%(%.%+%)") -- PT locale contains "-", must escape that.
	local bounded = false

	for i = 1, tooltipForParsing:NumLines() or 0 do
		local line = getglobal(tooltipForParsing:GetName() .. 'TextLeft' .. i)
		if line and line.GetText then
			local text = line:GetText() or ""
			if text == ITEM_SOULBOUND or text == ITEM_ACCOUNTBOUND or text == ITEM_BNETACCOUNTBOUND then bounded = true end

			local timeText = text:match(bindTradeTimeRemainingPattern)
			if timeText then -- Within 2h trade window, parse the time text
				tooltipForParsing:Hide()

				for hour = 1, 0, -1 do -- time>=60s, format: "1 hour", "1 hour 59 min", "59 min", "1 min"
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
         for slot=1, C_Container.GetContainerNumSlots(container) or 0 do
			local time =self:GetContainerItemTradeTimeRemaining(container, slot)
			if  time > 0 and time < math.huge then
				tinsert(items, C_Container.GetContainerItemLink(container, slot))

			end
		 end
	end
	return items
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
			return
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

function RCLootCouncil:GetNumberOfDaysFromNow(oldDate) return self.Utils:GetNumberOfDaysFromNow(oldDate) end

function RCLootCouncil:ConvertDateToString(day, month, year) return self.Utils:ConvertDateToString(day, month, year) end

--- Checks the current loot status data and returns it in a formatted data
-- @return Overview, List. Overview string for display, and a list of names/items and their status (for use in tooltips)
function RCLootCouncil:GetLootStatusData()
	if not next(self.lootStatus) then return "None", {} end -- Might not have any data
	-- Find out which guid we're working with
	local id, max = 0, 0
	for k, v in pairs(self.lootStatus) do
		if v.num and v.num > max then
			id = k
			max = v.num
		end
	end
	local looted, unlooted, fake = 0, 0, 0
	local list = {} -- [i] = name, text="status"
	local i = 0
	for name in pairs(self.candidatesInGroup) do
		i = i + 1
		if not self.lootStatus[id].candidates[name] then -- Unlooted
			-- Check if they got loot, but just haven't responded yet
			if self.lastEncounterID and self.lootStatus[self.lastEncounterID] and self.lootStatus[self.lastEncounterID][name] then
				list[i] = {name = name, text = self.lootStatus[self.lastEncounterID][name] .. "|cffffff00" .. L["Not Found"]}
			else
				list[i] = {name = name, text = "|cffffff00" .. L["Unlooted"]}
			end
			unlooted = unlooted + 1
		elseif self.lootStatus[id].candidates[name].status == "looted" then -- They have looted
			list[i] = {name = name, text = "|cff00ff00 " .. L["Looted"]}
			looted = looted + 1
		elseif self.lootStatus[id].candidates[name].status == "fakeLoot" then -- fake loot
			list[i] = {name = name, text = self.lootStatus[id].candidates[name].item .. "|cffff0000 " .. L["Fake Loot"] .. "|r"}
			fake = fake + 1
		elseif self.lootStatus[id].candidates[name].status == "fullbags" then
			list[i] = {name = name, text = self.lootStatus[id].candidates[name].item .. "|cffff0000 " .. L["Full Bags"] .. "|r"}
			fake = fake + 1 -- This counts as a fake loot
		end
	end
	local status = format("|cffff0000%d|cffffffff/|cffffff00%d|cffffffff/|cff00ff00%d|cffffffff/%d|r", fake, unlooted,
	                      looted, i)
	table.sort(list, function(a, b) return a.name < b.name end)
	return status, list
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
		self:UpdatePlayersData()
		self:ScheduleTimer(CandidateAndNewMLCheck, 2)
		self:ScheduleTimer(function() -- This needs some time to be ready
			local instanceName, _, _, difficultyName = GetInstanceInfo()
			self.currentInstanceName = instanceName .. (difficultyName ~= "" and "-" .. difficultyName or "")
		end, 5)

		if player_relogged then
			-- Ask for data when we have done a /rl and have a ML, but delay it until we've updated ML
			self.Log("Player relog...")
			self:ScheduleTimer(function()
				if not self.isMasterLooter and self.masterLooter and self.masterLooter ~= "" then
					self:Send("group", "pI", self:GetPlayerInfo()) -- Also send out info, just in case
					self:Send(self.masterLooter, "reconnect")
				end
			end, 2.1)
			player_relogged = false
		end
	elseif event == "ENCOUNTER_START" then
		self.Log:d("Event:", event, ...)
		wipe(self.lootStatus)
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
		wipe(self.nonTradeables)

	elseif event == "LOOT_CLOSED" then
		if not IsInInstance() then return end -- Don't do anything out of instances
		self.Log:d("Event:", event, ...)
		local i = 0
		for k, info in pairs(self.lootSlotInfo) do
			if not info.isLooted and info.guid and info.link then
				if info.autoloot then -- We've looted the item without getting LOOT_SLOT_CLEARED, properly due to FastLoot addons
					return self:OnEvent("LOOT_SLOT_CLEARED", k), self:OnEvent("LOOT_CLOSED")
				end
				-- Check if we have room in bags
				if self.Utils:GetNumFreeBagSlots() == 0 then return self:Send("group", "fullbags", info.link, info.guid) end
				self:Send("group", "fakeLoot", info.link, info.guid)

				return
			end
			i = k -- Only update if we have items
		end
		-- Otherwise they've looted everything, so send ack
		if i ~= 0 then -- We're not guaranteed to have something stored
			self:Send("group", "l", self.lootSlotInfo[i].guid)
		end
		self.lootOpen = false
	elseif event == "LOOT_SLOT_CLEARED" then
		local slot = ...
		if self.lootSlotInfo[slot] and not self.lootSlotInfo[slot].isLooted then -- If not, this is the 2nd LOOT_CLEARED event for the same thing. -_-
			local link = self.lootSlotInfo[slot].link
			local quality = self.lootSlotInfo[slot].quality
			self.Log:d("OnLootSlotCleared()", slot, link, quality)
			if quality and quality >= GetLootThreshold() and IsInInstance() then -- Only send when in instance
				-- Note that we don't check if this is master looted or not. We only know this is looted by ourselves.
				self:ScheduleTimer("UpdateAndSendRecentTradableItem", 2, self.lootSlotInfo[slot]) -- Delay a bit, need some time to between item removed from loot slot and moved to the bag.
			end
			self.lootSlotInfo[slot].isLooted = true

			if self.isMasterLooter then self:GetActiveModule("masterlooter"):OnLootSlotCleared(slot, link) end
		end
	elseif event == "ENCOUNTER_LOOT_RECEIVED" then
		self.Log:d("Event:", event, ...)
		local encounterID, _, itemLink, _, playerName, _ = ...
		if not self.lootStatus[encounterID] then self.lootStatus[encounterID] = {} end
		local name = self:UnitName(playerName)
		playerName = name or playerName -- Expect us to get something back from UnitName
		self.lootStatus[encounterID][playerName] = itemLink

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

function RCLootCouncil:NewMLCheck()
	local old_ml = self.masterLooter
	local old_lm = self.lootMethod
	self.isMasterLooter, self.masterLooter = self:GetML()
	self.lootMethod = GetLootMethod()
	local instance_type = select(2, IsInInstance())
	if instance_type == "pvp" or instance_type == "arena" then return end -- Don't do anything here
	if self.masterLooter and type(self.masterLooter) == "string"
					and (self.masterLooter == "Unknown" or Ambiguate(self.masterLooter, "short"):lower() == _G.UNKNOWNOBJECT:lower()) then
		-- ML might be unknown for some reason
		self.Log:d("Unknown ML")
		return self:ScheduleTimer("NewMLCheck", 0.5)
	end

	if not self.isMasterLooter and self:GetActiveModule("masterlooter"):IsEnabled() then -- we're not ML, so make sure it's disabled
		self:StopHandleLoot()
	end
	if self.Utils.IsPartyLFG() then return end -- We can't use in lfg/lfd so don't bother
	if not self.masterLooter then return end -- Didn't find a leader or ML.
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
		self.Log("MasterLooter = ", self.masterLooter)
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

	if (self.lootMethod == "group" and db.usage.gl) or (self.lootMethod == "personalloot" and db.usage.pl) then -- auto start
		self:StartHandleLoot()
	elseif (self.lootMethod == "group" and db.usage.ask_gl) or (self.lootMethod == "personalloot" and db.usage.ask_pl) then
		return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")
	end
end

--- Enables the addon to automatically handle looting
function RCLootCouncil:StartHandleLoot()
	local lootMethod = GetLootMethod()
	if lootMethod ~= "group" and self.lootMethod ~= "personalloot" then -- Set it
		SetLootMethod("group")
	end
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

function RCLootCouncil:OnRaidEnter(arg)
	-- NOTE: We shouldn't need to call GetML() as it's most likely called on "LOOT_METHOD_CHANGED"
	if self.Utils.IsPartyLFG() or db.usage.never then return end -- We can't use in lfg/lfd so don't bother
	-- Check if we can use in party
	if not IsInRaid() and db.onlyUseInRaids then return end
	if UnitIsGroupLeader("player") then
		if db.usage.gl then
			self:StartHandleLoot()
			-- We must ask the player for usage
		elseif db.usage.ask_gl then
			return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")
		end
	end
end

--- Gets information about the current Master Looter, if any.
-- @return boolean, "ML_Name". (true if the player is ML), (nil if there's no ML).
function RCLootCouncil:GetML()
	self.Log:d("GetML()")
	if self.Utils.IsPartyLFG() then return false, nil end -- Never use in LFG
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
			local ver = GetAddOnMetadata(self:GetModule(name).baseName, "Version")
			modules[num] = self:GetModule(name).baseName .. " - " .. (ver or _G.UNKNOWN)
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
				id = entry.responseID
				if type(id) == "number" then -- ID may be string, e.g. "PASS"
					if entry.isAwardReason then id = id + 100 end -- Bump to distingush from normal awards
					if entry.tokenRoll then id = id + 200 end
					if entry.relicRoll then id = id + 300 end
				end
				-- We assume the mapID and difficultyID is available on any item if at all.
				if not numTokens[entry.instance] then
					numTokens[entry.instance] = {num = 0, mapID = entry.mapID, difficultyID = entry.difficultyID}
				end
				if entry.tierToken then -- If it's a tierToken, increase the count
					numTokens[entry.instance].num = numTokens[entry.instance].num + 1
				end
				count[id] = count[id] and count[id] + 1 or 1
				responseText[id] = responseText[id] and responseText[id] or entry.response
				if (not color[id] or unpack(color[id], 1, 3) == unpack {1, 1, 1}) and (entry.color and #entry.color ~= 0) then -- If it's not already added
					color[id] = #entry.color ~= 0 and #entry.color == 4 and entry.color or {1, 1, 1}
				end
				if lastestAwardFound < 5 and type(id) == "number" and not entry.isAwardReason
								and (id <= db.numMoreInfoButtons or (entry.tokenRoll and id - 200 <= db.numMoreInfoButtons)
												or (entry.relicRoll and id - 300 <= db.numMoreInfoButtons)) then
					tinsert(lootDBStatistics[name], {
						entry.lootWon, --[[entry.response .. ", "..]]
						format(L["'n days' ago"], self:ConvertDateToString(self:GetNumberOfDaysFromNow(entry.date))),
						color[id],
						i,
					})
					lastestAwardFound = lastestAwardFound + 1
				end
				-- Raids:
				raids[entry.date .. entry.instance] =
								raids[entry.date .. entry.instance] and raids[entry.date .. entry.instance] + 1 or 0
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

function RCLootCouncil:GetHistoryDB() return self.lootDB.factionrealm end

function RCLootCouncil:UpdateDB()
	db = self.db.profile
	self.db:RegisterDefaults(self.defaults)
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
	item1 = self.Utils:GetItemStringFromLink(item1)
	item2 = self.Utils:GetItemStringFromLink(item2)
	if not (item1 and item2) then return false end -- KeyStones will fail the GetItemStringFromLink
	--[[ REVIEW Doesn't take upgradeValues into account.
		Doing that would require a parsing of the bonusIDs to check the correct positionings.
	]]
	return self.Utils:NeutralizeItem(item1) == self.Utils:NeutralizeItem(item2)
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
		return _G.GetClassColoredTextForUnit("player", self.Ambiguate(name))
	else
		local englishClass = select(2, UnitClass(Ambiguate(name, "short")))
		return _G.GetClassColoredTextForUnit(englishClass, self.Ambiguate(name))
	end
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
function RCLootCouncil:UpdateFrames() for _, frame in pairs(self.UI.minimizeableFrames) do frame:Update() end end

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

--- Displays a tooltip anchored to the mouse.
-- @paramsig ...
-- @param ... string(s) Lines to be added.
function RCLootCouncil:CreateTooltip(...)
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	for i = 1, select("#", ...) do GameTooltip:AddLine(select(i, ...), 1, 1, 1) end
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
	local id = self.Utils:GetItemIDFromLink(link)

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
	elseif equipLoc ~= "" and getglobal(equipLoc) then
		if equipLoc == "INVTYPE_TRINKET" then
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
--- @param type string @The type of response. Defaults to "default".
--- @param name string @The name of the response.
--- @see RCLootCouncil.db.responses
--- @return table @A table from db.responses containing the response info
function RCLootCouncil:GetResponse(type, name)
	-- REVIEW With proper inheritance, most of this should be redundant
	-- Check if the type should be translated to something else
	type = type and type or "default"
	if self.mldb.responses and not self.mldb.responses[type] and self.BTN_SLOTS[type]
					and self.mldb.responses[self.BTN_SLOTS[type]] then type = self.BTN_SLOTS[type] end
	-- FIXME If we use non default button without mldb (i.e. changing responses in loot history), this will fail.
	if type == "default" or (self.mldb and not self.mldb.responses[type]) then -- We have a value if mldb is blank
		if db.responses.default[name] or self.mldb.responses.default[name] then
			return (self.mldb.responses and self.mldb.responses.default and self.mldb.responses.default[name])
							       or db.responses.default[name]
		else
			self.Log:d("No db.responses.default entry for response:", name)
			return self.defaults.profile.responses.default.DEFAULT -- Use default
		end
	else -- This must be supplied by the ml
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
		else
			self.Log:d("No mldb for GetReponse: " .. tostring(type) .. ", " .. tostring(name))
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

-- #end UI Functions -----------------------------------------------------
-- @debug@
-- debug func
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
-- @end-debug@

--- These comms should live all the time
function RCLootCouncil:SubscribeToPermanentComms()
	Comms:BulkSubscribe(self.PREFIXES.MAIN, {
		--
		council = function(data, sender) self:OnCouncilReceived(sender, unpack(data)) end,
		--
		playerInfoRequest = function(_, sender)
			Comms:Send{target = Player:Get(sender), command = "pI", data = {self:GetPlayerInfo()}}
		end,

		pI = function(data, sender) self:OnPlayerInfoReceived(sender, unpack(data)) end,

		l = function(data, sender) self:OnLootStatusReceived(sender, "looted", nil, unpack(data)) end,

		fakeLoot = function(data, sender) self:OnLootStatusReceived(sender, "fakeLoot", unpack(data)) end,
		fullbags = function(data, sender) self:OnLootStatusReceived(sender, "fullbags", unpack(data)) end,

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

		lootAck = function() if self.enabled then self:OnLootAckReceived() end end,

		Rgear = function(_, sender) self:OnGearRequestReceived(sender) end,

		getCov = function(_, sender) self:OnCovenantRequest(sender) end,

		StartHandleLoot = function() self.handleLoot = true end,

		StopHandleLoot = function() self.handleLoot = false end,
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

function RCLootCouncil:OnLootStatusReceived(sender, command, link, guid)
	if not guid then return self.Log:d(format("no guid in %s comm", command), guid, sender) end
	if self.lootGUIDToIgnore[guid] then return end
	if not self.lootStatus[guid] then self.lootStatus[guid] = {candidates = {}, num = 0} end
	self.lootStatus[guid].num = self.lootStatus[guid].num + 1
	self.lootStatus[guid].candidates[sender] = {status = command, item = link}
	self:SendMessage("RCLootStatusReceived")
end

function RCLootCouncil:OnTradeableStatusReceived(sender, reason, link)
	tinsert(self.nonTradeables, {link = link, reason = reason, owner = sender})
end

function RCLootCouncil:OnSessionEndReceived(sender)
	if not self.enabled then return end
	if self:UnitIsUnit(sender, self.masterLooter) then
		self:Print(format(L["'player' has ended the session"], self.Ambiguate(self.masterLooter:GetName())))
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
	for _, v in pairs(lootTable) do if not GetItemInfo("item:" .. v.string) then cached = false end end
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
		return self:ScheduleTimer("OnLootTableReceived", 0, lt)
	end

	-- Check if council is received
	if not Council:Contains(self.masterLooter) then
		self.Log:d("Received loot table without ML in the council", self.masterLooter)
		self:Send(self.masterLooter, "council_request")
		return self:ScheduleTimer("OnLootTableReceived", 0, lt)
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

	if self.mldb.autoGroupLoot and not self.autoGroupLootWarningShown and db.showAutoGroupLootWarning then
		self.autoGroupLootWarningShown = true
		self:Print(L.autoGroupLoot_warning)
	end
end

function RCLootCouncil:OnReRollReceived(sender, lt)
	self:Print(format(L["'player' has asked you to reroll"], self.Ambiguate(sender)))
	self:PrepareLootTable(lt)
	self:DoAutoPasses(lt)
	-- REVIEW Are these needed?
	self:SendLootAck(lt)

	self:CallModule("lootframe")
	self:GetActiveModule("lootframe"):ReRoll(lt)
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
		end
	end
end

function RCLootCouncil:OnGearRequestReceived(sender)
	local data = TT:Acquire()
	self:UpdatePlayersData()
	for i, link in pairs(playersData.gears) do data[i] = self.Utils:GetTransmittableItemString(link) end
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

function RCLootCouncil:GetEJLatestInstanceID()
	local serverExpansionLevel = GetServerExpansionLevel()
	EJ_SelectTier(serverExpansionLevel + 1)
	local index = 1
	local instanceId, name = EJ_GetInstanceByIndex(index, true)

	while index do
		local id = EJ_GetInstanceByIndex(index + 1, true)
		if id then
			instanceId = id
			index = index + 1
		end
		index = nil
	end

	if not instanceId then instanceId = 1190 end -- default to Castle Nathria if no ID is found
	return instanceId
end
