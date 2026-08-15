MapSubSystem_Gadget = DefClass("MapSubSystem_Gadget", MapSubSystem_Gadget, MapSubSystemBase)
local M = MapSubSystem_Gadget
local Vector3 = Vector3
local math = math
local table = table
local VENDING_MIN_DIST = LTConfig.GpsConfig.VendingMinDist

function M:OnInit()
	self._eventHandlers = {
		[gEventConstants.ON_GADGET_SLOT_COMP_LOADED] = function (eventId, luaEntityId)
			self:OnGadgetLoaded(luaEntityId)
		end,
		[gEventConstants.MAP_SCALE_UPDATE_TO_MAP] = function ()
			self:RefreshVisibleVendings()
		end
	}
end

function M:OnLoadData()
	self:InitVending()
end

function M:OnSceneInit()
	gMessageManager:RegisterEventHandlers(self._eventHandlers)
end

function M:OnSceneDestroy()
	gMessageManager:UnregisterEventHandlers(self._eventHandlers)
	table.clear(self._vendingInfos)
	table.clear(self._vendingChunks)
end

function M:OnGadgetLoaded(luaEntityId)
	local entity = gGadgetManager:GetEntitySearchByInstanceId(luaEntityId)

	if entity then
		local gadgetName = entity.gameObject.name

		if self:IsVending(gadgetName) then
			self:OnVendingMachineLoaded(luaEntityId, entity, gadgetName)
		end
	end
end

function M:Tick()
	self:TickVendingMachine()
end

function M:IsNotFullHp()
	return gDataSetManager.myUnit.maxhp - gDataSetManager.myUnit.hp > 1
end

function M:InitVending()
	self.VENDING_DIST = 200
	self._vendingInfos = {}
	self._visibleVendingCount = 0
	self._vendingNames = {}

	for _, name in pairs(LTConfig.GpsConfig.VendingMachineList) do
		self._vendingNames[name] = true
	end

	for _, name in pairs(LTConfig.GpsConfig.HealBoothList) do
		self._vendingNames[name] = true
	end

	self._vendingChunks = {}
	self._vendingLastUpdatePos = Vector3.zero

	if not self._sharedVendingElements then
		self._sharedVendingElements = {}

		for i = 1, 3 do
			local element = MapElement.CreateLegacy(EMapElementType.Gadget, "VendingMachineSharedElem" .. i, EMapSubSystemType.Gadget, EMapViewMask.MiniMap, gMapSystem.lastRaidId)
			element.mData.sIconId = 28001638

			element:SetVisible(false)

			self._sharedVendingElements[i] = element
		end
	end
end

function M:IsVending(gadgetName)
	return self._vendingNames[gadgetName]
end

function M:OnVendingMachineLoaded(luaEntityId, entity, name)
	if not self._vendingInfos[luaEntityId] then
		local info = {
			name = name,
			pos = entity.gameObject.transform.position:Clone(),
			raidId = gMapSystem.lastRaidId
		}
		self._vendingInfos[luaEntityId] = info

		self:AddVendingToChunk(luaEntityId, info)
	end
end

