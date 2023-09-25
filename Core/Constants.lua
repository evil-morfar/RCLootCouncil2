--- Constants.lua
-- Objects which are intended to be set once (i.e. modules or addons can change them on init)

--- @class RCLootCouncil
local addon = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

addon.LOGO_LOCATION = "Interface\\AddOns\\RCLootCouncil\\Media\\rc_banner"

--- @class Prefixes
addon.PREFIXES = { MAIN = "RCLC", VERSION = "RCLCv", SYNC = "RCLCs", }

addon.MIN_LOOT_THRESHOLD = 3 -- Only loot rares or better

addon.BTN_SLOTS = {
	INVTYPE_HEAD = "AZERITE",
	INVTYPE_CHEST = "AZERITE",
	INVTYPE_ROBE = "AZERITE",
	INVTYPE_SHOULDER = "AZERITE",
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
	AZERITE = "Azerite Armor",
	TOKEN = L["Armor Token"],
	-- CORRUPTED = _G.CORRUPTION_TOOLTIP_TITLE,
	CONTEXT_TOKEN = "Beads and Spherules",
	PETS = _G.PETS,
	MOUNTS = _G.MOUNTS,
	BAGSLOT = _G.BAGSLOT,
	RECIPE = _G.AUCTION_CATEGORY_RECIPES,
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

--- Functions used for generating response codes
-- Functions are run numerically, and the first to return non-nil is used, i.e. order matters!
-- To add a new a button group, simply add it to the options menu (easily done by adding an entry to OPT_MORE_BUTTONS_VALUES), and add a function here to determine if that group should be used for the item.
-- Each function receives the following parameters:
-- item, db (addon:Getdb()), itemID, itemEquipLoc,itemClassID, itemSubClassID
addon.RESPONSE_CODE_GENERATORS = {
	-- Pets
	function(_, db, _, _, itemClassID, itemSubClassID)
		return db.enabledButtons.PETS and itemClassID == Enum.ItemClass.Miscellaneous and itemSubClassID

			== Enum.ItemMiscellaneousSubclass.CompanionPet and "PETS" or nil
	end,

	-- Beads and Spherules
	-- function(_, db, _, _, itemClassID, itemSubClassID)
	-- 	return db.enabledButtons.CONTEXT_TOKEN and itemClassID == 5 and itemSubClassID == 2 and "CONTEXT_TOKEN" or nil
	-- end,

	-- Armor tokens
	function(_, db, itemID)
		local _, _, _, _, _, itemClassID, itemSubClassID = GetItemInfoInstant(itemID)
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

	-- Check for Azerite Gear
	function(_, db, _, itemEquipLoc)
		-- To use Azerite Buttons, the item must be one of the 3 azerite items, and no other button group must be set for those equipLocs
		if db.enabledButtons.AZERITE and not db.enabledButtons[itemEquipLoc] then
			if addon.BTN_SLOTS[itemEquipLoc] == "AZERITE" then return "AZERITE" end
		end
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

	-- Recipies
	function(_, db, _, _, classID)
		if db.enabledButtons.RECIPE and classID == Enum.ItemClass.Recipe then
			return "RECIPE"
		end
	end,
}

--- @alias VersionCodes
---| '"current"'  #  Up to date
---| '"outdated"' # Outdated
---| '"tVersion"' # Running with test version
addon.VER_CHECK_CODES = { [1] = "current", [2] = "outdated", [3] = "tVersion", }
