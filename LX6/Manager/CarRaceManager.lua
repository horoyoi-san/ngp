-- Original chunk: @Lua\LuaFiles\LX6\Manager\CarRaceManager.lua
-- Decompiled from: 00755_CarRaceManager.lua_ceeeca34c626.luajit

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

CarRaceManager.ctor = function(self)
	self:InitEntities()

	self.rankList = {}
	self.raceType = RACE_TYPE_VEHICLE
	self.RaceSpeedEventType = {
		["`NϤ\\xa6\r\\xb0\r\\xc7\\xec"] = 3,
		["+.\\xefz\\x96\\xf0\\xa6,\\xf4\\xf7\\xe7g\\xfe"] = 0,
		["՛\\xe7\\xe1?\\xef\\x8b\\xe1\\x8b.-"] = 1,
		["pSmpo<"] = 2
	}
end

CarRaceManager.Init = function(self, taskID, raceType, laps, firstGpsSIcon, secondGpsSIcon, lastGpsSIcon, isOnline, isNotFinish, finishSignal)
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
		if i ~= #targetList then
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

CarRaceManager.StartOnlineRaceSpeed = function(self, taskID, laps, firstGpsSIcon, secondGpsSIcon, lastGpsSIcon)
	self:Init(taskID, 2, laps, firstGpsSIcon, secondGpsSIcon, lastGpsSIcon, true)

	local members = gLinkManager.LinkMemberInfo
	local entityNames = gLinkManager.LinkMember

	for pid, info in pairs(members) do
		local entityId = self:GetOnLineEntity(pid)

		if entityId == nil then
			gCarRaceManager:AddEntity(entityId, 0, nil, entityNames[pid].Name)
		end
	end

	self:SetOtherPlayerHudVisible(members, false)
	self:StartUpdate()
end

CarRaceManager.GetOnLineEntity = function(self, pid)
	local entityId = self.onLineEntityData[pid]

	return entityId
end

CarRaceManager.ClearRaceData = function(self)
	self.entityObjectList = {}
	self.entityIdToName = {}
	self.entityIdToIcon = {}
end

CarRaceManager.InitEntities = function(self)
	self:ClearRaceData()

	self.entityConfigMap = {}
	self.onLineEntityData = {}
end

CarRaceManager.SetOtherPlayerHudVisible = function(self, members, visible)
	for pid, _ in pairs(members) do
		local unitInfo = gLinkManager:GetUnitInfo(pid)
		local csunit = gCS.SceneDataMgr.GetUnit(unitInfo.Pid)

		if unitInfo.Pid == gCS.MyPlayerManager.PlayerUnit.Pid and csunit then
			local data = gDataSetManager:GetOrCreateUserData(csunit.ClientData.ownerId)

			if data then
				data.AllowHeadInfo = visible
			end
		end
	end
end

CarRaceManager.StartUpdate = function(self)
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

CarRaceManager.ResetRace = function(self, id)
	if self.entityObjectList[id] then
		gPanelManager:Close(gPanelId.S_RACING_PANEL)
		self:ShowRacingPanel()
		self:AddRankInfo(id)
		gMessageManager:SendMessage(gEventConstants.CHALLENGE_SPEED_RACE_RANK_MAP_CHANGE)
	end
end

CarRaceManager.ShowRacingPanel = function(self)
	local param = self:GetAllCarTipInfo()

	gPanelManager:CheckShow(gPanelId.S_RACING_PANEL, param)
end

CarRaceManager.OnUpdate = function(self)
	if not self.gameStart then
		return
	end

	self:RefreshRankList()
end

CarRaceManager.Destroy = function(self)
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
	gPanelManager:Close(gPanelId.CHALLENGE_COUNT_DOWN_RACING_PANEL)
	self:InitEntities()
	gMapSystem.navigation:ClearRaceNavLineInfo()
end

CarRaceManager.CorrectCount = function(self, index, maxCount)
	index = index % maxCount

	if index ~= 0 then
		index = maxCount
	end

	return index
end

