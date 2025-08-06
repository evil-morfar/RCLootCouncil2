-- Utils.lua Utility functions for RCLootCouncil
-- Creates RCLootCouncil.Utils namespace for utility functions
-- @Author Potdisc
-- Create Date : 27/7/2018 20:49:10

---@class RCLootCouncil
local addon = select(2, ...)
--- @type RCLootCouncilLocale
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local ItemUtils = addon.Require "Utils.Item"

---@class RCLootCouncil.Utils
local Utils = {}
addon.Utils = Utils

local string, gsub, format, date, time, strsplit = string, gsub, format, date, time, strsplit
-- GLOBALS: IsInRaid, UnitGroupRolesAssigned

--- Extracts the creature id from a guid
-- @param unitguid The UnitGUID
-- @return creatureID (string) or nil if nonexistant
function Utils:ExtractCreatureID(unitguid)
	if not unitguid then return nil end
	local id = unitguid:match(".+(%b--)")
	return id and (id:gsub("-", "")) or nil
end

--- Shorthand for RCLootCouncil:HideTooltip()
-- This way we can use the function as a table reference
function Utils.HideTooltip()
	addon:HideTooltip()
end

--- Searches for a string in a tooltip lines.
--- Search text can be either a multiple string or a table of strings.
--- Searching is done with pattern matching.
---@param tooltipLines TooltipDataLine[]
---@vararg string|string[]
---@return string? #The first line that matches the search text, or nil if not found.
function Utils:FindInTooltip(tooltipLines, ...)
	---@type string[]
	local searchStrings = type(select(1, ...)) == "table" and select(1, ...) or { ..., }
	for _, line in ipairs(tooltipLines) do
		if line.type == Enum.TooltipDataLineType.None then
			for _, searchString in ipairs(searchStrings) do
				if line.leftText:find(searchString) then
					return line.leftText
				end
			end
		end
	end
end

function Utils:RGBToHex(r, g, b)
	return string.format("%02x%02x%02x", 255 * r, 255 * g, 255 * b)
end

function Utils:GetAnnounceChannel(channel)
	return channel == "group" and (IsInRaid() and "RAID" or "PARTY") or channel
end

function Utils:GetPlayerRole()
	return UnitGroupRolesAssigned("player")
end

function Utils:TranslateRole(role)
	return (role and role ~= "") and _G[role] or ""
end

--- Calculates how long ago a given date was.
--- @param oldDate string A string specifying the date, formatted as "yyyy/mm/dd".
function Utils:GetNumberOfDaysFromNow(oldDate)
	local y, m, d = self:DateSplit(oldDate)
	local sinceEpoch = time({ year = y, month = m, day = d, hour = 0, }) -- convert from string to seconds since epoch

	return ConvertSecondsToUnits(GetServerTime() - (sinceEpoch or 0)).days
end

--- Takes the return value from :GetNumberOfDaysFromNow() and converts it to text.
--- @see Utils:GetNumberOfDaysFromNow
--- @param day number
--- @param month number
--- @param year number
--- @return string #A formatted string.
function Utils:ConvertDateToString(day, month, year)
	local text = format(L["x days"], day)
	if year > 0 then
		text = format(L["days, x months, y years"], text, month, year)
	elseif month > 0 then
		text = format(L["days and x months"], text, month)
	end
	return text;
end

--- Breaks an ISO date into it's components
---@param date string Date in the format "yyyy/mm/dd"
---@return number year, number month, number day
function Utils:DateSplit(date)
	local y, m, d = strsplit("/", date, 3)
	return tonumber(y or 1), tonumber(m or 1), tonumber(d or 1)
end

--- Returns the number of available spaces in the players bags
function Utils:GetNumFreeBagSlots()
	local result = 0
	for i = 1, _G.NUM_BAG_SLOTS do
		result = result + (addon.C_Container.GetContainerNumFreeSlots(i))
	end
	return result
end

