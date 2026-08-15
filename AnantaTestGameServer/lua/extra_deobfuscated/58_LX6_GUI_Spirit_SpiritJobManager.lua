local JobConfig = LTConfig.UrbanJobConfig
local M = {
	GetSpiritAllCost = function (self, tid)
		local data = gSpiritManager:GetSpirit(tid)

		if not data then
			return
		end

		local cost = 0
		local list = data.SpiritInfo.SpiritJobInfo.AvailableJobs

		for i, v in pairs(list) do
			local cfg = JobConfig.GetConfig(v.Job)

			if cfg then
				cost = cost + cfg.Cost
			end
		end

		return cost
	end,
	GetCurSpiritJobIdList = function (self)
		local tid = gSpiritManager:GetCurFirstSpiritTid()
		local data = gSpiritManager:GetSpirit(tid)

		if not data then
			return {}
		end

		return self:GetJobData(data.SpiritInfo.SpiritJobInfo.CurrentJob)
	end
}

function M.GetCurSpiritJobId()
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)

	if not spirit then
		return JobConfig.Jobless
	end

	local spiritJobInfo = spirit.SpiritInfo.SpiritJobInfo

	return spiritJobInfo.CurrentJob
end

function M.GetCurSpiritJobClassId()
	local currentJobId = M.GetCurSpiritJobId()
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(currentJobId)
	local jobClassId = urbanJobCfg and urbanJobCfg.JobClass or 0

	return jobClassId
end

function M.GetAvailableJobId(jobClassId)
	local jobClassInfo = gSpiritJobManager:GetAvailableJobByClass(jobClassId)

	return jobClassInfo and jobClassInfo.Job
end

function M.GetAvailableJobAvatarId(jobClassId)
	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()
	local count = LTConfig.UrbanJobAvatarConfig.count
	local targetAvatarCfg = nil

	for i = 0, count - 1 do
		local urbanJobAvatarCfg = LTConfig.UrbanJobAvatarConfig.LoadAt(i)

		if urbanJobAvatarCfg.SpiritId == currentSpiritId then
			targetAvatarCfg = urbanJobAvatarCfg

			break
		end
	end

	local jobId = M.GetAvailableJobId(jobClassId)
	local avatarKey = ("Avatar%d"):format(jobId)

	return targetAvatarCfg and targetAvatarCfg[avatarKey]
end

function M.GetCurSpiritAvailableJobIdList(containJobless)
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)
	local jobIdList = {}

	if spirit then
		local availableJobs = spirit.SpiritInfo.SpiritJobInfo.AvailableJobs

		for jobId in pairs(availableJobs) do
			if jobId ~= LTConfig.UrbanJobConfig.Jobless or containJobless then
				table.insert(jobIdList, jobId)
			end
		end
	end

	return jobIdList
end

function M:GetAvailableJobByClass(jobClassId)
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)

	if not spirit then
		return nil, nil
	end

	for i, v in pairs(spirit.SpiritInfo.SpiritJobInfo.AvailableJobs) do
		local cfg = LTConfig.UrbanJobConfig.GetConfig(v.Job)

		if cfg and cfg.JobClass == jobClassId then
			return v, cfg
		end
	end

	return nil, nil
end

function M:GetAvailableJobClass()
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)
	local jobClassList = {}

	if not spirit then
		return jobClassList
	end

	for i, v in pairs(spirit.SpiritInfo.SpiritJobInfo.AvailableJobs) do
		local cfg = LTConfig.UrbanJobConfig.GetConfig(v.Job)

		if cfg and cfg.JobClass ~= 0 then
			table.insert(jobClassList, cfg.JobClass)
		end
	end

	return jobClassList
end

function M.GetCurSpiritJob(jobId)
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)

	if spirit == nil then
		return nil
	end

	local availableJobs = spirit.SpiritInfo.SpiritJobInfo.AvailableJobs

	return availableJobs[jobId]
end

function M:GetJobData(jobId)
	self.jobConfigs = {}

	for i = 0, LTConfig.UrbanJobConfig.count - 1 do
		local cfg = LTConfig.UrbanJobConfig.LoadAt(i)
		local data = {
			id = cfg.Id,
			prejob = cfg.PreJob
		}

		if data.id ~= 100 then
			table.insert(self.jobConfigs, data)
		end
	end

	self.jobMapping = {}

	for _, job in ipairs(self.jobConfigs) do
		self.jobMapping[job.id] = job
	end

	return self:GetJobChain(jobId)
end

function M:findChainStartId(startId)
	local currentId = startId

	while self.jobMapping[currentId] and self.jobMapping[currentId].prejob ~= 0 do
		currentId = self.jobMapping[currentId].prejob
	end

	return currentId
end

function M:collectJobChain(startId)
	local result = {}
	local queue = {
		startId
	}

	while #queue > 0 do
		local currentId = table.remove(queue, 1)

		if not result[currentId] then
			result[currentId] = true

			for _, job in ipairs(self.jobConfigs) do
				if job.prejob == currentId then
					table.insert(queue, job.id)
				end
			end
		end
	end

	local resultList = {}

	for id, _ in pairs(result) do
		table.insert(resultList, id)
	end

	table.sort(resultList)

	return resultList
