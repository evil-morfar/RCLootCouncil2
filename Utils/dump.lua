-- dump.lua Dump stuffs in saved variable format
-- @author Safetee
-- Create Date: Dec/6/2017

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local AG = LibStub("AceGUI-3.0")

local ipairs = ipairs
local math = math
local pairs = pairs
local string_format = string.format
local tostring = tostring
local type = type

--@return true if the table t is an array.
local function TableIsArray(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then return false end
  end
  return true
end

-- Dump stuffs in LUA format. Try to be as similar to Blizzard saved variable.
--@param val: The variable to be dumped
--@param variableName: if supplied, will export as  variableName = xxxxx
--@param res: Table to store the result at the each line
--@param nres: Optional. The current line number.
--@param indent: Optional. Current indentation
--@return the last line number of the dump text, and "res"
-- Note that you need to table.contant(res, '\n') to get the final result.
function RCLootCouncil:DumpLuaFormat(val, variableName, res, nres, indent)
	nres = nres or 1
	indent = indent or ""
	if not res[nres] then
		res[nres] = ""
		if variableName then
			res[nres] = variableName.." = "
		end
	end
    local valType = type(val);
    if valType ~= "number" and valType ~= "string" and valType ~= "table" then
    	res[nres] = res[nres]..tostring(val)
    elseif valType == "number" then
    	-- Known issues: 
    	-- I dont know how to dump NaN (Not a Number)
    	-- Inprecise float number.
    	if val == math.huge then
    		res[nres] = res[nres].."math.huge"
    	elseif val == -math.huge then
    		res[nres] = res[nres].."-math.huge"
    	else
    		res[nres] = res[nres]..tostring(val)
    	end
    elseif valType == "string" then
    	res[nres] = res[nres]..string_format("%q", val)
    else -- "table"
    	res[nres] = res[nres].."{"
    	if TableIsArray(val) then
    	--[[
			{
				xxxx, -- [1]
				yyyy, -- [2]
			}
    	--]]
    		for k, v in ipairs(val) do
    			nres = nres + 1
    			res[nres] = indent.."\t"
    			nres = self:DumpLuaFormat(v, nil, res, nres, indent.."\t")
    			res[nres] = res[nres]..", -- ["..k.."]"
    		end
    	else
    	--[[
			{
				["a"] = xxxx,
				["b"] = yyyy,
			}
    	--]]
    		for k, v in pairs(val) do
    			nres = nres + 1
    			res[nres] = indent.."\t".."["
    			nres = self:DumpLuaFormat(k, nil, res, nres, indent)
    			res[nres] = res[nres].."] = "
    			nres = self:DumpLuaFormat(v, nil, res, nres, indent.."\t")
    			res[nres] = res[nres]..","
    		end
    	end
    	nres = nres + 1
    	res[nres] = indent.."}"
    end
    return nres, res
end

function RCLootCouncil:DumpSavedVariables()
	local res = {}
	res[1] = "" -- Blizzard Saved variable file starts with new line.
	local nres, res = self:DumpLuaFormat(RCLootCouncilDB, "RCLootCouncilDB", res, 2)
	local nres, res = self:DumpLuaFormat(RCLootCouncilLootDB, "RCLootCouncilLootDB", res, nres+1)
	return nres, res
end

-- Export text for copy & paste.
-- Currently redundant with the code in LootHistory.
-- Should simplify the code in LootHistory later.
do 
	-- Export frame
	local exportFrame = AG:Create("Window")
	exportFrame:SetLayout("List")
	exportFrame:SetWidth(700)
	exportFrame:SetHeight(360)
	exportFrame:Hide()

	exportFrame.desc = AG:Create("Label")
	exportFrame.desc:SetRelativeWidth(1)
	exportFrame:AddChild(exportFrame.desc)
	
	exportFrame.edit = AG:Create("MultiLineEditBox")
	exportFrame.edit:SetNumLines(20)
	exportFrame.edit:SetFullWidth(true)
	exportFrame.edit:SetLabel("")
	exportFrame:AddChild(exportFrame.edit)

	-- Frame for huge export. Use single line editbox to avoid freezing.
	local hugeExportFrame = AG:Create("Window")
	hugeExportFrame:SetLayout("List")
	hugeExportFrame:SetWidth(700)
	hugeExportFrame:SetHeight(100)
	hugeExportFrame:Hide()

	hugeExportFrame.desc = AG:Create("Label")
	hugeExportFrame.desc:SetRelativeWidth(1)
	hugeExportFrame:AddChild(hugeExportFrame.desc)

	hugeExportFrame.edit = AG:Create("EditBox")
	hugeExportFrame.edit:SetFullWidth(true)
	hugeExportFrame.edit:SetMaxLetters(0)
	hugeExportFrame.edit:SetLabel("")
	hugeExportFrame:AddChild(hugeExportFrame.edit)

	--@param text: The text to export
	--@param title: Optional. The title of the frame.
	--@param desc: The description. Long word is wraped.
	function RCLootCouncil:ExportText(text, title, desc)
		if text:len() < 40000 then
			exportFrame:Show()
			exportFrame:SetTitle(title or "")
			exportFrame.desc:SetText(desc or "")
			exportFrame.edit:SetCallback("OnTextChanged", function(self)
				self:SetText(text)
			end)
			exportFrame.edit:SetText(text)
			exportFrame.edit:SetFocus()
			exportFrame.edit:HighlightText()
		else -- Use hugeExportFrame(Single line editBox) for large export to avoid freezing the game.
			hugeExportFrame:Show()
			hugeExportFrame:SetTitle(title or "")
			hugeExportFrame.desc:SetText(desc or "")
			hugeExportFrame.edit:SetCallback("OnTextChanged", function(self)
				self:SetText(text)
			end)
			hugeExportFrame.edit:SetText(text)
			hugeExportFrame.edit:SetFocus()
			hugeExportFrame.edit:HighlightText()
		end

	end

end
