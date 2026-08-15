local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local WasherJobClassId = JobClassConfig.Washer
local M = gWasherManager or {}
M.IsInit = M.IsInit or false

function M:OnInit()
	if self.IsInit then
		return
	end

	self.appShown = false
	self.IsInit = true
	self.washerJobInfo = nil
	self.isWasherJob = false
	self.isWithoutOrder = false
end

function M:GetWasherJobInfo()
	return self.washerJobInfo
end

function M:SetWasherJobInfo(washerJobInfo)
	self.washerJobInfo = washerJobInfo
	self.isWasherJob = washerJobInfo and washerJobInfo.CurMissionId > 0

	gMessageManager:SendMessage(gEventConstants.ON_WASHER_INFO_UPDATE)
end

function M:ResetWasherJobInfo()
	self.washerJobInfo = nil

	gMessageManager:SendMessage(gEventConstants.ON_WASHER_INFO_UPDATE)
end

function M:RefreshWasherJobInfo()
	gClientToGameDelegate:AskGetWasherMissionInfo(false).Callback = function (errorId, washerJobInfo)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
			gWasherManager:ResetWasherJobInfo()
		else
			gWasherManager:SetWasherJobInfo(washerJobInfo)
		end
	end
end

function M:SetCurrentCleaningInfo(serverStart, info)
	self.serverStart = serverStart
	self.curCleaningInfo = info
end

function M:SwitchAppTab(secondTab, needJobInfo)
	if not needJobInfo or self.washerJobInfo then
		gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_SHOW, {
			secondShowType = secondTab,
			washerJobInfo = self.washerJobInfo
		})
	else
		gClientToGameDelegate:AskGetWasherMissionInfo(false).Callback = function (errorId, washerJobInfo)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)
				gWasherManager:ResetWasherJobInfo()

				return
			end

			gWasherManager:SetWasherJobInfo(washerJobInfo)
			gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_SHOW, {
				secondShowType = secondTab,
				washerJobInfo = washerJobInfo
			})
		end
	end
end

function M.OnWasherMissionFinished(res)
	local washerMissionResult = {
		missionId = res.MissionId,
		eventId = res.EventId,
		progress = res.Progress,
		rewardRate = res.RewardRate,
		proficiencyRate = res.ProficiencyRate,
		usingTime = res.UsingTime,
		money = res.AddMoney,
		talentPoint = res.TalentPoint
	}

	if gWasherManager.appShown then
		gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_SHOW, {
			secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.COMPLETE_DETAIL,
			washerMissionResult = washerMissionResult
		})
	else
		gMainPhoneUtils.ShowPhoneAppContent({
			isFromMainPhone = true,
			isFromFinish = true,
			showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Washer,
			secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.COMPLETE_DETAIL,
			washerMissionResult = washerMissionResult
		})
	end
end

function M.GetWasherMissionLevel(progress)
	local washerMissionCleanessConfig = LTConfig.WasherMissionCleanessConfig

	for i = 0, washerMissionCleanessConfig.count - 1 do
		local cfg = washerMissionCleanessConfig.LoadAt(i)

		if cfg and cfg.Rating <= progress then
			return i
		end
	end

	return washerMissionCleanessConfig.count - 1
end

function M.GetPlayerAvatarID()
	local jobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)
	local iconId = nil

	if jobId and jobId > 0 then
		iconId = gSpiritJobManager.GetAvailableJobAvatarId(LTConfig.UrbanJobJobClassConfig.Washer)
	end

	if not iconId then
		local selfTemplateId = gCS.BattleNetcodeUtils.GetCurrentSpiritTemplateId(gPlayerManager:GetLoginRolePid())

		if selfTemplateId then
			local fsConfig = LTConfig.FightSpiritConfig.GetConfig(selfTemplateId)

			if fsConfig then
				iconId = fsConfig.SHeadIconID
			end
		end
	end

	return iconId
end

function M.GetMainContentSpiritName()
	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()

	if currentSpiritId == LTConfig.FightSpiritConfig.DefaultMale or currentSpiritId == LTConfig.FightSpiritConfig.DefaultFemale then
		return gPlayerManager.infoLogin.bindData.name
	else
		local fightSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(currentSpiritId)

		return fightSpiritCfg.Name
	end
end

function M.RefreshWasherAvatarView(avatarWidget, needClick)
	local avatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	avatarStore.headIcon = gWasherManager.GetPlayerAvatarID()

	if needClick then
		function avatarStore.button.luaClick()
			gWasherManager:SwitchAppTab(gClientConst.WASHER_APP_SHOW_TYPE.ACCOUNT, true)
		end
	end
end

