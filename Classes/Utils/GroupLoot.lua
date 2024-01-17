--- GroupLoot.lua Class for handling Group Loot interactions.
-- @author Potdisc
-- Create Date: 09/11/2022

--- @type RCLootCouncil
local addon = select(2, ...)
--- @class Utils.GroupLoot
local GroupLoot = addon.Init "Utils.GroupLoot"
local Subject = addon.Require("rx.Subject")
local ItemUtils = addon.Require "Utils.Item"

--- @class OnLootRoll
--- Called everytime we're auto rolling for loot.
--- Subscriber functions are called with args: `itemLink` ,`rollID`, `rollType`
--- @field subscribe fun(onNext: fun(link:ItemLink, rollID:integer, rollType:RollType), onError:fun(message:string), onComplete:fun()): rx.Subscription
GroupLoot.OnLootRoll = Subject.create()

--- @type table<integer, boolean>
--- These item ids will not be processed by this code due to them not being tradeable.
GroupLoot.IgnoreList = {
	[209035] = true, -- Hearthstone of the Flame, Larodar, Amirdrassil
}

function GroupLoot:OnInitialize()
	self.Log = addon.Require "Utils.Log":New "GroupLoot"
	addon:RegisterEvent("START_LOOT_ROLL", self.OnStartLootRoll, self)
	self.OnLootRoll:subscribe(function(_, rollID)
		pcall(self.HideGroupLootFrameWithRollID, self, rollID) -- REVIEW: pcall because I haven't actually tested it in game.
	end)
	-- addon:RegisterEvent("LOOT_HISTORY_ROLL_CHANGED", self.OnLootHistoryRollChanged, self)
end

function GroupLoot:OnStartLootRoll(_, rollID)
	self.Log:d("START_LOOT_ROLL", rollID)
	if not addon.enabled then return self.Log:d("Addon disabled, ignoring group loot") end
	local link = GetLootRollItemLink(rollID)
	local _, _, _, quality, _, canNeed, _, _, _, _, _, _, canTransmog = GetLootRollItemInfo(rollID)
	if not link then -- Sanity check
		self.Log:d("No link!", rollID)
		return
	end
	if quality and quality >= Enum.ItemQuality.Legendary then
		self.Log:d("Ignoring legendary quality:", quality)
		return
	end
	local id = ItemUtils:GetItemIDFromLink(link)
	if self.IgnoreList[id] then
		self.Log:d(link, "is ignored, bailing.")
		return
	end
	if self:ShouldPassOnLoot() then
		self.Log:d("Passing on loot", link)
		self:RollOnLoot(rollID, 0)
		self.OnLootRoll(link, rollID, 0)
	elseif self:ShouldRollOnLoot() then
		local roll
		if canNeed then
			roll = 1
			-- Blizzard says transmog is more important than greed..
		elseif canTransmog then
			roll = 4
		else
			roll = 2
		end
		self.Log:d("Rolling on loot", link, roll)
		self:RollOnLoot(rollID, roll)
		self.OnLootRoll(link, rollID, roll)
	end
end

--- @alias RollType
--- | 0 #Pass
--- | 1 #Need
--- | 2 Greed
--- | 3 Disenchant
--- | 4 Transmog

--- Rolls on all items in group loot frame.
--- Note this function doesn't check if the chosen type is valid
--- @param rollID integer Id of the loot roll.
--- @param rollType? RollType Type to roll
function GroupLoot:RollOnLoot(rollID, rollType)
	-- Delay execution in case other addons have modified the loot frame
	-- and haven't had a change to fully load.
	addon:ScheduleTimer(RollOnLoot, 0.05, rollID, rollType)
	--ConfirmLootRoll(rollID, rollType)
end

function GroupLoot:ShouldPassOnLoot()
	local db = addon:Getdb()
	return addon.mldb and addon.mldb.autoGroupLoot and addon.handleLoot and
		addon.masterLooter and not addon.isMasterLooter and GetNumGroupMembers() > 1
		and (db.autoGroupLootGuildGroupOnly and addon.isInGuildGroup or not db.autoGroupLootGuildGroupOnly)
end

function GroupLoot:ShouldRollOnLoot()
	return addon.mldb and addon.mldb.autoGroupLoot and addon.handleLoot and
		addon.masterLooter and addon.isMasterLooter and GetNumGroupMembers() > 1
end

function GroupLoot:OnLootHistoryRollChanged(event, itemId, playerId)
	self.Log:d(event)
	self.Log:d("GetItem:", C_LootHistory.GetItem(itemId))
	self.Log:d("GetPlayerInfo:", C_LootHistory.GetPlayerInfo(itemId, playerId))
end

local NUM_LOOT_FRAMES = 4
--- Hides any visible default group loot frames
function GroupLoot:HideGroupLootFrames()
	local hidden = false
	for i = 1, NUM_LOOT_FRAMES do
		local frame = _G["GroupLootFrame" .. i]
		if frame and frame:IsShown() then
			_G.GroupLootContainer_RemoveFrame(_G.GroupLootContainer, frame)
			hidden = true
		end
	end
	if hidden then
		self.Log:D("Hided default group loot frames")
	end
end

---Hides a visiable default group loot frame with a particular rollID
---@param rollID integer RollID of the frame to hide.
function GroupLoot:HideGroupLootFrameWithRollID(rollID)
	if not rollID then return end
	for i = 1, NUM_LOOT_FRAMES do
		local frame = _G["GroupLootFrame" .. i]
		if frame and frame:IsShown() and frame.rollID == rollID then
			_G.GroupLootContainer_RemoveFrame(_G.GroupLootContainer, frame)
			self.Log:D("Hide group loot frame with rollID", i, rollID)
		end
	end
end
