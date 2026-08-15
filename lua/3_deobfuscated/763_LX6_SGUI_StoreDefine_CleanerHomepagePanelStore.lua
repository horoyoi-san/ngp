local EOrderTemplateType = {
	Take = 1,
	Disable = 2,
	Split = 3,
	Normal = 0
}
local ESplitType = {
	OrderList = "接单列表",
	OrderTop = "已接单"
}
local EPopUpCtrl = {
	Active = 1,
	Normal = 0
}
C_CleanerHomepagePanelStore = DefClass("C_CleanerHomepagePanelStore", C_CleanerHomepagePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerHomepagePanelStore = C_CleanerHomepagePanelStore
local M = C_CleanerHomepagePanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.takeOrderTabButton.luaClick = self:CreateAction(self.OnTakeOrderTabClick)
	self.bindData.acceptOrderTabButton.luaClick = self:CreateAction(self.OnAcceptOrderTabClick)
	self.bindData.orderButton.luaClick = self:CreateAction(self.OnOrderClick)
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitButtonClick)
	self.bindData.takeOrderList.onGetTIndex = self:CreateAction(self.OnTakeOrderListGetTIndex)
	self.bindData.takeOrderList.luaSimpleRenderItem = self:CreateAction(self.OnTakeOrderRendererItem)
	self.bindData.takeOrderList.luaLayoutSet = self:CreateAction(self.OnTakeOrderListLayoutSet)
	self.popUpTimer = nil
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_WASHER_INFO_UPDATE] = self:CreateAction(self.RefreshAll),
		[gEventConstants.WASH_PROGRESS_CHANGE] = self:CreateAction(self.OnProgressChange),
		[gEventConstants.TASK_EVENT_CHANGE] = function ()
			gWasherManager:RefreshWasherJobInfo()
		end
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.Order_Show_Type_Control = {
		TakeOrderList = 0,
		AcceptOrderList = 1
	}
	self.Order_State_Control = {
		Take = 0,
		Empty = 2,
		Accept = 1
	}
	self.Take_State_Control = {
		PickUp = 1,
		None = 0
	}
	self.washerJobInfo = args.washerJobInfo

	if self.washerJobInfo then
		self.takeOrderList = self.washerJobInfo.MissionDic
		self.currentOrderId = self.washerJobInfo.CurMissionId

		if self.currentOrderId > 0 then
			self.acceptOrderIndex = -1

			for index, missionId in pairs(self.takeOrderList) do
				if missionId == self.currentOrderId then
					self.acceptOrderIndex = index - 1

					break
				end
			end

			self.lastSeconds = (gLuaDataManager.serverTime - self.washerJobInfo.CurMissionStartTime) % gClientConst.SECONDS_PER_MINUTE
		else
			self.acceptOrderIndex = nil
			self.lastSeconds = nil
		end

		self.refreshNav = true
	else
		self.takeOrderList = {}
		self.currentOrderId = {}
	end
end

function M:InitView(args)
	M.base.InitView(self, args)

	self.bindData.showTypeControl = self.Order_Show_Type_Control.TakeOrderList

	gWasherManager.RefreshWasherAvatarView(self.bindData.avatar, true)
	self:RefreshTakeOrderListView()
	self:HidePopUp()
end

function M:CheckCanTakeOrder()
	return self.currentOrderId >= 0, 1
end

function M:RefreshTakeOrderListView()
	if self.bindData.showTypeControl == self.Order_Show_Type_Control.TakeOrderList then
		self.orderViewDataList = {}

		if self.acceptOrderIndex then
			table.insert(self.orderViewDataList, {
				type = EOrderTemplateType.Split,
				title = ESplitType.OrderTop
			})
			table.insert(self.orderViewDataList, {
				type = EOrderTemplateType.Split,
				title = ESplitType.OrderList
			})

			for index, missionId in pairs(self.takeOrderList) do
				if missionId > 0 then
					if index - 1 == self.acceptOrderIndex then
						table.insert(self.orderViewDataList, 2, {
							type = EOrderTemplateType.Take,
							missionId = missionId,
							index = index
						})
					else
						table.insert(self.orderViewDataList, {
							type = EOrderTemplateType.Disable,
							missionId = missionId,
							index = index
						})
					end
				end
			end
		else
			table.insert(self.orderViewDataList, {
				type = EOrderTemplateType.Split,
				title = ESplitType.OrderList
			})

			for index, missionId in pairs(self.takeOrderList) do
				if missionId > 0 then
					table.insert(self.orderViewDataList, {
						type = EOrderTemplateType.Normal,
						missionId = missionId,
						index = index
					})
				end
			end
		end

		local viewCount = #self.orderViewDataList

		print_debug("TakeOrderList ViewCount:", viewCount)

		self.bindData.takeOrderListEmptyActive = viewCount <= 1

		self.bindData.takeOrderList:SetSimpleList(viewCount)
	end
end

function M:OnTakeOrderListLayoutSet()
	if not self.refreshNav then
		return
	end

	self.refreshNav = not self.bindData.takeOrderList:SetNavSelectToTop(false)
end

function M:OnOrderClick()
	return
end

function M:OnExitButtonClick()
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end

function M:OnTakeOrderListGetTIndex(index)
	local data = self.orderViewDataList[index + 1]

	return data.type
end

