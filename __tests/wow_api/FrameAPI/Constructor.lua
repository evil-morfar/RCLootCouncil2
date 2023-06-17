require "/wow_api/FrameAPI/Frames/Frame"
require "/wow_api/FrameAPI/Frames/Button"
require "/wow_api/FrameAPI/Frames/CheckButton"
require "/wow_api/FrameAPI/Frames/GameTooltip"
require "/wow_api/FrameAPI/Frames/Editbox"
require "/wow_api/FrameAPI/Frames/StatusBar"


local frameConstructors = {
	Frame = _G.Frame.New,
	Button = _G.Button.New,
	CheckButton = _G.CheckButton.New,
	GameTooltip = _G.GameTooltipFrame.New,
	EditBox = _G.EditBox.New,
	StatusBar = _G.StatusBar.New,
}

--- Creates a new frame of the given type.
function FrameConstructor(kind, name, parent, ...)
	local constructor = frameConstructors[kind]
	if not constructor then
		-- Default to frame (for handling kinds we haven't implemented)
		constructor = frameConstructors.Frame
	end
	return constructor(name, parent, ...)
end