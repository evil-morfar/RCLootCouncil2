--- Only loaded when playing Forever

---@class RCLootCouncil
local addon = select(2, ...)

---@class MasterLoot : AceEvent-3.0, AceTimer-3.0
local MasterLoot = addon.Init "Services.MasterLoot"
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

	local lootToPlayer = addon.db.profile.mlLootToPlayer
	for slot, info in pairs(addon.lootSlotInfo) do
		if info.link and not info.isLooted and not processedSlots[slot] then
			processedSlots[slot] = info.link
			local link, boss = info.link, info.boss
			if lootToPlayer then
				LootSlot(slot)
				addon.ItemStorage:WatchForItemInBags(link, function(item)
					item.type = "temp"
					item.args = { boss = boss }
					item:Store()
					ML:AddItem(link, item, nil, nil, nil, boss)
				end, function(item)
					addon.Log:W("Master Loot item was not found in bags after looting", item.link)
				end, 5)
			else
				ML:AddItem(link, nil, slot, nil, nil, boss)
			end
		end
	end
end