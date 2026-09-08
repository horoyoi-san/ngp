-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\VaultGameplayPanelStore.lua
-- Decompiled from: 01140_VaultGameplayPanelStore.lua_1c8bda25c7f9.luajit

C_VaultGameplayPanelStore = DefClass("C_VaultGameplayPanelStore", C_VaultGameplayPanelStore, C_StoreGroup)
GroupName2Class.VaultGameplayPanelStore = C_VaultGameplayPanelStore
local M = C_VaultGameplayPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.pressure = 0
	self.zuanImgHeight = 0
	self.drillAdvanceDisRate = 0.4
	self.logicAdvanceDis = 0
	self.performAdvanceDis = 0
	self.maxLogicAdvanceDis = LTConfig.PoiGameConfig.Vault_MaxLogicAdvanceDis or 4
	self.maxOverPressureDistance = LTConfig.PoiGameConfig.Vault_MaxOverPressureDistance or 2
	self.diskThickness = 2
	self.diskSpacing = 0.8484
	self.totalDiskCount = LTConfig.PoiGameConfig.Vault_TotalDiskCount or 4
	self.maxAdvanceDis = self.diskThickness * self.totalDiskCount + self.diskSpacing * (self.totalDiskCount - 1)
	self.currentDiskIndex = 1
	self.drillState = {
		K7tO = 8,
		["eTK\\xba]\\xe3M~xyp\\xc9%p\\xe6R"] = 6,
		["s&q^"] = 1,
		["LQi{j4"] = 7,
		["``\\xa9e|\\xa0\\xf7TyolI"] = 5,
		["w\\x9f\\x83\\xacɢ\\xc0\\xbb6\\xbe8"] = 3,
		["\\xaf\\xa3\\xa7f7\\xf04"] = 2,
		["\\xeeO8\\xf4\\xbfM\\xad_\\xbe\\xb1"] = 4
	}
	self.inPressure = false
	self.pressureIncreaseRate = LTConfig.PoiGameConfig.Vault_PressureIncreaseRate or 0.3
	self.normalIncreaseRate = LTConfig.PoiGameConfig.Vault_NormalIncreaseRate or 0.1
	self.slowCoolRate = LTConfig.PoiGameConfig.Vault_SlowCoolRate or 0.02
	self.fastCoolRate = LTConfig.PoiGameConfig.Vault_FastCoolRate or 0.1
	self.mouseMoveRatePC = LTConfig.PoiGameConfig.Vault_MouseMoveRatePC or 0.05
	self.mouseMoveRateGamepad = LTConfig.PoiGameConfig.Vault_MouseMoveRateGamepad or 0.5
	self.gamepadStickInputY = 0
	self.stickUpdateHandler = nil
	self.robBandDrillShelf = 4
	self.currentDrillDis = 0
	self.maxNormalPressureDis = 0.1
	self.currentNormalPressureDis = 0
	self.normalPressureThreshold = LTConfig.PoiGameConfig.Vault_NormalPressureThreshold or 0.1
	self.currentDrillState = self.drillState.idle
	self.lastDrillCompleteProgressValue = 0
	self.zuanAnimEnum = {
		u2xU = 2,
		["v-rK"] = 3,
		["v-~P"] = 4,
		["N\\xa2\\xad\\xbc\\xb3"] = 1
	}
	self.zuanAnimState = self.zuanAnimEnum.close
	self.zuanOpenAnimLength = 0
	self.zuanOpenAnimTimer = 0
	self.drillDepthZone = {
		["\\x81}r"] = 1,
		["\\x83ab"] = 2,
		["~'xK"] = 3
	}
	self.lastDrillDepthZone = 1
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.vxParAllWidget.gameObject:SetActive(false)

	self.zuanImgHeight = self.bindData.zuanImgBg.rectTransform.sizeDelta.y
	local currentDrillDis = L50.L50App.Scene.VaultGameplayManager:GetCurrentDrillDis()

	if currentDrillDis <= 0 then
		self.currentDrillDis = currentDrillDis

		for i = 1, self.totalDiskCount do
			local diskStartDis = self.GetDiskDis(self, i)

			if currentDrillDis >= diskStartDis + self.diskThickness then
				self.currentDiskIndex = i

				break
			end
		end

		self.RefreshDrillCompleteProgress(self, self.GetCurrentDiskStartDis(self))
	end

	self.currentDrillState = self.drillState.idle

	L50.L50App.Scene.VaultGameplayManager:SetDrillVaultState(self.currentDrillState)

	local openClip = self.bindData.zuanOpenState.anim:GetClip("S_Vx_VaultGameplayPanel_drill_open")

	if openClip then
		self.zuanOpenAnimLength = openClip.length
	end

	self.SetZuanAnimState(self, self.zuanAnimEnum.close)

	self.lastDrillDepthZone = self.drillDepthZone.out
