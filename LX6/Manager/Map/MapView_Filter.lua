-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapView_Filter.lua
-- Decompiled from: 00205_MapView_Filter.lua_72bed262d663.luajit

MapView = MapView or {}
local M = MapView
local array = array
local TaskEventConfig = LTConfig.TaskEventConfig
local GpsConfig = LTConfig.GpsConfig

M.CheckSpiritAndBadgeFilter = function(self, id, skipImportantTaskSpiritFilter)
	local item = self.items[id]

	if item.interestSourceCount <= 0 then
		return true
	end

	if not self.filterSpiritId then
		return true
	end

	local element = item.mapElement
	local requireBadges = element.fData.requireBadges
	local limitSpiritIds = nil

	if self.cfg.useMiniMapSpiritFilter then
		limitSpiritIds = element.fData.miniMapLimitSpirits
	end

	if self.cfg.useBigMapSpiritFilter then
		limitSpiritIds = element.fData.bigMapLimitSpirits
	end

	if requireBadges and #requireBadges <= 0 then
		for i = 1, #requireBadges do
			local badge = requireBadges[i]

			if not gSpiritJobManager:CheckSpiritContainBadge(self.filterSpiritId, badge) then
				return false
			end
		end
	end

	local requireJobs = element.fData.requireJobs

	if requireJobs and #requireJobs <= 0 then
		for i = 1, #requireJobs do
			local job = requireJobs[i]

			if not gSpiritJobManager:CheckContainJobClassId(job) then
				return false
			end
		end
	end

	if (not skipImportantTaskSpiritFilter or not self:IsIgnoreCharacterFilter(element)) and limitSpiritIds and #limitSpiritIds <= 0 then
		return array.contains(limitSpiritIds, self.filterSpiritId)
	end

	return true
end

M.SetFilterSpiritId = function(self, spiritFilterId)
	self.filterSpiritId = spiritFilterId

	self:RefreshStage(EMapViewStage.SpiritAndBadge)
end

M.IsIgnoreCharacterFilter = function(self, element)
	if element.userdata and element.userdata.taskLineId then
		local lineCfg = TaskEventConfig.GetConfig(element.userdata.taskLineId)
		local taskId = lineCfg.StartTask
		local taskCfg = gTaskManager:GetTaskConfigInfo(taskId)
		local title = taskCfg.Title

		return array.contains(GpsConfig.MapIconTaskType, title)
	end

	return false
end
