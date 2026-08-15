require("LX6/Manager/Map/Utils/GpsTools")
require("LX6/Manager/Map/Utils/MapCsApi")
require("LX6/Manager/Map/Utils/MapGpsCmd")
require("LX6/Manager/Map/MapSystem_Constant")
require("LX6/Manager/Map/MapUIUtils")
require("LX6/Manager/Map/MapTransformHelper")
require("LX6/Manager/Map/MapSubSystem/MapSubSystemBase")
require("LX6/Manager/Map/MapElement")
require("LX6/Manager/Map/MapArea")
require("LX6/Manager/Map/GpsBound")
require("LX6/Manager/Map/MapViewMask")
require("LX6/Manager/Map/MapSubSystem/MapSubSystemUtils")
require("LX6/Manager/Map/MapAreaMgr")
require("LX6/Manager/Map/BaseMapMgr")
require("LX6/Manager/Map/BlockMgr")
require("LX6/Manager/Map/MapAreaCluster")
require("LX6/Manager/Map/MapView")
require("LX6/Manager/Map/GpsLText")
require("LX6/Manager/Map/ElementFilterId")
require("LX6/Manager/Map/MapSubSystem/Gps/GpsHelper")
require("LX6/Manager/Map/MapSubSystem/Gps/GpsWaitingEventHolder")
require("LX6/Manager/Map/MapSubSystem/MapSubSystemActionHelper")
require("LX6/Manager/Map/Utils/BigMapHelper")
require("LX6/Manager/Map/GpsBindingMgr")

local RaidConfig = LTConfig.RaidConfig
local IndoorConfig = LTConfig.IndoorConfig
local SceneConfig = LTConfig.SceneConfig
local gGpsTools = gGpsTools
gMapSystem = gMapSystem or {}
local M = gMapSystem

function M:OnInit()
	gGpsTools.PCallMethod(self.RealOnInit, self)
end

function M:RealOnInit()
	self:InitSwap()
	self:InitDebug()
	self:InitSwitch()

	self.isPV = false
	self.DefaultGpsSceneEffect = {
		effectId = 53610322,
		showDistance = LTConfig.GameConfig.TraceLightDisappearRange
	}

	gBigMapHelper:Init()
	gGpsBindingMgr:Init()
	self:InitPlayerAreaInfo()

	self.env = self
	self.modules = {}
	self.dataUtils = require("LX6/Manager/Map/MapSystem_DataUtils")
	self.fogMap = require("LX6/Manager/Map/MapSystem_FogMap")
	self.area = gMapSystem_Area
	self.container = require("LX6/Manager/Map/MapSystem_Container")
	self.ui = require("LX6/Manager/Map/MapSystem_UI")
	self.navigation = require("LX6/Manager/Map/MapSystem_Navigation")
	self.region = require("LX6/Manager/Map/MapSystem_Region")
	self.trace = require("LX6/Manager/Map/MapSystem_Trace")
	self.taskUtils = require("LX6/Manager/Map/MapSystem_TaskUtils")
	self.poi = require("LX6/Manager/Map/MapSystem_Poi")
	self.modules = {
		self.dataUtils,
		self.fogMap,
		self.area,
		self.container,
		self.ui,
		self.navigation,
		self.region,
		self.trace,
		self.taskUtils,
		self.poi
	}

	for _, module in ipairs(self.modules) do
		module.env = self

		if module.Init then
			gGpsTools.PCallMethod(module.Init, module)
		end
	end

	self._tickTable = {}

	gBlockMgr:Init()
	self:InitSubSystem()
	gBaseMapMgr:Init()

	self._ActiveSpoonUnitTrigger = {}

	self:InitEventHandler()

	self.inited = true
end

function M:InitSwitch()
	self.switches = {}
end

function M:CheckSwitch(switchType)
	return self.switches[switchType]
end

function M:SetSwitch(switchType, value)
	if value then
		self.switches[switchType] = true
	else
		self.switches[switchType] = nil
	end
end

function M:SGetTooltipInfo(id)
	local element = self.container:Get(id)

	if not element then
		return nil
	end

	if element.bigMapData.overrideTooltipInfo then
		local override = element.bigMapData.overrideTooltipInfo
		local tooltipInfo = {
			type = override.tooltipType
		}
		local specificInfo = {}
		tooltipInfo[override.infoName] = specificInfo

		for fieldName, fieldValue in pairs(override.fieldDatas) do
			specificInfo[fieldName] = fieldValue
		end

		return tooltipInfo
	end

	local subSystem = element:GetSubSystem()

	if subSystem then
		return subSystem:SGetTooltipInfo(element.id, element)
	else
		return nil
	end
end

function M:SetDevUserName(devUserName)
	gGpsTools.SetDevUserName(devUserName)
end

function M:GetPlayerRaidIdAndIndoorId()
	return self.lastRaidId, self.lastIndoorId
end

