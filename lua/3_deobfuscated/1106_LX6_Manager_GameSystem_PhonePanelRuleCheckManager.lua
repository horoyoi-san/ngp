C_PhonePanelRuleCheckManager = DefClass("C_PhonePanelRuleCheckManager", C_PhonePanelRuleCheckManager, nil, nil)
local M = C_PhonePanelRuleCheckManager
local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig

function M:ctor()
	self:InitData()
end

function M:ExecuteStateLogic()
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("ExecuteStateLogic")
	end

	if not gGmUtils.isForceOpenMainPhonePanel then
		self:ProcessPanelStateChange()
		self:ProcessQueue()
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:ProcessPanelStateChange()
	for i = 0, LTConfig.PhonePanelConfig.count - 1 do
		local phonePanelCfg = LTConfig.PhonePanelConfig.LoadAt(i)
		local panelId = phonePanelCfg.Id

		if gPanelManager:IsPanelShowing(panelId) then
			if self:CheckPanelContact(panelId) then
				gPanelManager:Close(panelId)
			else
				local actionConflictId = self:CheckActionConflict(panelId)
				local actionConflictCfg = LTConfig.PhonePanelActionConflictConfig.GetConfig(actionConflictId)

				if actionConflictCfg and actionConflictCfg.FunctionStartType == gClientConst.PHONE_PANEL_FUNCTION_START_TYPE.Forbid then
					local noticeMessage = ("ProcessPanelStateChange panelId:%d, actionConflict Id:%d"):format(panelId, actionConflictId)

					print_debug(noticeMessage)
					gPanelManager:Close(panelId)
				end
			end
		end
	end
end

function M:CheckSpecialRuleIgnoreConflict(panelId, actionConflictId)
	if gClientUtils.CheckIsMainPhonePanelId(panelId) and actionConflictId == LTConfig.PhonePanelActionConflictConfig.Dialog and table.find(LTConfig.PhonePanelConfig.IgnoreConflictDialogTypeList, gDialogManager:GetFirstDialogType()) then
		return true
	end
end

function M:ProcessQueue()
	local panelInfo = self.popUpQueue:Peek()

	if panelInfo then
		local actionConflictId = self:GetActionConflictId(panelInfo.panelId)

		if not actionConflictId then
			self.popUpQueue:Pop()
			gPanelManager:CheckShow(panelInfo.panelId, panelInfo.args)
		end
	end
end

function M:PushQueue(panelId, args)
	self.popUpQueue:Push({
		panelId = panelId,
		args = args
	})
end

function M:InitData()
	self.popUpQueue = self.popUpQueue or gDataStructureUtils.GetQueue()

	self:InitActionCheckFunctions()
	self:InitMessages()
end

function M:InitMessages()
	local eventHandlers = {
		[gEventConstants.DIALOG_START] = function ()
			self:ExecuteStateLogic()
		end,
		[gEventConstants.PAOKU_STATE_CHANGE] = function ()
			self:ExecuteStateLogic()
		end,
		[gEventConstants.PANEL_ON_SHOW] = function ()
			self:ExecuteStateLogic()
		end
	}

	gMessageManager:RegisterEventHandlers(eventHandlers)
end

function M:CheckPanelContact(panelId)
	local phonePanelCfg = LTConfig.PhonePanelConfig.GetConfig(panelId)

	if phonePanelCfg then
		local conflictPanelIdList = self:GetConflictPanelIdList()

		for _, conflictPanelId in ipairs(conflictPanelIdList) do
			if gPanelManager:IsPanelVisible(conflictPanelId) then
				return true
			end
		end
	end
end

function M:GetConflictPanelIdList()
	return {
		gPanelId.S_PHONE_CALL_IN_PANEL,
		gPanelId.S_CHALLENGE_STATEMENT_PANEL,
		gPanelId.S_CHALLENGE_ENDING_PANEL,
		gPanelId.PARTY_END_PANEL
	}
end

function M:CheckActionConflict(panelId)
	local actionConflictId = self:GetActionConflictId(panelId)

	if self:CheckSpecialRuleIgnoreConflict(panelId, actionConflictId) then
		return nil
	end

	return actionConflictId
end

function M:GetActionConflictId(panelId)
	local phonePanelCfg = LTConfig.PhonePanelConfig.GetConfig(panelId)

	if phonePanelCfg then
		for i = 0, LTConfig.PhonePanelActionConflictConfig.count - 1 do
			local actionConflictCfg = LTConfig.PhonePanelActionConflictConfig.LoadAt(i)
			local actionCheckFunction = self.actionCheckFunctions[actionConflictCfg.Id]

			if actionCheckFunction() then
				if phonePanelCfg.Type == gClientConst.PHONE_PANEL_TYPE.Function then
					if actionConflictCfg.FunctionStartType == gClientConst.PHONE_PANEL_FUNCTION_START_TYPE.Forbid then
						return actionConflictCfg.Id
					end
				elseif phonePanelCfg.Type == gClientConst.PHONE_PANEL_TYPE.Performance then
					if actionConflictCfg.PerformStartType == gClientConst.PHONE_PANEL_PERFORM_START_TYPE.Forbid then
						return actionConflictCfg.Id
					end

					if actionConflictCfg.PerformStartType == gClientConst.PHONE_PANEL_PERFORM_START_TYPE.Wait then
						return actionConflictCfg.Id
					end
				end
			end
		end
	end
