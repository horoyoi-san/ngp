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
local SoundEventConfig = LTConfig.SoundEventConfig
local SoundConfig = LTConfig.SoundConfig
local freeTimer = 0
local enterRotateTimer = 0

function M:OnAwake()
	self.bindData.ConfirmBtnClick = self:CreateAction("OnConfirm")
	self.bindData.FakeSelectBtn.luaClick = self:CreateAction("OnSelect")
	self.bindData.PadCancelBtn.luaClick = self:CreateAction("OnCancelSelect")
	self.bindData.SelectBtn.luaBeginDrag = self:CreateAction("OnBeginDrag")
	self.bindData.SelectBtn.luaDrag = self:CreateAction("OnDrag")
	self.bindData.SelectBtn.luaEndDrag = self:CreateAction("OnEndDrag")
	self.bindData.slotHover0.luaHover = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.headSlot)
	self.bindData.slotHover0.luaUnhover = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.headSlot)
	self.bindData.slotHover0.luaClick = self:CreateAction("OnHoverSelect")
	self.bindData.slotHover1.luaHover = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.handSlot)
	self.bindData.slotHover1.luaUnhover = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.handSlot)
	self.bindData.slotHover1.luaClick = self:CreateAction("OnHoverSelect")
	self.bindData.slotHover2.luaHover = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.shoulderSlot)
	self.bindData.slotHover2.luaUnhover = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.shoulderSlot)
	self.bindData.slotHover2.luaClick = self:CreateAction("OnHoverSelect")
	self.bindData.slotHover0.luaFocus = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.headSlot)
	self.bindData.slotHover0.luaBlur = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.headSlot)
	self.bindData.slotHover1.luaFocus = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.handSlot)
	self.bindData.slotHover1.luaBlur = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.handSlot)
	self.bindData.slotHover2.luaFocus = self:CreateActionWithArgs("OnHover", gPinHaoBanManager.slotIndexMap.shoulderSlot)
	self.bindData.slotHover2.luaBlur = self:CreateActionWithArgs("OnUnHover", gPinHaoBanManager.slotIndexMap.shoulderSlot)
	UCursorInput.onCursorPosChange = self:CreateAction("onCursorPosChange")
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.WKey.luaBeginLongPress = self:CreateActionWithArgs("OnPressBegin", 2)
		self.bindData.WKey.luaEndLongPress = self:CreateActionWithArgs("OnPressEnd", 2)
		self.bindData.SKey.luaBeginLongPress = self:CreateActionWithArgs("OnPressBegin", 1)
		self.bindData.SKey.luaEndLongPress = self:CreateActionWithArgs("OnPressEnd", 1)
		self.bindData.AKey.luaBeginLongPress = self:CreateActionWithArgs("OnPressBegin", 3)
		self.bindData.AKey.luaEndLongPress = self:CreateActionWithArgs("OnPressEnd", 3)
		self.bindData.DKey.luaBeginLongPress = self:CreateActionWithArgs("OnPressBegin", 4)
		self.bindData.DKey.luaEndLongPress = self:CreateActionWithArgs("OnPressEnd", 4)
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
		"S_vx_PinhaobanHoverButton1_open",
		"S_vx_PinhaobanHoverButton1",
		"S_vx_PinhaobanHoverButton2",
		"S_vx_PinhaobanHoverButton3"
	}
	self.openDuration = self.bindData.hoverAnim0:GetClip(self.hoverAnimName[1]).length
	self.msgEvents = {
		[gEventConstants.PINHAOBAN_ZOOM_IN] = self:CreateAction("ZoomIn"),
		[gEventConstants.PINHAOBAN_ZOOM_OUT] = self:CreateAction("ZoomOut"),
		[gEventConstants.PINHAOBAN_HIDE_SCENE_GO] = self:CreateAction("HideSceneGo"),
		[gEventConstants.PINHAOBAN_UI_CHANGE] = self:CreateAction("OnLoopCheck"),
		[gEventConstants.DIALOG_END] = self:CreateAction("DialogEnd")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device

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

		self:RecoverItemLogicState()
		self:OnRealEndDrag()
	end

	if self.enterRotate or self.enterStick then
		return
	end

	if self.selectedItem then
		self:ItemBackToInitPos()

		if self.currentSelectedRealGo then
			self.currentSelectedRealGo = nil
		end
	end
end

function M:OnDestroy()
	if self.rotateSoundId then
		gSoundMgr:StopSoundByNid(self.rotateSoundId)
	end

	self:ClearMessageEvents()
end

function M:OnLoopCheck()
	self.canShowUI = true

	if gPinHaoBanManager.slotCount == 3 and self.isZoomOut then
		local showDialog2003 = true

		for i, v in pairs(gPinHaoBanManager.slotContainer) do
			if v ~= -1 then
				self.bindData["slotHover" .. i].gameObject:SetActive(false)
			else
				self.bindData["slotHover" .. i].gameObject:SetActive(true)
			end

			if v == gPinHaoBanManager.itemIndexMap.headGo then
				showDialog2003 = showDialog2003 and false
			end
		end

		if showDialog2003 then
			local param = gDialogManager:CreateDialogParam()
			param.speakGo = gPinHaoBanManager.headGo.gameObject

			gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog2[2].dialog, gDialogSource.InteractGame, nil, param, function (_, _, state)
				gPinHaoBanManager.timer2 = 0

				self:GoToEndBtn()
			end)
		else
			self:GoToEndBtn()
		end
	end
