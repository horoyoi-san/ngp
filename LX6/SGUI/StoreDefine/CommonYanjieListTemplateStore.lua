-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonYanjieListTemplateStore.lua
-- Decompiled from: 01543_CommonYanjieListTemplateStore.lua_248ef61f4e1c.luajit

C_CommonYanjieListTemplate = DefClass("C_CommonYanjieListTemplate", C_CommonYanjieListTemplate, C_StoreGroup)
GroupName2Class.CommonYanjieListTemplate = C_CommonYanjieListTemplate
local M = C_CommonYanjieListTemplate
local ShowTypeControl = {
	["\\xfa\\xd4\t*\\xe5"] = 0,
	["h\\xa3\\xb2\\xbb\\xaf"] = 1
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.InitModel(self)
	self.InitView(self)
	self.InitMessageEvents(self)
end

M.InitMessageEvents = function(self)
	local msgEvents = {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_LIKE] = function (_, args)
			self:RefreshItemView(args)
		end
	}

	msgEvents[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION] = function (_, args)
		args.playCollectionAnimation = args.isCollect

		self:OnCollectionSuccess(args)
	end

	msgEvents[gEventConstants.ON_REQUEST_COMMENT_SOCIAL_NETWORK] = function (_, args)
		self:RefreshItemView(args)
	end

	msgEvents[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_DETAIL] = function (_, args)
		self:RefreshItemView(args)
	end

	msgEvents[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_FOLLOW] = function (_, args)
		self:FollowItemSuccess(args)
	end

	msgEvents[gEventConstants.ON_YANJIE_GET_REWARD_SUCCESS] = function (_, args)
		self:RefreshItemView(args)
	end

	msgEvents[gEventConstants.ON_YANJIE_SWITCH_VIEW_CHANGE] = function (_)
		self:OnSwitchViewChange()
	end

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnStart = function(self)
	gSocialNetworkUtils.DynamicLoadList(self.bindData.list, self.CreateAction(self, "OnScroll"), self.CreateAction(self, "OnScrollEnd"))
end

M.OnDestroy = function(self)
	self.hasDestroy = true

	self.ClearMessageEvents(self)
end

M.OnShow = function(self, _, _)
end

M.StartRequest = function(self)
	self.layoutSet = nil

	self.GetRequestDataList(self)
end

M.InitModel = function(self)
	self.buttonMap = {}
	self.hasDestroy = nil
	self.enableContentShowType = nil
	self.dataList = {}
	self.dataMap = {}
end

M.InitView = function(self)
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.list.luaSimpleDynamicRenderItem = self:CreateAction("OnDynamicRenderItem")
	self.bindData.list.luaDrag = self:CreateAction("OnDrag")
	self.bindData.list.luaEndDrag = self:CreateAction("OnDragEnd")

	self.bindData.list:RegisterToScrollEndEvent(self:CreateAction("OnScrollEnd"))

	self.bindData.list.luaLayoutSet = self:CreateAction("OnLayoutSet")
end

M.OnScroll = function(self)
	self.isScrolling = true
end

M.OnScrollEnd = function(self)
	self.isScrolling = nil

	self.CheckItemVisible(self)
end

M.CheckItemVisible = function(self)
	if not self.currentMaxCsIndex then
		return
	end

	local result, csMaxIndex = nil
	local startCsIndex = self.currentMaxCsIndex - 2
	local endCsIndex = self.currentMaxCsIndex + 1
	result, csMaxIndex = self.bindData.list:GetBottomVisibleMaxIndex(startCsIndex, endCsIndex, csMaxIndex)

	if not result then
		return
	end

	local lastMax = self.lastReportedMaxCsIndex or -1

	if csMaxIndex < lastMax then
		return
	end

	self.lastReportedMaxCsIndex = csMaxIndex
	local luaMaxIndex = csMaxIndex + 1
	local beginIndex = math.max(lastMax + 2, luaMaxIndex - 2, 1)

	for index = beginIndex, luaMaxIndex do
		local data = self.dataList[index]

		if data then
			local tuiteConfigId = gSocialNetworkUtils.GetTuiteConfigId(data)

			gSocialNetworkUtils.AskTwitterBehaviorFinish(tuiteConfigId, UX.Game.TwitterBehavior.ItemVisible)
		end
	end
end

