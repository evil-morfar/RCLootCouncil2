--- Only loaded when playing Forever

---@class RCLootCouncil
local addon = select(2, ...)

---@class MasterLoot : AceEvent-3.0, AceTimer-3.0, StatusHandler
local MasterLoot = addon.Init "Services.MasterLoot"
local Council = addon.Require "Data.Council"
local ML = _G.RCLootCouncilML
local processedSlots = {}

MasterLoot.name = "Master Loot"

function MasterLoot:OnEnable()
	LibStub("AceEvent-3.0"):Embed(self)
	LibStub("AceTimer-3.0"):Embed(self)
	self:RegisterEvent("LOOT_READY", "OnLootReady")
	self:RegisterEvent("LOOT_CLOSED", "OnLootClosed")
end

function MasterLoot:OnLootClosed()
	wipe(processedSlots)
end

function MasterLoot:OnDisable()
	wipe(processedSlots)
end

function MasterLoot:OnLootReady()
	-- Run after RCLootCouncil has populated lootSlotInfo for this loot window.
	self:ScheduleTimer("ProcessLoot", 0)
end

function MasterLoot:ProcessLoot()
	if not addon.enabled or not addon.handleLoot or not addon.isMasterLooter then return end
	if addon.GetLootMethod() ~= Enum.LootMethod.Masterlooter then return end
	if not ML or not ML:IsEnabled() then return end

	---@type RCSessionFrame
	local sessionframe = addon:GetActiveModule("sessionframe")
	if ML.running or sessionframe:IsRunning() then
		ML:UpdateLootSlots()
	else
		for slot, info in pairs(addon.lootSlotInfo) do
			local item = info.link
			if item and not info.isLooted and not processedSlots[slot] then
				processedSlots[slot] = item
				local autoAward, mode, winner = ML:ShouldAutoAward(item, info.quality)

				if autoAward and info.quantity > 0 then
					ML:AutoAward(slot, item, info.quality, winner, mode, addon.bossName)
				elseif item and ML:CanWeLootItem(item, info.quality) and info.quantity > 0 then -- check if our options allows us to loot it
					ML:AddItem(item, nil, slot, nil, nil, info.boss)
				end
			end
		end
	end
	if #ML.lootTable <= 0 or ML.running then return end
	local db = addon:Getdb()
	if db.autoStart and addon.candidatesInGroup[addon.player:GetName()] and Council:GetNum() > 0 then -- Auto start only if data is ready
		if db.awardLater then
			ML:DoAwardLater(ML.lootTable)
		else
			ML:StartSession()
		end
	else
		ML:ShowSessionFrame(ML.lootTable)
	end
end

-----------------------------------------------------------------
-- Status stuff
-----------------------------------------------------------------

---@enum MasterLootStatus
--- The position of these values matter! Based on GroupLootStatus as that came first.
--- See [GroupLoot Status](lua://GroupLootStatus) for more details
local statusBinaryTable = {
	[000000001] = "mldb",
	[000000010] = "enabled",			-- Only one different from group loot
	[000000100] = "handleLoot",
	[000001000] = "masterLooter",
	[000010000] = "isMasterLooter", 	-- 0 for passing; 1 for rolling.
	[000100000] = "numGroupMembers",
}
local statusInverted = tInvert(statusBinaryTable)

--- @enum MasterLootStatusDescription
--- Descriptions for [Status](lua://Status).
--- Index 0 is negative description and 1 is positive.
local description = {
	{ [0] = "Hasn't received data from ML",      [1] = "Received data from ML", },
	{ [0] = "RCLootCouncil disabled",            [1] = "RCLootCouncil enabled", },
	{ [0] = "RCLootCouncil doesn't handle loot", [1] = "RCLootCouncil handles loot", },
	{ [0] = "Group has no master looter",        [1] = "Group has master looter", },
	{ [0] = "Player is not master looter",       [1] = "Player is master looter", },
	{ [0] = "Not in a group",                    [1] = "In a group", },
}
function MasterLoot:GetDescription() return description end

--- Generates the status for the current GroupLoot setting.
---@return integer #The integer representation of the binary status value.
function MasterLoot:GetStatus()
	local result = (addon.mldb and next(addon.mldb) and 1 or 0)
	result = result + bit.lshift((addon.enabled and 1 or 0), 1)
	result = result + bit.lshift((addon.handleLoot and 1 or 0), 2)
	result = result + bit.lshift((addon:HasValidMasterLooter() and 1 or 0), 3)
	result = result + bit.lshift((addon.isMasterLooter and 1 or 0), 4)
	result = result + bit.lshift((GetNumGroupMembers() > 1 and 1 or 0), 5)
	return result
end


local targetStatusML = tonumber("111111", 2)
local targetStatus   = tonumber("101111", 2)

function MasterLoot:GetTargetedStatus() return targetStatus end
function MasterLoot:GetTargetedMLStatus() return targetStatusML end
