dofile(".specs/AddonLoader.lua").LoadToc "RCLootCouncil.toc"
dofile ".specs/EmulatePlayerLogin.lua"

describe("#Core #GetIlvlDifference", function()
	it("should get the item level difference of two shoulders", function()
		local item = 165824 -- ilvl: 110
		local g1 = 168346 -- ilvl: 102
		assert.are.equal(8, RCLootCouncil:GetIlvlDifference(item, g1))
		assert.are.equal(8, RCLootCouncil:GetIlvlDifference(item, nil, g1))
	end)

	it("should return 0 when no gear is provided", function()
		local item = 165824 -- ilvl: 110
		assert.are.equal(0, RCLootCouncil:GetIlvlDifference(item))
	end)
end)
