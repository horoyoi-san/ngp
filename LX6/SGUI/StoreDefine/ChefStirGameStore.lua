-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefStirGameStore.lua
-- Decompiled from: 01425_ChefStirGameStore.lua_18a506bb80ae.luajit

C_ChefStirGameStore = DefClass("C_ChefStirGameStore", C_ChefStirGameStore, C_StoreGroup)
GroupName2Class.ChefStirGameStore = C_ChefStirGameStore
local M = C_ChefStirGameStore
local StirReward = {
	["R+zS"] = 2,
	["o\\xbb\\xb0\\xa1\\xa2"] = 0,
	["2G\\x83\\x83\\x82M"] = 1
}
local LevelDefine = {
	["R+zS"] = 2,
	["\\xa3ab"] = 1,
	["\\xa2gq"] = 0
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.mouseAction = nil
	self.lastTouch = nil
	self.inputHandler = nil
	self.rewardUpdater = nil
	self.widthChangeTimer = 0
	self.widthChangeInterval = 10
	self.widthChangeIntervalRange = nil
	self.lowPosRange = nil
	self.midPosRange = nil
	self.highPosRange = nil
	self.lowWidthRange = nil
	self.midWidthRange = nil
	self.highWidthRange = nil
	self.bgWidth = self.bindData.bgRect.rect.width
	self.bgHalfWidth = self.bgWidth / 2
	self.curLevel = LevelDefine.Low
	self.mouseCoefficient = 5
	self.dragCoefficient = 5
	self.joyStickCoefficient = 5
	self.fallSpeed = -800
	self.riseAcceleration = 50
	self.hasInput = false
	self.currentVelocity = 0
	self.deltaTime = 0
	self.isPlayHintAnim = false
	self.hasPlayedHintAnim = false
	self.hintTimer = nil
	self.nowReward = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, data)
	self.InitInput(self)

	if data then
		self.inputHandler = data.inputHandler
		self.rewardUpdater = data.rewardUpdater
		self.lowPosRange = data.lowPosRange
		self.midPosRange = data.midPosRange
		self.highPosRange = data.highPosRange
		self.lowWidthRange = data.lowWidthRange
		self.midWidthRange = data.midWidthRange
		self.highWidthRange = data.highWidthRange
		self.widthChangeIntervalRange = data.widthChangeIntervalRange
		self.mouseCoefficient = data.mouseCoefficient
		self.bindData.slider.maxValue = data.maxLength
		self.fallSpeed = data.fallSpeed
		self.riseAcceleration = data.riseAcceleration

		self.RandomLocateRectWidth(self)
	end

	self.bindData.slider.value = 0
end

M.OnDisable = function(self)
	self.ClearInput(self)

	if self.hintTimer then
		self.hintTimer:Stop()

		self.hintTimer = nil
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnUpdate = function(self)
	self.deltaTime = Time.deltaTime

	self.UpdateVelocity(self)
	self.UpdateSlider(self)
	self.UpdateRewardCheck(self)
	self.UpdateRewardZone(self)
	self.UpdateDualShake(self)

	self.hasInput = false
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.interactBtn.luaClick = self.CreateAction(self, "OnClickInteractBtn")
end

M.OnClickInteractBtn = function(self)
end

M.InitInput = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.mouseAction = self:CreateAction("MouseMovePlay")

		gMessageManager:AddMessageListener(gEventConstants.MOUSE_MOVE, self.mouseAction)
	else
		self.bindData.interactBtn.luaDrag = self.CreateAction(self, "DragMovePlay")

		self.bindData.interactBtn.luaBeginDrag = function()
			self.lastTouch = gUtils:GetTouchPosition()
		end

		self.bindData.interactBtn.luaEndDrag = function()
			self.lastTouch = nil
		end
	end
end

M.ClearInput = function(self)
	if self.mouseAction then
		gMessageManager:RemoveMessageListener(gEventConstants.MOUSE_MOVE, self.mouseAction)
	end
end

M.MouseMovePlay = function(self, _, data)
	local x = data.x
	local y = data.y

	self.HandleInput(self, x, y)
end

M.DragMovePlay = function(self, delta)
	local x = delta.x
	local y = delta.y

	self.HandleInput(self, x, y)
end

M.UpdateDualShake = function(self)
	if gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.PlayStation then
		return
	end

	local motionData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadMotionData()
	local angularVelocity = motionData.angularVelocity
	local x = math.abs(angularVelocity.x) >= 0.1 and 0 or angularVelocity.x
	local z = math.abs(angularVelocity.z) >= 0.1 and 0 or angularVelocity.z

	self.inputHandler(x * 10, z * 10)
end

M.HandleInput = function(self, x, y)
	self.hasInput = true

	if self.inputHandler then
		self.inputHandler(x, y)
	end
end

