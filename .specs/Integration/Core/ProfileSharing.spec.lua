require "busted.runner" ()
---@type assert|luassert
local assert = assert
---@type RCLootCouncil
_G.RCLootCouncil = dofile(".specs/AddonLoader.lua").LoadArray {
	[[Libs\LibStub\LibStub.lua]],
	[[Libs\CallbackHandler-1.0\CallbackHandler-1.0.xml]],
	[[Libs\AceLocale-3.0\AceLocale-3.0.xml]],
	[[Libs\AceEvent-3.0\AceEvent-3.0.xml]],
	[[Libs\AceDB-3.0\AceDB-3.0.xml]],
	[[Libs\AceSerializer-3.0\AceSerializer-3.0.xml]],
	[[Libs\AceGUI-3.0\AceGUI-3.0.xml]],
	[[Libs\AceConfig-3.0\AceConfig-3.0.xml]],
	[[Libs\LibDeflate\LibDeflate.lua]],
	[[Classes/Core.lua]],
	[[Classes\Utils\TempTable.lua]],
	[[Classes/Utils/Log.lua]],
	[[Classes/Services/ErrorHandler.lua]],
	[[Classes/Data/Player.lua]],
	[[Locale\enUS.lua]],
	[[Classes/Utils/Item.lua]],
	[[Utils/Utils.lua]],
	[[Core/Defaults.lua]],
	[[Core/Constants.lua]],
	[[Modules/options.lua]],
}

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
		local s = spy.on(addon, "ApplyProfile")

		local export = addon:GetProfileForExport()
		addon:ImportProfile(export)
		assert.spy(s).was_called_with(addon, profileName, match.Same(preDB))
	end)

	it("should fail when imported data doesn't contain our magic word", function()
		local export = "NotRCLootCouncilProfile\nSomeName\nAll the data that might be hereeeeeeeeeeeeeeeee."
		local s = spy.on(addon, "Print")
		addon:ImportProfile(export)
		assert.spy(s).was_called_with(addon, L.opt_profileSharing_fail_noProfileData)
		assert.spy(s).called_at_most(1)
	end)

	it("should fail when data isn't formatted correctly", function()
		local export = addon.PROFILE_EXPORT_IDENTIFIER .."nSomeName\nThis data is missing the first newline character for seperating data."
		local s = spy.on(addon, "Print")
		addon:ImportProfile(export)
		assert.spy(s).was_called_with(addon, L.import_not_supported)
		assert.spy(s).called_at_most(1)
	end)

	it("should fail if encoded data is invalid", function()
		local s = spy.on(addon, "Print")
		local export = addon:GetProfileForExport()
		local a,b,c = string.split("\n", export)
		export = a .. "\n" .. b .. "\nE" .. c
		addon:ImportProfile(export)
		assert.spy(s).was_called_with(addon, L.import_not_supported)
		assert.spy(s).called_at_most(1)
	end)

	it("should fail if data contains extra newlines", function()
		local s = spy.on(addon, "Print")
		local export = addon:GetProfileForExport()
		local a, b, c = string.split("\n", export)
		export = a .. "\n\n" .. b .. "\n" .. c
		addon:ImportProfile(export)
		assert.spy(s).was_called_with(addon, L.import_not_supported)
		assert.spy(s).called_at_most(1)
		s:clear()
		export = a .. "\n\n\n" .. b .. "\n" .. c
		addon:ImportProfile(export)
		assert.spy(s).was_called_with(addon, L.import_not_supported)
		assert.spy(s).called_at_most(1)
	end)

	it("should techinically not fail if the newline is strategically placed", function()
		---@type luassert.spy
		local s = spy.on(addon, "Print")
		local export = addon:GetProfileForExport()
		local a, b, c = string.split("\n", export)
		export = a .. "\n" .. b .. "\n\n" .. c
		addon:ImportProfile(export)
		assert.spy(s).was_not_called_with(addon, L.import_not_supported)
		assert.spy(s).called_at_most(0)
		s:clear()
		export = a .. "\n" .. b .. "\n" .. c .. "\n"
		addon:ImportProfile(export)
		assert.spy(s).was_not_called_with(addon, L.import_not_supported)
		assert.spy(s).called_at_most(0)
	end)
end)
