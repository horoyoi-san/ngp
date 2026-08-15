C_ChatApplicationPanelStore = DefClass("C_ChatApplicationPanelStore", C_ChatApplicationPanelStore, C_ChatBrowserPanelStore)
GroupName2Class.ChatApplicationPanelStore = C_ChatApplicationPanelStore
local M = C_ChatApplicationPanelStore

function M:OnAwake()
	M.base.OnAwake(self)

	self.bindData.showTypeCtrl = 0
	self.bindData.btn.luaClick = self:CreateAction(self.OnApplyBtnClick)
end

function M:OnShow(_, data)
	M.base.OnShow(self, _, data)

	if data.chatID == self.lastShowChatId then
		self.bindData.showTypeCtrl = self.registered and 2 or 0

		return
	end

	self.registered = false
	self.lastShowChatId = data.chatID
end

function M:OnApplyBtnClick()
	if self.registered then
		return
	end

	self.bindData.showTypeCtrl = 1
	self.registered = true

	gClientToGameDelegate:AskFinishNpcChatRegistration(self.data.chatID)
end

function M:OnDestroy()
	self.lastShowChatId = nil
end
