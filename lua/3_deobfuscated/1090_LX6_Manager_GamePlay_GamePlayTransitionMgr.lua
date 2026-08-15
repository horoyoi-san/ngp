local M = gGamePlayTransitionMgr or {}

function M:OnInit()
	self:InitParam()
	self:InitConfig()
end

M.GamePlayType = {
	Situp = 3,
	Disco = 8,
	Squat = 4,
	Drum = 2,
	Piano = 1,
	none = 0,
	Onsen = 6,
	Home = 7,
	Eat = 5
}

function M:CheckIsInGamePlay()
	return self.curGamePlayType ~= M.GamePlayType.none
end

function M:EnterGamePlay(gamePlayType)
	self.curGamePlayEndFlag = false
	self.curGamePlayType = gamePlayType
	gCS.TransitionMgr.curGamePlayType = self.curGamePlayType

	if self.curGamePlayType ~= M.GamePlayType.none then
		gCS.TransitionMgr.isInGamePlay = true
	end

	self.curGamePlayMgr = self.allGamePlayManager[self.curGamePlayType]

	if self.curGamePlayMgr and self.curGamePlayMgr.EnterGamePlay then
		self.curGamePlayMgr:EnterGamePlay()
	end
end

function M:EndGamePlay(gamePlayType, force)
	if self.curGamePlayType ~= gamePlayType and not force then
		return
	end

	self.curGamePlayEndFlag = true

	self:CheckSwitchAction()

	self.curGamePlayEndFlag = false

	if self.curGamePlayMgr and self.curGamePlayMgr.EndGamePlay then
		self.curGamePlayMgr:EndGamePlay()
	end

	self.curGamePlayType = M.GamePlayType.none
	gCS.TransitionMgr.curGamePlayType = self.curGamePlayType
	gCS.TransitionMgr.isInGamePlay = false
	self.curGamePlayMgr = nil
end

function M:InitParam()
	self.currentActionTime = 0
	self.curActionAllTime = 0
	self.curGamePlayType = M.GamePlayType.none
	gCS.TransitionMgr.curGamePlayType = self.curGamePlayType
	self.curGamePlayEndFlag = false
	self.curGamePlayMgr = nil
end

function M:InitGamePlayConfig(gamePlayType, cfg, successBeforeFunc, successAfterFunc, gameplayMgr)
	local typeTransitions = {}
	local count = cfg.count

	for i = 0, count - 1 do
		local trans = cfg.LoadAt(i)

		if trans.StartAniType >= 0 and trans.StartAniGroup > 0 then
			local type = gUtils:GetActionKey(trans.StartAniType, trans.StartAniGroup)

			if typeTransitions[type] == nil then
				typeTransitions[type] = {}
			end

			table.insert(typeTransitions[type], trans)
		elseif trans.StartAniClass > 0 then
			if typeTransitions[trans.StartAniClass] == nil then
				typeTransitions[trans.StartAniClass] = {}
			end

			table.insert(typeTransitions[trans.StartAniClass], trans)
		end
	end

	self.allTransitions[gamePlayType] = typeTransitions
	self.allTransitionSuccessBeforeFunc[gamePlayType] = successBeforeFunc
	self.allTransitionSuccessAfterFunc[gamePlayType] = successAfterFunc
	self.allGamePlayManager[gamePlayType] = gameplayMgr
end

function M:InitConfig()
	print_debug("GamePlayTransitionConfig init")

	self.TransConditionFunc = {}
	self.allTransitions = {}
	self.allTransitionSuccessBeforeFunc = {}
	self.allTransitionSuccessAfterFunc = {}
	self.allGamePlayManager = {}

	self:InitGamePlayConfig(M.GamePlayType.Piano, LTConfig.GamePlayTransitionPianoConfig, nil, self.DoPianoActionAfter, gGamePlayPianoManager)
	self:InitGamePlayConfig(M.GamePlayType.Drum, LTConfig.GamePlayTransitionDrumkitConfig, self.DoDrumkitActionBefore, self.DoDrumkitActionAfter, gGamePlayDrumkitManager)
	self:InitGamePlayConfig(M.GamePlayType.Situp, LTConfig.GamePlayTransitionsitupConfig, nil, self.DoGymActionAfter)
	self:InitGamePlayConfig(M.GamePlayType.Squat, LTConfig.GamePlayTransitionsquatConfig, nil, self.DoGymActionAfter)
	self:InitGamePlayConfig(M.GamePlayType.Eat, LTConfig.GamePlayTransitioneatConfig, nil, self.DoEatActionAfter, gRestaurantManager)
	self:InitGamePlayConfig(M.GamePlayType.Onsen, LTConfig.GamePlayTransitionspringConfig, nil, self.DoOnsenActionAfter)
	self:InitGamePlayConfig(M.GamePlayType.Home, LTConfig.GamePlayTransitionlyingbedConfig, nil, self.DoHomeBedActionAfter)
	self:InitGamePlayConfig(M.GamePlayType.Disco, LTConfig.GamePlayTransitionDiscoConfig, nil, self.DoDiscoActionAfter)
