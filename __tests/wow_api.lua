local _G = getfenv(0)
local strbyte, strchar, gsub, gmatch, format, tinsert = string.byte, string.char, string.gsub, string.gmatch, string.format, table.insert

local donothing = function() end

local frames = {} -- Stores globally created frames, and their internal properties.

local FrameClass = {} -- A class for creating frames.
FrameClass.methods = { "SetScript", "GetScript", "RegisterEvent", "UnregisterEvent", "UnregisterAllEvents", "Show", "Hide", "IsShown", "ClearAllPoints", "SetParent","SetPoint","SetFrameStrata","SetAllPoints", "SetBackdrop","EnableMouse","SetBackdropColor", "SetBackdropBorderColor", "CreateFontString", "SetWidth","SetHeight","SetSize", "GetParent", "SetFrameLevel", "GetFrameLevel", "SetNormalTexture","GetNormalTexture","SetPushedTexture","GetPushedTexture","SetHighlightTexture","GetHighlightTexture", "CreateTexture", "SetFontString","SetNormalFontObject","SetHighlightFontObject","SetDisabledFontObject", "SetID","SetText", "SetToplevel" }
function FrameClass:New()
   local frame = {}
   for i, method in ipairs(self.methods) do
      frame[method] = self[method]
   end
   local frameProps = {
      events = {},
      scripts = {},
      values = {},
      timer = GetTime(),
      isShow = true,
      parent = nil,
   }
   return frame, frameProps
end
function FrameClass:SetScript(script, handler)
   frames[self].scripts[script] = handler
end
function FrameClass:GetScript (script)
   return frames[self].scripts[script]
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
function FrameClass:SetPoint (...)
   -- body...
end
function FrameClass:SetFrameStrata (...)
   -- body...
end
function FrameClass:EnableMouse (...)
   -- body...
end
function FrameClass:SetAllPoints (...)
   -- body...
end
function FrameClass:SetBackdrop (...)
   -- body...
end
function FrameClass:SetBackdropColor (...)
   -- body...
end
function FrameClass:SetBackdropBorderColor (...)
   -- body...
end
function FrameClass:SetWidth (...)
   -- body...
end
function FrameClass:SetHeight (...)
   -- body...
end
function FrameClass:SetSize (h,w)
   self:SetHeight(h)
   self:SetWidth(w)
end
function FrameClass:SetNormalTexture (...)

end
function FrameClass:GetNormalTexture (...)
   return self:CreateTexture()
end
function FrameClass:SetPushedTexture (...)

end
function FrameClass:GetPushedTexture (...)
   return self:CreateTexture()
end
function FrameClass:SetHighlightTexture (...)

end
function FrameClass:GetHighlightTexture (...)
   return self:CreateTexture()
end
function FrameClass:SetFontString (...)
   -- body...
end
function FrameClass:SetNormalFontObject (...)end
function FrameClass:SetHighlightFontObject (...)end
function FrameClass:SetDisabledFontObject (...)end
function FrameClass:SetID (...)end
function FrameClass:SetText (...)end
function FrameClass:SetToplevel (...)end
function FrameClass:GetParent (...)
   return frames[self].parent
end
function FrameClass:SetFrameLevel (lvl)
   frames[self].values.FrameLevel = lvl
end
function FrameClass:GetFrameLevel (...)
   return frames[self].values.FrameLevel or 0
end



function FrameClass:CreateFontString () -- Very much a mock
   return {
      SetPoint = function (args)
         -- body...
      end,
      SetJustifyH = function (args)
         -- body...
      end,
      SetJustifyV = function (args)
         -- body...
      end,
      SetText = function (args)
         -- body...
      end,
      SetSize = function()

      end,
   }
end

function FrameClass:CreateTexture (name, strata)
   local mt = {
      __index = {
         SetTexture = function (args)
            -- body...
         end,
         SetTexCoord = function (args)
            -- body...
         end,
         SetBlendMode = function (args)
            -- body...
         end,
         SetVertexColor = function (args)
            -- body...
         end,
         SetNormalTexture = function (args)
            -- body...
         end
      }
   }
   local texture = CreateFrame("Texture", name, self)
   return setmetatable(texture, mt)
