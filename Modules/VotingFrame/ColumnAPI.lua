--- API for manipulating the Voting Frame columns.

--- @type RCLootCouncil
local addon = select(2, ...)
--- @class RCVotingFrame
local RCVotingFrame = addon:GetModule("RCVotingFrame")
local private = {}

---@class ColumnSpec
---@field colName string Unique name of column.
---@field name string lib-st header name
---@field width number column width
---@field sortnext string|number?	lib-st sort next. A string value (indicating column name) will be auto converted to it's index
---@field sortnextRef string|number? internal reference to target sortnext
---@field defaultsort number?	lib-st default sort
---@field comparesort function?	lib-st compare sort
---@field align string?	lib-st align
---@field DoCellUpdate function? lib-st DoCellUpdate

--- Returns the column definition for a given id, name, or index.
--- @param nameOrIndex string|number The column id/name or numeric index.
--- @return ColumnSpec? #The matching column definition.
function RCVotingFrame:GetColumn(nameOrIndex)
	local index = self:GetColumnIndex(nameOrIndex)
	if index then
		return self.scrollCols[index]
	end
end

--- @deprecated
--- Use [GetColumnIndex](lua://RCVotingFrame.GetColumnIndex) instead
function RCVotingFrame:GetColumnIndexFromName(name)
	return self:GetColumnIndex(name)
end

--- Returns the current index for a column id, name, or numeric position.
--- @param nameOrIndex string|number The column id/name or numeric index.
--- @return number? #The matching index in the current column list.
function RCVotingFrame:GetColumnIndex(nameOrIndex)
	if type(nameOrIndex) == "number" then
		return self.scrollCols and self.scrollCols[nameOrIndex] and nameOrIndex or nil
	end
	if type(nameOrIndex) == "string" then
		for i, col in ipairs(self.scrollCols or {}) do
			if col.colName == nameOrIndex then
				return i
			end
		end
	end
end

--- Errors if a column with the requested name already exists in the current layout.
--- @internal
---@param name string Column name to check for
function RCVotingFrame:CheckColNameUniqueness(name)
	for i, col in ipairs(self.scrollCols or {}) do
		if col.colName == name then
			error(format("Column '%s' already exists at index %d", name, i), 2)
		end
	end
end

--- Inserts a new column into the layout at the requested position.
--- If this column causes circular sorting, it's still added with nil sortnext.
--- @param spec ColumnSpec The column definition to insert.
--- @param target string|number? The target column or index for relative placement.
--- @param position "before"|"after"? One of "before", "after", or nil for append behavior.
--- @return ColumnSpec #The inserted column definition.
function RCVotingFrame:AddColumn(spec, target, position)
	assert(spec, "Column spec is required")
	assert(spec.colName, "Column name is required")
	addon.Log:D("AddColumn", spec.colName, target, position)
	self:CheckColNameUniqueness(spec.colName)
	target = private:ResolveTarget(self.scrollCols, target)
	local clone = self:CloneColumnSpecs({ spec, })[1]
	private:InsertColumn(self.scrollCols, clone, target, position)
	self:RefreshColumnLayout()
	return clone
end

--- Removes a column from the current layout.
--- @param nameOrIndex string|number The column id/name or numeric index to remove.
--- @return ColumnSpec? #The removed column definition.
function RCVotingFrame:RemoveColumn(nameOrIndex)
	local removedCol, removedIndex
	if type(nameOrIndex) == "number" then
		removedIndex = nameOrIndex
		removedCol = tremove(self.scrollCols, nameOrIndex)
	else
		removedIndex = self:GetColumnIndex(nameOrIndex)
		assert(removedIndex, "ID is not a valid column name")
		removedCol = tremove(self.scrollCols, removedIndex)
	end
	if removedCol then
		addon.Log:D("RemoveColumn", removedCol.colName)
		self:RefreshColumnLayout()
		return removedCol
	end
end

--- Moves an existing column to a new position in the layout.
--- @param nameOrIndex string|number The column id/name or numeric index to move.
--- @param target string|number? The destination column or index for relative placement.
--- @param position "before"|"after"? One of "before", "after", or nil for append behavior.
--- @return ColumnSpec? #The moved column definition.
function RCVotingFrame:MoveColumn(nameOrIndex, target, position)
	local currentIndex = self:GetColumnIndex(nameOrIndex)
	assert(currentIndex, "Column was not found")
	local column = tremove(self.scrollCols, currentIndex)
	if not column then return end
	target = private:ResolveTarget(self.scrollCols, target)
	addon.Log:D("MoveColumn", column.colName, target, position)
	private:InsertColumn(self.scrollCols, column, target, position)
	self:RefreshColumnLayout()
	return column
end

--- Updates an existing column in place.
--- Nothing's changed if an error occurs.
--- @param nameOrIndex string|number The column id/name or numeric index to update.
--- @param spec ColumnSpec The updated column definition.
--- @return ColumnSpec? #The updated column definition.
function RCVotingFrame:UpdateColumn(nameOrIndex, spec)
	assert(spec, "Column spec is required")
	local index = self:GetColumnIndex(nameOrIndex)
	assert(index, "Column was not found")
	local column = self.scrollCols[index]
	if not column then return end
	addon.Log:D("UpdateColumn", column.colName)
	if column.colName ~= spec.colName then
		self:CheckColNameUniqueness(spec.colName)
	end
	local old = CopyTable(column)
	for k, v in pairs(spec) do
		column[k] = v
	end
	if column.sortnext ~= nil and type(column.sortnext) ~= "number" then
		column.sortnextRef = column.sortnext
		column.sortnext = nil
	end
	local success, err = pcall(self.RefreshColumnLayout, self)
	if not success then
		self.scrollCols[index] = old
		error(err, 2)
	end
	return column
end

------------------------------------------------
--- Internals
------------------------------------------------

--- Bunch of logic handling integer targets for column position,
--- such as negative numbers are relative to the end, 0 = first, and clamping.
--- Strings and nils are passed through as is, while all other types than number are errors.
---@param scrollCols ColumnSpec[]
---@param target integer|string
function private:ResolveTarget(scrollCols, target)
	if not target or type(target) == "string" then
		return target
	elseif type(target) ~= "number" then
		error("Invalid target type", 2)
	elseif target == 0 then
		return 1
	elseif target > #scrollCols then
		return #scrollCols
	elseif target < 0 then
		return (#scrollCols + target) % #scrollCols + 1
	else
		return target
	end
end

function private:InsertColumn(scrollCols, spec, target, position)
	local insertAt
	if type(target) == "number" and position == nil then
		insertAt = target
	elseif position == "before" or position == "after" then
		local targetIndex = RCVotingFrame:GetColumnIndex(target)
		assert(targetIndex, "Target column was not found")
		insertAt = targetIndex + (position == "after" and 1 or 0)
	elseif position == nil then
		insertAt = #scrollCols + 1
	else
		insertAt = #scrollCols + 1
	end
	if insertAt < 1 then insertAt = 1 end
	if insertAt > #scrollCols + 1 then insertAt = #scrollCols + 1 end
	tinsert(scrollCols, insertAt, spec)
end

--- Copies the supplied column definitions into a mutable table.
--- This preserves the existing layout while normalizing sortnext references
--- into a form that can be safely updated after insertions and moves.
--- @internal
--- @param columns ColumnSpec[]? The column definitions to clone.
--- @return ColumnSpec[] #A cloned list of column specs.
function RCVotingFrame:CloneColumnSpecs(columns)
	local copy = {}
	for _, col in ipairs(columns or {}) do
		---@type ColumnSpec
		local clone = {}
		for k, v in pairs(col) do
			clone[k] = v
		end
		if clone.sortnext ~= nil and type(clone.sortnext) ~= "number" then
			clone.sortnextRef = clone.sortnext
			clone.sortnext = nil
		end
		tinsert(copy, clone)
	end
	return copy
end

--- Resolves a column reference to a numeric index.
--- Accepts a numeric index, a string id/colName, or a stringified index.
--- @param ref number|string? Index or column name
--- @param columns ColumnSpec[]? The column list to search. Defaults to current columns.
--- @return number? #The resolved column index.
function RCVotingFrame:ResolveColumnReference(ref, columns)
	columns = columns or self.scrollCols or {}
	if type(ref) == "number" then
		return ref
	end
	if type(ref) == "string" then
		local number = tonumber(ref)
		if number then
			return number
		end
		for i, col in ipairs(columns) do
			if col.colName == ref then
				return i
			end
		end
	end
end

--- Rebuilds the effective sortnext chain for the current columns.
--- Existing sortnext values are resolved to stable numeric targets and circular
--- references are cleared so sorting cannot recurse indefinitely.
--- @internal
function RCVotingFrame:NormalizeColumnLayout()
	local resolvedCols = {} -- List of columns that have already been checked
	local cols = self.scrollCols or {}
	local function PrintTrace(path, raw)
		local trace = {}
		for i = 1, #path do
			trace[i] = path[i].colName or path[i].id or tostring(i)
		end
		trace[#trace + 1] = raw
		addon:Print("<Error> Circular Sort Path:", table.concat(trace, " -> "))
	end
	local function resolve(index, stack, path)
		if tContains(resolvedCols, index) then return end
		local col = cols[index]
		if not col then return end
		if stack[index] then
			local startIndex
			for i = 1, #path do
				if path[i] == col then
					startIndex = i
					break
				end
			end
			if startIndex then
				local cycleCol = path[#path]
				if cycleCol then
					cycleCol.sortnext = nil
					cycleCol.sortnextRef = nil
					error(
						("Circular sortnext reference detected for column %s -> %s"):format(
							cycleCol.id or cycleCol.colName or
							tostring(index), stack[startIndex].colName))
				end
			end
			tinsert(resolvedCols, index)
			return
		end
		stack[index] = true
		tinsert(path, col)
		local raw = col.sortnextRef
		if raw == nil then
			raw = col.sortnext
		end
		local target = self:ResolveColumnReference(raw, cols)
		col.sortnext = nil
		if target and target >= 1 and target <= #cols and target ~= index then
			if stack[target] then
				col.sortnext = nil
				col.sortnextRef = nil
				PrintTrace(path, raw)
				error(("Circular sortnext reference detected for column %s -> %s"):format(col.colName or tostring(index),
					raw))
			else
				col.sortnext = target
				resolve(target, stack, path)
			end
		end
		stack[index] = nil
		tinsert(resolvedCols, index)
		tremove(path)
	end

	for _, col in ipairs(cols) do
		local raw = col.sortnextRef
		if raw == nil then
			raw = col.sortnext
		end
		col.sortnextRef = raw
		col.sortnext = nil
	end
	for i = 1, #cols do
		resolve(i, {}, {})
	end
	return cols
end

--- Reapplies the current column layout to the scrolling table.
--- This normalizes the layout and refreshes the table view after mutations.
function RCVotingFrame:RefreshColumnLayout()
	self:NormalizeColumnLayout()
	if self.frame and self.frame.st and self.frame.st.SortData then
		self.frame.st:SetDisplayCols(self.scrollCols)
		self.frame:SetWidth(self.frame.st.frame:GetWidth() + 20)
		self.frame.st:SortData()
	end
end
