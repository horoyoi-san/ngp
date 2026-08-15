local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local VehicleConfig = LTConfig.VehicleConfig
local DispatchConfig = LTConfig.PoliceDispatchConfig
local FineConfig = LTConfig.PoliceFineConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local ViolationConfig = LTConfig.PoliceViolationConfig
local PoliceConfig = LTConfig.PoliceConfig
local AgentConfig = LTConfig.AgentConfig
local SummonConfig = LTConfig.SummonConfig
local PopupConfig = LTConfig.PopupConfig
local MessageConfig = LTConfig.MessageConfig
local FakeFileConfig = LTConfig.PoliceFakeFileConfig
local FakeFileState = UX.Game.PoliceFakeFileState
local FightSpiritConfig = LTConfig.FightSpiritConfig
local MyPlayerManager = gCS.MyPlayerManager
local SceneDataMgr = gCS.SceneDataMgr
local StaticProps = {}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
C_PolicePanelManager = DefClass("C_PolicePanelManager", C_PolicePanelManager, nil, StaticProps)
local M = C_PolicePanelManager

function M:InitData()
	self.baseStore = gStoreManager:GetStoreGroup("PoliceBasePanelStore")
	self.serviceData = {}
	self.weeklyServiceData = {}
	self.caseInfo = {}
	self.caseDict = {}
	self.caseCount = 0
	self.violationInfo = {}
	self.dispatchInfo = {}
	self.dispatchState = {}
	self.tid = 0
	self.skipNextWork = 0
	self.fakeFileInfo = {}
	self.fakeAgentDict = {}

	for i = 1, #PoliceConfig.FakeFileClueNumbers do
		local id = PoliceConfig.FakeFileClueNumbers[i]
		self.fakeAgentDict[id] = true
	end
end

function M:OnInit()
	self:InitData()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))
end

