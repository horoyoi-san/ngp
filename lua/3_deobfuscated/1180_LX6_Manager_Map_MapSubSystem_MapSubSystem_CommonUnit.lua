MapSubSystem_CommonUnit = DefClass("MapSubSystem_CommonUnit", MapSubSystem_CommonUnit, MapSubSystemBase)
local M = MapSubSystem_CommonUnit
local StealthConfig = LTConfig.AgentDetectConfig

function M:OnInit()
	self.unitInfo = {}
	self._blacklistDict = {}
	self._blackListIdCounter = 1
	self._invisiblePids = {}
	self._invisiblePidsDirty = false
	self._spoonBlacklistDict = {}
	self._invisibleSpoonPids = {}
	self._fetchTimer = 0
	self._policeRangeColor = Color.New(0, 0, 1, 0.5)

	self:InitEventHandlers()

	self._enemyVehicleMap = {}
	self._stealthEnemyDetectInfo = {}
	self._serverHostileUnits = {}
end

function M:InitEventHandlers()
	self.eventHandlers = {
		[gEventConstants.MINIMAP_CRIME_STATUS_UPDATE] = function (eventId, params)
			local crimeLevel = params.crimeLevel

			if crimeLevel then
				self:OnCrimeLevelChange(crimeLevel)
			end
		end,
		[gEventConstants.CRIME_ESCAPE_STATUS_CHANGE] = function (eventId, params)
			local isEscape = params

			self:OnCrimeEscapeStatusChange(isEscape)
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:Tick()
	local dt = Time.deltaTime
	local needFlush = false

	if self._fetchTimer < dt then
		self._fetchTimer = 1 - dt + self._fetchTimer
		needFlush = true
	else
		self._fetchTimer = self._fetchTimer - dt
	end

	if needFlush then
		self:FlushData()
	else
		self:TickVehicleBind()
	end
end

function M:TickVehicleBind()
	local vehicleMap = gGpsTools.GetTable()

	for i, unitInfo in pairs(self.unitInfo) do
		if unitInfo.csUnit and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(unitInfo.csUnit) then
			local hasVehicle, vehicleId = unitInfo.csUnit:IsBindOnVehicle(nil, nil)

			unitInfo.mapElement:SetVisible(not hasVehicle)

			if hasVehicle then
				vehicleMap[vehicleId] = true
			end
		end
	end

	for vehicleId, element in pairs(self._enemyVehicleMap) do
		if not vehicleMap[vehicleId] then
			element:Dispose()

			self._enemyVehicleMap[vehicleId] = nil
		end
	end

	for vehicleId in pairs(vehicleMap) do
		if not self._enemyVehicleMap[vehicleId] then
			local element = MapElement.CreateLegacy(EMapElementType.Enemy, vehicleId, EMapSubSystemType.CommonUnit, EMapViewMask.MiniMap, gRaidDataManager.RaidId)
			self._enemyVehicleMap[vehicleId] = element
			element.mData.sIconId = LTConfig.GpsConfig.EnemyVehiclleMiniMapIcon

			element:BindVehicle(vehicleId)
			element:SetVisible(true)
		end
	end

	gGpsTools.ReleaseTable(vehicleMap)
end

function M:OnFlushData()
	if not L50.L50App.Scene.GamePlayUtils or L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return EMapSystemFlushResult.Fail
	end

	local myCamp = gCS.MyPlayerManager.PlayerUnit.ClientData.Camp

	if self._invisiblePidsDirty then
		self:ResolveBlacklist()

		self._invisiblePidsDirty = false
	end

	self:ResolveSpoonUnitsBlacklist()

	if self._pidCache then
		table.clear(self._pidCache)
	else
		self._pidCache = {}
	end

	if self._typeCache then
		table.clear(self._typeCache)
	else
		self._typeCache = {}
	end

	local validUnits = self._pidCache
	local typeCache = self._typeCache
	local allUnits = {}

	LX6.Gps.MapSystem.Instance:LuaGetAllUnits(allUnits)

	for _, csUnit in ipairs(allUnits) do
		if csUnit then
			if csUnit.IsDead then
				-- Nothing
			else
				local pid = csUnit.Pid
				local type = EMapElementType.Enemy

				if self._serverHostileUnits[pid] then
					validUnits[pid] = csUnit
					typeCache[pid] = type
				elseif not self._invisiblePids[pid] and not self._invisibleSpoonPids[pid] or gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.CommonUnitIgnoreMask) then
					if gCS.UnitStateMgr:HasState(csUnit, LTConfig.UnitStateConfig.InvisibleS) then
						-- Nothing
					else
						local agentCfgId = csUnit.ClientData.SubType
						local agentCfg = LTConfig.AgentConfig.GetConfig(agentCfgId)

						if not agentCfg then
							-- Nothing
						elseif csUnit.IsBattleAiS and agentCfg.EnemyClassType ~= 6 and agentCfg.EnemyClassType ~= 1 then
							-- Nothing
						elseif not LX6.Gps.MapSystem.Instance:IsEnemyUnit(csUnit) then
							-- Nothing
						else
							validUnits[pid] = csUnit
							typeCache[pid] = type
						end
					end
				end
			end
		end
	end

	for pid, info in pairs(self.unitInfo) do
		if not validUnits[pid] then
			info.mapElement:Dispose()

			self.unitInfo[pid] = nil
		end
	end

	local policeRadius = 0

	if self.isEscape then
		local crimeLevel = gPlayerManager.infoOther.bindData.CrimeLevel

		if crimeLevel and crimeLevel > 0 then
			policeRadius = LTConfig.WantedConfig.GetConfig(crimeLevel).InductionRadius[1]
		end
	end

	for pid, csUnit in pairs(validUnits) do
		local elementType = typeCache[pid] or EMapElementType.Enemy

		if not self.unitInfo[pid] then
			local info = {}
			self.unitInfo[pid] = info
			local element = MapElement.CreateLegacy(elementType, pid, EMapSubSystemType.CommonUnit, EMapViewMask.MiniMap, gRaidDataManager.RaidId, 0)
			info.mapElement = element
			info.csUnit = csUnit
			element.mData.name = "CommonUnit" .. ulong.tostring(pid)
			element.mData.sIconId = self:GetIconId(elementType)

			element:BindUnit(pid)

			if element.type == EMapElementType.Enemy or element.type == EMapElementType.Police and self.isCrime then
				element:SetVisible(true)
			else
				element:SetVisible(false)
			end

			self:AddEnemyDetectRange(pid, self._stealthEnemyDetectInfo[pid])

			if info.mapElement.type == EMapElementType.Police then
				if self.isEscape and info.mapElement.mData.rangeInfo == nil then
					info.mapElement.mData.rangeInfo = {
						tmp_type = 1,
						hideIcon = false,
						color = self._policeRangeColor,
						radius = policeRadius
					}
				else
					info.mapElement.mData.rangeInfo = nil
				end
			end
		end
	end