function M:InitSwap()
	self._swapTable = {}
	self._swapArray = {}
end

function M:InitPlayerAreaInfo()
	self.lastRaidId = 0
	self.lastIndoorId = 0
	self.lastAreaId = 0
	self.lastGBoundId = 0
	self.lastPosition = Vector3.zero
end

function M:GetPlayerAreaId()
	return gMapAreaMgr:GetAreaId(self.lastRaidId, self.lastIndoorId)
end

function M:SyncPlayerIndoorInfo(gBoundId)
	local raidId, indoorId, boundId = gMapSystem.area:SplitGBoundId(gBoundId)

	gClientToGameDelegate:SyncChangeIndoor(indoorId, boundId)
end

function M:OnViewBoundInfoChanged(gBoundId)
	local raidId, indoorId, boundId = gMapSystem.area:SplitGBoundId(gBoundId)
	self.lastGBoundId = gBoundId
	self.lastAreaId = gMapAreaMgr:GetAreaId(raidId, indoorId)
	self.lastRaidId = raidId
	self.lastIndoorId = indoorId

	if indoorId and indoorId ~= 0 then
		local cfg = IndoorConfig.GetConfig(indoorId)

		if cfg and cfg.MiniMapScale > 0 then
			gMapManager:SetMiniMapScale(cfg.MiniMapScale, gMapScaleType.Indoor)
		elseif cfg and cfg.SMapName and cfg.SMapName ~= 0 then
			print_error("IndoorConfig=" .. indoorId .. ", 没有配置MiniMapScale")
		end
	else
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.Indoor)

		local scale = 1
		local raidCfg = RaidConfig.GetConfig(raidId)
		local sceneCfg = raidCfg and SceneConfig.GetConfig(raidCfg.SceneId)

		if sceneCfg and sceneCfg.MiniMapScale and sceneCfg.MiniMapScale > 0 then
			scale = sceneCfg.MiniMapScale
		end

		gMapManager:SetMiniMapScale(scale, gMapScaleType.Default)
	end

	gMapManager:ChangeMapId(indoorId)
	gMessageManager:SendMessage(gEventConstants.MAP_CHANGE_TO_INDOOR_MAP_EARLY)
end

function M:SyncCoordInfo(x, y, z)
	self.lastPosition.x = x
	self.lastPosition.y = y
	self.lastPosition.z = z
end

function M:OnEnterScene(enterInfo)
	return
end

function M:SetHudGpsEnabled(id, enabled)
	self.ui:SetHudGpsHideReason(id, not enabled)
end

function M:CallWithProfiler(profilerName, func, target, ...)
	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample(profilerName)
	end

	func(target or self, ...)

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:TickSubSystem()
	local fdt = Time.fixedDeltaTime

	for _, entry in ipairs(self.tickEntries) do
		local subSystem = self.subSystems[entry.systemType]

		if subSystem then
			local canTick = true

			if entry.interval > 0 then
				entry.tickTimer = entry.tickTimer + fdt

				if entry.interval <= entry.tickTimer then
					entry.tickTimer = 0
				else
					canTick = false
				end
			end

			if canTick then
				if gGameManager.Env.IsENABLE_PROFILER then
					gCS.LuaUtils.BeginSample(entry.profilerKey)
					subSystem:Tick()
					gCS.LuaUtils.EndSample()
				else
					subSystem:Tick()
				end
			end
		end
	end
end

function M:FlushSubSystems()
	for _, subSystem in pairs(self.subSystems) do
		if subSystem._needFlushData then
			if gGameManager.Env.IsENABLE_PROFILER then
				gCS.LuaUtils.BeginSample(subSystem._flushProfilerKey)
			end

			subSystem._needFlushData = false
			local ok, res = xpcall(subSystem.OnFlushData, tolua.traceback, subSystem)

			if not ok then
				local flushReason = "["

				for _, reason in ipairs(subSystem._flushReasons) do
					flushReason = flushReason .. reason .. ", "
				end

				flushReason = flushReason .. "]"

				print_error("MapSubSystem OnFlushData 报错: " .. subSystem._name .. ", FlushData来源: " .. flushReason, res)
			elseif res == EMapSystemFlushResult.Fail then
				subSystem._needFlushData = true
			end

			array.clear(subSystem._flushReasons)

			if gGameManager.Env.IsENABLE_PROFILER then
				gCS.LuaUtils.EndSample()
			end
		end
	end
end

function M:SyncPlayerInfo(playerInfo)
	if not self._logined then
		self._cachedPlayerInfo = playerInfo
	else
		gGpsTools.PCallMethod(self.OnSyncPlayerInfo, self, playerInfo)
	end
end

function M:FlushAll(reason)
	for _, subSystem in pairs(self.subSystems) do
		subSystem:FlushData(reason)
	end
end

function M:AddSpoonUnitIndoorTrigger(spoonId)
	if not self._ActiveSpoonUnitTrigger[spoonId] then
		self._ActiveSpoonUnitTrigger[spoonId] = 0
	end
