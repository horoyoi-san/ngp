local RecordConfig = LTConfig.SyncValueConfig
local RecordParamConfig = LTConfig.SyncValueParameterConfig
local TemplateConfig = LTConfig.SyncValueUITemplateConfig
local TemplateCallConfig = LTConfig.SyncValueTemplateCallConfig
local ProgressConfig = LTConfig.SyncValueProgressConfig
C_RobBankCountdownStore = DefClass("C_RobBankCountdownStore", C_RobBankCountdownStore, C_StoreGroup)
GroupName2Class.RobBankCountdownStore = C_RobBankCountdownStore
local M = C_RobBankCountdownStore

function M:ctor()
	self.needAlert = false
	self.startTime = 0
	self.endTime = 0
	self.nowTime = 0
	self.remainTime = 0
	self.timeRange = 0
	self.isPause = false
	self.totalPoint = 0
	self.msgEvents = {
		[gEventConstants.TIMELINE_TO_PANEL] = self:CreateAction(self.AddMoney),
		[gEventConstants.ROB_BANK_DRILL_SHELF_REWARD] = self:CreateAction(self.AddMoney),
		[gEventConstants.FINISH_COUNT_DOWN_SET_CALLBACK] = self:CreateAction(self.SetCallBack),
		[gEventConstants.ADD_TIME_COUNT_DOWN] = self:CreateAction(self.OnAddTimeEvent),
		[gEventConstants.FINISH_COUNT_DOWN] = self:CreateAction(self.FinishCountDownEvent),
		[gEventConstants.ROB_BANK_ADD_MONEY] = self:CreateAction(self.RobberMoneyCount),
		[gEventConstants.ON_ROB_BANK_REWARD] = self:CreateAction(self.SetRewardId)
	}
	self.openAnimName = "S_Vx_RobBankCountdown_NormalOpen"
end

function M:OnAwake()
	return
end

function M:SetCallBack(eventId, data)
	self.callBack = data.callBack
end

function M:OnAddTimeEvent(eventId, data)
	local addTime = data.addTime

	self:AddTime(addTime)
end

function M:FinishCountDownEvent(event, data)
	self:FinishCountDown()
end

function M:FinishCountDown()
	self.needUpdate = false
	self.needUpdateClose = true
end

function M:SetRewardId(_, rewardId)
	self.rewardId = rewardId
end

function M:CalReward()
	local config = RecordParamConfig.GetConfig(self.rewardId)

	if config then
		math.randomseed(os.time())

		local addPoint = math.random(config.ValueOnceChangeRange.min, config.ValueOnceChangeRange.max)

		return addPoint
	end

	return nil
end

function M:AddMoney(eventId, data)
	if eventId == gEventConstants.TIMELINE_TO_PANEL and data[1] ~= gPanelId.S_ROB_BANK_COUNT_DOWN then
		return
	end

	if data.ToTable then
		data = data:ToTable()
	end

	local str = data[0] or data.score
	local addPoint = self:CalReward() or tonumber(str)

	if addPoint == nil or addPoint <= 0 then
		return
	end

	gGameplayRecordValueManager:ChangeRecordDoubleValue(self.syncValue, RecordParamConfig.CurrencyNum, addPoint, function ()
		self:AddMoneyEffect(addPoint, true)
	end)
end

function M:AddMoneyEffect(count, playAnim)
	local scrollNum = self.bindData.ScrollGroup
	scrollNum.startNum = self.totalPoint
	scrollNum.targetNum = self.totalPoint + count
	self.totalPoint = self.totalPoint + count

	scrollNum:SetToStartNum()
	scrollNum:Play()

	if playAnim then
		self.bindData.moneyText = tostring(count)

		self.bindData.plusComp.anim:Stop()
		self.bindData.plusComp.anim:Play()
	end
end

function M:RobberMoneyCount(_, count)
	local addCount = count - self.totalPoint

	self:AddMoneyEffect(addCount, false)
end

function M:InitTemplateData(templateId)
	local cfg = TemplateCallConfig.GetConfig(templateId)
	local progressCfg = ProgressConfig.GetConfig(cfg.UITemplateId)
	self.showMillisecond = false
	self.isPause = false
	self.startTime = gCS.TimeManager.ServerUnixTime
	self.needAlert = false
	self.warningTime = 0
	self.bindData.warningState = 0
	self.warningTime = 0
	self.endTime = self.startTime + progressCfg.StartLength
	self.timeRange = progressCfg.StartLength
	self.reverseCountDown = false
	self.nowTime = gCS.TimeManager.ServerUnixTime

	if cfg.UITemplateId == TemplateConfig.MoneyCounter then
		self.bindData.countDownTime = ""
	elseif cfg.UITemplateId == TemplateConfig.MoneyTimer then
		self.needUpdate = true
		self.needUpdateClose = false
		self.reverseCountDown = progressCfg.DefaultSpeed > 0
		self.timeSpeed = math.abs(progressCfg.DefaultSpeed)
		self.totalPoint = 0
		self.rewardId = 0

		self:RefreshCountDown()
	end

	local scrollNum = self.bindData.ScrollGroup
	scrollNum.startNum = self.totalPoint
	scrollNum.targetNum = self.totalPoint

	scrollNum:SetToStartNum()
