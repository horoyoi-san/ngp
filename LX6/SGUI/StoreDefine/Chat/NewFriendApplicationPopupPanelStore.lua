-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\NewFriendApplicationPopupPanelStore.lua
-- Decompiled from: 01909_NewFriendApplicationPopupPanelStore.lua_a68d24e56d88.luajit

C_NewFriendApplicationPopupPanelStore = DefClass("C_NewFriendApplicationPopupPanelStore", C_NewFriendApplicationPopupPanelStore, C_ChatNormalPopupPanelStore)
GroupName2Class.NewFriendApplicationPopupPanelStore = C_NewFriendApplicationPopupPanelStore
local M = C_NewFriendApplicationPopupPanelStore

M.OnClick = function(self)
	local data = {
		secondShowType = gChatConst.TabShowType.NewRequest
	}

	gChatUtils.OpenChatPanel(data)
	gPanelManager:Close(self.panelId)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.data = data

	self:AutoClose()

	local pid = data.pid
	slot4 = gChatManager

	slot4:GetImageAvatarConfigByPidWithCallback(pid, function (success, avatarConfig)
		self.bindData.icon = avatarConfig.SguiImageId
	end)
end
