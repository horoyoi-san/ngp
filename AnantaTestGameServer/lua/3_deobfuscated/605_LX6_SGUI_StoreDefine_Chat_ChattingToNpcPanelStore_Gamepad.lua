local M = C_ChattingToNpcPanelStore

function M:OnAwake_Gamepad()
	self.bindData.doNavigateIntoListBtn.luaClick = self:CreateAction(self.OnNavigateIntoListBtnClick)

	self.bindData.doNavigateIntoListBtn:SetActive(false)

	self.bindData.doNavigateBackToPanelButton.luaClick = self:CreateAction(self.OnNavigateBackToPanelBtnClick)
	self.isController = gClientUtils.IsControllerMode()

	FrameTimer.New(function ()
		if self.bindData.chatListNavArea then
			self.bindData.chatListNavArea.enabled = false
		end
	end, 1):Start()
end

function M:OnActiveDeviceChange(device)
	self.isController = SGUI.GameDevice.KeyboardMouse < device

	self:UpdateInteractiveChatItemBtnList()
end

function M:OnListScroll_Gamepad()
	self:UpdateInteractiveChatItemBtnList()
end

function M:UpdateInteractiveChatItemBtnList()
	if self.isController then
		local btnList = self:GetVisibleInteractiveChatItemBtnList()

		self.bindData.doNavigateIntoListBtn:SetActive(#btnList > 0)
	end
end

function M:OnNavigateIntoListBtnClick()
	local btnList = self:GetVisibleInteractiveChatItemBtnList()

	if #btnList == 0 then
		return
	end

	self.bindData.chatListNavArea.enabled = true
	local highestBtn = btnList[1]

	for i = 2, #btnList do
		local btn = btnList[i]

		if highestBtn.transform.anchoredPosition.y < btn.transform.anchoredPosition.y then
			highestBtn = btn
		end
	end

	local store = gStoreManager:GetStoreGroup(highestBtn.Store):GetStoreByWidget(highestBtn)
	self.bindData.chatListNavArea.CurrentActiveContent = store.btn

	self.bindData.doNavigateBackToPanelButton:SetActive(true)
end

function M:OnNavigateBackToPanelBtnClick()
	self.bindData.chatListNavArea.enabled = false

	if self.bindData.optionNavArea.enabled then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.optionNavArea
	else
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.baseNavArea
	end

	self.bindData.doNavigateBackToPanelButton:SetActive(false)
end

function M:ShowBottom_Gamepad(isShow)
	local optionNavArea = self.bindData.optionNavArea

	if isShow then
		optionNavArea.enabled = true

		FrameTimer.New(function ()
			if gClientUtils.NotNil(optionNavArea) and optionNavArea.enabled then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = optionNavArea
			end
		end, 1):Start()
	else
		optionNavArea.enabled = false
	end
end

function M:OnDisable_Gamepad()
	self:OnNavigateBackToPanelBtnClick()
end
