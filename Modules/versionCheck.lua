--- versionCheck.lua	Adds a Version Checker to check versions of either people in current raidgroup or guild.
-- DefaultModule.
-- @author Potdisc
-- Create Date : 12/15/2014 8:55:10 PM

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCVersionCheck = addon:NewModule("RCVersionCheck", "AceTimer-3.0", "AceComm-3.0", "AceHook-3.0")
local ST = LibStub("ScrollingTable")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local GuildRankSort
local guildRanks = {}
local highestVersion = "0.0.0"

function RCVersionCheck:OnInitialize()
	-- Initialize scrollCols on self so others can change it
	self.scrollCols = {
		{ name = "",				width = 20, sortnext = 2,},
		{ name = _G.NAME,		width = 150, defaultsort = "dsc"},
		{ name = _G.RANK,		width = 90, comparesort = GuildRankSort},
		{ name = L["Version"],	width = 140, align = "RIGHT", comparesort = self.VersionSort, sort = "asc", sortnext = 2},
	}
end

function RCVersionCheck:OnEnable()
	self.frame = self:GetFrame()
	self:RegisterComm("RCLootCouncil")
	self:Show()
	guildRanks = addon:GetGuildRanks()
end

function RCVersionCheck:OnDisable()
	self:Hide()
	self:UnregisterAllComm()
	self.frame.rows = {}
end

function RCVersionCheck:Show()
	self:AddEntry(addon.playerName, addon.playerClass, addon.guildRank, addon.version, addon.tVersion,addon:GetInstalledModulesFormattedData()) -- add ourself
	self.frame:Show()
	self.frame.st:SetData(self.frame.rows)
end

function RCVersionCheck:Hide()
	self.frame:Hide()
end

function RCVersionCheck:OnCommReceived(prefix, serializedMsg, distri, sender)
	if prefix == "RCLootCouncil" then
		local test, command, data = addon:Deserialize(serializedMsg)
		if addon:HandleXRealmComms(self, command, data, sender) then return end
		if test and command == "verTestReply" then
			self:AddEntry(unpack(data))
		end
	end
end

function RCVersionCheck:Query(group)
	addon:DebugLog("Player asked for verTest", group)
	if group == "guild" then
		GuildRoster()
		for i = 1, GetNumGuildMembers() do
			local name, rank, _,_,_,_,_,_, online,_, class = GetGuildRosterInfo(i)
			if online then
				self:AddEntry(name, class, rank)
			end
		end

	elseif group == "group" then
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, class, _, online = GetRaidRosterInfo(i)
			if online then
				self:AddEntry(name, class, _G.UNKNOWN)
			end
		end
	end
	addon:SendCommand(group, "verTest", addon.version, addon.tVersion)
	self:AddEntry(addon.playerName, addon.playerClass, addon.guildRank, addon.version, addon.tVersion, addon:GetInstalledModulesFormattedData()) -- add ourself
	self:ScheduleTimer("QueryTimer", 5)
end

function RCVersionCheck:QueryTimer()
	for k,v in pairs(self.frame.rows) do
		local cell = self.frame.st:GetCell(k,4)
		if cell.value == L["Waiting for response"] then
			cell.value = L["Not installed"]
		end
	end
	self:Update()
end

function RCVersionCheck:AddEntry(name, class, guildRank, version, tVersion, modules)
	-- We need to be careful with naming conventions just as in RCLootCouncil:UnitName()
	--name = name:lower():gsub("^%l", string.upper)
	name = addon:UnitName(name)
	if not tVersion and addon:VersionCompare(highestVersion, version) then
		highestVersion = version
	end
	local vVal = version
	if tVersion then vVal = tostring(version).."-"..tVersion end
	for row, v in ipairs(self.frame.rows) do
		if addon:UnitIsUnit(v.name, name) then -- they're already added, so update them
			v.cols =	{
				{ value = "",					DoCellUpdate = addon.SetCellClassIcon, args = {class}, },
				{ value = addon.Ambiguate(name),color = addon:GetClassColor(class), },
				{ value = guildRank,			color = self.GetVersionColor, colorargs = {self,version,tVersion}},
				{ value = vVal or L["Waiting for response"],color = self.GetVersionColor, colorargs = {self,version,tVersion}, DoCellUpdate = self.SetCellModules, args = modules},
			}
			v.rank = guildRank
			v.version = version
			return self:Update()
		end
	end
	-- They haven't been added yet, so do it
	tinsert(self.frame.rows,
	{	name = name,
		rank = guildRank,
		version = version,
		cols = {
			{ value = "",					DoCellUpdate = addon.SetCellClassIcon, args = {class}, },
			{ value = addon.Ambiguate(name),color = addon:GetClassColor(class), },
			{ value = guildRank,			color = self.GetVersionColor, colorargs = {self,version,tVersion}},
			{ value = vVal or L["Waiting for response"],	color = self.GetVersionColor, colorargs = {self,version,tVersion}, DoCellUpdate = self.SetCellModules, args = modules},
		},
	})
	self:Update()