function Utils:IsInNonInstance()
	local instance_type = select(2, IsInInstance())
	if self:IsPartyLFG() or instance_type == "pvp" or instance_type == "arena" then
		return true
	else
		return false
	end
end

--- Removes corruption ID from a weapon.
-- A hotfix made it so bonusID 6513 is added to corrupted weapons after they're looted,
-- which causes :ItemIsItem to fail.
-- This function removes this id, but doesn't alter the numBonuses value.
-- Note: This will remove all occurances of ":6513:", but it shouldn't really matter afaik.
function Utils:DiscardWeaponCorruption(itemLink)
	return itemLink and gsub(itemLink, ":6513:", ":") or itemLink
end

--- Checks if the item is in our blacklist
-- TODO Should be moved to it's own class in the future
--- @param item string Any valid input for *C_Item.GetItemInfoInstant()*
--- @return boolean #True if the item is blacklisted
function Utils:IsItemBlacklisted(item)
	if not item then return false end
	local itemId, _, _, _, _, itemClassID, itemsubClassID = C_Item.GetItemInfoInstant(item)
	if not (itemClassID and itemsubClassID) then return false end
	if addon.blacklistedItemClasses[itemClassID] then
		if addon.blacklistedItemClasses[itemClassID].all or addon.blacklistedItemClasses[itemClassID][itemsubClassID] then
			if addon.blackListOverride[itemId] then return false end
			return true
		end
	end
	return false
end

--- Checks for outdated versions.
---@param baseVersion string
---@param newVersion string
---@param basetVersion string
---@param newtVersion string
---@return VersionCodes
function Utils:CheckOutdatedVersion(baseVersion, newVersion, basetVersion, newtVersion)
	baseVersion = baseVersion or addon.version
	if strfind(newVersion, "%a+") then return addon.Log:E("Someone's tampering with version?", newVersion) end

	if newtVersion and not basetVersion then
		return addon.VER_CHECK_CODES[1] -- Don't treat test versions as the latest
	elseif addon:VersionCompare(baseVersion, newVersion) then
		return addon.VER_CHECK_CODES[2] -- Outdated
	elseif basetVersion and newtVersion and basetVersion < newtVersion then
		return addon.VER_CHECK_CODES[3] -- tVersion outdated
	elseif basetVersion and not newtVersion and baseVersion == newVersion then
		return addon.VER_CHECK_CODES[2] -- Test version got released
	else
		return addon.VER_CHECK_CODES[1] -- All fine
	end
end

--- Returns 1 if the given player has an older version than `version`, otherwise 0.
--- Disregards players using test versions.
local checkVersion = function(name, version, strict)
	local tChk = time() - 86400 -- Must be newer than 1 day
	local data = addon.db.global.verTestCandidates[name]
	if not data then return strict and 1 or 0 end
	if not data[2] and addon:VersionCompare(data[1], version) then
		-- Inverted since we don't want to include those we haven't recently registered,
		-- unless strict is set.
		if data[3] < tChk then
			return strict and 1 or 0
		end
		return 1
	end
	return 0
end

--- Checks if everyone in our group has `version` or never installed.
--- Assumes we are on the requested version or newer.
--- If we don't have a record of a players version, we pretend they're on the latest.
---@param version string Version string, e.g. "3.0.1"
---@param strict boolean? When true, counts players with no record or older than 24 hour as outdated.
function Utils:GroupHasVersion(version, strict)
	if not IsInGroup() then return true end
	local i = 0
	for name in pairs(addon.candidatesInGroup) do
		i = i + checkVersion(name, version, strict)
	end
	return i == 0
end

--- Checks if a list of Players has a specific version.
---@param players Player[]
---@param version string Version string, e.g. "3.0.1"
---@param strict boolean? When true, counts players with no record or older than 24 hour as outdated.
function Utils:PlayersHasVersion(players, version, strict)
	local i = 0
	for _, player in ipairs(players) do
		i = i + checkVersion(player.name, version, strict)
	end
	return i == 0
