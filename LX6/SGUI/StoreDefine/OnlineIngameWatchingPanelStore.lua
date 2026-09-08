-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineIngameWatchingPanelStore.lua
-- Decompiled from: 01128_OnlineIngameWatchingPanelStore.lua_b6a2c8484f10.luajit

C_OnlineIngameWatchingPanelStore = DefClass("C_OnlineIngameWatchingPanelStore", C_OnlineIngameWatchingPanelStore, C_StoreGroup)
GroupName2Class.OnlineIngameWatchingPanelStore = C_OnlineIngameWatchingPanelStore
local M = C_OnlineIngameWatchingPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.nowWatchingPlayer = 0
	self.playerList = {}
	self.nowWatchingPlayerName = ""
	self.nowWatchingSelectIdx = -1
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	self:RegisterMessageEvents(self.msgEvents)
	LX6.GUI.GuiMgr.Instance:SetDisableJoystick(true, gBanId.ONLINE_WATCHING)

	self.nowWatchingPlayer = ulong.zero
	self.nowWatchingPlayerName = ""
	self.nowWatchingSelectIdx = -1

	if data and data.watchPlayer then
		self.nowWatchingPlayer = data.watchPlayer
	end

	if self.nowWatchingPlayer ~= ulong.zero then
		print_error("当前不存在可观战玩家！", data)

		return
	end

	self.RefreshWatchingTargetList(self)

	if not data.onlyShowName then
		self.ChangeWatchingTarget(self, self.nowWatchingPlayer)
	else
		slot3 = gFriendManager

		slot3:GetPlayerRealName(self.nowWatchingPlayer, function (name)
			self:ApplyWatchingPlayerName(name)
		end)
	end
end

M.OnClose = function(self)
	LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, gBanId.ONLINE_WATCHING)
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.CHARACTER_CONTROLS, true)
	self:ClearMessageEvents()
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ONLINE_INGAME_WATCH_PLAYER_CHANGE] = function (_, id)
			if not id or id ~= self.nowWatchingPlayer then
				return
			end

			self.nowWatchingPlayer = id
			self.nowWatchingPlayerName = ""
			self.nowWatchingSelectIdx = -1
			slot2 = self

			slot2:RefreshWatchingTargetList()

			slot2 = gFriendManager

			slot2:GetPlayerRealName(self.nowWatchingPlayer, function (name)
				self:ApplyWatchingPlayerName(name)
			end)
		end
	}
end

M.ApplyWatchingPlayerName = function(self, name)
	self.nowWatchingPlayerName = name

	if self.nowWatchingSelectIdx > 0 then
		self.bindData.selector:SetItemLabel(self.nowWatchingSelectIdx, name)
	end

	self.bindData.selector:RefreshOptions()
end

M.RegisterWidget = function(self)
	self.bindData.interacBtn.luaClick = self.CreateAction(self, "OnClickInteracBtn")
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnClickExitBtn")
	self.bindData.selector.luaRenderPopup = self.CreateAction(self, "OnSelectorRenderPopup")

	self.bindData.selector.luaSimpleOptionClick = function(btn, index)
		local data = self.playerList[index + 1]

		if data then
			self:ChangeWatchingTarget(data.playerId)
		end
	end

	self.bindData.selector.luaClick = self.CreateAction(self, "OnClickSelector")

	self.bindData.selector.luaOnPopup = function(isOpen)
		if isOpen then
			gCS.GuiUtils.SetPanelHideCursor(gPanelId.CHARACTER_CONTROLS, false)
		else
			gCS.GuiUtils.SetPanelHideCursor(gPanelId.CHARACTER_CONTROLS, true)
		end
	end

	self.bindData.selector.luaSimpleRenderSelector = function(selector, index)
		if self.nowWatchingPlayerName and self.nowWatchingPlayerName == "" then
			selector.title.text = self.nowWatchingPlayerName
		end
	end
end

M.OnClickInteracBtn = function(self)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_INGAME_WATCHING_MENU)
end

M.OnClickExitBtn = function(self)
	slot1 = gLinkManager

	slot1:ExitIngameWatching()

	slot1 = gClientToGameDelegate

	slot1:AskExitWatching().Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.OnSelectorRenderPopup = function(self, popup, list)
	list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderPopupListItem")

	list.RefreshList(list)
end

M.OnRenderPopupListItem = function(self, btn, index)
	local data = self.playerList[index + 1]
	local store = gStoreManager:GetStoreGroup("DropMenuBtn"):GetStoreByWidget(btn)

	if store and data then
		slot5 = gFriendManager

		slot5:GetPlayerRealName(data.playerId, function (name)
			store.title = name
		end)
	end
end

M.OnClickSelector = function(self)
	self.RefreshWatchingTargetList(self)
end

M.ChangeWatchingTarget = function(self, playerId)
	slot2 = gLinkManager

	slot2:AskWatchOnlinePlayer(playerId, function ()
		self.nowWatchingPlayer = playerId
		slot0 = gFriendManager

		slot0:GetPlayerRealName(self.nowWatchingPlayer, function (name)
			self:ApplyWatchingPlayerName(name)
		end)
	end, function ()
		self:RefreshWatchingTargetList()
	end)
end

M.RefreshWatchingTargetList = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskLinkWatcheeList().Callback = function (err, list)
		if err == LTConfig.MessageConfig.Ok then
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

			if list[i] ~= self.nowWatchingPlayer then
				selectedIndex = index
			end
		end

		local selectIdx = selectedIndex <= 0 and selectedIndex - 1 or #self.playerList <= 0 and 0 or -1
		self.nowWatchingSelectIdx = selectIdx

		self.bindData.selector:SetOptionsNoClose(#self.playerList)
		self.bindData.selector:SelectOption(selectIdx, false)

		if self.nowWatchingPlayerName == "" then
			self:ApplyWatchingPlayerName(self.nowWatchingPlayerName)
		end
	end
end
