local IndoorConfig = LTConfig.IndoorConfig
local HouseBuildConfig = LTConfig.HouseBuildConfig
local HouseConfig = LTConfig.HouseConfig
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
C_HouseManager = DefClass("C_HouseManager", C_HouseManager)
local M = C_HouseManager

function M:ctor()
	self.currentIndoorId = 0
	self.lastIndoorId = 0
	self.indoorEnterTime = 0
	self.indoorExitTime = 0
	self.houseId = 0
	self.targetIndoorIds = {}
	self.indoorEventHandlers = {}
	self.distanceCheckTimer = nil
	self.roomPosition = Vector3.New(2889.987, 192.14, 1242.778)
	self.loadThreshold = 70
	self.unloadThreshold = 100
	self.furnitureLoadedStates = {}
	self.serverSyncState = {}
	self.clientToServerUidMap = {}
	self.serverToClientUidMap = {}
	self.pendingChanges = {
		added = {},
		changed = {},
		removed = {}
	}

	self:OnInit()
end

function M:OnInit()
	for i = 0, HouseBuildConfig.count - 1 do
		local houseCfg = HouseBuildConfig.LoadAt(i)
		self.targetIndoorIds[houseCfg.IndoorId] = houseCfg
	end

	self:InitEventListeners()
	self:StartDistanceCheckTimer()
end

function M:OnDestroy()
	self:StopDistanceCheckTimer()
end

function M:InitEventListeners()
	gMessageManager:AddMessageListener(gEventConstants.MAP_CHANGE_TO_INDOOR_MAP, self:CreateAction("OnEventIndoorEnvironmentChange"))
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, self:CreateAction("OnSceneSwitch"))
end

function M:ClearEventListeners()
	return
end

function M:StartDistanceCheckTimer()
	if self.distanceCheckTimer then
		self.distanceCheckTimer:Stop()
	end

	self.distanceCheckTimer = Timer.New(function ()
		self:CheckPlayerDistanceToRooms()
	end, 1, -1):Start(true)
end

function M:StopDistanceCheckTimer()
	if self.distanceCheckTimer then
		self.distanceCheckTimer:Stop()

		self.distanceCheckTimer = nil
	end
end

function M:CheckPlayerDistanceToRooms()
	if not gCS.MyPlayerManager.PlayerUnit or gCS.MyPlayerManager.PlayerUnit.IsDestroyed then
		return
	end

	local playerPosition = gCS.MyPlayerManager.PlayerUnit.LocalPosition

	if not playerPosition then
		return
	end

	local distance = Vector3.Distance(playerPosition, self.roomPosition)

	for indoorId, houseCfg in pairs(self.targetIndoorIds) do
		local isLoaded = self.furnitureLoadedStates[indoorId] or false

		if distance < self.loadThreshold and not isLoaded then
			self:LoadFurnitureForIndoor(indoorId)

			self.furnitureLoadedStates[indoorId] = true
		elseif self.unloadThreshold < distance and isLoaded then
			self:UnloadFurnitureForIndoor(indoorId)

			self.furnitureLoadedStates[indoorId] = false
		end
	end
end

function M:LoadFurnitureForIndoor(indoorId)
	if self.targetIndoorIds[indoorId] then
		self:LoadTargetIndoorFurniture(indoorId)
	end
end

function M:UnloadFurnitureForIndoor(indoorId)
	if self.targetIndoorIds[indoorId] then
		self:UnloadTargetIndoorFurniture(indoorId)
	end
end

function M:OnEventIndoorEnvironmentChange(eventId, data)
	self:OnIndoorEnvironmentChange(data)
end

function M:OnIndoorEnvironmentChange(data)
	if not data then
		return
	end

	local toIndoorId = data.toIndoorId or 0
	self.lastIndoorId = self.currentIndoorId
	self.currentIndoorId = toIndoorId

	if toIndoorId > 0 then
		self:OnEnterIndoor(toIndoorId)
	else
		self:OnExitIndoor()
	end
end

function M:OnSceneSwitch(eventId, switchType)
	self:UpdateCurrentIndoorState()
end

function M:OnEnterIndoor(indoorId)
	self.indoorEnterTime = gCS.TimeManager.ServerUnixTime or os.time()
	local indoorConfig = IndoorConfig.GetConfig(indoorId)

	if self.targetIndoorIds[indoorId] then
		self:OnEnterTargetIndoor(indoorId, indoorConfig)
	end

	self:TriggerIndoorEvent("Enter", indoorId, indoorConfig)
end

function M:OnExitIndoor()
	local lastIndoorId = self.lastIndoorId
	self.indoorExitTime = gCS.TimeManager.ServerUnixTime or os.time()

	if self.targetIndoorIds[lastIndoorId] then
		self:OnExitTargetIndoor(lastIndoorId)
	end

	self:TriggerIndoorEvent("Exit", lastIndoorId, nil)
end

