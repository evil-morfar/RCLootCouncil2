--- @type RCLootCouncil
local addon = select(2, ...)

local name = "Icon"
--- @class Icon  : BackdropTemplate, Button, UI.embeds
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
