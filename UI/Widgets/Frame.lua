-- TODO: Support combat autohide

local _, addon = ...
local lwin = LibStub("LibWindow-1.1")

local name = "Frame"
local Object = {
   frames = {}
}
local db = {}

--- Creates a standard frame for addon with title, minimizing, positioning and scaling supported.
--		Adds Minimize(), Maximize() and IsMinimized() functions on the frame, and registers it for hide on combat.
--		SetWidth/SetHeight called on frame will also be called on frame.content.
--		Minimizing is done by double clicking the title. The returned frame and frame.title is NOT hidden.
-- 	Only frame.content is minimized, so put children there for minimize support.
--- @param parent Frame | UIParent @Parent of the new frame
--- @param name string @Global name of the frame.
--- @param title string @The title text.
--- @param width? integer @The width of the titleframe, defaults to 250.
--- @param height? integer @Height of the frame, defaults to 325.
--- @return table frame @The frame object.
function Object:New (parent, name, title, width, height)
   db = addon:Getdb()
   local f = CreateFrame("Frame", name, parent) -- LibWindow seems to work better with nil parent
	f:Hide()
	f:SetFrameStrata("DIALOG")
	f:SetWidth(450)
	f:SetHeight(height or 325)
	f:SetScale(db.UI[name].scale or 1.1)
	lwin:Embed(f)
	f:RegisterConfig(db.UI[name])
	f:RestorePosition() -- might need to move this to after whereever GetFrame() is called
	f:MakeDraggable()
	f:SetScript("OnMouseWheel", function(f,delta) if IsControlKeyDown() then lwin.OnMouseWheel(f,delta) end end)
	f:SetToplevel(true)

	self:CreateTitleFrame(f, name, title, width)
   self:CreateContentFrame (f, name, height)
   for field, obj in pairs(self.Minimie_Prototype) do
      f[field] = obj
   end

	f.Update = function(self)
		addon.Log:D("UpdateFrame", self:GetName())
      self.content:Update()
		self.title:Update()
	end
   addon.UI:RegisterForCombatMinimize (f)
	return f
end

function Object:CreateContentFrame (parent, name, height)
   local c = CreateFrame("Frame", "RC_UI_"..name.."_Content", parent, BackdropTemplateMixin and "BackdropTemplate") -- frame that contains the actual content
	 c:SetFrameLevel(1)
	 c:SetBackdrop({
		bgFile = AceGUIWidgetLSMlists.background[db.skins[db.currentSkin].background],
		edgeFile = AceGUIWidgetLSMlists.border[db.skins[db.currentSkin].border],
	   tile = true, tileSize = 255, edgeSize = 16,
	   insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	c:EnableMouse(true)
	c:SetWidth(450)
	c:SetHeight(height or 325)
	c:SetBackdropColor(unpack(db.skins[db.currentSkin].bgColor))
	c:SetBackdropBorderColor(unpack(db.skins[db.currentSkin].borderColor))
	c:SetPoint("TOPLEFT")
	c:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
	c:SetScript("OnMouseUp", function(self)
		local frame = self:GetParent()
		frame:StopMovingOrSizing()
		if frame:GetScale() and frame:GetLeft() and frame:GetRight() and frame:GetTop() and frame:GetBottom() then
			frame:SavePosition() -- LibWindow SavePosition has nil error rarely and randomly and I cant really find the root cause. Let's just do a nil check.
		end
	end)

   -- Hook updates to parent :SetWidth, :SetHeight
   parent:HookScript("OnSizeChanged", function(self, w, h)
      self.content:SetWidth(w)
      self.content:SetHeight(h)
   end)

   c.Update = function()
      c:SetBackdrop({
			bgFile = AceGUIWidgetLSMlists.background[db.UI[name].background],
			edgeFile = AceGUIWidgetLSMlists.border[db.UI[name].border],
			tile = false, tileSize = 64, edgeSize = 12,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
      c:SetBackdropColor(unpack(db.UI[name].bgColor))
		c:SetBackdropBorderColor(unpack(db.UI[name].borderColor))
   end

	parent.content = c
end

function Object:CreateTitleFrame (parent, name, title, width)
   local tf = CreateFrame("Frame", "RC_UI_"..name.."_Title", parent, BackdropTemplateMixin and "BackdropTemplate")
	tf:SetFrameLevel(2)
	tf:SetBackdrop({
		bgFile = AceGUIWidgetLSMlists.background[db.skins[db.currentSkin].background],
		edgeFile = AceGUIWidgetLSMlists.border[db.skins[db.currentSkin].border],
     tile = true, tileSize = 16, edgeSize = 12,
      insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	tf:SetBackdropColor(unpack(db.skins[db.currentSkin].bgColor))
	tf:SetBackdropBorderColor(unpack(db.skins[db.currentSkin].borderColor))
	tf:SetHeight(22)
	tf:EnableMouse()
	tf:SetMovable(true)
	tf:SetWidth(width or 250)
	tf:SetPoint("CENTER",parent,"TOP",0,-1)
	tf:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() self:GetParent():SetToplevel(true) end)
	tf:SetScript("OnMouseUp", function(self) -- Get double click by trapping time betweem mouse up
		local frame = self:GetParent()
		frame:StopMovingOrSizing()
		if frame:GetScale() and frame:GetLeft() and frame:GetRight() and frame:GetTop() and frame:GetBottom() then
			frame:SavePosition() -- LibWindow SavePosition has nil error rarely and randomly and I cant really find the root cause. Let's just do a nil check.
		end
		if self.lastClick and GetTime() - self.lastClick <= 0.5 then
			self.lastClick = nil
			if frame.minimized then frame:Maximize() else frame:Minimize() end
		else
			self.lastClick = GetTime()
		end
	end)

	local text = tf:CreateFontString(nil,"OVERLAY","GameFontNormal")
	text:SetPoint("CENTER",tf,"CENTER")
	text:SetTextColor(1,1,1,1)
	text:SetText(title)
	tf.text = text

   tf.Update = function(self)
      self:SetBackdrop({
			bgFile = AceGUIWidgetLSMlists.background[db.UI[name].background],
			edgeFile = AceGUIWidgetLSMlists.border[db.UI[name].border],
			tile = false, tileSize = 64, edgeSize = 12,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		self:SetBackdropColor(unpack(db.UI[name].bgColor))
		self:SetBackdropBorderColor(unpack(db.UI[name].borderColor))
   end
   parent.title = tf
end

Object.Minimie_Prototype = {
	minimized = false,
	autoMinimized = false,
	IsMinimized = function(frame)
		return frame.minimized
	end,
	Minimize = function(frame, auto)
		if not frame.minimized then
			frame.content:Hide()
			frame.autoMinimized = auto
			frame.minimized = true
		end
	end,
	Maximize = function(frame)
		if frame.minimized then
			frame.content:Show()
			frame.autoMinimized = false
			frame.minimized = false
		end
	end
}

addon.UI:RegisterElement(Object, name)
