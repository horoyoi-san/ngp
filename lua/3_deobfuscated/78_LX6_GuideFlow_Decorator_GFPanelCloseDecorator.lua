local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFPanelCloseDecorator = DefClass("C_GFPanelCloseDecorator", C_GFPanelCloseDecorator, C_GFDecoratorBase)
local C_GFPanelCloseDecorator = C_GFPanelCloseDecorator

function C_GFPanelCloseDecorator:ctor(id, isMonitor, params)
	self.panelId = params.panelId
	self.mNodeName = "C_GFPanelCloseDecorator"
	self.triggered = false
	self.mListenerAdd = false
	self.mStarted = false
	self.msgEvents = {}
end

function C_GFPanelCloseDecorator:OnStart()
	if not self.mListenerAdd then
		gMessageManager:RegisterEventHandlers(self.msgEvents)

		self.mListenerAdd = true

		print_error("AddListener")
	end

	self.mStarted = true
end

function C_GFPanelCloseDecorator:OnStopNode()
	self.mStarted = false

	print_error("OnStopNode")
end

function C_GFPanelCloseDecorator:OnDestroy()
	if self.mListenerAdd then
		gMessageManager:RemoveMessageListener(self.msgEvents)

		self.mListenerAdd = false

		print_error("RemoveListener")
	end
end

function C_GFPanelCloseDecorator:OnFinish(isSuccess)
	if self.mListenerAdd then
		gMessageManager:RemoveMessageListener(self.msgEvents)

		self.mListenerAdd = false

		print_error("RemoveListener")
	end
end

function C_GFPanelCloseDecorator:OnUpdate()
	if not self.mStarted then
		self.mStarted = true

		print_error("OnUpdate")
	end

	if self.triggered then
		local state = self.mChild:DoUpdateState()

		if state == gGFConstant.State.Success then
			self:FinishNode(true)
		elseif state == gGFConstant.State.Failure then
			self:FinishNode(false)
		else
			self.mState = state
		end
	end
end

function C_GFPanelCloseDecorator:OnReset()
	self.triggered = false
	self.mStarted = false

	print_error("OnReset")
end

function C_GFPanelCloseDecorator:OnSetSuccess()
	self.triggered = true

	if self.mListenerAdd then
		gMessageManager:RemoveMessageListener(self.msgEvents)

		self.mListenerAdd = false

		print_error("RemoveListener")
	end
end

return C_GFPanelCloseDecorator
