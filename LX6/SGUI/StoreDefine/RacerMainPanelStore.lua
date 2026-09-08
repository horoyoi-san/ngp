-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RacerMainPanelStore.lua
-- Decompiled from: 00894_RacerMainPanelStore.lua_2d601e3684a0.luajit

C_RacerMainPanelStore = DefClass("C_RacerMainPanelStore", C_RacerMainPanelStore, C_StoreGroup)
GroupName2Class.RacerMainPanelStore = C_RacerMainPanelStore
local M = C_RacerMainPanelStore

M.ctor = function(self)
	self.currentPage = gRacerManager.APP_PAGE.HOME
	self.currentPageStore = nil
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
	gRacerManager:RegisterPanelStore(self)

	local gotoPage = data and data.gotoPage or gRacerManager.APP_PAGE.HOME

	self:SwitchToPage(gotoPage)
end

M.OnClose = function(self)
	gRacerManager:UnregisterPanelStore()
	self.bindData.mainTab:SelectIndexWithClose(-1)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.mainTab.OnRenderTab = self.CreateAction(self, self.OnMainTabRender)
end

M.SwitchToPage = function(self, pageIndex)
	self.bindData.mainTab.selectedIndex = pageIndex
end

M.OnMainTabRender = function(self, index, widget)
	self.currentPage = index
	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.currentPageStore = store

	if store and store.ShowPanel then
		store.ShowPanel(store)
	end
end

M.OnRacingInfoUpdated = function(self)
	if self.currentPageStore and self.currentPageStore.ShowPanel then
		self.currentPageStore:ShowPanel()
	end
end

M.OnClickBackBtn = function(self)
	if self.currentPage ~= gRacerManager.APP_PAGE.HOME then
		gPanelManager:Close(gPanelId.RACER_MAIN_PANEL)
	else
		self.SwitchToPage(self, gRacerManager.APP_PAGE.HOME)
	end
end
