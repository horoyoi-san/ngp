-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ComputerMailPanelStore.lua
-- Decompiled from: 01549_ComputerMailPanelStore.lua_886d566f8adc.luajit

C_ComputerMailPanelStore = DefClass("C_ComputerMailPanelStore", C_ComputerMailPanelStore, C_StoreGroup)
GroupName2Class.ComputerMailPanelStore = C_ComputerMailPanelStore
local M = C_ComputerMailPanelStore

M.OnAwake = function(self)
	self.bindData.receiveButton.luaClick = self.CreateAction(self, "OnReceiveClick")
	self.bindData.sendButton.luaClick = self.CreateAction(self, "OnSendClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.minButton.luaClick = self.CreateAction(self, "OnMinClick")
	self.bindData.maxButton.luaClick = self.CreateAction(self, "OnMaxClick")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.list.luaSimpleFocus = self.CreateAction(self, "OnMailItemFocus")
	self.bindData.readMoreButton.luaClick = self.CreateAction(self, "OnReadMoreClick")
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, "OnContentRenderItem")
	self.bindData.list.luaLayoutSet = self.CreateAction(self, "OnLayoutSet")
end

M.ShowPanel = function(self, computerId)
	self.InitModel(self, computerId)
	self.InitView(self)
end

M.InitModel = function(self, computerId)
	self.layoutSet = nil
	self.computerId = computerId
	self.Tab_Type = {
		["\\xeb\\xde2\\xf4"] = 1,
		["I's_"] = 2
	}
	self.Email_Type = {
		["qBo`^,"] = 0,
		["/M\\x9f\\x8a\\x86S"] = 1
	}
	self.New_State_Control = {
		[")F\\xa3\\x8b\\x82E"] = 1,
		["\\xf1\\xda/%\\xf5"] = 0
	}
	self.Email_Content_Template = {
		["(Q\\x81\\x8b\\xd3"] = 5,
		["S,{T"] = 0
	}
	self.selectedType = self.Tab_Type.Receive
end

M.InitView = function(self)
	self:RefreshPanelView()
	self.bindData.contentList:RegisterToScrollEvent(self:CreateAction("OnContentScroll"))
	self.bindData.contentList:RegisterToScrollEndEvent(self:CreateAction("OnContentScrollEnd"))
end

M.RefreshPanelView = function(self)
	self.bindData.receiveButton.isSelected = self.selectedType ~= self.Tab_Type.Receive
	self.bindData.sendButton.isSelected = self.selectedType ~= self.Tab_Type.Send
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)
	self.mailViewDataList = {}
	local emailIdList = computerCfg.EmailList

	for index, emailId in ipairs(emailIdList) do
		local isEmailCanShow = self.CheckEmailCanShow(self, emailId)

		if isEmailCanShow then
			local emailCfg = LTConfig.ComputerEmailConfig.GetConfig(emailId)

			if self.selectedType ~= self.Tab_Type.Receive and emailCfg.EmailType ~= self.Email_Type.Recipient then
				table.insert(self.mailViewDataList, {
					emailId = emailId,
					index = index
				})
			elseif self.selectedType ~= self.Tab_Type.Send and emailCfg.EmailType ~= self.Email_Type.Sender then
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

	self.bindData.emptyControl = #self.mailViewDataList ~= 0 and 1 or 0

	self:RefreshContentView(emailId)
end

M.CheckEmailHasUnlocked = function(self, emailId)
	local computerEmailInfo = self:GetComputerEmailInfo(emailId)

	return computerEmailInfo == nil
end

M.CheckEmailCanShow = function(self, emailId)
	if not self.CheckEmailHasUnlocked(self, emailId) then
		return false
	end

	if self.CheckEmailHasDeleted(self, emailId) then
		return false
	end

	return true
end

M.CheckEmailHasDeleted = function(self, targetEmailId)
	local computerInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo.ComputerInfos[self.computerId]

	if computerInfo then
		for _, emailId in ipairs(computerInfo.DeleteEmails) do
			if emailId ~= targetEmailId then
				return true
			end
		end
	end
end

M.GetComputerEmailInfo = function(self, emailId)
	local computerUnlockInfo = gPlayerManager.infoMinor.bindData.computerUnlockInfo

	return computerUnlockInfo and computerUnlockInfo.UnlockEmails and computerUnlockInfo.UnlockEmails[emailId]
end

M.OnRenderItem = function(self, btn, csIndex)
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
	store.button.isSelected = emailId ~= self.selectedEmailId

	store.button.luaClick = function()
		self:RefreshContentView(emailId)
	end

	store.button.enabledTooltip = self:CheckEnabledToolTips()
	store.button.tooltipMode = self:GetToolTipMode()
	store.button.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderToolTips, emailId)
end

