require "busted.runner"{}
dofile ".specs/.matchers/isa.lua"
local addon = {
Getdb = function(self) return self.db end,
   realmName = "Realm1",
   db = {global = { log = {}, cache={}}},
   defaults = { global = {logMaxEntries = 2000}}
}
loadfile(".specs/AddonLoader.lua")(nil,nil, addon).LoadArray{
   [[Libs\LibStub\LibStub.lua]],
   [[Libs\CallbackHandler-1.0\CallbackHandler-1.0.xml]],
   [[Libs\AceComm-3.0\AceComm-3.0.xml]],
   [[Libs\AceSerializer-3.0\AceSerializer-3.0.xml]],
   [[Libs\AceEvent-3.0\AceEvent-3.0.xml]],
   [[Libs\AceLocale-3.0\AceLocale-3.0.xml]],
   [[Core\Constants.lua]],
   [[Classes\Core.lua]],
   [[Classes\Lib\RxLua\embeds.xml]],
   [[Libs\LibDeflate\LibDeflate.lua]],
   [[Classes\Utils\Log.lua]],
   [[Classes\Utils\TempTable.lua]],
   [[Classes\Services\ErrorHandler.lua]],
   [[Locale\enUS.lua]],
   [[Utils\Utils.lua]],
   [[Classes\Data\Player.lua]],
   [[Classes\Services\Comms.lua]],
}
addon:InitLogging()
local Player = addon.Require "Data.Player"

