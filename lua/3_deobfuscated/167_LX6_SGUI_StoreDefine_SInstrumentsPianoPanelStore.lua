local InstrumentPianoConfig = LTConfig.InstrumentPianoConfig
local InstrumentConfig = LTConfig.InstrumentConfig
local InputSGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
C_SInstrumentsPianoPanelStore = DefClass("C_SInstrumentsPianoPanelStore", C_SInstrumentsPianoPanelStore, C_StoreGroup)
GroupName2Class.SInstrumentsPianoPanelStore = C_SInstrumentsPianoPanelStore
local M = C_SInstrumentsPianoPanelStore

function M:OnAwake()
	self.instance = {}
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.LButtonClick.luaClick = self:CreateActionWithArgs("OnSwitchPageBtnClick", 0)
		self.bindData.RButtonClick.luaClick = self:CreateActionWithArgs("OnSwitchPageBtnClick", 1)
		self.bindData.rightCustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnRightRotateInput")
		self.bindData.leftCustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnLeftRotateInput")
		self.controllerAngleRTrans = self.bindData.controllerAngleR.rectTransform
		self.controllerAngleLTrans = self.bindData.controllerAngleL.rectTransform
	end

	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRefreshPianoBtn)
	self.bindData.list.luaSimplePress = self:CreateAction(self.ClickNote)
	self.bindData.list.luaSimpleRelease = self:CreateAction(self.ClickNoteUp)
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

function M:OnDestroy()
	return
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
	gGamePlayTransitionMgr:EnterGamePlay(gGamePlayTransitionMgr.GamePlayType.Piano)
	self:InitNoteList()

	self.playCameraIndex = 1
	self.counterTime = 0
	self.time = 5

	self:OnSwitchPageBtnClick()
	self:InitCameraData()
	self:EnableShotCamera(self.playCameraIndex)
end

function M:OnUpdate()
	if self.delayTime == nil then
		self.delayTime = 0
	end

	if self.delayTime > 0 then
		self.delayTime = self.delayTime - Time.deltaTime
	end

	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if csUnit then
		gGamePlayPianoManager.piano_curCheckType = 2

		gGamePlayTransitionMgr:CheckSwitchAction()

		gGamePlayPianoManager.piano_curCheckType = 0
	end

	self.counterTime = self.counterTime + Time.deltaTime

	if self.time <= self.counterTime then
		self.counterTime = 0

		self:EnableShotCamera(self.playCameraIndex)
	end
end

function M:OnClose()
	self.counterTime = 0

	gGamePlayTransitionMgr:EndGamePlay(gGamePlayTransitionMgr.GamePlayType.Piano)
	gInteractionManager:CommonInteractBreak(gInteractionManager.CommonInteractType.ElectronicOrgan)
end

function M:InitNoteList()
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

			if cfg.PlatformOnly == 0 then
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
	self.bindData.list:SetItemSelected(0, true)
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.UI_PANEL__INSTRUMENT__PIANO)
end

function M:OnRefreshPianoBtn(btn, index)
	local store = gStoreManager:GetStoreGroup("SInstrumentsPianoTemplateStore"):GetStoreByWidget(btn)

	if store then
		local data = self.listData[index + 1]
		store.btnType = data.btnType
		store.hasPCKey = data.hasPCKey and 1 or 0

		if data.hasPCKey then
			local cfg = InputSGUIPCKeyConfig.GetConfig(data.PCKeyId)

			if cfg then
				store.PCKey = cfg.Name

				btn:SetPCKeyInfoWithOutTip(data.PCKeyId)
				btn:SetPCKeyTipShowTip(false)
			end
		end

		store.type = data.type
	end
end

function M:ClickNote(btn, csIndex, data)
	if data == nil then
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

	if table.contains(self.leftHandPos, data.BelongArea.hand) then
		gGamePlayPianoManager.piano_lastNoteTime = gCS.MyPlayerManager.PlayerUnit.time
		gGamePlayPianoManager.piano_curLeftHandPosType = data.BelongArea.hand
		gGamePlayPianoManager.piano_curLeftHandWeight = data.BelongArea.weight
		gGamePlayPianoManager.piano_curCheckType = 0

		gGamePlayTransitionMgr:CheckSwitchAction()

		gGamePlayPianoManager.piano_lastLeftHandWeight = gGamePlayPianoManager.piano_curLeftHandWeight
		gGamePlayPianoManager.piano_curLeftHandPosType = 0
	elseif table.contains(self.rightHandPos, data.BelongArea.hand) then
		gGamePlayPianoManager.piano_lastNoteTime = gCS.MyPlayerManager.PlayerUnit.time
		gGamePlayPianoManager.piano_curRightHandPosType = data.BelongArea.hand
		gGamePlayPianoManager.piano_curRightHandWeight = data.BelongArea.weight
		gGamePlayPianoManager.piano_curCheckType = 0

		gGamePlayTransitionMgr:CheckSwitchAction()

		gGamePlayPianoManager.piano_lastRightHandWeight = gGamePlayPianoManager.piano_curRightHandWeight
		gGamePlayPianoManager.piano_curRightHandPosType = 0
	end

	local soundData = gSoundMgr:CreateSoundData(data.AudioID)

	if soundData then
		self.audioNidList[data.AudioID] = gSoundMgr:PlaySoundByData(soundData, nil, function ()
			self.delayTime = InstrumentConfig.LoopActionDelayTime.pianoDelayTime / 1000
		end)
	end
end

function M:ClickNoteUp(btn, csIndex, data)
	if data == nil then
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

