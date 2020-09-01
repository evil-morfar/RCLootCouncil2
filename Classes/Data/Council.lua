--- Council.lua Class for council handling.
-- @author Potdisc
-- Create Date: 15/04/2020

local _, addon = ...
local Council = addon.Init("Data.Council")
local Player = addon.Require "Data.Player"
local TT = addon.Require "Utils.TempTable"

local private = {
   council = {},
}

--- Returns the current council
-- Council is Player = true
function Council:Get ()
   return private.council
end

--- Sets the current council.
-- Format is {
--    [guid] = 'Data.Player'
-- }
function Council:Set (council)
   private.council = council
end

--- Returns the number of council members
function Council:GetNum ()
   return private:GetCouncilSize()
end

--- Adds a Player to the council.
-- @args player A 'Data.Player' object
-- @return The new council lenght
function Council:Add (player)
   if type(player) ~= "table" or not (player.name and player.guid) then
      error("Not a valid 'Player' object",2)
   end
   private.council[player.guid] = player
   return private:GetCouncilSize()
end

--- Removes a Player from the council
-- @args player A 'Data.Player' object
-- @return The new council lenght
function Council:Remove (player)
   if type(player) ~= "table" or not (player.name and player.guid) then
      error("Not a valid 'Player' object",2)
   end
   private.council[player.guid] = nil
   return private:GetCouncilSize()
end

--- Checks if a "Player" is in the council
-- @args player A 'Data.Player' object
-- @return boolean
function Council:Contains (player)
   local result = private.council[player.guid] ~= nil
   if addon.isMasterLooter or addon.nnp then result = true end
   return result
end

--- Gets the council table optimized for comms.
-- @return A "TempTable" with the council data.
function Council:GetForTransmit ()
   local tt = TT:Acquire()
   for _, player in pairs(private.council) do
      tt[player:GetForTransmit()] = true
   end
   return tt
end

--- Sets the currrent council to the received council.
-- @returns Lenght of the new council.
function Council:RestoreFromTransmit (council)
   wipe(private.council)
   for guid in pairs(council) do
      local player = Player:Get(guid)
      private.council[player.guid] = player
   end
   TT:Release(council)
   return private:GetCouncilSize()
end

function private:GetCouncilSize ()
   local size = 0
   for _ in pairs(self.council) do size = size + 1 end
   return size
end
