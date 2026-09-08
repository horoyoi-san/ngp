-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Police\PoliceEscortStore.lua
-- Decompiled from: 01233_PoliceEscortStore.lua_c8842e3490ed.luajit

C_PoliceEscortStore = DefClass("C_PoliceEscortStore", C_PoliceEscortStore, C_StoreGroup)
GroupName2Class.PoliceEscortStore = C_PoliceEscortStore
local M = C_PoliceEscortStore

M.ctor = function(self)
	self.mgr = gPoliceJobManager.escortMgr
	self.leaveBtnHide = false
	self.gamepadMode = false
	self.gamepadUpdateRotate = false
	self.rotateCameraContext = 1
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.lastIndoorId = 0
	self.currentIndoorId = 0
	self.isInDoor = false
end

M.OnAwake = function(self)
	self.bindData.leaveBtn.luaClick = self.CreateAction(self, self.OnLeaveBtnClick)
	self.bindData.releaseBtn.luaClick = self.CreateAction(self, self.OnReleaseBtnClick)
	self.bindData.examineBtn.luaClick = self.CreateAction(self, self.OnExamineBtnClick)
	self.bindData.walkBtn.luaClick = self.CreateAction(self, self.OnWalkBtnClick)
	self.bindData.navigateBtn.luaClick = self.CreateAction(self, self.OnNavigateBtnClick)
	self.bindData.supportBtn.luaClick = self.CreateAction(self, self.OnSupportBtnClick)
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self.CreateAction(self, "OnGamepadStickControl")
	self.msgEvents = {
		[gEventConstants.MAP_CHANGE_TO_INDOOR_MAP] = function (eventId, data)
			self:OnIndoorEnvironmentChange(data)
		end,
		[gEventConstants.L50_AFTER_SWITCH_SCENE] = function (eventId, switchSceneEventParams)
			local switchType = switchSceneEventParams.switchSceneType

			self:OnSceneSwitch(switchType)
		end
	}
end

M.OnShow = function(self, _, data)
	self.targetPid = data.targetPid
	gPoliceJobManager.escortMgr.panel = self
	self.isShow = true
	local store = gStoreManager:GetStoreGroup("CoreHudSystemControlStore")

	if store.bindData.motionActionBtn then
		store.bindData.motionActionBtn:SetActive(false)
	end

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	self:UpdateCurrentIndoorState()
	self:SetBtnShown(true)
	self:OnWalkBtnClick()

	self.joyStickId = 12001

	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(self.joyStickId, 1)
end

M.OnClose = function(self)
	self.isShow = false
	gPoliceJobManager.escortMgr.panel = nil
	local store = gStoreManager:GetStoreGroup("CoreHudSystemControlStore")

	if store.bindData.motionActionBtn then
		store.bindData.motionActionBtn:SetActive(true)
	end

	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(self.joyStickId)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnUpdate = function(self)
	if self.gamepadMode then
		self.UpdateCameraRotateGamePad(self)
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.OnLeaveBtnClick = function(self)
	self.mgr:EscortToLeave_Story(self.targetPid)
end

M.OnReleaseBtnClick = function(self)
	self.mgr:EscortToRelease_Story(self.targetPid)
end

M.OnExamineBtnClick = function(self)
	self.mgr:EscortToExamine_Story(self.targetPid)
end

M.OnWalkBtnClick = function(self)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	if store then
		store.OnWalkBtnClick(store)
	end
end

M.OnNavigateBtnClick = function(self)
	gPoliceJobManager:TraceToPoliceOffice()
end

M.OnSupportBtnClick = function(self)
	self.mgr:EscortSupport_Story(self.targetPid)
end

M.SetBtnShown = function(self, Shown)
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

	if not gPoliceJobManager.escortMgr.showTraceToPoliceOfficeBtn then
		self.bindData.navigateBtn:SetActive(false)
	else
		self.bindData.navigateBtn:SetActive(Shown)
	end

	self.bindData.supportBtn:SetActive(not self.isInDoor and Shown and gPoliceJobManager.escortMgr:IsEscortSupportEnabled())
end

M.UpdateCameraRotateGamePad = function(self)
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(self.rotateCameraContext, self.rightStickValue.x, self.rightStickValue.y)
end

M.OnGamepadStickControl = function(self, context)
	local value = context.ReadValueVector2(context)

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

M.OnIndoorEnvironmentChange = function(self, data)
	if not data then
		return
	end

	local toIndoorId = data.toIndoorId or 0
	self.lastIndoorId = self.currentIndoorId
	self.currentIndoorId = toIndoorId
	self.isInDoor = toIndoorId >= 0

	self.bindData.supportBtn:SetActive(not self.isInDoor and gPoliceJobManager.escortMgr.CanInteract and gPoliceJobManager.escortMgr:IsEscortSupportEnabled())
end

M.OnSceneSwitch = function(self, switchType)
	self.UpdateCurrentIndoorState(self)
end

M.UpdateCurrentIndoorState = function(self)
	local currentIndoorId = gMapManager.IndoorId or 0

	if currentIndoorId == self.currentIndoorId then
		self.OnIndoorEnvironmentChange(self, {
			toIndoorId = currentIndoorId
		})
	end
end