end

-- Extra hack as I didn't want to implement logic for all the UI functions
MSA_DropDownList1Button1NormalText = {
   GetFont = function (args)
      -- body...
   end
}

-- It seems Wow doesn't follow the 5.1 spec for xpcall (no additional arguments),
-- but instead the one from 5.2 where that's allowed.
-- Try to recreate that here.
local orig_xpcall = xpcall
function xpcall (f, err, ...)
   local status, code = pcall(f, ...)
   if not status then
      return err(code)
   else
      return status, code
   end
end

function InterfaceOptions_AddCategory ()
   -- body...
end

function ChatFrame_AddMessageEventFilter ()
   -- body...
end

function LoadAddOn (args)
   return "Not implemented!"
end

function CreateFrame(kind, name, parent)
   local frame, internal = FrameClass:New()
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

function UnitFullName (unit)
   return UnitName(unit), GetRealmName()
end

function GetBuildInfo ()
   return "mock", "mock","mock", 0
end

function GetRealmName()
   return "Realm Name"
end

function GetLootMethod ()
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

function GetNumRaidMembers()
   return 1
end

function GetNumPartyMembers()
   return 1
end

function issecurevariable (obj, method)
   return false
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
   end;
   print("No command found:", text)
end

local ChatFrameTemplate = {
   AddMessage = function(self, text)
      print((string.gsub(text, "|c%x%x%x%x%x%x%x%x(.-)|r", "%1")))
   end
}

for i = 1, 7 do
   local f = {}
   for k, v in pairs(ChatFrameTemplate) do
      f[k] = v
   end
   _G["ChatFrame"..i] = f
end
DEFAULT_CHAT_FRAME = ChatFrame1

debugstack = debug.traceback
date = os.date

function GetAddOnMetadata(arg)
   return "NOT_IMPLEMENTED"
end

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

function GetInstanceInfo()
   return "The Eternal Palace", nil, 14, "Normal", _,_,_,2164
end

function IsInGuild ()
   return false
end

function GuildRoster ()
   -- body...
end

function getglobal(k)
   return _G[k]
end

function setglobal(k, v)
   _G[k] = v
end

function _errorhandler(msg)
   error(msg,2)--print("--------- geterrorhandler error -------\n"..msg.."\n-----end error-----\n")
end

function geterrorhandler()
   return _errorhandler
end

function seterrorhandler()

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

time = os.time

strmatch = string.match

