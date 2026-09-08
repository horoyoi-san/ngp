-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PinHaoBanSelectPanelStore.lua
-- Decompiled from: 00839_PinHaoBanSelectPanelStore.lua_29a4dc61c20d.luajit

C_PinHaoBanSelectPanelStore = DefClass("C_PinHaoBanSelectPanelStore", C_PinHaoBanSelectPanelStore, C_StoreGroup)
GroupName2Class.PinHaoBanSelectPanelStore = C_PinHaoBanSelectPanelStore
local M = C_PinHaoBanSelectPanelStore
local Input = UnityEngine.Input
local GameDevice = SGUI.GameDevice
local UCursorInput = SGUI.UCursorInput
local PinHaoBanDefine = LX6.Share.PinhaobanDefine
local Rigidbody = UnityEngine.Rigidbody
local PHBSlot = LX6.Share.PHBSlot
local PoiGameConfig = LTConfig.PoiGameConfig
local Screen = UnityEngine.Screen
local SoundConfig = LTConfig.SoundConfig
local GameInputManager = LX6.Manager.GameInputManager
local freeTimer = 0
local enterRotateTimer = 0

M.OnAwake = function(self)
	self.bindData.ConfirmBtnClick = self:CreateAction("OnConfirm")
	self.bindData.FakeSelectBtn.luaClick = self:CreateAction("OnSelect")
	self.bindData.PadCancelBtn.luaClick = self:CreateAction("OnCancelSelect")
	self.bindData.SelectBtn.luaBeginDrag = self:CreateAction("OnBeginDrag")
	self.bindData.SelectBtn.luaDrag = self:CreateAction("OnDrag")
	self.bindData.SelectBtn.luaEndDrag = self:CreateAction("OnEndDrag")
	self.bindData.slotHover0.luaHover = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.headSlot)
	self.bindData.slotHover0.luaUnhover = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.headSlot)
	self.bindData.slotHover1.luaHover = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.handSlot)
	self.bindData.slotHover1.luaUnhover = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.handSlot)
	self.bindData.slotHover2.luaHover = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.shoulderSlot)
	self.bindData.slotHover2.luaUnhover = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.shoulderSlot)
	self.bindData.slotHover0.luaFocus = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.headSlot)
	self.bindData.slotHover0.luaBlur = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.headSlot)
	self.bindData.slotHover1.luaFocus = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.handSlot)
	self.bindData.slotHover1.luaBlur = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.handSlot)
	self.bindData.slotHover2.luaFocus = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.shoulderSlot)
	self.bindData.slotHover2.luaBlur = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.shoulderSlot)
	UCursorInput.onCursorPosChange = self:CreateAction("onCursorPosChange")
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.WKey.luaBeginLongPress = self.CreateActionWithArgs(self, "OnPressBegin", 2)
		self.bindData.WKey.luaEndLongPress = self.CreateActionWithArgs(self, "OnPressEnd", 2)
		self.bindData.SKey.luaBeginLongPress = self.CreateActionWithArgs(self, "OnPressBegin", 1)
		self.bindData.SKey.luaEndLongPress = self.CreateActionWithArgs(self, "OnPressEnd", 1)
		self.bindData.AKey.luaBeginLongPress = self.CreateActionWithArgs(self, "OnPressBegin", 3)
		self.bindData.AKey.luaEndLongPress = self.CreateActionWithArgs(self, "OnPressEnd", 3)
		self.bindData.DKey.luaBeginLongPress = self.CreateActionWithArgs(self, "OnPressBegin", 4)
		self.bindData.DKey.luaEndLongPress = self.CreateActionWithArgs(self, "OnPressEnd", 4)
	end

	self.hasSetHoverPos = false
	self.rotateSpeed = 40
	self.rotationCooldown = 0.1
	self.shakeDuration = 0.15
	self.shakeIntensity = 1.5
	self.isRotating = false
	self.isShaking = false
	self.rotationTimer = 0
	self.shakeTimer = 0
	self.targetRotation = nil
	self.mobileDragPrePos = nil
	self.mobileDragOffset = nil
	self.isMobilePlatform = not gCS.LuaUtils.IsNonMobileAdaptive()

	if gCS.CameraDataMgr.MainCamera then
		self.camera = gCS.CameraDataMgr.MainCamera
	end

	self.clipName = "S_vx_PinhaobanHoverButton"
	self.hoverAnimName = {
		"\\x9d3%\\xb7\\xaa\\xf1\\xe0Ҧ\\xe5\\xe6\\xdbr\\xe8\\xf9\\xb9\\x8c'\\xbb+\\x94\\xa9\\xd1ì\\xe9",
		"0ّ=/\\xfeT,\\xb1\\x8a&A\\xb3w\\xb2r%\\xaa&\\xf2\\x93*\\x9f",
		"0ّ=/\\xfeT,\\xb1\\x8a&A\\xb3w\\xb2r%\\xaa&\\xf2\\x93*\\x9c",
		"0ّ=/\\xfeT,\\xb1\\x8a&A\\xb3w\\xb2r%\\xaa&\\xf2\\x93*\\x9d"
	}
	slot1 = self.bindData.hoverAnim0
	self.openDuration = slot1:GetClip(self.hoverAnimName[1]).length
	self.msgEvents = {
		[gEventConstants.PINHAOBAN_ZOOM_IN] = self:CreateAction("ZoomIn"),
		[gEventConstants.PINHAOBAN_ZOOM_OUT] = self:CreateAction("ZoomOut"),
		[gEventConstants.PINHAOBAN_HIDE_SCENE_GO] = self:CreateAction("HideSceneGo"),
		[gEventConstants.PINHAOBAN_UI_CHANGE] = self:CreateAction("OnLoopCheck"),
		[gEventConstants.DIALOG_END] = self:CreateAction("DialogEnd")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device

	if self.hoverLoopSoundId then
		gSoundMgr:StopSoundByNid(self.hoverLoopSoundId)

		self.hoverLoopSoundId = nil
	end

	if self.soundDragId then
		gSoundMgr:StopSoundByNid(self.soundDragId)

		self.soundDragId = nil
	end

	if not self.gamepadMode then
		self.bindData.selectBtnActive = true
	else
		self.bindData.selectBtnActive = false
	end

	if self.enterStick then
		local slot = gPinHaoBanManager:GetSlotByIndex(self.selectedItem.installedSlotIndex)
		local tween = slot.gameObject:GetComponent(typeof(TweenRotation))

		if self.curSlotFromLocalRot then
			tween.from = Vector3.New(self.curSlotFromLocalRot.x, self.curSlotFromLocalRot.y, self.curSlotFromLocalRot.z)
			tween.to = Vector3.New(self.curSlotFromLocalRot.x, self.curSlotFromLocalRot.y + 6, self.curSlotFromLocalRot.z)
		end

		tween.enabled = false

		self.RecoverItemLogicState(self)
		self.OnRealEndDrag(self)
	end

	if self.enterRotate or self.enterStick then
		return
	end

	if self.selectedItem then
		self.ItemBackToInitPos(self)

		if self.currentSelectedRealGo then
			self.currentSelectedRealGo = nil
		end
	end
end

M.OnDestroy = function(self)
	if self.rotateSoundId then
		gSoundMgr:StopSoundByNid(self.rotateSoundId)
	end

	self.ClearMessageEvents(self)
end

M.OnLoopCheck = function(self)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navigationArea
	self.canShowUI = true

	if gPinHaoBanManager.slotCount ~= 3 and self.isZoomOut then
		local showDialog2003 = true

		for i, v in pairs(gPinHaoBanManager.slotContainer) do
			if v == -1 then
				self.bindData["slotHover" .. i].gameObject:SetActive(false)
			else
				self.bindData["slotHover" .. i].gameObject:SetActive(true)
			end

			if v ~= gPinHaoBanManager.itemIndexMap.headGo then
				showDialog2003 = showDialog2003 and false
			end
		end

		if showDialog2003 then
			local param = gDialogManager:CreateDialogParam()
			param.speakGo = gPinHaoBanManager.headGo.gameObject
			local taskId = gTaskNodeManager:GetNowDoingTask()

			if taskId == 0 then
				param.TaskId = taskId
			end

			slot4 = gDialogManager

			slot4:ShowGeneralDialog(gPinHaoBanManager.dialog2[2].dialog, gDialogSource.InteractGame, nil, param, function (_, _, state)
				gPinHaoBanManager.timer2 = 0

				self:GoToEndBtn()
			end)
		else
			self.GoToEndBtn(self)
		end
	end
end

M.ResetCursorPosition = function(self)
	self.currentCursorPos = Vector3.New(Screen.width / 2, Screen.height / 2, 0)

	UCursorInput.ResetCursorPos()
end

M.OnShow = function(self)
	GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay, true, UnityEngine.CursorLockMode.Confined)
	self:Init()
	self:ResetCursorPosition()
	self.bindData.PadCancelBtn:SetActive(false)

	local taskId = gTaskNodeManager:GetNowDoingTask()

	if taskId == 0 then
		self.curTaskInfo, self.taskTargetList, self.nowTargetIndex = gTaskNodeManager:GetTaskCounterInfo(taskId)

		if self.curTaskInfo ~= nil then
			self.bindData.taskDes = ""
		else
			self.bindData.taskDes = self.curTaskInfo.WorkDescription
		end
	else
		self.bindData.taskDes = ""
	end
