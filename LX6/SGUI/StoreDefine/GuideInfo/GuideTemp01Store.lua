-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideInfo\GuideTemp01Store.lua
-- Decompiled from: 01994_GuideTemp01Store.lua_0256add9a3f5.luajit

C_GuideTemp01Store = DefClass("C_GuideTemp01Store", C_GuideTemp01Store, C_GuideTempTabBaseStore)
GroupName2Class.GuideTemp01Store = C_GuideTemp01Store
local M = C_GuideTemp01Store
local animName = {
	"\\xf5i\\x94\\xda\\xbc,W\\xd5\n)\\xeeC\\x89\\xe6\\x86V\\xbef\\\\xe7\\x97",
	"\\xf5i\\x94\\xda\\xbc,W\\xd5\n)\\xeeC\\x89\\xe6\\x86V\\xbef\\\\xe7\\x94",
	"\\xf5i\\x94\\xda\\xbc,W\\xd5\n)\\xeeC\\x89\\xe6\\x86V\\xbef\\\\xe7\\x95"
}

M.OnAwake = function(self)
	self.pointNum = 3
	self.bindData.bgBtn.luaClick = self.CreateAction(self, self.NextPoint)
	self.bindData.isAnimFinished = false
end

M.PlayTaskStartAnim = function(self)
	Timer.New(function ()
		if self.STATE_EnableOnce then
			self.bindData.anim:Play()
		end
	end, 0.5):Start()
	self:AutoPlayNextAnim()
end

M.PlayNormalStartAnim = function(self)
	self.SetToAnimEnd(self)
end

M.NextPoint = function(self)
	self:StopAutoPlayNextAnim()

	local showCount = self.bindData.showCountCtrl or 0

	if showCount <= 0 then
		gUIUtils:SkipAni(self.bindData.anim, animName[showCount])

		if showCount ~= self.pointNum then
			self.bindData.isAnimFinished = true
		end
	end

	if self.pointNum < showCount then
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

	if showCount >= self.pointNum then
		self.AutoPlayNextAnim(self)
	else
		Timer.New(function ()
			if self.STATE_EnableOnce then
				self.bindData.isAnimFinished = true
			end
		end, 0.3):Start()
	end
end

M.AutoPlayNextAnim = function(self)
	self.autoClickTimer = Timer.New(function ()
		if self.STATE_EnableOnce then
			self:NextPoint()
		end
	end, 0.3):Start()
end

M.StopAutoPlayNextAnim = function(self)
	if self.autoClickTimer then
		self.autoClickTimer:Stop()

		self.autoClickTimer = nil
	end
end

M.OnDisable = function(self)
	self.StopAutoPlayNextAnim(self)
	self.SetToAnimEnd(self)
end

M.SetToAnimEnd = function(self)
	self.bindData.showCountCtrl = self.pointNum
	self.bindData.isAnimFinished = true
end

M.IsAnimPlaying = function(self)
	return not self.bindData.isAnimFinished
end

M.SkipCurrentAnim = function(self)
	self.NextPoint(self)
end
