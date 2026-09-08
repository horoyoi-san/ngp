-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterSubStore.lua
-- Decompiled from: 01801_HotCenterSubStore.lua_0d742b4ba59b.luajit

C_HotCenterSubStore = DefClass("C_HotCenterSubStore", C_HotCenterSubStore, C_StoreGroup)
GroupName2Class.HotCenterSubStore = C_HotCenterSubStore
local M = C_HotCenterSubStore
local InspireHubGamePlayTypeConfig = LTConfig.InspireHubGamePlayTypeConfig
local InspireHubConfig = LTConfig.InspireHubConfig
local STANDALONE_LIST_TITLE_TINDEX = 2
local MAIN_TAB_CHANGE_ANIM_NAME = "S_vx_HotCenterHome_SubJobTemplate_Change01_2"
local MAIN_TAB_OPEN_ANIM_NAME = "S_vx_HotCenterHome_SubJobTemplate_Open"

local SetText = function(widget, text)
	if gClientUtils.NotNil(widget) then
		widget.text = text or ""
	end
end

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.mainTabData = nil
	self.subTabData = nil
	self.listData = nil
	self.curSelectMainType = nil
	self.curSelectStandaloneSubType = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.showSubCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showSubCtrlEnum = nil
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
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
	if self.subType ~= gClientConst.HotCenterSubType.Main then
		self.CloseStandaloneSubPanel(self)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetListTIndex")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnSimpleClickList")
	self.bindData.list.luaLayoutSet = self.CreateAction(self, "OnListLayoutSet")

	if self.bindData.backBtn then
		self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	end

	if self.bindData.subTab then
		self.bindData.subTab.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSubTabItem")
		self.bindData.subTab.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderSubTabItem")
		self.bindData.subTab.luaSelectedChanged = self.CreateAction(self, "OnSubTabSelectedChanged")
	end

	if self.bindData.subTabLeftBtn then
		self.bindData.subTabLeftBtn.luaClick = self.CreateAction(self, "OnSubTabLeftBtnClick")
	end

	if self.bindData.subTabLeftOutBtn then
		self.bindData.subTabLeftOutBtn.luaClick = self.CreateAction(self, "OnSubTabLeftBtnClick")
	end

	if self.bindData.subTabRightBtn then
		self.bindData.subTabRightBtn.luaClick = self.CreateAction(self, "OnSubTabRightBtnClick")
	end

	if self.bindData.subTabRightOutBtn then
		self.bindData.subTabRightOutBtn.luaClick = self.CreateAction(self, "OnSubTabRightBtnClick")
	end

	if self.bindData.mainTabLeftBtn then
		self.bindData.mainTabLeftBtn.luaClick = self.CreateAction(self, "OnMainTabLeftBtnClick")
	end

	if self.bindData.mainTabRightBtn then
		self.bindData.mainTabRightBtn.luaClick = self.CreateAction(self, "OnMainTabRightBtnClick")
	end
end

M.OnSimpleRenderSubTabItem = function(self, btn, index)
	if self.subType ~= gClientConst.HotCenterSubType.Main then
		self.OnRenderStandaloneSubTabItem(self, btn, index)
	end
end

M.OnSubTabSelectedChanged = function(self, list)
	if self.subType ~= gClientConst.HotCenterSubType.Main then
		self.OnMainSubTabSelectedChanged(self, list)
	end
end

M.OnGetListTIndex = function(self, index)
	if self.subType ~= gClientConst.HotCenterSubType.Main then
		return self.OnGetStandaloneListTIndex(self, index)
	end

	return 0
end

M.OnListLayoutSet = function(self)
	if not self.pendingNavToTop then
		return
	end

	self.pendingNavToTop = false

	if self.listData and #self.listData <= 0 then
		self.bindData.list:SetNavSelectToTop()
	end
end

M.OnSimpleRenderListItem = function(self, btn, index)
	if self.subType ~= gClientConst.HotCenterSubType.Main then
		self.OnRenderStandaloneListItem(self, btn, index)
	end