end

M.OnClose = function(self)
	GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.Gameplay)
end

M.ZoomIn = function(self)
	enterRotateTimer = 0
	freeTimer = 0
	self.canShowUI = true
	self.canHover = false
	self.isZoomIn = true
	self.isZoomOut = false
end

M.ZoomOut = function(self, eventId, data)
	enterRotateTimer = 0
	freeTimer = 0

	if not gPinHaoBanManager.hasGoToEnd then
		self.canHover = true
	else
		self.canHover = false
	end

	if gPinHaoBanManager.slotCount == 3 then
		self.canShowUI = true
	else
		self.canHover = false
		self.canShowUI = false
	end

	if self.enterRotate then
		self.enterRotate = false
	end

	self.isZoomIn = false
	self.isZoomOut = true

	if data then
		self:Init()

		self.canShowUI = false

		gPinHaoBanManager:ShowOrHideItems(true)
		gPinHaoBanManager:InitData()
		gPinHaoBanManager:InitSlots(false)
	end

	local showDialog2004 = false
	local showWrongHead = false
	local showWrongArmHand = false

	for i, v in pairs(gPinHaoBanManager.slotContainer) do
		if v == -1 then
			self.bindData["slotHover" .. i].gameObject:SetActive(false)
		else
			self.bindData["slotHover" .. i].gameObject:SetActive(true)
		end

		showDialog2004 = showDialog2004 or v ~= gPinHaoBanManager.itemIndexMap.toiletGo and gPinHaoBanManager.hasShowOnceDialog2 ~= false
		showWrongHead = showWrongHead or v ~= gPinHaoBanManager.itemIndexMap.headGo and i == v
		showWrongArmHand = showWrongArmHand or v ~= gPinHaoBanManager.itemIndexMap.armGo and i == v or v ~= gPinHaoBanManager.itemIndexMap.handGo and i == v
	end

	if gPinHaoBanManager.hasGoToEnd then
		return
	end

	if showDialog2004 then
		local param = gDialogManager:CreateDialogParam()
		param.speakGo = gPinHaoBanManager.headGo.gameObject
		local taskId = gTaskNodeManager:GetNowDoingTask()

		if taskId == 0 then
			param.TaskId = taskId
		end

		slot8 = gDialogManager

		slot8:ShowGeneralDialog(gPinHaoBanManager.dialog2[1].dialog, gDialogSource.InteractGame, nil, param, function ()
			gPinHaoBanManager.hasShowOnceDialog2 = true
		end)
	elseif showWrongHead then
		gPinHaoBanManager:ShowDialog2(3)
	elseif showWrongArmHand then
		gPinHaoBanManager:ShowDialog2(4)
	elseif gPinHaoBanManager.slotCount == 0 then
		gPinHaoBanManager:ShowDialog2(5)
	end
end

M.HideSceneGo = function(self, eventId, data)
	gPinHaoBanManager:ShowOrHideItems(false)
end

M.OnSelect = function(self)
	if not self.gamepadMode then
		return
	end

	if not self.selectedItem then
		self.OnRealBeginDrag(self)
	elseif self.selectedItem and self.isOnHover then
		self.OnRealEndDrag(self)
	end
end

M.OnCancelSelect = function(self)
	if not self.gamepadMode then
		return
	end

	if self.enterStick then
		self.EnterStickNotSuccess(self, self.selectedItem.installedSlotIndex)

		if self.enterStick then
			self.canShowUI = true
			self.canHover = true
			self.enterStick = false
		end

		if self.selectedItem then
			if gPinHaoBanManager.canShowDialog3 and self.selectedItem.index ~= gPinHaoBanManager.itemIndexMap.headGo then
				gPinHaoBanManager.canShowDialog3 = false
			end

			self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).velocity = Vector3.zero
			local slotIndex = self.selectedItem.installedSlotIndex

			if slotIndex == -1 then
				local slot = gPinHaoBanManager:GetSlotByIndex(slotIndex)
				local tween = slot.gameObject:GetComponent(typeof(TweenRotation))

				tween:ResetToBeginning()

				tween.enabled = false
				slot.transform.localRotation = gPinHaoBanManager.slotOriginalRotation[slotIndex]
			end

			self.selectedItem = nil
		end

		return
	end

	if self.selectedItem then
		self.OnRealEndDrag(self, true)
	end
end

M.OnBeginDrag = function(self, eventPointer)
	if self.gamepadMode then
		return
	end

	self.OnRealBeginDrag(self)
end

