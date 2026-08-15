C_LoadingManager = DefClass("C_LoadingManager", C_LoadingManager)
local M = C_LoadingManager

function M:SwitchRole_SetSwitchRolePanel(switchRolePanel)
	self.switchRolePanel = switchRolePanel
end

function M:SetLoadingPanel(loadingPanel)
	self.loadingPanel = loadingPanel
end

local CS_LoadingManager = LX6.GUI.LoadingManager.Instance

function M:StopLoading(loadingInfoIndex, executeAfterLoadingEndCb)
	if executeAfterLoadingEndCb == nil then
		CS_LoadingManager:StopLoading(loadingInfoIndex)
	else
		CS_LoadingManager:StopLoading(loadingInfoIndex, executeAfterLoadingEndCb)
	end
end

function M:StopWaitLoading(loadingInfoIndex)
	CS_LoadingManager:StopWaitLoading(loadingInfoIndex)
end

function M:CheckLoadingInfoIndexIsLoading(loadingInfoIndex)
	return CS_LoadingManager:CheckLoadingInfoIndexIsLoading(loadingInfoIndex)
end

function M:CancelPreCover()
	CS_LoadingManager:CancelPreCover()
end

function M:GeneralCutIn_StopWaitLoading()
	CS_LoadingManager:GeneralCutIn_StopWaitLoading()
end

function M:RefreshDataOpenLoadingFinish(loadingTextId)
	CS_LoadingManager:RefreshDataOpenLoadingFinish(loadingTextId)
end

function M:Loading_ManualStopExecute()
	CS_LoadingManager:Loading_ManualStopExecute()
end

function M:SwitchTeleport_BeginShow(fightSpiritId)
	CS_LoadingManager:SwitchTeleport_BeginShow(fightSpiritId)
end

function M:SwitchTeleport_CloseUpPrepare()
	CS_LoadingManager:SwitchTeleport_CloseUpPrepare()
end

function M:SwitchTeleport_CloseUpSync()
	CS_LoadingManager:SwitchTeleport_CloseUpSync()
end

function M:SwitchTeleport_TryOpenBlur()
	CS_LoadingManager:SwitchTeleport_TryOpenBlur()
end

function M:SwitchTeleport_TryCloseBlur()
	CS_LoadingManager:SwitchTeleport_TryCloseBlur()
end

function M:PreShowLoading()
	gCS.LoadingPanelManager:PreShowLoading()
end

function M:Create_TaskOverrideLoadingParams()
	return CS_LoadingManager:Create_TaskOverrideLoadingParams()
end

function M:Task_SetOverrideLoadingInfo(taskOverrideLoadingParams)
	CS_LoadingManager:Task_SetOverrideLoadingInfo(taskOverrideLoadingParams)
end

function M:Event_OnTaskInactive(taskId)
	CS_LoadingManager:Event_OnTaskInactive(taskId)
end

function M:Quick_Garage(houseId, currentCarUid, parkingIndex, enter, afterPhaseCb, finalCb)
	return CS_LoadingManager:Quick_Garage(houseId, currentCarUid, parkingIndex, enter, afterPhaseCb, finalCb)
end

function M:Quick_CarShop(carShopId, currentCarUid, enter, afterPhaseCb, finalCb)
	return CS_LoadingManager:Quick_CarShop(carShopId, currentCarUid, enter, afterPhaseCb, finalCb)
end

function M:Quick_MapTeleport(mapEntranceId, forceLoading, firstFrameCb)
	return CS_LoadingManager:Quick_MapTeleport(mapEntranceId, forceLoading, firstFrameCb)
end

function M:Quick_Revive(forceLoading, afterLoadingCb)
	return CS_LoadingManager:Quick_Revive(forceLoading, afterLoadingCb)
end

function M:Quick_GeneralCutIn(cutsceneName, targetPos, targetFacing, generalCutInEndAction, callback, dontOpenBlackScreenValue)
	return CS_LoadingManager:Quick_GeneralCutIn(cutsceneName, targetPos, targetFacing, generalCutInEndAction, callback, dontOpenBlackScreenValue)
end

function M:Quick_GeneralTeleport(generalTeleportParams, targetPos, targetFacing, generalCutInEndAction, plotLoadingType, plotLoadingPanelType)
	return CS_LoadingManager:Quick_GeneralTeleport(generalTeleportParams, targetPos, targetFacing, generalCutInEndAction, plotLoadingType, plotLoadingPanelType)
end

function M:Create_GeneralTeleportParams()
	return CS_LoadingManager:Create_GeneralTeleportParams()
end

function M:Quick_FallOff()
	return CS_LoadingManager:Quick_FallOff()
end

function M:Quick_GM(targetPos)
	return CS_LoadingManager:Quick_GM(targetPos)
end

function M:Quick_TeleportWithCar(forceLoading, targetPos)
	return CS_LoadingManager:Quick_TeleportWithCar(forceLoading, targetPos)
end

function M:Quick_DefaultTeleport(targetPos)
	return CS_LoadingManager:Quick_DefaultTeleport(targetPos)
end

