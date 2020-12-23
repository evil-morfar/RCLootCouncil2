--- options.lua - option frame in BlizzardOptions for RCLootCouncil
-- @author Potdisc
-- Create Date : 5/24/2012 6:24:55 PM
---@type RCLootCouncil
local _,addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
---@type Data.Player
local Player = addon.Require "Data.Player"
------ Options ------
local function DBGet(info)
	return addon.db.profile[info[#info]]
end

local function DBSet(info, val)
	addon.db.profile[info[#info]] = val
	addon:ConfigTableChanged(info[#info])
end

local function roundColors(r,g,b,a)
	return addon.round(r,2),addon.round(g,2),addon.round(b,2),addon.round(a,2)
end

local function createNewButtonSet(path, name, order)
	-- Create the group
	path[name] = {
		order = order,
		name = addon.OPT_MORE_BUTTONS_VALUES[name],
		desc = "",
		type = "group",
		inline = true,
		args = {
			optionsDesc = {
				order = 0,
				name = format(L["opt_buttonsGroup_desc"], addon.OPT_MORE_BUTTONS_VALUES[name]),
				type = "description",
				width = "double",
			},
			remove = {
				order = 1,
				name = _G.REMOVE,
				type = "execute",
				func = function(info)
					addon.db.profile.enabledButtons[info[#info - 1]] = nil
					addon.db.profile.responses[info[#info - 1]] = nil
					addon.db.profile.buttons[info[#info - 1]] = nil

					addon:ConfigTableChanged("responses")
				end,
			},
			numButtons = {
				order = 2,
				name = L["Number of buttons"],
				desc = L["number_of_buttons_desc"],
				type = "range",
				width = "full",
				min = 1,
				max = addon.db.profile.maxButtons,
				step = 1,
				get = function() return addon.db.profile.buttons[name].numButtons or 3 end,
				set = function(_,v) 
					addon.db.profile.buttons[name].numButtons = v
					addon:ConfigTableChanged("responses")
				end,
			},
		}
	}
	-- Create each entry
	for i = 1, addon.db.profile.buttons[name].numButtons do
		addon.db.profile.responses[name][i].sort = i -- Sort is static, just set it
		path[name].args["button"..i] = {
			order = i * 5 + 1,
			name = L["Button"].." "..i,
			desc = format(L["Set the text on button 'number'"], i),
			type = "input",
			get = function() return addon.db.profile.buttons[name][i].text end,
			set = function(info, value) addon:ConfigTableChanged("buttons"); addon.db.profile.buttons[name][i].text = tostring(value) end,
			hidden = function() return addon.db.profile.buttons[name].numButtons < i end,
		}
		path[name].args["picker"..i] = {
			order = i * 5 + 2,
			name = L["Response color"],
			desc = L["response_color_desc"],
			width = 0.8,
			type = "color",
			get = function() return unpack(addon.db.profile.responses[name][i].color or {1,1,1,1})	end,
			set = function(info,r,g,b,a) addon:ConfigTableChanged("responses"); addon.db.profile.responses[name][i].color = {roundColors(r,g,b,a)} end,
			hidden = function() return addon.db.profile.buttons[name].numButtons < i end,
		}
		path[name].args["text"..i] = {
			order = i * 5 + 3,
			name = L["Response"],
			desc = format(L["Set the text for button i's response."], i),
			type = "input",
			get = function() return addon.db.profile.responses[name][i].text end,
			set = function(info, value) addon:ConfigTableChanged("responses"); addon.db.profile.responses[name][i].text = tostring(value) end,
			hidden = function() return addon.db.profile.buttons[name].numButtons < i end,
		}
		-- Move Up/Down buttons
		path[name].args["move_up"..i] = {
			order = i * 5 + 4,
			name = "",
			type = "execute",
			width = 0.1,
			image = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up",
			disabled = function(info) return i == 1 end, -- Disable the top button
			func = function()
				-- We basically need to switch two variables, this up, and the former up down.
				-- Variables: addon.db.profile.responses[name] + addon.db.profile.buttons[name]
				-- Temp store this data
				local tempBtn = addon.db.profile.buttons[name][i]
				local tempResponse = addon.db.profile.responses[name][i]
				-- Move i - 1 down to i
				addon.db.profile.buttons[name][i] = addon.db.profile.buttons[name][i - 1]
				addon.db.profile.responses[name][i] = addon.db.profile.responses[name][i - 1]
				-- And move the temp up
				addon.db.profile.buttons[name][i - 1] = tempBtn
				addon.db.profile.responses[name][i - 1] = tempResponse
				-- Now update the sort values
				addon.db.profile.responses[name][i].sort = i
				addon.db.profile.responses[name][i - 1].sort = i - 1

				addon:ConfigTableChanged("responses")
			end,
		}
		path[name].args["move_down"..i] = {
			order = i * 5 + 4.1,
			name = "", --L["Move Down"],
			type = "execute",
			width = 0.1,
			image = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up",
			disabled = function() return i == addon.db.profile.buttons[name].numButtons end, -- Disable the bottom button
			func = function()
				local tempBtn = addon.db.profile.buttons[name][i]
				local tempResponse = addon.db.profile.responses[name][i]
				addon.db.profile.buttons[name][i] = addon.db.profile.buttons[name][i + 1]
				addon.db.profile.responses[name][i] = addon.db.profile.responses[name][i + 1]
				addon.db.profile.buttons[name][i + 1] = tempBtn
				addon.db.profile.responses[name][i + 1] = tempResponse
				addon.db.profile.responses[name][i].sort = i
				addon.db.profile.responses[name][i + 1].sort = i + 1

				addon:ConfigTableChanged("responses")
			end,
		}
	end
end


local function createAutoAwardPrioList(list)
	local ret = {}
	local num = 4
	for i, name in ipairs(list) do
		local player, class, color
		player = Player:Get(name)
		class = player.name ~= "Unknown" and player:GetClass()
		ret.desc = {
			order = 0,
			type = "description",
			name = L["opt_autoAwardPrioList_desc"],
		}
		ret["name"..i] = {
			order = (i - 1) * num + 1,
			type = "description",
			width = 2.3,
			fontSize = "medium",
			name = function()
				color = _G.RAID_CLASS_COLORS[class or "PRIEST"] -- fallback to PRIEST as it's white
				return  i..". "..color:WrapTextInColorCode(addon.Ambiguate(name))
			end,
			image = function() return class and "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES" or "Interface/ICONS/INV_Sigil_Thorim.png" end,
			imageCoords = class and CLASS_ICON_TCOORDS[class] or {},
			imageWidth = 20,
			imageHeight = 20,
		}
		ret["remove"..i] = {
			order = (i - 1) * num + 2,
			name = _G.REMOVE,
			width = 0.5,
			type = "execute",
			func = function()
				table.remove(list, i)
			end
		}
		ret["moveUp"..i] = {
			order = (i - 1) * num + 3,
			name = "",
			type = "execute",
			width = 0.1,
			image = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up",
			disabled = function() return i == 1 end,
			func = function()
				local tmp = list[i]
				list[i] = list[i - 1]
				list[i - 1] = tmp
			end,
		}
		ret["moveDown"..i] = {
			order = (i - 1) * num + 4,
			name = "",
			type = "execute",
			width = 0.1,
			image = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up",
			disabled = function() return i == #list end,
			func = function()
				local tmp = list[i]
				list[i] = list[i + 1]
				list[i + 1] = tmp
			end,
		}
	end
	return ret
end

--- Creates a function used as the `set` value in auto award candidate input fields.
--- Takes input text (split by commas and spaces) and adds them to the provided list.
local function autoAwardFieldProcessor(list)
	return function(_, v)
		for name in string.gmatch(v, "[^, ]+") do
			if not tContains(list, name) then
				tinsert(list, name)
			end
		end
	end
end

local selections = {}
function addon:OptionsTable()
	local db = self:Getdb()
	local options = {
		name = "RCLootCouncil",
		type = "group",
		handler = addon,
		get = DBGet,
		set = DBSet,
		args = {
			settings = {
				order = 1,
				type = "group",
				name = _G.GENERAL,
				childGroups = "tab",
				args = {
					logo = {
							order = 1,
							type = "description",
							name = " ",
							image = addon.LOGO_LOCATION,
							imageWidth = 256,
							imageHeight = 64,
							width = 1.6
					},
					version = {
						order = 1.2,
						type = "description",
						name = function() return self.tVersion and "|cFF87CEFAv"..self.version.."|r-"..self.tVersion or "|cFF87CEFAv"..self.version.."|r" end,
						width = 0.9
					},

					generalSettingsTab = {
						order = 2,
						type = "group",
						name = _G.GENERAL,
						childGroups = "tab",
						args = {
							generalOptions = {
								order = 3,
								name = L["General options"],
								type = "group",
								inline = true,
								args = {
									enable = {
										order = 1,
										name = L["Active"],
										desc = L["active_desc"],
										type = "toggle",
										set = function()
											self.enabled = not self.enabled
											if not self.enabled and self.isMasterLooter then -- If we disable while being ML
												self.isMasterLooter = false
												self.masterLooter = nil
												self:GetActiveModule("masterlooter"):Disable()
											else
												self:NewMLCheck()
											end
										end,
										get = function() return addon.enabled end,
									},
									ambiguate = {
										order = 5,
										name = L["Append realm names"],
										desc = L["Check to append the realmname of a player from another realm"],
										type = "toggle",
									},
									header = {
										order = 7,
										type = "header",
										name = "",
										width = "half",
									},
									testButton = {
										order = 8,
										name = L["Test"],
										desc = L["test_desc"],
										type = "execute",
										func = function()
											InterfaceOptionsFrame:Hide(); -- close all option frames before testing
											self:Test(3)
										end,
									},
									versionTest = {
										name = L["Version Check"],
										desc = L["version_check_desc"],
										type = "execute",
										order = 9,
										func = function()
											InterfaceOptionsFrame:Hide()
											LibStub("AceConfigDialog-3.0"):CloseAll()
											addon:CallModule("version")
										end,
									},
									sync = {
										order = 10,
										name = L["Sync"],
										desc = L["Opens the synchronizer"],
										type = "execute",
										func = function()
											InterfaceOptionsFrame:Hide()
											LibStub("AceConfigDialog-3.0"):CloseAll()
											self.Sync:Enable()
										end,
									},
								},
							},
							responseOptions = {
								order = 4,
								type = "group",
								name = L["Response options"],
								inline = true,
								args = {
									autoPass = {
										order = 1,
										name = L["Auto Pass"],
										desc = L["auto_pass_desc"],
										type = "toggle",
									},
									autoPassTrinket = {
										order = 2,
										name = L["Auto Pass Trinkets"],
										desc = L["auto_pass_trinket_desc"],
										type = "toggle",
									},
									silentAutoPass = {
										order = 3,
										name = L["Silent Auto Pass"],
										desc = L["silent_auto_pass_desc"],
										type = "toggle",
									},
									autoPassBoE = {
										order = 4,
										name = L["Auto pass BoE"],
										desc = L["auto_pass_boe_desc"],
										type = "toggle",
									},
									printResponse = {
										order = 5,
										name = L["Print Responses"],
										desc = L["print_response_desc"],
										type = "toggle",
									},
								},
							},
							frameOptions = {
								order = 5,
								type = "group",
								name = L["Frame options"],
								inline = true,
								args = {
									autoOpen = {
										order = 1,
										name = L["Auto Open"],
										desc = L["auto_open_desc"],
										type = "toggle",
									},
									autoClose = {
										order = 2,
										name = L["Auto Close"],
										desc = L["auto_close_desc"],
										type = "toggle",
									},
									minimizeInCombat = {
										order = 3,
										name = L["Minimize in combat"],
										desc = L["Check to have all frames minimize when entering combat"],
										type = "toggle",
									},
									autoTrade = {
										order = 4,
										name = L["Auto Trade"],
										desc = L["opt_autoTrade_desc"],
										type = "toggle",
									},
									showSpecIcon = {
										order = 5,
										name = L["Show Spec Icon"],
										desc = L["show_spec_icon_desc"],
										type = "toggle",
									},
									chatFrameName = {
										order = 6,
										name = L["opt_chatFrameName_name"],
										desc = L["opt_chatFrameName_desc"],
										type = "select",
										values = function ()
											local ret = {}
											for _, v in ipairs(getglobal("CHAT_FRAMES")) do
												ret[v] = getglobal(v).name
											end
											return ret
										end,
										set = function (info, val)
											DBSet(info, val)
											addon:DoChatHook()
										end
									}

								}
							},
							lootHistoryOptions = {
								order = 6,
								type = "group",
								name = L["Loot History"],
								inline = true,
								args = {
									desc1 = {
										order = 1,
										name = L["loot_history_desc"],
										type = "description",
									},
									enableHistory = {
										order = 2,
										name = L["Enable Loot History"],
										desc = L["enable_loot_history_desc"],
										type = "toggle",
									},
									sendHistory = {
										order = 3,
										name = L["Send History"],
										desc = L["send_history_desc"],
										type = "toggle",
									},
									sendHistoryToGuildChannel = {
										order = 3.1,
										name = L["Send to Guild"],
										desc = L["send_to_guild_desc"],
										type = "toggle",
										disabled = function() return not self.db.profile.sendHistory end,
									},
									header = {
										order = 4,
										type = "header",
										name = "",
									},
									openLootDB = {
										order = 5,
										name = L["Open the Loot History"],
										desc = L["open_the_loot_history_desc"],
										type = "execute",
										func = function() self:CallModule("history");	_G.InterfaceOptionsFrame:Hide();end,
									},
									clearLootDB = {
										order = 6,
										name = L["Clear Loot History"],
										desc = L["clear_loot_history_desc"],
										type = "execute",
										func = function() self.lootDB:ResetDB() end,
										confirm = true,
									},
									spacer = {
										order = 10,
										type = "header",
										name = "",
									},
									desc = {
										order = 11,
										type = "description",
										name = L["Mass deletion of history entries."],
									},
									deleteName = {
										order = 12,
										name = _G.NAME,
										desc = L["opt_deleteName_desc"],
										type = "select",
										width = "double",
										values = function()
											local nameData = self:GetActiveModule("history"):GetAllRegisteredCandidates()
											local t = {}
											for name, v in pairs(nameData) do
												t[name] = "|cff"..self.Utils:RGBToHex(v.color.r,v.color.g,v.color.b)..v.name
											end
											return t
										end,
										get = function(info)
											return selections[info[#info]] or ""
										end,
										set = function(info, val)
											selections[info[#info]] = val
										end,
									},
									deleteNameBtn = {
										order = 13,
										name = _G.DELETE,
										type = "execute",
										confirm = function(info)
											if selections.deleteName then
												return format(L["opt_deleteName_confirm"], selections.deleteName)
											else
												return false
											end
										end,
										func = function(info)
											if not selections.deleteName then
												addon:Print(L["Invalid selection"])
												return
											end
											self:GetActiveModule("history"):DeleteAllEntriesByName(selections.deleteName)
											selections.deleteName = "" -- Barrow: Needs to be reset.
										end,
									},
									deleteDate = {
										order = 14,
										name = L["Date"],
										desc = L["opt_deleteDate_desc"],
										type = "select",
										width = "double",
										values = {
											[time() - 604800] = format(L["x days"], 7),
											[time() - 1209600] = format(L["x days"], 14),
											[time() -2592000] = format(L["x days"], 30),
											[time() -5184000] = format(L["x days"], 60),
											[time() -7776000] = format(L["x days"], 90),
											[time() -10368000] = format(L["x days"], 120),
											[time() -15552000] = format(L["x days"], 180),
											[time() -31536000] = format(L["x days"], 365),
										},
										get = function(info)
											return selections[info[#info]] or ""
										end,
										set = function(info, val)
											selections[info[#info]] = val
										end,
									},
									deleteDateBtn = {
										order = 15,
										name = _G.DELETE,
										type = "execute",
										confirm = function() return L["opt_deleteDate_confirm"] end,
										func = function(info)
											if not selections.deleteDate then
												addon:Print(L["Invalid selection"])
												return
											end
											self:GetActiveModule("history"):DeleteEntriesOlderThanEpoch(selections.deleteDate)
											selections.deleteDate = "" -- Barrow: Needs to be reset.
										end,
									},
									deletePatch = {
										order = 16,
										name = L["Patch"],
										desc = L["opt_deletePatch_desc"],
										type = "select",
										width = "double",
										values = {
											[1607385600] = "Castle Nathria Release",
											[1606176000] = "Shadowlands Launch",
											[1602547200] = "Patch 9.0.1 (Shadowlands)",
											[1579593600] = "Ny'alotha the Waking City raid",
											[1578988800] = "Patch 8.3.0 (Visions of N'Zoth)",
											-- [1562644800] = "Azshara's Eternal Palace raid",
											-- [1561521600] = "Patch 8.2.0 (Rise of Azshara)",
											-- [1544515200] = "Patch 8.1.0",
											-- [1534154400] = "Patch 8.0.1 (Battle for Azeroth)",
											-- [1510225200] = "Patch 7.3.2 (Tier 21)",
											-- [1497348000] = "Patch 7.2.5 (Tier 20)",
											-- [1484650800] = "Patch 7.1.5 (Tier 19)",
										},
										get = function(info)
											return selections[info[#info]] or ""
										end,
										set = function(info, val)
											selections[info[#info]] = val
										end,
									},
									deletePatchBtn = {
										order = 17,
										name = _G.DELETE,
										type = "execute",
										confirm = function() return L["opt_deletePatch_confirm"] end,
										func = function(info)
											if not selections.deletePatch then
												addon:Print(L["Invalid selection"])
												return
											end
											self:GetActiveModule("history"):DeleteEntriesOlderThanEpoch(selections.deletePatch)
											selections.deletePatch = "" -- Barrow: Needs to be reset.
										end,
									},
									deleteRaid = {
										order = 20,
										name = _G.INSTANCE,
										desc = L["opt_deleteRaid_desc"],
										type = "select",
										width = "double",
										values = self:GetActiveModule("history"):GetAllRegisteredInstances(),
										get = function(info)
											return selections[info[#info]] or ""
										end,
										set = function(info, val)
											selections[info[#info]] = val
										end,
									},
									deleteRaidBtn = {
										order = 21,
										name = _G.DELETE,
										type = "execute",
										confirm = function()
											if selections.deleteRaid then
												return L["opt_deleteRaid_confirm"]
											else
												return false
											end
										end,
										func = function ()
											if not selections.deleteRaid then
												addon:Print(L["Invalid selection"])
												return
											end
											self:GetActiveModule("history"):DeleteAllEntriesByMapIDDifficulty(strsplit("-", selections.deleteRaid, 2))
											selections.deleteRaid = ""
										end
									},

									deleteCustomDays = {
										order = 22,
										name = addon:CompleteFormatSimpleStringWithPluralRule(_G.DAYS, 2),
										desc = L["opt_deleteDate_desc"],
										type = "input",
										width = "double",
										validate = function(info, txt)
											return type(tonumber(txt)) == "number" and true or "Input must be a number"
										end,
										get = function(info)
											return selections[info[#info]] or ""
										end,
										set = function(info, txt)
											selections[info[#info]] = txt
										end,
									},
									deleteCustomDaysBtn = {
										order = 23,
										name = _G.DELETE,
										type = "execute",
										confirm = function() return L["opt_deleteDate_confirm"] end,
										func = function(info)
											if not selections.deleteCustomDays then
												addon:Print(L["Invalid selection"])
												return
											end
											-- Convert days into seconds
											local days = selections.deleteCustomDays * 60 * 60 * 24
											local currentTime = GetServerTime()
											self:GetActiveModule("history"):DeleteEntriesOlderThanEpoch(currentTime - days)
											selections.deleteCustomDays = ""
										end,
									},
								},
							},
						},
					},
					appearanceTab = {
						order = 3,
						type = "group",
						name = _G.APPEARANCE_LABEL,
						args = {
							skins = {
								order = 1,
								name = L["Skins"],
								inline = true,
								type = "group",
								args = {
									desc = {
										order = 0,
										type = "description",
										name = L["skins_description"],
									},
									skinSelect = {
										order = 1,
										name = L["Skins"],
										type = "select",
										width = "double",
										values = function()
											local t = {}
											for k,v in pairs(db.skins) do
												t[k] = v.name
											end
											return t
										end,
										get = function() return db.currentSkin	end,
										set = function(info, key)
											self:ActivateSkin(key)
										end,
									},
									saveSkin = {
										order = 2,
										name = L["Save Skin"],
										desc = L["save_skin_desc"],
										type = "input",
										set = function(info, text)
											db.skins[text] = {
												name = text,
												bgColor = {unpack(db.UI.default.bgColor)},
												borderColor = {unpack(db.UI.default.borderColor)},
												background = db.UI.default.background,
												border = db.UI.default.border,
											}
											db.currentSkin = text
										end,
									},
									deleteSkin = {
										order = 3,
										name = L["Delete Skin"],
										desc = L["delete_skin_desc"],
										type = "execute",
										confirm = true,
										func = function()
											db.skins[db.currentSkin] = nil
											for k in pairs(db.skins) do db.currentSkin = k break end --luacheck: ignore
										end,
									},
									resetSkins = {
										order = 4,
										name = L["Reset skins"],
										desc = L["reset_skins_desc"],
										type = "execute",
										confirm = true,
										func = function()
											for k,v in pairs(self.defaults.profile.skins) do
												db.skins[k] = v
											end
											db.currentSkin = self.defaults.profile.currentSkin
										end,
									},
								},
							},
							custom = {
								order = 2,
								name = L["Customize appearance"],
								inline = true,
								type = "group",
								args = {
									desc = {
										order = 1,
										type = "description",
										name = L["customize_appearance_desc"],
									},
									background = {
										order = 3,
										name = L["Background"],
										width = "double",
										type = "select",
										dialogControl = "LSM30_Background",
										values = AceGUIWidgetLSMlists.background,
										get = function() return db.UI.default.background end,
										set = function(info, key)
											for _,v in pairs(db.UI) do
												v.background = key
											end
											self:UpdateFrames()
										end
									},
									backgroundColor = {
										order = 4,
										name = L["Background Color"],
										type = "color",
										hasAlpha = true,
										get = function() return unpack(db.UI.default.bgColor) end,
										set = function(info, r,g,b,a)
											for _,v in pairs(db.UI) do
												v.bgColor = {r,g,b,a}
											end
											self:UpdateFrames()
										end
									},
									border = {
										order = 5,
										name = L["Border"],
										type = "select",
										width = "double",
										dialogControl = "LSM30_Border",
										values = _G.AceGUIWidgetLSMlists.border,
										get = function() return db.UI.default.border end,
										set = function(info, key)
											for _,v in pairs(db.UI) do
												v.border = key
											end
											self:UpdateFrames()
										end,
									},
									borderColor = {
										order = 6,
										name = L["Border Color"],
										type = "color",
										hasAlpha = true,
										get = function() return unpack(db.UI.default.borderColor) end,
										set = function(info, r,g,b,a)
											for _,v in pairs(db.UI) do
												v.borderColor = {r,g,b,a}
											end
											self:UpdateFrames()
										end
									},
									reset = {
										order = -1,
										name = L["Reset Skin"],
										desc = L["reset_skin_desc"],
										type = "execute",
										confirm = true,
										func = function()
											for _,v in pairs(db.UI) do
												v.bgColor = db.skins[db.currentSkin].bgColor
												v.borderColor = db.skins[db.currentSkin].borderColor
												v.background = db.skins[db.currentSkin].background
												v.border = db.skins[db.currentSkin].border
											end
											self:UpdateFrames()
										end,
									},
								},
							},
						},
					},
				},
				plugins = {
					default = {

					},
				},
			},
			mlSettings = {
				name = L["Master Looter"],
				order = 2,
				type = "group",
				childGroups = "tab",
				handler = addon,
				get = DBGet,
				set = DBSet,
				--hidden = function() return not db.advancedOptions end,
				args = {
					desc = {
						order = 1,
						type = "description",
						name = L["master_looter_desc"],
					},
					generalTab = {
						order = 2,
						type = "group",
						name = _G.GENERAL,
						args = {
							usageOptions = {
								order = 1,
								type = "group",
								name = L["Usage Options"],
								inline = true,
								args = {
									usage = {
										order = 1,
										name = L["Usage"],
										desc = L["Choose when to use RCLootCouncil"],
										type = "select",
										width = "double",
										values = {
										--	ml 			= L["Always use RCLootCouncil when I'm Master Looter"],
										--	ask_ml		= L["Ask me every time I become Master Looter"],
										--	leader 		= "Always use RCLootCouncil when I'm the group leader and enter a raid",
										--	ask_leader	= "Ask me every time I'm the group leader and enter a raid",
											pl				= L["Always use RCLootCouncil with Personal Loot"],
											ask_pl		= L["Ask me every time Personal Loot is enabled"],
											never			= L["Never use RCLootCouncil"],
										},
										set = function(_, key)
											for k in pairs(self.db.profile.usage) do
												if k == key then
													self.db.profile.usage[k] = true
												else
													self.db.profile.usage[k] = false
												end
											end
											self.db.profile.usage.state = key
										end,
										get = function() return self.db.profile.usage.state end,
									},
									spacer = {
												order = 2,
												type = "header",
												name = "",
									},
									onlyUseInRaids = {
										order = 4,
										name = L["Only use in raids"],
										desc = L["onlyUseInRaids_desc"],
										type = "toggle",
									},
									outOfRaid = {
										order = 5,
										name = L["options_ml_outOfRaid_name"],
										desc = L["options_ml_outOfRaid_desc"],
										type = "toggle"
									},
								},
							},
							lootingOptions = {
								order = 2,
								name = L["Looting options"],
								type = "group",
								inline = true,
								args = {
									autoStart = {
										order = 1,
										name = L["opt_skipSessionFrame_name"],
										desc = L["opt_skipSessionFrame_desc"],
										type = "toggle",
									},
									sortItems = {
										order = 2,
										name = L["Sort Items"],
										desc = L["sort_items_desc"],
										type = "toggle",
									},
									spacer = {
										order = 4,
										type = "header",
										name = "",
									},
									autoLoot = {
										order = 5,
										name = L["opt_autoAddItems_name"],
										desc = L["opt_autoAddItems_desc"],
										type = "toggle",
									},
									autolootBoE = {
										order = 6,
										name = L["opt_autoAddBoEs_name"],
										desc = L["opt_autoAddBoEs_desc"],
										type = "toggle",
										disabled = function() return not self.db.profile.autoLoot end,
									},
									lootPets = {
										order = 6.5,
										name = L["opt_autoAddPets_name"],
										desc = L["opt_autoAddPets_desc"],
										type = "toggle",
										get = function()
											return not addon.blacklistedItemClasses[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_COMPANION_PET]
										end,
										set = function(_, val)
											addon.blacklistedItemClasses[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_COMPANION_PET] = not val
										end
									},
									printCompletedTrades = {
										order = 7,
										name = L["opt_printCompletedTrade_Name"],
										desc = L["opt_printCompletedTrade_Desc"],
										type = "toggle",
									},
									rejectTrade = {
										order = 8,
										name = L["opt_rejectTrade_Name"],
										desc = L["opt_rejectTrade_Desc"],
										type = "toggle",
									},
									awardLater = {
										order = 9,
										name = L["Award later"],
										desc = L["opt_award_later_desc"],
										type = "toggle"
									},
								},
							},
							voteOptions = {
								order = 3,
								name = L["Voting options"],
								type = "group",
								inline = true,
								args = {
									selfVote = {
										order = 1,
										name = L["Self Vote"],
										desc = L["self_vote_desc"],
										type = "toggle",
									},
									multiVote = {
										order = 2,
										name = L["Multi Vote"],
										desc = L["multi_vote_desc"],
										type = "toggle",
									},
									anonymousVoting = {
										order = 4,
										name = L["Anonymous Voting"],
										desc = L["anonymous_voting_desc"],
										type = "toggle",
									},
									showForML = {
										order = 5,
										name = L["ML sees voting"],
										desc = L["ml_sees_voting_desc"],
										type = "toggle",
										disabled = function() return not self.db.profile.anonymousVoting end,
									},
									hideVotes = {
										order = 6,
										name = L["Hide Votes"],
										desc = L["hide_votes_desc"],
										type = "toggle",
									},
									observe = {
										order = 7,
										name = L["Observe"],
										desc = L["observe_desc"],
										type = "toggle",
									},
									autoAddRolls = {
										order = 8,
										name = L["Add Rolls"],
										desc = L["add_rolls_desc"],
										type = "toggle",
									},
									requireNotes = {
										order = 9,
										name = L["Require Notes"],
										desc = L["options_requireNotes_desc"],
										type = "toggle",
									},
								},
							},
							ignoreOptions = {
								order = 4,
								name = L["Ignore Options"],
								type = "group",
								inline = true,
								args = {
									desc = {
										order = 1,
										name = L["ignore_options_desc"],
										type = "description",
									},
									ignoreInput = {
										order = 2,
										name = L["Add Item"],
										desc = L["ignore_input_desc"],
										type = "input",
										validate = function(_, val) return GetItemInfoInstant(val) end,
										usage = L["ignore_input_usage"],
										get = function() return "\"item ID, Name or Link\"" end,
										set = function(info, val)
											local id = GetItemInfoInstant(val)
											if id then
												self.db.profile.ignoredItems[id] = true
												LibStub("AceConfigRegistry-3.0"):NotifyChange("RCLootCouncil")
											end
										end,
									},
									ignoreList = {
										order = 3,
										name = L["Ignore List"],
										desc = L["ignore_list_desc"],
										type = "select",
										style = "dropdown",
										width = "double",
										values = function()
											local t = {}
											for id, val in pairs(self.db.profile.ignoredItems) do
												if val then
													local link = select(2, GetItemInfo(id))
													if link then
														t[id] = link.."  (id: "..id..")"
													else
														t[id] = L["Not cached, please reopen."].."  (id: "..id..")"
													end
												end
											end
											return t
										end,
										get = function() return L["Ignore List"] end,
										set = function(info, val) self.db.profile.ignoredItems[val] = false end,
									},
								},
							},
						},
					},
					awardsTab = {
						order = 3,
						type = "group",
						name = L["Awards"],
						args = {
							autoAward = {
								order = 1,
								name = L["Auto Award"],
								type = "group",
								inline = true,
								disabled = function() return not self.db.profile.autoAward end,
								args = {
									desc = {
										order = 0,
										name = format(L["You can only auto award items with a quality lower than 'quality' to yourself due to Blizaard restrictions"],"|cff1eff00"..getglobal("ITEM_QUALITY2_DESC").."|r"),
										type = "description",
										hidden = function() return self.db.profile.autoAwardLowerThreshold >= 2 end,
									},
									autoAward = {
										order = 1,
										name = L["Auto Award"],
										desc = L["auto_award_desc"],
										type = "toggle",
										disabled = false,
									},
									autoAwardLowerThreshold = {
										order = 1.1,
										name = L["Lower Quality Limit"],
										desc = L["lower_quality_limit_desc"],
										type = "select",
										style = "dropdown",
										values = function()
											local t = {}
											for i = 0, 5 do
												local _,_,_,hex = GetItemQualityColor(i)
												t[i] = "|c"..hex.." "..getglobal("ITEM_QUALITY"..i.."_DESC")
											end
											return t;
										end,
									},
									autoAwardUpperThreshold = {
										order = 1.2,
										name = L["Upper Quality Limit"],
										desc = L["upper_quality_limit_desc"],
										type = "select",
										style = "dropdown",
										values = function()
											local t = {}
											for i = 0, 5 do
												--local r,g,b,hex = GetItemQualityColor(i)
												--t[i] = "|c"..hex.." "..getglobal("ITEM_QUALITY"..i.."_DESC")
												t[i] = ITEM_QUALITY_COLORS[i].hex..getglobal("ITEM_QUALITY"..i.."_DESC")
											end
											return t;
										end,
									},
									autoAwardTo2 = {
										order = 2,
										name = L["add_candidate"],
										desc = L["auto_award_to_desc"],
										width = "double",
										type = "input",
										hidden = function() return GetNumGroupMembers() > 0 end,
										get = function() return "" end,
										set = autoAwardFieldProcessor(db.autoAwardTo),
									},
									autoAwardTo = {
										order = 2,
										name = L["add_candidate"],
										desc = L["auto_award_to_desc"],
										width = "double",
										type = "select",
										style = "dropdown",
										values = function()
											local t = {}
											for i = 1, GetNumGroupMembers() do
												local name = GetRaidRosterInfo(i)
												t[name] = name
											end
											return t;
										end,
										get = function() return "" end,
										set = function(_, val)
											if not tContains(db.autoAwardTo, val) then
												tinsert(db.autoAwardTo, val)
											end
										end,
										hidden = function() return GetNumGroupMembers() == 0 end,
									},
									autoAwardReason = {
										order = 2.1,
										name = L["Reason"],
										desc = L["reason_desc"],
										type = "select",
										style = "dropdown",
										values = function()
											local t = {}
											for i = 1, self.db.profile.numAwardReasons do
												t[i] = self.db.profile.awardReasons[i].text
											end
											return t
										end,
									},

									autoAwardMembers = {
										order = 10,
										name = L["Auto Award to"],
										type = "group",
										inline = true,
										hidden = function() return not db.autoAward end,
										args = createAutoAwardPrioList(db.autoAwardTo)
									},
								},
							},
							autoAwardBoE = {
								order = 2,
								name = L["options_autoAwardBoE_name"],
								type = "group",
								inline = true,
								disabled = function () return not self.db.profile.autoAwardBoE end,
								args = {
									autoAwardBoE = {
										order = 1,
										name = L["options_autoAwardBoE_name"],
										desc = L["options_autoAwardBoE_desc"],
										type = "toggle",
										disabled = false,
										width = "full",
									},
									autoAwardBoETo2 = {
										order = 2,
										name = L["add_candidate"],
										desc = L["auto_award_to_desc"],
										width = "double",
										type = "input",
										hidden = function() return GetNumGroupMembers() > 0 end,
										get = function() return "" end,
										set = autoAwardFieldProcessor(db.autoAwardBoETo),
									},
									autoAwardBoETo = {
										order = 2,
										name = L["add_candidate"],
										desc = L["auto_award_to_desc"],
										width = "double",
										type = "select",
										style = "dropdown",
										values = function()
											local t = {}
											for i = 1, GetNumGroupMembers() do
												local name = GetRaidRosterInfo(i)
												t[name] = name
											end
											return t;
										end,
										get = function() return "" end,
										set = function(_,val)
											if not tContains(db.autoAwardBoETo, val) then
												tinsert(db.autoAwardBoETo, val)
											end
										end,
										hidden = function() return GetNumGroupMembers() == 0 end,
									},
									autoAwardBoEReason = {
										order = 3,
										name = L["Reason"],
										desc = L["reason_desc"],
										type = "select",
										style = "dropdown",
										values = function()
											local t = {}
											for i = 1, self.db.profile.numAwardReasons do
												t[i] = self.db.profile.awardReasons[i].text
											end
											return t
										end,
									},
									autoAwardBoEMembers = {
										order = 10,
										name = L["Auto Award to"],
										type = "group",
										inline = true,
										hidden = function() return not db.autoAwardBoE end,
										args = createAutoAwardPrioList(db.autoAwardBoETo)
									},
								}
							},
							awardReasons = {
								order = 3,
								type = "group",
								name = L["Award Reasons"],
								inline = true,
								args = {
									desc = {
										order = 0,
										name = L["award_reasons_desc"],
										type = "description",
									},
									numAwardReasons = {
										order = 1,
										name = L["Number of reasons"],
										desc = L["number_of_reasons_desc"],
										type = "range",
										width = "full",
										min = 1,
										max = self.db.profile.maxAwardReasons,
										step = 1,
									},
									-- Award reasons made further down
									reset = {
										order = -1,
										name = _G.RESET_TO_DEFAULT,
										desc = L["reset_to_default_desc"],
										type = "execute",
										confirm = true,
										func = function()
											self.db.profile.awardReasons = self.defaults.profile.awardReasons
											self.db.profile.numAwardReasons = self.defaults.profile.numAwardReasons
											self:ConfigTableChanged()
										end,
									},
								},
							},
						},
					},
					announcementsTab = {
						order = 4,
						type = "group",
						name = L["Announcements"],
						args = {
							awardAnnouncement = {
								order = 1,
								name = L["Award Announcement"],
								type = "group",
								inline = true,
								args = {
									announceAward = {
										order = 1,
										name = L["Announce Awards"],
										desc = L["announce_awards_desc"],
										type = "toggle",
										width = "full",
									},
									outputDesc = {
										order = 2,
										fontSize = "medium",
										name = function() return L["announce_awards_desc2"].."\n"..table.concat(RCLootCouncilML.awardStringsDesc, "\n") end,  -- use function so module can update this.
										type = "description",
										hidden = function() return not self.db.profile.announceAward end,
									},
									-- Rest is made further below
								},
							},

							announceConsiderations = {
								order = 2,
								name = L["Announce Considerations"],
								type = "group",
								inline = true,
								args = {
									announceItems = {
										order = 1,
										name = L["Announce Considerations"],
										desc = L["announce_considerations_desc"],
										type = "toggle",
										width = "full",
									},
									desc = {
										order = 2,
										type = "description",
										name = L["announce_considerations_desc2"],
										hidden = function() return not self.db.profile.announceItems end,
									},
									announceChannel = {
										order = 3,
										name = _G.CHANNEL,
										desc = L["channel_desc"],
										type = "select",
										style = "dropdown",
										values = {
											SAY = _G.CHAT_MSG_SAY,
											YELL = _G.CHAT_MSG_YELL,
											PARTY = _G.CHAT_MSG_PARTY,
											GUILD = _G.CHAT_MSG_GUILD,
											OFFICER = _G.CHAT_MSG_OFFICER,
											RAID = _G.CHAT_MSG_RAID	,
											RAID_WARNING = _G.CHAT_MSG_RAID_WARNING,
											group = _G.GROUP, -- must be converted
											chat = L["Chat print"],
										},
										set = function(i,v) self.db.profile.announceChannel = v end,
										hidden = function() return not self.db.profile.announceItems end,
									},
									announceText = {
										order = 3.1,
										name = L["Message"],
										desc = L["message_desc"],
										type = "input",
										width = "double",
										hidden = function() return not self.db.profile.announceItems end,
									},
									announceItemStringDesc ={
										order = 4,
										fontSize = "medium",
										name = function() return L["announce_item_string_desc"].."\n"..table.concat(RCLootCouncilML.announceItemStringsDesc, "\n") end, -- use function so module can update this.
										type = "description",
										hidden = function() return not self.db.profile.announceItems end,
									},
									announceItemString = {
										name = L["Message for each item"],
										order = 4.1,
										type = "input",
										width = "double",
										hidden = function() return not self.db.profile.announceItems end,
									},
								},
							},
							reset = {
								order = -1,
								name = _G.RESET_TO_DEFAULT,
								desc = L["reset_announce_to_default_desc"],
								type = "execute",
								confirm = true,
								func = function()
									for i = 1, #self.db.profile.awardText do
										self.db.profile.awardText[i].channel = self.defaults.profile.awardText[i].channel
										self.db.profile.awardText[i].text = self.defaults.profile.awardText[i].text
									end
									self.db.profile.announceAward = self.defaults.profile.announceAward
									self.db.profile.announceItems = self.defaults.profile.announceItems
									self.db.profile.announceChannel = self.defaults.profile.announceChannel
									self.db.profile.announceText = self.defaults.profile.announceText
									self.db.profile.announceItemString = self.defaults.profile.announceItemString
									self:ConfigTableChanged()
								end
							},
						},
					},
					buttonsTab = {
						order = 5,
						type = "group",
						name = L["Buttons and Responses"],
						args = {
							buttonOptions = {
								order = 1,
								type = "group",
								name = L["Buttons and Responses"],
								inline = true,
								args = {
									optionsDesc = {
										order = 0,
										name = format(L["buttons_and_responses_desc"], self.db.profile.maxButtons),
										type = "description"
									},
									numButtons = {
										order = 1,
										name = L["Number of buttons"],
										desc = L["number_of_buttons_desc"],
										type = "range",
										width = "full",
										min = 1,
										max = self.db.profile.maxButtons,
										step = 1,
										set = function(_,v) self.db.profile.buttons.default.numButtons = v end,
										get = function() return self.db.profile.buttons.default.numButtons end,
									},
									-- Made further down
								},
							},
							moreButtons = {
								order = 2,
								type = "group",
								name = L["Additional Buttons"],
								desc = "",
								inline = true,
								args = {
									desc = {
										order = 0,
										type = "description",
										name = L["opt_moreButtons_desc"],
									},
									selector = {
										order = 1,
										width = "double",
										name = L["Slot"],
										type = "select",
										values = self.OPT_MORE_BUTTONS_VALUES,
										get = function () return selections.AddMoreButtons or "INVTYPE_HEAD" end,
										set = function(i,v) selections.AddMoreButtons = v end,
									},
									addBtn = {
										order = 2,
										name = _G.ADD,
										desc = L["opt_addButton_desc"],
										type = "execute",
										func = function()
											local selection = selections.AddMoreButtons or "INVTYPE_HEAD"
											db.enabledButtons[selection] = true
											-- Also setup default options
											for i = 1, self.db.profile.maxButtons do
												if not db.buttons[selection][i] then
													db.buttons[selection][i] = {text = L["Button"]}
												end
											end
										end,
									}
								},
							},
							timeoutOptions = {
								order = 100,
								type = "group",
								name = L["Timeout"],
								inline = true,
								args = {
									enable = {
										order = 1,
										name = L["Enable Timeout"],
										desc = L["enable_timeout_desc"],
										type = "toggle",
										set = function()
											if self.db.profile.timeout then
												self.db.profile.timeout = false
											else
												self.db.profile.timeout = self.defaults.profile.timeout
											end
										end,
										get = function()
											return self.db.profile.timeout
										end,
									},
									timeout = {
										order = 2,
										name = L["Length"],
										desc = L["Choose timeout length in seconds"],
										type = "range",
										width = "full",
										min = 0,
										max = 200,
										step = 5,
										disabled = function() return not self.db.profile.timeout end,
									},
								},
							},
							moreInfoOptions = {
								order = 101,
								type = "group",
								name = L["More Info"],
								inline = true,
								args = {
									desc = {
										order = 1,
										type = "description",
										name = L["more_info_desc"],
									},
									numMoreInfoButtons = {
										order = 2,
										name = L["Number of responses"],
										type = "range",
										width = "full",
										min = 0,
										max = self.db.profile.maxButtons,
										step = 1,
									}
								},
							},
							responseFromChat = {
								order = 102,
								type = "group",
								name = L["Responses from Chat"],
								inline = true,
								args = {
									acceptWhispers = {
										order = 1,
										name = L["Accept Whispers"],
										desc = L["accept_whispers_desc"],
										type = "toggle",
									},
									desc = {
										order = 2,
										name = L["responses_from_chat_desc"],
										type = "description",
										hidden = function() return not self.db.profile.acceptWhispers end,
									},
									-- Made further down
								},
							},
							reset = {
								order = -1,
								name = _G.RESET_TO_DEFAULT,
								desc = L["reset_buttons_to_default_desc"],
								type = "execute",
								confirm = true,
								func = function()
									self.db.profile.buttons = self.defaults.profile.buttons
									self.db.profile.responses = self.defaults.profile.responses
									self.db.profile.acceptWhispers = self.defaults.profile.acceptWhispers
									self.db.profile.enabledButtons = {}
									-- now remove *'s (UpdateDB() will re-register the defaults)
									for k,v in pairs(self.db.profile.buttons) do if k == '*' then v = nil end end -- luacheck: ignore
									for k,v in pairs(self.db.profile.responses) do if k == '*' then v = nil end end -- luacheck: ignore
									self:UpdateDB()
									self:ConfigTableChanged()
								end,
							},
						},
					},
					councilTab = {
						order = 6,
						type = "group",
						name = L["Council"],
						childGroups = "tab",
						args = {
							currentCouncil = {
								order = 1,
								type = "group",
								name = L["Current Council"],
								args = {
									currentCouncilDesc = {
										order = 1,
										name = L["current_council_desc"],
										type = "description",
									},
									councilList = {
										order = 2,
										type = "multiselect",
										name = "",
										values = function()
											local t = {}
											for _,v in ipairs(self.db.profile.council) do t[v] = addon.Ambiguate(Player:Get(v):GetName()) end
											table.sort(t)
											return t;
										end,
										width = "full",
										get = function() return true end,
										set = function(m,key)
											tDeleteItem(self.db.profile.council, key)
											addon:CouncilChanged()
										end,
									},
									removeAll = {
										order = 3,
										name = L["Remove All"],
										desc = L["remove_all_desc"],
										type = "execute",
										confirm = true,
										func = function() self.db.profile.council = {}; addon:CouncilChanged() end,
									},
								},
							},
							addCouncil = {
								order = 2,
								type = "group",
								name = L["Guild Council Members"],
								childGroups = "tree",
								args = {
									addRank = {
										order = 1,
										name = L["Add ranks"],
										type = "group",
										args = {
											header1 = {
												order = 1,
												name = L["add_ranks_desc"],
												type = "header",
												width = "full",
											},
											selection = {
												order = 2,
												name = "",
												type = "select",
												width = "full",
												values = function()
													addon.Utils:GuildRoster();
													local info = {};
													for ci = 1, GuildControlGetNumRanks() do
														info[ci] = " "..ci.." - "..GuildControlGetRankName(ci);
													end
													return info
												end,
												set = function(_, val)
													self.db.profile.minRank = val
													for i = 1, GetNumGuildMembers() do
														local _, _, rankIndex,_, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
														if rankIndex + 1 <= val then -- if the member is the required rank, or above
															tinsert(self.db.profile.council, guid) -- then insert them to the council
														end
													end
													addon:CouncilChanged()
												end,
												get = function() return self.db.profile.minRank; end,
											},
											desc = {
												order = 3,
												name = L["add_ranks_desc2"],
												type = "description",
											},
										},
									},
									spacer = {
										order = 2,
										name = "",
										type = "group",
										args = {}
									},
									-- Rest of guild council is made further down when ready
								},
							},
							addGroupCouncil = {
								order = 3,
								type = "group",
								name = L["Group Council Members"],
								args = {
									header1 = {
										order = 1,
										name = L["group_council_members_head"],
										type = "header",
										width = "full",
									},
									desc = {
										order = 2,
										name = L["group_council_members_desc"],
										type = "description",
									},
									list = {
										order = 3,
										type = "multiselect",
										name = "",
										width = "full",
										values = function()
											local t = {}
											for i = 1, GetNumGroupMembers() do
												local name = select(1,GetRaidRosterInfo(i))
												local guid = UnitGUID(name)
												t[guid] = self.Ambiguate(name)
											end
											if #t == 0 then t[self.player:GetGUID()] = self.player:GetShortName() end -- Insert ourself
											table.sort(t, function(v1, v2)
												return v1 and v1 < v2
											end)
											return t
										end,
										set = function(info,key,tag)
											if tag then -- add
												tinsert(self.db.profile.council, key)
											else -- remove
												tDeleteItem(self.db.profile.council, key)
											end
											addon:CouncilChanged()
										end,
										get = function(info, key)
											return tContains(self.db.profile.council, key)
										end,
									},
								},
							},
						},
					},
				},
			},
		},
	}
	-- #region Create options thats made with loops
	-- NOTE Kind of redundant, but the createNewButtonSet() was created with groups in mind, not the default buttons
	-- Buttons
	local button, picker, text
	for i = 1, self.db.profile.buttons.default.numButtons do
		button = {
			order = i * 5 + 1,
			name = L["Button"].." "..i,
			desc = format(L["Set the text on button 'number'"], i),
			type = "input",
			get = function() return self.db.profile.buttons.default[i].text end,
			set = function(info, value) addon:ConfigTableChanged("buttons"); self.db.profile.buttons.default[i].text = tostring(value) end,
			hidden = function() return self.db.profile.buttons.default.numButtons < i end,
		}
		options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["button"..i] = button;
		picker = {
			order = i * 5 + 2,
			name = L["Response color"],
			desc = L["response_color_desc"],
			width = 0.8,
			type = "color",
			get = function() return unpack(self.db.profile.responses.default[i].color)	end,
			set = function(info,r,g,b,a) addon:ConfigTableChanged("responses"); self.db.profile.responses.default[i].color = {roundColors(r,g,b,a)} end,
			hidden = function() return self.db.profile.buttons.default.numButtons < i end,
		}
		options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["picker"..i] = picker;
		text = {
			order = i * 5 + 3,
			name = L["Response"],
			desc = format(L["Set the text for button i's response."], i),
			type = "input",
			get = function() return self.db.profile.responses.default[i].text end,
			set = function(info, value) addon:ConfigTableChanged("responses"); self.db.profile.responses.default[i].text = tostring(value) end,
			hidden = function() return self.db.profile.buttons.default.numButtons < i end,
		}
		options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["text"..i] = text;
		options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["move_up"..i] = {
			order = i * 5 + 4,
			name = "",
			type = "execute",
			width = 0.1,
			image = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up",
			disabled = function() return i == 1 end, -- Disable the top button
			func = function()
				-- We basically need to switch two variables, this up, and the former up down.
				-- Variables: addon.db.profile.responses[name] + addon.db.profile.buttons[name]
				-- Temp store this data
				local tempBtn = self.db.profile.buttons.default[i]
				local tempResponse = self.db.profile.responses.default[i]
				-- Move i - 1 down to i
				self.db.profile.buttons.default[i] = self.db.profile.buttons.default[i - 1]
				self.db.profile.responses.default[i] = self.db.profile.responses.default[i - 1]
				-- And move the temp up
				self.db.profile.buttons.default[i - 1] = tempBtn
				self.db.profile.responses.default[i - 1] = tempResponse

				self.db.profile.responses.default[i].sort = i
				self.db.profile.responses.default[i - 1].sort = i - 1
				addon:ConfigTableChanged("responses")
			end,
		}
		options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["move_down"..i] = {
			order = i * 5 + 4.1,
			name = "",
			type = "execute",
			width = 0.1,
			image = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up",
			disabled = function() return i == self.db.profile.buttons.default.numButtons end,
			func = function()
				local tempBtn = self.db.profile.buttons.default[i]
				local tempResponse = self.db.profile.responses.default[i]
				self.db.profile.buttons.default[i] = self.db.profile.buttons.default[i + 1]
				self.db.profile.responses.default[i] = self.db.profile.responses.default[i + 1]
				self.db.profile.buttons.default[i + 1] = tempBtn
				self.db.profile.responses.default[i + 1] = tempResponse

				self.db.profile.responses.default[i].sort = i
				self.db.profile.responses.default[i + 1].sort = i + 1

				addon:ConfigTableChanged("responses")
			end,
		}

		local whisperKeys = {
			order = i + 3,
			name = L["Button"]..i,
			desc = format(L["Set the whisper keys for button i."], i),
			type = "input",
			width = "double",
			get = function() return self.db.profile.buttons.default[i].whisperKey end,
			set = function(k,v) self.db.profile.buttons.default[i].whisperKey = tostring(v) end,
			hidden = function() return not (self.db.profile.acceptWhispers or self.db.profile.acceptRaidChat) or self.db.profile.buttons.default.numButtons < i end,
		}
		options.args.mlSettings.args.buttonsTab.args.responseFromChat.args["whisperKey"..i] = whisperKeys;
	end

	-- Award Reasons
	for i = 1, self.db.profile.numAwardReasons do
		options.args.mlSettings.args.awardsTab.args.awardReasons.args["reason"..i] = {
			order = i+1,
			name = L["Reason"]..i,
			desc = L["Text for reason #i"]..i,
			type = "input",
			--width = "double",
			get = function() return self.db.profile.awardReasons[i].text end,
			set = function(k,v) addon:ConfigTableChanged("awardReasons"); self.db.profile.awardReasons[i].text = v; end,
			hidden = function() return self.db.profile.numAwardReasons < i end,
		}
		options.args.mlSettings.args.awardsTab.args.awardReasons.args["color"..i] = {
			order = i +1.1,
			name = L["Text color"],
		--	name = "",
			desc = L["text_color_desc"],
			type = "color",
			width = "half",
			get = function() return unpack(self.db.profile.awardReasons[i].color) end,
			set = function(info, r,g,b,a) self.db.profile.awardReasons[i].color = {roundColors(r,g,b,a)} end,
			hidden = function() return self.db.profile.numAwardReasons < i end,
		}
		options.args.mlSettings.args.awardsTab.args.awardReasons.args["log"..i] = {
			order = i +1.2,
			name = L["Log"],
			desc = L["log_desc"],
			type = "toggle",
			width = 0.4,
			get = function() return self.db.profile.awardReasons[i].log end,
			set = function() self.db.profile.awardReasons[i].log = not self.db.profile.awardReasons[i].log end,
			hidden = function() return self.db.profile.numAwardReasons < i end,
		}
		options.args.mlSettings.args.awardsTab.args.awardReasons.args["DE"..i] = {
			order = i +1.3,
			name = _G.ROLL_DISENCHANT,
			desc = L["disenchant_desc"],
			type = "toggle",
			width = 0.8,
			get = function() return self.db.profile.awardReasons[i].disenchant end,
			set = function(info, val)
				for _,v in ipairs(self.db.profile.awardReasons) do
					v.disenchant = false
				end
				self.db.profile.awardReasons[i].disenchant = val
				self.db.profile.disenchant = val
			end,
			hidden = function() return self.db.profile.numAwardReasons < i end,
		}
		options.args.mlSettings.args.awardsTab.args.awardReasons.args["moveUp"..i] = {
			order = i + 1.4,
			name = "",
			type = "execute",
			width = 0.1,
			image = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up",
			disabled = function() return i == 1 end, -- Disable the top button
			func = function()
				local tempResponse = self.db.profile.awardReasons[i]
				-- Move i - 1 down to i
				self.db.profile.awardReasons[i] = self.db.profile.awardReasons[i - 1]
				-- And move the temp up
				self.db.profile.awardReasons[i - 1] = tempResponse
			end,
		}
		options.args.mlSettings.args.awardsTab.args.awardReasons.args["moveDown"..i] = {
			order = i + 1.5,
			name = "",
			type = "execute",
			width = 0.1,
			image = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up",
			disabled = function() return i == self.db.profile.numAwardReasons end, -- Disable the bottom button
			func = function()
				local tempResponse = self.db.profile.awardReasons[i]
				-- Move i - 1 down to i
				self.db.profile.awardReasons[i] = self.db.profile.awardReasons[i + 1]
				-- And move the temp up
				self.db.profile.awardReasons[i + 1] = tempResponse
			end,
		}
	end
	-- Announce Channels
	for i = 1, #self.db.profile.awardText do
		options.args.mlSettings.args.announcementsTab.args.awardAnnouncement.args["outputSelect"..i] = {
			order = i+3,
			name = _G.CHANNEL..i..":",
			desc = L["channel_desc"],
			type = "select",
			style = "dropdown",
			values = {
				NONE = _G.NONE,
				SAY = _G.CHAT_MSG_SAY,
				YELL = _G.CHAT_MSG_YELL,
				PARTY = _G.CHAT_MSG_PARTY,
				GUILD = _G.CHAT_MSG_GUILD,
				OFFICER = _G.CHAT_MSG_OFFICER,
				RAID = _G.CHAT_MSG_RAID,
				RAID_WARNING = _G.CHAT_MSG_RAID_WARNING,
				group = _G.GROUP,
				chat = L["Chat print"],
			},
			set = function(j,v) self.db.profile.awardText[i].channel = v	end,
			get = function() return self.db.profile.awardText[i].channel end,
			hidden = function() return not self.db.profile.announceAward end,
		}
		options.args.mlSettings.args.announcementsTab.args.awardAnnouncement.args["outputMessage"..i] = {
			order = i+3.1,
			name = L["Message"],
			desc = L["message_desc"],
			type = "input",
			width = "double",
			get = function() return self.db.profile.awardText[i].text end,
			set = function(j,v) self.db.profile.awardText[i].text = v; end,
			hidden = function() return not self.db.profile.announceAward end,
		}
	end
	-- #endregion
	local i = 4
	for group in pairs(db.enabledButtons) do
		createNewButtonSet(options.args.mlSettings.args.buttonsTab.args, group, i)
		i = i + 1
	end

	options.args.settings.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) -- Add profile tab
	addon.options = options
	self:GetGuildOptions()
	return options
end

function addon:GetGuildOptions()
	for i = 1, GuildControlGetNumRanks() do
		local rank = GuildControlGetRankName(i)
		local names = {}

		-- Define the individual council option:
		local option = {
			order = i + 2,
			name = rank,
			type = "group",
			args = {
				ranks = {
					order = i,
					name = ""..rank,
					type = "multiselect",
					width = "full",
					values = function()
						wipe(names)
						for ci = 1, GetNumGuildMembers() do
							local name, _, rankIndex,_, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(ci); -- NOTE I assume the realm part of name is without spaces.
							if (rankIndex + 1) == i then names[guid] = addon.Ambiguate(name) end -- Ambiguate to show realmname for players from another realm
						end
						table.sort(names, function(v1, v2)
							return v1 and v1 < v2
						end)
						return names
					end,
					get = function(info, key)
						return tContains(self.db.profile.council, key)
					end,
					set = function(info, key, tag)
						if tag then
							tinsert(self.db.profile.council, key)
						else
							tDeleteItem(self.db.profile.council, key)
						end
						addon:CouncilChanged()
					end,
				},
			},
		}

		-- Add it to the guildMembersGroup arguments:
		self.options.args.mlSettings.args.councilTab.args.addCouncil.args[i..""..rank] = option
	end
end
