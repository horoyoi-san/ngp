-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartyInfoStore.lua
-- Decompiled from: 01078_PartyInfoStore.lua_06ca88d9ee78.luajit

C_PartyInfoStore = DefClass("C_PartyInfoStore", C_PartyInfoStore, C_StoreGroup)
GroupName2Class.PartyInfoStore = C_PartyInfoStore
local M = C_PartyInfoStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.allList = {}
	self.roomInfo = nil
	self.partyHudStore = nil
	self.InfoListTIndex = {
		["N'eO"] = 2,
		["y\\xa7\\xb6\\xa3\\xb3"] = 1,
		["`HygZ6"] = 0
	}
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
	self.RefreshInfoData(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.RefreshInfoData(self, data)
end

M.ShowPanel = function(self, data)
	self.RefreshInfoData(self, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_CUSTOM_ROOM_INFO_CHANGE] = self.CreateAction(self, "OnCustomRoomInfoChange"),
		[gEventConstants.ON_CUSTOM_ROOM_STATUS_CHANGE] = self.CreateAction(self, "OnCustomRoomChange"),
		[gEventConstants.ON_CUSTOM_ROOM_SETTING_CHANGE] = self.CreateAction(self, "OnCustomRoomChange"),
		[gEventConstants.ON_CUSTOM_ROOM_OWNER_CHANGE] = self.CreateAction(self, "OnCustomRoomChange")
	}
end

M.OnCustomRoomInfoChange = function(self, _, roomInfo)
	self.RefreshInfoData(self, roomInfo)
end

M.OnCustomRoomChange = function(self)
	self.RefreshInfoData(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.fullBaseBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.list.onGetTIndex = self.CreateAction(self, self.OnGetListTIndex)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
end

M.OnClickBackBtn = function(self)
	self.CloseHudTab(self)
end

M.OnGetListTIndex = function(self, index)
	return self.allList[index + 1].tIndex
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.allList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= self.InfoListTIndex.Countdown then
		self.RenderCountdownStore(self, store, data)
	elseif data.tIndex ~= self.InfoListTIndex.Title then
		self.RenderTitleStore(self, store, data)
	elseif data.tIndex ~= self.InfoListTIndex.Text then
		self.RenderTextStore(self, store, data)
	end
end

M.OnSimpleClickList = function(self, btn, index)
end

M.RefreshInfoData = function(self, roomInfo)
	self.roomInfo = roomInfo or gCustomRoomMgr:GetRoomInfo()

	self:RefreshPartyRoomName()

	local partyTypeCfg = self:GetPartyTypeCfg(self.roomInfo)
	self.allList = {
		{
			tIndex = self.InfoListTIndex.Countdown,
			roomInfo = self.roomInfo
		},
		{
			tIndex = self.InfoListTIndex.Title,
			content = LTConfig.TextScriptTextConfig.GetConfig(89901538).Text
		},
		{
			tIndex = self.InfoListTIndex.Text,
			content = partyTypeCfg and partyTypeCfg.Instructions or ""
		}
	}

	self.bindData.list:SetSimpleList(#self.allList)
end

M.RefreshPartyRoomName = function(self)
	self.bindData.partyName = ""
	local roomInfo = self.roomInfo

	if not roomInfo then
		return
	end

	local roomId = roomInfo.RoomId
	local roomName = roomInfo.Name or ""
	local ownerPid = roomInfo.OwnerPid

	gCustomRoomMgr:CanShowRoomUGC(ownerPid, function (bOk)
		if not self.roomInfo or not ulong.equals(self.roomInfo.RoomId, roomId) or self.roomInfo.Name == roomName or not ulong.equals(self.roomInfo.OwnerPid, ownerPid) then
			return
		end

		if bOk then
			self.bindData.partyName = roomName
		end
	end)
end

M.RenderCountdownStore = function(self, store, data)
	store.status = self:GetPartyStatusText(data.roomInfo)
	local roomInfo = data.roomInfo
	local isPreparing = roomInfo and roomInfo.Status ~= UX.Game.CustomRoomStatus.Preparing
	local showPrepareOverBtn = isPreparing and ulong.equals(roomInfo.OwnerPid, gPlayerManager.infoLogin.bindData.pid)
	store.showEarlierStartCtrl = showPrepareOverBtn and 0 or 1
	store.prepareOverBtn.luaClick = self:CreateAction("OnClickPrepareOverBtn")

	self:PlayCountdown(store.countdown, data.roomInfo)
end

M.RenderTitleStore = function(self, store, data)
	store.content = data.content
end

M.RenderTextStore = function(self, store, data)
	store.content = data.content
end

M.GetPartyStatusText = function(self, roomInfo)
	local partyTypeName = self.GetPartyTypeName(self, roomInfo)

	if roomInfo and roomInfo.Status ~= UX.Game.CustomRoomStatus.Preparing then
		return LTConfig.PartyConfig.PartyPreparingTitle:format(partyTypeName)
	end

	if roomInfo and roomInfo.Status ~= UX.Game.CustomRoomStatus.Playing then
		return LTConfig.PartyConfig.PartyInProgressTitle:format(partyTypeName)
	end

	return partyTypeName
end

M.GetPartyTypeName = function(self, roomInfo)
	local partyTypeCfg = self:GetPartyTypeCfg(roomInfo)

	return partyTypeCfg and partyTypeCfg.Name or ""
end

M.GetPartyTypeCfg = function(self, roomInfo)
	local partyInfo = roomInfo and roomInfo.PartyInfo
	local partyConfigId = partyInfo and partyInfo.PartyConfigId
	local partyCfg = partyConfigId and LTConfig.PartyConfig.GetConfig(partyConfigId)

	return partyCfg and LTConfig.PartyPartyTypeConfig.GetConfig(partyCfg.Type) or nil
end

M.PlayCountdown = function(self, countdown, roomInfo)
	countdown:Stop()

	local overTime = roomInfo and roomInfo.CurrentStatusOverTime or 0
	local remainTime = overTime - gLuaDataManager.serverTime

	if remainTime <= 0 then
		countdown.Play(countdown, remainTime)
	end
end

M.OnClickPrepareOverBtn = function(self)
	local rightCallBack = function()
		gReliableRpcManager:RegisterRPC(gClientToGameDelegate.PartyPrepareOver, function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			self:RefreshInfoData()
			self:CloseHudTab()
		end)
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.OlinePartyForceStart, rightCallBack, nil)
end

M.GetPartyHudStore = function(self)
	if not self.partyHudStore then
		self.partyHudStore = gStoreManager:GetStoreGroup("PartyHudPanelStore")
	end

	return self.partyHudStore
end

M.CloseHudTab = function(self)
	self:GetPartyHudStore():CloseCurrentTab()
end
