C_NewFriendApplicationPopupPanelStore = DefClass("C_NewFriendApplicationPopupPanelStore", C_NewFriendApplicationPopupPanelStore, C_ChatNormalPopupPanelStore)
GroupName2Class.NewFriendApplicationPopupPanelStore = C_NewFriendApplicationPopupPanelStore
local M = C_NewFriendApplicationPopupPanelStore

function M:OnClick()
	local data = {
		secondShowType = gChatConst.TabShowType.NewRequest
	}

	gChatUtils.OpenChatPanel(data)
	gPanelManager:Close(self.panelId)
end

function M:OnShow(panelId, data)
	self.panelId = panelId
	self.data = data

	self:AutoClose()

	local pid = data.pid

	gChatManager:GetImageAvatarConfigByPidWithCallback(pid, function (success, avatarConfig)
		self.bindData.icon = avatarConfig.SguiImageId
	end)
end
