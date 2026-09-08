-- Original chunk: @Lua\LuaFiles\LX6\Manager\PauseManager.lua
-- Decompiled from: 00272_PauseManager.lua_b711a933095a.luajit

local M = gPauseManager or {
	["|~\\xa3`|\\xb3\\xe7ToNw\\"] = false,
	["C[ۮ\\x81;\\xa8\\xcc\\xec"] = 1,
	["\\xd0\\xc86%\\xfa"] = false,
	["\\xf0r9\\xc4\\xa6M\\xa0O\\xb5\\xa4"] = false,
	["F\\x90\\x8c\\x8fD"] = true
}

M.OnInit = function(self)
	if gCS.LuaUtils.CheckCurrentToolkitsTypeIsProgrammer() then
		self.showPauseTip = true
	end

	if UnityEngine.PlayerPrefs.HasKey("SHOW_PAUSE_TIP_BY_PAUSE") then
		self.showPauseTip = UnityEngine.PlayerPrefs.GetInt("SHOW_PAUSE_TIP_BY_PAUSE", 0) ~= 1
	end
end

M.CheckEnablePause = function(self)
	if gLuaDataManager.needSyncActionDatas or gLuaDataManager.needSyncEffect or self.isMultiplayer then
		return false
	end

	return true
end

M.StartGamePlayPause_CustomData_ChangeOthersTimeSpeed = function(self, timeScale)
	gCS.PauseManager.Instance:SetTafeiDrivePause(timeScale)
end

M.EndGamePlayPause_CustomData_ChangeOthersTimeSpeed = function(self)
	gCS.PauseManager.Instance:RemoveTafeiDrivePause()
end

M.SyncPauseSpeed = function(self, speed)
	self.isBreak = speed ~= 0
	self.pauseSpeed = speed

	gCS.LuaUtils.SetForbidCheckSwitchAction(self.isBreak)
end

gPauseManager = M
