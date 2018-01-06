--- trinketData.lua
-- Contains loot specs of all trinkets in the dungeon journal
-- @author Safetee
-- Create Date : 12/03/2017
-- Update Date : 1/6/2018 (7.3.2 Build 25549)

--@debug@
--[[
This function is used for developer.
Export the loot specs of all trinkets in the encounter journal.
The format is {[itemID] = specFlag}

specFlag is a large number and one hexadecimal digit represents the spec data for a single class.

For example,
0x365002707767
The least significant hexadecimal digit, 7, represents the loot specs of the trinket for Warrrior (class ID 1)
The most significant hexadecimal digit, 3, represents the loot specs of the trinket for Demon Hunter (class ID 11)

The least significant digit 0x7=0b0111, shows the trinket is lootable by Arms (spec index 1), Fury (spec index 2) and Protection (spec index 3)
The 2nd least significant digit 0x6=0b0110, shows the trinket is lootable by Protection (spec index 2) and Retribution (Spec index 3), and not lootable by Holy (index 1)
The specIndex here refers to GetSpecializationInfoForClassID(classID, specIndex)
Holy Paladin is the 1st spec of Paladin (class ID 2) because GetSpecializationInfoForClassID(2, 1) is Holy Paladin
Overall, 0x365002707767, written as 0x3650*2^32+0x02707767 in the code shows the trinket is lootable by all specs using Strength or Agility as Primary Stats.

Do note that although WoW can store and do integer calculation on 64bit integer. There are several places that only support 32 bit integers.
1. 64bit integer constant is not supported. 0x365002707767 is invalid in the source code, however, this can be rewritten as 0x3650*2^32+0x02707767
2. bitlib (bit.band, bit.rshift, etc) only support 32bit integer. However, this can be rewritten as division or modulo to power of 2.
3. Formated string flag "%d" only supports 32bit integer. The following Int48ToHexStr helps to solve the problem.
--]]
local trinketSpecs = {}
local trinketNames = {}

-- WoW does not support integer constants >= 2^32, but can store 64 bit integer.
-- Not supported: 0xffffffffffff
-- Supported: 0xffff*2^32+0xffffffff
-- Note that bitlib (bit.band, bit.rshift, etc) does not work for 64 bit integer.
local function Int48ToHexStr(n)
	return format("0x%04X*2^32+0x%08X", math.floor(n/2^32), math.floor(n%(2^32)))
end

-- The params are used internally inside this function
-- Process in the following order:
-- From expansion vanilla to the latest expansion (nextTier)
-- Inside each expansion, scan dungeon first then raid (nextIsRaid)
-- Inside dungeon/raid, scan by its index in the journal (nextIndex)
-- Inside each instance, scan by difficulty id order(nextDiffID)
function RCLootCouncil:ExportTrinketData(nextTier, nextIsRaid, nextIndex, nextDiffID)
	LoadAddOn("BLizzard_EncounterJournal")
	local MAX_CLASSFLAG_VAL = bit.lshift(1, MAX_CLASSES) - 1
	local TIME_FOR_EACH_INSTANCE_DIFF = 5

	if not nextTier then
		nextTier = 1
		nextIsRaid = 0
		nextIndex = 1
		nextDiffID = 1
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

	local instanceIndex = nextIndex
	for h=nextTier, EJ_GetNumTiers() do
		EJ_SelectTier(h)
		for i=nextIsRaid, 1 do
			while EJ_GetInstanceByIndex(instanceIndex, (i==1)) do
				local instanceID = EJ_GetInstanceByIndex(instanceIndex, (i==1))
				EJ_SelectInstance(instanceID)
				for diffID=nextDiffID, 99 do -- Should be enough to include all difficulties
					if EJ_IsValidInstanceDifficulty(diffID) then
						self:ExportTrinketDataSingleInstance(instanceID, diffID, TIME_FOR_EACH_INSTANCE_DIFF)
						return self:ScheduleTimer("ExportTrinketData", TIME_FOR_EACH_INSTANCE_DIFF, h, i, instanceIndex, diffID + 1)
					end
				end
				nextDiffID = 1
				instanceIndex = instanceIndex + 1
			end
			instanceIndex = 1
		end
		nextIsRaid = 0
	end

	local count = 0
	for id, val in pairs(trinketSpecs) do
		count = count + 1
	end
	self:Print(format("DONE. %d trinkets total", count))
	self:Print("Copy paste the data to Utils/TrinketData.lua")
	self:Print("Suggest to verify the data for the trinket in the recent raid")

	-- Hack that should only happen in developer mode.
	local frame = RCLootCouncil:GetActiveModule("history"):GetFrame()
	frame.exportFrame:Show()

	local exports ="_G.RCTrinketSpecs = {\n"
	local sorted = {}
	for id, val in pairs(trinketSpecs) do
		tinsert(sorted, {id, val})
	end
	table.sort(sorted, function(a, b) return a[1] < b[1] end)
	local longestNameLen = 0
	for _, name in pairs(trinketNames) do
		if #name > longestNameLen then
			longestNameLen = #name
		end
	end
	local exp = "%-"..format("%d", longestNameLen+1).."s" 
	for _, entry in ipairs(sorted) do
		exports = exports.."\t["..entry[1].."] = "..format("%s", Int48ToHexStr(entry[2]))
			..",\t-- "..format(exp, trinketNames[entry[1]]..",").."\t"..(_G.RCTrinketCategories[entry[2]] or "").."\n"
	end
	exports = exports.."}\n"
	frame.exportFrame.edit:SetText(exports)
end

function RCLootCouncil:ClassesFlagToStr(flag)
	local text = ""
	for i=1, MAX_CLASSES do
		if bit.band(flag, bit.lshift(1, i-1)) > 0 then
			if text ~= "" then
				text = text..", "
			end
			text = text..GetClassInfo(i)
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
	EJ_SetSlotFilter(LE_ITEM_FILTER_TYPE_TRINKET)
	for classID = 0, MAX_CLASSES do

	    local specIndexFirst, specIndexLast = 0, 0
	    if classID ~= 0 then
	    	specIndexFirst = 1
	    	specIndexLast = GetNumSpecializationsForClassID(classID)
	    end

	    for specIndex=specIndexFirst, specIndexLast do
	    	if classID == 0 then
	    		EJ_SetLootFilter(classID, 0)
	    	else
	    		EJ_SetLootFilter(classID, GetSpecializationInfoForClassID(classID, specIndex))
	    	end
		    -- GetSpecializationInfoForClassID
		    -- GetNumSpecializationsForClassID
		    for j = 1, EJ_GetNumLoot() do -- EJ_GetNumLoot() can be 0 if EJ items are not cached.
		        local id, _, _, _, _, _, link = EJ_GetLootInfoByIndex(j)
		        if link then
			        if classID == 0 then
			        	trinketSpecs[id] = 0
			        	trinketNames[id] = self:GetItemNameFromLink(link)
			        	GetItemInfo(id)
			        	count = count + 1
			        	tinsert(trinketlinksInThisInstances, link)
			        else
			        	-- Note that bitlib does not work for 64bit integer, so we don't use it here.
			        	trinketSpecs[id] = trinketSpecs[id] + 2^(4*(classID-1)+specIndex-1)
			        end
			    end
		    end
		end
	end
	local interval = 1
	if timeLeft > interval then -- Rerun many times for correctless
		return self:ScheduleTimer("ExportTrinketDataSingleInstance", interval, instanceID, diffID, timeLeft - interval)
	else
		local diffText = GetDifficultyInfo(diffID) or "Unknown difficulty"
		self:Print("--------------------")
		self:Print(format("Instance %d. %s %s. Processed %d trinkets", instanceID, EJ_GetInstanceInfo(instanceID), diffText, count))
		for _, link in ipairs(trinketlinksInThisInstances) do
			local id = self:GetItemIDFromLink(link)
			self:Print(format("%s(%d): %s", link, id, Int48ToHexStr(trinketSpecs[id])))
		end
		self:Print("--------------------")
	end
end
--@end-debug@

-- Trinket categories description according to specs that can loot the trinket.
-- These categories should cover all trinkets in the Encounter Journal. Add more if any trinket is missing category.
_G.RCTrinketCategories = {
	[0x3F77*2^32+0x77777777] = ALL_CLASSES, -- All Classes
	[0x3650*2^32+0x02707767] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT, -- Strength/Agility
	[0x0000*2^32+0x00700067] = ITEM_MOD_STRENGTH_SHORT, -- Strength
	[0x3650*2^32+0x02707467] = MELEE, -- Melee
	[0x3F77*2^32+0x77077710] = ITEM_MOD_AGILITY_SHORT.."/"..ITEM_MOD_INTELLECT_SHORT, -- Agility/Intellect
	[0x3650*2^32+0x02007700] = ITEM_MOD_AGILITY_SHORT, -- Agility
	[0x0927*2^32+0x75070010] = ITEM_MOD_INTELLECT_SHORT, -- Intellect
	[0x2410*2^32+0x00100024] = TANK, -- Tank
	[0x0000*2^32+0x00000024] = TANK..", "..BLOCK, -- Tank, Block (Warrior, Paladin)
	[0x2010*2^32+0x00100024] = TANK..", "..PARRY, -- Tank, Parry (Non-Druid)
	[0x0820*2^32+0x04030010] = HEALER, -- Healer
	[0x1240*2^32+0x02607743] = DAMAGER..", "..ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT, -- Damage, Strength/Agility
	[0x0000*2^32+0x00600043] = DAMAGER..", "..ITEM_MOD_STRENGTH_SHORT, -- Damage, Strength
	[0x1240*2^32+0x02007700] = DAMAGER..", "..ITEM_MOD_AGILITY_SHORT, -- Damage, Agility
	[0x1240*2^32+0x02607443] = DAMAGER..", "..MELEE, -- Damage, Melee
	[0x1240*2^32+0x02007400] = DAMAGER..", "..MELEE..", "..ITEM_MOD_AGILITY_SHORT, -- Damage, Melee, Agility
	[0x0107*2^32+0x71050300] = DAMAGER..", "..RANGED, -- Damage, Ranged
	[0x0107*2^32+0x71050000] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect
	[0x0106*2^32+0x71040000] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect (direct damage, no affliction warlock and shadow priest)
	[0x0107*2^32+0x71040000] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect (no discipline)

	-- The following categories does not make sense. Most likely a Blizzard error in the Encounter Journal for several old trinkets.
	-- Add "?" as a suffix to the description as the result
	[0x0410*2^32+0x00100024] = ALL_CLASSES.."?", -- All Classes?
	[0x3650*2^32+0x02107467] = MELEE.."?", -- Melee? （Missing Frost and Unholy DK)
	[0x2410*2^32+0x00100044] = TANK.."?", -- Tank? (Ret instead of Pro?)
	[0x1240*2^32+0x02607703] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT.."?", -- Strength/Agility?
	[0x3670*2^32+0x02707767] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT.."?", -- Strength/Agility?
	[0x3240*2^32+0x01607743] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT.."?", -- Strength/Agility?
	[0x3240*2^32+0x02007700] = ITEM_MOD_AGILITY_SHORT.."?", -- Agility? (Missing Brewmaster)
	[0x0927*2^32+0x75070310] = ITEM_MOD_AGILITY_SHORT.."/"..ITEM_MOD_INTELLECT_SHORT.."?", -- Agility/Intellect?
	[0x0920*2^32+0x05070010] = ITEM_MOD_INTELLECT_SHORT.."?", -- Intellect? (Missing Mage, Warlock)
	[0x0920*2^32+0x75070010] = ITEM_MOD_INTELLECT_SHORT.."?", -- Intellect? (Missing Warlock)
	[0x0107*2^32+0x73050000] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT.."?", -- Damage, Intellect? (+Enhancement Shaman)
}
-- Class specific trinket
for classID = 1, MAX_CLASSES do
	local flag = 0
	for specIndex=1, GetNumSpecializationsForClassID(classID) do
		flag = flag + 2^(4*(classID-1)+specIndex-1)
	end
	_G.RCTrinketCategories[flag] = select(1, GetClassInfo(classID))
