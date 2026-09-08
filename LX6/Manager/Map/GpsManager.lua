-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\GpsManager.lua
-- Decompiled from: 00219_GpsManager.lua_76b203cd9918.luajit

require("LX6/Manager/Map/GpsConstant")

gGpsSource = {
	["N#nP"] = 1,
	["b\\xba\\xaa\\xaa\\xa4"] = 0
}
gGpsShowMode = {
	["\\~\\xa3`x\\xb3\\xe1LGuzI"] = 0,
	["\\xac</(U\\x9cQ\\xf48\\xae\\xbc"] = 1
}
local M = {
	gpsList = {},
	gpsGroupList = {},
	WildEnemyMapping = {},
	wayPointEffects = {},
	wayPointGroupEffects = {},
	m_CurrentShowMode = gGpsShowMode.ShowMapMode
}

M.OnInit = function(self)
	self.InitMapWild(self)
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.ClearAllGps(self)
	end
end

M.SwitchGpsShowMode = function(self, mode, checkTaskRelateTrace)
	local modeChanged = self.m_CurrentShowMode == mode
	self.m_CurrentShowMode = mode

	if checkTaskRelateTrace == false and self.m_CurrentShowMode ~= gGpsShowMode.ShowTaskMode and not gMapSystem.trace:IsTaskRelateTrace(gMapSystem.trace.mainTraceGpsId) then
		gMapSystem.trace:RemoveMainTrace()
	end

	if not modeChanged then
		return
	end

	gMessageManager:SendMessage(gEventConstants.SWITCH_GPS_SHOW_MODE, self.m_CurrentShowMode)
end

M.TaskTrySwitchGpsShowMode = function(self, checkTaskRelateTrace)
	self.SwitchGpsShowMode(self, gGpsShowMode.ShowTaskMode, checkTaskRelateTrace)
end

M.HudIsShowTaskMode = function(self)
	return self.m_CurrentShowMode ~= gGpsShowMode.ShowTaskMode
end

M.AddGPS = function(self, data, ignoreConflict)
	if not data then
		return
	end

	if type(data) == "table" then
		data = data.ToTable(data)
	end

	if table.isNilOrEmpty(data) then
		return
	end

	local gpsInfoData = table.clone(data)
	local gpsType = data.GpsType

	if self.gpsList[gpsType] and self.gpsList[gpsType].InstanceId == gpsInfoData.InstanceId then
		self.RemoveGPS(self, self.gpsList[gpsType])

		self.gpsList[gpsType] = gpsInfoData
	end

	if gMapSubSystem_LegacyGps then
		gMapSubSystem_LegacyGps:AddGps(gpsInfoData)
	end
end

M.RemoveGPS = function(self, data)
	if not data then
		return
	end

	if type(data) == "table" then
		data = data.ToTable(data)
	end

	if table.isNilOrEmpty(data) then
		return
	end

	local gpsType = data.GpsType
	local instanceId = data.InstanceId

	self.RemoveGPSById(self, instanceId, gpsType)
end

M.RemoveGPSById = function(self, instanceId, gpsType)
	if instanceId and instanceId ~= gMapSystem.trace.mainTraceGpsId then
		gMapSystem.trace:SetMainTraceGpsId(nil)
	end

	self.gpsList[gpsType] = nil

	gMessageManager:SendMessage(gEventConstants.REMOVE_GPS, {
		instanceId = instanceId,
		GpsType = gpsType
	})
end

M.ClearAllGps = function(self)
	self.gpsList = {}

	gMapSystem.trace:SetMainTraceGpsId(nil)
end

M.InitMapWild = function(self)
end

M.TryRemoveMapGuideById = function(self, gpsId)
	gMapSystem.trace:TryRemoveMainTraceByGpsId(gpsId)
end

M.TryRemoveMapGuideByEnemyId = function(self, id)
	local wildEnemyGpsId = self.WildEnemyMapping[id]

	if wildEnemyGpsId and gMapSystem.trace.mainTraceGpsId ~= wildEnemyGpsId then
		self.RemoveGPSById(self, wildEnemyGpsId, gTaskGpsType.Trace)
	end
end

M.TryRemoveNowMapGuide = function(self)
	gMapSystem.trace:RemoveMainTrace()
end

local feisuoAttackAddGps = {
	["zTݩ\\x85\\xbb\\xe0\\xec"] = 888888,
	["\\xec\\xd5\t.-\\xf5"] = 0,
	TargetPos = Vector3.zero,
	GpsType = gTaskGpsType.FeiSouAttack
}
local removeGps = {
	["zTݩ\\x85\\xbb\\xe0\\xec"] = 888888,
	GpsType = gTaskGpsType.FeiSouAttack
}

M.AddFeiSuoAttackGPS = function(self, pid)
	feisuoAttackAddGps.UnitPid = pid

	gMessageManager:SendMessage(gEventConstants.ADD_SCENE_HINT, feisuoAttackAddGps)
end

M.RemoveFeiSuoAttackGPS = function(self)
	gMessageManager:SendMessage(gEventConstants.REMOVE_SCENE_HINT, removeGps)
end

gGpsManager = M
