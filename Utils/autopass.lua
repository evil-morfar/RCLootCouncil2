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
			if _G.RCTrinketClasses and _G.RCTrinketClasses[id] and bit.band(_G.RCTrinketClasses[id], bit.lshift(1, classID-1)) == 0 then 
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

--@debug@
-- This function is used for developer.
-- Export all trinkets in the current expansion in the encounter journal not usable by all classes to saved variable.
-- The format is {[itemID] = classFlag}
-- See the explanation of classFlag in RCLootCouncil:GetItemClassesAllowedFlag(item)
local trinketClasses = {}

local EJ_DIFFICULTIES =
{   -- Copy and paste from BLizzard_EncounterJournal.lua
	{ size = "5", prefix = PLAYER_DIFFICULTY1, difficultyID = 1 },
	{ size = "5", prefix = PLAYER_DIFFICULTY2, difficultyID = 2 },
	{ size = "5", prefix = PLAYER_DIFFICULTY6, difficultyID = 23 },
	{ size = "5", prefix = PLAYER_DIFFICULTY_TIMEWALKER, difficultyID = 24 },
	{ size = "25", prefix = PLAYER_DIFFICULTY3, difficultyID = 7 },
	{ size = "10", prefix = PLAYER_DIFFICULTY1, difficultyID = 3 },
	{ size = "10", prefix = PLAYER_DIFFICULTY2, difficultyID = 5 },
	{ size = "25", prefix = PLAYER_DIFFICULTY1, difficultyID = 4 },
	{ size = "25", prefix = PLAYER_DIFFICULTY2, difficultyID = 6 },
	{ prefix = PLAYER_DIFFICULTY3, difficultyID = 17 },
	{ prefix = PLAYER_DIFFICULTY1, difficultyID = 14 },
	{ prefix = PLAYER_DIFFICULTY2, difficultyID = 15 },
	{ prefix = PLAYER_DIFFICULTY6, difficultyID = 16 },
	{ prefix = PLAYER_DIFFICULTY_TIMEWALKER, difficultyID = 33 },
}
-- The params are used internally inside this function
function RCLootCouncil:ExportTrinketData(nextIsRaid, nextIndex, nextDiffIndex)
	local MAX_CLASSFLAG_VAL = bit.lshift(1, MAX_CLASSES) - 1
	local TIME_FOR_EACH_INSTANCE_DIFF = 5

	if not nextIsRaid then
		nextIsRaid = 0
		nextIndex = 1
		nextDiffIndex = 1
		self:Print("Exporting the class data of all current tier trinkets to RCLootCouncil.db.global.RCTrinketClasses\n"
			.."This command is intended to be run by the developer.\n"
			.."Please reload after exporting is done and copy and paste the data into Utils/TrinketData.lua.\n"
			.."Dont open EncounterJournal during export.\n"
			.."Dont run any /rc exporttrinketdata when it is running."
			.."Clear the export in the Saved Variable by /rc cleartrinketdata")
		self:Print(format("To ensure the data is correct, process one difficulty of one instance every %d s", TIME_FOR_EACH_INSTANCE_DIFF))
	end

	EJ_SelectTier(EJ_GetNumTiers()) -- Select current tier

	if _G.EncounterJournal then
		_G.EncounterJournal:UnregisterAllEvents() -- To help to ensure EncounterJournal does not affect exporting.
	end

	local instanceIndex = nextIndex
	for i=nextIsRaid, 1 do
		while EJ_GetInstanceByIndex(instanceIndex, (i==1)) do
			local instanceID = EJ_GetInstanceByIndex(instanceIndex, (i==1))
			EJ_SelectInstance(instanceID)
			for diffIndex=nextDiffIndex, #EJ_DIFFICULTIES do
				local entry = EJ_DIFFICULTIES[diffIndex]
				if EJ_IsValidInstanceDifficulty(entry.difficultyID) then
					self:ExportTrinketDataSingleInstance(instanceID, entry.difficultyID, TIME_FOR_EACH_INSTANCE_DIFF)
					return self:ScheduleTimer("ExportTrinketData", TIME_FOR_EACH_INSTANCE_DIFF, i, instanceIndex, diffIndex + 1)
				end
			end
			nextDiffIndex = 1
			instanceIndex = instanceIndex + 1
		end
		instanceIndex = 1
	end

	local count = 0
	for id, val in pairs(trinketClasses) do
		count = count + 1
	end
	self:Print(format("DONE. %d trinkets total", count))
	count = 0
	for id, val in pairs(trinketClasses) do -- Not report if the trinket can be used by all classes.
		if val == MAX_CLASSFLAG_VAL then
			trinketClasses[id] = nil
		else
			count = count + 1
		end
	end
	self:Print(format("Among them, %d trinket which cannnot be used by all classes are exported to RCLootCouncil.db.global.RCTrinketClasses. Please reload now", count))
	self:Print("Dont forget to sort the lines after copy paste the data to Utils/TrinketData.lua")
	self:Print("Suggest to verify the data for the trinket in the recent raid")
	self.db.global.RCTrinketClasses = trinketClasses
end

function RCLootCouncil:ExportTrinketDataSingleInstance(instanceID, diffID, timeLeft)
	if _G.EncounterJournal then
		_G.EncounterJournal:UnregisterAllEvents() -- To help to ensure EncounterJournal does not affect exporting.
	end
	local count = 0
	local trinketlinksInThisInstances = {}
	EJ_SelectInstance(instanceID)
	EJ_SetDifficulty(diffID)
	EJ_SetSlotFilter(LE_ITEM_FILTER_TYPE_TRINKET)
	for classID = 0, MAX_CLASSES do
	    EJ_SetLootFilter(classID, 0)
	    for j = 1, EJ_GetNumLoot() do -- EJ_GetNumLoot() can be 0 if EJ items are not cached.
	        local id, _, _, _, _, _, link = EJ_GetLootInfoByIndex(j)
	        if link then
		        if classID == 0 then
		        	trinketClasses[id] = 0
		        	GetItemInfo(id)
		        	count = count + 1
		        	tinsert(trinketlinksInThisInstances, link)
		        else
		        	trinketClasses[id] = trinketClasses[id] + bit.lshift(1, classID-1)
		        end
		    end
	    end
	end
	local interval = 1
	if timeLeft > interval then -- Rerun many times for correctless
		return self:ScheduleTimer("ExportTrinketDataSingleInstance", interval, instanceID, diffID, timeLeft - interval)
	else
		local diffText = ""
		for diffIndex=1, #EJ_DIFFICULTIES do
			local entry = EJ_DIFFICULTIES[diffIndex]
			if entry.difficultyID == diffID then
				diffText = entry.prefix
			end
		end
		self:Print("--------------------")
		self:Print(format("Instance %d. %s %s. Processed %d trinkets", instanceID, EJ_GetInstanceInfo(instanceID), diffText, count))
		for _, link in ipairs(trinketlinksInThisInstances) do
			local id = self:GetItemIDFromLink(link)
			self:Print(format("%s(%d): 0x%X", link, id, trinketClasses[id]))
		end
		self:Print("--------------------")
	end
end
--@end-debug@