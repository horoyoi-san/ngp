-- Original chunk: @Lua\LuaFiles\LX6\Manager\AgentTrust\AgentTrustManager.lua
-- Decompiled from: 00235_AgentTrustManager.lua_e4ebc0bc6633.luajit

local AgentConfig = LTConfig.AgentConfig
local AgentProfileConfig = LTConfig.ProfileAgentProfileConfig
local AgentProfileRewardConfig = LTConfig.ProfileRewardConfig
local AgentProfileTargetConfig = LTConfig.ProfileTargetConfig
local AgentTypeConfig = LTConfig.AgentAgentSpecificTypeConfig
local ProfileConfig = LTConfig.ProfileConfig
local ProfileWebConfig = LTConfig.ProfileWebConfig
local RedDotMgr = SGUI.RedDotMgr
local LogUtilsLua = LX6.Utils.LogUtilsLua
local bindData = gPlayerManager.infoMinorNpcProfile.bindData
local GetAgentSpecificTypeByAgentConfig = nil
local ENABLE_ICON_DEBUG = true

local IconDebug = function(fmt, ...)
	if ENABLE_ICON_DEBUG then
		LogUtilsLua.Debug(string.format(fmt, ...))
	end
end

local PidToString = function(pid)
	return pid and ulong.tostring(pid) or "nil"
end

local GetProfileIdByAgentConfig = function(agentCfg)
	if not agentCfg then
		return nil
	end

	local agentSpecificType = GetAgentSpecificTypeByAgentConfig(agentCfg)

	if not agentSpecificType or agentSpecificType ~= 0 then
		return nil
	end

	local typeCfg = AgentTypeConfig.GetConfig(agentSpecificType)

	return typeCfg and typeCfg.ProfileId or nil
end

GetAgentSpecificTypeByAgentConfig = function(agentCfg)
	if not agentCfg then
		return nil
	end

	if type(agentCfg) ~= "table" then
		return agentCfg.AgentSpecificType
	end

	return gCS.LuaUtils.GetAgentConfigSpecificType(agentCfg)
end

local GetProfileIdByUnit = function(unit)
	if not unit then
		return nil
	end

	local agentSpecificType = gCS.LuaUtils.GetAgentSpecificType(unit)

	if not agentSpecificType or agentSpecificType ~= 0 then
		return nil
	end

	local typeCfg = AgentTypeConfig.GetConfig(agentSpecificType)

	return typeCfg and typeCfg.ProfileId or nil
end

C_AgentTrustManager = DefClass("C_AgentTrustManager", C_AgentTrustManager)
local M = C_AgentTrustManager

M.ctor = function(self)
	self:DefineAllData()
end

M.DefineAllData = function(self)
	self.trustValueDic = {}
	self.activateTimeDic = {}
	self.gotRewardListDic = {}
	self.finishTargetListDic = {}
	self.popupInfoList = {}
	self.nowTraceGps = nil
	self.nowTracePos = nil
	self.removeDelay = nil
	self.openMapFromAgentProfile = false
	self.agentPosRaidIdCache = {}
	self.isQueryingAllFavorNpcPos = false
	self.queryAllFavorNpcPosCallbacks = {}
	self.lastQueryAllFavorNpcPosTime = nil
	self.iconRetryStates = {}
end

local QUERY_ALL_FAVOR_NPC_POS_TTL = 3

M.OnInit = function(self)
	self:InitDataMeta()

	gCS.UnitsManager.OnUnitWithAgentSpecificTypeHudInitialized = gCS.UnitsManager.OnUnitWithAgentSpecificTypeHudInitialized + self:CreateAction("OnUnitHUDInitialized")

	gMessageManager:AddMessageListener(gEventConstants.PLAYER_INFO_INIT, self:CreateAction("OnPlayerInfoInit"))
	gMessageManager:AddMessageListener(gEventConstants.NPC_HUD_ROOT_READY, self:CreateAction("OnNpcHudRootReady"))
end

M.OnPlayerInfoInit = function(self)
	self:RefreshAgentProfilePhoneAppRedDot()
end