M.OnRenderItem = function(self, btn, csIndex)
	if self.hideAvatarHeadButton then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if store.avatarHeadButton then
			store.avatarHeadButton:SetActive(false)
		end
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if self.enableContentShowType then
		local switchViewValue = gClientUtils.GetBool(gClientConst.YanJieSearchViewPrefsKey, false)
		store.contentTypeCtrl = switchViewValue and 1 or 0
	else
		store.contentTypeCtrl = 0
	end

	local luaIndex = csIndex + 1
	local data = self.dataList[luaIndex]
	data.isLastOne = luaIndex ~= #self.dataList
	data.itemClickCallback = self.itemClickCallback

	gSocialNetworkUtils.RefreshMomentItem(btn, data)

	self.buttonMap[data.id] = btn

	if csIndex ~= 0 then
		local activeArea = SGUI.UNavigationMgr.Inst.CurrentActiveArea

		if activeArea and activeArea.CurrentActiveContent and activeArea.CurrentActiveContent.transform then
			btn.Navigate(btn, btn)
		else
			btn.Navigate(btn, btn)
		end
	end

	self.currentMaxCsIndex = csIndex
end

M.GetIdList = function(self)
	local idList = {}

	for _, data in ipairs(self.dataList) do
		table.insert(idList, data.id)
	end

	return idList
end

M.GetRequestDataList = function(self)
	if self.GetList then
		local data = self.GetList()

		if not self.hasDestroy and data then
			data.list = gSocialNetworkUtils.SortTuiteInfoList(data.list)

			self.RefreshContentListView(self, data)
		end
	end
end

M.RefreshContentListView = function(self, requestData)
	if requestData then
		self.dataList = {}
		self.dataMap = {}
		local isFullScreen = gMainPhoneUtils.CheckYanJieIsFullScreen()
		slot3 = ipairs
		slot5 = requestData.list or {}

		for _, data in slot3(slot5) do
			local isTaskTemplate = data.templateId and data.templateId >= 0
			local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)
			isTaskTemplate = isTaskTemplate and tuiteCfg and tuiteCfg.TaskEvent and tuiteCfg.TaskEvent >= 0
			data.tIndex = isFullScreen and isTaskTemplate and 1 or 0

			table.insert(self.dataList, data)

			self.dataMap[data.id] = data
		end

		self.lastReportedMaxCsIndex = nil
	end

	self.firstBtn = nil

	self.bindData.list.onGetTIndex = function(csIndex)
		local data = self.dataList[csIndex + 1]

		return data and data.tIndex or 0
	end

	self.bindData.list:SetSimpleList(#self.dataList)

	self.bindData.showTypeCtrl = #self.dataList ~= 0 and ShowTypeControl.Empty or ShowTypeControl.Content

	if requestData then
		self.CheckItemVisible(self)
	end
end

M.RefreshItemView = function(self, args)
	local data = self.dataMap[args.id]

	if data then
		for k, v in pairs(args) do
			data[k] = v
		end
	end

	local button = self.buttonMap[args.id]

	if button then
		gSocialNetworkUtils.RefreshMomentItem(button, data or args)
	end
end

M.FollowItemSuccess = function(self, roleInfo)
	local roleId = roleInfo.roleId

	for _, data in pairs(self.dataMap) do
		if data.roleInfo and data.roleInfo.roleId ~= roleId then
			data.roleInfo.isFollow = roleInfo.isFollow
		end
	end

	self.RefreshContentListView(self)
end

M.OnDynamicRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.dataList[luaIndex]
	data.isLastOne = luaIndex ~= #self.dataList

	gSocialNetworkUtils.RefreshMomentItem(btn, data, true)

	if self.hideAvatarHeadButton then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if store.avatarHeadButton then
			store.avatarHeadButton:SetActive(false)
		end
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if self.enableContentShowType then
		local switchViewValue = gClientUtils.GetBool(gClientConst.YanJieSearchViewPrefsKey, false)
		store.contentTypeCtrl = switchViewValue and 1 or 0
	else
		store.contentTypeCtrl = 0
	end

	store.layout:ForceRebuildLayoutImmediate()
end

M.OnCollectionSuccess = function(self, args)
	self.RefreshItemView(self, args)
end

M.ClearAndRefreshData = function(self)
	self.layoutSet = nil

	self.GetRequestDataList(self)
end

M.OnUpdate = function(self)
	if self.isScrolling then
		self.timer = self.timer or 0
		self.timer = self.timer + Time.deltaTime

		if gClientConst.YanJieScrollIngCheckInterval < self.timer then
			self.CheckItemVisible(self)

			self.timer = 0
		end
	else
		self.timer = nil
	end
end

M.OnSwitchViewChange = function(self)
	if self.enableContentShowType then
		self.ClearAndRefreshData(self)
	end
end

M.OnLayoutSet = function(self)
	if self.layoutSet then
		return
	end

	self.layoutSet = true

	self.bindData.list:SetNavSelectToTop()
end

M.OnClose = function(self)
	self.buttonMap = nil
	self.isScrolling = nil
	self.currentMaxCsIndex = nil
	self.lastReportedMaxCsIndex = nil
end
