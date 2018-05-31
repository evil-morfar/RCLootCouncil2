--- TradeUI.lua	Handles and displays items to be traded
-- DefaultModule
-- @author Potdisc
-- Create Date : 28/5/2018 16:48:38

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local TradeUI = addon:NewModule("RCTradeUI", "AceComm-3.0", "AceEvent-3.0")
addon.TradeUI = TradeUI -- Shorthand for easier access
local ST = LibStub("ScrollingTable")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LibDialog = LibStub("LibDialog-1.0")
local _G = _G

local ROW_HEIGHT = 30
local db

-- lua
local select, GetItemInfoInstant, ipairs,  unpack, tinsert, wipe, tremove, format, table
    = select, GetItemInfoInstant, ipairs,  unpack, tinsert, wipe, tremove, format, table
-- GLOBALS: GetContainerNumSlots, ClickTradeButton, PickupContainerItem, ClearCursor, GetContainerItemInfo, GetContainerItemLink, GetTradePlayerItemInfo,
-- GLOBALS: IsModifiedClick, HandleModifiedItemClick, GetTradePlayerItemLink

function TradeUI:OnInitialize()
   self.scrollCols = {
      { name = "", width = ROW_HEIGHT,},   -- Item icon
      { name = "", width = 120,},          -- Item Link
      { name = "", width = ROW_HEIGHT - 5},-- Arrow
      { name = "", width = 100,},          -- Recipient
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
end

function TradeUI:OnDisable()
   addon:DebugLog("TradeUI disabled")
   self.frame:Hide()
end

function TradeUI:Show()
   self.frame = self:GetFrame()
   self:Update()
   self.frame:Show()
end

function TradeUI:Update()
   if not self.frame then return self:Show() end
   for k, v in ipairs(addon.itemsToTrade) do
      self.frame.rows[k] = {
         link = v.item,
         winner = v.recipient,
         cols = {
            {DoCellUpdate = self.SetCellItemIcon},
            {value = v.item},
            {value = "-->"},
            {value = addon.Ambiguate(v.recipient), color = addon:GetClassColor(addon.candidates[v.recipient] and addon.candidates[v.recipient].class or "nothing")},
         }
      }
   end
   self.frame.st:SetData(self.frame.rows)
end

function TradeUI:OnCommReceived(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncil" then
		local test, command, data = addon:Deserialize(serializedMsg)
		if addon:HandleXRealmComms(self, command, data, sender) then return end
		if test and command == "awarded" then
         local session, winner, trader = unpack(data)
         if addon:UnitIsUnit(trader, "player") then
            -- We should give our item to 'winner'
            tinsert(addon.itemsToTrade, {
               item = addon:GetLootTable()[session].link,
               recipient = winner,
            })
            self:Show()
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
   if addon.isMasterLooter	then
      local count = self:GetNumAwardedInBagsToTradeWindow()
      if count > 0 then
         LibDialog:Spawn("RCLOOTCOUNCIL_TRADE_ADD_ITEM", {count=count})
      end
   end
end

function TradeUI:OnEvent_TRADE_CLOSED (event, ...)
   self.isTrading = false -- Dont clear self.targetTarget here.
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
      local tradedItemsInBag = {}
      for _, link in ipairs(self.tradeItems) do
         for i = #db.baggedItems, 1, -1 do -- when the loop contains tremove, loop must be traversed in reverse order.
            local winner = db.baggedItems[i].winner
            local link = db.baggedItems[i].link
            if addon:UnitIsUnit(db.baggedItems[i].winner, self.tradeTarget) and addon:ItemIsItem(db.baggedItems[i].link, link)  then
               addon:Debug("Remove item from db.baggedItems because traded to", winner, link)
               tremove(db.baggedItems, i)
               tinsert(tradedItemsInBag, link)
               break
            end
         end
      end

      if #tradedItemsInBag > 0 then
         -- TODO Change this string
         addon:Print(format(L["The following items are removed from the award later list and traded to 'player'"], addon:GetUnitClassColoredName(self.tradeTarget)))
         addon:Print(table.concat(tradedItemsInBag))
      end
   end
end

function TradeUI:GetNumAwardedInBagsToTradeWindow()
	local count = 0
	local countedSlots = {}
	for _, v in ipairs(db.baggedItems) do
		if v.winner and addon:UnitIsUnit(self.tradeTarget, v.winner) then
			local itemCounted = false
			for container=0, _G.NUM_BAG_SLOTS do
				for slot=1, GetContainerNumSlots(container) or 0 do
					if not (countedSlots[container] and countedSlots[container][slot]) then
						local link = GetContainerItemLink(container, slot)
						if link and addon:ItemIsItem(link, v.link) and addon:GetContainerItemTradeTimeRemaining(container, slot) > 0 then
							itemCounted = true
							count = count + 1
							countedSlots[container] = countedSlots[container] or {}
							countedSlots[container][slot] = true
							break
						end
					end
				end
				if itemCounted then
					break
				end
			end
		end
	end
	return count
end

function TradeUI:AddAwardedInBagsToTradeWindow()
	if addon.isMasterLooter then
		local tradeIndex = 1
		for _, v in ipairs(db.baggedItems) do
			if v.winner and addon:UnitIsUnit(self.tradeTarget, v.winner) then
				while (GetTradePlayerItemInfo(tradeIndex)) do
					tradeIndex = tradeIndex	+ 1
				end
				if tradeIndex > _G.MAX_TRADE_ITEMS - 1 then -- Have used all available slots(The last trade slot is "Will not be traded" slot).
					break
				end
				local itemAdded = false
				for container=0, _G.NUM_BAG_SLOTS do
					for slot=1, GetContainerNumSlots(container) or 0 do
						if self.trading then
							local texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(container, slot)
							if addon:ItemIsItem(link, v.link) and not locked and addon:GetContainerItemTradeTimeRemaining(container, slot) > 0 then
								ClearCursor()
								PickupContainerItem(container, slot)
								ClickTradeButton(tradeIndex)
								tradeIndex = tradeIndex + 1
								itemAdded = true
								break
							end
						end
					end
					if itemAdded then
						break
					end
				end
			end
		end
	end
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
         -- TODO Check for open trade window

         -- Return false to have the default OnClick handler take care of left clicks
         return false
      end,
   })
   f:SetWidth(f.st.frame:GetWidth()+20)
	f.rows = {}

   f.closeBtn = addon:CreateButton(_G.CLOSE, f.content)
   f.closeBtn:SetPoint("BOTTOMRIGHT", f.content, "BOTTOMRIGHT", -10, 10)
   f.closeBtn:SetScript("OnClick", function()
      f:Hide()
   end)

   return f
end
