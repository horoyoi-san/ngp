local RaidConfig = LTConfig.RaidConfig
local MapentranceConfig = LTConfig.MapentranceConfig
local SceneConfig = LTConfig.SceneConfig
local HouseConfig = LTConfig.HouseConfig
local MessageConfig = LTConfig.MessageConfig
local M = gMapUtils or {}
M.IconType = {
	TaxiTarget = 21,
	TaskGps = 28,
	House = 24,
	RangeEvent = 20,
	SlotEntity = 17,
	Metro = 23,
	TempDungeon = 25,
	Dungeon = 26,
	Mark = 11,
	Gps = 27,
	Enemy = 1,
	Boss = 2,
	Tower = 22,
	Entrance = 5,
	RandomEvent = 19,
	JingYing = 3,
	Compound = 18,
	Task = 7,
	Vehicle = 29,
	PoliceCar = 30,
	NearByPhoto = 31,
	Collection = 9,
	Debug = 999,
	GpsByForce = 12,
	BossDrop = 14
}
M.TraceEffectType = {
	GamePlay = 4,
	Task = 3,
	Tower = 2,
	Site = 5,
	Boss = 6,
	Normal = 1
}
M.RaidMapEntranceType = {
	Tower = 9,
	Metro = 11,
	TempDungeon = 5,
	Dungeon = 6,
	House = 12,
	Portal = 13
}
M.MapPinState = {
	Remove = 2,
	Add = 1,
	Change = 3
}
M.LinkModeType = {
	Private = 2,
	Public = 3,
	Match = 4,
	None = 1
}

function M:Init()
	self:TMP_InitHouseInfo()
end

function M:TMP_InitHouseInfo()
	if self._entrance2HouseId then
		return
	end

	self._entrance2HouseId = {}

	for i = 0, HouseConfig.count - 1 do
		local cfg = HouseConfig.LoadAt(i)

		if cfg.MapEntrance and cfg.MapEntrance > 0 then
			self._entrance2HouseId[cfg.MapEntrance] = cfg.Id
		end
	end
end

function M:SyncMapEntranceState(visibleEntrance, unlockedEntrance)
	self._visibleEntrance = visibleEntrance or {}
	self._unlockedEntrance = unlockedEntrance or {}

	gMessageManager:SendMessage(gEventConstants.MAP_ENTRANCE_UPDATE)
	gMessageManager:SendMessage(gEventConstants.MAP_INFO_UPDATE)
end

function M:UpdateMapEntranceState(mapEntranceId, isOpen, isShow)
	self._visibleEntrance = self._visibleEntrance or {}
	self._unlockedEntrance = self._unlockedEntrance or {}

	if isShow then
		if not array.contains(self._visibleEntrance, mapEntranceId) then
			array.push(self._visibleEntrance, mapEntranceId)
		end
	else
		array.remove(self._visibleEntrance, mapEntranceId)
	end

	if isOpen then
		if not array.contains(self._unlockedEntrance, mapEntranceId) then
			array.push(self._unlockedEntrance, mapEntranceId)
		end
	else
		array.remove(self._unlockedEntrance, mapEntranceId)
	end

	gMessageManager:SendMessage(gEventConstants.MAP_ENTRANCE_UPDATE)
	gMessageManager:SendMessage(gEventConstants.MAP_INFO_UPDATE)
end

function M:IsEntranceVisible(id)
	return self._visibleEntrance and array.contains(self._visibleEntrance, id)
end

function M:SyncPortalItem(raidId, position)
	if not raidId or not position or raidId == 0 then
		return
	end

	local mapEntranceId = LTConfig.MapentranceConfig.PortalItem
	self._visibleEntrance = self._visibleEntrance or {}
	self._unlockedEntrance = self._unlockedEntrance or {}

	if not array.contains(self._visibleEntrance, mapEntranceId) then
		array.push(self._visibleEntrance, mapEntranceId)
	end

	if not array.contains(self._unlockedEntrance, mapEntranceId) then
		array.push(self._unlockedEntrance, mapEntranceId)
	end

	gMapSubSystem_Entrance:SyncPortalItem(raidId, position)
	gMessageManager:SendMessage(gEventConstants.MAP_ENTRANCE_UPDATE)
	gMessageManager:SendMessage(gEventConstants.MAP_INFO_UPDATE)
end

function M:IsEntranceUnlocked(id)
	return self._unlockedEntrance and array.contains(self._unlockedEntrance, id)
end

function M:IsInUnlockBlockNear(blockId)
	return table.contains(gMapManager.UnlockBlocksNearBlock, blockId)
end

