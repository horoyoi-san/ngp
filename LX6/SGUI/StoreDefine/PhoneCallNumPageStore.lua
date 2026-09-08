-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneCallNumPageStore.lua
-- Decompiled from: 02038_PhoneCallNumPageStore.lua_c3f8fee6c9df.luajit

C_PhoneCallNumPageStore = DefClass("C_PhoneCallNumPageStore", C_PhoneCallNumPageStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PhoneCallNumPageStore = C_PhoneCallNumPageStore
local M = C_PhoneCallNumPageStore

M.OnAwake = function(self)
	self.bindData.addContactButton.luaClick = self.CreateAction(self, "OnAddContactClick")
	self.bindData.deleteButton.luaClick = self.CreateAction(self, "OnDeleteClick")
	self.bindData.deleteButton.luaPress = self.CreateAction(self, "OnDeletePressDown")
	self.bindData.deleteButton.luaRelease = self.CreateAction(self, "OnDeletePressUp")
	self.bindData.callPhoneButton.luaClick = self.CreateAction(self, "OnCallPhoneClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.contactButton.luaClick = self.CreateAction(self, "OnContactClick")
	self.numberList = LTConfig.PhoneConfig.ContactPhoneNumberList

	for index = 1, #self.numberList do
		local bindName = ("phoneNumber%d"):format(index)
		self.bindData[bindName].luaClick = self:CreateActionWithArgs("OnPhoneNumberClick", index)
	end

	self.longPressThreshold = LTConfig.PhoneConfig.ContactLongPressThreshold
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self.CreateAction(self, "OnPhoneCallStateChange")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.inputPhoneNumber = ""
	self.longPressTime = 0
end

M.InitView = function(self, _)
	self.RefreshPhoneNumberView(self)
end

M.OnPhoneCallStateChange = function(self)
	self.RefreshPhoneNumberView(self)
end

M.RefreshPhoneNumberView = function(self)
	self.bindData.callButton.isSelected = true
	self.bindData.callPhoneButton.interactable = not gCallPhoneUtils.CheckPhoneCallConflict()
	self.bindData.inputPhoneNumberTips = string.is_null_or_empty(self.inputPhoneNumber)
	self.bindData.phoneNumber = self.inputPhoneNumber
end

M.OnCallPhoneClick = function(self)
	if string.is_null_or_empty(self.inputPhoneNumber) then
		local tips = LTConfig.PhoneConfig.ContactInputPhoneNumberTips

		gDisplayMessageMgr:ShowMessageContent(tips)

		return
	end

	self.ReviewInputPhoneNumber(self, function (phoneNumber)
		gCallPhoneUtils.ShowCallPhoneTimelineDialogPanel(gBattleSpiritMgr.currentSpiritTemplateId, phoneNumber)
	end)
end

M.ReviewInputPhoneNumber = function(self, onPass)
	if self.isReviewingPhoneNumber then
		return
	end

	local phoneNumber = self.inputPhoneNumber
	self.isReviewingPhoneNumber = true

	gCallPhoneUtils.ReviewPhoneNumber(phoneNumber, function ()
		self.isReviewingPhoneNumber = nil

		if self.inputPhoneNumber == phoneNumber then
			return
		end

		onPass(phoneNumber)
	end, function ()
		self.isReviewingPhoneNumber = nil
	end)
end

M.OnPhoneNumberClick = function(self, index)
	if LTConfig.PhoneConfig.ContactNumberMaxLength >= string.len(self.inputPhoneNumber) + 1 then
		local contactNumberMaxLengthTips = LTConfig.PhoneConfig.ContactNumberMaxLengthTips

		gDisplayMessageMgr:ShowMessageContent(contactNumberMaxLengthTips)

		return
	end

	local number = self.numberList[index]
	self.inputPhoneNumber = ("%s%s"):format(self.inputPhoneNumber, number)

	self:RefreshPhoneNumberView()
end

M.OnUpdate = function(self)
	local deleteButton = self.bindData.deleteButton

	if gClientUtils.NotNil(deleteButton) and self.isDeleteLongPress then
		self.longPressTime = self.longPressTime + Time.deltaTime

		if self.longPressThreshold < self.longPressTime then
			self.longPressTime = 0

			self.OnDeleteClick(self)
		end
	end
end

M.OnDeletePressDown = function(self)
	self.checkLongPressCo = coroutine.start(function ()
		coroutine.wait(0.5)

		self.longPressTime = 0
		self.isDeleteLongPress = true
	end)
end

M.OnDeletePressUp = function(self)
	self.checkLongPressCo = coroutine.stop(self.checkLongPressCo)
	self.longPressTime = nil
	self.isDeleteLongPress = nil
end

M.OnAddContactClick = function(self)
	gCallPhoneUtils.ShowEditPanelByAddContact(gBattleSpiritMgr.currentSpiritTemplateId, self.inputPhoneNumber, gClientConst.CallPhoneShowType.Dialing)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE)
end

M.OnDeleteClick = function(self)
	self.inputPhoneNumber = string.sub(self.inputPhoneNumber, 1, -2)

	self.RefreshPhoneNumberView(self)
end

M.OnContactClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_SHOW, {
		secondShowType = gClientConst.CallPhoneShowType.Contact
	})
end

M.ClearData = function(self)
	self.checkLongPressCo = coroutine.stop(self.checkLongPressCo)
	self.longPressTime = nil
	self.isDeleteLongPress = nil
	self.isReviewingPhoneNumber = nil
	self.inputPhoneNumber = ""
end
