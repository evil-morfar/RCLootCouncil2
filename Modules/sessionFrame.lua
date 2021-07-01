--- sessionFrame.lua Adds a frame listing the items to start a session with.
-- DefaultModule - Requires ml_core.lua or similary functionality.
-- @author Potdisc
-- Create Date : 1/20/2015 3:48:38 AM
---@type RCLootCouncil
local _,addon = ...
local RCSessionFrame = addon:NewModule("RCSessionFrame", "AceTimer-3.0", "AceEvent-3.0")
local ST = LibStub("ScrollingTable")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local ml;
local ROW_HEIGHT = 40
local awardLater = false
local loadingItems = false
local waitingToEndSessions = false  -- need some time to confirm the result of award later and the session cant be ended until then.
									-- When user chooses to award later then quickly reopens the loot window when this variable is still true, dont show session frame.
local scheduledToShowAgain = false       -- Have we scheduled to reshow the frame, due to a uncached item?

local Council = addon.Require "Data.Council"

--- Lua
local getglobal, ipairs, tinsert =
		getglobal, ipairs, tinsert

-- GLOBALS: CreateFrame, IsModifiedClick, HandleModifiedItemClick, InCombatLockdown, _G

function RCSessionFrame:OnInitialize()
	self.scrollCols = {
		{ name = "", width = 30}, 				-- remove item, sort by session number.
		{ name = "", width = ROW_HEIGHT},	-- item icon
		{ name = "", width = 50,}, 	-- item lvl
		{ name = "", width = 160}, 			-- item link
	}
end

function RCSessionFrame:OnEnable()
	addon.Log("RCSessionFrame enabled")
	self:RegisterMessage("RCLootStatusReceived", "UpdateLootStatus")
	ml = addon:GetActiveModule("masterlooter")
end

function RCSessionFrame:OnDisable()
	self.frame:Hide()
	self.frame.rows = {}
	self:UnregisterMessage("RCLootStatusReceived")
	awardLater = false
	addon.Log("RCSessionFrame disabled")
end

function RCSessionFrame:Show(data, disableAwardLater)
	if waitingToEndSessions then
		return		-- Silently fails
	end

	self.frame = self:GetFrame()
	self.frame:Show()
	scheduledToShowAgain = false

	if disableAwardLater then
		self.frame.toggle:Disable()
		getglobal(self.frame.toggle:GetName().."Text"):SetTextColor(0.7, 0.7, 0.7)
		awardLater = false
	else
		awardLater = addon:Getdb().awardLater
		self.frame.toggle:Enable()
		getglobal(self.frame.toggle:GetName().."Text"):SetTextColor(1, 1, 1)
	end

	if data then
		loadingItems = false
		if addon:Getdb().sortItems and not ml.running then
			-- FIXME Sorting after adding new items will screw up the original session order.
			-- Either don't sort (as now) or we would need something to track the sessions of items
			-- that's already in a running session.
			ml:SortLootTable(data)
		end
	end
	self:ExtractData(data)
	self.frame.st:SetData(self.frame.rows)
	self:Update()
end

function RCSessionFrame:Hide()
	self.frame:Hide()
end

function RCSessionFrame:IsRunning()
	return self.frame and self.frame:IsVisible()
end

-- Data should be unmodified lootTable from ml_core
function RCSessionFrame:ExtractData(data)
	-- Clear any rowdata
	self.frame.rows = {}
	-- And set the new
	for k,v in ipairs(data) do
		if not v.isSent then -- Don't add items we've already started a session with
			local bonusText = v.link and addon:GetItemBonusText(v.link, "\n ") or ""
			if bonusText ~= "" then bonusText = "\n |cff33ff33"..bonusText end
			tinsert(self.frame.rows, {
				session = k,
				texture = v.texture or nil,
				link = v.link,
				owner = v.owner,
				cols = {
					{ DoCellUpdate = self.SetCellDeleteBtn, },
					{ DoCellUpdate = self.SetCellItemIcon},
					{ value = " "..(addon.Utils:GetItemLevelText(v.ilvl, v.token) or "")..bonusText},
					{ DoCellUpdate = self.SetCellText },
				},
			})
		end
	end
end

function RCSessionFrame:Update()
	self.frame.toggle:SetChecked(awardLater)
	if ml.running then
		self.frame.startBtn:SetText(_G.ADD)
	else
		self.frame.startBtn:SetText(_G.START)
	end
end

function RCSessionFrame:UpdateLootStatus ()
	if not self.frame then return end
	local status, list = addon:GetLootStatusData()
	self.frame.lootStatus:SetText(status)
	self.frame.lootStatus:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.frame.lootStatus, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["Loot Status"])
		for _, v in ipairs(list) do
			GameTooltip:AddDoubleLine(addon:GetUnitClassColoredName(v.name), v.text)
		end
		GameTooltip:Show()
	end)
end

function RCSessionFrame:DeleteItem(session, row)
	addon.Log:D("Delete row:", row, "Sesison:", session)
	ml:RemoveItem(session) -- remove the item from MLs lootTable
	self:Show(ml.lootTable)
end

