-- Author      : Potdisc
-- Create Date : 5/24/2012 6:24:55 PM
-- options.lua - option frame in BlizOptions for RCLootCouncil

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
------ Options ------
function addon:OptionsTable()
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
				name = L["General"],
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
						name = L["General"],
						childGroups = "tab",
						args = {
							usage = {
								order = 1,
								name = L["Usage"],
								desc = L["Choose when to use RCLootCouncil"],
								type = "select",
								width = "double",
								values = {
									ml 			= L["Always use RCLootCouncil when I'm Master Looter"],
								--	leader 		= "Always use RCLootCouncil when I'm the group leader and enter a raid",
									ask_ml		= L["Ask me every time I become Master Looter"],
								--	ask_leader	= "Ask me every time I'm the group leader and enter a raid",
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
							leaderUsage = { -- Add leader options here since we can only make a single select dropdown
								order = 2,
								name = function() return self.db.profile.usage.ml and L["Always use when leader"] or L["Ask me when leader"] end,
								desc = L["Use the same setting when entering a raid as the group leader?"],
								type = "toggle",
								get = function() return self.db.profile.usage.leader or self.db.profile.usage.ask_leader end,
								set = function(_, val)
									self.db.profile.usage.leader, self.db.profile.usage.ask_leader = false, false -- Reset for zzzzz
									if self.db.profile.usage.ml then self.db.profile.usage.leader = val end
									if self.db.profile.usage.ask_ml then self.db.profile.usage.ask_leader = val end
								end,
								disabled = function() return self.db.profile.usage.never end,
							},
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
									minimizeInCombat = {
										order = 3,
										name = L["Minimize in combat"],
										desc = L["Check to have all frames minimize when entering combat"],
										type = "toggle",
									},
									ambiguate = {
										order = 4,
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
								},
							},
							autoPassOptions = {
								order = 4,
								type = "group",
								name = L["Auto Pass"],
								inline = true,
								args = {
									autoPass = {
										order = 1,
										name = L["Auto Pass"],
										desc = L["auto_pass_desc"],
										type = "toggle",
									},
									silentAutoPass = {
										order = 2,
										name = L["Silent Auto Pass"],
										desc = L["silent_auto_pass_desc"],
										type = "toggle",
									},
									autoPassBoE = {
										order = 3,
										name = L["Auto pass BoE"],
										desc = L["auto_pass_boe_desc"],
										type = "toggle",
									},
								},
							},
							lootHistoryOptions = {
								order = 5,
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
										order = -1,
										name = L["Clear Loot History"],
										desc = L["clear_loot_history_desc"],
										type = "execute",
										func = function() self.lootDB:ResetDB("") end,
										confirm = true,
									},
								},
							},
						},
					},
				},
				plugins = {
					default = {

					}
				}
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
						name = L["General"],
						args = {
							lootingOptions = {
								order = 1,
								name = L["Looting options"],
								type = "group",
								inline = true,
								args = {
									autoStart = {
										order = 2,
										name = L["Auto Start"],
										desc = L["auto_start_desc"],
										type = "toggle",
									},
									altClickLooting = {
										order = 3,
										name = L["Alt click Looting"],
										desc = L["alt_click_looting_desc"],
										type = "toggle",
									},
									spacer = {
										order = 4,
										type = "header",
										name = "",
									},
									autoLoot = {
										order = 5,
										name = L["Auto Loot"],
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
								},
							},
							voteOptions = {
								order = 2,
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
								},
							},
							ignoreOptions = {
								order = 3,
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
										pattern = "%d",
										usage = L["ignore_input_usage"],
										get = function() return "\"itemID\"" end,
										set = function(info, val) tinsert(self.db.profile.ignore, val); LibStub("AceConfigRegistry-3.0"):NotifyChange("RCLootCouncil") end,
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
											for i = 1, #self.db.profile.ignore do
												local link = select(2, GetItemInfo(self.db.profile.ignore[i]))
												t[i] = link or L["Not cached, please reopen."]
											end
											return t
										end,
										get = function() return L["Ignore List"] end,
										set = function(info, val) tremove(self.db.profile.ignore, val) end,
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
										name = L["Reset to default"],
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
										name = L["announce_awards_desc2"],
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
										name = L["Channel"],
										desc = L["channel_desc"],
										type = "select",
										style = "dropdown",
										values = {
											SAY = L["Say"],
											YELL = L["Yell"],
											PARTY = L["Party"],
											GUILD = L["Guild"],
											OFFICER = L["Officer"],
											RAID = L["Raid"],
											RAID_WARNING = L["Raid Warning"],
											group = L["Group"], -- must be converted
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
								},
							},
							reset = {
								order = -1,
								name = L["Reset to default"],
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
							responseFromChat = {
								order = 2,
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
								name = L["Reset to default"],
								desc = L["reset_buttons_to_default_desc"],
								type = "execute",
								confirm = true,
								func = function()
									self.db.profile.buttons = self.defaults.profile.buttons
									self.db.profile.responses = self.defaults.profile.responses
									self.db.profile.numButtons = self.defaults.profile.numButtons
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
			set = function(info,r,g,b,a) addon:ConfigTableChanged("responses"); self.db.profile.responses[i].color = {r,g,b,a} end,
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
			set = function(info, r,g,b,a) self.db.profile.awardReasons[i].color = {r,g,b,a} end,
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
			name = L["Disenchant"],
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
			name = L["Channel"]..i..":",
			desc = L["channel_desc"],
			type = "select",
			style = "dropdown",
			values = {
				NONE = L["None"],
				SAY = L["Say"],
				YELL = L["Yell"],
				PARTY = L["Party"],
				GUILD = L["Guild"],
				OFFICER = L["Officer"],
				RAID = L["Raid"],
				RAID_WARNING = L["Raid Warning"],
				group = L["Group"],
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
					end,
				},
			},
		}

		-- Add it to the guildMembersGroup arguments:
		self.options.args.mlSettings.args.councilTab.args.addCouncil.args[i..""..rank] = option
	end
end
