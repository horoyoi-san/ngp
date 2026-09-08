-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnantarkovMainPanelStore.lua
-- Decompiled from: 01616_AnantarkovMainPanelStore.lua_12341e6d6521.luajit

C_AnantarkovMainPanelStore = DefClass("C_AnantarkovMainPanelStore", C_AnantarkovMainPanelStore, C_StoreGroup)
GroupName2Class.AnantarkovMainPanelStore = C_AnantarkovMainPanelStore
local M = C_AnantarkovMainPanelStore

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
	self.ClearMessageEvents(self)
	self.CloseAllTabPanels(self)

	self.currentPageId = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	if self.currentPageId then
		return
	end

	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.currentPageId = args.currentPageId
	self.gameTypeId = args.gameTypeId
	self.tabDataList = gExtractionShooterManager.GetMainTabListViewData(self.gameTypeId)
	local data = self.tabDataList and self.tabDataList[1]

	if not data then
		print_error("@linminghe --- AnantarkovMainPanelStore data is nil", inspect(args))

		return
	end

	local id = data.id
	local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(id)
	self.currentPageId = homePageCfg.OpenPanelId
end

M.InitView = function(self)
	self.SubGroup.CommonTabSingleStore:SetData(self.tabDataList, nil, 0, 0, self:CreateAction("OnTabSelectedChanged"))

	local gameTypeId = self.gameTypeId
	local gameTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(gameTypeId)
	local showMoneyTypeList = gameTypeCfg.ShowMoneyTypeList or {}
	local moneyDataList = {}

	for _, showMoneyType in ipairs(showMoneyTypeList) do
		table.insert(moneyDataList, {
			Type = showMoneyType
		})
	end

	self.SubGroup.MoneyTemplateStore:SetData(moneyDataList)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PANEL_ON_SHOW] = self.CreateAction(self, "OnPanelShow"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_JUMP_HOME_PAGE] = self.CreateAction(self, "OnJumpHomePage")
	}
end

M.RegisterWidget = function(self)
end

M.OnClickExitButton = function(self)
	gPanelManager:Close(self.m_Id)
end

M.CloseAllTabPanels = function(self)
	for _, tabData in ipairs(self.tabDataList) do
		local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(tabData.id)

		if homePageCfg.OpenPanelId <= 0 then
			gMainPageManager:UnlockMainPage(homePageCfg.OpenPanelId)
			gPanelManager:Close(homePageCfg.OpenPanelId)
		end
	end
end

M.OnPanelShow = function(self, _, panelId)
	if self.CheckIsTabPanel(self, panelId) then
		gPanelManager:CheckShow(self.m_Id)
	end
end

M.OnJumpHomePage = function(self, _, args)
	local homePageId = args.homePageId

	for index, tabData in ipairs(self.tabDataList) do
		if tabData.id ~= homePageId and self.SubGroup.CommonTabSingleStore.selectedIndex == index then
			local currentSelectedIndex = self.SubGroup.CommonTabSingleStore:GetSelectedIndex()
			local currentHomePageId = self.tabDataList[currentSelectedIndex + 1].id
			self.fromHomePageId = currentHomePageId

			self.SubGroup.CommonTabSingleStore:SetSelectedIndex(index - 1, true)

			break
		end
	end
end

M.CheckIsTabPanel = function(self, panelId)
	if not self.tabDataList then
		return false
	end

	for index, data in ipairs(self.tabDataList) do
		local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(data.id)

		if homePageCfg.OpenPanelId ~= panelId then
			return true, index
		end
	end
end

M.OnPanelClose = function(self, _, panelId)
	local isTabPanel, tabIndex = self.CheckIsTabPanel(self, panelId)

	if isTabPanel then
		if tabIndex == 1 then
			gMainPageManager:UnlockMainPage(panelId)
			self.SubGroup.CommonTabSingleStore:SetSelectedIndex(0, true)

			return
		end

		gPanelManager:Close(self.m_Id)
	end
end

M.OnTabSelectedChanged = function(self, uList)
	local selectedIndex = uList.selectedIndex
	local data = self.tabDataList[selectedIndex + 1]

	if data.id ~= self.currentPageId then
		return
	end

	local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(data.id)

	if homePageCfg.OpenPanelId <= 0 then
		self.currentPageId = homePageCfg.OpenPanelId

		gMainPageManager:LockMainPage(homePageCfg.OpenPanelId)

		if homePageCfg.OpenPanelId ~= gPanelId.TALENT_TREE_PANEL then
			gDialogScriptFunc.ShowCommonGameplayTalentTree(2)
		else
			gPanelManager:CheckShow(homePageCfg.OpenPanelId, {
				["}\\xef\\xfe&:\\xc2h.\\xe1J\\x8e<C\\xc1\\xe3"] = true,
				homePageId = homePageCfg.Id,
				gamePlayTypeId = homePageCfg.GameType
			})
		end
	end
end
