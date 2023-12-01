require "busted.runner" ()
-----------------------------------------------------------
-- Setup
-----------------------------------------------------------
dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")
-----------------------------------------------------------
-- Tests
-----------------------------------------------------------
local addon = RCLootCouncil
local GroupLoot = addon.Require "Utils.GroupLoot"

addon:InitLogging()
addon.Print = function() end --noop
describe("#GroupLoot", function()
	-- describe("#Basic", function()
	-- 	it("should need on items when we're ML and item can be needed", function()
	-- 		stub(_G, "GetLootRollItemInfo", function()
	-- 			return nil,nil,nil,nil,nil,1 -- canNeed = true
	-- 		end)
	-- 		local s = spy.on(GroupLoot, "RollOnLoot")
	-- 		SetupML()
	-- 		GroupLoot:OnStartLootRoll(nil, 1)
	-- 		assert.spy(s).was_called(1)
	-- 		assert.spy(s).was_called_with(GroupLoot, 1, 1)
	-- 		_G.GetLootRollItemInfo:revert()
	-- 	end)
	-- 	it("should greed on loot when we're ML", function()
	-- 		local s = spy.on(GroupLoot, "RollOnLoot")
	-- 		SetupML()
	-- 		GroupLoot:OnStartLootRoll(nil, 1)
	-- 		assert.spy(s).was_called(1)
	-- 		assert.spy(s).was_called_with(GroupLoot, 1, 2)
	-- 	end)
	-- 	it("should pass on loot by default", function()
	-- 		local s = spy.on(GroupLoot, "RollOnLoot")
	-- 		SetupML()
	-- 		addon.isMasterLooter = false
	-- 		addon.isInGuildGroup = false
	-- 		GroupLoot:OnStartLootRoll(nil, 1)
	-- 		GroupLoot:OnStartLootRoll(nil, 2)
	-- 		assert.spy(s).was_called(0)
	-- 	end)

	-- 	it("should not do anything when addon isn't in use", function()
	-- 		local s = spy.on(GroupLoot, "RollOnLoot")
	-- 		addon.handleLoot = false
	-- 		GroupLoot:OnStartLootRoll(nil, 3)
	-- 		assert.spy(s).was_called(0)
	-- 	end)

	-- 	it("should not do anything when addon is disabled", function()
	-- 		local s = spy.on(GroupLoot, "RollOnLoot")
	-- 		addon.enabled = false
	-- 		GroupLoot:OnStartLootRoll(nil, 3)
	-- 		assert.spy(s).was_called(0)
	-- 	end)
	-- end)

	-- describe("#autoGroupLootGuildGroupOnly ", function()
	-- 	local s
	-- 	before_each(function()
	-- 		s = spy.on(GroupLoot, "RollOnLoot")
	-- 		addon.enabled = true
	-- 		SetupML()
	-- 		addon.isMasterLooter = false
	-- 	end)
	-- 	describe("enabled", function()
	-- 		it("should pass on loot if in guild group", function()
	-- 			addon.isInGuildGroup = true
	-- 			GroupLoot:OnStartLootRoll(nil, 1)
	-- 			GroupLoot:OnStartLootRoll(nil, 2)
	-- 			assert.spy(s).was_called(2)
	-- 			assert.spy(s).was_called_with(GroupLoot, 1, 0)
	-- 			assert.spy(s).was_called_with(GroupLoot, 2, 0)
	-- 		end)

	-- 		it("should not pass on loot if not in guild group", function()
	-- 			addon.isInGuildGroup = false
	-- 			GroupLoot:OnStartLootRoll(nil, 1)
	-- 			GroupLoot:OnStartLootRoll(nil, 2)
	-- 			assert.spy(s).was_called(0)
	-- 		end)
	-- 	end)

	-- 	describe("disabled", function()
	-- 		addon.db.profile.autoGroupLootGuildGroupOnly = false
	-- 		it("should pass on loot if in guild group", function()
	-- 			addon.isInGuildGroup = true
	-- 			GroupLoot:OnStartLootRoll(nil, 1)
	-- 			GroupLoot:OnStartLootRoll(nil, 2)
	-- 			assert.spy(s).was_called(2)
	-- 			assert.spy(s).was_called_with(GroupLoot, 1, 0)
	-- 			assert.spy(s).was_called_with(GroupLoot, 2, 0)
	-- 	   end)

	-- 		it("should pass on loot if not in guild group", function()
	-- 			addon.isInGuildGroup = false
	-- 			GroupLoot:OnStartLootRoll(nil, 1)
	-- 			GroupLoot:OnStartLootRoll(nil, 2)
	-- 			assert.spy(s).was_called(2)
	-- 			assert.spy(s).was_called_with(GroupLoot, 1, 0)
	-- 			assert.spy(s).was_called_with(GroupLoot, 2, 0)
	-- 	   end)
	-- 	end)

	-- end)

	describe("#ignored items", function()
		local s
		before_each(function()
			s = spy.on(GroupLoot, "RollOnLoot")
			addon.enabled = true
			SetupML()
			addon.isMasterLooter = false
		end)

		it("should ignore items on the ignore list", function()
			GroupLoot:OnStartLootRoll(nil, (next(GroupLoot.IgnoreList)))
			assert.spy(s).was_not_called()
		end)
	end)

	function _G.GetLootRollItemLink(rollID)
		if GroupLoot.IgnoreList[rollID] then
			return "item:" .. rollID .. ":"
		end
		return _G.Items_Array[math.random(#_G.Items_Array)]
	end
end)

function _G.GetNumGroupMembers()
	return 10
end

function _G.RollOnLoot() end

function _G.GetRaidRosterInfo()
	return "name"
end

function _G.GetLootThreshold()
	return 1
end

function _G.GetLootRollItemInfo(rollID)

end

function SetupML()
	addon.isMasterLooter = true
	addon.masterLooter = addon.player;
	RCLootCouncilML:Enable()
	RCLootCouncilML:NewML(addon.player)
	addon:StartHandleLoot()
end
