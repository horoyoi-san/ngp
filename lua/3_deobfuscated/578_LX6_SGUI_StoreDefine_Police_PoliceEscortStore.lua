C_PoliceEscortStore = DefClass("C_PoliceEscortStore", C_PoliceEscortStore, C_StoreGroup)
GroupName2Class.PoliceEscortStore = C_PoliceEscortStore
local M = C_PoliceEscortStore

function M:ctor()
	self.mgr = gPoliceJobManager.escortMgr
	self.leaveBtnHide = false
	self.gamepadMode = false
	self.gamepadUpdateRotate = false
	self.rotateCameraContext = 1
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.lastIndoorId = 0
	self.currentIndoorId = 0
	self.isInDoor = false
end

function M:OnAwake()
	self.bindData.leaveBtn.luaClick = self:CreateAction(self.OnLeaveBtnClick)
	self.bindData.releaseBtn.luaClick = self:CreateAction(self.OnReleaseBtnClick)
	self.bindData.examineBtn.luaClick = self:CreateAction(self.OnExamineBtnClick)
	self.bindData.walkBtn.luaClick = self:CreateAction(self.OnWalkBtnClick)
	self.bindData.navigateBtn.luaClick = self:CreateAction(self.OnNavigateBtnClick)
	self.bindData.supportBtn.luaClick = self:CreateAction(self.OnSupportBtnClick)
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self:CreateAction("OnGamepadStickControl")
	self.msgEvents = {
		[gEventConstants.MAP_CHANGE_TO_INDOOR_MAP] = function (eventId, data)
			self:OnIndoorEnvironmentChange(data)
		end,
		[gEventConstants.AFTER_SWITCH_SCENE] = function (eventId, switchType)
			self:OnSceneSwitch(switchType)
		end
	}
end

function M:OnShow(_, data)
	self.targetPid = data.targetPid
	gPoliceJobManager.escortMgr.panel = self
	self.isShow = true
	local store = gStoreManager:GetStoreGroup("CoreHudSystemControlStore")

	if store.bindData.motionActionBtn then
		store.bindData.motionActionBtn:SetActive(false)
	end

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()

	self:UpdateCurrentIndoorState()
	self:SetBtnShown(gPoliceJobManager.escortMgr.CanInteract)
end

function M:OnClose()
	self.isShow = false
	gPoliceJobManager.escortMgr.panel = nil
	local store = gStoreManager:GetStoreGroup("CoreHudSystemControlStore")

	if store.bindData.motionActionBtn then
		store.bindData.motionActionBtn:SetActive(true)
	end
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

function M:OnUpdate()
	if self.gamepadMode then
		self:UpdateCameraRotateGamePad()
	end
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnLeaveBtnClick()
	if gGameSwitch.EnablePoliceJobStoryLegacy then
		self.mgr:EscortToLeave_Story(self.targetPid)
	else
		self.mgr:EscortToLeave(self.targetPid)
	end
end

function M:OnReleaseBtnClick()
	if gGameSwitch.EnablePoliceJobStoryLegacy then
		self.mgr:EscortToRelease_Story(self.targetPid)
	else
		self.mgr:EscortToRelease(self.targetPid)
	end
end

function M:OnExamineBtnClick()
	if gGameSwitch.EnablePoliceJobStoryLegacy then
		self.mgr:EscortToExamine_Story(self.targetPid)
	else
		self.mgr:EscortToExamine(self.targetPid)
	end
end

function M:OnWalkBtnClick()
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	if store then
		store:OnWalkBtnClick()
	end
end

function M:OnNavigateBtnClick()
	gPoliceJobManager:TraceToPoliceOffice()
end

function M:OnSupportBtnClick()
	if gGameSwitch.EnablePoliceJobStoryLegacy then
		self.mgr:EscortSupport_Story(self.targetPid)
	else
		self.mgr:EscortSupport(self.targetPid)
	end
end

function M:SetBtnShown(Shown)
	if gPoliceJobManager.escortMgr.hideEscortLeaveBtn then
		self.bindData.leaveBtn:SetActive(false)
	else
		self.bindData.leaveBtn:SetActive(Shown)
	end

	if gPoliceJobManager.escortMgr.hideEscortReleaseBtn then
		self.bindData.releaseBtn:SetActive(false)
	else
		self.bindData.releaseBtn:SetActive(Shown)
	end

	if gPoliceJobManager.escortMgr.hideEscortToExamineBtn then
		self.bindData.examineBtn:SetActive(false)
	else
		self.bindData.examineBtn:SetActive(Shown)
	end

	self.bindData.navigateBtn:SetActive(Shown)
	self.bindData.supportBtn:SetActive(not self.isInDoor and Shown and gPoliceJobManager.escortMgr:IsEscortSupportEnabled())
end

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(self.rotateCameraContext, self.rightStickValue.x, self.rightStickValue.y)
end

function M:OnGamepadStickControl(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.gamepadUpdateRotate = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.gamepadUpdateRotate = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(self.rotateCameraContext, 0, 0)
	end
end

function M:OnIndoorEnvironmentChange(data)
	if not data then
		return
	end

	local toIndoorId = data.toIndoorId or 0
	self.lastIndoorId = self.currentIndoorId
	self.currentIndoorId = toIndoorId
	self.isInDoor = toIndoorId > 0

	self.bindData.supportBtn:SetActive(not self.isInDoor and gPoliceJobManager.escortMgr.CanInteract and gPoliceJobManager.escortMgr:IsEscortSupportEnabled())
end

function M:OnSceneSwitch(switchType)
	self:UpdateCurrentIndoorState()
end

function M:UpdateCurrentIndoorState()
	local currentIndoorId = gMapManager.IndoorId or 0

	if currentIndoorId ~= self.currentIndoorId then
		self:OnIndoorEnvironmentChange({
			toIndoorId = currentIndoorId
		})
	end
end
