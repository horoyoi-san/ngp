-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhotographGamePanelStore.lua
-- Decompiled from: 00843_PhotographGamePanelStore.lua_d5c5dc9fe455.luajit

local PhotographTemplateConfig = LTConfig.PhotoPhotographTemplateConfig
local PhotoTemplate = gTakePhotoUtils.PhotoTemplate
local PhotoMode = gTakePhotoUtils.PhotoMode
local GameInputManager = LX6.Manager.GameInputManager
local HUDManager = LX6.GUI.HUDNew.HUDManager
local MainViewUtils = LX6.Gps.MainViewUtils
local GuiMgr = LX6.GUI.GuiMgr
local VideoState = gTakePhotoUtils.PhotoTaskTargetState
C_PhotographGamePanelStore = DefClass("C_PhotographGamePanelStore", C_PhotographGamePanelStore, C_StoreGroup)
GroupName2Class.PhotographGamePanelStore = C_PhotographGamePanelStore
local M = C_PhotographGamePanelStore

dofile("LX6/SGUI/StoreDefine/PhotographGamePanelStore_Task")

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.photoTemplate = PhotoTemplate.Default
	self.isSwitching = false
	self.updateHudData = nil
	self.videoFocusTime = 0
	self.videoFocusTrans = nil
	self.isAlreadyPlayFocus = false
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.isFovBtnPressing = false
	self.FovChangeType = 0
	self.FovChangeTimeSignal = 0
	self.FovTimes = 1
	self.currentFOV = 0
	self.isLEndPress = true
	self.isREndPress = true
	self.inPhotoMode = false
	self.multiTargetData = nil
	self.multiTargetFocusStates = {}
	self.videoTargetTemplates = {}
	self.videoTargetTemplatePool = {}
	self.gpsTemplates = {}
	self.gpsTemplatePool = {}
	self.multiVideoFocusTrans = {}
	self.isMultiTargetFrameFocused = false
	self.needCameraFocusTarget = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)

	self.photoTemplate = gTakePhotoUtils.GetPhotoTemplate()
	local config = PhotographTemplateConfig.GetConfig(self.photoTemplate)

	if not config then
		print_error("不存在的拍照模板配置:", self.photoTemplate)

		return
	end

	gTakePhotoUtils.CacheConfig(config)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.photoTemplate = gTakePhotoUtils.GetPhotoTemplate()

	gTakePhotoUtils.CallOnPhotoPanelAwake()
end

M.OnEnable = function(self)
	local template = gTakePhotoUtils.OncePhotoTemplate

	if template ~= gTakePhotoUtils.PhotoTemplate.UAV then
		GuiMgr.Instance:SetShowJoystick(true, gPanelId.S_PHOTOGRAPH_GAME_PANEL)
	end

	if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		gCS.PhotoManager.Instance:RegisterPhotoTaskFrame(self.bindData.focusWidget, self.rootWidget.rectTransform)
	end
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	GuiMgr.Instance:SetShowJoystick(false, gPanelId.S_PHOTOGRAPH_GAME_PANEL)

	if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		gCS.PhotoManager.Instance:RegisterPhotoTaskFrame(nil, )
	end

	gTakePhotoUtils.CallOnPhotoPanelDisable()
end

M.OnDestroy = function(self)
	gTakePhotoUtils.CallOnPhotoPanelDestroy()

	if gClientUtils.CheckMainPhoneIsShowing() then
		gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.LookAtPhone)
	else
		gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.Clear)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollCallback)
	end
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if data and data.isBanClose then
		self.bindData.closeBtn:SetActive(false)
	end

	gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.NormalTakePhoto)
	gTakePhotoUtils.PlayTakePhotoCamera(PhotoMode.FullView, self.photoTemplate, 1)

	local hideTime = gTakePhotoUtils.templateConfig.enterPhotoModeSec

	self:InitUIElement()
	self:HandleSpPhotoTemplate()
	self:HideWholePanel(hideTime)
	gTakePhotoUtils.CallOnPhotoPanelShow()
	HUDManager.SetForceShow(true)
	HUDManager.ForceSetHUDTargetShow(gHudMgr.HUDTargetType.Npc)
	self:OnDOFSliderValueChanged(50)

	self.isFovBtnPressing = false

	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(self.m_Id, 5)
	gMessageManager:SendMessage(gEventConstants.PHOTOGRAPH_GAME_PANEL_ON_SHOW)

	self.needCameraFocusTarget = data and data.needFocusTarget
