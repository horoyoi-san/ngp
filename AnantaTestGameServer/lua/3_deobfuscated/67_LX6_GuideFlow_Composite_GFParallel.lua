local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFParallel = DefClass("C_GFParallel", C_GFParallel, C_GFCompositeBase)
local C_GFParallel = C_GFParallel

function C_GFParallel:ctor(id, isMonitor)
	self.mNodeType = gGFConstant.NodeType.Parallel
	self.mNodeName = "C_GFParallel"
end

function C_GFParallel:OnUpdate()
	local childCount = #self.mChilds

	if childCount > 0 then
		local successCount = 0
		local failureCount = 0

		for k, v in ipairs(self.mChilds) do
			local state = v:DoUpdateState()

			if state == gGFConstant.State.Success then
				successCount = successCount + 1
			elseif state == gGFConstant.State.Failure then
				failureCount = failureCount + 1
			end
		end

		if successCount == childCount then
			self:FinishNode(true)
		elseif successCount + failureCount == childCount then
			self:FinishNode(false)
		end
	else
		self:FinishNode(true)
	end
end

function C_GFParallel:OnReset()
	for k, v in pairs(self.mChilds) do
		v:ResetNode()
	end
end

function C_GFParallel:OnStopNode()
	for k, v in pairs(self.mChilds) do
		v:StopNode()
	end
end

function C_GFParallel:OnSetSuccess()
	for k, v in pairs(self.mChilds) do
		v:SetSuccess()
	end
end

function C_GFParallel:OnDestroy()
	for k, v in pairs(self.mChilds) do
		v:DestroyNode()
	end
end

return C_GFParallel
