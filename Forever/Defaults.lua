---@diagnostic disable: duplicate-set-field
--- Only loaded when playing Forever

---@class RCLootCouncil
local addon = select(2, ...)
---@class RCLootCouncilForeverDB : RCLootCouncilDB
local defaults = addon.defaults.profile

-- New in Forever
defaults.classicAutoPass = true
defaults.lastUsagePopupSelection = "group_loot" -- The last selection from new usage popup

-- Changes from default
defaults.currentSkin = "forever"
defaults.autoGroupLootDecor = false
defaults.showSpecIcon = false
defaults.ambiguate = false
defaults.ignoredItems = {}
defaults.autoPassWeapons = false
defaults.autoPassTrinkets = false
defaults.mlLootToPlayer = true

MergeTable(defaults.usage, {
	ml = false,
	ask_ml = false,
	leader = false,
	ask_leader = true,
	state = "ask_leader"
})
