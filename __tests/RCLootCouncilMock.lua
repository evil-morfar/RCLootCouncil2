dofile "../../Locale/enUS.lua"

RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil", "AceConsole-3.0")
RCLootCouncil.debug = false
local AceSer = LibStub("AceSerializer-3.0")
RCLootCouncil.Deserialize = AceSer.Deserialize

RCLootCouncil.db = {
   profile = {},
   global = {
      log = {},
   },
}
RCLootCouncil.defaults = {
   global = {
      logMaxEntries = 2000,
   },
}
RCLootCouncil.realmName = "Ravencrest"

function RCLootCouncil:Getdb (args)
   return self.db
end

function RCLootCouncil:UnitName(unit)
	unit = gsub(unit, " ", "")
	local find = strfind(unit, "-", nil, true)
	if find and find < #unit then -- "-" isn't the last character
		local name, realm = strsplit("-", unit, 2)
		name = string.lower(name):gsub("^%l", string.upper)
		return name.."-"..realm
	end
	unit = string.lower(unit)
	local name, realm = UnitName(unit)
	if not realm or realm == "" then realm = self.realmName or "" end -- Extract our own realm
	if not name then
		name = unit
	end -- Below won't work without name
	name = string.lower(name):gsub("^%l", string.upper)
	return name and name.."-"..realm
end

function RCLootCouncil:ItemIsItem(item1, item2)
	if type(item1) ~= "string" or type(item2) ~= "string" then return item1 == item2 end
	item1 = self.Utils:GetItemStringFromLink(item1)
	item2 = self.Utils:GetItemStringFromLink(item2)
	if not (item1 and item2) then return false end -- KeyStones will fail the GetItemStringFromLink
	--[[ REVIEW Doesn't take upgradeValues into account.
		Doing that would require a parsing of the bonusIDs to check the correct positionings.
	]]
	return self.Utils:NeutralizeItem(item1) == self.Utils:NeutralizeItem(item2)
end

-- Load utils last
local utils = assert(loadfile("../../Utils/Utils.lua"))
utils("",RCLootCouncil)
