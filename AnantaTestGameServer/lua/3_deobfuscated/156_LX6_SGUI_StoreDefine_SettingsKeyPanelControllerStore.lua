local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local RebindActionConfig = LTConfig.RebindActionConfig
local RebindActionActionMapConfig = LTConfig.RebindActionActionMapConfig
local RebindActionControllerConfig = LTConfig.RebindActionRebindActionControllerConfig
local RebindActionControllerIconConfig = LTConfig.RebindActionControllerIconConfig
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
local RebindMode = LX6.Manager.RebindMode
C_SettingsKeyPanelControllerStore = DefClass("C_SettingsKeyPanelControllerStore", C_SettingsKeyPanelControllerStore, C_StoreGroup)
GroupName2Class.SettingsKeyPanelControllerStore = C_SettingsKeyPanelControllerStore
local M = C_SettingsKeyPanelControllerStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.pathToButtonShowPS = {
		["<Gamepad>/leftTrigger"] = self.bindData.L2Btn_PS,
		["<Gamepad>/leftShoulder"] = self.bindData.L1Btn_PS,
		["<Gamepad>/dpad/left"] = self.bindData.DPadLeftBtn_PS,
		["<Gamepad>/dpad/right"] = self.bindData.DpadRightBtn_PS,
		["<Gamepad>/dpad/down"] = self.bindData.DpadDownBtn_PS,
		["<Gamepad>/leftStick"] = self.bindData.LeftStick_PS,
		["<Gamepad>/leftStickPress"] = self.bindData.L3Btn_PS,
		["<Gamepad>/menu"] = self.bindData.Menu_PS,
		["<Gamepad>/rightTrigger"] = self.bindData.R2Btn_PS,
		["<Gamepad>/rightShoulder"] = self.bindData.R1Btn_PS,
		["<Gamepad>/buttonWest"] = self.bindData.West_PS,
		["<Gamepad>/buttonNorth"] = self.bindData.North_PS,
		["<Gamepad>/buttonEast"] = self.bindData.East_PS,
		["<Gamepad>/buttonSouth"] = self.bindData.South_PS,
		["<Gamepad>/rightStick"] = self.bindData.RightStick_PS,
		["<Gamepad>/rightStickPress"] = self.bindData.R3Btn_PS,
		["<DualShockGamepad>/touchpadButton"] = self.bindData.Touch_PS,
		Composite = self.bindData.Combin_PS
	}
	self.pathToButtonShowXB = {
		["<XInputController>/select"] = self.bindData.View_XB,
		["<Gamepad>/leftTrigger"] = self.bindData.L2Btn_XB,
		["<Gamepad>/leftShoulder"] = self.bindData.L1Btn_XB,
		["<Gamepad>/leftStick"] = self.bindData.LeftStick_XB,
		["<Gamepad>/dpad/left"] = self.bindData.DPadLeft_XB,
		["<Gamepad>/dpad/right"] = self.bindData.DPadRight_XB,
		["<Gamepad>/dpad/down"] = self.bindData.DPadDown_XB,
		["<Gamepad>/menu"] = self.bindData.Menu_XB,
		["<Gamepad>/rightTrigger"] = self.bindData.R2Btn_XB,
		["<Gamepad>/rightShoulder"] = self.bindData.R1Btn_XB,
		["<Gamepad>/buttonWest"] = self.bindData.X_XB,
		["<Gamepad>/buttonNorth"] = self.bindData.Y_XB,
		["<Gamepad>/buttonEast"] = self.bindData.B_XB,
		["<Gamepad>/buttonSouth"] = self.bindData.A_XB,
		["<Gamepad>/rightStick"] = self.bindData.RightStick_XB,
		["<Gamepad>/rightStickPress"] = self.bindData.R3Btn_XB,
		["<Gamepad>/leftStickPress"] = self.bindData.L3Btn_XB,
		Composite = self.bindData.Combin_XB
	}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self:InitButtonLayoutData()
	self:InitRebindActionData()
	self.bindData.layoutList:SetSimpleList(#self.leftLayoutList)
	self.bindData.tabList:SetSimpleList(#RebindActionConfig.ControllerClassifyOutId)
	self.bindData.tabList:SetItemSelected(0, true)

	self.classifySelected = 1
	self.curActiveDevice = gCS.LuaUtils.GetActiveDevice()

	if self.curActiveDevice == SGUI.GameDevice.KeyboardMouse then
		self.bindData.platformCtrl = gameProfile.isPlayStationMode and 1 or 0
	else
		self.bindData.platformCtrl = self.curActiveDevice == SGUI.GameDevice.PlayStation and 1 or 0
		gameProfile.isPlayStationMode = self.curActiveDevice == SGUI.GameDevice.PlayStation

		ProfileManager.SaveGameProperty()
	end
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	self.curActiveDevice = device

	if SGUI.GameDevice.KeyboardMouse < device then
		local isPSMode = device == SGUI.GameDevice.PlayStation
		self.bindData.platformCtrl = isPSMode and 1 or 0
		gameProfile.isPlayStationMode = isPSMode

		ProfileManager.SaveGameProperty()
	end
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnRefreshTab", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnRefreshTab", 1)
	self.bindData.layoutList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderLayoutListItem")
	self.bindData.layoutList.onGetTIndex = self:CreateAction("OnGetLayoutListTIndex")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnTabSelectedChanged")

	self.bindData.tabList:SetItemSelected(0, true)
end

function M:InitButtonLayoutData()
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

	self.typeNameList = {}

	for t = 1, #RebindActionConfig.ControllerTypeId do
		self.typeNameList[RebindActionConfig.ControllerTypeId[t]] = RebindActionConfig.ControllerTypeText[t]
	end
end

function M:InitRebindActionData()
	self.rebindGroupedData = {}
	local tempMapData = {}

	for i = 0, RebindActionControllerConfig.count - 1 do
		local config = RebindActionControllerConfig.LoadAt(i)

		if config then
			local actionMapId = config.ActionMapId

			if not tempMapData[actionMapId] then
				tempMapData[actionMapId] = {}
			end

			table.insert(tempMapData[actionMapId], {
				id = config.Id,
				actionName = config.Name,
				button = gCS.RebindMgr:GetButtonNamesByActionId(config.Id, RebindMode.Gamepad, config.IsComposite):ToTable(),
				isRebind = gCS.RebindMgr:IsActionRebound(config.Id, RebindMode.Gamepad),
				isEmpty = gCS.RebindMgr:IsActionEmpty(config.Id, RebindMode.Gamepad),
				canRebind = config.CanRebind,
				isComposite = config.IsComposite,
				character = config.FightSpiritId
			})
		end
	end

	local typeUsed = {}

	for i = 0, RebindActionActionMapConfig.count - 1 do
		local config = RebindActionActionMapConfig.LoadAt(i)

		if config then
			local mapId = config.Id
			local classify = config.Classify
			local actionType = config.Type
			local mapDetails = tempMapData[mapId]

			if mapDetails then
				if not self.rebindGroupedData[classify] then
					self.rebindGroupedData[classify] = {}
				end

				if not table.contains(typeUsed, actionType) and actionType ~= 0 then
					table.insert(self.rebindGroupedData[classify], {
						id = -1,
						actionName = self.typeNameList[actionType]
					})
					table.insert(typeUsed, actionType)
				end

				for _, detail in ipairs(mapDetails) do
					table.insert(self.rebindGroupedData[classify], detail)
				end
			end
		end
	end
end

function M:OnGetLayoutListTIndex(index)
	local data = self.leftLayoutList[index + 1]

	if not data then
		return 0
	else
		return data.tIndex
	end
end

function M:OnSimpleRenderLayoutListItem(btn, index)
	local data = self.leftLayoutList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex == 0 then
		store.title = data.title
	elseif data.tIndex == 1 then
		store.title = data.title

		store.dropMenu:SetOptions(self.settingList)

		local selectIndex = self:GetSettingConfigIndex()

		store.dropMenu:SelectOption(selectIndex)

		self.bindData.settingCtrl = selectIndex
		store.dropMenu.luaOptionClick = self:CreateAction("OnSettingSelectedChanged")
	elseif data.tIndex == 2 then
		store.title = data.title
		store.turnToBtn.luaClick = self:CreateAction("OnTurnToBtnClicked")
	elseif data.tIndex == 3 then
		store.title = data.title
	end

	store.interactable = 1
end

function M:ShowButtonPos()
	local showButtonInfo = self.rebindGroupedData[self.classifySelected]
	local allText = {}
	local allRebind = {}

	for t = 1, #showButtonInfo do
		local curButtonInfo = showButtonInfo[t]

		if curButtonInfo.id ~= -1 then
			if curButtonInfo.isComposite then
				allText.Composite = allText.Composite or {}
				allText.Composite.text = curButtonInfo.actionName
			else
				allText[curButtonInfo.button[1]] = allText[curButtonInfo.button[1]] or {}
				allText[curButtonInfo.button[1]].text = curButtonInfo.actionName
			end

			allRebind[curButtonInfo.button[1]] = curButtonInfo.isRebind
		end
	end

	local device = gCS.LuaUtils.GetActiveDevice()
	local storeGo = device == SGUI.GameDevice.PlayStation and "PSStoreGo" or "XboxStoreGo"

	for i = 0, RebindActionControllerIconConfig.count - 1 do
		local config = RebindActionControllerIconConfig.LoadAt(i)

		if not table.isNilOrEmpty(config) and not table.isNilOrEmpty(config[storeGo]) then
			local store = gStoreManager:GetStoreGroup(self.bindData[config[storeGo]].Store):GetStoreByWidget(self.bindData[config[storeGo]])

			if not allText[config.ButtonName] then
				store.text = "---"
			else
				store.text = allText[config.ButtonName].text
			end

			if allRebind[config.ButtonName] and allRebind[config.ButtonName] == true then
				store.isReboundCtrl = 0
			else
				store.isReboundCtrl = 1
			end
		end
	end
end

function M:OnTurnToBtnClicked()
	gPanelManager:CheckShow(gPanelId.SETTING_BTN_RESET_PANEL_CONTROLLER)
end

function M:GetKeyConfigIndex()
	return gameProfile.isCustomizeController and 0 or 1
end

function M:OnConfigSelectedChanged(btn, item)
	self.bindData.isDefaultCtrl = item.index - 1
	gameProfile.isCustomizeController = self.bindData.isDefaultCtrl ~= 1

	ProfileManager.SaveGameProperty()

	if gameProfile.isCustomizeButton then
		gMessageManager:SendMessage(gEventConstants.REBIND_TO_CUSTOM, RebindMode.Gamepad)
	else
		gMessageManager:SendMessage(gEventConstants.REBIND_TO_DEFAULT, RebindMode.Gamepad)
	end

	self:InitRebindActionData()
	self:ShowButtonPos()
end

function M:OnSimpleClickLayoutList(btn, index)
	return
end

function M:OnSimpleRenderTabListItem(btn, index)
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

function M:OnTabSelectedChanged(btn, index)
	self.classifySelected = self.bindData.tabList.selectedIndex + 1
	self.bindData.pageCtrl = self.bindData.tabList.selectedIndex
end

function M:OnRefreshTab(step)
	local tabNum = #RebindActionConfig.ControllerClassifyOutId
	local nextStep = self.bindData.tabList.selectedIndex + step

	if nextStep < 0 then
		nextStep = tabNum - 1
	elseif tabNum <= nextStep then
		nextStep = 0
	end

	self.bindData.tabList:SetItemSelected(nextStep, true)

	self.bindData.pageCtrl = nextStep
end

function M:GetSettingConfigIndex()
	return gameProfile.isNewControllerSetting and 0 or 1
end

function M:OnSettingSelectedChanged(btn, item)
	self.bindData.settingCtrl = item.index - 1
	gameProfile.isNewControllerSetting = self.bindData.settingCtrl == 0

	ProfileManager.SaveGameProperty()
	gMessageManager:SendMessage(gEventConstants.SETTING_CONTROLLER_TYPE_CHANGE, gameProfile.isNewControllerSetting)
end
