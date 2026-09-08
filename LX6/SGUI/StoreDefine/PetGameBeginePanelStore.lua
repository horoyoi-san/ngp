-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameBeginePanelStore.lua
-- Decompiled from: 01089_PetGameBeginePanelStore.lua_48269e8cc7d2.luajit

C_PetGameBeginePanelStore = DefClass("C_PetGameBeginePanelStore", C_PetGameBeginePanelStore, C_StoreGroup)
GroupName2Class.PetGameBeginePanelStore = C_PetGameBeginePanelStore
local M = C_PetGameBeginePanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
	self.bindData.beginBtn.luaClick = self.CreateAction(self, "OnBtnStartClick")
	self.bindData.menuBtn.luaClick = self.CreateAction(self, "OnMenuBtnClick")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnConfirmBtnClick")
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnBtnStartClick = function(self)
	self.EnterGame(self)
end

M.OnMenuBtnClick = function(self)
	self.EnterGame(self)
end

M.OnConfirmBtnClick = function(self)
	self.EnterGame(self)
end

M.EnterGame = function(self)
	gPanelManager:Close(self.m_Id)
	gPetGameManager:StartContinue()
end
