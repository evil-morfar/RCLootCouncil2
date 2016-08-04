--[[	RCLootCouncil by Potdisc
core.lua	Contains core elements of the addon

--------------------------------
TODOs/Notes
	Things marked with "todo"
		- IDEA add an observer/council string to show players their role?
		- If we truly want to be able to edit votingframe scrolltable with modules, it needs to have GetCol by name
		- Pressing shift while hovering an item should do the same as vanilla
		- The 4'th cell in @line81 in versionCheck should not be static
--------------------------------
CHANGELOG
	-- SEE CHANGELOG.TXT
]]

RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceHook-3.0", "AceTimer-3.0");
local LibDialog = LibStub("LibDialog-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local lwin = LibStub("LibWindow-1.1")

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
}
local userModules = {
	masterlooter = nil,
	lootframe = nil,
	history = nil,
	version = nil,
	sessionframe = nil,
	votingframe = nil,
}

local frames = {} -- Contains all frames created by RCLootCouncil:CreateFrame()
local unregisterGuildEvent = false
local player_relogged = true -- Determines if we potentially need data from the ML due to /rl

function RCLootCouncil:OnInitialize()
	--IDEA Consider if we want everything on self, or just whatever modules could need.
  	self.version = GetAddOnMetadata("RCLootCouncil", "Version")
	self.nnp = false
	self.debug = false
	self.tVersion = nil -- String or nil. Indicates test version, which alters stuff like version check. Is appended to 'version', i.e. "version-tVersion"

	self.playerClass = select(2, UnitClass("player"))
	self.guildRank = L["Unguilded"]
	self.target = nil
	self.isMasterLooter = false -- Are we the ML?
	self.masterLooter = ""  -- Name of the ML
	self.isCouncil = false -- Are we in the Council?
	self.enabled = true -- turn addon on/off
	self.inCombat = false -- Are we in combat?

	self.verCheckDisplayed = false -- Have we shown a "out-of-date"?

	self.council = {} -- council from ML
	self.mldb = {} -- db recived from ML
	self.responses = {
		NOTANNOUNCED	= { color = {1,0,1,1},				sort = 501,		text = L["Not announced"],},
		ANNOUNCED		= { color = {1,0,1,1},				sort = 502,		text = L["Loot announced, waiting for answer"], },
		WAIT				= { color = {1,1,0,1},				sort = 503,		text = L["Candidate is selecting response, please wait"], },
		TIMEOUT			= { color = {1,0,0,1},				sort = 504,		text = L["Candidate didn't respond on time"], },
		REMOVED			= { color = {0.8,0.5,0,1},			sort = 505,		text = L["Candidate removed"], },
		NOTHING			= { color = {0.5,0.5,0.5,1},		sort = 505,		text = L["Offline or RCLootCouncil not installed"], },
		PASS				= { color = {0.7, 0.7,0.7,1},		sort = 800,		text = L["Pass"],},
		AUTOPASS			= { color = {0.7,0.7,0.7,1},		sort = 801,		text = L["Autopass"], },
		DISABLED			= { color = {0.3, 0.35, 0.5},		sort = 802,		text = L["Candidate has disabled RCLootCouncil"], },
		--[[1]]			  { color = {0,1,0,1},				sort = 1,		text = L["Mainspec/Need"],},
		--[[2]]			  { color = {1,0.5,0,1},			sort = 2,		text = L["Offspec/Greed"],	},
		--[[3]]			  { color = {0,0.7,0.7,1},			sort = 3,		text = L["Minor Upgrade"],},
	}
	self.roleTable = {
		TANK =		L["Tank"],
		HEALER =		L["Healer"],
		DAMAGER =	L["DPS"],
		NONE =		L["None"],
	}

	self.testMode = false;

	-- Option table defaults
	self.defaults = {
		global = {
			logMaxEntries = 500,
			log = {}, -- debug log
			localizedSubTypes = {},
		},
		profile = {
			usage = { -- State of enabledness
				ml = false,				-- Enable when ML
				ask_ml = true,			-- Ask before enabling when ML
				leader = false,		-- Enable when leader
				ask_leader = true,	-- Ask before enabling when leader
				never = false,			-- Never enable
				state = "ask_ml", 	-- Current state
			},
			ambiguate = false, -- Append realm names to players
			autoStart = false, -- start a session with all eligible items
			autoLoot = true, -- Auto loot equippable items
			autolootEverything = true,
			autolootBoE = true,
			autoOpen = true, -- auto open the voting frame
			autoPassBoE = true,
			autoPass = true,
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
			autoAwardTo = L["None"],
			autoAwardReason = 1,
			observe = false, -- observe mode on/off
			silentAutoPass = false, -- Show autopass message
			--neverML = false, -- Never use the addon as ML
			minimizeInCombat = false,

			UI = { -- stores all ui information
				['**'] = { -- Defaults for Lib-Window
					y		= 0,
					x		= 0,
					point	= "CENTER",
					scale	= 0.8,
				},
				lootframe = { -- We want the Loot Frame to get a little lower
					y = -200,
				},
			},

			modules = { -- For storing module specific data
				['*'] = {},
			},

			announceAward = true,
			awardText = { -- Just max it at 2 channels
				{ channel = "group",	text = L["&p was awarded with &i for &r!"],},
				{ channel = "NONE",	text = "",},
			},
			announceItems = false,
			announceText = L["Items under consideration:"],
			announceChannel = "group",

			responses = self.responses,

			enableHistory = false,
			sendHistory = true,

			minRank = -1,
			council = {},

			maxButtons = 10,
			numButtons = 3,
			buttons = {
				{	text = L["Need"],					whisperKey = L["whisperKey_need"], },	-- 1
				{	text = L["Greed"],				whisperKey = L["whisperKey_greed"],},	-- 2
				{	text = L["Minor Upgrade"],		whisperKey = L["whisperKey_minor"],},	-- 3
			},
			maxAwardReasons = 10,
			numAwardReasons = 3,
			awardReasons = {
				{ color = {1, 1, 1, 1}, disenchant = true, log = true,	sort = 401,	text = L["Disenchant"], },
				{ color = {1, 1, 1, 1}, disenchant = false, log = true,	sort = 402,	text = L["Banking"], },
				{ color = {1, 1, 1, 1}, disenchant = false, log = false, sort = 403,	text = L["Free"],},
			},
			disenchant = true, -- Disenchant enabled, i.e. there's a true in awardReasons.disenchant

			-- List of items to ignore:
			ignore = {
				109693, -- Draenic Dust
				115502, -- Small Luminous Shard
				111245, -- Luminous Shard
				115504, -- Fractured Temporal Crystal
				113588, -- Temporal Crystal
				124442, -- Chaos Crystal (Legion)
				124441, -- Leylight Shard (Legion)
			},
		},
	} -- defaults end

	-- create the other buttons/responses
	for i = #self.defaults.profile.buttons+1, self.defaults.profile.maxButtons do
		tinsert(self.defaults.profile.buttons, {
			text = L["Button"].." "..i,
			whisperKey = ""..i,
		})
	end
	for i = self.defaults.profile.numButtons+1, self.defaults.profile.maxButtons do
		tinsert(self.defaults.profile.responses, {
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
	self:RegisterComm("RCLootCouncil")
	self.db = LibStub("AceDB-3.0"):New("RCLootCouncilDB", self.defaults, true)
	self.lootDB = LibStub("AceDB-3.0"):New("RCLootCouncilLootDB")
	--[[ Format:
	"playerName" = {
		[#] = {"lootWon", "date (d/m/y)", "time (h:m:s)", "instance", "boss", "votes", "itemReplaced1", "itemReplaced2", "response", "responseID", "color", "class", "isAwardReason"}
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
	self:RegisterEvent("GUILD_ROSTER_UPDATE","OnEvent")
	self:RegisterEvent("RAID_INSTANCE_WELCOME","OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "EnterCombat")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "LeaveCombat")
	--self:RegisterEvent("GROUP_ROSTER_UPDATE", "Debug", "event")

	if IsInGuild() then
		self.guildRank = select(2, GetGuildInfo("player"))
		self:SendCommand("guild", "verTest", self.version, self.tVersion) -- send out a version check
	end

	-- Any upgrade to v2.0.0 or from Alpha.12 needs a db reset and possibly lootDB import
	if (self.db.global.version and self.db.global.version < "2.0.0") or (self.db.global.tVersion and self.db.global.tVersion <= "Alpha.12") then -- Upgraded to v.2.0.0
		self:Debug("First time v2.0.0 upgrade!")
		local lootdb = {}
		if self.db.factionrealm.lootDB then
			self:Debug("Extracting old LootDB")
			for k,v in pairs(self.db.factionrealm.lootDB) do
				lootdb[k] = v
			end
			self:Debug("Done")
		end
		self:Debug("Resetting DB")
		self.db:ResetDB("Default")
		self:Debug("Done\nImporting LootDB")
		for k,v in pairs(lootdb) do
			self.lootDB.factionrealm[k] = v
		end
		self:Debug("Done")
		self:Print("Your settings have been reset due to upgrading to v2.0.0")
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
	GuildRoster()

	local filterFunc = function(_, event, msg, player, ...)
		return strfind(msg, "[[RCLootCouncil]]:")
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterFunc)

	self:LocalizeSubTypes()

	----------PopUp setups --------------
	-------------------------------------
	LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_USAGE", {
		text = L["confirm_usage_text"],
		buttons = {
			{	text = L["Yes"],
				on_click = function()
					local lootMethod = GetLootMethod()
					if lootMethod ~= "master" then
						self:Print(L["Changing LootMethod to Master Looting"])
						SetLootMethod("master", self.Ambiguate(self.playerName)) -- activate ML
					end
					if db.autoAward and GetLootThreshold() ~= 2 and GetLootThreshold() > db.autoAwardLowerThreshold  then
						self:Print(L["Changing loot threshold to enable Auto Awarding"])
						SetLootThreshold(db.autoAwardLowerThreshold >= 2 and db.autoAwardLowerThreshold or 2)
					end
					self:Print(L["Now handles looting"])
					self.isMasterLooter = true
					self.masterLooter = self.playerName
					if #db.council == 0 then -- if there's no council
						self:Print(L["You haven't set a council! You can edit your council by typing '/rc council'"])
					end
					self:CallModule("masterlooter")
					self:GetActiveModule("masterlooter"):NewML(self.masterLooter)
				end,
			},
			{	text = L["No"],
				on_click = function()
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

function RCLootCouncil:RefreshConfig(event, database, profile)
	self:Debug("RefreshConfig",event, database, profile)
	self.db.profile = database.profile
	db = database.profile
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

	elseif input == 'version' or input == L["version"] or input == "v" or input == "ver" then
		self:CallModule("version")

	elseif input == "history" or input == L["history"] or input == "h" or input == "his" then
		self:CallModule("history")
--@debug@
	elseif input == "nnp" then
		self.nnp = not self.nnp
		self:Print("nnp = "..tostring(self.nnp))
--@end-debug@
	elseif input == "whisper" or input == L["whisper"] then
		self:Print(L["whisper_help"])

	elseif (input == "add" or input == L["add"]) then
		if self.isMasterLooter then
			self:GetActiveModule("masterlooter"):AddUserItem(arg1)
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

	elseif input == "reset" or input == L["reset"] then
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
--@debug@
	elseif input == 't' then -- Tester cmd
		printtable(historyDB)
--@end-debug@
	else
		self:ChatCommand("help")
	end
end

--- Send a RCLootCouncil Comm Message using AceComm-3.0
-- See RCLootCouncil:OnCommReceived() on how to receive these messages.
-- @param target The receiver of the message. Can be "group", "guild" or "playerName".
-- @param command The command to send.
-- @param vararg Any number of arguments to send along. Will be packaged as a table.
function RCLootCouncil:SendCommand(target, command, ...)
	-- send all data as a table, and let receiver unpack it
	local toSend = self:Serialize(command, {...})

	if target == "group" then
		if GetNumGroupMembers() > 0 then -- SendAddonMessage auto converts it to party is needed
			self:SendCommMessage("RCLootCouncil", toSend, "RAID")
		--[[elseif num > 0 then -- Party
			self:SendCommMessage("RCLootCouncil", toSend, "PARTY")]]
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
					self:SendCommMessage("RCLootCouncil", toSend, "RAID")
				end

			else -- Should also be our own realm
				self:SendCommMessage("RCLootCouncil", toSend, "WHISPER", target)
			end
		end
	end
end

--- Receives RCLootCouncil commands
-- Params are delivered by AceComm-3.0, but we need to extract our data created with the
-- RCLootCouncil:SendCommand function.
-- @usage
-- To extract the original data using AceSerializer-3.0:
-- -- local success, command, data = self:Deserialize(serializedMsg)
-- 'data' is a table containing the varargs delivered to RCLootCouncil:SendCommand().
-- To ensure correct handling of x-realm commands, include this line aswell:
-- -- if RCLootCouncil:HandleXRealmComms(self, command, data, sender) then return end
function RCLootCouncil:OnCommReceived(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncil" then
		self:DebugLog("Comm received:", serializedMsg, "from:", sender, "distri:", distri)
		-- data is always a table to be unpacked
		local test, command, data = self:Deserialize(serializedMsg)
		-- NOTE: Since I can't find a better way to do this, all xrealms comms is routed through here
		--			to make sure they get delivered properly. Must be included in every OnCommReceived() function.
		if self:HandleXRealmComms(self, command, data, sender) then return end

		if test then
			if command == "lootTable" then
				if self:UnitIsUnit(sender, self.masterLooter) then
					local lootTable = unpack(data)
					-- Send "DISABLED" response when not enabled
					if not self.enabled then
						for i = 1, #lootTable do
							self:SendCommand("group", "response", i, self.playerName, {response = "DISABLED"})
						end
						return self:Debug("Sent 'DISABLED' response to", sender)
					end

					-- v2.0.1: It seems people somehow receives mldb with numButtons, so check for it aswell.
					if not self.mldb or (self.mldb and not self.mldb.numButtons) then -- Really shouldn't happen, but I'm tired of people somehow not receiving it...
						self:Debug("Received loot table without having mldb :(", sender)
						self:SendCommand(self.masterLooter, "MLdb_request")
						return self:ScheduleTimer("OnCommReceived", 1, prefix, serializedMsg, distri, sender)
					end

					self:SendCommand("group", "lootAck", self.playerName) -- send ack

					if db.autoPass then -- Do autopassing
						for ses, v in ipairs(lootTable) do
							if (v.boe and db.autoPassBoE) or not v.boe then
								if self:AutoPassCheck(v.subType, v.equipLoc, v.link) then
									self:Debug("Autopassed on: ", v.link)
									if not db.silentAutoPass then self:Print(format(L["Autopassed on 'item'"], v.link)) end
									self:SendCommand("group", "response", self:CreateResponse(ses, v.link, v.ilvl, "AUTOPASS", v.equipLoc))
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
				if self:UnitIsUnit(sender, self.masterLooter) then
					self.mldb = unpack(data)
				else
					self:Debug("Non-ML:", sender, "sent Mldb!")
				end

			elseif command == "verTest" and not self:UnitIsUnit(sender, "player") then -- Don't reply to our own verTests
				local otherVersion, tVersion = unpack(data)
				self:SendCommand(sender, "verTestReply", self.playerName, self.playerClass, self.guildRank, self.version, self.tVersion)
				if self.version < otherVersion and not self.verCheckDisplayed and (not (tVersion or self.tVersion)) then
					self:Print(format(L["version_outdated_msg"], self.version, otherVersion))
					self.verCheckDisplayed = true

				elseif tVersion and self.tVersion and not self.verCheckDisplayed and self.tVersion < tVersion then
					self:Print(format(L["tVersion_outdated_msg"], tVersion))
					self.verCheckDisplayed = true
				end

			elseif command == "verTestReply" then
				local _,_,_, otherVersion, tVersion = unpack(data)
				if self.version < otherVersion and not self.verCheckDisplayed and (not (tVersion or self.tVersion)) then
					self:Print(format(L["version_outdated_msg"], self.version, otherVersion))
					self.verCheckDisplayed = true

				elseif tVersion and self.tVersion and not self.verCheckDisplayed and self.tVersion < tVersion then
					self:Print(format(L["tVersion_outdated_msg"], tVersion))
					self.verCheckDisplayed = true
				end

			elseif command == "history" and db.enableHistory then
				local name, history = unpack(data)
				if historyDB[name] then
					tinsert(historyDB[name], history)
				else
					historyDB[name] = {history}
				end

			elseif command == "reroll" and self:UnitIsUnit(sender, self.masterLooter) and self.enabled then
				self:Print(format(L["'player' has asked you to reroll"], self.Ambiguate(sender)))
				self:CallModule("lootframe")
				self:GetActiveModule("lootframe"):ReRoll(unpack(data))

			elseif command == "playerInfoRequest" then
				self:SendCommand(sender, "playerInfo", self:GetPlayerInfo())

			elseif command == "message" then
				self:Print(unpack(data))

			elseif command == "session_end" and self.enabled then
				if self:UnitIsUnit(sender, self.masterLooter) then
					self:Print(format(L["'player' has ended the session"], self.Ambiguate(self.masterLooter)))
					self:GetActiveModule("lootframe"):Disable()
					if self.isCouncil or self.mldb.observe then -- Don't call the voting frame if it wasn't used
						self:GetActiveModule("votingframe"):EndSession()
					end
				else
					self:Debug("Non ML:", sender, "sent end session command!")
				end
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

-- Used to make sure "WHISPER" type xrealm comms is handled properly.
-- Include this right after unpacking messages. Assumes you use "OnCommReceived" as comm handler:
-- if RCLootCouncil:HandleXRealmComms(self, command, data, sender) then return end
function RCLootCouncil:HandleXRealmComms(mod, command, data, sender)
	if command == "xrealm" then
		local target = tremove(data, 1)
		if self:UnitIsUnit(target, "player") then
			local command = tremove(data, 1)
			mod:OnCommReceived("RCLootCouncil", self:Serialize(command, data), "WHISPER", self:UnitName(sender))
		end
		return true
	end
	return false
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
	self:Debug("Test", num)
	local testItems = {105473,105407,105513,105465,105482,104631,105450,105537,104554,105509,104412,105499,104476,104544,104495,105568,105594,105514,105479,104532,105639,104508,105621,}
	local items = {};
	-- pick "num" random items
	for i = 1, num do
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

function RCLootCouncil:GetPlayersGear(link, equipLoc)
	local itemID = self:GetItemIDFromLink(link) -- Convert to itemID
	self:DebugLog("GetPlayersGear", itemID, equipLoc)
	if not itemID then return nil, nil; end
	local item1, item2;
	-- check if the item is a token, and if it is, return the matching current gear
	if RCTokenTable[itemID] then
		if RCTokenTable[itemID] == "Trinket" then -- We need to return both trinkets
			item1 = GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET0SLOT"))
			item2 = GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET1SLOT"))
		else	-- Just return the slot from the tokentable
			item1 = GetInventoryItemLink("player", GetInventorySlotInfo(RCTokenTable[itemID]))
		end
		return item1, item2
	end
	local slot = INVTYPE_Slots[equipLoc]
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
	elseif type == "MLdb_check" then
		-- If we have a ML
		if self.masterLooter then
			-- But haven't received the mldb, then request it
			if not self.mldb then
				self:SendCommand(self.masterLooter, "MLdb_request")
			end
			-- and if we haven't received a council, request it
			if not self.council then
				self:SendCommand(self.masterLooter, "council_request")
			end
		end
	end
end

-- Classes that should auto pass a subtype
local autopassTable = {
	["Cloth"]					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "DEMONHUNTER"},
	["Leather"] 				= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK"},
	["Mail"] 					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Plate"]					= {"DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Shields"] 				= {"DEATHKNIGHT", "DRUID", "MONK", "ROGUE", "HUNTER","PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Bows"] 					= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Crossbows"] 				= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Daggers"]					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "HUNTER", },
	["Guns"]						= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK","SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Fist Weapons"] 			= {"DEATHKNIGHT", "PALADIN",  "PRIEST", "MAGE", "WARLOCK"},
	["One-Handed Axes"]		= {"DRUID", "MONK", "ROGUE", "PRIEST", "MAGE", "WARLOCK"},
	["One-Handed Maces"]		= {"MONK", "HUNTER", "MAGE", "WARLOCK"},
	["One-Handed Swords"] 	= {"DRUID", "SHAMAN", "PRIEST",},
	["Polearms"] 				= {"ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Staves"]					= {"WARRIOR", "DEATHKNIGHT", "PALADIN",  "ROGUE", "DEMONHUNTER"},
	["Two-Handed Axes"]		= {"DRUID", "ROGUE", "MONK", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Two-Handed Maces"]		= {"MONK", "ROGUE", "HUNTER", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Two-Handed Swords"]	= {"DRUID", "MONK", "ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Wands"]					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "DEMONHUNTER"},
	["Warglaives"]				= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "HUNTER", "SHAMAN",}
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
	["Warglaives"]				= 141604, -- Glaive of the Fallen
}

-- Never autopass these armor types
local autopassOverride = {
	"INVTYPE_CLOAK",
}

function RCLootCouncil:AutoPassCheck(subType, equipLoc, link)
	if not tContains(autopassOverride, equipLoc) then
		if subType and autopassTable[self.db.global.localizedSubTypes[subType]] then
			return tContains(autopassTable[self.db.global.localizedSubTypes[subType]], self.playerClass)
		end
		-- The item wasn't a type we check for, but it might be a token
		local id = type(link) == "number" and link or self:GetItemIDFromLink(link) -- Convert to id if needed
		if RCTokenClasses[id] then -- It's a token
			return not tContains(RCTokenClasses[id], self.playerClass)
		end
	end
	return false
end

function RCLootCouncil:LocalizeSubTypes()
	if self.db.global.localizedSubTypes.created then return end -- We only need to create it once
	-- Get the item info
	for _, item in pairs(subTypeLookup) do
		GetItemInfo(item)
	end
	self.db.global.localizedSubTypes = {} -- reset
	self.db.global.localizedSubTypes.created = true
	for name, item in pairs(subTypeLookup) do
		local sType = select(7, GetItemInfo(item))
		if sType then
			self.db.global.localizedSubTypes[sType] = name
			self:DebugLog("Found "..name.." localized as: "..sType)
		else -- Probably not cached, set a timer
			self:Debug("We didn't find:", name, item)
			self:ScheduleTimer("Timer", 2, "LocalizeSubTypes")
			self.db.global.localizedSubTypes.created = false
			return
		end
	end
end

function RCLootCouncil:IsItemBoE(item)
	if not item then return false end
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

--- Formats a response for the player to be send to the group
-- @param session		The session to respond to
-- @param link 		The itemLink of the item in the session
-- @param ilvl			The ilvl of the item in the session
-- @param response	The selected response, must be index of db.responses
-- @param equipLoc	The item in the session's equipLoc
-- @param note			The player's note
-- @returns A formatted table that can be passed directly to :SendCommand("group", "response", -return-)
function RCLootCouncil:CreateResponse(session, link, ilvl, response, equipLoc, note)
	self:DebugLog("CreateResponse", session, link, ilvl, response, equipLoc, note)
	local g1, g2 = self:GetPlayersGear(link, equipLoc)
	local diff = nil
	if g1 then diff = (ilvl - select(4, GetItemInfo(g1))) end
	return
		session,
		self.playerName,
		{	gear1 = g1,
			gear2 = g2,
			ilvl = math.floor(select(2,GetAverageItemLevel())),
			diff = diff,
			note = note,
			response = response
		}
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

function RCLootCouncil:GetPlayerInfo()
	-- Check if the player has enchanting
	local enchant, lvl = nil, 0
	local prof1, prof2 = GetProfessions()
	if prof1 or prof2 then
		for i = 1, 2 do
			local _, _, rank, _, _, _, id = GetProfessionInfo(select(i, prof1, prof2))
			if id and id == 333 then -- NOTE: 333 should be enchanting, let's hope that holds...
				self:Debug("I'm an enchanter")
				enchant, lvl = true, rank
			end
		end
	end
	return self.playerName, self.playerClass, self:GetPlayerRole(), self.guildRank, enchant, lvl
end

function RCLootCouncil:GetPlayerRole()
	return UnitGroupRolesAssigned("player")
end

function RCLootCouncil.TranslateRole(role) -- reasons
	return (role and role ~= "") and RCLootCouncil.roleTable[role] or ""
end

--- GetGuildRanks
-- Returns a lookup table containing GuildRankNames and their index
-- @return table "GuildRankName" = rankIndex
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
	end
	return text;
end

function RCLootCouncil:OnEvent(event, ...)
	if event == "PARTY_LOOT_METHOD_CHANGED" then
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
		-- Ask for data when we have done a /rl and have a ML
		if not self.isMasterLooter and self.masterLooter and self.masterLooter ~= "" and player_relogged then
			self:ScheduleTimer("SendCommand", 2, self.masterLooter, "reconnect")
			self:SendCommand(self.masterLooter, "playerInfo", self:GetPlayerInfo()) -- Also send out info, just in case
		end
		player_relogged = false

	elseif event == "GUILD_ROSTER_UPDATE" then
		self.guildRank = self:GetPlayersGuildRank();
		if unregisterGuildEvent then
			self:UnregisterEvent("GUILD_ROSTER_UPDATE"); -- we don't need it any more
			self:GetGuildOptions() -- get the guild data to the options table now that it's ready
		end
	end
end

function RCLootCouncil:NewMLCheck()
	local old_ml = self.masterLooter
	self.isMasterLooter, self.masterLooter = self:GetML()

	if self:UnitIsUnit(old_ml, "player") and not self.isMasterLooter then
		-- We were ML, but no longer, so disable masterlooter module
		self:GetActiveModule("masterlooter"):Disable()
	end
	if self:UnitIsUnit(old_ml, self.masterLooter) or db.usage.never then return end -- no change
	if not self.isMasterLooter and self.masterLooter then return end -- Someone else is ML

	-- We are ML and shouldn't ask the player for usage
	if self.isMasterLooter and db.usage.ml then -- addon should auto start
		self:Print(L["Now handles looting"])
		if db.autoAward and GetLootThreshold() ~= 2 and GetLootThreshold() > db.autoAwardLowerThreshold  then
			self:Print(L["Changing loot threshold to enable Auto Awarding"])
			SetLootThreshold(db.autoAwardLowerThreshold >= 2 and db.autoAwardLowerThreshold or 2)
		end
		self:CallModule("masterlooter")
		self:GetActiveModule("masterlooter"):NewML(self.masterLooter)

	-- We're ML and must ask the player for usage
	elseif self.isMasterLooter and db.usage.ask_ml then
		return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")
	end
end

function RCLootCouncil:OnRaidEnter(arg)
	-- NOTE: We shouldn't need to call GetML() as it's most likely called on "LOOT_METHOD_CHANGED"
	-- There's no ML, and lootmethod ~= ML, but we are the group leader
	if not self.masterLooter and UnitIsGroupLeader("player") then
		-- We don't need to ask the player for usage, so change loot method to master, and make the player ML
		if db.usage.leader then
			SetLootMethod("master", self.Ambiguate(self.playerName))
			self:Print(L[" you are now the Master Looter and RCLootCouncil is now handling looting."])
			if db.autoAward and GetLootThreshold() ~= 2 and GetLootThreshold() > db.autoAwardLowerThreshold  then
				self:Print(L["Changing loot threshold to enable Auto Awarding"])
				SetLootThreshold(db.autoAwardLowerThreshold >= 2 and db.autoAwardLowerThreshold or 2)
			end
			self.isMasterLooter, self.masterLooter = true, self.playerName
			self:CallModule("masterlooter")
			self:GetActiveModule("masterlooter"):NewML(self.masterLooter)

		-- We must ask the player for usage
		elseif db.usage.ask_leader then
			return LibDialog:Spawn("RCLOOTCOUNCIL_CONFIRM_USAGE")
		end
	end
end

-- Returns boolean, mlName. (true if the player is ML), (nil if there's no ML)
function RCLootCouncil:GetML()
	self:DebugLog("GetML()")
	if GetNumGroupMembers() == 0 and (self.testMode or self.nnp) then -- always the player when testing alone
		return true, self.playerName
	end
	local lootMethod, mlPartyID, mlRaidID = GetLootMethod()
	self:Debug("LootMethod = ", lootMethod)
	if lootMethod == "master" then
		local name;
		if mlRaidID then 				-- Someone in raid
			name = self:UnitName("raid"..mlRaidID)
		elseif mlPartyID == 0 then -- Player in party
			name = self.playerName
		elseif mlPartyID then		-- Someone in party
			name = self:UnitName("party"..mlPartyID)
		end
		self:Debug("MasterLooter = ", name)
		-- Check to see if we have recieved mldb within 10 secs, otherwise request it
		self:ScheduleTimer("Timer", 10, "MLdb_check")
		return IsMasterLooter(), name
	end
	return false, nil;
end

function RCLootCouncil:IsCouncil(name)
	local ret = tContains(self.council, self:UnitName(name))
	if self:UnitIsUnit(name, self.playerName) and self.isMasterLooter or self.nnp then ret = true end -- ML and nnp is always council
	self:DebugLog(tostring(ret).." =", "IsCouncil", name)
	return ret
end

--- Returns a table containing the the council members in the group
function RCLootCouncil:GetCouncilInGroup()
	local council = {}
	if IsInRaid() then
		for k,v in ipairs(self.council) do
			if UnitInRaid(Ambiguate(v, "short")) then
				tinsert(council, v)
			end
		end
	elseif IsInGroup() then -- Party
		for k,v in ipairs(self.council) do
			if UnitInParty(Ambiguate(v, "short")) then
				tinsert(council, v)
			end
		end
	elseif self.isCouncil then -- When we're alone
		tinsert(council, self.playerName)
	end
	if #council == 0 and self.masterLooter then -- We can't have empty council
		tinsert(council, self.masterLooter)
	end
	self:DebugLog("GetCouncilInGroup", unpack(council))
	return council
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

function RCLootCouncil:GetAnnounceChannel(channel)
	return channel == "group" and (IsInRaid() and "RAID" or "PARTY") or channel
end

function RCLootCouncil:GetItemIDFromLink(link)
	return tonumber(strmatch(link, "item:(%d+):"))
end

--- Custom, better UnitIsUnit() function
-- Blizz UnitIsUnit() doesn't know how to compare unit-realm with unit
-- Seems to be because unit-realm isn't a valid unitid
function RCLootCouncil:UnitIsUnit(unit1, unit2)
	if not unit1 or not unit2 then return false end
	-- Remove realm names, if any
	if strfind(unit1, "-", nil, true) ~= nil then
		unit1 = Ambiguate(unit1, "short")
	end
	if strfind(unit2, "-", nil, true) ~= nil then
		unit2 = Ambiguate(unit2, "short")
	end
	return UnitIsUnit(unit1, unit2)
end

-- We always want realm name when we call UnitName
-- Note: If 'unit' is a playername, that player must be in our raid or party!
--[[ NOTE I'm concerned about the UnitIsVisible() range thing with UnitName(),
 	although testing in party doesn't seem to affect it. To counter this, it'll
	return any "unit" with something after a "-" (i.e a name from GetRaidRosterInfo())
	which means it isn't useable with all the "name-target" unitIDs]]
function RCLootCouncil:UnitName(unit)
	-- First strip any spaces
	unit = gsub(unit, " ", "")
	-- Then see if we already have a realm name appended
	local find = strfind(unit, "-", nil, true)
	if find and find < #unit then -- "-" isn't the last character
		return unit
	end
	-- Proceed with UnitName()
	local name, realm = UnitName(unit)
	if not realm or realm == "" then realm = self.realmName end -- Extract our own realm
	return name and name.."-"..realm or nil
end

---------------------------------------------------------------------------
-- Custom module support funcs
---------------------------------------------------------------------------

--- Enables a userModule if set, defaultModule otherwise
-- @paramsig module
-- @param module String, must correspond to a index in self.defaultModules
function RCLootCouncil:CallModule(module)
	if not self.enabled then return end -- Don't call modules unless enabled
	self:EnableModule(userModules[module] or defaultModules[module])
end

--- Returns the active module
--	Always use this when calling functions in another module
-- @paramsig module
-- @param module String, must correspond to a index in self.defaultModules
-- @return The module object of the active module or nil if not found. Prioritises userModules if set
function RCLootCouncil:GetActiveModule(module)
	return self:GetModule(userModules[module] or defaultModules[module], false)
end

--- Registers a module that should override a default module
-- The custom module must have all functions that a default module can be called with
-- @param type Index (string) in userModules
-- @param The name passed to AceAddon:NewModule()
function RCLootCouncil:RegisterUserModule(type, name)
	assert(defaultModules[type], format("Module \"%s\" is not a default module.", tostring(type)))
	userModules[type] = name
end

--#end Module support -----------------------------------------------------


---------------------------------------------------------------------------
-- UI Functions used throughout the addon
---------------------------------------------------------------------------

--- Used as a "DoCellUpdate" function for lib-st
function RCLootCouncil.SetCellClassIcon(rowFrame, frame, data, cols, row, realrow, column, fShow, table, class)
	local celldata = data[realrow].cols and data[realrow].cols[column] or data[realrow][column]
	local class = celldata.args and celldata.args[1] or class
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
		return {r=1,g=1,b=1,a=1}--{["r"] = 0.63921568627451, ["g"] = 0.2078431372549, ["b"] = 0.93333333333333, ["a"] = 1.0 };
	else
		color.a = 1.0
		return color
	end
end

function RCLootCouncil:RGBToHex(r,g,b)
	return string.format("%02x%02x%02x",255*r, 255*g, 255*b)
end

--- Creates a standard frame for RCLootCouncil with title, minimizuing, positioning and zoom support.
--		Adds Minimize(), Maximize() and IsMinimized() functions on the frame, and registers it for hide on combat.
--		SetWidth/SetHeight called on frame will also be called on frame.content
--		Minimizing is done by double clicking the title. The returned frame and frame.title is NOT minimized.
-- 	Only frame.content is minimized, so put children there for minimize support.
-- @paramsig name, cName, title[, width, height]
-- @param name Global name of the frame
-- @param cName Name of the module (used for lib-window-1.1 config in db.UI[cName])
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
		old_setheight(self, width)
		self.content:SetHeight(height)
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
-- @paramsig ...
-- @param ... Lines to be added.
function RCLootCouncil:CreateTooltip(...)
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	for i = 1, select("#", ...) do
		GameTooltip:AddLine(select(i, ...),1,1,1)
	end
	GameTooltip:Show()
end

--- Displays a hyperlink tooltip
-- @paramsig link
-- @param link The link to display
function RCLootCouncil:CreateHypertip(link)
	if not link or link == "" then return end
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	GameTooltip:SetHyperlink(link)
end

--- Hide the tooltip created with :CreateTooltip()
function RCLootCouncil:HideTooltip()
	GameTooltip:Hide()
end

--- Removes any realm name from name
-- @paramsig name
-- @param name Name with(out) realmname
-- @return The name, with(out) realmname according to selected options
function RCLootCouncil.Ambiguate(name)
	return db.ambiguate and Ambiguate(name, "none") or Ambiguate(name, "short")
end

--- Returns the text of a button, returning settings from mldb, or default buttons
-- @paramsig index
-- @param index The button's index
function RCLootCouncil:GetButtonText(i)
	return (self.mldb.buttons and self.mldb.buttons[i]) and self.mldb.buttons[i].text or db.buttons[i].text
end

--- The following functions returns the text, sort or color of a response, returning a result from mldb if possible, otherwise the default responses.
-- @paramsig response
-- @param response Index in db.responses
function RCLootCouncil:GetResponseText(response)
	return (self.mldb.responses and self.mldb.responses[response]) and self.mldb.responses[response].text or db.responses[response].text
end

function RCLootCouncil:GetResponseColor(response)
	local color = (self.mldb.responses and self.mldb.responses[response]) and self.mldb.responses[response].color or db.responses[response].color
	return unpack(color)
end

function RCLootCouncil:GetResponseSort(response)
	return (self.mldb.responses and self.mldb.responses[response]) and self.mldb.responses[response].sort or db.responses[response].sort
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
