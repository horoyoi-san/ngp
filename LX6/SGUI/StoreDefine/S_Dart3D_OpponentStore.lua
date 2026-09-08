-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_Dart3D_OpponentStore.lua
-- Decompiled from: 01391_S_Dart3D_OpponentStore.lua_81960bbbb6e6.luajit

C_S_Dart3D_OpponentStore = DefClass("C_S_Dart3D_OpponentStore", C_S_Dart3D_OpponentStore, C_StoreGroup)
GroupName2Class.S_Dart3D_OpponentStore = C_S_Dart3D_OpponentStore
local M = C_S_Dart3D_OpponentStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.BtnInfo.luaClick = self.CreateAction(self, "OnBtnInfo")
	self.bindData.BtnEasy.luaClick = self.CreateAction(self, "OnBtnEasy")
	self.bindData.BtnNormal.luaClick = self.CreateAction(self, "OnBtnNormal")
	self.bindData.BtnHard.luaClick = self.CreateAction(self, "OnBtnHard")
	self.bindData.BtnMaster.luaClick = self.CreateAction(self, "OnBtnMaster")
end

M.OnEnable = function(self)
	gDartsGameManager:ShowOrHideQuad(false)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	gDartsGameManager:ShowOrHideQuad(true)
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

M.OnBtnInfo = function(self, btn)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_InfoStorePanel, gPanelId.S_Dart3D_OpponentStorePanel)
end

M.OnBtnEasy = function(self)
	self.SetHardLevelAndShowNext(self, 100)
end

M.OnBtnNormal = function(self)
	self.SetHardLevelAndShowNext(self, 101)
end

M.OnBtnHard = function(self)
	self.SetHardLevelAndShowNext(self, 102)
end

M.OnBtnMaster = function(self)
	self.SetHardLevelAndShowNext(self, 103)
end

M.SetHardLevelAndShowNext = function(self, aiConfigId)
	gDartsGameManager:SetAiConfig(aiConfigId)
	gDartsGameManager.currentDartsGame:ShowPanelByPanelId(gPanelId.S_Dart3D_ChoiceStorePanel)
end
