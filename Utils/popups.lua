--- Contains all LibDialog popups used by RCLootCouncil
-- @author: Potdisc
-- 14/07/2017
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
      {	text = L["Yes"],
         on_click = function()
            addon:DebugLog("Player confirmed usage")
            -- The player might have passed on ML before accepting :O
            if not addon.isMasterLooter and addon.masterLooter and addon.masterLooter ~= "" then return end
            local lootMethod = GetLootMethod()
            if lootMethod ~= "master" then
               addon:Print(L["Changing LootMethod to Master Looting"])
               SetLootMethod("master", addon.Ambiguate(addon.playerName)) -- activate ML
            end
            local db = addon:Getdb()
            if db.autoAward and GetLootThreshold() ~= 2 and GetLootThreshold() > db.autoAwardLowerThreshold  then
               addon:Print(L["Changing loot threshold to enable Auto Awarding"])
               SetLootThreshold(db.autoAwardLowerThreshold >= 2 and db.autoAwardLowerThreshold or 2)
            end
            addon:Print(L["Now handles looting"])
            addon.isMasterLooter = true
            addon.masterLooter = addon.playerName
            if #db.council == 0 then -- if there's no council
               addon:Print(L["You haven't set a council! You can edit your council by typing '/rc council'"])
            end
            addon:CallModule("masterlooter")
            addon:GetActiveModule("masterlooter"):NewML(addon.masterLooter)
         end,
      },
      {	text = L["No"],
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
      {  text = L["Yes"],
         on_click = addon.Sync.OnSyncAccept
      },
      {  text = L["No"],
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
		{	text = L["Yes"],
			on_click = function(self)
				addon:DebugLog("ML aborted session")
				RCLootCouncilML:EndSession()
				CloseLoot() -- close the lootlist
				addon:GetActiveModule("votingframe"):EndSession(true)
			end,
		},
		{	text = L["No"],
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
		{	text = L["Yes"],
			on_click = RCLootCouncilML.AwardPopupOnClickYes
		},
		{	text = L["No"],
         on_click = RCLootCouncilML.AwardPopupOnClickNo
		},
	},
	hide_on_escape = true,
	show_while_dead = true,
})

-- Note button (lootframe)
LibDialog:Register("RCLOOTCOUNCIL_LOOTFRAME_NOTE", {
	text = L["Enter your note:"],
	on_show = function(self)
		self:SetFrameStrata("FULLSCREEN")
	end,
	editboxes = {
		{
			on_enter_pressed = function(self, entry)
				entry.item.note = self:GetText() -- new
				LibDialog:Dismiss("RCLOOTCOUNCIL_LOOTFRAME_NOTE")
			end,
			on_escape_pressed = function(self)
				LibDialog:Dismiss("RCLOOTCOUNCIL_LOOTFRAME_NOTE")
			end,
			auto_focus = true,
		}
	},
})
