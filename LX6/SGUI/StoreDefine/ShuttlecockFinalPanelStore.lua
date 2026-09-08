-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShuttlecockFinalPanelStore.lua
-- Decompiled from: 01328_ShuttlecockFinalPanelStore.lua_4641ca5c88d4.luajit

C_ShuttlecockFinalPanelStore = DefClass("C_ShuttlecockFinalPanelStore", C_ShuttlecockFinalPanelStore, C_StoreGroup)
GroupName2Class.ShuttlecockFinalPanelStore = C_ShuttlecockFinalPanelStore
local M = C_ShuttlecockFinalPanelStore

M.OnAwake = function(self)
end

M.OnStart = function(self)
	if self.bindData.restartButton then
		self.bindData.restartButton.luaClick = self.CreateAction(self, "OnRestart")
	end

	if self.bindData.exitButton then
		self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExit")
	end
end

M.OnShow = function(self, panelId, data)
	if not data then
		return
	end

	self.bindData.score.text = data.score or 0
	self.bindData.gainPoint.text = data.gainPoint or 0
end

M.OnClose = function(self)
end

M.OnRestart = function(self)
	local game = gShuttlecockGameManager.currentGame

	if not game then
		return
	end

	slot2 = gClientToGameDelegate

	slot2:StartNewChallenge(game.challengeId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowServerMessage(err)

			return
		end

		game:StartGame()
		gPanelManager:Close(gPanelId.MINI_GAMES_SHUTTLECOCK_FINAL_PANEL)
		gPanelManager:Preload(gPanelId.MINI_GAMES_SHUTTLECOCK_FINAL_PANEL)
	end
end

M.OnExit = function(self)
	gPanelManager:Close(self.m_Id)
	gShuttlecockGameManager:ExitGameCs()
end

M.OnDestroy = function(self)
end
