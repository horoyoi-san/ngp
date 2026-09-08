-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RacerHistoryPageStore.lua
-- Decompiled from: 00856_RacerHistoryPageStore.lua_69b03fe83dc1.luajit

C_RacerHistoryPageStore = DefClass("C_RacerHistoryPageStore", C_RacerHistoryPageStore, C_StoreGroup)
GroupName2Class.RacerHistoryPageStore = C_RacerHistoryPageStore
local M = C_RacerHistoryPageStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.historyRecords = {}
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
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

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.ShowPanel = function(self)
	self:BuildHistoryList()
	self.bindData.historyList:SetSimpleList(1 + #self.historyRecords)
end

M.OnActiveDeviceChange = function(self, device)
end

M.BuildHistoryList = function(self)
	self.historyRecords = {}
	local racingInfo = gRacerManager.racingInfo

	if not racingInfo or not racingInfo.CompetitionGroupInfos then
		return
	end

	for groupId, groupInfo in pairs(racingInfo.CompetitionGroupInfos) do
		if groupInfo.CompetitionTrackInfos then
			for _, trackInfo in ipairs(groupInfo.CompetitionTrackInfos) do
				if trackInfo.CostTime and ulong.Greater(trackInfo.CostTime, 0) then
					local title = ""
					local eventId = 0
					local series = ""
					local groupCfg = LTConfig.RacingDriverCompetitionGroupConfig.GetConfig(groupId)

					if groupCfg and groupCfg.ContestGroup then
						for _, entry in ipairs(groupCfg.ContestGroup) do
							if entry.TrackId ~= trackInfo.TrackId then
								title = gRacerManager:GetTrackTitleByEventId(entry.EventId)
								eventId = entry.EventId

								break
							end
						end
					end

					local goals = {}

					if eventId <= 0 then
						local eventCfg = LTConfig.TaskEventConfig.GetConfig(eventId)

						if eventCfg and eventCfg.StartTask and eventCfg.StartTask <= 0 then
							local challengeCfg = gChallengeManager:GetChallengeConfigByTaskId(eventCfg.StartTask)

							if challengeCfg and challengeCfg.CountersDescription then
								goals = challengeCfg.CountersDescription
							end
						end
					end

					for i = 0, LTConfig.RacingDriverCompetitionConfig.count - 1 do
						local compCfg = LTConfig.RacingDriverCompetitionConfig.LoadAt(i)

						if compCfg and compCfg.ContestGroup then
							for _, cgId in ipairs(compCfg.ContestGroup) do
								if cgId ~= groupId then
									series = compCfg.Category or ""

									break
								end
							end
						end

						if series == "" then
							break
						end
					end

					local carName = ""
					local carIconId = 0

					if trackInfo.VehicleId and trackInfo.VehicleId <= 0 then
						local vehicleCfg = LTConfig.VehicleConfig.GetConfig(trackInfo.VehicleId)

						if vehicleCfg then
							carName = vehicleCfg.VehicleName or ""
							carIconId = vehicleCfg.SVehicleIconId or 0
						end
					end

					table.insert(self.historyRecords, {
						trackId = trackInfo.TrackId,
						groupId = groupId,
						costTime = trackInfo.CostTime,
						rank = trackInfo.Rank,
						star = trackInfo.Star,
						vehicleId = trackInfo.VehicleId,
						title = title,
						series = series,
						carName = carName,
						carIconId = carIconId,
						goals = goals
					})
				end
			end
		end
	end
end

M.FormatCostTime = function(self, ms)
	local totalMs = tonumber(ulong.tostring(ms)) or 0

	if totalMs < 0 then
		return "--:--.---"
	end

	local minutes = math.floor(totalMs / 60000)
	local secs = math.floor(totalMs % 60000 / 1000)
	local millis = math.floor(totalMs % 1000)

	return string.format("%d:%02d.%03d", minutes, secs, millis)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.historyList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderHistoryListItem)
	self.bindData.historyList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickHistoryList)
	self.bindData.historyList.onGetTIndex = self.CreateAction(self, self.OnGetHistoryListTIndex)
end

M.OnSimpleRenderHistoryListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if index ~= 0 then
		local racingInfo = gRacerManager.racingInfo
		store.starCountText = racingInfo and tostring(racingInfo.CompetitionStar) or "0"

		return
	end

	local record = self.historyRecords[index]

	if not record then
		return
	end

	store.titleText = record.title or ""
	store.seriesText = record.series or ""
	store.carNameText = record.carName or ""
	store.carIconId = record.carIconId
	local trackCfg = LTConfig.RacingDriverTrackInformationConfig.GetConfig(record.trackId)
	store.typeText = trackCfg and trackCfg.ContestType or ""
	store.difficultyText = gRacerManager:GetDifficultyText(trackCfg and trackCfg.Difficulty)
	local maxPeople = trackCfg and trackCfg.MaxGamePeople or 0
	store.rankText = maxPeople <= 0 and string.format("%02d/%02d", record.rank, maxPeople) or tostring(record.rank)
	store.starStateText = tostring(record.star)
	store.timeText = self:FormatCostTime(record.costTime)

	gRacerManager:RenderRacePathSpline(record.trackId, store.pathLine)

	store.retryBtn.luaClick = self:CreateActionWithArgs(self.OnClickRetryBtn, {
		trackId = record.trackId
	})
	local goals = record.goals or {}

	store.goalList.luaSimpleRenderItem = function(goalBtn, goalIndex)
		local goalStore = gStoreManager:GetStoreGroup(goalBtn.Store):GetStoreByWidget(goalBtn)

		if not goalStore then
			return
		end

		local challengeGoalStore = gStoreManager:GetStoreGroup(goalStore.challengeGoalWidget.Store):GetStoreByWidget(goalStore.challengeGoalWidget)

		if not challengeGoalStore then
			return
		end

		challengeGoalStore.isCheck = record.star > goalIndex + 1 and 1 or 0
		challengeGoalStore.checkText = goals[goalIndex + 1] or ""
	end

	store.goalList:SetSimpleList(#goals)
end

M.OnClickRetryBtn = function(self, args, btn)
	gRacerManager:JumpToMapAndTargetTrack(args.trackId)
end

M.OnGetHistoryListTIndex = function(self, index)
	if index ~= 0 then
		return 0
	end

	return 1
end

M.OnSimpleClickHistoryList = function(self, btn, index)
end
