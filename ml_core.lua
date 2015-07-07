--[[	RCLootCouncil ml_core.lua	by Potdisc
	Contains core elements for the MasterLooter
	NOTE: Is implemented as a module for reasons...
		Although possible, this module shouldn't be replaced unless closely replicated as other default modules depend on it.

	TODO/NOTES:
		- Announce text for addon.db.awardReason (might need a better name)
		- Pool: Which reasons should be used with autoAward, and display announce message on autoAward?
		- SendMessage() on AddItem() to let userModules know it's safe to add to lootTable. Might have to do it other places too.
]]

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
RCLootCouncilML = addon:NewModule("RCLootCouncilML", "AceEvent-3.0", "AceBucket-3.0", "AceComm-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local db;
local session = 1

function RCLootCouncilML:OnInitialize()
	addon:Print("ML initialized!")
end

function RCLootCouncilML:OnDisable()

end

function RCLootCouncilML:OnEnable()
	db = addon:Getdb()
	self.candidates = {} -- candidateName = { class, role, rank }
	self.lootTable = {} -- The MLs operating lootTable - addon.lootTable is used for visuals
	--[[ self.lootTable[session] = {
		bagged, lootSlot, announced, awarded, name, link, lvl, type, subType, equipLoc, texture

		candidates[name] = {
			rank, role, totalIlvl, diff, response, gear1, gear2, votes, class, haveVoted, voters[], note
		},
	}
	]]
	self.lootInBags = {} -- Awarded items that are stored in MLs inventory
		-- i = { itemName, winner }
	self.lootOpen = false -- is the ML lootWindow open or closed?
	self.running = false -- true if we're handling a session

	self:RegisterComm("RCLootCouncil", "OnCommReceived")
	self:RegisterEvent("LOOT_OPENED","OnEvent")
	self:RegisterEvent("LOOT_CLOSED","OnEvent")
	self:RegisterEvent("RAID_INSTANCE_WELCOME","OnEvent")
	self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 20, "UpdateGroup") -- Bursts in group creation, and we should have plenty of time to handle it
	self:RegisterEvent("CHAT_MSG_WHISPER","OnEvent")
	self:RegisterEvent("CHAT_MSG_RAID","OnEvent")
end

-- Adds an item session in lootTable
-- @param session The Session to add to
-- @param item Any: ItemID|itemString|itemLink
-- @param bagged True if the item is in the ML's inventory
-- @param slotIndex Index of the lootSlot, or nil if none
function RCLootCouncilML:AddItem(session, item, bagged, slotIndex)
	addon:DebugLog("ML:AddItem("..tostring(session)..", "..tostring(item)..", "..tostring(bagged)..", "..tostring(slotIndex)..")")
	local name, link, rarity, ilvl, iMinLevel, type, subType, iStackCount, equipLoc, texture = GetItemInfo(item)
	if not name then -- start a timer so we can add when item info is recieved -- TODO should be redundant, as we'll never get an uncached item as ML (unless we're testing?)
		self:ScheduleTimer("Timer", 1, "AddItem", session, item, bagged, slotIndex)
		addon:Debug("Started timer: \"AddItem\"")
		return;
	end
	--self.lootTable[session] = {} -- wipe it
	self.lootTable[session] = {
		["bagged"]		= bagged,
		["lootSlot"]	= slotIndex,
		["announced"]	= false,
		["awarded"]		= false,
		["name"]		= name,
		["link"]		= link,
		["ilvl"]		= ilvl,
		["type"]		= type,
		["subType"]		= subType,
		["equipLoc"]	= equipLoc,
		["texture"]		= texture,
		--["candidates"]	= {},
	};
end

-- Removes item (session) from self.lootTable
function RCLootCouncilML:RemoveItem(session)
	tremove(self.lootTable, session)
end

function RCLootCouncilML:AddCandidate(name, class, role, rank)
	addon:DebugLog("ML:AddCandidate("..name..", ...)")
	self.candidates[name] = {
		["class"]	= class,
		["role"]	= role,
		["rank"]	= rank,
	}
end

function RCLootCouncilML:RemoveCandidate(name)
	self.candidates[name] = nil
end

-- TODO This needs to work if one's not in a raid (if possible)
function RCLootCouncilML:UpdateGroup()
	local group_copy = {}
	for name, _ in pairs(self.candidates) do	group_copy[name] = name end -- Use name as index for zzz
	for i = 1, GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i)
		if group_copy[name] then	-- If they're already registered
			group_copy[name] = nil	-- remove them from the check  -- TODO not 100% this will work as intended
		else -- add them
			addon:SendCommand(name, "playerInfoRequest")
			addon:SendCommand(name, "MLdb", addon.mldb) -- and send mlDB
		end
	end
	-- If anything's left in group_copy it means they left the raid, so lets remove them
	for _, name in pairs(group_copy) do
		if name then self:RemoveCandidate(name) end
	end
