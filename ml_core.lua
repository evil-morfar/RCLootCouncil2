--[[	RCLootCouncil ml_core.lua	by Potdisc
	Contains core elements for the MasterLooter
	NOTE: Is implemented as a module for reasons...
		Although possible, this module shouldn't be replaced unless closely replicated as other default modules depend on it.

	TODO/NOTES:
		- Announce text for addon.db.awardReason (might need a better name)
		- Pool: Which reasons should be used with autoAward, and display announce message on autoAward?
		- SendMessage() on AddItem() to let userModules know it's safe to add to lootTable. Might have to do it other places too.
		- Alt-click looting should display the sessionframe if not already shown
		- Revision lootTable.announced
]]

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
RCLootCouncilML = addon:NewModule("RCLootCouncilML", "AceEvent-3.0", "AceBucket-3.0", "AceComm-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LibDialog = LibStub("LibDialog-1.0")

local db;
local session = 1

function RCLootCouncilML:OnInitialize()
	addon:Debug("ML initialized!")
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
		-- i = { iLink, winner }
	self.lootOpen = false -- is the ML lootWindow open or closed?
	self.running = false -- true if we're handling a session

	self:RegisterComm("RCLootCouncil", "OnCommReceived")
	self:RegisterEvent("LOOT_OPENED","OnEvent")
	self:RegisterEvent("LOOT_CLOSED","OnEvent")
	--self:RegisterEvent("RAID_INSTANCE_WELCOME","OnEvent")
	self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 20, "UpdateGroup") -- Bursts in group creation, and we should have plenty of time to handle it
	self:RegisterEvent("CHAT_MSG_WHISPER","OnEvent")
end

-- Adds an item session in lootTable
-- @param session The Session to add to
-- @param item Any: ItemID|itemString|itemLink
-- @param bagged True if the item is in the ML's inventory
-- @param slotIndex Index of the lootSlot, or nil if none
function RCLootCouncilML:AddItem(session, item, bagged, slotIndex)
	addon:DebugLog("ML:AddItem("..tostring(session)..", "..tostring(item)..", "..tostring(bagged)..", "..tostring(slotIndex)..")")
	local name, link, rarity, ilvl, iMinLevel, type, subType, iStackCount, equipLoc, texture = GetItemInfo(item)
	if not name then -- start a timer so we can add when item info is recieved -- NOTE should be redundant, as we'll never get an uncached item as ML (unless we're testing?)
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
		["name"]			= name,
		["link"]			= link,
		["ilvl"]			= ilvl,
		["type"]			= type,
		["subType"]		= subType,
		["equipLoc"]	= equipLoc,
		["texture"]		= texture,
		["boe"]			= addon:IsItemBoE(link),
		--["candidates"]	= {},
	};
end

-- Removes item (session) from self.lootTable
function RCLootCouncilML:RemoveItem(session)
	tremove(self.lootTable, session)
end

function RCLootCouncilML:AddCandidate(name, class, role, rank)
	addon:DebugLog("ML:AddCandidate("..name..", "..tostring(class)..", ...)")
	self.candidates[name] = {
		["class"]	= class,
		["role"]		= role,
		["rank"]		= rank or "", -- Rank cannot be nil for votingFrame
	}
end

function RCLootCouncilML:RemoveCandidate(name)
	self.candidates[name] = nil
end

-- IDEA This needs to work if one's not in a raid (if possible)
function RCLootCouncilML:UpdateGroup()
	local group_copy = {}
	for name, _ in pairs(self.candidates) do	group_copy[name] = name end -- Use name as index for zzz
	for i = 1, GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i)
		if group_copy[name] then	-- If they're already registered
			group_copy[name] = nil	-- remove them from the check  -- REVIEW not 100% this will work as intended
		else -- add them
			addon:SendCommand(name, "playerInfoRequest")
			addon:SendCommand(name, "MLdb", addon.mldb) -- and send mlDB
			self:AddCandidate(name) -- Add them in case they haven't installed the adoon
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
		addon:SendCommand("group", "council", addon.council) -- IDEA only send council if there's changes, since it's send once a ML is detected
		addon:SendCommand("group", "candidates", self.candidates) -- IDEA Same as above


		addon:SendCommand("group", "lootTable", self.lootTable)

		if db.announceItems then self:AnnounceItems() end
		-- Start a timer to set response as offline/not installed unless we receive an ack
		self:ScheduleTimer("Timer", 10, "LootSend")

		-- Finally call the voting frame
		--addon:CallModule("votingframe")
		--addon:GetActiveModule("votingframe"):Setup(self.lootTable)
	else
		addon:Debug("called while running a session!")
	end
