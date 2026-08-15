C_PhoneCallContactDetailPageStore = DefClass("C_PhoneCallContactDetailPageStore", C_PhoneCallContactDetailPageStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PhoneCallContactDetailPageStore = C_PhoneCallContactDetailPageStore
local M = C_PhoneCallContactDetailPageStore
local ShowTypeControl = {
	Hide = 0,
	Show = 1
}

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.chatButton.luaClick = self:CreateAction(self.OnChatClick)
	self.bindData.callButton.luaClick = self:CreateAction(self.OnCallClick)
	self.bindData.deleteButton.luaClick = self:CreateAction(self.OnDeleteClick)
	self.bindData.editButton.luaClick = self:CreateAction(self.OnEditClick)
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_CALL_PHONE_DELETE_CONTACT_SUCCESS] = function (_, contactId)
			if contactId == self.contactId then
				local messageConfigId = LTConfig.MessageConfig.PhoneCallContactsDeleted
				local messageCfg = LTConfig.MessageConfig.GetConfig(messageConfigId)
				local tips = messageCfg.Content:format(self.remark)

				gDisplayMessageMgr:ShowMessageContent(tips)
				self:OnExit()
			end
		end,
		[gEventConstants.ON_CALL_PHONE_EDIT_CONTACT_SUCCESS] = function (_, contactId)
			if self.contactId == contactId then
				self:RefreshView()
			end
		end,
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self:CreateAction("OnPhoneCallStateChange")
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.backToShowType = args.backToShowType
	local contactId = args.contactId
	self.contactId = contactId
	self.remark = gCallPhoneUtils.GetContactRemark(contactId)
	self.chatNpcId = gCallPhoneUtils.GetChatNpcId(contactId)
end

function M:InitView(args)
	M.base.InitView(self, args)
	self:RefreshView()
end

function M:OnPhoneCallStateChange()
	self:RefreshView()
end

function M:PlayPanelAnimation()
	if self.panelArgs then
		if self.panelArgs.lastShowType == gClientConst.CallPhoneShowType.Contact then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_PhoneCallContactDetailPage_toLeft")
		elseif self.panelArgs.lastShowType == gClientConst.CallPhoneShowType.Edit then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_PhoneCallContactDetailPage_fromEdit")
		end
	end
end

function M:OnExecuteExitAction()
	local closeAnimationName = "S_Vx_PhoneCallContactDetailPage_toRight"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)
	self.bindData.rootWidget.activeCtrlDelay = clipTime

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE, self.backToShowType)
end

function M:RefreshView()
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
	self.bindData.showChatCtrl = self.chatNpcId and self.chatNpcId > 0 and ShowTypeControl.Show or ShowTypeControl.Hide
	self.bindData.showNameCtrl = remark ~= name and ShowTypeControl.Show or ShowTypeControl.Hide
	self.bindData.callButton.interactable = not gCallPhoneUtils.CheckPhoneCallConflict()
end

function M:OnEditClick()
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

function M:OnChatClick()
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

function M:OnCallClick()
	if self.isDeleting then
		return
	end

	local contactInfo = gCallPhoneUtils.GetContactInfoById(gBattleSpiritMgr.currentSpiritTemplateId, self.contactId)
	local phoneNumber = contactInfo and contactInfo.PhoneNumber

	gCallPhoneUtils.ShowCallPhoneTimelineDialogPanel(gBattleSpiritMgr.currentSpiritTemplateId, phoneNumber)
end

function M:OnDeleteClick()
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

function M:OnExitClick()
	if self.isDeleting then
		return
	end

	M.base.OnExitClick(self)
end

function M:ClearData()
	self.isDeleting = nil
	self.deleteCo = coroutine.stop(self.deleteCo)
end