function M:RefreshVisibleVendings()
	if not self:IsNotFullHp() then
		return
	end

	for id, elem in pairs(self._sharedVendingElements) do
		elem:SetVisible(false)
	end

	self._vendingLastUpdatePos = gCS.MyPlayerManager.PlayerUnit.LocalPosition:Clone()
	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local nearbyMachines = {}

	for id, info in pairs(self:GetNearbyVendingInfos(playerPos)) do
		local distance = Vector3.Distance(playerPos, info.pos)

		if distance <= self.VENDING_DIST then
			table.insert(nearbyMachines, {
				pos = info.pos,
				distance = distance,
				raidId = info.raidId
			})
		end
	end

	local sharedElemIndex = 1

	if #nearbyMachines < 3 then
		for _, machine in pairs(nearbyMachines) do
			local elem = self._sharedVendingElements[sharedElemIndex]

			elem:SetRaidId(machine.raidId)
			elem:SetPosition(machine.pos)
			elem:SetVisible(true)

			sharedElemIndex = sharedElemIndex + 1
		end

		self._visibleVendingCount = #nearbyMachines

		return
	end

	table.sort(nearbyMachines, function (a, b)
		return a.distance < b.distance
	end)

	local firstMachine = nearbyMachines[1]
	local bestCombination = nil
	local minAngleDifference = math.huge
	local maxCount = math.min(20, #nearbyMachines)

	for j = 2, maxCount - 1 do
		for k = j + 1, maxCount do
			local p1 = firstMachine.pos
			local p2 = nearbyMachines[j].pos
			local p3 = nearbyMachines[k].pos
			local dist12 = Vector3.Distance(p1, p2)
			local dist23 = Vector3.Distance(p2, p3)
			local dist31 = Vector3.Distance(p3, p1)

			if dist12 >= VENDING_MIN_DIST and dist23 >= VENDING_MIN_DIST then
				if dist31 < VENDING_MIN_DIST then
					-- Nothing
				else
					local v1 = (p1 - playerPos).normalized
					local v2 = (p2 - playerPos).normalized
					local v3 = (p3 - playerPos).normalized
					local angle1 = math.acos(math.max(-1, math.min(1, Vector3.Dot(v1, v2)))) * 180 / math.pi
					local angle2 = math.acos(math.max(-1, math.min(1, Vector3.Dot(v2, v3)))) * 180 / math.pi
					local angle3 = math.acos(math.max(-1, math.min(1, Vector3.Dot(v3, v1)))) * 180 / math.pi
					local angleDifference = math.abs(angle1 - 120) + math.abs(angle2 - 120) + math.abs(angle3 - 120)

					if minAngleDifference > angleDifference then
						minAngleDifference = angleDifference
						bestCombination = {
							firstMachine,
							nearbyMachines[j],
							nearbyMachines[k]
						}
					end
				end
			end
		end
	end

	if bestCombination then
		for _, machine in ipairs(bestCombination) do
			local elem = self._sharedVendingElements[sharedElemIndex]

			elem:SetRaidId(machine.raidId)
			elem:SetPosition(machine.pos)
			elem:SetVisible(true)

			sharedElemIndex = sharedElemIndex + 1
		end
	end

	self._visibleVendingCount = 3
end

function M:TickVendingMachine()
	if not L50.L50App.Scene.GamePlayUtils or L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) or not gDataSetManager.myUnit then
		return
	end

	if not self:IsNotFullHp() then
		if self._visibleVendingCount > 0 then
			self._visibleVendingCount = 0

			for i = 1, 3 do
				local element = self._sharedVendingElements[i]

				element:SetVisible(false)
			end
		end

		return
	end

	local dist = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, self._vendingLastUpdatePos)

	if self._visibleVendingCount >= 3 and dist < 350 then
		return
	end

	self:RefreshVisibleVendings()
end

function M:GetVendingChunkKey(pos)
	local chunkX = math.floor(pos.x / self.VENDING_DIST)
	local chunkZ = math.floor(pos.z / self.VENDING_DIST)

	return chunkX .. "_" .. chunkZ
end

function M:AddVendingToChunk(luaEntityId, info)
	local chunkKey = self:GetVendingChunkKey(info.pos)

	if not self._vendingChunks[chunkKey] then
		self._vendingChunks[chunkKey] = {}
	end

	self._vendingChunks[chunkKey][luaEntityId] = info
end

function M:GetNearbyVendingInfos(playerPos)
	local nearbyInfos = {}
	local centerChunkX = math.floor(playerPos.x / self.VENDING_DIST)
	local centerChunkZ = math.floor(playerPos.z / self.VENDING_DIST)

	for dx = -1, 1 do
		for dz = -1, 1 do
			local chunkKey = centerChunkX + dx .. "_" .. centerChunkZ + dz
			local chunk = self._vendingChunks[chunkKey]

			if chunk then
				for id, info in pairs(chunk) do
					nearbyInfos[id] = info
				end
			end
		end
	end

	return nearbyInfos
end

return M
