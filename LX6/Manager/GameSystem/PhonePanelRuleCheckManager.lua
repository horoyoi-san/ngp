-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\PhonePanelRuleCheckManager.lua
-- Decompiled from: 02197_PhonePanelRuleCheckManager.lua_9b289e763dee.luajit

C_PhonePanelRuleCheckManager = DefClass("C_PhonePanelRuleCheckManager", C_PhonePanelRuleCheckManager, nil, )
local M = C_PhonePanelRuleCheckManager
local ActionTransitionRuleTypesConfig = LTConfig.ActionTransitionRuleTypesConfig

M.ctor = function(self)
	self:InitData()
end

M.ExecuteStateLogic = function(self)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("ExecuteStateLogic")
	end

	if not gGmUtils.isForceOpenMainPhonePanel then
		self:ProcessPanelStateChange()
		self:ProcessQueue()
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.ProcessPanelStateChange = function(self)
	for i = 0, LTConfig.PhonePanelConfig.count - 1 do
		local phonePanelCfg = LTConfig.PhonePanelConfig.LoadAt(i)
		local panelId = phonePanelCfg.Id

		if gPanelManager:IsPanelShowing(panelId) then
			if self:CheckPanelContact(panelId) then
				gPanelManager:Close(panelId)
			else
				local actionConflictId = self:CheckActionConflict(panelId)
				local actionConflictCfg = LTConfig.PhonePanelActionConflictConfig.GetConfig(actionConflictId)

				if actionConflictCfg and actionConflictCfg.FunctionStartType ~= gClientConst.PHONE_PANEL_FUNCTION_START_TYPE.Forbid then
					local noticeMessage = ("ProcessPanelStateChange panelId:%d, actionConflict Id:%d"):format(panelId, actionConflictId)

					print_debug(noticeMessage)
					gPanelManager:Close(panelId)
				end
			end
		end
	end
end

M.CheckSpecialRuleIgnoreConflict = function(self, panelId, actionConflictId)
	if gClientUtils.CheckIsMainPhonePanelId(panelId) and actionConflictId ~= LTConfig.PhonePanelActionConflictConfig.Dialog and table.find(LTConfig.PhonePanelConfig.IgnoreConflictDialogTypeList, gDialogManager:GetFirstDialogType()) then
		return true
	end
end

M.ProcessQueue = function(self)
	local panelInfo = self.popUpQueue:Peek()

	if panelInfo then
		local actionConflictId = self:GetActionConflictId(panelInfo.panelId)

		if not actionConflictId then
			self.popUpQueue:Pop()
			gPanelManager:CheckShow(panelInfo.panelId, panelInfo.args)
		end
	end
end

M.PushQueue = function(self, panelId, args)
	self.popUpQueue:Push({
		panelId = panelId,
		args = args
	})
end

M.InitData = function(self)
	self.popUpQueue = self.popUpQueue or gDataStructureUtils.GetQueue()

	self:InitActionCheckFunctions()
	self:InitMessages()
end

M.InitMessages = function(self)
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

M.CheckPanelContact = function(self, panelId)
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

M.GetConflictPanelIdList = function(self)
	return {
		gPanelId.S_CHALLENGE_STATEMENT_PANEL,
		gPanelId.S_CHALLENGE_ENDING_PANEL,
		gPanelId.PARTY_END_PANEL
	}
end

M.CheckActionConflict = function(self, panelId)
	local actionConflictId = self:GetActionConflictId(panelId)

	if self:CheckSpecialRuleIgnoreConflict(panelId, actionConflictId) then
		return nil
	end

	return actionConflictId
end