end

M.OnClose = function(self)
	gTakePhotoUtils.CallOnPhotoPanelClose()
	gTakePhotoUtils.PlayTakePhotoCamera(PhotoMode.None, self.photoTemplate, 1)

	if gClientUtils.CheckMainPhoneIsShowing() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	HUDManager.SetForceShow(false)
	gMessageManager:SendMessage(gEventConstants.VIDEO_COUNTDOWN_CONDITION, {
		["1\\xebP;)\\xdf\t\\xb8U\\x85Y\\xa7\\xb8"] = true,
		["*9\r\\xe1v\\x8c\\xd4;\\xa6+\\xef\\xe6\\xef{\\xf5"] = false
	})
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(self.m_Id)
	self:RecycleAllVideoTemplates()
end

M.OnLateUpdate = function(self)
	self.UpdateGamepadCamera(self)
	self.UpdateFovByJoyStick(self)
end

M.OnCameraUpdate = function(self)
	if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		self.RefreshTaskUI(self)
	else
		self.UpdateHudTargetData(self)
	end

	self.UpdateVideoMultiTargetHud(self)

	if gTakePhotoUtils.UseOldVideoTaskLogic then
		self.UpdateVideoTargetOnce(self)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PHOTO_CUSTOM_TARGET] = function (eventId, data)
			if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
				return
			end

			if gTakePhotoUtils.UseOldVideoTaskLogic then
				self.updateHudData = data

				return
			end

			if data and data.Type ~= gTakePhotoUtils.PhotoCustomTargetType.Video then
				local multiData = {
					{
						meetPos = data.meetPos
					},
					["wF~nK\n?5"] = 1,
					Type = gTakePhotoUtils.PhotoCustomTargetType.MultiVideo,
					TaskId = data.TaskId,
					successTime = data.successTime,
					failureTime = data.failureTime
				}
				self.multiTargetData = multiData
			end
		end,
		[gEventConstants.VIDEO_TASK_MULTI_TARGET] = function (eventId, data)
			if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
				return
			end

			self.multiTargetData = data
		end,
		[gEventConstants.L50_AFTER_SWITCH_SCENE] = function (eventId, switchSceneEventParams)
			local switchType = switchSceneEventParams.switchSceneType

			if switchType == gSwitchSceneType.Reconnect then
				return
			end

			gTakePhotoUtils.PlayTakePhotoCamera(PhotoMode.FullView, self.photoTemplate, 1)
		end,
		[gEventConstants.VIDEO_CRAZY_PHOTO_MODE_SIGNAL] = function (eventId, params)
			if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
				return
			end

			if not gPanelManager:IsPanelShowing(gPanelId.S_PHOTOGRAPH_GAME_PANEL) then
				return
			end

			local isEnter = params.isEnter
			self.inPhotoMode = isEnter
			self.bindData.takePhotoCtrl = isEnter and 1 or 0
		end,
		[gEventConstants.VIDEO_COUNTDOWN_TIME_UPDATE] = function (eventId, data)
			if data and data.timeStr then
				if gTakePhotoUtils.UseOldVideoTaskLogic then
					self.bindData.timeText2.text = data.timeStr
				end

				for index, vtRT in pairs(self.videoTargetTemplates) do
					if not gClientUtils.IsNil(vtRT) then
						local vtStore = self:GetStoreById(vtRT.gameObject:GetInstanceID())

						if vtStore then
							vtStore.templateTimeText.text = data.timeStr
						end
					end
				end
			end
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.takePhotoBtn.luaClick = self.CreateAction(self, "OnClickTakePhotoBtn")
	self.bindData.DOFSlider.luaValueChanged = self.CreateAction(self, "OnDOFSliderValueChanged")
	local fov = gTakePhotoUtils.templateConfig.FOV
	self.defaultValue = fov.defaultValue
	self.bindData.DOFSlider.minValue = 0
	self.bindData.DOFSlider.maxValue = 100
	self.bindData.DOFSlider.stepSize = 5
	self.bindData.DOFSlider.value = 50
	self.bindData.sliderStyle = 1

	self.bindData.DOFSlider.luaPress = function()
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	self.bindData.DOFSlider.luaRelease = function()
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end

	self.mouseScrollCallback = self.CreateAction(self, "OnMouseScroll")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollCallback)
	end

	self.bindData.FOVUpBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnFOVPress", {
		["ZI변8\\xaa\\xda\\xfb"] = false,
		[""] = 1
	})
	self.bindData.FOVDownBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnFOVPress", {
		["ZI변8\\xaa\\xda\\xfb"] = false,
		[""] = -1
	})
	self.bindData.FOVUpBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnFOVPress", {
		["ZI변8\\xaa\\xda\\xfb"] = true,
		[""] = 1
	})
	self.bindData.FOVDownBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnFOVPress", {
		["ZI변8\\xaa\\xda\\xfb"] = true,
		[""] = -1
	})
	self.bindData.rightJoyStick.luaGamePadInputChanged = self.CreateAction(self, "OnRightJoyStickInputChanged")
	self.bindData.UAVUpBtn.luaPress = self.CreateAction(self, "OnUAVBtnUpPress")
	self.bindData.UAVUpBtn.luaRelease = self.CreateAction(self, "OnUAVBtnUpRelease")
	self.bindData.UAVUpBtn.luaClick = self.CreateAction(self, "OnUAVBtnUpClick")
	self.bindData.UAVDownBtn.luaPress = self.CreateAction(self, "OnUAVBtnDownPress")
	self.bindData.UAVDownBtn.luaRelease = self.CreateAction(self, "OnUAVBtnDownRelease")
	self.bindData.UAVDownBtn.luaClick = self.CreateAction(self, "OnUAVBtnDownClick")
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickTakePhotoBtn = function(self)
	if not self.inPhotoMode then
		return
	end

	self.bindData.takePhotoBtn.interactable = false
	slot1 = self:PlayAniChain(self.bindData.photoAni, "S_Vx_PhotoPanel_Light")

	slot1:OnComplete(function ()
		self.bindData.takePhotoBtn.interactable = true
	end)

	if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		local pm = gCS.PhotoManager.Instance

		pm.UpdateTaskInfoOnTakePhoto(pm, pm.GetCurTaskId(pm))

		return
	end

	if self.bindData.videoFocusCtrls == 0 then
		return
	end

	gMessageManager:SendMessage(gEventConstants.VIDEO_CRAZY_PHOTO_COUNT_UPDATE)
