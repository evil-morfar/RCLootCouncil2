require "busted.runner"()

---@diagnostic disable: inject-field, undefined-field, param-type-mismatch
---@type RCLootCouncil
local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
dofile ".specs/EmulatePlayerLogin.lua"

local Player = addon.Require "Data.Player"
local ML = RCLootCouncilML
local itemLink = "item:12345"
local snapshot

addon.Print = addon.noop
dofile(".specs/Helpers/SetupRaid.lua")(3)
addon.player = Player:Get("player")
addon:CallModule("masterlooter")

local function entry(options)
	local ret = {
		link = itemLink,
		lootSlot = nil,
		bagged = nil,
		awarded = false,
		boss = "Test Boss",
		owner = "Owner-Realm1",
	}
	for key, value in pairs(options or {}) do ret[key] = value end
	return ret
end

local function capture(...)
	---@type any
	local args = { ... }
	args.n = select("#", ...)
	return args
end

local function prepareDirectAward()
	ML.lootTable = { entry { lootSlot = 1 } }
	addon.lootOpen = true
	addon.lootSlotInfo = { [1] = {
		link = itemLink,
		name = "Test Item",
		quantity = 1,
		quality = Enum.ItemQuality.Epic,
		guid = "",
		boss = "Test Boss",
		autoloot = false,
	} }
	stub(ML, "CanGiveLoot", function() return true end)
end

