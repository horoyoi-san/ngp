local StaticProps = {}
C_CarRaceManager = DefClass("C_CarRaceManager", C_CarRaceManager, nil, StaticProps)
local CarRaceManager = C_CarRaceManager
local RACE_TYPE_NPC = 1
local RACE_TYPE_VEHICLE = 2
local MAX_CAR_RANK = 25
local InvokeGetVehicleInScene = LX6.Drive.DriveUtils.GetBaseVehicle
local InvokeGetNpcConfig = LTConfig.AgentConfig.GetConfig
local InvokeGetVehicleConfig = LTConfig.VehicleConfig.GetConfig
local TextConfig = LTConfig.TextConfig.GetConfig
local MessageConfig = LTConfig.MessageConfig

function CarRaceManager:ctor()
	self:InitEntities()

	self.rankList = {}
	self.raceType = RACE_TYPE_VEHICLE
	self.RaceSpeedEventType = {
		StayBehind = 3,
		RankingIncrease = 0,
		RankingDecline = 1,
		StayAhead = 2
	}
end

function CarRaceManager:Init(taskID, raceType, laps, firstGpsSIcon, secondGpsSIcon, lastGpsSIcon, isOnline, isNotFinish, finishSignal)
	self:PrintMessage("@liufuqiang01 CarRaceManager Init 1")

	self.firstGpsSIcon = firstGpsSIcon
	self.secondGpsSIcon = secondGpsSIcon
	self.lastGpsSIcon = lastGpsSIcon
	self.isOnline = isOnline and true or false
	self.isNotFinish = isNotFinish or false
	self.finishSignal = finishSignal or ""
	self.taskID = taskID
	self.raceType = raceType
	self.laps = laps or 1
	self.checkPointRange = LTConfig.PoiGameConfig.BabyDriver_CheckPointRange
	self.rollAngle = LTConfig.PoiGameConfig.BabyDriver_CheckPointRollAngle
	local _, targetList, _ = gTaskNodeManager:GetTaskCounterInfo(self.taskID)
	self.taskCounterList = {}

	for i, v in ipairs(targetList) do
		if i == #targetList then
			break
		end

		self.taskCounterList[i] = v
	end

	self.taskCounterCount = #targetList - 1
	self.entityRankInfoMap = {}
	self.entityRankMap = {}
	self.stayAheadTimes = {}
	self.stayBeheadTimes = {}
	self.nextGpsIndex = 2
	self.mgrName = "CarRaceManager"
	self.playerVehicle = gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle

	self:ClearRaceData()
	self:PrintMessage("@liufuqiang01 CarRaceManager Init 2")
end

function CarRaceManager:StartOnlineRaceSpeed(taskID, laps, firstGpsSIcon, secondGpsSIcon, lastGpsSIcon)
	self:Init(taskID, 2, laps, firstGpsSIcon, secondGpsSIcon, lastGpsSIcon, true)

	local members = gLinkManager.LinkMemberInfo
	local entityNames = gLinkManager.LinkMember

	for pid, info in pairs(members) do
		local entityId = self:GetOnLineEntity(pid)

		if entityId ~= nil then
			gCarRaceManager:AddEntity(entityId, 0, nil, entityNames[pid].Name)
		end
	end

	self:SetOtherPlayerHudVisible(members, false)
	self:StartUpdate()
end

function CarRaceManager:AddOnLineEntity(pid, entityId)
	self.onLineEntityData[pid] = entityId
	local members = gLinkManager.LinkMemberInfo
	local entityNames = gLinkManager.LinkMember

	if members and entityNames and members[pid] and entityNames[pid] and self.entityObjectList[entityId] == nil and self.gameStart then
		self:AddEntity(entityId, 0, nil, entityNames[pid].Name)
		self:ResetRace(entityId)
	end
end

function CarRaceManager:GetOnLineEntity(pid)
	local entityId = self.onLineEntityData[pid]

	return entityId
end

function CarRaceManager:ClearRaceData()
	self.entityObjectList = {}
	self.entityIdToName = {}
	self.entityIdToIcon = {}
end

function CarRaceManager:InitEntities()
	self:ClearRaceData()

	self.entityConfigMap = {}
	self.onLineEntityData = {}
