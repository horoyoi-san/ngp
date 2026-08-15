local GameConfig = LTConfig.GameConfig
local UnitModelManager = LX6.Units.UnitModelManager
local MessageConfig = LTConfig.MessageConfig
local CommonInteractConfig = LTConfig.GameInteractionTypeConfig
local CCTransitionMode = LTConfig.ActionTransitionRuleTypesConfig.CCTransitionMoveTypeType
local CCTransitionTargetType = LTConfig.ActionTransitionRuleTypesConfig.CCTransitionTargetType
local ActionTransitionRuleConfig = LTConfig.ActionTransitionRuleConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
C_InteractionManager = DefClass("C_InteractionManager", C_InteractionManager)
local M = C_InteractionManager
local ActionPosType = {
	Point = 0,
	TwoSide = 2,
	Circle = 1,
	Points = 3,
	IsNone = function (type)
		if type == 999 or type == -1 then
			return true
		end

		return false
	end
}
M.CommonInteractType = {
	Tower = 41,
	DoubleBed = 22,
	ElectronicOrgan = 16,
	RobBankDrill = 56,
	ThermiteLoading = 59,
	RobBankVaultLeft = 57,
	Guitar = 15,
	ChairGame = 17,
	Storage = 5,
	RobBankVaultRight = 58,
	Stall = 12,
	Lounge = 23,
	SitDrum = 14,
	None = 0,
	Sit = CommonInteractConfig.Sit,
	SitFront = CommonInteractConfig.Sit * 10 + 1,
	SitLeft = CommonInteractConfig.Sit * 10 + 2,
	SitRight = CommonInteractConfig.Sit * 10 + 3
}
M.CommonInteractInfo = {}
M.currentInteractType = nil
M.InteractActionType = {
	StealEarPhone = 19,
	TakePhotoSlotEntity = 18,
	EnterCommonInteract = 2,
	DoorInteract = 6,
	TakePhotoClimb = 16,
	LooAtPos = 11,
	StealPhoneGet = 3,
	StealEarPhoneFinish = 22,
	HoldLetter = 21,
	StealPhoneDelayDestroy = 17,
	StealPhoneOpen = 4,
	ChairInteract = 5,
	Scan = 10,
	BindEarPhoneToHand = 23,
	StealPhoneClear = 8,
	LongPressStart = 14,
	BreakCommonInteract = 1,
	TakePhoto = 13,
	StealPhoneSitQuit = 9,
	ThrowEarPhone = 20
}

function M:ctor()
	self.isInteractSitting = false
	self.useNewInteractMove = true
	self.isDoingCCTransition = false
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		self:Clear()
	end

	if switchType == gSwitchSceneType.KickToLogin then
		self.driveMode = false
	end
end

function M:Clear()
	self:SetInteractItem(nil)
end

function M:GetMobileCombineUnitBtnInfo()
	if not self.hintInfosHudStore then
		return nil, nil
	end

	for _, data in ipairs(self.hintInfosHudStore.mobileBtns) do
		if data.target.unit and data.combineTargets and #data.combineTargets > 1 then
			local btn = self.hintInfosHudStore:GetMinCombineTarget(data.combineTargets)

			return btn.target.unit.Pid, btn.iconId
		end
	end

	return nil, nil
end

function M:IsInteractLoopTime(type)
	local cfg = CommonInteractConfig.GetConfig(type)

	if not cfg then
		return false
	end

	return cfg.IsLoop == 1
end

function M:IsInteractOnWall(type, default)
	if not type or type == 0 then
		if default == nil then
			type = 1
		else
			return default
		end
	end

	local cfg = CommonInteractConfig.GetConfig(type)

	if not cfg then
		return false
	end

	return cfg.AbleOnWall == 1
end

function M:IsInteractOnChair(type, default)
	if default then
		return true
	end

	if not type or type == 0 then
		if default == nil then
			type = 1
		else
			return default
		end
	end

	local cfg = CommonInteractConfig.GetConfig(type)

	if not cfg then
		return false
	end

	return cfg.AbleOnSit == 1
end

function M:IsInteractIkPos(type)
	local cfg = CommonInteractConfig.GetConfig(type)

	if not cfg then
		return false
	end

	return cfg.UseIk == 1
end

function M:CheckCommonInteractFromLayerTransition(id)
	local cfg = LTConfig.LayerTransitionConfig.GetConfig(id)

	gInteractionManager:CheckCommonInteractCfg(cfg, gCS.MyPlayerManager.PlayerUnit)
end

function M:CSCheckCommonInteractCfg(cfgId, pid)
	local cfg = ActionTransitionRuleConfig.GetConfig(cfgId)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not cfg or not unit then
		return false
	end

	self:CheckCommonInteract(unit, cfg.SlotSignalTypeAndDelay, cfg.TargetAniType, cfg.TargetAniGroup)
end

function M:CheckCommonInteractCfg(cfg, unit)
	self:CheckCommonInteract(unit, cfg.SlotSignalTypeAndDelay, cfg.TargetAniType, cfg.TargetAniGroup)
end

function M:CheckCommonInteract_CS(cs_unit, SlotSignalType, delaytime, bindRotX, posX, posY, posZ, rotX, rotY, rotZ, TargetAniType, TargetAniGroup)
	local data = {
		SlotSignalType = SlotSignalType,
		delaytime = delaytime,
		bindRotX = bindRotX,
		offsetx = posX,
		offsety = posY,
		offsetz = posZ,
		selfEulerX = rotX,
		selfEulerY = rotY,
		selfEulerZ = rotZ
	}

	self:CheckCommonInteract(cs_unit, data, TargetAniType, TargetAniGroup)
end

