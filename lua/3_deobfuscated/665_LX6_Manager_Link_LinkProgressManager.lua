local ProgressConfig = LTConfig.LinkProgressConfig
local EventSource = require("LX6/Manager/Link/LinkProgressEvent")
local RedDotMgr = SGUI.RedDotMgr
local StaticProps = {}
local RedKey = "LinkProgressRedDot"
C_LinkProgressManager = DefClass("C_LinkProgressManager", C_LinkProgressManager, nil, StaticProps)
local M = C_LinkProgressManager

function M:ctor()
	self:Clear()
end

function M:Clear()
	self.progressInfo = {}
	self.progressRunning = {}
	self.redDotAction = self:CreateAction(self.OnRenderRedDot)
end

function M:AddProgress(groupId, startTime, totalLength, data)
	local cfg = ProgressConfig.GetConfig(groupId)

	if not cfg or groupId == ProgressConfig.none then
		return
	end

	self.progressInfo[groupId] = self.progressInfo[groupId] or {}
	local prgressEle = {
		isFinish = false,
		startTime = startTime or 0,
		totalLength = totalLength or 0,
		data = data
	}
	self.progressInfo[groupId][#self.progressInfo[groupId] + 1] = prgressEle

	self:RunProgress(groupId)
end

function M:ChangeProgressState(groupId, state)
	self.progressRunning[groupId] = state
end

function M:ClearProgress(groupId)
	self.progressInfo[groupId] = {}
	self.progressRunning[groupId] = false

	gMessageManager:SendMessage(gEventConstants.LINK_PROGRESS_STATE_CHANGE)
end

function M:UpdateProgress(groupId)
	self.progressInfo[groupId] = self.progressInfo[groupId] or {}
	local orgLen = #self.progressInfo[groupId]
	local index = 1

	for i = 1, #self.progressInfo[groupId] do
		local prgressEle = self.progressInfo[groupId][i]

		if self:CheckProgressEnable(prgressEle) then
			self.progressInfo[groupId][index] = prgressEle
			index = index + 1
		end
	end

	for i = index, #self.progressInfo[groupId] do
		self.progressInfo[groupId][i] = nil
	end

	if orgLen ~= #self.progressInfo[groupId] then
		gMessageManager:SendMessage(gEventConstants.LINK_PROGRESS_STATE_CHANGE)
	end
end

function M:GetCurrentProgress(groupId)
	self:UpdateProgress(groupId)

	if table.isNilOrEmpty(self.progressInfo[groupId]) then
		return nil
	end

	return self.progressInfo[groupId][1]
end

function M:CheckProgressEnable(progress)
	local currentTime = gCS.TimeManager.ServerUnixTime

	if progress.isFinish then
		return false
	end

	if currentTime > progress.startTime + progress.totalLength then
		return false
	end

	return true
end

function M:RunProgress(groupId)
	local cfg = ProgressConfig.GetConfig(groupId)

	if not cfg then
		return
	end

	self:UpdateProgress(groupId)

	if #self.progressInfo[groupId] <= 0 then
		return
	end

	if self.progressRunning[groupId] then
		return
	end

	local beginAction = self:CreateAction(cfg.BeginEvent, EventSource)

	if beginAction then
		beginAction()
	end

	self.progressRunning[groupId] = true
end

function M:PlayCountDown(progress, countdown, groupId, index, positiveTiming)
	local currentTime = gCS.TimeManager.ServerUnixTime
	local ele = {
		groupId = groupId,
		index = index
	}
	local startTime = currentTime - progress.startTime
	local totalTime = progress.totalLength - startTime

	if totalTime < 0 then
		return false
	end

	if positiveTiming then
		positiveTiming = true
	else
		positiveTiming = false
	end

	countdown.positiveTiming = positiveTiming
	countdown.luaFinished = self:CreateActionWithArgs(self.OnTimeOut, ele)

	if positiveTiming then
		countdown:Play(startTime, totalTime)
	else
		countdown:Play(totalTime)
	end

	return true
end

function M:OnRenderProgress(groupId, store, countdown)
	local cfg = ProgressConfig.GetConfig(groupId)

	if not cfg or table.isNilOrEmpty(self.progressInfo[groupId]) then
		return
	end

	local action = self:CreateAction(cfg.RenderEvent, EventSource)
	local progress = self.progressInfo[groupId][1]

	if action then
		action(store, progress, progress.data)
	end

	if countdown and progress then
		self.progressInfo[groupId][1].countdown = countdown

		self:PlayCountDown(progress, countdown, groupId, 1, true)
	end

	self:OnRefreshRedDot(groupId)
end

function M:OnProgressConfirm(groupId, index, isFinish)
	local cfg = ProgressConfig.GetConfig(groupId)

	if not cfg then
		return
	end

	local action = self:CreateAction(cfg.ConfirmEvent, EventSource)
	index = index and index or 1
	local progress = self.progressInfo[groupId][index]

	if action then
		action(progress.data)
	end

	if isFinish then
		self:OnProgressFinish(groupId, index, false)
	end
end

function M:OnProgressCancel(groupId, index, isFinish)
	local cfg = ProgressConfig.GetConfig(groupId)

	if not cfg then
		return
	end

	local action = self:CreateAction(cfg.CancelEvent, EventSource)
	index = index and index or 1
	local progress = self.progressInfo[groupId][index]

	if action then
		action(progress.data)
	end

	if isFinish then
		self:OnProgressFinish(groupId, index, false)
	end
end

function M:OnTimeOut(info)
	local groupId = info.groupId
	local index = info.index

	self:OnProgressFinish(groupId, index, true)
end

function M:OnProgressFinish(groupId, index, isOutOfTime)
	local cfg = ProgressConfig.GetConfig(groupId)

	if not cfg then
		return
	end

	index = index and index or 1
	local action = self:CreateAction(cfg.FinishEvent, EventSource)
	local progress = self.progressInfo[groupId][index]

	if action then
		action(groupId, progress.data, isOutOfTime)
	end

	progress.isFinish = true
	self.progressRunning[groupId] = false

	self:OnRefreshRedDot(groupId)

	local countDown = progress.countdown

	if countDown then
		countDown:Stop()
	end

	self:RunProgress(groupId)
end

function M:OnRefreshRedDot(groupId)
	local redCount = #self.progressInfo[groupId] - (self.progressRunning[groupId] and 1 or 0)

	RedDotMgr.LuaSetRedDot(redCount > 0, RedKey .. ":" .. groupId, true)
end

function M:OnRenderRedDot(redKey, templateKey, redDot)
	if templateKey == "Number" then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(redDot)

		if not store then
			return
		end

		local key, groupId = gStoreStaticMethod:GetRedDotKeyAndIndex(redKey)
		store.num = #self.progressInfo[groupId] - (self.progressRunning[groupId] and 1 or 0)
	end
end

gLinkProgressMgr = gLinkProgressMgr or C_LinkProgressManager.new()
