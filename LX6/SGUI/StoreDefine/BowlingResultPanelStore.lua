-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingResultPanelStore.lua
-- Decompiled from: 01683_BowlingResultPanelStore.lua_71f70c421cbb.luajit

C_BowlingResultPanelStore = DefClass("C_BowlingResultPanelStore", C_BowlingResultPanelStore, C_StoreGroup)
GroupName2Class.BowlingResultPanelStore = C_BowlingResultPanelStore
local M = C_BowlingResultPanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
	self.bindData.btnExit.luaClick = self.CreateAction(self, "OnExit")
	self.bindData.btnRetry.luaClick = self.CreateAction(self, "OnRetry")
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	print_debug("BowlingResultPanelStore OnShow:1")

	self.score = data.score
	self.bestScore = data.bestScore
	self.allScores = data.allScores
	self.exitCallback = data.exitCallback
	self.retryCallback = data.retryCallback

	self.refreshPanel(self)
end

M.OnClose = function(self)
end

M.refreshPanel = function(self)
	self.bindData.LabelNpc.gameObject:SetActive(false)

	self.bindData.txtScore.text = LTConfig.TextScriptTextConfig.GetConfig(89900322).Text:format(self.score)
	self.bindData.txtBest.text = self.bestScore

	if self.allScores and #self.allScores > 2 then
		self.bindData.scoreNpc.text = LTConfig.TextScriptTextConfig.GetConfig(89900322).Text:format(self.allScores[2])

		self.bindData.LabelNpc.gameObject:SetActive(true)
	end
end

M.OnRetry = function(self)
	self.retryCallback()
end

M.OnExit = function(self)
	self.exitCallback()
end
