-- Utils.lua Utility functions for RCLootCouncil
-- Creates RCLootCouncil.Utils namespace for utility functions
-- @Author Potdisc
-- Create Date : 27/7/2018 20:49:10
---@type RCLootCouncil
local _,addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local Utils = {}
addon.Utils = Utils

local string, gsub, strmatch, tonumber, format, date, time, strsplit = string, gsub, strmatch, tonumber, format, date, time, strsplit
-- GLOBALS: IsInRaid, UnitGroupRolesAssigned

--- Extracts the creature id from a guid
-- @param unitguid The UnitGUID
-- @return creatureID (string) or nil if nonexistant
function Utils:ExtractCreatureID (unitguid)
   if not unitguid then return nil end
   local id = unitguid:match(".+(%b--)")
   return id and (id:gsub("-", "")) or nil
end

--- Shorthand for RCLootCouncil:HideTooltip()
-- This way we can use the function as a table reference
function Utils.HideTooltip()
   addon:HideTooltip()
end

function Utils:RGBToHex(r,g,b)
	return string.format("%02x%02x%02x",255*r, 255*g, 255*b)
end

function Utils:GetTransmittableItemString (link)
   return self:GetItemStringClean(self:NeutralizeItem(link))
end

function Utils:GetItemStringClean(link)
	return gsub(self:GetItemStringFromLink(link), "item:", "")
end

function Utils:UncleanItemString(itemString)
	return "item:"..itemString or "0"
end

function Utils:GetItemNameFromLink(link)
	return strmatch(link or "", "%[(.+)%]")
end

function Utils:GetAnnounceChannel(channel)
	return channel == "group" and (IsInRaid() and "RAID" or "PARTY") or channel
end

function Utils:GetItemIDFromLink(link)
	return tonumber(strmatch(link or "", "item:(%d+):"))
end

function Utils:GetItemStringFromLink(link)
	return strmatch(strmatch(link or "", "item:[%d:-]+") or "", "(item:.-):*$")
end

function Utils:GetItemTextWithCount(link, count)
	return link..(count and count > 1 and (" x"..count) or "")
end

local NEUTRALIZE_ITEM_PATTERN = "item:(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):%d*:%d*:%d*:"
local NEUTRALIZE_ITEM_REPLACEMENT = "item:%1:%2:%3:%4:%5:%6:%7::::"

--- Removes any character specific data from an item
-- @param item Any itemlink, itemstring etc.
-- @return The same item with level, specID, uniqueID removed
function Utils:NeutralizeItem (item)
	return item:gsub(NEUTRALIZE_ITEM_PATTERN, NEUTRALIZE_ITEM_REPLACEMENT)
end

function Utils:GetItemLevelText(ilvl, token)
	if not ilvl then return "" end
	if token and ilvl > 600 then -- Armor token warforged is introduced since WoD
		return ilvl.."+"
	else
		return ilvl
	end
end

function Utils:GetPlayerRole()
	return UnitGroupRolesAssigned("player")
end

function Utils:TranslateRole(role)
	return (role and role ~= "") and _G[role] or ""
end

-- REVIEW FrameXML/Utils have something like this
--- Calculates how long ago a given date was.
-- Assumes the date is of year 2000+.
-- @param oldDate A string specifying the date, formatted as "dd/mm/yy".
-- @return day, month, year.
function Utils:GetNumberOfDaysFromNow(oldDate)
	local d, m, y = strsplit("/", oldDate, 3)
	local sinceEpoch = time({year = "20"..y, month = m, day = d, hour = 0}) -- convert from string to seconds since epoch
	local diff = date("*t", math.abs(time() - sinceEpoch)) -- get the difference as a table
	-- Convert to number of d/m/y
	return diff.day - 1, diff.month - 1, diff.year - 1970
end

--- Takes the return value from :GetNumberOfDaysFromNow() and converts it to text.
-- @see RCLootCouncil:GetNumberOfDaysFromNow
-- @return A formatted string.
function Utils:ConvertDateToString(day, month, year)
	local text = format(L["x days"], day)
	if year > 0 then
		text = format(L["days, x months, y years"], text, month, year)
	elseif month > 0 then
		text = format(L["days and x months"], text, month)
	end
	return text;
end

