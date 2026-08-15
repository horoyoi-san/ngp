local CollectionSubQuestConfig = LTConfig.CollectionSubQuestConfig
local CollectionQuestConfig = LTConfig.CollectionQuestConfig
local MapBlockMgr = LX6.Gps.MapBlockMgr
MapSubSystem_Camp = DefClass("MapSubSystem_Camp", MapSubSystem_Camp, MapSubSystemBase)
local M = MapSubSystem_Camp

function M:OnInit()
	self._subQuestInfos = {}
	self._activeSubQuestId = {}
	self._halfRedColor = Color.New(1, 0, 0, 0.5)
	self.eventHandler = {
		[gEventConstants.WILD_ENEMY_CAMP_STATE_CHANGE] = function ()
			self:FlushData("StateChange")
		end,
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = function (eventId, id)
			if id == LTConfig.SystemUnlockConfig.MidWildEnemyUnlock or id == LTConfig.SystemUnlockConfig.BigWildEnemyUnlock then
				self:FlushData("UnlockStateChange")
			end
		end
	}
end

function M:OnLogin()
	gMessageManager:RegisterEventHandlers(self.eventHandler)
end

function M:OnLogout()
	gMessageManager:UnregisterEventHandlers(self.eventHandler)
end

function M:OnLoadData()
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
			if questCfg.ShowType < 1 then
				-- Nothing
			elseif not questCfg.SQuestIcon or questCfg.SQuestIcon <= 0 then
				print_warn("CollectionQuestConfig: QuestIcon未配置或配置错误: ", cfg.QuestCategory)
			elseif questCfg.PoiLevel == 1 then
				if questCfg.MapIconShowType == 4 then
					local element = MapElement.CreateLegacy(EMapElementType.Camp, cfg.Id, EMapSubSystemType.Camp, EMapViewMask.AllSgui, LTConfig.RaidConfig.WorldMap, 0)

					element:SetActions(self.NormalTraceableActions)

					element.mData.sIconId = questCfg.SQuestIcon
					element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect
					element.gpsData.removeGpsRange = cfg.RemoveGpsRadius
					element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.Camp

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

function M:TryTraceCampByCollectionId(id)
	local info = self._subQuestInfos[id]

	if not info then
		return false
	end

	if info.mapElement:IsVisible() then
		gMapSubSystemActionHelper.Trace(info.mapElement)

		return true
	else
		return false
	end
end

function M:TryTraceAndLockAction(collectionId)
	local info = self._subQuestInfos[collectionId]

	if not info then
		return false
	end

	if info.mapElement:IsVisible() then
		gMapSubSystemActionHelper.Trace(info.mapElement)
		info.mapElement:SetActions(nil)

		return true
	else
		return false
	end
end

function M:TryUntraceAndUnlockAction(collectionId)
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

function M:Tick()
	if not L50.L50App.Scene.GamePlayUtils or L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local x = playerPos.x
	local z = playerPos.z

	for id, _ in pairs(self._activeSubQuestId) do
		local info = self._subQuestInfos[id]
		local shouldMuteUnit = false

		if not gBlockMgr:IsBlockUnlocked(info.blockId) then
			shouldMuteUnit = true

			info.mapElement:SetVisible(false)
		else
			info.mapElement:SetVisible(true)

			local dx = x - info.worldPos.x
			local dz = z - info.worldPos.z

			if dx * dx + dz * dz < info.sqrRadius then
				shouldMuteUnit = false

				self:SetRangeInfo(info, 1)
			else
				shouldMuteUnit = true

				self:SetRangeInfo(info, 2)
			end
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

local subQuestId2WildEnemyGroupId = {}

function M:OnFlushData()
	table.clear(subQuestId2WildEnemyGroupId)

	for id, _ in pairs(gTriggerEnemyMgr.activeList) do
		local wildEnemyGroup = gSpoonMgr:GetRaidGraph():GetWildEnemyData(id)

		if wildEnemyGroup and wildEnemyGroup.subQuestId and self._subQuestInfos[wildEnemyGroup.subQuestId] then
			subQuestId2WildEnemyGroupId[wildEnemyGroup.subQuestId] = id
		end
	end

	for id, _ in pairs(self._activeSubQuestId) do
		if not subQuestId2WildEnemyGroupId[id] then
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

	for subQuestId, wildEnemyGroupId in pairs(subQuestId2WildEnemyGroupId) do
		if not self._activeSubQuestId[subQuestId] then
			self._activeSubQuestId[subQuestId] = true
			local info = self._subQuestInfos[subQuestId]
			info.unitPids = gTriggerEnemyMgr.groupEnemyList[wildEnemyGroupId]
			local data = gSpoonMgr:GetRaidGraph():GetWildEnemyData(wildEnemyGroupId)
			local radius = data.uiRadius or 0
			info.radius = radius
			info.sqrRadius = radius * radius

			if data.pos then
				info.worldPos = Vector3.NewT(data.pos:ToLuaTable())
				info.blockId = MapBlockMgr.GetBlockIdXZ(LTConfig.RaidConfig.WorldMap, data.pos.x, data.pos.z)
			else
				print_error("MapSubSystem_Camp: WildEnemyGroup pos is nil, wildEnemyGroupId: ", wildEnemyGroupId)
			end

			info.mapElement:SetPosition(info.worldPos)
			self:SetRangeInfo(info, 1, radius)
		end
	end
end

function M:SetRangeInfo(info, type, radius)
	if not info.rangeInfoType1 then
		info.rangeInfoType1 = {
			tmp_type = 1,
			color = self._halfRedColor
		}
	end

	if not info.rangeInfoType2 then
		info.rangeInfoType2 = {
			tmp_type = 2,
			color = self._halfRedColor
		}
	end

	if radius then
		info.rangeInfoType1.radius = radius
		info.rangeInfoType2.radius = radius
	end

	if type == 1 then
		info.mapElement.mData.rangeInfo = info.rangeInfoType1
	else
		info.mapElement.mData.rangeInfo = info.rangeInfoType2
	end
end

function M:SGetTooltipInfo(id, element)
	return gMapSubSystemUtils:GetQuestTooltip(id, element)
end

function M:ExecuteAction(element, action, ctx)
	gMapSubSystemActionHelper.TryExecuteTraceAction(element, action, ctx)
end

return M