end

function CarRaceManager:SetOtherPlayerHudVisible(members, visible)
	for pid, _ in pairs(members) do
		local unitInfo = gLinkManager:GetUnitInfo(pid)
		local csunit = gCS.SceneDataMgr.GetUnit(unitInfo.pid)

		if unitInfo.pid ~= gCS.MyPlayerManager.PlayerUnit.Pid and csunit then
			local data = gDataSetManager:GetOrCreateUserData(csunit.ClientData.ownerId)

			if data then
				data.AllowHeadInfo = visible
			end
		end
	end
end

function CarRaceManager:StartUpdate()
	self:PrintMessage("@liufuqiang01 CarRaceManager StartUpdate 1")
	self:ShowRacingPanel()
	self:InitRank()
	self:AddGps(1, self.firstGpsSIcon)
	self:AddGps(2, self.secondGpsSIcon)
	self:AddArrow()
	gLuaClient:RegisterDynamicUpdate(self.mgrName, self, false)

	self.gameStart = true

	self:PrintMessage("@liufuqiang01 CarRaceManager StartUpdate 2")
end

function CarRaceManager:ResetRace(id)
	if self.entityObjectList[id] then
		gPanelManager:Close(gPanelId.S_RACING_PANEL)
		self:ShowRacingPanel()
		self:AddRankInfo(id)
		gMessageManager:SendMessage(gEventConstants.CHALLENGE_SPEED_RACE_RANK_MAP_CHANGE)
	end
end

function CarRaceManager:ShowRacingPanel()
	local param = self:GetAllCarTipInfo()

	gPanelManager:CheckShow(gPanelId.S_RACING_PANEL, param)
end

function CarRaceManager:OnUpdate()
	if not self.gameStart then
		return
	end

	self:RefreshRankList()
end

function CarRaceManager:Destroy()
	if not self.gameStart then
		return
	end

	self:CalFinalRankData()
	gLuaClient:UnregisterDynamicUpdate(self.mgrName)
	gMapSubSystem_CommonGps:RemoveStaticGps(string.format("%s%d%d", self.mgrName, self.taskID, self.nextGpsIndex))

	local preGpsIndex = (self.nextGpsIndex + self.taskCounterCount - 2) % self.taskCounterCount + 1

	gMapSubSystem_CommonGps:RemoveStaticGps(string.format("%s%d%d", self.mgrName, self.taskID, preGpsIndex))
	self:RemoveArrow()

	self.gameStart = false
	local members = gLinkManager.LinkMemberInfo

	if self.isOnline and members then
		self:SetOtherPlayerHudVisible(members, true)
	end

	gPanelManager:Close(gPanelId.S_RACING_PANEL)
	self:InitEntities()
end

function CarRaceManager:CorrectCount(index, maxCount)
	index = index % maxCount

	if index == 0 then
		index = maxCount
	end

	return index
end

function CarRaceManager:OnCurrentTaskChanged(changedTaskCounterIndex)
	local entityRankInfo = self.entityRankInfoMap[self.taskID]
	local nextCounterIndex = self:CorrectCount(changedTaskCounterIndex + 1, self.taskCounterCount)
	local nextTwoCounterIndex = self:CorrectCount(changedTaskCounterIndex + 2, self.taskCounterCount)

	gMapSubSystem_CommonGps:RemoveStaticGps(string.format("%s%d%d", self.mgrName, self.taskID, changedTaskCounterIndex))
	gMapSubSystem_CommonGps:RemoveStaticGps(string.format("%s%d%d", self.mgrName, self.taskID, nextTwoCounterIndex))

	if changedTaskCounterIndex == self.taskCounterCount and entityRankInfo.finishTime ~= math.huge then
		if not self.isOnline then
			if not self.isNotFinish then
				gClientToGameDelegate:AskSetTaskCounterValue(self.taskID, self.taskCounterCount, 1).Callback = function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						print_error(self.mgrName, err)
					end
				end
			else
				gCoroutineManager:StartCoroutine(function ()
					while gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene or not gCS.NetworkManager.Instance:IsServerConnected() do
						coroutine.yield(nil)
					end

					gClientToGameSceneDelegate:AskReleaseClientEvent(self.finishSignal)
				end)
			end
		else
			gClientToGameSceneDelegate:RaceSpeedFinish().Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					print_error(self.mgrName, err)
				end
			end
		end

		return
	end

	if entityRankInfo.rankPointIndex >= self.taskCounterCount - 1 and entityRankInfo.laps == self.laps - 1 then
		self:AddGps(nextCounterIndex, self.lastGpsSIcon)
		self:RemoveArrow()

		return
	end

	self:AddGps(nextCounterIndex, self.firstGpsSIcon)
	self:AddGps(nextTwoCounterIndex, self.secondGpsSIcon)
	self:UpdateArrowPosAndRot(nextCounterIndex, nextTwoCounterIndex)

	if entityRankInfo.laps >= 1 and not self.isOnline then
		gClientToGameDelegate:AskSetTaskCounterValue(self.taskID, changedTaskCounterIndex % self.taskCounterCount, 0).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				print_error(self.mgrName, err)
			end
		end
	end
