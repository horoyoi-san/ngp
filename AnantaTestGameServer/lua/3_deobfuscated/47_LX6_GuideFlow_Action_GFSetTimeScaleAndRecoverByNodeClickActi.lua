C_GFSetTimeScaleAndRecoverByNodeClickAction = DefClass("C_GFSetTimeScaleAndRecoverByNodeClickAction", C_GFSetTimeScaleAndRecoverByNodeClickAction, C_GFWaitActionBase)
local C_GFSetTimeScaleAndRecoverByNodeClickAction = C_GFSetTimeScaleAndRecoverByNodeClickAction

function C_GFSetTimeScaleAndRecoverByNodeClickAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFSetTimeScaleAndRecoverByNodeClickAction"
	self.timeScale = params.timeScale
	self.nodeName = params.nodeName
	self.countDownTime = params.countDownTime and (params.countDownTime < 0 and -1 or params.countDownTime) or -1
	self.recordTimeScale = false

	function self.clickCb()
		if self.recordTimeScale then
			Time.timeScale = self.recordTimeScale
			self.recordTimeScale = false

			gGuideNode:RemoveClickCallback(gGuideNode:GetNode(self.nodeName), self.clickCb, true)
		end

		self.isFinished = true
	end

	self.msgEvents = {
		[gEventConstants.GUIDE_NODE_GO_CREATE] = function (eventId, msg)
			if msg == self.nodeName then
				gGuideNode:AddClickCallback(gGuideNode:GetNode(self.nodeName), self.clickCb, true)
			end
		end
	}
end

function C_GFSetTimeScaleAndRecoverByNodeClickAction:OnStartAction()
	self.recordTimeScale = Time.timeScale
	Time.timeScale = self.timeScale
	self.timeRecord = Time.unscaledTime
	local node = gGuideNode:GetNode(self.nodeName)

	if node.gameObject then
		gGuideNode:AddClickCallback(node, self.clickCb, true)
	end

	self.mStartAction = true
end

function C_GFSetTimeScaleAndRecoverByNodeClickAction:OnUpdateForce()
	if not self.mSelfFinished and self.recordTimeScale and self:CheckCountDownTime() then
		Time.timeScale = self.recordTimeScale
		self.recordTimeScale = false

		gGuideNode:RemoveClickCallback(gGuideNode:GetNode(self.nodeName), self.clickCb, true)

		self.mSelfFinished = true
	end
end

function C_GFSetTimeScaleAndRecoverByNodeClickAction:CheckCountDownTime()
	if self.countDownTime < 0 then
		return false
	else
		return self.countDownTime < Time.unscaledTime - self.timeRecord
	end
end

function C_GFSetTimeScaleAndRecoverByNodeClickAction:OnStopNode()
	if not self.mSelfFinished then
		if self.recordTimeScale then
			Time.timeScale = self.recordTimeScale
			self.recordTimeScale = false

			gGuideNode:RemoveClickCallback(gGuideNode:GetNode(self.nodeName), self.clickCb, true)
		end

		self.mStartAction = false
	end
end

function C_GFSetTimeScaleAndRecoverByNodeClickAction:OnReset()
	self.mSelfFinished = false
end

return C_GFSetTimeScaleAndRecoverByNodeClickAction
