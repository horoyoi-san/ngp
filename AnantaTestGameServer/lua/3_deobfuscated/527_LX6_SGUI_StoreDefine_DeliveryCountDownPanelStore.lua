C_DeliveryCountDownPanelStore = DefClass("C_DeliveryCountDownPanelStore", C_DeliveryCountDownPanelStore, C_StoreGroup)
GroupName2Class.DeliveryCountDownPanelStore = C_DeliveryCountDownPanelStore
local M = C_DeliveryCountDownPanelStore

function M:OnAwake()
	self.openAnimeName = "S_Vx_TimerPanel_open"
	self.alertAnimeName = "S_Vx_TimerPanel_red10s"
	self.closeAnimeName = "S_Vx_TimerPanel_close"
	self.needAlert = false
	self.startTime = 0
	self.endTime = 0
	self.nowTime = 0
	self.remainTime = 0
	self.timeRange = 0
	self.msgEvents = {
		[gEventConstants.ON_GOOD_COUNT_DOWN_FINISH] = self:CreateAction(self.ClosePanel)
	}
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:ClosePanel()
	gCS.LuaUtils.StopCurrentAnimation(self.bindData.anime)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.closeAnimeName)
	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.S_DELIVERY_COUNT_DOWN_PANEL)
	end, self.closeTime)
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnShow(panelId, data)
	self.needAlert = data.redTenSeconds
	self.startTime = gCS.TimeManager.ServerUnixTime
	local countDown = data.countDownSecondNum > 0 and data.countDownSecondNum or 0
	self.endTime = self.startTime + countDown
	self.timeRange = countDown
	self.reverseCountDown = not data.isCountDown
	self.closeCallback = data and data.callback or data.CallBack
	self.needUpdate = true
	self.nowTime = gCS.TimeManager.ServerUnixTime
	self.showMillisecond = data.showMillisecond
	self.closeTime = self.bindData.anime:GetClip(self.closeAnimeName).length
	self.bindData.overtimeState = 0

	self:RefreshCountDown()

	if not self:RefreshAlert() then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.openAnimeName)
	end
end

function M:RefreshCountDown()
	if self.isMatchGameCountDown and self.reverseCountDown then
		self.bindData.countDownTime = self:GetFormatCountDownTime(self.nowTime + self.matchGameCountDown)
	else
		self.bindData.countDownTime = self:GetFormatCountDownTime(self.nowTime)
	end

	self.remainTime = self.endTime - self.nowTime
	local fill = self.timeRange == 0 and 0 or Mathf.Clamp01(self.remainTime / self.timeRange)
	self.bindData.counterFillAmount = self.reverseCountDown and 1 - fill or fill
end

function M:RefreshAlert()
	if self.needAlert and self.remainTime <= 10 then
		self.needAlert = false

		gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.alertAnimeName)

		return true
	end

	return false
end

function M:OnUpdate()
	if self.needUpdate then
		self.nowTime = gCS.TimeManager.ServerUnixTime

		if self.endTime <= self.nowTime then
			self.needUpdate = false
			self.bindData.overtimeState = 1

			self:RefreshCountDown()

			return
		end

		self:RefreshCountDown()
		self:RefreshAlert()
	end
end

function M:OnClose()
	if self.closeCallback then
		self.closeCallback()
	end

	self.closeCallback = nil
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
