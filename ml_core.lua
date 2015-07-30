--[[	RCLootCouncil ml_core.lua	by Potdisc
	Contains core elements for the MasterLooter
	-	Although possible, this module shouldn't be replaced unless closely replicated as other default modules depend on it.

	TODO/NOTES:
		- SendMessage() on AddItem() to let userModules know it's safe to add to lootTable. Might have to do it other places too.
		- Revision lootTable.announced
]]

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
RCLootCouncilML = addon:NewModule("RCLootCouncilML", "AceEvent-3.0", "AceBucket-3.0", "AceComm-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LibDialog = LibStub("LibDialog-1.0")

local db;
--local session = 1

function RCLootCouncilML:OnInitialize()
	addon:Debug("ML initialized!")
end

function RCLootCouncilML:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()
	self:UnregisterAllComm()
	self:UnregisterAllMessages()
	self:UnHookAll()
end

function RCLootCouncilML:OnEnable()
	db = addon:Getdb()
	self.candidates = {} -- candidateName = { class, role, rank }
	self.lootTable = {} -- The MLs operating lootTable
	-- self.lootTable[session] = {	bagged, lootSlot, announced, awarded, name, link, ilvl, type, subType, equipLoc, texture, boe	}
	self.awardedInBags = {} -- Awarded items that are stored in MLs inventory
									-- i = { link, winner }
	self.lootInBags = {} 	-- Items not yet awarded but stored in bags
	self.lootOpen = false 	-- is the ML lootWindow open or closed?
	self.running = false		-- true if we're handling a session

	self:RegisterComm("RCLootCouncil", "OnCommReceived")
	self:RegisterEvent("LOOT_OPENED","OnEvent")
	self:RegisterEvent("LOOT_CLOSED","OnEvent")
	--self:RegisterEvent("RAID_INSTANCE_WELCOME","OnEvent")
	self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 20, "UpdateGroup") -- Bursts in group creation, and we should have plenty of time to handle it
	self:RegisterEvent("CHAT_MSG_WHISPER","OnEvent")
	self:RegisterBucketMessage("RCConfigTableChanged", 2, "ConfigTableChanged") -- The messages can burst
	self:RegisterMessage("RCCouncilChanged", "CouncilChanged")
end

-- Adds an item session in lootTable
-- @param session The Session to add to
-- @param item Any: ItemID|itemString|itemLink
-- @param bagged True if the item is in the ML's inventory
-- @param slotIndex Index of the lootSlot, or nil if none
function RCLootCouncilML:AddItem(item, bagged, slotIndex)
	addon:DebugLog("ML:AddItem", item, bagged, slotIndex)
	local name, link, rarity, ilvl, iMinLevel, type, subType, iStackCount, equipLoc, texture = GetItemInfo(item)
	if not name then -- start a timer so we can add when item info is recieved -- NOTE should be redundant, as we'll never get an uncached item as ML (unless we're testing?)
		self:ScheduleTimer("Timer", 1, "AddItem", item, bagged, slotIndex)
		addon:Debug("Started timer:", "AddItem")
		return
	end
	--self.lootTable[session] = {} -- wipe it
	tinsert(self.lootTable, {
		["bagged"]		= bagged,
		["lootSlot"]	= slotIndex,
		["announced"]	= false,
		["awarded"]		= false,
		["name"]			= name,
		["link"]			= link,
		["ilvl"]			= ilvl,
		--["type"]			= type, -- Prolly not needed
		["subType"]		= subType,
		["equipLoc"]	= equipLoc,
		["texture"]		= texture,
		["boe"]			= addon:IsItemBoE(link),
	})
end

-- Removes item (session) from self.lootTable
function RCLootCouncilML:RemoveItem(session)
	tremove(self.lootTable, session)
end

function RCLootCouncilML:AddCandidate(name, class, role, rank)
	addon:DebugLog("ML:AddCandidate",name, class, role, rank)
	self.candidates[name] = {
		["class"]	= class,
		["role"]		= role,
		["rank"]		= rank or "", -- Rank cannot be nil for votingFrame
	}
end

function RCLootCouncilML:RemoveCandidate(name)
	self.candidates[name] = nil
end

