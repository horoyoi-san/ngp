-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneCallMainPageStore.lua
-- Decompiled from: 02037_PhoneCallMainPageStore.lua_f7c0f39f355b.luajit

C_PhoneCallMainPageStore = DefClass("C_PhoneCallMainPageStore", C_PhoneCallMainPageStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PhoneCallMainPageStore = C_PhoneCallMainPageStore
local M = C_PhoneCallMainPageStore
local TemplateType = {
	["rRejE2,"] = 1,
	["\\xfa\\xd4\t'\\xe5"] = 2,
	["y\\xa7\\xb6\\xa3\\xb3"] = 0
}
local ShowNameTypeCtrl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}

M.OnAwake = function(self)
	self.bindData.contactList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.addButton.luaClick = self.CreateAction(self, "OnAddClick")
	self.bindData.editButton.luaClick = self.CreateAction(self, "OnEditClick")
	self.bindData.callButton.luaClick = self.CreateAction(self, "OnCallClick")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_CALL_PHONE_ADD_CONTACT_SUCCESS] = self.CreateAction(self, "RefreshView"),
		[gEventConstants.ON_CALL_PHONE_DELETE_CONTACT_SUCCESS] = self.CreateAction(self, "RefreshView"),
		[gEventConstants.ON_CALL_PHONE_EDIT_CONTACT_SUCCESS] = self.CreateAction(self, "RefreshView"),
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self.CreateAction(self, "OnPhoneCallStateChange"),
		[gEventConstants.ON_FORMAL_SHORT_CUT_KEY_STATE_CHANGE] = function ()
			self.bindData.contactList:RefreshList()
		end
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.PC_KEY_MAP = {
		[0] = 62,
		63
	}
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	if args and args.isFromMainPhone then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_PhoneCall_MainPage_open_first")
	end

	self.RefreshView(self)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_CLOSE)
end

M.RefreshView = function(self)
	self.bindData.contactButton.isSelected = true
	self.viewDataList = self.GetContactViewList(self)

	self.bindData.contactList.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList[luaIndex]

		return data.tIndex
	end

	local guideMap = {}
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId

	for luaIndex, data in ipairs(self.viewDataList) do
		if data.tIndex ~= TemplateType.Contact then
			local phoneNumber = gCallPhoneUtils.GetContactPhoneNumber(data.contactId)
			local configId = gCallPhoneUtils.GetConfigIdByPhoneNumber(spiritId, phoneNumber)
			local contactCfg = LTConfig.PhoneContactConfig.GetConfig(configId)
			local guideId = contactCfg and not contactCfg.IsQuickCall and contactCfg.GuideId or ""

			if guideId == "" then
				guideMap[guideId] = luaIndex - 1
			end
		end
	end

	self.bindData.contactList:SetSimpleList(#self.viewDataList)
	gNewGuideMgr:RegisterGuideKeyLocations(self.bindData.contactList, guideMap)

	self.bindData.emptyControl = #self.viewDataList ~= 0 and 1 or 0
end

M.OnPhoneCallStateChange = function(self)
	self.bindData.contactList:RefreshList()
end

M.GetContactViewList = function(self)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local quickCallContactIdList, friendContactIdList = gCallPhoneUtils.GetContactIdList(spiritId)
	local viewDataList = {}
	self.focusContactId = nil

	if table.count(quickCallContactIdList) <= 0 then
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

	if table.count(friendContactIdList) <= 0 then
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

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex ~= TemplateType.Title then
		store.title = data.title
	elseif data.tIndex ~= TemplateType.QuickList then
		self.RefreshQuickCallList(self, store, data.quickCallContactIdList)
	elseif data.tIndex ~= TemplateType.Contact then
		if self.focusContactId ~= data.contactId then
			self.focusContactId = nil
			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
		end

		self.RefreshFriendContactItemView(self, store, data.contactId)
	end
end

M.RefreshQuickCallList = function(self, store, quickCallContactIdList)
	store.quickCallList.luaSimpleRenderItem = self.CreateAction(self, "OnContactRenterItem")
	self.quickCallViewDataList = {}

	for _, contactId in ipairs(quickCallContactIdList) do
		table.insert(self.quickCallViewDataList, {
			contactId = contactId
		})
	end

	store.quickCallList:SetSimpleList(#self.quickCallViewDataList)
end

M.OnContactRenterItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.quickCallViewDataList[luaIndex]

	if self.focusContactId ~= data.contactId then
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

	store.button.luaClick = function()
		gCallPhoneUtils.ShowCallPhoneTimelineDialogPanel(gBattleSpiritMgr.currentSpiritTemplateId, phoneNumber, true)
	end

	local typeControlValue = self:GetTypeControlValue(configId)
	local isActivePcKey = typeControlValue < 0

	store.pcKeyWidget:SetActive(isActivePcKey)

	store.typeControl = typeControlValue
	local pcKey = self.PC_KEY_MAP[typeControlValue] or 0

	btn:SetPCKeyInfoWithOutTip(pcKey)

	store.button.interactable = not gCallPhoneUtils.CheckPhoneCallConflict()

	if csIndex ~= 0 and btn.cachedNavArea and gClientUtils.IsNil(btn.cachedNavArea.CurrentActiveContent) and not SGUI.GuideMgr.IsNavigationLockedByGuide(btn) then
		btn.Navigate(btn, btn)
	end
end

M.GetTypeControlValue = function(self, contactId)
	if gGmUtils:GetFormalShortCutKeyState() and gCS.LuaUtils.IsNonMobileAdaptive() then
		local quickCallInfoList = gCallPhoneUtils.GetHudQuickCallInfoList()

		for _, callInfo in ipairs(quickCallInfoList) do
			if callInfo.contactId ~= contactId then
				return callInfo.pcKeyControl
			end
		end
	end

	return -1
end

M.RefreshFriendContactItemView = function(self, store, contactId)
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

	store.button.luaClick = function()
		local animationName = "S_Vx_PhoneCall_MainPage_open_toLeft"
		local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animationName)
		self.bindData.rootWidget.activeCtrlDelay = clipTime

		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)
		gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_SHOW, {
			["ZI诋\\x95\\xc0\\xe6"] = true,
			secondShowType = gClientConst.CallPhoneShowType.Detail,
			contactId = contactId,
			lastShowType = gClientConst.CallPhoneShowType.Contact
		})
	end
end

M.PlayPanelAnimation = function(self, _)
	if self.panelArgs and self.panelArgs.lastShowType ~= gClientConst.CallPhoneShowType.Detail then
		local animationName = "S_Vx_PhoneCall_MainPage_open_toRight"

		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)
	end
end

M.OnCallClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_CONTENT_SHOW, {
		secondShowType = gClientConst.CallPhoneShowType.Dialing
	})
end

M.OnAddClick = function(self)
	gCallPhoneUtils.ShowEditPanelByAddContact(gBattleSpiritMgr.currentSpiritTemplateId, nil, gClientConst.CallPhoneShowType.Contact)
end

M.OnEditClick = function(self)
end

M.ClearData = function(self)
end
