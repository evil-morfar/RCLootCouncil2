--[[--- ml_core.lua	Contains core elements for the MasterLooter.
	Although possible, this module shouldn't be replaced unless closely replicated as other default modules depend on it.
	Assumes several functions in SessionFrame and VotingFrame.
	@author Potdisc
]]

--[[TODOs/NOTES:
]]

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
RCLootCouncilML = addon:NewModule("RCLootCouncilML", "AceEvent-3.0", "AceBucket-3.0", "AceComm-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LibDialog = LibStub("LibDialog-1.0")

local db;

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
	self.awardedInBags = {} -- Awarded items that are stored in MLs inventory
									-- i = { link, winner }
	self.lootInBags = {} 	-- Items not yet awarded but stored in bags
	self.lootOpen = false 	-- is the ML lootWindow open or closed?
	self.running = false		-- true if we're handling a session
	self.council = self:GetCouncilInGroup()

	self:RegisterComm("RCLootCouncil", 		"OnCommReceived")
	self:RegisterEvent("LOOT_OPENED",		"OnEvent")
	self:RegisterEvent("LOOT_CLOSED",		"OnEvent")
	self:RegisterEvent("CHAT_MSG_WHISPER",	"OnEvent")
	self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 10, "UpdateGroup") -- Bursts in group creation, and we should have plenty of time to handle it
	self:RegisterBucketMessage("RCConfigTableChanged", 2, "ConfigTableChanged") -- The messages can burst
	self:RegisterMessage("RCCouncilChanged", "CouncilChanged")
end

