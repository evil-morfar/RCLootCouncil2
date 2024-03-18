--- @type RCLootCouncil
local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")

--- autopassing
describe("#Utils #Autopass", function()
	before_each(function()
		addon.db:ResetDB()
	end)

	describe("transmog", function()
		it("should not autopass items if 'disabled' and player can transmog into it", function()
			local t = { GetItemInfo(165597), }
			addon:Getdb().autoPassTransmog = true
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], 0xffffffff, nil, nil, "DEATHKNIGHT"))
			addon:Getdb().autoPassTransmog = false

			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], 0xffffffff, nil, nil, "DEATHKNIGHT"))
			addon:Getdb().autoPassTransmogSource = false
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], 0xffffffff, nil, nil, "DEATHKNIGHT"))
		end)
	end)

	describe("classesFlag", function()
		it("should autopass when flag doesn't contain our class", function()
			-- No class defaults to Warrior
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, 0))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, 0, nil, nil, "WARRIOR"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, 0, nil, nil, "PALADIN"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1111111111101", 2), nil, nil, "PALADIN"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1111111111011", 2), nil, nil, "HUNTER"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1111111110111", 2), nil, nil, "ROGUE"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1111111101111", 2), nil, nil, "PRIEST"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1111111011111", 2), nil, nil, "DEATHKNIGHT"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1111110111111", 2), nil, nil, "SHAMAN"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1111101111111", 2), nil, nil, "MAGE"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1111011111111", 2), nil, nil, "WARLOCK"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1110111111111", 2), nil, nil, "MONK"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1101111111111", 2), nil, nil, "DRUID"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1011111111111", 2), nil, nil, "DEMONHUNTER"))
			assert.True(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0111111111111", 2), nil, nil, "EVOKER"))
		end)

		it("should not autopass when flag contains our class", function()
			-- No class defaults to Warrior
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, 1))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, 1, nil, nil, "WARRIOR"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0000000000010", 2), nil, nil, "PALADIN"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0000000000100", 2), nil, nil, "HUNTER"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0000000001000", 2), nil, nil, "ROGUE"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0000000010000", 2), nil, nil, "PRIEST"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0000000100000", 2), nil, nil, "DEATHKNIGHT"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0000001000000", 2), nil, nil, "SHAMAN"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0000010000000", 2), nil, nil, "MAGE"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0000100000000", 2), nil, nil, "WARLOCK"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0001000000000", 2), nil, nil, "MONK"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0010000000000", 2), nil, nil, "DRUID"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("0100000000000", 2), nil, nil, "DEMONHUNTER"))
			assert.False(addon:AutoPassCheck(nil, nil, nil, nil, tonumber("1000000000000", 2), nil, nil, "EVOKER"))
		end)
	end)

	describe("trinkets", function()
		it("when enabled, should only auto pass trinkets our class can't use", function()
			local t = { GetItemInfo(155881), } -- "0365002007700", -- Harlan's Loaded Dice
			local id = addon.classIDToFileName
			local all = 0xffffffff
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[1]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[2]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[3]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[4]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[5]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[6]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[7]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[8]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[9]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[10]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[11]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[12]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[13]))

			t = { GetItemInfo(158712), } -- "0000000700067", -- Rezan's Gleaming Eye
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[1]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[2]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[3]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[4]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[5]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[6]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[7]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[8]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[9]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[10]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[11]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[12]))
			assert.True(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[13]))
		end)

		it("should never autopass trinkets when disabled", function()
			addon:Getdb().autoPassTrinket = false
			local t = { GetItemInfo(155881), } -- "0365002007700", -- Harlan's Loaded Dice
			local id = addon.classIDToFileName
			local all = 0xffffffff
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[1]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[2]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[3]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[4]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[5]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[6]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[7]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[8]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[9]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[10]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[11]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[12]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[13]))

			t = { GetItemInfo(158712), } -- "0000000700067", -- Rezan's Gleaming Eye
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[1]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[2]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[3]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[4]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[5]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[6]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[7]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[8]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[9]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[10]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[11]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[12]))
			assert.False(addon:AutoPassCheck(t[2], t[9], t[12], t[13], all, nil, nil, id[13]))
		end)
	end)

	--- items that a class can't use should be auto passed
	describe("item type autopass", function()
		it("should never autopass items contained in the override table (unless covered by the above)", function()
			assert.False(addon:AutoPassCheck(nil, "INVTYPE_CLOAK", nil, nil, 0xffffffff))
			-- Will auto pass due to our class not in flag
			assert.True(addon:AutoPassCheck(nil, "INVTYPE_CLOAK", nil, nil, 0))
		end)

		it("should autopass if the type/subtype is listed for our class in the autopass table", function()
			local armor = Enum.ItemClass.Armor
			local cloth = Enum.ItemArmorSubclass.Cloth
			local leather = Enum.ItemArmorSubclass.Leather
			local mail = Enum.ItemArmorSubclass.Mail
			local plate = Enum.ItemArmorSubclass.Plate
			assert.True(addon:AutoPassCheck(nil, nil, armor, cloth, 0xffffffff))
			assert.True(addon:AutoPassCheck(nil, nil, armor, cloth, 0xffffffff, nil, nil, "PALADIN"))
			assert.True(addon:AutoPassCheck(nil, nil, armor, cloth, 0xffffffff, nil, nil, "SHAMAN"))
			assert.False(addon:AutoPassCheck(nil, nil, armor, cloth, 0xffffffff, nil, nil, "PRIEST"))
			assert.True(addon:AutoPassCheck(nil, nil, armor, leather, 0xffffffff, nil, nil, "SHAMAN"))
			assert.True(addon:AutoPassCheck(nil, nil, armor, leather, 0xffffffff, nil, nil, "WARRIOR"))
			assert.True(addon:AutoPassCheck(nil, nil, armor, leather, 0xffffffff, nil, nil, "PRIEST"))
			assert.False(addon:AutoPassCheck(nil, nil, armor, leather, 0xffffffff, nil, nil, "DRUID"))
			assert.False(addon:AutoPassCheck(nil, nil, armor, mail, 0xffffffff, nil, nil, "SHAMAN"))
			assert.False(addon:AutoPassCheck(nil, nil, armor, mail, 0xffffffff, nil, nil, "HUNTER"))
			assert.True(addon:AutoPassCheck(nil, nil, armor, mail, 0xffffffff, nil, nil, "WARRIOR"))
			assert.True(addon:AutoPassCheck(nil, nil, armor, mail, 0xffffffff, nil, nil, "PRIEST"))
			assert.True(addon:AutoPassCheck(nil, nil, armor, plate, 0xffffffff, nil, nil, "PRIEST"))
			assert.True(addon:AutoPassCheck(nil, nil, armor, plate, 0xffffffff, nil, nil, "SHAMAN"))
			assert.False(addon:AutoPassCheck(nil, nil, armor, plate, 0xffffffff, nil, nil, "WARRIOR"))
			assert.False(addon:AutoPassCheck(nil, nil, armor, plate, 0xffffffff, nil, nil, "DEATHKNIGHT"))

			local weapon = Enum.ItemClass.Weapon
			local bows = Enum.ItemWeaponSubclass.Bows
			local dagger = Enum.ItemWeaponSubclass.Dagger
			assert.True(addon:AutoPassCheck(nil, nil, weapon, bows, 0xffffffff, nil, nil, "PALADIN"))
			assert.True(addon:AutoPassCheck(nil, nil, weapon, bows, 0xffffffff, nil, nil, "DRUID"))
			assert.True(addon:AutoPassCheck(nil, nil, weapon, bows, 0xffffffff, nil, nil, "PRIEST"))
			assert.False(addon:AutoPassCheck(nil, nil, weapon, bows, 0xffffffff, nil, nil, "HUNTER"))
			assert.True(addon:AutoPassCheck(nil, nil, weapon, dagger, 0xffffffff, nil, nil, "PALADIN"))
			assert.True(addon:AutoPassCheck(nil, nil, weapon, dagger, 0xffffffff, nil, nil, "DEATHKNIGHT"))
			assert.False(addon:AutoPassCheck(nil, nil, weapon, dagger, 0xffffffff, nil, nil, "PRIEST"))
		end)
	end)

	--- if not handled elsewhere, weapons that lack the stat required for the class should be autopassed
	describe("weapon stat autopass", function()
		--- not sure why I included the guard, but might as well test it :)
		it("should handle invalid class", function()
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WRONG_CLASS"))
		end)

		it("should not autopass an item it can't retrive the stats from", function()
			assert.False(addon:AutoPassCheck(nil, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARRIOR"))
			assert.False(addon:AutoPassCheck(12345, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARRIOR"))
		end)

		it("should not autopass on items without primary stats", function()
			assert.False(addon:AutoPassCheck(210214, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARRIOR"))
		end)

		it("should autopass if weapon is missing a stat our class requires", function()
			-- Agility
			assert.True(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARRIOR"))
			assert.True(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "PRIEST"))
			assert.True(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "PALADIN"))
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "ROGUE"))
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "HUNTER"))
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "SHAMAN"))
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "DRUID"))
			-- Strength
			assert.True(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "PRIEST"))
			assert.True(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "HUNTER"))
			assert.True(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "DRUID"))
			assert.False(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARRIOR"))
			assert.False(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "PALADIN"))
			assert.False(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "DEATHKNIGHT"))
			-- Intellect
			assert.True(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARRIOR"))
			assert.True(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "HUNTER"))
			assert.True(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "ROGUE"))
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "PRIEST"))
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "DRUID"))
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "MAGE"))
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARLOCK"))
		end)

		it("should not auto pass weapons when disabled", function()
			addon:Getdb().autoPassWeapons = false
			-- Agility
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARRIOR"))
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "PRIEST"))
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "PALADIN"))
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "ROGUE"))
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "HUNTER"))
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "SHAMAN"))
			assert.False(addon:AutoPassCheck(207781, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "DRUID"))
			-- Strength
			assert.False(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "PRIEST"))
			assert.False(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "HUNTER"))
			assert.False(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "DRUID"))
			assert.False(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARRIOR"))
			assert.False(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "PALADIN"))
			assert.False(addon:AutoPassCheck(207786, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "DEATHKNIGHT"))
			-- Intellect
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARRIOR"))
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "HUNTER"))
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "ROGUE"))
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "PRIEST"))
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "DRUID"))
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "MAGE"))
			assert.False(addon:AutoPassCheck(207788, nil, Enum.ItemClass.Weapon, nil, 0xffffffff, nil, nil, "WARLOCK"))
		end)
	end)
end)
