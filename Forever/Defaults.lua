---@diagnostic disable: duplicate-set-field
--- Only loaded when playing Forever

---@class RCLootCouncil
local addon = select(2, ...)
---@class RCLootCouncilDB
local defaults = addon.defaults.profile

-- New in Forever
defaults.classicAutoPass = true
defaults.mlLootToPlayer = true -- ML items directly to the player before starting the session

-- Changes from default
defaults.currentSkin = "forever"
defaults.autoGroupLootDecor = false
defaults.showSpecIcon = false
defaults.ambiguate = false
defaults.ignoredItems = {}
defaults.autoPassWeapons = false
defaults.autoPassTrinkets = false
