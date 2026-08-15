C_PoliceDriveBubbleStore = DefClass("C_PoliceDriveBubbleStore", C_PoliceDriveBubbleStore, C_StoreGroup)
GroupName2Class.PoliceDriveBubbleStore = C_PoliceDriveBubbleStore
local M = C_PoliceDriveBubbleStore

function M:ctor()
	self.isPlayAddLoopAnim = false
	self.isPlayingOpenAnim = false
	self.needPlayCloseAfterOpen = false
	self.currentAddTime = 0
	self.addTotalTimes = 0
	self.addPlayedTimes = 0
	self.scoreAnimOpenName = "S_Vx_PoliceDriveBubble_open"
	self.scoreAnimCloseName = "S_Vx_PoliceDriveBubble_close"
	self.scoreAnimAddName = "S_Vx_PoliceDriveBubble_add"
	self.timeAnimName = "S_Vx_BasketBallGamePanel_Bubble_times3"
	self.totalScore = 0
	self.startTime = 0
	self.endTime = 0
	self.nowTime = 0
	self.remainTime = 0
	self.enterContinuous = false
	self.addValue = 0
end

function M:OnGroupEnable()
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
		end
	}

	self:RegisterMessageEvents(self.msgEvents)

	if self.bindData.scoreAnim:GetClip(self.scoreAnimOpenName) then
		self.openAnimTime = self.bindData.scoreAnim:GetClip(self.scoreAnimOpenName).length
	end

	if self.bindData.scoreAnim:GetClip(self.scoreAnimCloseName) then
		self.closeAnimTime = self.bindData.scoreAnim:GetClip(self.scoreAnimCloseName).length
	end

	if self.bindData.scoreAnim:GetClip(self.scoreAnimAddName) then
		self.addAnimTime = self.bindData.scoreAnim:GetClip(self.scoreAnimAddName).length
	end
end

function M:ContinuousChange(data)
	local prevEnterContinuous = self.enterContinuous
	self.enterContinuous = data.isEnter

	if not self.enterContinuous and prevEnterContinuous then
		if self.isPlayingOpenAnim then
			self.needPlayCloseAfterOpen = true
		elseif self.isPlayAddLoopAnim then
			self.isPlayAddLoopAnim = false
			self.addPlayedTimes = 0
			self.addTotalTimes = 0

			self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimCloseName)

			if self.timeTimer then
				self.timeTimer:Stop()
			end

			self.timeTimer = Timer.New(function ()
				self.bindData.scoreRoot.gameObject:SetActive(false)

				self.timeTimer = nil
			end, self.closeAnimTime):Start()
		else
			self.bindData.scoreRoot.gameObject:SetActive(false)
		end
	elseif self.enterContinuous and not prevEnterContinuous then
		self.addPlayedTimes = 0
		self.addTotalTimes = 0
		self.needPlayCloseAfterOpen = false
	end

	if self.enterContinuous then
		self.addValue = data.addValue or self.addValue
	end
end

function M:RefreshCountDown()
	self.nowTime = gLogicTime.time
	self.bindData.countDownTime = self:GetFormatCountDownTime(self.nowTime)
	self.remainTime = math.max(self.endTime - self.nowTime, 0)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, totalTime)
	self.bindData.scoreText = 0
	self.totalScore = 0
	gMiniGameDataManager.safeDriveScore = self.totalScore
	self.startTime = gLogicTime.time
	self.endTime = self.startTime + totalTime
	self.timeRange = self.endTime
	self.needUpdate = true
	self.needUpdateClose = false
	self.bindData.totalScore = 0
	self.enterContinuous = false
	self.isPlayAddLoopAnim = false
	self.isPlayingOpenAnim = false
	self.needPlayCloseAfterOpen = false
	self.addPlayedTimes = 0
	self.addTotalTimes = 0
	self.currentAddTime = 0

	self:RefreshCountDown()

	self.bindData.countDownTime = self:GetFormatCountDownTime(self.nowTime)

	self.bindData.scoreRoot.gameObject:SetActive(false)
	self.bindData.timeRoot.gameObject:SetActive(false)
end

local currentAddTime = 0

