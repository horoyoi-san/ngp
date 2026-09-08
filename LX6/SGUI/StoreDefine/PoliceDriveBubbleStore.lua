-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceDriveBubbleStore.lua
-- Decompiled from: 00785_PoliceDriveBubbleStore.lua_7d0685aacabd.luajit

C_PoliceDriveBubbleStore = DefClass("C_PoliceDriveBubbleStore", C_PoliceDriveBubbleStore, C_StoreGroup)
GroupName2Class.PoliceDriveBubbleStore = C_PoliceDriveBubbleStore
local M = C_PoliceDriveBubbleStore

M.ctor = function(self)
	self.scoreAnimOpenName = "S_Vx_PoliceDriveBubble_open"
	self.scoreAnimCloseName = "S_Vx_PoliceDriveBubble_close"
	self.timeAnimName = "S_Vx_BasketBallGamePanel_Bubble_times3"
	self.totalScore = 0
	self.startTime = 0
	self.endTime = 0
	self.nowTime = 0
	self.remainTime = 0
	self.enterContinuous = false
	self.enterAetherLaneCheck = false
	self.addValue = 0
	self.vehicleUid = 0
	self.distanceAwayFromVehicleLane = 0
	self.distanceCloseToPedLane = 0
	self.angleThresholdForWrongWay = 0
	self.curAetherLaneCheckTime = 0
	self.contextId = 0
end

M.OnGroupEnable = function(self)
	self.msgEvents = {
		[gEventConstants.SAFE_DRIVE_ADD_TIME] = function (eventId, data)
			self:OnAddTime(data)
		end,
		[gEventConstants.SAFE_DRIVE_DECREASE_TIME] = function (eventId, data)
			self:OnDecreaseTime(data)
		end,
		[gEventConstants.SAFE_DRIVE_ADD_SCORE] = function (eventId, data)
			self:OnAddScore(data)
		end,
		[gEventConstants.SAFE_DRIVE_DECREASE_SCORE] = function (eventId, data)
			self:OnDecreaseScore(data)
		end,
		[gEventConstants.SAFE_DRIVE_CONTINUOUS_CHANGE] = function (eventId, data)
			self:ContinuousChange(data)
		end,
		[gEventConstants.SAFE_DRIVE_AETHER_LANE_CHECK] = function (eventId, data)
			self:AetherLaneCheckChange(data)
		end,
		[gEventConstants.SAFE_DRIVE_EXPRESSION_CHANGE] = function (eventInfo, data)
			self:OnMoodCtrlChange(data)
		end
	}

	self:RegisterMessageEvents(self.msgEvents)

	if self.bindData.scoreAnim:GetClip(self.scoreAnimOpenName) then
		self.openAnimTime = self.bindData.scoreAnim:GetClip(self.scoreAnimOpenName).length
	end

	if self.bindData.scoreAnim:GetClip(self.scoreAnimCloseName) then
		self.closeAnimTime = self.bindData.scoreAnim:GetClip(self.scoreAnimCloseName).length
	end
end

M.OnMoodCtrlChange = function(self, moodEmotionState)
	if not moodEmotionState then
		print_error("moodEmotionState is nil")

		return
	end

	self.bindData.moodCtrl = moodEmotionState
end

M.AetherLaneCheckChange = function(self, data)
	self.enterAetherLaneCheck = data.isStart or false

	if self.enterAetherLaneCheck and data.vehicleUid then
		self.vehicleUid = data.vehicleUid
		self.distanceAwayFromVehicleLane = data.distanceAwayFromVehicleLane
		self.angleThresholdForWrongWay = data.angleThresholdForWrongWay
		self.distanceCloseToPedLane = data.distanceCloseToPedLane
		self.contextId = data.clientContextId
	end
end

M.ContinuousChange = function(self, data)
	self.enterContinuous = data.isEnter
	self.bindData.state = data.isEnter and 1 or 0

	if self.enterContinuous then
		self.addValue = data.addValue or self.addValue
	end
end

M.RefreshCountDown = function(self)
	self.nowTime = gLogicTime.time
	self.bindData.countDownTime = self.GetFormatCountDownTime(self, self.nowTime)
	self.remainTime = math.max(self.endTime - self.nowTime, 0)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, totalTime)
	self.bindData.scoreText = 0
	self.totalScore = 0
	self.bindData.moodCtrl = 0
	gMiniGameDataManager.safeDriveScore = self.totalScore
	self.startTime = gLogicTime.time
	self.endTime = self.startTime + totalTime
	self.timeRange = self.endTime
	self.needUpdate = true
	self.needUpdateClose = false
	self.bindData.totalScore = string.format("%.2f", self.totalScore)
	self.enterContinuous = false
	self.addPlayedTimes = 0
	self.addTotalTimes = 0
	self.currentAddTime = 0

	self:RefreshCountDown()

	self.bindData.countDownTime = self:GetFormatCountDownTime(self.nowTime)

	self.bindData.scoreRoot.gameObject:SetActive(false)
	self.bindData.timeRoot.gameObject:SetActive(false)

	self.bindData.state = 0
	self.vehicleUid = 0
	self.distanceAwayFromVehicleLane = 0
	self.distanceCloseToPedLane = 0
	self.angleThresholdForWrongWay = 0
	self.curAetherLaneCheckTime = 0
end

