require "busted.runner"()

local addon = loadfile(".specs/AddonLoader.lua")(false, "RCLootCouncil", nil, 18).LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")

describe("#Forever #CoreUpdates", function()
	local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

	describe("IsCorrectVersion", function()
		local originalProjectId = WOW_PROJECT_ID

		after_each(function()
			WOW_PROJECT_ID = originalProjectId
		end)

		it("returns true when WOW_PROJECT_ID is WOW_PROJECT_CAMELOT", function()
			_G.WOW_PROJECT_ID = _G.WOW_PROJECT_CAMELOT
			assert.is_true(addon:IsCorrectVersion())
		end)

		it("returns false when WOW_PROJECT_ID is not WOW_PROJECT_CAMELOT", function()
			_G.WOW_PROJECT_ID = _G.WOW_PROJECT_MAINLINE
			assert.is_false(addon:IsCorrectVersion())

			_G.WOW_PROJECT_ID = _G.WOW_PROJECT_CLASSIC
			assert.is_false(addon:IsCorrectVersion())
		end)
	end)

	describe("Utils:UnitName", function()
		before_each(function()
			wipe(addon.Utils.unitNameLookup)
		end)

		it("returns empty string for nil or empty unit", function()
			assert.are.equal("", addon.Utils:UnitName(nil))
			assert.are.equal("", addon.Utils:UnitName(""))
		end)

		it("removes realm name from player-realm string", function()
			assert.are.equal("Player", addon.Utils:UnitName("Player-Realm"))
			assert.are.equal("First Last", addon.Utils:UnitName("First Last-Realm"))
		end)

		it("removes trailing dash", function()
			assert.are.equal("Player", addon.Utils:UnitName("Player-"))
			assert.are.equal("First Last", addon.Utils:UnitName("First Last-"))
		end)

		it("returns name untouched if no realm or dash is present", function()
			assert.are.equal("Player", addon.Utils:UnitName("Player"))
			assert.are.equal("First Last", addon.Utils:UnitName("First Last"))
		end)

		it("returns cached unit name when already in unitNameLookup", function()
			addon.Utils.unitNameLookup["CustomKey"] = "CachedName"
			assert.are.equal("CachedName", addon.Utils:UnitName("CustomKey"))
		end)

		it("returns secret value as is without modification", function()
			local secretUnit = "secret-value"
			local s = spy.on(addon.Utils, "IsSecretValue")
			s.callback = function(self, val)
				return val == secretUnit
			end

			assert.are.equal(secretUnit, addon.Utils:UnitName(secretUnit))
			s:revert()
		end)

		it("handles noCache keys correctly", function()
			addon.Utils:UnitName("player")
			assert.is_nil(addon.Utils.unitNameLookup["player"])
			addon.Utils:UnitName("target")
			assert.is_nil(addon.Utils.unitNameLookup["target"])
			addon.Utils:UnitName("npc")
			assert.is_nil(addon.Utils.unitNameLookup["npc"])
		end)
	end)

	describe("Test function", function()
		local originalGetML
		local originalPrint
		local originalSnapshot
		local originalCallModule
		local originalGetActiveModule
		local testItems = {
			284716, 279260, 279259, 279262, 279261, 279273, 21395, 12640, 279253, 279246, 18713, 18608, 19169, 19323, 250599, 252605, 280304, 252485, 18168, 17193, 873, 21134, 272851, 22383, 18821, 252484, 252483, 8708, 279266, 252561, 252604, 279265, 19147, 19168, 18609, 240993, 871, 9372, 18876, 14152, 279255, 279269, 14153, 272108, 272105, 276540, 271959, 22384, 227810,
		}
		local testItemsLookup = {}
		for _, id in ipairs(testItems) do testItemsLookup[id] = true end

		before_each(function()
			originalGetML = addon.GetML
			originalPrint = addon.Print
			originalSnapshot = addon.SnapshotInstanceData
			originalCallModule = addon.CallModule
			originalGetActiveModule = addon.GetActiveModule
		end)

		after_each(function()
			addon.GetML = originalGetML
			addon.Print = originalPrint
			addon.SnapshotInstanceData = originalSnapshot
			addon.CallModule = originalCallModule
			addon.GetActiveModule = originalGetActiveModule
			addon.testMode = false
		end)

		it("prints error and cancels test when not master looter", function()
			local printedMsg
			addon.GetML = function() return false, nil end
			addon.Print = function(self, msg) printedMsg = msg end

			addon:Test(3)

			assert.is_false(addon.testMode)
			assert.are.equal(L.error_test_as_non_leader, printedMsg)
		end)

		it("calls masterlooter module with test items when master looter", function()
			local snapshotCalled = false
			local callModuleCalled = false
			local newMLCalledWith
			local testItemsReceived

			addon.GetML = function() return true, "TestLeader" end
			addon.SnapshotInstanceData = function() snapshotCalled = true end
			addon.CallModule = function(self, mod)
				if mod == "masterlooter" then callModuleCalled = true end
			end
			addon.GetActiveModule = function(self, mod)
				return {
					NewML = function(_, ml) newMLCalledWith = ml end,
					Test = function(_, items) testItemsReceived = items end,
				}
			end

			addon:Test(5)

			assert.is_true(addon.testMode)
			assert.is_true(snapshotCalled)
			assert.is_true(callModuleCalled)
			assert.are.equal("TestLeader", newMLCalledWith)
			assert.is_table(testItemsReceived)
			assert.are.equal(5, #testItemsReceived)

			for _, itemID in ipairs(testItemsReceived) do
				assert.is_true(testItemsLookup[itemID])
			end
		end)
	end)
end)
