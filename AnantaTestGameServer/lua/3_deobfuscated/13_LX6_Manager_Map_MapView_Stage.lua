MapView = MapView or {}
local M = MapView

function M:InitStages()
	self.type2Stage = {}
	self.stages = {}
end

function M:AddStage(stage)
	if self.commited then
		print_error("@sunwei08: MapView:AddStage error, usage: call AddStage before Commit")

		return
	end

	if not stage then
		print_error("@sunwei08: MapView:AddStage error, stage is nil")

		return
	end

	if self.type2Stage[stage.type] then
		print_error("@sunwei08: MapView:AddStage error, duplicated type = " .. stage.type)

		return
	end

	self.type2Stage[stage.type] = stage

	table.insert(self.stages, stage)
end

function M:Commit()
	table.sort(self.stages, function (a, b)
		return a.type < b.type
	end)

	for idx, stage in ipairs(self.stages) do
		stage._indexInView = idx
	end

	self.firstStage = self.stages[1]
	self.finalStage = self.stages[#self.stages]

	for i = 1, #self.stages do
		local prevStage, nextStage = nil

		if i > 1 then
			prevStage = self.stages[i - 1]
		end

		if i < #self.stages then
			nextStage = self.stages[i + 1]
		end

		self.stages[i]:SetStageChain(prevStage, nextStage)
	end

	self.commited = true
end

function M:InitDefaultStages()
	self.defaultReachableStage = gMapViewStageCreator.Create(self, EMapViewStage.Reachable)

	self.defaultReachableStage:SetCommonStage(function (instanceId)
		local item = self.items[instanceId]

		if not item then
			gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:InitStages: Item not found for instanceId", instanceId)

			return false
		end

		return item.coordType ~= EMapViewerItemCoordType.Unreachable
	end)

	self.defaultCullStage = gMapViewStageCreator.Create(self, EMapViewStage.Cull)

	self.defaultCullStage:SetCommonStage(function (instanceId)
		return not self:Cull(instanceId)
	end)

	self.defaultFogStage = gMapViewStageCreator.Create(self, EMapViewStage.Fog)

	self.defaultFogStage:SetCommonStage(function (instanceId)
		return not self:InFog(instanceId)
	end)

	self.defaultLinkModeStage = gMapViewStageCreator.Create(self, EMapViewStage.LinkMode)

	self.defaultLinkModeStage:SetCommonStage(function (instanceId)
		local item = self.items[instanceId]
		local modes = item.mapElement.fData.linkShowModes

		if not modes or #modes == 0 then
			return true
		end

		return array.contains(modes, gMapUtils:UXLinkModeEnum2ConfigEnum(gLinkManager.LinkMode))
	end)

	self.defaultSpiritAndBadgeStage = gMapViewStageCreator.Create(self, EMapViewStage.SpiritAndBadge)

	self.defaultSpiritAndBadgeStage:SetCommonStage(function (instanceId)
		return self:CheckSpiritAndBadgeFilter(instanceId, self.cfg.skipImportantTaskSpiritFilter)
	end)

	self.defaultViewStage = gMapViewStageCreator.Create(self, EMapViewStage.View)

	self.defaultViewStage:SetCommonStage(nil)
	self.defaultViewStage:SetCallbacks(function (instanceId)
		self:TryRemoveFromView(instanceId)
	end, function (instanceId)
		self:TryAddToView(instanceId)
	end)

	self.defaultGateStage = gMapViewStageCreator.Create(self, EMapViewStage.Gate)

	self.defaultGateStage:SetGroupStage(function (instanceId, ruleContext)
		return self:GateStageCheck(instanceId, ruleContext)
	end, function (allItems, ruleContext)
		return self:GateStageRuleFullUpdate(allItems, ruleContext)
	end, function (allItems, ruleContext, instanceId, changeType)
		return self:GateStageRuleStepUpdate(allItems, ruleContext, instanceId, changeType)
	end)

	self.meConflictStage = gMapViewStageCreator.Create(self, EMapViewStage.MeConflict)

	self.meConflictStage:SetCommonStage(function (instanceId)
		local rootBindId = gGpsBindingMgr:GetBindRootIdByGpsInstanceId(instanceId)

		if not rootBindId then
			return true
		else
			return rootBindId ~= gGpsBindingMgr.meBindId
		end
	end)

	self.bindConflictStage = gMapViewStageCreator.Create(self, EMapViewStage.BindConflict)

	self.bindConflictStage:SetGroupStage(function (instanceId, ruleContext)
		return self:ConflictStageCheck(instanceId, ruleContext)
	end, function (allItems, ruleContext)
		return self:ConflictStageRuleFullUpdate(allItems, ruleContext)
	end, function (allItems, ruleContext, instanceId, changeType)
		return self:ConflictStageRuleFullUpdate(allItems, ruleContext, instanceId, changeType)
	end, function (ruleContext)
		self:InitConflictStageRuleContext(ruleContext)
	end)
end

function M:AddNecessaryStages()
	self:AddStage(self.defaultReachableStage)
	self:AddStage(self.defaultLinkModeStage)
	self:AddStage(self.defaultSpiritAndBadgeStage)
	self:AddStage(self.defaultViewStage)
	self:AddStage(self.meConflictStage)
	self:AddStage(self.defaultGateStage)
end

function M:RefreshStage(stageType)
	local stage = self.type2Stage[stageType]

	if not stage then
		return
	end

	stage:RefreshStage()
end

function M:RestageItem(instanceId)
	local item = self.items[instanceId]

	if not item then
		return
	end

	for i = 1, item.stageIdx do
		local stage = self.stages[i]

		if stage:RecheckItem(instanceId) ~= EMapViewStageCheckResult.Pass then
			return
		end
	end

	if item.stageIdx < #self.stages then
		self:RecheckItemStage(instanceId, item.stageIdx + 1)
	end
end

function M:RecheckItemStage(instanceId, changedStageType)
	local stage = self.type2Stage[changedStageType]

	if not stage then
		return
	end

	local item = self.items[instanceId]

	if not item then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:RecheckItemStage: Item not found for instanceId", instanceId)

		return
	end

	local changedStageIdx = stage._indexInView

	if changedStageIdx > item.stageIdx + 1 then
		return
	end

	stage:RecheckItem(instanceId)
end

function M:TryAddToView(instanceId)
	if self.cfg.delayAddAndRemove then
		self._viewMap.toRemove[instanceId] = nil

		if not self._viewMap.currentIds[instanceId] then
			self._viewMap.toAdd[instanceId] = true
		else
			self._viewMap.toAdd[instanceId] = nil
		end
	elseif not self._viewMap.currentIds[instanceId] then
		self._viewMap.currentIds[instanceId] = true

		if self._onAddCb then
			self._onAddCb(instanceId)
		end
	else
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:TryAddToView: Item already in view", instanceId)
	end
end

function M:TryRemoveFromView(instanceId)
	if self.cfg.delayAddAndRemove then
		self._viewMap.toAdd[instanceId] = nil

		if self._viewMap.currentIds[instanceId] then
			self._viewMap.toRemove[instanceId] = true
		else
			self._viewMap.toRemove[instanceId] = nil
		end
	elseif self._viewMap.currentIds[instanceId] then
		self._viewMap.currentIds[instanceId] = nil

		if self._onRemoveCb then
			self._onRemoveCb(instanceId)
		end
	else
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:TryRemoveFromView: Item not in view", gGpsTools.GetGpsDebugDesc(instanceId))
	end
end
