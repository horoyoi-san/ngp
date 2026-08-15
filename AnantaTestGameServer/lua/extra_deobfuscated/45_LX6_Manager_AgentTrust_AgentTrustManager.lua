local AgentConfig = LTConfig.AgentConfig
local AgentProfileConfig = LTConfig.ProfileAgentProfileConfig
local AgentProfileRewardConfig = LTConfig.ProfileRewardConfig
local AgentProfileTargetConfig = LTConfig.ProfileTargetConfig
local AgentTypeConfig = LTConfig.AgentAgentSpecificTypeConfig
local ProfileConfig = LTConfig.ProfileConfig
local bindData = gPlayerManager.infoMinorNpcProfile.bindData
C_AgentTrustManager = DefClass("C_AgentTrustManager", C_AgentTrustManager)
local M = C_AgentTrustManager

function M:ctor()
	self:DefineAllData()
end

function M:DefineAllData()
	self.trustValueDic = {}
	self.activateTimeDic = {}
	self.gotRewardListDic = {}
	self.finishTargetListDic = {}
	self.popupInfoList = {}
	self.nowTraceGps = nil
	self.nowTracePos = nil
	self.removeDelay = nil
	self.openMapFromAgentProfile = false
end

function M:OnInit()
	self:InitDataMeta()

	gCS.UnitsManager.OnUnitWithAgentSpecificTypeHudInitialized = gCS.UnitsManager.OnUnitWithAgentSpecificTypeHudInitialized + self:CreateAction("OnUnitHUDInitialized")
end

function M:OnUnitHUDInitialized(unit)
	local agentCfg = AgentConfig.GetConfig(unit.TemplateId)
	local profileId = agentCfg and agentCfg.AgentProfileId or nil
	local hasReward = self:CheckHasRewardCanGot(profileId)
	local isNpc = unit.ClientData.Type == UX.Game.EntityType.Npc

	if hasReward and isNpc then
		gHudMgr:AddTopAnimHeadIcon(unit.Pid, gHudMgr.TopAnimType.Gift)
	end
end

function M:OnUpdate()
	self:RefreshGps()
end

local TRUST_VALUE = "TrustValue"
local ACTIVATE_TIME = "ActivateTime"
local GOT_REWARD_LIST = "GotRewardList"
local FINISH_TARGET_LIST = "FinishTargetList"

