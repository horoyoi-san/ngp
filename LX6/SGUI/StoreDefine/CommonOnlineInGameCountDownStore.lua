-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonOnlineInGameCountDownStore.lua
-- Decompiled from: 01530_CommonOnlineInGameCountDownStore.lua_b6158d5c320c.luajit

C_CommonOnlineInGameCountDownStore = DefClass("C_CommonOnlineInGameCountDownStore", C_CommonOnlineInGameCountDownStore, C_StoreGroup)
GroupName2Class.CommonOnlineInGameCountDownStore = C_CommonOnlineInGameCountDownStore
local M = C_CommonOnlineInGameCountDownStore
local TemplateCallConfig = LTConfig.SyncValueTemplateCallConfig
local ProgressConfig = LTConfig.SyncValueProgressConfig
local SyncProgressConfig = LTConfig.SyncValueSyncProgressConfig

M.ctor = function(self)
	self.startTime = 0
	self.endTime = 0
	self.nowTime = 0
	self.remainTime = 0
	self.timeRange = 0
	self.isPause = false
	self.msgEvents = {
		[gEventConstants.FINISH_COUNT_DOWN_SET_CALLBACK] = self.CreateAction(self, self.SetCallBack),
		[gEventConstants.ADD_TIME_COUNT_DOWN] = self.CreateAction(self, self.OnAddTimeEvent),
		[gEventConstants.FINISH_COUNT_DOWN] = self.CreateAction(self, self.FinishCountDownEvent),
		[gEventConstants.PROGRESS_STATE_CHANGE] = self.CreateAction(self, self.ProgressStateChange)
	}
	self.openAnimName = "S_Vx_CommonOnlineIngameCountDown_open"
end

M.SetCallBack = function(self, eventId, data)
	self.callBack = data.callBack
end

M.OnAddTimeEvent = function(self, eventId, data)
	local addTime = data.addTime

	self.AddTime(self, addTime)
end

M.FinishCountDownEvent = function(self, event, data)
	self.FinishCountDown(self)
end

M.AddTime = function(self, addTime)
	self.endTime = self.endTime + addTime
	self.timeRange = self.timeRange + addTime

	self.RefreshNowTime(self)
	self.RefreshCountDown(self)
end

M.ProgressStateChange = function(self, _, data)
	if self.templateId then
		self.RefreshProgressInfo(self, self.templateId)
		self.RefreshCountDown(self)
	end
end

M.DefineAllVariables = function(self)
end

M.InitPanelData = function(self, data, param)
	self.spoonCallBack = data.CallBack
	self.isCanContinue = param.isCanContinue
	self.showMillisecond = param.isShowMilliseconds
	self.isPause = param.isPause or false
	self.startTime = gCS.TimeManager.ServerUnixTime
	self.needAlert = param.warningTime and true or false
	self.bindData.warningState = 0
	self.warningTime = param.warningTime and param.warningTime or 0
	local countDown = param.time <= 0 and param.time or 0
	self.endTime = self.startTime + countDown
	self.timeRange = countDown
	self.reverseCountDown = param.isIncrease or false
	self.needUpdate = true
	self.nowTime = gCS.TimeManager.ServerUnixTime
	self.timeSpeed = 1
end

M.InitTemplateData = function(self, templateId)
	local isNew = gGameSwitch and gGameSwitch.EnableNewProgress
	local cfg, progressCfg = nil

	if isNew then
		cfg = SyncProgressConfig.GetConfig(templateId)
		progressCfg = cfg
	else
		cfg = TemplateCallConfig.GetConfig(templateId)
		progressCfg = ProgressConfig.GetConfig(cfg.ProgressIdList[1])
	end

	self.templateId = templateId
	self.showMillisecond = false
	self.isPause = false
	self.startTime = gCS.TimeManager.ServerUnixTime
	self.needAlert = progressCfg.warningTime >= 0
	self.warningTime = progressCfg.warningTime
	self.bindData.warningState = 0
	self.endTime = self.startTime + progressCfg.TotalLength
	self.timeRange = progressCfg.TotalLength
	self.reverseCountDown = false
	self.nowTime = gCS.TimeManager.ServerUnixTime
	self.needUpdate = true
	self.reverseCountDown = progressCfg.DefaultSpeed >= 0
	self.timeSpeed = math.abs(progressCfg.DefaultSpeed)
	self.rewardId = 0

	self:ProgressStateChange()
