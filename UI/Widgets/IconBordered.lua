local _, addon = ...

local name = "IconBordered"
local Object = {}

-- varargs: texture
function Object:New(parent, name, texture)
   local b = addon.UI:NewNamed("Icon", parent, texture) -- Inherit icon
   b:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 18,
	})

   b.SetTextColor = self.SetBorderColor
	return b
end

function Object:SetBorderColor(color)
   if color == "green" then
      self:SetBackdropBorderColor(0,1,0,1) -- green
   	self:GetNormalTexture():SetVertexColor(0.8,0.8,0.8)
   elseif color == "yellow" then
      self:SetBackdropBorderColor(1,1,0,1) -- yellow
		self:GetNormalTexture():SetVertexColor(1,1,1)
   else -- Default to white
      self:SetBackdropBorderColor(1,1,1,1) -- white
		self:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
   end
end

addon.UI:RegisterElement(Object, name)
