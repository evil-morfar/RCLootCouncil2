--- TradeUI.lua Handles and displays items to be traded
-- DefaultModule
-- @author Potdisc
-- Create Date : 28/5/2018 16:48:38
--[[ Comms:
   MAIN:
      awarded        P - ML awards an item.
      do_trade       P - ML tells us to perfom a trade.
]]

local _,addon = ...
local TradeUI = addon:NewModule("TradeUI", "AceEvent-3.0", "AceTimer-3.0")
addon.TradeUI = TradeUI -- Shorthand for easier access
local ST = LibStub("ScrollingTable")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LibDialog = LibStub("LibDialog-1.0")
local _G = _G
local Comms = addon.Require "Services.Comms"
local PREFIX = addon.PREFIXES.MAIN

local ROW_HEIGHT = 30
local db
local update_targets_timer
local TIME_REMAINING_INTERVAL = 300 -- 5 min
local TIME_REMAINING_WARNING = 1200 -- 20 min
local UPDATE_TIME_INTERVAL = 1 -- 1 sec
local TRADE_ADD_DELAY = 0.100 -- sec

-- lua
local select, GetItemInfoInstant, pairs, ipairs,  unpack, tinsert, wipe, format, GetTime, CheckInteractDistance, InitiateTrade
    = select, GetItemInfoInstant, pairs, ipairs,  unpack, tinsert, wipe, format, GetTime, CheckInteractDistance, InitiateTrade
-- GLOBALS: GetContainerNumSlots, ClickTradeButton, PickupContainerItem, ClearCursor, GetContainerItemInfo, GetContainerItemLink, GetTradePlayerItemInfo,
-- GLOBALS: IsModifiedClick, HandleModifiedItemClick, GetTradePlayerItemLink, Ambiguate

function TradeUI:OnInitialize()
   self.scrollCols = {
      { name = "", width = ROW_HEIGHT,},   -- Item icon
      { name = "", width = 120,},          -- Item Link
      { name = "", width = ROW_HEIGHT - 5},-- Arrow
      { name = "", width = 100,},          -- Recipient
      { name = "", width = 40,},           -- Trade
   }
   self:Enable()
end

function TradeUI:OnEnable()
   addon:Log("TradeUI enabled")
   db = addon.Getdb()
   self.isTrading = false  -- Are we currently trading
   self.tradeItems = {}    -- Items we are currently trading
   self.tradeTarget = nil  -- Name of our last trade target

   self:RegisterComms()
   self:RegisterEvent("TRADE_SHOW", "OnEvent_TRADE_SHOW")
   self:RegisterEvent("TRADE_CLOSED", "OnEvent_TRADE_CLOSED")
   self:RegisterEvent("TRADE_ACCEPT_UPDATE", "OnEvent_TRADE_ACCEPT_UPDATE")
   self:RegisterEvent("UI_INFO_MESSAGE", "OnEvent_UI_INFO_MESSAGE")
   self:CheckTimeRemaining()
   self:ScheduleRepeatingTimer("CheckTimeRemaining", TIME_REMAINING_INTERVAL)
end

function TradeUI:OnDisable() -- Shouldn't really happen
   addon:Log("TradeUI disabled")
   self:Hide()
end

function TradeUI:RegisterComms ()
   Comms:BulkSubscribe(PREFIX, {
      awarded = function (data)
         self:OnAwardReceived(unpack(data))
      end,
      do_trade = function (data)
         self:OnDoTrade(unpack(data))
      end
   })
end

-- By default, TradeUI hides when empty
function TradeUI:Show(forceShow)
   addon.Log:d("TradeUI:Show()", forceShow)
   self.frame = self:GetFrame()
   update_targets_timer = self:ScheduleRepeatingTimer(function() self.frame.st:Refresh() end, UPDATE_TIME_INTERVAL)
   self:Update(forceShow)
end

function TradeUI:Hide()
   addon.Log:d("TradeUI:Hide()")
   self:CancelTimer(update_targets_timer)
   self.frame:Hide()
