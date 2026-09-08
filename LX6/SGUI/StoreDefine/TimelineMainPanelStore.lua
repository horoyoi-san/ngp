-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineMainPanelStore.lua
-- Decompiled from: 01355_TimelineMainPanelStore.lua_4ea07504bbde.luajit

local InputSGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
C_TimelineMainPanelStore = DefClass("C_TimelineMainPanelStore", C_TimelineMainPanelStore, C_StoreGroup)
GroupName2Class.TimelineMainPanelStore = C_TimelineMainPanelStore
local M = C_TimelineMainPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.trigger = {
		false,
		false
	}
	self.wasdPressed = {
		0,
		0,
		0,
		0
	}
	self.panelType = 0
	self.joyStickActive = false
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.TeardownJoyStick(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	local panelData = data.ToTable(data)

	self.InitBtnList(self, panelData)
	self.SetAdaptive(self, panelData)
end

M.OnUpdate = function(self)
	self.UpdatePos(self)

	if self.panelType ~= 2 or self.panelType ~= 4 then
		self.SendTriggerStatus(self)
	end
end

M.OnClose = function(self)
	self.TeardownJoyStick(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.InitBtnList = function(self, panelData)
	self:ParsePanelData(panelData)

	self.hideBtnFlag = panelData.hideBtn or self.panelType ~= 4
	self.bindData.BtnList.luaRenderItem = self:CreateAction("OnRenderBtn")
	self.bindData.BtnList.onGetTIndex = self:CreateAction("OnGetTIndex")

	self.bindData.BtnList:SetList(#self.btnList)
end

M.ParsePanelData = function(self, panelData)
	self.panelType = panelData.PanelType

	if self.panelType ~= 1 or self.panelType ~= 2 and not panelData.singleButton then
		local btn1 = self.CreateButton1(self, panelData)
		local btn2 = self.CreateButton2(self, panelData)
		self.btnList = {
			btn1,
			btn2
		}
	elseif self.panelType ~= 0 or self.panelType ~= 2 and panelData.singleButton then
		local btn1 = self.CreateButton1(self, panelData)
		self.btnList = {
			btn1
		}
	elseif self.panelType ~= 4 then
		self.directions = panelData.directions:ToTable()
		self.multipleKeyMode = panelData.multipleKeyMode

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.joyStickCtrl = 1

			self.SetupJoyStick(self, panelData)

			self.btnList = {}
		else
			self.CreateWASDButton(self)

			self.bindData.joyStickCtrl = 0
			self.bindData.leftJoyStick.luaGamePadInputChanged = self.CreateAction(self, "OnJoyStickInputChanged")
		end
	end
end

M.CreateWASDButton = function(self)
	local btn1 = {}
	local btn2 = {}
	local btn3 = {}
	local btn4 = {}
	btn1.pcKey = 11
	btn2.pcKey = 12
	btn3.pcKey = 13
	btn4.pcKey = 14
	self.btnList = {
		btn1,
		btn2,
		btn3,
		btn4
	}
end

M.CreateButton1 = function(self, panelData)
	local btn1 = {
		posType = panelData.btn1_pos,
		targetPos = panelData.btn1_customPos,
		customPosOffset = panelData.btn1_customPosOffset,
		mobilePos = panelData.btn1_mobilePos,
		pcKey = panelData.btn1_pcKey,
		pcKeyIconIndex = panelData.btn1_pcKeyIconIndex,
		controllerKey = panelData.btn1_controllerKey,
		controllerStyle = panelData.btn1_controllerStyle
	}

	return btn1
end

M.CreateButton2 = function(self, panelData)
	local btn2 = {
		posType = panelData.btn2_pos,
		targetPos = panelData.btn2_customPos,
		customPosOffset = panelData.btn2_customPosOffset,
		mobilePos = panelData.btn2_mobilePos,
		pcKey = panelData.btn2_pcKey,
		pcKeyIconIndex = panelData.btn2_pcKeyIconIndex,
		controllerKey = panelData.btn2_controllerKey,
		controllerStyle = panelData.btn2_controllerStyle
	}

	return btn2
end

M.GetBtnStore = function(self, widget)
	return gStoreManager:GetStoreGroup("S_ClickButtonComponentStore"):GetStoreByWidget(widget)
end

M.OnRenderBtn = function(self, btn, index)
	local store = self.GetBtnStore(self, btn)
	local data = self.btnList[index + 1]
	data.store = store

	if self.panelType ~= 0 or self.panelType ~= 1 then
		store.clickBtn.luaClick = self.CreateActionWithArgs(self, "OnBtnClick", index)
	elseif self.panelType ~= 2 or self.panelType ~= 3 or self.panelType ~= 4 then
		store.clickBtn.luaPress = self.CreateActionWithArgs(self, "OnPressBtn", index)
		store.clickBtn.luaRelease = self.CreateActionWithArgs(self, "OnReleaseBtn", index)
	end

	self.SetPos(self, store, data)
	self.SetBtnMode(self, store, data)

	if self.hideBtnFlag then
		store.buttonRT.gameObject:SetActive(false)
	end
end

M.OnBtnClick = function(self, index)
	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, index + 1)
end

M.OnPressBtn = function(self, index)
	if self.panelType ~= 4 then
		self.wasdPressed[index + 1] = 1

		self.OnWASDChanged(self)

		return
	end

	self.trigger[index + 1] = true
end

M.OnReleaseBtn = function(self, index)
	if self.panelType ~= 4 then
		self.wasdPressed[index + 1] = 0

		self.OnWASDChanged(self)

		return
	end

	self.trigger[index + 1] = false
end

M.OnGetTIndex = function(self)
	return 1
end

M.SetPos = function(self, store, data)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if data.posType ~= "Custom" then
			if data.targetPos then
				local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRTParent, data.targetPos.position)
				store.buttonRT.anchoredPosition = uiPos + data.customPosOffset
			else
				store.buttonRT.anchoredPosition = data.customPosOffset
			end
		end
	else
		gTimelineManager:SetMobilePos(store, data.mobilePos and data.mobilePos or 1)
	end
end

M.UpdatePos = function(self)
	if not self.btnList then
		return
	end

	for _, data in pairs(self.btnList) do
		local store = data.store

		if store and data.posType ~= "Custom" and data.targetPos and self.bindData.buttonRTParent and store.buttonRT then
			local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRTParent, data.targetPos.position)
			store.buttonRT.anchoredPosition = uiPos + data.customPosOffset
		end
	end