describe("#Integration #RCLootCouncilML:Award", function()
	before_each(function()
		snapshot = assert:snapshot()
		dofile(".specs/Helpers/SetupRaid.lua")(3)
		addon.player = Player:Get("player")
		addon.playerName = addon.player:GetName()
		addon.testMode = false
		addon.lootOpen = false
		addon.lootSlotInfo = {}
		ML.lootTable = {}
		ML.oldLootTable = {}
		ML.running = false
		stub(ML, "Send", function() end)
		stub(ML, "AnnounceAward", function() end)
		stub(ML, "HasAllItemsBeenAwarded", function() return false end)
		stub(ML, "ScheduleTimer", function() return "timer" end)
		stub(ML, "PrintLootErrorMsg", function() end)
		stub(addon, "GetActiveModule", function()
			return { GetCandidateData = function() return 42 end }
		end)
		stub(addon, "IsItemBoP", function() return false end)
		stub(_G, "GetLootSlotLink", function() return itemLink end)
		stub(addon.ItemStorage, "New", function(_, link, kind, args)
			return {
				link = link,
				kind = kind,
				args = args,
				inBags = true,
				Store = function(self) return self end,
			}
		end)
		stub(addon.ItemStorage, "RemoveItem", function() end)
	end)

	after_each(function()
		snapshot:revert()
	end)

	describe("loot table recovery and invalid states", function()
		it("returns false without a current or previous loot table", function()
			local callbackCalled = false
			ML.lootTable = nil
			assert.is_false(ML:Award(1, "Winner", nil, nil, function() callbackCalled = true end))
			assert.is_false(callbackCalled)
		end)

		it("returns false for an empty loot table without previous loot", function()
			local callbackCalled = false
			assert.is_false(ML:Award(1, "Winner", nil, nil, function() callbackCalled = true end))
			assert.is_false(callbackCalled)
		end)

		it("restores the previous loot table when the current one is empty", function()
			local oldEntry = entry()
			ML.oldLootTable = { oldEntry }
			local callbackArgs
			local result = ML:Award(1, "Winner", "Need", nil, function(...) callbackArgs = capture(...) end, "extra")
			assert.is_true(result)
			assert.equal(oldEntry, ML.lootTable[1])
			assert.same({ true, 1, "Winner", "manually_added", "extra", n = 5 }, callbackArgs)
		end)

		it("fails and reports an item that is both unlooted and bagged", function()
			ML.lootTable = { entry { lootSlot = 1, bagged = {} } }
			local callbackArgs
			stub(addon, "SessionError", function() end)
			assert.is_false(ML:Award(1, "Winner", "Need", nil, function(...) callbackArgs = capture(...) end, "extra"))
			assert.same({ false, 1, "Winner", "unlooted_in_bag", "extra", n = 5 }, callbackArgs)
		end)

		it("rejects bagging an item that is already bagged", function()
			ML.lootTable = { entry { bagged = {} } }
			local callbackArgs
			assert.is_false(ML:Award(1, nil, "Need", nil, function(...) callbackArgs = capture(...) end))
			assert.same({ false, 1, nil, "bagging_bagged", n = 4 }, callbackArgs)
		end)

		it("rejects bagging an item that has already been awarded", function()
			ML.lootTable = { entry { awarded = "PreviousWinner" } }
			local callbackArgs
			assert.is_false(ML:Award(1, nil, "Need", nil, function(...) callbackArgs = capture(...) end))
			assert.same({ false, 1, nil, "bagging_awarded_item", n = 4 }, callbackArgs)
		end)
	end)

	describe("manual and previously awarded items", function()
		it("awards an untracked item manually and preserves callback arguments", function()
			ML.lootTable = { entry() }
			local callbackArgs
			assert.is_true(ML:Award(1, "Winner", "Need", nil, function(...) callbackArgs = capture(...) end, "extra"))
			assert.same({ true, 1, "Winner", "manually_added", "extra", n = 5 }, callbackArgs)
			assert.equal("Winner", ML.lootTable[1].awarded)
		end)

		it("uses test_mode status for manual awards while testing", function()
			addon.testMode = true
			ML.lootTable = { entry() }
			local callbackArgs
			assert.is_true(ML:Award(1, "Winner", "Need", nil, function(...) callbackArgs = capture(...) end))
			assert.same({ true, 1, "Winner", "test_mode", n = 4 }, callbackArgs)
		end)

		it("does not allow award-later for manually added test items", function()
			addon.testMode = true
			ML.lootTable = { entry() }
			local callbackArgs
			assert.is_false(ML:Award(1, nil, "Need", nil, function(...) callbackArgs = capture(...) end))
			assert.same({ false, 1, nil, "test_mode", n = 4 }, callbackArgs)
		end)

		it("stores a manually added item for award later", function()
			ML.lootTable = { entry() }
			local callbackArgs
			assert.is_false(ML:Award(1, nil, "Need", nil, function(...) callbackArgs = capture(...) end))
			assert.same({ false, 1, nil, "manually_bagged", n = 4 }, callbackArgs)
			assert.is_table(ML.lootTable[1].bagged)
			assert.is_nil(ML.lootTable[1].lootSlot)
		end)

		it("changes a previous manual award and uses the appropriate status", function()
			ML.lootTable = { entry { awarded = "PreviousWinner" } }
			local callbackArgs
			assert.is_true(ML:Award(1, "NewWinner", "Need", nil, function(...) callbackArgs = capture(...) end))
			assert.same({ true, 1, "NewWinner", "manually_added", n = 4 }, callbackArgs)
			assert.equal("NewWinner", ML.lootTable[1].awarded)
		end)

		it("uses test_mode when changing a previous manual award while testing", function()
			addon.testMode = true
			ML.lootTable = { entry { awarded = "PreviousWinner" } }
			local callbackArgs
			assert.is_true(ML:Award(1, "NewWinner", "Need", nil, function(...) callbackArgs = capture(...) end))
			assert.same({ true, 1, "NewWinner", "test_mode", n = 4 }, callbackArgs)
		end)

		it("changes a previous award from a bagged item as an indirect award", function()
			ML.lootTable = { entry { awarded = "PreviousWinner", bagged = {} } }
			local callbackArgs
			assert.is_true(ML:Award(1, "NewWinner", "Need", nil, function(...) callbackArgs = capture(...) end))
			assert.same({ true, 1, "NewWinner", "indirect", n = 4 }, callbackArgs)
		end)

		it("changes a previous direct award with normal status", function()
			ML.lootTable = { entry { awarded = "PreviousWinner", lootSlot = 1 } }
			local callbackArgs
			assert.is_true(ML:Award(1, "NewWinner", "Need", nil, function(...) callbackArgs = capture(...) end))
			assert.same({ true, 1, "NewWinner", "normal", n = 4 }, callbackArgs)
		end)
	end)

	describe("bagged items", function()
		it("awards an item that is already in the bag", function()
			ML.lootTable = { entry { bagged = {} } }
			local callbackArgs
			assert.is_true(ML:Award(1, "Winner", "Need", nil, function(...) callbackArgs = capture(...) end, "extra"))
			assert.same({ true, 1, "Winner", "indirect", "extra", n = 5 }, callbackArgs)
			assert.equal("Winner", ML.lootTable[1].awarded)
		end)
	end)

	describe("direct loot", function()
		it("refreshes a stale loot slot before checking eligibility", function()
			prepareDirectAward()
			stub(addon, "ItemIsItem", function() return false end)
			stub(_G, "GetLootSlotLink", function() return "stale-link" end)
			local updated, checkedSlot
			stub(ML, "UpdateLootSlots", function(self)
				updated = true
				self.lootTable[1].lootSlot = 2
			end)
			stub(ML, "CanGiveLoot", function(_, slot)
				checkedSlot = slot
				return true
			end)
			local giveCallback
			stub(ML, "GiveLoot", function(_, slot, winner, callback) giveCallback = callback end)
			ML:Award(1, "Winner", "Need")
			assert.is_true(updated)
			assert.equal(2, checkedSlot)
			assert.is_function(giveCallback)
		end)

		it("reports ineligibility causes other than fallback causes", function()
			prepareDirectAward()
			stub(ML, "CanGiveLoot", function() return false, "offline" end)
			local callbackArgs
			assert.is_false(ML:Award(1, "Winner", "Need", nil, function(...) callbackArgs = capture(...) end))
			assert.same({ false, 1, "Winner", "offline", n = 4 }, callbackArgs)
		end)

		for _, cause in ipairs({ "quality_below_threshold", "not_bop" }) do
			local failureCause = cause
			it("falls back to bagging when the item cannot be given because of " .. failureCause, function()
				prepareDirectAward()
				local checks = 0
				stub(ML, "CanGiveLoot", function()
					checks = checks + 1
					if checks == 1 then return false, failureCause end
					return true
				end)
				local callbackArgs
				stub(ML, "GiveLoot", function(_, _, _, callback) callback(true) end)
				assert.is_nil(ML:Award(1, "Winner", "Need", nil, function(...) callbackArgs = capture(...) end))
				assert.equal(2, checks)
				assert.same({ false, 1, nil, "bagged", n = 4 }, callbackArgs)
				assert.is_table(ML.lootTable[1].bagged)
			end)
		end

		it("gives direct loot asynchronously and reports success", function()
			prepareDirectAward()
			local callbackArgs
			local giveCallback
			stub(ML, "GiveLoot", function(_, _, _, callback) giveCallback = callback end)
			assert.is_nil(ML:Award(1, "Winner", "Need", { text = "Reason" },
				function(...) callbackArgs = capture(...) end, "extra"))
			assert.is_function(giveCallback)
			giveCallback(true)
			assert.same({ true, 1, "Winner", "normal", "extra", n = 5 }, callbackArgs)
			assert.equal("Winner", ML.lootTable[1].awarded)
		end)

		it("reports a failed direct loot attempt asynchronously", function()
			prepareDirectAward()
			local callbackArgs
			local giveCallback
			stub(ML, "GiveLoot", function(_, _, _, callback) giveCallback = callback end)
			ML:Award(1, "Winner", "Need", nil, function(...) callbackArgs = capture(...) end, "extra")
			giveCallback(false, "timeout")
			assert.same({ false, 1, "Winner", "timeout", "extra", n = 5 }, callbackArgs)
		end)

		it("bags direct loot asynchronously when the loot attempt succeeds", function()
			prepareDirectAward()
			local callbackArgs
			local giveCallback
			stub(ML, "GiveLoot", function(_, _, _, callback) giveCallback = callback end)
			assert.is_nil(ML:Award(1, nil, "Need", nil, function(...) callbackArgs = capture(...) end, "extra"))
			giveCallback(true)
			assert.same({ false, 1, nil, "bagged", "extra", n = 5 }, callbackArgs)
			assert.is_table(ML.lootTable[1].bagged)
			assert.is_nil(ML.lootTable[1].lootSlot)
		end)

		it("reports a failed direct award-later loot attempt", function()
			prepareDirectAward()
			local callbackArgs
			local giveCallback
			stub(ML, "GiveLoot", function(_, _, _, callback) giveCallback = callback end)
			ML:Award(1, nil, "Need", nil, function(...) callbackArgs = capture(...) end)
			giveCallback(false, "timeout")
			assert.same({ false, 1, nil, "timeout", n = 4 }, callbackArgs)
			assert.is_nil(ML.lootTable[1].bagged)
		end)
	end)
end)