function M:CheckCommonInteract(cs_unit, SlotSignalTypeAndDelay, TargetAniType, TargetAniGroup)
	if cs_unit ~= gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local data = SlotSignalTypeAndDelay

	if not data.SlotSignalType or data.SlotSignalType == 0 then
		return
	end

	if LX6.Engine.DebugBoolMgr.debugLuaSlotLoad then
		print_debug("机关通用交互开始", data.SlotSignalType, data.delaytime)
	end

	if data.SlotSignalType == self.InteractActionType.BreakCommonInteract then
		self:SetInteractTargetCollider(true)
		self:OnBreakCommonInteract(true)
	elseif data.SlotSignalType == self.InteractActionType.EnterCommonInteract then
		self:OnStartCommonInteract(data.delaytime)
	elseif data.SlotSignalType == self.InteractActionType.ChairInteract then
		self:OnStartCommonInteract(data.delaytime)
	elseif data.SlotSignalType == self.InteractActionType.DoorInteract then
		if data.delaytime == 0 then
			L50.L50App.Scene.SpoonGadgetManager:SetAutoDoorTrig()
		else
			gLuaTimeMgrUtils.Delay(function ()
				L50.L50App.Scene.SpoonGadgetManager:SetAutoDoorTrig()
			end, data.delaytime, nil, nil, true)
		end
	elseif data.SlotSignalType == self.InteractActionType.StealEarPhone then
		local item = gCS.MindPowerMgr:GetAimItem()

		if item then
			local posOffset = Vector3.New(data.offsetx or 0, data.offsety or 0, data.offsetz or 0)
			local rotOffset = Vector3.New(data.selfEulerX or 0, data.selfEulerY or 0, data.selfEulerZ or 0)

			item:PullEarPhone(data.delaytime or 0, data.bindBone, posOffset, rotOffset)
		end
	elseif data.SlotSignalType == self.InteractActionType.BindEarPhoneToHand then
		local item = gCS.MindPowerMgr:GetAimItem()

		if item then
			local posOffset = Vector3.New(data.offsetx or 0, data.offsety or 0, data.offsetz or 0)
			local rotOffset = Vector3.New(data.selfEulerX or 0, data.selfEulerY or 0, data.selfEulerZ or 0)

			item:AttachEarPhoneToBoneFromTransition(data.delaytime or 0, data.bindBone, posOffset, rotOffset)
		end
	elseif data.SlotSignalType == self.InteractActionType.StealEarPhoneFinish then
		local item = gCS.MindPowerMgr:GetAimItem()

		if item then
			local posOffset = Vector3.New(data.offsetx or 0, data.offsety or 0, data.offsetz or 0)
			local rotOffset = Vector3.New(data.selfEulerX or 0, data.selfEulerY or 0, data.selfEulerZ or 0)

			item:StealEarPhoneFinish(data.delaytime or 0, data.bindBone, posOffset, rotOffset)
		end
	elseif data.SlotSignalType == self.InteractActionType.HoldLetter then
		local item = gCS.MindPowerMgr:GetAimItem()

		if item then
			local posOffset = Vector3.New(data.offsetx or 0, data.offsety or 0, data.offsetz or 0)
			local rotOffset = Vector3.New(data.selfEulerX or 0, data.selfEulerY or 0, data.selfEulerZ or 0)

			item:PullLetter(data.delaytime or 0, data.bindRotX or 0, data.bindBone, posOffset, rotOffset)
		end
	elseif data.SlotSignalType == self.InteractActionType.Scan then
		-- Nothing
	elseif data.SlotSignalType == self.InteractActionType.LooAtPos then
		local mindItem = gCS.MindPowerMgr:GetAimItem()

		if mindItem then
			local pos = mindItem:GetPosition()

			gCS.LuaUtils.LookAtPosition(pos.x, pos.y, pos.z, cs_unit)
		end
	elseif data.SlotSignalType == self.InteractActionType.TakePhoto then
		if not gPanelManager:IsPanelShowing(gPanelId.S_PHOTO_PANEL) then
			gTakePhotoUtils.PhotoPermission = true
			gTakePhotoUtils.OpenLock = false
			gTakePhotoUtils.OncePhotoTemplate = gTakePhotoUtils.PhotoTemplate.Default
		end
	elseif data.SlotSignalType == self.InteractActionType.LongPressStart then
		local item = gCS.MindPowerMgr:GetAimItem()

		if item then
			item:SetLongPressStartParas(data.delaytime or 0)
		end
	elseif data.SlotSignalType == self.InteractActionType.TakePhotoClimb then
		if not gPanelManager:IsPanelShowing(gPanelId.S_PHOTO_PANEL) then
			gTakePhotoUtils.PhotoPermission = true
			gTakePhotoUtils.OpenLock = false
			gTakePhotoUtils.OncePhotoTemplate = gTakePhotoUtils.PhotoTemplate.Climb
		end
	elseif data.SlotSignalType == self.InteractActionType.TakePhotoSlotEntity and not gPanelManager:IsPanelShowing(gPanelId.S_PHOTO_PANEL) then
		gTakePhotoUtils.PhotoPermission = true
		gTakePhotoUtils.OpenLock = false
		gTakePhotoUtils.OncePhotoTemplate = gTakePhotoUtils.PhotoTemplate.SlotEntity
	end
end

function M:SetInteractTargetCollider(enable, type, entityId)
	if not enable and entityId then
		LX6.Item.DestructibleMgr.Instance:OccupyDestructible(entityId, gCS.MyPlayerManager.PlayerUnit.Pid, true)

		self.sitDestructibleEntityId = entityId
	end

	if enable and self.sitDestructibleEntityId then
		LX6.Item.DestructibleMgr.Instance:OccupyDestructible(self.sitDestructibleEntityId, gCS.MyPlayerManager.PlayerUnit.Pid, false)

		self.sitDestructibleEntityId = nil
	end

	if enable then
		gCS.CameraDataMgr.cinemachineManager:SetFreeLookCollisionTag(nil)
		gCS.LuaUtils.SetChairIgnoreTag(not enable)

		return
	end

	if not type or self:IsIgnoreColliderType(type) then
		gCS.CameraDataMgr.cinemachineManager:SetFreeLookCollisionTag("Chair")
		gCS.LuaUtils.SetChairIgnoreTag(not enable)
	end
end

function M:IsIgnoreColliderType(type)
	local cfg = CommonInteractConfig.GetConfig(type)

	if not cfg then
		return false
	end

	return cfg.IgnoraCollider == 1
end

function M:OnStartCommonInteract(time)
	if self.commonActionTimer then
		return
	end

	if time == 0 then
		if not gInteractionManager.CommonInteractAction then
			return
		end

		gInteractionManager.CommonInteractAction()

		gInteractionManager.CommonInteractAction = nil
		gInteractionManager.CommonInteractBreakAction = nil

		return
	end

	self.commonActionTimer = gLuaTimeMgrUtils.Delay(function ()
		gInteractionManager.commonActionTimer = nil

		if not gInteractionManager.CommonInteractAction then
			return
		end

		gInteractionManager.CommonInteractAction()

		gInteractionManager.CommonInteractAction = nil
		gInteractionManager.CommonInteractBreakAction = nil
	end, time, nil, nil, true)
end

function M:OnBreakCommonInteract(clearAction)
	if clearAction then
		self.CommonInteractAction = nil

		if self.CommonInteractBreakAction then
			self.CommonInteractBreakAction()

			self.CommonInteractBreakAction = nil
		end

		gInteractionManager.isInteractSitting = false

		gInteractionManager:SetChairCapsuleAndAutoReset()
	end

	if self.commonActionTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.commonActionTimer)

		self.commonActionTimer = nil
	end

	if self.currentInteractType then
		if not gCS.MyPlayerManager.PlayerUnit.State.CurIsInteractDestruction then
			self:SetInteractItem(nil)
		end

		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.BreakCommonInteractTrigger, {
			type = self.currentInteractType
		})

		self.currentInteractType = nil
	end
end

function M:SetChairCapsuleAndAutoReset()
	gCS.UnitModelManager.SetCapsuleScale(gCS.MyPlayerManager.PlayerUnit, GameConfig.SitCapsulBodyDis)
	gCS.BaseUnitModuleUtils.TryChangeCollider(gCS.MyPlayerManager.PlayerUnit, LX6.Units.Module.ColliderChangeModule.ChangeReason.Default, -1, -1)
end

function M:ClearInteractSitting()
	if self.isInteractSitting then
		self.isInteractSitting = false

		self:SetChairCapsuleAndAutoReset()
	end
end

function M:OnEnterLuaSlotCommonInteract(info, entity, interactAction, startAction)
	if self.commonActionTimer then
		return
	end

	self.CommonInteractAction = nil

	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local param = info:ToTable()

	if param.type == 0 then
		self:TryDoSlotBtnAction(info)

		return
	end

	function gInteractionManager.CommonInteractAction()
		if type(interactAction) == "function" then
			interactAction()
		elseif interactAction.DynamicInvoke then
			interactAction:DynamicInvoke()
		else
			gInteractionManager:TryDoSlotBtnAction(info)
		end
	end

	local function OnEndMove(newType, index)
		if startAction then
			startAction:DynamicInvoke()
		end

		newType = newType or param.type
		local ignoreTransition = CommonInteractConfig.GetConfig(param.type).IsStateTree

		if gInteractionManager:IsChairType(param.type) then
			gInteractionManager.isInteractSitting = true
			gInteractionManager.sitIndex = index
		end

		if LX6.Engine.DebugBoolMgr.debugLuaSlotLoad then
			print_debug("请求机关通用交互进入", newType)
		end

		gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, Vector3.null, Vector3.null, nil)
		gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, nil, Vector3.null, nil)

		if gInteractionManager:IsInteractIkPos(param.type) and param.ikPosTrans then
			if param.posType == ActionPosType.Circle and param.useCircleIk then
				local dir = gCS.MyPlayerManager.PlayerUnit.LocalPosition - param.ikPosTrans.position
				dir.y = 0
				dir = dir:Normalize()
				local circleIkPos = param.ikPosTrans.position + dir * param.circleIkRadius

				gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, circleIkPos, Vector3.null, param.layPosTrans)
			else
				gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, param.ikPosTrans, Vector3.null, param.layPosTrans)
			end
		end

		gInteractionManager:OnSlotStartStorage(param)

		if not ignoreTransition then
			self:SetCommonInteractActionType(newType)
			gInteractionManager:TryCheckTransition(param.type, newType)
			self:SetCommonInteractActionType(0)

			if gInteractionManager:IsInteractLoopTime(param.type) and param.loopTime ~= -1 then
				gLuaTimeMgrUtils.Delay(function ()
					gInteractionManager:SetCommonInteractEnd(param.type)
				end, param.loopTime, nil, nil, true)
			end
		end
	end

	if param.type == self.CommonInteractType.RobBankVaultLeft or param.type == self.CommonInteractType.RobBankVaultRight or param.type == self.CommonInteractType.ThermiteLoading then
		self.CommonInteractInfo[param.type] = {
			{
				info.layPosTrans,
				info.layPosTransId
			},
			{
				info.layPosTrans2,
				info.layPosTransId2
			},
			{
				info.layPosTrans3,
				info.layPosTransId3
			}
		}
		self.CommonInteractInfoId = info.entityId
	end

	self:CommonInteractMove(param, OnEndMove, entity)