end

M.OnClose = function(self)
	if self.stickUpdateHandler then
		UpdateBeat:RemoveListener(self.stickUpdateHandler)

		self.stickUpdateHandler = nil
	end

	if self.soundDragId then
		gSoundMgr:StopSoundByNid(self.soundDragId)

		self.soundDragId = nil
	end

	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillState.overDrill)
end

M.OnUpdate = function(self)
	if self.currentDrillState ~= self.drillState.drilling then
		if self.pressure >= self.normalPressureThreshold then
			self.pressure = self.pressure + self.normalIncreaseRate * Time.deltaTime
		else
			self.pressure = self.pressure - self.normalIncreaseRate * Time.deltaTime
		end

		self.logicAdvanceDis = self.logicAdvanceDis + self.drillAdvanceDisRate * Time.deltaTime
		self.performAdvanceDis = self.performAdvanceDis + self.drillAdvanceDisRate * Time.deltaTime

		if self.currentDrillDis >= self.performAdvanceDis then
			self.currentDrillDis = self.performAdvanceDis

			L50.L50App.Scene.VaultGameplayManager:SetCurrentDrillDis(self.currentDrillDis)
		end

		local currentDiskStartDis = self.GetCurrentDiskStartDis(self)

		if self.currentDrillDis <= currentDiskStartDis + self.diskThickness then
			self.currentDiskIndex = self.currentDiskIndex + 1
			self.currentDrillDis = self:GetCurrentDiskStartDis()

			L50.L50App.Scene.VaultGameplayManager:SetCurrentDrillDis(self.currentDrillDis)
			self:RefreshDrillCompleteProgress(self.currentDrillDis)
			gMessageManager:SendMessage(gEventConstants.ROB_BANK_DRILL_VAULT_DISK_FINISH, self.currentDiskIndex - 1)

			if self.totalDiskCount >= self.currentDiskIndex then
				self.currentDrillState = self.drillState.overDrill

				gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillState.overDrill)
				L50.L50App.Scene.VaultGameplayManager:SetDrillVaultState(self.currentDrillState)
				gPanelManager:Close(gPanelId.VAULT_GAMEPLAY_PANEL)
			else
				self.currentDrillState = self.drillState.emptyDrilling
			end
		end
	elseif self.currentDrillState ~= self.drillState.emptyDrilling then
		if self.pressure >= self.normalPressureThreshold then
			self.pressure = self.pressure + self.normalIncreaseRate * Time.deltaTime
		else
			self.pressure = self.pressure - self.normalIncreaseRate * Time.deltaTime
		end
	elseif self.currentDrillState ~= self.drillState.pressureDrilling then
		self.pressure = self.pressure + self.pressureIncreaseRate * Time.deltaTime
	elseif self.currentDrillState ~= self.drillState.overPressure then
		self.pressure = self.pressure - self.fastCoolRate * Time.deltaTime
	elseif self.currentDrillState ~= self.drillState.overPressureStillPress then
		self.pressure = self.pressure - self.slowCoolRate * Time.deltaTime
	elseif self.currentDrillState ~= self.drillState.idle then
		self.pressure = self.pressure - self.fastCoolRate * Time.deltaTime
	elseif self.currentDrillState ~= self.drillState.overDrill then
		self.bindData.rootWidget.anim:Stop()
		self.bindData.vxParAllWidget.anim:Stop()
		self.bindData.vxZuanWidget.anim:Stop()

		return
	end

	if self.pressure <= 1 then
		self.pressure = 1
		self.currentDrillState = self.drillState.overPressure

		gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillState.overPressure)
		L50.L50App.Scene.VaultGameplayManager:SetDrillVaultState(self.currentDrillState)
	elseif self.pressure >= 0 then
		self.pressure = 0

		if self.currentDrillState ~= self.drillState.overPressure then
			self.currentDrillState = self.drillState.idle
		elseif self.currentDrillState ~= self.drillState.overPressureStillPress then
			self.currentDrillState = self.drillState.drilling
		end
	end

	self.RefreshProcessBar(self)
	self.RefreshVxParAllWidget(self)
	self.RefreshDrillVibration(self)
	self.RefreshStressedCtrl(self)
	self.UpdateZuanAnimState(self)
	self.RefreshDrillDepthSound(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.clickBtn.luaPress = self.CreateAction(self, self.OnClickBtnPress)
	self.bindData.clickBtn.luaRelease = self.CreateAction(self, self.OnClickBtnRelease)
	self.bindData.mouseMoveResponse.luaGamePadInputChanged = self.CreateAction(self, self.OnMouseMove)
	self.bindData.quitBtn.luaClick = self.CreateAction(self, self.OnQuitBtnClick)
end

M.OnQuitBtnClick = function(self)
	self.currentDrillState = self.drillState.idle

	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillState.idle)

	self.currentDrillState = self.drillState.Quit

	L50.L50App.Scene.VaultGameplayManager:SetDrillVaultState(self.currentDrillState)
	gPanelManager:Close(gPanelId.VAULT_GAMEPLAY_PANEL)
