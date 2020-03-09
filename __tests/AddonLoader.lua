--- Script for loading all addon files and it's environment.
-- Note: This should be loaded from the .toc instead of manually, but I can't get LuaFileSystem working.
local name,object = "RCLootCouncil", {}

-- Load files
dofile "Locale/enUS.lua"
loadfile("Core/Defaults.lua")(name, object)
loadfile("Core/Constants.lua")(name, object)
loadfile("Core/CoreEvents.lua")(name, object)

loadfile("core.lua")(name, object)
loadfile("ml_core.lua")(name, object)

loadfile("UI/UI.lua")(name, object)
-- Consider loading widgets

loadfile("Modules/lootFrame.lua")(name, object)
loadfile("Modules/versionCheck.lua")(name, object)
loadfile("Modules/votingFrame.lua")(name, object)
loadfile("Modules/sessionFrame.lua")(name, object)
loadfile("Modules/options.lua")(name, object)
loadfile("Modules/History/lootHistory.lua")(name, object)
loadfile("Modules/History/CSVImport.lua")(name, object)
loadfile("Modules/TradeUI.lua")(name, object)

loadfile("Utils/BackwardsCompat.lua")(name, object)
loadfile("Utils/Utils.lua")(name, object)
loadfile("Utils/trinketData.lua")(name, object)
loadfile("Utils/tokenData.lua")(name, object)
loadfile("Utils/ItemStorage.lua")(name,object)
loadfile("Utils/autopass.lua")(name,object)
loadfile("Utils/sync.lua")(name,object)
loadfile("Utils/popups.lua")(name,object)

-- Fire events
WoWAPI_FireEvent("ADDON_LOADED", name)
function IsLoggedIn () return true end
WoWAPI_FireEvent("PLAYER_LOGIN")