function SendChatMessage(text, chattype, language, destination)
   assert(#text < 255)
   WoWAPI_FireEvent("CHAT_MSG_"..strupper(chattype), text, "Sender", language or "Common")
end

local registeredPrefixes = {}
function RegisterAddonMessagePrefix(prefix)
   assert(#prefix <= 16) -- tested, 16 works /mikk, 20110327
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
         tbl[k] = nil
      end
   end
end

table.wipe = wipe

function ChatEdit_InsertLink ()
   -- body...
end

function StaticPopup_SetUpPosition (args)
   -- body...
end

function StaticPopup_EscapePressed (args)
   -- body...
end
InterfaceOptionsFrameCancel = {
   GetScript = function(input) return input end
}
C_CreatureInfo = {
   GetClassInfo = function(classIndex) return end
}

function UIDropDownMenu_InitializeHelper (args)
   -- body...
end

function hooksecurefunc(func_name, post_hook_func)
   local orig_func = _G[func_name]
   assert(type(orig_func) == "function")

   _G[func_name] = function (...)
      local ret = { orig_func(...) } -- yeahyeah wasteful, see if i care, it's a test framework
      post_hook_func(...)
      return unpack(ret)
   end
end

RED_FONT_COLOR_CODE = ""
GREEN_FONT_COLOR_CODE = ""

StaticPopupDialogs = {}

function WoWAPI_FireEvent(event, ...)
   for frame, props in pairs(frames) do
      if props.events[event] then
         if props.scripts["OnEvent"] then
            for i = 1, select('#', ...) do
               _G["arg"..i] = select(i, ...)
            end
            _G.event = event
            props.scripts["OnEvent"](frame, event, ...)
         end
      end
   end
end

function WoWAPI_FireUpdate(forceNow)
   if forceNow then
      _time = forceNow
   end
   local now = GetTime()
   for frame, props in pairs(frames) do
      if props.isShow and props.scripts.OnUpdate then
         if now == 0 then
            props.timer = 0 -- reset back in case we reset the clock for more testing
         end
         _G.arg1 = now - props.timer
         props.scripts.OnUpdate(frame, now - props.timer)
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
   for i = 1, select("#", ...) do
      local v = select(i, ...)
      if type(v) == "string" then
         tinsert(t, string.format("%q", v))
      elseif type(v) == "table" then
         tinsert(t, tostring(v).." #"..#v)
      else
         tinsert(t, tostring(v))
      end
   end
   return "<"..table.concat(t, "> <")..">"
end

function Ambiguate(name, method)
   if method == "short" then
      name = gsub(name, "%-.+", "")
   end
   return name
end

function string.split(sep, s, pieces)
   sep=sep or '%s'
   local t={}
   for field,s in string.gmatch(s, "([^"..sep.."]*)("..sep.."?)") do
      table.insert(t,field)
      if (pieces and #t >= pieces) or s=="" then
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
      class = "WARRIOR"
   },
   Player2 = {
      guid = "Player-1-00000002",
      name = "Player2-Realm1",
      realm = "Realm1",
      class = "WARRIOR"
   },
   Player3 = {
      guid = "Player-1122-00000003",
      name = "Player3-Realm2",
      realm = "Realm2",
      class = "WARRIOR"
   },
}

local playerGUIDInfo = {}
for _, info in pairs(playerNameToGUID) do
   playerGUIDInfo[info.guid] = info
end

function UnitGUID (name)
   return playerNameToGUID[name] and playerNameToGUID[name].guid or "Player-FFF-ABCDF012"
end

function GetPlayerInfoByGUID (guid)
   local player = playerGUIDInfo[guid]
   if player then
      return nil,player.class, nil,nil,nil, Ambiguate(player.name, "short"), player.realm
   else
      return nil, "HUNTER", nil,nil,nil, "Unknown", "Unknown"
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

-- Not part of the WoWAPI, but added to emulate the ingame /dump cmd
printtable = function( data, level )
   if not data then return end
   level = level or 0
   local ident = strrep('     ', level)
   if level > 6 then return end
   if type(data) ~= 'table' then print(tostring(data)) end;
      for index, value in pairs(data) do repeat
      if type(value) ~= 'table' then
         print( ident .. '['..tostring(index)..'] = ' .. tostring(value) .. ' (' .. type(value) .. ')' );
         break;
      end
      print( ident .. '['..tostring(index)..'] = {')
      printtable(value, level + 1)
      print( ident .. '}' );
   until true end
end

C_Timer = {After = function(delay, callback) callback() end}

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

function GetNumClasses ()
   return 12
end

function GetNumSpecializationsForClassID (classID)
   return #CLASS_INFO[classID].specs
end

function GetClassInfo (classIndex)
   return CLASS_INFO[classIndex].className, CLASS_INFO[classIndex].classFile, CLASS_INFO[classIndex].classID
end

function GetSpecializationInfoForClassID (classID, specNum)
   local spec = CLASS_INFO[classID].specs[specNum]
   return spec.specID, spec.name, "NOT_IMPLEMENTED", spec.iconID, spec.role, "NOT_IMPLEMENTED","NOT_IMPLEMENTED"
end

------------------------------------------
-- Constants from various places
------------------------------------------
TOOLTIP_DEFAULT_COLOR = { r = 1, g = 1, b = 1 };
TOOLTIP_DEFAULT_BACKGROUND_COLOR = { r = 0.09, g = 0.09, b = 0.19 };
NUM_LE_ITEM_ARMORS = 12
LE_ITEM_ARMOR_GENERIC = 0
LE_ITEM_ARMOR_CLOTH = 1
LE_ITEM_ARMOR_LEATHER = 2
LE_ITEM_ARMOR_MAIL = 3
LE_ITEM_ARMOR_PLATE = 4
LE_ITEM_ARMOR_COSMETIC = 5
LE_ITEM_ARMOR_SHIELD = 6
LE_ITEM_ARMOR_LIBRAM = 7
LE_ITEM_ARMOR_IDOL = 8
LE_ITEM_ARMOR_TOTEM = 9
LE_ITEM_ARMOR_SIGIL = 10
LE_ITEM_ARMOR_RELIC = 11

NUM_LE_ITEM_BIND_TYPES = 5
LE_ITEM_BIND_NONE = 0
LE_ITEM_BIND_ON_ACQUIRE = 1
LE_ITEM_BIND_ON_EQUIP = 2
LE_ITEM_BIND_ON_USE = 3
LE_ITEM_BIND_QUEST = 4
NUM_LE_ITEM_QUALITYS = 9
LE_ITEM_QUALITY_POOR = 0
LE_ITEM_QUALITY_COMMON = 1
LE_ITEM_QUALITY_UNCOMMON = 2
LE_ITEM_QUALITY_RARE = 3
LE_ITEM_QUALITY_EPIC = 4
LE_ITEM_QUALITY_LEGENDARY = 5
LE_ITEM_QUALITY_ARTIFACT = 6
LE_ITEM_QUALITY_HEIRLOOM = 7
LE_ITEM_QUALITY_WOW_TOKEN = 8
NUM_LE_ITEM_CLASSS = 19
LE_ITEM_CLASS_CONSUMABLE = 0
LE_ITEM_CLASS_CONTAINER = 1
LE_ITEM_CLASS_WEAPON = 2
LE_ITEM_CLASS_GEM = 3
LE_ITEM_CLASS_ARMOR = 4
LE_ITEM_CLASS_REAGENT = 5
LE_ITEM_CLASS_PROJECTILE = 6
LE_ITEM_CLASS_TRADEGOODS = 7
LE_ITEM_CLASS_ITEM_ENHANCEMENT = 8
LE_ITEM_CLASS_RECIPE = 9
LE_ITEM_CLASS_QUIVER = 11
LE_ITEM_CLASS_QUESTITEM = 12
LE_ITEM_CLASS_KEY = 13
LE_ITEM_CLASS_MISCELLANEOUS = 15
LE_ITEM_CLASS_GLYPH = 16
LE_ITEM_CLASS_BATTLEPET = 17
LE_ITEM_CLASS_WOW_TOKEN = 18
NUM_LE_ITEM_WEAPONS = 21
LE_ITEM_WEAPON_AXE1H = 0
LE_ITEM_WEAPON_AXE2H = 1
LE_ITEM_WEAPON_BOWS = 2
LE_ITEM_WEAPON_GUNS = 3
LE_ITEM_WEAPON_MACE1H = 4
LE_ITEM_WEAPON_MACE2H = 5
LE_ITEM_WEAPON_POLEARM = 6
LE_ITEM_WEAPON_SWORD1H = 7
LE_ITEM_WEAPON_SWORD2H = 8
LE_ITEM_WEAPON_WARGLAIVE = 9
LE_ITEM_WEAPON_STAFF = 10
LE_ITEM_WEAPON_BEARCLAW = 11
LE_ITEM_WEAPON_CATCLAW = 12
LE_ITEM_WEAPON_UNARMED = 13
LE_ITEM_WEAPON_GENERIC = 14
LE_ITEM_WEAPON_DAGGER = 15
LE_ITEM_WEAPON_THROWN = 16
LE_ITEM_WEAPON_CROSSBOW = 18
LE_ITEM_WEAPON_WAND = 19
LE_ITEM_WEAPON_FISHINGPOLE = 20

------------------------------------------
-- Global Strings
------------------------------------------
LOOT_ITEM = "%s receives loot: %s."
RANDOM_ROLL_RESULT = "%s rolls %d (%d-%d)"
REQUEST_ROLL = "Request Roll"
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

BLOCK = "Block"
PARRY = "Parry"
DAMAGER = "Damage"
TANK = "Tank"
HEALER = "Healer"
MELEE = "Melee"
RANGED = "Ranged"

dofile "__tests/wow_api/Mixin.lua"
dofile "__tests/wow_api/Color.lua"
dofile "__tests/wow_api/TableUtil.lua"