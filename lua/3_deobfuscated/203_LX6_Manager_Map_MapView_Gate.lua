MapView = MapView or {}
local M = MapView

function M:GateStageCheck(instanceId, ruleContext)
	local item = self.items[instanceId]

	if not item.representGBoundId or not self.cfg.ignoreInterestInGateStage and item.interestSourceCount > 0 then
		return true
	end

	local representGBoundId = item.representGBoundId

	if self.traceSpace.bounds[representGBoundId] then
		return false
	end

	local gateRule = ruleContext
	local gBoundId2AttachCount = gateRule.gBoundId2AttachCount
	local count = gBoundId2AttachCount and gBoundId2AttachCount[representGBoundId] or 0

	if count > 0 then
		return false
	else
		return true
	end
end

function M:GateStageRuleStepUpdate(allItems, ruleContext, instanceId, changeType)
	local gateRule = ruleContext
	local id2GBoundId = gateRule.id2GBoundId

	if not id2GBoundId then
		gateRule.id2GBoundId = {}
		id2GBoundId = gateRule.id2GBoundId
	end

	local gBoundId2AttachCount = gateRule.gBoundId2AttachCount

	if not gBoundId2AttachCount then
		gateRule.gBoundId2AttachCount = {}
		gBoundId2AttachCount = gateRule.gBoundId2AttachCount
	end

	local item = self.items[instanceId]
	local needAttachId = changeType ~= EMapViewStageItemChangeType.Remove and not item.representGBoundId and item.attachedGBoundId
	local hasAttachId = id2GBoundId[instanceId]

	if not needAttachId and not hasAttachId then
		return false
	elseif needAttachId and not hasAttachId then
		gBoundId2AttachCount[needAttachId] = (gBoundId2AttachCount[needAttachId] or 0) + 1
		id2GBoundId[instanceId] = needAttachId

		return true
	elseif not needAttachId and hasAttachId then
		id2GBoundId[instanceId] = nil
		gBoundId2AttachCount[hasAttachId] = gBoundId2AttachCount[hasAttachId] - 1

		return true
	elseif needAttachId ~= hasAttachId then
		gBoundId2AttachCount[hasAttachId] = gBoundId2AttachCount[hasAttachId] - 1
		gBoundId2AttachCount[needAttachId] = (gBoundId2AttachCount[needAttachId] or 0) + 1
		id2GBoundId[instanceId] = needAttachId

		return true
	else
		return false
	end
end

function M:GateStageRuleFullUpdate(allItems, ruleContext)
	local gateRule = ruleContext
	gateRule.id2GBoundId = {}
	gateRule.gBoundId2AttachCount = {}
	local id2GBoundId = gateRule.id2GBoundId
	local gBoundId2AttachCount = gateRule.gBoundId2AttachCount

	for instanceId, _ in pairs(allItems) do
		local item = self.items[instanceId]

		if not item.representGBoundId and item.attachedGBoundId then
			id2GBoundId[instanceId] = item.attachedGBoundId
			gBoundId2AttachCount[item.attachedGBoundId] = (gBoundId2AttachCount[item.attachedGBoundId] or 0) + 1
		end
	end
end
