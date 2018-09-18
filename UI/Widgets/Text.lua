local _, addon = ...

local name = "Text"
local Object = {}

function Object:New(parent, name, text)
   local f = addon.UI.CreateFrame("frame", name, parent)
   local t = f:CreateFontString(name:GetName().."_Text", "OVERLAY", "GameFontNormal")
   t:SetPoint("CENTER")
   t:SetText(text)
   -- Some functions should handle both
   f.SetText = t.SetText
   f.SetTextColor = t.SetTextColor
   local height, width = f.SetHeight, f.SetWidth

   function f:SetHeight (h)
      height(self,h)
      t:SetHeight(h)
   end
   function f:SetWidth(w)
      width(self, w)
      t:SetWidth(w)
   end
   return f
end

addon.UI:RegisterElement(Object, name)
