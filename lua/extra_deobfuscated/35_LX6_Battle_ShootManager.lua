local M = gShootManager or {}

function M:OnInit()
	self.spoonControlCrossHair = false
	self.spoonCrossHairTargetState = false
end

function M:CheckUseShootSkill()
	local store = gStoreManager:GetStoreGroup("CoreHudDriveBattleStore")

	if not store or not store.mouseLeftBtnDown then
		return false
	end

	return true
end

function M:OnRefreshFire()
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:OnRefreshFire()
end

function M:OnCrossHairModuleChanged(crossHairCfgId)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:OnCrossHairModuleChanged(crossHairCfgId)
end

function M:PlayCrossHairHit(killed, isWeak)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:PlayCrossHairHit(killed, isWeak)
end

function M:ResetCrossHairFriendlyFireStatus(isFriendlyFire)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:ResetCrossHairFriendlyFireStatus(isFriendlyFire)
end

function M:PressFireBtn()
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:OnRefreshFire()
end

function M:RefreshHp()
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterPartStore")

	store:OnRefreshHp()
end

function M:RefreshHoldWeaponCrossHair()
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:RefreshHoldWeaponCrossHair()
end

function M:EnterShoujinState(isOp)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:PlayCrossHairFireAni(isOp)
end

function M:ShowCameraArea(enable, width, height)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:ShowCameraArea(enable, width, height)
end

function M:RefreshShootCamZoomUI(enable)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:RefreshCamZoomActive(enable)
end

function M:DriveShootAimBtnDown(down)
	local store = gStoreManager:GetStoreGroup("CoreHudDriveBattleStore")

	store:SetRightBtnStatus(down)
end

gShootManager = M
