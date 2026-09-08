-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CleanerHomepagePanelStore.lua
-- Decompiled from: 02045_CleanerHomepagePanelStore.lua_dabee9aace8f.luajit

local WasherConfig = LTConfig.WasherConfig
local EOrderTemplateType = {
	["N#v^"] = 1,
	["\\xfd\\xd2(\\xf4"] = 2,
	["~\\xbe\\xae\\xa6\\xa2"] = 3,
	["2G\\x83\\x83\\x82M"] = 0
}
local EPopUpCtrl = {
	["=K\\x85\\x87\\x95D"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}
local EAreaLockCtrl = {
	["=K\\x85\\x87\\x95D"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}
C_CleanerHomepagePanelStore = DefClass("C_CleanerHomepagePanelStore", C_CleanerHomepagePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerHomepagePanelStore = C_CleanerHomepagePanelStore
local M = C_CleanerHomepagePanelStore
local TaskConfig = LTConfig.TaskConfig

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.orderButton.luaClick = self.CreateAction(self, self.OnOrderClick)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitButtonClick)
	self.bindData.takeOrderList.onGetTIndex = self.CreateAction(self, self.OnTakeOrderListGetTIndex)
	self.bindData.takeOrderList.luaLayoutSet = self.CreateAction(self, self.OnTakeOrderListLayoutSet)
	self.bindData.takeOrderList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTakeOrderListItem)
	self.bindData.takeOrderList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnRenderTakeOrderListItem)
	self.popUpTimer = nil
	self.washerJobInfo = nil
	self.curtAcceptOrderBtn = nil
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_WASHER_INFO_UPDATE] = self.CreateAction(self, self.RefreshAll),
		[gEventConstants.WASH_PROGRESS_CHANGE] = self.CreateAction(self, self.OnProgressChange)
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.Order_State_Control = {
		["N#v^"] = 0,
		["h\\xa3\\xb2\\xbb\\xaf"] = 2,
		["=K\\x92\\x8b\\x93U"] = 1
	}
	self.Take_State_Control = {
		[",A\\x92\\x85\\xb6Q"] = 1,
		["T-s^"] = 0
	}

	self.ApplyWasherJobInfo(self, args.washerJobInfo)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	gWasherManager.RefreshWasherAvatarView(self.bindData.avatar, true)
	self.RefreshTakeOrderListView(self)
	self.HidePopUp(self)
	self.SetAreaLockCtrl(self)
end

M.ClearData = function(self)
	M.base.ClearData()

	self.curtAcceptOrderBtn = nil
	self.cachedProgressList = nil
	self.cachedTextIdList = nil
end

M.ApplyWasherJobInfo = function(self, washerJobInfo)
	self.washerJobInfo = washerJobInfo

	if self.washerJobInfo then
		if self.washerJobInfo.MissionDic then
			self.takeOrderList = {}
			self.takeOrderRandomCfgIdList = {}

			for index, missionItem in pairs(self.washerJobInfo.MissionDic) do
				self.takeOrderList[index] = missionItem.Id
				self.takeOrderRandomCfgIdList[index] = missionItem.RandomCfgId or 0
			end
		else
			self.takeOrderList = {}
			self.takeOrderRandomCfgIdList = {}
		end

		local prevOrderId = self.currentOrderId or 0
		self.currentOrderId = self.washerJobInfo.CurMissionId or 0
		self.currentRandomCfgId = self.washerJobInfo.CurRandomCfgId or 0

		if prevOrderId == self.currentOrderId then
			self.cachedProgressList = nil
			self.cachedTextIdList = nil
		end

		if self.currentOrderId <= 0 then
			local curIndex = self.washerJobInfo.CurMissionIndex or 0
			local missionDic = self.washerJobInfo.MissionDic
			local missionItem = curIndex <= 0 and missionDic and missionDic[curIndex] or nil
			local itemId = missionItem and missionItem.Id or 0

			if not missionItem or itemId ~= 0 then
				print_error("#NoCreateIssue Washer 接单状态异常,MissionDic 中找不到 CurMissionIndex 对应项或 Id==0: CurMissionIndex=" .. tostring(curIndex) .. " CurMissionId=" .. tostring(self.currentOrderId) .. " itemId=" .. tostring(itemId))

				self.acceptOrderIndex = -1
			else
				if itemId == self.currentOrderId then
					print_error("#NoCreateIssue Washer MissionDic[CurMissionIndex].Id 与 CurMissionId 不一致: CurMissionIndex=" .. tostring(curIndex) .. " itemId=" .. tostring(itemId) .. " CurMissionId=" .. tostring(self.currentOrderId))
				end

				self.acceptOrderIndex = curIndex - 1
			end

			self.lastSeconds = (gLuaDataManager.serverTime - (self.washerJobInfo.CurMissionStartTime or 0)) % gClientConst.SECONDS_PER_MINUTE
		else
			self.acceptOrderIndex = nil
			self.lastSeconds = nil
		end

		self.refreshNav = true
	else
		self.takeOrderList = {}
		self.takeOrderRandomCfgIdList = {}
		self.currentOrderId = 0
		self.currentRandomCfgId = 0
		self.acceptOrderIndex = nil
		self.lastSeconds = nil
	end