-- IDEA This needs to work if one's not in a raid (if possible) -- edit: OR do it?
function RCLootCouncilML:UpdateGroup()
	local group_copy = {}
	local updates = false
	for name, _ in pairs(self.candidates) do	group_copy[name] = name end -- Use name as index for zzz
	for i = 1, GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i)
		if group_copy[name] then	-- If they're already registered
			group_copy[name] = nil	-- remove them from the check  -- REVIEW not 100% this will work as intended
		else -- add them
			addon:SendCommand(name, "playerInfoRequest")
			addon:SendCommand(name, "MLdb", addon.mldb) -- and send mlDB
			self:AddCandidate(name) -- Add them in case they haven't installed the adoon
			updates = true
		end
	end
	-- If anything's left in group_copy it means they left the raid, so lets remove them
	for _, name in pairs(group_copy) do
		if name then self:RemoveCandidate(name); updates = true end
	end
	if updates then addon:SendCommand("group", "candidates", self.candidates) end
end

function RCLootCouncilML:StartSession()
	addon:Debug("ML:StartSession()")
	--if not self.running then
		self.running = true

		addon:SendCommand("group", "lootTable", self.lootTable)

		if db.announceItems then self:AnnounceItems() end
		-- Start a timer to set response as offline/not installed unless we receive an ack
		self:ScheduleTimer("Timer", 10, "LootSend")
	--else
		--addon:Debug("called while running a session!")
	--end
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
	addon:SendCommand("group", "council", db.council)
end

function RCLootCouncilML:UpdateMLdb()
	-- The db has changed, so update the mldb and send the changes
	addon:Debug("UpdateMLdb")
	addon.mldb = self:BuildMLdb()
	addon:SendCommand("group", "MLdb", addon.mldb)
end