end

function M:GetCurGamePlayCheckConfigs()
	if #self.allTransitions > 0 then
		return self.allTransitions[self.curGamePlayType]
	end
end

function M:CheckActionEnd()
	self.isActionEndPlay = true
	local ok = self:CheckSwitchAction()
	self.isActionEndPlay = false

	return ok
end

function M:CheckSwitchAction()
	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit == nil then
		return false
	end

	if not self:CheckIsInGamePlay() then
		return false
	end

	local unityTime = gLogicTime.time
	local unityDeltaTime = gLogicTime.deltaTime
	self.currentActionTime, self.curActionAllTime = gCS.AnimationManager.GetCureentTimeAndLength(unit, true, 0)
	local checkConfigs = self:GetCurGamePlayCheckConfigs()

	if checkConfigs == nil then
		return false
	end

	local flag, playtime, targetActionType, fadeInTime = nil
	local actionId = gCS.AnimationManager.GetCurrentLayerActionKey(unit)
	local needCheckConfigs = checkConfigs[actionId]
	local addDeltaTime = self.curGamePlayType == M.GamePlayType.Piano

	if needCheckConfigs then
		for i = 1, #needCheckConfigs do
			local cfg = needCheckConfigs[i]
			flag, playtime, targetActionType, fadeInTime = self:CheckTransitionAndPlay(unit, cfg, addDeltaTime, unityDeltaTime, unityTime, self.currentActionTime, self.curActionAllTime)

			if flag then
				break
			end
		end
	end

	local aniClass = gCS.LuaUtils.GetAniClass()

	if not flag and aniClass > 0 and checkConfigs[aniClass] then
		needCheckConfigs = checkConfigs[aniClass]

		for i = 1, #needCheckConfigs do
			local cfg = needCheckConfigs[i]
			flag, playtime, targetActionType, fadeInTime = self:CheckTransitionAndPlay(unit, cfg, addDeltaTime, unityDeltaTime, unityTime, self.currentActionTime, self.curActionAllTime)

			if flag then
				break
			end
		end
	end

	if not flag then
		flag, playtime, targetActionType, fadeInTime = self:CheckExConfigs(unit, unityDeltaTime, unityTime)
	end

	return flag, playtime, targetActionType, fadeInTime
end

function M:CheckExConfigs(unit, unityDeltaTime, unityTime)
	local flag, playtime, targetActionType, fadeInTime = nil

	if self.curGamePlayMgr and self.curGamePlayMgr.CheckExConfigs then
		flag, playtime, targetActionType, fadeInTime = self.curGamePlayMgr:CheckExConfigs(unit, unityDeltaTime, unityTime)
	end

	return flag, playtime, targetActionType, fadeInTime
end

function M:CheckTimeIsOk(unit, cfg, AddDeltaTime, unityDeltaTime, currentActionTime, curActionAllTime)
	local nowTime = currentActionTime

	if AddDeltaTime then
		nowTime = nowTime + unityDeltaTime
	end

	if self.isActionEndPlay and curActionAllTime <= cfg.OverrideCancelTime then
		return true
	end

	if cfg.OverrideCancelTime > -2 and nowTime < cfg.OverrideCancelTime or not self.isActionEndPlay and cfg.OverrideCancelTime == -2 and nowTime < curActionAllTime then
		return false
	end

	return true
end

