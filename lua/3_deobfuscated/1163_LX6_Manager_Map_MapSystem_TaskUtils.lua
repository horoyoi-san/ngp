gMapSystem_TaskUtils = gMapSystem_TaskUtils or {}
local M = gMapSystem_TaskUtils

function M:Init()
	self:ResetData()
end

function M:OnLogin()
	self:ResetData()
end

function M:OnLogout()
	self:ResetData()
end

function M:ResetData()
	self._guidingTitleDict = {}
	self._defaultGuidingTitleDict = {}

	for _, titleId in ipairs(LTConfig.TaskConfig.AcceptTaskType) do
		self._defaultGuidingTitleDict[titleId] = true
	end
end

function M:SetTaskTitleGuide(titleId, guiding)
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

function M:SyncTaskGuideTitles(titleIdList)
	self._guidingTitleDict = {}

	if not titleIdList or #titleIdList == 0 then
		return
	end

	for _, titleId in ipairs(titleIdList) do
		self._guidingTitleDict[titleId] = true
	end
end

function M:IsMiniMapGuidingTaskTitle(titleId)
	if self._defaultGuidingTitleDict[titleId] then
		return true
	else
		return false
	end
end

function M:IsHudGuidingTaskTitle(titleId)
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

function M:NotifyTaskEventGuided(taskLineId)
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

function M:CheckFactionDisposition(taskLineCfg)
	if not taskLineCfg.FactionCondition or taskLineCfg.FactionCondition.FactionId == 0 then
		return true
	end

	local factionInfo = gClientUtils.GetFactionInfo(taskLineCfg.FactionCondition.FactionId)

	if factionInfo == nil or factionInfo.Disposition < taskLineCfg.FactionCondition.Disposition then
		return false
	end

	return true
end

function M:IsCurSpiritNotMatch(taskLineId)
	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(taskLineId)

	if not taskEventCfg then
		return false
	end

	local curTid = gSpiritManager:GetCurFirstSpiritTid()
	local legalSpirit = gMapSubSystemUtils:GetSingleTaskSpirit(taskEventCfg)

	return legalSpirit and curTid ~= legalSpirit
end

return M