--- Add an item to the lootTable
-- @paramsig item[, bagged, slotIndex, index]
-- @param item Any: ItemID|itemString|itemLink
-- @param bagged True if the item is in the ML's inventory
-- @param slotIndex Index of the lootSlot, or nil if none - either this or 'bagged' needs to be supplied
-- @param index Index in self.lootTable, used to set data in a specific session
function RCLootCouncilML:AddItem(item, bagged, slotIndex, index)
	addon:DebugLog("ML:AddItem", item, bagged, slotIndex, index)
	local name, link, rarity, ilvl, iMinLevel, type, subType, iStackCount, equipLoc, texture = GetItemInfo(item)
	local itemID = link and addon:GetItemIDFromLink(link)
	self.lootTable[index or #self.lootTable + 1] = { -- We want to reserve the index even if we haven't fully loaded the item
		["bagged"]		= bagged,
		["lootSlot"]	= slotIndex,
		["awarded"]		= false,
		["name"]			= name, -- REVIEW This is really not needed as it's contained in itemLink. Remove next time we break backwards com
		["link"]			= link,
		["quality"]		= rarity,
		["ilvl"]			= ilvl,
		["subType"]		= subType,
		["equipLoc"]	= equipLoc,
		["texture"]		= texture,
		["boe"]			= addon:IsItemBoE(link),
		["relic"]		= itemID and IsArtifactRelicItem(itemID) and select(3, C_ArtifactUI.GetRelicInfoByItemID(itemID)),
		["token"]		= itemID and RCTokenTable[itemID],
	}
		-- Item isn't properly loaded, so update the data in 1 sec (Should only happen with /rc test)
	if not name then
		self:ScheduleTimer("Timer", 1, "AddItem", item, bagged, slotIndex, index or #self.lootTable)
		addon:Debug("Started timer:", "AddItem", "for", item)
	else
		addon:SendMessage("RCMLAddItem", item, index or #self.lootTable)
	end
end

--- Removes a session from the lootTable
-- @param session The session (index) in lootTable to remove
function RCLootCouncilML:RemoveItem(session)
	tremove(self.lootTable, session)
end

function RCLootCouncilML:AddCandidate(name, class, role, rank, enchant, lvl)
	addon:DebugLog("ML:AddCandidate",name, class, role, rank, enchant, lvl)
	self.candidates[name] = {
		["class"]		= class,
		["role"]			= role,
		["rank"]			= rank or "", -- Rank cannot be nil for votingFrame
		["enchanter"] 	= enchant,
		["enchant_lvl"]= lvl,
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
	for name in pairs(self.candidates) do	group_copy[name] = true end
	for i = 1, GetNumGroupMembers() do
		local name, _, _, _, _, class, _, _, _, _, _, role  = GetRaidRosterInfo(i)
		name = addon:UnitName(name) -- Get their unambiguated name
		if name then -- Apparantly name can be nil (ticket #223)
			if group_copy[name] then	-- If they're already registered
				group_copy[name] = nil	-- remove them from the check
			else -- add them
				if not ask then -- ask for playerInfo?
					addon:SendCommand(name, "playerInfoRequest")
					addon:SendCommand(name, "MLdb", addon.mldb) -- and send mlDB
				end
				self:AddCandidate(name, class, role) -- Add them in case they haven't installed the adoon
				updates = true
			end
		end
	end
	-- If anything's left in group_copy it means they left the raid, so lets remove them
	for name, v in pairs(group_copy) do
		if v then self:RemoveCandidate(name); updates = true end
	end
	if updates then
		self.council = self:GetCouncilInGroup()
		addon:SendCommand("group", "candidates", self.candidates)
	end
end

function RCLootCouncilML:StartSession()
	addon:Debug("ML:StartSession()")
	-- Make sure we haven't started the session too fast
	if not addon.candidates[addon.playerName] or #addon.council == 0 then
		addon:Print(L["Please wait a few seconds until all data has been synchronized."])
		return addon:Debug("Data wasn't ready", addon.candidates[addon.playerName], #addon.council)
	end
	self.running = true

	addon:SendCommand("group", "lootTable", self.lootTable)

	self:AnnounceItems()
	-- Start a timer to set response as offline/not installed unless we receive an ack
	self:ScheduleTimer("Timer", 10, "LootSend")
end

function RCLootCouncilML:AddUserItem(item)
	if self.running then return addon:Print(L["You're already running a session."]) end
	self:AddItem(item, true)
	addon:CallModule("sessionframe")
	addon:GetActiveModule("sessionframe"):Show(self.lootTable)
end

function RCLootCouncilML:SessionFromBags()
	if self.running then return addon:Print(L["You're already running a session."]) end
	if #self.lootInBags == 0 then return addon:Print(L["No items to award later registered"]) end
	for i, link in ipairs(self.lootInBags) do self:AddItem(link, true) end
	if db.autoStart then
		self:StartSession()
	else
		addon:CallModule("sessionframe")
		addon:GetActiveModule("sessionframe"):Show(self.lootTable)
	end
end

-- TODO awardedInBags should be kept in db incase the player logs out
function RCLootCouncilML:PrintAwardedInBags()
	if #self.awardedInBags == 0 then return addon:Print(L["No winners registered"]) end
	addon:Print(L["Following winners was registered:"])
	for _, v in ipairs(self.awardedInBags) do
		if self.candidates[v.winner] then
			local c = addon:GetClassColor(self.candidates[v.winner].class)
			local text = "|cff"..addon:RGBToHex(c.r,c.g,c.b)..addon.Ambiguate(v.winner).."|r"
			addon:Print(v.link, "-->", text)
		else
			addon:Print(v.link, "-->", addon.Ambiguate(v.winner)) -- fallback
		end
	end
	-- IDEA Do we delete awardedInBags here or keep it?
end

function RCLootCouncilML:ConfigTableChanged(val)
	-- The db was changed, so check if we should make a new mldb
	-- We can do this by checking if the changed value is a key in mldb
	if not addon.mldb then return self:UpdateMLdb() end -- mldb isn't made, so just make it
	for val in pairs(val) do
		for key in pairs(addon.mldb) do
			if key == val then return self:UpdateMLdb() end
		end
	end
end

function RCLootCouncilML:CouncilChanged()
	-- The council was changed, so send out the council
	self.council = self:GetCouncilInGroup()
	addon:SendCommand("group", "council", self.council)
	-- Send candidates so new council members can register it
	addon:SendCommand("group", "candidates", self.candidates)
end

function RCLootCouncilML:UpdateMLdb()
	-- The db has changed, so update the mldb and send the changes
	addon:Debug("UpdateMLdb")
	addon.mldb = self:BuildMLdb()
	addon:SendCommand("group", "MLdb", addon.mldb)
end

function RCLootCouncilML:BuildMLdb()
	-- Extract changes to responses
	local changedResponses = {};
	for i = 1, db.numButtons do
		if db.responses[i].text ~= addon.defaults.profile.responses[i].text or unpack(db.responses[i].color) ~= unpack(addon.defaults.profile.responses[i].color) then
			changedResponses[i] = db.responses[i]
		end
	end
	changedResponses.tier = {}
	for k,v in pairs(db.responses.tier) do
		if v.text ~= addon.defaults.profile.responses.tier[k].text or unpack(v.color) ~= unpack(addon.defaults.profile.responses.tier[k].color) then
			changedResponses.tier[k] = v
		end
	end
	changedResponses.relic = {}
	for k,v in pairs(db.responses.relic) do
		if v.text ~= addon.defaults.profile.responses.relic[k].text or unpack(v.color) ~= unpack(addon.defaults.profile.responses.relic[k].color) then
			changedResponses.relic[k] = v
		end
	end
	-- Extract changed buttons
	local changedButtons = {};
	for i = 1, db.numButtons do
		if db.buttons[i].text ~= addon.defaults.profile.buttons[i].text then
			changedButtons[i] = {text = db.buttons[i].text}
		end
	end
	local changedTierButtons = {}
	for i = 1, db.tierNumButtons do
		if db.tierButtons[i].text ~= addon.defaults.profile.tierButtons[i].text then
			changedTierButtons[i] = {text = db.tierButtons[i].text}
		end
	end
	local changedRelicButtons = {}
	for i = 1, db.relicNumButtons do
		if db.relicButtons[i].text ~= addon.defaults.profile.relicButtons[i].text then
			changedRelicButtons[i] = {text = db.relicButtons[i].text}
		end
	end
	return {
		selfVote			= db.selfVote,
		multiVote		= db.multiVote,
		anonymousVoting = db.anonymousVoting,
		allowNotes		= db.allowNotes,
		numButtons		= db.numButtons,
		tierNumButtons = db.tierNumButtons,
		relicNumButtons = db.relicNumButtons,
		hideVotes		= db.hideVotes,
		observe			= db.observe,
		buttons			= changedButtons,
		tierButtons 	= changedTierButtons,
		relicButtons 	= changedRelicButtons,
		responses		= changedResponses,
		timeout			= db.timeout,
		tierButtonsEnabled = db.tierButtonsEnabled,
		relicButtonsEnabled = db.relicButtonsEnabled,
	}
end

function RCLootCouncilML:NewML(newML)
	addon:DebugLog("ML:NewML", newML)
	if addon:UnitIsUnit(newML, "player") then -- we are the the ML
		addon:SendCommand("group", "playerInfoRequest")
		self:UpdateMLdb() -- Will build and send mldb
		self:UpdateGroup(true)
		addon:SendCommand("group", "council", self.council)
		-- Set a timer to send out the incoming playerInfo changes
		self:ScheduleTimer("Timer", 10, "GroupUpdate")
	else
		self:Disable() -- We don't want to use this if we're not the ML
	end
end

function RCLootCouncilML:Timer(type, ...)
	if type == "AddItem" then
		self:AddItem(...)

	elseif type == "LootSend" then
		addon:SendCommand("group", "offline_timer")

	elseif type == "GroupUpdate" then
		addon:SendCommand("group", "council", self.council)
		addon:SendCommand("group", "candidates", self.candidates)
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

			elseif command == "MLdb_request" then
				-- Just resend to the entire group instead of the sender
				addon:SendCommand("group", "MLdb", addon.mldb)

			elseif command == "council_request" then
				addon:SendCommand("group", "council", self.council)

			elseif command == "candidates_request" then
				addon:SendCommand("group", "candidates", self.candidates)

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
					addon:ScheduleTimer("SendCommand", 4, sender, "lootTable", self.lootTable)
					-- v2.2.6 REVIEW For backwards compability we're just sending votingFrame's lootTable
					-- This is quite redundant and should be removed in the future
					local table = addon:GetActiveModule("votingframe"):GetLootTable()
					-- Remove our own voting data if any
					for ses, v in ipairs(table) do
						v.haveVoted = false
						for _, d in pairs(v.candidates) do
							d.haveVoted = false
						end
					end
					addon:ScheduleTimer("SendCommand", 5, sender, "reconnectData", table)
				end
				addon:Debug("Responded to reconnect from", sender)
			end
		else
			addon:Debug("Error in deserializing ML comm: ", command)
		end
	end
end

function RCLootCouncilML:OnEvent(event, ...)
	addon:DebugLog("ML event", event, ...)
	if event == "LOOT_OPENED" then -- IDEA Check if event LOOT_READY is useful here (also check GetLootInfo() for this)
		self.lootOpen = true
		if not InCombatLockdown() then
			self:LootOpened()
		else
			addon:Print(L["You can't start a loot session while in combat."])
		end
	elseif event == "LOOT_CLOSED" then
		self.lootOpen = false

	elseif event == "CHAT_MSG_WHISPER" and addon.isMasterLooter and db.acceptWhispers then
		local msg, sender = ...
		if msg == "rchelp" then
			self:SendWhisperHelp(sender)
		elseif self.running then
			self:GetItemsFromMessage(msg, sender)
		end
	end
end

function RCLootCouncilML:LootOpened()
	local sessionframe = addon:GetActiveModule("sessionframe")
	if addon.isMasterLooter and GetNumLootItems() > 0 then
		if self.running or sessionframe:IsRunning() then -- Check if an update is needed
			self:UpdateLootSlots()
		else -- Otherwise add the loot
			for i = 1, GetNumLootItems() do
				local item = GetLootSlotLink(i)
				if db.altClickLooting then self:ScheduleTimer("HookLootButton", 0.5, i) end -- Delay lootbutton hooking to ensure other addons have had time to build their frames
				local _, _, quantity, quality = GetLootSlotInfo(i)
				if self:ShouldAutoAward(item, quality) and quantity > 0 then
					self:AutoAward(i, item, quality, db.autoAwardTo, db.autoAwardReason, addon.bossName)

				elseif self:CanWeLootItem(item, quality) and quantity > 0 then -- check if our options allows us to loot it
					self:AddItem(item, false, i)

				elseif quantity == 0 then -- it's coin, just loot it
					LootSlot(i)
				end
			end
		end
		if #self.lootTable > 0 and not self.running then
			if db.autoStart then -- Settings say go
				self:StartSession()
			else
				addon:CallModule("sessionframe")
				sessionframe:Show(self.lootTable)
			end
		end
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

function RCLootCouncilML:UpdateLootSlots()
	if not self.lootOpen then return addon:Debug("ML:UpdateLootSlots() without loot window open!!") end
	local updatedLootSlot = {}
	for i = 1, GetNumLootItems() do
		local item = GetLootSlotLink(i)
		for session = 1, #self.lootTable do
			-- Just skip if we've already awarded the item or found a fitting lootSlot
			if not self.lootTable[session].awarded and not updatedLootSlot[session] then
				if item == self.lootTable[session].link then
					if i ~= self.lootTable[session].lootSlot then -- It has changed!
						addon:DebugLog("lootSlot @session", session, "Was at:",self.lootTable[session].lootSlot, "is now at:", i)
						self.lootTable[session].lootSlot = i -- update it
						updatedLootSlot[session] = true
					end
					break
				end
			end
		end
	end
end

function RCLootCouncilML:HookLootButton(i)
	local lootButton = getglobal("LootButton"..i)
	if XLoot then -- hook XLoot
		lootButton = getglobal("XLootButton"..i)
	end
	if XLootFrame then -- if XLoot 1.0
		lootButton = getglobal("XLootFrameButton"..i)
	end
	if getglobal("ElvLootSlot"..i) then -- if ElvUI
		lootButton = getglobal("ElvLootSlot"..i)
	end
	local hooked = self:IsHooked(lootButton, "OnClick")
	if lootButton and not hooked then
		addon:DebugLog("ML:HookLootButton", i)
		self:HookScript(lootButton, "OnClick", "LootOnClick")
	end
end

function RCLootCouncilML:LootOnClick(button)
	if not IsAltKeyDown() or not db.altClickLooting or IsShiftKeyDown() or IsControlKeyDown() then return; end
	addon:DebugLog("LootAltClick()", button)

	if getglobal("ElvLootFrame") then
		button.slot = button:GetID() -- ElvUI hack
	end

	-- Check we're not already looting that item
	for ses, v in ipairs(self.lootTable) do
		if button.slot == v.lootSlot then
			addon:Print(L["The loot is already on the list"])
			return
		end
	end

	self:AddItem(GetLootSlotLink(button.slot), false, button.slot)
	addon:CallModule("sessionframe")
	addon:GetActiveModule("sessionframe"):Show(self.lootTable)
end

-- Status can be one of the following:
-- test_mode, no_loot_slot, loot_not_open, normal, bagged
-- See :Award() for the different scenarios
local function awardSuccess(session, winner, status)
	addon:SendMessage("RCMLAwardSuccess", session, winner, status)
	return true
end
local function awardFailed(session, winner, status)
	addon:SendMessage("RCMLAwardFailed", session, winner, status)
	return false
end

--@param session	The session to award.
--@param winner	Nil/false if items should be stored in inventory and awarded later.
--@param response	The candidates response, used for announcement.
--@param reason	Entry in db.awardReasons.
--@returns True if awarded successfully
function RCLootCouncilML:Award(session, winner, response, reason)
	addon:DebugLog("ML:Award", session, winner, response, reason, isToken)
	if addon.testMode then
		if winner then
			addon:SendCommand("group", "awarded", session, winner)
			addon:Print(format(L["The item would now be awarded to 'player'"], addon.Ambiguate(winner)))
			self.lootTable[session].awarded = winner
			if self:HasAllItemsBeenAwarded() then
				 addon:Print(L["All items has been awarded and  the loot session concluded"])
			end
		end
		return awardSuccess(session, winner, "test_mode")
	end
	if not self.lootTable[session].lootSlot and not self.lootTable[session].bagged then
		addon:SessionError("Session "..session.." didn't have lootSlot")
		return awardFailed(session, winner, "no_loot_slot")
	end
	-- Determine if we should award the item now or just store it in our bags
	if winner then
		local awarded = false
		--  give out the loot or store the result, i.e. bagged or not
		if self.lootTable[session].bagged then   -- indirect mode (the item is in a bag)
			-- Add to the list of awarded items in MLs bags, and remove it from lootInBags
			tinsert(self.awardedInBags, {link = self.lootTable[session].link, winner = winner})
			tremove(self.lootInBags, session)
			awarded = true

		else -- Direct (we can award from a WoW loot list)
			if not self.lootOpen then -- we can't give out loot without the loot window open
				addon:Print(L["Unable to give out loot without the loot window open."])
				--addon:Print(L["Alternatively, flag the loot as award later."])
				return awardFailed(session, winner, "loot_not_open")
			end
			-- v2.4.4+: Check if the item is still in the expected slot
			if self.lootTable[session].link ~= GetLootSlotLink(self.lootTable[session].lootSlot) then
				addon:Debug("LootSlot has changed before award!", session)
				-- And update them if not
				self:UpdateLootSlots()
			end
			if self.lootTable[session].quality < GetLootThreshold() or GetNumGroupMembers() == 0 then
				LootSlot(self.lootTable[session].lootSlot)
				if not addon:UnitIsUnit(winner, "player") then
					addon:Print(format(L["Cannot give 'item' to 'player' due to Blizzard limitations. Gave it to you for distribution."], self.lootTable[session].link, addon.Ambiguate(winner)))
					tinsert(self.awardedInBags, {link = self.lootTable[session].link, winner = winner})
				end
				awarded = true

			else
				for i = 1, MAX_RAID_MEMBERS do
					if addon:UnitIsUnit(GetMasterLootCandidate(self.lootTable[session].lootSlot, i), winner) then
						addon:Debug("GiveMasterLoot", i)
						GiveMasterLoot(self.lootTable[session].lootSlot, i)
						awarded = true
						break
					end
				end
			end
		end
		if awarded then
			-- flag the item as awarded and update
			self.lootTable[session].awarded = winner -- No need to let Comms handle this
			awardSuccess(session, winner, "normal")
			addon:SendCommand("group", "awarded", session, winner)

			self:AnnounceAward(winner, self.lootTable[session].link,
			 reason and reason.text or response, addon:GetActiveModule("votingframe"):GetCandidateData(session, winner, "roll"), session)
			if self:HasAllItemsBeenAwarded() then self:EndSession() end

		else -- If we reach here it means we couldn't find a valid MasterLootCandidate, propably due to the winner is unable to receive the loot
			addon:Print(format(L["Unable to give 'item' to 'player' - (player offline, left group or instance?)"], self.lootTable[session].link, winner))
			awardFailed(session, winner, "normal")
		end
		return awarded

	else -- Store in bags and award later
		if not self.lootOpen then return addon:Print(L["Unable to give out loot without the loot window open."]) end
		if self.lootTable[session].quality < GetLootThreshold() then
			LootSlot(self.lootTable[session].lootSlot)
		else
			for i = 1, MAX_RAID_MEMBERS do
				if addon:UnitIsUnit(GetMasterLootCandidate(self.lootTable[session].lootSlot, i), "player") then
					GiveMasterLoot(self.lootTable[session].lootSlot, i)
					break
				end
			end
		end
		tinsert(self.lootInBags, self.lootTable[session].link) -- and store data
		return awardFailed(session, winner, "bagged") -- Item hasn't been awarded
	end
end

--- Substitution strings for AnnounceItems
-- Each keyword will be replaced with the func result if it's used in db.announceItemString
-- The function receives session, itemlink, lootTable[session] as arguments
RCLootCouncilML.announceItemStrings = {
	["&s"] = function(ses) return ses end,
	["&i"] = function(...) return select(2,...) end,
}
function RCLootCouncilML:AnnounceItems()
	if not db.announceItems then return end
	addon:DebugLog("ML:AnnounceItems()")
	SendChatMessage(db.announceText, addon:GetAnnounceChannel(db.announceChannel))
	for k,v in ipairs(self.lootTable) do
		local msg = db.announceItemString
		for text, func in pairs(self.announceItemStrings) do
			message = gsub(msg, text, tostring(func(k, v.link, v)))
		end
		SendChatMessage(msg, addon:GetAnnounceChannel(db.announceChannel))
	end
end

--- Substitution strings for the awardString
-- Each index corrosponds to a keyword in the award string.
-- If it exists, the function will be called with all the parameters from :AnnounceAward
RCLootCouncilML.awardStrings = {
	["&p"] = function(name) return addon.Ambiguate(name) end,
	["&i"] = function(...) return select(2, ...) end,
	["&r"] = function(...) return select(3, ...) end,
	["&n"] = function(...) return select(4, ...) or "" end,
}

-- See above for text substitutions
-- @paramsig 			name, link, text [,roll, session]
-- @param name 		The unambiguated name of the winner
-- @param link 		The itemlink of the awarded item
-- @param response	The text matching the candidate's response
-- @param roll 		The candidates' roll
-- @param session		The session of the awarded item
function RCLootCouncilML:AnnounceAward(name, link, response, roll, session)
	if db.announceAward then
		for k,v in pairs(db.awardText) do
			local message = v.text
			if v.channel ~= "NONE" then
				for text, func in pairs(self.awardStrings) do
					message = gsub(message, text, tostring(func(name, link, response, roll, session)))
				end
				SendChatMessage(message, addon:GetAnnounceChannel(v.channel))
			end
		end
	end
end

function RCLootCouncilML:ShouldAutoAward(item, quality)
	if db.autoAward and quality >= db.autoAwardLowerThreshold and quality <= db.autoAwardUpperThreshold then
		if db.autoAwardLowerThreshold >= GetLootThreshold() or db.autoAwardLowerThreshold < 2 then
			if UnitInRaid(db.autoAwardTo) or UnitInParty(db.autoAwardTo) then -- TEST perhaps use self.group?
				return true;
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

function RCLootCouncilML:AutoAward(lootIndex, item, quality, name, reason, boss)
	addon:DebugLog("ML:AutoAward", lootIndex, item, quality, name, reason, boss)
	local awarded = false
	if db.autoAwardLowerThreshold < 2 and quality < 2 then
		if addon:UnitIsUnit("player",name) then -- give it to the player
			LootSlot(lootIndex)
			awarded = true
		else
			addon:Print(L["Cannot autoaward:"])
			addon:Print(format(L["You can only auto award items with a quality lower than 'quality' to yourself due to Blizaard restrictions"],"|cff1eff00"..getglobal("ITEM_QUALITY2_DESC").."|r"))
			return false
		end
	else
		for i = 1, GetNumGroupMembers() do
			if addon:UnitIsUnit(GetMasterLootCandidate(lootIndex, i), name) then
				GiveMasterLoot(lootIndex,i)
				awarded = true
			end
		end
	end
	if awarded then
		addon:Print(format(L["Auto awarded 'item'"], item))
		self:AnnounceAward(name, item, db.awardReasons[reason].text)
		self:TrackAndLogLoot(name, item, reason, boss, 0, nil, nil, db.awardReasons[reason])
	else
		addon:Print(L["Cannot autoaward:"])
		addon:Print(format(L["Unable to give 'item' to 'player' - (player offline, left group or instance?)"], item, name))
	end
	return awarded
end

local history_table = {}
 function RCLootCouncilML:TrackAndLogLoot(name, item, responseID, boss, votes, itemReplaced1, itemReplaced2, reason, isToken, tokenRoll, relicRoll)
	if reason and not reason.log then return end -- Reason says don't log
	if not (db.sendHistory or db.enableHistory) then return end -- No reason to do stuff when we won't use it
	if addon.testMode and not addon.nnp then return end -- We shouldn't track testing awards.
	local instanceName, _, difficultyID, difficultyName, _,_,_,mapID, groupSize = GetInstanceInfo()
	addon:Debug("ML:TrackAndLogLoot()")
	history_table["lootWon"] 		= item
	history_table["date"] 			= date("%d/%m/%y")
	history_table["time"] 			= date("%H:%M:%S")
	history_table["instance"] 		= instanceName.."-"..difficultyName
	history_table["boss"] 			= boss or L["Unknown"]
	history_table["votes"] 			= votes
	history_table["itemReplaced1"]= itemReplaced1
	history_table["itemReplaced2"]= itemReplaced2
	history_table["response"] 		= reason and reason.text or addon:GetResponseText(responseID, tokenRoll, relicRoll)
	history_table["responseID"] 	= responseID or reason.sort - 400 															-- Changed in v2.0 (reason responseID was 0 pre v2.0)
	history_table["color"]			= reason and reason.color or {addon:GetResponseColor(responseID, tokenRoll, relicRoll)}	-- New in v2.0
	history_table["class"]			= self.candidates[name].class																-- New in v2.0
	history_table["isAwardReason"]= reason and true or false																	-- New in v2.0
	history_table["difficultyID"]	= difficultyID																					-- New in v2.3+
	history_table["mapID"]			= mapID																							-- New in v2.3+
	history_table["groupSize"]		= groupSize																						-- New in v2.3+
	history_table["tierToken"]		= isToken																						-- New in v2.3+
	history_table["tokenRoll"]		= tokenRoll																						-- New in v2.4+
	history_table["relicRoll"]		= relicRoll																						-- New in v2.5+

	addon:SendMessage("RCMLLootHistorySend", history_table, name, item, responseID, boss, votes, itemReplaced1, itemReplaced2, reason, isToken, tokenRoll, relicRoll)

	if db.sendHistory then -- Send it, and let comms handle the logging
		addon:SendCommand("group", "history", name, history_table)
	elseif db.enableHistory then -- Just log it
		addon:SendCommand("player", "history", name, history_table)
	end
	history_table = {} -- wipe to ensure integrety
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
	for session, iName in ipairs(items) do
		self:AddItem(iName, false, false)
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
	return tContains(db.ignore, itemID)
end

--- Fetches the council members from the current group.
-- Used by the ML to only send out a council consisting of actual group members.
-- That council is stored in RCLootCouncil.council
-- @return table [i] = "council_man_name".
function RCLootCouncilML:GetCouncilInGroup()
	local council = {}
	for _, name in ipairs(addon.db.profile.council) do
		if self.candidates[name] then
			tinsert(council, name)
		end
	end
	if not tContains(council, addon.playerName) then -- Check if the ML (us) is included
		tinsert(council, addon.playerName)
	end
	addon:DebugLog("GetCouncilInGroup", unpack(council))
	return council
end

function RCLootCouncilML:GetItemsFromMessage(msg, sender)
	addon:Debug("GetItemsFromMessage()", msg, sender)
	if not addon.isMasterLooter then return end

	local ses, arg1, arg2, arg3 = addon:GetArgs(msg, 4) -- We only require session to be correct, we can do some error checking on the rest
	ses = tonumber(ses)
	-- Let's test the input
	if not ses or type(ses) ~= "number" or ses > #self.lootTable then return end -- We need a valid session
	-- Set some locals
	local item1, item2, isTier, isRelic
	local response = 1
	if arg1:find("|Hitem:") then -- they didn't give a response
		item1, item2 = arg1, arg2
	else
		-- No reason to continue if they didn't provide an item
		if not arg2 or not arg2:find("|Hitem:") then return end
		item1, item2 = arg2, arg3

		-- check if the response is valid
		local whisperKeys = {}
		if self.lootTable[ses].token and addon.mldb.tierButtonsEnabled then
			isTier = true
			for i=1, db.tierNumButtons do
				gsub(db.tierButtons[i]["whisperKey"], '[%w]+', function(x) tinsert(whisperKeys, {key = x, num = i}) end)
			end
		elseif self.lootTable[ses].relic and addon.mldb.relicButtonsEnabled then
			isRelic = true
			for i=1, db.relicNumButtons do
				gsub(db.relicButtons[i]["whisperKey"], '[%w]+', function(x) tinsert(whisperKeys, {key = x, num = i}) end)
			end
		else
			for i = 1, db.numButtons do --go through all the button
				gsub(db.buttons[i]["whisperKey"], '[%w]+', function(x) tinsert(whisperKeys, {key = x, num = i}) end) -- extract the whisperKeys to a table
			end
		end
		for _,v in ipairs(whisperKeys) do
			if strmatch(arg1, v.key) then -- if we found a match
				response = v.num
				break;
			end
		end
	end
	local diff = 0
	if item1 then diff = (self.lootTable[ses].ilvl - select(4, GetItemInfo(item1))) end
	local toSend = {
		gear1 = item1,
		gear2 = item2,
		ilvl = nil,
		diff = diff,
		note = L["Auto extracted from whisper"],
		response = response,
		isTier = isTier,
		isRelic = isRelic,
	}
	addon:SendCommand("group", "response", ses, sender, toSend)
	-- Let people know we've done stuff
	addon:Print(format(L["Item received and added from 'player'"], addon.Ambiguate(sender)))
	SendChatMessage("[RCLootCouncil]: "..format(L["Acknowledged as 'response'"], addon:GetResponseText(response, isTier)), "WHISPER", nil, sender)
end

function RCLootCouncilML:SendWhisperHelp(target)
	addon:DebugLog("SendWhisperHelp", target)
	local msg
	SendChatMessage(L["whisper_guide"], "WHISPER", nil, target)
	for i = 1, db.numButtons do
		msg = "[RCLootCouncil]: "..db.buttons[i]["text"]..":  " -- i.e. MainSpec/Need:
		msg = msg..""..db.buttons[i]["whisperKey"].."." -- need, mainspec, etc
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
	frame.icon:SetTexture(RCLootCouncilML.lootTable[data.session].texture)
end

function RCLootCouncilML.AwardPopupOnClickYes(frame, data)
	local awarded = RCLootCouncilML:Award(data.session, data.winner, data.responseID and addon:GetResponseText(data.responseID, data.isTierRoll, data.isRelicRoll), data.reason)
	if awarded then -- log it
		RCLootCouncilML:TrackAndLogLoot(data.winner, data.link, data.responseID, addon.bossName, data.votes, data.gear1, data.gear2,
		 										  data.reason, data.isToken, data.isTierRoll, data.isRelicRoll)
	end
	-- We need to delay the test mode disabling so comms have a chance to be send first!
	if addon.testMode and RCLootCouncilML:HasAllItemsBeenAwarded() then RCLootCouncilML:EndSession() end
	--return awarded -- Doesn't work, as LibDialog only hides the dialog if we return false/nil
end

function RCLootCouncilML.AwardPopupOnClickNo(frame, data)
	-- Intentionally left empty
end
