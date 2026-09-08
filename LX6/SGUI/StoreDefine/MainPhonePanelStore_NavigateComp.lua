-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MainPhonePanelStore_NavigateComp.lua
-- Decompiled from: 01967_MainPhonePanelStore_NavigateComp.lua_e497310743ae.luajit

C_MainPhonePanelStore_NavigateComp = DefClass("C_MainPhonePanelStore_NavigateComp", C_MainPhonePanelStore_NavigateComp)
local M = C_MainPhonePanelStore_NavigateComp

M.ctor = function(self, attachStore)
	self.attachStore = attachStore
	self.defaultContentSelected = false
	self.needRegisterListeners = true
	self.destroyed = false
	self.currentLogicalPage = 0
	self.btn2AppId = {}
	self.appId2Index = {}
	self.index2Btn = {}
	local bindData = attachStore.bindData
	self.bindData = bindData
	self.mainPageList = bindData.mainPhoneList
	self.bottomList = bindData.bottomList
	self.topFakeNavButton2 = bindData.topFakeNavButton2
	self.topFakeNavButton3 = bindData.topFakeNavButton3
	self.moveLeftFakeNavButtons = bindData.moveLeftFakeNavButtons
	self.navigationArea = bindData.navigationArea
	self.startNavContent = bindData.startNavContent
	self.controllerKeyL1 = bindData.controllerKeyL1
	self.controllerKeyR1 = bindData.controllerKeyR1
	self.defaultSelectIndexIfTopButtonActive = 5
	self.defaultSelectIndexIfTopButtonInactive = 4
	self.buttonCountInHomePageIfTopButtonInactive = 17
	self.buttonCountInNormalPage = 20
	self.topButtonMerged = false
	self.disabled = false

	if debug then
		self.debugInfo = "no debug info"
	end

	self.RegisterMainPageListCallbacks(self)
end

M.Destroy = function(self)
	self.destroyed = true
	self.disabled = false
	self.focusAppIdBeforePreview = nil
	self.pageBeforePreview = nil
	self.waitForScrollEndCallbacks = nil
	self.focusAppId = nil

	if gClientUtils.NotNil(self.mainPageList) then
		if self.pageEventHandler then
			self.mainPageList:UnRegisterToPageEvent(self.pageEventHandler)
		end

		if self.scrollEndHandler then
			self.mainPageList:UnRegisterToScrollEvent(self.scrollEndHandler)
		end

		if self.mainPageList.luaLayoutSet ~= self.layoutSetHandler then
			self.mainPageList.luaLayoutSet = nil
		end
	end

	self.pageEventHandler = nil
	self.scrollEndHandler = nil
	self.layoutSetHandler = nil
end

M.RegisterMainPageListCallbacks = function(self)
	if gClientUtils.IsNil(self.mainPageList) then
		self.Destroy(self)

		return
	end

	self.layoutSetHandler = self.layoutSetHandler or self:CreateAction(self.OnLayoutSet)
	self.scrollEndHandler = self.scrollEndHandler or self:CreateAction(self.OnScrollEnd)
	self.mainPageList.luaLayoutSet = self.layoutSetHandler

	self.mainPageList:UnRegisterToScrollEvent(self.scrollEndHandler)
	self.mainPageList:RegisterToScrollEvent(self.scrollEndHandler)
end

M.SetDisable = function(self, disable)
	self.disabled = disable
end

M.GetTopButtonUseSpace = function(self)
	if self.topButtonMerged then
		return 3
	end

	return 4
end

M.OnLayoutSet = function(self)
	if self.destroyed or self.disabled then
		return
	end

	self.Refresh(self)
end

M.OnScrollEnd = function(self)
	if self.destroyed then
		return
	end

	self.currentListPage = self.mainPageList:GetNearestPageIndex()
	local waitForScrollEndCallbacks = self.waitForScrollEndCallbacks

	if waitForScrollEndCallbacks then
		self.waitForScrollEndCallbacks = nil

		if self.destroyed or self.disabled then
			return
		end

		for _, callback in ipairs(waitForScrollEndCallbacks) do
			callback()
		end
	end
end

M.WaitForScrollEnd = function(self, callback)
	self.waitForScrollEndCallbacks = self.waitForScrollEndCallbacks or {}

	table.insert(self.waitForScrollEndCallbacks, callback)
end