M.OnUnitHUDInitialized = function(self, unit)
	if unit.ClientData.Type ~= UX.Game.EntityType.Npc then
		IconDebug("[AgentTrust][Icon] OnUnitHUDInitialized: pid=%s name=%s", PidToString(unit.Pid), tostring(unit.ClientData.Name))
		gCS.LuaUtils.SubscribeLifeScheduleRoleChanged(unit)
	end
end

M.OnNpcHudRootReady = function(self, _, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		IconDebug("[AgentTrust][Icon] OnNpcHudRootReady SKIP: unit not found, pid=%s", PidToString(pid))

		return
	end

	if unit.ClientData.Type == UX.Game.EntityType.Npc then
		return
	end

	local profileId = GetProfileIdByUnit(unit)

	if not profileId then
		return
	end

	IconDebug("[AgentTrust][Icon] OnNpcHudRootReady: pid=%s name=%s profileId=%s", PidToString(pid), tostring(unit.ClientData.Name), tostring(profileId))
	gCS.LuaUtils.SubscribeLifeScheduleRoleChanged(unit)
end

M.OnUpdate = function(self)
	self:RefreshGps()
end

local TRUST_VALUE = "TrustValue"
local ACTIVATE_TIME = "ActivateTime"
local GOT_REWARD_LIST = "GotRewardList"
local FINISH_TARGET_LIST = "FinishTargetList"

local MAKE_META = function(kType)
	local meta = {
		__index = function (table, key)
			local npcTrustInfo = bindData.npcTrustInfo

			if npcTrustInfo ~= nil then
				return nil
			end

			local trustData = npcTrustInfo[key]

			if trustData == nil then
				return trustData[kType]
			end

			return nil
		end,
		__newIndex = function (table, key, value)
			print_error("该表仅用于映射至InfoMinorNpcProfile，禁止主动修改数据!")
		end
	}

	return meta
end

M.InitDataMeta = function(self)
	setmetatable(self.trustValueDic, MAKE_META(TRUST_VALUE))
	setmetatable(self.activateTimeDic, MAKE_META(ACTIVATE_TIME))
	setmetatable(self.gotRewardListDic, MAKE_META(GOT_REWARD_LIST))
	setmetatable(self.finishTargetListDic, MAKE_META(FINISH_TARGET_LIST))
end

M.UpdateProfileInfo = function(self, profileInfo)
	local profileId = profileInfo.ProfileId
	local wasAcquainted = bindData.npcTrustInfo[profileId] == nil
	local acquainted = profileInfo == nil
	bindData.npcTrustInfo[profileId] = profileInfo

	if wasAcquainted == acquainted then
		gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_ACQUAINTED_CHANGED, profileId)
	end

	if profileInfo then
		self:CheckAddIconForProfile(profileId)
	end
end

M.UpdateNpcProfileTargetFinish = function(self, profileId, target)
	local trustInfo = bindData.npcTrustInfo[profileId]
	local finishTargetList = trustInfo.FinishTargetList

	table.insert(finishTargetList, target)
end

M.UpdateNpcProfileRewardGot = function(self, profileId, rewardId)
	local trustInfo = bindData.npcTrustInfo[profileId]
	local gotRewardList = trustInfo.GotRewardList

	table.insert(gotRewardList, rewardId)
	gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
	self:RefreshAgentProfilePhoneAppRedDot()
	self:CheckRemoveIcon(profileId)
end

M.UpdateProgressRewardGotWithWeb = function(self, index, webId)
	local progressRewardsWithWeb = bindData._data.progressRewardsWithWeb

	if not progressRewardsWithWeb[webId] then
		progressRewardsWithWeb[webId] = {}
	end

	table.insert(progressRewardsWithWeb[webId], index)
	gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
	self:RefreshAgentProfilePhoneAppRedDot()
end

M.UpdateProfileNewStatus = function(self, profileId)
	local trustInfo = bindData.npcTrustInfo[profileId]

	if trustInfo then
		trustInfo.IsNew = false
	end

	gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
	self:RefreshAgentProfilePhoneAppRedDot()
end

M.CheckIfTargetIsNew = function(self, profileId, targetId)
	if not profileId or profileId ~= 0 or not targetId or targetId ~= 0 then
		return false
	end

	local trustInfo = bindData.npcTrustInfo[profileId]

	if not trustInfo or not trustInfo.TargetStateList then
		return false
	end

	return trustInfo.TargetStateList[targetId] ~= true