M.onCursorPosChange = function(self, position)
	local rect = UCursorInput.Inst.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height
	local worldPos = rect.parent:TransformPoint(Vector3.New(position.x - width / 2, position.y - height / 2, 0))
	local pos = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
	self.currentCursorPos = Vector3.New(pos.x, pos.y, 0)

	if self.gamepadMode and self.selectedItem then
		self.OnRealDrag(self)
	end
end

M.OnRealBeginDrag = function(self)
	if gPinHaoBanManager.hasGoToEnd then
		return
	end

	if self.enterRotate then
		if self.isMobilePlatform then
			self.mobileDragPrePos = Input.mousePosition
		end

		return
	end

	gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)

	if self.currentSelectedRealGo and not gCS.LuaUtils.IsNull(self.currentSelectedRealGo) then
		if self.currentSelectedRealGo.installedSlotIndex ~= -1 then
			self.canHover = false

			self.HandleItemSelectEffect(self)
		else
			self:HandleCancelSelectEffect()

			self.enterStick = true
			local slot = gPinHaoBanManager:GetSlotByIndex(self.currentSelectedRealGo.installedSlotIndex)
			self.curSlotFromLocalRot = slot.transform.localRotation:ToEulerAngles()
			self.beginStickOutPos = self.pos
			self.canShowUI = false
			self.canHover = false
		end
	end

	if not self.currentSelectedRealGo or not self.selectedItem then
		return
	end

	if self.selectedItem.installedSlotIndex == -1 then
		return
	end

	self.enterDrag = true

	if self.gamepadMode then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_ImportantButton", LX6.Audio.ExternalSourceType.Motion_2D)
	end

	self.bindData.PadCancelBtn:SetActive(true)

	freeTimer = 0

	for i = 1, 3 do
		self.ResetAnimation(self, self.GetHoverAnim(self, i - 1), self.hoverAnimName[3])
	end
end

M.OnDrag = function(self, eventPointer)
	if self.gamepadMode then
		return
	end

	self.OnRealDrag(self)
end

M.EnterStickNotSuccess = function(self, slotIndex)
	local slot = gPinHaoBanManager:GetSlotByIndex(slotIndex)
	local tween = slot.gameObject:GetComponent(typeof(TweenRotation))

	if self.curSlotFromLocalRot then
		tween.from = Vector3.New(self.curSlotFromLocalRot.x, self.curSlotFromLocalRot.y, self.curSlotFromLocalRot.z)
		tween.to = Vector3.New(self.curSlotFromLocalRot.x, self.curSlotFromLocalRot.y + 6, self.curSlotFromLocalRot.z)
	end

	local onFinished = function()
		tween.enabled = false
	end

	tween.enabled = true

	tween:SetOnFinished(onFinished)
	tween:PlayForward()

	self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = true
end

M.OnRealDrag = function(self)
	if self.enterRotate and self.isMobilePlatform then
		self.mobileDragOffset = Input.mousePosition - self.mobileDragPrePos

		if math.abs(self.mobileDragOffset.x) >= 0.1 and math.abs(self.mobileDragOffset.y) >= 0.1 then
			self.mobileDragOffset = nil
		end

		return
	end

	if not self.soundDragId then
		self.soundDragId = gSoundMgr:PlaySoundByExternalSource("ExHandle_LoadingLoop", LX6.Audio.ExternalSourceType.Motion_2D)
	end

	if self.enterStick then
		local slotIndex = self.selectedItem.installedSlotIndex

		if slotIndex == -1 then
			local slot = gPinHaoBanManager:GetSlotByIndex(slotIndex)
			local tween = slot.gameObject:GetComponent(typeof(TweenRotation))

			if not self:CheckPulloutSuccess() then
				if self.curSlotFromLocalRot then
					tween.from = Vector3.New(self.curSlotFromLocalRot.x, self.curSlotFromLocalRot.y, self.curSlotFromLocalRot.z)
					tween.to = Vector3.New(self.curSlotFromLocalRot.x, self.curSlotFromLocalRot.y + 6, self.curSlotFromLocalRot.z)
				end

				local onFinished = function()
					tween.enabled = false
				end

				tween.enabled = true

				tween:SetOnFinished(onFinished)
				tween:PlayForward()

				self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = true

				return
			end

			tween:ResetToBeginning()

			tween.enabled = false
			slot.transform.localRotation = gPinHaoBanManager.slotOriginalRotation[slotIndex]

			gSoundMgr:PlaySoundByTid(SoundConfig.phb_Off)
			gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBUninstall)
			self.bindData.PadCancelBtn:SetActive(true)

			for i = 1, 3 do
				self.ResetAnimation(self, self.GetHoverAnim(self, i - 1), self.hoverAnimName[3])
			end

			for i = 1, 4 do
				local item = gPinHaoBanManager:GetItemByIndex(i - 1).gameObject

				if item:GetComponent(typeof(PinHaoBanDefine)).installedSlotIndex == -1 then
					item:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(true)
				else
					item:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(false)
				end

				if self.selectedItem.index == i - 1 then
					item.GetComponent(item, typeof(Rigidbody)).isKinematic = true
				else
					item.GetComponent(item, typeof(Rigidbody)).isKinematic = false
				end
			end

			self:RecoverItemLogicState()

			self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = false
			self.enterDrag = true
			self.enterStick = false
			freeTimer = 0
			self.canShowUI = true
		end
	end

	if not self.enterDrag or not self.selectedItem then
		return
	end

	for i = 1, 4 do
		local item = gPinHaoBanManager:GetItemByIndex(i - 1).gameObject

		if item:GetComponent(typeof(PinHaoBanDefine)).installedSlotIndex == -1 then
			item:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(true)
		else
			item:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(false)
		end

		if self.selectedItem.index == i - 1 then
			item.GetComponent(item, typeof(Rigidbody)).isKinematic = true
		else
			item.GetComponent(item, typeof(Rigidbody)).isKinematic = false
		end
	end

	self.selectedItem:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(false)

	self.itemScreenPos = self.camera:WorldToScreenPoint(self.selectedItem.transform.position)
	local screenSpace = Vector3.New(self.pos.x, self.pos.y, self.itemScreenPos.z)

	if not self.cursorScreenSpace then
		self.cursorScreenSpace = screenSpace
	end

	self.cursorScreenSpace = screenSpace
	self.cursorWorldPos = self.camera:ScreenToWorldPoint(self.cursorScreenSpace)
	self.selectedItem.m_EnterDrag = true
	self.selectedItem.cursorWorldPos = self.cursorWorldPos
end

