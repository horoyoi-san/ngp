-- Original chunk: @Lua\LuaFiles\LX6\Gadget\GadgetManager.lua
-- Decompiled from: 00352_GadgetManager.lua_1876d8b2a76f.luajit

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
M.HackInteractList = {}
M.HunePoolTargetList = {}
M.lastHunePoolTime = 0
M.gadgetParamTmp = {}
M.creatorIdToInstanceIdMap = {}
M.FeiSuoData = DataSet.New({
	["++3\\xc2r\\x8a\\xd18\\xb1\\xe7\\xe0\\xe1q\\xef"] = false
})
M.taskPlayFeiSuoData = {
	["zTݩ\\x85\\xbb\\xe0\\xec"] = 9999992,
	["i*rL"] = false,
	GpsType = gTaskGpsType.TaskPlayFeiSuo,
	TargetPos = Vector3.zero
}
M.taskPlaySpaceThrowData = {
	["zTݩ\\x85\\xbb\\xe0\\xec"] = 9999993,
	["i*rL"] = false,
	GpsType = gTaskGpsType.SpaceThrow,
	TargetPos = Vector3.zero
}
M.startPressTime = 0
local lastLNormalUpdateTime = 0
local eventHandler = {
	[gEventConstants.L50_BEFORE_SWITCH_SCENE] = function (eventId, switchSceneEventParams)
		local switchType = switchSceneEventParams.switchSceneType

		if switchType ~= gSwitchSceneType.Reconnect then
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
	[gEventConstants.HACK_TARGET_CHANGE] = function (eventId, data)
		M:CheckNeedToUpdate()
	end
}

M.OnInit = function(self)
	for k, v in pairs(eventHandler) do
		gMessageManager:AddMessageListener(k, v)
	end
end

M.OnUpdate = function(self, force)
	local isCanNormalUpdate = false

	self:SendEntityAttack()

	local currentTime = Time.time

	if currentTime <= lastLNormalUpdateTime + 0.1 then
		isCanNormalUpdate = true
		lastLNormalUpdateTime = currentTime
	end

	if isCanNormalUpdate or force then
		self:RefreshFeiSuoTarget()
		self:RefreshHackInteract()
	end

	self:RefreshFollowPlayer()

	if not force then
		self:CheckNeedToUpdate()
	end
end

M.isInUpdate = false

M.CheckNeedToUpdate = function(self)
	local isNeedSendEntityAttack = not table.isNilOrEmpty(M.combineAttackCache)
	local isNeedFeiSuoTarget = not table.isNilOrEmpty(M.FeiSuoTargetList)
	local isNeedHunePoolTarget = not table.isNilOrEmpty(M.HunePoolTargetList)
	local isNeedHackInteract = not table.isNilOrEmpty(M.HackInteractList)
	local isNeedDiceMind = not table.isNilOrEmpty(M.MindDiceList)
	local isNeedFollowPlayer = not table.isNilOrEmpty(M.FollowPlayerList)
	local isNeedHackPedestrian = L50.L50App.Scene and L50.L50App.Scene.HackManager.hackUnitTarget == nil
	local isNeedHackVehicle = L50.L50App.Scene and L50.L50App.Scene.HackManager.hackVehicleTarget == nil
	local isNeedUpdate = isNeedSendEntityAttack or isNeedFeiSuoTarget or isNeedHunePoolTarget or isNeedHackInteract or isNeedDiceMind or isNeedFollowPlayer or isNeedHackPedestrian or isNeedHackVehicle

	if isNeedUpdate and not self.isInUpdate then
		gLuaClient:RegisterDynamicUpdate("gGadgetManager", self)

		self.isInUpdate = true
	elseif not isNeedUpdate and self.isInUpdate then
		gLuaClient:UnregisterDynamicUpdate("gGadgetManager")
		self:OnUpdate(true)

		self.isInUpdate = false
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType then
		self.taskSpoonSlotList = {
			{},
			{}
		}
		self.FeiSuoTargetList = {}
		self.HunePoolTargetList = {}
		self.lookAtEntityList = {}
		self.FeiSuoTarget = nil

		gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.GadgetFeiSuoTarget, false)

		self.HackInteractList = {}
		self.clientGadgetList = {}
		self.HackInteractTarget = nil
		self.hackInfoTargetId = nil

		self:SetHackTarget(nil)

		self.MindDiceList = {}

		gMessageManager:SendMessage(gEventConstants.REMOVE_SCENE_HINT, self.taskPlayFeiSuoData)
		gMessageManager:SendMessage(gEventConstants.REMOVE_SCENE_HINT, self.taskPlaySpaceThrowData)

		self.indicatorLoadWaiting = {}
		self.taskSpoonGroupSlotList = {}
		self.taskSpoonSingleSlotList = {}
	end

	if gSwitchSceneType.NewScene < switchType then
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

M.AskToGetSlotEntityId = function(self, parentId, templateId)
	local entityId = _allocateIdBase + parentId % 1000 * 1000 + templateId % 1000

	return entityId
end

M.miniMapList = {}
M.headTitleList = {}

M.AddSlotMiniMap = function(self, entity, icon)
	local entityId = self:GetEntityId(entity)

	if entityId ~= nil then
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

M.ClearAllHud = function(self)
	for i, v in pairs(M.headTitleList) do
		if v then
			gHudMgr:DestroySlotEntityTarget(i)
		end
	end
end

M.RemoveSlotMiniMap = function(self, entity)
	local entityId = self:GetEntityId(entity)

	if entityId ~= nil then
		return
	end

	if not self.miniMapList[entityId] then
		return
	end

	self.miniMapList[entityId] = nil

	gMessageManager:SendMessage(gEventConstants.MAP_LUA_SLOT_REMOVE, entityId)
end

M.FeiSuoType = {
	["\\x84\\xa4\\x99k0\\xf96"] = 1,
	["M#qW"] = 3,
	["2G\\x83\\x83\\x82M"] = 2
}
M.FeiSuoSide = {
	["^-jU"] = 2,
	["5"] = 1,
	["V'{O"] = 3,
	["\\xa7\\xa5\\xa7\\xa2"] = 4
}
M.breakWindowPos2 = Vector3.zero

