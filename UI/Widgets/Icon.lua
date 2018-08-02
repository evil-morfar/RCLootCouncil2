local _, addon = ...

local name = "Icon"
local Object = {}

-- varargs: texture
function Object:New(parent, name, texture)
   local b = addon.UI:NewNamed("Button", parent, name) -- Inherit button
   b:SetScript("OnLeave", addon.UI.HideTooltip)
   b:SetNormalTexture(texture or "Interface\\InventoryItems\\WoWUnknownItem01")
   b:SetSize(40,40)
	return b
end

addon.UI:RegisterElement(Object, name)