CarRaceManager.OnCurrentTaskChanged = function(self, changedTaskCounterIndex)
	local entityRankInfo = self.entityRankInfoMap[self.taskID]
	local nextCounterIndex = self:CorrectCount(changedTaskCounterIndex + 1, self.taskCounterCount)
	local nextTwoCounterIndex = self:CorrectCount(changedTaskCounterIndex + 2, self.taskCounterCount)

	gMapSubSystem_CommonGps:RemoveStaticGps(string.format("%s%d%d", self.mgrName, self.taskID, changedTaskCounterIndex))
	gMapSubSystem_CommonGps:RemoveStaticGps(string.format("%s%d%d", self.mgrName, self.taskID, nextTwoCounterIndex))

	if changedTaskCounterIndex ~= self.taskCounterCount and entityRankInfo.finishTime == math.huge then
		if not self.isOnline then
			if not self.isNotFinish then
				gClientToGameDelegate:AskSetTaskCounterValue(self.taskID, self.taskCounterCount, 1).Callback = function (err)
					if err == LTConfig.MessageConfig.Ok then
						print_error(self.mgrName, err)
					end
				end
			else
				gCoroutineManager:StartCoroutine(function ()
					while gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene or not gCS.NetworkManager.Instance:IsServerConnected() do
						coroutine.yield(nil)
					end

					gReliableRpcManager:RegisterRPC(gClientToGameSceneDelegate.AskReleaseClientEvent, self.finishSignal, function (err)
						if err == LTConfig.MessageConfig.Ok then
							print_error(self.mgrName, err)
						end
					end)
				end)
			end
		else
			gReliableRpcManager:RegisterRPC(gClientToGameSceneDelegate.RaceSpeedFinish, function (err)
				if err == LTConfig.MessageConfig.Ok then
					print_error(self.mgrName, err)
				end
			end)
		end

		gPanelManager:Close(gPanelId.S_RACING_PANEL)

		return
	end

	if entityRankInfo.rankPointIndex > self.taskCounterCount - 1 and entityRankInfo.laps ~= self.laps - 1 then
		self:AddGps(nextCounterIndex, self.lastGpsSIcon)
		self:RemoveArrow()

		return
	end

	self:AddGps(nextCounterIndex, self.firstGpsSIcon)
	self:AddGps(nextTwoCounterIndex, self.secondGpsSIcon)
	self:UpdateArrowPosAndRot(nextCounterIndex, nextTwoCounterIndex)

	if entityRankInfo.laps > 1 and not self.isOnline then
		gClientToGameDelegate:AskSetTaskCounterValue(self.taskID, changedTaskCounterIndex % self.taskCounterCount, 0).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				print_error(self.mgrName, err)
			end
		end
	end
end

CarRaceManager.AddArrow = function(self)
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

CarRaceManager.UpdateArrowPosAndRot = function(self, index, nextIndex)
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

CarRaceManager.RemoveArrow = function(self)
	if not gCS.LuaUtils.IsNull(self.arrowGO) and not self.arrowGO:IsDestroyed() then
		GameObject.Destroy(self.arrowGO)

		self.arrowGO = nil
		self.arrowRoot = nil
	end

	gResourceManager:UnloadAssetLoadOp(self.arrowLoadOp)

	self.arrowLoadOp = nil
end

CarRaceManager.InitRank = function(self)
	local rankIndex = 1
	self.entityObjectList[self.taskID] = gCS.MyPlayerManager.PlayerUnit

	for id, _ in pairs(self.entityObjectList) do
		self.entityRankInfoMap[id] = {
			["as\\xb4ch\\xbb\\xe1Skt}I"] = 0,
			["\\xf5\\x9b\\xe7,\\xef\\xfe\\xa1\\xe3\\x86%0"] = 0,
			["v#mH"] = 0,
			id = id,
			finishTime = math.huge
		}
		self.entityRankMap[id] = rankIndex
		self.stayAheadTimes[rankIndex] = 0
		self.stayBeheadTimes[rankIndex] = 0
		rankIndex = rankIndex + 1
	end
end

