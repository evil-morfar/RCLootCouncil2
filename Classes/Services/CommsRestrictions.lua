---@type RCLootCouncil
local addon = select(2, ...)
local Subject = addon.Require("rx.Subject")

---@class Services.CommsRestrictions
local CommsRestrictions = addon.Init "Services.CommsRestrictions"

--- @class OnAddonRestrictionChanged : rx.Subject
-- --- @field subscribe fun(self, onNext: fun(active: boolean),)
CommsRestrictions.OnAddonRestrictionChanged = Subject.create()

function CommsRestrictions:OnEnable()
	addon:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED", self.ChangeEvent, self)
end

local AddOnRestrictionTypeReverse = tInvert(Enum.AddOnRestrictionType)
local AddOnRestrictionStateReverse = tInvert(Enum.AddOnRestrictionState)

function CommsRestrictions:ChangeEvent(_, type, state)
	-- TODO: Currently checked: Combat, Encounter, ChallengeMode
	-- Combat seems to be the exception
	self.restrictionsEnabled =
		(state == Enum.AddOnRestrictionState.Active or state == Enum.AddOnRestrictionState.Activating) and
		(type ~= Enum.AddOnRestrictionType.Combat)
	addon.Log:d("Restriction:", AddOnRestrictionTypeReverse[type], AddOnRestrictionStateReverse[state], type, state,
	self.restrictionsEnabled)
end

function CommsRestrictions:IsRestricted()
	return self.restrictionsEnabled
end
