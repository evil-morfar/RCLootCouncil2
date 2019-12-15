require "luacov"
local lu = require("luaunit")
dofile("../wow_api.lua")
dofile("../wow_item_api.lua")
dofile("../__load_libs.lua")
dofile("../RCLootCouncilMock.lua")
loadfile("../../Modules/History/lootHistory.lua")("", RCLootCouncil)

loadfile("../../Modules/History/CSVImport.lua")("", RCLootCouncil)
local testCSVData = loadfile("csv_test_data.lua")()
local testPEData = loadfile("playerexport_test_data.lua")()
local His = RCLootCouncil:GetModule("RCLootHistory")
RCLootCouncil.debug = true

local private = {}
--
-- local type = His:DetermineImportType(testCSVData)
-- His:DetermineImportType(testPEData)
--
-- print("Type:", type)
-- if type == "tsv-csv" then
--    His:ImportTSV_CSV(testCSVData)
-- else
--    His:ImportCSV(testCSVData)
-- end
local testLine = [=[Rageasaurus-Ravencrest,7/11/18,19:14:42,"[Khor, Hammer of the Corrupted]",160679,item:160679::::::::120:104::5:3:4799:1492:4786,Best in Slot,0,WARRIOR,Uldir-Heroic,MOTHER,"[Khor, Hammer of the Corrupted]",[Dismembered Submersible Claw],1,false,normal,Two-Handed Maces,Two-Hand,,Unkown]=]

