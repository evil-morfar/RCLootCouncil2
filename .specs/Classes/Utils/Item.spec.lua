require "busted.runner" ()
---@type RCLootCouncil
local addon = dofile(".specs/AddonLoader.lua").LoadArray {
	"Classes/Core.lua",
	"Classes/Utils/Item.lua",
}

describe("#Utils #Item", function()
	local ItemUtils = addon.Require "Utils.Item"

	it("should produce transmitable item strings", function()
		local item =
		"|cffa335ee|Hitem:172200::::::::120:104::5:7:4823:6572:6578:6579:1502:4786:6513:::|h[Sk'shuul~`Vaz]|h|r"
		local cleaned = ItemUtils:GetTransmittableItemString(item)
		assert.are.equal("172200:::::::::::5:7:4823:6572:6578:6579:1502:4786:6513", cleaned)
		assert.are.equal("", ItemUtils:GetTransmittableItemString())
	end)

	it("should clean item strings and links", function()
		local item =
		"|cffa335ee|Hitem:207838::::::::70:102::23:7:9333:9223:9219:7977:6652:1530:8767:1:28:2731:::::|h[Vigorous Sandstompers]|h|r"
		local cleaned = ItemUtils:GetItemStringClean(item)
		assert.are.equal("207838::::::::70:102::23:7:9333:9223:9219:7977:6652:1530:8767:1:28:2731", cleaned)

		local item2 = "item:207838::::::::70:102::23:7:9333:9223:9219:7977:6652:1530:8767:1:28:2731:::::"
		local cleaned2 = ItemUtils:GetItemStringClean(item2)
		assert.are.equal("207838::::::::70:102::23:7:9333:9223:9219:7977:6652:1530:8767:1:28:2731", cleaned2)
		assert.are.equal("", ItemUtils:GetItemStringClean())
	end)

	it("should unclean item strings", function()
		local cleaned = "207838::::::::70:102::23:7:9333:9223:9219:7977:6652:1530:8767:1:28:2731"
		local item = ItemUtils:UncleanItemString(cleaned)
		assert.are.equal("item:207838::::::::70:102::23:7:9333:9223:9219:7977:6652:1530:8767:1:28:2731", item)
		assert.are.equal("item:0", ItemUtils:UncleanItemString(nil))
	end)

	it("should get itemstrings from itemlinks", function()
		local link =
		"|cffa335ee|Hitem:193775::::::::70:267::33:7:9330:6652:9223:9218:9144:1650:8767:1:28:1279:::::|h[Warlord's Cindermitts]|h|r"
		assert.are.equal("item:193775::::::::70:267::33:7:9330:6652:9223:9218:9144:1650:8767:1:28:1279",
			ItemUtils:GetItemStringFromLink(link))
		assert.is_nil(ItemUtils:GetItemStringFromLink())
	end)

	it("should get item names from itemlinks", function()
		local link =
		"|cffa335ee|Hitem:193775::::::::70:267::33:7:9330:6652:9223:9218:9144:1650:8767:1:28:1279:::::|h[Warlord's Cindermitts]|h|r"
		assert.are.equal("Warlord's Cindermitts", ItemUtils:GetItemNameFromLink(link))
		assert.is_nil(ItemUtils:GetItemNameFromLink())
	end)

	it("should get item ids from itemlinks/itemstrings", function()
		local link =
		"|cffa335ee|Hitem:193775::::::::70:267::33:7:9330:6652:9223:9218:9144:1650:8767:1:28:1279:::::|h[Warlord's Cindermitts]|h|r"
		assert.are.equal(193775, ItemUtils:GetItemIDFromLink(link))
		assert.are.equal(193775, ItemUtils:GetItemIDFromLink(ItemUtils:GetItemStringFromLink(link)))
	end)

	it("GetItemTextWithCount", function()
		assert.are.equal("Test x2", ItemUtils:GetItemTextWithCount("Test", 2))
		assert.are.equal("Test", ItemUtils:GetItemTextWithCount("Test", 1))
		assert.are.equal("Test", ItemUtils:GetItemTextWithCount("Test"))
		assert.are.equal("", ItemUtils:GetItemTextWithCount(""))
		assert.are.equal(" x3", ItemUtils:GetItemTextWithCount("", 3))
	end)

	it("should neutralze itemlinks/itemstrings", function()
		local link =
		"|cffa335ee|Hitem:193775::::::::70:267::33:7:9330:6652:9223:9218:9144:1650:8767:1:28:1279:::::|h[Warlord's Cindermitts]|h|r"
		local itemstring = "item:193775::::::::70:267::33:7:9330:6652:9223:9218:9144:1650:8767:1:28:1279:::::"
		assert.are.equal(
		"|cffa335ee|Hitem:193775:::::::::::33:7:9330:6652:9223:9218:9144:1650:8767:1:28:1279:::::|h[Warlord's Cindermitts]|h|r",
			ItemUtils:NeutralizeItem(link))
		assert.are.equal("item:193775:::::::::::33:7:9330:6652:9223:9218:9144:1650:8767:1:28:1279:::::",
			ItemUtils:NeutralizeItem(itemstring))
	end)
end)
