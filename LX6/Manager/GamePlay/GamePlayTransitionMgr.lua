-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\GamePlayTransitionMgr.lua
-- Decompiled from: 02180_GamePlayTransitionMgr.lua_9c0c3e72e426.luajit

local M = gGamePlayTransitionMgr or {}

M.OnInit = function(self)
	self:InitParam()
	self:InitConfig()
end

M.GamePlayType = {
	["\\xabir"] = 5,
	["~\\xa7\\xb6\\xba\\xa6"] = 3,
	["~\\xbf\\xb7\\xae\\xa2"] = 4,
	["i\\xa7\\xb1\\xac\\xb9"] = 8,
	["b\\xa0\\xb1\\xaa\\xb8"] = 6,
	["R-p^"] = 7,
	["t-s^"] = 0
}

M.CheckIsInGamePlay = function(self)
	return self.curGamePlayType == M.GamePlayType.none
end

M.EnterGamePlay = function(self, gamePlayType)
	self.curGamePlayEndFlag = false
	self.curGamePlayType = gamePlayType
	gCS.TransitionMgr.curGamePlayType = self.curGamePlayType

	if self.curGamePlayType == M.GamePlayType.none then
		gCS.TransitionMgr.isInGamePlay = true
	end

	self.curGamePlayMgr = self.allGamePlayManager[self.curGamePlayType]

	if self.curGamePlayMgr and self.curGamePlayMgr.EnterGamePlay then
		self.curGamePlayMgr:EnterGamePlay()
	end
end

M.EndGamePlay = function(self, gamePlayType, force)
	if self.curGamePlayType == gamePlayType and not force then
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

M.InitParam = function(self)
	self.currentActionTime = 0
	self.curActionAllTime = 0
	self.curGamePlayType = M.GamePlayType.none
	gCS.TransitionMgr.curGamePlayType = self.curGamePlayType
	self.curGamePlayEndFlag = false
	self.curGamePlayMgr = nil
	self.deprecated = true
end

M.InitConfig = function(self)
	print_debug("GamePlayTransitionConfig init")

	self.TransConditionFunc = {}
	self.allTransitions = {}
	self.allTransitionSuccessBeforeFunc = {}
	self.allTransitionSuccessAfterFunc = {}
	self.allGamePlayManager = {}
end

M.GetCurGamePlayCheckConfigs = function(self)
	if #self.allTransitions <= 0 then
		return self.allTransitions[self.curGamePlayType]
	end
end

M.CheckActionEnd = function(self)
	self.isActionEndPlay = true
	local ok = self:CheckSwitchAction()
	self.isActionEndPlay = false

	return ok
end

M.CheckSwitchAction = function(self)
	if self.deprecated then
		return false
	end

	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit ~= nil then
		return false
	end

	if not self:CheckIsInGamePlay() then
		return false
	end

	local unityTime = gLogicTime.time
	local unityDeltaTime = gLogicTime.deltaTime
	self.currentActionTime, self.curActionAllTime = gCS.AnimationManager.GetCureentTimeAndLength(unit, true, 0)
	local checkConfigs = self:GetCurGamePlayCheckConfigs()

	if checkConfigs ~= nil then
		return false
	end

	local flag, playtime, targetActionType, fadeInTime = nil
	local actionId = gCS.AnimationManager.GetCurrentLayerActionKey(unit)
	local needCheckConfigs = checkConfigs[actionId]

	if needCheckConfigs then
		for i = 1, #needCheckConfigs do
			local cfg = needCheckConfigs[i]
			flag, playtime, targetActionType, fadeInTime = self:CheckTransitionAndPlay(unit, cfg, false, unityDeltaTime, unityTime, self.currentActionTime, self.curActionAllTime)

			if flag then
				break
			end
		end
	end

	local aniClass = gCS.LuaUtils.GetAniClass()

	if not flag and aniClass <= 0 and checkConfigs[aniClass] then
		needCheckConfigs = checkConfigs[aniClass]

		for i = 1, #needCheckConfigs do
			local cfg = needCheckConfigs[i]
			flag, playtime, targetActionType, fadeInTime = self:CheckTransitionAndPlay(unit, cfg, false, unityDeltaTime, unityTime, self.currentActionTime, self.curActionAllTime)

			if flag then
				break
			end
		end
	end

	return flag, playtime, targetActionType, fadeInTime
end

