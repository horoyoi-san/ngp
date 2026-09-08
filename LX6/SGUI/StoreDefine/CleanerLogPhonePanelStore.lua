-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CleanerLogPhonePanelStore.lua
-- Decompiled from: 02024_CleanerLogPhonePanelStore.lua_7d39d711d1a2.luajit

C_CleanerLogPhonePanelStore = DefClass("C_CleanerLogPhonePanelStore", C_CleanerLogPhonePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerLogPhonePanelStore = C_CleanerLogPhonePanelStore
local M = C_CleanerLogPhonePanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.bindData.list.onGetTIndex = self.CreateAction(self, self.OnItemGetTIndex)
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.TimeOut_Control = {
		["\\xed\\xd211\\xe5"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
end

M.InitView = function(self, args)
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

M.RefreshOrderListView = function(self, washerJobInfo)
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
		if count > 30 then
			table.insert(viewDataList, {
				["NNzG;<"] = 0
			})

			break
		end

		table.insert(viewDataList, result)

		count = count + 1
	end

	array.reverse(viewDataList)

	self.viewDataList = viewDataList

	self.bindData.list:SetSimpleList(#viewDataList)

	self.bindData.emptyControl = #viewDataList < 0 and 1 or 0
end

M.OnItemGetTIndex = function(self, index)
	if index > 30 then
		return 1
	end

	return 0
end

M.OnRenderItem = function(self, btn, index)
	local data = self.viewDataList[index + 1]

	if not data then
		return
	end

	btn.luaClick = self:CreateActionWithArgs(self.OnItemClick, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local progressValue = math.max(0, math.min(100, math.floor(data.Progress * 10) * 0.1))
	store.integrity = progressValue
	store.progressBar.value = progressValue
	local minutes = math.floor(data.UsingTime / gClientConst.SECONDS_PER_MINUTE)
	local seconds = data.UsingTime % gClientConst.SECONDS_PER_MINUTE
	store.useTime = ("%02d:%02d"):format(minutes, seconds)
	store.rankControl = gWasherManager.GetWasherMissionLevel(progressValue)
	store.money = math.floor(data.AddMoney)
	local missionCfg = LTConfig.WasherConfig.GetConfig(data.MissionId)

	if missionCfg then
		local questName = missionCfg.QuestName
		local missionLevel = missionCfg.MissionLevel

		if data.RandomCfgId and data.RandomCfgId == 0 then
			local randomCfg = LTConfig.WasherRandomTaskConfig.GetConfig(data.RandomCfgId)

			if randomCfg then
				questName = randomCfg.RandomQuestName
				missionLevel = randomCfg.RandomMissionLevel
			end
		end

		store.name = questName
		store.qualityText = gWasherManager:GetDifficultyText(missionLevel)
		store.qualityCtrl = gWasherManager:GetDifficultyColorCtrl(missionLevel)
	end
end

M.OnItemClick = function(self, data)
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_SHOW, {
		secondShowType = gClientConst.WASHER_APP_SHOW_TYPE.COMPLETE_DETAIL,
		washerMissionResult = data
	})
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end
