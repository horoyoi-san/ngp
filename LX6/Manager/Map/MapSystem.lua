-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem.lua
-- Decompiled from: 00179_MapSystem.lua_f6fa2d65ce51.luajit

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

M.OnInit = function(self)
	gGpsTools.PCallMethod(self.RealOnInit, self)
end

M.RealOnInit = function(self)
	self:InitSwap()
	self:InitDebug()
	self:InitSwitch()

	self.isPV = false
	self.DefaultGpsSceneEffect = {
		["\\xae\\xb7\\xaei*\\xd77"] = 53610322,
		showDistance = LTConfig.GameConfig.TraceLightDisappearRange
	}

	gBigMapHelper:Init()
	gGpsBindingMgr:Init()
	self:InitPlayerAreaInfo()

	self.env = self
	self.modules = {}
	self.dataUtils = require("LX6/Manager/Map/MapSystem_DataUtils")
	self.redDot = require("LX6/Manager/Map/MapSystem_RedDot")
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
		self.redDot,
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
	self:UpdateCurPlayerUnit()

	self.inited = true
end

M.InitSwitch = function(self)
	self.switches = {}
end

M.CheckSwitch = function(self, switchType)
	return self.switches[switchType]
end

M.SetSwitch = function(self, switchType, value)
	if value then
		self.switches[switchType] = true
	else
		self.switches[switchType] = nil
	end
end

M.SGetTooltipInfo = function(self, id)
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

M.SetDevUserName = function(self, devUserName)
	gGpsTools.SetDevUserName(devUserName)
end

M.GetPlayerRaidIdAndIndoorId = function(self)
	return self.lastRaidId, self.lastIndoorId
end

M.InitSwap = function(self)
	self._swapTable = {}
	self._swapArray = {}
end

M.InitPlayerAreaInfo = function(self)
	self.lastRaidId = 0
	self.lastIndoorId = 0
	self.lastAreaId = 0
	self.lastGBoundId = 0
	self.lastPosition = Vector3.zero
end

M.GetPlayerAreaId = function(self)
	return gMapAreaMgr:GetAreaId(self.lastRaidId, self.lastIndoorId)
end

M.OnViewBoundInfoChanged = function(self, gBoundId)
	local raidId, indoorId, boundId = gMapSystem.area:SplitGBoundId(gBoundId)
	self.lastGBoundId = gBoundId
	self.lastAreaId = gMapAreaMgr:GetAreaId(raidId, indoorId)
	self.lastRaidId = raidId
	self.lastIndoorId = indoorId

	if indoorId and indoorId == 0 then
		local cfg = IndoorConfig.GetConfig(indoorId)

		if cfg and cfg.MiniMapScale <= 0 then
			gMapManager:SetMiniMapScale(cfg.MiniMapScale, gMapScaleType.Indoor)
		elseif cfg and cfg.SMapName and cfg.SMapName == 0 then
			print_error("IndoorConfig=" .. indoorId .. ", 没有配置MiniMapScale")
		end
	else
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.Indoor)

		local scale = 1
		local raidCfg = RaidConfig.GetConfig(raidId)
		local sceneCfg = raidCfg and SceneConfig.GetConfig(raidCfg.SceneId)

		if sceneCfg and sceneCfg.MiniMapScale and sceneCfg.MiniMapScale <= 0 then
			scale = sceneCfg.MiniMapScale
		end

		gMapManager:SetMiniMapScale(scale, gMapScaleType.Default)
	end

	gMapManager:ChangeMapId(indoorId)
	gMessageManager:SendMessage(gEventConstants.MAP_CHANGE_TO_INDOOR_MAP_EARLY)
end

M.SyncCoordInfo = function(self, x, y, z)
	self.lastPosition.x = x
	self.lastPosition.y = y
	self.lastPosition.z = z
end

M.OnEnterScene = function(self, enterInfo)
end

