-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\NewGameProgressMgr.lua
-- Decompiled from: 02251_NewGameProgressMgr.lua_f8ba3c2878bc.luajit

local TemplateConfig = LTConfig.SyncValueUITemplateConfig
local TemplateCallConfig = LTConfig.SyncValueTemplateCallConfig
local ProgressConfig = LTConfig.SyncValueProgressConfig
local SyncProgressConfig = LTConfig.SyncValueSyncProgressConfig
local PopupConfig = LTConfig.PopupConfig
C_NewGameProgressMgr = DefClass("C_NewGameProgressMgr", C_NewGameProgressMgr)
local M = C_NewGameProgressMgr

M.ctor = function(self)
	self.BOOL2CTL = {
		[true] = 1,
		[false] = 0
	}
	self.isDebug = true
	self.PREDICT_DURATION = 0.3

	self:InitData()
end

M.InitData = function(self)
	self.progress = {}
	self.progressCounter = {}
	self.progressChecker = {}
	self.templateVisible = {}
	self.uiOwners = {}
end

M.Log = function(self, ...)
	if self.isDebug then
		print_notice("[C_NewGameProgressMgr]", ...)
	end
end

M.IsNewProgress = function(self)
	return gGameSwitch and gGameSwitch.EnableNewProgress
end

M.OnUpdate = function(self)
	local curTime = gCS.TimeManager.ServerUnixTime

	for progressId, ele in pairs(self.progress) do
		if self:CheckProgress(progressId) then
			self.progressCounter[progressId] = ele.startLength + (curTime - ele.startTime) * ele.speed
		end
	end
end

M.BeforeSwitchScene = function(self, switchType)
	if self:IsNewProgress() then
		self:StopAllProgress()
	else
		self:StopAllProgressTemplate()
	end
end

M.AfterLoadingPanelClosed = function(self)
	for k, v in pairs(self.templateVisible) do
		if v then
			self:StartProgressTemplate(k, v)
		end
	end
end

M.ChangeProgressState = function(self, ProgressId, startTime, startLength, totalLength, speed, visible)
	self:Log("ChangeProgressState", ProgressId, startTime, startLength, totalLength, speed, visible)

	local isNew = self:IsNewProgress()
	local cfg = isNew and SyncProgressConfig.GetConfig(ProgressId) or ProgressConfig.GetConfig(ProgressId)

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
		speed = speed,
		warningTime = cfg.warningTime
	}
	self.progress[ProgressId] = ele
	self.progressCounter[ProgressId] = startLength
	self.progressChecker[ProgressId] = true

	if isNew and visible == false then
		self:StartProgressTemplate(ProgressId, true)
	end

	self:CheckProgress(ProgressId)
	gMessageManager:SendMessage(gEventConstants.PROGRESS_STATE_CHANGE, ProgressId)
end

M.StopProgress = function(self, ProgressId)
	self:Log("StopProgress", ProgressId)

	self.progress[ProgressId] = nil
	self.progressCounter[ProgressId] = nil
	self.progressChecker[ProgressId] = nil

	self:StopProgressTemplate(ProgressId)

	if table.isNilOrEmpty(self.progress) then
		gLuaClient:UnregisterDynamicUpdate("gNewGamePlayProgressMgr")
	end
end

M.GetProgress = function(self, ProgressId)
	return self.progress[ProgressId]
end

M.CheckProgress = function(self, progressId)
	if not self.progressChecker[progressId] then
		return false
	end

	local ele = self.progress[progressId]

	if ele.speed >= 0 and self.progressCounter[progressId] < 0 then
		self.progressChecker[progressId] = false

		return false
	end

	if ele.speed <= 0 and ele.totalLength < self.progressCounter[progressId] then
		self.progressChecker[progressId] = false

		return false
	end

	return true
end

