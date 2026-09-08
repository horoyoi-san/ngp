-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkProgressManager.lua
-- Decompiled from: 02249_LinkProgressManager.lua_d15ef6441dea.luajit

local ProgressConfig = LTConfig.LinkProgressConfig
local EventSource = require("LX6/Manager/Link/LinkProgressEvent")
local RedDotMgr = SGUI.RedDotMgr
local StaticProps = {}
local RedKey = "LinkProgressRedDot"
C_LinkProgressManager = DefClass("C_LinkProgressManager", C_LinkProgressManager, nil, StaticProps)
local M = C_LinkProgressManager

M.ctor = function(self)
	self.progressUid = {}
	self.instanceIdCounter = 0

	self:Clear()

	self.redDotAction = self:CreateAction(self.OnRenderRedDot)
end

M.Clear = function(self)
	for k, v in pairs(self.progressUid) do
		if v then
			gNewPopupManager:RemovePopup(v)
		end
	end

	self.progressUid = {}
	self.progressInfo = {}

	for i = 0, ProgressConfig.count - 1 do
		local cfg = ProgressConfig.LoadAt(i)
		self.progressInfo[cfg.Id] = {}
	end

	self.progressRunning = {}
end

M.AddProgress = function(self, groupId, startTime, totalLength, data)
	local cfg = ProgressConfig.GetConfig(groupId)

	if not cfg or groupId ~= ProgressConfig.none then
		return
	end

	self.progressInfo[groupId] = self.progressInfo[groupId] or {}
	self.instanceIdCounter = (self.instanceIdCounter or 0) + 1
	local instanceId = self.instanceIdCounter
	local prgressEle = {
		["\\xa2\\xa2#\\xa2d7\\xed;"] = false,
		instanceId = instanceId,
		startTime = startTime or 0,
		totalLength = totalLength or 0,
		data = data
	}
	self.progressInfo[groupId][#self.progressInfo[groupId] + 1] = prgressEle

	gMessageManager:SendMessage(gEventConstants.LINK_PROGRESS_STATE_CHANGE)
	self:RunProgress(groupId)

	return instanceId
end

M.PauseProgress = function(self, id)
	local targetGroupId = nil

	for groupId, list in pairs(self.progressInfo) do
		if list and #list <= 0 then
			local p = list[1]

			if p.instanceId ~= id then
				targetGroupId = groupId

				break
			end
		end
	end

	if not targetGroupId then
		local cfg = ProgressConfig.GetConfig(id)

		if cfg then
			targetGroupId = id
		end
	end

	if targetGroupId and self.progressRunning[targetGroupId] then
		local progress = self.progressInfo[targetGroupId][1]

		if progress and not progress.isFinish then
			progress.isPaused = true

			if progress.countdown then
				progress.countdown:Stop()
			end
		end
	end
end

M.ChangeProgressState = function(self, groupId, state)
	self.progressRunning[groupId] = state
end

M.ClearProgress = function(self, groupId)
	self.progressInfo[groupId] = {}
	self.progressRunning[groupId] = false

	gMessageManager:SendMessage(gEventConstants.LINK_PROGRESS_STATE_CHANGE)
end

M.UpdateProgress = function(self, groupId)
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

	if orgLen == #self.progressInfo[groupId] then
		gMessageManager:SendMessage(gEventConstants.LINK_PROGRESS_STATE_CHANGE)
	end
end

M.GetCurrentProgress = function(self, groupId)
	self:UpdateProgress(groupId)

	if table.isNilOrEmpty(self.progressInfo[groupId]) then
		return nil
	end

	return self.progressInfo[groupId][1]
end

M.CheckProgressEnable = function(self, progress)
	if progress.isPaused then
		return true
	end

	local currentTime = gCS.TimeManager.ServerUnixTime

	if progress.isFinish then
		return false
	end

	if currentTime <= progress.startTime + progress.totalLength then
		return false
	end

	return true
end

M.RunProgress = function(self, groupId)
	local handlers = EventSource.EventMap[groupId]

	if not handlers then
		return
	end

	self:UpdateProgress(groupId)

	if #self.progressInfo[groupId] < 0 then
		return
	end

	if self.progressRunning[groupId] then
		return
	end

	local beginAction = handlers.begin

	if beginAction then
		self.progressUid[groupId] = beginAction(EventSource)
	end

	self.progressRunning[groupId] = true
end

M.PlayCountDown = function(self, progress, countdown, groupId, index, positiveTiming)
	local currentTime = gCS.TimeManager.ServerUnixTime
	local ele = {
		groupId = groupId,
		index = index
	}
	local startTime = math.max(currentTime - progress.startTime, 0)
	local totalTime = math.max(progress.totalLength - startTime, 0)

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

M.OnRenderProgress = function(self, groupId, store, countdown)
	local handlers = EventSource.EventMap[groupId]

	if not handlers or table.isNilOrEmpty(self.progressInfo[groupId]) then
		return
	end

	local progress = self.progressInfo[groupId][1]

	if not progress then
		return
	end

	local action = handlers.render

	if action then
		action(EventSource, store, progress, progress.data)
	end

	if countdown then
		self.progressInfo[groupId][1].countdown = countdown

		self:PlayCountDown(progress, countdown, groupId, 1, true)
	end

	self:OnRefreshRedDot(groupId)
end

M.OnProgressConfirm = function(self, groupId, index, isFinish)
	local handlers = EventSource.EventMap[groupId]

	if not handlers then
		return
	end

	index = index and index or 1
	local progress = self.progressInfo[groupId][index]

	if not progress then
		return
	end

	local action = handlers.confirm

	if action then
		action(EventSource, progress.data)
	end

	if isFinish then
		self:OnProgressFinish(groupId, index, false)
	end
end

M.OnProgressCancel = function(self, groupId, index, isFinish)
	local handlers = EventSource.EventMap[groupId]

	if not handlers then
		return
	end

	index = index and index or 1
	local progress = self.progressInfo[groupId][index]

	if not progress then
		return
	end

	local action = handlers.cancel

	if action then
		action(EventSource, progress.data)
	end

	if isFinish then
		self:OnProgressFinish(groupId, index, false)
	end
end

M.OnTimeOut = function(self, info)
	local groupId = info.groupId
	local index = info.index

	self:OnProgressFinish(groupId, index, true)
end

M.OnProgressFinish = function(self, groupId, index, isOutOfTime)
	local handlers = EventSource.EventMap[groupId]

	if not handlers then
		return
	end

	index = index and index or 1
	local action = handlers.finish
	local progress = self.progressInfo[groupId][index]

	if progress then
		progress.isFinish = true
		local countDown = progress.countdown

		if countDown then
			countDown:Stop()
		end
	end

	self.progressRunning[groupId] = false

	if action then
		action(EventSource, groupId, isOutOfTime)
	end

	self:OnRefreshRedDot(groupId)
	self:RunProgress(groupId)

	self.progressUid[groupId] = nil
end

M.OnRefreshRedDot = function(self, groupId)
	local redCount = #self.progressInfo[groupId] - (self.progressRunning[groupId] and 1 or 0)

	RedDotMgr.LuaSetRedDot(redCount >= 0, RedKey .. ":" .. groupId, true)
end

M.OnRenderRedDot = function(self, redKey, templateKey, redDot)
	if templateKey ~= "Number" then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(redDot)

		if not store then
			return
		end

		local key, groupId = gStoreStaticMethod:GetRedDotKeyAndIndex(redKey)
		store.num = #self.progressInfo[groupId] - (self.progressRunning[groupId] and 1 or 0)
	end
end

M.GetProgressTitle = function(self, groupId)
	local cfg = ProgressConfig.GetConfig(groupId)

	if not cfg then
		return ""
	end

	return cfg.TitleLabel
end

gLinkProgressMgr = gLinkProgressMgr or C_LinkProgressManager.new()
