C_OnlineIngameWatchingPanelStore = DefClass("C_OnlineIngameWatchingPanelStore", C_OnlineIngameWatchingPanelStore, C_StoreGroup)
GroupName2Class.OnlineIngameWatchingPanelStore = C_OnlineIngameWatchingPanelStore
local M = C_OnlineIngameWatchingPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.nowWatchingPlayer = 0
	self.playerList = {}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnShow(panelId, data)
	self:RegisterMessageEvents(self.msgEvents)
	LX6.GUI.GuiMgr.Instance:SetDisableJoystick(true, gBanId.ONLINE_WATCHING)

	self.nowWatchingPlayer = ulong.zero

	if data and data.watchPlayer then
		self.nowWatchingPlayer = data.watchPlayer
	end

	if self.nowWatchingPlayer == ulong.zero then
		print_error("当前不存在可观战玩家！", data)

		return
	end

	self:RefreshWatchingTargetList()

	if not data.onlyShowName then
		self:ChangeWatchingTarget()
	else
		gFriendManager:GetPlayerRealName(self.nowWatchingPlayer, function (name)
			self.bindData.nowWatchingText = name
		end)
	end
end

function M:OnClose()
	LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, gBanId.ONLINE_WATCHING)
	self:ClearMessageEvents()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ONLINE_INGAME_WATCH_PLAYER_CHANGE] = function (_, id)
			if not id or id == self.nowWatchingPlayer then
				return
			end

			self.nowWatchingPlayer = id

			self:RefreshWatchingTargetList()
			gFriendManager:GetPlayerRealName(self.nowWatchingPlayer, function (name)
				self.bindData.nowWatchingText = name
			end)
		end
	}
end

function M:RegisterWidget()
	self.bindData.interacBtn.luaClick = self:CreateAction("OnClickInteracBtn")
	self.bindData.exitBtn.luaClick = self:CreateAction("OnClickExitBtn")
	self.bindData.selector.luaRenderPopup = self:CreateAction("OnSelectorRenderPopup")
	self.bindData.selector.luaOptionClick = self:CreateAction("OnClickPopupListItem")
	self.bindData.selector.luaClick = self:CreateAction("OnClickSelector")
end

function M:OnClickInteracBtn()
	gPanelManager:CheckShow(gPanelId.S_ONLINE_INGAME_WATCHING_MENU)
end

function M:OnClickExitBtn()
	gLinkManager:ExitIngameWatching()

	gClientToGameDelegate:AskExitWatching().Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:OnSelectorRenderPopup(popup, list)
	list.luaRenderItem = self:CreateAction("OnRenderPopupListItem")

	list:RefreshList()
end

function M:OnRenderPopupListItem(btn, index)
	local data = self.playerList[index + 1]
	local store = gStoreManager:GetStoreGroup("DropMenuBtn"):GetStoreByWidget(btn)

	if store and data then
		gFriendManager:GetPlayerRealName(data.playerId, function (name)
			store.title = name
		end)
	end
end

function M:OnClickPopupListItem(btn, data)
	self:ChangeWatchingTarget(data.playerId)
end

function M:OnClickSelector()
	self:RefreshWatchingTargetList()
end

function M:ChangeWatchingTarget(playerId)
	gLinkManager:AskWatchOnlinePlayer(self.nowWatchingPlayer, function ()
		self.nowWatchingPlayer = playerId

		gFriendManager:GetPlayerRealName(self.nowWatchingPlayer, function (name)
			self.bindData.nowWatchingText = name
		end)
	end, function ()
		self:RefreshWatchingTargetList()
	end)
end

function M:RefreshWatchingTargetList()
	gClientToGameDelegate:AskLinkWatcheeList().Callback = function (err, list)
		if err ~= LTConfig.MessageConfig.Ok then
			print_error("AskLinkWatcheeList err = ", err)

			return
		end

		self.playerList = {}
		local index = 0
		local selectedIndex = 0

		for i = 1, #list do
			local sData = {
				playerId = list[i]
			}

			table.insert(self.playerList, sData)

			index = index + 1

			if list[i] == self.nowWatchingPlayer then
				selectedIndex = index
			end
		end

		self.bindData.selector:SetOptionsNoClose(self.playerList)
		self.bindData.selector:SelectOption(selectedIndex - 1, false)
	end
end
