-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingScoreTechPanelStore.lua
-- Decompiled from: 01650_BowlingScoreTechPanelStore.lua_e1b604a19ec7.luajit

C_BowlingScoreTechPanelStore = DefClass("C_BowlingScoreTechPanelStore", C_BowlingScoreTechPanelStore, C_StoreGroup)
GroupName2Class.BowlingScoreTechPanelStore = C_BowlingScoreTechPanelStore
local M = C_BowlingScoreTechPanelStore

M.OnAwake = function(self)
	self.RegisterSingleEvent(self, gEventConstants.BOWLING_GAME_SWITCH_PANEL_ACTIVE, self.CreateAction(self, "OnActive"))
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
	self.ClearDataSetEvents(self)
end

M.OnShow = function(self, _, data)
	self.ClearPlayerScore(self)

	self.game = gBowlingGameManager.currentGame
	self.gameMode = self.game.gameMode
	self.dataSetEvents = {
		{
			self.gameMode.dataSet,
			"@HayB<",
			self.CreateAction(self, "RefreshCompleted")
		},
		{
			self.gameMode.dataSet,
			"\\xe6S)\t\\xc4\\xb2h\\xafR\\xb5\\xae",
			self.CreateAction(self, "OnSelected")
		}
	}

	self.ClearDataSetEvents(self)
	self.RegisterDataSetEvents(self, self.dataSetEvents)
	self.PlayChallengeAnimation(self, 3)
end

M.ClearPlayerScore = function(self)
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

M.PlayChallengeAnimation = function(self, count)
	if count ~= self.bindData.currentCount then
		return
	end

	self.bindData.currentCount = count
	local animationName = nil

	if count ~= 3 then
		animationName = "S_vx_ui_panel_Bowling_Challenge_open"
	elseif count ~= 2 then
		animationName = "S_vx_ui_panel_Bowling_board3to2"
	elseif count ~= 1 then
		animationName = "S_vx_ui_panel_Bowling_board2to1"
	elseif count ~= 0 then
		animationName = "S_vx_ui_panel_Bowling_board1to0"
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.challengeAnimation, animationName)
end

M.RefreshScoreBoardComplete = function(self, settleData)
	if not settleData then
		return
	end

	if not settleData.completedPatterns then
		return
	end

	self.RefreshScoreBoardPlayer(self, settleData.completedPatterns)
end

M.RefreshScoreBoardPlayer = function(self, completedPatterns)
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

M.RefreshCompleted = function(self)
	if not self.gameMode.dataSet.completed then
		return
	end

	local succ = self.gameMode.dataSet.completed
	local pn = "S" .. tostring(succ)

	if self.bindData[pn] and gClientUtils.NotNil(self.bindData[pn].gameObject) then
		self.bindData[pn].gameObject:SetActive(true)
	end
end

M.OnSelected = function(self)
	if self.gameMode.dataSet.selectedIndex then
		self.bindData.selectedNode:SetActive(true)

		self.bindData.selectedControl = self.gameMode.dataSet.selectedIndex
	end
end

M.OnActive = function(self, _, active)
	if active then
		self.rootGo:SetActive(true)
	else
		self.rootGo:SetActive(false)
	end

	self.PlayChallengeAnimation(self, self.gameMode.dataSet.count)
end
