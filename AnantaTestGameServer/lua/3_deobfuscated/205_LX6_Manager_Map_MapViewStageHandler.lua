EMapViewStage = {
	BindConflict = 10,
	Cull = 2,
	Reachable = 0,
	MeConflict = 3,
	LinkMode = 5,
	SpiritAndBadge = 6,
	View = 99,
	Fog = 4,
	Gate = 7
}
EMapViewStageCheckResult = {
	Pass = 1,
	Fail = 2,
	NotExist = 0
}
EMapViewStageItemChangeType = {
	Remove = 2,
	Update = 0,
	Add = 1
}
MapViewStageHandler = DefClass("MapViewStageHandler", MapViewStageHandler)
local M = MapViewStageHandler

function M:InitBaseInfo(view, type)
	self.view = view
	self.type = type
	self.allItems = {}
	self.commitedItems = {}
end

function M:SetCommonStage(checkFunc)
	self.checkFunc = checkFunc
	self.isGroup = false
end

function M:SetGroupStage(checkFunc, ruleFullUpdateHandler, ruleStepUpdater, initRuleContext)
	self.checkFunc = checkFunc
	self.ruleFullUpdater = ruleFullUpdateHandler
	self.ruleStepUpdater = ruleStepUpdater or ruleFullUpdateHandler
	self.isGroup = true
	self.ruleContext = {}

	if initRuleContext then
		initRuleContext(self.ruleContext)
	end
end

function M:TryPass(instanceId)
	if not self.checkFunc or self.checkFunc(instanceId, self.ruleContext) then
		return true
	else
		return false
	end
end

function M:CommitItem(instanceId)
	if self.commitedItems[instanceId] then
		return
	end

	self.commitedItems[instanceId] = true
	local item = self.view:GetItemInfo(instanceId)
	item.stageIdx = self._indexInView

	if self.onCommit then
		self.onCommit(instanceId)
	end

	if self.nextStage then
		self.nextStage:PushItem(instanceId)
	end
end

function M:RestoreItem(instanceId)
	if not self.commitedItems[instanceId] then
		return
	end

	if self.nextStage then
		self.nextStage:DropItem(instanceId)
	end

	self.commitedItems[instanceId] = nil
	local item = self.view:GetItemInfo(instanceId)
	item.stageIdx = self._indexInView - 1

	if self.onRestore then
		self.onRestore(instanceId)
	end
end

function M:SetCallbacks(onRestore, onCommit)
	self.onRestore = onRestore
	self.onCommit = onCommit
end

function M:SetStageChain(prevStage, nextStage)
	self.prevStage = prevStage
	self.nextStage = nextStage
end

function M:PushItem(instanceId)
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

function M:DropItem(instanceId)
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

function M:RecheckItem(instanceId)
	if not self.allItems[instanceId] then
		return EMapViewStageCheckResult.NotExist
	end

	if self.isGroup and self.ruleStepUpdater(self.allItems, self.ruleContext, instanceId, EMapViewStageItemChangeType.Update) then
		for id, _ in pairs(self.allItems) do
			if id ~= instanceId then
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

function M:RefreshStage()
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

function gMapViewStageCreator.Create(view, type)
	local handler = MapViewStageHandler.new()

	handler:InitBaseInfo(view, type)

	return handler
end
