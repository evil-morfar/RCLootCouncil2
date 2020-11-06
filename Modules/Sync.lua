--- Contains all code required for syncronizing stuff
-- @author: Potdisc
-- 14/07/2017
--[[ Comms:
   SYNC:
      syncR          P - Sync request received.
      syncNack       P - Sync nack recevied.
      sync           T - Actual sync data.
      syncAck        T - Sync ack received.
]]
---@type RCLootCouncil
local _, addon = ...
---@class Sync
local sync = addon:NewModule("Sync", "AceSerializer-3.0")
local LibDialog = LibStub("LibDialog-1.0")
local LD = LibStub("LibDeflate")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local AG = LibStub("AceGUI-3.0")
local PREFIX = addon.PREFIXES.SYNC
---@type Services.Comms
local Comms = addon.Require "Services.Comms"
---@type Data.Player
local Player = addon.Require "Data.Player"
addon.Sync = sync

local sync_table = {}
local last_sync_time = 0
local subscriptions = {}

function sync:OnInitialize()
    self.Send = Comms:GetSender(PREFIX)
    -- General "Sender" object for sync
    self.SendBulk = function(self, target, command, ...)
        Comms:Send {
            prefix = PREFIX,
            target = target,
            command = command,
            data = {...},
            prio = "BULK",
            callback = self.OnDataPartSent,
            callbackarg = self
        }
    end
    -- Register Permanent Comms
    Comms:BulkSubscribe(
        PREFIX,
        {
            syncR = function(data, sender)
                self:SyncRequestReceived(Player:Get(sender), unpack(data))
            end,
            syncNack = function(data, sender)
                self:SyncNackReceived(Player:Get(sender), unpack(data))
            end
        }
    )
end

function sync:OnEnable()
    -- Temporary comms only available with the window open
    subscriptions =
        Comms:BulkSubscribe(
        PREFIX,
        {
            sync = function(data, sender)
                self:SyncDataReceived(Player:Get(sender), unpack(data))
            end,
            syncAck = function(data, sender)
                self:SyncAckReceived(Player:Get(sender), unpack(data))
            end
        }
    )
    self:Spawn()
end

function sync:OnDisable()
    if self.frame then
        self.frame:Hide()
    end
    for _, sub in ipairs(subscriptions) do
        sub:unsubscribe()
    end
end

-- Handlers for incoming sync data - determines which sync types we can handle
sync.syncHandlers = {
    settings = {
        text = _G.SETTINGS,
        receive = function(data)
            for k, v in pairs(data) do
                addon.db.profile[k] = v
            end
            addon:UpdateDB()
            addon:ActivateSkin(addon.db.profile.currentSkin)
        end,
        send = function()
            return addon.db.profile
        end
    },
    history = {
        text = L["Loot History"],
        receive = function(data)
            addon:GetActiveModule("history"):ImportHistory(sync:Serialize(data))
        end, -- Import expects a serialized data table
        send = function()
            return addon:GetHistoryDB()
        end
    }
}

-- Reasons for declines
sync.declineReasons = {
    -- Gets delivered "player" and "type"
    unsupported = L["'player' can't receive 'type'"],
    user_declined = L["'player' declined your sync request"],
    not_open = L["'player' hasn't opened the sync window"]
}
local function SendSyncData(target, type)
    addon.Log:D("SendSyncData", target, type)
    sync:SendBulk(target, "sync", type, sync_table[target:GetName()][type])
    addon.Log:D("SendSyncData", "SENT")
end

