local MessageConfig = LTConfig.MessageConfig
local GameConfig = LTConfig.GameConfig
local DataSet = require("LX6/DataBind/DataSet")
local SpoonFeiSuoType = L18.Spoon.RegisterFeiSuo.FeiSuoType
local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig
local M = gGadgetManager or {}
M.combineAttackCache = {}
M.farDistanceCheckTarget = {}
M.unitStateListen = {}
M.entityEventPrerecord = {}
M.luaSlotDatas = {}
M.bindParentCache = {}
M.taskSpoonSlotList = {
	{},
	{}
}
M.taskSpoonGroupSlotList = {}
M.taskSpoonSingleSlotList = {}
M.NpcSceneInteractList = {}
M.NpcMetroInteractList = {}
M.TaskBanGadgetList = {}
M.farFlyTarget = nil
M.indicatorLoadWaiting = {}
M.MindDiceList = {}
M.FeiSuoTargetList = {}
M.SpaceThrowTargetList = {}
M.HackInteractList = {}
M.HunePoolTargetList = {}
M.lastHunePoolTime = 0
M.gadgetParamTmp = {}
M.creatorIdToInstanceIdMap = {}
M.FeiSuoData = DataSet.New({
	hasFarFlyTarget = false
})
M.taskPlayFeiSuoData = {
	InstanceId = 9999992,
	show = false,
	GpsType = gTaskGpsType.TaskPlayFeiSuo,
	TargetPos = Vector3.zero
}
M.taskPlaySpaceThrowData = {
	InstanceId = 9999993,
	show = false,
	GpsType = gTaskGpsType.SpaceThrow,
	TargetPos = Vector3.zero
}
M.startPressTime = 0
local lastLNormalUpdateTime = 0
local eventHandler = {
	[gEventConstants.BEFORE_SWITCH_SCENE] = function (eventId, switchType)
		if switchType == gSwitchSceneType.Reconnect then
			return
		end

		M.entityEventPrerecord = {}
		M.miniMapList = {}

		M:ClearAllHud()

		M.NpcSceneInteractList = {}
		M.NpcMetroInteractList = {}
		M.farFlyTarget = nil
		M.FeiSuoData.hasFarFlyTarget = false
		M.isFarFlying = false
	end,
	[gEventConstants.PEDESTRIAN_HACK_TARGET_CHANGE] = function (eventId, data)
		M:CheckNeedToUpdate()
	end
}

function M:OnInit()
	for k, v in pairs(eventHandler) do
		gMessageManager:AddMessageListener(k, v)
	end
end

function M:OnUpdate()
	local isCanNormalUpdate = false

	self:SendEntityAttack()

	local currentTime = Time.time

	if currentTime > lastLNormalUpdateTime + 0.1 then
		isCanNormalUpdate = true
		lastLNormalUpdateTime = currentTime
	end

	if isCanNormalUpdate then
		self:RefreshFeiSuoTarget()
		self:RefreshSpaceThrowTarget()
		self:RefreshHackInteract()
	end

	self:RefreshFollowPlayer()
	self:CheckNeedToUpdate()
end

M.isInUpdate = false

function M:CheckNeedToUpdate()
	local isNeedSendEntityAttack = not table.isNilOrEmpty(M.combineAttackCache)
	local isNeedFeiSuoTarget = not table.isNilOrEmpty(M.FeiSuoTargetList)
	local isNeedSpaceThrowTarget = not table.isNilOrEmpty(M.SpaceThrowTargetList)
	local isNeedHunePoolTarget = not table.isNilOrEmpty(M.HunePoolTargetList)
	local isNeedHackInteract = not table.isNilOrEmpty(M.HackInteractList)
	local isNeedDiceMind = not table.isNilOrEmpty(M.MindDiceList)
	local isNeedFollowPlayer = not table.isNilOrEmpty(M.FollowPlayerList)
	local isNeedHackPedestrian = L50.L50App.Scene and L50.L50App.Scene.HackManager.hackInfoTarget ~= nil
	local isNeedUpdate = isNeedSendEntityAttack or isNeedFeiSuoTarget or isNeedSpaceThrowTarget or isNeedHunePoolTarget or isNeedHackInteract or isNeedDiceMind or isNeedFollowPlayer or isNeedHackPedestrian

	if isNeedUpdate and not self.isInUpdate then
		gLuaClient:RegisterDynamicUpdate("gGadgetManager", self)

		self.isInUpdate = true
	elseif not isNeedUpdate and self.isInUpdate then
		gLuaClient:UnregisterDynamicUpdate("gGadgetManager")

		self.isInUpdate = false
	end
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		self.taskSpoonSlotList = {
			{},
			{}
		}
		self.FeiSuoTargetList = {}
		self.SpaceThrowTargetList = {}
		self.HunePoolTargetList = {}
		self.lookAtEntityList = {}
		self.FeiSuoTarget = nil

		gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.GadgetFeiSuoTarget, false)

		self.SpaceThrowTarget = nil
		self.HackInteractList = {}
		self.clientGadgetList = {}
		self.HackInteractTarget = nil

		self:SetHackTarget(nil)

		self.MindDiceList = {}

		gGpsManager:RemoveGPSById(9999992, gTaskGpsType.TaskPlayFeiSuo)
		gGpsManager:RemoveGPSById(9999993, gTaskGpsType.SpaceThrow)

		self.indicatorLoadWaiting = {}
		self.taskSpoonGroupSlotList = {}
		self.taskSpoonSingleSlotList = {}
	end

	if gSwitchSceneType.NewScene <= switchType then
		self.luaSlotEntityOtherName = {}
		self.farDistanceCheckTarget = {}
		self.unitStateListen = {}
		self.FollowPlayerList = {}
		self.TaskBanGadgetList = {}
		self.hackEffectList = {}

		table.clear(self.entityEventPrerecord)
		table.clear(self.luaSlotDatas)
	end
end

local _allocateIdBase = 3000000

function M:AskToGetSlotEntityId(parentId, templateId)
	local entityId = _allocateIdBase + parentId % 1000 * 1000 + templateId % 1000

	return entityId
end

M.miniMapList = {}
M.headTitleList = {}

function M:AddSlotMiniMap(entity, icon)
	local entityId = self:GetEntityId(entity)

	if entityId == nil then
		return
	end

	if self.miniMapList[entityId] then
		return
	end

	self.miniMapList[entityId] = {
		icon = icon,
		tran = entity.gameObject.transform,
		raid = gRaidDataManager.RaidId
	}

	gMessageManager:SendMessage(gEventConstants.MAP_LUA_SLOT_ADD, entityId)
end

function M:ClearAllHud()
	for i, v in pairs(M.headTitleList) do
		if v then
			gHudMgr:DestroySlotEntityTarget(i)
		end
	end
end

function M:RemoveSlotMiniMap(entity)
	local entityId = self:GetEntityId(entity)

	if entityId == nil then
		return
	end

	if not self.miniMapList[entityId] then
		return
	end

	self.miniMapList[entityId] = nil

	gMessageManager:SendMessage(gEventConstants.MAP_LUA_SLOT_REMOVE, entityId)
end

M.FeiSuoType = {
	OutRange = 1,
	Wall = 3,
	Normal = 2
}
M.FeiSuoSide = {
	Down = 2,
	Up = 1,
	Left = 3,
	Right = 4
}
M.breakWindowPos2 = Vector3.zero

