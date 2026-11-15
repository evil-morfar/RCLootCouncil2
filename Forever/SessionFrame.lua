---@diagnostic disable: duplicate-set-field
--- @type RCLootCouncil
local addon = select(2, ...)
--- @type RCLootCouncilLocale
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
---@class RCSessionFrame
local SF = addon:GetModule "RCSessionFrame"

local function HideManualTrade(frame)
	frame.manualTradeToggle:Hide()
	SF.mlLootToPlayer = false
end

local OriginalGetFrame = SF.GetFrame
function SF:GetFrame()
	local lootMethod = addon.GetLootMethod()
	-- Manual Trade toggle is only shown when using ML
	if self.lastLootMethod and self.lastLootMethod ~= lootMethod then
		if lootMethod == Enum.LootMethod.Masterlooter then
			self.frame.manualTradeToggle:Show()
			self.mlLootToPlayer = addon:Getdb().mlLootToPlayer
		else
			HideManualTrade(self.frame)
		end
	end
	if self.frame then return self.frame end

	---@class HistoryFrame
	local f = OriginalGetFrame(self)
	local tgl = CreateFrame("CheckButton", f:GetName() .. "ToggleMlToPlayer", f.content, "ChatConfigCheckButtonTemplate")
	tgl:SetPoint("LEFT", f.toggle.Text, "RIGHT", 10, 0)
	tgl:SetChecked(self.mlLootToPlayer)
	tgl:SetScript("OnClick", function() self.mlLootToPlayer = not self.mlLootToPlayer end)
	tgl.Text:SetTextToFit(L.opt_forever_mlLootToPlayer_name)
	tgl.Text:SetPoint("LEFT", tgl, "RIGHT", 5, 0)
	tgl.tooltip = L.opt_forever_mlLootToPlayer_desc
	f.manualTradeToggle = tgl
	if lootMethod ~= Enum.LootMethod.Masterlooter then
		HideManualTrade(f)
	end

	self.lastLootMethod = lootMethod
	return f
end

addon:Hook(SF, "Update", function(self)
	self.frame.manualTradeToggle:SetChecked(self.mlLootToPlayer)
end)