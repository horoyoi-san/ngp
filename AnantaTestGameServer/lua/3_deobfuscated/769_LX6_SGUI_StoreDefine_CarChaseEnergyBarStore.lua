local PoliceChargingSkillConfig = LTConfig.PoliceChargingSkillConfig
local PoliceChargeEventConfig = LTConfig.PoliceChargeEventConfig
local PoliceConfig = LTConfig.PoliceConfig
C_CarChaseEnergyBarStore = DefClass("C_CarChaseEnergyBarStore", C_CarChaseEnergyBarStore, C_StoreGroup)
GroupName2Class.CarChaseEnergyBarStore = C_CarChaseEnergyBarStore
local M = C_CarChaseEnergyBarStore
local MyPlayerManager = gCS.MyPlayerManager
local DragEventListener = SGUI.EventSystems.DragEventListener

function M:ctor()
	return
end

function M:OnAwake()
	self:InitInfo()

	self.bindData.SkillBtn.luaPress = self:CreateAction("OnClickSkillBtn")
	self.bindData.SkillBtn.luaRelease = self:CreateAction("OnReleaseSkillBtn")
	local skillBtnDrag = DragEventListener.Get(self.bindData.SkillBtn.gameObject)
	skillBtnDrag.onBeginDrag = self:CreateAction("OnDragMoveStart")
	skillBtnDrag.onDrag = self:CreateAction("OnDragMove")
	skillBtnDrag.onEndDrag = self:CreateAction("OnDragMoveEnd")
	self.bindData.closeCircleBtn.luaRelease = self:CreateAction("OnCloseSkillBtn")
	self.bindData.skillCustomResponed.luaGamePadInputChanged = self:CreateAction("OnGamepadSkill")
	self.bindData.energyBarList.luaRenderItem = self:CreateAction("OnRenderEnergyBarListItem")
	self.bindData.wheelList.luaRenderItem = self:CreateAction("OnRenderSkillCircleListItem")
	self.bindData.mouseMoveRespond.luaGamePadInputChanged = self:CreateAction("OnMouseMove")
	self.bindData.padStickRespond.luaGamePadInputChanged = self:CreateAction("OnStickMove")
	self.msgEvents = {
		[gEventConstants.CAR_CHASE_PROGRESS_CHANGE] = self:CreateAction("CarChaseProgressChange")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnEnable()
	self:ResetInfo()
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:InitInfo()
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

function M:OnShow(panelId, data)
	self:InitSkillCircle()
end

function M:ResetInfo()
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
end

function M:OnUpdate()
	if self.bindData.isShowCircle == 1 and self.updateSelect then
		self:UpdateSmoothMoveVector()
		self:UpdateCircle()
	end

	if gPoliceChaseManager.chaseVehicleUId == nil then
		if self.bindData.isShowComb == 0 then
			self.bindData.isShowComb = 1
		end

		return
	end

	if self.countDonwHideCombo and self.countDonwHideCombo > 0 then
		self.countDonwHideCombo = self.countDonwHideCombo - Time.deltaTime

		if self.countDonwHideCombo <= 0 then
			self.bindData.isShowComb = 1
		end
	end

	local baseVehicle = gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle
	local tempVehicle = nil

	if baseVehicle and self.pauseUUID == nil then
		self.countTime = self.countTime + Time.deltaTime

		if self.progress and self.addSpeed and self.countTime >= 1 and self.progress <= self.maxLayer * PoliceConfig.ChargingValueEachLayer then
			self.progress = self.progress + self.addSpeed

			self:SetChaseProgress()

			self.countTime = 0
		end

		if PoliceChargeEventConfig.GetConfig(2).EventThreshold[1] <= baseVehicle.Speed then
			self.countSpeedTime = self.countSpeedTime + Time.deltaTime

			print("车辆速度 Speed ：", baseVehicle.Speed)

			if PoliceChargeEventConfig.GetConfig(2).EventThreshold[2] < self.countSpeedTime then
				self.countSpeedTime = 0

				gPoliceChaseManager:AddPoliceChargingProgress(2)
				self:SetAddCount(2)
			end
		end

		tempVehicle = gDriveVehiclesManager.cs_manager:GetVehicle(gPoliceChaseManager.chaseVehicleUId)

		if tempVehicle then
			local distance = Vector3.Distance(baseVehicle.gameObject.transform.position, tempVehicle.gameObject.transform.position)

			if distance <= self.minDistance then
				self.passTime = self.passTime + Time.deltaTime

				if PoliceChargeEventConfig.GetConfig(4).EventThreshold[2] < self.passTime then
					self.passTime = 0

					gPoliceChaseManager:AddPoliceChargingProgress(4)
					self:SetAddCount(4)
				end
			end

			if tempVehicle.CurrentHp and self.tempVehicleHp ~= tempVehicle.CurrentHp then
				self.tempVehicleHp = tempVehicle.CurrentHp

				gHudMgr:VehicleHpChanged(gPoliceChaseManager.chaseVehicleUId, self.tempVehicleHp / tempVehicle.MaxHp)
			end
		end

		if baseVehicle.IsDrifting then
			print("漂移中，漂移角度：", baseVehicle.VdAngle)

			if PoliceChargeEventConfig.GetConfig(1).EventThreshold[1] <= math.abs(baseVehicle.VdAngle) and self.hasDrift == false then
				self.hasDrift = true

				gPoliceChaseManager:AddPoliceChargingProgress(1)
				self:SetAddCount(1)
			end
		elseif self.hasDrift then
			self.hasDrift = false
		end
	end

	self:UpdateEmp(baseVehicle, tempVehicle)
	self:UpdateInformationInterference()
	self:UpdateGlowFx()
end

function M:OnClose()
	self.countTime = 0
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnDragMoveStart(eventPointer)
	self.isDragMove = true
end

function M:OnDragMoveEnd(eventPointer)
	self.isDragMove = false
end

function M:OnDragMove(eventPointer)
	self.accumulateMoveVector:Add(eventPointer.delta * 5)
	self:SetVectorLength(self.accumulateMoveVector, self.MaxVectorLength)

	if self.MinVectorLength <= self.accumulateMoveVector.sqrMagnitude then
		self:SetSmoothMove(self.accumulateMoveVector)
	else
		self:ClearSmoothMove()
	end
end

function M:OnMouseMove(context)
	if self.isDragMove then
		return
	end

	if context.performed then
		self.accumulateMoveVector:Add(context:ReadValueVector2())
		self:SetVectorLength(self.accumulateMoveVector, self.MaxVectorLength)

		if self.MinVectorLength <= self.accumulateMoveVector.sqrMagnitude then
			self:SetSmoothMove(self.accumulateMoveVector)
		else
			self:ClearSmoothMove()
		end
	end
end

function M:OnStickMove(context)
	local value = context:ReadValueVector2()

	if context.performed then
		self:UpdateSmoothMoveVector()
		self:SetSmoothMove(value)
	elseif context.canceled then
		self:ClearSmoothMove()
	end
end

function M:SetVectorLength(vec, maxLength)
	local length = vec.sqrMagnitude

	if maxLength < length then
		vec:Mul(maxLength / length)
	end
end

function M:ClearSmoothMove()
	self.updateSelect = false
end

function M:SetSmoothMove(moveVector)
	self.updateSelect = true
	self.smoothStartVector.x = self.moveVector.x
	self.smoothStartVector.y = self.moveVector.y
	self.smoothStartTime = Time.unscaledTime
	self.smoothEndVector.x = moveVector.x
	self.smoothEndVector.y = moveVector.y
end

function M:UpdateSmoothMoveVector()
	if not self.updateSelect then
		return
	end

	if self.gamepadMode then
		local x, y = gCS.LuaUtils.Vector3Slerp(self.smoothStartVector.x, self.smoothStartVector.y, 0, self.smoothEndVector.x, self.smoothEndVector.y, 0, (Time.unscaledTime - self.smoothStartTime) / self.SMOOTH_TIME)
		self.moveVector.x = x
		self.moveVector.y = y

		if self.SMOOTH_TIME < Time.unscaledTime - self.smoothStartTime then
			self:ClearSmoothMove()
		end
	else
		self.moveVector.x = self.smoothEndVector.x
		self.moveVector.y = self.smoothEndVector.y

		self:ClearSmoothMove()
	end
end

function M:UpdateCircle()
	local index, angle = self:GetCirleSelect(self.moveVector)

	self:SetCircleSelect(index)

	self.bindData.arrowAngle = self.cicleInitHalfItemAngle - angle
end

function M:SetCircleSelect(index, force)
	if self.curSelectIndex ~= index or force then
		if self.curSelectIndex > 0 and self.skillList[self.curSelectIndex] then
			self.skillList[self.curSelectIndex].isFocus = false
		end

		if index > 0 and self.skillList[index] then
			self.skillList[index].isFocus = true
			self.bindData.skillText = self.skillList[index].Name
			self.bindData.skillDes = self.skillList[index].Des
		end

		self.curSelectIndex = index

		self.bindData.wheelList:RefreshList()
	end
end

function M:GetCirleSelect(moveVector)
	local angle = -Vector2.SignedAngle(self.cicleInitVector, moveVector)

	if angle < 0 then
		angle = angle + 360
	end

	local index = math.floor(angle / self.circleEachAngle) + 1

	if self.wheelItemCount < index then
		index = 1
	end

	return index, angle
end

function M:InitSkillCircle()
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
			canUse = self.progress >= cfg.Layer * PoliceConfig.ChargingValueEachLayer
		}
		local isUnlock = gSpiritJobManager:CheckCurSpiritContainBadge(cfg.BadgeId)

		if isUnlock or cfg.BadgeId == 0 then
			table.insert(self.skillList, view)
		end
	end

	self.bindData.wheelList:SetList(self.skillList)
