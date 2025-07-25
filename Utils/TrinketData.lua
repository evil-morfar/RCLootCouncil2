--- trinketData.lua
-- Contains loot specs of all trinkets in the dungeon journal
-- @author Safetee
-- Create Date : 12/03/2017
-- Update Date : 12/1/2020 (8.3.0 Build 32976)

---@type RCLootCouncil
local addon = select(2, ...)
local numClasses = 13 -- Hardcode for classic support
local ZERO = ("0"):rep(numClasses)
local ItemUtils = addon.Require "Utils.Item"
--@debug@
--[[
This function is used for developer.
Export the loot specs of all trinkets in the encounter journal.
The format is {[itemID] = specFlag}

specFlag is a large number and one hexadecimal digit represents the spec data for a single class.
Because WoW does not offer full support to 64bit integer, the data is store as string.

For example,
365002707767
The least significant hexadecimal digit, 7, represents the loot specs of the trinket for Warrrior (class ID 1)
The most significant hexadecimal digit, 3, represents the loot specs of the trinket for Demon Hunter (class ID 11)

The least significant digit 0x7=0b0111, shows the trinket is lootable by Arms (spec index 1), Fury (spec index 2) and Protection (spec index 3)
The 2nd least significant digit 0x6=0b0110, shows the trinket is lootable by Protection (spec index 2) and Retribution (Spec index 3), and not lootable by Holy (index 1)
The specIndex here refers to GetSpecializationInfoForClassID(classID, specIndex)
Holy Paladin is the 1st spec of Paladin (class ID 2) because GetSpecializationInfoForClassID(2, 1) is Holy Paladin
Overall, 365002707767 shows the trinket is lootable by all specs using Strength or Agility as Primary Stats.

--]]
local trinketData = {
}
local trinketNames = {
}
local trinketIdToIndex = {}
local instanceNames = {}
-- The params are used internally inside this function
-- Process in the following order:
-- From expansion vanilla to the latest expansion (nextTier)
-- Inside each expansion, scan dungeon first then raid (nextIsRaid)
-- Inside dungeon/raid, scan by its index in the journal (nextIndex)
-- Inside each instance, scan by difficulty id order(nextDiffID)
function RCLootCouncil:ExportTrinketData(nextTier, nextIsRaid, nextIndex, nextDiffID, maxTier)
   C_AddOns.LoadAddOn("BLizzard_EncounterJournal")
   local TIME_FOR_EACH_INSTANCE_DIFF = 3

   nextIsRaid = nextIsRaid or 0
   nextIndex = nextIndex or 1
   nextDiffID = nextDiffID or 1
   if not nextTier then
      nextTier = 11 -- TWW
      self:Print("Exporting the loot specs of all trinkets in the dungeon journal\n"
         .."This command is intended to be run by the developer.\n"
         .."After exporting is done and copy and paste the data into Utils/TrinketData.lua.\n"
         .."Dont open EncounterJournal during export.\n"
      .."Dont run any extra /rc exporttrinketdata when it is running.")
      self:Print(format("To ensure the data is correct, process one difficulty of one instance every %d s", TIME_FOR_EACH_INSTANCE_DIFF))
   end

   if _G.EncounterJournal then
      _G.EncounterJournal:UnregisterAllEvents() -- To help to ensure EncounterJournal does not affect exporting.
   end

   maxTier = maxTier or EJ_GetNumTiers()

   local instanceIndex = nextIndex
   for h = nextTier, maxTier do
      EJ_SelectTier(h)
      for i = nextIsRaid, 1 do
         while EJ_GetInstanceByIndex(instanceIndex, (i == 1)) do
            local instanceID = EJ_GetInstanceByIndex(instanceIndex, (i == 1))
            EJ_SelectInstance(instanceID)
            for diffID = nextDiffID, 99 do -- Should be enough to include all difficulties
               	if EJ_IsValidInstanceDifficulty(diffID) then
                  self:ExportTrinketDataSingleInstance(instanceID, diffID, TIME_FOR_EACH_INSTANCE_DIFF)
                  return self:ScheduleTimer("ExportTrinketData", TIME_FOR_EACH_INSTANCE_DIFF, h, i, instanceIndex, diffID + 1, maxTier)
				elseif nextTier == 1 and i == 1 and diffID == 9 then
					-- Classic raids has EJ_GetDifficulty() == 9, but EJ_IsValidInstanceDifficulty(9) == false
					-- and EJ_SetDifficulty(9) works as intended...
					-- Except for Ruins of Ahn'Qiraj (10-player) which correctly registers diffID 3.
					-- #GoodJobBlizzard
					self:ExportTrinketDataSingleInstance(instanceID, 9, TIME_FOR_EACH_INSTANCE_DIFF)
                	return self:ScheduleTimer("ExportTrinketData", TIME_FOR_EACH_INSTANCE_DIFF, h, i, instanceIndex + 1, 1, maxTier)
				end
            end
            nextDiffID = 1
            instanceIndex = instanceIndex + 1
         end
         instanceIndex = 1
      end
      nextIsRaid = 0
   end
	local numinstanceNames = 0
	for _ in pairs(instanceNames) do numinstanceNames = numinstanceNames + 1 end
   self:Print(format("DONE. %d trinkets total", #trinketData - numinstanceNames))
   self:Print("Copy paste the data to Utils/TrinketData.lua")
   self:Print("Suggest to verify the data for the trinket in the recent raid")

	local exportFrame = RCLootCouncil.UI:New("RCExportFrame")
	exportFrame:Show()

   local exports = "_G.RCTrinketSpecs = {\n"
   local longestNameLen = 0
   for _, name in pairs(trinketNames) do
      if #name > longestNameLen then
         longestNameLen = #name
      end
   end
   local exp = "%-"..format("%d", longestNameLen + 1).."s"
   for _, entry in ipairs(trinketData) do
		if entry[1] == "name" then
			exports = exports.."-- "..entry[2].."\n"

		elseif entry[3] ~= 0xffffffff then
			exports = exports .. "\t-- [" .. entry[1] .. "] = " .. format("%q", entry[2])
				.. ",\t-- " ..
				format(exp, trinketNames[entry[1]] .. ",") .. "\t" .. (self:ClassesFlagToStr(entry[3]) or "") .. "\n"
		else
	      exports = exports.."\t["..entry[1].."] = "..format("%q", entry[2])
	      ..",\t-- "..format(exp, trinketNames[entry[1]]..",").."\t"..(_G.RCTrinketCategories[entry[2]] or "").."\n"
		end
   end
   exports = exports.."}\n"
   exportFrame.edit:SetText(exports)
end

function RCLootCouncil:ClassesFlagToStr(flag)
   local text = ""
   for i = 1, numClasses do
      if bit.band(flag, bit.lshift(1, i - 1)) > 0 then
         if text ~= "" then
            text = text..", "
         end
         text = text..C_CreatureInfo.GetClassInfo(i).className or ""
      end
   end
   return text
end

function RCLootCouncil:ExportTrinketDataSingleInstance(instanceID, diffID, timeLeft)
   if _G.EncounterJournal then
      _G.EncounterJournal:UnregisterAllEvents() -- To help to ensure EncounterJournal does not affect exporting.
   end
   local count = 0
   local trinketlinksInThisInstances = {}
   EJ_SelectInstance(instanceID)
   EJ_SetDifficulty(diffID)
   C_EncounterJournal.SetSlotFilter(Enum.ItemSlotFilterType.Trinket)

	local diffText = GetDifficultyInfo(diffID) or "Unknown difficulty"
	local instanceText = format("%s %s (id: %d).", EJ_GetInstanceInfo(instanceID), diffText,instanceID)
	if not instanceNames[instanceText] then
		instanceNames[instanceText] = true
		tinsert(trinketData, {"name", instanceText})
	end

   EJ_SetLootFilter(0, 0)
   for j = 1, EJ_GetNumLoot() do -- EJ_GetNumLoot() can be 0 if EJ items are not cached.
      local info = C_EncounterJournal.GetLootInfoByIndex(j)
      if info.link then
			if not trinketIdToIndex[info.itemID] then
				tinsert(trinketData, { info.itemID, ZERO, self:GetItemClassesAllowedFlag(info.link) })
				trinketIdToIndex[info.itemID] = #trinketData
			else
				trinketData[trinketIdToIndex[info.itemID]][2] = ZERO
			end
         trinketNames[info.itemID] = ItemUtils:GetItemNameFromLink(info.link)
         C_Item.GetItemInfo(info.itemID)
         count = count + 1
         tinsert(trinketlinksInThisInstances, info.link)
      else
         self.Log:D("Uncached item @", instanceID, diffID, j, info.itemID)
      end
   end

   for classID = 1, numClasses do
      for specIndex = 1, GetNumSpecializationsForClassID(classID) do
         EJ_SetLootFilter(classID, GetSpecializationInfoForClassID(classID, specIndex))
         for j = 1, EJ_GetNumLoot() do -- EJ_GetNumLoot() can be 0 if EJ items are not cached.
            local info = C_EncounterJournal.GetLootInfoByIndex(j)
            if info.link then
				local index = trinketIdToIndex[info.itemID]
				local specCode = trinketData[index][2]
				local digit = tonumber(specCode:sub(-classID, - classID), 16)
				digit = digit + 2^(specIndex - 1)
				trinketData[index][2] = specCode:sub(1, numClasses - classID)..format("%X", digit)..specCode:sub(numClasses - classID + 2, numClasses)
            end
         end
      end
   end
   local interval = 1
   if timeLeft > interval then -- Rerun many times for correctless
      return self:ScheduleTimer("ExportTrinketDataSingleInstance", interval, instanceID, diffID, timeLeft - interval)
   else
      self:Print("--------------------")
      self:Print(format("Instance %d. %s %s. Processed %d trinkets", instanceID, EJ_GetInstanceInfo(instanceID), diffText, count))
      for _, link in ipairs(trinketlinksInThisInstances) do
         local id = ItemUtils:GetItemIDFromLink(link)
		 local data = trinketData[trinketIdToIndex[id]]
         self:Print(format("%s(%d): %s (%s)", link, id, data[2], data[3]))
			if not RCTrinketCategories[data[2]] and data[3] ~= 0xffffffff then
			print ("Missing category for " .. data[2] .. " " .. data[3])
		 end
      end
      self:Print("--------------------")
   end
end
--@end-debug@

-- Trinket categories description according to specs that can loot the trinket.
-- These categories should cover all trinkets in the Encounter Journal. Add more if any trinket is missing category.
_G.RCTrinketCategories = {
	["73F7777777777"] = ALL_CLASSES, -- All Classes
	["0365002707767"] = ITEM_MOD_STRENGTH_SHORT .. "/" .. ITEM_MOD_AGILITY_SHORT, -- Strength/Agility
	["0000000700067"] = ITEM_MOD_STRENGTH_SHORT, -- Strength
	["0365002707467"] = MELEE, -- Melee
	["33F7777077710"] = ITEM_MOD_AGILITY_SHORT .. "/" .. ITEM_MOD_INTELLECT_SHORT, -- Agility/Intellect
	["1375773047700"] = DAMAGER .. ", " .. ITEM_MOD_AGILITY_SHORT .. "/" .. ITEM_MOD_INTELLECT_SHORT, -- Damage, Agility/Intellect
	["0365002007700"] = ITEM_MOD_AGILITY_SHORT, -- Agility
	["7092775070010"] = ITEM_MOD_INTELLECT_SHORT, -- Intellect
	["0241000100024"] = TANK, -- Tank
	["0041000100024"] = TANK, -- Tanks except DEMONHUNTER (Too old) - FORMER: All Classes?
	["0000000000024"] = TANK .. ", " .. BLOCK, -- Tank, Block (Warrior, Paladin)
	["0201000100024"] = TANK .. ", " .. PARRY, -- Tank, Parry (Non-Druid)
	["2082004030010"] = HEALER, -- Healer
	["6082004030010"] = HEALER, -- Healer + Augmentation
	["0092005070010"] = HEALER, -- Healer (EJ includes some DPS specs) FORMER: Intellect? (Missing Mage, Warlock)
	["0082004030010"] = HEALER, -- Healer, - Evoker
	["22C3004130034"] = TANK .. ", ".. HEALER, -- Tank & Healer
	["0124002607743"] = DAMAGER .. ", " .. ITEM_MOD_STRENGTH_SHORT .. "/" .. ITEM_MOD_AGILITY_SHORT, -- Damage, Strength/Agility
	["0000000600043"] = DAMAGER .. ", " .. ITEM_MOD_STRENGTH_SHORT, -- Damage, Strength
	["0124002007700"] = DAMAGER .. ", " .. ITEM_MOD_AGILITY_SHORT, -- Damage, Agility
	["0124002607443"] = DAMAGER .. ", " .. MELEE, -- Damage, Melee
	["0124002007400"] = DAMAGER .. ", " .. MELEE .. ", " .. ITEM_MOD_AGILITY_SHORT, -- Damage, Melee, Agility
	["0010771050300"] = DAMAGER .. ", " .. RANGED, -- Damage, Ranged (+ discipline)
	["5010771050300"] = DAMAGER .. ", " .. RANGED, -- Damage, Ranged (+ discipline & augmentation)
	["0010771040300"] = DAMAGER .. ", " .. RANGED, -- Damage, Ranged
	["1010771040300"] = DAMAGER .. ", " .. RANGED, -- Damage, Ranged (+ Devastation)
	["1010771050000"] = DAMAGER .. ", " .. ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect
	["3092776070010"] = DAMAGER .. ", " .. ITEM_MOD_INTELLECT_SHORT, -- Damage + Healers, Intellect
	["1010671040000"] = DAMAGER .. ", " .. ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect (direct damage, no affliction warlock and shadow priest)
	["5010771040000"] = DAMAGER .. ", " .. ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect (no discipline)
	["1134773647743"] = DAMAGER, -- Damage (Pre augmentation evoker)
	["5134773647743"] = DAMAGER, -- Damage
	["0325002007700"] = ITEM_MOD_AGILITY_SHORT, -- Agility (DPS + vengance and brewmaster)??
	["73F7777077710"] = ITEM_MOD_AGILITY_SHORT .. "/" .. ITEM_MOD_INTELLECT_SHORT, -- Agility/Intellect
	["0000000700077"] = ITEM_MOD_STRENGTH_SHORT, -- Strength

	-- The following categories does not make sense. Most likely a Blizzard error in the Encounter Journal for several old trinkets.
	-- Add "?" as a suffix to the description as the result
	["0365002107467"] = MELEE .. "?", -- Melee? （Missing Frost and Unholy DK)
	["0241000100044"] = TANK .. "?", -- Tank? (Ret instead of Pro?)
	["0124002607703"] = ITEM_MOD_STRENGTH_SHORT .. "/" .. ITEM_MOD_AGILITY_SHORT .. "?", -- Strength/Agility?
	["0367002707767"] = ITEM_MOD_STRENGTH_SHORT .. "/" .. ITEM_MOD_AGILITY_SHORT .. "?", -- Strength/Agility?
	["0324001607743"] = ITEM_MOD_STRENGTH_SHORT .. "/" .. ITEM_MOD_AGILITY_SHORT .. "?", -- Strength/Agility?
	["0324002007700"] = ITEM_MOD_AGILITY_SHORT .. "?", -- Agility? (Missing Brewmaster)
	["3092775070310"] = ITEM_MOD_AGILITY_SHORT .. "/" .. ITEM_MOD_INTELLECT_SHORT .. "?", -- Agility/Intellect?
	["3092075070010"] = ITEM_MOD_INTELLECT_SHORT .. "?", -- Intellect? (Missing Warlock)
	["1010773050000"] = DAMAGER .. ", " .. ITEM_MOD_INTELLECT_SHORT .. "?", -- Damage, Intellect? (+Enhancement Shaman)
	["0124002607447"] = MELEE, -- All melee + protection warrior?
	["0092775070010"] = ITEM_MOD_INTELLECT_SHORT, -- Intellect (No evoker)
	["03F7777777777"] = ALL_CLASSES, -- All Classes except Evoker
	["0010771040000"] = DAMAGER .. ", " .. ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect (no discipline or evoker)
	["0010771050000"] = DAMAGER .. ", " .. ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect (no Evoker)
	["7300070000077"] = "", -- Class specific (Evoker, Demonhunter, Mage, Paladin, Warrior)
	["0007707000700"] = "", -- Class specific (Monk, Warlock, Shaman, Hunter)
	["00F0000777000"] = "", -- Class specific (Druid, Death Knight, Priest, Rogue)
}


function RCLootCouncil:InitTrinketData ()
   -- Class specific trinket
   for classID in pairs(self.classIDToDisplayName) do
      local digit = 0
      for specIndex = 1, self.Utils:GetNumSpecializationsForClassID(classID) do
         digit = digit + 2^(specIndex - 1)
      end
      local flag = ZERO:sub(1, numClasses - classID)..format("%X", digit)..ZERO:sub(numClasses - classID + 2, numClasses)
      _G.RCTrinketCategories[flag] = C_CreatureInfo.GetClassInfo(classID).className
   end
end

-- Automatically generated by command "/rc exporttrinketdata"
-- The code related to above command is commented out for Curseforge release because
-- this is intended to be run by the developer.
-- The table indicates if the trinket is lootable for certain specs.
-- Format: [itemID] = specFlag
_G.RCTrinketSpecs = {
	-- Blackfathom Deeps Normal (id: 227).
	-- Blackrock Depths Normal (id: 228).
	[11832] = "0082004030010", -- Burst of Knowledge,                             	Healer
	[11810] = "0241000100024", -- Force of Will,                                  	Tank
	[11815] = "0365002707767", -- Hand of Justice,                                	Strength/Agility
	[11819] = "0082004030010", -- Second Wind,                                    	Healer
	-- Deadmines Normal (id: 63).
	-- Deadmines Heroic (id: 63).
	-- Dire Maul Normal (id: 230).
	[18371] = "33F7777777777", -- Mindtap Talisman,                               	All Classes
	[18370] = "33F7777777777", -- Vigilance Charm,                                	All Classes
	-- Gnomeregan Normal (id: 231).
	-- Lower Blackrock Spire Normal (id: 229).
	[22321] = "0365002707767", -- Heart of Wyrmthalak,                            	Strength/Agility
	[13213] = "33F7777777777", -- Smolderweb's Eye,                               	All Classes
	-- Maraudon Normal (id: 232).
	[17744] = "33F7777777777", -- Heart of Noxxion,                               	All Classes
	-- Ragefire Chasm Normal (id: 226).
	-- Razorfen Downs Normal (id: 233).
	-- Razorfen Kraul Normal (id: 234).
	-- Scarlet Halls Normal (id: 311).
	-- Scarlet Halls Heroic (id: 311).
	-- Scarlet Monastery Normal (id: 316).
	[88294] = "0365002007700", -- Flashing Steel Talisman,                        	Agility
	-- Scarlet Monastery Heroic (id: 316).
	[144158] = "33F7777777777", -- Flashing Steel Talisman,                        	All Classes
	-- Scholomance Normal (id: 246).
	[88358] = "0000000700067", -- Lessons of the Darkmaster,                      	Strength
	[88360] = "0082004030010", -- Price of Progress,                              	Healer
	[88355] = "0365002007700", -- Searing Words,                                  	Agility
	-- Scholomance Heroic (id: 246).
	[144161] = "0000000700067", -- Lessons of the Darkmaster,                      	Strength
	[144159] = "3092775070010", -- Price of Progress,                              	Intellect
	[144160] = "0365002007700", -- Searing Words,                                  	Agility
	-- Scholomance Timewalking (id: 246).
	-- Shadowfang Keep Normal (id: 64).
	-- Shadowfang Keep Heroic (id: 64).
	-- Stratholme Normal (id: 236).
	[13382] = "33F7777777777", -- Cannonball Runner,                              	All Classes
	[13515] = "33F7777777777", -- Ramstein's Lightning Bolts,                     	All Classes
	-- The Stockade Normal (id: 238).
	-- The Temple of Atal'hakkar Normal (id: 237).
	-- Uldaman Normal (id: 239).
	-- Wailing Caverns Normal (id: 240).
	-- Zul'Farrak Normal (id: 241).
	-- Molten Core 40 Player (id: 741).
	[18815] = "33F7777777777", -- Essence of the Pure Flame,                      	All Classes
	[17082] = "33F7777777777", -- Shard of the Flame,                             	All Classes
	[18820] = "33F7777777777", -- Talisman of Ephemeral Power,                    	All Classes
	-- Blackwing Lair 40 Player (id: 742).
	[19345] = "33F7777777777", -- Aegis of Preservation,                          	All Classes
	[19336] = "33F7777777777", -- Arcane Infused Gem,                             	All Classes
	[19406] = "0365002707767", -- Drake Fang Talisman,                            	Strength/Agility
	[19341] = "33F7777777777", -- Lifegiving Gem,                                 	All Classes
	[19339] = "33F7777777777", -- Mind Quickening Gem,                            	All Classes
	[19344] = "33F7777777777", -- Natural Alignment Crystal,                      	All Classes
	[19379] = "3092775070010", -- Neltharion's Tear,                              	Intellect
	[19395] = "3092775070010", -- Rejuvenating Gem,                               	Intellect
	[19340] = "33F7777777777", -- Rune of Metamorphosis,                          	All Classes
	[19343] = "33F7777777777", -- Scrolls of Blinding Light,                      	All Classes
	[19431] = "33F7777777777", -- Styleen's Impeding Scarab,                      	All Classes
	[19337] = "33F7777777777", -- The Black Book,                                 	All Classes
	[19342] = "33F7777777777", -- Venomous Totem,                                 	All Classes
	-- Ruins of Ahn'Qiraj 10 Player (id: 743).
	[21473] = "33F7777777777", -- Eye of Moam,                                    	All Classes
	[21488] = "33F7777777777", -- Fetish of Chitinous Spikes,                     	All Classes
	-- Ruins of Ahn'Qiraj 40 Player (id: 743).
	-- Temple of Ahn'Qiraj 40 Player (id: 744).
	[21670] = "33F7777777777", -- Badge of the Swarmguard,                        	All Classes
	[21647] = "33F7777777777", -- Fetish of the Sand Reaver,                      	All Classes
	[23570] = "33F7777777777", -- Jom Gabbar,                                     	All Classes
	[21685] = "33F7777777777", -- Petrified Scarab,                               	All Classes
	[21625] = "33F7777777777", -- Scarab Brooch,                                  	All Classes
	[23558] = "33F7777777777", -- The Burrower's Shell,                           	All Classes
	[21579] = "33F7777777777", -- Vanquished Tentacle of C'Thun,                  	All Classes
	-- Auchenai Crypts Normal (id: 247).
	[27416] = "0241000100024", -- Fetish of the Fallen,                           	Tank
	[26055] = "0082004030010", -- Oculus of the Hidden Eye,                       	Healer
	-- Auchenai Crypts Heroic (id: 247).
	-- Hellfire Ramparts Normal (id: 248).
	-- Hellfire Ramparts Heroic (id: 248).
	-- Magisters' Terrace Normal (id: 249).
	[34471] = "0082004030010", -- Vial of the Sunwell,                            	Healer
	[34473] = "0241000100024", -- Commendation of Kael'thas,                      	Tank
	[34472] = "0124002607743", -- Shard of Contempt,                              	Damage, Strength/Agility
	[34470] = "3092775070010", -- Timbal's Focusing Crystal,                      	Intellect
	-- Magisters' Terrace Heroic (id: 249).
	-- Magisters' Terrace Timewalking (id: 249).
	[133464] = "0241000100024", -- Commendation of Kael'thas,                      	Tank
	[133463] = "0124002607743", -- Shard of Contempt,                              	Damage, Strength/Agility
	[133461] = "0010771050000", -- Timbal's Focusing Crystal,
	[133462] = "0082004030010", -- Vial of the Sunwell,                            	Healer
	-- Mana-Tombs Normal (id: 250).
	[27828] = "0082004030010", -- Warp-Scarab Brooch,                             	Healer
	-- Mana-Tombs Heroic (id: 250).
	-- Mana-Tombs Timewalking (id: 250).
	[127245] = "0092775070010", -- Warp-Scarab Brooch,                             	Intellect
	-- Old Hillsbrad Foothills Normal (id: 251).
	[28223] = "0096775070010", -- Arcanist's Stone,
	-- Old Hillsbrad Foothills Heroic (id: 251).
	-- Sethekk Halls Normal (id: 252).
	-- Sethekk Halls Heroic (id: 252).
	-- Shadow Labyrinth Normal (id: 253).
	[27891] = "33F7777777777", -- Adamantine Figurine,                            	All Classes
	[27900] = "03F7777777777", -- Jewel of Charismatic Mystique,                  	All Classes
	-- Shadow Labyrinth Heroic (id: 253).
	-- The Arcatraz Normal (id: 254).
	[28418] = "0092775070010", -- Shiffar's Nexus-Horn,                           	Intellect
	-- The Arcatraz Heroic (id: 254).
	-- The Black Morass Normal (id: 255).
	[28034] = "0124002607743", -- Hourglass of the Unraveller,                    	Damage, Strength/Agility
	[28190] = "0082004030010", -- Scarab of the Infinite Cycle,                   	Healer
	-- The Black Morass Heroic (id: 255).
	-- The Blood Furnace Normal (id: 256).
	[24390] = "0082004030010", -- Auslese's Light Channeler,                      	Healer
	[28121] = "33F7777777777", -- Icon of Unyielding Courage,                     	All Classes
	-- The Blood Furnace Heroic (id: 256).
	-- The Blood Furnace Timewalking (id: 256).
	[188282] = "0082004030010", -- Auslese's Light Channeler,                      	Healer
	[188309] = "33F7777777777", -- Icon of Unyielding Courage,                     	All Classes
	-- The Botanica Normal (id: 257).
	[28370] = "0082004030010", -- Bangle of Endless Blessings,                    	Healer
	-- The Botanica Heroic (id: 257).
	-- The Botanica Timewalking (id: 257).
	[188396] = "0082004030010", -- Bangle of Endless Blessings,                    	Healer
	-- The Mechanar Normal (id: 258).
	[28288] = "0124002607743", -- Abacus of Violent Odds,                         	Damage, Strength/Agility
	-- The Mechanar Heroic (id: 258).
	-- The Shattered Halls Normal (id: 259).
	[27529] = "0241000100024", -- Figurine of the Colossus,                       	Tank
	-- The Shattered Halls Heroic (id: 259).
	-- The Shattered Halls Timewalking (id: 259).
	[123992] = "0000000000024", -- Figurine of the Colossus,                       	Tank, Block
	-- The Slave Pens Normal (id: 260).
	[27683] = "3092775070010", -- Quagmirran's Eye,                               	Intellect
	[24376] = "0241000100024", -- Runed Fungalcap,                                	Tank
	-- The Slave Pens Heroic (id: 260).
	-- The Steamvault Normal (id: 261).
	-- The Steamvault Heroic (id: 261).
	-- The Underbog Normal (id: 262).
	[27896] = "0082004030010", -- Alembic of Infernal Power,                      	Healer
	[27770] = "0241000100024", -- Argussian Compass,                              	Tank
	-- The Underbog Heroic (id: 262).
	-- The Underbog Timewalking (id: 262).
	[188359] = "0082004030010", -- Alembic of Infernal Power,                      	Healer
	[188352] = "0241000100024", -- Argussian Compass,                              	Tank
	-- Karazhan 10 Player (id: 745).
	[28528] = "33F7777777777", -- Moroes' Lucky Pocket Watch,                     	All Classes
	[28727] = "3092775070010", -- Pendant of the Violet Eye,                      	Intellect
	[28590] = "3092775070010", -- Ribbon of Sacrifice,                            	Intellect
	[28579] = "33F7777777777", -- Romulo's Poison Vial,                           	All Classes
	[28785] = "33F7777777777", -- The Lightning Capacitor,                        	All Classes
	-- Gruul's Lair 25 Player (id: 746).
	[28830] = "0365002707767", -- Dragonspine Trophy,                             	Strength/Agility
	[28823] = "3092775070010", -- Eye of Gruul,                                   	Intellect
	-- Magtheridon's Lair 25 Player (id: 747).
	[28789] = "3092775070010", -- Eye of Magtheridon,                             	Intellect
	-- Serpentshrine Cavern 25 Player (id: 748).
	[30665] = "0000000070000", -- Earring of Soulful Meditation,                  	Priest
	[30663] = "33F7777777777", -- Fathom-Brooch of the Tidewalker,                	All Classes
	[30664] = "33F7777777777", -- Living Root of the Wildheart,                   	All Classes
	[30621] = "33F7777777777", -- Prism of Inner Calm,                            	All Classes
	[30629] = "33F7777777777", -- Scarab of Displacement,                         	All Classes
	[30720] = "33F7777777777", -- Serpent-Coil Braid,                             	All Classes
	[30626] = "33F7777777777", -- Sextant of Unstable Currents,                   	All Classes
	[30627] = "33F7777777777", -- Tsunami Talisman,                               	All Classes
	-- The Eye 25 Player (id: 749).
	[30619] = "33F7777777777", -- Fel Reaver's Piston,                            	All Classes
	[30446] = "33F7777777777", -- Solarian's Sapphire,                            	All Classes
	[30448] = "33F7777777777", -- Talon of Al'ar,                                 	All Classes
	[30447] = "33F7777777777", -- Tome of Fiery Redemption,                       	All Classes
	[30449] = "33F7777777777", -- Void Star Talisman,                             	All Classes
	[30450] = "33F7777777777", -- Warp-Spring Coil,                               	All Classes
	-- The Battle for Mount Hyjal 25 Player (id: 750).
	-- Black Temple Normal (id: 751).
	[32505] = "0365002707767", -- Madness of the Betrayer,                        	Strength/Agility
	[32496] = "3092775070010", -- Memento of Tyrande,                             	Intellect
	[32501] = "33F7777777777", -- Shadowmoon Insignia,                            	All Classes
	[32483] = "3092775070010", -- The Skull of Gul'dan,                           	Intellect
	-- Black Temple Timewalking (id: 751).
	[150527] = "0365002707767", -- Madness of the Betrayer,                        	Strength/Agility
	[150523] = "0082004030010", -- Memento of Tyrande,                             	Healer
	[150526] = "0365002707767", -- Shadowmoon Insignia,                            	Strength/Agility
	[150522] = "0010771040000", -- The Skull of Gul'dan,                           	Damage, Intellect
	-- Sunwell Plateau 25 Player (id: 752).
	[34427] = "33F7777777777", -- Blackened Naaru Sliver,                         	All Classes
	[34430] = "3092775070010", -- Glimmering Naaru Sliver,                        	Intellect
	[34429] = "33F7777777777", -- Shifting Naaru Sliver,                          	All Classes
	[34428] = "33F7777777777", -- Steely Naaru Sliver,                            	All Classes
	-- Ahn'kahet: The Old Kingdom Normal (id: 271).
	-- Ahn'kahet: The Old Kingdom Heroic (id: 271).
	-- Azjol-Nerub Normal (id: 272).
	[37220] = "0241000100024", -- Essence of Gossamer,                            	Tank
	-- Azjol-Nerub Heroic (id: 272).
	-- Azjol-Nerub Timewalking (id: 272).
	[188415] = "0241000100024", -- Essence of Gossamer,                            	Tank
	-- Drak'Tharon Keep Normal (id: 273).
	[37723] = "0124002607743", -- Incisor Fragment,                               	Damage, Strength/Agility
	[37734] = "0082004030010", -- Talisman of Troll Divinity,                     	Healer
	-- Drak'Tharon Keep Heroic (id: 273).
	-- Gundrak Normal (id: 274).
	[37638] = "0241000100024", -- Offering of Sacrifice,                          	Tank
	-- Gundrak Heroic (id: 274).
	-- Gundrak Timewalking (id: 274).
	[127550] = "0241000100024", -- Offering of Sacrifice,                          	Tank
	-- Halls of Lightning Normal (id: 275).
	[36993] = "0241000100024", -- Seal of the Pantheon,                           	Tank
	[37844] = "0092775070010", -- Winged Talisman,                                	Intellect
	-- Halls of Lightning Heroic (id: 275).
	-- Halls of Lightning Timewalking (id: 275).
	[127512] = "0092775070010", -- Winged Talisman,                                	Intellect
	-- Halls of Reflection Normal (id: 276).
	[50260] = "0082004030010", -- Ephemeral Snowflake,                            	Healer
	-- Halls of Reflection Heroic (id: 276).
	-- Halls of Stone Normal (id: 277).
	[37660] = "0092775070010", -- Forge Ember,                                    	Intellect
	[37657] = "0092775070010", -- Spark of Life,                                  	Intellect
	-- Halls of Stone Heroic (id: 277).
	-- Pit of Saron Normal (id: 278).
	[50235] = "0241000100024", -- Ick's Rotting Thumb,                            	Tank
	[50259] = "3092775070010", -- Nevermelting Ice Crystal,                       	Intellect
	-- Pit of Saron Heroic (id: 278).
	-- The Culling of Stratholme Normal (id: 279).
	[37111] = "0082004030010", -- Soul Preserver,                                 	Healer
	-- The Culling of Stratholme Heroic (id: 279).
	-- The Forge of Souls Normal (id: 280).
	[50198] = "0126002607743", -- Needle-Encrusted Scorpion,
	-- The Forge of Souls Heroic (id: 280).
	-- The Forge of Souls Timewalking (id: 280).
	[188478] = "0126002607743", -- Needle-Encrusted Scorpion,
	-- The Nexus Normal (id: 281).
	[37166] = "0124002607743", -- Sphere of Red Dragon's Blood,                   	Damage, Strength/Agility
	-- The Nexus Heroic (id: 281).
	-- The Nexus Timewalking (id: 281).
	[127594] = "0124002607743", -- Sphere of Red Dragon's Blood,                   	Damage, Strength/Agility
	-- The Oculus Normal (id: 282).
	[37264] = "0010771050000", -- Pendulum of Telluric Currents,
	[36972] = "3092775070010", -- Tome of Arcane Phenomena,                       	Intellect
	-- The Oculus Heroic (id: 282).
	-- The Violet Hold Normal (id: 283).
	[37872] = "0241000100024", -- Lavanthor's Talisman,                           	Tank
	[37873] = "0092775070010", -- Mark of the War Prisoner,                       	Intellect
	-- The Violet Hold Heroic (id: 283).
	-- Trial of the Champion Normal (id: 284).
	[47213] = "0010771050000", -- Abyssal Rune,
	[47214] = "0124002607743", -- Banner of Victory,                              	Damage, Strength/Agility
	[47215] = "0082004030010", -- Tears of the Vanquished,                        	Healer
	[47216] = "0241000100024", -- The Black Heart,                                	Tank
	-- Trial of the Champion Heroic (id: 284).
	-- Utgarde Keep Normal (id: 285).
	-- Utgarde Keep Heroic (id: 285).
	-- Utgarde Keep Timewalking (id: 285).
	-- Utgarde Pinnacle Normal (id: 286).
	[37390] = "0124002607743", -- Meteorite Whetstone,                            	Damage, Strength/Agility
	[37064] = "0124002607743", -- Vestige of Haldor,                              	Damage, Strength/Agility
	-- Utgarde Pinnacle Heroic (id: 286).
	-- Vault of Archavon 10 Player (id: 753).
	-- Vault of Archavon 25 Player (id: 753).
	-- Naxxramas 10 Player (id: 754).
	[39229] = "3092775070010", -- Embrace of the Spider,                          	Intellect
	[39257] = "33F7777777777", -- Loatheb's Shadow,                               	All Classes
	[39292] = "33F7777777777", -- Repelling Charge,                               	All Classes
	[39388] = "33F7777777777", -- Spirit-World Glass,                             	All Classes
	-- Naxxramas 25 Player (id: 754).
	[40371] = "0365002707767", -- Bandit's Insignia,                              	Strength/Agility
	[40257] = "33F7777777777", -- Defender's Code,                                	All Classes
	[40255] = "33F7777777777", -- Dying Curse,                                    	All Classes
	[40373] = "33F7777777777", -- Extract of Necromantic Power,                   	All Classes
	[40258] = "3092775070010", -- Forethought Talisman,                           	Intellect
	[40256] = "33F7777777777", -- Grim Toll,                                      	All Classes
	[40372] = "33F7777777777", -- Rune of Repulsion,                              	All Classes
	[40382] = "33F7777777777", -- Soul of the Dead,                               	All Classes
	-- The Obsidian Sanctum 10 Player (id: 755).
	[40430] = "33F7777777777", -- Majestic Dragon Figurine,                       	All Classes
	-- The Obsidian Sanctum 25 Player (id: 755).
	[40431] = "33F7777777777", -- Fury of the Five Flights,                       	All Classes
	[40432] = "33F7777777777", -- Illustration of the Dragon Soul,                	All Classes
	-- The Eye of Eternity 10 Player (id: 756).
	-- The Eye of Eternity 25 Player (id: 756).
	[40532] = "33F7777777777", -- Living Ice Crystals,                            	All Classes
	[40531] = "33F7777777777", -- Mark of Norgannon,                              	All Classes
	-- Ulduar Normal (id: 759).
	[45522] = "0124002607743", -- Blood of the Old God,                           	Damage, Strength/Agility
	[45609] = "0365002707767", -- Comet's Trail,                                  	Strength/Agility
	[46038] = "0365002707767", -- Dark Matter,                                    	Strength/Agility
	[45866] = "0010771050000", -- Elemental Focus Stone,
	[45292] = "3092775070010", -- Energy Siphon,                                  	Intellect
	[45308] = "0092775070010", -- Eye of the Broodmother,                         	Intellect
	[45518] = "0010771050000", -- Flare of the Heavens,
	[45313] = "0241000100024", -- Furnace Stone,                                  	Tank
	[45158] = "0241000100024", -- Heart of Iron,                                  	Tank
	[45148] = "0092775070010", -- Living Flame,                                   	Intellect
	[46051] = "3092775070010", -- Meteorite Crystal,                              	Intellect
	[45931] = "0124002607743", -- Mjolnir Runestone,                              	Damage, Strength/Agility
	[45490] = "3092775070010", -- Pandora's Plea,                                 	Intellect
	[45286] = "0124002607743", -- Pyrite Infuser,                                 	Damage, Strength/Agility
	[46021] = "0241000100024", -- Royal Seal of King Llane,                       	Tank
	[45466] = "3092775070010", -- Scale of Fates,                                 	Intellect
	[45535] = "3092775070010", -- Show of Faith,                                  	Intellect
	[45929] = "0082004030010", -- Sif's Remembrance,                              	Healer
	[45703] = "3092775070010", -- Spark of Hope,                                  	Intellect
	[45507] = "0241000100024", -- The General's Heart,                            	Tank
	[46312] = "0134773647743", -- Vanquished Clutches of Yogg-Saron,
	[45263] = "0124002607743", -- Wrathstone,                                     	Damage, Strength/Agility
	-- Ulduar Timewalking (id: 759).
	[156234] = "0124002607743", -- Blood of the Old God,                           	Damage, Strength/Agility
	[156288] = "0010771050000", -- Elemental Focus Stone,
	[156021] = "3092775070010", -- Energy Siphon,                                  	Intellect
	[156036] = "0090775070010", -- Eye of the Broodmother,
	[156230] = "0010771050000", -- Flare of the Heavens,
	[156041] = "0241000100024", -- Furnace Stone,                                  	Tank
	[155952] = "0241000100024", -- Heart of Iron,                                  	Tank
	[155947] = "0092775070010", -- Living Flame,                                   	Intellect
	[156310] = "0124002607743", -- Mjolnir Runestone,                              	Damage, Strength/Agility
	[156207] = "0092775070010", -- Pandora's Plea,                                 	Intellect
	[156016] = "0124002607743", -- Pyrite Infuser,                                 	Damage, Strength/Agility
	[156345] = "0241000100024", -- Royal Seal of King Llane,                       	Tank
	[156187] = "3092775070010", -- Scale of Fates,                                 	Intellect
	[156245] = "0082004030010", -- Show of Faith,                                  	Healer
	[156308] = "0082004030010", -- Sif's Remembrance,                              	Healer
	[156277] = "0082004030010", -- Spark of Hope,                                  	Healer
	[156221] = "0241000100024", -- The General's Heart,                            	Tank
	[156458] = "0134773657743", -- Vanquished Clutches of Yogg-Saron,
	[156000] = "0124002607743", -- Wrathstone,                                     	Damage, Strength/Agility
	-- Trial of the Crusader 10 Player (id: 757).
	[47880] = "33F7777777777", -- Binding Stone,                                  	All Classes
	[47882] = "33F7777777777", -- Eitrigg's Oath,                                 	All Classes
	[47879] = "33F7777777777", -- Fetish of Volatile Power,                       	All Classes
	[47881] = "33F7777777777", -- Vengeance of the Forsaken,                      	All Classes
	-- Trial of the Crusader 25 Player (id: 757).
	[47303] = "0365002707767", -- Death's Choice,                                 	Strength/Agility
	[47290] = "33F7777777777", -- Juggernaut's Vitality,                          	All Classes
	[47316] = "3092775070010", -- Reign of the Dead,                              	Intellect
	[47271] = "3092775070010", -- Solace of the Fallen,                           	Intellect
	-- Trial of the Crusader 10 Player (Heroic) (id: 757).
	[48019] = "33F7777777777", -- Binding Stone,                                  	All Classes
	[48021] = "33F7777777777", -- Eitrigg's Oath,                                 	All Classes
	[48018] = "33F7777777777", -- Fetish of Volatile Power,                       	All Classes
	[48020] = "33F7777777777", -- Vengeance of the Forsaken,                      	All Classes
	-- Trial of the Crusader 25 Player (Heroic) (id: 757).
	[47464] = "0365002707767", -- Death's Choice,                                 	Strength/Agility
	[47451] = "33F7777777777", -- Juggernaut's Vitality,                          	All Classes
	[47477] = "3092775070010", -- Reign of the Dead,                              	Intellect
	[47432] = "3092775070010", -- Solace of the Fallen,                           	Intellect
	-- Onyxia's Lair 10 Player (id: 760).
	[49463] = "33F7777777777", -- Purified Shard of the Flame,                    	All Classes
	[49310] = "33F7777777777", -- Purified Shard of the Scale,                    	All Classes
	-- Onyxia's Lair 25 Player (id: 760).
	[49464] = "33F7777777777", -- Shiny Shard of the Flame,                       	All Classes
	[49488] = "33F7777777777", -- Shiny Shard of the Scale,                       	All Classes
	-- Icecrown Citadel 10 Player (id: 758).
	[50340] = "33F7777777777", -- Muradin's Spyglass,                             	All Classes
	[50339] = "3092775070010", -- Sliver of Pure Ice,                             	Intellect
	[50341] = "33F7777777777", -- Unidentifiable Organ,                           	All Classes
	[50342] = "33F7777777777", -- Whispering Fanged Skull,                        	All Classes
	-- Icecrown Citadel 25 Player (id: 758).
	[50359] = "3092775070010", -- Althor's Abacus,                                	Intellect
	[50354] = "33F7777777777", -- Bauble of True Blood,                           	All Classes
	[50352] = "33F7777777777", -- Corpse Tongue Coin,                             	All Classes
	[50362] = "33F7777777777", -- Deathbringer's Will,                            	All Classes
	[50353] = "33F7777777777", -- Dislodged Foreign Object,                       	All Classes
	[50360] = "33F7777777777", -- Phylactery of the Nameless Lich,                	All Classes
	[50361] = "33F7777777777", -- Sindragosa's Flawless Fang,                     	All Classes
	[50351] = "33F7777777777", -- Tiny Abomination in a Jar,                      	All Classes
	-- Icecrown Citadel 10 Player (Heroic) (id: 758).
	[50345] = "33F7777777777", -- Muradin's Spyglass,                             	All Classes
	[50346] = "3092775070010", -- Sliver of Pure Ice,                             	Intellect
	[50344] = "33F7777777777", -- Unidentifiable Organ,                           	All Classes
	[50343] = "33F7777777777", -- Whispering Fanged Skull,                        	All Classes
	-- Icecrown Citadel 25 Player (Heroic) (id: 758).
	[50366] = "3092775070010", -- Althor's Abacus,                                	Intellect
	[50726] = "33F7777777777", -- Bauble of True Blood,                           	All Classes
	[50349] = "33F7777777777", -- Corpse Tongue Coin,                             	All Classes
	[50363] = "33F7777777777", -- Deathbringer's Will,                            	All Classes
	[50348] = "33F7777777777", -- Dislodged Foreign Object,                       	All Classes
	[50365] = "33F7777777777", -- Phylactery of the Nameless Lich,                	All Classes
	[50364] = "33F7777777777", -- Sindragosa's Flawless Fang,                     	All Classes
	[50706] = "33F7777777777", -- Tiny Abomination in a Jar,                      	All Classes
	-- The Ruby Sanctum 10 Player (id: 761).
	-- The Ruby Sanctum 25 Player (id: 761).
	[54572] = "33F7777777777", -- Charred Twilight Scale,                         	All Classes
	[54573] = "3092775070010", -- Glowing Twilight Scale,                         	Intellect
	[54571] = "33F7777777777", -- Petrified Twilight Scale,                       	All Classes
	[54569] = "33F7777777777", -- Sharpened Twilight Scale,                       	All Classes
	-- The Ruby Sanctum 10 Player (Heroic) (id: 761).
	-- The Ruby Sanctum 25 Player (Heroic) (id: 761).
	[54588] = "33F7777777777", -- Charred Twilight Scale,                         	All Classes
	[54589] = "3092775070010", -- Glowing Twilight Scale,                         	Intellect
	[54591] = "33F7777777777", -- Petrified Twilight Scale,                       	All Classes
	[54590] = "33F7777777777", -- Sharpened Twilight Scale,                       	All Classes
	-- Blackrock Caverns Normal (id: 66).
	[56295] = "0124002007700", -- Grace of the Herald,                            	Damage, Agility
	[56320] = "3092775070010", -- Witching Hourglass,                             	Intellect
	-- Blackrock Caverns Heroic (id: 66).
	-- Blackrock Caverns Timewalking (id: 66).
	[188490] = "0124002007700", -- Grace of the Herald,                            	Damage, Agility
	[188514] = "3092775070010", -- Witching Hourglass,                             	Intellect
	-- End Time Heroic (id: 184).
	[72897] = "0124002007700", -- Arrow of Time,                                  	Damage, Agility
	-- End Time Timewalking (id: 184).
	[133420] = "0124002007700", -- Arrow of Time,                                  	Damage, Agility
	-- Grim Batol Normal (id: 71).
	[56463] = "0082004030010", -- Corrupted Egg Shell,                            	Healer
	[56462] = "0092775070010", -- Gale of Shadows,                                	Intellect
	[56458] = "0000000700067", -- Mark of Khardros,                               	Strength
	[56440] = "0365002007700", -- Skardyn's Grace,                                	Agility
	[56449] = "0201000100024", -- Throngus's Finger,                              	Tank, Parry
	-- Grim Batol Heroic (id: 71).
	-- Halls of Origination Normal (id: 70).
	[56407] = "0092775070010", -- Anhuur's Hymnal,                                	Intellect
	[56414] = "0082004030010", -- Blood of Isiset,                                	Healer
	[56427] = "0365002007700", -- Left Eye of Rajh,                               	Agility
	[56431] = "0000000600043", -- Right Eye of Rajh,                              	Damage, Strength
	-- Halls of Origination Heroic (id: 70).
	-- Hour of Twilight Heroic (id: 186).
	[72901] = "0000000600043", -- Rosary of Light,                                	Damage, Strength
	[72900] = "0241000100024", -- Veil of Lies,                                   	Tank
	-- Lost City of the Tol'vir Normal (id: 69).
	[56393] = "0000000600043", -- Heart of Solace,                                	Damage, Strength
	[56400] = "0010771050000", -- Sorrowsong,
	[56394] = "0124002007700", -- Tia's Grace,                                    	Damage, Agility
	-- Lost City of the Tol'vir Heroic (id: 69).
	-- Lost City of the Tol'vir Timewalking (id: 69).
	[133268] = "0000000600043", -- Heart of Solace,                                	Damage, Strength
	[133281] = "0201000100024", -- Impetuous Query,                                	Tank, Parry
	[133275] = "0010771050000", -- Sorrowsong,
	[133269] = "0124002007700", -- Tia's Grace,                                    	Damage, Agility
	-- The Stonecore Normal (id: 67).
	[56328] = "0124002007700", -- Key to the Endless Chamber,                     	Damage, Agility
	[56347] = "0241000100024", -- Leaden Despair,                                 	Tank
	[56345] = "0000000600043", -- Magnetite Mirror,                               	Damage, Strength
	[56351] = "0082004030010", -- Tear of Blood,                                  	Healer
	[56339] = "0092775070010", -- Tendrils of Burrowing Dark,                     	Intellect
	-- The Stonecore Heroic (id: 67).
	-- The Stonecore Timewalking (id: 67).
	[133206] = "0124002007700", -- Key to the Endless Chamber,                     	Damage, Agility
	[133224] = "0241000100024", -- Leaden Despair,                                 	Tank
	[133222] = "0000000600043", -- Magnetite Mirror,                               	Damage, Strength
	[133227] = "0082004030010", -- Tear of Blood,                                  	Healer
	[133216] = "0092775070010", -- Tendrils of Burrowing Dark,                     	Intellect
	-- The Vortex Pinnacle Normal (id: 68).
	[56370] = "0241000100024", -- Heart of Thunder,                               	Tank
	-- The Vortex Pinnacle Heroic (id: 68).
	-- The Vortex Pinnacle Timewalking (id: 68).
	[133246] = "0241000100024", -- Heart of Thunder,                               	Tank
	[133252] = "0082004030010", -- Rainsong,                                       	Healer
	-- Throne of the Tides Normal (id: 65).
	[56285] = "0000000600043", -- Might of the Ocean,                             	Damage, Strength
	[56280] = "0241000100024", -- Porcelain Crab,                                 	Tank
	[56290] = "0092774070010", -- Sea Star,
	-- Throne of the Tides Heroic (id: 65).
	-- Throne of the Tides Timewalking (id: 65).
	[133197] = "0000000600043", -- Might of the Ocean,                             	Damage, Strength
	[133192] = "0365002107467", -- Porcelain Crab,                                 	Melee?
	[133201] = "0092775070010", -- Sea Star,                                       	Intellect
	-- Well of Eternity Heroic (id: 185).
	[72898] = "3092775070010", -- Foul Gift of the Demon Lord,                    	Intellect
	[72899] = "0000000700067", -- Varo'then's Brooch,                             	Strength
	-- Zul'Aman Normal (id: 77).
	-- Zul'Aman Heroic (id: 77).
	-- Zul'Gurub Normal (id: 76).
	-- Zul'Gurub Heroic (id: 76).
	-- Baradin Hold 10 Player (id: 75).
	[73648] = "0365002007700", -- Cataclysmic Gladiator's Badge of Conquest,      	Agility
	[73498] = "3092775070010", -- Cataclysmic Gladiator's Badge of Dominance,     	Intellect
	[73496] = "0000000700067", -- Cataclysmic Gladiator's Badge of Victory,       	Strength
	[73593] = "33F7777777777", -- Cataclysmic Gladiator's Emblem of Cruelty,      	All Classes
	[73591] = "33F7777777777", -- Cataclysmic Gladiator's Emblem of Meditation,   	All Classes
	[73592] = "33F7777777777", -- Cataclysmic Gladiator's Emblem of Tenacity,     	All Classes
	[73643] = "0365002007700", -- Cataclysmic Gladiator's Insignia of Conquest,   	Agility
	[73497] = "3092775070010", -- Cataclysmic Gladiator's Insignia of Dominance,  	Intellect
	[73491] = "0000000700067", -- Cataclysmic Gladiator's Insignia of Victory,    	Strength
	[73538] = "33F7777777777", -- Cataclysmic Gladiator's Medallion of Cruelty,   	All Classes
	[73534] = "33F7777777777", -- Cataclysmic Gladiator's Medallion of Meditation,	All Classes
	[73537] = "33F7777777777", -- Cataclysmic Gladiator's Medallion of Tenacity,  	All Classes
	[70399] = "0365002007700", -- Ruthless Gladiator's Badge of Conquest,         	Agility
	[70401] = "3092775070010", -- Ruthless Gladiator's Badge of Dominance,        	Intellect
	[70400] = "0000000700067", -- Ruthless Gladiator's Badge of Victory,          	Strength
	[70396] = "33F7777777777", -- Ruthless Gladiator's Emblem of Cruelty,         	All Classes
	[70397] = "33F7777777777", -- Ruthless Gladiator's Emblem of Meditation,      	All Classes
	[70398] = "33F7777777777", -- Ruthless Gladiator's Emblem of Tenacity,        	All Classes
	[70404] = "0365002007700", -- Ruthless Gladiator's Insignia of Conquest,      	Agility
	[70402] = "3092775070010", -- Ruthless Gladiator's Insignia of Dominance,     	Intellect
	[70403] = "0000000700067", -- Ruthless Gladiator's Insignia of Victory,       	Strength
	[70393] = "33F7777777777", -- Ruthless Gladiator's Medallion of Cruelty,      	All Classes
	[70394] = "33F7777777777", -- Ruthless Gladiator's Medallion of Meditation,   	All Classes
	[70395] = "33F7777777777", -- Ruthless Gladiator's Medallion of Tenacity,     	All Classes
	[61033] = "0365002007700", -- Vicious Gladiator's Badge of Conquest,          	Agility
	[61026] = "33F7777777777", -- Vicious Gladiator's Emblem of Cruelty,          	All Classes
	[61031] = "33F7777777777", -- Vicious Gladiator's Emblem of Meditation,       	All Classes
	[61032] = "33F7777777777", -- Vicious Gladiator's Emblem of Tenacity,         	All Classes
	[61047] = "0365002007700", -- Vicious Gladiator's Insignia of Conquest,       	Agility
	[60801] = "33F7777777777", -- Vicious Gladiator's Medallion of Cruelty,       	All Classes
	[60806] = "33F7777777777", -- Vicious Gladiator's Medallion of Meditation,    	All Classes
	[60807] = "33F7777777777", -- Vicious Gladiator's Medallion of Tenacity,      	All Classes
	-- Baradin Hold 25 Player (id: 75).
	-- Blackwing Descent 10 Player (id: 73).
	[59326] = "33F7777777777", -- Bell of Enraging Resonance,                     	All Classes
	[59224] = "0000000700067", -- Heart of Rage,                                  	Strength
	[59354] = "0082004030010", -- Jar of Ancient Remedies,                        	Healer
	[59441] = "0365002007700", -- Prestor's Talisman of Machination,              	Agility
	[59332] = "0241000100024", -- Symbiotic Worm,                                 	Tank
	-- Blackwing Descent 25 Player (id: 73).
	-- Blackwing Descent 10 Player (Heroic) (id: 73).
	[65053] = "33F7777777777", -- Bell of Enraging Resonance,                     	All Classes
	[65072] = "0000000700067", -- Heart of Rage,                                  	Strength
	[65029] = "0082004030010", -- Jar of Ancient Remedies,                        	Healer
	[65026] = "0365002007700", -- Prestor's Talisman of Machination,              	Agility
	[65048] = "0241000100024", -- Symbiotic Worm,                                 	Tank
	-- Blackwing Descent 25 Player (Heroic) (id: 73).
	-- The Bastion of Twilight 10 Player (id: 72).
	[59506] = "0000000700067", -- Crushing Weight,                                	Strength
	[59473] = "0365002007700", -- Essence of the Cyclone,                         	Agility
	[59500] = "3092775070010", -- Fall of Mortality,                              	Intellect
	[59514] = "33F7777777777", -- Heart of Ignacious,                             	All Classes
	[59519] = "3092775070010", -- Theralion's Mirror,                             	Intellect
	[59515] = "33F7777777777", -- Vial of Stolen Memories,                        	All Classes
	-- The Bastion of Twilight 25 Player (id: 72).
	-- The Bastion of Twilight 10 Player (Heroic) (id: 72).
	[65118] = "0000000700067", -- Crushing Weight,                                	Strength
	[65140] = "0365002007700", -- Essence of the Cyclone,                         	Agility
	[65124] = "3092775070010", -- Fall of Mortality,                              	Intellect
	[65110] = "33F7777777777", -- Heart of Ignacious,                             	All Classes
	[60233] = "33F7777777777", -- Shard of Woe,                                   	All Classes
	[65105] = "3092775070010", -- Theralion's Mirror,                             	Intellect
	[65109] = "33F7777777777", -- Vial of Stolen Memories,                        	All Classes
	-- The Bastion of Twilight 25 Player (Heroic) (id: 72).
	-- Throne of the Four Winds 10 Player (id: 74).
	-- Throne of the Four Winds 25 Player (id: 74).
	-- Throne of the Four Winds 10 Player (Heroic) (id: 74).
	-- Throne of the Four Winds 25 Player (Heroic) (id: 74).
	-- Firelands Normal (id: 78).
	[68983] = "3092775070010", -- Eye of Blazing Power,                           	Intellect
	[68926] = "3092775070010", -- Jaws of Defeat,                                 	Intellect
	[68994] = "0365002007700", -- Matrix Restabilizer,                            	Agility
	[68982] = "3092775070010", -- Necromantic Focus,                              	Intellect
	[68981] = "0241000100024", -- Spidersilk Spindle,                             	Tank
	[68927] = "0365002007700", -- The Hungerer,                                   	Agility
	[68925] = "3092775070010", -- Variable Pulse Lightning Capacitor,             	Intellect
	[68995] = "0000000700067", -- Vessel of Acceleration,                         	Strength
	-- Firelands Heroic (id: 78).
	[69149] = "3092775070010", -- Eye of Blazing Power,                           	Intellect
	[69111] = "3092775070010", -- Jaws of Defeat,                                 	Intellect
	[69150] = "0365002007700", -- Matrix Restabilizer,                            	Agility
	[69139] = "3092775070010", -- Necromantic Focus,                              	Intellect
	[69138] = "0241000100024", -- Spidersilk Spindle,                             	Tank
	[69112] = "0365002007700", -- The Hungerer,                                   	Agility
	[69110] = "3092775070010", -- Variable Pulse Lightning Capacitor,             	Intellect
	[69167] = "0000000700067", -- Vessel of Acceleration,                         	Strength
	-- Firelands Timewalking (id: 78).
	[171645] = "3092775070010", -- Eye of Blazing Power,                           	Intellect
	[171641] = "3092775070010", -- Jaws of Defeat,                                 	Intellect
	[171646] = "0365002007700", -- Matrix Restabilizer,                            	Agility
	[171644] = "3092775070010", -- Necromantic Focus,                              	Intellect
	[171643] = "0241000100024", -- Spidersilk Spindle,                             	Tank
	[171642] = "0365002007700", -- The Hungerer,                                   	Agility
	[171640] = "3092775070010", -- Variable Pulse Lightning Capacitor,             	Intellect
	[171647] = "0000000700067", -- Vessel of Acceleration,                         	Strength
	-- Dragon Soul 10 Player (id: 187).
	[77210] = "0000000700067", -- Bone-Link Fetish,                               	Strength
	[77205] = "0000000700067", -- Creche of the Final Dragon,                     	Strength
	[77208] = "0010771040000", -- Cunning of the Cruel,                           	Damage, Intellect
	[77200] = "0000000700067", -- Eye of Unmaking,                                	Strength
	[77199] = "3092775070010", -- Heart of Unliving,                              	Intellect
	[77211] = "0241000100024", -- Indomitable Pride,                              	Tank
	[77203] = "3092775070010", -- Insignia of the Corrupted Mind,                 	Intellect
	[77201] = "0241000100024", -- Resolve of Undying,                             	Tank
	[77204] = "3092775070010", -- Seal of the Seven Signs,                        	Intellect
	[77206] = "0241000100024", -- Soulshifter Vortex,                             	Tank
	[77202] = "0365002007700", -- Starcatcher Compass,                            	Agility
	[77207] = "0365002007700", -- Vial of Shadows,                                	Agility
	[77198] = "0010771040000", -- Will of Unbinding,                              	Damage, Intellect
	[77209] = "0082004030010", -- Windward Heart,                                 	Healer
	[77197] = "0365002007700", -- Wrath of Unchaining,                            	Agility
	-- Dragon Soul 25 Player (id: 187).
	-- Dragon Soul 10 Player (Heroic) (id: 187).
	[78002] = "0000000700067", -- Bone-Link Fetish,                               	Strength
	[77992] = "0000000700067", -- Creche of the Final Dragon,                     	Strength
	[78000] = "3092775070010", -- Cunning of the Cruel,                           	Intellect
	[77997] = "0000000700067", -- Eye of Unmaking,                                	Strength
	[77996] = "0082004030010", -- Heart of Unliving,                              	Healer
	[78003] = "0241000100024", -- Indomitable Pride,                              	Tank
	[77991] = "3092775070010", -- Insignia of the Corrupted Mind,                 	Intellect
	[77998] = "0241000100024", -- Resolve of Undying,                             	Tank
	[77989] = "3092775070010", -- Seal of the Seven Signs,                        	Intellect
	[77990] = "0241000100044", -- Soulshifter Vortex,                             	Tank?
	[77993] = "0365002007700", -- Starcatcher Compass,                            	Agility
	[77999] = "0365002007700", -- Vial of Shadows,                                	Agility
	[77995] = "0010771040000", -- Will of Unbinding,                              	Damage, Intellect
	[78001] = "0082004030010", -- Windward Heart,                                 	Healer
	[77994] = "0365002007700", -- Wrath of Unchaining,                            	Agility
	-- Dragon Soul 25 Player (Heroic) (id: 187).
	-- Dragon Soul Looking For Raid (id: 187).
	[77982] = "0000000600043", -- Bone-Link Fetish,                               	Damage, Strength
	[77972] = "0000000600043", -- Creche of the Final Dragon,                     	Damage, Strength
	[77980] = "0010771040000", -- Cunning of the Cruel,                           	Damage, Intellect
	[77977] = "0000000700067", -- Eye of Unmaking,                                	Strength
	[77976] = "0092005070010", -- Heart of Unliving,                              	Healer
	[77983] = "0041000100024", -- Indomitable Pride,                              	Tank
	[77971] = "0090775070000", -- Insignia of the Corrupted Mind,
	[77978] = "0041000100024", -- Resolve of Undying,                             	Tank
	[77969] = "0092005070010", -- Seal of the Seven Signs,                        	Healer
	[77970] = "0041000100024", -- Soulshifter Vortex,                             	Tank
	[77973] = "0065002007700", -- Starcatcher Compass,
	[77979] = "0065002007700", -- Vial of Shadows,
	[77975] = "0010771040000", -- Will of Unbinding,                              	Damage, Intellect
	[77981] = "0082004030010", -- Windward Heart,                                 	Healer
	[77974] = "0065002007700", -- Wrath of Unchaining,
	-- Gate of the Setting Sun Normal (id: 303).
	[144136] = "3092775070010", -- Vision of the Predator,                         	Intellect
	-- Gate of the Setting Sun Heroic (id: 303).
	-- Gate of the Setting Sun Timewalking (id: 303).
	-- Mogu'shan Palace Normal (id: 321).
	[144146] = "0241000100024", -- Iron Protector Talisman,                        	Tank
	-- Mogu'shan Palace Heroic (id: 321).
	-- Mogu'shan Palace Timewalking (id: 321).
	-- Shado-Pan Monastery Normal (id: 312).
	[144128] = "0241000100024", -- Heart of Fire,                                  	Tank
	-- Shado-Pan Monastery Heroic (id: 312).
	-- Shado-Pan Monastery Timewalking (id: 312).
	-- Siege of Niuzao Temple Normal (id: 324).
	[144156] = "0092775070010", -- Flashfrozen Resin Globule,                      	Intellect
	[144157] = "3092775070010", -- Vial of Ichorous Blood,                         	Intellect
	-- Siege of Niuzao Temple Heroic (id: 324).
	-- Stormstout Brewery Normal (id: 302).
	[144122] = "0000000700067", -- Carbonic Carbuncle,                             	Strength
	[144119] = "0092775070010", -- Empty Fruit Barrel,                             	Intellect
	-- Stormstout Brewery Heroic (id: 302).
	-- Stormstout Brewery Timewalking (id: 302).
	-- Temple of the Jade Serpent Normal (id: 313).
	[144113] = "0365002007700", -- Windswept Pages,                                	Agility
	-- Temple of the Jade Serpent Heroic (id: 313).
	-- Temple of the Jade Serpent Mythic (id: 313).
	-- Temple of the Jade Serpent Timewalking (id: 313).
	-- Pandaria 10 Player (id: 322).
	-- Pandaria 25 Player (id: 322).
	-- Pandaria 10 Player (Heroic) (id: 322).
	-- Pandaria 25 Player (Heroic) (id: 322).
	-- Pandaria Looking For Raid (id: 322).
	-- Mogu'shan Vaults 10 Player (id: 317).
	[86132] = "0365002007700", -- Bottle of Infinite Stars,                       	Agility
	[86144] = "0000000600043", -- Lei Shen's Final Orders,                        	Damage, Strength
	[86133] = "0010771040000", -- Light of the Cosmos,                            	Damage, Intellect
	[86147] = "0082004030010", -- Qin-xi's Polarizing Seal,                       	Healer
	[86131] = "0241000100024", -- Vial of Dragon's Blood,                         	Tank
	-- Mogu'shan Vaults 25 Player (id: 317).
	-- Mogu'shan Vaults 10 Player (Heroic) (id: 317).
	[87057] = "0365002007700", -- Bottle of Infinite Stars,                       	Agility
	[87072] = "0000000600043", -- Lei Shen's Final Orders,                        	Damage, Strength
	[87065] = "0010771040000", -- Light of the Cosmos,                            	Damage, Intellect
	[87075] = "0082004030010", -- Qin-xi's Polarizing Seal,                       	Healer
	[87063] = "0241000100024", -- Vial of Dragon's Blood,                         	Tank
	-- Mogu'shan Vaults 25 Player (Heroic) (id: 317).
	-- Mogu'shan Vaults Looking For Raid (id: 317).
	[86791] = "0365002007700", -- Bottle of Infinite Stars,                       	Agility
	[86802] = "0000000600043", -- Lei Shen's Final Orders,                        	Damage, Strength
	[86792] = "0010771040000", -- Light of the Cosmos,                            	Damage, Intellect
	[86805] = "0082004030010", -- Qin-xi's Polarizing Seal,                       	Healer
	[86790] = "0241000100024", -- Vial of Dragon's Blood,                         	Tank
	-- Heart of Fear 10 Player (id: 330).
	-- Heart of Fear 25 Player (id: 330).
	-- Heart of Fear 10 Player (Heroic) (id: 330).
	-- Heart of Fear 25 Player (Heroic) (id: 330).
	-- Heart of Fear Looking For Raid (id: 330).
	-- Terrace of Endless Spring 10 Player (id: 320).
	[86336] = "0000000600043", -- Darkmist Vortex,                                	Damage, Strength
	[86388] = "0010771040000", -- Essence of Terror,                              	Damage, Intellect
	[86327] = "0082004030010", -- Spirits of the Sun,                             	Healer
	[86323] = "0241000100024", -- Stuff of Nightmares,                            	Tank
	[86332] = "0365002007700", -- Terror in the Mists,                            	Agility
	-- Terrace of Endless Spring 25 Player (id: 320).
	-- Terrace of Endless Spring 10 Player (Heroic) (id: 320).
	[87172] = "0000000600043", -- Darkmist Vortex,                                	Damage, Strength
	[87175] = "0010771040000", -- Essence of Terror,                              	Damage, Intellect
	[87163] = "0082004030010", -- Spirits of the Sun,                             	Healer
	[87160] = "0241000100024", -- Stuff of Nightmares,                            	Tank
	[87167] = "0365002007700", -- Terror in the Mists,                            	Agility
	-- Terrace of Endless Spring 25 Player (Heroic) (id: 320).
	-- Terrace of Endless Spring Looking For Raid (id: 320).
	[86894] = "0000000600043", -- Darkmist Vortex,                                	Damage, Strength
	[86907] = "0010771040000", -- Essence of Terror,                              	Damage, Intellect
	[86885] = "0082004030010", -- Spirits of the Sun,                             	Healer
	[86881] = "0241000100024", -- Stuff of Nightmares,                            	Tank
	[86890] = "0365002007700", -- Terror in the Mists,                            	Agility
	-- Throne of Thunder 10 Player (id: 362).
	[94523] = "0365002007700", -- Bad Juju,                                       	Agility
	[94521] = "0010771040000", -- Breath of the Hydra,                            	Damage, Intellect
	[94531] = "0010771040000", -- Cha-Ye's Essence of Brilliance,                 	Damage, Intellect
	[94518] = "0241000100024", -- Delicate Vial of the Sanguinaire,               	Tank
	[94515] = "0000000600043", -- Fabled Feather of Ji-Kun,                       	Damage, Strength
	[94516] = "0241000100024", -- Fortitude of the Zandalari,                     	Tank
	[94529] = "0000000600043", -- Gaze of the Twins,                              	Damage, Strength
	[94514] = "0082004030010", -- Horridon's Last Gasp,                           	Healer
	[94520] = "0082004030010", -- Inscribed Bag of Hydra-Spawn,                   	Healer
	[94527] = "0241000100024", -- Ji-Kun's Rising Winds,                          	Tank
	[94530] = "0082004030010", -- Lightning-Imbued Chalice,                       	Healer
	[94519] = "0000000600043", -- Primordius' Talisman of Rage,                   	Damage, Strength
	[94512] = "0365002007700", -- Renataki's Soul Charm,                          	Agility
	[94532] = "0365002007700", -- Rune of Re-Origination,                         	Agility
	[94528] = "0241000100024", -- Soul Barrier,                                   	Tank
	[94526] = "0000000600043", -- Spark of Zandalar,                              	Damage, Strength
	[94525] = "0082004030010", -- Stolen Relic of Zuldazar,                       	Healer
	[94522] = "0365002007700", -- Talisman of Bloodlust,                          	Agility
	[94524] = "0010771040000", -- Unerring Vision of Lei Shen,                    	Damage, Intellect
	[94513] = "0010771040000", -- Wushoolay's Final Choice,                       	Damage, Intellect
	-- Throne of Thunder 25 Player (id: 362).
	-- Throne of Thunder 10 Player (Heroic) (id: 362).
	[96409] = "0365002007700", -- Bad Juju,                                       	Agility
	[96455] = "0010771040000", -- Breath of the Hydra,                            	Damage, Intellect
	[96516] = "0010771040000", -- Cha-Ye's Essence of Brilliance,                 	Damage, Intellect
	[96523] = "0241000100024", -- Delicate Vial of the Sanguinaire,               	Tank
	[96470] = "0000000600043", -- Fabled Feather of Ji-Kun,                       	Damage, Strength
	[96421] = "0241000100024", -- Fortitude of the Zandalari,                     	Tank
	[96543] = "0000000600043", -- Gaze of the Twins,                              	Damage, Strength
	[96385] = "0082004030010", -- Horridon's Last Gasp,                           	Healer
	[96456] = "0082004030010", -- Inscribed Bag of Hydra-Spawn,                   	Healer
	[96471] = "0241000100024", -- Ji-Kun's Rising Winds,                          	Tank
	[96561] = "0082004030010", -- Lightning-Imbued Chalice,                       	Healer
	[96501] = "0000000600043", -- Primordius' Talisman of Rage,                   	Damage, Strength
	[96369] = "0365002007700", -- Renataki's Soul Charm,                          	Agility
	[96546] = "0365002007700", -- Rune of Re-Origination,                         	Agility
	[96555] = "0241000100024", -- Soul Barrier,                                   	Tank
	[96398] = "0000000600043", -- Spark of Zandalar,                              	Damage, Strength
	[96507] = "0082004030010", -- Stolen Relic of Zuldazar,                       	Healer
	[96492] = "0365002007700", -- Talisman of Bloodlust,                          	Agility
	[96558] = "0010771040000", -- Unerring Vision of Lei Shen,                    	Damage, Intellect
	[96413] = "0010771040000", -- Wushoolay's Final Choice,                       	Damage, Intellect
	-- Throne of Thunder 25 Player (Heroic) (id: 362).
	-- Throne of Thunder Looking For Raid (id: 362).
	[95665] = "0365002007700", -- Bad Juju,                                       	Agility
	[95711] = "0010771040000", -- Breath of the Hydra,                            	Damage, Intellect
	[95772] = "0010771040000", -- Cha-Ye's Essence of Brilliance,                 	Damage, Intellect
	[95779] = "0241000100024", -- Delicate Vial of the Sanguinaire,               	Tank
	[95726] = "0000000600043", -- Fabled Feather of Ji-Kun,                       	Damage, Strength
	[95677] = "0241000100024", -- Fortitude of the Zandalari,                     	Tank
	[95799] = "0000000600043", -- Gaze of the Twins,                              	Damage, Strength
	[95641] = "0082004030010", -- Horridon's Last Gasp,                           	Healer
	[95712] = "0082004030010", -- Inscribed Bag of Hydra-Spawn,                   	Healer
	[95727] = "0241000100024", -- Ji-Kun's Rising Winds,                          	Tank
	[95817] = "0082004030010", -- Lightning-Imbued Chalice,                       	Healer
	[95757] = "0000000600043", -- Primordius' Talisman of Rage,                   	Damage, Strength
	[95625] = "0365002007700", -- Renataki's Soul Charm,                          	Agility
	[95802] = "0365002007700", -- Rune of Re-Origination,                         	Agility
	[95811] = "0241000100024", -- Soul Barrier,                                   	Tank
	[95654] = "0000000600043", -- Spark of Zandalar,                              	Damage, Strength
	[95763] = "0082004030010", -- Stolen Relic of Zuldazar,                       	Healer
	[95748] = "0365002007700", -- Talisman of Bloodlust,                          	Agility
	[95814] = "0010771040000", -- Unerring Vision of Lei Shen,                    	Damage, Intellect
	[95669] = "0010771040000", -- Wushoolay's Final Choice,                       	Damage, Intellect
	-- Siege of Orgrimmar Normal (id: 369).
	[112947] = "0124002007700", -- Assurance of Consequence,                       	Damage, Agility
	[112938] = "0010771040000", -- Black Blood of Y'Shaarj,                        	Damage, Intellect
	[112924] = "0241000100024", -- Curse of Hubris,                                	Tank
	[112877] = "0082004030010", -- Dysmorphic Samophlange of Discontinuity,        	Healer
	[112703] = "0000000600043", -- Evil Eye of Galakras,                           	Damage, Strength
	[112815] = "0010771040000", -- Frenzied Crystal of Rage,                       	Damage, Intellect
	[112503] = "0000000600043", -- Fusion-Fire Core,                               	Damage, Strength
	[112754] = "0124002007700", -- Haromm's Talisman,                              	Damage, Agility
	[112729] = "0241000100024", -- Juggernaut's Focusing Crystal,                  	Tank
	[112768] = "0010771040000", -- Kardris' Toxic Totem,                           	Damage, Intellect
	[112778] = "0082004030010", -- Nazgrim's Burnished Insignia,                   	Healer
	[112948] = "0082004030010", -- Prismatic Prison of Pride,                      	Healer
	[112426] = "0010771040000", -- Purified Bindings of Immerseus,                 	Damage, Intellect
	[112476] = "0241000100024", -- Rook's Unlucky Talisman,                        	Tank
	[112825] = "0124002007700", -- Sigil of Rampage,                               	Damage, Agility
	[112913] = "0000000600043", -- Skeer's Bloodsoaked Talisman,                   	Damage, Strength
	[112849] = "0082004030010", -- Thok's Acid-Grooved Tooth,                      	Healer
	[112850] = "0000000600043", -- Thok's Tail Tip,                                	Damage, Strength
	[112879] = "0365002007700", -- Ticking Ebon Detonator,                         	Agility
	[112792] = "0241000100024", -- Vial of Living Corruption,                      	Tank
	-- Siege of Orgrimmar Heroic (id: 369).
	-- Siege of Orgrimmar Mythic (id: 369).
	-- Siege of Orgrimmar Looking For Raid (id: 369).
	-- Auchindoun Normal (id: 547).
	[109995] = "0365002007700", -- Blood Seal of Azzakel,                          	Agility
	[110005] = "0082004030010", -- Crystalline Blood Drop,                         	Healer
	[110010] = "0000000600043", -- Mote of Corruption,                             	Damage, Strength
	-- Auchindoun Heroic (id: 547).
	-- Auchindoun Mythic (id: 547).
	-- Auchindoun Timewalking (id: 547).
	-- Bloodmaul Slag Mines Normal (id: 385).
	[110000] = "0010771040000", -- Crushto's Runic Alarm,                          	Damage, Intellect
	[110015] = "0041000100024", -- Toria's Unseeing Eye,                           	Tank
	-- Bloodmaul Slag Mines Heroic (id: 385).
	-- Bloodmaul Slag Mines Mythic (id: 385).
	-- Bloodmaul Slag Mines Timewalking (id: 385).
	-- Grimrail Depot Normal (id: 536).
	[109996] = "0365002007700", -- Thundertower's Targeting Reticle,               	Agility
	[110001] = "3092775070010", -- Tovra's Lightning Repository,                   	Intellect
	-- Grimrail Depot Heroic (id: 536).
	-- Grimrail Depot Mythic (id: 536).
	-- Grimrail Depot Timewalking (id: 536).
	-- Iron Docks Normal (id: 558).
	[110017] = "33F7777777777", -- Enforcer's Stun Grenade,                        	All Classes
	[110002] = "3092775070010", -- Fleshrender's Meathook,                         	Intellect
	[109997] = "0365002007700", -- Kihra's Adrenaline Injector,                    	Agility
	-- Iron Docks Heroic (id: 558).
	-- Iron Docks Mythic (id: 558).
	-- Shadowmoon Burial Grounds Normal (id: 537).
	[110012] = "0000000600043", -- Bonemaw's Big Toe,                              	Damage, Strength
	[110007] = "0082004030010", -- Voidmender's Shadowgem,                         	Healer
	-- Shadowmoon Burial Grounds Heroic (id: 537).
	-- Shadowmoon Burial Grounds Mythic (id: 537).
	-- Shadowmoon Burial Grounds Timewalking (id: 537).
	-- Skyreach Normal (id: 476).
	[110011] = "0000000600043", -- Fires of the Sun,                               	Damage, Strength
	[110006] = "0082004030010", -- Rukhran's Quill,                                	Healer
	[110016] = "0241000100024", -- Solar Containment Unit,                         	Tank
	-- Skyreach Heroic (id: 476).
	-- Skyreach Mythic (id: 476).
	-- Skyreach Timewalking (id: 476).
	-- The Everbloom Normal (id: 556).
	[110004] = "0010771040000", -- Coagulated Genesaur Blood,                      	Damage, Intellect
	[110009] = "0082004030010", -- Leaf of the Ancient Protectors,                 	Healer
	[110014] = "0000000600043", -- Spores of Alacrity,                             	Damage, Strength
	[109999] = "0365002007700", -- Witherbark's Branch,                            	Agility
	[110019] = "0241000100024", -- Xeri'tac's Unhatched Egg Sac,                   	Tank
	-- The Everbloom Heroic (id: 556).
	-- The Everbloom Mythic (id: 556).
	-- The Everbloom Timewalking (id: 556).
	-- Upper Blackrock Spire Normal (id: 559).
	[110013] = "0000000600043", -- Emberscale Talisman,                            	Damage, Strength
	[109998] = "0365002007700", -- Gor'ashan's Lodestone Spike,                    	Agility
	[110018] = "0241000100024", -- Kyrak's Vileblood Serum,                        	Tank
	[110003] = "0010771040000", -- Ragewing's Firefang,                            	Damage, Intellect
	[110008] = "0082004030010", -- Tharbek's Lucky Pebble,                         	Healer
	-- Upper Blackrock Spire Heroic (id: 559).
	-- Upper Blackrock Spire Mythic (id: 559).
	-- Draenor Normal (id: 557).
	-- Draenor Heroic (id: 557).
	[124545] = "33F7777777777", -- Chipped Soul Prism,                             	All Classes
	[124546] = "33F7777777777", -- Mark of Supreme Doom,                           	All Classes
	-- Draenor Mythic (id: 557).
	-- Draenor Looking For Raid (id: 557).
	-- Highmaul Normal (id: 477).
	[113658] = "0000000600043", -- Bottle of Infesting Spores,                     	Damage, Strength
	[113853] = "0124002007700", -- Captive Micro-Aberration,                       	Damage, Agility
	[113842] = "0082004030010", -- Emblem of Caustic Healing,                      	Healer
	[113861] = "0241000100024", -- Evergaze Arcane Eidolon,                        	Tank
	[113854] = "0082004030010", -- Mark of Rapid Replication,                      	Healer
	[113650] = "0241000100024", -- Pillar of the Earth,                            	Tank
	[113834] = "0241000100024", -- Pol's Blinded Eye,                              	Tank
	[113859] = "0010771040000", -- Quiescent Runestone,                            	Damage, Intellect
	[113612] = "0124002007700", -- Scales of Doom,                                 	Damage, Agility
	[113835] = "0010771040000", -- Shards of Nothing,                              	Damage, Intellect
	[113645] = "0000000600043", -- Tectus' Beating Heart,                          	Damage, Strength
	-- Highmaul Heroic (id: 477).
	-- Highmaul Mythic (id: 477).
	-- Highmaul Looking For Raid (id: 477).
	[116289] = "0324002007700", -- Bloodmaw's Tooth,                               	Agility?
	[116290] = "0010771040000", -- Emblem of Gushing Wounds,                       	Damage, Intellect
	[116293] = "0241000100024", -- Idol of Suppression,                            	Tank
	[116291] = "0082004030010", -- Immaculate Living Mushroom,                     	Healer
	[116292] = "0000000600043", -- Mote of the Mountain,                           	Damage, Strength
	-- Blackrock Foundry Normal (id: 457).
	[113986] = "0082004030010", -- Auto-Repairing Autoclave,                       	Healer
	[113987] = "0241000100024", -- Battering Talisman,                             	Tank
	[113931] = "0124002007700", -- Beating Heart of the Mountain,                  	Damage, Agility
	[113984] = "0010771040000", -- Blackiron Micro Crucible,                       	Damage, Intellect
	[113893] = "0241000100024", -- Blast Furnace Door,                             	Tank
	[113948] = "0010771040000", -- Darmac's Unstable Talisman,                     	Damage, Intellect
	[113889] = "0082004030010", -- Elementalist's Shielding Talisman,              	Healer
	[113983] = "0000000600043", -- Forgemaster's Insignia,                         	Damage, Strength
	[119194] = "0010771040000", -- Goren Soul Repository,                          	Damage, Intellect
	[119193] = "0000000600043", -- Horn of Screaming Spirits,                      	Damage, Strength
	[113985] = "0124002007700", -- Humming Blackiron Trigger,                      	Damage, Agility
	[119192] = "0082004030010", -- Ironspike Chew Toy,                             	Healer
	[118114] = "0124002007700", -- Meaty Dragonspine Trophy,                       	Damage, Agility
	[113905] = "0241000100024", -- Tablet of Turnbuckle Teamwork,                  	Tank
	[113969] = "0000000600043", -- Vial of Convulsive Shadows,                     	Damage, Strength
	-- Blackrock Foundry Heroic (id: 457).
	-- Blackrock Foundry Mythic (id: 457).
	-- Blackrock Foundry Looking For Raid (id: 457).
	[116314] = "0324002007700", -- Blackheart Enforcer's Medallion,                	Agility?
	[116316] = "0082004030010", -- Captured Flickerspark,                          	Healer
	[116315] = "0010771040000", -- Furyheart Talisman,                             	Damage, Intellect
	[116318] = "0241000100024", -- Stoneheart Idol,                                	Tank
	[116317] = "0000000600043", -- Storage House Key,                              	Damage, Strength
	-- Hellfire Citadel Normal (id: 669).
	[124241] = "0241000100024", -- Anzu's Cursed Plume,                            	Tank
	[124520] = "0000000007000", -- Bleeding Hollow Toxin Vessel,                   	Rogue
	[124521] = "0000007000000", -- Core of the Primal Elements,                    	Shaman
	[124233] = "0082004030010", -- Demonic Phylactery,                             	Healer
	[124228] = "0010771040000", -- Desecrated Shadowmoon Insignia,                 	Damage, Intellect
	[124237] = "0000000600043", -- Discordant Chorus,                              	Damage, Strength
	[124238] = "0000000600043", -- Empty Drinking Horn,                            	Damage, Strength
	[139630] = "0300000000000", -- Etching of Sargeras,                            	Demon Hunter
	[124223] = "0124002007700", -- Fel-Spring Coil,                                	Damage, Agility
	[124231] = "0082004030010", -- Flickering Felspark,                            	Healer
	[124522] = "0000700000000", -- Fragment of the Dark Star,                      	Warlock
	[124239] = "0241000100024", -- Imbued Stone Sigil,                             	Tank
	[124232] = "0082004030010", -- Intuition's Gift,                               	Healer
	[124227] = "0010771040000", -- Iron Reaver Piston,                             	Damage, Intellect
	[124518] = "0000000000070", -- Libram of Vindication,                          	Paladin
	[124226] = "0124002007700", -- Malicious Censer,                               	Damage, Agility
	[124224] = "0124002007700", -- Mirror of the Blademaster,                      	Damage, Agility
	[124230] = "0010671040000", -- Prophecy of Fear,
	[124513] = "0000000700000", -- Reaper's Harvest,                               	Death Knight
	[124519] = "0000000070000", -- Repudiation of War,                             	Priest
	[124235] = "0000000600043", -- Rumbling Pebble,                                	Damage, Strength
	[124517] = "0007000000000", -- Sacred Draenic Incense,                         	Monk
	[124514] = "00F0000000000", -- Seed of Creation,                               	Druid
	[124225] = "0124002007400", -- Soul Capacitor,                                 	Damage, Melee, Agility
	[124515] = "0000000000700", -- Talisman of the Master Tracker,                 	Hunter
	[124516] = "0000070000000", -- Tome of Shifting Words,                         	Mage
	[124242] = "0241000100024", -- Tyrant's Decree,                                	Tank
	[124229] = "0010771040000", -- Unblinking Gaze of Sethe,                       	Damage, Intellect
	[124236] = "0000000600043", -- Unending Hunger,                                	Damage, Strength
	[124234] = "0082004030010", -- Unstable Felshadow Emulsion,                    	Healer
	[124240] = "0241000100024", -- Warlord's Unseeing Eye,                         	Tank
	[124523] = "0000000000007", -- Worldbreaker's Resolve,                         	Warrior
	-- Hellfire Citadel Heroic (id: 669).
	-- Hellfire Citadel Mythic (id: 669).
	-- Hellfire Citadel Looking For Raid (id: 669).
	[128149] = "0365002707767", -- Accusation of Inferiority,                      	Strength/Agility
	[128141] = "3092775070010", -- Crackling Fel-Spark Plug,                       	Intellect
	[128152] = "3092775070010", -- Decree of Demonic Sovereignty,                  	Intellect
	[128146] = "3092775070010", -- Ensnared Orb of the Sky,                        	Intellect
	[128148] = "0000000700067", -- Fetid Salivation,                               	Strength
	[128143] = "0000000700067", -- Fragmented Runestone Etching,                   	Strength
	[128154] = "0365002707767", -- Grasp of the Defiler,                           	Strength/Agility
	[128145] = "0365002007700", -- Howling Soul Gem,                               	Agility
	[128142] = "3092775070010", -- Pledge of Iron Loyalty,                         	Intellect
	[128151] = "3092775070010", -- Portent of Disaster,                            	Intellect
	[128150] = "0365002007700", -- Pressure-Compressed Loop,                       	Agility
	[128140] = "0365002007700", -- Smoldering Felblade Remnant,                    	Agility
	[128147] = "3092775070010", -- Teardrop of Blood,                              	Intellect
	[128153] = "0000000700067", -- Unquenchable Doomfire Censer,                   	Strength
	[128144] = "0365002707767", -- Vial of Vile Viscera,                           	Strength/Agility
	-- Assault on Violet Hold Normal (id: 777).
	[137459] = "0124002607443", -- Chaos Talisman,                                 	Damage, Melee
	[137446] = "0010771050300", -- Elementium Bomb Squirrel Generator,             	Damage, Ranged
	[137430] = "0241000100024", -- Impenetrable Nerubian Husk,                     	Tank
	[137462] = "0082004030010", -- Jewel of Insatiable Desire,                     	Healer
	[137433] = "0092775070310", -- Obelisk of the Void,
	[137440] = "0241000100024", -- Shivermaw's Jawbone,                            	Tank
	[137452] = "0082004030010", -- Thrumming Gossamer,                             	Healer
	[137439] = "0124002607443", -- Tiny Oozeling in a Jar,                         	Damage, Melee
	-- Assault on Violet Hold Heroic (id: 777).
	-- Assault on Violet Hold Mythic (id: 777).
	-- Black Rook Hold Normal (id: 740).
	[136714] = "0082004030010", -- Amalgam's Seventh Spine,                        	Healer
	[136716] = "0010771050300", -- Caged Horror,                                   	Damage, Ranged
	[136978] = "0241000100024", -- Ember of Nullification,                         	Tank
	[136715] = "0124002607443", -- Spiked Counterweight,                           	Damage, Melee
	-- Black Rook Hold Heroic (id: 740).
	-- Black Rook Hold Mythic (id: 740).
	-- Black Rook Hold Timewalking (id: 740).
	-- Cathedral of Eternal Night Heroic (id: 900).
	[144480] = "3092775070010", -- Dreadstone of Endless Shadows,                  	Intellect
	[144482] = "0000000700067", -- Fel-Oiled Infernal Machine,                     	Strength
	[144477] = "0124002007700", -- Splinters of Agronox,                           	Damage, Agility
	-- Cathedral of Eternal Night Mythic (id: 900).
	-- Court of Stars Heroic (id: 800).
	[137484] = "0082004030010", -- Flask of the Solemn Night,                      	Healer
	[137485] = "0010771050000", -- Infernal Writ,
	[137486] = "0124002607443", -- Windscar Whetstone,                             	Damage, Melee
	-- Court of Stars Mythic (id: 800).
	-- Court of Stars Timewalking (id: 800).
	-- Darkheart Thicket Normal (id: 762).
	[137301] = "0010771050000", -- Corrupted Starlight,
	[137312] = "0124002607443", -- Nightmare Egg Shell,                            	Damage, Melee
	[137306] = "0010771050300", -- Oakheart's Gnarled Root,                        	Damage, Ranged
	[137315] = "0241000100024", -- Writhing Heart of Darkness,                     	Tank
	-- Darkheart Thicket Heroic (id: 762).
	-- Darkheart Thicket Mythic (id: 762).
	-- Darkheart Thicket Timewalking (id: 762).
	-- Eye of Azshara Normal (id: 716).
	[137378] = "0082004030010", -- Bottled Hurricane,                              	Healer
	[137369] = "0124002607443", -- Giant Ornamental Pearl,                         	Damage, Melee
	[137362] = "0241000100024", -- Parjesh's Medallion,                            	Tank
	[137367] = "0010771050300", -- Stormsinger Fulmination Charge,                 	Damage, Ranged
	[137373] = "0124002007700", -- Tempered Egg of Serpentrix,                     	Damage, Agility
	-- Eye of Azshara Heroic (id: 716).
	-- Eye of Azshara Mythic (id: 716).
	-- Eye of Azshara Timewalking (id: 716).
	-- Halls of Valor Normal (id: 721).
	[133641] = "0010771050300", -- Eye of Skovald,                                 	Damage, Ranged
	[133647] = "0241000100024", -- Gift of Radiance,                               	Tank
	[133642] = "33F7777777777", -- Horn of Valor,                                  	All Classes
	[136975] = "0124002607443", -- Hunger of the Pack,                             	Damage, Melee
	[133646] = "0082004030010", -- Mote of Sanctification,                         	Healer
	-- Halls of Valor Heroic (id: 721).
	-- Halls of Valor Mythic (id: 721).
	-- Maw of Souls Normal (id: 727).
	[137329] = "0010771050300", -- Figurehead of the Naglfar,                      	Damage, Ranged
	[133644] = "0124002607443", -- Memento of Angerboda,                           	Damage, Melee
	[133645] = "0082004030010", -- Naglfar Fare,                                   	Healer
	-- Maw of Souls Heroic (id: 727).
	-- Maw of Souls Mythic (id: 727).
	-- Neltharion's Lair Normal (id: 767).
	[137357] = "0124002607443", -- Mark of Dargrul,                                	Damage, Melee
	[137349] = "0010771050300", -- Naraxas' Spiked Tongue,                         	Damage, Ranged
	[137338] = "0241000100024", -- Shard of Rokmora,                               	Tank
	[137344] = "0241000100024", -- Talisman of the Cragshaper,                     	Tank
	-- Neltharion's Lair Heroic (id: 767).
	-- Neltharion's Lair Mythic (id: 767).
	-- Neltharion's Lair Timewalking (id: 767).
	-- Return to Karazhan Heroic (id: 860).
	[142157] = "0010771050300", -- Aran's Relaxing Ruby,                           	Damage, Ranged
	[142159] = "0124002607443", -- Bloodstained Handkerchief,                      	Damage, Melee
	[142165] = "0010771050300", -- Deteriorated Construct Core,                    	Damage, Ranged
	[142167] = "0124002607443", -- Eye of Command,                                 	Damage, Melee
	[142158] = "0082004030010", -- Faith's Crucible,                               	Healer
	[142162] = "0082004030010", -- Fluctuating Energy,                             	Healer
	[142161] = "0241000100024", -- Inescapable Dread,                              	Tank
	[142168] = "0241000100024", -- Majordomo's Dinner Bell,                        	Tank
	[142160] = "0010771050300", -- Mrrgria's Favor,                                	Damage, Ranged
	[142169] = "0241000100024", -- Raven Eidolon,                                  	Tank
	[142164] = "0124002607443", -- Toe Knee's Promise,                             	Damage, Melee
	-- Return to Karazhan Mythic (id: 860).
	-- Seat of the Triumvirate Heroic (id: 945).
	[151312] = "0241000100024", -- Ampoule of Pure Void,                           	Tank
	[151340] = "0082004030010", -- Echo of L'ura,                                  	Healer
	[151310] = "0010771050000", -- Reality Breacher,
	[151307] = "0124002607743", -- Void Stalker's Contract,                        	Damage, Strength/Agility
	-- Seat of the Triumvirate Mythic (id: 945).
	-- The Arcway Heroic (id: 726).
	[137419] = "33F7777777777", -- Chrono Shard,                                   	All Classes
	[137400] = "0241000100024", -- Coagulated Nightwell Residue,                   	Tank
	[133766] = "0082004030010", -- Nether Anti-Toxin,                              	Healer
	[137398] = "0010771050000", -- Portable Manacracker,
	[137406] = "0124002607443", -- Terrorbound Nexus,                              	Damage, Melee
	-- The Arcway Mythic (id: 726).
	-- Vault of the Wardens Normal (id: 707).
	[137540] = "0082004030010", -- Concave Reflecting Lens,                        	Healer
	[137539] = "0124002607443", -- Faulty Countermeasure,                          	Damage, Melee
	[137541] = "0010771050300", -- Moonlit Prism,                                  	Damage, Ranged
	[137538] = "0241000100024", -- Orb of Torment,                                 	Tank
	[137537] = "0124002007700", -- Tirathon's Betrayal,                            	Damage, Agility
	-- Vault of the Wardens Heroic (id: 707).
	-- Vault of the Wardens Mythic (id: 707).
	-- Vault of the Wardens Timewalking (id: 707).
	-- Broken Isles Normal (id: 822).
	[141535] = "0000000700067", -- Ettin Fingernail,                               	Strength
	[141536] = "3092775070010", -- Padawsen's Unlucky Charm,                       	Intellect
	[141537] = "0365002007700", -- Thrice-Accursed Compass,                        	Agility
	[141482] = "33F7777777777", -- Unstable Arcanocrystal,                         	All Classes
	-- Broken Isles Heroic (id: 822).
	-- Broken Isles Mythic (id: 822).
	-- Broken Isles Looking For Raid (id: 822).
	-- The Emerald Nightmare Normal (id: 768).
	[139329] = "0124002007700", -- Bloodthirsty Instinct,                          	Damage, Agility
	[139336] = "0010771050000", -- Bough of Corruption,
	[139322] = "0082004030010", -- Cocoon of Enforced Solitude,                    	Healer
	[139324] = "0241000100024", -- Goblet of Nightmarish Ichor,                    	Tank
	[139335] = "0241000100024", -- Grotesque Statuette,                            	Tank
	[139330] = "0082004030010", -- Heightened Senses,                              	Healer
	[139333] = "0082004030010", -- Horn of Cenarius,                               	Healer
	[139334] = "0124002607443", -- Nature's Call,                                  	Damage, Melee
	[138225] = "0241000100024", -- Phantasmal Echo,                                	Tank
	[139320] = "0124002607443", -- Ravaged Seed Pod,                               	Damage, Melee
	[139325] = "0124002607443", -- Spontaneous Appendages,                         	Damage, Melee
	[139321] = "0010773050000", -- Swarming Plaguehive,
	[139323] = "0010771050300", -- Twisting Wind,                                  	Damage, Ranged
	[139327] = "0241000100024", -- Unbridled Fury,                                 	Tank
	[138224] = "0010771050300", -- Unstable Horrorslime,                           	Damage, Ranged
	[139328] = "0000000600043", -- Ursoc's Rending Paw,                            	Damage, Strength
	[138222] = "0082004030010", -- Vial of Nightmare Fog,                          	Healer
	[139326] = "0010771050000", -- Wriggling Sinew,
	-- The Emerald Nightmare Heroic (id: 768).
	-- The Emerald Nightmare Mythic (id: 768).
	-- The Emerald Nightmare Looking For Raid (id: 768).
	-- Trial of Valor Normal (id: 861).
	[142507] = "3092775070010", -- Brinewater Slime in a Bottle,                   	Intellect
	[142508] = "0000000700067", -- Chains of the Valorous,                         	Strength
	[142506] = "0365002007700", -- Eye of Guarm,                                   	Agility
	-- Trial of Valor Heroic (id: 861).
	-- Trial of Valor Mythic (id: 861).
	-- Trial of Valor Looking For Raid (id: 861).
	-- The Nighthold Normal (id: 786).
	[140795] = "0082004030010", -- Aluriel's Mirror,                               	Healer
	[140789] = "0241000100024", -- Animated Exoskeleton,                           	Tank
	[140794] = "0124002007400", -- Arcanogolem Digit,                              	Damage, Melee, Agility
	[140790] = "0000000600043", -- Claw of the Crystalline Scorpid,                	Damage, Strength
	[140806] = "0124002607743", -- Convergence of Fates,                           	Damage, Strength/Agility
	[140808] = "0124002607443", -- Draught of Souls,                               	Damage, Melee
	[140796] = "0124002607743", -- Entwined Elemental Foci,                        	Damage, Strength/Agility
	[140805] = "0082004030010", -- Ephemeral Paradox,                              	Healer
	[140792] = "0010771050000", -- Erratic Metronome,
	[140803] = "0082004030010", -- Etraeus' Celestial Map,                         	Healer
	[140797] = "0241000100024", -- Fang of Tichondrius,                            	Tank
	[140801] = "0010771050300", -- Fury of the Burning Sky,                        	Damage, Ranged
	[140798] = "0010771050300", -- Icon of Rot,                                    	Damage, Ranged
	[140807] = "0241000100024", -- Infernal Contract,                              	Tank
	[140799] = "0000000600043", -- Might of Krosus,                                	Damage, Strength
	[140802] = "0124002007700", -- Nightblooming Frond,                            	Damage, Agility
	[140793] = "0082004030010", -- Perfectly Preserved Cake,                       	Healer
	[140800] = "0010771050000", -- Pharamere's Forbidden Grimoire,
	[140791] = "0241000100024", -- Royal Dagger Haft,                              	Tank
	[140804] = "0010771050000", -- Star Gate,
	[140809] = "0010771050000", -- Whispers in the Dark,
	-- The Nighthold Heroic (id: 786).
	-- The Nighthold Mythic (id: 786).
	-- The Nighthold Looking For Raid (id: 786).
	-- Tomb of Sargeras Normal (id: 875).
	[147006] = "0082004030010", -- Archive of Faith,                               	Healer
	[147003] = "0082004030010", -- Barbaric Mindslaver,                            	Healer
	[147005] = "0082004030010", -- Chalice of Moonlight,                           	Healer
	[147002] = "3092775070010", -- Charm of the Rising Tide,                       	Intellect
	[147010] = "0124002607743", -- Cradle of Anguish,                              	Damage, Strength/Agility
	[147015] = "0124002607743", -- Engine of Eradication,                          	Damage, Strength/Agility
	[147022] = "0241000100024", -- Feverish Carapace,                              	Tank
	[147009] = "0124002607443", -- Infernal Cinders,                               	Damage, Melee
	[147023] = "0241000100024", -- Leviathan's Hunger,                             	Tank
	[147025] = "0241000100024", -- Recompiled Guardian Module,                     	Tank
	[147024] = "0241000100024", -- Reliquary of the Damned,                        	Tank
	[147004] = "0082004030010", -- Sea Star of the Depthmother,                    	Healer
	[147026] = "0241000100024", -- Shifting Cosmic Sliver,                         	Tank
	[151190] = "0124002607443", -- Specter of Betrayal,                            	Damage, Melee
	[147018] = "0010771050300", -- Spectral Thurible,                              	Damage, Ranged
	[147017] = "0010771050300", -- Tarnished Sentinel Medallion,                   	Damage, Ranged
	[147016] = "0010771050300", -- Terror From Below,                              	Damage, Ranged
	[147007] = "0082004030010", -- The Deceiver's Grand Design,                    	Healer
	[147019] = "0010771050300", -- Tome of Unraveling Sanity,                      	Damage, Ranged
	[147012] = "0124002607443", -- Umbral Moonglaives,                             	Damage, Melee
	[147011] = "0124002607443", -- Vial of Ceaseless Toxins,                       	Damage, Melee
	-- Tomb of Sargeras Heroic (id: 875).
	-- Tomb of Sargeras Mythic (id: 875).
	-- Tomb of Sargeras Looking For Raid (id: 875).
	-- Antorus, the Burning Throne Normal (id: 946).
	[151955] = "0010771050000", -- Acrid Catalyst Injector,
	[154173] = "0241000100024", -- Aggramar's Conviction,                          	Tank
	[154172] = "33F7777777777", -- Aman'Thul's Vision,                             	All Classes
	[151975] = "0241000100024", -- Apocalypse Drive,                               	Tank
	[151960] = "0082004030010", -- Carafe of Searing Light,                        	Healer
	[151977] = "0241000100024", -- Diima's Glacial Aegis,                          	Tank
	[154175] = "0082004030010", -- Eonar's Compassion,                             	Healer
	[153544] = "0241000100024", -- Eye of F'harg,                                  	Tank
	[152645] = "0241000100024", -- Eye of Shatug,                                  	Tank
	[151963] = "0124002607743", -- Forgefiend's Fabricator,                        	Damage, Strength/Agility
	[151956] = "0082004030010", -- Garothi Feedback Conduit,                       	Healer
	[154174] = "0124002007700", -- Golganneth's Vitality,                          	Damage, Agility
	[152093] = "0124002607443", -- Gorshalach's Legacy,                            	Damage, Melee
	[152289] = "0082004030010", -- Highfather's Machination,                       	Healer
	[151957] = "0082004030010", -- Ishkar's Felshield Emitter,                     	Healer
	[154176] = "0000000600043", -- Khaz'goroth's Courage,                          	Damage, Strength
	[154177] = "0010771050000", -- Norgannon's Prowess,
	[151962] = "0010771050300", -- Prototype Personnel Decimator,                  	Damage, Ranged
	[151976] = "0241000100024", -- Riftworld Codex,                                	Tank
	[151964] = "0124002607443", -- Seeping Scourgewing,                            	Damage, Melee
	[151968] = "0124002607743", -- Shadow-Singed Fang,                             	Damage, Strength/Agility
	[151971] = "0010771050000", -- Sheath of Asara,
	[151978] = "0241000100024", -- Smoldering Titanguard,                          	Tank
	[151958] = "0082004030010", -- Tarratus Keystone,                              	Healer
	[151969] = "0010771050300", -- Terminus Signaling Beacon,                      	Damage, Ranged
	[151970] = "0092775070010", -- Vitality Resonator,                             	Intellect
	-- Antorus, the Burning Throne Heroic (id: 946).
	-- Antorus, the Burning Throne Mythic (id: 946).
	-- Antorus, the Burning Throne Looking For Raid (id: 946).
	-- Invasion Points Normal (id: 959).
	-- Invasion Points Heroic (id: 959).
	-- Invasion Points Mythic (id: 959).
	-- Invasion Points Looking For Raid (id: 959).
	-- Atal'Dazar Normal (id: 968).
	[158319] = "0365002007700", -- My'das Talisman,                                	Agility
	[158320] = "0082004030010", -- Revitalizing Voodoo Totem,                      	Healer
	[158712] = "0000000700067", -- Rezan's Gleaming Eye,                           	Strength
	[159610] = "0010771040000", -- Vessel of Skittering Shadows,                   	Damage, Intellect
	-- Atal'Dazar Heroic (id: 968).
	-- Atal'Dazar Mythic (id: 968).
	-- Freehold Normal (id: 1001).
	[155881] = "0365002007700", -- Harlan's Loaded Dice,                           	Agility
	-- Freehold Heroic (id: 1001).
	-- Freehold Mythic (id: 1001).
	-- Kings' Rest Heroic (id: 1041).
	[159617] = "0365002007700", -- Lustrous Golden Plumage,                        	Agility
	[159618] = "0241000100024", -- Mchimba's Ritual Bandages,                      	Tank
	-- Kings' Rest Mythic (id: 1041).
	-- Operation: Mechagon Heroic (id: 1178).
	[169344] = "0082014030010", -- Ingenious Mana Battery,
	[168965] = "0241000100024", -- Modular Platinum Plating,                       	Tank
	[169769] = "0124002607743", -- Remote Guidance Device,                         	Damage, Strength/Agility
	-- Operation: Mechagon Mythic (id: 1178).
	-- Shrine of the Storm Normal (id: 1036).
	[159619] = "0000000700067", -- Briny Barnacle,                                 	Strength
	[159620] = "0092775070010", -- Conch of Dark Whispers,                         	Intellect
	[159614] = "0365002007700", -- Galecaller's Boon,                              	Agility
	-- Shrine of the Storm Heroic (id: 1036).
	-- Shrine of the Storm Mythic (id: 1036).
	-- Siege of Boralus Heroic (id: 1023).
	[159623] = "0365002007700", -- Dead-Eye Spyglass,                              	Agility
	[159622] = "0010771040000", -- Hadal's Nautilus,                               	Damage, Intellect
	-- Siege of Boralus Mythic (id: 1023).
	-- Temple of Sethraliss Normal (id: 1030).
	[158368] = "0082004030010", -- Fangs of Intertwined Essence,                   	Healer
	[158367] = "0000000700067", -- Merektha's Fang,                                	Strength
	[158374] = "0365002007700", -- Tiny Electromental in a Jar,                    	Agility
	-- Temple of Sethraliss Heroic (id: 1030).
	-- Temple of Sethraliss Mythic (id: 1030).
	-- The MOTHERLODE!! Normal (id: 1012).
	[159612] = "0365002007700", -- Azerokk's Resonating Heart,                     	Agility
	[159611] = "0000000700067", -- Razdunk's Big Red Button,                       	Strength
	-- The MOTHERLODE!! Heroic (id: 1012).
	-- The MOTHERLODE!! Mythic (id: 1012).
	-- The Underrot Normal (id: 1022).
	[159626] = "0241000100024", -- Lingering Sporepods,                            	Tank
	[159624] = "0010771040000", -- Rotcrusted Voodoo Doll,                         	Damage, Intellect
	[159625] = "0000000700067", -- Vial of Animated Blood,                         	Strength
	-- The Underrot Heroic (id: 1022).
	-- The Underrot Mythic (id: 1022).
	-- Tol Dagor Normal (id: 1002).
	[159615] = "0092775070010", -- Ignition Mage's Fuse,                           	Intellect
	[159627] = "0000000700067", -- Jes' Howler,                                    	Strength
	[159628] = "0365002007700", -- Kul Tiran Cannonball Runner,                    	Agility
	-- Tol Dagor Heroic (id: 1002).
	-- Tol Dagor Mythic (id: 1002).
	-- Waycrest Manor Normal (id: 1021).
	[159630] = "0092775070010", -- Balefire Branch,                                	Intellect
	[159616] = "0000000700067", -- Gore-Crusted Butcher's Block,                   	Strength
	[159631] = "0092775070010", -- Lady Waycrest's Music Box,                      	Intellect
	-- Waycrest Manor Heroic (id: 1021).
	-- Waycrest Manor Mythic (id: 1021).
	-- Azeroth Normal (id: 1028).
	[166793] = "0092775070010", -- Ancient Knot of Wisdom,                         	Intellect
	[161377] = "0092775070010", -- Azurethos' Singed Plumage,                      	Intellect
	[161463] = "0000000700067", -- Doom's Fury,                                    	Strength
	[161461] = "0092775070010", -- Doom's Hatred,                                  	Intellect
	[161462] = "0365002007700", -- Doom's Wake,                                    	Agility
	[161380] = "0092775070010", -- Drust-Runed Icicle,                             	Intellect
	[169317] = "03F7777777777", -- Enthraller's Bindstone,                         	All Classes
	[166794] = "0365002007700", -- Forest Lord's Razorleaf,                        	Agility
	[161379] = "0000000700067", -- Galecaller's Beak,                              	Strength
	[166795] = "0000000700067", -- Knot of Ancient Fury,                           	Strength
	[161419] = "0000000700067", -- Kraulok's Claw,                                 	Strength
	[161381] = "0365002007700", -- Permafrost-Encrusted Heart,                     	Agility
	[161378] = "0365002007700", -- Plume of the Seaborne Avian,                    	Agility
	[161376] = "0000000700067", -- Prism of Dark Intensity,                        	Strength
	[169318] = "03F7777777777", -- Shockbiter's Fang,                              	All Classes
	[161412] = "0365002007700", -- Spiritbound Voodoo Burl,                        	Agility
	[161411] = "0092775070010", -- T'zane's Barkspines,                            	Intellect
	-- Azeroth Heroic (id: 1028).
	-- Azeroth Mythic (id: 1028).
	-- Azeroth Looking For Raid (id: 1028).
	-- Uldir Normal (id: 1031).
	[160652] = "0365002007700", -- Construct Overcharger,                          	Agility
	[160650] = "0000000700067", -- Disc of Systematic Regression,                  	Strength
	[160648] = "0365002007700", -- Frenetic Corpuscle,                             	Agility
	[160649] = "0082004030010", -- Inoculating Extract,                            	Healer
	[160655] = "0000000700067", -- Syringe of Bloodborne Infirmity,                	Strength
	[160656] = "0092775070010", -- Twitching Tentacle of Xalzaix,                  	Intellect
	[160654] = "0375773747767", -- Vanquished Tendril of G'huun,
	[160651] = "0010771040000", -- Vigilant's Bloodshaper,                         	Damage, Intellect
	[160653] = "0241000100024", -- Xalzaix's Veiled Eye,                           	Tank
	-- Uldir Heroic (id: 1031).
	-- Uldir Mythic (id: 1031).
	-- Uldir Looking For Raid (id: 1031).
	-- Battle of Dazar'alor Normal (id: 1176).
	[165577] = "0241000100024", -- Bwonsamdi's Bargain,                            	Tank
	[165581] = "3092775070010", -- Crest of Pa'ku,                                 	Intellect
	[165573] = "0241000100024", -- Diamond-Laced Refracting Prism,                 	Tank
	[165570] = "0000000600043", -- Everchill Anchor,                               	Damage, Strength
	[165574] = "0000000600043", -- Grong's Primal Rage,                            	Damage, Strength
	[165571] = "3092775070010", -- Incandescent Sliver,                            	Intellect
	[165568] = "0124002007700", -- Invocation of Yu'lon,                           	Damage, Agility
	[165579] = "0124002007700", -- Kimbul's Razor Claw,                            	Damage, Agility
	[165578] = "0082004030010", -- Mirror of Entwined Fate,                        	Healer
	[165580] = "0000000700067", -- Ramping Amplitude Gigavolt Engine,              	Strength
	[165576] = "0010771040000", -- Tidestorm Codex,                                	Damage, Intellect
	[165572] = "0365002007700", -- Variable Intensity Gigavolt Oscillating Reactor,	Agility
	[165569] = "0082004030010", -- Ward of Envelopment,                            	Healer
	-- Battle of Dazar'alor Heroic (id: 1176).
	-- Battle of Dazar'alor Mythic (id: 1176).
	-- Battle of Dazar'alor Looking For Raid (id: 1176).
	-- Crucible of Storms Normal (id: 1177).
	[167867] = "0010771040000", -- Harbinger's Inscrutable Will,                   	Damage, Intellect
	[167868] = "0365002707767", -- Idol of Indiscriminate Consumption,             	Strength/Agility
	[167866] = "0124002607743", -- Lurker's Insidious Gift,                        	Damage, Strength/Agility
	[167865] = "0082004030010", -- Void Stone,                                     	Healer
	-- Crucible of Storms Heroic (id: 1177).
	-- Crucible of Storms Mythic (id: 1177).
	-- Crucible of Storms Looking For Raid (id: 1177).
	-- The Eternal Palace Normal (id: 1179).
	[169305] = "0010771040000", -- Aquipotent Nautilus,                            	Damage, Intellect
	[169311] = "0124002607743", -- Ashvane's Razor Coral,                          	Damage, Strength/Agility
	[169314] = "33F7777777777", -- Azshara's Font of Power,                        	All Classes
	[169310] = "0241000100024", -- Bloodthirsty Urchin,                            	Tank
	[169308] = "0241000100024", -- Chain of Suffering,                             	Tank
	[169316] = "0082004030010", -- Deferred Sentence,                              	Healer
	[169319] = "0124002607743", -- Dribbling Inkpod,                               	Damage, Strength/Agility
	[169315] = "0241000100024", -- Edicts of the Faithless,                        	Tank
	[169304] = "0010771040000", -- Leviathan's Lure,                               	Damage, Intellect
	[169312] = "0082004030010", -- Luminous Jellyweed,                             	Healer
	[169313] = "0124002607443", -- Phial of the Arcane Tempest,                    	Damage, Melee
	[168905] = "0010771040000", -- Shiver Venom Relic,                             	Damage, Intellect
	[169307] = "0124002607743", -- Vision of Demise,                               	Damage, Strength/Agility
	[169306] = "0092775070010", -- Za'qul's Portal Key,                            	Intellect
	[169309] = "0082004030010", -- Zoatroid Egg Sac,                               	Healer
	-- The Eternal Palace Heroic (id: 1179).
	-- The Eternal Palace Mythic (id: 1179).
	-- The Eternal Palace Looking For Raid (id: 1179).
	-- Ny'alotha, the Waking City Normal (id: 1180).
	[173944] = "0092775070010", -- Forbidden Obsidian Claw,                        	Intellect
	[174044] = "03F7777777777", -- Humming Black Dragonscale,                      	All Classes
	[174277] = "0241000100024", -- Lingering Psychic Shell,                        	Tank
	[174103] = "0092775070010", -- Manifesto of Madness,                           	Intellect
	[174180] = "0082004030010", -- Oozing Coagulum,                                	Healer
	[174060] = "0010771040000", -- Psyche Shredder,                                	Damage, Intellect
	[173940] = "0241000100024", -- Sigil of Warding,                               	Tank
	[173943] = "0124002607743", -- Torment in a Jar,                               	Damage, Strength/Agility
	[174500] = "03F7777777777", -- Vita-Charged Titanshard,                        	All Classes
	[174528] = "03F7777777777", -- Void-Twisted Titanshard,                        	All Classes
	[173946] = "0124002607743", -- Writhing Segment of Drest'agath,                	Damage, Strength/Agility
	-- Ny'alotha, the Waking City Heroic (id: 1180).
	-- Ny'alotha, the Waking City Mythic (id: 1180).
	-- Ny'alotha, the Waking City Looking For Raid (id: 1180).
	-- De Other Side Normal (id: 1188).
	[179331] = "0241000100024", -- Blood-Spattered Scale,                          	Tank
	[179350] = "33F7777777777", -- Inscrutable Quantum Device,                     	All Classes
	[179342] = "0000000700067", -- Overwhelming Power Crystal,                     	Strength
	[179356] = "0365002007700", -- Shadowgrasp Totem,                              	Agility
	-- De Other Side Heroic (id: 1188).
	-- De Other Side Mythic (id: 1188).
	-- Halls of Atonement Normal (id: 1185).
	[178825] = "0241000100024", -- Pulsating Stoneheart,                           	Tank
	[178826] = "3092775070010", -- Sunblood Amethyst,                              	Intellect
	-- Halls of Atonement Heroic (id: 1185).
	-- Halls of Atonement Mythic (id: 1185).
	-- Mists of Tirna Scithe Normal (id: 1184).
	[178715] = "0365002007700", -- Mistcaller Ocarina,                             	Agility
	[178708] = "3092775070010", -- Unbound Changeling,                             	Intellect
	-- Mists of Tirna Scithe Heroic (id: 1184).
	-- Mists of Tirna Scithe Mythic (id: 1184).
	-- Plaguefall Normal (id: 1183).
	[178769] = "1375773047700", -- Infinitely Divisible Ooze,                      	Damage, Agility/Intellect
	[178771] = "0124002607443", -- Phial of Putrefaction,                          	Damage, Melee
	[178770] = "0241000100024", -- Slimy Consumptive Organ,                        	Tank
	-- Plaguefall Heroic (id: 1183).
	-- Plaguefall Mythic (id: 1183).
	-- Sanguine Depths Normal (id: 1189).
	[178862] = "0241000100024", -- Bladedancer's Armor Kit,                        	Tank
	[178861] = "0365002707467", -- Decanter of Anima-Charged Winds,                	Melee
	[178850] = "2082004030010", -- Lingering Sunmote,                              	Healer
	[178849] = "3092775070010", -- Overflowing Anima Cage,                         	Intellect
	-- Sanguine Depths Heroic (id: 1189).
	-- Sanguine Depths Mythic (id: 1189).
	-- Spires of Ascension Normal (id: 1186).
	[180118] = "0000000700067", -- Anima Field Emitter,                            	Strength
	[180119] = "2082004030010", -- Boon of the Archon,                             	Healer
	[180117] = "1010771040000", -- Empyreal Ordnance,                              	Damage, Intellect
	[180116] = "0365002007700", -- Overcharged Anima Battery,                      	Agility
	-- Spires of Ascension Heroic (id: 1186).
	-- Spires of Ascension Mythic (id: 1186).
	-- Tazavesh, the Veiled Market Heroic (id: 1194).
	[185836] = "0241000100024", -- Codex of the First Technique,                   	Tank
	[185845] = "2082004030010", -- First Class Healing Distributor,                	Healer
	[185846] = "0010771040300", -- Miniscule Mailemental in an Envelope,           	Damage, Ranged
	[190958] = "33F7777777777", -- So'leah's Secret Technique,                     	All Classes
	[190652] = "0124002607443", -- Ticking Sack of Terror,                         	Damage, Melee
	-- Tazavesh, the Veiled Market Mythic (id: 1194).
	-- The Necrotic Wake Normal (id: 1182).
	[178742] = "0365002007700", -- Bottled Flayedwing Toxin,                       	Agility
	[178772] = "1010771040000", -- Satchel of Misbegotten Minions,                 	Damage, Intellect
	[178783] = "2082004030010", -- Siphoning Phylactery Shard,                     	Healer
	[178751] = "0000000700067", -- Spare Meat Hook,                                	Strength
	-- The Necrotic Wake Heroic (id: 1182).
	-- The Necrotic Wake Mythic (id: 1182).
	-- Theater of Pain Normal (id: 1187).
	[178811] = "0124002607443", -- Grim Codex,                                     	Damage, Melee
	[178809] = "3092775070010", -- Soulletting Ruby,                               	Intellect
	[178810] = "2082004030010", -- Vial of Spectral Essence,                       	Healer
	[178808] = "0000000700067", -- Viscera of Coalesced Hatred,                    	Strength
	-- Theater of Pain Heroic (id: 1187).
	-- Theater of Pain Mythic (id: 1187).
	-- Shadowlands Normal (id: 1192).
	[187447] = "33F7777777777", -- Soul Cage Fragment,                             	All Classes
	-- Shadowlands Heroic (id: 1192).
	-- Shadowlands Mythic (id: 1192).
	-- Shadowlands Looking For Raid (id: 1192).
	-- Castle Nathria Normal (id: 1190).
	[184017] = "0241000100024", -- Bargast's Leash,                                	Tank
	[184028] = "0092775070010", -- Cabalist's Hymnal,                              	Intellect
	[184022] = "2082004030010", -- Consumptive Infusion,                           	Healer
	[184030] = "1134773647743", -- Dreadfire Vessel,                               	Damage
	[184023] = "0000000700067", -- Gluttonous Spike,                               	Strength
	[184021] = "1010771040000", -- Glyph of Assimilation,                          	Damage, Intellect
	[184026] = "0365002007700", -- Hateful Chain,                                  	Agility
	[184024] = "33F7777777777", -- Macabre Sheet Music,                            	All Classes
	[184029] = "2082004030010", -- Manabound Mirror,                               	Healer
	[184025] = "0124002607743", -- Memory of Past Sins,                            	Damage, Strength/Agility
	[184031] = "0241000100024", -- Sanguine Vintage,                               	Tank
	[184016] = "0124002607443", -- Skulker's Wing,                                 	Damage, Melee
	[184019] = "1010771040000", -- Soul Igniter,                                   	Damage, Intellect
	[184018] = "0241000100024", -- Splintered Heart of Al'ar,                      	Tank
	[184027] = "0365002707767", -- Stone Legion Heraldry,                          	Strength/Agility
	[184020] = "2082004030010", -- Tuft of Smoldering Plumage,                     	Healer
	-- Castle Nathria Heroic (id: 1190).
	-- Castle Nathria Mythic (id: 1190).
	-- Castle Nathria Looking For Raid (id: 1190).
	-- Sanctum of Domination Normal (id: 1193).
	[186435] = "0082004030010", -- Carved Ivory Keepsake,                          	Healer
	[186429] = "0365002707767", -- Decanter of Endless Howling,                    	Strength/Agility
	[186431] = "0010771040000", -- Ebonsoul Vise,                                  	Damage, Intellect
	[186421] = "0010771040000", -- Forbidden Necromantic Tome,                     	Damage, Intellect
	[186438] = "0000000700067", -- Old Warrior's Soul,                             	Strength
	[186433] = "0241000100024", -- Reactive Defense Matrix,                        	Tank
	[186437] = "0124002007700", -- Relic of the Frozen Wastes,                     	Damage, Agility
	[186436] = "0082004030010", -- Resonant Silver Bell,                           	Healer
	[186432] = "0124002607743", -- Salvaged Fusion Amplifier,                      	Damage, Strength/Agility
	[186425] = "0082004030010", -- Scrawled Word of Recall,                        	Healer
	[186428] = "0092775070010", -- Shadowed Orb of Torment,                        	Intellect
	[186424] = "0241000100024", -- Shard of Annhylde's Aegis,                      	Tank
	[186423] = "03F7777777777", -- Titanic Ocular Gland,                           	All Classes
	[186422] = "0010771040000", -- Tome of Monstrous Constructions,                	Damage, Intellect
	[186430] = "0124002607743", -- Tormented Rack Fragment,                        	Damage, Strength/Agility
	[186434] = "0241000100024", -- Weave of Warped Fates,                          	Tank
	[186427] = "0000000600043", -- Whispering Shard of Power,                      	Damage, Strength
	-- Sanctum of Domination Heroic (id: 1193).
	-- Sanctum of Domination Mythic (id: 1193).
	-- Sanctum of Domination Looking For Raid (id: 1193).
	-- Sepulcher of the First Ones Normal (id: 1195).
	[188268] = "0010771040000", -- Architect's Ingenuity Core,                     	Damage, Intellect
	[188273] = "0082004030010", -- Auxiliary Attendant Chime,                      	Healer
	[188267] = "0365002707767", -- Bells of the Endless Feast,                     	Strength/Agility
	[188265] = "0124002007700", -- Cache of Acquired Treasures,                    	Damage, Agility
	[188252] = "0124002607447", -- Chains of Domination,                           	Melee
	[188264] = "0365002707467", -- Earthbreaker's Impact,                          	Melee
	[188270] = "33F7777777777", -- Elegy of the Eternals,                          	All Classes
	[188254] = "3092775070010", -- Grim Eclipse,                                   	Intellect
	[188255] = "0000000700067", -- Heart of the Swarm,                             	Strength
	[188261] = "0241000100024", -- Intrusive Thoughtcage,                          	Tank
	[188269] = "0241000100024", -- Pocket Protoforge,                              	Tank
	[188266] = "0241000100024", -- Pulsating Riftshard,                            	Tank
	[188263] = "0082004030010", -- Reclaimer's Intensity Core,                     	Healer
	[188272] = "0010771040000", -- Resonant Reservoir,                             	Damage, Intellect
	[188253] = "33F7777777777", -- Scars of Fraternal Strife,                      	All Classes
	[188271] = "33F7777777777", -- The First Sigil,                                	All Classes
	[188262] = "0082004030010", -- The Lion's Roar,                                	Healer
	-- Sepulcher of the First Ones Heroic (id: 1195).
	-- Sepulcher of the First Ones Mythic (id: 1195).
	-- Sepulcher of the First Ones Looking For Raid (id: 1195).

	-- Dragonflight
	-- Algeth'ar Academy Normal (id: 1201).
	[193701] = "0365002707767", -- Algeth'ar Puzzle Box,           	Strength/Agility
	[193719] = "0000000700067", -- Dragon Games Equipment,         	Strength
	[193718] = "6082004030010", -- Emerald Coach's Whistle,        	Healer
	-- Algeth'ar Academy Heroic (id: 1201).
	-- Algeth'ar Academy Mythic (id: 1201).
	-- Brackenhide Hollow Normal (id: 1196).
	[193672] = "0124002607443", -- Frenzying Signoll Flare,        	Damage, Melee
	[193660] = "5010771050300", -- Idol of Pure Decay,             	Damage, Ranged
	[193652] = "0241000100024", -- Treemouth's Festering Splinter, 	Tank
	-- Brackenhide Hollow Heroic (id: 1196).
	-- Brackenhide Hollow Mythic Keystone (id: 1196).
	-- Brackenhide Hollow Mythic (id: 1196).
	-- Halls of Infusion Normal (id: 1204).
	[193732] = "0124002007700", -- Globe of Jagged Ice,            	Damage, Agility
	[193743] = "73F7777777777", -- Irideus Fragment,               	All Classes
	[193736] = "2082004030010", -- Water's Beating Heart,          	Healer
	-- Halls of Infusion Heroic (id: 1204).
	-- Halls of Infusion Mythic Keystone (id: 1204).
	-- Halls of Infusion Mythic (id: 1204).
	-- Neltharus Normal (id: 1199).
	[193769] = "5010771050300", -- Erupting Spear Fragment,        	Damage, Ranged
	[193786] = "0124002607443", -- Mutated Magmammoth Scale,       	Damage, Melee
	[193773] = "7092775070010", -- Spoils of Neltharus,            	Intellect
	-- Neltharus Heroic (id: 1199).
	-- Neltharus Mythic Keystone (id: 1199).
	-- Neltharus Mythic (id: 1199).
	-- Ruby Life Pools Normal (id: 1202).
	[193762] = "0000000700067", -- Blazebinder's Hoof,             	Strength
	[193748] = "2082004030010", -- Kyrakka's Searing Embers,       	Healer
	[193757] = "73F7777777777", -- Ruby Whelp Shell,               	All Classes
	-- Ruby Life Pools Heroic (id: 1202).
	-- Ruby Life Pools Mythic (id: 1202).
	-- The Azure Vault Normal (id: 1203).
	[193634] = "0241000100024", -- Burgeoning Seed,                	Tank
	[193628] = "7092775070010", -- Tome of Unstable Power,         	Intellect
	[193639] = "5010771040000", -- Umbrelskul's Fractured Heart,   	Damage, Intellect
	-- The Azure Vault Heroic (id: 1203).
	-- The Azure Vault Mythic (id: 1203).
	-- The Nokhud Offensive Normal (id: 1198).
	[193697] = "0325002007700", -- Bottle of Spiraling Winds,      	Agility
	[193677] = "5010771050000", -- Furious Ragefeather,            	
	[193689] = "0241000100024", -- Granyth's Enduring Scale,       	Tank
	[193679] = "0000000600043", -- Idol of Trampling Hooves,       	Damage, Strength
	[193678] = "2082004030010", -- Miniature Singing Stone,        	Healer
	-- The Nokhud Offensive Heroic (id: 1198).
	-- The Nokhud Offensive Mythic (id: 1198).
	-- Uldaman: Legacy of Tyr Normal (id: 1197).
	[193815] = "0124002607443", -- Homeland Raid Horn,             	Damage, Melee
	[193805] = "0241000100024", -- Inexorable Resonator,           	Tank
	[193791] = "7092775070010", -- Time-Breaching Talon,           	Intellect
	-- Uldaman: Legacy of Tyr Heroic (id: 1197).
	-- Uldaman: Legacy of Tyr Mythic Keystone (id: 1197).
	-- Uldaman: Legacy of Tyr Mythic (id: 1197).
	-- Dawn of the Infinite Heroic (id: 1209).
	[207566] = "0124002607443", -- Accelerating Sandglass,         	Damage, Melee
	[207552] = "2082004030010", -- Echoing Tyrstone,               	Healer
	[207581] = "73F7777777777", -- Mirror of Fractured Tomorrows,  	All Classes
	[207528] = "0241000100024", -- Prophetic Stonescales,          	Tank
	[207579] = "5010771040000", -- Time-Thief's Gambit,            	Damage, Intellect
	-- Dawn of the Infinite Mythic (id: 1209).
	-- Dragon Isles Normal (id: 1205).
	[200676] = "73F7777777777", -- Static-Charged Scale,           	All Classes
	-- Dragon Isles Heroic (id: 1205).
	-- Dragon Isles Mythic (id: 1205).
	-- Dragon Isles Looking For Raid (id: 1205).
	-- Vault of the Incarnates Normal (id: 1200).
	[194306] = "0241000100024", -- All-Totem of the Master,        	Tank
	[194307] = "2082004030010", -- Broodkeeper's Promise,          	Healer
	[194300] = "2082004030010", -- Conjured Chillglobe,            	Healer
	[194305] = "0365002007700", -- Controlled Current Technique,   	Agility
	[194299] = "0241000100024", -- Decoration of Flame,            	Tank
	[194310] = "5010771040000", -- Desperate Invoker's Codex,      	Damage, Intellect
	[194304] = "7092775070010", -- Iceblood Deathsnare,            	Intellect
	[194308] = "0124002607743", -- Manic Grieftorch,               	Damage, Strength/Agility
	[194303] = "0000000700067", -- Rumbling Ruby,                  	Strength
	[194309] = "73F7777777777", -- Spiteful Storm,                 	All Classes
	[194302] = "0124002607443", -- Storm-Eater's Boon,             	Damage, Melee
	[194301] = "73F7777777777", -- Whispering Incarnate Icon,      	All Classes
	-- Vault of the Incarnates Heroic (id: 1200).
	-- Vault of the Incarnates Mythic (id: 1200).
	-- Vault of the Incarnates Looking For Raid (id: 1200).
	-- Aberrus, the Shadowed Crucible Normal (id: 1208).
	[203963] = "73F7777777777", -- Beacon to the Beyond,           	All Classes
	[202610] = "0365002007700", -- Dragonfire Bomb Dispenser,      	Agility
	[202617] = "0124002607443", -- Elementium Pocket Anvil,        	Damage, Melee
	[202616] = "0241000100024", -- Enduring Dreadplate,            	Tank
	[203996] = "5010771040300", -- Igneous Flowstone,              	
	-- [204201] = "7300070000077",	-- Neltharion's Call to Chaos,     	Warrior, Paladin, Mage, Demon Hunter, Evoker
	-- [204202] = "0007707000700",	-- Neltharion's Call to Dominance, 	Hunter, Shaman, Warlock, Monk
	-- [204211] = "00F0000777000",	-- Neltharion's Call to Suffering, 	Rogue, Priest, Death Knight, Druid
	[203729] = "73F7777777777", -- Ominous Chromatic Essence,      	All Classes
	[202614] = "2082004030010", -- Rashok's Molten Heart,          	Healer
	[202612] = "73F7777777777", -- Screaming Black Dragonscale,    	All Classes
	[202615] = "5010771040000", -- Vessel of Searing Shadow,       	Damage, Intellect
	[203714] = "22C3004130034", -- Ward of Faceless Ire,           	Tank, Healer
	[202613] = "0000000700067", -- Zaqali Chaos Grapnel,           	Strength
	-- Aberrus, the Shadowed Crucible Heroic (id: 1208).
	-- Aberrus, the Shadowed Crucible Mythic (id: 1208).
	-- Aberrus, the Shadowed Crucible Looking For Raid (id: 1208).
	-- Amirdrassil, the Dream's Hope Normal (id: 1207).
	[207167] = "73F7777777777", -- Ashes of the Embersoul,         	All Classes
	[208614] = "5134773647743", -- Augury of the Primal Flame,     	
	[207165] = "0365002007700", -- Bandolier of Twisted Blades,    	Agility
	[207172] = "5012771040010", -- Belor'relos, the Suncaller,     	Damage, Intellect
	[207171] = "2082004030010", -- Blossom of Amirdrassil,         	Healer
	[207169] = "0000000700067", -- Branch of the Tormented Ancient,	Strength
	[207166] = "0124002607443", -- Cataclysmic Signet Brand,       	Damage, Melee
	[207175] = "0124002607743", -- Coiled Serpent Idol,            	Damage, Strength/Agility
	[207174] = "0241000100024", -- Fyrakk's Tainted Rageheart,     	Tank
	[207173] = "0241000100024", -- Gift of Ursine Vengeance,       	Tank
	[208615] = "5010771040000", -- Nymue's Unraveling Spindle,     	Damage, Intellect
	[207168] = "73F7777777777", -- Pip's Emerald Friendship Badge, 	All Classes
	[207170] = "2082004030010", -- Smoldering Seedling,            	Healer
	-- Amirdrassil, the Dream's Hope Heroic (id: 1207).
	-- Amirdrassil, the Dream's Hope Mythic (id: 1207).
	-- Amirdrassil, the Dream's Hope Looking For Raid (id: 1207).
	-- Freehold Normal (id: 1001).
	[155881] = "0365002007700", -- Harlan's Loaded Dice,           	Agility
	-- Freehold Heroic (id: 1001).
	-- Freehold Mythic Keystone (id: 1001).
	-- Freehold Mythic (id: 1001).
	-- The Underrot Normal (id: 1022).
	[159626] = "0241000100024", -- Lingering Sporepods,            	Tank
	[159624] = "5010771040000", -- Rotcrusted Voodoo Doll,         	Damage, Intellect
	[159625] = "0000000700067", -- Vial of Animated Blood,         	Strength
	-- The Underrot Heroic (id: 1022).
	-- The Underrot Mythic Keystone (id: 1022).
	-- The Underrot Mythic (id: 1022).
	-- Neltharion's Lair Normal (id: 767).
	[137357] = "0124002607443", -- Mark of Dargrul,                	Damage, Melee
	[137349] = "5010771050300", -- Naraxas' Spiked Tongue,         	Damage, Ranged
	[137338] = "0241000100024", -- Shard of Rokmora,               	Tank
	[137344] = "0241000100024", -- Talisman of the Cragshaper,     	Tank
	-- Neltharion's Lair Heroic (id: 767).
	-- Neltharion's Lair Mythic Keystone (id: 767).
	-- Neltharion's Lair Mythic (id: 767).
	-- Neltharion's Lair Timewalking (id: 767).
	-- The Vortex Pinnacle Normal (id: 68).
	[56370] = "0241000100024", -- Heart of Thunder,               	Tank
	-- The Vortex Pinnacle Heroic (id: 68).
	-- The Vortex Pinnacle Mythic Keystone (id: 68).
	[133246] = "0241000100024", -- Heart of Thunder,               	Tank
	[133252] = "2082004030010", -- Rainsong,                       	Healer
	-- The Vortex Pinnacle Timewalking (id: 68).

	-- The War Within
	-- Ara-Kara, City of Echoes Normal (id: 1271).
	[219314] = "73F7777777777", -- Ara-Kara Sacbrood,               	All Classes
	[219316] = "0241000100024", -- Ceaseless Swarmgland,            	Tank
	[219317] = "73F7777077710", -- Harvester's Edict,               	Agility/Intellect
	-- Ara-Kara, City of Echoes Heroic (id: 1271).
	-- Ara-Kara, City of Echoes Mythic Keystone (id: 1271).
	-- Ara-Kara, City of Echoes Mythic (id: 1271).
	-- Cinderbrew Meadery Normal (id: 1272).
	[219297] = "0241000100024", -- Cinderbrew Stein,                	Tank
	[219298] = "0124002607743", -- Ravenous Honey Buzzer,           	Damage, Strength/Agility
	[219299] = "7092775070010", -- Synergistic Brewterializer,      	Intellect
	-- Cinderbrew Meadery Heroic (id: 1272).
	-- Cinderbrew Meadery Mythic (id: 1272).
	-- City of Threads Normal (id: 1274).
	[219321] = "7092775070010", -- Cirral Concoctory,               	Intellect
	[219318] = "0000000700077", -- Oppressive Orator's Larynx,      	Strength
	[219319] = "0124002007700", -- Twin Fang Instruments,           	Damage, Agility
	[219320] = "2082004030010", -- Viscous Coaglam,                 	Healer
	-- City of Threads Heroic (id: 1274).
	-- City of Threads Mythic Keystone (id: 1274).
	-- City of Threads Mythic (id: 1274).
	-- Darkflame Cleft Normal (id: 1210).
	[219305] = "7092775070010", -- Carved Blazikon Wax,             	Intellect
	[219304] = "0124002007700", -- Conductor's Wax Whistle,         	Damage, Agility
	[219307] = "73F7777777777", -- Remnant of Darkness,             	All Classes
	[219306] = "2082004030010", -- Burin of the Candle King,        	Healer
	-- Darkflame Cleft Heroic (id: 1210).
	-- Darkflame Cleft Mythic (id: 1210).
	-- Priory of the Sacred Flame Normal (id: 1267).
	[219308] = "73F7777777777", -- Signet of the Priory,            	All Classes
	[219309] = "0241000100024", -- Tome of Light's Devotion,        	Tank
	[219310] = "2082004030010", -- Bursting Lightshard,             	Healer
	-- Priory of the Sacred Flame Heroic (id: 1267).
	-- Priory of the Sacred Flame Mythic (id: 1267).
	-- The Dawnbreaker Normal (id: 1270).
	[219312] = "73F7777077710", -- Empowering Crystal of Anub'ikkaj,	Agility/Intellect
	[219313] = "7092775070010", -- Mereldar's Toll,                 	Intellect
	[219311] = "0000000700067", -- Void Pactstone,                  	Strength
	-- The Dawnbreaker Heroic (id: 1270).
	-- The Dawnbreaker Mythic Keystone (id: 1270).
	-- The Dawnbreaker Mythic (id: 1270).
	-- The Rookery Normal (id: 1268).
	[219294] = "0124002007700", -- Charged Stormrook Plume,         	Damage, Agility
	[219296] = "7092775070010", -- Entropic Skardyn Core,           	Intellect
	[219295] = "73F7777777777", -- Sigil of Algari Concordance,     	All Classes
	-- The Rookery Heroic (id: 1268).
	-- The Rookery Mythic (id: 1268).
	-- The Stonevault Normal (id: 1269).
	[219303] = "7092775070010", -- High Speaker's Accretion,        	Intellect
	[219301] = "0124002607443", -- Overclocked Gear-A-Rang Launcher,	Damage, Melee
	[219315] = "0241000100024", -- Refracting Aggression Module,    	Tank
	[219302] = "2082004030010", -- Scrapsinger's Symphony,          	Healer
	[219300] = "0000000700067", -- Skarmorak Shard,                 	Strength
	-- The Stonevault Heroic (id: 1269).
	-- The Stonevault Mythic Keystone (id: 1269).
	-- The Stonevault Mythic (id: 1269).
	-- Khaz Algar Normal (id: 1278).
	-- Nerub-ar Palace Normal (id: 1273).
	[212451] = "5010771040000", -- Aberrant Spellforge,             	Damage, Intellect
	[219915] = "0241000100024", -- Foul Behemoth's Chelicera,       	Tank
	[212454] = "5134773647743", -- Mad Queen's Mandate,             	Damage
	[212449] = "0124002607443", -- Sikran's Endless Arsenal,        	Damage, Melee
	[212453] = "0000000600043", -- Skyterror's Corrosive Organ,     	Damage, Strength
	[212450] = "0241000100024", -- Swarmlord's Authority,           	Tank
	[221023] = "73F7777777777", -- Treacherous Transmitter,         	All Classes
	[212456] = "0124002007700", -- Void Reaper's Contract,          	Damage, Agility
	[219917] = "2082004030010", -- Creeping Coagulum,               	Healer
	[212452] = "2082004030010", -- Gruesome Syringe,                	Healer
	[220305] = "73F7777777777", -- Ovi'nax's Mercurial Egg,         	All Classes
	[220202] = "7092775070010", -- Spymaster's Web,                 	Intellect
	-- Nerub-ar Palace Heroic (id: 1273).
	-- Nerub-ar Palace Mythic (id: 1273).
	-- Nerub-ar Palace Looking For Raid (id: 1273).
	-- Mists of Tirna Scithe Normal (id: 1184).
	[178715] = "0365002007700", -- Mistcaller Ocarina,              	Agility
	[178708] = "7092775070010", -- Unbound Changeling,              	Intellect
	-- Mists of Tirna Scithe Heroic (id: 1184).
	-- Mists of Tirna Scithe Mythic Keystone (id: 1184).
	-- Mists of Tirna Scithe Mythic (id: 1184).
	-- The Necrotic Wake Normal (id: 1182).
	[178742] = "0365002007700", -- Bottled Flayedwing Toxin,        	Agility
	[178772] = "5010771040000", -- Satchel of Misbegotten Minions,  	Damage, Intellect
	[178783] = "2082004030010", -- Siphoning Phylactery Shard,      	Healer
	[178751] = "0000000700067", -- Spare Meat Hook,                 	Strength
	-- The Necrotic Wake Heroic (id: 1182).
	-- The Necrotic Wake Mythic Keystone (id: 1182).
	-- The Necrotic Wake Mythic (id: 1182).
	-- Siege of Boralus Heroic (id: 1023).
	[159623] = "0365002007700", -- Dead-Eye Spyglass,               	Agility
	[159622] = "5010771040000", -- Hadal's Nautilus,                	Damage, Intellect
	-- Siege of Boralus Mythic Keystone (id: 1023).
	-- Siege of Boralus Mythic (id: 1023).
	-- Grim Batol Normal (id: 71).
	[133305] = "2082004030010", -- Corrupted Egg Shell,             	Healer
	[133304] = "7092775070010", -- Gale of Shadows,                 	Intellect
	[133300] = "0000000600043", -- Mark of Khardros,                	Damage, Strength
	[133282] = "0124002007700", -- Skardyn's Grace,                 	Damage, Agility
	[133291] = "0201000100024", -- Throngus's Finger,               	Tank, Parry
	-- Grim Batol Heroic (id: 71).
	-- Grim Batol Mythic Keystone (id: 71).
	-- Grim Batol Mythic (id: 71).

	-- Blackrock Depths (id: 1301).
	[231457] = "2082004030010", -- Bottled Magma,                	Healer
	[231424] = "2082004030010", -- Burst of Knowledge,           	Healer
	[231476] = "2082004030010", -- Dope'rel's Calling Rune,      	Healer
	[231414] = "0241000100024", -- Force of Will,                	Tank
	[231471] = "0365002707767", -- Golem Gearbox,                	Strength/Agility
	[231417] = "0365002707767", -- Hand of Justice,              	Strength/Agility
	[231456] = "0000000700067", -- Heart of Roccor,              	Strength
	[231462] = "0241000100024", -- Molten Furnace,               	Tank
	[231420] = "2082004030010", -- Second Wind,                  	Healer

	-- Operation: Floodgate Normal (id: 1298).
	[232542] = "6082004030010", -- Darkfuse Medichopper,            	Healer
	[232545] = "5010771040000", -- Gigazap's Zap-Cap,               	Damage, Intellect
	[232541] = "0365002707767", -- Improvised Seaforium Pacemaker,  	Strength/Agility
	[232543] = "0241000100024", -- Ringing Ritual Mud,              	Tank
	-- Operation: Floodgate Heroic (id: 1298).
	-- Operation: Floodgate Mythic (id: 1298).

	-- Liberation of Undermine Normal (id: 1296).
	[230029] = "0241000100024", -- Chromebustible Bomb Suit,        	Tank
	[230198] = "73F7777777777", -- Eye of Kezan,                    	All Classes
	[230191] = "5010771040000", -- Flarendo's Pilot Light,          	Damage, Intellect
	[230188] = "2082004030010", -- Gallagio Bottle Service,         	Healer
	[230197] = "5134773647743", -- Geargrinder's Spare Keys,        	Damage
	[230027] = "73F7777777777", -- House of Cards,                  	All Classes
	[230189] = "0124002007700", -- Junkmaestro's Mega Magnet,       	Damage, Agility
	[230193] = "5134773647743", -- Mister Lock-N-Stalk,             	Damage
	[230186] = "2082004030010", -- Mister Pick-Me-Up,               	Healer
	[230192] = "7092775070010", -- Mug's Moxie Jug,                 	Intellect
	[230194] = "73F7777777777", -- Reverb Radio,                    	All Classes
	[230026] = "0241000100024", -- Scrapfield 9001,                 	Tank
	[230190] = "0000000600043", -- Torq's Big Red Button,           	Damage, Strength
	[230019] = "0241000100024", -- Vexie's Pit Whistle,             	Tank
	[230199] = "0124002607443", -- Zee's Thug Hotline,              	Damage, Melee
	-- Liberation of Undermine Heroic (id: 1296).
	-- Liberation of Undermine Mythic (id: 1296).
	-- Liberation of Undermine Looking For Raid (id: 1296).
}
