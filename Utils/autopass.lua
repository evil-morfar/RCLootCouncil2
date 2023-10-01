--- autopass.lua Contains everything related to autopassing
-- @author	Potdisc
-- Create Date : 23/9/2016

---@type RCLootCouncil
local addon = select(2, ...)
local ItemUtils = addon.Require "Utils.Item"

--- Never autopass these armor types.
-- @table autopassOverride
local autopassOverride = {
	"INVTYPE_CLOAK",
}

--- Classes that should autopass a subtype.
-- @table autopassTable
local autopassTable = {
	[Enum.ItemClass.Armor] = {

		[Enum.ItemArmorSubclass.Cloth] = { "WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN",

			"DEMONHUNTER", "EVOKER" },
		[Enum.ItemArmorSubclass.Leather] = { "WARRIOR", "DEATHKNIGHT", "PALADIN", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK",

			"EVOKER" },

		[Enum.ItemArmorSubclass.Mail] = { "WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST",
			"MAGE", "WARLOCK",

			"DEMONHUNTER" },

		[Enum.ItemArmorSubclass.Plate] = { "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER",

			"EVOKER" },

		[Enum.ItemArmorSubclass.Shield] = { "DEATHKNIGHT", "DRUID", "MONK", "ROGUE", "HUNTER", "PRIEST", "MAGE", "WARLOCK",

			"DEMONHUNTER", "EVOKER" },

	},
	[Enum.ItemClass.Weapon] = {
		[Enum.ItemWeaponSubclass.Axe1H] = { "DRUID", "PRIEST", "MAGE", "WARLOCK" },

		[Enum.ItemWeaponSubclass.Axe2H] = { "DRUID", "ROGUE", "MONK", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "EVOKER" },


		[Enum.ItemWeaponSubclass.Bows] = { "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK",
			"DEMONHUNTER", "WARRIOR", "EVOKER" },

		[Enum.ItemWeaponSubclass.Crossbow] = { "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK",

			"DEMONHUNTER", "WARRIOR", "EVOKER" },

		[Enum.ItemWeaponSubclass.Dagger] = { "DEATHKNIGHT", "PALADIN", "MONK", "DEMONHUNTER" },

		[Enum.ItemWeaponSubclass.Guns] = { "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK",

			"DEMONHUNTER", "WARRIOR", "EVOKER" },

		[Enum.ItemWeaponSubclass.Mace1H] = { "HUNTER", "MAGE", "WARLOCK", "DEMONHUNTER" },

		[Enum.ItemWeaponSubclass.Mace2H] = { "MONK", "ROGUE", "HUNTER", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "EVOKER" },


		[Enum.ItemWeaponSubclass.Polearm] = { "ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "EVOKER" },


		[Enum.ItemWeaponSubclass.Sword1H] = { "DRUID", "SHAMAN", "PRIEST", },

		[Enum.ItemWeaponSubclass.Sword2H] = { "DRUID", "MONK", "ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "EVOKER" },


		[Enum.ItemWeaponSubclass.Staff] = { "DEATHKNIGHT", "PALADIN", "ROGUE", "DEMONHUNTER" },

		[Enum.ItemWeaponSubclass.Wand] = { "WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN",

			"DEMONHUNTER", "EVOKER" },

		[Enum.ItemWeaponSubclass.Warglaive] = { "WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST", "MAGE",

			"WARLOCK", "HUNTER", "SHAMAN", "EVOKER" },

		[Enum.ItemWeaponSubclass.Unarmed] = { "DEATHKNIGHT", "PALADIN", "PRIEST", "MAGE", "WARLOCK" }, -- Fist weapons

	},
}

--- Types of relics. Thanks to xmyno for the list.
-- NOTE I'm not sure if the return from C_ArtifactUI.GetRelicInfoByItemID() is localized
-- @table relicTypes
local relicTypes = {
	BLOOD  = 'Blood',
	SHADOW = 'Shadow',
	IRON   = 'Iron',
	FROST  = 'Frost',
	FIRE   = 'Fire',
	FEL    = 'Fel',
	ARCANE = 'Arcane',
	LIFE   = 'Life',
	STORM  = 'Wind', -- Great job Blizzard -.-
	HOLY   = 'Holy'
}

--- The type of relic each class can use
-- @table relics
local relics = {
	DEATHKNIGHT = { relicTypes.BLOOD, relicTypes.SHADOW, relicTypes.IRON, relicTypes.FROST, relicTypes.FIRE },
	DEMONHUNTER = { relicTypes.FEL, relicTypes.SHADOW, relicTypes.IRON, relicTypes.ARCANE },
	DRUID       = { relicTypes.ARCANE, relicTypes.LIFE, relicTypes.FIRE, relicTypes.BLOOD, relicTypes.FROST },
	HUNTER      = { relicTypes.STORM, relicTypes.ARCANE, relicTypes.IRON, relicTypes.BLOOD, relicTypes.LIFE },
	MAGE        = { relicTypes.ARCANE, relicTypes.FROST, relicTypes.FIRE },
	MONK        = { relicTypes.LIFE, relicTypes.STORM, relicTypes.IRON, relicTypes.FROST },
	PALADIN     = { relicTypes.HOLY, relicTypes.LIFE, relicTypes.FIRE, relicTypes.IRON, relicTypes.ARCANE },
	PRIEST      = { relicTypes.HOLY, relicTypes.SHADOW, relicTypes.LIFE, relicTypes.BLOOD },
	ROGUE       = { relicTypes.SHADOW, relicTypes.IRON, relicTypes.BLOOD, relicTypes.STORM, relicTypes.FEL },
	SHAMAN      = { relicTypes.STORM, relicTypes.FROST, relicTypes.FIRE, relicTypes.IRON, relicTypes.LIFE },
	WARLOCK     = { relicTypes.SHADOW, relicTypes.BLOOD, relicTypes.FIRE, relicTypes.FEL },
	WARRIOR     = { relicTypes.IRON, relicTypes.BLOOD, relicTypes.SHADOW, relicTypes.FIRE, relicTypes.STORM },
}

--- Checks if the player should autopass on a given item.
-- All params are supplied by the lootTable from the ML.
-- Checks for a specific class if 'class' arg is provided, otherwise the player's class.
-- @usage
-- -- Check if the item in session 1 should be auto passed:
-- local dat = lootTable[1] -- Shortening
-- local boolean = RCLootCouncil:AutoPassCheck(dat.link, dat.equipLoc, dat.typeID, dat.subTypeID, dat.classesFlag, dat.isToken, dat.isRelic)
--@return true if the player should autopass the given item.
function RCLootCouncil:AutoPassCheck(link, equipLoc, typeID, subTypeID, classesFlag, isToken, isRelic, class)
	if (not self:Getdb().autoPassTransmog and self:IsTransmoggable(link)) then
		local playerKnowsTransmog

		if self:Getdb().autoPassTransmogSource then
			playerKnowsTransmog = self:PlayerKnowsTransmog(link)
		else
			playerKnowsTransmog = self:PlayerKnowsTransmogFromItem(link)
		end

		if not playerKnowsTransmog and (self:CharacterCanLearnTransmog(link) or self:IsItemBoE(link)) then return false end
	end


	local class = class or self.playerClass
	local classID = self.classTagNameToID[class]
	if bit.band(classesFlag, bit.lshift(1, classID - 1)) == 0 then -- The item tooltip writes the allowed clases, but our class is not in it.
		return true
	end
	local id = type(link) == "number" and link or ItemUtils:GetItemIDFromLink(link) -- Convert to id if needed
	if equipLoc == "INVTYPE_TRINKET" then
		if self:Getdb().autoPassTrinket then
			if _G.RCTrinketSpecs and _G.RCTrinketSpecs[id] and _G.RCTrinketSpecs[id]:sub(-classID, -classID) == "0" then
				return true
			end
		end
	end
	if not tContains(autopassOverride, equipLoc) then
		if autopassTable[typeID] and autopassTable[typeID][subTypeID] then
			return tContains(autopassTable[typeID][subTypeID], class)
		end
	end
	return false
end