end

function M:SetCommonInteractActionType(type)
	gCS.TransitionMgr.commonInteractActionType = type
end

function M:TryCheckTransition(type, newType)
	return gCS.LuaUtils.CheckSwitchAction(false, true, false, 0)
end

function M:GetNpcInteractionInfos(taskId, npcId, eventId)
	local data = gCS.SpoonTaskMgr.Instance:GetNpcInteractionInfosLua(taskId, npcId, eventId)
	local isEvent = eventId ~= nil and eventId ~= 0

	if data then
		return data.interactionData:ToTable(), isEvent
	else
		return nil, isEvent
	end
end

function M:OnEnterTaskNpcCommonInteract(npc, spoonId, taskId, eventId, index)
	if self.commonActionTimer then
		return
	end

	local interactInfos = self:GetNpcInteractionInfos(taskId, spoonId, eventId)
	local interactInfo = nil

	for i, v in ipairs(interactInfos) do
		if v.Index == index then
			interactInfo = v

			break
		end
	end

	if not interactInfo then
		print_error("OnEnterTaskNpcCommonInteract: interactInfo is nil", spoonId, taskId, eventId, index)

		return
	end

	self.CommonInteractAction = nil

	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local ikPosTrans = nil

	if interactInfo.InteractIkPos and interactInfo.InteractIkPos ~= 0 then
		local success, wayPointData = gCS.SpoonTaskMgr.Instance:TryGetWayPointData(taskId, interactInfo.InteractIkPos, nil)

		if not success then
			print_error("OnEnterTaskNpcCommonInteract: TryGetWayPointData failed", taskId, interactInfo.InteractIkPos)

			return
		end

		ikPosTrans = {
			position = wayPointData.position,
			forward = Quaternion.Euler(0, wayPointData.facing, 0) * Vector3.forward
		}
	else
		ikPosTrans = {
			position = npc.LocalPosition,
			forward = npc.PlayerObj.forward
		}
	end

	local posTrans = nil

	if interactInfo.InteractPos and interactInfo.InteractPos ~= 0 then
		local _, wayPointData = gCS.SpoonTaskMgr.Instance:TryGetWayPointData(taskId, interactInfo.InteractPos, nil)
		posTrans = {
			position = wayPointData.position,
			forward = Quaternion.Euler(0, wayPointData.facing, 0) * Vector3.forward
		}
	else
		local dis = self:GetIkDisByType(interactInfo.CommonInteractType)
		local newPos = ikPosTrans.position + ikPosTrans.forward * dis
		newPos.y = npc.LocalPosition.y
		posTrans = {
			position = newPos,
			forward = -ikPosTrans.forward
		}
	end

	local param = {
		type = interactInfo.CommonInteractType,
		posType = interactInfo.InteractPosType,
		posTrans = posTrans,
		radius = interactInfo.InteractRadius,
		loopTime = interactInfo.InteractLoopTime,
		ikPosTrans = ikPosTrans,
		chairType = interactInfo.chairType,
		selfTrans = npc.PlayerObj
	}

	local function OnEndMove(newType)
		newType = newType or param.type
		local ignoreTransition = CommonInteractConfig.GetConfig(param.type).IsStateTree

		function gInteractionManager.CommonInteractAction()
			L50.L50App.L50Game.InteractBtnMgr.onCommonInteractEnd:DynamicInvoke()
		end

		if gInteractionManager:IsChairType(param.type) then
			gInteractionManager.isInteractSitting = true
			gInteractionManager.sitIndex = -1
		end

		if gInteractionManager:IsInteractIkPos(param.type) and param.ikPosTrans then
			if type(param.ikPosTrans) == "table" then
				gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, param.ikPosTrans.position, Vector3.null, param.layPosTrans)
			else
				gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, param.ikPosTrans, Vector3.null, param.layPosTrans)
			end
		end

		if not ignoreTransition then
			self:SetCommonInteractActionType(newType)
			gInteractionManager:TryCheckTransition(param.type, newType)
			self:SetCommonInteractActionType(0)

			if gInteractionManager:IsInteractLoopTime(param.type) and param.loopTime ~= -1 then
				gLuaTimeMgrUtils.Delay(function ()
					gInteractionManager:SetCommonInteractEnd(param.type)
				end, param.loopTime, nil, nil, true)
			end
		end
	end

	if param.type == self.CommonInteractType.Storage then
		self:UnitStartStorge(npc)
	else
		self:CommonInteractMove(param, OnEndMove)
	end
end

function M:OnEnterSceneItemCommonInteract(CommonInteractType, InteractPosType, InteractPos, InteractPosForward, InteractRadius, InteractLoopTime, InteractIkPos, InteractIkPosForward, ChairType, onlyUsePointPos, instanceId, sceneItemGo, cb)
	if self.commonActionTimer or not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	self.CommonInteractAction = nil
	local param = {
		type = CommonInteractType,
		posType = InteractPosType,
		posTrans = {
			position = InteractPos,
			forward = InteractPosForward
		},
		radius = InteractRadius,
		loopTime = InteractLoopTime,
		ikPosTrans = {
			position = InteractIkPos,
			forward = InteractIkPosForward
		},
		onlyUsePointPos = onlyUsePointPos,
		chairType = ChairType,
		entityId = instanceId,
		entityGo = sceneItemGo
	}

	local function OnEndMove(newType)
		if cb then
			cb:DynamicInvoke()
		end

		newType = newType or param.type
		local ignoreTransition = CommonInteractConfig.GetConfig(param.type).IsStateTree

		if gInteractionManager:IsChairType(param.type) then
			gInteractionManager.isInteractSitting = true
			gInteractionManager.sitIndex = -1
		end

		if gInteractionManager:IsInteractIkPos(param.type) then
			if type(param.ikPosTrans) == "table" then
				gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, param.ikPosTrans.position, Vector3.null)
			else
				gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, param.ikPosTrans, Vector3.null)
			end
		end

		if not ignoreTransition then
			self:SetCommonInteractActionType(newType)
			gInteractionManager:TryCheckTransition(param.type, newType)
			self:SetCommonInteractActionType(0)

			if gInteractionManager:IsInteractLoopTime(param.type) and param.loopTime ~= -1 then
				gLuaTimeMgrUtils.Delay(function ()
					gInteractionManager:SetCommonInteractEnd(param.type)
				end, param.loopTime, nil, nil, true)
			end
		end
	end

	self:CommonInteractMove(param, OnEndMove)
end

