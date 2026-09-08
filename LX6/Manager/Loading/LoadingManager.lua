-- Original chunk: @Lua\LuaFiles\LX6\Manager\Loading\LoadingManager.lua
-- Decompiled from: 00547_LoadingManager.lua_f66614f8b7de.luajit

C_LoadingManager = DefClass("C_LoadingManager", C_LoadingManager)
local M = C_LoadingManager

M.SetLoadingPanel = function(self, loadingPanel)
	self.loadingPanel = loadingPanel
end

M.GetSwitcherVal = function(self, index)
	return LX6.GUI.LoadingManager.GetSwitcherVal(index)
end

M.AskTeleport = function(self, configId, preTeleportOption, askTeleportExtParams, rpcFunc)
	local l50Game = L50.L50App.L50Game

	if l50Game then
		l50Game.LoadingManager:AskTeleport(configId, preTeleportOption, askTeleportExtParams, rpcFunc)
	end
end

M.StopLoading = function(self, loadingInfoIndex)
	local l50Game = L50.L50App.L50Game

	if l50Game then
		l50Game.LoadingManager:StopLoading(loadingInfoIndex)
	end
end

M.StopWaitLoading = function(self, loadingInfoIndex)
	local l50Game = L50.L50App.L50Game

	if l50Game then
		l50Game.LoadingManager:StopWaitLoading(loadingInfoIndex)
	end
end

M.CancelPreCover = function(self)
	local l50Game = L50.L50App.L50Game

	if l50Game then
		l50Game.LoadingManager:CancelPreCover()
	end
end

M.RefreshDataOpenLoadingFinish = function(self, loadingTextId)
	local l50Game = L50.L50App.L50Game

	if l50Game then
		l50Game.LoadingManager:RefreshDataOpenLoadingFinish(loadingTextId)
	end
end

M.PreShowLoading = function(self)
	gCS.LoadingPanelManager:PreShowLoading()
end

M.PreShowLoading_SameImage = function(self)
	gCS.LoadingPanelManager:PreShowLoading_SameImage()
end

M.SwitchTeleport_BeginShow = function(self, fightSpiritId)
	L50.L50App.L50Game.SwitchTeleportManager:SwitchTeleportBeginShow(fightSpiritId)
end

M.SwitchTeleport_CloseUpPrepare = function(self)
	L50.L50App.L50Game.SwitchTeleportManager:OnSyncCloseUpAgentPrepare()
end

M.SwitchTeleport_CloseUpSync = function(self)
	L50.L50App.L50Game.SwitchTeleportManager:OnSyncCloseUpAgent()
end

M.SwitchTeleport_TryOpenBlur = function(self)
	L50.L50App.L50Game.SwitchTeleportManager:TryOpenBlurInPlayingShow()
end

M.SwitchTeleport_TryCloseBlur = function(self)
	L50.L50App.L50Game.SwitchTeleportManager:TryCloseBlurInPlayingShow()
end

M.OnSyncPlayerCurrentSpirit = function(self)
	L50.L50App.L50Game.SwitchTeleportManager:OnSyncPlayerCurrentSpirit()
end

M.SwitchTeleport_CheckIsLoading = function(self)
	local l50Game = L50.L50App.L50Game

	if l50Game then
		return l50Game.SwitchTeleportManager:CheckIsLoading()
	end

	return false
end

M.CheckSwitchTeleport = function(self, fightSpiritId)
	L50.L50App.L50Game.LoadingManager:CheckSwitchTeleport(fightSpiritId)
end

M.Quick_ViewFocusChange_Robot = function(self, summonType, callback)
	local params = self:Create_ViewFocusChangeParams()
	params.viewFocusChangeType = LX6.GUI.ViewFocusChangeType.Robot
	params.summonType = summonType
	params.endCallback = callback

	self:Quick_ViewFocusChange(params)
end

M.Quick_ViewFocusChange = function(self, viewFocusChangeParams)
	return L50.L50App.L50Game.LoadingManager:Quick_ViewFocusChange(viewFocusChangeParams)
end

M.Create_ViewFocusChangeParams = function(self)
	return L50.L50App.L50Game.LoadingManager:Create_ViewFocusChangeParams()
end

M.SetLoadingProgress = function(self, val)
	if self.loadingPanel then
		self.loadingPanel:SetProgressLimit(val)
	end
end

M.UpdateMultiPlayerLoadRate = function(self, pid, rate)
	if self.loadingPanel then
		self.loadingPanel:UpdateMultiPlayerLoadRate(pid, rate)
	end
end

M.ChangeLoadingPanelShowType = function(self, loadingStorePanelShowType)
	if self.loadingPanel then
		self.loadingPanel:ChangeLoadingPanelShowType(loadingStorePanelShowType)
	end
end

M.SetGarageLoadingCarUid = function(self, carUid)
	self.garageLoadingCarUid = carUid
end

M.GetGarageLoadingCarUid = function(self)
	local uid = self.garageLoadingCarUid or 0
	self.garageLoadingCarUid = nil

	return uid
end

M.Loading_Clear3CState = function(self, needClearCrouch)
	gClientUtils:ClearPaoKuState(false, false)

	if needClearCrouch then
		gUnitStateMgr:ResetMyStateAndClearMove(true)
	end

	gUnitStateMgr:DoEnterIdleSpeed(false, false, true)
end

gLoadingManager = gLoadingManager or C_LoadingManager.new()
