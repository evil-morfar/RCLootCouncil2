--- autopass.lua	Contains everything related to autopassing
-- @author	Potdisc
-- Create Date : 23/9/2016

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

--- Never autopass these armor types.
-- @table autopassOverride
local autopassOverride = {
	"INVTYPE_CLOAK",
}

--- Classes that should autopass a subtype.
-- @table autopassTable
local autopassTable = {
	[LE_ITEM_CLASS_ARMOR] = {
		[LE_ITEM_ARMOR_CLOTH]		= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "DEMONHUNTER"},
		[LE_ITEM_ARMOR_LEATHER] 	= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK"},
		[LE_ITEM_ARMOR_MAIL] 		= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
		[LE_ITEM_ARMOR_PLATE]		= {"DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
		[LE_ITEM_ARMOR_SHIELD] 		= {"DEATHKNIGHT", "DRUID", "MONK", "ROGUE", "HUNTER","PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	},
	[LE_ITEM_CLASS_WEAPON] = {
		[LE_ITEM_WEAPON_AXE1H]		= {"DRUID", "PRIEST", "MAGE", "WARLOCK"},
		[LE_ITEM_WEAPON_AXE2H]		= {"DRUID", "ROGUE", "MONK", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
		[LE_ITEM_WEAPON_BOWS] 		= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "WARRIOR"},
		[LE_ITEM_WEAPON_CROSSBOW] 	= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "WARRIOR"},
		[LE_ITEM_WEAPON_DAGGER]		= {"DEATHKNIGHT", "PALADIN", "MONK", },
		[LE_ITEM_WEAPON_GUNS]		= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK","SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "WARRIOR"},
		[LE_ITEM_WEAPON_MACE1H]		= {"HUNTER", "MAGE", "WARLOCK", "DEMONHUNTER"},
		[LE_ITEM_WEAPON_MACE2H]		= {"MONK", "ROGUE", "HUNTER", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
		[LE_ITEM_WEAPON_POLEARM] 	= {"ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
		[LE_ITEM_WEAPON_SWORD1H] 	= {"DRUID", "SHAMAN", "PRIEST",},
		[LE_ITEM_WEAPON_SWORD2H]	= {"DRUID", "MONK", "ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
		[LE_ITEM_WEAPON_STAFF]		= {"DEATHKNIGHT", "PALADIN",  "ROGUE", "DEMONHUNTER"},
		[LE_ITEM_WEAPON_WAND]		= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "DEMONHUNTER"},
		[LE_ITEM_WEAPON_WARGLAIVE]	= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "HUNTER", "SHAMAN",},
		[LE_ITEM_WEAPON_UNARMED] 	= {"DEATHKNIGHT", "PALADIN",  "PRIEST", "MAGE", "WARLOCK"}, -- Fist weapons
	},
}

--- Types of relics. Thanks to xmyno for the list.
-- NOTE I'm not sure if the return from C_ArtifactUI.GetRelicInfoByItemID() is localized
-- @table relicTypes
local relicTypes = {
  BLOOD     = 'Blood',
  SHADOW    = 'Shadow',
  IRON      = 'Iron',
  FROST     = 'Frost',
  FIRE      = 'Fire',
  FEL       = 'Fel',
  ARCANE    = 'Arcane',
  LIFE      = 'Life',
  STORM     = 'Wind', -- Great job Blizzard -.-
  HOLY      = 'Holy'
}

--- The type of relic each class can use
-- @table relics
local relics = {
   DEATHKNIGHT = {relicTypes.BLOOD, relicTypes.SHADOW,relicTypes.IRON,  relicTypes.FROST, relicTypes.FIRE },
   DEMONHUNTER = {relicTypes.FEL,   relicTypes.SHADOW,relicTypes.IRON,  relicTypes.ARCANE},
   DRUID       = {relicTypes.ARCANE,relicTypes.LIFE,  relicTypes.FIRE,  relicTypes.BLOOD, relicTypes.FROST},
   HUNTER      = {relicTypes.STORM, relicTypes.ARCANE,relicTypes.IRON,  relicTypes.BLOOD, relicTypes.LIFE},
   MAGE        = {relicTypes.ARCANE,relicTypes.FROST, relicTypes.FIRE},
   MONK        = {relicTypes.LIFE,  relicTypes.STORM, relicTypes.IRON,  relicTypes.FROST},
   PALADIN     = {relicTypes.HOLY,  relicTypes.LIFE,  relicTypes.FIRE,  relicTypes.IRON,  relicTypes.ARCANE},
   PRIEST      = {relicTypes.HOLY,  relicTypes.SHADOW,relicTypes.LIFE,  relicTypes.BLOOD},
   ROGUE       = {relicTypes.SHADOW,relicTypes.IRON,  relicTypes.BLOOD, relicTypes.STORM, relicTypes.FEL},
   SHAMAN      = {relicTypes.STORM, relicTypes.FROST, relicTypes.FIRE,  relicTypes.IRON,  relicTypes.LIFE},
   WARLOCK     = {relicTypes.SHADOW,relicTypes.BLOOD, relicTypes.FIRE,  relicTypes.FEL},
   WARRIOR     = {relicTypes.IRON,  relicTypes.BLOOD, relicTypes.SHADOW,relicTypes.FIRE,  relicTypes.STORM},
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
	local class = class or self.playerClass
	local classID = self.classTagNameToID[class]
	if bit.band(classesFlag, bit.lshift(1, classID-1)) == 0 then -- The item tooltip writes the allowed clases, but our class is not in it.
		return true
	end
	local id = type(link) == "number" and link or self:GetItemIDFromLink(link) -- Convert to id if needed
	if equipLoc == "INVTYPE_TRINKET" then
		if self:Getdb().autoPassTrinket then
			if _G.RCTrinketSpecs and _G.RCTrinketSpecs[id] and _G.RCTrinketSpecs[id]:sub(-classID, -classID)=="0" then
				return true
			end
		end
	end
	if not tContains(autopassOverride, equipLoc) then
		if self:IsRelicTypeID(typeID, subTypeID) then
			if isRelic then -- New in v2.3+
				self:DebugLog("NewRelicAutopassCheck", link, isRelic)
				return not tContains(relics[class], isRelic)
			else
				local id = self:GetItemIDFromLink(link)
	         local type = select(3, C_ArtifactUI.GetRelicInfoByItemID(id))
				self:DebugLog("RelicAutopassCheck", type, id)
	         -- If the type exists in the table, then the player can use it, so we need to negate it
	         return not tContains(relics[class], type)
			end

		elseif autopassTable[typeID] and autopassTable[typeID][subTypeID] then
			return tContains(autopassTable[typeID][subTypeID], class)
		end
	end
	return false
end
