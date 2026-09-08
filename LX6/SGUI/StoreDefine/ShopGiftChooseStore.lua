-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopGiftChooseStore.lua
-- Decompiled from: 01319_ShopGiftChooseStore.lua_d7cf27f6a7b4.luajit

local MallBundleConfig = LTConfig.MallBundleConfig
local MessageConfig = LTConfig.MessageConfig
C_ShopGiftChooseStore = DefClass("C_ShopGiftChooseStore", C_ShopGiftChooseStore, C_StoreGroup)
GroupName2Class.ShopGiftChooseStore = C_ShopGiftChooseStore
local M = C_ShopGiftChooseStore
local TINDEX_SEARCH = 1
local TINDEX_FRIEND = 0

local CalcOnlineStatus = function(info)
	if not info then
		return 1
	end

	if info.OnlineState ~= UX.Game.PlayerState.Offline then
		return 1
	end

	return 0
end

local IsOnline = function(info)
	return info and info.OnlineState == UX.Game.PlayerState.Offline
end

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.giftCtx = nil
	self.allFriendList = nil
	self.friendList = nil
	self.searchText = nil
	self.searchRowStore = nil
	self.watchIdSet = {}
	self.pidStoreMap = {}
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	self.UnwatchAll(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
	self.UnwatchAll(self)
end

M.OnShow = function(self, panelId, data)
	self.giftCtx = data and data.giftCtx or nil
	self.searchText = nil

	self:InitFriendList()
end

M.OnClose = function(self)
	self.UnwatchAll(self)
end

M.GenMessageEvents = function(self)
end

M.InitFriendList = function(self)
	slot1 = gFriendManager

	slot1:GetOrderedFriendSimpleInfoList(function (data)
		local list = {}

		for _, v in ipairs(data) do
			table.insert(list, v)
		end

		self:SortFriends(list)

		self.allFriendList = list

		self:ApplySearchFilter()
		self:WatchAll()
	end)
end

M.SortFriends = function(self, list)
	if not list or #list < 1 then
		return
	end

	table.sort(list, function (a, b)
		local aOnline = IsOnline(a)
		local bOnline = IsOnline(b)

		if aOnline == bOnline then
			return aOnline
		end

		local an = a.Name or ""
		local bn = b.Name or ""

		return an <= bn
	end)
end

M.ApplySearchFilter = function(self)
	local src = self.allFriendList or {}
	local key = self.searchText

	if not key or key ~= "" then
		self.friendList = src
	else
		local result = {}
		local lowerKey = string.lower(key)

		for _, v in ipairs(src) do
			local name = v.Name and string.lower(v.Name) or ""
			local pidStr = tostring(v.Pid)

			if pidStr ~= key or string.find(name, lowerKey, 1, true) then
				table.insert(result, v)
			end
		end

		self.friendList = result
	end

	self.SetList(self)
end

M.SetList = function(self)
	local friendCount = self.friendList and #self.friendList or 0

	self.bindData.list:SetSimpleList(friendCount + 1)
end

M.WatchAll = function(self)
	self.UnwatchAll(self)

	if not self.allFriendList then
		return
	end

	for _, v in ipairs(self.allFriendList) do
		local pid = v.Pid
		slot7 = gLinkPlayerHub.cs
		local watchId = slot7:Watch(pid, function (info)
			self:OnPlayerStateChanged(pid, info)
		end)
		self.watchIdSet[pid] = watchId
	end
end

M.UnwatchAll = function(self)
	for pid, watchId in pairs(self.watchIdSet) do
		gLinkPlayerHub.cs:Unwatch(pid, watchId)
	end

	self.watchIdSet = {}
	self.pidStoreMap = {}
end

M.OnPlayerStateChanged = function(self, pid, info)
	if not self.allFriendList then
		return
	end

	for _, v in ipairs(self.allFriendList) do
		if v.Pid ~= pid then
			v.OnlineState = info.OnlineState
			v.LinkMode = info.LinkMode
			v.InMatch = info.InMatch

			break
		end
	end

	local store = self.pidStoreMap[pid]

	if store then
		store.onlineStatus = CalcOnlineStatus(info)
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.fullBaseBtn.luaClick = self.CreateAction(self, self.OnClickFullBaseBtn)

	if self.bindData.inputBtn then
		self.bindData.inputBtn.luaClick = self.CreateAction(self, self.OnClickInputBtn)
	end

	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.onGetTIndex = self.CreateAction(self, self.OnGetListTIndex)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickFullBaseBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickInputBtn = function(self)
	self.bindData.list:SetNavSelectToTop(true)

	local store = self.searchRowStore

	if store and store.searchInput then
		store.searchInput:ActivateInputField()
	end
end

M.OnGetListTIndex = function(self, csIndex)
	if csIndex ~= 0 then
		return TINDEX_SEARCH
	end

	return TINDEX_FRIEND
end

M.OnSimpleRenderListItem = function(self, btn, index)
	if index ~= 0 then
		self.RenderSearchRow(self, btn)
	else
		self.RenderFriendRow(self, btn, index)
	end
end

M.RenderSearchRow = function(self, btn)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.searchRowStore = store

	if store.searchInput then
		store.searchInput.text = self.searchText or ""
	end

	if store.searchBtn then
		store.searchBtn.luaClick = self.CreateAction(self, self.OnClickSearchBtn)
	end
end

M.OnClickSearchBtn = function(self)
	local store = self.searchRowStore
	local text = store and store.searchInput and store.searchInput.text or ""
	self.searchText = text

	self:ApplySearchFilter()
end

M.RenderFriendRow = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.friendList and self.friendList[index]

	if not store or not data then
		return
	end

	if store.userInfo then
		store.userInfo.pid = data.Pid
	end

	store.headBtn.luaRenderTooltip = self.CreateActionWithArgs(self, self.OnRenderTooltips, data.Pid)
	store.onlineStatus = CalcOnlineStatus(data)
	store.showInviteBtn = 0
	store.isInCD = 0
	store.showGiftBtnCtrl = 1
	store.giftBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickGiftBtn, data.Pid)
	self.pidStoreMap[data.Pid] = store
