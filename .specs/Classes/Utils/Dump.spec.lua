require "busted.runner" ()

local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
dofile ".specs/EmulatePlayerLogin.lua"
---@type RCLootCouncil.Utils
local Utils = addon.Utils

describe("#Utils :DumpConfig", function()
	before_each(function()
		Utils = RCLootCouncil.Utils
	end)

	it("should exist", function()
		assert.is.Function(Utils.DumpConfig)
	end)

	it("handles non-table db values gracefully", function()
		local nres, res = Utils:DumpConfig(123, "myVar")
		assert.is.number(nres)
		assert.is.table(res)
		assert.equals("myVar = 123", res[1])
	end)

	it("dumps non-profile options as is", function()
		local db = {
			global = {
				logMaxEntries = 4000,
				version = "3.0.0",
			},
			profileKeys = {
				["Player - Realm"] = "Default",
			},
		}

		local _, res = Utils:DumpConfig(db, "RCLootCouncilDB")
		local output = table.concat(res, "\n")
		-- Execute output to verify it parses and preserves non-profile data
		local func = loadstring(output .. "\nreturn RCLootCouncilDB")
		assert.is_not_nil(func)
		local result = func()
		assert.are.same(db.global, result.global)
		assert.are.same(db.profileKeys, result.profileKeys)
	end)

	it("excludes profile options that match addon.defaults.profile", function()
		local db = {
			profiles = {
				Default = {
					ambiguate = addon.defaults.profile.ambiguate, -- same (false) -> omit
					autoPass = addon.defaults.profile.autoPass,   -- same (true) -> omit
					autoClose = not addon.defaults.profile.autoClose, -- different (true vs false) -> include
				},
			},
		}

		local _, res = Utils:DumpConfig(db, "RCLootCouncilDB")
		local output = table.concat(res, "\n")
		local func = loadstring(output .. "\nreturn RCLootCouncilDB")
		assert.is_not_nil(func)
		local result = func()

		assert.is_nil(result.profiles.Default.ambiguate)
		assert.is_nil(result.profiles.Default.autoPass)
		assert.equals(not addon.defaults.profile.autoClose, result.profiles.Default.autoClose)
	end)

	it("includes new custom fields in profile not present in defaults", function()
		local db = {
			profiles = {
				Custom = {
					myCustomField = "helloWorld",
					myCustomNumber = 42,
				},
			},
		}

		local _, res = Utils:DumpConfig(db, "RCLootCouncilDB")
		local output = table.concat(res, "\n")
		local func = loadstring(output .. "\nreturn RCLootCouncilDB")
		assert.is_not_nil(func)
		local result = func()

		assert.equals("helloWorld", result.profiles.Custom.myCustomField)
		assert.equals(42, result.profiles.Custom.myCustomNumber)
	end)

	it("performs deep comparison on nested tables and includes only changed values", function()
		local db = {
			profiles = {
				Default = {
					usage = {
						gl = not addon.defaults.profile.usage.gl, -- changed!
						never = addon.defaults.profile.usage.never, -- same -> omit
						state = addon.defaults.profile.usage.state, -- same -> omit
					},
					buttons = {
						default = {
							numButtons = 5, -- changed from 3
							[1] = {
								text = "My Custom Need", -- changed
								whisperKey = addon.defaults.profile.buttons.default[1].whisperKey, -- same -> omit
								requireNotes = addon.defaults.profile.buttons.default[1].requireNotes, -- same -> omit
							},
						},
					},
				},
			},
		}

		local _, res = Utils:DumpConfig(db, "RCLootCouncilDB")
		local output = table.concat(res, "\n")
		local func = loadstring(output .. "\nreturn RCLootCouncilDB")
		assert.is_not_nil(func)
		local result = func()

		assert.equals(not addon.defaults.profile.usage.gl, result.profiles.Default.usage.gl)
		assert.is_nil(result.profiles.Default.usage.never)
		assert.is_nil(result.profiles.Default.usage.state)

		assert.equals(5, result.profiles.Default.buttons.default.numButtons)
		assert.equals("My Custom Need", result.profiles.Default.buttons.default[1].text)
		assert.is_nil(result.profiles.Default.buttons.default[1].whisperKey)
		assert.is_nil(result.profiles.Default.buttons.default[1].requireNotes)
	end)

	it("omits sub-tables when all their values match defaults", function()
		local db = {
			profiles = {
				Default = {
					usage = {
						gl = addon.defaults.profile.usage.gl,
						never = addon.defaults.profile.usage.never,
						ask_gl = addon.defaults.profile.usage.ask_gl,
						state = addon.defaults.profile.usage.state,
					},
				},
			},
		}

		local _, res = Utils:DumpConfig(db, "RCLootCouncilDB")
		local output = table.concat(res, "\n")
		local func = loadstring(output .. "\nreturn RCLootCouncilDB")
		assert.is_not_nil(func)
		local result = func()

		assert.is_nil(result.profiles.Default.usage)
		assert.are.same({}, result.profiles.Default)
	end)

	it("handles multiple profiles independently", function()
		local db = {
			profiles = {
				ProfileA = {
					autoPass = false,
				},
				ProfileB = {
					autoPass = true, -- default is true -> omit
					timeout = 120, -- default is 60 -> include
				},
			},
		}

		local _, res = Utils:DumpConfig(db, "RCLootCouncilDB")
		local output = table.concat(res, "\n")
		local func = loadstring(output .. "\nreturn RCLootCouncilDB")
		assert.is_not_nil(func)
		local result = func()

		assert.equals(false, result.profiles.ProfileA.autoPass)
		assert.is_nil(result.profiles.ProfileB.autoPass)
		assert.equals(120, result.profiles.ProfileB.timeout)
	end)

	it("handles wildcard defaults like enabledButtons and UI correctly", function()
		local db = {
			profiles = {
				Default = {
					enabledButtons = {
						["Raid1"] = true, -- default ["*"] is false -> include
						["Raid2"] = false, -- default ["*"] is false -> omit
					},
				},
			},
		}

		local _, res = Utils:DumpConfig(db, "RCLootCouncilDB")
		local output = table.concat(res, "\n")
		local func = loadstring(output .. "\nreturn RCLootCouncilDB")
		assert.is_not_nil(func)
		local result = func()

		assert.equals(true, result.profiles.Default.enabledButtons.Raid1)
		assert.is_nil(result.profiles.Default.enabledButtons.Raid2)
	end)
end)
