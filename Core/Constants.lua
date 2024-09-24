--- Constants.lua
-- Objects which are intended to be set once (i.e. modules or addons can change them on init)

--- @class RCLootCouncil
local addon = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

addon.LOGO_LOCATION = "Interface\\AddOns\\RCLootCouncil\\Media\\rc_banner"

--- @enum Prefixes
addon.PREFIXES = { MAIN = "RCLC", VERSION = "RCLCv", SYNC = "RCLCs", }

addon.MIN_LOOT_THRESHOLD = 3 -- Only loot rares or better

addon.PROFILE_EXPORT_IDENTIFIER = "RCLootCouncilProfile"

--- Translation of a inventory slot to another ( custom) one
addon.BTN_SLOTS = {
	INVTYPE_2HWEAPON = "WEAPON",
	INVTYPE_WEAPONMAINHAND = "WEAPON",
	INVTYPE_WEAPONOFFHAND = "WEAPON",
	INVTYPE_WEAPON = "WEAPON",
	INVTYPE_THROWN = "WEAPON",
	INVTYPE_RANGED = "WEAPON",
	INVTYPE_RANGEDRIGHT = "WEAPON",
	INVTYPE_HOLDABLE = "WEAPON",
}

addon.OPT_MORE_BUTTONS_VALUES = {
	INVTYPE_HEAD = _G.INVTYPE_HEAD,
	INVTYPE_NECK = _G.INVTYPE_NECK,
	INVTYPE_SHOULDER = _G.INVTYPE_SHOULDER,
	INVTYPE_CLOAK = _G.INVTYPE_CLOAK,
	INVTYPE_CHEST = _G.INVTYPE_CHEST,
	INVTYPE_WRIST = _G.INVTYPE_WRIST,
	INVTYPE_HAND = _G.INVTYPE_HAND,
	INVTYPE_WAIST = _G.INVTYPE_WAIST,
	INVTYPE_LEGS = _G.INVTYPE_LEGS,
	INVTYPE_FEET = _G.INVTYPE_FEET,
	INVTYPE_FINGER = _G.INVTYPE_FINGER,
	INVTYPE_TRINKET = _G.INVTYPE_TRINKET,

	WEAPON = _G.WEAPON,
	TOKEN = L["Armor Token"],
	PETS = _G.PETS,
	MOUNTS = _G.MOUNTS,
	BAGSLOT = _G.BAGSLOT,
	RECIPE = _G.AUCTION_CATEGORY_RECIPES,
	CATALYST = L.Catalyst_Items, -- items that can be converted to tier through catalyst
}

--- Inventory types that can be converted to tier
addon.CATALYST_ITEMS = {
	INVTYPE_HEAD = true,
	INVTYPE_SHOULDER = true,
	INVTYPE_CHEST = true,
	INVTYPE_ROBE = true, -- same as chest
	INVTYPE_HAND = true,
	INVTYPE_LEGS = true,
}

--[[
	Used by getCurrentGear to determine slot types
   Inspired by EPGPLootMaster
   --v3.0: Now also used for custum "INVTYPEs"
--]]
addon.INVTYPE_Slots = {
	INVTYPE_HEAD = "HeadSlot",
	INVTYPE_NECK = "NeckSlot",
	INVTYPE_SHOULDER = "ShoulderSlot",
	INVTYPE_CLOAK = "BackSlot",
	INVTYPE_CHEST = "ChestSlot",
	INVTYPE_WRIST = "WristSlot",
	INVTYPE_HAND = "HandsSlot",
	INVTYPE_WAIST = "WaistSlot",
	INVTYPE_LEGS = "LegsSlot",
	INVTYPE_FEET = "FeetSlot",
	INVTYPE_SHIELD = "SecondaryHandSlot",
	INVTYPE_ROBE = "ChestSlot",
	INVTYPE_2HWEAPON = { "MainHandSlot", "SecondaryHandSlot", },
	INVTYPE_WEAPONMAINHAND = "MainHandSlot",
	INVTYPE_WEAPONOFFHAND = { "SecondaryHandSlot", ["or"] = "MainHandSlot", },
	INVTYPE_WEAPON = { "MainHandSlot", "SecondaryHandSlot", },
	INVTYPE_THROWN = { "MainHandSlot", ["or"] = "SecondaryHandSlot", },
	INVTYPE_RANGED = { "MainHandSlot", ["or"] = "SecondaryHandSlot", },
	INVTYPE_RANGEDRIGHT = { "MainHandSlot", ["or"] = "SecondaryHandSlot", },
	INVTYPE_FINGER = { "Finger0Slot", "Finger1Slot", },
	INVTYPE_HOLDABLE = { "SecondaryHandSlot", ["or"] = "MainHandSlot", },
	INVTYPE_TRINKET = { "TRINKET0SLOT", "TRINKET1SLOT", },

	-- Custom
	CONTEXT_TOKEN = { "HeadSlot", "ChestSlot", },
}

