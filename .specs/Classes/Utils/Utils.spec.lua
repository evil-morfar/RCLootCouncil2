require "busted.runner" ()

local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")

---@type RCLootCouncil.Utils
local Utils = addon.Utils

describe("#Utils :CheckOutdatedVersion", function()
	before_each(function()
		Utils = RCLootCouncil.Utils
	end)

	it("should exist", function()
		assert.is.Function(Utils.CheckOutdatedVersion)
	end)

	it("should not crash", function()
		assert.has_no.errors(function() Utils:CheckOutdatedVersion("", "") end)
	end)

	it("should report equal version", function()
		local res = Utils:CheckOutdatedVersion("2.15.0", "2.15.0")
		assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
		res = Utils:CheckOutdatedVersion("2.15.1", "2.15.1")
		assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
		res = Utils:CheckOutdatedVersion("3.0.0", "3.0.0")
		assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
		res = Utils:CheckOutdatedVersion("999.999.999", "999.999.999")
		assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
	end)

	it("should default to addon version", function()
		RCLootCouncil.version = "2.14.0"
		assert.are.equal(Utils:CheckOutdatedVersion(nil, "2.14.0"), RCLootCouncil.VER_CHECK_CODES[1])
	end)

	it("should report not-outdated versions", function()
		assert.are.equal(Utils:CheckOutdatedVersion("2.14.1", "2.14.0"), RCLootCouncil.VER_CHECK_CODES[1])
		assert.are.equal(Utils:CheckOutdatedVersion("2.15.1", "2.14.20"), RCLootCouncil.VER_CHECK_CODES[1])
		assert.are.equal(Utils:CheckOutdatedVersion("3.0.0", "2.14.20"), RCLootCouncil.VER_CHECK_CODES[1])
	end)

	it("should report outdated versions", function()
		assert.are.equal(Utils:CheckOutdatedVersion("2.14.2", "2.14.3"), RCLootCouncil.VER_CHECK_CODES[2])
		assert.are.equal(Utils:CheckOutdatedVersion("2.14.2", "2.15.1"), RCLootCouncil.VER_CHECK_CODES[2])
		assert.are.equal(Utils:CheckOutdatedVersion("2.14.2", "3.0.0"), RCLootCouncil.VER_CHECK_CODES[2])
	end)

	it("should handle test versions", function()
		assert.has_no.errors(function() Utils:CheckOutdatedVersion("2.0.0", "2.1.0", "Alpha.1", "Alpha.1") end)
	end)

	it("should handles outdated test versions", function()
		assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Alpha.2"),
			RCLootCouncil.VER_CHECK_CODES[3])
		assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Beta.1"),
			RCLootCouncil.VER_CHECK_CODES[3])
	end)

	it("should handle non-outdated test versions", function()
		assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.2", "Alpha.1"),
			RCLootCouncil.VER_CHECK_CODES[1])
		assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Beta.1", "Alpha.1"),
			RCLootCouncil.VER_CHECK_CODES[1])
	end)

	it("should handle equal test versions", function()
		assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Alpha.1"),
			RCLootCouncil.VER_CHECK_CODES[1])
		assert.are.equal(Utils:CheckOutdatedVersion("2.15.0", "2.15.0", "Alpha.1", "Alpha.1"),
			RCLootCouncil.VER_CHECK_CODES[1])
		assert.are.equal(Utils:CheckOutdatedVersion("2.15.0", "2.15.0", "Alpha.10", "Alpha.10"),
			RCLootCouncil.VER_CHECK_CODES[1])
	end)

	it("should not treat test versions as newer despite of main version", function()
		assert.are.equal(Utils:CheckOutdatedVersion("2.19.3", "3.0.0", nil, "Beta.1"), RCLootCouncil.VER_CHECK_CODES[1])
		assert.are.equal(Utils:CheckOutdatedVersion("3.0.0", "3.0.0", nil, "Beta.1"), RCLootCouncil.VER_CHECK_CODES[1])
	end)

	it("should handle releases of former test versions", function()
		assert.are.equal(Utils:CheckOutdatedVersion("3.0.0", "3.0.0", "Beta.1", nil), RCLootCouncil.VER_CHECK_CODES[2])
	end)

	it("should handle newer test versions", function()
		assert.are.equal(RCLootCouncil.VER_CHECK_CODES[1], Utils:CheckOutdatedVersion("3.0.1", "3.0.0", "Alpha.1", nil))
	end)
end)

