local RedDotMgr = SGUI.RedDotMgr
C_MailsPanelStore = DefClass("C_MailsPanelStore", C_MailsPanelStore, C_StoreGroup)
GroupName2Class.MailsPanelStore = C_MailsPanelStore
local M = C_MailsPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.mgr = gNewMailsMgr

	self:InitData()
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnBackBtnClick)

	gCommonItemManager:InitRenderList(self.bindData.itemList)

	self.bindData.receiveBtn.luaClick = self:CreateAction(self.OnReceiveBtnClick)
	self.bindData.collectBtn.luaClick = self:CreateAction(self.OnCollectBtnClick)
	self.bindData.uncollectBtn.luaClick = self:CreateAction(self.OnCollectBtnClick)
	self.bindData.deleteAllBtn.luaClick = self:CreateAction(self.OnDeleteAllBtnClick)
	self.bindData.allGetBtn.luaClick = self:CreateAction(self.OnAllGetBtnClick)
	self.bindData.deleteBtn.luaClick = self:CreateAction(self.OnDeleteBtnClick)
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
	self.msgEvents = {
		[gEventConstants.MAILS_NUM_CHANGE] = self:CreateActionWithArgs(self.OnMailChange)
	}

	self:RegisterMessageEvents(self.msgEvents)
	self:InitData()
end

function M:InitData()
	self.mailsInfo = {}
	self.tabIndex = 1
	self.mailIndex = 1
	self.mailId = 0
end

function M:OnGroupEnable()
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_MAIL_PANEL) and 1 or 0
end

function M:OnShow(panelId, data)
	self:RefreshPage()
	self.mgr:AskMailsHead(self:CreateAction(self.RefreshPage))
end

function M:OnClose()
	self:ClearMessageEvents()
	self.mgr:OnExit()
end

function M:RefreshPage()
	self.mailsInfo = self.mgr:GetMailsTabInfo()
	local mailList = self.mailsInfo[self.tabIndex]

	self.SubGroup.CommonTabSingleStore:SetSimpleData(#self.mailsInfo, #mailList, 0, 0, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))

	self.bindData.isEmpty = BOOL2CTL[#mailList == 0]
	local mailCount = table.count(self.mgr.mailBriefs)
	self.bindData.mailNumLabel = mailCount

	self:RefreshTab()
end

function M:RefreshTab()
	local mailList = self.mailsInfo[self.tabIndex]
	self.bindData.maxMailNum = LTConfig.GameConfig.NewMailUpperLimit[self.tabIndex]
	local isEmpty = #mailList == 0
	self.mailIndex = 1

	self.SubGroup.CommonTabSingleStore:SetSimpleTabList(#mailList, true)

	if not isEmpty then
		self.SubGroup.CommonTabSingleStore:SetSelectedIndex(self.mailIndex - 1, true, true)
	end

	self.bindData.isEmpty = BOOL2CTL[isEmpty]

	self:RefreshInfo()
end

function M:RefreshInfo()
	if self.mailIndex > #self.mailsInfo[self.tabIndex] then
		return
	end

	self.mailId = self.mailsInfo[self.tabIndex][self.mailIndex]

	if not self.mailId then
		return
	end

	self.mgr:AskMailInfo(self.mailId, self:CreateAction(self._RefreshInfo))
end

function M:_RefreshInfo()
	local maiInfo = self.mgr:GetMailDetailInfo(self.mailId)

	if not maiInfo then
		print_warn("[C_MailsPanelStore] 邮件详情不存在", self.mailId)

		return
	end

	self.bindData.titleLabel = maiInfo.title
	self.bindData.addresserLabel = maiInfo.senderName
	self.bindData.dateYMDLabel = maiInfo.createTimeDayStr
	self.bindData.dateHMLabel = maiInfo.createTimeHourStr

	self.bindData.contentList:SetSimpleList(1)
	self.bindData.contentList:SetItemLabel(0, maiInfo.content)

	local giftViewList = {}
	local propList = maiInfo.items

	for i = 1, #propList do
		local prop = propList[i]
		local view = {
			itemId = prop.itemId,
			itemNum = prop.itemNum,
			IsOwned = maiInfo.isRetrieved
		}

		table.insert(giftViewList, gCommonItemManager:GetItemRenderData(view))
	end

	self.bindData.itemList:SetList(giftViewList)
	self.bindData:Commit("hasAttachment", BOOL2CTL[maiInfo.hasAttachment], COMMIT_IMMEDIATELY)

	self.bindData.canReceive = BOOL2CTL[maiInfo.hasAttachment and not maiInfo.isRetrieved]
	self.bindData.showIsFavorite = BOOL2CTL[maiInfo.isFavorite]
	self.bindData.deleteAllBtn.interactable, self.bindData.allGetBtn.interactable = self.mgr:CheckCurrentTabCanDeleteAndRecive(self.tabIndex)
end

function M:OnChangeTab(uList, isSub)
	if isSub then
		local mailIndex = uList.selectedIndex + 1

		if mailIndex == self.mailIndex then
			return
		end

		self.mailIndex = mailIndex

		self:RefreshInfo()
	else
		local tabIndex = uList.selectedIndex + 1

		if tabIndex == self.tabIndex then
			return
		end

		self.tabIndex = tabIndex

		self:RefreshTab()
	end
end

function M:OnRenderTabItem(btn, index, data, store, isSub, uList)
	if isSub then
		self:OnRenderMailItem(btn, index, uList)
	else
		local info = self.mgr:GetTabInfo(index + 1)
		store.title = info.title
		store.icon = info.iconId
		btn.templateKey = "Number"
	end
end

function M:OnRenderMailItem(btn, index, uList)
	local store = self:GetStoreByWidget(btn)

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
		local itemData = gCommonItemManager:GetItemRenderData(brief.items[1])
		store.itemIcon = itemData.iconId
	end
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_MAIL_PANEL)
end

function M:OnReceiveBtnClick()
	self.mgr:AskReceiveMail(self.mailId, self:CreateAction(self.RefreshPage))
end

function M:OnDeleteAllBtnClick()
	self.mgr:DetailTabMail(self.tabIndex, self:CreateAction(self.RefreshPage))
end

function M:OnDeleteBtnClick()
	self.mgr:AskDeleteMails({
		self.mailId
	}, self:CreateAction(self.RefreshPage))
end

function M:OnCollectBtnClick()
	self.mgr:AskFavorMail(self.mailId, function ()
		self.SubGroup.CommonTabSingleStore:RefreshLogic(true)

		self.bindData.showIsFavorite = BOOL2CTL[self.mgr:GetMailBriefInfo(self.mailId).isFavorite]
		self.bindData.deleteAllBtn.interactable, self.bindData.allGetBtn.interactable = self.mgr:CheckCurrentTabCanDeleteAndRecive(self.tabIndex)
	end)
end

function M:OnAllGetBtnClick()
	self.mgr:ReceiveAllMail(self.tabIndex, function ()
		self:_RefreshInfo()
	end)
end

function M:OnMailChange()
	self.mgr:AskMailsHead(self:CreateAction(self.RefreshPage))
end

function M:OnRenderItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.text.onHyperlinkClick = self:CreateAction(self.OnClickHyperLink)
end

function M:OnClickHyperLink(text, action, label)
	self.mgr:OpenWebView(action)
end