function M:OnEnterSpoonPosCommonInteract(CommonInteractType, InteractPosType, InteractPos, InteractPosForward, InteractRadius, InteractLoopTime, InteractIkTrans, InteractIkPos, InteractIkPosForward, ChairType, cb)
	if self.commonActionTimer or not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	self.CommonInteractAction = nil
	local param = {
		type = CommonInteractType,
		posType = InteractPosType,
		posTrans = {
			position = InteractPos,
			forward = InteractPosForward
		},
		radius = InteractRadius,
		loopTime = InteractLoopTime,
		ikPosTrans = InteractIkTrans and InteractIkTrans or {
			position = InteractIkPos,
			forward = InteractIkPosForward
		},
		chairType = ChairType
	}

	local function OnEndMove(newType)
		if cb then
			cb:DynamicInvoke()
		end

		newType = newType or param.type
		local ignoreTransition = CommonInteractConfig.GetConfig(param.type).IsStateTree

		if gInteractionManager:IsChairType(param.type) then
			gInteractionManager.isInteractSitting = true
			gInteractionManager.sitIndex = -1
		end

		if gInteractionManager:IsInteractIkPos(param.type) then
			if type(param.ikPosTrans) == "table" then
				gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, param.ikPosTrans.position, Vector3.null)
			else
				gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, param.ikPosTrans, Vector3.null)
			end
		end

		if not ignoreTransition then
			self:SetCommonInteractActionType(newType)
			gInteractionManager:TryCheckTransition(param.type, newType)
			self:SetCommonInteractActionType(0)

			if gInteractionManager:IsInteractLoopTime(param.type) and param.loopTime ~= -1 then
				gLuaTimeMgrUtils.Delay(function ()
					gInteractionManager:SetCommonInteractEnd(param.type)
				end, param.loopTime, nil, nil, true)
			end
		end
	end

	self:CommonInteractMove(param, OnEndMove)
end

function M:OnEnterUnitCommonInteract(param, cb)
	local function OnEndMove(newType)
		newType = newType or param.type
		local ignoreTransition = CommonInteractConfig.GetConfig(param.type).IsStateTree

		function gInteractionManager.CommonInteractAction()
			if cb then
				cb()
			end
		end

		if gInteractionManager:IsChairType(param.type) then
			gInteractionManager.isInteractSitting = true
			gInteractionManager.sitIndex = -1
		end

		if not ignoreTransition then
			self:SetCommonInteractActionType(newType)
			gInteractionManager:TryCheckTransition(param.type, newType)
			self:SetCommonInteractActionType(0)

			if gInteractionManager:IsInteractLoopTime(param.type) and param.loopTime ~= -1 then
				gLuaTimeMgrUtils.Delay(function ()
					gInteractionManager:SetCommonInteractEnd(param.type)
				end, param.loopTime, nil, nil, true)
			end
		end

		if gInteractionManager:IsInteractIkPos(param.type) and param.ikPosTrans then
			if type(param.ikPosTrans) == "table" then
				gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, param.ikPosTrans.position, Vector3.null, param.layPosTrans)
			else
				gCS.MotionWindowManager.SetTargetsForInteraction(gCS.MyPlayerManager.PlayerUnit, param.ikPosTrans, Vector3.null, param.layPosTrans)
			end
		end
	end

	self:CommonInteractMove(param, OnEndMove)
end

function M:GetIkDisByType(type)
	return GameConfig.CommonInteractDisParam[type]
end

function M:IsChairType(type)
	if not type then
		return false
	end

	if type >= 100 then
		type = math.floor(type / 10)
	end

	local cfg = CommonInteractConfig.GetConfig(type)

	if not cfg then
		return false
	end

	return cfg.IsSit == 1
end

function M:IsNeedPosType(type)
	if type == self.CommonInteractType.None then
		return false
	end

	local cfg = CommonInteractConfig.GetConfig(type)

	if not cfg then
		return false
	end

	if cfg.MovePointType == CommonInteractConfig.MovePointTypeType.None then
		return false
	end

	return true
end

function M:CommonInteractMove(param, cb, entity)
	local posType = param.posType
	local trans = param.posTrans or param.selfTrans
	local radius = param.radius
	local selfTrans = param.selfTrans

	if not gInteractionManager.isInteractSitting then
		if param.isDestructible then
			self:SetInteractTargetCollider(false, param.type, param.entityId)
		else
			self:SetInteractTargetCollider(false, param.type)
		end
	end

	local weapon = gPlayerManager.infoSpirit.bindData.currentWeapon

	if weapon ~= nil then
		local cfgId = weapon.TemplateId
		local weaponCfg = LTConfig.WeaponConfig.GetConfig(cfgId)
		local sceneItemId = 0

		if weaponCfg ~= nil then
			sceneItemId = weaponCfg.SceneItemInteractionID
		end

		local sceneItemCfg = LTConfig.SceneItemInteractionConfig.GetConfig(sceneItemId)
		local flag = true

		if sceneItemCfg and sceneItemCfg.IsNotThrow == true then
			flag = false
		end

		if CommonInteractConfig.GetConfig(param.type).NoWeaponRPC and flag == true then
			gWeaponManager:AskSwitchWeaponToFistWeapon()
		end
	end

	gInteractionManager.currentInteractType = param.type

	if gInteractionManager.isInteractSitting and self:IsInteractOnChair(param.type) then
		cb()
	else
		if not self:IsNeedPosType(param.type) then
			local side = nil

			if self:IsInteractOnWall(param.type) then
				local mewPos = selfTrans:InverseTransformPoint(gCS.MyPlayerManager.PlayerUnit.LocalPosition)

				if mewPos.x > 0 then
					side = param.type * 10 + 2
				else
					side = param.type * 10 + 1
				end
			end

			param.side = side

			if param.faceDirType then
				if param.faceDirType == 0 then
					self:SetUnitMove({
						position = gCS.MyPlayerManager.PlayerUnit.LocalPosition,
						forward = trans.position - gCS.MyPlayerManager.PlayerUnit.LocalPosition
					}, param, function ()
						cb(side)
					end)
				elseif param.faceDirType == 2 then
					self:SetUnitMove({
						position = gCS.MyPlayerManager.PlayerUnit.LocalPosition,
						forward = param.faceDirPos.forward
					}, param, function ()
						cb(side)
					end)
				elseif param.faceDirType == 1 then
					if CommonInteractConfig.GetConfig(param.type).IsStateTree then
						self:SetUnitMove({
							position = gCS.MyPlayerManager.PlayerUnit.LocalPosition,
							forward = gCS.MyPlayerManager.PlayerUnit.PlayerObj.forward
						}, param, function ()
							cb(side)
						end)
					else
						cb(side)
					end
				end
			else
				self:SetUnitMove({
					position = gCS.MyPlayerManager.PlayerUnit.LocalPosition,
					forward = selfTrans.position - gCS.MyPlayerManager.PlayerUnit.LocalPosition
				}, param, function ()
					cb(side)
				end)
			end

			return
		end

		if posType == ActionPosType.Point then
			local side = nil

			if param.type == self.CommonInteractType.Sit then
				if not param.onlyUsePointPos then
					trans = self:GetChairBestTarget({
						trans
					}, entity, false, false, param.isDestructible, param.currentPos)
					side = trans.side
				else
					side = self.CommonInteractType.SitFront
				end

				gCS.TransitionMgr.ignoreChairBlockCheck = param.onlyUsePointPos and not param.isTeleportSit
			end

			param.side = side

			self:SetUnitMove(trans, param, function ()
				gCS.MyPlayerManager.PlayerUnit.NoSwitchTime = 0

				cb(side)
			end)
		elseif posType == ActionPosType.Circle then
			local newCenterPos = nil

			if param.useIkPosForCircle and param.ikPosTrans then
				newCenterPos = param.ikPosTrans.position
			else
				newCenterPos = trans.position
			end

			newCenterPos.y = gCS.MyPlayerManager.PlayerUnit.LocalPosition.y
			local targetPos = trans.position + (gCS.MyPlayerManager.PlayerUnit.LocalPosition - newCenterPos):Normalize() * radius
			local targetForward = (newCenterPos - gCS.MyPlayerManager.PlayerUnit.LocalPosition):Normalize()

			self:SetUnitMove({
				position = targetPos,
				forward = targetForward
			}, param, function ()
				gCS.MyPlayerManager.PlayerUnit.NoSwitchTime = 0

				cb()
			end)
		elseif posType == ActionPosType.TwoSide then
			local leftPos, rightPos = nil

			if type(trans) ~= "table" then
				leftPos = trans:TransformPoint(-Vector3.right * self:GetTwoSideOffsetByBody(param.type))
				rightPos = trans:TransformPoint(Vector3.right * self:GetTwoSideOffsetByBody(param.type))
			else
				leftPos = trans.position + (Quaternion.Euler(0, -90, 0) * trans.forward):Normalize() * self:GetTwoSideOffsetByBody(param.type)
				rightPos = trans.position + (Quaternion.Euler(0, 90, 0) * trans.forward):Normalize() * self:GetTwoSideOffsetByBody(param.type)
			end

			local leftDis = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, leftPos)
			local rightDis = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, rightPos)
			local forward = trans.forward
			local time, interactType = nil

			if leftDis < rightDis then
				interactType = param.type * 10 + 2

				if param.twoSideFaceCenter then
					forward = trans.position - leftPos
				end

				self:SetUnitMove({
					position = leftPos,
					forward = forward
				}, param, function ()
					gCS.MyPlayerManager.PlayerUnit.NoSwitchTime = 0

					cb(interactType)
				end, time)
			else
				interactType = param.type * 10 + 1

				if param.twoSideFaceCenter then
					forward = trans.position - rightPos
				end

				self:SetUnitMove({
					position = rightPos,
					forward = forward
				}, param, function ()
					gCS.MyPlayerManager.PlayerUnit.NoSwitchTime = 0

					cb(interactType)
				end, time)
			end
		elseif posType == ActionPosType.Points then
			local bestTarget, side = nil
			local list = {}

			if param.posTransArr.Length then
				for i = 0, param.posTransArr.Length - 1 do
					table.insert(list, param.posTransArr[i])
				end
			elseif type(param.posTransArr) == "table" then
				list = param.posTransArr
			end

			if param.type == self.CommonInteractType.Sit then
				bestTarget = self:GetChairBestTarget(list, entity, param.onlyUsePointPos, true, param.isDestructible, param.currentPos)
				side = bestTarget.side
			end

			if param.type == self.CommonInteractType.Sit then
				gCS.TransitionMgr.ignoreChairBlockCheck = param.onlyUsePointPos and not param.isTeleportSit
			end

			if param.type == self.CommonInteractType.RobBankDrill and self.drillShelfMgrData ~= nil then
				local drillShelfData = self.drillShelfMgrData.dataList[self.drillShelfMgrData.index]

				if drillShelfData then
					bestTarget = list[drillShelfData.col]
				end
			end

			param.side = side

			self:SetUnitMove(bestTarget, param, function ()
				gCS.MyPlayerManager.PlayerUnit.NoSwitchTime = 0

				if param.type == self.CommonInteractType.RobBankDrill then
					cb()
				else
					cb(side, bestTarget.index)
				end
			end)
		else
			cb()
		end
	end
