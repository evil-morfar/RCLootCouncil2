--- sessionFrame.lua	Adds a frame listing the items to start a session with.
-- DefaultModule - Requires ml_core.lua or similary functionality.
-- @author Potdisc
-- Create Date : 1/20/2015 3:48:38 AM

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCSessionFrame = addon:NewModule("RCSessionFrame", "AceTimer-3.0")
local ST = LibStub("ScrollingTable")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local ml;
local ROW_HEIGHT = 40
local awardLater = false
local loadingItems = false

function RCSessionFrame:OnInitialize()
	self.scrollCols = {
		{ name = "", width = 30}, 				-- remove item, sort by session number.
		{ name = "", width = ROW_HEIGHT},	-- item icon
		{ name = "", width = 160}, 			-- item link
	}
end

function RCSessionFrame:OnEnable()
	addon:Debug("RCSessionFrame", "enabled")
	ml = addon:GetActiveModule("masterlooter")
end

function RCSessionFrame:OnDisable()
	self.frame:Hide()
	self.frame.rows = {}
	awardLater = false
end

function RCSessionFrame:Show(data)
	self.frame = self:GetFrame()
	self.frame:Show()

	if data then
		loadingItems = false
		if addon:Getdb().sortItems then
			ml:SortLootTable(data)
		end
		self:ExtractData(data)
		self.frame.st:SetData(self.frame.rows)
		self:Update()
	end
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
		self.frame.rows[k] = {
			texture = v.texture or nil,
			link = v.link,
			cols = {
				{ DoCellUpdate = self.SetCellDeleteBtn, },
				{ DoCellUpdate = self.SetCellItemIcon},
				{ DoCellUpdate = self.SetCellText },
			},
		}
	end
end

function RCSessionFrame:Update()
	self.frame.toggle:SetChecked(awardLater)
end

function RCSessionFrame:DeleteItem(index)
	addon:Debug("Delete row:", index)
	ml:RemoveItem(index) -- remove the item from MLs lootTable
	self:Show(ml.lootTable)
end

function RCSessionFrame.SetCellText(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	if frame.text:GetFontObject() ~= GameFontNormal then
		frame.text:SetFontObject("GameFontNormal") -- We want bigger font
	end
	if not data[realrow].link then
		frame.text:SetText("--".._G.RETRIEVING_ITEM_INFO.."--")
		loadingItems = true
		RCSessionFrame:ScheduleTimer("Show", 1, ml.lootTable) -- Expect data to be available in 1 sec and then recreate the frame
	else
		frame.text:SetText(data[realrow].link)
	end
end

function RCSessionFrame.SetCellDeleteBtn(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	frame:SetNormalTexture("Interface/BUTTONS/UI-GroupLoot-Pass-Up.png")
	frame:SetScript("OnClick", function() RCSessionFrame:DeleteItem(realrow) end)
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

	local f = addon:CreateFrame("DefaultRCSessionSetupFrame", "sessionframe", L["RCLootCouncil Session Setup"], 250)

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
			addon:DebugLog("Player tried to start empty session.")
			return
		end
		if awardLater then
			for session in ipairs(ml.lootTable) do ml:Award(session) end
			ml:EndSession()
		else
			if not addon.candidates[addon.playerName] or #addon.council == 0 then
				addon:Print(L["Please wait a few seconds until all data has been synchronized."])
				return addon:Debug("Data wasn't ready", addon.candidates[addon.playerName], #addon.council)
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
		ml.lootTable = {}
		self:Disable()
	end)
	f.closeBtn = b2

	local st = ST:CreateST(self.scrollCols, 5, ROW_HEIGHT, nil, f.content)
	st.frame:SetPoint("TOPLEFT",f,"TOPLEFT",10,-20)
	st:RegisterEvents({
		["OnClick"] = function(_, _, _, _, row, realrow)
			if not (row or realrow) then
				return true
			end
		end
	})
	f:SetWidth(st.frame:GetWidth()+20)
	f:SetHeight(305)
	f.rows = {} -- the row data
	f.st = st
	return f
end
