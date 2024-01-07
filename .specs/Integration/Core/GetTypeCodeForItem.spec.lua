-- require "busted.runner" ()
dofile(".specs/AddonLoader.lua").LoadToc "RCLootCouncil.toc"

describe("#Core #GetTypeCodeForItem", function()
	it("should treat robes and chests as the same", function()
		local addon = RCLootCouncil
		addon:OnInitialize()
		local db = addon:Getdb()

		assert.are.equal("default", addon:GetTypeCodeForItem(168341)) -- robe
		assert.are.equal("default", addon:GetTypeCodeForItem(158355)) -- chest
		db.enabledButtons["INVTYPE_CHEST"] = true
		assert.are.equal("INVTYPE_CHEST", addon:GetTypeCodeForItem(168341)) -- robe
		assert.are.equal("INVTYPE_CHEST", addon:GetTypeCodeForItem(158355)) -- chest
	end)
end)
