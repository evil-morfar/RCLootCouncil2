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
	[236687] = true, -- Explosive Hearthstone, Liberation of Undermine
	[246565] = true, -- Cosmic Hearthstone, Manaforge Omega
	[250104] = true, -- Soulbinder's Nethermantle
}

function GroupLoot:OnInitialize()
	self.Log = addon.Require "Utils.Log":New "GroupLoot"
	addon:RegisterEvent("START_LOOT_ROLL", self.OnStartLootRoll, self)
	addon:RegisterEvent("LOOT_ITEM_ROLL_WON", function(...)
		self.Log:d("LOOT_ITEM_ROLL_WON", ...)
	end)
	self.OnLootRoll:subscribe(function(_, rollID)
		RunNextFrame(function()
			self:HideGroupLootFrameWithRollID(rollID)
		end)
	end)
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
	local status = self:GetStatus()
	self.Log:D("Status:", status, self:GetStatusHex(status), self:GetStatusBinary(status))
	if self:ShouldPassOnLoot(status) then
		self.Log:d("Passing on loot", link)
		self:RollOnLoot(rollID, 0)
		self.OnLootRoll(link, rollID, 0)
	elseif self:ShouldRollOnLoot(status) then
		local roll
		if canNeed then
			roll = 1
			-- Blizzard says transmog is more important than greed..
		elseif canTransmog then
			roll = 4
		else
			roll = 2
		end
		self.Log:d("Rolling on loot", roll, link)
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
end

--- True if we should currently pass on group loot.
---@param status? integer|string Integer or binary status. Defaults to [`GroupLoot:GetStatus()`](lua://Utils.GroupLoot.GetStatus).
function GroupLoot:ShouldPassOnLoot(status)
	status = status and (type(status) == "string" and tonumber(status, 2) or status) or self:GetStatus()
	-- Bit 7 can be whatever, bit 5 must be 0, rest must be 1
	return bit.band(status, 0x1af) == 0x1af and bit.band(status, 0x10) == 0 -- 1.1010.1111 & 0.0001.0000
end

--- True if we should currently need/greed on group loot.
---@param status? integer|string Integer or binary status. Defaults to [`GroupLoot:GetStatus()`](lua://Utils.GroupLoot.GetStatus).
function GroupLoot:ShouldRollOnLoot(status)
	status = status and (type(status) == "string" and tonumber(status, 2) or status) or self:GetStatus()
	-- Bit 7 & 8 can be whatever
	return bit.band(status, 0x13f) == 0x13f -- 1.0011.1111
end

--- @enum Status
--- Table which keys is the binary representation of whether the value is true.
--- autoGroupLootGuildGroupOnly doesn't matter for rolling, but is included for options clarity.
--- "guildGroup" indicates whether rolling is allowed according to guild group options.
--- Unless indicated all must be 1 for rolls to occur.
--- See [StatusDescription](lua://StatusDescription) for detailed description.
local statusBinaryTable = {
	[000000001] = "mldb",
	[000000010] = "mldb.autoGroupLoot",
	[000000100] = "handleLoot",
	[000001000] = "masterLooter",
	[000010000] = "isMasterLooter",           -- 0 for passing; 1 for rolling.
	[000100000] = "numGroupMembers",
	[001000000] = "autoGroupLootGuildGroupOnly", -- indicator only
	[010000000] = "guildGroup",               -- 1 for passing; 1 or 0 for rolling.
	[100000000] = "enabled",
}

local statusInverted = tInvert(statusBinaryTable)

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

---Generates the binary version of the status.
---@param status? integer|string Integer status. Defaults to [`GroupLoot:GetStatus()`](lua://Utils.GroupLoot.GetStatus).
---@return string #The binary representation of the status.
function GroupLoot:GetStatusBinary(status)
	return addon.Utils:Int2Bin(status or self:GetStatus())
end

--- Converts the status to a hexadecimal string.
---@param status? integer|string Integer status. Defaults to [`GroupLoot:GetStatus()`](lua://Utils.GroupLoot.GetStatus).
---@return string #The hexadecimal representation of the status.
function GroupLoot:GetStatusHex(status)
	return string.format("%x", status or self:GetStatus())
end

---@return enum Status The status table as-is.
function GroupLoot:GetStatusTable() return statusBinaryTable end

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

--- @enum StatusDescription
--- Descriptions for [Status](lua://Status).
--- Index 0 is negative description and 1 is positive.
local description = {
	{ [0] = "Hasn't received data from ML",      [1] = "Received data from ML", },
	{ [0] = "ML has disabled autoGroupLoot",     [1] = "ML has enabled autoGroupLoot", },
	{ [0] = "RCLootCouncil doesn't handle loot", [1] = "RCLootCouncil handles loot", },
	{ [0] = "Group has no master looter",        [1] = "Group has master looter", },
	{ [0] = "Player is not master looter",       [1] = "Player is master looter", },
	{ [0] = "Not in a group",                    [1] = "In a group", },
	{ [0] = "Guild Groups Only setting",         [1] = "Guild Groups Only setting", },
	{ [0] = "Guild group settings",              [1] = "Guild group settings", },
	{ [0] = "RCLootCouncil disabled",            [1] = "RCLootCouncil enabled", },
}

--- Creates a table of descriptions for the provided status.
--- These are colored green if set in the target status, otherwise red.
---@param status integer|string Integer or binary representation of [Status](lua://Status). See [GroupLoot:GetStatus()](lua://Utils.GroupLoot.GetStatus)
---@param target integer|string Integer or binary representation of the target status.
function GroupLoot:StatusToDescription(status, target)
	local binary = addon.Utils:Int2Bin(type(status) == "string" and tonumber(status, 2) or status)
	local res = {}
	local reversedBinary = binary:reverse()
	for i = 1, #binary do
		local statusBit = tonumber(reversedBinary:sub(i, i))
		if i == 7 then -- autoGroupLootGuildGroupOnly doesn't matter; but color green if enabled
			if bit.band(status, bit.lshift(1, i - 1)) > 0 then
				res[#res + 1] = WrapTextInColorCode(description[i][statusBit] or "", "FF00FF00")
			else
				res[#res + 1] = description[i][statusBit]
			end
		elseif bit.band(status, bit.lshift(1, i - 1)) == bit.band(target, bit.lshift(1, i - 1)) then
			res[#res + 1] = WrapTextInColorCode(description[i][statusBit] or "", "FF00FF00")
		else
			res[#res + 1] = WrapTextInColorCode(description[i][statusBit] or "", "FFFF0000")
		end
	end
	return res
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
