-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhotoPanelStore_Utils.lua
-- Decompiled from: 00853_PhotoPanelStore_Utils.lua_54206d13e514.luajit

local PhotoMode = gTakePhotoUtils.PhotoMode
local PhotoUtils = LX6.Utils.PhotoUtils
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
local PhotoFramesConfig = LTConfig.PhotoFramesConfig
local NextMode2NameId = {
	[PhotoMode.FullView] = 874,
	[PhotoMode.Selfie] = 873,
	[PhotoMode.Normal] = 875
}
local M = C_PhotoPanelStore

M.FormatParamValue = function(self, value, step)
	if step > 1 then
		return string.format("%.0f", value)
	end

	local decimals = 1
	local v = step * 10

	while v >= 1 do
		decimals = decimals + 1
		v = v * 10
	end

	return string.format("%." .. decimals .. "f", value)
end

M.GetCurrentStanceType = function(self)
	if self.photoMode ~= PhotoMode.FullView then
		return nil
	elseif self.photoMode ~= PhotoMode.Normal then
		return self.isSitting and 3 or 1
	else
		return self.isSitting and 2 or 0
	end
end

M.IsPhotoModeValid = function(self, photoMode)
	if photoMode ~= PhotoMode.FullView then
		return gTakePhotoUtils.templateConfig.canDefault
	elseif photoMode ~= PhotoMode.Selfie then
		return gTakePhotoUtils.templateConfig.canSelfie
	elseif photoMode ~= PhotoMode.Normal then
		return gTakePhotoUtils.templateConfig.canThird
	end

	return false
end

M.GetNextValidPhotoMode = function(self, curPhotoMode)
	local photoMode = curPhotoMode

	for _ = 1, 3 do
		photoMode = (photoMode + 1) % 3

		if self.IsPhotoModeValid(self, photoMode) then
			return photoMode
		end
	end

	return PhotoMode.FullView
end

M.SetCurrentPhotoMode = function(self)
	if self.lastPhotoMode ~= PhotoMode.Normal then
		-- Nothing
	elseif self.lastPhotoMode ~= PhotoMode.Selfie then
		gTakePhotoUtils.DoSelfieActionEvent(MuGenStates.Logic.GameplayEvent.PhotoSelfieExit)
		MuGenStates.Logic.ABPVarManager.SetBool(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.PhoneSelfie, false)
	end

	local needSkipNormalTakePhoto = self.needSkipNormalTakePhoto
	self.needSkipNormalTakePhoto = false

	if self.photoMode ~= PhotoMode.FullView then
		self.bindData.photoModeCtrl = 0

		if not needSkipNormalTakePhoto or needSkipNormalTakePhoto ~= false then
			gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.NormalTakePhoto)
		end

		self.selectedAction = self:GetDefaultPhotoAction()

		LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, self.m_Id)
		gCS.LuaUtils.ClearShadowFocus()
	elseif self.photoMode ~= PhotoMode.Selfie then
		self.bindData.photoModeCtrl = 1

		MuGenStates.Logic.ABPVarManager.SetBool(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.PhoneSelfie, true)
		gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.SelfTakePhoto)
		gTakePhotoUtils.DoSelfieActionEvent(MuGenStates.Logic.GameplayEvent.PhotoFrontalSelfie)

		self.defaultSelfiePosture = 1
		self.selectedAction = self:GetDefaultPhotoAction()

		self:BuildSelfieExpressionData(true)
		LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, self.m_Id)

		local playerUnit = gCS.MyPlayerManager.PlayerUnit

		if playerUnit then
			gCS.LuaUtils.SetShadowFocus(playerUnit.LocalPosition)
		end
	elseif self.photoMode ~= PhotoMode.Normal then
		self.bindData.photoModeCtrl = 2

		gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.ThirdPhotoEnter)

		self.selectedAction = self:GetDefaultPhotoAction()

		self:BuildSelfieExpressionData(true)
		LX6.GUI.GuiMgr.Instance:SetDisableJoystick(true, self.m_Id)
		gCS.LuaUtils.ClearShadowFocus()
	end

	self.lastPhotoMode = self.photoMode
	gCS.PhotoManager.Instance.curPhotoMode = self.photoMode

	self.UpdateCircularSliderActiveState(self)
	self.UpdateMobileJoystickActiveState(self)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local nextMode = self.GetNextValidPhotoMode(self, self.photoMode)
		local nameId = NextMode2NameId[nextMode]

		if nameId then
			self.bindData.switchBtn:SetPCKeyInfoTipNameId(nameId)
			self.bindData.navigation:ChangeButtonNameByActionId(23, nameId)
		end
	else
		local curNameId = NextMode2NameId[self.photoMode]

		if curNameId then
			local curNameCfg = InputButtonNameConfig.GetConfig(curNameId)

			if curNameCfg then
				self.bindData.curPhotoModeText = curNameCfg.Name
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.PHOTO_SWITCH_MODE, self.photoMode)

	local notForceSetSetippleAlpha = gTakePhotoUtils.templateConfig and gTakePhotoUtils.templateConfig.hideBodyInFirstPerson ~= false and self.photoMode ~= PhotoMode.FullView or false

	gTakePhotoUtils.PlayTakePhotoCamera(self.photoMode, self.photoTemplate, 1, notForceSetSetippleAlpha)

	local tiltAngle = PhotoUtils.GetCameraParam("CameraParamTiltAngle")

	if tiltAngle then
		PhotoUtils.SetCameraParam("CameraParamTiltAngle", tiltAngle)
	end
