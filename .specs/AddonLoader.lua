--- AddonLoader.lua
-- Creates an object that can load all files in a specified .toc or .xml file.
-- Lib files will be loaded as is (dofile "path"), while all other files will get ADDON_NAME and ADDON_OBJECT as arguments.
-- 'wow_api', 'wow_item_api' and 'bit' will be loaded before any other file.
-- USAGE: local Loader = loadfile (".specs/AddonLoader.lua")([debug, ADDON_NAME, ADDON_OBJECT])
--    Loader.LoadToc("something.toc") -- Loads all files in the .toc file.
--    Loader.LoadXML("something.xml") -- Loads all files in the .xml file
--    Loader.LoadArray{"file1.lua", "file2.xml"} -- Loads all files in the array. Will also load all files contained in an xml path.
-- Defaults to the values below:
local debug = select(1,...) or false
local ADDON_NAME = select(2, ...) or "RCLootCouncil"
local ADDON_OBJECT = select(3, ...) or {}

local Loader = {}

function Loader.LoadToc (file)
   local lines = Loader.lines_from(file)
   local files = {}
   for _, v in pairs(lines) do
      v = Loader.stripspaces(v)
      -- Ignore comments
      if not v:match("^##") and #v > 0 then
         local ext = Loader.GetFileExtension(v)
         if ext == ".xml" then
            local res = Loader.XmlHandler(v)
            Loader.AddTableToTable(res, files)
         elseif ext == ".lua" then
            files[#files + 1] = v
         end
      end
   end
   -- Actually load the files:
   Loader.LoadFiles(files)
end

function Loader.LoadXML(file)
   Loader.LoadFiles(Loader.XmlHandler(file, 0))
end

function Loader.LoadArray (list)
   local files = {}
   for _, file in ipairs(list) do
      local ext = Loader.GetFileExtension(file)
      if ext == ".xml" then
         Loader.AddTableToTable(Loader.XmlHandler(file), files)
      elseif ext == ".lua" then
         table.insert(files, file)
      end
   end
   Loader.LoadFiles(files)
end


function Loader.file_exists(file)
   local f = io.open(file, "rb")
   if f then f:close() end
   return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function Loader.lines_from(file)
   if not Loader.file_exists(file) then return {} end
   local lines = {}
   for line in io.lines(file) do
      lines[#lines + 1] = line
   end
   return lines
end

function Loader.GetFileExtension(url)
   return url:match("^.+(%..+)$")
end

function Loader.stripspaces (str)
   return string.gsub(str, "%s+", "")
end

function Loader.ExtractXMLLine (line)
   if line:match("^<Script") or line:match("^<Include") then
      return line:match("\"(.+)\"")
   else
      return nil
   end
end

function Loader.Log (...)
   return debug and print(...)
end

function Loader.AddTableToTable (tbl, target)
   for _,v in pairs(tbl) do
      target[#target + 1] = v
   end
end

function Loader.ReplaceXmlPathWith (xml, path)
   -- xml will look like Something\foo\bar.xml
   -- result should be: Something\foo\path
   return xml:gsub("[^\\]+$", path)
end

function Loader.XmlHandler (path, level)
   level = level or 0
   local xmllines = Loader.lines_from(path)
   local ret = {}
   Loader.Log(string.rep("\t", level),"XmlHandler", path,level)
   for x, y in pairs(xmllines) do
      y = Loader.ExtractXMLLine(Loader.stripspaces(y))
      if y then
         local ext = Loader.GetFileExtension(y)
         Loader.Log(string.rep("\t", level+1),x,y, ext)
         if ext == ".xml" then
            Loader.Log(string.rep("\t", level),"Found xml", string.rep("-", level*2 ).."->")
            if level > 0 then
               y = Loader.ReplaceXmlPathWith(path, y)
            end
               Loader.AddTableToTable(Loader.XmlHandler(y, level + 1), ret)
         elseif ext == ".lua" then
            if Loader.GetFileExtension(path) == ".xml" then
               -- We need to replace the previous .xml path with the new result
               y = Loader.ReplaceXmlPathWith(path, y)
            end
            Loader.Log(string.rep("\t", level),"Found LUA", string.rep("-", level*2 ).."->", y)
            ret[#ret + 1] = y
         end
      end
   end
   return ret
end

function Loader.LoadFiles (files)
   require("__tests/wow_api")
   require("__tests/wow_item_api")
   require "bit"
   Loader.Log "Loading files..."
   for _, file in ipairs(files) do
      Loader.Log("Loading:",file)
      if file:match("^Libs") then
         dofile(file)
      else
         loadfile(file)(ADDON_NAME,ADDON_OBJECT)
      end
   end
end

function Loader.TocParser (file)
   local lines = Loader.lines_from(file)
   local files = {}
   for _, v in pairs(lines) do
      v = Loader.stripspaces(v)
      -- Ignore comments
      if not v:match("^##") and #v > 0 then
         local ext = Loader.GetFileExtension(v)
         if ext == ".xml" then
            local res = Loader.XmlHandler(v)
            Loader.AddTableToTable(res, files)
         elseif ext == ".lua" then
            files[#files + 1] = v
         end
      end
   end
   -- Actually load the files:
   Loader.LoadFiles(files)
end

return Loader
