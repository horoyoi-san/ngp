-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CarChaseEnergyBarStore.lua
-- Decompiled from: 01633_CarChaseEnergyBarStore.lua_6cd89aeced96.luajit

local PoliceChargingSkillConfig = LTConfig.PoliceChargingSkillConfig
local PoliceChargeEventConfig = LTConfig.PoliceChargeEventConfig
local PoliceConfig = LTConfig.PoliceConfig
C_CarChaseEnergyBarStore = DefClass("C_CarChaseEnergyBarStore", C_CarChaseEnergyBarStore, C_StoreGroup)
GroupName2Class.CarChaseEnergyBarStore = C_CarChaseEnergyBarStore
local M = C_CarChaseEnergyBarStore
local MyPlayerManager = gCS.MyPlayerManager
local DragEventListener = SGUI.EventSystems.DragEventListener

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.initCircle = false

	self.InitInfo(self)

	self.bindData.SkillBtn.luaPress = self.CreateAction(self, "OnClickSkillBtn")
	self.bindData.SkillBtn.luaRelease = self.CreateAction(self, "OnReleaseSkillBtn")
	local skillBtnDrag = DragEventListener.Get(self.bindData.SkillBtn.gameObject)
	skillBtnDrag.onBeginDrag = self.CreateAction(self, "OnDragMoveStart")
	skillBtnDrag.onDrag = self.CreateAction(self, "OnDragMove")
	skillBtnDrag.onEndDrag = self.CreateAction(self, "OnDragMoveEnd")
	self.bindData.closeCircleBtn.luaRelease = self.CreateAction(self, "OnCloseSkillBtn")
	self.bindData.skillCustomResponed.luaGamePadInputChanged = self.CreateAction(self, "OnGamepadSkill")
	self.bindData.energyBarList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderEnergyBarListItem")
	self.bindData.wheelList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSkillCircleListItem")
	self.bindData.mouseMoveRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMouseMove")
	self.bindData.padStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnStickMove")
	self.msgEvents = {
		[gEventConstants.CAR_CHASE_PROGRESS_CHANGE] = self.CreateAction(self, "CarChaseProgressChange")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
	self.ResetInfo(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.InitInfo = function(self)
	self.wheelItemCount = 6
	self.passTime = 0
	self.SMOOTH_TIME = 0.1
	self.countSpeedTime = 0
	self.minDistance = PoliceChargeEventConfig.GetConfig(4).EventThreshold[1]
	self.hasDrift = false
	self.tempVehicleHp = 0
	self.curSelectIndex = 0
	self.countDonwHideCombo = 0
	self.bindData.isShowCircle = 0
	self.bindData.isShowKey = 1
	self.bindData.isShowComb = 1
	self.MinVectorLength = 20
	self.moveVector = Vector2.New(0, 1)
	self.accumulateMoveVector = Vector2.New(0, 0)
	self.smoothStartVector = Vector2.New(0, 0)
	self.smoothEndVector = Vector2.New(0, 0)
	self.MaxVectorLength = 40000
	self.cicleInitVector = Vector2.New(0, 1)
	self.circleEachAngle = math.floor(360 / self.wheelItemCount)
	self.cicleInitHalfItemAngle = 180 / self.wheelItemCount
	self.progress = 0
	self.maxLayer = 0
	self.addSpeed = nil
	self.pauseUUID = nil
	self.countTime = 0
	self.curEmpData = nil
	self.curInformationInterferenceData = nil
	self.updateEMP = false
	self.updateInformationInterference = false
	self.closeEMPTime = nil
	self.isDragMove = false

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.isShowQte = 0
	end
end

M.OnShow = function(self, panelId, data)
	self.InitSkillCircle(self)
end

M.ResetInfo = function(self)
	self.passTime = 0
	self.countSpeedTime = 0
	self.hasDrift = false
	self.tempVehicleHp = 0
	self.curSelectIndex = 0
	self.countDonwHideCombo = 0
	self.bindData.isShowCircle = 0
	self.bindData.isShowKey = 1
	self.bindData.isShowComb = 1
	self.moveVector = Vector2.New(0, 1)
	self.accumulateMoveVector = Vector2.New(0, 0)
	self.smoothStartVector = Vector2.New(0, 0)
	self.smoothEndVector = Vector2.New(0, 0)
	self.progress = 0
	self.maxLayer = 0
	self.addSpeed = nil
	self.pauseUUID = nil
	self.countTime = 0
	self.curEmpData = nil
	self.curInformationInterferenceData = nil
	self.updateEMP = false
	self.updateInformationInterference = false
	self.closeEMPTime = nil
	self.bindData.skillText = ""
	self.bindData.skillDes = ""
	self.bindData.showTip = 0
	self.bindData.showFocus = 0
	self.bindData.tipIsFail = 0
	self.bindData.tipType = 0
	local data = {
		progress = gPoliceChaseManager.progress,
		maxLayer = gPoliceChaseManager.maxLayer,
		speed = gPoliceChaseManager.speed or 0
	}
	self.glowTimer = {}
	self.energyBarList = {}

	self:CarChaseProgressChange(nil, data)

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.isShowQte = 0
	end

	self.InitSkillCircle(self)
	self.ResetSelectToFirst(self)
end

M.ResetSelectToFirst = function(self)
	self.updateSelect = true
	self.moveVector = Vector2.New(0, 1)
	self.accumulateMoveVector = Vector2.New(1000, 1414)

	self.SetVectorLength(self, self.accumulateMoveVector, self.MaxVectorLength)
	self.SetSmoothMove(self, self.accumulateMoveVector)
	self.UpdateSmoothMoveVector(self)
	self.UpdateCircle(self, true)
end

M.OnUpdate = function(self)
	if self.bindData.isShowCircle ~= 1 and self.updateSelect then
		self.UpdateSmoothMoveVector(self)
		self.UpdateCircle(self)
	end

	if gPoliceChaseManager.chaseVehicleUId ~= nil then
		if self.bindData.isShowComb ~= 0 then
			self.bindData.isShowComb = 1
		end

		return
	end

	if self.countDonwHideCombo and self.countDonwHideCombo <= 0 then
		self.countDonwHideCombo = self.countDonwHideCombo - Time.deltaTime

		if self.countDonwHideCombo < 0 then
			self.bindData.isShowComb = 1
		end
	end

	local baseVehicle = gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle
	local tempVehicle = nil

	if baseVehicle and self.pauseUUID ~= nil then
		self.countTime = self.countTime + Time.deltaTime

		if self.progress and self.addSpeed and self.countTime > 1 and self.progress < self.maxLayer * PoliceConfig.ChargingValueEachLayer then
			self.progress = self.progress + self.addSpeed

			self.SetChaseProgress(self)

			self.countTime = 0
		end

		if PoliceChargeEventConfig.GetConfig(2).EventThreshold[1] < baseVehicle.Speed then
			self.countSpeedTime = self.countSpeedTime + Time.deltaTime

			if PoliceChargeEventConfig.GetConfig(2).EventThreshold[2] >= self.countSpeedTime then
				self.countSpeedTime = 0

				gPoliceChaseManager:AddPoliceChargingProgress(2)
				self:SetAddCount(2)
			end
		end

		tempVehicle = gDriveVehiclesManager.cs_manager:GetBaseVehicle(gPoliceChaseManager.chaseVehicleUId)

		if tempVehicle and baseVehicle.gameObject and not gCS.LuaUtils.IsNull(baseVehicle.gameObject) and baseVehicle.gameObject.transform and tempVehicle.gameObject and not gCS.LuaUtils.IsNull(tempVehicle.gameObject) and tempVehicle.gameObject.transform then
			local distance = Vector3.Distance(baseVehicle.gameObject.transform.position, tempVehicle.gameObject.transform.position)

			if distance < self.minDistance then
				self.passTime = self.passTime + Time.deltaTime

				if PoliceChargeEventConfig.GetConfig(4).EventThreshold[2] >= self.passTime then
					self.passTime = 0

					gPoliceChaseManager:AddPoliceChargingProgress(4)
					self:SetAddCount(4)
				end
			end

			if tempVehicle.CurrentHp and self.tempVehicleHp == tempVehicle.CurrentHp then
				self.tempVehicleHp = tempVehicle.CurrentHp

				gHudMgr:VehicleHpChanged(gPoliceChaseManager.chaseVehicleUId, self.tempVehicleHp / tempVehicle.MaxHp)
			end
		end

		if baseVehicle.IsDrifting then
			if PoliceChargeEventConfig.GetConfig(1).EventThreshold[1] < math.abs(baseVehicle.VdAngle) and self.hasDrift ~= false then
				self.hasDrift = true

				gPoliceChaseManager:AddPoliceChargingProgress(1)
				self:SetAddCount(1)
			end
		elseif self.hasDrift then
			self.hasDrift = false
		end
	end

	self.UpdateEmp(self, baseVehicle, tempVehicle)
	self.UpdateInformationInterference(self)
	self.UpdateGlowFx(self)
end

M.OnClose = function(self)
	self.countTime = 0
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.OnDragMoveStart = function(self, eventPointer)
	self.isDragMove = true
end

M.OnDragMoveEnd = function(self, eventPointer)
	self.isDragMove = false
end

M.OnDragMove = function(self, eventPointer)
	self.accumulateMoveVector:Add(eventPointer.delta * 5)
	self:SetVectorLength(self.accumulateMoveVector, self.MaxVectorLength)

	if self.MinVectorLength < self.accumulateMoveVector.sqrMagnitude then
		self.SetSmoothMove(self, self.accumulateMoveVector)
	else
		self.ClearSmoothMove(self)
	end
end

M.OnMouseMove = function(self, context)
	if self.isDragMove then
		return
	end

	if context.performed then
		self.accumulateMoveVector:Add(context:ReadValueVector2())
		self:SetVectorLength(self.accumulateMoveVector, self.MaxVectorLength)

		if self.MinVectorLength < self.accumulateMoveVector.sqrMagnitude then
			self.SetSmoothMove(self, self.accumulateMoveVector)
		else
			self.ClearSmoothMove(self)
		end
	end
end

M.OnStickMove = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.performed then
		self.UpdateSmoothMoveVector(self)
		self.SetSmoothMove(self, value)
	elseif context.canceled then
		self.ClearSmoothMove(self)
	end
end

M.SetVectorLength = function(self, vec, maxLength)
	local length = vec.sqrMagnitude

	if maxLength >= length then
		vec.Mul(vec, maxLength / length)
	end
end

M.ClearSmoothMove = function(self)
	self.updateSelect = false
end

M.SetSmoothMove = function(self, moveVector)
	self.updateSelect = true
	self.smoothStartVector.x = self.moveVector.x
	self.smoothStartVector.y = self.moveVector.y
	self.smoothStartTime = Time.unscaledTime
	self.smoothEndVector.x = moveVector.x
	self.smoothEndVector.y = moveVector.y
end

M.UpdateSmoothMoveVector = function(self)
	if not self.updateSelect then
		return
	end

	if self.gamepadMode then
		local x, y = gCS.LuaUtils.Vector3Slerp(self.smoothStartVector.x, self.smoothStartVector.y, 0, self.smoothEndVector.x, self.smoothEndVector.y, 0, (Time.unscaledTime - self.smoothStartTime) / self.SMOOTH_TIME)
		self.moveVector.x = x
		self.moveVector.y = y

		if self.SMOOTH_TIME >= Time.unscaledTime - self.smoothStartTime then
			self.ClearSmoothMove(self)
		end
	else
		self.moveVector.x = self.smoothEndVector.x
		self.moveVector.y = self.smoothEndVector.y

		self.ClearSmoothMove(self)
	end
end

M.UpdateCircle = function(self, force)
	local index, angle = self.GetCirleSelect(self, self.moveVector)

	self.SetCircleSelect(self, index, force)

	self.bindData.arrowAngle = self.cicleInitHalfItemAngle - angle
end

M.SetCircleSelect = function(self, index, force)
	if self.curSelectIndex == index or force then
		if self.curSelectIndex <= 0 and self.skillList[self.curSelectIndex] then
			self.skillList[self.curSelectIndex].isFocus = false
		end

		if index <= 0 and self.skillList[index] then
			self.skillList[index].isFocus = true
			self.bindData.skillText = self.skillList[index].Name
			self.bindData.skillDes = self.skillList[index].Des
		end

		self.curSelectIndex = index

		self.bindData.wheelList:RefreshList()
	end
end

M.GetCirleSelect = function(self, moveVector)
	local angle = -Vector2.SignedAngle(self.cicleInitVector, moveVector)

	if angle >= 0 then
		angle = angle + 360
	end

	local index = math.floor(angle / self.circleEachAngle) + 1

	if self.wheelItemCount >= index then
		index = 1
	end

	return index, angle
end

M.InitSkillCircle = function(self)
	if self.initCircle then
		return
	end

	self.initCircle = true
	self.skillList = {}

	for index = 0, PoliceChargingSkillConfig.count - 1 do
		local cfg = PoliceChargingSkillConfig.LoadAt(index)
		local view = {
			Id = cfg.Id,
			Name = cfg.Name or "",
			Des = cfg.Des or "",
			Layer = cfg.Layer,
			SkillId = cfg.SkillId,
			Dialog = cfg.Dialog,
			BadgeId = cfg.BadgeId,
			Icon = cfg.Icon,
			isFocus = false,
			duration = cfg.Duration,
			distance = cfg.Distance,
			skillType = cfg.SkillType,
			canUse = self.progress < cfg.Layer * PoliceConfig.ChargingValueEachLayer
		}
		local isUnlock = gSpiritJobManager:CheckCurSpiritContainBadge(cfg.BadgeId)

		if isUnlock or cfg.BadgeId ~= 0 then
			table.insert(self.skillList, view)
		end
	end

	self.bindData.wheelList:SetSimpleList(#self.skillList)
end

M.SetAddCount = function(self, eventId)
	self.countDonwHideCombo = 2.233
	self.bindData.isShowComb = 0
	local cfg = PoliceChargeEventConfig.GetConfig(eventId)
	self.bindData.addCount = "+" .. cfg.Charge or 0
	self.bindData.addCountText = cfg.Name or ""
end

M.OnGamepadSkill = function(self, context)
	if context.performed and not self.pauseUUID then
		self.OnClickSkillBtn(self)
	end

	if context.canceled and self.pauseUUID then
		self.OnReleaseSkillBtn(self)
	end
end

M.OnClickSkillBtn = function(self)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	self.pauseUUID = gCS.PauseManager.Instance:SetGlobalPause(UX.Game.GamePauseReason.Guide, PoliceConfig.ChasingSkillPauseTimeScale, -1)
	self.bindData.isShowCircle = 1
end

M.OnReleaseSkillBtn = function(self)
	if not self.pauseUUID then
		return
	else
		gCS.PauseManager.Instance:RemoveGlobalPause(self.pauseUUID)

		self.pauseUUID = nil
	end

	self.bindData.isShowCircle = 0

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end

	local data = self.skillList[self.curSelectIndex]

	if data and data.canUse and gPoliceChaseManager.chaseVehicleUId then
		if data.Id ~= PoliceChargingSkillConfig.EMP then
			self.DoEmpSkill(self, data)
		elseif data.Id ~= PoliceChargingSkillConfig.InfoInterference then
			self.DoInformationInterferenceSkill(self, data)
		elseif data.skillType ~= PoliceChargingSkillConfig.SkillTypeType.Client then
			gCS.BattleManager.UseSkillByPid(MyPlayerManager.PlayerUnit.Pid, data.SkillId)
		end

		gPoliceChaseManager:UsePoliceChargingProgress(data.Id, data.Id ~= 1)
	end

	self.ResetSelectToFirst(self)
end

M.OnCloseSkillBtn = function(self)
	if self.pauseUUID then
		gCS.PauseManager.Instance:RemoveGlobalPause(self.pauseUUID)

		self.pauseUUID = nil
	end

	self.bindData.isShowCircle = 0

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end
end

M.CarChaseProgressChange = function(self, eventId, data)
	if gPoliceChaseManager.chaseVehicleUId ~= nil then
		self.bindData.energyBarList:SetSimpleList(0)

		self.bindData.isShowKey = 1

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.isShowQte = 0
		end

		return
	end

	if data then
		self.addSpeed = data.speed
		self.progress = data.progress
		self.maxLayer = data.maxLayer
	end

	self.SetChaseProgress(self)
end

M.SetChaseProgress = function(self)
	local showKey = false

	if self.maxLayer then
		for i = 1, self.maxLayer do
			local view = self.energyBarList[i]

			if not view then
				view = {
					lastProgress = 0
				}

				table.insert(self.energyBarList, view)
			end

			view.lastProgress = view.progress

			if self.progress > i * PoliceConfig.ChargingValueEachLayer then
				view.progress = 1
				showKey = true
			elseif self.progress >= i * PoliceConfig.ChargingValueEachLayer and self.progress <= (i - 1) * PoliceConfig.ChargingValueEachLayer then
				view.progress = self.progress % PoliceConfig.ChargingValueEachLayer / PoliceConfig.ChargingValueEachLayer
			else
				view.progress = 0
			end
		end

		self.bindData.energyBarList:SetSimpleList(#self.energyBarList)
	end

	self.bindData.isShowKey = showKey and 0 or 1

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.isShowQte = showKey and 1 or 0
	end

	self.RefreshSkillCanUse(self)
end

M.RefreshSkillCanUse = function(self)
	if self.skillList and #self.skillList <= 0 then
		for i = 1, #self.skillList do
			if self.progress > self.skillList[i].Layer * PoliceConfig.ChargingValueEachLayer then
				local id = self.skillList[i].Id

				if id ~= PoliceChargingSkillConfig.EMP then
					self.skillList[i].canUse = self.curEmpData ~= nil
				elseif id ~= PoliceChargingSkillConfig.InfoInterference then
					self.skillList[i].canUse = self.curInformationInterferenceData ~= nil
				else
					self.skillList[i].canUse = true
				end
			else
				self.skillList[i].canUse = false
			end
		end

		self.bindData.wheelList:RefreshList()
	end
end

M.OnRenderEnergyBarListItem = function(self, btn, index)
	local data = self.energyBarList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("CarChaseEnergyBarTemplate"):GetStoreByWidget(btn)

	if store then
		local lastValue = data.lastProgress or 0
		local value = data.progress or 0

		if lastValue >= value and value - lastValue <= 0.1 then
			store.progress:ProgressToFxValue(value, 0.25)
			store.progress:ProgressToValue(value, 0.8, 0.5, DG.Tweening.Ease.InOutCirc)
		else
			store.progress:StopProgress()

			store.progress.value = value
			store.progress.fxValue = value
		end

		local active = lastValue >= 1 and value < 1

		if active then
			self.glowTimer[index] = {
				["A_ü\\x8d\\x8c\r\\xc4\\xed"] = 0.5
			}
			store.glowRoot.activation = true
		elseif not self.glowTimer[index] then
			store.glowRoot.activation = false
		end
	end
end

M.UpdateGlowFx = function(self)
	local delete = nil

	for index, data in pairs(self.glowTimer) do
		data.remainTime = data.remainTime - Time.deltaTime

		if data.remainTime < 0 then
			local success, btn = self.bindData.energyBarList:TryGetChildAt(index, nil)

			if success and btn then
				local store = gStoreManager:GetStoreGroup("CarChaseEnergyBarTemplate"):GetStoreByWidget(btn)

				if store then
					store.glowRoot.activation = false
				end
			end

			delete = delete or {}

			table.insert(delete, index)
		end
	end

	if delete then
		for i = 1, #delete do
			self.glowTimer[delete[i]] = nil
		end
	end
end

M.OnRenderSkillCircleListItem = function(self, btn, index)
	local data = self.skillList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("CarChaseSkillCircleTemplate"):GetStoreByWidget(btn)

	if store then
		store.icon = data.Icon
		store.isFocus = data.isFocus and 0 or 1
		store.canUse = data.canUse and 0 or 1
		local layerNum = 0

		if data.Layer and data.Layer <= 0 then
			layerNum = data.Layer
		end

		store.energyBarList:SetSimpleList(layerNum)
	end
end

M.OnHoverSkillCircleList = function(self, btn, data)
	self.bindData.skillText = data.Name
	self.bindData.skillDes = data.Des
end

M.DoEmpSkill = function(self, data)
	if not self.curEmpData and not self.updateEMP then
		self.curEmpData = data
		self.bindData.showTip = 1
		self.bindData.tipIsFail = 0
		self.bindData.tipType = 0
		self.updateEMP = true
		self.EMPTime = 0
		self.closeEMPTime = nil

		self.UpdateEmp(self)
	end
end

M.UpdateEmp = function(self, baseVehicle, tempVehicle)
	if self.curEmpData and self.updateEMP then
		local canShowFocus = false
		baseVehicle = baseVehicle or gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle
		tempVehicle = tempVehicle or gDriveVehiclesManager.cs_manager:GetBaseVehicle(gPoliceChaseManager.chaseVehicleUId)
		local targetTrans = nil

		if baseVehicle and tempVehicle and baseVehicle.gameObject and not gCS.LuaUtils.IsNull(baseVehicle.gameObject) and baseVehicle.gameObject.transform and tempVehicle.gameObject and not gCS.LuaUtils.IsNull(tempVehicle.gameObject) and tempVehicle.gameObject.transform then
			local playerTrans = baseVehicle.gameObject.transform
			targetTrans = tempVehicle.gameObject.transform
			local forward = playerTrans.forward
			local dir = targetTrans.position - playerTrans.position
			local angle = Vector2.SignedAngle(Vector2.New(forward.x, forward.z), Vector2.New(dir.x, dir.z))

			if angle >= 90 and angle <= -90 then
				local dis = dir.magnitude
				canShowFocus = dis <= self.curEmpData.distance
			end
		end

		self.EMPTime = self.EMPTime + Time.deltaTime

		if self.curEmpData.duration < self.EMPTime then
			self.updateEMP = false
			local empData = self.curEmpData
			self.curEmpData = nil
			self.bindData.skillProgress = 0
			self.bindData.skillProgressText = "100%"
			local useSuccess = false

			if canShowFocus and empData.skillType ~= PoliceChargingSkillConfig.SkillTypeType.Client then
				useSuccess = gCS.BattleManager.UseSkillByPid(MyPlayerManager.PlayerUnit.Pid, empData.SkillId)
			end

			self.bindData.tipIsFail = useSuccess and 0 or 1

			if useSuccess then
				self.closeEMPTime = nil
				self.bindData.showTip = 0
			else
				self.closeEMPTime = PoliceConfig.ChasingSkillTipCloseTime
			end

			canShowFocus = false

			self.RefreshSkillCanUse(self)
		else
			local progress = self.EMPTime / self.curEmpData.duration
			self.bindData.skillProgress = 1 - progress
			self.bindData.skillProgressText = tostring(math.floor(progress * 100)) .. "%"
		end

		self.bindData.showFocus = canShowFocus and 1 or 0

		if canShowFocus then
			local pos = targetTrans.position
			local iconPos = Vector3.New(pos.x, pos.y, pos.z)
			local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(iconPos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
			local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.focusRootTrans.parent, Vector3.New(x, y, 0))

			self.bindData.focusRootTrans:SetLocalPositionXY(UIPos.x, UIPos.y)
		end
	elseif self.closeEMPTime then
		self.closeEMPTime = self.closeEMPTime - Time.deltaTime

		if self.closeEMPTime >= 0 then
			self.bindData.showTip = 0
			self.closeEMPTime = nil
		end
	end
end

M.DoInformationInterferenceSkill = function(self, data)
	if not self.curInformationInterferenceData and not self.updateInformationInterference and (data.skillType == PoliceChargingSkillConfig.SkillTypeType.Client or gCS.BattleManager.UseSkillByPid(MyPlayerManager.PlayerUnit.Pid, data.SkillId)) then
		self.curInformationInterferenceData = data
		self.bindData.showTip = 1
		self.bindData.tipIsFail = 0
		self.bindData.tipType = 1
		self.updateInformationInterference = true
		self.informationInterferenceTime = 0

		self.UpdateInformationInterference(self)
	end
end

M.UpdateInformationInterference = function(self)
	if self.curInformationInterferenceData and self.updateInformationInterference then
		self.informationInterferenceTime = self.informationInterferenceTime + Time.deltaTime

		if self.curInformationInterferenceData.duration < self.informationInterferenceTime then
			self.bindData.showTip = 0
			self.updateInformationInterference = false
			self.curInformationInterferenceData = nil

			self.RefreshSkillCanUse(self)
		else
			local progress = self.informationInterferenceTime / self.curInformationInterferenceData.duration
			self.bindData.skillProgress = 1 - progress
			self.bindData.skillProgressText = tostring(math.floor(progress * 100)) .. "%"
		end
	end
end
