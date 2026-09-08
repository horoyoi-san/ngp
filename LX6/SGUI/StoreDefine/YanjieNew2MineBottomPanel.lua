-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieNew2MineBottomPanel.lua
-- Decompiled from: 02068_YanjieNew2MineBottomPanel.lua_d9b18ef9ba04.luajit

C_YanjieNew2MineBottomPanel = DefClass("C_YanjieNew2MineBottomPanel", C_YanjieNew2MineBottomPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNew2MineBottomPanel = C_YanjieNew2MineBottomPanel
local M = C_YanjieNew2MineBottomPanel

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTabItem)
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, self.OnTabSelectedChanged)
	self.bindData.fansRightButton.luaClick = self.CreateAction(self, self.OnFansRightClick)
	self.bindData.tabLeftButton.luaClick = self.CreateActionWithArgs(self, "OnStep", -1)
	self.bindData.tabLeftButton.luaBeginLongPress = self.CreateActionWithArgs(self, "OnBeginLongPress", -1)
	self.bindData.tabLeftButton.luaEndLongPress = self.CreateAction(self, "OnEndLongPress")
	self.bindData.tabRightButton.luaClick = self.CreateActionWithArgs(self, "OnStep", 1)
	self.bindData.tabRightButton.luaBeginLongPress = self.CreateActionWithArgs(self, "OnBeginLongPress", 1)
	self.bindData.tabRightButton.luaEndLongPress = self.CreateAction(self, "OnEndLongPress")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
end

M.OnClickExitButton = function(self)
end

M.OnRenderTabItem = function(self, btn, index)
	local data = self.tabDataList[index + 1]
	slot4 = gStoreManager
	slot4 = slot4:GetStoreGroup(btn.Store)
	local store = slot4:GetStoreByWidget(btn)
	local menuItemCfg = LTConfig.TuiteMenuItemConfig.GetConfig(data.id)
	store.title = menuItemCfg.Title

	btn.luaClick = function()
		self.bindData.tabList:SelectItem(index, true)
	end
end

M.OnTabSelectedChanged = function(self)
	self.bindData.tabRect.selectedIndex = self.bindData.tabList.selectedIndex
end

M.OnFansRightClick = function(self)
	gPanelManager:CheckShow(gPanelId.YANJIE_MEMBER_CENTER_PANEL)
end

M.OnStep = function(self, step)
	self.preTime = gLogicTime.unscaledTime
	local index = self.bindData.tabList.selectedIndex + step
	local itemCount = #self.tabDataList

	if index >= 0 then
		index = itemCount - 1
	elseif itemCount < index then
		index = 0
	end

	self.bindData.tabList:SelectItem(index)
end

M.OnRenderTab = function(self, index, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	local args = {}

	store:ShowPanel(args)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.RefreshStageLevelView(self)
	self.InitTabListView(self)
	self.RefreshAvatarView(self)
	gSocialNetworkUtils.RefreshPlayerExpProgressView(self.bindData.commonFansLevel)

	if args.newUnlockedStageId then
		gPanelManager:CheckShow(gPanelId.YANJIE_MINE_HOME_POPUP_PANEL, {
			stageId = args.newUnlockedStageId
		})
	end
end

M.RefreshStageLevelView = function(self)
	local growthStageId = gPlayerManager.infoMinor.bindData.growthStageId
	local stageCfg = LTConfig.GrowthEndorsementStageConfig.GetConfig(growthStageId)

	if stageCfg then
		self.bindData.stageName = stageCfg.StageName
	else
		self.bindData.isOfficial = false
	end
end

M.InitTabListView = function(self)
	local count = LTConfig.TuiteMenuItemConfig.count
	self.tabDataList = {}

	for i = 0, count - 1 do
		local menuItemCfg = LTConfig.TuiteMenuItemConfig.LoadAt(i)

		table.insert(self.tabDataList, {
			id = menuItemCfg.Id
		})
	end

	self.bindData.tabList:SetSimpleList(count)
	self.bindData.tabList:SelectItem(0, true)
end

M.RefreshAvatarView = function(self)
	local playerAvatar = self.bindData.avatar
	local playerAvatarStore = gStoreManager:GetStoreGroup(playerAvatar.Store):GetStoreByWidget(playerAvatar)
	playerAvatarStore.headIcon = gSocialNetworkUtils.GetPlayerSGuiAvatarId()
	playerAvatarStore.button.luaClick = self:CreateAction("OnPlayerAvatarClick")
	self.bindData.name = gSocialNetworkUtils.GetPlayerAccountName()
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
