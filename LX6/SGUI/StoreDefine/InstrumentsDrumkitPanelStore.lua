-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InstrumentsDrumkitPanelStore.lua
-- Decompiled from: 01826_InstrumentsDrumkitPanelStore.lua_4431c668467d.luajit

local InstrumentDrumKitConfig = LTConfig.InstrumentDrumKitConfig
local InstrumentConfig = LTConfig.InstrumentConfig
C_InstrumentsDrumkitPanelStore = DefClass("C_InstrumentsDrumkitPanelStore", C_InstrumentsDrumkitPanelStore, C_StoreGroup)
GroupName2Class.InstrumentsDrumkitPanelStore = C_InstrumentsDrumkitPanelStore
local M = C_InstrumentsDrumkitPanelStore

M.OnAwake = function(self)
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
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.MiddleDrumBtn.luaPress = self.CreateActionWithArgs(self, "OnClickNote", 1)
	self.bindData.TopLeftDrumBtn.luaPress = self.CreateActionWithArgs(self, "OnClickNote", 2)
	self.bindData.TopRightDrumBtn.luaPress = self.CreateActionWithArgs(self, "OnClickNote", 3)
	self.bindData.LeftDrumBtn.luaPress = self.CreateActionWithArgs(self, "OnClickNote", 4)
	self.bindData.RightDrumBtn.luaPress = self.CreateActionWithArgs(self, "OnClickNote", 5)
	self.bindData.LeftCymbal2Btn.luaPress = self.CreateActionWithArgs(self, "OnClickNote", 6)
	self.bindData.LeftCymbal1Btn.luaPress = self.CreateActionWithArgs(self, "OnClickNote", 7)
	self.bindData.LeftCymbal1OpenBtn.luaPress = self.CreateActionWithArgs(self, "OnClickNote", 8)
	self.bindData.RightCymbal2Btn.luaPress = self.CreateActionWithArgs(self, "OnClickNote", 9)
	self.bindData.RightCymbal1Btn.luaPress = self.CreateActionWithArgs(self, "OnClickNote", 10)
	self.delayTime = 0

	self.InitCameraData(self)
end

M.OnDestroy = function(self)
	gInteractionManager:CommonInteractBreak(gInteractionManager.CommonInteractType.SitDrum)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	gCS.LogicStateMachineManager.SendMusicalInstrumentEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.MusicalInstrumentEvent.StartDrum)

	self.playCameraIndex = 1
	self.counterTime = 0
	self.time = 10

	self.EnableShotCamera(self, self.playCameraIndex)
end

M.InitCameraData = function(self)
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

M.OnUpdate = function(self)
	if self.delayTime <= 0 then
		self.delayTime = self.delayTime - Time.deltaTime
	end

	self.counterTime = self.counterTime + Time.deltaTime

	if self.time < self.counterTime then
		self.counterTime = 0

		self.EnableShotCamera(self, self.playCameraIndex)
	end
end

M.OnClose = function(self)
	self.counterTime = 0

	gCS.LogicStateMachineManager.SendMusicalInstrumentEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.MusicalInstrumentEvent.EndDrum)
	gCS.BaseUnitModuleUtils.RemoveDrumkitModule(gCS.MyPlayerManager.PlayerUnit)
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.UI_PANEL__INSTRUMENT__DRUMKIT)
end

M.OnClickNote = function(self, index)
	local cfg = InstrumentDrumKitConfig.GetConfig(index)

	if cfg then
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
		gCS.BaseUnitModuleUtils.HitDrum(gCS.MyPlayerManager.PlayerUnit, cfg.KeyIndex)

		local soundData = gSoundMgr:CreateSoundData(cfg.AudioID)

		if soundData then
			gCS.LuaUtils.NetcodeSendPlaySound(cfg.AudioID)

			slot4 = gSoundMgr

			slot4:PlaySoundByData(soundData, nil, function ()
				self.delayTime = InstrumentConfig.LoopActionDelayTime.drumkitDelayTime / 1000
			end)
		end
	else
		print_error("ClickNote error  index = " .. index)
	end
end

M.EnableShotCamera = function(self, index)
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
	local playerTrans = gCS.MyPlayerManager.PlayerUnit.PlayerObj.transform
	local camName = "DrumkitCamera" .. index
	local cm = cmRegister.GetVcamByName(cmRegister, camName)

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetLocalFixCameraData(cm.gameObject, playerTrans, Vector3(data.offsetx, data.offsety, data.offsetz), Vector3(data.eulerx, data.eulery, data.eulerz), data.fov, true)
	cmRegister:EnableVCamera(camName, LX6.Cinemachine.EVcamPriority.Panel)
end
