--- File containing events registered by Core.lua
-- Implementing this in a seperate file allows modifications before subscribing #Classic.
local _, addon = ...

addon.coreEvents = {
   ["PARTY_LOOT_METHOD_CHANGED"] = "OnEvent",
   ["PARTY_LEADER_CHANGED"] = "OnEvent",
   ["GROUP_LEFT"] = "OnEvent",
   ["GUILD_ROSTER_UPDATE"] = "OnEvent",
   ["RAID_INSTANCE_WELCOME"] = "OnEvent",
   ["PLAYER_ENTERING_WORLD"] = "OnEvent",
   ["PLAYER_REGEN_DISABLED"] = "EnterCombat",
   ["PLAYER_REGEN_ENABLED"] = "LeaveCombat",
   ["ENCOUNTER_START"] = "OnEvent",
   ["ENCOUNTER_END"] = "OnEvent",
   ["LOOT_SLOT_CLEARED"] = "OnEvent",
   ["LOOT_CLOSED"] = "OnEvent",
   ["LOOT_READY"] = "OnEvent",
   ["ENCOUNTER_LOOT_RECEIVED"] = "OnEvent",
   ["BONUS_ROLL_RESULT"] = "OnBonusRoll",
}