M.SetHudGpsEnabled = function(self, id, enabled)
	self.ui:SetHudGpsHideReason(id, not enabled)
end

M.CallWithProfiler = function(self, profilerName, func, target, ...)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample(profilerName)
	end

	func(target or self, ...)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.TickSubSystem = function(self)
	local fdt = Time.fixedDeltaTime

	for _, entry in ipairs(self.tickEntries) do
		local subSystem = self.subSystems[entry.systemType]

		if subSystem then
			local canTick = true

			if entry.interval <= 0 then
				entry.tickTimer = entry.tickTimer + fdt

				if entry.interval < entry.tickTimer then
					entry.tickTimer = 0
				else
					canTick = false
				end
			end

			if canTick then
				if gGameManager.Env.IsENABLE_PROFILER then
					gGameManager:BeginSample(entry.profilerKey)
					subSystem:Tick()
					gGameManager:EndSample()
				else
					subSystem:Tick()
				end
			end
		end
	end
end

M.FlushSubSystems = function(self)
	for _, subSystem in pairs(self.subSystems) do
		if subSystem._needFlushData then
			if gGameManager.Env.IsENABLE_PROFILER then
				gGameManager:BeginSample(subSystem._flushProfilerKey)
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
			elseif res ~= EMapSystemFlushResult.Fail then
				subSystem._needFlushData = true
			end

			array.clear(subSystem._flushReasons)

			if gGameManager.Env.IsENABLE_PROFILER then
				gGameManager:EndSample()
			end
		end
	end
end

M.SyncPlayerInfo = function(self, playerInfo)
	if not self._logined then
		self._cachedPlayerInfo = playerInfo
	else
		gGpsTools.PCallMethod(self.OnSyncPlayerInfo, self, playerInfo)
	end
end

M.FlushAll = function(self, reason)
	for _, subSystem in pairs(self.subSystems) do
		subSystem:FlushData(reason)
	end
end

M.AddSpoonUnitIndoorTrigger = function(self, spoonId)
	if not self._ActiveSpoonUnitTrigger[spoonId] then
		self._ActiveSpoonUnitTrigger[spoonId] = 0
	end
end

M.TickSpoonUnitTrigger = function(self)
	for spoonId, oldIndoorId in pairs(self._ActiveSpoonUnitTrigger) do
		local position = Vector3.zero

		GpsHelper.GetUnitGpsPosition(spoonId, position)

		if not gUtils:IsPositionZero(position) then
			local success, newIndoorId, localBoundId = LX6.Gps.AreaMgr.LuaTryGetBoundInfo(self.lastRaidId, position, nil, )

			if newIndoorId == oldIndoorId then
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

M.Tmp_CanOpenBigMap = function(self, raidId, indoorId, dontLog)
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.BigMapUnlock) then
		return false, "BigMap Locked"
	end

	local cfg = RaidConfig.GetConfig(raidId)

	if not cfg then
		if not dontLog then
			print_error("RaidConfig表中找不到raidId=" .. raidId .. "的数据")
		end

		return false, "RaidId Invalid: " .. raidId
	else
		local canOpen = nil

		if indoorId ~= 0 and array.contains(LTConfig.GpsConfig.RaidIdsUsingPrefabMap, raidId) then
			canOpen = true
		else
			local mapCfg = nil

			if indoorId == 0 then
				mapCfg = IndoorConfig.GetConfig(indoorId)
			else
				mapCfg = SceneConfig.GetConfig(cfg.SceneId)
			end

			local raidTypeCfg = LTConfig.RaidRaidTypeConfig.GetConfig(cfg.RaidType)
			canOpen = raidTypeCfg and raidTypeCfg.CanOpenMap and mapCfg and mapCfg.SMapName and mapCfg.SMapName >= 0
		end

		return canOpen
	end
end

