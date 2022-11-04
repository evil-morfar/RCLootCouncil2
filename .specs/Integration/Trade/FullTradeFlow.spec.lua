dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
dofile ".specs/EmulatePlayerLogin.lua"

local addon = RCLootCouncil

_G.IsInRaidVal = true

describe("#Integration #Trade #FullTradeFlow", function()
	local spyTradeComplete
	local spyTradeWrongWinner
	local Comms = addon.Require "Services.Comms"

	before_each(function()
		spyTradeComplete = spy.new()
		spyTradeWrongWinner = spy.new()
		Comms:RegisterPrefix(addon.PREFIXES.MAIN)
		Comms:Subscribe(addon.PREFIXES.MAIN, "trade_WrongWinner", spyTradeWrongWinner)
		Comms:Subscribe(addon.PREFIXES.MAIN, "trade_complete", spyTradeComplete)

	end)

	after_each(function()
		Comms:OnDisable()
		addon.ItemStorage:RemoveAllItems()
	end)

	it("should perform a full trade flow", function()
		-- Get an item
		local itemString = _G.Items_Array[1]

		-- Stub GetLootTable, as TradeUI relies on something being there.
		stub(addon, "GetLootTable", {{link = itemString}})
		-- Store it as if we've looted it
		local item = addon.ItemStorage:New(itemString, "temp"):Store()
		-- override time_remaining so it's tradeable
		item.time_remaining = 3600
		-- Storage should now only contain that item
		assert.are.equal(1, #addon.ItemStorage:GetAllItems())
		-- Check all's good
		assert.are.equal("temp", item.type)
		assert.are.equal(itemString, item.link)
		-- Pretend an item has been awarded 
		local winner = GetStoredPlayerNameToGUID("Player2").name
		stub(_G, "UnitName", function(unit)
			if unit == "npc" then return winner end
			return unit
		end)
		addon.TradeUI:OnAwardReceived(1, winner, addon.playerName)

		assert.True(addon.TradeUI.frame:IsShown())

		-- At this point we should still only have one item in storage
		assert.are.equal(1, #addon.ItemStorage:GetAllItems())
		-- and our item should have updated
		assert.are.equal("to_trade", item.type)
		assert.are.same({recipient = "Player2-Realm1", session = 1}, item.args)

		-- Pretend to trade
		-- Turn on autoTrade to avoid popups
		addon.db.profile.autoTrade = true
		WoWAPI_FireEvent("TRADE_SHOW")
		-- accept trade
		stub(_G, "GetTradePlayerItemLink", function(i)
			if i == 1 then
				return itemString
			else
				return nil
			end
		end)
		WoWAPI_FireEvent("TRADE_ACCEPT_UPDATE", 1)
		assert.are.equal(1, #addon.TradeUI.tradeItems)
		assert.are.equal(itemString, addon.TradeUI.tradeItems[1])
		WoWAPI_FireEvent("UI_INFO_MESSAGE", _G.LE_GAME_ERR_TRADE_COMPLETE)

		-- Our item should now have been removed from storage
		assert.are.equal(0, #addon.ItemStorage:GetAllItems())
		assert.False(addon.TradeUI.frame:IsShown())

		-- Test Comms
		WoWAPI_FireUpdate(GetTime() + 10)
		assert.spy(spyTradeWrongWinner).was_not_called()
		assert.spy(spyTradeComplete).was_called(1)
	end)

	it("trading wrong winner should remove first instance of the item", function()
		-- Get an item
		local itemString = _G.Items_Array[1]
		local itemString2 = _G.Items_Array[2]

		-- Setup some items as if they've been awarded
		stub(addon, "GetContainerItemTradeTimeRemaining", 3600)
		addon.ItemStorage:New(itemString2, "to_trade", {recipient = "Player1-Realm1", session = 1}):Store()
		addon.ItemStorage:New(itemString, "to_trade", {recipient = "Player1-Realm1", session = 1}):Store()
		addon.ItemStorage:New(itemString, "to_trade", {recipient = "Player2-Realm1", session = 1}):Store()

		assert.are.equal(3, #addon.ItemStorage:GetAllItems())

		-- Setup vars normally handled when trading
		addon.TradeUI.tradeItems = {itemString}
		addon.TradeUI.tradeTarget = "Player3-Realm1"

		WoWAPI_FireEvent("UI_INFO_MESSAGE", _G.LE_GAME_ERR_TRADE_COMPLETE)
		-- Item 2 should now be removed
		assert.are.equal(2, #addon.ItemStorage:GetAllItems())
		local remaining = addon.ItemStorage:GetItem(itemString)
		assert.are.same({recipient = "Player2-Realm1", session = 1}, remaining.args)

		-- Test Comms
		WoWAPI_FireUpdate(GetTime() + 10)
		assert.spy(spyTradeWrongWinner).was_called(1)
		assert.spy(spyTradeComplete).was_not_called()
	end)

	it("trading duplicate items removes the proper one", function()
		printtable(addon.db.profile.itemStorage)
		print (addon.db.profile.itemStorage[1])
	   -- Get an item
		local itemString = _G.Items_Array[1]

		-- Setup some items as if they've been awarded
		local item1 = addon.ItemStorage:New(itemString, "to_trade"):Store()
		item1.time_remaining = 3600
		item1.args = {recipient = "Player1-Realm1", session = 1}
		local item2 = addon.ItemStorage:New(itemString, "to_trade"):Store()
		item2.time_remaining = 3600
		item2.args = {recipient = "Player2-Realm1", session = 2}

		assert.are.equal(2, #addon.ItemStorage:GetAllItems())

		-- Setup vars normally handled when trading
		addon.TradeUI.tradeItems = {itemString}
		addon.TradeUI.tradeTarget = "Player2-Realm1"

		WoWAPI_FireEvent("UI_INFO_MESSAGE", _G.LE_GAME_ERR_TRADE_COMPLETE)
		-- Item 2 should now be removed
		assert.are.equal(1, #addon.ItemStorage:GetAllItems())
		local remaining = addon.ItemStorage:GetItem(itemString)
		
		assert.are.same({recipient = "Player1-Realm1", session = 1}, remaining.args)

		-- Test Comms
		WoWAPI_FireUpdate(GetTime() + 10)
		assert.spy(spyTradeWrongWinner).was_not_called()
		assert.spy(spyTradeComplete).was_called(1)
	end)
end)

-- Global helpers
function _G.GetContainerNumSlots(bagID) return 10 end

-- Lets say our item is always in bag 2, slot 3
function _G.GetContainerItemLink(bagID, slotIndex)
	if bagID ~= 2 or (bagID == 2 and slotIndex ~= 3) then return _G.Items_Array[math.random(100, #_G.Items_Array)] end
	-- bag 2, slot 3
	return _G.Items_Array[1]
end

function _G.CheckInteractDistance(unit, distIndex) return false end
