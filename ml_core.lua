--[[--- ml_core.lua	Contains core elements for the MasterLooter.
	Although possible, this module shouldn't be replaced unless closely replicated as other default modules depend on it.
	Assumes several functions in SessionFrame and VotingFrame.
	@author Potdisc
]]

--[[TODOs/NOTES:
]]

local _,addon = ...
_G.RCLootCouncilML = addon:NewModule("RCLootCouncilML", "AceEvent-3.0", "AceBucket-3.0", "AceComm-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

-- WoW API
local GetItemInfo, GetItemInfoInstant, GetRaidRosterInfo
	 = GetItemInfo, GetItemInfoInstant, GetRaidRosterInfo
-- Lua
local time, date, tonumber, unpack, select, wipe, pairs, ipairs, format, table, tinsert, tremove, bit, tostring, type, tFilter
	 = time, date, tonumber, unpack, select, wipe, pairs, ipairs, format, table, tinsert, tremove, bit, tostring, type, tFilter

local db;

local LOOT_TIMEOUT = 5 -- If we give loot to someone, but loot slot is not cleared after this time period, consider this loot distribute as failed.
						-- The real time needed is the sum of two players'(ML and the awardee) latency, so 1 second timeout should be enough.
						-- v2.17: There's reports of increased latency, especially in Classic - bump to 3 seconds.
local CANDIDATE_SEND_COOLDOWN = 10
local COUNCIL_COMMS_THROTTLE = 5

function RCLootCouncilML:OnInitialize()
	addon:Debug("ML initialized!")
end

function RCLootCouncilML:OnDisable()
	addon:Debug("ML Disabled")
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()
	self:UnregisterAllComm()
	self:UnregisterAllMessages()
	self:UnhookAll()
end

function RCLootCouncilML:OnEnable()
	db = addon:Getdb()
	self.candidates = {} 	-- candidateName = { class, role, rank }
	self.lootTable = {} 		-- The MLs operating lootTable, see ML:AddItem()
	self.oldLootTable = {}
	self.lootQueue = {}     -- Items ML have attempted to give out that waiting for LOOT_SLOT_CLEARED
	self.running = false		-- true if we're handling a session
	self.council = self:GetCouncilInGroup()
	self.combatQueue = {}	-- The functions that will be executed when combat ends. format: [num] = {func, arg1, arg2, ...}
	self.timers = {}			-- Table to hold timer references. Each value is the name of a timer, whose value is the timer id.

	self:RegisterComm("RCLootCouncil", 		"OnCommReceived")
	self:RegisterEvent("CHAT_MSG_WHISPER",	"OnEvent")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 10, "UpdateGroup") -- Bursts in group creation, and we should have plenty of time to handle it
	self:RegisterBucketMessage("RCConfigTableChanged", 5, "ConfigTableChanged") -- The messages can burst
	self:RegisterMessage("RCCouncilChanged", "CouncilChanged")
end

-- REVIEW v2.15 Almost all of these are added to `RCLootCouncil:PrepareLootTable` and can be removed from here.
function RCLootCouncilML:GetItemInfo(item)
	local name, link, rarity, ilvl, iMinLevel, type, subType, iStackCount, equipLoc, texture, sellPrice, typeID, subTypeID, bindType, expansionID, itemSetID, isCrafting = GetItemInfo(item) -- luacheck: ignore
	local itemID = link and addon:GetItemIDFromLink(link)
	if name then
		return {
			["link"]			= link,
			["quality"]		= rarity,
			["ilvl"]			= addon:GetTokenIlvl(link) or ilvl, -- if the item is a token, ilvl is the min ilvl of the item it creates.
			["equipLoc"]	= RCTokenTable[itemID] and addon:GetTokenEquipLoc(RCTokenTable[itemID]) or equipLoc,
			["subType"]		= subType,
			["texture"]		= texture,
			["boe"]			= bindType == LE_ITEM_BIND_ON_EQUIP,
			--["relic"]		= itemID and IsArtifactRelicItem(itemID) and select(3, C_ArtifactUI.GetRelicInfoByItemID(itemID)),
			--["token"]		= itemID and RCTokenTable[itemID],
			["typeID"]		= typeID,
			["subTypeID"]	= subTypeID,
			["classes"]		= addon:GetItemClassesAllowedFlag(link)
		}
	else
		return nil
	end
end

