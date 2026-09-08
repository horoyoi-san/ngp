-- Original chunk: @Lua\LuaFiles\LX6\Manager\Washer\WasherManager.lua
-- Decompiled from: 00759_WasherManager.lua_88f107f07950.luajit

local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local WasherJobClassId = JobClassConfig.Washer
local M = gWasherManager or {}
M.IsInit = M.IsInit or false

M.OnInit = function(self)
	if self.IsInit then
		return
	end

	self.appShown = false
	self.IsInit = true
	self.washerJobInfo = nil
	self.showWasherHud = false
	self.showWasherHudNoJob = false
	self.lastProcessTime = -1
	self.processDelayTime = 0.5
	self.isRefreshingJobInfo = false
	self.isListeningTaskChange = false

	self.taskChangeHandler = function()
		self:RefreshWasherJobInfo()
	end

	self.cachedPartProgressList = nil
	self.isListeningPartProgress = false
	self.showGlueHud = false

	self.partProgressHandler = function(eventId, data)
		self.cachedPartProgressList = data[2]:ToTable()
	end
end

M.OnAppOpen = function(self)
	self.appShown = true

	self:RegisterTaskChangeListener()
end

M.OnAppClose = function(self)
	self.appShown = false

	self:UnregisterTaskChangeListenerIfIdle()
end

M.RegisterTaskChangeListener = function(self)
	if self.isListeningTaskChange then
		return
	end

	self.isListeningTaskChange = true

	gMessageManager:AddMessageListener(gEventConstants.TASK_EVENT_CHANGE, self.taskChangeHandler)
end

M.UnregisterTaskChangeListenerIfIdle = function(self)
	if self.showWasherHud or self.appShown then
		return
	end

	if not self.isListeningTaskChange then
		return
	end

	self.isListeningTaskChange = false

	gMessageManager:RemoveMessageListener(gEventConstants.TASK_EVENT_CHANGE, self.taskChangeHandler)
end

M.RegisterPartProgressListener = function(self)
	if self.isListeningPartProgress then
		return
	end

	self.isListeningPartProgress = true
	self.cachedPartProgressList = nil

	gMessageManager:AddMessageListener(gEventConstants.WASH_PROGRESS_CHANGE, self.partProgressHandler)
end

M.UnregisterPartProgressListener = function(self)
	if not self.isListeningPartProgress then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.WASH_PROGRESS_CHANGE, self.partProgressHandler)

	self.isListeningPartProgress = false
end

M.GetWasherJobInfo = function(self)
	return self.washerJobInfo
end

M.GetCurrentRandomTaskDescription = function(self)
	local washerJobInfo = self:GetWasherJobInfo()
	local randomCfgId = washerJobInfo and washerJobInfo.CurRandomCfgId or 0
	local randomCfg = randomCfgId == 0 and LTConfig.WasherRandomTaskConfig.GetConfig(randomCfgId) or nil

	if randomCfg and not string.is_null_or_empty(randomCfg.WasherEventDescription) then
		return randomCfg.WasherEventDescription
	end

	return ""
end

M.SetWasherJobInfo = function(self, washerJobInfo)
	self.washerJobInfo = washerJobInfo

	print_debug("SetWasherJobInfo CurMissionEventId:", washerJobInfo and washerJobInfo.CurMissionEventId or "nil")

	if self.showWasherHud and not self.showWasherHudNoJob and washerJobInfo and washerJobInfo.CurMissionEventId and washerJobInfo.CurMissionEventId <= 0 and gTaskUtils:GetTaskGuideCurType() == gTaskUtils.TaskGuideSubPanel.Cleaner then
		gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Cleaner)
	end

	gMessageManager:SendMessage(gEventConstants.ON_WASHER_INFO_UPDATE)
end

M.ResetWasherJobInfo = function(self)
	self.washerJobInfo = nil

	gMessageManager:SendMessage(gEventConstants.ON_WASHER_INFO_UPDATE)
end

M.RefreshWasherJobInfo = function(self)
	if self.isRefreshingJobInfo then
		return
	end

	self.isRefreshingJobInfo = true

	gClientToGameDelegate:AskGetWasherMissionInfo(false).Callback = function (errorId, washerJobInfo)
		self.isRefreshingJobInfo = false

		if errorId == LTConfig.MessageConfig.Ok then
			print_error("[Washer]AskGetWasherMissionInfo failed:", errorId, gCS.Error.GetNameById(errorId))
		else
			gWasherManager:SetWasherJobInfo(washerJobInfo)
		end
	end
end

