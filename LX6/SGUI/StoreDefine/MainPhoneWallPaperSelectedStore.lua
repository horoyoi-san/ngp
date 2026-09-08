-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MainPhoneWallPaperSelectedStore.lua
-- Decompiled from: 01964_MainPhoneWallPaperSelectedStore.lua_540333f381be.luajit

C_MainPhoneWallPaperSelectedStore = DefClass("C_MainPhoneWallPaperSelectedStore", C_MainPhoneWallPaperSelectedStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.MainPhoneWallPaperSelectedStore = C_MainPhoneWallPaperSelectedStore
local M = C_MainPhoneWallPaperSelectedStore

M.OnAwake = function(self)
	self.bindData.resetButton.luaClick = self.CreateAction(self, "OnResetClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.previewButton.luaClick = self.CreateAction(self, "OnPreviewClick")
	self.bindData.confirmButton.luaClick = self.CreateAction(self, "OnConfirmClick")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.list.luaSelectedChanged = self.CreateAction(self, "OnSelectedChange")
	self.bindData.smallList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.smallList.luaSelectedChanged = self.CreateAction(self, "OnSelectedChange")
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnStep", -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnStep", 1)
	self.bindData.hyperLinkList.luaSimpleRenderItem = self.CreateAction(self, "OnHyperLinkRenderItem")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_SYNC_SPIRIT_SKIN_PART_INFO_CHANGE] = self.CreateAction(self, "OnSkinPartInfoChange")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.targetId = args.targetId
	self.currentShowType = args.showType
	self.List_Template_TYPE = {
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper] = 0,
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Decoration] = 1,
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Pendant] = 2,
		[gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit] = 0
	}
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	if self.currentShowType ~= gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper or self.currentShowType ~= gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit then
		self.targetList = self.bindData.list

		self.bindData.smallList:SetActive(false)
	else
		self.targetList = self.bindData.smallList

		self.bindData.list:SetActive(false)
	end

	self.viewDataList = self:GetViewDataList()

	self.targetList.onGetTIndex = function(index)
		local data = self.viewDataList[index + 1]

		return data.tIndex
	end

	self.targetList:SetSimpleList(#self.viewDataList)

	for index, viewData in ipairs(self.viewDataList) do
		if viewData.id ~= self.targetId then
			self.targetList:GoToIndex(index - 1, true)

			break
		end
	end
end

M.GetViewDataList = function(self)
	local viewDataList = gMainPhoneUtils.GetSkinPartViewDataList(self.currentShowType)

	for _, viewData in ipairs(viewDataList) do
		viewData.tIndex = self.List_Template_TYPE[self.currentShowType]
	end

	return viewDataList
end

M.OnRenderItem = function(self, btn, index)
	local data = self.viewDataList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.iconId = gMainPhoneUtils.GetSkinPartIconId(data.id)
	local isAvailable = gMainPhoneUtils.CheckIsApplySkinPart(data.id)
	store.hasGot = isAvailable and 1 or 0
end

M.OnStep = function(self, step)
	local index = self.targetList.selectedIndex + step
	local itemCount = self.targetList.itemData.Count

	if index >= 0 then
		index = itemCount - 1
	elseif itemCount < index then
		index = 0
	end

	self.targetList:SelectItem(index)
end

M.OnSkinPartInfoChange = function(self)
	self.bindData.list:RefreshList()
	self.bindData.smallList:RefreshList()
	self:RefreshSelectedSkinView()
end

M.OnSelectedChange = function(self)
	self.RefreshSelectedSkinView(self)
end

M.RefreshSelectedSkinView = function(self)
	local selectedId = self:GetSelectedItemId()
	local isAvailable = gMainPhoneUtils.CheckSkinPartAvailable(selectedId)

	self.bindData.conditionText:SetActive(not isAvailable)

	local isApply = gMainPhoneUtils.CheckIsApplySkinPart(selectedId)
	self.bindData.confirmButton.interactable = isAvailable and not isApply

	if not isAvailable then
		self.RefreshHyperLinkView(self)
	end

	self.bindData.hasOwnerControl = isAvailable and 1 or 0
end

M.RefreshHyperLinkView = function(self)
	local skinPartId = self:GetSelectedItemId()
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(skinPartId)

	self.bindData.hyperLinkList:SetSimpleList(#skinPartCfg.HyperLinkIdList)
end

M.OnResetClick = function(self)
	gMainPhoneUtils.OnExecuteSkinPartReset(self.rootGo)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_WALL_PAPER_APP_CONTENT_CLOSE)
end

M.OnPreviewClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_ENTER_PREVIEW_SKIN_MODE, {
		showType = self.currentShowType,
		skinPartId = self:GetSelectedItemId(),
		mainPhonePageIndex = self.panelArgs.mainPhonePageIndex
	})
end

M.OnConfirmClick = function(self)
	local skinPartId = self:GetSelectedItemId()
	local wallPaperId, decorationId, pendantId = gMainPhoneUtils.GetTargetSkinIds(skinPartId)
	local serverSkinInfo = gMainPhoneUtils.GetCurrentSpiritSkinInfo()
	wallPaperId = wallPaperId or serverSkinInfo.wallPaperId
	decorationId = decorationId or serverSkinInfo.decorationId
	pendantId = pendantId or serverSkinInfo.pendantId
	local rootGo = self.rootGo

	gMainPhoneUtils.AskSetMobileSkinPart({
		wallPaperId = wallPaperId,
		decorationId = decorationId,
		pendantId = pendantId,
		callback = function ()
			if gClientUtils.NotNil(rootGo) then
				self.targetList:RefreshList()
			end
		end
	})
end

M.GetSelectedItemId = function(self)
	local selectedIndex = self.targetList.selectedIndex
	local data = self.viewDataList[selectedIndex + 1]

	return data.id
end

M.OnHyperLinkRenderItem = function(self, btn, csIndex)
	local skinPartId = self:GetSelectedItemId()
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(skinPartId)
	local luaIndex = csIndex + 1
	local hyperLinkId = skinPartCfg.HyperLinkIdList[luaIndex]
	local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

	if hyperLinkInfo then
		slot9 = gCommonItemManager

		slot9:OnRenderDescItem(btn, _, hyperLinkInfo)

		slot9 = gStoreManager
		slot9 = slot9:GetStoreGroup(btn.Store)
		local store = slot9:GetStoreByWidget(btn)

		store.button.luaClick = function()
			gCommonItemManager:OnDescItemClick(btn, hyperLinkInfo)
		end
	end
end
