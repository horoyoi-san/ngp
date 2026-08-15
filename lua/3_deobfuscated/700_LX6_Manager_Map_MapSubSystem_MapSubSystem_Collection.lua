local CollectionQuestConfig = LTConfig.CollectionQuestConfig
local CollectionSubQuestConfig = LTConfig.CollectionSubQuestConfig
local TaskState = UX.Game.TaskState
local AtmosphereManager = LX6.Manager.AtmosphereManager
MapSubSystem_Collection = DefClass("MapSubSystem_Collection", MapSubSystem_Collection, MapSubSystemBase)
local M = MapSubSystem_Collection
M.QuestIconShowType = {
	LifeQualityChallenge = 3,
	Camp = 4,
	AlwaysShow = 6,
	Once = 1,
	Challenge = 2,
	MiniMapOnlySideQuest = 5
}

function M:Tick()
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local hour = math.floor(gameTime / 3600)

	if hour ~= self._lastHour then
		self._lastHour = hour

		self:FlushData("HourChange")
	end
end

function M:OnInit()
	self._collectionInfo = {}

	self:InitEventHandler()
end

function M:OnLoadData()
	for id, info in pairs(self._collectionInfo) do
		info.mapElement:Dispose()

		info.mapElement = nil
	end

	table.clear(self._collectionInfo)

	for i = 0, CollectionSubQuestConfig.count - 1 do
		local cfg = CollectionSubQuestConfig.LoadAt(i)
		local questCfg = CollectionQuestConfig.GetConfig(cfg.QuestCategory)

		if questCfg and questCfg.PoiLevel == 1 and questCfg.ShowType and questCfg.ShowType >= 1 then
			if questCfg.ShowType > 3 then
				-- Nothing
			elseif not questCfg.SQuestIcon or questCfg.SQuestIcon <= 0 then
				print_warn("CollectionQuestConfig: SQuestIcon未配置或配置错误: ", cfg.QuestCategory)
			else
				local questType = questCfg.MapIconShowType

				if questType ~= self.QuestIconShowType.MiniMapOnlySideQuest then
					if questType == self.QuestIconShowType.Camp then
						-- Nothing
					elseif not questType then
						print_error("CollectionQuestConfig: PoiLevel为1的玩法需要配置MapIconShowType: ", cfg.QuestCategory)
					elseif table.isNilOrEmpty(cfg.Coordinate) then
						print_warn("CollectionSubQuestConfig未配置Coordinate: ", cfg.Id)
					elseif not cfg.TaskId then
						print_error("CollectionSubQuestConfig未配置TaskId: ", cfg.Id)
					else
						local coord = cfg.Coordinate
						local worldPos = Vector3.New(coord[1], coord[2], coord[3])
						local blockId = nil

						if cfg.QuestCategory == 28 or cfg.QuestCategory == 31 or cfg.QuestCategory == 32 then
							blockId = cfg.Block or 0
						else
							blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(LTConfig.RaidConfig.WorldMap, coord[1], coord[3])
						end

						local element = MapElement.CreateLegacy(EMapElementType.Collection, cfg.Id, EMapSubSystemType.Collection, EMapViewMask.AllSgui, LTConfig.RaidConfig.WorldMap, 0)

						element:SetActions(self.NormalTraceableActions)
						element:SetPosition(worldPos)
						element:SetVisible(false)

						element.gpsData.removeGpsRange = cfg.RemoveGpsRadius
						element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect

						if questCfg.LinkShowMode > 0 then
							element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.LinkModeCollection
						elseif questType == self.QuestIconShowType.Challenge or questType == self.QuestIconShowType.AlwaysShow then
							element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Challenge
						end

						gMapSubSystemUtils:SetupSubQuestElementCommonInfo(element, questCfg, cfg)

						local info = {
							visible = false,
							mapElement = element,
							blockId = blockId,
							questType = questType
						}
						self._collectionInfo[cfg.Id] = info
					end
				end
			end
		end
	end
end

function M:GetAllVisiblePoiISubQuestPos()
	local ret = {}

	for id, info in pairs(self._collectionInfo) do
		if info.visible then
			ret[id] = info.mapElement:GetWorldPos()
		end
	end

	return ret
end

