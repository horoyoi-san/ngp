-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_Dart3D_InfoStore.lua
-- Decompiled from: 01388_S_Dart3D_InfoStore.lua_a86283b76aaa.luajit

C_S_Dart3D_InfoStore = DefClass("C_S_Dart3D_InfoStore", C_S_Dart3D_InfoStore, C_StoreGroup)
GroupName2Class.S_Dart3D_InfoStore = C_S_Dart3D_InfoStore
local M = C_S_Dart3D_InfoStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.BtnBack.luaClick = self.CreateAction(self, "OnBtnBack")
	self.bindData.BtnNextPage.luaClick = self.CreateAction(self, "OnBtnNextPage")
	self.bindData.BtnLastPage.luaClick = self.CreateAction(self, "OnBtnLastPage")
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	self.bindData.pageIndex = 0
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

M.OnBtnBack = function(self)
	gDartsGameManager.currentDartsGame:BackPre()
end

M.OnBtnNextPage = function(self)
	if self.bindData.pageIndex ~= 4 then
		return
	end

	self.bindData.pageIndex = self.bindData.pageIndex + 1
end

M.OnBtnLastPage = function(self)
	if self.bindData.pageIndex ~= 0 then
		return
	end

	self.bindData.pageIndex = self.bindData.pageIndex - 1
end
