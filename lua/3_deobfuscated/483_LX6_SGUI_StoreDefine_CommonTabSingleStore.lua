local GameConfig = LTConfig.GameConfig
local logicTime = gLogicTime
local AnimMgr = SGUI.AnimMgr
local EInvokeTime = SGUI.EInvokeTime
C_CommonTabSingleStore = DefClass("C_CommonTabSingleStore", C_CommonTabSingleStore, C_StoreGroup)
GroupName2Class.CommonTabSingleStore = C_CommonTabSingleStore
local M = C_CommonTabSingleStore
local STEP_LOCK_TIMER = 0.2
local TOTAL_ANI_TIME = 0.25
local ENTER_FRAME_COUNT = 5
local TAB_ANI_NAME = "TabAni"
local TAB_ANI_SCALE_NAME = "TabAniScale"
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local TWEEN_PROP = {
	TAB = 0,
	SUBTAB = 1
}

function M:ctor()
	self:OnEndLongPress()

	self.preTime = 0
	self.SkipInvokeInStart = 0
end

function M:OnAwake()
	self.bindData.tabList.luaSelectedChanged = self:CreateAction(self.OnTabChanged)
	self.bindData.tabList.luaSimpleDynamicRenderItem = self:CreateAction(self.OnDynRenderTabItem)
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTabItem)
	self.bindData.tabList.luaLayoutSet = self:CreateAction(self.OnTabListLayoutSet)

	if self.bindData.subTabList then
		self.bindData.subTabList.luaSelectedChanged = self:CreateAction(self.OnSubTabChanged)
		self.bindData.subTabList.luaSimpleRenderItem = self:CreateAction(self.OnRenderSubTabItem)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() and self.bindData.leftBtn then
		self.bindData.leftBtn.luaBeginLongPress = self:CreateActionWithArgs(self.OnBeginLongPress, -1)
		self.bindData.leftBtn.luaEndLongPress = self:CreateAction(self.OnEndLongPress)
		self.bindData.rightBtn.luaBeginLongPress = self:CreateActionWithArgs(self.OnBeginLongPress, 1)
		self.bindData.rightBtn.luaEndLongPress = self:CreateAction(self.OnEndLongPress)
	end

	self.callback = nil
	self.renderCallback = nil
	self.cacheList = {}
	self.cacheSubList = {}
	self.cacheStore = {}
	self.preIndex = -1
	self.preSubIndex = -1
	self.currentTween = nil

	self:_OnReset()

	self.uploadCache = {}
end

function M:OnEnable()
	self:_OnReset()
end

function M:_OnReset()
	self.resetFrame = logicTime.frameCount
end

function M:CheckIsEnter()
	return self.resetFrame - ENTER_FRAME_COUNT <= logicTime.frameCount and logicTime.frameCount <= self.resetFrame + ENTER_FRAME_COUNT
end

function M:OnBeginLongPress(step)
	self.step = step
	self.preTime = 0

	self:RefreshStep()
end

function M:OnEndLongPress()
	self.step = 0
end

function M:RefreshStep()
	if self.step ~= 0 and self:OnStep(self.step) then
		self.preTime = logicTime.unscaledTime
	end
end

function M:OnStart()
	self:EnableInvokeCallback(nil, false)

	self.beginTimer = FrameTimer.New(function ()
		self:EnableInvokeCallback(nil, true)
	end, 10):Start()
end

function M:OnDestroy()
	if self.beginTimer then
		self.beginTimer:Stop()

		self.beginTimer = nil
	end
end

function M:OnUpdate()
	if GameConfig.TabLongPressTimeInterval < logicTime.unscaledTime - self.preTime then
		self:RefreshStep()
	end

	if not table.isNilOrEmpty(self.uploadCache) then
		for k, v in pairs(self.uploadCache) do
			local flag, targetBtn = self.bindData.tabList:TryGetChildAt(k, nil)

			if flag then
				local isInstant = v.isInstant
				local rect = targetBtn.rectTransform.rect
				local width = rect.width
				local anchor = targetBtn.anchoredPosition

				self.bindData.sTabBg:SetSizeX(width)
				self.cacheStore[k]:Commit("inSelected", BOOL2CTL[true], COMMIT_IMMEDIATELY)

				self.bindData.sTabBg.anchoredPosition = anchor

				if not isInstant then
					self.bindData.sTabBg.renderOpacity = 0

					AnimMgr.Kill(self.bindData.sTabBg.rectTransform, TAB_ANI_NAME)
					AnimMgr.DoAlpha(self.bindData.sTabBg, TAB_ANI_NAME, 1, TOTAL_ANI_TIME, 0, DG.Tweening.Ease.OutCubic)
				end
			end
		end

		self.uploadCache = {}
	end

	if self.currentTween then
		if self.currentTween.prop == TWEEN_PROP.SUBTAB then
			self.bindData.subTabList:InvokeCallback(self.currentTween.inokeEvent)
		elseif self.currentTween.prop == TWEEN_PROP.TAB then
			self.bindData.tabList:InvokeCallback(self.currentTween.inokeEvent)
		end

		self.currentTween = nil
	end