M.Tmp_CanPlayerOpenMap = function(self, needMessage, dontLog)
	if gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene or gPanelManager:IsPanelShowing(gPanelId.PVP_LOADING_PANEL) then
		return false, "Loading"
	end

	if gMapSubSystem_Crime:InCrimeState() then
		if needMessage then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CanNotOpenMap)
		end

		return false, "Crime State"
	end

	if gDriveVehiclesManager.isTaxiMode then
		return false, "Taxi Mode"
	end

	if gCS.UnitStateMgr:HasState(self.curPlayerUnit, LTConfig.UnitStateConfig.TranslucentMapButton) then
		return false, "State TranslucentMapButton"
	end

	if gPlayerManager.main.bindData.isInFeisuo or gPlayerManager.main.bindData.isSwing then
		if needMessage then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CanNotOpenMapInFeisuoOrSwing)
		end

		return false, "Feisuo Or Swing"
	end

	return self:Tmp_CanOpenBigMap(gMapSystem.lastRaidId, gMapSystem.lastIndoorId, dontLog)
end

M.CanShowMainPageTabPanel = function(self)
	if self.notShowMainPageTabPanel then
		return false
	end

	return self:Tmp_CanPlayerOpenMap(false, true)
end

M.GetCurBlockId = function(self)
	if gGpsTools:UnitIsNull(self.curPlayerUnit) then
		return nil
	end

	local myPos = self:GetCurPlayerLocalPosition()

	return LX6.Gps.MapBlockMgr.GetBlockIdXZ(self.lastRaidId, myPos.x, myPos.z)
end

M.GetCurCountryId = function(self)
	local raidId = gMapManager:GetParentRaidId(self.lastRaidId)

	return LTConfig.RaidConfig.GetConfig(raidId).CountryId or LTConfig.CollectionCountryConfig.XinQi
end

local _tempPos = Vector3.zero
local _zeroLocalPos = Vector3.zero
local _zeroUXPos = UX.Game.UXVector3.New(0, 0, 0)

M.GetGeographInfoByInstanceId = function(self, instanceId)
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

		if viewItem and viewItem.coordType == EMapViewerItemCoordType.Unreachable then
			worldPos = viewItem.resolvedWorldPos
		end
	end

	local playerPosition = self:GetCurPlayerLocalPosition()
	distance = Vector3.Distance(worldPos, playerPosition)
	local blockCfg = LTConfig.CollectionBlockConfig.GetConfig(blockId)
	local countryId = blockCfg and blockCfg.CountryId or LTConfig.CollectionCountryConfig.XinQi

	return countryId, blockId, distance
end

local isPointInGpsCustomAreaAabbXZ = function(position, area)
	local bounds = area._gpsAabbXZ

	if bounds then
		return bounds.minX < position.x and position.x < bounds.maxX and bounds.minZ < position.z and position.z > bounds.maxZ
	end

	local points = area.points

	if not points or #points >= 3 then
		return false
	end

	local firstPoint = points[1]
	local minX = firstPoint.x
	local maxX = firstPoint.x
	local minZ = firstPoint.z
	local maxZ = firstPoint.z

	for index = 2, #points do
		local point = points[index]

		if point.x >= minX then
			minX = point.x
		elseif maxX >= point.x then
			maxX = point.x
		end

		if point.z >= minZ then
			minZ = point.z
		elseif maxZ >= point.z then
			maxZ = point.z
		end
	end

	bounds = {
		minX = minX,
		maxX = maxX,
		minZ = minZ,
		maxZ = maxZ
	}
	area._gpsAabbXZ = bounds

	return minX < position.x and position.x < maxX and minZ < position.z and position.z > maxZ
end

local isPlayerInGpsCustomAreaRange = function(mapSystem, gpsCustomAreaRangeInfo)
	local playerWorldPos = mapSystem:GetCurPlayerLocalPosition()
	local areas = gpsCustomAreaRangeInfo.areas

	if not areas then
		return false
	end

	for index = 1, #areas do
		if isPointInGpsCustomAreaAabbXZ(playerWorldPos, areas[index]) then
			return true
		end
	end

	return false
