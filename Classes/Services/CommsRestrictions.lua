---@type RCLootCouncil
local addon = select(2, ...)
local Subject = addon.Require("rx.Subject")

---@class Services.CommsRestrictions
local CommsRestrictions = addon.Init "Services.CommsRestrictions"

--- @class OnAddonRestrictionChanged : rx.Subject
--- @field subscribe fun(self, onNext: fun(active: boolean)) : rx.Subscription
CommsRestrictions.OnAddonRestrictionChanged = Subject.create()

function CommsRestrictions:OnEnable()
	addon:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED", self.ChangeEvent, self)
	self.restrictionsEnabled = false
	self.restrictions = 0x0
end

local AddOnRestrictionTypeReverse = tInvert(Enum.AddOnRestrictionType)
local AddOnRestrictionStateReverse = tInvert(Enum.AddOnRestrictionState)
function CommsRestrictions:ChangeEvent(_, type, state)
	-- Combat seems to be the exception. Not sure about map - comms still work when it's enabled in instances.
	local newState = (state == Enum.AddOnRestrictionState.Active or state == Enum.AddOnRestrictionState.Activating) and 1 or 0
	if newState == 1 then
		self.restrictions = bit.bor(self.restrictions, bit.lshift(1, type))
	else
		self.restrictions = bit.band(self.restrictions, bit.bnot(bit.lshift(1, type)))
	end
	self.restrictionsEnabled = bit.band(self.restrictions, 0x6) ~= 0  -- 6 = 0b110, the bits for encounter and challenge mode
	addon.Log:d("Restriction:", AddOnRestrictionTypeReverse[type], AddOnRestrictionStateReverse[state],
		string.format("0x%x",self.restrictions), self.restrictionsEnabled)
	self.OnAddonRestrictionChanged(self.restrictionsEnabled)
end

function CommsRestrictions:IsRestricted()
	return self.restrictionsEnabled
end

function CommsRestrictions:DumpRestrictions()
	addon.Log:D("Current Addon Restrictions:")
	for type = 0, #AddOnRestrictionTypeReverse do
		local state = C_RestrictedActions.IsAddOnRestrictionActive(type)
		addon.Log:D(" - ", AddOnRestrictionTypeReverse[type], state)
	end
	addon.Log:D("Secrets:", C_Secrets.HasSecretRestrictions())
end