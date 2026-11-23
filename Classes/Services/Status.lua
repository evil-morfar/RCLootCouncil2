--- Status.lua
--- API for addon statuses for various loot methods

---@class (exact) StatusHandler Implemented by StatusHandlers.
---@field GetStatus fun(self: StatusHandler): integer Status of the Handler
---@field StatusToDescription fun(self: StatusHandler, status: string|integer, target: string|integer): string[] Maps a status to a description, colored red/green based on the target
---@field GetTargetedStatus fun(self: StatusHandler): integer The status a raider should have
---@field GetTargetedMLStatus fun(self: StatusHandler): integer The status the ML/leader should have
---@field GetDescription fun(self:StatusHandler): string[][]
---@field name string Name of the status

--- @type RCLootCouncil
local addon = select(2, ...)

---@class Services.Status : Module, AceEvent-3.0
---@field private statusHandler StatusHandler
local Status = addon.Init "Services.Status"

function Status:OnInitialize()
	LibStub("AceEvent-3.0"):Embed(self)
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", "OnLootMethodChanged")
	self:OnLootMethodChanged()
end

--- Gets the name of the currently active status handler
function Status:GetName() return self.statusHandler.name end

--- Fetches the status of the currently enabled StatusHandler
--- @return integer # The integer representation of the binary status value
function Status:GetStatus() return self.statusHandler:GetStatus() end

--- The status a raider should have
function Status:GetTargetedStatus() return self.statusHandler:GetTargetedStatus() end

--- The status the ML/leader should have
function Status:GetTargetedMLStatus() return self.statusHandler:GetTargetedMLStatus() end

---Generates the binary version of the status.
---@param status? integer|string Integer status. Defaults to [`Status:GetStatus()`](lua://Services.Status.GetStatus).
---@return string #The binary representation of the status.
function Status:GetStatusBinary(status)
	return addon.Utils:Int2Bin(status or self:GetStatus())
end

--- Converts the status to a hexadecimal string.
---@param status? integer|string Integer status. Defaults to [`Status:GetStatus()`](lua://Services.Status.GetStatus).
---@return string #The hexadecimal representation of the status.
function Status:GetStatusHex(status)
	return string.format("%x", status or self:GetStatus())
end

--- Creates a table of descriptions for the provided status.
--- These are colored green if set in the target status, otherwise red.
---@param status integer|string Integer or binary representation of [Status](lua://Status). See [GroupLoot:GetStatus()](lua://Utils.GroupLoot.GetStatus)
---@param target integer|string Integer or binary representation of the target status.
function Status:StatusToDescription(status, target)
	status = type(status) == "string" and tonumber(status, 2) or status
	target = type(target) == "string" and tonumber(target, 2) or target
	local res = {}
	local description = self.statusHandler:GetDescription()
	for i = 1, #description do
		local lookAtBit = bit.lshift(1, i - 1)
		local statusAtBit = bit.band(status, lookAtBit)
		local bitState = statusAtBit > 0 and 1 or 0
		if i == 7 then -- autoGroupLootGuildGroupOnly doesn't matter; but color green if enabled
			if bitState == 1 then
				res[#res + 1] = WrapTextInColorCode(description[i][bitState] or "", "FF00FF00")
			else
				res[#res + 1] = description[i][bitState]
			end
		elseif statusAtBit == bit.band(target, lookAtBit) then
			res[#res + 1] = WrapTextInColorCode(description[i][bitState] or "", "FF00FF00")
		else
			res[#res + 1] = WrapTextInColorCode(description[i][bitState] or "", "FFFF0000")
		end
	end
	return res
end

---@private
function Status:OnLootMethodChanged()
    addon.lootMethod = addon:GetLootMethod()
	addon.Log:D("LootMethod changed", addon.lootMethod)
	if addon.lootMethod == Enum.LootMethod.Masterlooter then
		self.statusHandler = addon.Require "Services.MasterLoot"
	else
		self.statusHandler = addon.Require "Utils.GroupLoot"
	end
end
