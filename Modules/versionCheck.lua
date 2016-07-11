-- Author      : Potdisc
-- Create Date : 12/15/2014 8:55:10 PM
-- DefaultModule
-- versionCheck.lua	Adds a Version Checker to check versions of either people in current raidgroup or guild

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCVersionCheck = addon:NewModule("RCVersionCheck", "AceTimer-3.0", "AceComm-3.0", "AceHook-3.0")
local ST = LibStub("ScrollingTable")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

function RCVersionCheck:OnInitialize()
	-- Initialize scrollCols on self so others can change it
	self.scrollCols = {
		{ name = "",				width = 20, sortnext = 2,},
		{ name = L["Name"],		width = 150, },
		{ name = L["Rank"],		width = 90, },
		{ name = L["Version"],	width = 140, align = "RIGHT" },
	}
end

function RCVersionCheck:OnEnable()
	self.frame = self:GetFrame()
	self:RegisterComm("RCLootCouncil")
	self:Show()
end

function RCVersionCheck:OnDisable()
	self:Hide()
	self:UnregisterAllComm()
	self.frame.rows = {}
end

function RCVersionCheck:Show()
	self:AddEntry(addon.playerName, addon.playerClass, addon.guildRank, addon.version, addon.tVersion) -- add ourself
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
				self:AddEntry(name, class, rank, L["Waiting for response"])
			end
		end

	elseif group == "group" then
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, class, _, online = GetRaidRosterInfo(i)
			if online then
				self:AddEntry(name, class, L["Unknown"], L["Waiting for response"])
			end
		end
	end
	addon:SendCommand(group, "verTest", addon.version, addon.tVersion)
	self:AddEntry(addon.playerName, addon.playerClass, addon.guildRank, addon.version, addon.tVersion) -- add ourself
	self:ScheduleTimer("QueryTimer", 5)
end

function RCVersionCheck:QueryTimer()
	for k,v in pairs(self.frame.rows) do
		local cell = self.frame.st:GetCell(k,4)
		if cell.value == L["Waiting for response"] then cell.value = L["Not installed"] end
	end
	self:Update()
end

function RCVersionCheck:AddEntry(name, class, guildRank, version, tVersion)
	local vVal = version
	if tVersion then vVal = version.."-"..tVersion end
	for row, v in ipairs(self.frame.rows) do
		if addon:UnitIsUnit(v.name, name) then -- they're already added, so update them
			v.cols =	{
				{ value = "",					DoCellUpdate = addon.SetCellClassIcon, args = {class}, },
				{ value = addon.Ambiguate(name),color = addon:GetClassColor(class), },
				{ value = guildRank,			color = self:GetVersionColor(version,tVersion)},
				{ value = vVal ,				color = self:GetVersionColor(version,tVersion)},
			}
			return self:Update()
		end
	end
	-- They haven't been added yet, so do it
	tinsert(self.frame.rows,
	{	name = name,
		cols = {
			{ value = "",					DoCellUpdate = addon.SetCellClassIcon, args = {class}, },
			{ value = addon.Ambiguate(name),color = addon:GetClassColor(class), },
			{ value = guildRank,			color = self:GetVersionColor(version,tVersion)},
			{ value = vVal ,				color = self:GetVersionColor(version,tVersion)},
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
	if ver == addon.version then return green end
	if ver < addon.version then return red end
	return grey
end

function RCVersionCheck:GetFrame()
	if self.frame then return self.frame end
	local f = addon:CreateFrame("DefaultRCVersionCheckFrame", "versionCheck", L["RCLootCouncil Version Checker"], 250)

	local b1 = addon:CreateButton(L["Guild"], f.content)
	b1:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
	b1:SetScript("OnClick", function() self:Query("guild") end)
	f.guildBtn = b1

	local b2 = addon:CreateButton(L["Group"], f.content)
	b2:SetPoint("LEFT", b1, "RIGHT", 15, 0)
	b2:SetScript("OnClick", function() self:Query("group") end)
	f.raidBtn = b2

	local b3 = addon:CreateButton(L["Close"], f.content)
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