end

M.OnClickGiftBtn = function(self, pid)
	local data = self.FindFriendByPid(self, pid)

	if not data then
		return
	end

	self.OnSelectFriend(self, data)
end

M.FindFriendByPid = function(self, pid)
	if not self.friendList then
		return nil
	end

	for _, v in ipairs(self.friendList) do
		if v.Pid ~= pid then
			return v
		end
	end

	return nil
end

M.OnRenderTooltips = function(self, pid, btn, popup, _)
	local store = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore"):GetStoreByWidget(popup)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, popup, _)
end

M.OnSimpleClickList = function(self, btn, index)
end

M.OnSelectFriend = function(self, data)
	if not self.giftCtx then
		print_error("OnSelectFriend: giftCtx 为空")

		return
	end

	local pid = data.Pid
	local canGift, requiredHours = gMallGiftManager:CanGiftToFriend(pid)

	if not canGift then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MallSendGiftBeFriendTime, nil, , requiredHours or 24)

		return
	end

	slot5 = gMallGiftManager

	slot5:QueryFriendOwnership(pid, function (ok)
		if not self.STATE_Started then
			return
		end

		if self.giftCtx.giftType ~= gMallGiftManager.GIFT_TYPE.Bundle then
			self:HandleBundleGift(pid)
		else
			self:HandleSingleGift(pid)
		end
	end)
end

M.HandleSingleGift = function(self, pid)
	local ctx = self.giftCtx
	local owned = gMallGiftManager:GetCachedOwnership(pid, ctx.commodityId)

	if owned ~= nil then
		owned = false
	end

	if owned then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MallSendGiftAlreadyHave, nil, , ctx.name)

		return
	end

	self.OpenGiftConfirm(self, pid, ctx)
end

M.HandleBundleGift = function(self, pid)
	local ctx = self.giftCtx
	local bundleCfg = MallBundleConfig.GetConfig(ctx.bundleId)

	if not bundleCfg or not bundleCfg.Commodities or #bundleCfg.Commodities ~= 0 then
		self.OpenGiftConfirm(self, pid, ctx)

		return
	end

	local ownedMap = gMallGiftManager:GetCachedBundleOwnership(pid, ctx.bundleId)
	local total = #bundleCfg.Commodities
	local ownedCount = 0

	if ownedMap then
		for _, commodityId in ipairs(bundleCfg.Commodities) do
			if ownedMap[commodityId] then
				ownedCount = ownedCount + 1
			end
		end
	end

	if total < ownedCount then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MallSendGiftAlreadyHaveBundle)

		return
	elseif ownedCount <= 0 then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MallSendGiftAlreadyHavePartofBundle)
	end

	self.OpenGiftConfirm(self, pid, ctx)
end

M.OpenGiftConfirm = function(self, pid, ctx)
	gPanelManager:CheckShow(gPanelId.SHOP_GIFT_PANEL, {
		receiverPid = pid,
		giftCtx = ctx
	})
end