end

M.OnDOFSliderValueChanged = function(self, value)
	gSoundMgr:PlaySoundByTid(70601122)

	local fov = gTakePhotoUtils.templateConfig.FOV
	local minFov = fov.minValue
	local maxFov = fov.maxValue
	local defaultValue = fov.defaultValue
	local realValue, showValue = nil

	if value > 50 then
		self.bindData.DOFSlider.stepSize = 5
		realValue = defaultValue + (value - 50) / 5 * (maxFov - defaultValue) / 10
		showValue = 1 + (value - 50) / 5 * 0.1
	else
		self.bindData.DOFSlider.stepSize = 10
		realValue = minFov + value / 10 * (maxFov - defaultValue) / 5
		showValue = 0.5 + value / 10 * 0.1
	end

	self.bindData.DOFSlider.valueText.text = string.format("%.1fx", showValue)
	self.currentFOV = (maxFov + minFov - realValue) / self.FovTimes

	gTakePhotoUtils.SetPhotoCameraFOV(self.currentFOV)
end

M.OnMouseScroll = function(self, context)
	if SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice() or self.photoMode ~= PhotoMode.Selfie or self.isSwitching then
		return
	end

	if context.performed then
		local zoom = context.ReadValueVector2(context).y
		self.scrollSignal = true

		if zoom <= 0 then
			self.UpdateFovByMouseScroll(self, 1)
		else
			self.UpdateFovByMouseScroll(self, -1)
		end
	end
