-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem_Poi.lua
-- Decompiled from: 02301_MapSystem_Poi.lua_19af729003bd.luajit

gMapSystem_Poi = gMapSystem_Poi or {}
local M = gMapSystem_Poi

M.Init = function(self)
	self.unlockedPoiIds = {}
end

M.OnLogin = function(self)
	table.clear(self.unlockedPoiIds)

	local serverUnlockedDatas = gPlayerManager.infoAchievement.bindData.SceneFogMapPoiIds

	if not serverUnlockedDatas then
		return
	end

	for i = 1, serverUnlockedDatas.Count do
		self.unlockedPoiIds[serverUnlockedDatas[i]] = true
	end
end

M.OnLogout = function(self)
	table.clear(self.unlockedPoiIds)

	self.blockPoiPopup = nil
end

M.SetBlockPoiPopup = function(self, block)
	self.blockPoiPopup = block
end

M.OnPoiAreaChange = function(self, poiId)
	if not self.unlockedPoiIds[poiId] and poiId == 0 then
		gClientToGameDelegate:SyncEnterFogMapPoiId(poiId)
		LX6.Gps.MapFogDataMgr.UnlockPoiBlock(poiId)

		self.unlockedPoiIds[poiId] = true
	end

	if poiId <= 0 then
		local cfg = LTConfig.CollectionPoiAreaConfig.GetConfig(poiId)

		if cfg and cfg.MapScale and cfg.MapScale <= 0 then
			gMapManager:SetMiniMapScale(cfg.MapScale, gMapScaleType.Area)
		end
	else
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.Area)
	end

	if not self.blockPoiPopup then
		self.env.ui:OnPoiAreaChange(poiId)
	end
end

return M
