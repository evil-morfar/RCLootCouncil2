--- TradeUI.lua	Displays items to be traded to the player
-- DefaultModule
-- @author Potdisc
-- Create Date : 28/5/2018 16:48:38

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local TradeUI = addon:NewModule("RCTradeUI", "AceComm-3.0")
addon.TradeUI = TradeUI -- Shorthand for easier access
local ST = LibStub("ScrollingTable")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local ROW_HEIGHT = 30

-- lua
local select, GetItemInfoInstant, ipairs, IsModifiedClick, HandleModifiedItemClick, unpack, tinsert
    = select, GetItemInfoInstant, ipairs, IsModifiedClick, HandleModifiedItemClick, unpack, tinsert

function TradeUI:OnInitialize()
   self.scrollCols = {
      { name = "", width = ROW_HEIGHT,},   -- Item icon
      { name = "", width = 120,},          -- Item Link
      { name = "", width = ROW_HEIGHT - 5},-- Arrow
      { name = "", width = 100,},          -- Recipient
   }
   self:RegisterComm("RCLootCouncil")

end

function TradeUI:OnEnable()
   addon:DebugLog("TradeUI enabled")
   self:Show()
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
   st:RegisterEvents({
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