function M:OnTryFeiSuo()
	if not self.FeiSuoTarget then
		return false
	end

	self.curFeiSuoTargetId = self.FeiSuoTarget.entityId
	self.curFeiSuoIndex = self.FeiSuoTarget.index

	gSpoonClientMgr:ReleaseContextEvent(self.curFeiSuoTargetId, gSpoonEventType.FeiSuoTrigger, {
		type = 0,
		index = self.curFeiSuoIndex
	})

	if self.FeiSuoTarget.actionType then
		if L50.L50App.Scene.GamePlayUtils:CanTriggerGadgetABP(self.FeiSuoTarget.actionType) then
			gCS.DestroyWindowModuleMgr.GadgetInitList(gCS.MyPlayerManager.PlayerUnit, self.FeiSuoTarget.actionType, self.FeiSuoTarget.actionList, self.FeiSuoTarget.actionList[1].forward)
		end

		return true
	end

	if not self.FeiSuoTarget.actionTrans then
		return false
	end

	self.isFarFlying = true
	local flatY = self.FeiSuoTarget.actionTrans.eulerAngles.y
	local targetForward = self.FeiSuoTarget.actionTrans.forward
	self.breakWindowPos2 = Vector3.null
	local pos1 = self.FeiSuoTarget.actionTrans.position
	local pos2 = Vector3.New(pos1.x, pos1.y, pos1.z)

	if self.FeiSuoTarget.actionEndTrans then
		pos2 = self.FeiSuoTarget.actionEndTrans.position
		self.breakWindowPos2 = Vector3.New(pos2.x, pos2.y, pos2.z)
	end

	local posType, sideType, midPointPos, ropePos = self:GetCurFeiSuoPosType()

	if ropePos == nil then
		ropePos = pos1 + Vector3.up * 5
	end

	if self.FeiSuoTarget.feiSuoType == SpoonFeiSuoType.DownFlip then
		self.breakWindowPos2 = pos1
	end

	local isOnDownFlip = self.FeiSuoTarget.feiSuoType == SpoonFeiSuoType.DownFlip and Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, pos1) < self.FeiSuoTarget.flipRadius

	print_debug("[DestroyWindow] midPointPos", midPointPos, "feiSuoType", self.FeiSuoTarget.feiSuoType, "pos1", pos1, "pos2", pos2, "posType", posType, "ropePos", ropePos, "sideType", sideType, "isOnDownFlip", isOnDownFlip)

	local downFlipMidPos = self.FeiSuoTarget.actionTrans.position + Vector3.up * 2

	if self.FeiSuoTarget.feiSuoType == SpoonFeiSuoType.FlyThrow then
		local list = {
			self.FeiSuoTarget.actionTrans,
			self.FeiSuoTarget.actionEndTrans,
			self.FeiSuoTarget.endWallTrans
		}

		gCS.DestroyWindowModuleMgr.GadgetInitList(gCS.MyPlayerManager.PlayerUnit, ActionTransitionRuleTypesConfig.GadgetTypeType.WallThrough, list, targetForward)
	elseif self.FeiSuoTarget.feiSuoType == SpoonFeiSuoType.VentilatingPipeOut then
		gCS.DestroyWindowModuleMgr.SetCacheClimbDestEdge(gCS.MyPlayerManager.PlayerUnit, pos1, pos2, targetForward, pos1, self.FeiSuoTarget.feiSuoType, sideType)
		gCS.DestroyWindowModuleMgr.SetWorldEvent(gCS.MyPlayerManager.PlayerUnit)
	elseif isOnDownFlip then
		gCS.DestroyWindowModuleMgr.SetCacheClimbDestEdge(gCS.MyPlayerManager.PlayerUnit, downFlipMidPos, pos2, targetForward, pos1, self.FeiSuoTarget.feiSuoType, sideType)
		gCS.LuaUtils.CheckTimeLine(19, 0, 0)
	elseif self.FeiSuoTarget.feiSuoType ~= SpoonFeiSuoType.DestroyWindow or self.FeiSuoTarget.feiSuoType == SpoonFeiSuoType.DownFlip then
		sideType = 0

		gCS.DestroyWindowModuleMgr.SetCacheClimbDestEdge(gCS.MyPlayerManager.PlayerUnit, self.breakWindowPos2, pos2, targetForward, ropePos, self.FeiSuoTarget.feiSuoType, sideType)

		local _, time = gFeiSuoCrouchManager:PlayFeisuoActionRotation(gCS.MyPlayerManager.PlayerUnit.Pid, pos1, nil, gLuaFightConstants.FeisuoType_SlotFarInteract, nil)
	else
		if midPointPos ~= nil then
			self.breakWindowPos2 = midPointPos
		end

		self:AnyAngleBreakWindow(posType, pos2, sideType, ropePos, targetForward, flatY)
	end

	return true
end

function M:AnyAngleBreakWindow(posType, pos2, sideType, ropePos, targetForward, flatY)
	local pos1 = self.FeiSuoTarget.actionTrans.position

	print_debug("AnyAngleBreakWindow posType", posType, "sideType", sideType, "pos1", pos1, "pos2", pos2, "ropePos", ropePos, targetForward, flatY)

	if posType == M.FeiSuoType.Normal or posType == M.FeiSuoType.OutRange then
		gCS.DestroyWindowModuleMgr.SetCacheClimbDestEdge(gCS.MyPlayerManager.PlayerUnit, pos2, self.breakWindowPos2, targetForward, ropePos, self.FeiSuoTarget.feiSuoType, sideType)

		local _, time = gFeiSuoCrouchManager:PlayFeisuoActionRotation(gCS.MyPlayerManager.PlayerUnit.Pid, pos1, nil, gLuaFightConstants.FeisuoType_SlotFarInteract, nil)
	else
		gCS.DestroyWindowModuleMgr.SetCacheClimbDestEdge(gCS.MyPlayerManager.PlayerUnit, pos1, pos2, targetForward, ropePos, self.FeiSuoTarget.feiSuoType, sideType)
		gCS.LuaUtils.CheckTimeLine(15, 0, sideType)
	end
end

function M:DestroyWindowDisOK()
	gSpoonClientMgr:ReleaseContextEvent(self.curFeiSuoTargetId, gSpoonEventType.FeiSuoTrigger, {
		type = 1,
		index = self.curFeiSuoIndex
	})
end

function M:RegisterFeiSuo(entityId, index, data)
	if type(data) ~= "table" then
		data = data:ToTable()
		local fun = data.GetTargetPos

		function data.GetTargetPos()
			return fun:DynamicInvoke()
		end
	end

	if not self.FeiSuoTargetList[entityId] then
		self.FeiSuoTargetList[entityId] = {}
	end

	self.FeiSuoTargetList[entityId][index] = data

	self:CheckNeedToUpdate()
end

function M:UnRegisterFeiSuo(entityId, index)
	if self.FeiSuoTarget and self.FeiSuoTarget.entityId == entityId and self.FeiSuoTarget.index == index then
		gGpsManager:RemoveGPSById(9999992, gTaskGpsType.TaskPlayFeiSuo)
	end

	if self.FeiSuoTargetList[entityId] and index then
		self.FeiSuoTargetList[entityId][index] = nil
	end

	self:CheckNeedToUpdate()
end