-- We want to sync with another player
function sync:SendSyncRequest(target, type, data)
    addon.Log:D("SendSyncRequest", target, type)
    if time() - last_sync_time < 5 then -- Limit to 1 sync per 5 sec
        return addon:Print(L["Please wait before trying to sync again."])
    end
    last_sync_time = time()
    self:Send(target, "syncR", type)

    -- Lets see how much data we're trying to send by approximating it using the Serializer
    local ser = self:Serialize(data)
    local comp = LD:CompressDeflate(ser)
    local enc = LD:EncodeForWoWAddonChannel(comp, {level = 9})
    addon.Log:D(type, "Data size:", #enc / 1000, "Kb")

    sync_table[target:GetName()] = {
        -- Store the data
        [type] = data,
        size = #enc
    }
end

-- Another player has agreed to receive our data
function sync:SyncAckReceived(sender, type)
    addon.Log:D("SyncAckReceived", sender, type)
    local data = sync_table[sender:GetName()] and sync_table[sender:GetName()][type]
    if not data then
        addon:Print(L["Something went wrong during syncing, please try again."])
        return addon.Log:D("Data wasn't queued for syncing!!!")
    end
    -- We're ready to send
    SendSyncData(sender, type)
    addon:Print(format(L["Sending 'type' to 'player'..."], type, sender:GetName()))
end

function sync:SyncNackReceived(sender, type, msg)
    addon.Log:D("SyncNackReceived", sender, type, msg)
    -- Delete them from table
    sync_table[sender:GetName()] = nil
    addon:Print(format(self.declineReasons[msg], sender:GetName(), type))
end

-- We've received a request to sync with another player
function sync:SyncRequestReceived(sender, type)
    addon.Log:D("SyncRequestReceived", sender, type)
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
    addon.Log:D("OnSyncAccept", sender, type)
    sync:Send(sender, "syncAck", type)
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

function sync:DeclineSync(sender, type, msg)
    addon.Log:D("OnSyncDeclined", sender, type, msg)
    self:Send(sender, "syncNack", type, msg)
end

-- We're receiving data from another player
-- data to send: addon.db.profile
-- data to send: self:EscapeItemLink(addon:Serialize(lootDB))
function sync:SyncDataReceived(sender, type, data)
    addon.Log:D("SyncDataReceived", sender, type)
    self.frame.statusBar.text:SetText(L["Data Received"])
    if self.syncHandlers[type] then
        self.syncHandlers[type].receive(data)
    else -- Should never happen
        return addon.Log:D("Unsupported SyncDataReceived", type, "from", sender)
    end
    addon:Print(format(L["Successfully received 'type' from 'player'"], type, sender:GetName()))
end

local function addNameToList(list, name, class)
    addon.Log:D("Sync:addNameToList()", name, class)
    local c = addon:GetClassColor(class)
    list[name] = "|cff" .. addon.Utils:RGBToHex(c.r, c.g, c.b) .. tostring(name) .. "|r"
end

local function titleCaseName(name)
    if not name then
        return ""
    end -- Just in case
    local realm
    if (strfind(name, "-", nil, true)) then
        name, realm = strsplit("-", name, 2)
    end
    name = name:lower():gsub("^%l", string.upper)
    return name .. "-" .. (realm or addon.realmName)
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
        if isOnline then
            addNameToList(ret, addon:UnitName(name), class)
        end
    end
    -- friends
    for i = 1, C_FriendList.GetNumOnlineFriends() do
        name, _, class, _, isOnline = C_FriendList.GetFriendInfoByIndex(i)
        if isOnline then
            addNameToList(ret, titleCaseName(name), class)
        end
    end
    -- guildmembers
    for i = 1, GetNumGuildMembers() do
        name, _, _, _, _, _, _, _, isOnline, _, class = GetGuildRosterInfo(i)
        if isOnline then
            addNameToList(ret, titleCaseName(name), class)
        end
    end
    -- Remove ourselves
    if not addon.debug then
        ret[addon.playerName] = nil
    end
    -- Check if it's empty
    local isEmpty = true
    for k in pairs(ret) do
        isEmpty = false
        break
    end --luacheck: ignore
    ret[1] = isEmpty and "--" .. L["No recipients available"] .. "--" or nil
    table.sort(
        ret,
        function(a, b)
            return a > b
        end
    )
    return ret
end

function sync:OnDataPartSent(num, total)
    if not self.frame then
        return
    end
    self.frame.statusBar:Show()
    self.frame.statusBar:SetValue(num / total * 100)
    self.frame.statusBar.text:SetText(
        addon.round(num / total * 100) .. "% - " .. num / 1000 .. "kB / " .. total / 1000 .. "kB"
    )
    self.frame.statusBar.text:Show()
    if num == total then
        addon:Print(L["Done syncing"])
        addon.Log:D("Done syncing")
    end
end

-------------------------------------------------
-- Graphics
-------------------------------------------------
function sync:Spawn()
    if self.frame then
        return self.frame:Open()
    end
    self.syncType = "settings"
    local f =
        addon.UI:NewNamed(
        "Frame",
        UIParent,
        "DefaultRCLootCouncilSyncFrame",
        L["RCLootCouncil - Synchronizer"],
        nil,
        140
    )
    f:SetWidth(350)
    local sel = AG:Create("Dropdown")
    sel:SetWidth(f.content:GetWidth() * 0.4 - 20)
    sel:SetPoint("TOPLEFT", f.content, "TOPLEFT", 10, -50)
    local syncSelections = {}
    for k, v in pairs(self.syncHandlers) do
        syncSelections[k] = v.text
    end
    sel:SetList(syncSelections)
    sel:SetValue(self.syncType)
    sel:SetText(syncSelections[self.syncType])
    sel:SetCallback(
        "OnValueChanged",
        function(_, _, key)
            self.syncType = key
        end
    )
    sel:SetParent(f)
    sel.frame:Show()
    f.syncSelector = sel

    local txt = f.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    txt:SetPoint("BOTTOMLEFT", sel.frame, "TOPLEFT", 0, 5)
    txt:SetTextColor(1, 1, 1) -- Turqouise
    txt:SetText(L["Sync"] .. ":")
    f.typeText = txt

    sel = AG:Create("Dropdown")
    sel:SetWidth(f.content:GetWidth() * 0.6 - 20)
    sel:SetPoint("LEFT", f.syncSelector.frame, "RIGHT", 20, 0)
    sel:SetList(self:GetSyncTargetOptions())
    sel:SetCallback(
        "OnValueChanged",
        function(_, _, key)
            self.syncTarget = key
        end
    )
    sel:SetParent(f)
    sel.frame:Show()
    local old_click = sel.button:GetScript("OnClick")
    sel.button:SetScript(
        "OnClick",
        function(this)
            sel:SetList(self:GetSyncTargetOptions())
            old_click(this)
        end
    )
    f.syncTargetSelector = sel

    txt = f.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    txt:SetPoint("BOTTOMLEFT", sel.frame, "TOPLEFT", 0, 5)
    txt:SetTextColor(1, 1, 1) -- Turqouise
    txt:SetText(L["To target"] .. ":")
    f.targetText = txt

    f.syncButton = addon:CreateButton("Sync", f.content)
    f.syncButton:SetPoint("BOTTOMRIGHT", f, "CENTER", -10, -f:GetHeight() / 2 + 10)
    f.syncButton:SetScript(
        "OnClick",
        function()
            if not self.syncTarget then
                return addon:Print(L["You must select a target"])
            end
            self:SendSyncRequest(Player:Get(self.syncTarget), self.syncType, self.syncHandlers[self.syncType].send())
        end
    )
    f.exitButton = addon:CreateButton(_G.CLOSE, f.content)
    f.exitButton:SetPoint("LEFT", f.syncButton, "RIGHT", 20, 0)
    f.exitButton:SetScript(
        "OnClick",
        function()
            self:Disable()
        end
    )

    f.statusBar = CreateFrame("StatusBar", nil, f.content, "TextStatusBar")
    f.statusBar:SetSize(f.content:GetWidth() - 20, 15)
    f.statusBar:SetPoint("TOPLEFT", f.syncSelector.frame, "BOTTOMLEFT", 0, -10)
    f.statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    f.statusBar:SetStatusBarColor(0.1, 0, 0.6, 0.8) -- blue
    f.statusBar:SetMinMaxValues(0, 100)
    f.statusBar:Hide()

    f.statusBar.text = f.statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.statusBar.text:SetPoint("CENTER", f.statusBar)
    f.statusBar.text:SetTextColor(1, 1, 1)
    f.statusBar.text:SetText("")

    f.helpButton = CreateFrame("Button", nil, f.content)
    f.helpButton:SetNormalTexture("Interface/GossipFrame/ActiveQuestIcon")
    f.helpButton:SetSize(12, 12)
    f.helpButton:SetPoint("TOPRIGHT", f.content, "TOPRIGHT", -10, -10)
    f.helpButton:SetScript(
        "OnLeave",
        function()
            addon:HideTooltip()
        end
    )
    f.helpButton:SetScript(
        "OnEnter",
        function()
            addon:CreateTooltip(L["How to sync"], " ", L["sync_detailed_description"])
        end
    )

    f.Open = function()
        -- We need these to reset on each opening
        f.statusBar:Hide()
        f.statusBar.text:Hide()
        f:Show()
    end

    self.frame = f
    self.frame:Show()
end
