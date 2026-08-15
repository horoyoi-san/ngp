local HudDescConfig = LTConfig.HudDescConfig
C_CoreHudDriveTowedVehicleStore = DefClass("C_CoreHudDriveTowedVehicleStore", C_CoreHudDriveTowedVehicleStore, C_StoreGroup)
GroupName2Class.CoreHudDriveTowedVehicleStore = C_CoreHudDriveTowedVehicleStore
local M = C_CoreHudDriveTowedVehicleStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.upBtn.luaPress = self:CreateAction("OnUpBtnPress")
	self.bindData.upBtn.luaRelease = self:CreateAction("OnUpBtnRelease")
	self.bindData.downBtn.luaPress = self:CreateAction("OnDownBtnPress")
	self.bindData.downBtn.luaRelease = self:CreateAction("OnDownBtnRelease")
	self.bindData.unlockBtn.luaClick = self:CreateAction("OnUnlockBtnClick")
	self.bindData.upDownCustomRespond.luaGamePadInputChanged = self:CreateAction("OnUpDownRespondInput")
	self.UP_DOWN_THRESHOLD = 0.5
	self.started = false
end

function M:OnDestroy()
	self.started = nil
end

function M:OnGroupEnable()
	self.upBtnStore = self:GetStoreByWidget(self.bindData.upBtn)
	self.downBtnStore = self:GetStoreByWidget(self.bindData.downBtn)
	self.unlockBtnStore = self:GetStoreByWidget(self.bindData.unlockBtn)
	self.unlockBtnStore.btnId = HudDescConfig.UNLOCK_BTN
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.currVehicleId = data.vehicleId
	self.IsPhoneMode = IsPhoneMode
	self.IsMainDrive = IsMainDrive

	if self.started then
		self:RefreshButtonState()
	end

	self.upPress = false
	self.downPress = false
end

function M:OnStart()
	self.started = true

	self:RefreshButtonState()
end

function M:OnClose()
	self.currVehicleId = 0
	self.upPress = nil
	self.downPress = nil
end

function M:OnUpBtnPress()
	self.upPress = true

	gMessageManager:SendMessage(gEventConstants.LIFT_UP_TOWING_CRANE_ARM, true)
end

function M:OnUpBtnRelease()
	self.upPress = false

	gMessageManager:SendMessage(gEventConstants.LIFT_UP_TOWING_CRANE_ARM, false)
end

function M:OnDownBtnPress()
	self.downPress = true

	gMessageManager:SendMessage(gEventConstants.DROP_DOWN_TOWING_CRANE_ARM, true)
end

function M:OnDownBtnRelease()
	self.downPress = false

	gMessageManager:SendMessage(gEventConstants.DROP_DOWN_TOWING_CRANE_ARM, false)
end

function M:OnUnlockBtnClick()
	gMessageManager:SendMessage(gEventConstants.DETACH_TOWING_VEHICLE)
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

function M:RefreshButtonState()
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local active = not self.IsPhoneMode and self.IsMainDrive

	self:SetBtnActive(self.bindData.upBtn, active)
	self:SetBtnActive(self.bindData.downBtn, active)
	self:SetBtnActive(self.bindData.unlockBtn, active)
	self:SetBtnVisible(self.upBtnStore, isMobile)
	self:SetBtnVisible(self.downBtnStore, isMobile)
	self:SetBtnVisible(self.unlockBtnStore, isMobile)
end

function M:OnUpDownRespondInput(context)
	if context.performed then
		local value = context:ReadValueVector2().y

		if self.UP_DOWN_THRESHOLD < value or value < -self.UP_DOWN_THRESHOLD then
			if value > 0 then
				if self.downPress then
					self:OnDownBtnRelease()
				end

				if not self.upPress then
					self:OnUpBtnPress()
				end
			end

			if value < 0 then
				if self.upPress then
					self:OnUpBtnRelease()
				end

				if not self.downPress then
					self:OnDownBtnPress()
				end
			end
		else
			if self.upPress then
				self:OnUpBtnRelease()
			end

			if self.downPress then
				self:OnDownBtnRelease()
			end
		end
	end

	if context.canceled then
		if self.upPress then
			self:OnUpBtnRelease()
		end

		if self.downPress then
			self:OnDownBtnRelease()
		end
	end
end