end

---@param player string|Player Name or player object
---@param version string Version string, e.g. "3.0.1"
function Utils:PlayerHasVersion(player, version)
	return checkVersion(type(player) == "string" and player or player.name, version) == 0
end

function Utils:GuildRoster()
	if _G.GuildRoster then
		return _G.GuildRoster()
	else
		return C_GuildInfo.GuildRoster()
	end
end

--- Upvalued for Classic overwrite
function Utils:GetNumClasses()
	return _G.GetNumClasses and GetNumClasses() or _G.MAX_CLASSES
end

function Utils:IsPartyLFG()
	return IsPartyLFG and IsPartyLFG()
end

function Utils:GetNumSpecializationsForClassID(classID)
	return _G.GetNumSpecializationsForClassID and _G.GetNumSpecializationsForClassID(classID) or 3
end

Utils.unitNameLookup = {}
---@param key string
---@param name string
local function cacheUnitName(key, name)
	local find = strfind(name, "-", nil, true)
	if find and find < #name then
		Utils.unitNameLookup[key] = name
	end
	return name
end

--- Gets a unit's name formatted with realmName.
--- If the unit contains a '-' it's assumed it belongs to the realmName part.
--- Note: If 'unit' is a playername, that player must be in our raid or party!
--- @param input_unit string @Any unit, except those that include '-' like "name-target".
--- @return string @Titlecased "unitName-realmName"
function Utils:UnitName(input_unit)
	if self.unitNameLookup[input_unit] then return self.unitNameLookup[input_unit] end
	if not input_unit or input_unit == "" then return "" end
	-- First strip any spaces
	local unit = gsub(input_unit, " ", "")
	-- Then see if we already have a realm name appended
	local find = strfind(unit, "-", nil, true)
	if find and find < #unit then -- "-" isn't the last character
		-- Let's give it same treatment as below so we're sure it's the same
		local name, realm = strsplit("-", unit, 2)
		name = name:lower():gsub("^%l", string.upper)
		return cacheUnitName(input_unit, name .. "-" .. realm)
	elseif find and find == #unit then -- trailing '-'
		unit = string.sub(unit, 1, -2)
	end
	-- Apparently functions like GetRaidRosterInfo() will return "real" name, while UnitName() won't
	-- always work with that (see ticket #145). We need this to be consistant, so just lowercase the unit:
	unit = unit:lower()
	-- Proceed with UnitName()
	local name, realm = UnitName(unit)
	if not realm or realm == "" then realm = addon.realmName or "" end -- Extract our own realm
	if not name then                                                -- if the name isn't set then UnitName couldn't parse unit, most likely because we're not grouped.
		name = unit
	end                                                             -- Below won't work without name
	-- We also want to make sure the returned name is always title cased (it might not always be! ty Blizzard)
	name = name:lower():gsub("^%l", string.upper)
	return cacheUnitName(input_unit, name and name .. "-" .. realm)
end

--- Creates Name-Realm based off seperate name and realm.
--- @param name string name
--- @param realm string realm
--- @return string @The combined name-realm passed straight to `Utils:UnitName`
function Utils:UnitNameFromNameRealm(name, realm)
	if strfind(name, "-", nil, true) then
		-- Realm name's probably attached, pass it on
		return self:UnitName(name)
	end
	realm = (not realm or realm == "") and select(2, UnitFullName("player")) or realm
	return self:UnitName(name .. "-" .. realm)
end

--- Custom, better UnitIsUnit() function.
-- Blizz UnitIsUnit() doesn't know how to compare unit-realm with unit.
-- Seems to be because unit-realm isn't a valid unitid.
---@param unit1 string | Player
---@param unit2 string | Player
function Utils:UnitIsUnit(unit1, unit2)
	if not unit1 or not unit2 then return false end
	if unit1.name then unit1 = unit1.name end
	if unit2.name then unit2 = unit2.name end
	-- Remove realm names, if any
	if strfind(unit1, "-", nil, true) ~= nil then
		unit1 = Ambiguate(unit1, "short")
	end
	if strfind(unit2, "-", nil, true) ~= nil then
		unit2 = Ambiguate(unit2, "short")
	end
	-- v2.3.3 There's problems comparing non-ascii characters of different cases using UnitIsUnit()
	-- I.e. UnitIsUnit("Potdisc", "potdisc") works, but UnitIsUnit("Æver", "æver") doesn't.
	-- Since I can't find a way to ensure consistant returns from UnitName(), just lowercase units here before passing them.
	return UnitIsUnit(unit1:lower(), unit2:lower())
end

--- Returns the current loot threshold.
--- @return integer @The current loot threshold.
function Utils:GetLootThreshold()
	-- Retail
	if WOW_PROJECT_MAINLINE == WOW_PROJECT_ID then
		return addon.MIN_LOOT_THRESHOLD -- Consider making this an option
	else
		return GetLootThreshold() or 1
	end
end

--- Returns true if the target can receive addon messages from the whisper channel.
---@param target Player
function Utils:IsWhisperTarget(target)
	if not target:GetGUID() then return false end
	return C_PlayerInfo.UnitIsSameServer(_G.PlayerLocation:CreateFromGUID(target:GetGUID()))
end

--- Creates a table containing everything in 't' that is different from 'base'.
--- Empty table values are not included.
---@param base table
---@param t table
function Utils:GetTableDifference(base, t)
	local ret = {}
	for k, v in pairs(t) do
		if base[k] == nil or base[k] ~= v then
			if type(v) == "table" then
				ret[k] = Utils:GetTableDifference(base[k] or {}, v)
				if not next(ret[k]) then
					ret[k] = nil
				end
			else
				ret[k] = v
			end
		end
	end
	return ret
end

--- Converts an integer into a binary string
---@param n integer Number to convert
function Utils:Int2Bin(n)
	local result = ""
	while n ~= 0 and n do
		if n % 2 == 0 then
			result = "0" .. result
		else
			result = "1" .. result
		end
		n = math.floor(n / 2)
	end
	return string.format("%04s", result)
end

---@deprecated
---@see Utils.Item.GetTransmittableItemString
function Utils:GetTransmittableItemString(link)
	return ItemUtils:GetTransmittableItemString(link)
end

---@deprecated
---@see Utils.Item.GetItemStringClean
function Utils:GetItemStringClean(link)
	return ItemUtils:GetItemStringClean(link)
end

---@deprecated
---@see Utils.Item.UncleanItemString
function Utils:UncleanItemString(itemString)
	return ItemUtils:UncleanItemString(itemString)
end

---@deprecated
---@see Utils.Item.GetItemNameFromLink
function Utils:GetItemNameFromLink(link)
	return ItemUtils:GetItemNameFromLink(link)
end

---@deprecated
---@see Utils.Item.GetItemIDFromLink
function Utils:GetItemIDFromLink(link)
	return ItemUtils:GetItemIDFromLink(link)
end

---@deprecated
---@see Utils.Item.GetItemStringFromLink
function Utils:GetItemStringFromLink(link)
	return ItemUtils:GetItemStringFromLink(link)
end

---@deprecated
---@see Utils.Item.GetItemTextWithCount
function Utils:GetItemTextWithCount(link, count)
	return ItemUtils:GetItemTextWithCount(link, count)
end

--- Removes any character specific data from an item
--- @param item string Any itemlink, itemstring etc.
--- @return string #The same item with level, specID, uniqueID removed
---@deprecated
---@see Utils.Item.NeutralizeItem
function Utils:NeutralizeItem(item)
	return ItemUtils:NeutralizeItem(item)
end

---@deprecated v3.13.0: No longer does anything
function Utils:GetItemLevelText(ilvl)
	if not ilvl then return "" end
	return ilvl
end
