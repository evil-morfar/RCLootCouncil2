require "busted.runner" ()
---@type assert|luassert
local assert = assert
---@type RCLootCouncil
_G.RCLootCouncil = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")

describe("#Skin", function()
	local addon = RCLootCouncil
	local originalUI

	before_each(function()
		addon.db = LibStub("AceDB-3.0"):New("RCLootCouncilSkinTestDB", addon.defaults, true)
		addon.db.profile.UI.LegacyFrame = nil
		addon.Log = addon.Require "Utils.Log":New()
		originalUI = addon.UI
	end)

	after_each(function()
		addon.UI = originalUI
		addon.activeSkin = nil
	end)

	it("removes legacy skin properties from UI in the 3.26.0 compatibility migration", function()
		local frameData = {
			x = 25,
			y = -30,
			point = "TOP",
			scale = 1.2,
			bgColor = {1, 0, 0, 1},
			borderColor = {1, 1, 1, 1},
			background = "Blizzard Tooltip",
			border = "Blizzard Tooltip",
			scrollTable = {tileSize = 32},
		}
		addon.db.profile.UI.LegacyFrame = frameData

		local migration
		for _, compatibility in ipairs(addon.Compat.list) do
			if compatibility.name == "Remove skin data from UI settings" then
				assert.are.equal("3.26.0", compatibility.version)
				migration = compatibility.func
				break
			end
		end
		assert.is_function(migration)
		migration()

		assert.are.same({x = 25, y = -30, point = "TOP", scale = 1.2}, frameData)
		assert.is_nil(addon.defaults.profile.UI["**"].background)
		assert.is_nil(addon.defaults.profile.UI["**"].scrollTable)
	end)

	it("applies active skin data to live frames without storing it in UI", function()
		local rcFrame = {Update = function(self, skin) self.updatedSkin = skin end}
		local scrollTable = {
			SetBackdrop = function(self, skin) self.updatedSkin = skin.scrollTable end,
		}
		addon.UI = {
			GetCreatedFramesOfType = function(_, frameType)
				if frameType == "RCFrame" then return {rcFrame} end
				if frameType == "LibST" then return {scrollTable} end
				return {}
			end,
		}

		addon:ActivateSkin("new_blue")

		assert.are.same(addon.db.profile.skins.new_blue.bgColor, rcFrame.updatedSkin.bgColor)
		assert.are.same(addon.db.profile.skins.new_blue.scrollTable, scrollTable.updatedSkin)
		assert.is_nil(rcFrame.skin)
		assert.is_nil(addon.db.profile.UI.LegacyFrame.background)
		assert.is_nil(addon.db.profile.UI.LegacyFrame.scrollTable)
	end)

	it("fills default scroll table settings when resetting built-in skins", function()
		addon.db.profile.skins.bfa = CopyTable(addon.defaults.profile.skins.bfa)

		addon:ActivateSkin("bfa")

		assert.are.same(addon.defaults.profile.skins["**"].scrollTable, addon.activeSkin.scrollTable)
		assert.is_false(addon:IsSkinDirty())
	end)

	it("saves a deep copy of the active skin", function()
		addon:ActivateSkin("new_blue")
		assert.is_false(addon:IsSkinDirty())
		addon.activeSkin.bgColor[1] = 0.25
		assert.is_true(addon:IsSkinDirty())
		addon:SaveSkin("custom")
		assert.is_false(addon:IsSkinDirty())
		addon.activeSkin.bgColor[1] = 0.75

		assert.are.equal("custom", addon.db.profile.currentSkin)
		assert.are.equal("custom", addon.db.profile.skins.custom.name)
		assert.are.equal(0.25, addon.db.profile.skins.custom.bgColor[1])
		assert.are.same(addon.db.profile.skins.new_blue.scrollTable, addon.db.profile.skins.custom.scrollTable)
	end)
end)
