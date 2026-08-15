C_PhoneCallNumPageStore = DefClass("C_PhoneCallNumPageStore", C_PhoneCallNumPageStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PhoneCallNumPageStore = C_PhoneCallNumPageStore
local M = C_PhoneCallNumPageStore

function M:OnAwake()
	self.bindData.addContactButton.luaClick = self:CreateAction("OnAddContactClick")
	self.bindData.deleteButton.luaClick = self:CreateAction("OnDeleteClick")
	self.bindData.deleteButton.luaPress = self:CreateAction("OnDeletePressDown")
	self.bindData.deleteButton.luaRelease = self:CreateAction("OnDeletePressUp")
	self.bindData.callPhoneButton.luaClick = self:CreateAction("OnCallPhoneClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.contactButton.luaClick = self:CreateAction("OnContactClick")
	self.numberList = LTConfig.PhoneConfig.ContactPhoneNumberList

	for index = 1, #self.numberList do
		local bindName = ("phoneNumber%d"):format(index)
		self.bindData[bindName].luaClick = self:CreateActionWithArgs("OnPhoneNumberClick", index)
	end

	self.longPressThreshold = LTConfig.PhoneConfig.ContactLongPressThreshold
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self:CreateAction("OnPhoneCallStateChange")
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.inputPhoneNumber = ""
	self.longPressTime = 0
end

function M:InitView(_)
	self:RefreshPhoneNumberView()
end

function M:OnPhoneCallStateChange()
	self:RefreshPhoneNumberView()
end

function M:RefreshPhoneNumberView()
	self.bindData.callButton.isSelected = true
	self.bindData.callPhoneButton.interactable = not gCallPhoneUtils.CheckPhoneCallConflict()
	self.bindData.inputPhoneNumberTips = string.is_null_or_empty(self.inputPhoneNumber)
	self.bindData.phoneNumber = self.inputPhoneNumber
end

function M:OnCallPhoneClick()
	if string.is_null_or_empty(self.inputPhoneNumber) then
		local tips = LTConfig.PhoneConfig.ContactInputPhoneNumberTips

		gDisplayMessageMgr:ShowMessageContent(tips)

		return
	end

	gCallPhoneUtils.ShowCallPhoneTimelineDialogPanel(gBattleSpiritMgr.currentSpiritTemplateId, self.inputPhoneNumber)
end

function M:OnPhoneNumberClick(index)
	if LTConfig.PhoneConfig.ContactNumberMaxLength < string.len(self.inputPhoneNumber) + 1 then
		local contactNumberMaxLengthTips = LTConfig.PhoneConfig.ContactNumberMaxLengthTips

		gDisplayMessageMgr:ShowMessageContent(contactNumberMaxLengthTips)

		return
	end

	local number = self.numberList[index]
	self.inputPhoneNumber = ("%s%s"):format(self.inputPhoneNumber, number)

	self:RefreshPhoneNumberView()
end

function M:OnUpdate()
	local deleteButton = self.bindData.deleteButton

	if gClientUtils.NotNil(deleteButton) and self.isDeleteLongPress then
		self.longPressTime = self.longPressTime + Time.deltaTime

		if self.longPressThreshold <= self.longPressTime then
			self.longPressTime = 0

			self:OnDeleteClick()
		end
	end
end

function M:OnDeletePressDown()
	self.checkLongPressCo = coroutine.start(function ()
		coroutine.wait(0.5)

		self.longPressTime = 0
		self.isDeleteLongPress = true
	end)
end

function M:OnDeletePressUp()
	self.checkLongPressCo = coroutine.stop(self.checkLongPressCo)
	self.longPressTime = nil
	self.isDeleteLongPress = nil
end

function M:OnAddContactClick()
	gCallPhoneUtils.ShowEditPanelByAddContact(gBattleSpiritMgr.currentSpiritTemplateId, self.inputPhoneNumber, gClientConst.CallPhoneShowType.Dialing)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE)
end

function M:OnDeleteClick()
	self.inputPhoneNumber = string.sub(self.inputPhoneNumber, 1, -2)

	self:RefreshPhoneNumberView()
end

function M:OnContactClick()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_SHOW, {
		secondShowType = gClientConst.CallPhoneShowType.Contact
	})
end

function M:ClearData()
	self.checkLongPressCo = coroutine.stop(self.checkLongPressCo)
	self.longPressTime = nil
	self.isDeleteLongPress = nil
end
