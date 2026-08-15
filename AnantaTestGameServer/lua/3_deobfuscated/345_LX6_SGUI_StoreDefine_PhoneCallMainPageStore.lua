C_PhoneCallMainPageStore = DefClass("C_PhoneCallMainPageStore", C_PhoneCallMainPageStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PhoneCallMainPageStore = C_PhoneCallMainPageStore
local M = C_PhoneCallMainPageStore
local TemplateType = {
	QuickList = 1,
	Contact = 2,
	Title = 0
}
local ShowNameTypeCtrl = {
	Hide = 0,
	Show = 1
}

function M:OnAwake()
	self.bindData.contactList.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.addButton.luaClick = self:CreateAction("OnAddClick")
	self.bindData.editButton.luaClick = self:CreateAction("OnEditClick")
	self.bindData.callButton.luaClick = self:CreateAction("OnCallClick")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_CALL_PHONE_ADD_CONTACT_SUCCESS] = self:CreateAction("RefreshView"),
		[gEventConstants.ON_CALL_PHONE_DELETE_CONTACT_SUCCESS] = self:CreateAction("RefreshView"),
		[gEventConstants.ON_CALL_PHONE_EDIT_CONTACT_SUCCESS] = self:CreateAction("RefreshView"),
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self:CreateAction("OnPhoneCallStateChange"),
		[gEventConstants.ON_FORMAL_SHORT_CUT_KEY_STATE_CHANGE] = function ()
			self.bindData.contactList:RefreshList()
		end
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.PC_KEY_MAP = {
		[0] = 62,
		63
	}
end

function M:InitView(args)
	M.base.InitView(self, args)

	if args and args.isFromMainPhone then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_PhoneCall_MainPage_open_first")
	end

	self:RefreshView()
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE)
end