end

function M:ResetCursorPosition()
	self.currentCursorPos = Vector3.New(Screen.width / 2, Screen.height / 2, 0)

	UCursorInput.ResetCursorPos()
end

function M:OnShow()
	self:Init()
	self:ResetCursorPosition()
	self.bindData.PadCancelBtn:SetActive(false)
end

function M:ZoomIn()
	enterRotateTimer = 0
	freeTimer = 0
	self.canShowUI = true
	self.canHover = false
	self.isZoomIn = true
	self.isZoomOut = false
end

function M:ZoomOut(eventId, data)
	enterRotateTimer = 0
	freeTimer = 0

	if not gPinHaoBanManager.hasGoToEnd then
		self.canHover = true
	else
		self.canHover = false
	end

	if gPinHaoBanManager.slotCount ~= 3 then
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
		if v ~= -1 then
			self.bindData["slotHover" .. i].gameObject:SetActive(false)
		else
			self.bindData["slotHover" .. i].gameObject:SetActive(true)
		end

		showDialog2004 = showDialog2004 or v == gPinHaoBanManager.itemIndexMap.toiletGo and gPinHaoBanManager.hasShowOnceDialog2 == false
		showWrongHead = showWrongHead or v == gPinHaoBanManager.itemIndexMap.headGo and i ~= v
		showWrongArmHand = showWrongArmHand or v == gPinHaoBanManager.itemIndexMap.armGo and i ~= v or v == gPinHaoBanManager.itemIndexMap.handGo and i ~= v
	end

	if gPinHaoBanManager.hasGoToEnd then
		return
	end

	if showDialog2004 then
		local param = gDialogManager:CreateDialogParam()
		param.speakGo = gPinHaoBanManager.headGo.gameObject

		gDialogManager:ShowGeneralDialog(gPinHaoBanManager.dialog2[1].dialog, gDialogSource.InteractGame, nil, param, function ()
			gPinHaoBanManager.hasShowOnceDialog2 = true
		end)
	elseif showWrongHead then
		gPinHaoBanManager:ShowDialog2(3)
	elseif showWrongArmHand then
		gPinHaoBanManager:ShowDialog2(4)
	elseif gPinHaoBanManager.slotCount ~= 0 then
		gPinHaoBanManager:ShowDialog2(5)
	end
end

function M:HideSceneGo(eventId, data)
	gPinHaoBanManager:ShowOrHideItems(false)
end

function M:OnSelect()
	if not self.gamepadMode then
		return
	end

	if not self.selectedItem then
		self:OnRealBeginDrag()
	elseif self.selectedItem and self.isOnHover then
		self:OnRealEndDrag()
	end
end

function M:OnCancelSelect()
	if not self.gamepadMode then
		return
	end

	if self.enterStick then
		self:EnterStickNotSuccess(self.selectedItem.installedSlotIndex)

		if self.enterStick then
			self.canShowUI = true
			self.canHover = true
			self.enterStick = false
		end

		if self.selectedItem then
			if gPinHaoBanManager.canShowDialog3 and self.selectedItem.index == gPinHaoBanManager.itemIndexMap.headGo then
				gPinHaoBanManager.canShowDialog3 = false
			end

			self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).velocity = Vector3.zero
			local slotIndex = self.selectedItem.installedSlotIndex

			if slotIndex ~= -1 then
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
		self:OnRealEndDrag(true)
	end
end

function M:OnBeginDrag(eventPointer)
	if self.gamepadMode then
		return
	end

	self:OnRealBeginDrag()
end

