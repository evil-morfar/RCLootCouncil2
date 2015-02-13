--[[	RCLootCouncil ml_core.lua	by Potdisc
	Contains core elements for the MasterLooter
	NOTE: Is implemented as a module for reasons...
		Although possible, this module shouldn't be replaced unless closely replicated as other default modules depend on it.
	
	TODO/NOTES:
		- Announce text for addon.db.awardReason (might need a better name)
		- Pool: Which reasons should be used with autoAward, and display announce message on autoAward?
		- SessionFrame should take lootTable and add/remove new/unneeded sessions
		- SendMessage() on AddItem() to let userModules know it's safe to add to lootTable. Might have to do it other places too.
		- It might be smarter just to have a ["candidates"] = {[playername]={}}  in loottable instead of the current "playername"
		- Do we really need 2 comm channels? Most stuff are meant for people other than the ML. 
]]

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
RCLootCouncilML = addon:NewModule("RCLootCouncilML", "AceEvent-3.0", "AceBucket-3.0", "AceComm-3.0", "AceTimer-3.0")
local LibDialog = LibStub("LibDialog-1.0")

local db;
local session = 1 

function RCLootCouncilML:OnEnable()
	db = addon:Getdb()
	self.group = {} -- candidateName = { class, role, rank }
	self.lootTable = {} -- The MLs operating lootTable - addon.lootTable is used for visuals
	--[[ self.lootTable[session] = { 
		bagged, lootSlot, announced, awarded, name, link, lvl, type, subType, equipLoc, texture
		
		[playerName] = { 
			rank, role, totalIlvl, response, gear1, gear2, votes, class, haveVoted, voters[], note 	
		},	
	}
	]]
	self.lootInBags = {} -- Awarded items that are stored in MLs inventory
		-- i = { itemName, winner }
	self.lootOpen = false -- is the ML lootWindow open or closed?
	self.running = false -- true if we're handling a session

	self:RegisterComm("RCLootCouncil_ML")
	self:RegisterEvent("LOOT_OPENED","OnEvent")
	self:RegisterEvent("LOOT_CLOSED","OnEvent")
	self:RegisterEvent("RAID_INSTANCE_WELCOME","OnEvent")
	self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 20, "UpdateGroup") -- Bursts in group creation, and we should have plenty of time to handle it
	self:RegisterEvent("CHAT_MSG_WHISPER","OnEvent")
	self:RegisterEvent("CHAT_MSG_RAID","OnEvent")

	--------ML Popups ------------------
	LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_ABORT", {
		text = "Are you sure you want to abort?",
		buttons = {
			{	text = "yes",
				on_click = function(self)
				--TODO
					RCLootCouncil_Mainframe.abortLooting()
					RCLootCouncil:SendCommMessage("RCLootCouncil", "stop", "RAID") -- tell the council to abort aswell
					RCLootCouncil_Mainframe.stopLooting()
					CloseButton_OnClick() -- close the frame
					CloseLoot() -- close the lootlist
				end,	
			},
			{	text = "no",
				-- TODO check if a on_click function is needed
			},
		},
		hide_on_escape = true,
		show_while_dead = true,	
	})
	LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_AWARD", {
		text = "Are you sure you want to give %s to %s?",
		buttons = {
			{	text = "Yes",
				on_click = function(self)
					RCLootCouncil_Mainframe.award() -- TODO
				end,			
			},
			{	text = "No",
				-- TODO check if requires function
			},
		},
		hide_on_escape = true,
		show_while_dead = true,	
	})

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
	self.lootTable[session] = {} -- wipe it
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
	};
	-- init candidates for the item
	for name, _ in pairs(self.group) do
		self:InitCandidate(session, name, "NOTANNOUNCED")
	end	
end

-- Removes item (session) from self.lootTable
function RCLootCouncilML:RemoveItem(session)
	tremove(self.lootTable, session)
end

-- Setup initial data on a candidate in LootTable
function RCLootCouncilML:InitCandidate(session, name, response)
	self.lootTable[session][name] = {} -- wipe
	self.lootTable[session][name] = {
		["rank"]		= self.group[name].rank or "",
		["role"]		= self.group[name].role or "",
		["totalIlvl"]	= nil,
		["response"]	= response,
		["gear1"]		= nil,
		["gear2"]		= nil,
		["votes"]		= 0,
		["class"]		= self.group[name].class or "",
		["haveVoted"]	= false,
		["voters"]		= {},
		["note"]		= nil,
	};
end

function RCLootCouncilML:AddToGroup(name, class, role, rank)
	addon:DebugLog("ML:AddToGroup("..name..", ...)")
	self.group[name] = {
		["class"]	= class,
		["role"]	= role,
		["rank"]	= rank,
	}
end

function RCLootCouncilML:RemoveFromGroup(name)
	self.group[name] = nil
end

