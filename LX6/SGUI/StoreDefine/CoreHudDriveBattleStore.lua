-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudDriveBattleStore.lua
-- Decompiled from: 01490_CoreHudDriveBattleStore.lua_2237c4b787e9.luajit

local DragEventListener = SGUI.EventSystems.DragEventListener
C_CoreHudDriveBattleStore = DefClass("C_CoreHudDriveBattleStore", C_CoreHudDriveBattleStore, C_StoreGroup)
GroupName2Class.CoreHudDriveBattleStore = C_CoreHudDriveBattleStore
local M = C_CoreHudDriveBattleStore

M.ctor = function(self)
	self.DEFINE_DynamicOnUpdate = true
end

M.OnAwake = function(self)
	self.started = false
end

M.OnGroupEnable = function(self)
	self.InitSkillBtns(self)
end

M.OnShow = function(self, panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.IsMainDrive = IsMainDrive
	self.IsPhoneMode = IsPhoneMode

	if self.started then
		self.RefreshButtonState(self)
	end

	self.ShowNormalAttackBtn(self, true)
end

M.OnStart = function(self)
	self.started = true

	self.RefreshButtonState(self)
end

M.OnUpdate = function(self)
	gMainMenuMgr:ModifyCameraColorModulation()
end

M.OnClose = function(self)
	self.ShowNormalAttackBtn(self, false)
end

M.OnDestroy = function(self)
	self.started = nil
	self.normalAttackBtnStore = nil
	self.leftShootBtnStore = nil
end

M.EnterPhoneMode = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = true

	self.RefreshButtonState(self)
end

M.ExitPhoneMode = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = false

	self.RefreshButtonState(self)
end

M.ResetData = function(self)
end

M.InitSkillBtns = function(self)
	self.normalAttackBtnStore = self.GetStoreByWidget(self, self.bindData.normalAttackBtn)
	self.leftShootBtnStore = self.GetStoreByWidget(self, self.bindData.leftShootBtn)

	self.InitVehicleUnitAttackBtns(self)

	self.bindData.normalAttackBtn.luaPress = self.CreateActionWithArgs(self, "OnNormalAttackBtnDown", 1)
	self.bindData.normalAttackBtn.luaRelease = self.CreateActionWithArgs(self, "OnNormalAttackBtnUp", 1)
	self.bindData.normalAttackBtn.luaClick = self.CreateActionWithArgs(self, "OnNormalAttackBtnClick", 1)
	self.bindData.normalAttackBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnNormalAttackBtnLongPressBegin", 1)
	self.bindData.normalAttackBtn.luaLongPress = self.CreateActionWithArgs(self, "OnNormalAttackBtnLongPress", 1)
	self.bindData.normalAttackBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnNormalAttackBtnLongPressEnd", 1)
	self.bindData.leftShootBtn.luaPress = self.CreateActionWithArgs(self, "OnNormalAttackBtnDown", 1)
	self.bindData.leftShootBtn.luaRelease = self.CreateActionWithArgs(self, "OnNormalAttackBtnUp", 1)
	self.bindData.leftShootBtn.luaClick = self.CreateActionWithArgs(self, "OnNormalAttackBtnClick", 1)
	self.bindData.leftShootBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnNormalAttackBtnLongPressBegin", 1)
	self.bindData.leftShootBtn.luaLongPress = self.CreateActionWithArgs(self, "OnNormalAttackBtnLongPress", 1)
	self.bindData.leftShootBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnNormalAttackBtnLongPressEnd", 1)

	if self.bindData.mouseRight then
		self.mouseRightStore = self.GetStoreByWidget(self, self.bindData.mouseRight)
		self.bindData.mouseRight.luaPress = self.CreateAction(self, "OnMouseRightBtnDown")
		self.bindData.mouseRight.luaRelease = self.CreateAction(self, "OnMouseRightBtnUp")
	end

	local normalAttackBtnDrag = DragEventListener.Get(self.bindData.normalAttackBtn.gameObject)
	normalAttackBtnDrag.onBeginDrag = self.CreateActionWithArgs(self, "OnNormalAttackBtnDragBegin", 1)
	normalAttackBtnDrag.onDrag = self.CreateActionWithArgs(self, "OnNormalAttackBtnDrag", 1)
	normalAttackBtnDrag.onEndDrag = self.CreateActionWithArgs(self, "OnNormalAttackBtnDragEnd", 1)

	self.ResetData(self)
end

M.ShowNormalAttackBtn = function(self, enable)
	local showBtn = enable and not gCS.LuaUtils.IsNonMobileAdaptive()

	if not self.normalAttackBtnStore or not self.leftShootBtnStore then
		self.InitSkillBtns(self)
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

M.OnNormalAttackBtnDown = function(self)
	self.OnNormalAttackBtnLongPressBegin(self)
end

M.OnNormalAttackBtnUp = function(self)
	self.OnNormalAttackBtnLongPressEnd(self)
end

M.OnNormalAttackBtnClick = function(self)
end

M.OnNormalAttackBtnLongPressBegin = function(self)
	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if gCS.ShootModule.GetVehicleShootState(csUnit) ~= LX6.Units.Module.ShootModule.VehicleShootState.None then
		return
	end

	if gCS.ShootModule.GetIsInVehicleForwardShootState(csUnit) then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Normal)
	end

	if gCS.ShootModule.GetIsInVehicleShootState(csUnit) then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Normal)
	end
end