end

function M:SetAddCount(eventId)
	self.countDonwHideCombo = 2.233
	self.bindData.isShowComb = 0
	local cfg = PoliceChargeEventConfig.GetConfig(eventId)
	self.bindData.addCount = "+" .. cfg.Charge or 0
	self.bindData.addCountText = cfg.Name or ""
end

function M:OnGamepadSkill(context)
	if context.performed and not self.pauseUUID then
		self:OnClickSkillBtn()
	end

	if context.canceled and self.pauseUUID then
		self:OnReleaseSkillBtn()
	end
end

function M:OnClickSkillBtn()
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	self.pauseUUID = gCS.PauseManager.Instance:SetGlobalPause(UX.Game.GamePauseReason.Guide, PoliceConfig.ChasingSkillPauseTimeScale, -1)
	self.curSelectIndex = 0
	self.bindData.isShowCircle = 1
end

function M:OnReleaseSkillBtn()
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
		if data.Id == PoliceChargingSkillConfig.EMP then
			self:DoEmpSkill(data)
		elseif data.Id == PoliceChargingSkillConfig.InfoInterference then
			self:DoInformationInterferenceSkill(data)
		elseif data.skillType == PoliceChargingSkillConfig.SkillTypeType.Client then
			gCS.BattleManager.UseSkillByPid(MyPlayerManager.PlayerUnit.Pid, data.SkillId)
		end

		gPoliceChaseManager:UsePoliceChargingProgress(data.Id, data.Id == 1)
		print("释放技能成功，name = " .. data.Name .. "  Id = " .. data.Id)
	else
		print("释放技能失败")
	end