M.Refresh = function(self)
	if gClientUtils.IsNil(self.topFakeNavButton2) or gClientUtils.IsNil(self.topFakeNavButton3) or gClientUtils.IsNil(self.bottomList) or gClientUtils.IsNil(self.navigationArea) or gClientUtils.IsNil(self.mainPageList) or gClientUtils.IsNil(self.startNavContent) then
		print_warn("MainPhonePanelStore_NavigateComp Refresh failed, some UI components are nil. topFakeNavButton2=", self.topFakeNavButton2, " topFakeNavButton3=", self.topFakeNavButton3, " bottomList=", self.bottomList, " navigationArea=", self.navigationArea, " mainPageList=", self.mainPageList, " startNavContent=", self.startNavContent)
		self.Destroy(self)

		return
	end

	self.isTopButtonActive = gMainPhoneUtils.CheckMainPhoneTopButtonUnlocked()

	self.topFakeNavButton2:SetActive(self.isTopButtonActive and self.topButtonMerged)
	self.topFakeNavButton3:SetActive(self.isTopButtonActive and not self.topButtonMerged)

	local topButtonUseSpace = self:GetTopButtonUseSpace()
	self.buttonCountInHomePage = self.isTopButtonActive and self.buttonCountInHomePageIfTopButtonInactive - topButtonUseSpace + 1 or self.buttonCountInHomePageIfTopButtonInactive

	for _, item in pairs(self.index2Btn) do
		if gClientUtils.NotNil(item) then
			item.luaFocus = self.CreateActionWithArgs(self, self.OnButtonFocus, item)
		end
	end

	self.bottomItems = self.bottomList.items

	if not table.isNilOrEmpty(self.index2Btn) then
		local lastIndex = -1

		for k, v in pairs(self.index2Btn) do
			lastIndex = k
		end

		local lastButton = self.index2Btn[lastIndex]

		if lastButton and tolua.typeof(lastButton) ~= typeof(L18.Script.SGUI.SGUICustomNavigateButton) then
			lastButton.minScoreRight = 1
		end

		self.topButton = self.index2Btn[0]
	end

	self:UpdateSwitchPageButtons(self.currentLogicalPage)

	local defaultSelectIndex = self.isTopButtonActive and self.defaultSelectIndexIfTopButtonActive or self.defaultSelectIndexIfTopButtonInactive

	if self.index2Btn[defaultSelectIndex] and not self.defaultContentSelected then
		self.defaultContentSelected = true

		if not SGUI.GuideMgr.IsNavigationLockedByGuide(self.index2Btn[defaultSelectIndex]) then
			self.SetCurrentActiveContent(self, self.index2Btn[defaultSelectIndex])
		end
	end

	if self.needRegisterListeners then
		self.startNavContent.luaFocus = self:CreateAction(self.OnDefaultNavButtonFocus)
		self.navigationArea.luaAreaIn = self:CreateAction(self.OnNavigationAreaIn)

		self.topFakeNavButton2.luaClick = function(content, eventData)
			self:OnMoveToMapFakeButton(content, eventData)
		end

		self.topFakeNavButton3.luaClick = function(content, eventData)
			self:OnMoveToMapFakeButton(content, eventData)
		end

		self.pageEventHandler = self:CreateAction(self.OnPageChanged)

		self.mainPageList:RegisterToPageEvent(self.pageEventHandler)

		self.controllerKeyL1.luaClick = function(content, eventData)
			self:OnClickControllerKey(content, eventData)
		end

		self.controllerKeyR1.luaClick = function(content, eventData)
			self:OnClickControllerKey(content, eventData)
		end

		local moveLeftButtons = self.moveLeftFakeNavButtons:GetComponentsInChildren(typeof(SGUI.UButton))

		for i = 0, moveLeftButtons.Length - 1 do
			local button = moveLeftButtons[i]
			local row = i

			button.luaFocus = function()
				slot0 = self

				slot0:SetCurrentPageWithAnim(self.currentLogicalPage - 1, false)

				slot0 = self

				slot0:WaitForScrollEnd(function ()
					self:SetCurrentActiveContent(self:GetRightButtonInRow(row, self.currentLogicalPage))
				end)
			end
		end

		self.needRegisterListeners = false
	end
end

