--- trinketData.lua
-- Contains usable classes of trinkets of Legion expansion up to Patch 7.3.2 Build 25549
-- @author Safetee
-- Create Date : 12/3/2017

--@debug@
-- This function is used for developer.
-- Export all trinkets in the current expansion in the encounter journal not usable by all classes to saved variable.
-- The format is {[itemID] = classFlag}
-- See the explanation of classFlag in RCLootCouncil:GetItemClassesAllowedFlag(item)
local trinketClasses = {}
local trinketNames = {}

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
function RCLootCouncil:ExportTrinketData(nextTier, nextIsRaid, nextIndex, nextDiffIndex)
	LoadAddOn("BLizzard_EncounterJournal")
	local MAX_CLASSFLAG_VAL = bit.lshift(1, MAX_CLASSES) - 1
	local TIME_FOR_EACH_INSTANCE_DIFF = 4

	if not nextTier then
		nextTier = 1
		nextIsRaid = 0
		nextIndex = 1
		nextDiffIndex = 1
		self:Print("Exporting the class data of all current tier trinkets\n"
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
				for diffIndex=nextDiffIndex, #EJ_DIFFICULTIES do
					local entry = EJ_DIFFICULTIES[diffIndex]
					if EJ_IsValidInstanceDifficulty(entry.difficultyID) then
						self:ExportTrinketDataSingleInstance(instanceID, entry.difficultyID, TIME_FOR_EACH_INSTANCE_DIFF)
						return self:ScheduleTimer("ExportTrinketData", TIME_FOR_EACH_INSTANCE_DIFF, nextTier, i, instanceIndex, diffIndex + 1)
					end
				end
				nextDiffIndex = 1
				instanceIndex = instanceIndex + 1
			end
			instanceIndex = 1
		end
		nextIsRaid = 0
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
	self:Print(format("Among them, %d trinket which cannnot be used by all classes are exported", count))
	self:Print("Copy paste the data to Utils/TrinketData.lua")
	self:Print("Suggest to verify the data for the trinket in the recent raid")

	-- Hack that should only happen in developer mode.
	local frame = RCLootCouncil:GetActiveModule("history"):GetFrame()
	frame.exportFrame:Show()

	local exports ="_G.RCTrinketClasses = {\n"
	local sorted = {}
	for id, val in pairs(trinketClasses) do
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
		exports = exports.."\t["..entry[1].."] = "..format("0x%X", entry[2])
			..",\t-- "..format(exp, trinketNames[entry[1]]..",").."\t"..self:ClassesFlagToStr(entry[2]).."\n"
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
	    EJ_SetLootFilter(classID, 0)
	    for j = 1, EJ_GetNumLoot() do -- EJ_GetNumLoot() can be 0 if EJ items are not cached.
	        local id, _, _, _, _, _, link = EJ_GetLootInfoByIndex(j)
	        if link then
		        if classID == 0 then
		        	trinketClasses[id] = 0
		        	trinketNames[id] = self:GetItemNameFromLink(link)
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


-- Automatically generated by command "/rc exporttrinketdata"
-- The code related to above command is commented out for Curseforge release because
-- this is intended to be run by the developer.
-- The table indicates if the trinket is usable for certain classes.
-- Only contains trinket in the current expansion by far in the Encounter Journal
-- Format: [itemID] = classFlag
-- See the explanation of classFlag in RCLootCouncil:GetItemClassesAllowedFlag(item) in core.lua

_G.RCTrinketClasses = {
	[133641] = 0x5D4,	-- Eye of Skovald,                    	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[133644] = 0xE6F,	-- Memento of Angerboda,              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[133645] = 0x652,	-- Naglfar Fare,                      	Paladin, Priest, Shaman, Monk, Druid
	[133646] = 0x652,	-- Mote of Sanctification,            	Paladin, Priest, Shaman, Monk, Druid
	[133647] = 0xE23,	-- Gift of Radiance,                  	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[133766] = 0x652,	-- Nether Anti-Toxin,                 	Paladin, Priest, Shaman, Monk, Druid
	[136714] = 0x652,	-- Amalgam's Seventh Spine,           	Paladin, Priest, Shaman, Monk, Druid
	[136715] = 0xE6F,	-- Spiked Counterweight,              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[136716] = 0x5D4,	-- Caged Horror,                      	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[136975] = 0xE6F,	-- Hunger of the Pack,                	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[136978] = 0xE23,	-- Ember of Nullification,            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137301] = 0x5D0,	-- Corrupted Starlight,               	Priest, Shaman, Mage, Warlock, Druid
	[137306] = 0x5D4,	-- Oakheart's Gnarled Root,           	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[137312] = 0xE6F,	-- Nightmare Egg Shell,               	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137315] = 0xE23,	-- Writhing Heart of Darkness,        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137329] = 0x5D4,	-- Figurehead of the Naglfar,         	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[137338] = 0xE23,	-- Shard of Rokmora,                  	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137344] = 0xE23,	-- Talisman of the Cragshaper,        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137349] = 0x5D4,	-- Naraxas' Spiked Tongue,            	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[137357] = 0xE6F,	-- Mark of Dargrul,                   	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137362] = 0xE23,	-- Parjesh's Medallion,               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137367] = 0x5D4,	-- Stormsinger Fulmination Charge,    	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[137369] = 0xE6F,	-- Giant Ornamental Pearl,            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137373] = 0xE4C,	-- Tempered Egg of Serpentrix,        	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[137378] = 0x652,	-- Bottled Hurricane,                 	Paladin, Priest, Shaman, Monk, Druid
	[137398] = 0x5D0,	-- Portable Manacracker,              	Priest, Shaman, Mage, Warlock, Druid
	[137400] = 0xE23,	-- Coagulated Nightwell Residue,      	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137406] = 0xE6F,	-- Terrorbound Nexus,                 	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137430] = 0xE23,	-- Impenetrable Nerubian Husk,        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137433] = 0x7D6,	-- Obelisk of the Void,               	Paladin, Hunter, Priest, Shaman, Mage, Warlock, Monk, Druid
	[137439] = 0xE6F,	-- Tiny Oozeling in a Jar,            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137440] = 0xE23,	-- Shivermaw's Jawbone,               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137446] = 0x5D4,	-- Elementium Bomb Squirrel Generator,	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[137452] = 0x652,	-- Thrumming Gossamer,                	Paladin, Priest, Shaman, Monk, Druid
	[137459] = 0xE6F,	-- Chaos Talisman,                    	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137462] = 0x652,	-- Jewel of Insatiable Desire,        	Paladin, Priest, Shaman, Monk, Druid
	[137484] = 0x652,	-- Flask of the Solemn Night,         	Paladin, Priest, Shaman, Monk, Druid
	[137485] = 0x5D0,	-- Infernal Writ,                     	Priest, Shaman, Mage, Warlock, Druid
	[137486] = 0xE6F,	-- Windscar Whetstone,                	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137537] = 0xE4C,	-- Tirathon's Betrayal,               	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[137538] = 0xE23,	-- Orb of Torment,                    	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[137539] = 0xE6F,	-- Faulty Countermeasure,             	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[137540] = 0x652,	-- Concave Reflecting Lens,           	Paladin, Priest, Shaman, Monk, Druid
	[137541] = 0x5D4,	-- Moonlit Prism,                     	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[138222] = 0x652,	-- Vial of Nightmare Fog,             	Paladin, Priest, Shaman, Monk, Druid
	[138224] = 0x5D4,	-- Unstable Horrorslime,              	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[138225] = 0xE23,	-- Phantasmal Echo,                   	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[139320] = 0xE6F,	-- Ravaged Seed Pod,                  	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[139321] = 0x5D0,	-- Swarming Plaguehive,               	Priest, Shaman, Mage, Warlock, Druid
	[139322] = 0x652,	-- Cocoon of Enforced Solitude,       	Paladin, Priest, Shaman, Monk, Druid
	[139323] = 0x5D4,	-- Twisting Wind,                     	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[139324] = 0xE23,	-- Goblet of Nightmarish Ichor,       	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[139325] = 0xE6F,	-- Spontaneous Appendages,            	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[139326] = 0x5D0,	-- Wriggling Sinew,                   	Priest, Shaman, Mage, Warlock, Druid
	[139327] = 0xE23,	-- Unbridled Fury,                    	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[139328] = 0x23,	-- Ursoc's Rending Paw,               	Warrior, Paladin, Death Knight
	[139329] = 0xE4C,	-- Bloodthirsty Instinct,             	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[139330] = 0x652,	-- Heightened Senses,                 	Paladin, Priest, Shaman, Monk, Druid
	[139333] = 0x652,	-- Horn of Cenarius,                  	Paladin, Priest, Shaman, Monk, Druid
	[139334] = 0xE6F,	-- Nature's Call,                     	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[139335] = 0xE23,	-- Grotesque Statuette,               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[139336] = 0x5D0,	-- Bough of Corruption,               	Priest, Shaman, Mage, Warlock, Druid
	[140789] = 0xE23,	-- Animated Exoskeleton,              	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[140790] = 0x23,	-- Claw of the Crystalline Scorpid,   	Warrior, Paladin, Death Knight
	[140791] = 0xE23,	-- Royal Dagger Haft,                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[140792] = 0x5D0,	-- Erratic Metronome,                 	Priest, Shaman, Mage, Warlock, Druid
	[140793] = 0x652,	-- Perfectly Preserved Cake,          	Paladin, Priest, Shaman, Monk, Druid
	[140794] = 0xE4C,	-- Arcanogolem Digit,                 	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[140795] = 0x652,	-- Aluriel's Mirror,                  	Paladin, Priest, Shaman, Monk, Druid
	[140796] = 0xE6F,	-- Entwined Elemental Foci,           	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[140797] = 0xE23,	-- Fang of Tichondrius,               	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[140798] = 0x5D4,	-- Icon of Rot,                       	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[140799] = 0x23,	-- Might of Krosus,                   	Warrior, Paladin, Death Knight
	[140800] = 0x5D0,	-- Pharamere's Forbidden Grimoire,    	Priest, Shaman, Mage, Warlock, Druid
	[140801] = 0x5D4,	-- Fury of the Burning Sky,           	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[140802] = 0xE4C,	-- Nightblooming Frond,               	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[140803] = 0x652,	-- Etraeus' Celestial Map,            	Paladin, Priest, Shaman, Monk, Druid
	[140804] = 0x5D0,	-- Star Gate,                         	Priest, Shaman, Mage, Warlock, Druid
	[140805] = 0x652,	-- Ephemeral Paradox,                 	Paladin, Priest, Shaman, Monk, Druid
	[140806] = 0xE6F,	-- Convergence of Fates,              	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[140807] = 0xE23,	-- Infernal Contract,                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[140808] = 0xE6F,	-- Draught of Souls,                  	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[140809] = 0x5D0,	-- Whispers in the Dark,              	Priest, Shaman, Mage, Warlock, Druid
	[141535] = 0x23,	-- Ettin Fingernail,                  	Warrior, Paladin, Death Knight
	[141536] = 0x7D2,	-- Padawsen's Unlucky Charm,          	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[141537] = 0xE4C,	-- Thrice-Accursed Compass,           	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[142157] = 0x5D4,	-- Aran's Relaxing Ruby,              	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[142158] = 0x652,	-- Faith's Crucible,                  	Paladin, Priest, Shaman, Monk, Druid
	[142159] = 0xE6F,	-- Bloodstained Handkerchief,         	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[142160] = 0x5D4,	-- Mrrgria's Favor,                   	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[142161] = 0xE23,	-- Inescapable Dread,                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[142162] = 0x652,	-- Fluctuating Energy,                	Paladin, Priest, Shaman, Monk, Druid
	[142164] = 0xE6F,	-- Toe Knee's Promise,                	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[142165] = 0x5D4,	-- Deteriorated Construct Core,       	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[142167] = 0xE6F,	-- Eye of Command,                    	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[142168] = 0xE23,	-- Majordomo's Dinner Bell,           	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[142169] = 0xE23,	-- Raven Eidolon,                     	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[142506] = 0xE4C,	-- Eye of Guarm,                      	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[142507] = 0x7D2,	-- Brinewater Slime in a Bottle,      	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[142508] = 0x23,	-- Chains of the Valorous,            	Warrior, Paladin, Death Knight
	[144477] = 0xE4C,	-- Splinters of Agronox,              	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[144480] = 0x7D2,	-- Dreadstone of Endless Shadows,     	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[144482] = 0x23,	-- Fel-Oiled Infernal Machine,        	Warrior, Paladin, Death Knight
	[147002] = 0x7D2,	-- Charm of the Rising Tide,          	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[147003] = 0x652,	-- Barbaric Mindslaver,               	Paladin, Priest, Shaman, Monk, Druid
	[147004] = 0x652,	-- Sea Star of the Depthmother,       	Paladin, Priest, Shaman, Monk, Druid
	[147005] = 0x652,	-- Chalice of Moonlight,              	Paladin, Priest, Shaman, Monk, Druid
	[147006] = 0x652,	-- Archive of Faith,                  	Paladin, Priest, Shaman, Monk, Druid
	[147007] = 0x652,	-- The Deceiver's Grand Design,       	Paladin, Priest, Shaman, Monk, Druid
	[147009] = 0xE6F,	-- Infernal Cinders,                  	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[147010] = 0xE6F,	-- Cradle of Anguish,                 	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[147011] = 0xE6F,	-- Vial of Ceaseless Toxins,          	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[147012] = 0xE6F,	-- Umbral Moonglaives,                	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[147015] = 0xE6F,	-- Engine of Eradication,             	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[147016] = 0x5D4,	-- Terror From Below,                 	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[147017] = 0x5D4,	-- Tarnished Sentinel Medallion,      	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[147018] = 0x5D4,	-- Spectral Thurible,                 	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[147019] = 0x5D4,	-- Tome of Unraveling Sanity,         	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[147022] = 0xE23,	-- Feverish Carapace,                 	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[147023] = 0xE23,	-- Leviathan's Hunger,                	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[147024] = 0xE23,	-- Reliquary of the Damned,           	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[147025] = 0xE23,	-- Recompiled Guardian Module,        	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[147026] = 0xE23,	-- Shifting Cosmic Sliver,            	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[151190] = 0xE6F,	-- Specter of Betrayal,               	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151307] = 0xE6F,	-- Void Stalker's Contract,           	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151310] = 0x5D0,	-- Reality Breacher,                  	Priest, Shaman, Mage, Warlock, Druid
	[151312] = 0xE23,	-- Ampoule of Pure Void,              	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[151340] = 0x652,	-- Echo of L'ura,                     	Paladin, Priest, Shaman, Monk, Druid
	[151955] = 0x5D0,	-- Acrid Catalyst Injector,           	Priest, Shaman, Mage, Warlock, Druid
	[151956] = 0x652,	-- Garothi Feedback Conduit,          	Paladin, Priest, Shaman, Monk, Druid
	[151957] = 0x652,	-- Ishkar's Felshield Emitter,        	Paladin, Priest, Shaman, Monk, Druid
	[151958] = 0x652,	-- Tarratus Keystone,                 	Paladin, Priest, Shaman, Monk, Druid
	[151960] = 0x652,	-- Carafe of Searing Light,           	Paladin, Priest, Shaman, Monk, Druid
	[151962] = 0x5D4,	-- Prototype Personnel Decimator,     	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[151963] = 0xE6F,	-- Forgefiend's Fabricator,           	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151964] = 0xE6F,	-- Seeping Scourgewing,               	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151968] = 0xE6F,	-- Shadow-Singed Fang,                	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[151969] = 0x5D4,	-- Terminus Signaling Beacon,         	Hunter, Priest, Shaman, Mage, Warlock, Druid
	[151970] = 0x7D2,	-- Vitality Resonator,                	Paladin, Priest, Shaman, Mage, Warlock, Monk, Druid
	[151971] = 0x5D0,	-- Sheath of Asara,                   	Priest, Shaman, Mage, Warlock, Druid
	[151975] = 0xE23,	-- Apocalypse Drive,                  	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[151976] = 0xE23,	-- Riftworld Codex,                   	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[151977] = 0xE23,	-- Diima's Glacial Aegis,             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[151978] = 0xE23,	-- Smoldering Titanguard,             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[152093] = 0xE6F,	-- Gorshalach's Legacy,               	Warrior, Paladin, Hunter, Rogue, Death Knight, Shaman, Monk, Druid, Demon Hunter
	[152289] = 0x652,	-- Highfather's Machination,          	Paladin, Priest, Shaman, Monk, Druid
	[152645] = 0xE23,	-- Eye of Shatug,                     	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[153544] = 0xE23,	-- Eye of F'harg,                     	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[154173] = 0xE23,	-- Aggramar's Conviction,             	Warrior, Paladin, Death Knight, Monk, Druid, Demon Hunter
	[154174] = 0xE4C,	-- Golganneth's Vitality,             	Hunter, Rogue, Shaman, Monk, Druid, Demon Hunter
	[154175] = 0x652,	-- Eonar's Compassion,                	Paladin, Priest, Shaman, Monk, Druid
	[154176] = 0x23,	-- Khaz'goroth's Courage,             	Warrior, Paladin, Death Knight
	[154177] = 0x5D0,	-- Norgannon's Prowess,               	Priest, Shaman, Mage, Warlock, Druid
}
