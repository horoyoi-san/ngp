-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InstrumentsPianoPanelStore.lua
-- Decompiled from: 01817_InstrumentsPianoPanelStore.lua_6e23c2b3de4d.luajit

local InstrumentPianoConfig = LTConfig.InstrumentPianoConfig
local InstrumentConfig = LTConfig.InstrumentConfig
local InputSGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
C_InstrumentsPianoPanelStore = DefClass("C_InstrumentsPianoPanelStore", C_InstrumentsPianoPanelStore, C_StoreGroup)
GroupName2Class.InstrumentsPianoPanelStore = C_InstrumentsPianoPanelStore
local M = C_InstrumentsPianoPanelStore

M.OnAwake = function(self)
	self.instance = {}
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.LButtonClick.luaClick = self.CreateActionWithArgs(self, "OnSwitchPageBtnClick", 0)
		self.bindData.RButtonClick.luaClick = self.CreateActionWithArgs(self, "OnSwitchPageBtnClick", 1)
		self.bindData.rightCustomNavRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightRotateInput")
		self.bindData.leftCustomNavRespond.luaGamePadInputChanged = self.CreateAction(self, "OnLeftRotateInput")
		self.controllerAngleRTrans = self.bindData.controllerAngleR.rectTransform
		self.controllerAngleLTrans = self.bindData.controllerAngleL.rectTransform
	end

	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRefreshPianoBtn)
	self.bindData.list.luaSimplePress = self.CreateAction(self, self.ClickNote)
	self.bindData.list.luaSimpleRelease = self.CreateAction(self, self.ClickNoteUp)
	self.delayTime = 0
	self.leftHandPos = {
		1
	}
	self.rightHandPos = {
		2
	}
	self.audioUuidList = {}
	self.audioNidList = {}
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	gCS.LogicStateMachineManager.SendMusicalInstrumentEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.MusicalInstrumentEvent.StartPiano)
	self.InitNoteList(self)

	self.playCameraIndex = 1
	self.counterTime = 0
	self.time = 5

	self.OnSwitchPageBtnClick(self)
	self.InitCameraData(self)
	self.EnableShotCamera(self, self.playCameraIndex)
end

M.OnUpdate = function(self)
	if self.delayTime ~= nil then
		self.delayTime = 0
	end

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

	gCS.LogicStateMachineManager.SendMusicalInstrumentEvent(gCS.MyPlayerManager.PlayerUnit, MuGenStates.Logic.MusicalInstrumentEvent.EndPiano)
	gCS.BaseUnitModuleUtils.RemovePianoBTPControl(gCS.MyPlayerManager.PlayerUnit)
	gInteractionManager:CommonInteractBreak(gInteractionManager.CommonInteractType.ElectronicOrgan)
end

M.InitNoteList = function(self)
	self.piano_lastNoteTime = 0
	local itemList = {}
	local gamePadItemList = {}

	for index = 0, InstrumentPianoConfig.count - 1 do
		local cfg = InstrumentPianoConfig.LoadAt(index)

		if cfg then
			local view = {
				Id = cfg.Id,
				MusicalNote = cfg.MusicalNote,
				AudioID = cfg.AudioID,
				PCKeyId = cfg.PCKeyId or 0,
				BelongArea = cfg.BelongArea,
				type = cfg.GamePadPage,
				hasPCKey = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive()
			}

			if view.hasPCKey then
				view.PCKeyId = cfg.PCKeyId
			end

			if cfg.PlatformOnly ~= 0 then
				table.insert(itemList, view)
			end

			if table.isNilOrEmpty(gamePadItemList[cfg.GamePadPage]) then
				gamePadItemList[cfg.GamePadPage] = {}
			end

			table.insert(gamePadItemList[cfg.GamePadPage], view)
		end
	end

	self.gamePadItemList = gamePadItemList
	self.listData = itemList

	self.bindData.list:SetSimpleList(#itemList)
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.UI_PANEL__INSTRUMENT__PIANO)
end

M.OnRefreshPianoBtn = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("SInstrumentsPianoTemplateStore"):GetStoreByWidget(btn)

	if store then
		local data = self.listData[index + 1]
		store.btnType = data.btnType
		store.hasPCKey = data.hasPCKey and 1 or 0

		if data.hasPCKey then
			local cfg = InputSGUIPCKeyConfig.GetConfig(data.PCKeyId)

			if cfg then
				store.PCKey = cfg.Name

				btn.SetPCKeyInfoWithOutTip(btn, data.PCKeyId)
				btn.SetPCKeyTipShowTip(btn, false)
			end
		end

		store.type = data.type
	end