end

M.IsPlayerInRange = function(self, element)
	if element.areaId == self.lastAreaId then
		return false
	end

	local gpsCustomAreaRangeInfo = element.mData.gpsCustomAreaRangeInfo

	if gpsCustomAreaRangeInfo then
		return isPlayerInGpsCustomAreaRange(self, gpsCustomAreaRangeInfo)
	end

	local rangeInfo = element.mData.rangeInfo

	if not rangeInfo or rangeInfo.rangeType then
		return false
	end

	local playerWorldPos = self:GetCurPlayerLocalPosition()
	local worldPos = element:GetWorldPos()
	local dx = worldPos.x - playerWorldPos.x
	local dz = worldPos.z - playerWorldPos.z
	local sqrXZDist = dx * dx + dz * dz
	local sqrRange = rangeInfo.radius * rangeInfo.radius

	return sqrXZDist > sqrRange
end

M.GetByInstanceId = function(self, instanceId)
	return self.container:Get(instanceId)
end

M.GetByGpsId = function(self, gpsId)
	return self.container:GetByGpsId(gpsId)
end

M.GetInstanceIdByGpsId = function(self, gpsId)
	return self.container:GetInstanceIdByGpsId(gpsId)
end

M.SetRaceNavLineInfo = function(self, pathLists)
	self.navigation:SetRaceNavLineInfo(pathLists)
end

M.ClearRaceNavLineInfo = function(self)
	self.navigation:ClearRaceNavLineInfo()
end

M.OnLoadRaceNavLineInfoComplete = function(self, id, pathLists)
	self.navigation:OnLoadBigMapRaceNavLineInfoComplete(id, pathLists)
end

M.SetLinkTag = function(self, linkTag)
	if self.lastLinkTag ~= UX.Game.LinkTag.PublicEvent or linkTag ~= UX.Game.LinkTag.PublicEvent then
		self.lastLinkTag = linkTag

		gMapSubSystem_PublicEvent:FlushData()
	else
		self.lastLinkTag = linkTag
	end

	gMessageManager:SendMessage(gEventConstants.ON_LINK_TAG_CHANGE, linkTag)
end

M.GetCurLinkTag = function(self)
	return self.lastLinkTag or UX.Game.LinkTag.Normal
end

M.UpdateCurPlayerUnit = function(self)
	self.curVehicle = gCS.DriveManager.TargetVehicle or nil
	self.curPlayerUnit = not gGpsTools:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) and gCS.MyPlayerManager.PlayerUnit or nil
end

M.GetCurPlayerPosition = function(self)
	if self.curVehicle then
		return self.curVehicle.UXPosition
	end

	if not gGpsTools:UnitIsNull(self.curPlayerUnit) then
		return self.curPlayerUnit.Position
	end

	return _zeroUXPos
end

M.GetCurPlayerLocalPosition = function(self)
	if self.curVehicle then
		return self.curVehicle.Position
	end

	if not gGpsTools:UnitIsNull(self.curPlayerUnit) then
		return self.curPlayerUnit.LocalPosition
	end

	return _zeroLocalPos
end

M.GetCurPlayerEulerY = function(self)
	if self.curVehicle then
		return self.curVehicle.EulerY
	end

	if not gGpsTools:UnitIsNull(self.curPlayerUnit) then
		return self.curPlayerUnit.EulerY
	end

	return 0
end

M.GetCurVehicleEulerYNoSync = function(self)
	if self.curVehicle and self.curVehicle.gameObject then
		return self.curVehicle.gameObject.transform:GetEulerAnglesNoSync()
	end

	return 0
end

M.ChangeCurCampId = function(self, campId)
	self.curCampId = campId
end

require("LX6/Manager/Map/MapSystem_LifeCycle")
require("LX6/Manager/Map/MapSystem_Debug")
require("LX6/Manager/Map/MapSystem_Trace")