function M:OnEnterTargetIndoor(indoorId, indoorConfig)
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_ENTER_HOUSE)

	local houseInfoList = gPlayerManager.infoMinor.bindData.housesInfo
	local cfg = self.targetIndoorIds[indoorId]
	local houseInfo = nil

	for k, v in ipairs(houseInfoList.HouseInfoList) do
		local houseCfg = HouseConfig.GetConfig(v.HouseId)

		if houseCfg.BuildId == cfg.Id then
			houseInfo = v
			self.houseId = v.HouseId

			break
		end
	end

	if not houseInfo then
		print_debug(string.format("HouseManager: 还没买这个房，室内ID: %d, 配置ID: %d", indoorId, cfg.Id))

		return
	end

	local isLoaded = self.furnitureLoadedStates[indoorId] or false

	if not isLoaded then
		self.serverSyncState = {}
		self.clientToServerUidMap = {}
		self.serverToClientUidMap = {}

		self:ClearPendingChanges()

		self.furnitureLoadedStates[indoorId] = true

		self:LoadTargetIndoorFurniture(indoorId)
	end
end

function M:LoadTargetIndoorFurniture(indoorId)
	local houseInfoList = gPlayerManager.infoMinor.bindData.housesInfo
	local cfg = self.targetIndoorIds[indoorId]
	local houseInfo = nil

	for k, v in ipairs(houseInfoList.HouseInfoList) do
		local houseCfg = HouseConfig.GetConfig(v.HouseId)

		if houseCfg.BuildId == cfg.Id then
			houseInfo = v

			break
		end
	end

	if not houseInfo then
		print_debug(string.format("HouseManager: 未找到对应的房屋信息，室内ID: %d, 配置ID: %d", indoorId, cfg.Id))

		return
	end

	for k, v in pairs(houseInfo.FloorBuildInfoDict) do
		local indoorBuildInfo = v
		local furnitureDict = indoorBuildInfo.Root.ChildrenDict
		local processedFurnitures = {}

		for key, furnitureInfo in pairs(furnitureDict) do
			gFurnitureUtils:ProcessServerFurnitureData(furnitureInfo)

			processedFurnitures[key] = furnitureInfo
		end

		local loadedFurnitureIds = {}

		local function LoadFurnitureRecursively(furnitureInfo, parentId)
			local placedInstanceId = furnitureInfo.PlacedInstanceId

			if loadedFurnitureIds[placedInstanceId] then
				return
			end

			loadedFurnitureIds[placedInstanceId] = true

			self:CreateFurnitureFromServerData(furnitureInfo, parentId)

			if furnitureInfo.ChildrenDict and next(furnitureInfo.ChildrenDict) then
				for childKey, childFurnitureInfo in pairs(furnitureInfo.ChildrenDict) do
					gFurnitureUtils:ProcessServerFurnitureData(childFurnitureInfo)
					LoadFurnitureRecursively(childFurnitureInfo, furnitureInfo.PlacedInstanceId)
				end
			end
		end

		for key, furnitureInfo in pairs(processedFurnitures) do
			local parentId = furnitureInfo.ParentPlacedInstanceId or 0

			if parentId == 0 then
				LoadFurnitureRecursively(furnitureInfo, 0)
			end
		end
	end
end

function M:UnloadTargetIndoorFurniture(indoorId)
	gFurnitureManager:RemoveAllFurniture()
end

function M:CreateFurnitureFromServerData(furnitureInfo, parentId)
	if not furnitureInfo then
		print_error("HouseManager: furnitureInfo is nil")

		return
	end

	local furnitureId = furnitureInfo.FurnitureId
	local gadgetInstanceId = furnitureInfo.GadgetInstanceId
	local pos = furnitureInfo.Position
	local rotation = furnitureInfo.Rotation
	local serverPlacedInstanceId = furnitureInfo.PlacedInstanceId

	if not furnitureId or not pos or not rotation or not serverPlacedInstanceId then
		print_error("HouseManager: 家具信息不完整", furnitureId, pos, rotation, serverPlacedInstanceId)

		return
	end

	local clientUID = serverPlacedInstanceId
	local posVector3 = Vector3.New(pos.X or pos.x, pos.Y or pos.y, pos.Z or pos.z)
	local rotVector3 = Vector3.New(rotation.X or rotation.x, rotation.Y or rotation.y, rotation.Z or rotation.z)

	self:RecordServerFurnitureState(serverPlacedInstanceId, furnitureId, posVector3, rotVector3, parentId)
	self:MapClientToServerUID(clientUID, serverPlacedInstanceId)

	local carrySurfaceUID = nil

	if parentId and parentId ~= 0 then
		carrySurfaceUID = self.serverToClientUidMap[parentId] or parentId
	end

	gFurnitureManager:SpawnFurnitureFromServerData(furnitureId, posVector3, rotVector3, clientUID, gadgetInstanceId, carrySurfaceUID)
end

