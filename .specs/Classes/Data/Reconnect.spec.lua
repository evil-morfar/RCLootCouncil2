local addon = {
     db = { global = { log = {}, cache = {}, errors = {} } },
     defaults = { global = { logMaxEntries = 2000 } }
}

loadfile(".specs/AddonLoader.lua")(nil, nil, addon).LoadArray {
     "Libs/LibStub/Libstub.lua",
     [[Libs\CallbackHandler-1.0\CallbackHandler-1.0.xml]],
     [[Libs\AceLocale-3.0\AceLocale-3.0.xml]],
     "Libs/AceEvent-3.0/AceEvent-3.0.xml",
     [[Classes/Core.lua]],
     "Classes/Utils/TempTable.lua",
     [[Classes/Utils/Log.lua]],
     "Classes/Services/ErrorHandler.lua",
     [[Classes/Data/Player.lua]],
     [[Classes/Data/Reconnect.lua]],
     [[Locale\enUS.lua]],
     [[Utils\Utils.lua]],
}
addon:InitLogging()

local Reconnect = addon.Require "Data.Reconnect"
local Player = addon.Require "Data.Player"
addon.player = Player:Get("player")
-- local data = dofile "__tests/Reconnect/data2.lua"
local data = {
     {
          ["equipLoc"] = "INVTYPE_NECK",
          ["haveVoted"] = false,
          ["awarded"] = "жермейн-Ревущийфьорд",
          ["link"] = "|cffa335ee|Hitem:151965::::::::110:64::3:3:3610:1472:3528:::|h[Кулон из недр вулкана]|h|r",
          ["texture"] = 1360044,
          ["typeID"] = 4,
          ["subType"] = "Разное",
          ["relic"] = false,
          ["subTypeID"] = 0,
          ["lootSlot"] = 2,
          ["name"] = "Кулон из недр вулкана",
          ["classes"] = 4294967295,
          ["ilvl"] = 930,
          ["boe"] = false,
          ["quality"] = 4,
          ["candidates"] = {
               ["Player2"] = {
                    ["haveVoted"] = false,
                    ["ilvl"] = 942.9375,
                    ["class"] = "ROGUE",
                    ["response"] = "PASS",
                    ["voters"] = {
                    },
                    ["role"] = "DAMAGER",
                    ["diff"] = -15,
                    ["votes"] = 0,
                    ["specID"] = 259,
                    ["isRelic"] = false,
                    ["gear1"] = "|cffa335ee|Hitem:137487:5890:::::::110:259::35:3:3418:1597:3337:::|h[Ожерелье звезд]|h|r",
                    ["rank"] = "Четвертый",
               },
               ["Player3"] = {
                    ["haveVoted"] = false,
                    ["ilvl"] = 945.375,
                    ["class"] = "DEATHKNIGHT",
                    ["response"] = 6,
                    ["voters"] = {
                    },
                    ["role"] = "DAMAGER",
                    ["diff"] = -15,
                    ["votes"] = 0,
                    ["specID"] = 251,
                    ["isRelic"] = false,
                    ["gear1"] = "|cffa335ee|Hitem:134491:5437:::::::110:251::35:3:3418:1597:3337:::|h[Ожерелье Подкаменного разлома]|h|r",
                    ["rank"] = "Четвертый",
               },
          },
     },
}
local new = Reconnect:GetForTransmit(data)
-- printtable(new)
local old = Reconnect:RestoreFromTransmit(new)
printtable(old)