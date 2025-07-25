local _G = getfenv(0)
require "/wow_api/API/Enums"
require "/wow_api/API/Mixin"
require "/wow_api/API/Color"
require "/wow_api/API/ColorManager"
require "/wow_api/API/TableUtil"
require "wow_api/API/PlayerLocation"
require "wow_api/API/Dump"
require "wow_api/FrameAPI/Constructor"
local strbyte, strchar, gsub, gmatch, format, tinsert = string.byte, string.char, string.gsub, string.gmatch,
	string.format, table.insert

local donothing = function()
end

local frames = {}

local function uuid()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format("%x", v)
	end)
end

function _G.CreateFrame(kind, name, parent, templates, ...)
	name = name or kind .. uuid()
	local frame = _G.FrameConstructor(kind, name, parent, templates, ...)
	frame.name = name
	_G[name] = true
	frames[frame] = name
	if name then _G[name] = frame end
	return frame
end

-- It seems Wow doesn't follow the 5.1 spec for xpcall (no additional arguments),
-- but instead the one from 5.2 where that's allowed.
-- Try to recreate that here.
local orig_xpcall = xpcall
function xpcall(f, err, ...)
	-- Need to handle 5.1 case
	if select("#", ...) == 0 then return orig_xpcall(f, err) end
	local status, code = pcall(f, ...)
	if not status then
		return status, err(code)
	else
		return status, code
	end
end

function securecallfunction(method, ...)
	return method(...)
end


local function secureexecutenext(tbl, prev, func, ...)
	local key, value = next(tbl, prev)

	if key ~= nil then
		pcall(func, key, value, ...) -- Errors are silently discarded!
	end

	return key
end
function secureexecuterange(tbl, func, ...)
	local key = nil

	repeat
		key = securecallfunction(secureexecutenext, tbl, key, func, ...)
	until key == nil
end

function InterfaceOptions_AddCategory()
	-- body...
end

function InCinematic()
	return false
end

function ChatFrame_AddMessageEventFilter()
	-- body...
end

function GetUnitName(unit)
	if unit == "player" then
		return "Player1-Realm Name"
	elseif unit == "target" then
		return "Target1-Realm Name"
	end
	return unit .. "-Realm Name"	
end

function UnitName(unit)
	return unit
end

function UnitFullName(unit)
	return UnitName(unit), GetRealmName()
end

function GetBuildInfo()
	return "mock", "mock", "mock", 0
end

function GetRealmName()
	return "Realm Name"
end

function GetLootMethod()
	return "personalloot"
end

function UnitClass(unit)
	return "Warrior", "WARRIOR"
end

function UnitHealthMax()
	return 100
end

function UnitHealth()
	return 50
end

function UnitIsGroupLeader(unit)
	return false
end

function UnitIsDeadOrGhost()
	return false
end

function GetNumRaidMembers()
	return 1
end

function GetNumPartyMembers()
	return 1
end

function GetNumGroupMembers()
	return IsInRaid() and GetNumRaidMembers() or (IsInGroup() and GetNumPartyMembers() or 0)
end

function GetNumGuildMembers()
	return 1
end

function GetRaidRosterInfo(i) return "Unit" .. i end

function issecurevariable(obj, method)
	return false
end

function PlaySound() end

FACTION_HORDE = "Horde"
FACTION_ALLIANCE = "Alliance"

function UnitFactionGroup(unit)
	return "Horde", "Horde"
end

function UnitRace(unit)
	return "Undead", "Scourge"
end

_time = 0
function GetTime()
	return _time
end

function _G.StaticPopup_OnHide(args)
	-- body...
end

SlashCmdList = {}
hash_SlashCmdList = {}

function __WOW_Input(text)
	local a, b = string.find(text, "^/%w+")
	local arg, text = string.sub(text, a, b), string.sub(text, b + 2)
	for k, handler in pairs(SlashCmdList) do
		local i = 0
		while true do
			i = i + 1
			if not _G["SLASH_" .. k .. i] then
				break
			elseif _G["SLASH_" .. k .. i] == arg then
				handler(text)
				return
			end
		end
	end
	;
	print("No command found:", text)
end

local ChatFrameTemplate = {
	AddMessage = function(self, text)
		print((string.gsub(text, "|c%x%x%x%x%x%x%x%x(.-)|r", "%1")))
	end,
}

for i = 1, 7 do
	local f = {}
	for k, v in pairs(ChatFrameTemplate) do
		f[k] = v
	end
	_G["ChatFrame" .. i] = f