end

M.ShowPostProcessPanel = function(self)
	if gCS.LuaUtils.IsNull(self.rootGo) then
		return
	end

	gUIUtils:SetUITouchEnable(true)

	local frameCfg = PhotoFramesConfig.LoadAt(self.selectedFrame)
	local cropW, cropH = gTakePhotoUtils.ResolveCropSize(frameCfg, self.selectedFrame)
	local customPhotoTargetType, customTargetData = nil

	if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		local succeededPids = gCS.PhotoManager.Instance:GetAndClearLastShotSucceededPids()
		customTargetData = {}

		if succeededPids then
			for i = 1, #succeededPids do
				customTargetData[succeededPids[i]] = true
			end
		end

		if next(customTargetData) then
			customPhotoTargetType = gTakePhotoUtils.PhotoCustomTargetType.Npc
		end
	else
		for tType, set in pairs(self.customTargetResultSet) do
			if next(set) then
				customPhotoTargetType = tType

				break
			end
		end

		customTargetData = table.clone(self.customTargetResultSet[customPhotoTargetType])
	end

	local templateConfig = gTakePhotoUtils.templateConfig

	if not templateConfig or not templateConfig.disablePostProcessPanel then
		gPanelManager:CheckShow(gPanelId.S_PHOTO_POST_PROCESS_PANEL, {
			["\\x98\\xb9\n\\xbc^?\\xed8"] = false,
			watermarkInfo = self.watermarkCache,
			selectedFrame = self.selectedFrame,
			selectedFrameIconId = self.selectedFrameIconId,
			cropW = cropW,
			cropH = cropH,
			TaskId = gCS.PhotoManager.Instance.isUsingNewPhotoTask and self.shutterTaskId or self.nowFocusTaskId,
			PhotoMode = self.photoMode,
			customTargetType = customPhotoTargetType,
			customTargetData = customTargetData,
			ShareCallback = function (result)
				if not result then
					self:RecoverBasicUIFromPhotoShot()
				end
			end
		})
	else
		self.RecoverBasicUIFromPhotoShot(self)
	end
end

M.RecoverBasicUIFromPhotoShot = function(self)
	self:UpdateMobileJoystickActiveState()
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_PHOTO_PANEL, self.bindData.selfieMenuFold == 1)
	gTakePhotoUtils.HideUid(true)

	self.stopUpdateHud = false
end

M.PlayTakePhotoAnim = function(self, shotTaskId)
	self:SetPhotoTexture()

	local takePhotoAniName = self:GetTakePhotoAnimName()

	self.bindData.photoSuccessVx.gameObject:SetActive(true)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.photoSuccessVx, takePhotoAniName)

	if gClientUtils.NotNil(self.rootGo) then
		local scale = SGUI.UIConfig.instance:GetCurrentAdaptationScale()
		self.rootGo.transform.localScale = Vector3.New(scale, scale, 1)
	end

	if not self.needClosePanel then
		self.RecoverBasicUIFromPhotoShot(self)
	end

	local animLength = self.GetTakePhotoAnimLength(self)

	gLuaTimeMgrUtils.Delay(function ()
		if self.needClosePanel and gPanelManager:IsPanelShowing(self.m_Id) then
			self:ClosePanel()
			gClientUtils.CloseMainPhonePanel()
		end

		gMessageManager:SendMessage(gEventConstants.PHOTO_PUT_AWAY, {
			TaskId = shotTaskId
		})
	end, animLength)
end

M.GetTakePhotoAnimLength = function(self)
	local takePhotoAniName = self.GetTakePhotoAnimName(self)

	return gClientUtils.GetAnimationClipLength(self.bindData.photoSuccessVx, takePhotoAniName)
end

M.GetTakePhotoAnimName = function(self)
	local templateConfig = gTakePhotoUtils.templateConfig

	if templateConfig and templateConfig.photoEffectName and templateConfig.photoEffectName == "" then
		return templateConfig.photoEffectName
	end

	return gCS.LuaUtils.IsNonMobileAdaptive() and "S_Vx_Photopanel_takephoto_SuccessPC" or "S_Vx_Photopanel_takephoto_SuccessMobile"
end
