local _, addon = ...

local name = "Icon"
local Object = {}

-- varargs: texture
function Object:New(parent, name, texture)
   local b = addon.UI.CreateFrame("Button", parent:GetName()..name, parent)
   b:SetScript("OnLeave", addon.UI.HideTooltip)
   b:SetNormalTexture(texture or "Interface\\InventoryItems\\WoWUnknownItem01")
   b:SetSize(40,40)
   b:EnableMouse(true)
   b:RegisterForClicks("AnyUp")
	return b
end

addon.UI:RegisterElement(Object, name)
