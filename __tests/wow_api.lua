local _G = getfenv(0)
local strbyte, strchar, gsub, gmatch, format, tinsert = string.byte, string.char, string.gsub, string.gmatch, string.format, table.insert

local donothing = function() end

local frames = {} -- Stores globally created frames, and their internal properties.

local FrameClass = {} -- A class for creating frames.
FrameClass.methods = { "SetScript", "RegisterEvent", "UnregisterEvent", "UnregisterAllEvents", "Show", "Hide", "IsShown", "ClearAllPoints", "SetParent" }
function FrameClass:New()
	local frame = {}
	for i,method in ipairs(self.methods) do
		frame[method] = self[method]
	end
	local frameProps = {
		events = {},
		scripts = {},
		timer = GetTime(),
		isShow = true,
		parent = nil,
	}
	return frame, frameProps
end
function FrameClass:SetScript(script,handler)
	frames[self].scripts[script] = handler
end
function FrameClass:RegisterEvent(event)
	frames[self].events[event] = true
end
function FrameClass:UnregisterEvent(event)
	frames[self].events[event] = nil
end
function FrameClass:UnregisterAllEvents(frame)
	for event in pairs(frames[self].events) do
		frames[self].events[event] = nil
	end
end
function FrameClass:Show()
	frames[self].isShow = true
end
function FrameClass:Hide()
	frames[self].isShow = false
end
function FrameClass:IsShown()
	return frames[self].isShow
end
function FrameClass:ClearAllPoints()
end
function FrameClass:SetParent(parent)
	frames[self].parent = parent
end


function CreateFrame(kind, name, parent)
	local frame,internal = FrameClass:New()
	internal.parent = parent
	frames[frame] = internal
	if name then
		_G[name] = frame
	end
	return frame
end

function UnitName(unit)
	return unit
end

function GetRealmName()
	return "Realm Name"
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

function GetNumRaidMembers()
	return 1
end

function GetNumPartyMembers()
	return 1
end

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

function IsAddOnLoaded() return nil end

SlashCmdList = {}

function __WOW_Input(text)
	local a,b = string.find(text, "^/%w+")
	local arg, text = string.sub(text, a,b), string.sub(text, b + 2)
	for k,handler in pairs(SlashCmdList) do
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
	end;
	print("No command found:", text)
end

local ChatFrameTemplate = {
	AddMessage = function(self, text)
		print((string.gsub(text, "|c%x%x%x%x%x%x%x%x(.-)|r", "%1")))
	end
}

for i=1,7 do
	local f = {}
	for k,v in pairs(ChatFrameTemplate) do
		f[k] = v
	end
	_G["ChatFrame"..i] = f
end
DEFAULT_CHAT_FRAME = ChatFrame1

debugstack = debug.traceback
date = os.date

function GetLocale()
	return "enUS"
end

function GetCurrentRegion()
	return 3 -- EU
end

function GetAddOnInfo()
	return
end

function GetNumAddOns()
	return 0
end

function IsPartyLFG ()
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

function IsInGroup ()
	return _G.IsInGroupVal
end

function IsInInstance ()
	local type = "none"
	if _G.IsInGroupVal then
		type = "party"
	elseif _G.IsInRaidVal then
		type = "raid"
	end
	return (IsInGroup() or IsInRaid()), type
end

function getglobal(k)
	return _G[k]
end

function setglobal(k, v)
	_G[k] = v
end

local function _errorhandler(msg)
	print("--------- geterrorhandler error -------\n"..msg.."\n-----end error-----\n")
end

function geterrorhandler()
	return _errorhandler
end

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

time = os.clock

strmatch = string.match

