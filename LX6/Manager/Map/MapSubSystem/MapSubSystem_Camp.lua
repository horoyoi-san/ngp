-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Camp.lua
-- Decompiled from: 02323_MapSubSystem_Camp.lua_6ba3fab15337.luajit

local CollectionSubQuestConfig = LTConfig.CollectionSubQuestConfig
local CollectionQuestConfig = LTConfig.CollectionQuestConfig
local MapBlockMgr = LX6.Gps.MapBlockMgr
MapSubSystem_Camp = DefClass("MapSubSystem_Camp", MapSubSystem_Camp, MapSubSystemBase)
local M = MapSubSystem_Camp

M.OnInit = function(self)
	self._subQuestInfos = {}
	self._activeSubQuestId = {}
	self.subQuestId2WildEnemyGroupId = {}
	self._halfRedColor = Color.New(1, 0, 0, 0.5)
	self.eventHandler = {
		[gEventConstants.WILD_ENEMY_CAMP_STATE_CHANGE] = function ()
			self:RefreshData()
		end,
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = function (eventId, id)
			if id ~= LTConfig.SystemUnlockConfig.MidWildEnemyUnlock or id ~= LTConfig.SystemUnlockConfig.BigWildEnemyUnlock then
				self:RefreshData()
			end
		end
	}
end

M.OnLogin = function(self)
	gMessageManager:RegisterEventHandlers(self.eventHandler)
end

M.OnLogout = function(self)
	gMessageManager:UnregisterEventHandlers(self.eventHandler)
end

M.OnSceneInit = function(self)
	self.RefreshData(self)
end

M.OnLoadData = function(self)
	for _, info in pairs(self._subQuestInfos) do
		info.mapElement:Dispose()

		info.mapElement = nil
	end

	table.clear(self._subQuestInfos)

	self._activeSubQuestId = {}

	for i = 0, CollectionSubQuestConfig.count - 1 do
		local cfg = CollectionSubQuestConfig.LoadAt(i)
		local questId = cfg.QuestCategory
		local questCfg = CollectionQuestConfig.GetConfig(questId)

		if questCfg and questCfg.ShowType then
			if questCfg.ShowType >= 1 then
				-- Nothing
			elseif not questCfg.SQuestIcon or questCfg.SQuestIcon < 0 then
				print_warn("CollectionQuestConfig: QuestIcon未配置或配置错误: ", cfg.QuestCategory)
			elseif questCfg.PoiLevel ~= 1 then
				if questCfg.MapIconShowType ~= 4 then
					local element = MapElement.CreateLegacy(EMapElementType.Camp, cfg.Id, EMapSubSystemType.Camp, EMapViewMask.AllSgui, LTConfig.RaidConfig.WorldMap, 0)

					element:SetActions(self.NormalTraceableActions)

					element.mData.sIconId = questCfg.SQuestIcon
					element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect
					element.gpsData.removeGpsRange = cfg.RemoveGpsRadius
					element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Camp
					element.fData.linkShowModes = questCfg.LinkShowMode or {}

					gMapSubSystemUtils:SetupSubQuestElementCommonInfo(element, questCfg, cfg)

					local info = {}
					self._subQuestInfos[cfg.Id] = info
					info.mapElement = element
					info.subQuestId = cfg.Id
				end
			end
		end
	end
end

M.TryTraceAndLockAction = function(self, collectionId)
	local info = self._subQuestInfos[collectionId]

	if not info then
		return false
	end

	if info.mapElement:IsVisible() then
		info.mapElement:SetMainTrace()
		info.mapElement:SetActions(nil)

		return true
	else
		return false
	end
end

M.TryUntraceAndUnlockAction = function(self, collectionId)
	local info = self._subQuestInfos[collectionId]

	if not info then
		return false
	end

	info.mapElement:SetActions(self.NormalTraceableActions)

	if info.mapElement:IsVisible() then
		gMapSubSystemActionHelper.Untrace(info.mapElement)

		return true
	else
		return false
	end
end

M.Tick = function(self)
	if gGpsTools:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local x = playerPos.x
	local z = playerPos.z

	for id, _ in pairs(self._activeSubQuestId) do
		local info = self._subQuestInfos[id]
		local shouldMuteUnit = false
		local campId = self.subQuestId2WildEnemyGroupId[id]

		if not gBlockMgr:IsBlockUnlocked(info.blockId) then
			shouldMuteUnit = true

			info.mapElement:SetVisible(false)
		elseif campId ~= gMapSystem.curCampId then
			info.mapElement:SetVisible(false)
		else
			info.mapElement:SetVisible(true)

			local dx = x - info.worldPos.x
			local dz = z - info.worldPos.z
			shouldMuteUnit = dx * dx + dz * dz < info.sqrRadius
		end

		if shouldMuteUnit then
			if not info.blacklistId then
				info.blacklistId = gMapSubSystem_CommonUnit:AddBlacklist(info.unitPids)
			end
		elseif info.blacklistId then
			gMapSubSystem_CommonUnit:RemoveBlacklist(info.blacklistId)

			info.blacklistId = nil
		end
	end
end

M.RefreshData = function(self)
	table.clear(self.subQuestId2WildEnemyGroupId)

	local campIdList = {}

	for id, _ in pairs(gTriggerEnemyMgr.activeList) do
		local cfg = LTConfig.BattleCampConfig.GetConfig(id)

		if cfg and cfg.SubQuestId then
			self.subQuestId2WildEnemyGroupId[cfg.SubQuestId] = id

			table.insert(campIdList, id)
		end
	end

	LX6.Gps.AreaMgr.graph:LuaUpdateActiveCampIds(campIdList)

	for id, _ in pairs(self._activeSubQuestId) do
		if not self.subQuestId2WildEnemyGroupId[id] then
			self._activeSubQuestId[id] = nil
			local info = self._subQuestInfos[id]

			info.mapElement:SetVisible(false)

			if info.blacklistId then
				gMapSubSystem_CommonUnit:RemoveBlacklist(info.blacklistId)

				info.blacklistId = nil
			end

			info.unitPids = nil
		end
	end

	for subQuestId, wildEnemyGroupId in pairs(self.subQuestId2WildEnemyGroupId) do
		if not self._activeSubQuestId[subQuestId] then
			self._activeSubQuestId[subQuestId] = true
			local cfg = LTConfig.BattleCampConfig.GetConfig(wildEnemyGroupId)
			local info = self._subQuestInfos[subQuestId]
			info.unitPids = gTriggerEnemyMgr.groupEnemyList[wildEnemyGroupId]
			local data = gSpoonMgr:GetRaidGraph():GetWildEnemyData(wildEnemyGroupId)
			local radius = cfg and cfg.UIRadius or 0
			info.radius = radius
			info.sqrRadius = radius * radius

			if data.pos then
				info.worldPos = Vector3.NewT(data.pos:ToLuaTable())
				info.blockId = MapBlockMgr.GetBlockIdXZ(LTConfig.RaidConfig.WorldMap, data.pos.x, data.pos.z)
			else
				print_error("MapSubSystem_Camp: WildEnemyGroup pos is nil, wildEnemyGroupId: ", wildEnemyGroupId)
			end

			info.mapElement:SetPosition(info.worldPos)
		end
	end
end

M.SGetTooltipInfo = function(self, id, element)
	return gMapSubSystemUtils:GetQuestTooltip(id, element)
end

M.ExecuteAction = function(self, element, action, ctx)
	gMapSubSystemActionHelper.TryExecuteTraceAction(element, action, ctx)
end

return M
