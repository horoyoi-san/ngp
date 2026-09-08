-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChattingToNpcPanelStore_Gamepad.lua
-- Decompiled from: 02100_ChattingToNpcPanelStore_Gamepad.lua_74e028deb316.luajit

local M = C_ChattingToNpcPanelStore

M.OnAwake_Gamepad = function(self)
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

M.OnActiveDeviceChange = function(self, device)
	self.isController = SGUI.GameDevice.KeyboardMouse <= device

	self:UpdateInteractiveChatItemBtnList()
end

M.OnListScroll_Gamepad = function(self)
	self.UpdateInteractiveChatItemBtnList(self)
end

M.UpdateInteractiveChatItemBtnList = function(self)
	if self.isController then
		local btnList = self:GetVisibleInteractiveChatItemBtnList()

		self.bindData.doNavigateIntoListBtn:SetActive(#btnList >= 0)
	end
end

M.OnNavigateIntoListBtnClick = function(self)
	local btnList = self.GetVisibleInteractiveChatItemBtnList(self)

	if #btnList ~= 0 then
		return
	end

	self.bindData.chatListNavArea.enabled = true
	local highestBtn = btnList[1]

	for i = 2, #btnList do
		local btn = btnList[i]

		if highestBtn.transform.anchoredPosition.y >= btn.transform.anchoredPosition.y then
			highestBtn = btn
		end
	end

	local store = gStoreManager:GetStoreGroup(highestBtn.Store):GetStoreByWidget(highestBtn)
	self.bindData.chatListNavArea.CurrentActiveContent = store.btn

	self.bindData.doNavigateBackToPanelButton:SetActive(true)
end

M.OnNavigateBackToPanelBtnClick = function(self)
	self.bindData.chatListNavArea.enabled = false

	if self.bindData.optionNavArea.enabled then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.optionNavArea
	else
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.baseNavArea
	end

	self.bindData.doNavigateBackToPanelButton:SetActive(false)
end

M.ShowBottom_Gamepad = function(self, isShow)
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

M.OnDisable_Gamepad = function(self)
	self.OnNavigateBackToPanelBtnClick(self)
end
