--- Contains all code required for syncronizing stuff
-- @author: Potdisc
-- 14/07/2017

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local LibDialog = LibStub("LibDialog-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local AG = LibStub("AceGUI-3.0")
local sync = {}
addon.Sync = sync

local sync_table = {}
local last_sync_time = 0

-- Handlers for incoming sync data - determines which sync types we can handle
sync.syncHandlers = {
   settings = {
      text = _G.SETTINGS,
      receive = function(data) wipe(addon.db.profile); for k,v in pairs(data) do addon.db.profile[k] = v end; addon:UpdateDB(); addon:ActivateSkin(addon.db.profile.currentSkin) end,
      send = function() return addon.db.profile end,
   },
   history  = {
      text = L["Loot History"],
      receive = function(data) addon:GetActiveModule("history"):ImportHistory(addon:Serialize(data)) end, -- Import expects a serialized data table
      send = function() return addon:GetHistoryDB() end,
   },
}

-- Copy table with all function, userdata, thread inside removed
local function CopyTableSerializable(settings)
   local copy = {};
   for k, v in pairs(settings) do
      if ( type(v) == "table" ) then
         copy[k] = CopyTableSerializable(v);
      elseif type(v) ~= "function" and type(v) ~= "userdata" and type(v) ~= "thread" then
         copy[k] = v;
      end
   end
   return copy;
end

-- Support to sync module settings
-- Run in sync:Spawn, because we need to wait for the initialization of other modules.
-- Module must run registerDefaults after sync is done.
local function AddModuleSyncSupport()
   if addon.db.children then
      for name, db in pairs(addon.db.children) do
         sync.syncHandlers[name] = {
            text = name,
            receive = function(data) wipe(db.profile); for k,v in pairs(data) do db.profile[k] = v end; addon:SendMessage("RCSyncComplete", name) end,
            send = function() return CopyTableSerializable(db.profile) end,
         }
      end
   end
end

-- Reasons for declines
sync.declineReasons = { -- Gets delivered "player" and "type"
   unsupported     = L["'player' can't receive 'type'"],
   user_declined   = L["'player' declined your sync request"],
   not_open        = L["'player' hasn't opened the sync window"],
}
local function SendSyncData(target, type)
   addon:Debug("SendSyncData",target,type)
   local toSend = addon:Serialize("sync", {addon.playerName, type, sync_table[target][type]})
   if addon:UnitIsUnit(target,"player") then -- If target == "player"
			addon:SendCommMessage("RCLootCouncil", toSend, "WHISPER", addon.playerName, "BULK", sync.OnDataPartSent, sync)
	else
		-- We cannot send "WHISPER" to a crossrealm player
		if target:find("-") then
			if target:find(addon.realmName) then -- Our own realm, just send it
				addon:SendCommMessage("RCLootCouncil", toSend, "WHISPER", target, "BULK", sync.OnDataPartSent, sync)
			else -- Get creative
				-- Remake command to be "xrealm" and put target and command in the table
				-- See "RCLootCouncil:HandleXRealmComms()" for more info
				toSend = addon:Serialize("xrealm", {target, "sync", addon.playerName, type, sync_table[target][type]})
				if GetNumGroupMembers() > 0 then -- We're in a group
					addon:SendCommMessage("RCLootCouncil", toSend, "RAID", nil, "BULK", sync.OnDataPartSent, sync)
				else -- We're not, probably a guild verTest
					addon:SendCommMessage("RCLootCouncil", toSend, "GUILD", nil, "BULK", sync.OnDataPartSent, sync)
				end
			end

		else -- Should also be our own realm
			addon:SendCommMessage("RCLootCouncil", toSend, "WHISPER", target, "BULK", sync.OnDataPartSent, sync)
		end
	end
   addon:Debug("SendSyncData", "SENT")
end

-- We want to sync with another player
function sync:SendSyncRequest(player, type, data)
   addon:DebugLog("SendSyncRequest", player, type)
   if time() - last_sync_time < 10 then -- Limit to 1 sync per 10 sec
      return addon:Print(L["Please wait before trying to sync again."])
   end
   last_sync_time = time()
	addon:SendCommand(player, "syncRequest", addon.playerName, type)
   sync_table[player] = { -- Store the data
      [type] = data
   }
   -- Lets see how much data we're trying to send by approximating it using the Serializer
   if addon.debug then addon:Debug(type, "Data size:", #addon:Serialize(data)/1000, "Kb") end
end

-- Another player has agreed to receive our data
function sync:SyncAckReceived(player, type)
   addon:DebugLog("SyncAckReceived", player, type)
   local data = sync_table[player] and sync_table[player][type]
   if not data then
      addon:Print(L["Something went wrong during syncing, please try again."])
      return addon:Debug("Data wasn't queued for syncing!!!")
   end
   -- We're ready to send
   SendSyncData(player, type)
   -- clear the table:
   data = nil
   addon:Print(format(L["Sending 'type' to 'player'..."], type, player))
end

function sync:SyncNackReceived(player, type, msg)
   addon:DebugLog("SyncNackReceived", player, type, msg)
   -- Delete them from table
   sync_table[player] = nil
   addon:Print(format(self.declineReasons[msg], player, type))
end

-- We've received a request to sync with another player
function sync:SyncRequestReceived(sender, type)
   addon:DebugLog("SyncRequestReceived", sender, type)
   if not self.frame or not self.frame:IsVisible() then
      return self:DeclineSync(sender, type, "not_open")
   end
	if self.syncHandlers[type] then
		LibDialog:Spawn("RCLOOTCOUNCIL_SYNC_REQUEST", {sender, type, self.syncHandlers[type].text})
	else
      self:DeclineSync(sender, type, "unsupported")
	end
end

-- LibDialog OnAccept
function sync.OnSyncAccept(_, data)
   local sender, type = unpack(data)
   addon:Debug("OnSyncAccept", sender, type)
   addon:SendCommand(sender, "syncAck", addon.playerName, type)
   sync.frame.statusBar:Show()
   sync.frame.statusBar.text:Show()
   sync.frame.statusBar.text:SetText(_G.RETRIEVING_DATA)
   --sync.frame.statusBar:Hide()
end
-- LibDialog OnDecline
function sync.OnSyncDeclined(_, data)
   local sender, type = unpack(data)
   sync:DeclineSync(sender, type, "user_declined")
end

function sync:DeclineSync (sender, type, msg)
   addon:Debug("OnSyncDeclined", sender, type, msg)
   addon:SendCommand(sender, "syncNack", addon.playerName, type, msg)
end

-- We're receiving data from another player
-- data to send: addon.db.profile
-- data to send: self:EscapeItemLink(addon:Serialize(lootDB))
function sync:SyncDataReceived(sender, type, data)
   addon:DebugLog("SyncDataReceived", sender, type)
   self.frame.statusBar.text:SetText(L["Data Received"])
   if self.syncHandlers[type] then
      self.syncHandlers[type].receive(data)
   else -- Should never happen
      return addon:Debug("Unsupported SyncDataReceived", type, "from", sender)
   end
   addon:Print(format(L["Successfully received 'type' from 'player'"], type, sender))
end

local function addNameToList(list, name, class)
   local c = addon:GetClassColor(class)
   list[name] = "|cff"..addon:RGBToHex(c.r,c.g,c.b) .. name .."|r"
end

-- Builds a list of targets we can sync to.
-- Used in the options menu for an AceGUI dropdown.
function sync:GetSyncTargetOptions()
   local name, isOnline, class, _
   local ret = {}
   -- target
   if UnitIsFriend("player", "target") and UnitIsPlayer("target") then
      addNameToList(ret, addon:UnitName("target"), select(2, UnitClass("target")))
   end
   -- group
   for i = 1, GetNumGroupMembers() do
	   name, _, _, _, _, class, _, isOnline = GetRaidRosterInfo(i)
      if isOnline then addNameToList(ret, addon:UnitName(name), class) end
   end
   -- friends
   for i = 1, GetNumFriends() do
      name, _, class, _, isOnline = GetFriendInfo(i)
      if isOnline then addNameToList(ret, name, class) end
   end
   -- guildmembers
   for i = 1, GetNumGuildMembers() do
      name, _, _, _, _, _, _, _, isOnline,_,class = GetGuildRosterInfo(i)
      if isOnline then addNameToList(ret, name, class) end
   end
   -- Remove ourselves
   if not addon.debug then ret[addon.playerName] = nil end
   -- Check if it's empty
   local isEmpty = true
   for k in pairs(ret) do isEmpty = false; break end
   ret[1] = isEmpty and "--"..L["No recipients available"].."--" or nil
   table.sort(ret, function(a,b) return a > b end)
   return ret
end

function sync:OnDataPartSent(num, total)
   if not self.frame then return end
   self.frame.statusBar:Show()
   self.frame.statusBar:SetValue(num/total*100)
   self.frame.statusBar.text:SetText(addon.round(num/total*100) .."% - ".. num/1000 .."kB / ".. total/ 1000 .. "kB")
   if num == total then
      addon:Print(L["Done syncing"])
      addon:Debug("Done syncing")
   end
end

-------------------------------------------------
-- Graphics
-------------------------------------------------
function sync:Spawn()
   AddModuleSyncSupport() -- Add modules into the sync list

   if self.frame then return self.frame:Open() end
   self.syncType = "settings"
   local f = addon:CreateFrame("DefaultRCLootCouncilSyncFrame", "sync", L["RCLootCouncil - Synchronizer"], nil, 140)
   f:SetWidth(350)
   local sel = AG:Create("Dropdown")
   sel:SetWidth(f.content:GetWidth()*0.4 - 20)
   sel:SetPoint("TOPLEFT", f.content, "TOPLEFT", 10, -50)
   local syncSelections = {}
   for k,v in pairs(self.syncHandlers) do
      syncSelections[k] = v.text
   end
   sel:SetList(syncSelections)
   sel:SetValue(self.syncType)
   sel:SetText(syncSelections[self.syncType])
   sel:SetCallback("OnValueChanged", function(_,_, key)
      self.syncType = key
   end)
   sel:SetParent(f)
   sel.frame:Show()
   f.syncSelector = sel

   local txt = f.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	txt:SetPoint("BOTTOMLEFT", sel.frame, "TOPLEFT", 0, 5)
	txt:SetTextColor(1, 1, 1) -- Turqouise
	txt:SetText(L["Sync"]..":")
	f.typeText = txt

   sel = AG:Create("Dropdown")
   sel:SetWidth(f.content:GetWidth()*0.6 - 20)
   sel:SetPoint("LEFT", f.syncSelector.frame, "RIGHT", 20, 0)
   sel:SetList(self:GetSyncTargetOptions())
   sel:SetCallback("OnValueChanged", function(_,_, key)
      self.syncTarget = key
   end)
   sel:SetParent(f)
   sel.frame:Show()
   local old_click = sel.button_cover:GetScript("OnClick")
   sel.button_cover:SetScript("OnClick", function(this) GuildRoster(); sel:SetList(self:GetSyncTargetOptions()); old_click(this) end) -- User can click button_cover or button to open the menu
   local old_click = sel.button:GetScript("OnClick")
   sel.button:SetScript("OnClick", function(this) GuildRoster(); sel:SetList(self:GetSyncTargetOptions()); old_click(this) end) -- Need to call GuildRoster() to refresh online guild members.
   f.syncTargetSelector = sel

   txt = f.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	txt:SetPoint("BOTTOMLEFT", sel.frame, "TOPLEFT", 0, 5)
	txt:SetTextColor(1, 1, 1) -- Turqouise
	txt:SetText(L["To target"]..":")
	f.targetText = txt

   f.syncButton = addon:CreateButton("Sync", f.content)
   f.syncButton:SetPoint("BOTTOMRIGHT", f, "CENTER", -10, -f:GetHeight()/2+10)
   f.syncButton:SetScript("OnClick", function()
      if not self.syncTarget then return addon:Print(L["You must select a target"]) end
      self:SendSyncRequest(self.syncTarget, self.syncType, self.syncHandlers[self.syncType].send())
   end)
   f.exitButton = addon:CreateButton(_G.CLOSE, f.content)
   f.exitButton:SetPoint("LEFT", f.syncButton, "RIGHT", 20, 0)
   f.exitButton:SetScript("OnClick", function()
      self.frame:Hide()
   end)

   f.statusBar = CreateFrame("StatusBar", nil, f.content, "TextStatusBar")
	f.statusBar:SetSize(f.content:GetWidth() - 20, 15)
	f.statusBar:SetPoint("TOPLEFT", f.syncSelector.frame, "BOTTOMLEFT", 0, -10)
	f.statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	f.statusBar:SetStatusBarColor(0.1, 0, 0.6, 0.8) -- blue
	f.statusBar:SetMinMaxValues(0, 100)
   f.statusBar:Hide()

   f.statusBar.text = f.statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.statusBar.text:SetPoint("CENTER", f.statusBar)
	f.statusBar.text:SetTextColor(1,1,1)
	f.statusBar.text:SetText("")

   f.helpButton = CreateFrame("Button", nil, f.content)
   f.helpButton:SetNormalTexture("Interface/GossipFrame/ActiveQuestIcon")
   f.helpButton:SetSize(12,12)
   f.helpButton:SetPoint("TOPRIGHT", f.content, "TOPRIGHT", -10, -10)
   f.helpButton:SetScript("OnLeave", function() addon:HideTooltip() end)
   f.helpButton:SetScript("OnEnter", function()
      addon:CreateTooltip(L["How to sync"], " ", L["sync_detailed_description"])
   end)

   f.Open = function() -- We need these to reset on each opening
      f.statusBar:Hide()
      f.statusBar.text:Hide()
      f:Show()
   end

   self.frame = f
   self.frame:Show()
end
