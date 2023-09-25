--- @type RCLootCouncil
local addon = select(2, ...)

local name = "Text"
--- @class Text : BackdropTemplate, Frame, UI.embeds
--- @field text FontString
local Object = {}

function Object:New(parent, name, text)
   local f = addon.UI.CreateFrame("Frame", name, parent)
   local t = f:CreateFontString(parent:GetName().."_Text", "OVERLAY", "GameFontNormal")
   f.text = t
   t:SetPoint("CENTER")
   t:SetText(text)
   -- Upvalue some functions
   local height, width = f.SetHeight, f.SetWidth
   function f:SetHeight (h)
      height(self,h)
      t:SetHeight(h)
   end
   function f:SetWidth(w)
      width(self, w)
      t:SetWidth(w)
   end
   function f:SetTextColor(...)
      t:SetTextColor(...)
   end
   function f:SetText(...)
      t:SetText(...)
   end
   function f:GetStringWidth()
      return t:GetStringWidth()
   end
   return f
end

addon.UI:RegisterElement(Object, name)
