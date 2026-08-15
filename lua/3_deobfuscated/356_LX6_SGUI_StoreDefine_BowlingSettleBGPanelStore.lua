C_BowlingSettleBGPanelStore = DefClass("C_BowlingSettleBGPanelStore", C_BowlingSettleBGPanelStore, C_StoreGroup)
GroupName2Class.BowlingSettleBGPanelStore = C_BowlingSettleBGPanelStore
local M = C_BowlingSettleBGPanelStore

function M:OnAwake()
	return
end

function M:OnDestroy()
	return
end

function M:OnStart()
	print_debug("BowlingSettleBGPanelStore OnStart:1")

	self.bindData.btnExit.luaClick = self:CreateAction("OnExit")
	self.bindData.btnRetry.luaClick = self:CreateAction("OnRetry")

	if not self.titleTxt then
		self.titleTxt = LTConfig.TextScriptTextConfig.GetConfig(89901324).Text
	end

	self:RefreshTitle()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.score = data.score
	self.bestScore = data.bestScore
	self.allScores = data.allScores
	self.exitCallback = data.exitCallback
	self.retryCallback = data.retryCallback

	if data.title then
		self.titleTxt = data.title

		self:RefreshTitle()
	end

	self.coroutineAutoExit = coroutine.start(function ()
		coroutine.wait(2.6)
		gBowlingGameManager:ExecuteExitGame()
	end)
end

function M:OnClose()
	self.coroutineAutoExit = coroutine.stop(self.coroutineAutoExit)
end

function M:OnRetry()
	self.retryCallback()
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SETTLE_BG_PANEL)
end

function M:OnExit()
	self.exitCallback()
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SETTLE_BG_PANEL)
end

function M:RefreshTitle()
	return
end