end

M.CheckCanTakeOrder = function(self)
	return self.currentOrderId < 0, 1
end

M.SetAreaLockCtrl = function(self)
	if gSceneDataMgr.CurrentRaidId ~= LTConfig.RaidConfig.WorldMap then
		self.bindData.areaLockCtrl = EAreaLockCtrl.Normal
	else
		self.bindData.areaLockCtrl = EAreaLockCtrl.Active
	end
end

M.RefreshTakeOrderListView = function(self)
	self.curtAcceptOrderBtn = nil
	self.orderViewDataList = {}

	if self.acceptOrderIndex and self.acceptOrderIndex == -1 then
		table.insert(self.orderViewDataList, {
			type = EOrderTemplateType.Split,
			title = WasherConfig.WasherJiedan
		})
		table.insert(self.orderViewDataList, {
			type = EOrderTemplateType.Split,
			title = WasherConfig.WasherList
		})

		for index, missionId in pairs(self.takeOrderList) do
			if missionId <= 0 then
				local randomCfgId = self.takeOrderRandomCfgIdList and self.takeOrderRandomCfgIdList[index] or 0

				if index - 1 ~= self.acceptOrderIndex then
					table.insert(self.orderViewDataList, 2, {
						type = EOrderTemplateType.Take,
						missionId = missionId,
						randomCfgId = randomCfgId,
						index = index
					})
				else
					table.insert(self.orderViewDataList, {
						type = EOrderTemplateType.Disable,
						missionId = missionId,
						randomCfgId = randomCfgId,
						index = index
					})
				end
			end
		end
	else
		table.insert(self.orderViewDataList, {
			type = EOrderTemplateType.Split,
			title = WasherConfig.WasherList
		})

		for index, missionId in pairs(self.takeOrderList) do
			if missionId <= 0 then
				local randomCfgId = self.takeOrderRandomCfgIdList and self.takeOrderRandomCfgIdList[index] or 0

				table.insert(self.orderViewDataList, {
					type = EOrderTemplateType.Normal,
					missionId = missionId,
					randomCfgId = randomCfgId,
					index = index
				})
			end
		end
	end

	local viewCount = #self.orderViewDataList

	print_debug("TakeOrderList ViewCount:", viewCount)

	self.bindData.takeOrderListEmptyActive = viewCount > 1

	self.bindData.takeOrderList:SetSimpleList(viewCount)
end

M.OnTakeOrderListLayoutSet = function(self)
	if not self.refreshNav then
		return
	end

	self.refreshNav = false

	if self.acceptOrderIndex and self.acceptOrderIndex == -1 then
		self.curtAcceptOrderBtn:Navigate(self.curtAcceptOrderBtn)
		self.bindData.takeOrderList:GoToIndex(0, true)
	else
		self.bindData.takeOrderList:SetNavSelectToTop(false)
	end
end

M.OnOrderClick = function(self)
end

M.OnExitButtonClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end

M.OnTakeOrderListGetTIndex = function(self, index)
	local data = self.orderViewDataList[index + 1]

	return data.type
end

