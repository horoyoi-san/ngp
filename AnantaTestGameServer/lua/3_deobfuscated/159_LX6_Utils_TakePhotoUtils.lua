local M = {}
local MessageConfig = LTConfig.MessageConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local PhotoZoomConfig = LTConfig.PhotoZoomConfig
local Screen = UnityEngine.Screen
local FilterEffectManager = LX6.Effect.FilterEffectManager
M.PhotoType = {
	Video = 1,
	Normal = 0
}
M.PhotoMode = {
	Normal = 2,
	FullView = 0,
	Count = 3,
	Selfie = 1,
	None = -1
}
M.PhotoTaskTargetState = {
	OUT_SCREEN = 3,
	IN_VIEW = 1,
	OUT_VIEW = 2
}
M.PhotoTemplate = {
	Default = 1,
	RobDog = 4,
	Climb = 2,
	SlotEntity = 3,
	UAV = 5,
	Spider = 6
}
M.PhotoCustomTargetType = {
	Video = 2,
	Npc = 1
}
M.isDebugForce = false
M.OncePhotoType = M.PhotoType.Normal
M.PhotoPermission = false
M.OpenLock = false
M.OncePhotoTemplate = M.PhotoTemplate.Default
M.ZoomConfigCache = nil
M.AllowVideoSettle = false
M.AllowVideoFOVCheck = false
M.VideoMaxFov = 0
M.VideoMinFov = 0

local function OpenActualPhoto(photoType, params)
	if photoType == M.PhotoType.Normal then
		gPanelManager:CheckShow(gPanelId.S_PHOTO_PANEL, params)
	elseif photoType == M.PhotoType.Video then
		if params and params.isForce then
			if params.template and params.template > 0 then
				M.OncePhotoTemplate = params.template
			else
				M.OncePhotoTemplate = M.PhotoTemplate.Default
			end
		end

		gPanelManager:CheckShow(gPanelId.S_PHOTOGRAPH_GAME_PANEL, params)
	end
end

function M.CallOnPhotoPanelAwake()
	L50.L50App.Scene.ScanMgr:ClearAllUnitEffectForce()
	LX6.Share.SceneRoomR.LockRoomProbe(true)
	gMessageManager:SendMessage(gEventConstants.PHOTO_CONTROLLER_NEW)
end

function M.CallOnPhotoPanelShow()
	if gCS.MindPowerMgr:HasAimItem() then
		gCS.MindPowerMgr:GetAimItem():SetDragBreak()
	end

	gCS.LuaUtils.EnablePhotoMoveMode(false)
	gMessageManager:SendMessage(gEventConstants.PHONE_SET_SCREEN_BTN_ACTIVE, false)
end

function M.CallOnPhotoPanelClose()
	M.SetPhotoIK(false)
	gCS.BaseUnitModuleUtils.TryChangeCollider(gCS.MyPlayerManager.PlayerUnit, LX6.Units.Module.ColliderChangeModule.ChangeReason.TakePhoto, -1, -1)
	gCS.CameraDataMgr.cinemachineManager:SetFov(50, 0.3, 0, false)
	gCS.LuaUtils.EnablePhotoMoveMode(true)
	gMessageManager:SendMessage(gEventConstants.PHONE_SET_SCREEN_BTN_ACTIVE, true)
end

function M.CallOnPhotoPanelDisable()
	if gPanelManager:IsPanelShowing(gPanelId.S_HUD_TIPS) then
		gPanelManager:Close(gPanelId.S_HUD_TIPS)
	end

	LX6.Share.SceneRoomR.LockRoomProbe(false)
end

function M.CallOnPhotoPanelDestroy()
	gMessageManager:SendMessage(gEventConstants.PHONE_SET_SCREEN_BTN_ACTIVE, true)

	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.ModelSlot.ExpressionController then
		gCS.MyPlayerManager.PlayerUnit.ModelSlot.ExpressionController:PlayIdle(false, true)
	end

	gMessageManager:SendMessage(gEventConstants.PHOTO_CONTROLLER_DESTROY)
end

function M.PlayTakePhotoAction(takePhotoState)
	gCS.TransitionMgr.TakePhotoState = takePhotoState

	gCS.LuaUtils.CheckSwitchAction(true, false, false, 0)
end

function M.PlayTakePhotoCamera(PhotoMode, photoTemplate, blendTime)
	gCS.CameraDataMgr.cinemachineManager:EnablePhotoTemplate(PhotoMode + 1, photoTemplate, blendTime)
end

function M.ChangeExpression(expressionId)
	if gCS.MyPlayerManager.PlayerUnit.ModelSlot.ExpressionController then
		if expressionId == 0 then
			gCS.MyPlayerManager.PlayerUnit.ModelSlot.ExpressionController:PlayIdle(false, true)

			return
		end

		gCS.MyPlayerManager.PlayerUnit.ModelSlot.ExpressionController:PlaySpecialExpression(expressionId, 0, true, 9999)
	end
