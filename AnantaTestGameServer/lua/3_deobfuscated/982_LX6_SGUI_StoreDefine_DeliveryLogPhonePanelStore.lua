C_DeliveryLogPhonePanelStore = DefClass("C_DeliveryLogPhonePanelStore", C_DeliveryLogPhonePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryLogPhonePanelStore = C_DeliveryLogPhonePanelStore
local M = C_DeliveryLogPhonePanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.TimeOut_Control = {
		TimeOut = 1,
		Normal = 0
	}
	self.clientFinishedTruckOrderView = args.clientFinishedTruckOrderView
end

function M:InitView(args)
	M.base.InitView(self, args)
	gDeliveryTaskManager.RefreshDeliveryAvatarView(self.bindData.avatar, self.rootGo)

	self.bindData.money = self:GetTotalMoney()
	local todayRewardPoint = self.clientFinishedTruckOrderView.TodayRewardPoint or 0
	todayRewardPoint = math.max(0, todayRewardPoint)

	if gDeliveryTaskManager.CheckTruckActivityHasOpen() then
		self.bindData.activityScoreControl = todayRewardPoint >= 0 and 1 or 0
	else
		self.bindData.activityScoreControl = 0
	end

	self.bindData.activityScore = todayRewardPoint

	self:RefreshOrderListView()
end

function M:GetTotalMoney()
	local totalMoney = 0

	for _, truckJobOrderWrap in ipairs(self.clientFinishedTruckOrderView.FinishedOrders) do
		totalMoney = totalMoney + (truckJobOrderWrap.ResultInfo.DropMoney or 0)
	end

	return totalMoney
end

function M:RefreshOrderListView()
	self.viewDataList = {}

	for _, truckJobOrderWrap in ipairs(self.clientFinishedTruckOrderView.FinishedOrders) do
		table.insert(self.viewDataList, {
			truckJobOrderWrap = truckJobOrderWrap
		})
	end

	table.sort(self.viewDataList, function (data1, data2)
		if data1.truckJobOrderWrap.ResultInfo.FinishTime ~= data2.truckJobOrderWrap.ResultInfo.FinishTime then
			return data2.truckJobOrderWrap.ResultInfo.FinishTime < data1.truckJobOrderWrap.ResultInfo.FinishTime
		end

		return data1.truckJobOrderWrap.UniqueId < data2.truckJobOrderWrap.UniqueId
	end)
	self.bindData.list:SetSimpleList(#self.viewDataList)

	self.bindData.emptyControl = #self.viewDataList <= 0 and 1 or 0
end

function M:OnRenderItem(btn, index)
	local data = self.viewDataList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local truckJobOrderWrap = data.truckJobOrderWrap
	local orderInfo = truckJobOrderWrap.OrderInfo
	local randomGoodsCfg = LTConfig.UberSimRandomGoodsConfig.GetConfig(orderInfo.CargoId)
	store.name = randomGoodsCfg.information
	local resultInfo = truckJobOrderWrap.ResultInfo
	store.integrity = resultInfo.CargoIntegrity
	store.progressBar.value = resultInfo.CargoIntegrity
	local finishTime = resultInfo.FinishTime - truckJobOrderWrap.AcceptInfo.AcceptTime
	local minutes = math.floor(finishTime / gClientConst.SECONDS_PER_MINUTE)
	local seconds = finishTime % gClientConst.SECONDS_PER_MINUTE
	store.useTime = ("%02d:%02d"):format(minutes, seconds)
	local isLimitedOrder = not gDeliveryTaskManager.CheckIsUnlimitedTimeOrder(randomGoodsCfg.Id)
	local isTimeOut = isLimitedOrder and orderInfo.EstimatedFinishSeconds < finishTime
	store.overTimeControl = isTimeOut and self.TimeOut_Control.TimeOut or self.TimeOut_Control.Normal
	store.money = resultInfo.DropMoney or 0
	local jobExp = gDeliveryTaskManager.GetJobExp(resultInfo)
	store.score = ("+%d"):format(jobExp)
	store.iconId = randomGoodsCfg.image
	store.button.luaClick = self:CreateActionWithArgs(self.OnItemClick, truckJobOrderWrap)
	store.rankControl = resultInfo.Evaluation
end

function M:OnItemClick(truckJobOrderWrap)
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_SHOW, {
		secondShowType = gClientConst.DELIVERY_APP_SHOW_TYPE.COMPLETE_DETAIL,
		truckJobOrderWrap = truckJobOrderWrap
	})
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

function M:ClearData()
	self.viewDataList = nil
end
