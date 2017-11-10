--- autopass.lua	Contains everything related to autopassing
-- @author	Potdisc
-- Create Date : 23/9/2016

--- Never autopass these armor types.
-- @table autopassOverride
local autopassOverride = {
	"INVTYPE_CLOAK",
}

--- Classes that should autopass a subtype.
-- @table autopassTable
local autopassTable = {
	["Cloth"]					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "DEMONHUNTER"},
	["Leather"] 				= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK"},
	["Mail"] 					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Plate"]					= {"DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Shields"] 				= {"DEATHKNIGHT", "DRUID", "MONK", "ROGUE", "HUNTER","PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Bows"] 					= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "WARRIOR"},
	["Crossbows"] 				= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "WARRIOR"},
	["Daggers"]					= {"DEATHKNIGHT", "PALADIN", "MONK", },
	["Guns"]						= {"DEATHKNIGHT", "PALADIN", "DRUID", "MONK","SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER", "WARRIOR"},
	["Fist Weapons"] 			= {"DEATHKNIGHT", "PALADIN",  "PRIEST", "MAGE", "WARLOCK"},
	["One-Handed Axes"]		= {"DRUID", "PRIEST", "MAGE", "WARLOCK"},
	["One-Handed Maces"]		= {"HUNTER", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["One-Handed Swords"] 	= {"DRUID", "SHAMAN", "PRIEST",},
	["Polearms"] 				= {"ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Staves"]					= {"DEATHKNIGHT", "PALADIN",  "ROGUE", "DEMONHUNTER"},
	["Two-Handed Axes"]		= {"DRUID", "ROGUE", "MONK", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Two-Handed Maces"]		= {"MONK", "ROGUE", "HUNTER", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Two-Handed Swords"]	= {"DRUID", "MONK", "ROGUE", "SHAMAN", "PRIEST", "MAGE", "WARLOCK", "DEMONHUNTER"},
	["Wands"]					= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "HUNTER", "SHAMAN", "DEMONHUNTER"},
	["Warglaives"]				= {"WARRIOR", "DEATHKNIGHT", "PALADIN", "DRUID", "MONK", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "HUNTER", "SHAMAN",}
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
-- local boolean = RCLootCouncil:AutoPassCheck(dat.subType, dat.equipLoc, dat.link, dat.token, dat.relic)
--@return true if the player should autopass the given item.
function RCLootCouncil:AutoPassCheck(subType, equipLoc, link, isToken, isRelic, classesFlag, class)
	local class = class or self.playerClass
	local classID = self.classTagNameToID[class]
	if bit.band(classesFlag, bit.lshift(1, classID-1)) == 0 then -- The item tooltip writes the allowed clases, but our class is not in it.
		return true
	end
  -- Tokens ignore autopass override
  local id = type(link) == "number" and link or self:GetItemIDFromLink(link) -- Convert to id if needed
	if not tContains(autopassOverride, equipLoc) then
		if isRelic or ("Artifact Relic" == self.db.global.localizedSubTypes[subType]) then
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

		elseif subType and autopassTable[self.db.global.localizedSubTypes[subType]] then
			return tContains(autopassTable[self.db.global.localizedSubTypes[subType]], class)
		end
	end
	return false
end
