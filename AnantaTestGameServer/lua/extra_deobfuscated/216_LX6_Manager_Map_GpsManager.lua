require("LX6/Manager/Map/GpsConstant")

gGpsSource = {
	Task = 1,
	Other = 0
}
gGpsShowMode = {
	ShowTaskMode = 0,
	ShowMapMode = 1
}
local M = {
	gpsList = {},
	gpsGroupList = {},
	WildEnemyMapping = {},
	wayPointEffects = {},
	wayPointGroupEffects = {},
	m_CurrentShowMode = gGpsShowMode.ShowMapMode
}

function M:OnInit()
	self:InitMapWild()
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.Reconnect or switchType == gSwitchSceneType.KickToLogin then
		self:ClearAllGps()
	end
end

function M:SwitchGpsShowMode(mode)
	if self.m_CurrentShowMode == mode then
		return
	end

	self.m_CurrentShowMode = mode

	if self.m_CurrentShowMode == gGpsShowMode.ShowTaskMode then
		self:TryRemoveNowMapGuide()
	end

	gMessageManager:SendMessage(gEventConstants.SWITCH_GPS_SHOW_MODE, self.m_CurrentShowMode)
end

function M:HudIsShowTaskMode()
	return self.m_CurrentShowMode == gGpsShowMode.ShowTaskMode
end

function M:GetGpsShowMode()
	return self.m_CurrentShowMode
end

function M:AddGPS(data, ignoreConflict)
	if not data then
		return
	end

	if type(data) ~= "table" then
		data = data:ToTable()
	end

	if table.isNilOrEmpty(data) then
		return
	end

	local gpsInfoData = table.clone(data)
	local gpsType = data.GpsType

	if self.gpsList[gpsType] then
		if self.gpsList[gpsType].InstanceId == gpsInfoData.InstanceId then
			gMessageManager:SendMessage(gEventConstants.UPDATE_GPS, gpsInfoData)

			return
		else
			self:RemoveGPS(self.gpsList[gpsType])
		end
	end

	self.gpsList[gpsType] = gpsInfoData

	gMessageManager:SendMessage(gEventConstants.Add_GPS, gpsInfoData)
end

function M:RemoveGPS(data)
	if not data then
		return
	end

	if type(data) ~= "table" then
		data = data:ToTable()
	end

	if table.isNilOrEmpty(data) then
		return
	end

	local gpsType = data.GpsType
	local instanceId = data.InstanceId

	self:RemoveGPSById(instanceId, gpsType)
end

function M:RemoveGPSById(instanceId, gpsType)
	if instanceId and instanceId == gMapSystem.trace.mainTraceGpsId then
		gMapSystem.trace:SetMainTraceGpsId(nil)
	end

	self.gpsList[gpsType] = nil

	gMessageManager:SendMessage(gEventConstants.REMOVE_GPS, {
		instanceId = instanceId,
		GpsType = gpsType
	})
end

function M:AddFeiSuoGps(data)
	local gpsType = data.GpsType

	if gpsType == gTaskGpsType.SpaceThrow or gpsType == gTaskGpsType.FeiSuo or gpsType == gTaskGpsType.WallUpOverJump or gpsType == gTaskGpsType.CoiledJumpPos or gpsType == gTaskGpsType.FeiSouCrouchAttack then
		if self.gpsList[gpsType] == nil then
			self:AddGPS(data)
		else
			self.gpsList[gpsType] = data

			gMessageManager:SendMessage(gEventConstants.UPDATE_FEISUO_GPS, data)
		end
	elseif gpsType == gTaskGpsType.TaskPlayFeiSuo then
		self.gpsList[gpsType] = data

		gMessageManager:SendMessage(gEventConstants.UPDATE_FEISUO_GPS, data)
	end
end

function M:ClearAllGps()
	self.gpsList = {}

	gMapSystem.trace:SetMainTraceGpsId(nil)
end

function M:InitMapWild()
	for i = 0, LTConfig.RefreshEnemyConfig.count - 1 do
		local cfg = LTConfig.RefreshEnemyConfig.LoadAt(i)
		local id = cfg.Id
		local enemyId = cfg.EnemyId
		self.WildEnemyMapping[enemyId] = id
	end
end

function M:TryRemoveMapGuideById(gpsId)
	gMapSystem.trace:TryRemoveMainTraceByGpsId(gpsId)
end

function M:TryRemoveMapGuideByEnemyId(id)
	local wildEnemyGpsId = self.WildEnemyMapping[id]

	if wildEnemyGpsId and gMapSystem.trace.mainTraceGpsId == wildEnemyGpsId then
		self:RemoveGPSById(wildEnemyGpsId, gTaskGpsType.Trace)
	end
end

function M:TryRemoveNowMapGuide()
	gMapSystem.trace:RemoveMainTrace()
end

local feisuoAttackAddGps = {
	InstanceId = 888888,
	UnitPid = 0,
	TargetPos = Vector3.zero,
	GpsType = gTaskGpsType.FeiSouAttack
}
local removeGps = {
	InstanceId = 888888,
	GpsType = gTaskGpsType.FeiSouAttack
}

function M:AddFeiSuoAttackGPS(pid)
	feisuoAttackAddGps.UnitPid = pid

	gGpsManager:AddGPS(feisuoAttackAddGps)
end

function M:RemoveFeiSuoAttackGPS()
	gGpsManager:RemoveGPS(removeGps)
end

gGpsManager = M
