-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CreateCharacterV3PanelStore.lua
-- Decompiled from: 01508_CreateCharacterV3PanelStore.lua_798b20636f0b.luajit

C_CreateCharacterV3PanelStore = DefClass("C_CreateCharacterV3PanelStore", C_CreateCharacterV3PanelStore, C_StoreGroup)
GroupName2Class.CreateCharacterV3PanelStore = C_CreateCharacterV3PanelStore
local M = C_CreateCharacterV3PanelStore
local LayerConstants = LX6.Constants.LayerConstants
local GameInputManager = LX6.Manager.GameInputManager
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local CONTENT_OPEN_ANIMATION = "S_vx_CreateCharacterV3Panel_contents_open"
local CONTENT_CLOSE_ANIMATION = "S_vx_CreateCharacterV3Panel_contents_close"

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.sexType = UX.Game.SexType.UnKnow
	self.alreadyRequest = false
	self.isUseDefaultName = false
	self.oldInputText = ""
	self.oldInputVisualLength = 0
	self.withTL = false
	self.canSwitchGender = false
	self.hasPlayedNotifyAni = false
	self.playedContentAniSex = {}
	self.pendingContentOpen = nil
	self.isCharacterContentShown = false
	self.warningAnimationEndTime = 0

	if LX6.TimelineScript.CutsceneManager.Instance then
		self.timeline = gTimelineManager:GetTimeline("Ananta_Openning")
		self.withTL = true
	end
end

M.DefineAllEnumsAutoGen = function(self)
	self.warningCtrlEnum = {
		["\\x80gh"] = 1,
		["i*rL"] = 0
	}
	self.checkBoxSelectedCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isSelectingCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.visiableCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isTypingTextCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.ControllerTipCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.warningCtrlEnum = nil
	self.checkBoxSelectedCtrlEnum = nil
	self.isSelectingCtrlEnum = nil
	self.visiableCtrlEnum = nil
	self.isTypingTextCtrlEnum = nil
	self.ControllerTipCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.bindData.inputField.characterLimit = 0
	self.bindData.isTypingTextCtrl = self.isTypingTextCtrlEnum._false
	self.bindData.warningCtrl = self.warningCtrlEnum.non
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.joystickInputCallback)

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	if self.notifyTimer then
		self.notifyTimer:Stop()

		self.notifyTimer = nil
	end

	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end

	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
	gMessageManager:SendMessage(gEventConstants.CHARACTER_CHOICE, self.sexType)
	self:ClearNameInput()
	self:RefreshDefaultName()
	self.bindData.switchGenderBtn.gameObject:SetActive(self.sexType == UX.Game.SexType.UnKnow)

	self.isCharacterContentShown = not self.withTL

	self:RefreshControllerTip()

	if self.hasPlayedNotifyAni then
		self.canSwitchGender = true

		self.bindData.notifyAni:SetActive(false)
		self:RefreshControllerTip()

		return
	end

	self.canSwitchGender = false

	self.bindData.notifyAni:SetActive(true)

	local animation = self.bindData.notifyAni.anim

	animation:Play()

	if self.notifyTimer then
		self.notifyTimer:Stop()
	end

	self.notifyTimer = Timer.New(function ()
		self.bindData.notifyAni:SetActive(false)

		self.canSwitchGender = true
		self.hasPlayedNotifyAni = true

		self:RefreshControllerTip()

		self.notifyTimer = nil
	end, animation.clip.length):Start()
end

M.OnClose = function(self)
	self.isCharacterContentShown = false

	if self.notifyTimer then
		self.notifyTimer:Stop()

		self.notifyTimer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshControllerTip(self, device)

	if SGUI.GameDevice.KeyboardMouse >= device then
		self.ActivateInputField(self)
	end
end

