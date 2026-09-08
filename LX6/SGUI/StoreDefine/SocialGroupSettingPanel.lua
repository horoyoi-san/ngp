-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialGroupSettingPanel.lua
-- Decompiled from: 01284_SocialGroupSettingPanel.lua_562ca8452ef6.luajit

C_SocialGroupSettingPanel = DefClass("C_SocialGroupSettingPanel", C_SocialGroupSettingPanel, C_StoreGroup)
GroupName2Class.SocialGroupSettingPanel = C_SocialGroupSettingPanel
local M = C_SocialGroupSettingPanel
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.mgr = gSocialChatGroupManager
end

M.OnAwake = function(self)
	self.bindData.input.luaValueChanged = self.CreateAction(self, self.OnGroupNameEdited)
	self.bindData.btnSave.luaClick = self.CreateAction(self, self.OnClickSaveBtn)
	self.bindData.btnDelete.luaClick = self.CreateAction(self, self.OnClickDeleteBtn)
	self.bindData.btnBack.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.btnFullScreen.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.states = {
		["\\x8c</(K\\x9cW\\xdc\\xbe\\xb7"] = true,
		["\\xebP;.\\xd5\\xb3U\\xa4u\\xa4\\xba"] = false
	}
end

M.OnShow = function(self, panelId, data)
	self.groupData = data
	self.groupId = data.Id
	self.groupOwner = data.Owner

	if data.Owner then
		self.bindData.input.readOnly = false

		self.bindData.btnSave:SetActive(true)
	else
		self.bindData.input.readOnly = true

		self.bindData.btnSave:SetActive(false)
	end

	self.bindData.input.text = data.Name

	self.OnGroupNameEdited(self, self.bindData.input.text)
end

M.OnGroupNameEdited = function(self, text)
	local name = string.trim(text)
	local nameLen = string.utf8len(name)
	local showDeleteCtl = nameLen == 0
	local visualLength = LX6.Utils.TextUtils.GetVisualLength(name)
	local showSaveBtn = self.groupOwner and nameLen <= 0 and name == self.groupData.Name and visualLength > LTConfig.FriendsConfig.GroupNameMaxLength

	if LTConfig.FriendsConfig.GroupNameMaxLength >= visualLength then
		self.bindData.showWarningCtl = BOOL2CTL[true]
	else
		self.bindData.showWarningCtl = BOOL2CTL[false]
	end

	if self.states.showDeleteCtl == showDeleteCtl then
		self.bindData.showDeleteCtl = BOOL2CTL[showDeleteCtl]
		self.states.showDeleteCtl = showDeleteCtl
	end

	if self.states.showSaveBtn == showSaveBtn then
		self.bindData.btnSave:SetActive(showSaveBtn)

		self.states.showSaveBtn = showSaveBtn
	end
end

M.OnInputValueChanged = function(self)
end

M.OnClickSaveBtn = function(self)
	local name = string.trim(self.bindData.input.text)
	local nameLen = string.utf8len(name)

	if not self.groupOwner then
		return
	end

	if name ~= self.groupData.Name then
		return
	end

	if nameLen <= 0 then
		slot3 = gClientToAvatarDelegate

		slot3:AskChangeChatGroupName(self.groupId, name).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gPanelManager:Close(gPanelId.SOCIAL_GROUP_SETTING_PANEL)
		end
	end
end

M.OnClickDeleteBtn = function(self)
	self.bindData.input.text = ""
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.SOCIAL_GROUP_SETTING_PANEL)
end