end

function M:OnCloseSkillBtn()
	if self.pauseUUID then
		gCS.PauseManager.Instance:RemoveGlobalPause(self.pauseUUID)

		self.pauseUUID = nil
	end

	self.bindData.isShowCircle = 0

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end
end

function M:CarChaseProgressChange(eventId, data)
	if gPoliceChaseManager.chaseVehicleUId == nil then
		self.bindData.energyBarList:SetList({})

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

	self:SetChaseProgress()
end

function M:SetChaseProgress()
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

			if self.progress >= i * PoliceConfig.ChargingValueEachLayer then
				view.progress = 1
				showKey = true
			elseif self.progress < i * PoliceConfig.ChargingValueEachLayer and self.progress > (i - 1) * PoliceConfig.ChargingValueEachLayer then
				view.progress = self.progress % PoliceConfig.ChargingValueEachLayer / PoliceConfig.ChargingValueEachLayer
			else
				view.progress = 0
			end
		end

		self.bindData.energyBarList:SetList(self.energyBarList)
	end

	self.bindData.isShowKey = showKey and 0 or 1

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.isShowQte = showKey and 1 or 0
	end

	self:RefreshSkillCanUse()
end

function M:RefreshSkillCanUse()
	if self.skillList and #self.skillList > 0 then
		for i = 1, #self.skillList do
			if self.progress >= self.skillList[i].Layer * PoliceConfig.ChargingValueEachLayer then
				local id = self.skillList[i].Id

				if id == PoliceChargingSkillConfig.EMP then
					self.skillList[i].canUse = self.curEmpData == nil
				elseif id == PoliceChargingSkillConfig.InfoInterference then
					self.skillList[i].canUse = self.curInformationInterferenceData == nil
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

function M:OnRenderEnergyBarListItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("CarChaseEnergyBarTemplate"):GetStoreByWidget(btn)

	if store then
		local lastValue = data.lastProgress or 0
		local value = data.progress or 0

		if lastValue < value and value - lastValue > 0.1 then
			store.progress:ProgressToFxValue(value, 0.25)
			store.progress:ProgressToValue(value, 0.8, 0.5, DG.Tweening.Ease.InOutCirc)
		else
			store.progress:StopProgress()

			store.progress.value = value
			store.progress.fxValue = value
		end

		local active = lastValue < 1 and value >= 1

		if active then
			self.glowTimer[index] = {
				remainTime = 0.5
			}
			store.glowRoot.activation = true
		elseif not self.glowTimer[index] then
			store.glowRoot.activation = false
		end
	end
end

function M:UpdateGlowFx()
	local delete = nil

	for index, data in pairs(self.glowTimer) do
		data.remainTime = data.remainTime - Time.deltaTime

		if data.remainTime <= 0 then
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

function M:OnRenderSkillCircleListItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("CarChaseSkillCircleTemplate"):GetStoreByWidget(btn)

	if store then
		store.icon = data.Icon
		store.isFocus = data.isFocus and 0 or 1
		store.canUse = data.canUse and 0 or 1
		local layerNum = 0

		if data.Layer and data.Layer > 0 then
			layerNum = data.Layer
		end

		store.energyBarList:SetSimpleList(layerNum)
	end
end

function M:OnHoverSkillCircleList(btn, data)
	self.bindData.skillText = data.Name
	self.bindData.skillDes = data.Des
end

function M:DoEmpSkill(data)
	if not self.curEmpData and not self.updateEMP then
		self.curEmpData = data
		self.bindData.showTip = 1
		self.bindData.tipIsFail = 0
		self.bindData.tipType = 0
		self.updateEMP = true
		self.EMPTime = 0
		self.closeEMPTime = nil

		self:UpdateEmp()
	end
end

function M:UpdateEmp(baseVehicle, tempVehicle)
	if self.curEmpData and self.updateEMP then
		local canShowFocus = false
		baseVehicle = baseVehicle or gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle
		tempVehicle = tempVehicle or gDriveVehiclesManager.cs_manager:GetVehicle(gPoliceChaseManager.chaseVehicleUId)
		local targetTrans = nil

		if baseVehicle and tempVehicle then
			local playerTrans = baseVehicle.vehicleControl.VehicleGameObject.transform
			targetTrans = tempVehicle.VehicleGameObject.transform
			local forward = playerTrans.forward
			local dir = targetTrans.position - playerTrans.position
			local angle = Vector2.SignedAngle(Vector2.New(forward.x, forward.z), Vector2.New(dir.x, dir.z))

			if angle < 90 and angle > -90 then
				local dis = dir.magnitude
				canShowFocus = dis < self.curEmpData.distance
			end
		end

		self.EMPTime = self.EMPTime + Time.deltaTime

		if self.curEmpData.duration <= self.EMPTime then
			self.updateEMP = false
			local empData = self.curEmpData
			self.curEmpData = nil
			self.bindData.skillProgress = 0
			self.bindData.skillProgressText = "100%"
			local useSuccess = false

			if canShowFocus and empData.skillType == PoliceChargingSkillConfig.SkillTypeType.Client then
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

			self:RefreshSkillCanUse()
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

		if self.closeEMPTime < 0 then
			self.bindData.showTip = 0
			self.closeEMPTime = nil
		end
	end
end

function M:DoInformationInterferenceSkill(data)
	if not self.curInformationInterferenceData and not self.updateInformationInterference and (data.skillType ~= PoliceChargingSkillConfig.SkillTypeType.Client or gCS.BattleManager.UseSkillByPid(MyPlayerManager.PlayerUnit.Pid, data.SkillId)) then
		self.curInformationInterferenceData = data
		self.bindData.showTip = 1
		self.bindData.tipIsFail = 0
		self.bindData.tipType = 1
		self.updateInformationInterference = true
		self.informationInterferenceTime = 0

		self:UpdateInformationInterference()
	end
end

function M:UpdateInformationInterference()
	if self.curInformationInterferenceData and self.updateInformationInterference then
		self.informationInterferenceTime = self.informationInterferenceTime + Time.deltaTime

		if self.curInformationInterferenceData.duration <= self.informationInterferenceTime then
			self.bindData.showTip = 0
			self.updateInformationInterference = false
			self.curInformationInterferenceData = nil

			self:RefreshSkillCanUse()
		else
			local progress = self.informationInterferenceTime / self.curInformationInterferenceData.duration
			self.bindData.skillProgress = 1 - progress
			self.bindData.skillProgressText = tostring(math.floor(progress * 100)) .. "%"
		end
	end
end
