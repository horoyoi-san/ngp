local M = gFeisuoUIUpdateMgr or {}
M.HideUI = false
M.feisuoPos = Vector3.zero
local addGps = {
	feisuoIndex = 1,
	sourceFeiSuoType = 1,
	InstanceId = 999999,
	hasAnotherEnemy = false,
	TargetPos = Vector3.zero,
	GpsType = gTaskGpsType.FeiSuo,
	anotherEnemyPos = Vector3.zero
}
M.selectFeisuoInfo = {
	pointCanMove = false,
	select = false,
	pos = {
		z = 0,
		x = 0,
		y = 0
	}
}

function M:GetIsFindFeisuoPoint()
	return self.selectFeisuoInfo.select
end

function M:GetSelectFeisuoInfo()
	local ok = false
	local pointCanMove = false
	ok, self.feisuoPos.x, self.feisuoPos.y, self.feisuoPos.z, pointCanMove = gCS.ClimbBuildManager.CameraGetFeiSuoPosFast(0, 0, 0, false)

	if ok then
		return self.feisuoPos, pointCanMove
	end

	return nil
end

function M:CSShowGps(x, y, z, pointCanMove)
	self.selectFeisuoInfo.select = true
	self.selectFeisuoInfo.pos.z = z
	self.selectFeisuoInfo.pos.y = y
	self.selectFeisuoInfo.pos.x = x
	self.selectFeisuoInfo.pointCanMove = pointCanMove

	addGps.TargetPos:Set(x, y, z)

	gFeisuoAssassMgr.InteractionInfo.CanInteract = true

	self:UpdateFeisuoGps(addGps)
end

function M:UpdateFeisuoGps(needAddGps)
	needAddGps.ForceHide = false

	gMapSubSystem_NearByMisc:AddCommonFeisuo(addGps.TargetPos.x, addGps.TargetPos.y, addGps.TargetPos.z)

	if not self.hasAddGps then
		self.hasAddGps = true

		gBattleMgr:OnRefreshFeiSuo()
		gMessageManager:SendMessage(gEventConstants.FEISUO_GPS_EXIST_CHANGE, true)
	end
end

function M:RemoveFeisuoGps()
	if self.hasAddGps then
		self.hasAddGps = false
		self.selectFeisuoInfo.select = false
		addGps.ForceHide = true

		gMapSubSystem_NearByMisc:RemoveCommonFeisuo()

		gFeisuoAssassMgr.InteractionInfo.CanInteract = false

		gMessageManager:SendMessage(gEventConstants.FEISUO_GPS_EXIST_CHANGE, false)
	end
end

gFeisuoUIUpdateMgr = M

return gFeisuoUIUpdateMgr
