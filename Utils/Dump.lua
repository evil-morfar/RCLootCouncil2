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


local function GetDefaultValue(default, k, parentDefault)
	if not default and not parentDefault then return nil end
	if default and default[k] ~= nil then
		return default[k]
	end
	if default and default["*"] ~= nil then
		return default["*"]
	end
	if default and default["**"] ~= nil then
		return default["**"]
	end
	if parentDefault and parentDefault["**"] and type(parentDefault["**"]) == "table" then
		if parentDefault["**"][k] ~= nil then
			return parentDefault["**"][k]
		end
		if parentDefault["**"]["*"] ~= nil then
			return parentDefault["**"]["*"]
		end
		if parentDefault["**"]["**"] ~= nil then
			return parentDefault["**"]["**"]
		end
	end
	return nil
end

local function DeepCompareAndDiff(source, default, parentDefault)
	local diff = {}
	local hasChanges = false

	for k, v in pairs(source) do
		local defV = GetDefaultValue(default, k, parentDefault)

		if type(v) == "table" then
			if type(defV) == "table" then
				local childDiff, childChanged = DeepCompareAndDiff(v, defV, default)
				if childChanged then
					diff[k] = childDiff
					hasChanges = true
				end
			else
				diff[k] = v
				hasChanges = true
			end
		else
			if v ~= defV then
				diff[k] = v
				hasChanges = true
			end
		end
	end

	return diff, hasChanges
end

--- Dumps RCLootCouncilDB.
--- Similar to DumpLuaFormat, but does not include any profile values that's equal to the default.
---@param db table
---@param varName string?
---@param res string[]?
---@param nres integer?
---@param indent string?
---@return integer, string[]
function Utils:DumpConfig(db, varName, res, nres, indent)
	if type(db) ~= "table" then
		return self:DumpLuaFormat(db, varName, res, nres, indent)
	end

	local filteredDB = {}
	for k, v in pairs(db) do
		if k == "profiles" and type(v) == "table" then
			local defaultProfile = addon.defaults and addon.defaults.profile or {}
			local profiles = {}
			for profileName, profileData in pairs(v) do
				if type(profileData) == "table" then
					profiles[profileName] = DeepCompareAndDiff(profileData, defaultProfile)
				else
					profiles[profileName] = profileData
				end
			end
			filteredDB[k] = profiles
		else
			filteredDB[k] = v
		end
	end

	return self:DumpLuaFormat(filteredDB, varName, res, nres, indent)
end
