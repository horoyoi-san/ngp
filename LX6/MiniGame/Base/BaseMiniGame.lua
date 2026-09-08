-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\Base\BaseMiniGame.lua
-- Decompiled from: 00582_BaseMiniGame.lua_3864e0248bc2.luajit

local LogicalHiddenCause = LX6.Units.LogicalHiddenCause
local static_props = {
	GAME_STATUS = {
		["}\\x8f\\x97\\x9c\\x93"] = 3,
		["\\xabFB"] = 3,
		["~\\x9a\\x83\\x9d\\x82"] = 2,
		["T\rS~"] = 1
	}
}
gBaseMiniGame = DefClass("BaseMiniGame", gBaseMiniGame, nil, static_props)
local BaseMiniGame = gBaseMiniGame

BaseMiniGame.ctor = function(self, args)
	self.CreateGame(self, args)
end

BaseMiniGame.CreateGame = function(self, args)
	self.gameStatus = gBaseMiniGame.GAME_STATUS.START

	self.BeforeInitialize(self)
	self.Initialize(self, args)
end

BaseMiniGame.StartGame = function(self)
end

BaseMiniGame.BeforeInitialize = function(self)
	gCS.MindPowerMgr.Instance:EnterOrLeaveMiniGameBlockMind(true)
end

BaseMiniGame.ClearHideNpcListener = function(self)
	if self.hideNpcLoadHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.UNIT_LOAD_COMPLETE, self.hideNpcLoadHandler)

		self.hideNpcLoadHandler = nil
	end
end

BaseMiniGame.GetTargetNpcUnit = function(self)
	if self.npcPid and self.npcPid == 0 then
		local npcUnit = gCS.SceneDataMgr.GetUnit(self.npcPid)

		if gCS.LuaUtils.IsBaseUnitValid(npcUnit) then
			return npcUnit
		end
	end

	local npcUnit = self.npcId and gCS.LocalUnitMgr:GetNpcByTemplateId(self.npcId) or nil

	if gCS.LuaUtils.IsBaseUnitValid(npcUnit) then
		self.npcPid = npcUnit.Pid

		return npcUnit
	end
end

BaseMiniGame.IsTargetNpcUnit = function(self, baseUnit)
	if not gCS.LuaUtils.IsBaseUnitValid(baseUnit) then
		return false
	end

	if self.npcPid and self.npcPid == 0 and baseUnit.Pid ~= self.npcPid then
		return true
	end

	return self.npcId and baseUnit.ClientData.SubType ~= self.npcId
end

BaseMiniGame.OnNpcUnitLoadComplete = function(self, _, baseUnit)
	if not self.IsTargetNpcUnit(self, baseUnit) then
		return
	end

	self.npcPid = baseUnit.Pid

	gCS.BaseUnitUtils.SetUnitLogicalHidden(baseUnit, true, LogicalHiddenCause.GamePlay)
	self.ClearHideNpcListener(self)
end

BaseMiniGame.SetPlayerUnitVisible = function(self, visible)
	gMiniGameUtils.SetPlayerUnitVisible(visible)
end

BaseMiniGame.SetSceneOtherNodesVisible = function(self, isVisible)
	if not self.npcId and not self.npcPid then
		return
	end

	self.ClearHideNpcListener(self)

	local hidden = not isVisible
	local npcUnit = self.GetTargetNpcUnit(self)

	if gCS.LuaUtils.IsBaseUnitValid(npcUnit) then
		gCS.BaseUnitUtils.SetUnitLogicalHidden(npcUnit.Pid, hidden, LogicalHiddenCause.GamePlay, hidden)
	elseif hidden then
		self.hideNpcLoadHandler = self:CreateAction(self.OnNpcUnitLoadComplete)

		gMessageManager:AddMessageListener(gEventConstants.UNIT_LOAD_COMPLETE, self.hideNpcLoadHandler)
	end

	gMessageManager:SendMessage(gEventConstants.TASK_INSTRUCTION_GPS_ACTIVE, isVisible)
end

BaseMiniGame.Initialize = function(self, _)
end

BaseMiniGame.PauseGame = function(self)
	self.gameStatus = gBaseMiniGame.GAME_STATUS.PAUSE
end

BaseMiniGame.ResumeGame = function(self)
	self.gameStatus = gBaseMiniGame.GAME_STATUS.START
end

BaseMiniGame.BeforeDestroyGame = function(self)
	self:ClearHideNpcListener()
	gCS.MindPowerMgr.Instance:EnterOrLeaveMiniGameBlockMind(false)
end

BaseMiniGame.DestroyGame = function(self)
	self.hasDestroy = true
	self.gameStatus = gBaseMiniGame.GAME_STATUS.END

	self.BeforeDestroyGame(self)
	self.CleanGame(self)
end

BaseMiniGame.FinishChallenge = function(self)
end

BaseMiniGame.CleanGame = function(self)
end

BaseMiniGame.GetResult = function(self)
	return self.isSuccess
end

BaseMiniGame.RetryGame = function(self)
	local args = self.args

	self.CleanUI(self)
	self.DestroyGame(self)
	self.CreateGame(self, args)
end

BaseMiniGame.ShowResultPanel = function(self)
	local isSuccess = self:CheckResultIsSuccess()

	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = isSuccess
	})
end

BaseMiniGame.ShowEmptyFullScreenPanel = function(self)
	gPanelManager:CheckShow(gPanelId.S_EMPTY_FULL_SCREEN_PANEL)
end

BaseMiniGame.SetActiveEmptyFullScreenPanel = function(self, isVisible)
	gPanelManager:SetActiveById(gPanelId.S_EMPTY_FULL_SCREEN_PANEL, isVisible)
end

BaseMiniGame.CheckAllModelsLoaded = function(self)
end
