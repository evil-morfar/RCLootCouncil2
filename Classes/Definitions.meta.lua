--- @meta Various development definitions

---@class InstanceDataSnapshot
---@field instanceName string
---@field difficultyID number
---@field difficultyName string
---@field mapID number
---@field groupSize number
---@field timestamp number

---@class ItemID : number
---@class itemString : string
---@class itemLink : string


--- RCLootCouncil defined types


---@class HistoryEntry
---@field lootWon ItemLink
---@field date string Date in the format "YYYY-MM-DD", based on servertime local
---@field time string Time in the format "HH:MM:SS", based on servertime local
---@field instance string "InstanceName-DifficultyName"
---@field boss string "BossName" or "Unknown"
---@field votes integer
---@field itemReplaced1 ItemLink? Item that was replaced by the item won, if any
---@field itemReplaced2 ItemLink? Item that was replaced by the item won, if any
---@field response string Text of the winning response or reason
---@field responseID integer ID of the winning response or reason
---@field color number[] Color of the winning response or reason (r,g,b,a)
---@field class ClassInfo.classFile Class of the winner
---@field isAwardReason boolean Whether the response is an award reason
---@field difficultyID integer Difficulty ID of the instance
---@field mapID integer Map ID of the instance
---@field groupSize integer Size of the group at the time of the loot
---@field note string? Note added by the user, if any
---@field id string Unique ID of the history entry: `GetServerTime()-awardCountInSession`
---@field owner string Player who looted the item
---@field typeCode string Item typeCode, e.g. "Default". @see `RCLootCouncil:GetItemTypeCodeForItem()`
---@field iClass integer Item class, numberic value of `Enum.ItemClass`
---@field iSubClass integer Item sub-class, numeric value of `Enum.ItemSubclass`