end

function M:InitPanelData(data, param)
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
	local countDown = param.time > 0 and param.time or 0
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

function M:OnShow(panelId, data)
	if data.ToTable then
		data = data:ToTable()

		if data.Param and data.Param.ToTable then
			data.Param = data.Param:ToTable()
		end
	end

	local param = data.Param or data

	if param.isContinue and self.isCanContinue then
		return
	end

	if data.templateId then
		self:InitTemplateData(data.templateId)
	else
		self:InitPanelData(data, param)
	end

	local scrollNum = self.bindData.ScrollGroup
	scrollNum.startNum = self.totalPoint
	scrollNum.targetNum = self.totalPoint

	scrollNum:SetToStartNum()
	self:RefreshCountDown()
end

function M:BindDataSet()
	if self.dataSet then
		self.eventSet = C_DataEventSet.New()

		self.eventSet:BindHandler(self.dataSet, "isPause", self:CreateAction(self.PauseTime), nil, false)
	end
end

function M:PauseTime(cell)
	self.isPause = cell.value
	local now = gCS.TimeManager.ServerUnixTime

	if not self.isPause then
		self.endTime = now + self.remainTime
		self.startTime = now + self.timeRange - self.remainTime
	end
end

function M:OnAddTime(addTime)
	if addTime == nil then
		return
	end

	self:AddTime(addTime)
end

function M:OnAddMoney(addMoney)
	self:AddMoney(_, {
		score = addMoney
	})
end

function M:AddTime(addTime)
	self.endTime = self.endTime + addTime
	self.timeRange = self.timeRange + addTime

	self:RefreshNowTime()
	self:RefreshCountDown()
end

function M:BindEvents()
	if self.delegate then
		for i, v in pairs(self.delegate) do
			if self[i] ~= nil and type(self[i]) == "function" then
				v:RegisterHandler(self:CreateAction(self[i]))
			end
		end
	end
end

function M:UnBindEvents()
	if self.delegate then
		for i, v in pairs(self.delegate) do
			if self[i] ~= nil and type(self[i]) == "function" then
				v:UnregisterHandler(self:CreateAction(self[i]))
			end
		end
	end
end

function M:RefreshCountDown()
	if self.isPause then
		return
	end

	self.remainTime = self.endTime - self.nowTime
	self.bindData.countDownTime = self:GetFormatCountDownTime(self.nowTime)
	local fill = self.timeRange == 0 and 0 or Mathf.Clamp01(self.remainTime / self.timeRange)
	self.bindData.fillValue = self.reverseCountDown and 1 - fill or fill

	if self.needAlert and self.remainTime <= self.warningTime then
		self.needAlert = false
		self.bindData.warningState = 1
	end
end

function M:RefreshNowTime()
	self.nowTime = (gCS.TimeManager.ServerUnixTime - self.startTime) * self.timeSpeed + self.startTime
end

function M:OnUpdate()
	if self.needUpdate then
		self:RefreshNowTime()

		if self.endTime <= self.nowTime then
			self:FinishCountDown()
			self:RefreshCountDown()

			return
		end

		self:RefreshCountDown()
	end

	if self.needUpdateClose then
		self:RefreshNowTime()

		self.needUpdateClose = false

		gPanelManager:Close(gPanelId.S_ROB_BANK_COUNT_DOWN)
	end
end

function M:OnClose()
	local nowTime = gCS.TimeManager.ServerUnixTime

	if self.callBack then
		self:InvokeCallBack(self.callBack, nowTime < self.endTime)
	end

	if self.spoonCallBack then
		self:InvokeCallBack(self.spoonCallBack, nowTime < self.endTime)
	end

	self.callBack = nil
	self.spoonCallBack = nil
end

function M:InvokeCallBack(cb, param)
	if type(cb) == "userdata" then
		cb:DynamicInvoke(param)
	else
		cb(param)
	end
end

function M:GetFormatCountDownTime(nowTime)
	local time = self.reverseCountDown and nowTime - self.startTime or self.endTime - nowTime
	local rawMin = time <= 0 and 0 or math.floor(time / 60)
	local rawSec = 0
	local rawMs = 0

	if self.showMillisecond then
		local sec = time <= 0 and 0 or (time - rawMin * 60) % 60
		rawSec = math.floor(sec)
		rawMs = (sec - rawSec) * 1000

		return gString.Format("%02d:%02d.%03d", rawMin, rawSec, rawMs), rawMin, rawSec, rawMs
	else
		if time <= 0 then
			rawSec = 0
		else
			rawSec = math.floor((time - rawMin * 60) % 60)
		end

		return gString.Format("%02d:%02d", rawMin, rawSec), rawMin, rawSec
	end
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end