end

function TradeUI:Update(forceShow)
   if not self.frame then return self:Show(forceShow) end
   wipe(self.frame.rows)
   for k, v in ipairs(addon.ItemStorage:GetAllItemsOfType("to_trade")) do
      self.frame.rows[k] = {
         link = v.link,
         winner = v.args.recipient,
         cols = {
            {DoCellUpdate = self.SetCellItemIcon},
            {value = v.link},
            {value = "-->"},
            {value = v.args.recipient and addon.Ambiguate(v.args.recipient) or "Unknown", color = addon:GetClassColor(v.args.recipient.class or "nothing")},
            {value = _G.TRADE, color = self.GetTradeLabelColor, colorargs = {self, v.args.recipient},},
         }
      }
   end
   self.frame.st:SetData(self.frame.rows)
   if not forceShow and #self.frame.rows == 0 then self:Hide() else self.frame:Show() end
end

function TradeUI:OnDoTrade (trader, item, winner)
   if addon:UnitIsUnit(trader, "player") then
      -- Item should be registered
      local Item = addon.ItemStorage:GetItem(item, "temp")
      if not Item then
         addon.Log:E("TradeUI", "Couldn't find item for 'DoTrade'", item, winner)
         return addon:Print(format("Couldn't find %s to trade to %s",tostring(item), tostring(winner)))
      end
      Item.type = "to_trade"
      Item.args.recipient = winner
      if Item and addon:UnitIsUnit(winner, "player") and not (addon.testMode or addon.nnp) then
         addon.ItemStorage:RemoveItem(Item)
      end
      self:Show()
   end
end

function TradeUI:OnAwardReceived (session, winner, trader)
   if addon:UnitIsUnit(trader, "player") then
      -- We should give our item to 'winner'
      local Item
      -- Session might have ended, meaning the lootTable is cleared
      local lootSession = addon:GetLootTable()[session]
      addon.Log:d("OnAwardReceived", lootSession, session, winner, trader)
      if lootSession then
         Item = addon.ItemStorage:GetItem(lootSession.link, "temp") -- Update our temp item
         addon.Log:d("Found item as temp")
         if not Item then -- No temp item - maybe a changed award?
            -- In that case we should have the item registered as "to_trade"
            Item = addon.ItemStorage:GetItem(lootSession.link, "to_trade")
            if not Item then
               -- If we still don't have, then create a new
               Item = addon.ItemStorage:New(lootSession.link, "to_trade", {recipient = winner, session = session}):Store()
            end
         end
         Item.type = "to_trade"
         Item.args.recipient = winner
         Item.args.session = session
      else
         -- If the session has ended and we receive another award, it's got to be a reaward. Fetch the item based on the session:
         local Items = self:GetStoredItemBySession(session)
         if Items and #Items > 0 then
            if #Items > 1 then -- We have more than one?
               addon.Log:W("TradeUI","Found multiple items for session", session)
            end
            Item = Items[1]
            Item.args.recipient = winner
            addon.Log:d("Changed winner for", session, Item.link, "to", winner)
         else
            -- We found no items with the session - probably an error (or we have already traded the item)
            addon.Log:E("TradeUI", "Found no stored items for session:", session)
            -- REVIEW Fail silently
         end
      end

      -- Don't add ourself unless we're testing
      -- but do add/update the item first, in case it's a reaward to ourself
      if Item and addon:UnitIsUnit(winner, "player") and not (addon.testMode or addon.nnp) then
         addon.ItemStorage:RemoveItem(Item)
      end
      self:Show()
   end
end

