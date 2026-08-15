local DragEventListener = SGUI.EventSystems.DragEventListener
local GameConfig = LTConfig.GameConfig
local ParkourStateConfig = LTConfig.ParkourStateConfig
local HudDescConfig = LTConfig.HudDescConfig
C_UniqueSkillDiLaStore = DefClass("C_UniqueSkillDiLaStore", C_UniqueSkillDiLaStore, C_StoreGroup)
GroupName2Class.UniqueSkillDiLaStore = C_UniqueSkillDiLaStore
local M = C_UniqueSkillDiLaStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.dragButtons = {
		"downBtn",
		"upBtn",
		"landBtn"
	}
	self.floatFlightBtnNames = {
		"floatDownBtn",
		"floatUpBtn",
		"floatLandBtn"
	}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

function M:OnStart()
	self:InitData()
	self:OnRefreshFloatFlightBtn(gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.FloatFlight))
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end

function M:InitData()
	self:BindBtnEvent()
	self:RegisterBtnAction()
	self:InitBtnStore()
end

function M:InitBtnStore()
	self.floatDownBtn = self:GetStoreByWidget(self.bindData.floatDownBtn)
	self.floatDownBtn.btnId = HudDescConfig.DOWN_BTN
	self.floatUpBtn = self:GetStoreByWidget(self.bindData.floatUpBtn)
	self.floatUpBtn.btnId = HudDescConfig.UP_BTN
	self.floatLandBtn = self:GetStoreByWidget(self.bindData.floatLandBtn)
	self.floatLandBtn.btnId = HudDescConfig.LAND_BTN
end

function M:BindBtnEvent()
	self.bindData.floatDownBtn.luaBeginLongPress = self:CreateAction("OnDownBtnBeginLongPress")
	self.bindData.floatDownBtn.luaLongPress = self:CreateAction("OnDownBtnLongPress")
	self.bindData.floatDownBtn.luaEndLongPress = self:CreateAction("OnDownBtnEndLongPress")
	self.bindData.floatUpBtn.luaBeginLongPress = self:CreateAction("OnUpBtnBeginLongPress")
	self.bindData.floatUpBtn.luaLongPress = self:CreateAction("OnUpBtnLongPress")
	self.bindData.floatUpBtn.luaEndLongPress = self:CreateAction("OnUpBtnEndLongPress")
	self.bindData.floatLandBtn.luaBeginLongPress = self:CreateAction("OnLandBtnBeginLongPress")
	self.bindData.floatLandBtn.luaEndLongPress = self:CreateAction("OnLandBtnEndLongPress")

	for _, btn in ipairs(self.dragButtons) do
		local btn = self.bindData[btn]

		if btn then
			local dragListener = DragEventListener.Get(btn.gameObject)
			dragListener.onDrag = self:CreateAction("OnDragBtnDraging")
		end
	end
end

function M:RegisterBtnAction()
	return
end

function M:OnDownBtnBeginLongPress()
	gCoreHudImgManager:PlaySkillBtnDownFanseAni(self.floatDownBtn)

	if gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.FloatFlight) then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FallPress)

		return true
	end
end

function M:OnDownBtnLongPress()
	return
end

function M:OnDownBtnEndLongPress()
	gCoreHudImgManager:PlaySkillBtnUpFanseAni(self.floatDownBtn)

	if gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.FloatFlight) then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FallRelease)

		return true
	end
end

function M:OnUpBtnBeginLongPress()
	gCoreHudImgManager:PlaySkillBtnDownFanseAni(self.floatUpBtn)

	if gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.FloatFlight) then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.RisePress)

		return true
	end
end

function M:OnUpBtnLongPress()
	return
end

function M:OnUpBtnEndLongPress()
	gCoreHudImgManager:PlaySkillBtnUpFanseAni(self.floatUpBtn)

	if gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.FloatFlight) then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.RiseRelease)

		return true
	end
end

function M:OnLandBtnBeginLongPress()
	gCoreHudImgManager:PlaySkillBtnDownFanseAni(self.floatLandBtn)
	gCS.MindPowerMgr:TryThrowEarPhone()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.Land)
end

function M:OnLandBtnEndLongPress()
	gCoreHudImgManager:PlaySkillBtnUpFanseAni(self.floatLandBtn)
end

function M:OnDragBtnDraging(eventPointer)
	if not eventPointer.delta then
		return
	end

	self:OnDragButton(eventPointer.delta)
end

function M:OnDragButton(delta)
	local camRotateX = GameConfig.FreeLookRotateXDefaultSensitivity
	local camRotateY = GameConfig.FreeLookRotateYDefaultSensitivity
	local deltaX = delta.x * (1 + (camRotateX - 1) / 8 * 6) * 0.5
	local deltaY = delta.y * (1 + (camRotateY - 1) / 8 * 6) * 0.5
	local minDeltaInput = GameConfig.SwingJoystickMinInput

	if Mathf.Abs(deltaX) < minDeltaInput.X then
		deltaX = 0
	end

	if Mathf.Abs(deltaY) < minDeltaInput.Y then
		deltaY = 0
	end

	if deltaX ~= 0 or deltaY ~= 0 then
		local dir = Vector2.New(deltaX, deltaY)

		gCS.CameraDataMgr.cameraControllerManager:OnControlCameraAngle(dir)
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PAOKU_STATE_ADD_REMOVE] = self:CreateAction("OnParkourAddRemove")
	}
end

function M:RegisterWidget()
	return
end

function M:OnParkourAddRemove(eventId, data)
	if not data or data.parkourStateId ~= ParkourStateConfig.FloatFlight then
		return
	end

	self:OnRefreshFloatFlightBtn(data.isAdd)
end

function M:OnRefreshFloatFlightBtn(canFloatFlight)
	for i = 1, #self.floatFlightBtnNames do
		local curBtnName = self.floatFlightBtnNames[i]

		if self[curBtnName] and self.bindData[curBtnName] then
			self:SetBtnControl(self[curBtnName], canFloatFlight, canFloatFlight)
			self.bindData[curBtnName]:SetPCKeyTipShowTip(canFloatFlight)
		end

		if self.bindData.gamePadArea then
			self.bindData.gamePadArea:SetButtonInfoTipShowTip(canFloatFlight, i - 1)
		end
	end
end

function M:SetBtnVisible(btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

function M:SetBtnInteractable(btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

function M:SetBtnControl(btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end
