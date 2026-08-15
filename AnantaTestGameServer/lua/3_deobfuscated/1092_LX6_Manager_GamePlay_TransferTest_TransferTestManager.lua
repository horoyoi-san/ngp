local M = gTransferTestManager or {}
M.IsInit = M.IsInit or false
M.InPlayingData = M.InPlayingData or {}
M.LinkGadgetData = M.LinkGadgetData or {}
M.ConditionGadgetToPlayingIdMap = M.ConditionGadgetToPlayingIdMap or {}
M.WaitChangeStateFinishGadgetIdMap = M.WaitChangeStateFinishGadgetIdMap or {}
local ON_STATE_CHANGE_SIGNAL = "StateChange"
local ON_SUCCESS_SIGNAL = "Success"

function M:StartPlaying(id, effectId, linkConfigData, successCondition, successCallback)
	self:OnInit()

	if self.InPlayingData[id] then
		print_warn("玩法已开启，请勿重复开启玩法", id)

		return
	end

	linkConfigData = linkConfigData and linkConfigData:ToTable() or {}

	for i, v in ipairs(linkConfigData) do
		linkConfigData[i] = v:ToTable()

		if linkConfigData[i].linkGadget and linkConfigData[i].linkGadget.ToTable then
			linkConfigData[i].linkGadget = linkConfigData[i].linkGadget:ToTable()
		end
	end

	successCondition = successCondition and successCondition:ToTable() or {}

	for i, v in ipairs(successCondition) do
		successCondition[i] = v:ToTable()
	end

	self.InPlayingData[id] = {
		linkConfigData = linkConfigData,
		successCondition = successCondition,
		successCallback = function ()
			successCallback:DynamicInvoke()
		end,
		linkedOrderArray = {},
		goList = {},
		effectId = effectId
	}

	if linkConfigData then
		for _, linkInfo in ipairs(linkConfigData) do
			self.LinkGadgetData[linkInfo.sourceGadget] = linkInfo.linkGadget
		end
	end

	for _, condition in ipairs(successCondition) do
		self.ConditionGadgetToPlayingIdMap[condition.gadgetCreator] = id
	end

	self.InPlayingData[id].linkedOrderArray, self.InPlayingData[id].goList = self:GetLinkedOrderArray(linkConfigData)
end

function M:OnInit()
	if self.IsInit then
		return
	end

	self.IsInit = true

	gMessageManager:AddMessageListener(gEventConstants.ON_GADGET_STATE_START_CHANGE, self.OnGadgetStateBeginChange)
	gMessageManager:AddMessageListener(gEventConstants.ON_GADGET_STATE_CHANGE, self.OnGadgetStateChange)
end

