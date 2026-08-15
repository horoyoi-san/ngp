C_TimelineShakePanelStore = DefClass("C_TimelineShakePanelStore", C_TimelineShakePanelStore, C_StoreGroup)
GroupName2Class.TimelineShakePanelStore = C_TimelineShakePanelStore
local M = C_TimelineShakePanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
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
		self.bindData.dragBtn.luaClick = self:CreateAction("Pass")
	else
		self.bindData.leftJoyStick.luaGamePadInputChanged = self:CreateAction("OnLeftJoyStickInputChanged")
	end
end

function M:OnUpdate()
	self:UpdatePos()

	if self.state ~= 2 then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.KeyboardMouse then
			self:CheckMousePosition()
		elseif gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.PlayStation then
			self:CheckDualSense()
		end
	end

	self.timer = self.timer + gLogicTime.unscaledDeltaTime
end

function M:OnShow(panelId, data)
	self.state = 2
	local paramTable = data:ToTable()
	self.bindData.progressMode = paramTable.progressType

	self:SetPos(paramTable)
	self:PlayOpenAnim()

	self.bindData.dualsense = gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.PlayStation and not paramTable.forceStick and 0 or 1
end

function M:UpdatePos()
	if self.posType == "Custom" and self.targetPos then
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRT.parent, self.targetPos.position)
		self.bindData.buttonRT.anchoredPosition = uiPos + self.customPosOffset
	end
end

function M:SetPos(panelData)
	self.posType = panelData.pos

	if self.posType == "Custom" then
		self.targetPos = panelData.customPos
		self.customPosOffset = panelData.customPosOffset
	else
		self.targetPos = self.bindData[self.posType]
	end

	if self.targetPos then
		if self.posType == "Custom" then
			local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRT.parent, self.targetPos.position)
			self.bindData.buttonRT.anchoredPosition = uiPos + self.customPosOffset
		else
			self.bindData.buttonRT.anchoredPosition = self.targetPos.anchoredPosition
		end
	end
end

function M:PlayOpenAnim()
	local clip = self.bindData.animation:GetClip(self.openAnimName)

	if clip then
		self.openAnimLength = clip.length

		self.bindData.animation:Play(self.openAnimName)
		Timer.New(function ()
			self:PlayLoopAnim()
		end, clip.length):Start()
	else
		self:PlayControllerHintAnim()
		self:PlayLoopAnim()
	end
end

function M:PlayClickAnim()
	if self.bindData.clickAnimation then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.clickAnimation, self.clickAnimName)
	end
end

function M:PlayLoopAnim()
	if self.bindData.animation then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.animation, self.loopAnimName)
	end
end

function M:OnBtnBeginDrag(eventData)
	self.direction = 0
	self.startPosition = eventData.position
	self.dragging = true
end

function M:OnBtnDragging(eventData)
	if not self.dragging then
		return
	end

	local current = eventData.position
	local pass = self:CheckPass(current, 60)

	if pass then
		self.startPosition = eventData.position

		self:Pass()
	end
end

function M:OnBtnEndDrag(eventData)
	self.dragging = false
	self.direction = 0
end

function M:OnLeftJoyStickInputChanged(context)
	if self.bindData.dualsense == 1 then
		local value = context:ReadValueVector2()
		self.startPosition = {
			x = 0,
			y = 0
		}
		local pass = self:CheckPass(value, 0.8)

		if pass then
			self.startPosition = {
				x = 0,
				y = 0
			}

			self:Pass()
		end
	end
end

function M:CheckMousePosition()
	local position = gCS.LuaUtils.GetCursorPosition()

	if not self.startPosition then
		self.startPosition = position

		return
	end

	local pass1 = self:CheckPass(position, 60)
	local pass2 = self:CheckPass({
		x = 0,
		y = self.startPosition.y + position.x - self.startPosition.x
	}, 60)

	if pass1 or pass2 then
		self.startPosition = position

		self:Pass()
	end
end

function M:CheckDualSense()
	local motionData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadMotionData()
	self.startPosition = {
		x = 0,
		y = 0
	}
	local pass1 = self:CheckPass(motionData.acceleration, 0.8)
	local pass2 = self:CheckPass({
		x = 0,
		y = motionData.acceleration.z
	}, 0.8)

	if pass1 or pass2 then
		self.startPosition = {
			x = 0,
			y = 0
		}

		gSoundMgr:PlaySoundByTid(70350013)
		self:Pass()
	end
end

function M:CheckPass(current, passValue)
	if self.direction == 0 then
		if passValue <= current.y - self.startPosition.y then
			self.direction = 2

			return true
		elseif passValue <= self.startPosition.y - current.y then
			self.direction = 1

			return true
		end
	elseif self.direction == 1 then
		if passValue <= current.y - self.startPosition.y then
			self.direction = 2

			return true
		end
	elseif self.direction == 2 and passValue <= self.startPosition.y - current.y then
		self.direction = 1

		return true
	end

	return false
end

function M:Pass()
	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)
end

function M:ClosePanelFailed()
	return 0
end

function M:PlaySuccessEndAnim()
	gCS.LuaUtils.PlayAnimationByName(self.bindData.animation, self.finishAnimName)

	local duration = gCS.LuaUtils.GetAnimationTime(self.bindData.animation, self.finishAnimName)
	self.closeState = true

	return duration
end

function M:PlaySuccessEndAnim2()
	return 0
end

function M:SetProgress0(progress)
	if self.bindData.countdownProgressImage then
		self.bindData.countdownProgressImage.fillAmount = progress
	end

	if self.bindData.progressImage then
		self.bindData.progressImage.fillAmount = progress
	end
end

function M:SetProgress1(progress)
	return
end

function M:PlayClickAnimByCS(btn2)
	if not btn2 then
		self:PlayClickAnim()
	end
end
