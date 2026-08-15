local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFDelayDecorator = DefClass("C_GFDelayDecorator", C_GFDelayDecorator, C_GFDecoratorBase)
local C_GFDelayDecorator = C_GFDelayDecorator

function C_GFDelayDecorator:ctor(id, isMonitor, params)
	self.delayTime = params.delayTime
	self.scaled = params.scaledTime
	self.mNodeName = "C_GFDelayDecorator"
	self.triggered = false
	self.startTime = 0
end

function C_GFDelayDecorator:OnStart()
	self.startTime = self.scaled and Time.time or Time.unscaledTime
end

function C_GFDelayDecorator:OnUpdate()
	if self.triggered then
		local state = self.mChild:DoUpdateState()

		if state == gGFConstant.State.Success then
			self:FinishNode(true)
		elseif state == gGFConstant.State.Failure then
			self:FinishNode(false)
		end
	elseif self:CheckTime() then
		self.triggered = true
	end
end

function C_GFDelayDecorator:CheckTime()
	return self.scaled and Time.time > self.startTime + self.delayTime or Time.unscaledTime > self.startTime + self.delayTime
end

function C_GFDelayDecorator:OnReset()
	self.triggered = false
end

function C_GFDelayDecorator:OnSetSuccess()
	self.triggered = true
end

return C_GFDelayDecorator