end

function RCLootCouncilML:StartSession()
	addon:Debug("ML:StartSession()")
	if not self.running then
		self.running = true
		self:MLdbCheck() -- check if we need to build mldb or anyone have an outdated version
		addon:SendCommand("group", "council", addon.council) -- TODO only send council if there's changes, since it's send once a ML is detected
		addon:SendCommand("group", "candidates", self.candidates) -- TODO Same as above


		addon:SendCommand("group", "lootTable", self.lootTable)

		if db.announceItems then self:AnnounceItems() end
		-- Start a timer to set response as offline/not installed unless we receive an ack
		self:ScheduleTimer("Timer", 10, "LootSend")

		-- Finally call the voting frame
		--addon:CallModule("votingFrame")
		--addon:GetActiveModule("votingFrame"):Setup(self.lootTable)

	else
		addon:Debug("called while running a session!")
	end
end


function RCLootCouncilML:MLdbCheck()
	-- TODO we shouldn't have to send a check, just send it when it's created, and then send it again if we update it
	if addon.mldb.v then
		addon:SendCommand("group", "MLdb_check", addon.mldb.v)
	else
		addon.mldb = self:BuildMLdb()
		addon:SendCommand("group", "MLdb", addon.mldb)
	end
end

function RCLootCouncilML:BuildMLdb()
	-- Extract changes to addon.responses
	local changedResponses = {};
	for i,v in ipairs(db.responses) do
		if v.text ~= addon.responses[i].text or unpack(v.color) ~= unpack(addon.responses[i].color) then
			changedResponses[i] = v
		end
	end
	-- Extract changed buttons
	local changedButtons = {};
	for i,v in ipairs(db.buttons) do
		if v.text ~= addon.defaults.profile.buttons[i].text then
			changedButtons[i] = v
		end
	end
	-- Extract changed award reasons
	local changedAwardReasons = {}
	for i,v in ipairs(db.awardReasons) do
		if v.text ~= addon.defaults.profile.awardReasons[i].text then
			changedAwardReasons[i] = v
		end
	end
	return {
		v				= math.random(100), -- generate new mldb version
		selfVote		= db.selfVote,
		multiVote		= db.multiVote,
		anonymousVoting = db.anonymousVoting,
		allowNotes		= db.allowNotes,
		numButtons		= db.numButtons,
		passButton		= db.passButton,
		observe			= db.observe,
		awardReasons	= changedAwardReasons,
		buttons			= changedButtons,
		responses		= changedResponses,
	}
end

function RCLootCouncilML:NewML(newML)
	if addon:UnitIsUnit(newML, "player") then -- we are the the ML
		addon:DebugLog("ML:NewML()")
		addon:SendCommand("group", "playerInfoRequest")
		addon.mldb = self:BuildMLdb()
		addon:SendCommand("group", "council", addon.Council)
	end
end

function RCLootCouncilML:ShouldAutoAward(item, quality)
	if db.autoAward and quality >= db.autoAwardLowerThreshold and quality <= db.autoAwardUpperThreshold then
		if db.autoAwardLowerThreshold >= GetLootThreshold() then
			if UnitInRaid(db.autoAwardTo) then -- TODO perhaps use self.group?
				return true;
			else
				addon:Print(L["Cannot autoaward:"])
				addon:Print(format(L["Could not find p in the raid."], db.AutoAwardTo))
			end
		else
			addon:Print(format(L["Could not Auto Award i because the Loot Threshold is too high!"], item))
		end
	end
	return false
end

function RCLootCouncilML:Timer(type, ...)
	addon:Debug("Timer: "..type.." passed.")
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

		if test then
			if command == "playerInfo" and addon.isMasterLooter then -- only ML should receive playerInfo
				self:AddCandidate(unpack(data))

			elseif command == "MLdb_request" and addon.isMasterLooter then
				addon:SendCommand(sender, "MLdb", addon.mldb)

			--elseif command == "lootAck" then
			--	local name = unpack(data)
			--	for i = 1, #self.lootTable do
			--		self.lootTable[i].candidates[name].response = "WAIT"
			--	end
			end
		else
			addon:Debug("Error in deserializing ML comm: "..tostring(command))
		end
	end
end

