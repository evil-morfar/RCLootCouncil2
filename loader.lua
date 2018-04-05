local addon = select(2, ...)

_G.RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon(select(2, ...), "RCLootCouncil", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceHook-3.0", "AceTimer-3.0");

local error = error
local tostring = tostring
local type = type

local _api = {}
addon._api = _api

function addon:NewAPI(apiName)
	if type(apiName) ~= "string" then
		error(("Usage: AddAPI(apiName): 'apiName' string expected got '%s' (%s)"):format(type(apiName), tostring(apiName)), 2)
	end
	if _api[apiName] then
		error(("Usage: AddAPI(apiName): 'apiName' already exists"):format(tostring(apiName)), 2)
	end
	local api = {}
	_api[apiName] = api
	return api
end

function addon:GetAPI(apiName)
	if type(apiName) ~= "string" then
		error(("Usage: GetAPI(apiName): 'apiName' string expected got '%s' (%s)"):format(type(apiName), tostring(apiName)), 2)
	end
	if not _api[apiName] then
		error(("Usage: GetAPI(apiName): 'apiName' does not already exist"):format(tostring(apiName)), 2)
	end
	return _api[apiName]
end