function M:CheckTransitionAndPlay(unit, cfg, AddDeltaTime, unityDeltaTime, unityTime, currentActionTime, curActionAllTime)
	if not self:CheckTimeIsOk(unit, cfg, AddDeltaTime, unityDeltaTime, currentActionTime, curActionAllTime) then
		return false
	end

	if self.curGamePlayMgr and self.curGamePlayMgr.CheckConfigNoOk and self.curGamePlayMgr:CheckConfigNoOk(unit, cfg) then
		return false
	end

	local targetActionType = cfg.TargetAniType
	local targetGroup = cfg.TargetAniGroup
	local actionKey = gUtils:GetActionKey(targetActionType, targetGroup)
	local time = gCS.AnimationManager.AnimatorGetAnimationTime(unit, targetActionType, targetGroup)

	if time == 0 then
		print_debug("动作找不到！！！！ 动作是", targetActionType, "targetGroup", targetGroup)

		return false
	end

	if cfg.TransitionCondition == nil or self:RunFunc(cfg, cfg.TransitionCondition) then
		if unit.State.ActionGroupId ~= cfg.TargetAniGroup then
			unit.State.ActionGroupId = cfg.TargetAniGroup
		end

		local startTime = cfg.ActionStartTime

		if cfg.IsCutTime and cfg.IsCutTime > 0 then
			startTime = gCS.GamePlayTransitionMgr.GetActionStartTime(cfg.IsCutTime, unit, gUtils:GetActionKey(targetActionType, targetGroup), startTime)
		end

		local beforeActionFunc = self.allTransitionSuccessBeforeFunc[self.curGamePlayType]
		local afterActionFunc = self.allTransitionSuccessAfterFunc[self.curGamePlayType]

		gCS.ClimbManager.TryChangeParkourState(cfg.ParkourState, true)

		local actionEndCB = nil

		if beforeActionFunc then
			actionKey, startTime = beforeActionFunc(self, actionKey, startTime)
		end

		if actionKey == 0 then
			return false
		end

		if cfg.UpbodyActionAutoEnd then
			function actionEndCB()
				local key = gUtils:GetActionKey(targetActionType, targetGroup)

				gCS.AnimationManager.AnimatorStop(unit, key, -1)
			end
		end

		gCS.AnimControllerManager.PlayAction(unit, targetActionType, targetGroup, 0, startTime, cfg.TransitionTime, true, actionEndCB, 0)

		if gGameManager.Env.isEditor or self.debugInfo then
			unit:PushSwitchActionInfo(cfg.Id, targetActionType, targetGroup)
		end

		if cfg.ExtraAction and cfg.ExtraAction > 0 then
			local t = cfg.ExtraAction
			local g = targetGroup

			gCS.AnimControllerManager.PlayAction(unit, t, g, 0, startTime, cfg.TransitionTime, true, function ()
				if gGameManager.Env.isEditor then
					unit:PushSwitchActionInfo(cfg.Id, t, g)
				end

				if cfg.UpbodyActionAutoEnd then
					gCS.AnimationManager.AnimatorStop(unit, gUtils:GetActionKey(t, g), -1)
				end
			end, 0)
		end

		if cfg.gameMasktype == -1 then
			gCS.AnimationManager.StopAllLayerAction(unit, -1)
		end

		if afterActionFunc then
			afterActionFunc(self, unit, cfg, actionKey)
		end

		return true
	end
end

function M:GetActionStartTime(cfg, unit, targetActionTime, animationCfg)
	if cfg.IsCutTime == 1 then
		local oldAnimPer = gCS.AnimationManager.GetCurrentActionNormalizedTime(unit.cs_unit, animationCfg.LayerIndex)

		return oldAnimPer * targetActionTime
	elseif cfg.IsCutTime == 3 then
		local oldAnimPer = gCS.AnimationManager.GetCurrentActionNormalizedTime(unit.cs_unit, animationCfg.LayerIndex)

		return (1 - oldAnimPer) * targetActionTime
	end

	return cfg.ActionStartTime
end

function M:RunFunc(cfg, code)
	if code == nil then
		return true
	end

	local status, err, ret = self:RunCode(cfg.Id, code, gGamePlayTransitionFunc)

	return ret
end

function M:RunCode(cfgId, code, funcScript)
	local func = self.TransConditionFunc[cfgId]

	if func then
		local status, ret = xpcall(func, tolua.traceback)

		return status, nil, ret
	else
		local f = load(code, nil, "t", funcScript)

		if f then
			self.TransConditionFunc[cfgId] = f
			local status, ret = xpcall(f, tolua.traceback)

			return status, nil, ret
		end
	end

	return false
end

function M:DoPianoActionAfter(unit, cfg, actionKey)
	gGamePlayPianoManager:DoActionAfter(unit, cfg, actionKey)
end

function M:DoDrumkitActionBefore(actionKey, startTime)
	return gGamePlayDrumkitManager:DoActionBeforce(actionKey, startTime)
end

function M:DoDrumkitActionAfter(unit, cfg, actionKey)
	gGamePlayDrumkitManager:DoActionAfter(unit, cfg, actionKey)
end

function M:DoGymActionAfter(unit, cfg, actionKey)
	gGymManager:OnActionChange(actionKey)
end

function M:DoEatActionAfter(unit, cfg, actionKey)
	gRestaurantManager:OnActionChange(unit, cfg)
end

function M:DoOnsenActionAfter(unit, cfg, actionKey)
	return
end

function M:DoHomeBedActionAfter(unit, cfg, actionKey)
	gHomeInteractionManager:OnActionEnd(cfg)
end

function M:DoDiscoActionAfter(unit, cfg, actionKey)
	gBengdiActionManager:OnActionEnd(unit, cfg)
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.KickToLogin <= switchType then
		self:EndGamePlay(nil, true)
	end
end

gGamePlayTransitionMgr = M

return gGamePlayTransitionMgr
