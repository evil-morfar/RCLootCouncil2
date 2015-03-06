-- Author      : Potdisc
-- Create Date : 1/20/2015 3:48:38 AM
-- DefaultModule - Requires ml_core.lua or similary functionality.
-- Adds a frame listing the items to start a session with.

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
RCSessionFrame = addon:NewModule("RCSessionFrame")
local ST = LibStub("ScrollingTable")

local db;
local ROW_HEIGHT = 40
local HIGHLIGHT = {r = 0, g = 0, b = 0, a = 0} -- 0's for no highlight
local awardLater = false

function RCSessionFrame:OnInitialize()
	self.scrollCols = {
		{ name = "",		width = 30 }, -- remove item
		{ name = "",		width = ROW_HEIGHT }, -- item icon
		{ name = "Item",	width = 150}, -- item link
	}
end

function RCSessionFrame:OnEnable()
	db = addon:Getdb()
	--self:Show()
end

function RCSessionFrame:OnDisable()
	self.frame:Hide()
	self.frame.rows = {}
	self.frame:SetParent(nil)
end

function RCSessionFrame:Show(data)
	self.frame = self:GetFrame()
	self.frame:Show()
	if data then
		self:ExtractData(data)
		self.frame.st:SetData(self.frame.rows)
		self:Update()
	end
end

function RCSessionFrame:Hide()
	self.frame:Hide()
end

-- Data should be unmodified lootTable from ml_core
function RCSessionFrame:ExtractData(data)
	-- Clear any rowdata
	self.frame.rows = {}
	-- And set the new
	for k,v in ipairs(data) do
		self.frame.rows[k] = {
			cols = {
				{ value = "",	DoCellUpdate = self.SetCellDeleteBtn, },
				{ value = "",	DoCellUpdate = self.SetCellItemIcon, args = {v.texture, v.link} },
				{ value = v.link },	
			},
		}
	end
end

function RCSessionFrame:Update()
	self.frame.st:SortData()
end

function RCSessionFrame:DeleteItem(index)
	addon:Print("row: "..index)
	local ml = addon:GetActiveModule("masterlooter")
	ml:RemoveItem(index) -- remove the item from MLs lootTable
	self:Show(ml.lootTable)
end

function RCSessionFrame:SetCellDeleteBtn(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	frame:SetNormalTexture("Interface/BUTTONS/UI-GroupLoot-Pass-Up.png")
	frame:SetScript("OnClick", function() RCSessionFrame:DeleteItem(realrow) end)
	frame:SetSize(20,20)
end

function RCSessionFrame:SetCellItemIcon(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local celldata = data[realrow].cols[column]
	local texture = celldata.args[1]
	local link = celldata.args[2]
	frame:SetNormalTexture(texture)
	frame:SetScript("OnEnter", function() addon:CreateTooltip(nil, link) end)
	frame:SetScript("OnLeave", function() addon:HideTooltip() end)
end


function RCSessionFrame:GetFrame()
	if self.frame then return self.frame end

	local f = addon:CreateFrame("DefaultRCSessionSetupFrame", "sessionFrame")
	f.title = addon:CreateTitleFrame(f, "RCLootCouncil Session Setup", 250)

	local tgl = CreateFrame("CheckButton", f:GetName().."Toggle", f, "ChatConfigCheckButtonTemplate")
	getglobal(tgl:GetName().."Text"):SetText("  Award later?")
	tgl:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 40)
	tgl.tooltip = "Check this to loot the items and distribute them later."
	tgl:SetScript("OnClick", function() awardLater = not awardLater; end )
	f.toggle = tgl

	-- Start button
	local b1 = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	b1:SetText("Start")
	b1:SetSize(100,25)	
	b1:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
	b1:SetScript("OnClick", function()
		addon:GetActiveModule("masterlooter"):StartSession()
		self:Disable()
	end)
	f.guildBtn = b1

	-- Cancel button
	local b2 = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	b2:SetText("Cancel")
	b2:SetSize(100,25)
	b2:SetPoint("LEFT", b1, "RIGHT", 15, 0)
	b2:SetScript("OnClick", function()
		addon:GetActiveModule("masterlooter"):EndSession()
		self:Disable()
	end)
	f.guildBtn = b2	

	local st = ST:CreateST(self.scrollCols, 5, ROW_HEIGHT, HIGHLIGHT, f)
	st.frame:SetPoint("TOPLEFT",f,"TOPLEFT",10,-40)
	--content.frame:SetBackdropColor(1,0,0,1)
	f:SetWidth(st.frame:GetWidth()+20)
	f.rows = {} -- the row data
	f.st = st

	return f
end
