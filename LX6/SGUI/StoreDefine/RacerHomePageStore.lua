-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RacerHomePageStore.lua
-- Decompiled from: 00893_RacerHomePageStore.lua_63ec63bb8a71.luajit

C_RacerHomePageStore = DefClass("C_RacerHomePageStore", C_RacerHomePageStore, C_StoreGroup)
GroupName2Class.RacerHomePageStore = C_RacerHomePageStore
local M = C_RacerHomePageStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.rankDisplayList = {}
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
	self:BuildRankList()
	self.bindData.rankList:SetSimpleList(#self.rankDisplayList)

	local racingInfo = gRacerManager.racingInfo

	if racingInfo then
		self.bindData.currentPointText = tostring(racingInfo.CompetitionPoint or 0)
		local unlockedGroupSet = {}

		if racingInfo.CompetitionGroupInfos then
			for groupId, _ in pairs(racingInfo.CompetitionGroupInfos) do
				unlockedGroupSet[groupId] = true
			end
		end

		local currentCompName = ""

		for i = 0, LTConfig.RacingDriverCompetitionConfig.count - 1 do
			local compCfg = LTConfig.RacingDriverCompetitionConfig.LoadAt(i)

			if compCfg and compCfg.ContestGroup then
				for _, groupId in ipairs(compCfg.ContestGroup) do
					if unlockedGroupSet[groupId] then
						currentCompName = compCfg.Category or ""

						break
					end
				end
			end
		end

		self.bindData.currentScheduleText = currentCompName
	end

	local jobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.RacingDriver)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(jobId)
	self.bindData.jobNameText = urbanJobCfg and urbanJobCfg.Name or ""
end

M.OnActiveDeviceChange = function(self, device)
end

M.BuildRankList = function(self)
	self.rankDisplayList = {}
	local racingInfo = gRacerManager.racingInfo
	local aiPointMap = racingInfo and racingInfo.MemberCompetitionPoint or {}
	local teamScores = {}

	for i = 0, LTConfig.RacingDriverMotorcadeConfig.count - 1 do
		local teamCfg = LTConfig.RacingDriverMotorcadeConfig.LoadAt(i)

		if teamCfg and teamCfg.TeamStaff then
			local totalPoints = 0

			for _, aiId in ipairs(teamCfg.TeamStaff) do
				totalPoints = totalPoints + (aiPointMap[aiId] or 0)
			end

			if teamCfg.Id ~= 1 then
				totalPoints = totalPoints + (racingInfo and racingInfo.CompetitionPoint or 0)
				self.bindData.selfTeamNameText = teamCfg.TeamName
			end

			table.insert(teamScores, {
				teamId = teamCfg.Id,
				name = teamCfg.TeamName or "",
				points = totalPoints,
				isSelf = teamCfg.Id ~= 1
			})
		end
	end

	table.sort(teamScores, function (a, b)
		return b.points <= a.points
	end)

	for _, entry in ipairs(teamScores) do
		table.insert(self.rankDisplayList, {
			name = entry.name,
			points = tostring(entry.points),
			isSelf = entry.isSelf
		})
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.scheduleBtn.luaClick = self.CreateAction(self, self.OnClickScheduleBtn)
	self.bindData.talentBtn.luaClick = self.CreateAction(self, self.OnClickTalentBtn)
	self.bindData.historyBtn.luaClick = self.CreateAction(self, self.OnClickHistoryBtn)
	self.bindData.mapBtn.luaClick = self.CreateAction(self, self.OnClickMapBtn)
	self.bindData.rankList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderRankListItem)
	self.bindData.rankList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickRankList)
end

M.OnClickScheduleBtn = function(self)
	gRacerManager:SwitchToPage(gRacerManager.APP_PAGE.CAREER)
end

M.OnClickTalentBtn = function(self)
	gUIFunctionStateManager:TalentTreeOpenTrigger({
		jobClassId = LTConfig.UrbanJobJobClassConfig.RacingDriver
	})
end

M.OnClickHistoryBtn = function(self)
	gRacerManager:SwitchToPage(gRacerManager.APP_PAGE.HISTORY)
end

M.OnClickMapBtn = function(self)
	local raidId = gMapManager:GetParentRaidId(gMapSystem.lastRaidId)
	local indoorId = gMapSystem.lastIndoorId

	if indoorId <= 0 then
		local indoorCfg = LTConfig.IndoorConfig.GetConfig(indoorId)

		if indoorCfg then
			raidId = indoorCfg.ParentRaid or LTConfig.RaidConfig.WorldMap
		else
			raidId = LTConfig.RaidConfig.WorldMap
		end
	end

	gMapUtils:CheckRaidCanOpenMap({
		["\\xa2\\xbf\\xa4e,\\xd77"] = 0,
		["QFol\\3="] = true,
		raidId = raidId
	})
end

M.OnSimpleRenderRankListItem = function(self, btn, index)
	local entry = self.rankDisplayList[index + 1]

	if not entry then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.rankText = tostring(index + 1)
	store.nameText = entry.name
	store.pointsText = entry.points
	store.selfRankCtrl = entry.isSelf and 1 or 0
	store.showChangeCtrl = 0
	store.rankChangeText = entry.change or ""
end

M.OnSimpleClickRankList = function(self, btn, index)
end
