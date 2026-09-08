-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GameplayQteStore.lua
-- Decompiled from: 01747_GameplayQteStore.lua_a2ed5db48828.luajit

C_GameplayQteStore = DefClass("C_GameplayQteStore", C_GameplayQteStore, C_StoreGroup)
GroupName2Class.GameplayQteStore = C_GameplayQteStore
local M = C_GameplayQteStore
local SGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
local SGUIGamepadConfig = LTConfig.InputSGUIGamepadConfig
local MainCamera = gCS.CameraDataMgr.MainCamera
local ZERO_OFFSET = Vector3.New(0, 0, 0)

M.ctor = function(self)
	self.InputType = {
		["0*"] = 0,
		["1G\\x93\\x87\\x8fD"] = 2,
		["\\xfe\\xda%\\xf5"] = 1
	}
	self.QTEType = {
		["\\x86\\xa4\t\\xbfc\n\\xff#"] = 2,
		["R-q_"] = 1,
		["\\xbaiv"] = 0,
		["}\\xbc\\xa7\\xbc\\xa5"] = 3
	}
	self.TriggerEvent = {
		["˕\\xeb,\\xe3\\xf9\\xaa\\xe8\\x85)&"] = 3,
		["oHbn~+"] = 4,
		["\\xeb\\xde7\\xf4"] = 2,
		["}\\xbc\\xa7\\xbc\\xa5"] = 1,
		["Cy\\xa2p|\\xa0\\xf7Ty_pH"] = 5,
		["n\\xa2\\xab\\xac\\xbd"] = 0,
		["nHyzK3="] = 7,
		["Ey\\xb5dX\\xbb\\xf1LGuhI"] = 6
	}
	self.WidgetType = {
		["c_ܮ\\x8d\\xac\\xc7\\xfc"] = 0,
		["\\xbf\\C"] = 1
	}
	self.DEFAULT_HOLD_TIME = 1
	self.MouseMoveKeyIds = {
		[54.0] = true
	}
end

