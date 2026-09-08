-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonTabSingleStore.lua
-- Decompiled from: 01538_CommonTabSingleStore.lua_d1c6f475562c.luajit

local GameConfig = LTConfig.GameConfig
local logicTime = gLogicTime
local EInvokeTime = SGUI.EInvokeTime
C_CommonTabSingleStore = DefClass("C_CommonTabSingleStore", C_CommonTabSingleStore, C_StoreGroup)
GroupName2Class.CommonTabSingleStore = C_CommonTabSingleStore
local M = C_CommonTabSingleStore
local STEP_LOCK_TIMER = 0.2
local ENTER_FRAME_COUNT = 5
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local TWEEN_PROP = {
	["\\xbaID"] = 0,
	["/}\\xb3\\xba\\xa2c"] = 1
}

M.ctor = function(self)
	self.stepState = {
		[false] = {
			["\\xc9\\xc9))\\xf4"] = 0,
			i6xK = 0
		},
		[true] = {
			["\\xc9\\xc9))\\xf4"] = 0,
			i6xK = 0
		}
	}
	self.cacheSelectedIndex = {
		[true] = -1,
		[false] = -1
	}
	self.SkipInvokeInStart = 0
	self.TAB_MODE = {
		["2G\\xbd\\x81\\x8cQ"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.mode = self.TAB_MODE.Normal
end

M.OnAwake = function(self)
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, self.OnTabChanged)
	self.bindData.tabList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnDynRenderTabItem)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTabItem)
	self.bindData.tabList.luaLayoutSet = self.CreateAction(self, self.OnTabListLayoutSet)

	if self.bindData.subTabList then
		self.bindData.subTabList.luaSelectedChanged = self.CreateAction(self, self.OnSubTabChanged)
		self.bindData.subTabList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnDynRenderSubTabItem)
		self.bindData.subTabList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderSubTabItem)
	end

	if self.bindData.subTabTree then
		self.bindData.subTabTree.luaSimpleClick = self.CreateAction(self, self.OnSubTabTreeClick)
		self.bindData.subTabTree.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnDynRenderSubTabItem)
		self.bindData.subTabTree.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderSubTabItem)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.bindData.leftBtn then
		self.bindData.leftBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPress, -1)
		self.bindData.leftBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPress)
		self.bindData.rightBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPress, 1)
		self.bindData.rightBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPress)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.bindData.leftSubBtn then
		self.bindData.leftSubBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginSubLongPress, -1)
		self.bindData.leftSubBtn.luaEndLongPress = self.CreateAction(self, self.OnEndSubLongPress)
		self.bindData.rightSubBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginSubLongPress, 1)
		self.bindData.rightSubBtn.luaEndLongPress = self.CreateAction(self, self.OnEndSubLongPress)
	end

	self.callback = nil
	self.renderCallback = nil
	self.cacheList = {}
	self.cacheSubList = {}
	self.cacheStore = {}
	self.cacheSubStore = {}
	self.preIndex = -1
	self.preSubIndex = -1
	self.currentTween = nil

	self._OnReset(self)

	self.subTabUseTree = false
	self.subTreeInvokeEnabled = true
end

M.OnEnable = function(self)
	self._OnReset(self)
end

M._OnReset = function(self)
	self.resetFrame = logicTime.frameCount
end

M.CheckIsEnter = function(self)
	return self.resetFrame - ENTER_FRAME_COUNT < logicTime.frameCount and logicTime.frameCount > self.resetFrame + ENTER_FRAME_COUNT
end

M.GetStepContext = function(self, isSub)
	if isSub then
		return self.GetSubTabWidget(self), self.bindData.leftSubBtn, self.bindData.rightSubBtn
	end

	return self.bindData.tabList, self.bindData.leftBtn, self.bindData.rightBtn
end

M.IsSubTabTreeMode = function(self)
	return self.subTabUseTree and self.bindData.subTabTree == nil