function M:OnBeforeSwitchScene(_, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:InitData()
	end
end

function M:OnBeginPromote()
	gSpiritJobManager:TryBeginPromote(JobClassConfig.Police)
end

function M:OnSkipNext(eventId)
	self.skipNextWork = eventId
end

function M:OnBeginWork()
	if self.skipNextWork ~= 0 then
		gMessageManager:SendMessage(self.skipNextWork)

		self.skipNextWork = 0
	end

	if not gSpiritJobManager:CheckIsCurrentjob(JobClassConfig.Police) then
		gClientToGameDelegate:AskStartJob(JobClassConfig.Police).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gMainPhoneUtils.CloseMainPhonePanel()
		end
	else
		gMainPhoneUtils.CloseMainPhonePanel()
	end
end

function M:OnFinishWork()
	gClientToGameDelegate:AskFinishJob().Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gMainPhoneUtils.CloseMainPhonePanel()
	end
end

function M:OnPoliceServiceDataSync(spiritId, serviceData, weeklyServiceData)
	self.serviceData[spiritId] = serviceData
	self.weeklyServiceData[spiritId] = weeklyServiceData

	self.baseStore:RefreshPage()
end

function M:OnSpiritPoliceJobInfoSync(spiritId, policeJobInfo)
	if not policeJobInfo then
		return
	end

	self.serviceData[spiritId] = policeJobInfo.DutyBasicInfo.ServiceData
	self.weeklyServiceData[spiritId] = policeJobInfo.DutyBasicInfo.WeeklyServiceData
	self.violationInfo[spiritId] = policeJobInfo.ViolationInfos
	self.dispatchInfo[spiritId] = policeJobInfo.DispatchInfos
	self.fakeFileInfo[spiritId] = policeJobInfo.PoliceFakeFileInfo

	self:SetCaseInfo(spiritId, policeJobInfo.CaseInfos)
	self.baseStore:RefreshPage()
	gPoliceJobManager:RefreshPoliceStage()
end

function M:OnSpiritPoliceCaseInfosSync(spiritId, cases)
	local preCaseCount = self.caseCount

	self:SetCaseInfo(spiritId, cases)
	self.baseStore:RefreshPage()

	if preCaseCount ~= self.caseCount then
		self:RefreshNotice(2)
	end
end

function M:OnSpiritPoliceViolationInfosSync(spiritId, violations)
	local lastInDue = self:CheckIsInViolation()
	self.violationInfo[spiritId] = violations

	self.baseStore:RefreshPage()

	local lastViolation = self:CheckLastViolation(spiritId)

	if not table.isNilOrEmpty(lastViolation) then
		if gCS.TimeManager.ServerUnixTime < lastViolation.LeaveDueTime then
			if not lastInDue then
				gNewPopupManager:PushPopup(PopupConfig.S_PoliceTaskHUDFailPanel, lastViolation)
			end
		else
			self:RefreshNotice(1)
		end
	end

	gPoliceJobManager:RefreshPoliceStage()
end

function M:OnPoliceDispatchInfosSync(spiritId, dispatchInfos)
	self.dispatchInfo[spiritId] = dispatchInfos

	self.baseStore:RefreshPage()
end

function M:OnPanelInit()
	self.tid = gSpiritManager:GetCurFirstSpiritTid()
end

function M:RefreshNotice(notice)
	if notice < 1 then
		return
	end

	gNewPopupManager:PushPopup(PopupConfig.S_PoliceResultTips, {
		notice = notice - 1
	})
end

function M:OpenMainPanel(args)
	args = args or {}
	args.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Police
	args.secondShowType = gClientConst.PoliceShowType.Home

	gMainPhoneUtils.ShowPhoneAppContent(args)
end

function M:OpenNoticePanel()
	gMainPhoneUtils.ShowPhoneAppContent({
		isFromMainPhone = false,
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Police,
		secondShowType = gClientConst.PoliceShowType.Notice
	})
end

function M:OpenPoliceVehicleList()
	self:SwitchCurrentPanel({
		secondShowType = gClientConst.PoliceShowType.Call,
		vehicleType = VehicleConfig.VehicleTypeType.PoliceCar,
		onCustomConfirmCallback = function (selectedVehicleId)
			local playerObj = MyPlayerManager.PlayerUnit.PlayerObj

			gVehicleGamePlayManager.cs_manager:AskSummonVehicle(selectedVehicleId, playerObj.position, playerObj.eulerAngles.y, function (isSuccess)
				local dialogId = isSuccess and PoliceConfig.AskVehicleSuccessDialogId or PoliceConfig.AskVehicleFailDialogId

				if dialogId ~= 0 then
					gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Phone)
				end
			end)
			gMainPhoneUtils.CloseMainPhonePanel()
		end
	})
end

function M:SwitchCurrentPanel(data)
	if not self.baseStore then
		return
	end

	self.baseStore:ShowContentPanel(data)
end

function M:CloseCurrentPanel()
	if not self.baseStore then
		return
	end

	self.baseStore:CloseContentPanel()
end

function M:SwitchMainPanel(data)
	if not self.baseStore or not self.baseStore.STATE_EnableOnce then
		return
	end

	self.baseStore.stackPanel:Clear()
	self.baseStore:ShowContentPanel(data)
end

function M:SetCaseInfo(spiritId, cases)
	self.caseInfo[spiritId] = cases
	self.caseCount = 0
	local length = cases.Count or 0

	if length > 0 then
		for i = 1, length do
			local caseInfo = cases[i]
			self.caseDict[caseInfo.Id] = caseInfo
			self.caseCount = self.caseCount + 1
		end
	end
end

function M:GetCaseInfo(caseId)
	return self.caseDict[caseId] or {}
end

