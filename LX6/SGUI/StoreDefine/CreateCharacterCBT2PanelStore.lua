-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CreateCharacterCBT2PanelStore.lua
-- Decompiled from: 01506_CreateCharacterCBT2PanelStore.lua_70750a746cff.luajit

C_CreateCharacterCBT2PanelStore = DefClass("C_CreateCharacterCBT2PanelStore", C_CreateCharacterCBT2PanelStore, C_StoreGroup)
GroupName2Class.CreateCharacterCBT2PanelStore = C_CreateCharacterCBT2PanelStore
local M = C_CreateCharacterCBT2PanelStore

M.ctor = function(self)
	self.openAni = "S_vx_CreateCharacterPanel_open"
	self.maleOpenAni = "S_vx_CreateCharacterPanel_Male_open"
	self.maleOutAni = "S_vx_CreateCharacterPanel_Male_out"
	self.femaleOpenAni = "S_vx_CreateCharacterPanel_Female_open"
	self.femaleOutAni = "S_vx_CreateCharacterPanel_Female_out"
end

M.DefineAllVariables = function(self)
	self.sexType = UX.Game.SexType.Male
	self.alreadyRequest = false
	self.isUseDefaultName = false
	self.oldInputText = ""
	self.oldInputVisualLength = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()

	self.bindData.inputField.characterLimit = 0
	self.bindData.inputField.enableShortCharMaxLength = true

	self.bindData.confirmBtn:SetActive(false)
	self.bindData.warning:SetActive(false)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	if self.corPlayAni then
		coroutine.stop(self.corPlayAni)

		self.corPlayAni = nil
	end

	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)

	if data and data.sexType then
		self.sexType = data.sexType
	end

	gMessageManager:SendMessage(gEventConstants.CHARACTER_CHOICE, self.sexType)
	self:PlayOpenAnimation()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	if SGUI.GameDevice.KeyboardMouse >= device then
		self.ActivateInputField(self)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.BEGINNER_LOGIN_CREATE_END] = self.CreateAction(self, "BeginnerLoginCreateEnd")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnClickConfirmBtn")
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputFieldInputValueChanged")
	self.bindData.inputField.onValidateInput = SGUI.UInputField.OnValidateInput(self.OnValidateNameInput, self)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(gPanelId.CREATE_CHARACTER_CBT2_PANEL)
	gMessageManager:SendMessage(gEventConstants.RESHOW_LOGING_PANEL)
end

M.OnClickConfirmBtn = function(self)
	if self.alreadyRequest then
		print_debug("CreateCharacterCBT2 alreadyRequest")

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

			if gLoginManager:CreateRole(userName, self.sexType, true, false) then
				self.alreadyRequest = true
			end
		else
			print_debug("CreateCharacterCBT2 result code is :" .. wait.result.code)
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)
		end
	end)
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

	if oldLen >= visualLength and LTConfig.GameConfig.PlayerNameMaxLength >= visualLength then
		self.bindData.inputField.text = oldText

		self.OnExceedLength(self)

		return
	end

	if self.ContentIsEmpty(self, trimmed) then
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

M.PlayOpenAnimation = function(self)
	if not self.bindData.CreateCharacterAni then
		return
	end

	local aniName = self.openAni

	if self.sexType ~= UX.Game.SexType.Male then
		aniName = self.maleOpenAni
	elseif self.sexType ~= UX.Game.SexType.Female then
		aniName = self.femaleOpenAni
	end

	local clipTime = gCS.LuaUtils.PlayAnimationByName(self.bindData.CreateCharacterAni, aniName)

	if self.corPlayAni then
		coroutine.stop(self.corPlayAni)

		self.corPlayAni = nil
	end

	self.corPlayAni = coroutine.start(function ()
		coroutine.wait(clipTime)
		self:ActivateInputField()

		self.corPlayAni = nil
	end)
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

M.ContentIsEmpty = function(self, str)
	for i = 1, #str do
		if string.sub(str, i, i) == "\n" and string.sub(str, i, i) == " " then
			return false
		end
	end

	return true
end

M.OnExceedLength = function(self)
	self.bindData.warning:SetActive(true)

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self.timer = Timer.New(function ()
		if self.bindData and self.bindData.warning then
			self.bindData.warning:SetActive(false)
		end

		self.timer = nil
	end, 1):Start()
end

M.BeginnerLoginCreateEnd = function(self, eventId, data)
	self.bindData.inputField:DeactivateInputField()

	if data then
		Timer.New(function ()
			self.alreadyRequest = false

			gPanelManager:Close(gPanelId.CREATE_CHARACTER_CBT2_PANEL)
		end, 4):Start()
	else
		print_error("#NoCreateIssue CreateCharacterCBT2 新建角色失败")
	end
end
