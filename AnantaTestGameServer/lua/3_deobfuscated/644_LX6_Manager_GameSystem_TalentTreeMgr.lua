local TalentConfig = LTConfig.TalentTreeTalentConfig
local TalentTreeConfig = LTConfig.TalentTreeConfig
local JobConfig = LTConfig.UrbanJobConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local MessageConfig = LTConfig.MessageConfig
local PopupConfig = LTConfig.PopupConfig
local TalentTreeLevelConfig = LTConfig.TalentTreeLevelConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local PanelRedDotConfig = LTConfig.PanelRedDotConfig
local RedDotMgr = SGUI.RedDotMgr
local ItemReason = UX.Game.ItemReason
local StaticProps = {
	LOCK_TYPE = {
		EventCondition = 5,
		PreTalent = 2,
		TalentPoint = 4,
		Job = 1,
		IsUnlock = 3,
		None = 0
	}
}
C_TalentTreeMgr = DefClass("C_TalentTreeMgr", C_TalentTreeMgr, nil, StaticProps)
local M = C_TalentTreeMgr

function M:Log(...)
	print_debug("[C_TalentTreeMgr]", ...)
end

function M:ctor()
	self:Clear()

	self.LOCK_STATE = {
		LOCKED = 2,
		CAN_UNLOCK = 1,
		ACTIVE = 0
	}
	self.MAX_STATE = {
		TRUE = 1,
		LOCK = 2,
		FALSE = 0
	}
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, self:CreateAction(self.OnCurrentSpiritChange))

	self.jobClass2TalentDict = {}
	self.jobClass2TalentTreeDict = {}

	for i = 0, TalentConfig.count - 1 do
		local cfg = TalentConfig.LoadAt(i)
		local jCfg = JobConfig.GetConfig(cfg.JobRequest)
		local jobClass = jCfg and jCfg.JobClass or 0
		self.jobClass2TalentDict[jobClass] = self.jobClass2TalentDict[jobClass] or {}

		table.insert(self.jobClass2TalentDict[jobClass], cfg.Id)
	end

	for i = 0, TalentTreeConfig.count - 1 do
		local cfg = TalentTreeConfig.LoadAt(i)

		if cfg then
			self.jobClass2TalentTreeDict[cfg.JobClassId] = self.jobClass2TalentTreeDict[cfg.JobClassId] or {}

			table.insert(self.jobClass2TalentTreeDict[cfg.JobClassId], cfg.Id)
		end
	end

	self.baseKey = PanelRedDotConfig.GetConfig(PanelRedDotConfig.TalentTree).Name
	self.blockReson = {
		[ItemReason.TalentUpLevel] = true,
		[ItemReason.TalentReset] = true
	}
end

function M:OnExit()
	gNewGuideMgr:NotifySignal(EGuideSignal.TalentTreeClose)
end