M.OnButtonFocus = function(self, bindParent)
	if self.destroyed or self.disabled then
		return
	end

	self.bButtonFocusOnce = nil
	local appId = self.btn2AppId[bindParent]
	local index = appId and self.appId2Index[appId]

	if index ~= nil then
		print_error("#NoCreateIssue MainPhonePanelStore_NavigateComp OnButtonFocus failed, invalid index=", index, "appId=", appId, " bindParent=", bindParent, table.count(self.btn2AppId), self.debugInfo, self.appId2Index)

		return
	end

	self.focusAppId = appId

	if index > 0 then
		self.SetCurrentPageWithAnim(self, self.Index2PageIndex(self, index), true)
	else
		print_warn("@liulijun04 GetItemButtonIndex->" .. tostring(index), bindParent)
	end

	local showMapFakeNavButton = self.isTopButtonActive and index <= 0 and index <= self.buttonCountInHomePage

	self.topFakeNavButton2:SetActiveFastest(showMapFakeNavButton)
	self.topFakeNavButton3:SetActiveFastest(showMapFakeNavButton)
end

M.GetRealNavigateButtons = function(self, tIndex, btn)
	if tIndex ~= gClientConst.MainPhoneTemplateType.FourAppTIndex then
		local store = gStoreManager:GetStoreGroup("FourIconTemplateStore"):GetStoreByWidget(btn)
		local success, subBtn1, subBtn2, subBtn3, subBtn4 = nil
		success, subBtn1 = store.appList:TryGetChildAt(0, nil)
		success, subBtn2 = store.appList:TryGetChildAt(1, nil)
		success, subBtn3 = store.appList:TryGetChildAt(2, nil)
		success, subBtn4 = store.appList:TryGetChildAt(3, nil)

		return {
			subBtn1,
			subBtn2,
			subBtn3,
			subBtn4
		}, true
	elseif tIndex ~= gClientConst.MainPhoneTemplateType.SingleAppTIndex then
		return btn, false
	elseif tIndex ~= gClientConst.MainPhoneTemplateType.FansIndex or tIndex ~= gClientConst.MainPhoneTemplateType.IndividualizationFansIndex or tIndex ~= gClientConst.MainPhoneTemplateType.TopButton then
		local buttons = btn.GetComponentsInChildren(btn, typeof(SGUI.UButton))

		for i = 0, buttons.Length - 1 do
			local subBtn = buttons[i]

			if subBtn.navigation.mode <= 0 then
				return subBtn, false
			end
		end

		print_error("MainPhonePanelStore_NavigateComp GetRealNavigateButtons failed, no valid subBtn, tIndex=", tIndex, " button=", btn, "debug info", self.debugInfo)

		return btn, false
	else
		print_error("MainPhonePanelStore_NavigateComp GetRealNavigateButtons failed, unknown tIndex=", tIndex, " button=", btn, "debug info", self.debugInfo)

		return btn, false
	end
end

M.OnRenderItem = function(self, button, csIndex, data)
	if self.destroyed then
		print_error("MainPhonePanelStore_NavigateComp OnRenderItem failed, navigateComp has been destroyed", button, csIndex, data, self.debugInfo, self)

		return
	end

	if self.disabled then
		return
	end

	if data.tIndex ~= gClientConst.MainPhoneTemplateType.FourAppTIndex then
		return
	else
		button = self:GetRealNavigateButtons(data.tIndex or gClientConst.MainPhoneTemplateType.SingleAppTIndex, button)
	end

	if data.id then
		local index = self.appId2Index[data.id]
		self.btn2AppId[button] = data.id

		if index then
			self.index2Btn[index] = button
		else
			print_error("OnRenderItem: index not found", data, self.index2Btn, self.appId2Index, self.debugInfo, self)
		end
	end

	if tolua.typeof(button) ~= typeof(L18.Script.SGUI.SGUICustomNavigateButton) then
		button.minScoreRight = 0
	end
end

M.OnPageChanged = function(self, page)
	if self.destroyed or self.disabled then
		return
	end

	self.SetCurrentPageWithAnim(self, page, true)
end

M.OnMoveToMapFakeButton = function(self, _, _)
	if self.destroyed or self.disabled then
		return
	end

	self.SetCurrentActiveContent(self, self.topButton)
end

M.OnClickControllerKey = function(self, content, _)
	if self.destroyed or self.disabled then
		return
	end

	local delta = content ~= self.controllerKeyL1 and -1 or 1

	self:SetCurrentPageWithAnim(self.currentLogicalPage + delta, true)
end

M.OnSetToPoolCallback = function(self, tIndex, btn)
	if self.destroyed or self.disabled then
		return
	end

	local buttons, isList = self.GetRealNavigateButtons(self, tIndex, btn)

	if isList then
		for _, subBtn in pairs(buttons) do
			self.OnNavigateButtonSetToPool(self, subBtn)
		end
	else
		self.OnNavigateButtonSetToPool(self, buttons)
	end
