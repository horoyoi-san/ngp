local DragEventListener = SGUI.EventSystems.DragEventListener
C_CoreHudDriveBattleStore = DefClass("C_CoreHudDriveBattleStore", C_CoreHudDriveBattleStore, C_StoreGroup)
GroupName2Class.CoreHudDriveBattleStore = C_CoreHudDriveBattleStore
local M = C_CoreHudDriveBattleStore

function M:ctor()
	self.DEFINE_DynamicOnUpdate = true
end

function M:OnAwake()
	self.started = false
end

function M:OnGroupEnable()
	self:InitSkillBtns()
end

function M:OnShow(panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.IsMainDrive = IsMainDrive
	self.IsPhoneMode = IsPhoneMode

	if self.started then
		self:RefreshButtonState()
	end

	self:ShowNormalAttackBtn(true)
end

function M:OnStart()
	self.started = true

	self:RefreshButtonState()
end

function M:OnUpdate()
	gMainMenuMgr:ModifyCameraColorModulation()
end

function M:OnClose()
	self:ShowNormalAttackBtn(false)
end

function M:OnDestroy()
	self.started = nil
end

function M:EnterPhoneMode()
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = true

	self:RefreshButtonState()
end

function M:ExitPhoneMode()
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = false

	self:RefreshButtonState()
end

function M:ResetData()
	return
end

function M:InitSkillBtns()
	self.normalAttackBtnStore = self:GetStoreByWidget(self.bindData.normalAttackBtn)
	self.leftShootBtnStore = self:GetStoreByWidget(self.bindData.leftShootBtn)

	self:InitVehicleUnitAttackBtns()

	self.bindData.normalAttackBtn.luaPress = self:CreateActionWithArgs("OnNormalAttackBtnDown", 1)
	self.bindData.normalAttackBtn.luaRelease = self:CreateActionWithArgs("OnNormalAttackBtnUp", 1)
	self.bindData.normalAttackBtn.luaClick = self:CreateActionWithArgs("OnNormalAttackBtnClick", 1)
	self.bindData.normalAttackBtn.luaBeginLongPress = self:CreateActionWithArgs("OnNormalAttackBtnLongPressBegin", 1)
	self.bindData.normalAttackBtn.luaLongPress = self:CreateActionWithArgs("OnNormalAttackBtnLongPress", 1)
	self.bindData.normalAttackBtn.luaEndLongPress = self:CreateActionWithArgs("OnNormalAttackBtnLongPressEnd", 1)
	self.bindData.leftShootBtn.luaPress = self:CreateActionWithArgs("OnNormalAttackBtnDown", 1)
	self.bindData.leftShootBtn.luaRelease = self:CreateActionWithArgs("OnNormalAttackBtnUp", 1)
	self.bindData.leftShootBtn.luaClick = self:CreateActionWithArgs("OnNormalAttackBtnClick", 1)
	self.bindData.leftShootBtn.luaBeginLongPress = self:CreateActionWithArgs("OnNormalAttackBtnLongPressBegin", 1)
	self.bindData.leftShootBtn.luaLongPress = self:CreateActionWithArgs("OnNormalAttackBtnLongPress", 1)
	self.bindData.leftShootBtn.luaEndLongPress = self:CreateActionWithArgs("OnNormalAttackBtnLongPressEnd", 1)

	if self.bindData.mouseRight then
		self.mouseRightStore = self:GetStoreByWidget(self.bindData.mouseRight)
		self.bindData.mouseRight.luaPress = self:CreateAction("OnMouseRightBtnDown")
		self.bindData.mouseRight.luaRelease = self:CreateAction("OnMouseRightBtnUp")
	end

	local normalAttackBtnDrag = DragEventListener.Get(self.bindData.normalAttackBtn.gameObject)
	normalAttackBtnDrag.onBeginDrag = self:CreateActionWithArgs("OnNormalAttackBtnDragBegin", 1)
	normalAttackBtnDrag.onDrag = self:CreateActionWithArgs("OnNormalAttackBtnDrag", 1)
	normalAttackBtnDrag.onEndDrag = self:CreateActionWithArgs("OnNormalAttackBtnDragEnd", 1)
	local leftShootBtnDrag = DragEventListener.Get(self.bindData.leftShootBtn.gameObject)
	leftShootBtnDrag.onBeginDrag = self:CreateActionWithArgs("OnNormalAttackBtnDragBegin", 1)
	leftShootBtnDrag.onDrag = self:CreateActionWithArgs("OnNormalAttackBtnDrag", 1)
	leftShootBtnDrag.onEndDrag = self:CreateActionWithArgs("OnNormalAttackBtnDragEnd", 1)

	self:ResetData()
end

function M:ShowNormalAttackBtn(enable)
	local showBtn = enable and not gCS.LuaUtils.IsNonMobileAdaptive()

	if not self.normalAttackBtnStore or not self.leftShootBtnStore then
		self:InitSkillBtns()
	end

	self.bindData.normalAttackBtn.interactable = enable

	self.bindData.normalAttackBtn:SetActive(enable)

	self.normalAttackBtnStore.btnHideCtrl = showBtn and 0 or 1
	self.bindData.leftShootBtn.interactable = enable

	self.bindData.leftShootBtn:SetActive(enable)

	self.leftShootBtnStore.btnHideCtrl = showBtn and 0 or 1

	if self.bindData.mouseRight then
		local showMouseRight = showBtn
		self.bindData.mouseRight.interactable = enable

		self.bindData.mouseRight:SetActive(enable)

		self.mouseRightStore.btnHideCtrl = showMouseRight and 0 or 1
	end

	gMainMenuMgr:RefreshFullScreenLowHpAni(nil, true)
end

function M:OnNormalAttackBtnDown()
	self:OnNormalAttackBtnLongPressBegin()
end

function M:OnNormalAttackBtnUp()
	self:OnNormalAttackBtnLongPressEnd()
end

function M:OnNormalAttackBtnClick()
	gBattleMgr.characterControlPanel:OnMergeBtnClick(gBattleMgr.SkillBtnType.Normal)
end

function M:OnNormalAttackBtnLongPressBegin()
	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if gCS.ShootModule.GetVehicleShootState(csUnit) == LX6.Units.Module.ShootModule.VehicleShootState.None then
		return
	end

	if gCS.ShootModule.GetIsInVehicleForwardShootState(csUnit) then
		gBattleMgr.characterControlPanel:OnMergeBtnLongPressBegin(gBattleMgr.SkillBtnType.Normal)
	end

	if gCS.ShootModule.GetIsInVehicleShootState(csUnit) then
		gBattleMgr.characterControlPanel:OnMergeBtnLongPressBegin(gBattleMgr.SkillBtnType.Normal)
	end
end

function M:OnNormalAttackBtnLongPress()
	gBattleMgr.characterControlPanel:OnMergeBtnLongPress(gBattleMgr.SkillBtnType.Normal)
end

function M:OnNormalAttackBtnLongPressEnd()
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressEnd(gBattleMgr.SkillBtnType.Normal)
end

function M:OnNormalAttackBtnDragBegin(index, eventPointer)
	gBattleMgr.characterControlPanel:OnMergeBtnDragBegin(index, eventPointer)
end

function M:OnNormalAttackBtnDrag(index, eventPointer)
	gBattleMgr.characterControlPanel:OnMergeBtnDrag(index, eventPointer)
end

function M:OnNormalAttackBtnDragEnd(index, eventPointer)
	gBattleMgr.characterControlPanel:OnMergeBtnDragEnd(index, eventPointer)
end

function M:OnMouseRightBtnDown()
	local csUnit = gCS.MyPlayerManager.PlayerUnit
	local vehicleShootState = gCS.ShootModule.GetVehicleShootState(csUnit)

	if vehicleShootState == LX6.Units.Module.ShootModule.VehicleShootState.None then
		return
	end

	gBattleMgr.characterControlPanel:OnMergeBtnLongPressBegin(gBattleMgr.SkillBtnType.HeavyAttack)
end

function M:OnMouseRightBtnUp()
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressEnd(gBattleMgr.SkillBtnType.HeavyAttack)
end

function M:SetRightBtnStatus(down)
	if self.mouseRightStore then
		self.mouseRightStore.btnStatusCtrl = down and 1 or 0
	end
end

function M:InitVehicleUnitAttackBtns()
	self.vehicleNormalAttackBtnStore = self:GetStoreByWidget(self.bindData.vehicleNormalAttackBtn)
	self.vehicleActiveAttackBtnStore = self:GetStoreByWidget(self.bindData.vehicleActiveAttackBtn)
	self.bindData.vehicleNormalAttackBtn.luaPress = self:CreateActionWithArgs("OnVehicleNormalAttackBtnDown", 1)
	self.bindData.vehicleNormalAttackBtn.luaRelease = self:CreateActionWithArgs("OnVehicleNormalAttackBtnUp", 1)
	self.bindData.vehicleNormalAttackBtn.luaClick = self:CreateActionWithArgs("OnVehicleNormalAttackBtnClick", 1)
	self.bindData.vehicleNormalAttackBtn.luaBeginLongPress = self:CreateActionWithArgs("OnVehicleNormalAttackBtnLongPressBegin", 1)
	self.bindData.vehicleNormalAttackBtn.luaLongPress = self:CreateActionWithArgs("OnVehicleNormalAttackBtnLongPress", 1)
	self.bindData.vehicleNormalAttackBtn.luaEndLongPress = self:CreateActionWithArgs("OnVehicleNormalAttackBtnLongPressEnd", 1)
	self.bindData.vehicleActiveAttackBtn.luaPress = self:CreateActionWithArgs("OnVehicleActiveAttackBtnDown", 2)
	self.bindData.vehicleActiveAttackBtn.luaRelease = self:CreateActionWithArgs("OnVehicleActiveAttackBtnUp", 2)
	self.bindData.vehicleActiveAttackBtn.luaClick = self:CreateActionWithArgs("OnVehicleActiveAttackBtnClick", 2)
	self.bindData.vehicleActiveAttackBtn.luaBeginLongPress = self:CreateActionWithArgs("OnVehicleActiveAttackBtnLongPressBegin", 2)
	self.bindData.vehicleActiveAttackBtn.luaLongPress = self:CreateActionWithArgs("OnVehicleActiveAttackBtnLongPress", 2)
	self.bindData.vehicleActiveAttackBtn.luaEndLongPress = self:CreateActionWithArgs("OnVehicleActiveAttackBtnLongPressEnd", 2)
end

function M:ShowVehicleUnitAttackBtns(enable)
	self:SetBtnVisible(self.vehicleNormalAttackBtnStore, enable)
	self:SetBtnVisible(self.vehicleActiveAttackBtnStore, enable)
end

function M:SetShowVehicleUnitAttackBtns(enable)
	self.showVehicleAttackBtnDefault = enable
end

function M:OnVehicleNormalAttackBtnDown(data)
	self:OnVehicleNormalAttackBtnLongPressBegin(data)
end

function M:OnVehicleNormalAttackBtnUp(data)
	self:OnVehicleNormalAttackBtnLongPressEnd(data)
end

function M:OnVehicleNormalAttackBtnClick(data)
	gBattleMgr.characterControlPanel:OnMergeBtnClick(data)
end

function M:OnVehicleNormalAttackBtnLongPressBegin(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressBegin(data)
end

function M:OnVehicleNormalAttackBtnLongPress(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPress(data)
end

function M:OnVehicleNormalAttackBtnLongPressEnd(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressEnd(data)
end

function M:OnVehicleActiveAttackBtnDown(data)
	self:OnVehicleActiveAttackBtnLongPressBegin(data)
end

function M:OnVehicleActiveAttackBtnUp(data)
	self:OnVehicleActiveAttackBtnLongPressEnd(data)
end

function M:OnVehicleActiveAttackBtnClick(data)
	gBattleMgr.characterControlPanel:OnMergeBtnClick(data)
end

function M:OnVehicleActiveAttackBtnLongPressBegin(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressBegin(data)
end

function M:OnVehicleActiveAttackBtnLongPress(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPress(data)
end

function M:OnVehicleActiveAttackBtnLongPressEnd(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressEnd(data)
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

function M:SetBtnActive(btn, active)
	btn:SetActive(active)
end

function M:RefreshButtonState()
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local goRiderShootActive = gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.GoRiding)
	local csUnit = gCS.MyPlayerManager.PlayerUnit
	local vehicleShootActive = gCS.ShootModule.GetIsInVehicleShootState(csUnit)
	local vehicleForwardShootActive = gCS.ShootModule.GetIsInVehicleForwardShootState(csUnit)

	self:SetBtnActive(self.bindData.normalAttackBtn, vehicleShootActive or vehicleForwardShootActive)
	self:SetBtnActive(self.bindData.leftShootBtn, vehicleShootActive or vehicleForwardShootActive)
	self:SetBtnActive(self.bindData.mouseRight, vehicleShootActive or vehicleForwardShootActive)
	self:SetBtnActive(self.bindData.vehicleNormalAttackBtn, goRiderShootActive)
	self:SetBtnActive(self.bindData.vehicleActiveAttackBtn, goRiderShootActive)
	self:SetBtnVisible(self.normalAttackBtnStore, isMobile)
	self:SetBtnVisible(self.leftShootBtnStore, isMobile)
	self:SetBtnVisible(self.mouseRightStore, isMobile)
	self:SetBtnVisible(self.vehicleNormalAttackBtnStore, isMobile)
	self:SetBtnVisible(self.vehicleActiveAttackBtnStore, isMobile)
end

function M:CheckUpdateEnable()
	gStoreManager:RegisterDynamicOnUpdate(self)
end

function M:CheckUpdateDisable()
	gStoreManager:UnregisterDynamicOnUpdate(self)
end
