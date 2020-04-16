--- Council.lua Class for council handling.
-- @author Potdisc
-- Create Date: 15/04/2020

local _, addon = ...
local Council = addon.Init("Data.Council")

local private = {
   council = {}
}


--- Returns the current council
function Council:GetCouncil ()
   return private.council
end


function Council:SetCouncil (args)
   -- body...
end

function Council:GetCouncilForTransmit (args)
   -- body...
end

function Council:RestoreCouncilFromTransmit (args)
   -- body...
end
