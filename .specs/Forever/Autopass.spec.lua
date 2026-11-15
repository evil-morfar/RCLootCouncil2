require "busted.runner"()

local addon = loadfile(".specs/AddonLoader.lua")(false, "RCLootCouncil", nil, 18).LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")

describe("#Forever #Autopass", function()
	local AutoPass = addon.AutoPass
	local autoPassTable = AutoPass.autopassTable
	before_each(function()
		addon.db:ResetDB()
	end)

	describe("AutoPassCheck hook", function()
		local armor = Enum.ItemClass.Armor
		local weapon = Enum.ItemClass.Weapon

		it("autopasses if autoPassSlot is enabled for equipLoc", function()
			local db = addon:Getdb()
			db.autoPassSlot = {
				INVTYPE_HEAD = true,
			}

			-- Should return true immediately regardless of anything else
			assert.is_true(AutoPass:AutoPassCheck("someLink", "INVTYPE_HEAD", armor, Enum.ItemArmorSubclass.Plate, 0xffffffff, "WARRIOR"))
		end)

		it("does not force autopass if autoPassSlot is false or not set for equipLoc", function()
			local db = addon:Getdb()
			db.classicAutoPass = false
			db.autoPassSlot = {
				INVTYPE_HEAD = false,
				INVTYPE_CHEST = true,
			}

			-- Plate chest on Warrior: autoPassSlot is false for HEAD
			local result = AutoPass:AutoPassCheck("someLink", "INVTYPE_HEAD", armor, Enum.ItemArmorSubclass.Plate, 0xffffffff, "WARRIOR")
			assert.is_false(result)
		end)

		it("autopasses un-equippable weapons and armor when classicAutoPass is enabled", function()
			local db = addon:Getdb()
			db.classicAutoPass = true
			db.autoPassSlot = nil

			local sIsEquippable = stub(C_Item, "IsEquippableItem").returns(false)

			assert.is_true(AutoPass:AutoPassCheck("someWeaponLink", "INVTYPE_WEAPON", weapon, Enum.ItemWeaponSubclass.Sword1H, 0xffffffff, "WARRIOR"))
			assert.is_true(AutoPass:AutoPassCheck("someArmorLink", "INVTYPE_CHEST", armor, Enum.ItemArmorSubclass.Plate, 0xffffffff, "WARRIOR"))

			sIsEquippable:revert()
		end)

		it("falls through to original check if equippable when classicAutoPass is enabled", function()
			local db = addon:Getdb()
			db.classicAutoPass = true
			db.autoPassSlot = nil

			local sIsEquippable = stub(C_Item, "IsEquippableItem").returns(true)

			-- Plate on Warrior is usable, so original AutoPassCheck returns false
			assert.is_false(AutoPass:AutoPassCheck("someArmorLink", "INVTYPE_CHEST", armor, Enum.ItemArmorSubclass.Plate, 0xffffffff, "WARRIOR"))

			-- Plate on Mage is not usable, so original AutoPassCheck returns true
			assert.is_true(AutoPass:AutoPassCheck("someArmorLink", "INVTYPE_CHEST", armor, Enum.ItemArmorSubclass.Plate, 0xffffffff, "MAGE"))

			sIsEquippable:revert()
		end)

		it("does not check classicAutoPass on non-weapon and non-armor item types", function()
			local db = addon:Getdb()
			db.classicAutoPass = true
			db.autoPassSlot = nil

			local sIsEquippable = spy.on(C_Item, "IsEquippableItem")

			-- Consumable item type
			AutoPass:AutoPassCheck("someConsumable", "", Enum.ItemClass.Consumable, 0, 0xffffffff, "WARRIOR")

			assert.spy(sIsEquippable).was_not.called()
			sIsEquippable:revert()
		end)

		it("delegates to original AutoPassCheck when classicAutoPass is disabled", function()
			local db = addon:Getdb()
			db.classicAutoPass = false
			db.autoPassSlot = nil

			local sIsEquippable = stub(C_Item, "IsEquippableItem").returns(false)

			-- When classicAutoPass is false, it shouldn't auto pass equippable plate on warrior based on classicAutoPass
			assert.is_false(AutoPass:AutoPassCheck("someArmorLink", "INVTYPE_CHEST", armor, Enum.ItemArmorSubclass.Plate, 0xffffffff, "WARRIOR"))

			sIsEquippable:revert()
		end)
	end)
end)
