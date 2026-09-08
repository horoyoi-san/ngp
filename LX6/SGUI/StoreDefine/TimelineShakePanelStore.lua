-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineShakePanelStore.lua
-- Decompiled from: 01378_TimelineShakePanelStore.lua_a4a95268e720.luajit

C_TimelineShakePanelStore = DefClass("C_TimelineShakePanelStore", C_TimelineShakePanelStore, C_StoreGroup)
GroupName2Class.TimelineShakePanelStore = C_TimelineShakePanelStore
local M = C_TimelineShakePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.closeState = false
	self.timelineName = ""
	self.dragging = false
	self.timer = 0
	self.duration = 1
	self.openAnimLength = 0
	self.finishAnimName = "S_Vx_TimelineShakePanel_finish"
	self.openAnimName = "S_Vx_TimelineShakePanel_open"
	self.loopAnimName = "S_Vx_TimelineShakePanel_loop"
	self.clickAnimName = "S_Vx_TimelineShakePanel_Click_React"
	self.startPosition = nil
	self.state = 0
	self.direction = 0

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.dragBtn.luaClick = self.CreateAction(self, "Pass")
	else
		self.bindData.leftJoyStick.luaGamePadInputChanged = self.CreateAction(self, "OnLeftJoyStickInputChanged")
	end
end

M.OnUpdate = function(self)
	self.UpdatePos(self)

	if self.state == 2 then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if self.bindData.Adaptive ~= 0 then
			self.CheckMousePosition(self)
		elseif self.bindData.Adaptive ~= 1 then
			self.CheckDualSense(self)
		end
	else
		self.CheckGravitySensor(self)
	end

	self.timer = self.timer + gLogicTime.unscaledDeltaTime
end

M.SetAdaptive = function(self, panelData)
	self.bindData.Adaptive = panelData.Adaptive
end

M.OnShow = function(self, panelId, data)
	self.state = 2
	local paramTable = data:ToTable()
	self.bindData.progressMode = paramTable.progressType

	self:SetPos(paramTable)
	self:PlayOpenAnim()

	self.bindData.dualsense = gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.PlayStation and not paramTable.forceStick and 0 or 1

	self:SetAdaptive(paramTable)
	self:SetMobileIcon(self.bindData, paramTable.mobileIconId)
end

M.UpdatePos = function(self)
	if self.posType ~= "Custom" and self.targetPos then
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRT.parent, self.targetPos.position)
		self.bindData.buttonRT.anchoredPosition = uiPos + self.customPosOffset
	end
end

M.SetPos = function(self, panelData)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.posType = panelData.btn1_pos

		if self.posType ~= "Custom" then
			self.targetPos = panelData.btn1_customPos
			self.customPosOffset = panelData.btn1_customPosOffset
		else
			self.targetPos = self.bindData[self.posType]
		end

		if self.posType ~= "Custom" then
			if self.targetPos then
				local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRT.parent, self.targetPos.position)
				self.bindData.buttonRT.anchoredPosition = uiPos + self.customPosOffset
			else
				self.bindData.buttonRT.anchoredPosition = self.customPosOffset
			end
		elseif self.targetPos then
			self.bindData.buttonRT.anchoredPosition = self.targetPos.anchoredPosition
		end
	else
		gTimelineManager:SetMobilePos(self.bindData, panelData.btn1_mobilePos and panelData.btn1_mobilePos or 0)
	end
end

M.SetMobileIcon = function(self, store, iconId)
	if iconId and iconId == 0 then
		store.mobileIcon = iconId

		return
	end
end

M.PlayOpenAnim = function(self)
	local clip = self.bindData.animation:GetClip(self.openAnimName)

	if clip then
		self.openAnimLength = clip.length

		self.bindData.animation:Play(self.openAnimName)
		Timer.New(function ()
			self:PlayLoopAnim()
		end, clip.length):Start()
	else
		self.PlayControllerHintAnim(self)
		self.PlayLoopAnim(self)
	end
end

M.PlayClickAnim = function(self)
	if self.bindData.clickAnimation then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.clickAnimation, self.clickAnimName)
	end
end

M.PlayLoopAnim = function(self)
	if self.bindData.animation then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.animation, self.loopAnimName)
	end
