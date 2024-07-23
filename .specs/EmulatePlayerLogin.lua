--- Emulates the login process and fires needed events.
--- Should be called after addon files are loaded.
--- Run with: dofile ".specs/EmulatePlayerLogin.lua"

function _G.IsLoggedIn() return true end
WoWAPI_FireEvent("ADDON_LOADED", "RCLootCouncil")
WoWAPI_FireEvent("PLAYER_LOGIN", "RCLootCouncil")
WoWAPI_FireEvent("PLAYER_ENTERING_WORLD", "RCLootCouncil")
local origWowApi = WoWAPI_FireEvent
-- Override msg events to add the player name
function _G.WoWAPI_FireEvent(event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, distribution = ...
		return origWowApi(event, prefix, message, distribution, RCLootCouncil.player:GetName())
	end
	return origWowApi(event, ...)
end
RCLootCouncil:InitItemStorage() -- Will be called too late for tests