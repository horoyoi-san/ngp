local TextConfig = LTConfig.TextConfig
C_ChatCreateGroupPanelStore = DefClass("C_ChatCreateGroupPanelStore", C_ChatCreateGroupPanelStore, C_AppFragmentStore)
GroupName2Class.ChatCreateGroupPanelStore = C_ChatCreateGroupPanelStore
local M = C_ChatCreateGroupPanelStore

function M:OnAwake()
	self.bindData.input.characterLimit = 0
	self.bindData.input.maxLength = LTConfig.GameConfig.PlayerNameMaxLength
	self.bindData.input.luaValueChanged = self:CreateAction("OnInputFieldChange")
	self.bindData.input.luaExceedLength = self:CreateAction("OnExceedLength")
	self.bindData.comfirmBtn.luaClick = self:CreateAction("OnComfirmBtnClick")
	self.bindData.emptyBtn.luaClick = self:CreateAction("OnEmptyBtnClick")
end

function M:OnInputFieldChange()
	if self:ContentIsEmpty(self.bindData.input.text) then
		self.bindData.comfirmBtn:SetActive(false)
		self.bindData.emptyBtn:SetActive(false)

		return
	end

	self.bindData.comfirmBtn:SetActive(true)
	self.bindData.emptyBtn:SetActive(true)
end

function M:ContentIsEmpty(str)
	for i = 1, #str do
		if string.sub(str, i, i) ~= "\n" and string.sub(str, i, i) ~= " " then
			return false
		end
	end

	return true
end

function M:OnExceedLength()
	self.bindData.showNotice = 1

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self.timer = Timer.New(function ()
		if self.bindData.showNotice then
			self.bindData.showNotice = 0
		end

		self.timer = nil
	end, 1):Start()
end

function M:OnComfirmBtnClick()
	if self:ContentIsEmpty(self.bindData.input.text) then
		return
	end

	gClientToAvatarDelegate:AskCreateChatGroup(self.bindData.input.text).Callback = function (errorId, msg)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self:OnCreateChatGroup()
	end
end

function M:OnCreateChatGroup()
	self.activity:CloseCurrentFragment()
	gChatUtils.ShowPhoneAppTip(TextConfig.GetConfig(TextConfig.CreateChatGroup).Text)
end

function M:OnEmptyBtnClick()
	self.bindData.input.text = ""
end