M.OnRenderTakeOrderListItem = function(self, btn, index)
	local data = self.orderViewDataList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.type ~= EOrderTemplateType.Split then
		local cfg = LTConfig.TextConfig.GetConfig(data.title)
		store.title = cfg and cfg.Text or ""

		return
	end

	local washerMissionCfg = WasherConfig.GetConfig(data.missionId)
	local randomCfg = data.randomCfgId and data.randomCfgId == 0 and LTConfig.WasherRandomTaskConfig.GetConfig(data.randomCfgId) or nil
	local targetPos = nil

	if not washerMissionCfg then
		print_error("获取订单配置失败，检查配置是否正确！id:" .. tostring(data.missionId))
	else
		store.name = randomCfg and randomCfg.RandomQuestName or washerMissionCfg.QuestName
		store.startText = randomCfg and randomCfg.LocationName or washerMissionCfg.LocationName

		if washerMissionCfg.RewardDropId and washerMissionCfg.RewardDropId == 0 then
			local dropCfg = LTConfig.DropConfig.GetConfig(washerMissionCfg.RewardDropId)

			if dropCfg then
				if randomCfg then
					store.money = Mathf.Floor(dropCfg.Money * randomCfg.RewardDropIdParam)
				else
					store.money = dropCfg.Money
				end
			end
		else
			store.money = 0
		end

		local location = randomCfg and randomCfg.QuestLocationId or washerMissionCfg.QuestLocation
		targetPos = gSpoonMgr:GetWayPointById(location)

		if targetPos then
			local playerPosition = gClientUtils.GetPlayerPosition()
			playerPosition = Vector3.New(playerPosition.X, playerPosition.Y, playerPosition.Z)
			local distance = Vector3.Distance(playerPosition, targetPos)
			store.startDistance = gClientUtils.FormatDistance(distance)
		else
			print_error("获取spoon位置失败，检查配置是否正确！id:" .. tostring(data.missionId))
		end

		local missionLevel = randomCfg and randomCfg.RandomMissionLevel or washerMissionCfg.MissionLevel
		store.qualityText = gWasherManager:GetDifficultyText(missionLevel)
		store.qualityCtrl = gWasherManager:GetDifficultyColorCtrl(missionLevel)
	end

	if data.type ~= EOrderTemplateType.Take then
		self.curtAcceptOrderBtn = btn
		store.takeButton.luaClick = self:CreateActionWithArgs(self.OnSetTargetClick, targetPos)
		store.cancelBtn.luaClick = self:CreateActionWithArgs(self.OnCancelBtnClick)
		store.cancelBtn.interactable = true
		local time = data.missionId ~= self.currentOrderId and gLuaDataManager.serverTime - self.washerJobInfo.CurMissionStartTime or 0
		self.lastSeconds = time % gClientConst.SECONDS_PER_MINUTE
		local progress = data.missionId ~= self.currentOrderId and gWasherManager.serverStart and L50.L50App.Scene.WashMgr.Progress or 0
		local nomralizedProgress = math.floor(progress * 1000) * 0.1
		store.integrity = nomralizedProgress
		store.progressBar.value = nomralizedProgress
		store.takeStateControl = 1
		local progressList = self.cachedProgressList
		local subPartNames = randomCfg and randomCfg.SubPartNamesRandom or washerMissionCfg and washerMissionCfg.SubPartNames
		local configPartCount = subPartNames and #subPartNames or 0
		local partCount = nil

		if configPartCount <= 0 then
			partCount = configPartCount
			local washMgrCount = progressList and #progressList or 0

			if washMgrCount <= 0 and washMgrCount == configPartCount then
				print_error("#NoCreateIssue 部位进度数量与配表不匹配 configCount:" .. configPartCount .. " washMgrCount:" .. washMgrCount .. " missionId:" .. tostring(data.missionId))
			end
		else
			partCount = 0
		end

		store.havePartsCtrl = partCount <= 0 and 1 or 0

		if partCount <= 0 then
			store.partProgressList.luaSimpleRenderItem = function(partBtn, partIndex)
				if not partBtn or gCS.LuaUtils.IsNull(partBtn) or gCS.LuaUtils.IsNull(partBtn.gameObject) then
					print_error("部位进度列表的Item预制体错误，检查配置是否正确！", partBtn, partIndex)

					return
				end

				local group = gStoreManager:GetStoreGroup(partBtn.Store)

				if not group then
					print_error("未找到部位进度列表的StoreGroup，检查配置是否正确！", partBtn.Store, partBtn.name, partIndex)

					return
				end

				local partStore = group:GetStoreByWidget(partBtn)

				if not partStore then
					print_error("未找到部位进度列表的Store，检查配置是否正确！", partBtn.Store, partBtn.name, partIndex)

					return
				end

				local partProgress = progressList and progressList[partIndex + 1] or 0
				partStore.progressNumText = tostring(math.floor(partProgress * 1000) * 0.1)
				partStore.progressBar.value = partProgress
				local textId = configPartCount <= 0 and subPartNames[partIndex + 1] or nil
				local textCfg = textId and LTConfig.TextConfig.GetConfig(textId)
				partStore.partNameText = textCfg and textCfg.Text or ""
			end

			store.partProgressList:SetSimpleList(partCount)
		else
			store.partProgressList.luaSimpleRenderItem = nil

			store.partProgressList:SetSimpleList(0)
		end

		return
	end

	if data.type ~= EOrderTemplateType.Disable then
		if store.partProgressList then
			store.partProgressList.luaSimpleRenderItem = nil

			store.partProgressList:SetSimpleList(0)
		end

		store.takeButton.luaClick = self.CreateAction(self, self.OnClickDisabledOrder)
		store.cancelBtn.interactable = true
	else
		if store.partProgressList then
			store.partProgressList.luaSimpleRenderItem = nil

			store.partProgressList:SetSimpleList(0)
		end

		store.takeButton.interactable = not self.acceptOrderIndex
		store.takeButton.luaClick = self.CreateActionWithArgs(self, self.OnTakeOrderClick, data)
	end