function M:onCursorPosChange(position)
	local rect = UCursorInput.Inst.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height
	local worldPos = rect.parent:TransformPoint(Vector3.New(position.x - width / 2, position.y - height / 2, 0))
	local pos = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
	self.currentCursorPos = Vector3.New(pos.x, pos.y, 0)

	if self.gamepadMode and self.selectedItem then
		self:OnRealDrag()
	end
end

function M:OnRealBeginDrag()
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
		if self.currentSelectedRealGo.installedSlotIndex == -1 then
			self.canHover = false

			self:HandleItemSelectEffect()
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

	if self.selectedItem.installedSlotIndex ~= -1 then
		return
	end

	self.enterDrag = true

	if self.gamepadMode then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_ImportantButton", LX6.Audio.ExternalSourceType.Motion_2D)
	end

	self.bindData.PadCancelBtn:SetActive(true)

	freeTimer = 0

	for i = 1, 3 do
		self:ResetAnimation(self:GetHoverAnim(i - 1), self.hoverAnimName[3])
	end
end

function M:OnDrag(eventPointer)
	if self.gamepadMode then
		return
	end

	self:OnRealDrag()
end

function M:EnterStickNotSuccess(slotIndex)
	local slot = gPinHaoBanManager:GetSlotByIndex(slotIndex)
	local tween = slot.gameObject:GetComponent(typeof(TweenRotation))

	if self.curSlotFromLocalRot then
		tween.from = Vector3.New(self.curSlotFromLocalRot.x, self.curSlotFromLocalRot.y, self.curSlotFromLocalRot.z)
		tween.to = Vector3.New(self.curSlotFromLocalRot.x, self.curSlotFromLocalRot.y + 6, self.curSlotFromLocalRot.z)
	end

	local function onFinished()
		tween.enabled = false
	end

	tween.enabled = true

	tween:SetOnFinished(onFinished)
	tween:PlayForward()

	self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).isKinematic = true
end

function M:OnRealDrag()
	if self.enterRotate and self.isMobilePlatform then
		self.mobileDragOffset = Input.mousePosition - self.mobileDragPrePos

		if math.abs(self.mobileDragOffset.x) < 0.1 and math.abs(self.mobileDragOffset.y) < 0.1 then
			self.mobileDragOffset = nil
		end

		return
	end

	if not self.soundDragId then
		self.soundDragId = gSoundMgr:PlaySoundByExternalSource("ExHandle_LoadingLoop", LX6.Audio.ExternalSourceType.Motion_2D)
	end

	if self.enterStick then
		local slotIndex = self.selectedItem.installedSlotIndex

		if slotIndex ~= -1 then
			local slot = gPinHaoBanManager:GetSlotByIndex(slotIndex)
			local tween = slot.gameObject:GetComponent(typeof(TweenRotation))

			if not self:CheckPulloutSuccess() then
				if self.curSlotFromLocalRot then
					tween.from = Vector3.New(self.curSlotFromLocalRot.x, self.curSlotFromLocalRot.y, self.curSlotFromLocalRot.z)
					tween.to = Vector3.New(self.curSlotFromLocalRot.x, self.curSlotFromLocalRot.y + 6, self.curSlotFromLocalRot.z)
				end

				local function onFinished()
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
				self:ResetAnimation(self:GetHoverAnim(i - 1), self.hoverAnimName[3])
			end

			for i = 1, 4 do
				local item = gPinHaoBanManager:GetItemByIndex(i - 1).gameObject

				if item:GetComponent(typeof(PinHaoBanDefine)).installedSlotIndex ~= -1 then
					item:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(true)
				else
					item:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(false)
				end

				if self.selectedItem.index ~= i - 1 then
					item:GetComponent(typeof(Rigidbody)).isKinematic = true
				else
					item:GetComponent(typeof(Rigidbody)).isKinematic = false
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

		if item:GetComponent(typeof(PinHaoBanDefine)).installedSlotIndex ~= -1 then
			item:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(true)
		else
			item:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(false)
		end

		if self.selectedItem.index ~= i - 1 then
			item:GetComponent(typeof(Rigidbody)).isKinematic = true
		else
			item:GetComponent(typeof(Rigidbody)).isKinematic = false
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

