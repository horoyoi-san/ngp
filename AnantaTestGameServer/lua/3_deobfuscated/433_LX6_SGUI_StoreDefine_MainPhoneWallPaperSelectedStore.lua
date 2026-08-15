C_MainPhoneWallPaperSelectedStore = DefClass("C_MainPhoneWallPaperSelectedStore", C_MainPhoneWallPaperSelectedStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.MainPhoneWallPaperSelectedStore = C_MainPhoneWallPaperSelectedStore
local M = C_MainPhoneWallPaperSelectedStore

function M:OnAwake()
	self.bindData.resetButton.luaClick = self:CreateAction("OnResetClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.previewButton.luaClick = self:CreateAction("OnPreviewClick")
	self.bindData.confirmButton.luaClick = self:CreateAction("OnConfirmClick")
	self.bindData.list.luaRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.list.luaSelectedChanged = self:CreateAction("OnSelectedChange")
	self.bindData.smallList.luaRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.smallList.luaSelectedChanged = self:CreateAction("OnSelectedChange")
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnStep", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnStep", 1)
	self.bindData.hyperLinkList.luaSimpleRenderItem = self:CreateAction("OnHyperLinkRenderItem")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_SYNC_SPIRIT_SKIN_PART_INFO_CHANGE] = self:CreateAction("OnSkinPartInfoChange")
	}
end

function M:InitModel(args)
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

function M:InitView(args)
	M.base.InitView(self, args)

	if self.currentShowType == gClientConst.WALL_PAPER_HOME_TAB_TYPE.WallPaper or self.currentShowType == gClientConst.WALL_PAPER_HOME_TAB_TYPE.Suit then
		self.targetList = self.bindData.list

		self.bindData.smallList:SetActive(false)
	else
		self.targetList = self.bindData.smallList

		self.bindData.list:SetActive(false)
	end

	local viewDataList = self:GetViewDataList()

	self.targetList:SetList(viewDataList)

	for index, viewData in ipairs(viewDataList) do
		if viewData.id == self.targetId then
			self.targetList:GoToIndex(index - 1, true)

			break
		end
	end
end

function M:GetViewDataList()
	local viewDataList = gMainPhoneUtils.GetSkinPartViewDataList(self.currentShowType)

	for _, viewData in ipairs(viewDataList) do
		viewData.tIndex = self.List_Template_TYPE[self.currentShowType]
	end

	return viewDataList
end

function M:OnRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(data.id)
	store.iconId = skinPartCfg.IconId1 > 0 and skinPartCfg.IconId1 or skinPartCfg.IconId
	local isAvailable = gMainPhoneUtils.CheckIsApplySkinPart(data.id)
	store.hasGot = isAvailable and 1 or 0
end

function M:OnStep(step)
	local index = self.targetList.selectedIndex + step
	local itemCount = self.targetList.itemData.Count

	if index < 0 then
		index = itemCount - 1
	elseif itemCount <= index then
		index = 0
	end

	self.targetList:SelectItem(index)
end

function M:OnSkinPartInfoChange()
	self.bindData.list:RefreshList()
	self.bindData.smallList:RefreshList()
	self:RefreshSelectedSkinView()
end

function M:OnSelectedChange()
	self:RefreshSelectedSkinView()
end

function M:RefreshSelectedSkinView()
	local selectedId = self.targetList.selectedItem.id
	local isAvailable = gMainPhoneUtils.CheckSkinPartAvailable(selectedId)

	self.bindData.conditionText:SetActive(not isAvailable)

	local isApply = gMainPhoneUtils.CheckIsApplySkinPart(selectedId)
	self.bindData.confirmButton.interactable = isAvailable and not isApply

	if not isAvailable then
		self:RefreshHyperLinkView()
	end

	self.bindData.hasOwnerControl = isAvailable and 1 or 0
end

function M:RefreshHyperLinkView()
	local skinPartId = self.targetList.selectedItem.id
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(skinPartId)

	self.bindData.hyperLinkList:SetSimpleList(#skinPartCfg.HyperLinkIdList)
end

function M:OnResetClick()
	gMainPhoneUtils.OnExecuteSkinPartReset(self.rootGo)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_WALL_PAPER_APP_CONTENT_CLOSE)
end

function M:OnPreviewClick()
	local selectedItem = self.targetList.selectedItem

	gMessageManager:SendMessage(gEventConstants.ON_ENTER_PREVIEW_SKIN_MODE, {
		showType = self.currentShowType,
		skinPartId = selectedItem.id,
		mainPhonePageIndex = self.panelArgs.mainPhonePageIndex
	})
end

function M:OnConfirmClick()
	local skinPartId = self.targetList.selectedItem.id
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

function M:OnHyperLinkRenderItem(btn, csIndex)
	local skinPartId = self.targetList.selectedItem.id
	local skinPartCfg = LTConfig.MobileMenuSkinPartConfig.GetConfig(skinPartId)
	local luaIndex = csIndex + 1
	local hyperLinkId = skinPartCfg.HyperLinkIdList[luaIndex]
	local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

	gCommonItemManager:OnRenderDescItem(btn, _, hyperLinkInfo)

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	function store.button.luaClick()
		gCommonItemManager:OnDescItemClick(btn, hyperLinkInfo)
	end
end