end

function M:OnStep(step)
	if logicTime.unscaledTime - self.preTime <= STEP_LOCK_TIMER then
		return false
	end

	local index = self.bindData.tabList.selectedIndex + step
	local itemCount = self.bindData.tabList.itemData.Count

	if index < 0 then
		index = itemCount - 1
	elseif itemCount <= index then
		index = 0
	end

	self.bindData.tabList:SelectItem(index)

	return true
end

function M:OnDynRenderTabItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.cacheList[index + 1] or {}
	store.title = data.title or ""
	store.icon = data.iconId or 0
	self.cacheStore[index] = store
end

function M:OnTabListLayoutSet()
	local index = self.bindData.tabList.selectedIndex

	if index < 0 then
		return
	end

	self:UpdateBackGround(index, true)
end

function M:OnRenderTabItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.cacheList[index + 1] or {}

	self.bindData.tabList:SetItemId(index, data.id or index)

	store.title = data.title or ""
	store.icon = data.iconId or 0

	if not string.is_null_or_empty(data.guideId) then
		btn.guide.guideID = data.guideId
	end

	self.cacheStore[index] = store

	if self.renderCallback then
		self.renderCallback(btn, index, data, store, false, self.bindData.tabList)
	end
end

function M:OnSubTabChanged(uList)
	local index = uList.selectedIndex

	if index < 0 then
		return
	end

	local _, btn = uList:TryGetChildAt(index, nil)

	if not self:CheckIsEnter() then
		if btn then
			btn:InvokeCallback(EInvokeTime.User1)
		end

		if self.preSubIndex < index then
			self:OnUploadTween(TWEEN_PROP.SUBTAB, EInvokeTime.Custom6)
		else
			self:OnUploadTween(TWEEN_PROP.SUBTAB, EInvokeTime.Custom5)
		end
	end

	self.preSubIndex = index

	if self.callback then
		self.callback(uList, true)
	end
end

function M:OnRenderSubTabItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.cacheSubList[index + 1] or {}

	self.bindData.subTabList:SetItemId(index, data.id or index)

	store.title = data.title or ""
	store.icon = data.iconId or 0

	if self.renderCallback then
		self.renderCallback(btn, index, data, store, true, self.bindData.subTabList)
	end
end

function M:OnClose()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function M:OnTabChanged(uList)
	local index = uList.selectedIndex

	if index < 0 then
		return
	end

	local _, targetBtn = uList:TryGetChildAt(index, nil)
	local isStart = self:CheckIsEnter()

	if not isStart then
		if self.preIndex ~= -1 and self.preIndex ~= index then
			if self.preIndex < index then
				self:OnUploadTween(TWEEN_PROP.TAB, EInvokeTime.Custom6)
			else
				self:OnUploadTween(TWEEN_PROP.TAB, EInvokeTime.Custom5)
			end
		end

		if targetBtn then
			targetBtn:InvokeCallback(EInvokeTime.User1)
		end
	end

	self.preIndex = index

	self:_OnReset()

	if targetBtn and self.bindData.sTabBg then
		if self.timer then
			self.timer:Stop()

			self.timer = nil
		end

		for i = 0, #self.cacheStore do
			if self.cacheStore[i] then
				self.cacheStore[i].inSelected = BOOL2CTL[false]
			end
		end

		self:UpdateBackGround(index, isStart)
	end

	if self.callback then
		self.callback(uList, false)
	end
end

function M:OnUploadTween(prop, event)
	local tween = {
		prop = prop,
		inokeEvent = event
	}

	if not self.currentTween then
		self.currentTween = tween

		return
	end

	if prop <= self.currentTween.prop then
		self.currentTween = tween
	end
