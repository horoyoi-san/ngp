local M = C_NpcChatChattingPanelStore

function M:OnAwake_Gamepad()
	if self.bindData.doNavigateIntoListBtn then
		self.bindData.doNavigateIntoListBtn.luaClick = self:CreateAction("OnNavigateIntoListBtnClick")

		self.bindData.doNavigateIntoListBtn:SetActive(false)

		self.bindData.doNavigateBackToPanelButton.luaClick = self:CreateAction("OnNavigateBackToPanelBtnClick")
	end

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
	if self.bindData.doNavigateIntoListBtn and gClientUtils.IsControllerMode() then
		local btnList = self:GetVisibleInteractiveChatItemBtnList()

		self.bindData.doNavigateIntoListBtn:SetActive(#btnList > 0 and self.bindData.chatListNavArea.enabled ~= true)
	end
end

function M:OnNavigateIntoListBtnClick()
	local btnList = self:GetVisibleInteractiveChatItemBtnList()

	if #btnList == 0 then
		return
	end

	self.bindData.chatListNavArea.enabled = true
	local highestBtn = btnList[1]

	for i = 1, #btnList do
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
	if not self.bindData.chatListNavArea then
		return
	end

	self.bindData.chatListNavArea.enabled = false
	local inInvite = self.npcInviteGamePlay and self.npcInviteGamePlay ~= 0

	if self.bindData.optionNavArea.enabled and not inInvite then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.optionNavArea
	else
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.baseNavArea
	end

	self.bindData.doNavigateBackToPanelButton:SetActive(false)
end

function M:ShowBottom_Gamepad(isShow)
	local optionNavArea = self.bindData.optionNavArea

	if not optionNavArea then
		return
	end

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