--- Add an item to the lootTable
--- You CAN sort or delete entries in the lootTable while an item is being added.
--- @paramsig item[, bagged, slotIndex, index]
--- @param item ItemID|itemString|itemLink
--- @param bagged Item? The Item as stored in ItemStorage. Item is bagged if not nil.
--- @param slotIndex integer? Index of the lootSlot, or nil if none - either this or 'bagged' needs to be supplied
--- @param owner? string The owner of the item (if any). Defaults to 'BossName'.
--- @param entry? table Used to set data in a specific lootTable entry.
--- @param boss? string Set to override boss name. Defaults to `RCLootCouncil.bossName`.
function RCLootCouncilML:AddItem(item, bagged, slotIndex, owner, entry, boss)
	addon:DebugLog("ML:AddItem", item, bagged, slotIndex, owner, entry, boss)
	if type(item) == "string" and item:find("|Hcurrency") then return end -- Ignore "Currency" item links

	if not entry then
		entry = {}
		self.lootTable[#self.lootTable + 1] = entry
	else
		wipe(entry) -- Clear the entry. Don't use 'entry = {}' here to preserve table pointer.
	end

	entry.bagged = bagged
	entry.lootSlot = slotIndex
	entry.awarded = false
	entry.owner = owner or addon.bossName
	entry.boss = boss or addon.bossName
	entry.isSent = false
	entry.typeCode = self:GetTypeCodeForItem(item)

	local itemInfo = self:GetItemInfo(item)

	if itemInfo then
		for k, v in pairs(itemInfo) do
			entry[k] = v
		end
	end

	-- Item isn't properly loaded, so update the data next frame (Should only happen with /rc test)
	if not itemInfo then
		self:ScheduleTimer("Timer", 0, "AddItem", item, bagged, slotIndex, owner, entry, boss)
		addon:Debug("Started timer:", "AddItem", "for", item)
	else
		addon:SendMessage("RCMLAddItem", item, entry)
	end
end

function RCLootCouncilML:GetLootTableForTransmit()
	local copy = CopyTable(self.lootTable)
	for k, v in pairs(copy) do
		if v.isSent then -- Don't retransmit already sent items
			copy[k] = nil
		else
			v["equipLoc"] = select(4, GetItemInfoInstant(v.link))
			v["typeID"] = nil
			v["subTypeID"] = nil
			v["bagged"] = nil -- Only ML needs this.
		end
	end
	return copy
end

--- Removes a session from the lootTable
-- @param session The session (index) in lootTable to remove
function RCLootCouncilML:RemoveItem(session)
	tremove(self.lootTable, session)
end

--- Generates a "type code" used to determine which set of buttons to use for the item.
-- The returned code can be used directly in `mldb.responses[code]` and `mldb.buttons[code]`.
-- @See Constants.lua > RESPONSE_CODE_GENERATORS for more.
function RCLootCouncilML:GetTypeCodeForItem (item)
	local itemID, _, _, itemEquipLoc, _, itemClassID, itemSubClassID = GetItemInfoInstant(item)
	if not itemID then return "default" end -- We can't handle uncached items!

	for _,func in ipairs(addon.RESPONSE_CODE_GENERATORS) do
		local val = func(item, db, itemID, itemEquipLoc,itemClassID, itemSubClassID)
		if val then return val end
	end
	 -- Remaining is simply their equipLoc, if set
	 return db.enabledButtons[itemEquipLoc] and itemEquipLoc or "default"
end

function RCLootCouncilML:AddCandidate(name, class, role, rank, enchant, lvl, ilvl, specID)
	addon:DebugLog("ML:AddCandidate",name, class, role, rank, enchant, lvl, ilvl, specID)
	self.candidates[name] = {
		["class"]		= class,
		["role"]			= role,
		["rank"]			= rank or "", -- Rank cannot be nil for votingFrame
		["enchanter"] 	= enchant,
		["enchant_lvl"]= lvl,
		["specID"]		= specID,
	}
end

function RCLootCouncilML:RemoveCandidate(name)
	addon:DebugLog("ML:RemoveCandidate", name)
	self.candidates[name] = nil
end

function RCLootCouncilML:UpdateGroup(ask)
	addon:DebugLog("UpdateGroup", ask)
	if type(ask) ~= "boolean" then ask = false end
	local group_copy = {}
	local updates = false
	for name, v in pairs(self.candidates) do	group_copy[name] = v.role end
	for i = 1, GetNumGroupMembers() do
		local name, _, _, _, _, class, _, _, _, _, _, role  = GetRaidRosterInfo(i)
		if name then -- Apparantly name can be nil (ticket #223)
			name = addon:UnitName(name) -- Get their unambiguated name
			if group_copy[name] then -- If they're already registered
				if group_copy[name] ~= role then	-- They have changed their role
					self:AddCandidate(name, class, role, self.candidates[name].rank, self.candidates[name].enchanter, self.candidates[name].enchant_lvl, nil, self.candidates[name].specID)
					updates = true
				end
				group_copy[name] = nil -- Remove them, as they're still in the group
			else -- add them
				if not ask then -- ask for playerInfo?
					addon:SendCommand(name, "playerInfoRequest")
				end
				self:AddCandidate(name, class, role) -- Add them in case they haven't installed the adoon
				updates = true
			end
		else
			addon:Debug("ML:UpdateGroup", "GetRaidRosterInfo returns nil. Abort and retry after 1s.")
			return self:ScheduleTimer("UpdateGroup", 1, ask) -- Group info is not ready. Abort and retry.
		end
	end
	-- If anything's left in group_copy it means they left the raid, so lets remove them
	for name, v in pairs(group_copy) do
		if v then self:RemoveCandidate(name); updates = true end
	end
	if updates then
		addon:SendCommand("group", "MLdb", addon.mldb)
		self:SendCandidates()

		local oldCouncil = self.council
		self.council = self:GetCouncilInGroup()
		local councilUpdated = false
		if #self.council ~= #oldCouncil then
			councilUpdated = true
		else
			for i in ipairs(self.council) do
				if self.council[i] ~= oldCouncil[i] then
					councilUpdated = true
					break
				end
			end
		end
		if councilUpdated then
			self:SendCouncil()
		end
	end
end

-- Helpers for ML:SendCandidates
local function SendCandidates()
	addon:SendCommand("group", "candidates", RCLootCouncilML.candidates)
	RCLootCouncilML.timers.candidate_send = nil
	addon:DebugLog("ML:SendCandidates()")
end
local function OnCandidatesCooldown()
	RCLootCouncilML.timers.candidates_cooldown = nil
	addon:DebugLog("RCLootCouncilML:OnCandidatesCooldown()")
end

--- Sends candidates to the group no more than every CANDIDATE_SEND_COOLDOWN seconds.
-- Use this for all candidate sends!
function RCLootCouncilML:SendCandidates ()
	addon:DebugLog("RCLootCouncilML:SendCandidates()")
	if self.timers.candidates_cooldown then -- Recently sent one
		addon:DebugLog("candidates_cooldown == true")
		if self.timers.candidate_send then -- And we've queued a new one
			addon:DebugLog("candidate_send == true")
			return -- Do nothing, it'll be sent once the current timer ends
		else
			addon:DebugLog("candidate_send == false")
			-- Send the candidates when the grace period is done
			local timeRemaining = self:TimeLeft(self.timers.candidates_cooldown)
			self.timers.candidate_send = self:ScheduleTimer(SendCandidates, timeRemaining)
			return
		end
	else
		addon:DebugLog("candidates_cooldown == false")
		-- No cooldown, send immediately and start the cooldown
		self.timers.candidates_cooldown = self:ScheduleTimer(OnCandidatesCooldown, CANDIDATE_SEND_COOLDOWN)
		addon:SendCommand("group", "candidates", self.candidates)
	end
end

local function SendCouncil ()
	addon:SendCommand("group", "council", RCLootCouncilML.council)
	RCLootCouncilML.timers.council_send = nil
	addon:DebugLog("ML:SendCouncil()")
end

local function OnCouncilCooldown ()
	RCLootCouncilML.timers.council_cooldown = nil
	addon:DebugLog("ML:OnCouncilCooldown()")
end

-- Quick solution for throtteling council comms.
-- Group Loot support expects the ML to always send council, which is doesn't
-- if changing from ML to GL (as the ML hasn't changed).
-- We will receive numurous `council_request`, but only need to reply once.
-- Same goes for a few detected edge cases in ML where council isn't properly sent (reason unknown).
-- Basically a copy of `SendCandidates`
function RCLootCouncilML:SendCouncil ()
	if self.timers.council_cooldown then
		if self.timers.council_send then
			return -- do nothing, comm is queued.
		else -- Cooldown, but nothing queued - queue the command for when cooldown is done.
			local timeRemaining = self:TimeLeft(self.timers.council_cooldown)
			self.timers.council_send = self:ScheduleTimer(SendCouncil, timeRemaining)
			return
		end
	else -- No cooldown, send and start cooldown
		self.timers.council_cooldown = self:ScheduleTimer(OnCouncilCooldown, COUNCIL_COMMS_THROTTLE)
		SendCouncil()
	end
end

function RCLootCouncilML:StartSession()
	addon:Debug("ML:StartSession()")
	-- Make sure we haven't started the session too fast
	if not addon.candidates[addon.playerName] or #addon.council == 0 then
		addon:Print(L["Please wait a few seconds until all data has been synchronized."])
		self:SendCandidates() -- Ensure they get sent.
		return addon:Debug("Data wasn't ready", addon.candidates[addon.playerName], #addon.council)
	end


	if db.sortItems and not self.running then
		self:SortLootTable(self.lootTable)
	end
	if self.running then -- We're already running a sessions, so any new items needs to get added
		-- REVIEW This is not optimal, but will be changed anyway with the planned comms changes for v3.0
		--local count = 0
		--for k,v in ipairs(self.lootTable) do if not v.isSent then count = count + 1 end end
		addon:SendCommand("group", "lt_add", self:GetLootTableForTransmit())
	else
		addon:SendCommand("group", "lootTable", self:GetLootTableForTransmit())
	end
	for _, v in ipairs(self.lootTable) do
		v.isSent = true
	end
	self.running = true
	self:AnnounceItems(self.lootTable)

	-- Print some help messages for not direct mode.
	if not addon.testMode then
		-- Use the first entry in lootTable to determinte mode
		if not self.lootTable[1].lootSlot then
			addon:ScheduleTimer("Print", 1, L["session_help_not_direct"]) -- Delay a bit, so annouceItems are printed first.
		end
		if self.lootTable[1].bagged then
			addon:ScheduleTimer("Print", 1, L["session_help_from_bag"]) -- Delay a bit, so annouceItems are printed first.
		end
	end
end

function RCLootCouncilML:AddUserItem(item, username)
	self:AddItem(item, false, nil, username) -- The item is neither bagged nor in the loot slot.
	addon:CallModule("sessionframe")
	addon:GetActiveModule("sessionframe"):Show(self.lootTable)
end

function RCLootCouncilML:SessionFromBags()
	if self.running then return addon:Print(L["You're already running a session."]) end
	local Items = addon.ItemStorage:GetAllItemsOfType("award_later")
	if #Items == 0 then return addon:Print(L["No items to award later registered"]) end
	for _, v in ipairs(Items) do
		self:AddItem(v.link, v, nil, addon.playerName, nil, v.args.boss)
	end
	if db.autoStart then
		self:StartSession()
	else
		addon:CallModule("sessionframe")
		addon:GetActiveModule("sessionframe"):Show(self.lootTable, true)  -- Disable award later checkbox in the sessionframe
	end
end

function RCLootCouncilML:ClearOldItemsInBags()
	local Items = addon.ItemStorage:GetAllItemsOfType("award_later")
	for _,Item in ipairs(Items) do
		Item:UpdateTime()
		if (Item.args.bop and Item:TimeRemaining() < 0) or -- BoP item, 2 hrs
			time() - Item.time_added > 3600 * 6 then -- Non BoP, timeout after 6 hrs
			addon:DebugLog("ML: Removed Item", Item.link, "due to timeout.")
				addon.ItemStorage:RemoveItem(Item)
				-- REVIEW Notify the user?
		end
	end
end

function RCLootCouncilML:ClearAllItemsInBags()
	addon.ItemStorage:RemoveAllItemsOfType("award_later")
	addon:Print(L["The award later list has been cleared."])
end

-- Print all items that should be awarded later
function RCLootCouncilML:PrintItemsInBags()
	local Items = addon.ItemStorage:GetAllItemsOfType("award_later")
	if #Items == 0 then
		return addon:Print(L["The award later list is empty."])
	end
	addon:Print(L["Following items were registered in the award later list:"])
	for i, Item in ipairs(Items) do
		Item:UpdateTime()
		addon:Print(i .. ". " .. Item.link, format(GUILD_BANK_LOG_TIME, SecondsToTime(time() - Item.time_added, true)))
		-- GUILD_BANK_LOG_TIME == "( %s ago )", although the constant name does not make sense here, this constant expresses we intend to do.
		-- SecondsToTime is defined in SharedXML/util.lua
	end
end

-- Print awarded items in bags, in the order of awardee's name.
-- CHANGED: This functionality is now handled by TradeUI, but is updated to still work
function RCLootCouncilML:PrintAwardedInBags()
	local Items = addon.ItemStorage:GetAllItemsOfType("to_trade")
	if #Items == 0 then
		return addon:Print(L["No winners registered"])
	end
	addon:Print(L["Following winners was registered:"])
	local sortedByWinner = tFilter(Items, function(v) return v.args.recipient end)
	table.sort(sortedByWinner, function(a, b)
		if a.args.recipient == b.args.recipient then
			return a.time_added < b.time_added
		else
			return a.args.recipient < b.args.recipient
		end
	end)

	for _, v in ipairs(sortedByWinner) do -- difference with :PrintItemsInBags is that the index is not printed.
		addon:Print(v.link, "-->", v.args.recipient and addon:GetUnitClassColoredName(v.args.recipient) or L["Unawarded"],
			format(GUILD_BANK_LOG_TIME, SecondsToTime(time()-v.time_added)) )
	end
end

-- @param ... indexes
-- Remove entries in the award later list with the those index
-- Accept number or strings that can be converted into number as input
function RCLootCouncilML:RemoveItemsInBags(...)
	local indexes = {...}

	table.sort(indexes, function(a, b)
		if tonumber(a) and tonumber(b) then
			return tonumber(a) < tonumber(b)
		end
	end)
	local Items = addon.ItemStorage:GetAllItemsOfType("award_later")
	local removedEntries = {}
	for i=#indexes, 1, -1 do
		local index = tonumber(indexes[i])
		if index and Items[index] then
			addon.ItemStorage:RemoveItem(Items[index])
			tinsert(removedEntries, 1, Items[index])
		end
	end
	if #removedEntries == 0 then
		addon:Print(L["No entry in the award later list is removed."])
	else
		addon:Print(L["The following entries are removed from the award later list:"])
		for k, v in ipairs(removedEntries) do
			addon:Print(k..". "..v.link, "-->", v.args.recipient and addon:GetUnitClassColoredName(v.args.recipient) or L["Unawarded"],
				format(GUILD_BANK_LOG_TIME, SecondsToTime(time() - v.time_added)))
		end
	end
end

-- Check if there are any BOP item in the player's inventory that is in the award later list and has low trade time remaining.
-- If yes, print the items to remind the user.
local lastCheckItemsInBagsLowTradeTimeRemainingReminder = 0
function RCLootCouncilML:ItemsInBagsLowTradeTimeRemainingReminder()
	if GetTime() - lastCheckItemsInBagsLowTradeTimeRemainingReminder < 120 then -- Dont spam
		return
	end
	local entriesToRemind = {}
	local remindThreshold = 1200 -- 20min
	local Items = addon.ItemStorage:GetAllItemsOfType("award_later")
	local remainingTime
	for k, Item in ipairs(Items) do
		remainingTime = Item:TimeRemaining()
		if remainingTime > 0 and remainingTime < remindThreshold then
			tinsert(entriesToRemind, { index = k, Item = Item, remainingTime = remainingTime })
		end
	end

	if #entriesToRemind > 0 then
		addon:Print(format(L["item_in_bags_low_trade_time_remaining_reminder"], "|cffff0000"..SecondsToTime(remindThreshold).."|r"))
		for _, v in ipairs(entriesToRemind) do
			addon:Print(v.index .. ". " .. v.Item.link, "-->",
				v.Item.args.recipient and addon:GetUnitClassColoredName(v.Item.args.recipient) or L["Unawarded"],
				"(", _G.CLOSES_IN..":", SecondsToTime(v.remainingTime), ")")
		end
	end
	lastCheckItemsInBagsLowTradeTimeRemainingReminder = GetTime()
end

function RCLootCouncilML:ConfigTableChanged(value)
	-- The db was changed, so check if we should make a new mldb
	-- We can do this by checking if the changed value is a key in mldb
	if not addon.mldb then return self:UpdateMLdb() end -- mldb isn't made, so just make it
	for val in pairs(value) do
		for key in pairs(addon.mldb) do
			if key == val then return self:UpdateMLdb() end
		end
	end
end

function RCLootCouncilML:CouncilChanged()
	-- The council was changed, so send out the council
	self.council = self:GetCouncilInGroup()
	self:SendCouncil()
	-- Send candidates so new council members can register it
	self:SendCandidates()
end

function RCLootCouncilML:UpdateMLdb()
	-- The db has changed, so update the mldb and send the changes
	addon:Debug("UpdateMLdb")
	addon:OnMLDBReceived(self:BuildMLdb())
	addon:SendCommand("group", "MLdb", addon.mldb)
end

function RCLootCouncilML:BuildMLdb()
	-- Extract changes to responses/buttons
	local changedResponses = {};
	for type, responses in pairs(db.responses) do
		for i in ipairs(responses) do
			if i > db.buttons[type].numButtons then break end
			if not addon.defaults.profile.responses[type]
			or db.responses[type][i].text ~= addon.defaults.profile.responses[type][i].text
			or unpack(db.responses[type][i].color) ~= unpack(addon.defaults.profile.responses[type][i].color) then
				if not changedResponses[type] then changedResponses[type] = {} end
				changedResponses[type][i] = db.responses[type][i]
			end
		end
	end
	local changedButtons = {default = {}};
	for type, buttons in pairs(db.buttons) do
		for i in ipairs(buttons) do
			if i > db.buttons[type].numButtons then break end
			if not addon.defaults.profile.buttons[type]
			or db.buttons[type][i].text ~= addon.defaults.profile.buttons[type][i].text then
				if not changedButtons[type] then changedButtons[type] = {} end
				changedButtons[type][i] = {text = db.buttons[type][i].text}
			end
		end
	end
	changedButtons.default.numButtons = db.buttons.default.numButtons -- Always include this

	local MLdb = {
		selfVote			= db.selfVote or nil,
		multiVote		= db.multiVote or nil,
		anonymousVoting= db.anonymousVoting or nil,
		allowNotes		= db.allowNotes or nil,
		numButtons		= db.buttons.default.numButtons, -- v2.9: Kept as to not break backwards compability on mldb comms. Not used any more
		hideVotes		= db.hideVotes or nil,
		observe			= db.observe or nil,
		buttons			= changedButtons,	-- REVIEW I'm not sure if it's feasible to nil out empty tables
		responses		= changedResponses,
		timeout			= db.timeout,
		rejectTrade 	= db.rejectTrade or nil,
		requireNotes  	= db.requireNotes or nil,
		outOfRaid 		= db.outOfRaid or nil,
	}

	addon:SendMessage("RCMLBuildMLdb", MLdb)
	return MLdb
end

function RCLootCouncilML:NewML(newML)
	addon:DebugLog("ML:NewML", newML)
	if addon:UnitIsUnit(newML, "player") then -- we are the the ML
		addon:SendCommand("group", "playerInfoRequest")
		self:UpdateMLdb() -- Will build and send mldb
		self:UpdateGroup(true)
		self:SendCouncil()
		self:ClearOldItemsInBags()

		if #addon.ItemStorage:GetAllItemsOfType("award_later") > 0 then
			addon:Print(L["new_ml_bagged_items_reminder"])
		end
		self:ScheduleTimer("ItemsInBagsLowTradeTimeRemainingReminder", 5, self) -- Delay a bit as it might not be initialized
	else
		self:Disable() -- We don't want to use this if we're not the ML
	end
end

function RCLootCouncilML:Timer(type, ...)
	if type == "AddItem" then
		self:AddItem(...)

	elseif type == "LootSend" then
		addon:SendCommand("group", "offline_timer")
	end
end

function RCLootCouncilML:OnCommReceived(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncil" then
		-- data is always a table
		local test, command, data = addon:Deserialize(serializedMsg)
		if addon:HandleXRealmComms(self, command, data, sender) then return end

		if test and addon.isMasterLooter then -- only ML receives these commands
			if command == "playerInfo" then
				self:AddCandidate(unpack(data))
				self:SendCandidates()

			elseif command == "MLdb_request" then
				-- Just resend to the entire group instead of the sender
				addon:SendCommand("group", "MLdb", addon.mldb)

			elseif command == "council_request" then
				self:SendCouncil()

			elseif command == "candidates_request" then
				self:SendCandidates()

			elseif command == "reconnect" and not addon:UnitIsUnit(sender, addon.playerName) then -- Don't receive our own reconnect
				-- Someone asks for mldb, council and candidates
				addon:SendCommand(sender, "MLdb", addon.mldb)
				addon:SendCommand(sender, "council", self.council)

			--[[NOTE: For some reason this can silently fail, but adding a 1 sec timer on the rest of the calls seems to fix it
				v2.0.1: 	With huge candidates/lootTable we get AceComm lostdatawarning "First", presumeably due to the 4kb ChatThrottleLib limit.
							Bumping loottable to 4 secs is tested to work with 27 candidates + 10 items.
				v2.2.3: 	Got a ticket where candidates wasn't received. Bumped to 2 sec and added extra checks for candidates.]]

				addon:ScheduleTimer("SendCommand", 2, sender, "candidates", self.candidates)
				if self.running then -- Resend lootTable
					addon:ScheduleTimer("SendCommand", 4, sender, "lootTable", self:GetLootTableForTransmit())
					-- v2.2.6 REVIEW For backwards compability we're just sending votingFrame's lootTable
					-- This is quite redundant and should be removed in the future
					if db.observe or addon:CouncilContains(sender) then -- Only send all data to councilmen
						local table = addon:GetActiveModule("votingframe"):GetLootTable()
						-- Remove our own voting data if any
						for _, v in ipairs(table) do
							v.haveVoted = false
							for _, d in pairs(v.candidates) do
								d.haveVoted = false
							end
						end
						addon:ScheduleTimer("SendCommand", 5, sender, "reconnectData", table)
					end
				end
				addon:Debug("Responded to reconnect from", sender)
			elseif command == "lootTable" and addon:UnitIsUnit(sender, addon.playerName) then
				-- Start a timer to set response as offline/not installed unless we receive an ack
				self:ScheduleTimer("Timer", 11 + 0.5*#self.lootTable, "LootSend")

			elseif command == "tradable" then -- Raid members send the info of the tradable item he looted.
				self:HandleReceivedTradeable(unpack(data), sender)

			elseif command == "trade_complete" then
				self:OnTradeComplete(unpack(data))
			elseif command == "trade_WrongWinner" then
				local link, recipient, trader, winner = unpack(data)
				addon:Print(format(L["trade_wrongwinner_message"], addon.Ambiguate(trader), link, addon.Ambiguate(recipient), addon.Ambiguate(winner)))

			elseif command == "not_tradeable" or command == "rejected_trade" then
				self:HandleNonTradeable(unpack(data), addon:UnitName(sender), command)

			elseif command == "bonus_roll" then
				self:OnBonusRoll(unpack(data))
			end
		else
			addon:Debug("Error in deserializing ML comm: ", command)
		end
	end
end

function RCLootCouncilML:OnBonusRoll (winner, type, link)
	if db.saveBonusRolls then
		self:TrackAndLogLoot(winner, link, "BONUSROLL", addon.bossName)
	end
end

function RCLootCouncilML:OnTradeComplete(link, recipient, trader)
	if db.printCompletedTrades then
		addon:Print(format(L["trade_complete_message"], addon.Ambiguate(trader), link, addon.Ambiguate(recipient)))
	end
end

function RCLootCouncilML:HandleReceivedTradeable (item, sender)
	if not (addon.handleLoot and item and item ~= "") then return end -- Auto fail criterias
	if not GetItemInfo(item) then
		addon:Debug("Tradable item uncached: ", item, sender)
		return self:ScheduleTimer("HandleReceivedTradeable", 1, item, sender)
	end
	sender = addon:UnitName(sender)
	addon:Debug("ML:HandleReceivedTradeable", item, sender)

	-- For ML loot method, ourselve must be excluded because it should be handled in self:LootOpen()
	if not addon:UnitIsUnit(sender, "player") or addon.lootMethod ~= "master" then
		local quality = select(3, GetItemInfo(item))
		local autoAward, mode, winner = self:ShouldAutoAward(item, quality)
		if autoAward then
			self:AutoAward(nil, item, quality, winner, mode, addon.bossName, sender)
			return
		end
		local boe = addon:IsItemBoE(item)
		if	(not boe or (db.autolootOthersBoE and boe)) and -- BoE
			(IsEquippableItem(item) or db.autolootEverything) and -- Safetee: I don't want to check db.autoloot here, because this is actually not a loot.
			not self:IsItemIgnored(item) and -- Item mustn't be ignored
			(quality and quality >= (GetLootThreshold() or 1))  then
				if InCombatLockdown() and not db.skipCombatLockdown then
					addon:Print(format(L["autoloot_others_item_combat"], addon:GetUnitClassColoredName(sender), item))
					tinsert(self.combatQueue, {self.AddUserItem, self, item, sender}) -- Run the function when combat ends
				else
					self:AddUserItem(item, sender)
				end
		end
	end
end

function RCLootCouncilML:HandleNonTradeable(link, owner, reason)
	if not (addon.handleLoot and link and link ~= "") then return end -- Auto fail criterias
	local responseID
	if reason == "not_tradeable" then
		responseID = "PL"
	elseif reason == "rejected_trade" then
		responseID = "PL_REJECT"
	else
		return addon:Debug("Non handled reason in ML:HandleNonTradeable()",link,owner,reason)
	end
	self:TrackAndLogLoot(owner, link, responseID, addon.bossName)
end

function RCLootCouncilML:OnEvent(event, ...)
	addon:DebugLog("ML event", event, ...)
	if event == "CHAT_MSG_WHISPER" and addon.isMasterLooter and db.acceptWhispers then
		local msg, sender = ...
		if msg == "rchelp" then
			self:SendWhisperHelp(sender)
		elseif self.running then
			self:GetItemsFromMessage(msg, sender)
		end

	elseif event == "PLAYER_REGEN_ENABLED" then
		self:ItemsInBagsLowTradeTimeRemainingReminder()
		for _, entry in ipairs(self.combatQueue) do
			entry[1](select(2, unpack(entry)))
		end
		wipe(self.combatQueue)
	end
end

-- called in addon:OnEvent
function RCLootCouncilML:OnLootSlotCleared(slot, link)
	-- REVIEW v2.19.2: Apperantly this is called sometimes without self.lootQueue being initialized - especially in Classic.
	-- Not sure the exact cause - maybe due to looting between :GetML() registers player as ML and ML module being initialized.
	-- For now silently log an error and stack trace and hopefully find the issue in some SV.
	if not self.lootQueue then
		return addon:GetModule("ErrorHandler"):ThrowSilentError("ML.lootQueue nil")
	end

	for i = #self.lootQueue, 1, -1 do -- Check latest loot attempt first
		local v = self.lootQueue[i]
		if v.slot == slot then -- loot success
			self:CancelTimer(v.timer)
			tremove(self.lootQueue, i)
			if (v.callback) then
				v.callback(true, nil, unpack(v.args))
			end
			break
		end
	end
end

--- Awards all items in lootTable to the ML for award later
function RCLootCouncilML:DoAwardLater (lootTable)
	local awardsDone = 0
	for session in ipairs(lootTable) do
		self:Award(session, nil, nil, nil, function()
			-- Ensure all awards are done before ending the session.
			awardsDone = awardsDone + 1
			if awardsDone >= #lootTable then
				RCLootCouncilML:EndSession()
			end
		end)
	end
end

function RCLootCouncilML:CanWeLootItem(item, quality)
	local ret = false
	if item and db.autoLoot and (IsEquippableItem(item) or db.autolootEverything) and
		(quality and quality >= GetLootThreshold())
		and not self:IsItemIgnored(item) then -- it's something we're allowed to loot
		-- Let's check if it's BoE
		ret = db.autolootBoE or not addon:IsItemBoE(item) -- Don't bother checking if we know we want to loot it
	end
	addon:Debug("CanWeLootItem", item, quality, ret)
	return ret
end

-- Do we have free space in our bags to hold this item?
function RCLootCouncilML:HaveFreeSpaceForItem(item)
	local itemFamily = GetItemFamily(item)
	-- If the item is a container, then the itemFamily should be 0
	local equipSlot = select(4, GetItemInfoInstant(item))
	if equipSlot == "INVTYPE_BAG" then
		itemFamily = 0
	end
	-- Get the bag's family
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local freeSlots, bagFamily = addon.C_Container.GetContainerNumFreeSlots(bag)
		if freeSlots and freeSlots > 0 and (bagFamily == 0 or bit.band(itemFamily, bagFamily) > 0) then
			return true
		end
	end
	return false
end

-- Return can we give the loot to the winner
-- Note that it's still possible that GiveMasterLoot fails to be given after this check returns true.
-- Then the reason is most likely the winner's inventory is full.
--@return true we can, false and the cause if not
-- causes:
-- "loot_not_open": No loot windowed is open.
-- "loot_gone": No loot on the slot provided or loot on the slot is not the item provided.
-- "locked": The loot slot is locked for us. We are not eligible to loot this slot.
-- "ml_inventory_full": The winner is ourselves and our inventory is full.
-- "quality_below_threshold": The winner is not ourselve and the quality of the item is below loot threshold.
-- "not_in_group": The winner is not ourselve and not in our group.
-- "offline": The winner is offline.
-- "ml_not_in_instance": ML is not in an instance during a RC session.
-- "out_of_instance": Winner is not in the ML's instance.
-- "not_bop": The winner is not ourselves and the item is not a bop that cannot be looted by the winner.
-- "not_ml_candidate": The winner is not ML and not in ml candidate.
function RCLootCouncilML:CanGiveLoot(slot, item, winner)
	if not addon.lootOpen then
		return false, "loot_not_open"
	elseif not addon.lootSlotInfo[slot] or (not addon:ItemIsItem(addon.lootSlotInfo[slot].link, item)) then
		return false, "loot_gone"
	elseif addon.lootSlotInfo[slot].locked then
		return false, "locked" -- Side Note: When the loot method is master, but ML is ineligible to loot (didn't tag boss/did the boss earlier in the week), WoW gives loot as if it is group loot method.
	elseif addon:UnitIsUnit(winner, "player") and not self:HaveFreeSpaceForItem(addon.lootSlotInfo[slot].link) then
		return false, "ml_inventory_full"
	elseif not addon:UnitIsUnit(winner, "player") then
		if addon.lootSlotInfo[slot].quality < GetLootThreshold() then
			return false, "quality_below_threshold"
		end

		 -- Actually, the unit who leaves our group can still receive loot, as long as he is in the instance group.
		 -- After left group, the unit doesn't leave the instance group until leave instance or gets booted out of instance after 60s grace period expires.
		 -- I just don't want to bother this issue, and it's practical bad to do so,
		 -- as CHAT_LOOT_MSG, which many ML uses to get the loot confirmation, is very likely to be missing after the loot is given to a person out of group.
		 -- I want to give the user more precise reason why the item cant be given.
		local shortName = Ambiguate(winner, "short"):lower()
		if (not UnitInParty(shortName)) and (not UnitInRaid(shortName)) then
			return false, "not_in_group"
		end
		if not UnitIsConnected(shortName) then
			return false, "offline"
		end

		local found = false
		for i = 1, _G.MAX_RAID_MEMBERS do
			if addon:UnitIsUnit(GetMasterLootCandidate(slot, i), winner) then
				found = true
				break
			end
		end

		if not IsInInstance() then
		   return false, "ml_not_in_instance" -- ML leaves the instance during a RC session.
		end

		if select(4, UnitPosition(Ambiguate(winner, "short"))) ~= select(4, UnitPosition("player")) then
		  return false, "out_of_instance" -- Winner not in the same instance as ML
		end

		local bindType = select(14, GetItemInfo(item))

		if not found then
			if bindType ~= LE_ITEM_BIND_ON_ACQUIRE then
				return false, "not_bop"
			else
				return false, "not_ml_candidate"
			end
		end
	end
	return true
end

local function OnGiveLootTimeout(entryInQueue)
	for k, v in pairs(RCLootCouncilML.lootQueue) do -- remove entry from the loot queue.
		if v == entryInQueue then
			tremove(RCLootCouncilML.lootQueue, k)
		end
	end
	if entryInQueue.callback then
		entryInQueue.callback(false, "timeout", unpack(entryInQueue.args)) -- loot attempt fails
	end
end

-- Attempt to give loot to winner.
-- This function does not check loot eligibility. Use CanGiveLoot for that.
-- This function always call callback function, with the maximum delay of LOOT_TIMEOUT,
-- as callback(awarded, cause, ...), if callback is provided.
-- Currently, "cause" is always nil when award success (awarded == true) and "timeout" when awarded failed (awarded == false)
--@param slot the loot slot
--@param winner The name of the candidate who we want to give the item to
--@param callback The callback function that do stuff when this loot attempt success/fail
--@param ... The additional arguments provided to the callback.
--@return nil
function RCLootCouncilML:GiveLoot(slot, winner, callback, ...)
	if addon.lootOpen then

		local entryInQueue = {slot = slot, callback = callback, args = {...}, }
		entryInQueue.timer = self:ScheduleTimer(OnGiveLootTimeout, LOOT_TIMEOUT, entryInQueue)
		tinsert(self.lootQueue, entryInQueue)

		for i = 1, _G.MAX_RAID_MEMBERS do
			if addon:UnitIsUnit(GetMasterLootCandidate(slot, i), winner) then
				addon:Debug("GiveMasterLoot", slot, i)
				GiveMasterLoot(slot, i)
				break
			end
		end
	end
end

function RCLootCouncilML:UpdateLootSlots()
	if not addon.lootOpen then return addon:Debug("ML:UpdateLootSlots() without loot window open!!") end
	local updatedLootSlot = {}
	for i = 1, GetNumLootItems() do
		local item = GetLootSlotLink(i)
		for session = 1, #self.lootTable do
			-- Just skip if we've already awarded the item or found a fitting lootSlot
			if not self.lootTable[session].awarded and not updatedLootSlot[session] then
				if addon:ItemIsItem(item, self.lootTable[session].link) then
					if i ~= self.lootTable[session].lootSlot then -- It has changed!
						addon:DebugLog("lootSlot @session", session, "Was at:",self.lootTable[session].lootSlot, "is now at:", i)
					end
					self.lootTable[session].lootSlot = i -- update it
					updatedLootSlot[session] = true
					break
				end
			end
		end
	end
end

function RCLootCouncilML:PrintLootErrorMsg(cause, slot, item, winner)
	addon:Debug("ML:PrintLootErrorMsg", cause, slot, item, winner)
	if cause == "loot_not_open" then
		addon:Print(L["Unable to give out loot without the loot window open."])
	elseif cause == "timeout" then
		addon:Print(format(L["Timeout when giving 'item' to 'player'"], item, addon:GetUnitClassColoredName(winner)), " - ", _G.ERR_INV_FULL) -- "Inventory is full."
	elseif cause == "locked" then
		addon:SessionError("No permission to loot the item at slot "..slot)
	else
		local prefix = format(L["Unable to give 'item' to 'player'"], item, addon:GetUnitClassColoredName(winner)).."  - "
		if cause == "loot_gone" then
			addon:Print(prefix, _G.LOOT_GONE) -- "Item already looted."
		elseif cause == "ml_inventory_full" then
			addon:Print(prefix, _G.ERR_INV_FULL) -- "Inventory is full."
		elseif cause == "quality_below_threshold" then
			addon:Print(prefix, L["Item quality is below the loot threshold"])
		elseif cause == "not_in_group" then
			addon:Print(prefix, L["Player is not in the group"])
		elseif cause == "offline" then
			addon:Print(prefix, L["Player is offline"])
		elseif cause == "ml_not_in_instance" then
			addon:Print(prefix, L["You are not in an instance"])
		elseif cause == "out_of_instance" then
			addon:Print(prefix, L["Player is not in this instance"])
		elseif cause == "not_ml_candidate" then
			addon:Print(prefix, L["Player is ineligible for this item"])
		elseif cause == "not_bop" then
			addon:Print(prefix, L["The item can only be looted by you but it is not bind on pick up"])
		else
			addon:Print(prefix) -- should not happen if programming is correct
		end
	end
end

-- Status can be one of the following:
-- test_mode, normal, manually_added, indirect,
-- See :Award() for the different scenarios
local function awardSuccess(session, winner, status, callback, responseText, ...)
	addon:DebugLog("ML:awardSuccess", session, winner, status, callback, responseText, ...)
	addon:SendMessage("RCMLAwardSuccess", session, winner, status, RCLootCouncilML.lootTable[session].link, responseText)
	if callback then
		callback(true, session, winner, status, ...)
	end
	return true
end

-- Status can be one of the following:
-- award later success: bagged, manually_bagged,
-- normal error: bagging_awarded_item, loot_not_open, loot_gone, locked, ml_inventory_full, quality_below_threshold
-- , not_in_group, offline, not_ml_candidate, timeout, test_mode, bagging_bagged, ml_not_in_instance, out_of_instance
-- Status when the addon is bugged(should not happen): unlooted_in_bag
-- See :Award() and :CanGiveLoot() for the different scenarios and to get their meanings
local function awardFailed(session, winner, status, callback, responseText, ...)
	addon:DebugLog("ML:awardFailed", session, winner, status, callback, responseText, ...)
	addon:SendMessage("RCMLAwardFailed", session, winner, status, RCLootCouncilML.lootTable[session].link, responseText)
	if callback then
		callback(false, session, winner, status, ...)
	end
	return false
end

-- Run this after awardSuccess so callback can do stuff to announcement.
local function registerAndAnnounceAward(session, winner, response, reason)
	local self = RCLootCouncilML
	local changeAward = self.lootTable[session].awarded
	self.lootTable[session].awarded = winner
	if self.lootTable[session].bagged then
		self.lootTable[session].bagged.type = "to_trade"
	end
	addon:SendCommand("group", "awarded", session, winner, self.lootTable[session].owner)

	self:AnnounceAward(winner, self.lootTable[session].link,
			reason and reason.text or response, addon:GetActiveModule("votingframe"):GetCandidateData(session, winner, "roll"), session, changeAward)
	if self:HasAllItemsBeenAwarded() then
		addon:Print(L["All items have been awarded and the loot session concluded"])
		self:ScheduleTimer("EndSession", 1)  -- Delay a bit to ensure callback is handled before session ends.
	end
	return true
end

local function registerAndAnnounceBagged(session)
	local self = RCLootCouncilML
	local Item = addon.ItemStorage:New(self.lootTable[session].link, "award_later", {
		bop = addon:IsItemBoP(self.lootTable[session].link),
		boss = self.lootTable[session].boss
	}):Store()
	if not Item.inBags then -- It wasn't found!
		-- We don't care about onFound, as all we need is to record the time_remaining
		addon.ItemStorage:WatchForItemInBags(Item, nil, function(Item)
			addon:DebugLog(format("<ERROR> Award Later item %s was never found in bags!", Item.link))
		end, 5)
	end
	if self.lootTable[session].lootSlot or self.running then -- Item is looted by ML, announce it.
															-- Also announce if the item is awarded later in voting frame.
		self:AnnounceAward(L["The loot master"], self.lootTable[session].link, L["Store in bag and award later"], nil, session)
	else
		addon:Print(format(L["'Item' is added to the award later list."], self.lootTable[session].link))
	end
	self.lootTable[session].lootSlot = nil  -- Now the item is bagged and no longer in the loot window.
	self.lootTable[session].bagged = Item
	if self.running then -- Award later can be done when actually loot session hasn't been started yet.
		self.lootTable[session].baggedInSession = true -- REVIEW This variable is never used?
		addon:SendCommand("group", "bagged", session, addon.playerName)
	end
	return false
end

--@param session	The session to award.
--@param winner	Nil/false if items should be stored in inventory and awarded later.
--@param response	The candidates response, used for announcement.
--@param reason	Entry in db.awardReasons.
--@param callback This function will be called as callback(awarded, session, winner, status, ...)
--@returns true if award is success. false if award is failed. nil if we don't know the result yet.
function RCLootCouncilML:Award(session, winner, response, reason, callback, ...) -- Note: MAKE SURE callbacks is always called eventually in any case, or there is bug.
	addon:DebugLog("ML:Award", session, winner, response, reason)
	local args = {...} --  "..."(Three dots) cant be used in an inner function, use unpack(args) instead.

	local responseText = reason and reason.text or response

	if not self.lootTable or #self.lootTable == 0 then -- Our session probably ended, check the old loot table
		if self.oldLootTable and #self.oldLootTable > 0 then
			-- Restore it, and assume we want to reaward something
			self.lootTable = self.oldLootTable
		else
			-- We have neither lootTable nor oldLootTable - that shouldn't happen!
			addon:Debug("ML:Award <ERROR> - Neither lootTable nor oldLootTable!")
			return false
		end
	end

	if self.lootTable[session].lootSlot and self.lootTable[session].bagged then -- For debugging purpose, addon bug if this happens, such values never exist at any time.
		awardFailed(session, winner, "unlooted_in_bag", callback, responseText, ...)
		addon:SessionError("Session "..session.." has unlooted item in the bag!?")
		return false
	end

	if self.lootTable[session].bagged and not winner then  -- We should also check this in voting frame, but this check is needed due to comm delay between ML and voting frame.
		awardFailed(session, nil, "bagging_bagged", callback, responseText, ...)
		addon:Print(L["Items stored in the loot master's bag for award later cannot be awarded later."])
		return false
	end

	if self.lootTable[session].awarded and not winner then -- We should also check this in voting frame, but this check is needed due to comm delay between ML and voting frame.
		awardFailed(session, nil, "bagging_awarded_item", callback, responseText, ...)
		addon:Print(L["Awarded item cannot be awarded later."])
		return false
	end

	-- already awarded. Change award
	if self.lootTable[session].awarded then
		registerAndAnnounceAward(session, winner, response, reason)
		if not self.lootTable[session].lootSlot and not self.lootTable[session].bagged then -- "/rc add" or test mode
			awardSuccess(session, winner, addon.testMode and "test_mode" or "manually_added", callback, responseText, ...)
		elseif self.lootTable[session].bagged then
			awardSuccess(session, winner, "indirect", callback, responseText, ...)
		else
			awardSuccess(session, winner, "normal", callback, responseText, ...)
		end
		return true
	end

	-- For the rest, the item is not awarded.
	if not self.lootTable[session].lootSlot and not self.lootTable[session].bagged then -- "/rc add" or test mode. Note that "/rc add" does't add the item to ItemStorage unless award later is checked.
		if winner then
			awardSuccess(session, winner, addon.testMode and "test_mode" or "manually_added", callback, responseText, ...)
			registerAndAnnounceAward(session, winner, response, reason)
			return true
		else
			if addon.testMode then
				awardFailed(session, nil, "test_mode", callback, responseText, ...)
				addon:Print(L["Award later isn't supported when testing."])
				return false
			else -- Award later optioned is checked in "/rc add", put in ML's bag.
				registerAndAnnounceBagged(session)
				awardFailed(session, nil, "manually_bagged", callback, responseText, ...)
				return false
			end
		end
	end

	if self.lootTable[session].bagged then  -- indirect mode (the item is in a bag)
		-- Add to the list of awarded items in MLs bags,
		registerAndAnnounceAward(session, winner, response, reason)
		awardSuccess(session, winner, "indirect", callback, responseText, ...)
		return true
	end

	-- The rest is direct mode (item is in WoW loot window)

	-- v2.4.4+: Check if the item is still in the expected slot
	if addon.lootOpen and not addon:ItemIsItem(self.lootTable[session].link, GetLootSlotLink(self.lootTable[session].lootSlot)) then
		addon:Debug("LootSlot has changed before award!", session)
		-- And update them if not
		self:UpdateLootSlots()
	end

	local canGiveLoot, cause = self:CanGiveLoot(self.lootTable[session].lootSlot, self.lootTable[session].link, winner or addon.playerName) -- if winner is nil, give the loot to the ML for award later.

	if not canGiveLoot then
		if cause == "quality_below_threshold" or cause == "not_bop" then
			self:PrintLootErrorMsg(cause, self.lootTable[session].lootSlot, self.lootTable[session].link, winner or addon.playerName)
			addon:Print(L["Gave the item to you for distribution."])
			return self:Award(session, nil, response, reason, callback, ...) -- cant give the item to other people, award later.
		else
			awardFailed(session, winner, cause, callback, responseText, ...)
			self:PrintLootErrorMsg(cause, self.lootTable[session].lootSlot, self.lootTable[session].link, winner or addon.playerName)
			return false
		end
	else
		if winner then -- award the item now
			-- Attempt to give loot
			self:GiveLoot(self.lootTable[session].lootSlot, winner, function(awarded, cause)
				if awarded then
					registerAndAnnounceAward(session, winner, response, reason)
					awardSuccess(session, winner, "normal", callback, responseText, unpack(args))
					return true
				else
					awardFailed(session, winner, cause, callback, responseText, unpack(args))
					self:PrintLootErrorMsg(cause, self.lootTable[session].lootSlot, self.lootTable[session].link, winner)
					return false
				end
			end)
		else -- Store in our bags and award later
			self:GiveLoot(self.lootTable[session].lootSlot, addon.playerName, function(awarded, cause)
				if awarded then
					registerAndAnnounceBagged(session)
					awardFailed(session, nil, "bagged", callback, responseText, unpack(args)) -- Item hasn't been awarded
				else
					awardFailed(session, nil, cause, callback, responseText, unpack(args))
					self:PrintLootErrorMsg(cause, self.lootTable[session].lootSlot, self.lootTable[session].link, addon.playerName)
				end
				return false
			end)
		end
	end
end

--- Substitution strings for AnnounceItems
-- Each keyword will be replaced with the func result if it's used in db.announceItemString
-- The function receives session, itemlink, lootTable[session] as arguments
RCLootCouncilML.announceItemStrings = {
	["&s"] = function(ses) return ses end,
	["&i"] = function(...) return select(2,...) end,
	["&l"] = function(_, item)
		local t = RCLootCouncilML:GetItemInfo(item)
		return t and addon:GetItemLevelText(t.ilvl, t.token) or "" end,
	["&t"] = function(_, item)
		local t = RCLootCouncilML:GetItemInfo(item)
		return t and addon:GetItemTypeText(t.link, t.subType, t.equipLoc, t.typeID, t.subtypeID, t.classes, t.token, t.relic) or "" end,
	["&o"] = function(_,_,v) return v.owner and addon.Ambiguate(v.owner) or "" end,
}
-- The description for each keyword
RCLootCouncilML.announceItemStringsDesc = {
	L["announce_&s_desc"],
	L["announce_&i_desc"],
	L["announce_&l_desc"],
	L["announce_&t_desc"],
	L["announce_&o_desc"],
}

--@param: table: Table. The lootTable or the reroll table.
function RCLootCouncilML:AnnounceItems(table)
	if not db.announceItems then return end
	addon:DebugLog("ML:AnnounceItems()")
	addon:SendAnnouncement(db.announceText, db.announceChannel)
	for k,v in ipairs(table) do
		local msg = db.announceItemString
		for text, func in pairs(self.announceItemStrings) do
			-- escapePatternSymbols is defined in FrameXML/ChatFrame.lua that escapes special characters.
			msg = gsub(msg, text, escapePatternSymbols(tostring(func(v.session or k, v.link, v))))
		end
		if v.isRoll then
			msg = _G.ROLL..": "..msg
		end
		addon:SendAnnouncement(msg, db.announceChannel)
	end
end

--- Substitution strings for the awardString
-- Each index corrosponds to a keyword in the award string.
-- If it exists, the function will be called with all the parameters from :AnnounceAward
RCLootCouncilML.awardStrings = {
	["&s"] = function(_, _, _, _, session) return session or "" end,
	["&p"] = function(name) return addon.Ambiguate(name) end,
	["&i"] = function(...) return select(2, ...) end,
	["&r"] = function(...) return select(3, ...) or "" end,
	["&n"] = function(...) return select(4, ...) or "" end,
	["&l"] = function(_, item)
		local t = RCLootCouncilML:GetItemInfo(item)
		return t and addon:GetItemLevelText(t.ilvl, t.token) or "" end,
	["&t"] = function(_, item)
		local t = RCLootCouncilML:GetItemInfo(item)
		return t and addon:GetItemTypeText(t.link, t.subType, t.equipLoc, t.typeID, t.subTypeID, t.classes, t.token, t.relic) or "" end,
	["&o"] = function(...)
		local session = select(5, ...)
		local owner = select(6, ...) or RCLootCouncilML.lootTable[session] and  RCLootCouncilML.lootTable[session].owner
		return owner and addon.Ambiguate(owner) or _G.UNKNOWN end,
	["&m"] = function(...) return addon:GetActiveModule("votingframe"):GetCandidateData(select(5,...), select(1,...), "note") or "<none>" end,
}

-- The description for each keyword
RCLootCouncilML.awardStringsDesc = {
	L["announce_&s_desc"],
	L["announce_&p_desc"],
	L["announce_&i_desc"],
	L["announce_&r_desc"],
	L["announce_&n_desc"],
	L["announce_&l_desc"],
	L["announce_&t_desc"],
	L["announce_&o_desc"],
	L["announce_&m_desc"],
}


-- See above for text substitutions
-- @paramsig 			name, link, text [,roll, session]
-- @param name 		The unambiguated name of the winner
-- @param link 		The itemlink of the awarded item
-- @param response	The text matching the candidate's response
-- @param roll 		The candidates' roll
-- @param session		The session of the awarded item
-- @param changeAward Indicate whether this is a change to award instead of a new award. If it is, prefix the message by "Change Award"
-- @param owner 		Owner of the item, used if not available in lootTable, i.e. on autoAwards
function RCLootCouncilML:AnnounceAward(name, link, response, roll, session, changeAward, owner)
	if db.announceAward then
		for _,v in pairs(db.awardText) do
			local message = v.text
			for text, func in pairs(self.awardStrings) do
				-- escapePatternSymbols is defined in FrameXML/ChatFrame.lua that escapes special characters.
				message = gsub(message, text, escapePatternSymbols(tostring(func(name, link, response, roll, session, owner))))
			end
			if changeAward then
				message = "("..L["Change Award"]..") "..message
			end
			addon:SendAnnouncement(message, v.channel)
		end
	end
end

--- Determines if a given item should be auto awarded.
-- Assumes item is loaded.
-- Will fail if the selected auto award candidate is not present in group.
-- @param item: The item to check.
-- @param quality: Number Item quality.
-- @return shouldAutoAward[, mode, winner]
--		shouldAutoAward bool: Whether item should be autoawarded
--		mode string: AutoAward mode ("boe" or "normal")
--		winner string: The candidate that should receive the auto award.
function RCLootCouncilML:ShouldAutoAward(item, quality)
	if not item then return false end
	local _, _, _, _, _, itemClassID = GetItemInfoInstant(item)
	if itemClassID == 1 then return false end -- Ignore containers

	local boe = addon:IsItemBoE(item)
	if boe and db.autoAwardBoE and quality == 4 and IsEquippableItem(item) then -- Epic Equippable BoE
		for name in pairs(self.candidates) do
			if addon:UnitIsUnit(name, db.autoAwardBoETo) then
				return true, "boe", db.autoAwardBoETo
			end
		end
		-- Unit not in group
		addon:Print(L["Cannot autoaward:"])
		addon:Print(format(L["Could not find 'player' in the group."], db.autoAwardBoETo))
		return false
	end
	if db.autoAward and quality >= db.autoAwardLowerThreshold and quality <= db.autoAwardUpperThreshold
		and IsEquippableItem(item) then
		if db.autoAwardLowerThreshold >= GetLootThreshold() or db.autoAwardLowerThreshold < 2 then
			if UnitInRaid(db.autoAwardTo) or UnitInParty(db.autoAwardTo) then -- TEST perhaps use self.group?
				return true, "normal", db.autoAwardTo
			else
				addon:Print(L["Cannot autoaward:"])
				addon:Print(format(L["Could not find 'player' in the group."], db.autoAwardTo))
			end
		else
			addon:Print(format(L["Could not Auto Award i because the Loot Threshold is too high!"], item))
		end
	end
	return false
end

--- Auto award an item to a player.
-- Item isn't in the lootTable at this point!
-- @param mode: The mode as returned by `:ShouldAutoAward`. Defaults to "normal".
function RCLootCouncilML:AutoAward(lootIndex, item, quality, name, mode, boss, owner)
	name = addon:UnitName(name)
	addon:DebugLog("ML:AutoAward", lootIndex, item, quality, name, mode, boss, owner)
	local reason = mode == "boe" and db.autoAwardBoEReason or db.autoAwardReason

	if addon.lootMethod == "personalloot" then -- Normal restrictions doesn't apply here
		addon:Print(format(L["Auto awarded 'item'"], item))
		addon:SendCommand("group", "do_trade", owner, item, name)
		self:AnnounceAward(name, item, db.awardReasons[reason].text, nil, nil, nil, owner)
		self:TrackAndLogLoot(name, item, reason, boss, db.awardReasons[reason],nil,nil, owner)
		return true
	end

	if db.autoAwardLowerThreshold < 2 and quality < 2 and not addon:UnitIsUnit(name, "player") then
		local qualityText = _G.ITEM_QUALITY_COLORS[2].hex .. _G.ITEM_QUALITY2_DESC .. "|r"
		addon:Print(format(L["You can only auto award items with a quality lower than 'quality' to yourself due to Blizaard restrictions"], qualityText))
		return false
	end

	local canGiveLoot, cause = self:CanGiveLoot(lootIndex, item, name)

	if not canGiveLoot then
		addon:Print(L["Cannot autoaward:"])
		self:PrintLootErrorMsg(cause, lootIndex, item, name)
		return false
	else
		self:GiveLoot(lootIndex, name, function(awarded, cause)
			if awarded then
				addon:Print(format(L["Auto awarded 'item'"], item))
				self:AnnounceAward(name, item, db.awardReasons[reason].text)
				self:TrackAndLogLoot(name, item, reason, boss, db.awardReasons[reason])
				return true
			else
				addon:Print(L["Cannot autoaward:"])
				self:PrintLootErrorMsg(cause, lootIndex, item, name)
				return false
			end
		end)
		return true
	end
end

local history_table = {}
local historyCounter = 0 -- Used to generate history table entry unique id
-- REVIEW Updated with recent changes in v2.9+.
-- This should be refactored in v3.0 as several of the sources are no longer viable, and were ment to be used with ML.
-- v2.19.0: Boss is included in lootTable, but kept as arg for backwards compatibility.
function RCLootCouncilML:TrackAndLogLoot(winner, link, responseID, boss, reason, session, candData, owner)
	if reason and not reason.log then return end -- Reason says don't log
	if not (db.sendHistory or db.enableHistory) then return end -- No reason to do stuff when we won't use it
	if addon.testMode and not addon.nnp then return end -- We shouldn't track testing awards.
	local equipLoc = self.lootTable[session] and self.lootTable[session].equipLoc or "default"
	local typeCode = self.lootTable[session] and self.lootTable[session].typeCode
	local response = addon:GetResponse(typeCode or equipLoc, responseID)
	local instanceName, _, difficultyID, difficultyName, _,_,_,mapID, groupSize = GetInstanceInfo()
	-- Check if the item has a specific boss associated
	if self.lootTable[session] and self.lootTable[session].bagged and self.lootTable[session].bagged.args.boss then
		boss = self.lootTable[session].bagged.args.boss
	elseif self.lootTable[session] and self.lootTable[session].boss then
		boss = self.lootTable[session].boss
	end
	addon:Debug("ML:TrackAndLogLoot()", winner, link, responseID, boss, reason, session, candData)
	history_table["lootWon"] 		= link
	history_table["date"] 			= date("%d/%m/%y")
	history_table["time"] 			= date("%H:%M:%S")
	history_table["instance"] 		= instanceName.."-"..difficultyName
	history_table["boss"] 			= boss or _G.UNKNOWN
	history_table["votes"] 			= candData and candData.votes
	history_table["itemReplaced1"]= (candData and candData.gear1) and select(2,GetItemInfo(candData.gear1))
	history_table["itemReplaced2"]= (candData and candData.gear2) and select(2,GetItemInfo(candData.gear2))
	history_table["response"] 		= reason and reason.text or response.text
	history_table["responseID"] 	= reason and reason.sort - 400 or responseID 										-- Changed in v2.0 (reason responseID was 0 pre v2.0)
	history_table["color"]			= reason and reason.color or response.color											-- New in v2.0
	history_table["class"]			= self.candidates[winner].class															-- New in v2.0
	history_table["isAwardReason"]= reason and true or false																	-- New in v2.0
	history_table["difficultyID"]	= difficultyID																					-- New in v2.3+
	history_table["mapID"]			= mapID																							-- New in v2.3+
	history_table["groupSize"]		= groupSize																						-- New in v2.3+
--	history_table["tierToken"]		= isToken																						-- New in v2.3+ - Removed v2.9
--	history_table["tokenRoll"]		= tokenRoll																						-- New in v2.4+ - Removed v2.9
--	history_table["relicRoll"]		= relicRoll																						-- New in v2.5+ - Removed v2.9
	history_table["note"]			= candData and candData.note																-- New in v2.7+
	history_table["id"]				= time(date("!*t")).."-"..historyCounter												-- New in v2.7+. A unique id for the history entry.
	history_table["owner"]			= owner or self.lootTable[session] and self.lootTable[session].owner or winner		-- New in v2.9+.
	history_table["typeCode"]			= self.lootTable[session] and self.lootTable[session].typeCode		-- New in v2.15+.

	historyCounter = historyCounter + 1

	addon:SendMessage("RCMLLootHistorySend", history_table, winner, responseID, boss, reason, session, candData)

	if db.sendHistory then -- Send it, and let comms handle the logging
		addon:SendCommand(db.sendHistoryToGuildChannel and "guild" or "group", "history", winner, history_table)
	elseif db.enableHistory then -- Just log it
		addon:SendCommand("player", "history", winner, history_table)
	end
	local toRet = history_table
	history_table = {} -- wipe to ensure integrety
	return toRet
end

-- Remove an entry in the history table
--@param name: The candidate name
--@param id: The unique id of history table
function RCLootCouncilML:UnTrackAndLogLoot(id)
	if db.sendHistory then -- Send it, and let comms handle the logging
		addon:SendCommand(db.sendHistoryToGuildChannel and "guild" or "group", "delete_history", id)
	elseif db.enableHistory then -- Just log it
		addon:SendCommand("player", "delete_history", id)
	end
end

function RCLootCouncilML:HasAllItemsBeenAwarded()
	local moreItems = true
	for i = 1, #self.lootTable do
		if not self.lootTable[i].awarded then
			moreItems = false
		end
	end
	return moreItems
end

function RCLootCouncilML:EndSession()
	addon:DebugLog("ML:EndSession()")
	self.oldLootTable = self.lootTable
	self.lootTable = {}
	addon:SendCommand("group", "session_end")
	self.running = false
	self:CancelAllTimers()
	if addon.testMode then -- We need to undo our ML status
		addon.testMode = false
		addon:ScheduleTimer("NewMLCheck", 1) -- Delay it a bit
	end
	addon.testMode = false
end

-- Initiates a session with the items handed
function RCLootCouncilML:Test(items)
	-- check if we're added in self.group
	-- (We might not be on solo test)
	if not tContains(self.candidates, addon.playerName) then
		self:AddCandidate(addon.playerName, addon.playerClass, addon:GetPlayerRole(), addon.guildRank)
	end
	-- We must send candidates now, since we can't wait the normal 10 secs
	addon:SendCommand("group", "candidates", self.candidates)
	-- Add the items
	for _, iName in ipairs(items) do
		self:AddItem(iName)
	end
	if db.autoStart then
		addon:Print(L["Autostart isn't supported when testing"])
	end
	addon:CallModule("sessionframe")
	addon:GetActiveModule("sessionframe"):Show(self.lootTable)
end

-- Returns true if we are ignoring the item
function RCLootCouncilML:IsItemIgnored(link)
	local itemID = addon:GetItemIDFromLink(link) -- extract itemID
	return itemID and db.ignoredItems[itemID]
end

--- Fetches the council members from the current group.
-- Used by the ML to only send out a council consisting of actual group members.
-- That council is stored in RCLootCouncil.council
-- @return table [i] = "council_man_name".
function RCLootCouncilML:GetCouncilInGroup()
	local council = {}
	for _, name in ipairs(addon.db.profile.council) do
		-- self.candidates suffers from the problem mentioned in :UnitName, so safely (slowly) compare them
		for cand in pairs(self.candidates) do
			if addon:UnitIsUnit(name, cand ) then
				tinsert(council, name)
				break
			end
		end
	end
	if not tContains(council, addon.playerName) then -- Check if the ML (us) is included
		tinsert(council, addon.playerName)
	end
	addon:DebugLog("GetCouncilInGroup", unpack(council))
	return council
end

-- @param retryCount: How many times we have retried to execute this function.
function RCLootCouncilML:GetItemsFromMessage(msg, sender, retryCount)
	local MAX_RETRY = 5

	if not retryCount then retryCount = 0 end
	addon:Debug("GetItemsFromMessage()", msg, sender, retryCount)
	if not addon.isMasterLooter then return end

	local ses, arg1, arg2, arg3 = addon:GetArgs(msg, 4) -- We only require session to be correct and arg1 exists, we can do some error checking on the rest
	ses = tonumber(ses)
	-- Let's test the input
	if not ses or type(ses) ~= "number" or ses > #self.lootTable then return end -- We need a valid session
	if not arg1 then return end -- No response or item link

	-- Set some locals
	local item1, item2, diff
	local response = 1
	if arg1:find("|Hitem:") then -- they didn't give a response
		item1, item2 = arg1, arg2
	else
		-- No reason to continue if they didn't provide an item
		if not arg2 or not arg2:find("|Hitem:") then return end
		item1, item2 = arg2, arg3

		local whisperKeys = {}
		for k, v in pairs(db.buttons.default) do
			if k ~= "numButtons" then
				gsub(v.whisperKey, '[%w]+', function(x) tinsert(whisperKeys, {key = x, num = k}) end) -- extract the whisperKeys to a table
			end
		end

		for _,v in ipairs(whisperKeys) do
			if strmatch(arg1, v.key) then -- if we found a match
				response = v.num
				break;
			end
		end
	end

	local ilvl = self.lootTable[ses].ilvl
	local g1 = item1
	local g2 = item2

	local itemNeedCaching = false
	local g1diff, g2diff = g1 and select(4, GetItemInfo(g1)), g2 and select(4, GetItemInfo(g2))
	if g1diff and g2diff then
		diff = g1diff >= g2diff and ilvl - g2diff or ilvl - g1diff
	elseif g1 and g2 then
		itemNeedCaching = true
	elseif g1diff then
		diff = ilvl - g1diff
	elseif g1 then
		itemNeedCaching = true
	end

	if itemNeedCaching and retryCount < MAX_RETRY then -- Limit retryCount to avoid infinite loop. User can send invalid link that can never be cached.
		return self:ScheduleTimer("GetItemsFromMessage", 1, msg, sender, retryCount + 1)
	end

	local toSend = {
		gear1 = item1,
		gear2 = item2,
		ilvl = nil,
		diff = diff,
		note = L["Auto extracted from whisper"],
		response = response,
	}

	local count = 0
	local link = self.lootTable[ses].link
	-- Send Responses to all duplicate items.
	for s, v in ipairs(self.lootTable) do
		if addon:ItemIsItem(v.link, link) then
			addon:SendCommand("group", "response", s, sender, toSend)
			count = count + 1
		end
	end

	local typeCode = self.lootTable[ses].typeCode or self.lootTable[ses].equipLoc

	-- Let people know we've done stuff
	addon:Print(format(L["Item received and added from 'player'"], addon.Ambiguate(sender)))
	SendChatMessage("[RCLootCouncil]: "..format(L["Response to 'item' acknowledged as 'response'"],
		addon:GetItemTextWithCount(link, count), addon:GetResponse(typeCode, response).text), "WHISPER", nil, sender)
end

function RCLootCouncilML:SendWhisperHelp(target)
	addon:DebugLog("SendWhisperHelp", target)
	local msg
	local guide1 = L["whisper_guide"]
	if #guide1 > 254 then -- French locale reported too long
		SendChatMessage(strsub(guide1, 0, 254), "WHISPER", nil, target)
		SendChatMessage(strsub(guide1, 255), "WHISPER", nil, target)
	else
		SendChatMessage(guide1, "WHISPER", nil, target)
	end

	for i = 1, db.buttons.default.numButtons do
		msg = "[RCLootCouncil]: "..db.buttons.default[i]["text"]..":  " -- i.e. MainSpec/Need:
		msg = msg..""..db.buttons.default[i]["whisperKey"].."." -- need, mainspec, etc
		SendChatMessage(msg, "WHISPER", nil, target)
	end
	SendChatMessage(L["whisper_guide2"], "WHISPER", nil, target)
	addon:Print(format(L["Sent whisper help to 'player'"], addon.Ambiguate(target)))
end

--- Award popup control functions
-- Provided for easy hook access
--	data contains: session, winner, responseID, reason, votes, gear1, gear2, isTierRoll, isRelicRoll, link, isToken
function RCLootCouncilML.AwardPopupOnShow(frame, data)
	frame:SetFrameStrata("FULLSCREEN")
	frame.text:SetText(format(L["Are you sure you want to give #item to #player?"], data.link, addon.Ambiguate(data.winner)))
	frame.icon:SetTexture(data.texture)
end

function RCLootCouncilML.AwardPopupOnClickYesCallback(awarded, session, winner, status, data, callback, ...)
	if callback and type(callback) == "function" then
		callback(awarded, session, winner, status, data, ...)
	end
	if awarded then -- log it
		local oldHistory = RCLootCouncilML.lootTable[session].history
		if oldHistory and oldHistory.id then -- Reaward, clear the old history entry
			RCLootCouncilML:UnTrackAndLogLoot(oldHistory.id)
		end
		RCLootCouncilML.lootTable[session].history = RCLootCouncilML:TrackAndLogLoot(data.winner, data.link, data.responseID, data.boss, data.reason, session, data)
	end
end

-- Argument to callback: awarded, session, winner, status, data, ...
-- If you want to add a button to the rightclick menu which does award, use this function, the callback function is your custom function to do stuff after award is done.
function RCLootCouncilML.AwardPopupOnClickYes(frame, data, callback, ...)
	RCLootCouncilML:Award(data.session, data.winner, data.responseID and addon:GetResponse(data.typeCode or data.equipLoc, data.responseID).text, data.reason,
		RCLootCouncilML.AwardPopupOnClickYesCallback, data, callback, ...)

	-- We need to delay the test mode disabling so comms have a chance to be send first!
	if addon.testMode and RCLootCouncilML:HasAllItemsBeenAwarded() then RCLootCouncilML:EndSession() end
	--return awarded -- Doesn't work, as LibDialog only hides the dialog if we return false/nil
end

function RCLootCouncilML.AwardPopupOnClickNo(frame, data)
	-- Intentionally left empty
end


-- TRANSFORMED to 'EQUIPLOC_SORT_ORDER["INVTYPE"] = num', below
RCLootCouncilML.EQUIPLOC_SORT_ORDER = {
	-- From head to feet
	"INVTYPE_HEAD",
	"INVTYPE_NECK",
	"INVTYPE_SHOULDER",
	"INVTYPE_CLOAK",
	"INVTYPE_ROBE",
	"INVTYPE_CHEST",
	"INVTYPE_WRIST",
	"INVTYPE_HAND",
	"INVTYPE_WAIST",
	"INVTYPE_LEGS",
	"INVTYPE_FEET",
	"INVTYPE_FINGER",
	"INVTYPE_TRINKET",
	"",               -- armor tokens, artifact relics
	"INVTYPE_RELIC",

	"INVTYPE_QUIVER",
	"INVTYPE_RANGED",
	"INVTYPE_RANGEDRIGHT",
	"INVTYPE_THROWN",

	"INVTYPE_2HWEAPON",
	"INVTYPE_WEAPON",
	"INVTYPE_WEAPONMAINHAND",
	"INVTYPE_WEAPONMAINHAND_PET",

	"INVTYPE_WEAPONOFFHAND",
	"INVTYPE_HOLDABLE",
	"INVTYPE_SHIELD",
}
RCLootCouncilML.EQUIPLOC_SORT_ORDER = tInvert(RCLootCouncilML.EQUIPLOC_SORT_ORDER)
RCLootCouncilML.EQUIPLOC_SORT_ORDER["INVTYPE_ROBE"] = RCLootCouncilML.EQUIPLOC_SORT_ORDER["INVTYPE_CHEST"] -- Chest is the same as robe

function RCLootCouncilML:SortLootTable(lootTable)
	table.sort(lootTable, self.LootTableCompare)
end

local function GetItemStatsSum(link)
	local stats = GetItemStats(link)
	local sum = 0
	for _, value in pairs(stats or {}) do
		sum = sum + value
	end
	return sum
end

-- The loottable sort compare function
-- Sorted by:
-- 1. equipment slot: head, neck, ...
-- 2. trinket category name
-- 3. subType: junk(armor token), plate, mail, ...
-- 4. relicType: Arcane, Life, ..
-- 5. Item level from high to low
-- 6. The sum of item stats, to make sure items with bonuses(socket, leech, etc) are sorted first.
-- 7. Item name
--
-- @param a: an entry in the lootTable
-- @param b: The other entry in the looTable
-- @return true if a is sorted before b
function RCLootCouncilML.LootTableCompare(a, b)
	if not a.link then return false end
	if not b.link then return true end -- Item hasn't been loaded.
	local equipLocA = RCLootCouncilML.EQUIPLOC_SORT_ORDER[a.token and addon:GetTokenEquipLoc(a.token) or a.equipLoc] or math.huge
	local equipLocB = RCLootCouncilML.EQUIPLOC_SORT_ORDER[b.token and addon:GetTokenEquipLoc(b.token) or b.equipLoc] or math.huge
	if equipLocA ~= equipLocB then
		return equipLocA < equipLocB
	end
	if a.equipLoc == "INVTYPE_TRINKET" and b.equipLoc == "INVTYPE_TRINKET" then
		local specA = _G.RCTrinketSpecs[addon:GetItemIDFromLink(a.link)]
		local specB = _G.RCTrinketSpecs[addon:GetItemIDFromLink(b.link)]
		local categoryA = (specA and _G.RCTrinketCategories[specA]) or ""
		local categoryB = (specB and _G.RCTrinketCategories[specB]) or ""
		if categoryA ~= categoryB then
			return categoryA < categoryB
		end
	end
	if a.typeID ~= b.typeID then
		return a.typeID > b.typeID
	end
	if a.subTypeID ~= b.subTypeID then
		return a.subTypeID > b.subTypeID
	end
	if a.relic ~= b.relic then
		if a.relic and b.relic then
			return a.relic < b.relic
		else
			return b.relic
		end
	end
	if a.ilvl ~= b.ilvl then
		return a.ilvl > b.ilvl
	end
	local statsA = GetItemStatsSum(a.link)
	local statsB = GetItemStatsSum(b.link)
	if statsA ~= statsB then
		return statsA > statsB
	end
	return addon:GetItemNameFromLink(a.link) < addon:GetItemNameFromLink(b.link)
end
