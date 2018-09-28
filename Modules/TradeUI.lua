--- TradeUI.lua	Handles and displays items to be traded
-- DefaultModule
-- @author Potdisc
-- Create Date : 28/5/2018 16:48:38

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local TradeUI = addon:NewModule("RCTradeUI", "AceComm-3.0", "AceEvent-3.0", "AceTimer-3.0")
addon.TradeUI = TradeUI -- Shorthand for easier access
local ST = LibStub("ScrollingTable")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LibDialog = LibStub("LibDialog-1.0")
local _G = _G

local ROW_HEIGHT = 30
local db
local time_remaining_timer, update_targets_timer
local TIME_REMAINING_INTERVAL = 300 -- 5 min
local TIME_REMAINING_WARNING = 1200 -- 20 min
local UPDATE_TIME_INTERVAL = 1 -- 1 sec

-- lua
local select, GetItemInfoInstant, pairs, ipairs,  unpack, tinsert, wipe, tremove, format, table, GetTime, CheckInteractDistance, InitiateTrade
    = select, GetItemInfoInstant, pairs, ipairs,  unpack, tinsert, wipe, tremove, format, table, GetTime, CheckInteractDistance, InitiateTrade
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
   addon:DebugLog("TradeUI enabled")
   db = addon.Getdb()
   self.isTrading = false  -- Are we currently trading
   self.tradeItems = {}    -- Items we are currently trading
   self.tradeTarget = nil  -- Name of our last trade target

   self:RegisterComm("RCLootCouncil")
   self:RegisterEvent("TRADE_SHOW", "OnEvent_TRADE_SHOW")
   self:RegisterEvent("TRADE_CLOSED", "OnEvent_TRADE_CLOSED")
   self:RegisterEvent("TRADE_ACCEPT_UPDATE", "OnEvent_TRADE_ACCEPT_UPDATE")
   self:RegisterEvent("UI_INFO_MESSAGE", "OnEvent_UI_INFO_MESSAGE")
   self:CheckTimeRemaining()
   time_remaining_timer = self:ScheduleRepeatingTimer("CheckTimeRemaining", TIME_REMAINING_INTERVAL)
end

function TradeUI:OnDisable() -- Shouldn't really happen
   addon:DebugLog("TradeUI disabled")
   self:Hide()
end

-- By default, TradeUI hides when empty
function TradeUI:Show(forceShow)
   addon:Debug("TradeUI:Show()", forceShow)
   self.frame = self:GetFrame()
   update_targets_timer = self:ScheduleRepeatingTimer(function() self.frame.st:Refresh() end, UPDATE_TIME_INTERVAL)
   self:Update(forceShow)
end

function TradeUI:Hide()
   addon:Debug("TradeUI:Hide()")
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
            {value = addon.Ambiguate(v.args.recipient), color = addon:GetClassColor(addon.candidates[v.args.recipient] and addon.candidates[v.args.recipient].class or "nothing")},
            {value = _G.TRADE, color = self.GetTradeLabelColor, colorargs = {self, v.args.recipient},},
         }
      }
   end
   self.frame.st:SetData(self.frame.rows)
   if not forceShow and #self.frame.rows == 0 then self:Hide() else self.frame:Show() end
end

function TradeUI:OnCommReceived(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncil" then
		local test, command, data = addon:Deserialize(serializedMsg)
		if addon:HandleXRealmComms(self, command, data, sender) then return end
		if test and command == "awarded" then
         local session, winner, trader = unpack(data)
         if addon:UnitIsUnit(trader, "player") then
            -- We should give our item to 'winner'
            if not addon:UnitIsUnit(winner, "player") or (addon.testMode or addon.nnp) then -- Don't add ourself unless we're testing
               addon.ItemStorage:StoreItem(addon:GetLootTable()[session].link, "to_trade", {recipient = winner})
            end
            self:Show()
         end
      end
   end
end

function TradeUI:CheckTimeRemaining()
   -- This will handle all items in ItemStorage, not just to_trade.
   -- It might as well since it's always runnning, although I might change that if need be.
   local Items = addon.ItemStorage:GetAllItemsLessTimeRemaining(TIME_REMAINING_WARNING)
   if #Items > 0 then
      addon:Print(format(L["time_remaining_warning"], TIME_REMAINING_WARNING/60))
      for i, Item in pairs(Items) do
         addon:Print(i, Item)
      end
      for i, Item in pairs(Items) do
         if Item.time_remaining <= 0 then
            addon:DebugLog("TradeUI - removed", Item, "due to <= 0 time remaining")
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
      -- TODO Make this optionally automatic
      LibDialog:Spawn("RCLOOTCOUNCIL_TRADE_ADD_ITEM", {count=count})
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
      addon:Debug("TradeUI: Traded item(s) to", self.tradeTarget)
      -- TODO This records every single item we trade - modify to only do stuff with items we are actively handling
      for _, link in ipairs(self.tradeItems) do
         local Item = addon.ItemStorage:GetItem(link)
         if Item and addon:UnitIsUnit(self.tradeTarget, Item.args.recipient) then
            -- REVIEW This check is probably redundant, but currently TRADE_ACCEPT_UPDATE just adds all traded items, not just those we track
            addon:SendCommand("group", "trade_complete", link, self.tradeTarget, addon.playerName)
         elseif Item and not addon:UnitIsUnit(self.tradeTarget, Item.args.recipient) then
            -- Player trades the item to someone else than the winner
            addon:SendCommand("group", "trade_WrongWinner", link, self.tradeTarget, addon.playerName, Item.args.recipient)
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

function TradeUI:AddAwardedInBagsToTradeWindow()
   local tradeIndex = 1
   local items = addon.ItemStorage:GetAllItemsMultiPred(
      funcTradeTargetIsRecipient, funcItemHasMoreTimeLeft, funcStorageTypeIsToTrade
   )
   addon:Debug("Number of items to trade:", #items)
   for k, Item in ipairs(items) do
      if k > _G.MAX_TRADE_ITEMS - 1 then -- All available slots used (The last trade slot is "Will not be traded" slot).
			break
		end
      local c,s = addon.ItemStorage:GetItemContainerSlot(Item)
      if not c then -- Item is gone?!
         addon:Print(L["trade_item_to_trade_not_found"])
         return addon:Debug("Error TradeUI:", "Item missing when attempting to trade", Item.link, self.tradeTarget)
      end
      if self.isTrading then
         addon:Debug("#Trading", k)
         local _, _, locked, _, _, _, link = GetContainerItemInfo(c, s)
         if addon:ItemIsItem(link, Item.link) then -- Extra check, probably also redundant
            ClearCursor()
				PickupContainerItem(c, s)
				ClickTradeButton(k)
         end
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

   local f = addon:CreateFrame("RCDefaultTradeUIFrame", "tradeui", "RCLootCouncil Trade UI", nil, 220)
   f.st = ST:CreateST(self.scrollCols, 5, ROW_HEIGHT, nil, f.content)
   f.st.frame:SetPoint("TOPLEFT",f,"TOPLEFT",10,-20)
   f.st:RegisterEvents({
      ["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
         if CheckInteractDistance(Ambiguate(data[realrow].winner, "short"), 2) then -- 2 for trade distance
            InitiateTrade(Ambiguate(data[realrow].winner, "short"))
         else
            addon:Debug("TradeUI row OnClick - unit not in trade distance")
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
