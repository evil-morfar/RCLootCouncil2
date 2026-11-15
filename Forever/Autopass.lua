---@type RCLootCouncil
local addon                                                                     = select(2, ...)
local AutoPass                                                                  = addon.AutoPass

AutoPass.autopassTable[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Cloth]      = {
	"WARRIOR","PALADIN","HUNTER","ROGUE","PRIEST","SHAMAN",
	"MAGE","WARLOCK","DRUID",}
AutoPass.autopassTable[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Leather]    = {
	"WARRIOR", "PALADIN", "HUNTER", "ROGUE", "SHAMAN", "DRUID", }
AutoPass.autopassTable[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Mail]       = {
	"WARRIOR", "PALADIN", "HUNTER", "SHAMAN", }
AutoPass.autopassTable[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Plate]      = {
	"WARRIOR", "PALADIN", }
AutoPass.autopassTable[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Shield]     = {
	"WARRIOR", "PALADIN", "DEATHKNIGHT", "SHAMAN", }
AutoPass.autopassTable[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Guns]     = {
	"WARRIOR", "HUNTER", "ROGUE", }
AutoPass.autopassTable[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Bows]     = {
	"WARRIOR", "HUNTER", "ROGUE", }
AutoPass.autopassTable[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Crossbow] = {
	"WARRIOR", "HUNTER", "ROGUE", }

AutoPass.autopassTable[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Libram]     = { "PALADIN", }
AutoPass.autopassTable[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Idol]       = { "DRUID", }
AutoPass.autopassTable[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Totem]      = { "SHAMAN", }
-- AutoPass.autopassTable[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Sigil]      = allClasses
-- AutoPass.autopassTable[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Relic]      = allClasses

addon:RawHook(AutoPass, "AutoPassCheck",
	--- See [Original](lua://RCLootCouncil.AutoPass.AutoPassCheck)
	function(_, link, equipLoc, typeID, subTypeID, classesFlag, class)
		local db = addon:Getdb()
		-- If player has enabled `db.autoPassSlot[equipLoc]` we should auto pass
		if db.autoPassSlot and db.autoPassSlot[equipLoc] then return true end

		-- Use special "Classic" autopass that only autopasses items your class cannot use (Vanilla/TBC)
		if db.classicAutoPass and (typeID == Enum.ItemClass.Weapon or typeID == Enum.ItemClass.Armor) then
			if not C_Item.IsEquippableItem(link) then return true end
		end

		return addon.hooks[AutoPass].AutoPassCheck(AutoPass, link, equipLoc, typeID, subTypeID, classesFlag, class)
	end)