function M.RefreshOrderDetailView(orderStore, logStore, washerMissionResult)
	local progress = math.max(0, math.min(100, math.floor(washerMissionResult.progress * 10) * 0.1))
	orderStore.integrity = progress
	orderStore.progressBar.value = progress
	logStore.rankControl = gWasherManager.GetWasherMissionLevel(progress)
	logStore.money = washerMissionResult.money
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)
	local targetJobInfo = gSpiritJobManager.GetCurSpiritJob(targetJobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(targetJobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(urbanJobCfg)

	if urbanJobCfg and levelCfg then
		logStore.jobNameText = urbanJobCfg.Name
		logStore.jobLevelText = string.format("Lv.%d", targetJobInfo.Level)

		logStore.jobExpBar:ResetValue(targetJobInfo.Exp, levelCfg.Exp, 1, 0, 0, 0)
	end

	local missionCfg = LTConfig.WasherConfig.GetConfig(washerMissionResult.missionId)

	if missionCfg then
		orderStore.name = missionCfg.QuestName
		orderStore.startText = missionCfg.LocationName
		local location = missionCfg.QuestLocation
		local targetPos = gSpoonMgr:GetWayPointById(location)

		if targetPos then
			local playerPosition = gClientUtils.GetPlayerPosition()
			playerPosition = Vector3.New(playerPosition.X, playerPosition.Y, playerPosition.Z)
			local distance = Vector3.Distance(playerPosition, targetPos)
			orderStore.startDistance = gClientUtils.FormatDistance(distance)
		else
			print_error("获取spoon位置失败，检查配置是否正确！id:" .. tostring(missionCfg.Id))
		end

		if missionCfg.ProficiencyDropId then
			local dropCfg = LTConfig.DropConfig.GetConfig(missionCfg.ProficiencyDropId)

			if dropCfg then
				if dropCfg.JobExp and #dropCfg.JobExp > 0 then
					local jobExpInfo = dropCfg.JobExp[1]
					local proficiencyExp = jobExpInfo.count * washerMissionResult.proficiencyRate
					logStore.jobExpText = math.ceil(proficiencyExp)
				else
					logStore.jobExpText = 0
				end
			end
		end
	end
end

function M:OpenTaskGuidePanel(isCar, isWithoutOrder)
	self.isWasherJob = true
	self.isWithoutOrder = isWithoutOrder

	gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Cleaner, {
		isCar = isCar,
		isWithoutOrder = isWithoutOrder
	})
end

function M:CloseTaskGuidePanel()
	self.isWasherJob = false

	gTaskUtils:CloseTaskGuideCurTab()
end

function M:AskAcceptWasherMission(index, missionId, callback)
	local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()
	local isWasher = currentJobClassId == WasherJobClassId

	if not isWasher then
		gClientToGameDelegate:AskStartJob(WasherJobClassId).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			self:_AskAcceptWasher(index, missionId, callback)
		end
	else
		self:_AskAcceptWasher(index, missionId, callback)
	end
end

function M:_AskAcceptWasher(index, missionId, callback)
	gClientToGameDelegate:AskAcceptWasherMission(index, missionId).Callback = function (errorId)
		if callback then
			callback()
		end

		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_ACCEPT_WASHER_MISSION, index, missionId)
	end
end

function M:AskFinishWasherMission(isNeedResult)
	if not self.washerJobInfo or not self.washerJobInfo.CurMissionEventId or self.washerJobInfo.CurMissionEventId == 0 then
		print_error("#WasherManager AskFinishWasherMission failed: no current mission")

		return
	end

	local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()
	local isWasher = currentJobClassId == WasherJobClassId

	self:SendProgress(true)

	if isNeedResult then
		gClientToGameDelegate:AskFinishWasherMission(self.washerJobInfo.CurMissionEventId).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			if isWasher then
				gClientToGameDelegate:AskFinishJob(WasherJobClassId).Callback = function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)

						return
					end
				end
			end
		end
	else
		local taskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

		if not taskId or taskId == 0 then
			return
		end

		gClientToGameDelegate:AskDeleteTask(taskId, true).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			if isWasher then
				gClientToGameDelegate:AskFinishJob(WasherJobClassId).Callback = function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)

						return
					end
				end
			end
		end
	end
end

function M:SendProgress(force)
	force = force or false

	L50.L50App.Scene.WashMgr:TrySendProgress(force)
end

function M:GetCurrentHistoryInfo()
	local curSpiritId = gSpiritManager:GetCurFirstSpiritTid()

	if not curSpiritId then
		print_error("C_CleanerAccountPanelStore:OnInitContent curSpiritId is nil")

		return nil
	else
		local info = self.washerJobInfo.Spirit2HistoryMissionInfo[curSpiritId]

		if not info then
			print_warn("C_CleanerAccountPanelStore:OnInitContent info is nil")
		end

		return info
	end
end

gWasherManager = M
