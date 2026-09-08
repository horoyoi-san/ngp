-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Club\ClubEditPanelStore.lua
-- Decompiled from: 01261_ClubEditPanelStore.lua_f0e27903a7c9.luajit

C_ClubEditPanelStore = DefClass("C_ClubEditPanelStore", C_ClubEditPanelStore, C_StoreGroup)
GroupName2Class.ClubEditPanelStore = C_ClubEditPanelStore
local M = C_ClubEditPanelStore

M.OnAwake = function(self)
	self.Init(self)
	self.RegisterWidget(self)
end

M.Init = function(self)
	self.instance = {}
end

M.OnShow = function(self, panelId, data)
	self.instance.clubId = data
	local clubInfo = gClubManager:GetClubInfo()
	self.instance.originalData = gClubUIUtils:BuildClubEditData(clubInfo)
	self.instance.editData = gClubUIUtils:CloneClubEditData(self.instance.originalData)
	self.instance.templateUI = C_ClubEditTemplateUI.new(self.bindData.clubEditTemplate, self.instance.editData, nil, gClubUIUtils:GetClubLevelDisplayData(clubInfo))
end

M.OnDestroy = function(self)
	self.instance = nil
end

M.RegisterWidget = function(self)
	self.bindData.submitBtn.luaClick = self.CreateAction(self, self.OnSubmitBtnClick)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, self.OnCancelBtnClick)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnCancelBtnClick)
end

M.OnSubmitSuccess = function(self)
	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.ClubEditSuccess)
	self:ClosePanel()
end

M.GetValidateFailCallback = function(self)
	return self.instance.templateUI:CreateAction(self.instance.templateUI.ShowValidateFailMessage)
end

M.ValidateSubmitData = function(self, dirty, successCallback)
	local failCallback = self.GetValidateFailCallback(self)

	if dirty.name then
		slot4 = self.instance.templateUI

		slot4:ValidateName(function ()
			self:ValidateAnnouncementIfNeeded(dirty, successCallback)
		end, failCallback, "ClubEditPanel")

		return
	end

	self.ValidateAnnouncementIfNeeded(self, dirty, successCallback)
end

M.ValidateAnnouncementIfNeeded = function(self, dirty, successCallback)
	if dirty.declaration then
		self.instance.templateUI:ValidateAnnouncement(successCallback, self:GetValidateFailCallback(), "ClubEditPanel")

		return
	end

	if successCallback then
		successCallback()
	end
end

M.SubmitDirtyEditData = function(self, editData, dirty)
	if not dirty.name and not dirty.declaration and not dirty.icon and not dirty.setting then
		self.OnSubmitSuccess(self)

		return
	end

	slot3 = gClubManager
	slot9 = gClubManager

	slot3:AskChangeClubSettings(editData.name, editData.announcement, editData.avatarId, slot9:BuildClubSetting(editData.autoAccept), function (err)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		self:OnSubmitSuccess()
	end)
end

M.OnSubmitBtnClick = function(self)
	local editData = self.instance.templateUI:GetEditData()
	local dirty = {
		name = self.instance.originalData.name == editData.name,
		declaration = self.instance.originalData.announcement == editData.announcement,
		icon = self.instance.originalData.avatarId == editData.avatarId,
		setting = self.instance.originalData.autoAccept == editData.autoAccept
	}

	if not dirty.name and not dirty.declaration and not dirty.icon and not dirty.setting then
		self.ClosePanel(self)

		return
	end

	self.ValidateSubmitData(self, dirty, function ()
		self:SubmitDirtyEditData(editData, dirty)
	end)
end

M.OnCancelBtnClick = function(self)
	self.ClosePanel(self)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.m_Id)
end