M.GetActionConflictId = function(self, panelId)
	local phonePanelCfg = LTConfig.PhonePanelConfig.GetConfig(panelId)

	if phonePanelCfg then
		for i = 0, LTConfig.PhonePanelActionConflictConfig.count - 1 do
			local actionConflictCfg = LTConfig.PhonePanelActionConflictConfig.LoadAt(i)
			local actionCheckFunction = self.actionCheckFunctions[actionConflictCfg.Id]

			if actionCheckFunction() then
				if phonePanelCfg.Type ~= gClientConst.PHONE_PANEL_TYPE.Function then
					if actionConflictCfg.FunctionStartType ~= gClientConst.PHONE_PANEL_FUNCTION_START_TYPE.Forbid then
						return actionConflictCfg.Id
					end
				elseif phonePanelCfg.Type ~= gClientConst.PHONE_PANEL_TYPE.Performance then
					if actionConflictCfg.PerformStartType ~= gClientConst.PHONE_PANEL_PERFORM_START_TYPE.Forbid then
						return actionConflictCfg.Id
					end

					if actionConflictCfg.PerformStartType ~= gClientConst.PHONE_PANEL_PERFORM_START_TYPE.Wait then
						return actionConflictCfg.Id
					end
				end
			end
		end
	end
end

M.CheckPanelCanShow = function(self, panelId, args)
	if gGmUtils.isForceOpenMainPhonePanel then
		return true
	end

	if gClientUtils.CheckMainPhoneHalfScreenEnable() then
		if self:CheckPanelContact(panelId) then
			self:HandleConflict(panelId, args)

			return false
		end

		if gClientUtils.CheckIsMainPhonePanelId(panelId) then
			local appId = gMainPhoneUtils.GetAppIdByShowType(args and args.showType)

			if appId and not gMainPhoneUtils.CheckAppSwitchFunctionEnable(appId) then
				return false
			end
		end

		local actionConflictId = self:CheckActionConflict(panelId)

		if actionConflictId then
			local actionConflictCfg = LTConfig.PhonePanelActionConflictConfig.GetConfig(actionConflictId)

			if actionConflictCfg.PerformStartType ~= gClientConst.PHONE_PANEL_PERFORM_START_TYPE.Wait then
				self:HandleConflict(panelId, args)
			end

			return false
		end

		if panelId ~= gPanelId.S_HALF_PHONE_APP_HOME_PANEL and gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit:HasGameplayTag(LTConfig.GameplayTagConfig.Automated_MapBoundaryReturn) then
			return false
		end
	end

	return true
end

M.HandleConflict = function(self, panelId, args)
	local phonePanelCfg = LTConfig.PhonePanelConfig.GetConfig(panelId)

	if phonePanelCfg.Type ~= gClientConst.PHONE_PANEL_TYPE.Performance then
		self:PushQueue(panelId, args)
	end
end

M.IsRunState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Walk or state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Run or state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Rush
end

M.IsSwingState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Swing or state ~= ActionTransitionRuleTypesConfig.ParkourStateType.SwingOut
end

M.IsFallState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Fall
end

M.IsClimbState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.ClimbRun or state ~= ActionTransitionRuleTypesConfig.ParkourStateType.ClimbSlow
end

M.IsIdleState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Idle or state ~= ActionTransitionRuleTypesConfig.ParkourStateType.ShowAction
end

M.IsOnlyWalkState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Walk
end

M.IsOnlyRunState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Run
end

M.IsOnlyRushState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Rush
end

M.IsJumpState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Jump
end

M.IsFeiSuoState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Feisuo
end

M.IsSitState = function(self, state)
	return state ~= ActionTransitionRuleTypesConfig.ParkourStateType.Sit
end

M.InitActionCheckFunctions = function(self)
	self.actionCheckFunctions = {
		[LTConfig.PhonePanelActionConflictConfig.Fight] = function ()
			return gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.FightS)
		end,
		[LTConfig.PhonePanelActionConflictConfig.Driver] = function ()
			return gCS.DriveManager.isDriveMode
		end,
		[LTConfig.PhonePanelActionConflictConfig.Dialog] = function ()
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

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.popUpQueue:Clear()

		gCallPhoneUtils.multiMoveStatus = 0
	end
end

gPhonePanelRuleCheckManager = gPhonePanelRuleCheckManager or C_PhonePanelRuleCheckManager.new()
