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

--- Add a particular stat to a weapon
local weaponStatAdditions = {
	[232526] = { "ITEM_MOD_INTELLECT_SHORT", }, -- Best-In-Slots: Agi/Str version can be turned into the int version
	[232805] = { "ITEM_MOD_INTELLECT_SHORT", }, -- Best-In-Slots: Int version can be turned into the Agi/Str version
}

--- Classes that should autopass a subtype.
-- @table autopassTable
local autopassTable = {
	[Enum.ItemClass.Armor] = {

		[Enum.ItemArmorSubclass.Cloth] = { "WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER",
			"SHAMAN",

			"DEMONHUNTER", "EVOKER", },
		[Enum.ItemArmorSubclass.Leather] = { "WARRIOR", "DEATHKNIGHT", "PALADIN", "HUNTER", "SHAMAN", "PRIEST", "MAGE",
			"WARLOCK",

			"EVOKER", },

		[Enum.ItemArmorSubclass.Mail] = { "WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST",
			"MAGE", "WARLOCK",

			"DEMONHUNTER", },

		[Enum.ItemArmorSubclass.Plate] = { "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK",
			"DEMONHUNTER",

			"EVOKER", },

		[Enum.ItemArmorSubclass.Shield] = { "DEATHKNIGHT", "DRUID", "MONK", "ROGUE", "HUNTER", "PRIEST", "MAGE",
			"WARLOCK",

			"DEMONHUNTER", "EVOKER", },

	},
	[Enum.ItemClass.Weapon] = {
		[Enum.ItemWeaponSubclass.Axe1H] = { "DRUID", "PRIEST", "MAGE", "WARLOCK", },

		[Enum.ItemWeaponSubclass.Axe2H] = { "DRUID", "ROGUE", "MONK", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "EVOKER", },


		[Enum.ItemWeaponSubclass.Bows] = { "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE",
			"WARLOCK",
			"DEMONHUNTER", "WARRIOR", "EVOKER", },

		[Enum.ItemWeaponSubclass.Crossbow] = { "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE",
			"WARLOCK",

			"DEMONHUNTER", "WARRIOR", "EVOKER", },

		[Enum.ItemWeaponSubclass.Dagger] = { "DEATHKNIGHT", "PALADIN", "MONK", "DEMONHUNTER", },

		[Enum.ItemWeaponSubclass.Guns] = { "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE",
			"WARLOCK",

			"DEMONHUNTER", "WARRIOR", "EVOKER", },

		[Enum.ItemWeaponSubclass.Mace1H] = { "HUNTER", "MAGE", "WARLOCK", "DEMONHUNTER", },

		[Enum.ItemWeaponSubclass.Mace2H] = { "MONK", "ROGUE", "HUNTER", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER" },


		[Enum.ItemWeaponSubclass.Polearm] = { "ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "EVOKER", },


		[Enum.ItemWeaponSubclass.Sword1H] = { "DRUID", "SHAMAN", "PRIEST", },

		[Enum.ItemWeaponSubclass.Sword2H] = { "DRUID", "MONK", "ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "EVOKER", },


		[Enum.ItemWeaponSubclass.Staff] = { "DEATHKNIGHT", "PALADIN", "ROGUE", "DEMONHUNTER", },

		[Enum.ItemWeaponSubclass.Wand] = { "WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER",
			"SHAMAN",

			"DEMONHUNTER", "EVOKER", },

		[Enum.ItemWeaponSubclass.Warglaive] = { "WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST",
			"MAGE",

			"WARLOCK", "HUNTER", "SHAMAN", "EVOKER", },

		[Enum.ItemWeaponSubclass.Unarmed] = { "DEATHKNIGHT", "PALADIN", "PRIEST", "MAGE", "WARLOCK", }, -- Fist weapons

	},
}

--- Types of relics. Thanks to xmyno for the list.
-- NOTE I'm not sure if the return from C_ArtifactUI.GetRelicInfoByItemID() is localized
-- @table relicTypes
local relicTypes = {
	BLOOD  = "Blood",
	SHADOW = "Shadow",
	IRON   = "Iron",
	FROST  = "Frost",
	FIRE   = "Fire",
	FEL    = "Fel",
	ARCANE = "Arcane",
	LIFE   = "Life",
	STORM  = "Wind", -- Great job Blizzard -.-
	HOLY   = "Holy",
}

--- The type of relic each class can use
-- @table relics
local relics = {
	DEATHKNIGHT = { relicTypes.BLOOD, relicTypes.SHADOW, relicTypes.IRON, relicTypes.FROST, relicTypes.FIRE, },
	DEMONHUNTER = { relicTypes.FEL, relicTypes.SHADOW, relicTypes.IRON, relicTypes.ARCANE, },
	DRUID       = { relicTypes.ARCANE, relicTypes.LIFE, relicTypes.FIRE, relicTypes.BLOOD, relicTypes.FROST, },
	HUNTER      = { relicTypes.STORM, relicTypes.ARCANE, relicTypes.IRON, relicTypes.BLOOD, relicTypes.LIFE, },
	MAGE        = { relicTypes.ARCANE, relicTypes.FROST, relicTypes.FIRE, },
	MONK        = { relicTypes.LIFE, relicTypes.STORM, relicTypes.IRON, relicTypes.FROST, },
	PALADIN     = { relicTypes.HOLY, relicTypes.LIFE, relicTypes.FIRE, relicTypes.IRON, relicTypes.ARCANE, },
	PRIEST      = { relicTypes.HOLY, relicTypes.SHADOW, relicTypes.LIFE, relicTypes.BLOOD, },
	ROGUE       = { relicTypes.SHADOW, relicTypes.IRON, relicTypes.BLOOD, relicTypes.STORM, relicTypes.FEL, },
	SHAMAN      = { relicTypes.STORM, relicTypes.FROST, relicTypes.FIRE, relicTypes.IRON, relicTypes.LIFE, },
	WARLOCK     = { relicTypes.SHADOW, relicTypes.BLOOD, relicTypes.FIRE, relicTypes.FEL, },
	WARRIOR     = { relicTypes.IRON, relicTypes.BLOOD, relicTypes.SHADOW, relicTypes.FIRE, relicTypes.STORM, },
}

--- The stat(s) a weapon must have one of to be usable by a class.
local requiredWeaponStatsForClass = {
	WARRIOR = { "ITEM_MOD_STRENGTH_SHORT", },
	PALADIN = { "ITEM_MOD_STRENGTH_SHORT", "ITEM_MOD_INTELLECT_SHORT", },
	HUNTER = { "ITEM_MOD_AGILITY_SHORT", },
	ROGUE = { "ITEM_MOD_AGILITY_SHORT", },
	PRIEST = { "ITEM_MOD_INTELLECT_SHORT", },
	DEATHKNIGHT = { "ITEM_MOD_STRENGTH_SHORT", },
	SHAMAN = { "ITEM_MOD_INTELLECT_SHORT", "ITEM_MOD_AGILITY_SHORT", },
	MAGE = { "ITEM_MOD_INTELLECT_SHORT", },
	WARLOCK = { "ITEM_MOD_INTELLECT_SHORT", },
	MONK = { "ITEM_MOD_INTELLECT_SHORT", "ITEM_MOD_AGILITY_SHORT", },
	DRUID = { "ITEM_MOD_INTELLECT_SHORT", "ITEM_MOD_AGILITY_SHORT", },
	DEMONHUNTER = { "ITEM_MOD_AGILITY_SHORT", },
	EVOKER = { "ITEM_MOD_INTELLECT_SHORT", },
}

--- Returns false if the given item contains any of the stats required for the class
--- as determined by the `requiredWeaponStatsForClass` list OR the item doesn't have any main stat.
---@param itemLink ItemLink item to check
---@param class ClassInfo.classFile Class to check against.
---@param id number itemID
local function ShouldAutoPassWeapon(itemLink, class, id)
	-- Ensure class is valid
	if not requiredWeaponStatsForClass[class] then
		addon.Log:e("Invalid class in 'ShouldAutoPassWeapon'", class)
		return false
	end

	local stats = C_Item.GetItemStats(itemLink or "")

	-- Ensure item is loaded
	if not stats then
		addon.Log:d("Couldn't get stats for non-loaded item:", itemLink)
		return false
	end

	-- Ensure it has any main stat
	if not (stats.ITEM_MOD_STRENGTH_SHORT or
			stats.ITEM_MOD_AGILITY_SHORT or
			stats.ITEM_MOD_INTELLECT_SHORT) then
		return false
	end

	-- Check each class stat against the item's stats
	for _, stat in ipairs(requiredWeaponStatsForClass[class]) do
		if stats[stat] then return false end
	end

	-- Check for special items with stat additions
	if weaponStatAdditions[id] then
		for _, stat in ipairs(weaponStatAdditions[id]) do
			if tContains(requiredWeaponStatsForClass[class], stat) then return false end
		end
	end

	-- If all checks fails, then we must autopass the item
	return true
end


--- Checks if the player should autopass on a given item.
--- All params are supplied by the lootTable from the ML.
--- Checks for a specific class if `class` arg is provided, otherwise the player's class.
--- This method does not consider the "global" `db.autoPass` flag, but does consider granular
--- ones like `db.autoPassTrinket`.
---@param link ItemLink Item to check.
---@param equipLoc string Equipable location.
---@param typeID Enum.ItemClass ItemTypeID
---@param subTypeID Enum.ItemWeaponSubclass | Enum.ItemArmorSubclass ItemSubTypeID
---@param classesFlag string As returned by `RCLootCouncil:GetItemClassesAllowedFlag()`.
---@param isToken? string Non-nil if item is a token.
---@param isRelic? any @deprecated
---@param class? string Class file, e.g. 'WARRIOR'. Used as the base class if provided, defaults to player's class.
---@return boolean #True if the player should autopass.
--- ```
--- -- Check if the item in session 1 should be auto passed:
--- local dat = lootTable[1] -- Shortening
--- local shouldAutoPass = RCLootCouncil:AutoPassCheck(dat.link, dat.equipLoc, dat.typeID, dat.subTypeID, dat.classesFlag, dat.isToken, dat.isRelic)
--- ```
function RCLootCouncil:AutoPassCheck(link, equipLoc, typeID, subTypeID, classesFlag, isToken, isRelic, class)
	link = link or "" -- Just to avoid errors in case someone passes a nil value
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
	local classID = self.classTagNameToID[class] or 0
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
			if tContains(autopassTable[typeID][subTypeID], class) then
				return true
			end
		end
	end

	if typeID == Enum.ItemClass.Weapon then
		if self:Getdb().autoPassWeapons and ShouldAutoPassWeapon(link, class, id) then
			self.Log:D("Weapon auto pass on ", link)
			return true
		end
	end

	return false
end