function M:OnRealEndDrag(isConfirmExit)
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
		if gPinHaoBanManager.canShowDialog3 and self.selectedItem.index == gPinHaoBanManager.itemIndexMap.headGo then
			gPinHaoBanManager.canShowDialog3 = false
		end

		self.selectedItem.gameObject:GetComponent(typeof(Rigidbody)).velocity = Vector3.zero
		local slotIndex = self.selectedItem.installedSlotIndex

		if slotIndex ~= -1 then
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
		self:PlayReturnSoundByIndex(self.selectedItem.index)
		self:ItemBackToInitPos()
	end

	if self.currentSelectedRealGo then
		self.currentSelectedRealGo = nil
	end
end

function M:ItemBackToInitPos()
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

function M:OnEndDrag(eventPointer)
	if self.gamepadMode then
		return
	end

	if self.isMobilePlatform then
		self.mobileDragInitPos = nil
		self.mobileDragOffset = nil
	end

	self:OnRealEndDrag()
end

function M:CheckPulloutSuccess()
	return Vector3.Distance(self.pos, self.beginStickOutPos) >= 300
end

function M:Init()
	self.curRotateLoopId = nil
	gPinHaoBanManager.hasGoToEnd = false
	freeTimer = 0
	enterRotateTimer = 0
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
	self.bindData.CancelBtn.gameObject:SetActive(false)

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

function M:UpdateDialog1()
	if gPinHaoBanManager.timer1 > 0 then
		gPinHaoBanManager.timer1 = gPinHaoBanManager.timer1 - Time.deltaTime
		gPinHaoBanManager.canShowDialog1 = false
	else
		gPinHaoBanManager.canShowDialog1 = true
	end
end

function M:UpdateDialog2()
	if gPinHaoBanManager.timer2 > 0 then
		gPinHaoBanManager.timer2 = gPinHaoBanManager.timer2 - Time.deltaTime
		gPinHaoBanManager.canShowDialog2 = false
	else
		gPinHaoBanManager.canShowDialog2 = true
	end
end

function M:UpdateDialog3()
	if gPinHaoBanManager.timer3 > 0 then
		gPinHaoBanManager.timer3 = gPinHaoBanManager.timer3 - Time.deltaTime
	elseif not gPinHaoBanManager.hasGoToEnd then
		gPinHaoBanManager:ShowDialog3()
	end
end

function M:UpdateDialog45()
	if gPinHaoBanManager.timer45 > 0 then
		gPinHaoBanManager.timer45 = gPinHaoBanManager.timer45 - Time.deltaTime
		gPinHaoBanManager.canShowDialog45 = false
	else
		gPinHaoBanManager.canShowDialog45 = true
	end
end

function M:SetWASDEnable(enable)
	self.bindData.WKey.gameObject:SetActive(enable)
	self.bindData.AKey.gameObject:SetActive(enable)
	self.bindData.SKey.gameObject:SetActive(enable)
	self.bindData.DKey.gameObject:SetActive(enable)
end

function M:NotEnterRotateUpdateTimer()
	if self.canHover and not self.enterRotate and self.canShowUI and not self.enterDrag then
		freeTimer = freeTimer + Time.deltaTime

		if freeTimer >= 7 then
			gPinHaoBanManager:ShowFreeDialog(3, function ()
				freeTimer = 0
			end)
		end
	end

	if self.enterDrag and not self.enterStick and not self.enterRotate and self.selectedItem then
		freeTimer = freeTimer + Time.deltaTime

		if freeTimer >= 5 then
			gPinHaoBanManager:ShowFreeDialog(self.selectedItem.index, function ()
				freeTimer = 0
			end)
		end
	end
end

function M:EnterRotateUpdateTimer()
	if self.enterRotate and not self.curRotateIndex then
		enterRotateTimer = enterRotateTimer + Time.deltaTime

		if enterRotateTimer >= 10 then
			gPinHaoBanManager:ShowEnterRotateFreeDialog(function ()
				return
			end)

			enterRotateTimer = 0
		end
	end
end

