--- Player.lua Class for holding player related data.
-- @author Potdisc
-- Create Date: 15/04/2020

local _, addon = ...
local Player = addon.Init("Data.Player")
local Log = addon.Require("Log"):Get()

local private = {
   cache = setmetatable({}, {
      __index = function(_, id)
      if not addon.db.global.cache.player then
         addon.db.global.cache.player = {}
      end
      return addon.db.global.cache.player[id]
   end,
   __newindex = function(_, k,v)
      addon.db.global.cache.player[k] = v
   end
})}

local PLAYER_MT = {
   __index = {
      GetName = function (self)
         return self.name
      end,

      GetClass = function(self)
         return self.class
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

--- Fetches a player
-- @tparam input string A player name or GUID
-- @return Player
function Player:Get (input)
   -- Decide if input is a name or guid
   local guid
   if input and not strmatch(input, "Player%-") and strmatch(input, "%x%x%x%-%x%x%x%x%x%x%x%x") then
      -- GUID without "Player-"
      guid = "Player-"..input
   elseif input and strmatch(input, "%x%x%x%-%x%x%x%x%x%x%x%x") then
      -- GUID with player
      guid = input
   elseif type(input) == "string" then
      -- Assume UnitName
      guid = UnitGUID(input)
   else
      error(format("%s invalid player", tostring(input)), 2)
   end
   local Player = private:GetFromCache(guid)
   if not Player then
      Player = private:CreatePlayer(guid)
   end
   return Player
end

function private:CreatePlayer (guid)
   Log:f("<Data.Player>", "CreatePlayer", guid)
   local _, class, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
   realm = realm == "" and select(2, UnitFullName("player")) or realm
   local player = setmetatable({
      name = name,
      guid = guid,
      class = class,
      realm = realm
   }, PLAYER_MT)
   private:CachePlayer(player)
   return player
end

function private:GetFromCache (guid)
   if self.cache[guid] then
      return setmetatable(CopyTable(self.cache[guid]), PLAYER_MT)
   end
end

function private:CachePlayer (player)
   self.cache[player.guid] = CopyTable(player)
   self.cache[player.guid].cache_time = GetServerTime()
end