function M:OnTakeOrderRendererItem(btn, index)
	local data = self.orderViewDataList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.type == EOrderTemplateType.Split then
		store.title = data.title

		return
	end

	local washerMissionCfg = LTConfig.WasherConfig.GetConfig(data.missionId)
	local targetPos = nil

	if washerMissionCfg then
		store.name = washerMissionCfg.QuestName
		store.startText = washerMissionCfg.LocationName

		if washerMissionCfg.RewardDropId then
			local dropCfg = LTConfig.DropConfig.GetConfig(washerMissionCfg.RewardDropId)

			if dropCfg then
				store.money = dropCfg.Money
			end
		end

		local location = washerMissionCfg.QuestLocation
		targetPos = gSpoonMgr:GetWayPointById(location)

		if targetPos then
			local playerPosition = gClientUtils.GetPlayerPosition()
			playerPosition = Vector3.New(playerPosition.X, playerPosition.Y, playerPosition.Z)
			local distance = Vector3.Distance(playerPosition, targetPos)
			store.startDistance = gClientUtils.FormatDistance(distance)
		else
			print_error("获取spoon位置失败，检查配置是否正确！id:" .. tostring(data.missionId))
		end
	end

	if data.type == EOrderTemplateType.Take then
		store.takeButton.luaClick = self:CreateActionWithArgs(self.OnSetTargetClick, targetPos)
		store.cancelBtn.luaClick = self:CreateActionWithArgs(self.OnCancelBtnClick)
		store.cancelBtn.interactable = true
		local time = data.missionId == self.currentOrderId and gLuaDataManager.serverTime - self.washerJobInfo.CurMissionStartTime or 0
		local minutes = math.floor(time / gClientConst.SECONDS_PER_MINUTE)
		self.lastSeconds = time % gClientConst.SECONDS_PER_MINUTE
		local progress = data.missionId == self.currentOrderId and gWasherManager.serverStart and L50.L50App.Scene.WashMgr.Progress or 0
		local nomralizedProgress = math.floor(progress * 1000) * 0.1
		store.integrity = nomralizedProgress
		store.progressBar.value = nomralizedProgress
		store.takeStateControl = 1
	elseif data.type == EOrderTemplateType.Disable then
		store.takeButton.luaClick = self:CreateAction(self.OnClickDisabledOrder)
		store.cancelBtn.interactable = true
	else
		store.takeButton.interactable = not self.acceptOrderIndex
		store.takeButton.luaClick = self:CreateActionWithArgs(self.OnTakeOrderClick, data)
	end
end

function M:OnSetTargetClick(targetPos)
	self.refreshNav = true
	local taskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if not taskId or taskId == 0 then
		print_error("当前任务不存在，无法导航！")

		return
	end

	local gpsId = gMapSubSystem_Task:GetFirstGpsIdByTaskId(taskId)

	if not gpsId then
		print_error("任务导航点不存在！")

		return
	end

	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = LTConfig.RaidConfig.WorldMap,
		autoSelectGpsId = gpsId
	})
end

function M:OnCancelBtnClick()
	self.refreshNav = true

	gWasherManager:AskFinishWasherMission(false)
end

function M:OnTakeOrderClick(data)
	gWasherManager:AskAcceptWasherMission(data.index, data.missionId, function ()
		print_debug("Take Order Rpc Callback", data)
	end)
end

function M:OnClickDisabledOrder()
	self:ShowPopUp(1.5)
end

function M:RefreshAll()
	if gClientUtils.IsNil(self.rootGo) then
		return
	end

	self.washerJobInfo = gWasherManager:GetWasherJobInfo()

	if not self.washerJobInfo then
		return
	end

	self.takeOrderList = self.washerJobInfo.MissionDic
	self.currentOrderId = self.washerJobInfo.CurMissionId

	if self.currentOrderId > 0 then
		self.acceptOrderIndex = -1

		for index, missionId in pairs(self.takeOrderList) do
			if missionId == self.currentOrderId then
				self.acceptOrderIndex = index - 1

				break
			end
		end

		self.lastSeconds = (gLuaDataManager.serverTime - self.washerJobInfo.CurMissionStartTime) % gClientConst.SECONDS_PER_MINUTE
	else
		self.acceptOrderIndex = nil
		self.lastSeconds = nil
	end

	self.refreshNav = true

	self:RefreshTakeOrderListView()
	self:HidePopUp()
end

function M:OnProgressChange(eventId, data)
	self.bindData.takeOrderList:RefreshList()
end

function M:OnUpdate()
	return
end

function M:ShowPopUp(time)
	if self.popUpTimer then
		self.popUpTimer:Stop()

		self.popUpTimer = nil
	else
		self:SetShowPopUp(true)
	end

	if time and time > 0 then
		self.popUpTimer = Timer.New(function ()
			self.popUpTimer = nil

			self:SetShowPopUp(false)
		end, time)

		self.popUpTimer:Start()
	else
		self:SetShowPopUp(false)
	end
end

function M:HidePopUp()
	if self.popUpTimer then
		self.popUpTimer:Stop()

		self.popUpTimer = nil
	end

	self:SetShowPopUp(false)
end

function M:SetShowPopUp(isShow)
	self.bindData.popUpCtrl = isShow and EPopUpCtrl.Active or EPopUpCtrl.Normal
end