end

M.UpdateTargetNewStatus = function(self, profileId, targetId)
	local trustInfo = bindData.npcTrustInfo[profileId]

	if trustInfo and trustInfo.TargetStateList then
		trustInfo.TargetStateList[targetId] = false
	end

	gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
	self:RefreshAgentProfilePhoneAppRedDot()
end

M.UpdateNpcProfileTrustValue = function(self, profileInfo)
	local profileId = profileInfo.ProfileId
	bindData.npcTrustInfo[profileId].TrustValue = profileInfo.TrustValue

	IconDebug("[AgentTrust][Icon] UpdateNpcProfileTrustValue RPC: trust=%s profileId=%s", tostring(profileInfo.TrustValue), tostring(profileId))
	self:CheckAddIconForProfile(profileId)
end

M.RefreshGps = function(self)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local nowPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local dis = (nowPos.x - self.nowTracePos.x)^2 + (nowPos.y - self.nowTracePos.y)^2 + (nowPos.z - self.nowTracePos.z)^2

	if dis < 25 then
		if gPanelManager:IsPanelShowing(gPanelId.S_NEW_MAP_PANEL) then
			return
		end

		gLuaClient:UnregisterDynamicUpdate("gAgentTrustManager")

		self.removeDelay = gLuaTimeMgrUtils.Delay(function ()
			gMapSubSystem_LegacyGps:RemoveGps(self.nowTraceGps)

			self.nowTraceGps = nil
			self.nowTracePos = nil
			self.removeDelay = nil
		end, 3)
	end
end

M.GetIfAcquainted = function(self, agentId)
	local agentCfg = AgentConfig.GetConfig(agentId)

	if not agentCfg then
		return false
	end

	local agentProfileId = GetProfileIdByAgentConfig(agentCfg)

	if not agentProfileId or agentProfileId ~= 0 then
		return false
	end

	local trustData = bindData.npcTrustInfo[agentProfileId]

	if not trustData then
		return false
	end

	return true
end

M.GetIfAcquaintedByProfileId = function(self, agentProfileId)
	if not agentProfileId or agentProfileId ~= 0 then
		return false
	end

	local trustData = bindData.npcTrustInfo[agentProfileId]

	if not trustData then
		return false
	end

	return true
end

M.CheckIfNewAcquaintedByProfileId = function(self, agentProfileId)
	if not agentProfileId or agentProfileId ~= 0 then
		return false
	end

	local trustData = bindData.npcTrustInfo[agentProfileId]

	if not trustData then
		return false
	end

	return trustData.IsNew or false
end

M.GetIfRecruitable = function(self, agentProfileId)
	if not agentProfileId or agentProfileId ~= 0 then
		return false
	end

	return AgentProfileConfig.GetConfig(agentProfileId).CanJoin
end

M.GetTrustValue = function(self, profileId)
	return self.trustValueDic[profileId]
end

M.IsTrustDataAvailable = function(self, profileId)
	return self:GetTrustValue(profileId) == nil
end

M.GetGotRewardList = function(self, profileId)
	return self.gotRewardListDic[profileId]
end

M.GetFinishTargetList = function(self, profileId)
	return self.finishTargetListDic[profileId]
end

M.GetProgressRewardsWithWeb = function(self, webId)
	local progressRewardsWithWeb = bindData._data.progressRewardsWithWeb

	if not progressRewardsWithWeb then
		return {}
	end

	return progressRewardsWithWeb[webId] or {}
end

M.CheckProgressRewardGotWithWeb = function(self, index, webId)
	local progressRewards = self:GetProgressRewardsWithWeb(webId)

	for _, rewardIndex in ipairs(progressRewards) do
		if rewardIndex ~= index then
			return true
		end
	end

	return false
end

M.TakeProfileTrustReward = function(self, profileId, rewardId, cb)
	gClientToGameDelegate:AskTakeNpcProfileTrustReward(profileId, rewardId).Callback = function (errId)
		if errId == 0 then
			print_error("AskTakeNpcProfileTrustReward 请求失败，err = " .. gCS.Error.GetNameById(errId))

			return
		end

		cb()
		gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
		self:RefreshAgentProfilePhoneAppRedDot()
		self:CheckRemoveIcon(profileId)
	end
