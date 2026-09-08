-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudDriveFireEnginesStore.lua
-- Decompiled from: 01492_CoreHudDriveFireEnginesStore.lua_7398865eae54.luajit

C_CoreHudDriveFireEnginesStore = DefClass("C_CoreHudDriveFireEnginesStore", C_CoreHudDriveFireEnginesStore, C_StoreGroup)
GroupName2Class.CoreHudDriveFireEnginesStore = C_CoreHudDriveFireEnginesStore
local M = C_CoreHudDriveFireEnginesStore

M.OnAwake = function(self)
	self.bindData.waterBtn.luaPress = self.CreateAction(self, "OnWaterBtnPress")
	self.bindData.waterBtn.luaRelease = self.CreateAction(self, "OnWaterBtnRelease")
	self.bindData.aimBtn.luaPress = self.CreateAction(self, "OnAimBtnPress")
	self.bindData.aimBtn.luaRelease = self.CreateAction(self, "OnAimBtnRelease")
	self.started = false
	self.waterBtnPress = false
	self.msgEvents = {
		[gEventConstants.HACK_BTN_PRESS] = self.CreateAction(self, "OnHackBtnPress")
	}
end

M.OnDestroy = function(self)
	self.started = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)

	self.waterBtnStore = self.GetStoreByWidget(self, self.bindData.waterBtn)
	self.aimBtnStore = self.GetStoreByWidget(self, self.bindData.aimBtn)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.waterBtnStore = nil
	self.aimBtnStore = nil
end

M.OnShow = function(self, panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.currVehicleId = data.vehicleId
	self.IsPhoneMode = IsPhoneMode
	self.IsMainDrive = IsMainDrive
	self.waterBtnPress = false

	gPanelManager:DisableSpecialController()

	if self.started then
		self.RefreshButtonState(self)
	end
end

M.OnStart = function(self)
	self.started = true

	self.RefreshButtonState(self)
end

M.OnClose = function(self)
	self.currVehicleId = 0
	self.waterBtnPress = false

	gPanelManager:EnableSpecialController()
end

M.OnWaterBtnPress = function(self)
	self.waterBtnPress = true

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("OnWaterBtnPress")
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Normal)
end

M.OnWaterBtnRelease = function(self)
	if self.waterBtnPress then
		self.waterBtnPress = false

		if gStoreManager.DEBUG_UI_INPUT then
			print_error("OnWaterBtnRelease")
		end

		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Normal)
	end
end

M.OnAimBtnPress = function(self)
	if gStoreManager.DEBUG_UI_INPUT then
		print_error("OnAimBtnPress")
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Aim)
end

M.OnAimBtnRelease = function(self)
	if gStoreManager.DEBUG_UI_INPUT then
		print_error("OnAimBtnRelease")
	end

	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Aim)
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

M.RefreshButtonState = function(self)
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local active = not self.IsPhoneMode and self.IsMainDrive

	self:SetBtnActive(self.bindData.waterBtn, active)
	self:SetBtnActive(self.bindData.aimBtn, active)
	self:SetBtnVisible(self.waterBtnStore, isMobile)
	self:SetBtnVisible(self.aimBtnStore, isMobile)
end

M.OnHackBtnPress = function(self)
	if self.waterBtnPress then
		self.waterBtnPress = false

		if gStoreManager.DEBUG_UI_INPUT then
			print_error("OnWaterBtnRelease")
		end

		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.Normal)
	end
end
