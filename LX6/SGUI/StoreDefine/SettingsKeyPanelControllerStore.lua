-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SettingsKeyPanelControllerStore.lua
-- Decompiled from: 00887_SettingsKeyPanelControllerStore.lua_152fa95ff045.luajit

local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local RebindActionConfig = LTConfig.RebindActionConfig
local RebindActionActionMapConfig = LTConfig.RebindActionActionMapConfig
local RebindActionControllerConfig = LTConfig.RebindActionRebindActionControllerConfig
local RebindActionControllerIconConfig = LTConfig.RebindActionControllerIconConfig
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local RebindMode = LX6.Manager.RebindMode
local SettingsAction = require("LX6/GUI/Setting/SettingsAction")
C_SettingsKeyPanelControllerStore = DefClass("C_SettingsKeyPanelControllerStore", C_SettingsKeyPanelControllerStore, C_StoreGroup)
GroupName2Class.SettingsKeyPanelControllerStore = C_SettingsKeyPanelControllerStore
local M = C_SettingsKeyPanelControllerStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	self.showKeys = gStoreManager:GetStoreGroup("SettingsKeyControllerTemplate"):GetStoreByWidget(self.bindData.showKeys)
	self.driveKeys = gStoreManager:GetStoreGroup("SettingsKeyControllerTemplate"):GetStoreByWidget(self.bindData.driveKeys)
	self.opNameToTab = {}

	for i = 0, RebindActionControllerConfig.count - 1 do
		local cfg = RebindActionControllerConfig.LoadAt(i)
		self.opNameToTab[cfg.Name] = RebindActionActionMapConfig.GetConfig(cfg.ActionMapId).Classify
	end

	self.InitControllerText(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.showKeys = nil
	self.driveKeys = nil
	self.opNameToTab = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, data)
	if not data then
		return
	end

	self.itemGroup = data

	self:InitButtonLayoutData()

	self.rebindGroupedData = gRebindActionManager:InitRebindActionData(self.typeNameList)

	self.bindData.layoutList:SetSimpleList(#self.itemGroup)
	self.bindData.tabList:SetSimpleList(#RebindActionConfig.ControllerClassifyOutId)
	self.bindData.tabList:SetItemSelected(0, true)

	self.classifySelected = 1
	self.curActiveDevice = gCS.LuaUtils.GetActiveDevice()

	if self.curActiveDevice ~= SGUI.GameDevice.KeyboardMouse then
		self.bindData.platformCtrl = gameProfile.isPlayStationMode and 1 or 0
	else
		self.bindData.platformCtrl = self.curActiveDevice ~= SGUI.GameDevice.PlayStation and 1 or 0
		gameProfile.isPlayStationMode = self.curActiveDevice ~= SGUI.GameDevice.PlayStation

		ProfileManager.SaveGameProperty()
	end

	self.InitControllerText(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.curActiveDevice = device

	if SGUI.GameDevice.KeyboardMouse >= device then
		local isPSMode = device ~= SGUI.GameDevice.PlayStation
		self.bindData.platformCtrl = isPSMode and 1 or 0
		gameProfile.isPlayStationMode = isPSMode

		ProfileManager.SaveGameProperty()
	end
end

M.OnLanguageChange = function(self, lang)
	self.InitButtonLayoutData(self)

	if self.itemGroup then
		self.bindData.layoutList:SetSimpleList(#self.itemGroup)
	end

	self.bindData.tabList:SetSimpleList(#RebindActionConfig.ControllerClassifyOutId)
	self:InitControllerText()
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.REBIND_SHOW_CONTROLLER] = self.CreateAction(self, "OnShowControllerText"),
		[gEventConstants.REBIND_CHANGE_CONFIG_FINISH] = self.CreateAction(self, "OnChangeConfigFinish"),
		[gEventConstants.SETTING_ULT_BUTTON_TO_R2_CHANGE] = self.CreateAction(self, "OnShowControllerText")
	}
end

M.RegisterWidget = function(self)
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnRefreshTab", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnRefreshTab", 1)
	self.bindData.layoutList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderLayoutListItem")
	self.bindData.layoutList.onGetTIndex = self:CreateAction("OnGetLayoutListTIndex")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnTabSelectedChanged")

	self.bindData.tabList:SetItemSelected(0, true)
end

M.InitButtonLayoutData = function(self)
	self.leftLayoutList = {}
	local titleList = ShezhiPanelConfig.GamepadLayoutTitle

	for i = 1, #titleList do
		self.leftLayoutList[i] = {
			index = titleList[i].type,
			tIndex = titleList[i].tIndex,
			title = titleList[i].name
		}
	end

	if not table.isNilOrEmpty(ShezhiPanelConfig.KeyPanelConfigTitle) then
		self.optionList = {}

		for t = 1, #ShezhiPanelConfig.KeyPanelConfigTitle do
			local tView = {
				label = ShezhiPanelConfig.KeyPanelConfigTitle[t],
				iconId = 0,
				index = t,
				isSelect = false
			}

			table.insert(self.optionList, tView)
		end
	end

	if not table.isNilOrEmpty(ShezhiPanelConfig.GamepadSettingTitle) then
		self.settingList = {}

		for t = 1, #ShezhiPanelConfig.GamepadSettingTitle do
			local tView = {
				label = ShezhiPanelConfig.GamepadSettingTitle[t],
				index = t,
				isSelect = false
			}

			table.insert(self.settingList, tView)
		end
	end

	if not table.isNilOrEmpty(RebindActionConfig.ControllerClassifyText) then
		self.classifyList = RebindActionConfig.ControllerClassifyText
	end

	self.typeNameList = gRebindActionManager:GetGamepadTypeNameList()
end

M.OnGetLayoutListTIndex = function(self, index)
	local data = self.itemGroup[index + 1]

	if not data then
		return 0
	end

	return data.tIndex
end

M.OnSimpleRenderLayoutListItem = function(self, btn, index)
	local data = self.itemGroup[index + 1]

	if not data then
		return
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tType ~= 1 then
		store.title = data.title

		if data.sliderValue then
			store.leftBtn.luaClick = self:CreateActionWithArgs("OnIncreaseOrDecreaseBtnState", {
				["\\xaa\\xb5\\x9dk2\\xeb6"] = -1,
				tType = data.tType,
				id = id,
				index = index + 1
			})
			store.rightBtn.luaClick = self:CreateActionWithArgs("OnIncreaseOrDecreaseBtnState", {
				["\\xaa\\xb5\\x9dk2\\xeb6"] = 1,
				tType = data.tType,
				id = id,
				index = index + 1
			})
			store.sliderComp.formatText = "{0}"
			self.isSetMinMaxValue = true
			store.sliderComp.stepSize = not table.isNilOrEmpty(data.SliderSetValues) and data.SliderSetValues.stepValue or 1
			store.sliderComp.maxValue = not table.isNilOrEmpty(data.SliderSetValues) and data.SliderSetValues.maxValue or 100
			store.sliderComp.minValue = not table.isNilOrEmpty(data.SliderSetValues) and data.SliderSetValues.minValue or 0
			self.isSetMinMaxValue = false
			store.slider.luaValueChanged = self:CreateActionWithArgs("OnSliderValueChange", index + 1)
			store.slider.value = not table.isNilOrEmpty(data.SliderSetValues) and data.sliderValue * data.SliderSetValues.sliderSetValues or data.sliderValue
		end
	elseif data.tType ~= 2 then
		store.title = data.title
		local itemList = self.itemGroup[index + 1].itemList

		store.dropMenu:SetSimpleOptions(#itemList)

		for i = 1, #itemList do
			store.dropMenu:SetItemLabel(i - 1, itemList[i].label)
		end

		local view = {
			dropMenu = store.dropMenu,
			index = index + 1
		}
		store.dropMenu.luaSimpleOptionClick = self:CreateActionWithArgs("OnSelectedChanged", view)

		store.dropMenu:SelectOption(self.itemGroup[index + 1].selectIndex - 1)
	elseif data.tType ~= 4 then
		store.title = data.title
		store.turnToBtn.luaClick = self.CreateActionWithArgs(self, "OnTurnToBtnClick", index + 1)
	elseif data.tType ~= 5 or data.tType ~= 14 then
		store.title = data.title
	else
		print_error("类型超出范围，还未接入对应template")
	end

	store.interactable = BOOL2CTL[SettingsAction.CheckFunc(data.OpenAction, data)]
end

M.ShowButtonPos = function(self)
	if not self.rebindGroupedData then
		return
	end

	local showButtonInfo = self.rebindGroupedData[self.classifySelected]

	if not showButtonInfo then
		return
	end

	local allText = {}
	local allRebind = {}

	for t = 1, #showButtonInfo do
		local curButtonInfo = showButtonInfo[t]

		if curButtonInfo.id == -1 then
			if curButtonInfo.isComposite then
				if gameProfile.isUltButtonToR2 then
					local hasValue = allText["<Gamepad>/rightTrigger"] == nil
					allText["<Gamepad>/rightTrigger"] = (allText["<Gamepad>/rightTrigger"] or "") .. (hasValue and "/" or "") .. curButtonInfo.actionName .. "/"
					allRebind["<Gamepad>/rightTrigger"] = curButtonInfo.isRebind
				end
			else
				allText[curButtonInfo.button[1]] = (allText[curButtonInfo.button[1]] or "") .. curButtonInfo.actionName
				allRebind[curButtonInfo.button[1]] = curButtonInfo.isRebind
			end
		end
	end

	self.curKeyPanel = self.classifySelected ~= 1 and self.showKeys or self.driveKeys

	if not self.curKeyPanel then
		return
	end

	for i = 0, RebindActionControllerIconConfig.count - 1 do
		local config = RebindActionControllerIconConfig.LoadAt(i)

		if config and config.StoreName then
			local widget = self.curKeyPanel[config.StoreName]

			if not widget then
				-- Nothing
			else
				local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

				if not store then
					-- Nothing
				elseif allText[config.ButtonName] then
					store.text = allText[config.ButtonName]

					store:Commit("isRebound", allRebind[config.ButtonName] ~= true and 0 or 1, COMMIT_IMMEDIATELY)
				else
					local defaultNames = gCS.RebindMgr:GetActionsByPath(config.ButtonName):ToTable()

					if #defaultNames ~= 0 then
						print_warn("#NoCreateIssue ShowButtonPos: ButtonName not found, check ControllerIconConfig path:", config.ButtonName)
					end

					local defaultText = ""

					for _, opName in ipairs(defaultNames) do
						if self.opNameToTab[opName] ~= self.classifySelected then
							defaultText = defaultText .. opName
						end
					end

					store.text = string.is_null_or_empty(defaultText) and "---" or defaultText
					store.isReboundCtrl = 1
				end
			end
		end
	end

	if self.curKeyPanel.ultBtn then
		self.curKeyPanel.ultBtn:SetActive(not gameProfile.isUltButtonToR2)
	end
end

M.OnShowControllerText = function(self, eventId, data, isSwap)
	self.rebindGroupedData = gRebindActionManager:InitRebindActionData(self.typeNameList)

	self:InitControllerText()
end

M.OnChangeConfigFinish = function(self)
	self.rebindGroupedData = gRebindActionManager:InitRebindActionData(self.typeNameList)

	self:InitControllerText()
end

M.InitControllerText = function(self)
	self.ShowButtonPos(self)
end

M.OnTurnToBtnClicked = function(self)
	gPanelManager:CheckShow(gPanelId.SETTING_BTN_RESET_PANEL_CONTROLLER)
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local data = self.classifyList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data

	if btn.isSelected then
		self.classifySelected = index + 1
	end
end

M.OnTabSelectedChanged = function(self, btn, index)
	self.classifySelected = self.bindData.tabList.selectedIndex + 1
	self.bindData.pageCtrl = self.bindData.tabList.selectedIndex

	self.InitControllerText(self)
end

M.OnRefreshTab = function(self, step)
	local tabNum = #RebindActionConfig.ControllerClassifyOutId
	local nextStep = self.bindData.tabList.selectedIndex + step

	if nextStep >= 0 then
		nextStep = tabNum - 1
	elseif tabNum < nextStep then
		nextStep = 0
	end

	self.bindData.tabList:SetItemSelected(nextStep, true)

	self.bindData.pageCtrl = nextStep
end

M.OnIncreaseOrDecreaseBtnState = function(self, params)
	local store = gStoreManager:GetStoreGroup("SettingTemplate_" .. params.tType):GetStoreById(params.id)

	if store then
		local sliderValue = self.itemGroup[params.index].sliderValue

		if params.addValue == nil then
			sliderValue = sliderValue + params.addValue

			if sliderValue < 0 then
				store.slider.value = 0
				sliderValue = 0
			else
				store.slider.value = sliderValue
			end

			self.OnSliderValueChange(self, params.index, sliderValue, params.id)
		else
			if not self.itemGroup[params.index].isOn then
				store.slider.value = 0
				sliderValue = 0
			end

			self.OnSliderValueChange(self, params.index, sliderValue, params.id)
		end
	end
end

M.OnSliderValueChange = function(self, index, value, instanceId)
	if self.isSetMinMaxValue then
		return
	end

	local store = gStoreManager:GetStoreGroup("SettingTemplate_" .. self.itemGroup[index].tType):GetStoreById(instanceId)

	if store then
		store.isBtnOnCtrl = self.itemGroup[index].isOn and 1 or 0
	end

	if self.itemGroup[index].sliderValue == value then
		self.itemGroup[index].sliderValue = value
	end

	local data = {
		value = value
	}

	SettingsAction.RunFunc(self.itemGroup[index].SlideAction, data)
	gMessageManager:SendMessage(gEventConstants.SETTING_KEY_PANEL_CHANGED)
end

M.OnSelectedChanged = function(self, view, btn, selectorIndex)
	if selectorIndex >= 0 then
		return
	end

	local index = view.index
	local data = {
		value = selectorIndex + 1
	}
	self.itemGroup[index].selectIndex = selectorIndex + 1

	SettingsAction.RunFunc(self.itemGroup[index].SelectAction, data)
	gMessageManager:SendMessage(gEventConstants.SETTING_KEY_PANEL_CHANGED)
end

M.OnTurnToBtnClick = function(self, index)
	SettingsAction.RunFunc(self.itemGroup[index].TurnToAction)
end