M.OnNormalAttackBtnLongPress = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(gBattleMgr.SkillBtnType.Normal)
end

M.OnNormalAttackBtnLongPressEnd = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Normal)
end

M.OnNormalAttackBtnDragBegin = function(self, index, eventPointer)
	gMainMenuMgr:OnDragBtnDragBegin(index, eventPointer)
end

M.OnNormalAttackBtnDrag = function(self, index, eventPointer)
	gMainMenuMgr:OnDragBtnDraging(index, eventPointer)
end

M.OnNormalAttackBtnDragEnd = function(self, index, eventPointer)
	gMainMenuMgr:OnDragBtnDragEnd(index, eventPointer)
end

M.OnMouseRightBtnDown = function(self)
	local csUnit = gCS.MyPlayerManager.PlayerUnit
	local vehicleShootState = gCS.ShootModule.GetVehicleShootState(csUnit)

	if vehicleShootState ~= LX6.Units.Module.ShootModule.VehicleShootState.None then
		return
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Aim)
end

M.OnMouseRightBtnUp = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Aim)
end

M.SetRightBtnStatus = function(self, down)
	if self.mouseRightStore then
		self.mouseRightStore.btnStatusCtrl = down and 1 or 0
	end
end

M.InitVehicleUnitAttackBtns = function(self)
	self.vehicleNormalAttackBtnStore = self.GetStoreByWidget(self, self.bindData.vehicleNormalAttackBtn)
	self.vehicleActiveAttackBtnStore = self.GetStoreByWidget(self, self.bindData.vehicleActiveAttackBtn)
	self.bindData.vehicleNormalAttackBtn.luaPress = self.CreateActionWithArgs(self, "OnVehicleNormalAttackBtnDown", 1)
	self.bindData.vehicleNormalAttackBtn.luaRelease = self.CreateActionWithArgs(self, "OnVehicleNormalAttackBtnUp", 1)
	self.bindData.vehicleNormalAttackBtn.luaClick = self.CreateActionWithArgs(self, "OnVehicleNormalAttackBtnClick", 1)
	self.bindData.vehicleNormalAttackBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnVehicleNormalAttackBtnLongPressBegin", 1)
	self.bindData.vehicleNormalAttackBtn.luaLongPress = self.CreateActionWithArgs(self, "OnVehicleNormalAttackBtnLongPress", 1)
	self.bindData.vehicleNormalAttackBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnVehicleNormalAttackBtnLongPressEnd", 1)
	self.bindData.vehicleActiveAttackBtn.luaPress = self.CreateActionWithArgs(self, "OnVehicleActiveAttackBtnDown", 2)
	self.bindData.vehicleActiveAttackBtn.luaRelease = self.CreateActionWithArgs(self, "OnVehicleActiveAttackBtnUp", 2)
	self.bindData.vehicleActiveAttackBtn.luaClick = self.CreateActionWithArgs(self, "OnVehicleActiveAttackBtnClick", 2)
	self.bindData.vehicleActiveAttackBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnVehicleActiveAttackBtnLongPressBegin", 2)
	self.bindData.vehicleActiveAttackBtn.luaLongPress = self.CreateActionWithArgs(self, "OnVehicleActiveAttackBtnLongPress", 2)
	self.bindData.vehicleActiveAttackBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnVehicleActiveAttackBtnLongPressEnd", 2)
end

M.ShowVehicleUnitAttackBtns = function(self, enable)
	self.SetBtnVisible(self, self.vehicleNormalAttackBtnStore, enable)
	self.SetBtnVisible(self, self.vehicleActiveAttackBtnStore, enable)
end

M.SetShowVehicleUnitAttackBtns = function(self, enable)
	self.showVehicleAttackBtnDefault = enable
end

M.OnVehicleNormalAttackBtnDown = function(self, data)
	self.OnVehicleNormalAttackBtnLongPressBegin(self, data)
end

M.OnVehicleNormalAttackBtnUp = function(self, data)
	self.OnVehicleNormalAttackBtnLongPressEnd(self, data)
end

M.OnVehicleNormalAttackBtnClick = function(self, data)
end

M.OnVehicleNormalAttackBtnLongPressBegin = function(self, data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(data)
end

M.OnVehicleNormalAttackBtnLongPress = function(self, data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(data)
end

M.OnVehicleNormalAttackBtnLongPressEnd = function(self, data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(data)
end

M.OnVehicleActiveAttackBtnDown = function(self, data)
	self.OnVehicleActiveAttackBtnLongPressBegin(self, data)
end

M.OnVehicleActiveAttackBtnUp = function(self, data)
	self.OnVehicleActiveAttackBtnLongPressEnd(self, data)
end

M.OnVehicleActiveAttackBtnClick = function(self, data)
end

M.OnVehicleActiveAttackBtnLongPressBegin = function(self, data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(data)
end

M.OnVehicleActiveAttackBtnLongPress = function(self, data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPress(data)
end

M.OnVehicleActiveAttackBtnLongPressEnd = function(self, data)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(data)
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetBtnInteractable = function(self, btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

M.SetBtnControl = function(self, btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end

M.SetBtnActive = function(self, btn, active)
	btn.SetActive(btn, active)
end

M.RefreshButtonState = function(self)
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

M.CheckUpdateEnable = function(self)
	gStoreManager:RegisterDynamicOnUpdate(self)
end

M.CheckUpdateDisable = function(self)
	gStoreManager:UnregisterDynamicOnUpdate(self)
end
