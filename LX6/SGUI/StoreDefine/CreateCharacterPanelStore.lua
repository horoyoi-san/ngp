-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CreateCharacterPanelStore.lua
-- Decompiled from: 01507_CreateCharacterPanelStore.lua_9f71b6dddf2a.luajit

C_CreateCharacterPanelStore = DefClass("C_CreateCharacterPanelStore", C_CreateCharacterPanelStore, C_StoreGroup)
GroupName2Class.CreateCharacterPanelStore = C_CreateCharacterPanelStore
local M = C_CreateCharacterPanelStore

M.ctor = function(self)
	self.maleOpenAni = "S_vx_CreateCharacterPanel_Male_open"
	self.maleOutAni = "S_vx_CreateCharacterPanel_Male_out"
	self.femaleOpenAni = "S_vx_CreateCharacterPanel_Female_open"
	self.femaleOutAni = "S_vx_CreateCharacterPanel_Female_out"
	self.controllerKeyClickAni = "S_vx_CreateCharacterPanel_ControllerKey_click"
end

M.OnAwake = function(self)
	self.sexType = nil
	self.alreadyRequest = false
	self.isSelectCharacter = false
	self.isUsePlayerName = false
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.maleBtn.luaClick = self:CreateAction("OnMaleBtnClick")
	self.bindData.femaleBtn.luaClick = self:CreateAction("OnFemaleBtnClick")
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnConfirmBtnClick")
	self.bindData.checkBtn.luaClick = self:CreateAction("OnCheckBtnClick")
	self.bindData.inputField.characterLimit = 0
	self.bindData.inputField.maxLength = LTConfig.GameConfig.PlayerNameMaxLength
	self.bindData.inputField.enableShortCharMaxLength = true
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputFieldChange")
	self.bindData.inputField.luaExceedLength = self:CreateAction("OnExceedLength")
	self.bindData.inputField.onValidateInput = SGUI.UInputField.OnValidateInput(self.OnValidateNameInput, self)
	self.msgEvents = {
		[gEventConstants.BEGINNER_LOGIN_CREATE_END] = self:CreateAction("BeginnerLoginCreateEnd")
	}

	self:RegisterMessageEvents(self.msgEvents)
	self.bindData.femaleBtn:SetActive(false)
	self.bindData.maleBtn:SetActive(false)
	self.bindData.confirmBtn:SetActive(false)
	self.bindData.inputCtn:SetActive(false)
	self.bindData.warning:SetActive(false)
end

M.OnShow = function(self, panelId, data)
	slot3 = gMessageManager

	slot3:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)

	self.corBtnShow = coroutine.start(function ()
		coroutine.wait(0.5)
		self.bindData.femaleBtn:SetActive(true)
		self.bindData.maleBtn:SetActive(true)
	end)
end

M.OnActiveDeviceChange = function(self, device)
	if SGUI.GameDevice.KeyboardMouse >= device then
		self.ActivateInputField(self)
	end
end

M.OnDestroy = function(self)
	if self.corBtnShow then
		coroutine.stop(self.corBtnShow)

		self.corBtnShow = nil
	end

	if self.corPlayAni then
		coroutine.stop(self.corPlayAni)

		self.corPlayAni = nil
	end

	if self.corClickWait then
		coroutine.stop(self.corClickWait)

		self.corClickWait = nil
	end

	self.ClearMessageEvents(self)
end

M.OnMaleBtnClick = function(self)
	self.sexType = UX.Game.SexType.Male

	self.SelectCharacter(self)
end

M.OnFemaleBtnClick = function(self)
	self.sexType = UX.Game.SexType.Female

	self.SelectCharacter(self)
end

M.SelectCharacter = function(self)
	self.isSelectCharacter = true

	self:PlayClickAnimation()
	self.bindData.femaleBtn:SetActive(false)
	self.bindData.maleBtn:SetActive(false)
	self.bindData.inputCtn:SetActive(true)
	gMessageManager:SendMessage(gEventConstants.CHARACTER_CHOICE, self.sexType)
end

M.ActivateInputField = function(self)
	if not self.bindData.inputField then
		return
	end

	if gCS.LuaUtils.IsPSPlatform() then
		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self.bindData.inputField:ActivateInputField()