--- For use with `CreateAtlasMarkup`
addon.CLASS_TO_ATLAS = {
	DEATHKNIGHT = "classicon-deathknight",
	DEMONHUNTER = "classicon-demonhunter",
	DRUID = "classicon-druid",
	EVOKER = "classicon-evoker",
	HUNTER = "classicon-hunter",
	MAGE = "classicon-mage",
	MONK = "classicon-monk",
	PALADIN = "classicon-paladin",
	PRIEST = "classicon-priest",
	ROGUE = "classicon-rogue",
	SHAMAN = "classicon-shaman",
	WARLOCK = "classicon-warlock",
	WARRIOR = "classicon-warrior",
}

--- Functions used for generating response codes
--- Functions are run numerically, and the first to return non-nil is used, i.e. order matters!
--- To add a new a button group, simply add it to the options menu (easily done by adding an entry to OPT_MORE_BUTTONS_VALUES), and add a function here to determine if that group should be used for the item.
---@type (fun(item: string|integer, db: RCLootCouncil.db, itemID: integer, itemEquipLoc: string, itemClassID: Enum.ItemClass, itemSubClassID: Enum.ItemMiscellaneousSubclass): string?) []
addon.RESPONSE_CODE_GENERATORS = {
	-- Chest/Robe
	function(_, db, _, equipLoc)
		return db.enabledButtons.INVTYPE_CHEST and
			(addon.INVTYPE_Slots[equipLoc] == addon.INVTYPE_Slots.INVTYPE_CHEST)
			and "INVTYPE_CHEST" or nil
	end,
	-- Pets
	function(_, db, _, _, itemClassID, itemSubClassID)
		return db.enabledButtons.PETS and itemClassID == Enum.ItemClass.Miscellaneous and itemSubClassID

			== Enum.ItemMiscellaneousSubclass.CompanionPet and "PETS" or nil
	end,

	-- Armor tokens
	function(_, db, itemID, _, itemClassID, itemSubClassID)
		if db.enabledButtons["TOKEN"] and (RCTokenTable[itemID] or
				-- context token is armor token in DF
				itemClassID == Enum.ItemClass.Reagent and itemSubClassID == Enum.ItemReagentSubclass.ContextToken)
		then
			return "TOKEN"
		end
	end,

	-- Check for Weapon
	function(_, db, _, itemEquipLoc)
		if db.enabledButtons.WEAPON and addon.BTN_SLOTS[itemEquipLoc] == "WEAPON" then return "WEAPON" end
	end,

	-- Mounts
	function(_, db, _, _, classID, subClassID)
		if db.enabledButtons.MOUNTS and classID == Enum.ItemClass.Miscellaneous and subClassID == Enum.ItemMiscellaneousSubclass.Mount then
			return "MOUNTS"
		end
	end,

	-- Bags
	function(_, db, _, _, classID)
		if db.enabledButtons.BAGSLOT and classID == Enum.ItemClass.Container then
			return "BAGSLOT"
		end
	end,

	-- Recipes
	function(_, db, _, _, classID)
		if db.enabledButtons.RECIPE and classID == Enum.ItemClass.Recipe then
			return "RECIPE"
		end
	end,
	-- Catalyst
	function(_, db, _, itemEquipLoc)
		return db.enabledButtons.CATALYST and addon.CATALYST_ITEMS[itemEquipLoc] and "CATALYST" or nil
	end,
}

--- @alias VersionCodes
---| '"current"'  #  Up to date
---| '"outdated"' # Outdated
---| '"tVersion"' # Running with test version
addon.VER_CHECK_CODES = { [1] = "current", [2] = "outdated", [3] = "tVersion", }