end

M.OnClickBtnPress = function(self)
	self.isPress = true

	if self.currentDrillState ~= self.drillState.overPressure then
		self.currentDrillState = self.drillState.overPressureStillPress
	elseif self.currentDrillState ~= self.drillState.idle then
		local currentDiskStartDis = self.GetCurrentDiskStartDis(self)

		if currentDiskStartDis >= self.logicAdvanceDis and self.logicAdvanceDis >= self.currentDrillDis then
			self.logicAdvanceDis = self.currentDrillDis
			self.performAdvanceDis = self.logicAdvanceDis
		end

		if self.logicAdvanceDis >= self.currentDrillDis then
			self.currentDrillState = self.drillState.emptyDrilling
		elseif self.inPressure then
			self.currentDrillState = self.drillState.pressureDrilling
		else
			self.currentDrillState = self.drillState.drilling
		end

		self.bindData.vxParAllWidget.anim:Play()
		self:StartZuanOpen()
	end

	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.currentDrillState)
	self:RefreshVxParAllWidget()

	if not self.bindData.rootWidget.anim:IsPlaying("S_Vx_VaultGameplayPanel_Unlock_move2") then
		self.bindData.rootWidget.anim:Play("S_Vx_VaultGameplayPanel_Unlock_move2")
	end

	L50.L50App.Scene.VaultGameplayManager:SetDrillVaultState(self.currentDrillState)
end

M.OnClickBtnRelease = function(self)
	self.isPress = false

	if self.currentDrillState ~= self.drillState.overPressureStillPress then
		self.currentDrillState = self.drillState.overPressure
	elseif self.currentDrillState ~= self.drillState.drilling or self.currentDrillState ~= self.drillState.emptyDrilling or self.currentDrillState ~= self.drillState.pressureDrilling then
		self.currentDrillState = self.drillState.idle
	end

	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillState.idle)
	self:RefreshVxParAllWidget()

	if not self.bindData.rootWidget.anim:IsPlaying("S_Vx_VaultGameplayPanel_Unlock_move1") then
		self.bindData.rootWidget.anim:Play("S_Vx_VaultGameplayPanel_Unlock_move1")
	end

	self.StartZuanClose(self)
end