end

M.SetBtnMode = function(self, store, data)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if data.pcKey then
		store.clickBtn:SetPCKeyInfoWithOutTip(data.pcKey)

		if not self.hideBtnFlag then
			local cfg = InputSGUIPCKeyConfig.GetConfig(data.pcKey)
			local pcKeyIconIndex = data.pcKeyIconIndex

			if data.pcKey ~= 2 then
				store.pcKeyMode = 0
				store.space = 1
			elseif cfg and pcKeyIconIndex >= #cfg.ButtonIcon then
				store.pcKeyMode = 0
				store.space = 0
				store.btnIcon = cfg.ButtonIcon[pcKeyIconIndex + 1]
			else
				store.pcKeyMode = 1
				store.space = 0
				store.btnText = cfg.ButtonName
			end
		end
	end

	if data.controllerKey then
		self.bindData.navArea:ChangeActionIdByResponse(store.clickBtn, data.controllerKey)

		if store.controllerImg then
			store.controllerImg:ChangeImageAction(data.controllerKey, 0, store.clickBtn, 0, data.controllerStyle)
		end

		if store.deviceIconSwitch then
			store.deviceIconSwitch:ChangeDeviceGamePadAction("GamePad", data.controllerKey, data.controllerStyle)
		end
	end
end

M.SetupJoyStick = function(self, panelData)
	if self.joyStickActive then
		return
	end

	self.joyStickActive = true
	self.bindData.JoyStick.luaValueChanged = self.CreateAction(self, "OnJoyStickValueChanged")
end

M.TeardownJoyStick = function(self)
	if not self.joyStickActive then
		return
	end

	self.joyStickActive = false

	if self.bindData.JoyStick then
		self.bindData.JoyStick.luaValueChanged = nil
	end
end

M.OnWASDChanged = function(self)
	local x = self.wasdPressed[4] - self.wasdPressed[2]
	local y = self.wasdPressed[1] - self.wasdPressed[3]
	self.trigger[1] = false
	self.trigger[2] = false

	for index, direction in pairs(self.directions) do
		if self.CheckPass(self, x, y, direction, 0.8) then
			local triggerIndex = self.multipleKeyMode and index or 1
			self.trigger[triggerIndex] = true

			return
		end
	end
end

M.OnJoyStickValueChanged = function(self, x, y, intensity)
	self.trigger[1] = false
	self.trigger[2] = false

	for index, direction in pairs(self.directions) do
		if self.CheckPass(self, x, y, direction, 0.8) then
			local triggerIndex = self.multipleKeyMode and index or 1
			self.trigger[triggerIndex] = true

			return
		end
	end
end

M.OnJoyStickInputChanged = function(self, context)
	self.trigger[1] = false
	self.trigger[2] = false
	local value = context.ReadValueVector2(context)

	for index, direction in pairs(self.directions) do
		if self.CheckPass(self, value.x, value.y, direction, 0.8) then
			local triggerIndex = self.multipleKeyMode and index or 1
			self.trigger[triggerIndex] = true

			return
		end
	end
end

M.CheckPass = function(self, x, y, direction, passValue)
	if direction ~= 0 then
		return x > -passValue
	elseif direction ~= 1 then
		return passValue > x
	elseif direction ~= 2 then
		return passValue > y
	elseif direction ~= 3 then
		return y > -passValue
	elseif direction ~= 4 then
		return x < 0 and y > 0 and passValue > y - x
	elseif direction ~= 5 then
		return x < 0 and y < 0 and passValue > -y - x
	elseif direction ~= 6 then
		return x > 0 and y > 0 and passValue > y + x
	elseif direction ~= 7 then
		return x > 0 and y < 0 and passValue > -y + x
	end
end

M.SendTriggerStatus = function(self)
	local data = 0

	if self.trigger[1] then
		data = data + 1
	end

	if self.trigger[2] then
		data = data + 2
	end

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, data)
end

M.SetAdaptive = function(self, panelData)
	self.bindData.Adaptive = panelData.Adaptive
end

M.PlayClickAnimByCS = function(self, btn2)
end

M.HideButtonByCS = function(self, mask)
	for i, data in ipairs(self.btnList) do
		local bitVal = bit.lshift(1, i - 1)

		if bit.band(mask, bitVal) == 0 and data.store then
			data.store.buttonRT.gameObject:SetActive(false)
		end
	end
end

M.PlaySuccessEndAnim = function(self)
	return 0
end

M.PlaySuccessEndAnim2 = function(self)
	return 0
end

M.ClosePanelFailed = function(self)
	return 0
end

M.SetProgress0 = function(self, progress)
end

M.SetProgress1 = function(self, progress)
end