function M:RefreshFeiSuoTarget()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local target = nil
	local minAngle = 360
	local camPos = gCS.CameraDataMgr.MainCamera.transform.position
	local camDir = gCS.CameraDataMgr.MainCamera.transform.forward
	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

	if self:FarClickAble() then
		for entityId, list in pairs(self.FeiSuoTargetList) do
			for index, data in pairs(list) do
				local targetPos = data.GetTargetPos()

				if Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.HeadPos, targetPos) < data.dis and Vector3.Angle(data.targetTransform.forward, targetPos - playerPos) < data.angle and L50.L50App.Scene.HackManager:CheckEntityItemVisiable(camPos.x, camPos.y, camPos.z, targetPos.x, targetPos.y, targetPos.z, 0.1, 100, data.go) then
					local angle = Vector3.Angle(targetPos - camPos, camDir)
					local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(targetPos)

					if screenPos.z >= 0 and screenPos.x >= 0 and UnityEngine.Screen.width >= screenPos.x and screenPos.y >= 0 then
						if UnityEngine.Screen.height < screenPos.y then
							-- Nothing
						elseif angle < minAngle then
							minAngle = angle
							target = data
						end
					end
				end
			end
		end
	end

	local isFeiSuoState = gCS.PaoKuManager.ParkourStateLua == LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Feisuo

	gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.GadgetFeiSuoTarget, isFeiSuoState or target ~= nil)

	if self.FeiSuoTarget ~= target then
		self.FeiSuoTarget = target

		if target then
			self.FeiSuoData.hasFarFlyTarget = true
			self.taskPlayFeiSuoData.show = true
			self.taskPlayFeiSuoData.TargetTrans = target.targetTransform
		else
			self.FeiSuoData.hasFarFlyTarget = false
			self.taskPlayFeiSuoData.show = false
			self.taskPlayFeiSuoData.TargetTrans = nil
		end

		gGpsManager:AddFeiSuoGps(self.taskPlayFeiSuoData)
	end
end

function M:FarClickAble()
	if not gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.BuffConfig.CanFeiSuo) then
		return false
	end

	if self.curHackCameraEntityId then
		return false
	end

	if gCS.PaoKuManager.ParkourStateLua == LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.FeiSuoInteractive then
		return false
	end

	return true
end

function M:GetCurFeiSuoPosType()
	if self.FeiSuoTarget.feiSuoType == 9 or self.FeiSuoTarget.feiSuoType == 10 or self.FeiSuoTarget.feiSuoType == 11 then
		return M.FeiSuoType.Normal, 0, self.FeiSuoTarget.actionEndTrans.position, self.FeiSuoTarget.ropeTrans.position
	end

	local centerTrans = self.FeiSuoTarget.actionTrans
	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local playerLocalPos = centerTrans:InverseTransformPoint(playerPos)
	local wallWidth = GameConfig.FeiSuowallWidth
	local ropeUp = GameConfig.FeiSuoropeUp
	local virtualOffset = GameConfig.FeiSuovirtualOffset
	local virtualRadius = GameConfig.FeiSuovirtualRadius
	local midRadius = GameConfig.FeiSuomidRadius
	local side = nil

	if math.abs(playerLocalPos.x) < math.abs(playerLocalPos.y) then
		if playerLocalPos.y > 0 then
			side = M.FeiSuoSide.Up
		else
			side = M.FeiSuoSide.Down
		end
	elseif playerLocalPos.x < 0 then
		side = M.FeiSuoSide.Left
	else
		side = M.FeiSuoSide.Right
	end

	local ropePos = nil

	if self.FeiSuoTarget.feiSuoType == 7 then
		ropePos = centerTrans.position
	else
		ropePos = centerTrans:TransformPoint(Vector3.New(0, ropeUp, 0))
	end

	if playerLocalPos.z > -wallWidth then
		return M.FeiSuoType.Wall, side, nil, ropePos
	end

	local virtualPoint = centerTrans:TransformPoint(Vector3.New(0, 0, virtualOffset))
	local virtualSidePoint = centerTrans:TransformPoint(Vector3.New(virtualRadius, 0, 0))
	local virtualAngle = Vector3.Angle(virtualPoint - virtualSidePoint, centerTrans.forward)
	local playerAngle = Vector3.Angle(centerTrans.position - playerPos, centerTrans.forward)

	if playerAngle < virtualAngle then
		return M.FeiSuoType.Normal, 0, nil, ropePos
	else
		return M.FeiSuoType.OutRange, side, centerTrans.position + -centerTrans.forward * midRadius, ropePos
	end
end

function M:ModifySceneInterestPoint(entityId, isAdd, index, pid)
	local signalKey = isAdd and "NpcOccupy" or "NpcRelease"

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = signalKey,
		entityInstanceId = entityId
	})

	if not self.NpcSceneInteractList[entityId] then
		self.NpcSceneInteractList[entityId] = {}
	end

	if isAdd then
		self.NpcSceneInteractList[entityId][index] = pid and pid or true
	elseif index == -1 then
		self.NpcSceneInteractList[entityId] = nil
	else
		self.NpcSceneInteractList[entityId][index] = nil
	end
end

function M:ClearMetroInterestPoint(metroId)
	if not self.NpcMetroInteractList[metroId] then
		return
	end

	self.NpcMetroInteractList[metroId] = {}
end

function M:ModifyMetroInterestPoint(metroId, entityId, isAdd, index)
	if entityId == -1 and not isAdd then
		self.NpcMetroInteractList[metroId] = nil

		return
	end

	if not self.NpcMetroInteractList[metroId] then
		self.NpcMetroInteractList[metroId] = {}
	end

	local list = self.NpcMetroInteractList[metroId]

	if isAdd then
		if not list[entityId] then
			list[entityId] = {}
		end

		list[entityId][index] = true
	else
		if not list[entityId] then
			return
		end

		if index == -1 then
			list[entityId] = nil
		else
			list[entityId][index] = nil
		end
	end
end

function M:IsEntityIdInterestIndexUseful(entityId, index, pointId)
	local entity = self:GetEntitySearchByInstanceId(entityId, nil)

	if not entity then
		return true
	end

	return self:IsEntityInterestIndexUsefulHelper(entity, index, pointId)
end

function M:IsEntityInterestIndexUsefulHelper(entity, index, pointId)
	if not pointId then
		return true
	end

	local pointIndex = entity:GetOccupyIndex(pointId)

	return self:IsEntityInterestIndexUseful(entity, pointIndex)
end

function M:GetEntityIdInterestPointIndex(longChairPoints)
	local minIndex = 0
	local myUnit = gCS.MyPlayerManager.PlayerUnit

	if longChairPoints and myUnit then
		local playerObj = myUnit.PlayerObj
		local minDis = 100000

		for j, tran in ipairs(longChairPoints) do
			local dis = Vector3.Distance(playerObj.position, tran.position)

			if dis < minDis then
				minDis = dis
				minIndex = j
			end
		end
	end

	return minIndex
end

function M:CheckEntityInterestPoint(entity, buttonInfo)
	local minIndex = self:GetEntityIdInterestPointIndex(buttonInfo.longChairPoints)

	return self:IsEntityInterestIndexUsefulHelper(entity, minIndex, buttonInfo.longChairPointsId and buttonInfo.longChairPointsId[minIndex] or buttonInfo.interactPointsId)
end

function M:CheckEntityIdInterestPoint(entityId, buttonInfo)
	local entity = self:GetEntitySearchByInstanceId(entityId, nil)

	if entity == nil then
		return false
	end

	return self:CheckEntityInterestPoint(entity, buttonInfo)
end

function M:SyncSetEntityIdInterestUseful(entityId, longChairPoints, longChairPointsId, interactPointsId, commonInteractType, callbackFunc, isNotAuto)
	local entity = self:GetEntitySearchByInstanceId(entityId, nil)

	if entity == nil then
		return
	end

	local minIndex = self:GetEntityIdInterestPointIndex(longChairPoints)
	local pointId = longChairPointsId and longChairPointsId[minIndex] or interactPointsId
	local pointIndex = entity:GetOccupyIndex(pointId)

	if pointIndex == nil or not isNotAuto and entity:CheckIsFreeOccupy(pointIndex) then
		callbackFunc()

		return
	end

	callbackFunc()
	gCoroutineManager:StartCoroutine(function ()
		while gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene or not gCS.NetworkManager.Instance:IsServerConnected() do
			coroutine.yield(nil)
		end

		gClientToGameSceneDelegate:CheckCanOccupySceneItem(UX.Game.SceneItemEntityType.Gadget, entityId, pointIndex, false).Callback = function (err)
			if err == MessageConfig.Ok then
				self:ReleasePlayerOccupy()
				self:ModifySceneInterestPoint(entityId, true, pointIndex, gCS.MyPlayerManager.PlayerUnit.Pid)

				self.playerInteractType = commonInteractType
				self.playerOccupy = {
					entityId = entityId,
					pointIndex = pointIndex
				}
			end
		end
	end)
