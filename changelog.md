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