M.OnTryFeiSuo = function(self)
	if not self.FeiSuoTarget then
		return false
	end

	self.curFeiSuoTargetId = self.FeiSuoTarget.entityId
	self.curFeiSuoIndex = self.FeiSuoTarget.index

	gSpoonClientMgr:ReleaseContextEvent(self.curFeiSuoTargetId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.FeiSuoTrigger, {
		["n;m^"] = 0,
		index = self.curFeiSuoIndex
	})

	local playerUnit = gCS.MyPlayerManager.PlayerUnit

	if self.FeiSuoTarget.actionType then
		if L50.L50App.Scene.GamePlayUtils:CanTriggerGadgetABP(self.FeiSuoTarget.actionType) then
			if self.FeiSuoTarget.actionList.Length ~= 0 then
				print_error("OnTryFeiSuo 飞索动作列表为空", self.curFeiSuoTargetId)

				return false
			end

			gCS.DestroyWindowModuleMgr.GadgetInitList(playerUnit, self.FeiSuoTarget.actionType, self.FeiSuoTarget.actionList, self.FeiSuoTarget.actionList[0].forward)
			playerUnit:AddGameplayTagById(1337)
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

	if ropePos ~= nil then
		ropePos = pos1 + Vector3.up * 5
	end

	local feiSuoType = self.FeiSuoTarget.feiSuoType

	if feiSuoType ~= SpoonFeiSuoType.DownFlip then
		self.breakWindowPos2 = pos1
	end

	local isOnDownFlip = feiSuoType ~= SpoonFeiSuoType.DownFlip and Vector3.Distance(playerUnit.LocalPosition, pos1) <= self.FeiSuoTarget.flipRadius

	print_debug("[DestroyWindow] midPointPos", midPointPos, "feiSuoType", feiSuoType, "pos1", pos1, "pos2", pos2, "posType", posType, "ropePos", ropePos, "sideType", sideType, "isOnDownFlip", isOnDownFlip)

	local downFlipMidPos = self.FeiSuoTarget.actionTrans.position + Vector3.up * 2

	if feiSuoType ~= SpoonFeiSuoType.FlyThrow then
		local list = {
			self.FeiSuoTarget.actionTrans,
			self.FeiSuoTarget.actionEndTrans,
			self.FeiSuoTarget.endWallTrans
		}

		gCS.DestroyWindowModuleMgr.GadgetInitList(playerUnit, ActionTransitionRuleTypesConfig.GadgetTypeType.WallThrough, list, targetForward)
	elseif feiSuoType ~= SpoonFeiSuoType.VentilatingPipeOut then
		gCS.DestroyWindowModuleMgr.SetCacheClimbDestEdge(playerUnit, pos1, pos2, targetForward, pos1, feiSuoType, sideType)
		gCS.DestroyWindowModuleMgr.SetWorldEvent(playerUnit)
	elseif isOnDownFlip then
		gCS.DestroyWindowModuleMgr.SetCacheClimbDestEdge(playerUnit, downFlipMidPos, pos2, targetForward, pos1, feiSuoType, sideType)
		gCS.LuaUtils.CheckTimeLine(19, 0, 0)
	elseif feiSuoType == SpoonFeiSuoType.DestroyWindow or feiSuoType ~= SpoonFeiSuoType.DownFlip then
		sideType = 0

		gCS.DestroyWindowModuleMgr.SetCacheClimbDestEdge(playerUnit, self.breakWindowPos2, pos2, targetForward, ropePos, feiSuoType, sideType)

		local _, time = gFeiSuoCrouchManager:PlayFeisuoActionRotation(playerUnit.Pid, pos1, nil, gLuaFightConstants.FeisuoType_SlotFarInteract, nil)
	else
		if midPointPos == nil then
			self.breakWindowPos2 = midPointPos
		end

		self:AnyAngleBreakWindow(posType, pos2, sideType, ropePos, targetForward, flatY)
	end

	playerUnit:AddGameplayTagById(1337)

	return true
end

M.AnyAngleBreakWindow = function(self, posType, pos2, sideType, ropePos, targetForward, flatY)
	local pos1 = self.FeiSuoTarget.actionTrans.position

	print_debug("AnyAngleBreakWindow posType", posType, "sideType", sideType, "pos1", pos1, "pos2", pos2, "ropePos", ropePos, targetForward, flatY)

	if posType ~= M.FeiSuoType.Normal or posType ~= M.FeiSuoType.OutRange then
		gCS.DestroyWindowModuleMgr.SetCacheClimbDestEdge(gCS.MyPlayerManager.PlayerUnit, pos2, self.breakWindowPos2, targetForward, ropePos, self.FeiSuoTarget.feiSuoType, sideType)

		local _, time = gFeiSuoCrouchManager:PlayFeisuoActionRotation(gCS.MyPlayerManager.PlayerUnit.Pid, pos1, nil, gLuaFightConstants.FeisuoType_SlotFarInteract, nil)
	else
		gCS.DestroyWindowModuleMgr.SetCacheClimbDestEdge(gCS.MyPlayerManager.PlayerUnit, pos1, pos2, targetForward, ropePos, self.FeiSuoTarget.feiSuoType, sideType)
		gCS.LuaUtils.CheckTimeLine(15, 0, sideType)
	end
end

M.DestroyWindowDisOK = function(self)
	gSpoonClientMgr:ReleaseContextEvent(self.curFeiSuoTargetId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.FeiSuoTrigger, {
		["n;m^"] = 1,
		index = self.curFeiSuoIndex
	})
end

M.RegisterFeiSuo = function(self, entityId, index, data)
	if type(data) == "table" then
		data = data:ToTable()
		local func = data.GetTargetPos

		data.GetTargetPos = function()
			return gCS.LuaUtils.InvokeFuncVector3(func)
		end
	end

	if not self.FeiSuoTargetList[entityId] then
		self.FeiSuoTargetList[entityId] = {}
	end

	self.FeiSuoTargetList[entityId][index] = data

	self:CheckNeedToUpdate()
end

M.UnRegisterFeiSuo = function(self, entityId, index)
	if self.FeiSuoTarget and self.FeiSuoTarget.entityId ~= entityId and self.FeiSuoTarget.index ~= index then
		gMessageManager:SendMessage(gEventConstants.REMOVE_SCENE_HINT, self.taskPlayFeiSuoData)
	end

	if self.FeiSuoTargetList[entityId] and index then
		self.FeiSuoTargetList[entityId][index] = nil
	end

	self:CheckNeedToUpdate()
end

M.RefreshFeiSuoTarget = function(self)
	if not gCS.MyPlayerManager.PlayerUnit or not gCS.CameraDataMgr.MainCamera then
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
				local dis = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.HeadPos, targetPos)

				if dis <= 2 and dis >= data.dis and Vector3.Angle(data.targetTransform.forward, targetPos - playerPos) >= data.angle and L50.L50App.Scene.HackManager:CheckEntityItemVisiable(camPos.x, camPos.y, camPos.z, targetPos.x, targetPos.y, targetPos.z, 0.1, 100, data.go) then
					local angle = Vector3.Angle(targetPos - camPos, camDir)
					local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(targetPos)

					if screenPos.z > 0 and screenPos.x > 0 and UnityEngine.Screen.width > screenPos.x and screenPos.y > 0 then
						if UnityEngine.Screen.height >= screenPos.y then
							-- Nothing
						elseif angle >= minAngle then
							minAngle = angle
							target = data
						end
					end
				end
			end
		end
	end

	local needHideUI = gCS.PaoKuManager.ParkourStateLua ~= LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Feisuo or target == nil

	if self.needHideFeiSuoUI == needHideUI then
		self.needHideFeiSuoUI = needHideUI

		gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.GadgetFeiSuoTarget, self.needHideFeiSuoUI)
	end

	if self.FeiSuoTarget == target then
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

		gMessageManager:SendMessage(gEventConstants.UPDATE_SCENE_HINT, self.taskPlayFeiSuoData)
	end
end

M.FarClickAble = function(self)
	if self.curHackCameraEntityId then
		return false
	end

	if gCS.PaoKuManager.ParkourStateLua ~= LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.FeiSuoInteractive then
		return false
	end

	if not gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.GadgetFeiSuo) then
		return false
	end

	return true
end

