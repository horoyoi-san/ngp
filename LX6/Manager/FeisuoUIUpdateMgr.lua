-- Original chunk: @Lua\LuaFiles\LX6\Manager\FeisuoUIUpdateMgr.lua
-- Decompiled from: 00355_FeisuoUIUpdateMgr.lua_95f4e0e3f288.luajit

local M = gFeisuoUIUpdateMgr or {}
M.HideUI = false
M.feisuoPos = Vector3.zero
local addGps = {
	["\\x991),m\\x92h\\xd73\\xaf\\xa1"] = 1,
	["t\\x8f\\x82\\xbcٖ\\xc02\\x9a*\\x86&"] = 1,
	["zTݩ\\x85\\xbb\\xe0\\xec"] = 999999,
	["++3\\xc5}\\x97\\xe3<\\xad=\\xc3\\xfc\\xe3y\\xe2"] = false,
	TargetPos = Vector3.zero,
	GpsType = gTaskGpsType.FeiSuo,
	anotherEnemyPos = Vector3.zero
}
M.selectFeisuoInfo = {
	["y\\xa5yX\\x91\\xf3IGuhI"] = false,
	["M\\x9d\\x8b\\x80U"] = false,
	pos = {
		["\\xd7"] = 0,
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
}

M.GetIsFindFeisuoPoint = function(self)
	return self.selectFeisuoInfo.select
end

M.CSShowGps = function(self, x, y, z, pointCanMove)
	self.selectFeisuoInfo.select = true
	self.selectFeisuoInfo.pos.z = z
	self.selectFeisuoInfo.pos.y = y
	self.selectFeisuoInfo.pos.x = x
	self.selectFeisuoInfo.pointCanMove = pointCanMove

	addGps.TargetPos:Set(x, y, z)

	gFeisuoAssassMgr.InteractionInfo.CanInteract = true

	self:UpdateFeisuoGps(addGps)
end

M.UpdateFeisuoGps = function(self, needAddGps)
	needAddGps.ForceHide = false

	gMapSubSystem_NearByMisc:AddCommonFeisuo(addGps.TargetPos.x, addGps.TargetPos.y, addGps.TargetPos.z)

	if not self.hasAddGps then
		self.hasAddGps = true

		gBattleMgr:OnRefreshFeiSuo()
		gMessageManager:SendMessage(gEventConstants.FEISUO_GPS_EXIST_CHANGE, true)
	end
end

M.RemoveFeisuoGps = function(self)
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
