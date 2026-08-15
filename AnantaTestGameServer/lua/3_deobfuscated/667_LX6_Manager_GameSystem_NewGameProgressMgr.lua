local TemplateConfig = LTConfig.SyncValueUITemplateConfig
local TemplateCallConfig = LTConfig.SyncValueTemplateCallConfig
local ProgressConfig = LTConfig.SyncValueProgressConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
C_NewGameProgressMgr = DefClass("C_NewGameProgressMgr", C_NewGameProgressMgr)
local M = C_NewGameProgressMgr

function M:ctor()
	self.BOOL2CTL = {
		[true] = 1,
		[false] = 0
	}
	self.isDebug = true
	self.PREDICT_DURATION = 0.3

	self:InitData()
end

function M:InitData()
	self.progress = {}
	self.progressCounter = {}
	self.progressChecker = {}
	self.templateVisible = {}
end

function M:Log(...)
	if self.isDebug then
		print_debug("[C_NewGameProgressMgr]", ...)
	end
end

function M:OnUpdate()
	local curTime = gCS.TimeManager.ServerUnixTime

	for progressId, ele in pairs(self.progress) do
		if self:CheckProgress(progressId) then
			self.progressCounter[progressId] = ele.startLength + (curTime - ele.startTime) * ele.speed
		end
	end
end

function M:AfterLoadingPanelClosed()
	for k, v in pairs(self.templateVisible) do
		if v then
			self:StartProgressTemplate(k, v)
		end
	end
end

function M:ChangeProgressState(ProgressId, startTime, startLength, totalLength, speed)
	self:Log("ChangeProgressState", ProgressId, startTime, startLength, totalLength, speed)

	local cfg = ProgressConfig.GetConfig(ProgressId)

	if not cfg then
		return
	end

	if table.isNilOrEmpty(self.progress) then
		gLuaClient:RegisterDynamicUpdate("gNewGamePlayProgressMgr", self)
	end

	local ele = {
		startTime = startTime,
		startLength = startLength,
		totalLength = totalLength,
		speed = speed
	}
	self.progress[ProgressId] = ele
	self.progressCounter[ProgressId] = startLength
	self.progressChecker[ProgressId] = true

	self:CheckProgress(ProgressId)
	gMessageManager:SendMessage(gEventConstants.PROGRESS_STATE_CHANGE, ProgressId)
end

function M:StopProgress(ProgressId)
	self:Log("StopProgress", ProgressId)

	self.progress[ProgressId] = nil
	self.progressCounter[ProgressId] = nil
	self.progressChecker[ProgressId] = nil

	if table.isNilOrEmpty(self.progress) then
		gLuaClient:UnregisterDynamicUpdate("gNewGamePlayProgressMgr")
	end
end

function M:CheckProgress(progressId)
	if not self.progressChecker[progressId] then
		return false
	end

	local ele = self.progress[progressId]

	if ele.speed == 0 then
		self.progressChecker[progressId] = false

		return false
	end

	if ele.speed < 0 and self.progressCounter[progressId] <= 0 then
		self.progressChecker[progressId] = false

		return false
	end

	if ele.speed > 0 and ele.totalLength <= self.progressCounter[progressId] then
		self.progressChecker[progressId] = false

		return false
	end

	return true
end

function M:GetProgressListByTemplateId(templateCallId)
	local cfg = TemplateCallConfig.GetConfig(templateCallId)

	if not cfg then
		return {}
	end

	return cfg.ProgressIdList
end

function M:GetProgressDictByTemplateIds(templateCallIds)
	local ret = {}

	for i = 1, #templateCallIds do
		local progressIds = self:GetProgressListByTemplateId(templateCallIds[i])

		for j = 1, #progressIds do
			ret[progressIds[j]] = true
		end
	end

	return ret
end

