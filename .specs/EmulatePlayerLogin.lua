--- Emulates the login process and fires needed events.
--- Should be called after addon files are loaded.
--- Run with: dofile ".specs/EmulatePlayerLogin.lua"

function _G.IsLoggedIn() return true end
WoWAPI_FireEvent("ADDON_LOADED", "RCLootCouncil")
WoWAPI_FireEvent("PLAYER_LOGIN", "RCLootCouncil")
WoWAPI_FireEvent("PLAYER_ENTERING_WORLD", "RCLootCouncil")
RCLootCouncil:InitItemStorage() -- Will be called too late for tests