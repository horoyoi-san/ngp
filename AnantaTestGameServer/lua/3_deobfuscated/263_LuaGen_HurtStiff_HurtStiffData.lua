if not gHurtStiffData then
	local M = {
		HitFourDirType = {
			Right = 3,
			Back = 1,
			Left = 2,
			Front = 0
		}
	}
end

function M:ClearGameData()
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

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		self:ClearGameData()
	end
end

gHurtStiffData = M

return M