end
DEFAULT_CHAT_FRAME = ChatFrame1

debugstack = debug.traceback
date = os.date
debugprofilestop = os.clock

C_AddOns = {
	GetAddOnMetadata = function(arg)
		return "NOT_IMPLEMENTED"
	end,

	LoadAddOn = function(args)
		return "Not implemented!"
	end,

	IsAddOnLoaded = function() return nil end,
	GetAddOnInfo = function() return end,
	GetNumAddOns = function() return 0 end,
}

function GetLocale()
	return "enUS"
end

function GetCurrentRegion()
	return 3 -- EU
end

function _G.GetProfessions() end

function _G.GetProfessionInfo() end

function _G.GetAverageItemLevel() return 100, 100 end

_G.MAX_RAID_MEMBERS = 40

function IsPartyLFG()
	return _G.IsPartyLFGVal
end

function IsInRaid()
	return _G.IsInRaidVal
end

function UnitInRaid()
	return _G.IsInRaidVal
end

function UnitInParty()
	return _G.IsInGroupVal
end

function _G.UnitPosition(unit) end

function _G.UnitGroupRolesAssigned(unit) return "DAMAGER" end

_G.CLASS_ICON_TCOORDS = setmetatable({}, {
	__index = function(self, key)
		return { 0, 1, 0, 1, }
	end,
})
function IsInGroup()
	return _G.IsInGroupVal
end

function IsInInstance()
	local type = "none"
	if _G.IsInGroupVal then
		type = "party"
	elseif _G.IsInRaidVal then
		type = "raid"
	end
	return (IsInGroup() or IsInRaid()), type
end

function GetInstanceInfo()
	return "The Eternal Palace", nil, 14, "Normal", _, _, _, 2164
end

function IsInGuild()
	return false
end

function IsGuildMember(guid) return true end

function GuildRoster()
	-- body...
end

function GetGuildRosterInfo() end

function getglobal(k)
	return _G[k]
end

function setglobal(k, v)
	_G[k] = v
end

function _errorhandler(msg)
	error(msg) --print("--------- geterrorhandler error -------\n"..msg.."\n-----end error-----\n")
end

function geterrorhandler()
	return _errorhandler
end

function seterrorhandler()

end

_G.ClearCursor = donothing
_G.ClickTradeButton = donothing

function InCombatLockdown()
	return false
end

function IsLoggedIn()
	return false
end

function GetFramerate()
	return 60
end

function GetCVar(var)
	return "test"
end

function GetServerExpansionLevel() return 8 end

function EJ_SelectTier(num)
end

function EJ_GetInstanceByIndex()
end

function EJ_GetNumTiers() return WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC and 11 or 0 end

function EJ_SelectInstance(journalInstanceID) end

function EJ_ResetLootFilter() end

function EJ_SetDifficulty(difficultyID) end

function EJ_GetNumLoot() return 10 end

