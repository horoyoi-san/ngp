local M = gPauseManager or {
	showPauseTip = false,
	pauseSpeed = 1,
	isBreak = false,
	isMultiplayer = false,
	enable = true
}

function M:OnInit()
	if gCS.LuaUtils.CheckCurrentToolkitsTypeIsProgrammer() then
		self.showPauseTip = true
	end

	if UnityEngine.PlayerPrefs.HasKey("SHOW_PAUSE_TIP_BY_PAUSE") then
		self.showPauseTip = UnityEngine.PlayerPrefs.GetInt("SHOW_PAUSE_TIP_BY_PAUSE", 0) == 1
	end
end

function M:CheckEnablePause()
	if gLuaDataManager.needSyncActionDatas or gLuaDataManager.needSyncEffect or self.isMultiplayer then
		return false
	end

	return true
end

function M:StartGamePlayPause_CustomData_ChangeOthersTimeSpeed(timeScale)
	gCS.PauseManager.Instance:SetTafeiDrivePause(timeScale)
end

function M:EndGamePlayPause_CustomData_ChangeOthersTimeSpeed()
	gCS.PauseManager.Instance:RemoveTafeiDrivePause()
end

function M:SyncPauseSpeed(speed)
	self.isBreak = speed == 0
	self.pauseSpeed = speed

	gCS.LuaUtils.SetForbidCheckSwitchAction(self.isBreak)
end

gPauseManager = M
