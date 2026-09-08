-- Original chunk: @Lua\LuaFiles\LX6\Manager\UnitOperateManager.lua
-- Decompiled from: 00570_UnitOperateManager.lua_a3f98e222163.luajit

local M = {
	["\\x96'\n*u\\x8dj\\xdc.\\x9f\\xa9"] = false,
	["n\\xb5\\x9e\\x95ө\\xd6/\\xa0<\\x9f\r "] = false,
	["\\xb8\\xa6\\xa5m\\xff$"] = 0,
	["\\xf0u9\\xc07\\xb3X\\x85Y\\xa7\\xb8"] = false,
	["Ή;\\xf9\\xd5\\xe3\\x86\\xea\\xa7.,"] = false,
	[")%9\\xd7g\\x91\\xf4?\\x98*\\xf4\\xf1\\xe3z\\xef"] = 0,
	["\\x96'\n*u\\x8dr\\xce>\\xa4\\xbe"] = false,
	["n\\xbb?\\xf0W\\xa8~\t2)z\\x80\\xf0\"\\xd5\\xe2"] = false,
	["*9\r\\xe5t\\x96\\xf2 \\x83*\\xff\\xd6\\xe9c\\xf5"] = false,
	[")\\xa0\\xff\\xae\\xb4\\xfb\\xaf\\xb4\\x8f\\xf7\\xf7?־/\\x88\\xec"] = false,
	["PPegI2,"] = false,
	["\\x88:\\xe0\\xacx-\\xdf\\xdf\\xe0VN\\xde\\xb5\\xc6"] = 0
}

M.ResetParam = function(self)
	self.joyStickPercent = 0
	self.jumpKeyDownStartTime = 0

	if self.isJumpKeyDown then
		gCS.TransitionMgr.isJumpKeyDown = false
	end

	self.isJumpKeyDown = false
	self.isPressingJumpDown = false

	if self.isJumpKeyUp then
		gCS.TransitionMgr.isJumpKeyUp = false
	end

	self.isJumpKeyUp = false
	self.swingYaw = 0
	self.swingLeft = false
	self.isJumpSwing = false
	self.IsJumpSwingEnd = false
	self.swingNeedCheckAngle = false
	self.isMagnetKeyDown = false

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.JumpModuleMgr.JumpKeyUp(gCS.MyPlayerManager.PlayerUnit)
	end

	gCS.TransitionMgr.isMagnetKeyDown = false
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType then
		self.ResetParam(self)
	end
end

M.SetIsMagnetKeyDownFromCS = function(self, enable)
	self.isMagnetKeyDown = enable
end

gUnitOperateManager = M