function M:OnBeforeSwitchScene(_, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:Clear()
	end
end

function M:OnCurrentSpiritChange()
	gRedPointMgr:ClearRedDot(self.baseKey)
	self:CheckHasCanUnLockTalent()
end

function M:OnSyncSpiritJobTalentPoint(spiritId, jobClassId, talentPoint, reason)
	local spirit = gSpiritManager:GetSpirit(spiritId)

	if not spirit then
		return
	end

	self:Log("OnSyncSpiritJobTalentPoint", spiritId, jobClassId, talentPoint, reason)

	local jobId = 0
	local talentInfo = spirit.SpiritInfo.TalentInfo

	if jobClassId ~= 0 then
		local jobInfo = gSpiritJobManager:GetAvailableJobByClass(jobClassId)

		if table.isNilOrEmpty(jobInfo) then
			return
		end

		talentInfo = jobInfo.TalentInfo
		jobId = jobInfo.Job
	end

	local diff = talentPoint - talentInfo.TalentPoint

	if diff > 0 and self:CheckTalentTreeSystemUnlock() and not self.blockReson[reason] then
		local msg = {
			jobId = jobId,
			agentType = gNpcFavorManager:GetAgentTypeByFightSpiritId(spiritId),
			diff = diff
		}

		gNewPopupManager:PushPopup(PopupConfig.S_TalentPointTopTips, msg)
	end

	talentInfo.TalentPoint = talentPoint

	self:CheckHasCanUnLockTalent()
	gMessageManager:SendMessage(gEventConstants.SPIRIT_TALENT_CHANGE, {
		spiritId = spiritId,
		jobId = jobId,
		talentPoint = talentPoint
	})
end

function M:OnSyncActiveSpiritJobTalent(spiritId, jobClassId, talentId, layer)
	local spirit = gSpiritManager:GetSpirit(spiritId)

	if not spirit then
		return
	end

	local talentCfg = TalentConfig.GetConfig(talentId)

	if not talentCfg then
		return
	end

	local jobId = 0
	local talentInfo = spirit.SpiritInfo.TalentInfo

	if jobClassId ~= 0 then
		local jobInfo = gSpiritJobManager:GetAvailableJobByClass(jobClassId)

		if table.isNilOrEmpty(jobInfo) then
			return
		end

		talentInfo = jobInfo.TalentInfo
		jobId = jobInfo.Job
	end

	talentInfo.UnlockTalentInfoDict[talentId] = {
		TalentId = talentId,
		Layer = layer
	}

	self:CheckHasCanUnLockTalent()
	gMessageManager:SendMessage(gEventConstants.SPIRIT_TALENT_CHANGE, {
		spiritId = spiritId,
		jobId = jobId,
		talentId = talentId
	})
end

function M:OnStartCurrent()
	local spirit = gSpiritManager:GetSpirit(gBattleSpiritMgr.currentSpiritTemplateId)

	if not spirit then
		return
	end

	self.cacheJobDict = {
		[0] = true
	}
	self.jobClassId2TalentInfoDict = {
		[0] = spirit.SpiritInfo.TalentInfo
	}
	self.jobClassId2JobIdDict = {}
	local jobClassList = gSpiritJobManager:GetAvailableJobClass()

	for i = 1, #jobClassList do
		local jobClassId = jobClassList[i]
		local jobList = gSpiritJobManager:GetJobListByClassId(jobClassId)

		for j = 1, #jobList do
			local jobId = jobList[j].id
			local jobInfo = spirit.SpiritInfo.SpiritJobInfo.AvailableJobs[jobId]

			if not table.isNilOrEmpty(jobInfo) then
				self.cacheJobDict[jobId] = true
				self.jobClassId2TalentInfoDict[jobClassId] = jobInfo.TalentInfo
				self.jobClassId2JobIdDict[jobClassId] = jobId

				self:cachePreJob(jobId)
			end
		end
	end
end

function M:Clear()
	self.jobClassId2TalentInfoDict = {}
	self.jobClassId2JobIdDict = {}
	self.cacheJobDict = {}
	self.jobTalent = {}
	self.commonTalentExp = 0
	self.skipNext = 0
end

function M:cachePreJob(jobId)
	local cfg = JobConfig.GetConfig(jobId)

	if not cfg then
		return
	end

	self.cacheJobDict[jobId] = true

	return self:cachePreJob(cfg.PreJob)
end

function M:GetCurrentTalentPoint(jobClassId)
	local talentInfo = self.jobClassId2TalentInfoDict[jobClassId]

	return talentInfo and talentInfo.TalentPoint or 0
end

function M:GetCurrentTalentDict(jobClassId)
	local talentInfo = self.jobClassId2TalentInfoDict[jobClassId]

	return talentInfo and talentInfo.UnlockTalentInfoDict or {}
end

function M:CheckPreTalentIsUnLocked(talentId, jobClassId)
	local cfg = TalentConfig.GetConfig(talentId)
	local talentDict = self:GetCurrentTalentDict(jobClassId)

	for i = 1, #cfg.PreTalentIds do
		local id = cfg.PreTalentIds[i]
		local talentCfg = TalentConfig.GetConfig(id)

		if talentCfg then
			local talentInfo = talentDict[id]

			if talentInfo and talentInfo.Layer > 0 then
				return true
			end
		end
	end

	return table.isNilOrEmpty(cfg.PreTalentIds)
end

function M:CheckTalentIsLocked(talentId, jobClassId)
	local talentCfg = TalentConfig.GetConfig(talentId)

	if not talentCfg then
		return false
	end

	local talentDict = self:GetCurrentTalentDict(jobClassId)
	local talentInfo = talentDict[talentId]

	if table.isNilOrEmpty(talentInfo) then
		return true
	end

	return talentInfo.Layer < talentCfg.LayerNum
end

function M:GetJobClassTab(jobClass)
	local jobClassList = gSpiritJobManager:GetAvailableJobClass()
	local currentJobClass = jobClass and jobClass or gSpiritJobManager.GetCurSpiritJobClassId()
	local jobDict = {
		[0] = true
	}

	for i = 1, #jobClassList do
		jobDict[jobClassList[i]] = true
	end

	local ret = {}

	for i = 0, TalentTreeConfig.count - 1 do
		local cfg = TalentTreeConfig.LoadAt(i)

		if jobDict[cfg.JobClassId] and gSystemUnlockMgr:IsUnlockGroup(cfg.SystemIdList) then
			local ele = {
				id = cfg.Id,
				current = cfg.JobClassId == currentJobClass,
				guideId = cfg.GuideId,
				title = cfg.Name,
				iconId = cfg.IconId
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:RefreshTalentToolTip(toolTip, talentId, jobClassId, closeBtnCb)
	local store = gStoreManager:GetStoreGroup("TalentToolTipStore"):GetStoreByWidget(toolTip)

	if not store then
		return nil
	end

	local cfg = TalentConfig.GetConfig(talentId)

	if not cfg then
		print_error("[TalentTreeMgr] RefreshTalentToolTip talentId not exist: talentId = ", talentId, "jobClassId = ", jobClassId)

		return store
	end

	local jCfg = nil

	if jobClassId ~= 0 then
		jCfg = JobConfig.GetConfig(cfg.JobRequest)

		if not jCfg or jCfg.JobClass ~= jobClassId then
			return store
		end
	end

	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId
	local canUnLock, lockType = self:CheckTalentCanUnlock(talentId)
	local talentDict = self:GetCurrentTalentDict(jobClassId)
	local talentInfo = talentDict[talentId]
	local currentLv = talentInfo and talentInfo.Layer or 0
	store.nameLabel = cfg.Name
	store.iconId = cfg.IconId
	local hasLv = cfg.LayerNum > 1

	store.descList:SetSimpleList(0)

	for i = 1, #cfg.Description do
		local title = cfg.Description[i]
		local isActive = i <= currentLv

		if hasLv then
			store.descList:AddSimpleLabel(0, gString.Format(TextScriptTextConfig.GetConfig(89901298).Text, i), i, false, isActive)
		end

		store.descList:AddSimpleLabel(0, title, i, false, isActive)
	end

	store.descList:RefreshList()

	store.hasLv = BOOL2CTL[hasLv]
	store.lvLabel = gString.Format(TextScriptTextConfig.GetConfig(89901299).Text, currentLv, cfg.LayerNum)
	store.jobName = jCfg and jCfg.Name or ""
	store.consumeCountLabel = cfg.CostPoint
	store.detailIcon = cfg.DetailIconId
	store.hasImg = BOOL2CTL[cfg.DetailIconId > 0]
	store.closeBtn.luaClick = closeBtnCb
	store.lockType = lockType

	if lockType == StaticProps.LOCK_TYPE.Job then
		store.lockLabel = gString.Format(TextScriptTextConfig.GetConfig(89901119).Text, store.jobName)
	elseif lockType == StaticProps.LOCK_TYPE.PreTalent then
		store.lockLabel = TextScriptTextConfig.GetConfig(89901118).Text
	elseif lockType == StaticProps.LOCK_TYPE.IsUnlock then
		store.lockLabel = TextScriptTextConfig.GetConfig(89901266).Text
	elseif lockType == StaticProps.LOCK_TYPE.TalentPoint then
		store.lockLabel = TextScriptTextConfig.GetConfig(89901267).Text
	elseif lockType == StaticProps.LOCK_TYPE.EventCondition then
		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.TalentTree, cfg.Id, gBattleSpiritMgr.currentSpiritTemplateId)
		store.lockLabel = gString.Format(TextScriptTextConfig.GetConfig(89901338).Text, cfg.MaxProgress - progress)
	end

	store.activeBtn.interactable = canUnLock

	function store.activeBtn.luaClick()
		self:AskActiveTalent(spiritId, jobClassId, talentId)
	end

	store.progress:ProgressToValue(0, 0, 0, DG.Tweening.Ease.Linear)

	return store
end

function M:GetCurrentGraphPath(treeId)
	local cfg = TalentTreeConfig.GetConfig(treeId)

	if not cfg then
		return "", 1
	end

	local talentDict = self:GetCurrentTalentDict(cfg.JobClassId)
	local talentCount = table.count(talentDict)

	for i = #cfg.Path, 1, -1 do
		local path = cfg.Path[i]
		local need = cfg.TalentCountNeed[i]

		if need <= talentCount then
			return path, i, i == #cfg.Path and 0 or cfg.TalentCountNeed[i + 1]
		end
	end

	return "", 1
end

function M:AskActiveTalent(spiritId, jobClassId, talentId, callback)
	spiritId = spiritId or gBattleSpiritMgr.currentSpiritTemplateId

	gClientToGameDelegate:AskActiveSpiritJobTalentLayer(spiritId, jobClassId, talentId, 1).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_warn("C_TalentTreeMgr AskActiveTalent err:", err)

			return
		end

		if callback then
			callback()
		end

		local msg = {
			spiritId = spiritId,
			jobClassId = jobClassId,
			talentId = talentId
		}

		gMessageManager:SendMessage(gEventConstants.SPIRIT_TALENT_ACTIVE, msg)
	end
end

function M:CheckHasTalentTree()
	local tabList = self:GetJobClassTab()

	return not table.isNilOrEmpty(tabList)
end

function M:CheckTalentCanUnlock(talentId, skipTalentPoint)
	local cfg = TalentConfig.GetConfig(talentId)

	if not cfg then
		return false, StaticProps.LOCK_TYPE.None
	end

	local jobCfg = JobConfig.GetConfig(cfg.JobRequest)

	if cfg.JobRequest ~= 0 and not jobCfg then
		return false, StaticProps.LOCK_TYPE.None
	end

	local isReadyJob = self.cacheJobDict[cfg.JobRequest] or false

	if not isReadyJob then
		return false, StaticProps.LOCK_TYPE.Job
	end

	local jobClassId = jobCfg and jobCfg.JobClass or 0
	local isReadyTalent = self:CheckPreTalentIsUnLocked(talentId, jobClassId)

	if not isReadyTalent then
		return false, StaticProps.LOCK_TYPE.PreTalent
	end

	local isLock = self:CheckTalentIsLocked(talentId, jobClassId)

	if not isLock then
		return false, StaticProps.LOCK_TYPE.IsUnlock
	end

	local talentPoint = self:GetCurrentTalentPoint(jobClassId)
	local isLackTalentPoint = talentPoint < cfg.CostPoint

	if talentPoint < cfg.CostPoint and not skipTalentPoint then
		return false, StaticProps.LOCK_TYPE.TalentPoint
	end

	if not gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.TalentTree) then
		return false, StaticProps.LOCK_TYPE.EventCondition
	end

	return true, isLackTalentPoint and StaticProps.LOCK_TYPE.TalentPoint or StaticProps.LOCK_TYPE.None
