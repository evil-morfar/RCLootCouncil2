require "busted.runner"()

local addon = loadfile(".specs/AddonLoader.lua")(false, "RCLootCouncil", nil, 18).LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")

describe("#Forever #Options", function()
	local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
	local options

	before_each(function()
		addon.db:ResetDB()
		options = addon:OptionsTable()
	end)

	describe("removed options", function()
		it("removes ambiguate option", function()
			assert.is_nil(options.args.settings.args.generalSettingsTab.args.generalOptions.args.ambiguate)
		end)

		it("removes autoPassTrinket option", function()
			assert.is_nil(options.args.settings.args.generalSettingsTab.args.responseOptions.args.autoPassTrinket)
		end)

		it("removes printCompletedTrades and rejectTrade options", function()
			assert.is_nil(options.args.mlSettings.args.generalTab.args.lootingOptions.args.printCompletedTrades)
			assert.is_nil(options.args.mlSettings.args.generalTab.args.lootingOptions.args.rejectTrade)
		end)

		it("removes showSpecIcon option", function()
			assert.is_nil(options.args.settings.args.generalSettingsTab.args.frameOptions.args.showSpecIcon)
		end)

		it("removes personal loot and bonus rolls options", function()
			assert.is_nil(options.args.settings.args.generalSettingsTab.args.lootHistoryOptions.args.savePersonalLoot)
			assert.is_nil(options.args.settings.args.generalSettingsTab.args.lootHistoryOptions.args.saveBonusRolls)
		end)

		it("removes lootPets and lootDecor options", function()
			assert.is_nil(options.args.mlSettings.args.generalTab.args.lootingOptions.args.lootPets)
			assert.is_nil(options.args.mlSettings.args.generalTab.args.lootingOptions.args.lootDecor)
		end)

		it("removes autoGroupLoot from direct lootingOptions", function()
			assert.is_nil(options.args.mlSettings.args.generalTab.args.lootingOptions.args.autoGroupLoot)
		end)
	end)

	describe("classicAutoPass", function()
		local classicOption

		before_each(function()
			classicOption = options.args.settings.args.generalSettingsTab.args.responseOptions.args.classicAutoPass
		end)

		it("adds classicAutoPass toggle with proper metadata", function()
			assert.is_table(classicOption)
			assert.are.equal("toggle", classicOption.type)
			assert.are.equal(1.5, classicOption.order)
			assert.are.equal(L.opt_classicAutoPass_name, classicOption.name)
			assert.are.equal(L.opt_classicAutoPass_desc, classicOption.desc)
		end)

		it("disables classicAutoPass when autoPass is disabled", function()
			addon.db.profile.autoPass = false
			assert.is_true(classicOption.disabled())

			addon.db.profile.autoPass = true
			assert.is_false(classicOption.disabled())
		end)
	end)

	describe("masterLootText group", function()
		local mlGroup

		before_each(function()
			mlGroup = options.args.mlSettings.args.generalTab.args.lootingOptions.args.masterLootText
		end)

		it("creates master looter group", function()
			assert.is_table(mlGroup)
			assert.are.equal("group", mlGroup.type)
			assert.are.equal(_G.MASTER_LOOTER, mlGroup.name)
			assert.are.equal(9.6, mlGroup.order)
		end)

		it("configures mlLootToPlayer toggle get and set", function()
			local toggle = mlGroup.args.mlLootToPlayer
			assert.is_table(toggle)
			assert.are.equal("toggle", toggle.type)
			assert.are.equal(L.opt_forever_mlLootToPlayer_name, toggle.name)
			assert.are.equal(L.opt_forever_mlLootToPlayer_desc, toggle.desc)

			addon.db.profile.mlLootToPlayer = true
			assert.is_true(toggle.get())

			toggle.set(nil, false)
			assert.is_false(addon.db.profile.mlLootToPlayer)
			assert.is_false(toggle.get())

			toggle.set(nil, true)
			assert.is_true(addon.db.profile.mlLootToPlayer)
			assert.is_true(toggle.get())
		end)
	end)

	describe("groupLootText group", function()
		it("creates group loot group with autoGroupLoot inside", function()
			local group = options.args.mlSettings.args.generalTab.args.lootingOptions.args.groupLootText
			assert.is_table(group)
			assert.are.equal("group", group.type)
			assert.are.equal(L.GROUP_LOOT, group.name)
			assert.are.equal(10.6, group.order)
			assert.is_table(group.args.autoGroupLoot)
		end)
	end)
end)