M.SetCurrentCleaningInfo = function(self, serverStart, info)
	self.serverStart = serverStart
	self.curCleaningInfo = info
end

M.SwitchAppTab = function(self, secondTab, needJobInfo)
	if not needJobInfo or self.washerJobInfo then
		local param = {
			secondShowType = secondTab,
			washerJobInfo = self.washerJobInfo
		}

		gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_SHOW, param)
	else
		gClientToGameDelegate:AskGetWasherMissionInfo(false).Callback = function (errorId, washerJobInfo)
			if errorId == LTConfig.MessageConfig.Ok then
				print_error("[Washer]AskGetWasherMissionInfo failed:", errorId, gCS.Error.GetNameById(errorId))

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

M.OnSyncWasherMissionResult = function(res)
	local partProgressList = gWasherManager.cachedPartProgressList

	if gWasherManager.appShown then
		gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_SHOW, {
			secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.COMPLETE_DETAIL,
			washerMissionResult = res,
			partProgressList = partProgressList
		})
	else
		gMainPhoneUtils.ShowPhoneAppContent({
			["*9\\xf6|\\x95\\xda5\\xa1!\\xd6\\xfa\\xe9z\\xfe"] = true,
			["fe\\x8aeC\\xbf\\xd4NdsmD"] = true,
			showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Washer,
			secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.COMPLETE_DETAIL,
			washerMissionResult = res,
			partProgressList = partProgressList
		})
	end
end

M.GetWasherMissionLevel = function(progress)
	local washerMissionCleanessConfig = LTConfig.WasherMissionCleanessConfig

	for i = 0, washerMissionCleanessConfig.count - 1 do
		local cfg = washerMissionCleanessConfig.LoadAt(i)

		if cfg and cfg.Rating < progress then
			return i
		end
	end

	return washerMissionCleanessConfig.count - 1
end

M.GetPlayerAvatarID = function()
	local jobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)
	local iconId = nil

	if jobId and jobId <= 0 then
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

M.GetMainContentSpiritName = function()
	return gClientUtils.GetCurrentSpiritDisplayName()
end

M.RefreshWasherAvatarView = function(avatarWidget, needClick)
	local avatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	avatarStore.headIcon = gWasherManager.GetPlayerAvatarID()

	if needClick then
		avatarStore.button.luaClick = function()
			gWasherManager:SwitchAppTab(gClientConst.WASHER_APP_SHOW_TYPE.ACCOUNT, true)
		end
	end
end

