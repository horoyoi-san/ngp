local CollectionQuestConfig = LTConfig.CollectionQuestConfig
local CollectionSubQuestConfig = LTConfig.CollectionSubQuestConfig
MapSubSystem_CollectionType5 = DefClass("MapSubSystem_CollectionType5", MapSubSystem_CollectionType5, MapSubSystemBase)
local M = MapSubSystem_CollectionType5

function M:OnInit()
	self._gpsEntries = {}
	self.eventHandlers = {
		[gEventConstants.SYNC_COLLECTION_GET] = function ()
			self:FlushData()
		end,
		[gEventConstants.SYNC_COLLECTION_UNLOCK] = function ()
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
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:OnLoadData()
	for _, gpsEntry in ipairs(self._gpsEntries) do
		gpsEntry.mapElement:Dispose()
	end

	table.clear(self._gpsEntries)

	if self._miniMapSideQuests then
		for _, element in pairs(self._miniMapSideQuests) do
			element:Dispose()
		end
	end

	for i = 0, CollectionSubQuestConfig.count - 1 do
		local cfg = CollectionSubQuestConfig.LoadAt(i)
		local questCfg = CollectionQuestConfig.GetConfig(cfg.QuestCategory)

		if questCfg and questCfg.PoiLevel == 1 then
			if questCfg.MapIconShowType ~= 5 then
				-- Nothing
			elseif not questCfg.SQuestIcon or questCfg.SQuestIcon <= 0 then
				print_warn("CollectionQuestConfig: SQuestIcon未配置或配置错误: ", cfg.QuestCategory)
			elseif table.isNilOrEmpty(cfg.Coordinate) then
				print_error("CollectionSubQuestConfig未配置Coordinate: ", cfg.Id)
			elseif not cfg.TaskId then
				print_error("CollectionSubQuestConfig未配置TaskId: ", cfg.Id)
			else
				local coord = cfg.Coordinate
				local worldPos = Vector3.New(coord[1], coord[2], coord[3])
				local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(LTConfig.RaidConfig.WorldMap, coord[1], coord[3])
				local element = MapElement.CreateLegacy(EMapElementType.Collection, cfg.Id, EMapSubSystemType.CollectionType5, EMapViewMask.MiniMap, LTConfig.RaidConfig.WorldMap, 0)

				element:SetPosition(worldPos)

				element.mData.sIconId = questCfg.SQuestIcon
				self._gpsEntries[cfg.Id] = {
					mapElement = element,
					questCfg = questCfg,
					cfg = cfg,
					blockId = blockId
				}
			end
		end
	end
end

function M:OnFlushData()
	local unlockedQuestList = gPlayerManager.infoAchievement.bindData.UnlockedQuestList

	for id, entry in pairs(self._gpsEntries) do
		local subQuestCfg = CollectionSubQuestConfig.GetConfig(id)
		local questCfg = CollectionQuestConfig.GetConfig(subQuestCfg.QuestCategory)

		if gMapSubSystemUtils:IsCollectionTaskUnacceptable(subQuestCfg) or not gBlockMgr:IsBlockUnlocked(entry.blockId) or not table.contains(unlockedQuestList, questCfg.Id) then
			entry.unlocked = false
		else
			entry.unlocked = true
		end

		if entry.unlocked and not table.isNilOrEmpty(subQuestCfg.ExtraPlayableCondition) then
			entry.unlocked = gMapSubSystemUtils:CheckExtraPlayableCondition(subQuestCfg.ExtraPlayableCondition)
		end
	end
end

function M:Tick()
	if gRaidDataManager.RaidId ~= LTConfig.RaidConfig.WorldMap then
		return
	end

	if not L50.L50App.Scene.GamePlayUtils or L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local x = playerPos.x
	local y = playerPos.y
	local z = playerPos.z
	local sqrInXZ = LTConfig.CollectionConfig.PoiIShowDistance[1]
	sqrInXZ = sqrInXZ * sqrInXZ
	local sqrInY = LTConfig.CollectionConfig.PoiIShowDistance[2]
	sqrInY = sqrInY * sqrInY
	local sqrOutXZ = LTConfig.CollectionConfig.PoiIHideDistance[1]
	sqrOutXZ = sqrOutXZ * sqrOutXZ
	local sqrOutY = LTConfig.CollectionConfig.PoiIHideDistance[2]
	sqrOutY = sqrOutY * sqrOutY

	for id, entry in pairs(self._gpsEntries) do
		local element = entry.mapElement
		local pos = element:GetWorldPos()
		local dx = x - pos.x
		local dy = y - pos.y
		local dz = z - pos.z
		local sqrDistXZ = dx * dx + dz * dz
		local sqrDistY = dy * dy

		if sqrDistXZ < sqrInXZ and sqrDistY < sqrInY then
			entry.inRange = true
		elseif sqrOutXZ < sqrDistXZ or sqrOutY < sqrDistY then
			entry.inRange = false
		end

		if entry.inRange and entry.unlocked then
			element:SetVisible(true)
		else
			element:SetVisible(false)
		end
	end
end

return M
