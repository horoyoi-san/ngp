C_YanjieNewMineBottomPanel = DefClass("C_YanjieNewMineBottomPanel", C_YanjieNewMineBottomPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewMineBottomPanel = C_YanjieNewMineBottomPanel
local M = C_YanjieNewMineBottomPanel

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.fullScreenButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.categoryList.luaSimpleRenderItem = self:CreateAction("OnCategoryRenderItem")
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.bindData.walletButton.luaClick = self:CreateAction("OnWalletClick")
	self.bindData.categoryList.luaSelectedChanged = self:CreateAction("OnListSelectChange")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_YANJIE_TOTAL_LEFT_MONEY_CHANGE] = self:CreateAction("RefreshTotalMoneyView")
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.LIST_TEMPLATE_TYPE = {
		ARROW = 1,
		COLLECTION = 2,
		NORMAL = 0
	}
end

function M:InitView(args)
	M.base.InitView(self, args)
	self:RefreshPanelView(true)
	self:RefreshTotalMoneyView()
end

function M:RefreshTotalMoneyView()
	self.bindData.totalLeftMoney = gSocialNetworkUtils.GetTotalLeftMoney()
end

function M:RefreshPanelView(isInit)
	local avatarWidget = self.bindData.avatar
	local playerAvatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	playerAvatarStore.headIcon = gSocialNetworkUtils.GetPlayerSGuiAvatarId()
	self.bindData.name = gSocialNetworkUtils.GetPlayerAccountName()
	self.categoryViewDataList = self:GetCategoryViewDataList(isInit)

	function self.bindData.categoryList.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.categoryViewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.categoryList:SetSimpleList(#self.categoryViewDataList)
	self.bindData.categoryList:SetItemSelected(0, true)
	self.bindData.categoryList:SelectItem(0, true)
	self:RefreshMoneyView()
end

function M:RefreshMoneyView()
	local moneyShowWidget = self.bindData.moneyShowWidget
	local moneyShowStore = gStoreManager:GetStoreGroup(moneyShowWidget.Store):GetStoreByWidget(moneyShowWidget)
	moneyShowStore.count = gSocialNetworkUtils.GetTotalLeftMoney()
	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(LTConfig.TuiteConfig.EyeCoinConsumableId)
	moneyShowStore.imageIcon = consumableCfg.SMoneyIconId
	moneyShowStore.iconButton.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", {
		TemplateId = LTConfig.TuiteConfig.EyeCoinConsumableId
	}, gCommonItemManager)
end

function M:GetCategoryViewDataList(isInit)
	local viewDataList = {}
	local count = LTConfig.TuiteMenuItemConfig.count
	local popularityHasUnlocked = gMainPhoneUtils.CheckFansSystemUnlocked()

	for i = 0, count - 1 do
		local menuItemCfg = LTConfig.TuiteMenuItemConfig.LoadAt(i)

		if menuItemCfg.Id == LTConfig.TuiteMenuItemConfig.Popularity then
			if popularityHasUnlocked then
				table.insert(viewDataList, {
					id = menuItemCfg.Id,
					csIndex = i,
					selected = isInit,
					tIndex = self.LIST_TEMPLATE_TYPE.NORMAL
				})
			end
		else
			table.insert(viewDataList, {
				selected = false,
				id = menuItemCfg.Id,
				csIndex = i,
				tIndex = self.LIST_TEMPLATE_TYPE.NORMAL
			})
		end
	end

	return viewDataList
end

function M:OnCategoryRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.categoryViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex == self.LIST_TEMPLATE_TYPE.NORMAL then
		self:RefreshNormalItemView(store, data)
	end
end

function M:RefreshNormalItemView(store, data)
	local menuItemCfg = LTConfig.TuiteMenuItemConfig.GetConfig(data.id)
	store.title = menuItemCfg.Title
	store.iconId = menuItemCfg.IconId
end

function M:RefreshTabRectView(csIndex)
	self.bindData.tabRect.selectedIndex = csIndex
end

function M:OnRenderTab(_, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	local args = {}

	store:ShowPanel(args)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

function M:OnWalletClick()
	gPanelManager:CheckShow(gPanelId.YANJIE_WITHDRAW_CASH)
end

function M:OnListSelectChange()
	local selectedIndex = self.bindData.categoryList.selectedIndex
	local selectedItem = self.categoryViewDataList[selectedIndex + 1]

	if selectedItem.id == LTConfig.TuiteMenuItemConfig.Popularity then
		self:RefreshTabRectView(selectedItem.csIndex)
	elseif selectedItem.id == LTConfig.TuiteMenuItemConfig.Collection then
		self:RefreshTabRectView(selectedItem.csIndex)
	elseif selectedItem.id == LTConfig.TuiteMenuItemConfig.Message then
		self:RefreshTabRectView(selectedItem.csIndex)
	elseif selectedItem.id == LTConfig.TuiteMenuItemConfig.MyRelated then
		self:RefreshTabRectView(4)
	elseif selectedItem.id == LTConfig.TuiteMenuItemConfig.Home then
		self:RefreshTabRectView(5)
	else
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900581).Text)
	end
end

function M:ClearData()
	return
end