M.RefreshOrderDetailView = function(orderStore, logStore, washerMissionResult, partProgressList)
	local progress = math.max(0, math.min(100, math.floor(washerMissionResult.Progress * 10) * 0.1))
	orderStore.integrity = progress
	orderStore.progressBar.value = progress
	logStore.rankControl = gWasherManager.GetWasherMissionLevel(progress)
	logStore.money = washerMissionResult.AddMoney
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)
	local targetJobInfo = gSpiritJobManager.GetCurSpiritJob(targetJobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(targetJobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(urbanJobCfg)

	if urbanJobCfg and levelCfg then
		logStore.jobNameText = urbanJobCfg.Name
		logStore.jobLevelText = string.format("Lv.%d", targetJobInfo.Level)

		logStore.jobExpBar:ResetValue(targetJobInfo.Exp, levelCfg.Exp, 1, 0, 0, 0)
	end

	local missionCfg = LTConfig.WasherConfig.GetConfig(washerMissionResult.MissionId)
	local randomCfg = washerMissionResult.RandomCfgId == 0 and LTConfig.WasherRandomTaskConfig.GetConfig(washerMissionResult.RandomCfgId) or nil

	if missionCfg then
		orderStore.name = randomCfg and randomCfg.RandomQuestName or missionCfg.QuestName
		orderStore.startText = randomCfg and randomCfg.LocationName or missionCfg.LocationName
		local missionLevel = randomCfg and randomCfg.RandomMissionLevel or missionCfg.MissionLevel
		orderStore.qualityText = gWasherManager:GetDifficultyText(missionLevel)
		orderStore.qualityCtrl = gWasherManager:GetDifficultyColorCtrl(missionLevel)
		local location = randomCfg and randomCfg.QuestLocationId or missionCfg.QuestLocation
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
				if dropCfg.JobExp and #dropCfg.JobExp <= 0 then
					local jobExpInfo = dropCfg.JobExp[1]
					local proficiencyExp = jobExpInfo.count * washerMissionResult.ProficiencyRate
					logStore.jobExpText = math.ceil(proficiencyExp)
				else
					logStore.jobExpText = 0
				end
			end
		end
	end

	if partProgressList and #partProgressList <= 0 and missionCfg then
		local partNameList = {}
		local partValueList = {}
		local subPartNames = randomCfg and randomCfg.SubPartNamesRandom or missionCfg.SubPartNames

		if subPartNames and #subPartNames <= 0 then
			for i, textId in ipairs(subPartNames) do
				local v = partProgressList[i]

				if v and v > 0 then
					local textCfg = LTConfig.TextConfig.GetConfig(textId)

					table.insert(partNameList, textCfg and textCfg.Text or "")
					table.insert(partValueList, v)
				end
			end
		else
			for i, v in ipairs(partProgressList) do
				if v > 0 then
					local carTextCfg = LTConfig.WasherWashCarTextConfig.GetConfig(i)

					if carTextCfg then
						local textCfg = LTConfig.TextConfig.GetConfig(carTextCfg.TextId)

						table.insert(partNameList, textCfg and textCfg.Text or "")
						table.insert(partValueList, v)
					end
				end
			end
		end

		local partCount = #partValueList
		orderStore.havePartsCtrl = partCount <= 0 and 1 or 0

		if partCount <= 0 then
			orderStore.partProgressList.luaSimpleRenderItem = function(partBtn, partIndex)
				if not partBtn or gCS.LuaUtils.IsNull(partBtn) or gCS.LuaUtils.IsNull(partBtn.gameObject) then
					print_error("部位进度列表的Item预制体错误！", partBtn, partIndex)

					return
				end

				local group = gStoreManager:GetStoreGroup(partBtn.Store)

				if not group then
					print_error("未找到部位进度列表的StoreGroup！", partBtn.Store, partBtn.name, partIndex)

					return
				end

				local partStore = group:GetStoreByWidget(partBtn)

				if not partStore then
					print_error("未找到部位进度列表的Store！", partBtn.Store, partBtn.name, partIndex)

					return
				end

				local partProgress = partValueList[partIndex + 1] or 0
				partStore.progressNumText = tostring(math.floor(partProgress * 1000) * 0.1)
				partStore.progressBar.value = partProgress
				partStore.partNameText = partNameList[partIndex + 1] or ""
			end

			orderStore.partProgressList:SetSimpleList(partCount)
		else
			orderStore.partProgressList.luaSimpleRenderItem = nil

			orderStore.partProgressList:SetSimpleList(0)
		end

		return
	end

	orderStore.havePartsCtrl = 0
	orderStore.partProgressList.luaSimpleRenderItem = nil

	orderStore.partProgressList:SetSimpleList(0)
end

M.OpenTaskGuidePanel = function(self, isCar, noOrder)
	if self.showGlueHud then
		print_error("OpenTaskGuidePanel: HUD已被胶水玩法占用，无法打开")

		return
	end

	self.showWasherHud = true
	self.showWasherHudNoJob = noOrder

	if not noOrder then
		self:RegisterTaskChangeListener()
	end

	self:RegisterPartProgressListener()
	gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Cleaner, {
		isCar = isCar,
		isWithoutOrder = noOrder
	})
	print_debug("OpenTaskGuidePanel")
end

M.CloseTaskGuidePanel = function(self)
	self.showWasherHud = false
	self.showWasherHudNoJob = false

	self:UnregisterTaskChangeListenerIfIdle()
	self:UnregisterPartProgressListener()
	gTaskUtils:CloseTaskGuideCurTab()
	print_debug("CloseTaskGuidePanel")
end

M.OpenClueTaskGuidePanel = function(self)
	print_debug("OpenClueTaskGuidePanel")

	if self.showWasherHud then
		print_error("OpenClueTaskGuidePanel: HUD已被清洁工占用，无法打开")

		return
	end

	self.showGlueHud = true

	gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Cleaner, {
		["ZI鱑\r\\x95\\xcd\\xed"] = true
	})
end

M.CloseClueTaskGuidePanel = function(self)
	print_debug("CloseClueTaskGuidePanel")

	if not self.showGlueHud then
		return
	end

	self.showGlueHud = false

	gTaskUtils:CloseTaskGuideCurTab()
end

M.AskAcceptWasherMission = function(self, index, missionId, callback)
	if self.processDelayTimer then
		return
	end

	if Time.time >= (self.lastProcessTime or -1) + self.processDelayTime then
		return
	end

	self.lastProcessTime = Time.time
	local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()
	local isWasher = currentJobClassId ~= WasherJobClassId

	if not isWasher then
		gReliableRpcManager:RegisterRPC(gClientToGameDelegate.AskStartJob, WasherJobClassId, function (err)
			if err == LTConfig.MessageConfig.Ok then
				print_error("[Washer]AskStartJob failed:", err, gCS.Error.GetNameById(err))

				return
			end

			self:_AskAcceptWasher(index, missionId, callback)
		end)
	else
		self:_AskAcceptWasher(index, missionId, callback)
	end
