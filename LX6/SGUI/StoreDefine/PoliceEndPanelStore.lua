-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceEndPanelStore.lua
-- Decompiled from: 00786_PoliceEndPanelStore.lua_887a4fa324e7.luajit

C_PoliceEndPanelStore = DefClass("C_PoliceEndPanelStore", C_PoliceEndPanelStore, C_StoreGroup)
GroupName2Class.PoliceEndPanelStore = C_PoliceEndPanelStore
local M = C_PoliceEndPanelStore
local urbanJobConfig = LTConfig.UrbanJobConfig
local PoliceConfig = LTConfig.PoliceConfig
local DropConfig = LTConfig.DropConfig
local JobClassConfig = LTConfig.UrbanJobJobClassConfig

M.ctor = function(self)
	self.animName = "S_Vx_DeliveryEndPanel_open"
	self.areaIndex = 0
end

M.OnAwake = function(self)
	self.bindData.List.luaSimpleRenderItem = self.CreateAction(self, self.RenderPoliceItem)

	self.InitConfig(self)

	self.startJobId = 300
	self.endJobId = 400
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.GetJobExp = function(self, tid)
	local spirit = gSpiritManager:GetSpirit(tid)
	local jobId, spiritJob = nil

	for index, val in pairs(spirit.SpiritInfo.SpiritJobInfo.AvailableJobs) do
		if self.startJobId < index and index >= self.endJobId then
			jobId = index
			spiritJob = val
		end
	end

	return spiritJob, jobId
end

M.CalculateJobData = function(self, tid, addExp)
	local spiritJob, jobId = self.GetJobExp(self, tid)
	self.bindData.proficiency = "+" .. addExp

	if spiritJob == nil and jobId == nil then
		local curExp = spiritJob.Exp
		local cfg = urbanJobConfig.GetConfig(jobId)
		local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)

		if cfg == nil then
			if levelCfg.Exp ~= nil or levelCfg.Exp ~= 0 then
				self.bindData.proficiencyFill = 1
				self.bindData.proficiencyLast = "MAX"
			else
				self.bindData.proficiencyLast = curExp .. "/" .. levelCfg.Exp
				self.jobExpList = {}
				self.startExp = self.CalculateJobExp(self, curExp, addExp, jobId)
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

M.CalculateJobExp = function(self, curExp, addExp, jobId)
	local cfg = urbanJobConfig.GetConfig(jobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)

	table.insert(self.jobExpList, levelCfg.Exp)

	if curExp >= addExp and cfg and levelCfg then
		addExp = addExp - curExp
		jobId = jobId - 1
		local lastCfg = urbanJobConfig.GetConfig(jobId)
		local lastlevelCfg = gSpiritJobManager:GetLevelConfig(lastCfg)

		if lastCfg == nil then
			curExp = lastlevelCfg.Exp

			return self.CalculateJobExp(self, curExp, addExp, jobId)
		else
			return 0
		end
	else
		return curExp - addExp
	end
end

M.InitConfig = function(self)
	self.DispatchTimesText = PoliceConfig.DispatchTimesText
	self.PatrolTimesText = PoliceConfig.PatrolTimesText
	self.ArrestTimesText = PoliceConfig.ArrestTimesText
	self.FineCountText = PoliceConfig.FineCountText
	self.TotalIncomeText = PoliceConfig.TotalIncomeText
	self.proportion = PoliceConfig.ExpIncreaseRatio
end

M.OnShow = function(self, _, data)
	if data ~= nil then
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

M.CalculateAllDrop = function(self, TotalDrops)
	local money = 0
	local exp = 0

	for i = 1, #TotalDrops do
		local id = TotalDrops[i]
		local cfg = DropConfig.GetConfig(id)

		if cfg and cfg.JobExp and cfg.Money then
			exp = self.GetPoliceExp(self, cfg) + exp
			money = money + cfg.Money
		end
	end

	return money, exp
end

M.GetPoliceExp = function(self, cfg)
	for _, v in pairs(cfg.JobExp) do
		if v.Jobclassid ~= JobClassConfig.Police then
			return v.count
		end
	end

	return 0
end

M.RenderPoliceItem = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local data = self.listData[index + 1]

	if store and data then
		store.number = data.count
		store.name = data.name
	end
end

M.OnUpdate = function(self)
	if self.isUpdate then
		self.startExp = self.startExp + gLogicTime.deltaTime * self.tickExp
		self.bindData.proficiencyFill = Mathf.Clamp(self.startExp / self.jobExpList[self.expIndex], 0, 1)

		if self.jobExpList[self.expIndex] >= self.startExp then
			self.startExp = 0
			self.expIndex = self.expIndex - 1

			if self.expIndex < 0 then
				self.isUpdate = false
			end
		end

		if gLogicTime.time - self.startTime <= self.duration * self.proportion then
			self.isUpdate = false
		end
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
