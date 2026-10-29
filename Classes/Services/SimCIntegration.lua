--- SimC Integration
--- Adds ongoing sessions to SimC when using /simc.
--- @type RCLootCouncil
local addon = select(2, ...)

---@class Services.SimCIntegration : Module
local SimC = addon.Init "Services.SimCIntegration"

function SimC:OnEnable()
	local function DoHook()
		addon.Log:D("Hooking Simulationcraft:GetSimcProfile()")
		addon:RawHook(self.SC, "GetSimcProfile",
			function(self, debugOutput, noBags, showMerchant, links)
				local origFunc = addon.hooks[self].GetSimcProfile
				links = links or {}
				for _, data in ipairs(addon:GetLootTable()) do
					tinsert(links, data.link)
				end
				if #links > 0 then
					addon.Log:D(format("Added %d links to SimC profile", #links))
				end
				return origFunc(self, debugOutput, noBags, showMerchant, links)
			end, true)
	end

	self.SC = LibStub "AceAddon-3.0":GetAddon("Simulationcraft", true)
	if not self.SC then
		addon.Log:D("Simulationcraft not found, disabling SimCIntegration")
		self:Disable()
	else
		DoHook()
	end
end

function SimC:OnDisable()
	if addon:IsHooked(self.SC, "GetSimcProfile") then
		addon:Unhook(self.SC, "GetSimcProfile")
	end
end