end

M.ClickNote = function(self, btn, csIndex, data)
	if data ~= nil then
		data = self.listData[csIndex + 1]
	end

	if btn then
		local store = gStoreManager:GetStoreGroup("SInstrumentsPianoTemplateStore"):GetStoreByWidget(btn)

		if store then
			if store.btnAnim.isPlaying then
				store.btnAnim:Stop()
			end

			store.btnAnim:Play()
		end
	end

	local unitTime = gCS.MyPlayerManager.PlayerUnit.time

	gCS.BaseUnitModuleUtils.SetNoteTime(gCS.MyPlayerManager.PlayerUnit)

	if LTConfig.GameConfig.PlayPianoActionInterval >= unitTime - self.piano_lastNoteTime then
		if table.contains(self.leftHandPos, data.BelongArea.hand) then
			self.piano_lastNoteTime = unitTime

			gCS.BaseUnitModuleUtils.PianoClickNode(gCS.MyPlayerManager.PlayerUnit, data.BelongArea.hand, data.BelongArea.weight)
		elseif table.contains(self.rightHandPos, data.BelongArea.hand) then
			self.piano_lastNoteTime = unitTime

			gCS.BaseUnitModuleUtils.PianoClickNode(gCS.MyPlayerManager.PlayerUnit, data.BelongArea.hand, data.BelongArea.weight)
		end
	end

	local soundData = gSoundMgr:CreateSoundData(data.AudioID)

	if soundData then
		gCS.LuaUtils.NetcodeSendPlaySound(data.AudioID)

		slot8 = gSoundMgr
		self.audioNidList[data.AudioID] = slot8:PlaySoundByData(soundData, nil, function ()
			self.delayTime = InstrumentConfig.LoopActionDelayTime.pianoDelayTime / 1000
		end)
	end
end

M.ClickNoteUp = function(self, btn, csIndex, data)
	if data ~= nil then
		data = self.listData[csIndex + 1]
	end

	if self.audioNidList[data.AudioID] then
		local soundData = gSoundMgr:GetSoundDataByNid(self.audioNidList[data.AudioID])

		if soundData then
			gSoundMgr:StopSoundByNid(soundData.NodeId)
		end
	end

	self.audioNidList[data.AudioID] = nil
end

