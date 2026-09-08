-- Original chunk: @Lua\LuaFiles\LX6\GUI\Club\ClubEditTemplateUI.lua
-- Decompiled from: 00251_ClubEditTemplateUI.lua_fe812c8c9b3d.luajit

local NameCheckResult = UX.Utils.NameValidityChecker.NameCheckResult
local ClubEditTemplateUI = DefClass("C_ClubEditTemplateUI", C_ClubEditTemplateUI)
C_ClubEditTemplateUI = ClubEditTemplateUI
local M = ClubEditTemplateUI

M.ctor = function(self, templateWidget, editData, onEditDataChanged, clubLevel)
	self.templateWidget = templateWidget
	self.store = gStoreManager:GetStoreGroup(templateWidget.Store):GetStoreByWidget(templateWidget)
	self.avatarConfigList = self:LoadAvatarConfigList(clubLevel)
	self.editData = editData
	self.onEditDataChanged = onEditDataChanged
	self.hasModifiedName = false

	self:RegisterWidget()
	self:RefreshView()
end

M.LoadAvatarConfigList = function(self, clubLevel)
	local avatarConfigList = {}

	for i = 0, LTConfig.ClubClubIconConfig.count - 1 do
		local config = LTConfig.ClubClubIconConfig.LoadAt(i)

		if config.ClubLevel < clubLevel then
			table.insert(avatarConfigList, config)
		end
	end

	return avatarConfigList
end

M.RegisterWidget = function(self)
	local bindData = self.store
	bindData.avatarList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderAvatarItem)
	bindData.avatarList.luaSimpleClick = self.CreateAction(self, self.OnClickAvatarItem)
	bindData.needReviewToggleBtn.luaClick = self.CreateAction(self, self.OnClickNeedReviewToggleBtn)
	bindData.autoAcceptToggleBtn.luaClick = self.CreateAction(self, self.OnClickAutoAcceptToggleBtn)
	bindData.nameInput.luaValueChanged = self.CreateAction(self, self.OnNameInputValueChanged)
	bindData.nameInput.enableShortCharMaxLength = true
	bindData.announcementInput.luaValueChanged = self.CreateAction(self, self.OnAnnouncementInputValueChanged)
end