end

function RCVersionCheck:Update()
	self.frame.st:SortData()
end

function RCVersionCheck:GetVersionColor(ver,tVer)
	local green, yellow, red, grey = {r=0,g=1,b=0,a=1},{r=1,g=1,b=0,a=1},{r=1,g=0,b=0,a=1},{r=0.75,g=0.75,b=0.75,a=1}
	if tVer then return yellow end
	if ver == highestVersion then return green end
	if addon:VersionCompare(ver, highestVersion) then return red end
	return grey
end

function RCVersionCheck:GetFrame()
	if self.frame then return self.frame end
	local f = addon:CreateFrame("DefaultRCVersionCheckFrame", "versionCheck", L["RCLootCouncil Version Checker"], 250)

	local b1 = addon:CreateButton(_G.GUILD, f.content)
	b1:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
	b1:SetScript("OnClick", function() self:Query("guild") end)
	f.guildBtn = b1

	local b2 = addon:CreateButton(_G.GROUP, f.content)
	b2:SetPoint("LEFT", b1, "RIGHT", 15, 0)
	b2:SetScript("OnClick", function() self:Query("group") end)
	f.raidBtn = b2

	local b3 = addon:CreateButton(_G.CLOSE, f.content)
	b3:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10)
	b3:SetScript("OnClick", function() self:Disable() end)
	f.closeBtn = b3

	local st = ST:CreateST(self.scrollCols, 12, 20, nil, f.content)
	st.frame:SetPoint("TOPLEFT",f,"TOPLEFT",10,-35)
	--content.frame:SetBackdropColor(1,0,0,1)
	f:SetWidth(st.frame:GetWidth()+20)
	f.rows = {} -- the row data
	f.st = st
	return f
end

function RCVersionCheck.SetCellModules(rowFrame, f, data, cols, row, realrow, column, fShow, table, ...)
	local modules = data[realrow].cols[column].args
	if modules and #modules>0 then
		f:SetScript("OnEnter", function()
			 addon:CreateTooltip(L["Modules"], unpack(modules))
			 table.DefaultEvents.OnEnter(rowFrame, f, data, cols, row, realrow, column, table)
		end)
		f:SetScript("OnLeave", function()
			addon:HideTooltip()
			table.DefaultEvents.OnLeave(rowFrame, f, data, cols, row, realrow, column, table)
		end)
	else
		f:SetScript("OnEnter", function()
			table.DefaultEvents.OnEnter(rowFrame, f, data, cols, row, realrow, column, table)
		end)
	end
	table.DoCellUpdate(rowFrame, f, data, cols, row, realrow, column, fShow, table)
end

function GuildRankSort(table, rowa, rowb, sortbycol)
	local column = table.cols[sortbycol]
	local a, b = table:GetRow(rowa), table:GetRow(rowb);
	-- Extract the rank index from the name, fallback to 100 if not found
	a = guildRanks[a.rank] or 100
	b = guildRanks[b.rank] or 100
	if a == b then
		if column.sortnext then
			local nextcol = table.cols[column.sortnext];
			if not(nextcol.sort) then
				if nextcol.comparesort then
					return nextcol.comparesort(table, rowa, rowb, column.sortnext);
				else
					return table:CompareSort(rowa, rowb, column.sortnext);
				end
			end
		end
		return false
	else
		local direction = column.sort or column.defaultsort or "asc";
		if direction:lower() == "asc" then
			return a > b;
		else
			return a < b;
		end
	end
end

-- There's no need to make this more complicated.
function RCVersionCheck.VersionSort(table, rowa, rowb, sortbycol)
	local column = table.cols[sortbycol]
	local a,b = table:GetRow(rowa), table:GetRow(rowb)
	if not a.version then return false
	elseif not b.version then return true
	elseif a.version == b.version then
		if column.sortnext then
			local nextcol = table.cols[column.sortnext];
			if not nextcol.sort then
				if nextcol.comparesort then
					return nextcol.comparesort(table, rowa, rowb, column.sortnext);
				else
					return table:CompareSort(rowa, rowb, column.sortnext);
				end
			end
		end
		return false
	else
		local direction = column.sort or column.defaultsort or "asc";
		if direction:lower() == "asc" then
			return addon:VersionCompare(b.version, a.version)
		else
			return addon:VersionCompare(a.version, b.version)
		end
	end
end
