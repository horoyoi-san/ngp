-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GamePlayBattlePassPanelStore.lua
-- Decompiled from: 01737_GamePlayBattlePassPanelStore.lua_9f67766f826d.luajit

C_GamePlayBattlePassPanelStore = DefClass("C_GamePlayBattlePassPanelStore", C_GamePlayBattlePassPanelStore, C_StoreGroup)
GroupName2Class.GamePlayBattlePassPanelStore = C_GamePlayBattlePassPanelStore
local M = C_GamePlayBattlePassPanelStore

M.ctor = function(self)
	self.bpId = nil
	self.curTabStore = nil
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	if self.curTabStore then
		self.curTabStore:OnClose()

		self.curTabStore = nil
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if not data or not data.BpId then
		print_error("[GamePlayBP] OnShow: bpId is nil")

		return
	end

	self.bpId = data.BpId
	self.bindData.tabRect.selectedIndex = 0
end

M.OnClose = function(self)
	if self.curTabStore then
		self.curTabStore:OnClose()

		self.curTabStore = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
end

M.OnClickCloseBtn = function(self)
	if self.curTabIndex and self.curTabIndex == 0 then
		self.SwitchPage(self, 0)
	else
		gPanelManager:Close(gPanelId.GAMEPLAY_BATTLE_PASS_PANEL)
	end
end

M.OnTabRectRender = function(self, index, widget)
	self.curTabIndex = index

	if self.curTabStore then
		self.curTabStore:OnClose()
	end

	self.curTabStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTabStore then
		self.curTabStore.parentStore = self

		self.curTabStore:OnShow(self.bpId)
	end
end

M.SwitchPage = function(self, index)
	self.bindData.tabRect.selectedIndex = index
end
