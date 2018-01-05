--- trinketData.lua
-- Contains usable classes of all trinkets which cant be used by all classes in the dungeon journal
-- @author Safetee
-- Create Date : 12/03/2017
-- Update Date : 12/18/2017 (7.3.2 Build 25549)

--@debug@
-- This function is used for developer.
-- Export all trinkets in the encounter journal not usable by all classes.
-- The format is {[itemID] = classFlag}
-- See the explanation of classFlag in RCLootCouncil:GetItemClassesAllowedFlag(item)
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
	local TIME_FOR_EACH_INSTANCE_DIFF = 2

	if not nextTier then
		nextTier = 1
		nextIsRaid = 0
		nextIndex = 1
		nextDiffID = 1
		self:Print("Exporting the class data of all trinkets in the dungeon journal\n"
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
			..",\t-- "..format(exp, trinketNames[entry[1]]..",").."\n"
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

-- Automatically generated by command "/rc exporttrinketdata"
-- The code related to above command is commented out for Curseforge release because
-- this is intended to be run by the developer.
-- The table indicates if the trinket is usable for certain classes.
-- Only contains trinket in the current expansion by far in the Encounter Journal
-- Format: [itemID] = classFlag
-- See the explanation of classFlag in RCLootCouncil:GetItemClassesAllowedFlag(item) in core.lua

_G.RCtrinketSpecs = {
	[11810] = 0xE23,	-- Force of Will,                                  	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[11815] = 0xE6F,	-- Hand of Justice,                                	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[11819] = 0x652,	-- Second Wind,                                    	Paladin, Priest, Shaman, Monk, Druid
	[11832] = 0x7D2,	-- Burst of Knowledge,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[18371] = 0x652,	-- Mindtap Talisman,                               	Paladin, Priest, Shaman, Monk, Druid
	[22321] = 0xE6F,	-- Heart of Wyrmthalak,                            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[24390] = 0x7D2,	-- Auslese's Light Channeler,                      	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[26055] = 0x7D2,	-- Oculus of the Hidden Eye,                       	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[27416] = 0xE6D,	-- Fetish of the Fallen,                           	Warrior, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[27683] = 0x7D2,	-- Quagmirran's Eye,                               	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[27770] = 0xE23,	-- Argussian Compass,                              	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[27828] = 0x652,	-- Warp-Scarab Brooch,                             	Paladin, Priest, Shaman, Monk, Druid
	[27896] = 0x652,	-- Alembic of Infernal Power,                      	Paladin, Priest, Shaman, Monk, Druid
	[28034] = 0xE6F,	-- Hourglass of the Unraveller,                    	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[28190] = 0x7D2,	-- Scarab of the Infinite Cycle,                   	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[28288] = 0xE6F,	-- Abacus of Violent Odds,                         	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[28370] = 0x652,	-- Bangle of Endless Blessings,                    	Paladin, Priest, Shaman, Monk, Druid
	[28418] = 0x5D0,	-- Shiffar's Nexus-Horn,                           	Priest, Shaman, Mage, Warlock, Druid
	[28590] = 0x7D2,	-- Ribbon of Sacrifice,                            	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[28727] = 0x7D2,	-- Pendant of the Violet Eye,                      	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[28789] = 0x7D2,	-- Eye of Magtheridon,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[28823] = 0x7D2,	-- Eye of Gruul,                                   	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[28830] = 0xE6F,	-- Dragonspine Trophy,                             	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[30665] = 0x010,	-- Earring of Soulful Meditation,                  	Priest
	[32483] = 0x7D2,	-- The Skull of Gul'dan,                           	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[32496] = 0x7D2,	-- Memento of Tyrande,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[32505] = 0xE6F,	-- Madness of the Betrayer,                        	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[34430] = 0x7D2,	-- Glimmering Naaru Sliver,                        	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[34470] = 0x7D2,	-- Timbal's Focusing Crystal,                      	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[34472] = 0xE6F,	-- Shard of Contempt,                              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[34473] = 0xE23,	-- Commendation of Kael'thas,                      	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[36972] = 0x7D2,	-- Tome of Arcane Phenomena,                       	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[36993] = 0xE23,	-- Seal of the Pantheon,                           	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[37064] = 0xE6F,	-- Vestige of Haldor,                              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[37111] = 0x7D2,	-- Soul Preserver,                                 	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[37166] = 0xE6F,	-- Sphere of Red Dragon's Blood,                   	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[37220] = 0xE23,	-- Essence of Gossamer,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[37264] = 0x5D0,	-- Pendulum of Telluric Currents,                  	Priest, Shaman, Mage, Warlock, Druid
	[37390] = 0xE6F,	-- Meteorite Whetstone,                            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[37638] = 0xE23,	-- Offering of Sacrifice,                          	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[37657] = 0x652,	-- Spark of Life,                                  	Paladin, Priest, Shaman, Monk, Druid
	[37660] = 0x7D2,	-- Forge Ember,                                    	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[37723] = 0xE6F,	-- Incisor Fragment,                               	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[37844] = 0x652,	-- Winged Talisman,                                	Paladin, Priest, Shaman, Monk, Druid
	[37872] = 0x003,	-- Lavanthor's Talisman,                           	Warrior, Paladin
	[37873] = 0x7D2,	-- Mark of the War Prisoner,                       	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[39229] = 0x7D2,	-- Embrace of the Spider,                          	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[40258] = 0x7D2,	-- Forethought Talisman,                           	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[40371] = 0xE6F,	-- Bandit's Insignia,                              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[45466] = 0x7D2,	-- Scale of Fates,                                 	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[45490] = 0x7D2,	-- Pandora's Plea,                                 	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[45535] = 0x7D2,	-- Show of Faith,                                  	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[45609] = 0xE6F,	-- Comet's Trail,                                  	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[45929] = 0x7D2,	-- Sif's Remembrance,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[46038] = 0xE6F,	-- Dark Matter,                                    	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[46051] = 0x7D2,	-- Meteorite Crystal,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[47213] = 0x5D0,	-- Abyssal Rune,                                   	Priest, Shaman, Mage, Warlock, Druid
	[47214] = 0xE6F,	-- Banner of Victory,                              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[47215] = 0x7D2,	-- Tears of the Vanquished,                        	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[47216] = 0xE23,	-- The Black Heart,                                	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[47271] = 0x7D2,	-- Solace of the Fallen,                           	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[47303] = 0xE6F,	-- Death's Choice,                                 	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[47316] = 0x7D2,	-- Reign of the Dead,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[47432] = 0x7D2,	-- Solace of the Fallen,                           	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[47464] = 0xE6F,	-- Death's Choice,                                 	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[47477] = 0x7D2,	-- Reign of the Dead,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[50198] = 0xE6F,	-- Needle-Encrusted Scorpion,                      	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[50235] = 0xE23,	-- Ick's Rotting Thumb,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[50259] = 0x7D2,	-- Nevermelting Ice Crystal,                       	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[50260] = 0x652,	-- Ephemeral Snowflake,                            	Paladin, Priest, Shaman, Monk, Druid
	[50339] = 0x7D2,	-- Sliver of Pure Ice,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[50346] = 0x7D2,	-- Sliver of Pure Ice,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[50359] = 0x7D2,	-- Althor's Abacus,                                	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[50366] = 0x7D2,	-- Althor's Abacus,                                	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[54573] = 0x7D2,	-- Glowing Twilight Scale,                         	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[54589] = 0x7D2,	-- Glowing Twilight Scale,                         	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[55266] = 0xE4C,	-- Grace of the Herald,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[55787] = 0x7D2,	-- Witching Hourglass,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[55810] = 0x7D2,	-- Tendrils of Burrowing Dark,                     	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[55814] = 0x023,	-- Magnetite Mirror,                               	Warrior, Paladin, Death Knight
	[55816] = 0xE23,	-- Leaden Despair,                                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[55819] = 0x7D2,	-- Tear of Blood,                                  	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[55845] = 0xE23,	-- Heart of Thunder,                               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[55874] = 0xE4C,	-- Tia's Grace,                                    	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[55879] = 0x5D0,	-- Sorrowsong,                                     	Priest, Shaman, Mage, Warlock, Druid
	[55995] = 0x652,	-- Blood of Isiset,                                	Paladin, Priest, Shaman, Monk, Druid
	[56102] = 0xE4C,	-- Left Eye of Rajh,                               	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[56115] = 0xE4C,	-- Skardyn's Grace,                                	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[56132] = 0x023,	-- Mark of Khardros,                               	Warrior, Paladin, Death Knight
	[56136] = 0x652,	-- Corrupted Egg Shell,                            	Paladin, Priest, Shaman, Monk, Druid
	[56295] = 0xE4C,	-- Grace of the Herald,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[56320] = 0x7D2,	-- Witching Hourglass,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[56339] = 0x6D2,	-- Tendrils of Burrowing Dark,                     	Paladin, Priest, Shaman, Mage, Monk, Druid
	[56345] = 0x023,	-- Magnetite Mirror,                               	Warrior, Paladin, Death Knight
	[56347] = 0xE23,	-- Leaden Despair,                                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[56351] = 0x7D2,	-- Tear of Blood,                                  	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[56370] = 0xE23,	-- Heart of Thunder,                               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[56394] = 0xE4C,	-- Tia's Grace,                                    	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[56400] = 0x5D0,	-- Sorrowsong,                                     	Priest, Shaman, Mage, Warlock, Druid
	[56414] = 0x652,	-- Blood of Isiset,                                	Paladin, Priest, Shaman, Monk, Druid
	[56427] = 0xE4C,	-- Left Eye of Rajh,                               	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[56440] = 0xE4C,	-- Skardyn's Grace,                                	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[56458] = 0x023,	-- Mark of Khardros,                               	Warrior, Paladin, Death Knight
	[56463] = 0x652,	-- Corrupted Egg Shell,                            	Paladin, Priest, Shaman, Monk, Druid
	[59224] = 0x023,	-- Heart of Rage,                                  	Warrior, Paladin, Death Knight
	[59332] = 0xE23,	-- Symbiotic Worm,                                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[59354] = 0x652,	-- Jar of Ancient Remedies,                        	Paladin, Priest, Shaman, Monk, Druid
	[59441] = 0xE4C,	-- Prestor's Talisman of Machination,              	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[59473] = 0xE4C,	-- Essence of the Cyclone,                         	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[59500] = 0x7D2,	-- Fall of Mortality,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[59506] = 0x023,	-- Crushing Weight,                                	Warrior, Paladin, Death Knight
	[59519] = 0x7D2,	-- Theralion's Mirror,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[61033] = 0xE4C,	-- Vicious Gladiator's Badge of Conquest,          	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[61047] = 0xE4C,	-- Vicious Gladiator's Insignia of Conquest,       	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[65026] = 0xE4C,	-- Prestor's Talisman of Machination,              	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[65029] = 0x652,	-- Jar of Ancient Remedies,                        	Paladin, Priest, Shaman, Monk, Druid
	[65048] = 0xE23,	-- Symbiotic Worm,                                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[65072] = 0x023,	-- Heart of Rage,                                  	Warrior, Paladin, Death Knight
	[65105] = 0x7D2,	-- Theralion's Mirror,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[65118] = 0x023,	-- Crushing Weight,                                	Warrior, Paladin, Death Knight
	[65124] = 0x7D2,	-- Fall of Mortality,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[65140] = 0xE4C,	-- Essence of the Cyclone,                         	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[68925] = 0x7D2,	-- Variable Pulse Lightning Capacitor,             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[68926] = 0x7D2,	-- Jaws of Defeat,                                 	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[68927] = 0xE4C,	-- The Hungerer,                                   	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[68981] = 0xE23,	-- Spidersilk Spindle,                             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[68982] = 0x7D2,	-- Necromantic Focus,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[68983] = 0x7D2,	-- Eye of Blazing Power,                           	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[68994] = 0xE4C,	-- Matrix Restabilizer,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[68995] = 0x023,	-- Vessel of Acceleration,                         	Warrior, Paladin, Death Knight
	[69110] = 0x7D2,	-- Variable Pulse Lightning Capacitor,             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[69111] = 0x7D2,	-- Jaws of Defeat,                                 	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[69112] = 0xE4C,	-- The Hungerer,                                   	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[69138] = 0xE23,	-- Spidersilk Spindle,                             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[69139] = 0x7D2,	-- Necromantic Focus,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[69149] = 0x7D2,	-- Eye of Blazing Power,                           	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[69150] = 0xE4C,	-- Matrix Restabilizer,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[69167] = 0x023,	-- Vessel of Acceleration,                         	Warrior, Paladin, Death Knight
	[70399] = 0xE4C,	-- Ruthless Gladiator's Badge of Conquest,         	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[70400] = 0x023,	-- Ruthless Gladiator's Badge of Victory,          	Warrior, Paladin, Death Knight
	[70401] = 0x7D2,	-- Ruthless Gladiator's Badge of Dominance,        	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[70402] = 0x7D2,	-- Ruthless Gladiator's Insignia of Dominance,     	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[70403] = 0x023,	-- Ruthless Gladiator's Insignia of Victory,       	Warrior, Paladin, Death Knight
	[70404] = 0xE4C,	-- Ruthless Gladiator's Insignia of Conquest,      	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[72897] = 0xE4C,	-- Arrow of Time,                                  	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[72898] = 0x7D2,	-- Foul Gift of the Demon Lord,                    	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[72899] = 0x023,	-- Varo'then's Brooch,                             	Warrior, Paladin, Death Knight
	[72900] = 0xE23,	-- Veil of Lies,                                   	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[72901] = 0x023,	-- Rosary of Light,                                	Warrior, Paladin, Death Knight
	[73491] = 0x023,	-- Cataclysmic Gladiator's Insignia of Victory,    	Warrior, Paladin, Death Knight
	[73496] = 0x023,	-- Cataclysmic Gladiator's Badge of Victory,       	Warrior, Paladin, Death Knight
	[73497] = 0x7D2,	-- Cataclysmic Gladiator's Insignia of Dominance,  	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[73498] = 0x7D2,	-- Cataclysmic Gladiator's Badge of Dominance,     	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[73643] = 0xE4C,	-- Cataclysmic Gladiator's Insignia of Conquest,   	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[73648] = 0xE4C,	-- Cataclysmic Gladiator's Badge of Conquest,      	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[77197] = 0xE4C,	-- Wrath of Unchaining,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[77198] = 0x5D0,	-- Will of Unbinding,                              	Priest, Shaman, Mage, Warlock, Druid
	[77199] = 0x7D2,	-- Heart of Unliving,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[77200] = 0x023,	-- Eye of Unmaking,                                	Warrior, Paladin, Death Knight
	[77201] = 0xE23,	-- Resolve of Undying,                             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[77202] = 0xE4C,	-- Starcatcher Compass,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[77203] = 0x7D2,	-- Insignia of the Corrupted Mind,                 	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[77204] = 0x7D2,	-- Seal of the Seven Signs,                        	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[77205] = 0x023,	-- Creche of the Final Dragon,                     	Warrior, Paladin, Death Knight
	[77206] = 0xE23,	-- Soulshifter Vortex,                             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[77207] = 0xE4C,	-- Vial of Shadows,                                	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[77208] = 0x5D0,	-- Cunning of the Cruel,                           	Priest, Shaman, Mage, Warlock, Druid
	[77209] = 0x652,	-- Windward Heart,                                 	Paladin, Priest, Shaman, Monk, Druid
	[77210] = 0x023,	-- Bone-Link Fetish,                               	Warrior, Paladin, Death Knight
	[77211] = 0xE23,	-- Indomitable Pride,                              	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[77989] = 0x7D2,	-- Seal of the Seven Signs,                        	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[77990] = 0xE23,	-- Soulshifter Vortex,                             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[77991] = 0x7D2,	-- Insignia of the Corrupted Mind,                 	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[77992] = 0x023,	-- Creche of the Final Dragon,                     	Warrior, Paladin, Death Knight
	[77993] = 0xE4C,	-- Starcatcher Compass,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[77994] = 0xE4C,	-- Wrath of Unchaining,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[77995] = 0x5D0,	-- Will of Unbinding,                              	Priest, Shaman, Mage, Warlock, Druid
	[77996] = 0x652,	-- Heart of Unliving,                              	Paladin, Priest, Shaman, Monk, Druid
	[77997] = 0x023,	-- Eye of Unmaking,                                	Warrior, Paladin, Death Knight
	[77998] = 0xE23,	-- Resolve of Undying,                             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[77999] = 0xE4C,	-- Vial of Shadows,                                	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[78000] = 0x7D2,	-- Cunning of the Cruel,                           	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[78001] = 0x652,	-- Windward Heart,                                 	Paladin, Priest, Shaman, Monk, Druid
	[78002] = 0x023,	-- Bone-Link Fetish,                               	Warrior, Paladin, Death Knight
	[78003] = 0xE23,	-- Indomitable Pride,                              	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[86131] = 0xE23,	-- Vial of Dragon's Blood,                         	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[86132] = 0xE4C,	-- Bottle of Infinite Stars,                       	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[86133] = 0x5D0,	-- Light of the Cosmos,                            	Priest, Shaman, Mage, Warlock, Druid
	[86144] = 0x023,	-- Lei Shen's Final Orders,                        	Warrior, Paladin, Death Knight
	[86147] = 0x652,	-- Qin-xi's Polarizing Seal,                       	Paladin, Priest, Shaman, Monk, Druid
	[86323] = 0xE23,	-- Stuff of Nightmares,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[86327] = 0x652,	-- Spirits of the Sun,                             	Paladin, Priest, Shaman, Monk, Druid
	[86332] = 0xE4C,	-- Terror in the Mists,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[86336] = 0x023,	-- Darkmist Vortex,                                	Warrior, Paladin, Death Knight
	[86388] = 0x5D0,	-- Essence of Terror,                              	Priest, Shaman, Mage, Warlock, Druid
	[87057] = 0xE4C,	-- Bottle of Infinite Stars,                       	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[87063] = 0xE23,	-- Vial of Dragon's Blood,                         	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[87065] = 0x5D0,	-- Light of the Cosmos,                            	Priest, Shaman, Mage, Warlock, Druid
	[87072] = 0x023,	-- Lei Shen's Final Orders,                        	Warrior, Paladin, Death Knight
	[87075] = 0x652,	-- Qin-xi's Polarizing Seal,                       	Paladin, Priest, Shaman, Monk, Druid
	[87160] = 0xE23,	-- Stuff of Nightmares,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[87163] = 0x652,	-- Spirits of the Sun,                             	Paladin, Priest, Shaman, Monk, Druid
	[87167] = 0xE4C,	-- Terror in the Mists,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[87172] = 0x023,	-- Darkmist Vortex,                                	Warrior, Paladin, Death Knight
	[87175] = 0x5D0,	-- Essence of Terror,                              	Priest, Shaman, Mage, Warlock, Druid
	[88294] = 0xE4C,	-- Flashing Steel Talisman,                        	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[88355] = 0xE4C,	-- Searing Words,                                  	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[88358] = 0x023,	-- Lessons of the Darkmaster,                      	Warrior, Paladin, Death Knight
	[88360] = 0x652,	-- Price of Progress,                              	Paladin, Priest, Shaman, Monk, Druid
	[94512] = 0xE4C,	-- Renataki's Soul Charm,                          	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[94513] = 0x5D0,	-- Wushoolay's Final Choice,                       	Priest, Shaman, Mage, Warlock, Druid
	[94514] = 0x652,	-- Horridon's Last Gasp,                           	Paladin, Priest, Shaman, Monk, Druid
	[94515] = 0x023,	-- Fabled Feather of Ji-Kun,                       	Warrior, Paladin, Death Knight
	[94516] = 0xE23,	-- Fortitude of the Zandalari,                     	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[94518] = 0xE23,	-- Delicate Vial of the Sanguinaire,               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[94519] = 0x023,	-- Primordius' Talisman of Rage,                   	Warrior, Paladin, Death Knight
	[94520] = 0x652,	-- Inscribed Bag of Hydra-Spawn,                   	Paladin, Priest, Shaman, Monk, Druid
	[94521] = 0x5D0,	-- Breath of the Hydra,                            	Priest, Shaman, Mage, Warlock, Druid
	[94522] = 0xE4C,	-- Talisman of Bloodlust,                          	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[94523] = 0xE4C,	-- Bad Juju,                                       	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[94524] = 0x5D0,	-- Unerring Vision of Lei Shen,                    	Priest, Shaman, Mage, Warlock, Druid
	[94525] = 0x652,	-- Stolen Relic of Zuldazar,                       	Paladin, Priest, Shaman, Monk, Druid
	[94526] = 0x023,	-- Spark of Zandalar,                              	Warrior, Paladin, Death Knight
	[94527] = 0xE23,	-- Ji-Kun's Rising Winds,                          	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[94528] = 0xE23,	-- Soul Barrier,                                   	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[94529] = 0x023,	-- Gaze of the Twins,                              	Warrior, Paladin, Death Knight
	[94530] = 0x652,	-- Lightning-Imbued Chalice,                       	Paladin, Priest, Shaman, Monk, Druid
	[94531] = 0x5D0,	-- Cha-Ye's Essence of Brilliance,                 	Priest, Shaman, Mage, Warlock, Druid
	[94532] = 0xE4C,	-- Rune of Re-Origination,                         	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[96369] = 0xE4C,	-- Renataki's Soul Charm,                          	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[96385] = 0x652,	-- Horridon's Last Gasp,                           	Paladin, Priest, Shaman, Monk, Druid
	[96398] = 0x023,	-- Spark of Zandalar,                              	Warrior, Paladin, Death Knight
	[96409] = 0xE4C,	-- Bad Juju,                                       	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[96413] = 0x5D0,	-- Wushoolay's Final Choice,                       	Priest, Shaman, Mage, Warlock, Druid
	[96421] = 0xE23,	-- Fortitude of the Zandalari,                     	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[96455] = 0x5D0,	-- Breath of the Hydra,                            	Priest, Shaman, Mage, Warlock, Druid
	[96456] = 0x652,	-- Inscribed Bag of Hydra-Spawn,                   	Paladin, Priest, Shaman, Monk, Druid
	[96470] = 0x023,	-- Fabled Feather of Ji-Kun,                       	Warrior, Paladin, Death Knight
	[96471] = 0xE23,	-- Ji-Kun's Rising Winds,                          	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[96492] = 0xE4C,	-- Talisman of Bloodlust,                          	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[96501] = 0x023,	-- Primordius' Talisman of Rage,                   	Warrior, Paladin, Death Knight
	[96507] = 0x652,	-- Stolen Relic of Zuldazar,                       	Paladin, Priest, Shaman, Monk, Druid
	[96516] = 0x5D0,	-- Cha-Ye's Essence of Brilliance,                 	Priest, Shaman, Mage, Warlock, Druid
	[96523] = 0xE23,	-- Delicate Vial of the Sanguinaire,               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[96543] = 0x023,	-- Gaze of the Twins,                              	Warrior, Paladin, Death Knight
	[96546] = 0xE4C,	-- Rune of Re-Origination,                         	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[96555] = 0xE23,	-- Soul Barrier,                                   	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[96558] = 0x5D0,	-- Unerring Vision of Lei Shen,                    	Priest, Shaman, Mage, Warlock, Druid
	[96561] = 0x652,	-- Lightning-Imbued Chalice,                       	Paladin, Priest, Shaman, Monk, Druid
	[109995] = 0xE4C,	-- Blood Seal of Azzakel,                          	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[109996] = 0xE4C,	-- Thundertower's Targeting Reticle,               	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[109997] = 0xE4C,	-- Kihra's Adrenaline Injector,                    	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[109998] = 0xE4C,	-- Gor'ashan's Lodestone Spike,                    	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[109999] = 0xE4C,	-- Witherbark's Branch,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[110000] = 0x5D0,	-- Crushto's Runic Alarm,                          	Priest, Shaman, Mage, Warlock, Druid
	[110001] = 0x5D0,	-- Tovra's Lightning Repository,                   	Priest, Shaman, Mage, Warlock, Druid
	[110002] = 0x5D0,	-- Fleshrender's Meathook,                         	Priest, Shaman, Mage, Warlock, Druid
	[110003] = 0x5D0,	-- Ragewing's Firefang,                            	Priest, Shaman, Mage, Warlock, Druid
	[110004] = 0x5D0,	-- Coagulated Genesaur Blood,                      	Priest, Shaman, Mage, Warlock, Druid
	[110005] = 0x652,	-- Crystalline Blood Drop,                         	Paladin, Priest, Shaman, Monk, Druid
	[110006] = 0x652,	-- Rukhran's Quill,                                	Paladin, Priest, Shaman, Monk, Druid
	[110007] = 0x652,	-- Voidmender's Shadowgem,                         	Paladin, Priest, Shaman, Monk, Druid
	[110008] = 0x652,	-- Tharbek's Lucky Pebble,                         	Paladin, Priest, Shaman, Monk, Druid
	[110009] = 0x652,	-- Leaf of the Ancient Protectors,                 	Paladin, Priest, Shaman, Monk, Druid
	[110010] = 0x023,	-- Mote of Corruption,                             	Warrior, Paladin, Death Knight
	[110011] = 0x023,	-- Fires of the Sun,                               	Warrior, Paladin, Death Knight
	[110012] = 0x023,	-- Bonemaw's Big Toe,                              	Warrior, Paladin, Death Knight
	[110013] = 0x023,	-- Emberscale Talisman,                            	Warrior, Paladin, Death Knight
	[110014] = 0x023,	-- Spores of Alacrity,                             	Warrior, Paladin, Death Knight
	[110015] = 0x623,	-- Toria's Unseeing Eye,                           	Warrior, Paladin, Death Knight, Monk, Druid
	[110016] = 0xE23,	-- Solar Containment Unit,                         	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[110017] = 0xE23,	-- Enforcer's Stun Grenade,                        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[110018] = 0xE23,	-- Kyrak's Vileblood Serum,                        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[110019] = 0xE23,	-- Xeri'tac's Unhatched Egg Sac,                   	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[112426] = 0x5D0,	-- Purified Bindings of Immerseus,                 	Priest, Shaman, Mage, Warlock, Druid
	[112476] = 0xE23,	-- Rook's Unlucky Talisman,                        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[112503] = 0x023,	-- Fusion-Fire Core,                               	Warrior, Paladin, Death Knight
	[112703] = 0x023,	-- Evil Eye of Galakras,                           	Warrior, Paladin, Death Knight
	[112729] = 0xE23,	-- Juggernaut's Focusing Crystal,                  	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[112754] = 0xE4C,	-- Haromm's Talisman,                              	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[112768] = 0x5D0,	-- Kardris' Toxic Totem,                           	Priest, Shaman, Mage, Warlock, Druid
	[112778] = 0x652,	-- Nazgrim's Burnished Insignia,                   	Paladin, Priest, Shaman, Monk, Druid
	[112792] = 0xE23,	-- Vial of Living Corruption,                      	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[112815] = 0x5D0,	-- Frenzied Crystal of Rage,                       	Priest, Shaman, Mage, Warlock, Druid
	[112825] = 0xE4C,	-- Sigil of Rampage,                               	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[112849] = 0x652,	-- Thok's Acid-Grooved Tooth,                      	Paladin, Priest, Shaman, Monk, Druid
	[112850] = 0x023,	-- Thok's Tail Tip,                                	Warrior, Paladin, Death Knight
	[112877] = 0x652,	-- Dysmorphic Samophlange of Discontinuity,        	Paladin, Priest, Shaman, Monk, Druid
	[112879] = 0xE4C,	-- Ticking Ebon Detonator,                         	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[112913] = 0x023,	-- Skeer's Bloodsoaked Talisman,                   	Warrior, Paladin, Death Knight
	[112924] = 0xE23,	-- Curse of Hubris,                                	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[112938] = 0x5D0,	-- Black Blood of Y'Shaarj,                        	Priest, Shaman, Mage, Warlock, Druid
	[112947] = 0xE4C,	-- Assurance of Consequence,                       	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[112948] = 0x652,	-- Prismatic Prison of Pride,                      	Paladin, Priest, Shaman, Monk, Druid
	[113612] = 0xE4C,	-- Scales of Doom,                                 	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[113645] = 0x023,	-- Tectus' Beating Heart,                          	Warrior, Paladin, Death Knight
	[113650] = 0xE23,	-- Pillar of the Earth,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[113658] = 0x023,	-- Bottle of Infesting Spores,                     	Warrior, Paladin, Death Knight
	[113834] = 0xE23,	-- Pol's Blinded Eye,                              	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[113835] = 0x5D0,	-- Shards of Nothing,                              	Priest, Shaman, Mage, Warlock, Druid
	[113842] = 0x652,	-- Emblem of Caustic Healing,                      	Paladin, Priest, Shaman, Monk, Druid
	[113853] = 0xE4C,	-- Captive Micro-Aberration,                       	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[113854] = 0x652,	-- Mark of Rapid Replication,                      	Paladin, Priest, Shaman, Monk, Druid
	[113859] = 0x5D0,	-- Quiescent Runestone,                            	Priest, Shaman, Mage, Warlock, Druid
	[113861] = 0xE23,	-- Evergaze Arcane Eidolon,                        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[113889] = 0x652,	-- Elementalist's Shielding Talisman,              	Paladin, Priest, Shaman, Monk, Druid
	[113893] = 0xE23,	-- Blast Furnace Door,                             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[113905] = 0xE23,	-- Tablet of Turnbuckle Teamwork,                  	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[113931] = 0xE4C,	-- Beating Heart of the Mountain,                  	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[113948] = 0x5D0,	-- Darmac's Unstable Talisman,                     	Priest, Shaman, Mage, Warlock, Druid
	[113969] = 0x023,	-- Vial of Convulsive Shadows,                     	Warrior, Paladin, Death Knight
	[113983] = 0x023,	-- Forgemaster's Insignia,                         	Warrior, Paladin, Death Knight
	[113984] = 0x5D0,	-- Blackiron Micro Crucible,                       	Priest, Shaman, Mage, Warlock, Druid
	[113985] = 0xE4C,	-- Humming Blackiron Trigger,                      	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[113986] = 0x652,	-- Auto-Repairing Autoclave,                       	Paladin, Priest, Shaman, Monk, Druid
	[113987] = 0xE23,	-- Battering Talisman,                             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[116289] = 0xE4C,	-- Bloodmaw's Tooth,                               	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[116290] = 0x5D0,	-- Emblem of Gushing Wounds,                       	Priest, Shaman, Mage, Warlock, Druid
	[116291] = 0x652,	-- Immaculate Living Mushroom,                     	Paladin, Priest, Shaman, Monk, Druid
	[116292] = 0x023,	-- Mote of the Mountain,                           	Warrior, Paladin, Death Knight
	[116293] = 0xE23,	-- Idol of Suppression,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[116314] = 0xE4C,	-- Blackheart Enforcer's Medallion,                	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[116315] = 0x5D0,	-- Furyheart Talisman,                             	Priest, Shaman, Mage, Warlock, Druid
	[116316] = 0x652,	-- Captured Flickerspark,                          	Paladin, Priest, Shaman, Monk, Druid
	[116317] = 0x023,	-- Storage House Key,                              	Warrior, Paladin, Death Knight
	[116318] = 0xE23,	-- Stoneheart Idol,                                	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[118114] = 0xE4C,	-- Meaty Dragonspine Trophy,                       	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[119192] = 0x652,	-- Ironspike Chew Toy,                             	Paladin, Priest, Shaman, Monk, Druid
	[119193] = 0x023,	-- Horn of Screaming Spirits,                      	Warrior, Paladin, Death Knight
	[119194] = 0x5D0,	-- Goren Soul Repository,                          	Priest, Shaman, Mage, Warlock, Druid
	[123992] = 0x003,	-- Figurine of the Colossus,                       	Warrior, Paladin
	[124223] = 0xE4C,	-- Fel-Spring Coil,                                	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[124224] = 0xE4C,	-- Mirror of the Blademaster,                      	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[124225] = 0xE4C,	-- Soul Capacitor,                                 	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[124226] = 0xE4C,	-- Malicious Censer,                               	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[124227] = 0x5D0,	-- Iron Reaver Piston,                             	Priest, Shaman, Mage, Warlock, Druid
	[124228] = 0x5D0,	-- Desecrated Shadowmoon Insignia,                 	Priest, Shaman, Mage, Warlock, Druid
	[124229] = 0x5D0,	-- Unblinking Gaze of Sethe,                       	Priest, Shaman, Mage, Warlock, Druid
	[124230] = 0x5D0,	-- Prophecy of Fear,                               	Priest, Shaman, Mage, Warlock, Druid
	[124231] = 0x652,	-- Flickering Felspark,                            	Paladin, Priest, Shaman, Monk, Druid
	[124232] = 0x652,	-- Intuition's Gift,                               	Paladin, Priest, Shaman, Monk, Druid
	[124233] = 0x652,	-- Demonic Phylactery,                             	Paladin, Priest, Shaman, Monk, Druid
	[124234] = 0x652,	-- Unstable Felshadow Emulsion,                    	Paladin, Priest, Shaman, Monk, Druid
	[124235] = 0x023,	-- Rumbling Pebble,                                	Warrior, Paladin, Death Knight
	[124236] = 0x023,	-- Unending Hunger,                                	Warrior, Paladin, Death Knight
	[124237] = 0x023,	-- Discordant Chorus,                              	Warrior, Paladin, Death Knight
	[124238] = 0x023,	-- Empty Drinking Horn,                            	Warrior, Paladin, Death Knight
	[124239] = 0xE23,	-- Imbued Stone Sigil,                             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[124240] = 0xE23,	-- Warlord's Unseeing Eye,                         	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[124241] = 0xE23,	-- Anzu's Cursed Plume,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[124242] = 0xE23,	-- Tyrant's Decree,                                	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[124513] = 0x020,	-- Reaper's Harvest,                               	Death Knight
	[124514] = 0x400,	-- Seed of Creation,                               	Druid
	[124515] = 0x004,	-- Talisman of the Master Tracker,                 	Hunter
	[124516] = 0x080,	-- Tome of Shifting Words,                         	Mage
	[124517] = 0x200,	-- Sacred Draenic Incense,                         	Monk
	[124518] = 0x002,	-- Libram of Vindication,                          	Paladin
	[124519] = 0x010,	-- Repudiation of War,                             	Priest
	[124520] = 0x008,	-- Bleeding Hollow Toxin Vessel,                   	Rogue
	[124521] = 0x040,	-- Core of the Primal Elements,                    	Shaman
	[124522] = 0x100,	-- Fragment of the Dark Star,                      	Warlock
	[124523] = 0x001,	-- Worldbreaker's Resolve,                         	Warrior
	[127173] = 0x7D2,	-- Shiffar's Nexus-Horn,                           	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[127184] = 0xE23,	-- Runed Fungalcap,                                	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[127201] = 0x5D0,	-- Quagmirran's Eye,                               	Priest, Shaman, Mage, Warlock, Druid
	[127245] = 0x7D2,	-- Warp-Scarab Brooch,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[127441] = 0xE6F,	-- Hourglass of the Unraveller,                    	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[127448] = 0x652,	-- Scarab of the Infinite Cycle,                   	Paladin, Priest, Shaman, Monk, Druid
	[127474] = 0xE6F,	-- Vestige of Haldor,                              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[127493] = 0xE6F,	-- Meteorite Whetstone,                            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[127512] = 0x7D2,	-- Winged Talisman,                                	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[127550] = 0xE23,	-- Offering of Sacrifice,                          	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[127594] = 0xE6F,	-- Sphere of Red Dragon's Blood,                   	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[128140] = 0xE4C,	-- Smoldering Felblade Remnant,                    	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[128141] = 0x7D2,	-- Crackling Fel-Spark Plug,                       	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[128142] = 0x7D2,	-- Pledge of Iron Loyalty,                         	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[128143] = 0x023,	-- Fragmented Runestone Etching,                   	Warrior, Paladin, Death Knight
	[128144] = 0xE6F,	-- Vial of Vile Viscera,                           	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[128145] = 0xE4C,	-- Howling Soul Gem,                               	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[128146] = 0x7D2,	-- Ensnared Orb of the Sky,                        	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[128147] = 0x7D2,	-- Teardrop of Blood,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[128148] = 0x023,	-- Fetid Salivation,                               	Warrior, Paladin, Death Knight
	[128149] = 0xE6F,	-- Accusation of Inferiority,                      	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[128150] = 0xE4C,	-- Pressure-Compressed Loop,                       	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[128151] = 0x7D2,	-- Portent of Disaster,                            	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[128152] = 0x7D2,	-- Decree of Demonic Sovereignty,                  	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[128153] = 0x023,	-- Unquenchable Doomfire Censer,                   	Warrior, Paladin, Death Knight
	[128154] = 0xE6F,	-- Grasp of the Defiler,                           	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[133192] = 0xE6F,	-- Porcelain Crab,                                 	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[133197] = 0x023,	-- Might of the Ocean,                             	Warrior, Paladin, Death Knight
	[133201] = 0x7D2,	-- Sea Star,                                       	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[133206] = 0xE4C,	-- Key to the Endless Chamber,                     	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[133216] = 0x7D2,	-- Tendrils of Burrowing Dark,                     	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[133222] = 0x023,	-- Magnetite Mirror,                               	Warrior, Paladin, Death Knight
	[133224] = 0xE23,	-- Leaden Despair,                                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[133227] = 0x652,	-- Tear of Blood,                                  	Paladin, Priest, Shaman, Monk, Druid
	[133246] = 0xE23,	-- Heart of Thunder,                               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[133252] = 0x652,	-- Rainsong,                                       	Paladin, Priest, Shaman, Monk, Druid
	[133268] = 0x023,	-- Heart of Solace,                                	Warrior, Paladin, Death Knight
	[133269] = 0xE4C,	-- Tia's Grace,                                    	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[133275] = 0x5D0,	-- Sorrowsong,                                     	Priest, Shaman, Mage, Warlock, Druid
	[133281] = 0xA23,	-- Impetuous Query,                                	Warrior, Paladin, Death Knight, Monk, Demon Hunter
	[133282] = 0xE4C,	-- Skardyn's Grace,                                	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[133291] = 0xA23,	-- Throngus's Finger,                              	Warrior, Paladin, Death Knight, Monk, Demon Hunter
	[133300] = 0x023,	-- Mark of Khardros,                               	Warrior, Paladin, Death Knight
	[133304] = 0x7D2,	-- Gale of Shadows,                                	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[133305] = 0x652,	-- Corrupted Egg Shell,                            	Paladin, Priest, Shaman, Monk, Druid
	[133420] = 0xE4C,	-- Arrow of Time,                                  	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[133461] = 0x5D0,	-- Timbal's Focusing Crystal,                      	Priest, Shaman, Mage, Warlock, Druid
	[133462] = 0x652,	-- Vial of the Sunwell,                            	Paladin, Priest, Shaman, Monk, Druid
	[133463] = 0xE6F,	-- Shard of Contempt,                              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[133464] = 0xE23,	-- Commendation of Kael'thas,                      	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[133641] = 0x5D4,	-- Eye of Skovald,                                 	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[133644] = 0xE6F,	-- Memento of Angerboda,                           	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[133645] = 0x652,	-- Naglfar Fare,                                   	Paladin, Priest, Shaman, Monk, Druid
	[133646] = 0x652,	-- Mote of Sanctification,                         	Paladin, Priest, Shaman, Monk, Druid
	[133647] = 0xE23,	-- Gift of Radiance,                               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[133766] = 0x652,	-- Nether Anti-Toxin,                              	Paladin, Priest, Shaman, Monk, Druid
	[136714] = 0x652,	-- Amalgam's Seventh Spine,                        	Paladin, Priest, Shaman, Monk, Druid
	[136715] = 0xE6F,	-- Spiked Counterweight,                           	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[136716] = 0x5D4,	-- Caged Horror,                                   	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[136975] = 0xE6F,	-- Hunger of the Pack,                             	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[136978] = 0xE23,	-- Ember of Nullification,                         	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137301] = 0x5D0,	-- Corrupted Starlight,                            	Priest, Shaman, Mage, Warlock, Druid
	[137306] = 0x5D4,	-- Oakheart's Gnarled Root,                        	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[137312] = 0xE6F,	-- Nightmare Egg Shell,                            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137315] = 0xE23,	-- Writhing Heart of Darkness,                     	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137329] = 0x5D4,	-- Figurehead of the Naglfar,                      	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[137338] = 0xE23,	-- Shard of Rokmora,                               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137344] = 0xE23,	-- Talisman of the Cragshaper,                     	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137349] = 0x5D4,	-- Naraxas' Spiked Tongue,                         	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[137357] = 0xE6F,	-- Mark of Dargrul,                                	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137362] = 0xE23,	-- Parjesh's Medallion,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137367] = 0x5D4,	-- Stormsinger Fulmination Charge,                 	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[137369] = 0xE6F,	-- Giant Ornamental Pearl,                         	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137373] = 0xE4C,	-- Tempered Egg of Serpentrix,                     	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[137378] = 0x652,	-- Bottled Hurricane,                              	Paladin, Priest, Shaman, Monk, Druid
	[137398] = 0x5D0,	-- Portable Manacracker,                           	Priest, Shaman, Mage, Warlock, Druid
	[137400] = 0xE23,	-- Coagulated Nightwell Residue,                   	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137406] = 0xE6F,	-- Terrorbound Nexus,                              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137430] = 0xE23,	-- Impenetrable Nerubian Husk,                     	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137433] = 0x7D6,	-- Obelisk of the Void,                            	Paladin, Hunter, Priest, Shaman, Mage, Warlock, Monk, Druid
	[137439] = 0xE6F,	-- Tiny Oozeling in a Jar,                         	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137440] = 0xE23,	-- Shivermaw's Jawbone,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137446] = 0x5D4,	-- Elementium Bomb Squirrel Generator,             	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[137452] = 0x652,	-- Thrumming Gossamer,                             	Paladin, Priest, Shaman, Monk, Druid
	[137459] = 0xE6F,	-- Chaos Talisman,                                 	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137462] = 0x652,	-- Jewel of Insatiable Desire,                     	Paladin, Priest, Shaman, Monk, Druid
	[137484] = 0x652,	-- Flask of the Solemn Night,                      	Paladin, Priest, Shaman, Monk, Druid
	[137485] = 0x5D0,	-- Infernal Writ,                                  	Priest, Shaman, Mage, Warlock, Druid
	[137486] = 0xE6F,	-- Windscar Whetstone,                             	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137537] = 0xE4C,	-- Tirathon's Betrayal,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[137538] = 0xE23,	-- Orb of Torment,                                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137539] = 0xE6F,	-- Faulty Countermeasure,                          	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137540] = 0x652,	-- Concave Reflecting Lens,                        	Paladin, Priest, Shaman, Monk, Druid
	[137541] = 0x5D4,	-- Moonlit Prism,                                  	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[138222] = 0x652,	-- Vial of Nightmare Fog,                          	Paladin, Priest, Shaman, Monk, Druid
	[138224] = 0x5D4,	-- Unstable Horrorslime,                           	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[138225] = 0xE23,	-- Phantasmal Echo,                                	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[139320] = 0xE6F,	-- Ravaged Seed Pod,                               	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[139321] = 0x5D0,	-- Swarming Plaguehive,                            	Priest, Shaman, Mage, Warlock, Druid
	[139322] = 0x652,	-- Cocoon of Enforced Solitude,                    	Paladin, Priest, Shaman, Monk, Druid
	[139323] = 0x5D4,	-- Twisting Wind,                                  	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[139324] = 0xE23,	-- Goblet of Nightmarish Ichor,                    	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[139325] = 0xE6F,	-- Spontaneous Appendages,                         	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[139326] = 0x5D0,	-- Wriggling Sinew,                                	Priest, Shaman, Mage, Warlock, Druid
	[139327] = 0xE23,	-- Unbridled Fury,                                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[139328] = 0x023,	-- Ursoc's Rending Paw,                            	Warrior, Paladin, Death Knight
	[139329] = 0xE4C,	-- Bloodthirsty Instinct,                          	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[139330] = 0x652,	-- Heightened Senses,                              	Paladin, Priest, Shaman, Monk, Druid
	[139333] = 0x652,	-- Horn of Cenarius,                               	Paladin, Priest, Shaman, Monk, Druid
	[139334] = 0xE6F,	-- Nature's Call,                                  	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[139335] = 0xE23,	-- Grotesque Statuette,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[139336] = 0x5D0,	-- Bough of Corruption,                            	Priest, Shaman, Mage, Warlock, Druid
	[139630] = 0x800,	-- Etching of Sargeras,                            	Demon Hunter
	[140789] = 0xE23,	-- Animated Exoskeleton,                           	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[140790] = 0x023,	-- Claw of the Crystalline Scorpid,                	Warrior, Paladin, Death Knight
	[140791] = 0xE23,	-- Royal Dagger Haft,                              	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[140792] = 0x5D0,	-- Erratic Metronome,                              	Priest, Shaman, Mage, Warlock, Druid
	[140793] = 0x652,	-- Perfectly Preserved Cake,                       	Paladin, Priest, Shaman, Monk, Druid
	[140794] = 0xE4C,	-- Arcanogolem Digit,                              	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[140795] = 0x652,	-- Aluriel's Mirror,                               	Paladin, Priest, Shaman, Monk, Druid
	[140796] = 0xE6F,	-- Entwined Elemental Foci,                        	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[140797] = 0xE23,	-- Fang of Tichondrius,                            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[140798] = 0x5D4,	-- Icon of Rot,                                    	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[140799] = 0x023,	-- Might of Krosus,                                	Warrior, Paladin, Death Knight
	[140800] = 0x5D0,	-- Pharamere's Forbidden Grimoire,                 	Priest, Shaman, Mage, Warlock, Druid
	[140801] = 0x5D4,	-- Fury of the Burning Sky,                        	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[140802] = 0xE4C,	-- Nightblooming Frond,                            	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[140803] = 0x652,	-- Etraeus' Celestial Map,                         	Paladin, Priest, Shaman, Monk, Druid
	[140804] = 0x5D0,	-- Star Gate,                                      	Priest, Shaman, Mage, Warlock, Druid
	[140805] = 0x652,	-- Ephemeral Paradox,                              	Paladin, Priest, Shaman, Monk, Druid
	[140806] = 0xE6F,	-- Convergence of Fates,                           	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[140807] = 0xE23,	-- Infernal Contract,                              	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[140808] = 0xE6F,	-- Draught of Souls,                               	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[140809] = 0x5D0,	-- Whispers in the Dark,                           	Priest, Shaman, Mage, Warlock, Druid
	[141535] = 0x023,	-- Ettin Fingernail,                               	Warrior, Paladin, Death Knight
	[141536] = 0x7D2,	-- Padawsen's Unlucky Charm,                       	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[141537] = 0xE4C,	-- Thrice-Accursed Compass,                        	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[142157] = 0x5D4,	-- Aran's Relaxing Ruby,                           	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[142158] = 0x652,	-- Faith's Crucible,                               	Paladin, Priest, Shaman, Monk, Druid
	[142159] = 0xE6F,	-- Bloodstained Handkerchief,                      	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[142160] = 0x5D4,	-- Mrrgria's Favor,                                	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[142161] = 0xE23,	-- Inescapable Dread,                              	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[142162] = 0x652,	-- Fluctuating Energy,                             	Paladin, Priest, Shaman, Monk, Druid
	[142164] = 0xE6F,	-- Toe Knee's Promise,                             	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[142165] = 0x5D4,	-- Deteriorated Construct Core,                    	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[142167] = 0xE6F,	-- Eye of Command,                                 	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[142168] = 0xE23,	-- Majordomo's Dinner Bell,                        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[142169] = 0xE23,	-- Raven Eidolon,                                  	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[142506] = 0xE4C,	-- Eye of Guarm,                                   	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[142507] = 0x7D2,	-- Brinewater Slime in a Bottle,                   	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[142508] = 0x023,	-- Chains of the Valorous,                         	Warrior, Paladin, Death Knight
	[144113] = 0xE4C,	-- Windswept Pages,                                	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[144119] = 0x7D2,	-- Empty Fruit Barrel,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[144122] = 0x023,	-- Carbonic Carbuncle,                             	Warrior, Paladin, Death Knight
	[144128] = 0xE23,	-- Heart of Fire,                                  	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[144136] = 0x7D2,	-- Vision of the Predator,                         	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[144146] = 0xE23,	-- Iron Protector Talisman,                        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[144156] = 0x7D2,	-- Flashfrozen Resin Globule,                      	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[144157] = 0x7D2,	-- Vial of Ichorous Blood,                         	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[144159] = 0x7D2,	-- Price of Progress,                              	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[144160] = 0xE4C,	-- Searing Words,                                  	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[144161] = 0x023,	-- Lessons of the Darkmaster,                      	Warrior, Paladin, Death Knight
	[144477] = 0xE4C,	-- Splinters of Agronox,                           	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[144480] = 0x7D2,	-- Dreadstone of Endless Shadows,                  	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[144482] = 0x023,	-- Fel-Oiled Infernal Machine,                     	Warrior, Paladin, Death Knight
	[147002] = 0x7D2,	-- Charm of the Rising Tide,                       	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[147003] = 0x652,	-- Barbaric Mindslaver,                            	Paladin, Priest, Shaman, Monk, Druid
	[147004] = 0x652,	-- Sea Star of the Depthmother,                    	Paladin, Priest, Shaman, Monk, Druid
	[147005] = 0x652,	-- Chalice of Moonlight,                           	Paladin, Priest, Shaman, Monk, Druid
	[147006] = 0x652,	-- Archive of Faith,                               	Paladin, Priest, Shaman, Monk, Druid
	[147007] = 0x652,	-- The Deceiver's Grand Design,                    	Paladin, Priest, Shaman, Monk, Druid
	[147009] = 0xE6F,	-- Infernal Cinders,                               	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[147010] = 0xE6F,	-- Cradle of Anguish,                              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[147011] = 0xE6F,	-- Vial of Ceaseless Toxins,                       	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[147012] = 0xE6F,	-- Umbral Moonglaives,                             	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[147015] = 0xE6F,	-- Engine of Eradication,                          	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[147016] = 0x5D4,	-- Terror From Below,                              	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[147017] = 0x5D4,	-- Tarnished Sentinel Medallion,                   	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[147018] = 0x5D4,	-- Spectral Thurible,                              	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[147019] = 0x5D4,	-- Tome of Unraveling Sanity,                      	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[147022] = 0xE23,	-- Feverish Carapace,                              	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[147023] = 0xE23,	-- Leviathan's Hunger,                             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[147024] = 0xE23,	-- Reliquary of the Damned,                        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[147025] = 0xE23,	-- Recompiled Guardian Module,                     	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[147026] = 0xE23,	-- Shifting Cosmic Sliver,                         	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[150522] = 0x5D0,	-- The Skull of Gul'dan,                           	Priest, Shaman, Mage, Warlock, Druid
	[150523] = 0x652,	-- Memento of Tyrande,                             	Paladin, Priest, Shaman, Monk, Druid
	[150526] = 0xE6F,	-- Shadowmoon Insignia,                            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[150527] = 0xE6F,	-- Madness of the Betrayer,                        	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151190] = 0xE6F,	-- Specter of Betrayal,                            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151307] = 0xE6F,	-- Void Stalker's Contract,                        	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151310] = 0x5D0,	-- Reality Breacher,                               	Priest, Shaman, Mage, Warlock, Druid
	[151312] = 0xE23,	-- Ampoule of Pure Void,                           	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[151340] = 0x652,	-- Echo of L'ura,                                  	Paladin, Priest, Shaman, Monk, Druid
	[151955] = 0x5D0,	-- Acrid Catalyst Injector,                        	Priest, Shaman, Mage, Warlock, Druid
	[151956] = 0x652,	-- Garothi Feedback Conduit,                       	Paladin, Priest, Shaman, Monk, Druid
	[151957] = 0x652,	-- Ishkar's Felshield Emitter,                     	Paladin, Priest, Shaman, Monk, Druid
	[151958] = 0x652,	-- Tarratus Keystone,                              	Paladin, Priest, Shaman, Monk, Druid
	[151960] = 0x652,	-- Carafe of Searing Light,                        	Paladin, Priest, Shaman, Monk, Druid
	[151962] = 0x5D4,	-- Prototype Personnel Decimator,                  	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[151963] = 0xE6F,	-- Forgefiend's Fabricator,                        	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151964] = 0xE6F,	-- Seeping Scourgewing,                            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151968] = 0xE6F,	-- Shadow-Singed Fang,                             	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151969] = 0x5D4,	-- Terminus Signaling Beacon,                      	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[151970] = 0x7D2,	-- Vitality Resonator,                             	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[151971] = 0x5D0,	-- Sheath of Asara,                                	Priest, Shaman, Mage, Warlock, Druid
	[151975] = 0xE23,	-- Apocalypse Drive,                               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[151976] = 0xE23,	-- Riftworld Codex,                                	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[151977] = 0xE23,	-- Diima's Glacial Aegis,                          	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[151978] = 0xE23,	-- Smoldering Titanguard,                          	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[152093] = 0xE6F,	-- Gorshalach's Legacy,                            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[152289] = 0x652,	-- Highfather's Machination,                       	Paladin, Priest, Shaman, Monk, Druid
	[152645] = 0xE23,	-- Eye of Shatug,                                  	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[153544] = 0xE23,	-- Eye of F'harg,                                  	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[154173] = 0xE23,	-- Aggramar's Conviction,                          	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[154174] = 0xE4C,	-- Golganneth's Vitality,                          	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[154175] = 0x652,	-- Eonar's Compassion,                             	Paladin, Priest, Shaman, Monk, Druid
	[154176] = 0x023,	-- Khaz'goroth's Courage,                          	Warrior, Paladin, Death Knight
	[154177] = 0x5D0,	-- Norgannon's Prowess,                            	Priest, Shaman, Mage, Warlock, Druid
}
