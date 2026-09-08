-- Original chunk: @Lua\LuaFiles\LX6\Manager\MapEntrancePortalManager.lua
-- Decompiled from: 00523_MapEntrancePortalManager.lua_9a91cd2f2118.luajit

local M = {
	RaidEntranceType = {
		["\\xbd53:K\\x89@\\xcd>\\xa5\\xb7"] = 10,
		["g[ݶ\\xb6\r\\xae\r\\xcc\\xff"] = 8,
		["\\xba:(>v\\x9eD\\xd42\\xa4\\xad"] = 6,
		["1I\\x85\\x9c\\x8aY"] = 7
	},
	OnEvent_OutOfRange = function (self, data)
		local uniqueId = data

		gInteractionManager:OnSceneObjExit(uniqueId)
	end
}

M.Cs2LuaOnEventEnterSamePlace = function(self, param)
	local dict = param.ToTable()

	M:OnEventEnterSamePlace(dict)
end

M.OnEventEnterSamePlace = function(self, data, taskRaidInfo)
	local baseInfo = M:GetBaseInfoForSamePlace(data, taskRaidInfo)

	if baseInfo.RaidId ~= 0 then
		return
	end
end

M.GetBaseInfoForSamePlace = function(self, data, taskRaidInfo)
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
		local list = taskRaidInfo.ToTable(taskRaidInfo)

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

M.EnterSamePlace = function(self, entranceInfo)
	gRpcUtils:AskEnterRaidByRaidId(entranceInfo.RaidId, entranceInfo.WayPoint, entranceInfo.XAxis, entranceInfo.YAxis)
end

gMapEntrancePortalManager = M
