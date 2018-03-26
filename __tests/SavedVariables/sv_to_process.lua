
RCLootCouncilDB = {
	["namespaces"] = {
		["ExtraUtilities"] = {
			["profiles"] = {
				["Default"] = {
					["acceptPawn"] = false,
					["columns"] = {
						["traits"] = {
							["enabled"] = true,
						},
						["legendaries"] = {
							["enabled"] = true,
						},
						["spec"] = {
							["enabled"] = true,
						},
						["pawn"] = {
							["enabled"] = true,
							["pos"] = -9,
						},
						["ilvlUpgrade"] = {
							["enabled"] = true,
						},
						["bonus"] = {
							["enabled"] = true,
							["pos"] = -8,
						},
					},
					["normalColumns"] = {
						["class"] = {
							["enabled"] = false,
						},
						["roll"] = {
							["pos"] = 1,
						},
					},
					["pawn"] = {
						["PALADIN"] = {
							[70] = "(Torm)Paladin: Retribution",
							[66] = "Prot Pally",
						},
						["WARLOCK"] = {
							[266] = "908 4P iLvl 1 Target",
						},
						["DRUID"] = {
							[104] = "Guardian",
							[105] = "RDSW",
							[102] = "Balance",
						},
						["MONK"] = {
							[270] = "Joe Monk: Mistweaver",
						},
						["HUNTER"] = {
							[253] = "(bray)Hunter: Beast Mastery",
						},
					},
				},
			},
		},
		["EPGP"] = {
			["global"] = {
				["tocVersion"] = "2.2.2",
				["version"] = "2.2.2",
				["testTocVersion"] = "",
			},
			["profiles"] = {
				["Default"] = {
					["customEP"] = {
						["EPFormulas"] = {
							{
							}, -- [1]
						},
					},
				},
			},
		},
	},
	["profileKeys"] = {
		["DangÃ©rzone - Area 52"] = "Default",
		["Tenaral - Area 52"] = "Default",
		["Timerags - Area 52"] = "Default",
		["EterÃ­ - Area 52"] = "Default",
		["Velinadreni - Area 52"] = "Default",
		["Agonon - Area 52"] = "Default",
		["Timedrawnigh - Area 52"] = "Default",
		["Timeragnarok - Area 52"] = "Default",
		["Ragnosmarka - Area 52"] = "Default",
		["Seladri - Area 52"] = "Default",
		["Avernakis - Area 52"] = "Default",
		["Eteri - Area 52"] = "Default",
	},
	["global"] = {
		["locale"] = "enUS",
		["log"] = {
			"20:00:13 - Event: (PARTY_LEADER_CHANGED)", -- [1]
			"20:00:13 - GetML()", -- [2]
			"20:00:13 - LootMethod =  (personalloot)", -- [3]
			"20:00:13 - Resetting council as we have a new ML!", -- [4]
			"20:00:13 - MasterLooter =  (Avernakis-Area52)", -- [5]
			"20:00:13 - GetCouncilInGroup (Avernakis-Area52)", -- [6]
			"20:00:13 - ML:NewML (Avernakis-Area52)", -- [7]
			"20:00:13 - UpdateMLdb", -- [8]
			"20:00:13 - UpdateGroup (true)", -- [9]
			"20:00:13 - ML:AddCandidate (Avernakis-Area52) (DRUID) (HEALER) (nil) (nil) (nil) (nil)", -- [10]
			"20:00:13 - GetCouncilInGroup (Avernakis-Area52)", -- [11]
			"20:00:13 - Event: (PARTY_LOOT_METHOD_CHANGED)", -- [12]
			"20:00:13 - GetML()", -- [13]
			"20:00:13 - LootMethod =  (personalloot)", -- [14]
			"20:00:13 - Comm received:^1^SplayerInfoRequest^T^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [15]
			"20:00:13 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [16]
			"20:00:13 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^Sclass^SDRUID^Srank^S^t^t^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [17]
			"20:00:13 - Inspect! (Avernakis-Area52) (Avernakis) (Player-3676-090665D9) (true) (true)", -- [18]
			"20:00:13 - Inspect queued on:  (Avernakis-Area52)", -- [19]
			"20:00:13 - Comm received:^1^Scouncil^T^N1^T^N1^SAvernakis-Area52^t^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [20]
			"20:00:13 - true = (IsCouncil) (Avernakis-Area52)", -- [21]
			"20:00:13 - GetLootDBStatistics()", -- [22]
			"20:00:13 - GetGuildRankNum()", -- [23]
			"20:00:13 - RCVotingFrame (enabled)", -- [24]
			"20:00:13 - Comm received:^1^SplayerInfo^T^N1^SAvernakis-Area52^N2^SDRUID^N3^SHEALER^N4^SBaked~`Potato^N6^N0^N7^N942.375^N8^N105^t^^ (from:) (Avernakis) (distri:) (WHISPER)", -- [25]
			"20:00:13 - ML:AddCandidate (Avernakis-Area52) (DRUID) (HEALER) (Baked Potato) (nil) (0) (105)", -- [26]
			"20:00:14 - InspectHandler() (INSPECT_READY) (Player-3676-090665D9)", -- [27]
			"20:00:14 - Successfully received specID for  (Avernakis-Area52) (105)", -- [28]
			"20:00:14 - Event: (PARTY_LOOT_METHOD_CHANGED)", -- [29]
			"20:00:14 - GetML()", -- [30]
			"20:00:14 - LootMethod =  (master)", -- [31]
			"20:00:14 - ML:NewML (Avernakis-Area52)", -- [32]
			"20:00:14 - UpdateMLdb", -- [33]
			"20:00:14 - UpdateGroup (true)", -- [34]
			"20:00:14 - Start handle loot.", -- [35]
			"20:00:14 - Comm received:^1^SplayerInfoRequest^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [36]
			"20:00:15 - Comm received:^1^SplayerInfo^T^N1^SAvernakis-Area52^N2^SDRUID^N3^SHEALER^N4^SBaked~`Potato^N6^N0^N7^N942.375^N8^N105^t^^ (from:) (Avernakis) (distri:) (WHISPER)", -- [37]
			"20:00:15 - ML:AddCandidate (Avernakis-Area52) (DRUID) (HEALER) (Baked Potato) (nil) (0) (105)", -- [38]
			"20:00:23 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [39]
			"20:00:23 - Comm received:^1^Scouncil^T^N1^T^N1^SAvernakis-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [40]
			"20:00:23 - true = (IsCouncil) (Avernakis-Area52)", -- [41]
			"20:00:23 - Comm received:^1^Scouncil^T^N1^T^N1^SAvernakis-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [42]
			"20:00:23 - true = (IsCouncil) (Avernakis-Area52)", -- [43]
			"20:00:23 - UpdateGroup (table: 000001AABA699CC0)", -- [44]
			"20:00:23 - ML:AddCandidate (Lithelasha-Area52) (DEMONHUNTER) (DAMAGER) (nil) (nil) (nil) (nil)", -- [45]
			"20:00:23 - ML:AddCandidate (Dibbs-Area52) (SHAMAN) (DAMAGER) (nil) (nil) (nil) (nil)", -- [46]
			"20:00:23 - ML:AddCandidate (Freakeer-Area52) (SHAMAN) (DAMAGER) (nil) (nil) (nil) (nil)", -- [47]
			"20:00:23 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52)", -- [48]
			"20:00:23 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [49]
			"20:00:24 - GG:AddEntry(Update) (Lithelasha-Area52) (4)", -- [50]
			"20:00:24 - Comm received:^1^SplayerInfo^T^N1^SLithelasha-Area52^N2^SDEMONHUNTER^N3^SDAMAGER^N4^SStewed^N6^N0^N7^N942.5^N8^N577^t^^ (from:) (Lithelasha) (distri:) (WHISPER)", -- [51]
			"20:00:24 - ML:AddCandidate (Lithelasha-Area52) (DEMONHUNTER) (DAMAGER) (Stewed) (nil) (0) (577)", -- [52]
			"20:00:24 - GG:AddEntry(Update) (Dibbs-Area52) (1)", -- [53]
			"20:00:24 - Comm received:^1^SplayerInfo^T^N1^SDibbs-Area52^N2^SSHAMAN^N3^SDAMAGER^N4^SStewed^N6^N0^N7^N939.4375^N8^N262^t^^ (from:) (Dibbs) (distri:) (WHISPER)", -- [54]
			"20:00:24 - ML:AddCandidate (Dibbs-Area52) (SHAMAN) (DAMAGER) (Stewed) (nil) (0) (262)", -- [55]
			"20:00:24 - GG:AddEntry (Freakeer-Area52) (7)", -- [56]
			"20:00:24 - Comm received:^1^SplayerInfo^T^N1^SFreakeer-Area52^N2^SSHAMAN^N3^SDAMAGER^N4^STater~`Salad^N6^N0^N7^N941.875^N8^N262^t^^ (from:) (Freakeer) (distri:) (WHISPER)", -- [57]
			"20:00:24 - ML:AddCandidate (Freakeer-Area52) (SHAMAN) (DAMAGER) (Tater Salad) (nil) (0) (262)", -- [58]
			"20:00:28 - Timer MLdb_check passed", -- [59]
			"20:00:29 - Comm received:^1^Scandidates^T^N1^T^SFreakeer-Area52^T^Srole^SDAMAGER^Sclass^SSHAMAN^Srank^S^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^SDibbs-Area52^T^Srole^SDAMAGER^Sclass^SSHAMAN^Srank^S^t^SLithelasha-Area52^T^Srole^SDAMAGER^Sclass^SDEMONHUNTER^Srank^S^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [60]
			"20:00:29 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [61]
			"20:00:29 - Inspect failed on:  (Lithelasha-Area52)", -- [62]
			"20:00:29 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (false)", -- [63]
			"20:00:29 - Inspect failed on:  (Dibbs-Area52)", -- [64]
			"20:00:29 - Inspect! (Freakeer-Area52) (Freakeer) (Player-3676-07E65081) (true) (false)", -- [65]
			"20:00:29 - Inspect failed on:  (Freakeer-Area52)", -- [66]
			"20:00:29 - Comm received:^1^SMLdb_request^T^t^^ (from:) (Lithelasha) (distri:) (WHISPER)", -- [67]
			"20:00:30 - Comm received:^1^SMLdb_request^T^t^^ (from:) (Dibbs) (distri:) (WHISPER)", -- [68]
			"20:00:30 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [69]
			"20:00:30 - true = (IsCouncil) (Avernakis-Area52)", -- [70]
			"20:00:32 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [71]
			"20:00:32 - true = (IsCouncil) (Avernakis-Area52)", -- [72]
			"20:00:32 - Comm received:^1^SMLdb_request^T^t^^ (from:) (Freakeer) (distri:) (WHISPER)", -- [73]
			"20:00:35 - Comm received:^1^Scandidates^T^N1^T^SFreakeer-Area52^T^Srole^SDAMAGER^Sclass^SSHAMAN^Srank^S^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^SDibbs-Area52^T^Srole^SDAMAGER^Sclass^SSHAMAN^Srank^S^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [74]
			"20:00:35 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [75]
			"20:00:35 - Inspect failed on:  (Lithelasha-Area52)", -- [76]
			"20:00:35 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (false)", -- [77]
			"20:00:35 - Inspect failed on:  (Dibbs-Area52)", -- [78]
			"20:00:35 - Inspect! (Freakeer-Area52) (Freakeer) (Player-3676-07E65081) (true) (false)", -- [79]
			"20:00:35 - Inspect failed on:  (Freakeer-Area52)", -- [80]
			"20:00:44 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [81]
			"20:00:45 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Lesmes) (distri:) (GUILD)", -- [82]
			"20:00:50 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [83]
			"20:00:58 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [84]
			"20:01:04 - Event: (PLAYER_ENTERING_WORLD) (false) (false)", -- [85]
			"20:01:04 - GetML()", -- [86]
			"20:01:04 - LootMethod =  (master)", -- [87]
			"20:01:11 - UpdateGroup (table: 000001AABA699CC0)", -- [88]
			"20:01:11 - ML:AddCandidate (Lesmes-Area52) (MAGE) (DAMAGER) (nil) (nil) (nil) (nil)", -- [89]
			"20:01:11 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52)", -- [90]
			"20:01:27 - Comm received:^1^SMLdb_request^T^t^^ (from:) (Lesmes) (distri:) (WHISPER)", -- [91]
			"20:01:27 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Lesmes) (distri:) (WHISPER)", -- [92]
			"20:01:27 - GG:AddEntry(Update) (Lesmes-Area52) (6)", -- [93]
			"20:01:27 - Comm received:^1^SplayerInfo^T^N1^SLesmes-Area52^N2^SMAGE^N3^SDAMAGER^N4^SStewed^N5^B^N6^N790^N7^N942.0625^N8^N63^t^^ (from:) (Lesmes) (distri:) (WHISPER)", -- [94]
			"20:01:27 - ML:AddCandidate (Lesmes-Area52) (MAGE) (DAMAGER) (Stewed) (true) (790) (63)", -- [95]
			"20:01:28 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SLesmes-Area52^T^Srole^SDAMAGER^Sclass^SMAGE^Srank^S^t^SDibbs-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SStewed^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [96]
			"20:01:28 - Inspect! (Lesmes-Area52) (Lesmes) (Player-3676-0964317D) (true) (false)", -- [97]
			"20:01:28 - Inspect failed on:  (Lesmes-Area52)", -- [98]
			"20:01:28 - Inspect! (Freakeer-Area52) (Freakeer) (Player-3676-07E65081) (true) (false)", -- [99]
			"20:01:28 - Inspect failed on:  (Freakeer-Area52)", -- [100]
			"20:01:28 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [101]
			"20:01:28 - Inspect failed on:  (Lithelasha-Area52)", -- [102]
			"20:01:28 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (false)", -- [103]
			"20:01:28 - Inspect failed on:  (Dibbs-Area52)", -- [104]
			"20:01:37 - UpdateGroup (table: 000001AABA699CC0)", -- [105]
			"20:01:37 - ML:AddCandidate (Phryke-Area52) (WARLOCK) (DAMAGER) (nil) (nil) (nil) (nil)", -- [106]
			"20:01:37 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52)", -- [107]
			"20:01:38 - GG:AddEntry(Update) (Phryke-Area52) (5)", -- [108]
			"20:01:38 - Comm received:^1^SplayerInfo^T^N1^SPhryke-Area52^N2^SWARLOCK^N3^SDAMAGER^N4^SSpud^N6^N0^N7^N935.5625^N8^N265^t^^ (from:) (Phryke) (distri:) (WHISPER)", -- [109]
			"20:01:38 - ML:AddCandidate (Phryke-Area52) (WARLOCK) (DAMAGER) (Spud) (nil) (0) (265)", -- [110]
			"20:01:40 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [111]
			"20:01:40 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [112]
			"20:01:40 - true = (IsCouncil) (Avernakis-Area52)", -- [113]
			"20:01:43 - Comm received:^1^Scandidates^T^N1^T^SPhryke-Area52^T^Srole^SDAMAGER^Sclass^SWARLOCK^Srank^S^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^SDibbs-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SStewed^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [114]
			"20:01:43 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (false)", -- [115]
			"20:01:43 - Inspect failed on:  (Phryke-Area52)", -- [116]
			"20:01:43 - Inspect! (Lesmes-Area52) (Lesmes) (Player-3676-0964317D) (true) (false)", -- [117]
			"20:01:43 - Inspect failed on:  (Lesmes-Area52)", -- [118]
			"20:01:43 - Inspect! (Freakeer-Area52) (Freakeer) (Player-3676-07E65081) (true) (false)", -- [119]
			"20:01:43 - Inspect failed on:  (Freakeer-Area52)", -- [120]
			"20:01:43 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [121]
			"20:01:43 - Inspect failed on:  (Lithelasha-Area52)", -- [122]
			"20:01:43 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (false)", -- [123]
			"20:01:43 - Inspect failed on:  (Dibbs-Area52)", -- [124]
			"20:02:04 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Velynila) (distri:) (GUILD)", -- [125]
			"20:02:08 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Tuyen) (distri:) (GUILD)", -- [126]
			"20:03:15 - UpdateGroup (table: 000001AABA699CC0)", -- [127]
			"20:03:15 - ML:AddCandidate (Tuyen-Area52) (PALADIN) (TANK) (nil) (nil) (nil) (nil)", -- [128]
			"20:03:15 - ML:AddCandidate (Velynila-Area52) (DEMONHUNTER) (DAMAGER) (nil) (nil) (nil) (nil)", -- [129]
			"20:03:15 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Tuyen-Area52)", -- [130]
			"20:03:16 - GG:AddEntry (Velynila-Area52) (8)", -- [131]
			"20:03:16 - Comm received:^1^SplayerInfo^T^N1^SVelynila-Area52^N2^SDEMONHUNTER^N3^SDAMAGER^N4^SBoiled^N6^N0^N7^N925.4375^N8^N581^t^^ (from:) (Velynila) (distri:) (WHISPER)", -- [132]
			"20:03:16 - ML:AddCandidate (Velynila-Area52) (DEMONHUNTER) (DAMAGER) (Boiled) (nil) (0) (581)", -- [133]
			"20:03:16 - GG:AddEntry (Tuyen-Area52) (9)", -- [134]
			"20:03:16 - Comm received:^1^SplayerInfo^T^N1^STuyen-Area52^N2^SPALADIN^N3^STANK^N4^STater~`Tot^N6^N0^N7^N945.4375^N8^N66^t^^ (from:) (Tuyen) (distri:) (WHISPER)", -- [135]
			"20:03:16 - ML:AddCandidate (Tuyen-Area52) (PALADIN) (TANK) (Tater Tot) (nil) (0) (66)", -- [136]
			"20:03:20 - Comm received:^1^SMLdb_request^T^t^^ (from:) (Tuyen) (distri:) (WHISPER)", -- [137]
			"20:03:20 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Tuyen) (distri:) (WHISPER)", -- [138]
			"20:03:20 - Comm received:^1^SMLdb_request^T^t^^ (from:) (Velynila) (distri:) (WHISPER)", -- [139]
			"20:03:20 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Velynila) (distri:) (WHISPER)", -- [140]
			"20:03:26 - Comm received:^1^Scandidates^T^N1^T^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SSpud^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^Sclass^SPALADIN^Srank^S^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SDibbs-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SStewed^t^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^SVelynila-Area52^T^Srole^SDAMAGER^Sclass^SDEMONHUNTER^Srank^S^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [141]
			"20:03:26 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (false)", -- [142]
			"20:03:26 - Inspect failed on:  (Phryke-Area52)", -- [143]
			"20:03:26 - Inspect! (Tuyen-Area52) (Tuyen) (Player-3676-06DD54E2) (true) (true)", -- [144]
			"20:03:26 - Inspect queued on:  (Tuyen-Area52)", -- [145]
			"20:03:26 - Inspect! (Freakeer-Area52) (Freakeer) (Player-3676-07E65081) (true) (false)", -- [146]
			"20:03:26 - Inspect failed on:  (Freakeer-Area52)", -- [147]
			"20:03:26 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [148]
			"20:03:26 - Inspect failed on:  (Lithelasha-Area52)", -- [149]
			"20:03:26 - Inspect! (Lesmes-Area52) (Lesmes) (Player-3676-0964317D) (true) (true)", -- [150]
			"20:03:26 - Inspect queued on:  (Lesmes-Area52)", -- [151]
			"20:03:26 - Inspect! (Velynila-Area52) (Velynila) (Player-3676-0950F86A) (true) (false)", -- [152]
			"20:03:26 - Inspect failed on:  (Velynila-Area52)", -- [153]
			"20:03:26 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (false)", -- [154]
			"20:03:26 - Inspect failed on:  (Dibbs-Area52)", -- [155]
			"20:03:27 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [156]
			"20:03:27 - true = (IsCouncil) (Avernakis-Area52)", -- [157]
			"20:03:28 - InspectHandler() (INSPECT_READY) (Player-3676-06DD54E2)", -- [158]
			"20:03:28 - Successfully received specID for  (Tuyen-Area52) (66)", -- [159]
			"20:03:34 - InspectHandler() (INSPECT_READY) (Player-3676-0964317D)", -- [160]
			"20:03:34 - Successfully received specID for  (Lesmes-Area52) (63)", -- [161]
			"20:03:36 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [162]
			"20:03:37 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [163]
			"20:03:37 - true = (IsCouncil) (Avernakis-Area52)", -- [164]
			"20:03:38 - UpdateGroup (table: 000001AABA699CC0)", -- [165]
			"20:03:41 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [166]
			"20:03:41 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [167]
			"20:03:41 - true = (IsCouncil) (Avernakis-Area52)", -- [168]
			"20:04:10 - UpdateGroup (table: 000001AABA699CC0)", -- [169]
			"20:06:18 - Event: (RAID_INSTANCE_WELCOME) (Antorus, the Burning Throne (Normal)) (309221) (0) (0)", -- [170]
			"20:06:19 - Event: (PLAYER_ENTERING_WORLD) (false) (false)", -- [171]
			"20:06:19 - GetML()", -- [172]
			"20:06:19 - LootMethod =  (master)", -- [173]
			"20:06:21 - UpdateGroup (table: 000001AABA699CC0)", -- [174]
			"20:06:28 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Tuyen) (distri:) (GUILD)", -- [175]
			"20:06:31 - UpdateGroup (table: 000001AABA699CC0)", -- [176]
			"20:07:18 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Phryke) (distri:) (GUILD)", -- [177]
			"20:07:26 - UpdateGroup (table: 000001AABA699CC0)", -- [178]
			"20:07:27 - Comm received:^1^SMLdb_request^T^t^^ (from:) (Tuyen) (distri:) (WHISPER)", -- [179]
			"20:07:29 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Tuyen) (distri:) (WHISPER)", -- [180]
			"20:07:37 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [181]
			"20:07:37 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [182]
			"20:07:37 - true = (IsCouncil) (Avernakis-Area52)", -- [183]
			"20:07:37 - Comm received:^1^SMLdb_request^T^t^^ (from:) (Phryke) (distri:) (WHISPER)", -- [184]
			"20:07:37 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Phryke) (distri:) (WHISPER)", -- [185]
			"20:07:43 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [186]
			"20:07:43 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [187]
			"20:07:43 - true = (IsCouncil) (Avernakis-Area52)", -- [188]
			"20:07:51 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Amrehlu) (distri:) (GUILD)", -- [189]
			"20:07:57 - Comm received:^1^Scandidates_request^T^t^^ (from:) (Tuyen) (distri:) (WHISPER)", -- [190]
			"20:07:57 - Comm received:^1^Scandidates^T^N1^T^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SSpud^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SDibbs-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SStewed^t^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^SVelynila-Area52^T^Srole^SDAMAGER^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SBoiled^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [191]
			"20:07:57 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (false)", -- [192]
			"20:07:57 - Inspect failed on:  (Phryke-Area52)", -- [193]
			"20:07:57 - Inspect! (Freakeer-Area52) (Freakeer) (Player-3676-07E65081) (true) (true)", -- [194]
			"20:07:57 - Inspect queued on:  (Freakeer-Area52)", -- [195]
			"20:07:57 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [196]
			"20:07:57 - Inspect failed on:  (Lithelasha-Area52)", -- [197]
			"20:07:57 - Inspect! (Velynila-Area52) (Velynila) (Player-3676-0950F86A) (true) (false)", -- [198]
			"20:07:57 - Inspect failed on:  (Velynila-Area52)", -- [199]
			"20:07:57 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (true)", -- [200]
			"20:07:57 - Inspect queued on:  (Dibbs-Area52)", -- [201]
			"20:07:58 - Comm received:^1^Scandidates_request^T^t^^ (from:) (Phryke) (distri:) (WHISPER)", -- [202]
			"20:07:58 - Comm received:^1^Scandidates^T^N1^T^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SSpud^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SDibbs-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SStewed^t^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^SVelynila-Area52^T^Srole^SDAMAGER^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SBoiled^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [203]
			"20:07:58 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (false)", -- [204]
			"20:07:58 - Inspect failed on:  (Phryke-Area52)", -- [205]
			"20:07:58 - Inspect! (Freakeer-Area52) (Freakeer) (Player-3676-07E65081) (true) (true)", -- [206]
			"20:07:58 - Inspect queued on:  (Freakeer-Area52)", -- [207]
			"20:07:58 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [208]
			"20:07:58 - Inspect failed on:  (Lithelasha-Area52)", -- [209]
			"20:07:58 - Inspect! (Velynila-Area52) (Velynila) (Player-3676-0950F86A) (true) (false)", -- [210]
			"20:07:58 - Inspect failed on:  (Velynila-Area52)", -- [211]
			"20:07:58 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (true)", -- [212]
			"20:07:58 - Inspect queued on:  (Dibbs-Area52)", -- [213]
			"20:07:58 - InspectHandler() (INSPECT_READY) (Player-3676-07E65081)", -- [214]
			"20:07:58 - Successfully received specID for  (Freakeer-Area52) (262)", -- [215]
			"20:08:02 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Amrehlu) (distri:) (GUILD)", -- [216]
			"20:08:17 - InspectHandler() (INSPECT_READY) (Player-3676-0964317D)", -- [217]
			"20:08:17 - InspectHandler() tried to inspect a non pooled guid: (Player-3676-0964317D)", -- [218]
			"20:08:18 - UpdateGroup (table: 000001AABA699CC0)", -- [219]
			"20:08:18 - ML:AddCandidate (Amrehlu-Area52) (HUNTER) (DAMAGER) (nil) (nil) (nil) (nil)", -- [220]
			"20:08:18 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Tuyen-Area52)", -- [221]
			"20:08:18 - Comm received:^1^Scandidates^T^N1^T^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SVelynila-Area52^T^Srole^SDAMAGER^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SBoiled^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SSpud^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SAmrehlu-Area52^T^Srole^SDAMAGER^Sclass^SHUNTER^Srank^S^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^SDibbs-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [222]
			"20:08:18 - Inspect! (Velynila-Area52) (Velynila) (Player-3676-0950F86A) (true) (false)", -- [223]
			"20:08:18 - Inspect failed on:  (Velynila-Area52)", -- [224]
			"20:08:18 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [225]
			"20:08:18 - Inspect failed on:  (Lithelasha-Area52)", -- [226]
			"20:08:18 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (false)", -- [227]
			"20:08:18 - Inspect failed on:  (Phryke-Area52)", -- [228]
			"20:08:18 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (true)", -- [229]
			"20:08:18 - Inspect queued on:  (Dibbs-Area52)", -- [230]
			"20:08:18 - Inspect! (Amrehlu-Area52) (Amrehlu) (Player-3676-088D21B8) (true) (false)", -- [231]
			"20:08:18 - Inspect failed on:  (Amrehlu-Area52)", -- [232]
			"20:08:18 - GG:AddEntry(Update) (Amrehlu-Area52) (2)", -- [233]
			"20:08:18 - Comm received:^1^SplayerInfo^T^N1^SAmrehlu-Area52^N2^SHUNTER^N3^SDAMAGER^N4^SStewed^N6^N0^N7^N941.625^N8^N255^t^^ (from:) (Amrehlu) (distri:) (WHISPER)", -- [234]
			"20:08:18 - ML:AddCandidate (Amrehlu-Area52) (HUNTER) (DAMAGER) (Stewed) (nil) (0) (255)", -- [235]
			"20:08:23 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Amrehlu) (distri:) (WHISPER)", -- [236]
			"20:08:24 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [237]
			"20:08:24 - true = (IsCouncil) (Avernakis-Area52)", -- [238]
			"20:08:25 - InspectHandler() (INSPECT_READY) (Player-3676-07E65081)", -- [239]
			"20:08:25 - InspectHandler() tried to inspect a non pooled guid: (Player-3676-07E65081)", -- [240]
			"20:10:57 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Chauric) (distri:) (GUILD)", -- [241]
			"20:11:27 - UpdateGroup (table: 000001AABA699CC0)", -- [242]
			"20:11:27 - ML:AddCandidate (Chauric-Area52) (MONK) (TANK) (nil) (nil) (nil) (nil)", -- [243]
			"20:11:27 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Tuyen-Area52)", -- [244]
			"20:11:27 - Comm received:^1^Scandidates^T^N1^T^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SVelynila-Area52^T^Srole^SDAMAGER^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SBoiled^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SSpud^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SChauric-Area52^T^Srole^STANK^Sclass^SMONK^Srank^S^t^SAmrehlu-Area52^T^Srole^SDAMAGER^SspecID^N255^Senchant_lvl^N0^Sclass^SHUNTER^Srank^SStewed^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^SDibbs-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [245]
			"20:11:27 - Inspect! (Velynila-Area52) (Velynila) (Player-3676-0950F86A) (true) (false)", -- [246]
			"20:11:27 - Inspect failed on:  (Velynila-Area52)", -- [247]
			"20:11:27 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [248]
			"20:11:27 - Inspect failed on:  (Lithelasha-Area52)", -- [249]
			"20:11:27 - Inspect! (Chauric-Area52) (Chauric) (Player-3676-08DA36E4) (true) (false)", -- [250]
			"20:11:27 - Inspect failed on:  (Chauric-Area52)", -- [251]
			"20:11:27 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (true)", -- [252]
			"20:11:27 - Inspect queued on:  (Dibbs-Area52)", -- [253]
			"20:11:27 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (true)", -- [254]
			"20:11:27 - Inspect queued on:  (Phryke-Area52)", -- [255]
			"20:11:27 - Inspect! (Amrehlu-Area52) (Amrehlu) (Player-3676-088D21B8) (true) (false)", -- [256]
			"20:11:27 - Inspect failed on:  (Amrehlu-Area52)", -- [257]
			"20:11:27 - GG:AddEntry (Chauric-Area52) (10)", -- [258]
			"20:11:27 - Comm received:^1^SplayerInfo^T^N1^SChauric-Area52^N2^SMONK^N3^STANK^N4^SStewed^N6^N0^N7^N938.5625^N8^N268^t^^ (from:) (Chauric) (distri:) (WHISPER)", -- [259]
			"20:11:27 - ML:AddCandidate (Chauric-Area52) (MONK) (TANK) (Stewed) (nil) (0) (268)", -- [260]
			"20:11:29 - InspectHandler() (INSPECT_READY) (Player-3676-090665D9)", -- [261]
			"20:11:29 - InspectHandler() tried to inspect a non pooled guid: (Player-3676-090665D9)", -- [262]
			"20:11:32 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Chauric) (distri:) (WHISPER)", -- [263]
			"20:11:32 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [264]
			"20:11:32 - true = (IsCouncil) (Avernakis-Area52)", -- [265]
			"20:15:16 - Comm received:^1^SverTest^T^N1^S2.7.3^t^^ (from:) (Dravash) (distri:) (GUILD)", -- [266]
			"20:16:04 - ML event (PLAYER_REGEN_ENABLED)", -- [267]
			"20:16:10 - ML event (CHAT_MSG_LOOT) (Dibbs receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|r.) () () () (Dibbs) () (0) (0) () (0) (2306) (nil) (0) (false) (false) (false) (false)", -- [268]
			"20:16:10 - ML event (CHAT_MSG_LOOT) (Dibbs receives loot: |cff9d9d9d|Hitem:132200::::::::110:105::::::|h[Ashen Ring]|h|r.) () () () (Dibbs) () (0) (0) () (0) (2307) (nil) (0) (false) (false) (false) (false)", -- [269]
			"20:16:12 - UpdateGroup (table: 000001AABA699CC0)", -- [270]
			"20:16:12 - ML:AddCandidate (Dravash-Area52) (DEATHKNIGHT) (DAMAGER) (nil) (nil) (nil) (nil)", -- [271]
			"20:16:12 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Tuyen-Area52)", -- [272]
			"20:16:12 - GG:AddEntry (Dravash-Area52) (11)", -- [273]
			"20:16:12 - Comm received:^1^SplayerInfo^T^N1^SDravash-Area52^N2^SDEATHKNIGHT^N3^SDAMAGER^N4^SBoiled^N6^N0^N7^N947.375^N8^N251^t^^ (from:) (Dravash) (distri:) (WHISPER)", -- [274]
			"20:16:12 - ML:AddCandidate (Dravash-Area52) (DEATHKNIGHT) (DAMAGER) (Boiled) (nil) (0) (251)", -- [275]
			"20:16:12 - Comm received:^1^Scandidates^T^N1^T^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SVelynila-Area52^T^Srole^SDAMAGER^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SBoiled^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SSpud^t^SDravash-Area52^T^Srole^SDAMAGER^Sclass^SDEATHKNIGHT^Srank^S^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SChauric-Area52^T^Srole^STANK^SspecID^N268^Senchant_lvl^N0^Sclass^SMONK^Srank^SStewed^t^SAmrehlu-Area52^T^Srole^SDAMAGER^SspecID^N255^Senchant_lvl^N0^Sclass^SHUNTER^Srank^SStewed^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^SDibbs-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [276]
			"20:16:12 - Inspect! (Velynila-Area52) (Velynila) (Player-3676-0950F86A) (true) (true)", -- [277]
			"20:16:12 - Inspect queued on:  (Velynila-Area52)", -- [278]
			"20:16:12 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [279]
			"20:16:12 - Inspect failed on:  (Lithelasha-Area52)", -- [280]
			"20:16:12 - Inspect! (Chauric-Area52) (Chauric) (Player-3676-08DA36E4) (true) (true)", -- [281]
			"20:16:12 - Inspect queued on:  (Chauric-Area52)", -- [282]
			"20:16:12 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (true)", -- [283]
			"20:16:12 - Inspect queued on:  (Dibbs-Area52)", -- [284]
			"20:16:12 - Inspect! (Dravash-Area52) (Dravash) (Player-3676-080ABEE9) (true) (false)", -- [285]
			"20:16:12 - Inspect failed on:  (Dravash-Area52)", -- [286]
			"20:16:12 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (true)", -- [287]
			"20:16:12 - Inspect queued on:  (Phryke-Area52)", -- [288]
			"20:16:12 - Inspect! (Amrehlu-Area52) (Amrehlu) (Player-3676-088D21B8) (true) (false)", -- [289]
			"20:16:12 - Inspect failed on:  (Amrehlu-Area52)", -- [290]
			"20:16:17 - InspectHandler() (INSPECT_READY) (Player-3676-0964317D)", -- [291]
			"20:16:17 - InspectHandler() tried to inspect a non pooled guid: (Player-3676-0964317D)", -- [292]
			"20:16:19 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Dravash) (distri:) (WHISPER)", -- [293]
			"20:16:19 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [294]
			"20:16:19 - true = (IsCouncil) (Avernakis-Area52)", -- [295]
			"20:17:17 - ML event (PLAYER_REGEN_ENABLED)", -- [296]
			"20:17:19 - ML event (CHAT_MSG_LOOT) (Phryke receives loot: |cff9d9d9d|Hitem:132216::::::::110:105::::::|h[Charged Dust]|h|r.) () () () (Phryke) () (0) (0) () (0) (2316) (nil) (0) (false) (false) (false) (false)", -- [297]
			"20:18:17 - UpdateGroup (table: 000001AABA699CC0)", -- [298]
			"20:18:17 - ML:AddCandidate (Ahoyful-Area52) (PALADIN) (HEALER) (nil) (nil) (nil) (nil)", -- [299]
			"20:18:17 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Tuyen-Area52)", -- [300]
			"20:18:18 - GG:AddEntry(Update) (Ahoyful-Area52) (3)", -- [301]
			"20:18:18 - Comm received:^1^SplayerInfo^T^N1^SAhoyful-Area52^N2^SPALADIN^N3^SHEALER^N4^SSpud^N6^N0^N7^N912.375^N8^N65^t^^ (from:) (Ahoyful) (distri:) (WHISPER)", -- [302]
			"20:18:18 - ML:AddCandidate (Ahoyful-Area52) (PALADIN) (HEALER) (Spud) (nil) (0) (65)", -- [303]
			"20:18:18 - Comm received:^1^Scandidates^T^N1^T^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SVelynila-Area52^T^Srole^SDAMAGER^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SBoiled^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SSpud^t^SAhoyful-Area52^T^Srole^SHEALER^Sclass^SPALADIN^Srank^S^t^SDravash-Area52^T^Srole^SDAMAGER^SspecID^N251^Senchant_lvl^N0^Sclass^SDEATHKNIGHT^Srank^SBoiled^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SChauric-Area52^T^Srole^STANK^SspecID^N268^Senchant_lvl^N0^Sclass^SMONK^Srank^SStewed^t^SAmrehlu-Area52^T^Srole^SDAMAGER^SspecID^N255^Senchant_lvl^N0^Sclass^SHUNTER^Srank^SStewed^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^SDibbs-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [304]
			"20:18:18 - Inspect! (Velynila-Area52) (Velynila) (Player-3676-0950F86A) (true) (true)", -- [305]
			"20:18:18 - Inspect queued on:  (Velynila-Area52)", -- [306]
			"20:18:18 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (false)", -- [307]
			"20:18:18 - Inspect failed on:  (Lithelasha-Area52)", -- [308]
			"20:18:18 - Inspect! (Ahoyful-Area52) (Ahoyful) (Player-3676-0987CF67) (true) (false)", -- [309]
			"20:18:18 - Inspect failed on:  (Ahoyful-Area52)", -- [310]
			"20:18:18 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (true)", -- [311]
			"20:18:18 - Inspect queued on:  (Dibbs-Area52)", -- [312]
			"20:18:18 - Inspect! (Dravash-Area52) (Dravash) (Player-3676-080ABEE9) (true) (false)", -- [313]
			"20:18:18 - Inspect failed on:  (Dravash-Area52)", -- [314]
			"20:18:18 - Inspect! (Chauric-Area52) (Chauric) (Player-3676-08DA36E4) (true) (true)", -- [315]
			"20:18:18 - Inspect queued on:  (Chauric-Area52)", -- [316]
			"20:18:18 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (true)", -- [317]
			"20:18:18 - Inspect queued on:  (Phryke-Area52)", -- [318]
			"20:18:18 - Inspect! (Amrehlu-Area52) (Amrehlu) (Player-3676-088D21B8) (true) (false)", -- [319]
			"20:18:18 - Inspect failed on:  (Amrehlu-Area52)", -- [320]
			"20:18:22 - InspectHandler() (INSPECT_READY) (Player-3676-07E65081)", -- [321]
			"20:18:22 - InspectHandler() tried to inspect a non pooled guid: (Player-3676-07E65081)", -- [322]
			"20:18:26 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Ahoyful) (distri:) (WHISPER)", -- [323]
			"20:18:26 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [324]
			"20:18:26 - true = (IsCouncil) (Avernakis-Area52)", -- [325]
			"20:18:31 - ML event (PLAYER_REGEN_ENABLED)", -- [326]
			"20:20:52 - ML event (PLAYER_REGEN_ENABLED)", -- [327]
			"20:23:04 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Galastradra) (distri:) (GUILD)", -- [328]
			"20:23:37 - Comm received:^1^SverTest^T^N1^S2.7.1^t^^ (from:) (Sulana) (distri:) (GUILD)", -- [329]
			"20:24:05 - UpdateGroup (table: 000001AABA699CC0)", -- [330]
			"20:24:05 - ML:AddCandidate (Galastradra-Area52) (ROGUE) (DAMAGER) (nil) (nil) (nil) (nil)", -- [331]
			"20:24:05 - ML:AddCandidate (Sulana-Area52) (MONK) (HEALER) (nil) (nil) (nil) (nil)", -- [332]
			"20:24:05 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Galastradra-Area52) (Tuyen-Area52)", -- [333]
			"20:24:06 - GG:AddEntry (Sulana-Area52) (12)", -- [334]
			"20:24:06 - Comm received:^1^SplayerInfo^T^N1^SSulana-Area52^N2^SMONK^N3^SHEALER^N4^SBoiled^N6^N0^N7^N947.625^N8^N270^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [335]
			"20:24:06 - ML:AddCandidate (Sulana-Area52) (MONK) (HEALER) (Boiled) (nil) (0) (270)", -- [336]
			"20:24:06 - GG:AddEntry (Galastradra-Area52) (13)", -- [337]
			"20:24:06 - Comm received:^1^SplayerInfo^T^N1^SGalastradra-Area52^N2^SROGUE^N3^SDAMAGER^N4^STater~`Tot^N6^N0^N7^N946.9375^N8^N261^t^^ (from:) (Galastradra) (distri:) (WHISPER)", -- [338]
			"20:24:06 - ML:AddCandidate (Galastradra-Area52) (ROGUE) (DAMAGER) (Tater Tot) (nil) (0) (261)", -- [339]
			"20:24:09 - ML event (CHAT_MSG_LOOT) (You receive item: |cffa335ee|Hitem:152758::::::::110:105:::4:1693:3629:1472:3528:::|h[Arinor Keeper's Tunic of the Fireflash]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2379) (nil) (0) (false) (false) (false) (false)", -- [340]
			"20:24:11 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Galastradra) (distri:) (WHISPER)", -- [341]
			"20:24:11 - ML event (CHAT_MSG_LOOT) (You receive item: |cffa335ee|Hitem:152755::::::::110:105:::4:1718:3629:1477:3336:::|h[Arinor Keeper's Grips of the Decimator]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2380) (nil) (0) (false) (false) (false) (false)", -- [342]
			"20:24:15 - Comm received:^1^Scandidates^T^N1^T^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SChauric-Area52^T^Srole^STANK^SspecID^N268^Senchant_lvl^N0^Sclass^SMONK^Srank^SStewed^t^SGalastradra-Area52^T^Srole^SDAMAGER^Sclass^SROGUE^Srank^S^t^SVelynila-Area52^T^Srole^SDAMAGER^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SBoiled^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SSpud^t^SAhoyful-Area52^T^Srole^SHEALER^SspecID^N65^Senchant_lvl^N0^Sclass^SPALADIN^Srank^SSpud^t^SDravash-Area52^T^Srole^SDAMAGER^SspecID^N251^Senchant_lvl^N0^Sclass^SDEATHKNIGHT^Srank^SBoiled^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SSulana-Area52^T^Srole^SHEALER^Sclass^SMONK^Srank^S^t^SAmrehlu-Area52^T^Srole^SDAMAGER^SspecID^N255^Senchant_lvl^N0^Sclass^SHUNTER^Srank^SStewed^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^SDibbs-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [343]
			"20:24:15 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (true)", -- [344]
			"20:24:15 - Inspect queued on:  (Dibbs-Area52)", -- [345]
			"20:24:15 - Inspect! (Velynila-Area52) (Velynila) (Player-3676-0950F86A) (true) (true)", -- [346]
			"20:24:15 - Inspect queued on:  (Velynila-Area52)", -- [347]
			"20:24:15 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (true)", -- [348]
			"20:24:15 - Inspect queued on:  (Lithelasha-Area52)", -- [349]
			"20:24:15 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (true)", -- [350]
			"20:24:15 - Inspect queued on:  (Phryke-Area52)", -- [351]
			"20:24:15 - Inspect! (Ahoyful-Area52) (Ahoyful) (Player-3676-0987CF67) (true) (true)", -- [352]
			"20:24:15 - Inspect queued on:  (Ahoyful-Area52)", -- [353]
			"20:24:15 - Inspect! (Galastradra-Area52) (Galastradra) (Player-3676-09732AFE) (true) (false)", -- [354]
			"20:24:15 - Inspect failed on:  (Galastradra-Area52)", -- [355]
			"20:24:15 - Inspect! (Sulana-Area52) (Sulana) (Player-3676-088266F9) (true) (false)", -- [356]
			"20:24:15 - Inspect failed on:  (Sulana-Area52)", -- [357]
			"20:24:15 - Inspect! (Dravash-Area52) (Dravash) (Player-3676-080ABEE9) (true) (true)", -- [358]
			"20:24:15 - Inspect queued on:  (Dravash-Area52)", -- [359]
			"20:24:15 - Inspect! (Chauric-Area52) (Chauric) (Player-3676-08DA36E4) (true) (true)", -- [360]
			"20:24:15 - Inspect queued on:  (Chauric-Area52)", -- [361]
			"20:24:15 - Inspect! (Amrehlu-Area52) (Amrehlu) (Player-3676-088D21B8) (true) (true)", -- [362]
			"20:24:15 - Inspect queued on:  (Amrehlu-Area52)", -- [363]
			"20:24:16 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^SGalastradra-Area52^N4^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [364]
			"20:24:16 - true = (IsCouncil) (Avernakis-Area52)", -- [365]
			"20:24:16 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^SGalastradra-Area52^N4^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [366]
			"20:24:16 - true = (IsCouncil) (Avernakis-Area52)", -- [367]
			"20:24:17 - InspectHandler() (INSPECT_READY) (Player-3676-0987CF67)", -- [368]
			"20:24:17 - Successfully received specID for  (Ahoyful-Area52) (65)", -- [369]
			"20:24:17 - Comm received:^1^SMLdb_request^T^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [370]
			"20:24:17 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [371]
			"20:24:20 - ML event (CHAT_MSG_LOOT) (You receive item: |cffa335ee|Hitem:152759::::::::110:105:::4:1684:3629:1477:3336:::|h[Arinor Keeper's Headgear of the Peerless]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2382) (nil) (0) (false) (false) (false) (false)", -- [372]
			"20:24:20 - InspectHandler() (INSPECT_READY) (Player-3676-090665D9)", -- [373]
			"20:24:20 - InspectHandler() tried to inspect a non pooled guid: (Player-3676-090665D9)", -- [374]
			"20:24:21 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [375]
			"20:24:22 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^SGalastradra-Area52^N4^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [376]
			"20:24:22 - true = (IsCouncil) (Avernakis-Area52)", -- [377]
			"20:25:49 - ML event (TRADE_SHOW)", -- [378]
			"20:26:01 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cffffffff|Hitem:124440::::::::110:105::::::|h[Arkhana]|h|rx3.) () () () (Lesmes) () (0) (0) () (0) (2393) (nil) (0) (false) (false) (false) (false)", -- [379]
			"20:26:02 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cffffffff|Hitem:124440::::::::110:105::::::|h[Arkhana]|h|rx3.) () () () (Lesmes) () (0) (0) () (0) (2395) (nil) (0) (false) (false) (false) (false)", -- [380]
			"20:26:04 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cffffffff|Hitem:124440::::::::110:105::::::|h[Arkhana]|h|rx3.) () () () (Lesmes) () (0) (0) () (0) (2397) (nil) (0) (false) (false) (false) (false)", -- [381]
			"20:26:05 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cffffffff|Hitem:124440::::::::110:105::::::|h[Arkhana]|h|rx3.) () () () (Lesmes) () (0) (0) () (0) (2399) (nil) (0) (false) (false) (false) (false)", -- [382]
			"20:26:06 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cffffffff|Hitem:124440::::::::110:105::::::|h[Arkhana]|h|rx3.) () () () (Lesmes) () (0) (0) () (0) (2401) (nil) (0) (false) (false) (false) (false)", -- [383]
			"20:26:07 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cffffffff|Hitem:124440::::::::110:105::::::|h[Arkhana]|h|rx3.) () () () (Lesmes) () (0) (0) () (0) (2403) (nil) (0) (false) (false) (false) (false)", -- [384]
			"20:26:08 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cffffffff|Hitem:124440::::::::110:105::::::|h[Arkhana]|h|rx3.) () () () (Lesmes) () (0) (0) () (0) (2406) (nil) (0) (false) (false) (false) (false)", -- [385]
			"20:26:09 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cffffffff|Hitem:124440::::::::110:105::::::|h[Arkhana]|h|rx3.) () () () (Lesmes) () (0) (0) () (0) (2409) (nil) (0) (false) (false) (false) (false)", -- [386]
			"20:26:13 - ML event (TRADE_ACCEPT_UPDATE) (0) (1)", -- [387]
			"20:26:13 - ML event (TRADE_ACCEPT_UPDATE) (1) (1)", -- [388]
			"20:26:13 - ML event (TRADE_ACCEPT_UPDATE) (0) (1)", -- [389]
			"20:26:13 - ML event (TRADE_ACCEPT_UPDATE) (0) (0)", -- [390]
			"20:26:14 - ML event (TRADE_CLOSED)", -- [391]
			"20:26:14 - ML event (TRADE_CLOSED)", -- [392]
			"20:26:14 - ML event (UI_INFO_MESSAGE) (226) (Trade complete.)", -- [393]
			"20:26:37 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cff0070dd|Hitem:124441::::::::110:105::::::|h[Leylight Shard]|h|rx2.) () () () (Lesmes) () (0) (0) () (0) (2414) (nil) (0) (false) (false) (false) (false)", -- [394]
			"20:26:39 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cff0070dd|Hitem:124441::::::::110:105::::::|h[Leylight Shard]|h|rx2.) () () () (Lesmes) () (0) (0) () (0) (2416) (nil) (0) (false) (false) (false) (false)", -- [395]
			"20:26:40 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cff0070dd|Hitem:124441::::::::110:105::::::|h[Leylight Shard]|h|rx2.) () () () (Lesmes) () (0) (0) () (0) (2418) (nil) (0) (false) (false) (false) (false)", -- [396]
			"20:26:53 - ML event (CHAT_MSG_LOOT) (Lesmes receives loot: |cffa335ee|Hitem:124442::::::::110:105::::::|h[Chaos Crystal]|h|r.) () () () (Lesmes) () (0) (0) () (0) (2419) (nil) (0) (false) (false) (false) (false)", -- [397]
			"20:26:54 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:124442::::::::110:63::::::|h[Chaos~`Crystal]|h|r^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [398]
			"20:27:00 - ML event (CHAT_MSG_LOOT) (Lesmes receives loot: |cffa335ee|Hitem:124442::::::::110:105::::::|h[Chaos Crystal]|h|r.) () () () (Lesmes) () (0) (0) () (0) (2421) (nil) (0) (false) (false) (false) (false)", -- [399]
			"20:27:01 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:124442::::::::110:63::::::|h[Chaos~`Crystal]|h|r^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [400]
			"20:27:20 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2423) (nil) (0) (false) (false) (false) (false)", -- [401]
			"20:27:20 - ML event (CHAT_MSG_LOOT) (Phryke receives item: |cffffffff|Hitem:129032::::::::110:105::::::|h[Roseate Pigment]|h|rx8.) () () () (Phryke) () (0) (0) () (0) (2425) (nil) (0) (false) (false) (false) (false)", -- [402]
			"20:27:20 - ML event (CHAT_MSG_LOOT) (Phryke receives item: |cffffffff|Hitem:129034::::::::110:105::::::|h[Sallow Pigment]|h|r.) () () () (Phryke) () (0) (0) () (0) (2428) (nil) (0) (false) (false) (false) (false)", -- [403]
			"20:27:20 - ML event (CHAT_MSG_LOOT) (Phryke receives item: |cffffffff|Hitem:136926::::::::110:105::::::|h[Nightmare Pod]|h|r.) () () () (Phryke) () (0) (0) () (0) (2429) (nil) (0) (false) (false) (false) (false)", -- [404]
			"20:27:22 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2431) (nil) (0) (false) (false) (false) (false)", -- [405]
			"20:27:24 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2433) (nil) (0) (false) (false) (false) (false)", -- [406]
			"20:27:26 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2436) (nil) (0) (false) (false) (false) (false)", -- [407]
			"20:27:28 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2440) (nil) (0) (false) (false) (false) (false)", -- [408]
			"20:27:30 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2443) (nil) (0) (false) (false) (false) (false)", -- [409]
			"20:27:32 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2445) (nil) (0) (false) (false) (false) (false)", -- [410]
			"20:27:34 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2448) (nil) (0) (false) (false) (false) (false)", -- [411]
			"20:27:36 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2451) (nil) (0) (false) (false) (false) (false)", -- [412]
			"20:27:37 - ML event (CHAT_MSG_LOOT) (Phryke creates: |cffffffff|Hitem:141333::::::::110:105::::::|h[Codex of the Tranquil Mind]|h|r.) () () () (Phryke) () (0) (0) () (0) (2454) (nil) (0) (false) (false) (false) (false)", -- [413]
			"20:27:38 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2457) (nil) (0) (false) (false) (false) (false)", -- [414]
			"20:27:41 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2461) (nil) (0) (false) (false) (false) (false)", -- [415]
			"20:27:43 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2464) (nil) (0) (false) (false) (false) (false)", -- [416]
			"20:27:45 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2466) (nil) (0) (false) (false) (false) (false)", -- [417]
			"20:27:47 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2468) (nil) (0) (false) (false) (false) (false)", -- [418]
			"20:27:47 - ML event (CHAT_MSG_LOOT) (Phryke creates: |cffffffff|Hitem:141333::::::::110:105::::::|h[Codex of the Tranquil Mind]|h|r.) () () () (Phryke) () (0) (0) () (0) (2470) (nil) (0) (false) (false) (false) (false)", -- [419]
			"20:27:49 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2473) (nil) (0) (false) (false) (false) (false)", -- [420]
			"20:27:49 - ML event (CHAT_MSG_LOOT) (Phryke creates: |cffffffff|Hitem:141333::::::::110:105::::::|h[Codex of the Tranquil Mind]|h|r.) () () () (Phryke) () (0) (0) () (0) (2475) (nil) (0) (false) (false) (false) (false)", -- [421]
			"20:27:51 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2478) (nil) (0) (false) (false) (false) (false)", -- [422]
			"20:27:52 - ML event (CHAT_MSG_LOOT) (Phryke creates: |cffffffff|Hitem:141333::::::::110:105::::::|h[Codex of the Tranquil Mind]|h|r.) () () () (Phryke) () (0) (0) () (0) (2480) (nil) (0) (false) (false) (false) (false)", -- [423]
			"20:27:53 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2482) (nil) (0) (false) (false) (false) (false)", -- [424]
			"20:27:54 - ML event (CHAT_MSG_LOOT) (Phryke creates: |cff1eff00|Hitem:141446::::::::110:105::::::|h[Tome of the Tranquil Mind]|h|r.) () () () (Phryke) () (0) (0) () (0) (2484) (nil) (0) (false) (false) (false) (false)", -- [425]
			"20:27:55 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2486) (nil) (0) (false) (false) (false) (false)", -- [426]
			"20:27:55 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2487) (nil) (0) (false) (false) (false) (false)", -- [427]
			"20:27:56 - ML event (CHAT_MSG_LOOT) (Phryke creates: |cff1eff00|Hitem:141446::::::::110:105::::::|h[Tome of the Tranquil Mind]|h|r.) () () () (Phryke) () (0) (0) () (0) (2489) (nil) (0) (false) (false) (false) (false)", -- [428]
			"20:27:57 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2492) (nil) (0) (false) (false) (false) (false)", -- [429]
			"20:27:58 - ML event (CHAT_MSG_LOOT) (Phryke creates: |cff1eff00|Hitem:141446::::::::110:105::::::|h[Tome of the Tranquil Mind]|h|r.) () () () (Phryke) () (0) (0) () (0) (2494) (nil) (0) (false) (false) (false) (false)", -- [430]
			"20:27:59 - ML event (CHAT_MSG_LOOT) (Phryke creates: |cff1eff00|Hitem:141446::::::::110:105::::::|h[Tome of the Tranquil Mind]|h|r.) () () () (Phryke) () (0) (0) () (0) (2496) (nil) (0) (false) (false) (false) (false)", -- [431]
			"20:27:59 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2498) (nil) (0) (false) (false) (false) (false)", -- [432]
			"20:28:02 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2502) (nil) (0) (false) (false) (false) (false)", -- [433]
			"20:28:04 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2504) (nil) (0) (false) (false) (false) (false)", -- [434]
			"20:28:06 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2507) (nil) (0) (false) (false) (false) (false)", -- [435]
			"20:28:08 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2509) (nil) (0) (false) (false) (false) (false)", -- [436]
			"20:28:10 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2511) (nil) (0) (false) (false) (false) (false)", -- [437]
			"20:28:12 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx3.) () () () (Freakeer) () (0) (0) () (0) (2514) (nil) (0) (false) (false) (false) (false)", -- [438]
			"20:28:13 - ML event (CHAT_MSG_LOOT) (Phryke creates: |cffffffff|Hitem:128980::::::::110:105::::::|h[Scroll of Forgotten Knowledge]|h|r.) () () () (Phryke) () (0) (0) () (0) (2516) (nil) (0) (false) (false) (false) (false)", -- [439]
			"20:28:14 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2518) (nil) (0) (false) (false) (false) (false)", -- [440]
			"20:28:16 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2521) (nil) (0) (false) (false) (false) (false)", -- [441]
			"20:28:17 - ML event (CHAT_MSG_LOOT) (Phryke receives item: |cffffffff|Hitem:129032::::::::110:105::::::|h[Roseate Pigment]|h|rx26.) () () () (Phryke) () (0) (0) () (0) (2524) (nil) (0) (false) (false) (false) (false)", -- [442]
			"20:28:17 - ML event (CHAT_MSG_LOOT) (Phryke receives item: |cffffffff|Hitem:128304::::::::110:105::::::|h[Yseralline Seed]|h|rx2.) () () () (Phryke) () (0) (0) () (0) (2525) (nil) (0) (false) (false) (false) (false)", -- [443]
			"20:28:18 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2527) (nil) (0) (false) (false) (false) (false)", -- [444]
			"20:28:20 - ML event (CHAT_MSG_LOOT) (Phryke receives item: |cffffffff|Hitem:129034::::::::110:105::::::|h[Sallow Pigment]|h|rx2.) () () () (Phryke) () (0) (0) () (0) (2529) (nil) (0) (false) (false) (false) (false)", -- [445]
			"20:28:20 - ML event (CHAT_MSG_LOOT) (Phryke receives item: |cffffffff|Hitem:129032::::::::110:105::::::|h[Roseate Pigment]|h|rx2.) () () () (Phryke) () (0) (0) () (0) (2530) (nil) (0) (false) (false) (false) (false)", -- [446]
			"20:28:20 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2532) (nil) (0) (false) (false) (false) (false)", -- [447]
			"20:28:23 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2535) (nil) (0) (false) (false) (false) (false)", -- [448]
			"20:28:25 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2537) (nil) (0) (false) (false) (false) (false)", -- [449]
			"20:28:27 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2539) (nil) (0) (false) (false) (false) (false)", -- [450]
			"20:28:29 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2541) (nil) (0) (false) (false) (false) (false)", -- [451]
			"20:28:31 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2544) (nil) (0) (false) (false) (false) (false)", -- [452]
			"20:28:33 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2546) (nil) (0) (false) (false) (false) (false)", -- [453]
			"20:28:35 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2548) (nil) (0) (false) (false) (false) (false)", -- [454]
			"20:28:37 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2550) (nil) (0) (false) (false) (false) (false)", -- [455]
			"20:28:39 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2552) (nil) (0) (false) (false) (false) (false)", -- [456]
			"20:28:41 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2554) (nil) (0) (false) (false) (false) (false)", -- [457]
			"20:28:43 - UpdateGroup (table: 000001AABA699CC0)", -- [458]
			"20:28:43 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2556) (nil) (0) (false) (false) (false) (false)", -- [459]
			"20:28:46 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2558) (nil) (0) (false) (false) (false) (false)", -- [460]
			"20:28:48 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2560) (nil) (0) (false) (false) (false) (false)", -- [461]
			"20:28:50 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2562) (nil) (0) (false) (false) (false) (false)", -- [462]
			"20:28:52 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2564) (nil) (0) (false) (false) (false) (false)", -- [463]
			"20:28:53 - UpdateGroup (table: 000001AABA699CC0)", -- [464]
			"20:28:54 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2566) (nil) (0) (false) (false) (false) (false)", -- [465]
			"20:28:56 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2568) (nil) (0) (false) (false) (false) (false)", -- [466]
			"20:28:58 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2571) (nil) (0) (false) (false) (false) (false)", -- [467]
			"20:29:00 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2573) (nil) (0) (false) (false) (false) (false)", -- [468]
			"20:29:02 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2575) (nil) (0) (false) (false) (false) (false)", -- [469]
			"20:29:05 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2577) (nil) (0) (false) (false) (false) (false)", -- [470]
			"20:29:07 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2579) (nil) (0) (false) (false) (false) (false)", -- [471]
			"20:29:09 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx3.) () () () (Freakeer) () (0) (0) () (0) (2581) (nil) (0) (false) (false) (false) (false)", -- [472]
			"20:29:11 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2583) (nil) (0) (false) (false) (false) (false)", -- [473]
			"20:29:13 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2585) (nil) (0) (false) (false) (false) (false)", -- [474]
			"20:29:14 - UpdateGroup (table: 000001AABA699CC0)", -- [475]
			"20:29:15 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2587) (nil) (0) (false) (false) (false) (false)", -- [476]
			"20:29:17 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2590) (nil) (0) (false) (false) (false) (false)", -- [477]
			"20:29:19 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2592) (nil) (0) (false) (false) (false) (false)", -- [478]
			"20:29:21 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2594) (nil) (0) (false) (false) (false) (false)", -- [479]
			"20:29:23 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:127844::::::::110:105::::::|h[Potion of the Old War]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2596) (nil) (0) (false) (false) (false) (false)", -- [480]
			"20:29:24 - UpdateGroup (table: 000001AABA699CC0)", -- [481]
			"20:30:41 - ML event (CHAT_MSG_LOOT) (You receive item: |cffa335ee|Hitem:152761::::::::110:105:::5:1716:3629:42:1472:3528:::|h[Arinor Keeper's Trousers of the Harmonious]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2612) (nil) (0) (false) (false) (false) (false)", -- [482]
			"20:30:45 - ML event (CHAT_MSG_LOOT) (You receive item: |cffa335ee|Hitem:152757::::::::110:105:::4:1703:3629:1487:3337:::|h[Arinor Keeper's Treads of the Feverflare]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2613) (nil) (0) (false) (false) (false) (false)", -- [483]
			"20:32:14 - ML event (TRADE_SHOW)", -- [484]
			"20:32:19 - ML event (TRADE_ACCEPT_UPDATE) (0) (1)", -- [485]
			"20:32:26 - ML event (TRADE_ACCEPT_UPDATE) (0) (0)", -- [486]
			"20:32:28 - ML event (TRADE_ACCEPT_UPDATE) (1) (0)", -- [487]
			"20:32:29 - ML event (TRADE_CLOSED)", -- [488]
			"20:32:29 - ML event (TRADE_CLOSED)", -- [489]
			"20:32:29 - ML event (UI_INFO_MESSAGE) (226) (Trade complete.)", -- [490]
			"20:32:49 - ML event (CHAT_MSG_LOOT) (You receive item: |cffffffff|Hitem:127858::::::::110:105::::::|h[Spirit Flask]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2642) (nil) (0) (false) (false) (false) (false)", -- [491]
			"20:32:53 - ML event (CHAT_MSG_LOOT) (You receive item: |cffffffff|Hitem:127858::::::::110:105::::::|h[Spirit Flask]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2644) (nil) (0) (false) (false) (false) (false)", -- [492]
			"20:32:56 - ML event (CHAT_MSG_LOOT) (You receive item: |cffffffff|Hitem:127858::::::::110:105::::::|h[Spirit Flask]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2645) (nil) (0) (false) (false) (false) (false)", -- [493]
			"12/08/17", -- [494]
			"20:34:38 - Logged In", -- [495]
			"20:34:38 - ML initialized!", -- [496]
			"20:34:38 - Using ExtraUtilities (0.6.1)", -- [497]
			"20:34:38 - EU:UpdateGuildInfo", -- [498]
			"20:34:38 - GroupGear (1.3.1) (enabled)", -- [499]
			"20:34:40 - Avernakis-Area52 (2.7.4) (nil)", -- [500]
			"20:34:40 - ActivateSkin (new_blue)", -- [501]
			"20:34:40 - UpdateFrame (RCGroupGearFrame)", -- [502]
			"20:34:40 - UpdateFrame (DefaultRCLootCouncilFrame)", -- [503]
			"20:34:40 - UpdateFrame (DefaultRCLootCouncilFrame)", -- [504]
			"20:35:01 - Event: (PLAYER_ENTERING_WORLD) (false) (true)", -- [505]
			"20:35:01 - GetML()", -- [506]
			"20:35:01 - LootMethod =  (master)", -- [507]
			"20:35:01 - Resetting council as we have a new ML!", -- [508]
			"20:35:01 - MasterLooter =  (Avernakis-Area52)", -- [509]
			"20:35:01 - GetCouncilInGroup (Avernakis-Area52)", -- [510]
			"20:35:01 - ML:NewML (Avernakis-Area52)", -- [511]
			"20:35:01 - UpdateMLdb", -- [512]
			"20:35:01 - UpdateGroup (true)", -- [513]
			"20:35:01 - ML:AddCandidate (Avernakis-Area52) (DRUID) (HEALER) (nil) (nil) (nil) (nil)", -- [514]
			"20:35:01 - ML:AddCandidate (Tuyen-Area52) (PALADIN) (TANK) (nil) (nil) (nil) (nil)", -- [515]
			"20:35:01 - ML:AddCandidate (Lesmes-Area52) (MAGE) (DAMAGER) (nil) (nil) (nil) (nil)", -- [516]
			"20:35:01 - ML:AddCandidate (Sulana-Area52) (MONK) (HEALER) (nil) (nil) (nil) (nil)", -- [517]
			"20:35:01 - ML:AddCandidate (Ahoyful-Area52) (PALADIN) (HEALER) (nil) (nil) (nil) (nil)", -- [518]
			"20:35:01 - ML:AddCandidate (Lithelasha-Area52) (DEMONHUNTER) (DAMAGER) (nil) (nil) (nil) (nil)", -- [519]
			"20:35:01 - ML:AddCandidate (Dravash-Area52) (DEATHKNIGHT) (DAMAGER) (nil) (nil) (nil) (nil)", -- [520]
			"20:35:01 - ML:AddCandidate (Velynila-Area52) (DEMONHUNTER) (DAMAGER) (nil) (nil) (nil) (nil)", -- [521]
			"20:35:01 - ML:AddCandidate (Galastradra-Area52) (ROGUE) (DAMAGER) (nil) (nil) (nil) (nil)", -- [522]
			"20:35:01 - ML:AddCandidate (Chauric-Area52) (MONK) (TANK) (nil) (nil) (nil) (nil)", -- [523]
			"20:35:01 - ML:AddCandidate (Phryke-Area52) (WARLOCK) (DAMAGER) (nil) (nil) (nil) (nil)", -- [524]
			"20:35:01 - ML:AddCandidate (Dibbs-Area52) (SHAMAN) (DAMAGER) (nil) (nil) (nil) (nil)", -- [525]
			"20:35:01 - ML:AddCandidate (Amrehlu-Area52) (HUNTER) (DAMAGER) (nil) (nil) (nil) (nil)", -- [526]
			"20:35:01 - ML:AddCandidate (Freakeer-Area52) (SHAMAN) (DAMAGER) (nil) (nil) (nil) (nil)", -- [527]
			"20:35:01 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Galastradra-Area52) (Tuyen-Area52)", -- [528]
			"20:35:01 - Start handle loot.", -- [529]
			"20:35:01 - UpdatePlayersData()", -- [530]
			"20:35:03 - GetPlayersGuildRank()", -- [531]
			"20:35:03 - Found Guild Rank: Baked Potato", -- [532]
			"20:35:04 - Timer MLdb_check passed", -- [533]
			"20:35:05 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Avernakis) (distri:) (GUILD)", -- [534]
			"20:35:05 - Comm received:^1^SplayerInfoRequest^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [535]
			"20:35:05 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Avernakis) (distri:) (WHISPER)", -- [536]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^STuyen-Area52^N2^SPALADIN^N3^STANK^N4^STater~`Tot^N6^N0^N7^N945.4375^N8^N66^t^^ (from:) (Tuyen) (distri:) (WHISPER)", -- [537]
			"20:35:05 - GG:AddEntry (Tuyen-Area52) (1)", -- [538]
			"20:35:05 - ML:AddCandidate (Tuyen-Area52) (PALADIN) (TANK) (Tater Tot) (nil) (0) (66)", -- [539]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SAhoyful-Area52^N2^SPALADIN^N3^SHEALER^N4^SSpud^N6^N0^N7^N912.375^N8^N65^t^^ (from:) (Ahoyful) (distri:) (WHISPER)", -- [540]
			"20:35:05 - GG:AddEntry (Ahoyful-Area52) (2)", -- [541]
			"20:35:05 - ML:AddCandidate (Ahoyful-Area52) (PALADIN) (HEALER) (Spud) (nil) (0) (65)", -- [542]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SLithelasha-Area52^N2^SDEMONHUNTER^N3^SDAMAGER^N4^SStewed^N6^N0^N7^N942.5^N8^N577^t^^ (from:) (Lithelasha) (distri:) (WHISPER)", -- [543]
			"20:35:05 - GG:AddEntry (Lithelasha-Area52) (3)", -- [544]
			"20:35:05 - ML:AddCandidate (Lithelasha-Area52) (DEMONHUNTER) (DAMAGER) (Stewed) (nil) (0) (577)", -- [545]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SVelynila-Area52^N2^SDEMONHUNTER^N3^SDAMAGER^N4^SBoiled^N6^N0^N7^N929.5^N8^N581^t^^ (from:) (Velynila) (distri:) (WHISPER)", -- [546]
			"20:35:05 - GG:AddEntry (Velynila-Area52) (4)", -- [547]
			"20:35:05 - ML:AddCandidate (Velynila-Area52) (DEMONHUNTER) (DAMAGER) (Boiled) (nil) (0) (581)", -- [548]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SLesmes-Area52^N2^SMAGE^N3^SDAMAGER^N4^SStewed^N5^B^N6^N790^N7^N942.0625^N8^N63^t^^ (from:) (Lesmes) (distri:) (WHISPER)", -- [549]
			"20:35:05 - GG:AddEntry (Lesmes-Area52) (5)", -- [550]
			"20:35:05 - ML:AddCandidate (Lesmes-Area52) (MAGE) (DAMAGER) (Stewed) (true) (790) (63)", -- [551]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SFreakeer-Area52^N2^SSHAMAN^N3^SDAMAGER^N4^STater~`Salad^N6^N0^N7^N941.875^N8^N262^t^^ (from:) (Freakeer) (distri:) (WHISPER)", -- [552]
			"20:35:05 - GG:AddEntry (Freakeer-Area52) (6)", -- [553]
			"20:35:05 - ML:AddCandidate (Freakeer-Area52) (SHAMAN) (DAMAGER) (Tater Salad) (nil) (0) (262)", -- [554]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SAmrehlu-Area52^N2^SHUNTER^N3^SDAMAGER^N4^SStewed^N6^N0^N7^N941.625^N8^N255^t^^ (from:) (Amrehlu) (distri:) (WHISPER)", -- [555]
			"20:35:05 - GG:AddEntry (Amrehlu-Area52) (7)", -- [556]
			"20:35:05 - ML:AddCandidate (Amrehlu-Area52) (HUNTER) (DAMAGER) (Stewed) (nil) (0) (255)", -- [557]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SGalastradra-Area52^N2^SROGUE^N3^SDAMAGER^N4^STater~`Tot^N6^N0^N7^N946.9375^N8^N261^t^^ (from:) (Galastradra) (distri:) (WHISPER)", -- [558]
			"20:35:05 - GG:AddEntry (Galastradra-Area52) (8)", -- [559]
			"20:35:05 - ML:AddCandidate (Galastradra-Area52) (ROGUE) (DAMAGER) (Tater Tot) (nil) (0) (261)", -- [560]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SSulana-Area52^N2^SMONK^N3^SHEALER^N4^SBoiled^N6^N0^N7^N947.625^N8^N270^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [561]
			"20:35:05 - GG:AddEntry (Sulana-Area52) (9)", -- [562]
			"20:35:05 - ML:AddCandidate (Sulana-Area52) (MONK) (HEALER) (Boiled) (nil) (0) (270)", -- [563]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SDibbs-Area52^N2^SSHAMAN^N3^SDAMAGER^N4^SStewed^N6^N0^N7^N939.4375^N8^N262^t^^ (from:) (Dibbs) (distri:) (WHISPER)", -- [564]
			"20:35:05 - GG:AddEntry (Dibbs-Area52) (10)", -- [565]
			"20:35:05 - ML:AddCandidate (Dibbs-Area52) (SHAMAN) (DAMAGER) (Stewed) (nil) (0) (262)", -- [566]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SPhryke-Area52^N2^SWARLOCK^N3^SDAMAGER^N4^SBoiled^N6^N0^N7^N935.5625^N8^N265^t^^ (from:) (Phryke) (distri:) (WHISPER)", -- [567]
			"20:35:05 - GG:AddEntry (Phryke-Area52) (11)", -- [568]
			"20:35:05 - ML:AddCandidate (Phryke-Area52) (WARLOCK) (DAMAGER) (Boiled) (nil) (0) (265)", -- [569]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SDravash-Area52^N2^SDEATHKNIGHT^N3^SDAMAGER^N4^SBoiled^N6^N0^N7^N945.375^N8^N251^t^^ (from:) (Dravash) (distri:) (WHISPER)", -- [570]
			"20:35:05 - GG:AddEntry (Dravash-Area52) (12)", -- [571]
			"20:35:05 - ML:AddCandidate (Dravash-Area52) (DEATHKNIGHT) (DAMAGER) (Boiled) (nil) (0) (251)", -- [572]
			"20:35:05 - Comm received:^1^SplayerInfo^T^N1^SChauric-Area52^N2^SMONK^N3^STANK^N4^SStewed^N6^N0^N7^N938.5625^N8^N268^t^^ (from:) (Chauric) (distri:) (WHISPER)", -- [573]
			"20:35:05 - GG:AddEntry (Chauric-Area52) (13)", -- [574]
			"20:35:05 - ML:AddCandidate (Chauric-Area52) (MONK) (TANK) (Stewed) (nil) (0) (268)", -- [575]
			"20:35:05 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [576]
			"20:35:07 - Comm received:^1^SplayerInfo^T^N1^SAvernakis-Area52^N2^SDRUID^N3^SHEALER^N4^SBaked~`Potato^N6^N0^N7^N942.375^N8^N105^t^^ (from:) (Avernakis) (distri:) (WHISPER)", -- [577]
			"20:35:07 - ML:AddCandidate (Avernakis-Area52) (DRUID) (HEALER) (Baked Potato) (nil) (0) (105)", -- [578]
			"20:35:13 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^Sclass^SDRUID^Srank^S^t^STuyen-Area52^T^Srole^STANK^Sclass^SPALADIN^Srank^S^t^SFreakeer-Area52^T^Srole^SDAMAGER^Sclass^SSHAMAN^Srank^S^t^SAmrehlu-Area52^T^Srole^SDAMAGER^Sclass^SHUNTER^Srank^S^t^SVelynila-Area52^T^Srole^SDAMAGER^Sclass^SDEMONHUNTER^Srank^S^t^SLithelasha-Area52^T^Srole^SDAMAGER^Sclass^SDEMONHUNTER^Srank^S^t^SAhoyful-Area52^T^Srole^SHEALER^Sclass^SPALADIN^Srank^S^t^SDravash-Area52^T^Srole^SDAMAGER^Sclass^SDEATHKNIGHT^Srank^S^t^SPhryke-Area52^T^Srole^SDAMAGER^Sclass^SWARLOCK^Srank^S^t^SGalastradra-Area52^T^Srole^SDAMAGER^Sclass^SROGUE^Srank^S^t^SSulana-Area52^T^Srole^SHEALER^Sclass^SMONK^Srank^S^t^SChauric-Area52^T^Srole^STANK^Sclass^SMONK^Srank^S^t^SLesmes-Area52^T^Srole^SDAMAGER^Sclass^SMAGE^Srank^S^t^SDibbs-Area52^T^Srole^SDAMAGER^Sclass^SSHAMAN^Srank^S^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [579]
			"20:35:13 - Inspect! (Avernakis-Area52) (Avernakis) (Player-3676-090665D9) (true) (true)", -- [580]
			"20:35:13 - Inspect queued on:  (Avernakis-Area52)", -- [581]
			"20:35:13 - Inspect! (Tuyen-Area52) (Tuyen) (Player-3676-06DD54E2) (true) (true)", -- [582]
			"20:35:13 - Inspect queued on:  (Tuyen-Area52)", -- [583]
			"20:35:13 - Inspect! (Dibbs-Area52) (Dibbs) (Player-3676-06F009BD) (true) (true)", -- [584]
			"20:35:13 - Inspect queued on:  (Dibbs-Area52)", -- [585]
			"20:35:13 - Inspect! (Lesmes-Area52) (Lesmes) (Player-3676-0964317D) (true) (true)", -- [586]
			"20:35:13 - Inspect queued on:  (Lesmes-Area52)", -- [587]
			"20:35:13 - Inspect! (Velynila-Area52) (Velynila) (Player-3676-0950F86A) (true) (true)", -- [588]
			"20:35:13 - Inspect queued on:  (Velynila-Area52)", -- [589]
			"20:35:13 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (true)", -- [590]
			"20:35:13 - Inspect queued on:  (Lithelasha-Area52)", -- [591]
			"20:35:13 - Inspect! (Ahoyful-Area52) (Ahoyful) (Player-3676-0987CF67) (true) (true)", -- [592]
			"20:35:13 - Inspect queued on:  (Ahoyful-Area52)", -- [593]
			"20:35:13 - Inspect! (Chauric-Area52) (Chauric) (Player-3676-08DA36E4) (true) (true)", -- [594]
			"20:35:13 - Inspect queued on:  (Chauric-Area52)", -- [595]
			"20:35:13 - Inspect! (Galastradra-Area52) (Galastradra) (Player-3676-09732AFE) (true) (true)", -- [596]
			"20:35:13 - Inspect queued on:  (Galastradra-Area52)", -- [597]
			"20:35:13 - Inspect! (Freakeer-Area52) (Freakeer) (Player-3676-07E65081) (true) (true)", -- [598]
			"20:35:13 - Inspect queued on:  (Freakeer-Area52)", -- [599]
			"20:35:13 - Inspect! (Sulana-Area52) (Sulana) (Player-3676-088266F9) (true) (true)", -- [600]
			"20:35:13 - Inspect queued on:  (Sulana-Area52)", -- [601]
			"20:35:13 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (true)", -- [602]
			"20:35:13 - Inspect queued on:  (Phryke-Area52)", -- [603]
			"20:35:13 - Inspect! (Dravash-Area52) (Dravash) (Player-3676-080ABEE9) (true) (true)", -- [604]
			"20:35:13 - Inspect queued on:  (Dravash-Area52)", -- [605]
			"20:35:13 - Inspect! (Amrehlu-Area52) (Amrehlu) (Player-3676-088D21B8) (true) (true)", -- [606]
			"20:35:13 - Inspect queued on:  (Amrehlu-Area52)", -- [607]
			"20:35:13 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^SGalastradra-Area52^N4^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [608]
			"20:35:13 - true = (IsCouncil) (Avernakis-Area52)", -- [609]
			"20:35:13 - GetLootDBStatistics()", -- [610]
			"20:35:13 - GetGuildRankNum()", -- [611]
			"20:35:13 - RCVotingFrame (enabled)", -- [612]
			"20:35:14 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^SGalastradra-Area52^N4^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [613]
			"20:35:14 - true = (IsCouncil) (Avernakis-Area52)", -- [614]
			"20:35:14 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^SGalastradra-Area52^N4^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [615]
			"20:35:14 - true = (IsCouncil) (Avernakis-Area52)", -- [616]
			"20:35:16 - InspectHandler() (INSPECT_READY) (Player-3676-06F009BD)", -- [617]
			"20:35:16 - Successfully received specID for  (Dibbs-Area52) (262)", -- [618]
			"20:35:16 - InspectHandler() (INSPECT_READY) (Player-3676-088D21B8)", -- [619]
			"20:35:16 - Successfully received specID for  (Amrehlu-Area52) (255)", -- [620]
			"20:35:17 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^Sclass^SDRUID^Srank^S^t^STuyen-Area52^T^Srole^STANK^Sclass^SPALADIN^Srank^S^t^SFreakeer-Area52^T^Srole^SDAMAGER^Sclass^SSHAMAN^Srank^S^t^SAmrehlu-Area52^T^Srole^SDAMAGER^Sclass^SHUNTER^Srank^S^t^SVelynila-Area52^T^Srole^SDAMAGER^Sclass^SDEMONHUNTER^Srank^S^t^SLithelasha-Area52^T^Srole^SDAMAGER^Sclass^SDEMONHUNTER^Srank^S^t^SAhoyful-Area52^T^Srole^SHEALER^Sclass^SPALADIN^Srank^S^t^SDravash-Area52^T^Srole^SDAMAGER^Sclass^SDEATHKNIGHT^Srank^S^t^SPhryke-Area52^T^Srole^SDAMAGER^Sclass^SWARLOCK^Srank^S^t^SGalastradra-Area52^T^Srole^SDAMAGER^Sclass^SROGUE^Srank^S^t^SSulana-Area52^T^Srole^SHEALER^Sclass^SMONK^Srank^S^t^SChauric-Area52^T^Srole^STANK^Sclass^SMONK^Srank^S^t^SLesmes-Area52^T^Srole^SDAMAGER^Sclass^SMAGE^Srank^S^t^SDibbs-Area52^T^Srole^SDAMAGER^Sclass^SSHAMAN^Srank^S^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [621]
			"20:35:17 - Inspect! (Avernakis-Area52) (Avernakis) (Player-3676-090665D9) (true) (true)", -- [622]
			"20:35:17 - Inspect queued on:  (Avernakis-Area52)", -- [623]
			"20:35:17 - Inspect! (Tuyen-Area52) (Tuyen) (Player-3676-06DD54E2) (true) (true)", -- [624]
			"20:35:17 - Inspect queued on:  (Tuyen-Area52)", -- [625]
			"20:35:17 - Inspect! (Lesmes-Area52) (Lesmes) (Player-3676-0964317D) (true) (true)", -- [626]
			"20:35:17 - Inspect queued on:  (Lesmes-Area52)", -- [627]
			"20:35:17 - Inspect! (Velynila-Area52) (Velynila) (Player-3676-0950F86A) (true) (true)", -- [628]
			"20:35:17 - Inspect queued on:  (Velynila-Area52)", -- [629]
			"20:35:17 - Inspect! (Lithelasha-Area52) (Lithelasha) (Player-3676-09295886) (true) (true)", -- [630]
			"20:35:17 - Inspect queued on:  (Lithelasha-Area52)", -- [631]
			"20:35:17 - Inspect! (Ahoyful-Area52) (Ahoyful) (Player-3676-0987CF67) (true) (true)", -- [632]
			"20:35:17 - Inspect queued on:  (Ahoyful-Area52)", -- [633]
			"20:35:17 - Inspect! (Chauric-Area52) (Chauric) (Player-3676-08DA36E4) (true) (true)", -- [634]
			"20:35:17 - Inspect queued on:  (Chauric-Area52)", -- [635]
			"20:35:17 - Inspect! (Galastradra-Area52) (Galastradra) (Player-3676-09732AFE) (true) (true)", -- [636]
			"20:35:17 - Inspect queued on:  (Galastradra-Area52)", -- [637]
			"20:35:17 - Inspect! (Freakeer-Area52) (Freakeer) (Player-3676-07E65081) (true) (true)", -- [638]
			"20:35:17 - Inspect queued on:  (Freakeer-Area52)", -- [639]
			"20:35:17 - Inspect! (Sulana-Area52) (Sulana) (Player-3676-088266F9) (true) (true)", -- [640]
			"20:35:17 - Inspect queued on:  (Sulana-Area52)", -- [641]
			"20:35:17 - Inspect! (Phryke-Area52) (Phryke) (Player-3676-08103BF8) (true) (true)", -- [642]
			"20:35:17 - Inspect queued on:  (Phryke-Area52)", -- [643]
			"20:35:17 - Inspect! (Dravash-Area52) (Dravash) (Player-3676-080ABEE9) (true) (true)", -- [644]
			"20:35:17 - Inspect queued on:  (Dravash-Area52)", -- [645]
			"20:35:17 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^SGalastradra-Area52^N4^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [646]
			"20:35:17 - true = (IsCouncil) (Avernakis-Area52)", -- [647]
			"20:35:24 - InspectHandler() (INSPECT_READY) (Player-3676-080ABEE9)", -- [648]
			"20:35:24 - Successfully received specID for  (Dravash-Area52) (252)", -- [649]
			"20:35:25 - InspectHandler() (INSPECT_READY) (Player-3676-0950F86A)", -- [650]
			"20:35:25 - Successfully received specID for  (Velynila-Area52) (577)", -- [651]
			"20:35:26 - InspectHandler() (INSPECT_READY) (Player-3676-09732AFE)", -- [652]
			"20:35:26 - Successfully received specID for  (Galastradra-Area52) (261)", -- [653]
			"20:35:27 - InspectHandler() (INSPECT_READY) (Player-3676-08DA36E4)", -- [654]
			"20:35:27 - Successfully received specID for  (Chauric-Area52) (268)", -- [655]
			"20:35:35 - InspectHandler() (INSPECT_READY) (Player-3676-0964317D)", -- [656]
			"20:35:35 - Successfully received specID for  (Lesmes-Area52) (63)", -- [657]
			"20:35:36 - InspectHandler() (INSPECT_READY) (Player-3676-088266F9)", -- [658]
			"20:35:36 - Successfully received specID for  (Sulana-Area52) (270)", -- [659]
			"20:35:36 - InspectHandler() (INSPECT_READY) (Player-3676-0987CF67)", -- [660]
			"20:35:36 - Successfully received specID for  (Ahoyful-Area52) (65)", -- [661]
			"20:35:37 - InspectHandler() (INSPECT_READY) (Player-3676-07E65081)", -- [662]
			"20:35:37 - Successfully received specID for  (Freakeer-Area52) (262)", -- [663]
			"20:35:45 - InspectHandler() (INSPECT_READY) (Player-3676-088D21B8)", -- [664]
			"20:35:45 - InspectHandler() tried to inspect a non pooled guid: (Player-3676-088D21B8)", -- [665]
			"20:36:17 - Event: (ENCOUNTER_START) (2076) (Garothi Worldbreaker) (14) (14)", -- [666]
			"20:36:17 - UpdatePlayersData()", -- [667]
			"20:40:37 - Event: (ENCOUNTER_END) (2076) (Garothi Worldbreaker) (14) (14) (1)", -- [668]
			"20:40:37 - ML event (CHAT_MSG_LOOT) (You receive item: |cff0070dd|Hitem:151556::::::::110:105:8388608:3::56:::|h[Spoils of the Triumphant]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2837) (nil) (0) (false) (false) (false) (false)", -- [669]
			"20:40:38 - ML event (PLAYER_REGEN_ENABLED)", -- [670]
			"20:41:00 - Event: (LOOT_OPENED) (1)", -- [671]
			"20:41:00 - CanWeLootItem (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r) (4) (true)", -- [672]
			"20:41:00 - ML:AddItem (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r) (false) (1) (nil)", -- [673]
			"20:41:00 - CanWeLootItem (|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r) (4) (true)", -- [674]
			"20:41:00 - ML:AddItem (|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r) (false) (2) (nil)", -- [675]
			"20:41:00 - CanWeLootItem (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r) (4) (true)", -- [676]
			"20:41:00 - ML:AddItem (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r) (false) (3) (nil)", -- [677]
			"20:41:00 - RCSessionFrame (enabled)", -- [678]
			"20:41:00 - ML:HookLootButton (1)", -- [679]
			"20:41:00 - ML:HookLootButton (2)", -- [680]
			"20:41:00 - ML:HookLootButton (3)", -- [681]
			"20:41:01 - ML:StartSession()", -- [682]
			"20:41:01 - ML:AnnounceItems()", -- [683]
			"20:41:01 - Comm received:^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_SHOULDER^Sgp^N530^Silvl^N930^Slink^S|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads~`of~`the~`Demonic~`Blitz]|h|r^Srelic^b^Stexture^N1627518^SsubType^SLeather^SlootSlot^N2^Sclasses^N4294967295^Sname^SShoulderpads~`of~`the~`Demonic~`Blitz^Sboe^b^Sawarded^b^Squality^N4^t^N2^T^SequipLoc^SINVTYPE_TRINKET^Sgp^N884^Silvl^N930^Slink^S|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Personnel~`Decimator]|h|r^Srelic^b^Stexture^N1373903^SsubType^SMiscellaneous^SlootSlot^N1^Sclasses^N4294967295^Sname^SPrototype~`Personnel~`Decimator^Sboe^b^Sawarded^b^Squality^N4^t^N3^T^SequipLoc^SINVTYPE_TRINKET^Sgp^N884^Silvl^N930^Slink^S|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Personnel~`Decimator]|h|r^Srelic^b^Stexture^N1373903^SsubType^SMiscellaneous^SlootSlot^N3^Sclasses^N4294967295^Sname^SPrototype~`Personnel~`Decimator^Sboe^b^Sawarded^b^Squality^N4^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [684]
			"20:41:01 - SwitchSession (1)", -- [685]
			"20:41:01 - SwitchSession (1)", -- [686]
			"20:41:01 - GetPlayersGear (|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r) (INVTYPE_SHOULDER)", -- [687]
			"20:41:01 - GetPlayersGear (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r) (INVTYPE_TRINKET)", -- [688]
			"20:41:01 - GetPlayersGear (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r) (INVTYPE_TRINKET)", -- [689]
			"20:41:01 - LootFrame (GetFrame())", -- [690]
			"20:41:01 - LootFrame:Start()", -- [691]
			"20:41:01 - Entry update error @ item: (nil)", -- [692]
			"20:41:01 - Entry update error @ item: (nil)", -- [693]
			"20:41:01 - GetPlayersGear (|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r) (INVTYPE_SHOULDER)", -- [694]
			"20:41:01 - GetPlayersGear (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r) (INVTYPE_TRINKET)", -- [695]
			"20:41:01 - GetPlayersGear (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r) (INVTYPE_TRINKET)", -- [696]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^N2^N10^N3^N10^t^Sgear1^T^N1^Sitem:147180:5929:::::::110:262::5:3:3562:1497:3528^N2^Sitem:134336::151580::::::110:262::43:5:3573:1808:604:1582:3336^N3^Sitem:134336::151580::::::110:262::43:5:3573:1808:604:1582:3336^t^Sgear2^T^N2^Sitem:147019::151580::::::110:262::5:4:3562:1808:1507:3528^N3^Sitem:147019::151580::::::110:262::5:4:3562:1808:1507:3528^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [697]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^SFreakeer-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N646.668^Snew^N716.911^t^N2^T^Sequipped^N554.653^Snew^N245.905^t^N3^T^Sequipped^N554.653^Snew^N245.905^t^t^SspecID^N262^Straits^N74^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [698]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N75951.42^Snew^N46282.67^t^N2^T^Sequipped^N16781.03^Snew^N19377.6^t^N3^T^Sequipped^N16781.03^Snew^N19377.6^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [699]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^t^Sdiff^T^N1^N-70^N2^N10^N3^N10^t^Sgear1^T^N1^Sitem:144279::::::::110:577:::2:1811:3630^N2^Sitem:151968::::::::110:577::3:3:3610:1477:3336^N3^Sitem:151968::::::::110:577::3:3:3610:1477:3336^t^Sgear2^T^N2^Sitem:147009::::::::110:577::5:3:3562:1502:3336^N3^Sitem:147009::::::::110:577::5:3:3562:1502:3336^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [700]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^SLesmes-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N57571.48^Snew^N0^t^N2^T^Sequipped^N239.926^Snew^N289.198^t^N3^T^Sequipped^N239.926^Snew^N289.198^t^t^SspecID^N63^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [701]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N912.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^N2^N65^N3^N65^t^Sgear1^T^N1^Sitem:137076::::::::110:65:::2:1811:3630^N2^Sitem:139322::::::::110:65::3:3:1807:1487:3337^N3^Sitem:139322::::::::110:65::3:3:1807:1487:3337^t^Sgear2^T^N2^Sitem:134336::::::::110:65::43:4:3573:604:1572:3528^N3^Sitem:134336::::::::110:65::43:4:3573:604:1572:3528^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [702]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^SGalastradra-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N74150.64^Snew^N63860.56^t^N2^T^Sequipped^N54032.08^Snew^N10005.6^t^N3^T^Sequipped^N54032.08^Snew^N10005.6^t^t^SspecID^N261^Straits^N75^Slegend^N2^Ssockets^N5^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [703]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^SLithelasha-Area52^N2^T^Sforged^N10^Spawn^T^N1^T^Sequipped^N92627.25^Snew^N57119.62^t^N2^T^Sequipped^N38955.84^Snew^N221.904^t^N3^T^Sequipped^N38955.84^Snew^N221.904^t^t^SspecID^N577^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [704]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^N2^N-10^N3^N-10^t^Sgear1^T^N1^Sitem:147150::::::::110:63::3:3:3561:1512:3337^N2^Sitem:154177::::::::110:63::3:2:3983:3985^N3^Sitem:154177::::::::110:63::3:2:3983:3985^t^Sgear2^T^N2^Sitem:151955::::::::110:63::3:3:3610:1487:3337^N3^Sitem:151955::::::::110:63::3:3:3610:1487:3337^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [705]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^SAmrehlu-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N775.521^Snew^N698.266^t^N2^T^Sequipped^N311.386^Snew^N311.386^t^N3^T^Sequipped^N311.386^Snew^N311.386^t^t^SspecID^N255^Straits^N68^Slegend^N2^Ssockets^N5^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [706]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^N2^N30^N3^N30^t^Sgear1^T^N1^Sitem:138336:5931:::::::110:105::3:3:3514:1512:3337^N2^Sitem:141482::::::::110:105::43:3:3573:1512:3337^N3^Sitem:141482::::::::110:105::43:3:3573:1512:3337^t^Sgear2^T^N2^Sitem:144258::::::::110:105:::2:3459:3630^N3^Sitem:144258::::::::110:105:::2:3459:3630^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [707]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^SDibbs-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N54533.54^Snew^N60457.08^t^N2^T^Sequipped^N49341.12^Snew^N245.905^t^N3^T^Sequipped^N49341.12^Snew^N245.905^t^t^SspecID^N262^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [708]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^t^Sdiff^T^N1^N-70^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:144279:5883:::::::110:577:::2:3459:3630^N2^Sitem:151190::::::::110:577::5:3:3562:1512:3336^N3^Sitem:151190::::::::110:577::5:3:3562:1512:3336^t^Sgear2^T^N2^Sitem:154174::::::::110:577::3:2:3983:3985^N3^Sitem:154174::::::::110:577::3:2:3983:3985^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [709]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^SPhryke-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N655.43^Snew^N0^t^N2^T^Sequipped^N264.494^Snew^N301.965^t^N3^T^Sequipped^N264.494^Snew^N301.965^t^t^SspecID^N265^Straits^N69^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [710]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N946.9375^N4^T^Sresponse^T^t^Sdiff^T^N1^N-20^N2^N5^N3^N5^t^Sgear1^T^N1^Sitem:151988:5929:::::::110:261::5:4:3611:40:1492:3336^N2^Sitem:142167::151584::::::110:261::16:4:3418:1808:1537:3336^N3^Sitem:142167::151584::::::110:261::16:4:3418:1808:1537:3336^t^Sgear2^T^N2^Sitem:154174::::::::110:261::3:2:3983:3984^N3^Sitem:154174::::::::110:261::3:2:3983:3984^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [711]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SSulana-Area52^t^^ (from:) (Sulana) (distri:) (RAID)", -- [712]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^SAvernakis-Area52^N2^T^Sforged^N11^Spawn^T^N1^T^Sequipped^N696.257^Snew^N764.16^t^N2^T^Sequipped^N757.793^Snew^N270.266^t^N3^T^Sequipped^N757.793^Snew^N270.266^t^t^SspecID^N105^Straits^N75^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [713]
			"20:41:01 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N-20^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151988::::::::110:270::5:3:3611:1492:3336:::|h[Shoulderpads~`of~`the~`Demonic~`Blitz]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [714]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SDibbs-Area52^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [715]
			"20:41:01 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sgear2^S|cffa335ee|Hitem:151607::::::::110:270::13:3:3609:601:3607:::|h[Astral~`Alchemist~`Stone]|h|r^Sdiff^N0^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151956::::::::110:270::5:3:3611:1487:3528:::|h[Garothi~`Feedback~`Conduit]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [716]
			"20:41:01 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sgear2^S|cffa335ee|Hitem:151607::::::::110:270::13:3:3609:601:3607:::|h[Astral~`Alchemist~`Stone]|h|r^Sdiff^N0^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151956::::::::110:270::5:3:3611:1487:3528:::|h[Garothi~`Feedback~`Conduit]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [717]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N255^N3^N941.625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-5^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:137321:5929:::::::110:255::35:3:3418:1587:3337^N2^Sitem:154174::::::::110:255::3:2:3983:3984^N3^Sitem:154174::::::::110:255::3:2:3983:3984^t^Sgear2^T^N2^Sitem:137459::::::::110:255::43:3:3573:1582:3337^N3^Sitem:137459::::::::110:255::43:3:3573:1582:3337^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [718]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N945.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N10^N2^N30^N3^N30^t^Sgear1^T^N1^Sitem:147162:5931:::::::110:66::5:3:3562:1502:3336^N2^Sitem:151974::::::::110:66::5:4:3611:1487:3528:3618^N3^Sitem:151974::::::::110:66::5:4:3611:1487:3528:3618^t^Sgear2^T^N2^Sitem:128711::::::::110:66::13:3:689:601:679^N3^Sitem:128711::::::::110:66::13:3:689:601:679^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [719]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N5^N2^N30^N3^N30^t^Sgear1^T^N1^Sitem:137360::::::::110:265::16:3:3510:1577:3528^N2^Sitem:142165::151584::::::110:265::35:4:3417:1808:1542:3337^N3^Sitem:142165::151584::::::110:265::35:4:3417:1808:1542:3337^t^Sgear2^T^N2^Sitem:147017::::::::110:265::3:3:3561:1482:3528^N3^Sitem:147017::::::::110:265::3:3:3561:1482:3528^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [720]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^STuyen-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N634.179^Snew^N541.615^t^N2^T^Sequipped^N98.274^Snew^N199.2^t^N3^T^Sequipped^N98.274^Snew^N199.2^t^t^SspecID^N66^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [721]
			"20:41:01 - Comm received:^1^SextraUtilData^T^N1^SDravash-Area52^N2^T^Sforged^N9^Spawn^T^t^SspecID^N252^Straits^N68^Slegend^N2^Ssockets^N6^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [722]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SDravash-Area52^t^^ (from:) (Dravash) (distri:) (RAID)", -- [723]
			"20:41:01 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^N2^N30^N3^N30^t^Sgear1^T^N1^Sitem:147156:5883:::::::110:268::5:3:3562:1497:3528^N2^Sitem:128711::::::::110:268::13:3:689:600:679^N3^Sitem:128711::::::::110:268::13:3:689:600:679^t^Sgear2^T^N2^Sitem:147024::::::::110:268::5:3:3562:1497:3528^N3^Sitem:147024::::::::110:268::5:3:3562:1497:3528^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [724]
			"20:41:02 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147180:5442:::::::110:262::5:3:3562:1497:3528:::|h[Pauldrons~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [725]
			"20:41:02 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sresponse^SAUTOPASS^Sdiff^N-20^SspecID^N252^Sgear1^S|cffa335ee|Hitem:134360:5929:::::::110:252::35:3:3534:1612:3337:::|h[Portalguard~`Shoulders]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [726]
			"20:41:03 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sgear2^S|cffa335ee|Hitem:144480::::::::110:262::35:3:3418:1592:3337:::|h[Dreadstone~`of~`Endless~`Shadows]|h|r^Sdiff^N-10^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147002::::::::110:262::5:3:3562:1527:3337:::|h[Charm~`of~`the~`Rising~`Tide]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [727]
			"20:41:03 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sgear2^S|cffa335ee|Hitem:147009::::::::110:252::5:3:3562:1502:3336:::|h[Infernal~`Cinders]|h|r^Sdiff^N10^SspecID^N252^Sgear1^S|cffa335ee|Hitem:151190::151580::::::110:252::5:4:3562:1808:1507:3528:::|h[Specter~`of~`Betrayal]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [728]
			"20:41:03 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sgear2^S|cffa335ee|Hitem:144480::::::::110:262::35:3:3418:1592:3337:::|h[Dreadstone~`of~`Endless~`Shadows]|h|r^Sdiff^N-10^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147002::::::::110:262::5:3:3562:1527:3337:::|h[Charm~`of~`the~`Rising~`Tide]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [729]
			"20:41:03 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sgear2^S|cffa335ee|Hitem:147009::::::::110:252::5:3:3562:1502:3336:::|h[Infernal~`Cinders]|h|r^Sdiff^N10^SspecID^N252^Sgear1^S|cffa335ee|Hitem:151190::151580::::::110:252::5:4:3562:1808:1507:3528:::|h[Specter~`of~`Betrayal]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [730]
			"20:41:06 - Comm received:^1^Sresponse^T^N1^N2^N2^SAhoyful-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [731]
			"20:41:06 - Comm received:^1^Sresponse^T^N1^N3^N2^SAhoyful-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [732]
			"20:41:07 - Comm received:^1^Sresponse^T^N1^N2^N2^SVelynila-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [733]
			"20:41:07 - Comm received:^1^Sresponse^T^N1^N3^N2^SVelynila-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [734]
			"20:41:08 - Comm received:^1^Sresponse^T^N1^N1^N2^SGalastradra-Area52^N3^T^Sresponse^N4^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [735]
			"20:41:09 - Comm received:^1^Sresponse^T^N1^N1^N2^SVelynila-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [736]
			"20:41:10 - Comm received:^1^SEUBonusRoll^T^N1^SAhoyful-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:65:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [737]
			"20:41:12 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Sresponse^N3^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [738]
			"20:41:12 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Sresponse^N3^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [739]
			"20:41:13 - LootFrame:Response (3) (Response:) (Offspec)", -- [740]
			"20:41:13 - SendResponse (group) (2) (3) (nil) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [741]
			"20:41:13 - SendResponse (group) (3) (3) (nil) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [742]
			"20:41:13 - Trashing entry: (2) (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r)", -- [743]
			"20:41:13 - Comm received:^1^Sresponse^T^N1^N2^N2^SAvernakis-Area52^N3^T^Sresponse^N3^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [744]
			"20:41:13 - Comm received:^1^Sresponse^T^N1^N3^N2^SAvernakis-Area52^N3^T^Sresponse^N3^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [745]
			"20:41:14 - Comm received:^1^Soffline_timer^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [746]
			"20:41:14 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [747]
			"20:41:18 - LootFrame:Response (4) (Response:) (Transmog)", -- [748]
			"20:41:18 - SendResponse (group) (1) (4) (nil) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [749]
			"20:41:18 - Trashing entry: (1) (|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r)", -- [750]
			"20:41:19 - Comm received:^1^Sresponse^T^N1^N1^N2^SAvernakis-Area52^N3^T^Sresponse^N4^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [751]
			"20:41:20 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [752]
			"20:41:20 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [753]
			"20:41:21 - Comm received:^1^Sresponse^T^N1^N2^N2^SPhryke-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [754]
			"20:41:21 - Comm received:^1^Sresponse^T^N1^N3^N2^SPhryke-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [755]
			"20:41:21 - Comm received:^1^Sresponse^T^N1^N2^N2^SGalastradra-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [756]
			"20:41:21 - Comm received:^1^Sresponse^T^N1^N3^N2^SGalastradra-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [757]
			"20:41:23 - SwitchSession (2)", -- [758]
			"20:41:23 - Comm received:^1^Sresponse^T^N1^N1^N2^SChauric-Area52^N3^T^Sresponse^N3^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [759]
			"20:41:23 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [760]
			"20:41:23 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [761]
			"20:41:24 - SwitchSession (3)", -- [762]
			"20:41:24 - Comm received:^1^Sresponse^T^N1^N1^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [763]
			"20:41:24 - Comm received:^1^Sresponse^T^N1^N2^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [764]
			"20:41:24 - Comm received:^1^Sresponse^T^N1^N3^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [765]
			"20:41:24 - SwitchSession (2)", -- [766]
			"20:41:25 - SwitchSession (1)", -- [767]
			"20:41:27 - SwitchSession (3)", -- [768]
			"20:41:28 - Comm received:^1^Sresponse^T^N1^N2^N2^SLesmes-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [769]
			"20:41:28 - Comm received:^1^Sresponse^T^N1^N3^N2^SLesmes-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [770]
			"20:41:29 - SwitchSession (2)", -- [771]
			"20:41:30 - Comm received:^1^Sresponse^T^N1^N2^N2^SChauric-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [772]
			"20:41:30 - Comm received:^1^Sresponse^T^N1^N3^N2^SChauric-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [773]
			"20:41:30 - SwitchSession (1)", -- [774]
			"20:41:33 - SwitchSession (2)", -- [775]
			"20:41:33 - Comm received:^1^Sresponse^T^N1^N2^N2^SFreakeer-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [776]
			"20:41:33 - Comm received:^1^Sresponse^T^N1^N3^N2^SFreakeer-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [777]
			"20:41:34 - Event: (LOOT_CLOSED)", -- [778]
			"20:41:38 - Event: (LOOT_OPENED) (1)", -- [779]
			"20:41:43 - Comm received:^1^Sresponse^T^N1^N2^N2^STuyen-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [780]
			"20:41:43 - Comm received:^1^Sresponse^T^N1^N3^N2^STuyen-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [781]
			"20:41:48 - Comm received:^1^Sresponse^T^N1^N2^N2^SAmrehlu-Area52^N3^T^Snote^SWould~`have~`to~`sim~`it~`for~`MM^Sresponse^N3^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [782]
			"20:41:48 - Comm received:^1^Sresponse^T^N1^N3^N2^SAmrehlu-Area52^N3^T^Snote^SWould~`have~`to~`sim~`it~`for~`MM^Sresponse^N3^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [783]
			"20:41:55 - SwitchSession (3)", -- [784]
			"20:41:56 - SwitchSession (2)", -- [785]
			"20:42:07 - ReannounceOrRequestRoll (function: 000001AAC2483370) (function: 000001AB1FC1D7B0) (true) (false) (false)", -- [786]
			"20:42:08 - Comm received:^1^Srolls^T^N1^N2^N2^T^SSulana-Area52^S^SAvernakis-Area52^S^SAmrehlu-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [787]
			"20:42:08 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^SINVTYPE_TRINKET^Silvl^N930^Slink^S|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Personnel~`Decimator]|h|r^SisRoll^B^Sclasses^N4294967295^Sname^SPrototype~`Personnel~`Decimator^SnoAutopass^b^Srelic^b^Ssession^N2^Stexture^N1373903^t^N2^T^SequipLoc^SINVTYPE_TRINKET^Silvl^N930^Slink^S|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Personnel~`Decimator]|h|r^SisRoll^B^Sclasses^N4294967295^Sname^SPrototype~`Personnel~`Decimator^SnoAutopass^b^Srelic^b^Ssession^N3^Stexture^N1373903^t^t^t^^ (from:) (Avernakis) (distri:) (WHISPER)", -- [788]
			"20:42:08 - GetPlayersGear (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r) (INVTYPE_TRINKET)", -- [789]
			"20:42:08 - GetPlayersGear (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r) (INVTYPE_TRINKET)", -- [790]
			"20:42:08 - LootFrame:ReRoll(#table) (2)", -- [791]
			"20:42:08 - LootFrame:Start()", -- [792]
			"20:42:08 - Entry update error @ item: (nil)", -- [793]
			"20:42:08 - Comm received:^1^Srolls^T^N1^N3^N2^T^SSulana-Area52^S^SAvernakis-Area52^S^SAmrehlu-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [794]
			"20:42:08 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N30^N2^N30^t^Sgear1^T^N1^Sitem:141482::::::::110:105::43:3:3573:1512:3337^N2^Sitem:141482::::::::110:105::43:3:3573:1512:3337^t^Sgear2^T^N1^Sitem:144258::::::::110:105:::2:3459:3630^N2^Sitem:144258::::::::110:105:::2:3459:3630^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [795]
			"20:42:08 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N255^N3^N941.625^N4^T^Sresponse^T^t^Sdiff^T^N1^N0^N2^N0^t^Sgear1^T^N1^Sitem:154174::::::::110:255::3:2:3983:3984^N2^Sitem:154174::::::::110:255::3:2:3983:3984^t^Sgear2^T^N1^Sitem:137459::::::::110:255::43:3:3573:1582:3337^N2^Sitem:137459::::::::110:255::43:3:3573:1582:3337^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [796]
			"20:42:08 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sgear2^S|cffa335ee|Hitem:151607::::::::110:270::13:3:3609:601:3607:::|h[Astral~`Alchemist~`Stone]|h|r^Sdiff^N0^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151956::::::::110:270::5:3:3611:1487:3528:::|h[Garothi~`Feedback~`Conduit]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [797]
			"20:42:08 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sgear2^S|cffa335ee|Hitem:151607::::::::110:270::13:3:3609:601:3607:::|h[Astral~`Alchemist~`Stone]|h|r^Sdiff^N0^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151956::::::::110:270::5:3:3611:1487:3528:::|h[Garothi~`Feedback~`Conduit]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [798]
			"20:42:10 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Sroll^N4^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [799]
			"20:42:10 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Sroll^N4^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [800]
			"20:42:12 - Comm received:^1^Sroll^T^N1^SAvernakis-Area52^N2^N90^N3^T^N1^N2^N2^N3^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [801]
			"20:42:12 - Trashing entry: (1) (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r)", -- [802]
			"20:42:20 - Comm received:^1^Sroll^T^N1^SAmrehlu-Area52^N2^N68^N3^T^N1^N2^N2^N3^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [803]
			"20:42:24 - SwitchSession (2)", -- [804]
			"20:42:28 - ML:Award (2) (Avernakis-Area52) (Offspec) (nil)", -- [805]
			"20:42:28 - GiveMasterLoot (1) (4)", -- [806]
			"20:42:28 - LootSlot (1)", -- [807]
			"20:42:28 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r)", -- [808]
			"20:42:28 - ML:TrackAndLogLoot()", -- [809]
			"20:42:28 - ML event (CHAT_MSG_LOOT) (You receive loot: |cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2865) (nil) (0) (false) (false) (false) (false)", -- [810]
			"20:42:28 - Comm received:^1^Shistory^T^N1^SAvernakis-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SDRUID^SgroupSize^N13^Sboss^SGarothi~`Worldbreaker^Stime^S20:42:28^SitemReplaced1^S|cffa335ee|Hitem:141482::::::::110:105::43:3:3573:1512:3337:::|h[Unstable~`Arcanocrystal]|h|r^Sid^S1512801748-0^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SOffspec^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Personnel~`Decimator]|h|r^SisAwardReason^b^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^SresponseID^N3^SitemReplaced2^S|cffff8000|Hitem:144258::::::::110:105:::2:3459:3630:::|h[Velen's~`Future~`Sight]|h|r^Svotes^N0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [811]
			"20:42:28 - Comm received:^1^Sawarded^T^N1^N2^N2^SAvernakis-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [812]
			"20:42:28 - SwitchSession (3)", -- [813]
			"20:42:29 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Personnel~`Decimator]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [814]
			"20:42:29 - GetLootDBStatistics()", -- [815]
			"20:42:30 - SwitchSession (3)", -- [816]
			"20:42:33 - ML:Award (3) (Amrehlu-Area52) (Offspec) (nil)", -- [817]
			"20:42:33 - GiveMasterLoot (3) (8)", -- [818]
			"20:42:33 - OnLootSlotCleared() (3) (|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r)", -- [819]
			"20:42:33 - ML:TrackAndLogLoot()", -- [820]
			"20:42:33 - ML event (CHAT_MSG_LOOT) (Amrehlu receives loot: |cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (2869) (nil) (0) (false) (false) (false) (false)", -- [821]
			"20:42:33 - Comm received:^1^Shistory^T^N1^SAmrehlu-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SHUNTER^SgroupSize^N13^Sboss^SGarothi~`Worldbreaker^Stime^S20:42:33^SitemReplaced1^S|cffa335ee|Hitem:154174::::::::110:105::3:2:3983:3984:::|h[Golganneth's~`Vitality]|h|r^Sid^S1512801753-1^Snote^SWould~`have~`to~`sim~`it~`for~`MM^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SOffspec^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Personnel~`Decimator]|h|r^SisAwardReason^b^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^SresponseID^N3^SitemReplaced2^S|cffa335ee|Hitem:137459::::::::110:105::43:3:3573:1582:3337:::|h[Chaos~`Talisman]|h|r^Svotes^N0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [822]
			"20:42:33 - Comm received:^1^Sawarded^T^N1^N3^N2^SAmrehlu-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [823]
			"20:42:33 - SwitchSession (3)", -- [824]
			"20:42:34 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Personnel~`Decimator]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [825]
			"20:42:34 - GetLootDBStatistics()", -- [826]
			"20:42:34 - SwitchSession (1)", -- [827]
			"20:42:48 - ReannounceOrRequestRoll (Chauric-Area52) (function: 000001A99E2AAF90) (true) (true) (false)", -- [828]
			"20:42:49 - Comm received:^1^Srolls^T^N1^N1^N2^T^SChauric-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [829]
			"20:42:49 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147156:5883:::::::110:268::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [830]
			"20:42:56 - ReannounceOrRequestRoll (function: 000001AB134C4160) (function: 000001AACF8A0A20) (true) (false) (false)", -- [831]
			"20:42:56 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^SINVTYPE_SHOULDER^Silvl^N930^Slink^S|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads~`of~`the~`Demonic~`Blitz]|h|r^SisRoll^B^Sclasses^N4294967295^Sname^SShoulderpads~`of~`the~`Demonic~`Blitz^SnoAutopass^b^Srelic^b^Ssession^N1^Stexture^N1627518^t^t^t^^ (from:) (Avernakis) (distri:) (WHISPER)", -- [832]
			"20:42:56 - GetPlayersGear (|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r) (INVTYPE_SHOULDER)", -- [833]
			"20:42:56 - LootFrame:ReRoll(#table) (1)", -- [834]
			"20:42:56 - LootFrame:Start()", -- [835]
			"20:42:56 - Restoring entry: (roll) (1)", -- [836]
			"20:42:56 - Comm received:^1^Srolls^T^N1^N1^N2^T^SAvernakis-Area52^S^SGalastradra-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [837]
			"20:42:56 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N946.9375^N4^T^Sresponse^T^t^Sdiff^T^N1^N-20^t^Sgear1^T^N1^Sitem:151988:5929:::::::110:261::5:4:3611:40:1492:3336^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [838]
			"20:42:56 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:138336:5931:::::::110:105::3:3:3514:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [839]
			"20:42:59 - Comm received:^1^Sroll^T^N1^SGalastradra-Area52^N2^N18^N3^T^N1^N1^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [840]
			"20:43:01 - Comm received:^1^Sroll^T^N1^SAvernakis-Area52^N2^N71^N3^T^N1^N1^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [841]
			"20:43:02 - Trashing entry: (1) (|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r)", -- [842]
			"20:43:02 - Comm received:^1^Sroll^T^N1^SChauric-Area52^N2^N74^N3^T^N1^N1^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [843]
			"20:43:05 - ML event (CHAT_MSG_WHISPER) (Hey how was that, should I go back to frost or stay Unholy?) (Dravash-Area52) () () (Dravash) () (0) (0) () (0) (2882) (Player-3676-080ABEE9) (0) (false) (false) (false) (false)", -- [844]
			"20:43:08 - ML:Award (1) (Chauric-Area52) (Offspec) (nil)", -- [845]
			"20:43:08 - GiveMasterLoot (2) (2)", -- [846]
			"20:43:08 - OnLootSlotCleared() (2) (|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r)", -- [847]
			"20:43:08 - ML:TrackAndLogLoot()", -- [848]
			"20:43:08 - Event: (LOOT_CLOSED)", -- [849]
			"20:43:08 - Event: (LOOT_CLOSED)", -- [850]
			"20:43:08 - ML event (CHAT_MSG_LOOT) (Chauric receives loot: |cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r.) () () () (Chauric) () (0) (0) () (0) (2883) (nil) (0) (false) (false) (false) (false)", -- [851]
			"20:43:08 - Comm received:^1^Shistory^T^N1^SChauric-Area52^N2^T^Sid^S1512801788-2^SitemReplaced1^S|cffa335ee|Hitem:147156:5883:::::::110:105::5:3:3562:1497:3528:::|h[Xuen's~`Shoulderguards]|h|r^SmapID^N1712^SgroupSize^N13^Sdate^S08/12/17^Sclass^SMONK^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SOffspec^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Svotes^N0^Stime^S20:43:08^SisAwardReason^b^SlootWon^S|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads~`of~`the~`Demonic~`Blitz]|h|r^SresponseID^N3^Sboss^SGarothi~`Worldbreaker^SdifficultyID^N14^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [852]
			"20:43:08 - Comm received:^1^Sawarded^T^N1^N1^N2^SChauric-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [853]
			"20:43:08 - SwitchSession (2)", -- [854]
			"20:43:09 - ML:EndSession()", -- [855]
			"20:43:09 - Comm received:^1^Ssession_end^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [856]
			"20:43:09 - RCVotingFrame:EndSession (false)", -- [857]
			"20:43:09 - GetLootDBStatistics()", -- [858]
			"20:43:10 - Hide VotingFrame", -- [859]
			"20:44:50 - ML event (PLAYER_REGEN_ENABLED)", -- [860]
			"20:44:52 - ML event (CHAT_MSG_LOOT) (Galastradra receives loot: |cff9d9d9d|Hitem:132204::::::::110:105::::::|h[Sticky Volatile Substance]|h|r.) () () () (Galastradra) () (0) (0) () (0) (2890) (nil) (0) (false) (false) (false) (false)", -- [861]
			"20:44:55 - ML event (CHAT_MSG_LOOT) (Ahoyful receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|r.) () () () (Ahoyful) () (0) (0) () (0) (2891) (nil) (0) (false) (false) (false) (false)", -- [862]
			"20:45:01 - ML event (CHAT_MSG_WHISPER) (Ok I'll stick with Unholy this week) (Dravash-Area52) () () (Dravash) () (0) (0) () (0) (2893) (Player-3676-080ABEE9) (0) (false) (false) (false) (false)", -- [863]
			"20:47:03 - ML event (PLAYER_REGEN_ENABLED)", -- [864]
			"20:47:04 - ML event (CHAT_MSG_LOOT) (Velynila receives loot: |cffffffff|Hitem:151567::::::::110:105::::::|h[Lightweave Cloth]|h|rx3.) () () () (Velynila) () (0) (0) () (0) (2896) (nil) (0) (false) (false) (false) (false)", -- [865]
			"20:47:04 - ML event (CHAT_MSG_LOOT) (Galastradra receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|r.) () () () (Galastradra) () (0) (0) () (0) (2897) (nil) (0) (false) (false) (false) (false)", -- [866]
			"20:47:08 - ML event (CHAT_MSG_LOOT) (Phryke receives loot: |cff9d9d9d|Hitem:153075::::::::110:105::3::::|h[Ruined Krokul Hood]|h|r.) () () () (Phryke) () (0) (0) () (0) (2898) (nil) (0) (false) (false) (false) (false)", -- [867]
			"20:47:45 - Comm received:^1^SverTest^T^N1^S2.7.1^t^^ (from:) (Sulana) (distri:) (GUILD)", -- [868]
			"20:47:45 - Comm received:^1^SplayerInfo^T^N1^SSulana-Area52^N2^SMONK^N3^SHEALER^N4^SBoiled^N6^N0^N7^N947.625^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [869]
			"20:47:45 - GG:AddEntry(Update) (Sulana-Area52) (9)", -- [870]
			"20:47:45 - ML:AddCandidate (Sulana-Area52) (MONK) (HEALER) (Boiled) (nil) (0) (nil)", -- [871]
			"20:47:45 - Comm received:^1^Sreconnect^T^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [872]
			"20:47:45 - Responded to reconnect from (Sulana)", -- [873]
			"20:47:47 - ML event (PLAYER_REGEN_ENABLED)", -- [874]
			"20:47:48 - ML event (CHAT_MSG_LOOT) (Chauric receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|r.) () () () (Chauric) () (0) (0) () (0) (2899) (nil) (0) (false) (false) (false) (false)", -- [875]
			"20:47:48 - ML event (CHAT_MSG_LOOT) (Chauric receives loot: |cff9d9d9d|Hitem:132231::::::::110:105::::::|h[Worn Hooked Claw]|h|r.) () () () (Chauric) () (0) (0) () (0) (2900) (nil) (0) (false) (false) (false) (false)", -- [876]
			"20:47:48 - ML event (CHAT_MSG_LOOT) (Chauric receives loot: |cff9d9d9d|Hitem:132197::::::::110:105::::::|h[Fel Paw]|h|r.) () () () (Chauric) () (0) (0) () (0) (2901) (nil) (0) (false) (false) (false) (false)", -- [877]
			"20:47:49 - ML event (CHAT_MSG_LOOT) (Amrehlu receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (2902) (nil) (0) (false) (false) (false) (false)", -- [878]
			"20:47:51 - ML event (CHAT_MSG_LOOT) (Velynila receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|r.) () () () (Velynila) () (0) (0) () (0) (2903) (nil) (0) (false) (false) (false) (false)", -- [879]
			"20:47:52 - ML event (CHAT_MSG_LOOT) (Lithelasha receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|r.) () () () (Lithelasha) () (0) (0) () (0) (2904) (nil) (0) (false) (false) (false) (false)", -- [880]
			"20:47:52 - ML event (CHAT_MSG_LOOT) (Lithelasha receives loot: |cff9d9d9d|Hitem:132231::::::::110:105::::::|h[Worn Hooked Claw]|h|r.) () () () (Lithelasha) () (0) (0) () (0) (2905) (nil) (0) (false) (false) (false) (false)", -- [881]
			"20:47:53 - ML event (CHAT_MSG_LOOT) (Freakeer receives loot: |cff9d9d9d|Hitem:132197::::::::110:105::::::|h[Fel Paw]|h|rx2.) () () () (Freakeer) () (0) (0) () (0) (2906) (nil) (0) (false) (false) (false) (false)", -- [882]
			"20:48:20 - ML event (PLAYER_REGEN_ENABLED)", -- [883]
			"20:48:22 - ML event (CHAT_MSG_LOOT) (Lithelasha receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|r.) () () () (Lithelasha) () (0) (0) () (0) (2908) (nil) (0) (false) (false) (false) (false)", -- [884]
			"20:48:42 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Lesmes) () (0) (0) () (0) (2910) (nil) (0) (false) (false) (false) (false)", -- [885]
			"20:48:43 - ML event (CHAT_MSG_LOOT) (Freakeer creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Freakeer) () (0) (0) () (0) (2911) (nil) (0) (false) (false) (false) (false)", -- [886]
			"20:48:43 - ML event (CHAT_MSG_LOOT) (Lithelasha creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Lithelasha) () (0) (0) () (0) (2912) (nil) (0) (false) (false) (false) (false)", -- [887]
			"20:48:44 - ML event (CHAT_MSG_LOOT) (Galastradra creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Galastradra) () (0) (0) () (0) (2913) (nil) (0) (false) (false) (false) (false)", -- [888]
			"20:48:45 - ML event (CHAT_MSG_LOOT) (Velynila creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Velynila) () (0) (0) () (0) (2914) (nil) (0) (false) (false) (false) (false)", -- [889]
			"20:48:45 - ML event (CHAT_MSG_LOOT) (Amrehlu creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (2915) (nil) (0) (false) (false) (false) (false)", -- [890]
			"20:48:46 - ML event (CHAT_MSG_LOOT) (Sulana creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Sulana) () (0) (0) () (0) (2916) (nil) (0) (false) (false) (false) (false)", -- [891]
			"20:48:47 - ML event (CHAT_MSG_LOOT) (Tuyen creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Tuyen) () (0) (0) () (0) (2917) (nil) (0) (false) (false) (false) (false)", -- [892]
			"20:48:49 - ML event (CHAT_MSG_LOOT) (Dibbs creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Dibbs) () (0) (0) () (0) (2919) (nil) (0) (false) (false) (false) (false)", -- [893]
			"20:48:54 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Avernakis) () (0) (0) () (0) (2921) (nil) (0) (false) (false) (false) (false)", -- [894]
			"20:49:26 - ML event (CHAT_MSG_LOOT) (Ahoyful creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Ahoyful) () (0) (0) () (0) (2926) (nil) (0) (false) (false) (false) (false)", -- [895]
			"20:49:27 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Chauric) () (0) (0) () (0) (2927) (nil) (0) (false) (false) (false) (false)", -- [896]
			"20:51:38 - ML event (PLAYER_REGEN_ENABLED)", -- [897]
			"20:52:10 - Event: (ENCOUNTER_START) (2074) (Felhounds of Sargeras) (14) (14)", -- [898]
			"20:52:10 - UpdatePlayersData()", -- [899]
			"20:56:28 - Event: (ENCOUNTER_END) (2074) (Felhounds of Sargeras) (14) (14) (1)", -- [900]
			"20:56:28 - ML event (CHAT_MSG_LOOT) (You receive item: |cff0070dd|Hitem:151556::::::::110:105:8388608:3::56:::|h[Spoils of the Triumphant]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3106) (nil) (0) (false) (false) (false) (false)", -- [901]
			"20:56:29 - ML event (PLAYER_REGEN_ENABLED)", -- [902]
			"20:56:31 - Event: (LOOT_OPENED) (1)", -- [903]
			"20:56:31 - CanWeLootItem (|cffa335ee|Hitem:151980::::::::110:105::3:3:3610:1482:3336:::|h[Harness of Oppressing Dark]|h|r) (4) (true)", -- [904]
			"20:56:31 - ML:AddItem (|cffa335ee|Hitem:151980::::::::110:105::3:3:3610:1482:3336:::|h[Harness of Oppressing Dark]|h|r) (false) (1) (nil)", -- [905]
			"20:56:31 - CanWeLootItem (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1472:3528:::|h[Fraternal Fervor]|h|r) (4) (true)", -- [906]
			"20:56:31 - ML:AddItem (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1472:3528:::|h[Fraternal Fervor]|h|r) (false) (2) (nil)", -- [907]
			"20:56:31 - CanWeLootItem (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal Fervor]|h|r) (4) (true)", -- [908]
			"20:56:31 - ML:AddItem (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal Fervor]|h|r) (false) (3) (nil)", -- [909]
			"20:56:31 - RCSessionFrame (enabled)", -- [910]
			"20:56:33 - ML:StartSession()", -- [911]
			"20:56:33 - ML:AnnounceItems()", -- [912]
			"20:56:34 - Comm received:^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_CHEST^Sgp^N891^Silvl^N940^Slink^S|cffa335ee|Hitem:151980::::::::110:105::3:3:3610:1482:3336:::|h[Harness~`of~`Oppressing~`Dark]|h|r^Srelic^b^Stexture^N1626330^SsubType^SLeather^SlootSlot^N1^Sclasses^N4294967295^Sname^SHarness~`of~`Oppressing~`Dark^Sboe^b^Sawarded^b^Squality^N4^t^N2^T^SequipLoc^S^Sawarded^b^Slink^S|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal~`Fervor]|h|r^Srelic^SLife^Stexture^N459025^SsubType^SArtifact~`Relic^SlootSlot^N3^Sclasses^N4294967295^Sname^SFraternal~`Fervor^Sboe^b^Silvl^N950^Squality^N4^t^N3^T^SequipLoc^S^Sawarded^b^Slink^S|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1472:3528:::|h[Fraternal~`Fervor]|h|r^Srelic^SLife^Stexture^N459025^SsubType^SArtifact~`Relic^SlootSlot^N2^Sclasses^N4294967295^Sname^SFraternal~`Fervor^Sboe^b^Silvl^N930^Squality^N4^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [913]
			"20:56:34 - SwitchSession (1)", -- [914]
			"20:56:34 - SwitchSession (1)", -- [915]
			"20:56:34 - NewRelicAutopassCheck (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal Fervor]|h|r) (Life)", -- [916]
			"20:56:34 - NewRelicAutopassCheck (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1472:3528:::|h[Fraternal Fervor]|h|r) (Life)", -- [917]
			"20:56:34 - GetPlayersGear (|cffa335ee|Hitem:151980::::::::110:105::3:3:3610:1482:3336:::|h[Harness of Oppressing Dark]|h|r) (INVTYPE_CHEST)", -- [918]
			"20:56:34 - LootFrame:Start()", -- [919]
			"20:56:34 - Restoring entry: (normal) (2)", -- [920]
			"20:56:34 - Entry update error @ item: (nil)", -- [921]
			"20:56:34 - Entry update error @ item: (nil)", -- [922]
			"20:56:34 - GetPlayersGear (|cffa335ee|Hitem:151980::::::::110:105::3:3:3610:1482:3336:::|h[Harness of Oppressing Dark]|h|r) (INVTYPE_CHEST)", -- [923]
			"20:56:34 - GetPlayersGear (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal Fervor]|h|r) ()", -- [924]
			"20:56:34 - GetPlayersGear (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1472:3528:::|h[Fraternal Fervor]|h|r) ()", -- [925]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N52130.16^Snew^N814.178^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [926]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N35^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:147127::::::::110:577::3:3:3561:1487:3336^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [927]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SVelynila-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N55290.7^Snew^N939.555^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N70^Slegend^N2^Ssockets^N1^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [928]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SGalastradra-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N1295.304^Snew^N1047.347^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N261^Straits^N75^Slegend^N2^Ssockets^N5^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [929]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N10^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:152366::::::::110:262::3:4:3614:40:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [930]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SFreakeer-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N920.927^Snew^N1023.231^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N74^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [931]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SLesmes-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N870.89^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N63^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [932]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N5^N2^N35^N3^N15^t^Sgear1^T^N1^Sitem:142139::::::::110:105::35:3:3418:1552:3337^N2^Sitem:147106::::::::110:105::43:3:3573:1497:3336^N3^Sitem:147106::::::::110:105::43:3:3573:1497:3336^t^Sgear2^T^N2^Sitem:137478::::::::110:105::43:3:3573:1572:3336^N3^Sitem:137478::::::::110:105::43:3:3573:1572:3336^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [933]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N946.9375^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N-15^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:151982::151584::::::110:261::3:5:3610:1808:42:1487:3337^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [934]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SAvernakis-Area52^N2^T^Sforged^N11^Spawn^T^N1^T^Sequipped^N1077.613^Snew^N1114.984^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N105^Straits^N75^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [935]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.0625^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N25^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:147149::::::::110:63::3:3:3561:1497:3337^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [936]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SDibbs-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N72406^Snew^N1023.231^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [937]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SPhryke-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N783.612^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N265^Straits^N69^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [938]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SAmrehlu-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N1619.692^Snew^N989.123^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N253^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [939]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SDibbs-Area52^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [940]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SLithelasha-Area52^N2^T^Sforged^N10^Spawn^T^N1^T^Sequipped^N61479.23^Snew^N939.555^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [941]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-60^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:151805::::::::110:253:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [942]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N20^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:147127::::::::110:577::5:3:3562:1502:3336^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [943]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N30^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:134219::::::::110:265::16:3:3417:1572:3528^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [944]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^SDravash-Area52^N2^T^Sforged^N9^Spawn^T^t^SspecID^N252^Straits^N68^Slegend^N2^Ssockets^N6^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [945]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N945.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-5^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:152148::::::::110:66::3:3:3610:1487:3337^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [946]
			"20:56:34 - Comm received:^1^SextraUtilData^T^N1^STuyen-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N1076.543^Snew^N803.682^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N66^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [947]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SDravash-Area52^t^^ (from:) (Dravash) (distri:) (RAID)", -- [948]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SSulana-Area52^t^^ (from:) (Sulana) (distri:) (RAID)", -- [949]
			"20:56:34 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N-5^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151980::::::::110:270::5:3:3611:1487:3528:::|h[Harness~`of~`Oppressing~`Dark]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [950]
			"20:56:34 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N20^SspecID^N270^Sgear1^S|cffa335ee|Hitem:142309::::::::110:270::35:3:3417:1542:3337:::|h[Fauna~`Analysis~`Widget]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [951]
			"20:56:34 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N0^SspecID^N270^Sgear1^S|cffa335ee|Hitem:142309::::::::110:270::35:3:3417:1542:3337:::|h[Fauna~`Analysis~`Widget]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [952]
			"20:56:34 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N0^N2^N20^N3^N0^t^Sgear1^T^N1^Sitem:134438::::::::110:268::35:3:3418:1592:3337^N2^Sitem:152052::::::::110:268::3:3:3610:1472:3528^N3^Sitem:152052::::::::110:268::3:3:3610:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [953]
			"20:56:35 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^Sdiff^N25^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147175::151583::::::110:262::5:4:3562:1808:1497:3528:::|h[Harness~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [954]
			"20:56:35 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sresponse^SAUTOPASS^Sdiff^N-60^SspecID^N252^Sgear1^S|cffff8000|Hitem:151796::::::::110:252:::2:1811:3630:::|h[Cold~`Heart]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [955]
			"20:56:35 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^SspecID^N262^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [956]
			"20:56:35 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sresponse^SAUTOPASS^SspecID^N252^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [957]
			"20:56:36 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^SspecID^N262^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [958]
			"20:56:36 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sresponse^SAUTOPASS^SspecID^N252^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [959]
			"20:56:38 - Comm received:^1^SEUBonusRoll^T^N1^SGalastradra-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:261:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [960]
			"20:56:38 - Comm received:^1^Sresponse^T^N1^N3^N2^SFreakeer-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [961]
			"20:56:39 - Comm received:^1^Sresponse^T^N1^N2^N2^SFreakeer-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [962]
			"20:56:40 - Comm received:^1^Sresponse^T^N1^N1^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [963]
			"20:56:41 - Comm received:^1^Sresponse^T^N1^N1^N2^SVelynila-Area52^N3^T^Sresponse^N1^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [964]
			"20:56:42 - Comm received:^1^Sresponse^T^N1^N2^N2^STuyen-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [965]
			"20:56:43 - Comm received:^1^Sresponse^T^N1^N1^N2^SGalastradra-Area52^N3^T^Sresponse^N4^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [966]
			"20:56:43 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [967]
			"20:56:44 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [968]
			"20:56:44 - Comm received:^1^Sresponse^T^N1^N3^N2^STuyen-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [969]
			"20:56:47 - Comm received:^1^Soffline_timer^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [970]
			"20:56:47 - No response from: (Ahoyful-Area52)", -- [971]
			"20:56:47 - No response from: (Ahoyful-Area52)", -- [972]
			"20:56:47 - No response from: (Ahoyful-Area52)", -- [973]
			"20:56:51 - Comm received:^1^Sresponse^T^N1^N2^N2^SAmrehlu-Area52^N3^T^Snote^S+10~`ilvl^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [974]
			"20:57:08 - Comm received:^1^Sresponse^T^N1^N3^N2^SAmrehlu-Area52^N3^T^Snote^S+5~`ilvl^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [975]
			"20:57:09 - Comm received:^1^Sresponse^T^N1^N1^N2^SChauric-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [976]
			"20:57:10 - Comm received:^1^Sresponse^T^N1^N2^N2^SChauric-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [977]
			"20:57:11 - Comm received:^1^Sresponse^T^N1^N3^N2^SChauric-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [978]
			"20:57:12 - LootFrame:Response (1) (Response:) (Major Upgrade (4+ Trait Increase))", -- [979]
			"20:57:12 - SendResponse (group) (2) (1) (nil) (true) (Will have to SIM to be sure) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [980]
			"20:57:12 - Trashing entry: (2) (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal Fervor]|h|r)", -- [981]
			"20:57:12 - Comm received:^1^Sresponse^T^N1^N2^N2^SAvernakis-Area52^N3^T^Snote^SWill~`have~`to~`SIM~`to~`be~`sure^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [982]
			"20:57:25 - LootFrame:Response (1) (Response:) (Major Upgrade (4+ Trait Increase))", -- [983]
			"20:57:25 - SendResponse (group) (3) (1) (nil) (true) (Will have to SIM to be sure) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [984]
			"20:57:25 - Trashing entry: (2) (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1472:3528:::|h[Fraternal Fervor]|h|r)", -- [985]
			"20:57:25 - Comm received:^1^Sresponse^T^N1^N3^N2^SAvernakis-Area52^N3^T^Snote^SWill~`have~`to~`SIM~`to~`be~`sure^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [986]
			"20:57:28 - Comm received:^1^Svote^T^N1^N2^N2^SAvernakis-Area52^N3^N1^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [987]
			"20:57:28 - 1 = (IsCouncil) (Freakeer)", -- [988]
			"20:57:28 - LootFrame:Response (4) (Response:) (Transmog)", -- [989]
			"20:57:28 - SendResponse (group) (1) (4) (nil) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [990]
			"20:57:28 - Trashing entry: (1) (|cffa335ee|Hitem:151980::::::::110:105::3:3:3610:1482:3336:::|h[Harness of Oppressing Dark]|h|r)", -- [991]
			"20:57:28 - Comm received:^1^Sresponse^T^N1^N1^N2^SAvernakis-Area52^N3^T^Sresponse^N4^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [992]
			"20:57:29 - Comm received:^1^Svote^T^N1^N2^N2^SAvernakis-Area52^N3^N1^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [993]
			"20:57:29 - 1 = (IsCouncil) (Galastradra)", -- [994]
			"20:57:30 - Event: (LOOT_OPENED) (1)", -- [995]
			"20:57:31 - Comm received:^1^Svote^T^N1^N3^N2^SAmrehlu-Area52^N3^N1^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [996]
			"20:57:31 - 1 = (IsCouncil) (Freakeer)", -- [997]
			"20:57:35 - SwitchSession (2)", -- [998]
			"20:57:37 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [999]
			"20:57:37 - Comm received:^1^SEUBonusRoll^T^N1^SFreakeer-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:262:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1000]
			"20:57:45 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Sresponse^N3^SisRelic^B^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1001]
			"20:57:50 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1002]
			"20:58:09 - SwitchSession (3)", -- [1003]
			"20:58:26 - SwitchSession (2)", -- [1004]
			"20:58:29 - SwitchSession (3)", -- [1005]
			"20:58:32 - ML event (CHAT_MSG_LOOT) (Galastradra receives loot: |cff9d9d9d|Hitem:132204::::::::110:105::::::|h[Sticky Volatile Substance]|h|r.) () () () (Galastradra) () (0) (0) () (0) (3136) (nil) (0) (false) (false) (false) (false)", -- [1006]
			"20:58:32 - ML event (CHAT_MSG_LOOT) (Chauric receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|rx2.) () () () (Chauric) () (0) (0) () (0) (3137) (nil) (0) (false) (false) (false) (false)", -- [1007]
			"20:58:35 - ML event (CHAT_MSG_LOOT) (Freakeer receives loot: |cff9d9d9d|Hitem:132231::::::::110:105::::::|h[Worn Hooked Claw]|h|r.) () () () (Freakeer) () (0) (0) () (0) (3138) (nil) (0) (false) (false) (false) (false)", -- [1008]
			"20:58:35 - ML event (CHAT_MSG_LOOT) (Freakeer receives loot: |cff9d9d9d|Hitem:132197::::::::110:105::::::|h[Fel Paw]|h|r.) () () () (Freakeer) () (0) (0) () (0) (3139) (nil) (0) (false) (false) (false) (false)", -- [1009]
			"20:58:57 - Event: (LOOT_CLOSED)", -- [1010]
			"21:00:12 - SwitchSession (2)", -- [1011]
			"21:00:16 - SwitchSession (1)", -- [1012]
			"21:00:19 - Event: (LOOT_OPENED) (1)", -- [1013]
			"21:00:19 - lootSlot @session (3) (Was at:) (2) (is now at:) (1)", -- [1014]
			"21:00:19 - lootSlot @session (1) (Was at:) (1) (is now at:) (2)", -- [1015]
			"21:00:19 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Ahoyful) (distri:) (GUILD)", -- [1016]
			"21:00:22 - ML:Award (1) (Velynila-Area52) (Major Upgrade (10%+)) (nil)", -- [1017]
			"21:00:22 - GiveMasterLoot (2) (13)", -- [1018]
			"21:00:22 - OnLootSlotCleared() (2) (|cffa335ee|Hitem:151980::::::::110:105::3:3:3610:1482:3336:::|h[Harness of Oppressing Dark]|h|r)", -- [1019]
			"21:00:22 - ML:TrackAndLogLoot()", -- [1020]
			"21:00:22 - Comm received:^1^Shistory^T^N1^SVelynila-Area52^N2^T^Sid^S1512802822-3^SitemReplaced1^S|cffa335ee|Hitem:147127::::::::110:105::3:3:3561:1487:3336:::|h[Demonbane~`Harness]|h|r^SmapID^N1712^SgroupSize^N14^Sdate^S08/12/17^Sclass^SDEMONHUNTER^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SMajor~`Upgrade~`(10%+)^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Svotes^N0^Stime^S21:00:22^SisAwardReason^b^SlootWon^S|cffa335ee|Hitem:151980::::::::110:105::3:3:3610:1482:3336:::|h[Harness~`of~`Oppressing~`Dark]|h|r^SresponseID^N1^Sboss^SFelhounds~`of~`Sargeras^SdifficultyID^N14^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1021]
			"21:00:22 - Comm received:^1^Sawarded^T^N1^N1^N2^SVelynila-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1022]
			"21:00:22 - SwitchSession (2)", -- [1023]
			"21:00:23 - GetLootDBStatistics()", -- [1024]
			"21:00:27 - ML event (CHAT_MSG_LOOT) (Velynila receives loot: |cffa335ee|Hitem:151980::::::::110:105::3:3:3610:1482:3336:::|h[Harness of Oppressing Dark]|h|r.) () () () ()", -- [1025]
			"21:00:28 - UpdateGroup (table: 000001AAF56A0A00)", -- [1026]
			"21:00:32 - SwitchSession (1)", -- [1027]
			"21:00:34 - Comm received:^1^SMLdb_request^T^t^^ (from:) (Ahoyful) (distri:) (WHISPER)", -- [1028]
			"21:00:34 - Comm received:^1^Scouncil_request^T^t^^ (from:) (Ahoyful) (distri:) (WHISPER)", -- [1029]
			"21:00:35 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1030]
			"21:00:35 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^SGalastradra-Area52^N4^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1031]
			"21:00:35 - true = (IsCouncil) (Avernakis-Area52)", -- [1032]
			"21:00:45 - SwitchSession (2)", -- [1033]
			"21:00:56 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Ahoyful) (distri:) (GUILD)", -- [1034]
			"21:00:56 - Comm received:^1^SplayerInfo^T^N1^SAhoyful-Area52^N2^SPALADIN^N3^SHEALER^N4^SSpud^N6^N0^N7^N912.375^t^^ (from:) (Ahoyful) (distri:) (WHISPER)", -- [1035]
			"21:00:56 - GG:AddEntry(Update) (Ahoyful-Area52) (2)", -- [1036]
			"21:00:56 - ML:AddCandidate (Ahoyful-Area52) (PALADIN) (HEALER) (Spud) (nil) (0) (nil)", -- [1037]
			"21:00:56 - Comm received:^1^Sreconnect^T^t^^ (from:) (Ahoyful) (distri:) (WHISPER)", -- [1038]
			"21:00:56 - Responded to reconnect from (Ahoyful)", -- [1039]
			"21:01:04 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N637.21^Snew^N66607.88^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1040]
			"21:01:04 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N912.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N35^N2^N20^N3^N0^t^Sgear1^T^N1^Sitem:151576::::::::110:65::13:5:1685:3408:3609:600:3602^N2^Sitem:152051::::::::110:65::3:3:3610:1472:3528^N3^Sitem:152051::::::::110:65::3:3:3610:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1041]
			"21:01:09 - Comm received:^1^Sresponse^T^N1^N2^N2^SAhoyful-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1042]
			"21:01:12 - SwitchSession (3)", -- [1043]
			"21:01:12 - Comm received:^1^Sresponse^T^N1^N3^N2^SAhoyful-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1044]
			"21:01:14 - SwitchSession (2)", -- [1045]
			"21:01:19 - SwitchSession (3)", -- [1046]
			"21:01:42 - ReannounceOrRequestRoll (Sulana-Area52) (function: 000001AAC3D98A00) (true) (true) (false)", -- [1047]
			"21:01:42 - Comm received:^1^Srolls^T^N1^N3^N2^T^SSulana-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1048]
			"21:01:43 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N0^SspecID^N270^Sgear1^S|cffa335ee|Hitem:142309::::::::110:270::35:3:3417:1542:3337:::|h[Fauna~`Analysis~`Widget]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1049]
			"21:01:47 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Sroll^N25^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1050]
			"21:01:47 - ReannounceOrRequestRoll (Ahoyful-Area52) (function: 000001AB458E96F0) (true) (true) (false)", -- [1051]
			"21:01:47 - Comm received:^1^Srolls^T^N1^N3^N2^T^SAhoyful-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1052]
			"21:01:48 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N912.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N0^t^Sgear1^T^N1^Sitem:152051::::::::110:65::3:3:3610:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1053]
			"21:01:52 - Comm received:^1^Sroll^T^N1^SAhoyful-Area52^N2^N92^N3^T^N1^N3^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1054]
			"21:01:59 - ML:Award (3) (Ahoyful-Area52) (Major Upgrade (4+ Trait Increase)) (nil)", -- [1055]
			"21:01:59 - GiveMasterLoot (1) (10)", -- [1056]
			"21:01:59 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1472:3528:::|h[Fraternal Fervor]|h|r)", -- [1057]
			"21:01:59 - ML:TrackAndLogLoot()", -- [1058]
			"21:01:59 - Comm received:^1^Shistory^T^N1^SAhoyful-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SPALADIN^SgroupSize^N14^SisAwardReason^b^Stime^S21:01:59^SitemReplaced1^S|cffa335ee|Hitem:152051::::::::110:105::3:3:3610:1472:3528:::|h[Eidolon~`of~`Life]|h|r^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sid^S1512802919-4^Sresponse^SMajor~`Upgrade~`(4+~`Trait~`Increase)^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1472:3528:::|h[Fraternal~`Fervor]|h|r^SrelicRoll^B^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^SresponseID^N1^Sboss^SFelhounds~`of~`Sargeras^Svotes^N0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1059]
			"21:01:59 - Comm received:^1^Sawarded^T^N1^N3^N2^SAhoyful-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1060]
			"21:01:59 - SwitchSession (3)", -- [1061]
			"21:02:00 - GetLootDBStatistics()", -- [1062]
			"21:02:04 - ML event (CHAT_MSG_LOOT) (Ahoyful receives loot: |cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1472:3528:::|h[Fraternal Fervor]|h|r.) () () () ()", -- [1063]
			"21:02:42 - Event: (LOOT_CLOSED)", -- [1064]
			"21:02:45 - Event: (LOOT_OPENED) (1)", -- [1065]
			"21:02:45 - lootSlot @session (2) (Was at:) (3) (is now at:) (1)", -- [1066]
			"21:02:46 - ML event (CHAT_MSG_WHISPER) (sure thing) (Ahoyful-Area52) () () (Ahoyful) () (0) (0) () (0) (3165) (Player-3676-0987CF67) (0) (false) (false) (false) (false)", -- [1067]
			"21:02:58 - ML event (CHAT_MSG_WHISPER) (yeah in MM weapon, I selected off-spec right?) (Amrehlu-Area52) () () (Amrehlu) () (0) (0) () (0) (3166) (Player-3676-088D21B8) (0) (false) (false) (false) (false)", -- [1068]
			"21:03:31 - SwitchSession (2)", -- [1069]
			"21:03:34 - Event: (LOOT_OPENED) (1)", -- [1070]
			"21:03:41 - ReannounceOrRequestRoll (Sulana-Area52) (function: 000001AB49A6BDB0) (true) (true) (false)", -- [1071]
			"21:03:41 - Comm received:^1^Srolls^T^N1^N2^N2^T^SSulana-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1072]
			"21:03:42 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N20^SspecID^N270^Sgear1^S|cffa335ee|Hitem:142309::::::::110:270::35:3:3417:1542:3337:::|h[Fauna~`Analysis~`Widget]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1073]
			"21:03:43 - ML event (CHAT_MSG_WHISPER) (There were two so I probably fucked up on both in seperate ways) (Amrehlu-Area52) () () (Amrehlu) () (0) (0) () (0) (3173) (Player-3676-088D21B8) (0) (false) (false) (false) (false)", -- [1074]
			"21:03:44 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Sroll^N23^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1075]
			"21:03:46 - ReannounceOrRequestRoll (Avernakis-Area52) (function: 000001AB49AA9B30) (true) (true) (false)", -- [1076]
			"21:03:47 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^S^Silvl^N950^Slink^S|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal~`Fervor]|h|r^SisRoll^B^Sclasses^N4294967295^Sname^SFraternal~`Fervor^SnoAutopass^B^Srelic^SLife^Ssession^N2^Stexture^N459025^t^t^t^^ (from:) (Avernakis) (distri:) (WHISPER)", -- [1077]
			"21:03:47 - LootFrame:ReRoll(#table) (1)", -- [1078]
			"21:03:47 - LootFrame:Start()", -- [1079]
			"21:03:47 - Restoring entry: (roll) (1)", -- [1080]
			"21:03:47 - Comm received:^1^Srolls^T^N1^N2^N2^T^SAvernakis-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1081]
			"21:03:47 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N35^t^Sgear1^T^N1^Sitem:147106::::::::110:105::43:3:3573:1497:3336^t^Sgear2^T^N1^Sitem:137478::::::::110:105::43:3:3573:1572:3336^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1082]
			"21:03:49 - Comm received:^1^Sroll^T^N1^SAvernakis-Area52^N2^N75^N3^T^N1^N2^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1083]
			"21:03:49 - Trashing entry: (1) (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal Fervor]|h|r)", -- [1084]
			"21:03:54 - ML:Award (2) (Avernakis-Area52) (Major Upgrade (4+ Trait Increase)) (nil)", -- [1085]
			"21:03:54 - GiveMasterLoot (1) (5)", -- [1086]
			"21:03:54 - LootSlot (1)", -- [1087]
			"21:03:54 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal Fervor]|h|r)", -- [1088]
			"21:03:54 - ML:TrackAndLogLoot()", -- [1089]
			"21:03:54 - Event: (LOOT_CLOSED)", -- [1090]
			"21:03:54 - Event: (LOOT_CLOSED)", -- [1091]
			"21:03:54 - ML event (CHAT_MSG_LOOT) (You receive loot: |cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal Fervor]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3180) (nil) (0) (false) (false) (false) (false)", -- [1092]
			"21:03:55 - Comm received:^1^Shistory^T^N1^SAvernakis-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SDRUID^SgroupSize^N14^Sboss^SFelhounds~`of~`Sargeras^Stime^S21:03:54^SitemReplaced1^S|cffa335ee|Hitem:147106::::::::110:105::43:3:3573:1497:3336:::|h[Glowing~`Prayer~`Candle]|h|r^Sid^S1512803034-5^Snote^SWill~`have~`to~`SIM~`to~`be~`sure^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^SrelicRoll^B^Sresponse^SMajor~`Upgrade~`(4+~`Trait~`Increase)^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal~`Fervor]|h|r^SisAwardReason^b^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^SresponseID^N1^SitemReplaced2^S|cffa335ee|Hitem:137478::::::::110:105::43:3:3573:1572:3336:::|h[Reflection~`of~`Sorrow]|h|r^Svotes^N2^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1093]
			"21:03:55 - Comm received:^1^Sawarded^T^N1^N2^N2^SAvernakis-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1094]
			"21:03:55 - SwitchSession (3)", -- [1095]
			"21:03:55 - ML:EndSession()", -- [1096]
			"21:03:56 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal~`Fervor]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1097]
			"21:03:56 - Comm received:^1^Ssession_end^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1098]
			"21:03:56 - RCVotingFrame:EndSession (false)", -- [1099]
			"21:03:56 - GetLootDBStatistics()", -- [1100]
			"21:03:57 - Hide VotingFrame", -- [1101]
			"21:05:39 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:127845::::::::110:105::::::|h[Unbending Potion]|h|r.) () () () (Chauric) () (0) (0) () (0) (3194) (nil) (0) (false) (false) (false) (false)", -- [1102]
			"21:05:41 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:127845::::::::110:105::::::|h[Unbending Potion]|h|rx2.) () () () (Chauric) () (0) (0) () (0) (3196) (nil) (0) (false) (false) (false) (false)", -- [1103]
			"21:05:43 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:127845::::::::110:105::::::|h[Unbending Potion]|h|r.) () () () (Chauric) () (0) (0) () (0) (3198) (nil) (0) (false) (false) (false) (false)", -- [1104]
			"21:05:45 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:127845::::::::110:105::::::|h[Unbending Potion]|h|rx2.) () () () (Chauric) () (0) (0) () (0) (3200) (nil) (0) (false) (false) (false) (false)", -- [1105]
			"21:05:47 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:127845::::::::110:105::::::|h[Unbending Potion]|h|rx2.) () () () (Chauric) () (0) (0) () (0) (3202) (nil) (0) (false) (false) (false) (false)", -- [1106]
			"21:05:49 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:127845::::::::110:105::::::|h[Unbending Potion]|h|r.) () () () (Chauric) () (0) (0) () (0) (3204) (nil) (0) (false) (false) (false) (false)", -- [1107]
			"21:06:07 - ML event (CHAT_MSG_LOOT) (Dravash creates: |cffffffff|Hitem:142117::::::::110:105::::::|h[Potion of Prolonged Power]|h|rx11.) () () () (Dravash) () (0) (0) () (0) (3208) (nil) (0) (false) (false) (false) (false)", -- [1108]
			"21:08:39 - Event: (ENCOUNTER_START) (2070) (Antoran High Command) (14) (14)", -- [1109]
			"21:08:39 - UpdatePlayersData()", -- [1110]
			"21:14:34 - Event: (ENCOUNTER_END) (2070) (Antoran High Command) (14) (14) (1)", -- [1111]
			"21:14:34 - ML event (CHAT_MSG_LOOT) (You receive item: |cff0070dd|Hitem:151556::::::::110:105:8388608:3::56:::|h[Spoils of the Triumphant]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3333) (nil) (0) (false) (false) (false) (false)", -- [1112]
			"21:14:34 - ML event (UI_INFO_MESSAGE) (285) (Defeat the Antoran High Command in Antorus, The Burning Throne: 1/1)", -- [1113]
			"21:14:34 - ML event (UI_INFO_MESSAGE) (283) (Objective Complete.)", -- [1114]
			"21:14:34 - ML event (PLAYER_REGEN_ENABLED)", -- [1115]
			"21:14:36 - Comm received:^1^SEUBonusRoll^T^N1^SDibbs-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:262:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1116]
			"21:14:38 - Event: (LOOT_OPENED) (1)", -- [1117]
			"21:14:38 - CanWeLootItem (|cffa335ee|Hitem:152517::::::::110:105::3::::|h[Cloak of the Antoran Vanquisher]|h|r) (4) (true)", -- [1118]
			"21:14:38 - ML:AddItem (|cffa335ee|Hitem:152517::::::::110:105::3::::|h[Cloak of the Antoran Vanquisher]|h|r) (false) (1) (nil)", -- [1119]
			"21:14:38 - CanWeLootItem (|cffa335ee|Hitem:151985::::::::110:105::3:3:3610:1472:3528:::|h[General Erodus' Tricorne]|h|r) (4) (true)", -- [1120]
			"21:14:38 - ML:AddItem (|cffa335ee|Hitem:151985::::::::110:105::3:3:3610:1472:3528:::|h[General Erodus' Tricorne]|h|r) (false) (2) (nil)", -- [1121]
			"21:14:38 - CanWeLootItem (|cffa335ee|Hitem:151994::::::::110:105::3:4:3610:1808:1472:3528:::|h[Fleet Commander's Hauberk]|h|r) (4) (true)", -- [1122]
			"21:14:38 - ML:AddItem (|cffa335ee|Hitem:151994::::::::110:105::3:4:3610:1808:1472:3528:::|h[Fleet Commander's Hauberk]|h|r) (false) (3) (nil)", -- [1123]
			"21:14:38 - RCSessionFrame (enabled)", -- [1124]
			"21:14:43 - ML event (CHAT_MSG_LOOT) (Velynila receives bonus loot: |cffa335ee|Hitem:152032::::::::110:105::3:3:3610:1472:3528:::|h[Twisted Engineer's Fel-Infuser]|h|r.) () () () (Velynila) () (0) (0) () (0) (3343) (nil) (0) (false) (false) (false) (false)", -- [1125]
			"21:14:43 - Comm received:^1^SEUBonusRoll^T^N1^SVelynila-Area52^N2^Sitem^N3^S|cffa335ee|Hitem:152032::::::::110:577::3:3:3610:1472:3528:::|h[Twisted~`Engineer's~`Fel-Infuser]|h|r^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1126]
			"21:14:44 - Comm received:^1^SEUBonusRoll^T^N1^SLithelasha-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:577:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1127]
			"21:14:45 - ML:StartSession()", -- [1128]
			"21:14:45 - ML:AnnounceItems()", -- [1129]
			"21:14:45 - Comm received:^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_HEAD^Sgp^N707^Silvl^N930^Slink^S|cffa335ee|Hitem:151985::::::::110:105::3:3:3610:1472:3528:::|h[General~`Erodus'~`Tricorne]|h|r^Srelic^b^Stexture^N1627516^SsubType^SLeather^SlootSlot^N2^Sclasses^N4294967295^Sname^SGeneral~`Erodus'~`Tricorne^Sboe^b^Sawarded^b^Squality^N4^t^N2^T^SequipLoc^S^Sgp^N396^Silvl^N930^Slink^S|cffa335ee|Hitem:152517::::::::110:105::3::::|h[Cloak~`of~`the~`Antoran~`Vanquisher]|h|r^Stexture^N133772^SlootSlot^N1^SsubType^SJunk^Srelic^b^Sclasses^N1192^Sname^SCloak~`of~`the~`Antoran~`Vanquisher^Stoken^SBackSlot^Sboe^b^Sawarded^b^Squality^N4^t^N3^T^SequipLoc^SINVTYPE_CHEST^Sgp^N907^Silvl^N930^Slink^S|cffa335ee|Hitem:151994::::::::110:105::3:4:3610:1808:1472:3528:::|h[Fleet~`Commander's~`Hauberk]|h|r^Srelic^b^Stexture^N1547870^SsubType^SMail^SlootSlot^N3^Sclasses^N4294967295^Sname^SFleet~`Commander's~`Hauberk^Sboe^b^Sawarded^b^Squality^N4^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1130]
			"21:14:45 - SwitchSession (1)", -- [1131]
			"21:14:45 - SwitchSession (1)", -- [1132]
			"21:14:45 - Autopassed on:  (|cffa335ee|Hitem:151994::::::::110:105::3:4:3610:1808:1472:3528:::|h[Fleet Commander's Hauberk]|h|r)", -- [1133]
			"21:14:45 - GetPlayersGear (|cffa335ee|Hitem:151985::::::::110:105::3:3:3610:1472:3528:::|h[General Erodus' Tricorne]|h|r) (INVTYPE_HEAD)", -- [1134]
			"21:14:45 - GetPlayersGear (|cffa335ee|Hitem:152517::::::::110:105::3::::|h[Cloak of the Antoran Vanquisher]|h|r) (INVTYPE_CLOAK)", -- [1135]
			"21:14:45 - GetPlayersGear (|cffa335ee|Hitem:151994::::::::110:105::3:4:3610:1808:1472:3528:::|h[Fleet Commander's Hauberk]|h|r) (INVTYPE_CHEST)", -- [1136]
			"21:14:45 - LootFrame:Start()", -- [1137]
			"21:14:45 - Restoring entry: (normal) (1)", -- [1138]
			"21:14:45 - Entry update error @ item: (nil)", -- [1139]
			"21:14:45 - GetPlayersGear (|cffa335ee|Hitem:151985::::::::110:105::3:3:3610:1472:3528:::|h[General Erodus' Tricorne]|h|r) (INVTYPE_HEAD)", -- [1140]
			"21:14:45 - GetPlayersGear (|cffa335ee|Hitem:152517::::::::110:105::3::::|h[Cloak of the Antoran Vanquisher]|h|r) ()", -- [1141]
			"21:14:45 - GetPlayersGear (|cffa335ee|Hitem:151994::::::::110:105::3:4:3610:1808:1472:3528:::|h[Fleet Commander's Hauberk]|h|r) (INVTYPE_CHEST)", -- [1142]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N15^N2^N10^N3^N25^t^Sgear1^T^N1^Sitem:147130::::::::110:577::5:3:3562:1497:3528^N2^Sitem:147128:5435:::::::110:577::5:3:3562:1502:3336^N3^Sitem:147127::::::::110:577::3:3:3561:1487:3336^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1143]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SVelynila-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N70331.72^Snew^N741.622^t^N2^T^Sequipped^N434.471^Snew^N0^t^N3^T^Sequipped^N55290.7^Snew^N0^t^t^SspecID^N577^Straits^N70^Slegend^N2^Ssockets^N1^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1144]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SPhryke-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N995.641^Snew^N0^t^N2^T^Sequipped^N547.782^Snew^N0^t^N3^T^Sequipped^N783.612^Snew^N0^t^t^SspecID^N265^Straits^N69^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1145]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N1^B^N2^B^t^Sdiff^T^N1^N15^N2^N15^N3^N0^t^Sgear1^T^N1^Sitem:147178::::::::110:262::5:3:3562:1497:3528^N2^Sitem:147176:5436:::::::110:262::5:3:3562:1497:3528^N3^Sitem:152366::::::::110:262::3:4:3614:40:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1146]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SFreakeer-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N816.664^Snew^N919.442^t^N2^T^Sequipped^N521.672^Snew^N0^t^N3^T^Sequipped^N920.927^Snew^N952.85^t^t^SspecID^N262^Straits^N74^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1147]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SGalastradra-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N830.829^Snew^N1046.71^t^N2^T^Sequipped^N1051.751^Snew^N0^t^N3^T^Sequipped^N1295.304^Snew^N0^t^t^SspecID^N261^Straits^N75^Slegend^N2^Ssockets^N5^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1148]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SAmrehlu-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N874.149^Snew^N942.734^t^N2^T^Sequipped^N543.33^Snew^N0^t^N3^T^Sequipped^N1619.692^Snew^N948.889^t^t^SspecID^N253^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1149]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^N3^B^t^Sdiff^T^N1^N15^N2^N15^N3^N-5^t^Sgear1^T^N1^Sitem:138330::::::::110:105::5:4:3516:41:1512:3337^N2^Sitem:142170:5436:::::::110:105::16:3:3418:1532:3528^N3^Sitem:142139::::::::110:105::35:3:3418:1552:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1150]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N-5^N2^N-5^N3^N20^t^Sgear1^T^N1^Sitem:151587::151584::::::110:265::13:5:1702:3408:3609:600:3608^N2^Sitem:152172:5312:::::::110:265::3:3:3610:1477:3336^N3^Sitem:134219::::::::110:265::16:3:3417:1572:3528^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1151]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SAvernakis-Area52^N2^T^Sforged^N11^Spawn^T^N1^T^Sequipped^N913.505^Snew^N1017.759^t^N2^T^Sequipped^N559.59^Snew^N0^t^N3^T^Sequipped^N1077.613^Snew^N0^t^t^SspecID^N105^Straits^N75^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1152]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N945.4375^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N0^N2^N15^N3^N-15^t^Sgear1^T^N1^Sitem:152151::::::::110:66::3:3:3610:1472:3528^N2^Sitem:147158:5311:::::::110:66::5:4:3562:41:1497:3528^N3^Sitem:152148::::::::110:66::3:3:3610:1487:3337^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1153]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^STuyen-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N888.462^Snew^N793.747^t^N2^T^Sequipped^N573.433^Snew^N0^t^N3^T^Sequipped^N1076.543^Snew^N738.283^t^t^SspecID^N66^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1154]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N1^B^N2^B^t^Sdiff^T^N1^N10^N2^N15^N3^N-70^t^Sgear1^T^N1^Sitem:147142::::::::110:253::5:3:3562:1502:3336^N2^Sitem:147140:5435:151580::::::110:253::5:4:3562:1808:1497:3528^N3^Sitem:151805::::::::110:253:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1155]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N946.9375^N4^T^Sresponse^T^N3^B^t^Sdiff^T^N1^N20^N2^N-70^N3^N-25^t^Sgear1^T^N1^Sitem:147033::151585::::::110:261::3:4:3561:1808:1492:3336^N2^Sitem:137021:5435:::::::110:261:::2:3459:3630^N3^Sitem:151982::151584::::::110:261::3:5:3610:1808:42:1487:3337^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1156]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SLesmes-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N87516.57^Snew^N0^t^N2^T^Sequipped^N602.04^Snew^N0^t^N3^T^Sequipped^N870.89^Snew^N0^t^t^SspecID^N63^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1157]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.0625^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N-5^N2^N-5^N3^N15^t^Sgear1^T^N1^Sitem:151587::151583::::::110:63::13:5:1695:3408:3609:600:3608^N2^Sitem:152062:5436:::::::110:63::3:3:3610:1477:3336^N3^Sitem:147149::::::::110:63::3:3:3561:1497:3337^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1158]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N818.86^Snew^N691.948^t^N2^T^Sequipped^N381.709^Snew^N0^t^N3^T^Sequipped^N637.21^Snew^N751.281^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1159]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N912.375^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N-5^N2^N15^N3^N25^t^Sgear1^T^N1^Sitem:151590::151580::::::110:65::13:5:1685:3408:3609:601:3608^N2^Sitem:136977:5433:::::::110:65::43:3:3573:1567:3336^N3^Sitem:151576::::::::110:65::13:5:1685:3408:3609:600:3602^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1160]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SLithelasha-Area52^N2^T^Sforged^N10^Spawn^T^N1^T^Sequipped^N75114.74^Snew^N741.622^t^N2^T^Sequipped^N483.493^Snew^N0^t^N3^T^Sequipped^N61479.23^Snew^N0^t^t^SspecID^N577^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1161]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N5^N2^N10^N3^N10^t^Sgear1^T^N1^Sitem:147130::::::::110:577::5:3:3562:1507:3336^N2^Sitem:151298:5435:151580::::::110:577::43:4:3573:1808:1492:3336^N3^Sitem:147127::::::::110:577::5:3:3562:1502:3336^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1162]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SDibbs-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N87028.64^Snew^N919.442^t^N2^T^Sequipped^N46961.2^Snew^N0^t^N3^T^Sequipped^N72406^Snew^N952.85^t^t^SspecID^N262^Straits^N76^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1163]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SDibbs-Area52^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1164]
			"21:14:46 - Comm received:^1^SextraUtilData^T^N1^SDravash-Area52^N2^T^Sforged^N9^Spawn^T^t^SspecID^N252^Straits^N68^Slegend^N2^Ssockets^N6^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1165]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N-70^N2^N5^N3^N-10^t^Sgear1^T^N1^Sitem:137063::::::::110:268:::2:1811:3630^N2^Sitem:147152:5435:::::::110:268::5:3:3562:1507:3336^N3^Sitem:134438::::::::110:268::35:3:3418:1592:3337^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1166]
			"21:14:46 - Comm received:^1^SlootAck^T^N1^SDravash-Area52^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1167]
			"21:14:47 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N941.9375^Sresponse^SAUTOPASS^Sdiff^N-10^SspecID^N262^Sgear1^S|cffa335ee|Hitem:142134::::::::110:262::35:3:3418:1557:3337:::|h[Castellan's~`Blinders]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1168]
			"21:14:47 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sresponse^SAUTOPASS^Sdiff^N-5^SspecID^N252^Sgear1^S|cffa335ee|Hitem:151590::151580::::::110:252::13:5:1698:3408:3609:600:3608:::|h[Empyrial~`Titan~`Crown~`of~`the~`Feverflare]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1169]
			"21:14:47 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N941.9375^Sresponse^SAUTOPASS^Sdiff^N5^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147193:5436:::::::110:262::5:3:3562:1507:3336:::|h[Cape~`of~`Mindless~`Fury]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1170]
			"21:14:47 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sdiff^N5^SspecID^N252^Sgear1^S|cffa335ee|Hitem:137531:5310:::::::110:252::16:3:3418:1577:3336:::|h[Cloak~`of~`Enthralling~`Darkness]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1171]
			"21:14:48 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N941.9375^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147175::151583::::::110:262::5:4:3562:1808:1497:3528:::|h[Harness~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1172]
			"21:14:48 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sresponse^SAUTOPASS^Sdiff^N-70^SspecID^N252^Sgear1^S|cffff8000|Hitem:151796::::::::110:252:::2:1811:3630:::|h[Cold~`Heart]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1173]
			"21:14:50 - Comm received:^1^SEUBonusRoll^T^N1^SAhoyful-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:65:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1174]
			"21:14:50 - Comm received:^1^Sresponse^T^N1^N1^N2^SVelynila-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1175]
			"21:14:50 - Comm received:^1^Sresponse^T^N1^N1^N2^SGalastradra-Area52^N3^T^Sresponse^N1^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1176]
			"21:14:52 - Comm received:^1^Sresponse^T^N1^N3^N2^SAmrehlu-Area52^N3^T^Sresponse^N4^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1177]
			"21:14:52 - Comm received:^1^Sresponse^T^N1^N2^N2^SGalastradra-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1178]
			"21:14:52 - Comm received:^1^Sresponse^T^N1^N1^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1179]
			"21:14:52 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1180]
			"21:14:53 - LootFrame:Response (8) (Response:) (Offspec)", -- [1181]
			"21:14:53 - SendResponse (group) (2) (8) (true) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [1182]
			"21:14:53 - Trashing entry: (2) (|cffa335ee|Hitem:152517::::::::110:105::3::::|h[Cloak of the Antoran Vanquisher]|h|r)", -- [1183]
			"21:14:53 - Comm received:^1^Sresponse^T^N1^N2^N2^SAvernakis-Area52^N3^T^Sresponse^N8^SisTier^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1184]
			"21:14:55 - Comm received:^1^Sresponse^T^N1^N2^N2^SLesmes-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1185]
			"21:14:58 - ML event (CHAT_MSG_LOOT) (Amrehlu receives bonus loot: |cffa335ee|Hitem:151994::::::::110:105::3:3:3610:1472:3528:::|h[Fleet Commander's Hauberk]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (3348) (nil) (0) (false) (false) (false) (false)", -- [1186]
			"21:14:58 - Comm received:^1^SEUBonusRoll^T^N1^SAmrehlu-Area52^N2^Sitem^N3^S|cffa335ee|Hitem:151994::::::::110:253::3:3:3610:1472:3528:::|h[Fleet~`Commander's~`Hauberk]|h|r^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1187]
			"21:14:58 - LootFrame:Response (4) (Response:) (Transmog)", -- [1188]
			"21:14:58 - SendResponse (group) (1) (4) (nil) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [1189]
			"21:14:58 - Trashing entry: (1) (|cffa335ee|Hitem:151985::::::::110:105::3:3:3610:1472:3528:::|h[General Erodus' Tricorne]|h|r)", -- [1190]
			"21:14:58 - Comm received:^1^Soffline_timer^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1191]
			"21:14:58 - No response from: (Sulana-Area52)", -- [1192]
			"21:14:58 - No response from: (Sulana-Area52)", -- [1193]
			"21:14:58 - No response from: (Sulana-Area52)", -- [1194]
			"21:14:58 - Comm received:^1^Sresponse^T^N1^N1^N2^SAvernakis-Area52^N3^T^Sresponse^N4^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1195]
			"21:14:59 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Sresponse^N1^SisTier^B^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1196]
			"21:15:01 - Event: (LOOT_CLOSED)", -- [1197]
			"21:15:02 - Event: (LOOT_OPENED) (1)", -- [1198]
			"21:15:02 - lootSlot @session (1) (Was at:) (2) (is now at:) (1)", -- [1199]
			"21:15:02 - lootSlot @session (2) (Was at:) (1) (is now at:) (2)", -- [1200]
			"21:15:11 - Comm received:^1^Sresponse^T^N1^N3^N2^SFreakeer-Area52^N3^T^Snote^S2%^Sresponse^N2^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1201]
			"21:15:14 - Comm received:^1^SEUBonusRoll^T^N1^SFreakeer-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:262:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1202]
			"21:15:15 - ML event (CHAT_MSG_LOOT) (Tuyen receives bonus loot: |cffa335ee|Hitem:152149::::::::110:105::3:3:3610:1472:3528:::|h[Light's Vanguard Greatcloak]|h|r.) () () () (Tuyen) () (0) (0) () (0) (3350) (nil) (0) (false) (false) (false) (false)", -- [1203]
			"21:15:15 - Comm received:^1^SEUBonusRoll^T^N1^STuyen-Area52^N2^Sitem^N3^S|cffa335ee|Hitem:152149::::::::110:66::3:3:3610:1472:3528:::|h[Light's~`Vanguard~`Greatcloak]|h|r^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1204]
			"21:15:25 - Comm received:^1^Sresponse^T^N1^N1^N2^SChauric-Area52^N3^T^Sresponse^N2^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1205]
			"21:15:32 - SwitchSession (2)", -- [1206]
			"21:15:34 - SwitchSession (3)", -- [1207]
			"21:15:35 - ML event (CHAT_MSG_WHISPER) (can you link details?) (Ahoyful-Area52) () () (Ahoyful) () (0) (0) () (0) (3353) (Player-3676-0987CF67) (0) (false) (false) (false) (false)", -- [1208]
			"21:15:43 - ML event (CHAT_MSG_WHISPER) (I had to turn off, too many errors) (Ahoyful-Area52) () () (Ahoyful) () (0) (0) () (0) (3354) (Player-3676-0987CF67) (0) (false) (false) (false) (false)", -- [1209]
			"21:15:59 - Comm received:^1^SverTest^T^N1^S2.7.1^t^^ (from:) (Sulana) (distri:) (GUILD)", -- [1210]
			"21:15:59 - Comm received:^1^SplayerInfo^T^N1^SSulana-Area52^N2^SMONK^N3^SHEALER^N4^SBoiled^N6^N0^N7^N947.625^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [1211]
			"21:15:59 - GG:AddEntry(Update) (Sulana-Area52) (9)", -- [1212]
			"21:15:59 - ML:AddCandidate (Sulana-Area52) (MONK) (HEALER) (Boiled) (nil) (0) (nil)", -- [1213]
			"21:15:59 - Comm received:^1^Sreconnect^T^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [1214]
			"21:15:59 - Responded to reconnect from (Sulana)", -- [1215]
			"21:16:01 - Event: (LOOT_OPENED) (1)", -- [1216]
			"21:16:03 - SwitchSession (1)", -- [1217]
			"21:16:08 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SNOTINRAID^Sdiff^N-5^SspecID^N270^Sgear1^S|cffa335ee|Hitem:134447::::::::110:270::35:4:3418:43:1587:3337:::|h[Veil~`of~`Unseen~`Strikes]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1218]
			"21:16:08 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SNOTINRAID^Sdiff^N-70^SspecID^N270^Sgear1^S|cffff8000|Hitem:151784:5436:::::::110:270:::2:1811:3630:::|h[Doorway~`to~`Nowhere]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1219]
			"21:16:08 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SNOTINRAID^Sdiff^N-15^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151980::::::::110:270::5:3:3611:1487:3528:::|h[Harness~`of~`Oppressing~`Dark]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1220]
			"21:16:19 - SwitchSession (2)", -- [1221]
			"21:16:20 - SwitchSession (3)", -- [1222]
			"21:16:43 - SwitchSession (3)", -- [1223]
			"21:16:44 - SwitchSession (2)", -- [1224]
			"21:16:45 - SwitchSession (3)", -- [1225]
			"21:17:19 - Minimize()", -- [1226]
			"21:17:42 - Maximize()", -- [1227]
			"21:17:47 - ML event (CHAT_MSG_WHISPER) (thanks) (Ahoyful-Area52) () () (Ahoyful) () (0) (0) () (0) (3377) (Player-3676-0987CF67) (0) (false) (false) (false) (false)", -- [1228]
			"21:18:22 - ML event (CHAT_MSG_WHISPER) (k) (Ahoyful-Area52) () () (Ahoyful) () (0) (0) () (0) (3382) (Player-3676-0987CF67) (0) (false) (false) (false) (false)", -- [1229]
			"21:18:30 - SwitchSession (1)", -- [1230]
			"21:18:32 - SwitchSession (2)", -- [1231]
			"21:18:33 - SwitchSession (3)", -- [1232]
			"21:18:34 - SwitchSession (2)", -- [1233]
			"21:19:33 - SwitchSession (1)", -- [1234]
			"21:20:43 - SwitchSession (2)", -- [1235]
			"21:21:03 - ReannounceOrRequestRoll (function: 000001A9BE2B3480) (function: 000001AB06AA1010) (true) (false) (false)", -- [1236]
			"21:21:04 - Comm received:^1^Srolls^T^N1^N2^N2^T^SLesmes-Area52^S^SGalastradra-Area52^S^SDravash-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1237]
			"21:21:04 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N946.9375^N4^T^Sresponse^T^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:137021:5435:::::::110:261:::2:3459:3630^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1238]
			"21:21:04 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.0625^N4^T^Sresponse^T^t^Sdiff^T^N1^N-5^t^Sgear1^T^N1^Sitem:152062:5436:::::::110:63::3:3:3610:1477:3336^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1239]
			"21:21:05 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sdiff^N5^SspecID^N252^Sgear1^S|cffa335ee|Hitem:137531:5310:::::::110:252::16:3:3418:1577:3336:::|h[Cloak~`of~`Enthralling~`Darkness]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1240]
			"21:21:06 - Comm received:^1^Sroll^T^N1^SLesmes-Area52^N2^N66^N3^T^N1^N2^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1241]
			"21:21:10 - Comm received:^1^Sroll^T^N1^SGalastradra-Area52^N2^N18^N3^T^N1^N2^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1242]
			"21:22:15 - Comm received:^1^SverTest^T^N1^S2.7.1^t^^ (from:) (Sulana) (distri:) (GUILD)", -- [1243]
			"21:22:15 - Comm received:^1^SplayerInfo^T^N1^SSulana-Area52^N2^SMONK^N3^SHEALER^N4^SBoiled^N6^N0^N7^N947.625^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [1244]
			"21:22:15 - GG:AddEntry(Update) (Sulana-Area52) (9)", -- [1245]
			"21:22:15 - ML:AddCandidate (Sulana-Area52) (MONK) (HEALER) (Boiled) (nil) (0) (nil)", -- [1246]
			"21:22:15 - Comm received:^1^Sreconnect^T^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [1247]
			"21:22:15 - Responded to reconnect from (Sulana)", -- [1248]
			"21:22:20 - ML event (CHAT_MSG_WHISPER) (I clicked it... got a 26) (Dravash-Area52) () () (Dravash) () (0) (0) () (0) (3426) (Player-3676-080ABEE9) (0) (false) (false) (false) (false)", -- [1249]
			"21:22:23 - Comm received:^1^SlootAck^T^N1^SSulana-Area52^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1250]
			"21:22:23 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N-5^SspecID^N270^Sgear1^S|cffa335ee|Hitem:134447::::::::110:270::35:4:3418:43:1587:3337:::|h[Veil~`of~`Unseen~`Strikes]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1251]
			"21:22:23 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^Sdiff^N-70^SspecID^N270^Sgear1^S|cffff8000|Hitem:151784:5436:::::::110:270:::2:1811:3630:::|h[Doorway~`to~`Nowhere]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1252]
			"21:22:23 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^Sdiff^N-15^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151980::::::::110:270::5:3:3611:1487:3528:::|h[Harness~`of~`Oppressing~`Dark]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1253]
			"21:22:31 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sresponse^N4^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1254]
			"21:22:36 - ReannounceOrRequestRoll (Dravash-Area52) (function: 000001AAFE405FE0) (true) (true) (false)", -- [1255]
			"21:22:36 - Comm received:^1^Srolls^T^N1^N2^N2^T^SDravash-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1256]
			"21:22:38 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sdiff^N5^SspecID^N252^Sgear1^S|cffa335ee|Hitem:137531:5310:::::::110:252::16:3:3418:1577:3336:::|h[Cloak~`of~`Enthralling~`Darkness]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1257]
			"21:22:40 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Sroll^N32^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1258]
			"21:22:48 - ML:Award (2) (Lesmes-Area52) (1st Set Piece) (nil)", -- [1259]
			"21:22:48 - GiveMasterLoot (2) (3)", -- [1260]
			"21:22:48 - OnLootSlotCleared() (2) (|cffa335ee|Hitem:152517::::::::110:105::3::::|h[Cloak of the Antoran Vanquisher]|h|r)", -- [1261]
			"21:22:48 - ML:TrackAndLogLoot()", -- [1262]
			"21:22:48 - Comm received:^1^Shistory^T^N1^SLesmes-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SMAGE^SgroupSize^N14^Svotes^N0^Stime^S21:22:48^SitemReplaced1^S|cffa335ee|Hitem:152062:5436:::::::110:105::3:3:3610:1477:3336:::|h[Greatcloak~`of~`the~`Dark~`Pantheon]|h|r^Sid^S1512804168-6^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^S1st~`Set~`Piece^StokenRoll^B^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152517::::::::110:105::3::::|h[Cloak~`of~`the~`Antoran~`Vanquisher]|h|r^StierToken^SBackSlot^SisAwardReason^b^SresponseID^N1^Sboss^SAntoran~`High~`Command^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1263]
			"21:22:48 - Comm received:^1^Sawarded^T^N1^N2^N2^SLesmes-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1264]
			"21:22:48 - SwitchSession (3)", -- [1265]
			"21:22:49 - GetLootDBStatistics()", -- [1266]
			"21:22:53 - ML event (CHAT_MSG_LOOT) (Lesmes receives loot: |cffa335ee|Hitem:152517::::::::110:105::3::::|h[Cloak of the Antoran Vanquisher]|h|r.) () () () ()", -- [1267]
			"21:22:54 - ML:Award (3) (Freakeer-Area52) (Minor Upgrade (<10%)) (nil)", -- [1268]
			"21:22:54 - GiveMasterLoot (3) (7)", -- [1269]
			"21:22:54 - OnLootSlotCleared() (3) (|cffa335ee|Hitem:151994::::::::110:105::3:4:3610:1808:1472:3528:::|h[Fleet Commander's Hauberk]|h|r)", -- [1270]
			"21:22:54 - ML:TrackAndLogLoot()", -- [1271]
			"21:22:54 - Comm received:^1^Shistory^T^N1^SFreakeer-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SSHAMAN^SgroupSize^N14^Svotes^N0^Stime^S21:22:54^SitemReplaced1^S|cffa335ee|Hitem:152366::::::::110:105::3:4:3614:40:1472:3528:::|h[Enthralling~`Chain~`Armor]|h|r^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SMinor~`Upgrade~`(<10%)^Sid^S1512804174-7^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:151994::::::::110:105::3:4:3610:1808:1472:3528:::|h[Fleet~`Commander's~`Hauberk]|h|r^Snote^S2%^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^SresponseID^N2^SisAwardReason^b^Sboss^SAntoran~`High~`Command^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1272]
			"21:22:54 - Comm received:^1^Sawarded^T^N1^N3^N2^SFreakeer-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1273]
			"21:22:54 - SwitchSession (3)", -- [1274]
			"21:22:55 - SwitchSession (1)", -- [1275]
			"21:22:55 - GetLootDBStatistics()", -- [1276]
			"21:22:59 - ML event (CHAT_MSG_LOOT) (Freakeer receives loot: |cffa335ee|Hitem:151994::::::::110:105::3:4:3610:1808:1472:3528:::|h[Fleet Commander's Hauberk]|h|r.) () () () ()", -- [1277]
			"21:23:12 - ML event (CHAT_MSG_WHISPER) (lol addons) (Dravash-Area52) () () (Dravash) () (0) (0) () (0) (3443) (Player-3676-080ABEE9) (0) (false) (false) (false) (false)", -- [1278]
			"21:24:29 - ML:Award (1) (Galastradra-Area52) (Major Upgrade (10%+)) (nil)", -- [1279]
			"21:24:29 - GiveMasterLoot (1) (5)", -- [1280]
			"21:24:29 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:151985::::::::110:105::3:3:3610:1472:3528:::|h[General Erodus' Tricorne]|h|r)", -- [1281]
			"21:24:29 - ML:TrackAndLogLoot()", -- [1282]
			"21:24:29 - Event: (LOOT_CLOSED)", -- [1283]
			"21:24:29 - Event: (LOOT_CLOSED)", -- [1284]
			"21:24:29 - Comm received:^1^Shistory^T^N1^SGalastradra-Area52^N2^T^Sid^S1512804269-8^SitemReplaced1^S|cffff8000|Hitem:137021:5435:::::::110:105:::2:3459:3630:::|h[The~`Dreadlord's~`Deceit]|h|r^SmapID^N1712^SgroupSize^N14^Sdate^S08/12/17^Sclass^SROGUE^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SMajor~`Upgrade~`(10%+)^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Svotes^N0^Stime^S21:24:29^SisAwardReason^b^SlootWon^S|cffa335ee|Hitem:151985::::::::110:105::3:3:3610:1472:3528:::|h[General~`Erodus'~`Tricorne]|h|r^SresponseID^N1^Sboss^SAntoran~`High~`Command^SdifficultyID^N14^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1285]
			"21:24:29 - Comm received:^1^Sawarded^T^N1^N1^N2^SGalastradra-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1286]
			"21:24:29 - SwitchSession (2)", -- [1287]
			"21:24:30 - ML:EndSession()", -- [1288]
			"21:24:30 - GetLootDBStatistics()", -- [1289]
			"21:24:30 - Comm received:^1^Ssession_end^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1290]
			"21:24:30 - RCVotingFrame:EndSession (false)", -- [1291]
			"21:24:32 - Hide VotingFrame", -- [1292]
			"21:24:34 - ML event (CHAT_MSG_LOOT) (Galastradra receives loot: |cffa335ee|Hitem:151985::::::::110:105::3:3:3610:1472:3528:::|h[General Erodus' Tricorne]|h|r.) () () () ()", -- [1293]
			"21:25:29 - UpdateGroup (table: 000001AAF56A0A00)", -- [1294]
			"21:27:15 - Event: (ENCOUNTER_START) (2064) (Portal Keeper Hasabel) (14) (14)", -- [1295]
			"21:27:15 - UpdatePlayersData()", -- [1296]
			"21:33:39 - Event: (ENCOUNTER_END) (2064) (Portal Keeper Hasabel) (14) (14) (1)", -- [1297]
			"21:33:39 - ML event (CHAT_MSG_LOOT) (You receive item: |cff0070dd|Hitem:151556::::::::110:105:8388608:3::56:::|h[Spoils of the Triumphant]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3559) (nil) (0) (false) (false) (false) (false)", -- [1298]
			"21:33:40 - ML event (PLAYER_REGEN_ENABLED)", -- [1299]
			"21:33:42 - Event: (LOOT_OPENED) (1)", -- [1300]
			"21:33:42 - CanWeLootItem (|cffa335ee|Hitem:152086::::::::110:105::3:3:3610:1492:3337:::|h[Grips of Hungering Shadows]|h|r) (4) (true)", -- [1301]
			"21:33:42 - ML:AddItem (|cffa335ee|Hitem:152086::::::::110:105::3:3:3610:1492:3337:::|h[Grips of Hungering Shadows]|h|r) (false) (1) (nil)", -- [1302]
			"21:33:42 - CanWeLootItem (|cffa335ee|Hitem:152049::::::::110:105::3:3:3610:1472:3528:::|h[Fel-Engraved Handbell]|h|r) (4) (true)", -- [1303]
			"21:33:42 - ML:AddItem (|cffa335ee|Hitem:152049::::::::110:105::3:3:3610:1472:3528:::|h[Fel-Engraved Handbell]|h|r) (false) (2) (nil)", -- [1304]
			"21:33:42 - CanWeLootItem (|cffa335ee|Hitem:152035::::::::110:105::3:3:3610:1482:3336:::|h[Blazing Dreadsteed Horseshoe]|h|r) (4) (true)", -- [1305]
			"21:33:42 - ML:AddItem (|cffa335ee|Hitem:152035::::::::110:105::3:3:3610:1482:3336:::|h[Blazing Dreadsteed Horseshoe]|h|r) (false) (3) (nil)", -- [1306]
			"21:33:42 - RCSessionFrame (enabled)", -- [1307]
			"21:33:51 - ML event (CHAT_MSG_LOOT) (Freakeer receives bonus loot: |cffa335ee|Hitem:152001::::::::110:105::3:3:3610:1477:3336:::|h[Nexus Conductor's Headgear]|h|r.) () () () (Freakeer) () (0) (0) () (0) (3566) (nil) (0) (false) (false) (false) (false)", -- [1308]
			"21:33:51 - Comm received:^1^SEUBonusRoll^T^N1^SFreakeer-Area52^N2^Sitem^N3^S|cffa335ee|Hitem:152001::::::::110:262::3:3:3610:1477:3336:::|h[Nexus~`Conductor's~`Headgear]|h|r^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1309]
			"21:33:59 - ML:StartSession()", -- [1310]
			"21:33:59 - ML:AnnounceItems()", -- [1311]
			"21:33:59 - Comm received:^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_HAND^Sgp^N842^Silvl^N950^Slink^S|cffa335ee|Hitem:152086::::::::110:105::3:3:3610:1492:3337:::|h[Grips~`of~`Hungering~`Shadows]|h|r^Srelic^b^Stexture^N1627515^SsubType^SLeather^SlootSlot^N1^Sclasses^N4294967295^Sname^SGrips~`of~`Hungering~`Shadows^Sboe^b^Sawarded^b^Squality^N4^t^N2^T^SequipLoc^S^Sgp^N594^Silvl^N940^Slink^S|cffa335ee|Hitem:152035::::::::110:105::3:3:3610:1482:3336:::|h[Blazing~`Dreadsteed~`Horseshoe]|h|r^Srelic^SFire^Stexture^N1769016^SsubType^SArtifact~`Relic^SlootSlot^N3^Sclasses^N4294967295^Sname^SBlazing~`Dreadsteed~`Horseshoe^Sboe^b^Sawarded^b^Squality^N4^t^N3^T^SequipLoc^S^Sgp^N472^Silvl^N930^Slink^S|cffa335ee|Hitem:152049::::::::110:105::3:3:3610:1472:3528:::|h[Fel-Engraved~`Handbell]|h|r^Srelic^SIron^Stexture^N1769027^SsubType^SArtifact~`Relic^SlootSlot^N2^Sclasses^N4294967295^Sname^SFel-Engraved~`Handbell^Sboe^b^Sawarded^b^Squality^N4^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1312]
			"21:33:59 - SwitchSession (1)", -- [1313]
			"21:33:59 - SwitchSession (1)", -- [1314]
			"21:33:59 - NewRelicAutopassCheck (|cffa335ee|Hitem:152035::::::::110:105::3:3:3610:1482:3336:::|h[Blazing Dreadsteed Horseshoe]|h|r) (Fire)", -- [1315]
			"21:33:59 - NewRelicAutopassCheck (|cffa335ee|Hitem:152049::::::::110:105::3:3:3610:1472:3528:::|h[Fel-Engraved Handbell]|h|r) (Iron)", -- [1316]
			"21:33:59 - Autopassed on:  (|cffa335ee|Hitem:152049::::::::110:105::3:3:3610:1472:3528:::|h[Fel-Engraved Handbell]|h|r)", -- [1317]
			"21:33:59 - GetPlayersGear (|cffa335ee|Hitem:152086::::::::110:105::3:3:3610:1492:3337:::|h[Grips of Hungering Shadows]|h|r) (INVTYPE_HAND)", -- [1318]
			"21:33:59 - LootFrame:Start()", -- [1319]
			"21:33:59 - Restoring entry: (normal) (1)", -- [1320]
			"21:33:59 - Restoring entry: (relic) (2)", -- [1321]
			"21:33:59 - GetPlayersGear (|cffa335ee|Hitem:152086::::::::110:105::3:3:3610:1492:3337:::|h[Grips of Hungering Shadows]|h|r) (INVTYPE_HAND)", -- [1322]
			"21:33:59 - GetPlayersGear (|cffa335ee|Hitem:152035::::::::110:105::3:3:3610:1482:3336:::|h[Blazing Dreadsteed Horseshoe]|h|r) ()", -- [1323]
			"21:33:59 - GetPlayersGear (|cffa335ee|Hitem:152049::::::::110:105::3:3:3610:1472:3528:::|h[Fel-Engraved Handbell]|h|r) ()", -- [1324]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N423.795^Snew^N599.027^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1325]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SGalastradra-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N785.557^Snew^N846.199^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N261^Straits^N75^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1326]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SLithelasha-Area52^N2^T^Sforged^N10^Spawn^T^N1^T^Sequipped^N503.279^Snew^N660.886^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1327]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N912.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N65^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:152751::::::::110:65:::5:1684:1808:3629:1477:3336^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1328]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SLesmes-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N55955.42^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N63^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1329]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SDibbs-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N55325.83^Snew^N796.926^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N76^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1330]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N2^B^t^Sdiff^T^N1^N25^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:147032::::::::110:577::5:3:3562:1507:3336^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1331]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^N2^B^t^Sdiff^T^N1^N35^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:147129:5444:::::::110:577::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1332]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SAmrehlu-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N615.236^Snew^N778.824^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N253^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1333]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SVelynila-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N53484.84^Snew^N660.886^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N70^Slegend^N2^Ssockets^N1^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1334]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.0625^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N30^N2^N10^N3^N0^t^Sgear1^T^N1^Sitem:147146::::::::110:63::5:3:3562:1502:3336^N2^Sitem:152037::::::::110:63::3:3:3610:1472:3528^t^Sgear2^T^N2^Sitem:155849::::::::110:63::3:3:3610:1482:3528^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1335]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SDibbs-Area52^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1336]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SPhryke-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N669.889^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N265^Straits^N69^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1337]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SSulana-Area52^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1338]
			"21:33:59 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N35^SspecID^N270^Sgear1^S|cffa335ee|Hitem:147153::::::::110:270::5:3:3562:1497:3528:::|h[Xuen's~`Gauntlets]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1339]
			"21:33:59 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^SspecID^N270^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1340]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N948.1875^N4^T^Sresponse^T^N2^B^t^Sdiff^T^N1^N20^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:152360:5445:::::::110:261::3:3:3614:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1341]
			"21:33:59 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^SspecID^N270^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1342]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:134467::::::::110:262::35:3:3418:1587:3337^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1343]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^N3^B^t^Sdiff^T^N1^N10^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:137320:5444:::::::110:105::35:3:3418:1592:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1344]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SAvernakis-Area52^N2^T^Sforged^N11^Spawn^T^N1^T^Sequipped^N838.391^Snew^N903.591^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N105^Straits^N75^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1345]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SFreakeer-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N725.154^Snew^N796.926^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N74^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1346]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N35^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:141470:5444:151584::::::110:265::43:4:1808:3573:1527:3336^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1347]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N1^B^N2^B^t^Sdiff^T^N1^N30^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:147141:5446:::::::110:253::5:3:3562:1502:3336^N3^Sitem:147102::::::::110:253::5:3:3562:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1348]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^SDravash-Area52^N2^T^Sforged^N9^Spawn^T^t^SspecID^N252^Straits^N68^Slegend^N2^Ssockets^N6^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1349]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N20^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:152150:5444:::::::110:66::3:3:3610:1472:3528^N3^Sitem:152292::::::::110:66::3:3:3614:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1350]
			"21:33:59 - Comm received:^1^SextraUtilData^T^N1^STuyen-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N729.623^Snew^N717.719^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N66^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1351]
			"21:33:59 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N2^B^t^Sdiff^T^N1^N30^N2^N0^N3^N15^t^Sgear1^T^N1^Sitem:147153:5444:::::::110:268::5:3:3562:1502:3336^N3^Sitem:136778::::::::110:268::16:3:3418:1567:3528^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1352]
			"21:34:00 - Comm received:^1^SlootAck^T^N1^SDravash-Area52^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1353]
			"21:34:01 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N941.9375^Sresponse^SAUTOPASS^Sdiff^N35^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147177:5447:151583::::::110:262::5:4:3562:1808:1497:3528:::|h[Grips~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1354]
			"21:34:01 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sresponse^SAUTOPASS^Sdiff^N15^SspecID^N252^Sgear1^S|cffa335ee|Hitem:134509:5447:::::::110:252::35:3:3418:1587:3337:::|h[Fists~`of~`the~`Legion]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1355]
			"21:34:01 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N941.9375^SspecID^N262^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1356]
			"21:34:01 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sdiff^N25^SspecID^N252^Sgear1^S|cffa335ee|Hitem:147091::::::::110:252::43:3:3573:1497:3336:::|h[Cleansing~`Ignition~`Catalyst]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1357]
			"21:34:01 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N941.9375^SspecID^N262^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1358]
			"21:34:01 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.375^SspecID^N252^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1359]
			"21:34:03 - Comm received:^1^Sresponse^T^N1^N3^N2^SGalastradra-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1360]
			"21:34:04 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sresponse^N1^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1361]
			"21:34:04 - LootFrame:Response (PASS) (Response:) (Pass)", -- [1362]
			"21:34:04 - SendResponse (group) (2) (PASS) (nil) (true) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [1363]
			"21:34:04 - Trashing entry: (2) (|cffa335ee|Hitem:152035::::::::110:105::3:3:3610:1482:3336:::|h[Blazing Dreadsteed Horseshoe]|h|r)", -- [1364]
			"21:34:04 - Comm received:^1^Sresponse^T^N1^N2^N2^SAvernakis-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1365]
			"21:34:05 - Comm received:^1^Sresponse^T^N1^N3^N2^SAhoyful-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1366]
			"21:34:06 - Comm received:^1^Sresponse^T^N1^N1^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1367]
			"21:34:09 - Comm received:^1^Sresponse^T^N1^N2^N2^SAhoyful-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1368]
			"21:34:09 - Comm received:^1^Sresponse^T^N1^N3^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1369]
			"21:34:09 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1370]
			"21:34:09 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1371]
			"21:34:11 - Comm received:^1^SEUBonusRoll^T^N1^SAhoyful-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:65:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1372]
			"21:34:11 - Comm received:^1^Sresponse^T^N1^N1^N2^SGalastradra-Area52^N3^T^Sresponse^N1^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1373]
			"21:34:11 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1374]
			"21:34:11 - Comm received:^1^Sresponse^T^N1^N3^N2^SVelynila-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1375]
			"21:34:12 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1376]
			"21:34:12 - Comm received:^1^Soffline_timer^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1377]
			"21:34:14 - Comm received:^1^Sresponse^T^N1^N3^N2^SAmrehlu-Area52^N3^T^Snote^S+3~`ilvl^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1378]
			"21:34:14 - Comm received:^1^Sresponse^T^N1^N1^N2^SChauric-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1379]
			"21:34:15 - Comm received:^1^Sresponse^T^N1^N2^N2^SPhryke-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1380]
			"21:34:17 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1381]
			"21:34:17 - Comm received:^1^Sresponse^T^N1^N2^N2^SFreakeer-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1382]
			"21:34:18 - Comm received:^1^Sresponse^T^N1^N3^N2^SFreakeer-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1383]
			"21:34:19 - LootFrame:Response (2) (Response:) (Minor Upgrade (<10%))", -- [1384]
			"21:34:19 - SendResponse (group) (1) (2) (nil) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [1385]
			"21:34:19 - Trashing entry: (1) (|cffa335ee|Hitem:152086::::::::110:105::3:3:3610:1492:3337:::|h[Grips of Hungering Shadows]|h|r)", -- [1386]
			"21:34:19 - Comm received:^1^Sresponse^T^N1^N1^N2^SAvernakis-Area52^N3^T^Sresponse^N2^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1387]
			"21:34:20 - Comm received:^1^Sresponse^T^N1^N2^N2^STuyen-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1388]
			"21:34:25 - Comm received:^1^Sresponse^T^N1^N2^N2^SLesmes-Area52^N3^T^Sresponse^N2^SisRelic^B^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1389]
			"21:34:26 - Comm received:^1^Sresponse^T^N1^N3^N2^SChauric-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1390]
			"21:34:26 - Comm received:^1^Sresponse^T^N1^N1^N2^SVelynila-Area52^N3^T^Sresponse^N2^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1391]
			"21:34:27 - SwitchSession (2)", -- [1392]
			"21:34:38 - SwitchSession (3)", -- [1393]
			"21:34:38 - Comm received:^1^Sresponse^T^N1^N3^N2^STuyen-Area52^N3^T^Sresponse^N3^SisRelic^B^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1394]
			"21:34:42 - Comm received:^1^SEUBonusRoll^T^N1^STuyen-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:66:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1395]
			"21:34:44 - ReannounceOrRequestRoll (Galastradra-Area52) (function: 000001AB0C46FF40) (false) (true) (false)", -- [1396]
			"21:34:45 - Comm received:^1^Schange_response^T^N1^N3^N2^SGalastradra-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1397]
			"21:34:45 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N948.1875^N4^T^Sresponse^T^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1398]
			"21:34:54 - Comm received:^1^Sresponse^T^N1^N3^N2^SGalastradra-Area52^N3^T^Snote^SOutlaw~`10~`traits^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1399]
			"21:35:00 - ML:Award (3) (Tuyen-Area52) (Minor Upgrade (Better Trait)) (nil)", -- [1400]
			"21:35:00 - GiveMasterLoot (2) (14)", -- [1401]
			"21:35:00 - OnLootSlotCleared() (2) (|cffa335ee|Hitem:152049::::::::110:105::3:3:3610:1472:3528:::|h[Fel-Engraved Handbell]|h|r)", -- [1402]
			"21:35:00 - ML:TrackAndLogLoot()", -- [1403]
			"21:35:00 - ML event (CHAT_MSG_LOOT) (Tuyen receives loot: |cffa335ee|Hitem:152049::::::::110:105::3:3:3610:1472:3528:::|h[Fel-Engraved Handbell]|h|r.) () () () (Tuyen) () (0) (0) () (0) (3578) (nil) (0) (false) (false) (false) (false)", -- [1404]
			"21:35:00 - Comm received:^1^Shistory^T^N1^STuyen-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SPALADIN^SgroupSize^N14^SisAwardReason^b^Stime^S21:35:00^SitemReplaced1^S|cffa335ee|Hitem:152292::::::::110:105::3:3:3614:1472:3528:::|h[Spike~`of~`Immortal~`Command]|h|r^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sid^S1512804900-9^Sresponse^SMinor~`Upgrade~`(Better~`Trait)^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152049::::::::110:105::3:3:3610:1472:3528:::|h[Fel-Engraved~`Handbell]|h|r^SrelicRoll^B^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^SresponseID^N3^Sboss^SPortal~`Keeper~`Hasabel^Svotes^N0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1405]
			"21:35:00 - Comm received:^1^Sawarded^T^N1^N3^N2^STuyen-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1406]
			"21:35:00 - SwitchSession (3)", -- [1407]
			"21:35:01 - GetLootDBStatistics()", -- [1408]
			"21:35:02 - SwitchSession (2)", -- [1409]
			"21:35:03 - SwitchSession (1)", -- [1410]
			"21:35:18 - ReannounceOrRequestRoll (function: 000001AB33CD2280) (function: 000001AB4B989150) (true) (false) (false)", -- [1411]
			"21:35:18 - Comm received:^1^Srolls^T^N1^N1^N2^T^SSulana-Area52^S^SGalastradra-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1412]
			"21:35:18 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N948.1875^N4^T^Sresponse^T^t^Sdiff^T^N1^N20^t^Sgear1^T^N1^Sitem:152360:5445:::::::110:261::3:3:3614:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1413]
			"21:35:18 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N35^SspecID^N270^Sgear1^S|cffa335ee|Hitem:147153::::::::110:270::5:3:3562:1497:3528:::|h[Xuen's~`Gauntlets]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1414]
			"21:35:22 - Comm received:^1^Sroll^T^N1^SGalastradra-Area52^N2^N22^N3^T^N1^N1^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1415]
			"21:35:28 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sroll^N8^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1416]
			"21:35:34 - ML:Award (1) (Galastradra-Area52) (Major Upgrade (10%+)) (nil)", -- [1417]
			"21:35:34 - GiveMasterLoot (1) (6)", -- [1418]
			"21:35:34 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:152086::::::::110:105::3:3:3610:1492:3337:::|h[Grips of Hungering Shadows]|h|r)", -- [1419]
			"21:35:34 - ML:TrackAndLogLoot()", -- [1420]
			"21:35:35 - ML event (CHAT_MSG_LOOT) (Galastradra receives loot: |cffa335ee|Hitem:152086::::::::110:105::3:3:3610:1492:3337:::|h[Grips of Hungering Shadows]|h|r.) () () () (Galastradra) () (0) (0) () (0) (3587) (nil) (0) (false) (false) (false) (false)", -- [1421]
			"21:35:35 - Comm received:^1^Shistory^T^N1^SGalastradra-Area52^N2^T^Sid^S1512804934-10^SitemReplaced1^S|cffa335ee|Hitem:152360:5445:::::::110:105::3:3:3614:1472:3528:::|h[Gloves~`of~`Barbarous~`Feats]|h|r^SmapID^N1712^SgroupSize^N14^Sdate^S08/12/17^Sclass^SROGUE^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SMajor~`Upgrade~`(10%+)^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Svotes^N0^Stime^S21:35:34^SisAwardReason^b^SlootWon^S|cffa335ee|Hitem:152086::::::::110:105::3:3:3610:1492:3337:::|h[Grips~`of~`Hungering~`Shadows]|h|r^SresponseID^N1^Sboss^SPortal~`Keeper~`Hasabel^SdifficultyID^N14^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1422]
			"21:35:35 - Comm received:^1^Sawarded^T^N1^N1^N2^SGalastradra-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1423]
			"21:35:35 - SwitchSession (2)", -- [1424]
			"21:35:36 - GetLootDBStatistics()", -- [1425]
			"21:35:47 - ReannounceOrRequestRoll (function: 000001AB36096140) (function: 000001AB1C4DD700) (true) (false) (false)", -- [1426]
			"21:35:47 - Comm received:^1^Srolls^T^N1^N2^N2^T^SPhryke-Area52^S^SDravash-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1427]
			"21:35:47 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1428]
			"21:35:49 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sdiff^N25^SspecID^N252^Sgear1^S|cffa335ee|Hitem:147091::::::::110:252::43:3:3573:1497:3336:::|h[Cleansing~`Ignition~`Catalyst]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1429]
			"21:35:50 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Sroll^N76^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1430]
			"21:35:51 - Comm received:^1^Sroll^T^N1^SPhryke-Area52^N2^N91^N3^T^N1^N2^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1431]
			"21:37:17 - ML event (CHAT_MSG_LOOT) (Ahoyful receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|r.) () () () (Ahoyful) () (0) (0) () (0) (3607) (nil) (0) (false) (false) (false) (false)", -- [1432]
			"21:37:19 - ML event (CHAT_MSG_LOOT) (Dibbs receives loot: |cff9d9d9d|Hitem:132204::::::::110:105::::::|h[Sticky Volatile Substance]|h|r.) () () () (Dibbs) () (0) (0) () (0) (3608) (nil) (0) (false) (false) (false) (false)", -- [1433]
			"21:37:20 - ML:Award (2) (Phryke-Area52) (Major Upgrade (4+ Trait Increase)) (nil)", -- [1434]
			"21:37:20 - GiveMasterLoot (3) (4)", -- [1435]
			"21:37:20 - OnLootSlotCleared() (3) (|cffa335ee|Hitem:152035::::::::110:105::3:3:3610:1482:3336:::|h[Blazing Dreadsteed Horseshoe]|h|r)", -- [1436]
			"21:37:20 - ML:TrackAndLogLoot()", -- [1437]
			"21:37:20 - Event: (LOOT_CLOSED)", -- [1438]
			"21:37:20 - Event: (LOOT_CLOSED)", -- [1439]
			"21:37:20 - ML event (CHAT_MSG_LOOT) (Phryke receives loot: |cffa335ee|Hitem:152035::::::::110:105::3:3:3610:1482:3336:::|h[Blazing Dreadsteed Horseshoe]|h|r.) () () () (Phryke) () (0) (0) () (0) (3609) (nil) (0) (false) (false) (false) (false)", -- [1440]
			"21:37:20 - Comm received:^1^Shistory^T^N1^SPhryke-Area52^N2^T^Sid^S1512805040-11^SrelicRoll^B^SmapID^N1712^SgroupSize^N14^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Sclass^SWARLOCK^Sdate^S08/12/17^Sresponse^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sboss^SPortal~`Keeper~`Hasabel^Stime^S21:37:20^SdifficultyID^N14^Svotes^N0^SresponseID^N1^SlootWon^S|cffa335ee|Hitem:152035::::::::110:105::3:3:3610:1482:3336:::|h[Blazing~`Dreadsteed~`Horseshoe]|h|r^SisAwardReason^b^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1441]
			"21:37:20 - Comm received:^1^Sawarded^T^N1^N2^N2^SPhryke-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1442]
			"21:37:20 - SwitchSession (3)", -- [1443]
			"21:37:21 - ML:EndSession()", -- [1444]
			"21:37:21 - GetLootDBStatistics()", -- [1445]
			"21:37:21 - Comm received:^1^Ssession_end^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1446]
			"21:37:21 - RCVotingFrame:EndSession (false)", -- [1447]
			"21:37:24 - Hide VotingFrame", -- [1448]
			"21:38:59 - ML event (TRADE_SHOW)", -- [1449]
			"21:39:06 - ML event (TRADE_ACCEPT_UPDATE) (1) (0)", -- [1450]
			"21:39:06 - ML event (TRADE_ACCEPT_UPDATE) (1) (1)", -- [1451]
			"21:39:06 - ML event (CHAT_MSG_LOOT) (You receive item: |cffffffff|Hitem:133579::::::::110:105::::::|h[Lavish Suramar Feast]|h|rx2.) () () () (Avernakis) () (0) (0) () (0) (3622) (nil) (0) (false) (false) (false) (false)", -- [1452]
			"21:39:06 - ML event (TRADE_CLOSED)", -- [1453]
			"21:39:06 - ML event (TRADE_CLOSED)", -- [1454]
			"21:39:06 - ML event (UI_INFO_MESSAGE) (226) (Trade complete.)", -- [1455]
			"21:40:52 - Event: (ENCOUNTER_START) (2075) (The Defense of Eonar) (14) (14)", -- [1456]
			"21:40:52 - UpdatePlayersData()", -- [1457]
			"21:45:58 - Event: (ENCOUNTER_END) (2075) (The Defense of Eonar) (14) (14) (1)", -- [1458]
			"21:45:59 - ML event (CHAT_MSG_LOOT) (You receive item: |cff0070dd|Hitem:151556::::::::110:105:8388608:3::56:::|h[Spoils of the Triumphant]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3693) (nil) (0) (false) (false) (false) (false)", -- [1459]
			"21:45:59 - ML event (PLAYER_REGEN_ENABLED)", -- [1460]
			"21:46:07 - ML event (CHAT_MSG_LOOT) (Amrehlu receives bonus loot: |cffa335ee|Hitem:152047::::::::110:105::3:3:3610:1472:3528:::|h[Ironvine Thorn]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (3696) (nil) (0) (false) (false) (false) (false)", -- [1461]
			"21:46:07 - Comm received:^1^SEUBonusRoll^T^N1^SAmrehlu-Area52^N2^Sitem^N3^S|cffa335ee|Hitem:152047::::::::110:253::3:3:3610:1472:3528:::|h[Ironvine~`Thorn]|h|r^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1462]
			"21:46:08 - Event: (LOOT_OPENED) (1)", -- [1463]
			"21:46:08 - CanWeLootItem (|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest of the Antoran Protector]|h|r) (4) (true)", -- [1464]
			"21:46:08 - ML:AddItem (|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest of the Antoran Protector]|h|r) (false) (2) (nil)", -- [1465]
			"21:46:08 - CanWeLootItem (|cffa335ee|Hitem:152054::::::::110:105::3:3:3610:1477:3336:::|h[Unwavering Soul Essence]|h|r) (4) (true)", -- [1466]
			"21:46:08 - ML:AddItem (|cffa335ee|Hitem:152054::::::::110:105::3:3:3610:1477:3336:::|h[Unwavering Soul Essence]|h|r) (false) (3) (nil)", -- [1467]
			"21:46:08 - CanWeLootItem (|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest of the Antoran Vanquisher]|h|r) (4) (true)", -- [1468]
			"21:46:08 - ML:AddItem (|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest of the Antoran Vanquisher]|h|r) (false) (4) (nil)", -- [1469]
			"21:46:08 - RCSessionFrame (enabled)", -- [1470]
			"21:46:08 - OnLootSlotCleared() (1) (nil)", -- [1471]
			"21:46:09 - ML:HookLootButton (4)", -- [1472]
			"21:46:09 - ML event (CHAT_MSG_LOOT) (Dibbs receives bonus loot: |cffa335ee|Hitem:152007::::::::110:105::3:3:3610:1472:3528:::|h[Sash of the Gilded Rose]|h|r.) () () () (Dibbs) () (0) (0) () (0) (3701) (nil) (0) (false) (false) (false) (false)", -- [1473]
			"21:46:09 - Comm received:^1^SEUBonusRoll^T^N1^SDibbs-Area52^N2^Sitem^N3^S|cffa335ee|Hitem:152007::::::::110:262::3:3:3610:1472:3528:::|h[Sash~`of~`the~`Gilded~`Rose]|h|r^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1474]
			"21:46:09 - ML:StartSession()", -- [1475]
			"21:46:09 - ML:AnnounceItems()", -- [1476]
			"21:46:10 - Comm received:^1^SlootTable^T^N1^T^N1^T^SequipLoc^S^Sgp^N707^Silvl^N930^Slink^S|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest~`of~`the~`Antoran~`Protector]|h|r^Stexture^N132632^SlootSlot^N2^SsubType^SJunk^Srelic^b^Sclasses^N581^Sname^SChest~`of~`the~`Antoran~`Protector^Stoken^SChestSlot^Sboe^b^Sawarded^b^Squality^N4^t^N2^T^SequipLoc^S^Sgp^N707^Silvl^N930^Slink^S|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest~`of~`the~`Antoran~`Vanquisher]|h|r^Stexture^N132632^SlootSlot^N4^SsubType^SJunk^Srelic^b^Sclasses^N1192^Sname^SChest~`of~`the~`Antoran~`Vanquisher^Stoken^SChestSlot^Sboe^b^Sawarded^b^Squality^N4^t^N3^T^SequipLoc^S^Sgp^N529^Silvl^N935^Slink^S|cffa335ee|Hitem:152054::::::::110:105::3:3:3610:1477:3336:::|h[Unwavering~`Soul~`Essence]|h|r^Srelic^SShadow^Stexture^N895888^SsubType^SArtifact~`Relic^SlootSlot^N3^Sclasses^N4294967295^Sname^SUnwavering~`Soul~`Essence^Sboe^b^Sawarded^b^Squality^N4^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1477]
			"21:46:10 - SwitchSession (1)", -- [1478]
			"21:46:10 - SwitchSession (1)", -- [1479]
			"21:46:10 - Autopassed on:  (|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest of the Antoran Protector]|h|r)", -- [1480]
			"21:46:10 - NewRelicAutopassCheck (|cffa335ee|Hitem:152054::::::::110:105::3:3:3610:1477:3336:::|h[Unwavering Soul Essence]|h|r) (Shadow)", -- [1481]
			"21:46:10 - Autopassed on:  (|cffa335ee|Hitem:152054::::::::110:105::3:3:3610:1477:3336:::|h[Unwavering Soul Essence]|h|r)", -- [1482]
			"21:46:10 - GetPlayersGear (|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest of the Antoran Protector]|h|r) (INVTYPE_ROBE)", -- [1483]
			"21:46:10 - GetPlayersGear (|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest of the Antoran Vanquisher]|h|r) (INVTYPE_ROBE)", -- [1484]
			"21:46:10 - LootFrame:Start()", -- [1485]
			"21:46:10 - Restoring entry: (tier) (2)", -- [1486]
			"21:46:10 - GetPlayersGear (|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest of the Antoran Protector]|h|r) ()", -- [1487]
			"21:46:10 - GetPlayersGear (|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest of the Antoran Vanquisher]|h|r) ()", -- [1488]
			"21:46:10 - GetPlayersGear (|cffa335ee|Hitem:152054::::::::110:105::3:3:3610:1477:3336:::|h[Unwavering Soul Essence]|h|r) ()", -- [1489]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SLithelasha-Area52^N2^T^Sforged^N10^Spawn^T^N1^T^Sequipped^N61479.23^Snew^N0^t^N2^T^Sequipped^N61479.23^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1490]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N637.21^Snew^N0^t^N2^T^Sequipped^N637.21^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1491]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SGalastradra-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N1295.304^Snew^N0^t^N2^T^Sequipped^N1295.304^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N261^Straits^N75^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1492]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N949.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-25^N2^N-25^N3^N5^t^Sgear1^T^N1^Sitem:151982::151584::::::110:261::3:5:3610:1808:42:1487:3337^N2^Sitem:151982::151584::::::110:261::3:5:3610:1808:42:1487:3337^N3^Sitem:142191::::::::110:261::35:3:3417:1547:3337^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1493]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N928.875^N4^T^Sresponse^T^N1^B^N2^B^t^Sdiff^T^N1^N25^N2^N25^N3^N0^t^Sgear1^T^N1^Sitem:147127::::::::110:577::3:3:3561:1487:3336^N2^Sitem:147127::::::::110:577::3:3:3561:1487:3336^N3^Sitem:147111::::::::110:577::5:3:3562:1517:3336^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1494]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^N1^B^N2^B^t^Sdiff^T^N1^N10^N2^N10^N3^N5^t^Sgear1^T^N1^Sitem:147127::::::::110:577::5:3:3562:1502:3336^N2^Sitem:147127::::::::110:577::5:3:3562:1502:3336^N3^Sitem:147110::::::::110:577::5:3:3562:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1495]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N0^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:152366::::::::110:262::3:4:3614:40:1472:3528^N2^Sitem:152366::::::::110:262::3:4:3614:40:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1496]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SVelynila-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N55290.7^Snew^N0^t^N2^T^Sequipped^N55290.7^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N70^Slegend^N2^Ssockets^N0^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1497]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SAmrehlu-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N1619.692^Snew^N0^t^N2^T^Sequipped^N1619.692^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N253^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1498]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N912.375^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N25^N2^N25^N3^N0^t^Sgear1^T^N1^Sitem:151576::::::::110:65::13:5:1685:3408:3609:600:3602^N2^Sitem:151576::::::::110:65::13:5:1685:3408:3609:600:3602^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1499]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SFreakeer-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N920.927^Snew^N0^t^N2^T^Sequipped^N920.927^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N74^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1500]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SLesmes-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N870.89^Snew^N0^t^N2^T^Sequipped^N870.89^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N63^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1501]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.0625^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N15^N2^N15^N3^N0^t^Sgear1^T^N1^Sitem:147149::::::::110:63::3:3:3561:1497:3337^N2^Sitem:147149::::::::110:63::3:3:3561:1497:3337^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1502]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N-70^N2^N-70^N3^N0^t^Sgear1^T^N1^Sitem:151805::::::::110:253:::2:1811:3630^N2^Sitem:151805::::::::110:253:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1503]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SPhryke-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N783.612^Snew^N0^t^N2^T^Sequipped^N783.612^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N265^Straits^N69^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1504]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SDibbs-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N72406^Snew^N0^t^N2^T^Sequipped^N72406^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1505]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SDibbs-Area52^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1506]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N-10^N2^N-10^N3^N0^t^Sgear1^T^N1^Sitem:134438::::::::110:268::35:3:3418:1592:3337^N2^Sitem:134438::::::::110:268::35:3:3418:1592:3337^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1507]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SSulana-Area52^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1508]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^N1^B^N2^B^t^Sdiff^T^N1^N20^N2^N20^N3^N25^t^Sgear1^T^N1^Sitem:134219::::::::110:265::16:3:3417:1572:3528^N2^Sitem:134219::::::::110:265::16:3:3417:1572:3528^N3^Sitem:142191::::::::110:265::16:3:3418:1532:3528^t^Sgear2^T^N3^Sitem:151013::::::::110:265::43:3:3573:3189:3528^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1509]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SDravash-Area52^N2^T^Sforged^N9^Spawn^T^t^SspecID^N252^Straits^N68^Slegend^N2^Ssockets^N6^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1510]
			"21:46:10 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N-15^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151980::::::::110:270::5:3:3611:1487:3528:::|h[Harness~`of~`Oppressing~`Dark]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1511]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N-5^N2^N-5^N3^N0^t^Sgear1^T^N1^Sitem:142139::::::::110:105::35:3:3418:1552:3337^N2^Sitem:142139::::::::110:105::35:3:3418:1552:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1512]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^SAvernakis-Area52^N2^T^Sforged^N11^Spawn^T^N1^T^Sequipped^N1077.613^Snew^N0^t^N2^T^Sequipped^N1077.613^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N105^Straits^N75^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1513]
			"21:46:10 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^Sdiff^N-15^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151980::::::::110:270::5:3:3611:1487:3528:::|h[Harness~`of~`Oppressing~`Dark]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1514]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^SDravash-Area52^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1515]
			"21:46:10 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^SspecID^N270^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1516]
			"21:46:10 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N-15^N2^N-15^N3^N0^t^Sgear1^T^N1^Sitem:152148::::::::110:66::3:3:3610:1487:3337^N2^Sitem:152148::::::::110:66::3:3:3610:1487:3337^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1517]
			"21:46:10 - Comm received:^1^SextraUtilData^T^N1^STuyen-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N1076.543^Snew^N0^t^N2^T^Sequipped^N1076.543^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N66^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1518]
			"21:46:11 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N940.0625^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147175::151583::::::110:262::5:4:3562:1808:1497:3528:::|h[Harness~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1519]
			"21:46:11 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sresponse^SAUTOPASS^Sdiff^N-70^SspecID^N252^Sgear1^S|cffff8000|Hitem:151796::::::::110:252:::2:1811:3630:::|h[Cold~`Heart]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1520]
			"21:46:11 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N940.0625^Sresponse^SAUTOPASS^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147175::151583::::::110:262::5:4:3562:1808:1497:3528:::|h[Harness~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1521]
			"21:46:11 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sdiff^N-70^SspecID^N252^Sgear1^S|cffff8000|Hitem:151796::::::::110:252:::2:1811:3630:::|h[Cold~`Heart]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1522]
			"21:46:12 - LootFrame:Response (1) (Response:) (1st Set Piece)", -- [1523]
			"21:46:12 - SendResponse (group) (2) (1) (true) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [1524]
			"21:46:12 - Trashing entry: (1) (|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest of the Antoran Vanquisher]|h|r)", -- [1525]
			"21:46:12 - Comm received:^1^Sresponse^T^N1^N2^N2^SAvernakis-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1526]
			"21:46:12 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N940.0625^Sresponse^SAUTOPASS^SspecID^N262^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1527]
			"21:46:12 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sdiff^N20^SspecID^N252^Sgear1^S|cffa335ee|Hitem:151013::::::::110:252::29:3:3396:3194:3337:::|h[Ethereal~`Anchor]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1528]
			"21:46:12 - Comm received:^1^Sresponse^T^N1^N2^N2^SLesmes-Area52^N3^T^Sresponse^N2^SisTier^B^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1529]
			"21:46:13 - Comm received:^1^Sresponse^T^N1^N1^N2^SChauric-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1530]
			"21:46:13 - Comm received:^1^Sresponse^T^N1^N1^N2^SAmrehlu-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1531]
			"21:46:13 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Sresponse^N3^SisTier^B^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1532]
			"21:46:14 - Comm received:^1^Sresponse^T^N1^N1^N2^SFreakeer-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1533]
			"21:46:14 - Event: (LOOT_CLOSED)", -- [1534]
			"21:46:14 - BONUS_ROLL_RESULT (artifact_power) (|cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted Azsharan Seal]|h|r) (1) (0) (2) (false)", -- [1535]
			"21:46:14 - ML event (CHAT_MSG_LOOT) (You receive bonus loot: |cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted Azsharan Seal]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3707) (nil) (0) (false) (false) (false) (false)", -- [1536]
			"21:46:15 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sresponse^N1^SisTier^B^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1537]
			"21:46:16 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1538]
			"21:46:17 - Comm received:^1^SEUBonusRoll^T^N1^SAvernakis-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1539]
			"21:46:20 - Comm received:^1^SEUBonusRoll^T^N1^SVelynila-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:577:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1540]
			"21:46:21 - SwitchSession (2)", -- [1541]
			"21:46:22 - Comm received:^1^Sresponse^T^N1^N3^N2^SVelynila-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1542]
			"21:46:22 - Comm received:^1^Soffline_timer^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1543]
			"21:46:23 - Comm received:^1^Sresponse^T^N1^N2^N2^SGalastradra-Area52^N3^T^Snote^SWorth~`it~`better~`than~`955~`item~`lvl^Sresponse^N1^SisTier^B^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1544]
			"21:46:24 - Comm received:^1^SEUBonusRoll^T^N1^SPhryke-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:265:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1545]
			"21:46:25 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Sresponse^SPASS^SisTier^B^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1546]
			"21:46:27 - Comm received:^1^Sresponse^T^N1^N3^N2^SGalastradra-Area52^N3^T^Sresponse^N2^SisRelic^B^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1547]
			"21:46:29 - Comm received:^1^SEUBonusRoll^T^N1^SGalastradra-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:261:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1548]
			"21:46:33 - SwitchSession (3)", -- [1549]
			"21:46:35 - Comm received:^1^Sresponse^T^N1^N3^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1550]
			"21:46:35 - SwitchSession (1)", -- [1551]
			"21:46:36 - Comm received:^1^Sresponse^T^N1^N3^N2^SPhryke-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1552]
			"21:46:36 - Event: (LOOT_OPENED) (1)", -- [1553]
			"21:46:36 - lootSlot @session (3) (Was at:) (3) (is now at:) (1)", -- [1554]
			"21:46:36 - lootSlot @session (2) (Was at:) (4) (is now at:) (2)", -- [1555]
			"21:46:36 - lootSlot @session (1) (Was at:) (2) (is now at:) (3)", -- [1556]
			"21:46:37 - Comm received:^1^SEUBonusRoll^T^N1^STuyen-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:66:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1557]
			"21:46:43 - ReannounceOrRequestRoll (true) (function: 000001AAB9FAA570) (true) (false) (true)", -- [1558]
			"21:46:43 - ML:AnnounceItems()", -- [1559]
			"21:46:43 - Comm received:^1^Srolls^T^N1^N1^N2^T^SLesmes-Area52^S^STuyen-Area52^S^SDibbs-Area52^S^SAvernakis-Area52^S^SVelynila-Area52^S^SDravash-Area52^S^SPhryke-Area52^S^SAhoyful-Area52^S^SGalastradra-Area52^S^SFreakeer-Area52^S^SSulana-Area52^S^SChauric-Area52^S^SLithelasha-Area52^S^SAmrehlu-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1560]
			"21:46:43 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^SINVTYPE_ROBE^Silvl^N930^Slink^S|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest~`of~`the~`Antoran~`Protector]|h|r^SisRoll^B^Sclasses^N581^Sname^SChest~`of~`the~`Antoran~`Protector^Stoken^SChestSlot^SnoAutopass^b^Srelic^b^Ssession^N1^Stexture^N132632^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1561]
			"21:46:43 - Autopassed on:  (|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest of the Antoran Protector]|h|r)", -- [1562]
			"21:46:43 - GetPlayersGear (|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest of the Antoran Protector]|h|r) (INVTYPE_ROBE)", -- [1563]
			"21:46:43 - LootFrame:ReRoll(#table) (1)", -- [1564]
			"21:46:43 - LootFrame:Start()", -- [1565]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N928.875^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N25^t^Sgear1^T^N1^Sitem:147127::::::::110:577::3:3:3561:1487:3336^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1566]
			"21:46:44 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N-15^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151980::::::::110:270::5:3:3611:1487:3528:::|h[Harness~`of~`Oppressing~`Dark]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1567]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^t^Sdiff^T^N1^N0^t^Sgear1^T^N1^Sitem:152366::::::::110:262::3:4:3614:40:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1568]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N912.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N25^t^Sgear1^T^N1^Sitem:151576::::::::110:65::13:5:1685:3408:3609:600:3602^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1569]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N949.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-25^t^Sgear1^T^N1^Sitem:151982::151584::::::110:261::3:5:3610:1808:42:1487:3337^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1570]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147149::::::::110:63::3:3:3561:1497:3337^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1571]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-5^t^Sgear1^T^N1^Sitem:142139::::::::110:105::35:3:3418:1552:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1572]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N-10^t^Sgear1^T^N1^Sitem:134438::::::::110:268::35:3:3418:1592:3337^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1573]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:151805::::::::110:253:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1574]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N10^t^Sgear1^T^N1^Sitem:147127::::::::110:577::5:3:3562:1502:3336^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1575]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-15^t^Sgear1^T^N1^Sitem:152148::::::::110:66::3:3:3610:1487:3337^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1576]
			"21:46:44 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N20^t^Sgear1^T^N1^Sitem:134219::::::::110:265::16:3:3417:1572:3528^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1577]
			"21:46:45 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N940.0625^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147175::151583::::::110:262::5:4:3562:1808:1497:3528:::|h[Harness~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1578]
			"21:46:45 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sresponse^SAUTOPASS^Sdiff^N-70^SspecID^N252^Sgear1^S|cffff8000|Hitem:151796::::::::110:252:::2:1811:3630:::|h[Cold~`Heart]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1579]
			"21:46:46 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sroll^N4^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1580]
			"21:46:46 - Comm received:^1^Sroll^T^N1^SChauric-Area52^N2^N28^N3^T^N1^N1^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1581]
			"21:46:48 - Comm received:^1^Sroll^T^N1^SFreakeer-Area52^N2^N4^N3^T^N1^N1^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1582]
			"21:46:49 - Comm received:^1^Sroll^T^N1^SAmrehlu-Area52^N2^N32^N3^T^N1^N1^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1583]
			"21:46:54 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Sroll^N83^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1584]
			"21:47:01 - ML:Award (1) (Dibbs-Area52) (3rd Set Piece) (nil)", -- [1585]
			"21:47:01 - GiveMasterLoot (3) (11)", -- [1586]
			"21:47:01 - OnLootSlotCleared() (3) (|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest of the Antoran Protector]|h|r)", -- [1587]
			"21:47:01 - ML:TrackAndLogLoot()", -- [1588]
			"21:47:01 - Comm received:^1^Shistory^T^N1^SDibbs-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SSHAMAN^SgroupSize^N14^Svotes^N0^Stime^S21:47:01^SitemReplaced1^S|cffa335ee|Hitem:147175::151583::::::110:105::5:4:3562:1808:1497:3528:::|h[Harness~`of~`the~`Skybreaker]|h|r^Sid^S1512805621-12^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^SrelicRoll^b^Sresponse^S3rd~`Set~`Piece^StokenRoll^B^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest~`of~`the~`Antoran~`Protector]|h|r^StierToken^SChestSlot^SisAwardReason^b^SresponseID^N3^Sboss^SThe~`Defense~`of~`Eonar^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1589]
			"21:47:01 - Comm received:^1^Sawarded^T^N1^N1^N2^SDibbs-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1590]
			"21:47:01 - SwitchSession (2)", -- [1591]
			"21:47:02 - GetLootDBStatistics()", -- [1592]
			"21:47:06 - ML event (CHAT_MSG_LOOT) (Dibbs receives loot: |cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest of the Antoran Protector]|h|r.) () () () ()", -- [1593]
			"21:47:14 - ReannounceOrRequestRoll (true) (function: 000001AAC4608840) (true) (false) (true)", -- [1594]
			"21:47:14 - ML:AnnounceItems()", -- [1595]
			"21:47:14 - Comm received:^1^Srolls^T^N1^N2^N2^T^SLesmes-Area52^S^STuyen-Area52^S^SDibbs-Area52^S^SAvernakis-Area52^S^SVelynila-Area52^S^SDravash-Area52^S^SPhryke-Area52^S^SAhoyful-Area52^S^SGalastradra-Area52^S^SFreakeer-Area52^S^SSulana-Area52^S^SChauric-Area52^S^SLithelasha-Area52^S^SAmrehlu-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1596]
			"21:47:14 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^SINVTYPE_ROBE^Silvl^N930^Slink^S|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest~`of~`the~`Antoran~`Vanquisher]|h|r^SisRoll^B^Sclasses^N1192^Sname^SChest~`of~`the~`Antoran~`Vanquisher^Stoken^SChestSlot^SnoAutopass^b^Srelic^b^Ssession^N2^Stexture^N132632^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1597]
			"21:47:14 - GetPlayersGear (|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest of the Antoran Vanquisher]|h|r) (INVTYPE_ROBE)", -- [1598]
			"21:47:14 - LootFrame:ReRoll(#table) (1)", -- [1599]
			"21:47:14 - LootFrame:Start()", -- [1600]
			"21:47:14 - Restoring entry: (roll) (1)", -- [1601]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N949.4375^N4^T^Sresponse^T^t^Sdiff^T^N1^N-25^t^Sgear1^T^N1^Sitem:151982::151584::::::110:261::3:5:3610:1808:42:1487:3337^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1602]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N912.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N25^t^Sgear1^T^N1^Sitem:151576::::::::110:65::13:5:1685:3408:3609:600:3602^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1603]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N928.875^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N25^t^Sgear1^T^N1^Sitem:147127::::::::110:577::3:3:3561:1487:3336^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1604]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N10^t^Sgear1^T^N1^Sitem:147127::::::::110:577::5:3:3562:1502:3336^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1605]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^N1^Sitem:152366::::::::110:262::3:4:3614:40:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1606]
			"21:47:14 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^Sdiff^N-15^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151980::::::::110:270::5:3:3611:1487:3528:::|h[Harness~`of~`Oppressing~`Dark]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1607]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N-5^t^Sgear1^T^N1^Sitem:142139::::::::110:105::35:3:3418:1552:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1608]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N20^t^Sgear1^T^N1^Sitem:134219::::::::110:265::16:3:3417:1572:3528^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1609]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.0625^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147149::::::::110:63::3:3:3561:1497:3337^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1610]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:151805::::::::110:253:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1611]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-15^t^Sgear1^T^N1^Sitem:152148::::::::110:66::3:3:3610:1487:3337^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1612]
			"21:47:14 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-10^t^Sgear1^T^N1^Sitem:134438::::::::110:268::35:3:3418:1592:3337^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1613]
			"21:47:15 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N940.0625^Sresponse^SAUTOPASS^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147175::151583::::::110:262::5:4:3562:1808:1497:3528:::|h[Harness~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1614]
			"21:47:17 - Comm received:^1^Sroll^T^N1^SGalastradra-Area52^N2^N11^N3^T^N1^N2^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1615]
			"21:47:17 - Comm received:^1^Sroll^T^N1^SAvernakis-Area52^N2^N99^N3^T^N1^N2^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1616]
			"21:47:17 - Comm received:^1^Sroll^T^N1^SLesmes-Area52^N2^N2^N3^T^N1^N2^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1617]
			"21:47:18 - Trashing entry: (1) (|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest of the Antoran Vanquisher]|h|r)", -- [1618]
			"21:47:18 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sdiff^N-70^SspecID^N252^Sgear1^S|cffff8000|Hitem:151796::::::::110:252:::2:1811:3630:::|h[Cold~`Heart]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1619]
			"21:47:24 - ML:Award (2) (Avernakis-Area52) (1st Set Piece) (nil)", -- [1620]
			"21:47:24 - GiveMasterLoot (2) (4)", -- [1621]
			"21:47:24 - LootSlot (2)", -- [1622]
			"21:47:24 - OnLootSlotCleared() (2) (|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest of the Antoran Vanquisher]|h|r)", -- [1623]
			"21:47:24 - ML:TrackAndLogLoot()", -- [1624]
			"21:47:24 - ML event (CHAT_MSG_LOOT) (You receive loot: |cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest of the Antoran Vanquisher]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3742) (nil) (0) (false) (false) (false) (false)", -- [1625]
			"21:47:24 - Comm received:^1^Shistory^T^N1^SAvernakis-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SDRUID^SgroupSize^N14^Svotes^N0^Stime^S21:47:24^SitemReplaced1^S|cffa335ee|Hitem:142139::::::::110:105::35:3:3418:1552:3337:::|h[Vest~`of~`Wanton~`Deeds]|h|r^Sid^S1512805644-13^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^S1st~`Set~`Piece^StokenRoll^B^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest~`of~`the~`Antoran~`Vanquisher]|h|r^StierToken^SChestSlot^SisAwardReason^b^SresponseID^N1^Sboss^SThe~`Defense~`of~`Eonar^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1626]
			"21:47:24 - Comm received:^1^Sawarded^T^N1^N2^N2^SAvernakis-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1627]
			"21:47:24 - SwitchSession (3)", -- [1628]
			"21:47:25 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest~`of~`the~`Antoran~`Vanquisher]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1629]
			"21:47:25 - GetLootDBStatistics()", -- [1630]
			"21:47:30 - Comm received:^1^SEUBonusRoll^T^N1^SLesmes-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:63:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1631]
			"21:47:48 - ReannounceOrRequestRoll (function: 000001AAB707EF30) (function: 000001AB33445180) (true) (false) (false)", -- [1632]
			"21:47:48 - Comm received:^1^Srolls^T^N1^N3^N2^T^SPhryke-Area52^S^SDravash-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1633]
			"21:47:48 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N25^t^Sgear1^T^N1^Sitem:142191::::::::110:265::16:3:3418:1532:3528^t^Sgear2^T^N1^Sitem:151013::::::::110:265::43:3:3573:3189:3528^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1634]
			"21:47:49 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.375^Sdiff^N20^SspecID^N252^Sgear1^S|cffa335ee|Hitem:151013::::::::110:252::29:3:3396:3194:3337:::|h[Ethereal~`Anchor]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1635]
			"21:47:51 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Sroll^N73^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1636]
			"21:47:53 - Comm received:^1^Sroll^T^N1^SPhryke-Area52^N2^N60^N3^T^N1^N3^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1637]
			"21:47:59 - ML:Award (3) (Dravash-Area52) (Major Upgrade (4+ Trait Increase)) (nil)", -- [1638]
			"21:47:59 - GiveMasterLoot (1) (6)", -- [1639]
			"21:47:59 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:152054::::::::110:105::3:3:3610:1477:3336:::|h[Unwavering Soul Essence]|h|r)", -- [1640]
			"21:47:59 - ML:TrackAndLogLoot()", -- [1641]
			"21:47:59 - Event: (LOOT_CLOSED)", -- [1642]
			"21:47:59 - Event: (LOOT_CLOSED)", -- [1643]
			"21:47:59 - Comm received:^1^Shistory^T^N1^SDravash-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SDEATHKNIGHT^SgroupSize^N14^SisAwardReason^b^Stime^S21:47:59^SitemReplaced1^S|cffa335ee|Hitem:151013::::::::110:105::29:3:3396:3194:3337:::|h[Ethereal~`Anchor]|h|r^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sid^S1512805679-14^Sresponse^SMajor~`Upgrade~`(4+~`Trait~`Increase)^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152054::::::::110:105::3:3:3610:1477:3336:::|h[Unwavering~`Soul~`Essence]|h|r^SrelicRoll^B^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^SresponseID^N1^Sboss^SThe~`Defense~`of~`Eonar^Svotes^N0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1644]
			"21:47:59 - Comm received:^1^Sawarded^T^N1^N3^N2^SDravash-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1645]
			"21:47:59 - SwitchSession (3)", -- [1646]
			"21:48:00 - ML:EndSession()", -- [1647]
			"21:48:00 - Comm received:^1^Ssession_end^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1648]
			"21:48:00 - RCVotingFrame:EndSession (false)", -- [1649]
			"21:48:00 - GetLootDBStatistics()", -- [1650]
			"21:48:04 - ML event (CHAT_MSG_LOOT) (Dravash receives loot: |cffa335ee|Hitem:152054::::::::110:105::3:3:3610:1477:3336:::|h[Unwavering Soul Essence]|h|r.) () () () ()", -- [1651]
			"21:48:05 - Hide VotingFrame", -- [1652]
			"21:48:17 - ML event (CHAT_MSG_LOOT) (You receive item: |cffa335ee|Hitem:152124::::::::110:105::3:3:3610:1472:3528:::|h[Bearmantle Harness]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3753) (nil) (0) (false) (false) (false) (false)", -- [1653]
			"21:50:15 - UpdateGroup (table: 000001AAF56A0A00)", -- [1654]
			"21:50:38 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cffffffff|Hitem:124440::::::::110:105::::::|h[Arkhana]|h|rx3.) () () () (Lesmes) () (0) (0) () (0) (3776) (nil) (0) (false) (false) (false) (false)", -- [1655]
			"21:50:41 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cff0070dd|Hitem:124441::::::::110:105::::::|h[Leylight Shard]|h|rx2.) () () () (Lesmes) () (0) (0) () (0) (3778) (nil) (0) (false) (false) (false) (false)", -- [1656]
			"21:50:43 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cff0070dd|Hitem:124441::::::::110:105::::::|h[Leylight Shard]|h|rx2.) () () () (Lesmes) () (0) (0) () (0) (3780) (nil) (0) (false) (false) (false) (false)", -- [1657]
			"21:50:44 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cff0070dd|Hitem:124441::::::::110:105::::::|h[Leylight Shard]|h|rx2.) () () () (Lesmes) () (0) (0) () (0) (3782) (nil) (0) (false) (false) (false) (false)", -- [1658]
			"21:50:50 - ML event (CHAT_MSG_LOOT) (Lesmes creates: |cff0070dd|Hitem:124441::::::::110:105::::::|h[Leylight Shard]|h|rx2.) () () () (Lesmes) () (0) (0) () (0) (3785) (nil) (0) (false) (false) (false) (false)", -- [1659]
			"21:56:34 - ML event (TRADE_SHOW)", -- [1660]
			"21:56:38 - ML event (TRADE_ACCEPT_UPDATE) (1) (0)", -- [1661]
			"21:56:40 - ML event (TRADE_CLOSED)", -- [1662]
			"21:56:40 - ML event (TRADE_CLOSED)", -- [1663]
			"21:56:40 - ML event (UI_INFO_MESSAGE) (226) (Trade complete.)", -- [1664]
			"22:01:45 - Event: (ENCOUNTER_START) (2082) (Imonar the Soulhunter) (14) (14)", -- [1665]
			"22:01:45 - UpdatePlayersData()", -- [1666]
			"22:02:13 - Comm received:^1^SverTest^T^N1^S2.7.1^t^^ (from:) (Sulana) (distri:) (GUILD)", -- [1667]
			"22:02:13 - Comm received:^1^SplayerInfo^T^N1^SSulana-Area52^N2^SMONK^N3^SHEALER^N4^SBoiled^N6^N0^N7^N947.9375^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [1668]
			"22:02:13 - GG:AddEntry(Update) (Sulana-Area52) (9)", -- [1669]
			"22:02:13 - ML:AddCandidate (Sulana-Area52) (MONK) (HEALER) (Boiled) (nil) (0) (nil)", -- [1670]
			"22:02:13 - Comm received:^1^Sreconnect^T^t^^ (from:) (Sulana) (distri:) (WHISPER)", -- [1671]
			"22:02:13 - Responded to reconnect from (Sulana)", -- [1672]
			"22:06:59 - ML event (CHAT_MSG_LOOT) (You receive item: |cff0070dd|Hitem:151556::::::::110:105:8388608:3::56:::|h[Spoils of the Triumphant]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3882) (nil) (0) (false) (false) (false) (false)", -- [1673]
			"22:06:59 - ML event (PLAYER_REGEN_ENABLED)", -- [1674]
			"22:06:59 - Event: (ENCOUNTER_END) (2082) (Imonar the Soulhunter) (14) (14) (1)", -- [1675]
			"22:07:01 - ML event (CHAT_MSG_LOOT) (Lithelasha receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Lithelasha) () (0) (0) () (0) (3887) (nil) (0) (false) (false) (false) (false)", -- [1676]
			"22:07:02 - ML event (CHAT_MSG_LOOT) (Tuyen receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Tuyen) () (0) (0) () (0) (3888) (nil) (0) (false) (false) (false) (false)", -- [1677]
			"22:07:02 - BONUS_ROLL_RESULT (artifact_power) (|cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted Azsharan Seal]|h|r) (1) (0) (2) (false)", -- [1678]
			"22:07:02 - Comm received:^1^SEUBonusRoll^T^N1^SAvernakis-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1679]
			"22:07:02 - ML event (CHAT_MSG_LOOT) (You receive bonus loot: |cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted Azsharan Seal]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3890) (nil) (0) (false) (false) (false) (false)", -- [1680]
			"22:07:02 - ML event (CHAT_MSG_LOOT) (Galastradra receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Galastradra) () (0) (0) () (0) (3891) (nil) (0) (false) (false) (false) (false)", -- [1681]
			"22:07:03 - ML event (CHAT_MSG_LOOT) (Ahoyful receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Ahoyful) () (0) (0) () (0) (3892) (nil) (0) (false) (false) (false) (false)", -- [1682]
			"22:07:05 - ML event (CHAT_MSG_LOOT) (Chauric receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Chauric) () (0) (0) () (0) (3897) (nil) (0) (false) (false) (false) (false)", -- [1683]
			"22:07:05 - ML event (CHAT_MSG_LOOT) (Dravash receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Dravash) () (0) (0) () (0) (3901) (nil) (0) (false) (false) (false) (false)", -- [1684]
			"22:07:05 - Event: (LOOT_OPENED) (1)", -- [1685]
			"22:07:05 - CanWeLootItem (|cffa335ee|Hitem:151938::::::::110:105::3:3:3610:1472:3528:::|h[Drape of the Spirited Hunt]|h|r) (4) (true)", -- [1686]
			"22:07:05 - ML:AddItem (|cffa335ee|Hitem:151938::::::::110:105::3:3:3610:1472:3528:::|h[Drape of the Spirited Hunt]|h|r) (false) (1) (nil)", -- [1687]
			"22:07:05 - CanWeLootItem (|cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings of the Antoran Protector]|h|r) (4) (true)", -- [1688]
			"22:07:05 - ML:AddItem (|cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings of the Antoran Protector]|h|r) (false) (2) (nil)", -- [1689]
			"22:07:05 - CanWeLootItem (|cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r) (4) (false)", -- [1690]
			"22:07:05 - CanWeLootItem (|cffa335ee|Hitem:152528::::::::110:105::3::::|h[Leggings of the Antoran Conqueror]|h|r) (4) (true)", -- [1691]
			"22:07:05 - ML:AddItem (|cffa335ee|Hitem:152528::::::::110:105::3::::|h[Leggings of the Antoran Conqueror]|h|r) (false) (4) (nil)", -- [1692]
			"22:07:05 - RCSessionFrame (enabled)", -- [1693]
			"22:07:05 - Comm received:^1^SEUBonusRoll^T^N1^SAmrehlu-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:253:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1694]
			"22:07:06 - OnLootSlotCleared() (3) (|cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r)", -- [1695]
			"22:07:06 - ML event (UI_INFO_MESSAGE) (286) (Rune of Passage: 2/4)", -- [1696]
			"22:07:06 - ML event (CHAT_MSG_LOOT) (You receive loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3902) (nil) (0) (false) (false) (false) (false)", -- [1697]
			"22:07:06 - ML event (CHAT_MSG_LOOT) (Freakeer receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Freakeer) () (0) (0) () (0) (3903) (nil) (0) (false) (false) (false) (false)", -- [1698]
			"22:07:07 - ML:StartSession()", -- [1699]
			"22:07:07 - ML:AnnounceItems()", -- [1700]
			"22:07:08 - Comm received:^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_CLOAK^Sgp^N396^Silvl^N930^Slink^S|cffa335ee|Hitem:151938::::::::110:105::3:3:3610:1472:3528:::|h[Drape~`of~`the~`Spirited~`Hunt]|h|r^Srelic^b^Stexture^N1529599^SsubType^SCloth^SlootSlot^N1^Sclasses^N4294967295^Sname^SDrape~`of~`the~`Spirited~`Hunt^Sboe^b^Sawarded^b^Squality^N4^t^N2^T^SequipLoc^S^Sgp^N707^Silvl^N930^Slink^S|cffa335ee|Hitem:152528::::::::110:105::3::::|h[Leggings~`of~`the~`Antoran~`Conqueror]|h|r^Stexture^N133834^SlootSlot^N4^SsubType^SJunk^Srelic^b^Sclasses^N2322^Sname^SLeggings~`of~`the~`Antoran~`Conqueror^Stoken^SLegsSlot^Sboe^b^Sawarded^b^Squality^N4^t^N3^T^SequipLoc^S^Sgp^N707^Silvl^N930^Slink^S|cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings~`of~`the~`Antoran~`Protector]|h|r^Stexture^N133834^SlootSlot^N2^SsubType^SJunk^Srelic^b^Sclasses^N581^Sname^SLeggings~`of~`the~`Antoran~`Protector^Stoken^SLegsSlot^Sboe^b^Sawarded^b^Squality^N4^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1701]
			"22:07:08 - SwitchSession (1)", -- [1702]
			"22:07:08 - SwitchSession (1)", -- [1703]
			"22:07:08 - Autopassed on:  (|cffa335ee|Hitem:152528::::::::110:105::3::::|h[Leggings of the Antoran Conqueror]|h|r)", -- [1704]
			"22:07:08 - Autopassed on:  (|cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings of the Antoran Protector]|h|r)", -- [1705]
			"22:07:08 - GetPlayersGear (|cffa335ee|Hitem:151938::::::::110:105::3:3:3610:1472:3528:::|h[Drape of the Spirited Hunt]|h|r) (INVTYPE_CLOAK)", -- [1706]
			"22:07:08 - GetPlayersGear (|cffa335ee|Hitem:152528::::::::110:105::3::::|h[Leggings of the Antoran Conqueror]|h|r) (INVTYPE_LEGS)", -- [1707]
			"22:07:08 - GetPlayersGear (|cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings of the Antoran Protector]|h|r) (INVTYPE_LEGS)", -- [1708]
			"22:07:08 - LootFrame:Start()", -- [1709]
			"22:07:08 - Restoring entry: (normal) (1)", -- [1710]
			"22:07:08 - GetPlayersGear (|cffa335ee|Hitem:151938::::::::110:105::3:3:3610:1472:3528:::|h[Drape of the Spirited Hunt]|h|r) (INVTYPE_CLOAK)", -- [1711]
			"22:07:08 - GetPlayersGear (|cffa335ee|Hitem:152528::::::::110:105::3::::|h[Leggings of the Antoran Conqueror]|h|r) ()", -- [1712]
			"22:07:08 - GetPlayersGear (|cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings of the Antoran Protector]|h|r) ()", -- [1713]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SSulana-Area52^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1714]
			"22:07:08 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.9375^Sdiff^N-70^SspecID^N270^Sgear1^S|cffff8000|Hitem:151784:5436:::::::110:270:::2:1811:3630:::|h[Doorway~`to~`Nowhere]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1715]
			"22:07:08 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.9375^Sresponse^SAUTOPASS^Sdiff^N-40^SspecID^N270^Sgear1^S|cffa335ee|Hitem:134238::::::::110:270::35:3:3510:1632:3337:::|h[Brinewashed~`Leather~`Pants]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1716]
			"22:07:08 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.9375^Sdiff^N-40^SspecID^N270^Sgear1^S|cffa335ee|Hitem:134238::::::::110:270::35:3:3510:1632:3337:::|h[Brinewashed~`Leather~`Pants]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1717]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N381.709^Snew^N402.97^t^N2^T^Sequipped^N550.109^Snew^N0^t^N3^T^Sequipped^N550.109^Snew^N0^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1718]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SLithelasha-Area52^N2^T^Sforged^N10^Spawn^T^N1^T^Sequipped^N483.493^Snew^N421.629^t^N2^T^Sequipped^N83177.12^Snew^N0^t^N3^T^Sequipped^N83177.12^Snew^N0^t^t^SspecID^N577^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1719]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SDibbs-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N46961.2^Snew^N511.163^t^N2^T^Sequipped^N75098.95^Snew^N0^t^N3^T^Sequipped^N75098.95^Snew^N0^t^t^SspecID^N262^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1720]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SAmrehlu-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N543.33^Snew^N549.567^t^N2^T^Sequipped^N854.449^Snew^N0^t^N3^T^Sequipped^N854.449^Snew^N0^t^t^SspecID^N253^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1721]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N912.375^N4^T^Sresponse^T^N3^B^t^Sdiff^T^N1^N15^N2^N40^N3^N40^t^Sgear1^T^N1^Sitem:136977:5433:::::::110:65::43:3:3573:1567:3336^N2^Sitem:152746::::::::110:65:::4:1700:3629:1482:3336^N3^Sitem:152746::::::::110:65:::4:1700:3629:1482:3336^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1722]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N3^B^t^Sdiff^T^N1^N10^N2^N40^N3^N40^t^Sgear1^T^N1^Sitem:147128:5435:::::::110:577::5:3:3562:1502:3336^N2^Sitem:147131::::::::110:577::4:3:3564:1472:3336^N3^Sitem:147131::::::::110:577::4:3:3564:1472:3336^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1723]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SVelynila-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N434.471^Snew^N421.629^t^N2^T^Sequipped^N57558.35^Snew^N0^t^N3^T^Sequipped^N57558.35^Snew^N0^t^t^SspecID^N577^Straits^N70^Slegend^N2^Ssockets^N1^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1724]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SLesmes-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N555.339^Snew^N520.027^t^N2^T^Sequipped^N71608.38^Snew^N0^t^N3^T^Sequipped^N71608.38^Snew^N0^t^t^SspecID^N63^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1725]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N2^B^t^Sdiff^T^N1^N15^N2^N20^N3^N20^t^Sgear1^T^N1^Sitem:147176:5436:::::::110:262::5:3:3562:1497:3528^N2^Sitem:147179::::::::110:262::3:3:3561:1492:3336^N3^Sitem:147179::::::::110:262::3:3:3561:1492:3336^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1726]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SFreakeer-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N521.672^Snew^N511.163^t^N2^T^Sequipped^N831.303^Snew^N0^t^N3^T^Sequipped^N831.303^Snew^N0^t^t^SspecID^N262^Straits^N74^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1727]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SGalastradra-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N1051.751^Snew^N546.003^t^N2^T^Sequipped^N1189.414^Snew^N0^t^N3^T^Sequipped^N1189.414^Snew^N0^t^t^SspecID^N261^Straits^N75^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1728]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SDibbs-Area52^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1729]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N2^B^t^Sdiff^T^N1^N15^N2^N15^N3^N15^t^Sgear1^T^N1^Sitem:147140:5435:151580::::::110:253::5:4:3562:1808:1497:3528^N2^Sitem:147143::151580::::::110:253::5:5:3562:1808:43:1497:3528^N3^Sitem:147143::151580::::::110:253::5:5:3562:1808:43:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1730]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^N3^B^t^Sdiff^T^N1^N10^N2^N-15^N3^N-15^t^Sgear1^T^N1^Sitem:151298:5435:151580::::::110:577::43:4:3573:1808:1492:3336^N2^Sitem:147131::::::::110:577::5:3:3562:1527:3337^N3^Sitem:147131::::::::110:577::5:3:3562:1527:3337^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1731]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N15^N2^N5^N3^N5^t^Sgear1^T^N1^Sitem:142170:5436:::::::110:105::16:3:3418:1532:3528^N2^Sitem:147137::::::::110:105::5:3:3562:1507:3336^N3^Sitem:147137::::::::110:105::5:3:3562:1507:3336^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1732]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SAvernakis-Area52^N2^T^Sforged^N11^Spawn^T^N1^T^Sequipped^N559.59^Snew^N577.039^t^N2^T^Sequipped^N988.477^Snew^N0^t^N3^T^Sequipped^N988.477^Snew^N0^t^t^SspecID^N105^Straits^N75^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1733]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N0^N2^N10^N3^N10^t^Sgear1^T^N1^Sitem:152136:5436:::::::110:63::3:3:3610:1472:3528^N2^Sitem:147148::::::::110:63::5:3:3562:1502:3336^N3^Sitem:147148::::::::110:63::5:3:3562:1502:3336^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1734]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SPhryke-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N547.782^Snew^N517.222^t^N2^T^Sequipped^N950.812^Snew^N0^t^N3^T^Sequipped^N950.812^Snew^N0^t^t^SspecID^N265^Straits^N69^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1735]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N949.4375^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N-70^N2^N-25^N3^N-25^t^Sgear1^T^N1^Sitem:137021:5435:::::::110:261:::2:3459:3630^N2^Sitem:133616::::::::110:261::35:3:3535:1607:3337^N3^Sitem:133616::::::::110:261::35:3:3535:1607:3337^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1736]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N3^B^t^Sdiff^T^N1^N0^N2^N-70^N3^N-70^t^Sgear1^T^N1^Sitem:152149:5434:::::::110:66::3:3:3610:1472:3528^N2^Sitem:137070::::::::110:66:::3:3529:1811:3630^N3^Sitem:137070::::::::110:66:::3:3529:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1737]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^STuyen-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N500.471^Snew^N517.641^t^N2^T^Sequipped^N1565.963^Snew^N0^t^N3^T^Sequipped^N1565.963^Snew^N0^t^t^SspecID^N66^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1738]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N2^B^t^Sdiff^T^N1^N5^N2^N15^N3^N15^t^Sgear1^T^N1^Sitem:147152:5435:::::::110:268::5:3:3562:1507:3336^N2^Sitem:147155::::::::110:268::5:3:3562:1497:3528^N3^Sitem:147155::::::::110:268::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1739]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^N3^B^t^Sdiff^T^N1^N-5^N2^N-5^N3^N-5^t^Sgear1^T^N1^Sitem:152172:5312:::::::110:265::3:3:3610:1477:3336^N2^Sitem:151571::::::::110:265::13:5:1702:3408:3609:601:3608^N3^Sitem:151571::::::::110:265::13:5:1702:3408:3609:601:3608^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1740]
			"22:07:08 - Comm received:^1^SextraUtilData^T^N1^SDravash-Area52^N2^T^Sforged^N9^Spawn^T^t^SspecID^N252^Straits^N68^Slegend^N2^Ssockets^N6^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1741]
			"22:07:08 - Comm received:^1^SlootAck^T^N1^SDravash-Area52^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1742]
			"22:07:09 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sdiff^N5^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147193:5436:::::::110:262::5:3:3562:1507:3336:::|h[Cape~`of~`Mindless~`Fury]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1743]
			"22:07:09 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.5^Sdiff^N5^SspecID^N252^Sgear1^S|cffa335ee|Hitem:137531:5310:::::::110:252::16:3:3418:1577:3336:::|h[Cloak~`of~`Enthralling~`Darkness]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1744]
			"22:07:09 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^Sdiff^N10^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147179::::::::110:262::5:3:3562:1502:3336:::|h[Legguards~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1745]
			"22:07:09 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.5^Sresponse^SAUTOPASS^Sdiff^N-10^SspecID^N252^Sgear1^S|cffa335ee|Hitem:152016::151580::::::110:252::3:4:3610:1808:1472:3528:::|h[Cosmos-Culling~`Legplates]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1746]
			"22:07:10 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sdiff^N10^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147179::::::::110:262::5:3:3562:1502:3336:::|h[Legguards~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1747]
			"22:07:10 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.5^Sresponse^SAUTOPASS^Sdiff^N-10^SspecID^N252^Sgear1^S|cffa335ee|Hitem:152016::151580::::::110:252::3:4:3610:1808:1472:3528:::|h[Cosmos-Culling~`Legplates]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1748]
			"22:07:11 - Comm received:^1^Sresponse^T^N1^N3^N2^SAmrehlu-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1749]
			"22:07:12 - ML event (CHAT_MSG_LOOT) (Phryke receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Phryke) () (0) (0) () (0) (3908) (nil) (0) (false) (false) (false) (false)", -- [1750]
			"22:07:13 - Comm received:^1^Sresponse^T^N1^N1^N2^SGalastradra-Area52^N3^T^Sresponse^N4^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1751]
			"22:07:13 - ML event (CHAT_MSG_LOOT) (Lesmes receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Lesmes) () (0) (0) () (0) (3910) (nil) (0) (false) (false) (false) (false)", -- [1752]
			"22:07:14 - LootFrame:Response (PASS) (Response:) (Pass)", -- [1753]
			"22:07:14 - SendResponse (group) (1) (PASS) (nil) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [1754]
			"22:07:14 - Trashing entry: (1) (|cffa335ee|Hitem:151938::::::::110:105::3:3:3610:1472:3528:::|h[Drape of the Spirited Hunt]|h|r)", -- [1755]
			"22:07:15 - Event: (LOOT_CLOSED)", -- [1756]
			"22:07:15 - Comm received:^1^Sresponse^T^N1^N1^N2^SAvernakis-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1757]
			"22:07:15 - Comm received:^1^Sresponse^T^N1^N3^N2^SFreakeer-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1758]
			"22:07:15 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Sresponse^N1^SisTier^B^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1759]
			"22:07:17 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Sresponse^N1^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1760]
			"22:07:19 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1761]
			"22:07:19 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1762]
			"22:07:19 - Comm received:^1^Sresponse^T^N1^N2^N2^SAhoyful-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1763]
			"22:07:20 - Comm received:^1^Sresponse^T^N1^N1^N2^SPhryke-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1764]
			"22:07:20 - Comm received:^1^Soffline_timer^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1765]
			"22:07:21 - Comm received:^1^Sresponse^T^N1^N1^N2^SFreakeer-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1766]
			"22:07:21 - Comm received:^1^Sresponse^T^N1^N1^N2^SVelynila-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1767]
			"22:07:22 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisTier^B^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1768]
			"22:07:22 - Comm received:^1^Sresponse^T^N1^N3^N2^SChauric-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1769]
			"22:07:22 - Event: (LOOT_OPENED) (1)", -- [1770]
			"22:07:22 - lootSlot @session (2) (Was at:) (4) (is now at:) (2)", -- [1771]
			"22:07:22 - lootSlot @session (3) (Was at:) (2) (is now at:) (3)", -- [1772]
			"22:07:22 - ML event (CHAT_MSG_LOOT) (Velynila receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Velynila) () (0) (0) () (0) (3911) (nil) (0) (false) (false) (false) (false)", -- [1773]
			"22:07:23 - Comm received:^1^Sresponse^T^N1^N2^N2^SPhryke-Area52^N3^T^Sresponse^N2^SisTier^B^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1774]
			"22:07:24 - Comm received:^1^Sresponse^T^N1^N1^N2^SAhoyful-Area52^N3^T^Sresponse^N1^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1775]
			"22:07:25 - Comm received:^1^Sresponse^T^N1^N1^N2^SLesmes-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1776]
			"22:07:25 - Comm received:^1^Sresponse^T^N1^N1^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1777]
			"22:07:26 - Comm received:^1^Sresponse^T^N1^N2^N2^SVelynila-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1778]
			"22:07:26 - ML event (CHAT_MSG_LOOT) (Chauric receives bonus loot: |cffa335ee|Hitem:152050::::::::110:105::3:3:3610:1492:3337:::|h[Mysterious Petrified Egg]|h|r.) () () () (Chauric) () (0) (0) () (0) (3912) (nil) (0) (false) (false) (false) (false)", -- [1779]
			"22:07:27 - Comm received:^1^Sresponse^T^N1^N1^N2^STuyen-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1780]
			"22:07:28 - Comm received:^1^Sresponse^T^N1^N2^N2^STuyen-Area52^N3^T^Sresponse^SPASS^SisTier^B^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1781]
			"22:07:28 - Comm received:^1^Sresponse^T^N1^N2^N2^SLithelasha-Area52^N3^T^Sresponse^N2^SisTier^B^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1782]
			"22:07:31 - SwitchSession (2)", -- [1783]
			"22:07:31 - ML event (CHAT_MSG_LOOT) (Sulana receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Sulana) () (0) (0) () (0) (3913) (nil) (0) (false) (false) (false) (false)", -- [1784]
			"22:07:36 - Comm received:^1^Sresponse^T^N1^N1^N2^SChauric-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1785]
			"22:07:37 - SwitchSession (3)", -- [1786]
			"22:07:39 - Comm received:^1^Sresponse^T^N1^N1^N2^SAmrehlu-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1787]
			"22:07:41 - SwitchSession (2)", -- [1788]
			"22:07:45 - ML event (CHAT_MSG_LOOT) (Dravash receives bonus loot: |cffa335ee|Hitem:152416::::::::110:105::3:3:3610:1482:3336:::|h[Shoulderguards of Indomitable Purpose]|h|r.) () () () (Dravash) () (0) (0) () (0) (3914) (nil) (0) (false) (false) (false) (false)", -- [1789]
			"22:07:45 - Comm received:^1^SEUBonusRoll^T^N1^SDravash-Area52^N2^Sitem^N3^S|cffa335ee|Hitem:152416::::::::110:252::3:3:3610:1482:3336:::|h[Shoulderguards~`of~`Indomitable~`Purpose]|h|r^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1790]
			"22:07:48 - ML event (CHAT_MSG_LOOT) (Amrehlu receives loot: |cffa335ee|Hitem:152902::::::::110:105::::::|h[Rune of Passage]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (3916) (nil) (0) (false) (false) (false) (false)", -- [1791]
			"22:07:54 - Comm received:^1^SEUBonusRoll^T^N1^SLithelasha-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:577:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1792]
			"22:07:57 - SwitchSession (3)", -- [1793]
			"22:08:01 - Comm received:^1^SEUBonusRoll^T^N1^SLesmes-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:63:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1794]
			"22:08:04 - ReannounceOrRequestRoll (function: 000001AB3609C8C0) (function: 000001AB6B9EB8E0) (true) (false) (false)", -- [1795]
			"22:08:04 - Comm received:^1^Srolls^T^N1^N3^N2^T^SChauric-Area52^S^SSulana-Area52^S^SFreakeer-Area52^S^SAmrehlu-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1796]
			"22:08:04 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^t^Sdiff^T^N1^N20^t^Sgear1^T^N1^Sitem:147179::::::::110:262::3:3:3561:1492:3336^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1797]
			"22:08:05 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147143::151580::::::110:253::5:5:3562:1808:43:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1798]
			"22:08:05 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.9375^Sdiff^N-40^SspecID^N270^Sgear1^S|cffa335ee|Hitem:134238::::::::110:270::35:3:3510:1632:3337:::|h[Brinewashed~`Leather~`Pants]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1799]
			"22:08:05 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147155::::::::110:268::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1800]
			"22:08:06 - Comm received:^1^Svote^T^N1^N1^N2^SAhoyful-Area52^N3^N1^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1801]
			"22:08:06 - 1 = (IsCouncil) (Galastradra)", -- [1802]
			"22:08:06 - Comm received:^1^Sroll^T^N1^SChauric-Area52^N2^N49^N3^T^N1^N3^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1803]
			"22:08:06 - Comm received:^1^Svote^T^N1^N1^N2^SDravash-Area52^N3^N1^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1804]
			"22:08:06 - 1 = (IsCouncil) (Galastradra)", -- [1805]
			"22:08:07 - Comm received:^1^Sroll^T^N1^SAmrehlu-Area52^N2^N97^N3^T^N1^N3^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1806]
			"22:08:07 - Comm received:^1^Sroll^T^N1^SFreakeer-Area52^N2^N49^N3^T^N1^N3^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1807]
			"22:08:07 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Sroll^N61^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1808]
			"22:08:14 - Comm received:^1^Svote^T^N1^N2^N2^SLithelasha-Area52^N3^N1^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1809]
			"22:08:14 - 1 = (IsCouncil) (Galastradra)", -- [1810]
			"22:08:14 - ML:Award (3) (Amrehlu-Area52) (1st Set Piece) (nil)", -- [1811]
			"22:08:14 - GiveMasterLoot (3) (8)", -- [1812]
			"22:08:15 - OnLootSlotCleared() (3) (|cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings of the Antoran Protector]|h|r)", -- [1813]
			"22:08:15 - ML:TrackAndLogLoot()", -- [1814]
			"22:08:15 - Comm received:^1^Shistory^T^N1^SAmrehlu-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SHUNTER^SgroupSize^N13^Svotes^N0^Stime^S22:08:15^SitemReplaced1^S|cffa335ee|Hitem:147143::151580::::::110:105::5:5:3562:1808:43:1497:3528:::|h[Wildstalker~`Leggings]|h|r^Sid^S1512806895-15^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^S1st~`Set~`Piece^StokenRoll^B^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings~`of~`the~`Antoran~`Protector]|h|r^StierToken^SLegsSlot^SisAwardReason^b^SresponseID^N1^Sboss^SImonar~`the~`Soulhunter^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1815]
			"22:08:15 - Comm received:^1^Sawarded^T^N1^N3^N2^SAmrehlu-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1816]
			"22:08:15 - SwitchSession (3)", -- [1817]
			"22:08:16 - GetLootDBStatistics()", -- [1818]
			"22:08:20 - ML event (CHAT_MSG_LOOT) (Amrehlu receives loot: |cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings of the Antoran Protector]|h|r.) () () () ()", -- [1819]
			"22:08:23 - SwitchSession (1)", -- [1820]
			"22:08:23 - Comm received:^1^Svote^T^N1^N2^N2^SPhryke-Area52^N3^N1^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1821]
			"22:08:23 - 1 = (IsCouncil) (Galastradra)", -- [1822]
			"22:08:28 - ReannounceOrRequestRoll (function: 000001A9CE7C5060) (function: 000001AB6B5FBDE0) (true) (false) (false)", -- [1823]
			"22:08:28 - Comm received:^1^Srolls^T^N1^N1^N2^T^SAhoyful-Area52^S^SDravash-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1824]
			"22:08:28 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N912.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:136977:5433:::::::110:65::43:3:3573:1567:3336^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1825]
			"22:08:30 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.5^Sdiff^N5^SspecID^N252^Sgear1^S|cffa335ee|Hitem:137531:5310:::::::110:252::16:3:3418:1577:3336:::|h[Cloak~`of~`Enthralling~`Darkness]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1826]
			"22:08:31 - Comm received:^1^Sroll^T^N1^SAhoyful-Area52^N2^N73^N3^T^N1^N1^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1827]
			"22:08:32 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Sroll^N48^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1828]
			"22:08:37 - ML:Award (1) (Ahoyful-Area52) (Major Upgrade (10%+)) (nil)", -- [1829]
			"22:08:37 - GiveMasterLoot (1) (9)", -- [1830]
			"22:08:37 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:151938::::::::110:105::3:3:3610:1472:3528:::|h[Drape of the Spirited Hunt]|h|r)", -- [1831]
			"22:08:37 - ML:TrackAndLogLoot()", -- [1832]
			"22:08:37 - Comm received:^1^Shistory^T^N1^SAhoyful-Area52^N2^T^Sid^S1512806917-16^SitemReplaced1^S|cffa335ee|Hitem:136977:5433:::::::110:105::43:3:3573:1567:3336:::|h[Shadowfeather~`Shawl]|h|r^SmapID^N1712^SgroupSize^N13^Sdate^S08/12/17^Sclass^SPALADIN^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SMajor~`Upgrade~`(10%+)^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Svotes^N1^Stime^S22:08:37^SisAwardReason^b^SlootWon^S|cffa335ee|Hitem:151938::::::::110:105::3:3:3610:1472:3528:::|h[Drape~`of~`the~`Spirited~`Hunt]|h|r^SresponseID^N1^Sboss^SImonar~`the~`Soulhunter^SdifficultyID^N14^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1833]
			"22:08:37 - Comm received:^1^Sawarded^T^N1^N1^N2^SAhoyful-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1834]
			"22:08:37 - SwitchSession (2)", -- [1835]
			"22:08:38 - GetLootDBStatistics()", -- [1836]
			"22:08:42 - ML event (CHAT_MSG_LOOT) (Ahoyful receives loot: |cffa335ee|Hitem:151938::::::::110:105::3:3:3610:1472:3528:::|h[Drape of the Spirited Hunt]|h|r.) () () () ()", -- [1837]
			"22:08:46 - SwitchSession (1)", -- [1838]
			"22:08:51 - SwitchSession (2)", -- [1839]
			"22:08:57 - ReannounceOrRequestRoll (function: 000001AB355344D0) (function: 000001AB6BBCD3C0) (true) (false) (false)", -- [1840]
			"22:08:57 - Comm received:^1^Srolls^T^N1^N2^N2^T^SPhryke-Area52^S^SLithelasha-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1841]
			"22:08:57 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^t^Sdiff^T^N1^N-15^t^Sgear1^T^N1^Sitem:147131::::::::110:577::5:3:3562:1527:3337^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1842]
			"22:08:57 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N-5^t^Sgear1^T^N1^Sitem:151571::::::::110:265::13:5:1702:3408:3609:601:3608^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1843]
			"22:08:59 - Comm received:^1^Sroll^T^N1^SPhryke-Area52^N2^N9^N3^T^N1^N2^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1844]
			"22:09:06 - Comm received:^1^Sroll^T^N1^SLithelasha-Area52^N2^N98^N3^T^N1^N2^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1845]
			"22:09:10 - ML:Award (2) (Lithelasha-Area52) (2nd Set Piece) (nil)", -- [1846]
			"22:09:10 - GiveMasterLoot (2) (11)", -- [1847]
			"22:09:10 - OnLootSlotCleared() (2) (|cffa335ee|Hitem:152528::::::::110:105::3::::|h[Leggings of the Antoran Conqueror]|h|r)", -- [1848]
			"22:09:10 - ML:TrackAndLogLoot()", -- [1849]
			"22:09:10 - Event: (LOOT_CLOSED)", -- [1850]
			"22:09:10 - Event: (LOOT_CLOSED)", -- [1851]
			"22:09:11 - Comm received:^1^Shistory^T^N1^SLithelasha-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SDEMONHUNTER^SgroupSize^N14^Svotes^N1^Stime^S22:09:10^SitemReplaced1^S|cffa335ee|Hitem:147131::::::::110:105::5:3:3562:1527:3337:::|h[Demonbane~`Leggings]|h|r^Sid^S1512806950-17^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^S2nd~`Set~`Piece^StokenRoll^B^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152528::::::::110:105::3::::|h[Leggings~`of~`the~`Antoran~`Conqueror]|h|r^StierToken^SLegsSlot^SisAwardReason^b^SresponseID^N2^Sboss^SImonar~`the~`Soulhunter^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1852]
			"22:09:11 - Comm received:^1^Sawarded^T^N1^N2^N2^SLithelasha-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1853]
			"22:09:11 - SwitchSession (3)", -- [1854]
			"22:09:11 - ML:EndSession()", -- [1855]
			"22:09:12 - GetLootDBStatistics()", -- [1856]
			"22:09:12 - Comm received:^1^Ssession_end^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1857]
			"22:09:12 - RCVotingFrame:EndSession (false)", -- [1858]
			"22:09:13 - Hide VotingFrame", -- [1859]
			"22:09:14 - Comm received:^1^SEUBonusRoll^T^N1^SVelynila-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:577:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1860]
			"22:09:15 - ML event (CHAT_MSG_LOOT) (Lithelasha receives loot: |cffa335ee|Hitem:152528::::::::110:105::3::::|h[Leggings of the Antoran Conqueror]|h|r.) () () () ()", -- [1861]
			"22:09:42 - ML event (CHAT_MSG_LOOT) (Amrehlu receives loot: |cff9d9d9d|Hitem:132204::::::::110:105::::::|h[Sticky Volatile Substance]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (3944) (nil) (0) (false) (false) (false) (false)", -- [1862]
			"22:09:48 - ML event (CHAT_MSG_LOOT) (Lithelasha receives item: |cffa335ee|Hitem:152122::::::::110:105::3:4:3610:41:1472:3528:::|h[Felreaper Leggings]|h|r.) () () () (Lithelasha) () (0) (0) () (0) (3945) (nil) (0) (false) (false) (false) (false)", -- [1863]
			"22:10:04 - Event: (LOOT_OPENED) (1)", -- [1864]
			"22:10:04 - CanWeLootItem (|cff9d9d9d|Hitem:132204::::::::110:105::::::|h[Sticky Volatile Substance]|h|r) (0) (false)", -- [1865]
			"22:10:05 - Event: (LOOT_CLOSED)", -- [1866]
			"22:10:05 - ML event (CHAT_MSG_LOOT) (You receive loot: |cff9d9d9d|Hitem:132204::::::::110:105::::::|h[Sticky Volatile Substance]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3947) (nil) (0) (false) (false) (false) (false)", -- [1867]
			"22:10:15 - ML event (PLAYER_REGEN_ENABLED)", -- [1868]
			"22:10:20 - Event: (LOOT_OPENED) (1)", -- [1869]
			"22:10:20 - CanWeLootItem (|cff9d9d9d|Hitem:132234::::::::110:105::::::|h[Spectral Dust]|h|r) (0) (false)", -- [1870]
			"22:10:21 - OnLootSlotCleared() (1) (|cff9d9d9d|Hitem:132234::::::::110:105::::::|h[Spectral Dust]|h|r)", -- [1871]
			"22:10:21 - Event: (LOOT_CLOSED)", -- [1872]
			"22:10:21 - ML event (CHAT_MSG_LOOT) (You receive loot: |cff9d9d9d|Hitem:132234::::::::110:105::::::|h[Spectral Dust]|h|r.) () () () (Avernakis) () (0) (0) () (0) (3949) (nil) (0) (false) (false) (false) (false)", -- [1873]
			"22:10:51 - ML event (PLAYER_REGEN_ENABLED)", -- [1874]
			"22:10:54 - ML event (CHAT_MSG_LOOT) (Amrehlu receives loot: |cff9d9d9d|Hitem:132234::::::::110:105::::::|h[Spectral Dust]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (3958) (nil) (0) (false) (false) (false) (false)", -- [1875]
			"22:10:58 - ML event (CHAT_MSG_LOOT) (Freakeer receives loot: |cff9d9d9d|Hitem:132234::::::::110:105::::::|h[Spectral Dust]|h|r.) () () () (Freakeer) () (0) (0) () (0) (3960) (nil) (0) (false) (false) (false) (false)", -- [1876]
			"22:13:26 - ML event (CHAT_MSG_WHISPER) (promote me pls) (Chauric-Area52) () () (Chauric) () (0) (0) () (0) (3994) (Player-3676-08DA36E4) (0) (false) (false) (false) (false)", -- [1877]
			"22:13:42 - UpdateGroup (table: 000001AAF56A0A00)", -- [1878]
			"22:14:54 - Event: (ENCOUNTER_START) (2088) (Kin'garoth) (14) (14)", -- [1879]
			"22:14:54 - UpdatePlayersData()", -- [1880]
			"22:18:21 - ML event (CHAT_MSG_LOOT) (You receive item: |cffffffff|Hitem:153191::::::::110:105::::::|h[Cracked Fel-Spotted Egg]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4058) (nil) (0) (false) (false) (false) (false)", -- [1881]
			"22:23:44 - ML event (CHAT_MSG_LOOT) (You receive item: |cff0070dd|Hitem:151556::::::::110:105:8388608:3::56:::|h[Spoils of the Triumphant]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4112) (nil) (0) (false) (false) (false) (false)", -- [1882]
			"22:23:44 - Event: (ENCOUNTER_END) (2088) (Kin'garoth) (14) (14) (1)", -- [1883]
			"22:23:45 - ML event (PLAYER_REGEN_ENABLED)", -- [1884]
			"22:23:48 - Event: (LOOT_OPENED) (1)", -- [1885]
			"22:23:48 - CanWeLootItem (|cffa335ee|Hitem:151955::::::::110:105::3:4:3610:1808:1472:3528:::|h[Acrid Catalyst Injector]|h|r) (4) (true)", -- [1886]
			"22:23:48 - ML:AddItem (|cffa335ee|Hitem:151955::::::::110:105::3:4:3610:1808:1472:3528:::|h[Acrid Catalyst Injector]|h|r) (false) (1) (nil)", -- [1887]
			"22:23:48 - CanWeLootItem (|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets of the Antoran Vanquisher]|h|r) (4) (true)", -- [1888]
			"22:23:48 - ML:AddItem (|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets of the Antoran Vanquisher]|h|r) (false) (2) (nil)", -- [1889]
			"22:23:48 - CanWeLootItem (|cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's Fabricator]|h|r) (4) (true)", -- [1890]
			"22:23:48 - ML:AddItem (|cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's Fabricator]|h|r) (false) (3) (nil)", -- [1891]
			"22:23:48 - RCSessionFrame (enabled)", -- [1892]
			"22:23:50 - Comm received:^1^SEUBonusRoll^T^N1^SAmrehlu-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:253:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1893]
			"22:23:50 - ML:StartSession()", -- [1894]
			"22:23:50 - ML:AnnounceItems()", -- [1895]
			"22:23:50 - Comm received:^1^SlootTable^T^N1^T^N1^T^SequipLoc^S^Sgp^N530^Silvl^N930^Slink^S|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets~`of~`the~`Antoran~`Vanquisher]|h|r^Stexture^N132963^SlootSlot^N2^SsubType^SJunk^Srelic^b^Sclasses^N1192^Sname^SGauntlets~`of~`the~`Antoran~`Vanquisher^Stoken^SHandsSlot^Sboe^b^Sawarded^b^Squality^N4^t^N2^T^SequipLoc^SINVTYPE_TRINKET^Sgp^N992^Silvl^N935^Slink^S|cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's~`Fabricator]|h|r^Srelic^b^Stexture^N1769065^SsubType^SMiscellaneous^SlootSlot^N3^Sclasses^N4294967295^Sname^SForgefiend's~`Fabricator^Sboe^b^Sawarded^b^Squality^N4^t^N3^T^SequipLoc^SINVTYPE_TRINKET^Sgp^N1084^Silvl^N930^Slink^S|cffa335ee|Hitem:151955::::::::110:105::3:4:3610:1808:1472:3528:::|h[Acrid~`Catalyst~`Injector]|h|r^Srelic^b^Stexture^N1362636^SsubType^SMiscellaneous^SlootSlot^N1^Sclasses^N4294967295^Sname^SAcrid~`Catalyst~`Injector^Sboe^b^Sawarded^b^Squality^N4^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1896]
			"22:23:50 - SwitchSession (1)", -- [1897]
			"22:23:50 - SwitchSession (1)", -- [1898]
			"22:23:50 - GetPlayersGear (|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets of the Antoran Vanquisher]|h|r) (INVTYPE_HAND)", -- [1899]
			"22:23:50 - GetPlayersGear (|cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's Fabricator]|h|r) (INVTYPE_TRINKET)", -- [1900]
			"22:23:50 - GetPlayersGear (|cffa335ee|Hitem:151955::::::::110:105::3:4:3610:1808:1472:3528:::|h[Acrid Catalyst Injector]|h|r) (INVTYPE_TRINKET)", -- [1901]
			"22:23:50 - LootFrame:Start()", -- [1902]
			"22:23:50 - Restoring entry: (tier) (1)", -- [1903]
			"22:23:50 - Restoring entry: (normal) (1)", -- [1904]
			"22:23:50 - Restoring entry: (normal) (1)", -- [1905]
			"22:23:50 - GetPlayersGear (|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets of the Antoran Vanquisher]|h|r) ()", -- [1906]
			"22:23:50 - GetPlayersGear (|cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's Fabricator]|h|r) (INVTYPE_TRINKET)", -- [1907]
			"22:23:50 - GetPlayersGear (|cffa335ee|Hitem:151955::::::::110:105::3:4:3610:1808:1472:3528:::|h[Acrid Catalyst Injector]|h|r) (INVTYPE_TRINKET)", -- [1908]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^SGalastradra-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N846.199^Snew^N0^t^N2^T^Sequipped^N663.092^Snew^N264.263^t^N3^T^Sequipped^N663.092^Snew^N0^t^t^SspecID^N261^Straits^N75^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1909]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N-10^N2^N35^N3^N30^t^Sgear1^T^N1^Sitem:137320:5444:::::::110:105::35:3:3418:1592:3337^N2^Sitem:141482::::::::110:105::43:3:3573:1512:3337^N3^Sitem:141482::::::::110:105::43:3:3573:1512:3337^t^Sgear2^T^N2^Sitem:144258::::::::110:105:::2:3459:3630^N3^Sitem:144258::::::::110:105:::2:3459:3630^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1910]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^SAvernakis-Area52^N2^T^Sforged^N11^Spawn^T^N1^T^Sequipped^N838.391^Snew^N0^t^N2^T^Sequipped^N757.793^Snew^N244.015^t^N3^T^Sequipped^N757.793^Snew^N563.055^t^t^SspecID^N105^Straits^N75^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1911]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^SLesmes-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N55955.42^Snew^N0^t^N2^T^Sequipped^N239.926^Snew^N235.548^t^N3^T^Sequipped^N239.926^Snew^N538.039^t^t^SspecID^N63^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1912]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N10^N2^N-5^N3^N-10^t^Sgear1^T^N1^Sitem:147146::::::::110:63::5:3:3562:1502:3336^N2^Sitem:154177::::::::110:63::3:2:3983:3985^N3^Sitem:154177::::::::110:63::3:2:3983:3985^t^Sgear2^T^N2^Sitem:151955::::::::110:63::3:3:3610:1487:3337^N3^Sitem:151955::::::::110:63::3:3:3610:1487:3337^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1913]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N949.4375^N4^T^Sresponse^T^t^Sdiff^T^N1^N-20^N2^N10^N3^N5^t^Sgear1^T^N1^Sitem:152086::::::::110:261::3:3:3610:1492:3337^N2^Sitem:142167::151584::::::110:261::16:4:3418:1808:1537:3336^N3^Sitem:142167::151584::::::110:261::16:4:3418:1808:1537:3336^t^Sgear2^T^N2^Sitem:154174::::::::110:261::3:2:3983:3984^N3^Sitem:154174::::::::110:261::3:2:3983:3984^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1914]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-5^N2^N15^N3^N10^t^Sgear1^T^N1^Sitem:134467::::::::110:262::35:3:3418:1587:3337^N2^Sitem:134336::151580::::::110:262::43:5:3573:1808:604:1582:3336^N3^Sitem:134336::151580::::::110:262::43:5:3573:1808:604:1582:3336^t^Sgear2^T^N2^Sitem:147019::151580::::::110:262::5:4:3562:1808:1507:3528^N3^Sitem:147019::151580::::::110:262::5:4:3562:1808:1507:3528^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1915]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^SFreakeer-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N725.154^Snew^N0^t^N2^T^Sequipped^N554.653^Snew^N254.39^t^N3^T^Sequipped^N554.653^Snew^N533.113^t^t^SspecID^N262^Straits^N74^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [1916]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^N2^N35^N3^N30^t^Sgear1^T^N1^Sitem:152150:5444:::::::110:66::3:3:3610:1472:3528^N2^Sitem:151974::::::::110:66::5:4:3611:1487:3528:3618^N3^Sitem:151974::::::::110:66::5:4:3611:1487:3528:3618^t^Sgear2^T^N2^Sitem:128711::::::::110:66::13:3:689:601:679^N3^Sitem:128711::::::::110:66::13:3:689:601:679^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1917]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^STuyen-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N729.623^Snew^N0^t^N2^T^Sequipped^N98.274^Snew^N159.199^t^N3^T^Sequipped^N98.274^Snew^N0^t^t^SspecID^N66^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1918]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N5^N2^N15^N3^N10^t^Sgear1^T^N1^Sitem:147032::::::::110:577::5:3:3562:1507:3336^N2^Sitem:151968::::::::110:577::3:3:3610:1477:3336^N3^Sitem:151968::::::::110:577::3:3:3610:1477:3336^t^Sgear2^T^N2^Sitem:147009::::::::110:577::5:3:3562:1502:3336^N3^Sitem:147009::::::::110:577::5:3:3562:1502:3336^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1919]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N423.795^Snew^N0^t^N2^T^Sequipped^N205.122^Snew^N227.373^t^N3^T^Sequipped^N205.122^Snew^N375.804^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1920]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N913.3125^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N45^N2^N70^N3^N65^t^Sgear1^T^N1^Sitem:152751::::::::110:65:::5:1684:1808:3629:1477:3336^N2^Sitem:139322::::::::110:65::3:3:1807:1487:3337^N3^Sitem:139322::::::::110:65::3:3:1807:1487:3337^t^Sgear2^T^N2^Sitem:134336::::::::110:65::43:4:3573:604:1572:3528^N3^Sitem:134336::::::::110:65::43:4:3573:604:1572:3528^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1921]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^SAmrehlu-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N615.236^Snew^N0^t^N2^T^Sequipped^N604.917^Snew^N308.943^t^N3^T^Sequipped^N604.917^Snew^N0^t^t^SspecID^N253^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1922]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^SLithelasha-Area52^N2^T^Sforged^N10^Spawn^T^N1^T^Sequipped^N503.279^Snew^N0^t^N2^T^Sequipped^N38955.84^Snew^N194.306^t^N3^T^Sequipped^N38955.84^Snew^N0^t^t^SspecID^N577^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1923]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^SDibbs-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N96668.18^Snew^N0^t^N2^T^Sequipped^N49341.12^Snew^N254.39^t^N3^T^Sequipped^N49341.12^Snew^N533.113^t^t^SspecID^N262^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1924]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SSulana-Area52^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1925]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^N2^N5^N3^N0^t^Sgear1^T^N1^Sitem:147129:5444:::::::110:577::5:3:3562:1497:3528^N2^Sitem:151190::::::::110:577::5:3:3562:1512:3336^N3^Sitem:151190::::::::110:577::5:3:3562:1512:3336^t^Sgear2^T^N2^Sitem:154174::::::::110:577::3:2:3983:3985^N3^Sitem:154174::::::::110:577::3:2:3983:3985^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1926]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SDibbs-Area52^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1927]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N10^N2^N25^N3^N20^t^Sgear1^T^N1^Sitem:147141:5446:::::::110:253::5:3:3562:1502:3336^N2^Sitem:154174::::::::110:253::3:2:3983:3984^N3^Sitem:154174::::::::110:253::3:2:3983:3984^t^Sgear2^T^N2^Sitem:141482::::::::110:253::43:4:42:3573:1522:3528^N3^Sitem:141482::::::::110:253::43:4:42:3573:1522:3528^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1928]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^SPhryke-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N669.889^Snew^N0^t^N2^T^Sequipped^N264.494^Snew^N301.479^t^N3^T^Sequipped^N264.494^Snew^N476.41^t^t^SspecID^N265^Straits^N69^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1929]
			"22:23:51 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.9375^Sresponse^SAUTOPASS^Sdiff^N15^SspecID^N270^Sgear1^S|cffa335ee|Hitem:147153::::::::110:270::5:3:3562:1497:3528:::|h[Xuen's~`Gauntlets]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1930]
			"22:23:51 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.9375^Sgear2^S|cffa335ee|Hitem:151970::::::::110:270::3:4:3610:1808:1477:3336:::|h[Vitality~`Resonator]|h|r^Sdiff^N0^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151956::::::::110:270::5:3:3611:1487:3528:::|h[Garothi~`Feedback~`Conduit]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1931]
			"22:23:51 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.9375^Sgear2^S|cffa335ee|Hitem:151970::::::::110:270::3:4:3610:1808:1477:3336:::|h[Vitality~`Resonator]|h|r^Sdiff^N-5^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151956::::::::110:270::5:3:3611:1487:3528:::|h[Garothi~`Feedback~`Conduit]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1932]
			"22:23:51 - Comm received:^1^SextraUtilData^T^N1^SDravash-Area52^N2^T^Sforged^N9^Spawn^T^t^SspecID^N252^Straits^N68^Slegend^N2^Ssockets^N6^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1933]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N10^N2^N35^N3^N30^t^Sgear1^T^N1^Sitem:147153:5444:::::::110:268::5:3:3562:1502:3336^N2^Sitem:128711::::::::110:268::13:3:689:600:679^N3^Sitem:128711::::::::110:268::13:3:689:600:679^t^Sgear2^T^N2^Sitem:147024::::::::110:268::5:3:3562:1497:3528^N3^Sitem:147024::::::::110:268::5:3:3562:1497:3528^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1934]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SDravash-Area52^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1935]
			"22:23:51 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^N2^N35^N3^N30^t^Sgear1^T^N1^Sitem:141470:5444:151584::::::110:265::43:4:1808:3573:1527:3336^N2^Sitem:142165::151584::::::110:265::35:4:3417:1808:1542:3337^N3^Sitem:142165::151584::::::110:265::35:4:3417:1808:1542:3337^t^Sgear2^T^N2^Sitem:147017::::::::110:265::3:3:3561:1482:3528^N3^Sitem:147017::::::::110:265::3:3:3561:1482:3528^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1936]
			"22:23:52 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^Sdiff^N-70^SspecID^N262^Sgear1^S|cffff8000|Hitem:151819:5447:::::::110:262:::2:1811:3630:::|h[Smoldering~`Heart]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1937]
			"22:23:52 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.5^Sdiff^N-5^SspecID^N252^Sgear1^S|cffa335ee|Hitem:134509:5447:::::::110:252::35:3:3418:1587:3337:::|h[Fists~`of~`the~`Legion]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1938]
			"22:23:52 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sgear2^S|cffa335ee|Hitem:144480::::::::110:262::35:3:3418:1592:3337:::|h[Dreadstone~`of~`Endless~`Shadows]|h|r^Sdiff^N-5^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147002::::::::110:262::5:3:3562:1527:3337:::|h[Charm~`of~`the~`Rising~`Tide]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1939]
			"22:23:52 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.5^Sgear2^S|cffa335ee|Hitem:147009::::::::110:252::5:3:3562:1502:3336:::|h[Infernal~`Cinders]|h|r^Sdiff^N15^SspecID^N252^Sgear1^S|cffa335ee|Hitem:151190::151580::::::110:252::5:4:3562:1808:1507:3528:::|h[Specter~`of~`Betrayal]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1940]
			"22:23:53 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sgear2^S|cffa335ee|Hitem:144480::::::::110:262::35:3:3418:1592:3337:::|h[Dreadstone~`of~`Endless~`Shadows]|h|r^Sdiff^N-10^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147002::::::::110:262::5:3:3562:1527:3337:::|h[Charm~`of~`the~`Rising~`Tide]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1941]
			"22:23:53 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.5^Sgear2^S|cffa335ee|Hitem:147009::::::::110:252::5:3:3562:1502:3336:::|h[Infernal~`Cinders]|h|r^Sdiff^N10^SspecID^N252^Sgear1^S|cffa335ee|Hitem:151190::151580::::::110:252::5:4:3562:1808:1507:3528:::|h[Specter~`of~`Betrayal]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1942]
			"22:23:53 - LootFrame:Response (2) (Response:) (2nd Set Piece)", -- [1943]
			"22:23:53 - SendResponse (group) (1) (2) (true) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [1944]
			"22:23:53 - Trashing entry: (1) (|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets of the Antoran Vanquisher]|h|r)", -- [1945]
			"22:23:56 - Comm received:^1^Sresponse^T^N1^N1^N2^SLesmes-Area52^N3^T^Sresponse^N2^SisTier^B^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1946]
			"22:23:56 - Comm received:^1^Sresponse^T^N1^N1^N2^SAvernakis-Area52^N3^T^Sresponse^N2^SisTier^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1947]
			"22:23:57 - Comm received:^1^Sresponse^T^N1^N2^N2^SAhoyful-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1948]
			"22:23:57 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Sresponse^N1^SisTier^B^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1949]
			"22:24:00 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Sresponse^N1^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1950]
			"22:24:01 - Comm received:^1^Sresponse^T^N1^N3^N2^SLesmes-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1951]
			"22:24:01 - Comm received:^1^Sresponse^T^N1^N2^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1952]
			"22:24:01 - Comm received:^1^Sresponse^T^N1^N3^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1953]
			"22:24:01 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1954]
			"22:24:03 - Comm received:^1^Sresponse^T^N1^N2^N2^SLesmes-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [1955]
			"22:24:03 - Comm received:^1^Soffline_timer^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1956]
			"22:24:03 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1957]
			"22:24:04 - Comm received:^1^Sresponse^T^N1^N2^N2^SGalastradra-Area52^N3^T^Snote^SBest~`in~`Slot~`for~`Sub/Outlaw^Sresponse^N1^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1958]
			"22:24:05 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [1959]
			"22:24:05 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [1960]
			"22:24:06 - LootFrame:Response (3) (Response:) (Offspec)", -- [1961]
			"22:24:06 - SendResponse (group) (2) (3) (nil) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [1962]
			"22:24:06 - Trashing entry: (1) (|cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's Fabricator]|h|r)", -- [1963]
			"22:24:06 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Sresponse^N3^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [1964]
			"22:24:06 - Comm received:^1^Sresponse^T^N1^N2^N2^SAvernakis-Area52^N3^T^Sresponse^N3^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1965]
			"22:24:06 - Comm received:^1^Sresponse^T^N1^N1^N2^SGalastradra-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1966]
			"22:24:07 - Comm received:^1^Sresponse^T^N1^N3^N2^SVelynila-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1967]
			"22:24:07 - Comm received:^1^Sresponse^T^N1^N2^N2^SPhryke-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1968]
			"22:24:09 - Comm received:^1^Sresponse^T^N1^N3^N2^SGalastradra-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [1969]
			"22:24:09 - Comm received:^1^Sresponse^T^N1^N3^N2^SAhoyful-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [1970]
			"22:24:12 - ML event (CHAT_MSG_LOOT) (Lithelasha receives bonus loot: |cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's Fabricator]|h|r.) () () () (Lithelasha) () (0) (0) () (0) (4124) (nil) (0) (false) (false) (false) (false)", -- [1971]
			"22:24:12 - Comm received:^1^SEUBonusRoll^T^N1^SLithelasha-Area52^N2^Sitem^N3^S|cffa335ee|Hitem:151963::::::::110:577::3:3:3610:1477:3336:::|h[Forgefiend's~`Fabricator]|h|r^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [1972]
			"22:24:12 - Comm received:^1^Sresponse^T^N1^N2^N2^SChauric-Area52^N3^T^Sresponse^N3^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1973]
			"22:24:12 - Comm received:^1^Sresponse^T^N1^N3^N2^SPhryke-Area52^N3^T^Sresponse^N1^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [1974]
			"22:24:14 - LootFrame:Response (3) (Response:) (Offspec)", -- [1975]
			"22:24:14 - SendResponse (group) (3) (3) (nil) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [1976]
			"22:24:14 - Trashing entry: (1) (|cffa335ee|Hitem:151955::::::::110:105::3:4:3610:1808:1472:3528:::|h[Acrid Catalyst Injector]|h|r)", -- [1977]
			"22:24:14 - Comm received:^1^Sresponse^T^N1^N2^N2^SVelynila-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1978]
			"22:24:14 - Comm received:^1^Sresponse^T^N1^N3^N2^SAvernakis-Area52^N3^T^Sresponse^N3^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1979]
			"22:24:19 - Comm received:^1^Sresponse^T^N1^N3^N2^SChauric-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [1980]
			"22:24:22 - Event: (LOOT_CLOSED)", -- [1981]
			"22:24:22 - BONUS_ROLL_RESULT (item) (|cffa335ee|Hitem:152051::::::::110:105::3:3:3610:1472:3528:::|h[Eidolon of Life]|h|r) (1) (0) (2) (false)", -- [1982]
			"22:24:22 - ML event (CHAT_MSG_LOOT) (You receive bonus loot: |cffa335ee|Hitem:152051::::::::110:105::3:3:3610:1472:3528:::|h[Eidolon of Life]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4126) (nil) (0) (false) (false) (false) (false)", -- [1983]
			"22:24:22 - Comm received:^1^SEUBonusRoll^T^N1^SAvernakis-Area52^N2^Sitem^N3^S|cffa335ee|Hitem:152051::::::::110:105::3:3:3610:1472:3528:::|h[Eidolon~`of~`Life]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1984]
			"22:24:26 - Comm received:^1^SEUBonusRoll^T^N1^SVelynila-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:577:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Velynila) (distri:) (RAID)", -- [1985]
			"22:24:33 - SwitchSession (2)", -- [1986]
			"22:24:35 - Event: (LOOT_OPENED) (1)", -- [1987]
			"22:24:36 - Comm received:^1^Sresponse^T^N1^N2^N2^STuyen-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1988]
			"22:24:36 - Comm received:^1^Sresponse^T^N1^N3^N2^STuyen-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [1989]
			"22:24:37 - SwitchSession (3)", -- [1990]
			"22:24:38 - SwitchSession (1)", -- [1991]
			"22:24:41 - Comm received:^1^Sresponse^T^N1^N2^N2^SAmrehlu-Area52^N3^T^Snote^SMM^Sresponse^N3^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [1992]
			"22:24:43 - ReannounceOrRequestRoll (function: 000001A9BAAF0E70) (function: 000001AB69F36610) (true) (false) (false)", -- [1993]
			"22:24:43 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^SINVTYPE_HAND^Silvl^N930^Slink^S|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets~`of~`the~`Antoran~`Vanquisher]|h|r^SisRoll^B^Sclasses^N1192^Sname^SGauntlets~`of~`the~`Antoran~`Vanquisher^Stoken^SHandsSlot^SnoAutopass^b^Srelic^b^Ssession^N1^Stexture^N132963^t^t^t^^ (from:) (Avernakis) (distri:) (WHISPER)", -- [1994]
			"22:24:43 - GetPlayersGear (|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets of the Antoran Vanquisher]|h|r) (INVTYPE_HAND)", -- [1995]
			"22:24:43 - LootFrame:ReRoll(#table) (1)", -- [1996]
			"22:24:43 - LootFrame:Start()", -- [1997]
			"22:24:43 - Restoring entry: (roll) (1)", -- [1998]
			"22:24:43 - Comm received:^1^Srolls^T^N1^N1^N2^T^SAvernakis-Area52^S^SLesmes-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [1999]
			"22:24:43 - Comm received:^1^Sresponse^T^N1^N3^N2^SFreakeer-Area52^N3^T^Sresponse^N2^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2000]
			"22:24:43 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N-10^t^Sgear1^T^N1^Sitem:137320:5444:::::::110:105::35:3:3418:1592:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2001]
			"22:24:43 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N10^t^Sgear1^T^N1^Sitem:147146::::::::110:63::5:3:3562:1502:3336^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2002]
			"22:24:46 - Comm received:^1^Sroll^T^N1^SLesmes-Area52^N2^N1^N3^T^N1^N1^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2003]
			"22:24:48 - Comm received:^1^Sroll^T^N1^SAvernakis-Area52^N2^N99^N3^T^N1^N1^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2004]
			"22:24:48 - Trashing entry: (1) (|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets of the Antoran Vanquisher]|h|r)", -- [2005]
			"22:24:48 - Comm received:^1^Sresponse^T^N1^N3^N2^SAmrehlu-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2006]
			"22:24:48 - Comm received:^1^Sresponse^T^N1^N2^N2^SFreakeer-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2007]
			"22:24:51 - ML event (CHAT_MSG_LOOT) (Sulana receives bonus loot: |cffa335ee|Hitem:152412::::::::110:105::3:3:3610:1472:3528:::|h[Depraved Machinist's Footpads]|h|r.) () () () (Sulana) () (0) (0) () (0) (4137) (nil) (0) (false) (false) (false) (false)", -- [2008]
			"22:24:55 - ML:Award (1) (Avernakis-Area52) (2nd Set Piece) (nil)", -- [2009]
			"22:24:55 - GiveMasterLoot (2) (5)", -- [2010]
			"22:24:55 - LootSlot (2)", -- [2011]
			"22:24:55 - OnLootSlotCleared() (2) (|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets of the Antoran Vanquisher]|h|r)", -- [2012]
			"22:24:55 - ML:TrackAndLogLoot()", -- [2013]
			"22:24:55 - ML event (CHAT_MSG_LOOT) (You receive loot: |cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets of the Antoran Vanquisher]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4138) (nil) (0) (false) (false) (false) (false)", -- [2014]
			"22:24:55 - Comm received:^1^Shistory^T^N1^SAvernakis-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SDRUID^SgroupSize^N14^Svotes^N0^Stime^S22:24:55^SitemReplaced1^S|cffa335ee|Hitem:137320:5444:::::::110:105::35:3:3418:1592:3337:::|h[Gloves~`of~`Vile~`Defiance]|h|r^Sid^S1512807895-18^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^S2nd~`Set~`Piece^StokenRoll^B^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets~`of~`the~`Antoran~`Vanquisher]|h|r^StierToken^SHandsSlot^SisAwardReason^b^SresponseID^N2^Sboss^SKin'garoth^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2015]
			"22:24:55 - Comm received:^1^Sawarded^T^N1^N1^N2^SAvernakis-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2016]
			"22:24:55 - SwitchSession (2)", -- [2017]
			"22:24:56 - GetLootDBStatistics()", -- [2018]
			"22:24:56 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets~`of~`the~`Antoran~`Vanquisher]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2019]
			"22:25:17 - ML:Award (2) (Galastradra-Area52) (Major Upgrade (10%+)) (nil)", -- [2020]
			"22:25:17 - GiveMasterLoot (3) (1)", -- [2021]
			"22:25:17 - OnLootSlotCleared() (3) (|cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's Fabricator]|h|r)", -- [2022]
			"22:25:17 - ML:TrackAndLogLoot()", -- [2023]
			"22:25:17 - Comm received:^1^Shistory^T^N1^SGalastradra-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SROGUE^SgroupSize^N14^Sboss^SKin'garoth^Stime^S22:25:17^SitemReplaced1^S|cffa335ee|Hitem:142167::151584::::::110:105::16:4:3418:1808:1537:3336:::|h[Eye~`of~`Command]|h|r^Sid^S1512807917-19^Snote^SBest~`in~`Slot~`for~`Sub/Outlaw^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SMajor~`Upgrade~`(10%+)^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's~`Fabricator]|h|r^SisAwardReason^b^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^SresponseID^N1^SitemReplaced2^S|cffa335ee|Hitem:154174::::::::110:105::3:2:3983:3984:::|h[Golganneth's~`Vitality]|h|r^Svotes^N0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2024]
			"22:25:17 - Comm received:^1^Sawarded^T^N1^N2^N2^SGalastradra-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2025]
			"22:25:17 - SwitchSession (3)", -- [2026]
			"22:25:19 - GetLootDBStatistics()", -- [2027]
			"22:25:22 - ML event (CHAT_MSG_LOOT) (Galastradra receives loot: |cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's Fabricator]|h|r.) () () () ()", -- [2028]
			"22:25:26 - ReannounceOrRequestRoll (function: 000001A9BF0866A0) (function: 000001AB6AEC27F0) (true) (false) (false)", -- [2029]
			"22:25:29 - Comm received:^1^Srolls^T^N1^N3^N2^T^SPhryke-Area52^S^SSulana-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2030]
			"22:25:30 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.9375^Sgear2^S|cffa335ee|Hitem:151970::::::::110:270::3:4:3610:1808:1477:3336:::|h[Vitality~`Resonator]|h|r^Sdiff^N-5^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151956::::::::110:270::5:3:3611:1487:3528:::|h[Garothi~`Feedback~`Conduit]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2031]
			"22:25:30 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N935.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N30^t^Sgear1^T^N1^Sitem:142165::151584::::::110:265::35:4:3417:1808:1542:3337^t^Sgear2^T^N1^Sitem:147017::::::::110:265::3:3:3561:1482:3528^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2032]
			"22:25:33 - Comm received:^1^Sroll^T^N1^SPhryke-Area52^N2^N50^N3^T^N1^N3^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2033]
			"22:25:58 - UpdateGroup (table: 000001AAF56A0A00)", -- [2034]
			"22:26:02 - ML:Award (3) (Phryke-Area52) (Major Upgrade (10%+)) (nil)", -- [2035]
			"22:26:02 - GiveMasterLoot (1) (4)", -- [2036]
			"22:26:02 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:151955::::::::110:105::3:4:3610:1808:1472:3528:::|h[Acrid Catalyst Injector]|h|r)", -- [2037]
			"22:26:02 - ML:TrackAndLogLoot()", -- [2038]
			"22:26:02 - Event: (LOOT_CLOSED)", -- [2039]
			"22:26:02 - Event: (LOOT_CLOSED)", -- [2040]
			"22:26:02 - Comm received:^1^Shistory^T^N1^SPhryke-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SWARLOCK^SgroupSize^N14^Sboss^SKin'garoth^Stime^S22:26:02^SitemReplaced1^S|cffa335ee|Hitem:142165::151584::::::110:105::35:4:3417:1808:1542:3337:::|h[Deteriorated~`Construct~`Core]|h|r^Sid^S1512807962-20^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SMajor~`Upgrade~`(10%+)^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:151955::::::::110:105::3:4:3610:1808:1472:3528:::|h[Acrid~`Catalyst~`Injector]|h|r^SisAwardReason^b^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^SresponseID^N1^SitemReplaced2^S|cffa335ee|Hitem:147017::::::::110:105::3:3:3561:1482:3528:::|h[Tarnished~`Sentinel~`Medallion]|h|r^Svotes^N0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2041]
			"22:26:02 - Comm received:^1^Sawarded^T^N1^N3^N2^SPhryke-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2042]
			"22:26:02 - SwitchSession (3)", -- [2043]
			"22:26:03 - ML:EndSession()", -- [2044]
			"22:26:03 - GetLootDBStatistics()", -- [2045]
			"22:26:03 - Comm received:^1^Ssession_end^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2046]
			"22:26:03 - RCVotingFrame:EndSession (false)", -- [2047]
			"22:26:05 - Hide VotingFrame", -- [2048]
			"22:26:07 - ML event (CHAT_MSG_LOOT) (Phryke receives loot: |cffa335ee|Hitem:151955::::::::110:105::3:4:3610:1808:1472:3528:::|h[Acrid Catalyst Injector]|h|r.) () () () ()", -- [2049]
			"22:26:28 - ML event (CHAT_MSG_LOOT) (You receive item: |cffa335ee|Hitem:152126::::::::110:105::3:3:3610:1472:3528:::|h[Bearmantle Paws]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4154) (nil) (0) (false) (false) (false) (false)", -- [2050]
			"22:27:23 - UpdateGroup (table: 000001AAF56A0A00)", -- [2051]
			"22:27:40 - ML event (CHAT_MSG_LOOT) (Velynila receives loot: |cff9d9d9d|Hitem:132216::::::::110:105::::::|h[Charged Dust]|h|r.) () () () (Velynila) () (0) (0) () (0) (4162) (nil) (0) (false) (false) (false) (false)", -- [2052]
			"22:28:36 - ML event (PLAYER_REGEN_ENABLED)", -- [2053]
			"22:28:40 - ML event (CHAT_MSG_LOOT) (Lithelasha receives loot: |cff9d9d9d|Hitem:132204::::::::110:105::::::|h[Sticky Volatile Substance]|h|r.) () () () (Lithelasha) () (0) (0) () (0) (4170) (nil) (0) (false) (false) (false) (false)", -- [2054]
			"22:28:42 - ML event (CHAT_MSG_LOOT) (Phryke receives loot: |cff9d9d9d|Hitem:132204::::::::110:105::::::|h[Sticky Volatile Substance]|h|r.) () () () (Phryke) () (0) (0) () (0) (4171) (nil) (0) (false) (false) (false) (false)", -- [2055]
			"22:29:24 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:5512::::::::110:105::3::::|h[Healthstone]|h|r.) () () () (Chauric) () (0) (0) () (0) (4182) (nil) (0) (false) (false) (false) (false)", -- [2056]
			"22:30:59 - ML event (TRADE_SHOW)", -- [2057]
			"22:31:10 - ML event (TRADE_ACCEPT_UPDATE) (1) (0)", -- [2058]
			"22:31:12 - ML event (TRADE_CLOSED)", -- [2059]
			"22:31:12 - ML event (TRADE_CLOSED)", -- [2060]
			"22:31:12 - ML event (UI_INFO_MESSAGE) (226) (Trade complete.)", -- [2061]
			"22:31:30 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|rx2.) () () () (Avernakis) () (0) (0) () (0) (4194) (nil) (0) (false) (false) (false) (false)", -- [2062]
			"22:31:32 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4197) (nil) (0) (false) (false) (false) (false)", -- [2063]
			"22:31:34 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4199) (nil) (0) (false) (false) (false) (false)", -- [2064]
			"22:31:36 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4201) (nil) (0) (false) (false) (false) (false)", -- [2065]
			"22:31:38 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4203) (nil) (0) (false) (false) (false) (false)", -- [2066]
			"22:31:40 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4205) (nil) (0) (false) (false) (false) (false)", -- [2067]
			"22:31:42 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4207) (nil) (0) (false) (false) (false) (false)", -- [2068]
			"22:31:45 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4209) (nil) (0) (false) (false) (false) (false)", -- [2069]
			"22:31:47 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4211) (nil) (0) (false) (false) (false) (false)", -- [2070]
			"22:31:49 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4213) (nil) (0) (false) (false) (false) (false)", -- [2071]
			"22:31:51 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4215) (nil) (0) (false) (false) (false) (false)", -- [2072]
			"22:31:53 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|rx2.) () () () (Avernakis) () (0) (0) () (0) (4217) (nil) (0) (false) (false) (false) (false)", -- [2073]
			"22:31:55 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|rx2.) () () () (Avernakis) () (0) (0) () (0) (4219) (nil) (0) (false) (false) (false) (false)", -- [2074]
			"22:31:57 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4221) (nil) (0) (false) (false) (false) (false)", -- [2075]
			"22:31:59 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4223) (nil) (0) (false) (false) (false) (false)", -- [2076]
			"22:32:01 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4225) (nil) (0) (false) (false) (false) (false)", -- [2077]
			"22:32:03 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4227) (nil) (0) (false) (false) (false) (false)", -- [2078]
			"22:32:03 - ML event (CHAT_MSG_LOOT) (You create: |cffffffff|Hitem:127846::::::::110:105::::::|h[Leytorrent Potion]|h|rx3.) () () () (Avernakis) () (0) (0) () (0) (4228) (nil) (0) (false) (false) (false) (false)", -- [2079]
			"22:33:10 - ML event (CHAT_MSG_LOOT) (You receive item: |cffffffff|Hitem:127858::::::::110:105::::::|h[Spirit Flask]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4238) (nil) (0) (false) (false) (false) (false)", -- [2080]
			"22:33:14 - ML event (CHAT_MSG_LOOT) (You receive item: |cffffffff|Hitem:127858::::::::110:105::::::|h[Spirit Flask]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4240) (nil) (0) (false) (false) (false) (false)", -- [2081]
			"22:34:08 - Event: (ENCOUNTER_START) (2069) (Varimathras) (14) (14)", -- [2082]
			"22:34:08 - UpdatePlayersData()", -- [2083]
			"22:38:25 - ML event (CHAT_MSG_LOOT) (You receive item: |cff0070dd|Hitem:151556::::::::110:105:8388608:3::56:::|h[Spoils of the Triumphant]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4318) (nil) (0) (false) (false) (false) (false)", -- [2084]
			"22:38:25 - Event: (ENCOUNTER_END) (2069) (Varimathras) (14) (14) (1)", -- [2085]
			"22:38:25 - ML event (PLAYER_REGEN_ENABLED)", -- [2086]
			"22:38:33 - Event: (LOOT_OPENED) (1)", -- [2087]
			"22:38:33 - CanWeLootItem (|cffa335ee|Hitem:151964::::::::110:105::3:3:3610:1482:3336:::|h[Seeping Scourgewing]|h|r) (4) (true)", -- [2088]
			"22:38:33 - ML:AddItem (|cffa335ee|Hitem:151964::::::::110:105::3:3:3610:1482:3336:::|h[Seeping Scourgewing]|h|r) (false) (1) (nil)", -- [2089]
			"22:38:33 - CanWeLootItem (|cffa335ee|Hitem:152281::::::::110:105::3:3:3610:1477:3336:::|h[Varimathras' Shattered Manacles]|h|r) (4) (true)", -- [2090]
			"22:38:33 - ML:AddItem (|cffa335ee|Hitem:152281::::::::110:105::3:3:3610:1477:3336:::|h[Varimathras' Shattered Manacles]|h|r) (false) (2) (nil)", -- [2091]
			"22:38:33 - CanWeLootItem (|cffa335ee|Hitem:152092::::::::110:105::3:3:3610:1472:3528:::|h[Nathrezim Incisor]|h|r) (4) (true)", -- [2092]
			"22:38:33 - ML:AddItem (|cffa335ee|Hitem:152092::::::::110:105::3:3:3610:1472:3528:::|h[Nathrezim Incisor]|h|r) (false) (3) (nil)", -- [2093]
			"22:38:33 - RCSessionFrame (enabled)", -- [2094]
			"22:38:35 - ML:StartSession()", -- [2095]
			"22:38:35 - ML:AnnounceItems()", -- [2096]
			"22:38:35 - Comm received:^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_WRIST^Sgp^N444^Silvl^N935^Slink^S|cffa335ee|Hitem:152281::::::::110:105::3:3:3610:1477:3336:::|h[Varimathras'~`Shattered~`Manacles]|h|r^Srelic^b^Stexture^N1561258^SsubType^SPlate^SlootSlot^N2^Sclasses^N4294967295^Sname^SVarimathras'~`Shattered~`Manacles^Sboe^b^Sawarded^b^Squality^N4^t^N2^T^SequipLoc^SINVTYPE_TRINKET^Sgp^N1114^Silvl^N940^Slink^S|cffa335ee|Hitem:151964::::::::110:105::3:3:3610:1482:3336:::|h[Seeping~`Scourgewing]|h|r^Srelic^b^Stexture^N132105^SsubType^SMiscellaneous^SlootSlot^N1^Sclasses^N4294967295^Sname^SSeeping~`Scourgewing^Sboe^b^Sawarded^b^Squality^N4^t^N3^T^SequipLoc^S^Sgp^N472^Silvl^N930^Slink^S|cffa335ee|Hitem:152092::::::::110:105::3:3:3610:1472:3528:::|h[Nathrezim~`Incisor]|h|r^Srelic^SBlood^Stexture^N136231^SsubType^SArtifact~`Relic^SlootSlot^N3^Sclasses^N4294967295^Sname^SNathrezim~`Incisor^Sboe^b^Sawarded^b^Squality^N4^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2097]
			"22:38:35 - SwitchSession (1)", -- [2098]
			"22:38:35 - SwitchSession (1)", -- [2099]
			"22:38:35 - Autopassed on:  (|cffa335ee|Hitem:152281::::::::110:105::3:3:3610:1477:3336:::|h[Varimathras' Shattered Manacles]|h|r)", -- [2100]
			"22:38:35 - NewRelicAutopassCheck (|cffa335ee|Hitem:152092::::::::110:105::3:3:3610:1472:3528:::|h[Nathrezim Incisor]|h|r) (Blood)", -- [2101]
			"22:38:35 - GetPlayersGear (|cffa335ee|Hitem:152281::::::::110:105::3:3:3610:1477:3336:::|h[Varimathras' Shattered Manacles]|h|r) (INVTYPE_WRIST)", -- [2102]
			"22:38:35 - GetPlayersGear (|cffa335ee|Hitem:151964::::::::110:105::3:3:3610:1482:3336:::|h[Seeping Scourgewing]|h|r) (INVTYPE_TRINKET)", -- [2103]
			"22:38:35 - LootFrame:Start()", -- [2104]
			"22:38:35 - Restoring entry: (normal) (1)", -- [2105]
			"22:38:35 - Restoring entry: (relic) (2)", -- [2106]
			"22:38:35 - GetPlayersGear (|cffa335ee|Hitem:152281::::::::110:105::3:3:3610:1477:3336:::|h[Varimathras' Shattered Manacles]|h|r) (INVTYPE_WRIST)", -- [2107]
			"22:38:35 - GetPlayersGear (|cffa335ee|Hitem:151964::::::::110:105::3:3:3610:1482:3336:::|h[Seeping Scourgewing]|h|r) (INVTYPE_TRINKET)", -- [2108]
			"22:38:35 - GetPlayersGear (|cffa335ee|Hitem:152092::::::::110:105::3:3:3610:1472:3528:::|h[Nathrezim Incisor]|h|r) ()", -- [2109]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^SGalastradra-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N653.239^Snew^N0^t^N2^T^Sequipped^N264.263^Snew^N261.441^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N261^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2110]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N321.211^Snew^N441.204^t^N2^T^Sequipped^N205.122^Snew^N203.968^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2111]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^SLithelasha-Area52^N2^T^Sforged^N10^Spawn^T^N1^T^Sequipped^N45066.03^Snew^N0^t^N2^T^Sequipped^N38955.84^Snew^N215.276^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2112]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N913.3125^N4^T^Sresponse^T^N3^B^t^Sdiff^T^N1^N50^N2^N75^N3^N0^t^Sgear1^T^N1^Sitem:152752::::::::110:65:::4:1691:3629:1477:3336^N2^Sitem:139322::::::::110:65::3:3:1807:1487:3337^t^Sgear2^T^N2^Sitem:134336::::::::110:65::43:4:3573:604:1572:3528^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2113]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N0^N2^N20^N3^N0^t^Sgear1^T^N1^Sitem:149701::::::::110:262::43:4:3573:1708:1597:3337^N2^Sitem:134336::151580::::::110:262::43:5:3573:1808:604:1582:3336^t^Sgear2^T^N2^Sitem:147019::151580::::::110:262::5:4:3562:1808:1507:3528^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2114]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^SFreakeer-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N535.935^Snew^N0^t^N2^T^Sequipped^N554.653^Snew^N273.09^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N74^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2115]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^SPhryke-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N848.109^Snew^N0^t^N2^T^Sequipped^N476.41^Snew^N225.379^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N265^Straits^N69^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2116]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^SLesmes-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N901.731^Snew^N0^t^N2^T^Sequipped^N239.926^Snew^N267.421^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N63^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2117]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N0^N2^N10^N3^N0^t^Sgear1^T^N1^Sitem:134192::::::::110:577::35:3:3418:1597:3337^N2^Sitem:151190::::::::110:577::5:3:3562:1512:3336^t^Sgear2^T^N2^Sitem:154174::::::::110:577::3:2:3983:3985^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2118]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N941.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-10^N2^N40^N3^N0^t^Sgear1^T^N1^Sitem:134461::::::::110:105::35:3:3418:1597:3337^N2^Sitem:141482::::::::110:105::43:3:3573:1512:3337^t^Sgear2^T^N2^Sitem:144258::::::::110:105:::2:3459:3630^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2119]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^SAvernakis-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N637.696^Snew^N0^t^N2^T^Sequipped^N757.793^Snew^N265.234^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N105^Straits^N75^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2120]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N-65^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:132406::::::::110:63:::2:3459:3630^N2^Sitem:154177::::::::110:63::3:2:3983:3985^t^Sgear2^T^N2^Sitem:151955::::::::110:63::3:3:3610:1487:3337^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2121]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SSulana-Area52^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2122]
			"22:38:35 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^Sdiff^N20^SspecID^N270^Sgear1^S|cffa335ee|Hitem:152754::151584::::::110:270:::5:1706:1808:3629:1507:3337:::|h[Arinor~`Keeper's~`Armbands~`of~`the~`Aurora]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2123]
			"22:38:35 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sgear2^S|cffa335ee|Hitem:151607::::::::110:270::13:3:3609:601:3607:::|h[Astral~`Alchemist~`Stone]|h|r^Sdiff^N10^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151956::::::::110:270::5:3:3611:1487:3528:::|h[Garothi~`Feedback~`Conduit]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2124]
			"22:38:35 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^SspecID^N270^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2125]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N937.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-65^N2^N10^N3^N25^t^Sgear1^T^N1^Sitem:132381::::::::110:265:::2:1811:3630^N2^Sitem:142165::151584::::::110:265::35:4:3417:1808:1542:3337^N3^Sitem:140044::::::::110:265::27:3:3394:1567:3337^t^Sgear2^T^N2^Sitem:151955::::::::110:265::3:4:3610:1808:1472:3528^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2126]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^SDibbs-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N488.911^Snew^N0^t^N2^T^Sequipped^N613.237^Snew^N273.09^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2127]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N950.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-15^N2^N5^N3^N0^t^Sgear1^T^N1^Sitem:134458::::::::110:261::35:3:3418:1602:3337^N2^Sitem:151963::::::::110:261::3:3:3610:1477:3336^t^Sgear2^T^N2^Sitem:154174::::::::110:261::3:2:3983:3984^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2128]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SDibbs-Area52^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2129]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N3^B^t^Sdiff^T^N1^N-20^N2^N40^N3^N0^t^Sgear1^T^N1^Sitem:137337::::::::110:66::35:3:3418:1607:3337^N2^Sitem:151974::::::::110:66::5:4:3611:1487:3528:3618^t^Sgear2^T^N2^Sitem:128711::::::::110:66::13:3:689:601:679^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2130]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^STuyen-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N616.383^Snew^N534.264^t^N2^T^Sequipped^N98.274^Snew^N212.475^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N66^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2131]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^SDravash-Area52^N2^T^Sforged^N9^Spawn^T^t^SspecID^N252^Straits^N68^Slegend^N2^Ssockets^N6^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2132]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SDravash-Area52^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2133]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N5^N2^N40^N3^N0^t^Sgear1^T^N1^Sitem:149625::::::::110:268::43:5:3573:1680:40:1592:3337^N2^Sitem:128711::::::::110:268::13:3:689:600:679^t^Sgear2^T^N2^Sitem:147024::::::::110:268::5:3:3562:1497:3528^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2134]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N35^N2^N20^N3^N0^t^Sgear1^T^N1^Sitem:147042::::::::110:577::3:3:3561:1482:3528^N2^Sitem:151968::::::::110:577::3:3:3610:1477:3336^t^Sgear2^T^N2^Sitem:147009::::::::110:577::5:3:3562:1502:3336^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2135]
			"22:38:35 - Comm received:^1^SextraUtilData^T^N1^SAmrehlu-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N556.133^Snew^N0^t^N2^T^Sequipped^N604.917^Snew^N210.497^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N253^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2136]
			"22:38:35 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-5^N2^N30^N3^N0^t^Sgear1^T^N1^Sitem:121316::::::::110:253::35:3:3418:1602:3337^N2^Sitem:154174::::::::110:253::3:2:3983:3984^t^Sgear2^T^N2^Sitem:141482::::::::110:253::43:4:42:3573:1522:3528^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2137]
			"22:38:36 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147057::::::::110:262::5:3:3562:1502:3336:::|h[Pain-Singed~`Armguards]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2138]
			"22:38:36 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.5^Sdiff^N-65^SspecID^N252^Sgear1^S|cffff8000|Hitem:132448::::::::110:252:::2:3459:3630:::|h[The~`Instructor's~`Fourth~`Lesson]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2139]
			"22:38:37 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sgear2^S|cffa335ee|Hitem:144480::::::::110:262::35:3:3418:1592:3337:::|h[Dreadstone~`of~`Endless~`Shadows]|h|r^Sdiff^N0^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147002::::::::110:262::5:3:3562:1527:3337:::|h[Charm~`of~`the~`Rising~`Tide]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2140]
			"22:38:37 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.5^Sgear2^S|cffa335ee|Hitem:147009::::::::110:252::5:3:3562:1502:3336:::|h[Infernal~`Cinders]|h|r^Sdiff^N20^SspecID^N252^Sgear1^S|cffa335ee|Hitem:151190::151580::::::110:252::5:4:3562:1808:1507:3528:::|h[Specter~`of~`Betrayal]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2141]
			"22:38:37 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^SspecID^N262^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2142]
			"22:38:37 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.5^Sdiff^N10^SspecID^N252^Sgear1^S|cffa335ee|Hitem:151296::::::::110:252::43:3:3573:1572:3336:::|h[Blood~`of~`the~`Vanquished]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2143]
			"22:38:38 - Comm received:^1^Sresponse^T^N1^N2^N2^SLesmes-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2144]
			"22:38:38 - LootFrame:Response (4) (Response:) (Offspec)", -- [2145]
			"22:38:38 - SendResponse (group) (3) (4) (nil) (true) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [2146]
			"22:38:38 - Trashing entry: (2) (|cffa335ee|Hitem:152092::::::::110:105::3:3:3610:1472:3528:::|h[Nathrezim Incisor]|h|r)", -- [2147]
			"22:38:38 - Comm received:^1^Sresponse^T^N1^N1^N2^SAhoyful-Area52^N3^T^Sresponse^N1^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2148]
			"22:38:39 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2149]
			"22:38:39 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Sresponse^N3^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2150]
			"22:38:40 - Comm received:^1^Sresponse^T^N1^N2^N2^SFreakeer-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2151]
			"22:38:41 - Comm received:^1^Sresponse^T^N1^N3^N2^SAvernakis-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2152]
			"22:38:42 - Comm received:^1^Sresponse^T^N1^N2^N2^SPhryke-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2153]
			"22:38:42 - Comm received:^1^Sresponse^T^N1^N2^N2^SAhoyful-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2154]
			"22:38:43 - Comm received:^1^Sresponse^T^N1^N3^N2^SPhryke-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2155]
			"22:38:43 - Comm received:^1^Sresponse^T^N1^N1^N2^STuyen-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2156]
			"22:38:46 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2157]
			"22:38:47 - Comm received:^1^Sresponse^T^N1^N2^N2^SVelynila-Area52^N3^T^Sresponse^N1^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2158]
			"22:38:47 - Comm received:^1^Sresponse^T^N1^N2^N2^SGalastradra-Area52^N3^T^Sresponse^N1^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2159]
			"22:38:48 - Comm received:^1^Soffline_timer^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2160]
			"22:38:48 - Comm received:^1^Sresponse^T^N1^N2^N2^SAmrehlu-Area52^N3^T^Sresponse^N3^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2161]
			"22:38:48 - LootFrame:Response (3) (Response:) (Offspec)", -- [2162]
			"22:38:48 - SendResponse (group) (2) (3) (nil) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [2163]
			"22:38:48 - Trashing entry: (1) (|cffa335ee|Hitem:151964::::::::110:105::3:3:3610:1482:3336:::|h[Seeping Scourgewing]|h|r)", -- [2164]
			"22:38:48 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2165]
			"22:38:48 - Comm received:^1^Sresponse^T^N1^N2^N2^SAvernakis-Area52^N3^T^Sresponse^N3^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2166]
			"22:38:49 - Comm received:^1^Sresponse^T^N1^N2^N2^SLithelasha-Area52^N3^T^Sresponse^N1^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2167]
			"22:38:49 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Sresponse^SPASS^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2168]
			"22:38:50 - Comm received:^1^SEUBonusRoll^T^N1^SLithelasha-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:577:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2169]
			"22:38:50 - Comm received:^1^Sresponse^T^N1^N3^N2^SGalastradra-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2170]
			"22:39:00 - Comm received:^1^Sresponse^T^N1^N3^N2^SAmrehlu-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2171]
			"22:39:03 - Comm received:^1^SEUBonusRoll^T^N1^SDravash-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:252:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2172]
			"22:39:11 - Comm received:^1^Sresponse^T^N1^N2^N2^SChauric-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2173]
			"22:39:14 - Comm received:^1^Sresponse^T^N1^N2^N2^STuyen-Area52^N3^T^Sresponse^SPASS^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2174]
			"22:39:36 - Event: (LOOT_CLOSED)", -- [2175]
			"22:39:37 - Minimize()", -- [2176]
			"22:40:16 - Event: (LOOT_OPENED) (1)", -- [2177]
			"22:40:16 - lootSlot @session (1) (Was at:) (2) (is now at:) (1)", -- [2178]
			"22:40:16 - lootSlot @session (2) (Was at:) (1) (is now at:) (2)", -- [2179]
			"22:40:18 - Maximize()", -- [2180]
			"22:40:21 - ML:Award (1) (Ahoyful-Area52) (Major Upgrade (10%+)) (nil)", -- [2181]
			"22:40:21 - GiveMasterLoot (1) (10)", -- [2182]
			"22:40:21 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:152281::::::::110:105::3:3:3610:1477:3336:::|h[Varimathras' Shattered Manacles]|h|r)", -- [2183]
			"22:40:21 - ML:TrackAndLogLoot()", -- [2184]
			"22:40:21 - ML event (CHAT_MSG_LOOT) (Ahoyful receives loot: |cffa335ee|Hitem:152281::::::::110:105::3:3:3610:1477:3336:::|h[Varimathras' Shattered Manacles]|h|r.) () () () (Ahoyful) () (0) (0) () (0) (4357) (nil) (0) (false) (false) (false) (false)", -- [2185]
			"22:40:21 - Comm received:^1^Shistory^T^N1^SAhoyful-Area52^N2^T^Sid^S1512808821-21^SitemReplaced1^S|cffa335ee|Hitem:152752::::::::110:105:::4:1691:3629:1477:3336:::|h[Praetorium~`Guard's~`Vambraces~`of~`the~`Fireflash]|h|r^SmapID^N1712^SgroupSize^N14^Sdate^S08/12/17^Sclass^SPALADIN^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SMajor~`Upgrade~`(10%+)^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Svotes^N0^Stime^S22:40:21^SisAwardReason^b^SlootWon^S|cffa335ee|Hitem:152281::::::::110:105::3:3:3610:1477:3336:::|h[Varimathras'~`Shattered~`Manacles]|h|r^SresponseID^N1^Sboss^SVarimathras^SdifficultyID^N14^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2186]
			"22:40:21 - Comm received:^1^Sawarded^T^N1^N1^N2^SAhoyful-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2187]
			"22:40:21 - SwitchSession (2)", -- [2188]
			"22:40:22 - GetLootDBStatistics()", -- [2189]
			"22:40:28 - ReannounceOrRequestRoll (function: 000001AB173BDC50) (function: 000001AB16D647B0) (true) (false) (false)", -- [2190]
			"22:40:28 - Comm received:^1^Srolls^T^N1^N2^N2^T^SGalastradra-Area52^S^SVelynila-Area52^S^SLithelasha-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2191]
			"22:40:28 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N950.0625^N4^T^Sresponse^T^t^Sdiff^T^N1^N5^t^Sgear1^T^N1^Sitem:151963::::::::110:261::3:3:3610:1477:3336^t^Sgear2^T^N1^Sitem:154174::::::::110:261::3:2:3983:3984^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2192]
			"22:40:28 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N942.5^N4^T^Sresponse^T^t^Sdiff^T^N1^N10^t^Sgear1^T^N1^Sitem:151190::::::::110:577::5:3:3562:1512:3336^t^Sgear2^T^N1^Sitem:154174::::::::110:577::3:2:3983:3985^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2193]
			"22:40:28 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^t^Sdiff^T^N1^N20^t^Sgear1^T^N1^Sitem:151968::::::::110:577::3:3:3610:1477:3336^t^Sgear2^T^N1^Sitem:147009::::::::110:577::5:3:3562:1502:3336^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2194]
			"22:40:32 - Comm received:^1^Sroll^T^N1^SGalastradra-Area52^N2^N76^N3^T^N1^N2^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2195]
			"22:40:34 - Comm received:^1^Sroll^T^N1^SVelynila-Area52^N2^N44^N3^T^N1^N2^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2196]
			"22:40:35 - Comm received:^1^Sroll^T^N1^SLithelasha-Area52^N2^N89^N3^T^N1^N2^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2197]
			"22:40:40 - ML:Award (2) (Lithelasha-Area52) (Major Upgrade (10%+)) (nil)", -- [2198]
			"22:40:40 - GiveMasterLoot (2) (12)", -- [2199]
			"22:40:40 - OnLootSlotCleared() (2) (|cffa335ee|Hitem:151964::::::::110:105::3:3:3610:1482:3336:::|h[Seeping Scourgewing]|h|r)", -- [2200]
			"22:40:40 - ML:TrackAndLogLoot()", -- [2201]
			"22:40:40 - ML event (CHAT_MSG_LOOT) (Lithelasha receives loot: |cffa335ee|Hitem:151964::::::::110:105::3:3:3610:1482:3336:::|h[Seeping Scourgewing]|h|r.) () () () (Lithelasha) () (0) (0) () (0) (4371) (nil) (0) (false) (false) (false) (false)", -- [2202]
			"22:40:40 - Comm received:^1^Shistory^T^N1^SLithelasha-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SDEMONHUNTER^SgroupSize^N14^Sboss^SVarimathras^Stime^S22:40:40^SitemReplaced1^S|cffa335ee|Hitem:151190::::::::110:105::5:3:3562:1512:3336:::|h[Specter~`of~`Betrayal]|h|r^Sid^S1512808840-22^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^SMajor~`Upgrade~`(10%+)^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:151964::::::::110:105::3:3:3610:1482:3336:::|h[Seeping~`Scourgewing]|h|r^SisAwardReason^b^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^SresponseID^N1^SitemReplaced2^S|cffa335ee|Hitem:154174::::::::110:105::3:2:3983:3985:::|h[Golganneth's~`Vitality]|h|r^Svotes^N0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2203]
			"22:40:40 - Comm received:^1^Sawarded^T^N1^N2^N2^SLithelasha-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2204]
			"22:40:40 - SwitchSession (3)", -- [2205]
			"22:40:41 - GetLootDBStatistics()", -- [2206]
			"22:40:43 - ML:Award (3) (Dravash-Area52) (Major Upgrade (4+ Trait Increase)) (nil)", -- [2207]
			"22:40:43 - GiveMasterLoot (3) (6)", -- [2208]
			"22:40:44 - OnLootSlotCleared() (3) (|cffa335ee|Hitem:152092::::::::110:105::3:3:3610:1472:3528:::|h[Nathrezim Incisor]|h|r)", -- [2209]
			"22:40:44 - ML:TrackAndLogLoot()", -- [2210]
			"22:40:44 - Event: (LOOT_CLOSED)", -- [2211]
			"22:40:44 - Event: (LOOT_CLOSED)", -- [2212]
			"22:40:44 - ML event (CHAT_MSG_LOOT) (Dravash receives loot: |cffa335ee|Hitem:152092::::::::110:105::3:3:3610:1472:3528:::|h[Nathrezim Incisor]|h|r.) () () () (Dravash) () (0) (0) () (0) (4375) (nil) (0) (false) (false) (false) (false)", -- [2213]
			"22:40:44 - Comm received:^1^Shistory^T^N1^SDravash-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SDEATHKNIGHT^SgroupSize^N14^SisAwardReason^b^Stime^S22:40:44^SitemReplaced1^S|cffa335ee|Hitem:151296::::::::110:105::43:3:3573:1572:3336:::|h[Blood~`of~`the~`Vanquished]|h|r^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sid^S1512808844-23^Sresponse^SMajor~`Upgrade~`(4+~`Trait~`Increase)^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152092::::::::110:105::3:3:3610:1472:3528:::|h[Nathrezim~`Incisor]|h|r^SrelicRoll^B^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^SresponseID^N1^Sboss^SVarimathras^Svotes^N0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2214]
			"22:40:44 - Comm received:^1^Sawarded^T^N1^N3^N2^SDravash-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2215]
			"22:40:44 - SwitchSession (3)", -- [2216]
			"22:40:45 - ML:EndSession()", -- [2217]
			"22:40:45 - GetLootDBStatistics()", -- [2218]
			"22:40:45 - Comm received:^1^Ssession_end^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2219]
			"22:40:45 - RCVotingFrame:EndSession (false)", -- [2220]
			"22:40:46 - Hide VotingFrame", -- [2221]
			"22:45:37 - Event: (ENCOUNTER_START) (2073) (The Coven of Shivarra) (14) (14)", -- [2222]
			"22:45:37 - UpdatePlayersData()", -- [2223]
			"22:53:47 - ML event (CHAT_MSG_LOOT) (You receive item: |cff0070dd|Hitem:151556::::::::110:105:8388608:3::56:::|h[Spoils of the Triumphant]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4508) (nil) (0) (false) (false) (false) (false)", -- [2224]
			"22:53:47 - Event: (ENCOUNTER_END) (2073) (The Coven of Shivarra) (14) (14) (1)", -- [2225]
			"22:53:48 - ML event (PLAYER_REGEN_ENABLED)", -- [2226]
			"22:54:03 - Comm received:^1^SverTest^T^N1^S2.7.4^t^^ (from:) (Amrehlu) (distri:) (GUILD)", -- [2227]
			"22:54:03 - Comm received:^1^SplayerInfo^T^N1^SAmrehlu-Area52^N2^SHUNTER^N3^SDAMAGER^N4^SStewed^N6^N0^N7^N943.0625^t^^ (from:) (Amrehlu) (distri:) (WHISPER)", -- [2228]
			"22:54:03 - GG:AddEntry(Update) (Amrehlu-Area52) (7)", -- [2229]
			"22:54:03 - ML:AddCandidate (Amrehlu-Area52) (HUNTER) (DAMAGER) (Stewed) (nil) (0) (nil)", -- [2230]
			"22:54:03 - Comm received:^1^Sreconnect^T^t^^ (from:) (Amrehlu) (distri:) (WHISPER)", -- [2231]
			"22:54:03 - Responded to reconnect from (Amrehlu)", -- [2232]
			"22:54:03 - Event: (LOOT_OPENED) (1)", -- [2233]
			"22:54:03 - CanWeLootItem (|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven Prayer Bead]|h|r) (4) (true)", -- [2234]
			"22:54:03 - ML:AddItem (|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven Prayer Bead]|h|r) (false) (1) (nil)", -- [2235]
			"22:54:03 - CanWeLootItem (|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders of the Antoran Vanquisher]|h|r) (4) (true)", -- [2236]
			"22:54:03 - ML:AddItem (|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders of the Antoran Vanquisher]|h|r) (false) (2) (nil)", -- [2237]
			"22:54:03 - CanWeLootItem (|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r) (4) (true)", -- [2238]
			"22:54:03 - ML:AddItem (|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r) (false) (3) (nil)", -- [2239]
			"22:54:03 - RCSessionFrame (enabled)", -- [2240]
			"22:54:07 - Event: (LOOT_CLOSED)", -- [2241]
			"22:54:07 - BONUS_ROLL_RESULT (artifact_power) (|cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted Azsharan Seal]|h|r) (1) (0) (2) (false)", -- [2242]
			"22:54:07 - ML event (CHAT_MSG_LOOT) (You receive bonus loot: |cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted Azsharan Seal]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4527) (nil) (0) (false) (false) (false) (false)", -- [2243]
			"22:54:08 - ML:StartSession()", -- [2244]
			"22:54:08 - ML:AnnounceItems()", -- [2245]
			"22:54:12 - Comm received:^1^SEUBonusRoll^T^N1^SAvernakis-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2246]
			"22:54:14 - Comm received:^1^SlootTable^T^N1^T^N1^T^SequipLoc^S^Sgp^N530^Silvl^N930^Slink^S|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders~`of~`the~`Antoran~`Protector]|h|r^Stexture^N135053^SlootSlot^N3^SsubType^SJunk^Srelic^b^Sclasses^N581^Sname^SShoulders~`of~`the~`Antoran~`Protector^Stoken^SShoulderSlot^Sboe^b^Sawarded^b^Squality^N4^t^N2^T^SequipLoc^S^Sgp^N530^Silvl^N930^Slink^S|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders~`of~`the~`Antoran~`Vanquisher]|h|r^Stexture^N135053^SlootSlot^N2^SsubType^SJunk^Srelic^b^Sclasses^N1192^Sname^SShoulders~`of~`the~`Antoran~`Vanquisher^Stoken^SShoulderSlot^Sboe^b^Sawarded^b^Squality^N4^t^N3^T^SequipLoc^S^Sgp^N472^Silvl^N930^Slink^S|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven~`Prayer~`Bead]|h|r^Srelic^SHoly^Stexture^N1535059^SsubType^SArtifact~`Relic^SlootSlot^N1^Sclasses^N4294967295^Sname^SCoven~`Prayer~`Bead^Sboe^b^Sawarded^b^Squality^N4^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2247]
			"22:54:14 - SwitchSession (1)", -- [2248]
			"22:54:14 - SwitchSession (1)", -- [2249]
			"22:54:14 - Autopassed on:  (|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r)", -- [2250]
			"22:54:14 - NewRelicAutopassCheck (|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven Prayer Bead]|h|r) (Holy)", -- [2251]
			"22:54:14 - Autopassed on:  (|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven Prayer Bead]|h|r)", -- [2252]
			"22:54:14 - GetPlayersGear (|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r) (INVTYPE_SHOULDER)", -- [2253]
			"22:54:14 - GetPlayersGear (|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders of the Antoran Vanquisher]|h|r) (INVTYPE_SHOULDER)", -- [2254]
			"22:54:14 - LootFrame:Start()", -- [2255]
			"22:54:14 - Restoring entry: (tier) (1)", -- [2256]
			"22:54:14 - GetPlayersGear (|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r) ()", -- [2257]
			"22:54:14 - GetPlayersGear (|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders of the Antoran Vanquisher]|h|r) ()", -- [2258]
			"22:54:14 - GetPlayersGear (|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven Prayer Bead]|h|r) ()", -- [2259]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SGalastradra-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N909.991^Snew^N0^t^N2^T^Sequipped^N909.991^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N261^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2260]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N928.388^Snew^N0^t^N2^T^Sequipped^N928.388^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2261]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SDibbs-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N54533.54^Snew^N0^t^N2^T^Sequipped^N54533.54^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2262]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SAmrehlu-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N745.566^Snew^N0^t^N2^T^Sequipped^N745.566^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N253^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2263]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SLithelasha-Area52^N2^T^Sforged^N10^Spawn^T^N1^T^Sequipped^N92627.25^Snew^N0^t^N2^T^Sequipped^N92627.25^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2264]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N916.4375^N4^T^Sresponse^T^N1^B^N2^B^t^Sdiff^T^N1^N-70^N2^N-70^N3^N35^t^Sgear1^T^N1^Sitem:137076::::::::110:65:::2:1811:3630^N2^Sitem:137076::::::::110:65:::2:1811:3630^N3^Sitem:151005::::::::110:65::30:3:3397:3174:3528^t^Sgear2^T^N3^Sitem:137495::::::::110:65::43:3:3573:1562:3528^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2265]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N15^N2^N15^N3^N0^t^Sgear1^T^N1^Sitem:147180:5929:::::::110:262::5:3:3562:1497:3528^N2^Sitem:147180:5929:::::::110:262::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2266]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SFreakeer-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N646.668^Snew^N0^t^N2^T^Sequipped^N646.668^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N74^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2267]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N-70^N2^N-70^N3^N0^t^Sgear1^T^N1^Sitem:144279::::::::110:577:::2:1811:3630^N2^Sitem:144279::::::::110:577:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2268]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SVelynila-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N92627.25^Snew^N0^t^N2^T^Sequipped^N92627.25^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N70^Slegend^N2^Ssockets^N1^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2269]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SLesmes-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N57571.48^Snew^N0^t^N2^T^Sequipped^N57571.48^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N63^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2270]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N943.125^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N-70^N2^N-70^N3^N0^t^Sgear1^T^N1^Sitem:144279:5883:::::::110:577:::2:3459:3630^N2^Sitem:144279:5883:::::::110:577:::2:3459:3630^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2271]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SDibbs-Area52^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2272]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N0^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:147150::::::::110:63::3:3:3561:1512:3337^N2^Sitem:147150::::::::110:63::3:3:3561:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2273]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N950.0625^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N-20^N2^N-20^N3^N0^t^Sgear1^T^N1^Sitem:151988:5929:::::::110:261::5:4:3611:40:1492:3336^N2^Sitem:151988:5929:::::::110:261::5:4:3611:40:1492:3336^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2274]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SPhryke-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N655.43^Snew^N0^t^N2^T^Sequipped^N655.43^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N265^Straits^N69^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2275]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SSulana-Area52^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2276]
			"22:54:14 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N-20^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151988::::::::110:270::5:3:3611:1492:3336:::|h[Shoulderpads~`of~`the~`Demonic~`Blitz]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2277]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N-5^N2^N-5^N3^N0^t^Sgear1^T^N1^Sitem:137321:5929:::::::110:253::35:3:3418:1587:3337^N2^Sitem:137321:5929:::::::110:253::35:3:3418:1587:3337^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2278]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N1^B^N2^B^t^Sdiff^T^N1^N10^N2^N10^N3^N5^t^Sgear1^T^N1^Sitem:147162:5931:::::::110:66::5:3:3562:1502:3336^N2^Sitem:147162:5931:::::::110:66::5:3:3562:1502:3336^N3^Sitem:136771::::::::110:66::43:3:3573:1577:3337^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2279]
			"22:54:14 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^Sdiff^N-20^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151988::::::::110:270::5:3:3611:1492:3336:::|h[Shoulderpads~`of~`the~`Demonic~`Blitz]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2280]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^STuyen-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N634.179^Snew^N0^t^N2^T^Sequipped^N634.179^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N66^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2281]
			"22:54:14 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^SspecID^N270^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2282]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N937.4375^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N5^N2^N5^N3^N0^t^Sgear1^T^N1^Sitem:137360::::::::110:265::16:3:3510:1577:3528^N2^Sitem:137360::::::::110:265::16:3:3510:1577:3528^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2283]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N15^N2^N15^N3^N0^t^Sgear1^T^N1^Sitem:147156:5883:::::::110:268::5:3:3562:1497:3528^N2^Sitem:147156:5883:::::::110:268::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2284]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SDravash-Area52^N2^T^Sforged^N9^Spawn^T^t^SspecID^N252^Straits^N68^Slegend^N2^Ssockets^N6^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2285]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SDravash-Area52^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2286]
			"22:54:14 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N941.4375^N4^T^Sresponse^T^N1^B^N3^B^t^Sdiff^T^N1^N15^N2^N15^N3^N0^t^Sgear1^T^N1^Sitem:138336:5931:::::::110:105::3:3:3514:1512:3337^N2^Sitem:138336:5931:::::::110:105::3:3:3514:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2287]
			"22:54:14 - Comm received:^1^SextraUtilData^T^N1^SAvernakis-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N696.257^Snew^N0^t^N2^T^Sequipped^N696.257^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N105^Straits^N75^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2288]
			"22:54:15 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147180:5442:::::::110:262::5:3:3562:1497:3528:::|h[Pauldrons~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2289]
			"22:54:15 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.25^Sresponse^SAUTOPASS^Sdiff^N-20^SspecID^N252^Sgear1^S|cffa335ee|Hitem:134360:5929:::::::110:252::35:3:3534:1612:3337:::|h[Portalguard~`Shoulders]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2290]
			"22:54:15 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147180:5442:::::::110:262::5:3:3562:1497:3528:::|h[Pauldrons~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2291]
			"22:54:15 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.25^Sdiff^N-20^SspecID^N252^Sgear1^S|cffa335ee|Hitem:134360:5929:::::::110:252::35:3:3534:1612:3337:::|h[Portalguard~`Shoulders]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2292]
			"22:54:16 - Comm received:^1^Sresponse^T^N1^N3^N2^SAhoyful-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2293]
			"22:54:16 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^SspecID^N262^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2294]
			"22:54:16 - Comm received:^1^Sresponse^T^N1^N1^N2^SFreakeer-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2295]
			"22:54:16 - Comm received:^1^Sresponse^T^N1^N1^N2^SChauric-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2296]
			"22:54:16 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.25^Sresponse^SAUTOPASS^SspecID^N252^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2297]
			"22:54:17 - Comm received:^1^Sresponse^T^N1^N2^N2^SGalastradra-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2298]
			"22:54:17 - Comm received:^1^Sresponse^T^N1^N1^N2^SAmrehlu-Area52^N3^T^Sresponse^N2^SisTier^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2299]
			"22:54:17 - LootFrame:Response (3) (Response:) (3rd Set Piece)", -- [2300]
			"22:54:17 - SendResponse (group) (2) (3) (true) (false) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [2301]
			"22:54:17 - Trashing entry: (1) (|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders of the Antoran Vanquisher]|h|r)", -- [2302]
			"22:54:17 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sresponse^N1^SisTier^B^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2303]
			"22:54:19 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Sresponse^N1^SisTier^B^SisRelic^b^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2304]
			"22:54:20 - Comm received:^1^Sresponse^T^N1^N2^N2^SAvernakis-Area52^N3^T^Sresponse^N3^SisTier^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2305]
			"22:54:22 - SwitchSession (2)", -- [2306]
			"22:54:22 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisTier^B^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2307]
			"22:54:23 - Comm received:^1^Sresponse^T^N1^N2^N2^SLesmes-Area52^N3^T^Sresponse^SPASS^SisTier^B^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2308]
			"22:54:23 - Comm received:^1^Sresponse^T^N1^N3^N2^STuyen-Area52^N3^T^Sresponse^N2^SisRelic^B^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2309]
			"22:54:26 - Comm received:^1^Soffline_timer^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2310]
			"22:54:32 - ReannounceOrRequestRoll (true) (function: 000001AB534BB170) (true) (false) (true)", -- [2311]
			"22:54:32 - ML:AnnounceItems()", -- [2312]
			"22:54:32 - Comm received:^1^Srolls^T^N1^N2^N2^T^SLesmes-Area52^S^STuyen-Area52^S^SDibbs-Area52^S^SAvernakis-Area52^S^SVelynila-Area52^S^SDravash-Area52^S^SPhryke-Area52^S^SAhoyful-Area52^S^SGalastradra-Area52^S^SFreakeer-Area52^S^SSulana-Area52^S^SChauric-Area52^S^SLithelasha-Area52^S^SAmrehlu-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2313]
			"22:54:32 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^SINVTYPE_SHOULDER^Silvl^N930^Slink^S|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders~`of~`the~`Antoran~`Vanquisher]|h|r^SisRoll^B^Sclasses^N1192^Sname^SShoulders~`of~`the~`Antoran~`Vanquisher^Stoken^SShoulderSlot^SnoAutopass^b^Srelic^b^Ssession^N2^Stexture^N135053^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2314]
			"22:54:32 - GetPlayersGear (|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders of the Antoran Vanquisher]|h|r) (INVTYPE_SHOULDER)", -- [2315]
			"22:54:32 - LootFrame:ReRoll(#table) (1)", -- [2316]
			"22:54:32 - LootFrame:Start()", -- [2317]
			"22:54:32 - Restoring entry: (roll) (1)", -- [2318]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:144279::::::::110:577:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2319]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N916.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:137076::::::::110:65:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2320]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147180:5929:::::::110:262::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2321]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N943.125^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:144279:5883:::::::110:577:::2:3459:3630^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2322]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N0^t^Sgear1^T^N1^Sitem:147150::::::::110:63::3:3:3561:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2323]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N941.4375^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:138336:5931:::::::110:105::3:3:3514:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2324]
			"22:54:32 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^Sdiff^N-20^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151988::::::::110:270::5:3:3611:1492:3336:::|h[Shoulderpads~`of~`the~`Demonic~`Blitz]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2325]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-5^t^Sgear1^T^N1^Sitem:137321:5929:::::::110:253::35:3:3418:1587:3337^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2326]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N937.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N5^t^Sgear1^T^N1^Sitem:137360::::::::110:265::16:3:3510:1577:3528^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2327]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N10^t^Sgear1^T^N1^Sitem:147162:5931:::::::110:66::5:3:3562:1502:3336^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2328]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N950.0625^N4^T^Sresponse^T^t^Sdiff^T^N1^N-20^t^Sgear1^T^N1^Sitem:151988:5929:::::::110:261::5:4:3611:40:1492:3336^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2329]
			"22:54:32 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147156:5883:::::::110:268::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2330]
			"22:54:33 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147180:5442:::::::110:262::5:3:3562:1497:3528:::|h[Pauldrons~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2331]
			"22:54:33 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.25^Sdiff^N-20^SspecID^N252^Sgear1^S|cffa335ee|Hitem:134360:5929:::::::110:252::35:3:3534:1612:3337:::|h[Portalguard~`Shoulders]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2332]
			"22:54:34 - Comm received:^1^Sroll^T^N1^SAvernakis-Area52^N2^N58^N3^T^N1^N2^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2333]
			"22:54:35 - Trashing entry: (1) (|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders of the Antoran Vanquisher]|h|r)", -- [2334]
			"22:54:41 - Comm received:^1^Sroll^T^N1^SGalastradra-Area52^N2^N29^N3^T^N1^N2^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2335]
			"22:54:45 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Sroll^N44^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2336]
			"22:54:50 - Event: (LOOT_OPENED) (1)", -- [2337]
			"22:54:54 - ML:Award (2) (Avernakis-Area52) (3rd Set Piece) (nil)", -- [2338]
			"22:54:54 - GiveMasterLoot (2) (5)", -- [2339]
			"22:54:54 - LootSlot (2)", -- [2340]
			"22:54:54 - OnLootSlotCleared() (2) (|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders of the Antoran Vanquisher]|h|r)", -- [2341]
			"22:54:54 - ML:TrackAndLogLoot()", -- [2342]
			"22:54:54 - ML event (CHAT_MSG_LOOT) (You receive loot: |cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders of the Antoran Vanquisher]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4553) (nil) (0) (false) (false) (false) (false)", -- [2343]
			"22:54:54 - Comm received:^1^Shistory^T^N1^SAvernakis-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SDRUID^SgroupSize^N14^Svotes^N0^Stime^S22:54:54^SitemReplaced1^S|cffa335ee|Hitem:138336:5931:::::::110:105::3:3:3514:1512:3337:::|h[Mantle~`of~`the~`Astral~`Warden]|h|r^Sid^S1512809694-24^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^S3rd~`Set~`Piece^StokenRoll^B^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders~`of~`the~`Antoran~`Vanquisher]|h|r^StierToken^SShoulderSlot^SisAwardReason^b^SresponseID^N3^Sboss^SThe~`Coven~`of~`Shivarra^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2344]
			"22:54:54 - Comm received:^1^Sawarded^T^N1^N2^N2^SAvernakis-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2345]
			"22:54:54 - SwitchSession (3)", -- [2346]
			"22:54:55 - GetLootDBStatistics()", -- [2347]
			"22:54:55 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders~`of~`the~`Antoran~`Vanquisher]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2348]
			"22:55:04 - ReannounceOrRequestRoll (true) (function: 000001AACA951020) (true) (false) (true)", -- [2349]
			"22:55:04 - ML:AnnounceItems()", -- [2350]
			"22:55:04 - Comm received:^1^Srolls^T^N1^N3^N2^T^SLesmes-Area52^S^STuyen-Area52^S^SDibbs-Area52^S^SAvernakis-Area52^S^SVelynila-Area52^S^SDravash-Area52^S^SPhryke-Area52^S^SAhoyful-Area52^S^SGalastradra-Area52^S^SFreakeer-Area52^S^SSulana-Area52^S^SChauric-Area52^S^SLithelasha-Area52^S^SAmrehlu-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2351]
			"22:55:04 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^S^Silvl^N930^Slink^S|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven~`Prayer~`Bead]|h|r^SisRoll^B^Sclasses^N4294967295^Sname^SCoven~`Prayer~`Bead^SnoAutopass^b^Srelic^SHoly^Ssession^N3^Stexture^N1535059^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2352]
			"22:55:04 - NewRelicAutopassCheck (|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven Prayer Bead]|h|r) (Holy)", -- [2353]
			"22:55:04 - Autopassed on:  (|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven Prayer Bead]|h|r)", -- [2354]
			"22:55:04 - LootFrame:ReRoll(#table) (1)", -- [2355]
			"22:55:04 - LootFrame:Start()", -- [2356]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N950.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2357]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N941.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2358]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N916.4375^N4^T^Sresponse^T^t^Sdiff^T^N1^N35^t^Sgear1^T^N1^Sitem:151005::::::::110:65::30:3:3397:3174:3528^t^Sgear2^T^N1^Sitem:137495::::::::110:65::43:3:3573:1562:3528^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2359]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2360]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2361]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N943.125^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2362]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2363]
			"22:55:04 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^SspecID^N270^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2364]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N937.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2365]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2366]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N5^t^Sgear1^T^N1^Sitem:136771::::::::110:66::43:3:3573:1577:3337^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2367]
			"22:55:04 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2368]
			"22:55:05 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^SspecID^N262^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2369]
			"22:55:05 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.25^Sresponse^SAUTOPASS^SspecID^N252^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2370]
			"22:55:07 - Comm received:^1^Sroll^T^N1^STuyen-Area52^N2^N90^N3^T^N1^N3^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2371]
			"22:55:08 - Comm received:^1^Sroll^T^N1^SAhoyful-Area52^N2^N46^N3^T^N1^N3^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2372]
			"22:55:13 - ML:Award (3) (Tuyen-Area52) (Minor Upgrade (3 or Less Trait Increase)) (nil)", -- [2373]
			"22:55:13 - GiveMasterLoot (1) (14)", -- [2374]
			"22:55:13 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven Prayer Bead]|h|r)", -- [2375]
			"22:55:13 - ML:TrackAndLogLoot()", -- [2376]
			"22:55:13 - ML event (CHAT_MSG_LOOT) (Tuyen receives loot: |cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven Prayer Bead]|h|r.) () () () (Tuyen) () (0) (0) () (0) (4564) (nil) (0) (false) (false) (false) (false)", -- [2377]
			"22:55:13 - Comm received:^1^Shistory^T^N1^STuyen-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SPALADIN^SgroupSize^N14^SisAwardReason^b^Stime^S22:55:13^SitemReplaced1^S|cffa335ee|Hitem:136771::::::::110:105::43:3:3573:1577:3337:::|h[Eyir's~`Blessing]|h|r^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sid^S1512809713-25^Sresponse^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven~`Prayer~`Bead]|h|r^SrelicRoll^B^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^SresponseID^N2^Sboss^SThe~`Coven~`of~`Shivarra^Svotes^N0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2378]
			"22:55:13 - Comm received:^1^Sawarded^T^N1^N3^N2^STuyen-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2379]
			"22:55:13 - SwitchSession (3)", -- [2380]
			"22:55:14 - GetLootDBStatistics()", -- [2381]
			"22:55:14 - SwitchSession (1)", -- [2382]
			"22:55:27 - ML event (CHAT_MSG_LOOT) (Velynila receives loot: |cff9d9d9d|Hitem:132204::::::::110:105::::::|h[Sticky Volatile Substance]|h|r.) () () () (Velynila) () (0) (0) () (0) (4567) (nil) (0) (false) (false) (false) (false)", -- [2383]
			"22:55:30 - ML event (CHAT_MSG_LOOT) (Amrehlu receives loot: |cff9d9d9d|Hitem:132204::::::::110:105::::::|h[Sticky Volatile Substance]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (4568) (nil) (0) (false) (false) (false) (false)", -- [2384]
			"22:55:30 - ML event (CHAT_MSG_LOOT) (Freakeer receives loot: |cff9d9d9d|Hitem:132199::::::::110:105::::::|h[Congealed Felblood]|h|r.) () () () (Freakeer) () (0) (0) () (0) (4569) (nil) (0) (false) (false) (false) (false)", -- [2385]
			"22:55:53 - ReannounceOrRequestRoll (true) (function: 000001A9C03438C0) (false) (false) (true)", -- [2386]
			"22:55:53 - ML:AnnounceItems()", -- [2387]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SLesmes-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2388]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^STuyen-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2389]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SAmrehlu-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2390]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SDravash-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2391]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SVelynila-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2392]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SLithelasha-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2393]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SChauric-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2394]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SPhryke-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2395]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SFreakeer-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2396]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SGalastradra-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2397]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SSulana-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2398]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SAhoyful-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2399]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SAvernakis-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2400]
			"22:55:54 - Comm received:^1^Schange_response^T^N1^N1^N2^SDibbs-Area52^N3^SWAIT^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2401]
			"22:55:54 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^SINVTYPE_SHOULDER^Silvl^N930^Slink^S|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders~`of~`the~`Antoran~`Protector]|h|r^SisRoll^b^Sclasses^N581^Sname^SShoulders~`of~`the~`Antoran~`Protector^Stoken^SShoulderSlot^SnoAutopass^b^Srelic^b^Ssession^N1^Stexture^N135053^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2402]
			"22:55:54 - Autopassed on:  (|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r)", -- [2403]
			"22:55:54 - GetPlayersGear (|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r) (INVTYPE_SHOULDER)", -- [2404]
			"22:55:54 - LootFrame:ReRoll(#table) (1)", -- [2405]
			"22:55:54 - LootFrame:Start()", -- [2406]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N950.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-20^t^Sgear1^T^N1^Sitem:151988:5929:::::::110:261::5:4:3611:40:1492:3336^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2407]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:144279::::::::110:577:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2408]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N916.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:137076::::::::110:65:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2409]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^N1^Sitem:147150::::::::110:63::3:3:3561:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2410]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N941.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:138336:5931:::::::110:105::3:3:3514:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2411]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147180:5929:::::::110:262::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2412]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^t^Sdiff^T^N1^N-5^t^Sgear1^T^N1^Sitem:137321:5929:::::::110:253::35:3:3418:1587:3337^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2413]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N943.125^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:144279:5883:::::::110:577:::2:3459:3630^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2414]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N937.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N5^t^Sgear1^T^N1^Sitem:137360::::::::110:265::16:3:3510:1577:3528^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2415]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N10^t^Sgear1^T^N1^Sitem:147162:5931:::::::110:66::5:3:3562:1502:3336^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2416]
			"22:55:54 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N-20^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151988::::::::110:270::5:3:3611:1492:3336:::|h[Shoulderpads~`of~`the~`Demonic~`Blitz]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2417]
			"22:55:54 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147156:5883:::::::110:268::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2418]
			"22:55:55 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147180:5442:::::::110:262::5:3:3562:1497:3528:::|h[Pauldrons~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2419]
			"22:55:55 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.25^Sresponse^SAUTOPASS^Sdiff^N-20^SspecID^N252^Sgear1^S|cffa335ee|Hitem:134360:5929:::::::110:252::35:3:3534:1612:3337:::|h[Portalguard~`Shoulders]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2420]
			"22:55:56 - Comm received:^1^Sresponse^T^N1^N1^N2^SFreakeer-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2421]
			"22:55:56 - Comm received:^1^Sresponse^T^N1^N1^N2^SAmrehlu-Area52^N3^T^Sresponse^N2^SisTier^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2422]
			"22:55:56 - Comm received:^1^Sresponse^T^N1^N1^N2^SChauric-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2423]
			"22:55:57 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Sresponse^SPASS^SisTier^B^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2424]
			"22:55:57 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sresponse^N1^SisTier^B^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2425]
			"22:56:32 - ReannounceOrRequestRoll (true) (function: 000001AABBA1D710) (true) (false) (true)", -- [2426]
			"22:56:32 - ML:AnnounceItems()", -- [2427]
			"22:56:32 - Comm received:^1^Srolls^T^N1^N1^N2^T^SLesmes-Area52^S^STuyen-Area52^S^SDibbs-Area52^S^SAvernakis-Area52^S^SVelynila-Area52^S^SDravash-Area52^S^SPhryke-Area52^S^SAhoyful-Area52^S^SGalastradra-Area52^S^SFreakeer-Area52^S^SSulana-Area52^S^SChauric-Area52^S^SLithelasha-Area52^S^SAmrehlu-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2428]
			"22:56:32 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^SINVTYPE_SHOULDER^Silvl^N930^Slink^S|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders~`of~`the~`Antoran~`Protector]|h|r^SisRoll^B^Sclasses^N581^Sname^SShoulders~`of~`the~`Antoran~`Protector^Stoken^SShoulderSlot^SnoAutopass^b^Srelic^b^Ssession^N1^Stexture^N135053^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2429]
			"22:56:32 - Autopassed on:  (|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r)", -- [2430]
			"22:56:32 - GetPlayersGear (|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r) (INVTYPE_SHOULDER)", -- [2431]
			"22:56:32 - LootFrame:ReRoll(#table) (1)", -- [2432]
			"22:56:32 - LootFrame:Start()", -- [2433]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:144279::::::::110:577:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2434]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N916.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:137076::::::::110:65:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2435]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N941.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:138336:5931:::::::110:105::3:3:3514:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2436]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147180:5929:::::::110:262::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2437]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N943.125^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-70^t^Sgear1^T^N1^Sitem:144279:5883:::::::110:577:::2:3459:3630^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2438]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N950.0625^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-20^t^Sgear1^T^N1^Sitem:151988:5929:::::::110:261::5:4:3611:40:1492:3336^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2439]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^t^Sgear1^T^N1^Sitem:147150::::::::110:63::3:3:3561:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2440]
			"22:56:32 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N-20^SspecID^N270^Sgear1^S|cffa335ee|Hitem:151988::::::::110:270::5:3:3611:1492:3336:::|h[Shoulderpads~`of~`the~`Demonic~`Blitz]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2441]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N937.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N5^t^Sgear1^T^N1^Sitem:137360::::::::110:265::16:3:3510:1577:3528^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2442]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N943.0625^N4^T^Sresponse^T^t^Sdiff^T^N1^N-5^t^Sgear1^T^N1^Sitem:137321:5929:::::::110:253::35:3:3418:1587:3337^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2443]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147156:5883:::::::110:268::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2444]
			"22:56:32 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N10^t^Sgear1^T^N1^Sitem:147162:5931:::::::110:66::5:3:3562:1502:3336^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2445]
			"22:56:33 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sdiff^N15^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147180:5442:::::::110:262::5:3:3562:1497:3528:::|h[Pauldrons~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2446]
			"22:56:33 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.25^Sresponse^SAUTOPASS^Sdiff^N-20^SspecID^N252^Sgear1^S|cffa335ee|Hitem:134360:5929:::::::110:252::35:3:3534:1612:3337:::|h[Portalguard~`Shoulders]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2447]
			"22:56:34 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sroll^N97^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2448]
			"22:56:34 - Comm received:^1^Sroll^T^N1^SFreakeer-Area52^N2^N83^N3^T^N1^N1^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2449]
			"22:56:35 - Comm received:^1^Sroll^T^N1^SChauric-Area52^N2^N37^N3^T^N1^N1^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2450]
			"22:56:49 - SwitchSession (1)", -- [2451]
			"22:56:52 - SwitchSession (1)", -- [2452]
			"22:56:55 - Comm received:^1^Sroll^T^N1^SAmrehlu-Area52^N2^N59^N3^T^N1^N1^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2453]
			"22:58:47 - Event: (LOOT_CLOSED)", -- [2454]
			"22:59:30 - Event: (LOOT_OPENED) (1)", -- [2455]
			"22:59:30 - lootSlot @session (1) (Was at:) (3) (is now at:) (1)", -- [2456]
			"22:59:37 - ML:Award (1) (Amrehlu-Area52) (2nd Set Piece) (nil)", -- [2457]
			"22:59:37 - GiveMasterLoot (1) (8)", -- [2458]
			"22:59:37 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r)", -- [2459]
			"22:59:37 - ML:TrackAndLogLoot()", -- [2460]
			"22:59:37 - Event: (LOOT_CLOSED)", -- [2461]
			"22:59:37 - Event: (LOOT_CLOSED)", -- [2462]
			"22:59:37 - Comm received:^1^Shistory^T^N1^SAmrehlu-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SHUNTER^SgroupSize^N14^Svotes^N0^Stime^S22:59:37^SitemReplaced1^S|cffa335ee|Hitem:137321:5929:::::::110:105::35:3:3418:1587:3337:::|h[Burning~`Sky~`Pauldrons]|h|r^Sid^S1512809977-26^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sresponse^S2nd~`Set~`Piece^StokenRoll^B^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders~`of~`the~`Antoran~`Protector]|h|r^StierToken^SShoulderSlot^SisAwardReason^b^SresponseID^N2^Sboss^SThe~`Coven~`of~`Shivarra^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2463]
			"22:59:37 - Comm received:^1^Sawarded^T^N1^N1^N2^SAmrehlu-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2464]
			"22:59:37 - SwitchSession (2)", -- [2465]
			"22:59:38 - ML:EndSession()", -- [2466]
			"22:59:38 - Comm received:^1^Ssession_end^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2467]
			"22:59:38 - RCVotingFrame:EndSession (false)", -- [2468]
			"22:59:38 - GetLootDBStatistics()", -- [2469]
			"22:59:41 - Hide VotingFrame", -- [2470]
			"22:59:42 - ML event (CHAT_MSG_LOOT) (Amrehlu receives loot: |cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r.) () () () ()", -- [2471]
			"23:00:19 - ML event (CHAT_MSG_LOOT) (You receive item: |cffa335ee|Hitem:152129::::::::110:105::3:3:3610:1477:3336:::|h[Bearmantle Shoulders]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4627) (nil) (0) (false) (false) (false) (false)", -- [2472]
			"23:05:11 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:127845::::::::110:105::::::|h[Unbending Potion]|h|r.) () () () (Chauric) () (0) (0) () (0) (4659) (nil) (0) (false) (false) (false) (false)", -- [2473]
			"23:05:13 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:127845::::::::110:105::::::|h[Unbending Potion]|h|r.) () () () (Chauric) () (0) (0) () (0) (4662) (nil) (0) (false) (false) (false) (false)", -- [2474]
			"23:05:15 - ML event (CHAT_MSG_LOOT) (Chauric creates: |cffffffff|Hitem:127845::::::::110:105::::::|h[Unbending Potion]|h|rx2.) () () () (Chauric) () (0) (0) () (0) (4664) (nil) (0) (false) (false) (false) (false)", -- [2475]
			"23:06:11 - Event: (ENCOUNTER_START) (2063) (Aggramar) (14) (14)", -- [2476]
			"23:06:11 - UpdatePlayersData()", -- [2477]
			"23:13:49 - ML event (PLAYER_REGEN_ENABLED)", -- [2478]
			"23:14:54 - Event: (ENCOUNTER_END) (2063) (Aggramar) (14) (14) (1)", -- [2479]
			"23:14:54 - ML event (CHAT_MSG_LOOT) (You receive item: |cff0070dd|Hitem:151556::::::::110:105:8388608:3::56:::|h[Spoils of the Triumphant]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4832) (nil) (0) (false) (false) (false) (false)", -- [2480]
			"23:14:55 - ML event (CHAT_MSG_LOOT) (Galastradra receives loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Galastradra) () (0) (0) () (0) (4835) (nil) (0) (false) (false) (false) (false)", -- [2481]
			"23:14:56 - ML event (CHAT_MSG_LOOT) (Tuyen receives loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Tuyen) () (0) (0) () (0) (4837) (nil) (0) (false) (false) (false) (false)", -- [2482]
			"23:14:57 - ML event (CHAT_MSG_LOOT) (Lithelasha receives loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Lithelasha) () (0) (0) () (0) (4840) (nil) (0) (false) (false) (false) (false)", -- [2483]
			"23:14:57 - Comm received:^1^SEUBonusRoll^T^N1^SDibbs-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:262:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2484]
			"23:15:03 - ML event (CHAT_MSG_LOOT) (Chauric receives loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Chauric) () (0) (0) () (0) (4842) (nil) (0) (false) (false) (false) (false)", -- [2485]
			"23:15:41 - Event: (LOOT_OPENED) (1)", -- [2486]
			"23:15:41 - CanWeLootItem (|cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r) (4) (false)", -- [2487]
			"23:15:41 - CanWeLootItem (|cffa335ee|Hitem:152526::::::::110:105::3::::|h[Helm of the Antoran Protector]|h|r) (4) (true)", -- [2488]
			"23:15:41 - ML:AddItem (|cffa335ee|Hitem:152526::::::::110:105::3::::|h[Helm of the Antoran Protector]|h|r) (false) (2) (nil)", -- [2489]
			"23:15:41 - CanWeLootItem (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1487:3337:::|h[Prototype Titan-Disc]|h|r) (4) (true)", -- [2490]
			"23:15:41 - ML:AddItem (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1487:3337:::|h[Prototype Titan-Disc]|h|r) (false) (3) (nil)", -- [2491]
			"23:15:41 - CanWeLootItem (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Titan-Disc]|h|r) (4) (true)", -- [2492]
			"23:15:41 - ML:AddItem (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Titan-Disc]|h|r) (false) (4) (nil)", -- [2493]
			"23:15:41 - RCSessionFrame (enabled)", -- [2494]
			"23:15:41 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r)", -- [2495]
			"23:15:41 - ML event (UI_INFO_MESSAGE) (286) (Sigil of the Dark Titan: 2/4)", -- [2496]
			"23:15:41 - ML event (CHAT_MSG_LOOT) (You receive loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4859) (nil) (0) (false) (false) (false) (false)", -- [2497]
			"23:15:47 - Event: (LOOT_CLOSED)", -- [2498]
			"23:15:47 - BONUS_ROLL_RESULT (artifact_power) (|cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted Azsharan Seal]|h|r) (1) (0) (2) (false)", -- [2499]
			"23:15:47 - Comm received:^1^SEUBonusRoll^T^N1^SAvernakis-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2500]
			"23:15:47 - ML event (CHAT_MSG_LOOT) (You receive bonus loot: |cff0070dd|Hitem:147581::::::::110:105:8388608:3::56:::|h[Depleted Azsharan Seal]|h|r.) () () () (Avernakis) () (0) (0) () (0) (4862) (nil) (0) (false) (false) (false) (false)", -- [2501]
			"23:15:49 - ML:StartSession()", -- [2502]
			"23:15:49 - ML:AnnounceItems()", -- [2503]
			"23:15:49 - Comm received:^1^SlootTable^T^N1^T^N1^T^SequipLoc^S^Sgp^N707^Silvl^N930^Slink^S|cffa335ee|Hitem:152526::::::::110:105::3::::|h[Helm~`of~`the~`Antoran~`Protector]|h|r^Stexture^N133126^SlootSlot^N2^SsubType^SJunk^Srelic^b^Sclasses^N581^Sname^SHelm~`of~`the~`Antoran~`Protector^Stoken^SHeadSlot^Sboe^b^Sawarded^b^Squality^N4^t^N2^T^SequipLoc^S^Sgp^N667^Silvl^N945^Slink^S|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1487:3337:::|h[Prototype~`Titan-Disc]|h|r^Srelic^SArcane^Stexture^N134375^SsubType^SArtifact~`Relic^SlootSlot^N3^Sclasses^N4294967295^Sname^SPrototype~`Titan-Disc^Sboe^b^Sawarded^b^Squality^N4^t^N3^T^SequipLoc^S^Sgp^N472^Silvl^N930^Slink^S|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Titan-Disc]|h|r^Srelic^SArcane^Stexture^N134375^SsubType^SArtifact~`Relic^SlootSlot^N4^Sclasses^N4294967295^Sname^SPrototype~`Titan-Disc^Sboe^b^Sawarded^b^Squality^N4^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2504]
			"23:15:49 - SwitchSession (1)", -- [2505]
			"23:15:49 - SwitchSession (1)", -- [2506]
			"23:15:49 - Autopassed on:  (|cffa335ee|Hitem:152526::::::::110:105::3::::|h[Helm of the Antoran Protector]|h|r)", -- [2507]
			"23:15:49 - NewRelicAutopassCheck (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1487:3337:::|h[Prototype Titan-Disc]|h|r) (Arcane)", -- [2508]
			"23:15:49 - NewRelicAutopassCheck (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Titan-Disc]|h|r) (Arcane)", -- [2509]
			"23:15:49 - GetPlayersGear (|cffa335ee|Hitem:152526::::::::110:105::3::::|h[Helm of the Antoran Protector]|h|r) (INVTYPE_HEAD)", -- [2510]
			"23:15:49 - LootFrame:Start()", -- [2511]
			"23:15:49 - Restoring entry: (relic) (2)", -- [2512]
			"23:15:49 - Restoring entry: (relic) (2)", -- [2513]
			"23:15:49 - GetPlayersGear (|cffa335ee|Hitem:152526::::::::110:105::3::::|h[Helm of the Antoran Protector]|h|r) ()", -- [2514]
			"23:15:49 - GetPlayersGear (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1487:3337:::|h[Prototype Titan-Disc]|h|r) ()", -- [2515]
			"23:15:49 - GetPlayersGear (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Titan-Disc]|h|r) ()", -- [2516]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SFreakeer-Area52^N2^N262^N3^N941.875^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N15^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:147178::::::::110:262::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2517]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SFreakeer-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N816.664^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N74^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2518]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SAhoyful-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N818.86^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N65^Straits^N70^Slegend^N1^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2519]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SAhoyful-Area52^N2^N65^N3^N916.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-5^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:151590::151580::::::110:65::13:5:1685:3408:3609:601:3608^t^Sgear2^T^t^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2520]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SLithelasha-Area52^N2^T^Sforged^N10^Spawn^T^N1^T^Sequipped^N75114.74^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2521]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SGalastradra-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N1046.71^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N261^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2522]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SAmrehlu-Area52^N2^T^Sforged^N6^Spawn^T^N1^T^Sequipped^N874.149^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N253^Straits^N75^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2523]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SLesmes-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N87516.57^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N63^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2524]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SLithelasha-Area52^N2^N577^N3^N943.125^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N5^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:147130::::::::110:577::5:3:3562:1507:3336^t^Sgear2^T^t^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2525]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SPhryke-Area52^N2^T^Sforged^N5^Spawn^T^N1^T^Sequipped^N995.641^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N265^Straits^N69^Slegend^N2^Ssockets^N4^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2526]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N941.4375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:138330::::::::110:105::5:4:3516:41:1512:3337^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2527]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SAvernakis-Area52^N2^T^Sforged^N9^Spawn^T^N1^T^Sequipped^N913.505^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N105^Straits^N75^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2528]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SDibbs-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N845.946^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N262^Straits^N76^Slegend^N2^Ssockets^N2^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2529]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N15^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:147130::::::::110:577::5:3:3562:1497:3528^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2530]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N-5^N2^N30^N3^N15^t^Sgear1^T^N1^Sitem:151587::151583::::::110:63::13:5:1695:3408:3609:600:3608^N2^Sitem:140810::::::::110:63::43:3:3573:1512:3336^N3^Sitem:140810::::::::110:63::43:3:3573:1512:3336^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2531]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SVelynila-Area52^N2^T^Sforged^N8^Spawn^T^N1^T^Sequipped^N70331.72^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N577^Straits^N70^Slegend^N2^Ssockets^N1^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2532]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N942.4375^N4^T^Sresponse^T^t^Sdiff^T^N1^N10^N2^N15^N3^N0^t^Sgear1^T^N1^Sitem:147142::::::::110:253::5:3:3562:1502:3336^N2^Sitem:147079::::::::110:253::5:3:3562:1512:3336^N3^Sitem:147079::::::::110:253::5:3:3562:1512:3336^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2533]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SGalastradra-Area52^N2^N261^N3^N950.0625^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N0^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:151985::::::::110:261::3:3:3610:1472:3528^t^Sgear2^T^t^t^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2534]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SSulana-Area52^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2535]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SDibbs-Area52^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2536]
			"23:15:49 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sdiff^N-5^SspecID^N270^Sgear1^S|cffa335ee|Hitem:134447::::::::110:270::35:4:3418:43:1587:3337:::|h[Veil~`of~`Unseen~`Strikes]|h|r^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2537]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SPhryke-Area52^N2^N265^N3^N937.4375^N4^T^Sresponse^T^N1^B^N2^B^N3^B^t^Sdiff^T^N1^N-5^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:151587::151584::::::110:265::13:5:1702:3408:3609:600:3608^t^Sgear2^T^t^t^t^^ (from:) (Phryke) (distri:) (RAID)", -- [2538]
			"23:15:49 - Comm received:^1^Sresponse^T^N1^N2^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^SspecID^N270^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2539]
			"23:15:49 - Comm received:^1^Sresponse^T^N1^N3^N2^SSulana-Area52^N3^T^Silvl^N947.625^Sresponse^SAUTOPASS^SspecID^N270^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2540]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^STuyen-Area52^N2^N66^N3^N946.375^N4^T^Sresponse^T^N1^B^t^Sdiff^T^N1^N0^N2^N-10^N3^N-25^t^Sgear1^T^N1^Sitem:152151::::::::110:66::3:3:3610:1472:3528^N2^Sitem:137420::::::::110:66::35:3:3418:1607:3337^N3^Sitem:137420::::::::110:66::35:3:3418:1607:3337^t^Sgear2^T^t^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2541]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^STuyen-Area52^N2^T^Sforged^N7^Spawn^T^N1^T^Sequipped^N888.462^Snew^N0^t^N2^T^Sequipped^N0^Snew^N0^t^N3^T^Sequipped^N0^Snew^N0^t^t^SspecID^N66^Straits^N75^Slegend^N2^Ssockets^N3^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2542]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SChauric-Area52^N2^N268^N3^N938.5625^N4^T^Sresponse^T^N2^B^N3^B^t^Sdiff^T^N1^N-70^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:137063::::::::110:268:::2:1811:3630^t^Sgear2^T^t^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2543]
			"23:15:49 - Comm received:^1^SextraUtilData^T^N1^SDravash-Area52^N2^T^Sforged^N9^Spawn^T^t^SspecID^N252^Straits^N68^Slegend^N2^Ssockets^N6^SupgradeIlvl^N0^Supgrades^S0/0^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2544]
			"23:15:49 - Comm received:^1^SlootAck^T^N1^SDravash-Area52^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2545]
			"23:15:50 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sdiff^N10^SspecID^N262^Sgear1^S|cffa335ee|Hitem:147178::::::::110:262::3:3:3561:1502:3337:::|h[Helmet~`of~`the~`Skybreaker]|h|r^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2546]
			"23:15:50 - Comm received:^1^Sresponse^T^N1^N1^N2^SDravash-Area52^N3^T^Silvl^N945.25^Sresponse^SAUTOPASS^Sdiff^N-5^SspecID^N252^Sgear1^S|cffa335ee|Hitem:151590::151580::::::110:252::13:5:1698:3408:3609:600:3608:::|h[Empyrial~`Titan~`Crown~`of~`the~`Feverflare]|h|r^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2547]
			"23:15:50 - Comm received:^1^Sresponse^T^N1^N1^N2^SSulana-Area52^N3^T^Sresponse^N1^SisTier^B^SisRelic^b^t^t^^ (from:) (Sulana) (distri:) (RAID)", -- [2548]
			"23:15:50 - Comm received:^1^Sresponse^T^N1^N2^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^SspecID^N262^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2549]
			"23:15:50 - Comm received:^1^Sresponse^T^N1^N2^N2^SDravash-Area52^N3^T^Silvl^N945.25^Sresponse^SAUTOPASS^SspecID^N252^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2550]
			"23:15:51 - Comm received:^1^Sresponse^T^N1^N3^N2^SDibbs-Area52^N3^T^Silvl^N939.4375^Sresponse^SAUTOPASS^SspecID^N262^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2551]
			"23:15:51 - Comm received:^1^Sresponse^T^N1^N3^N2^SDravash-Area52^N3^T^Silvl^N945.25^Sresponse^SAUTOPASS^SspecID^N252^t^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2552]
			"23:15:52 - Comm received:^1^Sresponse^T^N1^N1^N2^SDibbs-Area52^N3^T^Sresponse^N4^SisTier^B^SisRelic^b^t^t^^ (from:) (Dibbs) (distri:) (RAID)", -- [2553]
			"23:15:52 - Comm received:^1^Sresponse^T^N1^N1^N2^SChauric-Area52^N3^T^Sresponse^N1^SisTier^B^t^t^^ (from:) (Chauric) (distri:) (RAID)", -- [2554]
			"23:15:53 - LootFrame:Response (4) (Response:) (Offspec)", -- [2555]
			"23:15:53 - SendResponse (group) (2) (4) (nil) (true) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [2556]
			"23:15:53 - Trashing entry: (1) (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1487:3337:::|h[Prototype Titan-Disc]|h|r)", -- [2557]
			"23:15:53 - Comm received:^1^Sresponse^T^N1^N2^N2^SAvernakis-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2558]
			"23:15:53 - Comm received:^1^Sresponse^T^N1^N1^N2^SAmrehlu-Area52^N3^T^Sresponse^N3^SisTier^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2559]
			"23:15:54 - Comm received:^1^Sresponse^T^N1^N2^N2^SVelynila-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2560]
			"23:15:55 - LootFrame:Response (4) (Response:) (Offspec)", -- [2561]
			"23:15:55 - SendResponse (group) (3) (4) (nil) (true) (nil) (nil) (nil) (nil) (nil) (nil) (nil) (nil)", -- [2562]
			"23:15:55 - Trashing entry: (1) (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Titan-Disc]|h|r)", -- [2563]
			"23:15:55 - Comm received:^1^SEUBonusRoll^T^N1^SDravash-Area52^N2^Sartifact_power^N3^S|cff0070dd|Hitem:147581::::::::110:252:8388608:3::56:::|h[Depleted~`Azsharan~`Seal]|h|r^t^^ (from:) (Dravash) (distri:) (RAID)", -- [2564]
			"23:15:55 - Comm received:^1^Sresponse^T^N1^N3^N2^SAvernakis-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2565]
			"23:15:55 - Comm received:^1^Sresponse^T^N1^N3^N2^SVelynila-Area52^N3^T^Sresponse^N4^SisRelic^B^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2566]
			"23:15:56 - Comm received:^1^Sresponse^T^N1^N2^N2^STuyen-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2567]
			"23:15:56 - Comm received:^1^Sresponse^T^N1^N3^N2^STuyen-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Tuyen) (distri:) (RAID)", -- [2568]
			"23:15:57 - Comm received:^1^Sresponse^T^N1^N2^N2^SLesmes-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2569]
			"23:15:57 - Event: (LOOT_OPENED) (1)", -- [2570]
			"23:15:57 - lootSlot @session (2) (Was at:) (3) (is now at:) (1)", -- [2571]
			"23:15:57 - lootSlot @session (3) (Was at:) (4) (is now at:) (3)", -- [2572]
			"23:15:58 - Comm received:^1^Svote^T^N1^N1^N2^SDibbs-Area52^N3^N1^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2573]
			"23:15:58 - 1 = (IsCouncil) (Galastradra)", -- [2574]
			"23:15:58 - Comm received:^1^Sresponse^T^N1^N2^N2^SAhoyful-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2575]
			"23:15:58 - Comm received:^1^Sresponse^T^N1^N1^N2^SFreakeer-Area52^N3^T^Sresponse^SPASS^SisTier^B^t^t^^ (from:) (Freakeer) (distri:) (RAID)", -- [2576]
			"23:16:00 - Comm received:^1^Sresponse^T^N1^N3^N2^SLesmes-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2577]
			"23:16:00 - Comm received:^1^Sresponse^T^N1^N3^N2^SAhoyful-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Ahoyful) (distri:) (RAID)", -- [2578]
			"23:16:02 - Comm received:^1^Soffline_timer^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2579]
			"23:16:04 - Comm received:^1^Sresponse^T^N1^N2^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2580]
			"23:16:04 - Comm received:^1^Sresponse^T^N1^N3^N2^SLithelasha-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Lithelasha) (distri:) (RAID)", -- [2581]
			"23:16:07 - ML:Award (1) (Dibbs-Area52) (4th Set Piece) (nil)", -- [2582]
			"23:16:07 - GiveMasterLoot (2) (12)", -- [2583]
			"23:16:08 - OnLootSlotCleared() (2) (|cffa335ee|Hitem:152526::::::::110:105::3::::|h[Helm of the Antoran Protector]|h|r)", -- [2584]
			"23:16:08 - ML:TrackAndLogLoot()", -- [2585]
			"23:16:08 - Comm received:^1^Shistory^T^N1^SDibbs-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SSHAMAN^SgroupSize^N14^Svotes^N1^Stime^S23:16:08^SitemReplaced1^S|cffa335ee|Hitem:147178::::::::110:105::3:3:3561:1502:3337:::|h[Helmet~`of~`the~`Skybreaker]|h|r^Sid^S1512810968-27^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^SrelicRoll^b^Sresponse^S4th~`Set~`Piece^StokenRoll^B^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152526::::::::110:105::3::::|h[Helm~`of~`the~`Antoran~`Protector]|h|r^StierToken^SHeadSlot^SisAwardReason^b^SresponseID^N4^Sboss^SAggramar^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2586]
			"23:16:08 - Comm received:^1^Sawarded^T^N1^N1^N2^SDibbs-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2587]
			"23:16:08 - SwitchSession (2)", -- [2588]
			"23:16:09 - GetLootDBStatistics()", -- [2589]
			"23:16:13 - ML event (CHAT_MSG_LOOT) (Dibbs receives loot: |cffa335ee|Hitem:152526::::::::110:105::3::::|h[Helm of the Antoran Protector]|h|r.) () () () ()", -- [2590]
			"23:16:13 - Comm received:^1^Sresponse^T^N1^N2^N2^SAmrehlu-Area52^N3^T^Sresponse^N1^SisRelic^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2591]
			"23:16:15 - SwitchSession (3)", -- [2592]
			"23:16:17 - SwitchSession (2)", -- [2593]
			"23:16:18 - SwitchSession (3)", -- [2594]
			"23:16:20 - Comm received:^1^Svote^T^N1^N2^N2^SLesmes-Area52^N3^N1^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2595]
			"23:16:20 - 1 = (IsCouncil) (Galastradra)", -- [2596]
			"23:16:20 - Comm received:^1^Svote^T^N1^N2^N2^SAmrehlu-Area52^N3^N1^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2597]
			"23:16:20 - 1 = (IsCouncil) (Galastradra)", -- [2598]
			"23:16:21 - SwitchSession (2)", -- [2599]
			"23:16:22 - Comm received:^1^Svote^T^N1^N3^N2^SLesmes-Area52^N3^N1^t^^ (from:) (Galastradra) (distri:) (RAID)", -- [2600]
			"23:16:22 - 1 = (IsCouncil) (Galastradra)", -- [2601]
			"23:16:27 - ML event (CHAT_MSG_LOOT) (Velynila receives loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Velynila) () (0) (0) () (0) (4875) (nil) (0) (false) (false) (false) (false)", -- [2602]
			"23:16:27 - Event: (LOOT_CLOSED)", -- [2603]
			"23:16:29 - Comm received:^1^Sresponse^T^N1^N3^N2^SAmrehlu-Area52^N3^T^Sresponse^SPASS^SisRelic^B^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2604]
			"23:16:31 - Event: (LOOT_OPENED) (1)", -- [2605]
			"23:16:31 - lootSlot @session (3) (Was at:) (3) (is now at:) (2)", -- [2606]
			"23:16:32 - ML event (CHAT_MSG_LOOT) (Phryke receives loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Phryke) () (0) (0) () (0) (4878) (nil) (0) (false) (false) (false) (false)", -- [2607]
			"23:16:33 - ML event (CHAT_MSG_LOOT) (Dravash receives loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Dravash) () (0) (0) () (0) (4879) (nil) (0) (false) (false) (false) (false)", -- [2608]
			"23:16:43 - ML event (CHAT_MSG_LOOT) (Amrehlu receives loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (4882) (nil) (0) (false) (false) (false) (false)", -- [2609]
			"23:16:53 - SwitchSession (3)", -- [2610]
			"23:16:54 - ML event (CHAT_MSG_LOOT) (Ahoyful receives loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Ahoyful) () (0) (0) () (0) (4885) (nil) (0) (false) (false) (false) (false)", -- [2611]
			"23:16:55 - SwitchSession (2)", -- [2612]
			"23:17:02 - ReannounceOrRequestRoll (function: 000001AB352817D0) (function: 000001AB6CF90530) (true) (false) (false)", -- [2613]
			"23:17:02 - Comm received:^1^Srolls^T^N1^N2^N2^T^SAmrehlu-Area52^S^SLesmes-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2614]
			"23:17:02 - Comm received:^1^SlootAck^T^N1^SAmrehlu-Area52^N2^N253^N3^N942.4375^N4^T^Sresponse^T^t^Sdiff^T^N1^N15^t^Sgear1^T^N1^Sitem:147079::::::::110:253::5:3:3562:1512:3336^t^Sgear2^T^t^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2615]
			"23:17:02 - Comm received:^1^SlootAck^T^N1^SLesmes-Area52^N2^N63^N3^N942.375^N4^T^Sresponse^T^t^Sdiff^T^N1^N30^t^Sgear1^T^N1^Sitem:140810::::::::110:63::43:3:3573:1512:3336^t^Sgear2^T^t^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2616]
			"23:17:04 - Comm received:^1^Sroll^T^N1^SAmrehlu-Area52^N2^N6^N3^T^N1^N2^t^t^^ (from:) (Amrehlu) (distri:) (RAID)", -- [2617]
			"23:17:05 - Comm received:^1^Sroll^T^N1^SLesmes-Area52^N2^N77^N3^T^N1^N2^t^t^^ (from:) (Lesmes) (distri:) (RAID)", -- [2618]
			"23:17:10 - ML:Award (2) (Lesmes-Area52) (Major Upgrade (4+ Trait Increase)) (nil)", -- [2619]
			"23:17:10 - GiveMasterLoot (1) (3)", -- [2620]
			"23:17:11 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1487:3337:::|h[Prototype Titan-Disc]|h|r)", -- [2621]
			"23:17:11 - ML:TrackAndLogLoot()", -- [2622]
			"23:17:11 - ML event (CHAT_MSG_LOOT) (Lesmes receives loot: |cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1487:3337:::|h[Prototype Titan-Disc]|h|r.) () () () (Lesmes) () (0) (0) () (0) (4891) (nil) (0) (false) (false) (false) (false)", -- [2623]
			"23:17:11 - Comm received:^1^Shistory^T^N1^SLesmes-Area52^N2^T^SmapID^N1712^Sdate^S08/12/17^Sclass^SMAGE^SgroupSize^N14^SisAwardReason^b^Stime^S23:17:11^SitemReplaced1^S|cffa335ee|Hitem:140810::::::::110:105::43:3:3573:1512:3336:::|h[Farsight~`Spiritjewel]|h|r^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sid^S1512811031-28^Sresponse^SMajor~`Upgrade~`(4+~`Trait~`Increase)^SdifficultyID^N14^SlootWon^S|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1487:3337:::|h[Prototype~`Titan-Disc]|h|r^SrelicRoll^B^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^SresponseID^N1^Sboss^SAggramar^Svotes^N1^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2624]
			"23:17:11 - Comm received:^1^Sawarded^T^N1^N2^N2^SLesmes-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2625]
			"23:17:11 - SwitchSession (3)", -- [2626]
			"23:17:12 - GetLootDBStatistics()", -- [2627]
			"23:17:20 - SwitchSession (2)", -- [2628]
			"23:17:21 - SwitchSession (3)", -- [2629]
			"23:17:24 - Event: (LOOT_OPENED) (1)", -- [2630]
			"23:17:25 - Event: (LOOT_CLOSED)", -- [2631]
			"23:17:26 - Event: (LOOT_OPENED) (1)", -- [2632]
			"23:17:26 - lootSlot @session (3) (Was at:) (2) (is now at:) (1)", -- [2633]
			"23:17:30 - ReannounceOrRequestRoll (function: 000001AACD4F8AE0) (function: 000001AB75BCAE00) (true) (false) (false)", -- [2634]
			"23:17:30 - Comm received:^1^Sreroll^T^N1^T^N1^T^SequipLoc^S^Silvl^N930^Slink^S|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Titan-Disc]|h|r^SisRoll^B^Sclasses^N4294967295^Sname^SPrototype~`Titan-Disc^SnoAutopass^b^Srelic^SArcane^Ssession^N3^Stexture^N134375^t^t^t^^ (from:) (Avernakis) (distri:) (WHISPER)", -- [2635]
			"23:17:30 - NewRelicAutopassCheck (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Titan-Disc]|h|r) (Arcane)", -- [2636]
			"23:17:30 - LootFrame:ReRoll(#table) (1)", -- [2637]
			"23:17:30 - LootFrame:Start()", -- [2638]
			"23:17:30 - Restoring entry: (roll) (1)", -- [2639]
			"23:17:30 - Comm received:^1^Srolls^T^N1^N3^N2^T^SVelynila-Area52^S^SAvernakis-Area52^S^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2640]
			"23:17:30 - Comm received:^1^SlootAck^T^N1^SAvernakis-Area52^N2^N105^N3^N941.4375^N4^T^Sresponse^T^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2641]
			"23:17:30 - Comm received:^1^SlootAck^T^N1^SVelynila-Area52^N2^N577^N3^N929.5^N4^T^Sresponse^T^t^Sdiff^T^N1^N0^t^Sgear1^T^t^Sgear2^T^t^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2642]
			"23:17:34 - Comm received:^1^Sroll^T^N1^SAvernakis-Area52^N2^N12^N3^T^N1^N3^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2643]
			"23:17:34 - Trashing entry: (1) (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Titan-Disc]|h|r)", -- [2644]
			"23:17:38 - Comm received:^1^Sroll^T^N1^SVelynila-Area52^N2^N43^N3^T^N1^N3^t^t^^ (from:) (Velynila) (distri:) (RAID)", -- [2645]
			"23:17:41 - ML event (CHAT_MSG_LOOT) (Dibbs receives loot: |cffa335ee|Hitem:152908::::::::110:105::::::|h[Sigil of the Dark Titan]|h|r.) () () () (Dibbs) () (0) (0) () (0) (4901) (nil) (0) (false) (false) (false) (false)", -- [2646]
			"23:17:43 - ML:Award (3) (Velynila-Area52) (Offspec) (nil)", -- [2647]
			"23:17:43 - GiveMasterLoot (1) (13)", -- [2648]
			"23:17:43 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Titan-Disc]|h|r)", -- [2649]
			"23:17:43 - ML:TrackAndLogLoot()", -- [2650]
			"23:17:43 - Event: (LOOT_CLOSED)", -- [2651]
			"23:17:43 - Event: (LOOT_CLOSED)", -- [2652]
			"23:17:43 - Comm received:^1^Shistory^T^N1^SVelynila-Area52^N2^T^Sid^S1512811063-29^SrelicRoll^B^SmapID^N1712^SgroupSize^N14^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Sclass^SDEMONHUNTER^Sdate^S08/12/17^Sresponse^SOffspec^Sinstance^SAntorus,~`the~`Burning~`Throne-Normal^Sboss^SAggramar^Stime^S23:17:43^SdifficultyID^N14^Svotes^N0^SresponseID^N4^SlootWon^S|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype~`Titan-Disc]|h|r^SisAwardReason^b^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2653]
			"23:17:43 - Comm received:^1^Sawarded^T^N1^N3^N2^SVelynila-Area52^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2654]
			"23:17:43 - SwitchSession (3)", -- [2655]
			"23:17:44 - ML:EndSession()", -- [2656]
			"23:17:44 - Comm received:^1^Ssession_end^T^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2657]
			"23:17:44 - RCVotingFrame:EndSession (false)", -- [2658]
			"23:17:44 - GetLootDBStatistics()", -- [2659]
			"23:17:45 - Hide VotingFrame", -- [2660]
			"23:17:48 - ML event (CHAT_MSG_LOOT) (Velynila receives loot: |cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Titan-Disc]|h|r.) () () () ()", -- [2661]
			"23:18:32 - UpdateGroup (table: 000001AAF56A0A00)", -- [2662]
			"23:18:42 - UpdateGroup (table: 000001AAF56A0A00)", -- [2663]
			"23:24:06 - Event: (ENCOUNTER_START) (2092) (Argus the Unmaker) (14) (14)", -- [2664]
			"23:24:06 - UpdatePlayersData()", -- [2665]
			"23:28:11 - ML event (PLAYER_REGEN_ENABLED)", -- [2666]
			"23:29:04 - Event: (ENCOUNTER_END) (2092) (Argus the Unmaker) (14) (14) (0)", -- [2667]
			"23:33:58 - Event: (ENCOUNTER_START) (2092) (Argus the Unmaker) (14) (14)", -- [2668]
			"23:33:58 - UpdatePlayersData()", -- [2669]
			"23:42:58 - ML event (PLAYER_REGEN_ENABLED)", -- [2670]
			"23:46:04 - ML event (PLAYER_REGEN_ENABLED)", -- [2671]
			"23:46:13 - Event: (ENCOUNTER_END) (2092) (Argus the Unmaker) (14) (14) (0)", -- [2672]
			"23:48:51 - Event: (PLAYER_ENTERING_WORLD) (false) (false)", -- [2673]
			"23:48:51 - GetML()", -- [2674]
			"23:48:51 - LootMethod =  (master)", -- [2675]
			"23:49:08 - UpdateGroup (table: 000001AAF56A0A00)", -- [2676]
			"23:49:08 - ML:RemoveCandidate (Dibbs-Area52)", -- [2677]
			"23:49:08 - ML:RemoveCandidate (Chauric-Area52)", -- [2678]
			"23:49:08 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Galastradra-Area52) (Tuyen-Area52)", -- [2679]
			"23:49:08 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SAmrehlu-Area52^T^Srole^SDAMAGER^Senchant_lvl^N0^Sclass^SHUNTER^Srank^SStewed^t^SVelynila-Area52^T^Srole^SDAMAGER^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SBoiled^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^SAhoyful-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SPALADIN^Srank^SSpud^t^SDravash-Area52^T^Srole^SDAMAGER^SspecID^N251^Senchant_lvl^N0^Sclass^SDEATHKNIGHT^Srank^SBoiled^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SBoiled^t^SGalastradra-Area52^T^Srole^SDAMAGER^SspecID^N261^Senchant_lvl^N0^Sclass^SROGUE^Srank^STater~`Tot^t^SSulana-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SMONK^Srank^SBoiled^t^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2680]
			"23:49:18 - UpdateGroup (table: 000001AAF56A0A00)", -- [2681]
			"23:49:18 - ML:RemoveCandidate (Dravash-Area52)", -- [2682]
			"23:49:18 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Galastradra-Area52) (Tuyen-Area52)", -- [2683]
			"23:49:18 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SAmrehlu-Area52^T^Srole^SDAMAGER^Senchant_lvl^N0^Sclass^SHUNTER^Srank^SStewed^t^SVelynila-Area52^T^Srole^SDAMAGER^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SBoiled^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^SAhoyful-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SPALADIN^Srank^SSpud^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SBoiled^t^SGalastradra-Area52^T^Srole^SDAMAGER^SspecID^N261^Senchant_lvl^N0^Sclass^SROGUE^Srank^STater~`Tot^t^SSulana-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SMONK^Srank^SBoiled^t^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2684]
			"23:49:28 - UpdateGroup (table: 000001AAF56A0A00)", -- [2685]
			"23:49:28 - ML:RemoveCandidate (Amrehlu-Area52)", -- [2686]
			"23:49:28 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Galastradra-Area52) (Tuyen-Area52)", -- [2687]
			"23:49:28 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SVelynila-Area52^T^Srole^SDAMAGER^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SBoiled^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^SAhoyful-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SPALADIN^Srank^SSpud^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SBoiled^t^SGalastradra-Area52^T^Srole^SDAMAGER^SspecID^N261^Senchant_lvl^N0^Sclass^SROGUE^Srank^STater~`Tot^t^SSulana-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SMONK^Srank^SBoiled^t^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2688]
			"23:49:38 - UpdateGroup (table: 000001AAF56A0A00)", -- [2689]
			"23:49:38 - ML:RemoveCandidate (Velynila-Area52)", -- [2690]
			"23:49:38 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Galastradra-Area52) (Tuyen-Area52)", -- [2691]
			"23:49:38 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^SAhoyful-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SPALADIN^Srank^SSpud^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SBoiled^t^SGalastradra-Area52^T^Srole^SDAMAGER^SspecID^N261^Senchant_lvl^N0^Sclass^SROGUE^Srank^STater~`Tot^t^SSulana-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SMONK^Srank^SBoiled^t^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2692]
			"23:49:48 - UpdateGroup (table: 000001AAF56A0A00)", -- [2693]
			"23:49:48 - ML:RemoveCandidate (Galastradra-Area52)", -- [2694]
			"23:49:48 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Tuyen-Area52)", -- [2695]
			"23:49:48 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SLithelasha-Area52^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SStewed^t^SAhoyful-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SPALADIN^Srank^SSpud^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SBoiled^t^SSulana-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SMONK^Srank^SBoiled^t^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2696]
			"23:49:48 - Comm received:^1^Scouncil^T^N1^T^N1^SFreakeer-Area52^N2^SAvernakis-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2697]
			"23:49:48 - true = (IsCouncil) (Avernakis-Area52)", -- [2698]
			"23:49:58 - UpdateGroup (table: 000001AAF56A0A00)", -- [2699]
			"23:49:58 - ML:RemoveCandidate (Lithelasha-Area52)", -- [2700]
			"23:49:58 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Tuyen-Area52)", -- [2701]
			"23:49:58 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SAhoyful-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SPALADIN^Srank^SSpud^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SBoiled^t^SSulana-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SMONK^Srank^SBoiled^t^SLesmes-Area52^T^Srole^SDAMAGER^SspecID^N63^Senchant_lvl^N790^Sclass^SMAGE^Senchanter^B^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2702]
			"23:50:40 - UpdateGroup (table: 000001AAF56A0A00)", -- [2703]
			"23:50:40 - ML:RemoveCandidate (Lesmes-Area52)", -- [2704]
			"23:50:40 - GetCouncilInGroup (Freakeer-Area52) (Avernakis-Area52) (Tuyen-Area52)", -- [2705]
			"23:50:40 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SFreakeer-Area52^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^STater~`Salad^t^SAhoyful-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SPALADIN^Srank^SSpud^t^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SBoiled^t^SSulana-Area52^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SMONK^Srank^SBoiled^t^t^t^^ (from:) (Avernakis) (distri:) (RAID)", -- [2706]
			"23:51:53 - Event: (PLAYER_ENTERING_WORLD) (false) (false)", -- [2707]
			"23:51:53 - GetML()", -- [2708]
			"23:51:53 - LootMethod =  (master)", -- [2709]
			"23:52:09 - Event: (GROUP_LEFT) (Party-3676-00001DD2398D)", -- [2710]
			"23:52:09 - GetML()", -- [2711]
			"23:52:09 - LootMethod =  (personalloot)", -- [2712]
			"23:52:09 - ML Disabled", -- [2713]
			"23:54:57 - Event: (PLAYER_ENTERING_WORLD) (false) (false)", -- [2714]
			"23:54:57 - GetML()", -- [2715]
			"23:54:57 - LootMethod =  (personalloot)", -- [2716]
			"23:55:20 - Event: (PLAYER_ENTERING_WORLD) (false) (false)", -- [2717]
			"23:55:20 - GetML()", -- [2718]
			"23:55:20 - LootMethod =  (personalloot)", -- [2719]
			"23:55:39 - Event: (LOOT_CLOSED)", -- [2720]
			"23:57:17 - Event: (PARTY_LEADER_CHANGED)", -- [2721]
			"23:57:17 - GetML()", -- [2722]
			"23:57:17 - LootMethod =  (personalloot)", -- [2723]
			"23:57:17 - Resetting council as we have a new ML!", -- [2724]
			"23:57:17 - MasterLooter =  (Galastradra-Area52)", -- [2725]
			"23:57:17 - Event: (PARTY_LOOT_METHOD_CHANGED)", -- [2726]
			"23:57:17 - GetML()", -- [2727]
			"23:57:17 - LootMethod =  (personalloot)", -- [2728]
			"23:57:18 - Comm received:^1^SplayerInfoRequest^T^t^^ (from:) (Galastradra) (distri:) (WHISPER)", -- [2729]
			"23:57:18 - Comm received:^1^SMLdb^T^N1^T^SallowNotes^B^Stimeout^N200^SselfVote^B^SrelicNumButtons^N2^StierNumButtons^N7^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(>10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N0^N2^N0.7^N3^N0.7^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N0.7^N2^N0.7^N3^N0.7^N4^N1^t^Stext^STransmog^Ssort^N4^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N1^N3^N0.5^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0.5^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F5157063102714458^f-54^N2^N0.23921568627451^N3^N1^N4^N1^t^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^F6569957103458132^f-53^N2^F5368997202826001^f-56^N3^N1^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforged~`or~`Higher~`to~`Upgrade)^Ssort^N6^t^N7^T^Scolor^T^N1^F7700272304053086^f-53^N2^N1^N3^F4803839602528531^f-56^N4^N1^t^Stext^STransmog^Ssort^N7^t^t^t^Sobserve^B^StierButtonsEnabled^B^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforged~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^t^SmultiVote^B^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%)^t^N2^T^Stext^SMinor~`Upgrade~`(>10%)^t^N3^T^Stext^SOffspec~`^t^N4^T^Stext^STransmog~`^t^t^SnumButtons^N4^t^t^^ (from:) (Galastradra) (distri:) (WHISPER)", -- [2730]
			"23:57:18 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^Sclass^SDRUID^Srank^S^t^STuyen-Area52^T^Srole^STANK^Sclass^SPALADIN^Srank^S^t^SGalastradra-Area52^T^Srole^SDAMAGER^SspecID^N261^Senchant_lvl^N0^Sclass^SROGUE^Srank^STater~`Tot^t^t^t^^ (from:) (Galastradra) (distri:) (PARTY)", -- [2731]
			"23:57:32 - Timer MLdb_check passed", -- [2732]
			"23:57:32 - Comm received:^1^Scouncil^T^N1^T^N1^SGalastradra-Area52^t^t^^ (from:) (Galastradra) (distri:) (PARTY)", -- [2733]
			"23:57:32 - nil = (IsCouncil) (Avernakis-Area52)", -- [2734]
			"00:01:37 - Comm received:^1^Scandidates^T^N1^T^SPhryke-Area52^T^Srole^SDAMAGER^Sclass^SWARLOCK^Srank^S^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SGalastradra-Area52^T^Srole^SDAMAGER^SspecID^N261^Senchant_lvl^N0^Sclass^SROGUE^Srank^STater~`Tot^t^SAmrehlu-Area52^T^Srole^SDAMAGER^Sclass^SHUNTER^Srank^S^t^t^t^^ (from:) (Galastradra) (distri:) (PARTY)", -- [2735]
			"00:01:41 - Comm received:^1^Scouncil^T^N1^T^N1^SGalastradra-Area52^t^t^^ (from:) (Galastradra) (distri:) (PARTY)", -- [2736]
			"00:01:41 - nil = (IsCouncil) (Avernakis-Area52)", -- [2737]
			"00:05:05 - Event: (PARTY_LEADER_CHANGED)", -- [2738]
			"00:05:05 - GetML()", -- [2739]
			"00:05:05 - LootMethod =  (personalloot)", -- [2740]
			"00:05:05 - Resetting council as we have a new ML!", -- [2741]
			"00:05:05 - MasterLooter =  (Avernakis-Area52)", -- [2742]
			"00:05:05 - GetCouncilInGroup (Avernakis-Area52)", -- [2743]
			"00:05:05 - ML:NewML (Avernakis-Area52)", -- [2744]
			"00:05:05 - UpdateMLdb", -- [2745]
			"00:05:05 - UpdateGroup (true)", -- [2746]
			"00:05:05 - ML:AddCandidate (Avernakis-Area52) (DRUID) (HEALER) (nil) (nil) (nil) (nil)", -- [2747]
			"00:05:05 - ML:AddCandidate (Galastradra-Area52) (ROGUE) (DAMAGER) (nil) (nil) (nil) (nil)", -- [2748]
			"00:05:05 - ML:AddCandidate (Tuyen-Area52) (PALADIN) (TANK) (nil) (nil) (nil) (nil)", -- [2749]
			"00:05:05 - ML:AddCandidate (Amrehlu-Area52) (HUNTER) (DAMAGER) (nil) (nil) (nil) (nil)", -- [2750]
			"00:05:05 - ML:AddCandidate (Phryke-Area52) (WARLOCK) (DAMAGER) (nil) (nil) (nil) (nil)", -- [2751]
			"00:05:05 - GetCouncilInGroup (Avernakis-Area52) (Galastradra-Area52) (Tuyen-Area52)", -- [2752]
			"00:05:05 - Comm received:^1^SplayerInfoRequest^T^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [2753]
			"00:05:05 - Comm received:^1^SMLdb^T^N1^T^SrelicButtons^T^N1^T^Stext^S4+~`Trait~`Level~`Increase^t^N2^T^Stext^S3~`or~`Less~`Trait~`Level~`Increase^t^N3^T^Stext^SSame~`iLvl,~`Better~`Trait^t^N4^T^Stext^SOffspec^t^t^SallowNotes^B^Stimeout^N200^Sbuttons^T^N1^T^Stext^SMajor~`Upgrade~`(10%+)^t^N2^T^Stext^SMinor~`Upgrade~`(<10%)^t^N3^T^Stext^SOffspec^t^N4^T^Stext^STransmog^t^t^StierButtons^T^N1^T^Stext^S1st~`Set~`Piece^t^N2^T^Stext^S2nd~`Set~`Piece^t^N3^T^Stext^S3rd~`Set~`Piece^t^N4^T^Stext^S4th~`Set~`Piece^t^N5^T^Stext^SMajor~`Upgrade~`(Up~`to~`Warforged)^t^N6^T^Stext^SMinor~`Upgrade~`(Titanforge~`or~`Higher~`to~`Upgrade)^t^N7^T^Stext^STransmog^t^N8^T^Stext^SOffspec^t^t^StierNumButtons^N8^Sresponses^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(10%+)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.5^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(<10%)^Ssort^N2^t^N3^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^STransmog^Ssort^N4^t^Srelic^T^N1^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^SMajor~`Upgrade~`(4+~`Trait~`Increase)^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^F4521260802379797^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(3~`or~`Less~`Trait~`Increase)^Ssort^N2^t^N3^T^Scolor^T^N1^F8795265154629438^f-53^N2^N1^N3^F6146088903235025^f-54^N4^N1^t^Stext^SMinor~`Upgrade~`(Better~`Trait)^Ssort^N3^t^N4^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N5^t^t^Stier^T^N1^T^Scolor^T^N1^N0.1^N2^N1^N3^N0.5^N4^N1^t^Stext^S1st~`Set~`Piece^Ssort^N1^t^N2^T^Scolor^T^N1^N0^N2^N1^N3^N0^N4^N1^t^Stext^S2nd~`Set~`Piece^Ssort^N2^t^N3^T^Scolor^T^N1^F6781891203569686^f-56^N2^F6252055953290810^f-53^N3^N1^N4^N1^t^Stext^S3rd~`Set~`Piece^Ssort^N3^t^N4^T^Scolor^T^N1^N0.5^N2^N1^N3^N1^N4^N1^t^Stext^S4th~`Set~`Piece^Ssort^N4^t^N5^T^Scolor^T^N1^F8865909854666623^f-53^N2^N1^N3^F5086418402677255^f-55^N4^N1^t^Stext^SMajor~`Upgrade~`(Warforged)^Ssort^N5^t^N6^T^Scolor^T^N1^N1^N2^F4945129002602895^f-53^N3^N0^N4^N1^t^Stext^SMinor~`Upgrade~`(Titanforge+)^Ssort^N6^t^N7^T^Scolor^T^N1^F8830587504648030^f-53^N2^N0^N3^N1^N4^N1^t^Stext^SXMOG^Ssort^N7^t^N8^T^Scolor^T^N1^N1^N2^N0^N3^N0^N4^N1^t^Stext^SOffspec^Ssort^N8^t^t^t^Sepgp^T^Sbid^T^SminNewPR^S1^SbidEnabled^b^SmaxBid^S10000^SminBid^S0^SbidMode^SprRelative^SdefaultBid^S^t^t^SselfVote^B^SrelicNumButtons^N4^Sobserve^B^SmultiVote^B^StierButtonsEnabled^B^SrelicButtonsEnabled^B^SnumButtons^N4^SanonymousVoting^B^t^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [2754]
			"00:05:05 - Comm received:^1^Scandidates^T^N1^T^SPhryke-Area52^T^Srole^SDAMAGER^Sclass^SWARLOCK^Srank^S^t^SAvernakis-Area52^T^Srole^SHEALER^Sclass^SDRUID^Srank^S^t^STuyen-Area52^T^Srole^STANK^Sclass^SPALADIN^Srank^S^t^SGalastradra-Area52^T^Srole^SDAMAGER^Sclass^SROGUE^Srank^S^t^SAmrehlu-Area52^T^Srole^SDAMAGER^Sclass^SHUNTER^Srank^S^t^t^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [2755]
			"00:05:05 - Comm received:^1^Scouncil^T^N1^T^N1^SAvernakis-Area52^N2^SGalastradra-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [2756]
			"00:05:05 - true = (IsCouncil) (Avernakis-Area52)", -- [2757]
			"00:05:05 - Comm received:^1^Scouncil^T^N1^T^N1^SAvernakis-Area52^N2^SGalastradra-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [2758]
			"00:05:05 - true = (IsCouncil) (Avernakis-Area52)", -- [2759]
			"00:05:06 - Comm received:^1^SplayerInfo^T^N1^SGalastradra-Area52^N2^SROGUE^N3^SDAMAGER^N4^STater~`Tot^N6^N0^N7^N950.0625^N8^N261^t^^ (from:) (Galastradra) (distri:) (WHISPER)", -- [2760]
			"00:05:06 - ML:AddCandidate (Galastradra-Area52) (ROGUE) (DAMAGER) (Tater Tot) (nil) (0) (261)", -- [2761]
			"00:05:06 - GG:AddEntry(Update) (Galastradra-Area52) (8)", -- [2762]
			"00:05:06 - Comm received:^1^SplayerInfo^T^N1^SAvernakis-Area52^N2^SDRUID^N3^SHEALER^N4^SBaked~`Potato^N6^N0^N7^N942.4375^N8^N105^t^^ (from:) (Avernakis) (distri:) (WHISPER)", -- [2763]
			"00:05:06 - ML:AddCandidate (Avernakis-Area52) (DRUID) (HEALER) (Baked Potato) (nil) (0) (105)", -- [2764]
			"00:05:06 - Comm received:^1^SplayerInfo^T^N1^SPhryke-Area52^N2^SWARLOCK^N3^SDAMAGER^N4^SBoiled^N6^N0^N7^N936.75^N8^N265^t^^ (from:) (Phryke) (distri:) (WHISPER)", -- [2765]
			"00:05:06 - ML:AddCandidate (Phryke-Area52) (WARLOCK) (DAMAGER) (Boiled) (nil) (0) (265)", -- [2766]
			"00:05:06 - GG:AddEntry(Update) (Phryke-Area52) (11)", -- [2767]
			"00:05:06 - Comm received:^1^SplayerInfo^T^N1^STuyen-Area52^N2^SPALADIN^N3^STANK^N4^STater~`Tot^N6^N0^N7^N946.625^N8^N66^t^^ (from:) (Tuyen) (distri:) (WHISPER)", -- [2768]
			"00:05:06 - ML:AddCandidate (Tuyen-Area52) (PALADIN) (TANK) (Tater Tot) (nil) (0) (66)", -- [2769]
			"00:05:06 - GG:AddEntry(Update) (Tuyen-Area52) (1)", -- [2770]
			"00:05:06 - Comm received:^1^SplayerInfo^T^N1^SAmrehlu-Area52^N2^SHUNTER^N3^SDAMAGER^N4^SStewed^N6^N0^N7^N942.4375^N8^N253^t^^ (from:) (Amrehlu) (distri:) (WHISPER)", -- [2771]
			"00:05:06 - ML:AddCandidate (Amrehlu-Area52) (HUNTER) (DAMAGER) (Stewed) (nil) (0) (253)", -- [2772]
			"00:05:06 - GG:AddEntry(Update) (Amrehlu-Area52) (7)", -- [2773]
			"00:05:09 - Event: (LOOT_OPENED) (1)", -- [2774]
			"00:05:09 - OnLootSlotCleared() (1) (|cffffffff|Hitem:124103::::::::110:105::::::|h[Foxflower]|h|r)", -- [2775]
			"00:05:09 - Event: (LOOT_CLOSED)", -- [2776]
			"00:05:09 - ML event (CHAT_MSG_LOOT) (You receive loot: |cffffffff|Hitem:124103::::::::110:105::::::|h[Foxflower]|h|rx4.) () () () (Avernakis) () (0) (0) () (0) (5468) (nil) (0) (false) (false) (false) (false)", -- [2777]
			"00:05:15 - Comm received:^1^Scouncil^T^N1^T^N1^SAvernakis-Area52^N2^SGalastradra-Area52^N3^STuyen-Area52^t^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [2778]
			"00:05:15 - true = (IsCouncil) (Avernakis-Area52)", -- [2779]
			"00:05:15 - Comm received:^1^Scandidates^T^N1^T^SPhryke-Area52^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N0^Sclass^SWARLOCK^Srank^SBoiled^t^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SGalastradra-Area52^T^Srole^SDAMAGER^SspecID^N261^Senchant_lvl^N0^Sclass^SROGUE^Srank^STater~`Tot^t^SAmrehlu-Area52^T^Srole^SDAMAGER^SspecID^N253^Senchant_lvl^N0^Sclass^SHUNTER^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [2780]
			"00:05:20 - Timer MLdb_check passed", -- [2781]
			"00:05:53 - ML event (CHAT_MSG_LOOT) (Phryke receives loot: |cff9d9d9d|Hitem:132183::::::::110:105::::::|h[Razor Tooth]|h|r.) () () () (Phryke) () (0) (0) () (0) (5472) (nil) (0) (false) (false) (false) (false)", -- [2782]
			"00:06:46 - Event: (RAID_INSTANCE_WELCOME) (Neltharion's Lair (Mythic)) (294793) (0) (0)", -- [2783]
			"00:06:47 - Event: (PLAYER_ENTERING_WORLD) (false) (false)", -- [2784]
			"00:06:47 - GetML()", -- [2785]
			"00:06:47 - LootMethod =  (personalloot)", -- [2786]
			"00:07:19 - Comm received:^1^SverTest^T^N1^S2.7.1^t^^ (from:) (Dabzdatree) (distri:) (GUILD)", -- [2787]
			"00:07:27 - Event: (PLAYER_ENTERING_WORLD) (false) (false)", -- [2788]
			"00:07:27 - GetML()", -- [2789]
			"00:07:27 - LootMethod =  (personalloot)", -- [2790]
			"00:07:43 - Event: (RAID_INSTANCE_WELCOME) (Neltharion's Lair (Mythic)) (294736) (0) (0)", -- [2791]
			"00:07:44 - Event: (PLAYER_ENTERING_WORLD) (false) (false)", -- [2792]
			"00:07:44 - GetML()", -- [2793]
			"00:07:44 - LootMethod =  (personalloot)", -- [2794]
			"00:09:52 - ML event (TRADE_SHOW)", -- [2795]
			"00:09:55 - ML event (TRADE_ACCEPT_UPDATE) (1) (0)", -- [2796]
			"00:09:56 - ML event (TRADE_CLOSED)", -- [2797]
			"00:09:56 - ML event (TRADE_CLOSED)", -- [2798]
			"00:09:56 - ML event (UI_INFO_MESSAGE) (226) (Trade complete.)", -- [2799]
			"00:10:02 - ML event (TRADE_SHOW)", -- [2800]
			"00:10:12 - ML event (TRADE_ACCEPT_UPDATE) (1) (0)", -- [2801]
			"00:10:15 - ML event (TRADE_ACCEPT_UPDATE) (0) (0)", -- [2802]
			"00:10:17 - ML event (TRADE_CLOSED)", -- [2803]
			"00:10:17 - ML event (TRADE_CLOSED)", -- [2804]
			"00:10:17 - ML event (UI_INFO_MESSAGE) (225) (Trade cancelled.)", -- [2805]
			"00:11:42 - ML event (TRADE_SHOW)", -- [2806]
			"00:11:44 - ML event (TRADE_ACCEPT_UPDATE) (1) (0)", -- [2807]
			"00:11:44 - ML event (TRADE_ACCEPT_UPDATE) (1) (1)", -- [2808]
			"00:11:44 - ML event (TRADE_CLOSED)", -- [2809]
			"00:11:44 - ML event (TRADE_CLOSED)", -- [2810]
			"00:11:44 - ML event (UI_INFO_MESSAGE) (226) (Trade complete.)", -- [2811]
			"00:14:36 - ML event (PLAYER_REGEN_ENABLED)", -- [2812]
			"00:15:09 - ML event (PLAYER_REGEN_ENABLED)", -- [2813]
			"00:15:15 - ML event (PLAYER_REGEN_ENABLED)", -- [2814]
			"00:16:00 - ML event (PLAYER_REGEN_ENABLED)", -- [2815]
			"00:16:10 - ML event (PLAYER_REGEN_ENABLED)", -- [2816]
			"00:16:50 - ML event (PLAYER_REGEN_ENABLED)", -- [2817]
			"00:17:21 - Event: (ENCOUNTER_START) (1790) (Rokmora) (8) (5)", -- [2818]
			"00:17:21 - UpdatePlayersData()", -- [2819]
			"00:19:11 - ML event (PLAYER_REGEN_ENABLED)", -- [2820]
			"00:19:11 - Event: (ENCOUNTER_END) (1790) (Rokmora) (8) (5) (1)", -- [2821]
			"00:20:27 - ML event (PLAYER_REGEN_ENABLED)", -- [2822]
			"00:21:36 - ML event (PLAYER_REGEN_ENABLED)", -- [2823]
			"00:22:12 - ML event (PLAYER_REGEN_ENABLED)", -- [2824]
			"00:22:48 - ML event (PLAYER_REGEN_ENABLED)", -- [2825]
			"00:23:05 - ML event (PLAYER_REGEN_ENABLED)", -- [2826]
			"00:23:51 - ML event (PLAYER_REGEN_ENABLED)", -- [2827]
			"00:24:35 - ML event (PLAYER_REGEN_ENABLED)", -- [2828]
			"00:24:41 - Event: (ENCOUNTER_START) (1791) (Ularogg Cragshaper) (8) (5)", -- [2829]
			"00:24:41 - UpdatePlayersData()", -- [2830]
			"00:27:27 - Event: (ENCOUNTER_END) (1791) (Ularogg Cragshaper) (8) (5) (1)", -- [2831]
			"00:27:27 - ML event (PLAYER_REGEN_ENABLED)", -- [2832]
			"00:28:20 - ML event (PLAYER_REGEN_ENABLED)", -- [2833]
			"00:29:03 - ML event (PLAYER_REGEN_ENABLED)", -- [2834]
			"00:29:29 - ML event (PLAYER_REGEN_ENABLED)", -- [2835]
			"00:30:03 - ML event (CHAT_MSG_LOOT) (Amrehlu creates: |cffffffff|Hitem:5512::::::::110:105::::::|h[Healthstone]|h|r.) () () () (Amrehlu) () (0) (0) () (0) (5612) (nil) (0) (false) (false) (false) (false)", -- [2836]
			"00:30:34 - ML event (PLAYER_REGEN_ENABLED)", -- [2837]
			"00:30:54 - Event: (ENCOUNTER_START) (1792) (Naraxas) (8) (5)", -- [2838]
			"00:30:54 - UpdatePlayersData()", -- [2839]
			"00:33:08 - Event: (ENCOUNTER_END) (1792) (Naraxas) (8) (5) (1)", -- [2840]
			"00:33:09 - ML event (PLAYER_REGEN_ENABLED)", -- [2841]
			"00:34:15 - ML event (PLAYER_REGEN_ENABLED)", -- [2842]
			"00:35:42 - ML event (PLAYER_REGEN_ENABLED)", -- [2843]
			"00:35:55 - Event: (ENCOUNTER_START) (1793) (Dargrul the Underking) (8) (5)", -- [2844]
			"00:35:55 - UpdatePlayersData()", -- [2845]
			"00:38:32 - Event: (ENCOUNTER_END) (1793) (Dargrul the Underking) (8) (5) (1)", -- [2846]
			"00:38:33 - ML event (PLAYER_REGEN_ENABLED)", -- [2847]
			"00:38:36 - Event: (LOOT_OPENED) (1)", -- [2848]
			"00:38:36 - OnLootSlotCleared() (1) (|cffa335ee|Hitem:139105::::::::110:105::16:3:3534:1592:3528:::|h[Rivermane Sandals]|h|r)", -- [2849]
			"00:38:36 - ML event (CHAT_MSG_LOOT) (You receive loot: |cffa335ee|Hitem:139105::::::::110:105::16:3:3534:1592:3528:::|h[Rivermane Sandals]|h|r.) () () () (Avernakis) () (0) (0) () (0) (5679) (nil) (0) (false) (false) (false) (false)", -- [2850]
			"00:38:37 - OnLootSlotCleared() (2) (|cff0070dd|Hitem:147809::::::::110:105::16::::|h[Adept's Spoils]|h|r)", -- [2851]
			"00:38:37 - ML event (CHAT_MSG_LOOT) (You receive loot: |cff0070dd|Hitem:147809::::::::110:105:8388608:16::56:::|h[Adept's Spoils]|h|r.) () () () (Avernakis) () (0) (0) () (0) (5680) (nil) (0) (false) (false) (false) (false)", -- [2852]
			"00:38:37 - OnLootSlotCleared() (3) (|cff0070dd|Hitem:147809::::::::110:105::16::::|h[Adept's Spoils]|h|r)", -- [2853]
			"00:38:37 - ML event (CHAT_MSG_LOOT) (You receive loot: |cff0070dd|Hitem:147809::::::::110:105:8388608:16::56:::|h[Adept's Spoils]|h|r.) () () () (Avernakis) () (0) (0) () (0) (5681) (nil) (0) (false) (false) (false) (false)", -- [2854]
			"00:38:37 - OnLootSlotCleared() (4) (|cff0070dd|Hitem:147809::::::::110:105::16::::|h[Adept's Spoils]|h|r)", -- [2855]
			"00:38:37 - ML event (CHAT_MSG_LOOT) (You receive loot: |cff0070dd|Hitem:147809::::::::110:105:8388608:16::56:::|h[Adept's Spoils]|h|r.) () () () (Avernakis) () (0) (0) () (0) (5682) (nil) (0) (false) (false) (false) (false)", -- [2856]
			"00:38:37 - OnLootSlotCleared() (5) (|cff0070dd|Hitem:147405::::::::110:105::16::::|h[Champion's Symbol]|h|r)", -- [2857]
			"00:38:37 - Event: (LOOT_CLOSED)", -- [2858]
			"00:38:37 - ML event (CHAT_MSG_LOOT) (You receive loot: |cff0070dd|Hitem:147405::::::::110:105:8388608:16::56:::|h[Champion's Symbol]|h|r.) () () () (Avernakis) () (0) (0) () (0) (5683) (nil) (0) (false) (false) (false) (false)", -- [2859]
			"00:38:38 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:139105::::::::110:105::16:3:3534:1592:3528:::|h[Rivermane~`Sandals]|h|r^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [2860]
			"00:38:40 - ML event (CHAT_MSG_LOOT) (Tuyen receives loot: |cffa335ee|Hitem:137342::::::::110:105::16:3:3534:1587:3336:::|h[Rock Solid Legplates]|h|r.) () () () (Tuyen) () (0) (0) () (0) (5685) (nil) (0) (false) (false) (false) (false)", -- [2861]
			"00:38:40 - ML event (CHAT_MSG_LOOT) (Phryke receives loot: |cffa335ee|Hitem:134427::::::::110:105::16:3:3534:1587:3336:::|h[Riverrider Legwraps]|h|r.) () () () (Phryke) () (0) (0) () (0) (5686) (nil) (0) (false) (false) (false) (false)", -- [2862]
			"00:38:41 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:137342::::::::110:66::16:3:3534:1587:3336:::|h[Rock~`Solid~`Legplates]|h|r^t^^ (from:) (Tuyen) (distri:) (PARTY)", -- [2863]
			"00:38:42 - Comm received:^1^Stradable^T^N1^S|cffa335ee|Hitem:134427::::::::110:266::16:3:3534:1587:3336:::|h[Riverrider~`Legwraps]|h|r^t^^ (from:) (Phryke) (distri:) (PARTY)", -- [2864]
			"00:39:11 - ML event (TRADE_SHOW)", -- [2865]
			"00:39:22 - ML event (TRADE_ACCEPT_UPDATE) (1) (0)", -- [2866]
			"00:39:23 - ML event (TRADE_CLOSED)", -- [2867]
			"00:39:23 - ML event (TRADE_CLOSED)", -- [2868]
			"00:39:23 - ML event (UI_INFO_MESSAGE) (226) (Trade complete.)", -- [2869]
			"00:40:35 - UpdateGroup (table: 000001A9CD7A6EF0)", -- [2870]
			"00:40:35 - ML:RemoveCandidate (Phryke-Area52)", -- [2871]
			"00:40:35 - GetCouncilInGroup (Avernakis-Area52) (Galastradra-Area52) (Tuyen-Area52)", -- [2872]
			"00:40:35 - Comm received:^1^Scandidates^T^N1^T^SAvernakis-Area52^T^Srole^SHEALER^SspecID^N105^Senchant_lvl^N0^Sclass^SDRUID^Srank^SBaked~`Potato^t^STuyen-Area52^T^Srole^STANK^SspecID^N66^Senchant_lvl^N0^Sclass^SPALADIN^Srank^STater~`Tot^t^SGalastradra-Area52^T^Srole^SDAMAGER^SspecID^N261^Senchant_lvl^N0^Sclass^SROGUE^Srank^STater~`Tot^t^SAmrehlu-Area52^T^Srole^SDAMAGER^SspecID^N253^Senchant_lvl^N0^Sclass^SHUNTER^Srank^SStewed^t^t^t^^ (from:) (Avernakis) (distri:) (PARTY)", -- [2873]
			"00:45:28 - Event: (PLAYER_ENTERING_WORLD) (false) (false)", -- [2874]
			"00:45:28 - GetML()", -- [2875]
			"00:45:28 - LootMethod =  (personalloot)", -- [2876]
		},
		["version"] = "2.7.4",
		["localizedItemStatus"] = {
			["created"] = "enUS",
			["Warforged"] = "Warforged",
			["Mythic"] = "Mythic",
			["LFR"] = "Raid Finder",
			["Heroic"] = "Heroic",
			["Titanforged"] = "Titanforged",
		},
		["verTestCandidates"] = {
			["Lesmes-Area52"] = "2.7.4-nil: - Avernakis-Area52",
			["Tuyen-Area52"] = "2.7.4-nil: - Avernakis-Area52",
			["Avernakis-Area52"] = "2.7.4-nil: - Avernakis-Area52",
			["Chauric-Area52"] = "2.7.4-nil: - Avernakis-Area52",
			["Velynila-Area52"] = "2.7.4-nil: - Avernakis-Area52",
			["Lithelasha-Area52"] = "2.7.4-nil: - Avernakis-Area52",
			["Ahoyful-Area52"] = "2.7.4-nil: - Avernakis-Area52",
			["Dravash-Area52"] = "2.7.3-nil: - Avernakis-Area52",
			["Phryke-Area52"] = "2.7.4-nil: - Avernakis-Area52",
			["Freakeer-Area52"] = "2.7.4-nil: - Avernakis-Area52",
			["Sulana-Area52"] = "2.7.1-nil: - Avernakis-Area52",
			["Dibbs-Area52"] = "2.7.3-nil: - Avernakis-Area52",
			["Galastradra-Area52"] = "2.7.4-nil: - Avernakis-Area52",
			["Amrehlu-Area52"] = "2.7.4-nil: - Avernakis-Area52",
		},
		["oldVersion"] = "2.7.3",
	},
	["profiles"] = {
		["Default"] = {
			["modules"] = {
				["RCVotingFrame"] = {
					["moreInfo"] = true,
				},
			},
			["anonymousVoting"] = true,
			["tierNumButtons"] = 8,
			["usage"] = {
				["state"] = "ml",
				["ask_leader"] = false,
				["leader"] = true,
				["ml"] = true,
				["ask_ml"] = false,
			},
			["showForML"] = true,
			["numAwardReasons"] = 5,
			["observe"] = true,
			["autoPassBoE"] = false,
			["relicNumButtons"] = 4,
			["UI"] = {
				["lootframe"] = {
					["y"] = 105.844135289715,
					["x"] = -84.9989018223278,
					["point"] = "BOTTOM",
					["scale"] = 1.10000002384186,
				},
				["votingframe"] = {
					["y"] = -54.6387778247226,
					["x"] = -58.6712767399731,
					["point"] = "TOP",
					["scale"] = 1.10000002384186,
				},
				["groupGear"] = {
					["y"] = -29.4668697328325,
					["x"] = 197.111071471974,
					["point"] = "LEFT",
					["scale"] = 1.10000002384186,
				},
				["versionCheck"] = {
					["y"] = 5.203353157412490e-005,
					["x"] = 2.619425504235550e-005,
				},
				["history"] = {
					["y"] = -64.7107873203713,
					["x"] = -95.2892462836462,
					["point"] = "TOP",
					["scale"] = 1.10000002384186,
				},
				["sessionframe"] = {
					["y"] = 9.24471863063263,
					["x"] = 48.7767846709321,
					["scale"] = 1.10000002384186,
				},
			},
			["awardReasons"] = {
				nil, -- [1]
				nil, -- [2]
				{
					["log"] = true,
				}, -- [3]
				{
					["text"] = "Transmog",
				}, -- [4]
				{
					["text"] = "Item Hold",
				}, -- [5]
			},
			["relicButtonsEnabled"] = true,
			["numMoreInfoButtons"] = 10,
			["council"] = {
				"Freakeer-Area52", -- [1]
				"Avernakis-Area52", -- [2]
				"ForsÃ¢kenone-Area52", -- [3]
				"Voidsloth-Area52", -- [4]
				"Tormentoz-Area52", -- [5]
				"Galastradra-Area52", -- [6]
				"Tuyen-Area52", -- [7]
				"Velinadreni-Area52", -- [8]
				"Timedrawnigh-Area52", -- [9]
				"DangÃ©rzone-Area52", -- [10]
				"Kaminote-Area52", -- [11]
				"Afearian-Area52", -- [12]
				"Coveredinwar-Area52", -- [13]
				"Freakyzex-Area52", -- [14]
				"Solidshadowz-Area52", -- [15]
				"Coveredinfel-Area52", -- [16]
				"Coverofdeath-Area52", -- [17]
				"Timeragnarok-Area52", -- [18]
				"Seladri-Area52", -- [19]
				"Budfest-Area52", -- [20]
				"Chomusuke-Area52", -- [21]
				"Elkir-Area52", -- [22]
				"Coverofshade-Area52", -- [23]
				"Coveredinlaw-Area52", -- [24]
			},
			["acceptWhispers"] = false,
			["numButtons"] = 4,
			["minRank"] = 4,
			["relicButtons"] = {
				{
					["text"] = "4+ Trait Level Increase",
				}, -- [1]
				{
					["text"] = "3 or Less Trait Level Increase",
				}, -- [2]
				{
					["text"] = "Same iLvl, Better Trait",
				}, -- [3]
				{
					["text"] = "Offspec",
				}, -- [4]
				{
					["text"] = "Offspec",
				}, -- [5]
			},
			["timeout"] = 200,
			["buttons"] = {
				{
					["text"] = "Major Upgrade (10%+)",
					["whisperKey"] = "major, maj, 1",
				}, -- [1]
				{
					["text"] = "Minor Upgrade (<10%)",
					["whisperKey"] = "minor, min, 2",
				}, -- [2]
				{
					["whisperKey"] = "set1, 3",
					["text"] = "Offspec",
				}, -- [3]
				{
					["text"] = "Transmog",
					["whisperKey"] = "set2, 4",
				}, -- [4]
				{
					["text"] = "3rd Set Piece",
					["whisperKey"] = "set3, 5",
				}, -- [5]
				{
					["whisperKey"] = "set4, 6",
					["text"] = "4th Set Piece+",
				}, -- [6]
				{
					["whisperKey"] = "offspec, 7",
					["text"] = "Offspec",
				}, -- [7]
				{
					["whisperKey"] = "transmog, mog, 8",
					["text"] = "Transmog",
				}, -- [8]
			},
			["announceItems"] = true,
			["tierButtons"] = {
				{
					["text"] = "1st Set Piece",
				}, -- [1]
				{
					["text"] = "2nd Set Piece",
				}, -- [2]
				{
					["text"] = "3rd Set Piece",
				}, -- [3]
				{
					["text"] = "4th Set Piece",
				}, -- [4]
				{
					["text"] = "Major Upgrade (Up to Warforged)",
				}, -- [5]
				{
					["text"] = "Minor Upgrade (Titanforge or Higher to Upgrade)",
				}, -- [6]
				{
					["text"] = "Transmog",
				}, -- [7]
				{
					["text"] = "Offspec",
				}, -- [8]
			},
			["awardText"] = {
				{
					["channel"] = "RAID",
					["text"] = "&s: &p was awarded &i with option &r selected.",
				}, -- [1]
				{
					["channel"] = "GUILD",
					["text"] = "&s: &p was awarded &i while raiding. Reason: &r",
				}, -- [2]
			},
			["responses"] = {
				{
					["text"] = "Major Upgrade (10%+)",
				}, -- [1]
				{
					["text"] = "Minor Upgrade (<10%)",
				}, -- [2]
				{
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
					},
					["text"] = "Offspec",
				}, -- [3]
				{
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
					},
					["text"] = "Transmog",
				}, -- [4]
				{
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
					},
					["text"] = "3rd Set Piece",
				}, -- [5]
				{
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
					},
					["text"] = "4th Set Piece (or more)",
				}, -- [6]
				{
					["color"] = {
						0, -- [1]
						0.541176470588235, -- [2]
						1, -- [3]
					},
					["text"] = "Offspec",
				}, -- [7]
				{
					["color"] = {
						1, -- [1]
						0.941176470588235, -- [2]
						0.368627450980392, -- [3]
					},
					["text"] = "Transmog",
				}, -- [8]
				["relic"] = {
					{
						["color"] = {
							0, -- [1]
							1, -- [2]
							0, -- [3]
						},
						["text"] = "Major Upgrade (4+ Trait Increase)",
					}, -- [1]
					{
						["color"] = {
							1, -- [1]
							0.501960784313726, -- [2]
							0, -- [3]
						},
						["text"] = "Minor Upgrade (3 or Less Trait Increase)",
					}, -- [2]
					{
						["color"] = {
							0.976470588235294, -- [1]
							1, -- [2]
							0.341176470588235, -- [3]
						},
						["text"] = "Minor Upgrade (Better Trait)",
					}, -- [3]
					{
						["color"] = {
							1, -- [1]
							0, -- [2]
							0, -- [3]
						},
						["text"] = "Offspec",
					}, -- [4]
					{
						["color"] = {
							1, -- [1]
							0, -- [2]
							0, -- [3]
						},
						["text"] = "Offspec",
					}, -- [5]
				},
				["tier"] = {
					{
						["text"] = "1st Set Piece",
					}, -- [1]
					{
						["color"] = {
							0, -- [1]
							[3] = 0,
						},
						["text"] = "2nd Set Piece",
					}, -- [2]
					{
						["color"] = {
							0.0941176470588235, -- [1]
							0.694117647058824, -- [2]
						},
						["text"] = "3rd Set Piece",
					}, -- [3]
					{
						["text"] = "4th Set Piece",
					}, -- [4]
					{
						["color"] = {
							0.984313725490196, -- [1]
							1, -- [2]
							0.141176470588235, -- [3]
						},
						["text"] = "Major Upgrade (Warforged)",
					}, -- [5]
					{
						["color"] = {
							1, -- [1]
							0.549019607843137, -- [2]
							0, -- [3]
						},
						["text"] = "Minor Upgrade (Titanforge+)",
					}, -- [6]
					{
						["color"] = {
							0.980392156862745, -- [1]
							0, -- [2]
							1, -- [3]
						},
						["text"] = "XMOG",
					}, -- [7]
					{
						["color"] = {
							1, -- [1]
							0, -- [2]
							0, -- [3]
						},
						["text"] = "Offspec",
					}, -- [8]
				},
				["BONUSROLL"] = {
					["color"] = {
						1, -- [1]
						0.8, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["text"] = "Bonus Rolls",
					["sort"] = 510,
				},
			},
			["announceChannel"] = "RAID",
			["iLvlDecimal"] = true,
			["announceText"] = "Items found inside the carcass of the boss:",
		},
	},
}
RCLootCouncilLootDB = {
	["profileKeys"] = {
		["DangÃ©rzone - Area 52"] = "DangÃ©rzone - Area 52",
		["Tenaral - Area 52"] = "Tenaral - Area 52",
		["Avernakis - Area 52"] = "Avernakis - Area 52",
		["Timedrawnigh - Area 52"] = "Timedrawnigh - Area 52",
		["Velinadreni - Area 52"] = "Velinadreni - Area 52",
	},
	["factionrealm"] = {
		["Horde - Area 52"] = {
			["Avernakis-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "DRUID",
					["groupSize"] = 15,
					["boss"] = "Portal Keeper Hasabel",
					["time"] = "21:51:49",
					["relicRoll"] = false,
					["id"] = "1512201109-8",
					["votes"] = 1,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Minor Upgrade (<10%)",
					["isAwardReason"] = false,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151958::::::::110:105::3:3:3610:1482:3336:::|h[Tarratus Keystone]|h|r",
					["color"] = {
						1, -- [1]
						0.5, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["itemReplaced1"] = "|cffa335ee|Hitem:141482::::::::110:105::43:3:3573:1512:3337:::|h[Unstable Arcanocrystal]|h|r",
					["responseID"] = 2,
					["itemReplaced2"] = "|cffff8000|Hitem:144258::::::::110:105:::2:3459:3630:::|h[Velen's Future Sight]|h|r",
					["note"] = false,
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "DRUID",
					["groupSize"] = 16,
					["boss"] = "The Coven of Shivarra",
					["time"] = "22:41:28",
					["relicRoll"] = false,
					["id"] = "1512290488-13",
					["isAwardReason"] = false,
					["response"] = "Minor Upgrade (<10%)",
					["color"] = {
						1, -- [1]
						0.5, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152289::::::::110:105::3:4:3610:40:1472:3528:::|h[Highfather's Machination]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["itemReplaced1"] = "|cffa335ee|Hitem:141482::::::::110:105::43:3:3573:1512:3337:::|h[Unstable Arcanocrystal]|h|r",
					["responseID"] = 2,
					["itemReplaced2"] = "|cffff8000|Hitem:144258::::::::110:105:::2:3459:3630:::|h[Velen's Future Sight]|h|r",
					["votes"] = 0,
				}, -- [2]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "DRUID",
					["groupSize"] = 13,
					["boss"] = "Garothi Worldbreaker",
					["time"] = "20:42:28",
					["itemReplaced1"] = "|cffa335ee|Hitem:141482::::::::110:105::43:3:3573:1512:3337:::|h[Unstable Arcanocrystal]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Offspec",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r",
					["id"] = "1512801748-0",
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["responseID"] = 3,
					["itemReplaced2"] = "|cffff8000|Hitem:144258::::::::110:105:::2:3459:3630:::|h[Velen's Future Sight]|h|r",
					["isAwardReason"] = false,
				}, -- [3]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "DRUID",
					["groupSize"] = 14,
					["boss"] = "Felhounds of Sargeras",
					["time"] = "21:03:54",
					["relicRoll"] = true,
					["id"] = "1512803034-5",
					["votes"] = 2,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["isAwardReason"] = false,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1492:3337:::|h[Fraternal Fervor]|h|r",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["itemReplaced1"] = "|cffa335ee|Hitem:147106::::::::110:105::43:3:3573:1497:3336:::|h[Glowing Prayer Candle]|h|r",
					["responseID"] = 1,
					["itemReplaced2"] = "|cffa335ee|Hitem:137478::::::::110:105::43:3:3573:1572:3336:::|h[Reflection of Sorrow]|h|r",
					["note"] = "Will have to SIM to be sure",
				}, -- [4]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "DRUID",
					["groupSize"] = 14,
					["votes"] = 0,
					["time"] = "21:47:24",
					["itemReplaced1"] = "|cffa335ee|Hitem:142139::::::::110:105::35:3:3418:1552:3337:::|h[Vest of Wanton Deeds]|h|r",
					["id"] = "1512805644-13",
					["color"] = {
						0.1, -- [1]
						1, -- [2]
						0.5, -- [3]
						1, -- [4]
					},
					["response"] = "1st Set Piece",
					["boss"] = "The Defense of Eonar",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152518::::::::110:105::3::::|h[Chest of the Antoran Vanquisher]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["isAwardReason"] = false,
					["responseID"] = 1,
					["tierToken"] = "ChestSlot",
					["tokenRoll"] = true,
				}, -- [5]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "DRUID",
					["groupSize"] = 14,
					["votes"] = 0,
					["time"] = "22:24:55",
					["itemReplaced1"] = "|cffa335ee|Hitem:137320:5444:::::::110:105::35:3:3418:1592:3337:::|h[Gloves of Vile Defiance]|h|r",
					["id"] = "1512807895-18",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["response"] = "2nd Set Piece",
					["boss"] = "Kin'garoth",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152521::::::::110:105::3::::|h[Gauntlets of the Antoran Vanquisher]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["isAwardReason"] = false,
					["responseID"] = 2,
					["tierToken"] = "HandsSlot",
					["tokenRoll"] = true,
				}, -- [6]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "DRUID",
					["groupSize"] = 14,
					["votes"] = 0,
					["time"] = "22:54:54",
					["itemReplaced1"] = "|cffa335ee|Hitem:138336:5931:::::::110:105::3:3:3514:1512:3337:::|h[Mantle of the Astral Warden]|h|r",
					["id"] = "1512809694-24",
					["color"] = {
						0.0941176470588235, -- [1]
						0.694117647058824, -- [2]
						1, -- [3]
						1, -- [4]
					},
					["response"] = "3rd Set Piece",
					["boss"] = "The Coven of Shivarra",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152530::::::::110:105::3::::|h[Shoulders of the Antoran Vanquisher]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["isAwardReason"] = false,
					["responseID"] = 3,
					["tierToken"] = "ShoulderSlot",
					["tokenRoll"] = true,
				}, -- [7]
			},
			["Chauric-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "MONK",
					["groupSize"] = 15,
					["isAwardReason"] = false,
					["time"] = "22:22:31",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (10%+)",
					["votes"] = 1,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151981::::::::110:105::3:3:3610:1482:3336:::|h[Life-Bearing Footpads]|h|r",
					["boss"] = "The Defense of Eonar",
					["itemReplaced1"] = "|cffa335ee|Hitem:152359::::::::110:268::3:3:3614:1472:3528:::|h[Vile Drifter's Footpads]|h|r",
					["responseID"] = 1,
					["id"] = "1512202951-11",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "MONK",
					["groupSize"] = 16,
					["isAwardReason"] = false,
					["time"] = "23:01:58",
					["relicRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152052::::::::110:105::3:3:3610:1472:3528:::|h[Sporemound Seedling]|h|r",
					["id"] = "1512291718-16",
					["itemReplaced1"] = "|cffa335ee|Hitem:147104::::::::110:268::5:3:3562:1497:3528:::|h[Icon of Perverse Animation]|h|r",
					["responseID"] = 1,
					["boss"] = "Aggramar",
					["votes"] = 1,
				}, -- [2]
				{
					["difficultyID"] = 14,
					["itemReplaced1"] = "|cffa335ee|Hitem:147156:5883:::::::110:105::5:3:3562:1497:3528:::|h[Xuen's Shoulderguards]|h|r",
					["boss"] = "Garothi Worldbreaker",
					["mapID"] = 1712,
					["id"] = "1512801788-2",
					["class"] = "MONK",
					["lootWon"] = "|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r",
					["groupSize"] = 13,
					["isAwardReason"] = false,
					["votes"] = 0,
					["time"] = "20:43:08",
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["response"] = "Offspec",
					["responseID"] = 3,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["date"] = "08/12/17",
				}, -- [3]
			},
			["Galastradra-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "ROGUE",
					["groupSize"] = 15,
					["boss"] = "Felhounds of Sargeras",
					["time"] = "20:57:38",
					["relicRoll"] = false,
					["id"] = "1512197858-2",
					["votes"] = 0,
					["response"] = "Minor Upgrade (<10%)",
					["color"] = {
						1, -- [1]
						0.5, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151968::::::::110:105::3:4:3610:40:1472:3528:::|h[Shadow-Singed Fang]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["itemReplaced1"] = "|cffa335ee|Hitem:121310::::::::110:261::43:4:3573:607:1572:3528:::|h[Nightmare Thorn]|h|r",
					["responseID"] = 2,
					["itemReplaced2"] = "|cffa335ee|Hitem:147015::151585::::::110:261::3:4:3561:1808:1482:3528:::|h[Engine of Eradication]|h|r",
					["isAwardReason"] = false,
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "ROGUE",
					["groupSize"] = 15,
					["isAwardReason"] = false,
					["time"] = "20:52:54",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Heroic",
					["response"] = "Major Upgrade (10%+)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 15,
					["lootWon"] = "|cffa335ee|Hitem:151988::::::::110:105::5:4:3611:40:1492:3336:::|h[Shoulderpads of the Demonic Blitz]|h|r",
					["id"] = "1512283974-2",
					["itemReplaced1"] = "|cffa335ee|Hitem:142144::151585::::::110:261::35:4:3418:1808:1547:3337:::|h[Unending Horizon Spaulders]|h|r",
					["responseID"] = 1,
					["boss"] = "Garothi Worldbreaker",
					["votes"] = 1,
				}, -- [2]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "ROGUE",
					["groupSize"] = 16,
					["isAwardReason"] = false,
					["time"] = "23:53:02",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (10%+)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151982::::::::110:105::3:5:3610:1808:42:1487:3337:::|h[Vest of Waning Life]|h|r",
					["id"] = "1512294782-19",
					["itemReplaced1"] = "|cffa335ee|Hitem:137514::::::::110:261::35:4:3417:43:1582:3337:::|h[Chestguard of Insidious Desire]|h|r",
					["responseID"] = 1,
					["boss"] = "Argus the Unmaker",
					["votes"] = 1,
				}, -- [3]
				{
					["difficultyID"] = 14,
					["itemReplaced1"] = "|cffff8000|Hitem:137021:5435:::::::110:105:::2:3459:3630:::|h[The Dreadlord's Deceit]|h|r",
					["boss"] = "Antoran High Command",
					["mapID"] = 1712,
					["id"] = "1512804269-8",
					["class"] = "ROGUE",
					["lootWon"] = "|cffa335ee|Hitem:151985::::::::110:105::3:3:3610:1472:3528:::|h[General Erodus' Tricorne]|h|r",
					["groupSize"] = 14,
					["isAwardReason"] = false,
					["votes"] = 0,
					["time"] = "21:24:29",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["response"] = "Major Upgrade (10%+)",
					["responseID"] = 1,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["date"] = "08/12/17",
				}, -- [4]
				{
					["difficultyID"] = 14,
					["itemReplaced1"] = "|cffa335ee|Hitem:152360:5445:::::::110:105::3:3:3614:1472:3528:::|h[Gloves of Barbarous Feats]|h|r",
					["boss"] = "Portal Keeper Hasabel",
					["mapID"] = 1712,
					["id"] = "1512804934-10",
					["class"] = "ROGUE",
					["lootWon"] = "|cffa335ee|Hitem:152086::::::::110:105::3:3:3610:1492:3337:::|h[Grips of Hungering Shadows]|h|r",
					["groupSize"] = 14,
					["isAwardReason"] = false,
					["votes"] = 0,
					["time"] = "21:35:34",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["response"] = "Major Upgrade (10%+)",
					["responseID"] = 1,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["date"] = "08/12/17",
				}, -- [5]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "ROGUE",
					["groupSize"] = 14,
					["boss"] = "Kin'garoth",
					["time"] = "22:25:17",
					["itemReplaced1"] = "|cffa335ee|Hitem:142167::151584::::::110:105::16:4:3418:1808:1537:3336:::|h[Eye of Command]|h|r",
					["id"] = "1512807917-19",
					["votes"] = 0,
					["response"] = "Major Upgrade (10%+)",
					["isAwardReason"] = false,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151963::::::::110:105::3:3:3610:1477:3336:::|h[Forgefiend's Fabricator]|h|r",
					["note"] = "Best in Slot for Sub/Outlaw",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["responseID"] = 1,
					["itemReplaced2"] = "|cffa335ee|Hitem:154174::::::::110:105::3:2:3983:3984:::|h[Golganneth's Vitality]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
				}, -- [6]
			},
			["Sulana-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "MONK",
					["groupSize"] = 15,
					["isAwardReason"] = false,
					["time"] = "21:51:20",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Minor Upgrade (<10%)",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151990::::::::110:105::3:3:3610:1477:3336:::|h[Portal Keeper's Cincture]|h|r",
					["boss"] = "Portal Keeper Hasabel",
					["itemReplaced1"] = "|cffff8000|Hitem:138879::::::::110:270:::2:3459:3570:::|h[Ovyd's Winter Wrap]|h|r",
					["responseID"] = 2,
					["id"] = "1512201080-7",
					["color"] = {
						1, -- [1]
						0.5, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "MONK",
					["groupSize"] = 15,
					["isAwardReason"] = false,
					["time"] = "20:39:18",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Minor Upgrade (<10%)",
					["votes"] = 1,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151988::::::::110:105::3:3:3610:1472:3528:::|h[Shoulderpads of the Demonic Blitz]|h|r",
					["boss"] = "Garothi Worldbreaker",
					["itemReplaced1"] = "|cffa335ee|Hitem:142144::151585::::::110:261::35:4:3418:1808:1547:3337:::|h[Unending Horizon Spaulders]|h|r",
					["responseID"] = 2,
					["id"] = "1512196758-0",
					["color"] = {
						1, -- [1]
						0.5, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [2]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "MONK",
					["groupSize"] = 15,
					["boss"] = "Garothi Worldbreaker",
					["time"] = "20:52:06",
					["relicRoll"] = false,
					["id"] = "1512283926-0",
					["isAwardReason"] = false,
					["response"] = "Major Upgrade (10%+)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 15,
					["lootWon"] = "|cffa335ee|Hitem:151956::::::::110:105::5:3:3611:1487:3528:::|h[Garothi Feedback Conduit]|h|r",
					["instance"] = "Antorus, the Burning Throne-Heroic",
					["itemReplaced1"] = "|cffa335ee|Hitem:151607::::::::110:270::13:3:3609:601:3607:::|h[Astral Alchemist Stone]|h|r",
					["responseID"] = 1,
					["itemReplaced2"] = "|cffa335ee|Hitem:142166::151584::::::110:270::43:4:1808:3573:1507:3528:::|h[Ethereal Urn]|h|r",
					["votes"] = 1,
				}, -- [3]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "MONK",
					["groupSize"] = 13,
					["isAwardReason"] = false,
					["time"] = "21:06:45",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Heroic",
					["response"] = "Major Upgrade (10%+)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 15,
					["lootWon"] = "|cffa335ee|Hitem:151980::::::::110:105::5:3:3611:1487:3528:::|h[Harness of Oppressing Dark]|h|r",
					["id"] = "1512284805-3",
					["itemReplaced1"] = "|cffa335ee|Hitem:147151::::::::110:270::5:3:3562:1497:3528:::|h[Xuen's Tunic]|h|r",
					["responseID"] = 1,
					["boss"] = "Felhounds of Sargeras",
					["votes"] = 0,
				}, -- [4]
			},
			["Amrehlu-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "HUNTER",
					["groupSize"] = 15,
					["isAwardReason"] = false,
					["time"] = "22:42:17",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Minor Upgrade (<10%)",
					["votes"] = 1,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151999::::::::110:105::3:3:3610:1472:3528:::|h[Preysnare Vicegrips]|h|r",
					["boss"] = "Imonar the Soulhunter",
					["itemReplaced1"] = "|cffa335ee|Hitem:147141:5446:::::::110:253::5:3:3562:1502:3336:::|h[Wildstalker Gauntlets]|h|r",
					["responseID"] = 2,
					["id"] = "1512204137-13",
					["color"] = {
						1, -- [1]
						0.5, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "HUNTER",
					["groupSize"] = 13,
					["boss"] = "Garothi Worldbreaker",
					["time"] = "20:42:33",
					["itemReplaced1"] = "|cffa335ee|Hitem:154174::::::::110:105::3:2:3983:3984:::|h[Golganneth's Vitality]|h|r",
					["id"] = "1512801753-1",
					["votes"] = 0,
					["response"] = "Offspec",
					["isAwardReason"] = false,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151962::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Personnel Decimator]|h|r",
					["note"] = "Would have to sim it for MM",
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["responseID"] = 3,
					["itemReplaced2"] = "|cffa335ee|Hitem:137459::::::::110:105::43:3:3573:1582:3337:::|h[Chaos Talisman]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
				}, -- [2]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "HUNTER",
					["groupSize"] = 13,
					["votes"] = 0,
					["time"] = "22:08:15",
					["itemReplaced1"] = "|cffa335ee|Hitem:147143::151580::::::110:105::5:5:3562:1808:43:1497:3528:::|h[Wildstalker Leggings]|h|r",
					["id"] = "1512806895-15",
					["color"] = {
						0.1, -- [1]
						1, -- [2]
						0.5, -- [3]
						1, -- [4]
					},
					["response"] = "1st Set Piece",
					["boss"] = "Imonar the Soulhunter",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings of the Antoran Protector]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["isAwardReason"] = false,
					["responseID"] = 1,
					["tierToken"] = "LegsSlot",
					["tokenRoll"] = true,
				}, -- [3]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "HUNTER",
					["groupSize"] = 14,
					["votes"] = 0,
					["time"] = "22:59:37",
					["itemReplaced1"] = "|cffa335ee|Hitem:137321:5929:::::::110:105::35:3:3418:1587:3337:::|h[Burning Sky Pauldrons]|h|r",
					["id"] = "1512809977-26",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["response"] = "2nd Set Piece",
					["boss"] = "The Coven of Shivarra",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["isAwardReason"] = false,
					["responseID"] = 2,
					["tierToken"] = "ShoulderSlot",
					["tokenRoll"] = true,
				}, -- [4]
			},
			["Lesmes-Area52"] = {
				{
					["mapID"] = 1712,
					["itemReplaced1"] = "|cffa335ee|Hitem:146987::::::::110:63::5:3:3562:1512:3337:::|h[Slippers of Enduring Vigilance]|h|r",
					["id"] = "1512199209-4",
					["response"] = "Disenchant",
					["date"] = "01/12/17",
					["class"] = "MAGE",
					["isAwardReason"] = true,
					["groupSize"] = 15,
					["lootWon"] = "|cffa335ee|Hitem:152011::::::::110:105::3:3:3610:1472:3528:::|h[Eredar Warcouncil Sabatons]|h|r",
					["boss"] = "Antoran High Command",
					["time"] = "21:20:09",
					["difficultyID"] = 14,
					["votes"] = 0,
					["responseID"] = "AUTOPASS",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["color"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
						1, -- [4]
					},
				}, -- [1]
				{
					["mapID"] = 1712,
					["itemReplaced1"] = "|cffff8000|Hitem:132406::::::::110:63:::2:3459:3630:::|h[Marquee Bindings of the Sun King]|h|r",
					["id"] = "1512201018-6",
					["response"] = "Disenchant",
					["date"] = "01/12/17",
					["class"] = "MAGE",
					["isAwardReason"] = true,
					["groupSize"] = 15,
					["lootWon"] = "|cffa335ee|Hitem:152008::::::::110:105::3:4:3610:40:1472:3528:::|h[Reality-Splitting Wristguards]|h|r",
					["boss"] = "Portal Keeper Hasabel",
					["time"] = "21:50:18",
					["difficultyID"] = 14,
					["votes"] = 0,
					["responseID"] = "AUTOPASS",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["color"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
						1, -- [4]
					},
				}, -- [2]
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "MAGE",
					["groupSize"] = 15,
					["isAwardReason"] = true,
					["time"] = "22:21:43",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Disenchant",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151952::::::::110:105::3:3:3610:1472:3528:::|h[Cord of Blossoming Petals]|h|r",
					["boss"] = "The Defense of Eonar",
					["itemReplaced1"] = "|cffa335ee|Hitem:134433::::::::110:63::35:3:3418:1587:3337:::|h[Cord of the Sea-Caller]|h|r",
					["responseID"] = "PASS",
					["id"] = "1512202903-10",
					["color"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
						1, -- [4]
					},
				}, -- [3]
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "MAGE",
					["groupSize"] = 15,
					["isAwardReason"] = true,
					["time"] = "22:41:59",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Disenchant",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151939::::::::110:105::3:3:3610:1477:3336:::|h[Whisperstep Runners]|h|r",
					["boss"] = "Imonar the Soulhunter",
					["itemReplaced1"] = "|cffa335ee|Hitem:146987::::::::110:63::5:3:3562:1512:3337:::|h[Slippers of Enduring Vigilance]|h|r",
					["responseID"] = "PASS",
					["id"] = "1512204119-12",
					["color"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
						1, -- [4]
					},
				}, -- [4]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "MAGE",
					["groupSize"] = 15,
					["boss"] = "Varimathras",
					["time"] = "21:50:17",
					["relicRoll"] = true,
					["id"] = "1512287417-8",
					["isAwardReason"] = false,
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152037::::::::110:105::3:3:3610:1472:3528:::|h[Tormentor's Brand]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["itemReplaced1"] = "|cffa335ee|Hitem:142184::::::::110:63::16:3:3418:1537:3336:::|h[Candle of Flickering Lumens]|h|r",
					["responseID"] = 1,
					["itemReplaced2"] = "|cffa335ee|Hitem:147089::::::::110:63::5:3:3562:1497:3528:::|h[Ferocity of the Devout]|h|r",
					["votes"] = 1,
				}, -- [5]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "MAGE",
					["groupSize"] = 15,
					["isAwardReason"] = false,
					["time"] = "21:50:27",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Transmog",
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151942::::::::110:105::3:4:3610:1808:1477:3336:::|h[Cord of Surging Hysteria]|h|r",
					["id"] = "1512287427-9",
					["itemReplaced1"] = "|cffa335ee|Hitem:134433::::::::110:63::35:3:3418:1587:3337:::|h[Cord of the Sea-Caller]|h|r",
					["responseID"] = 4,
					["boss"] = "Varimathras",
					["votes"] = 1,
				}, -- [6]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "MAGE",
					["groupSize"] = 16,
					["isAwardReason"] = false,
					["time"] = "22:41:21",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Transmog",
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151946::::::::110:105::3:3:3610:1472:3528:::|h[Fervent Twilight Legwraps]|h|r",
					["id"] = "1512290481-12",
					["itemReplaced1"] = "|cffa335ee|Hitem:147148::::::::110:63::5:3:3562:1502:3336:::|h[Leggings of the Arcane Tempest]|h|r",
					["responseID"] = 4,
					["boss"] = "The Coven of Shivarra",
					["votes"] = 0,
				}, -- [7]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "MAGE",
					["groupSize"] = 16,
					["boss"] = "Aggramar",
					["time"] = "23:01:55",
					["relicRoll"] = true,
					["id"] = "1512291715-15",
					["isAwardReason"] = false,
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152038::::::::110:105::3:3:3610:1472:3528:::|h[Pyretic Bronze Clasp]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["itemReplaced1"] = "|cffa335ee|Hitem:152037::::::::110:63::3:3:3610:1472:3528:::|h[Tormentor's Brand]|h|r",
					["responseID"] = 1,
					["itemReplaced2"] = "|cffa335ee|Hitem:147089::::::::110:63::5:3:3562:1497:3528:::|h[Ferocity of the Devout]|h|r",
					["votes"] = 1,
				}, -- [8]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "MAGE",
					["groupSize"] = 16,
					["boss"] = "Argus the Unmaker",
					["time"] = "23:52:12",
					["relicRoll"] = true,
					["id"] = "1512294732-17",
					["isAwardReason"] = false,
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:155849::::::::110:105::3:3:3610:1482:3528:::|h[Flickering Ember of Rage]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["itemReplaced1"] = "|cffa335ee|Hitem:152037::::::::110:63::3:3:3610:1472:3528:::|h[Tormentor's Brand]|h|r",
					["responseID"] = 1,
					["itemReplaced2"] = "|cffa335ee|Hitem:147089::::::::110:63::5:3:3562:1497:3528:::|h[Ferocity of the Devout]|h|r",
					["votes"] = 1,
				}, -- [9]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "MAGE",
					["groupSize"] = 14,
					["votes"] = 0,
					["time"] = "21:22:48",
					["itemReplaced1"] = "|cffa335ee|Hitem:152062:5436:::::::110:105::3:3:3610:1477:3336:::|h[Greatcloak of the Dark Pantheon]|h|r",
					["id"] = "1512804168-6",
					["color"] = {
						0.1, -- [1]
						1, -- [2]
						0.5, -- [3]
						1, -- [4]
					},
					["response"] = "1st Set Piece",
					["boss"] = "Antoran High Command",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152517::::::::110:105::3::::|h[Cloak of the Antoran Vanquisher]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["isAwardReason"] = false,
					["responseID"] = 1,
					["tierToken"] = "BackSlot",
					["tokenRoll"] = true,
				}, -- [10]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "MAGE",
					["groupSize"] = 14,
					["isAwardReason"] = false,
					["time"] = "23:17:11",
					["relicRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["votes"] = 1,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1487:3337:::|h[Prototype Titan-Disc]|h|r",
					["boss"] = "Aggramar",
					["itemReplaced1"] = "|cffa335ee|Hitem:140810::::::::110:105::43:3:3573:1512:3336:::|h[Farsight Spiritjewel]|h|r",
					["responseID"] = 1,
					["id"] = "1512811031-28",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [11]
			},
			["Tuyen-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "PALADIN",
					["groupSize"] = 13,
					["boss"] = "Felhounds of Sargeras",
					["time"] = "21:07:06",
					["relicRoll"] = false,
					["id"] = "1512284826-5",
					["isAwardReason"] = false,
					["response"] = "Major Upgrade (10%+)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 15,
					["lootWon"] = "|cffa335ee|Hitem:151974::::::::110:105::5:4:3611:3618:1487:3528:::|h[Eye of Shatug]|h|r",
					["instance"] = "Antorus, the Burning Throne-Heroic",
					["itemReplaced1"] = "|cffa335ee|Hitem:128711::::::::110:66::13:3:689:601:679:::|h[Darkmoon Deck: Immortality]|h|r",
					["responseID"] = 1,
					["itemReplaced2"] = "|cffa335ee|Hitem:147024::::::::110:66::5:3:3562:1507:3336:::|h[Reliquary of the Damned]|h|r",
					["votes"] = 0,
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "PALADIN",
					["groupSize"] = 15,
					["votes"] = 0,
					["time"] = "21:30:44",
					["relicRoll"] = false,
					["id"] = "1512286244-6",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["tokenRoll"] = true,
					["response"] = "2nd Set Piece",
					["tierToken"] = "HandsSlot",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152522::::::::110:105::3::::|h[Gauntlets of the Antoran Conqueror]|h|r",
					["itemReplaced1"] = "|cffa335ee|Hitem:134508:5444:::::::110:66::35:3:3418:1587:3337:::|h[Stormwake Handguards]|h|r",
					["isAwardReason"] = false,
					["responseID"] = 2,
					["boss"] = "Kin'garoth",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [2]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "PALADIN",
					["groupSize"] = 16,
					["votes"] = 1,
					["time"] = "23:01:51",
					["relicRoll"] = false,
					["id"] = "1512291711-14",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["tokenRoll"] = true,
					["response"] = "3rd Set Piece",
					["tierToken"] = "HeadSlot",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152525::::::::110:105::3::::|h[Helm of the Antoran Conqueror]|h|r",
					["itemReplaced1"] = "|cffa335ee|Hitem:147160::151583::::::110:66::5:4:3562:1808:1502:3336:::|h[Radiant Lightbringer Crown]|h|r",
					["isAwardReason"] = false,
					["responseID"] = 3,
					["boss"] = "Aggramar",
					["color"] = {
						0.0941176470588235, -- [1]
						0.694117647058824, -- [2]
						1, -- [3]
						1, -- [4]
					},
				}, -- [3]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "PALADIN",
					["groupSize"] = 14,
					["isAwardReason"] = false,
					["time"] = "21:35:00",
					["relicRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Minor Upgrade (Better Trait)",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152049::::::::110:105::3:3:3610:1472:3528:::|h[Fel-Engraved Handbell]|h|r",
					["boss"] = "Portal Keeper Hasabel",
					["itemReplaced1"] = "|cffa335ee|Hitem:152292::::::::110:105::3:3:3614:1472:3528:::|h[Spike of Immortal Command]|h|r",
					["responseID"] = 3,
					["id"] = "1512804900-9",
					["color"] = {
						0.976470588235294, -- [1]
						1, -- [2]
						0.341176470588235, -- [3]
						1, -- [4]
					},
				}, -- [4]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "PALADIN",
					["groupSize"] = 14,
					["isAwardReason"] = false,
					["time"] = "22:55:13",
					["relicRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Minor Upgrade (3 or Less Trait Increase)",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152046::::::::110:105::3:3:3610:1472:3528:::|h[Coven Prayer Bead]|h|r",
					["boss"] = "The Coven of Shivarra",
					["itemReplaced1"] = "|cffa335ee|Hitem:136771::::::::110:105::43:3:3573:1577:3337:::|h[Eyir's Blessing]|h|r",
					["responseID"] = 2,
					["id"] = "1512809713-25",
					["color"] = {
						1, -- [1]
						0.501960784313726, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [5]
			},
			["Ahoyahoy-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "HUNTER",
					["groupSize"] = 15,
					["isAwardReason"] = false,
					["time"] = "21:51:09",
					["relicRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152025::::::::110:105::3:3:3610:1472:3528:::|h[Thu'rayan Lash]|h|r",
					["id"] = "1512287469-10",
					["itemReplaced1"] = "|cffa335ee|Hitem:147079::::::::110:253::43:3:3573:1492:3528:::|h[Torn Fabric of Reality]|h|r",
					["responseID"] = 1,
					["boss"] = "Varimathras",
					["votes"] = 1,
				}, -- [1]
			},
			["Velynila-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "DEMONHUNTER",
					["groupSize"] = 15,
					["boss"] = "Garothi Worldbreaker",
					["time"] = "20:52:32",
					["relicRoll"] = true,
					["id"] = "1512283952-1",
					["isAwardReason"] = false,
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 15,
					["lootWon"] = "|cffa335ee|Hitem:152031::::::::110:105::5:3:3611:1487:3528:::|h[Doomfire Dynamo]|h|r",
					["instance"] = "Antorus, the Burning Throne-Heroic",
					["itemReplaced1"] = "|cffa335ee|Hitem:147086::::::::110:577::5:3:3562:1497:3528:::|h[Befouled Effigy of Elune]|h|r",
					["responseID"] = 1,
					["itemReplaced2"] = "|cffa335ee|Hitem:152345::::::::110:577::3:3:3614:1472:3528:::|h[Vilemus' Bile]|h|r",
					["votes"] = 1,
				}, -- [1]
				{
					["difficultyID"] = 14,
					["itemReplaced1"] = "|cffa335ee|Hitem:147127::::::::110:105::3:3:3561:1487:3336:::|h[Demonbane Harness]|h|r",
					["boss"] = "Felhounds of Sargeras",
					["mapID"] = 1712,
					["id"] = "1512802822-3",
					["class"] = "DEMONHUNTER",
					["lootWon"] = "|cffa335ee|Hitem:151980::::::::110:105::3:3:3610:1482:3336:::|h[Harness of Oppressing Dark]|h|r",
					["groupSize"] = 14,
					["isAwardReason"] = false,
					["votes"] = 0,
					["time"] = "21:00:22",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["response"] = "Major Upgrade (10%+)",
					["responseID"] = 1,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["date"] = "08/12/17",
				}, -- [2]
				{
					["isAwardReason"] = false,
					["relicRoll"] = true,
					["lootWon"] = "|cffa335ee|Hitem:152026::::::::110:105::3:3:3610:1472:3528:::|h[Prototype Titan-Disc]|h|r",
					["mapID"] = 1712,
					["id"] = "1512811063-29",
					["class"] = "DEMONHUNTER",
					["votes"] = 0,
					["groupSize"] = 14,
					["difficultyID"] = 14,
					["boss"] = "Aggramar",
					["time"] = "23:17:43",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Offspec",
					["responseID"] = 4,
					["date"] = "08/12/17",
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [3]
			},
			["Lithelasha-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "DEMONHUNTER",
					["groupSize"] = 15,
					["votes"] = 1,
					["time"] = "22:21:18",
					["relicRoll"] = false,
					["id"] = "1512202878-9",
					["color"] = {
						0.1, -- [1]
						1, -- [2]
						0.5, -- [3]
						1, -- [4]
					},
					["boss"] = "The Defense of Eonar",
					["response"] = "1st Set Piece",
					["tierToken"] = "ChestSlot",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152519::::::::110:105::3::::|h[Chest of the Antoran Conqueror]|h|r",
					["isAwardReason"] = false,
					["itemReplaced1"] = "|cffa335ee|Hitem:147127::::::::110:577::5:3:3562:1502:3336:::|h[Demonbane Harness]|h|r",
					["responseID"] = 1,
					["tokenRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "DEMONHUNTER",
					["groupSize"] = 15,
					["boss"] = "Kin'garoth",
					["time"] = "21:31:32",
					["relicRoll"] = false,
					["id"] = "1512286292-7",
					["note"] = "BiS once i get my 4 pc",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (10%+)",
					["isAwardReason"] = false,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152064::::::::110:105::3:3:3610:1477:3336:::|h[Band of the Sargerite Smith]|h|r",
					["itemReplaced1"] = "|cffa335ee|Hitem:134525:5427:::::::110:577::35:3:3418:1592:3337:::|h[Seal of the Nazjatar Empire]|h|r",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["responseID"] = 1,
					["itemReplaced2"] = "|cffff8000|Hitem:137038:5427:130247::::::110:577:::3:3529:3459:3570:::|h[Anger of the Half-Giants]|h|r",
					["votes"] = 0,
				}, -- [2]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "DEMONHUNTER",
					["groupSize"] = 14,
					["votes"] = 1,
					["time"] = "22:09:10",
					["itemReplaced1"] = "|cffa335ee|Hitem:147131::::::::110:105::5:3:3562:1527:3337:::|h[Demonbane Leggings]|h|r",
					["id"] = "1512806950-17",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["response"] = "2nd Set Piece",
					["boss"] = "Imonar the Soulhunter",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152528::::::::110:105::3::::|h[Leggings of the Antoran Conqueror]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["isAwardReason"] = false,
					["responseID"] = 2,
					["tierToken"] = "LegsSlot",
					["tokenRoll"] = true,
				}, -- [3]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "DEMONHUNTER",
					["groupSize"] = 14,
					["boss"] = "Varimathras",
					["time"] = "22:40:40",
					["itemReplaced1"] = "|cffa335ee|Hitem:151190::::::::110:105::5:3:3562:1512:3336:::|h[Specter of Betrayal]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (10%+)",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151964::::::::110:105::3:3:3610:1482:3336:::|h[Seeping Scourgewing]|h|r",
					["id"] = "1512808840-22",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["responseID"] = 1,
					["itemReplaced2"] = "|cffa335ee|Hitem:154174::::::::110:105::3:2:3983:3985:::|h[Golganneth's Vitality]|h|r",
					["isAwardReason"] = false,
				}, -- [4]
			},
			["Phryke-Area52"] = {
				{
					["isAwardReason"] = false,
					["relicRoll"] = true,
					["lootWon"] = "|cffa335ee|Hitem:152035::::::::110:105::3:3:3610:1482:3336:::|h[Blazing Dreadsteed Horseshoe]|h|r",
					["mapID"] = 1712,
					["id"] = "1512805040-11",
					["class"] = "WARLOCK",
					["votes"] = 0,
					["groupSize"] = 14,
					["difficultyID"] = 14,
					["boss"] = "Portal Keeper Hasabel",
					["time"] = "21:37:20",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["responseID"] = 1,
					["date"] = "08/12/17",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "WARLOCK",
					["groupSize"] = 14,
					["boss"] = "Kin'garoth",
					["time"] = "22:26:02",
					["itemReplaced1"] = "|cffa335ee|Hitem:142165::151584::::::110:105::35:4:3417:1808:1542:3337:::|h[Deteriorated Construct Core]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (10%+)",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151955::::::::110:105::3:4:3610:1808:1472:3528:::|h[Acrid Catalyst Injector]|h|r",
					["id"] = "1512807962-20",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["responseID"] = 1,
					["itemReplaced2"] = "|cffa335ee|Hitem:147017::::::::110:105::3:3:3561:1482:3528:::|h[Tarnished Sentinel Medallion]|h|r",
					["isAwardReason"] = false,
				}, -- [2]
			},
			["Freakeer-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "SHAMAN",
					["groupSize"] = 14,
					["votes"] = 0,
					["time"] = "21:22:54",
					["itemReplaced1"] = "|cffa335ee|Hitem:152366::::::::110:105::3:4:3614:40:1472:3528:::|h[Enthralling Chain Armor]|h|r",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Minor Upgrade (<10%)",
					["boss"] = "Antoran High Command",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:151994::::::::110:105::3:4:3610:1808:1472:3528:::|h[Fleet Commander's Hauberk]|h|r",
					["isAwardReason"] = false,
					["color"] = {
						1, -- [1]
						0.5, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["responseID"] = 2,
					["note"] = "2%",
					["id"] = "1512804174-7",
				}, -- [1]
			},
			["ForsÃ¢kenone-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "WARRIOR",
					["groupSize"] = 15,
					["votes"] = 1,
					["time"] = "21:21:29",
					["relicRoll"] = false,
					["id"] = "1512199289-5",
					["color"] = {
						0.1, -- [1]
						1, -- [2]
						0.5, -- [3]
						1, -- [4]
					},
					["boss"] = "Antoran High Command",
					["response"] = "1st Set Piece",
					["tierToken"] = "BackSlot",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152515::::::::110:105::3::::|h[Cloak of the Antoran Protector]|h|r",
					["isAwardReason"] = false,
					["itemReplaced1"] = "|cffa335ee|Hitem:134406::::::::110:71::35:3:3418:1602:3337:::|h[Mainsail Cloak]|h|r",
					["responseID"] = 1,
					["tokenRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "WARRIOR",
					["groupSize"] = 15,
					["votes"] = 1,
					["time"] = "22:43:12",
					["relicRoll"] = false,
					["id"] = "1512204192-14",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["boss"] = "Imonar the Soulhunter",
					["response"] = "2nd Set Piece",
					["tierToken"] = "LegsSlot",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152529::::::::110:105::3::::|h[Leggings of the Antoran Protector]|h|r",
					["isAwardReason"] = false,
					["itemReplaced1"] = "|cffa335ee|Hitem:147191::::::::110:71::5:3:3562:1497:3528:::|h[Titanic Onslaught Greaves]|h|r",
					["responseID"] = 2,
					["tokenRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
				}, -- [2]
			},
			["Ahoyful-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "PALADIN",
					["groupSize"] = 14,
					["isAwardReason"] = false,
					["time"] = "21:01:59",
					["relicRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152291::::::::110:105::3:3:3610:1472:3528:::|h[Fraternal Fervor]|h|r",
					["boss"] = "Felhounds of Sargeras",
					["itemReplaced1"] = "|cffa335ee|Hitem:152051::::::::110:105::3:3:3610:1472:3528:::|h[Eidolon of Life]|h|r",
					["responseID"] = 1,
					["id"] = "1512802919-4",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [1]
				{
					["difficultyID"] = 14,
					["itemReplaced1"] = "|cffa335ee|Hitem:136977:5433:::::::110:105::43:3:3573:1567:3336:::|h[Shadowfeather Shawl]|h|r",
					["boss"] = "Imonar the Soulhunter",
					["mapID"] = 1712,
					["id"] = "1512806917-16",
					["class"] = "PALADIN",
					["lootWon"] = "|cffa335ee|Hitem:151938::::::::110:105::3:3:3610:1472:3528:::|h[Drape of the Spirited Hunt]|h|r",
					["groupSize"] = 13,
					["isAwardReason"] = false,
					["votes"] = 1,
					["time"] = "22:08:37",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["response"] = "Major Upgrade (10%+)",
					["responseID"] = 1,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["date"] = "08/12/17",
				}, -- [2]
				{
					["difficultyID"] = 14,
					["itemReplaced1"] = "|cffa335ee|Hitem:152752::::::::110:105:::4:1691:3629:1477:3336:::|h[Praetorium Guard's Vambraces of the Fireflash]|h|r",
					["boss"] = "Varimathras",
					["mapID"] = 1712,
					["id"] = "1512808821-21",
					["class"] = "PALADIN",
					["lootWon"] = "|cffa335ee|Hitem:152281::::::::110:105::3:3:3610:1477:3336:::|h[Varimathras' Shattered Manacles]|h|r",
					["groupSize"] = 14,
					["isAwardReason"] = false,
					["votes"] = 0,
					["time"] = "22:40:21",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["response"] = "Major Upgrade (10%+)",
					["responseID"] = 1,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["date"] = "08/12/17",
				}, -- [3]
			},
			["Dravash-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "DEATHKNIGHT",
					["groupSize"] = 16,
					["isAwardReason"] = false,
					["time"] = "23:52:21",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (10%+)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152016::::::::110:105::3:4:3610:1808:1472:3528:::|h[Cosmos-Culling Legplates]|h|r",
					["id"] = "1512294741-18",
					["itemReplaced1"] = "|cffa335ee|Hitem:147066::::::::110:251::3:3:3561:1512:3337:::|h[Greaves of Impure Midnight]|h|r",
					["responseID"] = 1,
					["boss"] = "Argus the Unmaker",
					["votes"] = 1,
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "DEATHKNIGHT",
					["groupSize"] = 14,
					["isAwardReason"] = false,
					["time"] = "21:47:59",
					["relicRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152054::::::::110:105::3:3:3610:1477:3336:::|h[Unwavering Soul Essence]|h|r",
					["boss"] = "The Defense of Eonar",
					["itemReplaced1"] = "|cffa335ee|Hitem:151013::::::::110:105::29:3:3396:3194:3337:::|h[Ethereal Anchor]|h|r",
					["responseID"] = 1,
					["id"] = "1512805679-14",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [2]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "DEATHKNIGHT",
					["groupSize"] = 14,
					["isAwardReason"] = false,
					["time"] = "22:40:44",
					["relicRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (4+ Trait Increase)",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152092::::::::110:105::3:3:3610:1472:3528:::|h[Nathrezim Incisor]|h|r",
					["boss"] = "Varimathras",
					["itemReplaced1"] = "|cffa335ee|Hitem:151296::::::::110:105::43:3:3573:1572:3336:::|h[Blood of the Vanquished]|h|r",
					["responseID"] = 1,
					["id"] = "1512808844-23",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [3]
			},
			["PuÃ±eslayer-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "DEATHKNIGHT",
					["groupSize"] = 15,
					["isAwardReason"] = false,
					["time"] = "20:39:33",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Offspec",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152009::::::::110:105::3:4:3610:42:1472:3528:::|h[Doomwalker Warboots]|h|r",
					["boss"] = "Garothi Worldbreaker",
					["itemReplaced1"] = "|cffa335ee|Hitem:149532::::::::110:251::43:4:3573:1716:1572:3528:::|h[Fierce Combatant's Dreadplate Sabatons]|h|r",
					["responseID"] = 3,
					["id"] = "1512196773-1",
					["color"] = {
						1, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "01/12/17",
					["class"] = "DEATHKNIGHT",
					["groupSize"] = 15,
					["isAwardReason"] = false,
					["time"] = "20:59:12",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Normal",
					["response"] = "Major Upgrade (10%+)",
					["votes"] = 0,
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152021::::::::110:105::3:3:3610:1477:3336:::|h[Flamelicked Girdle]|h|r",
					["boss"] = "Felhounds of Sargeras",
					["itemReplaced1"] = "|cffa335ee|Hitem:150959::::::::110:251::43:3:3573:1572:3528:::|h[Garothi Waistplate]|h|r",
					["responseID"] = 1,
					["id"] = "1512197952-3",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [2]
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "DEATHKNIGHT",
					["groupSize"] = 13,
					["isAwardReason"] = false,
					["time"] = "21:06:49",
					["relicRoll"] = false,
					["instance"] = "Antorus, the Burning Throne-Heroic",
					["response"] = "Major Upgrade (10%+)",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["difficultyID"] = 15,
					["lootWon"] = "|cffa335ee|Hitem:152012::::::::110:105::5:3:3611:1487:3528:::|h[Molten Bite Handguards]|h|r",
					["id"] = "1512284809-4",
					["itemReplaced1"] = "|cffa335ee|Hitem:147061::::::::110:251::5:3:3562:1497:3528:::|h[Dusk-Crusher Handguards]|h|r",
					["responseID"] = 1,
					["boss"] = "Felhounds of Sargeras",
					["votes"] = 0,
				}, -- [3]
			},
			["Dibbs-Area52"] = {
				{
					["mapID"] = 1712,
					["date"] = "02/12/17",
					["class"] = "SHAMAN",
					["groupSize"] = 16,
					["votes"] = 1,
					["time"] = "22:41:11",
					["relicRoll"] = false,
					["id"] = "1512290471-11",
					["instance"] = "Antorus, the Burning Throne-Normal",
					["tokenRoll"] = true,
					["response"] = "2nd Set Piece",
					["tierToken"] = "ShoulderSlot",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152532::::::::110:105::3::::|h[Shoulders of the Antoran Protector]|h|r",
					["itemReplaced1"] = "|cffa335ee|Hitem:147180:5442:::::::110:262::5:3:3562:1497:3528:::|h[Pauldrons of the Skybreaker]|h|r",
					["isAwardReason"] = false,
					["responseID"] = 2,
					["boss"] = "The Coven of Shivarra",
					["color"] = {
						0, -- [1]
						1, -- [2]
						0, -- [3]
						1, -- [4]
					},
				}, -- [1]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "SHAMAN",
					["groupSize"] = 14,
					["votes"] = 0,
					["time"] = "21:47:01",
					["relicRoll"] = false,
					["id"] = "1512805621-12",
					["color"] = {
						0.0941176470588235, -- [1]
						0.694117647058824, -- [2]
						1, -- [3]
						1, -- [4]
					},
					["boss"] = "The Defense of Eonar",
					["response"] = "3rd Set Piece",
					["tierToken"] = "ChestSlot",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152520::::::::110:105::3::::|h[Chest of the Antoran Protector]|h|r",
					["isAwardReason"] = false,
					["itemReplaced1"] = "|cffa335ee|Hitem:147175::151583::::::110:105::5:4:3562:1808:1497:3528:::|h[Harness of the Skybreaker]|h|r",
					["responseID"] = 3,
					["tokenRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
				}, -- [2]
				{
					["mapID"] = 1712,
					["date"] = "08/12/17",
					["class"] = "SHAMAN",
					["groupSize"] = 14,
					["votes"] = 1,
					["time"] = "23:16:08",
					["relicRoll"] = false,
					["id"] = "1512810968-27",
					["color"] = {
						0.5, -- [1]
						1, -- [2]
						1, -- [3]
						1, -- [4]
					},
					["boss"] = "Aggramar",
					["response"] = "4th Set Piece",
					["tierToken"] = "HeadSlot",
					["difficultyID"] = 14,
					["lootWon"] = "|cffa335ee|Hitem:152526::::::::110:105::3::::|h[Helm of the Antoran Protector]|h|r",
					["isAwardReason"] = false,
					["itemReplaced1"] = "|cffa335ee|Hitem:147178::::::::110:105::3:3:3561:1502:3337:::|h[Helmet of the Skybreaker]|h|r",
					["responseID"] = 4,
					["tokenRoll"] = true,
					["instance"] = "Antorus, the Burning Throne-Normal",
				}, -- [3]
			},
		},
	},
}
