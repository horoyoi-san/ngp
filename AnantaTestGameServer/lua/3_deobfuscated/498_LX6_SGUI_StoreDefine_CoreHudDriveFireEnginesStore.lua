C_CoreHudDriveFireEnginesStore = DefClass("C_CoreHudDriveFireEnginesStore", C_CoreHudDriveFireEnginesStore, C_StoreGroup)
GroupName2Class.CoreHudDriveFireEnginesStore = C_CoreHudDriveFireEnginesStore
local M = C_CoreHudDriveFireEnginesStore

function M:OnAwake()
	self.bindData.waterBtn.luaPress = self:CreateAction("OnWaterBtnPress")
	self.bindData.waterBtn.luaRelease = self:CreateAction("OnWaterBtnRelease")
	self.started = false
end

function M:OnDestroy()
	self.started = nil
end

function M:OnGroupEnable()
	self.waterBtnStore = self:GetStoreByWidget(self.bindData.waterBtn)
end

function M:OnShow(panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.currVehicleId = data.vehicleId
	self.IsPhoneMode = IsPhoneMode
	self.IsMainDrive = IsMainDrive

	if self.started then
		self:RefreshButtonState()
	end
end

function M:OnStart()
	self.started = true

	self:RefreshButtonState()
end

function M:OnClose()
	self.currVehicleId = 0
end

function M:OnWaterBtnPress()
	gMessageManager:SendMessage(gEventConstants.FIREENGINE_START_DELUGE, self.currVehicleId)
end

function M:OnWaterBtnRelease()
	gMessageManager:SendMessage(gEventConstants.FIREENGINE_STOP_DELUGE, self.currVehicleId)
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

	self:SetBtnActive(self.bindData.waterBtn, active)
	self:SetBtnVisible(self.waterBtnStore, isMobile)
end
