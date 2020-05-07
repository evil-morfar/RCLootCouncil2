# v2.19.0-Beta.1
## Changes

### Award Later
When `Award Later` and `Auto Start` both are enabled, all items are automatically awarded to the Master Looter/Group Leader for award later.

I generally don't recommend enabling `Auto Start` as you will have no control over what happens before setting the addon free to do its thing.
This is especially dangerous with `Award Later`, as ALL eligible items will be awarded automatically.  
**You have been warned.**

### Bonus Rolls
Bonus Rolls detection has been moved to the Core addon from Extra Utilities.
This means all bonus roll detection is built into RCLootCouncil, and doesn't require the EU module to work.
By default all bonus rolls are logged to the Loot History, but this can be changed with the new `Save Bonus Rolls` option under Master Looter options.
The column showing bonus rolls is still part of the EU module.

### Boss Name in History
The boss name is now directly attached to items, meaning no matter when you award items the boss name should be correct in the Loot History.
This would not be the case earlier if another boss was pulled before awarding registered items.

### Classic
The retail version will now show a chat message if installed in the Classic client and vice versa, before disabling itself.

### Error Handler
RCLootCouncil will now log any lua errors caused by it.
This will help in debugging errors as users are no longer required to turn on scriptErrors to register them.

### Voting Frame
When `Hide Votes` is enabled, the Voting Frame will no longer sort the list when receiving votes from other councilmembers.
Once the player has voted, the list is sorted as normal.