M.GetCurFeiSuoPosType = function(self)
	if self.FeiSuoTarget.feiSuoType ~= 9 or self.FeiSuoTarget.feiSuoType ~= 10 or self.FeiSuoTarget.feiSuoType ~= 11 then
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

	if math.abs(playerLocalPos.x) >= math.abs(playerLocalPos.y) then
		if playerLocalPos.y <= 0 then
			side = M.FeiSuoSide.Up
		else
			side = M.FeiSuoSide.Down
		end
	elseif playerLocalPos.x >= 0 then
		side = M.FeiSuoSide.Left
	else
		side = M.FeiSuoSide.Right
	end

	local ropePos = nil

	if self.FeiSuoTarget.feiSuoType ~= 7 then
		ropePos = centerTrans.position
	else
		ropePos = centerTrans:TransformPoint(Vector3.New(0, ropeUp, 0))
	end

	if playerLocalPos.z <= -wallWidth then
		return M.FeiSuoType.Wall, side, nil, ropePos
	end

	local virtualPoint = centerTrans:TransformPoint(Vector3.New(0, 0, virtualOffset))
	local virtualSidePoint = centerTrans:TransformPoint(Vector3.New(virtualRadius, 0, 0))
	local virtualAngle = Vector3.Angle(virtualPoint - virtualSidePoint, centerTrans.forward)
	local playerAngle = Vector3.Angle(centerTrans.position - playerPos, centerTrans.forward)

	if playerAngle >= virtualAngle then
		return M.FeiSuoType.Normal, 0, nil, ropePos
	else
		return M.FeiSuoType.OutRange, side, centerTrans.position + -centerTrans.forward * midRadius, ropePos
	end
end

M.ModifySceneInterestPoint = function(self, entityId, isAdd, index, pid)
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
	elseif index ~= -1 then
		self.NpcSceneInteractList[entityId] = nil
	else
		self.NpcSceneInteractList[entityId][index] = nil
	end
end

M.ClearMetroInterestPoint = function(self, metroId)
	if not self.NpcMetroInteractList[metroId] then
		return
	end

	self.NpcMetroInteractList[metroId] = {}
end

M.ModifyMetroInterestPoint = function(self, metroId, entityId, isAdd, index)
	if entityId ~= -1 and not isAdd then
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

		if index ~= -1 then
			list[entityId] = nil
		else
			list[entityId][index] = nil
		end
	end
end

M.IsEntityIdInterestIndexUseful = function(self, entityId, index, pointId)
	local entity = self:GetEntitySearchByInstanceId(entityId, nil)

	if not entity then
		return true
	end

	return self:IsEntityInterestIndexUsefulHelper(entity, index, pointId)
end

M.IsEntityInterestIndexUsefulHelper = function(self, entity, index, pointId)
	if not pointId then
		return true
	end

	local pointIndex = entity:GetOccupyIndex(pointId)

	return self:IsEntityInterestIndexUseful(entity, pointIndex)
end

M.GetEntityIdInterestPointIndex = function(self, longChairPoints)
	local minIndex = 0
	local myUnit = gCS.MyPlayerManager.PlayerUnit

	if longChairPoints and myUnit then
		local playerObj = myUnit.PlayerObj
		local minDis = 100000

		for j, tran in ipairs(longChairPoints) do
			local dis = Vector3.Distance(playerObj.position, tran.position)

			if dis >= minDis then
				minDis = dis
				minIndex = j
			end
		end
	end

	return minIndex
end

M.CheckEntityInterestPoint = function(self, entity, buttonInfo)
	local minIndex = self:GetEntityIdInterestPointIndex(buttonInfo.longChairPoints)

	return self:IsEntityInterestIndexUsefulHelper(entity, minIndex, buttonInfo.longChairPointsId and buttonInfo.longChairPointsId[minIndex] or buttonInfo.interactPointsId)
end

