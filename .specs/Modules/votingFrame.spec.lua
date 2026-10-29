insulate("RCVotingFrame column registry", function()
	local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
	local module = addon:GetModule("RCVotingFrame")
	dofile(".specs/EmulatePlayerLogin.lua")
	addon.Print = function() end -- Disable printing

	before_each(function()
		module:OnInitialize()
	end)

	it("can insert a column before another column and resolve sortnext by name", function()
		module:AddColumn({ id = "custom", colName = "custom", name = "Custom", width = 40, sortnext = "response", },
			"response", "before")

		local customIndex = module:GetColumnIndex("custom")
		assert.are.equal(customIndex, module:GetColumnIndex("response") - 1)
		assert.are.equal(module:GetColumnIndex("response"), module:GetColumn("custom").sortnext)
	end)

	it("can move a column and keep sortnext pointing to the correct column", function()
		module:AddColumn({ id = "custom", colName = "custom", name = "Custom", width = 40, sortnext = "name", },
			"response", "before")
		module:MoveColumn("custom", "roll", "after")

		local customIndex = module:GetColumnIndex("custom")
		assert.are.equal(customIndex, module:GetColumnIndex("roll") + 1)
		assert.are.equal(module:GetColumnIndex("name"), module:GetColumn("custom").sortnext)
	end)

	it("can update an existing custom column in place", function()
		module:AddColumn({ id = "custom", colName = "custom", name = "Custom", width = 40, sortnext = "response", },
			"response", "before")
		module:UpdateColumn("custom", { name = "Updated", width = 80, sortnext = "name", })

		local column = module:GetColumn("custom")
		assert.are.equal("Updated", column.name)
		assert.are.equal(80, column.width)
		assert.are.equal(module:GetColumnIndex("name"), column.sortnext)
	end)

	it("throws on circular sortnext references and clears only the final link", function()
		module:AddColumn({ id = "a", colName = "a", name = "A", width = 40, sortnext = "b", })
		module:AddColumn({ id = "b", colName = "b", name = "B", width = 40, sortnext = "c", })
		module:AddColumn({ id = "c", colName = "c", name = "C", width = 40, sortnext = "d", })
		module:AddColumn({ id = "d", colName = "d", name = "D", width = 40, sortnext = "e", })
		assert.has.errors(function()
			module:AddColumn({ id = "e", colName = "e", name = "E", width = 40, sortnext = "a", })
		end)

		assert.are.equal(17, module:GetColumn("c").sortnext)
		assert.is_nil(module:GetColumn("e").sortnext)
		assert.is_nil(module:GetColumn("e").sortnextRef)
	end)

	it("should throw error when updating a column to cause circular sorting", function()
		local col = module:GetColumn("roll")
		local sortnext = col.sortnext
		local sortnextRef = col.sortnextRef
		assert.has_error(function()
			module:UpdateColumn("roll", { sortnext = "response", })
		end)
		assert.is.equal(sortnext, module:GetColumn("roll").sortnext)
		assert.is.equal(sortnextRef, module:GetColumn("roll").sortnextRef)
	end)

	it("should properly move columns", function()
		local rollIndex = module:GetColumnIndex("roll")
		local responseIndex = module:GetColumnIndex("response")
		module:MoveColumn("roll", "response", "before")
		assert.are.equal(responseIndex, module:GetColumnIndex("roll"))
		assert.are.equal(responseIndex + 1, module:GetColumnIndex("response"))
		module:MoveColumn(responseIndex, 30, "after") -- Get resolved to #cols + 1
		assert.are.equal(rollIndex, module:GetColumnIndex("roll"))
		assert.are.equal(responseIndex, module:GetColumnIndex("response"))
	end)

	it("should remove columns", function()
	   module:AddColumn({ colName = "custom", name = "Custom", width = 40, sortnext = "response", }, 0)
	   assert.is_not_nil(module:GetColumn("custom"))
	   assert.is.equal("custom", module:GetColumn(1).colName)
	   module:RemoveColumn("custom")
	   assert.is_nil(module:GetColumn("custom"))
	   assert.is.equal("class", module:GetColumn(1).colName)
	   module:RemoveColumn(1)
	   assert.is.equal("name", module:GetColumn(1).colName)
	end)

	it("should reject columns with non-unique names", function()
	   local col = { colName = "votes", name = "Votes", width = 40, sortnext = "response", }
	   assert.error_matches(function()
		   module:AddColumn(col, 0)
	   end, "Column 'votes' already exists at index 10")
	   assert.error_matches(function()
		   module:UpdateColumn("roll", col)
	   end, "Column 'votes' already exists at index 10")
	end)
end)