function M:OnUpdate()
	self:NotEnterRotateUpdateTimer()
	self:EnterRotateUpdateTimer()
	self:UpdateDialog1()
	self:UpdateDialog2()
	self:UpdateDialog3()
	self:UpdateDialog45()

	if gPinHaoBanManager.slotCount == 3 and self.isZoomOut then
		self.bindData.ConfirmBtn.gameObject:SetActive(false)

		self.bindData.leftControlActive = false

		self.bindData.SelectBtn.gameObject:SetActive(false)

		return
	end

	if self.canShowUI then
		if self.enterRotate then
			self:HideOrShowHover(false)

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

		if hitInfo.collider ~= nil then
			local hitGo = hitInfo.collider.transform

			if hitGo ~= nil then
				local hitRealGo = self:IsAimGos(hitGo)

				if not hitRealGo then
					if gPinHaoBanManager.preHoverUUID then
						gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)
					end

					gPinHaoBanManager.preHover = nil

					self:ClearEffects()

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

			self:ClearEffects()

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

				if math.abs(yOffset) < math.abs(xOffset) then
					if xOffset > 0 then
						self.YRotationInput = -1
					else
						self.YRotationInput = 1
					end
				elseif yOffset > 0 then
					self.XRotationInput = 1
				else
					self.XRotationInput = -1
				end
			end
		else
			self.XRotationInput = 0
			self.YRotationInput = 0

			if self.curRotateIndex then
				if self.curRotateIndex == 1 then
					self.XRotationInput = -1
				end

				if self.curRotateIndex == 2 then
					self.XRotationInput = 1
				end

				if self.curRotateIndex == 3 then
					self.YRotationInput = 1
				end

				if self.curRotateIndex == 4 then
					self.YRotationInput = -1
				end
			end
		end

		local rotationAxis = Vector3.zero
		local rotationAngle = 0

		if self.XRotationInput ~= 0 then
			rotationAxis = self.camera.transform.right
			rotationAngle = self.XRotationInput * PoiGameConfig.PHB_Rotate
		elseif self.YRotationInput ~= 0 then
			rotationAxis = self.camera.transform.up
			rotationAngle = self.YRotationInput * PoiGameConfig.PHB_Rotate
		end

		if self.XRotationInput ~= 0 or self.YRotationInput ~= 0 then
			gSoundMgr:PlaySoundByTid(SoundConfig.phb_Rotate)

			if self.selectedItem.installedSlotIndex ~= self.selectedItem.index then
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

function M:GetClampAngle(angle)
	if angle > 360 then
		angle = angle - 360
	elseif angle < 0 then
		angle = angle + 360
	end

	return angle
end

function M:SignedAngle(v1, v2, axis)
	local angle = Vector3.Angle(v1, v2)
	local sign = Mathf.Sign(Vector3.Dot(axis, Vector3.Cross(v1, v2)))

	return angle * sign
end

function M:CheckAngle(q, q1, q2, n)
	local v = q * Vector3.forward
	v = v - Vector3.Multiple(n, Vector3.Dot(v, n))
	local v1 = q1 * Vector3.forward
	local v2 = q2 * Vector3.forward
	local normal = Vector3.Cross(v1, v2)
	local angle = self:GetClampAngle(self:SignedAngle(v1, v2, normal))
	local signedAngle = self:GetClampAngle(self:SignedAngle(v1, v, normal))

	if angle < Mathf.Abs(signedAngle) then
		return true
	end
end

function M:RotationExceed(newRotation, limitRotation, parentTransform)
	local q = newRotation

	if limitRotation.limitX then
		local q1 = Quaternion.Euler(limitRotation.XLimit.x, 0, 0)
		local q2 = Quaternion.Euler(limitRotation.XLimit.y, 0, 0)

		if self:CheckAngle(q, q1, q2, Vector3.right) then
			return true
		end
	end

	if limitRotation.limitY then
		local q1 = Quaternion.Euler(0, limitRotation.YLimit.x, 0)
		local q2 = Quaternion.Euler(0, limitRotation.YLimit.y, 0)

		if self:CheckAngle(q, q1, q2, Vector3.up) then
			return true
		end
	end

	if limitRotation.limitZ then
		local q1 = Quaternion.Euler(0, 0, limitRotation.ZLimit.x)
		local q2 = Quaternion.Euler(0, 0, limitRotation.ZLimit.y)

		if self:CheckAngle(q, q1, q2, Vector3.forward) then
			return true
		end
	end

	return false
end

function M:StartShakeAnimation()
	if self.isShaking then
		return
	end

	local originalRotation = self.selectedItem.transform.localRotation
	local tween = self.selectedItem.gameObject:GetComponent(typeof(TweenRotation))

	if tween then
		tween:ResetToBeginning()

		tween.enabled = true
		local shakeDuration = self.shakeDuration
		local shakeIntensity = self.shakeIntensity
		local randomShake = Vector3.New(math.random(-shakeIntensity, shakeIntensity), math.random(-shakeIntensity, shakeIntensity), math.random(-shakeIntensity, shakeIntensity))
		tween.from = originalRotation.eulerAngles
		tween.to = originalRotation.eulerAngles + randomShake
		tween.duration = shakeDuration / 2
		tween.method = 2

		local function onFinished()
			if self.selectedItem then
				self.selectedItem.transform.localRotation = originalRotation
			end

			self.isShaking = false
			tween.enabled = false
		end

		tween:SetOnFinished(onFinished)
		tween:PlayForward()

		self.isShaking = true
	end