function M:OnUpdate()
	if self.needUpdate then
		self:RefreshCountDown()

		if self.isPlayingOpenAnim then
			local isOpenAnimPlaying = self.bindData.scoreAnim:IsPlaying(self.scoreAnimOpenName)

			if not isOpenAnimPlaying then
				self.isPlayingOpenAnim = false

				if self.needPlayCloseAfterOpen then
					self.needPlayCloseAfterOpen = false

					self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimCloseName)

					self.timeTimer = Timer.New(function ()
						self.bindData.scoreRoot.gameObject:SetActive(false)

						self.timeTimer = nil
					end, self.closeAnimTime):Start()
				elseif self.addTotalTimes > 0 then
					self.isPlayAddLoopAnim = true

					self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimAddName)
				end
			end
		end

		if self.isPlayAddLoopAnim and self.addTotalTimes > 0 then
			local isAddAnimPlaying = self.bindData.scoreAnim:IsPlaying(self.scoreAnimAddName)

			if not isAddAnimPlaying then
				self.totalScore = self.totalScore + self.addValue
				gMiniGameDataManager.safeDriveScore = self.totalScore
				self.bindData.totalScore = self.totalScore
				self.addPlayedTimes = self.addPlayedTimes + 1
				self.currentAddTime = 0

				if self.addTotalTimes <= self.addPlayedTimes then
					self.isPlayAddLoopAnim = false
					self.addPlayedTimes = 0
					self.addTotalTimes = 0

					self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimCloseName)

					self.timeTimer = Timer.New(function ()
						self.bindData.scoreRoot.gameObject:SetActive(false)

						self.timeTimer = nil
					end, self.closeAnimTime):Start()
				else
					self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimAddName)
				end
			end
		end

		if self.remainTime <= 0 then
			self.needUpdate = false
			self.needUpdateClose = true
		end
	end

	if self.needUpdateClose then
		gMessageManager:SendMessage(gEventConstants.ON_SAFE_DRIVE_END)
		gPanelManager:Close(gPanelId.POLICE_DRIVE_BUBBLE_PANEL)
	end
end

function M:OnAddTime(data)
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
		self.bindData.timeRoot.gameObject:SetActive(false)

		self.timeTimer = nil
	end, clip.length, nil):Start()
end

function M:OnDecreaseTime(data)
	if self.timeTimer then
		self.timeTimer:Stop()

		self.timeTimer = nil
	end

	local newEndTime = self.endTime - data
	self.endTime = math.max(newEndTime, self.startTime)

	self:RefreshCountDown()

	if self.remainTime <= 0 then
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
		self.bindData.timeRoot.gameObject:SetActive(false)

		self.timeTimer = nil
	end, clip.length, nil):Start()
end

function M:ResetAnimation(animation, clipName)
	if not animation or not clipName then
		return
	end

	animation:Stop()

	local animationState = animation:get_Item(clipName)

	if animationState then
		animationState.time = 0
		animationState.enabled = true

		animation:Sample()
		animation:Play(clipName)
	end
end

function M:OnAddScore(data)
	if self.timeTimer then
		self.timeTimer:Stop()
	end

	self.bindData.scoreCtrl = 0
	self.bindData.scoreText = LTConfig.TextCommonTextConfig.GetConfig(data.textId).Text or ""

	self.bindData.scoreRoot.gameObject:SetActive(true)

	if self.enterContinuous and data.addScore > 0 then
		local cnt = math.floor(data.addScore / self.addValue)

		if cnt <= 0 then
			return
		end

		self.bindData.scoreNumText = self.addValue
		self.totalScore = self.totalScore + self.addValue
		gMiniGameDataManager.safeDriveScore = self.totalScore
		self.bindData.totalScore = self.totalScore
		self.addTotalTimes = cnt - 1
		self.addPlayedTimes = 0
		self.isPlayingOpenAnim = true

		self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimOpenName)

		if self.addTotalTimes <= 0 then
			self.timeTimer = Timer.New(function ()
				self.isPlayingOpenAnim = false

				self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimCloseName)
				Timer.New(function ()
					self.bindData.scoreRoot.gameObject:SetActive(false)

					self.timeTimer = nil
				end, self.closeAnimTime):Start()
			end, self.openAnimTime):Start()
		end
	else
		self.totalScore = self.totalScore + data.addScore
		gMiniGameDataManager.safeDriveScore = self.totalScore
		self.bindData.scoreCtrl = 0
		self.bindData.scoreText = LTConfig.TextCommonTextConfig.GetConfig(data.textId).Text or ""
		self.bindData.scoreNumText = data.addScore
		self.bindData.totalScore = self.totalScore

		self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimOpenName)

		self.timeTimer = Timer.New(function ()
			self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimCloseName)
			Timer.New(function ()
				self.bindData.scoreRoot.gameObject:SetActive(false)

				self.timeTimer = nil
			end, self.closeAnimTime):Start()
		end, self.openAnimTime):Start()
	end
end

function M:OnDecreaseScore(data)
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

	self.bindData.totalScore = self.totalScore
	self.timeTimer = Timer.New(function ()
		self:ResetAnimation(self.bindData.scoreAnim, self.scoreAnimCloseName)

		self.timeTimer = Timer.New(function ()
			self.bindData.scoreRoot.gameObject:SetActive(false)

			self.timeTimer = nil
		end, self.closeAnimTime):Start()
	end, self.openAnimTime, nil):Start()
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