function M:CheckLinkMode(questCfg)
	if questCfg.Id == 100 then
		return gLinkManager.LinkMode ~= UX.Game.LinkMode.Match
	elseif questCfg.Id == 101 then
		return gLinkManager.LinkMode == UX.Game.LinkMode.Private or gLinkManager.LinkMode == UX.Game.LinkMode.Public
	elseif questCfg.LinkShowMode == 1 then
		return gLinkManager.LinkMode ~= UX.Game.LinkMode.None
	elseif questCfg.LinkShowMode == 0 then
		return gLinkManager.LinkMode == UX.Game.LinkMode.None
	end
end

function M:OnFlushData()
	local unlockedQuestList = gPlayerManager.infoAchievement.bindData.UnlockedQuestList

	for id, info in pairs(self._collectionInfo) do
		local subQuestCfg = CollectionSubQuestConfig.GetConfig(id)

		if not subQuestCfg then
			-- Nothing
		end

		local questCfg = CollectionQuestConfig.GetConfig(subQuestCfg.QuestCategory)
		local element = info.mapElement
		local questType = info.questType
		local unlocked = false
		local iconState = 1

		if not self:CheckLinkMode(questCfg) or not gBlockMgr:IsBlockUnlocked(info.blockId) or not unlockedQuestList or not array.contains(unlockedQuestList, questCfg.Id) then
			unlocked = false
		elseif questType == self.QuestIconShowType.Challenge then
			if gMapSubSystemUtils:IsChallengeAcceptableByTaskId(subQuestCfg.TaskId) then
				unlocked = true
			end
		elseif gMapSubSystemUtils:IsCollectionTaskUnacceptable(subQuestCfg.TaskId) then
			unlocked = false
		elseif questType == self.QuestIconShowType.AlwaysShow then
			unlocked = true
		elseif questType == self.QuestIconShowType.Once then
			if not subQuestCfg.TaskId or subQuestCfg.TaskId == 0 then
				unlocked = false
			else
				local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(subQuestCfg.TaskId)
				local state = gTaskNodeManager:GetTaskLineState(taskLineInfo.TaskLineId)
				unlocked = state == gTaskLineState.NoAccept

				if unlocked then
					local event = gTaskManager.taskEvents[taskLineInfo.TaskLineId]

					if event and event.Acceptable then
						unlocked = false
					end
				end
			end
		elseif questType == self.QuestIconShowType.LifeQualityChallenge then
			local state = gTaskManager:GetTaskState(subQuestCfg.TaskId)
			unlocked = state == TaskState.NotAccept or state == TaskState.Aborted or state == TaskState.Submited
		end

		if unlocked and not table.isNilOrEmpty(subQuestCfg.ExtraPlayableCondition) then
			unlocked = gMapSubSystemUtils:CheckExtraPlayableCondition(subQuestCfg.ExtraPlayableCondition)
		end

		element:SetVisible(unlocked)

		info.visible = unlocked

		if subQuestCfg.TargetNpcId and subQuestCfg.TargetNpcId > 0 then
			element:BindUnit(subQuestCfg.TargetNpcId)

			if unlocked then
				element:CbtSetWeakGuideInfo(subQuestCfg.RemoveGpsRadius)
			else
				element:CbtClearWeakGuideInfo()
			end
		end

		element.mData.sIconId = iconState == 2 and 28001083 or questCfg.SQuestIcon
	end
end

function M:SGetTooltipInfo(id, element)
	return gMapSubSystemUtils:GetQuestTooltip(id, element)
end

function M:ExecuteAction(element, action, ctx)
	gMapSubSystemActionHelper.TryExecuteTraceAction(element, action, ctx)
end

function M:InitEventHandler()
	self.eventHandlers = {
		[gEventConstants.SYNC_COLLECTION_GET] = function ()
			self:FlushData()
		end,
		[gEventConstants.SYNC_COLLECTION_UNLOCK] = function (eventId, params)
			self:FlushData()
		end,
		[gEventConstants.PALYER_LEVEL_UP] = function ()
			self:FlushData()
		end,
		[gEventConstants.TASK_EVENT_CHANGE] = function ()
			self:FlushData()
		end,
		[gEventConstants.MAP_INFO_UPDATE] = function ()
			self:FlushData()
		end,
		[gEventConstants.LINK_MODE_CHANGE] = function ()
			self:FlushData()
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

return M
