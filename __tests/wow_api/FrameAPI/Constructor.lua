require "FrameAPI/Frames/Frame"
require "FrameAPI/Frames/Button"
require "FrameAPI/Frames/CheckButton"
require "FrameAPI/Frames/GameTooltip"
require "FrameAPI/Frames/Editbox"
require "FrameAPI/Frames/StatusBar"
require "FrameAPI/Frames/Slider"
require "FrameAPI/Frames/ScrollFrame"

local Templates = {}

local frameConstructors = {
	Frame = _G.Frame.New,
	Button = _G.Button.New,
	CheckButton = _G.CheckButton.New,
	GameTooltip = _G.GameTooltipFrame.New,
	EditBox = _G.EditBox.New,
	StatusBar = _G.StatusBar.New,
	Slider = _G.Slider.New,
	ScrollFrame = _G.ScrollFrame.New,
}

--- Creates a new frame of the given type.
function FrameConstructor(kind, name, parent, templates, ...)
	local constructor = frameConstructors[kind]
	if not constructor then
		-- Default to frame (for handling kinds we haven't implemented)
		constructor = frameConstructors.Frame
	end
	local frame = constructor(name, parent, ...)
	if not templates then return frame end

	local multipleTemplates
	if string.find(templates, ", ") then
		multipleTemplates = { string.split(", ", templates), }
	end
	-- Setup Templates
	for _, template in ipairs(multipleTemplates or { templates, }) do
		if not Templates[template] then
			error("No template found for: ".. template)
			print(debugstack(-5))
			return frame
		end
		frame = Templates[template](frame, name)
	end
	return frame
end

Templates.UIDropDownMenuTemplate = function(object, name)
	local texture = [[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]]
	_G[name .. "Left"] = object:CreateTexture(texture, "ARTWORK")
	_G[name .. "Middle"] = object:CreateTexture(texture, "ARTWORK")
	_G[name .. "Right"] = object:CreateTexture(texture, "ARTWORK")
	_G[name .. "Text"] = object:CreateFontString("")
	_G[name .. "Button"] = _G.Button.New(name .. "Button", object)
	return object
end

Templates.CheckButton = function(object, name)
	return object                                                       -- Should all be handled by CheckButton.lua
end
Templates.Button = function(object, name) return object end             -- Should all be handled by Button.lua
Templates.UIPanelCloseButton = function(object, name) return object end -- Should all be handled by Button.lua
Templates.GameTooltipTemplate = function(object, name)
	return object                                                       -- Handled by GameTooltip
end
Templates.GameToolTip = Templates.GameTooltipTemplate
Templates.ShoppingTooltipTemplate = Templates.GameTooltipTemplate
Templates.BackdropTemplate = function(object, name)
	return object -- nothing really interesting here
end

Templates.DialogBorderOpaqueTemplate = function(object, name)
	_G[name .. "Bg"] = object:CreateTexture(nil, "BACKGROUND")
	return object
end

Templates.ScrollFrameTemplate = function(object, name)
	-- Lot's of stuff created, trying to avoid recreating everything
	return object
end

Templates.ScrollFrame = Templates.ScrollFrameTemplate
Templates.FauxScrollFrameTemplate = Templates.ScrollFrameTemplate -- No differences we care about for now

Templates.UIPanelButtonTemplate = function(object, name)
	return object -- Only OnEnter/OnLeave created here.
end

Templates.ChatConfigCheckButtonTemplate = function(object, name) return object end -- Nothing important


Templates.TextStatusBar = function(object, name) return object end
Templates.AutoCompleteEditBoxTemplate = function(object, name) return object end