end

M.OnBtnBeginDrag = function(self, eventData)
	self.direction = 0
	self.startPosition = eventData.position
	self.dragging = true
end

M.OnBtnDragging = function(self, eventData)
	if not self.dragging then
		return
	end

	local current = eventData.position
	local pass = self.CheckPass(self, current, 60)

	if pass then
		self.startPosition = eventData.position

		self.Pass(self)
	end
end

M.OnBtnEndDrag = function(self, eventData)
	self.dragging = false
	self.direction = 0
end

M.OnLeftJoyStickInputChanged = function(self, context)
	if self.bindData.dualsense ~= 1 then
		local value = context.ReadValueVector2(context)
		self.startPosition = {
			["\\xd5"] = 0,
			["\\xd4"] = 0
		}
		local pass = self.CheckPass(self, value, 0.8)

		if pass then
			self.startPosition = {
				["\\xd5"] = 0,
				["\\xd4"] = 0
			}

			self.Pass(self)
		end
	end
end

M.CheckMousePosition = function(self)
	local position = gCS.LuaUtils.GetCursorPosition()

	if not self.startPosition then
		self.startPosition = position

		return
	end

	local pass1 = self.CheckPass(self, position, 60)
	local pass2 = self.CheckPass(self, {
		["\\xd5"] = 0,
		y = self.startPosition.y + position.x - self.startPosition.x
	}, 60)

	if pass1 or pass2 then
		self.startPosition = position

		self.Pass(self)
	end
end

M.CheckDualSense = function(self)
	local motionData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadMotionData()
	self.startPosition = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	local pass1 = self:CheckPass(motionData.acceleration, 0.8)
	local pass2 = self:CheckPass({
		["\\xd5"] = 0,
		y = motionData.acceleration.z
	}, 0.8)

	if pass1 or pass2 then
		self.startPosition = {
			["\\xd5"] = 0,
			["\\xd4"] = 0
		}

		gSoundMgr:PlaySoundByTid(70350013)
		self:Pass()
	end
end

M.CheckGravitySensor = function(self)
	local attitudeData = self.bindData.gravitySensor:GetAttitudeSensorData()

	if not self.startPosition then
		self.startPosition = attitudeData

		return
	end

	local pass1 = self.CheckPass(self, attitudeData, 5)
	local pass2 = self.CheckPass(self, {
		["\\xd5"] = 0,
		y = self.startPosition.y + attitudeData.x - self.startPosition.x
	}, 5)
	local pass3 = self.CheckPass(self, {
		["\\xd5"] = 0,
		y = self.startPosition.y + attitudeData.z - self.startPosition.z
	}, 5)

	if pass1 or pass2 or pass3 then
		self.startPosition = attitudeData

		self.Pass(self)
	end
end

M.CheckPass = function(self, current, passValue)
	if self.direction ~= 0 then
		if passValue < current.y - self.startPosition.y then
			self.direction = 2

			return true
		elseif passValue < self.startPosition.y - current.y then
			self.direction = 1

			return true
		end
	elseif self.direction ~= 1 then
		if passValue < current.y - self.startPosition.y then
			self.direction = 2

			return true
		end
	elseif self.direction ~= 2 and passValue < self.startPosition.y - current.y then
		self.direction = 1

		return true
	end

	return false
end

M.Pass = function(self)
	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)
end

M.ClosePanelFailed = function(self)
	return 0
end

M.PlaySuccessEndAnim = function(self)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.animation, self.finishAnimName)

	local duration = gCS.LuaUtils.GetAnimationTime(self.bindData.animation, self.finishAnimName)
	self.closeState = true

	return duration
end

M.PlaySuccessEndAnim2 = function(self)
	return 0
end

M.SetProgress0 = function(self, progress)
	if self.bindData.countdownProgressImage then
		self.bindData.countdownProgressImage.fillAmount = progress
	end

	if self.bindData.progressImage then
		self.bindData.progressImage.fillAmount = progress
	end
end

M.SetProgress1 = function(self, progress)
end

M.PlayClickAnimByCS = function(self, btn2)
	if not btn2 then
		self.PlayClickAnim(self)
	end
end
