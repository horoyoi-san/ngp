local DragEventListener = SGUI.EventSystems.DragEventListener
C_TimelineSwipePanelStore = DefClass("C_TimelineSwipePanelStore", C_TimelineSwipePanelStore, C_StoreGroup)
GroupName2Class.TimelineSwipePanelStore = C_TimelineSwipePanelStore
local M = C_TimelineSwipePanelStore

function M:OnAwake()
	self.timelineName = ""
	self.dragging = false
	self.timer = 0
	self.duration = 1
	self.openAnimLength = 0
	self.finishAnimName = "S_Vx_TimelineSwipePanel_Finish"
	self.openAnimName = "S_Vx_TimelineSwipePanel_Open"
	self.failAnimName = "S_Vx_TimelineSwipePanel_Fail"
	self.clickAnimName = "S_Vx_TimelineSwipePanel_tips"
	self.clickAnimName_controller = "S_Vx_TimelineSwipePanel_tips_PS"
	self.callback = nil
	self.startPosition = nil
	self.state = 0
end

function M:PlayClickAnim()
	if self.bindData.mouseImgAnimation then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.mouseImgAnimation, self.clickAnimName)
	end
end

function M:PlayControllerHintAnim()
	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() and self.bindData.controllerAnimation then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.controllerAnimation, self.clickAnimName_controller)
	end
end

function M:PlayOpenAnim()
	local clip = self.bindData.animation:GetClip(self.openAnimName)

	if clip then
		self.openAnimLength = clip.length

		self.bindData.animation:Play(self.openAnimName)
		Timer.New(function ()
			self:PlayControllerHintAnim()
			self:PlayClickAnim()
		end, clip.length):Start()
	else
		self:PlayControllerHintAnim()
		self:PlayClickAnim()
	end
end

function M:OnShow(panelId, data)
	if gTimelineManager.swipeQTETimer then
		gTimelineManager.swipeQTETimer:Stop()

		gTimelineManager.swipeQTETimer = nil
	end

	self.state = 2
	local paramTable = data:ToTable()
	local direction = paramTable.direction

	if direction == "left" then
		self.bindData.direction = 0
	elseif direction == "right" then
		self.bindData.direction = 1
	elseif direction == "top" then
		self.bindData.direction = 2
	elseif direction == "bottom" then
		self.bindData.direction = 3
	elseif direction == "leftTop" then
		self.bindData.direction = 4
	elseif direction == "leftBottom" then
		self.bindData.direction = 5
	elseif direction == "rightTop" then
		self.bindData.direction = 6
	else
		self.bindData.direction = 7
	end

	self.bindData.progressMode = paramTable.progressType
	self.duration = paramTable.duration
	self.bindData.controllerKey = paramTable.controllerKey

	self:BindClick()
	self:SetPos(paramTable)
	self:PlayOpenAnim()

	self.bindData.mode = 1
	self.callback = paramTable.callback
end

function M:BindClick()
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		local dragBtn = DragEventListener.Get(self.bindData.dragBtn.gameObject)
		dragBtn.onBeginDrag = self:CreateAction("OnBtnBeginDrag")
		dragBtn.onDrag = self:CreateAction("OnBtnDragging")
		dragBtn.onEndDrag = self:CreateAction("OnBtnEndDrag")
	elseif self.bindData.controllerKey == 0 then
		self.bindData.leftJoyStick.luaGamePadInputChanged = self:CreateAction("OnJoyStickInputChanged")
	else
		self.bindData.rightJoyStick.luaGamePadInputChanged = self:CreateAction("OnJoyStickInputChanged")
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

