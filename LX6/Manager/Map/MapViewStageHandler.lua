-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapViewStageHandler.lua
-- Decompiled from: 00208_MapViewStageHandler.lua_25f29481296a.luajit

EMapViewStage = {
	["M\\xa2so\\xbd\\xfcAfs}X"] = 10,
	Y7qW = 2,
	["~_\\xed\\xb2\\x8a\\xb4\r\\xca\\xfc"] = 3,
	["\\xa8ga"] = 4,
	["qFbnK*,"] = 8,
	["}Uڔ\\x8a;\\xac\\xce\\xed"] = -1,
	["\\x87\\xb8\\xa0G1\\xfa6"] = 5,
	["Ԋ\\xfe\\xc7\\xee\\xaa\\xec\\x86'-"] = 6,
	["L+xL"] = 99,
	["qBmjF="] = 0,
	["]#i^"] = 7
}
EMapViewStageCheckResult = {
	["J#nH"] = 1,
	["\\#tW"] = 2,
	["\\x85\\xbe\\x8er7\\xed'"] = 0
}
EMapViewStageItemChangeType = {
	[".M\\x9c\\x81\\x95D"] = 2,
	[")X\\x95\\x8f\\x97D"] = 0,
	["\\xaflb"] = 1
}
MapViewStageHandler = DefClass("MapViewStageHandler", MapViewStageHandler)
local M = MapViewStageHandler

M.InitBaseInfo = function(self, view, type)
	self.view = view
	self.type = type
	self.allItems = {}
	self.commitedItems = {}
end

M.SetCommonStage = function(self, checkFunc)
	self.checkFunc = checkFunc
	self.isGroup = false
end

M.SetGroupStage = function(self, checkFunc, ruleFullUpdateHandler, ruleStepUpdater, initRuleContext)
	self.checkFunc = checkFunc
	self.ruleFullUpdater = ruleFullUpdateHandler
	self.ruleStepUpdater = ruleStepUpdater or ruleFullUpdateHandler
	self.isGroup = true
	self.ruleContext = {}

	if initRuleContext then
		initRuleContext(self.ruleContext)
	end
end

M.TryPass = function(self, instanceId)
	if not self.checkFunc or self.checkFunc(instanceId, self.ruleContext) then
		return true
	else
		return false
	end
end

M.CommitItem = function(self, instanceId)
	if self.commitedItems[instanceId] then
		return
	end

	self.commitedItems[instanceId] = true
	local item = self.view:GetItemInfo(instanceId)
	item.stageIdx = self._indexInView
	item.passStageType = self.type
	item.nextStageType = self.nextStage and self.nextStage.type or nil

	if self.onCommit then
		self.onCommit(instanceId)
	end

	if self.nextStage then
		self.nextStage:PushItem(instanceId)
	end
end

M.RestoreItem = function(self, instanceId)
	if not self.commitedItems[instanceId] then
		return
	end

	if self.nextStage then
		self.nextStage:DropItem(instanceId)
	end

	self.commitedItems[instanceId] = nil
	local item = self.view:GetItemInfo(instanceId)
	item.stageIdx = self._indexInView - 1
	item.passStageType = self.prevStage and self.prevStage.type or nil
	item.nextStageType = self.type

	if self.onRestore then
		self.onRestore(instanceId)
	end
end

M.SetCallbacks = function(self, onRestore, onCommit)
	self.onRestore = onRestore
	self.onCommit = onCommit
end

M.SetStageChain = function(self, prevStage, nextStage)
	self.prevStage = prevStage
	self.nextStage = nextStage
end

M.PushItem = function(self, instanceId)
	if self.allItems[instanceId] then
		return
	end

	self.allItems[instanceId] = true

	if self.isGroup then
		local changed = self.ruleStepUpdater(self.allItems, self.ruleContext, instanceId, EMapViewStageItemChangeType.Add)

		if changed then
			for id, _ in pairs(self.allItems) do
				if self:TryPass(id) then
					self:CommitItem(id)
				else
					self:RestoreItem(id)
				end
			end
		elseif self:TryPass(instanceId) then
			self:CommitItem(instanceId)
		end
	elseif self:TryPass(instanceId) then
		self:CommitItem(instanceId)
	end
end

M.DropItem = function(self, instanceId)
	if not self.allItems[instanceId] then
		return
	end

	self:RestoreItem(instanceId)

	self.allItems[instanceId] = nil

	if self.isGroup then
		local changed = self.ruleStepUpdater(self.allItems, self.ruleContext, instanceId, EMapViewStageItemChangeType.Remove)

		if changed then
			for id, _ in pairs(self.allItems) do
				if self:TryPass(id) then
					self:CommitItem(id)
				else
					self:RestoreItem(id)
				end
			end
		end
	end
end

M.RecheckItem = function(self, instanceId)
	if not self.allItems[instanceId] then
		return EMapViewStageCheckResult.NotExist
	end

	if self.isGroup and self.ruleStepUpdater(self.allItems, self.ruleContext, instanceId, EMapViewStageItemChangeType.Update) then
		for id, _ in pairs(self.allItems) do
			if id == instanceId then
				if self:TryPass(id) then
					self:CommitItem(id)
				else
					self:RestoreItem(id)
				end
			end
		end

		if self:TryPass(instanceId) then
			return EMapViewStageCheckResult.Pass
		end
	elseif self:TryPass(instanceId) then
		self:CommitItem(instanceId)

		return EMapViewStageCheckResult.Pass
	else
		self:RestoreItem(instanceId)

		return EMapViewStageCheckResult.Fail
	end
end

M.RefreshStage = function(self)
	if self.isGroup then
		self.ruleFullUpdater(self.allItems, self.ruleContext)
	end

	for instanceId, _ in pairs(self.allItems) do
		if self:TryPass(instanceId) then
			self:CommitItem(instanceId)
		else
			self:RestoreItem(instanceId)
		end
	end
end

gMapViewStageCreator = gMapViewStageCreator or {}

gMapViewStageCreator.Create = function(view, type)
	local handler = MapViewStageHandler.new()

	handler:InitBaseInfo(view, type)

	return handler
end
