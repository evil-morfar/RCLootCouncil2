--- Contains all LibDialog popups used by RCLootCouncil
-- @author: Potdisc
-- 14/07/2017

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local LibDialog = LibStub("LibDialog-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

-- Confirm usage (core)
LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_USAGE", {
   text = L["confirm_usage_text"],
   on_show = function(self)
      self:SetFrameStrata("FULLSCREEN")
   end,
   buttons = {
      {
         text = _G.YES,
         on_click = function()
            addon:DebugLog("Player confirmed usage, Personal Loot")
            addon:StartHandleLoot("personalloot")
         end,
      },
      {	text = _G.NO,
         on_click = function()
            addon:DebugLog("Player declined usage")
            addon:Print(L[" is not active in this raid."])
         end,
      },
   },
   hide_on_escape = true,
   show_while_dead = true,
})

-- Sync request (sync)
LibDialog:Register("RCLOOTCOUNCIL_SYNC_REQUEST", {
   text = "Incoming sync request",
   on_show = function(self, data)
      local sender,_, text = unpack(data)
      self.text:SetText(format("Receive %s data from %s", text, sender))
   end,
   buttons = {
      {  text = _G.YES,
         on_click = addon.Sync.OnSyncAccept
      },
      {  text = _G.NO,
         on_click = addon.Sync.OnSyncDeclined
      }
   },
	hide_on_escape = true,
	show_while_dead = true,
})

--------ML Popups ------------------
LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_ABORT", {
	text = L["Are you sure you want to abort?"],
	on_show = function(self)
		self:SetFrameStrata("FULLSCREEN")
	end,
	buttons = {
		{	text = _G.YES,
			on_click = function(self)
				addon:DebugLog("ML aborted session")
				RCLootCouncilML:EndSession()
				CloseLoot() -- close the lootlist
				addon:GetActiveModule("votingframe"):EndSession(true)
			end,
		},
		{	text = _G.NO,
		},
	},
	hide_on_escape = true,
	show_while_dead = true,
})
LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_AWARD", {
	text = "something_went_wrong",
	icon = "",
	on_show = _G.RCLootCouncilML.AwardPopupOnShow,
	buttons = {
		{	text = _G.YES,
			on_click = RCLootCouncilML.AwardPopupOnClickYes
		},
		{	text = _G.NO,
         on_click = RCLootCouncilML.AwardPopupOnClickNo
		},
	},
	hide_on_escape = true,
	show_while_dead = true,
})

LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_AWARD_LATER", {
   text = "something_went_wrong",
   icon = "",
   on_show = function(self, data)
      self.text:SetText(format(L["confirm_award_later_text"], data.link))
   end,
   buttons = {
      {  text = _G.YES,
         on_click = function(self, data)
            addon:GetActiveModule("masterlooter"):Award(data.session)
         end,
      },
      {  text = _G.NO,
      },
   },
   hide_on_escape = true,
   show_while_dead = true,
})


LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_REANNOUNCE_ALL_ITEMS", {
   text = "something_went_wrong",
   on_show = function(self, data)
      if data.isRoll then
         self.text:SetText(format(L["Are you sure you want to request rolls for all unawarded items from %s?"], data.text))
      else
         self.text:SetText(format(L["Are you sure you want to reannounce all unawarded items to %s?"], data.text))
      end
   end,
   buttons = {
      {  text = _G.YES,
         on_click = function(self, data)
            data.func()
         end,
      },
      {  text = _G.NO,
      },
   },
   hide_on_escape = true,
   show_while_dead = true,
})

----------- Common popups ---------------
LibDialog:Register("RCLOOTCOUNCIL_TRADE_ADD_ITEM", {
   text = "something_went_wrong",
   on_show = function(self, data)
      self.text:SetText(format(L["rclootcouncil_trade_add_item_confirm"], data.count, addon:GetUnitClassColoredName("npc")))
   end,
   buttons = {
      {  text = _G.YES,
         on_click = function(self, data)
            addon.TradeUI:AddAwardedInBagsToTradeWindow()
         end,
      },
      {  text = _G.NO,
      },
   },
   hide_on_escape = true,
   show_while_dead = true,
})

LibDialog:Register("RCLOOTCOUNCIL_KEEP_ITEM", {
   text = "something_went_wrong",
   on_show = function(self, link)
      self.text:SetText(format(L["Do you want to keep %s for yourself?"], link))
      local tex = select(5, GetItemInfoInstant(link))
      self.icon:SetTexture(tex)
      local icon = addon.UI:New("Icon", self, tex)
      icon:SetSize(self.icon:GetSize())
      icon:SetPoint("TOPLEFT", self.icon, "TOPLEFT")
      icon:SetScript("OnEnter", function() addon:CreateHypertip(link) end)
      icon:Show()
      self.icon2 = icon
   end,
   on_cancel = function(self, link)
      self.buttons[2]:Click(self, link)
      self.icon2:Hide()
   end,
   buttons = {
      {  text = _G.YES,
         on_click = function(self, link)
            addon:SendCommand("group", "rejected_trade", link)
            self.icon2:Hide()
         end,
      },
      {  text = _G.NO,
         on_click = function(self, link)
            addon:SendCommand("group", "tradable", link)
            self.icon2:Hide()
         end,
      },
   },
   icon = "",
   hide_on_escape = true,
   show_while_dead = true,
   no_close_button = true,
})