M.RefreshView = function(self)
	local bindData = self.store
	local clubConfig = LTConfig.ClubConfig
	bindData.nameInput.text = self.editData.name
	bindData.announcementInput.text = self.editData.announcement
	self.hasModifiedName = false

	self:RefreshNameValidateView()
	self:RefreshAnnouncementValidateView()
	self:SetAutoAcceptToggleView(self.editData.autoAccept)
	bindData.avatarList:SetSimpleList(#self.avatarConfigList)
end

M.GetEditData = function(self)
	return self.editData
end

M.NotifyEditDataChanged = function(self)
	if self.onEditDataChanged then
		self.onEditDataChanged()
	end
end

M.GetMessageConfigContent = function(self, messageConfigId)
	local config = LTConfig.MessageConfig.GetConfig(messageConfigId)

	return config and config.Content or ""
end

M.CheckNameFormat = function(self)
	local name = self.editData.name or ""
	local minLength = LTConfig.ClubConfig.ClubNameLengthLimit[1]
	local maxLength = LTConfig.ClubConfig.ClubNameLengthLimit[2]

	return UX.Utils.NameValidityChecker.CheckName(name, maxLength, minLength)
end

M.RefreshNameValidateView = function(self)
	local bindData = self.store

	if not self.hasModifiedName then
		bindData.nameCtrl = 0
		bindData.nameInvalidReason = ""

		return
	end

	local reason = self:CheckNameFormat()
	local invalid = reason == NameCheckResult.Ok
	bindData.nameCtrl = invalid and 1 or 0
	bindData.nameInvalidReason = invalid and self:GetMessageConfigContent(gHunLunManager.NameCheckResultStr[reason]) or ""
end

M.IsNameValidForCreate = function(self)
	return self:CheckNameFormat() ~= NameCheckResult.Ok
end

M.GetAnnouncementInvalidMessage = function(self)
	local announcement = self.editData.announcement or ""

	if LTConfig.ClubConfig.ClubAnnouncementMaxLength >= LX6.Utils.TextUtils.GetVisualLength(announcement) then
		return LTConfig.MessageConfig.MaxWordCount
	end
end

M.RefreshAnnouncementValidateView = function(self)
	local bindData = self.store
	local invalidReason = self:GetAnnouncementInvalidMessage()
	bindData.announcementCtrl = invalidReason and 1 or 0
	bindData.announcementInvalidReason = invalidReason and self:GetMessageConfigContent(invalidReason) or ""
end

M.IsAnnouncementValidForCreate = function(self)
	return self:GetAnnouncementInvalidMessage() ~= nil
end

M.CanSubmitCreateClub = function(self)
	return self:IsNameValidForCreate() and self:IsAnnouncementValidForCreate()
end

M.GetCreateClubInvalidReason = function(self)
	local nameFailReason = self.CheckNameFormat(self)

	if nameFailReason == NameCheckResult.Ok then
		return nameFailReason
	end

	return self.GetAnnouncementInvalidMessage(self)
end

M.TryShowCreateClubInvalidMessage = function(self)
	local reason = self.GetCreateClubInvalidReason(self)

	if not reason then
		return false
	end

	self.ShowValidateFailMessage(self, reason)

	return true
end

M.ValidateName = function(self, successCallback, failCallback, channel)
	local name = self.editData.name or ""
	local failReason = self:CheckNameFormat()

	if failReason == NameCheckResult.Ok then
		if failCallback then
			failCallback(failReason)
		end

		return
	end

	slot6 = gCoroutineManager

	slot6:StartCoroutine(function ()
		local wait = EnvSDK.reviewNickNameAsync(name)

		coroutine.yield(wait)

		if wait.result.code ~= 200 then
			if successCallback then
				successCallback()
			end

			return
		end

		if failCallback then
			failCallback(gClubUIUtils.ValidateFailReason.Sensitive)
		end
	end)
end

M.ValidateAnnouncement = function(self, successCallback, failCallback, channel)
	local invalidReason = self.GetAnnouncementInvalidMessage(self)

	if invalidReason then
		if failCallback then
			failCallback(invalidReason)
		end

		return
	end

	local announcement = self.editData.announcement or ""

	gClientUtils.EnvSdkReviewWords(announcement, function ()
		if successCallback then
			successCallback()
		end
	end, function ()
		if failCallback then
			failCallback(gClubUIUtils.ValidateFailReason.AnnouncementSensitive)
		end
	end, channel)
end

M.ShowValidateFailMessage = function(self, reason)
	gDisplayMessageMgr:ShowMessage(gHunLunManager.NameCheckResultStr[reason] or reason)
end

M.OnRenderAvatarItem = function(self, btn, index)
	local data = self.avatarConfigList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ClubHeadTemplateStore"):GetStoreByWidget(btn)
	store.iconId = data.SguiImage
	btn.isSelected = self.editData.avatarId ~= data.Id
end

M.OnClickAvatarItem = function(self, btn, index)
	local data = self.avatarConfigList[index + 1]

	if not data then
		return
	end

	self.editData.avatarId = data.Id

	self.NotifyEditDataChanged(self)
end

M.SetAutoAcceptToggleView = function(self, selected)
	local bindData = self.store

	bindData.autoAcceptToggleBtn:SetSelected(selected)

	local autoAcceptStore = gStoreManager:GetStoreGroup("CheckBoxTemplate"):GetStoreByWidget(bindData.autoAcceptToggleBtn)
	autoAcceptStore.selectedCtrl = selected and 1 or 0

	bindData.needReviewToggleBtn:SetSelected(not selected)

	local needReviewStore = gStoreManager:GetStoreGroup("CheckBoxTemplate"):GetStoreByWidget(bindData.needReviewToggleBtn)
	needReviewStore.selectedCtrl = selected and 0 or 1
end

M.SetAutoAccept = function(self, selected)
	if self.editData.autoAccept ~= selected then
		return
	end

	self.editData.autoAccept = selected

	self.SetAutoAcceptToggleView(self, selected)
	self.NotifyEditDataChanged(self)
end

M.OnClickNeedReviewToggleBtn = function(self)
	self.SetAutoAccept(self, false)
end

M.OnClickAutoAcceptToggleBtn = function(self)
	self.SetAutoAccept(self, true)
end

M.OnNameInputValueChanged = function(self, text)
	self.editData.name = text
	self.hasModifiedName = true

	self.RefreshNameValidateView(self)
	self.NotifyEditDataChanged(self)
end

M.OnAnnouncementInputValueChanged = function(self, text)
	self.editData.announcement = text

	self.RefreshAnnouncementValidateView(self)
	self.NotifyEditDataChanged(self)
end