M.OnRealEndDrag = function(self, isConfirmExit)
	if self.soundDragId then
		gSoundMgr:StopSoundByNid(self.soundDragId)

		self.soundDragId = nil
	end

	if self.enterStick then
		self.canShowUI = true
		self.canHover = true
		self.enterStick = false
	end

	if self.selectedItem then
		if gPinHaoBanManager.canShowDialog3 and self.selectedItem.index ~= gPinHaoBanManager.itemIndexMap.headGo then
			gPinHaoBanManager.canShowDialog3 = false
		end

		self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).velocity = Vector3.zero
		local slotIndex = self.selectedItem.installedSlotIndex

		if slotIndex == -1 then
			local slot = gPinHaoBanManager:GetSlotByIndex(slotIndex)
			local tween = slot.gameObject:GetComponent(typeof(TweenRotation))

			tween:ResetToBeginning()

			tween.enabled = false
			slot.transform.localRotation = gPinHaoBanManager.slotOriginalRotation[slotIndex]
		end
	end

	if not self.enterDrag then
		return
	end

	self.bindData.PadCancelBtn:SetActive(false)

	freeTimer = 0
	self.curSlotFromLocalRot = nil

	if self.curHoverSlotIndex and self.isOnHover and not isConfirmExit then
		gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBInstall)
		self:OnStickTo()
	else
		self.PlayReturnSoundByIndex(self, self.selectedItem.index)
		self.ItemBackToInitPos(self)
	end

	if self.currentSelectedRealGo then
		self.currentSelectedRealGo = nil
	end
end

M.ItemBackToInitPos = function(self)
	local itemIndex = self.selectedItem.index
	self.selectedItem.installedSlotIndex = -1

	self.selectedItem:SetRotationLimitAngle(false)
	self.selectedItem:SetRotationLimitData(Vector3.zero)

	self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = true
	local initPos, initRot = gPinHaoBanManager:GetInitPosRot(itemIndex)

	if initPos and initRot then
		gPinHaoBanManager:GetItemByIndex(itemIndex).transform:SetPosition(initPos.x, initPos.y, initPos.z)

		gPinHaoBanManager:GetItemByIndex(itemIndex).transform.rotation = Quaternion.Euler(initRot.x, initRot.y, initRot.z)

		if self.preSelectedItemUUID then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedItemUUID)
		end

		if self.preSelectedSlotUUID then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedSlotUUID)
		end

		self.selectedItem.m_EnterDrag = false

		for i = 1, 4 do
			gPinHaoBanManager:GetItemByIndex(i - 1).gameObject:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(true)

			gPinHaoBanManager:GetItemByIndex(i - 1).gameObject:GetComponent(typeof(Rigidbody)).isKinematic = false
		end

		self.selectedItem.transform:SetParent(gPinHaoBanManager.sceneNodeGo.transform)
		self.selectedItem.transform:SetPosition(initPos.x, initPos.y, initPos.z)

		self.selectedItem.transform.rotation = Quaternion.Euler(initRot.x, initRot.y, initRot.z)
		self.selectedItem = nil
		self.enterDrag = false
		self.selectedSlot = nil
		self.curHoverSlotIndex = nil
		self.canShowUI = true
		self.canHover = true
	end
end

M.OnEndDrag = function(self, eventPointer)
	if self.gamepadMode then
		return
	end

	if self.isMobilePlatform then
		self.mobileDragInitPos = nil
		self.mobileDragOffset = nil
	end

	self.OnRealEndDrag(self)
end

M.CheckPulloutSuccess = function(self)
	return Vector3.Distance(self.pos, self.beginStickOutPos) < 300
end

M.Init = function(self)
	self.curRotateLoopId = nil
	gPinHaoBanManager.hasGoToEnd = false
	freeTimer = 0
	enterRotateTimer = 0
	gPinHaoBanManager.timer1 = 0
	gPinHaoBanManager.timer2 = 0
	gPinHaoBanManager.timer3 = 0
	gPinHaoBanManager.timer45 = 0
	gPinHaoBanManager.hasShowOnceDialog1 = false
	gPinHaoBanManager.hasShowOnceDialog2 = false
	gPinHaoBanManager.canShowDialog1 = false
	gPinHaoBanManager.canShowDialog2 = false
	gPinHaoBanManager.canShowDialog3 = false
	gPinHaoBanManager.canShowDialog45 = false
	gPinHaoBanManager.canShowDialog67 = false
	self.rotateSoundId = nil
	self.soundDragId = nil
	self.hoverLoopSoundId = nil
	self.hasPadFocus = false
	self.hover0Hovering = false
	self.hover1Hovering = false
	self.hover2Hovering = false
	self.hover0Timer = nil
	self.hover1Timer = nil
	self.hover2Timer = nil
	self.begin0 = false
	self.begin1 = false
	self.begin2 = false
	self.isZoomIn = false
	self.isZoomOut = false
	self.selectedItem = nil
	self.selectedSlot = nil
	self.selectedCancelItem = nil

	self.bindData.ConfirmBtn.gameObject:SetActive(false)

	self.curRotateIndex = nil
	self.enterDrag = false
	self.XRotationInput = 0
	self.YRotationInput = 0
	self.enterRotate = false
	self.curHoverSlotIndex = nil
	self.canShowUI = true
	self.canHover = true
	self.selectedItemIndex = nil
	self.enterStick = false
	self.itemScreenPos = nil
	self.cursorScreenSpace = nil
	self.cursorWorldPos = nil

	self:ResetCursorPosition()

	for i, v in pairs(gPinHaoBanManager.slotIndexMap) do
		if not self.hasSetHoverPos then
			local slot = gPinHaoBanManager:GetSlotByIndex(v)
			local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(slot.transform.position, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
			local UIPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.RootRect, Vector3.New(x, y, 0))

			self.bindData["rectHover" .. v]:SetLocalPosition(UIPos)
		end

		self.bindData["slotHover" .. v].gameObject:SetActive(false)
	end

	if not self.hasSetHoverPos then
		self.hasSetHoverPos = true
	end

	self.bindData.rotateImg.gameObject:SetActive(false)
	self:SetWASDEnable(false)
end

M.UpdateDialog1 = function(self)
	if gPinHaoBanManager.timer1 <= 0 then
		gPinHaoBanManager.timer1 = gPinHaoBanManager.timer1 - Time.deltaTime
		gPinHaoBanManager.canShowDialog1 = false
	else
		gPinHaoBanManager.canShowDialog1 = true
	end
end

M.UpdateDialog2 = function(self)
	if gPinHaoBanManager.timer2 <= 0 then
		gPinHaoBanManager.timer2 = gPinHaoBanManager.timer2 - Time.deltaTime
		gPinHaoBanManager.canShowDialog2 = false
	else
		gPinHaoBanManager.canShowDialog2 = true
	end
end

M.UpdateDialog3 = function(self)
	if gPinHaoBanManager.timer3 <= 0 then
		gPinHaoBanManager.timer3 = gPinHaoBanManager.timer3 - Time.deltaTime
	elseif not gPinHaoBanManager.hasGoToEnd then
		gPinHaoBanManager:ShowDialog3()
	end
end

M.UpdateDialog45 = function(self)
	if gPinHaoBanManager.timer45 <= 0 then
		gPinHaoBanManager.timer45 = gPinHaoBanManager.timer45 - Time.deltaTime
		gPinHaoBanManager.canShowDialog45 = false
	else
		gPinHaoBanManager.canShowDialog45 = true
	end
end