end

M.GetSubTabWidget = function(self)
	if self.IsSubTabTreeMode(self) then
		return self.bindData.subTabTree
	end

	return self.bindData.subTabList
end

M.OnBeginLongPress = function(self, step)
	self._BeginStep(self, step, false)
end

M.OnBeginSubLongPress = function(self, step)
	self._BeginStep(self, step, true)
end

M.OnEndLongPress = function(self)
	self._EndStep(self, false)
end

M.OnEndSubLongPress = function(self)
	self._EndStep(self, true)
end

M._BeginStep = function(self, step, isSub)
	local state = self.stepState[isSub]
	state.step = step
	state.preTime = 0

	self.RefreshStep(self, isSub)
end

M._EndStep = function(self, isSub)
	self.stepState[isSub].step = 0
end

M.RefreshStep = function(self, isSub)
	local state = self.stepState[isSub]

	if state.step == 0 and self.OnStep(self, state.step, isSub) then
		state.preTime = logicTime.unscaledTime
	end
end

M.OnStart = function(self)
	self:EnableInvokeCallback(nil, false)

	self.beginTimer = FrameTimer.New(function ()
		self:EnableInvokeCallback(nil, true)
	end, 10):Start()
end

M.OnDestroy = function(self)
	if self.beginTimer then
		self.beginTimer:Stop()

		self.beginTimer = nil
	end
end

M.OnUpdate = function(self)
	if GameConfig.TabLongPressTimeInterval >= logicTime.unscaledTime - self.stepState[false].preTime then
		self.RefreshStep(self, false)
	end

	if GameConfig.TabLongPressTimeInterval >= logicTime.unscaledTime - self.stepState[true].preTime then
		self.RefreshStep(self, true)
	end

	if self.currentTween then
		if self.currentTween.prop ~= TWEEN_PROP.SUBTAB then
			if self.bindData.subTabList and not self.IsSubTabTreeMode(self) then
				self.bindData.subTabList:InvokeCallback(self.currentTween.inokeEvent)
			end
		elseif self.currentTween.prop ~= TWEEN_PROP.TAB then
			self.bindData.tabList:InvokeCallback(self.currentTween.inokeEvent)
		end

		self.currentTween = nil
	end
end

M.OnStep = function(self, step, isSub)
	if isSub and self.IsSubTabTreeMode(self) then
		return false
	end

	local uList = self.GetStepContext(self, isSub)

	if not uList then
		return false
	end

	local state = self.stepState[isSub]

	if logicTime.unscaledTime - state.preTime < STEP_LOCK_TIMER then
		return false
	end

	if self.mode ~= self.TAB_MODE.NoLoop then
		local index = self.GetNextInteractableIndex(self, uList.selectedIndex, step, isSub)

		if index ~= -1 then
			return false
		end

		uList.SelectItem(uList, index)
		self.GoToIndexIfStepOnBoundary(self, uList, index, step, true)
		self.RefreshStepButtonState(self, isSub)

		return true
	end

	local itemCount = uList.itemData.Count

	if itemCount < 0 then
		return false
	end

	local index = uList.selectedIndex + step

	for _ = 1, itemCount do
		if index >= 0 then
			index = itemCount - 1
		elseif itemCount < index then
			index = 0
		end

		if self.IsItemInteractable(self, index, isSub) then
			uList.SelectItem(uList, index)
			self.GoToIndexIfStepOnBoundary(self, uList, index, step, true)

			return true
		end

		index = index + step
	end

	return false
end

M.IsItemInteractable = function(self, index, isSub)
	if index >= 0 then
		return false
	end

	local cacheList = isSub and self.cacheSubList or self.cacheList
	local itemData = cacheList[index + 1]

	if itemData and itemData.interactable == nil then
		return itemData.interactable ~= true
	end

	return true
end