M.OnUpdate = function(self)
	if self.needUpdate then
		self.RefreshCountDown(self)

		if self.enterContinuous and self.addValue <= 0 then
			self.totalScore = self.totalScore + self.addValue
			gMiniGameDataManager.safeDriveScore = self.totalScore
			self.bindData.totalScore = string.format("%.2f", self.totalScore)
		end

		if self.enterAetherLaneCheck then
			self.curAetherLaneCheckTime = self.curAetherLaneCheckTime + Time.deltaTime

			if self.curAetherLaneCheckTime > 1 then
				gCS.LuaUtils.SafeDriveAetherLaneCheck(self.vehicleUid, self.distanceAwayFromVehicleLane, self.distanceCloseToPedLane, self.angleThresholdForWrongWay, self.contextId)

				self.curAetherLaneCheckTime = 0
			end
		end

		if self.remainTime < 0 then
			self.needUpdate = false
			self.needUpdateClose = true

			if self.enterAetherLaneCheck then
				self.enterAetherLaneCheck = false
				self.curAetherLaneCheckTime = 0
			end
		end
	end

	if self.needUpdateClose then
		gMessageManager:SendMessage(gEventConstants.ON_SAFE_DRIVE_END)
		gPanelManager:Close(gPanelId.POLICE_DRIVE_BUBBLE_PANEL)
	end
end

M.OnAddTime = function(self, data)
	if self.timeTimer then
		self.timeTimer:Stop()

		self.timeTimer = nil
	end

	self.endTime = self.endTime + data

	self:RefreshCountDown()
	self.bindData.timeRoot.gameObject:SetActive(false)

	self.bindData.timeCtrl = 0
	self.bindData.addTimeText = tostring(data)

	self.bindData.timeRoot.gameObject:SetActive(true)

	local clip = self.bindData.timeAnim:GetClip(self.timeAnimName)

	self.bindData.timeAnim:Play(self.timeAnimName)

	self.timeTimer = Timer.New(function ()
		if self.bindData.timeRoot then
			self.bindData.timeRoot.gameObject:SetActive(false)
		end

		self.timeTimer = nil
	end, clip.length, nil):Start()
end

M.OnDecreaseTime = function(self, data)
	if self.timeTimer then
		self.timeTimer:Stop()

		self.timeTimer = nil
	end

	local newEndTime = self.endTime - data
	self.endTime = math.max(newEndTime, self.startTime)

	self.RefreshCountDown(self)

	if self.remainTime < 0 then
		self.needUpdate = false
		self.needUpdateClose = true
	end

	self.bindData.timeRoot.gameObject:SetActive(false)

	self.bindData.timeCtrl = 1
	self.bindData.addTimeText = tostring(data)

	self.bindData.timeRoot.gameObject:SetActive(true)

	local clip = self.bindData.punishAnim:GetClip(self.timeAnimName)

	self.bindData.timeAnim:Play(self.timeAnimName)

	self.timeTimer = Timer.New(function ()
		if self.bindData.timeRoot then
			self.bindData.timeRoot.gameObject:SetActive(false)
		end

		self.timeTimer = nil
	end, clip.length, nil):Start()
end

M.ResetAnimation = function(self, animation, clipName)
	if not animation or not clipName then
		return
	end

	animation.Stop(animation)

	local animationState = animation.get_Item(animation, clipName)

	if animationState then
		animationState.time = 0
		animationState.enabled = true

		animation.Sample(animation)
		animation.Play(animation, clipName)
	end
end

M.OnAddScore = function(self, data)
	if self.timeTimer then
		self.timeTimer:Stop()
	end

	self.bindData.scoreRoot.gameObject:SetActive(true)

	self.bindData.scoreCtrl = 0
	self.bindData.scoreText = LTConfig.TextCommonTextConfig.GetConfig(data.textId).Text or ""
	self.bindData.scoreNumText = data.addScore
	self.totalScore = self.totalScore + data.addScore
	gMiniGameDataManager.safeDriveScore = self.totalScore
	self.bindData.totalScore = string.format("%.2f", self.totalScore)

	self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimOpenName)

	self.timeTimer = Timer.New(function ()
		if self.bindData.scoreAnim then
			self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimCloseName)
		end

		Timer.New(function ()
			if self.bindData.scoreRoot then
				self.bindData.scoreRoot.gameObject:SetActive(false)
			end

			self.timeTimer = nil
		end, self.closeAnimTime):Start()
	end, self.openAnimTime):Start()
end

M.OnDecreaseScore = function(self, data)
	if self.timeTimer then
		self.timeTimer:Stop()

		self.timeTimer = nil
	end

	self.bindData.scoreRoot.gameObject:SetActive(true)

	self.bindData.scoreCtrl = 1
	self.bindData.scoreNumText = data.decreaseScore
	self.totalScore = math.max(self.totalScore - data.decreaseScore, 0)
	gMiniGameDataManager.safeDriveScore = self.totalScore
	self.bindData.scoreText = LTConfig.TextCommonTextConfig.GetConfig(data.textId).Text or ""

	self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimOpenName)

	self.bindData.totalScore = string.format("%.2f", self.totalScore)
	self.timeTimer = Timer.New(function ()
		if self.bindData.scoreAnim then
			self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimCloseName)
		end

		self.timeTimer = Timer.New(function ()
			if self.bindData.scoreRoot then
				self.bindData.scoreRoot.gameObject:SetActive(false)
			end

			self.timeTimer = nil
		end, self.closeAnimTime):Start()
	end, self.openAnimTime, nil):Start()
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