function M:OnUpdate()
	self:UpdatePos()

	if self.bindData.mode == 0 then
		return
	end

	if self.state ~= 2 then
		return
	end

	if self.duration then
		if self.duration < self.timer then
			self:Fail()
		else
			self.bindData.fill.fillAmount = 1 - (self.timer - self.openAnimLength) / (self.duration - self.openAnimLength)

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				self:CheckMousePosition()
			end
		end

		self.timer = self.timer + gLogicTime.unscaledDeltaTime
	elseif gCS.LuaUtils.IsNonMobileAdaptive() then
		self:CheckMousePosition()
	end
end

function M:UpdatePos()
	if self.posType == "Custom" and self.targetPos then
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRT.parent, self.targetPos.position)
		self.bindData.buttonRT.anchoredPosition = uiPos + self.customPosOffset
	end
end

function M:OnBtnBeginDrag(eventData)
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
		self:Pass()
	end
end

function M:OnBtnEndDrag(eventData)
	self.dragging = false
end

function M:CheckPass(current, passValue)
	if self.bindData.direction == 0 then
		return current.x <= self.startPosition.x - passValue
	elseif self.bindData.direction == 1 then
		return current.x >= self.startPosition.x + passValue
	elseif self.bindData.direction == 2 then
		return current.y >= self.startPosition.y + passValue
	elseif self.bindData.direction == 3 then
		return current.y <= self.startPosition.y - passValue
	elseif self.bindData.direction == 4 then
		return current.x <= self.startPosition.x and self.startPosition.y <= current.y and passValue <= current.y - self.startPosition.y + self.startPosition.x - current.x
	elseif self.bindData.direction == 5 then
		return current.x <= self.startPosition.x and current.y <= self.startPosition.y and passValue <= self.startPosition.y - current.y + self.startPosition.x - current.x
	elseif self.bindData.direction == 6 then
		return self.startPosition.x <= current.x and self.startPosition.y <= current.y and passValue <= current.y - self.startPosition.y + current.x - self.startPosition.x
	elseif self.bindData.direction == 7 then
		return self.startPosition.x <= current.x and current.y <= self.startPosition.y and passValue <= self.startPosition.y - current.y + current.x - self.startPosition.x
	end
end

function M:OnJoyStickInputChanged(context)
	local value = context:ReadValueVector2()
	self.startPosition = {
		x = 0,
		y = 0
	}
	local pass = self:CheckPass(value, 0.8)

	if pass then
		self:Pass()
	end
end

function M:CheckMousePosition()
	local position = gCS.LuaUtils.GetCursorPosition()

	if not self.startPosition then
		self.startPosition = position

		return
	end

	local pass = self:CheckPass(position, 60)

	if pass then
		self:Pass()
	end
end

function M:Pass()
	self.state = 3
	self.dragging = false

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)
end

function M:Fail()
	if self.state == 4 then
		return
	end

	self.state = 4

	gCS.LuaUtils.PlayAnimationByName(self.bindData.animation, self.failAnimName)

	local duration = gCS.LuaUtils.GetAnimationTime(self.bindData.animation, self.failAnimName)
	gTimelineManager.swipeQTETimer = Timer.New(function ()
		gPanelManager:Close(gPanelId.TIMELINE_SWIPE_PANEL)

		gTimelineManager.swipeQTETimer = nil
	end, duration):Start()
end

function M:ClosePanelWithAnim()
	if gTimelineManager.swipeQTETimer then
		return
	end

	gPanelManager:Close(gPanelId.TIMELINE_SWIPE_PANEL)
end

function M:SetProgress0(progress)
	if self.bindData.countdownProgressImage then
		self.bindData.fill.fillAmount = progress
	end

	if self.bindData.progressImage then
		self.bindData.fill.fillAmount = progress
	end
end

function M:SetProgress1(progress)
	return
end

function M:PlaySuccessEndAnim()
	local duration = gCS.LuaUtils.GetAnimationTime(self.bindData.animation, self.finishAnimName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.animation, self.finishAnimName)

	return duration
end

function M:PlaySuccessEndAnim2()
	return 0
end

function M:ClosePanelFailed()
	return 0
end
