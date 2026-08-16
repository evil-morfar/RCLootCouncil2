-- Translate RCLootCouncil to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("RCLootCouncil", "ptBR")
if not L then return end

--@localization(locale="ptBR", format="lua_additive_table", same-key-is-true=true)@
L["chat_commands_test"] = "Emulate a loot session with # items, 1 if omitted. Pass item IDs separated by space to test those instead."
