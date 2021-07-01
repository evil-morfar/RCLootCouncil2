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

* *Session data didn't transmit properly after a disconnect/reload during a session (Curse#475).*

# 3.1.5

## Changes

Updated toc for patch 9.0.5.

# v3.1.4

## Bugfixes

* *A candidates mainhand/offhand is now always shown in the voting frame when dealing with context tokens. (Curse#470)*
* *Hopefully fixed the remaining issues plaguing the addon the last couple of weeks. (Curse#457-472)*

# v3.1.3

## Bugfixes

* *Suppressed errors in Voting Frame. Exact cause is still unknown, and this fix while supressing errors can still lead to blank spaces in voting frame. Please report back if you're experiencing any of this. (Curse#457-465)*

# v3.1.2

## Bugfixes

* *Context tokens were unintentionally ignored.*
* *Fixed errors from missing functions (Curse#453).*
* *Council should now be more reliably sent before first kill to avoid non showing voting frame for council members (Curse#456, #202).*
* *Sorting of the default buttons in the voting frame now works again. Note you may need to move buttons up/down to properly register. (#203).*

# v3.1.1

## Bugfixes

* *Fixed issue with Blizzard functions occasionally returning nil upon entering a group (Curse#452).*
* *Fixed issue related to player classes (Curse#449).*

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

* *Players' enchating level again shows up in the disenchant menu in the voting frame.*
* *The list of candidates now updates much more frequently to avoid listing candidates that have left the group.*
* *Fixed corrupted player caches, introduced in v3.0.2, leading to a total breakdown (Curse#443-448 + #201).*

# v3.0.2

## Bugfixes

* *Group version checks could break the addon.*
* *Cancelling the session frame while a session was running led to unexpected behaviors.*
* *Fixed issue with guild ranks that could break the voting frame.*

# v3.0.1

## Changes

Updated for patch 9.0.2.

### Version Check

Version check now again works cross realm.  
Players using older versions will have unexpected entries added if someone with this version performs a version check - that was unavoidable to make this work, but doesn't happen once you've upgraded.

## Bugfixes

* *The version checker wouldn't always show installed modules.*
* *Fixed issues with adding cross realm council members leading to the entire addon to break.*
* *Having an outdated version will no longer produce an error and correctly show a message prompting you to upgrade.*

### Dev

* *Added recipient at index 6 for `VERSION.fr` comms.*

# v3.0.0

*v3.0 is not backwards compatible with any older versions, including most of its beta versions.*

## Changes

v3.0 marks a development landmark more than 2 years in the making.  
It consists of more than 10k line changes, most of which are background stuff you won't be seeing, with the goal of providing a solid foundation for the future.
Ideally you shouldn't *see* any major changes, but everything should *feel* faster and more responsive.  
Below is a list of the most relevant changes.

### Updated for Shadowlands

* Deprecated API calls have been removed, and all addon code updated for the changes introduced in Shadowlands.
* Shadowlands related dates have been added to the History Patch Mass delete tool.

#### Button Groups

* Added a new response group for Anima Beads and Spherules - a new Main/Off-hand token in Shadowlands.  
* Removed the groups for Corruption.


### Comms overhaul

All comms have been updated with a new system compressing all messages sent.  
Most comms have been optimized resulting in up to an 90% decrease in comms usage, i.e. everything is faster.  
This change breaks backwards compatiblity with 2.x versions.

### Options Menu

The options menu have been slimmed down, some toggles have had a name switch and some options moved around.

#### Removed

The following have been removed and are now always enabled:
* Alt-click looting
* Loot Everything
* Notes
* Save Bonus Rolls
* Autoloot All BoE (merged with `Auto Add BoEs`)

#### Renamed

The following have had a name and description update to better explain what they do:
* Auto Start > Skip Session Frame
* Auto Loot > Auto Add Items
* Autoloot BoE > Auto Add BoE's

### Testing

v3.0 is developed with a philosophy of writing automated tests for all new code.  
This should result in a lot fewer bugs in new releases.  
The internal log has also been updated for better identifying issues.

### Removed

* Corruption column.  
* `winners` command - has been handled by the TradeUI for a long time.

### Dev

* All comms have updated prefixes, commands, and handlers. Refer to `/Classes/Services/Comms.lua`.
* Old way of logging is removed - see `/Classes/Utils/Log.lua` for new implementation.
* Many structures now have their own files and classes. See `/Classes`.
* Classes are loaded with `RCLootCouncil.Require`. See `/Classes/Core.lua` for details.
* Removed all references to `candidates`. It's now based on `Player` class, and group members can be found with `RCLootCouncil.candidatesInGroup` and `RCLootCouncil:GroupIterator()`.
* `RCLootCouncil.council` removed. `db.profile.council` now stores GUIDs, which combined with `Data.Player` and `Data.Council` now makes up a council.

## Bugfixes

* *The completion indicator in the Synchronizer no longer disappears.*