-- Author      : Potdisc
-- Create Date : 12/16/2014 7:22:51 PM
-- DefaultModule
-- rankChooser		Adds a simple frame for choosing the minimum guildrank to be included in the council

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RankChooser = addon:NewModule("RCRankChooser")
local AG = LibStub("AceGUI-3.0")
local db = addon:Getdb()

function RankChooser:OnEnable()
	self:Show()
end

function RankChooser:OnDisable()
	self:Hide()
end

function RankChooser:Show()
	self.frame = self:GetFrame()
end

function RankChooser:Hide()
	self.frame:Release()
end

function RankChooser:SetMinRank(rank)
	db.minRank = rank
	GuildRoster()
	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex = GetGuildRosterInfo(i) -- get info from all guild members
		if rankIndex + 1 <= rank then -- if the member is the required rank, or above
			table.insert(db.council, name) -- then insert them to the council
		end
	end
end

function RankChooser:GetFrame()
	if self.frame and self.frame:IsVisible() then return self.frame end

	local f = AG:Create("InlineGroup")
	f:SetTitle("Choose minimum rank")
	f:SetHeight(100)
	f:SetLayout("Flow")

	local drop = AG:Create("Dropdown")
	local t = {}
	for i = 1, GuildControlGetNumRanks() do 
		tinsert(t, i.." - "..GuildControlGetRankName(i))
	end
	drop:SetList(t)
	local rank
	drop:SetCallback("OnValueChanged", function(key) rank = key end)
	drop:SetFullWidth(true)
	f:AddChild(drop)

	local accept = AG:Create("Button")
	accept:SetText("Accept")
	accept:SetWidth(75)
	accept:SetCallback("OnClick", function() self:SetMinRank(rank) end)
	accept:SetCallback("OnEnter", function() addon:CreateTooltip({"Accepting will wipe if current council if any!"}) end)
	accept:SetCallback("OnLeave", function() addon:HideTooltip() end)
--	accept:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
	f:AddChild(accept)

	local close = AG:Create("Button")
	close:SetText("Close")
	close:SetWidth(75)
	close:SetCallback("OnClick", function() self:Disable() end)
	close:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
	f:AddChild(close)

	return f
end