end

function M:GetJobChain(jobId)
	local chainStartId = self:findChainStartId(jobId)

	return self:collectJobChain(chainStartId)
end

function M:CheckContainJobId(JobId)
	local spirit = gSpiritManager:GetSpirit(gSpiritManager:GetCurFirstSpiritTid())

	if spirit.SpiritInfo.SpiritJobInfo.AvailableJobs[JobId] then
		return true
	end

	return false
end

function M:CheckContainJobClassId(JobClassId)
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)

	if not spirit then
		return false
	end

	for i, v in pairs(spirit.SpiritInfo.SpiritJobInfo.AvailableJobs) do
		local cfg = LTConfig.UrbanJobConfig.GetConfig(v.Job)

		if JobClassId == cfg.JobClass then
			return true
		end
	end

	return false
end

function M:CheckIsCurrentjob(JobClassId)
	local curId = self:GetCurJobId()
	local cfg = LTConfig.UrbanJobConfig.GetConfig(curId)

	if cfg and cfg.JobClass == tonumber(JobClassId) then
		return true
	end

	return false
end

function M:CheckJobPopUp(spiritId, availableJobs, currentJob)
	local spirit = gSpiritManager:GetSpirit(spiritId)
	local lastJobId = spirit.SpiritInfo.SpiritJobInfo.CurrentJob

	if currentJob ~= LTConfig.UrbanJobConfig.Jobless and lastJobId == currentJob then
		return false
	end

	local curCfg = LTConfig.UrbanJobConfig.GetConfig(currentJob)
	local lastCfg = LTConfig.UrbanJobConfig.GetConfig(lastJobId)

	if not curCfg or not lastCfg then
		return false
	end

	if currentJob ~= LTConfig.UrbanJobConfig.Jobless and curCfg.JobClass == lastCfg.JobClass then
		return true, currentJob, lastJobId
	end

	for i, v in pairs(availableJobs) do
		if not spirit.SpiritInfo.SpiritJobInfo.AvailableJobs[i] then
			local isHistoryJob = spirit.SpiritInfo.SpiritJobInfo.HistoryJobs[i]

			return true, i, 0, isHistoryJob
		end
	end

	return false
end

function M:CheckActivateJob(spiritId, currentJob)
	if currentJob == LTConfig.UrbanJobConfig.Jobless then
		return false
	end

	local spirit = gSpiritManager:GetSpirit(spiritId)

	if spirit.SpiritInfo.SpiritJobInfo.CurrentJob ~= currentJob then
		local lastJobId = spirit.SpiritInfo.SpiritJobInfo.CurrentJob
		local curCfg = LTConfig.UrbanJobConfig.GetConfig(currentJob)
		local lastCfg = LTConfig.UrbanJobConfig.GetConfig(lastJobId)

		if curCfg.JobClass ~= lastCfg.JobClass then
			return true
		end
	end

	return false
end

function M:GetCurJobId()
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)

	if not spirit then
		print_warn("GetCurJobId  not found spirit ")

		return
	end

	return spirit.SpiritInfo.SpiritJobInfo.CurrentJob
end

function M:GetCurJobData()
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)

	if not spirit then
		print_warn("GetCurJobData  not found spirit ")

		return
	end

	local curId = spirit.SpiritInfo.SpiritJobInfo.CurrentJob

	return spirit.SpiritInfo.SpiritJobInfo.AvailableJobs[curId]
end

function M:CheckJobIsPromote(jobClassId, exp)
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)

	if not spirit then
		return false
	end

	local jobInfo = self:GetAvailableJobByClass(jobClassId)
	local jobLevelCfg = self:GetLevelConfig(jobInfo)

	if not jobLevelCfg then
		return false
	end

	return jobInfo and jobLevelCfg.Exp < exp or false
end

function M:GetBadgeList(jobId, spiritInfo)
	local list = {}

	for i = 0, LTConfig.UrbanBadgeConfig.count - 1 do
		local cfg = LTConfig.UrbanBadgeConfig.LoadAt(i)

		if cfg and cfg.Type == 2 and cfg.JobId == jobId and not cfg.OnlyServer then
			table.insert(list, cfg)
		end
	end

	return list
end

function M:GetJobPathAllBadge(jobId)
	local list = {}
	local jobList = self:GetJobData(jobId)

	for i = 0, LTConfig.UrbanBadgeConfig.count - 1 do
		local cfg = LTConfig.UrbanBadgeConfig.LoadAt(i)

		if cfg and cfg.Type == 2 and not cfg.OnlyServer then
			local index = 0

			for k, v in pairs(jobList) do
				index = index + 1

				if cfg.JobId == v then
					local data = {
						level = index,
						cfg = cfg
					}

					table.insert(list, data)
				end
			end
		end
	end

	return list
end