function M:OnExitTargetIndoor(indoorId)
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_EXIT_HOUSE)

	self.houseId = nil

	self:UnloadTargetIndoorFurniture(indoorId)
end

function M:UpdateCurrentIndoorState()
	local currentIndoorId = gMapManager.IndoorId or 0

	if currentIndoorId ~= self.currentIndoorId then
		self:OnIndoorEnvironmentChange({
			toIndoorId = currentIndoorId
		})
	end
end

function M:AddTargetIndoorId(indoorId)
	if indoorId and indoorId > 0 then
		self.targetIndoorIds[indoorId] = true
	end
end

function M:RemoveTargetIndoorId(indoorId)
	if indoorId and self.targetIndoorIds[indoorId] then
		self.targetIndoorIds[indoorId] = nil
	end
end

function M:ClearTargetIndoorIds()
	self.targetIndoorIds = {}
end

function M:GetCurrentIndoorId()
	return self.currentIndoorId
end

function M:AddIndoorEventHandler(eventType, handler)
	if not self.indoorEventHandlers[eventType] then
		self.indoorEventHandlers[eventType] = {}
	end

	table.insert(self.indoorEventHandlers[eventType], handler)
end

function M:TriggerIndoorEvent(eventType, indoorId, indoorConfig)
	local handlers = self.indoorEventHandlers[eventType]

	if handlers then
		for _, handler in ipairs(handlers) do
			if type(handler) == "function" then
				handler(indoorId, indoorConfig)
			end
		end
	end
end

function M:GetNowBuildConfig()
	return self.targetIndoorIds[self.currentIndoorId] or nil
end

function M:GetNowBuildDefaultTowards()
	local cfg = self:GetNowBuildConfig()

	if cfg then
		return tonumber(cfg.BuildDefaultTowards) or 0
	end

	return 0
end

function M:ChangeFloorCeilingEnable(buildId, floor, isCeiling, enable)
	local cfg = HouseBuildConfig.GetConfig(buildId)
	local uidList = isCeiling and cfg.CeilingUidList or cfg.FloorUidList
	local num = #uidList

	for i, uid in ipairs(uidList) do
		CSFurnitureManager.uidStrList[i - 1] = uid
	end

	CSFurnitureManager.ChangeOneFloorCeilingGameObjectEnable(enable, num)
end

function M:GetCurHouseId()
	return self.houseId
end

function M:GetRealTimePlacedCount(furnitureId)
	if not furnitureId then
		return 0
	end

	local furnitureInfoDict = gPlayerManager.infoMinor.bindData.housesInfo.FurnitureInfoDict
	local furnitureInfo = furnitureInfoDict[furnitureId]
	local serverPlacedCount = furnitureInfo and furnitureInfo.PlacedCount or 0
	local localAddedCount = 0
	local localRemovedCount = 0

	for clientUID, addInfo in pairs(self.pendingChanges.added) do
		if addInfo.furnitureId == furnitureId then
			localAddedCount = localAddedCount + 1
		end
	end

	for clientUID, removedInfo in pairs(self.pendingChanges.removed) do
		if removedInfo.furnitureId == furnitureId then
			localRemovedCount = localRemovedCount + 1
		end
	end

	local realTimePlacedCount = serverPlacedCount + localAddedCount - localRemovedCount

	return math.max(0, realTimePlacedCount)
end

function M:GetRealTimeAvailableCount(furnitureId)
	if not furnitureId then
		return 0
	end

	local furnitureInfoDict = gPlayerManager.infoMinor.bindData.housesInfo.FurnitureInfoDict
	local furnitureInfo = furnitureInfoDict[furnitureId]
	local totalCount = furnitureInfo and furnitureInfo.Count or 0
	local realTimePlacedCount = self:GetRealTimePlacedCount(furnitureId)
	local availableCount = totalCount - realTimePlacedCount

	return availableCount
end

function M:RecordServerFurnitureState(serverPlacedInstanceId, furnitureId, position, rotation, parentId)
	self.serverSyncState[serverPlacedInstanceId] = {
		furnitureId = furnitureId,
		position = {
			x = position.x,
			y = position.y,
			z = position.z
		},
		rotation = {
			x = rotation.x,
			y = rotation.y,
			z = rotation.z
		},
		parentId = parentId or 0
	}
end

function M:MapClientToServerUID(clientUID, serverPlacedInstanceId)
	self.clientToServerUidMap[clientUID] = serverPlacedInstanceId
	self.serverToClientUidMap[serverPlacedInstanceId] = clientUID
	gFurnitureManager.uniqueIdCounter = math.max(gFurnitureManager.uniqueIdCounter, clientUID)
end

