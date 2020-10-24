require "busted.runner"()
local addonName, addon = "RCLootCouncil_Test", {
   db = {global = { log = {}, cache = {}}},
   defaults = { global = {logMaxEntries = 2000}}
}
loadfile(".specs/AddonLoader.lua")(nil, addonName, addon).LoadArray{
   [[Libs\LibStub\LibStub.lua]],
   [[Libs\CallbackHandler-1.0\CallbackHandler-1.0.xml]],
   [[Libs\AceLocale-3.0\AceLocale-3.0.xml]],
   [[Libs\AceEvent-3.0\AceEvent-3.0.xml]],
   [[Classes/Core.lua]],
   [[Classes/Utils/Log.lua]],
   [[Classes/Services/ErrorHandler.lua]],
   [[Classes/Data/Player.lua]],
   [[Locale\enUS.lua]],
   [[Utils\Utils.lua]]
}
addon:InitLogging()

describe("#Player", function()
   local Player
   before_each(function()
      Player = addon.Require("Data.Player")
   end)

      describe("Init", function()
         it("should create 'Data.Player' module", function()
         assert.not_nil(Player)
         assert.is.table(Player)
      end)

      it("should have certain functions", function()
         assert.is.Function(Player.Get)
      end)

      it("'Player' object should have certain functions", function()
         local player = Player:Get("Player1")
         assert.is.Function(player.GetName)
         assert.is.Function(player.GetClass)
         assert.is.Function(player.GetShortName)
         assert.is.Function(player.GetRealm)
         assert.is.Function(player.GetGUID)
         assert.is.Function(player.GetForTransmit)
         assert.is.Function(player.GetInfo)
         --assert.is.Function(player.tostring)
         assert.True(player == player)
      end)
   end)

   describe("class", function()
      before_each(function()
         addon.db.global.cache = {}
      end)

      it("stores correct info", function()
         local p = Player:Get("Player2")
         assert.are.equal("Player2-Realm1", p:GetName())
         assert.are.equal("WARRIOR", p:GetClass())
         assert.are.equal("Player2", p:GetShortName())
         assert.are.equal(p:GetRealm(), "Realm1")
         assert.are.equal(p:GetGUID(), "Player-1-00000002")
         assert.are.equal("WARRIOR", select(2, p:GetInfo()))
         assert.are.equal(p:GetForTransmit(), "1-00000002")
      end)

      it("handles invalid input", function()
         assert.has.errors(
         function()
            Player:Get()
         end, "nil invalid player")
         assert.has.errors(function()
            Player:Get(1)
         end, "1 invalid player")
      end)

      it("is printable", function()
         local p = Player:Get("Player1")
         assert.are.equal(tostring(p), "Player1-Realm1")
      end)

      it("is compareable", function()
         local p1 = Player:Get("Player1")
         assert.are.equal(p1, p1)
         local p2 = Player:Get("Player2")
         assert.are.equal(p2, p2)
         assert.are_not.equal(p1, p2)
      end)

      it("is cached", function()
         local playerA = Player:Get("Player1") -- Should be cached after creation
         local playerB = Player:Get("Player1")
         assert.are_not_nil(playerB.cache_time)
         assert.are.equal(playerA, playerB)
      end)

      it("fetches player from guid", function()
         local player = Player:Get("Player-1122-00000003")
         assert.are.equal("Player3-Realm2", player:GetName())
      end)

      it("fetches player from stripped guid", function()
         local player = Player:Get("1-00000002")
         assert.are.equal("Player2-Realm1", player:GetName())
      end)
   end)
end)