_G.C_EncounterJournal = {
	GetLootInfoByIndex = function(index)
		local Item = _G.Items[_G.Items_Array[math.random(#_G.Items_Array)]]
		return {
			itemID = Item.itemID,
			name = Item.name,
			itemQuality = Item.itemRarity,
			icon = Item.icon,
			slot = Item.itemEquipLoc,
			armorType = Item.itemType,
			link = Item.itemLink,
		}
	end,
}

function ReloadUI()
end

time = os.time

strmatch = string.match

function SendChatMessage(text, chattype, language, destination)
	assert(#text < 255)
	WoWAPI_FireEvent("CHAT_MSG_" .. strupper(chattype), text, "Sender", language or "Common")
end

local registeredPrefixes = {}

C_ChatInfo = {
	RegisterAddonMessagePrefix = function(prefix)
		assert(#prefix <= 16) -- tested, 16 works /mikk, 20110327
		registeredPrefixes[prefix] = true
	end,

	SendAddonMessage = function(prefix, message, distribution, target)
		if C_ChatInfo.RegisterAddonMessagePrefix then --4.1+
			assert(#message <= 255,
				string.format("SendAddonMessage: message too long (%d bytes > 255)",
					#message))
			-- CHAT_MSG_ADDON(prefix, message, distribution, sender)
			WoWAPI_FireEvent("CHAT_MSG_ADDON", prefix, message, distribution, "Sender")
		else -- allow RegisterAddonMessagePrefix to be nilled out to emulate pre-4.1
			assert(#prefix + #message < 255,
				string.format("SendAddonMessage: message too long (%d bytes)",
					#prefix + #message))
			-- CHAT_MSG_ADDON(prefix, message, distribution, sender)
			WoWAPI_FireEvent("CHAT_MSG_ADDON", prefix, message, distribution, "Sender")
		end
	end,
}
C_ChatInfo.SendAddonMessageLogged = C_ChatInfo.SendAddonMessage

function BNSendGameData()

end

if not wipe then
	function wipe(tbl)
		for k in pairs(tbl) do
			tbl[k] = nil
		end
		return tbl
	end
end

table.wipe = wipe

function ChatEdit_InsertLink()
	-- body...
end

function StaticPopup_SetUpPosition(args)
	-- body...
end

function StaticPopup_EscapePressed(args)
	-- body...
end

InterfaceOptionsFrameCancel = {
	GetScript = function(input) return input end,
}

function UIDropDownMenu_InitializeHelper(args)
	-- body...
end

function hooksecurefunc(tbl, func_name, post_hook_func)
	if type(tbl) == "string" then
		post_hook_func = func_name
		func_name = tbl
		tbl = _G
	end
	local orig_func = tbl[func_name]
	assert(type(orig_func) == "function")

	tbl[func_name] = function(...)
		local ret = { orig_func(...), } -- yeahyeah wasteful, see if i care, it's a test framework
		post_hook_func(...)
		return unpack(ret)
	end
end

RED_FONT_COLOR_CODE = ""
GREEN_FONT_COLOR_CODE = ""

StaticPopupDialogs = {}

function WoWAPI_FireEvent(event, ...)
	for frame in pairs(frames) do
		if frame.events[event] then
			if frame.scripts["OnEvent"] then
				for i = 1, select("#", ...) do
					_G["arg" .. i] = select(i, ...)
				end
				_G.event = event
				frame.scripts["OnEvent"](frame, event, ...)
			end
		end
	end
end

EventRegistry = {}
function EventRegistry:TriggerEvent(event, ...) end

--- ! NOT A WOW FUNCTION
--- Emulating advancing time by firing WoWAPI_FireUpdate every 0.1 seconds.
---@param seconds integer
function _ADVANCE_TIME(seconds)
	local now = GetTime()
	for i = 1, seconds do
		for m = 0, 0.9, 0.5 do
			WoWAPI_FireUpdate(_time + i + m)
		end
	end
	-- print("_ADVANCE_TIME time taken", seconds, GetTime() - now)
end

function WoWAPI_FireUpdate(forceNow)
	if forceNow then
		_time = forceNow
	end
	local now = GetTime()
	for frame in pairs(frames) do
		if frame.isShown and frame.scripts.OnUpdate then
			if now == 0 then
				frame.timer = 0 -- reset back in case we reset the clock for more testing
			end
			_G.arg1 = now - frame.timer
			frame.scripts.OnUpdate(frame, _G.arg1)
			frame.timer = now
		end
	end
end
local timerFrames = {}
C_Timer = {
	After = function(delay, callback)
		-- print("Creating timer with delay: ", delay)
		local frame = CreateFrame("Frame")
		frame:Show()
		frame.timer = 0
		frame.delay = delay
		frame.elapsed = 0
		frame:SetScript("OnUpdate", function(self, time)
			frame.elapsed = frame.elapsed + time
			if (frame.elapsed >= frame.delay) then
				-- print("Fire timer callback", delay)
				callback()
				-- Destroy OnUpdate
				frame.scripts.OnUpdate = nil
			end
		end)
		tinsert(timerFrames, frame)
	end,
}
-- Not WoWAPI
_CancelAllTimers = function()
	for i = #timerFrames, 1, -1 do
		timerFrames[i]:Hide()
		timerFrames[i]:SetScript("OnUpdate", nil)
		timerFrames[i] = nil
	end
end

local closureGeneration = {
	function(f) return function(...) return f(...); end end,
	function(f, a) return function(...) return f(a, ...); end end,
	function(f, a, b) return function(...) return f(a, b, ...); end end,
	function(f, a, b, c) return function(...) return f(a, b, c, ...); end end,
	function(f, a, b, c, d) return function(...) return f(a, b, c, d, ...); end end,
	function(f, a, b, c, d, e) return function(...) return f(a, b, c, d, e, ...); end end,
};

function GenerateClosure(f, ...)
	local count = select("#", ...);
	local generator = closureGeneration[count + 1];
	if generator then
		return generator(f, ...);
	end
	error("Closure generation does not support more than " .. (#closureGeneration - 1) .. " parameters");
end

function RunNextFrame(callback)
	C_Timer.After(0, callback);
end

function GetServerTime()
	return os.time()
end

-- utility function for "dumping" a number of arguments (return a string representation of them)
function dump(...)
	local t = {}
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if type(v) == "string" then
			tinsert(t, string.format("%q", v))
		elseif type(v) == "table" then
			tinsert(t, tostring(v) .. " #" .. #v)
		else
			tinsert(t, tostring(v))
		end
	end
	return "<" .. table.concat(t, "> <") .. ">"
end

function Ambiguate(name, method)
	if method == "short" then
		name = gsub(name, "%-.+", "")
	end
	return name
end

function string.split(sep, p, pieces)
	sep = sep or "%s"
	local t = {}
	for field, s in string.gmatch(p, "([^" .. sep .. "]*)(" .. sep .. "?)") do
		table.insert(t, field)
		if (pieces and #t >= pieces) or s == "" then
			return unpack(t)
		end
	end
end

function split(inputstr, sep)

end

local playerNameToGUID = {
	Player1 = {
		guid = "Player-1-00000001",
		name = "Player1-Realm1",
		realm = "Realm1",
		class = "WARRIOR",
	},
	Player2 = {
		guid = "Player-1-00000002",
		name = "Player2-Realm1",
		realm = "Realm1",
		class = "WARRIOR",
	},
	Player3 = {
		guid = "Player-1122-00000003",
		name = "Player3-Realm2",
		realm = "Realm2",
		class = "WARRIOR",
	},
}

local playerGUIDInfo = {}
for _, info in pairs(playerNameToGUID) do
	playerGUIDInfo[info.guid] = info
end

function CheckInteractDistance()
	return false
end

-- Not WoW lua
function GetStoredPlayerNameToGUID(name)
	return name and playerNameToGUID[name] or playerNameToGUID.Player1
end

function UnitIsUnit(u1, u2)
	if u1 == "player" then
		return "player1" == u2
	elseif u2 == "player" then
		return u1 == "player1"
	end
	return u1 == u2
end

function UnitGUID(name)
	if name == "player" or name == "Sender-Realm Name" then return playerNameToGUID.Player1.guid end
	name = Ambiguate(name, "short")
	return playerNameToGUID[name] and playerNameToGUID[name].guid or nil
end

function GetPlayerInfoByGUID(guid)
	local player = playerGUIDInfo[guid]
	if player then
		return nil, player.class, nil, nil, nil, Ambiguate(player.name, "short"), player.realm
	else
		return nil
	end
end

-- Enable some globals
_G.gsub = string.gsub
_G.strfind = string.find
_G.strsplit = string.split
_G.strsub = string.sub
_G.tremove = table.remove
_G.strrep = string.rep
_G.tinsert = table.insert
_G.format = string.format

-- local utf8 = require "lua-utf8"
strcmputf8i = function(a, b)
	print("Compare: ", a, b)
	return a == b -- ~= nil
end

local function keyValueForTable(input)
	return type(input) == "string" and "\"" .. input .. "\"" or tostring(input)
end
-- Not part of the WoWAPI, but added to emulate the ingame /dump cmd
printtable = function(data, level)
	if not data then return end
	level = level or 0
	local ident = strrep("     ", level)
	if level > 6 then return end
	if type(data) ~= "table" then
		print(tostring(data))
	end
	;
	for index, value in pairs(data) do
		repeat
			if type(value) ~= "table" then
				print(ident ..
					"[" ..
					keyValueForTable(index) ..
					"] = " .. keyValueForTable(value) .. ", -- (" .. type(value) .. ")");
				break;
			end
			print(ident .. "[" .. keyValueForTable(index) .. "] = {")
			printtable(value, level + 1)
			print(ident .. "},");
		until true
	end
end

-- Classes
CLASS_SORT_ORDER = {
	"WARRIOR",
	"DEATHKNIGHT",
	"PALADIN",
	"MONK",
	"PRIEST",
	"SHAMAN",
	"DRUID",
	"ROGUE",
	"MAGE",
	"WARLOCK",
	"HUNTER",
	"DEMONHUNTER",
	"EVOKER",
};
MAX_CLASSES = #CLASS_SORT_ORDER;

local CLASS_INFO = {
	[1] = {
		className = "Warrior",
		classFile = "WARRIOR",
		classID = 1,
		specs = {
			[1] = {
				specID = 71,
				name = "Arms",
				iconID = 132355,
				role = "DAMAGER",
			},
			[2] = {
				specID = 72,
				name = "Fury",
				iconID = 132347,
				role = "DAMAGER",
			},
			[3] = {
				specID = 73,
				name = "Protection",
				iconID = 132341,
				role = "TANK",
			},
		},
	},
	[2] = {
		className = "Paladin",
		classFile = "PALADIN",
		classID = 2,
		specs = {
			[1] = {
				specID = 65,
				name = "Holy",
				iconID = 135920,
				role = "HEALER",
			},
			[2] = {
				specID = 66,
				name = "Protection",
				iconID = 236264,
				role = "TANK",
			},
			[3] = {
				specID = 70,
				name = "Retribution",
				iconID = 135873,
				role = "DAMAGER",
			},
		},
	},
	[3] = {
		className = "Hunter",
		classFile = "HUNTER",
		classID = 3,
		specs = {
			[1] = {
				specID = 253,
				name = "Beast Mastery",
				iconID = 461112,
				role = "DAMAGER",
			},
			[2] = {
				specID = 254,
				name = "Marksmanship",
				iconID = 236179,
				role = "DAMAGER",
			},
			[3] = {
				specID = 255,
				name = "Survival",
				iconID = 461113,
				role = "DAMAGER",
			},
		},
	},
	[4] = {
		className = "Rogue",
		classFile = "ROGUE",
		classID = 4,
		specs = {
			[1] = {
				specID = 259,
				name = "Assassination",
				iconID = 236270,
				role = "DAMAGER",
			},
			[2] = {
				specID = 260,
				name = "Outlaw",
				iconID = 236286,
				role = "DAMAGER",
			},
			[3] = {
				specID = 261,
				name = "Subtlety",
				iconID = 132320,
				role = "DAMAGER",
			},
		},
	},
	[5] = {
		className = "Priest",
		classFile = "PRIEST",
		classID = 5,
		specs = {
			[1] = {
				specID = 256,
				name = "Discipline",
				iconID = 135940,
				role = "HEALER",
			},
			[2] = {
				specID = 257,
				name = "Holy",
				iconID = 237542,
				role = "HEALER",
			},
			[3] = {
				specID = 258,
				name = "Shadow",
				iconID = 136207,
				role = "DAMAGER",
			},
		},
	},
	[6] = {
		className = "Death Knight",
		classFile = "DEATHKNIGHT",
		classID = 6,
		specs = {
			[1] = {
				specID = 250,
				name = "Blood",
				iconID = 135770,
				role = "TANK",
			},
			[2] = {
				specID = 251,
				name = "Frost",
				iconID = 135773,
				role = "DAMAGER",
			},
			[3] = {
				specID = 252,
				name = "Unholy",
				iconID = 135775,
				role = "DAMAGER",
			},
		},
	},
	[7] = {
		className = "Shaman",
		classFile = "SHAMAN",
		classID = 7,
		specs = {
			[1] = {
				specID = 262,
				name = "Elemental",
				iconID = 136048,
				role = "DAMAGER",
			},
			[2] = {
				specID = 263,
				name = "Enhancement",
				iconID = 237581,
				role = "DAMAGER",
			},
			[3] = {
				specID = 264,
				name = "Restoration",
				iconID = 136052,
				role = "HEALER",
			},
		},
	},
	[8] = {
		className = "Mage",
		classFile = "MAGE",
		classID = 8,
		specs = {
			[1] = {
				specID = 62,
				name = "Arcane",
				iconID = 135932,
				role = "DAMAGER",
			},
			[2] = {
				specID = 63,
				name = "Fire",
				iconID = 135810,
				role = "DAMAGER",
			},
			[3] = {
				specID = 64,
				name = "Frost",
				iconID = 135846,
				role = "DAMAGER",
			},
		},
	},
	[9] = {
		className = "Warlock",
		classFile = "WARLOCK",
		classID = 9,
		specs = {
			[1] = {
				specID = 265,
				name = "Affliction",
				iconID = 136145,
				role = "DAMAGER",
			},
			[2] = {
				specID = 266,
				name = "Demonology",
				iconID = 136172,
				role = "DAMAGER",
			},
			[3] = {
				specID = 267,
				name = "Destruction",
				iconID = 136186,
				role = "DAMAGER",
			},
		},
	},
	[10] = {
		className = "Monk",
		classFile = "MONK",
		classID = 10,
		specs = {
			[1] = {
				specID = 268,
				name = "Brewmaster",
				iconID = 608951,
				role = "TANK",
			},
			[2] = {
				specID = 270,
				name = "Mistweaver",
				iconID = 608952,
				role = "HEALER",
			},
			[3] = {
				specID = 269,
				name = "Windwalker",
				iconID = 608953,
				role = "DAMAGER",
			},
		},
	},
	[11] = {
		className = "Druid",
		classFile = "DRUID",
		classID = 11,
		specs = {
			[1] = {
				specID = 102,
				name = "Balance",
				iconID = 136096,
				role = "DAMAGER",
			},
			[2] = {
				specID = 103,
				name = "Feral",
				iconID = 132115,
				role = "DAMAGER",
			},
			[3] = {
				specID = 104,
				name = "Guardian",
				iconID = 132276,
				role = "TANK",
			},
			[4] = {
				specID = 105,
				name = "Restoration",
				iconID = 136041,
				role = "HEALER",
			},
		},
	},
	[12] = {
		className = "Demon Hunter",
		classFile = "DEMONHUNTER",
		classID = 12,
		specs = {
			[1] = {
				specID = 577,
				name = "Havoc",
				iconID = 1247264,
				role = "DAMAGER",
			},
			[2] = {
				specID = 581,
				name = "Vengeance",
				iconID = 1247265,
				role = "TANK",
			},
		},
	},
	[13] = {
		className = "Evoker",
		classFile = "EVOKER",
		classID = 13,
		specs = {
			[1] = {
				specID = 1467,
				name = "Devastation",
				iconID = 4511811,
				role = "DAMAGER",
			},
			[2] = {
				specID = 1468,
				name = "Preservation",
				iconID = 4511812,
				role = "HEALER",
			},
			[3] = {
				specID = 1473,
				name = "Augmentation",
				iconID = 5198700,
				role = "DAMAGER",
			},
		},
	},
}

-- Above was exported with
-- local export = "local CLASS_INFO = {\n"
-- for classID=1,GetNumClasses() do
-- 	local classInfo = C_CreatureInfo.GetClassInfo(classID)
-- 	export = export .. "\t["..classID.."] = {\n"
-- 	export = export .. "\t\tclassName = \""..classInfo.className .. "\",\n"
-- 	export = export .. "\t\tclassFile = \""..classInfo.classFile .. "\",\n"
-- 	export = export .. "\t\tclassID = "..classInfo.classID .. ",\n"
-- 	export = export .. "\t\tspecs = {\n"
-- 	for specNum=1,GetNumSpecializationsForClassID(classID) do
-- 		local specID, name, description, iconID, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(classID, specNum)
-- 		export = export .. "\t\t["..specNum.."] = {\n"
--
-- 		export = export .. "\t\t\tspecID = "..specID..",\n"
-- 		export = export .. "\t\t\tname = \""..name.."\",\n"
-- 		export = export .. "\t\t\ticonID = "..iconID..",\n"
-- 		export = export .. "\t\t\trole = \""..role.."\",\n"
-- 		export = export .. "\t\t},\n"
-- 	end
-- 	export = export .. "\t\t},\n"
--
-- 	export = export .. "},\n"
-- end
-- export = export .. "}"
-- -- Reuse RCLootCouncil History Export Frame
-- local frame = RCLootCouncil:GetActiveModule("history"):GetFrame()
-- frame.exportFrame:Show()
-- frame.exportFrame.edit:SetText(export)

function GetNumClasses()
	return 13
end

function GetNumSpecializationsForClassID(classID)
	return #CLASS_INFO[classID].specs
end

function GetClassInfo(classIndex)
	return CLASS_INFO[classIndex].className, CLASS_INFO[classIndex].classFile, CLASS_INFO[classIndex].classID
end

function GetSpecializationInfoForClassID(classID, specNum)
	local spec = CLASS_INFO[classID].specs[specNum]
	return spec.specID, spec.name, "NOT_IMPLEMENTED", spec.iconID, spec.role, "NOT_IMPLEMENTED", "NOT_IMPLEMENTED"
end

function GetSpecialization() return 71 end

function GetSpecializationInfo() return GetSpecializationInfoForClassID(1, 1) end

function GetSpecializationInfoByID() return GetSpecializationInfoForClassID(1, 1) end

function _G.GetInventorySlotInfo(slot) end

-- Mocked with random item
function GetInventoryItemLink(unit, slot) return _G.Items_Array[math.random(#_G.Items_Array)] end

local symbols = { "%%", "%*", "%+", "%-", "%?", "%(", "%)", "%[", "%]", "%$", "%^", } --% has to be escaped first or everything is ruined
local replacements = { "%%%%", "%%%*", "%%%+", "%%%-", "%%%?", "%%%(", "%%%)", "%%%[", "%%%]", "%%%$", "%%%^", }
-- Defined in FrameXML/ChatFrame.lua
function escapePatternSymbols(text)
	for i = 1, #symbols do
		text = text:gsub(symbols[i], replacements[i])
	end
	return text
end

function FauxScrollFrame_Update()
end

function FauxScrollFrame_GetOffset() return 0 end

function _G.FauxScrollFrame_OnVerticalScroll() end

function GetClassColoredTextForUnit(unit, text) return text end

function CreateAtlasMarkup(text) return "" end

ceil = math.ceil
max = math.max
mod = math.fmod
C_Container = {
	GetContainerItemInfo = function(c, s)
		return {
			hyperlink = C_Container.GetContainerItemLink(c, s),
		}
	end,
	PickupContainerItem = donothing,
	GetContainerNumSlots = function(c) return 10 end,
	GetContainerNumFreeSlots = function(c) return 10, 0 end,
	GetContainerItemLink = donothing,
}

C_CreatureInfo = {
	GetClassInfo = function(classID)
		return CLASS_INFO[classID]
	end,
}

C_PlayerInfo = {
	UnitIsSameServer = function(target)
		return false
	end,
}

C_ColorOverrides = {
	GetColorForQuality = function (itemQuality)
		return CreateColor(1, 1, 1, 1)
	end
}

C_Glue = {
	IsOnGlueScreen = function()
		return true
	end,
}

C_Spell = {
	GetSpellInfo = function(spellID)
		if spellID == 12345 then
			return "Test Spell", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
		end
		return "Unknown Spell", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
	end,
}

UISpecialFrames = {}
_G.UIParent = CreateFrame("Frame", "UIParent")
_G.GameTooltip = CreateFrame("GameTooltip", "GameTooltip", UIParent)
------------------------------------------
-- Constants from various places
------------------------------------------
NUM_BAG_SLOTS = 10

RAID_CLASS_COLORS = {}
function GetClassColorObj(classFilename)
	return RAID_CLASS_COLORS[classFilename];
end

MAX_TRADE_ITEMS = 6 -- don't remember

TOOLTIP_DEFAULT_COLOR = { r = 1, g = 1, b = 1, };
TOOLTIP_DEFAULT_BACKGROUND_COLOR = { r = 0.09, g = 0.09, b = 0.19, };
_G.INVSLOT_FIRST_EQUIPPED = 1
_G.INVSLOT_LAST_EQUIPPED = 18
NORMAL_FONT_COLOR = CreateColor(255, 209, 0, 255) --ffd100

------------------------------------------
-- Global Strings
------------------------------------------
BIND_TRADE_TIME_REMAINING =
"You may trade this item with players that were also eligible to loot this item for the next %s."
CLOSE = "Close"
CLOSES_IN = "Time Left";
ENABLE = "Enable"
GROUP = "Group"
GUILD = "Guild"
LOOT_ITEM = "%s receives loot: %s."
RANDOM_ROLL_RESULT = "%s rolls %d (%d-%d)"
REQUEST_ROLL = "Request Roll"
INVTYPE_CHEST = "Chest"
ITEM_CLASSES_ALLOWED = "Classes: %s"
ITEM_LEVEL_ABBR = "ilvl"
ITEM_MOD_AGILITY = "%c%s Agility";
ITEM_MOD_AGILITY_OR_INTELLECT_SHORT = "Agility or Intellect";
ITEM_MOD_AGILITY_OR_STRENGTH_OR_INTELLECT_SHORT = "Agility or Strength or Intellect";
ITEM_MOD_AGILITY_OR_STRENGTH_SHORT = "Agility or Strength";
ITEM_MOD_AGILITY_SHORT = "Agility";
ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT = "Armor Penetration";
ITEM_MOD_ATTACK_POWER_SHORT = "Attack Power";
ITEM_MOD_BLOCK_RATING_SHORT = "Block";
ITEM_MOD_BLOCK_VALUE_SHORT = "Block Value";
ITEM_MOD_CORRUPTION = "Corruption";
ITEM_MOD_CORRUPTION_RESISTANCE = "Corruption Resistance";
ITEM_MOD_CRIT_MELEE_RATING_SHORT = "Critical Strike (Melee)";
ITEM_MOD_CRIT_RANGED_RATING_SHORT = "Critical Strike (Ranged)";
ITEM_MOD_CRIT_RATING_SHORT = "Critical Strike";
ITEM_MOD_CRIT_SPELL_RATING_SHORT = "Critical Strike (Spell)";
ITEM_MOD_CRIT_TAKEN_MELEE_RATING_SHORT = "Critical Strike Avoidance (Melee)";
ITEM_MOD_CRIT_TAKEN_RANGED_RATING_SHORT = "Critical Strike Avoidance (Ranged)";
ITEM_MOD_CRIT_TAKEN_RATING_SHORT = "Critical Strike Avoidance";
ITEM_MOD_CRIT_TAKEN_SPELL_RATING_SHORT = "Critical Strike Avoidance (Spell)";
ITEM_MOD_CR_AVOIDANCE_SHORT = "Avoidance";
ITEM_MOD_CR_LIFESTEAL_SHORT = "Leech";
ITEM_MOD_CR_MULTISTRIKE_SHORT = "Multistrike";
ITEM_MOD_CR_SPEED_SHORT = "Speed";
ITEM_MOD_CR_STURDINESS_SHORT = "Indestructible";
ITEM_MOD_DODGE_RATING_SHORT = "Dodge";
ITEM_MOD_EXPERTISE_RATING_SHORT = "Expertise";
ITEM_MOD_EXTRA_ARMOR_SHORT = "Bonus Armor";
ITEM_MOD_FERAL_ATTACK_POWER_SHORT = "Attack Power In Forms";
ITEM_MOD_HASTE_RATING_SHORT = "Haste";
ITEM_MOD_HEALTH_REGEN = "Restores %s health per 5 sec.";
ITEM_MOD_HEALTH_REGENERATION_SHORT = "Health Regeneration";
ITEM_MOD_HEALTH_SHORT = "Health";
ITEM_MOD_HIT_MELEE_RATING_SHORT = "Hit (Melee)";
ITEM_MOD_HIT_RANGED_RATING_SHORT = "Hit (Ranged)";
ITEM_MOD_HIT_RATING_SHORT = "Hit";
ITEM_MOD_HIT_SPELL_RATING_SHORT = "Hit (Spell)";
ITEM_MOD_HIT_TAKEN_MELEE_RATING_SHORT = "Hit Avoidance (Melee)";
ITEM_MOD_HIT_TAKEN_RANGED_RATING_SHORT = "Hit Avoidance (Ranged)";
ITEM_MOD_HIT_TAKEN_RATING_SHORT = "Hit Avoidance";
ITEM_MOD_HIT_TAKEN_SPELL_RATING_SHORT = "Hit Avoidance (Spell)";
ITEM_MOD_INTELLECT_SHORT = "Intellect";
ITEM_MOD_MANA_REGENERATION_SHORT = "Mana Regeneration";
ITEM_MOD_MANA_SHORT = "Mana";
ITEM_MOD_MASTERY_RATING_SHORT = "Mastery";
ITEM_MOD_MELEE_ATTACK_POWER_SHORT = "Melee Attack Power";
ITEM_MOD_PARRY_RATING_SHORT = "Parry";
ITEM_MOD_RANGED_ATTACK_POWER_SHORT = "Ranged Attack Power";
ITEM_MOD_RESILIENCE_RATING_SHORT = "PvP Resilience";
ITEM_MOD_SPELL_POWER_SHORT = "Spell Power";
ITEM_MOD_STAMINA_SHORT = "Stamina";
ITEM_MOD_STRENGTH_OR_INTELLECT_SHORT = "Strength or Intellect";
ITEM_MOD_STRENGTH_SHORT = "Strength";
ITEM_MOD_VERSATILITY = "Versatility";
ITEM_SOULBOUND = "Soulbound";
NAME = "Name"
MODE = "Mode"
RANK = "Rank"
ROLL = "Roll"
STATUS = "Status"
UNKNOWNOBJECT = "Unknown"
UNKNOWN = "Unknown"

BLOCK = "Block"
PARRY = "Parry"
DAMAGER = "Damage"
TANK = "Tank"
HEALER = "Healer"
MELEE = "Melee"
RANGED = "Ranged"


-- Classic only functions
if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	GetNumSkillLines = function()
		return 0
	end

	C_Seasons = {
		GetActiveSeason = function() return 0 end,
	}
end

-- Run last
ColorManager.UpdateColorData();