M.DefineAllVariables = function(self)
	self.m_RegisteredItems = {
		[self.InputType.PC] = {},
		[self.InputType.Gamepad] = {},
		[self.InputType.Mobile] = {}
	}
	self.m_IsGamepadMode = false
	self.m_IsMobileMode = false
	self.m_ItemDataList = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.progressTypeEnum = {
		["\\xbb\\xa3\n\\xacx;\\xed "] = 2,
		["A\\x83\\x8d\\x8fD"] = 1,
		["@HygZ6"] = 3,
		["t-s^"] = 0
	}
	self.pcKeyModeEnum = {
		["PVǾ\\x8f:\\xb1\\xc1\\xfc"] = 1,
		["SDN}@*\n,"] = 3,
		["SDN}@76"] = 2,
		["@KejE2,"] = 0
	}
	self.tapTypeEnum = {
		["LI`pm3"] = 0,
		["nR`}m3"] = 1
	}
	self.buttonSizeEnum = {
		["~\\xa3\\xa3\\xa3\\xba"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.textStateCtrlEnum = {
		["R+y^"] = 0,
		["I*rL"] = 1
	}
	self.LeftRightCtrlEnum = {
		["V'{O"] = 0,
		["\\xa7\\xa5\\xa7\\xa2"] = 1
	}
	self.btnHideCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.wordsCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.qteVxCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.progressTypeEnum = nil
	self.pcKeyModeEnum = nil
	self.tapTypeEnum = nil
	self.buttonSizeEnum = nil
	self.textStateCtrlEnum = nil
	self.LeftRightCtrlEnum = nil
	self.btnHideCtrlEnum = nil
	self.wordsCtrlEnum = nil
	self.qteVxCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.DoCallBack = function(self, cb)
	if not cb then
		return
	end

	if type(cb) ~= "function" then
		cb()
	elseif cb.DynamicInvoke then
		cb.DynamicInvoke(cb)
	end
end

M.ClearLastGamePlay = function(self)
	self.DoCallBack(self, self.callBack)

	self.callBack = nil

	self.DefineAllVariables(self)
end

M.OnShow = function(self, panelId, data)
	self:ClearLastGamePlay()

	self.m_IsGamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	self.m_IsMobileMode = not gCS.LuaUtils.IsNonMobileAdaptive()

	if data and type(data) ~= "table" then
		for _, item in ipairs(data) do
			self:RegisterButton(item.keyId, item.qteType, item.position, item.inputType, item.tapCount, item.joystickSide, item.widgetType or self.WidgetType.Persistent, item.canBecomeTip, item.textId, item.isMouseMove, item.holdTime, item.transform, item.offset, item.isHideButton, item.inputIndex, item.mobileIcon, item.isMobileJoy, item.anchor, item.pivot)
		end
	end

	self.callBack = data.callBack

	if data.rectTab then
		self.curTypeData = data.tabData
		self.bindData.TabRectList.selectedIndex = data.rectTab
	end

	self.DoCallBack(self, data.onShowCallback)
end

M.OnClose = function(self)
	self.UnregisterAll(self)
	self.ClearLastGamePlay(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.m_IsGamepadMode = SGUI.GameDevice.KeyboardMouse <= device
	self.m_IsMobileMode = not gCS.LuaUtils.IsNonMobileAdaptive()

	self:RefreshItemList()
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.GAMEPLAY_QTE_REGISTER] = self.CreateAction(self, "OnMsgRegisterButton"),
		[gEventConstants.GAMEPLAY_QTE_UNREGISTER] = self.CreateAction(self, "OnMsgUnregisterButton"),
		[gEventConstants.GAMEPLAY_QTE_UNREGISTER_ALL] = self.CreateAction(self, "OnMsgUnregisterAll"),
		[gEventConstants.GAMEPLAY_QTE_TAB_RECT] = self.CreateAction(self, "SetTabRectList")
	}
end

M.OnMsgRegisterButton = function(self, eventId, data)
	if not data or not data.keyId then
		print_error("[GameplayQteStore] OnMsgRegisterButton: invalid data, need keyId")

		return
	end

	self.ShowButton(self, data.keyId, data.inputType, data.transform, data.offset)
end

M.OnMsgUnregisterButton = function(self, eventId, data)
	if not data or not data.keyId then
		print_error("[GameplayQteStore] OnMsgUnregisterButton: invalid data")

		return
	end

	self.HideButton(self, data.keyId, data.inputType)
end

M.OnMsgUnregisterAll = function(self, eventId, data)
	self.HideAllButtons(self)
end

M.SetTabRectList = function(self, _, data)
	self.curTypeData = data.tabData
	self.bindData.TabRectList.selectedIndex = data.index
end

M.RegisterWidget = function(self)
	if self.bindData.PCFreeList then
		self.bindData.PCFreeList.luaRenderItem = self.CreateAction(self, "OnRenderFreeListItem")

		self.bindData.PCFreeList.onGetTIndex = function(index)
			return self:_GetTemplateIndex(index)
		end
	end

	if self.bindData.mobileFreeList then
		self.bindData.mobileFreeList.luaRenderItem = self.CreateAction(self, "OnRenderMobileFreeListItem")

		self.bindData.mobileFreeList.onGetTIndex = function(index)
			return self:_GetMobileTemplateIndex(index)
		end
	end

	self.bindData.TabRectList.OnRenderTab = self.CreateAction(self, "OnRenderTaskTab")
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnClick")
end

M.RegisterButton = function(self, keyId, qteType, position, inputType, tapCount, joystickSide, widgetType, canBecomeTip, textId, isMouseMove, holdTime, transform, offset, isHideButton, inputIndex, mobileIcon, isMobileJoy, anchor, pivot)
	if not keyId then
		print_error("[GameplayQteStore] RegisterButton: invalid params, keyId=" .. tostring(keyId))

		return
	end

	inputType = inputType or self.InputType.PC
	widgetType = widgetType or self.WidgetType.QTE

	if joystickSide == nil and inputType == self.InputType.Gamepad then
		print_warn("[GameplayQteStore] RegisterButton: joystickSide 仅手柄有效，已忽略，keyId=" .. tostring(keyId))

		joystickSide = nil
	end

	isMouseMove = self._IsMouseMove(self, keyId, inputType)

	if widgetType ~= self.WidgetType.Persistent then
		if qteType ~= nil then
			qteType = self.QTEType.Tap
		elseif qteType == self.QTEType.Tap and qteType == self.QTEType.Hold and qteType == self.QTEType.Press then
			print_error("[GameplayQteStore] RegisterButton: Persistent widget only supports Tap/Hold/Press, keyId=" .. tostring(keyId))

			return
		end
	elseif qteType ~= nil then
		print_error("[GameplayQteStore] RegisterButton: qteType is required for QTE widget, keyId=" .. tostring(keyId))

		return
	end

	local totalTaps = 1

	if qteType ~= self.QTEType.MultiTap then
		totalTaps = tapCount and tapCount <= 0 and tapCount or 1
	end

	local posX = 0
	local posY = 0

	if position then
		posX = position.x or position[1] or 0
		posY = position.y or position[2] or 0
	end

	local offsetX = 0
	local offsetY = 0
	local offsetZ = 0

	if offset then
		offsetX = offset.x or offset[1] or 0
		offsetY = offset.y or offset[2] or 0
		offsetZ = offset.z or offset[3] or 0
	end

	local anchorX = anchor and (anchor.x or anchor[1]) or 0.5
	local anchorY = anchor and (anchor.y or anchor[2]) or 0.5
	local pivotX = pivot and (pivot.x or pivot[1]) or 0
	local pivotY = pivot and (pivot.y or pivot[2]) or 0
	local item = {
		["\\xd0\\xc8'3\\xff"] = true,
		keyId = keyId,
		qteType = qteType,
		inputType = inputType,
		tapCount = totalTaps,
		remainingTaps = totalTaps,
		joystickSide = joystickSide,
		widgetType = widgetType,
		canBecomeTip = canBecomeTip or false,
		textId = textId,
		isMouseMove = isMouseMove or false,
		holdTime = holdTime,
		position = {
			x = posX,
			y = posY
		},
		offset = Vector3.New(offsetX, offsetY, offsetZ),
		_transform = transform,
		isHideButton = isHideButton or false,
		inputIndex = inputIndex,
		mobileIcon = mobileIcon,
		isMobileJoy = isMobileJoy or false,
		anchor = {
			x = anchorX,
			y = anchorY
		},
		pivot = {
			x = pivotX,
			y = pivotY
		}
	}
	self.m_RegisteredItems[inputType][keyId] = item

	self:RefreshItemList()
end

M.ShowButton = function(self, keyId, inputType, transform, offset)
	inputType = inputType or self.InputType.PC
	local bucket = self.m_RegisteredItems[inputType]
	local item = bucket and bucket[keyId]

	if not item then
		return
	end

	if transform == nil then
		item._transform = transform
	end

	if offset == nil then
		item.offset = Vector3.New(offset.x or offset[1] or 0, offset.y or offset[2] or 0, offset.z or offset[3] or 0)
	end

	local needRefresh = not item.isShown or transform == nil or offset == nil
	item.isShown = true

	if needRefresh then
		self.RefreshItemList(self)
	end
end

M.HideButton = function(self, keyId, inputType)
	inputType = inputType or self.InputType.PC
	local bucket = self.m_RegisteredItems[inputType]
	local item = bucket and bucket[keyId]

	if not item or not item.isShown then
		return
	end

	item.isShown = false

	self.RefreshItemList(self)
end

M.HideAllButtons = function(self)
	local changed = false

	for _, bucket in pairs(self.m_RegisteredItems) do
		for _, item in pairs(bucket) do
			if item.isShown then
				item.isShown = false
				changed = true
			end
		end
	end

	if changed then
		self.RefreshItemList(self)
	end
end

M.UnregisterAll = function(self)
	table.clear(self.m_RegisteredItems[self.InputType.PC])
	table.clear(self.m_RegisteredItems[self.InputType.Gamepad])
	table.clear(self.m_RegisteredItems[self.InputType.Mobile])

	self.m_ItemDataList = {}

	if self.bindData.PCFreeList then
		self.bindData.PCFreeList:SetList(0)
	end

	if self.bindData.mobileFreeList then
		self.bindData.mobileFreeList:SetList(0)
	end
end

M.OnCameraUpdate = function(self)
	for _, bucket in pairs(self.m_RegisteredItems) do
		for _, item in pairs(bucket) do
			if item.isShown and not gCS.LuaUtils.IsNull(item._transform) and item._store and item._store.buttonRT then
				if item.isHideButton and item.canBecomeTip then
					item._store.rootComponent.renderOpacity = 0
				else
					local worldPos = item._transform:TransformPoint(item.offset or ZERO_OFFSET)

					if gCS.LuaUtils.IsInCameraView(MainCamera, worldPos) then
						local screenPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.rootTransform, worldPos)
						item._store.buttonRT.anchoredPosition = Vector2.New(screenPos.x, screenPos.y)
						item._store.rootComponent.renderOpacity = 1
					else
						item._store.rootComponent.renderOpacity = 0
					end
				end
			end
		end
	end
