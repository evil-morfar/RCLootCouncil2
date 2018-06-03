--- options.lua - option frame in BlizzardOptions for RCLootCouncil
-- @author Potdisc
-- Create Date : 5/24/2012 6:24:55 PM

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
------ Options ------
function addon:OptionsTable()
	local db = self:Getdb()
	local options = {
		name = "RCLootCouncil",
		type = "group",
		handler = addon,
		get = "DBGet",
		set = "DBSet",
		args = {
			settings = {
				order = 1,
				type = "group",
				name = _G.GENERAL,
				childGroups = "tab",
				args = {
					version = {
						order = 1,
						type = "description",
						name = function() return self.tVersion and "|cFF87CEFAv"..self.version.."|r-"..self.tVersion or "|cFF87CEFAv"..self.version.."|r" end,
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
									autoOpen = {
										order = 2,
										name = L["Auto Open"],
										desc = L["auto_open_desc"],
										type = "toggle",
									},
									autoClose = {
										order = 3,
										name = L["Auto Close"],
										desc = L["auto_close_desc"],
										type = "toggle",
									},
									minimizeInCombat = {
										order = 4,
										name = L["Minimize in combat"],
										desc = L["Check to have all frames minimize when entering combat"],
										type = "toggle",
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
											self.Sync:Spawn()
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
									showSpecIcon = {
										order = 1,
										name = L["Show Spec Icon"],
										desc = L["show_spec_icon_desc"],
										type = "toggle",
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
										func = function() self:CallModule("history");	InterfaceOptionsFrame:Hide();end,
									},
									clearLootDB = {
										order = 6,
										name = L["Clear Loot History"],
										desc = L["clear_loot_history_desc"],
										type = "execute",
										func = function() self.lootDB:ResetDB(); self:UpdateHistoryDB() end,
										confirm = true,
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
											for k in pairs(db.skins) do db.currentSkin = k break end
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
											for k,v in pairs(db.UI) do
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
											for k,v in pairs(db.UI) do
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
										values = AceGUIWidgetLSMlists.border,
										get = function() return db.UI.default.border end,
										set = function(info, key)
											for k,v in pairs(db.UI) do
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
											for k,v in pairs(db.UI) do
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
											for k,v in pairs(db.UI) do
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
				get = "DBGet",
				set = "DBSet",
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
											ml 			= L["Always use RCLootCouncil when I'm Master Looter"],
											ask_ml		= L["Ask me every time I become Master Looter"],
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
									leaderUsage = { -- Add leader options here since we can only make a single select dropdown
										order = 3,
										name = function() return self.db.profile.usage.ml and L["Always use when leader"] or L["Ask me when leader"] end,
										desc = L["leaderUsage_desc"],
										type = "toggle",
										get = function() return self.db.profile.usage.leader or self.db.profile.usage.ask_leader end,
										set = function(_, val)
											self.db.profile.usage.leader, self.db.profile.usage.ask_leader = false, false -- Reset for zzzzz
											if self.db.profile.usage.ml then self.db.profile.usage.leader = val end
											if self.db.profile.usage.ask_ml then self.db.profile.usage.ask_leader = val end
										end,
										disabled = function() return self.db.profile.usage.never or self.db.profile.usage.pl or self.db.profile.usage.ask_pl end,
									},
									onlyUseInRaids = {
										order = 4,
										name = L["Only use in raids"],
										desc = L["onlyUseInRaids_desc"],
										type = "toggle",
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
										name = L["Auto Start"],
										desc = L["auto_start_desc"],
										type = "toggle",
									},
									altClickLooting = {
										order = 2,
										name = L["Alt click Looting"],
										desc = L["alt_click_looting_desc"],
										type = "toggle",
									},
									sortItems = {
										order = 3,
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
										name = _G.AUTO_LOOT_DEFAULT_TEXT,
										desc = L["auto_loot_desc"],
										type = "toggle",
									},
									autolootEverything = {
										order = 6,
										name = L["Loot Everything"],
										desc = L["loot_everything_desc"],
										type = "toggle",
										disabled = function() return not self.db.profile.autoLoot end,
									},
									autolootBoE = {
										order = 7,
										name = L["Autoloot BoE"],
										desc = L["autoloot_BoE_desc"],
										type = "toggle",
										disabled = function() return not self.db.profile.autoLoot end,
									},
									autolootOthersBoE = {
										order = 8,
										name = L["Autoloot all BoE"],
										desc = L["autoloot_others_BoE_desc"],
										type = "toggle",
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
									allowNotes = {
										order = 3,
										name = L["Notes"],
										desc = L["notes_desc"],
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
									}
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
												local r,g,b,hex = GetItemQualityColor(i)
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
										name = L["Auto Award to"],
										desc = L["auto_award_to_desc"],
										width = "double",
										type = "input",
										hidden = function() return GetNumGroupMembers() > 0 end,
										get = function() return self.db.profile.autoAwardTo; end,
										set = function(i,v) self.db.profile.autoAwardTo = v; end,
									},
									autoAwardTo = {
										order = 2,
										name = L["Auto Award to"],
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
								},
							},
							awardReasons = {
								order = 2,
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
									},
									-- Made further down
								},
							},
							tierButtonsOptions = {
								order = 2,
								type = "group",
								name = L["Tier Buttons and Responses"],
								inline = true,
								args = {
									tierButtonsEnabled = {
										order = 0,
										name = L["Enable Tier Buttons"],
										desc = L["enable_tierbuttons_desc"],
										type = "toggle",
									},
									optionsDesc = {
										order = 0.1,
										name = L["tier_buttons_desc"],
										type = "description",
										hidden = function() return not self.db.profile.tierButtonsEnabled end,
									},
									tierNumButtons = {
										order = 1,
										name = L["Number of buttons"],
										desc = L["number_of_buttons_desc"],
										type = "range",
										width = "full",
										min = 1,
										max = self.db.profile.maxButtons,
										step = 1,
										hidden = function() return not self.db.profile.tierButtonsEnabled end,
									},
									-- Made further down
								},
							},
							relicButtonsOptions = {
								order = 2.1,
								type = "group",
								name = L["Relic Buttons and Responses"],
								inline = true,
								args = {
									relicButtonsEnabled = {
										order = 0,
										name = L["Enable Relic Buttons"],
										desc = L["enable_relicbuttons_desc"],
										type = "toggle",
									},
									optionsDesc = {
										order = 0.1,
										name = L["relic_buttons_desc"],
										type = "description",
										hidden = function() return not self.db.profile.relicButtonsEnabled end,
									},
									relicNumButtons = {
										order = 1,
										name = L["Number of buttons"],
										desc = L["number_of_buttons_desc"],
										type = "range",
										width = "full",
										min = 1,
										max = self.db.profile.maxButtons,
										step = 1,
										hidden = function() return not self.db.profile.relicButtonsEnabled end,
									},
									-- Buttons is made further down
								},
							},
							timeoutOptions = {
								order = 3,
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
								order = 4,
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
								order = 5,
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
									self.db.profile.tierButtons = self.defaults.profile.tierButtons
									self.db.profile.relicButtons = self.defaults.profile.relicButtons
									self.db.profile.responses = self.defaults.profile.responses
									self.db.profile.numButtons = self.defaults.profile.numButtons
									self.db.profile.tierNumButtons = self.defaults.profile.tierNumButtons
									self.db.profile.relicNumButtons = self.defaults.profile.relicNumButtons
									self.db.profile.acceptWhispers = self.defaults.profile.acceptWhispers
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
											for k,v in ipairs(self.db.profile.council) do t[k] = self.Ambiguate(v) end
											return t;
										end,
										width = "full",
										get = function() return true end,
										set = function(m,key) tremove(self.db.profile.council,key); addon:CouncilChanged() end,
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
													GuildRoster();
													local info = {};
													for ci = 1, GuildControlGetNumRanks() do
														info[ci] = " "..ci.." - "..GuildControlGetRankName(ci);
													end
													return info
												end,
												set = function(_, val)
													self.db.profile.minRank = val
													for i = 1, GetNumGuildMembers() do
														local name, _, rankIndex = GetGuildRosterInfo(i) -- get info from all guild members
														if rankIndex + 1 <= val then -- if the member is the required rank, or above
															tinsert(self.db.profile.council, name) -- then insert them to the council
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
												t[self:UnitName(name)] = self.Ambiguate(name)
											end
											if #t == 0 then t[self.playerName] = self.Ambiguate(self.playerName) end -- Insert ourself
											table.sort(t, function(v1, v2)
												return v1 and v1 < v2
											end)
											return t
										end,
										set = function(info,key,tag)
											--local values = self.options.args.mlSettings.args.councilTab.args.addGroupCouncil.args.list.values()
											if tag then -- add
												tinsert(self.db.profile.council, key)
											else -- remove
												for k,v in ipairs(self.db.profile.council) do
													if v == key then
														tremove(self.db.profile.council, k)
													end
												end
											end
											addon:CouncilChanged()
										end,
										get = function(info, key)
											--local values = self.options.args.mlSettings.args.councilTab.args.addGroupCouncil.args.list.values()
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
	local function roundColors(r,g,b,a)
		return addon.round(r,2),addon.round(g,2),addon.round(b,2),addon.round(a,2)
	end

	-- #region Create options thats made with loops
	-- Buttons
	local button, picker, text = {}, {}, {}
	for i = 1, self.db.profile.maxButtons do
		button = {
			order = i * 3 + 1,
			name = L["Button"].." "..i,
			desc = format(L["Set the text on button 'number'"], i),
			type = "input",
			get = function() return self.db.profile.buttons[i].text end,
			set = function(info, value) addon:ConfigTableChanged("buttons"); self.db.profile.buttons[i].text = tostring(value) end,
			hidden = function() return self.db.profile.numButtons < i end,
		}
		options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["button"..i] = button;
		picker = {
			order = i * 3 + 2,
			name = L["Response color"],
			desc = L["response_color_desc"],
			type = "color",
			get = function() return unpack(self.db.profile.responses[i].color)	end,
			set = function(info,r,g,b,a) addon:ConfigTableChanged("responses"); self.db.profile.responses[i].color = {roundColors(r,g,b,a)} end,
			hidden = function() return self.db.profile.numButtons < i end,
		}
		options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["picker"..i] = picker;
		text = {
			order = i * 3 + 3,
			name = L["Response"],
			desc = format(L["Set the text for button i's response."], i),
			type = "input",
			get = function() return self.db.profile.responses[i].text end,
			set = function(info, value) addon:ConfigTableChanged("responses"); self.db.profile.responses[i].text = tostring(value) end,
			hidden = function() return self.db.profile.numButtons < i end,
		}
		options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["text"..i] = text;

		local whisperKeys = {
			order = i + 3,
			name = L["Button"]..i,
			desc = format(L["Set the whisper keys for button i."], i),
			type = "input",
			width = "double",
			get = function() return self.db.profile.buttons[i].whisperKey end,
			set = function(k,v) self.db.profile.buttons[i].whisperKey = tostring(v) end,
			hidden = function() return not (self.db.profile.acceptWhispers or self.db.profile.acceptRaidChat) or self.db.profile.numButtons < i end,
		}
		options.args.mlSettings.args.buttonsTab.args.responseFromChat.args["whisperKey"..i] = whisperKeys;
	end

	-- Award Reasons
	for i = 1, self.db.profile.maxAwardReasons do
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
			width = "half",
			get = function() return self.db.profile.awardReasons[i].log end,
			set = function() self.db.profile.awardReasons[i].log = not self.db.profile.awardReasons[i].log end,
			hidden = function() return self.db.profile.numAwardReasons < i end,
		}
		options.args.mlSettings.args.awardsTab.args.awardReasons.args["DE"..i] = {
			order = i +1.3,
			name = _G.ROLL_DISENCHANT,
			desc = L["disenchant_desc"],
			type = "toggle",
			get = function() return self.db.profile.awardReasons[i].disenchant end,
			set = function(info, val)
				for k,v in ipairs(self.db.profile.awardReasons) do
					v.disenchant = false
				end
				self.db.profile.awardReasons[i].disenchant = val
				self.db.profile.disenchant = val
			end,
			hidden = function() return self.db.profile.numAwardReasons < i end,
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
				OFFICER = _G.CHAT_MSG_RAID_WARNING,
				RAID = _G.CHAT_MSG_RAID,
				RAID_WARNING = _G.CHAT_MSG_RAID_WARNING,
				group = _G.GROUP,
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
	-- Tier Buttons/responses
	for k, v in pairs(self.db.profile.responses.tier) do
		options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["button"..k] = {
			order = v.sort * 3 + 1,
			name = L["Button"].." "..v.sort,
			desc = format(L["Set the text on button 'number'"], v.sort),
			type = "input",
			get = function() return self.db.profile.tierButtons[v.sort].text end,
			set = function(info, value) addon:ConfigTableChanged("tierButtons"); self.db.profile.tierButtons[v.sort].text = tostring(value) end,
			hidden = function() return not self.db.profile.tierButtonsEnabled or self.db.profile.tierNumButtons < v.sort end,
		}
		options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["color"..k] = {
			order = v.sort * 3 + 2,
			name = L["Response color"],
			desc = L["response_color_desc"],
			type = "color",
			get = function() return unpack(v.color)	end,
			set = function(info,r,g,b,a) addon:ConfigTableChanged("responses"); v.color = {roundColors(r,g,b,a)} end,
			hidden = function() return not self.db.profile.tierButtonsEnabled or self.db.profile.tierNumButtons < v.sort end,
		}
		options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["text"..k] = {
			order = v.sort * 3 + 3,
			name = L["Response"],
			desc = format(L["Set the text for button i's response."], v.sort),
			type = "input",
			get = function() return v.text end,
			set = function(info, value) addon:ConfigTableChanged("responses"); v.text = tostring(value) end,
			hidden = function() return not self.db.profile.tierButtonsEnabled or self.db.profile.tierNumButtons < v.sort end,
		}
	end
	-- Relic Buttons/Responses
	for k, v in pairs(self.db.profile.responses.relic) do
		options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["button"..k] = {
			order = v.sort * 3 + 1,
			name = L["Button"].." "..v.sort,
			desc = format(L["Set the text on button 'number'"], v.sort),
			type = "input",
			get = function() return self.db.profile.relicButtons[v.sort].text end,
			set = function(info, value) addon:ConfigTableChanged("relicButtons"); self.db.profile.relicButtons[v.sort].text = tostring(value) end,
			hidden = function() return not self.db.profile.relicButtonsEnabled or self.db.profile.relicNumButtons < v.sort end,
		}
		options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["color"..k] = {
			order = v.sort * 3 + 2,
			name = L["Response color"],
			desc = L["response_color_desc"],
			type = "color",
			get = function() return unpack(v.color)	end,
			set = function(info,r,g,b,a) addon:ConfigTableChanged("responses"); v.color = {roundColors(r,g,b,a)} end,
			hidden = function() return not self.db.profile.relicButtonsEnabled or self.db.profile.relicNumButtons < v.sort end,
		}
		options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["text"..k] = {
			order = v.sort * 3 + 3,
			name = L["Response"],
			desc = format(L["Set the text for button i's response."], v.sort),
			type = "input",
			get = function() return v.text end,
			set = function(info, value) addon:ConfigTableChanged("responses"); v.text = tostring(value) end,
			hidden = function() return not self.db.profile.relicButtonsEnabled or self.db.profile.relicNumButtons < v.sort end,
		}
	end
	-- #endregion
	return options
end

function RCLootCouncil:DBGet(info)
	return self.db.profile[info[#info]]
end

function RCLootCouncil:DBSet(info, val)
	self.db.profile[info[#info]] = val
	self:ConfigTableChanged(info[#info])
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
							local name, rank1, rankIndex = GetGuildRosterInfo(ci); -- NOTE I assume the realm part of name is without spaces.
							if (rankIndex + 1) == i then names[name] = Ambiguate(name, "short") end -- Ambiguate to show realmname for players from another realm
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
							for k,v in ipairs(self.db.profile.council) do
								if v == key then
									tremove(self.db.profile.council, k)
								end
							end
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
