C_PhoneCallEditContactPageStore = DefClass("C_PhoneCallEditContactPageStore", C_PhoneCallEditContactPageStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PhoneCallEditContactPageStore = C_PhoneCallEditContactPageStore
local M = C_PhoneCallEditContactPageStore
local ShowNoticeControl = {
	Hide = 0,
	Show = 1
}
local EditableControl = {
	Enable = 1,
	Disable = 0
}

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.cancelButton.luaClick = self:CreateAction(self.OnCancelClick)
	self.bindData.confirmButton.luaClick = self:CreateAction(self.OnConfirmClick)
	self.bindData.resetInputNameButton.luaClick = self:CreateAction(self.OnResetInputNameClick)
	self.bindData.resetInputNumberButton.luaClick = self:CreateAction(self.OnResetInputNumberClick)
	self.bindData.inputName.luaExceedLength = self:CreateAction(self.OnOutLimitInputNameCallback)
	self.bindData.inputName.luaValueChanged = self:CreateAction(self.OnInputNameChange)
	self.bindData.inputName.maxLength = LTConfig.PhoneConfig.ContactNameMaxLength
	self.bindData.inputName.onActivateAction = self:CreateAction(self.OnInputFieldActivate)
	self.bindData.inputName.onDeActivateAction = self:CreateAction(self.OnInputFieldDeActivate)
	self.bindData.inputNumber.luaExceedLength = self:CreateAction(self.OnOutLimitInputNumberCallback)
	self.bindData.inputNumber.luaValueChanged = self:CreateAction(self.OnInputNumberChange)
	self.bindData.inputNumber.characterLimit = LTConfig.PhoneConfig.ContactNumberMaxLength
	self.bindData.inputNumber.onActivateAction = self:CreateAction(self.OnInputFieldActivate)
	self.bindData.inputNumber.onDeActivateAction = self:CreateAction(self.OnInputFieldDeActivate)
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_CALL_PHONE_EDIT_CONTACT_SUCCESS] = function (_, contactId)
			if self.contactId == contactId then
				self:OnExit()
			end
		end,
		[gEventConstants.ON_CALL_PHONE_ADD_CONTACT_SUCCESS] = function (_, newContactInfo)
			if not self.contactId then
				local phoneNumber = newContactInfo.PhoneNumber
				local contactId = gCallPhoneUtils.GetContactIdByPhoneNumber(gBattleSpiritMgr.currentSpiritTemplateId, phoneNumber)

				gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_SHOW, {
					isFromEdit = true,
					secondShowType = gClientConst.CallPhoneShowType.Detail,
					contactId = contactId,
					backToShowType = gClientConst.CallPhoneShowType.Contact
				})
			end
		end
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.contactId = args.contactId
end

function M:InitView(args)
	local avatarId = gCallPhoneUtils.GetContactSAvatarId(self.contactId)
	local headStore = gStoreManager:GetStoreGroup("PhoneCallContactHeadTemplateStore"):GetStoreByWidget(self.bindData.headWidget)
	headStore.avatarId = avatarId
	self.bindData.showNameExceedCtrl = ShowNoticeControl.Hide
	self.bindData.showNumberExceedCtrl = ShowNoticeControl.Hide
	local remark = gCallPhoneUtils.GetContactRemark(self.contactId)
	local phoneNumber = self:GetPhoneNumber(args)
	self.bindData.inputName.text = remark
	self.bindData.inputNumber.text = phoneNumber

	self:RefreshShowRemarkClearView()
	self:RefreshShowNumberClearView()
end

function M:PlayPanelAnimation()
	if self.panelArgs then
		local lastShowType = self.panelArgs.lastShowType

		if lastShowType == gClientConst.CallPhoneShowType.Detail then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_PhoneCallEditContactPage_open")
		elseif lastShowType == gClientConst.CallPhoneShowType.Contact or lastShowType == gClientConst.CallPhoneShowType.Dialing then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_PhoneCallEditContactPage_open_NewContact")
		end
	end
end

function M:OnExecuteExitAction()
	if self.panelArgs and self.panelArgs.lastShowType == gClientConst.CallPhoneShowType.Detail then
		local closeAnimationName = "S_Vx_PhoneCallEditContactPage_close"
		local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)
		self.bindData.rootWidget.activeCtrlDelay = clipTime

		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)
	end

	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE)
end

