local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

-- Default responses
addon.responses = {
   default = {
      AWARDED        = { color = {1,1,1,1},				sort = 0.1,		text = L["Awarded"],},
      PL					= { color = {1, 0.6,0,1},			sort = 498,		text = L["Personal Loot - Non tradeable"]},
      PL_REJECT		= { color = {0.2,0,0,1},			sort = 499,		text = L["Personal Loot - Rejected Trade"]},
      NOTANNOUNCED	= { color = {1,0,1,1},				sort = 501,		text = L["Not announced"],},
      ANNOUNCED		= { color = {1,0,1,1},				sort = 502,		text = L["Loot announced, waiting for answer"], },
      WAIT				= { color = {1,1,0,1},				sort = 503,		text = L["Candidate is selecting response, please wait"], },
      TIMEOUT			= { color = {1,0,0,1},				sort = 504,		text = L["Candidate didn't respond on time"], },
      REMOVED			= { color = {0.8,0.5,0,1},			sort = 505,		text = L["Candidate removed"], },
      NOTHING			= { color = {0.5,0.5,0.5,1},		sort = 505,		text = L["Offline or RCLootCouncil not installed"], },
      BONUSROLL      = { color = {1,0.8,0,1},	      sort = 510,		text = _G.BONUS_ROLL_TOOLTIP_TITLE},
      PASS				= { color = {0.7, 0.7,0.7,1},		sort = 800,		text = _G.PASS,},
      AUTOPASS			= { color = {0.7,0.7,0.7,1},		sort = 801,		text = L["Autopass"], },
      DISABLED			= { color = {0.3,0.35,0.5,1},		sort = 802,		text = L["Candidate has disabled RCLootCouncil"], },
      NOTINRAID		= { color = {0.7,0.6,0,1}, 		sort = 803, 	text = L["Candidate is not in the instance"]},
      DEFAULT			= { color = {1,0,0,1},				sort = 899, 	text = L["Response isn't available. Please upgrade RCLootCouncil."]},
      --[[1]]			  { color = {0,1,0,1},				sort = 1,		text = L["Mainspec/Need"],},
      --[[2]]			  { color = {1,0.5,0,1},			sort = 2,		text = L["Offspec/Greed"],	},
      --[[3]]			  { color = {0,0.7,0.7,1},			sort = 3,		text = L["Minor Upgrade"],},
   },
   ['*'] = {
      ['*'] = {
         text = L["Response"],
         color = {1,1,1,1},
      },
   },
}

