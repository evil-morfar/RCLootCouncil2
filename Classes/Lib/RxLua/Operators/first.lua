--- @type RCLootCouncil
local addon = select(2, ...)
local Observable = addon.Require("rx.Observable")

--- Returns a new Observable that only produces the first result of the original.
-- @returns {Observable}
function Observable:first()
  return self:take(1)
end