function M:GetCurrentProgress(maxNum, templateCallId)
	if table.isNilOrEmpty(self.progress) then
		return {}
	end

	local progressIds = self:GetProgressListByTemplateId(templateCallId)
	local ret = {}

	for i = 1, #progressIds do
		local progressId = progressIds[i]
		local ele = self.progress[progressId]

		if not table.isNilOrEmpty(ele) then
			local cfg = ProgressConfig.GetConfig(progressId)
			local ele = {
				progressId = progressId,
				maxValue = ele.totalLength,
				formatStr = cfg.FormatStr
			}

			table.insert(ret, ele)

			if maxNum <= #ret then
				break
			end
		end
	end

	return ret
end

function M:GetCounterValue(progressId)
	if not self.progress[progressId] then
		return 0
	end

	return math.min(self.progressCounter[progressId], self.progress[progressId].totalLength)
end

function M:GetUIConfigByTemplateId(templateId)
	local cfg = TemplateCallConfig.GetConfig(templateId)

	if not cfg then
		return nil
	end

	local tCfg = TemplateConfig.GetConfig(cfg.UITemplateId)

	return tCfg
end

function M:StartProgressTemplate(templateId, visible)
	self:Log("StartProgressTemplate", templateId, visible)

	local cfg = TemplateCallConfig.GetConfig(templateId)

	if not cfg then
		return
	end

	local tCfg = TemplateConfig.GetConfig(cfg.UITemplateId)
	local uiId = tCfg and tCfg.PanelId or 0
	self.templateVisible[templateId] = visible
	local ele = {
		templateId = templateId,
		uiId = uiId
	}

	if uiId ~= 0 and not gPanelManager:IsPanelShowing(uiId) then
		if visible then
			gPanelManager:CheckShow(uiId, ele)
		end
	else
		gMessageManager:SendMessage(gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE, ele)
	end
end

function M:StopProgressTemplate(templateId)
	self:Log("StopProgressTemplate", templateId)

	local cfg = TemplateCallConfig.GetConfig(templateId)

	if not cfg then
		return
	end

	local tCfg = TemplateConfig.GetConfig(cfg.UITemplateId)
	self.templateVisible[templateId] = false

	gPanelManager:Close(tCfg.PanelId)
end

function M:RenderSingleProgressTemplate(store, templateId)
	local progressInfo = self:GetCurrentProgress(1, templateId)

	if table.isNilOrEmpty(progressInfo) or not store then
		return 0
	end

	progressInfo = progressInfo[1]
	local id = progressInfo.progressId
	local progress = self.progress[id]
	local cfg = ProgressConfig.GetConfig(id)

	if not cfg then
		return 0
	end

	store.title = cfg.title
	store.finishTips = progress.speed > 0 and cfg.fulltips or cfg.emptyTips
	store.visible = self.BOOL2CTL[self.templateVisible[templateId] or false]

	if store.progress then
		store.progress.maxValue = progressInfo.maxValue
		store.progress.formatText = progressInfo.formatStr
	elseif store.dotList then
		local currentCounter = self:GetCounterValue(id)
		store.dotList.groupType = 2

		store.dotList:SetSimpleList(0)

		for i = 1, progressInfo.maxValue do
			store.dotList:AddSimpleData(0, i <= currentCounter)
		end

		store.dotList:RefreshList()

		return 0
	end

	return progressInfo.progressId
end

function M:RefreshSingleProgressCounter(store, progressId, templateId)
	if progressId == 0 or not store then
		return
	end

	local counter = self:GetCounterValue(progressId)

	if not counter then
		return
	end

	local state = self.progressChecker[progressId]
	store.status = self.BOOL2CTL[not state]

	if not state then
		return
	end

	local isVisible = self.templateVisible[templateId] or false
	store.visible = self.BOOL2CTL[isVisible]

	if not isVisible or not store.progress then
		return
	end

	local ele = self.progress[progressId]

	if not ele or not ele.speed then
		store.progress:ProgressToValue(counter, 0)

		return
	end

	local curTime = gCS.TimeManager.ServerUnixTime or 0
	local futureTime = curTime + self.PREDICT_DURATION
	local futureValue = ele.startLength + (futureTime - ele.startTime) * ele.speed
	futureValue = math.max(0, math.min(futureValue, ele.totalLength or futureValue))
	self.uiAnimState = self.uiAnimState or {}
	local animState = self.uiAnimState[progressId] or {}
	local needUpdateTarget = false

	if not animState.lastTargetValue then
		needUpdateTarget = true
	else
		local realNow = counter
		local deltaToTarget = math.abs(realNow - animState.lastTargetValue)
		local deltaTime = curTime - (animState.lastTargetEndTime or 0)
		local MAX_PREDICT_ERROR = 1

		if deltaToTarget > MAX_PREDICT_ERROR then
			needUpdateTarget = true
		elseif deltaTime >= 0 then
			needUpdateTarget = true
		end
	end

	if not needUpdateTarget then
		self.uiAnimState[progressId] = animState

		return
	end

	animState.lastTargetValue = futureValue
	animState.lastTargetEndTime = futureTime
	self.uiAnimState[progressId] = animState

	store.progress:ProgressToValue(futureValue, self.PREDICT_DURATION)
