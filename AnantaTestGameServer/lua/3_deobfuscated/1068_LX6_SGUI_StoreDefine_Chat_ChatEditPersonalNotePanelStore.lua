C_ChatEditPersonalNotePanelStore = DefClass("C_ChatEditPersonalNotePanelStore", C_ChatEditPersonalNotePanelStore, C_AppFragmentStore)
GroupName2Class.ChatEditPersonalNotePanelStore = C_ChatEditPersonalNotePanelStore
local M = C_ChatEditPersonalNotePanelStore

function M:OnAwake()
	self.bindData.cancelBtn.luaClick = self:CreateAction(self.OnCancelBtnClick)
	self.bindData.confirmBtn.luaClick = self:CreateAction(self.OnConfirmBtnClick)
end

function M:OnShow(_, data)
	self.bindData.inputField.text = gChatUtils.GetMySignature()
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnEnable()
	gLuaDataManager.guiMgr.sguiJoystick.Visible = false
end

function M:OnDisable()
	gLuaDataManager.guiMgr.sguiJoystick.Visible = true
end

function M:OnCancelBtnClick()
	self:Close()
end

function M:OnConfirmBtnClick()
	local sign = self.bindData.inputField.text:gsub("\\n", "\\\\n")

	gHunLunManager:ChangeSign(sign, function ()
		gMessageManager:SendMessage(gEventConstants.PLAYER_SIGN_CHANGED, sign)
		self:Close()
	end)
end

function M:Close()
	self.activity:CloseCurrentFragment()
end