end

M.RefreshItemList = function(self)
	self.m_ItemDataList = {}

	if self.bindData.navigationArea then
		for keyId, item in pairs(self.m_RegisteredItems[self.InputType.Gamepad]) do
			if item.canBecomeTip then
				self.bindData.navigationArea:RemoveClickBindByActionId(keyId)
			end
		end
	end

	local activeBucket = nil

	if self.m_IsMobileMode then
		activeBucket = self.m_RegisteredItems[self.InputType.Mobile]
	elseif self.m_IsGamepadMode then
		activeBucket = self.m_RegisteredItems[self.InputType.Gamepad]
	else
		activeBucket = self.m_RegisteredItems[self.InputType.PC]
	end

	local shownItems = {}

	for _, item in pairs(activeBucket) do
		if item.isShown then
			shownItems[#shownItems + 1] = item
		end
	end

	table.sort(shownItems, function (a, b)
		return (a.inputIndex or 0) <= (b.inputIndex or 0)
	end)

	for _, item in ipairs(shownItems) do
		local itemData = nil

		if self.m_IsMobileMode then
			itemData = self.BuildMobileItemData(self, item)
		elseif self.m_IsGamepadMode then
			itemData = self.BuildGamepadItemData(self, item)
		else
			itemData = self.BuildPCItemData(self, item)
		end

		if itemData then
			self.m_ItemDataList[#self.m_ItemDataList + 1] = itemData
		end
	end

	local freeList = self.m_IsMobileMode and self.bindData.mobileFreeList or self.bindData.PCFreeList

	if freeList then
		freeList.SetList(freeList, #self.m_ItemDataList)
	end
end

M.BuildPCItemData = function(self, item)
	local cfg = SGUIPCKeyConfig.GetConfig(item.keyId)

	if not cfg then
		print_error("[GameplayQteStore] SGUIPCKeyConfig not found for keyId=" .. tostring(item.keyId))

		return nil
	end

	local pcKeyMode = self.pcKeyModeEnum.pcBtnText
	local btnIconId, btnText = nil

	if cfg.ButtonIcon and #cfg.ButtonIcon <= 0 then
		pcKeyMode = self.pcKeyModeEnum.pcBtnIcon
		btnIconId = cfg.ButtonIcon[1]
	else
		btnText = cfg.ButtonName
	end

	local eProgress = self.progressTypeEnum
	local eTapType = self.tapTypeEnum
	local eQTEType = self.QTEType
	local itemData = {
		keyId = item.keyId,
		inputType = item.inputType,
		qteType = item.qteType,
		widgetType = item.widgetType,
		pcKeyMode = pcKeyMode,
		btnIconId = btnIconId,
		btnText = btnText,
		textId = item.textId,
		holdTime = item.holdTime,
		canBecomeTip = item.canBecomeTip,
		hasTransform = item._transform == nil,
		isHideButton = item.isHideButton or false,
		posX = item.position.x,
		posY = item.position.y
	}

	if item.widgetType ~= self.WidgetType.Persistent then
		if item.qteType ~= eQTEType.Hold then
			itemData.progressType = eProgress.progress
		else
			itemData.progressType = eProgress.none
		end

		itemData.tapType = eTapType.onlyClick
	elseif item.qteType ~= eQTEType.Hold then
		itemData.progressType = eProgress.circle
		itemData.tapType = eTapType.onlyClick
	elseif item.qteType ~= eQTEType.MultiTap then
		itemData.progressType = eProgress.progress
		itemData.tapType = eTapType.MultClick
		itemData.remainingTaps = item.remainingTaps
		itemData.tapCount = item.tapCount
	else
		itemData.progressType = eProgress.none
		itemData.tapType = eTapType.onlyClick
	end

	return itemData
end

M.BuildGamepadItemData = function(self, item)
	if not SGUIGamepadConfig.GetConfig(item.keyId) then
		print_error("[GameplayQteStore] SGUIGamepadConfig not found for keyId=" .. tostring(item.keyId))

		return nil
	end

	local itemData = {
		keyId = item.keyId,
		inputType = item.inputType,
		qteType = item.qteType,
		widgetType = item.widgetType,
		textId = item.textId,
		holdTime = item.holdTime,
		hasTransform = item._transform == nil,
		isHideButton = item.isHideButton or false,
		canBecomeTip = item.canBecomeTip or false,
		posX = item.position.x,
		posY = item.position.y
	}

	if item.joystickSide == nil then
		itemData.isJoystick = true
		itemData.joystickSide = item.joystickSide
		itemData.controllerIconId = true
		itemData.textId = nil

		return itemData
	end

	itemData.controllerIconId = true
	local eProgress = self.progressTypeEnum
	local eTapType = self.tapTypeEnum
	local eQTEType = self.QTEType

	if item.widgetType ~= self.WidgetType.Persistent then
		if item.qteType ~= eQTEType.Hold then
			itemData.progressType = eProgress.progress
		else
			itemData.progressType = eProgress.none
		end

		itemData.tapType = eTapType.onlyClick
	elseif item.qteType ~= eQTEType.Hold then
		itemData.progressType = eProgress.progress
		itemData.tapType = eTapType.onlyClick
	elseif item.qteType ~= eQTEType.MultiTap then
		itemData.progressType = eProgress.progress
		itemData.tapType = eTapType.MultClick
		itemData.remainingTaps = item.remainingTaps
		itemData.tapCount = item.tapCount
	else
		itemData.progressType = eProgress.none
		itemData.tapType = eTapType.onlyClick
	end

	return itemData
end

M._GetTemplateIndex = function(self, index)
	local itemData = self.m_ItemDataList[index + 1]

	if itemData and itemData.isJoystick then
		return 1
	end

	return 0
end

M.OnRenderFreeListItem = function(self, btn, index)
	if not btn or not self.m_ItemDataList[index + 1] then
		return
	end

	local itemData = self.m_ItemDataList[index + 1]

	if not itemData then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if not store then
		return
	end

	self._RenderItem(self, btn, index, itemData, store, id)
end

M._RenderItem = function(self, btn, index, itemData, store, id)
	if itemData.textId then
		local cfg = LTConfig.InputButtonNameConfig.GetConfig(itemData.textId)

		if cfg then
			store.btnDesText = cfg.Name

			store.clickBtn:SetPCKeyInfoTipNameId(itemData.textId)
		end

		store.textStateCtrl = cfg and self.textStateCtrlEnum.Show or self.textStateCtrlEnum.Hide
	elseif not itemData.isJoystick and not itemData.btnText then
		store.textStateCtrl = self.textStateCtrlEnum.Hide
	end

	if itemData.isJoystick then
		if store.controllerImg then
			store.controllerImg:ChangeImageAction(itemData.keyId, 0, nil, 0, 2)
		end

		if store.deviceIconSwitch then
			store.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", itemData.keyId, 2)
		end

		store.LeftRightCtrl = itemData.joystickSide or self.LeftRightCtrlEnum.Left

		if store.joyStick then
			local side = itemData.joystickSide or 0
			store.joyStick.acceptGamepadLeftStick = side ~= 0
			store.joyStick.acceptGamepadRightStick = side ~= 1

			store.joyStick.luaValueChanged = function(dx, dy, size)
				self:OnJoystickMove(itemData.keyId, itemData.inputType, side, dx, dy, size)
			end
		end
	elseif itemData.controllerIconId then
		local respondType = itemData.qteType ~= self.QTEType.Hold and 1 or 0
		local holdTime = itemData.holdTime and itemData.holdTime <= 0 and itemData.holdTime or self.DEFAULT_HOLD_TIME

		if store.controllerImg then
			store.controllerImg:ChangeImageAction(itemData.keyId, respondType, store.clickBtn, 0, 2, 0, holdTime)
		end

		if store.deviceIconSwitch then
			store.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", itemData.keyId, 2)
		end

		if itemData.canBecomeTip and self.bindData.navigationArea and store.clickBtn then
			self.bindData.navigationArea:AddClickBindToNavArea(itemData.keyId, itemData.textId or 0, store.clickBtn, 0, 0, 1, respondType, holdTime)
			self.bindData.navigationArea:RefreshGamePadBar()
		end
	else
		local isMouse = self._IsMouseMove(self, itemData.keyId, itemData.inputType)

		if store.clickBtn then
			if isMouse then
				store.clickBtn:SetPCKeyInfoWithOutTip(itemData.keyId, 0, 2)
			else
				local respondType = itemData.qteType ~= self.QTEType.Hold and 1 or 0
				local template = itemData.qteType ~= self.QTEType.Hold and 1 or 2

				if template ~= 2 then
					local keyConfig = LTConfig.InputSGUIPCKeyConfig.GetConfig(itemData.keyId)

					if keyConfig == nil and #keyConfig.ButtonIcon == 0 then
						template = 4
					end
				end

				store.clickBtn:SetPCKeyInfoWithOutTip(itemData.keyId, template, respondType)
			end
		end

		if store.customRespond then
			if isMouse then
				slot7 = store.clickBtn

				slot7:SetPCKeyCustomRespond(store.customRespond)

				store.customRespond.luaGamePadInputChanged = function(context)
					local value = context:ReadValueVector2()

					self:OnMouseMove(itemData.keyId, itemData.inputType, value.x, value.y)
				end
			else
				store.customRespond.luaGamePadInputChanged = nil
			end
		end

		if itemData.canBecomeTip and store.clickBtn then
			store.clickBtn:SetPCKeyTipShowTip(true)
		end
	end

	if not itemData.isJoystick then
		store.pcKeyMode = itemData.pcKeyMode or self.pcKeyModeEnum.pcBtnText

		if itemData.btnIconId then
			store.btnIcon = itemData.btnIconId
		elseif itemData.btnText then
			store.btnText = itemData.btnText
		end
	end

	if not itemData.isJoystick then
		store.progressType = itemData.progressType or self.progressTypeEnum.none
		store.tapType = itemData.tapType or self.tapTypeEnum.onlyClick
	end

	local bucket = self.m_RegisteredItems[itemData.inputType]

	if bucket then
		local regItem = bucket[itemData.keyId]

		if regItem then
			regItem._store = store
		end
	end

	if store.buttonRT then
		local posX = itemData.posX or 0
		local posY = itemData.posY or 0

		if itemData.hasTransform then
			local regItem = bucket and bucket[itemData.keyId]

			if regItem and regItem._transform then
				local worldPos = regItem._transform:TransformPoint(regItem.offset or ZERO_OFFSET)
				local screenPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.rootTransform, worldPos)
				posX = screenPos.x
				posY = screenPos.y
				store.rootComponent.renderOpacity = gCS.LuaUtils.IsInCameraView(MainCamera, worldPos) and 1 or 0
			end
		end

		store.buttonRT.anchoredPosition = Vector2.New(posX, posY)
	end

	if not itemData.isJoystick then
		local needAnim = itemData.widgetType == self.WidgetType.Persistent and itemData.progressType == self.progressTypeEnum.none

		if needAnim then
			if store.circleShowAnim == nil then
				store.circleShowAnim = true
			end

			if itemData.progressType ~= self.progressTypeEnum.circle and store.circleAnimation then
				gCS.LuaUtils.PlayAnimationByName(store.circleAnimation, "S_Vx_TimelineTapPanel_ClickOffset")
			elseif itemData.progressType ~= self.progressTypeEnum.progress and store.progressAnimation then
				gCS.LuaUtils.PlayAnimationByName(store.progressAnimation, "S_Vx_ClickBtn_Mobile_outerProgress")
			end
		else
			if store.circleShowAnim == nil then
				store.circleShowAnim = false
			end

			if store.circleAnimation then
				store.circleAnimation:Stop()
			end
		end
	end

	self._BindQteButtonEvents(self, store, itemData)

	if itemData.isHideButton and itemData.canBecomeTip then
		store.rootComponent.renderOpacity = 0
	end
end

M._BindQteButtonEvents = function(self, store, itemData)
	local eQTEType = self.QTEType
	local eTrigger = self.TriggerEvent
	local qteType = itemData.qteType

	if store.clickBtn and not self._IsMouseMove(self, itemData.keyId, itemData.inputType) then
		if qteType ~= eQTEType.Tap or qteType ~= eQTEType.MultiTap then
			store.clickBtn.luaClick = self.CreateActionWithArgs(self, "OnQTEItemTriggered", {
				keyId = itemData.keyId,
				inputType = itemData.inputType,
				qteType = qteType,
				triggerEvent = eTrigger.Click
			})
		elseif qteType ~= eQTEType.Press then
			store.clickBtn.luaPress = self.CreateActionWithArgs(self, "OnQTEItemTriggered", {
				keyId = itemData.keyId,
				inputType = itemData.inputType,
				qteType = qteType,
				triggerEvent = eTrigger.Press
			})
			store.clickBtn.luaRelease = self.CreateActionWithArgs(self, "OnQTEItemTriggered", {
				keyId = itemData.keyId,
				inputType = itemData.inputType,
				qteType = qteType,
				triggerEvent = eTrigger.Release
			})
		elseif qteType ~= eQTEType.Hold then
			local holdTime = itemData.holdTime and itemData.holdTime <= 0 and itemData.holdTime or self.DEFAULT_HOLD_TIME
			store.clickBtn.customLongPressSetting = true
			store.clickBtn.longPressTime = holdTime
			store.clickBtn.enabledLongPress = true

			store.clickBtn.luaBeginLongPress = function()
				self:_HoldOnBegin(store, itemData)
				self:OnQTEItemTriggered({
					keyId = itemData.keyId,
					inputType = itemData.inputType,
					qteType = qteType,
					triggerEvent = eTrigger.LongPressBegin
				})
			end

			store.clickBtn.luaLongPress = function()
				self:_SetHoldFull(store)
				self:OnQTEItemTriggered({
					keyId = itemData.keyId,
					inputType = itemData.inputType,
					qteType = qteType,
					triggerEvent = eTrigger.LongPress
				})
			end

			store.clickBtn.luaEndLongPress = function(progress)
				self:_HoldOnEnd(store, itemData)
				self:OnQTEItemTriggered({
					keyId = itemData.keyId,
					inputType = itemData.inputType,
					qteType = qteType,
					triggerEvent = eTrigger.LongPressEnd
				}, progress)

				if itemData.widgetType == self.WidgetType.Persistent then
					self:HideButton(itemData.keyId, itemData.inputType)
				end
			end
		end
	end
end

M._HoldOnBegin = function(self, store, itemData)
	if store.circleShowAnim == nil then
		store.circleShowAnim = false
	end

	if store.circleAnimation then
		store.circleAnimation:Stop()
	end

	self._StartHoldFill(self, store, itemData)
end

M._HoldOnEnd = function(self, store, itemData)
	self._StopHoldFill(self, store)

	if store.progress then
		store.progress.value = 0
	end

	self._SetCircleProgress(self, store, 0)

	if itemData.widgetType == self.WidgetType.Persistent then
		if store.circleShowAnim == nil then
			store.circleShowAnim = true
		end

		if store.circleAnimation then
			gCS.LuaUtils.PlayAnimationByName(store.circleAnimation, "S_Vx_TimelineTapPanel_ClickOffset")
		end
	end
end

M._StartHoldFill = function(self, store, itemData)
	self:_StopHoldFill(store)

	local holdTime = itemData.holdTime and itemData.holdTime <= 0 and itemData.holdTime or self.DEFAULT_HOLD_TIME
	local startTime = Time.time

	if store.progress then
		store.progress.value = 0
	end

	self:_SetCircleProgress(store, 0)

	store._holdFillTimer = Timer.New(function ()
		local p = (Time.time - startTime) / holdTime

		if p >= 0 then
			p = 0
		elseif p <= 1 then
			p = 1
		end

		if store.progress then
			store.progress.value = p
		end

		self:_SetCircleProgress(store, p)

		if p > 1 then
			self:_StopHoldFill(store)
		end
	end, 0.0167, -1)

	store._holdFillTimer:Start()
end

M._StopHoldFill = function(self, store)
	if store and store._holdFillTimer then
		store._holdFillTimer:Stop()

		store._holdFillTimer = nil
	end
end

M._SetHoldFull = function(self, store)
	self._StopHoldFill(self, store)

	if store.progress then
		store.progress.value = 1
	end

	self._SetCircleProgress(self, store, 1)
end

M._SetCircleProgress = function(self, store, p)
	if store.outCircleRT and store.innerCircleRT then
		local outerWidth = store.outCircleRT.rect.width
		local innerWidth = store.innerCircleRT.rect.width

		if outerWidth and outerWidth <= 0 then
			local s = innerWidth / outerWidth
			store.outCircleRT.localScale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(s, s, 1), p)
		end
	end
end

M.OnQTEItemTriggered = function(self, args, progress)
	local regItem = self.m_RegisteredItems[args.inputType] and self.m_RegisteredItems[args.inputType][args.keyId]
	local eventData = {
		keyId = args.keyId,
		inputType = args.inputType,
		qteType = args.qteType,
		triggerEvent = args.triggerEvent,
		progress = progress,
		inputIndex = regItem and regItem.inputIndex
	}

	gMessageManager:SendMessage(gEventConstants.GAMEPLAY_QTE_TRIGGERED, eventData)

	if args.qteType ~= self.QTEType.MultiTap and args.triggerEvent ~= self.TriggerEvent.Click then
		local bucket = self.m_RegisteredItems[args.inputType]

		if bucket then
			local item = bucket[args.keyId]

			if item then
				item.remainingTaps = math.max(0, (item.remainingTaps or 1) - 1)

				if item.remainingTaps ~= 0 then
					self.HideButton(self, args.keyId, args.inputType)
				else
					self.RefreshItemList(self)
				end
			end
		end
	end
end

M.OnJoystickMove = function(self, keyId, inputType, joystickSide, dx, dy, size)
	local regItem = self.m_RegisteredItems[inputType] and self.m_RegisteredItems[inputType][keyId]
	local eventData = {
		keyId = keyId,
		inputType = inputType,
		triggerEvent = self.TriggerEvent.JoystickMove,
		joystickSide = joystickSide,
		dx = dx,
		dy = dy,
		size = size,
		inputIndex = regItem and regItem.inputIndex
	}

	gMessageManager:SendMessage(gEventConstants.GAMEPLAY_QTE_TRIGGERED, eventData)
end

M._GetMobileTemplateIndex = function(self, index)
	local itemData = self.m_ItemDataList[index + 1]

	if itemData and itemData.isMobileJoy then
		return 1
	end

	return 0
end

M.BuildMobileItemData = function(self, item)
	return {
		keyId = item.keyId,
		inputType = item.inputType,
		qteType = item.qteType,
		widgetType = item.widgetType,
		textId = item.textId,
		holdTime = item.holdTime,
		mobileIcon = item.mobileIcon,
		isMobileJoy = item.isMobileJoy or false,
		hasTransform = item._transform == nil,
		isHideButton = item.isHideButton or false,
		posX = item.position.x,
		posY = item.position.y,
		anchorX = item.anchor and item.anchor.x or 0.5,
		anchorY = item.anchor and item.anchor.y or 0.5,
		pivotX = item.pivot and item.pivot.x or 0,
		pivotY = item.pivot and item.pivot.y or 0
	}
end

M.OnRenderMobileFreeListItem = function(self, btn, index)
	if not btn or not self.m_ItemDataList[index + 1] then
		return
	end

	local itemData = self.m_ItemDataList[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if not store then
		return
	end

	self._RenderMobileItem(self, index, itemData, store)
end

M._RenderMobileItem = function(self, index, itemData, store)
	local bucket = self.m_RegisteredItems[itemData.inputType]
	local regItem = bucket and bucket[itemData.keyId]

	if regItem then
		regItem._store = store
	end

	if store.buttonRT then
		local anchorVec = Vector2.New(itemData.anchorX or 0.5, itemData.anchorY or 0.5)
		store.buttonRT.anchorMin = anchorVec
		store.buttonRT.anchorMax = anchorVec
		store.buttonRT.pivot = Vector2.New(itemData.pivotX or 0, itemData.pivotY or 0)
		local posX = itemData.posX or 0
		local posY = itemData.posY or 0

		if itemData.hasTransform and regItem and regItem._transform then
			local worldPos = regItem._transform:TransformPoint(regItem.offset or ZERO_OFFSET)
			local screenPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.rootTransform, worldPos)
			posX = screenPos.x
			posY = screenPos.y

			if store.rootComponent then
				store.rootComponent.renderOpacity = gCS.LuaUtils.IsInCameraView(MainCamera, worldPos) and 1 or 0
			end
		end

		store.buttonRT.anchoredPosition = Vector2.New(posX, posY)
	end

	if itemData.isMobileJoy then
		if store.joyStick then
			store.joyStick.luaValueChanged = function(dx, dy, size)
				self:OnJoystickMove(itemData.keyId, itemData.inputType, 0, dx, dy, size)
			end
		end

		return
	end

	if itemData.mobileIcon and itemData.mobileIcon <= 0 then
		store.iconId = itemData.mobileIcon
	end

	if itemData.textId then
		local cfg = LTConfig.InputButtonNameConfig.GetConfig(itemData.textId)

		if cfg then
			store.notifyWord = cfg.Name
			store.wordsCtrl = self.wordsCtrlEnum.True
		else
			store.wordsCtrl = self.wordsCtrlEnum.False
		end
	else
		store.wordsCtrl = self.wordsCtrlEnum.False
	end

	store.interactable = true

	self._BindQteButtonEvents(self, store, itemData)
end

M._IsMouseMove = function(self, keyId, inputType)
	return inputType ~= self.InputType.PC and self.MouseMoveKeyIds[keyId] ~= true
end

M.OnMouseMove = function(self, keyId, inputType, dx, dy)
	local regItem = self.m_RegisteredItems[inputType] and self.m_RegisteredItems[inputType][keyId]
	local eventData = {
		keyId = keyId,
		inputType = inputType,
		triggerEvent = self.TriggerEvent.MouseMove,
		dx = dx,
		dy = dy,
		inputIndex = regItem and regItem.inputIndex
	}

	gMessageManager:SendMessage(gEventConstants.GAMEPLAY_QTE_TRIGGERED, eventData)
end

M.OnRenderTaskTab = function(self, index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(_, self.curTypeData)
	end
end

M.OnExitBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_GAMEPLAY_QTE_PANEL)
end