## Bugfixes
* *Fixed another issue with EQdkp Plus XML export introduced with v2.18.3.*
* *Loot should no longer linger in the Session Frame after leaving the instance (CurseClassic#41).*
* *Multiple items can be automatically added to a pending trade at once.*
* *Moving responses up/down in the options menu now properly updates their sorting position (Classic#18).*
* *Fixed issues with TradeUI and multiple copies of the same item.*
* *Deleting history older than a specified number of days now works correctly.*


# v2.18.3
## Bugfixes
* *Fixed rare error when award later items have no trade time remaining. (CurseClassic#37)*
* *Fixed issues with EQdkp Plus XML export (CurseClassic#35).*
* *Fixed issue with Award Later when items aren't available in the ML's bags when expected.*

# v2.18.2
## Changes
### Allow Keeping
The pop-up for keeping items now shows "Keep"/"Trade" instead of yes/no. (#183).

## Bugfixes
* *Passes no longer require a note with 'Require Notes' enabled. (#184)*
* *Fixes issue with receiving votes outside an instance (Curse#413).*
* *Fixed issues with TSV Export hyperlinks.*


# v2.18.0
## Additions
### Auto Award BoE's
Added a new system allowing for auto awarding BoE's.
Only Epic, Equippable, non-bags items qualify.
This is checked before the normal auto award, so if both is enabled, this will have priority.

### Class Filter
Added class filters to the Loot History.
Unlike the normal filters, these are active when enabled, i.e. checking 'Warrior' and 'Priest' will only show warriors and priests.

### Require Notes
Added a new option for ML's that will require a note to be added to all responses.
When enabled, if no note is supplied, the response is blocked, and the candidate shown a message to why that happened.
Note: This is not backwards compatible with older version of the addon.

### Winners of item
Added all the winners of the selected item to the More Info tooltip in the Loot History.
Note: Different versions of an item is not included in the count.

## Changes
### Auto Award
Apparently Auto Awards never worked with Personal Loot - this has now been rectified.

### Corrupted Items
Corrupted items now have a purple border and 'Corrupted' text as their bonus text.
This should help you spotting those.

### History Exports
All exports will now respect all currently active filters, i.e. only export what you're currently able to see.

### Out of Raid Support
An "Out of Raid" response is no longer automatically sent if you're outside an instance while in a group of 8 or more.
Instead, the Master Looter will now have to specifically enable it in the "Master Looter > Usage Options" options.
When enabled, it functions exactly as it did before.
*DevNote: I decided to make this change now, as I've seen an increasingly amount of confusion as to why people didn't get Loot pop-ups when out of an instance. I expect the few that actually use this feature will figure out how to turn it on.*

## Bugfixes
* *Candidate info no longer has the potential to wait a long time before being sync, i.e. guild rank not showing up in the voting frame.*
* *2.18.1: Previous version would error out when awarding during tests.*


#### Dev
* Changed parameters of `ML:AutoAward`.
* Changed parameters and return type of `ML:ShouldAutoAward`.
* Added new comm `do_trade` for handling trading of items not contained in `lootTable`.
* Changed system for sending candidate updates (`ML:SendCandidates`).



# v2.17.2
## Bugfixes
* *Characters with Non-ascii names that have a lower-case by WoW lua's definition can now be council members (CurseClassic#31).*
* *Fixed issue regarding adding items to a session could potentially cause an error (Curse#406).*

# v2.17.1
## Changes
### Corruption
The corruption column will now show a candidate's effective corruption (corruption - resistance) instead of the total corruption.
When awarding a corruption item, the tooltip showing the new total corruption now takes corruption resistance into consideration.
Corruption Effects in the tooltip are now colored yellow if an award would make a player exceed its threshold.

### Item Registration
Changed the detection of looted items to ensure better reliability with high latencies (CurseClassic#9).

## Bugfixes
* *Mousing over an empty corruption column will no longer result in an error.*
* *CSV importing data with date and time and no id will now properly add the time part to the history.*


#### Dev
Deprecated `:IsCouncil(name)` with `:CouncilContains(name)`. Former function will be removed in a couple of months.

# v2.17.0
## Changes
Updated for patch 8.3.

## Additions
### Corruption
Added a new button group for corrupted items.
This group supersedes all other button groups, regardless of their specificity.

Added a new column in the Voting Frame containing candidates' corruption info.
Mouse over the value to see a tooltip containing even more info.
It may also be clickable, N'Zoth wills it..

### Ny'alotha the Waking City
Added auto pass data for the new trinkets.
Added both patch 8.3 and the raid as history mass deletion options.

### JSON Export
Sebastianbassen kindly created a JSON export which is now included (#180).


## Bugfixes
* *Fixed issue with CSV importing responses without button groups (CurseClassic#25).*

# v2.16.1
## Changes

#### Chat Frame
`/rc reset` now also resets the chosen chat frame.
The chat frame is also automatically reset to default if the selected chat frame becomes invalid.


## Bugfixes
* *Time calculations with raid members in different timezones now works properly (CurseClassic#22).*
* *The TradeUI now detects reawards when a session has ended.*
* *Bags are now properly ignored by the Auto Award system.*

# v2.16.0

## Additions

### Alt-click Awarding
ML's can now Award items by Alt-clicking a candidate row, saving you a right-click.

### CSV Import/Export
Added support for importing custom history through CSV.  
See the wiki for more info.  
*Note: The CSV export has changed fields to comply with the new import system. This also means old CSV exports cannot be imported!*

### Frame Options
Added an option to select which chat frame RCLootCouncil will print to.

### Loot History
Added "Send to guild" option.  
Checking this will send history entries to your guild instead of your group.

### Looting Options
Added "Award Later" option.  
When enabled, this option will automatically check "Award Later" in the Session Frame.

## Changes

### Loot History
The history is now sortable by class. Just click the class icon header.

### Options

#### Council
Current Council list is now sorted alphabetically.

### Voting Frame

#### Awarding
When Master Looter, awarding an item will now switch session to the first unawarded session instead of simply the next numerical session (i.e. session + 1).

#### Vote Status
The list is now sorted alphabetically and colored according to the candidates' class.  
Added councilmembers that haven't yet voted to the list.  
The names now respects the "Append realm name" option.

#### Votes Column
Voter names are now class colored.  
The names now respects the "Append realm name" option.


## Bugfixes
* *Added a potential fix to the occasional false "Full bags" blame.*
* *Added a history patch for broken "Award Reasons".*


### v2.15.1
---
###### Bugfixes
* *Fixed error when council members reconnect during session (Curse#398).*
* *Fixed error with 'whisper guide' being too long to send in some locales (#177).*
* *The 'Keep Loot' popup is now only used in raids to avoid it unintentionally popping up in dungeons. This is a temporary fix, as a proper fix needs way more work (Curse#396).*
* *Adding items to a session will no longer reset rolls on existing items when "Add Rolls" is enabled.*
* *Adding more than one item to a session could sometimes mess up and make a session switch button disappear.*
* *Items awarded with "Award Reasons" would retain their original response when filtering the Loot History (CurseClassic#9).*


### v2.15.0
---
* **Auto Award**  
* Auto Awards can now only happen on equip able items. #Classic.


* **Filters**  
* Added the option to always show the owner of an item in the voting frame.
* Enabled by default.


###### Bugfixes
* *The explanation on how to use the whisper system was wrong.*
* *The whisper system didn't work properly with responses..*
* *The whisper help system was also broken...*

###### Dev
* Added `typeCode` to `lootTable`. Used to determine butons/responses for a session. Still backwards compatible with old system.
* Changed the entire system of adding new button groups. Refer to `ML:GetTypeCodeForItem`.
* Updated `:PrepareLootTable` to add info from `GetItemInfo` for future comms update.
* Added "Constants.lua" and moved certain constants there.
* Added `itemClassID` and `itemSubClassID` to loot history.
* `RCVotingFrame:RemoveColumn` now automatically updates old sortnext values.
* Overhauled "TrinketData.lua" with new format and classic trinkets.



### v2.14.0
---
* **Voting Frame**  
* The ML can now right click candidates after a session has ended.
* This basically allows for an entire redo of the session, particularly changing awards later than usual.
* As a reminder you can always reopen the voting frame with "/rc open".

###### Bugfixes
* *Reawarding an item to the original owner will now remove the old trade entry from the TradeUI.*


### v2.13.1
---
###### Bugfixes
* *Fixed issues when upgrading from a pre 2.7 version to 2.13 (#391-394).*

### v2.13.0
---
* **Loot History**  
* Added an option to delete loot history entries by instance name.
* This allows you to target a specific instance, in particular Mythic+ loot that got added unintentionally.

###### Dev
* Changed various structures for easier editing. All changes are backwards compatible. #Classic.



### v2.12.2
---
###### Bugfixes
* *Fixed issue with loot history (#389).*
* *Fixed error popping up on random trades (#390).*
* *No longer tracks non-tradeable loot when it isn't supposed to.*


### v2.12.1
---
###### Bugfixes  
* *Fixed library issue causing scrolling tables to unstick and break the UI in 8.2.*



### v2.12.0 (patch 8.2)
---
* Added patch 8.2 and Azshara's Eternal Palace as history mass delete options.


* **Autopass**  
* Added autopass data for trinkets in Crucible of Storms (a bit late, I know).
* Added autopass data for trinkets in Eternal Palace.


###### Bugfixes  
* *Added a compatibility fix very old loot histories (#388).*
* *Removed any Breath of Bwonsamdi that have been recorded to the history during alpha releases.*


### v2.11.0
---
* **Loot Status**  
* The loot status now registers all items dropped by a boss, even if the response indicating if it's tradeable isn't received from the candidate.
* Implemented code to ignore certain loot sources and types (particularly Opulence trash piles), which should overall make the loot status more reliable.


###### Bugfixes  
* *The TradeUI is now able to handle multiple instances of the same item.*
* *More error correcting code for corrupted loot history*
* *No longer logs `non_tradeable` loots when the addon isn't being used, i.e. in dungeons.*
* *Mostly fixed the worst texture stretching throughout the UI.*


###### Dev
* Added `addon.Compat` namespace for handling backwards compatibility.
* Added `addon.lootGUIDToIgnore` table indicating guid's that won't have their loot registered.


### v2.10.3
---
###### Bugfixes
* *Added error correcting code for corrupted settings and loot history.*


### v2.10.2
---
* **Loot History**
* Added all non default responses to the list of changeable responses.


###### Bugfixes
* *VotingFrame session buttons now better display the status, particular for council members.*



### v2.10.1
---
**Loot Status**
* Added loot status to the session frame.
* This allows the ML to see how many have looted the boss before starting a session.

* Added `notes` as an option to announce awards.


###### Bugfixes
* *Fixed random issue with realm name (#385).*


### v2.10.0
---
* **Version Checker**
* The version checker can now print any detected outdated clients.
* Simply add any argument to the chat command, e.g. `/rc v 1` to get the list.


* **Ilvl comparisons**
* If a trinket or ring is looted, and the candidate already has equipped a different version of the item,
RCLootCouncil now uses that item's ilvl when calculating the difference, since that item would have to be replaced (#378).


* The owner is now also shown above the award status in the voting frame.


* Updated Libraries to the latest version(s).


###### Bugfixes
* *Sorting the loot history now properly triggers secondary sorts where needed.*

###### Dev
* Changed structure of `db.global.verTestCandidates`.
* Replaced `:GetDiff()` with `:GetIlvlDifference()` which takes different arguments.


### v2.9.7
---
###### Bugfixes
* *Fixed issue with Loot Status (#382).*



### v2.9.6
---
* **Loot Status**  
* Added a new indicator for when candidates fail to loot items due to full bags.
* This is considered the same as "fake loot" for all intents and purposes.


* **Tests**
* `/rc ftest` now only uses items from the newest raid.
* A `looted` message is now sent on all tests so that people can see the "Loot Status" in action.


* **Loot History**
* Added the owner of an item to the Loot History.
* The owner has also been added to .csv and .tsv exports.
* Note: Only items awarded after this release has their owners tracked.

* Declined manual rolls is now displayed in the voting frame (#329).

* Added trinkets from Battle of Dazar'Alor to the autopass list.

###### Bugfixes
* *Fixed "Not in raid" spam in Battlegrounds (#380).*

###### Dev
* Changed parameters in ml_core `TrackAndLogLoot`.
* Updated fields in `history_table` in said function, along with `RCMLLootHistorySend` message.


### v2.9.5
---
* Updated .toc for patch 8.1
* Added patch 8.1 as an option for Loot History mass deletion.


* **Auto Trade**
* Added a new option that when enabled bypasses the trade popup and automatically adds items that should be traded.
* This option is disabled by default.


* The version checker now only shows eligible players at the time of the query *(For Bram)*.


###### Bugfixes
* *Fixed issue with fewer than default buttons not working properly (Git#172).*
* *Items would sometimes be marked as non-tradeable if the player already had a duplicate of the item (#379, #375).*
* *Switched to MSA_DropDownMenu-1.0 to avoid errors with DropDownMenus (#376, #374, #366?, #361?).*



### v2.9.4
---
###### Bugfixes
* *Fixed issue with loot frame disappearing after rolling for just one item. (#377)*


### v2.9.3
---
* **Loot Status**  
* Added a display of whom have looted the boss to the voting frame.


* **Add command**
* The "/rc add" command have been extended to optionally include a player name.
* Simply type the name of a group member before any items you add.
* Unless invalid, that player will be added as the owner of the item, which will allow the TradeUI to do it's thing.
* Note: You must add a space after the player name.


* **Moveable buttons options**
* Buttons and responses can now be moved up/down in the options menu to easily change their order.
* This can also be done on the "Award Reasons".



### v2.9.2
---
###### Bugfixes
* *Fixed issue with dropdown menus that had sneaked in at the last minute.*


### v2.9.1
---

* Added local chat print option to all announcements.
* Added a custom number of days input to loot history mass deletion.


###### Bugfixes
* *BoE items are now no longer added to sessions when the option is turned off.*
* *Disabled all ML registrations in pvp (#354).*
* *Added a patch and fix for Blizzards and others taint of dropdown menus (#358, #361, #366).*
* *Wands and other weapons are now correctly identified as MainHand weapons (#368).*
* *The TradeUI will now be shown if using a different locale than the ML (#370).*



### v2.9.0
---
* **Appearance**
* Added a new default Battle for Azeroth skin.
* Remember you can change the appearance in the options menu.
* Added a different colored frame for when rolling for items you own yourself.


* **Buttons and Responses**
* ~~Removed~~ Tier and relic buttons.
* Added new buttons for every gear slot available.
* You can now set custom buttons and responses for each type of gear, and even groups of gear such as Azerite Armor.
* By default none of these are enabled, and must be added manually. As always only the group leader's set of buttons is used.
* The new buttons are not backwards compatible with older versions, but altered default buttons/responses have been migrated.


* **Loot History Mass Deletion**
* It's now possible to delete multiple entries at once from the loot history.
* Just go to the options menu ("/rc config") and have a look at the loot history settings.
* Currently delete by name, patch, and number of days is supported - let me know if you need more.


* **Candidate Loot Status**
* The backend of this has been implemented.
* As this was a lot harder to do than anticipated, I still need a bit more time to ensure it's working.


* Added Battle for Azeroth trinkets to the autopass table.
* Non-tradeable and rejected trades from PL are now registered in the loot history.
* Quest and crafting items are now always ignored.


###### Bugfixes
* *Fixed EQDKP Plus exports (#360).*
* *All item icons are now shift-right-clickable to see Azerite Traits.*


###### Dev
* Changed parameters in `UpdateAndSendRecentTradableItem()` to contain the table itself.
* Changed comms `tradeable` and `non_tradeable` to include boss guid as the last parameter.
* Added to new comms `looted` and `fakeLoot` to deal with looting status.
* Changed the structure of `db.responses` and `db.buttons`.
* Removed `:GetResponseText` and the likes. Use the new `:GetResponse` and `:GetButtons` functions.
* Changed `mldb` to fit the new scheme, which includes inheritance from normal db.
* Removed a few values from the lootTable.


### v2.8.3
---
* **Trading**
* The Group Leader now has an option to see whenever candidates trades items to the winners.
* A warning is printed if a candidate trades an awarded item to the wrong person.


* **Personal Loot**
* The council can now see all items looted whether tradeable or not.
* New buttons will appear for any items that can't be added to the session under the voting frame.
* Usage options have been updated to only include PL options.


* **Allow Keeping**
* The Group Leader can now choose whether candidates can keep their items.
* If enabled (disabled by default) candidates will see a popup asking if the want to keep the loot whenever they loot a tradeable item.


###### Bugfixes
* *Removed usage popup for non group leaders.*
* *Usage popup should be more reliable (#350).*


###### Dev
* Two new comm messages (`not_tradeable` and `rejected_trade`).
* Added UI section. This is the beginning of a consolidation of UI elements - everything will use this format soon ish.
* Backwards compatibility isn't broken yet, but will be at some point.

### v2.8.2
---

* **TradeUI**
* Added an indicator for when you're in range of the trade target.
* When in range, simply click the row in the TradeUI to initiate trade.
* Note: There seems to be issues with automatically adding multiple items at once.
* It also seems like something has changed that doesn't allow for as automatic trading as I'd hoped.


###### Bugfixes
* *Fixed an issue preventing automatic trading (#347).*


### v2.8.1
---
###### Bugfixes
* *Fixed a few issues with the TradeUI (#343, #344).*

###### Dev
* Added two new comm messages for when RCLootCouncil handles loot. See top of core.lua.


### v2.8.0 (patch 8.0)
---
* **Personal Loot**
* RCLootCouncil is now fully useable with Personal Loot (PL).
* All features (except obviously automatic distribution) is available when using PL.
* PL mode is activated the same way ML used to be (popup in raid/group and/or through options).
* When in PL mode, any tradeable items looted by any raider is automatically added to the session frame.
* When items are awarded, players will need to trade the item to the winner, see below.
* PL sessions still respects all loot/item settings such as autopass, filters etc.
* *TODO: Missing a list of candidates that has looted a particular boss.*


* **TradeUI**
* Items that need to be traded to someone else are now presented in a separate window.
* *TODO: Make it even easier by (semi) automatically open trade dialog.*


* **Session additions**
* Due to the nature of PL items not necessarily all dropping at once, items can now be added to a running session.
* The MasterLooter/GroupLeader can simply add items through already available methods ('/rc add', alt-clicking or automatically).
* Depending on settings, items are added to the session automatically, or to the session frame, and candidates are presented with the LootFrame for these items.
* Due to internal restrictions, these items are not sorted if enabled.


* **Item owners**
* Session- and Voting frame now shows the owner of a particular item.
* This info is also available for use in announcements.


* **Discord export**
* The Loot History can now be exported in a Discord friendly format.


###### Dev
* Removed `db.baggedItems`.
* Added `RCLootCouncil.ItemStorage` for handling all items stored in bags. See file for documentation.
* Added TradeUI for handling items that should be traded.
* Added comm `lt_add` to relay lootTable additions.
* Changed `award` comm to include `owner` as the last argument.
* Removed Master Loot (loot method) related stuff.

### v2.7.11
---
###### Bugfixes
* *Fixed an issue with out of instance checks (#340).*
* *Fixed an issue sometimes happening on login due to version checks (#341).*

### v2.7.10
---
* Added "Pass" button to right click menu -> Change Response.
* Loot Frame notes no longer requires an "enter" press to save the note.
* Added a Discord option to Loot History exports.

* **Out of Instance**
* A message is added to a response if people has left the instance (i.e. impossible to give loot).
* Various error messages have been updated to better reflect what's going on.

###### Bugfixes
* *Trying to sync/receiving sync in LFG/Battlegrounds could give "Not in Raid" spam (#338).*
* *Wrong roles on candidates shouldn't happen anymore.*
* *Missing/wrong guild ranks should happen less frequently (will be fully fixed in another update).*


### v2.7.9
---
###### Bugfixes
* *Group members that haven't been awarded anything is now shown in the loot history (Git#151).*
* *Some times guild rank could disappear from candidates (#335).*


### v2.7.8
---
###### Bugfixes
* *Changing role could temporarily remove a candidate from future sessions (#328, #332, #333).*
* *Fixed an odd potential error related to the voting frame (#330).*


### v2.7.7
---
###### Bugfixes
* *Fixed a `ZERO` bug introduced with v2.7.6.*


### v2.7.6
---
* **Tokens and trinkets**
* Every eligible trinket and tier token is now registered according to specs and classes, and can be autopassed.
* The Voting Frame now shows trinkets' intended receiver role and/or main stat.


* **Item bonuses**
 * Item bonuses are now displayed in the Voting-, Loot- and Session frame.
 * The bonuses registered are Sockets, Leech, Avoidance, Speed and Indestructible.


###### Bugfixes
* *No longer asks for usage in pvp instances.*
* *Fixed an error with syncing in some locales (#318).*
* *Item names in the loot history are now sorted correctly.*
* *Changing roles mid raid wouldn't always be registered properly.*


###### Dev
* `:CustomChatCmd()` is now deprecated, use `:ModuleChatCmd()` instead.


### v2.7.5
---
* It's now (again) possible to see the voting frame while not in the instance.


* **Autopass trinkets**
* Added a new feature which (by default) autopasses trinkets that are not listed for your class in the Dungeon Journal (#314).
* This can be toggled in the options menu if needed.
* Note: Trinkets added before Legion are not included in this check.


* **Tooltips**
* Tooltips on the voting frame and loot frame can now be permanently shown.
* Just double click on the item icon to toggle.


###### Bugfixes
* *Doing reannounce or request rolls could potentially set autopass response in some sessions (#313).*
* *Attempting to sync with friends or guildmembers on ruRU locale would fail (#317).*


### v2.7.4
---
Note: This version partially breaks backwards compatibility. All council members needs this version to see player's gear.
###### Bugfixes
* *Hopefully fixed disconnect on large raid sizes for real (#313)*

###### Dev
* **Changed**
* "lootAck" now contains player gear for all sessions, along with autopasses.
* Item links in responses have been replaced with itemstrings.
*  `AutoResponse()` replaced with `SendLootAck` and `DoAutoPasses`.

### v2.7.3
---
###### Bugfixes
* *Fixed a bug causing errors when pressing "Pass". (#315)*


### v2.7.2
---
* Added filtering for guildranks.
* Added Sigil of the Dark Titan to the ignore list.

###### Bugfixes
* *The version checker didn't always sort "Not installed" correctly.*
* *The "Use RCLootCouncil" popup no longer shows twice for certain settings.*
* *Added a potential fix for disconnect issues with large raid sizes. (#313)*


### v2.7.1
---
###### Bugfixes
* *A breaking bug on session sorting had sneaked into the latest release.*


### v2.7.0
---
* **General**
* Tier tokens now uses the minimum ilvl of the item the token will create as their ilvl.
   + This way all ilvl calculations will show more useful numbers.
   + Note: RCLootCouncil cannot track if these items will be Warforged/Titanforged. Only the guaranteed minimum ilvl is used.
* The class icon can now be replaced with spec icon.
* Filter button's text now change color to indicate a filter is active.
* During tests all chat outputs are now preceeded with "(test)".
* Any chat output during solo tests are now replaced with chat prints.
* "/rc add" once again works without spaces between items.
* A winner's note (if set) is now stored in the history, and included in TSV and CSV exports. (#306)
* Various localization improvements have been added.


* **Master Loot**
* **RCLootCouncil** can now be used without Master Loot enabled (#134, #137, #171).
* The group leader can now always start a session ("/rc add [item]"), regardless of the loot method being used.
   * *The only exception to this is in LFG groups.*
   * This also requires everyone in the group to use v2.7 or newer.
* Do note it's still not possible to automatically give out items without using Master Loot due to WoW restrictions.


* **Announcements**
* Added a few more keyword replacements for announcement options.
* It's now possible to edit the announcement string for individual items.
* Have a look at the redesigned "Announcements" tab for the changes.


* **Sessions**
* Items are now sorted before starting a session.
   + The sorting algorithm follows: type/subtype > ilvl > bonuses > name
   + This can be disabled in case you prefer your sessions to follow the order items are dropped in.
* Session Frame is now displayed if using "Auto Start" and the session isn't fully ready.
* Items can now be awarded later even after a session is started.
* Any errors during awarding are now more detailedly relayed to the user.
* Items can now be reawarded.
   + Simply award the already awarded item to another candidate.
   + This will update everything RCLootCouncil tracks to the new winner.
   + The original receiver of the item will still have to trade the item to the new winner.
* Awarding an item will change the winner's response to awarded for all duplicate sessions.
* Added an option to auto add any BoE item looted by another player in the group.
* Ilvl is now included in the session frame.


* **Responses**
* Most response related information is now sent immediately when a session starts instead of after rolling.
   + E.g. the council can now see a candidates gear and ilvl before a candidate responds.
* **RCLootCouncil** now sends the gear a candidate had equipped during the most recent encounter instead of the gear equipped when rolling.
   + This way candidates can't change their gear to appear to have a lower ilvl.
* If enabled, relic responses can now be filtered separately.
* You can now filter responses from candidates that can't use a given item.
* It's now possible to ask a candidate to reroll only on items they can use.


* **Loot Frame**
* Multiple copies of the same item now stacks together so only one roll is required.
* The loot frame will now trigger immediately when a session starts instead of after ~2 seconds delay.
* Now shows items' type and subType alongside the ilvl.
* The layout is now more consistent in general.
* The note button design received an update.
* Added an option to print out responses as they're sent.
* The default timeout is now 60 seconds.


* **Rolls**
* Added a new feature that involves raiders in the roll system, making it seem less "random" and more transparent.
   * There's a new option in the ML's right click menu that starts a roll session.
   * Clicking it will show a special roll version of the loot frame to the specified candidates.
   * Candidates can then click the dice button to roll, or simply pass if they want.
   * Doing that will result in a normal "/roll" which is then sent to the council.
* This is entirely optional, and the normal roll system still exists.
* If the item being rolled for exists multiple times in a session, then the roll is added to all of the item's sessions.


* **History Export/Import**
* Removed all lag on import and export.
* Huge exports now appear in a single line - you won't see a difference after pasting the data somewhere else though.
* Minor exports is still fully shown.
* When importing, only the first 2500 bytes are shown, but the data is still there.


* **Loot from bags**
* Trading with a winner while having awarded items in your bags now prompts to add those items to the trade window.
* Now keeps an eye on the timer on items that needs to be traded.


###### Bugfixes
+ *Fixed a few localization related bugs for non-english clients.*
+ *A session starting immidiately after doing a /reload could cause an error.*
+ *Fixed a few spelling errors in english locale.*
+ *Fixed an error when the ML receives an integer from whisper during a session with whisper feature enabled*.
+ *Fixed an issue when deleting multiple entries in the loot history*.

###### Dev
* **New**
   + ```:GetItemTypeText()``` for displaying various item types.
   + ```:PrepareLootTable()``` replaces the ```subType``` in the lootTable with the subType in our localization.
   + ```:UpdatePlayersData()``` uses the two new functions ```:UpdatePlayersRelics()``` and ```:UpdatePlayerGears()``` to cache the player's gear/info.
   + SpecID is now included in the candidate data.
   + New message on ```:BuildMLdb()```.
   + ```:ItemIsItem(link or itemID or itemName)``` properly compares two items.
   + ```:CanSetML()``` returns true if and only if we can set the master looter. (The player is raid leader and in a guild group)
   + Loads of other new functions that doesn't alter previous executions noteably.

* **Changed**
   + ~~```:CreateResponse()```~~ is consolidated into ```:SendResponse(...)``` which now creates and sends responses.
   * ```:GetPlayersGear(link, equipLoc, gearsTable)``` added arg ```gearsTable```. If specified, use that table to fetch item data instead of from the player's current equipped gears.
   * ```:GetArtifactRelics(link, relicsTable)``` added arg ```relicsTable```. Similar to above.
   * "Miscellaneous" and "Junk" is added to the ```subTypeLookup```.
   * The ```lootTable``` in core is now the same as in votingFrame. Use ```RCLootCouncil:GetLootTable()``` to fetch it, as the votingFrame one will be removed.
   * ```ML:AddItem(...)``` is changed to ```ML:AddItem(item, bagged, slotIndex, entry)```.
   * ```ML:Award(...)``` is more or less completely reworked.
   * New ruleset for ```GetML()```. Will always indicate the group leader as ML with ML disabled.
   * The argument of message ```RCMLAddItem``` is changed from item, session to item, entry.
   * The entries in mldb are now nonexistant (nil) instead of false - just to save a bit of space.


*Huge shoutout to __Safetee__ for the majority of these changes!*

### v2.6.1
---

###### Bugfixes
+ *Using "Award for ..." would cause an error (#305) - props to safetee.*

* ***Dev***
* Added RCMLLootHistorySend message to allow for edits to the loot history send outs.


### v2.6.0
---
* **Relic Buttons**
* A new seperate set of buttons is now available for relics.
* As Master Looter, have a look at the "Button and Responses" settings to enable them.
* Do note that anyone with an older version of RCLootCouncil (<2.6) will NOT see the relic buttons.


* **History Exports**
* The subType and equipLoc of the awarded item have been included in TSV and CSV exports (#301).
* RollType ("token", "relic" and "normal") have also been added to indicate which set of buttons was used.
* TSV exports no longer includes links when there's no item.
* isAwardReason columns will no longer return nil (only true/false).


* **Scaling**
* All RCLootCouncil frames now hides with the UI (alt-z by default) (#303).
* This change affected all frame scaling, and all scaling have been reset to the new default.
* I've tried to remain as close as possible to the original, but if something seems off remember you can scale all frames with ctrl-mousewheel.


* Testing optimization for wowhead urls in exports (#278).
* Tier and Relic responses now only shows up in rightclick menus if enabled.
* Better sorting for names in the loot history rightclick menu - thanks to Safetee (#292).


###### Bugfixes
+ *The Version Checker is now more realistic with its coloring and sorting.*
+ *Councilmen could open the voting frame with no data and produce an error (#300).*


* ***Dev***
* Restructured "CONFIRM_AWARD" popup, along with data supplied from votingFrame.
* All functions in that popup are now easily hookable.
* Edited arguments in ML:Award().
* Minor restructuring in rightclick menus, added 'hidden' field.
* ChatCommands can now receive more arguments.
* Several new internal messages.


### v2.5.5
---
###### Bugfixes
+ *Fixed an issue with registering awards on the voting frame.*


### v2.5.4
---
###### Bugfixes
+ *Removed occasional "test num num" prints (#297).*
+ *Should no longer cause "You're not in a raid" spam from addon messages.*


### v2.5.3
---
* Names in the Loot History rightclick menu is now sorted alphabetically (#292).


* **Dev**
* Added :GetCurrentSession() and AceEvent messages "RCSessionChangedPre" and "RCSessionChangedPost" to the voting frame.

###### Bugfixes
+ *Fixed occasional error related to awards (#296).*
+ *Long standing autopass issue when the ML is using a different locale - thanks to safetee (#285).*



### v2.5.2
---
###### Bugfixes
+ *Fixed error after syncing in certain situations. (#288)*
+ *Fixed a nil comparison error when more than 14 was in the group (#289).*
+ *Fixed an error in the loot frame note (#290).*

### v2.5.1
---
###### Bugfixes
+ *The usage popup wouldn't work properly if master looter was already enabled.*


### v2.5.0
---
* **Synchronize**
* It's now possible to synchronize the settings and loot history between players.
* The sync frame is accessible through the options menu, or the newly added "/rc sync" command.


* **Rolls**
* Added an option to automatically add a random 1-100 roll to all candidates.
* A candidate's roll can now be added to award announcements by using "&n" in the announcement text.


* **Award**
* The winner of an item is now shown in the voting frame.


* **Number of raids**
* Added number of raids registered to all more info displays.
* Note: These are somewhat estimates, as RCLootCouncil only has a loot tracker, and not a fully fletched raid tracker.


* Updated for 7.3.
* Comms optimizations.
* Prepared to handle Tier 21.
* Added some missing text to the localization table.
* Added Rune of Passage to the ignore list.


* **Dev**
 * **Breaking**
 * Added a new parameter to CustomChatCmd() to add a help string to the added command.
 * Changed returns from GetLootDBStatistics().
 * RCLootCouncilML:AnnounceAward() has been recreated so keywords can be added and/or changed.
* Restructured votingFrame and lootHistory rightclick menu so new entries can be added and defaults changed.
* scrollCols in LootHistory module is now changeable.


###### Bugfixes
+ *It's no longer possible to start a session before crucial data has been sent out.*


### v2.4.6
---
* Optimized ML comm timers.


### v2.4.5
---
* Optimized boss name recording.

###### Bugfixes
+ *Fixed a rare occurence of wrong item awarding (#271).*
+ *Fixed a failure when evaluating if items can be looted.*

### v2.4.4
---
###### Bugfixes
+ *Refixed buttons once again - should be the last time, sorry (#270).*
+ *Deleting the last entry from a candidate will now properly make the votingframe more info show "no entries in loot history".*

### v2.4.3
---
###### Bugfixes
+ *Awarding a tier token for any non-editable response would trigger an error in the loot history (#269).*
+ *Editing a response in the loot history to a tier response wouldn't retain it's colors after a /reload.*

### v2.4.2
---
###### Bugfixes
+ *Council was sometimes not sent out properly (#267).*
+ *Changing from a higher to a lower button count would require a /reload (#268).*


### v2.4.1
---
* Added Fragment of the Guardian's Seal and Sticky Volatile Essence to the ignore list.

###### Bugfixes
 + *Tier Awards will now be announced properly (#264).*
 + *The loot frame will now properly reset after a session.(#263)*
 + *Huge amount of councilmembers should no longer slow down the addon. (#263)*

### v2.4.0
---
**Note:**
While this version is backwards compatible, the tier token buttons will not be showed on older clients,
 and any tier rolls will show up as normal rolls for all intents and purposes.


* **Tier tokens**
 * By default, tier tokens now receive special roll options.
 * A brand new set of buttons and responses have been added for tier tokens only.
 * Check them out in the options menu, where it can also be disabled if need be.
 * Prepared to handle tier 20 tokens.


* **Loot History**
 * You can now edit recipients and reasons in the loot history.
 * Simply right click any entry and change it to what you want.
 * Exports have been optimized.
 * Time-Sort no longer memory leaks.
 * A small error in the history will no longer break the entire addon.

##### Fix
+ *The Master Looter wouldn't send all the correct buttons (#262).*


### v2.3.4
---
###### Bugfixes
 + *Items could be wrongly awarded by opening/closing the default loot frame in a specific sequence (#257).*


### v2.3.3
---
###### Bugfixes
 + *Added a bandaid for playernames with non-english characters (#255).*
 + *Changing from more to less buttons will now properly remove old buttons on the loot frame (#254).*


### v2.3.2
---
* Added backwards compatibility for the latest updates for non-english clients.

  *Note: This requires at least one v2.3.1+ award entry for each instance/difficulty.
   The update happens upon logging in after upgrading to v2.3.2, and can be forced afterwards with "/rc updatehistory".*

###### Bugfixes
 + *Newest history additions didn't work well with very old history data.*


### v2.3.1
---
* **History**
 * The loot history is now enabled by default.
 * Now tracks tier tokens received, group size and instanceMapIDs.
 * Tier tokens received from the current instance is displayed under more info in the voting frame.
 * All tier tokens are displayed in the loot history more info.

 * *Note: neither of these are backwards compatible with non-english clients, but will show up for all items awarded after this update.*     
 * Total awards are now displayed in the loot history.
 * Loot History is now sorted by award time by default.
 * Removed response text from voting frame more info to make it smaller.


* Minor optimizations.
* Fixed some spelling mistakes.


### v2.3.0
---
* **Patch 7.2**
  * Added Tier 20 tokens
  * Updated .toc to 7.2.
  * Updated libraries.


* Councilmen reconnecting will now receive the full session data instead of just the initial state.
* Added better boss name grabbing for the loot history.


##### Bugfixes
 + *Fixed a bug that allowed modules to cause errors when changing columns (#249).*

### v2.2.5
---
##### Bugfixes
+ *The fix to ticket #237 caused another issue under certain circumstances - refixed the fix.*


### v2.2.4
---
* Added Echo of Time (Nighthold quest item) to the ignore list.
* Added proper guild rank sorting in the Version Checker.

##### Bugfixes
+ *Links for gear2 is now properly generated when using TSV export.*
+ ~~*Items will no longer be added multiple times to the session setup if you reopen the ML loot before starting the session (#237).*~~
+ *The Version Checker will no longer fail to show correct modules after manipulating the list.*


### v2.2.3
---
* **History Export**
 * ItemStrings are now in a seperate column.
 * Added a tab delimited export with hyperlinks on items (#232).


* Allowed raid groups with less than 5 people (#236).

##### Bugfixes
+ *CSV export now works as intended (#233)*
+ *Made ML/candidate communication more reliable (#235)*
+ *The Version Checker will now display the realm part of a crossrealm players' name correctly.*

### v2.2.2
---
* **Delete History entry**
 * You can now delete individual entries in the loot history.


* Comms optimizations.

##### Bugfixes
+ *Loot History now works directly after clearing it (#228)*
+ *The previous version broke most sorting - reverted that.*


### v2.2.1
---
* Artifact Relic type is now displayed in the voting frame.

##### Bugfixes
+ *Fixed version comparison for good (#226)*

### v2.2.0
---
* **Tier 19**
 * Added support for Nighthold Tier 19 tokens.


* **Skin**
  * Legion's been out for a while, so the default skin is now back to Midnight Blue.


* Buttons on the Loot Frame now always have a minimum witdh of 40 px.

##### Bugfixes
+ *Added extra checks so a name related error won't happen (#223).*
+ *Fixed some false autopasses on artifact relics related to uncached items.*

### v2.1.11
---
##### Bugfixes
 + *Fixed bug on version comparisons (#216).*
 + *Removed some debug stuff (#217).*

### v2.1.10
---
##### Bugfixes
 + *Fixed error on localization based on Curse changing their format.*
 + *Fixed an error on tooltips (#213).*

### v2.1.9
---
* **Item Icons**
  * All item icons are now ctrl/shift clickable (like the default UI buttons).
  * It's now possible to compare by shift-clicking while hovering over an icon instead of holding down shift before the mouseover.


* **Export optimizations**

##### Bugfixes
  + *Artifact relics wasn't being sent on non-english locales (#212).*

### v2.1.8
---
+ **Clear Selection**
  * Added a clear selection button in the loot history.

+ **Bonuses on Wowhead links**
  * All exports containing Wowhead links will now include item bonusses. Thanks to Iacha.

* All popups are now forced to be on top of other RCLootCouncil frames.

* Reannouncing items now changes the candidate's response to waiting.

##### Bugfixes
 + *Not all awards would display properly in the loot history (#197, #201).*
 + *Finally convinced the loot history filter button to be the same height as other buttons.*

### v2.1.7
---
* **Updated toc for 7.1**

* **Only use in raids**
  * Added an option to automatically disable in parties. Also moved usage options to Master Looter page.

* No longer asks for usage in LFG instances (#196).

* Clarified a few of the option descriptions.

* Various stability fixes.

##### Bugfixes
 * *The filter button needed to be clicked before newly added buttons/responses would show (#203).*
 * *Various council/voting issues (#199, #194, #189, #174).*
 * *Version Checker could show double entries in some locales (#198).*
 * *Changing buttons after a session started could cause errors.*
 * *It was possible to get an error when rolling on a relic without having an artifact equipped.*
 * *Other Award Reasons could get merged with normal awards in the voting frame more info tooltip.*

### v2.1.6
---
+ **Shared Loot History**
  * It's now possible to share and synchronize your loot history. For now it's a manual copy/paste job using
  * the new "Player Export" format and the import button. Hopes are to make it automatic some day.
  * Note: Importing someone's history will only add to your own, not delete anything.

##### Bugfixes
 * *Accepting the usage popup will no longer do anything if you're not the ML.*
 * *Fixed a potential voting frame related bug depending on installed addons (#190) - thanks to Stoobert_Broon.*
 * *Councilmembers wouldn't count the ML in the number of votes if he hadn't assigned himself to the council.*

### v2.1.5
---
* **Item differences**
  * Now always calculated on the lowest ilvl if two items of the same type is equipped.

* Added Essence of Clarity to the ignore list.

##### Bugfixes
 * *Remade the check that would fail to award double items (#180).*
 * *Loot History will now correctly show the response as it was when awarded (#181).*
 * *Fixed a weird error probably related to Russian lua locale (#179)*
 * *Added a fix to time calculations that could sometimes cause an error.*
 * *Using the Version Checker on the guild will now properly have people respond to it.*

### v2.1.4
---
+ **Offspec artifact relics**
  * Added support for offspec artifact, so you longer autopass those items.

+ **Mouseover more info**
  * The voting frame now updates the more info tooltip every time you mouseover a candidate.
  * New option to display info about latest loot from more responses. Checkout MasterLooter -> Buttons and Responses -> More Info options.

+ **Date-Time column in Loot History**
  * You can now see, and sort by, date and time the item was awarded in the loot history.

* You can no longer start an empty session.

##### Bugfixes
 * *Fixed potential error when handling X-Realm comms (#156).*
 * *Added extra checks against comm messages droppings (#149,#151,#152,#153,#155,#156,#157).*

### v2.1.3
---
+ **Added BBCode SMF export**

##### Bugfixes
 * *Fixed ticket #145 for real this time.*
 * *Potential fix to some issues with people not seeing loot frame/voting frame.(#149,#150,#152,#153)*
 * *Potential fix to some issues with double added items/skipped items.(#149)*

### v2.1.2
---
##### Bugfixes
* *Wrong library load order would cause errors when RCLootCouncil was the only installed addon (#146)*

### v2.1.1
---
* **Artifact Relics**
  * Your currently equipped Artifact Relics are now showed in the voting frame.
  * And they're autopassed if you can't use that type.
* **Module chat commands**
  * Implemented a function to let user modules add chat commands to "/rc" prefix.
* **Module Versions**
  * The version checker now displays information about installed modules, if any.

##### Bugfixes
* *Fixed an inconsistency in handling players with capital letters in the middle of their name (#145)*

## v2.1
* **Skins**
  * You can now customize the look and feel of RCLootCouncil.
* **Timeout**
  * You can now specify a timeout on the loot frame. If players doesn't respond in time, the voting frame will list them as timed out.
* **Export Loot History**
  * It's now possible to export your loot history! For now csv, bbcode, xml and lua exports are available. Feel free to make a request if you'd like to see others added.
* **Not in Raid**
  * RCLootCouncil now detects if you're actually in the instance. If not, you won't be able to receive loot and the council will now know it.

##### Bugfixes
* *The more info frame in the Loot History sometimes needed some convincing to show/hide.*
* *Raiders permissions are now reset/updated every session (#144).*
* *It was sometimes possible to get non-title case UnitNames (#145).*

### v2.0.2
---
* **Auto Close**
  * The voting frame can now be toggled to automatically close when the ML ends a session.
* Monks no longer autopasses on maces and axes.
* Rolls are now synced with the raid

### v2.0.1
---
* Autopass
  * Shamans no longer autopasses daggers, and hunters staves and polearms.
* Awarding an item now automatically changes the voting frame to the next.
* The voting frame is now a bit narrower.
* Should be a bit more stable when reconnecting during a session.

## v2.0

* **Complete rewrite**

* **UI overhaul**
  *   Every frame now follows a standardized layout with support for minimizing and scaling (ctrl+scroll).
      It's also made with future customization in mind. Note: Use rightclick for awarding items.

* **Options menu overhaul**
  * Master Looter options have been moved to a separate tree and the entire interface have been streamlined.

* **Updated chat commands**
  *    Most chat commands results in a more appropriate interface than before, while some have been removed.

* **Auto pass**
  *    By default, RCLootCouncil now auto passes on items certain classes can't use (e.g. plate for priests)
      and items certain classes shouldn't use (e.g. leather for hunters).

* **Observe mode**
  *    The Master Looter can enable observe mode to let non-council members see the voting frame.

* **Autohide in combat**
  *    If enabled all RCLootCouncil frames will minimize when entering combat.

* **Session setup**
  *    The Master Looter is now able to review the list of items before starting a session as well as
      manipulating the list by adding or removing items.

* **Award later**
  *    Using the session setup, the Master Looter can choose to award items later thus looting the items,
      and have RCLootCouncil start a session later by typing '/rc award'. It's not possible to automatically
      give out items that's already looted, so instead '/rc winners' gives you a list with whom to give the item to.

* **Loot from bags**
  *    RCLootCouncil can now add custom items to a session by typing '/rc add [item]'.

* **Localization**
  *    All text strings in the addon is now localizable. Head to http://wow.curseforge.com/addons/rclootcouncil/localization/
      to contribuate.

* **Ignore list**
  *    RCLootCouncil now have a customizable ignore list, for, well, ignoring stuff.

* **Usage options**
  *    More usability to e.g. disable the popup when entering a raid by always accepting it, or
      always rejecting it. Option to turn off the addon temporarily.

* **Filtering**
  *    All responses on the voting frame are now filterable.

* **Status text**
  *    Everyone in the group is now added to the voting frame with a status text as their response,
      e.g. "Not installed", "Selecting response" and "Candidate removed"

* **Diff and roll**
  *    Two new columns in the voting frame:
  *    "Diff" - which shows the item lvl difference between a candidates' equipped item and the one in session.
  *    "Roll" which allows the Master Looter to add a random 1 - 100 roll to all candidates should he so desire.

* **Hide Votes**
  *    New option to hide votes until one self have voted.

* **Module support**
  *    All frames are implemented as modules, which can be replaced. This also gives the opportunity
      for anyone to add custom features to the core addon.

* **Disenchant button**
  *    You'll get a "Disenchant" button in the voting frame. Clicking it will show a list of enchanters in your group (if any),
      and clicking a name will award the item to that player with the reason selected for disenchant in "Award Reasons".

* ~~Limits~~
  *    No more 20 item limit per session (not that you're gonna need that), no more "award in this particular order" limit,
      no more "close session when you close the WoW loot frame", etc.

* ~~Rank Frame~~
  *    Old and not really useful. Better alternative in the options menu.

* ~~Raid Chat~~
  *    Noone wants to see people linking items in the raid chat just because someone didn't install an addon. Use whisper for that!

* ~~Pass button~~
  *    Not really removed, but automatically added so you won't have to think about that. Also removed "filter passes" due to the new filtering system.

1.7.8 Bugfixes:
	*	*Various taint fixes.*
	*	*Alt-clicking items didn't work properly when the player used different loot frame addons.*
	*	*Blizzard doesn't allow to give out loot with a quality less than loot treshhold, work-around by allowing items to get auto looted to the Master Looter.*


### v2.0.0 Release changes
---
* **Legion Updates**
  * Demon Hunters has been added to the autopass check.
  * Legion enchanting materials added to ignore table.
  * API updates to patch 7.0.3 changes

* Every setting from both alpha versions and v1.7.8 has been reset. Loot History from v1.7.8 is imported to v2.0.

* **Tier token autopass**
  * Now autopasses on tier tokens not useable by your class.

##### Bugfixes
* *Sorting by Response or Guildrank didn't work as intended (#127).*
* *Multi Vote option didn't work properly (#128).*
* *The Voting Frame no longer sorts itself every time a vote is received.*
* *Wasn't handling sessions correctly when two of the same items dropped.*


### Alpha12 changes
---
* Repacked. No longer named as "RCLootCouncil2". This is done in preparation for release. Note this change will overwrite any v.1.7.x settings.
* It's no longer possible to start a session with items that aren't fully loaded.

* **More Info in Voting Frame**
  * The Voting Frame now has a little button that enables you to see how many items with a given response a given player has received,
   along with the last item and how long since they received it.

##### Bugfixes
* *The MasterLooters enchanting profession was never registered (#126).*
* *Some times the MasterLooters settings was rejected resulting in empty Loot Frames (#124).*
* *No longer tracks test awards in the Loot History.*
* *Cleaned up some globals.*


### Alpha11 changes
---
* **Enabled LootHistory**
  * The Loot History is now back in a refreshed form. There's been some changes since the launch of the v2.0 alpha, hence class specific
things won't show for your old history, and you're encouraged to delete your history to get the optimal experience. Note: Exporting
the Loot History will come in a later update, go find the ticket on Curse to specify which export formats you want.

* The Disenchant button is now always shown. It'll only produce a list of enchanters if an award reason has been marked as disenchant.
* Guildrank sorting is now done according to the actual rank instead of alphabetically.

* The voting frame scroll position now always resets when switching between items in a session.

* **Show realmnames**
  * It's now possible to see the realm name of a player from a different realm throughout the addon.

##### Bugfixes
* *The disenchant button is now only visable to the Master Looter.*


### Alpha10 changes
---
* Bumped max buttons and awardReasons to 10.
* Asking someone to reroll while they're already rolling now adds the new rolls to the list instead of replacing it.

##### Bugfixes
* *Some actions involving players from another realm wasn't handled properly (#117, #119).*
* *Fixed error when changing profiles (#120).*
* *Some times the "reconnect" function wouldn't always work, potentially resulting in an empty loot frame (#119).*
* *Whispering responses didn't work due to recent updates.*

### Alpha9 changes
---
* Some optimizations.
* **Item status**
  * Now shows whether an item is mythic, warforged, etc. in the voting frame.
* **People to vote string** is now back.

##### Bugfixes
* *The tooltip showing voters names showed up when it wasn't supposed to.*
* *Councilmens "Filter" didn't update correctly if the ML changed the buttons (Ticket#113).*
* *Now never auto passes cloaks as they're considered cloth by Blizzard (Ticket#115).*
* *Loot Slot changes wasn't handled properly (Ticket#116).*

### Alpha8 changes
---
* Now properly resets ML status after a test session.
* Players doing a /reloadui during a session will now be prompted to reroll their item. (Other players' rolls are not carried over though).
* Localization updates.
* Outdated version string now only shows once.

### Alpha7 changes
---
##### Bugfixes
* Fixed error on raid join or becoming Master Looter.

### Alpha6 changes
---
_Never change Git tags, #IFuckedUp_

### Alpha5 changes
---
##### Bugfixes
* *Forgot to add a locale entry.*
* *Sometimes players could report not having gear.*
* *Spellings breaking "Loot Everything".*

### Alpha4 changes
---
* Now displays the "alpha message" on each update (or first time upgrading to alpha) to ensure people doesn't get it by mistake.
* **Added** Disenchant button to voting frame (only shows when all entries are filtered)
  * *(Note: I haven't tested it with actual enchanters in the group)*
* ~~Removed~~ some unnecessary comms spam.
* Changed previous taint fix to only apply in combat.

##### Bugfixes
* *Usage option now has a default state*
* *Council members from the ML's realm added from a specific guild rank wouldn't see the voting frame. (Council is reset because of this)*
* *Autopasses didn't get filtered properly.*


### Alpha3 changes
---
* Fixed error when responding to the last item.
* More locale changes.
* Properly display version string in .toc #Notes field.
* Added a potential fix to previous versions taint.

### Alpha2 changes
---
* Wrong load order for Libs/DropDownMenu (#105)
* Was double importing libs (#104)
* Updated Libs/Lib-st due to leaked globals (#103)
* Edited some locale to a more descriptive name
