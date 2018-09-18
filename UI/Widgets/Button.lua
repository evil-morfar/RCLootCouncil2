local _, addon = ...

local name = "Button"
local Object = {}

function Object:New(parent, name)
   local b = addon.UI.CreateFrame("Button", parent:GetName()..name, parent, "UIPanelButtonTemplate")
	b:SetText("")
	b:SetSize(100,25)
	return b
end

addon.UI:RegisterElement(Object, name)
