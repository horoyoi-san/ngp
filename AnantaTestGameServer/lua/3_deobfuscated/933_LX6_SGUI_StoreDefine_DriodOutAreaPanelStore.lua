local GameConfig = LTConfig.GameConfig
C_DriodOutAreaPanelStore = DefClass("C_DriodOutAreaPanelStore", C_DriodOutAreaPanelStore, C_StoreGroup)
GroupName2Class.DriodOutAreaPanelStore = C_DriodOutAreaPanelStore
local M = C_DriodOutAreaPanelStore
local ShowType = {
	Hide = 0,
	Show = 1
}

function M:ctor()
	return
end

function M:OnAwake()
	self:InitData()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self:InitData()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:InitData()
	self.maxDistance = GameConfig.HackEnemyMoveRadius
	self.toastPopDistance = GameConfig.HackToastPopDistance
	self.showTipDistance = self.maxDistance - self.toastPopDistance
	self.maxDistanceSqr = self.maxDistance * self.maxDistance
	self.toastPopDistanceSqr = self.toastPopDistance * self.toastPopDistance
	self.showTipDistanceSqr = self.showTipDistance * self.showTipDistance
	local curControlPid = gCS.MyPlayerManager.PlayerUnit.Pid
	local allPlayers = gCS.SceneDataMgr.UnitsManager:GetPlayers()

	for i = 1, allPlayers.Count do
		local v = allPlayers[i - 1]

		if v.Pid ~= curControlPid then
			self.playerUnit = v

			break
		end
	end
end

function M:OnUpdate()
	if not self.playerUnit or not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	self:UpdateDistanceFill()
end

function M:OnClose()
	self.playerUnit = nil
end

function M:UpdateDistanceFill()
	local agentPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local playerPos = self.playerUnit.LocalPosition
	local sqrDistance = Vector3.SqrDistance(agentPos, playerPos)
	self.bindData.showWarningCtrl = self.showTipDistanceSqr <= sqrDistance and ShowType.Show or ShowType.Hide

	if self.maxDistanceSqr < sqrDistance then
		self:OutOfArea()

		return
	end

	if self.showTipDistanceSqr <= sqrDistance then
		local dis = Vector3.Distance(agentPos, playerPos)
		local fill = 1 - (dis - self.showTipDistance) / self.toastPopDistance
		self.bindData.fill1 = fill
		self.bindData.fill2 = fill
	end
end

function M:OutOfArea()
	gPanelManager:Close(gPanelId.S_DRIOD_OUT_AREA_PANEL)
end