M.UpdateVelocity = function(self)
	if self.hasInput then
		if self.currentVelocity >= 0 then
			self.currentVelocity = Mathf.Lerp(self.currentVelocity, 0, 5 * self.deltaTime)
		end

		self.currentVelocity = self.currentVelocity + self.riseAcceleration * self.deltaTime
	else
		self.currentVelocity = Mathf.Lerp(self.currentVelocity, self.fallSpeed / 10, 5 * self.deltaTime)
	end
end

M.UpdateSlider = function(self)
	self.bindData.slider.value = self.bindData.slider.value + self.currentVelocity * self.deltaTime
end

M.UpdateRewardCheck = function(self)
	local handleCenterX = self.bindData.handleRect.localPosition.x
	local locatePos = self.bindData.locateRect.localPosition
	local locateWidth = self.bindData.locateRect.rect.width * self.bindData.locateRect.localScale.x
	local locateLeft = locatePos.x - locateWidth / 2
	local locateRight = locatePos.x + locateWidth / 2

	if locateLeft < handleCenterX and handleCenterX < locateRight then
		self.UpdateRewardSpeed(self, StirReward.High)

		if self.hasPlayedHintAnim then
			self.hasPlayedHintAnim = false
		end
	else
		self.UpdateRewardSpeed(self, StirReward.Normal)

		if not self.hasPlayedHintAnim and not self.isPlayHintAnim then
			self.bindData.flashActive = true
			self.hasPlayedHintAnim = true
			self.isPlayHintAnim = true

			if self.hintTimer then
				self.hintTimer:Reset(function ()
					self.bindData.flashActive = false
					self.isPlayHintAnim = false
				end, 1)
				self.hintTimer:Start()
			else
				self.hintTimer = Timer.New(function ()
					self.bindData.flashActive = false
					self.isPlayHintAnim = false
				end, 1):Start()
			end
		end
	end
end

M.UpdateRewardZone = function(self)
	self.widthChangeTimer = self.widthChangeTimer + self.deltaTime

	if self.widthChangeInterval < self.widthChangeTimer then
		self.curLevel = (self.curLevel + 1) % 3

		self.RandomLocateRectWidth(self)

		self.widthChangeTimer = 0
	end
end

M.RandomLocateRectWidth = function(self)
	self.widthChangeInterval = math.random(self.widthChangeIntervalRange.x, self.widthChangeIntervalRange.y)
	local targetValue = 0

	if self.curLevel ~= LevelDefine.Low then
		targetValue = math.random(self.lowPosRange.x, self.lowPosRange.y)
	elseif self.curLevel ~= LevelDefine.Mid then
		targetValue = math.random(self.midPosRange.x, self.midPosRange.y)
	else
		targetValue = math.random(self.highPosRange.x, self.highPosRange.y)
	end

	targetValue = targetValue / 100
	local randomWidth = 0

	if self.curLevel ~= LevelDefine.Low then
		randomWidth = math.random(self.lowWidthRange.x, self.lowWidthRange.y)
	elseif self.curLevel ~= LevelDefine.Mid then
		randomWidth = math.random(self.midWidthRange.x, self.midWidthRange.y)
	else
		randomWidth = math.random(self.highWidthRange.x, self.highWidthRange.y)
	end

	local bgLeft = -self.bgHalfWidth
	local bgRight = self.bgHalfWidth
	local halfWidthPixels = randomWidth / 100 * self.bgWidth / 2
	local desiredCenterX = bgLeft + targetValue * (bgRight - bgLeft)
	local desiredLeft = desiredCenterX - halfWidthPixels
	local desiredRight = desiredCenterX + halfWidthPixels
	local finalCenterX = desiredCenterX
	local finalWidth = randomWidth
	local finalLeft = desiredLeft
	local finalRight = desiredRight

	if desiredLeft <= bgLeft or bgRight >= desiredRight then
		if desiredLeft >= bgLeft and bgRight >= desiredRight then
			finalWidth = 100
			finalCenterX = 0
			finalLeft = bgLeft
			finalRight = bgRight
		elseif desiredLeft >= bgLeft then
			finalLeft = bgLeft
			finalRight = finalLeft + randomWidth / 100 * self.bgWidth

			if bgRight >= finalRight then
				finalRight = bgRight
				finalWidth = (finalRight - finalLeft) / self.bgWidth * 100
			end

			finalCenterX = (finalLeft + finalRight) / 2
		elseif bgRight >= desiredRight then
			finalRight = bgRight
			finalLeft = finalRight - randomWidth / 100 * self.bgWidth

			if bgLeft <= finalLeft then
				finalLeft = bgLeft
				finalWidth = (finalRight - finalLeft) / self.bgWidth * 100
			end

			finalCenterX = (finalLeft + finalRight) / 2
		end
	end

	self.bindData.locateRect.localPosition = Vector3.New(finalCenterX, 0, 0)
	local size = self.bindData.locateRect.sizeDelta
	size.x = finalWidth * self.bgWidth / 100
	self.bindData.locateRect.sizeDelta = size
end

M.UpdateRewardSpeed = function(self, level)
	if self.nowReward and self.nowReward ~= level then
		return
	end

	if self.rewardUpdater then
		self.rewardUpdater(level)
	end
end