function RCLootCouncilML:BuildMLdb()
	-- Extract changes to addon.responses
	local changedResponses = {};
	for i = 1, db.numButtons do
		if db.responses[i].text ~= addon.responses[i].text or unpack(db.responses[i].color) ~= unpack(addon.responses[i].color) then
			changedResponses[i] = db.responses[i]
		end
	end
	-- Extract changed buttons
	local changedButtons = {};
	for i = 1, db.numButtons do
		if db.buttons[i].text ~= addon.defaults.profile.buttons[i].text then
			changedButtons[i] = db.buttons[i]
		end
	end
	-- Extract changed award reasons
	local changedAwardReasons = {}
	for i = 1, db.numAwardReasons do
		if db.awardReasons[i].text ~= addon.defaults.profile.awardReasons[i].text then
			changedAwardReasons[i] = db.awardReasons[i]
		end
	end
	return {
		selfVote			= db.selfVote,
		multiVote		= db.multiVote,
		anonymousVoting = db.anonymousVoting,
		allowNotes		= db.allowNotes,
		numButtons		= db.numButtons,
		hideVotes		= db.hideVotes,
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
		self:UpdateMLdb() -- Will build and send mldb
		addon:SendCommand("group", "council", db.council)
		-- Send out self.candidates in 10 secs, should be plenty of time for people to respond on "playerInfoRequest"
		self:ScheduleTimer("Timer", 10, "GroupUpdate")
	else
		self:Disable() -- We don't want to use this if we're not the ML
	end
end

function RCLootCouncilML:ShouldAutoAward(item, quality)
	if db.autoAward and quality >= db.autoAwardLowerThreshold and quality <= db.autoAwardUpperThreshold then
		if db.autoAwardLowerThreshold >= GetLootThreshold() then
			if UnitInRaid(db.autoAwardTo) then -- TEST perhaps use self.group?
				return true;
			else
				addon:Print(L["Cannot autoaward:"])
				addon:Print(format(L["Could not find 'player' in the raid."], db.AutoAwardTo))
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

	elseif type == "GroupUpdate" then
		addon:SendCommand("group", "candidates", self.candidates)
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
			end
		else
			addon:Debug("Error in deserializing ML comm: ", command)
		end
	end
end

function RCLootCouncilML:OnEvent(event, ...)
	addon:DebugLog("ML event", event)
	if event == "LOOT_OPENED" then -- IDEA Check if event LOOT_READY is useful here (also check GetLootInfo() for this)
		self.lootOpen = true
		if not InCombatLockdown() then
			if addon.isMasterLooter and GetNumLootItems() > 0 then
				-- We have reopened the loot frame if we're running at this point
				if self.running then return end
				addon.target = GetUnitName("target") or "Unknown/Chest" -- capture the boss name
				for i = 1, GetNumLootItems() do
					if db.altClickLooting then self:ScheduleTimer("HookLootButton", 0.5, i) end -- Delay lootbutton hooking to ensure other addons have had time to build their frames
					local _, _, quantity, quality = GetLootSlotInfo(i)
					local item = GetLootSlotLink(i)
					if self:ShouldAutoAward(item, quality) and quantity > 0 then
						self:AutoAward(i, item, db.autoAwardTo, db.autoAwardReason, addon.target)

					elseif self:CanWeLootItem(item, quality) and quantity > 0 then -- check if our options allows us to loot it
						self:AddItem(item, false, i)

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

function RCLootCouncilML:CanWeLootItem(item, quality)
	if db.autoLoot and (IsEquippableItem(item) or db.autoLootEverything) and quality >= GetLootThreshold() and not self:IsItemIgnored(item) then -- it's something we're allowed to loot
		-- Let's check if it's BoE
		-- Don't bother checking if we know we want to loot it
		return db.autolootBoE or not addon:IsItemBoE(item)
	end
	return false
end

function RCLootCouncilML:HookLootButton(i)
	addon:DebugLog("ML:HookLootButton("..tostring(i)..")")
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

function RCLootCouncilML:AnnounceItems()
	addon:DebugLog("ML:AnnounceItems()")
	SendChatMessage(db.announceText, db.announceChannel)
	for k,v in ipairs(self.lootTable) do
		SendChatMessage(k .. ": " .. v.link, db.announceChannel)
	end
end


--@param session	The session to award
--@param winner	Nil/false if items should be stored in inventory and awarded later
--@param response	The candidates response, index in db.responses
--@param reason	Entry in db.awardReasons
--@returns True if awarded successfully
function RCLootCouncilML:Award(session, winner, response, reason)
	if addon.testMode then
		if winner then
			addon:SendCommand("group", "awarded", session)
			addon:Print(format(L["The item would now be awarded to 'player'"], addon.Ambiguate(winner)))
			self.lootTable[session].awarded = true
			if self:HasAllItemsBeenAwarded() then
				 addon:Print(L["All items has been awarded and  the loot session concluded"])
				 self:EndSession()
			end
		end
		return true
	end
	-- Determine if we should award the item now or just store it in our bags
	if winner then
		--  give out the loot or store the result, i.e. bagged or not
		if self.lootTable[session].bagged then   -- indirect mode (the item is in a bag)
			-- Add to the list of awarded items in MLs bags, and remove it from lootInBags
			tinsert(self.awardedInBags, {link = self.lootTable[session].link, winner = winner})
			tremove(self.lootInBags, session)

		else -- Direct (we can award from a WoW loot list)
			if not self.lootTable[session].lootSlot then
				addon:SessionError("Session "..session.." didn't have lootSlot (award)")
				return false
			end
			if not self.lootOpen then -- we can't give out loot without the loot window open
				addon:Print(L["Unable to give out loot without the loot window open."])
				addon:Print(L["Alternatively, flag the loot as award later."])
				return false
			end
			if addon:UnitIsUnit(winner, "player") then -- give it to the player
				LootSlot(self.lootTable[session].lootSlot)
			else
				for i = 1, GetNumGroupMembers() do
					if addon:UnitIsUnit(GetMasterLootCandidate(i), winner) then
						GiveMasterLoot(self.lootTable[session].lootSlot, i)
						break
					end
				end
			end
		end

		-- flag the item as awarded and update
		addon:SendCommand("group", "awarded", session)
		self.lootTable[session].awarded = true -- No need to let Comms handle this
		-- IDEA Switch session ?

		self:AnnounceAward(addon.Ambiguate(winner), self.lootTable[session].link, reason and reason.text or db.responses[response].text)

		if self:HasAllItemsBeenAwarded() then self:EndSession() end -- REVIEW might not be the best place for it
	else -- Store in bags and award later
		if not self.lootTable[session].lootSlot then return addon:SessionError("Session "..session.. " didn't have lootSlot (store in bags)") end
		if not self.lootOpen then return addon:Print(L["Unable to give out loot without the loot window open."]) end
		LootSlot(self.lootTable[session].lootSlot) -- take the item
		tinsert(self.lootInBags, self.lootTable[session].link) -- and store data
		return false -- Item hasn't been awarded
	end
	return true
end

function RCLootCouncilML:AnnounceAward(name, link, text)
	if db.announceAward then
		for k,v in pairs(db.awardText) do
			if v.channel ~= "NONE" then
				local message = gsub(v.text, "&p", name)
				message = gsub(message, "&i", link)
				message = gsub(message, "&r", text)
				SendChatMessage(message, v.channel)
			end
		end
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
	self:Print(format(L["Auto awarded 'item'"], item))
	self:AnnounceAward(addon.Ambiguate(name), item, db.awardReasons[reason].text)
	self:TrackAndLogLoot(name, item, reason, boss, 0, nil, nil, db.awardReasons[reason])
end

function RCLootCouncilML:TrackAndLogLoot(name, item, response, boss, votes, itemReplaced1, itemReplaced2, reason)
	if reason and not reason.log then return end -- Reason says don't log
	if not (db.sendHistory and db.enableHistory) then return end -- No reason to do stuff when we won't use it
	local instanceName, _, _, difficultyName = GetInstanceInfo()
	local table = {["lootWon"] = item, ["date"] = date("%d/%m/%y"), ["time"] = date("%H:%M:%S"), ["instance"] = instanceName.." "..difficultyName,
		["boss"] = boss, ["votes"] = votes, ["itemReplaced1"] = itemReplaced1, ["itemReplaced2"] = itemReplaced2, ["response"] = response,
		["reason"] = reason and reason.text or db.responses[response].text, ["color"] = reason and reason.color or db.responses[response].color}
	if db.sendHistory then -- Send it, and let comms handle the logging
		addon:SendCommand("group", "history", name, table)
	elseif db.enableHistory then -- Just log it
		addon:SendCommand("player", "history", name, table)
	end
	table = {}
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
	--session = 1
	self.lootTable = {}
	addon:SendCommand("group", "session_end")
	self.running = false
	self:CancelAllTimers()
	addon.testMode = false
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
	-- We must send candidates now, since we can't wait the normal 10 secs
	addon:SendCommand("group", "candidates", self.candidates)
	-- Add the items
	for session, iName in ipairs(items) do
		self:AddItem(iName, false, false)
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
	addon:Debug("GetItemsFromMessage()", msg, sender)
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
		addon:Print(format(L["Item received and added from 'player'"], addon.Ambiguate(sender)))
	SendChatMessage("[RCLootCouncil]: "..format(L["Acknowledged as 'response'"], db.responses[response].text ), "WHISPER", nil, sender)
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

--------ML Popups ------------------
LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_ABORT", {
	text = L["Are you sure you want to abort?"],
	buttons = {
		{	text = L["Yes"],
			on_click = function(self)
				CloseLoot() -- close the lootlist
				RCLootCouncilML:EndSession()
				addon:GetActiveModule("votingframe"):EndSession(true)
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
		local session, player = unpack(data)
		self.text:SetText(format(L["Are you sure you want to give #item to #player?"], RCLootCouncilML.lootTable[session].link, addon.Ambiguate(player)))
		self.icon:SetTexture(RCLootCouncilML.lootTable[session].texture)
	end,
	buttons = {
		{	text = L["Yes"],
			on_click = function(self, data)
				-- IDEA Perhaps come up with a better way of handling this
				local session, player, response, reason, votes, item1, item2 = unpack(data)
				local awarded = RCLootCouncilML:Award(session, player, response, reason)
				if awarded then -- log it
					RCLootCouncilML:TrackAndLogLoot(name, item, response, addon.target, votes, item1, item2, reason)
				end
			end,
		},
		{	text = L["No"],
		},
	},
	hide_on_escape = true,
	show_while_dead = true,
})
