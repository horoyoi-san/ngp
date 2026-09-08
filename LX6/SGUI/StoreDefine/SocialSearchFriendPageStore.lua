-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialSearchFriendPageStore.lua
-- Decompiled from: 01288_SocialSearchFriendPageStore.lua_64057defca1a.luajit

C_SocialSearchFriendPageStore = DefClass("C_SocialSearchFriendPageStore", C_SocialSearchFriendPageStore, C_StoreGroup)
GroupName2Class.SocialSearchFriendPageStore = C_SocialSearchFriendPageStore
local M = C_SocialSearchFriendPageStore

M.ctor = function(self)
	self.ResultCtrl = {
		["\\xf7\\xd4=1\\xe5"] = 2,
		["h\\xa3\\xb2\\xbb\\xaf"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.FriendTypeCtrl = {
		[":Z\\x98\\x8b\\x8dE"] = 3,
		["I'q]"] = 2,
		["\\xf8\\xcb!\\xf5"] = 1,
		["T-s^"] = 0
	}
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.deleteBtn.luaClick = self.CreateAction(self, "OnDeleteBtnClick")
	self.bindData.searchBtn.luaClick = self.CreateAction(self, "OnSearchBtnClick")
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputFieldValueChanged")

	self.ResetUI(self)
end

M.OnEnable = function(self)
	self:ResetUI()
	FrameTimer.New(function ()
		self.bindData.inputField:ActivateInputField()
	end, 5):Start()
end

M.OnShow = function(self, data)
	self.parentNavi = data
	self.bindData.navi.leftNav = self.parentNavi
end

M.SetData = function(self, _, data)
	self.ResetUI(self)
end

M.ResetUI = function(self)
	self.currentSearchId = ""
	self.inputValue = ""
	self.nextRequestTime = 0
	self.bindData.inputField.text = ""
	self.bindData.resultCtrl = self.ResultCtrl.NoInput

	self.bindData.deleteBtn:SetActive(false)
end

M.OnInputFieldValueChanged = function(self, inputText)
	local text = string.gsub(inputText, "[^0-9]", "")
	text = string.sub(text, 1, 15)

	if text == inputText then
		self.bindData.inputField.text = text
	end

	self.currentSearchId = ""

	if string.is_null_or_empty(text) then
		self.inputValue = ""

		self.bindData.deleteBtn:SetActive(false)
	else
		self.inputValue = text

		self.bindData.deleteBtn:SetActive(true)
	end
end

M.OnUpdate = function(self)
	if self.currentSearchId ~= self.inputValue then
		return
	end

	if string.is_null_or_empty(self.inputValue) then
		self.ResetUI(self)

		return
	end

	local currentTime = Time.unscaledTime

	if currentTime >= self.nextRequestTime then
		return
	end

	self.DoSearch(self, self.inputValue)

	self.nextRequestTime = currentTime + 1
end

M.DoSearch = function(self, idStr)
	local pid = gCS.LuaUtils.StringToUlong(idStr)
	self.currentSearchId = idStr

	local Callback = function(info)
		if not self.STATE_EnableOnce or self.currentSearchId == idStr then
			return
		end

		if info ~= nil or not info.Name then
			self.bindData.resultCtrl = 1

			return
		end

		self.bindData.resultCtrl = 0

		self:RefreshInfo(info)
	end

	gFriendManager:GetSimplePlayerInfo(pid, Callback, true)
end

M.RefreshInfo = function(self, data)
	if data and gClientUtils.NotNil(self.bindData.resultItem) then
		self.SetPlayerData(self, self.bindData.resultItem, data)
	end
end

M.SetPlayerData = function(self, btn, itemData)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.userInfo.pid = itemData.Pid
	local pid = itemData.Pid
	store.headBtn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderHeadToolTips", pid)

	if ulong.equals(pid, gPlayerManager.infoLogin.bindData.pid) then
		store.typeCtrl = self.FriendTypeCtrl.Self

		return
	end

	local isFriend = gSocialFriendManager:IsFriend(pid)

	if isFriend then
		store.typeCtrl = self.FriendTypeCtrl.Friend
		store.chatBtn.luaClick = self.CreateActionWithArgs(self, "OnChatBtnClick", itemData)
	else
		store.typeCtrl = self.FriendTypeCtrl.None
		store.addBtn.luaClick = self.CreateActionWithArgs(self, "OnApplyBtnClick", {
			item = itemData,
			store = store
		})
	end
end

M.OnRenderHeadToolTips = function(self, pid, btn, PopUp, _)
	local store = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore"):GetStoreByWidget(PopUp)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, PopUp, _)
end

M.OnApplyBtnClick = function(self, data)
	local pid = data.item.Pid

	if gSocialFriendManager:IsInBlackList(pid) then
		slot3 = gDisplayMessageMgr

		slot3:ShowMessage(LTConfig.MessageConfig.SocialRemoveFromBlacklistAndAddFriend, function ()
			slot0 = gSocialFriendManager

			slot0:RemoveFromBlackList(pid, function ()
				gSocialFriendManager:ApplyFriend(pid)

				data.store.typeCtrl = self.FriendTypeCtrl.Applied
			end)
		end)
	else
		gSocialFriendManager:ApplyFriend(pid)

		data.store.typeCtrl = self.FriendTypeCtrl.Applied
	end
end

M.OnChatBtnClick = function(self, itemData)
	gSocialChatManager:JumpToChat(gSocialChatManager.ChatTopChannel.Friend, itemData.Pid)
end

M.OnDeleteBtnClick = function(self)
	self.bindData.inputField.text = ""

	self.ResetUI(self)
end

M.OnBackBtnClick = function(self)
	gStoreManager:GetStoreGroup("SocialFriendPageStore"):SetBackPage()
end