end

function M:GetTagId(spiritId)
	local fightSpiritTagConfig = LTConfig.FightSpiritTagConfig

	for i = 0, fightSpiritTagConfig.count - 1 do
		local cfg = fightSpiritTagConfig.LoadAt(i)

		if cfg.SpiritId == spiritId then
			return cfg.Id
		end
	end

	return 0
end

function M:PlayerIsMale()
	local spiritId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
	local tagId = self:GetTagId(spiritId)
	local tagConfig = LTConfig.FightSpiritTagConfig.GetConfig(tagId)

	return tagConfig.Sex == 1
end

M.isCommonInteractMoving = false

function M:SetUnitMove(target, param, cb)
	local actionType = param.type

	if actionType == self.CommonInteractType.Tower and self:PlayerIsMale() then
		target = {
			position = target:TransformPoint(Vector3.New(-0.038, 0, -0.13)),
			forward = target.forward
		}
	end

	local cfg = CommonInteractConfig.GetConfig(actionType)

	local function OnFinish()
		self.isCommonInteractMoving = false
		gCS.MyPlayerManager.PlayerUnit.NoSwitchTime = 0

		if cb then
			cb()
		end

		if cfg.IsHookUp then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnInteractDestructible, {
				isHookUp = true
			})
		end
	end

	local function OnRealFinish(success)
		self.isCommonInteractMoving = false

		if not success then
			self:SetInteractTargetCollider(true)
			gMessageManager:SendMessage(gEventConstants.COMMON_INTERACT_INTERRUPT)
		end

		self.isDoingCCTransition = false
	end

	if not cfg.IsStateTree then
		self.isDoingCCTransition = true
	end

	gCS.MyPlayerManager.PlayerUnit.NoSwitchTime = 10

	if not L50.L50App.Scene.GamePlayUtils:CurHasSummoned() and CommonInteractConfig.GetConfig(actionType).NeedReportPlace then
		local pos = {
			X = gCS.MyPlayerManager.PlayerUnit.LocalPosition.x,
			Y = gCS.MyPlayerManager.PlayerUnit.LocalPosition.y,
			Z = gCS.MyPlayerManager.PlayerUnit.LocalPosition.z
		}

		gClientToGameSceneDelegate:ReportPlayerStartCommonInteract(pos, gCS.MyPlayerManager.PlayerUnit.moveId).Callback = function (err)
			if err ~= MessageConfig.Ok then
				print_error("#NoCreateIssue 通用交互坐标异常", err, gCS.MyPlayerManager.PlayerUnit.LocalPosition, param.selfTrans.position, actionType, param.selfTrans.name, param)
			end
		end
	end

	if cfg.IsHookUp then
		self:SetInteractItem(param.entityGo.transform, param.entityId)
	elseif cfg.IsHookDown then
		self:SetUnBindItem(param.entityId)
	end

	if actionType == self.CommonInteractType.SitDrum then
		gCS.BaseUnitModuleUtils.SetDrumkitInstance(gCS.MyPlayerManager.PlayerUnit, param.entityGo.transform)
	elseif actionType == self.CommonInteractType.Guitar then
		gCS.BaseUnitModuleUtils.SetGuitarInstance(gCS.MyPlayerManager.PlayerUnit, param.entityGo)
	end

	if cfg.IsStateTree then
		self:SetCommonInteractActionType(param.side or actionType)

		local tran = nil

		if type(target) == "table" then
			if target.onlyUsePointPos then
				tran = target.tran
			end
		else
			tran = target
		end

		function self.stateTreeCallback(success)
			self.isCommonInteractMoving = false

			if success then
				OnFinish(true)
			else
				OnRealFinish(false)
			end
		end

		self.isCommonInteractMoving = true

		if tran then
			if cfg.IsHookDown then
				L50.L50App.Scene.GamePlayUtils:RecordInteractMovePos(tran.position, tran.forward)
			end

			LX6.PaoKu.EntrySystemManager.SetDestAndSendInteractEvent(gCS.MyPlayerManager.PlayerUnit, actionType, tran, Vector3.zero, Quaternion.identity)
		else
			if cfg.IsHookDown then
				L50.L50App.Scene.GamePlayUtils:RecordInteractMovePos(target.position, target.forward)
			end

			LX6.PaoKu.EntrySystemManager.SetDestAndSendInteractEvent(gCS.MyPlayerManager.PlayerUnit, actionType, nil, target.position, Quaternion.LookRotation(target.forward))
		end
	else
		self.isCommonInteractMoving = true

		self:SetCCTransitionTargets(target, OnFinish, OnRealFinish, self:GetTransitionMode(param))

		local flag = gCS.LuaUtils.CheckSwitchAction(true, true, false, 0)

		gCS.CCTransitionManager.ResetNextMoveTarget()

		if not flag then
			print_error("#NoCreateIssue Interaction:  CheckSwitchAction return false")
			OnRealFinish(false)
		end
	end
end

function M:OnUnBindItem()
	if self.unBindItemCallback then
		self.unBindItemCallback()

		self.unBindItemCallback = nil
	end
end

function M:SetUnBindItem(entityId)
	function self.unBindItemCallback()
		self:SetInteractItem(nil, entityId)
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnInteractDestructible, {
			isHookUp = false
		})
	end
end