end

function M:SyncReleaseOccupySceneItem(entityId, isNotAuto)
	local index, data = self:CheckPlayerOccupy(entityId, true)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if index and data and (isNotAuto or not entity:CheckIsFreeOccupy(index)) then
		gClientToGameSceneDelegate:ReleaseOccupySceneItem(UX.Game.SceneItemEntityType.Gadget, entityId, index)
		self:ModifySceneInterestPoint(entityId, false, index)

		data[index] = nil
		self.playerOccupy = nil
	end
end

function M:ReleasePlayerOccupy()
	if self.playerOccupy then
		gClientToGameSceneDelegate:ReleaseOccupySceneItem(UX.Game.SceneItemEntityType.Gadget, self.playerOccupy.entityId, self.playerOccupy.pointIndex)
		self:ModifySceneInterestPoint(self.playerOccupy.entityId, false, self.playerOccupy.pointIndex)

		self.playerOccupy = nil
	end
end

function M:GetEntityInterestIndexUseful(entityId, index)
	if entityId == nil or index == nil then
		return nil
	end

	local data = self.NpcSceneInteractList[entityId]

	if data then
		return data[index]
	end
end

function M:CheckPlayerOccupy(entityId, needCheckInteract)
	if entityId == nil then
		return nil
	end

	local data = self.NpcSceneInteractList[entityId]

	if data then
		for i, v in pairs(data) do
			if v == gCS.MyPlayerManager.PlayerUnit.Pid and (not needCheckInteract or not gInteractionManager.isCommonInteractMoving) then
				return i, data
			end
		end
	end

	return nil
end

function M:IsEntityInterestIndexUseful(entity, index)
	local gadgetId = entity.entityInstanceId

	if not entity or not gadgetId or not index then
		return true
	end

	if gadgetId == 0 and entity.entityInstanceId then
		gadgetId = entity.entityInstanceId
	end

	local data = self.NpcSceneInteractList[gadgetId]

	if data then
		if data[index] then
			return gCS.MyPlayerManager.PlayerUnit.Pid == data[index]
		end

		return true
	end

	local entityBindMetroId = nil

	if type(entity) == "table" then
		entityBindMetroId = entity.bindMetroId
	else
		entityBindMetroId = entity.BindMetroId
	end

	local list = self.NpcMetroInteractList[entityBindMetroId]

	if not list or not list[entity.entityInstanceId] or not list[entity.entityInstanceId][index] then
		return true
	end

	return false
end

function M:IsEntityIdInterestUseful(entityId, maxIndex)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if not entity then
		return true
	end

	return self:IsEntityInterestUseful(entity, maxIndex)
end