end


function RCLootCouncilML:MLdbCheck()
	-- IDEA we shouldn't have to send a check, just send it when it's created, and then send it again if we update it
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
		v					= math.random(100), -- generate new mldb version
		selfVote			= db.selfVote,
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
		addon:SendCommand("group", "council", db.council)
	end
end

function RCLootCouncilML:ShouldAutoAward(item, quality)
	if db.autoAward and quality >= db.autoAwardLowerThreshold and quality <= db.autoAwardUpperThreshold then
		if db.autoAwardLowerThreshold >= GetLootThreshold() then
			if UnitInRaid(db.autoAwardTo) then -- TEST perhaps use self.group?
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
	if event == "LOOT_OPENED" then -- IDEA Check if event LOOT_READY is useful here (also check GetLootInfo() for this)
		self.lootOpen = true
		if not InCombatLockdown() then -- TODO do something with looting in combat
			if addon.isMasterLooter and GetNumLootItems() > 0 then
				addon.target = GetUnitName("target") or "Unknown/Chest" -- capture the boss name
				for i = 1, GetNumLootItems() do
					if db.altClickLooting then self:HookLootButton(i) end -- hook the buttons
					local _, _, quantity, quality = GetLootSlotInfo(i)
					local item = GetLootSlotLink(i)
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
						addon:CallModule("sessionframe")
						addon:GetActiveModule("sessionframe"):Show(self.lootTable)
					end
				end
			end
		else
			self:Print(L["You can't start a loot session while in combat."])
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

function RCLootCouncilML:CanWeLootItem(item, index, quality)
	--TODO LootSlotHasItem doesn't work for this purpose
	if (LootSlotHasItem(index) or db.autoLootEverything) and quality >= GetLootThreshold() and not self:IsItemIgnored(item) then -- it's something we're allowed to loot
		-- Let's check if it's BoE
		-- Don't bother checking if we know we want to loot it
		return db.autolootBoE or addon:IsItemBoE(item)
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
--@param reason
--@param winner		Nil/false if items should be stored in inventory and awarded later
function RCLootCouncilML:Award(session, reason, winner)
	-- Start by determining if we should award the item now or just store it in our bags
	if winner then
		--  give out the loot or store the result, i.e. bagged or not
		if self.lootTable[session].bagged then   -- indirect mode (the item is in a bag)
			-- Add to the list of awarded items in MLs bags
			tinsert(self.lootInBags, {addon.lootList[session].itemid, winner})

		else -- Direct (we can award from a WoW loot list)
			if not self.lootTable[session].lootSlot then
				return addon:SessionError("Session "..session.. "didn't have lootSlot")
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
						break
					end
				end
			end
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
		if db.enableHistory or db.sendHistory then -- log it
			self:TrackAndLogLoot(winner, self.lootTable[session].itemid, self.lootTable[session].candidates[winner].response, addon.target, self.lootTable[session].candidates[winner].votes, self.lootTable[session].candidates[winner].gear1, self.lootTable[session].candidates[winner].gear2)
		end
		self:HasAllItemsBeenAwarded() -- REVIEW might not be the best place for it
	else -- Store in bags
		if not self.lootTable[session].lootSlot then return addon:SessionError("Session "..session.. "didn't have lootSlot") end
		LootSlot(self.lootTable[session].lootSlot) -- take the item
		tinsert(self.lootInBags, {self.lootTable[session].link, winner}) -- and store data
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
	if (db.enableHistory or db.sendHistory) and db.awardReasons[reason].log then -- only track and log if allowed
		self:TrackAndLogLoot(name, item, reason, boss, 0, nil, nil, db.autoAwardReasons[reason].text, db.autoAwardReasons[reason].color)
	end

end

function RCLootCouncilML:TrackAndLogLoot(name, item, response, boss, votes, itemReplaced1, itemReplaced2, reason, color)
	local instanceName, _, _, difficultyName = GetInstanceInfo()
	local table = {["lootWon"] = item, ["date"] = date("%d/%m/%y"), ["time"] = date("%H:%M:%S"), ["instance"] = instanceName.." "..difficultyName,
		["boss"] = boss, ["votes"] = votes, ["itemReplaced1"] = itemReplaced1, ["itemReplaced2"] = itemReplaced2, ["response"] = response,
		["reason"] = reason or db.responses[response].text, ["color"] = color or db.responses[response].color}
	if db.sendHistory then -- Send it, and let comms handle the logging
		addon:SendCommand("group", "history", name, table)
	elseif db.enableHistory then -- Just log it
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
	addon:DebugLog("ML:EndSession()")
	session = 1
	self.lootTable = {}
	addon:SendCommand("group", "session_end")
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
	if db.autoStart then -- Settings say go
		self:StartSession()
	else
		addon:CallModule("sessionframe")
		addon:GetActiveModule("sessionframe"):Show(self.lootTable)
	end
