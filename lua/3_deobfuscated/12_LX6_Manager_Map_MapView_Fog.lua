local RaidConfig = LTConfig.RaidConfig
MapView = MapView or {}
local M = MapView

function M:InitFog()
	self.enableFog = nil
end

function M:SetFogEnable(enable)
	if not self.enableFog ~= not enable then
		self.enableFog = enable

		self:RefreshStage(EMapViewStage.Fog)
	end
end

function M:InFog(instanceId)
	local item = self.items[instanceId]

	if not item then
		gGpsTools.Error(gGpsModule.SafeAssert, "MapView:IsInFog: Item not found for instanceId", instanceId)

		return true
	end

	if not self.enableFog or not self.type2Stage[EMapViewStage.Fog] then
		return false
	end

	if item.interestSourceCount > 0 or item.mapElement.fData.ignoreFog then
		return false
	end

	if item.sourceMap.trace then
		return false
	end

	local raidId = gMapSystem.area:SplitGBoundId(item.resolvedGBoundId)
	local raidCfg = RaidConfig.GetConfig(raidId)
	local sceneId = raidCfg and raidCfg.SceneId or nil

	if sceneId and gMapSystem.fogMap:IsUnlocked(sceneId, item.resolvedWorldPos.x, item.resolvedWorldPos.z) then
		return false
	else
		return true
	end
end