function M:RecordAddedFurniture(clientUID, furnitureId, position, rotation, parentClientUID)
	local parentServerInstanceId = 0

	if parentClientUID then
		parentServerInstanceId = self.clientToServerUidMap[parentClientUID] or 0
	end

	self.pendingChanges.added[clientUID] = {
		furnitureId = furnitureId,
		position = {
			x = position.x,
			y = position.y,
			z = position.z
		},
		rotation = {
			x = rotation.x,
			y = rotation.y,
			z = rotation.z
		},
		parentServerInstanceId = parentServerInstanceId
	}

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_NUM_CHANGE)
end

function M:RecordChangedFurniture(clientUID, position, rotation, parentClientUID)
	local serverPlacedInstanceId = self.clientToServerUidMap[clientUID]

	if serverPlacedInstanceId then
		local serverState = self.serverSyncState[serverPlacedInstanceId]

		if not serverState then
			print_warn(string.format("HouseManager: 无法找到服务端PlacedInstanceId[%d]的状态记录", serverPlacedInstanceId))

			return
		end

		local hasPositionChange = math.abs(serverState.position.x - position.x) > 0.01 or math.abs(serverState.position.y - position.y) > 0.01 or math.abs(serverState.position.z - position.z) > 0.01
		local hasRotationChange = math.abs(serverState.rotation.x - rotation.x) > 0.01 or math.abs(serverState.rotation.y - rotation.y) > 0.01 or math.abs(serverState.rotation.z - rotation.z) > 0.01
		local newParentServerInstanceId = 0

		if parentClientUID then
			newParentServerInstanceId = self.clientToServerUidMap[parentClientUID] or 0
		end

		local hasParentChange = serverState.parentId ~= newParentServerInstanceId

		if hasPositionChange or hasRotationChange or hasParentChange then
			local oldPosition = Vector3.New(serverState.position.x, serverState.position.y, serverState.position.z)
			local oldRotation = Vector3.New(serverState.rotation.x, serverState.rotation.y, serverState.rotation.z)
			local newPosition = Vector3.New(position.x, position.y, position.z)
			local newRotation = Vector3.New(rotation.x, rotation.y, rotation.z)
			self.pendingChanges.changed[clientUID] = {
				serverPlacedInstanceId = serverPlacedInstanceId,
				position = {
					x = position.x,
					y = position.y,
					z = position.z
				},
				rotation = {
					x = rotation.x,
					y = rotation.y,
					z = rotation.z
				},
				parentServerInstanceId = newParentServerInstanceId,
				isChangeParentNode = hasParentChange
			}

			if hasPositionChange or hasRotationChange then
				self:UpdateCarriedFurnitureRecursively(clientUID, oldPosition, oldRotation, newPosition, newRotation)
			end
		end

		return
	end

	local addedFurnitureInfo = self.pendingChanges.added[clientUID]

	if addedFurnitureInfo then
		local hasPositionChange = math.abs(addedFurnitureInfo.position.x - position.x) > 0.01 or math.abs(addedFurnitureInfo.position.y - position.y) > 0.01 or math.abs(addedFurnitureInfo.position.z - position.z) > 0.01
		local hasRotationChange = math.abs(addedFurnitureInfo.rotation.x - rotation.x) > 0.01 or math.abs(addedFurnitureInfo.rotation.y - rotation.y) > 0.01 or math.abs(addedFurnitureInfo.rotation.z - rotation.z) > 0.01
		local newParentServerInstanceId = 0

		if parentClientUID then
			newParentServerInstanceId = self.clientToServerUidMap[parentClientUID] or 0
		end

		local hasParentChange = addedFurnitureInfo.parentServerInstanceId ~= newParentServerInstanceId

		if hasPositionChange or hasRotationChange or hasParentChange then
			local oldPosition = Vector3.New(addedFurnitureInfo.position.x, addedFurnitureInfo.position.y, addedFurnitureInfo.position.z)
			local oldRotation = Vector3.New(addedFurnitureInfo.rotation.x, addedFurnitureInfo.rotation.y, addedFurnitureInfo.rotation.z)
			local newPosition = Vector3.New(position.x, position.y, position.z)
			local newRotation = Vector3.New(rotation.x, rotation.y, rotation.z)
			addedFurnitureInfo.position = {
				x = position.x,
				y = position.y,
				z = position.z
			}
			addedFurnitureInfo.rotation = {
				x = rotation.x,
				y = rotation.y,
				z = rotation.z
			}
			addedFurnitureInfo.parentServerInstanceId = newParentServerInstanceId

			if hasPositionChange or hasRotationChange then
				self:UpdateCarriedFurnitureRecursively(clientUID, oldPosition, oldRotation, newPosition, newRotation)
			end
		end

		return
	end

	print_warn(string.format("HouseManager: 无法找到客户端UID[%d]的家具记录，既不在服务端状态中也不在待添加列表中", clientUID))
end

