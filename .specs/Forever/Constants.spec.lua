require "busted.runner"()

local addon = loadfile(".specs/AddonLoader.lua")(false, "RCLootCouncil", nil, 18).LoadToc("RCLootCouncil.toc")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

describe("#Forever #Constants", function()

	describe("slot mapping", function()
		it("maps ranged slots to RangedSlot", function()
			assert.are.equal("RangedSlot", addon.INVTYPE_Slots.INVTYPE_RANGED)
			assert.are.equal("RangedSlot", addon.INVTYPE_Slots.INVTYPE_RANGEDRIGHT)
			assert.are.equal("RangedSlot", addon.INVTYPE_Slots.INVTYPE_THROWN)
		end)

		it("maps relic slot", function()
			assert.is_table(addon.INVTYPE_Slots.INVTYPE_RELIC)
			assert.are.equal("RelicSlot ", addon.INVTYPE_Slots.INVTYPE_RELIC[1])
			assert.are.equal(_G.INVTYPE_RELIC, addon.OPT_MORE_BUTTONS_VALUES.INVTYPE_RELIC)
		end)
	end)

	describe("button groups", function()
		it("removes unneeded retail button groups", function()
			assert.is_nil(addon.OPT_MORE_BUTTONS_VALUES.PETS)
			assert.is_nil(addon.OPT_MORE_BUTTONS_VALUES.CATALYST)
			assert.is_nil(addon.OPT_MORE_BUTTONS_VALUES.DECOR)
			assert.is_nil(addon.OPT_MORE_BUTTONS_VALUES.RARE)
		end)

		it("adds SETS button group", function()
			assert.are.equal(L.SET_PIECES, addon.OPT_MORE_BUTTONS_VALUES.SETS)
		end)
	end)

	describe("SETS response code generator", function()
		it("returns SETS when enabledButtons.SETS is true and item is a set piece", function()
			addon:OnInitialize()
			local db = addon:Getdb()
			db.enabledButtons.SETS = true

			local setItem = 165512
			assert.are.equal("SETS", addon:GetTypeCodeForItem(setItem))
		end)

		it("does not return SETS when enabledButtons.SETS is false", function()
			addon:OnInitialize()
			local db = addon:Getdb()
			db.enabledButtons.SETS = false

			local setItem = 165512
			assert.are_not.equal("SETS", addon:GetTypeCodeForItem(setItem))
		end)

		it("does not return SETS for items without a set", function()
			addon:OnInitialize()
			local db = addon:Getdb()
			db.enabledButtons.SETS = true

			local nonSetItem = 158355
			assert.are_not.equal("SETS", addon:GetTypeCodeForItem(nonSetItem))
		end)
	end)
end)