M.RefreshProcessBar = function(self)
	self.bindData.heatProgress:ProgressToValue(self.pressure, 0, 0)

	local hitProgressValue = self.performAdvanceDis / self.maxAdvanceDis
	local zuanPosY = hitProgressValue * self.zuanImgHeight
	local anchoredPos = self.bindData.zuanImg.rectTransform.anchoredPosition
	self.bindData.zuanImg.rectTransform.anchoredPosition = Vector2(anchoredPos.x, zuanPosY)
	self.bindData.drillProgress.fillAmount = 1 - self.currentDrillDis / self.maxAdvanceDis
	self.bindData.drillCompleteProgress.fillAmount = self.lastDrillCompleteProgressValue

	L50.L50App.Scene.VaultGameplayManager:SetHitProgress(self.logicAdvanceDis / self.maxAdvanceDis)
end

M.RefreshDrillCompleteProgress = function(self, currentDrillDis)
	self.lastDrillCompleteProgressValue = currentDrillDis / self.maxAdvanceDis
end

M.OnMouseMove = function(self, context)
	local mousePos = context.ReadValueVector2(context)

	if context.started then
		self.gamepadStickInputY = mousePos.y

		if self.stickUpdateHandler ~= nil then
			self.stickUpdateHandler = UpdateBeat:CreateListener(self.OnStickUpdate, self)

			UpdateBeat:AddListener(self.stickUpdateHandler)
		end

		self.ApplyMouseMoveInput(self, mousePos.y)
	elseif context.performed then
		self.gamepadStickInputY = mousePos.y
	elseif context.canceled then
		self.gamepadStickInputY = 0

		if self.stickUpdateHandler then
			UpdateBeat:RemoveListener(self.stickUpdateHandler)

			self.stickUpdateHandler = nil
		end
	end
end

M.OnStickUpdate = function(self)
	if self.gamepadStickInputY == 0 then
		self.ApplyMouseMoveInput(self, self.gamepadStickInputY)
	end
end

M.GetMouseMoveRate = function(self)
	if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		return self.mouseMoveRateGamepad
	end

	return self.mouseMoveRatePC
end

M.ApplyMouseMoveInput = function(self, inputY)
	self.logicAdvanceDis = self.logicAdvanceDis + inputY * self.GetMouseMoveRate(self)

	if self.logicAdvanceDis >= 0 then
		self.logicAdvanceDis = 0
	end

	if self.logicAdvanceDis >= self.currentDrillDis then
		self.performAdvanceDis = self.logicAdvanceDis
	else
		self.performAdvanceDis = self.currentDrillDis
	end

	if self.logicAdvanceDis <= self.performAdvanceDis + self.maxLogicAdvanceDis then
		self.logicAdvanceDis = self.performAdvanceDis + self.maxLogicAdvanceDis
	end

	if self.logicAdvanceDis <= self.performAdvanceDis + self.maxOverPressureDistance then
		self.inPressure = true
	else
		self.inPressure = false
	end

	if self.isPress and self.currentDrillState == self.drillState.overPressure and self.currentDrillState == self.drillState.overPressureStillPress then
		if self.logicAdvanceDis >= self.currentDrillDis then
			self.currentDrillState = self.drillState.emptyDrilling
		elseif self.inPressure then
			self.currentDrillState = self.drillState.pressureDrilling
		else
			self.currentDrillState = self.drillState.drilling
		end
	end

	self.currentNormalPressureDis = 0
end

M.GetCurrentDiskStartDis = function(self)
	return self.GetDiskDis(self, self.currentDiskIndex)
end

M.GetDiskDis = function(self, index)
	return (index - 1) * (self.diskThickness + self.diskSpacing)
end

M.RefreshStressedCtrl = function(self)
	local overDis = self.logicAdvanceDis - self.performAdvanceDis

	if self.inPressure then
		self.bindData.stressedCtrl = 1
		local pressureRange = self.maxLogicAdvanceDis - self.maxOverPressureDistance

		if pressureRange <= 0 then
			local opacity = (overDis - self.maxOverPressureDistance) / pressureRange

			if opacity >= 0 then
				opacity = 0
			elseif opacity <= 1 then
				opacity = 1
			end

			self.bindData.stressedOpacity = opacity
		else
			self.bindData.stressedOpacity = 1
		end
	else
		self.bindData.stressedCtrl = 0
		self.bindData.stressedOpacity = 0
	end