M.GetProgressListByTemplateId = function(self, templateCallId)
	if self:IsNewProgress() then
		local cfg = SyncProgressConfig.GetConfig(templateCallId)

		if not cfg then
			return {}
		end

		return {
			templateCallId
		}
	end

	local cfg = TemplateCallConfig.GetConfig(templateCallId)

	if not cfg then
		return {}
	end

	return cfg.ProgressIdList
end

M.GetProgressDictByTemplateIds = function(self, templateCallIds)
	local ret = {}

	for i = 1, #templateCallIds do
		local progressIds = self:GetProgressListByTemplateId(templateCallIds[i])

		for j = 1, #progressIds do
			ret[progressIds[j]] = true
		end
	end

	return ret
end

M.GetAllTemplateIdsByUiId = function(self, uiId)
	local ret = {}

	for templateId, isVisible in pairs(self.templateVisible) do
		if isVisible then
			local cfg = self:IsNewProgress() and SyncProgressConfig.GetConfig(templateId) or TemplateCallConfig.GetConfig(templateId)

			if cfg then
				local tCfg = TemplateConfig.GetConfig(cfg.UITemplateId)
				local curUiId = tCfg and tCfg.PanelId or 0

				if curUiId ~= uiId then
					table.insert(ret, templateId)
				end
			end
		end
	end

	return ret
end

M.GetCurrentProgress = function(self, maxNum, templateCallId)
	if table.isNilOrEmpty(self.progress) then
		return {}
	end

	local progressIds = self:GetProgressListByTemplateId(templateCallId)
	local ret = {}

	for i = 1, #progressIds do
		local progressId = progressIds[i]
		local ele = self.progress[progressId]

		if not table.isNilOrEmpty(ele) then
			local cfg = self:IsNewProgress() and SyncProgressConfig.GetConfig(progressId) or ProgressConfig.GetConfig(progressId)
			local ele = {
				progressId = progressId,
				maxValue = ele.totalLength,
				formatStr = cfg.FormatStr
			}

			table.insert(ret, ele)

			if maxNum < #ret then
				break
			end
		end
	end

	return ret
end

M.GetCounterValue = function(self, progressId)
	if not self.progress[progressId] then
		return 0
	end

	return math.min(self.progressCounter[progressId], self.progress[progressId].totalLength)
end

M.GetUIConfigByTemplateId = function(self, templateId)
	local cfg = self:IsNewProgress() and SyncProgressConfig.GetConfig(templateId) or TemplateCallConfig.GetConfig(templateId)

	if not cfg then
		return nil
	end

	local tCfg = TemplateConfig.GetConfig(cfg.UITemplateId)

	return tCfg
end

M.StartProgressTemplate = function(self, templateId, visible)
	self:Log("StartProgressTemplate", templateId, visible)

	local cfg = self:IsNewProgress() and SyncProgressConfig.GetConfig(templateId) or TemplateCallConfig.GetConfig(templateId)

	if not cfg then
		return
	end

	local tCfg = TemplateConfig.GetConfig(cfg.UITemplateId)
	local uiId = tCfg and tCfg.PanelId or 0
	self.templateVisible[templateId] = visible

	if uiId == 0 then
		self.uiOwners[uiId] = templateId
	end

	local ele = {
		templateId = templateId,
		uiId = uiId
	}

	if uiId == 0 and not gPanelManager:IsPanelShowing(uiId) then
		if visible then
			print_debug("ShowPanel gp", uiId)
			gPanelManager:CheckShow(uiId, ele)
		end
	else
		gMessageManager:SendMessage(gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE, ele)
	end
end

