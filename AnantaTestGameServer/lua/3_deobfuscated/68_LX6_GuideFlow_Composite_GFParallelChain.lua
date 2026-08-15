local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFParallelChain = DefClass("C_GFParallelChain", C_GFParallelChain, C_GFCompositeBase)
local C_GFParallelChain = C_GFParallelChain

function C_GFParallelChain:ctor(id, isMonitor)
	self.mNodeType = gGFConstant.NodeType.Parallel
	self.runningList = {}
	self.mNodeName = "C_GFParallelChain"
end

function C_GFParallelChain:OnUpdate()
	local childCount = #self.mChilds

	if childCount > 0 then
		local successCount = 0
		local failureCount = 0
		self.runningList = {}

		for idx, node in ipairs(self.mChilds) do
			local state = node:DoUpdateState()

			if state == gGFConstant.State.Success then
				for _, v in ipairs(self.runningList) do
					self.mChilds[v]:SetSuccess()
				end

				self.runningList = {}
				successCount = idx
			elseif state == gGFConstant.State.Failure then
				failureCount = failureCount + 1
			elseif state == gGFConstant.State.Running then
				table.insert(self.runningList, idx)
			end
		end

		if successCount == childCount then
			self:FinishNode(true)
		elseif failureCount == childCount then
			self:FinishNode(false)
		end
	else
		self:FinishNode(true)
	end
end

function C_GFParallelChain:OnReset()
	self.runningList = {}

	for k, v in pairs(self.mChilds) do
		v:ResetNode()
	end
end

function C_GFParallelChain:OnStopNode()
	for k, v in pairs(self.mChilds) do
		v:StopNode()
	end
end

function C_GFParallelChain:OnSetSuccess()
	for k, v in pairs(self.mChilds) do
		v:SetSuccess()
	end
end

function C_GFParallelChain:OnDestroy()
	for k, v in pairs(self.mChilds) do
		v:DestroyNode()
	end
end

return C_GFParallelChain
