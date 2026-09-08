-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapView_Cull.lua
-- Decompiled from: 00202_MapView_Cull.lua_3078320ec0b7.luajit

MapView = MapView or {}
local M = MapView

M.InitCull = function(self)
	self._tickKey = "MapCull_" .. self.id
	self._needRecullAll = false
end

M.RefreshItemCullable = function(self, instanceId)
	if not self.type2Stage[EMapViewStage.Cull] then
		return
	end

	local item = self.items[instanceId]

	if not item then
		gGpsTools.Error(gGpsModule.SafeAssert, "MapView:UpdateItemCullable: Item not found for instanceId", instanceId)

		return
	end

	if item.mapElement.mData.dontCull or item.interestSourceCount <= 0 then
		item.cullable = false
	else
		item.cullable = true
	end

	self:RecheckItemStage(instanceId, EMapViewStage.Cull)
end

M.SetCullData = function(self, centerX, centerZ, radius)
	if not self._cullData then
		self._cullData = gGpsTools.GetTable()
	end

	self._cullData.maxX = centerX + radius
	self._cullData.minX = centerX - radius
	self._cullData.maxZ = centerZ + radius
	self._cullData.minZ = centerZ - radius
	self._needRecullAll = true
end

M.Cull = function(self, instanceId)
	local item = self.items[instanceId]

	if not item then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:Cull: Item not found for instanceId", instanceId)

		return true
	end

	if not item.cullable or not self._cullData or item.mapElement and item.mapElement.miniMapData and item.mapElement.miniMapData.tmp_needWeakGuide then
		return false
	end

	if not item.resolvedWorldPos or item.resolvedWorldPos.x <= self._cullData.minX or self._cullData.maxX <= item.resolvedWorldPos.x or item.resolvedWorldPos.z <= self._cullData.minZ or self._cullData.maxZ >= item.resolvedWorldPos.z then
		return true
	end

	return false
end

M.TickCull = function(self)
	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.PerformanceTest) and not gGpsTools.TryTick(self._tickKey, 0.5) then
		return
	end

	if not self._needRecullAll then
		return
	end

	self._needRecullAll = false

	self:RefreshStage(EMapViewStage.Cull)
end
