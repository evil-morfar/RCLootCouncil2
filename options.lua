-- Author      : Potdisc
-- Create Date : 5/24/2012 6:24:55 PM
-- options.lua - option frame in BlizOptions for RCLootCouncil

-- TODO		Clarify "Responses from chat"
-- TODO		Add trees for "Everyone" and "ML" options
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
------ Options ------
function addon:OptionsTable()
	local db = addon:Getdb()
	local function hidden() return not db.advancedOptions end -- avoid making unnessecary functions
	local options = { 
		name = "RCLootCouncil",
		type = "group",
		childGroups = "tab",
		args = {
			version = {
				order = 1,
				type = "description",
				name = "v"..self.version,
			},
			generalSettingsTab = {
				order = 1,
				type = "group",
				name = "General",
				args = {							
					generalOptions = {
						order = 2,
						name = "General options",
						type = "group",
						inline = true,
						args = {
							toggle = {
								order = 1,
								name = "Activate",
								desc = "Uncheck to temporary disable RCLootCouncil. Useful if you're in a raid group, but not actually participating. Note: This resets on every logout.",
								type = "toggle",
								set = function() addon.disable = not addon.disable end,
								get = function() return not addon.disable end,
							},
							autoEnable = {
								order = 1.1,
								name = "Auto Activation",
								desc = "Check to auto activate the addon when entering a raid. Unchecking will make the addon ask if you want to use it.",
								type = "toggle",
								set = function() db.autoEnable = not db.autoEnable end,
								get = function() return db.autoEnable end,
								hidden = hidden,
							},
							autoOpen = {
								order = 1.2,
								name = "Auto Open",
								desc = "Check to Auto Open the voting frame when available. The voting frame can otherwise be opened with /rc open.",
								type = "toggle",
								set = function() db.autoOpen = not db.autoOpen end,
								get = function() return db.autoOpen end,
							},
							toggleAdvanced = {
								order = 1.3,
								name = "Toggle ML Options",
								desc = "Shows options that's only available to MasterLooters, such as changing loot buttons/responses, looting styles, announcements, voting types, etc.",
								type = "toggle",
								get = function() return db.advancedOptions end,
								set = function() db.advancedOptions = not db.advancedOptions; end,
							},
							header = {
								order = 2,
								type = "header",
								name = "",
							},
							testButton = {
								order = 3,
								name = "Test",
								desc = "Click to emulate master looting an item for yourself and anyone in your raid.",
								type = "execute",
								func = function()
									InterfaceOptionsFrame:Hide(); -- close all option frames before testing
									RCLootCouncil_Mainframe.testFrames()
								end			
							},
							versionTest = {
								name = "Version Check",
								desc = "Opens the version checker module.",
								type = "execute",
								order = 3.1	,
								func = function()
									--InterfaceOptionsFrame:Hide()
									LibStub("AceConfigDialog-3.0"):CloseAll()
									addon:CallModule("version")
								end
							},
						},
					},
					voteOptions = {
						order = 3,
						name = "Voting options",
						type = "group",
						inline = true,
						hidden = hidden,
						args = {
							selfVoteToggle = {
								order = 1,
								name = "Self Vote",
								desc = "Enables voters to vote for themselves.",
								type = "toggle",
								get = function() return db.selfVote end,
								set = function() db.selfVote = not db.selfVote end,
							},
							multiVoteToggle = {
								order = 2,
								name = "Multi Vote",
								desc = "Enables multi voting, i.e. multiple votes per voter.",
								type = "toggle",
								get = function() return db.multiVote end,
								set = function() db.multiVote = not db.multiVote; end,
							},
							allowNotes = {
								order = 3,
								name = "Notes",
								desc = "Enables raiders to send a note to the council along with their roll.",
								type = "toggle",
								get = function() return db.allowNotes end,
								set = function() db.allowNotes = not db.allowNotes end, 
							},
							anonymousVotingToggle = {
								order = 4,
								name = "Anonymous Voting",
								desc = "Activates Anonymous Voting, i.e. you cannot see whom voted for who.",
								type = "toggle",
								hidden = hidden,
								get = function() return db.anonymousVoting end,
								set = function() db.anonymousVoting = not db.anonymousVoting end,
							},
							masterLooterOnly = {
								order = 5,
								name = "ML sees voting",
								desc = "Allow only the Masterlooter too see who's voting for whom.",
								type = "toggle",
								disabled = function() return not db.anonymousVoting end,
								hidden = hidden,
								get = function() return db.showForML end,
								set = function() db.showForML = not db.showForML end,
							},
						},
					},
					lootDesc = {
						order = 4,
						name = "Looting options",
						type = "group",
						inline = true,
						hidden = hidden,
						args = {
							autoStart = {
								order = 1,
								name = "Auto Start",
								desc = "Activates Auto Start, i.e. the addon automatically starts looting whenever it can. If unchecked the addon only works by alt-clicking (see \"Alt click Looting\").",
								type = "toggle";
								get = function() return db.autoStart end,
								set = function() db.autoStart = not db.autoStart
									if not db.autoStart then db.altClickLooting = true end
								end,
							},
							autoLootEverything = {
								order = 2,
								name = "Loot Everything",
								desc = "Enables looting of non-items (e.g. mounts, tier-tokens)",
								type = "toggle",
								disabled = function() return not db.autoStart end,
								get = function() return db.autolootEverything end,
								set = function() db.autolootEverything = not db.autolootEverything end,
							},
							autoLootBoE = {
								order = 3,
								name = "Autoloot BoE",
								desc = "Enables autolooting of BoE (Bind on Equip) items.",
								type = "toggle",
								disabled = function() return not db.autoStart end,
								hidden = hidden,
								get = function() return db.autolootBoE; end,
								set = function() db.autolootBoE = not db.autolootBoE; end,
							},
							altClickLooting = {
								order = 4,
								name = "Alt click Looting",
								desc = "Enables Alt click Looting, i.e. start a looting session by holding down alt and (left)clicking an item.",
								type = "toggle",
								hidden = hidden,
								get = function() return db.altClickLooting end,
								set = function() db.altClickLooting = not db.altClickLooting; end,
							},
						},
					},
					lootHistoryOptions = {
						order = 5,
						type = "group",
						name = "Loot History",
						inline = true,
						args = {
							desc1 = {
								order = 1,
								name = "RCLootCouncil automatically records relevant information from sessions.\nThe raw data is stored in \".../SavedVariables/RCLootCouncilLootDB.lua\".\n\nNote: Non-MasterLooters can only store data sent from the MasterLooter.\n",
								type = "description",
							},
							trackLooting = {
								order = 2,
								name = "Enable Loot History",
								desc = "Enables the history. RCLootCouncil won't log anything if disabled.",
								type = "toggle",
								get = function() return db.enableHistory end,
								set = function() db.enableHistory = not db.enableHistory end,
							},
							sendHistory = {
								order = 3,
								name = "Send History",
								desc = "Send data to everyone in the raid, regardless if you log it yourself. RCLootCouncil will only send data if you're the MasterLooter.",
								type = "toggle",
								get = function() return db.sendHistory; end,
								set = function() db.sendHistory = not db.sendHistory; end,
								hidden = hidden,
							},
							header = {
								order = 4,
								type = "header",
								name = "",
							},
							openLootDB = {
								order = 5,
								name = "Open the Loot History",
								desc = "Click to open the Loot History.",
								type = "execute",
								func = function() self:CallModule("loothistory");	InterfaceOptionsFrame:Hide();end,
							},
							clearLootDB = {
								order = -1,
								name = "Clear Loot History",
								desc = "Delete the entire loot history.",
								type = "execute",
								func = function() self.db.factionrealm.lootDB = {} end,
								confirm = true,
							},
						},
					},
				},
			},
			awardTab = {
				order = 2,
				type = "group",
				name = "Awards",
				hidden = hidden,
				args = {
					autoAward = {
						order = 1,
						name = "Auto Award",
						type = "group",
						inline = true,
						disabled = function() return not db.autoAward end,
						args = {
							autoAward = {
								order = 1,
								name = "Auto Award",
								desc = "Activates Auto Award.",
								type = "toggle",
								get = function() return db.autoAward end,
								set = function() db.autoAward = not db.autoAward; end,
								disabled = false,
							},
							autoAwardLowerThreshold = {
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
								get = function() return db.autoAwardLowerThreshold end,
								set = function(i,v) db.autoAwardLowerThreshold = v; end,
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
								get = function() return db.autoAwardUpperThreshold end,
								set = function(i,v) db.autoAwardUpperThreshold = v; end,
							},
							autoAwardTo = {
								order = 2,
								name = "Auto Award to",
								desc = "The player to Auto Award items to. A selectable list of raid members appear if you're in a raid group.",
								width = "double",
								type = "input",
								hidden = function() return not db.advancedOptions or IsInRaid() end,
								get = function() return db.autoAwardTo; end,
								set = function(i,v) db.autoAwardTo = v; end,
							},
							autoAwardTo2 = {
								order = 2,
								name = "Auto Award to",
								desc = "The player to Auto Award items to.",
								width = "double",
								type = "select",
								style = "dropdown",
								values = function()
									local t = {}
									for i = 1, GetNumGroupMembers() do
										t[i] = GetRaidRosterInfo(i)
									end
									return t;
								end,
								hidden = function() return not db.advancedOptions or not IsInRaid() end,
								get = function() return db.autoAwardTo; end,
								set = function(i,v) db.autoAwardTo = v; end,
							},
							autoAwardReason = {
								order = 2.1,
								name = "Reason",
								desc = "The award reason to add to the Loot History when auto awarding.",
								type = "select",
								style = "dropdown",
								values = function()
									local t = {}
									for i = 1, db.numAwardReasons do
										t[i] = db.awardReasons[i].text
									end
									return t
								end,
								get = function() return db.autoAwardReason end,
								set = function(i,v) db.autoAwardReason = v; end,
							},
						},
					},
					awardReasons = {
						order = 2,
						type = "group",
						name = "Award Reasons",
						inline = true,
						args = {
							desc = {
								order = 0,
								name = "Award reasons that can't be chosen during a roll.\nUsed when changing a response with the right click menu and for Auto Awards.\n",
								type = "description",
							},
							range = {
								order = 1,
								name = "Number of reasons",
								desc = "Slide to change the number of reasons.",
								type = "range",
								width = "full",
								min = 1,
								max = db.maxAwardReasons,
								step = 1,
								get = function() return db.numAwardReasons end,
								set = function(i,v) db.numAwardReasons = v end,
							},
							-- Award reasons made further down
							reset = {
								order = -1,
								name = "Reset to default",
								desc = "Resets the award reasons to default.",
								type = "execute",
								confirm = true,
								func = function() addon:awardReasonsToDefault() end, 
							},
						},
					},

				},
			},
			announcementTab = {
				order = 3,
				type = "group",
				name = "Announcements",
				hidden = hidden,
				args = {
					awardAnnouncement = {
						order = 1,
						name = "Award Announcement",
						type = "group",
						inline = true,
						args = {
							toggle = {
								order = 1,
								name = "Announce Awards",
								desc = "Enables the announcment of awards in chat.",
								type = "toggle",
								width = "full",
								get = function() return db.announceAward end,
								set = function() db.announceAward = not db.announceAward end,
							},
							outputDesc = {
								order = 2,
								name = "\nChoose which channel(s) you want to announce to along with the text.\nUse &p for the name of the player getting the loot and &i for the item awarded.",
								type = "description",
								hidden = function() return not db.announceAward end,
							},
							-- Rest is made further below
						},
					},				
					
					announceConsiderations = {
						order = 2,
						name = "Announce Considerations",
						type = "group",
						inline = true,
						args = {
							announceConsideration = {
								order = 1,
								name = "Announce Considerations",
								desc = "Activates announcement of items under consideration whenever a session starts.",
								type = "toggle",
								width = "full",
								get = function() return db.announceItems end,
								set = function() db.announceItems = not db.announceItems end,
							},
							desc = {
								order = 2,
								type = "description",
								name = "\nChoose the channel you want to announce to and the message.\nYour message serves as a header for the list of items.",
								hidden = function() return not db.announceItems end,
							},							
							announceChannel = {
								order = 3,
								name = "Channel",
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
								set = function(i,v) db.announceChannel = v end,
								get = function() return db.announceChannel end,
								hidden = function() return not db.announceItems end,
							},
							announceText = {
								order = 3.1,
								name = "Message",
								desc = "The message to send to the selected channel.",
								type = "input",
								width = "double",
								get = function() return db.announceText end,
								set = function(i,v) db.announceText = v; end,
								hidden = function() return not db.announceItems end,
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
				order = 4,
				type = "group",
				name = "Buttons and Responses",
				hidden = hidden,
				args = {
					buttonOptions = {
						order = 1,
						type = "group",
						name = "Buttons and Responses",
						inline = true,
						args = {
							optionsDesc = {
								order = 0,
								name = "Configure the reply buttons to show on raiders' Loot Frame.\nThe first button is showed furthest to the left, and the last furthest to the right - use the slider to choose how many buttons you want (max "..db.maxButtons..").\n\nThe order of responses determines all sorting orders of said response.\nThe \"Pass\" button determines which response to filter when \"Filter Passes\" is selected.",
								type = "description"
							},
							buttonsRange = {
								order = 1,
								name = "Number of buttons",
								desc = "Slide to change the number of buttons.",
								type = "range",
								width = "full",
								min = 1,
								max = db.maxButtons,
								step = 1,
								get = function() return db.numButtons end,
								set = function(i,v) db.numButtons = v end,
							},
							passButton = {
								order = -1,
								name = "Pass button",
								desc = "Select which buttons' response you want to filter when selecting \"Filter Passes\".",
								type = "select",
								style = "dropdown",
								width = "double",
								values = function()
									local t = {}
									t[(db.maxButtons + 1)] = "None";
									for i = 1, db.maxButtons do
										if i <= db.numButtons then t[i] = "Button "..i; else break end
									end	
									return t;
								end,
								set = function(i,v) db.passButton = v end,
								get = function() return db.passButton end,
							},
						},
					},
					responseFromChat = {
						order = 2,
						type = "group",
						name = "Responses from Chat",
						inline = true,
						args = {							
							acceptWhispers = {
								order = 1,
								name = "Accept whispers",
								desc = "Enables players to whisper their current item(s) to you to get added to the voting frame.",
								type = "toggle",
								get = function() return db.acceptWhispers end,
								set = function() db.acceptWhispers = not db.acceptWhispers end,
							},
							acceptRaidChat = {
								order = 1.1,
								name = "Accept Raid Chat",
								desc = "Enables players to post their current item(s) in raid chat and thus get added to the voting frame.",
								type = "toggle",
								get = function() return db.acceptRaidChat end,
								set = function() db.acceptRaidChat = not db.acceptRaidChat; end,
							},
							desc = {
								order = 2,
								name = "To get added to the voting frame raiders can link their item(s) followed by a keyword to the Master Looter (Button 1 is used if no keyword is specified).\nExample: \"/w ML_NAME [ITEM] greed\" would by default show up as you greeding on an item.\nBelow you can choose keywords for the individual buttons, seperated by punctation or spaces. Only numbers and words are accepted.\nPlayers can recieve the keyword list by messaging 'rchelp' to the Master Looter once the addon is enabled (i.e. in a raid).",
								type = "description",
								hidden = function() return not (db.acceptWhispers or db.acceptRaidChat) end,
							},
							-- Made further down
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
									for k,v in ipairs(db.council) do t[k] = ""..v end
									return t;
								end,
								width = "full",
								get = function() return true end,
								set = function(m,key) tremove(db.council,key) end,
							},							
							removeAll = {
								order = 3,
								name = "Remove All",
								desc = "Remove all council members",
								type = "execute",
								confirm = true,
								func = function() db.council = {} end,							
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
										set = function(j,i) db.council = {}; RCLootCouncil_Mainframe.setRank(i); end, --TODO CHANGE THIS
										get = function() return db.minRank; end,
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
						--hidden = not IsInRaid(), -- don't show if we're not in a raid
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
										tinsert(self.db.profile.council, Ambiguate(select(1,GetRaidRosterInfo(i)), "none"))	-- might need a tostring()		
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
	for i = 1, db.maxButtons do	
		button = {
			order = i * 3 + 1,
			name = "Button "..i,
			desc = "Set the text on button "..i..".",
			type = "input",
			get = function() return db.buttons[i].text end,
			set = function(info, value)	db.buttons[i].text = tostring(value) end,
			hidden = function() return db.numButtons < i end,
		}
		options.args.buttonsOptionsTab.args.buttonOptions.args["button"..i] = button;
		picker = {
			order = i * 3 + 2,
			name = "Response color",
			desc = "Set a color for the response.",
			type = "color",
			get = function() return unpack(self.responses[i].color)	end,
			set = function(info,r,g,b,a) self.responses[i].color = {r,g,b,a} end,
			hidden = function() return db.numButtons < i end,
		}
		options.args.buttonsOptionsTab.args.buttonOptions.args["picker"..i] = picker;
		text = {	
			order = i * 3 + 3,
			name = "Response",
			desc = "Set the text for button "..i.."'s response.",
			type = "input",
			get = function() return self.responses[i].text end,
			set = function(info, value) self.responses[i].text = tostring(value) end,
			hidden = function() return db.numButtons < i end,		
		}
		options.args.buttonsOptionsTab.args.buttonOptions.args["text"..i] = text;
		
		local whisperKeys = {
			order = i + 3,
			name = "Button"..i,
			desc = "Set the whisper keys for button "..i..". Used in conjunction with Chat settings.",
			type = "input",
			width = "double",
			get = function() return db.buttons[i].whisperKey end,
			set = function(k,v) db.buttons[i].whisperKey = tostring(v) end,
			hidden = function() return not (db.acceptWhispers or db.acceptRaidChat) or db.numButtons < i end,
		}
		options.args.buttonsOptionsTab.args.responseFromChat.args["whisperKey"..i] = whisperKeys;
	end

	-- Award Reasons
	for i = 1, db.maxAwardReasons do
		options.args.awardTab.args.awardReasons.args["reason"..i] = {
			order = i+1,
			name = "Reason "..i,
			desc = "Text for reason #"..i,
			type = "input",
			width = "double",
			get = function() return db.awardReasons[i].text end,
			set = function(k,v) db.awardReasons[i].text = v; end,
			hidden = function() return db.numAwardReasons < i end,
		}
		options.args.awardTab.args.awardReasons.args["color"..i] = {
			order = i +1.1,
			name = "Text color",
			desc = "Color of the text when displayed.",
			type = "color",
			width = "half",
			get = function() return unpack(db.awardReasons[i].color) end,
			set = function(info, r,g,b,a) db.awardReasons[i].color = {r,g,b,a} end, 
			hidden = function() return db.numAwardReasons < i end,
		}
		options.args.awardTab.args.awardReasons.args["log"..i] = {
			order = i +1.2,
			name = "Log",
			desc = "Enables logging in Loot History.",
			type = "toggle",
			width = "half",
			get = function() return db.awardReasons[i].log end,
			set = function() db.awardReasons[i].log = not db.awardReasons[i].log end,
			hidden = function() return db.numAwardReasons < i end,
		}
	end
	-- Announce Channels
	for i = 1, #db.awardText do
		options.args.announcementTab.args.awardAnnouncement.args["outputSelect"..i] = {
			order = i+3,
			name = "Channel "..i..":",
			desc = "Select a channel to announce awards to.",
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
			set = function(j,v) db.awardText[i].channel = v end,
			get = function() return db.awardText[i].channel end,
			hidden = function() return not db.announceAward end,
		}
		options.args.announcementTab.args.awardAnnouncement.args["outputMessage"..i] = {
			order = i+3.1,
			name = "Message",
			desc = "The message to send to the selected channel.",
			type = "input",
			width = "double",
			get = function() return db.awardText[i].text end,
			set = function(j,v) db.awardText[i].text = v; end,
			hidden = function() return not db.announceAward end,
		}
	end
	-- #endregion
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