M.SyncSetEntityIdInterestUseful = function(self, entityId, longChairPoints, longChairPointsId, interactPointsId, commonInteractType, callbackFunc, isNotAuto)
	local entity = self:GetEntitySearchByInstanceId(entityId, nil)

	if entity ~= nil then
		return
	end

	local minIndex = self:GetEntityIdInterestPointIndex(longChairPoints)
	local pointId = longChairPointsId and longChairPointsId[minIndex] or interactPointsId
	local pointIndex = entity:GetOccupyIndex(pointId)

	if pointIndex ~= nil or not isNotAuto and entity:CheckIsFreeOccupy(pointIndex) then
		callbackFunc()

		return
	end

	callbackFunc()
	gCoroutineManager:StartCoroutine(function ()
		while gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene or not gCS.NetworkManager.Instance:IsServerConnected() do
			coroutine.yield(nil)
		end

		gClientToGameSceneDelegate:CheckCanOccupySceneItem(UX.Game.SceneItemEntityType.Gadget, entityId, pointIndex, false).Callback = function (err)
			if err ~= MessageConfig.Ok then
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

M.SyncReleaseOccupySceneItem = function(self, entityId, isNotAuto)
	local index, data = self:CheckPlayerOccupy(entityId, true)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if index and data and (isNotAuto or not entity:CheckIsFreeOccupy(index)) then
		gClientToGameSceneDelegate:ReleaseOccupySceneItem(UX.Game.SceneItemEntityType.Gadget, entityId, index)
		self:ModifySceneInterestPoint(entityId, false, index)

		data[index] = nil
		self.playerOccupy = nil
	end
end

M.ReleasePlayerOccupy = function(self)
	if self.playerOccupy then
		gClientToGameSceneDelegate:ReleaseOccupySceneItem(UX.Game.SceneItemEntityType.Gadget, self.playerOccupy.entityId, self.playerOccupy.pointIndex)
		self:ModifySceneInterestPoint(self.playerOccupy.entityId, false, self.playerOccupy.pointIndex)

		self.playerOccupy = nil
	end
end

M.GetEntityInterestIndexUseful = function(self, entityId, index)
	if entityId ~= nil or index ~= nil then
		return nil
	end

	local data = self.NpcSceneInteractList[entityId]

	if data then
		return data[index]
	end
end

M.CheckPlayerOccupy = function(self, entityId, needCheckInteract)
	if entityId ~= nil then
		return nil
	end

	local data = self.NpcSceneInteractList[entityId]

	if data then
		for i, v in pairs(data) do
			if v ~= gCS.MyPlayerManager.PlayerUnit.Pid and (not needCheckInteract or not gInteractionManager.isCommonInteractMoving) then
				return i, data
			end
		end
	end

	return nil
end

M.IsEntityInterestIndexUseful = function(self, entity, index)
	local gadgetId = entity.entityInstanceId

	if not entity or not gadgetId or not index then
		return true
	end

	if gadgetId ~= 0 and entity.entityInstanceId then
		gadgetId = entity.entityInstanceId
	end

	local data = self.NpcSceneInteractList[gadgetId]

	if data then
		if data[index] then
			return gCS.MyPlayerManager.PlayerUnit.Pid ~= data[index]
		end

		return true
	end

	if entity:IsGadgetEntity() then
		local entityBindMetroId = entity.BindMetroId
		local list = self.NpcMetroInteractList[entityBindMetroId]

		if not list or not list[entity.entityInstanceId] or not list[entity.entityInstanceId][index] then
			return true
		end

		return false
	else
		return true
	end
end

M.IsEntityIdInterestUseful = function(self, entityId, maxIndex)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if not entity then
		return true
	end

	return self:IsEntityInterestUseful(entity, maxIndex)
end

M.CheckHasEntityInterestUsefulById = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if not entity then
		return true
	end

	local maxIndex = entity:GetMaxOccupy()

	return self:IsEntityInterestUseful(entity, maxIndex)
end

M.IsEntityInterestUseful = function(self, entity, maxIndex)
	local gadgetId = entity:GetGadgetCfgId()

	if not entity or not gadgetId then
		return true
	end

	if gadgetId ~= 0 and entity.entityInstanceId then
		gadgetId = entity.entityInstanceId
	end

	local data = self.NpcSceneInteractList[gadgetId]

	if data then
		if not maxIndex or maxIndex ~= -1 then
			return not data[-1]
		end

		if maxIndex and maxIndex > 1 then
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

	if not maxIndex or maxIndex ~= -1 then
		return not list[entity.entityInstanceId][-1]
	end

	for i = 0, maxIndex do
		if not list[entity.entityInstanceId][i] then
			return true
		end
	end

	return false
end

M.OnPickBasketball = function(self, entityId, pick, isMe)
	if pick then
		if isMe then
			self.currentBasketballEntityId = entityId

			gMessageManager:SendMessage(gEventConstants.SWITCH_BASKETBALL_SHOOTING_ENTER)

			local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

			gameplayControlStore:StartGameplayByType(gHUDGameplayType.BASKETBALL)
		end

		gSpoonClientMgr:ReleaseContextEvent(entityId, L50.Spoon.SpoonRunTime.ClientGraphType.SCENE_ITEM, gSpoonEventType.MessageTrigger, {
			message = gEventConstants.ON_PICK_BASKETBALL
		})
	else
		if isMe and (not self.currentBasketballEntityId or self.currentBasketballEntityId ~= entityId) then
			self.currentBasketballEntityId = nil

			gMessageManager:SendMessage(gEventConstants.SWITCH_BASKETBALL_SHOOTING_EXIT)
		end

		gSpoonClientMgr:ReleaseContextEvent(entityId, L50.Spoon.SpoonRunTime.ClientGraphType.SCENE_ITEM, gSpoonEventType.MessageTrigger, {
			message = gEventConstants.ON_RELEASE_BASKETBALL
		})
	end
end

M.interrogationData = {}

M.OnSelectInterrogation = function(self, index)
	if self.interrogationData[index] then
		return false
	end

	self.interrogationData[index] = true

	return true
end

M.ClearInterrogation = function(self)
	self.interrogationData = {}
end

M.GetNextInterrogation = function(self, index, isRight)
	local add = isRight and 1 or -1
	local next = index + add

	if next <= 3 then
		next = 1
	end

	if next >= 1 then
		next = 3
	end

	if not self.interrogationData[next] then
		return next
	end

	next = next + add

	if next <= 3 then
		next = 1
	end

	if next >= 1 then
		next = 3
	end

	if not self.interrogationData[next] then
		return next
	end

	next = next + add

	if next <= 3 then
		next = 1
	end

	if next >= 1 then
		next = 3
	end

	if not self.interrogationData[next] then
		return next
	end

	return index
end

M.CanInterrogation = function(self)
	for i = 1, 3 do
		if not self.interrogationData[i] then
			return true
		end
	end

	return false
end

M.GetGadgetEntityMindData = function(self, entityId)
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

M.GetGadgetEntityMindControlAble = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity then
		return entity.mindControlAble or false
	end

	return false
end

M.GetGadgetEntityStartSignal = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.startSignal
	end

	return nil
end

M.GetGadgetEntityFinishSignal = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.finishSignal
	end

	return nil
end

M.GetGadgetEntityStopSignal = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.stopSignal
	end

	return nil
end

M.GetGadgetEntityDragOnceSignal = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.dragOnceSignal
	end

	return nil
end

M.GetGadgetEntityDragOnceEndSignal = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.dragOnceEndSignal
	end

	return nil
end

M.GetGadgetEntityDragBreakSignal = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.dragBreakSignal
	end

	return nil
end

M.GetGadgetEntityIsDrag = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.IsDrag or false
	end

	return false
end

M.GetGadgetEntityIsPress = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.IsPress or false
	end

	return false
end

M.GetGadgetEntityIsClick = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.IsClick or false
	end

	return false
end

M.GetGadgetEntityPullableBase = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.dragComp
	end

	return nil
end

M.GetGadgetEntityShowInBattle = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.showInBattle or false
	end

	return false
end

M.GetGadgetEntityIsLocked = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.isLocked or false
	end

	return false
end

M.GetGadgetEntitySlotEffect = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.SlotEffect or 0
	end

	return 0
end

M.GetGadgetEntityPlayerEffect = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.PlayerEffect or 0
	end

	return 0
end

M.GetGadgetEntityClickSound = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.clickSound or 0
	end

	return 0
end

M.GetGadgetEntityPressStartSound = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.pressStartSound or 0
	end

	return 0
end

M.GetGadgetEntityPressEndSound = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.pressEndSound or 0
	end

	return 0
end

M.GetGadgetEntityDragType = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	if entity and entity.mindPowerParams then
		return entity.mindPowerParams.dragType or 0
	end

	return 0
end

M.clientGadgetList = {}

M.OnAddClientGadget = function(self, rootEntityId, entityId)
	if not self.clientGadgetList[rootEntityId] then
		self.clientGadgetList[rootEntityId] = {}
	end

	self.clientGadgetList[rootEntityId][entityId] = true
end

M.OnClearEntityIdClientGadget = function(self, entityId)
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

M.OnRemoveClientGadget = function(self, entityId)
	for rootEntityId, v in pairs(self.clientGadgetList) do
		if v[entityId] then
			v[entityId] = nil

			if table.is_empty(v) then
				self.clientGadgetList[rootEntityId] = nil

				gSpoonClientMgr:ReleaseContextEvent(rootEntityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.AllClientGadgetDestroy)
			end

			L50.L50App.Scene.GamePlayUtils:SetCreateClientGadgetRemove(rootEntityId, entityId)

			return
		end
	end
end

M.HackCameraPanelStore_SetFocus = function(self, open, target, duration)
	if gGadgetManager.hackCameraPanelStore then
		gGadgetManager.hackCameraPanelStore:SetFocus(open, target, duration)
	end
end

M.OnLongPressHackTrigger = function(self)
	local data = L50.L50App.Scene.HackManager.curSelectHackData

	if not data or data.locked then
		return
	end

	local entityId = data.entityId

	gSpoonClientMgr:ReleaseContextEvent(entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.HackLongPressTrigger)
end

M.GetInteractPosByPid = function(self, pid)
	local entity = self:GetEntitySearchByInstanceId(pid)
	local trans = entity.gameObject.transform:Find("InteractNode")
	trans = trans or entity.gameObject.transform

	return trans
end

M.GetEntitySearchByInstanceId = function(self, instanceId, isCreateBySpoon)
	return L50.L50App.Scene.SpoonGadgetManager:GetEntitySearchByInstanceId(instanceId)
end

M.ChangeGadgetState = function(self, entityId, stateType, state, isImmediately, needCheckLink)
	local entity = self:GetEntitySearchByInstanceId(entityId, false)

	if entity ~= nil then
		return
	end

	entity:SetGadgetState(stateType, state, isImmediately, needCheckLink)
end

M.GMChangeGadgetState = function(self, entityInstanceId, stateType, state, isImmediately, needCheckLink)
	L50.L50App.Scene.SpoonGadgetManager:GMChangeGadgetState(entityInstanceId, stateType, state)
end

M.ChangeGadgetValue = function(self, entityId, Key, Value)
	local entity = self:GetEntitySearchByInstanceId(entityId, false)

	if entity ~= nil then
		return
	end

	entity:SetGadgetValue(Key, Value, false)
end

M.DestroyGadgetById = function(self, entityId)
	local entity = self:GetEntitySearchByInstanceId(entityId, false)

	if entity ~= nil then
		return
	end

	UnityEngine.GameObject.DestroyImmediate(entity.gameObject)
end

local sendPack = {}
local FRAME_UPDATE_RATE = 5
local currentFrame = FRAME_UPDATE_RATE

M.SendEntityAttack = function(self)
	if currentFrame >= FRAME_UPDATE_RATE then
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
			if err == MessageConfig.Ok then
				print_error("AskTriggerLuaSlotEventAttack err =", err)
			end
		end

		needSend = false
	end

	table.clear(self.combineAttackCache)
end

M.GetEntityByTypeOtherName = function(self, typeName, otherName)
	if self.luaSlotEntityOtherName ~= nil then
		return
	end

	if self.luaSlotEntityOtherName[typeName] ~= nil then
		return
	end

	if self.luaSlotEntityOtherName[typeName][otherName] then
		return self.luaSlotEntityOtherName[typeName][otherName]
	end
end

M.GadgetSandbagAddDamage = function(self, val)
	local sandbagScreen = gGadgetManager:GetEntityByTypeOtherName("LuaSlotComponent", "SandbagScreen")

	if sandbagScreen then
		sandbagScreen:AddDamage(val)
	end
end

M.CheckUnitStateChangeEvent = function(self, pid, stateId, isAdd)
	local entitys = self.unitStateListen[pid]

	if entitys then
		for i, e in pairs(entitys) do
			if e and e.CheckUnitStateChange then
				e:CheckUnitStateChange(stateId, isAdd)
			end
		end
	end
end

M.GetEntityId = function(self, entity)
	if entity.entityInstanceId == 0 then
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

M.EntityBroadCastSignal = function(self, entityId, signal)
	local entity = self:GetEntitySearchByInstanceId(entityId)

	gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_OUT, {
		entity = entity,
		signalKey = signal
	})