function TradeUI:CheckTimeRemaining()
   local Items = addon.ItemStorage:GetAllItemsLessTimeRemaining(TIME_REMAINING_WARNING)
   -- Filter for items with "to_trade" and "award_later"
   Items = tFilter(Items, function(item)
      return item.type == "to_trade" or item.type == "award_later"
    end, true)
   if #Items > 0 then
      addon:Print(format(L["time_remaining_warning"], TIME_REMAINING_WARNING/60))
      for i, Item in pairs(Items) do
         addon:Print(i, Item)
      end
      for _, Item in pairs(Items) do
         if Item.time_remaining <= 0 and Item:SafeToRemove() then
            addon.Log:d("TradeUI - removed", Item, "due to <= 0 time remaining")
            addon.ItemStorage:RemoveItem(Item)
         end
      end
   end
end

--------------------------------------------------------------
-- Trade Window
--------------------------------------------------------------

function TradeUI:OnEvent_TRADE_SHOW (event, ...)
   self.isTrading = true
   wipe(self.tradeItems)
   self.tradeTarget = addon:UnitName("NPC")
   local count = self:GetNumAwardedInBagsToTradeWindow()

   if count > 0 then
      if db.autoTrade then
         self:AddAwardedInBagsToTradeWindow()
      else
         LibDialog:Spawn("RCLOOTCOUNCIL_TRADE_ADD_ITEM", {count=count})
      end
   end
end

function TradeUI:OnEvent_TRADE_CLOSED (event, ...)
   self.isTrading = false
end

function TradeUI:OnEvent_TRADE_ACCEPT_UPDATE (event, ...) -- Record the item traded
   if select(1, ...) == 1 or select(2, ...) == 1 then
      wipe(self.tradeItems)
      for i = 1, _G.MAX_TRADE_ITEMS-1 do -- The last trade slot is "Will not be traded"
         local link = GetTradePlayerItemLink(i)
         if link then
            tinsert(self.tradeItems, link)
         end
      end
   end
end

function TradeUI:OnEvent_UI_INFO_MESSAGE (event, ...)
   if select(1, ...) == _G.LE_GAME_ERR_TRADE_COMPLETE then -- Trade complete. Remove items from db.baggedItems if traded to winners
      addon.Log:d("TradeUI: Traded item(s) to", self.tradeTarget)
      for _, link in ipairs(self.tradeItems) do
         local Item = addon.ItemStorage:GetItem(link)
         if Item and Item.type and Item.type == "to_trade" then
            if addon:UnitIsUnit(self.tradeTarget, Item.args.recipient) then
               addon:Send("group", "trade_complete", link, self.tradeTarget, addon.playerName)
            elseif Item.args.recipient and not addon:UnitIsUnit(self.tradeTarget, Item.args.recipient) then
               -- Player trades the item to someone else than the winner
               addon:Send("group", "trade_WrongWinner", link, self.tradeTarget, addon.playerName, Item.args.recipient)

               -- REVIEW: Temporary debugging
               addon.Log:D("WrongWinner", self.tradeTarget, Item.args.recipient)
               addon.Log:D("Target:", UnitName("target"))
               addon.Log:D("NPC:", UnitName("NPC"))
            end
         end
         addon.ItemStorage:RemoveItem(link)
      end
      self:Update()
   end
end

-- These functions will be used multiple times, so make them static
local funcTradeTargetIsRecipient = function(v) return addon:UnitIsUnit(TradeUI.tradeTarget, v.args.recipient) end  -- Our trade target is the winner
local funcItemHasMoreTimeLeft    = function(v) return GetTime() < (v.time_added + v.time_remaining) end            -- There's still time remaining
local funcStorageTypeIsToTrade   = function(v) return v.type == "to_trade" end                                     -- The stored item type is "to_trade"

function TradeUI:GetNumAwardedInBagsToTradeWindow()
   return #addon.ItemStorage:GetAllItemsMultiPred(
      funcTradeTargetIsRecipient,
      funcItemHasMoreTimeLeft
   )
end

function TradeUI:GetStoredItemBySession (session)
   return tFilter(addon.ItemStorage:GetAllItemsOfType("to_trade"), function(v)
      return v.args.session and v.args.session == session
   end, true)
end