function M:UpdateCarriedFurnitureRecursively(parentUID, oldParentPosition, oldParentRotation, newParentPosition, newParentRotation)
	if not parentUID then
		return
	end

	local carriedUIDs = gFurnitureManager.carryUid2AdsUidListDict[parentUID]

	if not carriedUIDs or #carriedUIDs == 0 then
		return
	end

	local oldParentQuaternion = Quaternion.Euler(oldParentRotation.x, oldParentRotation.y, oldParentRotation.z)
	local newParentQuaternion = Quaternion.Euler(newParentRotation.x, newParentRotation.y, newParentRotation.z)

	for _, childUID in ipairs(carriedUIDs) do
		local childServerPlacedInstanceId = self.clientToServerUidMap[childUID]
		local childCurrentPosition, childCurrentRotation = nil
		local childGameObject = gFurnitureManager.uid2FurnitureGoDict[childUID]
		local newChildPosition, newChildRotation = nil

		if childGameObject and not gCS.LuaUtils.IsNull(childGameObject) then
			newChildPosition = childGameObject.transform.position
			newChildRotation = childGameObject.transform.rotation.eulerAngles
		else
			local relativePosition = childCurrentPosition - oldParentPosition
			local relativeRotation = Quaternion.Inverse(oldParentQuaternion) * Quaternion.Euler(childCurrentRotation.x, childCurrentRotation.y, childCurrentRotation.z)
			newChildPosition = newParentPosition + newParentQuaternion * relativePosition
			local newChildQuaternion = newParentQuaternion * relativeRotation
			newChildRotation = newChildQuaternion.eulerAngles
		end

		self:RecordChangedFurniture(childUID, newChildPosition, newChildRotation, parentUID)
		self:UpdateCarriedFurnitureRecursively(childUID, childCurrentPosition, childCurrentRotation, newChildPosition, newChildRotation)
	end
end

function M:RecordRemovedFurniture(clientUID)
	local serverPlacedInstanceId = self.clientToServerUidMap[clientUID]

	if serverPlacedInstanceId then
		local serverState = self.serverSyncState[serverPlacedInstanceId]

		if serverState then
			self.pendingChanges.removed[clientUID] = {
				serverPlacedInstanceId = serverPlacedInstanceId,
				furnitureId = serverState.furnitureId,
				position = {
					x = serverState.position.x,
					y = serverState.position.y,
					z = serverState.position.z
				},
				rotation = {
					x = serverState.rotation.x,
					y = serverState.rotation.y,
					z = serverState.rotation.z
				},
				parentId = serverState.parentId
			}
		end
	end

	if self.pendingChanges.changed[clientUID] then
		self.pendingChanges.changed[clientUID] = nil
	end

	if self.pendingChanges.added[clientUID] then
		self.pendingChanges.added[clientUID] = nil
	end

	self.clientToServerUidMap[clientUID] = nil

	if serverPlacedInstanceId then
		self.serverToClientUidMap[serverPlacedInstanceId] = nil
		self.serverSyncState[serverPlacedInstanceId] = nil
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_NUM_CHANGE)
end

function M:SyncAllChangesToServer()
	local houseId = self:GetCurHouseId()

	if not houseId or houseId == 0 then
		print_error("HouseManager: 无法获取当前房屋ID")

		return false
	end

	local floor = 0
	local hasChanges = false

	if next(self.pendingChanges.removed) then
		local removePlacedInstanceIdList = {}

		for clientUID, removedInfo in pairs(self.pendingChanges.removed) do
			local serverPlacedInstanceId = removedInfo.serverPlacedInstanceId

			table.insert(removePlacedInstanceIdList, ulong.new(serverPlacedInstanceId, 0))
		end

		if #removePlacedInstanceIdList > 0 then
			hasChanges = true

			self:RemoveFurnitureInfo(floor, removePlacedInstanceIdList)
		end
	end

	if next(self.pendingChanges.added) then
		for clientUID, addInfo in pairs(self.pendingChanges.added) do
			hasChanges = true

			self:AskAddBuildHouseIndoor(floor, addInfo, clientUID)
		end
	end

	if next(self.pendingChanges.changed) then
		for clientUID, changeInfo in pairs(self.pendingChanges.changed) do
			hasChanges = true

			self:ChangeFurnitureInfo(floor, changeInfo)
		end
	end

	if hasChanges then
		gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_NUM_CHANGE)
	end

	return hasChanges
end

function M:ClearPendingChanges()
	self.pendingChanges = {
		added = {},
		changed = {},
		removed = {}
	}

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_NUM_CHANGE)
end