function RCLootCouncilML:UpdateGroup()
	local group_copy = {}
	for name, _ in pairs(self.group) do	group_copy[name] = name end -- Use name as index for zzz
	for i = 1, GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i)
		if group_copy[name] then
			group_copy[name] = nil -- remove them if they're registered and in the raid -- TODO not 100% this will work as intended
		else
			self:SendCommand(name, "playerInfoRequest") -- add them otherwise
			self:SendCommand(name, "MLdb", addon.mldb) -- and send mlDB
		end
	end
	-- If anything's left in group_copy it means they left the raid, so lets remove them
	for _, name in pairs(group_copy) do
		if name then self:RemoveFromGroup(name) end
	end
end

function RCLootCouncilML:StartSession()
	addon:Debug("ML:StartSession()")
	if not self.running then
		self.running = true
		self:SendCommand("raid", "council", addon.council) -- TODO only send council if there's changes, since it's send once a ML is detected
		-- update the session to be announced 
		--for session = 1, #self.lootTable do
		--	self.lootTable[session].announced = true
		--	for name, _ in pairs(self.lootTable[session]) do
		--		if self.lootTable[session][name]["response"] then self.lootTable[session][name].response = "ANNOUNCED" end
		--	end				
		--end
		self:MLdbCheck() -- check if we need to build mldb or anyone have an outdated version
		self:SendCommand("raid", "lootTable", self.lootTable)
		
		if db.announceItems then self:AnnounceItems() end
		-- Start a timer to set response as offline/not installed unless we receive an ack
		self:ScheduleTimer("Timer", 5, "LootSend")

		-- Finally call the voting frame
		addon:CallModule("votingFrame")
		addon:GetActiveModule("votingFrame"):Setup(self.lootTable)
		
	else
		addon:Debug("called while running a session!")
	end
end

function RCLootCouncilML:MLdbCheck()
	-- TODO we shouldn't have to send a check, just send it when it's created, and then send it again if we update it
	if addon.mldb.v then
		self:SendCommand("raid", "MLdb_check", addon.mldb.v)
	else
		addon.mldb = self:BuildMLdb()
		self:SendCommand("raid", "MLdb", addon.mldb)
	end
end

function RCLootCouncilML:BuildMLdb()
	-- Extract changes to addon.responses
	local changedResponses = {};
	for i,v in ipairs(db.responses) do
		if v ~= addon.responses[i] then
			changedResponses[i] = v
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
		buttons			= db.buttons, --TODO Do we want to send all buttons, or extract like responses?
		awardReasons	= db.awardReasons,
		observe			= db.observe,
		responses		= changedResponses,
	}
end

function RCLootCouncilML:NewML(newML)
	if addon:UnitIsUnit(newML, "player") then -- we are the the ML
		addon:DebugLog("ML:NewML()")
		self:SendCommand("raid", "playerInfoRequest")
		addon.mldb = self:BuildMLdb()
		self:SendCommand("raid", "council", addon.Council)
	end
end

function RCLootCouncilML:ShouldAutoAward(item, quality)
	if db.autoAward and quality >= db.autoAwardLowerThreshold and quality <= db.autoAwardUpperThreshold then
		if db.autoAwardLowerThreshold >= GetLootThreshold() then
			if UnitInRaid(db.autoAwardTo) then -- TODO perhaps use self.group?
				return true;
			else
				addon:Print("Cannot autoaward:")
				addon:Print("Could not find ".. db.AutoAwardTo .. " in the raid.")
			end
		else
			addon:Print("Could not Auto Award ".. item .." because the Loot Threshold is too high!")
		end
	end
	return false
end

function RCLootCouncilML:Timer(type, ...)
	addon:Debug("Timer: "..type.." passed.")
	if type == "AddItem" then 
		self:AddItem(...)
	elseif type == "LootSend" then
		for session = 1, #self.lootTable do
			for name,t in pairs(self.lootTable[session]) do
				if t.response == "ANNOUNCED" then 
					addon:SendCommand("raid", "change_response", session, name, "NOTHING")
				end
			end
		end	
	end
end

function RCLootCouncilML:SendCommand(target, command, ...)
	if addon.soloMode then return; end
	-- send all data as a table, and let receiver unpack it
	local toSend = addon:Serialize(command, {...})

	if target == "raid" then
		self:SendCommMessage("RCLootCouncil", toSend, "RAID")
	else
		if addon:UnitIsUnit(target,"player") then
			addon:OnCommReceived("RCLootCouncil", toSend, "WHISPER", target)
		else
			self:SendCommMessage("RCLootCouncil", toSend, "WHISPER", target)
		end
	end
end

