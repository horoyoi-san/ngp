-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MailsPanelStore.lua
-- Decompiled from: 01416_MailsPanelStore.lua_a01acf45376e.luajit

C_MailsPanelStore = DefClass("C_MailsPanelStore", C_MailsPanelStore, C_StoreGroup)
GroupName2Class.MailsPanelStore = C_MailsPanelStore
local M = C_MailsPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.mgr = gNewMailsMgr

	self.InitData(self)
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItemItem)
	self.bindData.receiveBtn.luaClick = self.CreateAction(self, self.OnReceiveBtnClick)
	self.bindData.collectBtn.luaClick = self.CreateAction(self, self.OnCollectBtnClick)
	self.bindData.uncollectBtn.luaClick = self.CreateAction(self, self.OnCollectBtnClick)
	self.bindData.deleteAllBtn.luaClick = self.CreateAction(self, self.OnDeleteAllBtnClick)
	self.bindData.allGetBtn.luaClick = self.CreateAction(self, self.OnAllGetBtnClick)
	self.bindData.deleteBtn.luaClick = self.CreateAction(self, self.OnDeleteBtnClick)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.msgEvents = {
		[gEventConstants.MAILS_NUM_CHANGE] = self.CreateActionWithArgs(self, self.OnMailChange),
		[gEventConstants.REFRESH_MAIL_LIST] = self.CreateActionWithArgs(self, self.RefreshMailList),
		[gEventConstants.REFRESH_MAIL_DETAIL] = self.CreateActionWithArgs(self, self.RefreshMailDetail),
		[gEventConstants.REFRESH_MAIL_SORT] = self.CreateActionWithArgs(self, self.RefreshMailSort)
	}

	self.RegisterMessageEvents(self, self.msgEvents)
	self.InitData(self)
end

M.InitData = function(self)
	self.mailsInfo = {}
	self.tabIndex = 1
	self.mailIndex = 1
	self.mailId = 0
	self.giftViewList = {}
end

M.OnGroupEnable = function(self)
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_MAIL_PANEL) and 1 or 0
end

M.OnShow = function(self, panelId, data)
	self.bindData.isEmpty = BOOL2CTL[true]

	self.mgr:RegisterAskMailsHead()
end

M.OnClose = function(self)
	self:ClearMessageEvents()
	self.mgr:OnExit()
end