end

M.OnCheckBtnClick = function(self)
	self.isUsePlayerName = not self.isUsePlayerName
	self.bindData.usePlayerNameCtrl = self.isUsePlayerName and 1 or 0
end

M.OnConfirmBtnClick = function(self)
	if self.alreadyRequest then
		print_debug("alreadyRequest")

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

			if gLoginManager:CreateRole(userName, self.sexType, self.isUsePlayerName, true) then
				self.alreadyRequest = true
			end
		else
			print_debug("result code is :" .. wait.result.code)
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)
		end
	end)
end

M.ContentIsEmpty = function(self, str)
	for i = 1, #str do
		if string.sub(str, i, i) == "\n" and string.sub(str, i, i) == " " then
			return false
		end
	end

	return true
end

M.OnBackBtnClick = function(self)
	if self.isSelectCharacter then
		self.ReSelect(self)
	else
		gPanelManager:Close(gPanelId.S_CREATE_CHARACTER_PANEL)
		gMessageManager:SendMessage(gEventConstants.RESHOW_LOGING_PANEL)
	end
end

M.ReSelect = function(self)
	self.isSelectCharacter = false

	self.bindData.inputField:DeactivateInputField()

	self.bindData.inputField.text = ""

	if self.sexType ~= UX.Game.SexType.Male then
		self.PlayAnimation(self)
	else
		self.PlayAnimation(self)
	end
end

M.OnInputFieldChange = function(self)
	if self.ContentIsEmpty(self, self.bindData.inputField.text) then
		self.bindData.confirmBtn:SetActive(false)

		return
	end

	self.bindData.confirmBtn:SetActive(true)
end

M.OnValidateNameInput = function(self, text, charIndex, addedChar)
	if addedChar ~= string.byte(" ") then
		return 0
	end

	return addedChar
end

M.OnExceedLength = function(self)
	self.bindData.warning:SetActive(true)
	self.bindData.checkBtn:SetActive(false)

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self.timer = Timer.New(function ()
		if self.bindData.warning then
			self.bindData.warning:SetActive(false)
			self.bindData.checkBtn:SetActive(true)
		end

		self.timer = nil
	end, 1):Start()
end

M.BeginnerLoginCreateEnd = function(self, eventId, data)
	self.bindData.inputField:DeactivateInputField()

	if data then
		Timer.New(function ()
			self.alreadyRequest = false

			gPanelManager:Close(gPanelId.S_CREATE_CHARACTER_PANEL)
		end, 4):Start()
	else
		print_error("#NoCreateIssue 新建角色失败")
	end
end

M.PlayClickAnimation = function(self)
	if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		if self.sexType ~= UX.Game.SexType.Male then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.maleClickAni, self.controllerKeyClickAni)
		else
			gCS.LuaUtils.PlayAnimationByName(self.bindData.famaleClickAni, self.controllerKeyClickAni)
		end

		self.corClickWait = coroutine.start(function ()
			coroutine.wait(0.1)
			self:PlayAnimation()
		end)
	else
		self.PlayAnimation(self)
	end
end

M.PlayAnimation = function(self)
	self.corPlayAni = coroutine.stop(self.corPlayAni)
	local aniName = self.GetAniName(self)
	local clipTime = gCS.LuaUtils.PlayAnimationByName(self.bindData.CreateCharacterAni, aniName)
	self.corPlayAni = coroutine.start(function ()
		coroutine.wait(clipTime)

		if not self.isSelectCharacter then
			self.bindData.femaleBtn:SetActive(true)
			self.bindData.maleBtn:SetActive(true)
			self.bindData.inputCtn:SetActive(false)
		else
			self:ActivateInputField()
		end
	end)
end

M.GetAniName = function(self)
	local aniNames = {
		[true] = {
			[UX.Game.SexType.Female] = self.femaleOpenAni,
			[UX.Game.SexType.Male] = self.maleOpenAni
		},
		[false] = {
			[UX.Game.SexType.Female] = self.femaleOutAni,
			[UX.Game.SexType.Male] = self.maleOutAni
		}
	}

	return aniNames[self.isSelectCharacter][self.sexType]
end