end

M.CheckRewardGot = function(self, profileId, rewardId)
	local gotRewardList = self:GetGotRewardList(profileId)

	if not gotRewardList then
		return false
	end

	for _, reward in ipairs(gotRewardList) do
		if rewardId ~= reward then
			return true
		end
	end

	return false
end

M.CheckAllRewardsGot = function(self, profileId)
	local config = AgentProfileConfig.GetConfig(profileId)
	local rewards = config and config.TrustReward

	if not rewards or #rewards ~= 0 then
		return false
	end

	for _, rewardId in ipairs(rewards) do
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)

		if rewardCfg and rewardCfg.RewardType == AgentProfileRewardConfig.RewardTypeType.Disable and not self:CheckRewardGot(profileId, rewardId) then
			return false
		end
	end

	return true
end

M.CheckRemoveIcon = function(self, profileId)
	local agentList = gCS.UnitsManager:GetAllUnitsWithAgentSpecificType():ToTable()

	for _, unit in ipairs(agentList) do
		local unitProfileId = GetProfileIdByUnit(unit)

		if unitProfileId ~= profileId then
			local hasReward = self:CheckHasRewardCanGot(unitProfileId)
			local isNpc = unit.ClientData.Type ~= UX.Game.EntityType.Npc

			if not hasReward and isNpc then
				gHudMgr:RemoveTopAnimHeadIcon(unit.Pid)
				gCS.LuaUtils.UnsubscribeLifeScheduleRoleChanged(unit)
				self:CancelIconRetry(unit.Pid)
			end
		end
	end
end

