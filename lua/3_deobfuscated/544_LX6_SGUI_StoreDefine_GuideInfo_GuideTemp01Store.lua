C_GuideTemp01Store = DefClass("C_GuideTemp01Store", C_GuideTemp01Store, C_GuideTempTabBaseStore)
GroupName2Class.GuideTemp01Store = C_GuideTemp01Store
local M = C_GuideTemp01Store
local animName = {
	"S_Vx_GuideTemp01_open01",
	"S_Vx_GuideTemp01_open02",
	"S_Vx_GuideTemp01_open03"
}

function M:OnAwake()
	self.pointNum = 3
	self.bindData.bgBtn.luaClick = self:CreateAction(self.NextPoint)
	self.bindData.isAnimFinished = false
end

function M:PlayTaskStartAnim()
	Timer.New(function ()
		if self.STATE_EnableOnce then
			self.bindData.anim:Play()
		end
	end, 0.5):Start()
	self:AutoPlayNextAnim()
end

function M:PlayNormalStartAnim()
	self:SetToAnimEnd()
end

function M:NextPoint()
	self:StopAutoPlayNextAnim()

	local showCount = self.bindData.showCountCtrl or 0

	if showCount > 0 then
		gUIUtils:SkipAni(self.bindData.anim, animName[showCount])

		if showCount == self.pointNum then
			self.bindData.isAnimFinished = true
		end
	end

	if self.pointNum <= showCount then
		return
	end

	showCount = showCount + 1
	self.bindData.showCountCtrl = showCount
	local widget = self.bindData["widget" .. showCount]

	if gClientUtils.IsNil(widget) then
		print_error_without_stack("GuideTemp01Store: widget" .. showCount .. " is nil")
	end

	widget.renderOpacity = 0

	FrameTimer.New(function ()
		if gClientUtils.NotNil(widget) then
			widget.renderOpacity = 1
		end
	end, 1):Start()

	if showCount < self.pointNum then
		self:AutoPlayNextAnim()
	else
		Timer.New(function ()
			if self.STATE_EnableOnce then
				self.bindData.isAnimFinished = true
			end
		end, 0.3):Start()
	end
end

function M:AutoPlayNextAnim()
	self.autoClickTimer = Timer.New(function ()
		if self.STATE_EnableOnce then
			self:NextPoint()
		end
	end, 0.3):Start()
end

function M:StopAutoPlayNextAnim()
	if self.autoClickTimer then
		self.autoClickTimer:Stop()

		self.autoClickTimer = nil
	end
end

function M:OnDisable()
	self:StopAutoPlayNextAnim()
	self:SetToAnimEnd()
end

function M:SetToAnimEnd()
	self.bindData.showCountCtrl = self.pointNum
	self.bindData.isAnimFinished = true
end

function M:IsAnimPlaying()
	return not self.bindData.isAnimFinished
end

function M:SkipCurrentAnim()
	self:NextPoint()
end