function M:CheckHasEntityInterestUsefulById(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if not entity then
		return true
	end

	local maxIndex = entity:GetMaxOccupy()

	return self:IsEntityInterestUseful(entity, maxIndex)
end

function M:IsEntityInterestUseful(entity, maxIndex)
	local gadgetId = entity:GetGadgetCfgId()

	if not entity or not gadgetId then
		return true
	end

	if gadgetId == 0 and entity.entityInstanceId then
		gadgetId = entity.entityInstanceId
	end

	local data = self.NpcSceneInteractList[gadgetId]

	if data then
		if not maxIndex or maxIndex == -1 then
			return not data[-1]
		end

		if maxIndex and maxIndex >= 1 then
			for i = 0, maxIndex - 1 do
				if not data[i] then
					return true
				end
			end
		end

		return false
	end

	local list = self.NpcMetroInteractList[entity.bindMetroId]

	if not list or not list[entity.entityInstanceId] then
		return true
	end

	if not maxIndex or maxIndex == -1 then
		return not list[entity.entityInstanceId][-1]
	end

	for i = 0, maxIndex do
		if not list[entity.entityInstanceId][i] then
			return true
		end
	end

	return false
end

function M:OnPickBasketball(entityId, pick)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if pick then
		gMessageManager:SendMessage(gEventConstants.SWITCH_BASKETBALL_SHOOTING_ENTER)
		gameplayControlStore:StartGameplayByType(gHUDGameplayType.BASKETBALL)
		gSpoonClientMgr:ReleaseContextEvent(entityId, gSpoonEventType.MessageTrigger, {
			message = gEventConstants.ON_PICK_BASKETBALL
		})
	else
		gMessageManager:SendMessage(gEventConstants.SWITCH_BASKETBALL_SHOOTING_EXIT)
		gSpoonClientMgr:ReleaseContextEvent(entityId, gSpoonEventType.MessageTrigger, {
			message = gEventConstants.ON_RELEASE_BASKETBALL
		})
	end
end

M.interrogationData = {}

function M:OnSelectInterrogation(index)
	if self.interrogationData[index] then
		return false
	end

	self.interrogationData[index] = true

	return true
end

function M:ClearInterrogation()
	self.interrogationData = {}
end

function M:GetNextInterrogation(index, isRight)
	local add = isRight and 1 or -1
	local next = index + add

	if next > 3 then
		next = 1
	end

	if next < 1 then
		next = 3
	end

	if not self.interrogationData[next] then
		return next
	end

	next = next + add

	if next > 3 then
		next = 1
	end

	if next < 1 then
		next = 3
	end

	if not self.interrogationData[next] then
		return next
	end

	next = next + add

	if next > 3 then
		next = 1
	end

	if next < 1 then
		next = 3
	end

	if not self.interrogationData[next] then
		return next
	end

	return index
end

function M:CanInterrogation()
	for i = 1, 3 do
		if not self.interrogationData[i] then
			return true
		end
	end

	return false
end

function M:GetGadgetEntityMindData(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity then
		local mindPowerParams = entity.mindPowerParams
		local res = {
			mindControlAble = entity.mindControlAble or false,
			startSignal = mindPowerParams.startSignal,
			finishSignal = mindPowerParams.finishSignal,
			stopSignal = mindPowerParams.stopSignal,
			dragOnceSignal = mindPowerParams.dragOnceSignal,
			dragOnceEndSignal = mindPowerParams.dragOnceEndSignal,
			dragBreakSignal = mindPowerParams.dragBreakSignal,
			IsDrag = mindPowerParams.IsDrag or false,
			IsPress = mindPowerParams.IsPress or false,
			IsClick = mindPowerParams.IsClick or false,
			dragComp = mindPowerParams.dragComp,
			showInBattle = mindPowerParams.showInBattle or false,
			isLocked = mindPowerParams.isLocked or false,
			clickSound = mindPowerParams.clickSound or 0,
			pressStartSound = mindPowerParams.pressStartSound or 0,
			pressEndSound = mindPowerParams.pressEndSound or 0,
			dragType = mindPowerParams.dragType or 0,
			MindTime = mindPowerParams.MindTime or 0
		}

		return res
	end

	return nil
end

function M:GetGadgetEntityMindControlAble(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity then
		return entity.mindControlAble or false
	end

	return false
end

function M:GetGadgetEntityStartSignal(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.startSignal
	end

	return nil
end

function M:GetGadgetEntityFinishSignal(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.finishSignal
	end

	return nil
end

function M:GetGadgetEntityStopSignal(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.stopSignal
	end

	return nil
end

function M:GetGadgetEntityDragOnceSignal(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.dragOnceSignal
	end

	return nil
end

function M:GetGadgetEntityDragOnceEndSignal(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.dragOnceEndSignal
	end

	return nil
end

function M:GetGadgetEntityDragBreakSignal(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.dragBreakSignal
	end

	return nil
end

function M:GetGadgetEntityIsDrag(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.IsDrag or false
	end

	return false
end

function M:GetGadgetEntityIsPress(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.IsPress or false
	end

	return false
end

function M:GetGadgetEntityIsClick(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.IsClick or false
	end

	return false
end

function M:GetGadgetEntityPullableBase(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.dragComp
	end

	return nil
end

function M:GetGadgetEntityShowInBattle(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.showInBattle or false
	end

	return false
end

function M:GetGadgetEntityIsLocked(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.isLocked or false
	end

	return false
end

function M:GetGadgetEntitySlotEffect(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.SlotEffect or 0
	end

	return 0
end

function M:GetGadgetEntityPlayerEffect(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.PlayerEffect or 0
	end

	return 0
end

function M:GetGadgetEntityClickSound(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.clickSound or 0
	end

	return 0
end

function M:GetGadgetEntityPressStartSound(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.pressStartSound or 0
	end

	return 0
end

function M:GetGadgetEntityPressEndSound(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.pressEndSound or 0
	end

	return 0
end

function M:GetGadgetEntityDragType(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.dragType or 0
	end

	return 0
end

M.clientGadgetList = {}

function M:OnAddClientGadget(rootEntityId, entityId)
	if not self.clientGadgetList[rootEntityId] then
		self.clientGadgetList[rootEntityId] = {}
	end

	self.clientGadgetList[rootEntityId][entityId] = true
end

function M:OnClearEntityIdClientGadget(entityId)
	local list = gGadgetManager.clientGadgetList[entityId]

	if list then
		for id, v in pairs(list) do
			local entity = gGadgetManager:GetEntitySearchByInstanceId(id)

			if entity then
				UnityEngine.GameObject.Destroy(entity.gameObject)
			end
		end

		gGadgetManager.clientGadgetList[entityId] = nil
	end
end

function M:OnRemoveClientGadget(entityId)
	for rootEntityId, v in pairs(self.clientGadgetList) do
		if v[entityId] then
			v[entityId] = nil

			if table.is_empty(v) then
				self.clientGadgetList[rootEntityId] = nil

				gSpoonClientMgr:ReleaseContextEvent(rootEntityId, gSpoonEventType.AllClientGadgetDestroy)
			end

			L50.L50App.Scene.GamePlayUtils:SetCreateClientGadgetRemove(rootEntityId, entityId)

			return
		end
	end
end

function M:HackCameraPanelStore_SetFocus(open, target, duration)
	if gGadgetManager.hackCameraPanelStore then
		gGadgetManager.hackCameraPanelStore:SetFocus(open, target, duration)
	end
end

function M:GetInteractPosByPid(pid)
	local entity = self:GetEntitySearchByInstanceId(pid)
	local trans = entity.gameObject.transform:Find("InteractNode")
	trans = trans or entity.gameObject.transform

	return trans
end

function M:GetEntitySearchByInstanceId(instanceId, isCreateBySpoon)
	return L50.L50App.Scene.SpoonGadgetManager:GetEntitySearchByInstanceId(instanceId)
end

function M:ChangeGadgetState(entityId, stateType, state, isImmediately, needCheckLink)
	local entity = self:GetEntitySearchByInstanceId(entityId, false)

	if entity == nil then
		return
	end

	entity:SetGadgetState(stateType, state, isImmediately, needCheckLink)
end

function M:GMChangeGadgetState(entityInstanceId, stateType, state, isImmediately, needCheckLink)
	gClientToGameSceneDelegate:AskSceneItemChangeState(UX.Game.SceneItemEntityType.Gadget, entityInstanceId, stateType, state, false).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gGadgetManager:ChangeGadgetState(entityInstanceId, stateType, state, false)
		end
	end
end

function M:ChangeGadgetValue(entityId, Key, Value)
	local entity = self:GetEntitySearchByInstanceId(entityId, false)

	if entity == nil then
		return
	end

	entity:SetGadgetValue(Key, Value, false)
end

function M:DestroyGadgetById(entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId, false)

	if entity == nil then
		return
	end

	UnityEngine.GameObject.DestroyImmediate(entity.gameObject)
end

local sendPack = {}
local FRAME_UPDATE_RATE = 5
local currentFrame = FRAME_UPDATE_RATE

function M:SendEntityAttack()
	if currentFrame < FRAME_UPDATE_RATE then
		currentFrame = currentFrame + 1

		return
	end

	currentFrame = 0

	if table.isNilOrEmpty(M.combineAttackCache) then
		return
	end

	table.clear(sendPack)

	local hurtNumber = 0
	local hurtId = 0
	local needSend = false

	for entityId, list in pairs(self.combineAttackCache) do
		for weaponId, info in pairs(list) do
			local data = {}
			local entity = self:GetEntitySearchByInstanceId(entityId)

			if entity then
				data.SlotId = entityId
				data.GroupId = weaponId
				hurtId = info.hurtId
				hurtNumber = info.hurtNumber
				data.IsTask = entity.slotComp.isTaskSpoon
				data.ResidentTaskId = entity.slotComp.residentTask
				data.Targets = info.unitPidList

				table.insert(sendPack, data)

				needSend = true
			end
		end
	end

	if needSend then
		gClientToGameSceneDelegate:AskTriggerLuaSlotEventAttack(sendPack, hurtNumber, hurtId).Callback = function (err)
			if err ~= MessageConfig.Ok then
				print_error("AskTriggerLuaSlotEventAttack err =", err)
			end
		end

		needSend = false
	end

	table.clear(self.combineAttackCache)
end

function M:GetEntityByTypeOtherName(typeName, otherName)
	if self.luaSlotEntityOtherName == nil then
		return
	end

	if self.luaSlotEntityOtherName[typeName] == nil then
		return
	end

	if self.luaSlotEntityOtherName[typeName][otherName] then
		return self.luaSlotEntityOtherName[typeName][otherName]
	end
end

function M:GadgetSandbagAddDamage(val)
	local sandbagScreen = gGadgetManager:GetEntityByTypeOtherName("LuaSlotComponent", "SandbagScreen")

	if sandbagScreen then
		sandbagScreen:AddDamage(val)
	end
end

function M:CheckUnitStateChangeEvent(pid, stateId, isAdd)
	local entitys = self.unitStateListen[pid]

	if entitys then
		for i, e in pairs(entitys) do
			if e and e.CheckUnitStateChange then
				e:CheckUnitStateChange(stateId, isAdd)
			end
		end
	end
end

function M:GetEntityId(entity)
	if entity.entityInstanceId ~= 0 then
		return entity.entityInstanceId
	end

	if gCS.LuaUtils.IsNull(entity.gameObject) then
		return
	end

	local comp = entity.gameObject:GetComponent(typeof(LX6.LuaSlotEntitySystem.LuaSlotComponent))

	if comp then
		return comp.LuaEntityId
	end
end

function M:EntityBroadCastSignal(entityId, signal)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_OUT, {
		entity = entity,
		signalKey = signal
	})
end

function M:OnTrySpaceThrow()
	if not self.SpaceThrowTarget then
		return
	end

	local list = {
		self.SpaceThrowTarget.startPos,
		self.SpaceThrowTarget.midPos,
		self.SpaceThrowTarget.endPos,
		self.SpaceThrowTarget.startPos1,
		self.SpaceThrowTarget.startPos2,
		self.SpaceThrowTarget.endPos1,
		self.SpaceThrowTarget.endPos2
	}

	gCS.DestroyWindowModuleMgr.GadgetInitList(gCS.MyPlayerManager.PlayerUnit, ActionTransitionRuleTypesConfig.GadgetTypeType.WallJumpCross, list, -self.SpaceThrowTarget.startPos.forward)
end

function M:RegisterSpaceThrow(entityId, index, data)
	data = data:ToTable()
	local func = data.GetNearPos

	function data.GetNearPos(pos1, pos2)
		return func:DynamicInvoke(pos1, pos2)
	end

	if not self.SpaceThrowTargetList[entityId] then
		self.SpaceThrowTargetList[entityId] = {}
	end

	self.SpaceThrowTargetList[entityId][index] = data

	self:CheckNeedToUpdate()
end

function M:UnRegisterSpaceThrow(entityId, index)
	if self.SpaceThrowTarget and self.SpaceThrowTarget.entityId == entityId and self.SpaceThrowTarget.index == index then
		gGpsManager:RemoveGPSById(9999993, gTaskGpsType.SpaceThrow)
	end

	if self.SpaceThrowTargetList[entityId] then
		self.SpaceThrowTargetList[entityId][index] = nil
	end

	self:CheckNeedToUpdate()
end

function M:RefreshSpaceThrowTarget()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local target = nil
	local minAngle = 360
	local camPos = gCS.CameraDataMgr.MainCamera.transform.position
	local camDir = gCS.CameraDataMgr.MainCamera.transform.forward

	if self:FarClickAble() then
		for entityId, list in pairs(self.SpaceThrowTargetList) do
			for index, data in pairs(list) do
				local targetPos = data.GetNearPos(data.startPos1, data.startPos2)
				local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(targetPos)

				if screenPos.x >= 0 and UnityEngine.Screen.width >= screenPos.x and screenPos.y >= 0 then
					if UnityEngine.Screen.height < screenPos.y then
						-- Nothing
					else
						local angle = Vector3.Angle(targetPos - camPos, camDir)

						if angle < minAngle then
							minAngle = angle
							target = data
						end
					end
				end
			end
		end
	end

	if target then
		target.startPos.position = target.GetNearPos(target.startPos1, target.startPos2)
		target.endPos.position = target.GetNearPos(target.endPos1, target.endPos2)
	end

	if self.SpaceThrowTarget ~= target then
		if gCS.PaoKuManager.ParkourStateLua ~= LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Feisuo then
			self:SetSpaceThrowTarget(target)
		end

		if target then
			self.taskPlaySpaceThrowData.show = true
			self.taskPlaySpaceThrowData.GetNearPos = target.GetNearPos
			self.taskPlaySpaceThrowData.startPos1 = target.startPos1
			self.taskPlaySpaceThrowData.startPos2 = target.startPos2
			self.taskPlaySpaceThrowData.TargetTrans = target.targetTransform
		else
			self.taskPlaySpaceThrowData.show = false
			self.taskPlaySpaceThrowData.TargetTrans = nil
		end

		gGpsManager:AddFeiSuoGps(self.taskPlaySpaceThrowData)
	end
end

function M:SetSpaceThrowTarget(target)
	if self.SpaceThrowTarget ~= target then
		if not self.SpaceThrowTarget and target then
			gBattleMgr:EnableGrappleSpaceBtn(true)
		elseif self.SpaceThrowTarget and not target then
			gBattleMgr:EnableGrappleSpaceBtn(false)
		end

		self.SpaceThrowTarget = target
	end
end

M.FollowPlayerList = {}

function M:RegisterFollowPlayer(entityId, obj, maxSpeed, followRate, offset)
	self.FollowPlayerList[entityId] = {
		obj = obj,
		maxSpeed = maxSpeed,
		followRate = followRate,
		offset = offset
	}

	self:CheckNeedToUpdate()
end

function M:UnRegisterFollowPlayer(entityId)
	self.FollowPlayerList[entityId] = nil

	self:CheckNeedToUpdate()
end

function M:RefreshFollowPlayer()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	for entityId, data in pairs(self.FollowPlayerList) do
		local targetPos = gCS.MyPlayerManager.PlayerUnit.PlayerObj:TransformPoint(data.offset)
		local dir = targetPos - data.obj.position
		local dis = dir.magnitude
		local newPos = targetPos
		local newDelt = math.min(dis * data.followRate, data.maxSpeed * Time.deltaTime)

		if newDelt < dis then
			newPos = data.obj.position + dir.normalized * newDelt
		end

		data.obj.position = newPos
	end
end

function M:RegisterMindDice(entityId, data)
	self.MindDiceList[entityId] = data

	self:CheckNeedToUpdate()
end

function M:UnRegisterMindDice(entityId)
	self.MindDiceList[entityId] = nil

	self:CheckNeedToUpdate()
end

function M:RefreshDiceMind()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	for entityId, data in pairs(self.MindDiceList) do
		local maxTrans = data.posList[1]

		for i, trans in ipairs(data.posList) do
			if maxTrans.position.y < trans.position.y then
				maxTrans = trans
			end
		end

		local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
		local dirList = {
			maxTrans:TransformDirection(Vector3.right),
			maxTrans:TransformDirection(Vector3.left),
			maxTrans:TransformDirection(Vector3.forward),
			maxTrans:TransformDirection(Vector3.back)
		}
		local minDis = 999
		local minDir = dirList[1]

		for i, v in ipairs(dirList) do
			local dis = Vector3.Distance(playerPos, maxTrans.position + v * data.diceRadius)

			if dis < minDis then
				minDis = dis
				minDir = v
			end
		end

		data.target.position = maxTrans.position + minDir * data.diceRadius
		data.target.rotation = Quaternion.LookRotation(minDir)
	end
end

function M:RegisterHackInteract(key, data)
	if type(data) ~= "table" then
		data = data:ToTable()
		data.btnTextIds = data.btnTextIds:ToTable()
		data.btnState = data.btnState:ToTable()
		data.btnHackTypeIds = data.btnHackTypeIds:ToTable()
		data.usefulBtns = data.usefulBtns:ToTable()

		if data.GetTarget then
			local func = data.GetTarget

			function data.GetTarget()
				return func:DynamicInvoke()
			end
		end

		for i, v in ipairs(data.usefulBtns) do
			data.usefulBtns[i] = v:ToTable()
		end
	end

	self.HackInteractList[key] = data

	self:CheckNeedToUpdate()
end

function M:UnRegisterHackInteract(key)
	if self.HackInteractList[key] ~= nil then
		self.HackInteractList[key] = nil
	end

	self:CheckNeedToUpdate()
end

function M:GetHackInteractData(key)
	return self.HackInteractList[key]
end

function M:RefreshHackInteract()
	if not self:NeedRefreshHackTarget() then
		return
	end

	local target = nil
	local minAngle = 90
	local camPos = gCS.CameraDataMgr.MainCamera.transform.position
	local camDir = gCS.CameraDataMgr.MainCamera.transform.forward

	if self:HasGlobalHackBuff() then
		for key, data in pairs(self.HackInteractList) do
			local targetTrans = data.target

			if not targetTrans and data.GetTarget then
				targetTrans = data.GetTarget()
			end

			if gCS.LuaUtils.IsNull(targetTrans) then
				-- Nothing
			else
				local pos = targetTrans.position

				if self:CheckHackCondition(data, camPos, pos) then
					local angle = Vector3.Angle(pos - camPos, camDir)

					if angle < minAngle then
						minAngle = angle
						target = data
					end
				end
			end
		end
	end

	self:RefreshPedestrianHackTarget()

	if self.pedestrianHackTarget and self.pedestrianHackTarget.angle < minAngle then
		target = self.pedestrianHackTarget
	end

	self:SetHackTarget(target)
	gMainMenuMgr:SetWallJumpStateByInturn(target == nil)
end

function M:HasGlobalHackBuff()
	if L50.L50App.Scene.GamePlayUtils:IsNotPeople(gCS.MyPlayerManager.PlayerUnit) then
		return true
	end

	return L50.L50App.Scene.HackManager.debugHackIgnoreBuff or gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.BuffConfig.HackingAbility)
end

function M:RefreshPedestrianHackTarget()
	self:SetPedestrianHackTarget(L50.L50App.Scene.HackManager.hackInfoTarget, L50.L50App.Scene.HackManager.hackInfoAngle)
end

M.pedestrianHackTarget = nil

function M:SetPedestrianHackTarget(cs_unit, angle)
	if not cs_unit then
		self.pedestrianHackTarget = nil

		return
	end

	if not self.pedestrianHackTarget then
		self.pedestrianHackTarget = {
			isItem = false,
			useNpcCfg = true,
			interactType = 1
		}
	end

	if self.pedestrianHackTarget.entityId ~= cs_unit.Pid then
		self.pedestrianHackTarget.entityId = cs_unit.Pid
		self.pedestrianHackTarget.unit = cs_unit
		local go = cs_unit.PlayerObj.gameObject

		function self.pedestrianHackTarget.GetTarget()
			if L50.L50App.Scene.GamePlayUtils:UnitIsNull(cs_unit) then
				return nil
			end

			if cs_unit.ModelSlot then
				return cs_unit.ModelSlot.upbody
			end

			return cs_unit.PlayerObj
		end

		self.pedestrianHackTarget.go = go
	end

	self.pedestrianHackTarget.angle = angle
end

function M:CheckHackCondition(data, camPos, pos)
	if gGadgetManager.curHackCameraEntityId == data.entityId then
		return false
	end

	if data.dis < Vector3.Distance(gGadgetManager.hackCameraPanelStore and camPos or gCS.MyPlayerManager.PlayerUnit.LocalPosition, pos) then
		return false
	end

	if not self:SummonedTypeHackAble(data) then
		return false
	end

	if not L50.L50App.Scene.HackManager:CheckEntityItemVisiable(camPos.x, camPos.y, camPos.z, pos.x, pos.y, pos.z, 0.1, 100, data.go) then
		return false
	end

	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(pos)

	if screenPos.x < 0 or UnityEngine.Screen.width < screenPos.x or screenPos.y < 0 or UnityEngine.Screen.height < screenPos.y then
		return false
	end

	return true
end

function M:SummonedTypeHackAble(data)
	if not data.onlySummonedInteract then
		return L50.L50App.Scene.GamePlayUtils:DefaultCanHack()
	else
		return L50.L50App.Scene.GamePlayUtils:TypeContainsSummoned(data.summonedType)
	end
end

function M:SummonedTypeAreaTriggerAble(unit, onlySummonedInteract, summonedType)
	if not onlySummonedInteract then
		return L50.L50App.Scene.GamePlayUtils:DefaultCanAreaTrigger(unit)
	else
		return L50.L50App.Scene.GamePlayUtils:TypeContainsSummoned(summonedType, unit)
	end
end

function M:NeedRefreshHackTarget()
	if not gCS.MyPlayerManager.PlayerUnit then
		return false
	end

	if gHackManager.isShowHackInfoPanel then
		if self.HackInteractTarget and self.HackInteractTarget.interactType == 2 then
			return true
		else
			return false
		end
	end

	return true
end

M.oldHackTargetPid = nil

function M:SetHackTarget(target)
	if target and self.oldHackTargetPid == target.entityId or not self.oldHackTargetPid and not target then
		return
	end

	self:OnHackTargetChange(self.HackInteractTarget, target, self.oldHackTargetPid)

	if target then
		self.oldHackTargetPid = target.entityId
		self.hackBtnShow = true

		gMessageManager:SendMessage(gEventConstants.HACK_BTN_SHOW, true)
	else
		self.oldHackTargetPid = nil
		self.hackBtnShow = false

		gMessageManager:SendMessage(gEventConstants.HACK_BTN_SHOW, false)
	end

	self.HackInteractTarget = target

	self:CheckNeedToUpdate()
end

M.hackEffectList = {}
M.hackViewEffect = nil
M.gmBanHackSelectEffect = false

function M:BanHackSelectEffect(ban)
	self.gmBanHackSelectEffect = ban
end

function M:OnHackTargetChange(oldTarget, newTarget, oldPid)
	if oldTarget then
		local UUID = self.hackEffectList[oldPid]

		if UUID then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(UUID)

			self.hackEffectList[oldPid] = nil
		end
	end

	if newTarget then
		if newTarget.interactType == 2 then
			gGadgetManager:SetHackInfoPanel(true, newTarget, false)
		end

		if self.gmBanHackSelectEffect then
			return
		end

		if newTarget.isItem then
			local UUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(LTConfig.HackerConfig.HackingEffect_Jiguan, "hack" .. ulong.tostring(newTarget.entityId), newTarget.go)
			self.hackEffectList[newTarget.entityId] = UUID
		else
			local UUID = gCS.EffectMgr:PlayEffectsForUnitId(newTarget.entityId, LTConfig.HackerConfig.HackingEffect_Npc)
			self.hackEffectList[newTarget.entityId] = UUID
		end
	elseif oldTarget and oldTarget.interactType == 2 then
		gGadgetManager:SetHackInfoPanel(false)
	end
end

function M:OnHackItemView(isEnter, target)
	if isEnter then
		local UUID = self.hackEffectList[target.entityId]

		if UUID then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(UUID)

			self.hackEffectList[target.entityId] = nil
		end

		if target.isItem then
			local UUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(LTConfig.HackerConfig.HackingEffect_Jiguan_miaobian, "hack" .. ulong.tostring(target.entityId), target.go)
			self.hackViewEffect = UUID
		else
			local UUID = gCS.EffectMgr:PlayEffectsForUnitId(target.entityId, LTConfig.HackerConfig.HackingEffect_Npc_miaobian)
			self.hackViewEffect = UUID
		end
	else
		if self.hackViewEffect then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.hackViewEffect)

			self.hackViewEffect = nil
		end

		if target.interactType ~= 2 then
			if target.isItem then
				local UUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(LTConfig.HackerConfig.HackingEffect_Jiguan, "hack" .. ulong.tostring(target.entityId), target.go)
				self.hackEffectList[target.entityId] = UUID
			else
				local UUID = gCS.EffectMgr:PlayEffectsForUnitId(target.entityId, LTConfig.HackerConfig.HackingEffect_Npc)
				self.hackEffectList[target.entityId] = UUID
			end
		end
	end
end

function M:SetHackInfoPanel(open, data, isPress)
	if open then
		if isPress then
			if data.isItem then
				gSpoonClientMgr:ReleaseContextEvent(data.entityId, gSpoonEventType.HackPressInfoTrigger)
			elseif gGadgetManager.HackInteractTarget.hackerId then
				gClientToGameSceneDelegate:AskHackingNpcPress(gGadgetManager.HackInteractTarget.entityId).Callback = function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:ShowMessage(err)
						print_error("AskHackingNpcPress err = ", err, gGadgetManager.HackInteractTarget.entityId, gCS.MyPlayerManager.PlayerUnit.LocalPosition)
					end
				end
			end
		end

		data.isPress = isPress

		if not gInteractionManager.hackInfoShow then
			gInteractionManager.hackInfoShow = true

			gPanelManager:CheckShow(gPanelId.HACKER_INFO, data)
		end

		self.hackInfoTargetId = data.entityId

		self:OnHackItemView(true, data)
		gMessageManager:SendMessage(gEventConstants.HACK_RING_SHOW, true)
	else
		gMessageManager:SendMessage(gEventConstants.HACK_RING_SHOW, false)

		gInteractionManager.hackInfoShow = false

		gPanelManager:Close(gPanelId.HACKER_INFO)
	end
end

function M:DoHackClickAction()
	gCS.TransitionMgr.hackClick = true

	gCS.LuaUtils.CheckSwitchAction(false, true, false, 0)

	gCS.TransitionMgr.hackClick = false

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8503)
end

function M:DoHackPressClickAction()
	gCS.TransitionMgr.hackPressClick = true

	gCS.LuaUtils.CheckSwitchAction(false, true, false, 0)

	gCS.TransitionMgr.hackPressClick = false

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8503)
end

function M:OnClickHackBtn(index, textId)
	local target = gGadgetManager.HackInteractTarget

	if not target then
		return
	end

	if not target.hackerId then
		local npcTextIds = L50.L50App.Scene.HackManager:GetUnitHackBtns(target.unit):ToTable()
		local textId = npcTextIds[index]
		local unit = target.unit

		self:AskHack(nil, function (success)
			if not success then
				gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8505)

				return
			end

			gGadgetManager:DoHackPressClickAction()

			local skillType = L50.L50App.Scene.HackManager:OnClickHackNpc(unit, textId)

			gInteractionManager.hintInfosHudStore:AddHackSkillIcon(unit, skillType)
			gGadgetManager:SetHackInfoPanel(false)
		end)

		return
	end

	local clickAbleBtns = {}

	for i = 1, #target.usefulBtns do
		local btn = target.usefulBtns[i]

		if btn.state == 0 then
			table.insert(clickAbleBtns, btn)
		end
	end

	if #clickAbleBtns == 0 then
		return
	end

	local data = clickAbleBtns[index]

	if data.state ~= 0 then
		return
	end

	local realIndex = data.index - 1

	self:AskHack(data.index, function (success)
		if not success then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8505)

			return
		end

		gGadgetManager:DoHackPressClickAction()

		if target.isItem then
			gSpoonClientMgr:ReleaseContextEvent(target.entityId, gSpoonEventType.HackInteractTrigger, {
				index = realIndex
			})
		else
			gClientToGameSceneDelegate:AskHackingNpc(target.entityId, realIndex).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:ShowMessage(err)
					print_error("AskHackingNpc err = ", err, realIndex, self.HackInteractTarget)
				end
			end
		end
	end)

	if gHackManager.isShowHackInfoPanel and target.interactType ~= 2 then
		self:SetHackInfoPanel(false)
	end
end

function M:AgentExistHackIcon(pid)
	if not self.HackInteractTarget then
		return false
	end

	if not gGadgetManager.HackInteractTarget.isItem and self.HackInteractTarget.entityId == pid then
		return true
	end

	return false
end

M.lastAskHackTime = 0

function M:AskHack(index, cb)
	if Time.time - self.lastAskHackTime < 0.5 then
		return true
	end

	self.lastAskHackTime = Time.time

	if not gGadgetManager.HackInteractTarget then
		return true
	end

	local id = 1

	if gGadgetManager.HackInteractTarget.btnHackTypeIds then
		id = gGadgetManager.HackInteractTarget.btnHackTypeIds[index] or 1
	end

	if id == 0 then
		print_error("AskHack 配置Hacker表的HackTypeId异常，请策划检查配置：", index)

		id = 1
	end

	local cfg = LTConfig.HackerHackTypeConfig.GetConfig(id)

	if Mathf.Floor(gInteractionManager.hackInfo.BatteryCurrentCount) < cfg.HackCost then
		return false
	end

	gClientToGameDelegate:AskHack(id).Callback = function (err)
		if cb then
			local success = err == LTConfig.MessageConfig.Ok

			cb(success)
		end
	end

	return true
end

function M:SetHackCamera(open, entityId, target, xRange, yRange, defaultAngle, fov, useTelescope, showWarnOnce)
	if open then
		gStoreManager:GetStoreGroup("CoreHudGameplayControlStore"):StopGameplayByName("HackInteract")
		gStoreManager:GetStoreGroup("CoreHudGameplayControlStore"):StartGameplayByName("HackInteract", {
			fov = fov,
			useTelescope = useTelescope,
			target = target,
			defaultAngle = defaultAngle,
			xRange = xRange,
			yRange = yRange,
			showWarnOnce = showWarnOnce
		})
		gCS.CameraDataMgr.cinemachineManager:EnableFirstPersonCamera(target, Vector3.zero, xRange, yRange, defaultAngle, 1, false)

		gGadgetManager.curHackCameraEntityId = entityId

		gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.GadgetHackCamera, entityId ~= nil)
	else
		gMessageManager:SendMessage(gEventConstants.HACKER_CAMERA_PANEL_EXIT_ANIM)
	end
end

function M:SetHackBtnState(key, index, btnState, nodeId)
	local data = gGadgetManager:GetHackInteractData(key)

	if not data then
		return
	end

	data.btnState[index] = btnState
	local newIds = {}

	for k, v in ipairs(data.btnHackTypeIds) do
		if data.btnState[k] ~= 2 then
			local typeId = data.btnHackTypeIds[k]

			if not typeId or typeId == 0 then
				typeId = 1
			end

			local textId = LTConfig.HackerHackTypeConfig.GetConfig(typeId).HackTextid

			table.insert(newIds, {
				id = textId,
				index = k,
				state = data.btnState[k] or 0
			})
		end
	end

	data.usefulBtns = newIds

	if gInteractionManager.hintInfosHudStore then
		gInteractionManager.hintInfosHudStore:RefreshHackIndicateState(key, nodeId, btnState == 1)
	end
end

function M:GetFeiSuoTarget()
	if not self.HackInteractTarget then
		return nil
	end

	return self.HackInteractTarget.target
end

M.TerrainKillingList = {}

function M:RegisterTerrainKilling(pid, dict)
	local data = dict:ToTable()
	data.exTransList = data.exTransList:ToTable()

	if not self.TerrainKillingList[pid] then
		self.TerrainKillingList[pid] = {}
	end

	for i, v in ipairs(self.TerrainKillingList[pid]) do
		if v.entityId == data.entityId and v.pointIndex == data.pointIndex then
			return
		end
	end

	table.insert(self.TerrainKillingList[pid], data)
end

function M:UnRegisterTerrainKilling(pid, entityId, pointIndex)
	if not pid or ulong.equals(pid, 0) then
		for pidKey, v in pairs(self.TerrainKillingList) do
			for i = #v, 1, -1 do
				if v[i].entityId == entityId and v[i].pointIndex == pointIndex then
					table.remove(v, i)

					if #v == 0 then
						self.TerrainKillingList[pidKey] = nil

						break
					end
				end
			end
		end

		return
	end

	if not self.TerrainKillingList[pid] then
		return
	end

	for i, v in ipairs(self.TerrainKillingList[pid]) do
		if v.entityId == entityId and v.pointIndex == pointIndex then
			table.remove(self.TerrainKillingList[pid], i)
		end
	end

	if #self.TerrainKillingList[pid] == 0 then
		self.TerrainKillingList[pid] = nil
	end
end

function M:GetTerrainKillingList()
	return self.TerrainKillingList
end

function M:OnTriggerTerrainKillingAnim(pid, targetTrans)
	if not self.TerrainKillingList[pid] then
		return
	end

	for i, v in ipairs(self.TerrainKillingList[pid]) do
		if v.targetTrans == targetTrans then
			gSpoonClientMgr:ReleaseContextEvent(v.entityId, gSpoonEventType.MessageTrigger, {
				message = gEventConstants.GADGET_TERRAIN_KILLING,
				param = v.pointIndex
			})
		end
	end
end

gGadgetManager = M
