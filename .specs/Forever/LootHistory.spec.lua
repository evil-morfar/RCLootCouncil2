require "busted.runner"()

local addon = loadfile(".specs/AddonLoader.lua")(false, "RCLootCouncil", nil, 18).LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")

describe("#Forever #LootHistory", function()
	local History = addon:GetModule("RCLootHistory")

	before_each(function()
		History:Enable()
		addon.lootDB.factionrealm = {}
	end)

	it("sets wowheadBaseUrl to forever url", function()
		assert.are.equal("https://www.wowhead.com/forever/item=", History.wowheadBaseUrl)
	end)

	it("registers biscouncil export on OnInitialize", function()
		assert.is_table(History.exports.biscouncil)
		assert.are.equal("BisCouncil", History.exports.biscouncil.name)
		assert.are.equal("BisCouncil formatted export.", History.exports.biscouncil.tip)
		assert.are.equal(History.ExportBisCouncil, History.exports.biscouncil.func)
	end)

	describe("ExportBisCouncil", function()
		it("returns header when database is empty", function()
			addon.lootDB.factionrealm = {}
			local csv = History:ExportBisCouncil()
			assert.are.equal("player,date,itemID,response,class,id\r\n", csv)
		end)

		it("exports entries in BisCouncil CSV format", function()
			local testTime = 1741210091 -- 2025/03/05 (depending on timezone date("%Y/%m/%d", testTime))
			local expectedDate = date("%Y/%m/%d", testTime)
			local testId = testTime .. "-32"
			local itemLink = "|cffa335ee|Hitem:163265:::::::::::28:3:5125:1537:4783::::::|h[7th Legionnaire's Leggings]|h|r"

			addon.lootDB.factionrealm = {
				["Player1"] = {
					{
						["id"] = testId,
						["lootWon"] = itemLink,
						["response"] = "Mainspec",
						["class"] = "WARRIOR",
						["instance"] = "Molten Core",
						["boss"] = "Ragnaros",
					},
				},
			}

			local csv = History:ExportBisCouncil()
			local expectedRow = string.format("Player1,%s,163265,Mainspec,WARRIOR,%s\r\n", expectedDate, testId)
			local expectedOutput = "player,date,itemID,response,class,id\r\n" .. expectedRow

			assert.are.equal(expectedOutput, csv)
		end)

		it("exports multiple entries correctly", function()
			local time1 = 1741210000
			local time2 = 1741220000
			local date1 = date("%Y/%m/%d", time1)
			local date2 = date("%Y/%m/%d", time2)

			addon.lootDB.factionrealm = {
				["Player1"] = {
					{
						["id"] = time1 .. "-1",
						["lootWon"] = "|cffa335ee|Hitem:163265::::::::|h[Item1]|h|r",
						["response"] = "Need",
						["class"] = "WARRIOR",
					},
					{
						["id"] = time2 .. "-2",
						["lootWon"] = "|cffa335ee|Hitem:158355::::::::|h[Item2]|h|r",
						["response"] = "Greed",
						["class"] = "WARRIOR",
					},
				},
			}

			local csv = History:ExportBisCouncil()

			assert.is_truthy(csv:find("player,date,itemID,response,class,id\r\n", 1, true))
			assert.is_truthy(csv:find(string.format("Player1,%s,163265,Need,WARRIOR,%d-1\r\n", date1, time1), 1, true))
			assert.is_truthy(csv:find(string.format("Player1,%s,158355,Greed,WARRIOR,%d-2\r\n", date2, time2), 1, true))
		end)
	end)
end)
