-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_Dart3D_GameStartStore.lua
-- Decompiled from: 01386_S_Dart3D_GameStartStore.lua_b94c758f97f6.luajit

C_S_Dart3D_GameStartStore = DefClass("C_S_Dart3D_GameStartStore", C_S_Dart3D_GameStartStore, C_StoreGroup)
GroupName2Class.S_Dart3D_GameStartStore = C_S_Dart3D_GameStartStore
local M = C_S_Dart3D_GameStartStore

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
	local playModeDetail = gDartsGameManager.currentDartsGame.playModeDetail

	if playModeDetail ~= 1 then
		self.bindData.gameType = 4
	elseif playModeDetail ~= 2 then
		self.bindData.gameType = 0
	elseif playModeDetail ~= 3 then
		self.bindData.gameType = 1
	elseif playModeDetail ~= 4 then
		self.bindData.gameType = 2
	end

	if self.bindData.anim then
		if playModeDetail ~= 1 then
			self.bindData.anim:Play("S_Dart3D_GameBgStart")
		else
			self.bindData.anim:Play("S_Dart3D_GameBgOpen")
		end
	end
end

M.OnClose = function(self)
end
