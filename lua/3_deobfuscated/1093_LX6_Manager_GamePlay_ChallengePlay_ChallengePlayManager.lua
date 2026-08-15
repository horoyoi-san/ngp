local M = gChallengeManager or {}
M.IsInit = M.IsInit or false
M.InPlayingData = M.InPlayingData or {}
M.GadgetIdToPlayingIdMap = M.GadgetIdToPlayingIdMap or {}
local ON_START_SHOW_SIGNAL = "OnStartShow"
local SPOON_CLIENT_NAME = "SceneEvent_ChallengePlay_23300888"

function M:StartPlay(nodeId, allGadgetIdList, successCallback)
	if allGadgetIdList and allGadgetIdList.ToTable then
		allGadgetIdList = allGadgetIdList:ToTable()
	end

	self:OnInit()

	if self.InPlayingData[nodeId] then
		print_warn("@chenguo 玩法已开启，请勿重复开启玩法", nodeId)

		return
	end

	self.InPlayingData[nodeId] = {
		allGadgetIdList = allGadgetIdList,
		successCallback = successCallback
	}

	for _, gadgetId in ipairs(allGadgetIdList) do
		self.GadgetIdToPlayingIdMap[gadgetId] = nodeId
	end

	L50.L50App.Scene.SpoonClientMgr:StartGraph(nodeId, nodeId, SPOON_CLIENT_NAME, L50.Spoon.SpoonRunTime.ClientGraphType.TASK_SPOON_CLIENT, true, nil, nil)
end

function M:OnNpcPassBy(gadgetUId)
	local playId = self.GadgetIdToPlayingIdMap[gadgetUId]

	if playId == nil then
		print_warn("@chenguo 该机关没有找到对应的玩法", gadgetUId)

		return
	end

	local data = self.InPlayingData[playId]

	if data == nil then
		print_warn("@chenguo 该玩法没有对应数据", playId)

		return
	end

	local gadgetUIdList = data.allGadgetIdList
	local target = nil

	for _, uid in ipairs(gadgetUIdList) do
		if ulong.equals(uid, gadgetUId) then
			target = uid

			break
		end
	end

	if target == nil then
		print_warn("@chenguo 该玩法未找到指定机关", gadgetUId, playId)

		return
	end

	local gadget = gGadgetManager:GetEntitySearchByInstanceId(gadgetUId)

	if gadget then
		gadget:TryCallInnerSignal(ON_START_SHOW_SIGNAL)
	else
		print_warn("@chenguo 找不到机关", gadgetUId)
	end

	if data.successCallback then
		if data.successCallback.DynamicInvoke then
			data.successCallback:DynamicInvoke()
		else
			data.successCallback()
		end
	end
end

function M:OnInit()
	if self.IsInit then
		return
	end

	self.IsInit = true
end

function M:StopPlay(nodeId)
	local data = self.InPlayingData[nodeId]

	if data.allGadgetIdList and data.allGadgetIdList.ToTable then
		data.allGadgetIdList = data.allGadgetIdList:ToTable()
	end

	if data and data.allGadgetIdList then
		for _, gadgetId in ipairs(data.allGadgetIdList) do
			self.GadgetIdToPlayingIdMap[gadgetId] = nil
		end
	end

	self.InPlayingData[nodeId] = nil
	self.IsInit = false
end

gChallengeManager = M
