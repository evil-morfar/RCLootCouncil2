# v3.15.2

## Bugfixes

- *Prevented "Explosive Hearthstone" from being automatically looted, as it cannot be traded.*

# v3.15.1

## Bugfixes

- *Fixed history date selector not sorting properly.*
- *Fixed date/time issue with certain history exports.*
- *Fixed issue with updating during a session breaking the loot history.*

# 3.15.0

Updated for patch 11.1.0.

## Changes

Added trinkets and tokens from new raid and dungeon.

Added `servertime` field to JSON export.

### Time handling

All time stamps are now based off server time instead of the group leader's local time.

- This will reduce accuracy as local server time is only updated once a minute.

All date formats now follows the ISO standard of `YYYY/MM/DD`.

- This includes importing - they must now be of the new format. *Note: if you have a backup in either `Player Export` or `CSV` (with `id` field) those will import into the new format.*
- Existing history will be updated to the new format, but the timestamps will not, and are assumed to be server time going forwards.

Voting Frame more info tooltip showing time since award has been changed to just show the number of days.

### Bugfixes

- *Council wouldn't always be registered properly.*

# 3.14.5

## Changes

Updated for patch 11.0.7.

### Request rolls

Asking a candidate to roll will now change their roll to "?" when they have received the request.

# 3.14.4

## Changes

## Bugfixes