function M:RefreshView()
	self.bindData.contactButton.isSelected = true
	self.viewDataList = self:GetContactViewList()

	function self.bindData.contactList.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.contactList:SetSimpleList(#self.viewDataList)

	self.bindData.emptyControl = #self.viewDataList == 0 and 1 or 0
end

function M:OnPhoneCallStateChange()
	self.bindData.contactList:RefreshList()
end

function M:GetContactViewList()
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local quickCallContactIdList, friendContactIdList = gCallPhoneUtils.GetContactIdList(spiritId)
	local viewDataList = {}
	self.focusContactId = nil

	if table.count(quickCallContactIdList) > 0 then
		table.insert(viewDataList, {
			tIndex = TemplateType.Title,
			title = LTConfig.TextScriptTextConfig.GetConfig(89901051).Text
		})
		table.insert(viewDataList, {
			tIndex = TemplateType.QuickList,
			quickCallContactIdList = quickCallContactIdList
		})

		self.focusContactId = quickCallContactIdList[1]
	end

	if table.count(friendContactIdList) > 0 then
		table.insert(viewDataList, {
			tIndex = TemplateType.Title,
			title = LTConfig.TextScriptTextConfig.GetConfig(89901052).Text
		})

		for _, contactId in ipairs(friendContactIdList) do
			table.insert(viewDataList, {
				tIndex = TemplateType.Contact,
				contactId = contactId
			})
		end

		self.focusContactId = friendContactIdList[1]
	end

	return viewDataList
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex == TemplateType.Title then
		store.title = data.title
	elseif data.tIndex == TemplateType.QuickList then
		self:RefreshQuickCallList(store, data.quickCallContactIdList)
	elseif data.tIndex == TemplateType.Contact then
		if self.focusContactId == data.contactId then
			self.focusContactId = nil
			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
		end

		self:RefreshFriendContactItemView(store, data.contactId)
	end
end

function M:RefreshQuickCallList(store, quickCallContactIdList)
	store.quickCallList.luaSimpleRenderItem = self:CreateAction("OnContactRenterItem")
	self.quickCallViewDataList = {}

	for _, contactId in ipairs(quickCallContactIdList) do
		table.insert(self.quickCallViewDataList, {
			contactId = contactId
		})
	end

	store.quickCallList:SetSimpleList(#self.quickCallViewDataList)
end

function M:OnContactRenterItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.quickCallViewDataList[luaIndex]

	if self.focusContactId == data.contactId then
		self.focusContactId = nil
		SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
	end

	btn.name = tostring(csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local contactId = data.contactId
	local remark = gCallPhoneUtils.GetContactRemark(contactId)
	local avatarId = gCallPhoneUtils.GetContactSAvatarId(contactId)
	store.remark = remark
	local headStore = gStoreManager:GetStoreGroup(store.headWidget.Store):GetStoreByWidget(store.headWidget)
	headStore.avatarId = avatarId
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId
	local contactInfo = gCallPhoneUtils.GetContactInfoById(spiritId, contactId)
	local phoneNumber = contactInfo and contactInfo.PhoneNumber
	local configId = gCallPhoneUtils.GetConfigIdByPhoneNumber(spiritId, phoneNumber)
	local contactCfg = LTConfig.PhoneContactConfig.GetConfig(configId)
	store.guideId = contactCfg and contactCfg.GuideId or ""

	function store.button.luaClick()
		gCallPhoneUtils.ShowCallPhoneTimelineDialogPanel(gBattleSpiritMgr.currentSpiritTemplateId, phoneNumber, true)
	end

	local typeControlValue = self:GetTypeControlValue(configId)
	local isActivePcKey = typeControlValue >= 0

	store.pcKeyWidget:SetActive(isActivePcKey)

	store.typeControl = typeControlValue
	local pcKey = self.PC_KEY_MAP[typeControlValue] or 0

	btn:SetPCKeyInfoWithOutTip(pcKey)

	store.button.interactable = not gCallPhoneUtils.CheckPhoneCallConflict()

	if csIndex == 0 and btn.cachedNavArea and gClientUtils.IsNil(btn.cachedNavArea.CurrentActiveContent) then
		btn:Navigate(btn)
	end
end

function M:GetTypeControlValue(contactId)
	if gGmUtils:GetFormalShortCutKeyState() and gCS.LuaUtils.IsNonMobileAdaptive() then
		local quickCallInfoList = gCallPhoneUtils.GetHudQuickCallInfoList()

		for _, callInfo in ipairs(quickCallInfoList) do
			if callInfo.contactId == contactId then
				return callInfo.pcKeyControl
			end
		end
	end

	return -1
end

function M:RefreshFriendContactItemView(store, contactId)
	local remark = gCallPhoneUtils.GetContactRemark(contactId)
	local name = gCallPhoneUtils.GetContactName(contactId)
	local phoneNumber = gCallPhoneUtils.GetContactPhoneNumber(contactId)
	store.isTop = false
	store.remark = remark
	store.name = name
	store.phoneNumber = phoneNumber
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId
	local configId = gCallPhoneUtils.GetConfigIdByPhoneNumber(spiritId, phoneNumber)
	local contactCfg = LTConfig.PhoneContactConfig.GetConfig(configId)
	store.guideId = contactCfg and not contactCfg.IsQuickCall and contactCfg.GuideId or ""
	local headStore = gStoreManager:GetStoreGroup("PhoneCallContactHeadTemplateStore"):GetStoreByWidget(store.headWidget)
	local avatarId = gCallPhoneUtils.GetContactSAvatarId(contactId)
	headStore.avatarId = avatarId
	local isShowName = gCallPhoneUtils.CheckIsShowName(contactId)
	store.showNameType = isShowName and ShowNameTypeCtrl.Show or ShowNameTypeCtrl.Hide

	function store.button.luaClick()
		local animationName = "S_Vx_PhoneCall_MainPage_open_toLeft"
		local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animationName)
		self.bindData.rootWidget.activeCtrlDelay = clipTime

		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_SHOW, {
			isFromMain = true,
			secondShowType = gClientConst.CallPhoneShowType.Detail,
			contactId = contactId,
			lastShowType = gClientConst.CallPhoneShowType.Contact
		})
	end
end

function M:PlayPanelAnimation(_)
	if self.panelArgs and self.panelArgs.lastShowType == gClientConst.CallPhoneShowType.Detail then
		local animationName = "S_Vx_PhoneCall_MainPage_open_toRight"

		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)
	end
end

function M:OnCallClick()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_SHOW, {
		secondShowType = gClientConst.CallPhoneShowType.Dialing
	})
end

function M:OnAddClick()
	gCallPhoneUtils.ShowEditPanelByAddContact(gBattleSpiritMgr.currentSpiritTemplateId, nil, gClientConst.CallPhoneShowType.Contact)
end

function M:OnEditClick()
	return
end

function M:ClearData()
	return
end
