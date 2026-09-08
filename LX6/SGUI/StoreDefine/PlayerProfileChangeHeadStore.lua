-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerProfileChangeHeadStore.lua
-- Decompiled from: 00807_PlayerProfileChangeHeadStore.lua_2d1673f436c2.luajit

C_PlayerProfileChangeHeadStore = DefClass("C_PlayerProfileChangeHeadStore", C_PlayerProfileChangeHeadStore, C_StoreGroup)
GroupName2Class.PlayerProfileChangeHeadStore = C_PlayerProfileChangeHeadStore
local M = C_PlayerProfileChangeHeadStore
M.HeadType = {
	["/Q\\x82\\x9a\\x86L"] = 0
}
M.TabType = {
	["R'|_"] = 1,
	["kBmmh="] = 2
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.tabIdx = 1
	self.avaliableHeads = {}
	self.avaliableHeadFrames = {}
	self.selectedHeadIdx = 0
	self.usingHeadIdx = 0
	self.selectedHeadFrameIdx = 0
	self.usingHeadFrameIdx = 0
	self.btnStores = {}
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnClickListItem)
	self.bindData.btnSave.luaClick = self.CreateAction(self, self.OnClickSave)
	self.bindData.btnExit.luaClick = self.CreateAction(self, self.OnClickExit)
	self.bindData.btnExit2.luaClick = self.CreateAction(self, self.OnClickExit)
end

M.OnShow = function(self, panelId, data)
	if not data or not data.pid then
		return
	end

	self.pid = data.pid
	self.name = data.name or ""

	self:LoadData()

	local tabIdx = data.isFrame and 2 or 1

	self.SubGroup.CommonTabSingleStore:SetData(self.tabList, nil, tabIdx - 1, nil, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))
	self:RefreshPanel()
	self:CloseOther()
end

M.CloseOther = function(self)
	local toClose = {
		gPanelId.PLAYER_PROFILE_CHANGE_BACKGROUND_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_BIRTHDAY_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_NOTE_PANEL,
		gPanelId.PLAYER_PROFILE_CHANGE_POPUP_BACKGROUND_PANEL
	}

	for _, v in ipairs(toClose) do
		if gPanelManager:IsPanelShowing(v) then
			gPanelManager:Close(v)
		end
	end
end

M.LoadData = function(self)
	self.tabList = {
		{
			title = LTConfig.ImageAvatarConfig.UIImageAvatar or "1",
			tabType = self.TabType.Head
		},
		{
			title = LTConfig.ImageAvatarConfig.UIImageAvatarFrame or "2",
			tabType = self.TabType.HeadFrame
		}
	}

	self:LoadData_Heads()
	self:LoadData_HeadFrames()
end

M.LoadData_Heads = function(self)
	self.avaliableHeads = {}
	local sexType = gPlayerManager.infoLogin.bindData.sexType

	for i = 0, LTConfig.ImageNewAvatarConfig.count - 1 do
		local config = LTConfig.ImageNewAvatarConfig.LoadAt(i)
		local bContinue = true

		if config.Id ~= LTConfig.ImageNewAvatarConfig.AdultMH and sexType ~= UX.Game.SexType.Female or config.Id ~= LTConfig.ImageNewAvatarConfig.AdultFH and sexType ~= UX.Game.SexType.Male then
			bContinue = false
		end

		if bContinue then
			table.insert(self.avaliableHeads, {
				["[\\xae\\x80\\x86V"] = false,
				id = config.Id
			})

			local curLinkHead = gPlayerManager.infoLogin.bindData.infoLinkPzHeadInfo

			if curLinkHead and curLinkHead.SystemHeadId ~= config.Id then
				self.selectedHeadIdx = #self.avaliableHeads
				self.usingHeadIdx = self.selectedHeadIdx
			end
		end
	end
end

M.LoadData_HeadFrames = function(self)
	self.avaliableHeadFrames = {
		{
			["\t\r"] = 0,
			["t#p^"] = "T-s^",
			["s!rU"] = 0
		}
	}

	self.QueryUserHeadFrameInfo(self, function (list)
		local curLinkHead = gPlayerManager.infoLogin.bindData.infoLinkPzHeadInfo

		for _, v in ipairs(list) do
			local id = v
			local cfg = LTConfig.ImageAvatarFrameConfig.GetConfig(id)

			if cfg then
				table.insert(self.avaliableHeadFrames, {
					id = v,
					name = cfg.ImageName,
					quality = cfg.Quality,
					icon = cfg.Resourceid
				})

				if curLinkHead and curLinkHead.AvatarFrame and curLinkHead.AvatarFrame ~= v then
					self.selectedHeadFrameIdx = #self.avaliableHeadFrames
					self.usingHeadFrameIdx = self.selectedHeadFrameIdx
				end
			else
				print_error("#NoCreateIssue ImageAvatarFrameConfig not found", id)
			end
		end

		self:RefreshPanel()
	end)
end

M.QueryUserHeadInfo = function(self, callback)
	slot2 = gClientToGameDelegate

	slot2:QueryPersonalZoneHeadExtendInfo().Callback = function (err, info)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			callback(info)
		end
	end
