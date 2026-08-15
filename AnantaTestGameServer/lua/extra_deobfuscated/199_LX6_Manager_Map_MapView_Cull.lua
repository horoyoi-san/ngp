MapView = MapView or {}
local M = MapView

function M:InitCull()
	self._tickKey = "MapCull_" .. self.id
	self._needRecullAll = false
end

function M:RefreshItemCullable(instanceId)
	if not self.type2Stage[EMapViewStage.Cull] then
		return
	end

	local item = self.items[instanceId]

	if not item then
		gGpsTools.Error(gGpsModule.SafeAssert, "MapView:UpdateItemCullable: Item not found for instanceId", instanceId)

		return
	end

	if item.mapElement.mData.dontCull or item.interestSourceCount > 0 then
		item.cullable = false
	else
		item.cullable = true
	end

	self:RecheckItemStage(instanceId, EMapViewStage.Cull)
end

function M:SetCullData(centerX, centerZ, radius)
	if not self._cullData then
		self._cullData = gGpsTools.GetTable()
	end

	self._cullData.maxX = centerX + radius
	self._cullData.minX = centerX - radius
	self._cullData.maxZ = centerZ + radius
	self._cullData.minZ = centerZ - radius
	self._needRecullAll = true
end

function M:Cull(instanceId)
	local item = self.items[instanceId]

	if not item then
		gGpsTools.Assert(gGpsModule.SafeAssert, "MapView:Cull: Item not found for instanceId", instanceId)

		return true
	end

	if not item.cullable or not self._cullData or item.mapElement.miniMapData.tmp_needWeakGuide then
		return false
	end

	if not item.resolvedWorldPos or item.resolvedWorldPos.x < self._cullData.minX or self._cullData.maxX < item.resolvedWorldPos.x or item.resolvedWorldPos.z < self._cullData.minZ or self._cullData.maxZ < item.resolvedWorldPos.z then
		return true
	end

	return false
end

function M:TickCull()
	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.PerformanceTest) and not gGpsTools.TryTick(self._tickKey, 0.5) then
		return
	end

	if not self._needRecullAll then
		return
	end

	self._needRecullAll = false

	self:RefreshStage(EMapViewStage.Cull)
end
