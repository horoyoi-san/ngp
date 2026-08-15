local gGFConstant = require("LX6/GuideFlow/GFConstant")
local DataSet = require("LX6/DataBind/DataSet")
C_GFGuideEventDecorator = DefClass("C_GFGuideEventDecorator", C_GFGuideEventDecorator, C_GFDecoratorBase)
local C_GFGuideEventDecorator = C_GFGuideEventDecorator

function C_GFGuideEventDecorator:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFGuideEventDecorator"
	self.eventName = params.eventName
	self.finishDirectly = params.invisible
	self.cell = false
	self.conditionSuccess = false
	self.isFinished = false
end

function C_GFGuideEventDecorator:AddGuideListener()
	gPlayerManager.guideEvents.bindData[self.eventName] = DataSet.EVENT_VALUE
	self.cell = gPlayerManager.guideEvents.bindData:BindHandler(self.eventName, function (cell)
		self.conditionSuccess = true

		self.cell:Destroy()

		self.cell = false
	end)
end

function C_GFGuideEventDecorator:RemoveGuideListener()
	if self.cell then
		self.cell:Destroy()

		self.cell = false
	end
end

function C_GFGuideEventDecorator:OnStart()
	if not self.cell then
		self:AddGuideListener()
	end
end

function C_GFGuideEventDecorator:OnUpdate()
	if self.finishDirectly then
		self:FinishNode(true)
	elseif self.conditionSuccess then
		if self.mChild then
			local state = self.mChild:DoUpdateState()

			if state == gGFConstant.State.Success then
				self.mSelfFinished = true

				self:FinishNode(true)
			elseif state == gGFConstant.State.Failure then
				self.mSelfFinished = true

				self:FinishNode(false)
			end
		else
			self.mSelfFinished = true

			self:FinishNode(true)
		end
	end
end

function C_GFGuideEventDecorator:OnDestroy()
	self:RemoveGuideListener()
end

function C_GFGuideEventDecorator:OnUpdateForce()
	if self.finishDirectly and self.mChild and self.conditionSuccess and not self.mSelfFinished then
		local state = self.mChild:DoUpdateState()

		if gGFConstant.State.Success < state then
			self.mSelfFinished = true

			self:RemoveGuideListener()
		end
	end
end

function C_GFGuideEventDecorator:OnStopNode()
	self:RemoveGuideListener()
end

function C_GFGuideEventDecorator:OnReset()
	self.mSelfFinished = false
	self.conditionSuccess = false
end

return C_GFGuideEventDecorator
