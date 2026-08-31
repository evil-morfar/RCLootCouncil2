-- Translate RCLootCouncil to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("RCLootCouncil", "zhCN")
if not L then return end

--@localization(locale="zhCN", format="lua_additive_table", same-key-is-true=true)@
L["chat_commands_test"] = "模拟有#个物品的分配进程。如果省略默认为一个物品。也可以用空格分隔的物品ID来测试指定物品。"