end

function M:___BeginHackerTest()
	self:StartProgressTemplate(1018)
	self:ChangeProgressState(118, gCS.TimeManager.ServerUnixTime, 0, 60, 1)
end

function M:___EndHackerTest()
	self:StopProgressTemplate(1018)
	self:StopProgress(118)
end

function M:___BeginHackerMoney()
	self:StartProgressTemplate(1100, true)

	local progressId = LTConfig.SyncValueTemplateCallConfig.GetConfig(1100).ProgressIdList[1]
	local time = LTConfig.SyncValueProgressConfig.GetConfig(progressId).TotalLength

	self:ChangeProgressState(progressId, gCS.TimeManager.ServerUnixTime, 0, time, 1)

	return time
end

function M:___EndHackerMoney()
	self:StopProgressTemplate(1100)

	local progressId = LTConfig.SyncValueTemplateCallConfig.GetConfig(1100).ProgressIdList[1]

	self:StopProgress(progressId)
end

function M:___BeginHackerFans()
	self:StartProgressTemplate(1101, true)

	local progressId = LTConfig.SyncValueTemplateCallConfig.GetConfig(1101).ProgressIdList[1]
	local time = LTConfig.SyncValueProgressConfig.GetConfig(progressId).TotalLength

	self:ChangeProgressState(progressId, gCS.TimeManager.ServerUnixTime, 0, time, 1)

	return time
end

function M:___EndHackerFans()
	self:StopProgressTemplate(1101)

	local progressId = LTConfig.SyncValueTemplateCallConfig.GetConfig(1101).ProgressIdList[1]

	self:StopProgress(progressId)
end

function M:___BeginCommonLinerUpTest()
	self:StartProgressTemplate(1008, true)
	self:ChangeProgressState(108, gCS.TimeManager.ServerUnixTime, 0, 400, 1)
end

function M:___EndCommonLinerUpTest()
	self:StopProgressTemplate(1008)
	self:StopProgress(108)
end

function M:___BeginCommonDotUpTest()
	self:StartProgressTemplate(1034)
	self:ChangeProgressState(134, gCS.TimeManager.ServerUnixTime, 0, 3, 0)
end

function M:___ChangeCommonDotUpTest(count)
	self:ChangeProgressState(134, gCS.TimeManager.ServerUnixTime, count, 3, 0)
end

function M:___EndCommonDotUpTest()
	self:StopProgressTemplate(1034)
	self:StopProgress(134)
end

function M:___BeginCommonLinerDownTest()
	self:StartProgressTemplate(1035)
	self:ChangeProgressState(135, gCS.TimeManager.ServerUnixTime, 60, 60, -1)
end

function M:___EndCommonLinerDownTest()
	self:StopProgressTemplate(1035)
	self:StopProgress(135)
end

function M:___BeginPoliceTest()
	self:StartProgressTemplate(1018)
	self:ChangeProgressState(118, gCS.TimeManager.ServerUnixTime, 0, 60, 1)
end

function M:___EndPoliceTest()
	self:StopProgressTemplate(1018)
	self:StopProgress(118)
end

gNewGamePlayProgressMgr = gNewGamePlayProgressMgr or C_NewGameProgressMgr.new()
