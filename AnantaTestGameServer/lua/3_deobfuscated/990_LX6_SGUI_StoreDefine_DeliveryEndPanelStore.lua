C_DeliveryEndPanelStore = DefClass("C_DeliveryEndPanelStore", C_DeliveryEndPanelStore, C_StoreGroup)
GroupName2Class.DeliveryEndPanelStore = C_DeliveryEndPanelStore
local M = C_DeliveryEndPanelStore
local UberSimConfig = LTConfig.UberSimConfig
local UrbanJobJobClassConfig = LTConfig.UrbanJobJobClassConfig
local urbanJobConfig = LTConfig.UrbanJobConfig

function M:ctor()
	self.areaIndex = 0
	self.finishAnimation = "S_Vx_DeliveryEndPanel_open"
end

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.ListRenderItem)
end

function M:ListRenderItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.listData[index + 1]

	if store and data then
		store.title = data.name
		store.score = data.score
	end
end

function M:OnShow(_, param)
	local data = param.data
	self.areaIndex = param.areaIndex

	gDeliveryTaskManager.RefreshOrderDetailView(self.bindData.detailItemWidget, data)

	self.duration = self.bindData.root.anim:GetClip(self.finishAnimation).length or LTConfig.DropConfig.SpecialDropShowTime

	self.bindData.root.anim:Play()
	self:SetPointReward(data)
	self:InitDeliveryExp(data)
	Timer.New(function ()
		gPanelManager:Close(gPanelId.S_DELIVERY_END_PANEL)

		if gDeliveryTaskManager.CheckTruckActivityHasOpen() and param.preRank ~= param.nowRank then
			-- Nothing
		end
	end, self.duration):Start()
end

function M:InitDeliveryExp(truckJobOrderWrap)
	local addExp = self:GetOrderExp(truckJobOrderWrap)
	local spiritJob, jobId, cfg = self:GetDeliveryExp()
	local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)

	if spiritJob ~= nil and jobId ~= nil and cfg ~= nil and levelCfg ~= nil then
		local curExp = spiritJob.Exp

		if levelCfg.Exp == nil or levelCfg.Exp == 0 then
			self.bindData.expFill = 1
			self.bindData.jobExp = "MAX"
		else
			self.bindData.jobExp = curExp .. "/" .. levelCfg.Exp
			local lastConfig = urbanJobConfig.GetConfig(jobId - 1)
			local lastlevelCfg = gSpiritJobManager:GetLevelConfig(lastConfig)

			if curExp - addExp < 1e-05 and lastConfig ~= nil and lastlevelCfg ~= nil then
				self.isNeedMid = true
				self.minProficiency = math.max(lastlevelCfg.Exp - addExp, 0) / lastlevelCfg.Exp
				self.maxProficiency = curExp / levelCfg.Exp + 1
			else
				self.minProficiency = math.max(curExp - addExp, 0) / levelCfg.Exp
				self.maxProficiency = curExp / levelCfg.Exp
			end

			self.startTime = gLogicTime.time
			self.isStartBar = true
		end

		self.bindData.jobName = cfg.Name
	end
end

function M:OnUpdate()
	if self.isStartBar then
		local nowTime = gLogicTime.time
		local fill = self.minProficiency + (nowTime - self.startTime) / self.duration * (self.maxProficiency - self.minProficiency)
		self.bindData.expFill = fill > 1 and fill - 1 or fill

		if self.duration < nowTime - self.startTime then
			self.isStartBar = false
		end
	end
end

function M:GetOrderExp(truckJobOrderWrap)
	local resultInfo = truckJobOrderWrap.ResultInfo
	local dropId = LTConfig.UberSimConfig.OrderRewardDropId
	local jobExpInfo = LTConfig.DropConfig.GetConfig(dropId).JobExp[1]
	local jobExp = jobExpInfo.count * resultInfo.DropCoefficient

	return math.ceil(jobExp)
end

function M:GetDeliveryExp()
	local spiritJob, cfg = gSpiritJobManager:GetAvailableJobByClass(UrbanJobJobClassConfig.Delivery)

	if spiritJob ~= nil then
		return spiritJob, spiritJob.Job, cfg
	end

	return nil, nil, nil
end

function M:StringSplit(inputStr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	local subStr = ""

	for i = 1, #inputStr do
		local char = string.sub(inputStr, i, i)

		if char == sep then
			table.insert(t, subStr)

			subStr = ""
		else
			subStr = subStr .. char
		end
	end

	table.insert(t, subStr)

	return t
end

function M:SetPointReward(data)
	local IntegralDescription = self:StringSplit(UberSimConfig.IntegralDescription, "|")

	if data.OrderInfo == nil or not gDeliveryTaskManager.CheckTruckActivityHasOpen() or data.ResultInfo == nil then
		self.bindData.PointsState = 0

		return
	end

	self.bindData.PointsState = 1
	local listData = {
		{
			score = data.OrderInfo.SpecialPointReward,
			name = IntegralDescription[1]
		},
		{
			score = data.ResultInfo.RewardPoint - data.OrderInfo.SpecialPointReward,
			name = IntegralDescription[2]
		},
		{
			score = data.ResultInfo.RewardPoint,
			name = IntegralDescription[3]
		}
	}
	self.listData = listData

	self.bindData.list:SetSimpleList(#listData)
end

function M:OnClose()
	return
end
