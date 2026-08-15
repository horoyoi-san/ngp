local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFRepeatDecorator = DefClass("C_GFRepeatDecorator", C_GFRepeatDecorator, C_GFDecoratorBase)
local C_GFRepeatDecorator = C_GFRepeatDecorator

function C_GFRepeatDecorator:ctor(id, isMonitor, params)
	self.repeatNum = params.repeatNum
	self.mNodeName = "C_GFRepeatDecorator"
	self.count = 0
	self.needUpdateDebug = false
end

function C_GFRepeatDecorator:OnUpdate()
	if not self.mChild then
		self:FinishNode(true)
	elseif self.repeatNum == 0 then
		local state = self.mChild:DoUpdateState()
		self.count = self.count + 1
		self.needUpdateDebug = true

		if gGFConstant.State.Running < state then
			self.mChild:ResetNode()
		end
	elseif self.count < self.repeatNum then
		local state = self.mChild:DoUpdateState()

		if state == gGFConstant.State.Success then
			self.count = self.count + 1
			self.needUpdateDebug = true

			if self.count < self.repeatNum then
				self.mChild:ResetNode()
			else
				self:FinishNode(true)
			end
		elseif state == gGFConstant.State.Failure then
			self:FinishNode(false)
		end
	else
		self:FinishNode(true)
	end

	if self.needUpdateDebug then
		self:SendNodeDebugInfo()

		self.needUpdateDebug = false
	end
end

function C_GFRepeatDecorator:OnReset()
	self.count = 0
end

function C_GFRepeatDecorator:OnUpdateDebugInfo()
	self.mDebugInfo.repeatNum = self.count
end

function C_GFRepeatDecorator:PrintCurrentRunningState()
	print_notice("GF Debug => CURRENT STATE: ---引导当前执行状态=", self:GetStateName(self.mState), " 节点=", self.mNodeName, " count/repeatNum=", self.count, "/", self.repeatNum, " id=", self.mId)

	for k, v in pairs(self.mChilds) do
		v:PrintCurrentRunningState()
	end
end

return C_GFRepeatDecorator