describe("#Services #Comms (basics)", function()
   addon.player = Player:Get("Player1")
   local Comms = addon.Require("Services.Comms")
   local Subscription = addon.Require("rx.Subscription")

   describe("init", function()
      it("should contain required functions", function()
         assert.is.Function(Comms.Subscribe)
         assert.is.Function(Comms.BulkSubscribe)
         assert.is.Function(Comms.GetSender)
         assert.is.Function(Comms.Send)
         assert.is.Function(Comms.RegisterPrefix)
      end)
   end)

   describe(":Subscribe", function()
      it("should fail with unregistered or nil prefix", function()
         assert.has.errors(function() Comms:Subscribe("PREFIX") end, "PREFIX is not a registered prefix!")
         assert.has.errors(function() Comms:Subscribe() end, "Prefix must be supplied")
      end)

      it("should return a Subscription", function()
         local sub = Comms:Subscribe(addon.PREFIXES.MAIN, "something", function() end)
         assert.is_a(sub, Subscription)
      end)

      it("should return different subscriptions", function()
         local sub1 = Comms:Subscribe(addon.PREFIXES.MAIN, "something", function() end)
         local sub2 = Comms:Subscribe(addon.PREFIXES.MAIN, "something", function() end)
         assert.is_a(sub1, Subscription)
         assert.is_a(sub2, Subscription)
         assert.are_not.equal(sub1, sub2)
      end)
   end)

   describe(":BulkSubscribe", function()
      it("fails with wrong data", function()
         assert.has.errors(Comms.BulkSubscribe, "Error - wrong data supplied.")
      end)

      it("should return an array of subscriptions", function()
         local ret = Comms:BulkSubscribe(addon.PREFIXES.MAIN, {
            comm1 = function() end,
            comm2 = function() end,
            comm3 = function() end,
            comm4 = function() end,
         })
         assert.is.table(ret)
         assert.equals(4, #ret)
         for _,v in ipairs(ret) do
            assert.is_a(v, Subscription)
         end
      end)
   end)

   describe(":GetSender", function()
      it("fails without prefix", function()
         assert.has.errors(Comms.GetSender, "Prefix must be supplied")
         assert.has.errors(function()Comms:GetSender(nil)end, "Prefix must be supplied")
         assert.has.errors(function()Comms:GetSender(false)end, "Prefix must be supplied")
         assert.has.errors(function()Comms:GetSender("")end, "Prefix must be supplied")
         assert.has.errors(function()Comms.GetSender("Prefix")end, "Prefix must be supplied")
      end)
      it("returns a function", function()
         assert.is.Function(Comms:GetSender("Prefix"))
      end)
   end)

   describe(":Send", function()
      it("fails with wrong input", function()
         assert.has.errors(Comms.Send,"Must supply a table")
         assert.has.errors(function() Comms:Send{} end,"Command must be set")
         assert.has.errors(function() Comms:Send{data=true} end,"Command must be set")
      end)
   end)

   describe(":RegisterPrefix", function()
      it("fails without a prefix", function()
         assert.has.errors(Comms.RegisterPrefix, "Prefix must be supplied")
         assert.has.errors(function()Comms:RegisterPrefix(nil)end, "Prefix must be supplied")
         assert.has.errors(function()Comms:RegisterPrefix(false)end, "Prefix must be supplied")
         assert.has.errors(function()Comms:RegisterPrefix("")end, "Prefix must be supplied")
         assert.has.errors(function()Comms.RegisterPrefix("Prefix")end, "Prefix must be supplied")
      end)
      it("succeeds with proper prefix", function()
         assert.has_no.errors(function() Comms:RegisterPrefix("Somethng") end)
      end)
   end)
end)

describe("#Services #Comms", function()
   local Comms = addon.Require("Services.Comms")
   local match = require "luassert.match"
   describe("sends", function()
      local _ = match._
      local onReceiveSpy, _sub
      local t = {receiver = function(data, sender, ...)
         -- print("RECEIVER:", dist, sender, unpack(data),...);
         return unpack(data)
      end}
      setup(function()
         _sub = Comms:Subscribe(addon.PREFIXES.MAIN, "test", function(...) t.receiver(...) end)
      end)

      teardown(function()
         _sub:unsubscribe()
      end)

      before_each(function()
         -- Make wow_api think we're in a raid
         _G.IsInRaidVal = true
         onReceiveSpy = spy.on(t, "receiver")
      end)

      it("with :GetSender", function()
         local data = "test"
         -- Test with simulated addon:Send() call
         Comms:GetSender(addon.PREFIXES.MAIN)(addon,"group", "test", data)
         WoWAPI_FireUpdate(GetTime()+10)
         assert.spy(onReceiveSpy).was_called(1)
         assert.spy(onReceiveSpy).returned_with(data)
         assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "RAID")
         -- And without
         Comms:GetSender(addon.PREFIXES.MAIN)("group", "test", data)
         WoWAPI_FireUpdate(GetTime()+10)
         assert.spy(onReceiveSpy).was_called(2)
         assert.spy(onReceiveSpy).returned_with(data)
         assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "RAID")

         onReceiveSpy:clear()

         local mock = {} -- Could be addon
         mock.Send = Comms:GetSender(addon.PREFIXES.MAIN)
         mock:Send("group", "test", data)
         WoWAPI_FireUpdate(GetTime()+10)
         assert.spy(onReceiveSpy).was_called(1)
         assert.spy(onReceiveSpy).returned_with(data)
         assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "RAID")

         mock.Send("guild", "test", data)
         WoWAPI_FireUpdate(GetTime()+10)
         assert.spy(onReceiveSpy).was_called(2)
         assert.spy(onReceiveSpy).returned_with(data)
         assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "GUILD")
      end)

      it("with :GetSender multiple args", function()
         local arg1,arg2,arg3 = 3, "test", {"args"}
         Comms:GetSender(addon.PREFIXES.MAIN)("group", "test", arg1,arg2,arg3)
         WoWAPI_FireUpdate(GetTime()+10)
         assert.spy(onReceiveSpy).was_called(1)
         assert.spy(onReceiveSpy).returned_with(arg1,arg2,arg3)
         assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "RAID")
      end)

      it("with different prefix", function()
         local prefix = "foo"
         local s = spy.new(function(...) return ... end)
         Comms:RegisterPrefix(prefix)
         Comms:Subscribe(prefix, "test",s)
         Comms:Send{
            prefix = prefix,
            command = "test",
            data = "Hi"
         }
         WoWAPI_FireUpdate(GetTime()+10)
         assert.spy(s).was_called(1)
      end)

      describe("in different group types", function()
         before_each(function()
            -- Ensure clean slate
            _G.IsPartyLFGVal = false
            _G.IsInRaidVal = false
            _G.IsInGroupVal = false
         end)

         it("LFG", function()
            _G.IsPartyLFGVal = true
            Comms:GetSender(addon.PREFIXES.MAIN)("group", "test")
            WoWAPI_FireUpdate(GetTime()+10)
            assert.spy(onReceiveSpy).was_called(1)
            assert.spy(onReceiveSpy).returned_with()
            assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "INSTANCE_CHAT")
         end)

         it("Party", function()
            _G.IsInGroupVal = true
            Comms:GetSender(addon.PREFIXES.MAIN)("group", "test")
            WoWAPI_FireUpdate(GetTime()+10)
            assert.spy(onReceiveSpy).was_called(1)
            assert.spy(onReceiveSpy).returned_with()
            assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "PARTY")
         end)

         it("guild", function()
            Comms:GetSender(addon.PREFIXES.MAIN)("guild", "test")
            WoWAPI_FireUpdate(GetTime()+10)
            assert.spy(onReceiveSpy).was_called(1)
            assert.spy(onReceiveSpy).returned_with()
            assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "GUILD")
         end)

         it("none", function()
            -- pending("Requires implementation of playerNames")
            Comms:GetSender(addon.PREFIXES.MAIN)("group", "test")
            WoWAPI_FireUpdate(GetTime()+10)
            assert.spy(onReceiveSpy).was_called(1)
            assert.spy(onReceiveSpy).returned_with()
            assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "WHISPER")
         end)
      end)

      describe("with :Send", function()
         it("basics", function()
            local data = "test2"
            Comms:Send{
               prefix = addon.PREFIXES.MAIN,
               command = "test",
               data = data
            }

            WoWAPI_FireUpdate(GetTime()+10)
            assert.spy(onReceiveSpy).was_called(1)
            assert.spy(onReceiveSpy).returned_with(data)
            assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "RAID")
         end)

         it("with 'ALERT' prio", function()
            local data = "ALERT PRIO"
            Comms:Send{
               prefix = addon.PREFIXES.MAIN,
               command = "test",
               data = data,
               prio = "ALERT"
            }

            WoWAPI_FireUpdate(GetTime()+10)
            assert.spy(onReceiveSpy).was_called(1)
            assert.spy(onReceiveSpy).returned_with(data)
            assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "RAID")
         end)
         it("with 'BULK' prio", function()
            local data = "BULK PRIO"
            Comms:Send{
               prefix = addon.PREFIXES.MAIN,
               command = "test",
               data = data,
               prio = "BULK"
            }

            WoWAPI_FireUpdate(GetTime()+10)
            assert.spy(onReceiveSpy).was_called(1)
            assert.spy(onReceiveSpy).returned_with(data)
            assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "RAID")
         end)

         it("with callback func", function()
            local s = spy.new(function(...) end)
            local data = "a"
            Comms:Send{
               prefix = addon.PREFIXES.MAIN,
               command = "test",
               data = data,
               callback = s
            }
            WoWAPI_FireUpdate(GetTime()+10)
            assert.spy(onReceiveSpy).was_called(1)
            assert.spy(onReceiveSpy).returned_with(data)
            assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "RAID")

            assert.spy(s).was_called(1)
            assert.spy(s).was_called_with(nil, match.is_number(), match.is_number())
         end)

         it("with callback func multiple messages", function()
            local s = spy.new(function()end)
            -- Now to construct data that will produce two messages with LibDeflate :/
            local data = {}
            for i=1,150 do
               data[i] = {}
            end
            Comms:Send{
               prefix = addon.PREFIXES.MAIN,
               command = "test",
               data = {data},
               callback = s
            }
            WoWAPI_FireUpdate(GetTime()+10)
            assert.spy(onReceiveSpy).was_called(1)
            assert.spy(onReceiveSpy).returned_with(data)
            assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "RAID")

            assert.spy(s).was_called(2)
            assert.spy(s).was_called_with(nil, match.is_number(), match.is_number())
         end)

         it("with callback func and arg", function()
            local s = spy.new(function(...) end)
            local data = "a"
            local arg = {}
            Comms:Send{
               prefix = addon.PREFIXES.MAIN,
               command = "test",
               data = data,
               callback = s,
               callbackarg = arg
            }
            WoWAPI_FireUpdate(GetTime()+10)
            assert.spy(onReceiveSpy).was_called(1)
            assert.spy(onReceiveSpy).returned_with(data)
            assert.spy(onReceiveSpy).was_called_with(match.is_table(), "Sender-Realm1", "test", "RAID")

            assert.spy(s).was_called(1)
            assert.spy(s).was_called_with(arg, match.is_number(), match.is_number())
         end)

      end)

   end)

   describe("receives", function()
      it("the same data with both senders", function()
         local rec1, rec2
         local prefix = addon.PREFIXES.VERSION
         local cmd1 = ":GetSender"
         local cmd2 = ":Send"
         local data = {
            "test",
            ["our"] = "data"
         }
         local data2 = "structure"
         Comms:BulkSubscribe(prefix, {
            [cmd1] = function(data) rec1 = data end,
            [cmd2] = function(data) rec2 = data end
         })

         Comms:GetSender(prefix)("group", cmd1, data, data2)
         Comms:Send{
            prefix = prefix,
            command = cmd2,
            data = {data, data2}
         }
         WoWAPI_FireUpdate(GetTime()+10)
         assert.are.same(rec1, rec2)
      end)

      it("handles unsubscribe", function()
         local s = spy.new(function(data,sender,command, dist) return unpack(data) end)
         local sub = Comms:Subscribe(addon.PREFIXES.MAIN, "test", s)
         local data = "test"
         Comms:Send{
            prefix = addon.PREFIXES.MAIN,
            command = "test",
            data = data
         }
         WoWAPI_FireUpdate(GetTime()+10)
         assert.spy(s).was_called(1)
         assert.spy(s).returned_with(data)
         sub:unsubscribe()
         Comms:Send{
            prefix = addon.PREFIXES.MAIN,
            command = "something else that shouldn't be received",
            data = data
         }
         WoWAPI_FireUpdate(GetTime()+10)
         assert.spy(s).was_called(1)
         assert.spy(s).returned_with(data)
      end)
   end)

   it("should send cross realm, send to other realm", function()
      local s = spy.new(function(data,sender,command, dist) return unpack(data) end)
      local sub = Comms:Subscribe(addon.PREFIXES.MAIN, "test", s)
      local target = Player:Get("Player3")
      local data = "test"
      Comms:Send{
         command = "test",
         data = data,
         target = target
      }
      WoWAPI_FireUpdate(GetTime()+10)
      assert.spy(s).was_called(0) -- Shouldn't be called as we are not on the same realm as target
   end)
   it("should receive cross realm messages", function()
      local s = spy.new(function(data,sender,command, dist) return unpack(data) end)
      Comms:Subscribe(addon.PREFIXES.MAIN, "test", s)
      local target = Player:Get("Player1")
      local data = "test"
      addon.realmName = "something else"
      Comms:Send{
         command = "test",
         data = data,
         target = target
      }
      WoWAPI_FireUpdate(GetTime()+10)
      assert.spy(s).was_called(1)
      assert.spy(s).returned_with(data)
   end)

   it("should send to a specific target", function()
      local s = spy.new(function(data,sender,command, dist) return unpack(data) end)
      Comms:Subscribe(addon.PREFIXES.MAIN, "test", s)
      local target = Player:Get("Player1")
      addon.realmName = target:GetRealm()
      local data = "test"
      Comms:Send{
         command = "test",
         data = data,
         target = target
      }
      WoWAPI_FireUpdate(GetTime()+10)
      assert.spy(s).was_called(1)
      assert.spy(s).returned_with(data)
   end)
end)
