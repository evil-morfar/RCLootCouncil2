--- versionCheck.lua Adds a Version Checker to check versions of either people in current raidgroup or guild.
-- DefaultModule.
-- @author Potdisc
-- Create Date : 12/15/2014 8:55:10 PM
--[[ Comms:
	VERSION:
		v		P - Version Check.
		r 		P - Version Check Reply.
		fr 	P - Full version checkc request.
		f 		T - Full version check reply. Only when open.
]]
--- @type RCLootCouncil
local _, addon = ...
local RCVersionCheck = addon:NewModule("VersionCheck", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0", "AceBucket-3.0")
local ST = LibStub("ScrollingTable")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

--- @type Services.Comms
local Comms = addon.Require "Services.Comms"
--- @type Data.Player
local Player = addon.Require "Data.Player"
--- @type Utils.TempTable
local TT = addon.Require "Utils.TempTable"

local GuildRankSort
local guildRanks = {}
local highestVersion = "0.0.0"
local listOfNames = {}
local colors = {
    green = CreateColor(0,1,0,1),
    yellow = CreateColor(1,1,0,1),
    red = CreateColor(1,0,0,1),
    grey = CreateColor(0.75,0.75,0.75,1)
}

function RCVersionCheck:OnInitialize()
    self.verCheckDisplayed = false -- Have we shown a "out-of-date"?
    self.moduleVerCheckDisplayed = {} -- Have we shown a "out-of-date" for a module? The key of the table is the baseName of the module.
    -- Initialize scrollCols on self so others can change it
    self.scrollCols = {
        {name = "", width = 20, sortnext = 2},
        {name = _G.NAME, width = 150, defaultsort = ST.SORT_ASC},
        {name = _G.RANK, width = 90, comparesort = GuildRankSort},
        {
            name = L["Version"],
            width = 140,
            align = "RIGHT",
            comparesort = self.VersionSort,
            sort = ST.SORT_DSC,
            sortnext = 2
        }
    }

    if IsInGuild() then
        addon.guildRank = select(2, GetGuildInfo("player"))
        addon:ScheduleTimer("SendGuildVerTest", 2) -- send out a version check after a delay
	end
	self:InitCoreVersionComms()
    self.subscriptions = {}
end

function RCVersionCheck:OnEnable()
    self.frame = self:GetFrame()
    self:Show()
    guildRanks = addon:GetGuildRanks()
    -- Unsubscribable Comms
    tinsert(
        self.subscriptions,
        Comms:Subscribe(
            addon.PREFIXES.VERSION,
            "f",
            function(data, sender)
                -- Check for recipient (x-realm support)
                if data[6] then
                    local senderPlayer = Player:Get(data[6])
                    if senderPlayer ~= addon.player then return end
                end
                self:AddEntry(sender, data[1], data[2], data[3], data[4], data[5])
            end
        )
    )
    self:RegisterBucketMessage("RCVersionCheckUpdate", 0.5, "UpdateTotals")
end

function RCVersionCheck:OnDisable()
    self:Hide()
    self.frame.rows = {}
    wipe(listOfNames)
    for _, sub in ipairs(self.subscriptions) do
        sub:unsubscribe()
	end
    wipe(self.subscriptions)
    self:UnregisterAllBuckets()
end

function RCVersionCheck:Show()
    self:AddEntry(
        addon.player:GetName(),
        addon.playerClass,
        addon.guildRank,
        addon.version,
        addon.tVersion,
        addon:GetInstalledModulesFormattedData()
    ) -- add ourself
    self.frame:Show()
    self.frame.st:SetData(self.frame.rows)
    self:UpdateTotals()
end

function RCVersionCheck:Hide()
    self.frame:Hide()
end

function RCVersionCheck:Query(target)
    addon.Log("VC", "Player asked for verTest", target)
    if target == "guild" then
        addon.Utils:GuildRoster()
        for i = 1, GetNumGuildMembers() do
            local name, rank, _, _, _, _, _, _, online, _, class = GetGuildRosterInfo(i)
            if online then
                self:AddEntry(name, class, rank)
            end
        end
    elseif target == "group" then
        for i = 1, GetNumGroupMembers() do
            local name, _, _, _, _, class, _, online = GetRaidRosterInfo(i)
            if online then
                self:AddEntry(name, class, _G.UNKNOWN)
            end
        end
    end
    Comms:Send {
        prefix = addon.PREFIXES.VERSION,
        target = target,
        command = "fr"
    }
    self:AddEntry(
        addon.player:GetName(),
        addon.playerClass,
        addon.guildRank,
        addon.version,
        addon.tVersion,
        addon:GetInstalledModulesFormattedData()
    ) -- add ourself
    self:ScheduleTimer("QueryTimer", 5)
end

function RCVersionCheck:QueryTimer()
    for k in pairs(self.frame.rows) do
        local cell = self.frame.st:GetCell(k, 4)
        if cell.value == L["Waiting for response"] then
            cell.value = L["Not installed"]
        end
    end
    self:Update()
end

local function logversion(name, version, tversion, status)
    addon.db.global.verTestCandidates[name] = {version, tversion, status}
end
-- Static
function RCVersionCheck:LogVersion(name, version, tversion)
    if not name then
        return addon.Log:D("LogVersion", "No name", name, version, tversion)
    end
    if addon.db.global.verTestCandidates[name] then -- Updated
        logversion(name, version, tversion, time())
    else -- New
        logversion(name, version, tversion, time(), "new")
    end
end

function RCVersionCheck:PrintOutDatedClients()
    local outdated = {}
    local isgrouped = IsInGroup()
    local i = 0
    local tChk = time() - 86400 -- Must be newer than 1 day
    for name, data in pairs(addon.db.global.verTestCandidates) do
        if isgrouped and addon.candidatesInGroup[name] or not isgrouped then -- Only check people in our group if we're grouped.
            if not data[2] and addon:VersionCompare(data[1], addon.version) and data[3] > tChk then -- No tversion, and older than ours, and fresh
                i = i + 1
                outdated[i] = addon:GetUnitClassColoredName(name) .. ": " .. data[1]
            end
        end
    end
    if i > 0 then
        addon:Print(L["Found the following outdated versions"] .. ":")
        for j, v in ipairs(outdated) do
            addon:Print(j, v)
        end
    else
        addon:Print(L["Everybody is up to date."])
    end
end

function RCVersionCheck:AddEntry(name, class, guildRank, version, tVersion, modules)
    -- We need to be careful with naming conventions just as in RCLootCouncil:UnitName()
    --name = name:lower():gsub("^%l", string.upper)
    name = addon:UnitName(name)
    if not tVersion and addon:VersionCompare(highestVersion, version) then
        highestVersion = version
    end
    local vVal = version
    if tVersion then
        vVal = tostring(version) .. "-" .. tVersion
    end
    for _, v in ipairs(self.frame.rows) do
        if addon:UnitIsUnit(v.name, name) then -- they're already added, so update them
            v.cols = {
                {value = "", DoCellUpdate = addon.SetCellClassIcon, args = {class}},
                {value = addon.Ambiguate(name), color = addon:GetClassColor(class)},
                {value = guildRank, color = self.GetVersionColor, colorargs = {self, version, tVersion}},
                {
                    value = vVal or L["Waiting for response"],
                    color = self.GetVersionColor,
                    colorargs = {self, version, tVersion},
                    DoCellUpdate = self.SetCellModules,
                    args = modules
                }
            }
            v.rank = guildRank
            v.version = version
            v.tVersion = tVersion
            return self:Update()
        end
    end
    -- They haven't been added yet, so do it
    tinsert(
        self.frame.rows,
        {
            name = name,
            rank = guildRank,
            version = version,
            tVersion = tVersion,
            cols = {
                {value = "", DoCellUpdate = addon.SetCellClassIcon, args = {class}},
                {value = addon.Ambiguate(name), color = addon:GetClassColor(class)},
                {value = guildRank, color = self.GetVersionColor, colorargs = {self, version, tVersion}},
                {
                    value = vVal or L["Waiting for response"],
                    color = self.GetVersionColor,
                    colorargs = {self, version, tVersion},
                    DoCellUpdate = self.SetCellModules,
                    args = modules
                }
            }
        }
    )
    listOfNames[name] = true
    self:Update()
end

function RCVersionCheck:Update()
    self.frame.st:SortData()
    self:SendMessage("RCVersionCheckUpdate")
end

function RCVersionCheck:UpdateTotals()
    local total = #self.frame.rows
    local tVersions = AccumulateIf(self.frame.rows, function(row)
        return row.tVersion
    end)
    local outdated = AccumulateIf(self.frame.rows, function(row)
        return addon:VersionCompare(row.version, highestVersion)
    end)
    local normal = AccumulateIf(self.frame.rows, function(row)
        return row.version == highestVersion
    end)
    local text = TT:Acquire(
        colors.yellow:WrapTextInColorCode(tVersions),
        colors.red:WrapTextInColorCode(outdated),
        colors.green:WrapTextInColorCode(normal),
        total
    )
    self.frame.totals:SetText(table.concat(text, "/"))
    TT:Release(text)
end

-- Permanent comms
function RCVersionCheck:InitCoreVersionComms()
    -- "verTest"
    Comms:Subscribe(
        addon.PREFIXES.VERSION,
        "v",
        function(data, sender, _, dist)
            if addon:UnitIsUnit(sender, "player") then
                return
            end -- Don't repond to our own
            local otherVersion, tVersion = unpack(data)
            self:LogVersion(addon:UnitName(sender), otherVersion, tVersion)

            local verCheck = addon.Utils:CheckOutdatedVersion(addon.version, otherVersion, addon.tVersion, tVersion)

            if verCheck == addon.VER_CHECK_CODES[1] then
                return
            end -- Same as ours, don't do anything

            -- Send response
            Comms:Send {
                prefix = addon.PREFIXES.VERSION,
                target = dist == "GUILD" and "guild" or Player:Get(sender),
                command = "r",
                data = {addon.version, addon.tVersion, addon:GetInstalledModulesFormattedData()}
            }

            self:VerCheckDisplay(otherVersion, tVersion)
        end
    )
    -- verTestReply
    Comms:Subscribe(
        addon.PREFIXES.VERSION,
        "r",
        function(data, sender)
            if addon:UnitIsUnit(sender, "player") then
                return
            end -- Don't repond to our own
            local otherVersion, tVersion, moduleData = unpack(data)
            self:LogVersion(addon:UnitName(sender), otherVersion, tVersion)

            self:VerCheckDisplay(otherVersion, tVersion, moduleData)
        end
    )
    -- New, full version response for the version checker.
    Comms:Subscribe(
        addon.PREFIXES.VERSION,
        "fr",
        function(data, sender, _, dist)
            local senderPlayer = Player:Get(sender)
            local target
            if dist == "RAID" or dist == "PARTY" then
                target = "group"
            elseif dist == "GUILD" then
                target = "guild"
            else
                target = senderPlayer
            end

            Comms:Send {
                prefix = addon.PREFIXES.VERSION,
                target = target,
                command = "f",
                data = {
                    addon.playerClass,
                    addon.guildRank,
                    addon.version,
                    addon.tVersion,
                    addon:GetInstalledModulesFormattedData(),
                    senderPlayer:GetForTransmit()
                }
            }
        end
    )
end

--- Displays version status message, but only once per session.
function RCVersionCheck:VerCheckDisplay(otherVersion, tVersion, moduleData)
    if self.verCheckDisplayed then
        return
    end -- Don't bother if we already displayed

    local verCheck = addon.Utils:CheckOutdatedVersion(addon.version, otherVersion, addon.tVersion, tVersion)

    if verCheck == addon.VER_CHECK_CODES[2] then
        self:PrintOutdatedVersionWarning(otherVersion)
    elseif verCheck == addon.VER_CHECK_CODES[3] then
        self:PrintOutdatedTestVersionWarning(tVersion)
    end

    if moduleData then
        self:DoModulesVersionCheck(moduleData)
    end
end

--- Runs version checks on all modules data received in a 'verTestReply'
function RCVersionCheck:DoModulesVersionCheck(moduleData)
    -- Check modules. Parse the strings.
    if moduleData then
        for _, str in pairs(moduleData) do
            local baseName, otherVersion, tVersion = str:match("(.+) %- (.+)%-(.+)")
            if not baseName then
                baseName, otherVersion = str:match("(.+) %- (.+)")
            end
            if otherVersion and strfind(otherVersion, "%a+") then
                addon.Log:d("Someone's tampering with version in the module?", baseName, otherVersion)
            elseif baseName then
                for _, module in pairs(addon.modules) do
                    if module.baseName == baseName and module.version and not self.moduleVerCheckDisplayed[baseName] then
                        local verCheck =
                            addon.Utils:CheckOutdatedVersion(module.version, otherVersion, module.tVersion, tVersion)

                        if verCheck == addon.VER_CHECK_CODES[2] then
                            self:PrintOutdatedModuleVersion(baseName, module.version, otherVersion)
                        elseif verCheck == addon.VER_CHECK_CODES[3] then
                            self:PrintOutdatedModuleTestVersion(baseName, module.tVersion)
                        end
                    end
                end
            end
        end
    end
end

function RCVersionCheck:PrintOutdatedVersionWarning(newVersion, ourVersion)
    addon:Print(format(L["version_outdated_msg"], ourVersion or addon.version, newVersion))
    self.verCheckDisplayed = true
end

function RCVersionCheck:PrintOutdatedTestVersionWarning(tVersion)
    if #tVersion >= 10 then
        return addon.Log:W("tVersion tampering", tVersion)
    end
    addon:Print(format(L["tVersion_outdated_msg"], tVersion))
    self.verCheckDisplayed = true
end

function RCVersionCheck:PrintOutdatedModuleVersion(name, version, newVersion)
    addon:Print(format(L["module_version_outdated_msg"], name, version, newVersion))
    self.moduleVerCheckDisplayed[name] = true
end

function RCVersionCheck:PrintOutdatedModuleTestVersion(name, tVersion)
    if #tVersion >= 10 then
        addon.Log:d("Someone's tampering with tVersion in the module?", name, tVersion)
    end
    addon:Print(format(L["module_tVersion_outdated_msg"], name, tVersion))
    self.moduleVerCheckDisplayed[name] = true
end

---------------------------------------------
-- UI
---------------------------------------------

function RCVersionCheck:GetVersionColor(ver, tVer)
    if tVer then
        return colors.yellow
    end
    if ver == highestVersion then
        return colors.green
    end
    if addon:VersionCompare(ver, highestVersion) then
        return colors.red
    end
    return colors.grey
end

function RCVersionCheck:GetFrame()
    if self.frame then
        return self.frame
    end
    local f =
        addon.UI:NewNamed("Frame", UIParent, "DefaultRCVersionCheckFrame", L["RCLootCouncil Version Checker"], 250)

    local b1 = addon:CreateButton(_G.GUILD, f.content)
    b1:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
    b1:SetScript(
        "OnClick",
        function()
            self:Query("guild")
        end
    )
    f.guildBtn = b1

    local b2 = addon:CreateButton(_G.GROUP, f.content)
    b2:SetPoint("LEFT", b1, "RIGHT", 15, 0)
    b2:SetScript(
        "OnClick",
        function()
            self:Query("group")
        end
    )
    f.raidBtn = b2

    local b3 = addon:CreateButton(_G.CLOSE, f.content)
    b3:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10)
    b3:SetScript(
        "OnClick",
        function()
            self:Disable()
        end
    )
    f.closeBtn = b3

    local totals = addon.UI:New("Text", f.content, "Unknown")
    totals:SetHeight(25)
    totals:SetTextColor(1,1,1,1)
    totals:SetPoint("LEFT", b2, "RIGHT", 15, 0)
    totals:SetPoint("RIGHT", b3, "LEFT", -15, 0)
    local temp = TT:Acquire(
        colors.yellow:WrapTextInColorCode("Test Versions"),
        colors.red:WrapTextInColorCode("Outdated"),
        colors.green:WrapTextInColorCode("Up-to-date"),
        "Total"
    )
    local totalsTooltipText = table.concat(temp, " / ")
    TT:Release(temp)
    totals:SetMultipleScripts{
        OnEnter = function()
            addon:CreateTooltip("Overview", totalsTooltipText)
        end,
        OnLeave = addon.UI.HideTooltip
    }
    f.totals = totals

    local st = ST:CreateST(self.scrollCols, 12, 20, nil, f.content)
    st.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -35)
    --content.frame:SetBackdropColor(1,0,0,1)
    f:SetWidth(st.frame:GetWidth() + 20)
    f.rows = {} -- the row data
    f.st = st
    return f