end

M.OnSpaceThrowHintChange = function(self, show, startPos1, startPos2, targetTrans)
	self.taskPlaySpaceThrowData.show = show or false

	if show then
		self.taskPlaySpaceThrowData.GetNearPos = function(pos1, pos2)
			return L50.L50App.Scene.SpoonGadgetManager:SpaceThrowGetNearPos(pos1, pos2)
		end

		self.taskPlaySpaceThrowData.startPos1 = startPos1
		self.taskPlaySpaceThrowData.startPos2 = startPos2
		self.taskPlaySpaceThrowData.TargetTrans = targetTrans
	else
		self.taskPlaySpaceThrowData.TargetTrans = nil
	end

	gMessageManager:SendMessage(gEventConstants.ADD_SCENE_HINT, self.taskPlaySpaceThrowData)
end

M.FollowPlayerList = {}

M.RegisterFollowPlayer = function(self, entityId, obj, maxSpeed, followRate, offset)
	self.FollowPlayerList[entityId] = {
		obj = obj,
		maxSpeed = maxSpeed,
		followRate = followRate,
		offset = offset
	}

	self:CheckNeedToUpdate()
end

M.UnRegisterFollowPlayer = function(self, entityId)
	self.FollowPlayerList[entityId] = nil

	self:CheckNeedToUpdate()
end

M.RefreshFollowPlayer = function(self)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	for entityId, data in pairs(self.FollowPlayerList) do
		local targetPos = gCS.MyPlayerManager.PlayerUnit.PlayerObj:TransformPoint(data.offset)
		local dir = targetPos - data.obj.position
		local dis = dir.magnitude
		local newPos = targetPos
		local newDelt = math.min(dis * data.followRate, data.maxSpeed * Time.deltaTime)

		if newDelt >= dis then
			newPos = data.obj.position + dir.normalized * newDelt
		end

		data.obj.position = newPos
	end
end

M.RegisterMindDice = function(self, entityId, data)
	self.MindDiceList[entityId] = data

	self:CheckNeedToUpdate()
end

M.UnRegisterMindDice = function(self, entityId)
	self.MindDiceList[entityId] = nil

	self:CheckNeedToUpdate()
end

M.RegisterHackInteract = function(self, key, data)
	data = data:ToTable()
	data.btnTextIds = data.btnTextIds:ToTable()
	data.btnState = data.btnState:ToTable()
	data.btnHackTypeIds = data.btnHackTypeIds:ToTable()
	data.usefulBtns = data.usefulBtns:ToTable()

	if data.GetTargetPos then
		local func = data.GetTargetPos

		data.GetTargetPos = function()
			return gCS.LuaUtils.InvokeFuncVector3(func)
		end
	end

	for i, v in ipairs(data.usefulBtns) do
		data.usefulBtns[i] = v:ToTable()
	end

	if data.talentId and data.talentId == 0 then
		data.talentLocked = gTalentTreeMgr:CheckTalentIsLocked(data.talentId, 11300004)
	end

	self.HackInteractList[key] = data

	self:CheckNeedToUpdate()
end

M.UnRegisterHackInteract = function(self, key)
	if self.HackInteractList[key] == nil then
		self.HackInteractList[key] = nil
	end

	self:CheckNeedToUpdate()
end

M.GetHackInteractData = function(self, key)
	return self.HackInteractList[key]
end

M.hackTargetMinAngle = 360
M.HACK_TALENT_CHECK_INTERVAL = 5
M.lastTalentCheckFrame = 0

M.RefreshHackInteract = function(self)
	if not self:NeedRefreshHackTarget() then
		return
	end

	local frame = Time.frameCount

	if self.HACK_TALENT_CHECK_INTERVAL < frame - self.lastTalentCheckFrame then
		self.lastTalentCheckFrame = frame

		for _, data in pairs(self.HackInteractList) do
			if data.talentId and data.talentId == 0 then
				data.talentLocked = gTalentTreeMgr:CheckTalentIsLocked(data.talentId, 11300004)
			end
		end
	end

	local target = nil
	local minAngle = 90
	local camPos = gCS.CameraDataMgr.MainCamera.transform.position
	local camDir = gCS.CameraDataMgr.MainCamera.transform.forward

	if self:HasGlobalHackAble() then
		for key, data in pairs(self.HackInteractList) do
			local pos = data.GetTargetPos()

			if self:CheckHackCondition(data, camPos, pos) then
				local angle = Vector3.Angle(pos - camPos, camDir)

				if angle >= minAngle then
					minAngle = angle
					self.hackTargetMinAngle = minAngle
					target = data
				end
			end
		end
	end

	self:RefreshPedestrianAndVehicleHackTarget()

	if self.pedestrianHackTarget and self.pedestrianHackTarget.angle >= minAngle then
		minAngle = self.pedestrianHackTarget.angle
		self.hackTargetMinAngle = minAngle
		target = self.pedestrianHackTarget
	end

	if self.vehicleHackTarget and self.vehicleHackTarget.angle >= minAngle then
		minAngle = self.vehicleHackTarget.angle
		self.hackTargetMinAngle = minAngle
		target = self.vehicleHackTarget
	end

	if L50.L50App.Scene.HackManager.isLongPressHacking then
		target = nil
	elseif (SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice() or not gCS.LuaUtils.IsNonMobileAdaptive()) and L50.L50App.Scene.HackManager.curSelectHackData and L50.L50App.Scene.HackManager.longPressTargetMinAngle >= self.hackTargetMinAngle then
		target = nil
	end

	self:SetHackTarget(target)
	gMainMenuMgr:SetWallJumpStateByInturn(target ~= nil)
end