end

M.OnNavigateButtonSetToPool = function(self, btn)
	if self.destroyed or self.disabled then
		return
	end

	if gClientUtils.IsNil(btn) then
		return
	end

	if self.btn2AppId[btn] ~= nil then
		for k, v in pairs(self.index2Btn) do
			if v ~= btn then
				self.index2Btn[k] = nil
			end
		end

		return
	end

	local appId = self.btn2AppId[btn]
	local index = self.appId2Index[appId]

	if index then
		self.index2Btn[index] = nil
	else
		print_error("OnNavigateButtonSetToPool: index not found", appId, self.index2Btn, self.appId2Index, self.debugInfo, self)
	end

	self.btn2AppId[btn] = nil
end

M.BeforeSetSimpleList = function(self, viewDataList)
	self.defaultContentSelected = false
	self.appId2Index = {}
	self.btn2AppId = {}
	self.index2Btn = {}
	local index = 0

	if #viewDataList > 1 then
		viewDataList[1].id = viewDataList[1].id or -1
	end

	if #viewDataList > 2 then
		viewDataList[2].id = viewDataList[2].id or -2
	end

	for _, item in ipairs(viewDataList) do
		if item.appList then
			for _, subApp in ipairs(item.appList) do
				self.appId2Index[subApp.id] = index
				index = index + 1
			end
		else
			self.appId2Index[item.id] = index
			index = index + 1
		end
	end
end

M.OnEnterPreviewSkinMode = function(self)
	self:SetDisable(true)

	local currentContent = gClientUtils.NotNil(self.navigationArea) and self.navigationArea.CurrentActiveContent
	local currentAppId = currentContent and self.btn2AppId[currentContent]
	self.focusAppIdBeforePreview = currentAppId
	self.pageBeforePreview = self.bindData.pageList.selectedIndex
end

M.OnExitPreviewSkinMode = function(self)
	self.SetDisable(self, false)

	local focusAppId = self.focusAppIdBeforePreview
	self.focusAppIdBeforePreview = nil
	local pageBeforePreview = self.pageBeforePreview
	self.pageBeforePreview = nil

	self.RestoreFocusToAppId(self, focusAppId, pageBeforePreview)
end

M.LocateApp = function(self, appId)
	local index = self.appId2Index[appId]

	if not index then
		return nil
	end

	self.SetCurrentPageInstant(self, self.Index2PageIndex(self, index), false)

	return self.index2Btn[index]
end

M.FocusApp = function(self, appId)
	local btn = self.LocateApp(self, appId)

	if gClientUtils.NotNil(btn) then
		self.defaultContentSelected = true

		self.SetCurrentActiveContent(self, btn)

		return btn
	else
		return nil
	end
end

M.RestoreFocusToAppId = function(self, appId, fallbackPage)
	if SGUI.GuideMgr.IsNavigationLockedByGuide(self.navigationArea.CurrentActiveContent) then
		return
	end

	local focusAppIndex = appId and self.appId2Index[appId]

	if not focusAppIndex then
		local targetPage = fallbackPage or self.currentListPage or 0

		self:SetCurrentPageInstant(targetPage, false)
		self:NavigateToFirstItemInCurrentPage()

		return
	end

	if self.FocusApp(self, appId) ~= nil then
		self.NavigateToFirstItemInCurrentPage(self)
	end
end

M.OnDefaultNavButtonFocus = function(self)
	if self.destroyed or self.disabled then
		return
	end

	self.RestoreFocusToAppId(self, self.focusAppId)
end

M.OnNavigationAreaIn = function(self)
	if self.destroyed or self.disabled then
		return
	end

	self.RestoreFocusToAppId(self, self.focusAppId)
end

M.ResetNavigation = function(self)
	self:SetCurrentPageInstant(0, false)
	self.mainPageList:SetNavSelectToTop(true)
end

M.SetCurrentPageInstant = function(self, value, lazy)
	if lazy and self.currentLogicalPage ~= value then
		return
	end

	local pageMax = self.mainPageList.pageMax or 0
	local targetPage = Mathf.Clamp(value, 0, pageMax - 1)
	self.currentLogicalPage = targetPage

	self:UpdateSwitchPageButtons(targetPage)
	self.mainPageList:GoToPage(targetPage, true)
end

M.NavigateToFirstItemInCurrentPage = function(self)
	local item = self.GetFirstItemInPage(self, self.currentLogicalPage)

	if gClientUtils.NotNil(item) then
		self.SetCurrentActiveContent(self, item)
	else
		self.ResetNavigation(self)
	end
