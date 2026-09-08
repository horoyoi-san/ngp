-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieNewMineBottomPanel.lua
-- Decompiled from: 01914_YanjieNewMineBottomPanel.lua_705c562cce01.luajit

C_YanjieNewMineBottomPanel = DefClass("C_YanjieNewMineBottomPanel", C_YanjieNewMineBottomPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewMineBottomPanel = C_YanjieNewMineBottomPanel
local M = C_YanjieNewMineBottomPanel

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.categoryList.luaSimpleRenderItem = self.CreateAction(self, "OnCategoryRenderItem")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.bindData.walletButton.luaClick = self.CreateAction(self, "OnWalletClick")
	self.bindData.categoryList.luaSelectedChanged = self.CreateAction(self, "OnListSelectChange")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_YANJIE_TOTAL_LEFT_MONEY_CHANGE] = self.CreateAction(self, "RefreshTotalMoneyView")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.LIST_TEMPLATE_TYPE = {
		["l\\x9c\\x90\\x80\\x81"] = 1,
		["pu②+\\x8c-\\xe6\\xc6"] = 2,
		["2g\\xa3\\xa3\\xa2m"] = 0
	}
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.RefreshPanelView(self, true)
	self.RefreshTotalMoneyView(self)
end

M.RefreshTotalMoneyView = function(self)
	self.bindData.totalLeftMoney = gSocialNetworkUtils.GetTotalLeftMoney()
end

M.RefreshPanelView = function(self, isInit)
	local avatarWidget = self.bindData.avatar
	local playerAvatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	playerAvatarStore.headIcon = gSocialNetworkUtils.GetPlayerSGuiAvatarId()
	self.bindData.name = gSocialNetworkUtils.GetPlayerAccountName()
	self.categoryViewDataList = self:GetCategoryViewDataList(isInit)

	self.bindData.categoryList.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1
		local data = self.categoryViewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.categoryList:SetSimpleList(#self.categoryViewDataList)
	self.bindData.categoryList:SetItemSelected(0, true)
	self.bindData.categoryList:SelectItem(0, true)
	self:RefreshMoneyView()
end

M.RefreshMoneyView = function(self)
	local moneyShowWidget = self.bindData.moneyShowWidget
	local moneyShowStore = gStoreManager:GetStoreGroup(moneyShowWidget.Store):GetStoreByWidget(moneyShowWidget)
	moneyShowStore.count = gSocialNetworkUtils.GetTotalLeftMoney()
	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(LTConfig.TuiteConfig.EyeCoinConsumableId)
	moneyShowStore.imageIcon = consumableCfg.SMoneyIconId
	moneyShowStore.iconButton.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", {
		TemplateId = LTConfig.TuiteConfig.EyeCoinConsumableId
	}, gCommonItemManager)
end

M.GetCategoryViewDataList = function(self, isInit)
	local viewDataList = {}
	local count = LTConfig.TuiteMenuItemConfig.count
	local popularityHasUnlocked = gMainPhoneUtils.CheckFansSystemUnlocked()

	for i = 0, count - 1 do
		local menuItemCfg = LTConfig.TuiteMenuItemConfig.LoadAt(i)

		if menuItemCfg.Id ~= LTConfig.TuiteMenuItemConfig.Popularity then
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
				["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
				id = menuItemCfg.Id,
				csIndex = i,
				tIndex = self.LIST_TEMPLATE_TYPE.NORMAL
			})
		end
	end

	return viewDataList
end

M.OnCategoryRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.categoryViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex ~= self.LIST_TEMPLATE_TYPE.NORMAL then
		self.RefreshNormalItemView(self, store, data)
	end
end

M.RefreshNormalItemView = function(self, store, data)
	local menuItemCfg = LTConfig.TuiteMenuItemConfig.GetConfig(data.id)
	store.title = menuItemCfg.Title
	store.iconId = menuItemCfg.IconId
end

M.RefreshTabRectView = function(self, csIndex)
	self.bindData.tabRect.selectedIndex = csIndex
end

M.OnRenderTab = function(self, _, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	local args = {}

	store:ShowPanel(args)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

M.OnWalletClick = function(self)
	gPanelManager:CheckShow(gPanelId.YANJIE_WITHDRAW_CASH)
end

M.OnListSelectChange = function(self)
	local selectedIndex = self.bindData.categoryList.selectedIndex
	local selectedItem = self.categoryViewDataList[selectedIndex + 1]

	if selectedItem.id ~= LTConfig.TuiteMenuItemConfig.Popularity then
		self.RefreshTabRectView(self, selectedItem.csIndex)
	elseif selectedItem.id ~= LTConfig.TuiteMenuItemConfig.Collection then
		self.RefreshTabRectView(self, selectedItem.csIndex)
	elseif selectedItem.id ~= LTConfig.TuiteMenuItemConfig.Message then
		self.RefreshTabRectView(self, selectedItem.csIndex)
	elseif selectedItem.id ~= LTConfig.TuiteMenuItemConfig.MyRelated then
		self.RefreshTabRectView(self, 4)
	elseif selectedItem.id ~= LTConfig.TuiteMenuItemConfig.Home then
		self.RefreshTabRectView(self, 5)
	else
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900581).Text)
	end
end

M.ClearData = function(self)
end
