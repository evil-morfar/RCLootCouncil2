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
-- local boolean = RCLootCouncil:AutoPassCheck(dat.subType, dat.equipLoc, dat.link, dat.token, dat.relic)
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
			if self.EJTrinkets[0][id] and not self.EJTrinkets[classID][id] then 
				-- Found the trinkets in "All classes" of EJ, but not this class
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

--@param force : Force to recaching. Used when receive EJ data.
function RCLootCouncil:CacheEJTrinkets(force)
	-- Backup the current EJ instance settings.
	local instanceID = self.EJInstanceID
	local encounterID = self.EJEncounterID
	local difficultyID = EJ_GetDifficulty()
	local slotFilter = EJ_GetSlotFilter()
	local classID, specID = EJ_GetLootFilter()

	local curInstanceID = EJ_GetCurrentInstance() -- The we are current in, not EJ setting.
	local _, _, curDifficultyID = GetInstanceInfo()

	local newInstanceID, newDifficultyID
	if curInstanceID and curInstanceID ~= 0 then -- In instance, cache the current instance we are in.
		newInstanceID = curInstanceID
		newDifficultyID = curDifficultyID
	else -- If out of instance, assume to be testing, so cache the lastest instance.
		newInstanceID = self.EJLastestInstanceID
		newDifficultyID = 14 -- Normal difficulty
	end
	if not force and self.EJTrinkets.instanceID == newInstanceID and self.EJTrinkets.difficultyID == newDifficultyID then
		return
	end

	if _G.EncounterJournal then
		-- We have to do this because when EncounterJournal receives the event "EJ_DIFFICULTY_UPDATE", 
		-- the EJ instance is immediately reseted to the instance which is currently shown in EJ.
		_G.EncounterJournal:UnregisterEvent("EJ_DIFFICULTY_UPDATE")
	end

	EJ_SelectInstance(newInstanceID)
	if EJ_IsValidInstanceDifficulty(newDifficultyID) then
		EJ_SetDifficulty(newDifficultyID)
	end

	EJ_SetSlotFilter(LE_ITEM_FILTER_TYPE_TRINKET)
	for i = 0, GetNumClasses() do
	    EJ_SetLootFilter(i, 0)
	    wipe(self.EJTrinkets[i])
	    for j = 1, EJ_GetNumLoot() do -- EJ_GetNumLoot() can be 0 if EJ items are not cached.
	        local id = EJ_GetLootInfoByIndex(j)
	        if id then
	        	self.EJTrinkets[i][id] = true
	        end
	    end
	end
	self.EJTrinkets.instanceID = self.EJInstanceID  -- self.EJInstanceID is set by hooks to EJ_SelectInstance
	self.EJTrinkets.difficultyID = EJ_GetDifficulty()

	-- Restore settings
	if instanceID then EJ_SelectInstance(instanceID) end
	if encounterID then EJ_SelectEncounter(encounterID) end
	EJ_SetDifficulty(difficultyID)
	EJ_SetSlotFilter(slotFilter)
	EJ_SetLootFilter(classID, specID)
	if _G.EncounterJournal then
		-- In-game tests show that no taint is generated this way.
		_G.EncounterJournal:RegisterEvent("EJ_DIFFICULTY_UPDATE") 
	end

end