function M:ChangeFurnitureInfo(floor, changeInfo)
	local houseId = self:GetCurHouseId()

	if not houseId or houseId == 0 then
		print_error("HouseManager: 无法获取当前房屋ID")

		return
	end

	local changePlacedFurnitureInfo = {
		PlacedInstanceId = ulong.new(changeInfo.serverPlacedInstanceId, 0),
		IsChangeParentNode = changeInfo.isChangeParentNode,
		ParentPlacedInstanceId = ulong.new(changeInfo.parentServerInstanceId, 0),
		Position = {
			X = changeInfo.position.x,
			Y = changeInfo.position.y,
			Z = changeInfo.position.z
		},
		Rotation = {
			X = changeInfo.rotation.x,
			Y = changeInfo.rotation.y,
			Z = changeInfo.rotation.z
		}
	}

	gClientToGameDelegate:AskChangeBuildHouseIndoor(houseId, floor, changePlacedFurnitureInfo).Callback = function (result, data)
		if result == 0 then
			local serverState = self.serverSyncState[changeInfo.serverPlacedInstanceId]

			if serverState then
				serverState.position = changeInfo.position
				serverState.rotation = changeInfo.rotation
				serverState.parentId = changeInfo.parentServerInstanceId
			end

			self:ModifyOneFurnitureInfo({
				FurnitureId = serverState.furnitureId,
				Position = changeInfo.position,
				Rotation = changeInfo.rotation,
				PlacedInstanceId = changeInfo.serverPlacedInstanceId,
				ParentPlacedInstanceId = changeInfo.parentServerInstanceId
			})
		else
			print_error(string.format("HouseManager: 修改家具失败，PlacedInstanceId: %d, 错误码: %d", changeInfo.serverPlacedInstanceId, result))
			gDisplayMessageMgr:ShowMessage(result)
		end
	end
end

function M:RemoveFurnitureInfo(floor, removePlacedInstanceIdList)
	local houseId = self:GetCurHouseId()

	if not houseId or houseId == 0 then
		print_error("HouseManager: 无法获取当前房屋ID")

		return
	end

	gClientToGameDelegate:AskRemoveBuildHouseIndoor(houseId, floor, removePlacedInstanceIdList).Callback = function (result, data)
		if result == 0 then
			for _, serverPlacedInstanceId in ipairs(removePlacedInstanceIdList) do
				self.serverSyncState[serverPlacedInstanceId] = nil

				self:RemoveOneFurnitureInfo(serverPlacedInstanceId)
			end
		else
			print_error(string.format("HouseManager: 删除家具失败，错误码: %d", result))
			gDisplayMessageMgr:ShowMessage(result)
		end
	end
end

function M:AskAddBuildHouseIndoor(floor, addInfo, clientUID)
	local houseId = self:GetCurHouseId()

	if not houseId or houseId == 0 then
		print_error("HouseManager: 无法获取当前房屋ID")

		return
	end

	local addPlacedFurnitureInfo = {
		ParentPlacedInstanceId = addInfo.parentServerInstanceId,
		FurnitureId = addInfo.furnitureId,
		Position = {
			X = addInfo.position.x,
			Y = addInfo.position.y,
			Z = addInfo.position.z
		},
		Rotation = {
			X = addInfo.rotation.x,
			Y = addInfo.rotation.y,
			Z = addInfo.rotation.z
		}
	}

	gClientToGameDelegate:AskAddBuildHouseIndoor(houseId, floor, addPlacedFurnitureInfo).Callback = function (result, data)
		if result == 0 and data then
			gFurnitureUtils:ProcessServerFurnitureData(data)

			local serverPlacedInstanceId = data.PlacedInstanceId

			self:MapClientToServerUID(clientUID, serverPlacedInstanceId)
			self:RecordServerFurnitureState(serverPlacedInstanceId, addInfo.furnitureId, addInfo.position, addInfo.rotation, addInfo.parentServerInstanceId)

			local gadgetInstanceId = data.GadgetInstanceId
			local carrySurfaceUID = nil

			if addInfo.parentServerInstanceId and addInfo.parentServerInstanceId ~= 0 then
				carrySurfaceUID = self.serverToClientUidMap[addInfo.parentServerInstanceId] or addInfo.parentServerInstanceId
			end

			gFurnitureManager:SpawnFurnitureFromServerData(addInfo.furnitureId, addInfo.position, addInfo.rotation, clientUID, gadgetInstanceId, carrySurfaceUID)
			self:AddOneFurnitureInfo({
				FurnitureId = addInfo.furnitureId,
				Position = addInfo.position,
				Rotation = addInfo.rotation,
				GadgetInstanceId = gadgetInstanceId,
				PlacedInstanceId = serverPlacedInstanceId,
				ParentPlacedInstanceId = addInfo.parentServerInstanceId
			})
		else
			print_error(string.format("HouseManager: 添加家具失败，FurnitureId: %d, 错误码: %s", addInfo.furnitureId, tostring(result)))
			gDisplayMessageMgr:ShowMessage(result)
		end
	end
end

function M:GetOneFloorFurnitureInfos(floor)
	local houseInfoList = gPlayerManager.infoMinor.bindData.housesInfo
	local houseInfo = nil

	for k, v in ipairs(houseInfoList.HouseInfoList) do
		if v.HouseId == self.houseId then
			houseInfo = v

			break
		end
	end

	local indoorBuildInfo = houseInfo.FloorBuildInfoDict[floor]

	return indoorBuildInfo.Root.ChildrenDict