end

M.RefreshProgressInfo = function(self, templateId)
	local progressInfo = gNewGamePlayProgressMgr:GetCurrentProgress(1, templateId)

	if table.isNilOrEmpty(progressInfo) then
		return
	end

	progressInfo = progressInfo[1]
	local id = progressInfo.progressId
	local progress = gNewGamePlayProgressMgr:GetProgress(id)

	if progress then
		self.startTime = progress.startTime
		self.timeRange = progress.totalLength
		self.endTime = self.startTime + progress.totalLength
		self.reverseCountDown = progress.speed >= 0
		self.timeSpeed = math.abs(progress.speed)
	end
end

M.RefreshNowTime = function(self)
	self.nowTime = (gCS.TimeManager.ServerUnixTime - self.startTime) * self.timeSpeed + self.startTime
end

M.OnUpdate = function(self)
	if self.needUpdate then
		self.RefreshNowTime(self)

		if self.endTime < self.nowTime then
			self.FinishCountDown(self)

			return
		end

		self.RefreshCountDown(self)
	end
end

M.RefreshCountDown = function(self)
	if self.isPause then
		return
	end

	self.remainTime = self.endTime - self.nowTime
	self.bindData.countDownTime = self.GetFormatCountDownTime(self, self.nowTime)

	if self.needAlert and self.remainTime < self.warningTime then
		self.needAlert = false
		self.bindData.warningState = 1
	end
end

M.GetFormatCountDownTime = function(self, nowTime)
	local time = self.reverseCountDown and nowTime - self.startTime or self.endTime - nowTime
	local rawMin = time < 0 and 0 or math.floor(time / 60)
	local rawSec = 0
	local rawMs = 0

	if self.showMillisecond then
		local sec = time < 0 and 0 or (time - rawMin * 60) % 60
		rawSec = math.floor(sec)
		rawMs = (sec - rawSec) * 1000

		return gString.Format("%02d:%02d.%03d", rawMin, rawSec, rawMs), rawMin, rawSec, rawMs
	else
		if time < 0 then
			rawSec = 0
		else
			rawSec = math.floor((time - rawMin * 60) % 60)
		end

		return gString.Format("%02d:%02d", rawMin, rawSec), rawMin, rawSec
	end
end

M.FinishCountDown = function(self)
	self.needUpdate = false

	gPanelManager:Close(gPanelId.S_COMMON_ONLINE_IN_GAME_COUNT_DOWN)
end

M.DefineAllEnumsAutoGen = function(self)
	self.warningStateEnum = {
		["\\xee\\xda*\\xf6"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.warningStateEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if data.ToTable then
		data = data.ToTable(data)

		if data.Param and data.Param.ToTable then
			data.Param = data.Param:ToTable()
		end
	end

	self.templateId = nil
	local param = data.Param or data

	if param.isContinue and self.isCanContinue then
		return
	end

	if data.templateId then
		self.InitTemplateData(self, data.templateId)
	else
		self.InitPanelData(self, data, param)
	end

	self.bindData.root.anim:Play(self.openAnimName)
end

M.OnClose = function(self)
	local nowTime = gCS.TimeManager.ServerUnixTime

	if self.callBack then
		self:InvokeCallBack(self.callBack, nowTime <= self.endTime)
	end

	if self.spoonCallBack then
		self:InvokeCallBack(self.spoonCallBack, nowTime <= self.endTime)
	end

	self.callBack = nil
	self.spoonCallBack = nil
end

M.InvokeCallBack = function(self, cb, param)
	if type(cb) ~= "userdata" then
		cb.DynamicInvoke(cb, param, 0)
	else
		cb(param, 0)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
