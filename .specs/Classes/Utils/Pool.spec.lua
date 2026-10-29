require "busted.runner" ()
-----------------------------------------------------------
-- Setup
-----------------------------------------------------------
local addon_name, addon = "RCLootCouncil", {}
loadfile(".specs/AddonLoader.lua")(nil, addon_name, addon).LoadArray {
	"Classes/Core.lua",
	"Classes/Utils/Pool.lua",
}

-----------------------------------------------------------
-- Tests
-----------------------------------------------------------
describe("#Pool", function()
	local Pool = addon.Require "Utils.Pool"
	it("can be created", function()
		local pool = Pool:New()
		assert.is_table(pool)
		assert.is_function(pool.Acquire)
		assert.is_function(pool.Release)
		assert.is_function(pool.Initialize)
	end)
	it("can acquire and release values from the pool", function()
		local count = 0
		local p = Pool:New(function()
			count = count + 1
			return count
		end)
		local obj1 = p:Acquire()
		local obj2 = p:Acquire()
		p:Release(obj1)
		p:Release(obj2)
		assert.equals(2, p.head)
		assert.equals(1, p.pool[1])
		assert.equals(2, p.pool[2])
	end)

	it("can initialize the pool with pre-created objects", function()
		local p = Pool:New()
		p:Initialize(5)
		assert.equals(5, p.head)
		assert.is_table(p.pool[1])
		assert.is_table(p.pool[5])
	end)
end)