TestBasics = {
   Setup = function (args)
      -- Clear previous db.
      wipe(RCLootCouncil:GetHistoryDB())
   end,
   TestDetermineImportType = function (args)
      lu.assertEquals(His:DetermineImportType(private.testData[1]), "tsv-csv")
      lu.assertEquals(His:DetermineImportType(testCSVData), "tsv-csv")
      lu.assertEquals(His:DetermineImportType(testPEData), "playerexport")
      lu.assertEquals(His:DetermineImportType(private.testData[3]), "csv")
      lu.assertEquals(His:DetermineImportType(private.testData[4]), "tsv")
      lu.assertEquals(His:DetermineImportType(private.testData[5]), "Unknown")
      lu.assertEquals(His:DetermineImportType(private.testData[6]), "Unknown")
      lu.assertNil(His:DetermineImportType(""))
   end,

   TestImportTSV_CSV1 = function (args)
      His:ImportTSV_CSV(private.testData[1])
      local entry = RCLootCouncil:GetHistoryDB()["Cindermuff-Ravencrest"][1]

      -- Check some random entries
      lu.assertEquals(entry.mapID, 2070)
      lu.assertEquals(entry.class, "ROGUE")
      lu.assertEquals(entry.groupSize, 13)
      lu.assertEquals(entry.lootWon, "|cffa335ee|Hitem:165514::::::::120:257::5:4:4799:43:1522:4786:::|h[Gloves of Spiritual Grace]|h|r")
      lu.assertEquals(entry.responseID, 1)
      lu.assertEquals(entry.votes, 0)
   end,
   TestImportTSV_CSV2 = function (args)
      His:ImportTSV_CSV(private.testData[2])
      local db = RCLootCouncil:GetHistoryDB()
      lu.assertIsTable(db["Cindermuff-Ravencrest"])
      lu.assertIsTable(db["Stryx-Ravencrest"])
      lu.assertEquals(#db["Cindermuff-Ravencrest"], 1)
      His:ImportTSV_CSV(private.testData[1])
      lu.assertIsTable(db["Cindermuff-Ravencrest"])
      lu.assertIsTable(db["Stryx-Ravencrest"])
      lu.assertEquals(#db["Cindermuff-Ravencrest"], 2)
   end
}

TestTargetedDataRebuilding = {
   Setup = function (args)
      -- Clear previous db.
      wipe(RCLootCouncil:GetHistoryDB())
   end,
   TestInstanceRebuilds = function()
      His:ImportTSV_CSV(private.testData[7])
      local entry = RCLootCouncil:GetHistoryDB()["Potdisc-Ravencrest"][1]
      -- Rebuilt from mapID
      lu.assertEquals(entry.instance, "Battle of Dazar'alor")
      His:ImportTSV_CSV(private.testData[8])
      entry = RCLootCouncil:GetHistoryDB()["Potdisc-Ravencrest"][2]
      -- Rebuilt from instance string
      lu.assertEquals(entry.mapID, 2070)
      lu.assertEquals(entry.difficultyID, 15)
   end,

   TestTimeRebuilds = function()
      His:ImportTSV_CSV(private.testData[9])
      local entry = RCLootCouncil:GetHistoryDB()["Potdisc-Ravencrest"][1]
      lu.assertEquals(entry.date, date("%d/%m/%y"))
      lu.assertEquals(entry.time, date("%H:%M:%S"))

      His:ImportTSV_CSV(private.testData[10])
      entry = RCLootCouncil:GetHistoryDB()["Potdisc-Ravencrest"][2]
      printtable(entry)
      lu.assertEquals(entry.date, "12/05/19")
      lu.assertEquals(entry.time, "00:00:00")
   end,
}


private.testData = {
   [1]=[[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Cindermuff-Ravencrest	22/5/19	20:08:07	1558552087-9	[Gloves of Spiritual Grace]	165514	item:165514::::::::120:104::5:4:4799:43:1522:4786	Stat & iLvl upgrade	0	ROGUE	"Battle of Dazar'alor-Heroic"	"Champion of the Light"	15	2070	13	162544		1	false	Leather	Hands		Cindermuff-Ravencrest]], -- Google Sheet copy
   [2]=[[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Cindermuff-Ravencrest	22/5/19	20:08:07	1558552087-10	162544	165514	item:165514::::::::120:104::5:4:4799:43:1522:4786	Stat & iLvl upgrade	0	ROGUE	Battle of Dazar'alor-Heroic	Champion of the Light	15	2070	13	162544		1	false	Leather	Hands		Cindermuff-Ravencrest
   Stryx-Ravencrest	23/9/18	19:57:50	1537729070-13	[Twitching Tentacle of Xalzaix]	160656	item:160656::::::::120:104::3:3:4798:1477:4786	Best in Slot	0	PALADIN	Uldir-Normal	Mythrax	14	1861	21	162544	162544	1	false	Miscellaneous	Trinket		Unknown]], -- Google Sheet copy
   [3]=[[player,date,time,id,item,itemID,itemString,response,votes,class,instance,boss,difficultyID,mapID,groupSize,gear1,gear2,responseID,isAwardReason,subType,equipLoc,note,owner,,,,Maeglas-Ravencrest,12/9/18,20:02:13,1536778933-48,[Sanguicell],162461,item:162461::::::::120:104,Personal Loot -Non tradeable,nil,HUNTER,Uldir-Normal,Vectis,14,1861,21,,,PL,false,Elemental,,,Unknown]], -- CSV
   [4]=[[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
	Maeglas-Ravencrest	12/9/18	20:02:13	1536778933-48	[Sanguicell]	162461	item:162461::::::::120:104	Personal Loot - Non tradeable	nil	HUNTER	Uldir-Normal	Vectis	14	1861	21			PL	false	Elemental			Unknown]], -- TSV export mock
   [5]=[[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	mapID gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Maeglas-Ravencrest	12/9/18	20:02:13	1536778933-48	[Sanguicell]	162461	item:162461::::::::120:104	Personal Loot - Non tradeable	nil	HUNTER	Uldir-Normal	Vectis	14	1861	21			PL	false	Elemental			Unknown]], -- Broken (missing difficultyID)
   [6]=[[player date	time	id	item	itemID	itemString	response	votes	class	instance	boss	mapID gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Maeglas-Ravencrest	12/9/18	20:02:13	1536778933-48	[Sanguicell]	162461	item:162461::::::::120:104	Personal Loot - Non tradeable	nil	HUNTER	Uldir-Normal	Vectis	14	1861	21			PL	false	Elemental			Unknown]], -- Broken (space after "player")


   [7] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
Potdisc-Ravencrest	12/6/19	21:34:34	1560371674-43	[Giga-Charged Shoulderpads]	165497	item:165497::::::::120:104::5:4:4823:1522:4786:5418	Scrap	0	PRIEST		Mekkatorque		2070	19	|cffa335ee|Hitem:162544:5939:::::::120:257::23:3:4779:1517:4783:::|h[Jade Ophidian Band]|h|r		1	false	Cloth	Shoulder		Frostone-Ravencrest]], -- Missing diffID and instance
   [8] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Potdisc-Ravencrest	12/6/19	21:34:34	1560371674-44	[Giga-Charged Shoulderpads]	165497	item:165497::::::::120:104::5:4:4823:1522:4786:5418	Scrap	0	PRIEST	Battle of Dazar'alor-Heroic	Mekkatorque			19	|cffa335ee|Hitem:162544:5939:::::::120:257::23:3:4779:1517:4783:::|h[Jade Ophidian Band]|h|r		1	false	Cloth	Shoulder		Frostone-Ravencrest]], -- Missing diffID and mapID

   [9] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Potdisc-Ravencrest				[Deathspeaker Spire]	165597	item:165597::::::::120:258::5:3:4799:1522:4786	Personal Loot - Non tradeable	nil	PRIEST	Battle of Dazar'alor-Heroic	King Rastakhan	15	2070	14			PL	false	Staves	Two-Hand		Potdisc-Ravencrest]], -- Missing all time vars

   [10] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Potdisc-Ravencrest	12/5/19	22:01:51		[Deathspeaker Spire]	165597	item:165597::::::::120:258::5:3:4799:1522:4786	Personal Loot - Non tradeable	nil	PRIEST	Battle of Dazar'alor-Heroic	King Rastakhan	15	2070	14			PL	false	Staves	Two-Hand		Potdisc-Ravencrest]], -- Missing id
}
os.exit(lu.LuaUnit.run("-o", "tap"))