M.HasGlobalHackAble = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.COMPUTER_MAIN_PANEL) then
		return false
	end

	if not L50.L50App.Scene.HackManager.debugHackIgnoreBuff and not gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.BuffConfig.HackingAbility) and not gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, 52899024) then
		return false
	end

	if gCS.MyPlayerManager.PlayerUnit:HasGameplayTag(LTConfig.GameplayTagParentConfig.Motion_Special_Ball_Basketball_Withball) or gCS.MyPlayerManager.PlayerUnit:HasGameplayTag(LTConfig.GameplayTagParentConfig.Motion_Special_Ball_Basketball_Withoutball) then
		return false
	end

	return true
end

M.SyncHackIndicateState = function(self)
	L50.L50App.Scene.HackManager:SetHackIndicateState(self.hackInfoTargetId or 0, self.HackInteractTarget and self.HackInteractTarget.entityId or 0, self:HasGlobalHackAble())
end

M.RefreshPedestrianAndVehicleHackTarget = function(self)
	self:SetPedestrianHackTarget(L50.L50App.Scene.HackManager.hackUnitTarget, L50.L50App.Scene.HackManager.hackUnitAngle)
	self:SetVehicleHackTarget(L50.L50App.Scene.HackManager.hackVehicleTarget, L50.L50App.Scene.HackManager.hackVehicleAngle)
end

M.pedestrianHackTarget = nil

M.SetPedestrianHackTarget = function(self, cs_unit, angle)
	if not cs_unit then
		self.pedestrianHackTarget = nil

		return
	end

	if not self.pedestrianHackTarget then
		self.pedestrianHackTarget = {
			["fx\\xb8r^\\xb3\\xf1S^cnI"] = 1,
			hackTargetType = self.HackTargetType.AtmosphereNpc
		}
	end

	if self.pedestrianHackTarget.entityId == cs_unit.Pid then
		self.pedestrianHackTarget.entityId = cs_unit.Pid
		self.pedestrianHackTarget.unit = cs_unit
		local go = cs_unit.PlayerObj.gameObject

		self.pedestrianHackTarget.GetTargetPos = function()
			if L50.L50App.Scene.GamePlayUtils:UnitIsNull(cs_unit) then
				return Vector3.one * 999999
			end

			if cs_unit.ModelSlot and cs_unit.ModelSlot.upbody then
				return cs_unit.ModelSlot.upbody.position
			end

			return cs_unit.PlayerObj.position
		end

		self.pedestrianHackTarget.go = go
	end

	self.pedestrianHackTarget.angle = angle
end

M.HackTargetType = {
	[";I\\x95\\x89\\x86U"] = 0,
	["U\\xe8*\\xe3:''\\xc6s%\\xe3N\\x84A\\xca\\xe3"] = 4,
	["\\xed\\xda04\\xf2"] = 1,
	["#\\xf7R#\\xc0\\xb3S\\xa4x\\xa0\\xb5"] = 2,
	["\\xab534N\\x98I\\xd04\\xa6\\xbc"] = 3
}
M.vehicleHackTarget = nil

M.SetVehicleHackTarget = function(self, vehicle, angle)
	if not vehicle then
		self.vehicleHackTarget = nil

		return
	end

	if not self.vehicleHackTarget then
		self.vehicleHackTarget = {
			["fx\\xb8r^\\xb3\\xf1S^cnI"] = 1,
			hackTargetType = self.HackTargetType.AtmosphereVehicle
		}
	end

	if self.vehicleHackTarget.entityId == vehicle.uid then
		self.vehicleHackTarget.entityId = vehicle.uid
		self.vehicleHackTarget.vehicle = vehicle
		local go = vehicle.gameObject and not gCS.LuaUtils.IsNull(vehicle.gameObject) and vehicle.gameObject or nil

		self.vehicleHackTarget.GetTargetPos = function()
			local trans = L50.L50App.Scene.HackManager.hackVehicleTargetBone

			if gCS.LuaUtils.IsNull(trans) then
				return Vector3.one * 999999
			end

			return trans.position
		end

		self.vehicleHackTarget.go = go
	end

	self.vehicleHackTarget.angle = angle
end

M.CheckHackCondition = function(self, data, camPos, pos)
	if data.talentLocked then
		return false
	end

	if gGadgetManager.curHackCameraEntityId ~= data.entityId then
		return false
	end

	if data.dis >= Vector3.Distance(gGadgetManager.hackCameraPanelStore and camPos or gCS.MyPlayerManager.PlayerUnit.LocalPosition, pos) then
		return false
	end

	if not self:SummonedTypeHackAble(data) then
		return false
	end

	if not L50.L50App.Scene.HackManager:CheckEntityItemVisiable(camPos.x, camPos.y, camPos.z, pos.x, pos.y, pos.z, 0.1, 100, data.go) then
		return false
	end

	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(pos)

	if screenPos.z <= 0 or screenPos.x <= 0 or UnityEngine.Screen.width <= screenPos.x or screenPos.y <= 0 or UnityEngine.Screen.height >= screenPos.y then
		return false
	end

	return true
end

M.SummonedTypeHackAble = function(self, data)
	if not data.onlySummonedInteract then
		return L50.L50App.Scene.GamePlayUtils:DefaultCanHack()
	else
		return L50.L50App.Scene.GamePlayUtils:TypeContainsSummoned(data.summonedType)
	end
end

M.SummonedTypeAreaTriggerAble = function(self, unit, onlySummonedInteract, summonedType)
	if not onlySummonedInteract then
		return L50.L50App.Scene.GamePlayUtils:DefaultCanAreaTrigger(unit)
	else
		return L50.L50App.Scene.GamePlayUtils:TypeContainsSummoned(summonedType, unit)
	end
end

M.NeedRefreshHackTarget = function(self)
	if not gCS.MyPlayerManager.PlayerUnit then
		return false
	end

	if gHackManager:IsShowHackInfoPanel() then
		if self.HackInteractTarget and self.HackInteractTarget.interactType ~= 2 then
			return true
		else
			return false
		end
	end

	return true
end

M.oldHackTargetPid = nil

M.SetHackTarget = function(self, target)
	if target and self.oldHackTargetPid ~= target.entityId or not self.oldHackTargetPid and not target then
		return
	end

	self:OnHackTargetChange(self.HackInteractTarget, target, self.oldHackTargetPid)

	if target then
		self.oldHackTargetPid = target.entityId
	else
		self.oldHackTargetPid = nil
	end

	self.HackInteractTarget = target

	if not target then
		L50.L50App.Scene.HackManager:ClearHackEffect()
	end

	self:SyncHackIndicateState()
	gMessageManager:SendMessage(gEventConstants.HACK_BTN_REFRESH)
end

M.hackEffectList = {}
M.hackViewEffect = nil
M.gmBanHackSelectEffect = false

M.BanHackSelectEffect = function(self, ban)
	self.gmBanHackSelectEffect = ban
end

