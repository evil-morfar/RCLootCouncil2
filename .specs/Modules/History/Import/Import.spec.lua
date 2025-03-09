local addon = loadfile(".specs/AddonLoader.lua")().LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")
local History = addon:GetModule("RCLootHistory")
local private = {}

--  Data
local testCSVData = dofile(".specs/Modules/History/Import/csv_test_data.lua")
local testPEData = dofile(".specs/Modules/History/Import/playerexport_test_data.lua")


--- @type RCLootCouncilLocale
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

--[[
	TODO:
	Certain time related functions fails to run on Github actions due to time zone being different.
	Disabled those tests until a solution is found (probably requires a time refactoring)
]]

describe("#Import", function()
	before_each(function()
		wipe(addon.lootDB.factionrealm)
	end)

	describe("Basics", function()
		it("should be able to determine import types", function()
			assert.is.equal("csv", History:DetermineImportType(testCSVData))
			assert.is.equal("playerexport", History:DetermineImportType(testPEData))
			assert.is.equal("tsv-csv", History:DetermineImportType(private.testData[1]))
			assert.is.equal("csv", History:DetermineImportType(private.testData[3]))
			assert.is.equal("tsv", History:DetermineImportType(private.testData[4]))
			assert.is.equal("Unknown", History:DetermineImportType(private.testData[5]))
			assert.is.equal("Unknown", History:DetermineImportType(private.testData[6]))
		end)

		it("should import tsv-csv data", function()
			local s = stub(addon, "Print")
			History:ImportTSV_CSV(private.testData[1])
			assert.stub(s).was_called_with(match.is_ref(addon),
				string.format(L["Successfully imported 'number' entries."], 1))
			local entry = addon:GetHistoryDB()["Cindermuff-Ravencrest"][1]
			assert.is_not.Nil(entry)

			assert.is.equal("2019/05/22", entry.date)
			-- assert.is.equal("21:08:07", entry.time)
			assert.is.equal("1558552087-9", entry.id)
			assert.is.equal(
				"|cffa335ee|Hitem:165514:::::::::::5:4:4799:42:1522:4786::::::|h[Gloves of Spiritual Grace]|h|r",
				entry.lootWon)
			assert.is.equal("Mainspec/Need", entry.response)
			assert.is.equal(0, entry.votes)
			assert.is.equal("ROGUE", entry.class)
			assert.is.equal("Battle of Dazar'alor-Heroic", entry.instance)
			assert.is.equal("Champion of the Light", entry.boss)
			assert.is.equal(15, entry.difficultyID)
			assert.is.equal(2070, entry.mapID)
			assert.is.equal(13, entry.groupSize)
			assert.is.equal(
				"|cffa335ee|Hitem:162544:5942:153709:::::::::16:4:5010:4802:1542:4786::::::|h[Jade Ophidian Band]|h|r",
				entry.itemReplaced1)
			assert.is.equal(nil, entry.itemReplaced2)
			assert.is.equal(1, entry.responseID)
			assert.is.equal(false, entry.isAwardReason)
			assert.is.equal(4, entry.iClass) -- Armor
			assert.is.equal(2, entry.iSubClass) -- Leather
			assert.is.equal("Cindermuff-Ravencrest", entry.owner)
		end)

		it("should import multiple entries on tsv-csv format", function()
			local s = stub(addon, "Print")
			History:ImportTSV_CSV(private.testData[2])
			local db = addon:GetHistoryDB()
			assert.stub(s).was_called_with(match.is_ref(addon),
				string.format(L["Successfully imported 'number' entries."], 2))

			assert.is.table(db["Cindermuff-Ravencrest"])
			assert.is.table(db["Stryx-Ravencrest"])
			assert.is.equal(1, #db["Cindermuff-Ravencrest"])

			History:ImportTSV_CSV(private.testData[1])
			assert.stub(s).was_called_with(match.is_ref(addon),
				string.format(L["Successfully imported 'number' entries."], 1))
			assert.is.table(db["Cindermuff-Ravencrest"])
			assert.is.table(db["Stryx-Ravencrest"])
			assert.is.equal(2, #db["Cindermuff-Ravencrest"])
		end)

		it("should import csv data", function()
			local s = spy.on(addon, "Print")
			History:ImportCSV(private.testData[3])
			assert.spy(s).was_called_with(match.is_ref(addon),
				string.format(L["Successfully imported 'number' entries."], 1))
		end)
	end)


	describe("Targeted Data Rebuilding", function()
		it("should rebuild instance data", function()
			History:ImportTSV_CSV(private.testData[7])
			local entry = addon:GetHistoryDB()["Potdisc-Ravencrest"][1]
			assert.is_not.Nil(entry)
			assert.are.equal("Battle of Dazar'alor", entry.instance) -- rebuilt from mapID

			History:ImportTSV_CSV(private.testData[8])
			entry = addon:GetHistoryDB()["Potdisc-Ravencrest"][2]
			assert.is_not.Nil(entry)
			assert.are.equal(2070, entry.mapID) -- rebuilt from instance string
			assert.are.equal(15, entry.difficultyID)
		end)

		it("should rebuild date/time", function()
			History:ImportTSV_CSV(private.testData[9])
			local entry = addon:GetHistoryDB()["Potdisc-Ravencrest"][1]
			-- Missing all time data, i.e. date/time should be set to now
			assert.are.equal(date("%Y/%m/%d"), entry.date)
			assert.are.equal(date("%H:%M:%S"), entry.time)

			History:ImportTSV_CSV(private.testData[10])
			entry = addon:GetHistoryDB()["Potdisc-Ravencrest"][2]
			-- Missing id, should be rebuilt form date/time
			assert.are.equal("2019/05/12", entry.date)
			assert.are.equal("22:01:51", entry.time)
			-- assert.are.equal("1557691311-1", entry.id)
		end)

		it("should gracefully handle invalid responseIDs", function()
			History:ImportHistory(private.testData[12])
			local name = next(addon:GetHistoryDB())
			local entry = addon:GetHistoryDB()[name][1]
			assert.is_not.Nil(entry)
		end)
	end)

	describe("Imports large data sets", function()
		it("should import large tsv-csv", function()
			local s = stub(addon, "Print")
			History:ImportCSV(testCSVData)
			assert.stub(s).was_called_with(match.is_ref(addon),
				string.format(L["Successfully imported 'number' entries."], 2403))
		end)

		it("should import large player export", function()
			local s = stub(addon, "Print")
			History:ImportPlayerExport(testPEData)
			assert.stub(s).was_called_with(match.is_ref(addon),
				string.format(L["Successfully imported 'number' entries."], 2378))
		end)
	end)

	describe("worst case", function()
		it("should import with minimally required fields", function()
			local s = stub(addon, "Print")
			local data =
			[[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
Gemenim					165524												1					]]

			History:ImportHistory(data)
			assert.stub(s).was_called_with(match.is_ref(addon),
				string.format(L["Successfully imported 'number' entries."], 1))
			local entry = addon:GetHistoryDB()["Gemenim-Realm Name"][1]
			assert.are.equal(
				"|cffa335ee|Hitem:165524:::::::::::5:3:4799:1522:4786::::::|h[Amethyst-Studded Bindings]|h|r",
				entry.lootWon)
			assert.are.equal(1, entry.responseID)
		end)
		it("should fail when missing 'player'", function()
			local s = stub(addon, "Print")
			local data =
			[[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
					165524				ROGUE								1					]]

			History:ImportHistory(data)
			assert.stub(s).was_called_with(match.is_ref(addon),
				match.Matches("Malformed Name", 0, true))
		end)
		it("should fail when missing 'itemID' or 'itemString'", function()
			local s = stub(addon, "Print")
			local data =
			[[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
Gemenim									ROGUE								1					]]
			History:ImportHistory(data)
			assert.stub(s).was_called_with(match.is_ref(addon),
				match.Matches("Must have either 'itemID' or 'itemString'", 0, true))
		end)

		it("should fail when missing 'responseID'", function()
			local s = stub(addon, "Print")
			local data =
			[[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
Gemenim					165524				ROGUE													]]

			History:ImportHistory(data)
			assert.stub(s).was_called_with(match.is_ref(addon),
				match.Matches("Malformed responseID (string or numbers only)", 0, true))
		end)

		it("should fail if header is malformed", function()
			local s = stub(addon, "Print")
			-- 'player' is required for determining import type
			History:ImportHistory(
				[[plater	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
Gemenim					165524												1					]])
			assert.stub(s).was_called_with(match.is_ref(addon), L["import_not_supported"])
			assert.stub(s).was_called_with(match.is_ref(addon), L["Accepted imports: 'Player Export' and 'CSV'"])

			s:clear()
			-- date = dat => malformed header
			History:ImportHistory(
				[[player	dat	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
Gemenim					165524												1					]])
			assert.stub(s).was_called_with(match.is_ref(addon), L["import_malformed_header"])

			s:clear()

			-- tsv
			History:ImportHistory(private.testData[4])
			assert.stub(s).was_called_with(match.is_ref(addon), L["import_not_supported"])
			assert.stub(s).was_called_with(match.is_ref(addon), L["Accepted imports: 'Player Export' and 'CSV'"])
		end)
	end)
end)


private.testData = {
	[1] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner		
   Cindermuff-Ravencrest	22/5/19	20:08:07	1558552087-9	[Gloves of Spiritual Grace]	165514	item:165514::::::::120:104::5:4:4799:43:1522:4786	Stat & iLvl upgrade	0	ROGUE	"Battle of Dazar'alor-Heroic"	"Champion of the Light"	15	2070	13	162544		1	false	Leather	Hands		Cindermuff-Ravencrest		]], -- Google Sheet copy
	[2] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Cindermuff-Ravencrest	22/5/19	20:08:07	1558552087-10	162544	165514	item:165514::::::::120:104::5:4:4799:43:1522:4786	Stat & iLvl upgrade	0	ROGUE	Battle of Dazar'alor-Heroic	Champion of the Light	15	2070	13	162544		1	false	Leather	Hands		Cindermuff-Ravencrest
   Stryx-Ravencrest	23/9/18	19:57:50	1537729070-13	[Twitching Tentacle of Xalzaix]	160656	item:160656::::::::120:104::3:3:4798:1477:4786	Best in Slot	0	PALADIN	Uldir-Normal	Mythrax	14	1861	21	162544	162544	1	false	Miscellaneous	Trinket		Unknown]], -- Google Sheet copy
	[3] = [[player,date,time,id,item,itemID,itemString,response,votes,class,instance,boss,difficultyID,mapID,groupSize,gear1,gear2,responseID,isAwardReason,subType,equipLoc,note,owner
	Potdisc-Ravencrest,12/9/18,20:02:13,1536778933-48,[Sanguicell],162461,item:162461::::::::120:104,Personal Loot -Non tradeable,nil,HUNTER,Uldir-Normal,Vectis,14,1861,21,,,PL,false,Elemental,,,Unknown]],                                              -- CSV
	[4] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
	Maeglas-Ravencrest	12/9/18	20:02:13	1536778933-48	[Sanguicell]	162461	item:162461::::::::120:104	Personal Loot - Non tradeable	nil	HUNTER	Uldir-Normal	Vectis	14	1861	21			PL	false	Elemental			Unknown]],                                             -- TSV export mock
	[5] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	mapID gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Maeglas-Ravencrest	12/9/18	20:02:13	1536778933-48	[Sanguicell]	162461	item:162461::::::::120:104	Personal Loot - Non tradeable	nil	HUNTER	Uldir-Normal	Vectis	14	1861	21			PL	false	Elemental			Unknown]],                                           -- Broken (missing difficultyID)
	[6] = [[player date	time	id	item	itemID	itemString	response	votes	class	instance	boss	mapID gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Maeglas-Ravencrest	12/9/18	20:02:13	1536778933-48	[Sanguicell]	162461	item:162461::::::::120:104	Personal Loot - Non tradeable	nil	HUNTER	Uldir-Normal	Vectis	14	1861	21			PL	false	Elemental			Unknown]],                                           -- Broken (space after "player")


	[7] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
