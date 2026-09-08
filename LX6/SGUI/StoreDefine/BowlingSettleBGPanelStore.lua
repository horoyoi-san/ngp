-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingSettleBGPanelStore.lua
-- Decompiled from: 01620_BowlingSettleBGPanelStore.lua_530231b2ec30.luajit

C_BowlingSettleBGPanelStore = DefClass("C_BowlingSettleBGPanelStore", C_BowlingSettleBGPanelStore, C_StoreGroup)
GroupName2Class.BowlingSettleBGPanelStore = C_BowlingSettleBGPanelStore
local M = C_BowlingSettleBGPanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
	print_debug("BowlingSettleBGPanelStore OnStart:1")

	self.bindData.btnExit.luaClick = self.CreateAction(self, "OnExit")
	self.bindData.btnRetry.luaClick = self.CreateAction(self, "OnRetry")
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.score = data.score
	self.bestScore = data.bestScore
	self.allScores = data.allScores
	self.exitCallback = data.exitCallback
	self.retryCallback = data.retryCallback
	self.coroutineAutoExit = coroutine.start(function ()
		coroutine.wait(2.6)
		gBowlingGameManager:ExecuteExitGame()
	end)
end

M.OnClose = function(self)
	self.coroutineAutoExit = coroutine.stop(self.coroutineAutoExit)
end

M.OnRetry = function(self)
	self.retryCallback()
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SETTLE_BG_PANEL)
end

M.OnExit = function(self)
	self.exitCallback()
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SETTLE_BG_PANEL)
end
