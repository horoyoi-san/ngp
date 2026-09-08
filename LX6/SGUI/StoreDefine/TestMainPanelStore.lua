-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TestMainPanelStore.lua
-- Decompiled from: 01380_TestMainPanelStore.lua_6166a1ef5a86.luajit

C_TestMainPanelStore = DefClass("C_TestMainPanelStore", C_TestMainPanelStore, C_StoreGroup)
GroupName2Class.TestMainPanelStore = C_TestMainPanelStore
local M = C_TestMainPanelStore
local showall, tabDatas, testMainUtils, partTabDatas, json, switchOptions, ShowControl = nil
local maxHistoryCount = 15

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.InitLocalParams(self)

	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnTabListRenderItem")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.upperTabIndex = 0
	self.bindData.searchContent = {}
	self.bindData.storeToContentData = {}

	self.bindData.searchText.luaValueChanged = function(text, _, _)
		self:SetSecondMenuState(false)

		self.bindData.TestFirstStore.isTabListActive = ShowControl.Hide

		self.bindData.tabList:SelectItem(11)

		self.bindData.searchContent = testMainUtils.GetSearchContent(text, tabDatas)
		self.bindData.firstListData = self.bindData.searchContent

		self.bindData.contentList:SetSimpleList(#self.bindData.searchContent)
	end

	self.eventHandlers = {
		[gEventConstants.TEST_MAIN_OPEN_DEBUG_BOOL] = self.CreateAction(self, "OpenDebugBool"),
		[gEventConstants.TEST_MAIN_CLOSE_DEBUG_BOOL] = self.CreateAction(self, "CloseDebugBool"),
		[gEventConstants.TEST_MAIN_REFRESH_TAB_RECT] = self.CreateAction(self, "RefreshTabRect"),
		[gEventConstants.TEST_MAIN_PASTE_POS] = self.CreateAction(self, "PastePos"),
		[gEventConstants.TEST_MAIN_TELEPORT_TO_POS] = self.CreateAction(self, "TeleportToTargetPos"),
		[gEventConstants.TEST_MAIN_CLEAR_POS] = self.CreateAction(self, "ClearPos"),
		[gEventConstants.TEST_MAIN_CLEAR_CAMERA] = self.CreateAction(self, "ClearCameraDirection"),
		[gEventConstants.TEST_MAIN_PASTE_CAMERA] = self.CreateAction(self, "PasteCamera"),
		[gEventConstants.TEST_MAIN_OPEN_LOG_CATEGORY] = self.CreateAction(self, "OpenLogCategory"),
		[gEventConstants.TEST_MAIN_CLOSE_LOG_CATEGORY] = self.CreateAction(self, "CloseLogCategory"),
		[gEventConstants.TEST_MAIN_CLEAR_DEBUG_BOOL] = self.CreateAction(self, "ClearDebugBool"),
		[gEventConstants.TEST_MAIN_REFRESH_CURRENT_TAB] = self.CreateAction(self, "RefreshCurrentTab"),
		[gEventConstants.TEST_MAIN_CLEAR_LOG_CATEGORY] = self.CreateAction(self, "ClearLogCategory")
	}

	self.RegisterMessageEvents(self, self.eventHandlers)
end

M.InitLocalParams = function(self)
	if showall ~= nil then
		showall = L50.Gm.AutoQaFunctions.checkShowAll()
	end

	if tabDatas ~= nil then
		tabDatas = require("LX6/Data/TestMainData")
	end

	if testMainUtils ~= nil then
		testMainUtils = require("LX6/Utils/TestMainUtils")
	end

	testMainUtils.RefreshSwitchDatas(tabDatas)

	if partTabDatas ~= nil then
		partTabDatas = require("LX6/Data/TestMainPartData")
	end

	if switchOptions ~= nil then
		switchOptions = {
			{
				["X\\x94\\x80\\xa4N"] = "ARx}A>>",
				["\\xda\\xd7\\xfe"] = "\\xa9\\xa4\\xbfe0\\xd1="
			},
			{
				["X\\x94\\x80\\xa4N"] = "\\xa9\\xa4\\xbfe0\\xd1=",
				["\\xda\\xd7\\xfe"] = "ARx}A>>"
			}
		}
	end

	if ShowControl ~= nil then
		ShowControl = {
			["R+y^"] = 0,
			["I*rL"] = 1
		}
	end
end

M.OnEnable = function(self)
	self.SetSecondMenuState(self, false)

	if showall then
		self.bindData.tabList:SetSimpleList(#tabDatas)
	else
		self.bindData.tabList:SetSimpleList(#partTabDatas)
	end

	self.bindData.searchText.gameObjectActive = showall

	self.bindData.tabList:SelectItem(0)
end

M.OnShow = function(self, panelId, _)
	self.panelId = panelId
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnTabListRenderItem = function(self, btn, index)
	local data = nil

	if showall then
		data = tabDatas[index + 1]
	else
		data = partTabDatas[index + 1]
	end

	local store = gStoreManager:GetStoreGroup("MainTabStore"):GetStoreByWidget(btn)
	store.nameLabel = data.title
	store.button.luaClick = self:CreateActionWithArgs("OnMainTabClick", data)

	if data.isFirst ~= true then
		self.OnMainTabClick(self, data)
	end
end

M.OnMainTabClick = function(self, data)
	self.bindData.curData = data

	if data.tIndex == self.bindData.tabRect.selectedIndex then
		self.bindData.tabRect.selectedIndex = data.tIndex
	else
		self.bindData.tabRect.selectedIndex = -1
		self.bindData.tabRect.selectedIndex = data.tIndex
	end
end

M.OnTabRectRender = function(self, index, widget)
	self.SetSecondMenuState(self, false)

	if index ~= 0 then
		local store = gStoreManager:GetStoreGroup("TestFirstStore"):GetStoreByWidget(widget)
		self.bindData.TestFirstStore = store
		self.bindData.contentList = store.list
		store.list.luaSimpleRenderItem = self:CreateAction("OnFirstListRenderItem")
		store.list.luaSimpleDynamicRenderItem = self:CreateAction("OnFirstListRenderItem")
		store.list.onGetTIndex = self:CreateAction("OnGetFirstListTIndex")
		local showMainButton = self.bindData.curData.showMainButton
		store.mainButton.gameObjectActive = showMainButton ~= true
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
				mainButtonStore.buttonRoadSign.luaClick = function()
					gPanelManager:Close(gPanelId.S_TEST_MAIN_PANEL)
					gPanelManager:CheckShow(gPanelId.S_ROADSGIN_SUGGEST_PANEL)
				end
			end
		end
	elseif index ~= 1 then
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

M.OnTestListTemplateItem = function(self, btn, index, data)
	data = data or self.bindData.curData[index + 1]
	local store = gStoreManager:GetStoreGroup("TestListTemplateStore"):GetStoreByWidget(btn)
	store.label = data.name

	store.button.luaClick = function()
		self:UpdateToggles(data.content)
	end
end

M.UpdateToggles = function(self, content)
	self.bindData.testSelListData = content

	self:SetSecondMenuState(true)

	local wid = self.bindData.secondMenu
	local store = gStoreManager:GetStoreGroup("TestPopStore"):GetStoreByWidget(wid)
	store.list.luaSimpleRenderItem = self:CreateAction("OnTestSelTemplateRenderItem")

	store.list:SetSimpleList(#content)

	self.bindData.secondMenuList = store.list
end

M.SetSecondMenuState = function(self, isOn)
	self.bindData.secondMenu.gameObjectActive = isOn
	self.bindData.searchText.gameObjectActive = not isOn
end

M.OnTestSelTemplateRenderItem = function(self, btn, index, data)
	data = data or self.bindData.testSelListData[index + 1]
	local store = gStoreManager:GetStoreGroup("TestSelTemplate1Store"):GetStoreByWidget(btn)
	store.title = data.label

	store.switcher:SetSimpleOptions(#switchOptions)

	store.switcher.luaSimpleRenderSwitcher = function(_, index)
		local item = switchOptions[index + 1]
		store[item.openGo].gameObjectActive = true
		store[item.closeGo].gameObjectActive = false
	end

	if data.isFeatureSwitch then
		local selectedIndex = data.isOn and 1 or 0

		store.switcher:SelectOption(selectedIndex, false)

		store.switcher.luaSelectedChanged = function()
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

		store.switcher.luaSelectedChanged = function()
			local index = store.switcher.selectedIndex

			if data.switcherHander and data.switchName then
				data.switcherHander[data.switchName] = index ~= 1 and true or false
			end

			if data.switchFunc then
				self:getFuncByName(data.switchFunc)()
			end

			self:updateHistoryData(data)
		end
	end
end

M.OnGetFirstListTIndex = function(self, index)
	return self.bindData.firstListData[index + 1].tIndex
end

M.OnFirstListRenderItem = function(self, btn, index)
	local data = self.bindData.firstListData[index + 1]

	if data.tIndex ~= 2 then
		local store = gStoreManager:GetStoreGroup("TitleMainStore"):GetStoreByWidget(btn)
		store.titleLabel = data.title
	elseif data.tIndex ~= 1 then
		local store = gStoreManager:GetStoreGroup("TestMainTemplate2Store"):GetStoreByWidget(btn)
		self.bindData.testPopWidget = store.secondMenu
		local content = self.bindData.firstListData[index + 1].content
		local length = #content
		store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnTemplate2ListRenderItem", content)
		store.list.onGetTIndex = self:CreateActionWithArgs("OnGetTemplate2ListTIndex", content)

		store.list:SetSimpleList(length)
	end
end

M.OnTestTabListRenderItem = function(self, btn, index)
	local data = self.bindData.tabContentData[index + 1]
	local store = gStoreManager:GetStoreGroup("TestTabLv2TemplateStore"):GetStoreByWidget(btn)
	store.label = data.label

	if data.index ~= self.bindData.upperTabIndex then
		local contentData = data.content == nil and data.content or testMainUtils[data.getContentFunc]()
		self.bindData.firstListData = contentData

		self.bindData.contentList:SetSimpleList(#contentData)
	end

	store.button.luaClick = function()
		local contentData = data.content == nil and data.content or testMainUtils[data.getContentFunc]()
		self.bindData.firstListData = contentData

		self.bindData.contentList:SetSimpleList(#contentData)

		self.bindData.upperTabIndex = data.index
	end
end

M.OnGetTemplate2ListTIndex = function(self, content, index)
	return content[index + 1].tIndex
end

M.OnTemplate2ListRenderItem = function(self, content, btn, index)
	local data = content[index + 1]

	if data.tIndex ~= 0 then
		slot5 = gStoreManager
		slot5 = slot5:GetStoreGroup("commonButtonLv1Store")
		local store = slot5:GetStoreByWidget(btn)
		store.enableTitle = data.enableText
		store.disableTitle = data.disableText

		store.button.luaClick = function()
			if data.params then
				self:getFuncByName(data.funcName)(unpack(data.params))
			else
				local r, error = xpcall(self:getFuncByName(data.funcName), tolua.traceback)
			end

			self:updateHistoryData(data)
		end
	else
		if data.tIndex ~= 1 then
			local store = gStoreManager:GetStoreGroup("TestSwitcherTemplateStore"):GetStoreByWidget(btn)
			store.label = data.label
			local switchStore = gStoreManager:GetStoreGroup("TestSwitherStore"):GetStoreByWidget(store.switcher)

			switchStore.switcher:SetSimpleOptions(#switchOptions)

			if not self:getFuncByName(data.checkIsOnFunc) then
				print_error("not find function: " .. data.checkIsOnFunc)
			end

			local selectedIndex = nil

			if data.prefsKey then
				if self.getFuncByName(self, data.checkIsOnFunc)(data.prefsKey) then
					selectedIndex = 1
				else
					selectedIndex = 0
				end
			elseif self.getFuncByName(self, data.checkIsOnFunc)() then
				selectedIndex = 1
			else
				selectedIndex = 0
			end

			slot8 = switchStore.switcher

			slot8:SelectOption(selectedIndex, false)

			switchStore.switcher.luaSimpleRenderSwitcher = function(_, index)
				local item = switchOptions[index + 1]
				switchStore[item.openGo].gameObjectActive = true
				switchStore[item.closeGo].gameObjectActive = false
			end

			switchStore.switcher.luaSelectedChanged = function(_)
				if data.prefsKey then
					self:getFuncByName(data.onSwitch)(data.prefsKey)
				else
					self:getFuncByName(data.onSwitch)()
				end

				self:updateHistoryData(data)
			end

			return
		end

		if data.tIndex ~= 2 then
			local store = gStoreManager:GetStoreGroup("TestBtnTemplateStore"):GetStoreByWidget(btn)
			store.label = data.label

			if data.buttonLabel then
				local buttonStore = gStoreManager:GetStoreGroup("CommonButtonSStore"):GetStoreByWidget(store.button)
				buttonStore.enableTitle = data.buttonLabel
				buttonStore.disableTitle = data.buttonLabel
			end

			store.button.luaClick = function()
				if data.params then
					self:getFuncByName(data.funcName)(unpack(data.params))
				else
					self:getFuncByName(data.funcName)()
				end

				self:updateHistoryData(data)
			end
		elseif data.tIndex ~= 3 then
			self.OnTestSelTemplateRenderItem(self, btn, index, data)
		elseif data.tIndex ~= 4 then
			self.OnTestListTemplateItem(self, btn, index, data)
		elseif data.tIndex ~= 5 then
			slot5 = gStoreManager
			slot5 = slot5:GetStoreGroup("TestInputTemplate1Store")
			local store = slot5:GetStoreByWidget(btn)
			store.title = data.title
			slot6 = gStoreManager
			slot6 = slot6:GetStoreGroup("InputFieldLStore")
			local inputStore = slot6:GetStoreByWidget(store.inputField)
			inputStore.holderText = data.holderText
			slot7 = gStoreManager
			slot7 = slot7:GetStoreGroup("CommonButtonMStore")
			local buttonStore = slot7:GetStoreByWidget(store.button)
			buttonStore.enableTitle = data.buttonLabel
			buttonStore.disableTitle = data.buttonLabel

			buttonStore.button.luaClick = function()
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
		elseif data.tIndex ~= 6 then
			slot5 = gStoreManager
			slot5 = slot5:GetStoreGroup("TestInputTemplateStore")
			local store = slot5:GetStoreByWidget(btn)
			store.title = data.title
			slot6 = gStoreManager
			slot6 = slot6:GetStoreGroup("InputFieldStore")
			local firstInputStore = slot6:GetStoreByWidget(store.firstInput)
			firstInputStore.holderText = data.firstInputHolder
			slot7 = gStoreManager
			slot7 = slot7:GetStoreGroup("InputFieldStore")
			local secondInputStore = slot7:GetStoreByWidget(store.secondInput)
			secondInputStore.holderText = data.secondInputHolder
			slot8 = gStoreManager
			slot8 = slot8:GetStoreGroup("CommonButtonMStore")
			local buttonStore = slot8:GetStoreByWidget(store.button)
			buttonStore.enableTitle = data.buttonLabel
			buttonStore.disableTitle = data.buttonLabel

			buttonStore.button.luaClick = function()
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
		elseif data.tIndex ~= 7 then
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
		elseif data.tIndex ~= 9 then
			local store = gStoreManager:GetStoreGroup("TestDoneTemplateStore"):GetStoreByWidget(btn)
			store.label = testMainUtils[data.labelFuncName]()

			if data.showButton ~= true then
				store.isButtonActive = ShowControl.Show
				store.enableText = data.enableText
				store.disableText = data.disableText

				store.button.luaClick = function()
					self:getFuncByName(data.funcName)()
					self:updateHistoryData(data)
				end
			else
				store.isButtonActive = ShowControl.Hide
			end
		elseif data.tIndex ~= 10 then
			local store = gStoreManager:GetStoreGroup("TestBtnSTemplateStore"):GetStoreByWidget(btn)
			store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnTestBtnTemplateRenderItem", data.content)

			store.list:SetSimpleList(#data.content)
		elseif data.tIndex ~= 11 then
			local store = gStoreManager:GetStoreGroup("TestBtnTemplateV2Store"):GetStoreByWidget(btn)
			store.title = data.title
			store.firstButtonLabel = data.firstButtonLabel
			store.secondButtonLabel = data.secondButtonLabel

			store.firstButton.luaClick = function()
				self:getFuncByName(data.firstButtonFunc)()
				self:RefreshTabRect()
				self:updateHistoryData(data)
			end

			store.secondButton.luaClick = function()
				self:getFuncByName(data.secondButtonFunc)()
				self:RefreshTabRect()
				self:updateHistoryData(data)
			end

			local selectIndex = self:getFuncByName(data.getIndexFunc)()
			store.firstButton.isSelected = selectIndex ~= 0
			store.secondButton.isSelected = selectIndex ~= 1
		elseif data.tIndex ~= 12 then
			local store = gStoreManager:GetStoreGroup("SectorListTemplate3Store"):GetStoreByWidget(btn)
			store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnSectorListTemplateRenderItem", data.content)

			store.list:SetSimpleList(#data.content)

			local selcetedIndex = self:getFuncByName(data.getIndexFunc)()

			if selcetedIndex then
				store.list:SelectItem(selcetedIndex, false)
			else
				store.list:DeselectAll(false)
			end
		elseif data.tIndex ~= 13 then
			slot5 = gStoreManager
			slot5 = slot5:GetStoreGroup("CommonButtonM2Store")
			local store = slot5:GetStoreByWidget(btn)
			store.enableTitle = data.enableText

			store.button.luaClick = function()
				self:getFuncByName(data.funcName)()
				self:updateHistoryData(data)
			end
		elseif data.tIndex ~= 14 then
			local store = gStoreManager:GetStoreGroup("TestPcTemplateStore"):GetStoreByWidget(btn)
			store.title = data.title
			store.label = data.label
		elseif data.tIndex ~= 15 then
			slot5 = gStoreManager
			slot5 = slot5:GetStoreGroup("TestInputTemplate2Store")
			local store = slot5:GetStoreByWidget(btn)
			store.title = data.title
			slot6 = gStoreManager
			slot6 = slot6:GetStoreGroup("InputFieldStore")
			local firstInputStore = slot6:GetStoreByWidget(store.firstInput)
			firstInputStore.holderText = data.firstInputHolder
			slot7 = gStoreManager
			slot7 = slot7:GetStoreGroup("InputFieldStore")
			local secondInputStore = slot7:GetStoreByWidget(store.secondInput)
			secondInputStore.holderText = data.secondInputHolder
			slot8 = gStoreManager
			slot8 = slot8:GetStoreGroup("InputFieldStore")
			local thirdInputStore = slot8:GetStoreByWidget(store.thirdInput)
			thirdInputStore.holderText = data.thirdInputHolder
			slot9 = gStoreManager
			slot9 = slot9:GetStoreGroup("CommonButtonMStore")
			local buttonStore = slot9:GetStoreByWidget(store.button)
			buttonStore.enableTitle = data.buttonLabel
			buttonStore.disableTitle = data.buttonLabel

			buttonStore.button.luaClick = function()
				local func = self:getFuncByName(data.funcName)

				func(firstInputStore.inputText.text, secondInputStore.inputText.text, thirdInputStore.inputText.text)
				self:updateHistoryData(data)
			end

			if store.title ~= "位置" then
				self.bindData.pos1Input = store.firstInput
				self.bindData.pos2Input = store.secondInput
				self.bindData.pos3Input = store.thirdInput
			end

			if store.title ~= "镜头" then
				self.bindData.camera1Input = store.firstInput
				self.bindData.camera2Input = store.secondInput
				self.bindData.camera3Input = store.thirdInput
			end
		elseif data.tIndex ~= 16 then
			slot5 = gStoreManager
			slot5 = slot5:GetStoreGroup("TestSlideTemplate2Store")
			local store = slot5:GetStoreByWidget(btn)
			store.title = data.title
			local getStateFunc = self:getFuncByName(data.getStateFunc)
			local getValueFunc = self:getFuncByName(data.getValueFunc)
			store.currentState = getStateFunc()
			store.slider.value = getValueFunc()

			store.slider.luaValueChanged = function(process)
				self:getFuncByName(data.onValueChanged)(process)

				store.currentState = getStateFunc()
			end

			store.leftBtn.luaClick = function()
				self:getFuncByName(data.leftFunc)()

				store.currentState = getStateFunc()

				store.slider:SetValueWithParams(getValueFunc(), 0, 100, 0.01, false)
			end

			store.rightBtn.luaClick = function()
				self:getFuncByName(data.rightFunc)()

				store.currentState = getStateFunc()

				store.slider:SetValueWithParams(getValueFunc(), 0, 100, 0.01, false)
			end

			store.button.luaClick = function()
				self:getFuncByName(data.exceuteFunc)()
			end
		end
	end
end

M.CheckParamType = function(self, text, targetType)
	if targetType ~= "number" then
		return tonumber(text) == nil
	end

	return true
end

M.OnTestBtnTemplateRenderItem = function(self, content, btn, index)
	local data = content[index + 1]
	local store = gStoreManager:GetStoreGroup("CommonButtonSMStore"):GetStoreByWidget(btn)
	store.enableTitle = data.enableText
	store.disableTitle = data.disableText
	store.button.luaClick = self:getFuncByName(data.funcName)
end

M.OnSectorListTemplateRenderItem = function(self, content, btn, index)
	local data = content[index + 1]
	slot5 = gStoreManager
	slot5 = slot5:GetStoreGroup("TestSelTemplateStore")
	local store = slot5:GetStoreByWidget(btn)
	store.title = data.title

	store.button.luaClick = function()
		self:getFuncByName(data.funcName)()
		self:RefreshTabRect()
	end
end

M.getFuncByName = function(self, funcName)
	local func = nil

	if rawget(L50.Gm.AutoQaFunctions, funcName) == nil then
		func = L50.Gm.AutoQaFunctions[funcName]
	else
		func = testMainUtils[funcName]
	end

	return func
end

M.updateHistoryData = function(self, data)
	if json ~= nil then
		json = require("cjson/json")
	end

	local historyString = UnityEngine.PlayerPrefs.GetString("TestMainHistorys", "")
	local historys = {}

	if historyString == "" then
		historys = json.decode(historyString)
	end

	local recordData = testMainUtils.ConvertDataToHistoryRecord(data)
	local inHistory = false
	local findIndex = 0

	for i = 1, #historys do
		if self.IsTableEqual(self, historys[i], recordData) then
			findIndex = i
			inHistory = true

			break
		end
	end

	if not inHistory then
		table.insert(historys, recordData)

		local historyCount = #historys

		if maxHistoryCount >= historyCount then
			table.remove(historys, 1)
		end

		local jsondata = json.encode(historys)

		UnityEngine.PlayerPrefs.SetString("TestMainHistorys", jsondata)
	elseif findIndex == #historys then
		local movedRecordData = historys[findIndex]

		table.remove(historys, findIndex)
		table.insert(historys, movedRecordData)

		local jsondata = json.encode(historys)

		UnityEngine.PlayerPrefs.SetString("TestMainHistorys", jsondata)
	end
end

M.clearHistoryData = function(self)
	UnityEngine.PlayerPrefs.SetString("TestMainHistorys", "")
end

M.IsTableEqual = function(self, table1, table2)
	local keys = table.keys(table1)

	for i = 1, #keys do
		local key = keys[i]

		if type(table1[key]) ~= "table" and type(table2[key]) ~= "table" then
			if not self.IsTableEqual(self, table1[key], table2[key]) then
				return false
			end
		elseif table1[key] == table2[key] then
			return false
		end
	end

	return true
end

M.OpenDebugBool = function(self)
	self.bindData.prevData = self.bindData.curData
	self.bindData.curData = testMainUtils.GetDebugBoolData()
	self.bindData.curData.funcName = "CloseDebugBool"
	self.bindData.tabRect.selectedIndex = 1
end

M.CloseDebugBool = function(self)
	self.bindData.curData = self.bindData.prevData
	self.bindData.tabRect.selectedIndex = 0
end

M.OpenLogCategory = function(self)
	self.bindData.prevData = self.bindData.curData
	self.bindData.curData = testMainUtils.GetLogCategoryData()
	self.bindData.curData.funcName = "CloseLogCategory"
	self.bindData.tabRect.selectedIndex = 1
end

M.CloseLogCategory = function(self)
	self.bindData.curData = self.bindData.prevData
	self.bindData.tabRect.selectedIndex = 0
end

M.ClearDebugBool = function(self)
	local viewList = gCS.DebugBoolMgr.GetView()

	for i = 0, viewList.Count - 1 do
		local debugBoolList = viewList[i].list

		for j = 0, debugBoolList.Count - 1 do
			local debugBool = debugBoolList[j]

			if debugBool.field then
				debugBool.field = false

				debugBool.OnChange(debugBool)
			end
		end
	end
end

M.ClearLogCategory = function(self)
	local LogCategoryMenu = LX6.Utils.LogCategoryMenu
	local items = LogCategoryMenu.s_PreprocessingItems

	for i = 0, items.Count - 1 do
		LogCategoryMenu.SetMenuSwitch(i, false)
	end
end

M.RefreshTabRect = function(self)
	if self.bindData.contentList then
		self.bindData.contentList:RefreshList()
	end

	if self.bindData.secondMenuList then
		self.bindData.secondMenuList:RefreshList()
	end
end

M.RefreshCurrentTab = function(self)
	if self.bindData.tabContentData then
		local tabIndex = self.bindData.upperTabIndex or 0
		local data = self.bindData.tabContentData[tabIndex + 1]

		if data and data.getContentFunc then
			local contentData = testMainUtils[data.getContentFunc]()
			self.bindData.firstListData = contentData

			self.bindData.contentList:SetSimpleList(#contentData)
		end
	end
end

M.PastePos = function(self, _, pos)
	if self.bindData.pos1Input then
		self.bindData.pos1Input.text = pos.x
		self.bindData.pos2Input.text = pos.y
		self.bindData.pos3Input.text = pos.z
	end
end

M.ClearPos = function(self)
	self.bindData.pos1Input.text = ""
	self.bindData.pos2Input.text = ""
	self.bindData.pos3Input.text = ""
end

M.ClearCameraDirection = function(self)
	self.bindData.camera1Input.text = ""
	self.bindData.camera2Input.text = ""
	self.bindData.camera3Input.text = ""
end

M.PasteCamera = function(self, _, eulerAngles)
	if self.bindData.camera1Input then
		self.bindData.camera1Input.text = eulerAngles.x
		self.bindData.camera2Input.text = eulerAngles.y
		self.bindData.camera3Input.text = eulerAngles.z
	end
end

M.TeleportToTargetPos = function(self)
	local pos1 = tonumber(self.bindData.pos1Input.text)
	local pos2 = tonumber(self.bindData.pos2Input.text)
	local pos3 = tonumber(self.bindData.pos3Input.text)

	if pos1 == nil and pos2 == nil and pos3 == nil then
		L50.Gm.AutoQaFunctions.TeleportXYZ(self.bindData.pos1Input.text, self.bindData.pos2Input.text, self.bindData.pos3Input.text)
	else
		gDisplayMessageMgr:ShowMessageContentDebug("请输入正确的坐标")
	end
end

M.OnExitClick = function(self)
	gPanelManager:Close(gPanelId.S_TEST_MAIN_PANEL)
end
