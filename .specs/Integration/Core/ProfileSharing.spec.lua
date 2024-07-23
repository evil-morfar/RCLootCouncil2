require "busted.runner" ()
---@type assert|luassert
local assert = assert
---@type RCLootCouncil
_G.RCLootCouncil = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")

-- TODO: Actually test the full flow, instead of just reapplying the same profile ontop
describe("#ProfileSharing", function()
	local addon = RCLootCouncil
	--- @type RCLootCouncilLocale
	local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
	addon.Log = addon.Require "Utils.Log":New()
	addon.db = LibStub("AceDB-3.0"):New("RCLootCouncilDB", addon.defaults, true)
	addon.lootDB = LibStub("AceDB-3.0"):New("RCLootCouncilLootDB")
	-- Mock :UpdateDB()
	addon.UpdateDB = function() end

	it("should produce the current profile for export", function()
		local export = addon:GetProfileForExport()
		assert.is.string(export)
	end)

	it("will import an exported profile", function()
		local export = addon:GetProfileForExport()
		assert.has_no.errors(function() addon:ImportProfile(export) end)
	end)

	it("should deliver profiles as expected", function()
		local profileName = addon.db:GetCurrentProfile()
		local preDB = addon.Utils:GetTableDifference(addon.db.defaults.profile, addon.db.profile)
		preDB.UI = nil
		preDB.itemStorage = nil
		preDB.baggedItems = nil
		local s = stub(addon, "ApplyProfile")

		local export = addon:GetProfileForExport()
		addon:ImportProfile(export)
		local dialog = LibStub("LibDialog-1.1"):ActiveDialog("RCLOOTCOUNCIL_OVERWRITE_PROFILE")
		dialog.delegate.buttons[1]:on_click(dialog.data)

		assert.stub(s).was_called_with(match.is_ref(addon), profileName, match.Same(preDB))
	end)

	it("should fail when imported data doesn't contain our magic word", function()
		local export = "NotRCLootCouncilProfile\nSomeName\nAll the data that might be hereeeeeeeeeeeeeeeee."
		local s = stub(addon, "Print")
		addon:ImportProfile(export)
		assert.stub(s).was_called_with(addon, L.opt_profileSharing_fail_noProfileData)
		assert.stub(s).called_at_most(1)
	end)

	it("should fail when data isn't formatted correctly", function()
		local export = addon.PROFILE_EXPORT_IDENTIFIER .."nSomeName\nThis data is missing the first newline character for seperating data."
		local s = stub(addon, "Print")
		addon:ImportProfile(export)
		assert.stub(s).was_called_with(addon, L.import_not_supported)
		assert.stub(s).called_at_most(1)
	end)

	it("should fail if encoded data is invalid", function()
		local s = stub(addon, "Print")
		local export = addon:GetProfileForExport()
		local a,b,c = string.split("\n", export)
		export = a .. "\n" .. b .. "\nE" .. c
		addon:ImportProfile(export)
		assert.stub(s).was_called_with(addon, L.import_not_supported)
		assert.stub(s).called_at_most(1)
	end)

	it("should fail if data contains extra newlines", function()
		local s = stub(addon, "Print")
		local export = addon:GetProfileForExport()
		local a, b, c = string.split("\n", export)
		export = a .. "\n\n" .. b .. "\n" .. c
		addon:ImportProfile(export)
		assert.stub(s).was_called_with(addon, L.import_not_supported)
		assert.stub(s).called_at_most(1)
		s:clear()
		export = a .. "\n\n\n" .. b .. "\n" .. c
		addon:ImportProfile(export)
		assert.stub(s).was_called_with(addon, L.import_not_supported)
		assert.stub(s).called_at_most(1)
	end)

	it("should techinically not fail if the newline is strategically placed", function()
		local s = stub(addon, "Print")
		local export = addon:GetProfileForExport()
		local a, b, c = string.split("\n", export)
		export = a .. "\n" .. b .. "\n\n" .. c
		addon:ImportProfile(export)
		assert.stub(s).was_not_called_with(addon, L.import_not_supported)
		assert.stub(s).called_at_most(0)
		s:clear()
		export = a .. "\n" .. b .. "\n" .. c .. "\n"
		addon:ImportProfile(export)
		assert.stub(s).was_not_called_with(addon, L.import_not_supported)
		assert.stub(s).called_at_most(0)
	end)
end)
