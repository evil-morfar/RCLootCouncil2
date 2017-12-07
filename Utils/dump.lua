-- dump.lua Dump stuffs in saved variable format
-- @author Safetee
-- Create Date: Dec/6/2017

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

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
--@param res: Table to store the result at the each line
--@param nres: Optional. The current line number.
--@param indent: Optional. Current indentation
--@return the last line number of the dump text, and "res"
function RCLootCouncil:DumpLuaFormat(val, res, nres, indent)
	nres = nres or 1
	indent = indent or ""
	if not res[nres] then
		res[nres] = ""
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
    			nres = self:DumpLuaFormat(v, res, nres, indent.."\t")
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
    			nres = self:DumpLuaFormat(k, res, nres, indent)
    			res[nres] = res[nres].."] = "
    			nres = self:DumpLuaFormat(v, res, nres, indent.."\t")
    			res[nres] = res[nres]..","
    		end
    	end
    	nres = nres + 1
    	res[nres] = indent.."}"
    end
    return nres, res
end