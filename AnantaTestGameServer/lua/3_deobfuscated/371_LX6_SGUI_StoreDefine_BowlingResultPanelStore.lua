C_BowlingResultPanelStore = DefClass("C_BowlingResultPanelStore", C_BowlingResultPanelStore, C_StoreGroup)
GroupName2Class.BowlingResultPanelStore = C_BowlingResultPanelStore
local M = C_BowlingResultPanelStore

function M:OnAwake()
	return
end

function M:OnDestroy()
	return
end

function M:OnStart()
	self.bindData.btnExit.luaClick = self:CreateAction("OnExit")
	self.bindData.btnRetry.luaClick = self:CreateAction("OnRetry")
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	print_debug("BowlingResultPanelStore OnShow:1")

	self.score = data.score
	self.bestScore = data.bestScore
	self.allScores = data.allScores
	self.exitCallback = data.exitCallback
	self.retryCallback = data.retryCallback

	self:refreshPanel()
end

function M:OnClose()
	return
end

function M:refreshPanel()
	self.bindData.LabelNpc.gameObject:SetActive(false)

	self.bindData.txtScore.text = LTConfig.TextScriptTextConfig.GetConfig(89900322).Text:format(self.score)
	self.bindData.txtBest.text = self.bestScore

	if self.allScores and #self.allScores >= 2 then
		self.bindData.scoreNpc.text = LTConfig.TextScriptTextConfig.GetConfig(89900322).Text:format(self.allScores[2])

		self.bindData.LabelNpc.gameObject:SetActive(true)
	end
end

function M:OnRetry()
	self.retryCallback()
end

function M:OnExit()
	self.exitCallback()
end