M.OnJoystickMove = function(self, context)
	if self.sexType == UX.Game.SexType.UnKnow or not self.isCharacterContentShown or not context.performed or context.ReadContextName(context) == "leftStick" then
		return
	end

	local x = context.ReadValueVector2(context).x

	if x >= -0.5 then
		self.SwitchGender(self, UX.Game.SexType.Female)
	elseif x <= 0.5 then
		self.SwitchGender(self, UX.Game.SexType.Male)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.BEGINNER_LOGIN_CREATE_END] = self.CreateAction(self, "BeginnerLoginCreateEnd"),
		[gEventConstants.CREATE_CHARACTER_TL_CAMERA_MOVE_END] = self.CreateAction(self, "OnTLCameraMoveEnd")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.checkBtn.luaClick = self.CreateAction(self, "OnClickCheckBtn")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnClickConfirmBtn")
	self.bindData.switchGenderBtn.luaClick = self.CreateAction(self, "OnClickSwitchGenderBtn")
	self.bindData.fullScreenBtn.luaClick = self.CreateAction(self, "OnClickFullScreenBtn")
	self.joystickInputCallback = self.CreateAction(self, "OnJoystickMove")

	GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.joystickInputCallback)

	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputFieldInputValueChanged")
	self.bindData.inputField.onValidateInput = SGUI.UInputField.OnValidateInput(self.OnValidateNameInput, self)
end

M.OnClickBackBtn = function(self)
	if self.sexType == UX.Game.SexType.UnKnow and self.withTL and not self.timeline:GetGamePlayFeatureMessage("CreateCharFeature", "interactive") then
		return
	end

	if self.sexType ~= UX.Game.SexType.UnKnow then
		if self.withTL then
			self.timeline:StopTimeline()
		end

		gPanelManager:Close(gPanelId.CREATE_CHARACTER_V3_PANEL)
		gPanelManager:CheckShow(gLoginManager:GetCurrentPanelId())
		gMessageManager:SendMessage(gEventConstants.RESHOW_LOGING_PANEL)
	else
		local previousSex = self.sexType
		slot2 = self.bindData.switchGenderBtn.gameObject

		slot2:SetActive(false)
		self:PlayContentCloseAnimation(function ()
			self:ClearNameInput()

			self.bindData.isSelectingCtrl = self.isSelectingCtrlEnum._false
			self.sexType = UX.Game.SexType.UnKnow
			self.isCharacterContentShown = false

			self:RefreshControllerTip()

			if self.withTL then
				self.timeline:DoGamePlayFeature("CreateCharFeature", "chooseNone")
				self.timeline:DoGamePlayFeature("CreateCharFeature", previousSex ~= UX.Game.SexType.Male and "malecancel" or "femalecancel")
			end

			self.bindData.visiableCtrl = self.visiableCtrlEnum.hide
			self.canSwitchGender = true
		end)
	end
end

M.OnClickCheckBtn = function(self)
	self.isUseDefaultName = not self.isUseDefaultName

	if self.isUseDefaultName then
		self.RefreshDefaultName(self)

		self.bindData.checkBoxSelectedCtrl = 1
	else
		self.bindData.checkBoxSelectedCtrl = 0
	end
end

M.OnClickConfirmBtn = function(self)
	if self.alreadyRequest then
		print_debug("CreateCharacterV3 alreadyRequest")

		return
	end

	local userName = self.bindData.inputField.text

	if self.ContentIsEmpty(self, userName) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesNameNone)

		return
	end

	slot2 = gCoroutineManager

	slot2:StartCoroutine(function ()
		local wait = EnvSDK.reviewNickNameAsync(userName)

		coroutine.yield(wait)

		if wait.result.code ~= 200 then
			local result = gCS.GuiUtils.IsInputNameValidNoMsg(userName, LTConfig.GameConfig.PlayerNameMinLength, LTConfig.GameConfig.PlayerNameMaxLength)

			if result == 0 then
				gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.NameInvalid)

				return
			end

			if gLoginManager:CreateRole(userName, self.sexType, self.isUseDefaultName, false) then
				self.alreadyRequest = true
			end
		else
			print_debug("CreateCharacterV3 result code is :" .. wait.result.code)
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)
		end
	end)
end