end

function CarRaceManager:AddArrow()
	local prefabPath = LTConfig.PoiGameConfig.BabyDriver_CheckPointArrowPrefab
	self.arrowLoadOp = gResourceManager:LoadAssetWithCallBack(prefabPath, typeof(GameObject), function (loadOp)
		local res = loadOp.asset

		if gCS.LuaUtils.IsNull(res) then
			print_error(" Load asset failed at " .. prefabPath)

			return
		end

		if not gCS.LuaUtils.IsNull(self.arrowGO) and not self.arrowGO:IsDestroyed() then
			GameObject.Destroy(self.arrowGO)
		end

		self.arrowGO = GameObject.Instantiate(res)
		self.arrowRoot = self.arrowGO.transform:Find("arrowRoot")

		self:UpdateArrowPosAndRot(1, 2)
	end)
end

function CarRaceManager:UpdateArrowPosAndRot(index, nextIndex)
	local checkPointSnapAngle = LTConfig.PoiGameConfig.BabyDriver_CheckPointSnapAngle
	local playerPosition = self:GetEntityPosition(self.taskID)

	if not gCS.LuaUtils.IsNull(self.arrowRoot) or not playerPosition then
		local targetPos = self.taskCounterList[index].TargetPos
		self.arrowGO.transform.position = targetPos
		local nextTargetPos = self.taskCounterList[nextIndex].TargetPos
		local dir = nextTargetPos - targetPos
		local dirFlat = Vector3.New(dir.x, 0, dir.z)
		local rotation = Quaternion.LookRotation(dir).eulerAngles
		local rotationY = math.floor(rotation.y / checkPointSnapAngle + 0.5) * checkPointSnapAngle
		local playerToArrowDir = targetPos - playerPosition
		local playerToArrowFlat = Vector3.New(playerToArrowDir.x, 0, playerToArrowDir.z)
		local dirFlatNorm = dirFlat.normalized
		local playerToArrowFlatNorm = playerToArrowFlat.normalized
		local dot = dirFlatNorm.x * playerToArrowFlatNorm.x + dirFlatNorm.z * playerToArrowFlatNorm.z
		local cross = dirFlatNorm.x * playerToArrowFlatNorm.z - dirFlatNorm.z * playerToArrowFlatNorm.x
		local angleToArrow = math.atan(cross, dot) * Mathf.Rad2Deg
		local rotationZ = math.floor(angleToArrow / checkPointSnapAngle + 0.5) * checkPointSnapAngle
		self.arrowRoot.transform.rotation = Quaternion.Euler(0, rotationY, math.abs(rotationZ))
	end
end

function CarRaceManager:RemoveArrow()
	if not gCS.LuaUtils.IsNull(self.arrowGO) and not self.arrowGO:IsDestroyed() then
		GameObject.Destroy(self.arrowGO)

		self.arrowGO = nil
		self.arrowRoot = nil
	end

	gResourceManager:UnloadAssetLoadOp(self.arrowLoadOp)

	self.arrowLoadOp = nil
end

