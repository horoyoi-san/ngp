-- Original chunk: @Lua\LuaFiles\LX6\Battle\ShootManager.lua
-- Decompiled from: 00079_ShootManager.lua_6b2fb9e9fe6f.luajit

local M = gShootManager or {}

M.OnInit = function(self)
	self.spoonControlCrossHair = false
	self.spoonCrossHairTargetState = false
end

M.CheckUseShootSkill = function(self)
	local store = gStoreManager:GetStoreGroup("CoreHudDriveBattleStore")

	if not store or not store.mouseLeftBtnDown then
		return false
	end

	return true
end

M.OnRefreshFire = function(self)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:OnRefreshFire()
end

M.OnCrossHairModuleChanged = function(self, crossHairCfgId)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:OnCrossHairModuleChanged(crossHairCfgId)
end

M.PlayCrossHairHit = function(self, hitMarkType)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:PlayCrossHairHit(hitMarkType)
end

M.ResetCrossHairFriendlyFireStatus = function(self, crossHairAimType)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:ResetCrossHairFriendlyFireStatus(crossHairAimType)
end

M.PressFireBtn = function(self)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:OnRefreshFire()
end

M.RefreshHp = function(self)
	gMessageManager:SendMessage(gEventConstants.FORCE_REFRESH_PLAYER_HP_HUD)
end

M.RefreshHoldWeaponCrossHair = function(self)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:RefreshHoldWeaponCrossHair()
end

M.EnterShoujinState = function(self, isOp)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:PlayCrossHairFireAni(isOp)
end

M.ShowCameraArea = function(self, enable, width, height)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:ShowCameraArea(enable, width, height)
end

M.RefreshShootCamZoomUI = function(self, enable)
	local store = gStoreManager:GetStoreGroup("CoreHudShootStore")

	store:RefreshCamZoomActive(enable)
end

M.DriveShootAimBtnDown = function(self, down)
	local store = gStoreManager:GetStoreGroup("CoreHudDriveBattleStore")

	store:SetRightBtnStatus(down)
end

gShootManager = M