M.SetWASDEnable = function(self, enable)
	self.bindData.WKey.gameObject:SetActive(enable)
	self.bindData.AKey.gameObject:SetActive(enable)
	self.bindData.SKey.gameObject:SetActive(enable)
	self.bindData.DKey.gameObject:SetActive(enable)
	self.bindData.controllerImgs:SetActive(enable)
end

M.NotEnterRotateUpdateTimer = function(self)
	if self.canHover and not self.enterRotate and self.canShowUI and not self.enterDrag then
		freeTimer = freeTimer + Time.deltaTime

		if freeTimer > 7 then
			slot1 = gPinHaoBanManager

			slot1:ShowFreeDialog(3, function ()
				freeTimer = 0
			end)
		end
	end

	if self.enterDrag and not self.enterStick and not self.enterRotate and self.selectedItem then
		freeTimer = freeTimer + Time.deltaTime

		if freeTimer > 5 then
			slot1 = gPinHaoBanManager

			slot1:ShowFreeDialog(self.selectedItem.index, function ()
				freeTimer = 0
			end)
		end
	end
end

M.EnterRotateUpdateTimer = function(self)
	if self.enterRotate and not self.curRotateIndex then
		enterRotateTimer = enterRotateTimer + Time.deltaTime

		if enterRotateTimer > 10 then
			slot1 = gPinHaoBanManager

			slot1:ShowEnterRotateFreeDialog(function ()
			end)

			enterRotateTimer = 0
		end
	end
end

M.OnUpdate = function(self)
	self.NotEnterRotateUpdateTimer(self)
	self.EnterRotateUpdateTimer(self)
	self.UpdateDialog1(self)
	self.UpdateDialog2(self)
	self.UpdateDialog3(self)
	self.UpdateDialog45(self)

	if gPinHaoBanManager.slotCount ~= 3 and self.isZoomOut then
		self.bindData.ConfirmBtn.gameObject:SetActive(false)

		self.bindData.leftControlActive = false

		self.bindData.SelectBtn.gameObject:SetActive(false)

		return
	end

	if self.canShowUI then
		if self.enterRotate then
			self.HideOrShowHover(self, false)

			self.bindData.leftControlActive = false
			self.bindData.fakeSelectBtnActive = false

			if not self.isMobilePlatform then
				self.bindData.SelectBtn.gameObject:SetActive(false)
			else
				self.bindData.SelectBtn.gameObject:SetActive(true)
			end

			if self.gamepadMode then
				self.bindData.PadCancelBtn.gameObject:SetActive(false)
			end

			self.bindData.rotateImg.gameObject:SetActive(true)
			self.bindData.ConfirmBtn.gameObject:SetActive(true)
			self:SetWASDEnable(true)
		else
			if not self.hasGoToEnd then
				if self.isZoomIn then
					self.bindData.leftControlActive = false
					self.bindData.fakeSelectBtnActive = false

					self.bindData.PadCancelBtn.gameObject:SetActive(false)
				else
					self.bindData.leftControlActive = true
					self.bindData.fakeSelectBtnActive = true

					self.bindData.PadCancelBtn.gameObject:SetActive(true)
				end

				if self.gamepadMode then
					self.bindData.PadCancelBtn.gameObject:SetActive(true)
				end
			end

			self.bindData.SelectBtn.gameObject:SetActive(true)
			self:HideOrShowHover(true)
			self.bindData.rotateImg.gameObject:SetActive(false)
			self.bindData.ConfirmBtn.gameObject:SetActive(false)
			self:SetWASDEnable(false)
		end
	else
		self.bindData.leftControlActive = false
		self.bindData.fakeSelectBtnActive = false

		if self.enterStick then
			self.bindData.PadCancelBtn.gameObject:SetActive(true)
		else
			self.bindData.PadCancelBtn.gameObject:SetActive(false)
		end

		if self.gamepadMode then
			self.bindData.SelectBtn.gameObject:SetActive(false)
			self.bindData.ConfirmBtn.gameObject:SetActive(false)
			self:SetWASDEnable(false)
		end

		self:HideOrShowHover(false)
		self.bindData.ConfirmBtn.gameObject:SetActive(false)
		self.bindData.rotateImg.gameObject:SetActive(false)
		self:SetWASDEnable(false)
	end

	if not self.gamepadMode then
		self.pos = Input.mousePosition
	else
		self.pos = self.currentCursorPos
	end

	if self.pos and self.enterDrag then
		return
	end

	if not self.enterRotate and self.canHover and not gPinHaoBanManager.hasGoToEnd and not self.enterDrag then
		local hitInfo = gCS.LuaUtils.PinHaoBanGetUIToCameraHit(self.pos)

		if hitInfo.collider == nil then
			local hitGo = hitInfo.collider.transform

			if hitGo == nil then
				local hitRealGo = self.IsAimGos(self, hitGo)

				if not hitRealGo then
					if gPinHaoBanManager.preHoverUUID then
						gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)
					end

					gPinHaoBanManager.preHover = nil

					self.ClearEffects(self)

					self.currentSelectedRealGo = nil
					self.currentSelectedIndex = nil

					return
				end

				self.currentSelectedRealGo = hitRealGo
				self.currentSelectedIndex = self.currentSelectedRealGo.index
			else
				if gPinHaoBanManager.preHoverUUID then
					gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)
				end

				gPinHaoBanManager.preHover = nil
				self.currentSelectedRealGo = nil
				self.currentSelectedIndex = nil
			end
		else
			if gPinHaoBanManager.preHoverUUID then
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)
			end

			gPinHaoBanManager.preHover = nil

			self.ClearEffects(self)

			self.currentSelectedRealGo = nil
			self.currentSelectedIndex = nil
		end
	end

	if not self.enterRotate then
		return
	end

	if self.camera then
		if self.isMobilePlatform then
			self.XRotationInput = 0
			self.YRotationInput = 0

			if self.mobileDragOffset then
				local xOffset = self.mobileDragOffset.x
				local yOffset = self.mobileDragOffset.y

				if math.abs(yOffset) >= math.abs(xOffset) then
					if xOffset <= 0 then
						self.YRotationInput = -1
					else
						self.YRotationInput = 1
					end
				elseif yOffset <= 0 then
					self.XRotationInput = 1
				else
					self.XRotationInput = -1
				end
			end
		else
			self.XRotationInput = 0
			self.YRotationInput = 0

			if self.curRotateIndex then
				if self.curRotateIndex ~= 1 then
					self.XRotationInput = -1
				end

				if self.curRotateIndex ~= 2 then
					self.XRotationInput = 1
				end

				if self.curRotateIndex ~= 3 then
					self.YRotationInput = 1
				end

				if self.curRotateIndex ~= 4 then
					self.YRotationInput = -1
				end
			end
		end

		local rotationAxis = Vector3.zero
		local rotationAngle = 0

		if self.XRotationInput == 0 then
			rotationAxis = self.camera.transform.right
			rotationAngle = self.XRotationInput * PoiGameConfig.PHB_Rotate
		elseif self.YRotationInput == 0 then
			rotationAxis = self.camera.transform.up
			rotationAngle = self.YRotationInput * PoiGameConfig.PHB_Rotate
		end

		if self.XRotationInput == 0 or self.YRotationInput == 0 then
			gSoundMgr:PlaySoundByTid(SoundConfig.phb_Rotate)

			if self.selectedItem.installedSlotIndex == self.selectedItem.index then
				gPinHaoBanManager:ShowDialog45(false)
			else
				gPinHaoBanManager:ShowDialog45(true)
			end

			self.selectedItem.transform:RotateAround(self.selectedItem.transform.position, rotationAxis, rotationAngle)

			self.rotationTimer = 0

			self:StartShakeAnimation()
		end
	end