end

M.QueryUserHeadFrameInfo = function(self, callback)
	slot2 = gClientToGameDelegate

	slot2:AskQueryPlayerUnlockAvatarFrame().Callback = function (err, info)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			callback(info)
		end
	end
end

M.RefreshPanel = function(self)
	local tabType = self.GetCurrentTabType(self)
	self.btnStores = {}

	if tabType ~= self.TabType.Head then
		self.RefreshPanel_Head(self)
	elseif tabType ~= self.TabType.HeadFrame then
		self.RefreshPanel_HeadFrame(self)
	end

	self.RefreshHead(self)
end

M.RefreshPanel_Head = function(self)
	self.bindData.list:SetSimpleList(#self.avaliableHeads)

	self.bindData.name.text = self.name

	self.bindData.list:SelectItem(self.selectedHeadIdx - 1, false)
end

M.RefreshPanel_HeadFrame = function(self)
	self.bindData.list:SetSimpleList(#self.avaliableHeadFrames)
	self.bindData.list:SelectItem(self.selectedHeadFrameIdx - 1, false)
end

M.RefreshHead = function(self)
	local head = self.avaliableHeads[self.selectedHeadIdx]
	local headFrame = self.avaliableHeadFrames[self.selectedHeadFrameIdx]

	if head then
		local iconId, name = gHunLunManager:GetHeadIconAndName(head.id)
		self.bindData.name.text = name

		self.bindData:Commit("icon", iconId, COMMIT_FORCE)
	end

	self.bindData.showFrameCtrl = BOOL2CTL[headFrame and headFrame.icon and headFrame.icon >= 0]

	if headFrame then
		self.bindData:Commit("iconFrame", headFrame.icon, COMMIT_FORCE)
	end
end

M.OnRenderTabItem = function(self, btn, index, data, store, isSub, uList)
	local data = self.tabList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.title = data.title
end

M.OnChangeTab = function(self, uList, isSub)
	local index = uList.selectedIndex + 1
	self.tabIdx = index

	self.RefreshPanel(self)
end

M.GetCurrentTabType = function(self)
	local tab = self.tabList[self.tabIdx]

	return tab.tabType
end

M.OnRenderListItem = function(self, widget, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	local tabType = self.GetCurrentTabType(self)
	local iconId, data = nil

	if tabType ~= self.TabType.Head then
		local data = self.avaliableHeads[index]
		iconId, _ = gHunLunManager:GetHeadIconAndName(data and data.id)
		store.usingCtrl = BOOL2CTL[self.usingHeadIdx ~= index]
	elseif tabType ~= self.TabType.HeadFrame then
		data = self.avaliableHeadFrames[index]
		iconId = data.icon
		store.usingCtrl = BOOL2CTL[self.usingHeadFrameIdx ~= index]
	end

	store:Commit("icon", iconId or 0, COMMIT_IMMEDIATELY)

	self.btnStores[index] = store
	store.showCtrl = BOOL2CTL[true]
end

M.OnClickListItem = function(self, _, index)
	index = index + 1

	self.bindData.list:SelectItem(index - 1, false)

	local tabType = self:GetCurrentTabType()

	if tabType ~= self.TabType.Head then
		self.selectedHeadIdx = index
	elseif tabType ~= self.TabType.HeadFrame then
		self.selectedHeadFrameIdx = index
	end

	self.RefreshHead(self)
end

M.OnClickSave = function(self)
	if self.selectedHeadIdx <= 0 then
		local rpcCnt = 2

		local RpcCallback = function(err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			else
				rpcCnt = rpcCnt - 1

				if rpcCnt ~= 0 then
					self:UpdateCacheDataAfterHeadChange(function ()
						gMessageManager:SendMessage(gEventConstants.PLAYER_PROFILE_INFO_CHANGED)
					end)
					self:OnClickExit()
				end
			end
		end

		local headInfo = self.avaliableHeads[self.selectedHeadIdx]
		local headFrame = self.avaliableHeadFrames[self.selectedHeadFrameIdx]
		gClientToGameDelegate:AskUpdatePersonalZoneHead(self.HeadType.System, headInfo.id, true).Callback = RpcCallback
		gClientToGameDelegate:AskUpdatePlayerAvatarFrame(headFrame and headFrame.id or 0).Callback = RpcCallback
	end
end

M.UpdateCacheDataAfterHeadChange = function(self, callback)
	self.QueryUserHeadInfo(self, function (info)
		gPlayerManager.infoLogin.bindData.infoPzHeadInfo = info.PzHeadInfo
		gPlayerManager.infoLogin.bindData.infoLinkPzHeadInfo = info.LinkPzHeadInfo
		slot1 = gLinkPlayerHub.cs

		slot1:GetSimplePlayerInfo(gPlayerManager.infoLogin.bindData.pid, function ()
		end, true)

		if callback then
			callback()
		end
	end)
end

M.OnClickExit = function(self)
	gPanelManager:Close(gPanelId.PLAYER_PROFILE_CHANGE_HEAD_PANEL)
end

M.OnActiveDeviceChange = function(self, device)
end
