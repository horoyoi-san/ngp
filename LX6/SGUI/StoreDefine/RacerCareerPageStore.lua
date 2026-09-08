-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RacerCareerPageStore.lua
-- Decompiled from: 00916_RacerCareerPageStore.lua_5efc283c8bac.luajit

C_RacerCareerPageStore = DefClass("C_RacerCareerPageStore", C_RacerCareerPageStore, C_StoreGroup)
GroupName2Class.RacerCareerPageStore = C_RacerCareerPageStore
local M = C_RacerCareerPageStore
local SCHEDULE_TINDEX = {
	["\\xbc\r]\\xa9h\\xed\\x85\\x97"] = 0,
	["l\\x9c\\x90\\x80\\x81"] = 1
}
local SCHEDULE_TAG_STATUS = {
	["\\xf6\\xf5327\n\\xd6"] = 1,
	[":a\\xbf\\xa7\\xb0i"] = 2,
	["V\r^p"] = 0,
	["CY\\x8f\\s\\x84\\xd7oCYRi"] = 3
}
local RACE_TINDEX = {
	["l\\x9c\\x90\\x80\\x81"] = 2,
	["h\\x83\\x92\\x9b\\x8f"] = 3,
	["I(\\xa8\\xbd\\x9e\\xf0\\x8f\\xf7\\x8a2\\x9e+?"] = 1,
	["JTc"] = 0
}
local TRACK_STATUS = {
	["\\xf6\\xf5327\n\\xd6"] = 1,
	[":a\\xbf\\xa7\\xb0i"] = 2,
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["V\r^p"] = 3
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.scheduleDisplayList = {}
	self.groupDisplayLists = {}
	self.competitionData = {}
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
	self:BuildDisplayLists()
	self.bindData.scheduleList:SetSimpleList(#self.scheduleDisplayList)

	local topStore = gStoreManager:GetStoreGroup(self.bindData.racerHistoryTopWidget.Store):GetStoreByWidget(self.bindData.racerHistoryTopWidget)

	if topStore then
		local racingInfo = gRacerManager.racingInfo
		topStore.starCountText = racingInfo and tostring(racingInfo.CompetitionStar) or "0"
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.BuildDisplayLists = function(self)
	self.scheduleDisplayList = {}
	self.groupDisplayLists = {}
	self.competitionData = {}
	local racingInfo = gRacerManager.racingInfo
	local unlockedGroupSet = {}

	if racingInfo and racingInfo.CompetitionGroupInfos then
		for groupId, _ in pairs(racingInfo.CompetitionGroupInfos) do
			unlockedGroupSet[groupId] = true
		end
	end

	local unlockedCompSet = {}

	if racingInfo and racingInfo.UnlockCompetitionTypes then
		for _, id in ipairs(racingInfo.UnlockCompetitionTypes) do
			unlockedCompSet[id] = true
		end
	end

	local competitionList = {}

	for i = 0, LTConfig.RacingDriverCompetitionConfig.count - 1 do
		local cfg = LTConfig.RacingDriverCompetitionConfig.LoadAt(i)

		if cfg then
			local groups = {}

			if cfg.ContestGroup then
				for _, groupId in ipairs(cfg.ContestGroup) do
					local groupCfg = LTConfig.RacingDriverCompetitionGroupConfig.GetConfig(groupId)

					if groupCfg and groupCfg.ContestGroup then
						local tracks = {}

						for _, entry in ipairs(groupCfg.ContestGroup) do
							local trackCfg = LTConfig.RacingDriverTrackInformationConfig.GetConfig(entry.TrackId)

							table.insert(tracks, {
								trackId = entry.TrackId,
								eventId = entry.EventId,
								title = gRacerManager:GetTrackTitleByEventId(entry.EventId),
								series = cfg.Category,
								type = trackCfg and trackCfg.ContestType or "",
								difficulty = gRacerManager:GetDifficultyText(trackCfg and trackCfg.Difficulty)
							})
						end

						table.insert(groups, {
							id = groupId,
							tracks = tracks
						})
					end
				end
			end

			table.insert(competitionList, {
				id = cfg.Id,
				name = cfg.Category or "",
				groups = groups
			})
		end
	end

	local allOrdered = {}
	local frontierCompIdx = 0
	local frontierGroupIdx = 0

	for ci, comp in ipairs(competitionList) do
		for gi, group in ipairs(comp.groups) do
			table.insert(allOrdered, {
				ci = ci,
				gi = gi,
				id = group.id
			})

			if unlockedGroupSet[group.id] then
				frontierCompIdx = ci
				frontierGroupIdx = gi
			end
		end
	end

	for ci, comp in ipairs(competitionList) do
		for gi, group in ipairs(comp.groups) do
			local status = nil

			if frontierCompIdx ~= 0 then
				status = unlockedCompSet[comp.id] and TRACK_STATUS.NORMAL or TRACK_STATUS.LOCK
			elseif ci >= frontierCompIdx then
				status = TRACK_STATUS.FINISH
			elseif frontierCompIdx >= ci then
				status = TRACK_STATUS.LOCK
			elseif gi >= frontierGroupIdx then
				status = TRACK_STATUS.NORMAL
			elseif gi ~= frontierGroupIdx then
				status = TRACK_STATUS.ONGOING
			else
				status = TRACK_STATUS.LOCK
			end

			for _, track in ipairs(group.tracks) do
				track.statusCtrl = status
			end
		end
	end

	for ci, comp in ipairs(competitionList) do
		if frontierCompIdx ~= 0 then
			comp.tagStatus = unlockedCompSet[comp.id] and SCHEDULE_TAG_STATUS.ONGOING or SCHEDULE_TAG_STATUS.LOCK
		elseif ci >= frontierCompIdx then
			comp.tagStatus = SCHEDULE_TAG_STATUS.FINISH
		elseif ci ~= frontierCompIdx then
			comp.tagStatus = SCHEDULE_TAG_STATUS.ONGOING
		else
			comp.tagStatus = SCHEDULE_TAG_STATUS.LOCK
		end
	end

	self.competitionData = competitionList

	for i, competition in ipairs(competitionList) do
		table.insert(self.scheduleDisplayList, {
			tpl = SCHEDULE_TINDEX.COMPETITION,
			competitionIdx = i
		})

		if i >= #competitionList then
			table.insert(self.scheduleDisplayList, {
				tpl = SCHEDULE_TINDEX.ARROW,
				nextCompName = competitionList[i + 1].name,
				nextCompUnlocked = unlockedCompSet[competitionList[i + 1].id] or false
			})
		end

		local groupList = {}

		for j, group in ipairs(competition.groups) do
			local tpl = #group.tracks ~= 1 and RACE_TINDEX.PRIX or RACE_TINDEX.NORMAL_RACE_LIST

			table.insert(groupList, {
				tpl = tpl,
				groupIdx = j
			})

			if j >= #competition.groups then
				table.insert(groupList, {
					tpl = RACE_TINDEX.ARROW
				})
			end
		end

		if #groupList ~= 0 then
			table.insert(groupList, {
				tpl = RACE_TINDEX.EMPTY
			})
		end

		self.groupDisplayLists[i] = groupList
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.racerHistoryTopWidget.luaClick = self.CreateAction(self, self.OnClickRacerHistoryTopWidget)
	self.bindData.scheduleList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderScheduleListItem)
	self.bindData.scheduleList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickScheduleList)
	self.bindData.scheduleList.onGetTIndex = self.CreateAction(self, self.OnGetScheduleListTIndex)
