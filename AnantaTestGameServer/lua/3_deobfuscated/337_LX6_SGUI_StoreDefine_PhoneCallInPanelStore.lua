C_PhoneCallInPanelStore = DefClass("C_PhoneCallInPanelStore", C_PhoneCallInPanelStore, C_StoreGroup)
GroupName2Class.PhoneCallInPanelStore = C_PhoneCallInPanelStore
local M = C_PhoneCallInPanelStore
local PhoneCallControl = {
	ReCall = 2,
	InCall = 1
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.acceptButton.luaClick = self:CreateAction(self.OnAcceptClick)
	self.bindData.refuseButton.luaClick = self:CreateAction(self.OnRefuseClick)
	self.bindData.recallButton.luaClick = self:CreateAction(self.OnRecallClick)
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self.hasAccept = nil
	self.hasDestroy = true
	self.checkTimeOutCo = coroutine.stop(self.checkTimeOutCo)
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, args)
	self.panelId = panelId

	self:InitModel(args)
	self:InitView()
end

function M:InitModel(args)
	self.hasDestroy = nil
	self.hasAccept = nil
	self.contactOptionId = args.contactOptionId
end

function M:InitView()
	self.bindData.pageTabCtrl = 1
	self.bindData.showModelCtrl = 0
	self.bindData.phoneCallCtrl = PhoneCallControl.InCall

	self:RefreshView()
	self:StartCheckTimeOut()
end

function M:StartCheckTimeOut()
	self.checkTimeOutCo = coroutine.start(function ()
		coroutine.wait(LTConfig.PhoneConfig.PhoneCallInWaitAnswerTime)

		self.bindData.phoneCallCtrl = PhoneCallControl.ReCall

		coroutine.wait(LTConfig.PhoneConfig.PhoneCallInWaitRecallTime)
		self:ClosePanel()
	end)
end

function M:RefreshView()
	local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(self.contactOptionId)
	self.bindData.avatarId = gCallPhoneUtils.GetSAvatarByConfigId(contactOptionCfg.ContactId)
	self.bindData.name = gCallPhoneUtils.GetContactNameByConfigId(contactOptionCfg.ContactId)
end

function M:OnRefuseClick()
	self:ClosePanel()
end

function M:OnAcceptClick()
	if self.hasAccept then
		return
	end

	self.hasAccept = true
	local contactOptionCfg = LTConfig.PhoneContactOptionConfig.GetConfig(self.contactOptionId)
	local dialogId = contactOptionCfg.UnlockDialogId
	local dialogParams = gDialogManager:CreateDialogParam()
	dialogParams.ConnectAnim = false

	gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Phone, nil, dialogParams, nil)
	self:ClosePanel()
end

function M:OnRecallClick()
	self:OnAcceptClick()
end

function M:ClosePanel()
	gPanelManager:Close(self.panelId)
end
