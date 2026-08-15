C_VolleyballTopPanelStore = DefClass("C_VolleyballTopPanelStore", C_VolleyballTopPanelStore, C_StoreGroup)
GroupName2Class.VolleyballTopPanelStore = C_VolleyballTopPanelStore
local M = C_VolleyballTopPanelStore
local ScoreAnimClipNames = {
	"S_Vx_Volleyball_Top_ScoreMy",
	"S_Vx_Volleyball_Top_ScoreOpponent"
}

function M:OnAwake()
	self.curMyScore = 0
	self.curOpScore = 0
	self.curGame = nil
	self.curLuaGame = nil
	self.scoreAnimTimer = nil
	self.scoreAnimChangeTime = 0.66
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.bindData.myScore = 0
	self.bindData.opScore = 0
	self.bindData.myName = data.myName
	self.bindData.opName = data.opName

	if data.curGame then
		self.curGame = data.curGame
		self.curGame.TopStoreTable = self
	end

	if data.curLuaGame then
		self.curLuaGame = data.curLuaGame
		self.curLuaGame.curTopPanel = self
	end

	if data.finishCb then
		data.finishCb()
	end
end

function M:OnClose()
	return
end

function M:RefreshScore(myScore, opScore)
	if self.curMyScore < myScore then
		self:PlayScoreAnim(true)
	end

	self.curMyScore = myScore

	if self.curOpScore < opScore then
		self:PlayScoreAnim(false)
	end

	self.curOpScore = opScore
end

function M:PlayScoreAnim(isMyScore)
	self.bindData.scoreCtrl = isMyScore and 1 or 2
	local clipName = ScoreAnimClipNames[isMyScore and 1 or 2]
	local clip = self.bindData.scoreAnim:GetClip(clipName)

	if not clip then
		print_error("VolleyballTopPanel动画丢失")

		return
	end

	if self.scoreAnimTimer then
		self.scoreAnimTimer:Stop()

		self.scoreAnimTimer = nil
	end

	self.scoreTimer = Timer.New(function ()
		self.bindData.myScore = self.curMyScore
		self.bindData.opScore = self.curOpScore
		self.bindData.scoreCtrl = 0
	end, self.scoreAnimChangeTime):Start()

	self.bindData.scoreAnim:Stop()
	self.bindData.scoreAnim:Play(clipName)
	self.bindData.showAnim:Stop()
	self.bindData.showAnim:Play()
end