end

function M:CheckHasCanUnLockTalent()
	self:OnStartCurrent()

	local jobClassList = gSpiritJobManager:GetAvailableJobClass()

	table.insert(jobClassList, 0)

	for i = 1, #jobClassList do
		local jobClass = jobClassList[i]
		local talentDict = self.jobClass2TalentDict[jobClass] or {}
		local canUnlock = false

		for j = 1, #talentDict do
			local talentId = self.jobClass2TalentDict[jobClass][j]
			canUnlock, _ = self:CheckTalentCanUnlock(talentId)

			if canUnlock then
				break
			end
		end

		local treeDict = self.jobClass2TalentTreeDict[jobClass] or {}

		for j = 1, #treeDict do
			local treeId = self.jobClass2TalentTreeDict[jobClass][j]
			local redKey = self:GetRedDot(treeId)

			RedDotMgr.LuaSetRedDot(canUnlock, redKey)
		end
	end
end

function M:CheckTalentTreeSystemUnlock()
	return gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.TalentTree)
end

function M:CheckIsSkipNext()
	if self.skipNext > 0 then
		self.skipNext = self.skipNext - 1

		return true
	end

	return false
end

function M:GetSpiritActiveTalent(spiritId, jobClassId)
	spiritId = spiritId or gBattleSpiritMgr.currentSpiritTemplateId
	local spirit = gSpiritManager:GetSpirit(spiritId)

	if not spirit then
		return 0
	end

	local talentInfo = spirit.SpiritInfo.TalentInfo

	if jobClassId ~= 0 then
		local jobInfo = gSpiritJobManager:GetAvailableJobByClass(jobClassId)

		if table.isNilOrEmpty(jobInfo) then
			return
		end

		talentInfo = jobInfo.TalentInfo
	end

	local totalCount = 0

	for k, v in pairs(talentInfo.UnlockTalentInfoDict) do
		totalCount = totalCount + v.Layer
	end

	return totalCount
