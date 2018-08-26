--- trinketData.lua
-- Contains loot specs of all trinkets in the dungeon journal
-- @author Safetee
-- Create Date : 12/03/2017
-- Update Date : 25/8/2018 (8.0.1 Build 27404)


local ZERO = ""
for i=1, GetNumClasses() do
	ZERO = "0"..ZERO -- "000000000000"
end
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
local trinketSpecs = {
	[151974] = "241000100024",	-- Manually added, because the item id of actual item does not match item id in EJ
}
local trinketNames = {
	[151974] = "Eye of",
}

-- The params are used internally inside this function
-- Process in the following order:
-- From expansion vanilla to the latest expansion (nextTier)
-- Inside each expansion, scan dungeon first then raid (nextIsRaid)
-- Inside dungeon/raid, scan by its index in the journal (nextIndex)
-- Inside each instance, scan by difficulty id order(nextDiffID)
function RCLootCouncil:ExportTrinketData(nextTier, nextIsRaid, nextIndex, nextDiffID)
	LoadAddOn("BLizzard_EncounterJournal")
	local MAX_CLASSFLAG_VAL = bit.lshift(1, GetNumClasses()) - 1
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
		exports = exports.."\t["..entry[1].."] = "..format("%q", entry[2])
			..",\t-- "..format(exp, trinketNames[entry[1]]..",").."\t"..(_G.RCTrinketCategories[entry[2]] or "").."\n"
	end
	exports = exports.."}\n"
	frame.exportFrame.edit:SetText(exports)
end

function RCLootCouncil:ClassesFlagToStr(flag)
	local text = ""
	for i=1, GetNumClasses() do
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

	EJ_SetLootFilter(0, 0)
    for j = 1, EJ_GetNumLoot() do -- EJ_GetNumLoot() can be 0 if EJ items are not cached.
        local id, _, _, _, _, _, link = EJ_GetLootInfoByIndex(j)
        if link then
	        trinketSpecs[id] = ZERO
	        trinketNames[id] = self:GetItemNameFromLink(link)
	        GetItemInfo(id)
	        count = count + 1
	        tinsert(trinketlinksInThisInstances, link)
	    end
	end

	for classID = 1, GetNumClasses() do
	    for specIndex=1, GetNumSpecializationsForClassID(classID) do
	    	EJ_SetLootFilter(classID, GetSpecializationInfoForClassID(classID, specIndex))
		    for j = 1, EJ_GetNumLoot() do -- EJ_GetNumLoot() can be 0 if EJ items are not cached.
		        local id, _, _, _, _, _, link = EJ_GetLootInfoByIndex(j)
		        if link then
		        	local digit = tonumber(trinketSpecs[id]:sub(-classID, -classID), 16)
		        	digit = digit + 2^(specIndex-1)
		        	trinketSpecs[id] = trinketSpecs[id]:sub(1, GetNumClasses()-classID)..format("%X", digit)..trinketSpecs[id]:sub(GetNumClasses()-classID+2, GetNumClasses())
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
			self:Print(format("%s(%d): %s", link, id, trinketSpecs[id]))
		end
		self:Print("--------------------")
	end
end
--@end-debug@

-- Trinket categories description according to specs that can loot the trinket.
-- These categories should cover all trinkets in the Encounter Journal. Add more if any trinket is missing category.
_G.RCTrinketCategories = {
	["3F7777777777"] = ALL_CLASSES, -- All Classes
	["365002707767"] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT, -- Strength/Agility
	["000000700067"] = ITEM_MOD_STRENGTH_SHORT, -- Strength
	["365002707467"] = MELEE, -- Melee
	["3F7777077710"] = ITEM_MOD_AGILITY_SHORT.."/"..ITEM_MOD_INTELLECT_SHORT, -- Agility/Intellect
	["365002007700"] = ITEM_MOD_AGILITY_SHORT, -- Agility
	["092775070010"] = ITEM_MOD_INTELLECT_SHORT, -- Intellect
	["241000100024"] = TANK, -- Tank
	["000000000024"] = TANK..", "..BLOCK, -- Tank, Block (Warrior, Paladin)
	["201000100024"] = TANK..", "..PARRY, -- Tank, Parry (Non-Druid)
	["082004030010"] = HEALER, -- Healer
	["124002607743"] = DAMAGER..", "..ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT, -- Damage, Strength/Agility
	["000000600043"] = DAMAGER..", "..ITEM_MOD_STRENGTH_SHORT, -- Damage, Strength
	["124002007700"] = DAMAGER..", "..ITEM_MOD_AGILITY_SHORT, -- Damage, Agility
	["124002607443"] = DAMAGER..", "..MELEE, -- Damage, Melee
	["124002007400"] = DAMAGER..", "..MELEE..", "..ITEM_MOD_AGILITY_SHORT, -- Damage, Melee, Agility
	["010771050300"] = DAMAGER..", "..RANGED, -- Damage, Ranged
	["010771050000"] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect
	["010671040000"] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect (direct damage, no affliction warlock and shadow priest)
	["010771040000"] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect (no discipline)

	-- The following categories does not make sense. Most likely a Blizzard error in the Encounter Journal for several old trinkets.
	-- Add "?" as a suffix to the description as the result
	["041000100024"] = ALL_CLASSES.."?", -- All Classes?
	["365002107467"] = MELEE.."?", -- Melee? （Missing Frost and Unholy DK)
	["241000100044"] = TANK.."?", -- Tank? (Ret instead of Pro?)
	["124002607703"] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT.."?", -- Strength/Agility?
	["367002707767"] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT.."?", -- Strength/Agility?
	["324001607743"] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT.."?", -- Strength/Agility?
	["324002007700"] = ITEM_MOD_AGILITY_SHORT.."?", -- Agility? (Missing Brewmaster)
	["092775070310"] = ITEM_MOD_AGILITY_SHORT.."/"..ITEM_MOD_INTELLECT_SHORT.."?", -- Agility/Intellect?
	["092005070010"] = ITEM_MOD_INTELLECT_SHORT.."?", -- Intellect? (Missing Mage, Warlock)
	["092075070010"] = ITEM_MOD_INTELLECT_SHORT.."?", -- Intellect? (Missing Warlock)
	["010773050000"] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT.."?", -- Damage, Intellect? (+Enhancement Shaman)
}
-- Class specific trinket
for classID = 1, GetNumClasses() do
	local digit = 0
	for specIndex=1, GetNumSpecializationsForClassID(classID) do
		digit = digit + 2^(specIndex-1)
	end
	local flag = ZERO:sub(1, GetNumClasses()-classID)..format("%X", digit)..ZERO:sub(GetNumClasses()-classID+2, GetNumClasses())
	_G.RCTrinketCategories[flag] = select(1, GetClassInfo(classID))
end

