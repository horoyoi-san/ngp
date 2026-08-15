local DataSet = require("LX6/DataBind/DataSet")
local HackingConfig = LTConfig.HackingConfig
local M = gFeisuoAssassMgr or {}
M.InteractionInfo = DataSet.New({
	CanInteract = false,
	LockEnemyId = 0,
	feisuoType = -1
})

function M:IsFeiSuoBattleCrouch()
	if ulong.Greater(self.InteractionInfo.LockEnemyId, 0) then
		return true
	end

	return false
end

function M:SetCanFeiSuoCrouchAss(canAssassin, LockEnemyId, target1, target2)
	self.canAssassin = canAssassin
	self.InteractionInfo.LockEnemyId = LockEnemyId
	self.feisuoCrouchAssTarget1 = target1
	self.feisuoCrouchAssTarget2 = target2

	gMainMenuMgr:SetCanAssassinate(canAssassin)
	self:UpdateAssinateGps()
end

function M:UpdateAssinateGps()
	local show = false

	if self.InteractionInfo then
		local configId = HackingConfig.PaokuFly

		if self:IsFeiSuoBattleCrouch() and not gCS.BattleManager.IsAnyEnemyLockMe() then
			configId = HackingConfig.FeiSuoEnemyCrouch
		else
			configId = nil
		end

		show = configId ~= nil
	end

	if show then
		gHackManager:AddFocusDangerEffect(self.feisuoCrouchAssTarget1, self.feisuoCrouchAssTarget2)
	else
		gHackManager:ClearDangerEffectData()
	end

	gMainMenuMgr:SetCanUseAssassinate(show)
end

gFeisuoAssassMgr = M

return gFeisuoAssassMgr
