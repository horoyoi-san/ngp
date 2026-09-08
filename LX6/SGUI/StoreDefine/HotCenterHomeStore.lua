-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterHomeStore.lua
-- Decompiled from: 01726_HotCenterHomeStore.lua_54a97439bf2e.luajit

C_HotCenterHomeStore = DefClass("C_HotCenterHomeStore", C_HotCenterHomeStore, C_StoreGroup)
GroupName2Class.HotCenterHomeStore = C_HotCenterHomeStore
local M = C_HotCenterHomeStore
local Input = UnityEngine.Input
local KeyCode = UnityEngine.KeyCode
local MAIN_MODE_TAB_PANEL_STORE = "HotCenterMainPageTabPanelStore_PC"
local LinkHubConfig = LTConfig.LinkHubConfig
local PAGE_INDEX_TO_STORE = {
	[0] = "U\\xa6\\xf2w\\xa8h%9e\\x92\\xea*\\xcb\\xe2",
	"\\\\xf33\\xcf,9;\\xc6s\\xc0I\\xbfM\\xd4\\xe3",
	"\\xc73\\xb7\\xc1\\xe9\\xbf\\xec끔\\xea\\x86\\xeb\\x9c>\\x92\\xd1a\\x8c\\xa9\\x8e",
	"\\xe8\"얱\\xf1\\xab\\xb4\\xf3\\x82\\xa2\r\\xc1\\x8a\"\\x9e\\x8c\r\\x8f\\xdd \\xe2",
	"\\xe8\"얱\\xf1\\xab\\xa3㔓桘\r\\xc1\\x8a\"\\x9e\\x8c\r\\x8f\\xdd \\xe2"
}

local SetWidgetActive = function(widget, isActive)
	if widget and widget.SetActive then
		widget.SetActive(widget, isActive)
	elseif widget and widget.gameObject then
		widget.gameObject:SetActive(isActive)
	end
end

local IsOnlineLinkMode = function()
	return gLinkManager and UX and UX.Game and gLinkManager.LinkMode == UX.Game.LinkMode.None
end

local GetRootButton = function(storeGroup, fieldName, fallbackPath)
	if not storeGroup then
		return
	end

	local bindData = storeGroup.bindData

	if bindData then
		local btn = bindData[fieldName]

		if btn then
			return btn
		end
	end

	local rootGo = storeGroup.rootGo

	if not rootGo or not rootGo.FindChild then
		return
	end

	local target = rootGo:FindChild(fallbackPath or fieldName)

	if not target then
		return
	end

	return target.GetComponent(target, "UButton")
end

local UpdateMobileSwitchModeButtonActive = function(storeGroup, isMainHomePage)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local switchModeBtn = GetRootButton(storeGroup, "switchModeBtnMoblie", "SwitchModeBtnMoblie")
	switchModeBtn = switchModeBtn or GetRootButton(storeGroup, "SwitchModeBtnMoblie", "SwitchModeBtnMoblie")

	if switchModeBtn then
		SetWidgetActive(switchModeBtn, isMainHomePage and not IsOnlineLinkMode())
	end
end

M.ctor = function(self)
	self.DEFINE_DynamicOnUpdate = true
end

