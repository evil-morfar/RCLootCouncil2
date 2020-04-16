--- Player.lua Class for holding player related data.
-- @author Potdisc
-- Create Date: 15/04/2020

local _, addon = ...
local Player = addon.Init("Data.Player")
local Log = addon.Require("Log"):Get()

local private = {}

local PLAYER_MT = {
   __index = {
      GetName = function (self)
         return self.name
      end,

      GetShortName = function (self)
         return Ambiguate(self.name, "short")
      end,

      GetRealm = function (self)
         return self.realm
      end,

      GetGUID = function (self)
         return self.guid
      end,

      GetForTransmit = function (self)
         return (gsub(self.guid, "Player%-", ""))
      end,

      --- Lazy call to GetPlayerInfoByGUID
      GetInfo = function (self)
         return GetPlayerInfoByGUID(self.guid)
      end
   },
   __tostring = function(self)
      return self.name
   end,
   __eq = function (a, b)
      return a.guid == b.guid
   end
}

function private:CreatePlayer (name)
   Log:f("<Data.Player>", "CreatePlayer", name)
   local Player = setmetatable({
      name = name
   }, PLAYER_MT)
end

function private:GetFromCache (name, guid)
   -- body...
end
