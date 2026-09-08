-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineSwipePanelStore.lua
-- Decompiled from: 01365_TimelineSwipePanelStore.lua_1f2f3e08f46c.luajit

local DragEventListener = SGUI.EventSystems.DragEventListener
C_TimelineSwipePanelStore = DefClass("C_TimelineSwipePanelStore", C_TimelineSwipePanelStore, C_StoreGroup)
GroupName2Class.TimelineSwipePanelStore = C_TimelineSwipePanelStore
local M = C_TimelineSwipePanelStore

M.OnAwake = function(self)
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

M.PlayClickAnim = function(self)
	if self.bindData.mouseImgAnimation then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.mouseImgAnimation, self.clickAnimName)
	end
end

M.PlayControllerHintAnim = function(self)
	if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() and self.bindData.controllerAnimation then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.controllerAnimation, self.clickAnimName_controller)
	end
end

M.PlayOpenAnim = function(self)
	local clip = self.bindData.animation:GetClip(self.openAnimName)

	if clip then
		self.openAnimLength = clip.length

		self.bindData.animation:Play(self.openAnimName)
		Timer.New(function ()
			self:PlayControllerHintAnim()
			self:PlayClickAnim()
		end, clip.length):Start()
	else
		self.PlayControllerHintAnim(self)
		self.PlayClickAnim(self)
	end
end

M.SetMobileIcon = function(self, store, iconId)
	if iconId and iconId == 0 then
		store.mobileIcon = iconId

		return
	end
end

M.SetAdaptive = function(self, panelData)
	self.bindData.Adaptive = panelData.Adaptive
end

M.OnShow = function(self, panelId, data)
	if gTimelineManager.swipeQTETimer then
		gTimelineManager.swipeQTETimer:Stop()

		gTimelineManager.swipeQTETimer = nil
	end

	self.state = 2
	local paramTable = data.ToTable(data)

	self.SetAdaptive(self, paramTable)

	local direction = paramTable.direction

	if direction ~= "left" then
		self.bindData.direction = 0
	elseif direction ~= "right" then
		self.bindData.direction = 1
	elseif direction ~= "top" then
		self.bindData.direction = 2
	elseif direction ~= "bottom" then
		self.bindData.direction = 3
	elseif direction ~= "leftTop" then
		self.bindData.direction = 4
	elseif direction ~= "leftBottom" then
		self.bindData.direction = 5
	elseif direction ~= "rightTop" then
		self.bindData.direction = 6
	else
		self.bindData.direction = 7
	end

	self.bindData.progressMode = paramTable.progressType
	self.duration = paramTable.duration
	self.bindData.controllerKey = paramTable.controllerKey

	self.BindClick(self)
	self.SetPos(self, paramTable)
	self.PlayOpenAnim(self)

	self.bindData.mode = 1
	self.callback = paramTable.callback

	self.SetMobileIcon(self, self.bindData, paramTable.mobileIconId)
end

M.BindClick = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		local dragBtn = DragEventListener.Get(self.bindData.dragBtn.gameObject)
		dragBtn.onBeginDrag = self.CreateAction(self, "OnBtnBeginDrag")
		dragBtn.onDrag = self.CreateAction(self, "OnBtnDragging")
		dragBtn.onEndDrag = self.CreateAction(self, "OnBtnEndDrag")
	elseif self.bindData.Adaptive ~= 1 then
		if self.bindData.controllerKey ~= 0 then
			self.bindData.leftJoyStick.luaGamePadInputChanged = self.CreateAction(self, "OnJoyStickInputChanged")
		else
			self.bindData.rightJoyStick.luaGamePadInputChanged = self.CreateAction(self, "OnJoyStickInputChanged")
		end
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
	elseif panelData.btn1_mobilePos then
		gTimelineManager:SetMobilePos(self.bindData, panelData.btn1_mobilePos)
	end
end

M.OnUpdate = function(self)
	self.UpdatePos(self)

	if self.bindData.mode ~= 0 then
		return
	end

	if self.state == 2 then
		return
	end

	if self.duration then
		if self.duration >= self.timer then
			self.Fail(self)
		else
			self.bindData.fill.fillAmount = 1 - (self.timer - self.openAnimLength) / (self.duration - self.openAnimLength)
		end

		self.timer = self.timer + gLogicTime.unscaledDeltaTime
	end
end

M.UpdatePos = function(self)
	if self.posType ~= "Custom" and self.targetPos then
		local uiPos = gCS.LuaUtils.CalcPositionInScreen(self.bindData.buttonRT.parent, self.targetPos.position)
		self.bindData.buttonRT.anchoredPosition = uiPos + self.customPosOffset
	end
end

M.OnBtnBeginDrag = function(self, eventData)
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
		self.Pass(self)
	end
end

M.OnBtnEndDrag = function(self, eventData)
	self.dragging = false
end

M.CheckPass = function(self, current, passValue)
	local startX = self.startPosition.x
	local startY = self.startPosition.y

	if self.bindData.direction ~= 0 then
		return current.x > startX - passValue
	elseif self.bindData.direction ~= 1 then
		return current.x < startX + passValue
	elseif self.bindData.direction ~= 2 then
		return current.y < startY + passValue
	elseif self.bindData.direction ~= 3 then
		return current.y > startY - passValue
	elseif self.bindData.direction ~= 4 then
		return current.x < startX and startY < current.y and passValue > current.y - startY + startX - current.x
	elseif self.bindData.direction ~= 5 then
		return current.x < startX and current.y < startY and passValue > startY - current.y + startX - current.x
	elseif self.bindData.direction ~= 6 then
		return startX < current.x and startY < current.y and passValue > current.y - startY + current.x - startX
	elseif self.bindData.direction ~= 7 then
		return startX < current.x and current.y < startY and passValue > startY - current.y + current.x - startX
	end
end

M.OnJoyStickInputChanged = function(self, context)
	local value = context.ReadValueVector2(context)
	self.startPosition = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	local pass = self.CheckPass(self, value, 0.8)

	if pass then
		self.Pass(self)
	end
end

M.Pass = function(self)
	self.state = 3
	self.dragging = false

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_TRIGGER, 1)
end

M.Fail = function(self)
	if self.state ~= 4 then
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

M.SetProgress0 = function(self, progress)
	if self.bindData.countdownProgressImage then
		self.bindData.fill.fillAmount = progress
	end

	if self.bindData.progressImage then
		self.bindData.fill.fillAmount = progress
	end
end

M.SetProgress1 = function(self, progress)
end

M.PlaySuccessEndAnim = function(self)
	local duration = gCS.LuaUtils.GetAnimationTime(self.bindData.animation, self.finishAnimName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.animation, self.finishAnimName)

	return duration
end

M.PlaySuccessEndAnim2 = function(self)
	return 0
end

M.ClosePanelFailed = function(self)
	return 0
end