function M:GetStateStr(caseInfo)
	local ret = {}

	if #caseInfo.Fines > 0 then
		table.insert(ret, TextScriptTextConfig.GetConfig(89901153).Text)
	end

	if caseInfo.Sentence > 0 then
		local inSentnce = caseInfo.Time + caseInfo.Sentence * gClientConst.SECONDS_PER_DAY

		if gCS.TimeManager.ServerUnixTime < inSentnce then
			table.insert(ret, TextScriptTextConfig.GetConfig(89901144).Text)
			table.insert(ret, TextScriptTextConfig.GetConfig(89901146).Text)
		else
			table.insert(ret, TextScriptTextConfig.GetConfig(89901145).Text)
			table.insert(ret, TextScriptTextConfig.GetConfig(89901149).Text)
		end
	elseif caseInfo.Sentence == 0 then
		table.insert(ret, TextScriptTextConfig.GetConfig(89901145).Text)
		table.insert(ret, TextScriptTextConfig.GetConfig(89901147).Text)
	else
		table.insert(ret, TextScriptTextConfig.GetConfig(89901145).Text)
		table.insert(ret, TextScriptTextConfig.GetConfig(89901148).Text)
	end

	return #ret > 0 and table.concat(ret, ",") or TextScriptTextConfig.GetConfig(89901148).Text
end

function M:GetTestFines()
	local ret = {}

	for i = 0, FineConfig.count - 1 do
		local cfg = FineConfig.LoadAt(i)

		table.insert(ret, cfg.Id)
	end

	return ret
end

function M:GetFineList(fines)
	local ret = {}
	local factor = 0

	for i = 1, #fines do
		local fine = fines[i]
		local cfg = FineConfig.GetConfig(fine)
		local ele = {
			label = cfg.Title
		}

		if PoliceConfig.FineFactorLine <= cfg.Factor then
			factor = 1
		end

		table.insert(ret, ele)
	end

	if #ret == 0 then
		table.insert(ret, {
			label = TextScriptTextConfig.GetConfig(89901148).Text
		})
	end

	return ret, factor
end

function M:GetResultList(caseInfo)
	local ret = {}
	local sentenceStr = TextScriptTextConfig.GetConfig(89901219).Text

	if #caseInfo.Fines > 0 then
		table.insert(ret, {
			label = TextScriptTextConfig.GetConfig(89901153).Text
		})

		for i = 1, #caseInfo.Fines do
			local fine = caseInfo.Fines[i]
			local cfg = FineConfig.GetConfig(fine)

			if cfg and PoliceConfig.FineFactorLine <= cfg.Factor then
				sentenceStr = TextScriptTextConfig.GetConfig(89901152).Text
			end
		end
	end

	if caseInfo.Sentence > 0 then
		table.insert(ret, {
			label = gString.Format(sentenceStr, caseInfo.Sentence)
		})
	elseif caseInfo.Sentence == 0 then
		table.insert(ret, {
			label = TextScriptTextConfig.GetConfig(89901147).Text
		})
	else
		table.insert(ret, {
			label = TextScriptTextConfig.GetConfig(89901148).Text
		})
	end

	return ret
end

function M:GetAwardByDropId(dropIds)
	local jobExp = 0
	local gold = 0

	if table.isNilOrEmpty(dropIds) then
		return jobExp, gold
	end

	for i = 1, #dropIds do
		local dropId = dropIds[i]
		local cfg = LTConfig.DropConfig.GetConfig(dropId)

		if cfg then
			gold = gold + cfg.Money

			for j = 1, #cfg.JobExp do
				if cfg.JobExp[j].Jobclassid == JobClassConfig.Police then
					jobExp = jobExp + cfg.JobExp[j].count

					break
				end
			end
		else
			print_error("#NoCreateIssue [PolicePanelManager] GetAwardByDropId failed, DropId =", dropId)
		end
	end

	return jobExp, gold
end

function M:GetOrderCaseInfo()
	local caseInfo = self.caseInfo[self.tid] or {}
	local ret = {}
	local length = caseInfo.Count or 0

	if length > 0 then
		for i = 1, length do
			local info = caseInfo[i]

			if info.Time <= gCS.TimeManager.ServerUnixTime then
				local ele = {
					id = #ret,
					cId = info.Id,
					time = info.Time
				}

				table.insert(ret, ele)
			end
		end

		table.sort(ret, function (a, b)
			if a.time == b.time then
				return a.cId < b.cId
			end

			return b.time < a.time
		end)
	end

	return ret
end