local function MAKE_META(kType)
	local meta = {
		__index = function (table, key)
			local trustData = bindData.npcTrustInfo[key]

			if trustData ~= nil then
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

function M:InitDataMeta()
	setmetatable(self.trustValueDic, MAKE_META(TRUST_VALUE))
	setmetatable(self.activateTimeDic, MAKE_META(ACTIVATE_TIME))
	setmetatable(self.gotRewardListDic, MAKE_META(GOT_REWARD_LIST))
	setmetatable(self.finishTargetListDic, MAKE_META(FINISH_TARGET_LIST))
end

function M:UpdateProfileInfo(profileInfo)
	local profileId = profileInfo.ProfileId
	bindData.npcTrustInfo[profileId] = profileInfo
end

function M:UpdateNpcProfileTargetFinish(profileId, target)
	local trustInfo = bindData.npcTrustInfo[profileId]
	local finishTargetList = trustInfo.FinishTargetList

	table.insert(finishTargetList, target)
end

function M:UpdateNpcProfileRewardGot(profileId, rewardId)
	local trustInfo = bindData.npcTrustInfo[profileId]
	local gotRewardList = trustInfo.GotRewardList

	table.insert(gotRewardList, rewardId)
	gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
	self:CheckRemoveIcon(profileId)
end

function M:UpdateProgressRewardGot(index)
	table.insert(bindData._data.progressRewards, index)
	gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
end

function M:UpdateMaxTrustRewardGot(profileId)
	local trustInfo = bindData.npcTrustInfo[profileId]

	if trustInfo then
		trustInfo.IsMaxTrustReward = true
	end

	gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
end

function M:UpdateProfileNewStatus(profileId)
	local trustInfo = bindData.npcTrustInfo[profileId]

	if trustInfo then
		trustInfo.IsNew = false
	end

	gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
end

function M:CheckIfTargetIsNew(profileId, targetId)
	if not profileId or profileId == 0 or not targetId or targetId == 0 then
		return false
	end

	local trustInfo = bindData.npcTrustInfo[profileId]

	if not trustInfo or not trustInfo.TargetStateList then
		return false
	end

	return trustInfo.TargetStateList[targetId] == true
end

function M:UpdateTargetNewStatus(profileId, targetId)
	local trustInfo = bindData.npcTrustInfo[profileId]

	if trustInfo and trustInfo.TargetStateList then
		trustInfo.TargetStateList[targetId] = false
	end

	gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
end

function M:CheckMaxTrustRewardGot(profileId)
	local trustInfo = bindData.npcTrustInfo[profileId]

	if trustInfo and trustInfo.IsMaxTrustReward then
		return true
	end

	return false
end

function M:UpdateNpcProfileTrustValue(profileInfo)
	local profileId = profileInfo.ProfileId
	bindData.npcTrustInfo[profileId].TrustValue = profileInfo.TrustValue

	self:CheckAddIcon()
end

function M:RefreshGps()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local nowPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local dis = (nowPos.x - self.nowTracePos.x)^2 + (nowPos.y - self.nowTracePos.y)^2 + (nowPos.z - self.nowTracePos.z)^2

	if dis <= 25 then
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

function M:GetIfAcquainted(agentId)
	local agentCfg = AgentConfig.GetConfig(agentId)

	if not agentCfg then
		return false
	end

	local agentType = agentCfg.AgentSpecificType
	local typeCfg = AgentTypeConfig.GetConfig(agentType)

	if not typeCfg then
		return false
	end

	local agentProfileId = typeCfg.ProfileId

	if not agentProfileId or agentProfileId == 0 then
		return false
	end

	local trustData = bindData.npcTrustInfo[agentProfileId]

	if not trustData then
		return false
	end

	return true
end

function M:GetIfAcquaintedByProfileId(agentProfileId)
	if not agentProfileId or agentProfileId == 0 then
		return false
	end

	local trustData = bindData.npcTrustInfo[agentProfileId]

	if not trustData then
		return false
	end

	return true
end

function M:CheckIfNewAcquaintedByProfileId(agentProfileId)
	if not agentProfileId or agentProfileId == 0 then
		return false
	end

	local trustData = bindData.npcTrustInfo[agentProfileId]

	if not trustData then
		return false
	end

	return trustData.IsNew or false
end

function M:GetIfRecruitable(agentProfileId)
	if not agentProfileId or agentProfileId == 0 then
		return false
	end

	return AgentProfileConfig.GetConfig(agentProfileId).CanJoin
end

function M:GetTrustValue(profileId)
	return self.trustValueDic[profileId]
end

function M:GetGotRewardList(profileId)
	return self.gotRewardListDic[profileId]
end

function M:GetFinishTargetList(profileId)
	return self.finishTargetListDic[profileId]
end

function M:GetProgressRewards()
	return bindData._data.progressRewards or {}
end

function M:CheckProgressRewardGot(index)
	local progressRewards = self:GetProgressRewards()

	for _, rewardIndex in ipairs(progressRewards) do
		if rewardIndex == index then
			return true
		end
	end

	return false
end

function M:TakeProfileTrustReward(profileId, rewardId, cb)
	gClientToGameDelegate:AskTakeNpcProfileTrustReward(profileId, rewardId).Callback = function (errId)
		if errId ~= 0 then
			print_error("AskTakeNpcProfileTrustReward 请求失败，err = " .. gCS.Error.GetNameById(errId))

			return
		end

		cb()
		gMessageManager:SendMessage(gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH)
		self:CheckRemoveIcon(profileId)
	end
end

function M:CheckRewardGot(profileId, rewardId)
	local gotRewardList = self:GetGotRewardList(profileId)

	for _, reward in ipairs(gotRewardList) do
		if rewardId == reward then
			return true
		end
	end

	return false
end

function M:CheckAddIcon()
	local agentList = gCS.UnitsManager:GetAllUnitsWithAgentSpecificType():ToTable()

	for _, unit in ipairs(agentList) do
		local agentCfg = AgentConfig.GetConfig(unit.TemplateId)
		local unitProfileId = agentCfg and agentCfg.AgentProfileId or 0

		if unitProfileId ~= 0 then
			local hasReward = self:CheckHasRewardCanGot(unitProfileId)
			local isNpc = unit.ClientData.Type == UX.Game.EntityType.Npc

			if hasReward and isNpc then
				gHudMgr:AddTopAnimHeadIcon(unit.Pid, gHudMgr.TopAnimType.Gift)
			end
		end
	end
end

function M:CheckRemoveIcon(profileId)
	local agentList = gCS.UnitsManager:GetAllUnitsWithAgentSpecificType():ToTable()

	for _, unit in ipairs(agentList) do
		local agentCfg = AgentConfig.GetConfig(unit.TemplateId)
		local unitProfileId = agentCfg and agentCfg.AgentProfileId or nil

		if unitProfileId == profileId then
			local hasReward = self:CheckHasRewardCanGot(unitProfileId)
			local isNpc = unit.ClientData.Type == UX.Game.EntityType.Npc

			if not hasReward and isNpc then
				gHudMgr:RemoveTopAnimHeadIcon(unit.Pid)
			end

			break
		end
	end
end

function M:OnNpcConvertToPed(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit then
		gHudMgr:RemoveTopAnimHeadIcon(pid)
	end
end

function M:CheckTargetFinish(profileId, targetId)
	local finishTargetList = self:GetFinishTargetList(profileId) or {}

	for _, target in ipairs(finishTargetList) do
		if targetId == target then
			return true
		end
	end

	return false
end

function M:CheckHasRewardCanGot(profileId)
	local config = AgentProfileConfig.GetConfig(profileId)

	if not config then
		return false
	end

	local rewards = config.TrustReward
	local nowTrust = self:GetTrustValue(profileId)

	if nowTrust == nil then
		return false
	end

	for _, rewardId in ipairs(rewards) do
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)
		local needTrust = rewardCfg.NeedTrust

		if needTrust <= nowTrust and not self:CheckRewardGot(profileId, rewardId) and rewardCfg.RewardType ~= AgentProfileRewardConfig.RewardTypeType.Disable then
			return true
		end
	end

	return false
end

function M:GetFirstClaimableRewardGuideId(profileId)
	local config = AgentProfileConfig.GetConfig(profileId)

	if not config then
		return nil
	end

	local rewards = config.TrustReward
	local nowTrust = self:GetTrustValue(profileId)

	if nowTrust == nil then
		return nil
	end

	for _, rewardId in ipairs(rewards) do
		local rewardCfg = AgentProfileRewardConfig.GetConfig(rewardId)
		local needTrust = rewardCfg.NeedTrust

		if needTrust <= nowTrust and not self:CheckRewardGot(profileId, rewardId) and rewardCfg.RewardType ~= AgentProfileRewardConfig.RewardTypeType.Disable then
			return rewardCfg.GuideId
		end
	end

	return nil
end

function M:CheckAnyHasRewardCanGot()
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

function M:CheckTotalProgressHasRewardCanGot()
	local totalProgressWeight = self:CalculateTotalProgressWeight()

	if totalProgressWeight <= 0 then
		return false
	end

	local completedWeight = 0

	for i = 0, AgentProfileConfig.count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			if self:GetIfAcquaintedByProfileId(config.Id) then
				completedWeight = completedWeight + (config.Weight or 0)
			end

			for _, targetId in ipairs(config.TrustTarget) do
				local targetConfig = AgentProfileTargetConfig.GetConfig(targetId)

				if targetConfig and self:CheckTargetFinish(config.Id, targetId) then
					completedWeight = completedWeight + (targetConfig.Weight or 0)
				end
			end
		end
	end

	local progress = completedWeight / totalProgressWeight
	local rewards = self:GetCompletionRewards(progress)

	for _, reward in ipairs(rewards) do
		if reward.canGet then
			return true
		end
	end

	return false
end

function M:GetAgentLocateCtrl(agentProfileId)
	if not agentProfileId or not self:GetIfAcquaintedByProfileId(agentProfileId) then
		return 0
	end

	local config = AgentProfileConfig.GetConfig(agentProfileId)

	if not config or not config.AgentId or config.AgentId == 0 then
		return 0
	end

	local agentCfg = AgentConfig.GetConfig(config.AgentId)
	local agentType = agentCfg.AgentSpecificType
	local currentSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(gBattleSpiritMgr.currentSpiritTemplateId)

	if currentSpiritCfg then
		local agentTypeNow = AgentConfig.GetConfig(currentSpiritCfg.AgentId).AgentSpecificType

		if agentType == agentTypeNow then
			return 1
		end
	end

	local scheduleInfo = gNpcDaliyManager:GetCurrentSchedule(agentType)

	if not scheduleInfo then
		return 2
	end

	local gpsId = gGpsTools.GetGpsId(EMapElementType.SpiritAcquisition, scheduleInfo.ActivityId)
	local element = gMapSystem.container:GetByGpsId(gpsId)
	local success = element ~= nil

	if not success then
		return 2
	end

	return 0
end

function M:GetScheduleInfo(agentProfileId)
	local config = AgentProfileConfig.GetConfig(agentProfileId)

	if not config or not config.AgentId or config.AgentId == 0 then
		return nil
	end

	local agentCfg = AgentConfig.GetConfig(config.AgentId)

	return gNpcDaliyManager:GetCurrentSchedule(agentCfg.AgentSpecificType)
end

function M:GetAgentActualPosition(agentProfileId)
	local config = AgentProfileConfig.GetConfig(agentProfileId)

	if not config or not config.AgentId or config.AgentId == 0 then
		return nil
	end

	local agentCfg = AgentConfig.GetConfig(config.AgentId)
	local agentType = agentCfg.AgentSpecificType
	local timeTableInfo = gNpcDaliyManager.NpcTimeTableInfos[agentType]

	if timeTableInfo and timeTableInfo.CurrentSpoonAgentId and timeTableInfo.CurrentSpoonAgentId ~= 0 and timeTableInfo.SpoonPosition then
		local spoonPos = timeTableInfo.SpoonPosition
		local worldPos = Vector3.New(spoonPos.X, spoonPos.Y, spoonPos.Z)

		if worldPos.x ~= 0 or worldPos.z ~= 0 then
			return worldPos
		end
	end

	local scheduleInfo = self:GetScheduleInfo(agentProfileId)

	if scheduleInfo and scheduleInfo.Position then
		local worldPos = Vector3.New(scheduleInfo.Position.X, scheduleInfo.Position.Y, scheduleInfo.Position.Z)

		if worldPos.x ~= 0 or worldPos.z ~= 0 then
			return worldPos
		end
	end

	return nil
end

function M:GetRewardItemType(dropId)
	if not dropId or dropId <= 0 then
		return 2
	end

	local dropConfig = LTConfig.DropConfig.GetConfig(dropId)

	if not dropConfig or not dropConfig.Item1 or #dropConfig.Item1 == 0 then
		return 2
	end

	local firstItem = dropConfig.Item1[1]

	if not firstItem or not firstItem.id1 or firstItem.id1 <= 0 then
		return 2
	end

	local itemConfig = LTConfig.CommonItemConfig.GetConfig(firstItem.id1)

	if not itemConfig or not itemConfig.SubType then
		return 2
	end

	if itemConfig.SubType == LTConfig.ConsumableTypeConfig.Character then
		return 1
	end

	if itemConfig.SubType == LTConfig.ConsumableTypeConfig.Vehicle then
		return 3
	end

	local weaponSubTypes = {
		LTConfig.ConsumableTypeConfig.Weapon,
		LTConfig.ConsumableTypeConfig.WeaponSkin
	}

	for _, wType in ipairs(weaponSubTypes) do
		if itemConfig.SubType == wType then
			return 0
		end
	end

	if itemConfig.SubType == LTConfig.ConsumableTypeConfig.AchievementBadge then
		return 1
	end

	return 2
end

function M:CalculateTotalProgressWeight()
	local totalWeight = 0

	for i = 0, AgentProfileConfig.count - 1 do
		local config = AgentProfileConfig.LoadAt(i)

		if config then
			totalWeight = totalWeight + (config.Weight or 0)

			for _, targetId in ipairs(config.TrustTarget) do
				local targetConfig = AgentProfileTargetConfig.GetConfig(targetId)

				if targetConfig then
					totalWeight = totalWeight + (targetConfig.Weight or 0)
				end
			end
		end
	end

	return totalWeight
end

function M:GetCompletionRewards(currentProgress)
	local completionRewards = ProfileConfig.CompletionReward

	if not completionRewards or #completionRewards == 0 then
		return {}
	end

	local rewardList = {}

	for i, rewardCfg in ipairs(completionRewards) do
		local isGot = self:CheckProgressRewardGot(i - 1)

		table.insert(rewardList, {
			index = i,
			percent = rewardCfg.percent,
			dropId = rewardCfg.dropId,
			canGet = rewardCfg.percent <= currentProgress and not isGot,
			isGot = isGot
		})
	end

	table.sort(rewardList, function (a, b)
		return a.percent < b.percent
	end)

	return rewardList
end

function M:PopUpAgentProfileTrustChange(profileId, nowValue, value)
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

function M:PopUpAgentProfile(profileInfo)
	local profileId = profileInfo.ProfileId
	local config = AgentProfileConfig.GetConfig(profileId)

	if config and config.NoTrustPop then
		return
	end

	table.insert(self.popupInfoList, profileInfo)

	self.waitCo = coroutine.stop(self.waitCo)
	self.waitCo = coroutine.start(function ()
		coroutine.wait(0.25)

		if LTConfig.PopupConfig.AreaFivePopUpLimitCount <= #self.popupInfoList then
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

gAgentTrustManager = gAgentTrustManager or C_AgentTrustManager.new()
