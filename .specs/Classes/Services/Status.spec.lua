require "busted.runner"()

local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")

local Status = addon.Require "Services.Status"
local GroupLoot = addon.Require "Utils.GroupLoot"

describe("#Services #Status", function()
	local originalGetLootMethod

	before_each(function()
		originalGetLootMethod = addon.GetLootMethod
		addon.GetLootMethod = function() return Enum.LootMethod.Group end
		Status:OnLootMethodChanged()
	end)

	after_each(function()
		addon.GetLootMethod = originalGetLootMethod
		Status:OnLootMethodChanged()
	end)

	it("registers for loot method changes and selects the current handler", function()
		Status:Initialize()
		WoWAPI_FireEvent("PARTY_LOOT_METHOD_CHANGED")
		-- Doesn't do much in retail, as wer only have group loot
		assert.equal("Group Loot", Status:GetName())
		assert.equal(GroupLoot, Status.statusHandler)
	end)


	it("selects the handler for the current loot method", function()
		assert.equal("Group Loot", Status:GetName())

		addon.GetLootMethod = function() return Enum.LootMethod.Personal end
		Status:OnLootMethodChanged()

		assert.equal("Group Loot", Status:GetName())
		assert.equal(Enum.LootMethod.Personal, addon.lootMethod)
	end)

	it("delegates status and target values to the active handler", function()
		-- 101101
		local getStatus = stub(GroupLoot, "GetStatus").returns(45)
		-- 101111
		local getTargetedStatus = stub(GroupLoot, "GetTargetedStatus").returns(47)
		-- 111111
		local getTargetedMLStatus = stub(GroupLoot, "GetTargetedMLStatus").returns(63)

		-- 101101
		assert.equal(45, Status:GetStatus())
		-- 101111
		assert.equal(47, Status:GetTargetedStatus())
		-- 111111
		assert.equal(63, Status:GetTargetedMLStatus())

		getStatus:revert()
		getTargetedStatus:revert()
		getTargetedMLStatus:revert()
	end)

	it("converts status values to binary and hexadecimal strings", function()
		-- 101101
		local getStatus = stub(GroupLoot, "GetStatus").returns(45)

		-- 101101
		assert.equal("101101", Status:GetStatusBinary())
		-- 101101
		assert.equal("101101", Status:GetStatusBinary(45))
		-- 101101 = 2d in hexadecimal
		assert.equal("2d", Status:GetStatusHex())
		-- 101101 = 2d in hexadecimal
		assert.equal("2d", Status:GetStatusHex(45))

		getStatus:revert()
	end)

	it("colors descriptions according to the active handler and target", function()
		local descriptions = Status:StatusToDescription(1, 2)

		assert.equal(WrapTextInColorCode("Received data from ML", "FFFF0000"), descriptions[1])
		assert.equal(WrapTextInColorCode("ML has disabled autoGroupLoot", "FFFF0000"), descriptions[2])
	end)
end)