end

function M:CheckPanelCanShow(panelId, args)
	if gGmUtils.isForceOpenMainPhonePanel then
		return true
	end

	if gClientUtils.CheckMainPhoneHalfScreenEnable() then
		if self:CheckPanelContact(panelId) then
			self:HandleConflict(panelId, args)

			return false
		end

		local actionConflictId = self:CheckActionConflict(panelId)

		if actionConflictId then
			local actionConflictCfg = LTConfig.PhonePanelActionConflictConfig.GetConfig(actionConflictId)

			if actionConflictCfg.PerformStartType == gClientConst.PHONE_PANEL_PERFORM_START_TYPE.Wait then
				self:HandleConflict(panelId, args)
			end

			return false
		end
	end

	return true
end

function M:HandleConflict(panelId, args)
	local phonePanelCfg = LTConfig.PhonePanelConfig.GetConfig(panelId)

	if phonePanelCfg.Type == gClientConst.PHONE_PANEL_TYPE.Performance then
		self:PushQueue(panelId, args)
	end
end

function M:IsRunState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.Walk or state == ActionTransitionRuleTypesConfig.ParkourStateType.Run or state == ActionTransitionRuleTypesConfig.ParkourStateType.Rush
end

function M:IsSwingState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.Swing or state == ActionTransitionRuleTypesConfig.ParkourStateType.SwingOut
end

function M:IsFallState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.Fall
end

function M:IsClimbState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbRun or state == ActionTransitionRuleTypesConfig.ParkourStateType.ClimbSlow
end

function M:IsIdleState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.Idle or state == ActionTransitionRuleTypesConfig.ParkourStateType.ShowAction
end

function M:IsOnlyWalkState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.Walk
end

function M:IsOnlyRunState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.Run
end

function M:IsOnlyRushState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.Rush
end

function M:IsJumpState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.Jump
end

function M:IsFeiSuoState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.Feisuo
end

function M:IsSitState(state)
	return state == ActionTransitionRuleTypesConfig.ParkourStateType.Sit
end

function M:InitActionCheckFunctions()
	self.actionCheckFunctions = {
		[LTConfig.PhonePanelActionConflictConfig.Fight] = function ()
			return gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.FightS)
		end,
		[LTConfig.PhonePanelActionConflictConfig.Driver] = function ()
			return gCS.DriveManager.isDriveMode
		end,
		[LTConfig.PhonePanelActionConflictConfig.Dialog] = function ()
			if gCallPhoneUtils.CheckPhoneCallConflict() then
				return true
			end

			if gDialogManager:IsDialogRunning() then
				if table.find(LTConfig.PhonePanelConfig.IgnoreConflictDialogTypeList, gDialogManager:GetFirstDialogType()) then
					return false
				end

				if table.find(LTConfig.PhoneConfig.IgnoreAutoClosePhoneDialogIdList, gDialogManager:GetFirstDialogId()) then
					return false
				end

				return true
			end

			return false
		end,
		[LTConfig.PhonePanelActionConflictConfig.Idle] = function ()
			local state = gCS.PaoKuManager.ParkourStateLua

			return self:IsIdleState(state)
		end,
		[LTConfig.PhonePanelActionConflictConfig.Sit] = function ()
			local state = gCS.PaoKuManager.ParkourStateLua

			return self:IsSitState(state)
		end,
		[LTConfig.PhonePanelActionConflictConfig.Walk] = function ()
			local state = gCS.PaoKuManager.ParkourStateLua

			return self:IsOnlyWalkState(state)
		end,
		[LTConfig.PhonePanelActionConflictConfig.Run] = function ()
			local state = gCS.PaoKuManager.ParkourStateLua

			return self:IsOnlyRunState(state)
		end,
		[LTConfig.PhonePanelActionConflictConfig.Rush] = function ()
			local state = gCS.PaoKuManager.ParkourStateLua

			return self:IsOnlyRushState(state)
		end,
		[LTConfig.PhonePanelActionConflictConfig.Climb] = function ()
			local state = gCS.PaoKuManager.ParkourStateLua

			return self:IsClimbState(state)
		end,
		[LTConfig.PhonePanelActionConflictConfig.Swing] = function ()
			local state = gCS.PaoKuManager.ParkourStateLua

			return self:IsSwingState(state)
		end,
		[LTConfig.PhonePanelActionConflictConfig.Jump] = function ()
			local state = gCS.PaoKuManager.ParkourStateLua

			return self:IsJumpState(state)
		end,
		[LTConfig.PhonePanelActionConflictConfig.FeiSuo] = function ()
			local state = gCS.PaoKuManager.ParkourStateLua

			return self:IsFeiSuoState(state)
		end
	}
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.popUpQueue:Clear()

		gCallPhoneUtils.multiMoveStatus = 0
	end
end

gPhonePanelRuleCheckManager = gPhonePanelRuleCheckManager or C_PhonePanelRuleCheckManager.new()