CarRaceManager.AddRankInfo = function(self, id)
	if not self.entityRankInfoMap[id] then
		self.entityRankInfoMap[id] = {
			["as\\xb4ch\\xbb\\xe1Skt}I"] = 0,
			["\\xf5\\x9b\\xe7,\\xef\\xfe\\xa1\\xe3\\x86%0"] = 0,
			["v#mH"] = 0,
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

CarRaceManager.AddGps = function(self, index, gpsIcon)
	local cfg = gTaskManager:GetTaskConfigInfo(self.taskID)
	local sIconId = gTaskManager.TaskSIconId[cfg.Title]

	if gpsIcon == nil and gpsIcon == 0 then
		sIconId = gpsIcon
	end

	local counter = self.taskCounterList[index]
	self.nextGpsIndex = index

	if counter ~= nil then
		print_error("@liufuqiang01 counter is nil", #self.taskCounterList, index)

		return
	end

	local local_gpsId = string.format("%s%d%d", self.mgrName, self.taskID, index)

	gMapSubSystem_CommonGps:AddStaticGps(local_gpsId, gRaidDataManager.RaidId, counter.TargetPos, EMapViewMask.MiniMap, {
		["t#p^"] = "",
		sIconId = sIconId
	}, true, true, true)
end

CarRaceManager.GetRankInfoList = function(self)
	local rankList = {}

	for id, _ in pairs(self.entityObjectList) do
		self:UpdateEntityRankInfoById(id)
		table.insert(rankList, self.entityRankInfoMap[id])
	end

	table.sort(rankList, self.SortRankList)

	return rankList
end

CarRaceManager.UpdateEntityRankInfoById = function(self, id)
	local entityRankInfo = self.entityRankInfoMap[id]
	local finishTime = entityRankInfo.finishTime

	if finishTime == math.huge then
		return
	end

	local entityPos = self:GetEntityPosition(id)

	if entityPos ~= nil then
		return
	end

	local rankPointIndex = entityRankInfo.rankPointIndex
	local nextRankPointIndex = rankPointIndex + 1
	local curLaps = entityRankInfo.laps
	local nextRankPoint = self.taskCounterList[nextRankPointIndex]

	if nextRankPoint ~= nil then
		print_error("@liufuqiang01 nextRankPoint is nil", #self.taskCounterList, nextRankPointIndex)
	end

	local nextDistance = Vector3.Distance(entityPos, nextRankPoint.TargetPos)
	entityRankInfo.nextDistance = nextDistance

	if nextDistance >= self.checkPointRange then
		entityRankInfo.rankPointIndex = nextRankPointIndex
		entityRankInfo.nextDistance = math.huge

		if nextRankPointIndex ~= self.taskCounterCount then
			entityRankInfo.laps = curLaps + 1
			entityRankInfo.rankPointIndex = 0
		end

		if entityRankInfo.laps ~= self.laps then
			entityRankInfo.finishTime = gLogicTime.time
		end

		if id ~= self.taskID then
			if not self.isOnline then
				gClientToGameDelegate:AskSetTaskCounterValue(self.taskID, nextRankPointIndex - 1, 1).Callback = function (err)
					if err == LTConfig.MessageConfig.Ok then
						print_error(self.mgrName, err, self.taskID, nextRankPointIndex - 1)
					end
				end
			end

			self:OnCurrentTaskChanged(nextRankPointIndex)
		end
	end
end

CarRaceManager.RefreshRankList = function(self)
	local rankList = self:GetRankInfoList()
	self.rankList = rankList
	local isRankChange = false
	local lastRank = self:GetPlayerRank()

	for i, v in ipairs(rankList) do
		if self.entityRankMap[v.id] == i then
			isRankChange = true
		end

		self.entityRankMap[v.id] = i
	end

	local curRank = self:GetPlayerRank()

	if isRankChange then
		gMessageManager:SendMessage(gEventConstants.CHALLENGE_SPEED_RACE, self.entityRankMap)
	end

	if curRank == lastRank then
		gMessageManager:SendMessage(gEventConstants.ON_CAR_RACE_EVENT, {
			type = curRank >= lastRank and self.RaceSpeedEventType.RankingIncrease or self.RaceSpeedEventType.RankingDecline
		})
	end

	local length = #self.stayAheadTimes

	for i = 1, length do
		if curRank < i then
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

CarRaceManager.SortRankList = function(a, b)
	if a.finishTime == b.finishTime then
		return a.finishTime <= b.finishTime
	end

	if a.laps == b.laps then
		return b.laps <= a.laps
	end

	if a.rankPointIndex == b.rankPointIndex then
		return b.rankPointIndex <= a.rankPointIndex
	end

	return a.nextDistance <= b.nextDistance
end

CarRaceManager.GetEntityRankMap = function(self)
	if not self.gameStart then
		return L50.Spoon.CarRaceManager.Instance == nil and L50.Spoon.CarRaceManager.Instance.EntityRankMap:ToTable() or {}
	end

	return self.entityRankMap
end

CarRaceManager.GetPlayerVehicleSpeed = function(self)
	if not self.gameStart then
		return L50.Spoon.CarRaceManager.Instance == nil and L50.Spoon.CarRaceManager.Instance:GetPlayerVehicleSpeed() or 0
	end

	if gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle ~= nil then
		return 0
	end

	local speed = math.abs(gDriveVehiclesManager.cs_manager.PlayerCarSpeed) * 3.6
	local maxSpeed = gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle.MaxSpeed * 3.6
	speed = math.min(math.floor(speed + 0.5), maxSpeed)
	speed = math.floor(speed + 0.5)

	return speed
end

CarRaceManager.AddEntity = function(self, id, nameCfgId, icon, playerName)
	local entity = nil
	local nameCfg = TextConfig(nameCfgId)
	local name = nameCfg and nameCfg.Text or ""

	if not string.is_null_or_empty(playerName) then
		name = playerName
	end

	if self.raceType ~= RACE_TYPE_NPC then
		entity = gCS.LocalUnitMgr:GetNpcByPid(id)
	elseif self.raceType ~= RACE_TYPE_VEHICLE then
		entity = InvokeGetVehicleInScene(id)
	end

	if entity ~= nil then
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

CarRaceManager.GetEntityPosition = function(self, id)
	if self.entityObjectList[id] ~= nil or InvokeGetVehicleInScene(id) ~= nil and id == self.taskID then
		return nil
	end

	if self.raceType ~= RACE_TYPE_NPC then
		if id ~= self.taskID then
			return gCS.MyPlayerManager.PlayerUnit.LocalPosition
		end

		if self.entityObjectList[id].PlayerObj ~= nil then
			return nil
		end

		return self.entityObjectList[id].PlayerObj.transform.position
	elseif self.raceType ~= RACE_TYPE_VEHICLE then
		if id ~= self.taskID then
			if gCS.DriveManager.isDriveMode and not gCS.LuaUtils.IsNull(self.playerVehicle.gameObject) then
				return self.playerVehicle.gameObject.transform.position
			else
				return Vector3.New(0, 0, 0)
			end
		end

		if self.entityObjectList[id] ~= nil or gCS.LuaUtils.IsNull(self.entityObjectList[id].gameObject) then
			return nil
		end

		return self.entityObjectList[id].gameObject.transform.position
	end
end

CarRaceManager.GetEntityConfig = function(self, id)
	if self.entityObjectList[id] ~= nil then
		return nil
	end

	if self.entityConfigMap[id] == nil then
		return self.entityConfigMap[id]
	end

	local cfg = nil

	if self.raceType ~= RACE_TYPE_NPC then
		cfg = InvokeGetNpcConfig(self.entityObjectList[id].NpcId)
	elseif self.raceType ~= RACE_TYPE_VEHICLE then
		cfg = InvokeGetVehicleConfig(self.entityObjectList[id].cfgId)
	end

	if cfg ~= nil then
		return nil
	end

	self.entityConfigMap[id] = cfg

	return cfg
end

CarRaceManager.GetEntityNameById = function(self, id)
	if not self.gameStart then
		return L50.Spoon.CarRaceManager.Instance == nil and L50.Spoon.CarRaceManager.Instance:GetEntityNameById(id) or nil
	end

	if id ~= self.taskID then
		return gPlayerManager.infoLogin.bindData.playerName
	end

	return self.entityIdToName[id]
end

CarRaceManager.GetPlayerId = function(self)
	if not self.gameStart then
		return L50.Spoon.CarRaceManager.Instance == nil and L50.Spoon.CarRaceManager.Instance:GetPlayerVehicleId() or 0
	end

	return self.taskID
end

CarRaceManager.GetEntityIconById = function(self, id)
	if id ~= self.taskID then
		return 0
	end

	return self.entityIdToIcon[id] or 0
end

CarRaceManager.GetPlayerRank = function(self)
	if not self.gameStart then
		return L50.Spoon.CarRaceManager.Instance == nil and L50.Spoon.CarRaceManager.Instance:GetPlayerRank() or MAX_CAR_RANK
	end

	if self.entityRankMap and self.taskID then
		return self.entityRankMap[self.taskID]
	end

	return MAX_CAR_RANK
end

CarRaceManager.GetPlayerPos = function(self)
	return self:GetEntityPosition(self.taskID)
end

CarRaceManager.GetRankById = function(self, id)
	return self.entityRankMap[id]
end

CarRaceManager.GetAllCarTipInfo = function(self)
	local infos = {}

	for id, name in pairs(self.entityIdToName) do
		if id == self.taskID then
			local info = {
				id = id,
				name = name
			}

			table.insert(infos, info)
		end
	end

	return {
		["s1^H"] = false,
		carTipInfos = infos
	}
end

CarRaceManager.GetAllCarInfo = function(self)
	local infos = {}

	for id, entity in pairs(self.entityObjectList) do
		if id == self.taskID then
			local info = {
				vehicleId = id,
				pos = self:GetEntityPosition(id),
				entity = entity
			}
			local playerPos = self:GetPlayerPos()
			info.rank = self:GetRankById(id)

			if info.pos == nil then
				info.distance = Vector3.Distance(playerPos, info.pos)
			end

			info.zOffset = 0.01 * (4 - info.rank)

			table.insert(infos, info)
		end
	end

	return infos
end

CarRaceManager.CheckHasFrontPlayer = function(self)
	if not self.gameStart then
		return L50.Spoon.CarRaceManager.Instance == nil and L50.Spoon.CarRaceManager.Instance:CheckHasFrontPlayer() or false
	end

	if not self.entityRankMap then
		return false
	end

	local selfRank = self.entityRankMap[self.taskID]

	for k, v in pairs(self.entityRankInfoMap) do
		local rank = self.entityRankMap[k]

		if k == self.taskID and v.finishTime ~= math.huge and rank >= selfRank then
			return true
		end
	end

	return false
end

CarRaceManager.CheckGameStart = function(self)
	return self.gameStart or L50.Spoon.CarRaceManager.Instance == nil and L50.Spoon.CarRaceManager.Instance.IsGameStart
end

CarRaceManager.CalFinalRankData = function(self)
	local finalRankList = {}

	for i, val in pairs(self.rankList) do
		local id = val.id
		local vehicleEntity = nil

		if id == self.taskID then
			vehicleEntity = self.entityObjectList[id]
		else
			vehicleEntity = self.playerVehicle
		end

		if vehicleEntity == nil then
			local vehicleCfg = InvokeGetVehicleConfig(vehicleEntity.cfgId)
			local ele = {
				["JT_|M+"] = true,
				["a\\x9f\\x8a\\x86Y"] = 0,
				id = id,
				isSelf = id ~= self.taskID,
				player = {
					name = self:GetEntityNameById(id),
					icon = self:GetEntityIconById(id)
				},
				vehicle = {
					name = vehicleCfg and vehicleCfg.VehicleName or "",
					icon = vehicleCfg and vehicleCfg.SVehicleBrandIcon or 0
				},
				award = {},
				time = val.finishTime
			}

			table.insert(finalRankList, ele)
		end
	end

	self.finalRankList = finalRankList
end

CarRaceManager.PrintMessage = function(self, ...)
	if self.TaskDebug then
		print_error(...)
	end
end

gCarRaceManager = gCarRaceManager or CarRaceManager.new()

return gCarRaceManager
