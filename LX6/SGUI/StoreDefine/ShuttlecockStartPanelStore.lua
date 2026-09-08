-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShuttlecockStartPanelStore.lua
-- Decompiled from: 01342_ShuttlecockStartPanelStore.lua_f15fe34e962f.luajit

C_ShuttlecockStartPanelStore = DefClass("C_ShuttlecockStartPanelStore", C_ShuttlecockStartPanelStore, C_StoreGroup)
GroupName2Class.ShuttlecockStartPanelStore = C_ShuttlecockStartPanelStore
local M = C_ShuttlecockStartPanelStore

M.OnAwake = function(self)
end

M.OnStart = function(self)
	self.bindData.startButton.luaClick = self.CreateAction(self, "OnStartGame")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExit")

	self.InitLanguageTexts(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshScores(self)
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)
end

M.InitLanguageTexts = function(self)
end

M.RefreshScores = function(self)
	local game = gShuttlecockGameManager.currentGame

	if not game then
		return
	end

	self.bindData.lastScore.text = game.lastScore or 0
	local key = "ShuttlecockBestScore"
	local bestScore = gClientUtils.GetInt(key, 0)
	self.bindData.bestScore.text = bestScore
	local challengeCfg = game.challengeCfg

	if challengeCfg and challengeCfg.CountersDescription then
		local desc = challengeCfg.CountersDescription

		if #desc <= 0 then
			self.bindData.goalDesc.text = desc[1]
		end
	end
end

M.OnStartGame = function(self)
	local game = gShuttlecockGameManager.currentGame

	if not game or game.gameStatus ~= gBaseMiniGame.GAME_STATUS.START then
		return
	end

	game.StartGame(game)
end

M.OnExit = function(self)
	gShuttlecockGameManager:ExitGameCs()
end

M.OnDestroy = function(self)
end
