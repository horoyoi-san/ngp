gMapSystem_Poi = gMapSystem_Poi or {}
local M = gMapSystem_Poi

function M:Init()
	self.unlockedPoiIds = {}
end

function M:OnLogin()
	table.clear(self.unlockedPoiIds)

	local serverUnlockedDatas = gPlayerManager.infoAchievement.bindData.SceneFogMapPoiIds

	if not serverUnlockedDatas then
		return
	end

	for i = 1, serverUnlockedDatas.Count do
		self.unlockedPoiIds[serverUnlockedDatas[i]] = true
	end
end

function M:OnLogout()
	table.clear(self.unlockedPoiIds)
end

function M:OnPoiAreaChange(poiId)
	if not self.unlockedPoiIds[poiId] and poiId ~= 0 then
		gClientToGameDelegate:SyncEnterFogMapPoiId(poiId)
		LX6.Gps.MapFogDataMgr.UnlockPoiBlock(poiId)

		self.unlockedPoiIds[poiId] = true
	end

	self.env.ui:OnPoiAreaChange(poiId)
end

return M
