local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFCheckStateDecorator = DefClass("C_GFCheckStateDecorator", C_GFCheckStateDecorator, C_GFDecoratorBase)
local C_GFCheckStateDecorator = C_GFCheckStateDecorator

function C_GFCheckStateDecorator:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFCheckStateDecorator"
	self.checkState = params.state
	self.frequency = params.checkFrequency < 1 and 1 or params.checkFrequency
	self.mode = params.mode
	self.force = params.forceIncrementSequence
	self.isInverse = params.isInverse
	self.finishWithChild = params.finishWithChild
	self.failWhenFalse = params.failWhenFalse
	self.manualTick = false
	self.lastCheckTime = 0
	self.isActivated = false
	self.childState = gGFConstant.State.Ready
end

function C_GFCheckStateDecorator:OnUpdate()
	if self.mChild then
		if Time.frameCount % self.frequency == 0 then
			if not self.isInverse ~= not self:CheckState() then
				self.isActivated = true
				self.childState = self.mChild:DoUpdateState(self.manualTick)

				if self.finishWithChild and gGFConstant.State.Running < self.childState then
					self:FinishNode(self.childState == gGFConstant.State.Success)
				end
			else
				if self.failWhenFalse then
					if self.isActivated and self.mChild:DoUpdateState(self.manualTick) == gGFConstant.State.Success then
						self:FinishNode(true)
					else
						self:FinishNode(false)
					end
				end

				if self.isActivated then
					self.childState = self.mChild:DoUpdateState(self.manualTick)

					if gGFConstant.State.Failure <= self.childState then
						self:FinishNode(false)
					elseif self.mode == gGFConstant.CheckStateSuccessMode.StateChange or self.childState == gGFConstant.State.Success then
						self:FinishNode(true)
					elseif self.manualTick then
						self.mChild:ManualIncrement(self.force)
					else
						self.mChild:StopNode()
					end

					self.isActivated = false
				end
			end
		end
	else
		self:FinishNode(true)
	end
end

function C_GFCheckStateDecorator:CheckState()
	return gGFCondition:CheckCondition(self.checkState)
end

function C_GFCheckStateDecorator:SetChild(child)
	self.mChild = child
	self.manualTick = self.mChild:GetType() == gGFConstant.NodeType.Sequence
end

function C_GFCheckStateDecorator:OnReset()
	self.isActivated = false
	self.childState = gGFConstant.State.Ready
end

return C_GFCheckStateDecorator