describe("#Utils functions", function()
	before_each(function()
		Utils = RCLootCouncil.Utils
	end)

	describe("DiscardWeaponCorruption", function()
		it("should remove correct bonusID", function()
			local itemWith =
			"|cffa335ee|Hitem:172200::::::::120:104::5:7:4823:6572:6578:6579:1502:4786:6513:::|h[Sk'shuul~`Vaz]|h|r"
			local itemWithout =
			"|cffa335ee|Hitem:172200::::::::120:104::5:7:4823:6572:6578:6579:1502:4786:::|h[Sk'shuul~`Vaz]|h|r"
			assert.are.equal(itemWithout, Utils:DiscardWeaponCorruption(itemWith))
		end)

		it("shouldn't touch others", function()
			local item =
			"|cffa335ee|Hitem:174117::::::::120:256::5:5:4823:1502:4786:6509:4775:::|h[Spaulders of Miasmic Mycelia]|h|r"
			assert.are.equal(item, Utils:DiscardWeaponCorruption(item))
		end)

		it("should handle nils", function()
			assert.has_no.errors(function()
				assert.is_nil(Utils:DiscardWeaponCorruption(nil))
			end)
		end)
	end)

	describe("UnitName", function()
		local potdisc

		setup(function()
			potdisc = "Potdisc-Ravencrest"
		end)

		before_each(function()
			RCLootCouncil.realmName = "Ravencrest"
			Utils.unitNameLookup = {}
		end)
		it("should handle full name-realm", function()
			assert.equals(potdisc, Utils:UnitName(potdisc))
		end)

		it("should handle missing realm", function()
			assert.equals(potdisc, Utils:UnitName("Potdisc"))
			assert.equals(potdisc, Utils:UnitName("Potdisc-"))
		end)

		it("should cache found player names", function()
			Utils:UnitName("potdisc")
			assert.are.same(potdisc, Utils.unitNameLookup["potdisc"])
			Utils:UnitName(potdisc)
			assert.are.same(potdisc, Utils.unitNameLookup[potdisc])
		end)

		it("should not cache names ending with '-'", function()
			RCLootCouncil.realmName = ""
			Utils:UnitName("potdisc")
			Utils:UnitName("potdisc-")
			assert.are.same({}, Utils.unitNameLookup)
		end)

		it("can handle missing param", function()
			assert.has_no.errors(function()
				Utils:UnitName()
			end)
		end)
	end)
end)

describe("#Utils *HasVersion", function()
	describe("#GroupHasVersion", function()
		before_each(function()
			_G.IsInGroupVal = true
			addon.candidatesInGroup = {
				a = true,
				b = true,
				c = true,
				d = true,
			}
			addon.db = {
				global = {
					verTestCandidates = {
						a = { "3.0.0", false, time() - math.random(1, 100), },
						b = { "3.0.1", false, time() - math.random(1, 100), },
						c = { "3.0.2", false, time() - math.random(1, 100), },
						d = { "3.0.3", false, time() - math.random(1, 100), },
					},
				},
			}
		end)
		it("should return true when we're not in a group", function()
			_G.IsInGroupVal = false
			assert.True(Utils:GroupHasVersion())
		end)

		it("should return true when everyone has a newer version", function()
			assert.True(Utils:GroupHasVersion("3.0.0"))
		end)

		it("should return false if someone is outdated", function()
			assert.False(Utils:GroupHasVersion("3.0.1"))
		end)

		it("should return true if someone doesn't have a version recorded", function()
			addon.candidatesInGroup["e"] = true
			assert.True(Utils:GroupHasVersion("3.0.0"))
		end)

		it("should return false if someone doesn't have a version recorded and using strict", function()
			addon.candidatesInGroup["e"] = true
			assert.False(Utils:GroupHasVersion("3.0.0", true))
		end)

		it("should return true if their record is outdated", function()
			addon.db.global.verTestCandidates.d[3] = -1
			addon.db.global.verTestCandidates.d[1] = "2.9.0"

			assert.True(Utils:GroupHasVersion("3.0.0"))
		end)

		it("should return false if their record is outdated in strict", function()
			addon.db.global.verTestCandidates.d[3] = -1
			addon.db.global.verTestCandidates.d[1] = "2.9.0"
			assert.False(Utils:GroupHasVersion("3.0.0", true))
		end)
	end)

	describe("#PlayersHasVersion", function()
		before_each(function()
			addon.candidatesInGroup = {
				a = true,
				b = true,
				c = true,
				d = true,
			}
			addon.db = {
				global = {
					verTestCandidates = {
						a = { "3.0.0", false, time() - math.random(1, 100), },
						b = { "3.0.1", false, time() - math.random(1, 100), },
						c = { "3.0.2", false, time() - math.random(1, 100), },
						d = { "3.0.3", false, time() - math.random(1, 100), },
					},
				},
			}
		end)

		local createPlayer = function(name) return { name = name, } end

		it("should return true if everyone has version or newer", function()
			assert.True(Utils:PlayersHasVersion({ createPlayer("a"), createPlayer("b"), }, "3.0.0"))
		end)
		it("should return false if someone doesn't have a version", function()
			assert.False(Utils:PlayersHasVersion({ createPlayer("a"), createPlayer("b"), }, "3.0.1"))
		end)
	end)
end)
