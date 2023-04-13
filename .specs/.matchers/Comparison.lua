local assert = require "luassert"

local function GreaterThan(state, args)
    local lhs = args[1]
    local rhs = args[2]

    return lhs > rhs
end

local function LessThan(state, args)
    return not GreaterThan(state, args)
end

local function GreaterThanOrEqual(state, args)
    local lhs = args[1]
    local rhs = args[2]
    return lhs >= rhs
end

local function LessThanOrEqual(state, args)
    return not GreaterThanOrEqual(state, args)
end

local s = require "say"
s:set("assertion.greater_than.positive", "Expected %s to be greater than %s")
s:set("assertion.greater_than.negative", "Expected %s to not be greater than %s")
assert:register("assertion", "greater_than", GreaterThan, "assertion.greater_than.positive", "assertion.greater_than.negative")
assert:register("assertion", "gt", GreaterThan, "assertion.greater_than.positive", "assertion.greater_than.negative")

s:set("assertion.less_than.positive", "Expected %s to be less than %s")
s:set("assertion.less_than.negative", "Expected %s to not be less than %s")
assert:register("assertion", "less_than", LessThan, "assertion.less_than.positive", "assertion.less_than.negative")
assert:register("assertion", "lt", LessThan, "assertion.less_than.positive", "assertion.less_than.negative")

s:set("assertion.greater_than_or_equal.positive", "Expected %s to be greater than or equal to %s")
s:set("assertion.greater_than_or_equal.negative", "Expected %s to not be greater than or equal to %s")
assert:register("assertion", "greater_than_or_equal", GreaterThanOrEqual, "assertion.greater_than_or_equal.positive", "assertion.greater_than_or_equal.negative")
assert:register("assertion", "gte", GreaterThanOrEqual, "assertion.greater_than_or_equal.positive", "assertion.greater_than_or_equal.negative")

s:set("assertion.less_than_or_equal.positive", "Expected %s to be less than or equal to %s")
s:set("assertion.less_than_or_equal.negative", "Expected %s to not be less than or equal to %s")
assert:register("assertion", "less_than_or_equal", LessThanOrEqual, "assertion.less_than_or_equal.positive", "assertion.less_than_or_equal.negative")
assert:register("assertion", "lte", LessThanOrEqual, "assertion.less_than_or_equal.positive", "assertion.less_than_or_equal.negative")
