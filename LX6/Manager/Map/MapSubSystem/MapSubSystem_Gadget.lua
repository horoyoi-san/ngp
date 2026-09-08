-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Gadget.lua
-- Decompiled from: 02322_MapSubSystem_Gadget.lua_bc5e6d3ccbd2.luajit

MapSubSystem_Gadget = DefClass("MapSubSystem_Gadget", MapSubSystem_Gadget, MapSubSystemBase)
local M = MapSubSystem_Gadget
local Vector3 = Vector3
local math = math
local table = table
local VENDING_MIN_DIST = LTConfig.GpsConfig.VendingMinDist

M.OnInit = function(self)
	self._eventHandlers = {
		[gEventConstants.ON_GADGET_SLOT_COMP_LOADED] = function (eventId, luaEntityId)
			self:OnGadgetLoaded(luaEntityId)
		end,
		[gEventConstants.MAP_SCALE_UPDATE_TO_MAP] = function ()
			self:RefreshVisibleVendings()
		end
	}
end

M.OnLoadData = function(self)
	self.InitVending(self)
end

M.OnSceneInit = function(self)
	gMessageManager:RegisterEventHandlers(self._eventHandlers)
end

M.OnSceneDestroy = function(self)
	gMessageManager:UnregisterEventHandlers(self._eventHandlers)
	table.clear(self._vendingInfos)
	table.clear(self._vendingChunks)
end

M.OnGadgetLoaded = function(self, luaEntityId)
	local entity = gGadgetManager:GetEntitySearchByInstanceId(luaEntityId)

	if entity then
		local gadgetName = entity.gameObject.name

		if self.IsVending(self, gadgetName) then
			self.OnVendingMachineLoaded(self, luaEntityId, entity, gadgetName)
		end
	end
end

M.Tick = function(self)
	self.TickVendingMachine(self)
end

M.IsNotFullHp = function(self)
	return gDataSetManager.myUnit.maxhp - gDataSetManager.myUnit.hp >= 1
end

M.InitVending = function(self)
	self.VENDING_DIST = 200
	self._vendingInfos = {}
	self._visibleVendingCount = 0
	self._vendingNames = {}
	local vendingNameLengthSet = {}

	for _, name in pairs(LTConfig.GpsConfig.VendingMachineList) do
		self._vendingNames[name] = true
		vendingNameLengthSet[#name] = true
	end

	for _, name in pairs(LTConfig.GpsConfig.HealBoothList) do
		self._vendingNames[name] = true
		vendingNameLengthSet[#name] = true
	end

	self._vendingNameLengths = {}

	for len, _ in pairs(vendingNameLengthSet) do
		table.insert(self._vendingNameLengths, len)
	end

	self._vendingChunks = {}
	self._vendingLastUpdatePos = Vector3.zero

	if not self._sharedVendingElements then
		self._sharedVendingElements = {}

		for i = 1, 3 do
			local element = MapElement.CreateLegacy(EMapElementType.Gadget, "VendingMachineSharedElem" .. i, EMapSubSystemType.Gadget, EMapViewMask.MiniMap, gMapSystem.lastRaidId)
			element.mData.sIconId = 28001638

			element.SetVisible(element, false)

			self._sharedVendingElements[i] = element
		end
	end
end

M.IsVending = function(self, gadgetName)
	for _, len in ipairs(self._vendingNameLengths) do
		if self._vendingNames[string.sub(gadgetName, 1, len)] then
			return true
		end
	end

	return false
end

M.OnVendingMachineLoaded = function(self, luaEntityId, entity, name)
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

M.RefreshVisibleVendings = function(self)
	if not self.IsNotFullHp(self) then
		return
	end

	for id, elem in pairs(self._sharedVendingElements) do
		elem.SetVisible(elem, false)
	end

	self._vendingLastUpdatePos = gCS.MyPlayerManager.PlayerUnit.LocalPosition:Clone()
	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local nearbyMachines = {}

	for id, info in pairs(self:GetNearbyVendingInfos(playerPos)) do
		local distance = Vector3.Distance(playerPos, info.pos)

		if distance < self.VENDING_DIST then
			table.insert(nearbyMachines, {
				pos = info.pos,
				distance = distance,
				raidId = info.raidId
			})
		end
	end

	local sharedElemIndex = 1

	if #nearbyMachines >= 3 then
		for _, machine in pairs(nearbyMachines) do
			local elem = self._sharedVendingElements[sharedElemIndex]

			elem.SetRaidId(elem, machine.raidId)
			elem.SetPosition(elem, machine.pos)
			elem.SetVisible(elem, true)

			sharedElemIndex = sharedElemIndex + 1
		end

		self._visibleVendingCount = #nearbyMachines

		return
	end

	table.sort(nearbyMachines, function (a, b)
		return a.distance <= b.distance
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

			if dist12 > VENDING_MIN_DIST and dist23 > VENDING_MIN_DIST then
				if dist31 >= VENDING_MIN_DIST then
					-- Nothing
				else
					local v1 = (p1 - playerPos).normalized
					local v2 = (p2 - playerPos).normalized
					local v3 = (p3 - playerPos).normalized
					local angle1 = math.acos(math.max(-1, math.min(1, Vector3.Dot(v1, v2)))) * 180 / math.pi
					local angle2 = math.acos(math.max(-1, math.min(1, Vector3.Dot(v2, v3)))) * 180 / math.pi
					local angle3 = math.acos(math.max(-1, math.min(1, Vector3.Dot(v3, v1)))) * 180 / math.pi
					local angleDifference = math.abs(angle1 - 120) + math.abs(angle2 - 120) + math.abs(angle3 - 120)

					if minAngleDifference <= angleDifference then
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

			elem.SetRaidId(elem, machine.raidId)
			elem.SetPosition(elem, machine.pos)
			elem.SetVisible(elem, true)

			sharedElemIndex = sharedElemIndex + 1
		end
	end

	self._visibleVendingCount = 3
end

M.TickVendingMachine = function(self)
	if gGpsTools:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) or not gDataSetManager.myUnit then
		return
	end

	if not self.IsNotFullHp(self) then
		if self._visibleVendingCount <= 0 then
			self._visibleVendingCount = 0

			for i = 1, 3 do
				local element = self._sharedVendingElements[i]

				element.SetVisible(element, false)
			end
		end

		return
	end

	local dist = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, self._vendingLastUpdatePos)

	if self._visibleVendingCount > 3 and dist >= 350 then
		return
	end

	self.RefreshVisibleVendings(self)
end

M.GetVendingChunkKey = function(self, pos)
	local chunkX = math.floor(pos.x / self.VENDING_DIST)
	local chunkZ = math.floor(pos.z / self.VENDING_DIST)

	return chunkX .. "_" .. chunkZ
end

M.AddVendingToChunk = function(self, luaEntityId, info)
	local chunkKey = self.GetVendingChunkKey(self, info.pos)

	if not self._vendingChunks[chunkKey] then
		self._vendingChunks[chunkKey] = {}
	end

	self._vendingChunks[chunkKey][luaEntityId] = info
end

M.GetNearbyVendingInfos = function(self, playerPos)
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