M.CheckAddIconForProfile = function(self, profileId)
	if not self:CheckHasRewardCanGot(profileId) then
		local trustVal = self:GetTrustValue(profileId)

		IconDebug("[AgentTrust][Icon] CheckAddIconForProfile SKIP: no claimable reward, profileId=%s trust=%s", tostring(profileId), tostring(trustVal))

		return
	end

	local agentList = gCS.UnitsManager:GetAllUnitsWithAgentSpecificType():ToTable()

	IconDebug("[AgentTrust][Icon] CheckAddIconForProfile: searching %d units in range for profileId=%s", #agentList, tostring(profileId))

	local matched = false

	for _, unit in ipairs(agentList) do
		local unitProfileId = GetProfileIdByUnit(unit)

		if unitProfileId ~= profileId then
			matched = true
			local isLS = gCS.LuaUtils.IsLifeScheduleRole(unit)
			local isNpc = unit.ClientData.Type ~= UX.Game.EntityType.Npc

			if isNpc then
				gCS.LuaUtils.SubscribeLifeScheduleRoleChanged(unit)
			end

			if isLS and isNpc then
				local ok, hudReason = gHudMgr:AddTopAnimHeadIcon(unit.Pid, gHudMgr.TopAnimType.Gift)

				if ok then
					self:CancelIconRetry(unit.Pid)
					IconDebug("[AgentTrust][Icon] CheckAddIconForProfile OK: icon added, pid=%s profileId=%s hud=%s", PidToString(unit.Pid), tostring(profileId), tostring(hudReason))
				else
					IconDebug("[AgentTrust][Icon] CheckAddIconForProfile DEFER: icon add failed, pid=%s profileId=%s hud=%s", PidToString(unit.Pid), tostring(profileId), tostring(hudReason))
					self:ScheduleIconRetry(profileId, unit.Pid)
				end
			else
				IconDebug("[AgentTrust][Icon] CheckAddIconForProfile PARTIAL: unit found but LifeSchedule=%s isNpc=%s, pid=%s profileId=%s", tostring(isLS), tostring(isNpc), PidToString(unit.Pid), tostring(profileId))
			end
		end
	end

	if not matched then
		IconDebug("[AgentTrust][Icon] CheckAddIconForProfile DEFER: no unit in range for profileId=%s", tostring(profileId))
	end
end

M.OnNpcConvertToPed = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit then
		gHudMgr:RemoveTopAnimHeadIcon(pid)
		gCS.LuaUtils.UnsubscribeLifeScheduleRoleChanged(unit)
		self:CancelIconRetry(pid)
	end
end

M.OnLifeScheduleRoleActive = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		IconDebug("[AgentTrust][Icon] OnLifeScheduleRoleActive SKIP: unit not found, pid=%s", PidToString(pid))

		return
	end

	local profileId = GetProfileIdByUnit(unit)

	if not profileId then
		IconDebug("[AgentTrust][Icon] OnLifeScheduleRoleActive SKIP: profileId not found, pid=%s", PidToString(pid))

		return
	end

	local isNpc = unit.ClientData.Type ~= UX.Game.EntityType.Npc

	if not isNpc then
		IconDebug("[AgentTrust][Icon] OnLifeScheduleRoleActive SKIP: not NPC, pid=%s type=%s", PidToString(pid), tostring(unit.ClientData.Type))

		return
	end

	if self:CheckHasRewardCanGot(profileId) then
		local ok, hudReason = gHudMgr:AddTopAnimHeadIcon(pid, gHudMgr.TopAnimType.Gift)

		if ok then
			self:CancelIconRetry(pid)
			IconDebug("[AgentTrust][Icon] OnLifeScheduleRoleActive OK: icon added, pid=%s profileId=%s hud=%s", PidToString(pid), tostring(profileId), tostring(hudReason))
		else
			IconDebug("[AgentTrust][Icon] OnLifeScheduleRoleActive HUD_DEFER: icon add failed, pid=%s profileId=%s hud=%s", PidToString(pid), tostring(profileId), tostring(hudReason))
			self:ScheduleIconRetry(profileId, pid)
		end
	elseif not self:IsTrustDataAvailable(profileId) then
		IconDebug("[AgentTrust][Icon] OnLifeScheduleRoleActive RETRY: trust data absent, pid=%s profileId=%s", PidToString(pid), tostring(profileId))
		self:ScheduleIconRetry(profileId, pid)
	else
		local trustVal = self:GetTrustValue(profileId)

		IconDebug("[AgentTrust][Icon] OnLifeScheduleRoleActive SKIP: trust=%s but no claimable reward, pid=%s profileId=%s", tostring(trustVal), PidToString(pid), tostring(profileId))
	end
end

M.OnLifeScheduleRoleInactive = function(self, pid)
	gHudMgr:RemoveTopAnimHeadIcon(pid)
	self:CancelIconRetry(pid)
end

local ICON_RETRY_INTERVALS = {
	0.5,
	1.5,
	3
}
local ICON_RETRY_MAX = #ICON_RETRY_INTERVALS

M.ScheduleIconRetry = function(self, profileId, pid)
	local pidKey = PidToString(pid)
	local state = self.iconRetryStates[pidKey]

	if state then
		if state.profileId ~= profileId then
			return
		end

		self:CancelIconRetry(pid)
	end

	state = {
		["A_گ\\x9d+\\xb7\\xc7\\xfc"] = 0,
		profileId = profileId,
		pid = pid
	}
	self.iconRetryStates[pidKey] = state

	local tryAddIcon = function()
		state.retryCount = state.retryCount + 1
		local unit = gCS.SceneDataMgr.GetUnit(pid)

		if not unit then
			IconDebug("[AgentTrust][Icon] IconRetry #%d stopped: unit not found, pid=%s", state.retryCount, pidKey)
			self:CancelIconRetry(pid)

			return
		end

		if self:CheckHasRewardCanGot(profileId) and unit.ClientData.Type ~= UX.Game.EntityType.Npc then
			local ok, hudReason = gHudMgr:AddTopAnimHeadIcon(pid, gHudMgr.TopAnimType.Gift)

			if ok then
				self:CancelIconRetry(pid)
				IconDebug("[AgentTrust][Icon] IconRetry #%d OK: profileId=%d pid=%s hud=%s", state.retryCount, profileId, pidKey, tostring(hudReason))

				return
			end

			if state.retryCount >= ICON_RETRY_MAX then
				local interval = ICON_RETRY_INTERVALS[state.retryCount + 1] or 3

				IconDebug("[AgentTrust][Icon] IconRetry #%d continue: pid=%s hud=%s next=%.1f", state.retryCount, pidKey, tostring(hudReason), interval)

				state.delayHandle = gLuaTimeMgrUtils.Delay(tryAddIcon, interval)

				return
			end

			IconDebug("[AgentTrust][Icon] IconRetry stopped after %d attempts: hud not ready. profileId=%d pid=%s hud=%s", state.retryCount, profileId, pidKey, tostring(hudReason))
			self:CancelIconRetry(pid)

			return
		elseif not self:IsTrustDataAvailable(profileId) and state.retryCount >= ICON_RETRY_MAX then
			local interval = ICON_RETRY_INTERVALS[state.retryCount + 1] or 3
			state.delayHandle = gLuaTimeMgrUtils.Delay(tryAddIcon, interval)
		else
			local reason = self:IsTrustDataAvailable(profileId) and "trust insufficient or all claimed" or "retries exhausted"

			IconDebug("[AgentTrust][Icon] IconRetry stopped after %d attempts: %s. profileId=%d pid=%s", state.retryCount, reason, profileId, pidKey)
			self:CancelIconRetry(pid)
		end
	end

	local interval = ICON_RETRY_INTERVALS[1]
	state.delayHandle = gLuaTimeMgrUtils.Delay(tryAddIcon, interval)
end

M.CancelIconRetry = function(self, pid)
	local pidKey = PidToString(pid)
	local state = self.iconRetryStates[pidKey]

	if not state then
		return
	end

	if state.delayHandle then
		gLuaTimeMgrUtils.CancelUnitDelay(state.delayHandle)

		state.delayHandle = nil
	end

	self.iconRetryStates[pidKey] = nil
end

M.CheckTargetFinish = function(self, profileId, targetId)
	local finishTargetList = self:GetFinishTargetList(profileId) or {}

	for _, target in ipairs(finishTargetList) do
		if targetId ~= target then
			return true
		end
	end

	return false
end

M.CheckHasRewardCanGot = function(self, profileId)
	local config = AgentProfileConfig.GetConfig(profileId)

	if not config then
		return false
	end

	local rewards = config.TrustReward

	if not rewards or #rewards ~= 0 then
		return false
	end

	local nowTrust = self:GetTrustValue(profileId)

	if nowTrust ~= nil then
		return false
	end

	for _, rewardId in ipairs(rewards) do
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)

		if rewardCfg then
			local needTrust = rewardCfg.NeedTrust
			local got = self:CheckRewardGot(profileId, rewardId)
			local disabled = rewardCfg.RewardType ~= AgentProfileRewardConfig.RewardTypeType.Disable

			if needTrust < nowTrust and not got and not disabled then
				return true
			end
		end
	end

	return false