end

function RCVersionCheck.SetCellModules(rowFrame, f, data, cols, row, realrow, column, fShow, table, ...)
    local modules = data[realrow].cols[column].args
    if modules and #modules > 0 then
        f:SetScript(
            "OnEnter",
            function()
                addon:CreateTooltip(L["Modules"], unpack(modules))
                table.DefaultEvents.OnEnter(rowFrame, f, data, cols, row, realrow, column, table)
            end
        )
        f:SetScript(
            "OnLeave",
            function()
                addon:HideTooltip()
                table.DefaultEvents.OnLeave(rowFrame, f, data, cols, row, realrow, column, table)
            end
        )
    else
        f:SetScript(
            "OnEnter",
            function()
                table.DefaultEvents.OnEnter(rowFrame, f, data, cols, row, realrow, column, table)
            end
        )
    end
    table.DoCellUpdate(rowFrame, f, data, cols, row, realrow, column, fShow, table)
end

function GuildRankSort(table, rowa, rowb, sortbycol)
    local column = table.cols[sortbycol]
    local a, b = table:GetRow(rowa), table:GetRow(rowb)
    -- Extract the rank index from the name, fallback to 100 if not found
    a = guildRanks[a.rank] or 100
    b = guildRanks[b.rank] or 100
    if a == b then
        if column.sortnext then
            local nextcol = table.cols[column.sortnext]
            if not (nextcol.sort) then
                if nextcol.comparesort then
                    return nextcol.comparesort(table, rowa, rowb, column.sortnext)
                else
                    return table:CompareSort(rowa, rowb, column.sortnext)
                end
            end
        end
        return false
    else
        local direction = column.sort or column.defaultsort or ST.SORT_ASC
        if direction == ST.SORT_ASC then
            return a < b
        else
            return a > b
        end
    end
end

-- There's no need to make this more complicated.
function RCVersionCheck.VersionSort(table, rowa, rowb, sortbycol)
    local column = table.cols[sortbycol]
    local a, b = table:GetRow(rowa), table:GetRow(rowb)
    if not a.version then
        return false
    elseif not b.version then
        return true
    elseif a.version == b.version then
        if column.sortnext then
            local nextcol = table.cols[column.sortnext]
            if not nextcol.sort then
                if nextcol.comparesort then
                    return nextcol.comparesort(table, rowa, rowb, column.sortnext)
                else
                    return table:CompareSort(rowa, rowb, column.sortnext)
                end
            end
        end
        return false
    else
        local direction = column.sort or column.defaultsort or ST.SORT_ASC
        if direction == ST.SORT_ASC then
            return addon:VersionCompare(a.version, b.version)
        else
            return addon:VersionCompare(b.version, a.version)
        end
    end
end