function M:SetInteractItem(trans, entityId)
	if not gCS.LuaUtils.IsNull(trans) then
		gCS.DestructibleMgr:SetDestructibleUsingNoECS(entityId, true)
	end

	if not gCS.LuaUtils.IsNull(LX6.Item.DestructibleMgr.curInteractItem) and trans == nil and entityId then
		gCS.DestructibleMgr:SetDestructibleUsingNoECS(entityId, false)
	end

	LX6.Item.DestructibleMgr.curInteractItem = trans

	if not entityId then
		return
	end

	if trans then
		gClientToGameSceneDelegate:AskHandHoldDestructibleObject(entityId)
		gSpoonClientMgr:ReleaseDestructibleEvent(entityId, gSpoonEventType.DestructibleEventType.HandHold)
	else
		gClientToGameSceneDelegate:AskPutDownDestructibleObject(entityId)
		gSpoonClientMgr:ReleaseDestructibleEvent(entityId, gSpoonEventType.DestructibleEventType.PutDown)
	end
end

function M:OnStateTreeFinish(success)
	if self.stateTreeCallback then
		self.stateTreeCallback(success)

		self.stateTreeCallback = nil
	else
		print_debug("OnStateTreeFinish stateTreeCallback is nil 通用交互结束时间为空", success)
	end
end

function M:OnStateTreeClearStatus()
	if self.stateTreeCallback then
		self.stateTreeCallback(false)

		self.stateTreeCallback = nil
	end
end

function M:SetCCTransitionTargets(target, OnFinish, OnRealFinish, mode)
	if type(target) == "table" then
		if target.tran and target.onlyUsePointPos ~= false then
			gCS.CCTransitionManager.SetNextMoveTarget(CCTransitionTargetType.Interact, target.tran, Vector3.zero, Quaternion.identity, OnFinish, OnRealFinish, mode)
		else
			gCS.CCTransitionManager.SetNextMoveTarget(CCTransitionTargetType.Interact, nil, target.position, Quaternion.LookRotation(target.forward), OnFinish, OnRealFinish, mode)
		end
	else
		gCS.CCTransitionManager.SetNextMoveTarget(CCTransitionTargetType.Interact, target, Vector3.zero, Quaternion.identity, OnFinish, OnRealFinish, mode)
	end
end

function M:GetTransitionMode(param)
	if param.forceWalk then
		return CCTransitionMode.Walk
	end

	return CCTransitionMode.Default
end

function M:GetTwoSideOffsetByBody(type)
	local bodyType = GeneralModelConfig.GetConfig(gCS.MyPlayerManager.PlayerUnit.ClientData.ModelId).BodyType

	if type == self.CommonInteractType.Stall then
		return GameConfig.CommonInteractStallOffsetToPlayerType[bodyType]
	elseif type == self.CommonInteractType.DoubleBed then
		return GameConfig.doublebedDis
	elseif type == self.CommonInteractType.Lounge then
		return GameConfig.lyingchairDis
	elseif type == self.CommonInteractType.ChairGame then
		return GameConfig.CommonInteractJieJIOffsetToPlayerType[bodyType]
	end

	return GameConfig.CommonInteractStallOffsetToPlayerType[bodyType]
end

function M:TransformPoint(pos, forward, localPos)
	local rot = Quaternion.LookRotation(Vector3.Normalize(forward), Vector3.up)

	return pos + rot * localPos
end

