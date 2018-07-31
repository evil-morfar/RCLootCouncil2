local _, addon = ...

local name = "Icon"
local Object = {}

-- varargs: texture
function Object:New(parent, name, texture)
   local b = addon.UI:NewNamed("Button", parent, name) -- Inherit button
   b:SetScript("OnLeave", addon.UI.HideTooltip)
   b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
   b:GetHighlightTexture():SetBlendMode("ADD")
   b:SetNormalTexture(texture or "Interface\\InventoryItems\\WoWUnknownItem01")
   b:GetNormalTexture():SetDrawLayer("BACKGROUND")
   b:SetSize(40,40)
	return b
end

addon.UI:RegisterElement(Object, name)
