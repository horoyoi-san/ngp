C_BowlingScoreTechPanelStore = DefClass("C_BowlingScoreTechPanelStore", C_BowlingScoreTechPanelStore, C_StoreGroup)
GroupName2Class.BowlingScoreTechPanelStore = C_BowlingScoreTechPanelStore
local M = C_BowlingScoreTechPanelStore

function M:OnAwake()
	return
end

function M:OnDestroy()
	self:ClearDataSetEvents()
end

function M:OnShow(_, data)
	self:ClearPlayerScore()

	self.dataSetEvents = {
		{
			gBowlingGameManager.currentGame.gameMode.dataSet,
			"completed",
			self:CreateAction("RefreshCompleted")
		},
		{
			gBowlingGameManager.currentGame.gameMode.dataSet,
			"selectedIndex",
			self:CreateAction("OnSelected")
		},
		{
			gBowlingGameManager.currentGame.gameMode.dataSet,
			"count",
			self:CreateAction("OnCountChange")
		}
	}

	self:ClearDataSetEvents()
	self:RegisterDataSetEvents(self.dataSetEvents)
	self:PlayChallengeAnimation()
end

function M:ClearPlayerScore()
	self.bindData.S1.gameObject:SetActive(false)
	self.bindData.S2.gameObject:SetActive(false)
	self.bindData.S3.gameObject:SetActive(false)
	self.bindData.S4.gameObject:SetActive(false)
	self.bindData.S5.gameObject:SetActive(false)
	self.bindData.S6.gameObject:SetActive(false)
	self.bindData.S7.gameObject:SetActive(false)
	self.bindData.S8.gameObject:SetActive(false)
	self.bindData.S9.gameObject:SetActive(false)
	self.bindData.S10.gameObject:SetActive(false)
end

function M:PlayChallengeAnimation(count)
	count = count or 3

	gClientUtils.FinishAnimation(self.bindData.challengeAnimation, "S_vx_ui_panel_Bowling_Challenge_open")

	local animationName = nil

	if count == 3 then
		animationName = "S_vx_ui_panel_Bowling_Challenge_open"
	elseif count == 2 then
		animationName = "S_vx_ui_panel_Bowling_board3to2"
	elseif count == 1 then
		animationName = "S_vx_ui_panel_Bowling_board2to1"
	elseif count == 0 then
		animationName = "S_vx_ui_panel_Bowling_board1to0"
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.challengeAnimation, animationName)
end

function M:RefreshScoreBoardComplete(settleData)
	if not settleData then
		return
	end

	if not settleData.completedPatterns then
		return
	end

	self:RefreshScoreBoardPlayer(settleData.completedPatterns)
end

function M:RefreshScoreBoardPlayer(completedPatterns)
	if not completedPatterns then
		return
	end

	for i, succ in ipairs(completedPatterns) do
		local pn = "S" .. tostring(succ)

		if self.bindData[pn] and gClientUtils.NotNil(self.bindData[pn].gameObject) then
			self.bindData[pn].gameObject:SetActive(true)
		end
	end
end

function M:RefreshCompleted()
	if not gBowlingGameManager.currentGame.gameMode.dataSet.completed then
		return
	end

	local succ = gBowlingGameManager.currentGame.gameMode.dataSet.completed
	local pn = "S" .. tostring(succ)

	if self.bindData[pn] and gClientUtils.NotNil(self.bindData[pn].gameObject) then
		self.bindData[pn].gameObject:SetActive(true)
	end
end

function M:OnSelected()
	if gBowlingGameManager.currentGame.gameMode.dataSet.selectedIndex then
		self.bindData.selectedNode:SetActive(true)

		self.bindData.selectedControl = gBowlingGameManager.currentGame.gameMode.dataSet.selectedIndex
	end
end

function M:OnCountChange()
	self:PlayChallengeAnimation(gBowlingGameManager.currentGame.gameMode.dataSet.count)
end
