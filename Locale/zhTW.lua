-- Translate RCLootCouncil to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("RCLootCouncil", "zhTW")
if not L then return end

--@localization(locale="zhTW", format="lua_additive_table", same-key-is-true=true)@
L["chat_commands_test"] = "模擬有#個物品的分配進程。如果省略默認為一個物品。也可以用空格分隔的物品ID來測試指定物品。"
