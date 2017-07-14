--- Contains all code required for syncronizing stuff
-- @author: Potdisc
-- 14/07/2017
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local LibDialog = LibStub("LibDialog-1.0")
local sync = {}
addon.Sync = sync

local sync_table = {}
local last_sync_time = 0

-- We want to sync with another player
function sync:SendSyncRequest(player, type, data)
   addon:DebugLog("SendSyncRequest", player, type)
   if time() - last_sync_time < 10 then -- Limit to 1 sync per 10 sec
      return addon:Print("Please wait before trying to sync again.")
   end
   last_sync_time = time()
	addon:SendCommand(player, "syncRequest", addon.playerName, type)
   sync_table[player] = { -- Store the data
      [type] = data
   }
end

-- Another player has agreed to receive our data
function sync:SyncAckReceived(player, type)
   addon:DebugLog("SyncAckReceived", player, type)
   local data = sync_table[player] and sync_table[player][type]
   if not data then
      addon:Print("Something went wrong during syncing, please try again.")
      return addon:Debug("Data wasn't queued for syncing!!!")
   end
   -- Lets see how much data we're trying to send by approximating it using the Serializer
   if addon.debug then addon:Debug(type, "Data size:", #addon:Serialize(data)/1000, "Kb") end
   -- We're ready to send
   addon:SendCommand(player, "sync", addon.playerName, type, data)
   -- clear the table:
   data = nil
   addon:Debug("Done syncing", type, "with", player)
end

function sync:SyncNackReceived(player, type)
   addon:DebugLog("SyncNackReceived", player, type)
   -- Delete them from table
   sync_table[player] = nil
   addon:Print(format("%s declined your sync request.", player))
end

-- We've received a request to sync with another player
function sync:SyncRequestReceived(sender, type)
   addon:DebugLog("SyncRequestReceived", sender, type)
	if type == "settings" or
      type == "history" then
		LibDialog:Spawn("RCLOOTCOUNCIL_SYNC_REQUEST", {sender, type})
	else
		addon:Debug("Unsupported SyncRequestReceived:", type, "from", sender)
	end
end

function sync.OnSyncAccept(_, data)
   local sender, type = unpack(data)
   addon:DebugLog("OnSyncAccept", sender, type)
   addon:SendCommand(sender, "syncAck", addon.playerName, type)
end

function sync.OnSyncDeclined(_, data)
   local sender, type = unpack(data)
   addon:DebugLog("OnSyncDeclined", sender, type)
   addon:SendCommand(sender, "syncNack", addon.playerName, type)
end

-- We're receiving data from another player
-- data to send: addon.db.profile
-- data to send: self:EscapeItemLink(addon:Serialize(lootDB))
function sync:SyncDataReceived(sender, type, data)
   addon:DebugLog("SyncDataReceived", sender, type)
   if type == "settings" then
      addon.db.profile = data
   elseif type == "history" then
      addon:GetActiveModule("history"):ImportHistory(data)
   else
      return addon:Debug("Unsupported SyncDataReceived", type, "from", sender)
   end
   addon:Print("Successfully received ", type, "from", sender)
end
