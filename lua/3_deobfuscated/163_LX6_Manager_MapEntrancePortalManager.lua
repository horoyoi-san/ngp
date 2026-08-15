local M = {
	RaidEntranceType = {
		BaseStation = 10,
		TaskReview = 8,
		Enhancement = 6,
		Matrix = 7
	},
	OnEvent_OutOfRange = function (self, data)
		local uniqueId = data

		gInteractionManager:OnSceneObjExit(uniqueId)
	end
}

function M:Cs2LuaOnEventEnterSamePlace(param)
	local dict = param.ToTable()

	M:OnEventEnterSamePlace(dict)
end

function M:OnEventEnterSamePlace(data, taskRaidInfo)
	local baseInfo = M:GetBaseInfoForSamePlace(data, taskRaidInfo)

	if baseInfo.RaidId == 0 then
		return
	end
end

function M:GetBaseInfoForSamePlace(data, taskRaidInfo)
	local baseInfo = {
		UniqueId = data.UniqueId,
		IconId = data.IconId,
		IconText = data.IconText,
		RaidId = data.RaidId,
		WayPoint = data.WayPoint,
		TimeLine = data.TimeLine,
		XAxis = data.XAxis,
		YAxis = data.YAxis
	}

	if taskRaidInfo then
		local list = taskRaidInfo:ToTable()

		for _, info in pairs(list) do
			if table.contains(gTaskNodeManager.NowDoingTask, info.TaskId) then
				baseInfo.RaidId = info.RaidId
				baseInfo.IconId = info.IconId

				return baseInfo
			end
		end
	end

	return baseInfo
end

function M:EnterSamePlace(entranceInfo)
	gRpcUtils:AskEnterRaidByRaidId(entranceInfo.RaidId, entranceInfo.WayPoint, entranceInfo.XAxis, entranceInfo.YAxis)
end

gMapEntrancePortalManager = M
