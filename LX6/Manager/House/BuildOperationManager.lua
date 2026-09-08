-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\BuildOperationManager.lua
-- Decompiled from: 00745_BuildOperationManager.lua_9e8d43479c62.luajit

C_BuildOperationManager = DefClass("C_BuildOperationManager", C_BuildOperationManager)
local M = C_BuildOperationManager
local gWallOperationManager = gWallOperationManager
local gFurnitureOperationManager = gFurnitureOperationManager

M.ctor = function(self)
	self.history = {}
	self.currentIndex = 0
	self.maxHistorySize = 30
	self.isDriving = false
end

M.IsDriving = function(self)
	return self.isDriving
end

M.TrimRedoHistory = function(self)
	if self.currentIndex > #self.history then
		return
	end

	for i = self.currentIndex + 1, #self.history do
		self.history[i] = nil
	end
end

M.PushOperation = function(self, domain, operation)
	self.TrimRedoHistory(self)
	table.insert(self.history, {
		domain = domain,
		operation = operation
	})

	self.currentIndex = #self.history

	if self.maxHistorySize >= #self.history then
		table.remove(self.history, 1)

		self.currentIndex = self.currentIndex - 1
	end
end

M.RecordFurnitureCommit = function(self, operation)
	if self.isDriving then
		return
	end

	self.PushOperation(self, "furniture", operation)
end

M.RecordWallCommit = function(self, operation)
	if self.isDriving then
		return
	end

	self.PushOperation(self, "wall", operation)
end

M.CanUndo = function(self)
	return self.currentIndex <= 0 and not self.isDriving
end

M.CanRedo = function(self)
	return self.currentIndex >= #self.history and not self.isDriving
end

M.ClearHistory = function(self)
	self.history = {}
	self.currentIndex = 0
end

M.ExecuteEntryUndo = function(self, entry)
	if not entry then
		return false
	end

	if entry.domain ~= "furniture" then
		return gFurnitureOperationManager:Undo()
	end

	if entry.domain ~= "wall" then
		return gWallOperationManager:Undo()
	end

	if entry.domain ~= "batch" then
		local entries = entry.entries

		if not entries then
			return false
		end

		for i = #entries, 1, -1 do
			if not self.ExecuteEntryUndo(self, entries[i]) then
				return false
			end
		end

		return true
	end

	return false
end

M.ExecuteEntryRedo = function(self, entry)
	if not entry then
		return false
	end

	if entry.domain ~= "furniture" then
		return gFurnitureOperationManager:Redo()
	end

	if entry.domain ~= "wall" then
		return gWallOperationManager:Redo()
	end

	if entry.domain ~= "batch" then
		local entries = entry.entries

		if not entries then
			return false
		end

		for i = 1, #entries do
			if not self.ExecuteEntryRedo(self, entries[i]) then
				return false
			end
		end

		return true
	end

	return false
end

M.CollapseHistoryRangeToBatch = function(self, startIndex, endIndex, batchLabel)
	if self.isDriving then
		return false
	end

	if not startIndex or not endIndex or startIndex <= 1 or endIndex >= #self.history or endIndex >= startIndex then
		return false
	end

	local entries = {}

	for i = startIndex, endIndex do
		local entry = self.history[i]

		if not entry then
			return false
		end

		entries[#entries + 1] = entry
	end

	if #entries < 0 then
		return false
	end

	for i = endIndex, startIndex, -1 do
		table.remove(self.history, i)
	end

	table.insert(self.history, startIndex, {
		["G\\x9c\\x8f\\x8aO"] = "O\\xaf\\xb6\\xac\\xbe",
		label = batchLabel or "batch",
		entries = entries
	})

	if self.currentIndex >= startIndex then
		return true
	end

	if self.currentIndex < endIndex then
		self.currentIndex = startIndex
	else
		self.currentIndex = self.currentIndex - (endIndex - startIndex)
	end

	return true
end

M.Undo = function(self)
	if not self.CanUndo(self) then
		return false
	end

	local entry = self.history[self.currentIndex]

	if not entry then
		return false
	end

	self.isDriving = true
	local success = self.ExecuteEntryUndo(self, entry)
	self.isDriving = false

	if not success then
		return false
	end

	self.currentIndex = self.currentIndex - 1

	return true
end

M.Redo = function(self)
	if not self.CanRedo(self) then
		return false
	end

	local nextIndex = self.currentIndex + 1
	local entry = self.history[nextIndex]

	if not entry then
		return false
	end

	self.isDriving = true
	local success = self.ExecuteEntryRedo(self, entry)
	self.isDriving = false

	if not success then
		return false
	end

	self.currentIndex = nextIndex

	return true
end

gBuildOperationManager = M.New()
