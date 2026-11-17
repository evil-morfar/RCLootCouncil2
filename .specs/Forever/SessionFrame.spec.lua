require "busted.runner"()

local addon = loadfile(".specs/AddonLoader.lua")(false, "RCLootCouncil", nil, 18).LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")

describe("#Forever #SessionFrame", function()
	local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
	local SF = addon:GetModule("RCSessionFrame")
	local originalGetLootMethod

	before_each(function()
		addon.db:ResetDB()
		originalGetLootMethod = addon.GetLootMethod
		SF:Enable()
		SF.frame = nil
		SF.lastLootMethod = nil
		SF.mlLootToPlayer = nil
	end)

	after_each(function()
		addon.GetLootMethod = originalGetLootMethod
		if SF.frame then
			SF.frame:Hide()
			SF.frame = nil
		end
		SF.lastLootMethod = nil
	end)

	it("creates manualTradeToggle on frame", function()
		addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end
		local frame = SF:GetFrame()
		SF.frame = frame

		assert.is_not_nil(frame.manualTradeToggle)
		assert.are.equal(L.opt_forever_mlLootToPlayer_name, frame.manualTradeToggle.Text:GetText())
		assert.are.equal(L.opt_forever_mlLootToPlayer_desc, frame.manualTradeToggle.tooltip)
	end)

	it("hides manualTradeToggle and disables mlLootToPlayer when not master looter", function()
		addon.GetLootMethod = function() return Enum.LootMethod.Group end

		local frame = SF:GetFrame()
		SF.frame = frame

		assert.is_not_nil(frame.manualTradeToggle)
		assert.is_false(SF.mlLootToPlayer)
		assert.is_false(frame.manualTradeToggle:IsShown())
	end)

	it("shows manualTradeToggle and updates mlLootToPlayer when loot method changes to Masterlooter", function()
		addon.GetLootMethod = function() return Enum.LootMethod.Group end
		local frame = SF:GetFrame()
		SF.frame = frame
		assert.is_false(SF.mlLootToPlayer)

		local sShow = spy.on(frame.manualTradeToggle, "Show")

		-- Change loot method to Masterlooter
		addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end
		addon:Getdb().mlLootToPlayer = true
		SF:Show({})

		assert.spy(sShow).was.called()
		assert.is_true(frame.manualTradeToggle:IsShown())
		assert.is_true(SF.mlLootToPlayer)

		sShow:revert()
	end)

	it("hides manualTradeToggle and sets mlLootToPlayer to false when loot method changes away from Masterlooter", function()
		addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end
		local frame = SF:GetFrame()
		SF.frame = frame
		frame.manualTradeToggle:Show()
		SF.mlLootToPlayer = true

		local sHide = spy.on(frame.manualTradeToggle, "Hide")

		-- Change loot method to Group
		addon.GetLootMethod = function() return Enum.LootMethod.Group end
		SF:Show({})

		assert.spy(sHide).was.called()
		assert.is_false(frame.manualTradeToggle:IsShown())
		assert.is_false(SF.mlLootToPlayer)

		sHide:revert()
	end)

	it("toggles mlLootToPlayer when clicked", function()
		addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end
		local frame = SF:GetFrame()
		SF.frame = frame
		SF.mlLootToPlayer = true

		local onClick = frame.manualTradeToggle:GetScript("OnClick")
		assert.is_function(onClick)

		onClick(frame.manualTradeToggle)
		assert.is_false(SF.mlLootToPlayer)

		onClick(frame.manualTradeToggle)
		assert.is_true(SF.mlLootToPlayer)
	end)

	it("updates checkbox state in Update hook", function()
		addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end
		local frame = SF:GetFrame()
		SF.frame = frame

		SF.mlLootToPlayer = true
		SF:Update()
		assert.is_true(frame.manualTradeToggle:GetChecked())

		SF.mlLootToPlayer = false
		SF:Update()
		assert.is_false(frame.manualTradeToggle:GetChecked())
	end)
end)