end

M.OnSetTargetClick = function(self, targetPos)
	self.refreshNav = true
	local taskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if not taskId or taskId ~= 0 then
		print_error("当前任务不存在，无法导航！")

		return
	end

	local cfg = TaskConfig.GetConfig(taskId)
	local gpsId = nil

	if cfg and array.contains(cfg.Tags, TaskConfig.TagsType.WasherTask) then
		local gpsInfoIds = L18.Spoon.Task.TaskManager.Instance:GetTaskGpsInfoIds(taskId):ToTable()
		gpsId = gpsInfoIds and "TaskGps_" .. gpsInfoIds[1]
	else
		gpsId = gMapSubSystem_Task:GetFirstGpsIdByTaskId(taskId)
	end

	if not gpsId then
		print_error("任务导航点不存在！")

		return
	end

	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = LTConfig.RaidConfig.WorldMap,
		autoSelectGpsId = gpsId
	})
end

M.OnCancelBtnClick = function(self)
	self.refreshNav = true

	gWasherManager:AskFinishWasherMission(false)
end

M.OnTakeOrderClick = function(self, data)
	slot2 = gWasherManager

	slot2:AskAcceptWasherMission(data.index, data.missionId, function ()
		print_debug("Take Order Rpc Callback", data)
	end)
end

M.OnClickDisabledOrder = function(self)
	self.ShowPopUp(self, 1.5)
end

M.RefreshAll = function(self)
	if gClientUtils.IsNil(self.rootGo) then
		return
	end

	local info = gWasherManager:GetWasherJobInfo()

	if not info then
		return
	end

	self.ApplyWasherJobInfo(self, info)
	self.RefreshTakeOrderListView(self)
	self.HidePopUp(self)
end

M.OnProgressChange = function(self, eventId, data)
	local rawProgressList = data[2]:ToTable()
	local rawTextIdList = data[3]:ToTable()
	self.cachedProgressList = {}
	self.cachedTextIdList = {}

	for i, v in ipairs(rawProgressList) do
		if v > 0 then
			self.cachedProgressList[#self.cachedProgressList + 1] = v
			self.cachedTextIdList[#self.cachedTextIdList + 1] = rawTextIdList[i]
		end
	end

	local washerMissionCfg = self.currentOrderId and WasherConfig.GetConfig(self.currentOrderId)
	local configPartCount = 0

	if self.currentRandomCfgId and self.currentRandomCfgId == 0 then
		local randomCfg = LTConfig.WasherRandomTaskConfig.GetConfig(self.currentRandomCfgId)
		local subPartNamesRandom = randomCfg and randomCfg.SubPartNamesRandom
		configPartCount = subPartNamesRandom and #subPartNamesRandom or 0
	else
		local subPartNames = washerMissionCfg and washerMissionCfg.SubPartNames
		configPartCount = subPartNames and #subPartNames or 0
	end

	if configPartCount <= 0 and #self.cachedProgressList <= 0 and #self.cachedProgressList == configPartCount then
		print_error("#NoCreateIssue OnProgressChange 部位进度数量与配表不匹配 configCount:" .. configPartCount .. " washMgrCount:" .. #self.cachedProgressList .. " missionId:" .. tostring(self.currentOrderId))
	end

	self.bindData.takeOrderList:SetSimpleList(#self.orderViewDataList)
end

M.OnUpdate = function(self)
end

M.ShowPopUp = function(self, time)
	if self.popUpTimer then
		self.popUpTimer:Stop()

		self.popUpTimer = nil
	else
		self.SetShowPopUp(self, true)
	end

	if time and time <= 0 then
		self.popUpTimer = Timer.New(function ()
			self.popUpTimer = nil

			self:SetShowPopUp(false)
		end, time)

		self.popUpTimer:Start()
	else
		self.SetShowPopUp(self, false)
	end
end

M.HidePopUp = function(self)
	if self.popUpTimer then
		self.popUpTimer:Stop()

		self.popUpTimer = nil
	end

	self.SetShowPopUp(self, false)
end

M.SetShowPopUp = function(self, isShow)
	self.bindData.popUpCtrl = isShow and EPopUpCtrl.Active or EPopUpCtrl.Normal
end