end

function M.SwitchPlayerSpirit(roleId)
	gClientToGameSceneDelegate:AskSwitchPlayerSpirit(roleId).Callback = function (err)
		if err == MessageConfig.Ok then
			gSoundMgr:PlayModelSwitchSoundByModelId(LTConfig.SoundConfig.PhotoSwitchCharacter, gCS.MyPlayerManager.PlayerUnit.ClientData.ModelId, gCS.MyPlayerManager.PlayerUnit.LocalPosition)
		elseif err == MessageConfig.SummonAtInvalidPosition then
			gDisplayMessageMgr:ShowMessage(MessageConfig.SummonAtInvalidPosition)
		end
	end
end

function M.SetPhotoCameraFOV(value)
	gCS.CameraDataMgr.cinemachineManager:SetPhotoCamFov(value)

	if not M.ZoomConfigCache then
		M.ZoomConfigCache = {}

		for i = 0, PhotoZoomConfig.count - 1 do
			local cfg = PhotoZoomConfig.LoadAt(i)
			M.ZoomConfigCache[cfg.FOV] = cfg.BodyDis
		end
	end

	local bodyDis = M.ZoomConfigCache[math.floor(value)]

	if bodyDis then
		gCS.BaseUnitModuleUtils.TryChangeCollider(gCS.MyPlayerManager.PlayerUnit, LX6.Units.Module.ColliderChangeModule.ChangeReason.TakePhoto, bodyDis, -1)
	end
end

function M.DoSelfieActionEvent(event, eventParam)
	if eventParam then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, event, eventParam)
	else
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, event)
	end
end

function M.DoActionWhenSwitchComposition(fromSignal, toSignal)
	if fromSignal == MuGenStates.Logic.GameplayEvent.PhotoSideSelfie and toSignal == MuGenStates.Logic.GameplayEvent.PhotoFrontalSelfie then
		gCS.CameraDataMgr.cinemachineManager:SwitchSelfiePhotoMode(false, 0.5)
	elseif fromSignal == MuGenStates.Logic.GameplayEvent.PhotoFrontalSelfie and toSignal == MuGenStates.Logic.GameplayEvent.PhotoSideSelfie then
		gCS.CameraDataMgr.cinemachineManager:SwitchSelfiePhotoMode(true, 0.5)
	end
end

function M.SetPhotoIK(enable)
	if gClientUtils.IsNil(gCS.MyPlayerManager.PlayerUnit.ModelSlot.eyeIk) then
		return
	end

	if enable then
		gCS.MyPlayerManager.PlayerUnit.ModelSlot.eyeIk.dependLookAtIk = false
		gCS.MyPlayerManager.PlayerUnit.ModelSlot.eyeIk.ikTarget = gCS.CameraDataMgr.MainCamera.transform
	else
		gCS.MyPlayerManager.PlayerUnit.ModelSlot.eyeIk.dependLookAtIk = true
	end
end

function M.SetPhotoFilters(filters)
	FilterEffectManager.AddFilterExclusive(filters)
end

function M.ClearPhotoFilters()
	FilterEffectManager.RemoveAllFilter()
end

function M.GetPhotoTemplate()
	return M.OncePhotoTemplate
end

function M:GetFocusUnitStateForCS(position, uiWidth, uiHeight)
	return M.GetFocusUnitState(position, uiWidth, uiHeight)
end

function M.GetFocusUnitState(position, uiWidth, uiHeight)
	local taskPhotoState = nil
	local mainCamera = gCS.CameraDataMgr.MainCamera
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(position, mainCamera, 0, 0, 0)
	local targetFrameWidth = uiWidth
	local targetFrameHeight = uiHeight

	if z >= 0 then
		local uiPosition = gCS.LuaUtils.ScreenPointToUINoRay(x, y)

		if M.CheckUIPositionInRect(uiPosition, targetFrameWidth, targetFrameHeight) then
			taskPhotoState = M.PhotoTaskTargetState.IN_VIEW
		else
			local uiWidth = Screen.width
			local uiHeight = Screen.height

			if M.CheckScreenPositionInRect(x, y, uiWidth, uiHeight) then
				taskPhotoState = M.PhotoTaskTargetState.OUT_VIEW
			else
				taskPhotoState = M.PhotoTaskTargetState.OUT_SCREEN
			end
		end
	else
		taskPhotoState = M.PhotoTaskTargetState.OUT_SCREEN
	end

	return taskPhotoState
end