function CarRaceManager:InitRank()
	local rankIndex = 1
	self.entityObjectList[self.taskID] = gCS.MyPlayerManager.PlayerUnit

	for id, _ in pairs(self.entityObjectList) do
		self.entityRankInfoMap[id] = {
			nextDistance = 0,
			rankPointIndex = 0,
			laps = 0,
			id = id,
			finishTime = math.huge
		}
		self.entityRankMap[id] = rankIndex
		self.stayAheadTimes[rankIndex] = 0
		self.stayBeheadTimes[rankIndex] = 0
		rankIndex = rankIndex + 1
	end
end

function CarRaceManager:AddRankInfo(id)
	if not self.entityRankInfoMap[id] then
		self.entityRankInfoMap[id] = {
			nextDistance = 0,
			rankPointIndex = 0,
			laps = 0,
			id = id,
			finishTime = math.huge
		}
		local rankIndex = 0

		for id, _ in pairs(self.entityObjectList) do
			rankIndex = rankIndex + 1
		end

		self.entityRankMap[id] = rankIndex
	end
end

function CarRaceManager:AddGps(index, gpsIcon)
	local cfg = gTaskManager:GetTaskConfigInfo(self.taskID)
	local sIconId = gTaskManager.TaskSIconId[cfg.Title]

	if gpsIcon ~= nil and gpsIcon ~= 0 then
		sIconId = gpsIcon
	end

	local counter = self.taskCounterList[index]
	self.nextGpsIndex = index

	if counter == nil then
		print_error("@liufuqiang01 counter is nil", #self.taskCounterList, index)

		return
	end

	local local_gpsId = string.format("%s%d%d", self.mgrName, self.taskID, index)

	gMapSubSystem_CommonGps:AddStaticGps(local_gpsId, gRaidDataManager.RaidId, counter.TargetPos, EMapViewMask.MiniMap, {
		name = "",
		sIconId = sIconId
	}, true, true, true)
end

function CarRaceManager:GetRankInfoList()
	local rankList = {}

	for id, _ in pairs(self.entityObjectList) do
		self:UpdateEntityRankInfoById(id)
		table.insert(rankList, self.entityRankInfoMap[id])
	end

	table.sort(rankList, self.SortRankList)

	return rankList
end

function CarRaceManager:UpdateEntityRankInfoById(id)
	local entityRankInfo = self.entityRankInfoMap[id]
	local finishTime = entityRankInfo.finishTime

	if finishTime ~= math.huge then
		return
	end

	local entityPos = self:GetEntityPosition(id)

	if entityPos == nil then
		return
	end

	local rankPointIndex = entityRankInfo.rankPointIndex
	local nextRankPointIndex = rankPointIndex + 1
	local curLaps = entityRankInfo.laps
	local nextRankPoint = self.taskCounterList[nextRankPointIndex]
	local nextDistance = Vector3.Distance(entityPos, nextRankPoint.TargetPos)
	entityRankInfo.nextDistance = nextDistance

	if nextDistance < self.checkPointRange then
		entityRankInfo.rankPointIndex = nextRankPointIndex
		entityRankInfo.nextDistance = math.huge

		if nextRankPointIndex == self.taskCounterCount then
			entityRankInfo.laps = curLaps + 1
			entityRankInfo.rankPointIndex = 0
		end

		if entityRankInfo.laps == self.laps then
			entityRankInfo.finishTime = gLogicTime.time
		end

		if id == self.taskID then
			if not self.isOnline then
				gClientToGameDelegate:AskSetTaskCounterValue(self.taskID, nextRankPointIndex - 1, 1).Callback = function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						print_error(self.mgrName, err, self.taskID, nextRankPointIndex - 1)
					end
				end
			end

			self:OnCurrentTaskChanged(nextRankPointIndex)
		end
	end
end

function CarRaceManager:RefreshRankList()
	local rankList = self:GetRankInfoList()
	self.rankList = rankList
	local isRankChange = false
	local lastRank = self:GetPlayerRank()

	for i, v in ipairs(rankList) do
		if self.entityRankMap[v.id] ~= i then
			isRankChange = true
		end

		self.entityRankMap[v.id] = i
	end

	local curRank = self:GetPlayerRank()

	if isRankChange then
		gMessageManager:SendMessage(gEventConstants.CHALLENGE_SPEED_RACE, self.entityRankMap)
	end

	if curRank ~= lastRank then
		gMessageManager:SendMessage(gEventConstants.ON_CAR_RACE_EVENT, {
			type = curRank < lastRank and self.RaceSpeedEventType.RankingIncrease or self.RaceSpeedEventType.RankingDecline
		})
	end

	local length = #self.stayAheadTimes

	for i = 1, length do
		if curRank <= i then
			self.stayAheadTimes[i] = self.stayAheadTimes[i] + gLogicTime.deltaTime
			self.stayBeheadTimes[length - i + 1] = self.stayBeheadTimes[length - i + 1] + gLogicTime.deltaTime
		else
			self.stayAheadTimes[i] = 0
			self.stayBeheadTimes[length - i + 1] = 0
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_CAR_RACE_EVENT, {
		type = self.RaceSpeedEventType.StayAhead,
		stayAheadTimes = self.stayAheadTimes,
		stayBeheadTimes = self.stayBeheadTimes
	})