M.CheckTimeIsOk = function(self, unit, cfg, AddDeltaTime, unityDeltaTime, currentActionTime, curActionAllTime)
	local nowTime = currentActionTime

	if AddDeltaTime then
		nowTime = nowTime + unityDeltaTime
	end

	if self.isActionEndPlay and curActionAllTime < cfg.OverrideCancelTime then
		return true
	end

	if cfg.OverrideCancelTime <= -2 and nowTime <= cfg.OverrideCancelTime or not self.isActionEndPlay and cfg.OverrideCancelTime ~= -2 and nowTime >= curActionAllTime then
		return false
	end

	return true
end

M.CheckTransitionAndPlay = function(self, unit, cfg, AddDeltaTime, unityDeltaTime, unityTime, currentActionTime, curActionAllTime)
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

	if time ~= 0 then
		print_debug("动作找不到！！！！ 动作是", targetActionType, "targetGroup", targetGroup)

		return false
	end

	if cfg.TransitionCondition ~= nil or self:RunFunc(cfg, cfg.TransitionCondition) then
		if unit.State.ActionGroupId == cfg.TargetAniGroup then
			unit.State.ActionGroupId = cfg.TargetAniGroup
		end

		local startTime = cfg.ActionStartTime

		if cfg.IsCutTime and cfg.IsCutTime <= 0 then
			startTime = gCS.GamePlayTransitionMgr.GetActionStartTime(cfg.IsCutTime, unit, gUtils:GetActionKey(targetActionType, targetGroup), startTime)
		end

		local beforeActionFunc = self.allTransitionSuccessBeforeFunc[self.curGamePlayType]
		local afterActionFunc = self.allTransitionSuccessAfterFunc[self.curGamePlayType]

		gCS.ClimbManager.TryChangeParkourState(cfg.ParkourState, true)

		local actionEndCB = nil

		if beforeActionFunc then
			actionKey, startTime = beforeActionFunc(self, actionKey, startTime)
		end

		if actionKey ~= 0 then
			return false
		end

		if cfg.UpbodyActionAutoEnd then
			actionEndCB = function()
				local key = gUtils:GetActionKey(targetActionType, targetGroup)

				gCS.AnimationManager.AnimatorStop(unit, key, -1)
			end
		end

		gCS.AnimControllerManager.PlayAction(unit, targetActionType, targetGroup, 0, startTime, cfg.TransitionTime, true, actionEndCB, LX6.Units.Module.AnimSource.GameplayTransition)

		if gGameManager.Env.isEditor or self.debugInfo then
			unit:PushSwitchActionInfo(cfg.Id, targetActionType, targetGroup)
		end

		if cfg.ExtraAction and cfg.ExtraAction <= 0 then
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

		if cfg.gameMasktype ~= -1 then
			gCS.AnimationManager.StopAllLayerAction(unit, -1)
		end

		if afterActionFunc then
			afterActionFunc(self, unit, cfg, actionKey)
		end

		return true
	end
end

M.GetActionStartTime = function(self, cfg, unit, targetActionTime, animationCfg)
	if cfg.IsCutTime ~= 1 then
		local oldAnimPer = gCS.AnimationManager.GetCurrentActionNormalizedTime(unit.cs_unit, animationCfg.LayerIndex)

		return oldAnimPer * targetActionTime
	elseif cfg.IsCutTime ~= 3 then
		local oldAnimPer = gCS.AnimationManager.GetCurrentActionNormalizedTime(unit.cs_unit, animationCfg.LayerIndex)

		return (1 - oldAnimPer) * targetActionTime
	end

	return cfg.ActionStartTime
end

M.RunFunc = function(self, cfg, code)
	if code ~= nil then
		return true
	end

	local status, err, ret = self:RunCode(cfg.Id, code, gGamePlayTransitionFunc)

	return ret
end

M.RunCode = function(self, cfgId, code, funcScript)
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

M.DoGymActionAfter = function(self, unit, cfg, actionKey)
	gGymManager:OnActionChange(actionKey)
end

M.DoEatActionAfter = function(self, unit, cfg, actionKey)
	gRestaurantManager:OnActionChange(unit, cfg)
end

M.DoOnsenActionAfter = function(self, unit, cfg, actionKey)
end

M.DoHomeBedActionAfter = function(self, unit, cfg, actionKey)
	gHomeInteractionManager:OnActionEnd(cfg)
end

M.DoDiscoActionAfter = function(self, unit, cfg, actionKey)
	gBengdiActionManager:OnActionEnd(unit, cfg)
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.KickToLogin < switchType then
		self:EndGamePlay(nil, true)
	end
end

gGamePlayTransitionMgr = M

return gGamePlayTransitionMgr
