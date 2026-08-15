local InstrumentDrumKitConfig = LTConfig.InstrumentDrumKitConfig
local InstrumentConfig = LTConfig.InstrumentConfig
C_InstrumentsDrumkitPanelStore = DefClass("C_InstrumentsDrumkitPanelStore", C_InstrumentsDrumkitPanelStore, C_StoreGroup)
GroupName2Class.InstrumentsDrumkitPanelStore = C_InstrumentsDrumkitPanelStore
local M = C_InstrumentsDrumkitPanelStore

function M:OnAwake()
	self.ANIM_BIND = {
		self.bindData.MiddleDrumAnim,
		self.bindData.TopLeftDrumAnim,
		self.bindData.TopRightDrumAnim,
		self.bindData.LeftDrumAnim,
		self.bindData.RightDrumAnim,
		self.bindData.LeftCymbal2Anim,
		self.bindData.LeftCymbal1Anim,
		self.bindData.LeftCymbal1OpenAnim,
		self.bindData.RightCymbal2Anim,
		self.bindData.RightCymbal1Anim
	}
	self.SPECIAL_ANIM_INDEX = {
		7,
		8
	}
	self.SPECIAL_ANIM = {
		[7] = self.bindData.LeftCymbal1Anim2,
		[8] = self.bindData.LeftCymbal1OpenAnim2
	}
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.MiddleDrumBtn.luaPress = self:CreateActionWithArgs("OnClickNote", 1)
	self.bindData.TopLeftDrumBtn.luaPress = self:CreateActionWithArgs("OnClickNote", 2)
	self.bindData.TopRightDrumBtn.luaPress = self:CreateActionWithArgs("OnClickNote", 3)
	self.bindData.LeftDrumBtn.luaPress = self:CreateActionWithArgs("OnClickNote", 4)
	self.bindData.RightDrumBtn.luaPress = self:CreateActionWithArgs("OnClickNote", 5)
	self.bindData.LeftCymbal2Btn.luaPress = self:CreateActionWithArgs("OnClickNote", 6)
	self.bindData.LeftCymbal1Btn.luaPress = self:CreateActionWithArgs("OnClickNote", 7)
	self.bindData.LeftCymbal1OpenBtn.luaPress = self:CreateActionWithArgs("OnClickNote", 8)
	self.bindData.RightCymbal2Btn.luaPress = self:CreateActionWithArgs("OnClickNote", 9)
	self.bindData.RightCymbal1Btn.luaPress = self:CreateActionWithArgs("OnClickNote", 10)
	self.delayTime = 0

	self:InitCameraData()
end

function M:OnDestroy()
	gInteractionManager:CommonInteractBreak(gInteractionManager.CommonInteractType.SitDrum)
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	gGamePlayTransitionMgr:EnterGamePlay(gGamePlayTransitionMgr.GamePlayType.Drum)

	self.playCameraIndex = 1
	self.counterTime = 0
	self.time = 10

	self:EnableShotCamera(self.playCameraIndex)
end

function M:InitCameraData()
	local camDataList = {
		InstrumentConfig.DrumkitCamera1,
		InstrumentConfig.DrumkitCamera2,
		InstrumentConfig.DrumkitCamera3,
		InstrumentConfig.DrumkitCamera4,
		InstrumentConfig.DrumkitCamera5,
		InstrumentConfig.DrumkitCamera6
	}
	self.camOffSet = {}

	for i = 1, #camDataList do
		local data = camDataList[i]
		self.camOffSet[i] = {
			offsetx = data.offsetx,
			offsety = data.offsety,
			offsetz = data.offsetz,
			eulerx = data.eulerx,
			eulery = data.eulery,
			eulerz = data.eulerz,
			fov = data.fov,
			time = data.time
		}
	end
end

function M:OnUpdate()
	if self.delayTime > 0 then
		self.delayTime = self.delayTime - Time.deltaTime
	end

	self.counterTime = self.counterTime + Time.deltaTime

	if self.time <= self.counterTime then
		self.counterTime = 0

		self:EnableShotCamera(self.playCameraIndex)
	end
end

function M:OnClose()
	self.counterTime = 0

	gGamePlayTransitionMgr:EndGamePlay(gGamePlayTransitionMgr.GamePlayType.Drum)
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.UI_PANEL__INSTRUMENT__DRUMKIT)
end

function M:OnClickNote(index)
	local cfg = InstrumentDrumKitConfig.GetConfig(index)

	if cfg then
		print("当前点击的鼓id为 " .. index)

		if table.contains(self.SPECIAL_ANIM_INDEX, index) then
			if self.SPECIAL_ANIM[index].isPlaying then
				self.SPECIAL_ANIM[index]:Stop()
			end

			for i, v in pairs(self.SPECIAL_ANIM) do
				self.SPECIAL_ANIM[i]:Play()
			end
		end

		if self.ANIM_BIND[index].isPlaying then
			self.ANIM_BIND[index]:Stop()
		end

		self.ANIM_BIND[index]:Play()

		gGamePlayDrumkitManager.DrumkitKeyType = cfg.KeyIndex

		gGamePlayTransitionMgr:CheckSwitchAction()

		local soundData = gSoundMgr:CreateSoundData(cfg.AudioID)

		if soundData then
			gSoundMgr:PlaySoundByData(soundData, nil, function ()
				self.delayTime = InstrumentConfig.LoopActionDelayTime.drumkitDelayTime / 1000
			end)
		end
	else
		print_error("ClickNote error  index = " .. index)
	end
end

function M:EnableShotCamera(index)
	self.playCameraIndex = index % 6 + 1
	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("InstrumentsDrumkitPanel")

	if not cmRegister then
		return
	end

	local data = self.camOffSet[index]

	if table.isNilOrEmpty(data) then
		return
	end

	self.time = data.time
	local playerTrans = gCS.MyPlayerManager.PlayerUnit.PlayerObj
	local worldPos = playerTrans:TransformPoint(data.offsetx, data.offsety, data.offsetz)
	local dir = Quaternion.Euler(data.eulerx, data.eulery, data.eulerz) * Vector3.forward
	local worldEuler = Quaternion.LookRotation(playerTrans:TransformDirection(dir)).eulerAngles
	local camName = "DrumkitCamera" .. index
	local cm = cmRegister:GetVcamByName(camName)

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetFixCameraData(cm.gameObject, worldPos, worldEuler, data.fov)
	cmRegister:EnableVCamera(camName, LX6.Cinemachine.EVcamPriority.Panel)
end
