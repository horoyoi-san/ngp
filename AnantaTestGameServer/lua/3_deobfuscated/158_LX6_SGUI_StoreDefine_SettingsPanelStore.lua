local GameConfig = LTConfig.GameConfig
local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local ShezhiPanelShezhiConfig = LTConfig.ShezhiPanelShezhiConfig
local RebindMode = LX6.Manager.RebindMode
local MessageConfig = LTConfig.MessageConfig
local ProfileManager = LX6.Engine.ProfileManager
local SettingsAction = require("LX6/GUI/Setting/SettingsAction")
local gameProfile = ProfileManager.gameProfile
local languageProfile = ProfileManager.languageProfile
local GameQualitySettings = LX6.Manager.GameQualitySettings
local InputActionBind = SGUI.InputActionBind
local PanelManager = LX6.Manager.PanelManager
local DeviceDisplayLevel = LX6.Quality.DeviceDisplayLevel
local DeviceGraphicsQuality = LX6.Quality.DeviceGraphicsQuality
C_SettingsPanelStore = DefClass("C_SettingsPanelStore", C_SettingsPanelStore, C_StoreGroup)
GroupName2Class.SettingsPanelStore = C_SettingsPanelStore
local M = C_SettingsPanelStore
local ActiveIndex = {
	HideInPC = 1,
	Show = 3,
	Hide = 0,
	HideInPhone = 2
}
local tType2tIndex = {
	[0] = 0,
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	nil,
	nil,
	6,
	7,
	8
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

local function GetFpsIndex()
	local normalFps = ShezhiPanelConfig.NormalFps

	for i = 1, #normalFps do
		if gameProfile.fpsType <= normalFps[i] then
			return i
		end
	end

	if normalFps[#normalFps] < gameProfile.fpsType then
		return #normalFps
	end

	print_error("当前fps找不到对应的配置档位！！！！fps = " .. gameProfile.fpsType)
end

local function GetLanguageIndex()
	local lang = LTConfig.TableGetLanguage()

	for i = 1, #ShezhiPanelConfig.LanguagesDisplay do
		if lang == ShezhiPanelConfig.LanguagesDisplay[i] then
			return i
		end
	end
end

function M:GetSaveProfilePath(index)
	return self.tIndex2SaveProfilePath[index]
end

function M:ctor(name, id, isSub)
	self.page = 1
end

function M:OnAwake()
	self.isEnableController = SGUI.GameDevice.KeyboardMouse < InputActionBind.activeGameDevice or false
	self.controllerIndex = InputActionBind.activeGameDevice
	self.bindData.btnBack.luaClick = self:CreateAction("ClosePanel")
	self.bindData.btnExitGame.luaClick = self:CreateAction("ExitGame")
	self.bindData.resetBtn.luaClick = self:CreateAction("ResetBtnClick")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnRefreshItem")
	self.bindData.itemList.onGetTIndex = self:CreateAction("OnGetItemListTIndex")
	self.bindData.itemList.luaLayoutSet = self:CreateAction("OnLayOutSet")
	self.bindData.backToLoginBtn.luaClick = self:CreateAction("DoKickToLogin", gLoginManager)
	self.bindData.accountBindBtn.luaClick = self:CreateAction("ShowAccountBind", gLoginManager)
	self.bindData.OutOfJamBtn.luaClick = self:CreateAction("OnOutOfJam")

	if self.bindData.rebindTabRect then
		self.bindData.rebindTabRect.OnRenderTab = self:CreateAction("OnTabRectRender")
	end

	self.ANIME_TYPE = {
		OPEN = "fx_S_SettingsPanel_open",
		SWITCH_TAB = "fx_S_SettingsPanel_tabswitch",
		CLOSE = "fx_S_SettingsPanel_close"
	}
	self.msgEvents = {
		[gEventConstants.SETTING_SEND_RESOLUTION_NAME] = self:CreateAction("SetResolutionName"),
		[gEventConstants.SETTING_SEND_ALIASING_NAME] = self:CreateAction("SetAliasingName"),
		[gEventConstants.SETTING_REFRESH_INFOS] = self:CreateAction("SetRefreshiInfos"),
		[gEventConstants.SETTING_SEND_GAMEPAD_SHOW_ICON] = self:CreateAction("SetGamePadShowIcon"),
		[gEventConstants.REBIND_CLOSE_PANEL] = self:CreateAction("OnButtonPageShow")
	}

	self:RegisterMessageEvents(self.msgEvents)
	self:RefreshSaveProfilePath()
	self:OnInit()
end

function M:OnInit()
	self.lastSelectDropMenu = nil
	self.isSetData = false
	self.IsPCPlatform = false
	self.IsOnAndroid = false
	self.IsOnIOS = false
	self.IsOnPS5 = false
	self.IsOnMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.page = 1
	self.currentPageItemGroup = {}
	self.itemGroup = {}
	self.itemGroupByPage = {}
	self.isReloadTip = false

	if gCS.LuaUtils.IsOnAndroid or gQualityManager:IsInEditorAndroidPlatform() then
		self.IsOnAndroid = true
	elseif gCS.LuaUtils.IsOnPS5 or gQualityManager:IsInEditorPSPlatform() then
		self.IsOnPS5 = true
	elseif gCS.LuaUtils.IsOnIOS or gQualityManager:IsInEditorIOSPlatform() then
		self.IsOnIOS = true
	else
		self.IsPCPlatform = gCS.LuaUtils.IsNonMobileAdaptive()
	end

	self.isInGame = true
	self.specialType = {
		[ShezhiPanelShezhiConfig.Resolution] = true,
		[ShezhiPanelShezhiConfig.Aliasings] = true,
		[ShezhiPanelShezhiConfig.FrameGen] = true,
		[ShezhiPanelShezhiConfig.DisplayIndex] = true
	}
	self.displayLevel2Name = {}

	for i = 1, #ShezhiPanelConfig.DisplayLevelType do
		local info = ShezhiPanelConfig.DisplayLevelType[i]
		self.displayLevel2Name[info.type] = info.name
	end
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_SETTINGS_PANEL) and 1 or 0
end

function M:OnGroupDisable()
	return
end

function M:OnActiveDeviceChange(scheme)
	self.controllerIndex = scheme
	self.isEnableController = SGUI.GameDevice.KeyboardMouse < scheme
end

function M:OnShow(panelId, data)
	if data then
		self.page = data.page or 1

		if data.isLoginShow ~= nil then
			self.isInGame = data.isLoginShow
		end
	end

	self.bindData.isLoginShow = self.isInGame and 0 or 1
	self.bindData.isBackToLogin = BOOL2CTL[self.IsOnPS5]

	self:PlayAnimation(self.ANIME_TYPE.OPEN)
	self:InitTabInfo()

	if not self.STATE_OnShowOnce then
		self:InitSettingData()
	end

	self:SwitchPage(self.page)

	self.isSetData = true
end

function M:InitTabInfo()
	self.tabTitle = {}
	local TabTitle = ShezhiPanelConfig.LoginShezhiTabTitle

	if self.isInGame then
		TabTitle = ShezhiPanelConfig.TabTitle
	end

	for i = 1, #TabTitle do
		local info = ShezhiPanelConfig.TabTitle[i]
		local view = {
			active = true,
			title = info.name,
			page = info.page
		}

		if info.page == ShezhiPanelConfig.PCButtonPage then
			view.active = self.IsPCPlatform and true or false
		end

		if info.page == ShezhiPanelConfig.ControllerPage then
			view.active = (self.IsOnPS5 or self.IsPCPlatform) and true or false
		end

		table.insert(self.tabTitle, view)
	end

	if table.isNilOrEmpty(self.tabTitle) then
		print_error("ShezhiPanelConfig.TabTitle为空")

		return
	end

	local tabs = {}
	local index = 0
	local selelctedIndex = 0

	for i = 1, #self.tabTitle do
		local info = self.tabTitle[i]

		if info.active then
			if info.page == self.page then
				selelctedIndex = index
			end

			index = index + 1
			tabs[index] = {
				title = info.title,
				page = info.page
			}
		end
	end

	self.SubGroup.CommonTabSingleStore:SetData(tabs, nil, selelctedIndex, nil, self:CreateAction("OnChangeTab"), self:CreateAction("OnRenderTab"))

	self.pageName = self.tabTitle[self.page].title
end

function M:InitSettingData()
	self.itemGroupByPage = {}

	for i = 1, ShezhiPanelShezhiConfig.count do
		local cfg = ShezhiPanelShezhiConfig.GetConfig(i)

		if cfg then
			if self.itemGroupByPage[cfg.Page] == nil then
				self.itemGroupByPage[cfg.Page] = {}
			end

			local view = {}
			local value = self:GetSaveProfilePath(cfg.SliderProfile)
			view.Id = cfg.Id
			view.tType = cfg.S_ItemType
			view.tIndex = tType2tIndex[view.tType]
			view.panel = cfg.Page
			view.title = cfg.Title
			view.iOSItemName, view.iOSItemIcon, view.iOSItemIndex = self:GetItemNameAndIcon(cfg.Id, cfg.iOSName)
			view.PCItemName, view.PCItemIcon, view.PCItemIndex = self:GetItemNameAndIcon(cfg.Id, cfg.PCName)
			view.PS5ItemName, view.PS5ItemIcon, view.PS5ItemIndex = self:GetItemNameAndIcon(cfg.Id, cfg.PS5Name)
			view.AndroidItemName, view.AndroidItemIcon, view.AndroidItemIndex = self:GetItemNameAndIcon(cfg.Id, cfg.AndriodName)
			view.cfgActive = self:IsShowInPlatform(cfg.Active)
			view.SlideAction = cfg.SlideAction
			view.ClickAction = cfg.ClickAction
			view.SelectAction = cfg.SelectAction
			view.TurnToAction = cfg.TurnToAction
			view.SliderProfile = cfg.SliderProfile
			view.SliderSetValues = cfg.SliderSetValues
			view.ClickProfile = cfg.ClickProfile
			view.IsConnectDisplayLevel = cfg.IsConnectDisplayLevel == 1
			view.IconIndex = cfg.IconIndex
			view.StartAction = cfg.StartAction
			view.ResetAction = cfg.ResetAction
			view.IsOpen = cfg.IsOpen == 1
			view.OpenAction = cfg.OpenAction
			view.sliderValue = value
			view.sliderValueStr = value and math.floor(value) or nil
			view.selectIndex = self:GetSaveProfilePath(cfg.SelectProfile) or 0
			view.isOn = self:GetSaveProfilePath(cfg.ClickProfile[1]) or false
			view.btnInfoIndex = view.isOn and 2 or 1
			view.IsShowReloadTips = cfg.IsShowReloadTips == 1 or false
			view.IsLoginShow = cfg.IsLoginShow == 1

			if view.cfgActive or view.isOpen then
				table.insert(self.itemGroupByPage[cfg.Page], view)
				self:InitSettingsItemData(view)
			end
		end
	end
end

function M:InitSettingsItemData(item)
	local isSpecial = true
	local itemsName = item.iOSItemName
	local itemsIcon = item.iOSItemIcon
	local itemsIndex = item.iOSItemIndex

	if self.IsOnAndroid and not table.isNilOrEmpty(item.AndroidItemName) then
		itemsName = item.AndroidItemName
		itemsIcon = item.AndroidItemIcon
		itemsIndex = item.AndroidItemIndex
	elseif self.IsPCPlatform and not table.isNilOrEmpty(item.PCItemName) then
		itemsName = item.PCItemName
		itemsIcon = item.PCItemIcon
		itemsIndex = item.PCItemIndex
	elseif self.IsOnPS5 and not table.isNilOrEmpty(item.PS5ItemName) then
		itemsName = item.PS5ItemName
		itemsIcon = item.PS5ItemIcon
		itemsIndex = item.PS5ItemIndex
	end

	if item.Id == ShezhiPanelShezhiConfig.Resolution then
		itemsName = {}
		itemsIcon = {}
		itemsIndex = {}
		local tempRes = gQualityManager:GetPCResolutions()

		for i = 1, #tempRes do
			if languageProfile.pcResolutionScreenHeight == tempRes[i].height and languageProfile.pcResolutionScreenWidth == tempRes[i].width then
				item.selectIndex = i
			end

			local str = tempRes[i].width .. "x" .. tempRes[i].height

			table.insert(itemsName, str)
			table.insert(itemsIndex, i)
		end
	end

	if item.Id == ShezhiPanelShezhiConfig.Aliasings then
		itemsName = {}
		itemsIcon = {}
		itemsIndex = {}
		local tempRes = gQualityManager:GetAliasings()
		local antialiasingType = ShezhiPanelConfig.AntialiasingType

		for i = 1, #tempRes do
			for t = 1, #antialiasingType do
				if gameProfile.antiAliasing == tempRes[i] then
					item.selectIndex = i
				end

				if tempRes[i] == antialiasingType[t].type then
					table.insert(itemsName, antialiasingType[tempRes[i]].name)
					table.insert(itemsIndex, i)
				end
			end
		end
	end

	if item.Id == ShezhiPanelShezhiConfig.AntialiasingQuality then
		itemsName = {}
		itemsIcon = {}
		itemsIndex = {}
		local tempRes = gQualityManager:GetAntiAliasingQualitys()
		local antialiasingQualityType = ShezhiPanelConfig.AntialiasingQualityType

		for i = 1, #tempRes do
			for t = 1, #antialiasingQualityType do
				if gameProfile.antialiasingQuality == tempRes[i] then
					item.selectIndex = i
				end

				if tempRes[i] == antialiasingQualityType[t].type then
					table.insert(itemsName, antialiasingQualityType[tempRes[i]].name)
					table.insert(itemsIndex, i)
				end
			end
		end
	elseif item.Id == ShezhiPanelShezhiConfig.AntialiasingLevel then
		itemsName = {}
		itemsIcon = {}
		itemsIndex = {}
		local tempRes = gQualityManager:GetAntiAliasingLevels()
		local antialiasingLevelType = ShezhiPanelConfig.AntialiasingLevelType

		for i = 1, #tempRes do
			if gameProfile.antialiasingLevel == tempRes[i] then
				item.selectIndex = i
			end

			table.insert(itemsName, antialiasingLevelType[tempRes[i]])
			table.insert(itemsIndex, i)
		end
	elseif item.Id == ShezhiPanelShezhiConfig.FrameGen then
		itemsName = {}
		itemsIcon = {}
		itemsIndex = {}
		local tempGen = gQualityManager:GetFrameGenerationQuality()
		local frameGenType = ShezhiPanelConfig.FrameGenType

		for i = 1, #tempGen do
			if gameProfile.frameGeneration == tempGen[i] then
				item.selectIndex = i
			end

			table.insert(itemsName, frameGenType[tempGen[i]])
			table.insert(itemsIndex, i)
		end
	elseif item.Id == ShezhiPanelShezhiConfig.DisplayIndex then
		local tempRes = gQualityManager:GetDisplayIndex()

		for i = 1, #tempRes do
			local name = string.format(ShezhiPanelConfig.DisplayDeviceName, i)

			table.insert(itemsName, name)
			table.insert(itemsIndex, i)
		end
	else
		isSpecial = false
	end

	if not table.isNilOrEmpty(itemsName) then
		item.itemList = {}

		for t = 1, #itemsName do
			local tView = {
				fatherId = item.Id
			}

			if item.panel == ShezhiPanelConfig.PCButtonPage then
				-- Nothing
			elseif item.panel ~= ShezhiPanelConfig.ControllerPage then
				tView.label = itemsName[t]
				tView.iconId = itemsIcon[t] or 0
				tView.itemIndex = itemsIndex[t]
				tView.index = t
				tView.isSelect = item.selectIndex == t
			end

			if item.Id == ShezhiPanelShezhiConfig.DisplayLevel then
				tView.index = self.IsPCPlatform and t + DeviceDisplayLevel.Ultra - 1 or t + DeviceDisplayLevel.Movie - 1
			end

			if gQualityManager:CheckIsDisplayLevel(item.Id) then
				tView.index = self.IsPCPlatform and t + DeviceGraphicsQuality.L3 - 1 or t + DeviceGraphicsQuality.L4 - 1
			end

			table.insert(item.itemList, tView)
		end
	end

	return isSpecial
end

function M:OnChangeTab(uList)
	local data = self.SubGroup.CommonTabSingleStore:GetSelectedItem()
	local page = data.page

	if self.page == page then
		return
	end

	if self.IsPCPlatform or self.IsOnPS5 then
		if self.page < page then
			self.bindData.pageAnim:Play("vx_S_SettingsPanel_PC_open_to_left")
		else
			self.bindData.pageAnim:Play("vx_S_SettingsPanel_PC_open_to_right")
		end
	elseif self.IsOnMobile then
		self.bindData.playAnim:Play("vx_S_SettingsPanel_2")
	end

	self.page = page
	self.pageName = data.title

	self:SwitchPage(self.page)
end

function M:OnRenderTab(btn, index, data, store, isSub)
	if btn.isSelected then
		self.pageName = data.title
	end
end

function M:SwitchPage(page)
	self.type7TabTopIndex = 0

	self:PlayAnimation(self.ANIME_TYPE.SWITCH_TAB)

	self.itemGroup = self.itemGroupByPage[self.page]
	self.bindData.isShowReset = BOOL2CTL[self:CheckCanReset()]

	self.bindData.itemList:SetSimpleList(self.page ~= ShezhiPanelConfig.PCButtonPage and self.page ~= ShezhiPanelConfig.ControllerPage and #self.itemGroup or 0)

	if self.IsOnMobile then
		return
	end

	if self.curSettingsKeyPanelStore then
		self.curSettingsKeyPanelStore:OnClose()

		self.curSettingsKeyPanelStore = nil
	end

	if self.page == ShezhiPanelConfig.PCButtonPage then
		self.bindData.itemList.activation = false
		self.bindData.rebindTabRect.selectedIndex = 0
	elseif self.page == ShezhiPanelConfig.ControllerPage then
		self.bindData.itemList.activation = false
		self.bindData.rebindTabRect.selectedIndex = 1
	else
		self.bindData.itemList.activation = true
		self.bindData.rebindTabRect.selectedIndex = -1
	end
end

function M:GetItemNameAndIcon(id, nameInfo)
	local nameList = {}
	local iconList = {}
	local itemIndexList = {}
	local bottomId = 1
	local isDisplayLevel = id == ShezhiPanelShezhiConfig.DisplayLevel

	if isDisplayLevel or gQualityManager:CheckIsDisplayLevel(id) then
		bottomId = self.IsPCPlatform and DeviceDisplayLevel.Ultra or DeviceDisplayLevel.Movie
	end

	if gQualityManager:CheckIsDisplayLevel(id) then
		bottomId = self.IsPCPlatform and DeviceGraphicsQuality.L3 or DeviceGraphicsQuality.L4
	end

	for i = bottomId, #nameInfo do
		if isDisplayLevel then
			local name = tonumber(nameInfo[i].name)

			if self.displayLevel2Name[name] then
				local realName = self.displayLevel2Name[name]

				table.insert(nameList, realName)
				table.insert(itemIndexList, name)
			end
		else
			table.insert(nameList, nameInfo[i].name)
			table.insert(itemIndexList, i)
		end

		table.insert(iconList, nameInfo[i].iconId)
	end

	return nameList, iconList, itemIndexList
end

function M:IsShowInPlatform(index)
	if index == ActiveIndex.Hide then
		return false
	end

	if (self.IsPCPlatform or self.IsOnPS5) and index == ActiveIndex.HideInPC then
		return false
	end

	if (self.IsOnIOS or self.IsOnAndroid) and index == ActiveIndex.HideInPhone then
		return false
	end

	return true
end

function M:ClosePanel()
	self:PlayAnimation(self.ANIME_TYPE.CLOSE)
	gPanelManager:Close(gPanelId.S_SETTINGS_PANEL)
end

function M:OnLayOutSet()
	if not self.isEnableController then
		self.bindData.itemList:GoToIndex(0, true)
	end

	self.bindData.itemList:SetNavSelectToTop()
end

function M:OnGetItemListTIndex(index)
	local data = self.itemGroup[index + 1]

	if not data then
		return 0
	else
		return data.tIndex
	end
end

function M:OnRefreshItem(btn, index)
	local data = self.itemGroup[index + 1]

	if not data then
		return
	end

	gQualityManager.isSettingRefresh = true

	if self.lastSelectDropMenu then
		self.lastSelectDropMenu:ClosePopUp(true)

		self.lastSelectDropMenu = nil
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tType == 0 then
		store.title = data.title
		store.isBtnOnCtrl = data.isOn and 1 or 0
		store.onOffBtn.luaClick = self:CreateActionWithArgs("OnChangeBtnState", {
			isOnOff = true,
			tType = data.tType,
			id = id,
			index = index + 1
		})
		store.leftBtn.luaClick = self:CreateActionWithArgs("OnIncreaseOrDecreaseBtnState", {
			addValue = -1,
			tType = data.tType,
			id = id,
			index = index + 1
		})
		store.rightBtn.luaClick = self:CreateActionWithArgs("OnIncreaseOrDecreaseBtnState", {
			addValue = 1,
			tType = data.tType,
			id = id,
			index = index + 1
		})
		store.slider.luaValueChanged = self:CreateActionWithArgs("OnSliderValueChange", index + 1)
		store.slider.value = data.sliderValue
	elseif data.tType == 1 then
		store.title = data.title

		if data.sliderValue then
			store.leftBtn.luaClick = self:CreateActionWithArgs("OnIncreaseOrDecreaseBtnState", {
				addValue = -1,
				tType = data.tType,
				id = id,
				index = index + 1
			})
			store.rightBtn.luaClick = self:CreateActionWithArgs("OnIncreaseOrDecreaseBtnState", {
				addValue = 1,
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
	elseif data.tType == 2 then
		local selectIndex = data.selectIndex
		store.title = data.title

		store.dropMenu:SetOptions(self.itemGroup[index + 1].itemList)

		local view = {
			dropMenu = store.dropMenu,
			index = index + 1
		}

		if not table.isNilOrEmpty(self.itemGroup[index + 1].itemList) then
			for i = 1, #self.itemGroup[index + 1].itemList do
				local item = self.itemGroup[index + 1].itemList[i]

				if self.itemGroup[index + 1].selectIndex == item.index then
					selectIndex = i

					break
				end
			end
		end

		store.dropMenu.luaOptionClick = self:CreateActionWithArgs("OnSelectedChanged", view)

		store.dropMenu:SelectOption(selectIndex - 1)
	elseif data.tType == 3 then
		store.title = data.title
	elseif data.tType == 4 then
		store.title = data.title
		store.turnToBtn.luaClick = self:CreateActionWithArgs("OnTurnToBtnClick", index + 1)
	elseif data.tType == 5 then
		store.title = data.title
	elseif data.tType == 6 then
		store.title = data.title
		store.leftBtn.luaPress = self:CreateActionWithArgs("OnSetBtnState", {
			isOnOff = false,
			tType = data.tType,
			id = id,
			index = index + 1
		})
		store.rightBtn.luaClick = self:CreateActionWithArgs("OnSetBtnState", {
			isOnOff = true,
			tType = data.tType,
			id = id,
			index = index + 1
		})
	elseif data.tType == 7 then
		self.itemType7TabTopIndex = index
		store.leftBtn.luaPress = self:CreateActionWithArgs("OnType7TabClick", -1)
		store.rightBtn.luaClick = self:CreateActionWithArgs("OnType7TabClick", 1)
		store.tabList.luaRenderItem = self:CreateAction("OnRefreshTabList")
		store.tabList.luaClick = self:CreateAction("OnSelectTabList")
		store.tabIndex = self.type7TabTopIndex
		local tabList = {}

		for i = 1, #ShezhiPanelConfig.ControllerTabTitle do
			tabList[i] = {
				index = ShezhiPanelConfig.ControllerTabTitle[i].page,
				title = ShezhiPanelConfig.ControllerTabTitle[i].name
			}
		end

		local type = self.controllerIndex == SGUI.GameDevice.Xbox and 0 or 1
		store.normalType = type
		store.farType = type
		store.closeType = type

		store.tabList:SetList(tabList)
	elseif data.tType == 8 then
		store.joystickModeBtn.isSelected = data.isOn
		store.settingModeBtn.isSelected = not data.isOn
		store.joystickModeBtn.luaClick = self:CreateActionWithArgs("OnSetVehicleMode", {
			isJoysticMode = true,
			tType = data.tType,
			id = id,
			index = index + 1
		})
		store.settingModeBtn.luaClick = self:CreateActionWithArgs("OnSetVehicleMode", {
			isJoysticMode = false,
			tType = data.tType,
			id = id,
			index = index + 1
		})
	else
		print("类型超出范围，还未接入对应template")
	end

	store.interactable = BOOL2CTL[SettingsAction.CheckFunc(data.OpenAction, data)]
	gQualityManager.isSettingRefresh = false
end

function M:OnRefreshTabList(btn, index, data)
	local store = gStoreManager:GetStoreGroup("ControllerTab_Template"):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		btn.isSelected = self.type7TabTopIndex == data.index - 1
		self.bindData.isShowReset = BOOL2CTL[self:CheckCanReset()]
	end
end

function M:OnSelectTabList(btn, data)
	self.type7TabTopIndex = data.index - 1

	self.bindData.itemList:RefreshElement(self.itemType7TabTopIndex)

	self.bindData.isShowReset = BOOL2CTL[self:CheckCanReset()]
end

function M:OnType7TabClick(data)
	if self.type7TabTopIndex == nil then
		self.type7TabTopIndex = 0
	end

	if self.type7TabTopIndex <= 0 and data < 0 then
		return
	end

	if self.type7TabTopIndex >= 2 and data > 0 then
		return
	end

	self.type7TabTopIndex = self.type7TabTopIndex + data

	self.bindData.itemList:RefreshElement(self.itemType7TabTopIndex)

	self.bindData.isShowReset = BOOL2CTL[self:CheckCanReset()]
end

function M:OnClose()
	ProfileManager.SaveGameProperty()
	ProfileManager.SaveDevProperty()
	ProfileManager.SaveLanguageProperty()
end

function M:PlayAnimation(anime)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.playAnim, anime)
end

function M:GetBaseItemIdFromGroupId(id)
	for i = 1, #self.currentPageItemGroup do
		if self.currentPageItemGroup[i] and self.currentPageItemGroup[i].Id == id then
			return i
		end
	end

	return nil
end

function M:OnIncreaseOrDecreaseBtnState(params)
	local store = gStoreManager:GetStoreGroup("SettingTemplate_" .. params.tType):GetStoreById(params.id)

	if store then
		local sliderValue = self.itemGroup[params.index].sliderValue

		if params.addValue ~= nil then
			sliderValue = sliderValue + params.addValue

			if sliderValue <= 0 then
				store.slider.value = 0
				sliderValue = 0
			else
				store.slider.value = sliderValue
			end

			self:OnSliderValueChange(params.index, sliderValue, params.id)
		else
			if not self.itemGroup[params.index].isOn then
				store.slider.value = 0
				sliderValue = 0
			end

			self:OnSliderValueChange(params.index, sliderValue, params.id)
		end
	end
end

function M:OnChangeBtnState(params)
	local store = gStoreManager:GetStoreGroup("SettingTemplate_" .. params.tType):GetStoreById(params.id)

	if store then
		self.itemGroup[params.index].isOn = not self.itemGroup[params.index].isOn
		store.isBtnOnCtrl = self.itemGroup[params.index].isOn and 1 or 0
		local data = {
			value = self.itemGroup[params.index].isOn
		}

		SettingsAction.RunFunc(self.itemGroup[params.index].ClickAction[1], data)

		self.bindData.isShowReset = BOOL2CTL[self:CheckCanReset()]
	end
end

function M:OnSetBtnState(params)
	local store = gStoreManager:GetStoreGroup("SettingTemplate_" .. params.tType):GetStoreById(params.id)

	if store then
		self.itemGroup[params.index].isOn = params.isOnOff
		store.isBtnOnCtrl = self.itemGroup[params.index].isOn and 1 or 0
		local data = {
			value = self.itemGroup[params.index].isOn
		}

		SettingsAction.RunFunc(self.itemGroup[params.index].ClickAction[1], data)

		self.bindData.isShowReset = BOOL2CTL[self:CheckCanReset()]
	end
end

function M:OnSliderValueChange(index, value, instanceId)
	if self.isSetMinMaxValue then
		return
	end

	local store = gStoreManager:GetStoreGroup("SettingTemplate_" .. self.itemGroup[index].tType):GetStoreById(instanceId)

	if store then
		store.isBtnOnCtrl = self.itemGroup[index].isOn and 1 or 0
	end

	if self.itemGroup[index].sliderValue ~= value then
		self.itemGroup[index].sliderValue = value
	end

	local data = {
		value = value
	}

	SettingsAction.RunFunc(self.itemGroup[index].SlideAction, data)

	self.bindData.isShowReset = BOOL2CTL[self:CheckCanReset()]
end

function M:OnSelectedChanged(view, btn, item)
	local index = view.index

	if self.isSetData then
		self.lastSelectDropMenu = view.dropMenu
		local data = {
			value = item.index
		}
		self.itemGroup[index].selectIndex = item.index

		if self.itemGroup[index].IsShowReloadTips and self.isInGame then
			gDisplayMessageMgr:ShowMessage(MessageConfig.SettingReloadTips)
		end

		if self.itemGroup[index].IsConnectDisplayLevel and gameProfile.displayLevel ~= gQualityManager:GetCustomLevel() then
			self:SetCustomLevel()
		end

		SettingsAction.RunFunc(self.itemGroup[index].SelectAction, data)
	elseif not table.isNilOrEmpty(self.itemGroup[index].StartAction) then
		for k = 1, self.itemGroup[index].StartAction.length do
			local data = {
				fatherId = index
			}

			SettingsAction.RunFunc(self.itemGroup[index].StartAction[k], data)
		end
	end

	self.bindData.isShowReset = BOOL2CTL[self:CheckCanReset()]
end

function M:OnTurnToBtnClick(index)
	SettingsAction.RunFunc(self.itemGroup[index].TurnToAction)
end

function M:OnSetVehicleMode(params)
	local store = gStoreManager:GetStoreGroup("SettingTemplate_" .. params.tType):GetStoreById(params.id)

	if store then
		store.joystickModeBtn.isSelected = params.isJoysticMode
		store.settingModeBtn.isSelected = not params.isJoysticMode
		self.itemGroup[params.index].isOn = params.isJoysticMode
		local data = {
			value = self.itemGroup[params.index].isOn
		}

		SettingsAction.RunFunc(self.itemGroup[params.index].ClickAction[1], data)

		self.bindData.isShowReset = BOOL2CTL[self:CheckCanReset()]
	end
end

function M:SetCustomLevel()
	for _, list in pairs(self.itemGroupByPage) do
		for i = 1, #list do
			if list[i].Id == ShezhiPanelShezhiConfig.DisplayLevel then
				list[i].selectIndex = gQualityManager:GetCustomLevel()

				break
			end
		end
	end

	for i = 1, #self.itemGroup do
		if self.itemGroup[i].Id == ShezhiPanelShezhiConfig.DisplayLevel then
			self.itemGroup[i].selectIndex = gQualityManager:GetCustomLevel()
		end
	end

	gameProfile.displayLevel = gQualityManager:GetCustomLevel()

	self.bindData.itemList:RefreshList()
end

function M:SetResolutionName(_, data)
	local fatherItem = self.itemGroup[data.fatherId]
	local baseItemIndex = self:GetBaseItemIdFromGroupId(fatherItem.Id)

	if baseItemIndex == nil then
		return
	end

	if fatherItem.PCItemName and data.name then
		local itemName = {}
		local itemList = {}

		for i = 1, #data.name do
			local antialiasingType = ShezhiPanelConfig.AntialiasingType

			for t = 1, #antialiasingType do
				if data.name[i] == antialiasingType[t].type then
					itemName[i] = antialiasingType[data.name[i]].name
				end
			end

			itemList[i] = {
				name = itemName[i],
				fatherId = data.fatherId
			}

			if gameProfile.antiAliasing == data.name[i] then
				fatherItem.selectIndex = i
				fatherItem.selectName = itemName[i]
			end
		end

		if not table.contains(data.name, gameProfile.antiAliasing) or fatherItem.selectIndex == 0 then
			local index = GameQualitySettings.SetAntiAliasingQuality()

			for i = 1, #data.name do
				if index == data.name[i] then
					fatherItem.selectIndex = i
					fatherItem.selectName = itemName[i]
				end
			end
		end

		fatherItem.PCItemName = itemName
		fatherItem.itemList = itemList
	end
end

function M:SetAliasingName(_, data)
	local fatherItem = self.itemGroup[data.fatherId]
	local baseItemIndex = self:GetBaseItemIdFromGroupId(fatherItem.Id)

	if baseItemIndex == nil then
		return
	end

	if fatherItem.PCItemName and data.name then
		local itemName = {}
		local itemList = {}

		for i = 1, #data.name do
			local antialiasingType = ShezhiPanelConfig.AntialiasingType

			for t = 1, #antialiasingType do
				if data.name[i] == antialiasingType[t].type then
					itemName[i] = antialiasingType[data.name[i]].name
				end
			end

			itemList[i] = {
				name = itemName[i],
				fatherId = data.fatherId
			}

			if gameProfile.antiAliasing == data.name[i] then
				fatherItem.selectIndex = i
				fatherItem.selectName = itemName[i]
			end
		end

		if not table.contains(data.name, gameProfile.antiAliasing) or fatherItem.selectIndex == 0 then
			local index = GameQualitySettings.SetAntiAliasingQuality()

			for i = 1, #data.name do
				if index == data.name[i] then
					fatherItem.selectIndex = i
					fatherItem.selectName = itemName[i]
				end
			end
		end

		fatherItem.PCItemName = itemName
		fatherItem.itemList = itemList
	end
end

function M:SetRefreshiInfos(_, data)
	self:RefreshSettingsInfos(data)
end

function M:SetGamePadShowIcon(_, data)
	return
end

function M:ExitGame()
	if gLoginManager:CheckIsTgsPack() then
		gDisplayMessageMgr:ShowMessage(MessageConfig.TGSLogoutGame, function ()
			self:ClosePanel()
			gLoginManager:TGSExit(false)
		end)

		return
	end

	gDisplayMessageMgr:ShowMessageTriple(MessageConfig.LogoutGame, function ()
		print_debug("Cannel LogoutGame msg")
	end, function ()
		self:ClosePanel()
		gLoginManager:DoKickToLogin(nil, nil, true)
	end, function ()
		self:ClosePanel()
		gCS.LuaUtils.QuitApplication()
	end)
end

function M:ResetBtnClick()
	self.isReloadTip = true

	gDisplayMessageMgr:ShowMessage(MessageConfig.ShezhiReset, function ()
		if self.page == ShezhiPanelConfig.ControllerPage or self.page == ShezhiPanelConfig.PCButtonPage then
			gCS.RebindMgr:RemoveAllOverrides(self.page == ShezhiPanelConfig.PCButtonPage and RebindMode.Keyboard or RebindMode.Gamepad)

			if self.page == ShezhiPanelConfig.PCButtonPage then
				gameProfile.isCustomizeButton = false
			else
				gameProfile.isCustomizeController = false
			end

			ProfileManager.SaveGameProperty()
			self:OnButtonPageShow()

			return
		end

		for i = 1, #self.itemGroup do
			if self.itemGroup[i].ResetAction then
				SettingsAction.RunFunc(self.itemGroup[i].ResetAction)
			end
		end

		if self.page == 1 then
			local recommendLevel = gQualityManager.DeviceQuality
			gameProfile.displayLevel = gQualityManager.DefaultQuality

			gQualityManager:LoadQualityData(recommendLevel, gameProfile.displayLevel)
			gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS, {
				refreshToTop = true
			})
			gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_CHAR_MESH)
		else
			gMessageManager:SendMessage(gEventConstants.SETTING_REFRESH_INFOS, {
				refreshToTop = true
			})
		end

		ProfileManager.SaveGameProperty()
		ProfileManager.SaveDevProperty()
		ProfileManager.SaveLanguageProperty()
		gDisplayMessageMgr:ShowMessage(self.isReloadTip and MessageConfig.ResetComplete or MessageConfig.SettingReloadTips)

		self.bindData.isShowReset = BOOL2CTL[self:CheckCanReset()]
	end, nil, self.pageName)
end

function M:RefreshSettingsInfos(data)
	self:RefreshSaveProfilePath()

	local isShowReloadTips = false

	for i = 1, #self.itemGroup do
		local item = self.itemGroup[i]
		local cfg = ShezhiPanelShezhiConfig.GetConfig(item.Id)
		local sliderValue = self:GetSaveProfilePath(cfg.SliderProfile)
		local selectIndex = self:GetSaveProfilePath(cfg.SelectProfile) or item.selectIndex

		if item.IsShowReloadTips and (sliderValue ~= item.sliderValue or selectIndex ~= item.selectIndex) then
			isShowReloadTips = true
		end

		local isSpecial = self:InitSettingsItemData(self.itemGroup[i])
		item.sliderValue = sliderValue
		item.selectIndex = isSpecial and self.itemGroup[i].selectIndex or selectIndex

		if not table.isNilOrEmpty(item.StartAction) then
			for k = 1, #item.StartAction do
				local data = {
					fatherId = i
				}

				SettingsAction.RunFunc(item.StartAction[k], data)
			end
		end

		item.isOn = self:GetSaveProfilePath(cfg.ClickProfile[1]) or false

		if item.itemList and #item.itemList > 0 then
			for t = 1, #item.itemList do
				item.itemList[t].isSelect = item.selectIndex == t
				item.itemList[t].isSuggest = item.IconIndex > 0 and self:GetSaveProfilePath(item.IconIndex) == t or nil
				item.itemList[t].isOn = self:GetSaveProfilePath(item.ClickProfile[t]) or false
			end

			if item.itemList[item.selectIndex] then
				item.selectName = item.itemList[item.selectIndex].label or ""
			end
		end
	end

	if isShowReloadTips and (data == nil or not data.banShowTips) and self.isInGame and not self.isReloadTip then
		gDisplayMessageMgr:ShowMessage(MessageConfig.SettingReloadTips)
	end

	self.isReloadTip = not isShowReloadTips

	GameQualitySettings.Instance:ApplySettings()
	self.bindData.itemList:RefreshList()
end

function M:CheckCanReset()
	if table.isNilOrEmpty(self.itemGroup) then
		return false
	end

	for i = 1, #self.itemGroup do
		local item = self.itemGroup[i]
		local cfg = ShezhiPanelShezhiConfig.GetConfig(item.Id)
		local sliderValue = self:GetSaveProfilePath(cfg.SliderProfile)
		local selectIndex = self:GetSaveProfilePath(cfg.SelectProfile) or item.selectIndex
		local isSpecial = self.specialType[item.Id] or false

		if not isSpecial and (sliderValue ~= item.sliderValue or selectIndex ~= item.selectIndex) then
			return true
		end
	end

	return false
end

function M:RefreshSaveProfilePath()
	self.SaveProfilePath = {
		{
			Index = 1,
			path = gameProfile.bgmVolume * 100
		},
		{
			Index = 2,
			path = gameProfile.effectVolume * 100
		},
		{
			Index = 3,
			path = gameProfile.fightTalkVolume * 100
		},
		{
			Index = 4,
			path = gameProfile.cameraRotateXLevel < 1 and GameConfig.FreeLookRotateXDefaultSensitivity or gameProfile.cameraRotateXLevel
		},
		{
			Index = 5,
			path = gameProfile.cameraRotateYLevel < 1 and GameConfig.FreeLookRotateYDefaultSensitivity or gameProfile.cameraRotateYLevel
		},
		{
			Index = 6,
			path = gameProfile.swingCameraItensity
		},
		{
			Index = 7,
			path = gameProfile.cameraMotionBlurIntensity
		},
		{
			Index = 8,
			path = gameProfile.shotFireCameraRotateXLevel
		},
		{
			Index = 9,
			path = gameProfile.shotFireCameraRotateYLevel
		},
		{
			Index = 10,
			path = gameProfile.allVolume * 100
		},
		{
			Index = 11,
			path = gameProfile.swingCameraRotateXLevel < 1 and GameConfig.SwingCameraRotateXDefaultSensitivity or gameProfile.swingCameraRotateXLevel
		},
		{
			Index = 12,
			path = gameProfile.swingCameraRotateYLevel < 1 and GameConfig.SwingCameraRotateYDefaultSensitivity or gameProfile.swingCameraRotateYLevel
		},
		{
			Index = 13,
			path = gameProfile.motionStrength
		},
		{
			Index = 14,
			path = gameProfile.vehicleCameraRotateXLevel
		},
		{
			Index = 15,
			path = gameProfile.vehicleCameraRotateYLevel
		},
		{
			Index = 18,
			path = gameProfile.vehicleSteerSpeedLevel
		},
		{
			Index = 19,
			path = gameProfile.handleSpeakerValue * 100
		},
		{
			Index = 20,
			path = gameProfile.shotOpenLensFireCameraRotateXLevel
		},
		{
			Index = 21,
			path = gameProfile.shotOpenLensFireCameraRotateYLevel
		},
		{
			Index = 22,
			path = gameProfile.lensDistortionIntensity
		},
		{
			Index = 23,
			path = gameProfile.shotNotFireCameraRotateXLevel
		},
		{
			Index = 24,
			path = gameProfile.shotNotFireCameraRotateYLevel
		},
		{
			Index = 25,
			path = gameProfile.shotOpenLensNotFireCameraRotateXLevel
		},
		{
			Index = 26,
			path = gameProfile.shotOpenLensNotFireCameraRotateYLevel
		},
		{
			Index = 27,
			path = gameProfile.shotFireCameraRotateXLevel
		},
		{
			Index = 28,
			path = gameProfile.shotFireCameraRotateYLevel
		},
		{
			Index = 29,
			path = gameProfile.shotOpenLensFireCameraRotateXLevel
		},
		{
			Index = 30,
			path = gameProfile.shotOpenLensFireCameraRotateYLevel
		},
		{
			Index = 31,
			path = gameProfile.vehicleShotNotFireCameraRotateXLevel
		},
		{
			Index = 32,
			path = gameProfile.vehicleShotNotFireCameraRotateYLevel
		},
		{
			Index = 33,
			path = gameProfile.vehicleShotOpenLensNotFireCameraRotateXLevel
		},
		{
			Index = 34,
			path = gameProfile.vehicleShotOpenLensNotFireCameraRotateYLevel
		},
		{
			Index = 35,
			path = gameProfile.vehicleShotFireCameraRotateXLevel
		},
		{
			Index = 36,
			path = gameProfile.vehicleShotFireCameraRotateYLevel
		},
		{
			Index = 37,
			path = gameProfile.vehicleShotOpenLensFireCameraRotateXLevel
		},
		{
			Index = 38,
			path = gameProfile.vehicleShotOpenLensFireCameraRotateYLevel
		},
		{
			Index = 39,
			path = gameProfile.shotGlobalCameraRotateLevel
		},
		{
			Index = 100,
			path = gameProfile.isBgmVolumeOn
		},
		{
			Index = 101,
			path = gameProfile.isSoundEffectOn
		},
		{
			Index = 102,
			path = gameProfile.isFightTalkOn
		},
		{
			Index = 103,
			path = gameProfile.isAllVolumeOn
		},
		{
			Index = 104,
			path = gameProfile.isHandleSpeakerOn
		},
		{
			Index = 301,
			path = gameProfile.displayName
		},
		{
			Index = 302,
			path = gameProfile.displayTitle
		},
		{
			Index = 303,
			path = gameProfile.displayIcon
		},
		{
			Index = 400,
			path = gameProfile.isVehicleJoystickMode
		},
		{
			Index = 500,
			path = gameProfile.isShowBubble and 1 or 2
		},
		{
			Index = 501,
			path = gameProfile.isShowZhanlingBubble and 1 or 2
		},
		{
			Index = 502,
			path = gameProfile.ShowUniqueSkillAnimation and 1 or 2
		},
		{
			Index = 503,
			path = gameProfile.isVibrating and 1 or 2
		},
		{
			Index = 504,
			path = gameProfile.isLockTargetCameraOn and 1 or 2
		},
		{
			Index = 505,
			path = gameProfile.isBattlePeaceMode and 1 or 2
		},
		{
			Index = 2000,
			path = gQualityManager:GetDisplayLevelIndex()
		},
		{
			Index = 2001,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.resolutionScreen)
		},
		{
			Index = 2002,
			path = GetFpsIndex()
		},
		{
			Index = 2003,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.resolutionShadow)
		},
		{
			Index = 2004,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.postProcess)
		},
		{
			Index = 2005,
			path = gameProfile.antiAliasing
		},
		{
			Index = 2006,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.sceneCount)
		},
		{
			Index = 2007,
			path = gameProfile.raytracingOn and 1 or 2
		},
		{
			Index = 2008,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.sceneMat)
		},
		{
			Index = 2009,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.charMeshTex)
		},
		{
			Index = 2012,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.effect)
		},
		{
			Index = 2013,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.charCount)
		},
		{
			Index = 2014,
			path = languageProfile.pcResolutionIsFullScreen
		},
		{
			Index = 2015,
			path = gameProfile.vSync and 1 or 2
		},
		{
			Index = 2016,
			path = gameProfile.ssrOn and 1 or 2
		},
		{
			Index = 2017,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.vehicleCount)
		},
		{
			Index = 2018,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.matLevel)
		},
		{
			Index = 2019,
			path = gQualityManager:ConvertLevelForDisplay(gameProfile.adaptableSize)
		},
		{
			Index = 2020,
			path = languageProfile.pcResolutionDisplayIndex
		},
		{
			Index = 3000,
			path = gameProfile.isDialogTyperOn and 1 or 2
		},
		{
			Index = 3001,
			path = languageProfile.textLanguage or GetLanguageIndex()
		},
		{
			Index = 3002,
			path = languageProfile.voiceLanguage
		},
		{
			Index = 3003,
			path = gameProfile.motionLevel
		},
		{
			Index = 3004,
			path = gameProfile.inverseCamInputX and 1 or 2
		},
		{
			Index = 3005,
			path = gameProfile.inverseCamInputY and 1 or 2
		},
		{
			Index = 3006,
			path = gameProfile.isClickSwitchShoulderFire and 2 or 1
		},
		{
			Index = 3007,
			path = gameProfile.isUsePlayerName and 1 or 2
		},
		{
			Index = 3008,
			path = gameProfile.handleSpeakerOutputId
		},
		{
			Index = 3009,
			path = gameProfile.powerSavingMode and 1 or 2
		},
		{
			Index = 3010,
			path = not gCS.PanelManager.Instance.IsMobileMode and 1 or 2
		},
		{
			Index = 3011,
			path = gCharMotionUtils.CheckInviteNotDisturb() and 1 or 2
		},
		{
			Index = 3012,
			path = gameProfile.soundNumberLevel
		},
		{
			Index = 3013,
			path = gameProfile.frameGeneration
		},
		{
			Index = 3014,
			path = gameProfile.isAntidinicMode and 1 or 2
		},
		{
			Index = 3015,
			path = gameProfile.isAntidinicModeAll and 1 or 2
		},
		{
			Index = 3016,
			path = gameProfile.isExchangeWingSuit and 1 or 2
		},
		{
			Index = 3017,
			path = gameProfile.mobileControlMode and 1 or 2
		},
		{
			Index = 3018,
			path = gameProfile.antialiasingQuality
		},
		{
			Index = 3019,
			path = gameProfile.antialiasingLevel
		},
		{
			Index = 10000,
			path = gQualityManager.DefaultQuality
		}
	}
	self.tIndex2SaveProfilePath = {}

	for i = 1, #self.SaveProfilePath do
		local ele = self.SaveProfilePath[i]
		self.tIndex2SaveProfilePath[ele.Index] = ele.path
	end
end

function M:OnLanguageChange(lang)
	self:InitTabInfo()
	self:InitSettingData()
	self:SwitchPage(self.page)

	self.isSetData = true
end

function M:OnButtonPageShow()
	if self.curSettingsKeyPanelStore then
		self.curSettingsKeyPanelStore:OnShow()
	end
end

function M:OnTabRectRender(index, widget)
	self.curSettingsKeyPanelStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curSettingsKeyPanelStore then
		self.curSettingsKeyPanelStore:OnShow()
	end
end

function M:OnOutOfJam()
	gDisplayMessageMgr:ShowMessage(MessageConfig.FreeFromStuck, function ()
		gPanelManager:Close(gPanelId.S_SETTINGS_PANEL)
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
		gClientToGameSceneDelegate:AskPlayerOutOfStuck()
	end, nil)
end