end

function M:OnConfirm()
	if self.enterRotate then
		self:OnInstall()

		return
	end
end

function M:OnStickTo()
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
	gTimelineManager:Timeline_JumpTo(gPinHaoBanManager.timelineName, self:GetTimelineClipName(true))
	gSoundMgr:PlaySoundByTid(SoundConfig.phb_On)

	gPinHaoBanManager.timer45 = 0
	gPinHaoBanManager.slotCount = gPinHaoBanManager.slotCount + 1
	self.enterRotate = true

	SGUI.UCursorInput.Inst.SetCursorDisplay(false)

	self.canShowUI = false

	self:ClearEffects()
end

function M:GoToEndBtn()
	if not gPinHaoBanManager.hasGoToEnd then
		gPinHaoBanManager.hasGoToEnd = true

		if gDialogManager:IsDialogRunning() then
			return
		end

		self:RealGoToEnd()
	end
end

function M:DialogEnd()
	if gPinHaoBanManager.hasGoToEnd then
		self:RealGoToEnd()
	end
end

function M:RealGoToEnd()
	for i, v in pairs(gPinHaoBanManager.slotContainer) do
		if i ~= v then
			self:HandleFailCondition()

			return
		end
	end

	if self:CheckAllItemsCorrect() then
		self:HideAllItems(false)
		print_debug("拼好板跳转到02_A1_01")
		gTimelineManager:Timeline_JumpTo(gPinHaoBanManager.timelineName, "02_A1_01")
		gPanelManager:Close(gPanelId.PINHAOBAN_SELECT_PANEL)
		gPinHaoBanManager:ClearData()
	else
		self:HandleFailCondition()
	end
end

function M:HandleFailCondition()
	print_debug("拼好板跳转到02_A2")
	gTimelineManager:Timeline_JumpTo(gPinHaoBanManager.timelineName, "02_A2")
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

function M:CheckAllItemsCorrect()
	for i = 1, 3 do
		local item = gPinHaoBanManager:GetItemByIndex(i - 1).gameObject:GetComponent(typeof(PinHaoBanDefine))
		local itemIndex = item.index

		if self:RotationExceed(item.transform.localRotation, gPinHaoBanManager.successLimit[itemIndex], item.transform:GetParent()) then
			return false
		end
	end

	return true
end

function M:HideAllItems()
	gPinHaoBanManager.headGo.gameObject:SetActive(false)
	gPinHaoBanManager.armGo.gameObject:SetActive(false)
	gPinHaoBanManager.handGo.gameObject:SetActive(false)

	for i = 1, 4 do
		gPinHaoBanManager:GetItemByIndex(i - 1).gameObject:GetComponent(typeof(PinHaoBanDefine)):SetTrigger(true)
	end
end

function M:IsAimGos(transform)
	if transform ~= nil then
		local item, index = gPinHaoBanManager:GetItemGoIndex(transform)

		if not item then
			if gPinHaoBanManager.preHoverUUID then
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)
			end

			gPinHaoBanManager.preHover = nil

			return
		end

		if item and gPinHaoBanManager.preHover ~= item then
			if gPinHaoBanManager.preHoverUUID then
				gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)
			end

			gSoundMgr:PlaySoundByExternalSource("ExHandle_click_03", LX6.Audio.ExternalSourceType.Motion_2D)

			gPinHaoBanManager.preHoverUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, "PinHaoBanGameSelect_" .. tostring(type) .. tostring(index), item.gameObject)
			gPinHaoBanManager.preHover = item
		end

		return item
	end

	if gPinHaoBanManager.preHover ~= nil then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)

		gPinHaoBanManager.preHoverUUID = nil
		gPinHaoBanManager.preHover = nil
	end
end

function M:HandleItemSelectEffect()
	local nextItemGo = self.currentSelectedRealGo

	if not nextItemGo then
		return
	end

	self.selectedItem = nextItemGo

	if self.preSelectedItemUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedItemUUID)
	end

	self.preSelectedItemUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610836, "pinhaobanItemSelect_" .. tostring(self.currentSelectedIndex), self.selectedItem.gameObject)
	self.selectedItemIndex = self.currentSelectedIndex

	self:HandleDialog1()

	if gPinHaoBanManager.preHover ~= nil then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)

		gPinHaoBanManager.preHoverUUID = nil
		gPinHaoBanManager.preHover = nil
	end
