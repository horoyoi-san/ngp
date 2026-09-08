-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneCallContactDetailPageStore.lua
-- Decompiled from: 02034_PhoneCallContactDetailPageStore.lua_88f7c65491c5.luajit

C_PhoneCallContactDetailPageStore = DefClass("C_PhoneCallContactDetailPageStore", C_PhoneCallContactDetailPageStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PhoneCallContactDetailPageStore = C_PhoneCallContactDetailPageStore
local M = C_PhoneCallContactDetailPageStore
local ShowTypeControl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.chatButton.luaClick = self.CreateAction(self, self.OnChatClick)
	self.bindData.callButton.luaClick = self.CreateAction(self, self.OnCallClick)
	self.bindData.deleteButton.luaClick = self.CreateAction(self, self.OnDeleteClick)
	self.bindData.editButton.luaClick = self.CreateAction(self, self.OnEditClick)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_CALL_PHONE_DELETE_CONTACT_SUCCESS] = function (_, contactId)
			if contactId ~= self.contactId then
				local messageConfigId = LTConfig.MessageConfig.PhoneCallContactsDeleted
				local messageCfg = LTConfig.MessageConfig.GetConfig(messageConfigId)
				local tips = messageCfg.Content:format(self.remark)

				gDisplayMessageMgr:ShowMessageContent(tips)
				self:OnExit()
			end
		end,
		[gEventConstants.ON_CALL_PHONE_EDIT_CONTACT_SUCCESS] = function (_, contactId)
			if self.contactId ~= contactId then
				self:RefreshView()
			end
		end,
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self.CreateAction(self, "OnPhoneCallStateChange")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.backToShowType = args.backToShowType
	local contactId = args.contactId
	self.contactId = contactId
	self.remark = gCallPhoneUtils.GetContactRemark(contactId)
	self.chatNpcId = gCallPhoneUtils.GetChatNpcId(contactId)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.RefreshView(self)
end

M.OnPhoneCallStateChange = function(self)
	self.RefreshView(self)
end

M.PlayPanelAnimation = function(self)
	if self.panelArgs then
		if self.panelArgs.lastShowType ~= gClientConst.CallPhoneShowType.Contact then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_PhoneCallContactDetailPage_toLeft")
		elseif self.panelArgs.lastShowType ~= gClientConst.CallPhoneShowType.Edit then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_PhoneCallContactDetailPage_fromEdit")
		end
	end
end

M.OnExecuteExitAction = function(self)
	local closeAnimationName = "S_Vx_PhoneCallContactDetailPage_toRight"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)
	self.bindData.rootWidget.activeCtrlDelay = clipTime

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE, self.backToShowType)
end

M.RefreshView = function(self)
	local remark = gCallPhoneUtils.GetContactRemark(self.contactId)
	local name = gCallPhoneUtils.GetContactName(self.contactId)
	local phoneNumber = gCallPhoneUtils.GetContactPhoneNumber(self.contactId)
	self.bindData.remark = remark
	self.bindData.name = name
	self.bindData.phoneNumber = phoneNumber
	local avatarId = gCallPhoneUtils.GetContactSAvatarId(self.contactId)
	local headStore = gStoreManager:GetStoreGroup("PhoneCallContactHeadTemplateStore"):GetStoreByWidget(self.bindData.headWidget)
	headStore.avatarId = avatarId
	self.bindData.isShowDelete = gCallPhoneUtils.CheckContactCanDelete(self.contactId)
	self.bindData.showChatCtrl = self.chatNpcId and self.chatNpcId <= 0 and ShowTypeControl.Show or ShowTypeControl.Hide
	self.bindData.showNameCtrl = remark == name and ShowTypeControl.Show or ShowTypeControl.Hide
	self.bindData.callButton.interactable = not gCallPhoneUtils.CheckPhoneCallConflict()
end

M.OnEditClick = function(self)
	if self.isDeleting then
		return
	end

	local animation = "S_Vx_PhoneCallContactDetailPage_toEdit"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animation)
	self.bindData.rootWidget.activeCtrlDelay = clipTime

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animation)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_SHOW, {
		secondShowType = gClientConst.CallPhoneShowType.Edit,
		contactId = self.contactId,
		lastShowType = gClientConst.CallPhoneShowType.Detail
	})
end

M.OnChatClick = function(self)
	if self.isDeleting then
		return
	end

	local topChannelId = gNpcChatConst.ChatTopChannel.Npc
	local subChannelId = self.chatNpcId
	local subChannelHaveChatMessage = gNpcChatUtils.HaveNormalTypeChat(topChannelId, subChannelId)
	subChannelId = subChannelHaveChatMessage and subChannelId or nil

	gMessageManager:SendMessage(gEventConstants.ON_CALL_PHONE_OPEN_CHAT_PANEL)

	local params = {
		topChannelId = topChannelId,
		subChannelId = subChannelId
	}

	gNpcChatUtils.OpenChatPanel(params)
end

M.OnCallClick = function(self)
	if self.isDeleting then
		return
	end

	local contactInfo = gCallPhoneUtils.GetContactInfoById(gBattleSpiritMgr.currentSpiritTemplateId, self.contactId)
	local phoneNumber = contactInfo and contactInfo.PhoneNumber

	gCallPhoneUtils.ShowCallPhoneTimelineDialogPanel(gBattleSpiritMgr.currentSpiritTemplateId, phoneNumber)
end

M.OnDeleteClick = function(self)
	if self.isDeleting then
		return
	end

	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextScriptTextConfig.GetConfig(89901106).Text,
		onConfirmCallback = function ()
			self.deleteCo = coroutine.start(function ()
				self.isDeleting = true
				local rootGo = self.rootGo

				coroutine.wait(0.3)
				gCallPhoneUtils.DeletePhoneContact(gBattleSpiritMgr.currentSpiritTemplateId, self.contactId, function ()
					if gClientUtils.NotNil(rootGo) then
						self.isDeleting = nil
					end
				end)
			end)
		end
	})
end

M.OnExitClick = function(self)
	if self.isDeleting then
		return
	end

	M.base.OnExitClick(self)
end

M.ClearData = function(self)
	self.isDeleting = nil
	self.deleteCo = coroutine.stop(self.deleteCo)
end
