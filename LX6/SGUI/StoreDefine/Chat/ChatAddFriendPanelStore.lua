-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatAddFriendPanelStore.lua
-- Decompiled from: 01927_ChatAddFriendPanelStore.lua_ed87f8f8b297.luajit

C_ChatAddFriendPanelStore = DefClass("C_ChatAddFriendPanelStore", C_ChatAddFriendPanelStore, C_AppFragmentStore)
GroupName2Class.ChatAddFriendPanelStore = C_ChatAddFriendPanelStore
local M = C_ChatAddFriendPanelStore

M.OnAwake = function(self)
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, self.OnInputFieldValueChanged)
end

M.OnShow = function(self, _, data)
	self.bindData.inputField.onActivateAction = self.CreateAction(self, self.activity.OnInputFieldActivate)
	self.bindData.inputField.onDeActivateAction = self.CreateAction(self, self.activity.OnInputFieldDeActivate)

	self.ResetData(self)
	self.ResetUI(self)
end

M.ResetData = function(self)
	self.currentSearchId = 0
	self.inputValue = 0
	self.nextRequestTime = 0
end

M.ResetUI = function(self)
	self.bindData.inputField.text = ""
	self.bindData.resultCtrl = 2
end

M.OnRenderItem = function(self, btn, _, itemData)
	local store = self:GetStoreByWidget(btn)
	local pid = itemData.Pid

	gChatUtils.SetChatChannelCardBaseView(btn, gChatTopChannel.Friend, pid)

	store.name = gSocialFriendManager:GetPlayerDisplayName(pid, itemData.Name)
	store.showOnline = true
	store.playerStateCtrl = itemData.OnlineState

	if ulong.equals(pid, gPlayerManager.infoLogin.bindData.pid) then
		store.typeCtrl = 2

		return
	end

	local isFriend = gFriendManager:IsFriend(pid, true)
	local applied = gFriendManager:IsFriend(pid, false)

	if isFriend then
		store.typeCtrl = 3
	elseif applied then
		store.typeCtrl = 0
		store.applyBtn.luaClick = self.CreateActionWithArgs(self, self.OnApplyBtnClickEx, itemData)
	else
		store.typeCtrl = 0
		store.applyBtn.luaClick = self.CreateActionWithArgs(self, self.OnApplyBtnClick, itemData)
	end
end

M.OnApplyBtnClick = function(self, itemData, noBlackListCheck)
	local pid = itemData.Pid
	slot4 = gFriendManager

	slot4:AskApplyFriend(pid, function ()
		if ulong.equals(self.currentSearchId, pid) then
			self:DoSearch(pid)
		end
	end)
end

M.OnApplyBtnClickEx = function(self, itemData)
	slot2 = gFriendManager

	slot2:DeleteFriend(itemData.Pid, function ()
		self:OnApplyBtnClick(itemData)
	end, true)
end

M.OnInputFieldValueChanged = function(self, inputText)
	local text = string.gsub(inputText, "[^0-9]", "")
	text = string.sub(text, 1, 9)

	if text == inputText then
		self.bindData.inputField.text = text
	end

	if string.is_null_or_empty(text) then
		self.inputValue = nil
	else
		self.inputValue = tonumber(text)
	end
end

M.OnUpdate = function(self)
	if ulong.equals(self.currentSearchId or 0, self.inputValue or 0) then
		return
	end

	if self.inputValue ~= nil then
		self.ResetUI(self)

		return
	end

	local currentTime = Time.unscaledTime

	if currentTime >= self.nextRequestTime then
		return
	end

	self.DoSearch(self, self.inputValue)

	self.nextRequestTime = currentTime + LTConfig.NPCChatConfig.SearchFriendInterval
end

M.DoSearch = function(self, id)
	id = ulong.check(id) and id or ulong.new(id)
	self.currentSearchId = id

	local Callback = function(info)
		if not self.STATE_EnableOnce or self.currentSearchId == id then
			return
		end

		if info ~= nil or not info.Name then
			self.bindData.resultCtrl = 1

			return
		end

		self.bindData.resultCtrl = 0

		self:RefreshInfo(info)
	end

	gFriendManager:GetSimplePlayerInfo(id, Callback, true)
end

M.RefreshInfo = function(self, data)
	if data and gClientUtils.NotNil(self.bindData.itemBtn) then
		self.OnRenderItem(self, self.bindData.itemBtn, 0, data)
	end
end