M.RefreshMailList = function(self)
	self.mailsInfo = self.mgr:GetMailsTabInfo()
	local mailList = self.mailsInfo[self.tabIndex]

	self.SubGroup.CommonTabSingleStore:SetSimpleData(#self.mailsInfo, #mailList, 0, 0, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))

	self.bindData.isEmpty = BOOL2CTL[#mailList ~= 0]
	local mailCount = table.count(self.mgr.mailBriefs)
	self.bindData.mailNumLabel = mailCount

	self:RefreshMailTab()
end

M.RefreshMailTab = function(self)
	local mailList = self.mailsInfo[self.tabIndex]
	self.bindData.maxMailNum = LTConfig.GameConfig.NewMailUpperLimit[self.tabIndex]
	local isEmpty = #mailList ~= 0
	self.mailIndex = 1

	self.SubGroup.CommonTabSingleStore:SetSimpleTabList(#mailList, true)

	if not isEmpty then
		self.SubGroup.CommonTabSingleStore:SetSelectedIndex(self.mailIndex - 1, true, true)
	end

	self.bindData.isEmpty = BOOL2CTL[isEmpty]

	self.RequestMailDetail(self)
end

M.RequestMailDetail = function(self)
	if self.mailIndex <= #self.mailsInfo[self.tabIndex] then
		return
	end

	self.mailId = self.mailsInfo[self.tabIndex][self.mailIndex]

	if not self.mailId then
		return
	end

	self.mgr:RegisterAskMailInfo(self.mailId)
end

M.RefreshMailDetail = function(self)
	local mailInfo = self.mgr:GetMailDetailInfo(self.mailId)

	if not mailInfo then
		print_warn("[C_MailsPanelStore] 邮件详情不存在", self.mailId)

		return
	end

	self.bindData.titleLabel = mailInfo.title
	self.bindData.addresserLabel = mailInfo.senderName
	self.bindData.dateYMDLabel = mailInfo.createTimeDayStr
	self.bindData.dateHMLabel = mailInfo.createTimeHourStr

	self.bindData.contentList:SetSimpleList(1)
	self.bindData.contentList:SetItemLabel(0, mailInfo.content)

	local giftViewList = {}
	local propList = mailInfo.items

	for i = 1, #propList do
		local prop = propList[i]
		local view = {
			itemId = prop.itemId,
			itemNum = prop.itemNum,
			IsOwned = mailInfo.isRetrieved
		}

		table.insert(giftViewList, view)
	end

	self.giftViewList = gCommonItemManager:GetSingleSortedListRenderDataByList(giftViewList)

	self.bindData.itemList:SetSimpleList(#giftViewList)
	self.bindData:Commit("hasAttachment", BOOL2CTL[mailInfo.hasAttachment], COMMIT_IMMEDIATELY)

	self.bindData.canReceive = BOOL2CTL[mailInfo.hasAttachment and not mailInfo.isRetrieved]
	self.bindData.showIsFavorite = BOOL2CTL[mailInfo.isFavorite]
	self.bindData.deleteAllBtn.interactable, self.bindData.allGetBtn.interactable = self.mgr:CheckCurrentTabCanDeleteAndRecive(self.tabIndex)
end

M.RefreshMailSort = function(self)
	local oldCount = #(self.mailsInfo[self.tabIndex] or {})
	self.mailsInfo = self.mgr:GetMailsTabInfo()
	local mailList = self.mailsInfo[self.tabIndex]
	local newIndex = 1

	for i, id in ipairs(mailList) do
		if id ~= self.mailId then
			newIndex = i

			break
		end
	end

	self.mailIndex = newIndex

	if #mailList == oldCount then
		self.SubGroup.CommonTabSingleStore:SetSimpleTabList(#mailList, true)
	end

	self.SubGroup.CommonTabSingleStore:SetSelectedIndex(newIndex - 1, false, true)
	self.SubGroup.CommonTabSingleStore:RefreshLogic(true)
end

M.OnChangeTab = function(self, uList, isSub)
	if isSub then
		local mailIndex = uList.selectedIndex + 1

		if mailIndex ~= self.mailIndex then
			return
		end

		self.mailIndex = mailIndex

		self.RequestMailDetail(self)
	else
		local tabIndex = uList.selectedIndex + 1

		if tabIndex ~= self.tabIndex then
			return
		end

		self.tabIndex = tabIndex

		self.RefreshMailTab(self)
	end
end

M.OnRenderTabItem = function(self, btn, index, data, store, isSub, uList)
	if isSub then
		self.OnRenderMailItem(self, btn, index, uList)
	else
		local info = self.mgr:GetTabInfo(index + 1)
		store.title = info.title
		store.icon = info.iconId
		btn.templateKey = "Number"
	end
end

M.OnRenderMailItem = function(self, btn, index, uList)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local mailId = self.mailsInfo[self.tabIndex][index + 1]
	local brief = self.mgr:GetMailBriefInfo(mailId)
	store.titleLabel = brief.title
	store.nameLabel = brief.senderName
	store.dateLabel = brief.validTimeStr
	store.collect = BOOL2CTL[brief.isFavorite]
	store.isNewMail = BOOL2CTL[brief.isNew]
	store.canReceive = BOOL2CTL[brief.hasAttachment]

	uList:SetItemId(index, ulong.tostring(mailId))

	if brief.hasAttachment and not table.isNilOrEmpty(brief.items) then
		local giftViewList = gCommonItemManager:GetSingleSortedListRenderDataByList(brief.items)

		if #giftViewList <= 0 then
			local itemData = gCommonItemManager:GetItemRenderData(giftViewList[1])
			store.itemIcon = itemData.iconId
		end
	end
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_MAIL_PANEL)
end

M.OnReceiveBtnClick = function(self)
	self.mgr:AskReceiveMail(self.mailId, self:CreateAction(self.RefreshMailDetail))
end

M.OnDeleteAllBtnClick = function(self)
	self.mgr:DetailTabMail(self.tabIndex, self:CreateAction(self.RefreshMailList))
end

M.OnDeleteBtnClick = function(self)
	self.mgr:AskDeleteMails({
		self.mailId
	}, self:CreateAction(self.RefreshMailList))
end

M.OnCollectBtnClick = function(self)
	slot1 = self.mgr

	slot1:AskFavorMail(self.mailId, function ()
		self.SubGroup.CommonTabSingleStore:RefreshLogic(true)

		self.bindData.showIsFavorite = BOOL2CTL[self.mgr:GetMailBriefInfo(self.mailId).isFavorite]
		self.bindData.deleteAllBtn.interactable, self.bindData.allGetBtn.interactable = self.mgr:CheckCurrentTabCanDeleteAndRecive(self.tabIndex)
	end)
end

M.OnAllGetBtnClick = function(self)
	self.mgr:ReceiveAllMail(self.tabIndex, self:CreateAction(self.RefreshMailDetail))
end

M.OnMailChange = function(self)
	self.mgr:RegisterAskMailsHead()
end

M.OnRenderItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.text.onHyperlinkClick = self.CreateAction(self, self.OnClickHyperLink)
end

M.OnRenderItemItem = function(self, btn, index)
	local data = self.giftViewList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

M.OnClickHyperLink = function(self, text, action, label)
	UniSDKManager.OpenWebView(action)
end