end

M.OnFOVPress = function(self, args)
	local op = args.op

	if op ~= 1 then
		self.isLEndPress = args.isEndPress
	else
		self.isREndPress = args.isEndPress
	end

	local isEndPress = self.isLEndPress and self.isREndPress

	if not isEndPress then
		self.isFovBtnPressing = true

		if not self.isLEndPress and not self.isREndPress then
			if op <= 0 then
				self.FovChangeType = 1
			else
				self.FovChangeType = -1
			end
		elseif self.isREndPress then
			self.FovChangeType = 1
		else
			self.FovChangeType = -1
		end
	else
		self.isFovBtnPressing = false
		self.FovChangeType = 0
	end
end

local INTERVAL = 0.1

M.UpdateFovByJoyStick = function(self)
	if not self.isFovBtnPressing then
		return
	end

	self.FovChangeTimeSignal = self.FovChangeTimeSignal + Time.unscaledDeltaTime

	if self.FovChangeTimeSignal >= INTERVAL then
		return
	end

	self.FovChangeTimeSignal = 0
	self.bindData.DOFSlider.value = self.bindData.DOFSlider.value + self.FovChangeType * self.bindData.DOFSlider.stepSize
end

M.OnRightJoyStickInputChanged = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.started or context.performed then
		self.needUpdateCamera = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.needUpdateCamera = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(5, 0, 0)
	end
end

M.UpdateGamepadCamera = function(self)
	if self.needUpdateCamera then
		gCameraUtils:DoRotateCameraByGamePad(5, self.rightStickValue.x, self.rightStickValue.y)
	end
end

M.OnUAVBtnUpPress = function(self)
	self.PlayUAVBtnDownAnime(self, self.bindData.UAVUpBtn)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.UAVRisePress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnUpPress send3CEvent UAVRisePress")
	end
end

M.OnUAVBtnUpRelease = function(self)
	self.PlayUAVBtnUpAnime(self, self.bindData.UAVUpBtn)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.UAVRiseRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnUpRelease send3CEvent UAVRiseRelease")
	end
end

M.OnUAVBtnDownPress = function(self)
	self.PlayUAVBtnDownAnime(self, self.bindData.UAVDownBtn)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.UAVFallPress)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDownPress send3CEvent UAVFallPress")
	end
end

M.OnUAVBtnDownRelease = function(self)
	self.PlayUAVBtnUpAnime(self, self.bindData.UAVDownBtn)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.UAVFallRelease)

	if gStoreManager.DEBUG_UI_INPUT then
		print_error("#NoCreateIssue OnBtnDownRelease send3CEvent UAVFallRelease")
	end
end

M.OnUAVBtnDownClick = function(self)
end

local UAV_BTN_ANIME = {
	["59"] = "_^\\xe1]\\xfb\\xd1\\xe7k\\xffaI\\xf7\\xf2l\\xf3[t\\xd7\\xde\\xecأ\\xe7t",
	["^\rJu"] = " L^D8\\xad}\\xf8D0he{C\\xff6{\\xe6D"
}

