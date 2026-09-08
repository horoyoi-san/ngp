-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_Dart3D_ModeStore.lua
-- Decompiled from: 01390_S_Dart3D_ModeStore.lua_e3e736908680.luajit

C_S_Dart3D_ModeStore = DefClass("C_S_Dart3D_ModeStore", C_S_Dart3D_ModeStore, C_StoreGroup)
GroupName2Class.S_Dart3D_ModeStore = C_S_Dart3D_ModeStore
local M = C_S_Dart3D_ModeStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.Btn301.luaClick = self.CreateAction(self, "OnBtn301")
	self.bindData.Btn501.luaClick = self.CreateAction(self, "OnBtn501")
	self.bindData.Btn701.luaClick = self.CreateAction(self, "OnBtn701")
	self.bindData.Btn901.luaClick = self.CreateAction(self, "OnBtn901")
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

M.OnExitBtn = function(self, btn)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_OpponentStorePanel)
end

M.OnBtn301 = function(self, btn)
	gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(2, 301)
end

M.OnBtn501 = function(self, btn, itemData)
	gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(2, 501)
end

M.OnBtn701 = function(self, btn, itemData)
	gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(2, 701)
end

M.OnBtn901 = function(self, btn, itemData)
	gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(2, 901)
end

M.OnBtnInfo = function(self, btn)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_InfoStorePanel, gPanelId.S_Dart3D_ModeStorePanel)
end