end

function M:UpdateBackGround(index, isInstant)
	if not self.bindData.sTabBg then
		if self.cacheStore[index] then
			self.cacheStore[index]:Commit("inSelected", BOOL2CTL[true], COMMIT_IMMEDIATELY)
		end

		return
	end

	self.uploadCache[index] = {
		isInstant = isInstant
	}
end

function M:SetData(tabList, subTabList, selectedTabIndex, selectedSubTabIndex, callback, renderCallback)
	self:_OnReset()

	self.callback = callback
	self.renderCallback = renderCallback

	self:SetTabList(tabList, false)
	self:SetSelectedIndex(selectedTabIndex, true, false)

	if subTabList and self.bindData.subTabList then
		self:SetTabList(subTabList, true)
		self:SetSelectedIndex(selectedSubTabIndex, true, true)
	end
end

function M:SetSimpleData(tabLength, subTabLength, selectedTabIndex, selectedSubTabIndex, callback, renderCallback)
	self:_OnReset()

	self.callback = callback
	self.renderCallback = renderCallback

	self:SetSimpleTabList(tabLength, false)
	self:SetSelectedIndex(selectedTabIndex, true, false)

	if subTabLength and self.bindData.subTabList then
		self:SetSimpleTabList(subTabLength, true)
		self:SetSelectedIndex(selectedSubTabIndex, true, true)
	end
end

function M:SetTabList(list, isSub)
	if isSub then
		self.cacheSubList = list

		self.bindData.subTabList:SetSimpleList(#list)
	else
		self.cacheList = list
		self.bindData.isSingle = BOOL2CTL[#list <= 1]

		self.bindData.tabList:SetSimpleList(#list)
	end
end

function M:SetSimpleTabList(count, isSub)
	if isSub then
		self.cacheSubList = {}

		self.bindData.subTabList:SetSimpleList(count)
	else
		self.cacheList = {}
		self.bindData.isSingle = BOOL2CTL[count <= 1]

		self.bindData.tabList:SetSimpleList(count)
	end
end

function M:GetSelectedItem()
	return self.cacheList[self.bindData.tabList.selectedIndex + 1]
end

function M:GetSubSelectedItem()
	if not self.bindData.subTabList then
		return nil
	end

	return self.cacheSubList[self.bindData.subTabList.selectedIndex + 1]
end

function M:GetSubSelectedIndex()
	if not self.bindData.subTabList then
		return 0
	end

	return self.bindData.subTabList.selectedIndex
end

function M:SetSelectedIndex(index, sendcallback, isSub)
	if index == nil then
		return
	end

	if isSub then
		self.bindData.subTabList:SelectItem(index, sendcallback)

		return
	end

	self.bindData.tabList:SelectItem(index, sendcallback)
end

function M:GetSelectedIndex()
	return self.bindData.tabList.selectedIndex
end

function M:ReSelectedIndex(isSub)
	if isSub then
		self:OnSubTabChanged(self.bindData.subTabList)
	else
		self:OnTabChanged(self.bindData.tabList)
	end
end

function M:RefreshItems()
	self.bindData.tabList:RefreshList()
end

function M:RefreshLogic(isSub)
	if not isSub then
		self.bindData.tabList:RefreshLogicList()
	else
		self.bindData.subTabList:RefreshLogicList()
	end
end

function M:RefreshSubItems()
	self.bindData.subTabList:RefreshList()
end

function M:NavigateToTop(isSub)
	if isSub then
		self.bindData.subTabList:SetNavSelectToTop()
	else
		self.bindData.tabList:SetNavSelectToTop()
	end
end

function M:EnableInvokeCallback(isSub, isEnable)
	if isSub == nil then
		self.bindData.tabList.enableInvokeCallback = isEnable

		if self.bindData.subTabList then
			self.bindData.subTabList.enableInvokeCallback = isEnable
		end

		return
	end

	if isSub then
		self.bindData.subTabList.enableInvokeCallback = isEnable
	else
		self.bindData.tabList.enableInvokeCallback = isEnable
	end
end

function M:SetSkipInvokeInStart(time)
	self.SkipInvokeInStart = time
end

function M:OnLanguageChange(lang)
	self:OnTabListLayoutSet()
end

function M:OnActiveDeviceChange(device)
	return
end
