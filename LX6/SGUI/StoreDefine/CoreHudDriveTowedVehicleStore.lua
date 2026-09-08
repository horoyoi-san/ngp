-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudDriveTowedVehicleStore.lua
-- Decompiled from: 01494_CoreHudDriveTowedVehicleStore.lua_57232fd113ef.luajit

local HudDescConfig = LTConfig.HudDescConfig
C_CoreHudDriveTowedVehicleStore = DefClass("C_CoreHudDriveTowedVehicleStore", C_CoreHudDriveTowedVehicleStore, C_StoreGroup)
GroupName2Class.CoreHudDriveTowedVehicleStore = C_CoreHudDriveTowedVehicleStore
local M = C_CoreHudDriveTowedVehicleStore

M.OnAwake = function(self)
	self.bindData.upBtn.luaPress = self.CreateAction(self, "OnUpBtnPress")
	self.bindData.upBtn.luaRelease = self.CreateAction(self, "OnUpBtnRelease")
	self.bindData.downBtn.luaPress = self.CreateAction(self, "OnDownBtnPress")
	self.bindData.downBtn.luaRelease = self.CreateAction(self, "OnDownBtnRelease")
	self.bindData.unlockBtn.luaClick = self.CreateAction(self, "OnUnlockBtnClick")
	self.bindData.upDownCustomRespond.luaGamePadInputChanged = self.CreateAction(self, "OnUpDownRespondInput")
	self.UP_DOWN_THRESHOLD = 0.5
	self.started = false
	self.unlockState = false
	self.msgEvents = {
		[gEventConstants.VEHICLE_TOWING_ATTACH_STATE_CHANGED] = self.CreateAction(self, "OnAttachStateChange")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnDestroy = function(self)
	self.started = nil
	self.unlockState = nil
end

M.OnGroupEnable = function(self)
	self.upBtnStore = self.GetStoreByWidget(self, self.bindData.upBtn)
	self.downBtnStore = self.GetStoreByWidget(self, self.bindData.downBtn)
	self.unlockBtnStore = self.GetStoreByWidget(self, self.bindData.unlockBtn)
	self.unlockBtnStore.btnId = HudDescConfig.UNLOCK_BTN
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.msgEvents = nil
end

M.OnShow = function(self, panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.currVehicleData = data
	self.IsPhoneMode = IsPhoneMode
	self.IsMainDrive = IsMainDrive

	if self.started then
		self.unlockState = self.currVehicleData.vehicleCs.IsTowingVehicle

		self.RefreshButtonState(self)
	end

	self.upPress = false
	self.downPress = false
end

M.OnStart = function(self)
	self.started = true

	self.RefreshButtonState(self)
end

M.OnClose = function(self)
	self.currVehicleData = nil
	self.upPress = nil
	self.downPress = nil
end

M.OnUpBtnPress = function(self)
	self.upPress = true

	gMessageManager:SendMessage(gEventConstants.LIFT_UP_TOWING_CRANE_ARM, true)
end

M.OnUpBtnRelease = function(self)
	self.upPress = false

	gMessageManager:SendMessage(gEventConstants.LIFT_UP_TOWING_CRANE_ARM, false)
end

M.OnDownBtnPress = function(self)
	self.downPress = true

	gMessageManager:SendMessage(gEventConstants.DROP_DOWN_TOWING_CRANE_ARM, true)
end

M.OnDownBtnRelease = function(self)
	self.downPress = false

	gMessageManager:SendMessage(gEventConstants.DROP_DOWN_TOWING_CRANE_ARM, false)
end

M.OnUnlockBtnClick = function(self)
	gMessageManager:SendMessage(gEventConstants.DETACH_TOWING_VEHICLE)
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

	self:SetBtnActive(self.bindData.upBtn, active)
	self:SetBtnActive(self.bindData.downBtn, active)
	self:SetBtnActive(self.bindData.unlockBtn, active and self.unlockState)
	self:SetBtnVisible(self.upBtnStore, isMobile)
	self:SetBtnVisible(self.downBtnStore, isMobile)
	self:SetBtnVisible(self.unlockBtnStore, isMobile and self.unlockState)
end

M.OnUpDownRespondInput = function(self, context)
	if context.performed then
		local value = context.ReadValueVector2(context).y

		if self.UP_DOWN_THRESHOLD <= value or value >= -self.UP_DOWN_THRESHOLD then
			if value <= 0 then
				if self.downPress then
					self.OnDownBtnRelease(self)
				end

				if not self.upPress then
					self.OnUpBtnPress(self)
				end
			end

			if value >= 0 then
				if self.upPress then
					self.OnUpBtnRelease(self)
				end

				if not self.downPress then
					self.OnDownBtnPress(self)
				end
			end
		else
			if self.upPress then
				self.OnUpBtnRelease(self)
			end

			if self.downPress then
				self.OnDownBtnRelease(self)
			end
		end
	end

	if context.canceled then
		if self.upPress then
			self.OnUpBtnRelease(self)
		end

		if self.downPress then
			self.OnDownBtnRelease(self)
		end
	end
end

M.OnAttachStateChange = function(self, eventId, state)
	if not self.STATE_EnableOnce then
		return
	end

	self.unlockState = state

	self.RefreshUnlockButton(self)
end

M.RefreshUnlockButton = function(self)
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local active = not self.IsPhoneMode and self.IsMainDrive

	self:SetBtnActive(self.bindData.unlockBtn, active and self.unlockState)
	self:SetBtnVisible(self.unlockBtnStore, isMobile and self.unlockState)
end