function M:GetLinkedOrderArray(linkConfigData)
	local linkedOrderArray = {}
	local alreadyLinked = {}
	local goList = {}

	if linkConfigData then
		for _, linkInfo in ipairs(linkConfigData) do
			for _, gadget in ipairs(linkInfo.linkGadget) do
				if not alreadyLinked[gadget] then
					local tmp = {}

					table.insert(tmp, gadget)
					table.insert(tmp, linkInfo.sourceGadget)

					linkedOrderArray[#linkedOrderArray + 1] = tmp

					if not alreadyLinked[linkInfo.sourceGadget] then
						alreadyLinked[linkInfo.sourceGadget] = true
					end
				end
			end

			if linkInfo.rootComponentId and linkInfo.rootComponentId > 0 then
				local gadget = gGadgetManager:GetEntitySearchByInstanceId(linkInfo.sourceGadget)

				if not gadget then
					print_error("@chenguo 机关缺失", linkInfo.sourceGadget)

					return
				end

				local gameObject = gadget:GetGameObjectById(linkInfo.rootComponentId)

				if not gameObject then
					print_error("@chenguo 机关组件缺失", linkInfo.rootComponentId)

					return
				end

				goList[linkInfo.sourceGadget] = gameObject
			end
		end
	else
		print_error("@chenguo 玩法数据为空")
	end

	return linkedOrderArray, goList
end

function M.OnGadgetStateBeginChange(_, params)
	params = params:ToTable()

	if params.needCheckLink and M.LinkGadgetData[params.entityInstanceId] then
		local linkGadget = M.LinkGadgetData[params.entityInstanceId]

		for _, linkGadgetId in ipairs(linkGadget) do
			local linkGadgetPlayingId = M.ConditionGadgetToPlayingIdMap[linkGadgetId]

			if linkGadgetPlayingId then
				M.WaitChangeStateFinishGadgetIdMap[linkGadgetPlayingId] = M.WaitChangeStateFinishGadgetIdMap[linkGadgetPlayingId] or {}
				M.WaitChangeStateFinishGadgetIdMap[linkGadgetPlayingId][linkGadgetId] = true
			end

			local linkGadget = gGadgetManager:GetEntitySearchByInstanceId(linkGadgetId)

			linkGadget:TryCallInnerSignal(ON_STATE_CHANGE_SIGNAL)
		end
	end
end

function M.OnGadgetStateChange(_, entityInstanceId)
	local playingId = M.ConditionGadgetToPlayingIdMap[entityInstanceId]

	if playingId and M.WaitChangeStateFinishGadgetIdMap[playingId] then
		M.WaitChangeStateFinishGadgetIdMap[playingId][entityInstanceId] = nil
	end

	if playingId and M.WaitChangeStateFinishGadgetIdMap[playingId] and table.count(M.WaitChangeStateFinishGadgetIdMap[playingId]) == 0 then
		M:CheckSuccess(playingId)
	end
end

function M:PlayLinkedGadgetEffect(id, effectId)
	if not id or not effectId or self.InPlayingData[id] == nil or effectId <= 0 then
		return
	end

	local data = self.InPlayingData[id]
	local lineList = data.linkedOrderArray
	local goList = data.goList

	for _, line in ipairs(lineList) do
		if line[1] and line[2] and not gCS.LuaUtils.IsNull(goList[line[1]]) and not gCS.LuaUtils.IsNull(goList[line[1]]) then
			local uuid = gCS.EffectMgr:PlayEffectsOnTransform(effectId, goList[line[1]].transform)

			gCS.EffectMgr:SetEffectVfxTransformByUUId(uuid, "A", goList[line[1]].transform)
			gCS.EffectMgr:SetEffectVfxTransformByUUId(uuid, "B", goList[line[2]].transform)
		end
	end
end

function M:CheckSuccess(id)
	if self.InPlayingData[id] == nil then
		return false
	end

	local data = self.InPlayingData[id]

	for _, condition in ipairs(data.successCondition) do
		local gadget = gGadgetManager:GetEntitySearchByInstanceId(condition.gadgetCreator)

		if gadget == nil then
			return false
		end

		local state = gadget:GetState(condition.stateType)

		if state ~= condition.state then
			return false
		end
	end

	local effectId = data.effectId

	self:PlayLinkedGadgetEffect(id, effectId)

	for _, condition in ipairs(data.successCondition) do
		local gadget = gGadgetManager:GetEntitySearchByInstanceId(condition.gadgetCreator)

		gadget:TryCallInnerSignal(ON_SUCCESS_SIGNAL)
	end

	if data.successCallback then
		data.successCallback()
	end

	return true
end

function M:StopPlaying(id)
	local data = self.InPlayingData[id]

	if data then
		if data.linkConfigData then
			for _, linkInfo in ipairs(data.linkConfigData) do
				self.LinkGadgetData[linkInfo.sourceGadget] = nil
			end
		end

		if data.successCondition then
			for _, condition in ipairs(data.successCondition) do
				self.ConditionGadgetToPlayingIdMap[condition.gadgetCreator] = nil
			end
		end
	end

	self.InPlayingData[id] = nil
end

gTransferTestManager = M