end

function M:TickSpoonUnitTrigger()
	for spoonId, oldIndoorId in pairs(self._ActiveSpoonUnitTrigger) do
		local position = Vector3.zero

		GpsHelper.GetUnitGpsPosition(spoonId, position)

		if not gUtils:IsPositionZero(position) then
			local success, newIndoorId, localBoundId = LX6.Gps.AreaMgr.LuaTryGetBoundInfo(self.lastRaidId, position, nil, nil)

			if newIndoorId ~= oldIndoorId then
				self._ActiveSpoonUnitTrigger[spoonId] = newIndoorId

				gMessageManager:SendMessage(gEventConstants.AGENT_ENTER_INDOOR, {
					spoonId = spoonId,
					toIndoorId = newIndoorId,
					fromIndoorId = oldIndoorId
				})
			end
		end
	end
end

function M:Tmp_CanOpenBigMap(raidId, indoorId)
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.BigMapUnlock) then
		return false
	end

	local cfg = RaidConfig.GetConfig(raidId)

	if not cfg then
		print_error("RaidConfig表中找不到raidId=" .. raidId .. "的数据")

		return false
	else
		local canOpen = nil

		if indoorId == 0 and (raidId == RaidConfig.WorldMap or raidId == RaidConfig.Chongxiao) then
			canOpen = true
		else
			local mapCfg = nil

			if indoorId ~= 0 then
				mapCfg = IndoorConfig.GetConfig(indoorId)
			else
				mapCfg = SceneConfig.GetConfig(cfg.SceneId)
			end

			local raidTypeCfg = LTConfig.RaidRaidTypeConfig.GetConfig(cfg.RaidType)
			canOpen = raidTypeCfg and raidTypeCfg.CanOpenMap and mapCfg and mapCfg.SMapName and mapCfg.SMapName > 0
		end

		return canOpen
	end
end

function M:Tmp_CanPlayerOpenMap(needMessage)
	if gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene or gPanelManager:IsPanelShowing(gPanelId.PVP_LOADING_PANEL) then
		return false
	end

	if gMapSubSystem_Crime:InCrimeState() then
		if needMessage then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CanNotOpenMap)
		end

		return false
	end

	if gDriveVehiclesManager.isTaxiMode then
		return false
	end

	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.TranslucentMapButton) then
		return false
	end

	if gPlayerManager.main.bindData.isInFeisuo or gPlayerManager.main.bindData.isSwing then
		return false
	end

	return self:Tmp_CanOpenBigMap(gMapSystem.lastRaidId, gMapSystem.lastIndoorId)
end

function M:GetCurBlockId()
	if L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return nil
	end

	local myPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

	return LX6.Gps.MapBlockMgr.GetBlockIdXZ(self.lastRaidId, myPos.x, myPos.z)
end

function M:GetCurCountryId()
	return LTConfig.CollectionCountryConfig.XinQi
end

local _tempPos = Vector3.zero

function M:GetGeographInfoByInstanceId(instanceId)
	if not instanceId then
		return nil
	end

	local element = self.container:Get(instanceId)

	if not element or not element:IsVisible() then
		return nil
	end

	local worldPos = element:GetOriginWorldPos(_tempPos)
	local raidId = element.raidId
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(raidId, worldPos.x, worldPos.z)
	local distance = nil
	local hudView = self.container.views.HudGps

	if hudView then
		local viewItem = hudView:GetItemInfo(instanceId)

		if viewItem and viewItem.coordType ~= EMapViewerItemCoordType.Unreachable then
			worldPos = viewItem.resolvedWorldPos
		end
	end

	local playerPosition = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	distance = Vector3.Distance(worldPos, playerPosition)

	return LTConfig.CollectionCountryConfig.XinQi, blockId, distance
end

function M:IsPlayerInRange(element)
	if element.areaId ~= self.lastAreaId or not element.mData.rangeInfo or element.mData.rangeInfo.tmp_type then
		return false
	end

	local playerWorldPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local worldPos = element:GetWorldPos()
	local dx = worldPos.x - playerWorldPos.x
	local dz = worldPos.z - playerWorldPos.z
	local sqrXZDist = dx * dx + dz * dz
	local sqrRange = element.mData.rangeInfo.radius * element.mData.rangeInfo.radius

	return sqrXZDist <= sqrRange
end

function M:GetByInstanceId(instanceId)
	return self.container:Get(instanceId)
end

function M:GetByGpsId(gpsId)
	return self.container:GetByGpsId(gpsId)
end

function M:GetInstanceIdByGpsId(gpsId)
	return self.container:GetInstanceIdByGpsId(gpsId)
end

require("LX6/Manager/Map/MapSystem_LifeCycle")
require("LX6/Manager/Map/MapSystem_Debug")
require("LX6/Manager/Map/MapSystem_Trace")
