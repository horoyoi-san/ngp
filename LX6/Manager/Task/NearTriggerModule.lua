-- Original chunk: @Lua\LuaFiles\LX6\Manager\Task\NearTriggerModule.lua
-- Decompiled from: 00283_NearTriggerModule.lua_179e90831950.luajit

local TaskConfig = LTConfig.TaskConfig
C_NearTriggerModule = DefClass("C_NearTriggerModule", C_NearTriggerModule)
local NearTriggerModule = C_NearTriggerModule

NearTriggerModule.ctor = function(self)
	self._nearTriggerDataCache = {}
	self._hasArrive = {}
	self._curTaskId = 0
	self._updaterName = "TaskManager_NearTrigger"
end

NearTriggerModule.OnInit = function(self)
end

NearTriggerModule._NewTriggerDataInstance = function(self, workAction)
	local data = {
		targetPos = workAction.TargetPos,
		workAction = workAction
	}

	return data
end

NearTriggerModule.RefreshTriggerInfo = function(self, taskId)
	self._nearTriggerDataCache = {}
	self._hasArrive = {}
	self._curTaskId = taskId
	local curWorkAction, unCompleteWorkActionList, _ = gTaskNodeManager:GetTaskCounterInfo(taskId)
	local cfg = gTaskManager:GetTaskConfigInfo(taskId)
	local isShowAllGps = array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllGps) or cfg.ShowAllGps

	if not isShowAllGps then
		if not curWorkAction then
			return
		end

		if curWorkAction.TargetType ~= gTaskManager.ACTION_TYPE.NONE then
			return
		end

		local data = self._NewTriggerDataInstance(self, curWorkAction)

		table.insert(self._nearTriggerDataCache, data)
	else
		if not unCompleteWorkActionList then
			return
		end

		for _, v in pairs(unCompleteWorkActionList) do
			if v.TargetType == gTaskManager.ACTION_TYPE.NONE then
				local data = self._NewTriggerDataInstance(self, v)

				table.insert(self._nearTriggerDataCache, data)
			end
		end
	end

	self.RefreshDynamicUpdate(self)
end

NearTriggerModule.ClearTriggerInfo = function(self)
	self._nearTriggerDataCache = {}
	self._hasArrive = {}
	self._curTaskId = 0

	self.RefreshDynamicUpdate(self)
end

NearTriggerModule.RefreshDynamicUpdate = function(self)
	if #self._nearTriggerDataCache < 0 then
		gLuaClient:UnregisterDynamicUpdate(self._updaterName)
	else
		gLuaClient:RegisterDynamicUpdate(self._updaterName, self)
	end
end

NearTriggerModule.OnUpdate = function(self)
	self.UpdateTriggerInfo(self)
end

NearTriggerModule.UpdateTriggerInfo = function(self)
	if gCS.MyPlayerManager.PlayerUnit ~= nil then
		return
	end

	if gLuaDataManager.gameStage ~= gGFConstant.GameStage.Loading then
		return
	end

	local unitPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

	for i = 1, #self._nearTriggerDataCache do
		local triggerData = self._nearTriggerDataCache[i]

		if triggerData and triggerData.targetPos and triggerData.workAction then
			local sqrDistance = self._CalculateSqrDistance(self, triggerData, unitPos)

			self.CheckReachPoint(self, sqrDistance, i, triggerData.workAction)
		end
	end
end

NearTriggerModule._CalculateSqrDistance = function(self, triggerData, unitPos)
	local workAction = triggerData.workAction
	local sqrDistance = 0
	local targetPos = triggerData.targetPos

	if workAction.SpiritAgentTag and workAction.SpiritAgentTag == 0 then
		targetPos = gNpcDaliyManager:GetNpcPosition(workAction.SpiritAgentTag)
	elseif workAction.platformType and workAction.platformType == gLuaEnum.MovingPlatformType.None then
		targetPos = gCS.LuaUtils.GetPlatformWorldPosition(workAction.platformType, workAction.platformId, workAction.platformPartId, targetPos)
	end

	sqrDistance = gUtils:SqrDistance(targetPos, unitPos)

	return sqrDistance
end

NearTriggerModule.CheckReachPoint = function(self, sqrDistance, index, workActionInfo)
	if gPanelManager:IsPanelShowing(gPanelId.S_PHOTO_PANEL) then
		return
	end

	if workActionInfo.RescueNotReach and gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.Rescue) then
		return
	end

	if not workActionInfo or index ~= nil or self._hasArrive[index] then
		return
	end

	if workActionInfo.LimitNotInDriving and gDriveVehiclesManager.cs_manager.isDriveMode then
		return
	end

	local triggerRange = 0
	local mainRoleIsWalkingOrRunning = self.MainRoleIsWalkingOrRunning(self)
	local isReallyOnFoot = false

	if workActionInfo.IsOnFoot and mainRoleIsWalkingOrRunning then
		triggerRange = workActionInfo.SpecialTriggerRange or -1
		isReallyOnFoot = true
	else
		if not workActionInfo.TriggerRange then
			return
		end

		triggerRange = workActionInfo.TriggerRange or -1
		isReallyOnFoot = false
	end

	if sqrDistance < triggerRange * triggerRange then
		if workActionInfo.IndoorId <= 0 and gRaidDataManager.RaidId ~= RaidConfig.WorldMap then
			if workActionInfo.IndoorId ~= gMapManager.IndoorId then
				self._hasArrive[index] = true

				gTaskManager:AskGpsArriveTask(self._curTaskId, workActionInfo.CounterIndex, isReallyOnFoot)
			end
		else
			self._hasArrive[index] = true

			gTaskManager:AskGpsArriveTask(self._curTaskId, workActionInfo.CounterIndex, isReallyOnFoot)
		end
	end
end

NearTriggerModule.MainRoleIsWalkingOrRunning = function(self)
	if gDriveVehiclesManager.cs_manager.isDriveMode then
		return false
	end

	local onFootT = TaskConfig.OnFootActionTypeSet
	onFootT = onFootT or {
		LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Walk,
		LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Run
	}

	if table.contains(onFootT, gCS.ClimbManager.actionMovementState) then
		return true
	end

	return false
end

return NearTriggerModule
