-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerMainData.lua
-- Decompiled from: 00090_PlayerMainData.lua_8636a403d29d.luajit

C_PlayerMainData = DefClass("C_PlayerMainData", C_PlayerMainData, C_PlayerDataBase)
local M = C_PlayerMainData

M.DefineBindEvents = function(self)
	self.BindEventHandler = {
		isInRush = function (cell)
			local value = cell.value

			gMessageManager:SendMessage(gEventConstants.RUSH_STATE_CHANGE, value)
		end
	}
end

M.OnInit = function(self)
	local t = self.DataSet_Template
	t.isInFightState = false
	t.anotherWorldActivity = false
	t.isInClimbing = false
	t.isInFeisuo = false
	t.isFeiSuoCrouch = false
	t.isInZipLine = false
	t.isInSlideRail = false
	t.isInRush = false
	t.isInVehicleShoot = false
	t.isInCannonShoot = false
	t.isInWash = false
	t.isFreeClimbing = false
	t.isSwing = false
	t.isInLift = false
	t.isCanEnterBaiDangState = false
	t.slipSpeed = 1
	t.slipXZSpeed = 5
	t.loginRolePid = nil
	t.actionMovementState = 0
	t.isInMagnetHold = false
	t.isInShootingMode = false
	t.isInSkillQTE = false
	t.isInHoldEnemy = false
	t.hasMindPowerTarget = false
	t.isMindPowerStaticActive = false
	t.canUseMindPower = false
	t.hasForceRebornDestructible = false
	t.banShootBthInHoldState = false
	t.curCrossHairType = 0

	self.bindData:RefreshData(t)
end

M.OnLogOut = function(self)
	self.OnInit(self)
end