end

-- Automatically generated by command "/rc exporttrinketdata"
-- The code related to above command is commented out for Curseforge release because
-- this is intended to be run by the developer.
-- The table indicates if the trinket is lootable for certain specs.
-- Format: [itemID] = specFlag
-- Manually added: (item id in the EJ is not the same as the item that actually drops -_-)
-- [151974] = 0x2410*2^32+0x00100024,	-- Eye of Shatug,                                  	Tank
_G.RCTrinketSpecs = {
	[11810] = 0x2410*2^32+0x00100024,	-- Force of Will,                                  	Tank
	[11815] = 0x3650*2^32+0x02707767,	-- Hand of Justice,                                	Strength/Agility
	[11819] = 0x0820*2^32+0x04030010,	-- Second Wind,                                    	Healer
	[11832] = 0x0927*2^32+0x75070010,	-- Burst of Knowledge,                             	Intellect
	[13213] = 0x3F77*2^32+0x77777777,	-- Smolderweb's Eye,                               	All Classes
	[13382] = 0x3F77*2^32+0x77777777,	-- Cannonball Runner,                              	All Classes
	[13515] = 0x3F77*2^32+0x77777777,	-- Ramstein's Lightning Bolts,                     	All Classes
	[17744] = 0x3F77*2^32+0x77777777,	-- Heart of Noxxion,                               	All Classes
	[18370] = 0x3F77*2^32+0x77777777,	-- Vigilance Charm,                                	All Classes
	[18371] = 0x0820*2^32+0x04030010,	-- Mindtap Talisman,                               	Healer
	[21473] = 0x3F77*2^32+0x77777777,	-- Eye of Moam,                                    	All Classes
	[21488] = 0x3F77*2^32+0x77777777,	-- Fetish of Chitinous Spikes,                     	All Classes
	[22321] = 0x3650*2^32+0x02707767,	-- Heart of Wyrmthalak,                            	Strength/Agility
	[24376] = 0x3F77*2^32+0x77777777,	-- Runed Fungalcap,                                	All Classes
	[24390] = 0x0927*2^32+0x75070010,	-- Auslese's Light Channeler,                      	Intellect
	[26055] = 0x0927*2^32+0x75070010,	-- Oculus of the Hidden Eye,                       	Intellect
	[27416] = 0x1240*2^32+0x02607703,	-- Fetish of the Fallen,                           	Strength/Agility?
	[27529] = 0x3F77*2^32+0x77777777,	-- Figurine of the Colossus,                       	All Classes
	[27683] = 0x0927*2^32+0x75070010,	-- Quagmirran's Eye,                               	Intellect
	[27770] = 0x2410*2^32+0x00100024,	-- Argussian Compass,                              	Tank
	[27828] = 0x0820*2^32+0x04030010,	-- Warp-Scarab Brooch,                             	Healer
	[27891] = 0x3F77*2^32+0x77777777,	-- Adamantine Figurine,                            	All Classes
	[27896] = 0x0820*2^32+0x04030010,	-- Alembic of Infernal Power,                      	Healer
	[27900] = 0x3F77*2^32+0x77777777,	-- Jewel of Charismatic Mystique,                  	All Classes
	[28034] = 0x3240*2^32+0x01607743,	-- Hourglass of the Unraveller,                    	Strength/Agility?
	[28121] = 0x3F77*2^32+0x77777777,	-- Icon of Unyielding Courage,                     	All Classes
	[28190] = 0x0927*2^32+0x75070010,	-- Scarab of the Infinite Cycle,                   	Intellect
	[28223] = 0x3F77*2^32+0x77777777,	-- Arcanist's Stone,                               	All Classes
	[28288] = 0x1240*2^32+0x02607743,	-- Abacus of Violent Odds,                         	Damage, Strength/Agility
	[28370] = 0x0820*2^32+0x04030010,	-- Bangle of Endless Blessings,                    	Healer
	[28418] = 0x0107*2^32+0x71040000,	-- Shiffar's Nexus-Horn,                           	Damage, Intellect
	[28528] = 0x3F77*2^32+0x77777777,	-- Moroes' Lucky Pocket Watch,                     	All Classes
	[28579] = 0x3F77*2^32+0x77777777,	-- Romulo's Poison Vial,                           	All Classes
	[28590] = 0x0927*2^32+0x75070010,	-- Ribbon of Sacrifice,                            	Intellect
	[28727] = 0x0927*2^32+0x75070010,	-- Pendant of the Violet Eye,                      	Intellect
	[28785] = 0x3F77*2^32+0x77777777,	-- The Lightning Capacitor,                        	All Classes
	[28789] = 0x0927*2^32+0x75070010,	-- Eye of Magtheridon,                             	Intellect
	[28823] = 0x0927*2^32+0x75070010,	-- Eye of Gruul,                                   	Intellect
	[28830] = 0x3650*2^32+0x02707767,	-- Dragonspine Trophy,                             	Strength/Agility
	[30446] = 0x3F77*2^32+0x77777777,	-- Solarian's Sapphire,                            	All Classes
	[30447] = 0x3F77*2^32+0x77777777,	-- Tome of Fiery Redemption,                       	All Classes
	[30448] = 0x3F77*2^32+0x77777777,	-- Talon of Al'ar,                                 	All Classes
	[30449] = 0x3F77*2^32+0x77777777,	-- Void Star Talisman,                             	All Classes
	[30450] = 0x3F77*2^32+0x77777777,	-- Warp-Spring Coil,                               	All Classes
	[30619] = 0x3F77*2^32+0x77777777,	-- Fel Reaver's Piston,                            	All Classes
	[30621] = 0x3F77*2^32+0x77777777,	-- Prism of Inner Calm,                            	All Classes
	[30626] = 0x3F77*2^32+0x77777777,	-- Sextant of Unstable Currents,                   	All Classes
	[30627] = 0x3F77*2^32+0x77777777,	-- Tsunami Talisman,                               	All Classes
	[30629] = 0x3F77*2^32+0x77777777,	-- Scarab of Displacement,                         	All Classes
	[30663] = 0x3F77*2^32+0x77777777,	-- Fathom-Brooch of the Tidewalker,                	All Classes
	[30664] = 0x3F77*2^32+0x77777777,	-- Living Root of the Wildheart,                   	All Classes
	[30665] = 0x0000*2^32+0x00070000,	-- Earring of Soulful Meditation,                  	Priest
	[30720] = 0x3F77*2^32+0x77777777,	-- Serpent-Coil Braid,                             	All Classes
	[32483] = 0x0927*2^32+0x75070010,	-- The Skull of Gul'dan,                           	Intellect
	[32496] = 0x0927*2^32+0x75070010,	-- Memento of Tyrande,                             	Intellect
	[32501] = 0x3F77*2^32+0x77777777,	-- Shadowmoon Insignia,                            	All Classes
	[32505] = 0x3650*2^32+0x02707767,	-- Madness of the Betrayer,                        	Strength/Agility
	[34427] = 0x3F77*2^32+0x77777777,	-- Blackened Naaru Sliver,                         	All Classes
	[34428] = 0x3F77*2^32+0x77777777,	-- Steely Naaru Sliver,                            	All Classes
	[34429] = 0x3F77*2^32+0x77777777,	-- Shifting Naaru Sliver,                          	All Classes
	[34430] = 0x0927*2^32+0x75070010,	-- Glimmering Naaru Sliver,                        	Intellect
	[34470] = 0x0927*2^32+0x75070010,	-- Timbal's Focusing Crystal,                      	Intellect
	[34471] = 0x3F77*2^32+0x77777777,	-- Vial of the Sunwell,                            	All Classes
	[34472] = 0x1240*2^32+0x02607743,	-- Shard of Contempt,                              	Damage, Strength/Agility
	[34473] = 0x2410*2^32+0x00100024,	-- Commendation of Kael'thas,                      	Tank
	[36972] = 0x0927*2^32+0x75070010,	-- Tome of Arcane Phenomena,                       	Intellect
	[36993] = 0x2410*2^32+0x00100024,	-- Seal of the Pantheon,                           	Tank
	[37064] = 0x3650*2^32+0x02707767,	-- Vestige of Haldor,                              	Strength/Agility
	[37111] = 0x0927*2^32+0x75070010,	-- Soul Preserver,                                 	Intellect
	[37166] = 0x3650*2^32+0x02707767,	-- Sphere of Red Dragon's Blood,                   	Strength/Agility
	[37220] = 0x2410*2^32+0x00100024,	-- Essence of Gossamer,                            	Tank
	[37264] = 0x0107*2^32+0x71040000,	-- Pendulum of Telluric Currents,                  	Damage, Intellect
	[37390] = 0x3650*2^32+0x02707767,	-- Meteorite Whetstone,                            	Strength/Agility
	[37638] = 0x2410*2^32+0x00100024,	-- Offering of Sacrifice,                          	Tank
	[37657] = 0x0920*2^32+0x05070010,	-- Spark of Life,                                  	Intellect?
	[37660] = 0x0927*2^32+0x75070010,	-- Forge Ember,                                    	Intellect
	[37723] = 0x1240*2^32+0x02607743,	-- Incisor Fragment,                               	Damage, Strength/Agility
	[37734] = 0x3F77*2^32+0x77777777,	-- Talisman of Troll Divinity,                     	All Classes
	[37844] = 0x0920*2^32+0x05070010,	-- Winged Talisman,                                	Intellect?
	[37872] = 0x0000*2^32+0x00000024,	-- Lavanthor's Talisman,                           	Tank, Block
	[37873] = 0x0927*2^32+0x75070010,	-- Mark of the War Prisoner,                       	Intellect
	[39229] = 0x0927*2^32+0x75070010,	-- Embrace of the Spider,                          	Intellect
	[39257] = 0x3F77*2^32+0x77777777,	-- Loatheb's Shadow,                               	All Classes
	[39292] = 0x3F77*2^32+0x77777777,	-- Repelling Charge,                               	All Classes
	[39388] = 0x3F77*2^32+0x77777777,	-- Spirit-World Glass,                             	All Classes
	[40255] = 0x3F77*2^32+0x77777777,	-- Dying Curse,                                    	All Classes
	[40256] = 0x3F77*2^32+0x77777777,	-- Grim Toll,                                      	All Classes
	[40257] = 0x3F77*2^32+0x77777777,	-- Defender's Code,                                	All Classes
	[40258] = 0x0927*2^32+0x75070010,	-- Forethought Talisman,                           	Intellect
	[40371] = 0x3650*2^32+0x02707767,	-- Bandit's Insignia,                              	Strength/Agility
	[40372] = 0x3F77*2^32+0x77777777,	-- Rune of Repulsion,                              	All Classes
	[40373] = 0x3F77*2^32+0x77777777,	-- Extract of Necromantic Power,                   	All Classes
	[40382] = 0x3F77*2^32+0x77777777,	-- Soul of the Dead,                               	All Classes
	[40430] = 0x3F77*2^32+0x77777777,	-- Majestic Dragon Figurine,                       	All Classes
	[40431] = 0x3F77*2^32+0x77777777,	-- Fury of the Five Flights,                       	All Classes
	[40432] = 0x3F77*2^32+0x77777777,	-- Illustration of the Dragon Soul,                	All Classes
	[40531] = 0x3F77*2^32+0x77777777,	-- Mark of Norgannon,                              	All Classes
	[40532] = 0x3F77*2^32+0x77777777,	-- Living Ice Crystals,                            	All Classes
	[45148] = 0x3F77*2^32+0x77777777,	-- Living Flame,                                   	All Classes
	[45158] = 0x3F77*2^32+0x77777777,	-- Heart of Iron,                                  	All Classes
	[45263] = 0x3F77*2^32+0x77777777,	-- Wrathstone,                                     	All Classes
	[45286] = 0x3F77*2^32+0x77777777,	-- Pyrite Infuser,                                 	All Classes
	[45292] = 0x3F77*2^32+0x77777777,	-- Energy Siphon,                                  	All Classes
	[45308] = 0x3F77*2^32+0x77777777,	-- Eye of the Broodmother,                         	All Classes
	[45313] = 0x3F77*2^32+0x77777777,	-- Furnace Stone,                                  	All Classes
	[45466] = 0x0927*2^32+0x75070010,	-- Scale of Fates,                                 	Intellect
	[45490] = 0x0927*2^32+0x75070010,	-- Pandora's Plea,                                 	Intellect
	[45507] = 0x3F77*2^32+0x77777777,	-- The General's Heart,                            	All Classes
	[45518] = 0x3F77*2^32+0x77777777,	-- Flare of the Heavens,                           	All Classes
	[45522] = 0x3F77*2^32+0x77777777,	-- Blood of the Old God,                           	All Classes
	[45535] = 0x0927*2^32+0x75070010,	-- Show of Faith,                                  	Intellect
	[45609] = 0x3650*2^32+0x02707767,	-- Comet's Trail,                                  	Strength/Agility
	[45703] = 0x3F77*2^32+0x77777777,	-- Spark of Hope,                                  	All Classes
	[45866] = 0x3F77*2^32+0x77777777,	-- Elemental Focus Stone,                          	All Classes
	[45929] = 0x0927*2^32+0x75070010,	-- Sif's Remembrance,                              	Intellect
	[45931] = 0x3F77*2^32+0x77777777,	-- Mjolnir Runestone,                              	All Classes
	[46021] = 0x3F77*2^32+0x77777777,	-- Royal Seal of King Llane,                       	All Classes
	[46038] = 0x3650*2^32+0x02707767,	-- Dark Matter,                                    	Strength/Agility
	[46051] = 0x0927*2^32+0x75070010,	-- Meteorite Crystal,                              	Intellect
	[46312] = 0x3F77*2^32+0x77777777,	-- Vanquished Clutches of Yogg-Saron,              	All Classes
	[47213] = 0x0107*2^32+0x71040000,	-- Abyssal Rune,                                   	Damage, Intellect
	[47214] = 0x1240*2^32+0x02607743,	-- Banner of Victory,                              	Damage, Strength/Agility
	[47215] = 0x0927*2^32+0x75070010,	-- Tears of the Vanquished,                        	Intellect
	[47216] = 0x2410*2^32+0x00100024,	-- The Black Heart,                                	Tank
	[47271] = 0x0927*2^32+0x75070010,	-- Solace of the Fallen,                           	Intellect
	[47290] = 0x3F77*2^32+0x77777777,	-- Juggernaut's Vitality,                          	All Classes
	[47303] = 0x3650*2^32+0x02707767,	-- Death's Choice,                                 	Strength/Agility
	[47316] = 0x0927*2^32+0x75070010,	-- Reign of the Dead,                              	Intellect
	[47432] = 0x0927*2^32+0x75070010,	-- Solace of the Fallen,                           	Intellect
	[47451] = 0x3F77*2^32+0x77777777,	-- Juggernaut's Vitality,                          	All Classes
	[47464] = 0x3650*2^32+0x02707767,	-- Death's Choice,                                 	Strength/Agility
	[47477] = 0x0927*2^32+0x75070010,	-- Reign of the Dead,                              	Intellect
	[47879] = 0x3F77*2^32+0x77777777,	-- Fetish of Volatile Power,                       	All Classes
	[47880] = 0x3F77*2^32+0x77777777,	-- Binding Stone,                                  	All Classes
	[47881] = 0x3F77*2^32+0x77777777,	-- Vengeance of the Forsaken,                      	All Classes
	[47882] = 0x3F77*2^32+0x77777777,	-- Eitrigg's Oath,                                 	All Classes
	[48018] = 0x3F77*2^32+0x77777777,	-- Fetish of Volatile Power,                       	All Classes
	[48019] = 0x3F77*2^32+0x77777777,	-- Binding Stone,                                  	All Classes
	[48020] = 0x3F77*2^32+0x77777777,	-- Vengeance of the Forsaken,                      	All Classes
	[48021] = 0x3F77*2^32+0x77777777,	-- Eitrigg's Oath,                                 	All Classes
	[49310] = 0x3F77*2^32+0x77777777,	-- Purified Shard of the Scale,                    	All Classes
	[49463] = 0x3F77*2^32+0x77777777,	-- Purified Shard of the Flame,                    	All Classes
	[49464] = 0x3F77*2^32+0x77777777,	-- Shiny Shard of the Flame,                       	All Classes
	[49488] = 0x3F77*2^32+0x77777777,	-- Shiny Shard of the Scale,                       	All Classes
	[50198] = 0x3670*2^32+0x02707767,	-- Needle-Encrusted Scorpion,                      	Strength/Agility?
	[50235] = 0x2410*2^32+0x00100024,	-- Ick's Rotting Thumb,                            	Tank
	[50259] = 0x0927*2^32+0x75070010,	-- Nevermelting Ice Crystal,                       	Intellect
	[50260] = 0x0820*2^32+0x04030010,	-- Ephemeral Snowflake,                            	Healer
	[50339] = 0x0927*2^32+0x75070010,	-- Sliver of Pure Ice,                             	Intellect
	[50340] = 0x3F77*2^32+0x77777777,	-- Muradin's Spyglass,                             	All Classes
	[50341] = 0x3F77*2^32+0x77777777,	-- Unidentifiable Organ,                           	All Classes
	[50342] = 0x3F77*2^32+0x77777777,	-- Whispering Fanged Skull,                        	All Classes
	[50343] = 0x3F77*2^32+0x77777777,	-- Whispering Fanged Skull,                        	All Classes
	[50344] = 0x3F77*2^32+0x77777777,	-- Unidentifiable Organ,                           	All Classes
	[50345] = 0x3F77*2^32+0x77777777,	-- Muradin's Spyglass,                             	All Classes
	[50346] = 0x0927*2^32+0x75070010,	-- Sliver of Pure Ice,                             	Intellect
	[50348] = 0x3F77*2^32+0x77777777,	-- Dislodged Foreign Object,                       	All Classes
	[50349] = 0x3F77*2^32+0x77777777,	-- Corpse Tongue Coin,                             	All Classes
	[50351] = 0x3F77*2^32+0x77777777,	-- Tiny Abomination in a Jar,                      	All Classes
	[50352] = 0x3F77*2^32+0x77777777,	-- Corpse Tongue Coin,                             	All Classes
	[50353] = 0x3F77*2^32+0x77777777,	-- Dislodged Foreign Object,                       	All Classes
	[50354] = 0x3F77*2^32+0x77777777,	-- Bauble of True Blood,                           	All Classes
	[50359] = 0x0927*2^32+0x75070010,	-- Althor's Abacus,                                	Intellect
	[50360] = 0x3F77*2^32+0x77777777,	-- Phylactery of the Nameless Lich,                	All Classes
	[50361] = 0x3F77*2^32+0x77777777,	-- Sindragosa's Flawless Fang,                     	All Classes
	[50362] = 0x3F77*2^32+0x77777777,	-- Deathbringer's Will,                            	All Classes
	[50363] = 0x3F77*2^32+0x77777777,	-- Deathbringer's Will,                            	All Classes
	[50364] = 0x3F77*2^32+0x77777777,	-- Sindragosa's Flawless Fang,                     	All Classes
	[50365] = 0x3F77*2^32+0x77777777,	-- Phylactery of the Nameless Lich,                	All Classes
	[50366] = 0x0927*2^32+0x75070010,	-- Althor's Abacus,                                	Intellect
	[50706] = 0x3F77*2^32+0x77777777,	-- Tiny Abomination in a Jar,                      	All Classes
	[50726] = 0x3F77*2^32+0x77777777,	-- Bauble of True Blood,                           	All Classes
	[54569] = 0x3F77*2^32+0x77777777,	-- Sharpened Twilight Scale,                       	All Classes
	[54571] = 0x3F77*2^32+0x77777777,	-- Petrified Twilight Scale,                       	All Classes
	[54572] = 0x3F77*2^32+0x77777777,	-- Charred Twilight Scale,                         	All Classes
	[54573] = 0x0927*2^32+0x75070010,	-- Glowing Twilight Scale,                         	Intellect
	[54588] = 0x3F77*2^32+0x77777777,	-- Charred Twilight Scale,                         	All Classes
	[54589] = 0x0927*2^32+0x75070010,	-- Glowing Twilight Scale,                         	Intellect
	[54590] = 0x3F77*2^32+0x77777777,	-- Sharpened Twilight Scale,                       	All Classes
	[54591] = 0x3F77*2^32+0x77777777,	-- Petrified Twilight Scale,                       	All Classes
	[55237] = 0x3F77*2^32+0x77777777,	-- Porcelain Crab,                                 	All Classes
	[55251] = 0x3F77*2^32+0x77777777,	-- Might of the Ocean,                             	All Classes
	[55256] = 0x3F77*2^32+0x77777777,	-- Sea Star,                                       	All Classes
	[55266] = 0x3650*2^32+0x02007700,	-- Grace of the Herald,                            	Agility
	[55787] = 0x0927*2^32+0x75070010,	-- Witching Hourglass,                             	Intellect
	[55795] = 0x3F77*2^32+0x77777777,	-- Key to the Endless Chamber,                     	All Classes
	[55810] = 0x0927*2^32+0x75070010,	-- Tendrils of Burrowing Dark,                     	Intellect
	[55814] = 0x0000*2^32+0x00700067,	-- Magnetite Mirror,                               	Strength
	[55816] = 0x2410*2^32+0x00100024,	-- Leaden Despair,                                 	Tank
	[55819] = 0x0927*2^32+0x75070010,	-- Tear of Blood,                                  	Intellect
	[55845] = 0x2410*2^32+0x00100024,	-- Heart of Thunder,                               	Tank
	[55868] = 0x3F77*2^32+0x77777777,	-- Heart of Solace,                                	All Classes
	[55874] = 0x3650*2^32+0x02007700,	-- Tia's Grace,                                    	Agility
	[55879] = 0x0107*2^32+0x71040000,	-- Sorrowsong,                                     	Damage, Intellect
	[55889] = 0x3F77*2^32+0x77777777,	-- Anhuur's Hymnal,                                	All Classes
	[55995] = 0x0820*2^32+0x04030010,	-- Blood of Isiset,                                	Healer
	[56100] = 0x3F77*2^32+0x77777777,	-- Right Eye of Rajh,                              	All Classes
	[56102] = 0x3650*2^32+0x02007700,	-- Left Eye of Rajh,                               	Agility
	[56115] = 0x3650*2^32+0x02007700,	-- Skardyn's Grace,                                	Agility
	[56121] = 0x3F77*2^32+0x77777777,	-- Throngus's Finger,                              	All Classes
	[56132] = 0x0000*2^32+0x00700067,	-- Mark of Khardros,                               	Strength
	[56136] = 0x0820*2^32+0x04030010,	-- Corrupted Egg Shell,                            	Healer
	[56138] = 0x3F77*2^32+0x77777777,	-- Gale of Shadows,                                	All Classes
	[56280] = 0x3F77*2^32+0x77777777,	-- Porcelain Crab,                                 	All Classes
	[56285] = 0x3F77*2^32+0x77777777,	-- Might of the Ocean,                             	All Classes
	[56290] = 0x3F77*2^32+0x77777777,	-- Sea Star,                                       	All Classes
	[56295] = 0x3650*2^32+0x02007700,	-- Grace of the Herald,                            	Agility
	[56320] = 0x0927*2^32+0x75070010,	-- Witching Hourglass,                             	Intellect
	[56328] = 0x3F77*2^32+0x77777777,	-- Key to the Endless Chamber,                     	All Classes
	[56339] = 0x0920*2^32+0x75070010,	-- Tendrils of Burrowing Dark,                     	Intellect?
	[56345] = 0x0000*2^32+0x00700067,	-- Magnetite Mirror,                               	Strength
	[56347] = 0x2410*2^32+0x00100024,	-- Leaden Despair,                                 	Tank
	[56351] = 0x0927*2^32+0x75070010,	-- Tear of Blood,                                  	Intellect
	[56370] = 0x2410*2^32+0x00100024,	-- Heart of Thunder,                               	Tank
	[56393] = 0x3F77*2^32+0x77777777,	-- Heart of Solace,                                	All Classes
	[56394] = 0x3650*2^32+0x02007700,	-- Tia's Grace,                                    	Agility
	[56400] = 0x0107*2^32+0x71040000,	-- Sorrowsong,                                     	Damage, Intellect
	[56407] = 0x3F77*2^32+0x77777777,	-- Anhuur's Hymnal,                                	All Classes
	[56414] = 0x0820*2^32+0x04030010,	-- Blood of Isiset,                                	Healer
	[56427] = 0x3650*2^32+0x02007700,	-- Left Eye of Rajh,                               	Agility
	[56431] = 0x3F77*2^32+0x77777777,	-- Right Eye of Rajh,                              	All Classes
	[56440] = 0x3650*2^32+0x02007700,	-- Skardyn's Grace,                                	Agility
	[56449] = 0x3F77*2^32+0x77777777,	-- Throngus's Finger,                              	All Classes
	[56458] = 0x0000*2^32+0x00700067,	-- Mark of Khardros,                               	Strength
	[56462] = 0x3F77*2^32+0x77777777,	-- Gale of Shadows,                                	All Classes
	[56463] = 0x0820*2^32+0x04030010,	-- Corrupted Egg Shell,                            	Healer
	[59224] = 0x0000*2^32+0x00700067,	-- Heart of Rage,                                  	Strength
	[59326] = 0x3F77*2^32+0x77777777,	-- Bell of Enraging Resonance,                     	All Classes
	[59332] = 0x2410*2^32+0x00100024,	-- Symbiotic Worm,                                 	Tank
	[59354] = 0x0820*2^32+0x04030010,	-- Jar of Ancient Remedies,                        	Healer
	[59441] = 0x3650*2^32+0x02007700,	-- Prestor's Talisman of Machination,              	Agility
	[59473] = 0x3650*2^32+0x02007700,	-- Essence of the Cyclone,                         	Agility
	[59500] = 0x0927*2^32+0x75070010,	-- Fall of Mortality,                              	Intellect
	[59506] = 0x0000*2^32+0x00700067,	-- Crushing Weight,                                	Strength
	[59514] = 0x3F77*2^32+0x77777777,	-- Heart of Ignacious,                             	All Classes
	[59515] = 0x3F77*2^32+0x77777777,	-- Vial of Stolen Memories,                        	All Classes
	[59519] = 0x0927*2^32+0x75070010,	-- Theralion's Mirror,                             	Intellect
	[60233] = 0x3F77*2^32+0x77777777,	-- Shard of Woe,                                   	All Classes
	[60801] = 0x3F77*2^32+0x77777777,	-- Vicious Gladiator's Medallion of Cruelty,       	All Classes
	[60806] = 0x3F77*2^32+0x77777777,	-- Vicious Gladiator's Medallion of Meditation,    	All Classes
	[60807] = 0x3F77*2^32+0x77777777,	-- Vicious Gladiator's Medallion of Tenacity,      	All Classes
	[61026] = 0x3F77*2^32+0x77777777,	-- Vicious Gladiator's Emblem of Cruelty,          	All Classes
	[61031] = 0x3F77*2^32+0x77777777,	-- Vicious Gladiator's Emblem of Meditation,       	All Classes
	[61032] = 0x3F77*2^32+0x77777777,	-- Vicious Gladiator's Emblem of Tenacity,         	All Classes
	[61033] = 0x3650*2^32+0x02007700,	-- Vicious Gladiator's Badge of Conquest,          	Agility
	[61047] = 0x3650*2^32+0x02007700,	-- Vicious Gladiator's Insignia of Conquest,       	Agility
	[65026] = 0x3650*2^32+0x02007700,	-- Prestor's Talisman of Machination,              	Agility
	[65029] = 0x0820*2^32+0x04030010,	-- Jar of Ancient Remedies,                        	Healer
	[65048] = 0x2410*2^32+0x00100024,	-- Symbiotic Worm,                                 	Tank
	[65053] = 0x3F77*2^32+0x77777777,	-- Bell of Enraging Resonance,                     	All Classes
	[65072] = 0x0000*2^32+0x00700067,	-- Heart of Rage,                                  	Strength
	[65105] = 0x0927*2^32+0x75070010,	-- Theralion's Mirror,                             	Intellect
	[65109] = 0x3F77*2^32+0x77777777,	-- Vial of Stolen Memories,                        	All Classes
	[65110] = 0x3F77*2^32+0x77777777,	-- Heart of Ignacious,                             	All Classes
	[65118] = 0x0000*2^32+0x00700067,	-- Crushing Weight,                                	Strength
	[65124] = 0x0927*2^32+0x75070010,	-- Fall of Mortality,                              	Intellect
	[65140] = 0x3650*2^32+0x02007700,	-- Essence of the Cyclone,                         	Agility
	[68925] = 0x0927*2^32+0x75070010,	-- Variable Pulse Lightning Capacitor,             	Intellect
	[68926] = 0x0927*2^32+0x75070010,	-- Jaws of Defeat,                                 	Intellect
	[68927] = 0x3650*2^32+0x02007700,	-- The Hungerer,                                   	Agility
	[68981] = 0x2410*2^32+0x00100024,	-- Spidersilk Spindle,                             	Tank
	[68982] = 0x0927*2^32+0x75070010,	-- Necromantic Focus,                              	Intellect
	[68983] = 0x0927*2^32+0x75070010,	-- Eye of Blazing Power,                           	Intellect
	[68994] = 0x3650*2^32+0x02007700,	-- Matrix Restabilizer,                            	Agility
	[68995] = 0x0000*2^32+0x00700067,	-- Vessel of Acceleration,                         	Strength
	[69110] = 0x0927*2^32+0x75070010,	-- Variable Pulse Lightning Capacitor,             	Intellect
	[69111] = 0x0927*2^32+0x75070010,	-- Jaws of Defeat,                                 	Intellect
	[69112] = 0x3650*2^32+0x02007700,	-- The Hungerer,                                   	Agility
	[69138] = 0x2410*2^32+0x00100024,	-- Spidersilk Spindle,                             	Tank
	[69139] = 0x0927*2^32+0x75070010,	-- Necromantic Focus,                              	Intellect
	[69149] = 0x0927*2^32+0x75070010,	-- Eye of Blazing Power,                           	Intellect
	[69150] = 0x3650*2^32+0x02007700,	-- Matrix Restabilizer,                            	Agility
	[69167] = 0x0000*2^32+0x00700067,	-- Vessel of Acceleration,                         	Strength
	[70393] = 0x3F77*2^32+0x77777777,	-- Ruthless Gladiator's Medallion of Cruelty,      	All Classes
	[70394] = 0x3F77*2^32+0x77777777,	-- Ruthless Gladiator's Medallion of Meditation,   	All Classes
	[70395] = 0x3F77*2^32+0x77777777,	-- Ruthless Gladiator's Medallion of Tenacity,     	All Classes
	[70396] = 0x3F77*2^32+0x77777777,	-- Ruthless Gladiator's Emblem of Cruelty,         	All Classes
	[70397] = 0x3F77*2^32+0x77777777,	-- Ruthless Gladiator's Emblem of Meditation,      	All Classes
	[70398] = 0x3F77*2^32+0x77777777,	-- Ruthless Gladiator's Emblem of Tenacity,        	All Classes
	[70399] = 0x3650*2^32+0x02007700,	-- Ruthless Gladiator's Badge of Conquest,         	Agility
	[70400] = 0x0000*2^32+0x00700067,	-- Ruthless Gladiator's Badge of Victory,          	Strength
	[70401] = 0x0927*2^32+0x75070010,	-- Ruthless Gladiator's Badge of Dominance,        	Intellect
	[70402] = 0x0927*2^32+0x75070010,	-- Ruthless Gladiator's Insignia of Dominance,     	Intellect
	[70403] = 0x0000*2^32+0x00700067,	-- Ruthless Gladiator's Insignia of Victory,       	Strength
	[70404] = 0x3650*2^32+0x02007700,	-- Ruthless Gladiator's Insignia of Conquest,      	Agility
	[72897] = 0x3650*2^32+0x02007700,	-- Arrow of Time,                                  	Agility
	[72898] = 0x0927*2^32+0x75070010,	-- Foul Gift of the Demon Lord,                    	Intellect
	[72899] = 0x0000*2^32+0x00700067,	-- Varo'then's Brooch,                             	Strength
	[72900] = 0x2410*2^32+0x00100024,	-- Veil of Lies,                                   	Tank
	[72901] = 0x0000*2^32+0x00700067,	-- Rosary of Light,                                	Strength
	[73491] = 0x0000*2^32+0x00700067,	-- Cataclysmic Gladiator's Insignia of Victory,    	Strength
	[73496] = 0x0000*2^32+0x00700067,	-- Cataclysmic Gladiator's Badge of Victory,       	Strength
	[73497] = 0x0927*2^32+0x75070010,	-- Cataclysmic Gladiator's Insignia of Dominance,  	Intellect
	[73498] = 0x0927*2^32+0x75070010,	-- Cataclysmic Gladiator's Badge of Dominance,     	Intellect
	[73534] = 0x3F77*2^32+0x77777777,	-- Cataclysmic Gladiator's Medallion of Meditation,	All Classes
	[73537] = 0x3F77*2^32+0x77777777,	-- Cataclysmic Gladiator's Medallion of Tenacity,  	All Classes
	[73538] = 0x3F77*2^32+0x77777777,	-- Cataclysmic Gladiator's Medallion of Cruelty,   	All Classes
	[73591] = 0x3F77*2^32+0x77777777,	-- Cataclysmic Gladiator's Emblem of Meditation,   	All Classes
	[73592] = 0x3F77*2^32+0x77777777,	-- Cataclysmic Gladiator's Emblem of Tenacity,     	All Classes
	[73593] = 0x3F77*2^32+0x77777777,	-- Cataclysmic Gladiator's Emblem of Cruelty,      	All Classes
	[73643] = 0x3650*2^32+0x02007700,	-- Cataclysmic Gladiator's Insignia of Conquest,   	Agility
	[73648] = 0x3650*2^32+0x02007700,	-- Cataclysmic Gladiator's Badge of Conquest,      	Agility
	[77197] = 0x3650*2^32+0x02007700,	-- Wrath of Unchaining,                            	Agility
	[77198] = 0x0107*2^32+0x71040000,	-- Will of Unbinding,                              	Damage, Intellect
	[77199] = 0x0927*2^32+0x75070010,	-- Heart of Unliving,                              	Intellect
	[77200] = 0x0000*2^32+0x00700067,	-- Eye of Unmaking,                                	Strength
	[77201] = 0x2410*2^32+0x00100024,	-- Resolve of Undying,                             	Tank
	[77202] = 0x3650*2^32+0x02007700,	-- Starcatcher Compass,                            	Agility
	[77203] = 0x0927*2^32+0x75070010,	-- Insignia of the Corrupted Mind,                 	Intellect
	[77204] = 0x0927*2^32+0x75070010,	-- Seal of the Seven Signs,                        	Intellect
	[77205] = 0x0000*2^32+0x00700067,	-- Creche of the Final Dragon,                     	Strength
	[77206] = 0x2410*2^32+0x00100024,	-- Soulshifter Vortex,                             	Tank
	[77207] = 0x3650*2^32+0x02007700,	-- Vial of Shadows,                                	Agility
	[77208] = 0x0107*2^32+0x71040000,	-- Cunning of the Cruel,                           	Damage, Intellect
	[77209] = 0x0820*2^32+0x04030010,	-- Windward Heart,                                 	Healer
	[77210] = 0x0000*2^32+0x00700067,	-- Bone-Link Fetish,                               	Strength
	[77211] = 0x2410*2^32+0x00100024,	-- Indomitable Pride,                              	Tank
	[77989] = 0x0927*2^32+0x75070010,	-- Seal of the Seven Signs,                        	Intellect
	[77990] = 0x2410*2^32+0x00100044,	-- Soulshifter Vortex,                             	Tank?
	[77991] = 0x0927*2^32+0x75070010,	-- Insignia of the Corrupted Mind,                 	Intellect
	[77992] = 0x0000*2^32+0x00700067,	-- Creche of the Final Dragon,                     	Strength
	[77993] = 0x3650*2^32+0x02007700,	-- Starcatcher Compass,                            	Agility
	[77994] = 0x3650*2^32+0x02007700,	-- Wrath of Unchaining,                            	Agility
	[77995] = 0x0107*2^32+0x71040000,	-- Will of Unbinding,                              	Damage, Intellect
	[77996] = 0x0820*2^32+0x04030010,	-- Heart of Unliving,                              	Healer
	[77997] = 0x0000*2^32+0x00700067,	-- Eye of Unmaking,                                	Strength
	[77998] = 0x2410*2^32+0x00100024,	-- Resolve of Undying,                             	Tank
	[77999] = 0x3650*2^32+0x02007700,	-- Vial of Shadows,                                	Agility
	[78000] = 0x0927*2^32+0x75070010,	-- Cunning of the Cruel,                           	Intellect
	[78001] = 0x0820*2^32+0x04030010,	-- Windward Heart,                                 	Healer
	[78002] = 0x0000*2^32+0x00700067,	-- Bone-Link Fetish,                               	Strength
	[78003] = 0x2410*2^32+0x00100024,	-- Indomitable Pride,                              	Tank
	[86131] = 0x2410*2^32+0x00100024,	-- Vial of Dragon's Blood,                         	Tank
	[86132] = 0x3650*2^32+0x02007700,	-- Bottle of Infinite Stars,                       	Agility
	[86133] = 0x0107*2^32+0x71040000,	-- Light of the Cosmos,                            	Damage, Intellect
	[86144] = 0x0000*2^32+0x00600043,	-- Lei Shen's Final Orders,                        	Damage, Strength
	[86147] = 0x0820*2^32+0x04030010,	-- Qin-xi's Polarizing Seal,                       	Healer
	[86323] = 0x2410*2^32+0x00100024,	-- Stuff of Nightmares,                            	Tank
	[86327] = 0x0820*2^32+0x04030010,	-- Spirits of the Sun,                             	Healer
	[86332] = 0x3650*2^32+0x02007700,	-- Terror in the Mists,                            	Agility
	[86336] = 0x0000*2^32+0x00600043,	-- Darkmist Vortex,                                	Damage, Strength
	[86388] = 0x0107*2^32+0x71040000,	-- Essence of Terror,                              	Damage, Intellect
	[87057] = 0x3650*2^32+0x02007700,	-- Bottle of Infinite Stars,                       	Agility
	[87063] = 0x2410*2^32+0x00100024,	-- Vial of Dragon's Blood,                         	Tank
	[87065] = 0x0107*2^32+0x71040000,	-- Light of the Cosmos,                            	Damage, Intellect
	[87072] = 0x0000*2^32+0x00600043,	-- Lei Shen's Final Orders,                        	Damage, Strength
	[87075] = 0x0820*2^32+0x04030010,	-- Qin-xi's Polarizing Seal,                       	Healer
	[87160] = 0x2410*2^32+0x00100024,	-- Stuff of Nightmares,                            	Tank
	[87163] = 0x0820*2^32+0x04030010,	-- Spirits of the Sun,                             	Healer
	[87167] = 0x3650*2^32+0x02007700,	-- Terror in the Mists,                            	Agility
	[87172] = 0x0000*2^32+0x00600043,	-- Darkmist Vortex,                                	Damage, Strength
	[87175] = 0x0107*2^32+0x71040000,	-- Essence of Terror,                              	Damage, Intellect
	[88294] = 0x3650*2^32+0x02007700,	-- Flashing Steel Talisman,                        	Agility
	[88355] = 0x3650*2^32+0x02007700,	-- Searing Words,                                  	Agility
	[88358] = 0x0000*2^32+0x00700067,	-- Lessons of the Darkmaster,                      	Strength
	[88360] = 0x0820*2^32+0x04030010,	-- Price of Progress,                              	Healer
	[94512] = 0x3650*2^32+0x02007700,	-- Renataki's Soul Charm,                          	Agility
	[94513] = 0x0107*2^32+0x71040000,	-- Wushoolay's Final Choice,                       	Damage, Intellect
	[94514] = 0x0820*2^32+0x04030010,	-- Horridon's Last Gasp,                           	Healer
	[94515] = 0x0000*2^32+0x00600043,	-- Fabled Feather of Ji-Kun,                       	Damage, Strength
	[94516] = 0x2410*2^32+0x00100024,	-- Fortitude of the Zandalari,                     	Tank
	[94518] = 0x2410*2^32+0x00100024,	-- Delicate Vial of the Sanguinaire,               	Tank
	[94519] = 0x0000*2^32+0x00600043,	-- Primordius' Talisman of Rage,                   	Damage, Strength
	[94520] = 0x0820*2^32+0x04030010,	-- Inscribed Bag of Hydra-Spawn,                   	Healer
	[94521] = 0x0107*2^32+0x71040000,	-- Breath of the Hydra,                            	Damage, Intellect
	[94522] = 0x3650*2^32+0x02007700,	-- Talisman of Bloodlust,                          	Agility
	[94523] = 0x3650*2^32+0x02007700,	-- Bad Juju,                                       	Agility
	[94524] = 0x0107*2^32+0x71040000,	-- Unerring Vision of Lei Shen,                    	Damage, Intellect
	[94525] = 0x0820*2^32+0x04030010,	-- Stolen Relic of Zuldazar,                       	Healer
	[94526] = 0x0000*2^32+0x00600043,	-- Spark of Zandalar,                              	Damage, Strength
	[94527] = 0x2410*2^32+0x00100024,	-- Ji-Kun's Rising Winds,                          	Tank
	[94528] = 0x2410*2^32+0x00100024,	-- Soul Barrier,                                   	Tank
	[94529] = 0x0000*2^32+0x00600043,	-- Gaze of the Twins,                              	Damage, Strength
	[94530] = 0x0820*2^32+0x04030010,	-- Lightning-Imbued Chalice,                       	Healer
	[94531] = 0x0107*2^32+0x71040000,	-- Cha-Ye's Essence of Brilliance,                 	Damage, Intellect
	[94532] = 0x3650*2^32+0x02007700,	-- Rune of Re-Origination,                         	Agility
	[96369] = 0x3650*2^32+0x02007700,	-- Renataki's Soul Charm,                          	Agility
	[96385] = 0x0820*2^32+0x04030010,	-- Horridon's Last Gasp,                           	Healer
	[96398] = 0x0000*2^32+0x00600043,	-- Spark of Zandalar,                              	Damage, Strength
	[96409] = 0x3650*2^32+0x02007700,	-- Bad Juju,                                       	Agility
	[96413] = 0x0107*2^32+0x71040000,	-- Wushoolay's Final Choice,                       	Damage, Intellect
	[96421] = 0x2410*2^32+0x00100024,	-- Fortitude of the Zandalari,                     	Tank
	[96455] = 0x0107*2^32+0x71040000,	-- Breath of the Hydra,                            	Damage, Intellect
	[96456] = 0x0820*2^32+0x04030010,	-- Inscribed Bag of Hydra-Spawn,                   	Healer
	[96470] = 0x0000*2^32+0x00600043,	-- Fabled Feather of Ji-Kun,                       	Damage, Strength
	[96471] = 0x2410*2^32+0x00100024,	-- Ji-Kun's Rising Winds,                          	Tank
	[96492] = 0x3650*2^32+0x02007700,	-- Talisman of Bloodlust,                          	Agility
	[96501] = 0x0000*2^32+0x00600043,	-- Primordius' Talisman of Rage,                   	Damage, Strength
	[96507] = 0x0820*2^32+0x04030010,	-- Stolen Relic of Zuldazar,                       	Healer
	[96516] = 0x0107*2^32+0x71040000,	-- Cha-Ye's Essence of Brilliance,                 	Damage, Intellect
	[96523] = 0x2410*2^32+0x00100024,	-- Delicate Vial of the Sanguinaire,               	Tank
	[96543] = 0x0000*2^32+0x00600043,	-- Gaze of the Twins,                              	Damage, Strength
	[96546] = 0x3650*2^32+0x02007700,	-- Rune of Re-Origination,                         	Agility
	[96555] = 0x2410*2^32+0x00100024,	-- Soul Barrier,                                   	Tank
	[96558] = 0x0107*2^32+0x71040000,	-- Unerring Vision of Lei Shen,                    	Damage, Intellect
	[96561] = 0x0820*2^32+0x04030010,	-- Lightning-Imbued Chalice,                       	Healer
	[109995] = 0x3650*2^32+0x02007700,	-- Blood Seal of Azzakel,                          	Agility
	[109996] = 0x3650*2^32+0x02007700,	-- Thundertower's Targeting Reticle,               	Agility
	[109997] = 0x3650*2^32+0x02007700,	-- Kihra's Adrenaline Injector,                    	Agility
	[109998] = 0x3650*2^32+0x02007700,	-- Gor'ashan's Lodestone Spike,                    	Agility
	[109999] = 0x3650*2^32+0x02007700,	-- Witherbark's Branch,                            	Agility
	[110000] = 0x0107*2^32+0x71040000,	-- Crushto's Runic Alarm,                          	Damage, Intellect
	[110001] = 0x0107*2^32+0x71040000,	-- Tovra's Lightning Repository,                   	Damage, Intellect
	[110002] = 0x0107*2^32+0x71040000,	-- Fleshrender's Meathook,                         	Damage, Intellect
	[110003] = 0x0107*2^32+0x71040000,	-- Ragewing's Firefang,                            	Damage, Intellect
	[110004] = 0x0107*2^32+0x71040000,	-- Coagulated Genesaur Blood,                      	Damage, Intellect
	[110005] = 0x0820*2^32+0x04030010,	-- Crystalline Blood Drop,                         	Healer
	[110006] = 0x0820*2^32+0x04030010,	-- Rukhran's Quill,                                	Healer
	[110007] = 0x0820*2^32+0x04030010,	-- Voidmender's Shadowgem,                         	Healer
	[110008] = 0x0820*2^32+0x04030010,	-- Tharbek's Lucky Pebble,                         	Healer
	[110009] = 0x0820*2^32+0x04030010,	-- Leaf of the Ancient Protectors,                 	Healer
	[110010] = 0x0000*2^32+0x00600043,	-- Mote of Corruption,                             	Damage, Strength
	[110011] = 0x0000*2^32+0x00600043,	-- Fires of the Sun,                               	Damage, Strength
	[110012] = 0x0000*2^32+0x00600043,	-- Bonemaw's Big Toe,                              	Damage, Strength
	[110013] = 0x0000*2^32+0x00600043,	-- Emberscale Talisman,                            	Damage, Strength
	[110014] = 0x0000*2^32+0x00600043,	-- Spores of Alacrity,                             	Damage, Strength
	[110015] = 0x0410*2^32+0x00100024,	-- Toria's Unseeing Eye,                           	All Classes?
	[110016] = 0x2410*2^32+0x00100024,	-- Solar Containment Unit,                         	Tank
	[110017] = 0x2410*2^32+0x00100024,	-- Enforcer's Stun Grenade,                        	Tank
	[110018] = 0x2410*2^32+0x00100024,	-- Kyrak's Vileblood Serum,                        	Tank
	[110019] = 0x2410*2^32+0x00100024,	-- Xeri'tac's Unhatched Egg Sac,                   	Tank
	[112426] = 0x0107*2^32+0x71040000,	-- Purified Bindings of Immerseus,                 	Damage, Intellect
	[112476] = 0x2410*2^32+0x00100024,	-- Rook's Unlucky Talisman,                        	Tank
	[112503] = 0x0000*2^32+0x00600043,	-- Fusion-Fire Core,                               	Damage, Strength
	[112703] = 0x0000*2^32+0x00600043,	-- Evil Eye of Galakras,                           	Damage, Strength
	[112729] = 0x2410*2^32+0x00100024,	-- Juggernaut's Focusing Crystal,                  	Tank
	[112754] = 0x1240*2^32+0x02007700,	-- Haromm's Talisman,                              	Damage, Agility
	[112768] = 0x0107*2^32+0x71040000,	-- Kardris' Toxic Totem,                           	Damage, Intellect
	[112778] = 0x0820*2^32+0x04030010,	-- Nazgrim's Burnished Insignia,                   	Healer
	[112792] = 0x2410*2^32+0x00100024,	-- Vial of Living Corruption,                      	Tank
	[112815] = 0x0107*2^32+0x71040000,	-- Frenzied Crystal of Rage,                       	Damage, Intellect
	[112825] = 0x1240*2^32+0x02007700,	-- Sigil of Rampage,                               	Damage, Agility
	[112849] = 0x0820*2^32+0x04030010,	-- Thok's Acid-Grooved Tooth,                      	Healer
	[112850] = 0x0000*2^32+0x00600043,	-- Thok's Tail Tip,                                	Damage, Strength
	[112877] = 0x0820*2^32+0x04030010,	-- Dysmorphic Samophlange of Discontinuity,        	Healer
	[112879] = 0x3650*2^32+0x02007700,	-- Ticking Ebon Detonator,                         	Agility
	[112913] = 0x0000*2^32+0x00600043,	-- Skeer's Bloodsoaked Talisman,                   	Damage, Strength
	[112924] = 0x2410*2^32+0x00100024,	-- Curse of Hubris,                                	Tank
	[112938] = 0x0107*2^32+0x71040000,	-- Black Blood of Y'Shaarj,                        	Damage, Intellect
	[112947] = 0x1240*2^32+0x02007700,	-- Assurance of Consequence,                       	Damage, Agility
	[112948] = 0x0820*2^32+0x04030010,	-- Prismatic Prison of Pride,                      	Healer
	[113612] = 0x1240*2^32+0x02007700,	-- Scales of Doom,                                 	Damage, Agility
	[113645] = 0x0000*2^32+0x00600043,	-- Tectus' Beating Heart,                          	Damage, Strength
	[113650] = 0x2410*2^32+0x00100024,	-- Pillar of the Earth,                            	Tank
	[113658] = 0x0000*2^32+0x00600043,	-- Bottle of Infesting Spores,                     	Damage, Strength
	[113834] = 0x2410*2^32+0x00100024,	-- Pol's Blinded Eye,                              	Tank
	[113835] = 0x0107*2^32+0x71040000,	-- Shards of Nothing,                              	Damage, Intellect
	[113842] = 0x0820*2^32+0x04030010,	-- Emblem of Caustic Healing,                      	Healer
	[113853] = 0x1240*2^32+0x02007700,	-- Captive Micro-Aberration,                       	Damage, Agility
	[113854] = 0x0820*2^32+0x04030010,	-- Mark of Rapid Replication,                      	Healer
	[113859] = 0x0107*2^32+0x71040000,	-- Quiescent Runestone,                            	Damage, Intellect
	[113861] = 0x2410*2^32+0x00100024,	-- Evergaze Arcane Eidolon,                        	Tank
	[113889] = 0x0820*2^32+0x04030010,	-- Elementalist's Shielding Talisman,              	Healer
	[113893] = 0x2410*2^32+0x00100024,	-- Blast Furnace Door,                             	Tank
	[113905] = 0x2410*2^32+0x00100024,	-- Tablet of Turnbuckle Teamwork,                  	Tank
	[113931] = 0x1240*2^32+0x02007700,	-- Beating Heart of the Mountain,                  	Damage, Agility
	[113948] = 0x0107*2^32+0x71040000,	-- Darmac's Unstable Talisman,                     	Damage, Intellect
	[113969] = 0x0000*2^32+0x00600043,	-- Vial of Convulsive Shadows,                     	Damage, Strength
	[113983] = 0x0000*2^32+0x00600043,	-- Forgemaster's Insignia,                         	Damage, Strength
	[113984] = 0x0107*2^32+0x71040000,	-- Blackiron Micro Crucible,                       	Damage, Intellect
	[113985] = 0x1240*2^32+0x02007700,	-- Humming Blackiron Trigger,                      	Damage, Agility
	[113986] = 0x0820*2^32+0x04030010,	-- Auto-Repairing Autoclave,                       	Healer
	[113987] = 0x2410*2^32+0x00100024,	-- Battering Talisman,                             	Tank
	[116289] = 0x3240*2^32+0x02007700,	-- Bloodmaw's Tooth,                               	Agility?
	[116290] = 0x0107*2^32+0x71040000,	-- Emblem of Gushing Wounds,                       	Damage, Intellect
	[116291] = 0x0820*2^32+0x04030010,	-- Immaculate Living Mushroom,                     	Healer
	[116292] = 0x0000*2^32+0x00600043,	-- Mote of the Mountain,                           	Damage, Strength
	[116293] = 0x2410*2^32+0x00100024,	-- Idol of Suppression,                            	Tank
	[116314] = 0x3240*2^32+0x02007700,	-- Blackheart Enforcer's Medallion,                	Agility?
	[116315] = 0x0107*2^32+0x71040000,	-- Furyheart Talisman,                             	Damage, Intellect
	[116316] = 0x0820*2^32+0x04030010,	-- Captured Flickerspark,                          	Healer
	[116317] = 0x0000*2^32+0x00600043,	-- Storage House Key,                              	Damage, Strength
	[116318] = 0x2410*2^32+0x00100024,	-- Stoneheart Idol,                                	Tank
	[118114] = 0x1240*2^32+0x02007700,	-- Meaty Dragonspine Trophy,                       	Damage, Agility
	[119192] = 0x0820*2^32+0x04030010,	-- Ironspike Chew Toy,                             	Healer
	[119193] = 0x0000*2^32+0x00600043,	-- Horn of Screaming Spirits,                      	Damage, Strength
	[119194] = 0x0107*2^32+0x71040000,	-- Goren Soul Repository,                          	Damage, Intellect
	[123992] = 0x0000*2^32+0x00000024,	-- Figurine of the Colossus,                       	Tank, Block
	[124223] = 0x1240*2^32+0x02007700,	-- Fel-Spring Coil,                                	Damage, Agility
	[124224] = 0x1240*2^32+0x02007700,	-- Mirror of the Blademaster,                      	Damage, Agility
	[124225] = 0x1240*2^32+0x02007400,	-- Soul Capacitor,                                 	Damage, Melee, Agility
	[124226] = 0x1240*2^32+0x02007700,	-- Malicious Censer,                               	Damage, Agility
	[124227] = 0x0107*2^32+0x71040000,	-- Iron Reaver Piston,                             	Damage, Intellect
	[124228] = 0x0107*2^32+0x71040000,	-- Desecrated Shadowmoon Insignia,                 	Damage, Intellect
	[124229] = 0x0107*2^32+0x71040000,	-- Unblinking Gaze of Sethe,                       	Damage, Intellect
	[124230] = 0x0106*2^32+0x71040000,	-- Prophecy of Fear,                               	Damage, Intellect
	[124231] = 0x0820*2^32+0x04030010,	-- Flickering Felspark,                            	Healer
	[124232] = 0x0820*2^32+0x04030010,	-- Intuition's Gift,                               	Healer
	[124233] = 0x0820*2^32+0x04030010,	-- Demonic Phylactery,                             	Healer
	[124234] = 0x0820*2^32+0x04030010,	-- Unstable Felshadow Emulsion,                    	Healer
	[124235] = 0x0000*2^32+0x00600043,	-- Rumbling Pebble,                                	Damage, Strength
	[124236] = 0x0000*2^32+0x00600043,	-- Unending Hunger,                                	Damage, Strength
	[124237] = 0x0000*2^32+0x00600043,	-- Discordant Chorus,                              	Damage, Strength
	[124238] = 0x0000*2^32+0x00600043,	-- Empty Drinking Horn,                            	Damage, Strength
	[124239] = 0x2410*2^32+0x00100024,	-- Imbued Stone Sigil,                             	Tank
	[124240] = 0x2410*2^32+0x00100024,	-- Warlord's Unseeing Eye,                         	Tank
	[124241] = 0x2410*2^32+0x00100024,	-- Anzu's Cursed Plume,                            	Tank
	[124242] = 0x2410*2^32+0x00100024,	-- Tyrant's Decree,                                	Tank
	[124513] = 0x0000*2^32+0x00700000,	-- Reaper's Harvest,                               	Death Knight
	[124514] = 0x0F00*2^32+0x00000000,	-- Seed of Creation,                               	Druid
	[124515] = 0x0000*2^32+0x00000700,	-- Talisman of the Master Tracker,                 	Hunter
	[124516] = 0x0000*2^32+0x70000000,	-- Tome of Shifting Words,                         	Mage
	[124517] = 0x0070*2^32+0x00000000,	-- Sacred Draenic Incense,                         	Monk
	[124518] = 0x0000*2^32+0x00000070,	-- Libram of Vindication,                          	Paladin
	[124519] = 0x0000*2^32+0x00070000,	-- Repudiation of War,                             	Priest
	[124520] = 0x0000*2^32+0x00007000,	-- Bleeding Hollow Toxin Vessel,                   	Rogue
	[124521] = 0x0000*2^32+0x07000000,	-- Core of the Primal Elements,                    	Shaman
	[124522] = 0x0007*2^32+0x00000000,	-- Fragment of the Dark Star,                      	Warlock
	[124523] = 0x0000*2^32+0x00000007,	-- Worldbreaker's Resolve,                         	Warrior
	[124545] = 0x3F77*2^32+0x77777777,	-- Chipped Soul Prism,                             	All Classes
	[124546] = 0x3F77*2^32+0x77777777,	-- Mark of Supreme Doom,                           	All Classes
	[127173] = 0x0927*2^32+0x75070010,	-- Shiffar's Nexus-Horn,                           	Intellect
	[127184] = 0x2410*2^32+0x00100024,	-- Runed Fungalcap,                                	Tank
	[127201] = 0x0107*2^32+0x71050000,	-- Quagmirran's Eye,                               	Damage, Intellect
	[127245] = 0x0927*2^32+0x75070010,	-- Warp-Scarab Brooch,                             	Intellect
	[127441] = 0x1240*2^32+0x02607743,	-- Hourglass of the Unraveller,                    	Damage, Strength/Agility
	[127448] = 0x0820*2^32+0x04030010,	-- Scarab of the Infinite Cycle,                   	Healer
	[127474] = 0x1240*2^32+0x02607743,	-- Vestige of Haldor,                              	Damage, Strength/Agility
	[127493] = 0x1240*2^32+0x02607743,	-- Meteorite Whetstone,                            	Damage, Strength/Agility
	[127512] = 0x0927*2^32+0x75070010,	-- Winged Talisman,                                	Intellect
	[127550] = 0x2410*2^32+0x00100024,	-- Offering of Sacrifice,                          	Tank
	[127594] = 0x1240*2^32+0x02607743,	-- Sphere of Red Dragon's Blood,                   	Damage, Strength/Agility
	[128140] = 0x3650*2^32+0x02007700,	-- Smoldering Felblade Remnant,                    	Agility
	[128141] = 0x0927*2^32+0x75070010,	-- Crackling Fel-Spark Plug,                       	Intellect
	[128142] = 0x0927*2^32+0x75070010,	-- Pledge of Iron Loyalty,                         	Intellect
	[128143] = 0x0000*2^32+0x00700067,	-- Fragmented Runestone Etching,                   	Strength
	[128144] = 0x3650*2^32+0x02707767,	-- Vial of Vile Viscera,                           	Strength/Agility
	[128145] = 0x3650*2^32+0x02007700,	-- Howling Soul Gem,                               	Agility
	[128146] = 0x0927*2^32+0x75070010,	-- Ensnared Orb of the Sky,                        	Intellect
	[128147] = 0x0927*2^32+0x75070010,	-- Teardrop of Blood,                              	Intellect
	[128148] = 0x0000*2^32+0x00700067,	-- Fetid Salivation,                               	Strength
	[128149] = 0x3650*2^32+0x02707767,	-- Accusation of Inferiority,                      	Strength/Agility
	[128150] = 0x3650*2^32+0x02007700,	-- Pressure-Compressed Loop,                       	Agility
	[128151] = 0x0927*2^32+0x75070010,	-- Portent of Disaster,                            	Intellect
	[128152] = 0x0927*2^32+0x75070010,	-- Decree of Demonic Sovereignty,                  	Intellect
	[128153] = 0x0000*2^32+0x00700067,	-- Unquenchable Doomfire Censer,                   	Strength
	[128154] = 0x3650*2^32+0x02707767,	-- Grasp of the Defiler,                           	Strength/Agility
	[133192] = 0x3650*2^32+0x02107467,	-- Porcelain Crab,                                 	Melee?
	[133197] = 0x0000*2^32+0x00600043,	-- Might of the Ocean,                             	Damage, Strength
	[133201] = 0x0927*2^32+0x75070010,	-- Sea Star,                                       	Intellect
	[133206] = 0x1240*2^32+0x02007700,	-- Key to the Endless Chamber,                     	Damage, Agility
	[133216] = 0x0927*2^32+0x75070010,	-- Tendrils of Burrowing Dark,                     	Intellect
	[133222] = 0x0000*2^32+0x00600043,	-- Magnetite Mirror,                               	Damage, Strength
	[133224] = 0x2410*2^32+0x00100024,	-- Leaden Despair,                                 	Tank
	[133227] = 0x0820*2^32+0x04030010,	-- Tear of Blood,                                  	Healer
	[133246] = 0x2410*2^32+0x00100024,	-- Heart of Thunder,                               	Tank
	[133252] = 0x0820*2^32+0x04030010,	-- Rainsong,                                       	Healer
	[133268] = 0x0000*2^32+0x00600043,	-- Heart of Solace,                                	Damage, Strength
	[133269] = 0x1240*2^32+0x02007700,	-- Tia's Grace,                                    	Damage, Agility
	[133275] = 0x0107*2^32+0x71050000,	-- Sorrowsong,                                     	Damage, Intellect
	[133281] = 0x2010*2^32+0x00100024,	-- Impetuous Query,                                	Tank, Parry
	[133282] = 0x1240*2^32+0x02007700,	-- Skardyn's Grace,                                	Damage, Agility
	[133291] = 0x2010*2^32+0x00100024,	-- Throngus's Finger,                              	Tank, Parry
	[133300] = 0x0000*2^32+0x00600043,	-- Mark of Khardros,                               	Damage, Strength
	[133304] = 0x0927*2^32+0x75070010,	-- Gale of Shadows,                                	Intellect
	[133305] = 0x0820*2^32+0x04030010,	-- Corrupted Egg Shell,                            	Healer
	[133420] = 0x1240*2^32+0x02007700,	-- Arrow of Time,                                  	Damage, Agility
	[133461] = 0x0107*2^32+0x71050000,	-- Timbal's Focusing Crystal,                      	Damage, Intellect
	[133462] = 0x0820*2^32+0x04030010,	-- Vial of the Sunwell,                            	Healer
	[133463] = 0x1240*2^32+0x02607743,	-- Shard of Contempt,                              	Damage, Strength/Agility
	[133464] = 0x2410*2^32+0x00100024,	-- Commendation of Kael'thas,                      	Tank
	[133641] = 0x0107*2^32+0x71050300,	-- Eye of Skovald,                                 	Damage, Ranged
	[133642] = 0x3F77*2^32+0x77777777,	-- Horn of Valor,                                  	All Classes
	[133644] = 0x1240*2^32+0x02607443,	-- Memento of Angerboda,                           	Damage, Melee
	[133645] = 0x0820*2^32+0x04030010,	-- Naglfar Fare,                                   	Healer
	[133646] = 0x0820*2^32+0x04030010,	-- Mote of Sanctification,                         	Healer
	[133647] = 0x2410*2^32+0x00100024,	-- Gift of Radiance,                               	Tank
	[133766] = 0x0820*2^32+0x04030010,	-- Nether Anti-Toxin,                              	Healer
	[136714] = 0x0820*2^32+0x04030010,	-- Amalgam's Seventh Spine,                        	Healer
	[136715] = 0x1240*2^32+0x02607443,	-- Spiked Counterweight,                           	Damage, Melee
	[136716] = 0x0107*2^32+0x71050300,	-- Caged Horror,                                   	Damage, Ranged
	[136975] = 0x1240*2^32+0x02607443,	-- Hunger of the Pack,                             	Damage, Melee
	[136978] = 0x2410*2^32+0x00100024,	-- Ember of Nullification,                         	Tank
	[137301] = 0x0107*2^32+0x71050000,	-- Corrupted Starlight,                            	Damage, Intellect
	[137306] = 0x0107*2^32+0x71050300,	-- Oakheart's Gnarled Root,                        	Damage, Ranged
	[137312] = 0x1240*2^32+0x02607443,	-- Nightmare Egg Shell,                            	Damage, Melee
	[137315] = 0x2410*2^32+0x00100024,	-- Writhing Heart of Darkness,                     	Tank
	[137329] = 0x0107*2^32+0x71050300,	-- Figurehead of the Naglfar,                      	Damage, Ranged
	[137338] = 0x2410*2^32+0x00100024,	-- Shard of Rokmora,                               	Tank
	[137344] = 0x2410*2^32+0x00100024,	-- Talisman of the Cragshaper,                     	Tank
	[137349] = 0x0107*2^32+0x71050300,	-- Naraxas' Spiked Tongue,                         	Damage, Ranged
	[137357] = 0x1240*2^32+0x02607443,	-- Mark of Dargrul,                                	Damage, Melee
	[137362] = 0x2410*2^32+0x00100024,	-- Parjesh's Medallion,                            	Tank
	[137367] = 0x0107*2^32+0x71050300,	-- Stormsinger Fulmination Charge,                 	Damage, Ranged
	[137369] = 0x1240*2^32+0x02607443,	-- Giant Ornamental Pearl,                         	Damage, Melee
	[137373] = 0x1240*2^32+0x02007700,	-- Tempered Egg of Serpentrix,                     	Damage, Agility
	[137378] = 0x0820*2^32+0x04030010,	-- Bottled Hurricane,                              	Healer
	[137398] = 0x0107*2^32+0x71050000,	-- Portable Manacracker,                           	Damage, Intellect
	[137400] = 0x2410*2^32+0x00100024,	-- Coagulated Nightwell Residue,                   	Tank
	[137406] = 0x1240*2^32+0x02607443,	-- Terrorbound Nexus,                              	Damage, Melee
	[137419] = 0x3F77*2^32+0x77777777,	-- Chrono Shard,                                   	All Classes
	[137430] = 0x2410*2^32+0x00100024,	-- Impenetrable Nerubian Husk,                     	Tank
	[137433] = 0x0927*2^32+0x75070310,	-- Obelisk of the Void,                            	Agility/Intellect?
	[137439] = 0x1240*2^32+0x02607443,	-- Tiny Oozeling in a Jar,                         	Damage, Melee
	[137440] = 0x2410*2^32+0x00100024,	-- Shivermaw's Jawbone,                            	Tank
	[137446] = 0x0107*2^32+0x71050300,	-- Elementium Bomb Squirrel Generator,             	Damage, Ranged
	[137452] = 0x0820*2^32+0x04030010,	-- Thrumming Gossamer,                             	Healer
	[137459] = 0x1240*2^32+0x02607443,	-- Chaos Talisman,                                 	Damage, Melee
	[137462] = 0x0820*2^32+0x04030010,	-- Jewel of Insatiable Desire,                     	Healer
	[137484] = 0x0820*2^32+0x04030010,	-- Flask of the Solemn Night,                      	Healer
	[137485] = 0x0107*2^32+0x71050000,	-- Infernal Writ,                                  	Damage, Intellect
	[137486] = 0x1240*2^32+0x02607443,	-- Windscar Whetstone,                             	Damage, Melee
	[137537] = 0x1240*2^32+0x02007700,	-- Tirathon's Betrayal,                            	Damage, Agility
	[137538] = 0x2410*2^32+0x00100024,	-- Orb of Torment,                                 	Tank
	[137539] = 0x1240*2^32+0x02607443,	-- Faulty Countermeasure,                          	Damage, Melee
	[137540] = 0x0820*2^32+0x04030010,	-- Concave Reflecting Lens,                        	Healer
	[137541] = 0x0107*2^32+0x71050300,	-- Moonlit Prism,                                  	Damage, Ranged
	[138222] = 0x0820*2^32+0x04030010,	-- Vial of Nightmare Fog,                          	Healer
	[138224] = 0x0107*2^32+0x71050300,	-- Unstable Horrorslime,                           	Damage, Ranged
	[138225] = 0x2410*2^32+0x00100024,	-- Phantasmal Echo,                                	Tank
	[139320] = 0x1240*2^32+0x02607443,	-- Ravaged Seed Pod,                               	Damage, Melee
	[139321] = 0x0107*2^32+0x73050000,	-- Swarming Plaguehive,                            	Damage, Intellect?
	[139322] = 0x0820*2^32+0x04030010,	-- Cocoon of Enforced Solitude,                    	Healer
	[139323] = 0x0107*2^32+0x71050300,	-- Twisting Wind,                                  	Damage, Ranged
	[139324] = 0x2410*2^32+0x00100024,	-- Goblet of Nightmarish Ichor,                    	Tank
	[139325] = 0x1240*2^32+0x02607443,	-- Spontaneous Appendages,                         	Damage, Melee
	[139326] = 0x0107*2^32+0x71050000,	-- Wriggling Sinew,                                	Damage, Intellect
	[139327] = 0x2410*2^32+0x00100024,	-- Unbridled Fury,                                 	Tank
	[139328] = 0x0000*2^32+0x00600043,	-- Ursoc's Rending Paw,                            	Damage, Strength
	[139329] = 0x1240*2^32+0x02007700,	-- Bloodthirsty Instinct,                          	Damage, Agility
	[139330] = 0x0820*2^32+0x04030010,	-- Heightened Senses,                              	Healer
	[139333] = 0x0820*2^32+0x04030010,	-- Horn of Cenarius,                               	Healer
	[139334] = 0x1240*2^32+0x02607443,	-- Nature's Call,                                  	Damage, Melee
	[139335] = 0x2410*2^32+0x00100024,	-- Grotesque Statuette,                            	Tank
	[139336] = 0x0107*2^32+0x71050000,	-- Bough of Corruption,                            	Damage, Intellect
	[139630] = 0x3000*2^32+0x00000000,	-- Etching of Sargeras,                            	Demon Hunter
	[140789] = 0x2410*2^32+0x00100024,	-- Animated Exoskeleton,                           	Tank
	[140790] = 0x0000*2^32+0x00600043,	-- Claw of the Crystalline Scorpid,                	Damage, Strength
	[140791] = 0x2410*2^32+0x00100024,	-- Royal Dagger Haft,                              	Tank
	[140792] = 0x0107*2^32+0x71050000,	-- Erratic Metronome,                              	Damage, Intellect
	[140793] = 0x0820*2^32+0x04030010,	-- Perfectly Preserved Cake,                       	Healer
	[140794] = 0x1240*2^32+0x02007400,	-- Arcanogolem Digit,                              	Damage, Melee, Agility
	[140795] = 0x0820*2^32+0x04030010,	-- Aluriel's Mirror,                               	Healer
	[140796] = 0x1240*2^32+0x02607743,	-- Entwined Elemental Foci,                        	Damage, Strength/Agility
	[140797] = 0x2410*2^32+0x00100024,	-- Fang of Tichondrius,                            	Tank
	[140798] = 0x0107*2^32+0x71050300,	-- Icon of Rot,                                    	Damage, Ranged
	[140799] = 0x0000*2^32+0x00600043,	-- Might of Krosus,                                	Damage, Strength
	[140800] = 0x0107*2^32+0x71050000,	-- Pharamere's Forbidden Grimoire,                 	Damage, Intellect
	[140801] = 0x0107*2^32+0x71050300,	-- Fury of the Burning Sky,                        	Damage, Ranged
	[140802] = 0x1240*2^32+0x02007700,	-- Nightblooming Frond,                            	Damage, Agility
	[140803] = 0x0820*2^32+0x04030010,	-- Etraeus' Celestial Map,                         	Healer
	[140804] = 0x0107*2^32+0x71050000,	-- Star Gate,                                      	Damage, Intellect
	[140805] = 0x0820*2^32+0x04030010,	-- Ephemeral Paradox,                              	Healer
	[140806] = 0x1240*2^32+0x02607743,	-- Convergence of Fates,                           	Damage, Strength/Agility
	[140807] = 0x2410*2^32+0x00100024,	-- Infernal Contract,                              	Tank
	[140808] = 0x1240*2^32+0x02607443,	-- Draught of Souls,                               	Damage, Melee
	[140809] = 0x0107*2^32+0x71050000,	-- Whispers in the Dark,                           	Damage, Intellect
	[141482] = 0x3F77*2^32+0x77777777,	-- Unstable Arcanocrystal,                         	All Classes
	[141535] = 0x0000*2^32+0x00700067,	-- Ettin Fingernail,                               	Strength
	[141536] = 0x0927*2^32+0x75070010,	-- Padawsen's Unlucky Charm,                       	Intellect
	[141537] = 0x3650*2^32+0x02007700,	-- Thrice-Accursed Compass,                        	Agility
	[142157] = 0x0107*2^32+0x71050300,	-- Aran's Relaxing Ruby,                           	Damage, Ranged
	[142158] = 0x0820*2^32+0x04030010,	-- Faith's Crucible,                               	Healer
	[142159] = 0x1240*2^32+0x02607443,	-- Bloodstained Handkerchief,                      	Damage, Melee
	[142160] = 0x0107*2^32+0x71050300,	-- Mrrgria's Favor,                                	Damage, Ranged
	[142161] = 0x2410*2^32+0x00100024,	-- Inescapable Dread,                              	Tank
	[142162] = 0x0820*2^32+0x04030010,	-- Fluctuating Energy,                             	Healer
	[142164] = 0x1240*2^32+0x02607443,	-- Toe Knee's Promise,                             	Damage, Melee
	[142165] = 0x0107*2^32+0x71050300,	-- Deteriorated Construct Core,                    	Damage, Ranged
	[142167] = 0x1240*2^32+0x02607443,	-- Eye of Command,                                 	Damage, Melee
	[142168] = 0x2410*2^32+0x00100024,	-- Majordomo's Dinner Bell,                        	Tank
	[142169] = 0x2410*2^32+0x00100024,	-- Raven Eidolon,                                  	Tank
	[142506] = 0x3650*2^32+0x02007700,	-- Eye of Guarm,                                   	Agility
	[142507] = 0x0927*2^32+0x75070010,	-- Brinewater Slime in a Bottle,                   	Intellect
	[142508] = 0x0000*2^32+0x00700067,	-- Chains of the Valorous,                         	Strength
	[144113] = 0x3650*2^32+0x02007700,	-- Windswept Pages,                                	Agility
	[144119] = 0x0927*2^32+0x75070010,	-- Empty Fruit Barrel,                             	Intellect
	[144122] = 0x0000*2^32+0x00700067,	-- Carbonic Carbuncle,                             	Strength
	[144128] = 0x2410*2^32+0x00100024,	-- Heart of Fire,                                  	Tank
	[144136] = 0x0927*2^32+0x75070010,	-- Vision of the Predator,                         	Intellect
	[144146] = 0x2410*2^32+0x00100024,	-- Iron Protector Talisman,                        	Tank
	[144156] = 0x0927*2^32+0x75070010,	-- Flashfrozen Resin Globule,                      	Intellect
	[144157] = 0x0927*2^32+0x75070010,	-- Vial of Ichorous Blood,                         	Intellect
	[144158] = 0x3F77*2^32+0x77777777,	-- Flashing Steel Talisman,                        	All Classes
	[144159] = 0x0927*2^32+0x75070010,	-- Price of Progress,                              	Intellect
	[144160] = 0x3650*2^32+0x02007700,	-- Searing Words,                                  	Agility
	[144161] = 0x0000*2^32+0x00700067,	-- Lessons of the Darkmaster,                      	Strength
	[144477] = 0x1240*2^32+0x02007700,	-- Splinters of Agronox,                           	Damage, Agility
	[144480] = 0x0927*2^32+0x75070010,	-- Dreadstone of Endless Shadows,                  	Intellect
	[144482] = 0x0000*2^32+0x00700067,	-- Fel-Oiled Infernal Machine,                     	Strength
	[147002] = 0x0927*2^32+0x75070010,	-- Charm of the Rising Tide,                       	Intellect
	[147003] = 0x0820*2^32+0x04030010,	-- Barbaric Mindslaver,                            	Healer
	[147004] = 0x0820*2^32+0x04030010,	-- Sea Star of the Depthmother,                    	Healer
	[147005] = 0x0820*2^32+0x04030010,	-- Chalice of Moonlight,                           	Healer
	[147006] = 0x0820*2^32+0x04030010,	-- Archive of Faith,                               	Healer
	[147007] = 0x0820*2^32+0x04030010,	-- The Deceiver's Grand Design,                    	Healer
	[147009] = 0x1240*2^32+0x02607443,	-- Infernal Cinders,                               	Damage, Melee
	[147010] = 0x1240*2^32+0x02607743,	-- Cradle of Anguish,                              	Damage, Strength/Agility
	[147011] = 0x1240*2^32+0x02607443,	-- Vial of Ceaseless Toxins,                       	Damage, Melee
	[147012] = 0x1240*2^32+0x02607443,	-- Umbral Moonglaives,                             	Damage, Melee
	[147015] = 0x1240*2^32+0x02607743,	-- Engine of Eradication,                          	Damage, Strength/Agility
	[147016] = 0x0107*2^32+0x71050300,	-- Terror From Below,                              	Damage, Ranged
	[147017] = 0x0107*2^32+0x71050300,	-- Tarnished Sentinel Medallion,                   	Damage, Ranged
	[147018] = 0x0107*2^32+0x71050300,	-- Spectral Thurible,                              	Damage, Ranged
	[147019] = 0x0107*2^32+0x71050300,	-- Tome of Unraveling Sanity,                      	Damage, Ranged
	[147022] = 0x2410*2^32+0x00100024,	-- Feverish Carapace,                              	Tank
	[147023] = 0x2410*2^32+0x00100024,	-- Leviathan's Hunger,                             	Tank
	[147024] = 0x2410*2^32+0x00100024,	-- Reliquary of the Damned,                        	Tank
	[147025] = 0x2410*2^32+0x00100024,	-- Recompiled Guardian Module,                     	Tank
	[147026] = 0x2410*2^32+0x00100024,	-- Shifting Cosmic Sliver,                         	Tank
	[150522] = 0x0107*2^32+0x71040000,	-- The Skull of Gul'dan,                           	Damage, Intellect
	[150523] = 0x0820*2^32+0x04030010,	-- Memento of Tyrande,                             	Healer
	[150526] = 0x3650*2^32+0x02707767,	-- Shadowmoon Insignia,                            	Strength/Agility
	[150527] = 0x3650*2^32+0x02707767,	-- Madness of the Betrayer,                        	Strength/Agility
	[151190] = 0x1240*2^32+0x02607443,	-- Specter of Betrayal,                            	Damage, Melee
	[151307] = 0x1240*2^32+0x02607743,	-- Void Stalker's Contract,                        	Damage, Strength/Agility
	[151310] = 0x0107*2^32+0x71050000,	-- Reality Breacher,                               	Damage, Intellect
	[151312] = 0x2410*2^32+0x00100024,	-- Ampoule of Pure Void,                           	Tank
	[151340] = 0x0820*2^32+0x04030010,	-- Echo of L'ura,                                  	Healer
	[151955] = 0x0107*2^32+0x71050000,	-- Acrid Catalyst Injector,                        	Damage, Intellect
	[151956] = 0x0820*2^32+0x04030010,	-- Garothi Feedback Conduit,                       	Healer
	[151957] = 0x0820*2^32+0x04030010,	-- Ishkar's Felshield Emitter,                     	Healer
	[151958] = 0x0820*2^32+0x04030010,	-- Tarratus Keystone,                              	Healer
	[151960] = 0x0820*2^32+0x04030010,	-- Carafe of Searing Light,                        	Healer
	[151962] = 0x0107*2^32+0x71050300,	-- Prototype Personnel Decimator,                  	Damage, Ranged
	[151963] = 0x1240*2^32+0x02607743,	-- Forgefiend's Fabricator,                        	Damage, Strength/Agility
	[151964] = 0x1240*2^32+0x02607443,	-- Seeping Scourgewing,                            	Damage, Melee
	[151968] = 0x1240*2^32+0x02607743,	-- Shadow-Singed Fang,                             	Damage, Strength/Agility
	[151969] = 0x0107*2^32+0x71050300,	-- Terminus Signaling Beacon,                      	Damage, Ranged
	[151970] = 0x0927*2^32+0x75070010,	-- Vitality Resonator,                             	Intellect
	[151971] = 0x0107*2^32+0x71050000,	-- Sheath of Asara,                                	Damage, Intellect
	[151974] = 0x2410*2^32+0x00100024,	-- Eye of Shatug,                                  	Tank	
	[151975] = 0x2410*2^32+0x00100024,	-- Apocalypse Drive,                               	Tank
	[151976] = 0x2410*2^32+0x00100024,	-- Riftworld Codex,                                	Tank
	[151977] = 0x2410*2^32+0x00100024,	-- Diima's Glacial Aegis,                          	Tank
	[151978] = 0x2410*2^32+0x00100024,	-- Smoldering Titanguard,                          	Tank
	[152093] = 0x1240*2^32+0x02607443,	-- Gorshalach's Legacy,                            	Damage, Melee
	[152289] = 0x0820*2^32+0x04030010,	-- Highfather's Machination,                       	Healer
	[152645] = 0x2410*2^32+0x00100024,	-- Eye of Shatug,                                  	Tank
	[153544] = 0x2410*2^32+0x00100024,	-- Eye of F'harg,                                  	Tank
	[154172] = 0x3F77*2^32+0x77777777,	-- Aman'Thul's Vision,                             	All Classes
	[154173] = 0x2410*2^32+0x00100024,	-- Aggramar's Conviction,                          	Tank
	[154174] = 0x1240*2^32+0x02007700,	-- Golganneth's Vitality,                          	Damage, Agility
	[154175] = 0x0820*2^32+0x04030010,	-- Eonar's Compassion,                             	Healer
	[154176] = 0x0000*2^32+0x00600043,	-- Khaz'goroth's Courage,                          	Damage, Strength
	[154177] = 0x0107*2^32+0x71050000,	-- Norgannon's Prowess,                            	Damage, Intellect
}