M.OnHackTargetChange = function(self, oldTarget, newTarget, oldPid)
	if oldTarget then
		local UUID = self.hackEffectList[oldPid]

		if UUID then
			if oldTarget.hackTargetType ~= gGadgetManager.HackTargetType.TaskVehicle or oldTarget.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
				L50.L50App.Scene.HackManager:StopVehicleHackEffect(UUID)
			elseif oldTarget.hackTargetType ~= gGadgetManager.HackTargetType.Gadget then
				L50.L50App.L50Game.GadgetMgr:StopHackGadgetEffect(oldTarget.entityId)
			else
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(UUID)
			end

			self.hackEffectList[oldPid] = nil
		end
	end

	if newTarget then
		if newTarget.interactType ~= 2 then
			gGadgetManager:SetHackInfoPanel(true, newTarget, false)
		end

		if self.gmBanHackSelectEffect then
			return
		end

		if newTarget.hackTargetType ~= gGadgetManager.HackTargetType.Gadget then
			local UUID = L50.L50App.L50Game.GadgetMgr:PlayHackGadgetEffect(newTarget.entityId, false)
			self.hackEffectList[newTarget.entityId] = UUID
		elseif newTarget.hackTargetType ~= gGadgetManager.HackTargetType.TaskNpc or newTarget.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereNpc then
			local UUID = gCS.EffectMgr:PlayEffectsForUnitId(newTarget.entityId, LTConfig.HackerConfig.HackingEffect_Npc, LX6.Effect.EffectPlayTag.Gameplay)
			self.hackEffectList[newTarget.entityId] = UUID
		elseif newTarget.hackTargetType ~= gGadgetManager.HackTargetType.TaskVehicle or newTarget.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
			local UUID = L50.L50App.Scene.HackManager:PlayVehicleHackEffect(LTConfig.HackerConfig.HackingEffect_Jiguan, newTarget.entityId, Vector3.zero)
			self.hackEffectList[newTarget.entityId] = UUID
		end
	elseif oldTarget and oldTarget.interactType ~= 2 then
		gGadgetManager:SetHackInfoPanel(false)
	end
end

M.OnHackItemView = function(self, isEnter, target)
	if isEnter then
		local UUID = self.hackEffectList[target.entityId]

		if UUID then
			if target.hackTargetType ~= gGadgetManager.HackTargetType.TaskVehicle or target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
				L50.L50App.Scene.HackManager:StopVehicleHackEffect(UUID)
			elseif target.hackTargetType ~= gGadgetManager.HackTargetType.Gadget then
				L50.L50App.L50Game.GadgetMgr:StopHackGadgetEffect(target.entityId)
			else
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(UUID)
			end

			self.hackEffectList[target.entityId] = nil
		end

		if target.hackTargetType ~= gGadgetManager.HackTargetType.Gadget then
			local UUID = L50.L50App.L50Game.GadgetMgr:PlayHackGadgetEffect(target.entityId, true)
			self.hackViewEffect = UUID
		elseif target.hackTargetType ~= gGadgetManager.HackTargetType.TaskNpc or target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereNpc then
			local UUID = gCS.EffectMgr:PlayEffectsForUnitId(target.entityId, LTConfig.HackerConfig.HackingEffect_Npc_miaobian, LX6.Effect.EffectPlayTag.Gameplay)
			self.hackViewEffect = UUID
		elseif target.hackTargetType ~= gGadgetManager.HackTargetType.TaskVehicle or target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
			local UUID = L50.L50App.Scene.HackManager:PlayVehicleHackEffect(LTConfig.HackerConfig.HackingEffect_Jiguan_miaobian, target.entityId, Vector3.zero)
			self.hackViewEffect = UUID
		end
	else
		if self.hackViewEffect then
			if target.hackTargetType ~= gGadgetManager.HackTargetType.TaskVehicle or target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
				L50.L50App.Scene.HackManager:StopVehicleHackEffect(self.hackViewEffect)
			elseif target.hackTargetType ~= gGadgetManager.HackTargetType.Gadget then
				L50.L50App.L50Game.GadgetMgr:StopHackGadgetEffect(target.entityId)
			else
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.hackViewEffect)
			end

			self.hackViewEffect = nil
		end

		if target.interactType == 2 then
			if target.hackTargetType ~= gGadgetManager.HackTargetType.Gadget then
				local UUID = L50.L50App.L50Game.GadgetMgr:PlayHackGadgetEffect(target.entityId, false)
				self.hackEffectList[target.entityId] = UUID
			elseif target.hackTargetType ~= gGadgetManager.HackTargetType.TaskNpc or target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereNpc then
				local UUID = gCS.EffectMgr:PlayEffectsForUnitId(target.entityId, LTConfig.HackerConfig.HackingEffect_Npc, LX6.Effect.EffectPlayTag.Gameplay)
				self.hackEffectList[target.entityId] = UUID
			elseif target.hackTargetType ~= gGadgetManager.HackTargetType.TaskVehicle or target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
				local UUID = L50.L50App.Scene.HackManager:PlayVehicleHackEffect(LTConfig.HackerConfig.HackingEffect_Jiguan, target.entityId, Vector3.zero)
				self.hackEffectList[target.entityId] = UUID
			end
		end
	end
end

M.SetHackInfoPanel = function(self, open, data, isPress)
	if open then
		if isPress then
			if data.hackTargetType ~= gGadgetManager.HackTargetType.Gadget then
				gSpoonClientMgr:ReleaseContextEvent(data.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.HackPressInfoTrigger)
			elseif gGadgetManager.HackInteractTarget.hackerId then
				local unit = gCS.SceneDataMgr.GetUnit(gGadgetManager.HackInteractTarget.entityId)

				if unit then
					local pressEntityId = gGadgetManager.HackInteractTarget.entityId

					gReliableRpcManager:RegisterRPC(gClientToGameSceneDelegate.AskHackingNpcPress, pressEntityId, function (err)
						if err == LTConfig.MessageConfig.Ok then
							gDisplayMessageMgr:ShowMessage(err)
							print_error("AskHackingNpcPress err = ", err, pressEntityId, gCS.MyPlayerManager.PlayerUnit.LocalPosition)
						end
					end)
				end
			end
		end

		data.isPress = isPress

		if not gHackManager:IsShowHackInfoPanel() then
			gPanelManager:CheckShow(gPanelId.HACKER_INFO, data)
		end

		self.hackInfoTargetId = data.entityId

		gMessageManager:SendMessage(gEventConstants.HACK_RING_SHOW, true)
	else
		gMessageManager:SendMessage(gEventConstants.HACK_RING_SHOW, false)
		gPanelManager:Close(gPanelId.HACKER_INFO)
		gMessageManager:SendMessage(gEventConstants.HACK_CLEAR_ANIM)

		self.hackInfoTargetId = nil
	end

	self:SyncHackIndicateState()
end

M.DoHackClickAction = function(self)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8503)
end

M.DoHackPressClickAction = function(self)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8503)
end

M.OnClickHackBtn = function(self, index, textId)
	local target = gGadgetManager.HackInteractTarget

	if not target then
		return
	end

	if not target.hackerId then
		local textId = 0

		if target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereNpc then
			local npcTextIds = L50.L50App.Scene.HackManager:GetUnitHackBtns(target.unit):ToTable()
			textId = npcTextIds[index] or 0
		elseif target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
			local vehicleTextIds = L50.L50App.Scene.HackManager:GetVehicleHackBtns(target.vehicle):ToTable()
			textId = vehicleTextIds[index] or 0
		end

		self:AskHack(nil, function (success)
			if not success then
				gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8505)

				return
			end

			gGadgetManager:DoHackPressClickAction()

			if target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereNpc then
				local skillType = L50.L50App.Scene.HackManager:OnClickHackNpc(target.unit, textId)

				gInteractionManager.hintInfosHudStore:AddHackSkillIcon(target.unit, skillType)
			elseif target.hackTargetType ~= gGadgetManager.HackTargetType.AtmosphereVehicle then
				L50.L50App.Scene.HackManager:OnClickHackVehicle(target.vehicle, textId)
			end

			gGadgetManager:SetHackInfoPanel(false)
		end)

		return
	end

	local clickAbleBtns = {}

	for i = 1, #target.usefulBtns do
		local btn = target.usefulBtns[i]

		if btn.state ~= 0 then
			table.insert(clickAbleBtns, btn)
		end
	end

	if #clickAbleBtns ~= 0 then
		return
	end

	local data = clickAbleBtns[index]

	if data.state == 0 then
		return
	end

	local realIndex = data.index - 1

	self:AskHack(data.index, function (success)
		if not success then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8505)

			return
		end

		gGadgetManager:DoHackPressClickAction()

		if target.hackTargetType ~= gGadgetManager.HackTargetType.Gadget then
			gSpoonClientMgr:ReleaseContextEvent(target.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.HackInteractTrigger, {
				index = realIndex
			})
		elseif target.hackTargetType ~= gGadgetManager.HackTargetType.TaskNpc then
			gReliableRpcManager:RegisterRPC(gClientToGameSceneDelegate.AskHackingNpc, target.entityId, realIndex, function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:ShowMessage(err)
					print_error("AskHackingNpc err = ", err, realIndex, self.HackInteractTarget)
				end
			end)
		elseif target.hackTargetType ~= gGadgetManager.HackTargetType.TaskVehicle then
			L50.L50App.Scene.HackManager:AskHackTaskVehicle(target.entityId, realIndex)
		end
	end)

	if gHackManager:IsShowHackInfoPanel() and target.interactType == 2 then
		self:SetHackInfoPanel(false)
	end