end

M.OnSimpleClickList = function(self, btn, index)
	if self.subType ~= gClientConst.HotCenterSubType.Main then
		self.OnClickStandaloneListItem(self, index)
	end
end

M.OnSubTabLeftBtnClick = function(self)
	local selectIndex = self.bindData.subTab.selectedIndex
	selectIndex = selectIndex - 1

	if selectIndex > 0 then
		self.bindData.subTab:SelectItem(selectIndex)
	end
end

M.OnSubTabRightBtnClick = function(self)
	local selectIndex = self.bindData.subTab.selectedIndex
	selectIndex = selectIndex + 1

	if selectIndex >= #self.subTabData then
		self.bindData.subTab:SelectItem(selectIndex)
	end
end

M.OnMainTabLeftBtnClick = function(self)
	self.SelectMainTabByIndex(self, 0)
end

M.OnMainTabRightBtnClick = function(self)
	self.SelectMainTabByIndex(self, 1)
end

M.SelectMainTabByIndex = function(self, arrayIndex)
	if table.isNilOrEmpty(self.mainTabData) then
		return
	end

	if not self.mainTabData[arrayIndex + 1] then
		return
	end

	if self.bindData.mainTab.selectedIndex ~= arrayIndex then
		return
	end

	self.bindData.mainTab:SelectItem(arrayIndex)
end

M.PlayMainTabChangeAnim = function(self)
	if not self.rootGo then
		return
	end

	local anim = self.rootGo:GetComponent("Animation")

	if anim then
		gCS.LuaUtils.PlayAnimationByName(anim, MAIN_TAB_CHANGE_ANIM_NAME)
	end
end

M.PlayMainTabOpenAnim = function(self)
	if not self.rootGo then
		return
	end

	local anim = self.rootGo:GetComponent("Animation")

	if anim then
		gCS.LuaUtils.PlayAnimationByName(anim, MAIN_TAB_OPEN_ANIM_NAME)
	end
end

M.DisableCommonTabSingleStepBtns = function(self)
	if self.bindData.mainTabLeftBtn then
		self.bindData.mainTabLeftBtn.luaBeginLongPress = nil
		self.bindData.mainTabLeftBtn.luaEndLongPress = nil
	end

	if self.bindData.mainTabRightBtn then
		self.bindData.mainTabRightBtn.luaBeginLongPress = nil
		self.bindData.mainTabRightBtn.luaEndLongPress = nil
	end
end

M.OnBackBtnClick = function(self)
	local targetMainType = gClientConst.HotCenterType.Main

	if self.subType ~= gClientConst.HotCenterSubType.OnlineSub or self.subType ~= gClientConst.HotCenterSubType.OnlineDetail then
		targetMainType = gClientConst.HotCenterType.Online
	end

	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
		["x#~P"] = true,
		mainType = targetMainType
	})
end

M.ShowPanel = function(self, data)
	self.subType = data.subType

	if self.subType ~= gClientConst.HotCenterSubType.Main then
		self.ShowStandaloneSubData(self, data)
	end
end

M.ShowStandaloneSubData = function(self, data)
	local selectTabId = data.selectTab
	local selectedCfg = InspireHubConfig.GetConfig(selectTabId)

	if not selectedCfg then
		self:RefreshStandaloneDetailInfo()
		self.bindData.list:SetSimpleList(0)

		return
	end

	self.mainTabData = gHotCenterManager:GetStandaloneCategoryList(selectedCfg.Country)

	if not self.SubGroup or not self.SubGroup.CommonTabSingleStore then
		self.pendingShowStandaloneData = data
		self.standaloneInitTimer = FrameTimer.New(function ()
			self.standaloneInitTimer = nil

			if self.pendingShowStandaloneData then
				local pending = self.pendingShowStandaloneData
				self.pendingShowStandaloneData = nil

				self:ShowStandaloneSubData(pending)
			end
		end, 1)

		self.standaloneInitTimer:Start()

		return
	end

	self.SubGroup.CommonTabSingleStore:SetData(self.mainTabData, nil, 0, nil, self:CreateAction(self.OnStandaloneMainTabSelectedChanged))
	self:DisableCommonTabSingleStepBtns()

	local selectIndex = 0

	if selectTabId then
		for i = 1, #self.mainTabData do
			if self.mainTabData[i].id ~= selectTabId then
				selectIndex = i - 1

				break
			end
		end
	end

	self.curSelectMainType = nil
	self.curSelectStandaloneSubType = nil

	self.bindData.mainTab:SelectItem(selectIndex)
	self:ChangeStandaloneMainType(selectTabId)