M.SwitchGender = function(self, targetSex)
	if not self.canSwitchGender then
		return
	end

	if self.withTL and not self.timeline:GetGamePlayFeatureMessage("CreateCharFeature", "interactive") then
		return
	end

	if self.sexType ~= targetSex then
		return
	end

	self:ClearNameInput()
	self.bindData.switchGenderBtn.gameObject:SetActive(true)

	self.bindData.isSelectingCtrl = self.isSelectingCtrlEnum._true
	self.playedContentAniSex = self.playedContentAniSex or {}
	local shouldPlayContentOpen = not self.playedContentAniSex[targetSex]
	self.playedContentAniSex[targetSex] = true

	if self.withTL then
		self.pendingContentOpen = shouldPlayContentOpen and "play" or "show"
	elseif shouldPlayContentOpen then
		self.PlayContentOpenAnimation(self)
	else
		self.ShowContentWithoutAnimation(self)
	end

	if targetSex ~= UX.Game.SexType.Female then
		if self.sexType ~= UX.Game.SexType.UnKnow then
			self.sexType = UX.Game.SexType.Female

			if self.withTL then
				self.timeline:DoGamePlayFeature("CreateCharFeature", "chooseFemale")
				self.timeline:DoGamePlayFeature("CreateCharFeature", "start2female")
			end
		else
			self.sexType = UX.Game.SexType.Female

			if self.withTL then
				self.timeline:DoGamePlayFeature("CreateCharFeature", "chooseFemale")
				self.timeline:DoGamePlayFeature("CreateCharFeature", "male2female")
			end
		end
	elseif self.sexType ~= UX.Game.SexType.UnKnow then
		self.sexType = UX.Game.SexType.Male

		if self.withTL then
			self.timeline:DoGamePlayFeature("CreateCharFeature", "chooseMale")
			self.timeline:DoGamePlayFeature("CreateCharFeature", "start2male")
		end
	else
		self.sexType = UX.Game.SexType.Male

		if self.withTL then
			self.timeline:DoGamePlayFeature("CreateCharFeature", "chooseMale")
			self.timeline:DoGamePlayFeature("CreateCharFeature", "female2male")
		end
	end

	self:RefreshDefaultName()

	self.bindData.visiableCtrl = self.visiableCtrlEnum.hide

	self:RefreshControllerTip()
	gMessageManager:SendMessage(gEventConstants.CHARACTER_CHOICE, self.sexType)
end

M.OnTLCameraMoveEnd = function(self, _, cameraInteractive)
	if cameraInteractive then
		self.bindData.visiableCtrl = self.visiableCtrlEnum.show
		self.isCharacterContentShown = true

		self.RefreshControllerTip(self)

		if self.pendingContentOpen ~= "play" then
			self.pendingContentOpen = nil

			self.PlayContentOpenAnimation(self)
		elseif self.pendingContentOpen ~= "show" then
			self.pendingContentOpen = nil

			self.ShowContentWithoutAnimation(self)
		end
	end
end

M.OnClickSwitchGenderBtn = function(self)
	if self.sexType ~= UX.Game.SexType.UnKnow then
		self.SwitchGender(self, UX.Game.SexType.Male)
	elseif self.sexType ~= UX.Game.SexType.Male then
		self.SwitchGender(self, UX.Game.SexType.Female)
	else
		self.SwitchGender(self, UX.Game.SexType.Male)
	end
end

M.OnClickFullScreenBtn = function(self)
	local camera = gCS.CameraDataMgr.MainCamera

	if not camera then
		return
	end

	local ray = camera.ScreenPointToRay(camera, UnityEngine.Input.mousePosition)
	local playerLayerMask = bit.lshift(1, LayerConstants.Player)
	local hitCount = CSFurnitureManager.RayCastNonAlloc(ray.origin, ray.direction, 100, nil, playerLayerMask, true, 1)

	if hitCount <= 0 then
		local hitInfo = CSFurnitureManager.SortedRayCastList[0]
		local name = string.lower(hitInfo.collider.gameObject.name)

		if string.find(name, "female") then
			self.SwitchGender(self, UX.Game.SexType.Female)
		else
			self.SwitchGender(self, UX.Game.SexType.Male)
		end
	end
end

M.OnInputFieldInputValueChanged = function(self, text)
	local trimmed = string.trim(text)

	if trimmed == text then
		self.bindData.inputField.text = trimmed

		return
	end

	local visualLength = LX6.Utils.TextUtils.GetVisualLength(trimmed)
	local oldText = self.oldInputText
	local oldLen = self.oldInputVisualLength
	self.oldInputText = trimmed
	self.oldInputVisualLength = visualLength

	if oldLen >= visualLength and LTConfig.GameConfig.PlayerNameMaxLength < visualLength then
		self.OnExceedLength(self)

		if LTConfig.GameConfig.PlayerNameMaxLength >= visualLength then
			self.bindData.inputField.text = oldText

			return
		end
	end

	if self.ContentIsEmpty(self, text) or self.sexType ~= UX.Game.SexType.UnKnow then
		self.bindData.isTypingTextCtrl = self.isTypingTextCtrlEnum._false

		return
	end

	self.bindData.isTypingTextCtrl = self.isTypingTextCtrlEnum._true
