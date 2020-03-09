--- Loads all the files!
dofile "Locale/enUS.lua"
local name,object = "RCLootCouncil", {}

-- Load files
loadfile("Core/Defaults.lua")(name, object)
loadfile("Core/Constants.lua")(name, object)
loadfile("Core/CoreEvents.lua")(name, object)
loadfile("core.lua")(name, object)
loadfile("Utils/Utils.lua")(name, object)
loadfile("Utils/ItemStorage.lua")(name,object)


-- Fire events
print("ADDON_LOADED")
WoWAPI_FireEvent("ADDON_LOADED", name)

function IsLoggedIn () return true end

print "PLAYER_LOGIN"
WoWAPI_FireEvent("PLAYER_LOGIN")