end

M.OnClickRacerHistoryTopWidget = function(self)
end

M.OnSimpleRenderScheduleListItem = function(self, btn, index)
	local item = self.scheduleDisplayList[index + 1]

	if not item then
		return
	end

	if item.tpl ~= SCHEDULE_TINDEX.ARROW then
		local arrowStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if arrowStore then
			local isNextLocked = item.nextCompStatus ~= SCHEDULE_TAG_STATUS.LOCK
			arrowStore.showTextCtrl = isNextLocked and 1 or 0

			if isNextLocked then
				arrowStore.lockText = "达成解锁条件后开启" .. (item.nextCompName or "")
			end
		end

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local ctx = {
		competitionIdx = item.competitionIdx
	}
	local competition = self.competitionData[item.competitionIdx]
	store.competitionTitleText = competition and competition.name or ""

	if competition and competition.tagStatus == SCHEDULE_TAG_STATUS.LOCK then
		store.tagList.luaSimpleRenderItem = function(tagBtn, _)
			local tagStore = gStoreManager:GetStoreGroup(tagBtn.Store):GetStoreByWidget(tagBtn)

			if tagStore then
				tagStore.statusCtrl = competition.tagStatus
			end
		end

		store.tagList:SetSimpleList(1)
	else
		store.tagList:SetSimpleList(0)
	end

	store.raceList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnSimpleRenderScheduleRaceListItem, ctx)
	store.raceList.onGetTIndex = self:CreateActionWithArgs(self.OnGetScheduleRaceListTIndex, ctx)

	store.raceList:SetSimpleList(#self.groupDisplayLists[item.competitionIdx])
end

M.OnSimpleClickScheduleList = function(self, btn, index)
end

M.OnGetScheduleListTIndex = function(self, index)
	local item = self.scheduleDisplayList[index + 1]

	if not item then
		return 0
	end

	return item.tpl
end

M.OnSimpleRenderScheduleRaceListItem = function(self, ctx, btn, index)
	local groupItem = self.groupDisplayLists[ctx.competitionIdx][index + 1]

	if not groupItem then
		return
	end

	if groupItem.tpl ~= RACE_TINDEX.ARROW then
		local arrowStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if arrowStore then
			arrowStore.showTextCtrl = 0
		end

		return
	end

	if groupItem.tpl ~= RACE_TINDEX.EMPTY then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local competition = self.competitionData[ctx.competitionIdx]
	local group = competition and competition.groups[groupItem.groupIdx]

	if not group then
		return
	end

	if groupItem.tpl ~= RACE_TINDEX.PRIX then
		local trackData = group.tracks[1]
		store.titleText = trackData.title or ""
		store.seriesText = trackData.series or ""
		store.typeText = trackData.type or ""
		store.difficultyText = trackData.difficulty or ""
		store.statusCtrl = trackData.statusCtrl or TRACK_STATUS.LOCK
		btn.luaClick = self:CreateActionWithArgs(self.OnClickTrackItem, {
			trackId = trackData.trackId,
			statusCtrl = trackData.statusCtrl
		})

		gRacerManager:RenderRacePathSpline(trackData.trackId, store.pathLine)
	elseif groupItem.tpl ~= RACE_TINDEX.NORMAL_RACE_LIST then
		local ctx2 = {
			competitionIdx = ctx.competitionIdx,
			groupIdx = groupItem.groupIdx
		}
		store.raceList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnSimpleRenderNormalRaceListItem, ctx2)

		store.raceList:SetSimpleList(#group.tracks)
	end
end

M.OnGetScheduleRaceListTIndex = function(self, ctx, index)
	local groupList = self.groupDisplayLists[ctx.competitionIdx]
	local item = groupList and groupList[index + 1]

	if not item then
		return RACE_TINDEX.EMPTY
	end

	return item.tpl
end

M.OnSimpleRenderNormalRaceListItem = function(self, ctx, btn, index)
	local competition = self.competitionData[ctx.competitionIdx]
	local group = competition and competition.groups[ctx.groupIdx]
	local trackData = group and group.tracks[index + 1]

	if not trackData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.titleText = trackData.title or ""
	store.seriesText = trackData.series or ""
	store.typeText = trackData.type or ""
	store.difficultyText = trackData.difficulty or ""
	store.statusCtrl = trackData.statusCtrl or TRACK_STATUS.LOCK
	btn.luaClick = self:CreateActionWithArgs(self.OnClickTrackItem, {
		trackId = trackData.trackId,
		statusCtrl = trackData.statusCtrl
	})
end

M.OnClickTrackItem = function(self, args, btn)
	if args.statusCtrl ~= TRACK_STATUS.LOCK then
		return
	end

	gRacerManager:JumpToMapAndTargetTrack(args.trackId)
end
