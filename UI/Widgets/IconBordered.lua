--- @type RCLootCouncil
local addon = select(2, ...)

local name = "IconBordered"
--- @class IconBordered : BackdropTemplate, Button, UI.embeds
local Object = {}

-- varargs: texture
function Object:New(parent, name, texture)
	local b = addon.UI.CreateFrame("Button", name, parent, "BackdropTemplate")
	b.SetBorderColor = self.SetBorderColor
	b.Desaturate = self.Desaturate
	b.Init = self.Init
	b:Init(texture)
	return b
end

function Object:Init(texture)
	self:SetSize(40, 40)
	self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	self:GetHighlightTexture():SetBlendMode("ADD")
	self:SetNormalTexture(texture or "Interface\\InventoryItems\\WoWUnknownItem01")
	self:GetNormalTexture():SetDrawLayer("BACKGROUND")
	self:GetNormalTexture():SetVertexColor(1, 1, 1)
	self:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 18,
	})
	self:SetScript("OnLeave", addon.UI.HideTooltip)
	self:EnableMouse(true)
	self:RegisterForClicks("AnyUp")
end

function Object:SetBorderColor(color)
   if color == "green" then
      self:SetBackdropBorderColor(0,1,0,1) -- green
      self:GetNormalTexture():SetVertexColor(0.8,0.8,0.8)
   elseif color == "yellow" then
      self:SetBackdropBorderColor(1,1,0,1) -- yellow
		self:GetNormalTexture():SetVertexColor(1,1,1)
   elseif color == "grey" or color == "gray" then
      self:SetBackdropBorderColor(0.75,0.75,0.75,1)
      self:GetNormalTexture():SetVertexColor(1,1,1)
   elseif color == "red" then
      self:SetBackdropBorderColor(1,0,0,1)
      self:GetNormalTexture():SetVertexColor(1,1,1)
   elseif color == "purple" then
      self:SetBackdropBorderColor(0.65,0.4,1,1)
      self:GetNormalTexture():SetVertexColor(1,1,1)
   else -- Default to white
      self:SetBackdropBorderColor(1,1,1,1) -- white
		self:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
   end
end

function Object:Desaturate()
   return self:GetNormalTexture():SetDesaturated(true)
end

addon.UI:RegisterElement(Object, name)