function RCSessionFrame.SetCellText(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	if frame.text:GetFontObject() ~= _G.GameFontNormal then
		frame.text:SetFontObject("GameFontNormal") -- We want bigger font
	end
	if not data[realrow].link then
		frame.text:SetText("--".._G.RETRIEVING_ITEM_INFO.."--")
		loadingItems = true
		if not scheduledToShowAgain then -- Dont make unneeded scheduling
			scheduledToShowAgain = true
			RCSessionFrame:ScheduleTimer("Show", 0, ml.lootTable) -- Try again next frame
		end
	else
		frame.text:SetText(data[realrow].link..(data[realrow].owner and "\n"..addon:GetUnitClassColoredName(data[realrow].owner) or ""))
	end
end

function RCSessionFrame.SetCellDeleteBtn(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	frame:SetNormalTexture("Interface/BUTTONS/UI-GroupLoot-Pass-Up.png")
	frame:SetScript("OnClick", function() RCSessionFrame:DeleteItem(data[realrow].session, realrow) end)
	frame:SetSize(20,20)
end

function RCSessionFrame.SetCellItemIcon(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local texture = data[realrow].texture or "Interface/ICONS/INV_Sigil_Thorim.png"
	local link = data[realrow].link
	frame:SetNormalTexture(texture)
	frame:SetScript("OnEnter", function() addon:CreateHypertip(link) end)
	frame:SetScript("OnLeave", function() addon:HideTooltip() end)
	frame:SetScript("OnClick", function()
		if IsModifiedClick() then
		   HandleModifiedItemClick(link);
      end
	end)
end

function RCSessionFrame:GetFrame()
	if self.frame then return self.frame end

	local f = addon.UI:NewNamed("Frame", UIParent, "DefaultRCSessionSetupFrame", L["RCLootCouncil Session Setup"], 260)

	local tgl = CreateFrame("CheckButton", f:GetName().."Toggle", f.content, "ChatConfigCheckButtonTemplate")
	getglobal(tgl:GetName().."Text"):SetText(L["Award later?"])
	tgl:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 40)
	tgl.tooltip = L["Check this to loot the items and distribute them later."]
	tgl:SetChecked(awardLater)
	tgl:SetScript("OnClick", function() awardLater = not awardLater; end )
	f.toggle = tgl

	-- Start button
	local b1 = addon:CreateButton(_G.START, f.content)
	b1:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
	b1:SetScript("OnClick", function()
		if loadingItems then
			return addon:Print(L["You can't start a session before all items are loaded!"])
		end
		if not ml.lootTable or #ml.lootTable == 0 then
			addon:Print(L["You cannot start an empty session."])
			addon.Log:D("Player tried to start empty session.")
			return
		end
		if awardLater then
			local sessionAwardDoneCount = 0
			waitingToEndSessions = true
			for session in ipairs(ml.lootTable) do
				ml:Award(session, nil, nil, nil, function()
					sessionAwardDoneCount = sessionAwardDoneCount + 1
					if sessionAwardDoneCount >= #ml.lootTable then
						waitingToEndSessions = false
						ml:EndSession()
					end
				end)
			end
		else
			if Council:GetNum() == 0 then
				addon:Print(L["Please wait a few seconds until all data has been synchronized."])
				return addon.Log:D("Data wasn't ready", Council:GetNum())
			elseif InCombatLockdown() and not addon.db.profile.skipCombatLockdown then
				return addon:Print(L["You can't start a loot session while in combat."])
			--elseif ml.running then
				--return addon:Print(L["You're already running a session."])
			else
				ml:StartSession()
			end
		end
		self:Disable()
	end)
	f.startBtn = b1

	-- Cancel button
	local b2 = addon:CreateButton(_G.CANCEL, f.content)
	b2:SetPoint("LEFT", b1, "RIGHT", 15, 0)
	b2:SetScript("OnClick", function()
		if not ml.running then -- Don't clear lootTable on a running session.
			ml.lootTable = {}
		end
		self:Disable()
	end)
	f.closeBtn = b2

	-- Loot Status
	f.lootStatus = addon.UI:New("Text", f.content, " ")
	f.lootStatus:SetTextColor(1,1,1,1) -- White for now
	f.lootStatus:SetHeight(20)
	f.lootStatus:SetWidth(75)
	-- f.lootStatus:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 14)
	f.lootStatus:SetPoint("LEFT", f.closeBtn, "RIGHT", 13, 1)
	f.lootStatus:SetScript("OnLeave", addon.Utils.HideTooltip)
	f.lootStatus.text:SetJustifyH("LEFT")

	local st = ST:CreateST(self.scrollCols, 5, ROW_HEIGHT, nil, f.content)
	st.frame:SetPoint("TOPLEFT",f,"TOPLEFT",10,-ROW_HEIGHT-10)
	st:RegisterEvents({
		["OnClick"] = function(_, _, _, _, row, realrow)
			if not (row or realrow) then
				return true
			end
		end
	})
	f:SetWidth(st.frame:GetWidth()+20)
	f:SetHeight(325)
	f.rows = {} -- the row data
	f.st = st
	return f
end
