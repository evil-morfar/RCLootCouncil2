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
      {	text = _G.YES,
         on_click = function(self, switchToMasterLoot)
            addon:DebugLog("Player confirmed usage")
            addon:StartHandleLoot(switchToMasterLoot)
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
	on_show = RCLootCouncilML.AwardPopupOnShow,
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