function M:GetJobListByClassId(classId)
	local jobList = {}

	for i = 0, LTConfig.UrbanJobConfig.count - 1 do
		local cfg = LTConfig.UrbanJobConfig.LoadAt(i)

		if cfg.JobClass == classId then
			local ele = {
				id = cfg.Id
			}

			table.insert(jobList, ele)
		end
	end

	return jobList
end

function M:GetActivateBadgeListByJobPath(jobId, spiritInfo)
	local jobList = self:GetJobData(jobId)
	local list = {}

	for i, v in pairs(spiritInfo.InfoBadge.Badges) do
		local cfg = LTConfig.UrbanBadgeConfig.GetConfig(v.TemplateId)

		if not cfg then
			print_warn("缺失  UrbanBadgeConfig " .. v.TemplateId)
		end

		if v.Active and cfg and cfg.Type == 2 then
			for k, v in pairs(jobList) do
				if cfg.JobId == v then
					table.insert(list, cfg)
				end
			end
		end
	end

	return list
end

function M:CheckSpiritContainBadge(spiritTid, badgeId)
	if not spiritTid then
		return false
	end

	local spirit = gSpiritManager:GetSpirit(spiritTid)

	if not spirit then
		return false
	end

	for i, v in pairs(spirit.SpiritInfo.InfoBadge.Badges) do
		if i == badgeId then
			return v.Active
		end
	end

	return false
end

function M:CheckCurSpiritContainBadge(id)
	local tid = gSpiritManager:GetCurFirstSpiritTid()
	local spirit = gSpiritManager:GetSpirit(tid)

	if not spirit then
		print_error("CheckCurSpiritContainBadge  not  spirit")

		return false
	end

	for i, v in pairs(spirit.SpiritInfo.InfoBadge.Badges) do
		if i == id then
			return v.Active
		end
	end

	return false
end

function M:OnRenderJobPathItem(btn, csIndex, data)
	local store = gStoreManager:GetStoreGroup("CommonOccupationTemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.id)
	store.title = cfg.Name
	store.icon = cfg.Icon
	store.num = ("%02d"):format(csIndex + 1)
	store.isNow = data.isNow and 1 or 0
	store.lock = data.isNow and 0 or 1
	local lockText = cfg.PromoteDes

	function store.lockBtn.luaRenderTooltip(lockBtn, popIns, index)
		local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

		if not popStore then
			return
		end

		popStore.text = lockText
	end

	if not cfg.BriefDescription then
		return
	end

	local list = {}

	for i, v in ipairs(cfg.BriefDescription) do
		local info = {
			selected = false,
			id = i,
			cfg = v
		}

		table.insert(list, info)
	end

	function store.list.luaRenderItem(storeBtn, _, storeData)
		local btnStore = gStoreManager:GetStoreGroup("CommonOccupationTemplate2Store"):GetStoreByWidget(storeBtn)

		if not btnStore then
			return
		end

		btnStore.des = storeData.cfg.description
		btnStore.icon = storeData.cfg.imageId
	end

	store.list:SetList(list)
end

function M:TryBeginPromote(classId, callback)
	local currentJob, jobCfg = self:GetAvailableJobByClass(classId)
	local targetTaskId = jobCfg and jobCfg.PromoteTask or nil

	if targetTaskId then
		local taskState = gTaskManager:GetTaskState(targetTaskId)

		if taskState == UX.Game.TaskState.Accepted then
			gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
		else
			local rootGo = self.rootGo

			gClientToGameDelegate:AskAcceptTask(targetTaskId).Callback = function (errorId, data)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end

				if gClientUtils.IsNil(rootGo) then
					return
				end

				if callback then
					callback()
				end
			end
		end
	end
end

function M:GetLevelConfig(jobCfg)
	if not jobCfg then
		print_error("@zhouxiaoxuan01 gSpiritJobManager.GetLevelConfig jobCfg is nil")

		return
	end

	for i = 0, LTConfig.UrbanJobLevelConfig.count - 1 do
		local cfg = LTConfig.UrbanJobLevelConfig.LoadAt(i)

		if jobCfg.JobClass == cfg.JobClassId and jobCfg.Level == cfg.Level then
			return cfg
		end
	end
end

function M:GetLevelData(jobCfg, spiritTId)
	if not jobCfg then
		print_error("@zhouxiaoxuan01 gSpiritJobManager.GetLevelData jobCfg is nil")

		return
	end

	local spirit = gSpiritManager:GetSpirit(spiritTId)
	local jobData = spirit.SpiritInfo.SpiritJobInfo.AvailableJobs[jobCfg.Id]
	jobData = jobData or spirit.SpiritInfo.SpiritJobInfo.HistoryJobs[jobCfg.Id]

	if not jobData then
		return
	end

	return self:GetLevelCfg(jobCfg.JobClass, jobData.Level), jobData
end

function M:GetLevelCfg(jobClass, level)
	for i = 0, LTConfig.UrbanJobLevelConfig.count - 1 do
		local cfg = LTConfig.UrbanJobLevelConfig.LoadAt(i)

		if jobClass == cfg.JobClassId and level == cfg.Level then
			return cfg
		end
	end
end

gSpiritJobManager = M
