C_GameplayCountDownStore = DefClass("C_GameplayCountDownStore", C_GameplayCountDownStore, C_StoreGroup)
GroupName2Class.GameplayCountDownStore = C_GameplayCountDownStore
local M = C_GameplayCountDownStore

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
		[gEventConstants.FINISH_COUNT_DOWN_SET_CALLBACK] = self:CreateAction(self.SetCallBack),
		[gEventConstants.ADD_TIME_COUNT_DOWN] = self:CreateAction(self.OnAddTimeEvent),
		[gEventConstants.PAUSE_COUNT_DOWN] = self:CreateAction(self.PauseTimeEvent),
		[gEventConstants.FINISH_COUNT_DOWN] = self:CreateAction(self.FinishCountDownEvent),
		[gEventConstants.RESET_COUNT_DOWN] = self:CreateAction(self.ResetCountDownEvent)
	}
	self.openAnimName = "S_Vx_TimerPanel_open"
	self.closeAnimName = "S_Vx_TimerPanel_close"
end

function M:OnAwake()
	return
end

function M:OnShow(panelId, data)
	if data.ToTable then
		data = data:ToTable()

		if data.Param.ToTable then
			data.Param = data.Param:ToTable()
		end
	end

	local param = nil

	if data and data.rawParam == true then
		param = data
		data = {}
	else
		param = data.Param
	end

	self.id = data.id or 0
	self.callBack = data.CallBack
	self.dataSet = data.DataSet
	self.delegate = data.Delegate

	self:BindDataSet()
	self:BindEvents()

	self.isPlayEndAnim = false
	self.unLimit = param.time == -1 and param.isIncrease
	self.showMillisecond = param.isShowMilliseconds
	self.startTime = gLogicTime.time
	self.needAlert = param.warningTime and true or false
	self.warningTime = param.warningTime and param.warningTime or 0
	local countDown = param.time > 0 and param.time or 0
	self.endTime = self.startTime + countDown
	self.timeRange = countDown
	self.reverseCountDown = param.isIncrease or false
	self.needUpdate = true
	self.needUpdateClose = false
	self.nowTime = gLogicTime.time
	self.closeTime = self.bindData.root.anim:GetClip(self.closeAnimName).length

	self.bindData.root.anim:Play(self.openAnimName)

	self.runTime = 0
	self.bindData.iconState = self.unLimit and 1 or 0

	self:RefreshCountDown()
	self:PauseTime(param.isPause or false)
end

function M:SetCallBack(eventId, data)
	if data.ToTable then
		data = data:ToTable()
	end

	self.callBack = data.callBack
end

function M:OnAddTimeEvent(eventId, data)
	local addTime = data.addTime

	if data.id == nil then
		data.id = 0
	end

	if data.id == self.id then
		self:AddTime(addTime)
	end
end

function M:PauseTimeEvent(eventId, data)
	local isPause = data.isPause

	if data.id == nil then
		data.id = 0
	end

	if data.id == self.id and isPause == nil then
		isPause = true
	end

	self:PauseTime(data.isPause)
end

function M:FinishCountDownEvent(event, data)
	if data.ToTable then
		data = data:ToTable()
	end

	if data.id == nil then
		data.id = 0
	end

	if data.id == self.id then
		self:FinishCountDown()
	end
end

function M:ResetCountDownEvent(event, data)
	self.startTime = gLogicTime.time
	self.endTime = self.startTime + data.time
	self.timeRange = data.time

	self:RefreshCountDown()
end

function M:FinishCountDown()
	self.needUpdate = false
	self.needUpdateClose = true
	self.endTime = gLogicTime.time
	self.timeRange = self.endTime - self.startTime
end

function M:FinishCountDownEnd()
	self.needUpdateClose = false
	self.needUpdate = false
end

function M:BindDataSet()
	if self.dataSet then
		self.eventSet = C_DataEventSet.New()

		self.eventSet:BindHandler(self.dataSet, "isPause", self:CreateAction(self.CellPauseTime), nil, false)
		self.eventSet:BindHandler(self.dataSet, "countDown", self:CreateAction(self.CellRefreshCountDown), nil, false)
	end
end

function M:CellPauseTime(cell)
	self:PauseTime(cell.value)
end

function M:PauseTime(value)
	self.isPause = value
	local now = gLogicTime.time

	if self.isPause then
		self.runTime = now - self.startTime
		self.remainTime = self.endTime - now
	else
		self.endTime = now + self.remainTime
		self.startTime = now - self.runTime
	end
end

function M:CellRefreshCountDown(cell)
	local newTime = cell.value
	self.timeRange = newTime
	self.startTime = gLogicTime.time
	self.endTime = newTime + self.startTime

	self:RefreshCountDown()
end

function M:OnAddTime(addTime)
	if addTime == nil then
		return
	end

	self:AddTime(addTime)
end

function M:AddTime(addTime)
	self.endTime = self.endTime + addTime
	self.timeRange = self.timeRange + addTime
	self.nowTime = gLogicTime.time

	self:RefreshCountDown()
end

function M:BindEvents()
	if self.delegate then
		for i, v in pairs(self.delegate) do
			if self[i] ~= nil and type(self[i]) == "function" then
				v:RegisterHandler(0, self:CreateAction(self[i]))
			end
		end
	end
end

function M:UnBindEvents()
	if self.delegate then
		for i, v in pairs(self.delegate) do
			if self[i] ~= nil and type(self[i]) == "function" then
				v:UnregisterHandler(0, self:CreateAction(self[i]))
			end
		end
	end
end

function M:RefreshCountDown()
	if self.isPause then
		return
	end

	self.runTime = self.nowTime - self.startTime
	self.remainTime = self.endTime - self.nowTime
	self.bindData.countDownTime = self:GetFormatCountDownTime(self.nowTime)
	local fill = self.timeRange == 0 and 0 or Mathf.Clamp01(self.remainTime / self.timeRange)
	self.bindData.fillValue = self.reverseCountDown and 1 - fill or fill
	self.bindData.warningState = self.needAlert and self.remainTime <= self.warningTime and 1 or 0
end

function M:OnUpdate()
	if self.needUpdate then
		self.nowTime = gLogicTime.time

		if self.endTime <= self.nowTime and not self.unLimit then
			self:FinishCountDown()
			self:RefreshCountDown()

			return
		end

		self:RefreshCountDown()
	end

	if self.needUpdateClose then
		self.nowTime = gLogicTime.time

		if not self.isPlayEndAnim then
			self.isPlayEndAnim = true

			self.bindData.root.anim:Play(self.closeAnimName)
		end

		if self.closeTime <= self.nowTime - self.endTime then
			self.needUpdateClose = false

			gPanelManager:Close(gPanelId.S_GAMEPLAY_COUNT_DOWN)
		end
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

function M:OnClose()
	if self.callBack ~= nil then
		self.callBack()
	end

	self:FinishCountDownEnd()

	self.callBack = nil
end