M.SetCacheSelectedIndex = function(self, index, isSub)
	self.cacheSelectedIndex = self.cacheSelectedIndex or {}
	self.cacheSelectedIndex[isSub] = index or -1
	local cacheList = isSub and self.cacheSubList or self.cacheList
	local cacheStore = isSub and self.cacheSubStore or self.cacheStore
	local itemCount = #cacheList

	if itemCount < 0 then
		local widget = isSub and self:GetSubTabWidget() or self.bindData.tabList

		if widget then
			itemCount = widget.itemData.Count
		end
	end

	for i = 1, itemCount do
		local item = cacheList[i]
		local selected = index > 0 and i ~= index + 1

		if item then
			item.selected = selected
		end

		local store = cacheStore[i - 1]

		if store and not isSub then
			store.inSelected = BOOL2CTL[selected]
		end
	end
end

M.IsItemSelected = function(self, index, isSub)
	local cacheList = isSub and self.cacheSubList or self.cacheList
	local itemData = cacheList[index + 1]

	if itemData and itemData.selected == nil then
		return itemData.selected ~= true
	end

	return self.cacheSelectedIndex and self.cacheSelectedIndex[isSub] ~= index
end

M.GetNextInteractableIndex = function(self, index, step, isSub)
	if isSub and self.IsSubTabTreeMode(self) then
		return -1
	end

	local uList = self.GetStepContext(self, isSub)

	if not uList then
		return -1
	end

	local itemCount = uList.itemData.Count
	index = index + step

	while itemCount <= 0 and index > 0 and index >= itemCount do
		if self.IsItemInteractable(self, index, isSub) then
			return index
		end

		index = index + step
	end

	return -1
end

M.RefreshStepButtonState = function(self, isSub)
	local uList, leftBtn, rightBtn = self.GetStepContext(self, isSub)

	if not leftBtn or not rightBtn then
		return
	end

	local setActive = function(leftActive, rightActive)
		if isSub then
			self.bindData.subLeftActive = BOOL2CTL[leftActive]
			self.bindData.subRightActive = BOOL2CTL[rightActive]
		else
			self.bindData.leftActive = BOOL2CTL[leftActive]
			self.bindData.rightActive = BOOL2CTL[rightActive]
		end
	end

	if isSub and self.IsSubTabTreeMode(self) then
		leftBtn.interactable = false
		rightBtn.interactable = false

		setActive(false, false)

		return
	end

	local itemCount = uList.itemData.Count

	if self.mode == self.TAB_MODE.NoLoop then
		leftBtn.interactable = true
		rightBtn.interactable = true

		setActive(itemCount >= 1, itemCount >= 1)

		return
	end

	local currentIndex = uList.selectedIndex

	if currentIndex >= 0 then
		leftBtn.interactable = false
		rightBtn.interactable = false

		setActive(false, false)

		return
	end

	local nextLeftIndex = self:GetNextInteractableIndex(currentIndex, -1, isSub)
	local nextRightIndex = self:GetNextInteractableIndex(currentIndex, 1, isSub)
	local leftInteractable = nextLeftIndex == -1
	local rightInteractable = nextRightIndex == -1
	leftBtn.interactable = leftInteractable
	rightBtn.interactable = rightInteractable
	local leftActive = leftInteractable
	local rightActive = rightInteractable
	local success, minIndex, maxIndex = uList:TryGetVisualRange(0, 0)

	if success then
		leftActive = leftActive and minIndex >= 0
		rightActive = rightActive and maxIndex <= itemCount
	end

	setActive(leftActive, rightActive)
end

