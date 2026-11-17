--- @type RCLootCouncil
local addon = select(2, ...)

---@class ScrollingTable
---@field RegisterEvents fun(self: ScrollingTable, events : table<ScriptType, fun(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...): boolean>, fRemoveOldEvents? : boolean)
---@field SetFilter fun(self: ScrollingTable, Filter : fun(self: ScrollingTable, rowData))
---@field SetData fun(self: ScrollingTable, data: table, isMinimalDataformat: boolean)
---@field EnableSelection fun(self: ScrollingTable, bool: boolean)
---@field ClearSelection fun(self: ScrollingTable, bool: boolean)
---@field GetCell fun(self: ScrollingTable, rowData: table, col: integer)
---@field Refresh fun(self: ScrollingTable)
---@field SortData fun(self: ScrollingTable)
---@field frame Frame|BackdropTemplate
---@field data table
---@field filtered integer[]
---@field rowHeight number
---@field cols table
---@field head table
---@field scrollframe ScrollFrame

local name = "LibST"
--- @class LibST : ScrollingTable, UI.embeds, BackdropTemplate
local Object = {}

---@param parent Frame
---@param _ string
---@param scrollCols table
---@param numRows integer
---@param rowHeight number
---@param colors table?
---@return LibST
function Object:New(parent, name, scrollCols, numRows, rowHeight, colors)
	local f = LibStub("ScrollingTable"):CreateST(scrollCols, numRows, rowHeight, colors, parent)
	local db = addon:Getdb()
	f.SetBackdrop = self.SetBackdrop
	f:SetBackdrop(addon.activeSkin or db.skins[db.currentSkin])
	return f
end

function Object:SetBackdrop(skin)
	local options = skin.scrollTable
	self.frame:SetBackdrop({
		bgFile = AceGUIWidgetLSMlists.background[options.background],
		edgeFile = AceGUIWidgetLSMlists.border[options.border],
		tile = true,
		tileSize = options.tileSize or 64,
		edgeSize = options.edgeSize,
		insets = options.insets,
	})
	self.frame:SetBackdropColor(unpack(options.bgColor))
	self.frame:SetBackdropBorderColor(unpack(options.borderColor))
end

addon.UI:RegisterElement(Object, name)