end

M.GetClampAngle = function(self, angle)
	if angle <= 360 then
		angle = angle - 360
	elseif angle >= 0 then
		angle = angle + 360
	end

	return angle
end

M.SignedAngle = function(self, v1, v2, axis)
	local angle = Vector3.Angle(v1, v2)
	local sign = Mathf.Sign(Vector3.Dot(axis, Vector3.Cross(v1, v2)))

	return angle * sign
end

M.CheckAngle = function(self, q, q1, q2, n)
	local v = q * Vector3.forward
	v = v - Vector3.Multiple(n, Vector3.Dot(v, n))
	local v1 = q1 * Vector3.forward
	local v2 = q2 * Vector3.forward
	local normal = Vector3.Cross(v1, v2)
	local angle = self.GetClampAngle(self, self.SignedAngle(self, v1, v2, normal))
	local signedAngle = self.GetClampAngle(self, self.SignedAngle(self, v1, v, normal))

	if angle >= Mathf.Abs(signedAngle) then
		return true
	end
end

M.RotationExceed = function(self, newRotation, limitRotation, parentTransform)
	local q = newRotation

	if limitRotation.limitX then
		local q1 = Quaternion.Euler(limitRotation.XLimit.x, 0, 0)
		local q2 = Quaternion.Euler(limitRotation.XLimit.y, 0, 0)

		if self.CheckAngle(self, q, q1, q2, Vector3.right) then
			return true
		end
	end

	if limitRotation.limitY then
		local q1 = Quaternion.Euler(0, limitRotation.YLimit.x, 0)
		local q2 = Quaternion.Euler(0, limitRotation.YLimit.y, 0)

		if self.CheckAngle(self, q, q1, q2, Vector3.up) then
			return true
		end
	end

	if limitRotation.limitZ then
		local q1 = Quaternion.Euler(0, 0, limitRotation.ZLimit.x)
		local q2 = Quaternion.Euler(0, 0, limitRotation.ZLimit.y)

		if self.CheckAngle(self, q, q1, q2, Vector3.forward) then
			return true
		end
	end

	return false
end

M.StartShakeAnimation = function(self)
	if self.isShaking then
		return
	end

	local originalRotation = self.selectedItem.transform.localRotation
	local tween = self.selectedItem.gameObject:GetComponent(typeof(TweenRotation))

	if tween then
		tween.ResetToBeginning(tween)

		tween.enabled = true
		local shakeDuration = self.shakeDuration
		local shakeIntensity = self.shakeIntensity
		local randomShake = Vector3.New(math.random(-shakeIntensity, shakeIntensity), math.random(-shakeIntensity, shakeIntensity), math.random(-shakeIntensity, shakeIntensity))
		tween.from = originalRotation.eulerAngles
		tween.to = originalRotation.eulerAngles + randomShake
		tween.duration = shakeDuration / 2
		tween.method = 2

		local onFinished = function()
			if self.selectedItem then
				self.selectedItem.transform.localRotation = originalRotation
			end

			self.isShaking = false
			tween.enabled = false
		end

		tween.SetOnFinished(tween, onFinished)
		tween.PlayForward(tween)

		self.isShaking = true
	end
end

M.OnConfirm = function(self)
	if self.enterRotate then
		self.OnInstall(self)

		return
	end
end

M.OnStickTo = function(self)
	if self.hoverLoopSoundId then
		gSoundMgr:StopSoundByNid(self.hoverLoopSoundId)

		self.hoverLoopSoundId = nil
	end

	if self.isOnHover then
		self.isOnHover = false
	end

	self.selectedSlot = gPinHaoBanManager:GetSlotByIndex(self.curHoverSlotIndex)
	self.selectedItem.installedSlotIndex = self.curHoverSlotIndex

	self.selectedItem.gameObject:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(true)

	self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = true

	self.selectedItem:SetRotationLimitAngle(true)

	self.selectedItem.m_EnterDrag = false
	self.enterDrag = false
	gPinHaoBanManager.slotContainer[self.curHoverSlotIndex] = self.selectedItem.index

	self.bindData["slotHover" .. self.curHoverSlotIndex].gameObject:SetActive(false)

	if not self.selectedSlot then
		return
	end

	self:HideOrShowHover(false)
	self.bindData.rotateImg.gameObject:SetActive(false)
	self:SetWASDEnable(false)
	self.selectedItem.transform:SetParent(self.selectedSlot.transform)
	self.selectedItem.transform:SetLocalPosition(0, 0, 0)

	local rot = gPinHaoBanManager:GetInstalledRot(self.selectedItem.installedSlotIndex, self.selectedItem.index + 1)
	self.selectedItem.transform.localRotation = Quaternion.Euler(rot.x, rot.y, rot.z)
	local axis = self.selectedSlot.gameObject:GetComponent(typeof(PHBSlot)):GetAxis()

	self.selectedItem:SetRotationLimitData(axis)
	gTimelineManager:Timeline_JumpTo(gPinHaoBanManager:GetTLName(), self:GetTimelineClipName(true))
	gSoundMgr:PlaySoundByTid(SoundConfig.phb_On)

	gPinHaoBanManager.timer45 = 0
	gPinHaoBanManager.slotCount = gPinHaoBanManager.slotCount + 1
	self.enterRotate = true

	SGUI.UCursorInput.Inst.SetCursorDisplay(false)

	self.canShowUI = false

	self:ClearEffects()
end

M.GoToEndBtn = function(self)
	if not gPinHaoBanManager.hasGoToEnd then
		gPinHaoBanManager.hasGoToEnd = true

		if gDialogManager:IsDialogRunning() then
			return
		end

		self.RealGoToEnd(self)
	end
end

M.DialogEnd = function(self)
	if gPinHaoBanManager.hasGoToEnd then
		self.RealGoToEnd(self)
	end
end

M.RealGoToEnd = function(self)
	for i, v in pairs(gPinHaoBanManager.slotContainer) do
		if i == v then
			self.HandleFailCondition(self)

			return
		end
	end

	if self.CheckAllItemsCorrect(self) then
		self:HideAllItems(false)
		print_debug("拼好板跳转到02_A1_01")
		gTimelineManager:Timeline_JumpTo(gPinHaoBanManager:GetTLName(), "02_A1_01")
		gPanelManager:Close(gPanelId.PINHAOBAN_SELECT_PANEL)
		gPinHaoBanManager:ClearData()

		gPinHaoBanManager.curData = nil
	else
		self.HandleFailCondition(self)
	end
