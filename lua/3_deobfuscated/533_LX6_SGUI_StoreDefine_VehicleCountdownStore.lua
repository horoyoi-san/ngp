C_VehicleCountdownStore = DefClass("C_VehicleCountdownStore", C_VehicleCountdownStore, C_StoreGroup)
GroupName2Class.VehicleCountdownStore = C_VehicleCountdownStore
local M = C_VehicleCountdownStore
local GameConfig = LTConfig.GameConfig

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()

	self.inLink = gLinkManager:CheckInLinkMode()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.startTime = self.inLink and gLogicTime.unscaledTime or gLogicTime.time
	local countDown = data.countDownSecondNum > 0 and data.countDownSecondNum or 0
	self.endTime = self.startTime + countDown
	self.timeRange = countDown
	self.reverseCountDown = not data.isCountDown
	self.showMillisecond = data.showMillisecond
	self.needUpdate = true
	self.nowTime = self.inLink and gLogicTime.unscaledTime or gLogicTime.time
	self.needPlayLoopAni = data.enableBlink
	self.needPlayEndAni = not data.isRed
	self.playedAni = false
	self.closeTime = nil

	self:RefreshCountDown()

	self.bindData.typeCtrl = data.isRed and 0 or 1
	self.bindData.showTimeText = data.showTimeText and 0 or 1
	self.bindData.countDownCtrl = data.showProgressBar and 0 or 1
	local page = 0

	if data.textId and data.textId > 0 then
		local titleCfg = LTConfig.TextConfig.GetConfig(data.textId)

		if titleCfg then
			self.bindData.title = titleCfg.Text
			page = 1
		end
	end

	self.bindData.showCustomText = page
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	return
end

function M:OnUpdate()
	if self.needUpdate then
		if self.closeTime then
			self.closeTime = self.closeTime - Time.deltaTime

			if self.closeTime < 0 then
				self.closeTime = nil

				self.bindData.anim:Stop()
				gPanelManager:Close(gPanelId.VEHICLE_COUNTDOWN)
			end
		else
			self.nowTime = self.inLink and gLogicTime.unscaledTime or gLogicTime.time

			if self.endTime <= self.nowTime then
				self:RefreshCountDown()

				if self.needPlayEndAni then
					self.closeTime = 0.57

					self.bindData.anim:Play("Vx_S_VehicleCountdown_2")
				else
					self.needUpdate = false

					gPanelManager:Close(gPanelId.VEHICLE_COUNTDOWN)
				end
			else
				self:RefreshCountDown()
			end
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

function M:RefreshCountDown()
	self.bindData.time = self:GetFormatCountDownTime(self.nowTime)
	self.remainTime = self.endTime - self.nowTime
	local fill = self.timeRange == 0 and 0 or Mathf.Clamp01(self.remainTime / self.timeRange)
	self.bindData.countDownProgress = self.reverseCountDown and 1 - fill or fill

	if self.needPlayLoopAni and self.remainTime <= GameConfig.VehicleChasingUITime then
		if not self.playedAni then
			self.playedAni = true

			self.bindData.anim:Play("Vx_S_VehicleCountdown_1")
		end

		local aniSpeed = self:GetAnimSpeed(self.remainTime)

		SGUI.ExtensionMethod.SetAnimationSpeed(self.bindData.anim, "Vx_S_VehicleCountdown_1", aniSpeed)
	end
end

function M:GetAnimSpeed(remainTime)
	local time = remainTime / GameConfig.VehicleChasingUITime
	time = Mathf.Clamp01(time)

	return (1 - time) * (GameConfig.VehicleChasingAnimationSpeedMax - GameConfig.VehicleChasingAnimationSpeedMin) + GameConfig.VehicleChasingAnimationSpeedMin
end
