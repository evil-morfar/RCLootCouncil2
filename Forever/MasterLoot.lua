--- Only loaded when playing Forever

---@class RCLootCouncil
local addon = select(2, ...)

---@class MasterLoot : AceEvent-3.0, AceTimer-3.0
local MasterLoot = addon.Init "Services.MasterLoot"
local Council = addon.Require "Data.Council"
local ML = _G.RCLootCouncilML
local processedSlots = {}

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