function M:Quick_EnterExitRoom(mapEntranceId, callback)
	return CS_LoadingManager:Quick_EnterExitRoom(mapEntranceId, callback)
end

function M:Create_TextTeleportParams()
	return CS_LoadingManager:Create_TextTeleportParams()
end

function M:Quick_TextTeleport(textTeleportParams)
	return CS_LoadingManager:Quick_TextTeleport(textTeleportParams)
end

function M:Quick_ArrestTeleport(part1Pos, part1Facing, part3Pos, part3Facing, arrestPart1, arrestPart2, arrestPart3, onPart1FinishCb, minBeforeDuration, minLoadingDuration)
	if minBeforeDuration == nil then
		minBeforeDuration = 0
	end

	if minLoadingDuration == nil then
		minLoadingDuration = 0
	end

	return CS_LoadingManager:Quick_ArrestTeleport(part1Pos, part1Facing, part3Pos, part3Facing, arrestPart1, arrestPart2, arrestPart3, onPart1FinishCb, minBeforeDuration, minLoadingDuration)
end

function M:Quick_ViewFocusChange_Robot(callback)
	return CS_LoadingManager:Quick_ViewFocusChange_Robot(callback)
end

function M:Quick_ViewFocusChange(viewFocusChangeParams)
	return CS_LoadingManager:Quick_ViewFocusChange(viewFocusChangeParams)
end

function M:Create_ViewFocusChangeParams()
	return CS_LoadingManager:Create_ViewFocusChangeParams()
end

function M:Quick_SilentTeleport(addBegin, beforeLoadingCallback, finishedCallback, forceLoadingBoolean)
	local forceLoading = forceLoadingBoolean

	if forceLoadingBoolean == nil then
		forceLoading = true
	end

	return CS_LoadingManager:Quick_SilentTeleport(addBegin, beforeLoadingCallback, finishedCallback, forceLoading)
end

function M:ShowPayTips(payTipsIconId, payTipsId, money)
	local moneyEnough = money <= gPlayerManager.infoItem.bindData.money

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.PayTips, {
		Param = {
			logoId = payTipsIconId,
			textId = payTipsId,
			value = money,
			moneyEnough = moneyEnough
		}
	})
end

function M:SetLoadingProgress(val)
	if self.loadingPanel then
		self.loadingPanel:SetProgressLimit(val)
	end
end

function M:SetFullScreenMaskActive(active)
	if self.loadingPanel then
		self.loadingPanel:SetFullScreenMaskActive(active)
	end
end

function M:UpdateMultiPlayerLoadRate(pid, rate)
	if self.loadingPanel then
		self.loadingPanel:UpdateMultiPlayerLoadRate(pid, rate)
	end
end

function M:NotifyLoadingSceneLoaded()
	if self.loadingPanel then
		self.loadingPanel:NotifyLoadingSceneLoaded()
	end
end

function M:SwitchRole_OpenPanelStartSceneResWaiting(fightSpiritId, leftRTCam)
	gPanelManager:CheckShow(gPanelId.S_SWITCH_ROLE_PANEL, {
		fightSpiritId = fightSpiritId,
		leftRTCam = leftRTCam
	})
end

function M:SwitchRole_EndSceneResWaiting()
	if self.switchRolePanel then
		self.switchRolePanel:HidePhoneDialogUI()
	end
end

function M:SwitchRole_SetRightRTCamera(rtCam)
	if self.switchRolePanel then
		self.switchRolePanel:SetRightRTCam(rtCam)
	end
end

function M:SwitchRole_SplitScreenMoveToOneThird()
	if self.switchRolePanel then
		self.switchRolePanel:SetPhaseOneThird()
	end
end

function M:SwitchRole_SplitScreenMoveToHalf()
	if self.switchRolePanel then
		self.switchRolePanel:SetPhaseHalf()
	end
end

function M:SwitchRole_CloseSplitScreenChangeToRight()
	if self.switchRolePanel then
		self.switchRolePanel:SetPhaseRight()
	end
end

function M:SwitchRole_CloseSplitScreenPanel()
	if self.switchRolePanel then
		self.switchRolePanel:ReleaseRTManual()
	end

	self.switchRolePanel = nil

	gPanelManager:Close(gPanelId.S_SWITCH_ROLE_PANEL)
end

function M:SwitchRole_CloseSplitGetChairBestTarget(pointList, forward, currentPos)
	local pointTable = pointList:ToTable()
	local pointTransPointTable = {}

	for _, v in pairs(pointTable) do
		local trans = {
			position = v,
			forward = forward
		}

		table.insert(pointTransPointTable, trans)
	end

	local bestTarget = gInteractionManager:GetChairBestTarget(pointTransPointTable, nil, false, true, false, currentPos)

	return bestTarget.position, bestTarget.forward
end

function M:Loading_Clear3CState(needClearCrouch)
	gClientUtils:ClearPaoKuState(false, false)

	if needClearCrouch then
		gUnitStateMgr:ResetMyStateAndClearMove(true)
	end

	gUnitStateMgr:DoEnterIdleSpeed(false, false, true)
end

gLoadingManager = gLoadingManager or C_LoadingManager.new()
