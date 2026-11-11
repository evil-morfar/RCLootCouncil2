---@diagnostic disable: duplicate-set-field
--- Only loaded when playing Forever

---@class RCLootCouncil
local addon = select(2, ...)

local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local Object = {}

local old_options_func = addon.OptionsTable
function addon:OptionsTable()
	local options = old_options_func(addon)

	-- No need for ambiguate
	options.args.settings.args.generalSettingsTab.args.ambiguate = nil

	-- No Encounter Journal, so no trinkets autopass
	options.args.settings.args.generalSettingsTab.args.responseOptions.args.autoPassTrinket = nil

	-- Disable "Allow Keeping" and "Trade Messages" options
	options.args.mlSettings.args.generalTab.args.lootingOptions.args.printCompletedTrades = nil
	options.args.mlSettings.args.generalTab.args.lootingOptions.args.rejectTrade = nil

	-- We don't have spec icons
	options.args.settings.args.generalSettingsTab.args.frameOptions.args.showSpecIcon = nil

	-- no personal loot
	options.args.settings.args.generalSettingsTab.args.lootHistoryOptions.args.savePersonalLoot = nil
	options.args.settings.args.generalSettingsTab.args.lootHistoryOptions.args.saveBonusRolls = nil

	-- TODO: implement
	-- "Classic" auto pass options for auto passing items your class cannot use only (Vanilla/TBC)
	options.args.settings.args.generalSettingsTab.args.responseOptions.args.classicAutoPass = {
		order = 1.5,
		name = L.opt_classicAutoPass_name,
		desc = L.opt_classicAutoPass_desc,
		type = "toggle",
		disabled = function() return not addon.db.profile.autoPass end,
	}

	-- No pets or decor to loot
	options.args.mlSettings.args.generalTab.args.lootingOptions.args.lootPets = nil
	options.args.mlSettings.args.generalTab.args.lootingOptions.args.lootDecor = nil
	-- Object:NewAwardOptions(options)
	return options
end

function Object:NewAwardOptions(options)
	-- Will keep the options grouped in `db.autoPassSlot` whilst allowing them to be
	-- named e.g. `INVTYPE_HEAD` global for easy fetching on demand.
	local function autoPassOptionsGet(info)
		return addon.db.profile.autoPassSlot[info[#info]]
	end

	local function autoPassOptionsSet(info, val)
		addon.db.profile.autoPassSlot[info[#info]] = val
		-- Also set robes when dealing with chest.
		if info[#info] == "INVTYPE_CHEST" then
			addon.db.profile.autoPassSlot["INVTYPE_ROBE"] = val
		end
	end

	local function autoPassSlotHidden()
		return not addon.db.profile.autoPassSlot.enabled
	end

	-- Setup new options group
	local autoPassSlotsOptions = {
		order = 4.1,
		name = LC.opt_advancedAutoPass_name,
		type = "group",
		inline = true,
		get = autoPassOptionsGet,
		set = autoPassOptionsSet,
		args = {
			enabled = {
				order = 0,
				type = "toggle",
				name = _G.ENABLE,
				set = function(info, val)
					autoPassOptionsSet(info, val)
					if not val then
						-- Uncheck everything when disabling group:
						for k in pairs(addon.db.profile.autoPassSlot) do
							addon.db.profile.autoPassSlot[k] = false
						end
					end
				end,
			},
			description = {
				order = 1,
				type = "description",
				name = L.opt_advancedAutoPass_desc,
				hidden = autoPassSlotHidden,
			},
			-- Fields created below
		},
	}
	-- Each type listed is the global string for an item equip location that should
	-- be an option for auto pass slot. They're added to the options menu in this order.
	local fields = {
		"INVTYPE_HEAD",
		"INVTYPE_NECK",
		"INVTYPE_SHOULDER",
		"INVTYPE_CLOAK",
		"INVTYPE_CHEST",
		"INVTYPE_WAIST",
		"INVTYPE_LEGS",
		"INVTYPE_FEET",
		"INVTYPE_WRIST",
		"INVTYPE_HAND",
		"INVTYPE_FINGER",
		"INVTYPE_TRINKET",
		"INVTYPE_RANGED",
		"INVTYPE_WEAPON",
		"INVTYPE_SHIELD",
		"INVTYPE_2HWEAPON",
	}

	for i, name in ipairs(fields) do
		autoPassSlotsOptions.args[name] = {
			order = i + 1,
			type = "toggle",
			name = _G[name],
			desc = format(L.opt_advancedAutoPassSlot_desc, _G[name]),
			hidden = autoPassSlotHidden,
		}
	end

	options.args.settings.args.generalSettingsTab.args.autoPassSlots = autoPassSlotsOptions

	-- AlwaysAutoAward
	options.args.mlSettings.args.awardsTab.args.autoAward.args.alwaysAutoAward =
	{
		order = 5,
		name = L.ALWAYS_AUTO_AWARD_OPTION,
		type = "group",
		inline = true,
		args = {
			desc = {
				order = 1,
				name = L.ALWAYS_AUTO_AWARD_OPTION_DESC,
				type = "description",
			},
			alwaysAutoAwardInput = {
				order = 2,
				name = L["Add Item"],
				desc = L.ALWAYS_AUTO_AWARD_OPTION_INPUT_DESC,
				usage = L["ignore_input_usage"],
				type = "input",
				validate = function(_, val)
					return C_Item.GetItemInfoInstant(val)
				end,
				get = function()
					return "\"item ID, Name or Link\""
				end,
				set = function(_, val)
					local id = C_Item.GetItemInfoInstant(val)
					if id then
						addon.db.profile.alwaysAutoAwardItems[id] = true
						addon.blackListOverride[id] = true
						LibStub("AceConfigRegistry-3.0"):NotifyChange(
							"RCLootCouncil")
					end
				end,
			},
			alwaysAutoAwardList = {
				order = 3,
				name = L.ALWAYS_AUTO_AWARD_OPTION_LIST,
				desc = L.ALWAYS_AUTO_AWARD_OPTION_LIST_DESC,
				type = "select",
				style = "dropdown",
				width = "double",
				values = function()
					local t = {}
					local hasItems = false
					for id in pairs(addon.db.profile.alwaysAutoAwardItems) do
						local link = select(2, GetItemInfo(id))
						if link then
							t[id] = link .. "  (id: " .. id .. ")"
						else
							t[id] =
								L["Not cached, please reopen."] .. "  (id: " ..
								id .. ")"
						end
						hasItems = true
					end
					if not hasItems then
						t[1] = L.ALWAYS_AUTO_AWARD_OPTION_LIST_NONE
					end
					return t
				end,
				get = function() return L["Ignore List"] end,
				set = function(_, val)
					addon.db.profile.alwaysAutoAwardItems[val] = nil
					addon.blackListOverride[val] = nil
				end,
			},
		},
	}
end