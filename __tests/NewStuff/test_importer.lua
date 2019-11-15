local lu = require("luaunit")
dofile("../wow_api.lua")
dofile("../__load_libs.lua")
dofile("../RCLootCouncilMock.lua")
loadfile("../../Modules/lootHistory.lua")("", RCLootCouncil)

loadfile("CSVImport.lua")("", RCLootCouncil)
local testCSVData = loadfile("csv_test_data.lua")()
local testPEData = loadfile("playerexport_test_data.lua")()
local His = RCLootCouncil:GetModule("RCLootHistory")

His:DetermineImportType(testCSVData)
His:DetermineImportType(testPEData)

His:ImportCSV(testCSVData)
local testLine = [=[Rageasaurus-Ravencrest,7/11/18,19:14:42,"[Khor, Hammer of the Corrupted]",160679,item:160679::::::::120:104::5:3:4799:1492:4786,Best in Slot,0,WARRIOR,Uldir-Heroic,MOTHER,"[Khor, Hammer of the Corrupted]",[Dismembered Submersible Claw],1,false,normal,Two-Handed Maces,Two-Hand,,Unkown]=]
-- print(His:ExtractLine(testLine, ",")[12])
-- print(printtable(His:ExtractLine(testLine, ",")))
print(os.time(), os.clock(),date("%d/%m/%y", 10))
