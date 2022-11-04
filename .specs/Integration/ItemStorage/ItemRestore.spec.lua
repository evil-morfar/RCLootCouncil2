loadfile(".specs/AddonLoader.lua")().LoadToc("RCLootCouncil.toc")
dofile ".specs/EmulatePlayerLogin.lua"
local addon = RCLootCouncil

describe("#Integration #ItemStorage #ItemRestore", function()
	it("should remove items that no longer exists in our bags", function()
        -- Set some items into storage
		addon.db.profile["itemStorage"] = {
			{
				["inBags"] = true,
				["type"] = "award_later",
				["link"] = "|cff1eff00|Hitem:45912::::::::80:::::::::|h[Book of Glyph Mastery]|h|r",
				["time_added"] = 1666292781,
				["args"] = {["bop"] = false},
			}, -- [1]
			{
				["inBags"] = true,
				["type"] = "award_later",
				["link"] = "|cffa335ee|Hitem:39702::::::::80:::::::::|h[Arachnoid Gold Band]|h|r",
				["time_remaining"] = 7140,
				["time_added"] = 1666292961,
				["args"] = {["bop"] = true, ["boss"] = "Anub'Rekhan"},
			}, -- [2]
			{
				["inBags"] = true,
				["type"] = "award_later",
				["link"] = "|cffa335ee|Hitem:39722::::::::80:::::::::|h[Swarm Bindings]|h|r",
				["time_remaining"] = 7140,
				["time_added"] = 1666292961,
				["args"] = {["bop"] = true, ["boss"] = "Anub'Rekhan"},
			}, -- [3]
			{
				["inBags"] = true,
				["type"] = "award_later",
				["link"] = "|cffa335ee|Hitem:40080::::::::80:::::::::|h[Lost Jewel]|h|r",
				["time_remaining"] = 7140,
				["time_added"] = 1666292961,
				["args"] = {["bop"] = true, ["boss"] = "Anub'Rekhan"},
			}, -- [4]
		}
        addon:InitItemStorage()
        -- All items should have been removed from storage since we didn't find them in our bags
        assert.are.equal(0, #addon.db.profile.itemStorage)
	end)

    it("should restore items still in our bags", function()
       addon.db.profile["itemStorage"] = {
			{
				["inBags"] = true,
				["type"] = "award_later",
				["link"] = "|cffa335ee|Hitem:39702::::::::80:::::::::|h[Arachnoid Gold Band]|h|r",
				["time_added"] = 1666292781,
				["args"] = {["bop"] = false},
			}, -- [1]
			{
				["inBags"] = true,
				["type"] = "award_later",
				["link"] = "|cff1eff00|Hitem:55555::::::::80:::::::::|h[Book of Glyph Mastery]|h|r",
				["time_remaining"] = 7140,
				["time_added"] = 1666292961,
				["args"] = {["bop"] = true, ["boss"] = "Anub'Rekhan"},
			}, -- [2]
			{
				["inBags"] = true,
				["type"] = "award_later",
				["link"] = "|cffa335ee|Hitem:39722::::::::80:::::::::|h[Swarm Bindings]|h|r",
				["time_remaining"] = 7140,
				["time_added"] = 1666292961,
				["args"] = {["bop"] = true, ["boss"] = "Anub'Rekhan"},
			}, -- [3]
			{
				["inBags"] = true,
				["type"] = "award_later",
				["link"] = "|cffa335ee|Hitem:40080::::::::80:::::::::|h[Lost Jewel]|h|r",
				["time_remaining"] = 7140,
				["time_added"] = 1666292961,
				["args"] = {["bop"] = true, ["boss"] = "Anub'Rekhan"},
			}, -- [4]
		}
        addon:InitItemStorage()
        -- All items should have been removed from storage since we didn't find them in our bags
        assert.are.equal(1, #addon.db.profile.itemStorage)
        assert.are.equal("|cff1eff00|Hitem:55555::::::::80:::::::::|h[Book of Glyph Mastery]|h|r", addon.db.profile.itemStorage[1].link)
    end)
end)


-- Global helpers
function _G.GetContainerNumSlots(bagID) return 10 end

function _G.GetContainerItemLink(bagID, slotIndex)
	if bagID ~= 2 or (bagID == 2 and slotIndex ~= 3) then return _G.Items_Array[math.random(100, #_G.Items_Array)] end
	-- bag 2, slot 3
	return "|cff1eff00|Hitem:55555::::::::80:::::::::|h[Book of Glyph Mastery]|h|r"
end