end

-- Returns true if we are ignoring the item
function RCLootCouncilML:IsItemIgnored(link)
	local itemID = tonumber(strmatch(link, "item:(%d+):")) -- extract itemID
	return tContains(db.ignore, itemID)
end

function RCLootCouncilML:GetItemsFromMessage(msg, sender)
	addon:DebugLog("GetItemsFromMessage("..tostring(msg)..", "..tostring(sender)..")")
	if not addon.isMasterLooter then return end

	local ses, arg1, arg2, arg3 = addon:GetArgs(msg, 4) -- We only require session to be correct, we can do some error checking on the rest
	ses = tonumber(ses)
	-- Let's test the input
	if not ses or type(ses) ~= "number" or ses > #self.lootTable then return end -- We need a valid session
	-- Set some locals
	local item1, item2, diff
	local response = 1
	if arg1:find("|Hitem:") then -- they didn't give a response
		item1, item2 = arg1, arg2
	else
		-- No reason to continue if they didn't provide an item
		if not arg2 or not arg2:find("|Hitem:") then return end
		item1, item2 = arg2, arg3

		-- check if the response is valid
		local whisperKeys = {}
		for i = 1, db.numButtons do --go through all the button
			gsub(db.buttons[i]["whisperKey"], '[%w]+', function(x) tinsert(whisperKeys, {key = x, num = i}) end) -- extract the whisperKeys to a table
		end
		for _,v in ipairs(whisperKeys) do
			if strmatch(arg1, v.key) then -- if we found a match
				response = v.num
				break;
			end
		end
	end
	-- calculate diff
	diff = (self.lootTable[ses].ilvl - select(4, GetItemInfo(item1))) or nil
	-- add the entry to the player's own entryTable
	local toAdd =  {
	session = ses,
	name = sender,
	data = {
			gear1 = item1,
			gear2 = item2,
			diff = diff,
			note = "",
			response = response
		}
	}
	addon:SendCommand("group", "response", toAdd)
	-- Let people know we've done stuff
	addon:Print(format(L["Item received and added from %s."], addon.Ambiguate(sender)))
	SendChatMessage("[RCLootCouncil]: "..format(L["Acknowledged as \" %s \""], db.responses[response].text ), "WHISPER", nil, sender)
end

function RCLootCouncilML:SendWhisperHelp(target)
	addon:DebugLog("SendWhisperHelp("..tostring(target)..")")
	local msg
	SendChatMessage(L["whisper_guide"], "WHISPER", nil, target)
	for i = 1, db.numButtons do
		msg = "[RCLootCouncil]: "..db.buttons[i]["text"]..":  " -- i.e. MainSpec/Need:
		msg = msg..""..db.buttons[i]["whisperKey"].."." -- need, mainspec, etc
		SendChatMessage(msg, "WHISPER", nil, target)
	end
	SendChatMessage(L["whisper_guide2"], "WHISPER", nil, target)
	addon:Print(format(L["sent whisper help to %s"], addon.Ambiguate(target)))
end

--------ML Popups ------------------
LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_ABORT", {
	text = L["Are you sure you want to abort?"],
	buttons = {
		{	text = L["Yes"],
			on_click = function(self)
				RCLootCouncilML:EndSession()
				addon:GetActiveModule("votingframe"):Disable()
				CloseLoot() -- close the lootlist
			end,
		},
		{	text = L["No"],
		},
	},
	hide_on_escape = true,
	show_while_dead = true,
})
LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_AWARD", {
	text = "something_went_wrong",
	icon = "",
	on_show = function(self, data)
		local item, player, texture = unpack(data)
		self.text:SetText(format(L["Are you sure you want to give #item to #player?"], item, player))
		self.icon:SetTexture(texture)
	end,
	buttons = {
		{	text = L["Yes"],
			on_click = function(self)
				addon:Print("Item awarded!")
				-- TODO make award
				-- addon:GetActiveModule("masterlooter"):Award(session)
			end,
		},
		{	text = L["No"],
		},
	},
	hide_on_escape = true,
	show_while_dead = true,
})
