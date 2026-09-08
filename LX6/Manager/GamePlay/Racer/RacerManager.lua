-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\Racer\RacerManager.lua
-- Decompiled from: 00761_RacerManager.lua_a311bf4209f3.luajit

local MessageConfig = LTConfig.MessageConfig
C_RacerManager = DefClass("C_RacerManager", C_RacerManager, nil)
local M = C_RacerManager
M.APP_PAGE = {
	["\\xf1\\xf2')1\\xc8"] = 1,
	["?i\\xa3\\xab\\xa6s"] = 2,
	["R\rP~"] = 0
}

M.ctor = function(self)
	self.panelStore = nil
	self.racingInfo = nil
end

M.RegisterPanelStore = function(self, store)
	self.panelStore = store

	self:RequestRacingInfo()
end

M.UnregisterPanelStore = function(self)
	self.panelStore = nil
end

M.SwitchToPage = function(self, pageIndex)
	if self.panelStore then
		self.panelStore:SwitchToPage(pageIndex)
	end
end

M.RequestRacingInfo = function(self)
	gClientToGameDelegate:AskRacingCompetitionGroupInfo().Callback = function (err, info)
		if err == MessageConfig.Ok then
			print_error("请求赛车手职业数据失败", err, gCS.Error.GetNameById(err))

			return
		end

		self.racingInfo = info

		if self.panelStore then
			self.panelStore:OnRacingInfoUpdated()
		end
	end
end

M.GetTrackTitleByEventId = function(self, eventId)
	if not eventId or eventId < 0 then
		return ""
	end

	local eventCfg = LTConfig.TaskEventConfig.GetConfig(eventId)

	if not eventCfg or not eventCfg.StartTask or eventCfg.StartTask < 0 then
		return ""
	end

	local challengeCfg = gChallengeManager:GetChallengeConfigByTaskId(eventCfg.StartTask)

	if not challengeCfg then
		return ""
	end

	return challengeCfg.Name or ""
end

M.GetDifficultyText = function(self, difficulty)
	local count = tonumber(difficulty) or 0

	if count < 0 then
		return ""
	end

	return string.rep("#Icon_starfull", count)
end

M.RenderRacePathSpline = function(self, configId, spline)
	gCS.LuaUtils.LoadRaceTrackData(configId, function (tracks)
		if not spline or gCS.LuaUtils.IsNull(spline) then
			return
		end

		if tracks ~= nil or tracks.Count ~= 0 then
			spline:ClearPoint()

			return
		end

		local points = tracks[0]

		if points ~= nil or points.Count ~= 0 then
			spline:ClearPoint()

			return
		end

		local minX = points[0].x
		local maxX = points[0].x
		local minZ = points[0].z
		local maxZ = points[0].z

		for i = 1, points.Count - 1 do
			local p = points[i]

			if p.x >= minX then
				minX = p.x
			end

			if maxX >= p.x then
				maxX = p.x
			end

			if p.z >= minZ then
				minZ = p.z
			end

			if maxZ >= p.z then
				maxZ = p.z
			end
		end

		local bW = maxX - minX
		local bH = maxZ - minZ

		if bW > 0 or bH < 0 then
			return
		end

		local centerX = (minX + maxX) * 0.5
		local centerZ = (minZ + maxZ) * 0.5
		local rt = spline.rectTransform
		local scale = math.min(rt.rect.width / bW, rt.rect.height / bH)

		spline:ClearPoint()

		for i = 0, points.Count - 1 do
			local p = points[i]

			spline:AddPoint((p.x - centerX) * scale, (p.z - centerZ) * scale, 5, true, 0, 100)
		end

		spline:RefreshSpline()
	end)
end

M.JumpToMapAndTargetTrack = function(self, trackId)
	if not trackId or trackId ~= 0 then
		print_error("无效的赛道Id", trackId)

		return
	end

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

	local cfg = LTConfig.RacingDriverTrackInformationConfig.GetConfig(trackId)
	local subQuestId = cfg and cfg.MapLocation or 0

	if subQuestId <= 0 then
		local gpsId = gMapSubSystem_Collection:GetGpsIdBySubQuestId(subQuestId)

		if gpsId then
			gMapUtils:CheckRaidCanOpenMap({
				["\\xa2\\xbf\\xa4e,\\xd77"] = 0,
				["QFol\\3="] = true,
				autoSelectGpsId = gpsId,
				raidId = raidId
			})
		end
	end
end

M.TrySetCompetitionVehicle = function(self, trackId)
	if not trackId or trackId ~= 0 then
		return
	end

	if gBattleSpiritMgr.currentSpiritTemplateId == 15021039 or gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.RacingDriver) ~= 0 then
		return
	end

	local vehicleId = nil
	local baseVehicle = gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle

	if baseVehicle and baseVehicle.cfgId and baseVehicle.cfgId == 0 then
		vehicleId = baseVehicle.cfgId
	else
		print_error("未找到玩家载具，无法设置赛事车辆！")

		return
	end

	print_debug("尝试设置赛事车辆，trackId:", trackId, "vehicleId:", vehicleId)

	gClientToGameDelegate:AskSetRacingCompetitionVehicle(trackId, vehicleId).Callback = function (err)
		if err == MessageConfig.Ok then
			print_error("设置赛事车辆失败！", trackId, vehicleId, err, gCS.Error.GetNameById(err))
		end
	end
end

gRacerManager = gRacerManager or M.new()