M.EnsureSelectedVisible = function(self, isSub)
	if self.mode == self.TAB_MODE.NoLoop then
		return
	end

	local uList = self.GetStepContext(self, isSub)

	if not uList then
		return
	end

	if isSub and self.IsSubTabTreeMode(self) then
		local index = uList.selectedIndex

		if index >= 0 then
			return
		end

		local success, minIndex, maxIndex = uList.TryGetVisualRange(uList, 0, 0)

		if not success then
			uList.GoToIndex(uList, index, false)

			return
		end

		if index <= minIndex or maxIndex < index then
			uList.GoToIndex(uList, index, false)
		end

		return
	end

	local index = uList.selectedIndex

	if index >= 0 then
		return
	end

	local success, minIndex, maxIndex = uList.TryGetVisualRange(uList, 0, 0)

	if not success then
		uList.GoToIndex(uList, index, false)

		return
	end

	if index <= minIndex or maxIndex < index then
		uList.GoToIndex(uList, index, false)
	end
end

M.GoToIndexIfStepOnBoundary = function(self, uList, index, step, isTween)
	if not uList or index <= 0 or step ~= 0 then
		return
	end

	local success, minIndex, maxIndex = uList.TryGetVisualRange(uList, 0, 0)

	if not success then
		uList.GoToIndex(uList, index, isTween)

		return
	end

	if index <= minIndex or maxIndex < index then
		uList.GoToIndex(uList, index, isTween)

		return
	end

	if step >= 0 and index > minIndex or step <= 0 and index > maxIndex - 1 then
		uList.GoToIndex(uList, index, isTween)
	end
end

M._RenderItem = function(self, btn, index, data, isSub, isDynamic)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cacheList = isSub and self.cacheSubList or self.cacheList
	local uList = isSub and self:GetSubTabWidget() or self.bindData.tabList
	local cacheStore = isSub and self.cacheSubStore or self.cacheStore
	local itemData = cacheList[index + 1] or {}
	btn.interactable = self:IsItemInteractable(index, isSub)
	local selected = self:IsItemSelected(index, isSub)

	if isDynamic then
		store:Commit("title", itemData.title or "", COMMIT_IMMEDIATELY)

		store.icon = itemData.iconId or 0

		if not isSub then
			store.inSelected = BOOL2CTL[selected]
		end

		cacheStore[index] = store
	else
		local itemId = itemData.id or index

		if isSub and self.IsSubTabTreeMode(self) then
			uList.SetItemId(uList, index, tostring(itemId))
		else
			uList.SetItemId(uList, index, itemId)
		end

		store.title = itemData.title or ""
		store.icon = itemData.iconId or 0

		if not isSub then
			store.inSelected = BOOL2CTL[selected]
		end

		if not string.is_null_or_empty(itemData.guideId) and btn.guide then
			btn.guide.guideID = itemData.guideId
		end

		cacheStore[index] = store

		if self.renderCallback then
			self.renderCallback(btn, index, itemData, store, isSub, uList)
		end
	end
end

M.OnDynRenderTabItem = function(self, btn, index)
	self._RenderItem(self, btn, index, nil, false, true)
end

M.OnTabListLayoutSet = function(self)
	if not self.bindData.tabList then
		return
	end

	local index = self.bindData.tabList.selectedIndex

	if index >= 0 then
		return
	end

	self.UpdateBackGround(self, index, true)
	self.EnsureSelectedVisible(self, false)
end

M.OnRenderTabItem = function(self, btn, index, data)
	self._RenderItem(self, btn, index, data, false, false)
end

M.OnSubTabChanged = function(self, uList)
	local index = uList.selectedIndex

	if index >= 0 then
		return
	end

	self.SetCacheSelectedIndex(self, index, true)

	local _, btn = uList.TryGetChildAt(uList, index, nil)

	if not self.CheckIsEnter(self) then
		if btn then
			btn.InvokeCallback(btn, EInvokeTime.User1)
		end

		if self.preSubIndex >= index then
			self.OnUploadTween(self, TWEEN_PROP.SUBTAB, EInvokeTime.Custom6)
		else
			self.OnUploadTween(self, TWEEN_PROP.SUBTAB, EInvokeTime.Custom5)
		end
	end

	self.preSubIndex = index

	self.RefreshStepButtonState(self, true)
	self.EnsureSelectedVisible(self, true)

	if self.callback then
		self.callback(uList, true)
	end