end

M.ChangeStandaloneMainType = function(self, targetMainType)
	if targetMainType == self.curSelectMainType then
		self.curSelectMainType = targetMainType
		self.curSelectStandaloneSubType = nil

		self:RefreshStandaloneDetailInfo()

		self.subTabData = gHotCenterManager:GetStandaloneGameplayTypes(self.curSelectMainType)

		if self.subTabData then
			if self.IsStandaloneMergeSubTypeList(self) then
				self.bindData.showSubCtrl = self.showSubCtrlEnum._false

				if self.bindData.subTab then
					self.bindData.subTab:SetSimpleList(0)
				end

				self.listData = self:BuildStandaloneMergedListData()
				self.pendingNavToTop = true

				self.bindData.list:SetSimpleList(#self.listData)
				self:RefreshStandaloneDetailInfo(self:GetFirstStandaloneGameplayItem())
			else
				self.bindData.showSubCtrl = #self.subTabData <= 1 and self.showSubCtrlEnum._true or self.showSubCtrlEnum._false

				self.bindData.subTab:SetSimpleList(#self.subTabData)
				self.bindData.subTab:SelectItem(0)
			end
		else
			self.bindData.showSubCtrl = self.showSubCtrlEnum._false
			self.listData = {}

			self.bindData.list:SetSimpleList(0)
		end
	end
end

M.ChangeStandaloneSubType = function(self, targetSubType)
	if targetSubType == self.curSelectStandaloneSubType then
		self.curSelectStandaloneSubType = targetSubType
		local rawList = gHotCenterManager:GetStandaloneGameplayByType(self.curSelectStandaloneSubType.Id) or {}
		self.listData = {}

		if #rawList <= 0 then
			table.insert(self.listData, self.GetEntryTabTitleData(self))

			for _, item in ipairs(rawList) do
				table.insert(self.listData, item)
			end
		end

		self.pendingNavToTop = true

		self.bindData.list:SetSimpleList(#self.listData)
		self:RefreshStandaloneDetailInfo(self:GetFirstStandaloneGameplayItem())
	end
end

M.CloseStandaloneSubPanel = function(self)
	self.mainTabData = nil
	self.subTabData = nil
	self.listData = nil

	self.RefreshStandaloneDetailInfo(self)
end

M.RefreshStandaloneDetailInfo = function(self, data)
	local detailData = gHotCenterManager:GetStandaloneGameplayDetailData(data)
	self.bindData.onlineTitle = detailData.title or ""
	self.bindData.onlineDesc = detailData.desc or ""
end

M.IsStandaloneMergeSubTypeList = function(self)
	if table.isNilOrEmpty(self.subTabData) or #self.subTabData < 1 then
		return false
	end

	local cfg = InspireHubGamePlayTypeConfig.GetConfig(self.subTabData[1].Id)

	if not cfg then
		return false
	end

	return gHotCenterManager:GetStandaloneGameplayTemplateType(cfg) ~= gHotCenterManager.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_BIG
end

M.IsStandaloneJobMergedList = function(self)
	if table.isNilOrEmpty(self.subTabData) then
		return false
	end

	for _, subTypeData in ipairs(self.subTabData) do
		local cfg = subTypeData and InspireHubGamePlayTypeConfig.GetConfig(subTypeData.Id)

		if cfg and gHotCenterManager:GetStandaloneGameplayTemplateType(cfg) ~= gHotCenterManager.SUB_PANEL_LIST_TEMPLATE_TYPE.MAIN_SMALL then
			return true
		end
	end

	return false
end

M.GetOrderedStandaloneSubTabData = function(self)
	return self.subTabData or {}
end

M.BuildStandaloneMergedListData = function(self)
	local result = {}

	if table.isNilOrEmpty(self.subTabData) then
		return result
	end

	table.insert(result, self.GetEntryTabTitleData(self))

	local shouldShowTitle = self.IsStandaloneJobMergedList(self)

	for _, subTypeData in ipairs(self.GetOrderedStandaloneSubTabData(self)) do
		local list = gHotCenterManager:GetStandaloneGameplayByType(subTypeData.Id) or {}

		if shouldShowTitle and #list <= 0 then
			local typeCfg = subTypeData and InspireHubGamePlayTypeConfig.GetConfig(subTypeData.Id)

			table.insert(result, {
				["\\xd0\\xc8 \n(\\xf4"] = true,
				tIndex = STANDALONE_LIST_TITLE_TINDEX,
				title = typeCfg and typeCfg.Name or ""
			})
		end

		for _, item in ipairs(list) do
			table.insert(result, item)
		end
	end

	return result
end

M.GetEntryTabTitleData = function(self)
	local cfg = self.curSelectMainType and InspireHubConfig.GetConfig(self.curSelectMainType)

	return {
		["\\xd0\\xc8 \n(\\xf4"] = true,
		tIndex = STANDALONE_LIST_TITLE_TINDEX,
		title = cfg and cfg.Name or ""
	}
end

M.GetFirstStandaloneGameplayItem = function(self)
	slot1 = ipairs
	slot3 = self.listData or {}

	for _, data in slot1(slot3) do
		if data and not data.isTitle and data.Id and data.Id <= 0 then
			return data
		end
	end
end

M.FindComponent = function(self, rootWidget, path, componentName)
	if not rootWidget or not rootWidget.transform then
		return
	end

	local trans = rootWidget.transform:Find(path)

	if not trans then
		return
	end

	return trans.GetComponent(trans, componentName)
end

M.RenderStandaloneTitleItem = function(self, btn, data)
	local titleText = self:FindComponent(btn, "SDFText", "UText") or self:FindComponent(btn, "SDFText", "USDFText")

	SetText(titleText, data and data.title or "")
end

M.OnRenderStandaloneSubTabItem = function(self, btn, index)
	local data = self.subTabData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.Id <= 0 then
		local cfg = InspireHubGamePlayTypeConfig.GetConfig(data.Id)
		store.title = cfg and cfg.Name or ""
	end
end

M.OnStandaloneMainTabSelectedChanged = function(self, list)
	local data = self.mainTabData[list.selectedIndex + 1]

	if not data then
		return
	end

	local isInitial = self.curSelectMainType ~= nil

	self:ChangeStandaloneMainType(data.id)

	if isInitial then
		self.PlayMainTabOpenAnim(self)
	else
		self.PlayMainTabChangeAnim(self)
	end
end

M.OnMainSubTabSelectedChanged = function(self, list)
	local data = self.subTabData[list.selectedIndex + 1]

	if not data then
		return
	end

	self.ChangeStandaloneSubType(self, data)
end

M.OnGetStandaloneListTIndex = function(self, index)
	local data = self.listData[index + 1]

	if data then
		return data.tIndex or 0
	end

	return 0
end

M.OnRenderStandaloneListItem = function(self, btn, index)
	local data = self.listData[index + 1]

	if not data then
		return
	end

	if data.isTitle then
		self.RenderStandaloneTitleItem(self, btn, data)

		return
	end

	if data.Id and data.Id <= 0 then
		gHotCenterManager:RenderStandaloneListWidget(btn, data)
	end
end

M.OnClickStandaloneListItem = function(self, index)
	local data = self.listData[index + 1]

	if not data or data.isTitle then
		return
	end

	self.RefreshStandaloneDetailInfo(self, data)
end