local function addItemToTradeWindow (tradeBtn, Item)
   addon.Log:d("addItemToTradeWindow", tradeBtn, Item)
   local c,s = addon.ItemStorage:GetItemContainerSlot(Item)
   if not c then -- Item is gone?!
      addon:Print(L["trade_item_to_trade_not_found"])
      return addon.Log:E("TradeUI", "Item missing when attempting to trade", Item.link, TradeUI.tradeTarget)
   end
   local _, _, _, _, _, _, link = GetContainerItemInfo(c, s)
   if addon:ItemIsItem(link, Item.link) then -- Extra check, probably also redundant
      addon.Log:d("Trading", link, c,s)
      ClearCursor()
      PickupContainerItem(c, s)
      ClickTradeButton(tradeBtn)
   else -- Shouldn't happen
      return addon.Log:E("TradeUI", "Item link mismatch", link, Item.link)
   end
end

function TradeUI:AddAwardedInBagsToTradeWindow()
   local items = addon.ItemStorage:GetAllItemsMultiPred(
      funcTradeTargetIsRecipient, funcItemHasMoreTimeLeft, funcStorageTypeIsToTrade
   )
   addon.Log:d("Number of items to trade:", #items)
   for k, Item in ipairs(items) do
      if k > _G.MAX_TRADE_ITEMS - 1 then -- All available slots used (The last trade slot is "Will not be traded" slot).
			break
		end
      if self.isTrading then
         addon.Log:d("<TradeUI> Scheduling trade add timer for #", k)
         -- Delay the adding of items, as we can't add them all at once
         self:ScheduleTimer(addItemToTradeWindow, TRADE_ADD_DELAY * k, k, Item)
      end
   end
   -- TradeFrameTradeButton:Click() REVIEW When calling this, it seems trade is accepted and then immediately unaccepted. Called it through a timer yield ADDON_ACTION_BLOCKED error.
   -- It might just be protected (HW) after all, but it's odd it doesn't always produce an error.
end

--------------------------------------------------------
-- UI stuff
--------------------------------------------------------
function TradeUI.SetCellItemIcon(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
   local link = data[realrow].link
   local texture = select(5, GetItemInfoInstant(link)) or "Interface/ICONS/INV_Sigil_Thorim.png"
	frame:SetNormalTexture(texture)
	frame:SetScript("OnEnter", function() addon:CreateHypertip(link) end)
	frame:SetScript("OnLeave", function() addon:HideTooltip() end)
	frame:SetScript("OnClick", function()
		if IsModifiedClick() then
		   HandleModifiedItemClick(link);
      end
	end)
end

function TradeUI:GetFrame()
   if self.frame then return self.frame end

   local f = addon.UI:NewNamed("Frame", UIParent, "RCDefaultTradeUIFrame", "RCLootCouncil Trade UI", nil, 220)
   f.st = ST:CreateST(self.scrollCols, 5, ROW_HEIGHT, nil, f.content)
   f.st.frame:SetPoint("TOPLEFT",f,"TOPLEFT",10,-20)
   f.st:RegisterEvents({
      ["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
         if CheckInteractDistance(Ambiguate(data[realrow].winner, "short"), 2) then -- 2 for trade distance
            InitiateTrade(Ambiguate(data[realrow].winner, "short"))
         else
            addon.Log:d("TradeUI row OnClick - unit not in trade distance")
         end

         -- Return false to have the default OnClick handler take care of left clicks
         return false
      end,
   })
   f:SetWidth(f.st.frame:GetWidth()+20)
	f.rows = {}

   f.closeBtn = addon:CreateButton(_G.CLOSE, f.content)
   f.closeBtn:SetPoint("BOTTOMRIGHT", f.content, "BOTTOMRIGHT", -10, 10)
   f.closeBtn:SetScript("OnClick", function()
      self:Hide()
   end)

   return f
end

function TradeUI:GetTradeLabelColor(target)
   return CheckInteractDistance(Ambiguate(target, "short"), 2) and {r=0,g=1,b=0,a=1} or {r=1,g=0,b=0,a=1}
end
