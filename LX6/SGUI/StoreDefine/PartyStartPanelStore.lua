-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartyStartPanelStore.lua
-- Decompiled from: 01082_PartyStartPanelStore.lua_a608e186668f.luajit

local MoneyType = UX.Game.MoneyType
local PartyConfig = LTConfig.PartyConfig
C_PartyStartPanelStore = DefClass("C_PartyStartPanelStore", C_PartyStartPanelStore, C_StoreGroup)
GroupName2Class.PartyStartPanelStore = C_PartyStartPanelStore
local M = C_PartyStartPanelStore
M.TabIndex = {
	["`\\xbb\\xae\\xbb\\xbf"] = 1,
	["/A\\x9f\\x89\\x8fD"] = 0
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.allTabDataList = {
		{
			["\\xa2\\xa2*\\xa5f7\\xf06"] = false,
			id = self.TabIndex.Single,
			tabIndex = self.TabIndex.Single,
			title = PartyConfig.SingleModeName
		},
		{
			["\\xa2\\xa2*\\xa5f7\\xf06"] = true,
			id = self.TabIndex.Multi,
			tabIndex = self.TabIndex.Multi,
			title = PartyConfig.LinkModeName
		}
	}
	self.tabDataList = {}
	self.currentTabIndex = self.TabIndex.Single
	self.topTabStore = nil
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
	self.RefreshTabIndexByCurrentMode(self)
	self.RefreshMoney(self)
	self.RefreshTopTabData(self)
	self.RefreshTabData(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshTabIndexByCurrentMode(self)
	self.RefreshMoney(self)
	self.RefreshTopTabData(self)
	self.RefreshTabData(self)
end

M.ShowPanel = function(self, args)
	self.panelArgs = args or {}
	self.panelId = self.panelArgs.panelId

	self:RefreshTabIndexByCurrentMode()
	self:RefreshMoney()
	self:RefreshTopTabData()
	self:RefreshTabData()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(gPanelId.PARTY_START_PANEL)
end

M.RefreshMoney = function(self)
	local moneyStore = self.SubGroup and self.SubGroup.MoneyTemplateStore

	if not moneyStore then
		local moneyWidget = self.bindData.money
		moneyStore = moneyWidget and moneyWidget.Store and gStoreManager:GetStoreGroup(moneyWidget.Store)
	end

	if moneyStore and moneyStore.SetData then
		moneyStore.SetData(moneyStore, MoneyType.Money)
	end
end

M.RefreshTabIndexByCurrentMode = function(self)
	self.currentTabIndex = gLinkManager:CheckInLinkMode() and self.TabIndex.Multi or self.TabIndex.Single
	self.tabDataList = {
		self.allTabDataList[self.currentTabIndex + 1]
	}
end

M.RefreshTopTabData = function(self)
	self.SubGroup.CommonTabSingleStore:SetData(self.tabDataList, nil, 0, nil, self:CreateAction("OnTopTabChanged"))
end

M.OnTopTabChanged = function(self, uList)
	local tabData = self.tabDataList[uList.selectedIndex + 1]

	if not tabData then
		return
	end

	self.SwitchTab(self, tabData.tabIndex)
end

M.SwitchTab = function(self, tabIndex)
	if self.currentTabIndex ~= tabIndex then
		return
	end

	self.currentTabIndex = tabIndex
	self.bindData.tabRect.selectedIndex = tabIndex
end

M.RefreshTabData = function(self)
	self.bindData.tabRect.selectedIndex = self.currentTabIndex or self.TabIndex.Single
end

M.OnTabRectRender = function(self, index, widget)
	self.currentTabIndex = index
	local storeName = widget and widget.Store

	if not storeName then
		return
	end

	local store = gStoreManager:GetStoreGroup(storeName)

	if not store or not store.ShowPanel then
		return
	end

	local tabData = self.allTabDataList[index + 1] or {}

	store:ShowPanel({
		tabIndex = tabData.tabIndex or index,
		isOnline = tabData.isOnline ~= true
	})
end