end

M._AskAcceptWasher = function(self, index, missionId, callback)
	gClientToGameDelegate:AskAcceptWasherMission(index, missionId).Callback = function (errorId)
		if callback then
			callback()
		end

		if errorId == LTConfig.MessageConfig.Ok then
			print_error("[Washer]AskAcceptWasherMission failed:", errorId, gCS.Error.GetNameById(errorId), index, missionId)

			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_ACCEPT_WASHER_MISSION, index, missionId)
	end
end

M.AskFinishWasherMission = function(self, isNeedResult)
	if Time.time >= (self.lastProcessTime or -1) + self.processDelayTime then
		return
	end

	self.lastProcessTime = Time.time

	if not self.washerJobInfo or not self.washerJobInfo.CurMissionEventId or self.washerJobInfo.CurMissionEventId ~= 0 then
		print_error("#WasherManager AskFinishWasherMission failed: no current mission", self.washerJobInfo, self.washerJobInfo and self.washerJobInfo.CurMissionEventId)

		return
	end

	local currentJobClassId = gSpiritJobManager.GetCurSpiritJobClassId()
	local isWasher = currentJobClassId ~= WasherJobClassId

	self:SendProgress(true)

	if isNeedResult then
		gClientToGameDelegate:AskFinishWasherMission(self.washerJobInfo.CurMissionEventId).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				print_error("[Washer]AskFinishWasherMission failed:", err, gCS.Error.GetNameById(err), self.washerJobInfo.CurMissionEventId)

				return
			end

			if isWasher then
				gClientToGameDelegate:AskFinishJob(WasherJobClassId).Callback = function (err)
					if err == LTConfig.MessageConfig.Ok then
						print_error("[Washer]AskFinishJob failed:", err, gCS.Error.GetNameById(err), WasherJobClassId)

						return
					end
				end
			end
		end
	else
		local taskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

		if not taskId or taskId ~= 0 then
			return
		end

		gClientToGameDelegate:AskDeleteTask(taskId, true).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				print_error("[Washer]AskDeleteTask failed:", err, gCS.Error.GetNameById(err), taskId)

				return
			end

			if isWasher then
				gClientToGameDelegate:AskFinishJob(WasherJobClassId).Callback = function (err)
					if err == LTConfig.MessageConfig.Ok then
						print_error("[Washer]AskFinishJob failed:", err, gCS.Error.GetNameById(err), WasherJobClassId)

						return
					end
				end
			end
		end
	end
end

M.SendProgress = function(self, force)
	force = force or false

	L50.L50App.Scene.WashMgr:TrySendProgress(force)
end

M.GetCurrentHistoryInfo = function(self)
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

M.GetDifficultyText = function(self, missionLevel)
	local texts = LTConfig.WasherConfig.MissionLevelUIText

	if not texts or #texts ~= 0 then
		print_error("清洁工订单难度文本获取失败，配置不存在")

		return ""
	end

	if missionLevel <= 1 or missionLevel <= #texts then
		print_error("清洁工订单难度文本获取失败，等级超范围", missionLevel)

		return ""
	end

	local id = texts[missionLevel]
	local cfg = LTConfig.TextConfig.GetConfig(id)

	if not cfg then
		print_error("清洁工订单难度文本获取失败，配置不存在", id)

		return ""
	end

	return cfg.Text or ""
end

local QUALITY_COLOR_CTRL = {
	["x.h^"] = 3,
	["}-q_"] = 5,
	["]\\x83\\x9e\\x8fD"] = 4,
	["Z\\x90\\x80\\x84D"] = 6
}
local LEVEL_TO_QUALITY_COLOR_CTRL = {
	QUALITY_COLOR_CTRL.blue,
	QUALITY_COLOR_CTRL.purple,
	QUALITY_COLOR_CTRL.gold,
	QUALITY_COLOR_CTRL.orange
}

M.GetDifficultyColorCtrl = function(self, missionLevel)
	if not LEVEL_TO_QUALITY_COLOR_CTRL[missionLevel] then
		print_error("清洁工订单难度颜色获取失败，等级超范围，须限制为1~4", missionLevel)
	end

	return LEVEL_TO_QUALITY_COLOR_CTRL[missionLevel] or QUALITY_COLOR_CTRL.blue
end

gWasherManager = M