function SendChatMessage(text, chattype, language, destination)
	assert(#text<255)
	WoWAPI_FireEvent("CHAT_MSG_"..strupper(chattype), text, "Sender", language or "Common")
end

local registeredPrefixes = {}
function RegisterAddonMessagePrefix(prefix)
	assert(#prefix<=16)	-- tested, 16 works /mikk, 20110327
	registeredPrefixes[prefix] = true
end

function SendAddonMessage(prefix, message, distribution, target)
	if RegisterAddonMessagePrefix then --4.1+
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
end

if not wipe then
	function wipe(tbl)
		for k in pairs(tbl) do
			tbl[k]=nil
		end
	end
end

function hooksecurefunc(func_name, post_hook_func)
	local orig_func = _G[func_name]
	assert(type(orig_func)=="function")

	_G[func_name] = function (...)
				local ret = { orig_func(...) }		-- yeahyeah wasteful, see if i care, it's a test framework
				post_hook_func(...)
				return unpack(ret)
			end
end

RED_FONT_COLOR_CODE = ""
GREEN_FONT_COLOR_CODE = ""

StaticPopupDialogs = {}

function WoWAPI_FireEvent(event,...)
	for frame, props in pairs(frames) do
		if props.events[event] then
			if props.scripts["OnEvent"] then
				for i=1,select('#',...) do
					_G["arg"..i] = select(i,...)
				end
				_G.event=event
				props.scripts["OnEvent"](frame,event,...)
			end
		end
	end
end

function WoWAPI_FireUpdate(forceNow)
	if forceNow then
		_time = forceNow
	end
	local now = GetTime()
	for frame,props in pairs(frames) do
		if props.isShow and props.scripts.OnUpdate then
			if now == 0 then
				props.timer = 0	-- reset back in case we reset the clock for more testing
			end
			_G.arg1=now-props.timer
			props.scripts.OnUpdate(frame,now-props.timer)
			props.timer = now
		end
	end
end

function GetServerTime ()
	return os.time()
end


-- utility function for "dumping" a number of arguments (return a string representation of them)
function dump(...)
	local t = {}
	for i=1,select("#", ...) do
		local v = select(i, ...)
		if type(v)=="string" then
			tinsert(t, string.format("%q", v))
		elseif type(v)=="table" then
			tinsert(t, tostring(v).." #"..#v)
		else
			tinsert(t, tostring(v))
		end
	end
	return "<"..table.concat(t, "> <")..">"
end

function tDeleteItem(tbl, item)
	local index = 1;
	while tbl[index] do
		if ( item == tbl[index] ) then
			tremove(tbl, index);
		else
			index = index + 1;
		end
	end
end

function tIndexOf(tbl, item)
	for i, v in ipairs(tbl) do
		if item == v then
			return i;
		end
	end
end

function tContains(tbl, item)
	return tIndexOf(tbl, item) ~= nil;
end

function tInvert(tbl)
	local inverted = {};
	for k, v in pairs(tbl) do
		inverted[v] = k;
	end
	return inverted;
end

function tFilter(tbl, pred, isIndexTable)
	local out = {};

	if (isIndexTable) then
		local currentIndex = 1;
		for i, v in ipairs(tbl) do
			if (pred(v)) then
				out[currentIndex] = v;
				currentIndex = currentIndex + 1;
			end
		end
	else
		for k, v in pairs(tbl) do
			if (pred(v)) then
				out[k] = v;
			end
		end
	end

	return out;
end

function CopyTable(settings)
	local copy = {};
	for k, v in pairs(settings) do
		if ( type(v) == "table" ) then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

function FindInTableIf(tbl, pred)
	for k, v in pairs(tbl) do
		if (pred(v)) then
			return k, v;
		end
	end

	return nil;
end

function Ambiguate(name, method)
	if method == "short" then
		name = gsub(name, "%-.+", "")
	end
	return name
end

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function UnitGUID (name)
   return "Player-FFF-ABCDF012"
end

-- Enable some globals
_G.gsub = string.gsub
_G.strfind = string.find
_G.strsplit = string.split
_G.strsub = string.sub
_G.tremove = table.remove
_G.strrep = string.rep
_G.tinsert = table.insert

-- Not part of the WoWAPI, but added to emulate the ingame /dump cmd
printtable = function( data, level )
	if not data then return end
	level = level or 0
	local ident=strrep('     ', level)
	if level>6 then return end
	if type(data)~='table' then print(tostring(data)) end;
	for index,value in pairs(data) do repeat
		if type(value)~='table' then
			print( ident .. '['..tostring(index)..'] = ' .. tostring(value) .. ' (' .. type(value) .. ')' );
			break;
		end
		print( ident .. '['..tostring(index)..'] = {')
        printtable(value, level+1)
        print( ident .. '}' );
	until true end
end

C_Timer = {After = function() end}