function M:InitCameraData()
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
	local camName = "PianoCamera" .. index
	local cm = cmRegister:GetVcamByName(camName)

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetFixCameraData(cm.gameObject, worldPos, worldEuler, data.fov)
	cmRegister:EnableVCamera(camName, LX6.Cinemachine.EVcamPriority.Panel)
end

function M:OnRightRotateInput(context)
	local input = context:ReadValueVector2()

	if not self.instance.joystickRTriggered then
		local threshold = InstrumentConfig.PianoJoystickTriggerThreshold

		if threshold < input.x * input.x + input.y * input.y then
			self.instance.joystickRTriggered = true
			self.rightPressId = 0

			self.bindData.controllerAngleR:SetActive(true)
		else
			return
		end
	end

	if context.performed then
		local threshold = InstrumentConfig.PianoJoystickMoveThreshold

		if threshold > input.x * input.x + input.y * input.y then
			return
		end

		local inputVal = input * 20
		self.rightRotateParam = inputVal
		local rot = self:CalcRotAngle(self.rightRotateParam)
		self.controllerAngleRTrans.localRotation = Quaternion.Euler(0, 0, 360 - rot)
		local rightPressId = self:CalcPressButtonIndex(rot)

		if rightPressId ~= self.rightPressId then
			local data = self.curPageNotes[self.rightPressId]

			if data then
				self:ClickNoteUp(nil, nil, data)

				self.bindData["PressStateR" .. self.rightPressId] = 0
			end

			self.rightPressId = rightPressId

			self:OnRightClickNote(self.rightPressId)

			if self.rightPressId ~= nil then
				self.bindData["PressStateR" .. self.rightPressId] = 1
			end
		end
	end

	if context.canceled then
		self.instance.joystickRTriggered = false

		self.bindData.controllerAngleR:SetActive(false)

		self.rightRotateParam = nil

		if self.rightPressId ~= nil then
			local data = self.curPageNotes[self.rightPressId]

			self:ClickNoteUp(nil, nil, data)

			self.bindData["PressStateR" .. self.rightPressId] = 0
			self.rightPressId = nil
		end
	end
end

function M:OnLeftRotateInput(context)
	local input = context:ReadValueVector2()

	if not self.instance.joystickLTriggered then
		local threshold = InstrumentConfig.PianoJoystickTriggerThreshold

		if threshold < input.x * input.x + input.y * input.y then
			self.instance.joystickLTriggered = true
			self.leftPressId = 0

			self.bindData.controllerAngleL:SetActive(true)
		else
			return
		end
	end

	if context.performed then
		local threshold = InstrumentConfig.PianoJoystickMoveThreshold

		if threshold > input.x * input.x + input.y * input.y then
			return
		end

		local inputVal = input * 20
		self.leftRotateParam = inputVal
		local rot = self:CalcRotAngle(self.leftRotateParam)
		self.controllerAngleLTrans.localRotation = Quaternion.Euler(0, 0, 360 - rot)
		local leftPressId = self:CalcPressButtonIndex(rot)

		if self.leftPressId ~= leftPressId then
			local data = {
				AudioID = InstrumentConfig.PianoChordAudioID[self.leftPressId]
			}

			if data.AudioID then
				self:ClickNoteUp(nil, nil, data)

				self.bindData["PressStateL" .. self.leftPressId] = 0
			end

			self.leftPressId = leftPressId

			self:OnLeftClickNote(self.leftPressId)

			if self.leftPressId ~= nil then
				self.bindData["PressStateL" .. self.leftPressId] = 1
			end
		end
	end

	if context.canceled then
		self.instance.joystickLTriggered = false

		self.bindData.controllerAngleL:SetActive(false)

		if self.leftPressId ~= nil then
			local data = {
				AudioID = InstrumentConfig.PianoChordAudioID[self.leftPressId]
			}

			self:ClickNoteUp(nil, nil, data)

			self.bindData["PressStateL" .. self.leftPressId] = 0
			self.leftPressId = nil
		end

		self.leftRotateParam = nil
	end
end

function M:OnSwitchPageBtnClick(data)
	if self.rightPressId then
		local data = self.curPageNotes[self.rightPressId]

		if data then
			self:ClickNoteUp(nil, nil, data)
		end
	end

	if self.page == nil then
		self.page = 1
	elseif data then
		if data == 0 then
			self.page = self.page - 1
		else
			self.page = self.page + 1
		end
	end

	if self.page > 3 then
		self.page = 1
	end

	if self.page < 1 then
		self.page = 3
	end

	self.bindData.painoPage = self.page - 1
	self.curPageNotes = self.gamePadItemList[self.page]

	print("page = " .. self.page)

	self.bindData.PagePiano = self.page

	if table.isNilOrEmpty(self.curPageNotes) then
		print_error("gamePadItemList is nil")
	end
end

function M:OnLeftClickNote(index)
	print("leftClickNote" .. index)

	local audioId = InstrumentConfig.PianoChordAudioID[index]

	if audioId ~= nil then
		local soundData = gSoundMgr:CreateSoundData(audioId)

		if soundData then
			self.audioNidList[audioId] = gSoundMgr:PlaySoundByData(soundData, nil, function (uuid)
				return
			end)
		end
	end
end

function M:OnRightClickNote(index)
	print("rightClickNote" .. index)
	self:ClickNote(nil, nil, self.curPageNotes[index])
end

function M:CalcRotAngle(rotateParam)
	local x = rotateParam.x
	local y = rotateParam.y
	local rot = math.deg(math.atan2(x, y))

	if rot < 0 then
		rot = rot + 360
	end

	return rot
end

function M:CalcPressButtonIndex(rot)
	return math.floor((rot + 22.5) / 45) % 8 + 1
end