function RCLootCouncilML:OnEvent(event, ...)
	addon:DebugLog("ML event: "..event)
	if event == "LOOT_OPENED" then -- TODO Check if event LOOT_READY is useful here (also check GetLootInfo() for this)
		self.lootOpen = true
		if addon.isMasterLooter and (IsInRaid() or addon.nnp) and GetNumLootItems() > 0 then
			if not InCombatLockdown() then -- TODO do something with looting in combat
				addon.target = GetUnitName("target") or "Unknown/Chest" -- capture the boss name
				for i = 1, GetNumLootItems() do
					if db.altClickLooting then self:HookLootButton(i) end -- hook the buttons
					local _, item, quantity, quality = GetLootSlotInfo(i)
					if self:ShouldAutoAward(item, quality) and quantity > 0 then
						self:AutoAward(i, item, db.autoAwardTo, db.autoAwardReason, addon.target)

					elseif self:CanWeLootItem(item, i, quality) and quantity > 0 then -- check if our options allows us to loot it
							self:AddItem(session, item, false, i)
							session = session + 1

					elseif quantity == 0 then -- it's coin, just loot it
						LootSlot(i)
					end
				end
				if #self.lootTable > 0 then
					if db.autoStart then -- Settings say go
						self:StartSession()
					else
						addon:CallModule("sessionFrame")
						addon:GetActiveModule("sessionFrame"):Show(self.lootTable)
					end
				end
			else
				self:Print(L["You can't start a loot session while in combat."])
			end
		end
	elseif event == "LOOT_CLOSED" then
		self.lootOpen = false

	end
end

function RCLootCouncilML:CanWeLootItem(item, index, quality)
	--TODO LootSlotHasItem doesn't work for this purpose
	if (LootSlotHasItem(index) or db.autoLootEverything) and quality >= GetLootThreshold() and not self:IsItemIgnored(item) then -- it's something we're allowed to loot
		-- Let's check if it's BoE
		-- Don't bother checking if we know we want to loot it
		if db.autolootBoE then return true; end

		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:SetHyperlink(item)
		if GameTooltip:NumLines() > 1 then -- check that there is something here
			for i = 1, 5 do -- BoE status won't be further away than line 5
				local line = getglobal('GameTooltipTextLeft' .. i)
				if line and line.GetText then
					if line:GetText() == ITEM_BIND_ON_EQUIP then
						GameTooltip:Hide()
						return db.autolootBoE
					end
				end
			end
		end
		GameTooltip:Hide()
		return true;
	end
	return false
end

function RCLootCouncilML:HookLootButton(i)
	addon:DebugLog("ML:HookLootButton("..tostring(i)..")")
	local lootButton = getglobal("LootButton"..i)
	if lootButton then
		self:HookScript(lootButton, "OnClick", "LootOnClick")
	end
	if XLoot then -- hook XLoot
		lootButton = getglobal("XLootButton"..i)
		if lootButton then
			self:HookScript(lootButton, "OnClick", "LootOnClick")
		end
	end
	if XLootFrame then -- if XLoot 1.0
		lootButton = getglobal("XLootFrameButton"..i)
		if lootButton then
			self:HookScript(lootButton, "OnClick", "LootOnClick")
		end
	end
	if getglobal("ElvLootSlot"..i) then -- if ElvUI
		lootButton = getglobal("ElvLootSlot"..i)
		if lootButton then
			self:HookScript(lootButton, "OnClick", "LootOnClick")
		end
	end
end

function RCLootCouncilML:LootOnClick(button)
	if not IsAltKeyDown() or not db.altClickLooting or IsShiftKeyDown() or IsControlKeyDown() then return; end
	self:DebugLog("LootAltClick(...)")

		--TODO
end

function RCLootCouncilML:AnnounceItems()
	addon:DebugLog("ML:AnnounceItems()")
	SendChatMessage(db.announceText, db.announceChannel)
	for k,v in ipairs(self.lootTable) do
		SendChatMessage(k .. ": " .. v.link, db.announceChannel)
	end
end