function M:CheckHasAward()
	local caseInfo = self.caseInfo[self.tid] or {}
	local length = caseInfo.Count or 0

	if length > 0 then
		for i = 1, length do
			if caseInfo[i].RewardTaken == false then
				return true
			end
		end
	end

	return false
end

function M:AskReceiveCaseAward(cId)
	gClientToGameDelegate:AskPoliceTakeCaseReward(cId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			local caseInfo = self.caseInfo[self.tid] or {}
			local length = caseInfo.Count or 0

			if length > 0 then
				for i = 1, length do
					local info = caseInfo[i]

					if info.Id == cId then
						info.RewardTaken = true

						break
					end
				end
			end

			local redDotKey = ("PhoneAppItemRedDot:%d"):format(LTConfig.MobileMenuSGuiConfig.PoliceId)

			gMainPhoneUtils.RefreshAppItemRedDot(LTConfig.MobileMenuSGuiConfig.PoliceId, redDotKey)
		else
			print_warn("AskReceiveCaseAward failed, error =", gCS.Error.GetNameById(err))

			return
		end
	end
end

function M:CheckLastViolation(spiritId)
	spiritId = spiritId or self.tid
	local violation = self.violationInfo[spiritId] or {}
	local lastTime = -math.huge
	local lastViolation = nil

	for i = 1, #violation do
		local ele = violation[i]

		if lastTime < ele.Time then
			lastTime = ele.Time
			lastViolation = violation[i]
		end
	end

	return lastViolation or {}
end

function M:CheckIsInViolation()
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local violation = self.violationInfo[spiritId] or {}
	local lastTime = -math.huge
	local lastViolation = nil

	for i = 1, #violation do
		local ele = violation[i]

		if lastTime < ele.Time then
			lastTime = ele.Time
			lastViolation = violation[i]
		end
	end

	if table.isNilOrEmpty(lastViolation) then
		return false, 0
	else
		return gCS.TimeManager.ServerUnixTime < lastViolation.LeaveDueTime, lastViolation.LeaveDueTime - gCS.TimeManager.ServerUnixTime
	end
end

function M:GetViolationInfo(vId)
	return ViolationConfig.GetConfig(vId)
end

function M:GetNoticeList(hasAward)
	local caseInfo = self.caseInfo[self.tid] or {}
	local ret = {}

	if hasAward then
		local length = caseInfo.Count or 0

		if length > 0 then
			for i = 1, length do
				local info = caseInfo[i]

				if info.Time <= gCS.TimeManager.ServerUnixTime then
					local proficiency, gold = self:GetAwardByDropId(info.BonusDrops)

					if proficiency > 0 or gold > 0 then
						local ele = {
							tIndex = 1,
							id = #ret,
							cId = info.Id,
							time = info.Time,
							rewardTaken = info.RewardTaken
						}

						table.insert(ret, ele)
					end
				end
			end
		end
	end

	local violationInfo = self.violationInfo[self.tid] or {}

	for i = 1, #violationInfo do
		local v = violationInfo[i]

		if v.Time <= gCS.TimeManager.ServerUnixTime then
			local ele = {
				tIndex = 0,
				id = #ret,
				cId = v.Id,
				time = v.Time,
				forceLeave = v.LeaveDueTime
			}

			table.insert(ret, ele)
		end
	end

	table.sort(ret, function (a, b)
		if a.rewardTaken ~= b.rewardTaken then
			return a.rewardTaken == false
		else
			return b.time < a.time
		end
	end)

	return ret
end

function M:GetViolationDesc(id)
	if id == ViolationConfig.FalseFineCarLimit then
		return gString.Format(TextScriptTextConfig.GetConfig(TextScriptTextConfig.FalseFineOffWork).Text, PoliceConfig.ForceQuitJobTime / 60)
	else
		return gString.Format(TextScriptTextConfig.GetConfig(89901150).Text, PoliceConfig.ForceQuitJobTime / 60)
	end
end

function M:GetViolationBeginDesc(time)
	local remainTime = time - gCS.TimeManager.ServerUnixTime

	return gString.Format(TextScriptTextConfig.GetConfig(89901151).Text, remainTime / 60, remainTime % 60)
end

function M:GetViolationSimpleDesc(time)
	local remainTime = time - gCS.TimeManager.ServerUnixTime

	return gString.Format(TextScriptTextConfig.GetConfig(89901168).Text, remainTime / 60, remainTime % 60)
end

function M:CallDispatch(data)
	local id = data.id

	if self:GetDispatchCD(id) > 0 then
		return
	end

	gClientToGameDelegate:AskPoliceDispatch(id).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			print_warn("AskPoliceDispatch failed, error =", gCS.Error.GetNameById(err))

			return
		end

		local cfg = DispatchConfig.GetConfig(id)

		if cfg.DialogId ~= 0 then
			gDialogManager:ShowGeneralDialog(cfg.DialogId, gDialogSource.Police)
		end

		local state = self.dispatchState[id]
		local skillId = 0

		if state then
			skillId = cfg.SwitchSkillId or 0
		else
			skillId = cfg.SkillId or 0
		end

		if skillId ~= 0 then
			gCS.BattleManager.UseSkillByPid(MyPlayerManager.PlayerUnit.Pid, skillId)
		end

		if cfg.CloseApp then
			gMainPhoneUtils.CloseMainPhonePanel()
		elseif self.baseStore then
			self.baseStore:RefreshPage()
		end
	end
end

function M:GetDispatchCD(id)
	if table.isNilOrEmpty(self.dispatchInfo[self.tid]) then
		return -1
	end

	local dispatchInfo = self.dispatchInfo[self.tid][id]

	if not dispatchInfo then
		return -1
	end

	return dispatchInfo.NextAvailableTime - gCS.TimeManager.ServerUnixTime
end

function M:CheckDispatchEnable(id)
	local cfg = DispatchConfig.GetConfig(id)

	if not cfg then
		return false
	end

	if not cfg.ShowInApp then
		return false
	end

	return true
end

function M:GetPoliceDispatchItemList()
	local supportList = {}
	local currentJob, jobCfg = gSpiritJobManager:GetAvailableJobByClass(JobClassConfig.Police)

	if not currentJob then
		return supportList
	end

	local dispatchInfo = self.dispatchInfo[self.tid]

	if table.isNilOrEmpty(dispatchInfo) then
		return supportList
	end

	for k, v in pairs(dispatchInfo) do
		if self:CheckDispatchEnable(v.Id) then
			local ele = {
				tIndex = 0,
				id = v.Id
			}

			table.insert(supportList, ele)
		end
	end

	while #supportList >= 1 and #supportList < 3 do
		table.insert(supportList, {
			tIndex = 1
		})
	end

	return supportList
end

function M:OnDispatchSwitch(id)
	self.dispatchState[id] = not self.dispatchState[id]
end

function M:CheckIsDogIn()
	local agnetId = gBattleMgr.SummonAgentId
	local agentCfg = nil
	local unit = SceneDataMgr.GetUnit(agnetId)

	if unit then
		agentCfg = LTConfig.AgentConfig.GetConfig(unit.ClientData.AgentId)
	end

	if not agentCfg then
		return false
	end

	return agentCfg.SummonTag == SummonConfig.Dog
end

function M:RenderSummaryTemplate(btn, isWeekly)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local tid = self.tid
	store.isWeekly = BOOL2CTL[isWeekly]
	local data = self.serviceData[tid]

	if isWeekly then
		data = self.weeklyServiceData[tid]
	end

	if table.isNilOrEmpty(data) then
		data = {
			PatrolTimes = 0,
			DispatchTimes = 0,
			ArrestTimes = 0
		}
	end

	store.respondLabel = data.DispatchTimes or 0
	store.partolLabel = data.PatrolTimes or 0
	store.catchLabel = data.ArrestTimes or 0
	btn.luaClick = self:CreateActionWithArgs("SwitchCurrentPanel", {
		secondShowType = gClientConst.PoliceShowType.Case
	})
end

function M:RenderPoliceLicenseTemplate(btn)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local spirit = gSpiritManager:GetSpirit(self.tid)
	local currentJob, jobCfg = gSpiritJobManager:GetAvailableJobByClass(JobClassConfig.Police)

	if not currentJob or not jobCfg then
		return
	end

	local levelCfg = gSpiritJobManager:GetLevelData(jobCfg, self.tid)
	local level = levelCfg and levelCfg.Level or 1
	store.levelText = string.format("Lv%d", level or 1)
	local canPromote = levelCfg.Exp <= currentJob.Exp and jobCfg.PromoteTask
	store.jobLabel = jobCfg.Name
	store.iconId = jobCfg.Icon
	local cfg = FightSpiritConfig.GetConfig(spirit.Id)
	store.nameLabel = cfg and cfg.Name or spirit.Name
	store.regLabel = gTimeUtils:DateFormat("%d-%02d-%02d", currentJob.RegisterTime)
	store.canPromote = BOOL2CTL[canPromote]
	store.vehicleBtn.luaClick = self:CreateAction("OpenPoliceVehicleList")

	if store.progressBar then
		store.progressBar.maxValue = levelCfg.Exp

		store.progressBar:ProgressToValue(currentJob.Exp)
	end

	store.promoteBtn.luaClick = self:CreateAction("OnBeginPromote")
	store.mistakeBtn.luaClick = self:CreateActionWithArgs("SwitchCurrentPanel", {
		secondShowType = gClientConst.PoliceShowType.Case
	})
	store.occupationBtn.luaClick = self:CreateActionWithArgs("SwitchCurrentPanel", {
		secondShowType = gClientConst.PoliceShowType.Occupation
	})
end

function M:RenderCurrentSpirit(btn)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local spirit = gSpiritManager:GetSpirit(self.tid)

	if not spirit then
		print_error("#NoCreateIssue [PolicePanelManager] RenderCurrentSpirit failed, spirit =", self.tid)

		return
	end

	store.headIcon = spirit.config.SHeadIconID
	local cfg = FightSpiritConfig.GetConfig(spirit.Id)
	store.nameLabel = cfg and cfg.Name or spirit.Name
end

function M:RenderSupportItem(btn, data)
	if data.tIndex > 0 then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cdTime = self:GetDispatchCD(data.id)
	local inCd = cdTime > 0
	local cfg = DispatchConfig.GetConfig(data.id)
	store.costLabel = cfg.Number
	store.nameLabel = cfg.Name
	store.iconId = cfg.Icon
	btn.guide.guideID = cfg.GuideId
	local isSwitch = not string.is_null_or_empty(cfg.SwitchSubTitle) or cfg.SwitchSkillId
	store.type = BOOL2CTL[isSwitch]

	if not string.is_null_or_empty(cfg.SubTitle) then
		store.hasSubTitle = BOOL2CTL[true]
		store.subTitle = self.dispatchState[data.id] and cfg.SwitchSubTitle or cfg.SubTitle
	end

	local isInOrVehicle = data.id == DispatchConfig.Dog and (self:CheckIsDogIn() or gPoliceJobManager.cs:IsPlayerInVehicle())
	btn.interactable = not inCd and not isInOrVehicle

	if inCd then
		store.countDown:SetActiveFastest(true)
		store.countDown:Play(cdTime)

		function store.countDown.luaFinished()
			btn.interactable = true
		end
	end

	if isInOrVehicle then
		store.countDown:SetActiveFastest(false)
	end

	function store.switchBtn.luaClick()
		self.dispatchState[data.id] = not self.dispatchState[data.id]
		local isSwitch = self.dispatchState[data.id] or false
		store.subTitle = isSwitch and cfg.SwitchSubTitle or cfg.SubTitle
	end
end

function M:GetNumberStr(num)
	if num > 0 then
		return "+" .. num, BOOL2CTL[true]
	elseif num == 0 then
		return "", BOOL2CTL[false]
	end

	return num, BOOL2CTL[true]
end

function M:GetAgentIcon(agentId)
	local agentCfg = AgentConfig.GetConfig(agentId)

	if not agentCfg then
		return 0
	end

	return agentCfg.HeadIcon
end

function M:GetAgentInfo(agentId)
	local agentCfg = AgentConfig.GetConfig(agentId)

	if not agentCfg then
		return {}
	end

	local ret = {
		name = agentCfg.Name,
		icon = agentCfg.HeadIcon
	}

	return ret
end

function M:CheckCanExit()
	return not gPoliceJobManager.fakeActive
end

function M:CheckFakeInfoState(id, targetState)
	local info = self:GetCurrentFakeFileInfo()
	local state = info and info.UnlockFileInfoDict[id] or FakeFileState.None

	return state == targetState
end

function M:AskReadPoliceFakeClueAgentInfoList(fakeFileIds)
	gClientToGameDelegate:AskReadPoliceFakeClueAgentInfoList(fakeFileIds).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		local info = self:GetCurrentFakeFileInfo()

		for i = 1, #fakeFileIds do
			local id = fakeFileIds[i]
			info.HistoryClueAgentInfoList[id].IsRead = true
		end
	end
end

function M:AskPoliceFakeFileAcceptEvent(fakeFileId)
	if not self:CheckFakeInfoState(fakeFileId, FakeFileState.Unlock) then
		return
	end

	gPanelManager:Close(gPanelId.POLICE_ARCHIVE_PANEL)

	gClientToGameDelegate:AskPoliceFakeFileAcceptTaskEvent().Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:OnSyncPoliceFakeFileInfo(spiritId, fakeInfo)
	local oldFake = self.fakeFileInfo[spiritId]
	self.fakeFileInfo[spiritId] = fakeInfo
	local hasNewNormal, hasNewImport = nil
	local hasNewPoint = 0

	if not oldFake then
		if #fakeInfo.HistoryClueAgentInfoList > 0 then
			hasNewNormal = {
				agentId = fakeInfo.HistoryClueAgentInfoList[1].AgentId
			}
		end

		for k, v in pairs(fakeInfo.UnlockFileInfoDict) do
			if v == FakeFileState.Unlock then
				local cfg = FakeFileConfig.GetConfig(k)
				hasNewImport = {
					agentId = cfg.AgentId
				}

				break
			end
		end

		hasNewPoint = fakeInfo.ClueValue
	else
		if #oldFake.HistoryClueAgentInfoList < #fakeInfo.HistoryClueAgentInfoList then
			hasNewNormal = {
				agentId = fakeInfo.HistoryClueAgentInfoList[#fakeInfo.HistoryClueAgentInfoList].AgentId
			}
		end

		for k, v in pairs(fakeInfo.UnlockFileInfoDict) do
			if v == FakeFileState.AcceptTask and oldFake.UnlockFileInfoDict[k] ~= FakeFileState.AcceptTask then
				local cfg = FakeFileConfig.GetConfig(k)
				hasNewImport = {
					agentId = cfg.AgentId
				}

				break
			end
		end

		hasNewPoint = fakeInfo.ClueValue - oldFake.ClueValue
	end

	self:PushPop(hasNewImport, hasNewNormal, hasNewPoint)
	gMessageManager:SendMessage(gEventConstants.POLICE_NEW_FAKE_FILE)
end

function M:PushPop(hasNewImport, hasNewNormal, hasNewPoint)
	if not table.isNilOrEmpty(hasNewNormal) then
		gNewPopupManager:PushPopup(PopupConfig.PoliceArchiveNormalTips, hasNewNormal)
	end

	if not table.isNilOrEmpty(hasNewImport) then
		gNewPopupManager:PushPopup(PopupConfig.S_PoliceArchiveTips, hasNewImport)
	end

	if hasNewPoint > 0 then
		local msg = {
			point = hasNewPoint
		}

		gNewPopupManager:PushPopup(PopupConfig.PoliceArchiveNewPoint, msg)
	end
end

function M:OnSyncPoliceFakeFileSingleInfo(spiritId, fakeFileId, agentId, curClueValue, fakeFileState)
	local hasNewPoint = 0

	if not self.fakeFileInfo[spiritId] then
		self.fakeFileInfo[spiritId] = {
			CurFakeFileId = fakeFileId,
			ClueValue = curClueValue,
			UnlockFileInfoDict = {},
			HistoryClueAgentInfoList = {
				Count = 0,
				Length = 0
			}
		}
		hasNewPoint = curClueValue
	else
		hasNewPoint = curClueValue - self.fakeFileInfo[spiritId].ClueValue
	end

	local fakeFileInfo = self.fakeFileInfo[spiritId]
	local oldFakeFileState = fakeFileInfo.UnlockFileInfoDict[fakeFileId] or FakeFileState.None
	self.fakeFileInfo[spiritId].UnlockFileInfoDict[fakeFileId] = fakeFileState
	self.fakeFileInfo[spiritId].ClueValue = curClueValue
	local hasNewNormal = nil

	if agentId ~= 0 then
		table.insert(fakeFileInfo.HistoryClueAgentInfoList, {
			IsRead = false,
			AgentId = agentId
		})

		hasNewNormal = {
			agentId = agentId
		}
	end

	local hasNewImport = nil

	if fakeFileState == FakeFileState.AcceptTask and oldFakeFileState ~= FakeFileState.AcceptTask then
		local cfg = FakeFileConfig.GetConfig(fakeFileId)
		hasNewImport = {
			agentId = cfg.AgentId
		}
	end

	self:PushPop(hasNewImport, hasNewNormal, hasNewPoint)
	gMessageManager:SendMessage(gEventConstants.POLICE_NEW_FAKE_FILE)
end

function M:GetCurrentFakeFileInfo()
	self.tid = gSpiritManager:GetCurFirstSpiritTid()

	return self.fakeFileInfo[self.tid] or {
		CurFakeFileId = 1,
		ClueValue = 0,
		UnlockFileInfoDict = {},
		HistoryClueAgentInfoList = {}
	}
end

function M:GetMainFakeList()
	local ret = {}

	self:OnPanelInit()

	for i = 0, FakeFileConfig.count - 1 do
		local cfg = FakeFileConfig.LoadAt(i)

		if cfg.FightSpiritId == self.tid then
			local ele = {
				id = cfg.Id
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

function M:GetNormalFakeList()
	local ret = {}

	self:OnPanelInit()

	local info = self:GetCurrentFakeFileInfo()

	if table.isNilOrEmpty(info) then
		return ret
	end

	for i = 1, #info.HistoryClueAgentInfoList do
		local ele = {
			id = i
		}

		table.insert(ret, ele)
	end

	return ret
end

function M:GetMainFakeInfo(fileId)
	local cfg = FakeFileConfig.GetConfig(fileId)
	local ele = {
		id = fileId,
		desc = cfg.Desc,
		agentId = cfg.AgentId,
		maxProgress = cfg.ClueValue,
		isUnlock = self:CheckFakeInfoState(fileId, FakeFileState.Unlock),
		isAccept = self:CheckFakeInfoState(fileId, FakeFileState.AcceptTask),
		isSubmit = self:CheckFakeInfoState(fileId, FakeFileState.SubmitTask)
	}

	return ele
end

function M:GetNormalFakeInfo(id)
	local info = self:GetCurrentFakeFileInfo()
	local ele = {
		id = id,
		agentId = info.HistoryClueAgentInfoList[id].AgentId,
		isRead = info.HistoryClueAgentInfoList[id].IsRead,
		isImport = self.fakeAgentDict[id] and true or false
	}

	return ele
end

function M:RemoveAllUnRead()
	local ret = {}
	local info = self:GetCurrentFakeFileInfo()

	if table.isNilOrEmpty(info) then
		return
	end

	for i = 1, #info.HistoryClueAgentInfoList do
		if not info.HistoryClueAgentInfoList[i].IsRead then
			table.insert(ret, i)
		end
	end

	if table.isNilOrEmpty(ret) then
		return
	end

	self:AskReadPoliceFakeClueAgentInfoList(ret)
end

return gPoliceJobManager and gPoliceJobManager.panelMgr or C_PolicePanelManager.new()
