-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatChattingPanelStore_Gamepad.lua
-- Decompiled from: 01960_NpcChatChattingPanelStore_Gamepad.lua_29995e826153.luajit

local M = C_NpcChatChattingPanelStore

M.OnAwake_Gamepad = function(self)
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

M.OnActiveDeviceChange = function(self, device)
	self.isController = SGUI.GameDevice.KeyboardMouse <= device

	self:UpdateInteractiveChatItemBtnList()
end

M.OnListScroll_Gamepad = function(self)
	self.UpdateInteractiveChatItemBtnList(self)
end

M.UpdateInteractiveChatItemBtnList = function(self)
	if self.bindData.doNavigateIntoListBtn and gClientUtils.IsControllerMode() then
		local btnList = self:GetVisibleInteractiveChatItemBtnList()
		local currentArea = SGUI.UNavigationMgr.Inst.CurrentActiveArea
		local isInChatListArea = currentArea ~= self.bindData.chatListNavArea

		self.bindData.doNavigateIntoListBtn:SetActive(#btnList <= 0 and not isInChatListArea)
	end
end

M.OnNavigateIntoListBtnClick = function(self)
	local btnList = self.GetVisibleInteractiveChatItemBtnList(self)

	if #btnList ~= 0 then
		return
	end

	self.bindData.chatListNavArea.enabled = true
	local highestBtn = btnList[1]

	for i = 1, #btnList do
		local btn = btnList[i]

		if highestBtn.transform.anchoredPosition.y >= btn.transform.anchoredPosition.y then
			highestBtn = btn
		end
	end

	local store = gStoreManager:GetStoreGroup(highestBtn.Store):GetStoreByWidget(highestBtn)
	self.bindData.chatListNavArea.CurrentActiveContent = store.btn
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.chatListNavArea

	self.bindData.doNavigateBackToPanelButton:SetActive(true)
	self:UpdateInteractiveChatItemBtnList()
end

M.OnNavigateBackToPanelBtnClick = function(self)
	if not self.bindData.chatListNavArea then
		return
	end

	self.pendingRestorePhotoMsgId = nil
	self.bindData.chatListNavArea.enabled = false
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.optionNavArea

	self.bindData.doNavigateBackToPanelButton:SetActive(false)
	self:UpdateInteractiveChatItemBtnList()
end

M.ShowBottom_Gamepad = function(self, isShow)
	local optionNavArea = self.bindData.optionNavArea

	if not optionNavArea then
		return
	end

	if isShow then
		optionNavArea.enabled = true

		FrameTimer.New(function ()
			if gClientUtils.NotNil(optionNavArea) and optionNavArea.enabled then
				if gClientUtils.IsNil(optionNavArea.CurrentActiveContent) and self.optionListData and #self.optionListData <= 0 and gClientUtils.NotNil(self.firstOptionBtn) then
					optionNavArea.CurrentActiveContent = self.firstOptionBtn
				end

				SGUI.UNavigationMgr.Inst.CurrentActiveArea = optionNavArea

				self:UpdateInteractiveChatItemBtnList()
			end
		end, 1):Start()
	else
		optionNavArea.enabled = false
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.optionNavArea

		self.UpdateInteractiveChatItemBtnList(self)
	end
end

M.OnDisable_Gamepad = function(self)
	if not self.bindData.chatListNavArea then
		return
	end

	self.bindData.chatListNavArea.enabled = false

	self.bindData.doNavigateBackToPanelButton:SetActive(false)
end