end

function M:FindFurnitureInfoRecursively(placedInstanceId, floor)
	floor = floor or 0
	local ulongPlacedInstanceId = type(placedInstanceId) ~= "number" and placedInstanceId or ulong.new(placedInstanceId, 0)
	local topLevelInfos = self:GetOneFloorFurnitureInfos(floor)

	local function SearchRecursively(furnitureDict, parentInfo)
		if not furnitureDict then
			return nil, nil
		end

		for key, furnitureInfo in pairs(furnitureDict) do
			if key == ulongPlacedInstanceId or furnitureInfo.PlacedInstanceId and ulong.new(furnitureInfo.PlacedInstanceId, 0) == ulongPlacedInstanceId then
				return furnitureInfo, parentInfo
			end

			if furnitureInfo.ChildrenDict and next(furnitureInfo.ChildrenDict) then
				local found, foundParent = SearchRecursively(furnitureInfo.ChildrenDict, furnitureInfo)

				if found then
					return found, foundParent
				end
			end
		end

		return nil, nil
	end

	return SearchRecursively(topLevelInfos, nil)
end

function M:SetFurnitureInfoRecursively(placedInstanceId, newFurnitureInfo, floor)
	floor = floor or 0
	local ulongPlacedInstanceId = type(placedInstanceId) ~= "number" and placedInstanceId or ulong.new(placedInstanceId, 0)
	local existingInfo, parentInfo = self:FindFurnitureInfoRecursively(placedInstanceId, floor)

	if parentInfo then
		if parentInfo.ChildrenDict then
			parentInfo.ChildrenDict[ulongPlacedInstanceId] = newFurnitureInfo
		else
			parentInfo.ChildrenDict = {
				[ulongPlacedInstanceId] = newFurnitureInfo
			}
		end

		return true
	else
		local topLevelInfos = self:GetOneFloorFurnitureInfos(floor)
		topLevelInfos[ulongPlacedInstanceId] = newFurnitureInfo

		return true
	end
end

function M:RemoveFurnitureInfoRecursively(placedInstanceId, floor)
	floor = floor or 0
	local ulongPlacedInstanceId = type(placedInstanceId) ~= "number" and placedInstanceId or ulong.new(placedInstanceId, 0)
	local existingInfo, parentInfo = self:FindFurnitureInfoRecursively(placedInstanceId, floor)

	if not existingInfo then
		return false
	end

	if parentInfo then
		if parentInfo.ChildrenDict and parentInfo.ChildrenDict[ulongPlacedInstanceId] then
			parentInfo.ChildrenDict[ulongPlacedInstanceId] = nil

			return true
		end
	else
		local topLevelInfos = self:GetOneFloorFurnitureInfos(floor)

		if topLevelInfos[ulongPlacedInstanceId] then
			topLevelInfos[ulongPlacedInstanceId] = nil

			return true
		end
	end

	return false
end

function M:AddOneFurnitureInfo(info)
	local furnitureInfo = {
		FurnitureId = info.FurnitureId,
		Position = {
			X = info.Position.x,
			Y = info.Position.y,
			Z = info.Position.z
		},
		Rotation = {
			X = info.Rotation.x,
			Y = info.Rotation.y,
			Z = info.Rotation.z
		},
		GadgetInstanceId = info.GadgetInstanceId or 0,
		PlacedInstanceId = info.PlacedInstanceId or 0,
		ParentPlacedInstanceId = info.ParentPlacedInstanceId or 0,
		ChildrenDict = {}
	}
	local placedInstanceId = ulong.new(info.PlacedInstanceId, 0)

	if furnitureInfo.ParentPlacedInstanceId and furnitureInfo.ParentPlacedInstanceId ~= 0 then
		local parentInfo, _ = self:FindFurnitureInfoRecursively(furnitureInfo.ParentPlacedInstanceId, 0)

		if parentInfo then
			if not parentInfo.ChildrenDict then
				parentInfo.ChildrenDict = {}
			end

			parentInfo.ChildrenDict[placedInstanceId] = furnitureInfo
		else
			print_warn(string.format("HouseManager: 无法找到父家具[%d]，将作为顶级家具添加", furnitureInfo.ParentPlacedInstanceId))

			local topLevelInfos = self:GetOneFloorFurnitureInfos(0)
			topLevelInfos[placedInstanceId] = furnitureInfo
		end
	else
		local topLevelInfos = self:GetOneFloorFurnitureInfos(0)
		topLevelInfos[placedInstanceId] = furnitureInfo
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_NUM_CHANGE)
end

function M:RemoveOneFurnitureInfo(placedInstanceId)
	local furnitureInfo, parentInfo = self:FindFurnitureInfoRecursively(placedInstanceId, 0)

	if furnitureInfo then
		local furnitureId = furnitureInfo.FurnitureId

		if self:RemoveFurnitureInfoRecursively(placedInstanceId, 0) then
			gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_NUM_CHANGE)
		else
			print_warn("HouseManager: 删除家具信息失败", placedInstanceId)
		end
	else
		print_warn("HouseManager: 无法找到PlacedInstanceId的家具信息", placedInstanceId)
	end
