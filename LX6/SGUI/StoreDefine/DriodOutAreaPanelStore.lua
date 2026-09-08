-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DriodOutAreaPanelStore.lua
-- Decompiled from: 01890_DriodOutAreaPanelStore.lua_c868aa7e1abe.luajit

local GameConfig = LTConfig.GameConfig
C_DriodOutAreaPanelStore = DefClass("C_DriodOutAreaPanelStore", C_DriodOutAreaPanelStore, C_StoreGroup)
GroupName2Class.DriodOutAreaPanelStore = C_DriodOutAreaPanelStore
local M = C_DriodOutAreaPanelStore
local MapBoundaryDistance = 10000
local AgentConfig = LTConfig.AgentConfig
local ShowType = {
	["R+y^"] = 0,
	["I*rL"] = 1
}
local _enumeratingPlayers = {}

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.ON_REFRESH_MAP_DISTANCE] = self.CreateAction(self, self.RefreshMapDistance)
	}
end

M.OnAwake = function(self)
	self.InitData(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.InitData(self, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.InitData = function(self, distance)
	self.boundaryDistance = distance and distance or MapBoundaryDistance
	local agentConfigId = gCS.MyPlayerManager.PlayerUnit.TemplateId
	local agentConfig = AgentConfig.GetConfig(agentConfigId)
	self.maxDistanceXZ = agentConfig and agentConfig.SummonMoveRange.Radius or GameConfig.HackEnemyMoveRadius
	self.maxDistanceY = agentConfig and agentConfig.SummonMoveRange.YRange or GameConfig.HackEnemyMoveRadiusY
	self.toastPopDistance = GameConfig.HackToastPopDistance
	self.showTipDistanceXZ = self.maxDistanceXZ - self.toastPopDistance
	self.showTipDistanceY = self.maxDistanceY - self.toastPopDistance
	self.maxDistanceXZSqr = self.maxDistanceXZ * self.maxDistanceXZ
	self.maxDistanceYSqr = self.maxDistanceY * self.maxDistanceY
	self.showTipDistanceXZSqr = self.showTipDistanceXZ * self.showTipDistanceXZ
	self.showTipDistanceYSqr = self.showTipDistanceY * self.showTipDistanceY
	self.toastPopDistanceSqr = self.toastPopDistance * self.toastPopDistance
	self.checkWarnDistance = GameConfig.BoundaryStartAlertDistance
	self.checkReturnDistance = GameConfig.BoundaryStartReturnDistance
	self.mapToastPopDistance = GameConfig.BoundaryStartAlertDistance - GameConfig.BoundaryStartReturnDistance
	local curControlPid = gCS.MyPlayerManager.PlayerUnit.Pid

	table.clear(_enumeratingPlayers)
	gCS.SceneDataMgr.UnitsManager:LuaGetAllPlayers(_enumeratingPlayers)

	for _, v in ipairs(_enumeratingPlayers) do
		if v.Pid == curControlPid then
			self.playerUnit = v

			break
		end
	end

	table.clear(_enumeratingPlayers)
end

M.OnUpdate = function(self)
	if not self.playerUnit or not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	self.UpdateDistanceFill(self)
end

M.RefreshMapDistance = function(self, _, distance)
	self.boundaryDistance = distance and distance or MapBoundaryDistance
end

M.OnClose = function(self)
	self.playerUnit = nil
	self.boundaryDistance = MapBoundaryDistance
end

M.CheckIsShowTip = function(self, sqrDistanceXZ, sqrDistanceY)
	return self.showTipDistanceXZSqr > sqrDistanceXZ or self.showTipDistanceYSqr > sqrDistanceY or self.boundaryDistance > self.checkWarnDistance
end

M.CheckISOutOfArea = function(self, sqrDistanceXZ, sqrDistanceY)
	return self.maxDistanceXZSqr <= sqrDistanceXZ or self.maxDistanceYSqr <= sqrDistanceY or self.boundaryDistance > self.checkReturnDistance
end

M.CalShowTipFill = function(self, distanceXZ, distanceY)
	local fillXZ = 1 - (distanceXZ - self.showTipDistanceXZ) / self.toastPopDistance
	local fillY = 1 - (distanceY - self.showTipDistanceY) / self.toastPopDistance
	local fillMap = (self.boundaryDistance - self.checkReturnDistance) / self.mapToastPopDistance

	return math.min(fillXZ, fillY, fillMap)
end

M.CalPlayerToAgentDistance = function(self, agentPos, playerPos)
	local agentPosXZ = Vector3.New(agentPos.x, 0, agentPos.z)
	local playerPosXZ = Vector3.New(playerPos.x, 0, playerPos.z)
	local sqrDistanceXZ = Vector3.SqrDistance(agentPosXZ, playerPosXZ)
	local distanceXZ = Vector3.Distance(agentPosXZ, playerPosXZ)
	local agentY = agentPos.y or 0
	local playerY = playerPos.y or 0
	local sqrDistanceY = (agentY - playerY)^2
	local distanceY = math.abs(agentY - playerY)

	return sqrDistanceXZ, distanceXZ, sqrDistanceY, distanceY
end

M.UpdateDistanceFill = function(self)
	if not self.playerUnit then
		self.OutOfArea(self)

		return
	end

	local agentPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local playerPos = self.playerUnit.LocalPosition
	local sqrDistanceXZ, distanceXZ, sqrDistanceY, distanceY = self:CalPlayerToAgentDistance(agentPos, playerPos)
	self.bindData.showWarningCtrl = self:CheckIsShowTip(sqrDistanceXZ, sqrDistanceY) and ShowType.Show or ShowType.Hide

	if self:CheckISOutOfArea(sqrDistanceXZ, sqrDistanceY) then
		self.OutOfArea(self)

		return
	end

	if self.CheckIsShowTip(self, sqrDistanceXZ, sqrDistanceY) then
		local fill = self.CalShowTipFill(self, distanceXZ, distanceY)
		self.bindData.fill1 = fill
		self.bindData.fill2 = fill
	end
end

M.OutOfArea = function(self)
	gPanelManager:Close(gPanelId.S_DRIOD_OUT_AREA_PANEL)
end