end

function M:HandleDialog1()
	if gPinHaoBanManager.hasGoToEnd then
		return
	end

	if self.currentSelectedIndex == gPinHaoBanManager.itemIndexMap.toiletGo and not gPinHaoBanManager.hasShowOnceDialog1 then
		gPinHaoBanManager:ShowDialog1(1)
	elseif self.currentSelectedIndex == gPinHaoBanManager.itemIndexMap.headGo then
		gPinHaoBanManager:ShowDialog1(2)
	end
end

function M:HandleCancelSelectEffect()
	local nextItemGo = self.currentSelectedRealGo

	if not nextItemGo then
		return
	end

	self.selectedItem = nextItemGo
	self.selectedItemIndex = self.currentSelectedIndex

	if self.preSelectedItemUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectedItemUUID)
	end

	self.preSelectedItemUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610836, "pinhaobanItemSelect_" .. tostring(self.currentSelectedIndex), self.selectedItem.gameObject)

	if gPinHaoBanManager.preHover ~= nil then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(gPinHaoBanManager.preHoverUUID)

		gPinHaoBanManager.preHoverUUID = nil
		gPinHaoBanManager.preHover = nil
	end
end

function M:OnHover(slotIndex)
	if not self.selectedItem then
		self:SetHoverAnimIsHovering(slotIndex, false)

		return
	end

	if self.curHoverSlotIndex ~= slotIndex then
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
		gCS.LuaUtils.PlayAnimationByName(self:GetHoverAnim(slotIndex), self.hoverAnimName[4])
	end

	self.bindData["slotHover" .. slotIndex].gameObject:SetActive(true)

	self.enterInner = true
end

function M:OnUnHover(slotIndex)
	if self.curHoverSlotIndex and self.curHoverSlotIndex == slotIndex then
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

function M:RecoverItemLogicState()
	gPinHaoBanManager.slotContainer[self.selectedItem.installedSlotIndex] = -1

	self.bindData["slotHover" .. self.selectedItem.installedSlotIndex].gameObject:SetActive(true)

	gPinHaoBanManager.slotCount = gPinHaoBanManager.slotCount - 1
	self.selectedItem.installedSlotIndex = -1
end

function M:OnPressBegin(index)
	if not self.enterRotate then
		return
	end

	enterRotateTimer = 0
	self.curRotateIndex = index

	self:PlayRotateLoopSound(self.selectedItem.index)
end

function M:OnPressEnd(index)
	if not self.enterRotate then
		return
	end

	enterRotateTimer = 0
	self.curRotateIndex = nil

	gSoundMgr:StopSoundByNid(self.curRotateLoopId)

	self.curRotateLoopId = nil
end

function M:GetTimelineClipName(isEnter)
	if not self.selectedSlot then
		return
	end

	local selectedSlotIndex = self.selectedSlot.gameObject:GetComponent(typeof(PHBSlot)).slotIndex

	if selectedSlotIndex == 0 then
		if isEnter then
			return "01_C1"
		end

		return "C2"
	end

	if selectedSlotIndex == 1 then
		if isEnter then
			return "01_A1"
		end

		return "A2"
	end

	if selectedSlotIndex == 2 then
		if isEnter then
			return "01_B1"
		end

		return "B2"
	end
end

function M:OnInstall()
	self.selectedItem:SetRotationLimitAngle(false)
	gTimelineManager:Timeline_JumpTo(gPinHaoBanManager.timelineName, self:GetTimelineClipName(false))

	local isCorrect = self.selectedItem.index == self.selectedItem.installedSlotIndex

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

function M:GetHoverAnim(index)
	if index == 0 then
		return self.bindData.hoverAnim0
	elseif index == 1 then
		return self.bindData.hoverAnim1
	else
		return self.bindData.hoverAnim2
	end

	return nil
end

function M:GetRectHover(index)
	if index == 0 then
		return self.bindData.rectHover0
	elseif index == 1 then
		return self.bindData.rectHover1
	else
		return self.bindData.rectHover2
	end

	return nil
end

function M:GetSlotHover(index)
	if index == 0 then
		return self.bindData.slotHover0
	elseif index == 1 then
		return self.bindData.slotHover1
	else
		return self.bindData.slotHover2
	end

	return nil
end

function M:HoverAnimIsHovering(index)
	if index == 0 then
		return self.hover0Hovering
	elseif index == 1 then
		return self.hover1Hovering
	else
		return self.hover2Hovering
	end