Potdisc-Ravencrest	12/6/19	21:34:34	1560371674-43	[Giga-Charged Shoulderpads]	165497	item:165497::::::::120:104::5:4:4823:1522:4786:5418	Scrap	0	PRIEST		Mekkatorque		2070	19	|cffa335ee|Hitem:162544:5939:::::::120:257::23:3:4779:1517:4783:::|h[Jade Ophidian Band]|h|r		1	false	Cloth	Shoulder		Frostone-Ravencrest]],                           -- Missing diffID and instance
	[8] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Potdisc-Ravencrest	12/6/19	21:34:34	1560371674-44	[Giga-Charged Shoulderpads]	165497	item:165497::::::::120:104::5:4:4823:1522:4786:5418	Scrap	0	PRIEST	Battle of Dazar'alor-Heroic	Mekkatorque			19	|cffa335ee|Hitem:162544:5939:::::::120:257::23:3:4779:1517:4783:::|h[Jade Ophidian Band]|h|r		1	false	Cloth	Shoulder		Frostone-Ravencrest]], -- Missing diffID and mapID

	[9] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Potdisc-Ravencrest				[Deathspeaker Spire]	165597	item:165597::::::::120:258::5:3:4799:1522:4786	Personal Loot - Non tradeable	nil	PRIEST	Battle of Dazar'alor-Heroic	King Rastakhan	15	2070	14			PL	false	Staves	Two-Hand		Potdisc-Ravencrest]], -- Missing all time vars

	[10] = [[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Potdisc-Ravencrest	2019/5/12	22:01:51		[Deathspeaker Spire]	165597	item:165597::::::::120:258::5:3:4799:1522:4786	Personal Loot - Non tradeable	nil	PRIEST	Battle of Dazar'alor-Heroic	King Rastakhan	15	2070	14			PL	false	Staves	Two-Hand		Potdisc-Ravencrest]], -- Missing id
	[11] =
	[[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
   Potdisc-Ravencrest	2019/5/12	22:01:51	1560371674-43	[Deathspeaker Spire]	165597	item:165597::::::::120:258::5:3:4799:1522:4786	Personal Loot - Non tradeable	nil	PRIEST	Battle of Dazar'alor-Heroic	King Rastakhan	15	2070	14			8	false	Staves	Two-Hand		Potdisc-Ravencrest]],
	[12] =
	[[player	date	time	id	item	itemID	itemString	response	votes	class	instance	boss	difficultyID	mapID	groupSize	gear1	gear2	responseID	isAwardReason	subType	equipLoc	note	owner
Løthár-KhazModan	2025/03/06	22:37:00	1741297055-9	[Bijou béni de Gobleone]	228842	item:165597::::::::120:258::5:3:4799:1522:4786	BIS	1	PALADIN	Libération de Terremine-Normal	Verr’Minh, chefs de la sécurité	14	2769	19	item:165597::::::::120:258::5:3:4799:1522:4786		1	FALSE	Divers	Cou	BIs tank	Meliscendre-KhazModan
Altaras-KhazModan	2025/03/06	22:34:00	1741296859-5	[Coup de poing en fusion de Capo]	232804	item:165597::::::::120:258::5:3:4799:1522:4786	Butin personnel - non-échangeable	nil	HUNTER	Libération de Terremine-Normal	Verr’Minh, chefs de la sécurité	14	2769	19			PL	FALSE	Armes de pugilat	À une main		Altaras-KhazModan
Zaarooc-Hyjal	2025/03/06	21:40:00	1741293692-3	[As-des-Machines]	232526	item:165597::::::::120:258::5:3:4799:1522:4786	BIS	1	PALADIN	Libération de Terremine-Normal	Bandit manchot	14	2769	18	item:165597::::::::120:258::5:3:4799:1522:4786		1	FALSE	Masses à deux mains	Deux mains	bis all for one	Meliscendre-KhazModan
Zaarooc-Hyjal	2025/03/06	22:34:00	1741296836-4	[Offre refusée d’affranchi]	228902	item:165597::::::::120:258::5:3:4799:1522:4786	Butin personnel - non-échangeable	nil	PALADIN	Libération de Terremine-Normal	Verr’Minh, chefs de la sécurité	14	2769	19			PL	FALSE	Masses à une main	À une main		Zaarooc-Hyjal
Ninperméable-KhazModan	2025/03/06	21:38:00	1741293548-1	[Roulette miniature]	228843	item:165597::::::::120:258::5:3:4799:1522:4786	BIS	0	SHAMAN	Libération de Terremine-Normal	Bandit manchot	14	2769	18	item:165597::::::::120:258::5:3:4799:1522:4786	item:165597::::::::120:258::5:3:4799:1522:4786	1	FALSE	Divers	Doigt	Bis d'apres ice veins :p	Meliscendre-KhazModan
Chlðé-KhazModan	2025/03/06	21:38:00	1741293538-0	[Détecteur de fraude d’opérateur]	228906	item:165597::::::::120:258::5:3:4799:1522:4786	BIS	1	MAGE	Libération de Terremine-Normal	Bandit manchot	14	2769	18	item:165597::::::::120:258::5:3:4799:1522:4786		1	FALSE	Divers	Tenu(e) en main gauche	C'est mon BIS raid, mais c'est pas ma meilleure option	Meliscendre-KhazModan
Chlðé-KhazModan	2025/03/06	22:35:00	1741296952-6	[Mantelet sur mesure de sous-chef]	228870	item:165597::::::::120:258::5:3:4799:1522:4786	Meilleurs Ilvl (NM->HM)	1	MAGE	Libération de Terremine-Normal	Verr’Minh, chefs de la sécurité	14	2769	19	item:165597::::::::120:258::5:3:4799:1522:4786		3	FALSE	Tissu	Épaule	ça peut faire une pièce de set avec le catalyseur	Meliscendre-KhazModan
Chlðé-KhazModan	2025/03/06	22:36:00	1741296961-7	[Palmes de Murloc en ciment]	228879	item:165597::::::::120:258::5:3:4799:1522:4786	BIS	0	MAGE	Libération de Terremine-Normal	Verr’Minh, chefs de la sécurité	14	2769	19	item:165597::::::::120:258::5:3:4799:1522:4786		1	FALSE	Tissu	Pieds	Exactement mes stats, c'est mon BIS	Meliscendre-KhazModan
Chitarolc-KhazModan	2025/03/06	22:36:00	1741296999-8	[Numéro d’urgence des brutes de Minh]	230199	item:165597::::::::120:258::5:3:4799:1522:4786	BIS	1	DEMONHUNTER	Libération de Terremine-Normal	Verr’Minh, chefs de la sécurité	14	2769	19	item:165597::::::::120:258::5:3:4799:1522:4786	item:165597::::::::120:258::5:3:4799:1522:4786	1	FALSE	Divers	Bijou	3 iéme meuilleur bijou bis	Meliscendre-KhazModan
Spagueflex-KhazModan	2025/03/06	21:38:00	1741293573-2	[Gallybrouzouf doré du zénith]	228810	item:165597::::::::120:258::5:3:4799:1522:4786	Set Token	2	WARRIOR	Libération de Terremine-Normal	Bandit manchot	14	2769	18	item:165597::::::::120:258::5:3:4799:1522:4786		8	FALSE	Jeton d'armure			Meliscendre-KhazModan]],
}