end

function M:OnSyncCommonTalentInfo(changeExp, exp)
	self:Log("OnSyncCommonTalentInfo", changeExp, exp)

	self.commonTalentExp = exp

	if changeExp ~= 0 and self:CheckTalentTreeSystemUnlock() then
		if changeExp > 0 then
			local msg = {
				spiritId = 0,
				diff = changeExp
			}

			gNewPopupManager:PushPopup(PopupConfig.AgentTalentExpTip, msg)
		end

		gMessageManager:SendMessage(gEventConstants.SPIRIT_TALENT_CHANGE)
	end
end

function M:CheckHasEnoughExp2LevelUp()
	local currentExp, maxExp, _ = self:GetCurrentExpInfo()

	return maxExp <= currentExp + self.commonTalentExp and currentExp ~= maxExp
end

function M:OnSyncSpiritTalentExpAndLevel(spiritId, addExp, exp, level)
	local spirit = gSpiritManager:GetSpirit(spiritId)

	if not spirit then
		return
	end

	self:Log("OnSyncSpiritTalentExpAndLevel", spiritId, addExp, exp, level)

	local talentInfo = spirit.SpiritInfo.TalentInfo

	if addExp ~= 0 and self:CheckTalentTreeSystemUnlock() and not self:CheckIsSkipNext() then
		local msg = {
			spiritId = spiritId,
			diff = addExp
		}

		gNewPopupManager:PushPopup(PopupConfig.AgentTalentExpTip, msg)
	end

	talentInfo.Exp = exp
	talentInfo.Level = level

	gMessageManager:SendMessage(gEventConstants.SPIRIT_TALENT_CHANGE)