end

M.AgentExistHackIcon = function(self, pid)
	if not self.HackInteractTarget then
		return false
	end

	if not gGadgetManager.HackInteractTarget.hackTargetType ~= gGadgetManager.HackTargetType.Gadget and self.HackInteractTarget.entityId ~= pid then
		return true
	end

	return false
end

M.lastAskHackTime = 0

M.AskHack = function(self, index, cb)
	if Time.time - self.lastAskHackTime >= 0.5 then
		if cb then
			cb(false, true)
		end

		return
	end

	self.lastAskHackTime = Time.time

	if not gGadgetManager.HackInteractTarget then
		if cb then
			cb(false, true)
		end

		return
	end

	local id = 1

	if gGadgetManager.HackInteractTarget.btnHackTypeIds then
		id = gGadgetManager.HackInteractTarget.btnHackTypeIds[index] or 1
	end

	if id ~= 0 then
		print_error("AskHack 配置Hacker表的HackTypeId异常，请策划检查配置：", gGadgetManager.HackInteractTarget.entityId, index)

		id = 1
	end

	local cfg = LTConfig.HackerHackTypeConfig.GetConfig(id)

	if Mathf.Floor(gInteractionManager.hackInfo.BatteryCurrentCount) >= cfg.HackCost then
		if cb then
			cb(false, false)
		end

		return
	end

	gClientToGameDelegate:AskHack(id).Callback = function (err)
		if cb then
			local success = err ~= LTConfig.MessageConfig.Ok

			cb(success, true)
		end
	end
end

M.SetHackCamera = function(self, open, entityId, target, xRange, yRange, defaultAngle, fov, useTelescope, showWarnOnce, cameraBlendCurveId, keepExitBtnState)
	if open then
		gStoreManager:GetStoreGroup("CoreHudGameplayControlStore"):StopGameplayByName("HackInteract")
		gStoreManager:GetStoreGroup("CoreHudGameplayControlStore"):StartGameplayByName("HackInteract", {
			fov = fov,
			useTelescope = useTelescope,
			target = target,
			defaultAngle = defaultAngle,
			xRange = xRange,
			yRange = yRange,
			showWarnOnce = showWarnOnce,
			keepExitBtnState = keepExitBtnState
		})
		gCS.CameraDataMgr.cinemachineManager:EnableFirstPersonCamera(target, Vector3.zero, xRange, yRange, defaultAngle, 1, false, 0.3, nil, cameraBlendCurveId)

		gGadgetManager.curHackCameraEntityId = entityId
		gGadgetManager.curHackCameraPos = target.position

		gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.GadgetHackCamera, entityId == nil)
	else
		gMessageManager:SendMessage(gEventConstants.HACKER_CAMERA_PANEL_EXIT_ANIM)
	end
end

M.SetHackBtnState = function(self, key, index, btnState, nodeId)
	local data = gGadgetManager:GetHackInteractData(key)

	if not data then
		return
	end

	data.btnState[index] = btnState
	local newIds = {}

	for k, v in ipairs(data.btnHackTypeIds) do
		if data.btnState[k] == 2 then
			local typeId = data.btnHackTypeIds[k]

			if not typeId or typeId ~= 0 then
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
		gInteractionManager.hintInfosHudStore:RefreshHackIndicateState(key, nodeId, btnState ~= 1)
	end
end

M.GetFeiSuoTarget = function(self)
	if not self.HackInteractTarget then
		return nil
	end

	return self.HackInteractTarget.target
end

M.TerrainKillingList = {}

M.RegisterTerrainKilling = function(self, pid, dict)
	local data = dict:ToTable()
	data.exTransList = data.exTransList:ToTable()

	if not self.TerrainKillingList[pid] then
		self.TerrainKillingList[pid] = {}

		gCS.BattleManager.AddOrRmvEnemyInGadget(pid, true)
	end

	for i, v in ipairs(self.TerrainKillingList[pid]) do
		if v.entityId ~= data.entityId and v.pointIndex ~= data.pointIndex then
			return
		end
	end

	table.insert(self.TerrainKillingList[pid], data)
end

M.UnRegisterTerrainKilling = function(self, pid, entityId, pointIndex)
	if not pid or ulong.equals(pid, 0) then
		for pidKey, v in pairs(self.TerrainKillingList) do
			for i = #v, 1, -1 do
				if v[i].entityId ~= entityId and v[i].pointIndex ~= pointIndex then
					table.remove(v, i)

					if #v ~= 0 then
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
		if v.entityId ~= entityId and v.pointIndex ~= pointIndex then
			table.remove(self.TerrainKillingList[pid], i)
		end
	end

	if #self.TerrainKillingList[pid] ~= 0 then
		gCS.BattleManager.AddOrRmvEnemyInGadget(pid, false)

		self.TerrainKillingList[pid] = nil
	end
end

M.GetTerrainKillingList = function(self)
	return self.TerrainKillingList
end

M.OnTriggerTerrainKillingAnim = function(self, pid, targetTrans)
	if not self.TerrainKillingList[pid] then
		return
	end

	for i, v in ipairs(self.TerrainKillingList[pid]) do
		if v.targetTrans ~= targetTrans then
			gSpoonClientMgr:ReleaseContextEvent(v.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.MessageTrigger, {
				message = gEventConstants.GADGET_TERRAIN_KILLING,
				param = v.pointIndex
			})
		end
	end
end

M.curActiveTerrainGadgetId = nil

M.OnTerrainGadgetActiveChange = function(self, entityId)
	if self.curActiveTerrainGadgetId ~= entityId then
		return
	end

	if self.curActiveTerrainGadgetId and not ulong.equals(self.curActiveTerrainGadgetId, 0) then
		gSpoonClientMgr:ReleaseContextEvent(self.curActiveTerrainGadgetId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.MessageTrigger, {
			message = gEventConstants.ON_TERRAIN_GADGET_INACTIVE
		})
	end

	if not ulong.equals(entityId, 0) then
		gSpoonClientMgr:ReleaseContextEvent(entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.MessageTrigger, {
			message = gEventConstants.ON_TERRAIN_GADGET_ACTIVE
		})
	end

	self.curActiveTerrainGadgetId = entityId
end

gGadgetManager = M
