require "busted.runner" ()

local addon = {
     db = { global = { log = {}, cache = {}, errors = {}, }, },
     defaults = { global = { logMaxEntries = 2000, }, },
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
               ["Player3-Realm2"] = {
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

describe("#Reconnect", function()
     describe("Basics", function()
          local expectedTransmitFormat = {
               ["00000002"] = {
                    ["|2"] = {
                         [1] = "137487:5890::::::::::35:3:3418:1597:3337"
                    },
                    ["|6"] = {
                         [1] = false,
                    },
               },
               ["1122-00000003"] = {
                    ["|2"] = {
                         [1] = "134491:5437::::::::::35:3:3418:1597:3337"
                    },
                    ["|6"] = {
                         [1] = 6,
                    },
               },
          }
          local expectedRestoredFormat = {
               ["Player3-Realm2"] = {
                    ["gear1"] = {
                         [1] = "item:134491:5437::::::::::35:3:3418:1597:3337"
                    },
                    ["response"] = {
                         [1] = 6,
                    },
               },
               ["Player2-Realm1"] = {
                    ["gear1"] = {
                         [1] = "item:137487:5890::::::::::35:3:3418:1597:3337"
                    },
                    ["response"] = {
                         [1] = "PASS"
                    },
               },
          }
          it("should create transmitable data without errors", function()
               assert.has_no.errors(function()
                    Reconnect:GetForTransmit(data)
               end)
          end)

          it("should turn into a specific format", function()
               assert.are.same(Reconnect:GetForTransmit(data), expectedTransmitFormat)
          end)

          it("should restore transmitted data to a specific format", function()
               assert.are.same(Reconnect:RestoreFromTransmit(expectedTransmitFormat), expectedRestoredFormat)
          end)
     end)

     describe("Extended", function()
          dofile ".specs/.matchers/Comparison.lua"
          dofile("Libs/AceSerializer-3.0/AceSerializer-3.0.lua")
          dofile("Libs/LibDeflate/LibDeflate.lua")
          local ld = LibStub("LibDeflate")
          local AceSer = LibStub("AceSerializer-3.0")

          local data1 = dofile "__tests/Reconnect/data1.lua"
          local data2 = dofile "__tests/Reconnect/data2.lua"
          local data3 = dofile "__tests/Reconnect/data3.lua"
          it("should handle transmit/recieve conversion of a larger dataset", function()
               assert.has_no.errors(function()
                    local transmit = Reconnect:GetForTransmit(data1)
                    Reconnect:RestoreFromTransmit(transmit)
               end)
          end)

          local function getDataSizes(data)
               local serialized = AceSer:Serialize(data)
               local compressed = ld:CompressDeflate(serialized, { level = 3, })
               local encoded = ld:EncodeForWoWAddonChannel(compressed)
               local originalDataSize = #encoded
               local transmit = Reconnect:GetForTransmit(data)
               compressed = ld:CompressDeflate(AceSer:Serialize(transmit), { level = 3, })
               encoded = ld:EncodeForWoWAddonChannel(compressed)
               return originalDataSize, #encoded
          end


          it("should create transmitable data at least 3 times smaller than the original (data1)", function()
               local originalDataSize, newDataSize = getDataSizes(data1)
               assert.gt(originalDataSize, newDataSize * 3)
          end)

          it("should create transmitable data at least 3 times smaller than the original (data2)", function()
               local originalDataSize, newDataSize = getDataSizes(data2)
               assert.gt(originalDataSize, newDataSize * 3)
          end)

          it("should create transmitable data at least 2.5 times smaller than the original (data3)", function()
               local _, _, data = AceSer:Deserialize(data3)

               local originalDataSize, newDataSize = getDataSizes(data[1])
               assert.gt(originalDataSize, newDataSize * 2.5)
          end)
     end)
end)


--- @type table<PlayerName, GUID>
local guidCache = {
     ["Player1"] = "00000001",
     ["Player2"] = "00000002",
     ["Player3"] = "00000003",
}
--- @type table<RealmName, GUID>
local realmGuidCache = {
     ["Realm1"] = "1",
     ["Realm2"] = "1122",
}

local function getRandomGUID(lenght, format)
     format = format or "%x"
     -- Generate random guid
     local guid = ""
     for i = 1, lenght do
          guid = guid .. string.format(format, math.random(0, format == "%x" and 16 or 10))
     end
     return guid
end

-- Creates memoized random guid's for each player/realm combination.
function _G.UnitGUID(name)
     local player, realm = strsplit("-", name, 2)
     if not realm then realm = addon.player:GetRealm() end
     if not realmGuidCache[realm] then
          realmGuidCache[realm] = getRandomGUID(4, "%d")
     end
     realm = realmGuidCache[realm]
     if not guidCache[player] then
          guidCache[player] = getRandomGUID(8)
     end
     player = guidCache[player]
     local guid = "Player-" .. realm .. "-" .. player
     -- print ("Created GUID for " .. name .. ": " .. guid)
     return guid
end
