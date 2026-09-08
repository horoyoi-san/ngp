-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_OnlineTrace.lua
-- Decompiled from: 02318_MapSubSystem_OnlineTrace.lua_493d541fd61c.luajit

MapSubSystem_OnlineTrace = DefClass("MapSubSystem_OnlineTrace", MapSubSystem_OnlineTrace, MapSubSystemBase)
local M = MapSubSystem_OnlineTrace

M.OnInit = function(self)
	self.trackGPSInfos = {}
	self.trackGPSElementIds = {}

	self.InitEventHandlers(self)
end

M.OnLoadData = function(self)
	self.ClearData(self)
end

M.OnLogin = function(self)
	self:ClearData()
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogout = function(self)
	self.ClearData(self)
end

M.ClearData = function(self)
	for _, instanceId in pairs(self.trackGPSElementIds) do
		gMapSystem.trace:RemoveOnlineTraceId(instanceId)

		local element = gMapSystem.container:Get(instanceId)

		if element then
			element.Dispose(element)
		end
	end

	table.clear(self.trackGPSElementIds)
end

M.OnLoadData = function(self)
	self.ClearData(self)
end

M.OnLogout = function(self)
	self.ClearData(self)
end

M.OnSceneDestroy = function(self)
	self.ClearData(self)
end

M.InitEventHandlers = function(self)
	self.eventHandlers = {
		[gEventConstants.LINK_MODE_CHANGE] = function ()
			self:FlushData()
		end,
		[gEventConstants.LINK_MEMBER_INFO_CHANGE] = function ()
			self:FlushData()
		end,
		[gEventConstants.TEAM_REFRESH_DATA] = function ()
			self:FlushData()
		end,
		[gEventConstants.TEAM_JOIN] = function ()
			gMapSystem.trace:TrySyncTrackGPS()
		end,
		[gEventConstants.TEAM_MEMBER_CHANGED] = function ()
			gMapSystem.trace:TrySyncTrackGPS()
		end
	}
end

M.OnFlushData = function(self)
	for pid, _ in pairs(self.trackGPSElementIds) do
		if not gTeamManager:GetMember(pid) then
			self.SyncTrackGPS(self, pid, nil)
		end
	end

	if gTeamManager.members then
		for _, memberInfo in ipairs(gTeamManager.members) do
			local pid = memberInfo.Pid

			self.SyncTrackGPS(self, pid, memberInfo.TrackGPS)
		end
	end
end

M.RemoveTrackGPS = function(self, pid)
	if self.trackGPSElementIds[pid] then
		local instanceId = self.trackGPSElementIds[pid]

		gMapSystem.trace:RemoveOnlineTraceId(instanceId)

		local element = gMapSystem.container:Get(instanceId)

		if element then
			element.RemoveOnlineTrace(element, pid)

			if element.type ~= EMapElementType.Mark then
				element.Dispose(element)
			end
		end

		self.trackGPSElementIds[pid] = nil
	end
end

M.CheckIsSameTrackGpsInfo = function(self, info1, info2)
	if info1 ~= nil and info2 ~= nil then
		return false
	end

	if info1 ~= nil and info2 == nil or info1 == nil and info2 ~= nil then
		return false
	end

	if info1.TrackGPSType == info2.TrackGPSType or info1.TrackGPSId == info2.TrackGPSId then
		return false
	end

	if math.abs(info1.TrackPosition.X - info2.TrackPosition.X) >= 0.01 or math.abs(info1.TrackPosition.Y - info2.TrackPosition.Y) >= 0.01 or math.abs(info1.TrackPosition.Z - info2.TrackPosition.Z) <= 0.01 then
		return false
	end

	return true
end

M.SyncTrackGPS = function(self, pid, trackGPS)
	if pid ~= gPlayerManager.infoLogin.bindData.pid then
		return
	end

	if self.CheckIsSameTrackGpsInfo(self, self.trackGPSInfos[pid], trackGPS) then
		return
	end

	if self.trackGPSInfos[pid] then
		self.RemoveTrackGPS(self, pid)
	end

	self.trackGPSInfos[pid] = trackGPS

	if not trackGPS then
		return
	end

	local type = trackGPS.TrackGPSType or 0
	local idStr = ulong.tostring(pid)
	local raidId = gMapManager:GetParentRaidId(gMapSystem.lastRaidId)
	local indoorId = gMapSystem.lastIndoorId

	if indoorId <= 0 then
		local indoorCfg = LTConfig.IndoorConfig.GetConfig(indoorId)

		if indoorCfg then
			raidId = indoorCfg.ParentRaid or LTConfig.RaidConfig.WorldMap
		else
			raidId = LTConfig.RaidConfig.WorldMap
		end
	end

	local gpsId = trackGPS.TrackGPSId

	if type ~= EMapElementType.Mark then
		local worldPos = Vector3.New(trackGPS.TrackPosition.X, trackGPS.TrackPosition.Y, trackGPS.TrackPosition.Z)
		local element = MapElement.CreateLegacy(EMapElementType.Mark, idStr, EMapSubSystemType.Pin, EMapViewMask.AllSgui, raidId, 0)
		element.gpsData.pId = pid

		gMapSubSystem_Pin:SetupCommonBigWorldPin(element)

		element.fData.ignoreFog = true
		element.gpsData.sceneEffectInfo = gMapSystem.DefaultGpsSceneEffect
		element.bigMapData.unselectable = true

		element:SetVisible(true)
		element:SetPosition(worldPos)

		self.trackGPSElementIds[pid] = element.instanceId

		gMapSystem.trace:AddOnlineTraceId(element.instanceId)
		element:SetOnlineTrace(pid)
	else
		local element = gMapSystem.container:GetByGpsId(gpsId)

		if element then
			gMapSystem.trace:AddOnlineTraceId(element.instanceId)

			self.trackGPSElementIds[pid] = element.instanceId

			element:SetOnlineTrace(pid)
		end
	end
end

return M
