---@diagnostic disable: duplicate-set-field
--- Only loaded when playing Forever

---@class RCLootCouncil
local addon = select(2, ...)
--constants
-- Some item slots are different from retail
addon.INVTYPE_Slots.INVTYPE_RANGED = "RangedSlot"
addon.INVTYPE_Slots.INVTYPE_RANGEDRIGHT = "RangedSlot"
addon.INVTYPE_Slots.INVTYPE_THROWN = "RangedSlot"

-- We don't need buttons for these
addon.OPT_MORE_BUTTONS_VALUES.PETS = nil
addon.OPT_MORE_BUTTONS_VALUES.CATALYST = nil
addon.OPT_MORE_BUTTONS_VALUES.DECOR = nil