M.OnMailItemFocus = function(self, _, csIndex)
	if SGUI.UNavigationMgr.Inst.CurNavigationMode == SGUI.NavigationMode.DPad then
		return
	end

	local data = self.mailViewDataList[csIndex + 1]

	if data then
		self.bindData.list:SetItemSelected(csIndex, true)
		self:RefreshContentView(data.emailId)
	end
end

M.GetToolTipMode = function(self)
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	return isMobile and 2 or 6
end

M.CheckEnabledToolTips = function(self)
	local computerCfg = LTConfig.ComputerConfig.GetConfig(self.computerId)

	return computerCfg.IsDelete
end

M.RefreshContentView = function(self, emailId)
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

		self.bindData.contentList.onGetTIndex = function(csIndex)
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

M.CheckCanShowReadMoreButton = function(self)
	local emailCfg = LTConfig.ComputerEmailConfig.GetConfig(self.selectedEmailId)

	return emailCfg and emailCfg.IsShowFloatWindow
end

M.OnRenderToolTips = function(self, emailId, _, popup, _)
	slot5 = gStoreManager
	local store = slot5:GetStoreGroup(popup.Store)

	store.onDeleteCallback = function()
		local rootGo = self.rootGo
		slot1 = gClientToGameDelegate

		slot1:AskComputerDeleteEmail(self.computerId, emailId).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
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

M.OnContentRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.contentDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local emailId = data.emailId
	local emailCfg = LTConfig.ComputerEmailConfig.GetConfig(emailId)

	if data.tIndex ~= self.Email_Content_Template.Info then
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

		if data.tIndex ~= self.Email_Content_Template.Type04 and emailCfg.TemplateLogo <= 0 then
			store.corpIconControl = 1
		end
	end
end

M.OnReceiveClick = function(self)
	if self.selectedType == self.Tab_Type.Receive then
		self.layoutSet = nil
		self.selectedType = self.Tab_Type.Receive

		self.RefreshPanelView(self)
	end
end

M.OnSendClick = function(self)
	if self.selectedType == self.Tab_Type.Send then
		self.layoutSet = nil
		self.selectedType = self.Tab_Type.Send

		self.RefreshPanelView(self)
	end
end

M.GetEmailNewState = function(self, emailId)
	if self.selectedType ~= self.Tab_Type.Send then
		return self.New_State_Control.HasRead
	end

	local hasRead = self:CheckEmailHasRead(emailId)

	return hasRead and self.New_State_Control.HasRead or self.New_State_Control.UnRead
end

M.CheckEmailHasRead = function(self, emailId)
	local computerEmailInfo = self.GetComputerEmailInfo(self, emailId)

	return computerEmailInfo.IsRead
end

M.SetEmailHasRead = function(self, emailId)
	slot2 = gMessageManager

	slot2:SendMessage(gEventConstants.ON_COMPUTER_EMAIL_READ, emailId)

	local hasRead = self:CheckEmailHasRead(emailId)
	slot3 = gReliableRpcManager

	slot3:RegisterRPC(gClientToGameDelegate.AskComputerEmailRead, emailId, function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			return
		end

		if not hasRead then
			local computerEmailInfo = self:GetComputerEmailInfo(emailId)
			computerEmailInfo.IsRead = true

			self.bindData.list:RefreshList()
		end
	end)
end

M.OnExitClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)
end

M.OnMinClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_COMPUTER_APP_CLOSE)
end

M.OnMaxClick = function(self)
end

M.OnReadMoreClick = function(self)
	self.bindData.contentList.normalizedScrollPosition = Vector2.Fetch(0, 0)
end

M.OnContentScroll = function(self)
	if self.CheckCanShowReadMoreButton(self) then
		if self.bindData.contentList.normalizedScrollPosition.y < LTConfig.ComputerConfig.MailScrollToBottomThreshold then
			self.bindData.readMoreButton:SetActive(false)
			self:AskComputerMailScrollToBottom()
		else
			self.bindData.readMoreButton:SetActive(true)
		end
	end
end

M.AskComputerMailScrollToBottom = function(self)
	if self.hasTriggerEmailScrollToBottom then
		return
	end

	self.hasTriggerEmailScrollToBottom = true
	slot1 = gMessageManager

	slot1:SendMessage(gEventConstants.ON_COMPUTER_MAIL_SCROLL_TO_BOTTOM, {
		mailId = self.selectedEmailId
	})

	slot1 = gReliableRpcManager

	slot1:RegisterRPC(gClientToGameDelegate.AskComputerEmailScrollToBottom, self.selectedEmailId, function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end)
end

M.OnLayoutSet = function(self)
	if self.layoutSet then
		return
	end

	self.layoutSet = true

	self.bindData.list:SetNavSelectToSelect(true)
end

M.OnContentScrollEnd = function(self)
	self.hasTriggerEmailScrollToBottom = false
end

M.OnDestroy = function(self)
	self.layoutSet = nil
	self.hasTriggerEmailScrollToBottom = nil

	self.ClearMessageEvents(self)
end
