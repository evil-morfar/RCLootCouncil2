require "luacov"
local lu = require("luaunit")

local path = "__tests/"

require(path.."wow_api")
require(path.."wow_item_api")
require(path.."__load_libs")
require(path.."AddonLoader")

-- Unit Tests
require(path.."UnitTests/RunUnitTests")

-- Full Tests
require(path.."FullTests/RunFullTests")


os.exit(lu.LuaUnit.run("-o", "tap"))
