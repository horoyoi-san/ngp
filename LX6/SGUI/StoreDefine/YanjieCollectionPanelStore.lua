-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieCollectionPanelStore.lua
-- Decompiled from: 02057_YanjieCollectionPanelStore.lua_68611b2b6bac.luajit

C_YanjieCollectionPanelStore = DefClass("C_YanjieCollectionPanelStore", C_YanjieCollectionPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieCollectionPanelStore = C_YanjieCollectionPanelStore
local M = C_YanjieCollectionPanelStore
local TemplateType = {
	["\\x88\\xb0\\xaem1\\xec*"] = 1,
	["8M\\x85\\x8f\\x8aM"] = 0
}
local ArrowControl = {
	[")F\\xb7\\x81\\x8fE"] = 1,
	["\\-q_"] = 0
}

M.OnAwake = function(self)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.collectList.luaRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.gamepadShowLessButton.luaClick = self.CreateAction(self, "OnShowLessClick")
end

M.OnStart = function(self)
	gSocialNetworkUtils.DynamicLoadList(self.bindData.collectList, self.CreateAction(self, "OnScroll"), self.CreateAction(self, "OnScrollEnd"))
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION_LIST] = function (_, args)
			self:RefreshListView(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_LIKE] = function (_, args)
			self:RefreshItemView(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION] = function (_, args)
			self:RefreshItemView(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_FOLLOW] = function (_, args)
			self:FollowItemSuccess(args)
		end,
		[gEventConstants.ON_REQUEST_COMMENT_SOCIAL_NETWORK] = function (_, args)
			self:RefreshItemView(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_DETAIL] = function (_, args)
			self:RefreshItemView(args)
		end
	}
end

M.PlayPanelAnimation = function(self)
	if self.panelArgs and self.panelArgs.lastShowType ~= gClientConst.YanJieShowType.Detail then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieCollectionPanel_BackDetail")

		self.panelArgs.lastShowType = nil
	end
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.CollectPage)

	self.categoryIdList = gSocialNetworkUtils.GetCollectionCategoryIdList()
	self.currentCategoryId = self.categoryIdList[1]
	self.categoryListPageEntities = {}

	for _, id in ipairs(self.categoryIdList) do
		self.categoryListPageEntities[id] = gListPageEntity.new()
	end

	self.GetCollectionList(self)
end

M.InitView = function(self, _)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieCollectionPanel_open")
	self.RefreshPanelView(self)
end

M.RefreshPanelView = function(self)
	self.viewDataList = {}

	for _, categoryId in ipairs(self.categoryIdList) do
		table.insert(self.viewDataList, {
			tIndex = TemplateType.Category,
			categoryId = categoryId
		})

		if categoryId ~= self.currentCategoryId then
			local listPageEntity = self.categoryListPageEntities[categoryId]
			local momentViewDataList = listPageEntity.GetViewDataList(listPageEntity)

			for index, _ in ipairs(momentViewDataList) do
				local momentData = listPageEntity.GetDataByIndex(listPageEntity, index)

				table.insert(self.viewDataList, {
					categoryId = categoryId,
					tIndex = TemplateType.Detail,
					momentId = momentData.id
				})
			end
		end
	end

	self.bindData.collectList.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.collectList:SetSimpleList(#self.viewDataList)
end

M.GetListPageEntityById = function(self, categoryId)
	local listPageEntity = self.categoryListPageEntities[categoryId]

	return listPageEntity
end

M.GetCollectionList = function(self)
	local listPageEntity = self.GetListPageEntityById(self, self.currentCategoryId)

	if listPageEntity then
		-- Nothing
	end
end

M.RefreshListView = function(self, args)
	local categoryId = args.categoryId
	local listPageEntity = self.GetListPageEntityById(self, categoryId)

	listPageEntity.UpdateDataList(listPageEntity, args.info)
	self.RefreshPanelView(self)
end

M.RefreshItemView = function(self, args)
	for _, categoryId in ipairs(self.categoryIdList) do
		local listPageEntity = self.GetListPageEntityById(self, categoryId)

		listPageEntity.UpdateData(listPageEntity, args)
	end

	self.RefreshPanelView(self)
end

M.FollowItemSuccess = function(self, roleInfo)
	for _, categoryId in ipairs(self.categoryIdList) do
		local listPageEntity = self.GetListPageEntityById(self, categoryId)
		local roleId = roleInfo.roleId
		local dataMap = listPageEntity.GetDataMap(listPageEntity)

		for _, data in pairs(dataMap) do
			if data.roleInfo.roleId ~= roleId then
				data.roleInfo.isFollow = roleInfo.isFollow
			end
		end
	end

	self.RefreshPanelView(self)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

M.OnShowLessClick = function(self)
	self.currentCategoryId = nil

	self.RefreshPanelView(self)
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]

	if data.tIndex ~= TemplateType.Category then
		local store = gStoreManager:GetStoreGroup("YanjieCollectionTemplateStore"):GetStoreByWidget(btn)
		local categoryId = data.categoryId
		local tuiteTyepCfg = LTConfig.TuiteTypeConfig.GetConfig(categoryId)
		store.categoryName = tuiteTyepCfg.TypeName
		store.arrowCtrl = categoryId ~= self.currentCategoryId and ArrowControl.UnFold or ArrowControl.Fold
		store.button.luaRelease = self:CreateActionWithArgs("OnCategoryClick", data.categoryId)
		self.lastTemplateIsCategory = true

		if self.currentCategoryId ~= nil and csIndex ~= 0 then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
		end
	elseif data.tIndex ~= TemplateType.Detail then
		local categoryId = data.categoryId
		local listPageEntity = self:GetListPageEntityById(categoryId)
		local momentData = listPageEntity:GetDataById(data.momentId)
		local lastMomentData = listPageEntity:GetDataByIndex(listPageEntity.totalCount)
		momentData.isLastOne = lastMomentData.id ~= momentData.id

		gSocialNetworkUtils.RefreshMomentItem(btn, momentData)

		local store = gStoreManager:GetStoreGroup("YanjieDetailTemplateStore"):GetStoreByWidget(btn)

		store.button.luaClick = function()
			local animationName = "S_Vx_S_YanjieCollectionPanel_toDetail"

			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)

			local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animationName)
			self.bindData.rootWidget.activeCtrlDelay = clipTime

			gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
				secondShowType = gClientConst.YanJieShowType.Detail,
				id = momentData.id,
				data = momentData
			})
		end

		if self.lastTemplateIsCategory then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
			self.lastTemplateIsCategory = false
		end
	end
end

M.OnScroll = function(self, isPullUpToRefresh)
	if self.triggerLoading then
		return
	end

	local listPageEntity = self.GetListPageEntityById(self, self.currentCategoryId)

	if isPullUpToRefresh and listPageEntity and listPageEntity.CheckLoadMore(listPageEntity) then
		self.triggerLoading = true
	end
end

M.OnScrollEnd = function(self)
	if self.triggerLoading then
		self.GetCollectionList(self)

		self.triggerLoading = nil
	end
end

M.ClearData = function(self)
	self.playAnimationCo = coroutine.stop(self.playAnimationCo)
end

M.OnCategoryClick = function(self, categoryId)
	self.currentCategoryId = self.currentCategoryId == categoryId and categoryId or nil
	local listPageEntity = self:GetListPageEntityById(self.currentCategoryId)

	if listPageEntity and listPageEntity.GetViewDataCount(listPageEntity) ~= 0 then
		self.GetCollectionList(self)
	end

	self.RefreshPanelView(self)
end