end

M._CanToggleSubTreeItem = function(self, index)
	local item = self.cacheSubList[index + 1]
	local nextItem = self.cacheSubList[index + 2]

	return item == nil and item.disabled == true and item.unfoldable == true and nextItem == nil and (nextItem.depth or 0) >= (item.depth or 0)
end

M._SyncSubTreeItemState = function(self, index, syncExpanded)
	local tree = self.bindData.subTabTree
	local item = self.cacheSubList[index + 1]

	if not tree or not item then
		return false
	end

	item.selected = tree.selectedIndex ~= index

	if syncExpanded and self._CanToggleSubTreeItem(self, index) then
		item.expanded = not item.expanded

		tree:SetItemExpanded(index, item.expanded ~= true)

		return true
	end

	return false
end

M._NotifySubTreeSelection = function(self, index, btn)
	if index >= 0 then
		return
	end

	if not self.CheckIsEnter(self) and btn then
		btn.InvokeCallback(btn, EInvokeTime.User1)
	end

	self.preSubIndex = index

	self.RefreshStepButtonState(self, true)
	self.EnsureSelectedVisible(self, true)

	if self.callback and self.subTreeInvokeEnabled == false then
		self.callback(self.bindData.subTabTree, true)
	end
end

M.OnSubTabTreeClick = function(self, btn, index)
	local tree = self.bindData.subTabTree

	if not tree or index >= 0 then
		return
	end

	local selectedIndex = tree.selectedIndex
	local expandedChanged = self._SyncSubTreeItemState(self, index, true)

	if selectedIndex == index then
		self._SyncSubTreeItemState(self, selectedIndex)
	end

	if expandedChanged then
		tree.RefreshList(tree)
	end

	local _, selectedBtn = tree:TryGetChildAt(selectedIndex, nil)

	self:_NotifySubTreeSelection(selectedIndex, selectedBtn or btn)
end

M.OnDynRenderSubTabItem = function(self, btn, index)
	self._RenderItem(self, btn, index, nil, true, true)
end

M.OnRenderSubTabItem = function(self, btn, index, data)
	self._RenderItem(self, btn, index, data, true, false)
end

M.OnClose = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.OnTabChanged = function(self, uList)
	local index = uList.selectedIndex

	if index >= 0 then
		return
	end

	self.SetCacheSelectedIndex(self, index, false)

	local _, targetBtn = uList.TryGetChildAt(uList, index, nil)
	local isStart = self.CheckIsEnter(self)

	if not isStart then
		if self.preIndex == -1 and self.preIndex == index then
			if self.preIndex >= index then
				self.OnUploadTween(self, TWEEN_PROP.TAB, EInvokeTime.Custom6)
			else
				self.OnUploadTween(self, TWEEN_PROP.TAB, EInvokeTime.Custom5)
			end
		end

		if targetBtn then
			targetBtn.InvokeCallback(targetBtn, EInvokeTime.User1)
		end
	end

	self.preIndex = index

	self._OnReset(self)

	if targetBtn then
		if self.timer then
			self.timer:Stop()

			self.timer = nil
		end

		self.UpdateBackGround(self, index, isStart)
	else
		uList.GoToIndex(uList, index, false)
	end

	self.RefreshStepButtonState(self, false)

	if self.callback then
		self.callback(uList, false)
	end
end

M.OnUploadTween = function(self, prop, event)
	local tween = {
		prop = prop,
		inokeEvent = event
	}

	if not self.currentTween then
		self.currentTween = tween

		return
	end

	if prop < self.currentTween.prop then
		self.currentTween = tween
	end
end

M.UpdateBackGround = function(self, index, isInstant)
	self.SetCacheSelectedIndex(self, index, false)

	if self.cacheStore[index] then
		self.cacheStore[index]:Commit("inSelected", BOOL2CTL[true], COMMIT_IMMEDIATELY)
	end