end

M.HandleFailCondition = function(self)
	print_debug("拼好板跳转到02_A2")
	gTimelineManager:Timeline_JumpTo(gPinHaoBanManager:GetTLName(), "02_A2")
	gPinHaoBanManager:ClearLogicData()

	self.canHover = false
	self.canShowUI = false

	if gPinHaoBanManager.preHoverUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)
	end

	if self.preSelectedItemUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedItemUUID)
	end
end

M.CheckAllItemsCorrect = function(self)
	for i = 1, 3 do
		local item = gPinHaoBanManager:GetItemByIndex(i - 1).gameObject:GetComponent(typeof(PinHaoBanDefine))
		local itemIndex = item.index

		if self:RotationExceed(item.transform.localRotation, gPinHaoBanManager.successLimit[itemIndex], item.transform:GetParent()) then
			return false
		end
	end

	return true
end

M.HideAllItems = function(self)
	gPinHaoBanManager.headGo.gameObject:SetActive(false)
	gPinHaoBanManager.armGo.gameObject:SetActive(false)
	gPinHaoBanManager.handGo.gameObject:SetActive(false)

	for i = 1, 4 do
		gPinHaoBanManager:GetItemByIndex(i - 1).gameObject:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(true)
	end
end

M.IsAimGos = function(self, transform)
	if transform == nil then
		local item, index = gPinHaoBanManager:GetItemGoIndex(transform)

		if not item then
			if gPinHaoBanManager.preHoverUUID then
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)
			end

			gPinHaoBanManager.preHover = nil

			return
		end

		if item and gPinHaoBanManager.preHover == item then
			if gPinHaoBanManager.preHoverUUID then
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)
			end

			gSoundMgr:PlaySoundByExternalSource("ExHandle_click_03", LX6.Audio.ExternalSourceType.Motion_2D)

			gPinHaoBanManager.preHoverUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, LX6.Effect.EffectPlayTag.Gameplay, "PinHaoBanGameSelect_" .. tostring(type) .. tostring(index), item.gameObject)
			gPinHaoBanManager.preHover = item
		end

		return item
	end

	if gPinHaoBanManager.preHover == nil then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)

		gPinHaoBanManager.preHoverUUID = nil
		gPinHaoBanManager.preHover = nil
	end
end

M.HandleItemSelectEffect = function(self)
	local nextItemGo = self.currentSelectedRealGo

	if not nextItemGo then
		return
	end

	self.selectedItem = nextItemGo

	if self.preSelectedItemUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedItemUUID)
	end

	self.preSelectedItemUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610836, LX6.Effect.EffectPlayTag.Gameplay, "pinhaobanItemSelect_" .. tostring(self.currentSelectedIndex), self.selectedItem.gameObject)
	self.selectedItemIndex = self.currentSelectedIndex

	self:HandleDialog1()

	if gPinHaoBanManager.preHover == nil then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)

		gPinHaoBanManager.preHoverUUID = nil
		gPinHaoBanManager.preHover = nil
	end
end

M.HandleDialog1 = function(self)
	if gPinHaoBanManager.hasGoToEnd then
		return
	end

	if self.currentSelectedIndex ~= gPinHaoBanManager.itemIndexMap.toiletGo and not gPinHaoBanManager.hasShowOnceDialog1 then
		gPinHaoBanManager:ShowDialog1(1)
	elseif self.currentSelectedIndex ~= gPinHaoBanManager.itemIndexMap.headGo then
		gPinHaoBanManager:ShowDialog1(2)
	end
end

M.HandleCancelSelectEffect = function(self)
	local nextItemGo = self.currentSelectedRealGo

	if not nextItemGo then
		return
	end

	self.selectedItem = nextItemGo
	self.selectedItemIndex = self.currentSelectedIndex

	if self.preSelectedItemUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedItemUUID)
	end

	self.preSelectedItemUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610836, LX6.Effect.EffectPlayTag.Gameplay, "pinhaobanItemSelect_" .. tostring(self.currentSelectedIndex), self.selectedItem.gameObject)

	if gPinHaoBanManager.preHover == nil then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)

		gPinHaoBanManager.preHoverUUID = nil
		gPinHaoBanManager.preHover = nil
	end
end

M.OnHover = function(self, slotIndex)
	if not self.selectedItem then
		self.SetHoverAnimIsHovering(self, slotIndex, false)

		return
	end

	if self.curHoverSlotIndex == slotIndex then
		self.curHoverSlotIndex = slotIndex

		if self.soundDragId then
			gSoundMgr:StopSoundByNid(self.soundDragId)

			self.soundDragId = nil
		end

		if not self.hoverLoopSoundId then
			self.hoverLoopSoundId = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)
		end

		self.isOnHover = true
	end

	self:SetHoverAnimIsHovering(slotIndex, true)

	if not self:GetHoverAnim(slotIndex):IsPlaying(self.hoverAnimName[4]) then
		gCS.LuaUtils.PlayAnimationByName(self.GetHoverAnim(self, slotIndex), self.hoverAnimName[4])
	end

	self.bindData["slotHover" .. slotIndex].gameObject:SetActive(true)

	self.enterInner = true
end

M.OnUnHover = function(self, slotIndex)
	if self.curHoverSlotIndex and self.curHoverSlotIndex ~= slotIndex then
		self.curHoverSlotIndex = nil
		self.isOnHover = false

		if self.hoverLoopSoundId then
			gSoundMgr:StopSoundByNid(self.hoverLoopSoundId)

			self.hoverLoopSoundId = nil
		end
	end

	self:SetHoverAnimIsHovering(slotIndex, false)
	self:GetHoverAnim(slotIndex):Stop()

	self.outInner = true
end

M.RecoverItemLogicState = function(self)
	gPinHaoBanManager.slotContainer[self.selectedItem.installedSlotIndex] = -1

	self.bindData["slotHover" .. self.selectedItem.installedSlotIndex].gameObject:SetActive(true)

	gPinHaoBanManager.slotCount = gPinHaoBanManager.slotCount - 1
	self.selectedItem.installedSlotIndex = -1
end

M.OnPressBegin = function(self, index)
	if not self.enterRotate then
		return
	end

	enterRotateTimer = 0
	self.curRotateIndex = index

	self.PlayRotateLoopSound(self, self.selectedItem.index)
end

M.OnPressEnd = function(self, index)
	if not self.enterRotate then
		return
	end

	enterRotateTimer = 0
	self.curRotateIndex = nil

	gSoundMgr:StopSoundByNid(self.curRotateLoopId)

	self.curRotateLoopId = nil
end