M.PlayUAVBtnDownAnime = function(self, btn)
	local store = gStoreManager:GetStoreGroup("RobotFlyerControlsStore"):GetStoreByWidget(btn)

	gCS.LuaUtils.PlayAnimationByName(store.btnFanseAni, UAV_BTN_ANIME.DOWN)
end

M.PlayUAVBtnUpAnime = function(self, btn)
	local store = gStoreManager:GetStoreGroup("RobotFlyerControlsStore"):GetStoreByWidget(btn)

	gCS.LuaUtils.PlayAnimationByName(store.btnFanseAni, UAV_BTN_ANIME.UP)
end

M.InitUIElement = function(self)
	self.bindData.videoFocusCtrls = 3
end

M.HandleSpPhotoTemplate = function(self)
	local template = gTakePhotoUtils.OncePhotoTemplate
	self.bindData.summonCtrl = 0

	if template ~= gTakePhotoUtils.PhotoTemplate.RobDog then
		self.bindData.summonCtrl = 2
	elseif template ~= gTakePhotoUtils.PhotoTemplate.UAV then
		self.bindData.summonCtrl = 1
	elseif template ~= gTakePhotoUtils.PhotoTemplate.Spider then
		self.bindData.summonCtrl = 3
	end
end

M.HideWholePanel = function(self, time)
	slot2 = self.rootGo

	slot2:SetActive(false)

	self.isSwitching = true
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false

	gLuaTimeMgrUtils.Delay(function ()
		if gPanelManager:IsPanelShowing(gPanelId.S_PHOTOGRAPH_GAME_PANEL) then
			self.rootGo:SetActive(true)
		end

		self.isSwitching = false
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end, time)
end

M.UpdateFovByMouseScroll = function(self, op)
	self.bindData.DOFSlider.value = self.bindData.DOFSlider.value + op * self.bindData.DOFSlider.stepSize
end

M.UpdateHudTargetData = function(self)
	if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		return
	end

	if gTakePhotoUtils.UseOldVideoTaskLogic then
		self.vtTemplateStore = self:GetStoreById(self.bindData.videoTargetTemplateTrans.gameObject:GetInstanceID())
		self.gpsTemplateStore = self:GetStoreById(self.bindData.gpsTemplateTrans.gameObject:GetInstanceID())

		if not self.multiTargetData then
			if self.isSwitching or not self.updateHudData then
				self.bindData.videoFocusCtrls = 3
				self.bindData.gpsCtrl = 1
				self.vtTemplateStore.templateVideoFocusCtrl = 3
				self.gpsTemplateStore.templateGpsCtrl = 1

				return
			end

			if self.updateHudData.Type ~= gTakePhotoUtils.PhotoCustomTargetType.Video then
				self.UpdateVideoTarget(self, self.updateHudData)

				self.updateHudData = nil
			end

			return
		end
	end

	if self.isSwitching or not self.multiTargetData then
		self:ResetMultiTargetUI()

		self.bindData.videoFocusCtrls = 3
		local vtTemplateStore = self:GetStoreById(self.bindData.videoTargetTemplateTrans.gameObject:GetInstanceID())
		vtTemplateStore.templateVideoFocusCtrl = 3
		local gpsTemplateStore = self:GetStoreById(self.bindData.gpsTemplateTrans.gameObject:GetInstanceID())
		gpsTemplateStore.templateGpsCtrl = 1

		if not self.multiTargetData then
			gMessageManager:SendMessage(gEventConstants.VIDEO_COUNTDOWN_CONDITION, {
				["*9\r\\xe1v\\x8c\\xd4;\\xa6+\\xef\\xe6\\xef{\\xf5"] = false
			})
		end

		return
	end

	if self.multiTargetData.Type ~= gTakePhotoUtils.PhotoCustomTargetType.MultiVideo then
		self.UpdateVideoMultiTarget(self, self.multiTargetData)

		self.multiTargetData = nil
	end
end