end

M.GetFirstClaimableRewardGuideId = function(self, profileId)
	local config = AgentProfileConfig.GetConfig(profileId)

	if not config then
		return nil
	end

	local rewards = config.TrustReward
	local nowTrust = self:GetTrustValue(profileId)

	if nowTrust ~= nil then
		return nil
	end

	for _, rewardId in ipairs(rewards) do
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)
		local needTrust = rewardCfg.NeedTrust

		if needTrust < nowTrust and not self:CheckRewardGot(profileId, rewardId) and rewardCfg.RewardType == AgentProfileRewardConfig.RewardTypeType.Disable then
			return rewardCfg.GuideId
		end
	end

	return nil
end

M.GetProfileIdByTargetId = function(self, targetId)
	local count = AgentProfileConfig.count

	for i = 0, count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			for _, tId in ipairs(config.TrustTarget) do
				if tId ~= targetId then
					return config.Id
				end
			end
		end
	end
end

M.CheckAnyHasRewardCanGot = function(self)
	local count = AgentProfileConfig.count

	for i = 0, count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			local id = config.Id

			if self:CheckHasRewardCanGot(id) then
				return true
			end
		end
	end

	if self:CheckTotalProgressHasRewardCanGot() then
		return true
	end

	return false
end

M.RefreshAgentProfilePhoneAppRedDot = function(self)
	local hasRedDot = self:CheckAnyHasRewardCanGot()

	RedDotMgr.LuaSetRedDot(hasRedDot, "AgentProfilePhoneApp")
