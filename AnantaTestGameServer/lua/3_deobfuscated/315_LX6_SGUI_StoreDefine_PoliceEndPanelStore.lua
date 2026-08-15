C_PoliceEndPanelStore = DefClass("C_PoliceEndPanelStore", C_PoliceEndPanelStore, C_StoreGroup)
GroupName2Class.PoliceEndPanelStore = C_PoliceEndPanelStore
local M = C_PoliceEndPanelStore
local urbanJobConfig = LTConfig.UrbanJobConfig
local PoliceConfig = LTConfig.PoliceConfig
local DropConfig = LTConfig.DropConfig
local JobClassConfig = LTConfig.UrbanJobJobClassConfig

function M:ctor()
	self.animName = "S_Vx_DeliveryEndPanel_open"
	self.areaIndex = 0
end

function M:OnAwake()
	self.bindData.List.luaSimpleRenderItem = self:CreateAction(self.RenderPoliceItem)

	self:InitConfig()

	self.startJobId = 300
	self.endJobId = 400
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:GetJobExp(tid)
	local spirit = gSpiritManager:GetSpirit(tid)
	local jobId, spiritJob = nil

	for index, val in pairs(spirit.SpiritInfo.SpiritJobInfo.AvailableJobs) do
		if self.startJobId <= index and index < self.endJobId then
			jobId = index
			spiritJob = val
		end
	end

	return spiritJob, jobId
end

function M:CalculateJobData(tid, addExp)
	local spiritJob, jobId = self:GetJobExp(tid)
	self.bindData.proficiency = "+" .. addExp

	if spiritJob ~= nil and jobId ~= nil then
		local curExp = spiritJob.Exp
		local cfg = urbanJobConfig.GetConfig(jobId)
		local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)

		if cfg ~= nil then
			if levelCfg.Exp == nil or levelCfg.Exp == 0 then
				self.bindData.proficiencyFill = 1
				self.bindData.proficiencyLast = "MAX"
			else
				self.bindData.proficiencyLast = curExp .. "/" .. levelCfg.Exp
				self.jobExpList = {}
				self.startExp = self:CalculateJobExp(curExp, addExp, jobId)
				self.tickExp = addExp / (self.duration * self.proportion)
				self.expIndex = #self.jobExpList
				self.bindData.proficiencyFill = Mathf.Clamp(self.startExp / self.jobExpList[self.expIndex], 0, 1)
				self.isUpdate = true
				self.startTime = gLogicTime.time
			end

			self.bindData.jobName = cfg.Name
		end
	end
end

function M:CalculateJobExp(curExp, addExp, jobId)
	local cfg = urbanJobConfig.GetConfig(jobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)

	table.insert(self.jobExpList, levelCfg.Exp)

	if curExp < addExp and cfg and levelCfg then
		addExp = addExp - curExp
		jobId = jobId - 1
		local lastCfg = urbanJobConfig.GetConfig(jobId)
		local lastlevelCfg = gSpiritJobManager:GetLevelConfig(lastCfg)

		if lastCfg ~= nil then
			curExp = lastlevelCfg.Exp

			return self:CalculateJobExp(curExp, addExp, jobId)
		else
			return 0
		end
	else
		return curExp - addExp
	end
end

function M:InitConfig()
	self.DispatchTimesText = PoliceConfig.DispatchTimesText
	self.PatrolTimesText = PoliceConfig.PatrolTimesText
	self.ArrestTimesText = PoliceConfig.ArrestTimesText
	self.FineCountText = PoliceConfig.FineCountText
	self.TotalIncomeText = PoliceConfig.TotalIncomeText
	self.proportion = PoliceConfig.ExpIncreaseRatio
end

function M:OnShow(_, data)
	if data == nil then
		return
	end

	self.areaIndex = data.areaIndex
	local serviceData = data.serviceData
	local listData = {
		{
			name = self.DispatchTimesText,
			count = serviceData.DispatchTimes
		},
		{
			name = self.PatrolTimesText,
			count = serviceData.PatrolTimes
		},
		{
			name = self.ArrestTimesText,
			count = serviceData.ArrestTimes
		},
		{
			name = self.FineCountText,
			count = serviceData.FineCount
		}
	}
	local money, addExp = self:CalculateAllDrop(serviceData.TotalDrops)
	self.duration = self.bindData.root.anim:GetClip(self.animName).length
	self.bindData.moneyText = money
	self.listData = listData

	self.bindData.List:SetSimpleList(#self.listData)
	self:CalculateJobData(data.spiritId, addExp)
	self.bindData.root.anim:Stop()
	self.bindData.root.anim:Play()
	Timer.New(function ()
		gPanelManager:Close(gPanelId.POLICE_END_PANEL)
	end, self.duration):Start()
end

function M:CalculateAllDrop(TotalDrops)
	local money = 0
	local exp = 0

	for i = 1, #TotalDrops do
		local id = TotalDrops[i]
		local cfg = DropConfig.GetConfig(id)

		if cfg and cfg.JobExp and cfg.Money then
			exp = self:GetPoliceExp(cfg) + exp
			money = money + cfg.Money
		end
	end

	return money, exp
end

function M:GetPoliceExp(cfg)
	for _, v in pairs(cfg.JobExp) do
		if v.Jobclassid == JobClassConfig.Police then
			return v.count
		end
	end

	return 0
end

function M:RenderPoliceItem(btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local data = self.listData[index + 1]

	if store and data then
		store.number = data.count
		store.name = data.name
	end
end

function M:OnUpdate()
	if self.isUpdate then
		self.startExp = self.startExp + gLogicTime.deltaTime * self.tickExp
		self.bindData.proficiencyFill = Mathf.Clamp(self.startExp / self.jobExpList[self.expIndex], 0, 1)

		if self.jobExpList[self.expIndex] < self.startExp then
			self.startExp = 0
			self.expIndex = self.expIndex - 1

			if self.expIndex <= 0 then
				self.isUpdate = false
			end
		end

		if gLogicTime.time - self.startTime > self.duration * self.proportion then
			self.isUpdate = false
		end
	end
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
