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
end

local AddOnRestrictionTypeReverse = tInvert(Enum.AddOnRestrictionType)
local AddOnRestrictionStateReverse = tInvert(Enum.AddOnRestrictionState)
function CommsRestrictions:ChangeEvent(_, type, state)
	-- Combat seems to be the exception. Not sure about map - comms still work when it's enabled in instances.
	self.restrictionsEnabled =
		(state == Enum.AddOnRestrictionState.Active or state == Enum.AddOnRestrictionState.Activating) and
		(type ~= Enum.AddOnRestrictionType.Combat and type ~= Enum.AddOnRestrictionType.Map)
	addon.Log:d("Restriction:", AddOnRestrictionTypeReverse[type], AddOnRestrictionStateReverse[state], type, state,
		self.restrictionsEnabled)
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