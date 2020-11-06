-- Setup "is a" matchers
do
   local assert = require "luassert"
   local rx_util = require "rx".util
   local function isa (state, args)
      if not #args == 2 then return false end
      return rx_util.isa(args[1], args[2])
   end
   local s = require "say"
   s:set("assertion.isa.positive", "Expected object: %s \nto be of type %s")
   s:set("assertion.isa.negative", "Expected object: %s \nto not be of type %s")
   assert:register("assertion", "is_a", isa, "assertion.isa.positive", "assertion.isa.negative")
end