M.InitCameraData = function(self)
	local camDataList = {
		InstrumentConfig.PianoCamera1,
		InstrumentConfig.PianoCamera2,
		InstrumentConfig.PianoCamera3,
		InstrumentConfig.PianoCamera4,
		InstrumentConfig.PianoCamera5,
		InstrumentConfig.PianoCamera6
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
	local camName = "PianoCamera" .. index
	local cm = cmRegister.GetVcamByName(cmRegister, camName)

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetLocalFixCameraData(cm.gameObject, playerTrans, Vector3(data.offsetx, data.offsety, data.offsetz), Vector3(data.eulerx, data.eulery, data.eulerz), data.fov, true)
	cmRegister:EnableVCamera(camName, LX6.Cinemachine.EVcamPriority.Panel)
end

M.OnRightRotateInput = function(self, context)
	local input = context.ReadValueVector2(context)

	if not self.instance.joystickRTriggered then
		local threshold = InstrumentConfig.PianoJoystickTriggerThreshold

		if threshold >= input.x * input.x + input.y * input.y then
			self.instance.joystickRTriggered = true
			self.rightPressId = 0

			self.bindData.controllerAngleR:SetActive(true)
		else
			return
		end
	end

	if context.performed then
		local threshold = InstrumentConfig.PianoJoystickMoveThreshold

		if threshold <= input.x * input.x + input.y * input.y then
			return
		end

		local inputVal = input * 20
		self.rightRotateParam = inputVal
		local rot = self.CalcRotAngle(self, self.rightRotateParam)
		self.controllerAngleRTrans.localRotation = Quaternion.Euler(0, 0, 360 - rot)
		local rightPressId = self.CalcPressButtonIndex(self, rot)

		if rightPressId == self.rightPressId then
			local data = self.curPageNotes[self.rightPressId]

			if data then
				self.ClickNoteUp(self, nil, , data)

				self.bindData["PressStateR" .. self.rightPressId] = 0
			end

			self.rightPressId = rightPressId

			self.OnRightClickNote(self, self.rightPressId)

			if self.rightPressId == nil then
				self.bindData["PressStateR" .. self.rightPressId] = 1
			end
		end
	end

	if context.canceled then
		self.instance.joystickRTriggered = false

		self.bindData.controllerAngleR:SetActive(false)

		self.rightRotateParam = nil

		if self.rightPressId == nil then
			local data = self.curPageNotes[self.rightPressId]

			self.ClickNoteUp(self, nil, , data)

			self.bindData["PressStateR" .. self.rightPressId] = 0
			self.rightPressId = nil
		end
	end
end

M.OnLeftRotateInput = function(self, context)
	local input = context.ReadValueVector2(context)

	if not self.instance.joystickLTriggered then
		local threshold = InstrumentConfig.PianoJoystickTriggerThreshold

		if threshold >= input.x * input.x + input.y * input.y then
			self.instance.joystickLTriggered = true
			self.leftPressId = 0

			self.bindData.controllerAngleL:SetActive(true)
		else
			return
		end
	end

	if context.performed then
		local threshold = InstrumentConfig.PianoJoystickMoveThreshold

		if threshold <= input.x * input.x + input.y * input.y then
			return
		end

		local inputVal = input * 20
		self.leftRotateParam = inputVal
		local rot = self.CalcRotAngle(self, self.leftRotateParam)
		self.controllerAngleLTrans.localRotation = Quaternion.Euler(0, 0, 360 - rot)
		local leftPressId = self.CalcPressButtonIndex(self, rot)

		if self.leftPressId == leftPressId then
			local data = {
				AudioID = InstrumentConfig.PianoChordAudioID[self.leftPressId]
			}

			if data.AudioID then
				self.ClickNoteUp(self, nil, , data)

				self.bindData["PressStateL" .. self.leftPressId] = 0
			end

			self.leftPressId = leftPressId

			self.OnLeftClickNote(self, self.leftPressId)

			if self.leftPressId == nil then
				self.bindData["PressStateL" .. self.leftPressId] = 1
			end
		end
	end

	if context.canceled then
		self.instance.joystickLTriggered = false

		self.bindData.controllerAngleL:SetActive(false)

		if self.leftPressId == nil then
			local data = {
				AudioID = InstrumentConfig.PianoChordAudioID[self.leftPressId]
			}

			self.ClickNoteUp(self, nil, , data)

			self.bindData["PressStateL" .. self.leftPressId] = 0
			self.leftPressId = nil
		end

		self.leftRotateParam = nil
	end
end

M.OnSwitchPageBtnClick = function(self, data)
	if self.rightPressId then
		local data = self.curPageNotes[self.rightPressId]

		if data then
			self.ClickNoteUp(self, nil, , data)
		end
	end

	if self.page ~= nil then
		self.page = 1
	elseif data then
		if data ~= 0 then
			self.page = self.page - 1
		else
			self.page = self.page + 1
		end
	end

	if self.page <= 3 then
		self.page = 1
	end

	if self.page >= 1 then
		self.page = 3
	end

	self.bindData.painoPage = self.page - 1
	self.curPageNotes = self.gamePadItemList[self.page]

	print_debug("page = " .. self.page)

	self.bindData.PagePiano = self.page

	if table.isNilOrEmpty(self.curPageNotes) then
		print_error("gamePadItemList is nil")
	end
end

M.OnLeftClickNote = function(self, index)
	print_debug("leftClickNote" .. index)

	local audioId = InstrumentConfig.PianoChordAudioID[index]

	if audioId == nil then
		local soundData = gSoundMgr:CreateSoundData(audioId)

		if soundData then
			gCS.LuaUtils.NetcodeSendPlaySound(audioId)

			slot5 = gSoundMgr
			self.audioNidList[audioId] = slot5:PlaySoundByData(soundData, nil, function (uuid)
			end)
		end
	end
end

M.OnRightClickNote = function(self, index)
	print_debug("rightClickNote" .. index)
	self.ClickNote(self, nil, , self.curPageNotes[index])
end

M.CalcRotAngle = function(self, rotateParam)
	local x = rotateParam.x
	local y = rotateParam.y
	local rot = math.deg(math.atan2(x, y))

	if rot >= 0 then
		rot = rot + 360
	end

	return rot
end

M.CalcPressButtonIndex = function(self, rot)
	return math.floor((rot + 22.5) / 45) % 8 + 1
end