end

M.CheckTotalProgressHasRewardCanGot = function(self)
	local totalWeightByWeb = {}
	local completedWeightByWeb = {}

	for i = 0, AgentProfileConfig.count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			local webId = config.WebId or 1
			totalWeightByWeb[webId] = (totalWeightByWeb[webId] or 0) + (config.Weight or 0)

			if self:GetIfAcquaintedByProfileId(config.Id) then
				completedWeightByWeb[webId] = (completedWeightByWeb[webId] or 0) + (config.Weight or 0)
			end

			for _, targetId in ipairs(config.TrustTarget) do
				local targetConfig = AgentProfileTargetConfig.GetConfig(targetId)

				if targetConfig then
					totalWeightByWeb[webId] = (totalWeightByWeb[webId] or 0) + (targetConfig.Weight or 0)

					if self:CheckTargetFinish(config.Id, targetId) then
						completedWeightByWeb[webId] = (completedWeightByWeb[webId] or 0) + (targetConfig.Weight or 0)
					end
				end
			end
		end
	end

	for webId, totalWeight in pairs(totalWeightByWeb) do
		if totalWeight <= 0 then
			local progress = (completedWeightByWeb[webId] or 0) / totalWeight
			local webCfg = ProfileWebConfig.GetConfig(webId)
			local completionRewards = webCfg and webCfg.CompletionReward or {}

			for i, rewardCfg in ipairs(completionRewards) do
				local isGot = self:CheckProgressRewardGotWithWeb(i - 1, webId)

				if not isGot and rewardCfg.percent < progress then
					return true
				end
			end
		end
	end

	return false
end

M.GetAgentLocateCtrl = function(self, agentProfileId)
	if not agentProfileId or not self:GetIfAcquaintedByProfileId(agentProfileId) then
		return 0
	end

	local config = AgentProfileConfig.GetConfig(agentProfileId)

	if not config or not config.AgentId or config.AgentId ~= 0 then
		return 0
	end

	local agentCfg = AgentConfig.GetConfig(config.AgentId)
	local agentType = GetAgentSpecificTypeByAgentConfig(agentCfg)

	if agentType ~= 0 then
		print_error("AgentConfig AgentSpecificType error, id = " .. config.AgentId .. " profileId = " .. agentProfileId)

		return 1
	end

	local currentSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(gBattleSpiritMgr.currentSpiritTemplateId)

	if currentSpiritCfg then
		local agentTypeNow = GetAgentSpecificTypeByAgentConfig(AgentConfig.GetConfig(currentSpiritCfg.AgentId))

		if agentType ~= agentTypeNow then
			return 1
		end
	end

	local posInfo = self.agentPosRaidIdCache[agentType]
	local raidId = posInfo and posInfo.RaidId or nil

	if raidId ~= nil then
		return 0
	end

	if raidId < 0 then
		return 2
	end

	return 0
end

M.AskQueryAllFavorNpcAgentPos = function(self, callback)
	local now = Time.realtimeSinceStartup

	if self.lastQueryAllFavorNpcPosTime and now - self.lastQueryAllFavorNpcPosTime >= QUERY_ALL_FAVOR_NPC_POS_TTL then
		if callback then
			callback(0, self.agentPosRaidIdCache)
		end

		return
	end

	if callback then
		table.insert(self.queryAllFavorNpcPosCallbacks, callback)
	end

	if self.isQueryingAllFavorNpcPos then
		return
	end

	self.isQueryingAllFavorNpcPos = true

	gClientToGameDelegate:AskQueryAllFavorNpcAgentPos().Callback = function (errId, allPosInfoDic)
		self.isQueryingAllFavorNpcPos = false

		if errId ~= 0 then
			self.agentPosRaidIdCache = allPosInfoDic or {}
			self.lastQueryAllFavorNpcPosTime = Time.realtimeSinceStartup
		end

		local callbacks = self.queryAllFavorNpcPosCallbacks
		self.queryAllFavorNpcPosCallbacks = {}

		for _, cb in ipairs(callbacks) do
			cb(errId, allPosInfoDic)
		end
	end
end