end

function M:ModifyOneFurnitureInfo(info)
	gFurnitureUtils:ProcessServerFurnitureData(info)

	local placedInstanceId = ulong.new(info.PlacedInstanceId, 0)
	local furnitureInfo, parentInfo = self:FindFurnitureInfoRecursively(placedInstanceId, 0)

	if furnitureInfo then
		local oldParentId = furnitureInfo.ParentPlacedInstanceId or 0
		local newParentId = info.ParentPlacedInstanceId or 0
		furnitureInfo.Position = {
			X = info.Position.x,
			Y = info.Position.y,
			Z = info.Position.z
		}
		furnitureInfo.Rotation = {
			X = info.Rotation.x,
			Y = info.Rotation.y,
			Z = info.Rotation.z
		}
		furnitureInfo.ParentPlacedInstanceId = newParentId

		if oldParentId ~= newParentId then
			if oldParentId == 0 then
				local topLevelInfos = self:GetOneFloorFurnitureInfos(0)
				topLevelInfos[placedInstanceId] = nil
			elseif parentInfo and parentInfo.ChildrenDict then
				parentInfo.ChildrenDict[placedInstanceId] = nil
			end

			if newParentId == 0 then
				local topLevelInfos = self:GetOneFloorFurnitureInfos(0)
				topLevelInfos[placedInstanceId] = furnitureInfo
			else
				local newParentInfo, _ = self:FindFurnitureInfoRecursively(newParentId, 0)

				if newParentInfo then
					if not newParentInfo.ChildrenDict then
						newParentInfo.ChildrenDict = {}
					end

					newParentInfo.ChildrenDict[placedInstanceId] = furnitureInfo
				else
					print_warn(string.format("HouseManager: 无法找到新的父家具[%d]，将家具[%d]放置为顶级家具", newParentId, placedInstanceId))

					furnitureInfo.ParentPlacedInstanceId = 0
					local topLevelInfos = self:GetOneFloorFurnitureInfos(0)
					topLevelInfos[placedInstanceId] = furnitureInfo
				end
			end
		else
			self:SetFurnitureInfoRecursively(placedInstanceId, furnitureInfo, 0)
		end
	else
		print_warn("HouseManager: 无法找到PlacedInstanceId的家具信息", placedInstanceId)
	end
end

function M:ResetFurnitureToServerState()
	if not self.targetIndoorIds[self.currentIndoorId] then
		return false
	end

	self:ClearPendingChanges()
	gFurnitureManager:RemoveAllFurniture()

	self.serverSyncState = {}
	self.clientToServerUidMap = {}
	self.serverToClientUidMap = {}
	local houseInfoList = gPlayerManager.infoMinor.bindData.housesInfo
	local cfg = self.targetIndoorIds[self.currentIndoorId]
	local houseInfo = nil

	for k, v in ipairs(houseInfoList.HouseInfoList) do
		local houseCfg = HouseConfig.GetConfig(v.HouseId)

		if houseCfg.BuildId == cfg.Id then
			houseInfo = v

			break
		end
	end

	if not houseInfo then
		return false
	end

	for k, v in pairs(houseInfo.FloorBuildInfoDict) do
		local indoorBuildInfo = v
		local furnitureDict = indoorBuildInfo.Root.ChildrenDict
		local processedFurnitures = {}

		for key, furnitureInfo in pairs(furnitureDict) do
			gFurnitureUtils:ProcessServerFurnitureData(furnitureInfo)

			processedFurnitures[key] = furnitureInfo
		end

		local loadedFurnitureIds = {}

		local function LoadFurnitureRecursively(furnitureInfo, parentId)
			local furnitureId = furnitureInfo.PlacedInstanceId

			if loadedFurnitureIds[furnitureId] then
				return
			end

			loadedFurnitureIds[furnitureId] = true

			self:CreateFurnitureFromServerData(furnitureInfo, parentId)

			if furnitureInfo.ChildrenDict and next(furnitureInfo.ChildrenDict) then
				for childKey, childFurnitureInfo in pairs(furnitureInfo.ChildrenDict) do
					gFurnitureUtils:ProcessServerFurnitureData(childFurnitureInfo)
					LoadFurnitureRecursively(childFurnitureInfo, furnitureInfo.PlacedInstanceId)
				end
			end
		end

		for key, furnitureInfo in pairs(processedFurnitures) do
			local parentId = furnitureInfo.ParentPlacedInstanceId or 0

			if parentId == 0 then
				LoadFurnitureRecursively(furnitureInfo, 0)
			end
		end
	end

	return true
end

function M:GetCurRoomPos()
	return self.roomPosition
end

gHouseManager = gHouseManager or M.New()
