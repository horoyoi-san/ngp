C_ChallengeCountDownPanelStore = DefClass("C_ChallengeCountDownPanelStore", C_ChallengeCountDownPanelStore, C_StoreGroup)
GroupName2Class.ChallengeCountDownPanelStore = C_ChallengeCountDownPanelStore
local M = C_ChallengeCountDownPanelStore

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
	self.inLink = gLinkManager:CheckInLinkMode()
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnShow(panelId, data)
	if type(data) == "userdata" then
		data = data:ToTable()
	end

	self.needAlert = data.redTenSeconds
	self.startTime = self.inLink and gLogicTime.unscaledTime or gLogicTime.time
	local countDown = math.max(data.countDownSecondNum or 0, 0)
	self.endTime = self.startTime + countDown
	self.timeRange = countDown
	self.reverseCountDown = not data.isCountDown
	self.closeCallback = data and (data.callback or data.CallBack)
	self.needUpdate = true
	self.needUpdateClose = false
	self.nowTime = self.inLink and gLogicTime.unscaledTime or gLogicTime.time
	self.showMillisecond = data.showMillisecond
	self.closeTime = self.bindData.anime:GetClip(self.closeAnimeName).length

	self:CheckMatchGameCountDown(data.isMatchGameCountDown)
	self:RefreshCountDown()

	if not self:RefreshAlert() then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.openAnimeName)
	end

	gMessageManager:SendMessage(gEventConstants.BOSS_HP_PANEL_DOWN, true)
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

	if self.needAlert and self.remainTime <= 10 then
		self.needAlert = false

		gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.alertAnimeName)
	end
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
		self.nowTime = self.inLink and gLogicTime.unscaledTime or gLogicTime.time

		if self.endTime <= self.nowTime then
			if self.bindData.anime then
				gCS.LuaUtils.PlayAnimationByName(self.bindData.anime, self.closeAnimeName)
			end

			self.needUpdate = false
			self.needUpdateClose = true

			self:RefreshCountDown()

			return
		end

		self:RefreshCountDown()
		self:RefreshAlert()
	end

	if self.needUpdateClose then
		self.nowTime = self.inLink and gLogicTime.unscaledTime or gLogicTime.time

		if self.closeTime <= self.nowTime - self.endTime then
			self.needUpdateClose = false

			gPanelManager:Close(gPanelId.S_CHALLENGE_COUNTDOWN_PANEL)
		end
	end
end

function M:OnClose()
	if self.closeCallback then
		local nowTime = self.inLink and gLogicTime.unscaledTime or gLogicTime.time

		self:InvokeCallBack(self.closeCallback, nowTime < self.endTime)
	end

	self.closeCallback = nil

	gMessageManager:SendMessage(gEventConstants.BOSS_HP_PANEL_DOWN, false)
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

function M:CheckMatchGameCountDown(isMatchGameCountDown)
	self.isMatchGameCountDown = false
	self.matchGameCountDown = 0

	if isMatchGameCountDown then
		local matchGameCountDown = self:GetMatchGameCountDown()

		if matchGameCountDown > 0 then
			self.endTime = self.endTime - matchGameCountDown
			self.isMatchGameCountDown = true
			self.matchGameCountDown = matchGameCountDown
		end
	end
end

function M:GetMatchGameCountDown()
	if not gLinkManager.gameStartTime or not gLinkManager.targetPlayId or gLinkManager.gameStartTime == 0 or gLinkManager.targetPlayId == 0 then
		return -1
	end

	local cfg = LTConfig.LinkMultiPlayerConfig.GetConfig(gLinkManager.targetPlayId)

	if not cfg then
		return -1
	end

	local countDown = gLuaDataManager.serverTime - cfg.StartTime - gLinkManager.gameStartTime

	return countDown
end