-- Option table defaults
addon.defaults = {
   global = {
      logMaxEntries = 2000,
      log = {}, -- debug log
      verTestCandidates = {}, -- Stores received verTests
      errors = {},
      cache = {},
   },
   profile = {
      skipCombatLockdown = false,

      baggedItems = {}, -- Items that are stored in MLs inventory for award later.
                     -- i = { {link=link, winner=winner, addedTime=sec between UTC epoch to when the item is added to lootInBags, }, bop=Item is BOP?}
      itemStorage = {}, -- See ItemStorage.lua

      usage = { -- State of enabledness
         --ml = false,				-- Enable when ML
         --ask_ml = true,			-- Ask before enabling when ML
         never = false,			-- Never enable
         pl = false,				-- Always enable with PL
         ask_pl = true,			-- Ask before enabling when PL
         state = "ask_pl", 	-- Current state
      },
      onlyUseInRaids = true,
      ambiguate = false, -- Append realm names to players
      autoAddRolls = false,
      autoStart = false, -- start a session with all eligible items
      autoLoot = true, -- Auto loot equippable items
      autolootBoE = true,
      autoOpen = true, -- auto open the voting frame
      autoClose = false, -- Auto close voting frame on session end
      autoPassBoE = true,
      autoPass = true,
      autoPassTrinket = true,
      acceptWhispers = true,
      selfVote = true,
      multiVote = true,
      anonymousVoting = false,
      showForML = false,
      hideVotes = false, -- Hide the # votes until one have voted
      autoAward = false,
      autoAwardLowerThreshold = 2,
      autoAwardUpperThreshold = 3,
      autoAwardTo = {},
      autoAwardReason = 1,
      autoAwardBoE = false,
      autoAwardBoETo = {},
      autoAwardBoEReason = 2,
      observe = false, -- observe mode on/off
      silentAutoPass = false, -- Show autopass message
      printResponse = false, -- Print response in chat
      printCompletedTrades = true, -- Print whenever raiders trade their item to the winner
      --neverML = false, -- Never use the addon as ML
      minimizeInCombat = false,
      iLvlDecimal = false,
      showSpecIcon = false,
      sortItems = true, -- Sort sessions by item type and item level
      rejectTrade = false, -- Can candidates choose not to give loot to the council
      autoTrade = false,
      awardLater = false, -- Auto check award later
      requireNotes = false,
      outOfRaid = false,

      chatFrameName = "DEFAULT_CHAT_FRAME", -- The chat frame to use for :Print()s

      UI = { -- stores all ui information
         ['**'] = { -- Defaults
            y		= 0,
            x		= 0,
            point	= "CENTER",
            scale	= 1.1,--0.8,
            bgColor = {0, 0, 0.2, 1},
            borderColor = {0.3, 0.3, 0.5, 1},
            border = "Blizzard Tooltip",
            background = "Blizzard Tooltip",
         },
         lootframe = { -- We want the Loot Frame to get a little lower
            y = -200,
         },
         tradeui = {
            x = -300,
         },
         default = {}, -- base line
      },

      skins = {
         new_blue = {
            name = "Midnight blue",
            bgColor = {0, 0, 0.2, 1}, -- Blue-ish
            borderColor = {0.3, 0.3, 0.5, 1}, -- More Blue-ish
            border = "Blizzard Tooltip",
            background = "Blizzard Tooltip",
         },
         old_red = {
            name = "Old golden red",
            bgColor = {0.5, 0, 0 ,1},
            borderColor = {1, 0.5, 0, 1},
            border = "Blizzard Tooltip",
            background = "Blizzard Dialog Background Gold",
         },
         minimalGrey = {
            name = "Minimal Grey",
            bgColor = {0.25, 0.25, 0.25, 1},
            borderColor = {1, 1, 1, 0.2},
            border = "Blizzard Tooltip",
            background = "Blizzard Tooltip",
         },
         legion = {
            name = "Legion Green",
            bgColor = {0.1, 1, 0, 1},
            borderColor = {0, 0.8, 0, 0.75},
            background = "Blizzard Garrison Background 2",
            border = "Blizzard Dialog Gold",
         },
         bfa = {
            name = "Battle for Azeroth",
            bgColor = {0.55, 0.84, 1, 1},
            borderColor = {0.62, 0.86, 0.87, 0.85},
            border = "Blizzard Dialog",
            background = "Blizzard Garrison Background 3",
         },
      },
      currentSkin = "bfa",

      modules = { -- For storing module specific data
         ['*'] = {
            filters = { -- Default filtering is showed
               ['*'] = true,
               ranks = {
                  ['*'] = true
               },
               class = {
                  ['*'] = false
               }
            },
            alwaysShowTooltip = false,
         },
      },

      announceAward = true,
      awardText = { -- Just max it at 2 channels
         { channel = "group",	text = L["&p was awarded with &i for &r!"],},
         { channel = "NONE",	text = "",},
      },
      announceItems = false,
      announceText = L["Items under consideration:"],
      announceChannel = "group",
      announceItemString = "&s: &i", -- The message posted for each item, default: "session: itemlink"

      responses = addon.responses,

      enableHistory = true,
      sendHistory = true,
      sendHistoryToGuildChannel = false,

      minRank = -1,
      council = {},

      maxButtons = 10,
      buttons = {
         default = {
            {	text = _G.NEED,					whisperKey = L["whisperKey_need"], },	-- 1
            {	text = _G.GREED,					whisperKey = L["whisperKey_greed"],},	-- 2
            {	text = L["Minor Upgrade"],		whisperKey = L["whisperKey_minor"],},	-- 3
            numButtons = 3,
         },
         ['*'] = {
            ['*'] = {
               text = L["Button"],
            },
            numButtons = 3,
         },
      },
      enabledButtons = { -- By default all extra buttons are disabled
         ["*"] = false,
      },
      numMoreInfoButtons = 1,
      maxAwardReasons = 10,
      numAwardReasons = 3,
      awardReasons = {
         { color = {1, 1, 1, 1}, disenchant = true, log = true,	sort = 401,	text = _G.ROLL_DISENCHANT, },
         { color = {1, 1, 1, 1}, disenchant = false, log = true,	sort = 402,	text = L["Banking"], },
         { color = {1, 1, 1, 1}, disenchant = false, log = false, sort = 403,	text = L["Free"],},
      },
      disenchant = true, -- Disenchant enabled, i.e. there's a true in awardReasons.disenchant

      timeout = 60,

      -- List of items to ignore:
      ignoredItems = {
         [109693] = true, [115502] = true, [111245] = true, [115504] = true, [113588] = true, -- WoD enchant mats
         [124441] = true, [124442] = true, -- Chaos Crystal (Legion), Leylight Shard (Legion)
         [141303] = true, [141304] = true, [141305] = true, -- Essence of Clarity (Emerald Nightmare quest item)
         [143656] = true, [143657] = true, [143658] = true, -- Echo of Time (Nighthold quest item)
         [132204] = true, [151248] = true, [151249] = true, [151250] = true, -- Sticky Volatile Essence, Fragment of the Guardian's Seal (Tomb of Sargeras)
         [152902] = true, [152906] = true, [152907] = true, [155831] = true, -- Rune of Passage (Antorus shortcut item), Pantheon's Blessing
         [152908] = true, [152909] = true, [152910] = true, -- Sigil of the Dark Titan (Another Antorus shortcut item)
         [162461] = true, -- Sanguicell (BfA crafting)
      },
   },
} -- defaults end

-- addon.db = setmetatable({}, {__index = addon.defaults})