- *Fixed Group Leader chat command help not being printed without having other modules enabled (Curse#546).*
- *Moving a frame the exact moment it's minimized will no longer make it stuck to the mouse.*
- *Clicking the "Disenchant" button in the voting frame could use values from hidden award reasons.*

# 3.14.3

## Changes

### More info tooltips

Now properly tracks responses from item groups other than default and tier token.

Responses are now sorted by number of awards.

## Bugfixes

- *Fixed broken sorting in Voting Frame.*

# 3.14.2

## Changes

Updated for patch 11.0.5.

Added trinkets from Blackrock Depths.

## Bugfixes

- *Fixed Voting Frame sometimes breaking when extending a session while there's changes in group composition.*

# 3.14.1

## Changes

### Rolls

Requesting rolls now only resets the roll for the people requested.

Auto passing when requesting rolls will now show a '-' in the roll column, like when passing the roll.

## Bugfixes

- *Fixed wrong specs autopassing a few trinkets.*

# 3.14.0

## Changes

### Buttons and Responses

Added button group for Catalyst items. (#257)

Removed "Azerite" button group.

### Group Loot Status

The version checker now includes group loot status for each player. Use this to check if RCLootCouncil will do group loot for everyone. Won't work for players using versions older than 3.13.3.

The tooltip includes specific information as to why it won't do group loot, such as being in a non-guild group without disabling "Guild Groups Only".

### Options and Commands

Added option to not store personal loot in the history.

Added new command `/rc session` - opens the session frame if you're the group leader.

Added new command `/rc stop` - inverse of start, stops handling loot.

Reworked the chat command help section (`/rc` or `/rc help`) - now shows commands useable at the moment. Group leader has a seperate section for group leader only commands. Also added description for the commands that missed them.

### Profile Export & Sync

Module specific options (show more info, show tooltip, filters, etc) are no longer included in exported/synced profiles.

### Voting Frame

Hovering a candidate's class/spec icon will now show the name of their current class and spec.

## Bugfixes

- *WuE items will no longer register as BoEs (despite GetItemInfo saying so).*
- *Fixed Conniver's Badges being incorrectly shown as trinket slot.*
- *Changing roles should now properly update the column in the voting frame.*
- *Changing leader would not always activate RCLootCouncil properly.*

# 3.13.3

## Changes

## Bugfixes

- *Addon should now always properly initialize when reloading as the ML.*
- *No longer prints the reroll message for candidates not being asked to reroll.*

# 3.13.2

## Changes

More info frames is no longer clamped to screen.

## Bugfixes

- *Selecting an item for "Award Later" during a session will now properly count the item as awarded.*
- *Tier token items are now properly registered as such for usage in more info tooltips.*
- *BoE's are recognized once again.*

# 3.13.1

## Changes

Updated for patch 11.0.2.

### History Export

Added a new export option for Google Sheets and English versions of Excel that uses ";" as formula delimiter.

Changed default export to Player Export.

### Winners of item in Voting Frame

The more info tooltip in the votingframe nows shows previous winners of the selected item.
Their response and the item level of the version of the item they received is also shown there.

## Bugfixes

- *Enabling "Observe" now more reliably prepares the voting frame for the next session.*

# 3.13.0

## Changes

Updated for the War Within prepatch (11.0.0).

### Comms optimization

Optimized random rolls from 1 message per session to approximately 1 message per 10 sessions. You can once again safely use the `"Add Rolls"` option.

Optimized Rerolls and Request Rolls from 1-2 message(s) per candidate per session to 1-2 messages per request.

Both are fully backwards compatible (uses old system for those that haven't updated).

### Look and Feel

Reviewed all addon prints/displays of player names and added class icon/colors where appropiate.

Added highlight and push textures to several buttons that didn't have them.

Added help tooltip and hover effect when hovering frame titles.

Made frame scaling more granular.

Prevented more info frames from getting too small/large.

All import/export frames are now closeable with "Esc".

When awarding an item, voting frame now switches to the *next* unawarded item instead of the *first*.

Reviewed all UI layouts and margins. Updated all inconsistencies for a more unified look.

Frame position and size settings has been reset due to these changes.

### Loot Frame

Loot Frame will now always "shrink" upwards when rolling on items, no matter where it's positioned.

Integrated timeout bar with background and refreshed layout.

The new timeout bar will flash when there's 5 seconds to timeout - can be disabled in the options menu (`Timeout Flash`).

### Profile sharing

It's now possible to export and import profile settings. This new feature is located at the "Profiles" tab in the options menu (`/rc profile`).

### TradeUI

TradeUI will now popup automatically after reloads/relogs if there's items to trade.

Removing the last item in the list will now close the window.

## Bugfixes

- *Player names in voting frame vote status tooltip is again shown with class colors.*
- *Loot- and Voting frame item type text now only shows subtype for most miscellaneous items.*
- *Voting Frame More info now correctly updates when changing sessions while shown.*
- *More info frames now minimizes with their parent frame.*
- *Item owner information is again sent when reannouncing loot.*
- *In loot history filter: deselecting a single selected class now resets the filter.*

# 3.12.1

## Bugfixes

- *Fixed tertiary stats not being shown in loot/voting frame.*
- *Miscellaneous items is now listed as their subtype instead of "armor token" (unless their subtype is junk) in voting frame more info.*
- *Setting "Require Note" on a button that has default text now actually makes said note required.*
- *Fixed players guild ranks occasionally dissappearing.*

# 3.12.0

## Changes

Updated for patch 10.2.7.

### Comms throttle

Voting Frame data is no longer being sent when reloading/reconnecting.

`Add Rolls` option has been reset to `false` due to the extra comms required for it.

## Bugfixes

- *Fixed `/rc council` not properly opening council menu.*


# 3.11.1

## Changes

Added support for tier tokens from Awakened Raids.

Added Antique Bronze Bullion to the ignore list.

# 3.11.0

## Changes

Updated for patch 10.2.6.

### Minimize in combat

Loot/Voting frames triggered while in combat will now automatically be minimized if `Minimize in combat` is enabled.

### Group updates

People joining late, or just before a pull now has a much higher chance of receiving required data from the group leader, which should fix most instances of those people not autopassing group loot.

### Loot Status

Removed - hasn't been used since group loot was introduced, and was essentially just using up comms bandwidth.

### Weapons auto pass

By default, RCLootCouncil will now auto pass weapons that you either can't use, or doesn't have the appropiate main stat for your class (e.g. agility weapons for priests). It can be turned off in the response options if needed.

## Bugfixes

- *Fixed issue with importing corrupt history data.*
- *Fixed formatting of item status string for items with extended info such as 'Shadowflame Suffused'.*

# 3.10.5

## Changes

Updated for patch 10.2.5.

## Bugfixes

- *Fixed an issue with council related comms that could end up spamming the group leader.*
- *Fixed issue with `/rc start` not always working as intended.*

# 3.10.4

## Changes

Holy Paladins and Mistweavers no longer autopass on Belor'relos, the Suncaller.

RCLootCouncil will no longer group loot legendary items automatically.

Chest pieces with `INVTYPE_ROBE` are now correctly grouped with chests in regards to buttons and responses (#246).

# 3.10.3

## Changes

### Group Loot

Hiding default group loot frames will now also hide the group loot container (would leave behind an invisible frame that intercepted clicks).

### TradeUI

Fixed error when TradeUI being opened in combat.

# 3.10.2

## Changes

### Group Loot

Default WoW group loot frames is now forced hidden after being rolled on by RCLootCouncil.

### Loot History

Added a column for notes.

### Session frame

Will now be shown automatically after a cinematic if it was hidden because of it.

### TradeUI

Addons can no longer check whether people are in trade range during combat, so now the labels are yellow in combat. Clicking the yellow label will attempt to open trade.

# 3.10.1

## Changes

### Hearthstone of the Flame

Hearthstone of the Flame (bonus loot from Larodar) is now ignored by RCLootCouncil as it cannot be traded.

# 3.10.0

## Changes

### Patch 10.2

Updated for patch 10.2.
Added trinkets and tokens for the new raid.

### CSV import

Smoothened the whole experience, along with some quality of life changes:

- `owner` no longer needs to be set when importing csv data.
- trailing spaces and/or tabs in both header and data are now ignored.
- fixed issue in line validation making error messages more useful.

### Observe mode

When using observe mode and having hide votes enabled, non-council members can now see votes, instead of hide votes requiering a vote to be cast before showing votes.

## Bugfixes

- *Trying to import tsv data will now show the correct error message instead of throwing an error.*

# 3.9.3

## Bugfixes

- *Fixed `nil` errors causing error handler to throw errors.*

# 3.9.2

## Changes

Updated for patch 10.1.7

# 3.9.1

## Changes

### Voting Frame session buttons

Selecting an awarded session now shows a yellow checkmark instead of nothing on the session button.

## Bugfixes

- *Fixed issue with random rolls not sorting properly (#240).*
- *History now records the correct response instead of "Awarded" when awarding multiple copies of the same item to a player.*

# 3.9.0

## Changes

Updated for patch 10.1.5

### Roll column

Switched to a new system that's much lighter on comms for propergating the automatic random rolls. This should fix the issues some people have with the last few sessions not receiving random rolls.

This change is not backwards compatible, once the ML upgrades, everyone will have to in order to see the random rolls.

## Bugfixes

- *Fixed issues with detecting remaining trade time on clients with russian locale.*
- *Fixed issue preventing the list of council members that has/still has to vote from showing.*


# 3.8.2

## Changes

### Group Loot

Now rolls transmog when that's the only option for the group leader.

### Transmog autopass

Added a new option that allows you to not auto pass on items that's transmogable for you - just uncheck "Auto Pass Transmog".
The accompanying option "Auto Pass Transmog Source" further refines it by allowing auto passes if you've already collected the transmog.

Credits to [Urtgard](https://github.com/Urtgard) for creating this.

### Void-Touched Curio

Context tokens are now counted as being part of the armor token group.


# 3.8.1

## Changes

Uncommon quality (greens) items are now ignored.

# 3.8.0

## Changes

Updated for patch 10.1.0.

Added token and trinket data from Aberrus the Shadowed Crucible

### Require note per response

It's now possible to require notes per specific response - check `Buttons and Response` options and check `Require Notes` for each response you want raiders to submit a note with.  
Old require notes option has been removed as part of this change.

Note: This will not work for people with older versions.

### Void-Touched Curio

Removed from blacklist.

## Bugfixes

- *Fixed occasional inability to trade multiple identical items.*
- *`/rc fulltest` should once again pull items from the latest raid.*


# 3.7.1

Updated for patch 10.0.7.

## Bugfixes

- *Fixed wrong text used for "Guild Groups Only" setting.*

# 3.7.0

## Changes

Updated for patch 10.0.5

### Voting Frame More Info

Now shows the equip location of recently awarded items.

### Export items in session

Added new chat command `/rc export` which will export a csv formatted list of the items currently in session.

### Button Groups

Added button groups for mounts, bags and recipies.

## Bugfixes

- *Items can now again be automatically added to a trade with a player from another realm.*
- *Fixed issue with items some times being added twice.*

# 3.6.7

## Bugfixes

- *Fixed error when changing a response in the history to a non default category response.*
- *Added potential fix for ElvUI loot frame issues.*

# 3.6.6

## Changes

### Group Loot

When being the Group Leader, RCLootCouncil will now need on items that can be needed instead of always greeding.

## Bugfixes

- *Various cleanup of minor errors and more logging for future ones.*
- *Closing "Keep/Trade" pop-up with escape would cause an error (#227).*
- *Fixed issue with the new group loot being reported as "personalloot" disabling the addon if the ML reloads (#227).*
- *Automatic group loot warning didn't show due to the above.*

# 3.6.5

## Changes

### Group Loot

`Guild Groups Only` option reenabled. When enabled (default) RCLootCouncil will only automatically pass on group loot when you're in a "Guild Group", i.e. group has at least 80% guild members in raids or 60% in parties.

## Bugfixes

- *Date selection in delete history options now again shows the chosen value.*
- *Fixed invisible header on TradeUI obstructing the title frame, making it unclickable.*
- *ML module could potentially enable itself even after clicking "no" to usage pop-up. (#224)*

# 3.6.4

## Changes

- *Reverted "Guild Groups Only" addition as it had potential to break horribly.*

# v3.6.3

## Changes

Added option for toggling 'Escape' closing frames.

### Group Loot

By default, RCLootCouncil will now no longer auto pass group loot if the group leader is not a member of your guild. You can override this behavior with the "Guild Groups Only" option.

## Bugfixes

- *Fixed issue with realm name not available upon login, affecting specifc comms.*

# v3.6.2

## Changes

### Group Loot

Changed logic behind automatically adding loot to a session. Should result in a more reliable experience.

## Bugfixes

- *Warning about Auto Group Loot will now only be displayed when actually using group loot.*
- *Fixed issue with auto trade. (#223)*
- *Fixed realm name issue related to playing cross realm on realms containing '-'.(Curse#512).*

# v3.6.1

## Changes

Added `/rc start` command which either shows the usage pop-up or starts the addon depending on your usage settings.

## Bugfixes

- *Fixed potential nil error (Classic#46, CurseClassic#170).*
- *Fixed issue preventing the addon from adding items to the trade window.*
- *Fixed issue with players joining after the group leader wouldn't auto pass on group loot.*

# v3.6.0

## Changes

### Esc closing frames

All RCLootCouncil frames except `Loot-` and `Voting Frame` can now be closed by pressing `Escape`.

### Group Loot

Added new option `Auto Group Loot` (enabled by default).
When enabled, this will cause all group members (with RCLootCouncil installed, of course) to automatically pass on group loot, and have you (the group leader) greed on it. This will cause all items to end up in your bags, and start a session (depending on your settings) with said items.

Usage options has been reset and Personal Loot choices removed.

### TradeUI and ItemStorage

Made several fixes to the ItemStorage which should eliminate outstanding issues with wrong warnings about trade timers and items staying in the award later list forever.

Furthermore added a delete button to the TradeUI allowing one to remove items from it.

## Bugfixes

- *Enabling settings that should be synced with the group wouldn't always be synced immediately.*

- *Starting a test session too quickly now prints a message starting to wait a bit rather than causing errors (Curse#510).*
- *Test versions will no longer be listed as newer if you're not running a test version yourself.*
- *Updated libraries - fixes error when opening options menu.*

# v3.5.1

## Changes

Updated for prepatch phase 2.

### Checkmark

Awarded items now also has a checkmark overlay on their session button.

## Bugfixes

- *Fixed error when clicking buttons in the options menu.*

# v3.5.0

## Changes

### Dragonflight

Updated for Dragonflight prepatch.

Added token and trinket data.

Added auto pass for Evokers.

### Add all tradeable items to session

It's now possible to add all items from your bags with a trade timer on them to a session at once.
Simply use `/rc add bags` or `/rc add all` to do so. You must obviously still be ML/group leader to do so, and have the addon active.

### TradeUI

Updated logic being ItemStorage when trading items. It should now properly account for whom you're trading items to, which resolves issues with the "wrong" item being removed after trading with someone.

Last I checked there were still some issues with detecting the trade target (not sure I can do anything about it). The above will only work if trade target is detected properly, i.e. if the addon can add items to the trade window automatically.

### Group Loot

Addon now fully supports group loot. In this first iteration it more or less works similar to personal loot - although you may come across needing to manually add items (`/rc add [item]`). This will be expanding upon and more fletched out in the coming weeks.

### Other

Added `itemName` to JSON export (CurseClassic#137).


## Bugfixes

- *Frames will no longer intercept mouse scrolls when hidden (CurseClassic#181).*


# v3.4.0

## Changes

Updated for patch 9.2.7.

Non-tradeable items that's ignored or blacklisted are no longer recorded in the loot history (#210).

Added option for restoring `/rc` to its ready check functionality (#215, Curse#495).

### Dev

- *Added itemLink to `RCMLAwardSuccess` and `RCMLAwardFailed` AceEvents.*

## Bugfixes

- *Fixed issue with Auto Award BoE list. (Curse#500)*
- *Fixed occasional missing data error. (Curse#503)*
- *Fixed hyperlink formats in TSV exports - thanks to Yttrium-tYcLief (#214).*
- *Added `id` to json export (Classic#43).*
- *Award Later items now remembers which boss they where dropped by (Classic#43).*


# v3.3.0

## Changes 

### Patch 9.2

Updated for patch 9.2.0.

Re-added Armor Token button/response group option.
Added item data for Sepulcher of the First Ones.

## Bugfixes

- *Fixed issue with `/rc remove` command.*
- *TradeUI can now handle duplicate items.*

# v3.2.1

## Changes

### Patch 9.1.5

Updated for patch 9.1.5.

## Bugfixes

- _Fixed issue with non ascii name comparisons for never seen before players._

# v3.2.0

## Changes

### Patch 9.1

Updated for patch 9.1.

Added new trinkets to the auto pass list.

### Quality of life

Frames that have been manually minimized will no longer maximize when leaving combat.

Frame z-level issues are no longer a thing. Credits to enajork (#206).

Session frame no longer has items infinitely stuck on "Waiting for item info". Items are removed if the item info isn't found.

Added trinkets from all Shadowlands dungeons and raids to the auto pass list.

### Misc

`/rc fulltest` now always uses items from the latest raid. Credits to jjholleman (#204).

`/rc add` can now only be used supported inputs (itemLinks and itemIDs).

## Bugfixes

- _Session data didn't transmit properly after a disconnect/reload during a session (Curse#475)._

# 3.1.5

## Changes

Updated toc for patch 9.0.5.

# v3.1.4

## Bugfixes

- _A candidates mainhand/offhand is now always shown in the voting frame when dealing with context tokens. (Curse#470)_
- _Hopefully fixed the remaining issues plaguing the addon the last couple of weeks. (Curse#457-472)_

# v3.1.3

## Bugfixes

- _Suppressed errors in Voting Frame. Exact cause is still unknown, and this fix while supressing errors can still lead to blank spaces in voting frame. Please report back if you're experiencing any of this. (Curse#457-465)_

# v3.1.2

## Bugfixes

- _Context tokens were unintentionally ignored._
- _Fixed errors from missing functions (Curse#453)._
- _Council should now be more reliably sent before first kill to avoid non showing voting frame for council members (Curse#456, #202)._
- _Sorting of the default buttons in the voting frame now works again. Note you may need to move buttons up/down to properly register. (#203)._

# v3.1.1

## Bugfixes

- _Fixed issue with Blizzard functions occasionally returning nil upon entering a group (Curse#452)._
- _Fixed issue related to player classes (Curse#449)._

# v3.1.0

## Changes

### Auto Awards

Auto Awards now works on a priority based list, so that you can have fallbacks in case your usual recipient is on an alt etc.

The input field is updated to handle multiple entries at once (seperated by commas and/or spaces) when ungrouped, while still listing group members when grouped.

Candidates in the list have class icons and colors added if you've seen them recently. If they're in your group but don't have the class infomation, then you probably have misspelled their name.

All stored Auto Award settings has been reset as part of the update.

### Anima

Anima is no longer registered in the voting frame or history, and any anima in the history has been removed.

## Added

### Companion Pets

Pets now have a button group.

Added option to ignore all pets when looting.

### Version Check

The version checks now shows the totals of installed versions.

## Bugfixes

- _Players' enchating level again shows up in the disenchant menu in the voting frame._
- _The list of candidates now updates much more frequently to avoid listing candidates that have left the group._
- _Fixed corrupted player caches, introduced in v3.0.2, leading to a total breakdown (Curse#443-448 + #201)._

# v3.0.2

## Bugfixes

- _Group version checks could break the addon._
- _Cancelling the session frame while a session was running led to unexpected behaviors._
- _Fixed issue with guild ranks that could break the voting frame._

# v3.0.1

## Changes

Updated for patch 9.0.2.

### Version Check

Version check now again works cross realm.  
Players using older versions will have unexpected entries added if someone with this version performs a version check - that was unavoidable to make this work, but doesn't happen once you've upgraded.

## Bugfixes

- _The version checker wouldn't always show installed modules._
- _Fixed issues with adding cross realm council members leading to the entire addon to break._
- _Having an outdated version will no longer produce an error and correctly show a message prompting you to upgrade._

### Dev

- _Added recipient at index 6 for `VERSION.fr` comms._

# v3.0.0

_v3.0 is not backwards compatible with any older versions, including most of its beta versions._

## Changes

v3.0 marks a development landmark more than 2 years in the making.  
It consists of more than 10k line changes, most of which are background stuff you won't be seeing, with the goal of providing a solid foundation for the future.
Ideally you shouldn't _see_ any major changes, but everything should _feel_ faster and more responsive.  
Below is a list of the most relevant changes.

### Updated for Shadowlands

- Deprecated API calls have been removed, and all addon code updated for the changes introduced in Shadowlands.
- Shadowlands related dates have been added to the History Patch Mass delete tool.

#### Button Groups

- Added a new response group for Anima Beads and Spherules - a new Main/Off-hand token in Shadowlands.
- Removed the groups for Corruption.

### Comms overhaul

All comms have been updated with a new system compressing all messages sent.  
Most comms have been optimized resulting in up to an 90% decrease in comms usage, i.e. everything is faster.  
This change breaks backwards compatiblity with 2.x versions.

### Options Menu

The options menu have been slimmed down, some toggles have had a name switch and some options moved around.

#### Removed

The following have been removed and are now always enabled:

- Alt-click looting
- Loot Everything
- Notes
- Save Bonus Rolls
- Autoloot All BoE (merged with `Auto Add BoEs`)

#### Renamed

The following have had a name and description update to better explain what they do:

- Auto Start > Skip Session Frame
- Auto Loot > Auto Add Items
- Autoloot BoE > Auto Add BoE's

### Testing

v3.0 is developed with a philosophy of writing automated tests for all new code.  
This should result in a lot fewer bugs in new releases.  
The internal log has also been updated for better identifying issues.

### Removed

- Corruption column.
- `winners` command - has been handled by the TradeUI for a long time.

### Dev

- All comms have updated prefixes, commands, and handlers. Refer to `/Classes/Services/Comms.lua`.
- Old way of logging is removed - see `/Classes/Utils/Log.lua` for new implementation.
- Many structures now have their own files and classes. See `/Classes`.
- Classes are loaded with `RCLootCouncil.Require`. See `/Classes/Core.lua` for details.
- Removed all references to `candidates`. It's now based on `Player` class, and group members can be found with `RCLootCouncil.candidatesInGroup` and `RCLootCouncil:GroupIterator()`.
- `RCLootCouncil.council` removed. `db.profile.council` now stores GUIDs, which combined with `Data.Player` and `Data.Council` now makes up a council.

## Bugfixes

- _The completion indicator in the Synchronizer no longer disappears._
