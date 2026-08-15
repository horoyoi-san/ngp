C_GFConditionBranch = DefClass("C_GFConditionBranch", C_GFConditionBranch, C_GFBranchBase)
local C_GFConditionBranch = C_GFConditionBranch

function C_GFConditionBranch:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFConditionBranch"
	self.newCondition = params.newCondition
	self.legacyCondition = params.legacyCondition or params.condition
	self.useLegacyCondition = false
	self.checkBlock = nil
end

function C_GFConditionBranch:OnStart()
	self:InitCheckBlock()
end

function C_GFConditionBranch:CheckCondition()
	if self.useLegacyCondition then
		return self.checkBlock:Check()
	else
		return gGFCondition:CheckCondition(self.newCondition)
	end
end

function C_GFConditionBranch:OnStopNode()
	self:ClearCheckBlock()
end

function C_GFConditionBranch:OnFinish(isSuccess)
	self:ClearCheckBlock()
end

function C_GFConditionBranch:InitCheckBlock()
	if self.legacyCondition and not string.is_null_or_empty(self.legacyCondition) and gGuideConditionFormula[self.legacyCondition] then
		self.useLegacyCondition = true
		self.checkBlock = gGuideConditionFormula[self.legacyCondition](gGuideConditionFormula)
	end
end

function C_GFConditionBranch:ClearCheckBlock()
	self.useLegacyCondition = false

	if self.checkBlock then
		self.checkBlock:Dispose()

		self.checkBlock = nil
	end
end

return C_GFConditionBranch
