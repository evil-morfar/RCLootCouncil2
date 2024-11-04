--- @type RCLootCouncil
local addon = select(2, ...)
local lwin = LibStub("LibWindow-1.1")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local name = "RCFrame"
--- @class RCFrame : Object.Minimize_Prototype, Frame, UI.embeds
--- @field content RCFrame.Content
--- @field title RCFrame.Title
--- @field Update fun(self:RCFrame)
local Object = {}
local db = {}
local scrollHandler = function(f, delta)
	if IsControlKeyDown() then
		lwin.SetScale(f,
			delta > 0 and f:GetScale() + .03 or math.min(f:GetScale() - .03), .03)
	end
end

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
--- @return RCFrame frame @The frame object.
function Object:New(parent, name, title, width, height)
	db = addon:Getdb()
	--- @type RCFrame
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
	f:SetScript("OnMouseWheel", scrollHandler)
	f:SetToplevel(true)

	self:CreateTitleFrame(f, name, title, width)
	self:CreateContentFrame(f, name, height)
	for field, obj in pairs(self.Minimize_Prototype) do f[field] = obj end

	f.Update = function(self)
		addon.Log:D("UpdateFrame", self:GetName())
		db = addon:Getdb()
		self.content:Update()
		self.title:Update()
	end
	addon.UI:RegisterForCombatMinimize(f)
	return f
end

---@param parent RCFrame
---@param name string
---@param height integer
function Object:CreateContentFrame(parent, name, height)
	---@class RCFrame.Content : Frame, BackdropTemplate
	local c = CreateFrame("Frame", "RC_UI_" .. name .. "_Content", parent, BackdropTemplateMixin and "BackdropTemplate") -- frame that contains the actual content
	c:SetFrameLevel(1)
	self:SetupBackdrop(c, db.skins[db.currentSkin], true, 256)
	c:EnableMouse(true)
	c:SetWidth(450)
	c:SetHeight(height or 325)
	c:SetPoint("TOPLEFT")
	c:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
	c:SetScript("OnMouseUp", function(self)
		local frame = self:GetParent()
		frame:StopMovingOrSizing()
		if frame:GetScale() and frame:GetLeft() and frame:GetRight() and frame:GetTop() and frame:GetBottom() then
			frame:SavePosition() -- LibWindow SavePosition has nil error rarely and randomly and I cant really find the root cause. Let's just do a nil check.
		end
	end)
	c:SetScript("OnLeave", function(this)
		-- Used if minimized while dragging the panel
		this:GetParent():StopMovingOrSizing()
	end)

	-- Hook updates to parent :SetWidth, :SetHeight
	parent:HookScript("OnSizeChanged", function(self, w, h)
		self.content:SetWidth(w)
		self.content:SetHeight(h)
	end)

	c.Update = function()
		self:SetupBackdrop(c, db.UI[name], true, 256)
	end

	parent.content = c
end

function Object:CreateTitleFrame(parent, name, title, width)
	---@class RCFrame.Title : Frame, BackdropTemplate
	local tf = CreateFrame("Frame", "RC_UI_" .. name .. "_Title", parent, BackdropTemplateMixin and "BackdropTemplate")
	tf:SetFrameLevel(2)
	self:SetupBackdrop(tf, db.skins[db.currentSkin], true, 128)
	tf:SetHeight(22)
	tf:EnableMouse()
	tf:SetMovable(true)
	tf:SetWidth(width or 250)
	tf:SetPoint("CENTER", parent, "TOP", 0, -1)
	tf:SetScript("OnMouseWheel", function(self, delta) parent:GetScript("OnMouseWheel")(parent, delta) end)
	tf:SetScript("OnMouseDown", function(self)
		self:GetParent():StartMoving()
		self:GetParent():SetToplevel(true)
	end)
	tf:SetScript("OnMouseUp", function(self) -- Get double click by trapping time betweem mouse up
		local frame = self:GetParent()
		frame:StopMovingOrSizing()
		if frame:GetScale() and frame:GetLeft() and frame:GetRight() and frame:GetTop() and frame:GetBottom() then
			frame:SavePosition() -- LibWindow SavePosition has nil error rarely and randomly and I cant really find the root cause. Let's just do a nil check.
		end
		if self.lastClick and GetTime() - self.lastClick <= 0.5 then
			self.lastClick = nil
			if frame.minimized then
				frame:Maximize()
			else
				frame:Minimize()
			end
		else
			self.lastClick = GetTime()
		end
	end)
	local tempScale = db.UI[name].scale
	local hoverTimer
	local showHelpTooltip = function()
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR_RIGHT")
		GameTooltip:AddLine(title, 1, 1, 1)
		GameTooltip:AddLine()
		GameTooltip:AddLine(L.rcframe_help, 1, 1, 1)

		GameTooltip:Show()
	end
	tf:SetScript("OnEnter", function(self)
		tempScale = self:GetScale()
		self:SetScale(self:GetScale() * 1.07)
		hoverTimer = addon:ScheduleTimer(showHelpTooltip, 1.2)
	end)
	tf:SetScript("OnLeave", function(self)
		self:SetScale(tempScale)
		addon:HideTooltip()
		addon:CancelTimer(hoverTimer)
	end)

	local text = tf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint("CENTER", tf, "CENTER")
	text:SetTextColor(1, 1, 1, 1)
	text:SetText(title)
	tf.text = text

	tf.Update = function()
		self:SetupBackdrop(tf, db.UI[name], true, 128)
	end
	parent.title = tf
end

--- Insets will be 0 if there's no border
---@param frame Frame | BackdropTemplate
---@param skinSelector table Table containing skin info. Should either be db.skins[db.currentSkin] or db.UI[name].
---@param tile boolean Wheter or not the frame should be tiled
---@param tileSize integer Defaults to 64
function Object:SetupBackdrop(frame, skinSelector, tile, tileSize)
	tileSize = tileSize or 64
	local insets = 2
	if skinSelector.border == "None" or skinSelector.border == "" then
		insets = 0
	end
	frame:SetBackdrop({
		bgFile = AceGUIWidgetLSMlists.background[skinSelector.background],
		edgeFile = AceGUIWidgetLSMlists.border[skinSelector.border],
		tile = tile,
		tileSize = tileSize,
		edgeSize = 12,
		insets = { left = insets, right = insets, top = insets, bottom = insets, },
	})
	frame:SetBackdropColor(unpack(skinSelector.bgColor))
	frame:SetBackdropBorderColor(unpack(skinSelector.borderColor))
end

---@class Object.Minimize_Prototype
Object.Minimize_Prototype = {
	minimized = false,
	autoMinimized = false,
	IsMinimized = function(frame) return frame.minimized end,
	Minimize = function(frame, auto)
		if not frame.minimized then
			frame.content:Hide()
			frame.autoMinimized = auto
			frame.minimized = true
			frame:SetScript("OnMouseWheel", nil)
		end
	end,
	Maximize = function(frame)
		if frame.minimized then
			frame.content:Show()
			frame.autoMinimized = false
			frame.minimized = false
			frame:SetScript("OnMouseWheel", scrollHandler)
		end
	end,
}

addon.UI:RegisterElement(Object, name)