function RCLootCouncilML:OnCommRecevied(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncilML" then
		addon:Debug("MLComm received from: "..sender..": "..serializedMsg)
		-- data is always a table
		local test, command, data = addon:Deserialize(serializedMsg)

		if test then
			if command == "vote" then -- we might not need to do unit checks
				for k,v in pairs(addon.council) do
					if addon:UnitIsUnit(v,sender) or addon:UnitIsUnit(sender,addon.masterLooter) then -- It was really a councilmember
						self:HandleVote(unpack(data))
						return
					end
				end
				addon:Print(sender.." tried to hack the voting!")
				
			elseif command == "change_response" then 
				self:ChangeResponse(unpack(data))
			
			elseif command == "remove" then
				self:RemoveCandidate(unpack(data))

			elseif command == "lootAck" then
				local session = data[1]
				addon.lootList[session][sender].response = "WAIT"

			elseif command == "playerInfo" and addon.isMasterLooter then -- only ML should receive playerInfo
				self:AddToGroup(unpack(data))
			
			elseif command == "awarded" then
				local i = data[1]
				addon.lootList[i].awarded = true
				self:Update()

			elseif command == "MLdb_request" and addon.isMasterLooter then
				self:SendCommand(sender, "MLdb", addon.mldb)
				
			elseif command == "response" then
				local t = data[1]
				addon.lootList[t.session][t.name].totalIlvl = t.ilvl
				addon.lootList[t.session][t.name].gear1 = t.gear1
				addon.lootList[t.session][t.name].gear2 = t.gear2
				addon.lootList[t.session][t.name].note = t.note
				addon.lootList[t.session][t.name].response = t.response
				self:Update() --TODO
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
				self:Print("You can't start a loot session while in combat.")
			end			
		end
	elseif event == "LOOT_CLOSED" then
		self.lootOpen = false
	
	end
end

function RCLootCouncilML:CanWeLootItem(item, index, quality)
	--TODO LootSlotHasItem doesn't work for this purpose
	if (LootSlotHasItem(index) or db.autoLootEverything) and quality >= GetLootThreshold() then -- it's something we're allowed to loot
		-- Let's check if it's BoE
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
				addon:Print("Unable to give out loot without the loot window open.")
				addon:Print("Alternatively, flag the loot as award later.")
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
		addon:SendCommand("raid", "awarded", session)
		RCLootCouncilML:Update()

		if db.announceAward then
			-- TODO insert announce text if awarded by addon.db.awardReason
			for k,v in pairs(db.awardText) do
				if v.channel ~= "NONE" then
					local message = gsub(v.text, "&p", addon:Ambiguate(winner))
					message = gsub(message, "&i", addon.lootList[session].link)
					SendChatMessage(message, v.channel)
				end
			end
		end
		if db.enableHistory then -- log it
			self:TrackAndLogLoot(winner, self.lootTable[session].itemid, self.lootTable[session][winner].response, addon.target,self.lootTable[session][winner].votes, self.lootTable[session][winner].gear1, self.lootTable[session][winner].gear2)
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
	self:Print(item.." was Auto Awarded to "..addon:Ambiguate(name).. " with the reason "..reason)
	if db.enableHistory and db.awardReasons[reason].log then -- only track and log if allowed
		RCLootCouncilML:TrackAndLogLoot(name, item, reason, boss, 0, nil, nil, db.autoAwardReasons[reason].text, db.autoAwardReasons[reason].color)
	end
		
end

function RCLootCouncilML:TrackAndLogLoot(name, item, response, boss, votes, itemReplaced1, itemReplaced2, reason, color)
	local instanceName, _, _, difficultyName = GetInstanceInfo()	
	local table = {["lootWon"] = item, ["date"] = date("%d/%m/%y"), ["time"] = date("%H:%M:%S"), ["instance"] = instanceName.." "..difficultyName,
		["boss"] = boss, ["votes"] = votes, ["itemReplaced1"] = itemReplaced1, ["itemReplaced2"] = itemReplaced2, ["response"] = response,
		["reason"] = reason or db.responses[response].text, ["color"] = color or db.responses[response].color}
	if db.sendHistory then
		self:SendCommand("raid", "history", table)
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
	self:SendCommand("raid", "message", "The session has ended.")
	self.running = false
	addon.testMode = false
	-- TODO add more to restart the whole thing
end

function RCLootCouncilML:HandleVote(session, name, vote, voter)
	addon.lootList[session][name].votes = addon.lootList[session][name].votes + vote	
	--TODO This wont work..
	if vote > 0 then -- +1
		tinsert(addon.lootList[session][name].voters, voter)
	else -- -1
		for i,v in ipairs(addon.lootList[session][name].voters) do
			if addon:UnitIsUnit(v, voter) then 
				return tremove(addon.lootList[session][name].voters, i)
			end
		end
	end	
end

function RCLootCouncilML:ChangeResponse(session, name, response)
	addon.lootList[session][name].response = response
end

-- Initiates a session with the items handed
function RCLootCouncilML:Test(items)
	-- check if we're added in self.group
	-- (We might not be on solo test)
	if not tContains(self.group, addon.playerName) then
		local role = addon:TranslateRole(addon:GetCandidateRole(addon.playerName))
		self:AddToGroup(addon.playerName, addon.playerClass, role, addon.guildRank)	
	end

	-- Add the items
	for session, iName in ipairs(items) do
		self:AddItem(session, iName, false, false)
	end
	printtable(self.lootTable)
	-- FOR DEVELOPMENT
	addon:CallModule("sessionFrame")
	addon:GetActiveModule("sessionFrame"):Show(self.lootTable)

end