function M:GetChairBestTarget(transList, entity, onlyUsePointPos, isLongChair, isDestructible, currentPos)
	local targetList = {}
	local leftTarget = nil

	if type(transList[1]) == "table" then
		leftTarget = self:TransformPoint(transList[1].position, transList[1].forward, Vector3.New(-GameConfig.SitChairLeftDis, -0.49, GameConfig.SitChairSideFrontDis))
	else
		leftTarget = transList[1]:TransformPoint(Vector3.New(-GameConfig.SitChairLeftDis, -0.49, GameConfig.SitChairSideFrontDis))
	end

	local rightTarget = nil

	if type(transList[#transList]) == "table" then
		rightTarget = self:TransformPoint(transList[1].position, transList[1].forward, Vector3.New(GameConfig.SitChairLeftDis, -0.49, GameConfig.SitChairSideFrontDis))
	else
		rightTarget = transList[#transList]:TransformPoint(Vector3.New(GameConfig.SitChairLeftDis, -0.49, GameConfig.SitChairSideFrontDis))
	end

	for i, v in ipairs(transList) do
		local pos, checkPos = nil

		if type(v) == "table" then
			if onlyUsePointPos then
				pos = v.position
				checkPos = v.position
			else
				pos = self:TransformPoint(v.position, v.forward, Vector3.New(0, -0.49, GameConfig.SitChairFrontDis))
				checkPos = self:TransformPoint(v.position, v.forward, Vector3.New(0, -0.49, GameConfig.StandChairCapsulFrontDis))
			end
		elseif onlyUsePointPos then
			pos = v.position
			checkPos = v.position
		else
			pos = v:TransformPoint(Vector3.New(0, -0.49, GameConfig.SitChairFrontDis))
			checkPos = v:TransformPoint(Vector3.New(0, -0.49, GameConfig.StandChairCapsulFrontDis))
		end

		local data = {
			position = pos,
			forward = v.forward,
			checkPos = checkPos,
			side = self.CommonInteractType.SitFront,
			onlyUsePointPos = onlyUsePointPos,
			index = i - 1
		}

		if type(v) == "table" then
			data.tranTable = v
		else
			data.tran = v
		end

		table.insert(targetList, data)
	end

	local leftUseful, rightUseful = nil
	targetList, leftUseful, rightUseful = self:GetUsefulTarget(targetList, entity, isDestructible)

	if not onlyUsePointPos and (#targetList == 0 or leftUseful) then
		local data = {
			index = 0,
			position = leftTarget,
			forward = transList[1].forward,
			side = self.CommonInteractType.SitLeft,
			onlyUsePointPos = onlyUsePointPos
		}

		if type(transList[1]) == "table" then
			data.tranTable = transList[1]
		else
			data.tran = transList[1]
		end

		table.insert(targetList, data)
	end

	if not onlyUsePointPos and (#targetList == 0 or rightUseful) then
		local data = {
			position = rightTarget,
			forward = transList[#transList].forward,
			side = self.CommonInteractType.SitRight,
			onlyUsePointPos = onlyUsePointPos,
			index = #transList - 1
		}

		if type(transList[#transList]) == "table" then
			data.tranTable = transList[#transList]
		else
			data.tran = transList[#transList]
		end

		table.insert(targetList, data)
	end

	if #targetList == 0 then
		return nil
	end

	local minTarget = self:GetChairFinalTarget(targetList, isLongChair, currentPos)

	return minTarget
end

function M:GetChairFinalTarget(targetList, isLongChair, currentPos)
	if currentPos == nil then
		currentPos = gCS.MyPlayerManager.PlayerUnit.PlayerObj.position
	end

	local target = nil

	for i, v in ipairs(targetList) do
		if v.side == self.CommonInteractType.SitFront then
			target = v

			break
		end
	end

	if not target or isLongChair then
		local minDis = 999999

		for i, v in ipairs(targetList) do
			local dis = Vector3.Distance(currentPos, v.position)

			if dis < minDis then
				minDis = dis
				target = v
			end
		end
	end

	if not target then
		return nil
	end

	if target.tran == nil or type(target.tran) == "table" then
		gCS.TransitionMgr.chairPointTran = nil
		gCS.TransitionMgr.chairPointPosition = target.position
		gCS.TransitionMgr.chairPointForward = target.forward
	else
		gCS.TransitionMgr.chairPointTran = target.tran
	end

	return target
end

function M:GetUsefulTarget(targetList, entity, isDestructible)
	local function IsUseful(index)
		if not entity then
			return true
		end

		if isDestructible then
			return true
		end

		if #targetList == 1 then
			return gGadgetManager:IsEntityInterestIndexUseful(entity, -1)
		end

		return gGadgetManager:IsEntityInterestIndexUseful(entity, index - 1)
	end

	local leftPoint = targetList[1]
	local rightPoint = targetList[#targetList]
	local leftUseful = true
	local rightUseful = true

	for i = #targetList, 1, -1 do
		if not IsUseful(i) then
			if leftPoint == targetList[i] then
				leftUseful = false
			end

			if rightPoint == targetList[i] then
				rightUseful = false
			end

			table.remove(targetList, i)
		elseif not gCS.LuaUtils.CheckPlayerChairUseful(targetList[i].checkPos) and not targetList[i].onlyUsePointPos then
			table.remove(targetList, i)
		end
	end

	return targetList, leftUseful, rightUseful
end

function M:TryDoSlotBtnAction(buttonInfo)
	if buttonInfo.buttonFireEvent and not gCS.LuaUtils.IsNull(buttonInfo.buttonFireEvent.Target) then
		buttonInfo.buttonFireEvent:DynamicInvoke()
	end
end

function M:TryDoNpcBtnAction(npc, taskId, param, eventId)
	if self.DebugMode then
		print_notice("Interaction Debug => InteractionManager:TaskDoNpcAction/触发任务交互/AskDoNpcAction开始", Time.frameCount, Time.time)
	end

	gClientToGameSceneDelegate:AskDoNpcAction(npc.NpcId, 0, ulong.tonum2(npc.Pid), taskId, eventId, param.index - 1).Callback = function (err)
		if self.DebugMode then
			print_notice("Interaction Debug => InteractionManager:TaskDoNpcAction/触发任务交互/AskDoNpcAction 接收到 Callback, err=", gCS.Error.GetNameById(err), Time.frameCount, Time.time)
		end

		if err ~= MessageConfig.Ok then
			print_warn("AskDoNpcAction Fail, taskSpoon", gCS.Error.GetNameById(err))
		end
	end
end

function M:CommonInteractBreak(type)
	self:SetCommonInteractEnd(type)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.BreakCommonInteractTrigger, {
		type = type
	})
end

function M:DebugPlayStateForInteract()
	print_error("DebugPlayStateForInteract CheckCanVehicleInteract", gMainMenuMgr:CheckCanVehicleInteract())
	print_error("DebugPlayStateForInteract CheckCanGroundInteract", gMainMenuMgr:CheckCanGroundInteract())
	print_error("DebugPlayStateForInteract CheckCanWallInteract", gMainMenuMgr:CheckCanWallInteract())
	print_error("DebugPlayStateForInteract CheckCanChairInteract", gMainMenuMgr:CheckCanChairInteract())
	print_error("DebugPlayStateForInteract GetClientState", gMainMenuMgr:GetClientState())
end

function M:UnitStartStorge(cs_unit, param)
	param = param or {
		type = self.CommonInteractType.Storage,
		posTrans = {
			position = cs_unit.LocalPosition,
			forward = cs_unit.LocalPosition - gCS.MyPlayerManager.PlayerUnit.LocalPosition
		},
		loopTime = GameConfig.StorgeLoopTime,
		ikPosTrans = cs_unit.ModelSlot.headSlot,
		selfTrans = cs_unit.PlayerObj
	}
	local unit = gCS.SceneDataMgr.GetUnit(cs_unit.Pid)

	if not unit then
		return
	end

	local function PlayEffect()
		local pid = cs_unit.Pid
		local unitPos = unit.UpBodyPosition
		local scale = 1

		gLuaTimeMgrUtils.Delay(function ()
			gCS.EffectMgr:PlayEffectsForUnit(gCS.MyPlayerManager.PlayerUnit, GameConfig.StorgeHandEffect)
		end, 0.4, nil, nil, true)
		gLuaTimeMgrUtils.Delay(function ()
			local uuid = gCS.EffectMgr:PlayEffects(GameConfig.StorgeEndEffect, unitPos)

			gCS.EffectMgr:SetEffectItemScaleByUUId(uuid, scale)
		end, 0.8, nil, nil, true)
		gLuaTimeMgrUtils.Delay(function ()
			UnitModelManager.HideOrShowAllRender(unit, false, true)
			gClientToGameSceneDelegate:AskCaptureAgentFinished(pid)
		end, 1.6)
		gLuaTimeMgrUtils.Delay(function ()
			gObjectManager:PlayPickUpEffect(GameConfig.StorgeEndFlyEffect, nil, unitPos, nil, true, function ()
				gCS.EffectMgr:PlayEffectsForUnit(gCS.MyPlayerManager.PlayerUnit, GameConfig.StorgeEndPlayerEffect)
				gCS.CameraDataMgr.cinemachineManager:DisableFocusNpcCamera()
			end)
		end, 2.1, nil, nil, true)
	end

	self:OnEnterUnitCommonInteract(param, PlayEffect)
end

function M:OnSlotStartStorage(param)
	if param.type ~= self.CommonInteractType.Storage then
		return
	end

	local pos = param.storageEffectTrans.position

	gLuaTimeMgrUtils.Delay(function ()
		gCS.EffectMgr:PlayEffectsForUnit(gCS.MyPlayerManager.PlayerUnit, GameConfig.StorgeHandEffect)
	end, 0.4, nil, nil, true)
	gLuaTimeMgrUtils.Delay(function ()
		gCS.EffectMgr:PlayEffects(GameConfig.StorgeEndEffect, pos)
	end, 0.8, nil, nil, true)
	gLuaTimeMgrUtils.Delay(function ()
		gObjectManager:PlayPickUpEffect(GameConfig.StorgeEndFlyEffect, nil, pos, nil, true, function ()
			gCS.EffectMgr:PlayEffectsForUnit(gCS.MyPlayerManager.PlayerUnit, GameConfig.StorgeEndPlayerEffect)
		end)
	end, 2.1, nil, nil, true)
end

function M:SetCommonInteractEnd(typeNum)
	local cfg = CommonInteractConfig.GetConfig(typeNum)

	if cfg and cfg.IsStateTree then
		gCS.LogicStateMachineManager.SendGeneralInteractEvent(gCS.MyPlayerManager.PlayerUnit, 1, typeNum)

		return
	end

	gCS.TransitionMgr.commonInteractEndActionType = typeNum

	if typeNum == gInteractionManager.CommonInteractType.Sit then
		gCS.TransitionMgr.setChairUp = true
	end

	gCS.LuaUtils.CheckSwitchAction(false, true, false, 0)

	gCS.TransitionMgr.commonInteractEndActionType = 0
	gCS.TransitionMgr.setChairUp = false
	self.currentInteractType = nil
end

M.BtnTargetType = {
	Gadget = 1,
	Destructible = 4,
	Vehicle = 2,
	Npc = 3
}

function M:CheckIsEnterInteractionRange(id, gpsTargetType)
	if L50.L50App.L50Game.InteractBtnMgr:HasUsefulBtn() then
		return L50.L50App.L50Game.InteractBtnMgr:ExistPid(id)
	end

	return false
end

function M:CheckUnitPcBtnShow(pid)
	local BtnMgr = L50.L50App.L50Game.InteractBtnMgr

	if BtnMgr and BtnMgr:HasUsefulBtn() then
		return BtnMgr:ExistPid(pid)
	end

	return false
end

function M:CheckUnitPcBtnHideByDis(pid)
	return L50.L50App.L50Game.InteractBtnMgr:CheckUnitPcBtnHideByDis(pid)
end

M.registerInteractIndicateList = {}

function M:RegisterIndicate(data)
	data = data:ToTable()
	local getFunc = data.GetTarget

	function data.GetTarget()
		return getFunc:DynamicInvoke()
	end

	local rateFunc = data.IndicateDisRate

	if rateFunc then
		function data.IndicateDisRate()
			return rateFunc:DynamicInvoke()
		end
	end

	if data.InDis then
		local inDisFun = data.InDis

		function data.InDis()
			return inDisFun:DynamicInvoke()
		end
	end

	if not self.hintInfosHudStore then
		table.insert(self.registerInteractIndicateList, data)

		return
	end

	self.hintInfosHudStore:RegisterIndicateTarget(data)
end

function M:RegisterUnitIndicate(pid, dis, target, offsetY)
	local data = {
		index = 0,
		isImportant = false,
		isUnit = true,
		pid = pid,
		dis = dis,
		offsetY = offsetY,
		GetTarget = function ()
			if gCS.LuaUtils.IsNull(target) then
				return nil
			end

			return target
		end
	}

	if not self.hintInfosHudStore then
		table.insert(self.registerInteractIndicateList, data)

		return
	end

	self.hintInfosHudStore:RegisterIndicateTarget(data)
end

function M:UnRegisterIndicate(pid, index)
	if not pid then
		return
	end

	if not self.hintInfosHudStore then
		for i = #self.registerInteractIndicateList, 1, -1 do
			if self.registerInteractIndicateList[i].pid == pid and (self.registerInteractIndicateList[i].index == index or index == nil) then
				table.remove(self.registerInteractIndicateList, i)
			end
		end

		return
	end

	self.hintInfosHudStore:UnRegisterIndicateTarget(pid, index)
end

function M:SetMindIndicateEnable(pid, enable)
	if not self.hintInfosHudStore then
		for i, v in ipairs(self.registerInteractIndicateList) do
			if v.pid == pid and v.isMindPower then
				v.enable = enable
			end
		end

		return
	end

	self.hintInfosHudStore:SetMindIndicateTargetEnable(pid, enable)
end

function M:SetNewInteractionUseMobile(enable)
	gInteractionManager.hintInfosHudStore.testMobile = enable
end

function M:CheckCardSwipedSuccess(value)
	return true
end

function M:GadgetDynamicBind(unit, interactActionType, index, dynamicBindItem, delayTime, bindTrans)
	local gTrans = nil

	if unit.IsMe then
		if not self.CommonInteractInfo[interactActionType] or not self.CommonInteractInfo[interactActionType][index] then
			print_error("@wangjiao01 An error occurred in GadgetDynamicBind " .. interactActionType .. index .. dynamicBindItem .. delayTime)

			return
		end

		local gTransId = self.CommonInteractInfo[interactActionType][index][2]
		local entityId = self.CommonInteractInfoId

		if gLinkManager:CheckInLinkMode() then
			gClientToGameSceneDelegate:AskDoInteractBindPerformance(entityId, gTransId, interactActionType, index, dynamicBindItem, LTUtils.UXTime.GetNowUnixTime(), delayTime)
		end

		gTrans = self.CommonInteractInfo[interactActionType][index][1]
	else
		gTrans = bindTrans
	end

	gLuaTimeMgrUtils.Delay(function ()
		local trans = gCS.UnitBindItem.UnManageDynamicItem(unit, dynamicBindItem)

		if not trans then
			print_error("GadgetDynamicBind failed, " .. gCS.MyPlayerManager.PlayerUnit.Pid .. unit.Pid .. interactActionType .. index .. dynamicBindItem .. delayTime)

			return
		end

		trans:SetParent(gTrans)
		trans:SetLocalPosition(0, 0, 0)
		trans:SetLocalEulerAngles(0, 0, 0)
	end, delayTime, nil, nil, true)
end

function M:DrillShelfBeginPick()
	if not self.drillShelfMgrData or self:CheckDrillShelfEnd() then
		return
	end

	local dataList = self.drillShelfMgrData.dataList
	local index = self.drillShelfMgrData.index
	local drillShelfData = dataList[index]

	if not drillShelfData then
		return
	end

	local score = self.drillShelfMgrData.score
	local DrillShelfRewardItem = {
		Normal = 1,
		Task = 2,
		None = 0
	}

	if drillShelfData.rwd == DrillShelfRewardItem.Normal then
		gMessageManager:SendMessage(gEventConstants.ROB_BANK_DRILL_SHELF_REWARD, {
			score = score,
			rwd = drillShelfData.rwd,
			entityInstanceId = self.drillShelfEntityInstanceId
		})
	elseif drillShelfData.rwd == DrillShelfRewardItem.Task then
		gMessageManager:SendMessage(gEventConstants.ROB_BANK_DRILL_SHELF_REWARD, {
			rwd = drillShelfData.rwd,
			entityInstanceId = self.drillShelfEntityInstanceId
		})
	end
end

function M:SetDrillShelfData(drillShelfMgrData, entityInstanceId)
	if entityInstanceId == self.drillShelfEntityInstanceId then
		return
	end

	if drillShelfMgrData and drillShelfMgrData.ToTable then
		drillShelfMgrData = drillShelfMgrData:ToTable()

		if drillShelfMgrData.dataList.ToTable then
			drillShelfMgrData.dataList = drillShelfMgrData.dataList:ToTable()
			local dataList = {}

			for _, v in ipairs(drillShelfMgrData.dataList) do
				if v.ToTable then
					table.insert(dataList, v:ToTable())
				end
			end

			drillShelfMgrData.dataList = dataList
		end
	end

	self.drillShelfMgrData = drillShelfMgrData
	self.drillShelfEntityInstanceId = entityInstanceId
end

function M:CheckBankRobDrillShelfState(checkTypeValue, heightValue, switchShelf)
	if self.drillShelfMgrData.index == 1 then
		return self.drillShelfMgrData.dataList[1].row == heightValue and not switchShelf
	end

	local index = self.drillShelfMgrData.index
	local dataList = self.drillShelfMgrData.dataList

	if index > #self.drillShelfMgrData.dataList then
		return false
	end

	local preDrillShelfData = dataList[index - 1]
	local nextDrillShelfData = dataList[index]
	local switchRow = preDrillShelfData.col ~= nextDrillShelfData.col

	if checkTypeValue == 1 then
		return heightValue == nextDrillShelfData.row
	elseif checkTypeValue == 2 then
		return switchRow == switchShelf
	end

	return switchRow == switchShelf and heightValue == nextDrillShelfData.row
end

function M:ProceedDrillShelfNextStep()
	local dataList = self.drillShelfMgrData.dataList
	local drillShelfData = dataList[self.drillShelfMgrData.index]

	gMessageManager:SendMessage(gEventConstants.ROB_BANK_DRILL_SHELF_OPEN, {
		row = drillShelfData.row,
		col = drillShelfData.col,
		entityInstanceId = self.drillShelfEntityInstanceId
	})

	self.drillShelfMgrData.index = self.drillShelfMgrData.index + 1
end

function M:CheckDrillShelfEnd()
	return self.drillShelfMgrData and #self.drillShelfMgrData.dataList < self.drillShelfMgrData.index
end

function M:PlayMindPowerAnim()
	if self.hintInfosHudStore then
		self.hintInfosHudStore:PlayMindPowerAnim()
	end
end

function M:GadgetIsNotInIndicate(slotEntityId)
	if self.hintInfosHudStore then
		local data = self.hintInfosHudStore.indicateList[slotEntityId]

		if data then
			for _, v in pairs(data) do
				if v.isMindPower and v.isTooShort then
					return false
				end
			end
		end
	end

	return true
end

function M:HintHudSetDrag(isDrag, playAnim)
	if isDrag then
		if self.hintInfosHudStore then
			if playAnim then
				self.hintInfosHudStore.bindData.dragAnimation:Play("S_Vx_MindPowerNotify_Open", 0)
			end

			self.hintInfosHudStore:SetIsDrag(true)
		end
	elseif self.hintInfosHudStore then
		if playAnim then
			self.hintInfosHudStore:PlayMindPowerAnim()
		end

		self.hintInfosHudStore:SetIsDrag(false)
	end
end

function M:CheckPlayerInteractType()
	return self.isCommonInteractMoving
end

function M:ExitSceneItemInteract()
	self.currentInteractType = nil
end

function M:GetAgentInteractConfig(cfg)
	if not cfg or not cfg.InteractSetting then
		return nil
	end

	return LTConfig.AgentDataSetsInteractSettingConfig.GetConfig(cfg.InteractSetting)
end

function M:CompareTarget(a, b)
	if a.type == b.type then
		if TargetSortable[a.type] then
			return a:CompareTo(b)
		end
	else
		return b.type < a.type
	end

	return false
end

function M:SetDebugMode(mode)
	self.DebugMode = mode
end

function M:SetDebugCheckAssistMode(mode)
	self.DebugCheckAssistMode = mode
end

function M:OnMindPowerTrigger(target)
	target:OnMindPowerTrigger()
end

gInteractionManager = gInteractionManager or C_InteractionManager.new()
