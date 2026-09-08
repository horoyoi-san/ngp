-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RobBankCountdownStore.lua
-- Decompiled from: 00921_RobBankCountdownStore.lua_17fdbb72cc42.luajit

local RecordConfig = LTConfig.SyncValueConfig
local RecordParamConfig = LTConfig.SyncValueParameterConfig
local TemplateConfig = LTConfig.SyncValueUITemplateConfig
local TemplateCallConfig = LTConfig.SyncValueTemplateCallConfig
local ProgressConfig = LTConfig.SyncValueProgressConfig
local SyncProgressConfig = LTConfig.SyncValueSyncProgressConfig
C_RobBankCountdownStore = DefClass("C_RobBankCountdownStore", C_RobBankCountdownStore, C_StoreGroup)
GroupName2Class.RobBankCountdownStore = C_RobBankCountdownStore
local M = C_RobBankCountdownStore

M.ctor = function(self)
	self.needAlert = false
	self.startTime = 0
	self.endTime = 0
	self.nowTime = 0
	self.remainTime = 0
	self.timeRange = 0
	self.isPause = false
	self.totalPoint = 0
	self.msgEvents = {
		[gEventConstants.TIMELINE_TO_PANEL] = self.CreateAction(self, self.AddMoney),
		[gEventConstants.ROB_BANK_DRILL_SHELF_REWARD] = self.CreateAction(self, self.AddMoneyByRewardId),
		[gEventConstants.FINISH_COUNT_DOWN_SET_CALLBACK] = self.CreateAction(self, self.SetCallBack),
		[gEventConstants.ADD_TIME_COUNT_DOWN] = self.CreateAction(self, self.OnAddTimeEvent),
		[gEventConstants.FINISH_COUNT_DOWN] = self.CreateAction(self, self.FinishCountDownEvent),
		[gEventConstants.ROB_BANK_ADD_MONEY] = self.CreateAction(self, self.RobberMoneyCount),
		[gEventConstants.ON_ROB_BANK_REWARD] = self.CreateAction(self, self.SetRewardId),
		[gEventConstants.PROGRESS_STATE_CHANGE] = self.CreateAction(self, self.ProgressStateChange)
	}
	self.openAnimName = "S_Vx_RobBankCountdown_NormalOpen"
end

M.OnAwake = function(self)
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

M.FinishCountDown = function(self)
	self.needUpdate = false
	self.needUpdateClose = true
end

M.SetRewardId = function(self, _, rewardId)
	self.rewardId = rewardId
end

M.CalReward = function(self)
	local config = RecordParamConfig.GetConfig(self.rewardId)

	if config then
		math.randomseed(os.time())

		local addPoint = math.random(config.ValueOnceChangeRange.min, config.ValueOnceChangeRange.max)

		return addPoint
	end

	return nil
end

M.AddMoneyByRewardId = function(self, eventId, data)
	if data.rewardId ~= nil or data.rewardId ~= 0 then
		return
	end

	self.rewardId = data.rewardId

	self.AddMoney(self, eventId, data)
end

M.SyncRefreshMoney = function(self)
	slot1 = gClientToGameSceneDelegate

	slot1:AskGetRaidGamePlayRecordDoubleValue(self.syncValue).Callback = function (err, money)
		if err == 0 then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		local addCount = money - self.totalPoint

		self:AddMoneyEffect(addCount, false)
	end
end

M.AddMoney = function(self, eventId, data)
	if eventId ~= gEventConstants.TIMELINE_TO_PANEL and data[1] == gPanelId.S_ROB_BANK_COUNT_DOWN then
		return
	end

	if data.ToTable then
		data = data.ToTable(data)
	end

	local str = data[0] or data.score
	local addPoint = self:CalReward() or tonumber(str)

	if addPoint ~= nil or addPoint < 0 then
		return
	end

	slot5 = gGameplayRecordValueManager

	slot5:ChangeRecordDoubleValue(self.syncValue, self.rewardId, addPoint, function ()
		self:AddMoneyEffect(addPoint, true)
	end)
end

M.AddMoneyEffect = function(self, count, playAnim)
	if playAnim then
		self.bindData.moneyText = tostring(count)

		self.bindData.plusComp.anim:Stop()
		self.bindData.plusComp.anim:Play()
	else
		local scrollNum = self.bindData.ScrollGroup
		scrollNum.startNum = self.totalPoint
		scrollNum.targetNum = self.totalPoint + count
		self.totalPoint = self.totalPoint + count

		scrollNum.SetToStartNum(scrollNum)
		scrollNum.Play(scrollNum)
	end
end

