local SunbathCameraConfig = LTConfig.SunbathCameraConfig
local SunbathConfig = LTConfig.SunbathConfig
local GameplayEvent = MuGenStates.Logic.GameplayEvent
C_BeachMainPanelStore = DefClass("C_BeachMainPanelStore", C_BeachMainPanelStore, C_StoreGroup)
GroupName2Class.BeachMainPanelStore = C_BeachMainPanelStore
local M = C_BeachMainPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.relaxBtn.luaClick = self:CreateAction("OnRelaxBtnClick")
	self.bindData.drinkBtn.luaClick = self:CreateAction("OnDrinkBtnClick")
	self.bindData.chatBtn.luaClick = self:CreateAction("OnChatBtnClick")
	self.bindData.cheersBtn.luaClick = self:CreateAction("OnCheersBtnClick")
	self.bindData.musicBtn.luaClick = self:CreateAction("OnMusicBtnClick")
	self.bindData.switchCameraBtn.luaClick = self:CreateAction("OnSwitchCameraBtnClick")
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	gSunbathManager.isInGame = false

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = "ExitSunBathGameplay"
	})
	gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathExit)
end

function M:OnShow(panelId, data)
	self.isSolo = data and data.isSolo
	self.bindData.isSolo = self.isSolo and 0 or 1
	self.musicIsPlay = true
	self.bindData.isMusicPlay = self.musicIsPlay and 1 or 0
	self.cameraSetId = 1

	self:RefreshInteractionTime()
	self:OnSwitchCameraBtnClick()
end

function M:OnClose()
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnRelaxBtnClick()
	print("OnRelaxBtnClick")
	gMainPhoneFunctionAction.OpenTime()
end

function M:OnDrinkBtnClick()
	gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathDrink)
	print("OnDrinkBtnClick")
end

function M:OnChatBtnClick()
	gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathChat)
	print("OnChatBtnClick")
end

function M:OnCheersBtnClick()
	gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, GameplayEvent.SunbathCheers)
	print("OnCheersBtnClick")
end

function M:OnMusicBtnClick()
	if self.musicIsPlay then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "TurnOffMusic"
		})

		self.musicIsPlay = false
	else
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "TurnOnMusic"
		})

		self.musicIsPlay = true
	end

	self.bindData.isMusicPlay = self.musicIsPlay and 1 or 0

	print("OnMusicBtnClick")
end

function M:OnSwitchCameraBtnClick()
	local cfg = SunbathCameraConfig.GetConfig(self.cameraSetId)

	if cfg == nil then
		return
	end

	local sortCamera = nil

	if self.isSolo then
		sortCamera = SunbathConfig.CameraSoloSort
	else
		sortCamera = SunbathConfig.CameraInviteSort
	end

	self.cameraSetId = self.cameraSetId + 1

	if self.cameraSetId > #sortCamera then
		self.bindData.VCam.gameObject:SetActive(false)

		self.cameraSetId = 1
	else
		if self.cameraSetId == 1 then
			self.bindData.VCam.gameObject:SetActive(true)
		end

		local camCfg = gSunbathManager:GetSunbathCameraCfg(sortCamera[self.cameraSetId])

		if camCfg then
			gUtils:SetCameraView(gCS.MyPlayerManager.PlayerUnit, camCfg, self.bindData.VCam.gameObject)
		end
	end
end

function M:RefreshInteractionTime()
	self.longInteractionTime = gLogicTime.time
	self.shorInteractionTime = gLogicTime.time
end
