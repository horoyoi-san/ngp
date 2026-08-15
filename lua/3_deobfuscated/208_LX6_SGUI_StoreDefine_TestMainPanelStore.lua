C_TestMainPanelStore = DefClass("C_TestMainPanelStore", C_TestMainPanelStore, C_StoreGroup)
GroupName2Class.TestMainPanelStore = C_TestMainPanelStore
local M = C_TestMainPanelStore
local showall, tabDatas, testMainUtils, partTabDatas, json, switchOptions, ShowControl = nil
local maxHistoryCount = 15

function M:ctor()
	return
end

function M:OnAwake()
	self:InitLocalParams()

	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnTabListRenderItem")
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnTabRectRender")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.upperTabIndex = 0
	self.bindData.searchContent = {}
	self.bindData.storeToContentData = {}

	function self.bindData.searchText.luaValueChanged(text, _, _)
		self:SetSecondMenuState(false)

		self.bindData.TestFirstStore.isTabListActive = ShowControl.Hide

		self.bindData.tabList:SelectItem(11)

		self.bindData.searchContent = testMainUtils.GetSearchContent(text, tabDatas)
		self.bindData.firstListData = self.bindData.searchContent

		self.bindData.contentList:SetSimpleList(#self.bindData.searchContent)
	end

	self.eventHandlers = {
		[gEventConstants.TEST_MAIN_OPEN_DEBUG_BOOL] = self:CreateAction("OpenDebugBool"),
		[gEventConstants.TEST_MAIN_CLOSE_DEBUG_BOOL] = self:CreateAction("CloseDebugBool"),
		[gEventConstants.TEST_MAIN_REFRESH_TAB_RECT] = self:CreateAction("RefreshTabRect"),
		[gEventConstants.TEST_MAIN_PASTE_POS] = self:CreateAction("PastePos"),
		[gEventConstants.TEST_MAIN_TELEPORT_TO_POS] = self:CreateAction("TeleportToTargetPos"),
		[gEventConstants.TEST_MAIN_CLEAR_POS] = self:CreateAction("ClearPos"),
		[gEventConstants.TEST_MAIN_CLEAR_CAMERA] = self:CreateAction("ClearCameraDirection"),
		[gEventConstants.TEST_MAIN_PASTE_CAMERA] = self:CreateAction("PasteCamera"),
		[gEventConstants.TEST_MAIN_OPEN_LOG_CATEGORY] = self:CreateAction("OpenLogCategory"),
		[gEventConstants.TEST_MAIN_CLOSE_LOG_CATEGORY] = self:CreateAction("CloseLogCategory")
	}

	self:RegisterMessageEvents(self.eventHandlers)
end

function M:InitLocalParams()
	if showall == nil then
		showall = L50.Gm.AutoQaFunctions.checkShowAll()
	end

	if tabDatas == nil then
		tabDatas = require("LX6/Data/TestMainData")
	end

	if testMainUtils == nil then
		testMainUtils = require("LX6/Utils/TestMainUtils")
	end

	testMainUtils.RefreshSwitchDatas(tabDatas)

	if partTabDatas == nil then
		partTabDatas = require("LX6/Data/TestMainPartData")
	end

	if switchOptions == nil then
		switchOptions = {
			{
				openGo = "buttonOff",
				closeGo = "buttonOn"
			},
			{
				openGo = "buttonOn",
				closeGo = "buttonOff"
			}
		}
	end

	if ShowControl == nil then
		ShowControl = {
			Hide = 0,
			Show = 1
		}
	end
end

function M:OnEnable()
	self:SetSecondMenuState(false)

	if showall then
		self.bindData.tabList:SetSimpleList(#tabDatas)
	else
		self.bindData.tabList:SetSimpleList(#partTabDatas)
	end

	self.bindData.searchText.gameObjectActive = showall

	self.bindData.tabList:SelectItem(0)
end

function M:OnShow(panelId, _)
	self.panelId = panelId
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnTabListRenderItem(btn, index)
	local data = nil

	if showall then
		data = tabDatas[index + 1]
	else
		data = partTabDatas[index + 1]
	end

	local store = gStoreManager:GetStoreGroup("MainTabStore"):GetStoreByWidget(btn)
	store.nameLabel = data.title
	store.button.luaClick = self:CreateActionWithArgs("OnMainTabClick", data)

	if data.isFirst == true then
		self:OnMainTabClick(data)
	end
end

function M:OnMainTabClick(data)
	self.bindData.curData = data

	if data.tIndex ~= self.bindData.tabRect.selectedIndex then
		self.bindData.tabRect.selectedIndex = data.tIndex
	else
		self.bindData.tabRect.selectedIndex = -1
		self.bindData.tabRect.selectedIndex = data.tIndex
	end
end

function M:OnTabRectRender(index, widget)
	self:SetSecondMenuState(false)

	if index == 0 then
		local store = gStoreManager:GetStoreGroup("TestFirstStore"):GetStoreByWidget(widget)
		self.bindData.TestFirstStore = store
		self.bindData.contentList = store.list
		store.list.luaSimpleRenderItem = self:CreateAction("OnFirstListRenderItem")
		store.list.luaSimpleDynamicRenderItem = self:CreateAction("OnFirstListRenderItem")
		store.list.onGetTIndex = self:CreateAction("OnGetFirstListTIndex")
		local showMainButton = self.bindData.curData.showMainButton
		store.mainButton.gameObjectActive = showMainButton == true
		local contentData = self.bindData.curData.content

		if self.bindData.curData.IsTabList then
			self.bindData.upperTabIndex = 0
			self.bindData.tabContentData = contentData
			store.tabList.luaSimpleRenderItem = self:CreateAction("OnTestTabListRenderItem")

			store.tabList:SetSimpleList(#contentData)

			store.isTabListActive = ShowControl.Show

			store.tabList:SelectItem(self.bindData.upperTabIndex, true)
		elseif self.bindData.curData.isSeachTab then
			store.isTabListActive = ShowControl.Hide

			store.list:SetSimpleList(#self.bindData.searchContent)

			self.bindData.firstListData = self.bindData.searchContent
		else
			store.isTabListActive = ShowControl.Hide
			self.bindData.firstListData = contentData

			store.list:SetSimpleList(#contentData)
		end

		store.list:GoToIndex(0, false)

		if showMainButton then
			local mainButtonStore = gStoreManager:GetStoreGroup("MainBtnTemplateStore"):GetStoreByWidget(store.mainButton)
			mainButtonStore.buttonSave.luaClick = self:getFuncByName("ScreenRecordSave")
			mainButtonStore.buttonGm.luaClick = self:getFuncByName("GmOpenConsole")
			mainButtonStore.buttonBug.luaClick = self:getFuncByName("QTFeedback")
			mainButtonStore.buttonRoadSign.gameObjectActive = LX6.RoadSign.RoadSignManager.Enable

			if LX6.RoadSign.RoadSignManager.Enable then
				function mainButtonStore.buttonRoadSign.luaClick()
					gPanelManager:Close(gPanelId.S_TEST_MAIN_PANEL)
					gPanelManager:CheckShow(gPanelId.S_ROADSGIN_SUGGEST_PANEL)
				end
			end
		end
	elseif index == 1 then
		local store = gStoreManager:GetStoreGroup("TestSecondStore"):GetStoreByWidget(widget)
		local buttonStore = gStoreManager:GetStoreGroup("CommonButtonMStore"):GetStoreByWidget(store.button)
		buttonStore.button.luaClick = self:getFuncByName(self.bindData.curData.funcName)
		local templateStore = gStoreManager:GetStoreGroup("TestMainTemplateStore"):GetStoreByWidget(store.mainTemplate)
		templateStore.list.luaSimpleRenderItem = self:CreateAction("OnTestListTemplateItem")

		templateStore.list:SetSimpleList(#self.bindData.curData)

		self.bindData.contentList = templateStore.list
	end

	self.bindData.tabRectIndex = index
end

function M:OnTestListTemplateItem(btn, index, data)
	data = data or self.bindData.curData[index + 1]
	local store = gStoreManager:GetStoreGroup("TestListTemplateStore"):GetStoreByWidget(btn)
	store.label = data.name

	function store.button.luaClick()
		self:UpdateToggles(data.content)
	end
end

function M:UpdateToggles(content)
	self.bindData.testSelListData = content

	self:SetSecondMenuState(true)

	local wid = self.bindData.secondMenu
	local store = gStoreManager:GetStoreGroup("TestPopStore"):GetStoreByWidget(wid)
	store.list.luaSimpleRenderItem = self:CreateAction("OnTestSelTemplateRenderItem")

	store.list:SetSimpleList(#content)

	self.bindData.secondMenuList = store.list
end

function M:SetSecondMenuState(isOn)
	self.bindData.secondMenu.gameObjectActive = isOn
	self.bindData.searchText.gameObjectActive = not isOn
end

function M:OnTestSelTemplateRenderItem(btn, index, data)
	data = data or self.bindData.testSelListData[index + 1]
	local store = gStoreManager:GetStoreGroup("TestSelTemplate1Store"):GetStoreByWidget(btn)
	store.title = data.label

	store.switcher:SetOptions(switchOptions)

	function store.switcher.luaRenderSwitcher(_, _, item)
		store[item.openGo].gameObjectActive = true
		store[item.closeGo].gameObjectActive = false
	end

	if data.isFeatureSwitch then
		local selectedIndex = data.isOn and 1 or 0

		store.switcher:SelectOption(selectedIndex, false)

		function store.switcher.luaSelectedChanged()
			gCS.FeatureSwitch.SetSwitch(data.switchName)

			data.isOn = not data.isOn
		end
	elseif data.isDebugBool then
		local selectedIndex = data.isOn and 1 or 0

		store.switcher:SelectOption(selectedIndex, false)

		store.switcher.luaSelectedChanged = data.onChange
	else
		if data.switcherHander and data.switchName then
			local selectedIndex = data.switcherHander[data.switchName] and 1 or 0

			store.switcher:SelectOption(selectedIndex, false)
		else
			local selectedIndex = self:getFuncByName(data.getIndexFunc)()

			store.switcher:SelectOption(selectedIndex, false)
		end

		function store.switcher.luaSelectedChanged()
			local index = store.switcher.selectedIndex

			if data.switcherHander and data.switchName then
				data.switcherHander[data.switchName] = index == 1 and true or false
			end

			if data.switchFunc then
				self:getFuncByName(data.switchFunc)()
			end

			self:updateHistoryData(data)
		end
	end
end

function M:OnGetFirstListTIndex(index)
	return self.bindData.firstListData[index + 1].tIndex
end

function M:OnFirstListRenderItem(btn, index)
	local data = self.bindData.firstListData[index + 1]

	if data.tIndex == 2 then
		local store = gStoreManager:GetStoreGroup("TitleMainStore"):GetStoreByWidget(btn)
		store.titleLabel = data.title
	elseif data.tIndex == 1 then
		local store = gStoreManager:GetStoreGroup("TestMainTemplate2Store"):GetStoreByWidget(btn)
		self.bindData.testPopWidget = store.secondMenu
		local content = self.bindData.firstListData[index + 1].content
		local length = #content
		store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnTemplate2ListRenderItem", content)
		store.list.onGetTIndex = self:CreateActionWithArgs("OnGetTemplate2ListTIndex", content)

		store.list:SetSimpleList(length)
	end
end

function M:OnTestTabListRenderItem(btn, index)
	local data = self.bindData.tabContentData[index + 1]
	local store = gStoreManager:GetStoreGroup("TestTabLv2TemplateStore"):GetStoreByWidget(btn)
	store.label = data.label

	if data.index == self.bindData.upperTabIndex then
		local contentData = data.content ~= nil and data.content or testMainUtils[data.getContentFunc]()
		self.bindData.firstListData = contentData

		self.bindData.contentList:SetSimpleList(#contentData)
	end

	function store.button.luaClick()
		local contentData = data.content ~= nil and data.content or testMainUtils[data.getContentFunc]()
		self.bindData.firstListData = contentData

		self.bindData.contentList:SetSimpleList(#contentData)

		self.bindData.upperTabIndex = data.index
	end
end

function M:OnGetTemplate2ListTIndex(content, index)
	return content[index + 1].tIndex
end

function M:OnTemplate2ListRenderItem(content, btn, index)
	local data = content[index + 1]

	if data.tIndex == 0 then
		local store = gStoreManager:GetStoreGroup("commonButtonLv1Store"):GetStoreByWidget(btn)
		store.enableTitle = data.enableText
		store.disableTitle = data.disableText

		function store.button.luaClick()
			if data.params then
				self:getFuncByName(data.funcName)(unpack(data.params))
			else
				local r, error = xpcall(self:getFuncByName(data.funcName), tolua.traceback)
			end

			self:updateHistoryData(data)
		end
	else
		if data.tIndex == 1 then
			local store = gStoreManager:GetStoreGroup("TestSwitcherTemplateStore"):GetStoreByWidget(btn)
			store.label = data.label
			local switchStore = gStoreManager:GetStoreGroup("TestSwitherStore"):GetStoreByWidget(store.switcher)

			switchStore.switcher:SetOptions(switchOptions)

			if not self:getFuncByName(data.checkIsOnFunc) then
				print_error("not find function: " .. data.checkIsOnFunc)
			end

			local selectedIndex = nil

			if data.prefsKey then
				if self:getFuncByName(data.checkIsOnFunc)(data.prefsKey) then
					selectedIndex = 1
				else
					selectedIndex = 0
				end
			elseif self:getFuncByName(data.checkIsOnFunc)() then
				selectedIndex = 1
			else
				selectedIndex = 0
			end

			switchStore.switcher:SelectOption(selectedIndex, false)

			function switchStore.switcher.luaRenderSwitcher(_, _, item)
				switchStore[item.openGo].gameObjectActive = true
				switchStore[item.closeGo].gameObjectActive = false
			end

			function switchStore.switcher.luaSelectedChanged(_)
				if data.prefsKey then
					self:getFuncByName(data.onSwitch)(data.prefsKey)
				else
					self:getFuncByName(data.onSwitch)()
				end

				self:updateHistoryData(data)
			end

			return
		end

		if data.tIndex == 2 then
			local store = gStoreManager:GetStoreGroup("TestBtnTemplateStore"):GetStoreByWidget(btn)
			store.label = data.label

			if data.buttonLabel then
				local buttonStore = gStoreManager:GetStoreGroup("CommonButtonSStore"):GetStoreByWidget(store.button)
				buttonStore.enableTitle = data.buttonLabel
				buttonStore.disableTitle = data.buttonLabel
			end

			function store.button.luaClick()
				if data.params then
					self:getFuncByName(data.funcName)(unpack(data.params))
				else
					self:getFuncByName(data.funcName)()
				end

				self:updateHistoryData(data)
			end
		elseif data.tIndex == 3 then
			self:OnTestSelTemplateRenderItem(btn, index, data)
		elseif data.tIndex == 4 then
			self:OnTestListTemplateItem(btn, index, data)
		elseif data.tIndex == 5 then
			local store = gStoreManager:GetStoreGroup("TestInputTemplate1Store"):GetStoreByWidget(btn)
			store.title = data.title
			local inputStore = gStoreManager:GetStoreGroup("InputFieldLStore"):GetStoreByWidget(store.inputField)
			inputStore.holderText = data.holderText
			local buttonStore = gStoreManager:GetStoreGroup("CommonButtonMStore"):GetStoreByWidget(store.button)
			buttonStore.enableTitle = data.buttonLabel
			buttonStore.disableTitle = data.buttonLabel

			function buttonStore.button.luaClick()
				local func = self:getFuncByName(data.funcName)

				if not func then
					gDisplayMessageMgr:ShowMessageContentDebug("该接口不存在，无法执行请更新！")

					return
				end

				if data.fixedParams then
					func(unpack(data.fixedParams), inputStore.inputText.text)
				else
					func(inputStore.inputText.text)
				end

				self:updateHistoryData(data)
			end
		elseif data.tIndex == 6 then
			local store = gStoreManager:GetStoreGroup("TestInputTemplateStore"):GetStoreByWidget(btn)
			store.title = data.title
			local firstInputStore = gStoreManager:GetStoreGroup("InputFieldStore"):GetStoreByWidget(store.firstInput)
			firstInputStore.holderText = data.firstInputHolder
			local secondInputStore = gStoreManager:GetStoreGroup("InputFieldStore"):GetStoreByWidget(store.secondInput)
			secondInputStore.holderText = data.secondInputHolder
			local buttonStore = gStoreManager:GetStoreGroup("CommonButtonMStore"):GetStoreByWidget(store.button)
			buttonStore.enableTitle = data.buttonLabel
			buttonStore.disableTitle = data.buttonLabel

			function buttonStore.button.luaClick()
				local func = self:getFuncByName(data.funcName)
				local passCheck = true

				if not self:CheckParamType(firstInputStore.inputText.text, data.firstInputType) then
					passCheck = false

					gDisplayMessageMgr:ShowMessageContentDebug("第一个参数格式错误！")
				end

				if not self:CheckParamType(secondInputStore.inputText.text, data.secondInputType) then
					passCheck = false

					gDisplayMessageMgr:ShowMessageContentDebug("第二个参数格式错误！")
				end

				if passCheck then
					local res, _ = pcall(func, firstInputStore.inputText.text, secondInputStore.inputText.text)

					if not res then
						gDisplayMessageMgr:ShowMessageContentDebug("执行出错")
					end

					self:updateHistoryData(data)
				end
			end
		elseif data.tIndex == 7 then
			local store = gStoreManager:GetStoreGroup("SectorListTemplate1Store"):GetStoreByWidget(btn)

			if store then
				store.title = data.title
				store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnSectorListTemplateRenderItem", data.content)

				store.list:SetSimpleList(#data.content)

				local selcetedIndex = self:getFuncByName(data.getIndexFunc)()

				if selcetedIndex then
					store.list:SelectItem(selcetedIndex, false)
				else
					store.list:DeselectAll(false)
				end
			end
		elseif data.tIndex == 9 then
			local store = gStoreManager:GetStoreGroup("TestDoneTemplateStore"):GetStoreByWidget(btn)
			store.label = testMainUtils[data.labelFuncName]()

			if data.showButton == true then
				store.isButtonActive = ShowControl.Show
				store.enableText = data.enableText
				store.disableText = data.disableText

				function store.button.luaClick()
					self:getFuncByName(data.funcName)()
					self:updateHistoryData(data)
				end
			else
				store.isButtonActive = ShowControl.Hide
			end
		elseif data.tIndex == 10 then
			local store = gStoreManager:GetStoreGroup("TestBtnSTemplateStore"):GetStoreByWidget(btn)
			store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnTestBtnTemplateRenderItem", data.content)

			store.list:SetSimpleList(#data.content)
		elseif data.tIndex == 11 then
			local store = gStoreManager:GetStoreGroup("TestBtnTemplateV2Store"):GetStoreByWidget(btn)
			store.title = data.title
			store.firstButtonLabel = data.firstButtonLabel
			store.secondButtonLabel = data.secondButtonLabel

			function store.firstButton.luaClick()
				self:getFuncByName(data.firstButtonFunc)()
				self:RefreshTabRect()
				self:updateHistoryData(data)
			end

			function store.secondButton.luaClick()
				self:getFuncByName(data.secondButtonFunc)()
				self:RefreshTabRect()
				self:updateHistoryData(data)
			end

			local selectIndex = self:getFuncByName(data.getIndexFunc)()
			store.firstButton.isSelected = selectIndex == 0
			store.secondButton.isSelected = selectIndex == 1
		elseif data.tIndex == 12 then
			local store = gStoreManager:GetStoreGroup("SectorListTemplate3Store"):GetStoreByWidget(btn)
			store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnSectorListTemplateRenderItem", data.content)

			store.list:SetSimpleList(#data.content)

			local selcetedIndex = self:getFuncByName(data.getIndexFunc)()

			if selcetedIndex then
				store.list:SelectItem(selcetedIndex, false)
			else
				store.list:DeselectAll(false)
			end
		elseif data.tIndex == 13 then
			local store = gStoreManager:GetStoreGroup("CommonButtonM2Store"):GetStoreByWidget(btn)
			store.enableTitle = data.enableText

			function store.button.luaClick()
				self:getFuncByName(data.funcName)()
				self:updateHistoryData(data)
			end
		elseif data.tIndex == 14 then
			local store = gStoreManager:GetStoreGroup("TestPcTemplateStore"):GetStoreByWidget(btn)
			store.title = data.title
			store.label = data.label
		elseif data.tIndex == 15 then
			local store = gStoreManager:GetStoreGroup("TestInputTemplate2Store"):GetStoreByWidget(btn)
			store.title = data.title
			local firstInputStore = gStoreManager:GetStoreGroup("InputFieldStore"):GetStoreByWidget(store.firstInput)
			firstInputStore.holderText = data.firstInputHolder
			local secondInputStore = gStoreManager:GetStoreGroup("InputFieldStore"):GetStoreByWidget(store.secondInput)
			secondInputStore.holderText = data.secondInputHolder
			local thirdInputStore = gStoreManager:GetStoreGroup("InputFieldStore"):GetStoreByWidget(store.thirdInput)
			thirdInputStore.holderText = data.thirdInputHolder
			local buttonStore = gStoreManager:GetStoreGroup("CommonButtonMStore"):GetStoreByWidget(store.button)
			buttonStore.enableTitle = data.buttonLabel
			buttonStore.disableTitle = data.buttonLabel

			function buttonStore.button.luaClick()
				local func = self:getFuncByName(data.funcName)

				func(firstInputStore.inputText.text, secondInputStore.inputText.text, thirdInputStore.inputText.text)
				self:updateHistoryData(data)
			end

			if store.title == "位置" then
				self.bindData.pos1Input = store.firstInput
				self.bindData.pos2Input = store.secondInput
				self.bindData.pos3Input = store.thirdInput
			end

			if store.title == "镜头" then
				self.bindData.camera1Input = store.firstInput
				self.bindData.camera2Input = store.secondInput
				self.bindData.camera3Input = store.thirdInput
			end
		end
	end
end

function M:CheckParamType(text, targetType)
	if targetType == "number" then
		return tonumber(text) ~= nil
	end

	return true
end

function M:OnTestBtnTemplateRenderItem(content, btn, index)
	local data = content[index + 1]
	local store = gStoreManager:GetStoreGroup("CommonButtonSMStore"):GetStoreByWidget(btn)
	store.enableTitle = data.enableText
	store.disableTitle = data.disableText
	store.button.luaClick = self:getFuncByName(data.funcName)
end

function M:OnSectorListTemplateRenderItem(content, btn, index)
	local data = content[index + 1]
	local store = gStoreManager:GetStoreGroup("TestSelTemplateStore"):GetStoreByWidget(btn)
	store.title = data.title

	function store.button.luaClick()
		self:getFuncByName(data.funcName)()
		self:RefreshTabRect()
	end
end

function M:getFuncByName(funcName)
	local func = nil

	if rawget(L50.Gm.AutoQaFunctions, funcName) ~= nil then
		func = L50.Gm.AutoQaFunctions[funcName]
	else
		func = testMainUtils[funcName]
	end

	return func
end

function M:updateHistoryData(data)
	if json == nil then
		json = require("cjson/json")
	end

	local historyString = UnityEngine.PlayerPrefs.GetString("TestMainHistorys", "")
	local historys = {}

	if historyString ~= "" then
		historys = json.decode(historyString)
	end

	local recordData = testMainUtils.ConvertDataToHistoryRecord(data)
	local inHistory = false
	local findIndex = 0

	for i = 1, #historys do
		if self:IsTableEqual(historys[i], recordData) then
			findIndex = i
			inHistory = true

			break
		end
	end

	if not inHistory then
		table.insert(historys, recordData)

		local historyCount = #historys

		if maxHistoryCount < historyCount then
			table.remove(historys, 1)
		end

		local jsondata = json.encode(historys)

		UnityEngine.PlayerPrefs.SetString("TestMainHistorys", jsondata)
	elseif findIndex ~= #historys then
		local movedRecordData = historys[findIndex]

		table.remove(historys, findIndex)
		table.insert(historys, movedRecordData)

		local jsondata = json.encode(historys)

		UnityEngine.PlayerPrefs.SetString("TestMainHistorys", jsondata)
	end
end

function M:clearHistoryData()
	UnityEngine.PlayerPrefs.SetString("TestMainHistorys", "")
end

function M:IsTableEqual(table1, table2)
	local keys = table.keys(table1)

	for i = 1, #keys do
		local key = keys[i]

		if type(table1[key]) == "table" and type(table2[key]) == "table" then
			if not self:IsTableEqual(table1[key], table2[key]) then
				return false
			end
		elseif table1[key] ~= table2[key] then
			return false
		end
	end

	return true
end

function M:OpenDebugBool()
	self.bindData.prevData = self.bindData.curData
	self.bindData.curData = testMainUtils.GetDebugBoolData()
	self.bindData.curData.funcName = "CloseDebugBool"
	self.bindData.tabRect.selectedIndex = 1
end

function M:CloseDebugBool()
	self.bindData.curData = self.bindData.prevData
	self.bindData.tabRect.selectedIndex = 0
end

function M:OpenLogCategory()
	self.bindData.prevData = self.bindData.curData
	self.bindData.curData = testMainUtils.GetLogCategoryData()
	self.bindData.curData.funcName = "CloseLogCategory"
	self.bindData.tabRect.selectedIndex = 1
end

function M:CloseLogCategory()
	self.bindData.curData = self.bindData.prevData
	self.bindData.tabRect.selectedIndex = 0
end

function M:RefreshTabRect()
	if self.bindData.contentList then
		self.bindData.contentList:RefreshList()
	end

	if self.bindData.secondMenuList then
		self.bindData.secondMenuList:RefreshList()
	end
end

function M:PastePos(_, pos)
	if self.bindData.pos1Input then
		self.bindData.pos1Input.text = pos.x
		self.bindData.pos2Input.text = pos.y
		self.bindData.pos3Input.text = pos.z
	end
end

function M:ClearPos()
	self.bindData.pos1Input.text = ""
	self.bindData.pos2Input.text = ""
	self.bindData.pos3Input.text = ""
end

function M:ClearCameraDirection()
	self.bindData.camera1Input.text = ""
	self.bindData.camera2Input.text = ""
	self.bindData.camera3Input.text = ""
end

function M:PasteCamera(_, eulerAngles)
	if self.bindData.camera1Input then
		self.bindData.camera1Input.text = eulerAngles.x
		self.bindData.camera2Input.text = eulerAngles.y
		self.bindData.camera3Input.text = eulerAngles.z
	end
end

function M:TeleportToTargetPos()
	local pos1 = tonumber(self.bindData.pos1Input.text)
	local pos2 = tonumber(self.bindData.pos2Input.text)
	local pos3 = tonumber(self.bindData.pos3Input.text)

	if pos1 ~= nil and pos2 ~= nil and pos3 ~= nil then
		L50.Gm.AutoQaFunctions.TeleportXYZ(self.bindData.pos1Input.text, self.bindData.pos2Input.text, self.bindData.pos3Input.text)
	else
		gDisplayMessageMgr:ShowMessageContentDebug("请输入正确的坐标")
	end
end

function M:OnExitClick()
	gPanelManager:Close(gPanelId.S_TEST_MAIN_PANEL)
end
