-- Original chunk: @Lua\LuaGen\HurtStiff\HurtStiffData.lua
-- Decompiled from: 00682_HurtStiffData.lua_c917daac9e65.luajit

if not gHurtStiffData then
	local M = {
		HitFourDirType = {
			["\\xa7\\xa5\\xa7\\xa2"] = 3,
			["X#~P"] = 1,
			["V'{O"] = 2,
			["k\\xbc\\xad\\xa1\\xa2"] = 0
		}
	}
end

M.ClearGameData = function(self)
	self.HurtId = 0
	self.AttackerPid = 0
	self.HurterPid = 0
	self.HitPosition = nil
	self.SkillId = 0
	self.SkillIndex = 0
	self.IsBackStruck = false
	self.HitFourDir = M.HitFourDirType.Front
	self.IsHurterStiffDown = false
	self.HorizontalForce = 0
	self.VerticalForce = 0
	self.LeftOrRightHit = 0
	self.IsUnbalance = false
	self.ToughnessCutValue = 0
	self.ToughnessExpectCutValue = 0
	self.HitDirection = nil
	self.HitDirType = nil
	self.IsHitTurn = false
	self.IsHeadShield = false
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType then
		self.ClearGameData(self)
	end
end

gHurtStiffData = M

return M
