require "busted.runner" ()
local addon = {}
loadfile(".specs/AddonLoader.lua")(nil, nil, addon).LoadArray {
	[[Libs\LibStub\LibStub.lua]],
	[[Libs\CallbackHandler-1.0\CallbackHandler-1.0.xml]],
	[[Libs\AceEvent-3.0\AceEvent-3.0.xml]],

	[[Classes\Core.lua]],
	[[Classes\Lib\RxLua\embeds.xml]],
	[[Classes\Services\CommsRestrictions.lua]],
}

addon.Log = {
	d = function(_, ...)
		-- print(...)
	end,
}

describe("#Services #CommsRestrictions", function()
	local CommsRestrictions = addon.Require "Services.CommsRestrictions"

	before_each(function()
		LibStub("AceEvent-3.0"):Embed(addon)
		CommsRestrictions:OnEnable()
	end)

	local SetRestriction = function(restriction, value)
		CommsRestrictions:ChangeEvent("ADDON_RESTRICTION_STATE_CHANGED", restriction, value)
	end
	describe("basics", function()
		it("should be true in encounters", function()
			assert.is_false(CommsRestrictions:IsRestricted())
			SetRestriction(Enum.AddOnRestrictionType.Encounter, Enum.AddOnRestrictionState.Active)
			assert.Equal(2, CommsRestrictions.restrictions) -- encounter bit should be set
			_ADVANCE_TIME(1)
			assert.is_true(CommsRestrictions:IsRestricted())
		end)

		it("should be true in challenge mode", function()
			assert.is_false(CommsRestrictions:IsRestricted())
			SetRestriction(Enum.AddOnRestrictionType.ChallengeMode, Enum.AddOnRestrictionState.Active)
			assert.Equal(4, CommsRestrictions.restrictions) -- challenge mode bit should be set
			_ADVANCE_TIME(1)
			assert.is_true(CommsRestrictions:IsRestricted())
		end)

		it("should be false in combat", function()
			assert.is_false(CommsRestrictions:IsRestricted())
			SetRestriction(Enum.AddOnRestrictionType.Combat, Enum.AddOnRestrictionState.Active)
			assert.Equal(1, CommsRestrictions.restrictions) -- combat bit should be set
			_ADVANCE_TIME(1)
			assert.is_false(CommsRestrictions:IsRestricted())
		end)

		it("should be false on map", function()
			assert.is_false(CommsRestrictions:IsRestricted())
			SetRestriction(Enum.AddOnRestrictionType.Map, Enum.AddOnRestrictionState.Active)
			assert.Equal(16, CommsRestrictions.restrictions) -- map bit should be set
			_ADVANCE_TIME(1)
			assert.is_false(CommsRestrictions:IsRestricted())
		end)

		it("should be false when no restrictions", function()
			assert.is_false(CommsRestrictions:IsRestricted())
			SetRestriction(Enum.AddOnRestrictionType.Encounter, Enum.AddOnRestrictionState.Inactive)
			SetRestriction(Enum.AddOnRestrictionType.ChallengeMode, Enum.AddOnRestrictionState.Inactive)
			SetRestriction(Enum.AddOnRestrictionType.Combat, Enum.AddOnRestrictionState.Inactive)
			SetRestriction(Enum.AddOnRestrictionType.Map, Enum.AddOnRestrictionState.Inactive)
			_ADVANCE_TIME(1)
			assert.is_false(CommsRestrictions:IsRestricted())
		end)

		it("should register both on active and activating", function()
			assert.is_false(CommsRestrictions:IsRestricted())
			SetRestriction(Enum.AddOnRestrictionType.Encounter, Enum.AddOnRestrictionState.Activating)
			_ADVANCE_TIME(1)
			assert.Equal(2, CommsRestrictions.restrictions)
			assert.is_true(CommsRestrictions:IsRestricted())
			SetRestriction(Enum.AddOnRestrictionType.Encounter, Enum.AddOnRestrictionState.Inactive)
			_ADVANCE_TIME(1)
			assert.is_false(CommsRestrictions:IsRestricted())
			assert.Equal(0, CommsRestrictions.restrictions)
			SetRestriction(Enum.AddOnRestrictionType.Encounter, Enum.AddOnRestrictionState.Active)
			_ADVANCE_TIME(1)
			assert.is_true(CommsRestrictions:IsRestricted())
			assert.Equal(2, CommsRestrictions.restrictions)
		end)
	end)

	describe("memory", function()
		it("should not deactivate on ongoing events", function()
			assert.is_false(CommsRestrictions:IsRestricted())
			SetRestriction(Enum.AddOnRestrictionType.ChallengeMode, Enum.AddOnRestrictionState.Active)
			_ADVANCE_TIME(1)
			assert.is_true(CommsRestrictions:IsRestricted())
			assert.Equal(4, CommsRestrictions.restrictions)
			SetRestriction(Enum.AddOnRestrictionType.Encounter, Enum.AddOnRestrictionState.Activating)
			_ADVANCE_TIME(1)
			assert.is_true(CommsRestrictions:IsRestricted())
			assert.Equal(6, CommsRestrictions.restrictions)
			SetRestriction(Enum.AddOnRestrictionType.Encounter, Enum.AddOnRestrictionState.Inactive)
			_ADVANCE_TIME(1)
			assert.is_true(CommsRestrictions:IsRestricted())
			assert.Equal(4, CommsRestrictions.restrictions)
		end)
	end)
end)
