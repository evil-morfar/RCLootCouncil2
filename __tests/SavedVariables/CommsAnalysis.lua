local Analysis = {}
dofile "__tests/wow_api.lua"

local function RunAnalysis()
	dofile "__tests/SavedVariables/sv_to_process.lua"
	local comms = Analysis:ExtractCommsLinesFromSV(_G.RCLootCouncilDB["global"]["log"])
	local commsAnalyzed = Analysis:AnalyzeComms(comms)
	commsAnalyzed = Analysis:PerformStatistics(commsAnalyzed)
	Analysis:PrintResults(commsAnalyzed)
	local commsAnalyzed2 = Analysis:AnalyzeComms(comms, true)
	commsAnalyzed2 = Analysis:PerformStatistics(commsAnalyzed2)
	Analysis:PrintResults(commsAnalyzed2)
end

---@param sv string[]
---@return string[]
function Analysis:ExtractCommsLinesFromSV(sv)
	-- "<20:49:32> <Comm>		^1^Scouncil_request^T^t^^	WHISPER	Denzema-TarrenMill", -- [10]
	local ret = {}
	for _, v in ipairs(sv) do
		if (v:find("<Comm>")) then
			tinsert(ret, v:match("(%^1.+%^%^)"))
		end
	end
	return ret
end

---@alias AnalyzedComms table<string, number[]>

---@param comms string[]
---@return AnalyzedComms
function Analysis:AnalyzeComms(comms, useCompressed)
	local ret = {}
	--- @param line string
	local function ExtractCommand(line)
		return line:match("%^1%^S(.-)%^")
	end
	dofile("Libs/LibStub/LibStub.lua")
	dofile("Libs/LibDeflate/LibDeflate.lua")
	local LibDef = LibStub("LibDeflate")
	local compressLvl = { level = 3, }
	for i, v in ipairs(comms) do
		local cmd = ExtractCommand(v)
		if not ret[cmd] then ret[cmd] = {} end
		tinsert(ret[cmd],
			useCompressed and #LibDef:EncodeForWoWAddonChannel(LibDef:CompressDeflate(v, compressLvl)) or #v)
	end

	return ret
end

---@alias AnalysisResult table<int, {min:number,name:string, max:number, average:number, count:int}>

---@param comms AnalyzedComms
---@return AnalysisResult
function Analysis:PerformStatistics(comms)
	local ret = {}
	---@param t number[]
	---@param max boolean
	local function minMax(t, max)
		local min = max and 0 or math.huge
		for _, v in ipairs(t) do
			if (max and v > min) or (not max and v < min) then min = v end
		end
		return min
	end

	---@param t number[]
	local function average(t)
		local num = 0
		for _, v in ipairs(t) do
			num = num + v
		end
		return num / #t
	end

	for i, v in pairs(comms) do
		tinsert(ret, {
			name = i,
			min = minMax(v, false),
			max = minMax(v, true),
			average = average(v),
			count = #v,
		})
	end
	table.sort(ret, function(a, b)
		return a.count > b.count
	end)
	return ret
end

---@param analysis AnalysisResult
function Analysis:PrintResults(analysis)
	print(string.format("%-17s count  min \t max \t average msg \t p.msg", "name"))
	print "---------------------------------------------------------------"
	local totals = { count = 0, min = 0, max = 0, average = 0, msg = 0, pmsg = 0, }
	for _, v in ipairs(analysis) do
		local msg = v.average / 255
		local pmsg = 1 / msg
		print(string.format("%-17s %d \t %d \t %d \t %d \t %.2f \t %.2f", v.name, v.count, v.min, v.max, v.average,
			msg, pmsg))
		totals.count = totals.count + v.count
		totals.min = totals.min + v.min * v.count
		totals.max = totals.max + v.max * v.count
		totals.average = totals.average + v.average * v.count
		totals.msg = totals.msg + msg * v.count
		totals.pmsg = totals.pmsg + pmsg * v.count
	end
	print "---------------------------------------------------------------"
	print(string.format("Total: \t\t%d \t%.2f \t%.2f \t%.2f \t%.2f \t%.2f",
		totals.count,
		totals.min/totals.count,
		totals.max / totals.count,
		totals.average/totals.count,
		totals.msg / totals.count,
		totals.pmsg / totals.count))
end

RunAnalysis()
