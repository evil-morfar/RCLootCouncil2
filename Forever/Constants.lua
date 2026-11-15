---@diagnostic disable: duplicate-set-field
--- Only loaded when playing Forever

---@class RCLootCouncil
local addon = select(2, ...)
--- @type RCLootCouncilLocale
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
--constants
-- Some item slots are different from retail
addon.INVTYPE_Slots.INVTYPE_RANGED = "RangedSlot"
addon.INVTYPE_Slots.INVTYPE_RANGEDRIGHT = "RangedSlot"
addon.INVTYPE_Slots.INVTYPE_THROWN = "RangedSlot"

addon.INVTYPE_Slots.INVTYPE_RELIC = { "RelicSlot " }
addon.OPT_MORE_BUTTONS_VALUES.INVTYPE_RELIC = _G.INVTYPE_RELIC

-- We don't need buttons for these
addon.OPT_MORE_BUTTONS_VALUES.PETS = nil
addon.OPT_MORE_BUTTONS_VALUES.CATALYST = nil
addon.OPT_MORE_BUTTONS_VALUES.DECOR = nil
addon.OPT_MORE_BUTTONS_VALUES.RARE = nil

-- Add "Set Pieces" as a group
addon.OPT_MORE_BUTTONS_VALUES.SETS = L.SET_PIECES
tinsert(addon.RESPONSE_CODE_GENERATORS, 2, function(item, db)
	local set = select(16, C_Item.GetItemInfo(item))
	if db.enabledButtons.SETS and set and set > 0 then
		return "SETS"
	end
end)
