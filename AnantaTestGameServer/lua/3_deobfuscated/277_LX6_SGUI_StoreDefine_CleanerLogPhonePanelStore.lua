C_CleanerLogPhonePanelStore = DefClass("C_CleanerLogPhonePanelStore", C_CleanerLogPhonePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerLogPhonePanelStore = C_CleanerLogPhonePanelStore
local M = C_CleanerLogPhonePanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
	self.bindData.list.onGetTIndex = self:CreateAction(self.OnItemGetTIndex)
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.TimeOut_Control = {
		TimeOut = 1,
		Normal = 0
	}
end

function M:InitView(args)
	M.base.InitView(self, args)

	local washerJobInfo = gWasherManager:GetWasherJobInfo()

	if not washerJobInfo then
		return
	end

	gWasherManager.RefreshWasherAvatarView(self.bindData.avatar, true)

	local historyInfo = gWasherManager:GetCurrentHistoryInfo()
	self.bindData.money = historyInfo and historyInfo.TodayMissionMoney or 0

	self:RefreshOrderListView(washerJobInfo)
end

function M:RefreshOrderListView(washerJobInfo)
	local viewDataList = {}
	local count = 0
	local currentSpiritId = gSpiritManager:GetCurFirstSpiritTid()

	if not currentSpiritId then
		print_error("C_CleanerLogPhonePanelStore:RefreshOrderListView currentSpiritId is nil")

		return
	end

	local info = washerJobInfo.Spirit2HistoryMissionInfo[currentSpiritId]

	if not info then
		return
	end

	for _, result in ipairs(info.HistoryMissionResults) do
		if count >= 30 then
			table.insert(viewDataList, {
				missionId = 0
			})

			break
		end

		table.insert(viewDataList, {
			missionId = result.MissionId,
			eventId = result.EventId,
			progress = result.Progress,
			rewardRate = result.RewardRate,
			proficiencyRate = result.ProficiencyRate,
			usingTime = result.UsingTime,
			money = result.AddMoney
		})

		count = count + 1
	end

	array.reverse(viewDataList)

	self.viewDataList = viewDataList

	self.bindData.list:SetSimpleList(#viewDataList)

	self.bindData.emptyControl = #viewDataList <= 0 and 1 or 0
end

function M:OnItemGetTIndex(index)
	if index >= 30 then
		return 1
	end

	return 0
end

function M:OnRenderItem(btn, index)
	local data = self.viewDataList[index + 1]

	if not data then
		return
	end

	btn.luaClick = self:CreateActionWithArgs(self.OnItemClick, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local progressValue = math.max(0, math.min(100, math.floor(data.progress * 10) * 0.1))
	store.integrity = progressValue
	store.progressBar.value = progressValue
	local minutes = math.floor(data.usingTime / gClientConst.SECONDS_PER_MINUTE)
	local seconds = data.usingTime % gClientConst.SECONDS_PER_MINUTE
	store.useTime = ("%02d:%02d"):format(minutes, seconds)
	store.rankControl = gWasherManager.GetWasherMissionLevel(progressValue)
	store.money = math.floor(data.money)
	local missionCfg = LTConfig.WasherConfig.GetConfig(data.missionId)

	if missionCfg then
		store.name = missionCfg.QuestName
	end
end

function M:OnItemClick(data)
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_SHOW, {
		secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.COMPLETE_DETAIL,
		washerMissionResult = data
	})
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end