M.RobberMoneyCount = function(self, _, data)
	if data.recordId ~= self.syncValue then
		local addCount = data.recordValue - self.totalPoint

		self.AddMoneyEffect(self, addCount, false)
	end
end

M.ProgressStateChange = function(self, _, data)
	if self.templateId then
		self.RefreshProgressInfo(self, self.templateId)
		self.RefreshCountDown(self)
	end
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
	self.needAlert = false
	self.warningTime = 0
	self.bindData.warningState = 0
	self.warningTime = 0
	self.endTime = self.startTime + progressCfg.TotalLength
	self.timeRange = progressCfg.TotalLength
	self.reverseCountDown = false
	self.nowTime = gCS.TimeManager.ServerUnixTime
	self.syncValue = cfg.RecordIdList[1] or RecordConfig.RobDrop

	if cfg.UITemplateId ~= TemplateConfig.MoneyCounter then
		self.bindData.countDownTime = ""
	elseif cfg.UITemplateId ~= TemplateConfig.MoneyTimer then
		self.needUpdate = true
		self.needUpdateClose = false
		self.reverseCountDown = progressCfg.DefaultSpeed >= 0
		self.timeSpeed = math.abs(progressCfg.DefaultSpeed)
		self.totalPoint = 0
		self.rewardId = 0

		self:RefreshProgressInfo(templateId)
		self:SyncRefreshMoney()
		self:RefreshCountDown()
	end

	local scrollNum = self.bindData.ScrollGroup
	scrollNum.startNum = self.totalPoint
	scrollNum.targetNum = self.totalPoint

	scrollNum.SetToStartNum(scrollNum)
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

M.InitPanelData = function(self, data, param)
	self.spoonCallBack = data.CallBack
	self.dataSet = data.DataSet
	self.delegate = data.Delegate

	self:BindDataSet()
	self:BindEvents()

	self.syncValue = data.syncValue or RecordConfig.RobDrop
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
	self.needUpdateClose = false
	self.nowTime = gCS.TimeManager.ServerUnixTime
	self.totalPoint = 0

	self.bindData.coutDown.anim:Play(self.openAnimName)

	self.rewardId = 0
	self.timeSpeed = 1
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

	local scrollNum = self.bindData.ScrollGroup
	scrollNum.startNum = self.totalPoint
	scrollNum.targetNum = self.totalPoint

	scrollNum.SetToStartNum(scrollNum)
	self.RefreshCountDown(self)
end

M.BindDataSet = function(self)
	if self.dataSet then
		self.eventSet = C_DataEventSet.New()

		self.eventSet:BindHandler(self.dataSet, "isPause", self:CreateAction(self.PauseTime), nil, false)
	end
end

M.PauseTime = function(self, cell)
	self.isPause = cell.value
	local now = gCS.TimeManager.ServerUnixTime

	if not self.isPause then
		self.endTime = now + self.remainTime
		self.startTime = now + self.timeRange - self.remainTime
	end
end

M.OnAddTime = function(self, addTime)
	if addTime ~= nil then
		return
	end

	self.AddTime(self, addTime)
end

M.AddTime = function(self, addTime)
	self.endTime = self.endTime + addTime
	self.timeRange = self.timeRange + addTime

	self.RefreshNowTime(self)
	self.RefreshCountDown(self)
end

M.BindEvents = function(self)
	if self.delegate then
		for i, v in pairs(self.delegate) do
			if self[i] == nil and type(self[i]) ~= "function" then
				v.RegisterHandler(v, self.CreateAction(self, self[i]))
			end
		end
	end
end

M.UnBindEvents = function(self)
	if self.delegate then
		for i, v in pairs(self.delegate) do
			if self[i] == nil and type(self[i]) ~= "function" then
				v.UnregisterHandler(v, self.CreateAction(self, self[i]))
			end
		end
	end
end

M.RefreshCountDown = function(self)
	if self.isPause then
		return
	end

	self.remainTime = self.endTime - self.nowTime
	self.bindData.countDownTime = self:GetFormatCountDownTime(self.nowTime)
	local fill = self.timeRange ~= 0 and 0 or Mathf.Clamp01(self.remainTime / self.timeRange)
	self.bindData.fillValue = self.reverseCountDown and 1 - fill or fill

	if self.needAlert and self.remainTime < self.warningTime then
		self.needAlert = false
		self.bindData.warningState = 1
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
			self.RefreshCountDown(self)

			return
		end

		self.RefreshCountDown(self)
	end

	if self.needUpdateClose then
		self:RefreshNowTime()

		self.needUpdateClose = false

		gPanelManager:Close(gPanelId.S_ROB_BANK_COUNT_DOWN)
	end
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

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end
