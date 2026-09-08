-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_Dart3D_GameTypeStore.lua
-- Decompiled from: 01387_S_Dart3D_GameTypeStore.lua_c1e972d7ffd4.luajit

C_S_Dart3D_GameTypeStore = DefClass("C_S_Dart3D_GameTypeStore", C_S_Dart3D_GameTypeStore, C_StoreGroup)
GroupName2Class.S_Dart3D_GameTypeStore = C_S_Dart3D_GameTypeStore
local M = C_S_Dart3D_GameTypeStore

M.ctor = function(self)
end

M.OnAwake = function(self)
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
	self.bindData.myNameText.text = gDartsGameManager.currentDartsGame.playerList[1].playerName
	self.bindData.otherNameText.text = gDartsGameManager.currentDartsGame.playerList[2].playerName

	if gDartsGameManager.currentDartsGame.playModeDetail ~= 1 then
		self.bindData.gameType = 4
	elseif gDartsGameManager.currentDartsGame.playModeDetail ~= 2 then
		self.bindData.gameType = 0
	elseif gDartsGameManager.currentDartsGame.playModeDetail ~= 3 then
		self.bindData.gameType = 1
	elseif gDartsGameManager.currentDartsGame.playModeDetail ~= 4 then
		self.bindData.gameType = 2
	end
end

M.OnClose = function(self)
end
