-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem_TaskUtils.lua
-- Decompiled from: 02300_MapSystem_TaskUtils.lua_e64157cc34a1.luajit

gMapSystem_TaskUtils = gMapSystem_TaskUtils or {}
local M = gMapSystem_TaskUtils

M.Init = function(self)
	self:ResetData()
end

M.OnLogin = function(self)
	self:ResetData()
end

M.OnLogout = function(self)
	self:ResetData()
end

M.ResetData = function(self)
	self._guidingTitleDict = {}
	self._defaultGuidingTitleDict = {}

	for _, titleId in ipairs(LTConfig.TaskConfig.AcceptTaskType) do
		self._defaultGuidingTitleDict[titleId] = true
	end
end

M.SetTaskTitleGuide = function(self, titleId, guiding)
	local changed = false

	if guiding then
		if not self._guidingTitleDict[titleId] then
			self._guidingTitleDict[titleId] = true
			changed = true
		end
	elseif self._guidingTitleDict[titleId] then
		self._guidingTitleDict[titleId] = nil
		changed = true
	end

	if changed then
		gMapSubSystem_Task:OnGuidingTaskTitleChanged()
	end
end

M.SyncTaskGuideTitles = function(self, titleIdList)
	self._guidingTitleDict = {}

	if not titleIdList or #titleIdList ~= 0 then
		return
	end

	for _, titleId in ipairs(titleIdList) do
		self._guidingTitleDict[titleId] = true
	end
end

M.IsMiniMapGuidingTaskTitle = function(self, titleId)
	if self._defaultGuidingTitleDict[titleId] then
		return true
	else
		return false
	end
end

M.IsHudGuidingTaskTitle = function(self, titleId)
	local guidingTitles = nil

	if self._guidingTitleDict and next(self._guidingTitleDict) then
		guidingTitles = self._guidingTitleDict
	else
		guidingTitles = self._defaultGuidingTitleDict
	end

	if guidingTitles[titleId] then
		return true
	else
		return false
	end
end

M.NotifyTaskEventGuided = function(self, taskLineId)
	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(taskLineId)

	if not taskEventCfg then
		return
	end

	local taskCfg = LTConfig.TaskConfig.GetConfig(taskEventCfg.StartTask)

	if not taskCfg then
		return
	end

	local taskTitleId = taskCfg.Title

	gClientToGameDelegate:FinishTaskTitleGuideUnlock(taskTitleId)
end

M.CheckFactionDisposition = function(self, taskLineCfg)
	if not taskLineCfg.FactionCondition or taskLineCfg.FactionCondition.FactionId ~= 0 then
		return true
	end

	local factionInfo = gClientUtils.GetFactionInfo(taskLineCfg.FactionCondition.FactionId)

	if factionInfo ~= nil or factionInfo.Disposition >= taskLineCfg.FactionCondition.Disposition then
		return false
	end

	return true
end

M.IsCurSpiritNotMatch = function(self, taskLineId)
	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(taskLineId)

	if not taskEventCfg then
		return false
	end

	local curTid = gSpiritManager:GetCurFirstSpiritTid()
	local legalSpiritList = gMapSubSystemUtils:GetTaskSpiritRoleTeamList(taskEventCfg)

	return legalSpiritList and #legalSpiritList <= 0 and not array.contains(legalSpiritList, curTid)
end

return M