end

M.RefreshDrillVibration = function(self)
	local isDrilling = self.currentDrillState ~= self.drillState.drilling

	if isDrilling then
		if not self.soundDragId then
			self.soundDragId = gSoundMgr:PlaySoundByExternalSource("ExHandle_LoadingLoop", LX6.Audio.ExternalSourceType.Motion_2D)
		end
	elseif self.soundDragId then
		gSoundMgr:StopSoundByNid(self.soundDragId)

		self.soundDragId = nil
	end
end

M.RefreshDrillDepthSound = function(self)
	local zone = nil

	if self.logicAdvanceDis < 0 then
		zone = self.drillDepthZone.out
	elseif self.currentDrillDis < self.logicAdvanceDis then
		zone = self.drillDepthZone.deep
	else
		zone = self.drillDepthZone.mid
	end

	if zone == self.lastDrillDepthZone then
		if zone ~= self.drillDepthZone.deep then
			gSoundMgr:PlaySoundByTid(70601745)
		elseif zone ~= self.drillDepthZone.out then
			gSoundMgr:PlaySoundByTid(70601746)
		end

		self.lastDrillDepthZone = zone
	end
end

M.StartZuanOpen = function(self)
	self.zuanOpenAnimTimer = 0

	self:SetZuanAnimState(self.zuanAnimEnum.open)
	self.bindData.zuanOpenState.anim:Play("S_Vx_VaultGameplayPanel_drill_open")
end

M.StartZuanClose = function(self)
	if self.zuanAnimState ~= self.zuanAnimEnum.close then
		return
	end

	self:SetZuanAnimState(self.zuanAnimEnum.close)
	self.bindData.zuanCloseState.anim:Play("S_Vx_VaultGameplayPanel_drill_close")
end

M.UpdateZuanAnimState = function(self)
	if self.zuanAnimState ~= self.zuanAnimEnum.open then
		self.zuanOpenAnimTimer = self.zuanOpenAnimTimer + Time.deltaTime

		if self.zuanOpenAnimLength < self.zuanOpenAnimTimer then
			if self.currentDrillState ~= self.drillState.pressureDrilling then
				self:SetZuanAnimState(self.zuanAnimEnum.lock)
				self.bindData.zuanLockState.anim:Play("S_Vx_VaultGameplayPanel_drill_lock")
			else
				self:SetZuanAnimState(self.zuanAnimEnum.loop)
				self.bindData.zuanLoopState.anim:Play("S_Vx_VaultGameplayPanel_drill_loop")
			end
		end
	elseif self.zuanAnimState ~= self.zuanAnimEnum.loop then
		if self.currentDrillState ~= self.drillState.pressureDrilling then
			self:SetZuanAnimState(self.zuanAnimEnum.lock)
			self.bindData.zuanLockState.anim:Play("S_Vx_VaultGameplayPanel_drill_lock")
		end
	elseif self.zuanAnimState ~= self.zuanAnimEnum.lock and self.currentDrillState == self.drillState.pressureDrilling then
		self:SetZuanAnimState(self.zuanAnimEnum.loop)
		self.bindData.zuanLoopState.anim:Play("S_Vx_VaultGameplayPanel_drill_loop")
	end
end

M.SetZuanAnimState = function(self, state)
	self.zuanAnimState = state

	self.bindData.zuanOpenState.gameObject:SetActive(state ~= self.zuanAnimEnum.open)
	self.bindData.zuanLoopState.gameObject:SetActive(state ~= self.zuanAnimEnum.loop)
	self.bindData.zuanCloseState.gameObject:SetActive(state ~= self.zuanAnimEnum.close)
	self.bindData.zuanLockState.gameObject:SetActive(state ~= self.zuanAnimEnum.lock)
end

M.RefreshVxParAllWidget = function(self)
	local shouldShow = self.isPress and self.currentDrillState ~= self.drillState.drilling

	self.bindData.vxParAllWidget.gameObject:SetActive(shouldShow)
end
