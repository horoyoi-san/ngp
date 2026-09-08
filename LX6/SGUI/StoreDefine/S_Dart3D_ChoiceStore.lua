-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_Dart3D_ChoiceStore.lua
-- Decompiled from: 01385_S_Dart3D_ChoiceStore.lua_7a43905b9443.luajit

C_S_Dart3D_ChoiceStore = DefClass("C_S_Dart3D_ChoiceStore", C_S_Dart3D_ChoiceStore, C_StoreGroup)
GroupName2Class.S_Dart3D_ChoiceStore = C_S_Dart3D_ChoiceStore
local M = C_S_Dart3D_ChoiceStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.BtnMode01.luaClick = self.CreateAction(self, "OnBtnMode01")
	self.bindData.BtnModeHighScore.luaClick = self.CreateAction(self, "OnBtnModeHighScore")
	self.bindData.BtnInfo.luaClick = self.CreateAction(self, "OnBtnInfo")
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
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoConfirmAISetting()
	end
end

M.OnClose = function(self)
end

M.OnBtnMode01 = function(self, btn)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_ModeStorePanel)
end

M.OnBtnModeHighScore = function(self, btn, itemData)
	gDartsGameManager.currentDartsGame:SetModeAndOpenSelectPanel(1)
end

M.OnBtnInfo = function(self, btn)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_InfoStorePanel, gPanelId.S_Dart3D_ChoiceStorePanel)
end
