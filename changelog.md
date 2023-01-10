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