end

function M:AddBlacklist(blacklist)
	local bId = self._blackListIdCounter
	self._blackListIdCounter = self._blackListIdCounter + 1
	local cachedBlacklist = {}

	for _, pid in ipairs(blacklist) do
		cachedBlacklist[#cachedBlacklist + 1] = pid
	end

	self._blacklistDict[bId] = cachedBlacklist
	self._invisiblePidsDirty = true

	return bId
end

function M:RemoveBlacklist(bId)
	self._blacklistDict[bId] = nil
	self._invisiblePidsDirty = true
end

function M:ResolveBlacklist()
	table.clear(self._invisiblePids)

	for _, blacklist in pairs(self._blacklistDict) do
		for _, pid in ipairs(blacklist) do
			self._invisiblePids[pid] = true
		end
	end
end

function M:OnCrimeLevelChange(crimeLevel)
	if crimeLevel == 0 then
		self.isCrime = false
		self.isEscape = false

		self:OnCrimeEscapeStatusChange(false)
	else
		self.isCrime = true
	end

	for _, info in pairs(self.unitInfo) do
		if info.mapElement.type == EMapElementType.Police then
			info.mapElement:SetVisible(self.isCrime)
		end
	end
end

function M:OnCrimeEscapeStatusChange(isEscape)
	self.isEscape = isEscape
	local radius = 0

	if isEscape then
		local crimeLevel = gPlayerManager.infoOther.bindData.CrimeLevel

		if crimeLevel and crimeLevel > 0 then
			radius = LTConfig.WantedConfig.GetConfig(crimeLevel).InductionRadius[1]
		end
	end

	for _, info in pairs(self.unitInfo) do
		if info.mapElement.type == EMapElementType.Police then
			if self.isEscape then
				info.mapElement.mData.rangeInfo = {
					tmp_type = 1,
					hideIcon = false,
					color = self._policeRangeColor,
					radius = radius
				}
			else
				info.mapElement.mData.rangeInfo = nil
			end
		end
	end
end

function M:AddSpoonUnitsBlacklist(taskId)
	self._spoonBlacklistDict[taskId] = true
end

function M:RemoveSpoonUnitsBlacklist(taskId)
	self._spoonBlacklistDict[taskId] = nil
end

function M:ResolveSpoonUnitsBlacklist()
	table.clear(self._invisibleSpoonPids)

	for taskId, _ in pairs(self._spoonBlacklistDict) do
		local spoonUnits = nil
		spoonUnits = gCS.SpoonTaskMgr.Instance:GetSpoonTaskAllEnemyPid(taskId)
		spoonUnits = spoonUnits and spoonUnits:ToTable()

		if spoonUnits then
			for _, pid in pairs(spoonUnits) do
				self._invisibleSpoonPids[pid] = true
			end
		end
	end
end

function M:GetIconId(type)
	if type == EMapElementType.Enemy then
		return 28004236
	elseif type == EMapElementType.Police then
		return 28001667
	end

	print_error("MapSubSystem_CommonUnit:GetIconId - Invalid type: " .. tostring(type))

	return 0
end

function M:OnSyncEnemyDetectInfo(pid, cfgId)
	self._stealthEnemyDetectInfo[pid] = cfgId

	self:AddEnemyDetectRange(pid, cfgId)
end

function M:AddEnemyDetectRange(pid, cfgId)
	if not pid or not cfgId then
		return
	end

	local info = self.unitInfo[pid]
	local cfg = StealthConfig.GetConfig(cfgId)

	if info and info.mapElement and cfg then
		info.mapElement:AddDetectRangeInfo(cfg.EnterVisionRange.DetectRadius, cfg.EnterVisionRange.DetectAngle, info.csUnit)
	end
end

function M:SetServerHostileUnit(pid, hostile)
	if hostile then
		self._serverHostileUnits[pid] = true
	else
		self._serverHostileUnits[pid] = nil
	end
end

return M