end

function M:SetHoverAnimIsHovering(index, enable)
	if index == 0 then
		self.hover0Hovering = enable
	elseif index == 1 then
		self.hover1Hovering = enable
	else
		self.hover2Hovering = enable
	end
end

function M:GetHoverHoverAnimOpenTimer(index)
	if index == 0 then
		return self.hover0Timer
	elseif index == 1 then
		return self.hover1Timer
	else
		return self.hover2Timer
	end
end

function M:SetHoverHoverAnimOpenTimer(index, timer)
	if index == 0 then
		self.hover0Timer = timer
	elseif index == 1 then
		self.hover1Timer = timer
	else
		self.hover2Timer = timer
	end
end

function M:GetBegin(index)
	if index == 0 then
		return self.begin0
	elseif index == 1 then
		return self.begin1
	else
		return self.begin2
	end
end

function M:SetBegin(index, value)
	if index == 0 then
		self.begin0 = value
	elseif index == 1 then
		self.begin1 = value
	else
		self.begin2 = value
	end
end

function M:HideOrShowHover(isActive)
	for i, v in pairs(gPinHaoBanManager.slotContainer) do
		local isSlotOccupied = gPinHaoBanManager.slotContainer[i] ~= -1

		if isSlotOccupied or isActive == false then
			self:GetRectHover(i).gameObject:SetActive(false)
		elseif self.pos and self.pos then
			local slotScreenPos = self.camera:WorldToScreenPoint(gPinHaoBanManager:GetSlotByIndex(i).gameObject.transform.position)
			local UIDis = gUtils:ScreenToUIPosition(self.pos) - gUtils:ScreenToUIPosition(slotScreenPos)
			local dis = gUtils:MagnitudeVector2(UIDis.x, UIDis.y)

			if self.selectedItem and not self:HoverAnimIsHovering(i) then
				self:GetRectHover(i).gameObject:SetActive(true)
				self:GetSlotHover(i).gameObject:SetActive(true)

				if not self:GetHoverAnim(i):IsPlaying(self.hoverAnimName[3]) then
					gCS.LuaUtils.PlayAnimationByName(self:GetHoverAnim(i), self.hoverAnimName[3])
				end
			elseif dis > 300 then
				self:SetBegin(i, false)
				self:GetRectHover(i).gameObject:SetActive(false)
				self:SetHoverAnimIsHovering(i, false)
			elseif dis >= 0 and dis < 300 then
				self:GetRectHover(i).gameObject:SetActive(isActive)
				self:GetSlotHover(i).gameObject:SetActive(isActive)

				if isActive then
					if not self.selectedItem and not self:HoverAnimIsHovering(i) and not self:GetHoverAnim(i):IsPlaying(self.hoverAnimName[1]) and not self:GetHoverAnim(i):IsPlaying(self.hoverAnimName[1]) and not self:GetHoverHoverAnimOpenTimer(i) then
						if not self:GetBegin(i) then
							gCS.LuaUtils.PlayAnimationByName(self:GetHoverAnim(i), self.hoverAnimName[1])
							self:SetBegin(i, true)
						end

						local timer = Timer.New(function ()
							self:SetHoverHoverAnimOpenTimer(i, nil)
							gCS.LuaUtils.PlayAnimationByName(self:GetHoverAnim(i), self.hoverAnimName[2])
						end, self.openDuration):Start()

						self:SetHoverHoverAnimOpenTimer(i, timer)
					end
				else
					self:SetBegin(i, false)
					self:SetHoverAnimIsHovering(i, false)
				end
			end
		end
	end
end

function M:ClearEffects()
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

function M:ResetAnimation(animation, clipName)
	local animationState = animation:get_Item(clipName)

	animation:Play(clipName)

	animationState.time = 0
	animationState.enabled = true

	animation:Sample()

	animationState.enabled = false
end

function M:PlayRotateLoopSound(index)
	if self.curRotateLoopId then
		return
	end

	if index == 0 then
		self.curRotateLoopId = gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBHeadRotate)
	elseif index == 3 then
		self.curRotateLoopId = gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBToiletRotate)
	else
		self.curRotateLoopId = gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBArmRotate)
	end
end

function M:PlayReturnSoundByIndex(index)
	if index == 0 then
		gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBHeadReturn)
	elseif index == 3 then
		gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBToiletReturn)
	else
		gSoundMgr:PlaySoundByTid(PoiGameConfig.PHBArmReturn)
	end
end