end

function CarRaceManager.SortRankList(a, b)
	if a.finishTime ~= b.finishTime then
		return a.finishTime < b.finishTime
	end

	if a.laps ~= b.laps then
		return b.laps < a.laps
	end

	if a.rankPointIndex ~= b.rankPointIndex then
		return b.rankPointIndex < a.rankPointIndex
	end

	return a.nextDistance < b.nextDistance
end

function CarRaceManager:GetEntityRankMap()
	return self.entityRankMap
end

function CarRaceManager:GetPlayerVehicleSpeed()
	if gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle == nil then
		return 0
	end

	local speed = math.abs(gDriveVehiclesManager.cs_manager.PlayerCarSpeed) * 3.6
	local maxSpeed = gDriveVehiclesManager.cs_manager.CurrentPlayerVehicle.MaxSpeed * 3.6
	speed = math.min(math.floor(speed + 0.5), maxSpeed)
	speed = math.floor(speed + 0.5)

	return speed
end

function CarRaceManager:AddEntity(id, nameCfgId, icon, playerName)
	local entity = nil
	local nameCfg = TextConfig(nameCfgId)
	local name = nameCfg and nameCfg.Text or ""

	if not string.is_null_or_empty(playerName) then
		name = playerName
	end

	if self.raceType == RACE_TYPE_NPC then
		entity = gCS.NpcMgr:GetNpcByPid(id)
	elseif self.raceType == RACE_TYPE_VEHICLE then
		entity = InvokeGetVehicleInScene(id)
	end

	if entity == nil then
		print_warn("RaceSpeedManager: no entity" .. id)

		return
	end

	if self.entityConfigMap[id] then
		return
	end

	self.entityObjectList[id] = entity
	self.entityIdToName[id] = name
	self.entityIdToIcon[id] = icon
end

function CarRaceManager:GetEntityPosition(id)
	if self.entityObjectList[id] == nil or InvokeGetVehicleInScene(id) == nil and id ~= self.taskID then
		return nil
	end

	if self.raceType == RACE_TYPE_NPC then
		if id == self.taskID then
			return gCS.MyPlayerManager.PlayerUnit.LocalPosition
		end

		if self.entityObjectList[id].PlayerObj == nil then
			return nil
		end

		return self.entityObjectList[id].PlayerObj.transform.position
	elseif self.raceType == RACE_TYPE_VEHICLE then
		if id == self.taskID then
			if gCS.DriveManager.isDriveMode and not gCS.LuaUtils.IsNull(self.playerVehicle.gameObject) then
				return self.playerVehicle.gameObject.transform.position
			else
				return Vector3.New(0, 0, 0)
			end
		end

		if self.entityObjectList[id] == nil or gCS.LuaUtils.IsNull(self.entityObjectList[id].gameObject) then
			return nil
		end

		return self.entityObjectList[id].gameObject.transform.position
	end
end

function CarRaceManager:GetEntityConfig(id)
	if self.entityObjectList[id] == nil then
		return nil
	end

	if self.entityConfigMap[id] ~= nil then
		return self.entityConfigMap[id]
	end

	local cfg = nil

	if self.raceType == RACE_TYPE_NPC then
		cfg = InvokeGetNpcConfig(self.entityObjectList[id].NpcId)
	elseif self.raceType == RACE_TYPE_VEHICLE then
		cfg = InvokeGetVehicleConfig(self.entityObjectList[id].cfgId)
	end

	if cfg == nil then
		return nil
	end

	self.entityConfigMap[id] = cfg

	return cfg
