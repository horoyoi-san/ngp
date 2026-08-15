C_ComputerMailPanelStore = DefClass("C_ComputerMailPanelStore", C_ComputerMailPanelStore, C_StoreGroup)
GroupName2Class.ComputerMailPanelStore = C_ComputerMailPanelStore
local M = C_ComputerMailPanelStore

function M:OnAwake()
	self.bindData.receiveButton.luaClick = self:CreateAction("OnReceiveClick")
	self.bindData.sendButton.luaClick = self:CreateAction("OnSendClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.minButton.luaClick = self:CreateAction("OnMinClick")
	self.bindData.maxButton.luaClick = self:CreateAction("OnMaxClick")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.readMoreButton.luaClick = self:CreateAction("OnReadMoreClick")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnContentRenderItem")
end

function M:ShowPanel(computerId)
	self:InitModel(computerId)
	self:InitView()
end

function M:InitModel(computerId)
	self.computerId = computerId
	self.Tab_Type = {
		Receive = 1,
		Send = 2
	}
	self.Email_Type = {
		Recipient = 0,
		Sender = 1
	}
	self.New_State_Control = {
		UnRead = 1,
		HasRead = 0
	}
	self.Email_Content_Template = {
		Type04 = 5,
		Info = 0
	}
	self.selectedType = self.Tab_Type.Receive
end

function M:InitView()
	self:RefreshPanelView()
	self.bindData.contentList:RegisterToScrollEvent(self:CreateAction("OnContentScroll"))
	self.bindData.contentList:RegisterToScrollEndEvent(self:CreateAction("OnContentScrollEnd"))
end

function M:RefreshPanelView()
	self.bindData.receiveButton.isSelected = self.selectedType == self.Tab_Type.Receive
	self.bindData.sendButton.isSelected = self.selectedType == self.Tab_Type.Send
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	self.mailViewDataList = {}
	local emailIdList = computerCfg.EmailList

	for index, emailId in ipairs(emailIdList) do
		local isEmailCanShow = self:CheckEmailCanShow(emailId)

		if isEmailCanShow then
			local emailCfg = LTConfig.ComputerEmailConfig.GetConfig(emailId)

			if self.selectedType == self.Tab_Type.Receive and emailCfg.EmailType == self.Email_Type.Recipient then
				table.insert(self.mailViewDataList, {
					emailId = emailId,
					index = index
				})
			elseif self.selectedType == self.Tab_Type.Send and emailCfg.EmailType == self.Email_Type.Sender then
				table.insert(self.mailViewDataList, {
					emailId = emailId,
					index = index
				})
			end
		end
	end

	local emailId = self.mailViewDataList[1] and self.mailViewDataList[1].emailId
	self.selectedEmailId = emailId

	self.bindData.list:SetSimpleList(#self.mailViewDataList)
	self.bindData.list:SetItemSelected(0, true)

	self.bindData.emptyControl = #self.mailViewDataList == 0 and 1 or 0

	self:RefreshContentView(emailId)
end

function M:CheckEmailHasUnlocked(emailId)
	local computerEmailInfo = self:GetComputerEmailInfo(emailId)

	return computerEmailInfo ~= nil
end

function M:CheckEmailCanShow(emailId)
	if not self:CheckEmailHasUnlocked(emailId) then
		return false
	end

	if self:CheckEmailHasDeleted(emailId) then
		return false
	end

	return true
end

function M:CheckEmailHasDeleted(targetEmailId)
	local computerInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo.ComputerInfos[self.computerId]

	if computerInfo then
		for _, emailId in ipairs(computerInfo.DeleteEmails) do
			if emailId == targetEmailId then
				return true
			end
		end
	end
end

function M:GetComputerEmailInfo(emailId)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	return computerUnlockInfo and computerUnlockInfo.UnlockEmails and computerUnlockInfo.UnlockEmails[emailId]
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.mailViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local emailId = data.emailId
	local emailCfg = LTConfig.ComputerEmailConfig.GetConfig(emailId)
	store.title = emailCfg.Sender
	store.content = emailCfg.EmailTitle
	store.newState = self:GetEmailNewState(emailId)
	store.iconId = emailCfg.HeadImage
	store.avatarControl = 1
	store.button.isSelected = emailId == self.selectedEmailId
	store.button.luaClick = self:CreateActionWithArgs(self.RefreshContentView, emailId)
	store.button.enabledTooltip = self:CheckEnabledToolTips()
	store.button.tooltipMode = self:GetToolTipMode()
	store.button.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderToolTips, emailId)
end

function M:GetToolTipMode()
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	return isMobile and 2 or 6
end

function M:CheckEnabledToolTips()
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	return computerCfg.IsDelete
end

function M:RefreshContentView(emailId)
	self.selectedEmailId = emailId
	local emailCfg = LTConfig.ComputerEmailConfig.GetConfig(emailId)
	self.contentDataList = {}

	if emailCfg then
		self.bindData.title = emailCfg.EmailTitle or ""

		table.insert(self.contentDataList, {
			tIndex = self.Email_Content_Template.Info,
			emailId = emailId
		})
		table.insert(self.contentDataList, {
			tIndex = emailCfg.EmailTemplate,
			emailId = emailId
		})
		self:SetEmailHasRead(emailId)

		function self.bindData.contentList.onGetTIndex(csIndex)
			local luaIndex = csIndex + 1
			local data = self.contentDataList[luaIndex]

			return data.tIndex
		end

		self.bindData.contentList:SetSimpleList(#self.contentDataList)

		local isActive = self:CheckCanShowReadMoreButton()

		self.bindData.readMoreButton:SetActive(isActive)
		self.bindData.contentList:GoToIndex(0, true)
	else
		self.bindData.readMoreButton:SetActive(false)
		self.bindData.contentList:SetSimpleList(0)

		self.bindData.title = ""
	end
end

function M:CheckCanShowReadMoreButton()
	local emailCfg = LTConfig.ComputerEmailConfig.GetConfig(self.selectedEmailId)

	return emailCfg and emailCfg.IsShowFloatWindow
end

function M:OnRenderToolTips(emailId, _, popup, _)
	local store = gStoreManager:GetStoreGroup(popup.Store)

	function store.onDeleteCallback()
		local rootGo = self.rootGo

		gClientToGameDelegate:AskComputerDeleteEmail(self.computerId, emailId).Callback = function (errorId)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			local computerInfos = gPlayerManager.infoMinor.bindData.computerUnlockInfo.ComputerInfos

			if not computerInfos[self.computerId] then
				computerInfos[self.computerId] = {
					CfgId = self.computerId,
					FirstOpenTime = gLuaDataManager.serverTime,
					DeleteFiles = {},
					DeleteEmails = {}
				}
			end

			local computerInfo = computerInfos[self.computerId]

			table.insert(computerInfo.DeleteEmails, emailId)

			if gClientUtils.NotNil(rootGo) then
				self:RefreshPanelView()
			end
		end
	end
end

function M:OnContentRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.contentDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local emailId = data.emailId
	local emailCfg = LTConfig.ComputerEmailConfig.GetConfig(emailId)

	if data.tIndex == self.Email_Content_Template.Info then
		store.sender = emailCfg.Sender
		store.receiver = emailCfg.Recipient
		store.iconId = emailCfg.HeadImage
		store.avatarControl = 1
	else
		store.content = emailCfg.EmailTextCode
		store.logoId = emailCfg.TemplateLogo
		store.title = emailCfg.TemplateTitle
		store.contentTitle = emailCfg.ContentTitle
		store.sign = emailCfg.TemplateSign

		if data.tIndex == self.Email_Content_Template.Type04 and emailCfg.TemplateLogo > 0 then
			store.corpIconControl = 1
		end
	end
end

function M:OnReceiveClick()
	if self.selectedType ~= self.Tab_Type.Receive then
		self.selectedType = self.Tab_Type.Receive

		self:RefreshPanelView()
	end
end

function M:OnSendClick()
	if self.selectedType ~= self.Tab_Type.Send then
		self.selectedType = self.Tab_Type.Send

		self:RefreshPanelView()
	end
end

function M:GetEmailNewState(emailId)
	if self.selectedType == self.Tab_Type.Send then
		return self.New_State_Control.HasRead
	end

	local hasRead = self:CheckEmailHasRead(emailId)

	return hasRead and self.New_State_Control.HasRead or self.New_State_Control.UnRead
end

function M:CheckEmailHasRead(emailId)
	local computerEmailInfo = self:GetComputerEmailInfo(emailId)

	return computerEmailInfo.IsRead
end

function M:SetEmailHasRead(emailId)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_EMAIL_READ, emailId)

	local hasRead = self:CheckEmailHasRead(emailId)

	gClientToGameDelegate:AskComputerEmailRead(emailId).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			return
		end

		if not hasRead then
			local computerEmailInfo = self:GetComputerEmailInfo(emailId)
			computerEmailInfo.IsRead = true

			self.bindData.list:RefreshList()
		end
	end
end

function M:OnExitClick()
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)
end

function M:OnMinClick()
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)
end

function M:OnMaxClick()
	return
end

function M:OnReadMoreClick()
	self.bindData.contentList.normalizedScrollPosition = Vector2.Fetch(0, 0)
end

function M:OnContentScroll()
	if self:CheckCanShowReadMoreButton() then
		if self.bindData.contentList.normalizedScrollPosition.y <= LTConfig.ComputerConfig.MailScrollToBottomThreshold then
			self.bindData.readMoreButton:SetActive(false)
			self:AskComputerMailScrollToBottom()
		else
			self.bindData.readMoreButton:SetActive(true)
		end
	end
end

function M:AskComputerMailScrollToBottom()
	if self.hasTriggerEmailScrollToBottom then
		return
	end

	self.hasTriggerEmailScrollToBottom = true

	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_MAIL_SCROLL_TO_BOTTOM, {
		mailId = self.selectedEmailId
	})

	gClientToGameDelegate:AskComputerEmailScrollToBottom(self.selectedEmailId).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

function M:OnContentScrollEnd()
	self.hasTriggerEmailScrollToBottom = false
end

function M:OnDestroy()
	self.hasTriggerEmailScrollToBottom = nil

	self:ClearMessageEvents()
end