M.StopProgressTemplate = function(self, templateId)
	self:Log("StopProgressTemplate", templateId)

	local cfg = self:IsNewProgress() and SyncProgressConfig.GetConfig(templateId) or TemplateCallConfig.GetConfig(templateId)

	if not cfg then
		return
	end

	local tCfg = TemplateConfig.GetConfig(cfg.UITemplateId)
	local uiId = tCfg and tCfg.PanelId or 0
	self.templateVisible[templateId] = false

	if uiId == 0 and self.uiOwners[uiId] ~= templateId then
		self.uiOwners[uiId] = nil

		if tCfg.ClosePanel then
			gPanelManager:Close(uiId)
		else
			local ele = {
				templateId = templateId,
				uiId = uiId
			}

			gMessageManager:SendMessage(gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE, ele)
		end
	elseif uiId ~= 0 then
		local ele = {
			templateId = templateId,
			uiId = uiId
		}

		gMessageManager:SendMessage(gEventConstants.PROGRESS_TEMPLATE_STATE_CHANGE, ele)
	end
end

M.StopAllProgressTemplate = function(self)
	self:Log("StopAllProgressTemplate")

	local panelsToClose = {}

	for uiId, _ in pairs(self.uiOwners) do
		panelsToClose[uiId] = true
	end

	self:InitData()
	gLuaClient:UnregisterDynamicUpdate("gNewGamePlayProgressMgr")

	for uiId, _ in pairs(panelsToClose) do
		gPanelManager:Close(uiId)
	end
end

M.ChangeProgressVisible = function(self, templateId, visible)
	self:Log("ChangeProgressVisible", templateId, visible)

	if visible then
		self:StartProgressTemplate(templateId, true)
	else
		self:StopProgressTemplate(templateId)
	end
end

M.StopAllProgress = function(self)
	self:StopAllProgressTemplate()
end

M.RenderSingleProgressTemplate = function(self, store, templateId)
	local progressInfo = self:GetCurrentProgress(1, templateId)

	if table.isNilOrEmpty(progressInfo) or not store then
		store.visible = self.BOOL2CTL[false]

		return 0
	end

	progressInfo = progressInfo[1]
	local id = progressInfo.progressId
	local progress = self.progress[id]
	local cfg = self:IsNewProgress() and SyncProgressConfig.GetConfig(id) or ProgressConfig.GetConfig(id)

	if not cfg then
		return 0
	end

	store.title = cfg.title
	local fulltips = string.is_null_or_empty(cfg.fulltips) and "" or cfg.fulltips
	local emptyTips = string.is_null_or_empty(cfg.emptyTips) and "" or cfg.emptyTips
	store.finishTips = math.abs(progress.speed) <= 0 and fulltips or emptyTips
	store.visible = self.BOOL2CTL[self.templateVisible[templateId] or false]

	if store.progress then
		store.progress.maxValue = progressInfo.maxValue
		store.progress.formatText = progressInfo.formatStr
	elseif store.dotList then
		local currentCounter = self:GetCounterValue(id)
		store.dotList.groupType = 2

		store.dotList:SetSimpleList(0)

		for i = 1, progressInfo.maxValue do
			store.dotList:AddSimpleData(0, i > currentCounter)
		end

		store.dotList:RefreshList()

		return 0
	elseif store.countDown then
		store.countDown.formatText = progressInfo.formatStr
		local absSpeed = math.abs(progress.speed)
		local remainCounter = self:GetCounterValue(id) or 0
		remainCounter = math.max(0, math.min(remainCounter, progressInfo.maxValue))

		store.countDown:Play(remainCounter / absSpeed)
	end

	return progressInfo.progressId
end

M.RefreshSingleProgressCounter = function(self, store, progressId, templateId)
	if progressId ~= 0 or not store then
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

	store.warning = self.BOOL2CTL[ele.warningTime and counter <= ele.warningTime]
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

		if deltaToTarget <= MAX_PREDICT_ERROR then
			needUpdateTarget = true
		elseif deltaTime > 0 then
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

M.AddNewPopup = function(self, id)
	gNewPopupManager:PushPopup(PopupConfig.S_OnlineMatchNotice, {
		id = id
	})
end

M.AskPopupEnter = function(self, id)
end

gNewGamePlayProgressMgr = gNewGamePlayProgressMgr or C_NewGameProgressMgr.new()
