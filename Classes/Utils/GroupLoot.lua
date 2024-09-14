--- GroupLoot.lua Class for handling Group Loot interactions.
-- @author Potdisc
-- Create Date: 09/11/2022

--- @type RCLootCouncil
local addon = select(2, ...)
--- @class Utils.GroupLoot
local GroupLoot = addon.Init "Utils.GroupLoot"
local Subject = addon.Require("rx.Subject")
local ItemUtils = addon.Require "Utils.Item"

--- @class OnLootRoll : rx.Subject
--- Called everytime we're auto rolling for loot.
--- Subscriber functions are called with args: `itemLink` ,`rollID`, `rollType`
--- @field subscribe fun(self, onNext: fun(link:ItemLink, rollID:integer, rollType:RollType), onError?:fun(message:string), onComplete?:fun()): rx.Subscription
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
	end, nil)
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
	self.Log:D("Status:", self:GetStatusBinary())
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
	-- local status = self:GetStatus()
	-- Bit 7 can be whatever, bit 5 must be 0, rest must be 1
	-- return bit.band(status, 0x1af) == 0x1af and bit.band(status, 0x10) == 0-- 1.1010.1111 & 0.0001.0000
end

function GroupLoot:ShouldRollOnLoot()
	return addon.mldb and addon.mldb.autoGroupLoot and addon.handleLoot and
		addon.masterLooter and addon.isMasterLooter and GetNumGroupMembers() > 1
	-- return bit.band(self:GetStatus(), 0x1bf) == 0x1bf -- 1.1011.1111
	-- TODO Consider if we do care about the guild group thing as ML.
end

--- @enum Status
--- Table which keys is the binary representation of whether the value is true.
--- autoGroupLootGuildGroupOnly doesn't matter for rolling, but is included for options clarity.
--- "guildGroup" is the combined result of both - true if rolling is allowed.
--- If everything but 'isMasterLooter' is true, then we pass on loot.
--- If 'isMasterLooter' is also true, then we roll on loot.
local status = {
	[000000001] = "mldb",
	[000000010] = "mldb.autoGroupLoot",
	[000000100] = "handleLoot",
	[000001000] = "masterLooter",
	[000010000] = "isMasterLooter",
	[000100000] = "numGroupMembers",
	[001000000] = "autoGroupLootGuildGroupOnly",
	[010000000] = "guildGroup",
	[100000000] = "enabled",
}

local statusInverted = tInvert(status)

--- Generates the status for the current GroupLoot setting.
---@return integer #The integer representation of the binary status value.
function GroupLoot:GetStatus()
	local result = (addon.mldb and next(addon.mldb) and 1 or 0)
	result = result + bit.lshift((addon.mldb and addon.mldb.autoGroupLoot and 1 or 0), 1)
	result = result + bit.lshift((addon.handleLoot and 1 or 0), 2)
	result = result + bit.lshift((addon:HasValidMasterLooter() and 1 or 0), 3)
	result = result + bit.lshift((addon.isMasterLooter and 1 or 0), 4)
	result = result + bit.lshift((GetNumGroupMembers() > 1 and 1 or 0), 5)
	result = result + bit.lshift((addon.db.profile.autoGroupLootGuildGroupOnly and 1 or 0), 6)
	result = result +
		bit.lshift(((not addon.db.profile.autoGroupLootGuildGroupOnly or addon.isInGuildGroup) and 1 or 0), 7)
	result = result + bit.lshift((addon.enabled and 1 or 0), 8)
	return result
end

---Generates the binary version of [GroupLoot:GetStatus()](lua://Utils.GroupLoot.GetStatus)
---@return string #The binary representation of the status.
function GroupLoot:GetStatusBinary()
	return addon.Utils:Int2Bin(self:GetStatus())
end

---@return enum Status The status table as-is.
function GroupLoot:GetStatusTable() return status end

---@return table<string, integer> StatusInverted The inverted status table as-is.
function GroupLoot:GetInvertedStatusTable() return statusInverted end


--- Calculates the status with one or more fields set.
--- Invalid fields will be ignored.
---@param ...Status The fields to set. Must be a valid value in [Status](lua://Status).
---@return integer #The integer representation of the binary status value.
function GroupLoot:CalculateStatus(...)
	local result = 0
	for i = 1, select("#", ...) do
		local s = select(i, ...)
		if statusInverted[s] then
			result = result + statusInverted[s]
		end
	end
	return tonumber(result, 2)
end

local description = {
	"Received data from ML",
	"ML has enabled autoGroupLoot",
	"addon handles loot",
	"group has master looter",
	"player is master looter",
	"numGroupMembers > 1",
	"autoGroupLootGuildGroupOnly enabled",
	"Guild group settings",
	"addon enabled",
}
---comment
---@param status integer
---@param target integer
function GroupLoot:StatusToDescription(status, target)
	local binary = addon.Utils:Int2Bin(status)
	local res = {}
	for i = 1, #binary do
		if i == 7 then -- autoGroupLootGuildGroupOnly doesn't matter
			res[#res + 1] = description[i]
		else
			if bit.band(status, bit.lshift(1, i - 1)) > 0 and bit.band(status, bit.lshift(1, i - 1)) > 0 then
				res[#res + 1] = WrapTextInColorCode(description[i], "FF00FF00")
			else
				res[#res + 1] = WrapTextInColorCode(description[i], "FFFF0000")
			end
		end
	end
	return res
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