function M.GetTaskUnitState(cs_unit, targetFrame, rootRect)
	local taskPhotoState = nil
	local mainCamera = gCS.CameraDataMgr.MainCamera
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(cs_unit.UpBodyPosition, mainCamera, 0, 0, 0)
	local targetFrameWidth = targetFrame:GetTargetWidth()
	local targetFrameHeight = targetFrame:GetTargetHeight()

	if z >= 0 then
		local uiPosition = gCS.LuaUtils.ScreenPointUI(rootRect, Vector3.New(x, y, 0))

		if M.CheckUIPositionInRect(uiPosition, targetFrameWidth, targetFrameHeight) then
			taskPhotoState = M.PhotoTaskTargetState.IN_VIEW
		else
			local uiWidth = Screen.width
			local uiHeight = Screen.height

			if M.CheckScreenPositionInRect(x, y, uiWidth, uiHeight) then
				taskPhotoState = M.PhotoTaskTargetState.OUT_VIEW
			else
				taskPhotoState = M.PhotoTaskTargetState.OUT_SCREEN
			end
		end
	else
		taskPhotoState = M.PhotoTaskTargetState.OUT_SCREEN
	end

	return taskPhotoState
end

function M.GetTaskPositionState(position, targetFrame, rootRect)
	local taskPhotoState = nil
	local mainCamera = gCS.CameraDataMgr.MainCamera
	local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(position, mainCamera, 0, 0, 0)
	local targetFrameWidth = targetFrame:GetTargetWidth()
	local targetFrameHeight = targetFrame:GetTargetHeight()

	if z >= 0 then
		local uiPosition = gCS.LuaUtils.ScreenPointUI(rootRect, Vector3.New(x, y, 0))

		if M.CheckUIPositionInRect(uiPosition, targetFrameWidth, targetFrameHeight) then
			taskPhotoState = M.PhotoTaskTargetState.IN_VIEW
		else
			local uiWidth = Screen.width
			local uiHeight = Screen.height

			if M.CheckScreenPositionInRect(x, y, uiWidth, uiHeight) then
				taskPhotoState = M.PhotoTaskTargetState.OUT_VIEW
			else
				taskPhotoState = M.PhotoTaskTargetState.OUT_SCREEN
			end
		end
	else
		taskPhotoState = M.PhotoTaskTargetState.OUT_SCREEN
	end

	return taskPhotoState
end

function M.CheckUIPositionInRect(uiPosition, width, height)
	if uiPosition.x > -width * 0.5 and uiPosition.x < width * 0.5 and uiPosition.y > -height * 0.5 and uiPosition.y < height * 0.5 then
		return true
	end
end

function M.CheckScreenPositionInRect(x, y, width, height)
	if x > 0 and x < width and y > 0 and y < height then
		return true
	end
end

function M.SetSpecifiedPanelsVisible(visible)
	local panelIdList = {
		gPanelId.DIR_JOYSTICK
	}

	for _, panelId in ipairs(panelIdList) do
		local go = gLuaDataManager.guiMgr.panelCache:GetUICacheObject(panelId)

		if gClientUtils.NotNil(go) then
			local scale = visible and Vector3.one or Vector3.zero
			go.transform.localScale = scale
		end
	end
end

function M.DoSpecialPhotoCheck(params)
	if gCS.LuaUtils.CheckIsInRobDogMode() then
		M.OncePhotoTemplate = M.PhotoTemplate.RobDog

		OpenActualPhoto(M.OncePhotoType, params)

		M.OpenLock = false

		return true
	end

	if gCS.LuaUtils.CheckIsInUAVMode() then
		M.OncePhotoTemplate = M.PhotoTemplate.UAV

		OpenActualPhoto(M.OncePhotoType, params)

		M.OpenLock = false

		return true
	end

	if gCS.LuaUtils.CheckIsInSpiderBotMode() then
		M.OncePhotoTemplate = M.PhotoTemplate.Spider

		OpenActualPhoto(M.OncePhotoType, params)

		M.OpenLock = false

		return true
	end

	return false
end

function M.TryTakePhoto(preCheckFunc, params)
	if M.isDebugForce then
		OpenActualPhoto(M.OncePhotoType, params)

		return true
	end

	if params and params.isForce then
		OpenActualPhoto(M.OncePhotoType, params)

		return true
	end

	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.PhotoUnlock) then
		return false
	end

	if M.OpenLock then
		return false
	end

	M.OpenLock = true

	M.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.NormalTakePhoto)

	if not M.PhotoPermission then
		if M.DoSpecialPhotoCheck(params) then
			return true
		end

		gDisplayMessageMgr:ShowMessageContent(TextScriptTextConfig.GetConfig(89900379).Text)
		M.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.None)

		M.OpenLock = false

		return false
	end

	M.PhotoPermission = false

	if preCheckFunc and type(preCheckFunc) == "function" then
		preCheckFunc()
	end

	OpenActualPhoto(M.OncePhotoType, params)

	M.OpenLock = false

	return true
end

function M.HideUid(flag)
	if gLuaUIMgr.uidLayerPanelStore then
		gLuaUIMgr.uidLayerPanelStore:RefreshUIDDisplay(not flag)
	end
end

gTakePhotoUtils = M
