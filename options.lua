-- Author      : Potdisc
-- Create Date : 5/24/2012 6:24:55 PM
-- options.lua - option frame in BlizOptions for RCLootCouncil
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")

------ Options ------
function addon:OptionsTable()
	local db = addon.db.profile
	local options = { 
		name = "RCLootCouncil",
		type = "group",
		childGroups = "tab",
		args = {
			toggle = {
				order = 1,
				name = "Toggle usage",
				desc = "Check to manually toggle usage on/off - needed in case you change your mind after entering a raid.\nWon't do anything unless you're the Master Looter.",
				type = "toggle",
				set = function() RCLootCouncil.isRunning() end,
				get = function() return RCLootCouncil:GetVariable("isRunning") end
			},
			toggleAdvanced = {
				order = 2,
				name = "Toggle Advanced Options",
				desc = "Check to show advanced options such as changing loot buttons/responses, toggle different looting, announcement options and voting types.",
				type = "toggle",
				width = "double",
				get = function() return self.db.profile.advancedOptions end,
				set = function() self.db.profile.advancedOptions = not self.db.profile.advancedOptions; end,
			},
			generalSettingsTab = {
				order = 1,
				type = "group",
				name = "General Settings",
				args = {
					addonDesc = {
						order = 1,
						name = "Note: The options in here only does something if you're the Master Looter in your raid.\nOnly one option is configureable as a non-MasterLooter, which is the \"Track Awards\" option found (with \"Advanced Options\" enabled) in the \"Loot History\"-tab.\n",
						type = "description",
						hidden = function() return self.db.profile.advancedOptions; end,
					},
					testOptions = {
						order = 2,
						name = "Test Options",
						type = "group",
						inline = true,
						args = {
							testDesc = {
								order = 1,
								name = "Solo Test will only display frames as setup by youself locally, and with one item. Raid Test will display your configuration to everyone in your raid and allow voting for anyone configured as being a council member by you. In a real raid situation, the Master Looter's configuration is always used.\nTo Raid Test with more or less than 5 items, use \"/rc test #\".\n",
								type = "description"	
							},
							testButton = {
								order = 2,
								name = "Solo test",
								desc = "Click to emulate master looter looting an item for yourself only (not possible in a raid)",
								type = "execute",
								func = function()
									InterfaceOptionsFrame:Hide(); -- close all option frames before testing
									RCLootCouncil_Mainframe.testFrames()
								end			
							},
							testRaidButton = {
								order = 3,
								name = "Raid Test",
								desc = "Click to emulate master looter looting 5 items (requires you to be in an raid and be the master looter or group leader/assistant",
								type = "execute",
								func = function()
									if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
										RCLootCouncil_Mainframe.raidTestFrames(5)
										InterfaceOptionsFrame:Hide();
									else
										addon:Print("Cannot start raid test when you're not in a raid or the raid leader/assistant.")
									end
								end
							},
							versionTest = {
								name = "Version Check",
								desc = "Click to check for updates and see who has the addon installed",
								type = "execute",
								order = 4,
								func = function()
									RCLootCouncil:EnableModule("RCLootCouncil_VersionFrame");
									InterfaceOptionsFrame:Hide();
								end
							},
						},
					},
					voteOptions = {
						order = 3,
						name = "Voting options\n",
						type = "group",
						inline = true,
						args = {
							selfVoteToggle = {
								order = 1,
								name = "Vote for self",
								desc = "Check to enable councilmembers ability to vote for themselves.",
								type = "toggle",
								get = function() return self.db.profile.dbToSend.selfVote end,
								set = function() self.db.profile.dbToSend.selfVote = not self.db.profile.dbToSend.selfVote end,
							},
							multiVoteToggle = {
								order = 2,
								name = "Multi Vote",
								desc = "Check to enable multi voting, i.e. more than 1 vote per player.",
								type = "toggle",
								get = function() return self.db.profile.dbToSend.multiVote end,
								set = function() self.db.profile.dbToSend.multiVote = not self.db.profile.dbToSend.multiVote; end,
							},
							allowNotes = {
								order = 3,
								name = "Allow Notes",
								desc = "Check to allow raiders to send a note to the council along with their roll.",
								type = "toggle",
								get = function() return self.db.profile.dbToSend.allowNotes end,
								set = function() self.db.profile.dbToSend.allowNotes = not self.db.profile.dbToSend.allowNotes end, 
							},
							anonymousVotingToggle = {
								order = 4,
								name = "Anonymous Voting",
								desc = "Check to enable Anonymous Voting, i.e. NOT seeing who is voting for whom.",
								type = "toggle",
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.dbToSend.anonymousVoting end,
								set = function()
									self.db.profile.dbToSend.anonymousVoting = not self.db.profile.dbToSend.anonymousVoting;
									if not self.db.profile.dbToSend.anonymousVoting then 
										self.db.profile.dbToSend.masterLooterOnly = false
									end 
								end,
							},
							--autoPassVoteToggle = {
                            --    order = 5,
                            --    name = "AutoPass unusable",
                            --    desc = "Check to enable automatic passing of unusable gear.",
                            --    type = "toggle",
                            --    get = function() return self.db.profile.dbToSend.autoPass end,
                            --    set = function() self.db.profile.dbToSend.autoPass = not self.db.profile.dbToSend.autoPass; end,
                            --},
							masterLooterOnly = {
								order = 6,
								name = "Show for the ML only",
								desc = "Check to allow the Masterlooter only too see who's voting for whom.",
								type = "toggle",
								disabled = function() return not self.db.profile.dbToSend.anonymousVoting; end,
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.dbToSend.masterLooterOnly end,
								set = function() self.db.profile.dbToSend.masterLooterOnly = not self.db.profile.dbToSend.masterLooterOnly end,
							},
						},
					},
					lootDesc = {
						order = 4,
						name = "Looting options",
						type = "group",
						inline = true,
						args = {
							autoLooting = {
								order = 1,
								name = "Auto Looting",
								desc = "Check to enable Auto Looting, i.e. the addon automatically starts looting whenever it can.",
								type = "toggle";
								get = function() return self.db.profile.autoLooting end,
								set = function() self.db.profile.autoLooting = not self.db.profile.autoLooting; end,
							},
							lootEverything = {
								order = 2,
								name = "Loot Everything",
								desc = "Check to enable looting of non-items (e.g. mounts, tier-tokens)",
								type = "toggle",
								disabled = function() return not self.db.profile.autoLooting; end,
								get = function() return self.db.profile.lootEverything end,
								set = function() self.db.profile.lootEverything = not self.db.profile.lootEverything; end,
							},
							boeLoot = {
								order = 3,
								name = "Autoloot BoE",
								desc = "Check to enable autolooting of BoE (Bind on Equip) items.\ni.e. the addon automatically starts looting BoE items.",
								type = "toggle",
								disabled = function() return not self.db.profile.autoLooting; end,
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.autolootBoE; end,
								set = function() self.db.profile.autolootBoE = not self.db.profile.autolootBoE; end,
							},
							altClickLooting = {
								order = 4,
								name = "Alt click looting",
								desc = "Check to enable alt click looting, i.e. start a looting session by holding down alt and (left)clicking an item.",
								type = "toggle",
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.altClickLooting end,
								set = function() self.db.profile.altClickLooting = not self.db.profile.altClickLooting; end,
							},
						},
					},
					autoAward = {
						order = 5,
						name = "Auto Award",
						type = "group",
						hidden = function() return not self.db.profile.advancedOptions; end,
						inline = true,
						args = {
							autoAward = {
								order = 1,
								name = "Auto Award",
								desc = "Check to enable Auto Awarding.",
								type = "toggle",
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.autoAward; end,
								set = function() self.db.profile.autoAward = not self.db.profile.autoAward; end,
							},
							autoAwardQualityLower = {
								order = 1.1,
								name = "Lower Quality Limit",
								desc = "Select the lower quality limit of items to auto award (this quality included!).\nNote: This overrides the normal loot treshhold.",
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
								hidden = function() return not self.db.profile.advancedOptions; end,
								disabled = function() return not self.db.profile.autoAward; end,
								get = function() return self.db.profile.autoAwardQualityLower; end,
								set = function(i,v) self.db.profile.autoAwardQualityLower = v; end,
							},
							autoAwardQualityUpper = {
								order = 1.2,
								name = "Upper Quality Limit",
								desc = "Select the upper quality limit of items to auto award (this quality included!).\nNote: This overrides the normal loot treshhold.",
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
								hidden = function() return not self.db.profile.advancedOptions; end,
								disabled = function() return not self.db.profile.autoAward; end,
								get = function() return self.db.profile.autoAwardQualityUpper; end,
								set = function(i,v) self.db.profile.autoAwardQualityUpper = v; end,
							},
							autoAwardTo = {
								order = 2,
								name = "Auto Award to",
								desc = "Enter the name of the person to Auto Award items to.",
								width = "double",
								type = "input",
								disabled = function() return not self.db.profile.autoAward; end,
								hidden = function() return not self.db.profile.advancedOptions or IsInRaid(); end,
								get = function() return self.db.profile.autoAwardTo; end,
								set = function(i,v) self.db.profile.autoAwardTo = v; end,
							},
							autoAwardTo2 = {
								order = 2,
								name = "Auto Award to",
								desc = "Select the name of the person to Auto Award items to.",
								width = "double",
								type = "select",
								style = "dropdown",
								values = function()
									local t = {}
									if IsInRaid() then
										for i = 1, GetNumGroupMembers() do
											local name = GetRaidRosterInfo(i)
											t[i] = name
										end
									else
										t[1] = UnitName("player");
									end
									return t;
								end,
								disabled = function() return not self.db.profile.autoAward; end,
								hidden = function() return not self.db.profile.advancedOptions or not IsInRaid(); end,
								get = function() return self.db.profile.autoAwardTo; end,
								set = function(i,v) self.db.profile.autoAwardTo = v; end,
							},
							autoAwardReason = {
								order = 2.1,
								name = "Reason",
								desc = "Select the reason to add to the Loot History when auto awarding.",
								type = "select",
								style = "dropdown",
								values = function()
									local t = {}
									for i = 1, #self.db.profile.otherAwardReasons do
										t[i] = self.db.profile.otherAwardReasons[i].text
									end
									return t
								end,
								disabled = function() return not self.db.profile.autoAward; end,
								hidden = function() return not self.db.profile.advancedOptions; end,
								get = function() return self.db.profile.autoAwardReason; end,
								set = function(i,v) self.db.profile.autoAwardReason = v; end,
							},
						},
					},
				},
			},
			announcementTab = {
				order = 2,
				type = "group",
				name = "Announcement Options",
				hidden = function() return not self.db.profile.advancedOptions; end,
				args = {
					AwardAnnouncement = {
						order = 1,
						name = "Award Announcement",
						type = "group",
						inline = true,
						args = {
							toggle = {
								order = 1,
								name = "Announce Awards",
								desc = "Toggle to turn Award Announcement on/off.",
								type = "toggle",
								width = "full",
								get = function() return self.db.profile.awardAnnouncement end,
								set = function() self.db.profile.awardAnnouncement = not self.db.profile.awardAnnouncement; end,
							},
							outputDesc = {
								order = 2,
								name = "\nChoose wether to announce whom an item is awarded to, which message you want to announce to which channel when awarding loot, or none to toggle announcement off. You can announce in 2 channels at once.\nUse &p for the name of the player getting the loot and &i for the item awarded.",
								type = "description",
							},
							outputMessage = {
								order = 3,
								name = "Award message 1",
								desc = "The message to be displayed when awarding an item.",
								type = "input",
								width = "double",
								get = function() return self.db.profile.awardMessageText1 end,
								set = function(i,v) self.db.profile.awardMessageText1 = v; end,
								hidden = function() return not self.db.profile.awardAnnouncement; end,
							},
							outputSelect = {
								order = 3.1,
								name = "",
								desc = "Select which channel to announce rewards in or none to toggle announcing off.",
								type = "select",
								style = "dropdown",
								values = {
									NONE = "None",
									SAY = "Say",
									YELL = "Yell",
									PARTY = "Party",
									GUILD = "Guild",
									OFFICER = "Officer",
									RAID = "Raid",
									RAID_WARNING = "Raid Warning"
								},
								set = function(i,v) self.db.profile.awardMessageChat1 = v end,
								get = function() return self.db.profile.awardMessageChat1 end,
								hidden = function() return not self.db.profile.awardAnnouncement; end,
							},
							outputMessage2 = {
								order = 4,
								name = "Award message 2",
								desc = "The message to be displayed when awarding an item.",
								type = "input",
								width = "double",
								get = function() return self.db.profile.awardMessageText2 end,
								set = function(i,v) self.db.profile.awardMessageText2 = v; end,
								hidden = function() return not self.db.profile.awardAnnouncement; end,
							},
							outputSelect2 = {
								order = 4.1,
								name = "",
								desc = "Select which channel to announce rewards in or none to toggle announcing off.",
								type = "select",
								style = "dropdown",
								values = {
									NONE = "None",
									SAY = "Say",
									YELL = "Yell",
									PARTY = "Party",
									GUILD = "Guild",
									OFFICER = "Officer",
									RAID = "Raid",
									RAID_WARNING = "Raid Warning"
								},
								set = function(i,v) self.db.profile.awardMessageChat2 = v end,
								get = function() return self.db.profile.awardMessageChat2 end,
								hidden = function() return not self.db.profile.awardAnnouncement; end,
							},
						},
					},				
					
					considerationAnnouncement = {
						order = 2,
						name = "Consideration Announcement",
						type = "group",
						inline = true,
						args = {
							announceConsideration = {
								order = 1,
								name = "Announce Consideration",
								desc = "Check to enable the announcement of items under consideration.",
								type = "toggle",
								width = "full",
								get = function() return self.db.profile.announceConsideration; end,
								set = function() self.db.profile.announceConsideration = not self.db.profile.announceConsideration; end,
							},
							desc = {
								order = 2,
								type = "description",
								name = "\nChoose wether you want to announce every time an item is under consideration, which channel to announce in, and which message to announce.\nUse &i to display the item under consideration.",
							},							
							announceText = {
								order = 3,
								name = "Announce consideration message",
								desc = "The message to be displayed when an item is under consideration.",
								type = "input",
								width = "double",
								get = function() return self.db.profile.announceText end,
								set = function(i,v) self.db.profile.announceText = v; end,
								hidden = function() return not self.db.profile.announceConsideration; end,
							},
							announceChannel = {
								order = 3.1,
								name = "",
								desc = "The channel to send the message to.",
								type = "select",
								style = "dropdown",
								values = {
									SAY = "Say",
									YELL = "Yell",
									PARTY = "Party",
									GUILD = "Guild",
									OFFICER = "Officer",
									RAID = "Raid",
									RAID_WARNING = "Raid Warning"
								},
								set = function(i,v) self.db.profile.announceChannel = v end,
								get = function() return self.db.profile.announceChannel end,
								hidden = function() return not self.db.profile.announceConsideration; end,
							},
						},
					},
					reset = {
						order = -1,
						name = "Reset to default",
						desc = "Resets all the announcement options to default",
						type = "execute",
						confirm = true,
						func = function() addon:announceToDefault() end
					},
				},
			},
			buttonsOptionsTab = {
				order = 3,
				type = "group",
				name = "Buttons, Responses and Whispers",
				hidden = function() return not self.db.profile.advancedOptions; end,
				args = {
					buttonOptions = {
						order = 1,
						type = "group",
						name = "Buttons and Responses",
						inline = true,
						args = {
							optionsDesc = {
								order = 0,
								name = "Configure the reply buttons on the raiders' loot frame as well as the corresponding response and color to be showed on the council frame.\nThe lowest number button is showed furthest to the left and the highest furthes to the right - use the slider to choose how many buttons you want (max "..self.db.profile.dbToSend.maxButtons..").\n\nThe first button is always activated and will count as MainSpec in the loot history.\nYou must specify a new \"Pass\" button if you change it.",
								type = "description"
							},
							buttonsRange = {
								order = 1,
								name = "Number of buttons",
								desc = "Slide to toggle the number of buttons to display on the loot frame.",
								type = "range",
								width = "full",
								min = 1,
								max = self.db.profile.dbToSend.maxButtons,
								step = 1,
								get = function() return self.db.profile.dbToSend.numButtons; end,
								set = function(i,v) self.db.profile.dbToSend.numButtons = v; end,
							},
							passButton = {
								order = -1,
								name = "Pass button",
								desc = "Select your pass button here in order to be able to filter out passes when running a council.",
								type = "select",
								style = "dropdown",
								width = "double",
								values = function()
									local t = {}
									t[(self.db.profile.dbToSend.maxButtons + 1)] = "None";
									for i = 1, self.db.profile.dbToSend.maxButtons do
										if i <= self.db.profile.dbToSend.numButtons then t[i] = "Button "..i; else break; end
									end	
									return t;
								end,
								set = function(i,v) self.db.profile.dbToSend.passButton = v end,
								get = function() return self.db.profile.dbToSend.passButton end,
							},
						},
					},
					whisperOptions = {
						order = 2,
						type = "group",
						name = "Whisper Options",
						inline = true,
						args = {							
							acceptWhispers = {
								order = 1,
								name = "Accept whispers",
								desc = "Check to allow players without the addon to whisper their current item(s) to you to get added to the consideration list.",
								type = "toggle",
								get = function() return self.db.profile.acceptWhispers end,
								set = function() self.db.profile.acceptWhispers = not self.db.profile.acceptWhispers end,
							},
							acceptRaidChat = {
								order = 1.1,
								name = "Accept Raid Chat",
								desc = "Check to allow players without the addon to post their current item(s) in raid chat and thus get added to the consideration list.",
								type = "toggle",
								get = function() return self.db.profile.acceptRaidChat end,
								set = function() self.db.profile.acceptRaidChat = not self.db.profile.acceptRaidChat; end,
							},
							desc = {
								order = 2,
								name = "To get added to the consideration list, without having the addon installed, raiders can link their item(s) followed by a keyword to the Master Looter (Button 1 is used if no keyword is specified).\nExample: \"/w ML_NAME [ITEM] greed\" would by default show up as you greeding on an item.\nBelow you can choose keywords for the individual buttons, seperated by punctation or spaces. Only numbers and words are accepted.\nPlayers can recieve the keyword list by messaging 'rchelp' to the Master Looter once the addon is enabled (i.e. in a raid).",
								type = "description",
							},
						},
					},
					reset = {
						order = -1,
						name = "Reset to default",
						desc = "Resets all the buttons, colors and responses to default",
						type = "execute",
						confirm = true,
						func = function() addon:buttonsToDefault() end
					},
				},
			},
			lootHistoryTab = {
				order = 4,
				type = "group",
				name = "Loot History options",
				hidden = function() return not self.db.profile.advancedOptions; end,
				args = {
					lootHistoryOptions = {
						order = 1,
						type = "group",
						name = "Loot History",
						inline = true,
						args = {
							desc1 = {
								order = 1,
								name = "The Loot History is still a work in progress - for now it logs all data and displays them in a simple view. This will get more refined as i get more time.\n",
								type = "description",
							},
							trackLooting = {
								order = 2,
								name = "Track Awards",
								desc = "Check to enable tracking of awards, i.e. log all awards for a later presentation. Only works for non-MasterLooters if the Master Looter have turned on \"Send Awards\".",
								type = "toggle",
								get = function() return self.db.profile.trackAwards; end,
								set = function() self.db.profile.trackAwards = not self.db.profile.trackAwards; end,
							},
							sendHistory = {
								order = 3,
								name = "Send Awards",
								desc = "Check to send all award logs to everyone in the raid, regardless if you don't log it yourself. Anyone in the raid with \"Track Awards\" on will get the same info as you would if you had it on.",
								type = "toggle",
								width = "full",
								get = function() return self.db.profile.sendHistory; end,
								set = function() self.db.profile.sendHistory = not self.db.profile.sendHistory; end,
							},
							openLootDB = {
								order = 4,
								name = "Open the Loot History",
								desc = "Click to open the RCLootCouncil Loot History.",
								type = "execute",
								func = function() RCLootCouncil:EnableModule("RCLootHistory");	InterfaceOptionsFrame:Hide();end,
							},
							clearLootDB = {
								order = 90,
								name = "Clear Loot History",
								desc = "Delete the entire loot history.",
								type = "execute",
								func = function() self.db.factionrealm.lootDB = {} end,
								confirm = true,
							},
						},
					},
					awardOptions = {
						order = 2,
						type = "group",
						name = "Other History Entries",
						inline = true,
						args = {
							desc = {
								order = 0,
								name = "Other reasons for awarding items other than the usual rolls.\nUsed in the right click menu.\n",
								type = "description",
							},
							range = {
								order = 1,
								name = "Number of reasons",
								desc = "Slide to toggle the number of reasons to use in the rightclick menu.",
								type = "range",
								width = "full",
								min = 1,
								max = 8,
								step = 1,
								get = function() return #self.db.profile.otherAwardReasons; end,
								set = function(i,v)
									if v < #self.db.profile.otherAwardReasons then
										tremove(self.db.profile.otherAwardReasons)
									elseif v > #self.db.profile.otherAwardReasons then
										tinsert(self.db.profile.otherAwardReasons, { text = "", log = true,})
									end
								end,
							},
							reset = {
								order = -1,
								name = "Reset to default",
								desc = "Resets the award reasons to default.",
								type = "execute",
								confirm = true,
								func = function() addon:otherAwardReasonsToDefault() end, 
							},
						},
					},
				},
			},
			council = {
				order = 5,
				type = "group",
				name = "Council",
				childGroups = "tab",
				args = {
					currentCouncil = {
						order = 1,
						type = "group",
						name = "Current Council",
						args = {
							currentCouncilDesc = {
								order = 1,
								name = "\nClick to remove certain people from the council\n",
								type = "description",
							},
							councilList = {
								order = 2,
								type = "multiselect",
								name = "",
								values = function()
									local t = {}
									for k,v in ipairs(self.db.profile.council) do t[k] = ""..v end
									return t;
								end,
								width = "full",
								get = function() return true end,
								set = function(m,key) tremove(self.db.profile.council,key) end,
							},							
							removeAll = {
								order = 3,
								name = "Remove All",
								desc = "Remove all council members",
								type = "execute",
								confirm = true,
								func = function() self.db.profile.council = {} end,							
							},
						},
					},
					addCouncil = {
						order = 2,
						type = "group",
						name = "Guild Council Members",
						childGroups = "tree",
						args = {
							addRank = {
								order = 1,
								name = "Add ranks",
								type = "group",
								args = {
									header1 = {
										order = 1,
										name = "Choose minimum rank to participate in lootcouncil:",
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
										set = function(j,i) self.db.profile.council = {}; RCLootCouncil_Mainframe.setRank(i); end,
										get = function() return self.db.profile.minRank; end,
									},
									desc = {
										order = 3,
										name = "\n\nSelect a rank above to add all members at and above that rank to the council.\n\nClick on the ranks to the left to add individual players to the council.\n\nClick the 'Current Council' tab to see your selection.",
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
						},
					},
					addRaidCouncil = {
						order = 3,
						type = "group",
						name = "Raid Council Members",
						hidden = not IsInRaid(), -- don't show if we're not in a raid
						args = {
							header1 = {
								order = 1,
								name = "Add council members from your current raid.",
								type = "header",
								width = "full",
							},
							desc = {
								order = 2,
								name = "Use this to add council members from another realm.",
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
										-- Ambiguate to distinguish people from own realm, not sure if it's smart at the end of the day though
										tinsert(Ambiguate(select(1,GetRaidRosterInfo(i)), "none"))	-- might need a tostring()		
									end
									table.sort(t, function(v1, v2)
									 return v1 and v1 < v2
									end)
									return t 
								end,
								set = function(info,key,tag)
									-- probably could've used info[#info-1].values() instead
									local values = addon.options.args.council.args.addRaidCouncil.args.list.values()
									if tag then -- add
										tinsert(self.db.profile.council, values[key])
									else -- remove
										for k,v in ipairs(self.db.profile.council) do
											if v == values[key] then
												tremove(self.db.profile.council, k)
											end
										end
									end
								end,
								get = function(info, key)
									local values = addon.options.args.council.args.addRaidCouncil.args.list.values()
									if tContains(self.db.profile.council, values[key]) then return true end
									return false
								end,
							}
						},
					},
				},
			},
		},
	}
	
	-- make the buttons config
	local button, picker, text = {}, {}, {}
	for i = 1, self.db.profile.dbToSend.maxButtons do	
		button = {
			order = i * 3 + 1,
			name = "Button "..i,
			desc = "Set the text on button "..i..".",
			type = "input",
			get = function() return self.db.profile.dbToSend.buttons[i]["text"] end,
			set = function(info, value)	self.db.profile.dbToSend.buttons[i]["text"] = tostring(value) end,
			hidden = function() if self.db.profile.dbToSend.numButtons < i then return true; else return false; end end
		}
		options.args.buttonsOptionsTab.args.buttonOptions.args["button"..i] = button;
		picker = {
			order = i * 3 + 1,
			name = "Response color",
			desc = "Set a text color for the response",
			type = "color",
			get = function()
				local r = self.db.profile.dbToSend.buttons[i]["color"][1]
				local g = self.db.profile.dbToSend.buttons[i]["color"][2]
				local b = self.db.profile.dbToSend.buttons[i]["color"][3]
				return r,g,b
			end,
			set = function(info,r,g,b)
				local color = {r,g,b,1}
				self.db.profile.dbToSend.buttons[i]["color"] = color
			end,
			hidden = function() if self.db.profile.dbToSend.numButtons < i then return true; else return false; end end,
		}
		options.args.buttonsOptionsTab.args.buttonOptions.args["picker"..i] = picker;
		text = {	
			order = i * 3 + 3,
			name = "Response",
			desc = "Set the text for button "..i.."'s response.",
			type = "input",
			get = function() return self.db.profile.dbToSend.buttons[i]["response"] end,
			set = function(info, value) self.db.profile.dbToSend.buttons[i]["response"] = tostring(value) end,
			hidden = function() if self.db.profile.dbToSend.numButtons < i then return true; else return false; end end,		
		}
		options.args.buttonsOptionsTab.args.buttonOptions.args["text"..i] = text;
		local whisperKeys = {
			order = i + 3,
			name = "Button"..i,
			desc = "Set the whisper keys for button "..i..".",
			type = "input",
			width = "double",
			get = function() return self.db.profile.dbToSend.buttons[i]["whisperKey"] end,
			set = function(k,v) self.db.profile.dbToSend.buttons[i]["whisperKey"] = v end,
			hidden = function() if self.db.profile.dbToSend.numButtons < i or not self.db.profile.acceptWhispers then return true; else return false; end end,
		}
		options.args.buttonsOptionsTab.args.whisperOptions.args["whisperKey"..i] = whisperKeys;
	end
	for i = 1, 8 do
		options.args.lootHistoryTab.args.awardOptions.args["reason"..i] = {
			order = i * 2 +1,
			name = "Reason "..i,
			desc = "Enter the reason #"..i,
			type = "input",
			width = "double",
			get = function() return self.db.profile.otherAwardReasons[i].text end,
			set = function(k,v) self.db.profile.otherAwardReasons[i].text = v; end,
			hidden = function() if #self.db.profile.otherAwardReasons < i then return true; else return false; end end,
		}
		
		options.args.lootHistoryTab.args.awardOptions.args["log"..i] = {
			order = i * 2 +2,
			name = "Log",
			desc = "Log in the Loot History?",
			type = "toggle",
			get = function() return self.db.profile.otherAwardReasons[i].log end,
			set = function() self.db.profile.otherAwardReasons[i].log = not self.db.profile.otherAwardReasons[i].log end,
			hidden = function() if #self.db.profile.otherAwardReasons < i then return true; else return false; end end,
		}
	end
	return options
end

function RCLootCouncil:GetGuildOptions()
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
							local name, rank1, rankIndex = GetGuildRosterInfo(ci);
							name = Ambiguate(name, "none")
							if (rankIndex + 1) == i then tinsert(names, name) end
						end
						table.sort(names, function(v1, v2)
							return v1 and v1 < v2
						end)
						return names
					end,
					get = function(info, number)
						local values = addon.options.args.council.args.addCouncil.args[info[#info-1]].args.ranks.values()
						for j = 1, #self.db.profile.council do
							if values[number] == self.db.profile.council[j] then return true end
						end
						return false
					end,
					set = function(info, number, tag)
						local values = addon.options.args.council.args.addCouncil.args[info[#info-1]].args.ranks.values()
						if tag then tinsert(self.db.profile.council, values[number])
						else
							for k,v in ipairs(self.db.profile.council) do
								if v == values[number] then
									tremove(self.db.profile.council, k)
								end
							end
						end
					end,
				},
			},
		}

		-- Add it to the guildMembersGroup arguments:
		self.options.args.council.args.addCouncil.args[i..""..rank] = option
	end
end
