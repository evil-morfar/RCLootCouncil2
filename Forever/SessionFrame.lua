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

	return f
end

addon:Hook(SF, "Update", function(self)
	self.frame.manualTradeToggle:SetChecked(self.mlLootToPlayer)
end)

addon:SecureHook(SF, "Show", function(self, data, isAwardLater)
	local lootMethod = addon.GetLootMethod()
	-- Manual Trade toggle is only shown when using ML
	if lootMethod == Enum.LootMethod.Masterlooter then
		self.frame.manualTradeToggle:Show()
		self.mlLootToPlayer = addon:Getdb().mlLootToPlayer
	else
		HideManualTrade(self.frame)
	end
	if isAwardLater then
		self.frame.manualTradeToggle:Disable()
		_G[self.frame.manualTradeToggle:GetName() .. "Text"]:SetTextColor(.7, .7, .7)
		self.mlLootToPlayer = false
	else
		self.frame.manualTradeToggle:Enable()
		_G[self.frame.manualTradeToggle:GetName() .. "Text"]:SetTextColor(1, 1, 1)
	end
end)