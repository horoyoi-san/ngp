-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcShopSwitchPanelStore.lua
-- Decompiled from: 00936_NpcShopSwitchPanelStore.lua_bfa425092785.luajit

C_NpcShopSwitchPanelStore = DefClass("C_NpcShopSwitchPanelStore", C_NpcShopSwitchPanelStore, C_StoreGroup)
GroupName2Class.NpcShopSwitchPanelStore = C_NpcShopSwitchPanelStore
local M = C_NpcShopSwitchPanelStore

M.DefineAllVariables = function(self)
	self.tabList = {
		{
			title = LTConfig.TextCommonTextConfig.GetConfig(74000531).Text
		},
		{
			title = LTConfig.TextScriptTextConfig.GetConfig(89901461).Text
		}
	}
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

M.OnDestroy = function(self)
	self.tabList = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	data.mode = gCommonItemManager.INVENTORY_MODE.SELL
	data.ShopSwitch = true
	self.data = data
	self.shopId = data.shopId
	local cfg = LTConfig.ShopConfig.GetConfig(self.shopId)
	self.bindData.shopName = cfg and cfg.ShopName or ""

	self.SubGroup.CommonTabSingleStore:SetSimpleData(#self.tabList, nil, , , self:CreateAction("OnTabChangeSelect"), self:CreateAction("OnRenderTabItem"))
	self.SubGroup.CommonTabSingleStore:SetSelectedIndex(0, false, false)

	self.selectIndex = 0
end

M.OnClose = function(self)
	self.data = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.switchBtnPad.luaClick = self.CreateAction(self, "OnSwitchBtnClick")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBtnBackClick")
end

M.OnTabChangeSelect = function(self, list)
	self.selectIndex = list.selectedIndex

	if self.selectIndex ~= 0 then
		gPanelManager:CheckShow(gPanelId.S_NPC_SHOP_PANEL, self.data)
	else
		gPanelManager:CheckShow(gPanelId.S_NEW_INVENTORY_PANEL_FRONT_FS, self.data)
	end
end

M.OnBtnBackClick = function(self)
	gPanelManager:Close(gPanelId.NPC_SHOP_SWITCH_PANEL)
	gPanelManager:Close(gPanelId.S_NPC_SHOP_PANEL)
	gPanelManager:Close(gPanelId.S_NEW_INVENTORY_PANEL_FRONT_FS)
end

M.OnRenderTabItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.tabList[index + 1]

	if store and data then
		store.title = data.title
	end
end

M.OnSwitchBtnClick = function(self)
	if self.selectIndex ~= 0 then
		self.SubGroup.CommonTabSingleStore:SetSelectedIndex(1, true, false)
	else
		self.SubGroup.CommonTabSingleStore:SetSelectedIndex(0, true, false)
	end
end
