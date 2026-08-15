C_CreateCharacterPanelStore = DefClass("C_CreateCharacterPanelStore", C_CreateCharacterPanelStore, C_StoreGroup)
GroupName2Class.CreateCharacterPanelStore = C_CreateCharacterPanelStore
local M = C_CreateCharacterPanelStore

function M:ctor()
	self.maleOpenAni = "S_vx_CreateCharacterPanel_Male_open"
	self.maleOutAni = "S_vx_CreateCharacterPanel_Male_out"
	self.femaleOpenAni = "S_vx_CreateCharacterPanel_Female_open"
	self.femaleOutAni = "S_vx_CreateCharacterPanel_Female_out"
	self.controllerKeyClickAni = "S_vx_CreateCharacterPanel_ControllerKey_click"
end

function M:OnAwake()
	self.sexType = nil
	self.alreadyRequest = false
	self.isSelectCharacter = false
	self.isUsePlayerName = true
	self.bindData.usePlayerNameCtrl = self.isUsePlayerName and 0 or 1
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnConfirmBtnClick")
	self.bindData.checkBtn.luaClick = self:CreateAction("OnCheckBtnClick")
	self.bindData.inputField.characterLimit = 0
	self.bindData.inputField.maxLength = LTConfig.GameConfig.PlayerNameMaxLength
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputFieldChange")
	self.bindData.inputField.luaExceedLength = self:CreateAction("OnExceedLength")
	self.msgEvents = {
		[gEventConstants.BEGINNER_LOGIN_CREATE_END] = self:CreateAction("BeginnerLoginCreateEnd")
	}

	self:RegisterMessageEvents(self.msgEvents)
	self.bindData.confirmBtn:SetActive(false)
	self.bindData.warning:SetActive(false)

	self.sexType = UX.Game.SexType.Male
	local name = LTConfig.NpcCultivationConfig.GetConfig(LTConfig.NpcCultivationConfig.DefaultMale).Name
	self.bindData.useNametips = string.format(LTConfig.GameConfig.PlayerNameShowTips, name)
	self.bindData.settingTips = LTConfig.GameConfig.PlayerNameSettingTips
end

function M:OnShow(panelId, data)
	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
end

function M:OnActiveDeviceChange(device)
	if SGUI.GameDevice.KeyboardMouse < device then
		self:ActivateInputField()
	end
end

function M:OnDestroy()
	if self.corBtnShow then
		coroutine.stop(self.corBtnShow)

		self.corBtnShow = nil
	end

	if self.corPlayAni then
		coroutine.stop(self.corPlayAni)

		self.corPlayAni = nil
	end

	self:ClearMessageEvents()
end

function M:OnMaleBtnClick()
	self.sexType = UX.Game.SexType.Male

	self:SelectCharacter()
end

function M:OnFemaleBtnClick()
	self.sexType = UX.Game.SexType.Female

	self:SelectCharacter()
end

function M:SelectCharacter()
	self.isSelectCharacter = true

	self:PlayClickAnimation()
	self.bindData.femaleBtn:SetActive(false)
	self.bindData.maleBtn:SetActive(false)
	self.bindData.inputCtn:SetActive(true)
	gMessageManager:SendMessage(gEventConstants.CHARACTER_CHOICE, self.sexType)
end

function M:ActivateInputField()
	if not self.bindData.inputField then
		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self.bindData.inputField:ActivateInputField()
end

function M:OnCheckBtnClick()
	self.isUsePlayerName = not self.isUsePlayerName
	self.bindData.usePlayerNameCtrl = self.isUsePlayerName and 0 or 1
end

function M:OnConfirmBtnClick()
	if self.alreadyRequest then
		print_debug("alreadyRequest")

		return
	end

	local userName = self.bindData.inputField.text

	if self:ContentIsEmpty(userName) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesNameNone)

		return
	end

	gCoroutineManager:StartCoroutine(function ()
		local wait = EnvSDK.reviewNickNameAsync(userName)

		coroutine.yield(wait)

		if wait.result.code == 200 then
			local result = gCS.GuiUtils.IsInputNameValidNoMsg(userName, LTConfig.GameConfig.PlayerNameMinLength, LTConfig.GameConfig.PlayerNameMaxLength)

			if result ~= 0 then
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

function M:ContentIsEmpty(str)
	for i = 1, #str do
		if string.sub(str, i, i) ~= "\n" and string.sub(str, i, i) ~= " " then
			return false
		end
	end

	return true
end

function M:OnBackBtnClick()
	if self.isSelectCharacter then
		self:ReSelect()
	else
		gPanelManager:Close(gPanelId.S_CREATE_CHARACTER_PANEL)
		gMessageManager:SendMessage(gEventConstants.RESHOW_LOGING_PANEL)
	end
end

function M:ReSelect()
	self.isSelectCharacter = false

	self.bindData.inputField:DeactivateInputField()

	self.bindData.inputField.text = ""

	if self.sexType == UX.Game.SexType.Male then
		self:PlayAnimation()
	else
		self:PlayAnimation()
	end
end

function M:OnInputFieldChange()
	if self:ContentIsEmpty(self.bindData.inputField.text) then
		self.bindData.confirmBtn:SetActive(false)

		return
	end

	self.bindData.confirmBtn:SetActive(true)
end

function M:OnExceedLength()
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

function M:BeginnerLoginCreateEnd(eventId, data)
	self.bindData.inputField:DeactivateInputField()

	if data then
		Timer.New(function ()
			self.alreadyRequest = false

			gPanelManager:Close(gPanelId.S_CREATE_CHARACTER_PANEL)
		end, 4):Start()
	else
		print_error("新建角色失败")
	end
end

function M:PlayClickAnimation()
	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
		if self.sexType == UX.Game.SexType.Male then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.maleClickAni, self.controllerKeyClickAni)
		else
			gCS.LuaUtils.PlayAnimationByName(self.bindData.famaleClickAni, self.controllerKeyClickAni)
		end

		coroutine.start(function ()
			coroutine.wait(0.1)
			self:PlayAnimation()
		end)
	else
		self:PlayAnimation()
	end
end

function M:PlayAnimation()
	local aniName = self:GetAniName()
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

function M:GetAniName()
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
