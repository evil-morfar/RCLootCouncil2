--- Pool.lua Class providing object pooling.
--- @author Potdisc
--- Create date: 29/10/2026

--- @type RCLootCouncil
local addon = select(2, ...)
---@class Utils.Pool
local UtilsPool = addon.Init "Utils.Pool"

---@class Pool<T>
---@field creator fun(self:Pool<T>):T
---@field pool T[]
---@field head integer
local Pool = {}
local mt = { __index = Pool }


---Creates a new Pool object.
---@generic T
---@param creator? fun(self:Pool<T>):T #Function to create a new object. Defaults a new table.
---@return Pool<T>
function UtilsPool:New(creator)
	local o = {
		head = 0,
		---@type T[]
		pool = {},
		creator = creator or function() return {} end
	}
	setmetatable(o, mt)
	return o
end

---Acquires an object from the pool.
---@return T
function Pool:Acquire()
	if self.head == 0 then
		return self.creator(self)
	end
	local obj = self.pool[self.head]
	self.pool[self.head] = nil
	self.head = self.head - 1
	return obj
end

---Release any object back to the pool.
---@param obj T
function Pool:Release(obj)
	self.head = self.head + 1
	self.pool[self.head] = obj
end

---Initialize the pool with a number of objects.
---@param count integer Number of objects to create. Defaults to 1.
function Pool:Initialize(count)
	count = count or 1
	for i = 1, count do
		self.pool[i] = self.creator(self)
	end
	self.head = count
end