local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFParallelWithMonitor = DefClass("C_GFParallelWithMonitor", C_GFParallelWithMonitor, C_GFCompositeBase)
local C_GFParallelWithMonitor = C_GFParallelWithMonitor

function C_GFParallelWithMonitor:ctor(id, isMonitor)
	self.mNodeType = gGFConstant.NodeType.Parallel
	self.mNodeName = "C_GFParallelWithMonitor"
end

function C_GFParallelWithMonitor:OnUpdate()
	local childCount = #self.mChilds

	if childCount > 0 then
		self.mState = gGFConstant.State.Running

		for k, v in ipairs(self.mChilds) do
			local state = v:DoUpdateState()

			if v.mMonitor then
				if state == gGFConstant.State.Success then
					self:FinishNode(true)
				elseif state == gGFConstant.State.Failure then
					self:FinishNode(false)
				end
			end
		end
	else
		self:FinishNode(true)
	end
end

function C_GFParallelWithMonitor:OnReset()
	self.runningList = {}

	for k, v in pairs(self.mChilds) do
		v:ResetNode()
	end
end

function C_GFParallelWithMonitor:OnStopNode()
	for k, v in pairs(self.mChilds) do
		v:StopNode()
	end
end

function C_GFParallelWithMonitor:OnSetSuccess()
	for k, v in pairs(self.mChilds) do
		v:SetSuccess()
	end
end

function C_GFParallelWithMonitor:OnDestroy()
	for k, v in pairs(self.mChilds) do
		v:DestroyNode()
	end
end

return C_GFParallelWithMonitor