function M:GetPhoneNumber(args)
	if self.contactId then
		local contactInfo = gCallPhoneUtils.GetContactInfoById(gBattleSpiritMgr.currentSpiritTemplateId, self.contactId)

		return contactInfo.PhoneNumber
	else
		return args and args.phoneNumber or ""
	end
end

function M:OnInputNumberChange()
	local inputContent = self.bindData.inputNumber.text
	self.bindData.inputNumber.text = LX6.Extension.StringEx.ReplacePattern(inputContent, "[^0-9*#]", "")
	local isEmpty = string.is_null_or_empty(self.bindData.inputNumber.text)
	self.bindData.showPhoneNumberClear = not isEmpty
end

function M:OnInputNameChange()
	self.bindData.inputName.text = string.trim(self.bindData.inputName.text)

	self:RefreshShowRemarkClearView()
end

function M:RefreshShowRemarkClearView()
	local isEmpty = string.is_null_or_empty(self.bindData.inputName.text)
	self.bindData.showRemarkClear = not isEmpty
end

function M:RefreshShowNumberClearView()
	local isForbidModify = gCallPhoneUtils.CheckIsForbidModifyPhoneNumber(self.contactId)

	if isForbidModify then
		self.bindData.inputNumber.interactable = false
		self.bindData.phoneNumberEditCtrl = EditableControl.Disable
		self.bindData.showPhoneNumberClear = false
	else
		self.bindData.inputNumber.interactable = true
		self.bindData.phoneNumberEditCtrl = EditableControl.Enable
		local isEmpty = string.is_null_or_empty(self.bindData.inputNumber.text)
		self.bindData.showPhoneNumberClear = not isEmpty
	end
end

function M:OnOutLimitInputNameCallback()
	self:ShowNameTips(LTConfig.PhoneConfig.ContactNameMaxLengthTips)
end

function M:ShowNameTips(text)
	self.bindData.showNameExceedCtrl = ShowNoticeControl.Show
	self.bindData.nameTipsText = text
	self.showNameTipsCo = coroutine.stop(self.showNameTipsCo)
	self.showNameTipsCo = coroutine.start(function ()
		coroutine.wait(2)

		self.bindData.showNameExceedCtrl = ShowNoticeControl.Hide
	end)
end

function M:OnOutLimitInputNumberCallback()
	self:ShowNumberTips(LTConfig.PhoneConfig.ContactNumberMaxLengthTips)
end

function M:ShowNumberTips(text)
	self.bindData.showNumberExceedCtrl = ShowNoticeControl.Show
	self.bindData.numberTipText = text
	self.showNumberTipsCo = coroutine.stop(self.showNumberTipsCo)
	self.showNumberTipsCo = coroutine.start(function ()
		coroutine.wait(2)

		self.bindData.showNumberExceedCtrl = ShowNoticeControl.Hide
	end)
end

function M:OnCancelClick()
	self:OnExit()
end

function M:OnConfirmClick()
	local remark = self.bindData.inputName.text
	local phoneNumber = self.bindData.inputNumber.text
	local isContactNameEmpty = string.is_null_or_empty(remark)
	local isPhoneNumberEmpty = string.is_null_or_empty(phoneNumber)

	if isContactNameEmpty or isPhoneNumberEmpty then
		if isContactNameEmpty then
			self:ShowNameTips(LTConfig.PhoneConfig.ContactNameEmptyTips)
		end

		if isPhoneNumberEmpty then
			self:ShowNumberTips(LTConfig.PhoneConfig.ContactNumberEmptyTips)
		end

		return
	end

	if self.contactId then
		gCallPhoneUtils.EditPhoneContact(gBattleSpiritMgr.currentSpiritTemplateId, self.contactId, phoneNumber, remark)
	else
		gCallPhoneUtils.AddPhoneContact(gBattleSpiritMgr.currentSpiritTemplateId, phoneNumber, remark)
	end
end

function M:OnResetInputNameClick()
	self.bindData.inputName.text = ""
end

function M:OnResetInputNumberClick()
	if gCallPhoneUtils.CheckIsForbidModifyPhoneNumber(self.contactId, true) then
		return
	end

	self.bindData.inputNumber.text = ""
end

function M:ClearData()
	self.contactId = nil
	self.showNameTipsCo = coroutine.stop(self.showNameTipsCo)
	self.showNumberTipsCo = coroutine.stop(self.showNumberTipsCo)
end