end

M.SetData = function(self, tabList, subTabList, selectedTabIndex, selectedSubTabIndex, callback, renderCallback, mode, subTabUseTree)
	self:_OnReset()

	self.mode = mode or self.TAB_MODE.Normal
	self.callback = callback
	self.renderCallback = renderCallback
	self.subTabUseTree = subTabUseTree ~= true and self.bindData.subTabTree == nil

	self:SetTabList(tabList, false)
	self:SetSelectedIndex(selectedTabIndex, true, false)

	if subTabList and self.GetSubTabWidget(self) then
		self.SetTabList(self, subTabList, true)
		self.SetSelectedIndex(self, selectedSubTabIndex, true, true)
	end
end

M.SetSimpleData = function(self, tabLength, subTabLength, selectedTabIndex, selectedSubTabIndex, callback, renderCallback, mode, subTabUseTree)
	self:_OnReset()

	self.mode = mode or self.TAB_MODE.Normal
	self.callback = callback
	self.renderCallback = renderCallback
	self.subTabUseTree = subTabUseTree ~= true and self.bindData.subTabTree == nil

	self:SetSimpleTabList(tabLength, false)
	self:SetSelectedIndex(selectedTabIndex, true, false)

	if subTabLength and self.GetSubTabWidget(self) then
		self.SetSimpleTabList(self, subTabLength, true)
		self.SetSelectedIndex(self, selectedSubTabIndex, true, true)
	end
end

