MapView = MapView or {}
local M = MapView

function M:InitConflictStageRuleContext(ruleContext)
	ruleContext.bindRootId2ConflictMask = {}
end

function M:ConflictStageCheck(instanceId, ruleContext)
	local bindRootId = gGpsBindingMgr:GetBindRootIdByGpsInstanceId(instanceId)

	if not bindRootId then
		return true
	elseif not ruleContext.bindRootId2ConflictMask[bindRootId] then
		return true
	else
		local element = gMapSystem.container:Get(instanceId)
		local priority = element.fData.bindConflictPriority or 0
		local conflictMask = ruleContext.bindRootId2ConflictMask[bindRootId]

		if priority < conflictMask then
			return false
		else
			return true
		end
	end
end

function M:ConflictStageRuleStepUpdate(allItems, ruleContext, instanceId, changeType)
	return
end

function M:ConflictStageRuleFullUpdate(allItems, ruleContext)
	local newMask = gGpsTools.GetTable()

	for instanceId, _ in pairs(allItems) do
		local bindRootId = gGpsBindingMgr:GetBindRootIdByGpsInstanceId(instanceId)

		if bindRootId then
			local element = gMapSystem.container:Get(instanceId)
			local priority = element.fData.bindConflictPriority or 0

			if not newMask[bindRootId] or newMask[bindRootId] < priority then
				newMask[bindRootId] = priority
			end
		end
	end

	return gGpsTools.TrySetDict(ruleContext.bindRootId2ConflictMask, newMask)
end
