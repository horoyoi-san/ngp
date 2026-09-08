-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\BigMapComp_Racer.lua
-- Decompiled from: 01038_BigMapComp_Racer.lua_2df479efbff7.luajit

BigMapComp_Racer = BigMapComp_Racer or {}
local type = type
local table = table
local TrackInformationConfig = LTConfig.RacingDriverTrackInformationConfig
local CollectionSubQuestConfig = LTConfig.CollectionSubQuestConfig
local CollectionQuestConfig = LTConfig.CollectionQuestConfig
local MessageConfig = LTConfig.MessageConfig
local RacingDriverCompetitionConfig = LTConfig.RacingDriverCompetitionConfig
local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local M = BigMapComp_Racer
M.__index = M
local RaceListType = {
	["\\x99\\xb0\\xae^?\\xed8"] = 1,
	["\\x99\\xb0\\xaeC0\\xf8<"] = 0
}

M.OnInit = function(self)
	self.store = nil
	self.widget = nil
	self.racingList = {}

	if gSpiritJobManager:CheckContainJobClassId(JobClassConfig.RacingDriver) then
		gClientToGameDelegate:AskRacingCompetitionGroupInfo().Callback = function (err, info)
			if err == MessageConfig.Ok then
				print_error("请求赛车手职业数据失败", err, gCS.Error.GetNameById(err))

				return
			end

			self.racingInfo = info

			self:Refresh()
		end
	end
end

M.OnActive = function(self)
	self.bigMap:SetViewMask(EMapViewMask.Racer)

	self.bindData.taskListTab.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
	self.bindData.taskListTab.selectedIndex = 1

	self:Refresh()
end