end

function M:Test()
	local msg = {
		spiritId = 15020992,
		diff = 0
	}

	gNewPopupManager:PushPopup(PopupConfig.AgentTalentExpTip, msg)
end

function M:GetCurrentExpInfo(spiritId)
	spiritId = spiritId or gBattleSpiritMgr.currentSpiritTemplateId
	local spirit = gSpiritManager:GetSpirit(spiritId)

	if not spirit then
		return 0, 0, 0
	end

	local talentInfo = spirit.SpiritInfo.TalentInfo
	local cfg = TalentTreeLevelConfig.GetConfig(talentInfo.Level)

	if not cfg or talentInfo.Level == TalentTreeLevelConfig.count then
		return 0, 0, talentInfo.Level
	end

	return talentInfo.Exp, cfg.Exp, talentInfo.Level
end

function M:CanLevelUp()
	local _, _, currentLevel = self:GetCurrentExpInfo()
	local nextLevel = currentLevel + 1
	local nextCfg = TalentTreeLevelConfig.GetConfig(nextLevel)
	local currentCfg = TalentTreeLevelConfig.GetConfig(currentLevel)

	if not nextCfg then
		return self.MAX_STATE.TRUE, 0
	end

	if currentCfg.Fan <= gPlayerManager.infoMinor.bindData.fan123 then
		return self.MAX_STATE.FALSE, 0
	end

	return self.MAX_STATE.LOCK, currentCfg.Fan
end

function M:OnResetTalentTree(jobClassId)
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId

	self:Log("OnResetTalentTree", spiritId, jobClassId)

	gClientToGameDelegate:AskResetSpiritJobTalent(spiritId, jobClassId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:OnCharacterTalentLevelup(exp)
	if exp <= 0 then
		return
	end

	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId

	self:Log("OnCharacterTalentLevelup", spiritId, exp)

	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId
	self.skipNext = self.skipNext + 1

	gClientToGameDelegate:AskConvertCommonSpiritTalentExp(spiritId, exp).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:GetRedDot(treeId)
	local cfg = TalentTreeConfig.GetConfig(treeId)

	if not cfg then
		return ""
	end

	local redCfg = PanelRedDotConfig.GetConfig(cfg.RedDotId)

	return ("%s/%s"):format(self.baseKey, redCfg.Name)
end

gTalentTreeMgr = gTalentTreeMgr or C_TalentTreeMgr.new()