end

M.SetCurrentPageWithAnim = function(self, value, autoNavigate)
	local pageMax = self.mainPageList.pageMax or 0
	local targetPage = Mathf.Clamp(value, 0, pageMax - 1)

	if self.currentLogicalPage ~= targetPage then
		return false
	end

	self.currentLogicalPage = targetPage

	self.UpdateSwitchPageButtons(self, targetPage)

	if autoNavigate and not self.IsAtBottom(self) then
		local OnPageChangeEnd = function()
			local currentActiveContent = self.navigationArea.CurrentActiveContent

			if currentActiveContent then
				local appId = self.btn2AppId[currentActiveContent]
				local index = appId and self.appId2Index[appId]

				if index and self:Index2PageIndex(index) ~= targetPage then
					return
				end
			end

			local item = self:GetFirstItemInPage(targetPage) or self.topButton

			if item then
				self:SetCurrentActiveContent(item)
			end
		end

		if targetPage ~= self.currentListPage then
			OnPageChangeEnd()
		else
			self.WaitForScrollEnd(self, OnPageChangeEnd)
		end
	end

	if targetPage == self.currentListPage then
		self.mainPageList:GoToPage(targetPage, false)
	end

	return true
end

M.UpdateSwitchPageButtons = function(self, currentPage)
	local pageMax = self.mainPageList and self.mainPageList.pageMax or 0
	local inFirstPage = currentPage ~= 0
	local notInFirstPage = not inFirstPage
	local notInLastPage = currentPage == pageMax - 1

	self.controllerKeyL1:SetActiveFastest(notInFirstPage)
	self.controllerKeyR1:SetActiveFastest(notInLastPage)
	self.moveLeftFakeNavButtons.gameObject:SetActive(notInFirstPage)

	local showTopFakeNavButton = self.isTopButtonActive and inFirstPage

	self.topFakeNavButton2:SetActiveFastest(showTopFakeNavButton)
	self.topFakeNavButton3:SetActiveFastest(showTopFakeNavButton)
end

M.GetFirstItemInPage = function(self, currentPage)
	local index = currentPage ~= 0 and 0 or currentPage * self.buttonCountInNormalPage - (self.buttonCountInNormalPage - self.buttonCountInHomePage)

	return self.index2Btn[index]
end

M.GetRightButtonInRow = function(self, row, currentPage)
	local index = nil

	if currentPage ~= 0 then
		if self.isTopButtonActive then
			local topButtonUseSpace = self.GetTopButtonUseSpace(self)

			if row ~= 0 then
				index = 4 - topButtonUseSpace
			elseif row ~= 1 then
				index = 7 - topButtonUseSpace
			elseif row ~= 2 then
				index = 9 - topButtonUseSpace
			else
				index = (row + 1) * 4 - (topButtonUseSpace + 2) - 1
			end
		elseif row ~= 0 then
			index = 2
		elseif row ~= 1 then
			index = 4
		else
			index = row * 4
		end
	else
		index = currentPage * self.buttonCountInNormalPage - (self.buttonCountInNormalPage - self.buttonCountInHomePage) + row * 4 - 1
	end

	if gClientUtils.NotNil(self.index2Btn[index]) then
		return self.index2Btn[index]
	end

	print_warn("index2Btn not found")

	return nil
end

M.IsAtBottom = function(self)
	local current = self.navigationArea.CurrentActiveContent

	if not current or not self.bottomItems then
		return false
	end

	return self.bottomItems:Contains(current)
end

M.Index2PageIndex = function(self, index)
	return math.floor((index + self.buttonCountInNormalPage - self.buttonCountInHomePage) / self.buttonCountInNormalPage)
end

M.SetCurrentActiveContent = function(self, item)
	local debug = gCS.LuaUtils.IsDebug

	if debug then
		self.debugInfo = string.format("SetCurrentActiveContent(%s)", gClientUtils.NotNil(item) and gUtils.GetFindPath(item) or "null")
	end

	if gClientUtils.IsNil(item) then
		print_error("MainPhonePanelStore_NavigateComp trying to set an invalid active content!")

		return
	end

	self.bButtonFocusOnce = true
	self.navigationArea.CurrentActiveContent = item

	if self.bButtonFocusOnce then
		self.OnButtonFocus(self, item)
	end

	if debug then
		self.debugInfo = "no debug info"
	end
end