end

M.OnValidateNameInput = function(self, text, charIndex, addedChar)
	if addedChar ~= string.byte(" ") then
		return 0
	end

	return addedChar
end

M.ClearNameInput = function(self)
	self.isUseDefaultName = false
	self.bindData.inputField.text = ""
	self.bindData.checkBoxSelectedCtrl = 0
end

M.RefreshDefaultName = function(self)
	self.isSettingText = true
	local NpcCultivationConfig = LTConfig.NpcCultivationConfig
	local name = nil

	if self.sexType ~= UX.Game.SexType.Male then
		name = NpcCultivationConfig.GetConfig(NpcCultivationConfig.DefaultMale).Name
	else
		name = NpcCultivationConfig.GetConfig(NpcCultivationConfig.DefaultFemale).Name
	end

	self.bindData.nameDesc = string.format(LTConfig.GameConfig.PlayerNameTip, name)
	self.isSettingText = false
end

M.ActivateInputField = function(self)
	if gCS.LuaUtils.IsPSPlatform() then
		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self.bindData.inputField:ActivateInputField()
end

M.RefreshControllerTip = function(self, device)
	device = device or gCS.LuaUtils.GetActiveDevice()
	local showControllerTip = self.isCharacterContentShown and self.canSwitchGender and self.sexType ~= UX.Game.SexType.UnKnow and SGUI.GameDevice.KeyboardMouse <= device
	self.bindData.ControllerTipCtrl = showControllerTip and self.ControllerTipCtrlEnum._true or self.ControllerTipCtrlEnum._false

	if showControllerTip then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navigationArea

		self.bindData.navigationArea:RefreshGamePadBar()
	end
end

M.ContentIsEmpty = function(self, str)
	for i = 1, #str do
		if string.sub(str, i, i) == "\n" and string.sub(str, i, i) == " " then
			return false
		end
	end

	return true
end

M.OnExceedLength = function(self)
	local inputFeedbackText = self.bindData.inputFeedbackText

	if not inputFeedbackText.activation then
		self.bindData:Commit("warningCtrl", self.warningCtrlEnum.non, COMMIT_IMMEDIATELY)
		self.bindData:Commit("warningCtrl", self.warningCtrlEnum.show, COMMIT_IMMEDIATELY)
	end

	if self.warningAnimationEndTime < Time.time then
		StartCoroutine(function ()
			WaitForEndOfFrame()
			inputFeedbackText.anim:Play()
		end)

		self.warningAnimationEndTime = Time.time + inputFeedbackText.anim.clip.length
	end

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self.timer = Timer.New(function ()
		self.bindData.warningCtrl = self.warningCtrlEnum.non
		self.warningAnimationEndTime = 0
		self.timer = nil
	end, 1):Start()
end

M.PlayContentCloseAnimation = function(self, callback)
	self.canSwitchGender = false
	local animation = self.bindData.contentANi.anim

	animation:Play(CONTENT_CLOSE_ANIMATION)

	self.closeTimer = Timer.New(function ()
		self.closeTimer = nil

		callback()
	end, animation:GetClip(CONTENT_CLOSE_ANIMATION).length):Start()
end

M.PlayContentOpenAnimation = function(self)
	self.bindData.contentANi.gameObject:SetActive(true)
	self.bindData.contentANi.anim:Play(CONTENT_OPEN_ANIMATION)
end

M.ShowContentWithoutAnimation = function(self)
	self.bindData.contentANi.gameObject:SetActive(true)

	local animation = self.bindData.contentANi.anim

	gCS.LuaUtils.SampleTargetAnimation(animation, CONTENT_OPEN_ANIMATION, animation:GetClip(CONTENT_OPEN_ANIMATION).length)
end

M.BeginnerLoginCreateEnd = function(self, eventId, data)
	self.bindData.inputField:DeactivateInputField()

	if data then
		self.PlayContentCloseAnimation(self, function ()
			self.alreadyRequest = false

			gPanelManager:Close(gPanelId.CREATE_CHARACTER_V3_PANEL)
		end)
	else
		print_error("#NoCreateIssue CreateCharacterV3 新建角色失败")
	end
end
