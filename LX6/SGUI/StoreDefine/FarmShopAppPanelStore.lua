-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FarmShopAppPanelStore.lua
-- Decompiled from: 01879_FarmShopAppPanelStore.lua_7b68d678afe1.luajit

C_FarmShopAppPanelStore = DefClass("C_FarmShopAppPanelStore", C_FarmShopAppPanelStore, C_StoreGroup)
GroupName2Class.FarmShopAppPanelStore = C_FarmShopAppPanelStore
local M = C_FarmShopAppPanelStore

M.ctor = function(self)
	self.currentPage = gFarmerManager.APP_PAGE.HOME
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
	slot3 = gFarmerManager

	slot3:RegisterPanelStore(self)

	slot3 = self.SubGroup.MoneyTemplateStore

	slot3:SetData(LTConfig.FarmConfig.FarmCurrency)
	self:SwitchToPage(gFarmerManager.APP_PAGE.HOME)

	slot3 = gClientToGameDelegate

	slot3:AskOpenFarmerShopApp().Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			print_error("打开农场商店界面失败，错误码：", err, gCS.Error.GetNameById(err))
		end
	end
end

M.OnClose = function(self)
	slot1 = gFarmerManager

	slot1:UnregisterPanelStore()

	slot1 = self.bindData.mainTab

	slot1:SelectIndexWithClose(-1)

	slot1 = gPanelManager

	slot1:Close(gPanelId.FARM_INVENTORY_PANEL)

	slot1 = gClientToGameDelegate

	slot1:AskCloseFarmerShopApp().Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			print_error("关闭农场商店界面失败，错误码：", err, gCS.Error.GetNameById(err))
		end
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.mainTab.OnRenderTab = self.CreateAction(self, self.OnRenderMainTab)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
end

M.SwitchToPage = function(self, pageIndex)
	self.bindData.mainTab.selectedIndex = pageIndex
end

M.OnRenderMainTab = function(self, index, widget)
	self.currentPage = index
	local store = gStoreManager:GetStoreGroup(widget.Store)

	if store and store.ShowPanel then
		store.ShowPanel(store)
	end
end

M.OnClickBackBtn = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.FARM_INVENTORY_PANEL) then
		gPanelManager:Close(gPanelId.FARM_INVENTORY_PANEL)

		return
	end

	if self.currentPage ~= gFarmerManager.APP_PAGE.HOME then
		gPanelManager:Close(gPanelId.FARM_SHOP_APP_PANEL)
	else
		self.SwitchToPage(self, gFarmerManager.APP_PAGE.HOME)
	end
end