function M:IsBelongRaidId(raidId1, raidId2)
	local info1 = gMapManager.IndoorConfigInfoByRaidId[raidId1]
	local info2 = gMapManager.IndoorConfigInfoByRaidId[raidId2]

	if info1 then
		if info2 then
			return info1.ParentRaid == info2.ParentRaid
		else
			return info1.ParentRaid == raidId2
		end
	end

	return raidId1 == raidId2
end

local mapData = {
	default = {
		isUnfold = true,
		mapScale = 1,
		mapPos = Vector2.New(0, 0)
	}
}

function M:OnBeforeSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	mapData = {
		default = {
			isUnfold = true,
			mapScale = 1,
			mapPos = Vector2.New(0, 0)
		}
	}
end

function M:TryInitSavedData(raidId)
	if mapData[raidId] then
		return
	end

	mapData[raidId] = {}
	local data = mapData[raidId]
	local raidCfg = RaidConfig.GetConfig(raidId)
	local sceneCfg = raidCfg and raidCfg.SceneId and SceneConfig.GetConfig(raidCfg.SceneId)
	data.mapScale = sceneCfg and sceneCfg.MapDefaultRate or 0.85
	data.mapPos = Vector2.New(0, 0)
	data.isUnfold = true
end

function M:GetSavedDataByType(raidId, type)
	if not raidId then
		return mapData.default[type]
	end

	if not mapData[raidId] then
		self:TryInitSavedData(raidId)
	end

	if mapData[raidId] and mapData[raidId][type] then
		return mapData[raidId][type]
	else
		return mapData.default[type]
	end
end

function M:SaveData(raidId, type, data)
	if raidId == nil then
		return
	end

	if not mapData[raidId] then
		self:TryInitSavedData(raidId)
	end

	mapData[raidId][type] = data
end

function M:CheckRaidCanOpenMap(param)
	if gMapSystem:Tmp_CanOpenBigMap(gMapSystem.lastRaidId, gMapSystem.lastIndoorId) then
		if gDriveVehiclesManager.isTaxiMode then
			param = param or {}
			param.taxiMode = true
		end

		gPanelManager:CheckShow(gPanelId.S_NEW_MAP_PANEL, param)
	end
end

function M:CloseBigMap()
	gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
end

function M:PlayerOpenBigMap(param)
	if gDriveVehiclesManager.isTaxiMode then
		gTaxiManager:ChangeDestination()

		return
	end

	if gMapSystem:Tmp_CanPlayerOpenMap(true) then
		gPanelManager:CheckShow(gPanelId.S_NEW_MAP_PANEL, param)
	end
end

function M:UXLinkModeEnum2ConfigEnum(uxEnum)
	if uxEnum == UX.Game.LinkMode.None then
		return gMapUtils.LinkModeType.None
	elseif uxEnum == UX.Game.LinkMode.Public then
		return gMapUtils.LinkModeType.Public
	elseif uxEnum == UX.Game.LinkMode.Match then
		return gMapUtils.LinkModeType.Match
	elseif uxEnum == UX.Game.LinkMode.Private then
		return gMapUtils.LinkModeType.Private
	end

	print_error("gMapUtils:UXLinkModeEnum2ConfigEnum error, uxEnum = " .. tostring(uxEnum))

	return gMapUtils.LinkModeType.None
end

function M:IsViewItemAttachingAirPort(instanceId, view, currentAreaId)
	local item = view:GetItemInfo(instanceId)

	if item.coordType == EMapViewerItemCoordType.AttachGate then
		local nextRaidId = gMapAreaMgr:SplitGBoundId(item.attachedGBoundId)
		local curRaidId = gMapAreaMgr:SplitGBoundId(currentAreaId)

		if nextRaidId ~= curRaidId and gMapAreaMgr:IsBigWorldRaidId(curRaidId) and gMapAreaMgr:IsBigWorldRaidId(nextRaidId) then
			return true
		end
	end

	return false
end

function M:CloseMiniMap()
	gMapSystem.ui:CloseMiniMap()
end

function M:ShowMiniMap()
	gMapSystem.ui:ShowMiniMap()
end

function M:DoAcceptTask(taskId, successCb, failCb)
	gClientToGameDelegate:AskAcceptTask(taskId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			if failCb then
				failCb(err, taskId)
			end

			return
		end

		if successCb then
			successCb()
		end
	end
end

function M:DoGiveUpTask(taskId, successCb, failCb)
	gClientToGameDelegate:AskDeleteTask(taskId, false).Callback = function (err)
		if err ~= MessageConfig.Ok then
			if failCb then
				failCb(err, taskId)
			end

			return
		end

		if successCb then
			successCb()
		end
	end
end

gMapUtils = M