end

function CarRaceManager:GetEntityNameById(id)
	if id == self.taskID then
		return gPlayerManager.infoLogin.bindData.name
	end

	return self.entityIdToName[id]
end

function CarRaceManager:GetEntityIconById(id)
	if id == self.taskID then
		return 0
	end

	return self.entityIdToIcon[id] or 0
end

function CarRaceManager:GetPlayerRank()
	if self.entityRankMap and self.taskID then
		return self.entityRankMap[self.taskID]
	end

	return MAX_CAR_RANK
end

function CarRaceManager:GetPlayerPos()
	return self:GetEntityPosition(self.taskID)
end

function CarRaceManager:GetRankById(id)
	return self.entityRankMap[id]
end

function CarRaceManager:GetAllCarTipInfo()
	local infos = {}

	for id, name in pairs(self.entityIdToName) do
		if id ~= self.taskID then
			local info = {
				id = id,
				name = name
			}

			table.insert(infos, info)
		end
	end

	return {
		isCs = false,
		carTipInfos = infos
	}
end

function CarRaceManager:GetAllCarInfo()
	local infos = {}

	for id, entity in pairs(self.entityObjectList) do
		if id ~= self.taskID then
			local info = {
				vehicleId = id,
				pos = self:GetEntityPosition(id),
				entity = entity
			}
			local playerPos = self:GetPlayerPos()
			info.rank = self:GetRankById(id)

			if info.pos ~= nil then
				info.distance = Vector3.Distance(playerPos, info.pos)
			end

			info.zOffset = 0.01 * (4 - info.rank)

			table.insert(infos, info)
		end
	end

	return infos
end

function CarRaceManager:CheckHasFrontPlayer()
	if not self.entityRankMap then
		return false
	end

	local selfRank = self.entityRankMap[self.taskID]

	for k, v in pairs(self.entityRankInfoMap) do
		local rank = self.entityRankMap[k]

		if k ~= self.taskID and v.finishTime == math.huge and rank < selfRank then
			return true
		end
	end

	return false
end

function CarRaceManager:CalFinalRankData()
	local finalRankList = {}

	for i, val in pairs(self.rankList) do
		local id = val.id
		local vehicleEntity = nil

		if id ~= self.taskID then
			vehicleEntity = self.entityObjectList[id]
		else
			vehicleEntity = self.playerVehicle
		end

		if vehicleEntity ~= nil then
			local vehicleCfg = InvokeGetVehicleConfig(vehicleEntity.cfgId)
			local ele = {
				isSuccess = true,
				tIndex = 0,
				id = id,
				player = {
					name = self:GetEntityNameById(id),
					icon = self:GetEntityIconById(id)
				},
				vehicle = {
					name = vehicleCfg.VehicleName,
					icon = vehicleCfg.SVehicleBrandIcon
				},
				award = {},
				time = val.finishTime
			}

			table.insert(finalRankList, ele)
		end
	end

	self.finalRankList = finalRankList
end

function CarRaceManager:GetFinalRankData()
	return self.finalRankList
end

function CarRaceManager:PrintMessage(...)
	if self.TaskDebug then
		print_error(...)
	end
end

function CarRaceManager:DebugEnable(enable)
	self.TaskDebug = enable
end

function CarRaceManager:RetrieveNearbyVehicle(isAhead, distance)
	local playerRank = self:GetPlayerRank()
	local playPos = self:GetPlayerPos()
	local vehicleId, position = nil

	if isAhead and self.rankList[playerRank - 1] then
		position = self:GetEntityPosition(self.rankList[playerRank - 1])
		vehicleId = self.rankList[playerRank - 1]
	elseif not isAhead and self.rankList[playerRank + 1] then
		position = self:GetEntityPosition(self.rankList[playerRank + 1])
		vehicleId = self.rankList[playerRank + 1]
	end

	if vehicleId and position and playPos and Vector3.Distance(playPos, position) < distance then
		return vehicleId
	end

	return ulong.zero
end

gCarRaceManager = gCarRaceManager or CarRaceManager.new()

return gCarRaceManager