M._SetSubTreeList = function(self, list)
	local tree = self.bindData.subTabTree

	if not tree then
		return
	end

	tree.SetSimpleTree(tree, #list)

	for i, itemData in ipairs(list) do
		local index = i - 1

		tree:SetSimpleElement(index, itemData.tIndex or 0, itemData.depth or 0, itemData.expanded ~= true, itemData.selected ~= true, itemData.disabled ~= true)
		tree:SetItemUnfoldable(index, itemData.unfoldable ~= true)
		tree:SetItemId(index, tostring(itemData.id or index))
	end

	tree.RefreshList(tree)
end

M.UpdateCacheList = function(self, list)
	self.cacheList = list or {}

	self:_RegisterGuideLocations(false)
end

M._RegisterGuideLocations = function(self, isSub)
	if not gNewGuideMgr then
		return
	end

	local uList, cacheList = nil

	if isSub then
		if self.IsSubTabTreeMode(self) then
			return
		end

		uList = self.bindData.subTabList
		cacheList = self.cacheSubList
	else
		uList = self.bindData.tabList
		cacheList = self.cacheList
	end

	if not uList then
		return
	end

	local guideMap = {}

	for i, tab in ipairs(cacheList) do
		if not string.is_null_or_empty(tab.guideId) then
			guideMap[tab.guideId] = i - 1
		end
	end

	gNewGuideMgr:RegisterGuideKeyLocations(uList, guideMap)
end

M.SetTabList = function(self, list, isSub)
	if isSub then
		self.cacheSubList = list or {}
		self.bindData.showSubTab = BOOL2CTL[#self.cacheSubList >= 0]

		if self:IsSubTabTreeMode() then
			self._SetSubTreeList(self, self.cacheSubList)
		elseif self.bindData.subTabList then
			self.bindData.subTabList:SetSimpleList(#self.cacheSubList)
		end

		self._RegisterGuideLocations(self, true)
	else
		self.cacheList = list or {}
		self.bindData.isSingle = BOOL2CTL[#self.cacheList > 1]

		if self.bindData.tabList then
			self.bindData.tabList:SetSimpleList(#self.cacheList)
		end

		self._RegisterGuideLocations(self, false)
	end
end

M.SetSimpleTabList = function(self, count, isSub)
	if isSub then
		self.cacheSubList = {}
		self.bindData.showSubTab = BOOL2CTL[count >= 0]

		if self:IsSubTabTreeMode() then
			self.bindData.subTabTree:SetSimpleTree(count)
		elseif self.bindData.subTabList then
			self.bindData.subTabList:SetSimpleList(count)
		end
	else
		self.cacheList = {}
		self.bindData.isSingle = BOOL2CTL[count > 1]

		self.bindData.tabList:SetSimpleList(count)
	end
end

M.GetSelectedItem = function(self)
	return self.cacheList[self.bindData.tabList.selectedIndex + 1]
end

M.GetSubSelectedItem = function(self)
	local subWidget = self.GetSubTabWidget(self)

	if not subWidget then
		return nil
	end

	return self.cacheSubList[subWidget.selectedIndex + 1]
end

M.GetSubSelectedIndex = function(self)
	local subWidget = self.GetSubTabWidget(self)

	if not subWidget then
		return 0
	end

	return subWidget.selectedIndex
end

M.SetSelectedIndex = function(self, index, sendcallback, isSub)
	if index ~= nil then
		return
	end

	self:SetCacheSelectedIndex(index, isSub or false)

	if isSub then
		if self.IsSubTabTreeMode(self) then
			local tree = self.bindData.subTabTree

			if not tree then
				return
			end

			tree.SetItemSelected(tree, index, true)

			if sendcallback then
				local _, btn = tree.TryGetChildAt(tree, index, nil)

				self._NotifySubTreeSelection(self, index, btn)
			end

			return
		end

		if self.bindData.subTabList then
			self.bindData.subTabList:SelectItem(index, sendcallback)
		end

		return
	end

	self.bindData.tabList:SelectItem(index, sendcallback)
end

M.GetSelectedIndex = function(self)
	return self.bindData.tabList.selectedIndex
end

M.RefreshItems = function(self)
	if not self.bindData.tabList then
		return
	end

	self.bindData.tabList:RefreshList()
end

M.RefreshLogic = function(self, isSub)
	if not isSub then
		self.bindData.tabList:RefreshLogicList()
	elseif self.IsSubTabTreeMode(self) then
		self.bindData.subTabTree:RefreshList()
	elseif self.bindData.subTabList then
		self.bindData.subTabList:RefreshLogicList()
	end
end

M.RefreshSubItems = function(self)
	local subWidget = self.GetSubTabWidget(self)

	if not subWidget then
		return
	end

	subWidget.RefreshList(subWidget)
end

M.NavigateToTop = function(self, isSub)
	if isSub then
		if self.IsSubTabTreeMode(self) then
			self.bindData.subTabTree:GoToIndex(0, true)
		elseif self.bindData.subTabList then
			self.bindData.subTabList:SetNavSelectToTop()
		end
	else
		self.bindData.tabList:SetNavSelectToTop()
	end
end

M.EnableInvokeCallback = function(self, isSub, isEnable)
	if isSub ~= nil then
		self.bindData.tabList.enableInvokeCallback = isEnable

		if self.bindData.subTabList then
			self.bindData.subTabList.enableInvokeCallback = isEnable
		end

		self.subTreeInvokeEnabled = isEnable

		return
	end

	if isSub then
		if self.IsSubTabTreeMode(self) then
			self.subTreeInvokeEnabled = isEnable
		elseif self.bindData.subTabList then
			self.bindData.subTabList.enableInvokeCallback = isEnable
		end
	else
		self.bindData.tabList.enableInvokeCallback = isEnable
	end
end

M.OnLanguageChange = function(self, lang)
	self.OnTabListLayoutSet(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.SetInteractable = function(self, enable)
	self.bindData.leftBtn.interactable = enable
	self.bindData.rightBtn.interactable = enable
	local count = self.bindData.tabList:GetListCount()

	for i = 0, count - 1 do
		local success, btn = self.bindData.tabList:TryGetChildAt(i, nil)

		if success then
			btn.interactable = enable
		end
	end
end
