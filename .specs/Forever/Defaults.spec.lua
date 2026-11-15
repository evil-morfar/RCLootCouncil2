require "busted.runner"()

local addon = loadfile(".specs/AddonLoader.lua")(false, "RCLootCouncil", nil, 18).LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")

describe("#Forever #Defaults", function()
	local defaults = addon.defaults.profile

	before_each(function()
		addon.db:ResetDB()
	end)

	it("sets classicAutoPass default to true", function()
		assert.is_true(defaults.classicAutoPass)
		assert.is_true(addon:Getdb().classicAutoPass)
	end)

	it("sets currentSkin default to forever", function()
		assert.are.equal("forever", defaults.currentSkin)
		assert.are.equal("forever", addon:Getdb().currentSkin)
	end)

	it("sets autoGroupLootDecor default to false", function()
		assert.is_false(defaults.autoGroupLootDecor)
		assert.is_false(addon:Getdb().autoGroupLootDecor)
	end)

	it("sets showSpecIcon default to false", function()
		assert.is_false(defaults.showSpecIcon)
		assert.is_false(addon:Getdb().showSpecIcon)
	end)

	it("sets ambiguate default to false", function()
		assert.is_false(defaults.ambiguate)
		assert.is_false(addon:Getdb().ambiguate)
	end)

	it("sets ignoredItems default to empty table", function()
		assert.is_table(defaults.ignoredItems)
		assert.are.same({}, defaults.ignoredItems)
		assert.are.same({}, addon:Getdb().ignoredItems)
	end)

	it("sets autoPassWeapons default to false", function()
		assert.is_false(defaults.autoPassWeapons)
		assert.is_false(addon:Getdb().autoPassWeapons)
	end)

	it("sets autoPassTrinkets default to false", function()
		assert.is_false(defaults.autoPassTrinkets)
		assert.is_false(addon:Getdb().autoPassTrinkets)
	end)

	it("sets mlLootToPlayer default to true", function()
		assert.is_true(defaults.mlLootToPlayer)
		assert.is_true(addon:Getdb().mlLootToPlayer)
	end)

	it("resets back to Forever defaults when db:ResetDB() is called", function()
		local db = addon:Getdb()
		db.classicAutoPass = false
		db.mlLootToPlayer = false
		db.currentSkin = "standard"

		addon.db:ResetDB()

		local resetDb = addon:Getdb()
		assert.is_true(resetDb.classicAutoPass)
		assert.is_true(resetDb.mlLootToPlayer)
		assert.are.equal("forever", resetDb.currentSkin)
	end)
end)