-- Automatically generated by command "/rc exporttrinketdata"
-- The code related to above command is commented out for Curseforge release because
-- this is intended to be run by the developer.
-- The table indicates if the trinket is lootable for certain specs.
-- Format: [itemID] = specFlag
_G.RCTrinketSpecs = {
	[11810] = "241000100024",	-- Force of Will,                                  	Tank
	[11815] = "365002707767",	-- Hand of Justice,                                	Strength/Agility
	[11819] = "082004030010",	-- Second Wind,                                    	Healer
	[11832] = "092775070010",	-- Burst of Knowledge,                             	Intellect
	[13213] = "3F7777777777",	-- Smolderweb's Eye,                               	All Classes
	[13382] = "3F7777777777",	-- Cannonball Runner,                              	All Classes
	[13515] = "3F7777777777",	-- Ramstein's Lightning Bolts,                     	All Classes
	[17744] = "3F7777777777",	-- Heart of Noxxion,                               	All Classes
	[18370] = "3F7777777777",	-- Vigilance Charm,                                	All Classes
	[18371] = "082004030010",	-- Mindtap Talisman,                               	Healer
	[21473] = "3F7777777777",	-- Eye of Moam,                                    	All Classes
	[21488] = "3F7777777777",	-- Fetish of Chitinous Spikes,                     	All Classes
	[22321] = "365002707767",	-- Heart of Wyrmthalak,                            	Strength/Agility
	[24376] = "3F7777777777",	-- Runed Fungalcap,                                	All Classes
	[24390] = "092775070010",	-- Auslese's Light Channeler,                      	Intellect
	[26055] = "092775070010",	-- Oculus of the Hidden Eye,                       	Intellect
	[27416] = "124002607703",	-- Fetish of the Fallen,                           	Strength/Agility?
	[27529] = "3F7777777777",	-- Figurine of the Colossus,                       	All Classes
	[27683] = "092775070010",	-- Quagmirran's Eye,                               	Intellect
	[27770] = "241000100024",	-- Argussian Compass,                              	Tank
	[27828] = "082004030010",	-- Warp-Scarab Brooch,                             	Healer
	[27891] = "3F7777777777",	-- Adamantine Figurine,                            	All Classes
	[27896] = "082004030010",	-- Alembic of Infernal Power,                      	Healer
	[27900] = "3F7777777777",	-- Jewel of Charismatic Mystique,                  	All Classes
	[28034] = "324001607743",	-- Hourglass of the Unraveller,                    	Strength/Agility?
	[28121] = "3F7777777777",	-- Icon of Unyielding Courage,                     	All Classes
	[28190] = "092775070010",	-- Scarab of the Infinite Cycle,                   	Intellect
	[28223] = "3F7777777777",	-- Arcanist's Stone,                               	All Classes
	[28288] = "124002607743",	-- Abacus of Violent Odds,                         	Damage, Strength/Agility
	[28370] = "082004030010",	-- Bangle of Endless Blessings,                    	Healer
	[28418] = "010771040000",	-- Shiffar's Nexus-Horn,                           	Damage, Intellect
	[28528] = "3F7777777777",	-- Moroes' Lucky Pocket Watch,                     	All Classes
	[28579] = "3F7777777777",	-- Romulo's Poison Vial,                           	All Classes
	[28590] = "092775070010",	-- Ribbon of Sacrifice,                            	Intellect
	[28727] = "092775070010",	-- Pendant of the Violet Eye,                      	Intellect
	[28785] = "3F7777777777",	-- The Lightning Capacitor,                        	All Classes
	[28789] = "092775070010",	-- Eye of Magtheridon,                             	Intellect
	[28823] = "092775070010",	-- Eye of Gruul,                                   	Intellect
	[28830] = "365002707767",	-- Dragonspine Trophy,                             	Strength/Agility
	[30446] = "3F7777777777",	-- Solarian's Sapphire,                            	All Classes
	[30447] = "3F7777777777",	-- Tome of Fiery Redemption,                       	All Classes
	[30448] = "3F7777777777",	-- Talon of Al'ar,                                 	All Classes
	[30449] = "3F7777777777",	-- Void Star Talisman,                             	All Classes
	[30450] = "3F7777777777",	-- Warp-Spring Coil,                               	All Classes
	[30619] = "3F7777777777",	-- Fel Reaver's Piston,                            	All Classes
	[30621] = "3F7777777777",	-- Prism of Inner Calm,                            	All Classes
	[30626] = "3F7777777777",	-- Sextant of Unstable Currents,                   	All Classes
	[30627] = "3F7777777777",	-- Tsunami Talisman,                               	All Classes
	[30629] = "3F7777777777",	-- Scarab of Displacement,                         	All Classes
	[30663] = "3F7777777777",	-- Fathom-Brooch of the Tidewalker,                	All Classes
	[30664] = "3F7777777777",	-- Living Root of the Wildheart,                   	All Classes
	[30665] = "000000070000",	-- Earring of Soulful Meditation,                  	Priest
	[30720] = "3F7777777777",	-- Serpent-Coil Braid,                             	All Classes
	[32483] = "092775070010",	-- The Skull of Gul'dan,                           	Intellect
	[32496] = "092775070010",	-- Memento of Tyrande,                             	Intellect
	[32501] = "3F7777777777",	-- Shadowmoon Insignia,                            	All Classes
	[32505] = "365002707767",	-- Madness of the Betrayer,                        	Strength/Agility
	[34427] = "3F7777777777",	-- Blackened Naaru Sliver,                         	All Classes
	[34428] = "3F7777777777",	-- Steely Naaru Sliver,                            	All Classes
	[34429] = "3F7777777777",	-- Shifting Naaru Sliver,                          	All Classes
	[34430] = "092775070010",	-- Glimmering Naaru Sliver,                        	Intellect
	[34470] = "092775070010",	-- Timbal's Focusing Crystal,                      	Intellect
	[34471] = "3F7777777777",	-- Vial of the Sunwell,                            	All Classes
	[34472] = "124002607743",	-- Shard of Contempt,                              	Damage, Strength/Agility
	[34473] = "241000100024",	-- Commendation of Kael'thas,                      	Tank
	[36972] = "092775070010",	-- Tome of Arcane Phenomena,                       	Intellect
	[36993] = "241000100024",	-- Seal of the Pantheon,                           	Tank
	[37064] = "365002707767",	-- Vestige of Haldor,                              	Strength/Agility
	[37111] = "092775070010",	-- Soul Preserver,                                 	Intellect
	[37166] = "365002707767",	-- Sphere of Red Dragon's Blood,                   	Strength/Agility
	[37220] = "241000100024",	-- Essence of Gossamer,                            	Tank
	[37264] = "010771040000",	-- Pendulum of Telluric Currents,                  	Damage, Intellect
	[37390] = "365002707767",	-- Meteorite Whetstone,                            	Strength/Agility
	[37638] = "241000100024",	-- Offering of Sacrifice,                          	Tank
	[37657] = "092005070010",	-- Spark of Life,                                  	Intellect?
	[37660] = "092775070010",	-- Forge Ember,                                    	Intellect
	[37723] = "124002607743",	-- Incisor Fragment,                               	Damage, Strength/Agility
	[37734] = "3F7777777777",	-- Talisman of Troll Divinity,                     	All Classes
	[37844] = "092005070010",	-- Winged Talisman,                                	Intellect?
	[37872] = "000000000024",	-- Lavanthor's Talisman,                           	Tank, Block
	[37873] = "092775070010",	-- Mark of the War Prisoner,                       	Intellect
	[39229] = "092775070010",	-- Embrace of the Spider,                          	Intellect
	[39257] = "3F7777777777",	-- Loatheb's Shadow,                               	All Classes
	[39292] = "3F7777777777",	-- Repelling Charge,                               	All Classes
	[39388] = "3F7777777777",	-- Spirit-World Glass,                             	All Classes
	[40255] = "3F7777777777",	-- Dying Curse,                                    	All Classes
	[40256] = "3F7777777777",	-- Grim Toll,                                      	All Classes
	[40257] = "3F7777777777",	-- Defender's Code,                                	All Classes
	[40258] = "092775070010",	-- Forethought Talisman,                           	Intellect
	[40371] = "365002707767",	-- Bandit's Insignia,                              	Strength/Agility
	[40372] = "3F7777777777",	-- Rune of Repulsion,                              	All Classes
	[40373] = "3F7777777777",	-- Extract of Necromantic Power,                   	All Classes
	[40382] = "3F7777777777",	-- Soul of the Dead,                               	All Classes
	[40430] = "3F7777777777",	-- Majestic Dragon Figurine,                       	All Classes
	[40431] = "3F7777777777",	-- Fury of the Five Flights,                       	All Classes
	[40432] = "3F7777777777",	-- Illustration of the Dragon Soul,                	All Classes
	[40531] = "3F7777777777",	-- Mark of Norgannon,                              	All Classes
	[40532] = "3F7777777777",	-- Living Ice Crystals,                            	All Classes
	[45148] = "3F7777777777",	-- Living Flame,                                   	All Classes
	[45158] = "3F7777777777",	-- Heart of Iron,                                  	All Classes
	[45263] = "3F7777777777",	-- Wrathstone,                                     	All Classes
	[45286] = "3F7777777777",	-- Pyrite Infuser,                                 	All Classes
	[45292] = "3F7777777777",	-- Energy Siphon,                                  	All Classes
	[45308] = "3F7777777777",	-- Eye of the Broodmother,                         	All Classes
	[45313] = "3F7777777777",	-- Furnace Stone,                                  	All Classes
	[45466] = "092775070010",	-- Scale of Fates,                                 	Intellect
	[45490] = "092775070010",	-- Pandora's Plea,                                 	Intellect
	[45507] = "3F7777777777",	-- The General's Heart,                            	All Classes
	[45518] = "3F7777777777",	-- Flare of the Heavens,                           	All Classes
	[45522] = "3F7777777777",	-- Blood of the Old God,                           	All Classes
	[45535] = "092775070010",	-- Show of Faith,                                  	Intellect
	[45609] = "365002707767",	-- Comet's Trail,                                  	Strength/Agility
	[45703] = "3F7777777777",	-- Spark of Hope,                                  	All Classes
	[45866] = "3F7777777777",	-- Elemental Focus Stone,                          	All Classes
	[45929] = "092775070010",	-- Sif's Remembrance,                              	Intellect
	[45931] = "3F7777777777",	-- Mjolnir Runestone,                              	All Classes
	[46021] = "3F7777777777",	-- Royal Seal of King Llane,                       	All Classes
	[46038] = "365002707767",	-- Dark Matter,                                    	Strength/Agility
	[46051] = "092775070010",	-- Meteorite Crystal,                              	Intellect
	[46312] = "3F7777777777",	-- Vanquished Clutches of Yogg-Saron,              	All Classes
	[47213] = "010771040000",	-- Abyssal Rune,                                   	Damage, Intellect
	[47214] = "124002607743",	-- Banner of Victory,                              	Damage, Strength/Agility
	[47215] = "092775070010",	-- Tears of the Vanquished,                        	Intellect
	[47216] = "241000100024",	-- The Black Heart,                                	Tank
	[47271] = "092775070010",	-- Solace of the Fallen,                           	Intellect
	[47290] = "3F7777777777",	-- Juggernaut's Vitality,                          	All Classes
	[47303] = "365002707767",	-- Death's Choice,                                 	Strength/Agility
	[47316] = "092775070010",	-- Reign of the Dead,                              	Intellect
	[47432] = "092775070010",	-- Solace of the Fallen,                           	Intellect
	[47451] = "3F7777777777",	-- Juggernaut's Vitality,                          	All Classes
	[47464] = "365002707767",	-- Death's Choice,                                 	Strength/Agility
	[47477] = "092775070010",	-- Reign of the Dead,                              	Intellect
	[47879] = "3F7777777777",	-- Fetish of Volatile Power,                       	All Classes
	[47880] = "3F7777777777",	-- Binding Stone,                                  	All Classes
	[47881] = "3F7777777777",	-- Vengeance of the Forsaken,                      	All Classes
	[47882] = "3F7777777777",	-- Eitrigg's Oath,                                 	All Classes
	[48018] = "3F7777777777",	-- Fetish of Volatile Power,                       	All Classes
	[48019] = "3F7777777777",	-- Binding Stone,                                  	All Classes
	[48020] = "3F7777777777",	-- Vengeance of the Forsaken,                      	All Classes
	[48021] = "3F7777777777",	-- Eitrigg's Oath,                                 	All Classes
	[49310] = "3F7777777777",	-- Purified Shard of the Scale,                    	All Classes
	[49463] = "3F7777777777",	-- Purified Shard of the Flame,                    	All Classes
	[49464] = "3F7777777777",	-- Shiny Shard of the Flame,                       	All Classes
	[49488] = "3F7777777777",	-- Shiny Shard of the Scale,                       	All Classes
	[50198] = "367002707767",	-- Needle-Encrusted Scorpion,                      	Strength/Agility?
	[50235] = "241000100024",	-- Ick's Rotting Thumb,                            	Tank
	[50259] = "092775070010",	-- Nevermelting Ice Crystal,                       	Intellect
	[50260] = "082004030010",	-- Ephemeral Snowflake,                            	Healer
	[50339] = "092775070010",	-- Sliver of Pure Ice,                             	Intellect
	[50340] = "3F7777777777",	-- Muradin's Spyglass,                             	All Classes
	[50341] = "3F7777777777",	-- Unidentifiable Organ,                           	All Classes
	[50342] = "3F7777777777",	-- Whispering Fanged Skull,                        	All Classes
	[50343] = "3F7777777777",	-- Whispering Fanged Skull,                        	All Classes
	[50344] = "3F7777777777",	-- Unidentifiable Organ,                           	All Classes
	[50345] = "3F7777777777",	-- Muradin's Spyglass,                             	All Classes
	[50346] = "092775070010",	-- Sliver of Pure Ice,                             	Intellect
	[50348] = "3F7777777777",	-- Dislodged Foreign Object,                       	All Classes
	[50349] = "3F7777777777",	-- Corpse Tongue Coin,                             	All Classes
	[50351] = "3F7777777777",	-- Tiny Abomination in a Jar,                      	All Classes
	[50352] = "3F7777777777",	-- Corpse Tongue Coin,                             	All Classes
	[50353] = "3F7777777777",	-- Dislodged Foreign Object,                       	All Classes
	[50354] = "3F7777777777",	-- Bauble of True Blood,                           	All Classes
	[50359] = "092775070010",	-- Althor's Abacus,                                	Intellect
	[50360] = "3F7777777777",	-- Phylactery of the Nameless Lich,                	All Classes
	[50361] = "3F7777777777",	-- Sindragosa's Flawless Fang,                     	All Classes
	[50362] = "3F7777777777",	-- Deathbringer's Will,                            	All Classes
	[50363] = "3F7777777777",	-- Deathbringer's Will,                            	All Classes
	[50364] = "3F7777777777",	-- Sindragosa's Flawless Fang,                     	All Classes
	[50365] = "3F7777777777",	-- Phylactery of the Nameless Lich,                	All Classes
	[50366] = "092775070010",	-- Althor's Abacus,                                	Intellect
	[50706] = "3F7777777777",	-- Tiny Abomination in a Jar,                      	All Classes
	[50726] = "3F7777777777",	-- Bauble of True Blood,                           	All Classes
	[54569] = "3F7777777777",	-- Sharpened Twilight Scale,                       	All Classes
	[54571] = "3F7777777777",	-- Petrified Twilight Scale,                       	All Classes
	[54572] = "3F7777777777",	-- Charred Twilight Scale,                         	All Classes
	[54573] = "092775070010",	-- Glowing Twilight Scale,                         	Intellect
	[54588] = "3F7777777777",	-- Charred Twilight Scale,                         	All Classes
	[54589] = "092775070010",	-- Glowing Twilight Scale,                         	Intellect
	[54590] = "3F7777777777",	-- Sharpened Twilight Scale,                       	All Classes
	[54591] = "3F7777777777",	-- Petrified Twilight Scale,                       	All Classes
	[55237] = "3F7777777777",	-- Porcelain Crab,                                 	All Classes
	[55251] = "3F7777777777",	-- Might of the Ocean,                             	All Classes
	[55256] = "3F7777777777",	-- Sea Star,                                       	All Classes
	[55266] = "365002007700",	-- Grace of the Herald,                            	Agility
	[55787] = "092775070010",	-- Witching Hourglass,                             	Intellect
	[55795] = "3F7777777777",	-- Key to the Endless Chamber,                     	All Classes
	[55810] = "092775070010",	-- Tendrils of Burrowing Dark,                     	Intellect
	[55814] = "000000700067",	-- Magnetite Mirror,                               	Strength
	[55816] = "241000100024",	-- Leaden Despair,                                 	Tank
	[55819] = "092775070010",	-- Tear of Blood,                                  	Intellect
	[55845] = "241000100024",	-- Heart of Thunder,                               	Tank
	[55868] = "3F7777777777",	-- Heart of Solace,                                	All Classes
	[55874] = "365002007700",	-- Tia's Grace,                                    	Agility
	[55879] = "010771040000",	-- Sorrowsong,                                     	Damage, Intellect
	[55889] = "3F7777777777",	-- Anhuur's Hymnal,                                	All Classes
	[55995] = "082004030010",	-- Blood of Isiset,                                	Healer
	[56100] = "3F7777777777",	-- Right Eye of Rajh,                              	All Classes
	[56102] = "365002007700",	-- Left Eye of Rajh,                               	Agility
	[56115] = "365002007700",	-- Skardyn's Grace,                                	Agility
	[56121] = "3F7777777777",	-- Throngus's Finger,                              	All Classes
	[56132] = "000000700067",	-- Mark of Khardros,                               	Strength
	[56136] = "082004030010",	-- Corrupted Egg Shell,                            	Healer
	[56138] = "3F7777777777",	-- Gale of Shadows,                                	All Classes
	[56280] = "3F7777777777",	-- Porcelain Crab,                                 	All Classes
	[56285] = "3F7777777777",	-- Might of the Ocean,                             	All Classes
	[56290] = "3F7777777777",	-- Sea Star,                                       	All Classes
	[56295] = "365002007700",	-- Grace of the Herald,                            	Agility
	[56320] = "092775070010",	-- Witching Hourglass,                             	Intellect
	[56328] = "3F7777777777",	-- Key to the Endless Chamber,                     	All Classes
	[56339] = "092075070010",	-- Tendrils of Burrowing Dark,                     	Intellect?
	[56345] = "000000700067",	-- Magnetite Mirror,                               	Strength
	[56347] = "241000100024",	-- Leaden Despair,                                 	Tank
	[56351] = "092775070010",	-- Tear of Blood,                                  	Intellect
	[56370] = "241000100024",	-- Heart of Thunder,                               	Tank
	[56393] = "3F7777777777",	-- Heart of Solace,                                	All Classes
	[56394] = "365002007700",	-- Tia's Grace,                                    	Agility
	[56400] = "010771040000",	-- Sorrowsong,                                     	Damage, Intellect
	[56407] = "3F7777777777",	-- Anhuur's Hymnal,                                	All Classes
	[56414] = "082004030010",	-- Blood of Isiset,                                	Healer
	[56427] = "365002007700",	-- Left Eye of Rajh,                               	Agility
	[56431] = "3F7777777777",	-- Right Eye of Rajh,                              	All Classes
	[56440] = "365002007700",	-- Skardyn's Grace,                                	Agility
	[56449] = "3F7777777777",	-- Throngus's Finger,                              	All Classes
	[56458] = "000000700067",	-- Mark of Khardros,                               	Strength
	[56462] = "3F7777777777",	-- Gale of Shadows,                                	All Classes
	[56463] = "082004030010",	-- Corrupted Egg Shell,                            	Healer
	[59224] = "000000700067",	-- Heart of Rage,                                  	Strength
	[59326] = "3F7777777777",	-- Bell of Enraging Resonance,                     	All Classes
	[59332] = "241000100024",	-- Symbiotic Worm,                                 	Tank
	[59354] = "082004030010",	-- Jar of Ancient Remedies,                        	Healer
	[59441] = "365002007700",	-- Prestor's Talisman of Machination,              	Agility
	[59473] = "365002007700",	-- Essence of the Cyclone,                         	Agility
	[59500] = "092775070010",	-- Fall of Mortality,                              	Intellect
	[59506] = "000000700067",	-- Crushing Weight,                                	Strength
	[59514] = "3F7777777777",	-- Heart of Ignacious,                             	All Classes
	[59515] = "3F7777777777",	-- Vial of Stolen Memories,                        	All Classes
	[59519] = "092775070010",	-- Theralion's Mirror,                             	Intellect
	[60233] = "3F7777777777",	-- Shard of Woe,                                   	All Classes
	[60801] = "3F7777777777",	-- Vicious Gladiator's Medallion of Cruelty,       	All Classes
	[60806] = "3F7777777777",	-- Vicious Gladiator's Medallion of Meditation,    	All Classes
	[60807] = "3F7777777777",	-- Vicious Gladiator's Medallion of Tenacity,      	All Classes
	[61026] = "3F7777777777",	-- Vicious Gladiator's Emblem of Cruelty,          	All Classes
	[61031] = "3F7777777777",	-- Vicious Gladiator's Emblem of Meditation,       	All Classes
	[61032] = "3F7777777777",	-- Vicious Gladiator's Emblem of Tenacity,         	All Classes
	[61033] = "365002007700",	-- Vicious Gladiator's Badge of Conquest,          	Agility
	[61047] = "365002007700",	-- Vicious Gladiator's Insignia of Conquest,       	Agility
	[65026] = "365002007700",	-- Prestor's Talisman of Machination,              	Agility
	[65029] = "082004030010",	-- Jar of Ancient Remedies,                        	Healer
	[65048] = "241000100024",	-- Symbiotic Worm,                                 	Tank
	[65053] = "3F7777777777",	-- Bell of Enraging Resonance,                     	All Classes
	[65072] = "000000700067",	-- Heart of Rage,                                  	Strength
	[65105] = "092775070010",	-- Theralion's Mirror,                             	Intellect
	[65109] = "3F7777777777",	-- Vial of Stolen Memories,                        	All Classes
	[65110] = "3F7777777777",	-- Heart of Ignacious,                             	All Classes
	[65118] = "000000700067",	-- Crushing Weight,                                	Strength
	[65124] = "092775070010",	-- Fall of Mortality,                              	Intellect
	[65140] = "365002007700",	-- Essence of the Cyclone,                         	Agility
	[68925] = "092775070010",	-- Variable Pulse Lightning Capacitor,             	Intellect
	[68926] = "092775070010",	-- Jaws of Defeat,                                 	Intellect
	[68927] = "365002007700",	-- The Hungerer,                                   	Agility
	[68981] = "241000100024",	-- Spidersilk Spindle,                             	Tank
	[68982] = "092775070010",	-- Necromantic Focus,                              	Intellect
	[68983] = "092775070010",	-- Eye of Blazing Power,                           	Intellect
	[68994] = "365002007700",	-- Matrix Restabilizer,                            	Agility
	[68995] = "000000700067",	-- Vessel of Acceleration,                         	Strength
	[69110] = "092775070010",	-- Variable Pulse Lightning Capacitor,             	Intellect
	[69111] = "092775070010",	-- Jaws of Defeat,                                 	Intellect
	[69112] = "365002007700",	-- The Hungerer,                                   	Agility
	[69138] = "241000100024",	-- Spidersilk Spindle,                             	Tank
	[69139] = "092775070010",	-- Necromantic Focus,                              	Intellect
	[69149] = "092775070010",	-- Eye of Blazing Power,                           	Intellect
	[69150] = "365002007700",	-- Matrix Restabilizer,                            	Agility
	[69167] = "000000700067",	-- Vessel of Acceleration,                         	Strength
	[70393] = "3F7777777777",	-- Ruthless Gladiator's Medallion of Cruelty,      	All Classes
	[70394] = "3F7777777777",	-- Ruthless Gladiator's Medallion of Meditation,   	All Classes
	[70395] = "3F7777777777",	-- Ruthless Gladiator's Medallion of Tenacity,     	All Classes
	[70396] = "3F7777777777",	-- Ruthless Gladiator's Emblem of Cruelty,         	All Classes
	[70397] = "3F7777777777",	-- Ruthless Gladiator's Emblem of Meditation,      	All Classes
	[70398] = "3F7777777777",	-- Ruthless Gladiator's Emblem of Tenacity,        	All Classes
	[70399] = "365002007700",	-- Ruthless Gladiator's Badge of Conquest,         	Agility
	[70400] = "000000700067",	-- Ruthless Gladiator's Badge of Victory,          	Strength
	[70401] = "092775070010",	-- Ruthless Gladiator's Badge of Dominance,        	Intellect
	[70402] = "092775070010",	-- Ruthless Gladiator's Insignia of Dominance,     	Intellect
	[70403] = "000000700067",	-- Ruthless Gladiator's Insignia of Victory,       	Strength
	[70404] = "365002007700",	-- Ruthless Gladiator's Insignia of Conquest,      	Agility
	[72897] = "365002007700",	-- Arrow of Time,                                  	Agility
	[72898] = "092775070010",	-- Foul Gift of the Demon Lord,                    	Intellect
	[72899] = "000000700067",	-- Varo'then's Brooch,                             	Strength
	[72900] = "241000100024",	-- Veil of Lies,                                   	Tank
	[72901] = "000000700067",	-- Rosary of Light,                                	Strength
	[73491] = "000000700067",	-- Cataclysmic Gladiator's Insignia of Victory,    	Strength
	[73496] = "000000700067",	-- Cataclysmic Gladiator's Badge of Victory,       	Strength
	[73497] = "092775070010",	-- Cataclysmic Gladiator's Insignia of Dominance,  	Intellect
	[73498] = "092775070010",	-- Cataclysmic Gladiator's Badge of Dominance,     	Intellect
	[73534] = "3F7777777777",	-- Cataclysmic Gladiator's Medallion of Meditation,	All Classes
	[73537] = "3F7777777777",	-- Cataclysmic Gladiator's Medallion of Tenacity,  	All Classes
	[73538] = "3F7777777777",	-- Cataclysmic Gladiator's Medallion of Cruelty,   	All Classes
	[73591] = "3F7777777777",	-- Cataclysmic Gladiator's Emblem of Meditation,   	All Classes
	[73592] = "3F7777777777",	-- Cataclysmic Gladiator's Emblem of Tenacity,     	All Classes
	[73593] = "3F7777777777",	-- Cataclysmic Gladiator's Emblem of Cruelty,      	All Classes
	[73643] = "365002007700",	-- Cataclysmic Gladiator's Insignia of Conquest,   	Agility
	[73648] = "365002007700",	-- Cataclysmic Gladiator's Badge of Conquest,      	Agility
	[77197] = "365002007700",	-- Wrath of Unchaining,                            	Agility
	[77198] = "010771040000",	-- Will of Unbinding,                              	Damage, Intellect
	[77199] = "092775070010",	-- Heart of Unliving,                              	Intellect
	[77200] = "000000700067",	-- Eye of Unmaking,                                	Strength
	[77201] = "241000100024",	-- Resolve of Undying,                             	Tank
	[77202] = "365002007700",	-- Starcatcher Compass,                            	Agility
	[77203] = "092775070010",	-- Insignia of the Corrupted Mind,                 	Intellect
	[77204] = "092775070010",	-- Seal of the Seven Signs,                        	Intellect
	[77205] = "000000700067",	-- Creche of the Final Dragon,                     	Strength
	[77206] = "241000100024",	-- Soulshifter Vortex,                             	Tank
	[77207] = "365002007700",	-- Vial of Shadows,                                	Agility
	[77208] = "010771040000",	-- Cunning of the Cruel,                           	Damage, Intellect
	[77209] = "082004030010",	-- Windward Heart,                                 	Healer
	[77210] = "000000700067",	-- Bone-Link Fetish,                               	Strength
	[77211] = "241000100024",	-- Indomitable Pride,                              	Tank
	[77989] = "092775070010",	-- Seal of the Seven Signs,                        	Intellect
	[77990] = "241000100044",	-- Soulshifter Vortex,                             	Tank?
	[77991] = "092775070010",	-- Insignia of the Corrupted Mind,                 	Intellect
	[77992] = "000000700067",	-- Creche of the Final Dragon,                     	Strength
	[77993] = "365002007700",	-- Starcatcher Compass,                            	Agility
	[77994] = "365002007700",	-- Wrath of Unchaining,                            	Agility
	[77995] = "010771040000",	-- Will of Unbinding,                              	Damage, Intellect
	[77996] = "082004030010",	-- Heart of Unliving,                              	Healer
	[77997] = "000000700067",	-- Eye of Unmaking,                                	Strength
	[77998] = "241000100024",	-- Resolve of Undying,                             	Tank
	[77999] = "365002007700",	-- Vial of Shadows,                                	Agility
	[78000] = "092775070010",	-- Cunning of the Cruel,                           	Intellect
	[78001] = "082004030010",	-- Windward Heart,                                 	Healer
	[78002] = "000000700067",	-- Bone-Link Fetish,                               	Strength
	[78003] = "241000100024",	-- Indomitable Pride,                              	Tank
	[86131] = "241000100024",	-- Vial of Dragon's Blood,                         	Tank
	[86132] = "365002007700",	-- Bottle of Infinite Stars,                       	Agility
	[86133] = "010771040000",	-- Light of the Cosmos,                            	Damage, Intellect
	[86144] = "000000600043",	-- Lei Shen's Final Orders,                        	Damage, Strength
	[86147] = "082004030010",	-- Qin-xi's Polarizing Seal,                       	Healer
	[86323] = "241000100024",	-- Stuff of Nightmares,                            	Tank
	[86327] = "082004030010",	-- Spirits of the Sun,                             	Healer
	[86332] = "365002007700",	-- Terror in the Mists,                            	Agility
	[86336] = "000000600043",	-- Darkmist Vortex,                                	Damage, Strength
	[86388] = "010771040000",	-- Essence of Terror,                              	Damage, Intellect
	[87057] = "365002007700",	-- Bottle of Infinite Stars,                       	Agility
	[87063] = "241000100024",	-- Vial of Dragon's Blood,                         	Tank
	[87065] = "010771040000",	-- Light of the Cosmos,                            	Damage, Intellect
	[87072] = "000000600043",	-- Lei Shen's Final Orders,                        	Damage, Strength
	[87075] = "082004030010",	-- Qin-xi's Polarizing Seal,                       	Healer
	[87160] = "241000100024",	-- Stuff of Nightmares,                            	Tank
	[87163] = "082004030010",	-- Spirits of the Sun,                             	Healer
	[87167] = "365002007700",	-- Terror in the Mists,                            	Agility
	[87172] = "000000600043",	-- Darkmist Vortex,                                	Damage, Strength
	[87175] = "010771040000",	-- Essence of Terror,                              	Damage, Intellect
	[88294] = "365002007700",	-- Flashing Steel Talisman,                        	Agility
	[88355] = "365002007700",	-- Searing Words,                                  	Agility
	[88358] = "000000700067",	-- Lessons of the Darkmaster,                      	Strength
	[88360] = "082004030010",	-- Price of Progress,                              	Healer
	[94512] = "365002007700",	-- Renataki's Soul Charm,                          	Agility
	[94513] = "010771040000",	-- Wushoolay's Final Choice,                       	Damage, Intellect
	[94514] = "082004030010",	-- Horridon's Last Gasp,                           	Healer
	[94515] = "000000600043",	-- Fabled Feather of Ji-Kun,                       	Damage, Strength
	[94516] = "241000100024",	-- Fortitude of the Zandalari,                     	Tank
	[94518] = "241000100024",	-- Delicate Vial of the Sanguinaire,               	Tank
	[94519] = "000000600043",	-- Primordius' Talisman of Rage,                   	Damage, Strength
	[94520] = "082004030010",	-- Inscribed Bag of Hydra-Spawn,                   	Healer
	[94521] = "010771040000",	-- Breath of the Hydra,                            	Damage, Intellect
	[94522] = "365002007700",	-- Talisman of Bloodlust,                          	Agility
	[94523] = "365002007700",	-- Bad Juju,                                       	Agility
	[94524] = "010771040000",	-- Unerring Vision of Lei Shen,                    	Damage, Intellect
	[94525] = "082004030010",	-- Stolen Relic of Zuldazar,                       	Healer
	[94526] = "000000600043",	-- Spark of Zandalar,                              	Damage, Strength
	[94527] = "241000100024",	-- Ji-Kun's Rising Winds,                          	Tank
	[94528] = "241000100024",	-- Soul Barrier,                                   	Tank
	[94529] = "000000600043",	-- Gaze of the Twins,                              	Damage, Strength
	[94530] = "082004030010",	-- Lightning-Imbued Chalice,                       	Healer
	[94531] = "010771040000",	-- Cha-Ye's Essence of Brilliance,                 	Damage, Intellect
	[94532] = "365002007700",	-- Rune of Re-Origination,                         	Agility
	[96369] = "365002007700",	-- Renataki's Soul Charm,                          	Agility
	[96385] = "082004030010",	-- Horridon's Last Gasp,                           	Healer
	[96398] = "000000600043",	-- Spark of Zandalar,                              	Damage, Strength
	[96409] = "365002007700",	-- Bad Juju,                                       	Agility
	[96413] = "010771040000",	-- Wushoolay's Final Choice,                       	Damage, Intellect
	[96421] = "241000100024",	-- Fortitude of the Zandalari,                     	Tank
	[96455] = "010771040000",	-- Breath of the Hydra,                            	Damage, Intellect
	[96456] = "082004030010",	-- Inscribed Bag of Hydra-Spawn,                   	Healer
	[96470] = "000000600043",	-- Fabled Feather of Ji-Kun,                       	Damage, Strength
	[96471] = "241000100024",	-- Ji-Kun's Rising Winds,                          	Tank
	[96492] = "365002007700",	-- Talisman of Bloodlust,                          	Agility
	[96501] = "000000600043",	-- Primordius' Talisman of Rage,                   	Damage, Strength
	[96507] = "082004030010",	-- Stolen Relic of Zuldazar,                       	Healer
	[96516] = "010771040000",	-- Cha-Ye's Essence of Brilliance,                 	Damage, Intellect
	[96523] = "241000100024",	-- Delicate Vial of the Sanguinaire,               	Tank
	[96543] = "000000600043",	-- Gaze of the Twins,                              	Damage, Strength
	[96546] = "365002007700",	-- Rune of Re-Origination,                         	Agility
	[96555] = "241000100024",	-- Soul Barrier,                                   	Tank
	[96558] = "010771040000",	-- Unerring Vision of Lei Shen,                    	Damage, Intellect
	[96561] = "082004030010",	-- Lightning-Imbued Chalice,                       	Healer
	[109995] = "365002007700",	-- Blood Seal of Azzakel,                          	Agility
	[109996] = "365002007700",	-- Thundertower's Targeting Reticle,               	Agility
	[109997] = "365002007700",	-- Kihra's Adrenaline Injector,                    	Agility
	[109998] = "365002007700",	-- Gor'ashan's Lodestone Spike,                    	Agility
	[109999] = "365002007700",	-- Witherbark's Branch,                            	Agility
	[110000] = "010771040000",	-- Crushto's Runic Alarm,                          	Damage, Intellect
	[110001] = "010771040000",	-- Tovra's Lightning Repository,                   	Damage, Intellect
	[110002] = "010771040000",	-- Fleshrender's Meathook,                         	Damage, Intellect
	[110003] = "010771040000",	-- Ragewing's Firefang,                            	Damage, Intellect
	[110004] = "010771040000",	-- Coagulated Genesaur Blood,                      	Damage, Intellect
	[110005] = "082004030010",	-- Crystalline Blood Drop,                         	Healer
	[110006] = "082004030010",	-- Rukhran's Quill,                                	Healer
	[110007] = "082004030010",	-- Voidmender's Shadowgem,                         	Healer
	[110008] = "082004030010",	-- Tharbek's Lucky Pebble,                         	Healer
	[110009] = "082004030010",	-- Leaf of the Ancient Protectors,                 	Healer
	[110010] = "000000600043",	-- Mote of Corruption,                             	Damage, Strength
	[110011] = "000000600043",	-- Fires of the Sun,                               	Damage, Strength
	[110012] = "000000600043",	-- Bonemaw's Big Toe,                              	Damage, Strength
	[110013] = "000000600043",	-- Emberscale Talisman,                            	Damage, Strength
	[110014] = "000000600043",	-- Spores of Alacrity,                             	Damage, Strength
	[110015] = "041000100024",	-- Toria's Unseeing Eye,                           	All Classes?
	[110016] = "241000100024",	-- Solar Containment Unit,                         	Tank
	[110017] = "241000100024",	-- Enforcer's Stun Grenade,                        	Tank
	[110018] = "241000100024",	-- Kyrak's Vileblood Serum,                        	Tank
	[110019] = "241000100024",	-- Xeri'tac's Unhatched Egg Sac,                   	Tank
	[112426] = "010771040000",	-- Purified Bindings of Immerseus,                 	Damage, Intellect
	[112476] = "241000100024",	-- Rook's Unlucky Talisman,                        	Tank
	[112503] = "000000600043",	-- Fusion-Fire Core,                               	Damage, Strength
	[112703] = "000000600043",	-- Evil Eye of Galakras,                           	Damage, Strength
	[112729] = "241000100024",	-- Juggernaut's Focusing Crystal,                  	Tank
	[112754] = "124002007700",	-- Haromm's Talisman,                              	Damage, Agility
	[112768] = "010771040000",	-- Kardris' Toxic Totem,                           	Damage, Intellect
	[112778] = "082004030010",	-- Nazgrim's Burnished Insignia,                   	Healer
	[112792] = "241000100024",	-- Vial of Living Corruption,                      	Tank
	[112815] = "010771040000",	-- Frenzied Crystal of Rage,                       	Damage, Intellect
	[112825] = "124002007700",	-- Sigil of Rampage,                               	Damage, Agility
	[112849] = "082004030010",	-- Thok's Acid-Grooved Tooth,                      	Healer
	[112850] = "000000600043",	-- Thok's Tail Tip,                                	Damage, Strength
	[112877] = "082004030010",	-- Dysmorphic Samophlange of Discontinuity,        	Healer
	[112879] = "365002007700",	-- Ticking Ebon Detonator,                         	Agility
	[112913] = "000000600043",	-- Skeer's Bloodsoaked Talisman,                   	Damage, Strength
	[112924] = "241000100024",	-- Curse of Hubris,                                	Tank
	[112938] = "010771040000",	-- Black Blood of Y'Shaarj,                        	Damage, Intellect
	[112947] = "124002007700",	-- Assurance of Consequence,                       	Damage, Agility
	[112948] = "082004030010",	-- Prismatic Prison of Pride,                      	Healer
	[113612] = "124002007700",	-- Scales of Doom,                                 	Damage, Agility
	[113645] = "000000600043",	-- Tectus' Beating Heart,                          	Damage, Strength
	[113650] = "241000100024",	-- Pillar of the Earth,                            	Tank
	[113658] = "000000600043",	-- Bottle of Infesting Spores,                     	Damage, Strength
	[113834] = "241000100024",	-- Pol's Blinded Eye,                              	Tank
	[113835] = "010771040000",	-- Shards of Nothing,                              	Damage, Intellect
	[113842] = "082004030010",	-- Emblem of Caustic Healing,                      	Healer
	[113853] = "124002007700",	-- Captive Micro-Aberration,                       	Damage, Agility
	[113854] = "082004030010",	-- Mark of Rapid Replication,                      	Healer
	[113859] = "010771040000",	-- Quiescent Runestone,                            	Damage, Intellect
	[113861] = "241000100024",	-- Evergaze Arcane Eidolon,                        	Tank
	[113889] = "082004030010",	-- Elementalist's Shielding Talisman,              	Healer
	[113893] = "241000100024",	-- Blast Furnace Door,                             	Tank
	[113905] = "241000100024",	-- Tablet of Turnbuckle Teamwork,                  	Tank
	[113931] = "124002007700",	-- Beating Heart of the Mountain,                  	Damage, Agility
	[113948] = "010771040000",	-- Darmac's Unstable Talisman,                     	Damage, Intellect
	[113969] = "000000600043",	-- Vial of Convulsive Shadows,                     	Damage, Strength
	[113983] = "000000600043",	-- Forgemaster's Insignia,                         	Damage, Strength
	[113984] = "010771040000",	-- Blackiron Micro Crucible,                       	Damage, Intellect
	[113985] = "124002007700",	-- Humming Blackiron Trigger,                      	Damage, Agility
	[113986] = "082004030010",	-- Auto-Repairing Autoclave,                       	Healer
	[113987] = "241000100024",	-- Battering Talisman,                             	Tank
	[116289] = "324002007700",	-- Bloodmaw's Tooth,                               	Agility?
	[116290] = "010771040000",	-- Emblem of Gushing Wounds,                       	Damage, Intellect
	[116291] = "082004030010",	-- Immaculate Living Mushroom,                     	Healer
	[116292] = "000000600043",	-- Mote of the Mountain,                           	Damage, Strength
	[116293] = "241000100024",	-- Idol of Suppression,                            	Tank
	[116314] = "324002007700",	-- Blackheart Enforcer's Medallion,                	Agility?
	[116315] = "010771040000",	-- Furyheart Talisman,                             	Damage, Intellect
	[116316] = "082004030010",	-- Captured Flickerspark,                          	Healer
	[116317] = "000000600043",	-- Storage House Key,                              	Damage, Strength
	[116318] = "241000100024",	-- Stoneheart Idol,                                	Tank
	[118114] = "124002007700",	-- Meaty Dragonspine Trophy,                       	Damage, Agility
	[119192] = "082004030010",	-- Ironspike Chew Toy,                             	Healer
	[119193] = "000000600043",	-- Horn of Screaming Spirits,                      	Damage, Strength
	[119194] = "010771040000",	-- Goren Soul Repository,                          	Damage, Intellect
	[123992] = "000000000024",	-- Figurine of the Colossus,                       	Tank, Block
	[124223] = "124002007700",	-- Fel-Spring Coil,                                	Damage, Agility
	[124224] = "124002007700",	-- Mirror of the Blademaster,                      	Damage, Agility
	[124225] = "124002007400",	-- Soul Capacitor,                                 	Damage, Melee, Agility
	[124226] = "124002007700",	-- Malicious Censer,                               	Damage, Agility
	[124227] = "010771040000",	-- Iron Reaver Piston,                             	Damage, Intellect
	[124228] = "010771040000",	-- Desecrated Shadowmoon Insignia,                 	Damage, Intellect
	[124229] = "010771040000",	-- Unblinking Gaze of Sethe,                       	Damage, Intellect
	[124230] = "010671040000",	-- Prophecy of Fear,                               	Damage, Intellect
	[124231] = "082004030010",	-- Flickering Felspark,                            	Healer
	[124232] = "082004030010",	-- Intuition's Gift,                               	Healer
	[124233] = "082004030010",	-- Demonic Phylactery,                             	Healer
	[124234] = "082004030010",	-- Unstable Felshadow Emulsion,                    	Healer
	[124235] = "000000600043",	-- Rumbling Pebble,                                	Damage, Strength
	[124236] = "000000600043",	-- Unending Hunger,                                	Damage, Strength
	[124237] = "000000600043",	-- Discordant Chorus,                              	Damage, Strength
	[124238] = "000000600043",	-- Empty Drinking Horn,                            	Damage, Strength
	[124239] = "241000100024",	-- Imbued Stone Sigil,                             	Tank
	[124240] = "241000100024",	-- Warlord's Unseeing Eye,                         	Tank
	[124241] = "241000100024",	-- Anzu's Cursed Plume,                            	Tank
	[124242] = "241000100024",	-- Tyrant's Decree,                                	Tank
	[124513] = "000000700000",	-- Reaper's Harvest,                               	Death Knight
	[124514] = "0F0000000000",	-- Seed of Creation,                               	Druid
	[124515] = "000000000700",	-- Talisman of the Master Tracker,                 	Hunter
	[124516] = "000070000000",	-- Tome of Shifting Words,                         	Mage
	[124517] = "007000000000",	-- Sacred Draenic Incense,                         	Monk
	[124518] = "000000000070",	-- Libram of Vindication,                          	Paladin
	[124519] = "000000070000",	-- Repudiation of War,                             	Priest
	[124520] = "000000007000",	-- Bleeding Hollow Toxin Vessel,                   	Rogue
	[124521] = "000007000000",	-- Core of the Primal Elements,                    	Shaman
	[124522] = "000700000000",	-- Fragment of the Dark Star,                      	Warlock
	[124523] = "000000000007",	-- Worldbreaker's Resolve,                         	Warrior
	[124545] = "3F7777777777",	-- Chipped Soul Prism,                             	All Classes
	[124546] = "3F7777777777",	-- Mark of Supreme Doom,                           	All Classes
	[127173] = "092775070010",	-- Shiffar's Nexus-Horn,                           	Intellect
	[127184] = "241000100024",	-- Runed Fungalcap,                                	Tank
	[127201] = "010771050000",	-- Quagmirran's Eye,                               	Damage, Intellect
	[127245] = "092775070010",	-- Warp-Scarab Brooch,                             	Intellect
	[127441] = "124002607743",	-- Hourglass of the Unraveller,                    	Damage, Strength/Agility
	[127448] = "082004030010",	-- Scarab of the Infinite Cycle,                   	Healer
	[127474] = "124002607743",	-- Vestige of Haldor,                              	Damage, Strength/Agility
	[127493] = "124002607743",	-- Meteorite Whetstone,                            	Damage, Strength/Agility
	[127512] = "092775070010",	-- Winged Talisman,                                	Intellect
	[127550] = "241000100024",	-- Offering of Sacrifice,                          	Tank
	[127594] = "124002607743",	-- Sphere of Red Dragon's Blood,                   	Damage, Strength/Agility
	[128140] = "365002007700",	-- Smoldering Felblade Remnant,                    	Agility
	[128141] = "092775070010",	-- Crackling Fel-Spark Plug,                       	Intellect
	[128142] = "092775070010",	-- Pledge of Iron Loyalty,                         	Intellect
	[128143] = "000000700067",	-- Fragmented Runestone Etching,                   	Strength
	[128144] = "365002707767",	-- Vial of Vile Viscera,                           	Strength/Agility
	[128145] = "365002007700",	-- Howling Soul Gem,                               	Agility
	[128146] = "092775070010",	-- Ensnared Orb of the Sky,                        	Intellect
	[128147] = "092775070010",	-- Teardrop of Blood,                              	Intellect
	[128148] = "000000700067",	-- Fetid Salivation,                               	Strength
	[128149] = "365002707767",	-- Accusation of Inferiority,                      	Strength/Agility
	[128150] = "365002007700",	-- Pressure-Compressed Loop,                       	Agility
	[128151] = "092775070010",	-- Portent of Disaster,                            	Intellect
	[128152] = "092775070010",	-- Decree of Demonic Sovereignty,                  	Intellect
	[128153] = "000000700067",	-- Unquenchable Doomfire Censer,                   	Strength
	[128154] = "365002707767",	-- Grasp of the Defiler,                           	Strength/Agility
	[133192] = "365002107467",	-- Porcelain Crab,                                 	Melee?
	[133197] = "000000600043",	-- Might of the Ocean,                             	Damage, Strength
	[133201] = "092775070010",	-- Sea Star,                                       	Intellect
	[133206] = "124002007700",	-- Key to the Endless Chamber,                     	Damage, Agility
	[133216] = "092775070010",	-- Tendrils of Burrowing Dark,                     	Intellect
	[133222] = "000000600043",	-- Magnetite Mirror,                               	Damage, Strength
	[133224] = "241000100024",	-- Leaden Despair,                                 	Tank
	[133227] = "082004030010",	-- Tear of Blood,                                  	Healer
	[133246] = "241000100024",	-- Heart of Thunder,                               	Tank
	[133252] = "082004030010",	-- Rainsong,                                       	Healer
	[133268] = "000000600043",	-- Heart of Solace,                                	Damage, Strength
	[133269] = "124002007700",	-- Tia's Grace,                                    	Damage, Agility
	[133275] = "010771050000",	-- Sorrowsong,                                     	Damage, Intellect
	[133281] = "201000100024",	-- Impetuous Query,                                	Tank, Parry
	[133282] = "124002007700",	-- Skardyn's Grace,                                	Damage, Agility
	[133291] = "201000100024",	-- Throngus's Finger,                              	Tank, Parry
	[133300] = "000000600043",	-- Mark of Khardros,                               	Damage, Strength
	[133304] = "092775070010",	-- Gale of Shadows,                                	Intellect
	[133305] = "082004030010",	-- Corrupted Egg Shell,                            	Healer
	[133420] = "124002007700",	-- Arrow of Time,                                  	Damage, Agility
	[133461] = "010771050000",	-- Timbal's Focusing Crystal,                      	Damage, Intellect
	[133462] = "082004030010",	-- Vial of the Sunwell,                            	Healer
	[133463] = "124002607743",	-- Shard of Contempt,                              	Damage, Strength/Agility
	[133464] = "241000100024",	-- Commendation of Kael'thas,                      	Tank
	[133641] = "010771050300",	-- Eye of Skovald,                                 	Damage, Ranged
	[133642] = "3F7777777777",	-- Horn of Valor,                                  	All Classes
	[133644] = "124002607443",	-- Memento of Angerboda,                           	Damage, Melee
	[133645] = "082004030010",	-- Naglfar Fare,                                   	Healer
	[133646] = "082004030010",	-- Mote of Sanctification,                         	Healer
	[133647] = "241000100024",	-- Gift of Radiance,                               	Tank
	[133766] = "082004030010",	-- Nether Anti-Toxin,                              	Healer
	[136714] = "082004030010",	-- Amalgam's Seventh Spine,                        	Healer
	[136715] = "124002607443",	-- Spiked Counterweight,                           	Damage, Melee
	[136716] = "010771050300",	-- Caged Horror,                                   	Damage, Ranged
	[136975] = "124002607443",	-- Hunger of the Pack,                             	Damage, Melee
	[136978] = "241000100024",	-- Ember of Nullification,                         	Tank
	[137301] = "010771050000",	-- Corrupted Starlight,                            	Damage, Intellect
	[137306] = "010771050300",	-- Oakheart's Gnarled Root,                        	Damage, Ranged
	[137312] = "124002607443",	-- Nightmare Egg Shell,                            	Damage, Melee
	[137315] = "241000100024",	-- Writhing Heart of Darkness,                     	Tank
	[137329] = "010771050300",	-- Figurehead of the Naglfar,                      	Damage, Ranged
	[137338] = "241000100024",	-- Shard of Rokmora,                               	Tank
	[137344] = "241000100024",	-- Talisman of the Cragshaper,                     	Tank
	[137349] = "010771050300",	-- Naraxas' Spiked Tongue,                         	Damage, Ranged
	[137357] = "124002607443",	-- Mark of Dargrul,                                	Damage, Melee
	[137362] = "241000100024",	-- Parjesh's Medallion,                            	Tank
	[137367] = "010771050300",	-- Stormsinger Fulmination Charge,                 	Damage, Ranged
	[137369] = "124002607443",	-- Giant Ornamental Pearl,                         	Damage, Melee
	[137373] = "124002007700",	-- Tempered Egg of Serpentrix,                     	Damage, Agility
	[137378] = "082004030010",	-- Bottled Hurricane,                              	Healer
	[137398] = "010771050000",	-- Portable Manacracker,                           	Damage, Intellect
	[137400] = "241000100024",	-- Coagulated Nightwell Residue,                   	Tank
	[137406] = "124002607443",	-- Terrorbound Nexus,                              	Damage, Melee
	[137419] = "3F7777777777",	-- Chrono Shard,                                   	All Classes
	[137430] = "241000100024",	-- Impenetrable Nerubian Husk,                     	Tank
	[137433] = "092775070310",	-- Obelisk of the Void,                            	Agility/Intellect?
	[137439] = "124002607443",	-- Tiny Oozeling in a Jar,                         	Damage, Melee
	[137440] = "241000100024",	-- Shivermaw's Jawbone,                            	Tank
	[137446] = "010771050300",	-- Elementium Bomb Squirrel Generator,             	Damage, Ranged
	[137452] = "082004030010",	-- Thrumming Gossamer,                             	Healer
	[137459] = "124002607443",	-- Chaos Talisman,                                 	Damage, Melee
	[137462] = "082004030010",	-- Jewel of Insatiable Desire,                     	Healer
	[137484] = "082004030010",	-- Flask of the Solemn Night,                      	Healer
	[137485] = "010771050000",	-- Infernal Writ,                                  	Damage, Intellect
	[137486] = "124002607443",	-- Windscar Whetstone,                             	Damage, Melee
	[137537] = "124002007700",	-- Tirathon's Betrayal,                            	Damage, Agility
	[137538] = "241000100024",	-- Orb of Torment,                                 	Tank
	[137539] = "124002607443",	-- Faulty Countermeasure,                          	Damage, Melee
	[137540] = "082004030010",	-- Concave Reflecting Lens,                        	Healer
	[137541] = "010771050300",	-- Moonlit Prism,                                  	Damage, Ranged
	[138222] = "082004030010",	-- Vial of Nightmare Fog,                          	Healer
	[138224] = "010771050300",	-- Unstable Horrorslime,                           	Damage, Ranged
	[138225] = "241000100024",	-- Phantasmal Echo,                                	Tank
	[139320] = "124002607443",	-- Ravaged Seed Pod,                               	Damage, Melee
	[139321] = "010773050000",	-- Swarming Plaguehive,                            	Damage, Intellect?
	[139322] = "082004030010",	-- Cocoon of Enforced Solitude,                    	Healer
	[139323] = "010771050300",	-- Twisting Wind,                                  	Damage, Ranged
	[139324] = "241000100024",	-- Goblet of Nightmarish Ichor,                    	Tank
	[139325] = "124002607443",	-- Spontaneous Appendages,                         	Damage, Melee
	[139326] = "010771050000",	-- Wriggling Sinew,                                	Damage, Intellect
	[139327] = "241000100024",	-- Unbridled Fury,                                 	Tank
	[139328] = "000000600043",	-- Ursoc's Rending Paw,                            	Damage, Strength
	[139329] = "124002007700",	-- Bloodthirsty Instinct,                          	Damage, Agility
	[139330] = "082004030010",	-- Heightened Senses,                              	Healer
	[139333] = "082004030010",	-- Horn of Cenarius,                               	Healer
	[139334] = "124002607443",	-- Nature's Call,                                  	Damage, Melee
	[139335] = "241000100024",	-- Grotesque Statuette,                            	Tank
	[139336] = "010771050000",	-- Bough of Corruption,                            	Damage, Intellect
	[139630] = "300000000000",	-- Etching of Sargeras,                            	Demon Hunter
	[140789] = "241000100024",	-- Animated Exoskeleton,                           	Tank
	[140790] = "000000600043",	-- Claw of the Crystalline Scorpid,                	Damage, Strength
	[140791] = "241000100024",	-- Royal Dagger Haft,                              	Tank
	[140792] = "010771050000",	-- Erratic Metronome,                              	Damage, Intellect
	[140793] = "082004030010",	-- Perfectly Preserved Cake,                       	Healer
	[140794] = "124002007400",	-- Arcanogolem Digit,                              	Damage, Melee, Agility
	[140795] = "082004030010",	-- Aluriel's Mirror,                               	Healer
	[140796] = "124002607743",	-- Entwined Elemental Foci,                        	Damage, Strength/Agility
	[140797] = "241000100024",	-- Fang of Tichondrius,                            	Tank
	[140798] = "010771050300",	-- Icon of Rot,                                    	Damage, Ranged
	[140799] = "000000600043",	-- Might of Krosus,                                	Damage, Strength
	[140800] = "010771050000",	-- Pharamere's Forbidden Grimoire,                 	Damage, Intellect
	[140801] = "010771050300",	-- Fury of the Burning Sky,                        	Damage, Ranged
	[140802] = "124002007700",	-- Nightblooming Frond,                            	Damage, Agility
	[140803] = "082004030010",	-- Etraeus' Celestial Map,                         	Healer
	[140804] = "010771050000",	-- Star Gate,                                      	Damage, Intellect
	[140805] = "082004030010",	-- Ephemeral Paradox,                              	Healer
	[140806] = "124002607743",	-- Convergence of Fates,                           	Damage, Strength/Agility
	[140807] = "241000100024",	-- Infernal Contract,                              	Tank
	[140808] = "124002607443",	-- Draught of Souls,                               	Damage, Melee
	[140809] = "010771050000",	-- Whispers in the Dark,                           	Damage, Intellect
	[141482] = "3F7777777777",	-- Unstable Arcanocrystal,                         	All Classes
	[141535] = "000000700067",	-- Ettin Fingernail,                               	Strength
	[141536] = "092775070010",	-- Padawsen's Unlucky Charm,                       	Intellect
	[141537] = "365002007700",	-- Thrice-Accursed Compass,                        	Agility
	[142157] = "010771050300",	-- Aran's Relaxing Ruby,                           	Damage, Ranged
	[142158] = "082004030010",	-- Faith's Crucible,                               	Healer
	[142159] = "124002607443",	-- Bloodstained Handkerchief,                      	Damage, Melee
	[142160] = "010771050300",	-- Mrrgria's Favor,                                	Damage, Ranged
	[142161] = "241000100024",	-- Inescapable Dread,                              	Tank
	[142162] = "082004030010",	-- Fluctuating Energy,                             	Healer
	[142164] = "124002607443",	-- Toe Knee's Promise,                             	Damage, Melee
	[142165] = "010771050300",	-- Deteriorated Construct Core,                    	Damage, Ranged
	[142167] = "124002607443",	-- Eye of Command,                                 	Damage, Melee
	[142168] = "241000100024",	-- Majordomo's Dinner Bell,                        	Tank
	[142169] = "241000100024",	-- Raven Eidolon,                                  	Tank
	[142506] = "365002007700",	-- Eye of Guarm,                                   	Agility
	[142507] = "092775070010",	-- Brinewater Slime in a Bottle,                   	Intellect
	[142508] = "000000700067",	-- Chains of the Valorous,                         	Strength
	[144113] = "365002007700",	-- Windswept Pages,                                	Agility
	[144119] = "092775070010",	-- Empty Fruit Barrel,                             	Intellect
	[144122] = "000000700067",	-- Carbonic Carbuncle,                             	Strength
	[144128] = "241000100024",	-- Heart of Fire,                                  	Tank
	[144136] = "092775070010",	-- Vision of the Predator,                         	Intellect
	[144146] = "241000100024",	-- Iron Protector Talisman,                        	Tank
	[144156] = "092775070010",	-- Flashfrozen Resin Globule,                      	Intellect
	[144157] = "092775070010",	-- Vial of Ichorous Blood,                         	Intellect
	[144158] = "3F7777777777",	-- Flashing Steel Talisman,                        	All Classes
	[144159] = "092775070010",	-- Price of Progress,                              	Intellect
	[144160] = "365002007700",	-- Searing Words,                                  	Agility
	[144161] = "000000700067",	-- Lessons of the Darkmaster,                      	Strength
	[144477] = "124002007700",	-- Splinters of Agronox,                           	Damage, Agility
	[144480] = "092775070010",	-- Dreadstone of Endless Shadows,                  	Intellect
	[144482] = "000000700067",	-- Fel-Oiled Infernal Machine,                     	Strength
	[147002] = "092775070010",	-- Charm of the Rising Tide,                       	Intellect
	[147003] = "082004030010",	-- Barbaric Mindslaver,                            	Healer
	[147004] = "082004030010",	-- Sea Star of the Depthmother,                    	Healer
	[147005] = "082004030010",	-- Chalice of Moonlight,                           	Healer
	[147006] = "082004030010",	-- Archive of Faith,                               	Healer
	[147007] = "082004030010",	-- The Deceiver's Grand Design,                    	Healer
	[147009] = "124002607443",	-- Infernal Cinders,                               	Damage, Melee
	[147010] = "124002607743",	-- Cradle of Anguish,                              	Damage, Strength/Agility
	[147011] = "124002607443",	-- Vial of Ceaseless Toxins,                       	Damage, Melee
	[147012] = "124002607443",	-- Umbral Moonglaives,                             	Damage, Melee
	[147015] = "124002607743",	-- Engine of Eradication,                          	Damage, Strength/Agility
	[147016] = "010771050300",	-- Terror From Below,                              	Damage, Ranged
	[147017] = "010771050300",	-- Tarnished Sentinel Medallion,                   	Damage, Ranged
	[147018] = "010771050300",	-- Spectral Thurible,                              	Damage, Ranged
	[147019] = "010771050300",	-- Tome of Unraveling Sanity,                      	Damage, Ranged
	[147022] = "241000100024",	-- Feverish Carapace,                              	Tank
	[147023] = "241000100024",	-- Leviathan's Hunger,                             	Tank
	[147024] = "241000100024",	-- Reliquary of the Damned,                        	Tank
	[147025] = "241000100024",	-- Recompiled Guardian Module,                     	Tank
	[147026] = "241000100024",	-- Shifting Cosmic Sliver,                         	Tank
	[150522] = "010771040000",	-- The Skull of Gul'dan,                           	Damage, Intellect
	[150523] = "082004030010",	-- Memento of Tyrande,                             	Healer
	[150526] = "365002707767",	-- Shadowmoon Insignia,                            	Strength/Agility
	[150527] = "365002707767",	-- Madness of the Betrayer,                        	Strength/Agility
	[151190] = "124002607443",	-- Specter of Betrayal,                            	Damage, Melee
	[151307] = "124002607743",	-- Void Stalker's Contract,                        	Damage, Strength/Agility
	[151310] = "010771050000",	-- Reality Breacher,                               	Damage, Intellect
	[151312] = "241000100024",	-- Ampoule of Pure Void,                           	Tank
	[151340] = "082004030010",	-- Echo of L'ura,                                  	Healer
	[151955] = "010771050000",	-- Acrid Catalyst Injector,                        	Damage, Intellect
	[151956] = "082004030010",	-- Garothi Feedback Conduit,                       	Healer
	[151957] = "082004030010",	-- Ishkar's Felshield Emitter,                     	Healer
	[151958] = "082004030010",	-- Tarratus Keystone,                              	Healer
	[151960] = "082004030010",	-- Carafe of Searing Light,                        	Healer
	[151962] = "010771050300",	-- Prototype Personnel Decimator,                  	Damage, Ranged
	[151963] = "124002607743",	-- Forgefiend's Fabricator,                        	Damage, Strength/Agility
	[151964] = "124002607443",	-- Seeping Scourgewing,                            	Damage, Melee
	[151968] = "124002607743",	-- Shadow-Singed Fang,                             	Damage, Strength/Agility
	[151969] = "010771050300",	-- Terminus Signaling Beacon,                      	Damage, Ranged
	[151970] = "092775070010",	-- Vitality Resonator,                             	Intellect
	[151971] = "010771050000",	-- Sheath of Asara,                                	Damage, Intellect
	[151974] = "241000100024",	-- Eye of,									    	Tank
	[151975] = "241000100024",	-- Apocalypse Drive,                               	Tank
	[151976] = "241000100024",	-- Riftworld Codex,                                	Tank
	[151977] = "241000100024",	-- Diima's Glacial Aegis,                          	Tank
	[151978] = "241000100024",	-- Smoldering Titanguard,                          	Tank
	[152093] = "124002607443",	-- Gorshalach's Legacy,                            	Damage, Melee
	[152289] = "082004030010",	-- Highfather's Machination,                       	Healer
	[152645] = "241000100024",	-- Eye of Shatug,                                  	Tank
	[153544] = "241000100024",	-- Eye of F'harg,                                  	Tank
	[154172] = "3F7777777777",	-- Aman'Thul's Vision,                             	All Classes
	[154173] = "241000100024",	-- Aggramar's Conviction,                          	Tank
	[154174] = "124002007700",	-- Golganneth's Vitality,                          	Damage, Agility
	[154175] = "082004030010",	-- Eonar's Compassion,                             	Healer
	[154176] = "000000600043",	-- Khaz'goroth's Courage,                          	Damage, Strength
	[154177] = "010771050000",	-- Norgannon's Prowess,                            	Damage, Intellect
	-- Battle for Azeroth
	[155881] = "365002007700",	-- Harlan's Loaded Dice,           	Agility
	[158319] = "365002007700",	-- My'das Talisman,                	Agility
	[158320] = "082004030010",	-- Revitalizing Voodoo Totem,      	Healer
	[158367] = "000000700067",	-- Merektha's Fang,                	Strength
	[158368] = "082004030010",	-- Fangs of Intertwined Essence,   	Healer
	[158374] = "365002007700",	-- Tiny Electromental in a Jar,    	Agility
	[158712] = "000000700067",	-- Rezan's Gleaming Eye,           	Strength
	[159610] = "010771040000",	-- Vessel of Skittering Shadows,   	Damage, Intellect
	[159611] = "000000700067",	-- Razdunk's Big Red Button,       	Strength
	[159612] = "365002007700",	-- Azerokk's Resonating Heart,     	Agility
	[159614] = "365002007700",	-- Galecaller's Boon,              	Agility
	[159615] = "092775070010",	-- Ignition Mage's Fuse,           	Intellect
	[159616] = "000000700067",	-- Gore-Crusted Butcher's Block,   	Strength
	[159617] = "365002007700",	-- Lustrous Golden Plumage,        	Agility
	[159618] = "241000100024",	-- Mchimba's Ritual Bandages,      	Tank
	[159619] = "000000700067",	-- Briny Barnacle,                 	Strength
	[159620] = "092775070010",	-- Conch of Dark Whispers,         	Intellect
	[159622] = "010771040000",	-- Hadal's Nautilus,               	Damage, Intellect
	[159623] = "365002007700",	-- Dead-Eye Spyglass,              	Agility
	[159624] = "010771040000",	-- Rotcrusted Voodoo Doll,         	Damage, Intellect
	[159625] = "000000700067",	-- Vial of Animated Blood,         	Strength
	[159626] = "241000100024",	-- Lingering Sporepods,            	Tank
	[159627] = "000000700067",	-- Jes' Howler,                    	Strength
	[159628] = "365002007700",	-- Kul Tiran Cannonball Runner,    	Agility
	[159630] = "092775070010",	-- Balefire Branch,                	Intellect
	[159631] = "092775070010",	-- Lady Waycrest's Music Box,      	Intellect
	[160648] = "365002007700",	-- Frenetic Corpuscle,             	Agility
	[160649] = "082004030010",	-- Inoculating Extract,            	Healer
	[160650] = "000000700067",	-- Disc of Systematic Regression,  	Strength
	[160651] = "010771040000",	-- Vigilant's Bloodshaper,         	Damage, Intellect
	[160652] = "365002007700",	-- Construct Overcharger,          	Agility
	[160653] = "241000100024",	-- Xalzaix's Veiled Eye,           	Tank
	[160654] = "375773747767",	-- Vanquished Tendril of G'huun,
	[160655] = "000000700067",	-- Syringe of Bloodborne Infirmity,	Strength
	[160656] = "092775070010",	-- Twitching Tentacle of Xalzaix,  	Intellect
	[161376] = "000000700067",	-- Prism of Dark Intensity,        	Strength
	[161377] = "092775070010",	-- Azurethos' Singed Plumage,      	Intellect
	[161378] = "365002007700",	-- Plume of the Seaborne Avian,    	Agility
	[161379] = "000000700067",	-- Galecaller's Beak,              	Strength
	[161380] = "092775070010",	-- Drust-Runed Icicle,             	Intellect
	[161381] = "365002007700",	-- Permafrost-Encrusted Heart,     	Agility
	[161411] = "092775070010",	-- T'zane's Barkspines,            	Intellect
	[161412] = "365002007700",	-- Spiritbound Voodoo Burl,        	Agility
	[161419] = "000000700067",	-- Kraulok's Claw,                 	Strength
	[161472] = "092775070010",	-- Lion's Grace,                   	Intellect
	[161473] = "365002007700",	-- Lion's Guile,                   	Agility
	[161474] = "000000700067",	-- Lion's Strength,                	Strength
}