M.DefineAllVariables = function(self)
	self.SIGNAL_STATE = {
		["M'|P"] = 0,
		["1A\\x95\\x8a\\x8fD"] = 2,
		["\\xa2gq"] = 1,
		["/\\\\x83\\x81\\x8dF"] = 3
	}
	self.curSubType = nil
	self.isDynamicUpdateRegistered = false
	self.cityListData = {}
	self.curCountryId = nil
	self.showCityTab = false
	self.pendingRefreshMainModeTabPanel = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.showTabCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.statusCtrlEnum = {
		["3F\\x9d\\x87\\x8dD"] = 0,
		["\\xf6\\xdd*\\xf4"] = 1
	}
	self.switchCtrlEnum = {
		["3F\\x9d\\x87\\x8dD"] = 1,
		["\\xf6\\xdd*\\xf4"] = 0
	}
	self.switchTitleCtrlEnum = {
		["kHxJK*"] = 0,
		["@x\\xa0~B\\xb7\\xd1Bdn{^"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showTabCtrlEnum = nil
	self.statusCtrlEnum = nil
	self.switchCtrlEnum = nil
	self.switchTitleCtrlEnum = nil
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
	self.UnregisterHotCenterUpdate(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
	self.UnregisterHotCenterUpdate(self)
end

M.OnShow = function(self, panelId, data)
	gHotCenterManager:TryNotifyPopularityUIOpened()
	self:InitTabData()
	self:RegisterHotCenterUpdate()
	self:SyncOpenInspireHub()
end

M.SyncOpenInspireHub = function(self)
	slot1 = gClientToGameDelegate

	slot1:SyncOpenInspireHub().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gHotCenterManager:RequestHomeDynamicDisplayData()
	end
end

M.OnClose = function(self)
	self:UnregisterHotCenterUpdate()
	gHotCenterManager:ClearPopularityInfoScroll()
end

M.OnActiveDeviceChange = function(self, device)
	UpdateMobileSwitchModeButtonActive(self, self.IsMainHomePage(self))
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL] = self.CreateAction(self, "OnRequestSubPanel")
	}
end

M.OnRequestSubPanel = function(self, eventId, args)
	args = args or {}
	local returnPanelId = args.back and self.curShowData and self.curShowData.returnPanelId
	local returnPanelData = args.back and self.curShowData and self.curShowData.returnPanelData

	local changeBackPage = function()
		if args.back and #self.stack <= 0 then
			table.remove(self.stack, #self.stack)
		end

		self:ChangeShowTab(args.mainType, args.subType, args, args.back, args.skipStack)
	end

	if returnPanelId then
		returnPanelData = returnPanelData or {}
		returnPanelData.onShowCallback = changeBackPage

		if gPanelManager:CheckShow(returnPanelId, returnPanelData) then
			return
		end
	end

	changeBackPage()
end

M.RegisterWidget = function(self)
	if self.bindData.mobileTab then
		self.bindData.mobileTab.OnRenderTab = self.CreateAction(self, "OnMobileTabRender")
	end

	if self.bindData.cityList then
		self.bindData.cityList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderCityItem")
		self.bindData.cityList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickCityItem")
	end

	if self.bindData.backBtn then
		self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	end

	local switchModeBtn = GetRootButton(self, "switchModeBtnMoblie", "SwitchModeBtnMoblie")
	switchModeBtn = switchModeBtn or GetRootButton(self, "SwitchModeBtnMoblie", "SwitchModeBtnMoblie")

	if switchModeBtn then
		switchModeBtn.luaClick = self.CreateAction(self, "OnSwitchModeBtnClick")
	end
end

M.RegisterHotCenterUpdate = function(self)
	if self.isDynamicUpdateRegistered then
		return
	end

	gStoreManager:RegisterDynamicOnUpdate(self)

	self.isDynamicUpdateRegistered = true
end

M.UnregisterHotCenterUpdate = function(self)
	if not self.isDynamicUpdateRegistered then
		return
	end

	gStoreManager:UnregisterDynamicOnUpdate(self)

	self.isDynamicUpdateRegistered = false
end

M.OnBackBtnClick = function(self)
	local stackCount = self.stack and #self.stack or 0

	if stackCount <= 1 then
		local returnPanelId = self.curShowData and self.curShowData.returnPanelId
		local returnPanelData = self.curShowData and self.curShowData.returnPanelData

		local changeBackPage = function()
			local data = self.stack[#self.stack - 1]

			table.remove(self.stack, #self.stack)
			self:ChangeShowTab(data.mainType or data.tabIndex, data.subType, data.showData, true)
		end

		if returnPanelId then
			returnPanelData = returnPanelData or {}
			returnPanelData.onShowCallback = changeBackPage

			if gPanelManager:CheckShow(returnPanelId, returnPanelData) then
				return
			end
		end

		changeBackPage()
	else
		gPanelManager:Close(gPanelId.HOT_CENTER_HOME)
	end
end

M.OnMobileTabRender = function(self, index, widget)
	local storeGroup = gStoreManager:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	if storeGroup.ShowPanel then
		storeGroup.ShowPanel(storeGroup, self.curShowData)
	end
end

M.OnSwitchModeBtnClick = function(self)
	if self.GetCurrentMainModeType(self) ~= gClientConst.HotCenterType.Online then
		self.SwitchToSingleMainMode(self)
	else
		self.SwitchToOnlineMainMode(self)
	end
end

M.SwitchToOnlineMainMode = function(self)
	self.ChangeShowTab(self, gClientConst.HotCenterType.Online, nil, {
		countryId = self.curCountryId
	})
end

M.SwitchToSingleMainMode = function(self)
	self.ChangeShowTab(self, gClientConst.HotCenterType.Main, nil, {
		countryId = self.curCountryId
	})
end

M.InitTabData = function(self)
	self.stack = {}
	self.curShowTabType = -1
	self.curShowData = nil
	self.curSubType = -1
	self.curCountryId = gHotCenterManager:GetDefaultHomeCountryId()

	self:RefreshCityList()

	if self.bindData.mobileTab then
		self.bindData.mobileTab.selectedIndex = -1
	end

	self.bindData.showTabCtrl = self.showCityTab and self.showTabCtrlEnum.active or self.showTabCtrlEnum.normal

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		self.ChangeShowTab(self, gClientConst.HotCenterType.Main)
	else
		self.ChangeShowTab(self, gClientConst.HotCenterType.Online)
	end
end

M.GetTargetPageIndex = function(self, targetType, targetSubType)
	if targetType ~= gClientConst.HotCenterType.Online then
		if targetSubType ~= gClientConst.HotCenterSubType.OnlineSub then
			return 3
		end

		if targetSubType ~= gClientConst.HotCenterSubType.OnlineDetail then
			return 4
		end

		return 2
	end

	if targetSubType then
		return 1
	end

	return 0
end

M.GetCurrentMainModeType = function(self)
	if self.curShowData and self.curShowData.mainType == nil then
		return self.curShowData.mainType
	end

	return gClientConst.HotCenterType.Main
end

M.IsMainHomePage = function(self)
	return not self.curSubType
end

M.IsMainModeTabPanelVisible = function(self)
	return not IsOnlineLinkMode() and not self.curSubType
end

M.GetMainModeTabPanelData = function(self)
	local tabNames = LinkHubConfig.InspireHubTab

	return {
		visible = self:IsMainModeTabPanelVisible(),
		tabs = {
			{
				name = tabNames[1],
				mainType = gClientConst.HotCenterType.Main
			},
			{
				name = tabNames[2],
				mainType = gClientConst.HotCenterType.Online
			}
		},
		selectedIndex = self:GetCurrentMainModeType() ~= gClientConst.HotCenterType.Online and 2 or 1,
		selectCallback = self:CreateAction("OnMainModeTabSelect")
	}
end

M.RefreshMainModeTabPanel = function(self)
	local storeGroup = gStoreManager:GetStoreGroup(MAIN_MODE_TAB_PANEL_STORE)

	if not storeGroup or not storeGroup.ShowPanel then
		self.pendingRefreshMainModeTabPanel = true

		return false
	end

	self.pendingRefreshMainModeTabPanel = false

	storeGroup.ShowPanel(storeGroup, self.GetMainModeTabPanelData(self))

	return true
end

M.RefreshCurrentTabPanel = function(self, pageIndex)
	local storeName = PAGE_INDEX_TO_STORE[pageIndex]
	local storeGroup = storeName and gStoreManager:GetStoreGroup(storeName)

	if storeGroup and storeGroup.ShowPanel then
		storeGroup.ShowPanel(storeGroup, self.curShowData)
	end
end

M.OnMainModeTabSelect = function(self, tabData, index)
	if not tabData or not tabData.mainType then
		return
	end

	if tabData.mainType ~= self.GetCurrentMainModeType(self) and not self.curSubType then
		return
	end

	self.ChangeShowTab(self, tabData.mainType, nil, {
		countryId = self.curCountryId
	})
end

M.RefreshCityList = function(self)
	local cityList = gHotCenterManager:GetHomeCountryList() or {}
	self.cityListData = {}
	local selectedIndex = -1

	for _, data in ipairs(cityList) do
		if data.unlocked then
			table.insert(self.cityListData, data)

			if data.id ~= self.curCountryId then
				selectedIndex = #self.cityListData - 1
			end
		end
	end

	if selectedIndex >= 0 and self.cityListData[1] then
		self.curCountryId = self.cityListData[1].id
		selectedIndex = 0
	end

	self.showCityTab = #self.cityListData >= 1

	if self.bindData.cityList then
		SetWidgetActive(self.bindData.cityList, self.showCityTab)
		self.bindData.cityList:SetSimpleList(self.showCityTab and #self.cityListData or 0)
		self:SelectCityListItem(selectedIndex)
	end
end

M.SelectCityListItem = function(self, selectedIndex)
	if not self.showCityTab or selectedIndex <= 0 or not self.bindData.cityList then
		return
	end

	if self.bindData.cityList.groupType ~= 0 then
		return
	end

	self.bindData.cityList:SelectItem(selectedIndex, false)
end

M.OnSimpleRenderCityItem = function(self, btn, index)
	local data = self.cityListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.name = data.name or ""
	end
end

M.OnSimpleClickCityItem = function(self, btn, index)
	local data = self.cityListData[index + 1]

	if not data or data.id ~= self.curCountryId then
		return
	end

	self.curCountryId = data.id

	if self.bindData.mobileTab then
		self.bindData.mobileTab.selectedIndex = -1
	end

	self.stack = {}

	self.ChangeShowTab(self, gClientConst.HotCenterType.Main, nil, {
		["6\\x91\\xf4\\x88\\xae\\xfc\\xbf\\x99\\x80\\xdc\\xec5û.\\x96\\xef"] = true,
		countryId = self.curCountryId
	})
end

M.ChangeShowTab = function(self, targetType, targetSubType, showData, back, skipStack)
	showData = showData or {}
	local oldMainModeType = self.curShowData and self.curShowData.mainType or nil
	local oldSubType = self.curSubType
	local targetCountryId = showData.countryId or self.curCountryId

	if targetCountryId then
		self.curCountryId = targetCountryId
	end

	local citySelectedIndex = self:GetCitySelectedIndex()
	local targetPageIndex = self:GetTargetPageIndex(targetType, targetSubType)
	local needSelectPage = self.bindData.mobileTab and self.bindData.mobileTab.selectedIndex == targetPageIndex
	local needRefreshCountry = self.curShowData and targetCountryId and self.curShowData.countryId == targetCountryId

	if targetType == self.curShowTabType or targetSubType == self.curSubType or needSelectPage or needRefreshCountry then
		if not back and oldMainModeType and not oldSubType and not targetSubType and oldMainModeType == targetType then
			showData.playMainModeSwitchAnim = true
		end

		self.curShowTabType = targetType
		self.curShowData = showData
		self.curSubType = targetSubType
		self.curShowData.mainType = targetType
		self.curShowData.countryId = targetCountryId

		if self.curSubType then
			self.curShowData.subType = self.curSubType
			self.curShowTabType = self.curSubType
		else
			self.curShowData.subType = nil
		end

		if not back then
			if #self.stack <= 0 and self.stack[1].tabIndex == targetType then
				table.clear(self.stack)
			end

			local stackInfo = {
				mainType = targetType,
				subType = self.curSubType,
				tabIndex = self.curShowTabType,
				showData = self.curShowData
			}

			if skipStack then
				if #self.stack <= 0 then
					self.stack[#self.stack] = stackInfo
				else
					table.insert(self.stack, stackInfo)
				end
			else
				table.insert(self.stack, stackInfo)
			end
		end

		self.bindData.showTabCtrl = self.showCityTab and self.showTabCtrlEnum.active or self.showTabCtrlEnum.normal

		self:SelectCityListItem(citySelectedIndex)

		if self.bindData.mobileTab then
			self.bindData.mobileTab:SelectIndexWithClose(targetPageIndex)
		end

		if needRefreshCountry and not needSelectPage then
			self.RefreshCurrentTabPanel(self, targetPageIndex)
		end

		if self.bindData.backBtn then
			self.bindData.backBtn:SetActive(true)
		end

		UpdateMobileSwitchModeButtonActive(self, self:IsMainHomePage())

		self.bindData.statusCtrl = targetType ~= gClientConst.HotCenterType.Online and 0 or 1
		self.bindData.switchCtrl = targetType ~= gClientConst.HotCenterType.Online and self.switchCtrlEnum.Online or self.switchCtrlEnum.Offline
		self.bindData.switchTitleCtrl = targetType ~= gClientConst.HotCenterType.Online and self.switchTitleCtrlEnum.OnlineCenter or self.switchTitleCtrlEnum.HotCenter

		self:RefreshMainModeTabPanel()
	end
end

M.GetCitySelectedIndex = function(self)
	for index, data in ipairs(self.cityListData) do
		if data.id ~= self.curCountryId then
			return index - 1
		end
	end

	return -1
end

M.OnUpdate = function(self)
	if not self.bindData then
		return
	end

	if self.pendingRefreshMainModeTabPanel then
		self.RefreshMainModeTabPanel(self)
	end

	if Input and KeyCode and KeyCode.Escape and Input.GetKeyDown and Input.GetKeyDown(KeyCode.Escape) then
		self.OnBackBtnClick(self)
	end
end