--- Returns the number of available spaces in the players bags
function Utils:GetNumFreeBagSlots()
   local result = 0
   for i = 1, _G.NUM_BAG_SLOTS do
      result = result + (GetContainerNumFreeSlots(i))
   end
   return result
end

function Utils:IsInNonInstance()
   local instance_type = select(2, IsInInstance())
   if self.IsPartyLFG() or instance_type == "pvp" or instance_type == "arena" then
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
function Utils:DiscardWeaponCorruption (itemLink)
   return itemLink and gsub(itemLink, ":6513:", ":") or itemLink
end


--- Checks if the item is in our blacklist
-- COMBAK Should be moved to it's own class in the future
-- @param item Any valid input for `GetItemInfoInstant`
-- @return boolean True if the item is blacklisted
function Utils:IsItemBlacklisted(item)
   if not item then return false end
   local _,_,_,_,_,itemClassID, itemsubClassID = GetItemInfoInstant(item)
   if not (itemClassID and itemsubClassID) then return false end
   if addon.blacklistedItemClasses[itemClassID] then
      if addon.blacklistedItemClasses[itemClassID].all or addon.blacklistedItemClasses[itemClassID][itemsubClassID] then
         return true
      end
   end
   return false
end

--- Checks for outdated versions.
function Utils:CheckOutdatedVersion (baseVersion, newVersion, basetVersion, newtVersion)
   baseVersion = baseVersion or addon.version

   if strfind(newVersion, "%a+") then return self:Debug("Someone's tampering with version?", newVersion) end

   if addon:VersionCompare(baseVersion,newVersion) then
		return addon.VER_CHECK_CODES[2] -- Outdated

	elseif basetVersion and newtVersion and basetVersion < newtVersion then
		return addon.VER_CHECK_CODES[3] -- tVersion outdated

	elseif basetVersion and not newtVersion and baseVersion == newVersion then
		return addon.VER_CHECK_CODES[2] -- Test version got released

	else

      return addon.VER_CHECK_CODES[1] -- All fine
	end
end

function Utils:GuildRoster()
   if _G.GuildRoster then
      return _G.GuildRoster()
   else
      return C_GuildInfo.GuildRoster()
   end
end

--- Upvalued for Classic overwrite
function Utils:GetNumClasses ()
   return _G.GetNumClasses and GetNumClasses() or _G.MAX_CLASSES
end

function Utils:IsPartyLFG ()
   return IsPartyLFG and IsPartyLFG()
end

function Utils:GetNumSpecializationsForClassID (classID)
   return _G.GetNumSpecializationsForClassID and _G.GetNumSpecializationsForClassID(classID) or 3
end

Utils.unitNameLookup = {}

--- Gets a unit's name formatted with realmName.
--- If the unit contains a '-' it's assumed it belongs to the realmName part.
--- Note: If 'unit' is a playername, that player must be in our raid or party!
--- @param input_unit string @Any unit, except those that include '-' like "name-target".
--- @return string @Titlecased "unitName-realmName"
function Utils:UnitName(input_unit)
   if self.unitNameLookup[input_unit] then return self.unitNameLookup[input_unit] end
   -- First strip any spaces
	local unit = gsub(input_unit, " ", "")
	-- Then see if we already have a realm name appended
	local find = strfind(unit, "-", nil, true)
	if find and find < #unit then -- "-" isn't the last character
		-- Let's give it same treatment as below so we're sure it's the same
		local name, realm = strsplit("-", unit, 2)
		name = name:lower():gsub("^%l", string.upper)
		return name.."-"..realm
	end
	-- Apparently functions like GetRaidRosterInfo() will return "real" name, while UnitName() won't
	-- always work with that (see ticket #145). We need this to be consistant, so just lowercase the unit:
	unit = unit:lower()
	-- Proceed with UnitName()
	local name, realm = UnitName(unit)
	if not realm or realm == "" then realm = addon.realmName or "" end -- Extract our own realm
	if not name then -- if the name isn't set then UnitName couldn't parse unit, most likely because we're not grouped.
		name = unit
	end -- Below won't work without name
	-- We also want to make sure the returned name is always title cased (it might not always be! ty Blizzard)
   name = name:lower():gsub("^%l", string.upper)
   local ret = name and name.."-"..realm
   self.unitNameLookup[input_unit] = ret
	return ret
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