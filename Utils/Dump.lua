--- Dump.lua - A function to dump a lua value to a string.

---@class RCLootCouncil
local addon = select(2, ...)
---@class RCLootCouncil.Utils
local Utils = addon.Utils

local function TableIsArray(t)
	local i = 0
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then return false end
	end
	return true
end

--- Converts a lua value to an array of lua parseable strings.
--- Doesn't handle functions, userdata or threads.
--- Originally created by Safetee
---@param value any -- The value to convert.
---@param variableName string? -- The name of the variable, if any. Used for the first line of the output.
---@param res {}? -- The result table to append the output to. If not provided, a new table will be created.
---@param nres integer? -- The current index in the result table. If not provided, it will start at 1.
---@param indent string? -- The indentation string.
---@return integer, string[] -- The last index in the result table and the result table itself.
function Utils:DumpLuaFormat(value, variableName, res, nres, indent)
	nres = nres or 1
	indent = indent or ""
	res = res or {}
	if not res[nres] then
		res[nres] = ""
		if variableName then
			res[nres] = variableName .. " = "
		end
	end
	local valType = type(value);
	if valType == "function" then
		res[nres] = "--" .. res[nres] .. tostring(value)
	elseif valType == "number" then
		-- Known issues:
		-- I dont know how to dump NaN (Not a Number)
		-- Inprecise float number.
		if value == math.huge then
			res[nres] = res[nres] .. "math.huge"
		elseif value == -math.huge then
			res[nres] = res[nres] .. "-math.huge"
		else
			res[nres] = res[nres] .. tostring(value)
		end
	elseif valType == "string" then
		res[nres] = res[nres] .. format("%q", gsub(value, "\n", ""))
	elseif valType == "table" then
		res[nres] = res[nres] .. "{"
		if TableIsArray(value) then
			--[[
			{
				xxxx, -- [1]
				yyyy, -- [2]
			}
    	--]]
			for k, v in ipairs(value) do
				nres = nres + 1
				res[nres] = indent .. "\t"
				nres = self:DumpLuaFormat(v, nil, res, nres, indent .. "\t")
				res[nres] = res[nres] .. ", -- [" .. k .. "]"
			end
		else
			--[[
			{
				["a"] = xxxx,
				["b"] = yyyy,
			}
    	--]]
			for k, v in pairs(value) do
				nres = nres + 1
				res[nres] = indent .. "\t" .. "["
				nres = self:DumpLuaFormat(k, nil, res, nres, indent)
				res[nres] = res[nres] .. "] = "
				nres = self:DumpLuaFormat(v, nil, res, nres, indent .. "\t")
				res[nres] = res[nres] .. ","
			end
		end
		nres = nres + 1
		res[nres] = indent .. "}"
	else
		res[nres] = res[nres] .. tostring(value)
	end
	return nres, res
end
