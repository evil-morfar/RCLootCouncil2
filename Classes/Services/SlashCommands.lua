--- SlashCommands.lua Class for handling slash commands.
-- @author Potdisc
-- Create date: 05/04/2020

-- REVIEW Not finished!

--- @type RCLootCouncil
local addon = select(2, ...)
local SlashCommands = addon.Init("Services.SlashCommands")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local Subject = addon.Require("rx.Subject")
local Log = addon.Require("Utils.Log")

local private = {
   AceConsole = {},
   subjects = {},
   commands = {}
}

LibStub("AceConsole-3.0"):Embed(private.AceConsole)

function SlashCommands:OnInitialize ()
   private.AceConsole:RegisterChatCommand("rc")
   private.AceConsole:RegisterChatCommand("rclc")
   private.AceConsole:RegisterChatCommand("rclootcouncil")
end

--- Subscribe to a chat command.
-- The commands should be given as an array for registering multiple commands to the same function.
-- @param cmds Array of commands that should be registered.
-- @param cmdDesc An optional string that describes the command.
-- @param helpText The text shown in the help section.
-- @param func The function that will be executed whenever the command is encountered. It's called with all console args as arguments.
-- @return The subsription of the command.
function SlashCommands:Subscribe (cmds, cmdDesc, helpText, func)
   assert(type(cmds) == "table" and type(cmds[1]) == "string", "'cmds' must be an array with at least one string.")
   assert(type(func) == "function", "'func' must be a function.")
   private:RegisterCommand(cmds, cmdDesc, helpText)
   return private:SubjectHelper(cmds):subsribe(func)
end

--- Show the help text for the commands.
function SlashCommands:ShowHelp ()
   -- Print version info
   if addon.tVersion then
      print(format(L["chat tVersion string"], addon.version, addon.tVersion))
   else
      print(format(L["chat version String"], addon.version))
   end

   for _, v in ipairs(private.commands) do
      print "" -- spacer
      if v.module.version and v.module.tVersion then
         print(v.module.baseName, "|cFFFFA500", v.module.version, v.module.tVersion)
      elseif v.module.version then
         print(v.module.baseName, "|cFFFFA500", v.module.version)
      else
         print(v.module.baseName, "|cFFFFA500", GetAddOnMetadata(v.module.baseName, "Version"))
      end
      if v.cmd then
         print("|cff20a200", v.cmd, "|r:", v.desc)
      else
         print(v.desc) -- For backwards compatibility
      end
   end
   if addon.debug then private:PrintDebugHelp() end
end


function private:RegisterCommand (cmds, cmdDesc, helpText)
   for _, cmd in ipairs(cmds) do
      if not self.commands[cmd] then
         self.commands[cmd] = {
            cmd = cmd,
            cmdDesc = cmdDesc,
            helpText = helpText
         }
      end
   end
end

function private:SubjectHelper(cmds)
   if not self.subjects[cmds[1]] then
      self.subjects[cmds[1]] = Subject.create()
      for i = 2, #cmds do
         self.subjects[cmds[i]] = self.subject[cmds[1]]
      end
   end
   return self.subjects[cmds[1]]
end