M.RefreshRacingList = function(self)
	self.racingList = {}

	table.insert(self.racingList, {
		["\t\r"] = 0,
		type = RaceListType.RaceInfo
	})

	for i = 0, TrackInformationConfig.count - 1 do
		local config = TrackInformationConfig.LoadAt(i)

		if config.MapLocation and config.MapLocation <= 0 and config.IsOccupationTask then
			table.insert(self.racingList, {
				id = config.Id,
				type = RaceListType.RaceTask
			})
		end
	end

	self.store.list:SetSimpleList(#self.racingList)
end

M.OnInactive = function(self)
	self:Refresh()
end

M.OnEnd = function(self)
	self.bindData.taskListTab.selectedIndex = -1

	self.bindData.taskListTab:ClearUnusedTabInstances()

	self.racingInfo = nil

	gMapSystem.navigation:ClearBigMapRaceNavLineInfo()
end

M.Refresh = function(self)
	if not self:CheckLoaded() then
		if self.actived then
			self:LoadPanel()
		end

		return
	end

	if self.actived then
		self.widget:SetActive(true)
		self.bigMap:RegisterNavArea(EBigMapNavArea.Racer, self.store.navArea)
		self.bigMap:RegisterNavArea(EBigMapNavArea.Racer, self.store.listNavArea)
		self:RegisterScrollConflictArea()
		self:RefreshRacingList()
	else
		self.widget:SetActive(false)
		self.bigMap:UnRegisterNavArea(EBigMapNavArea.Racer, self.store.navArea)
		self.bigMap:UnRegisterNavArea(EBigMapNavArea.Racer, self.store.listNavArea)
		self:UnregisterScrollConflictArea()
	end
end

M.CheckLoaded = function(self)
	return self.store == nil and self.widget == nil
end

M.LoadPanel = function(self)
	self.bindData.taskListTab.selectedIndex = 1
end

M.OnPanelLoaded = function(self, index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMapCompRacerStore"):GetStoreByWidget(self.widget)
	self.store.list.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderItem", self)
	self.store.list.luaSimpleClick = self.bigMap:CreateAction("OnClickItem", self)
	self.store.list.onGetTIndex = self.bigMap:CreateAction("OnGetTIndex", self)

	self:Refresh()
end

M.RegisterScrollConflictArea = function(self)
	self.bigMap:RegisterScrollConflictArea("Racer", function ()
		return self:ScrollConflictAreaGetter()
	end)
end

M.UnregisterScrollConflictArea = function(self)
	self.bigMap:UnregisterScrollConflictArea("Racer")
end

M.ScrollConflictAreaGetter = function(self)
	if self.store and self.store.list then
		return self.store.list.rectTransform
	end

	return nil
end

M.OnRenderItem = function(self, btn, index)
	index = index + 1
	local data = self.racingList[index]

	if data.type ~= RaceListType.RaceInfo then
		local btnStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		btnStore.onRouteBtn = function()
			gPanelManager:CheckShow(gPanelId.RACER_MAIN_PANEL, {
				gotoPage = gRacerManager.APP_PAGE.CAREER
			})
		end

		btnStore.onAppBtn = function()
			gPanelManager:CheckShow(gPanelId.RACER_MAIN_PANEL)
		end

		local compTypes = self.racingInfo and self.racingInfo.UnlockCompetitionTypes

		if compTypes and #compTypes <= 0 then
			local lastCompId = compTypes[#compTypes]
			local compCfg = RacingDriverCompetitionConfig.GetConfig(lastCompId)
			btnStore.name = compCfg and compCfg.Category or ""
		end
	else
		local cfg = TrackInformationConfig.GetConfig(data.id)
		local subQuestCfg = cfg and CollectionSubQuestConfig.GetConfig(cfg.MapLocation)
		local questCfg = CollectionQuestConfig.GetConfig(subQuestCfg.QuestCategory)

		if subQuestCfg and questCfg then
			local btnStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

			if btnStore then
				btnStore.name = subQuestCfg.SubQuestName
				btnStore.iconId = questCfg.SQuestIcon
			end
		end
	end
end

M.OnClickItem = function(self, btn, index)
	index = index + 1
	local data = self.racingList[index]

	if data.type ~= RaceListType.RaceInfo then
		-- Nothing
	else
		local cfg = TrackInformationConfig.GetConfig(data.id)
		local subQuestId = cfg and cfg.MapLocation or 0

		if subQuestId <= 0 then
			local gpsId = gMapSubSystem_Collection:GetGpsIdBySubQuestId(subQuestId)
			local element = gMapSystem.container:GetByGpsId(gpsId)

			if element then
				local info = self.bigMap._id2ElementInfo[element.instanceId]

				if info and info.element then
					self.bigMap:ScheduleOperation(self.bigMap.OperationType.Select, {
						gpsId = gpsId
					}, true)
					self.bigMap:ScheduleOperation(self.bigMap.OperationType.FocusTexPos, {
						texPos = info.texPos
					}, true)
				end
			end
		end
	end
end

M.OnGetTIndex = function(self, index)
	index = index + 1
	local data = self.racingList[index]

	if data.type ~= RaceListType.RaceInfo then
		return 0
	else
		return 1
	end
end

M.OnUpdate = function(self)
	if not self:CheckLoaded() then
		return
	end
end

M.OnSelectElement = function(self, element)
	if element and element.type ~= EMapElementType.Collection then
		local trackInformationId = gMapSubSystem_Collection:GetRacingDriverIdBySubQuestId(element.id)
		local cfg = trackInformationId and TrackInformationConfig.GetConfig(trackInformationId)

		if cfg and cfg.RacingPathName and (not cfg.LeaveToRaidId or cfg.LeaveToRaidId ~= 0) then
			LX6.Gps.MapSystem.Instance:LuaTryLoadRacePathData(element.id, cfg.RacingPathName)
		end
	else
		gMapSystem.navigation:ClearBigMapRaceNavLineInfo()
		self.bigMap:SetRaceNavRenderInfo({})
	end
end

M.SetBigMapRaceNavLineInfo = function(self, id, pathLists)
	if not self:CheckLoaded() then
		gMapSystem.navigation:ClearBigMapRaceNavLineInfo()

		return
	end

	self.bigMap:SetRaceNavRenderInfo(pathLists)
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

M.GetBestScore = function(self, racingDriverId)
	if self.racingInfo and self.racingInfo.CompetitionHistoryInfos and self.racingInfo.CompetitionHistoryInfos[racingDriverId] then
		local bestScore = self:FormatCostTime(self.racingInfo.CompetitionHistoryInfos[racingDriverId].CostTime)
		local bestLevel = self.racingInfo.CompetitionHistoryInfos[racingDriverId].Star

		return bestScore, bestLevel
	else
		return nil, 
	end
end