M.GetTimelineClipName = function(self, isEnter)
	if not self.selectedSlot then
		return
	end

	local selectedSlotIndex = self.selectedSlot.gameObject:GetComponent(typeof(PHBSlot)).slotIndex

	if selectedSlotIndex ~= 0 then
		if isEnter then
			return "01_C1"
		end

		return "C2"
	end

	if selectedSlotIndex ~= 1 then
		if isEnter then
			return "01_A1"
		end

		return "A2"
	end

	if selectedSlotIndex ~= 2 then
		if isEnter then
			return "01_B1"
		end

		return "B2"
	end
end

M.OnInstall = function(self)
	self.selectedItem:SetRotationLimitAngle(false)
	gTimelineManager:Timeline_JumpTo(gPinHaoBanManager:GetTLName(), self:GetTimelineClipName(false))

	local isCorrect = self.selectedItem.index ~= self.selectedItem.installedSlotIndex

	gPinHaoBanManager:ShowDialog67(isCorrect)
	SGUI.UCursorInput.Inst.SetCursorDisplay(true)
	SGUI.UCursorInput.StopCursorSnap()

	self.canShowUI = false
	self.canHover = false
	self.selectedSlot = nil
	self.selectedItem = nil
	self.selectedCancelItem = nil
	self.enterRotate = false
	self.curHoverSlotIndex = nil
	gPinHaoBanManager.preHover = nil

	self:ClearEffects()
end

M.GetHoverAnim = function(self, index)
	if index ~= 0 then
		return self.bindData.hoverAnim0
	elseif index ~= 1 then
		return self.bindData.hoverAnim1
	else
		return self.bindData.hoverAnim2
	end

	return nil
end

M.GetRectHover = function(self, index)
	if index ~= 0 then
		return self.bindData.rectHover0
	elseif index ~= 1 then
		return self.bindData.rectHover1
	else
		return self.bindData.rectHover2
	end

	return nil
end

M.GetSlotHover = function(self, index)
	if index ~= 0 then
		return self.bindData.slotHover0
	elseif index ~= 1 then
		return self.bindData.slotHover1
	else
		return self.bindData.slotHover2
	end

	return nil
end

M.HoverAnimIsHovering = function(self, index)
	if index ~= 0 then
		return self.hover0Hovering
	elseif index ~= 1 then
		return self.hover1Hovering
	else
		return self.hover2Hovering
	end
end

M.SetHoverAnimIsHovering = function(self, index, enable)
	if index ~= 0 then
		self.hover0Hovering = enable
	elseif index ~= 1 then
		self.hover1Hovering = enable
	else
		self.hover2Hovering = enable
	end
end

M.GetHoverHoverAnimOpenTimer = function(self, index)
	if index ~= 0 then
		return self.hover0Timer
	elseif index ~= 1 then
		return self.hover1Timer
	else
		return self.hover2Timer
	end
end

M.SetHoverHoverAnimOpenTimer = function(self, index, timer)
	if index ~= 0 then
		self.hover0Timer = timer
	elseif index ~= 1 then
		self.hover1Timer = timer
	else
		self.hover2Timer = timer
	end
end

M.GetBegin = function(self, index)
	if index ~= 0 then
		return self.begin0
	elseif index ~= 1 then
		return self.begin1
	else
		return self.begin2
	end
end

M.SetBegin = function(self, index, value)
	if index ~= 0 then
		self.begin0 = value
	elseif index ~= 1 then
		self.begin1 = value
	else
		self.begin2 = value
	end
end

M.HideOrShowHover = function(self, isActive)
	for i, v in pairs(gPinHaoBanManager.slotContainer) do
		local isSlotOccupied = gPinHaoBanManager.slotContainer[i] == -1

		if isSlotOccupied or isActive ~= false then
			self:GetRectHover(i).gameObject:SetActive(false)
		elseif self.pos and self.pos then
			local slotScreenPos = self.camera:WorldToScreenPoint(gPinHaoBanManager:GetSlotByIndex(i).gameObject.transform.position)
			local UIDis = gUtils:ScreenToUIPosition(self.pos) - gUtils:ScreenToUIPosition(slotScreenPos)
			local dis = gUtils:MagnitudeVector2(UIDis.x, UIDis.y)

			if self.selectedItem and not self.HoverAnimIsHovering(self, i) then
				self:GetRectHover(i).gameObject:SetActive(true)
				self:GetSlotHover(i).gameObject:SetActive(true)

				if not self:GetHoverAnim(i):IsPlaying(self.hoverAnimName[3]) then
					gCS.LuaUtils.PlayAnimationByName(self.GetHoverAnim(self, i), self.hoverAnimName[3])
				end
			elseif dis <= 300 then
				self:SetBegin(i, false)
				self:GetRectHover(i).gameObject:SetActive(false)
				self:SetHoverAnimIsHovering(i, false)
			elseif dis > 0 and dis >= 300 then
				self:GetRectHover(i).gameObject:SetActive(isActive)
				self:GetSlotHover(i).gameObject:SetActive(isActive)

				if isActive then
					if not self.selectedItem and not self.HoverAnimIsHovering(self, i) and not self:GetHoverAnim(i):IsPlaying(self.hoverAnimName[1]) and not self:GetHoverAnim(i):IsPlaying(self.hoverAnimName[1]) and not self.GetHoverHoverAnimOpenTimer(self, i) then
						if not self.GetBegin(self, i) then
							gCS.LuaUtils.PlayAnimationByName(self.GetHoverAnim(self, i), self.hoverAnimName[1])
							self.SetBegin(self, i, true)
						end

						local timer = Timer.New(function ()
							self:SetHoverHoverAnimOpenTimer(i, nil)
							gCS.LuaUtils.PlayAnimationByName(self:GetHoverAnim(i), self.hoverAnimName[2])
						end, self.openDuration):Start()

						self:SetHoverHoverAnimOpenTimer(i, timer)
					end
				else
					self.SetBegin(self, i, false)
					self.SetHoverAnimIsHovering(self, i, false)
				end
			end
		end
	end
end

M.ClearEffects = function(self)
	if self.preSelectedCancelItemUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedCancelItemUUID)
	end

	if self.preSelectedSlotUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedSlotUUID)
	end

	if self.preSelectedItemUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedItemUUID)
	end

	if gPinHaoBanManager.preHoverUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)
	end
end

M.ResetAnimation = function(self, animation, clipName)
	local animationState = animation.get_Item(animation, clipName)

	animation.Play(animation, clipName)

	animationState.time = 0
	animationState.enabled = true

	animation.Sample(animation)

	animationState.enabled = false
end

M.PlayRotateLoopSound = function(self, index)
	if self.curRotateLoopId then
		return
	end

	if index ~= 0 then
		self.curRotateLoopId = gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBHeadRotate)
	elseif index ~= 3 then
		self.curRotateLoopId = gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBToiletRotate)
	else
		self.curRotateLoopId = gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBArmRotate)
	end
end

M.PlayReturnSoundByIndex = function(self, index)
	if index ~= 0 then
		gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBHeadReturn)
	elseif index ~= 3 then
		gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBToiletReturn)
	else
		gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBArmReturn)
	end
end