--@param session	The session to award
--@param winner		Nil/false if items should be stored in inventory and awarded later
function RCLootCouncilML:Award(session, winner)
	-- Start by determining if we should award the item now or just store it in our bags
	if winner then
		--  give out the loot or store the result, i.e. bagged or not
		if not addon.lootList[session].bagged then -- Direct (we can award from a WoW loot list)
			local lootSlot = addon.lootList[session].lootSlot
			if not lootSlot then
				addon:SessionError("Session "..session.. "didn't have lootSlot")
				return
			end
			if not self.lootOpen then -- we can't give out loot without the loot window open
				addon:Print(L["Unable to give out loot without the loot window open."])
				addon:Print(L["Alternatively, flag the loot as award later."])
				return
			end
			if addon:UnitIsUnit(winner, "player") then -- give it to the player
				LootSlot(lootSlot)
			else
				for i = 1, GetNumGroupMembers() do
					if addon:UnitIsUnit(GetMasterLootCandidate(i), winner) then
						GiveMasterLoot(lootSlot, i)
					end
				end
			end

		else -- indirect mode (the item is in a bag)
			-- Add to the list of awarded items in MLs bags
			tinsert(self.lootInBags, {addon.lootList[session].itemid, winner})
		end

		-- flag the item as awarded and update
		addon:SendCommand("group", "awarded", session)
		RCLootCouncilML:Update()

		if db.announceAward then
			-- TODO insert announce text if awarded by addon.db.awardReason
			for k,v in pairs(db.awardText) do
				if v.channel ~= "NONE" then
					local message = gsub(v.text, "&p", addon.Ambiguate(winner))
					message = gsub(message, "&i", addon.lootList[session].link)
					SendChatMessage(message, v.channel)
				end
			end
		end
		if db.enableHistory then -- log it
			self:TrackAndLogLoot(winner, self.lootTable[session].itemid, self.lootTable[session].candidates[winner].response, addon.target, self.lootTable[session].candidates[winner].votes, self.lootTable[session].candidates[winner].gear1, self.lootTable[session].candidates[winner].gear2)
		end
		self:HasAllItemsBeenAwarded() -- TODO might not be the best place for it
	else -- Store in bags
		if not addon.lootList[session].lootSlot then return addon:SessionError("Session "..session.. "didn't have lootSlot") end
		LootSlot(addon.lootList[session].lootSlot) -- take the item
		tinsert(self.lootInBags, {addon.lootList[session].itemid, winner}) -- and store data
	end
end

function RCLootCouncilML:AutoAward(lootIndex, item, name, reason, boss)
	if addon:UnitIsUnit("player",name) then -- give it to the player
		LootSlot(lootIndex)
	else
		for i = 1, GetNumGroupMembers() do
			if addon:UnitIsUnit(GetMasterLootCandidate(lootIndex, i), name) then
				GiveMasterLoot(lootIndex,i)
			end
		end
	end
	self:Print(format(L["i was Auto Awarded to p with the reason r"], item, addon.Ambiguate(name), reason))
	if db.enableHistory and db.awardReasons[reason].log then -- only track and log if allowed
		RCLootCouncilML:TrackAndLogLoot(name, item, reason, boss, 0, nil, nil, db.autoAwardReasons[reason].text, db.autoAwardReasons[reason].color)
	end

end

function RCLootCouncilML:TrackAndLogLoot(name, item, response, boss, votes, itemReplaced1, itemReplaced2, reason, color)
	local instanceName, _, _, difficultyName = GetInstanceInfo()
	local table = {["lootWon"] = item, ["date"] = date("%d/%m/%y"), ["time"] = date("%H:%M:%S"), ["instance"] = instanceName.." "..difficultyName,
		["boss"] = boss, ["votes"] = votes, ["itemReplaced1"] = itemReplaced1, ["itemReplaced2"] = itemReplaced2, ["response"] = response,
		["reason"] = reason or db.responses[response].text, ["color"] = color or db.responses[response].color}
	if db.sendHistory then -- Send it, and let comms handle the logging
		addon:SendCommand("group", "history", name, table)
	else -- Just log it
		addon:SendCommand("player", "history", name, table)
	end
	table = {}
end

function RCLootCouncilML:HasAllItemsBeenAwarded()
	local moreItems = false
	for i = 1, #self.lootTable do
		if not self.lootTable[i].awarded then
			moreItems = true
		end
	end
	if moreItems then
		-- Continue? Or ?
	else
		RCLootCouncilML:EndSession()
	end
end

function RCLootCouncilML:EndSession()
	session = 1
	self.lootTable = {}
	addon:SendCommand("group", "message", L["The session has ended."])
	self.running = false
	addon.testMode = false
	self:CancelAllTimers()
	-- TODO add more to restart the whole thing
end

function RCLootCouncilML:ChangeResponse(session, name, response)
	self.lootTable[session].candidates[name].response = response
end

-- Initiates a session with the items handed
function RCLootCouncilML:Test(items)
	-- check if we're added in self.group
	-- (We might not be on solo test)
	if not tContains(self.candidates, addon.playerName) then
		local role = addon:GetCandidateRole(addon.playerName)
		self:AddCandidate(addon.playerName, addon.playerClass, role, addon.guildRank)
	end

	-- Add the items
	for session, iName in ipairs(items) do
		self:AddItem(session, iName, false, false)
	end
	--printtable(self.lootTable)
	if db.autoStart then -- Settings say go
		self:StartSession()
	else
		addon:CallModule("sessionFrame")
		addon:GetActiveModule("sessionFrame"):Show(self.lootTable)
	end
end

-- Returns false if we are ignoring the item
function RCLootCouncilML:IsItemIgnored(link)
	local itemID = tonumber(strmatch(link, "item:(%d+):")) -- extract itemID
	return not tContains(db.ignore, itemID)
end
