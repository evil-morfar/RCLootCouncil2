loadfile(".specs/AddonLoader.lua")().LoadToc("RCLootCouncil.toc")
dofile ".specs/EmulatePlayerLogin.lua"
local addon = RCLootCouncil
local private = {}
local ItemUtils = addon.Require "Utils.Item"
local Comms = addon.Require "Services.Comms"
local player1 = "Player1-Realm1"
describe("#Integration #ItemStorage #Tradable", function()
	local function CreateSpy()
		local s = spy.new(function(...) return ... end)
		Comms:Subscribe(addon.PREFIXES.MAIN, "tradable", s)
		Comms:Subscribe(addon.PREFIXES.MAIN, "n_t", s)
		return s
	end
	local function DoLootDrop(i)
		addon.Require("Utils.GroupLoot").OnLootRoll(private.items[i], 1, 0)
		_ADVANCE_TIME(1)
		WoWAPI_FireEvent("LOOT_READY")
		WoWAPI_FireEvent("LOOT_SLOT_CLEARED", i)
		_ADVANCE_TIME(2)
	end

	it("should send items with 0 time remaining as 'n_t", function()
		local s = CreateSpy()
		DoLootDrop(1)
		assert.spy(s).was_called(1)
		assert.spy(s).was_called_with(match.is_table(), player1, "n_t", "WHISPER")
		assert.spy(s).was_not_called_with(match.is_table(), player1, "tradable", "WHISPER")
	end)

	it("should send items with time remaining as 'tradable", function()
		local s = CreateSpy()
		DoLootDrop(2)
		assert.spy(s).was_called(1)
		assert.spy(s).was_called_with(match.is_table(), player1, "tradable", "WHISPER")
		assert.spy(s).was_not_called_with(match.is_table(), player1, "n_t", "WHISPER")
	end)

	it("should not send any messages when item isn't found", function()
		local s = CreateSpy()
		DoLootDrop(3)
		_ADVANCE_TIME(6)
		assert.spy(s).was_called(0)
	end)
end)

local orig_GetContainerItemTradeTimeRemaining = addon.GetContainerItemTradeTimeRemaining
function addon:GetContainerItemTradeTimeRemaining(container, slot)
	if container ~= 1 or not private.items[slot] then return orig_GetContainerItemTradeTimeRemaining(addon, container,
	slot) end
	return private.items[slot].tradeTime
end

_G.C_Container.GetContainerItemLink = function(bagID, slotIndex)
	if bagID == 1 and private.items[slotIndex] and not private.items[slotIndex].notInBags then
		return private.items[slotIndex] and private.items[slotIndex].link
	end
end

function _G.GetNumLootItems() return #private.items end

function _G.LootSlotHasItem(i) return private.items[i] end

function _G.GetLootSlotInfo(slot)
	return "texture", ItemUtils:GetItemNameFromLink(private.items[slot].link), 1, nil,
		Enum.ItemQuality.Epic
end

function _G.GetLootSlotLink(i) return private.items[i].link end

function _G.IsInInstance() return true end

function _G.GetLootSourceInfo(i) end

function _G.GetUnitName()
	return player1
end

private.items = {
	{
		link = "|cffa335ee|Hitem:236960::::::::80:253::3::1:28:872:::::|h[Prototype~`A.S.M.R.]|h|r",
		tradeTime = 0,
	},
	{
		link = _G.Items_Array[math.random(1, #_G.Items_Array)],
		tradeTime = 3600,
	},
	{
		link = _G.Items_Array[math.random(1, #_G.Items_Array)],
		tradeTime = 3600,
		notInBags = true,
	},
}