M.QueryAgentLocateCtrl = function(self, agentProfileId, callback)
	if not agentProfileId or not self:GetIfAcquaintedByProfileId(agentProfileId) then
		if callback then
			callback(0)
		end

		return
	end

	local config = AgentProfileConfig.GetConfig(agentProfileId)

	if not config or not config.AgentId or config.AgentId ~= 0 then
		if callback then
			callback(0)
		end

		return
	end

	local agentCfg = AgentConfig.GetConfig(config.AgentId)
	local agentType = GetAgentSpecificTypeByAgentConfig(agentCfg)

	if agentType ~= 0 then
		if callback then
			callback(0)
		end

		return
	end

	local currentSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(gBattleSpiritMgr.currentSpiritTemplateId)

	if currentSpiritCfg then
		local agentTypeNow = GetAgentSpecificTypeByAgentConfig(AgentConfig.GetConfig(currentSpiritCfg.AgentId))

		if agentType ~= agentTypeNow then
			if callback then
				callback(1)
			end

			return
		end
	end

	self:AskQueryAllFavorNpcAgentPos(function (errId)
		if errId == 0 then
			if callback then
				callback(0)
			end

			return
		end

		local posInfo = self.agentPosRaidIdCache[agentType]
		local raidId = posInfo and posInfo.RaidId or 0

		if callback then
			callback(raidId < 0 and 2 or 0)
		end
	end)
end

M.GetRewardItemType = function(self, dropId)
	if not dropId or dropId < 0 then
		return 2
	end

	local dropConfig = LTConfig.DropConfig.GetConfig(dropId)

	if not dropConfig or not dropConfig.Item1 or #dropConfig.Item1 ~= 0 then
		return 2
	end

	local firstItem = dropConfig.Item1[1]

	if not firstItem or not firstItem.id1 or firstItem.id1 < 0 then
		return 2
	end

	local itemConfig = LTConfig.CommonItemConfig.GetConfig(firstItem.id1)

	if not itemConfig or not itemConfig.SubType then
		return 2
	end

	if itemConfig.SubType ~= LTConfig.ConsumableTypeConfig.Character then
		return 1
	end

	if itemConfig.SubType ~= LTConfig.ConsumableTypeConfig.Vehicle then
		return 3
	end

	local weaponSubTypes = {
		LTConfig.ConsumableTypeConfig.Weapon,
		LTConfig.ConsumableTypeConfig.WeaponSkin
	}

	for _, wType in ipairs(weaponSubTypes) do
		if itemConfig.SubType ~= wType then
			return 0
		end
	end

	if itemConfig.SubType ~= LTConfig.ConsumableTypeConfig.AchievementBadge then
		return 1
	end

	return 2
end

M.PopUpAgentProfileTrustChange = function(self, profileId, nowValue, value)
	local config = AgentProfileConfig.GetConfig(profileId)

	if config and config.NoTrustPop then
		return
	end

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_AgentTrustLevelUp, {
		profileId = profileId,
		nowValue = nowValue,
		targetValue = value
	})
end

M.PopUpAgentProfile = function(self, profileInfo)
	local profileId = profileInfo.ProfileId
	local config = AgentProfileConfig.GetConfig(profileId)

	if config and config.NoTrustPop then
		return
	end

	table.insert(self.popupInfoList, profileInfo)

	self.waitCo = coroutine.stop(self.waitCo)
	self.waitCo = coroutine.start(function ()
		coroutine.wait(0.25)

		if LTConfig.PopupConfig.AreaFivePopUpLimitCount < #self.popupInfoList then
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.AgentAcquaintedTotal, {
				count = #self.popupInfoList
			})
		else
			for _, popupInfo in ipairs(self.popupInfoList) do
				gNewPopupManager:PushPopup(LTConfig.PopupConfig.AgentAcquainted, popupInfo)
			end
		end

		self.popupInfoList = {}
	end)
end

M.PopUpAgentProfileTargetUnlock = function(self, targetId)
	local config = AgentProfileConfig.GetConfig(targetId)

	if config and config.NoTrustPop then
		return
	end

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.ProfileTargetUnlock, {
		targetId = targetId
	})
end

gAgentTrustManager = gAgentTrustManager or C_AgentTrustManager.new()
