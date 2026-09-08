-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\OnlineTablePanelStore.lua
-- Decompiled from: 01229_OnlineTablePanelStore.lua_915ee50a2bc4.luajit

C_OnlineTablePanelStore = DefClass("C_OnlineTablePanelStore", C_OnlineTablePanelStore, C_StoreGroup)
GroupName2Class.OnlineTablePanelStore = C_OnlineTablePanelStore
local M = C_OnlineTablePanelStore

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.InitData = function(self)
	self.instance = {
		flags = {}
	}

	self.InitSeatState(self)
end

M.OnAwake = function(self)
	self.InitData(self)

	self.bindData.matchBtn.luaClick = self.CreateAction(self, self.OnMatchBtnClick)
	self.bindData.cancelMatchBtn.luaClick = self.CreateAction(self, self.OnCancelMatchBtnClick)
	self.bindData.readyBtn.luaClick = self.CreateAction(self, self.OnReadyBtnClick)
	self.bindData.cancelReadyBtn.luaClick = self.CreateAction(self, self.OnCancelReadyBtnClick)
	self.bindData.leaveBtn.luaClick = self.CreateAction(self, self.OnLeaveBtnClick)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnStartBtnClick)
	self.bindData.showSettingBtn.luaClick = self.CreateAction(self, self.ShowSettingPanel)
	self.bindData.rStickNavRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnRStickRotateCamera)

	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(self.m_Id, 1)
end

M.InitSeatState = function(self)
	self.instance.seats = {}

	for i = 1, #gMaJiangConst.SeatOrder do
		local duty = gMaJiangConst.SeatOrder[i]
		self.instance.seats[duty] = {
			["CVϤ\\x81\\x96\\xc4\\xed"] = "",
			["\\xd0\\xc8;\n!\\xe3"] = false,
			["\\xd0\\xc8& \\xe8"] = false,
			["\\x9eab"] = 0
		}
	end
end

M.IsSelfReady = function(self)
	local seat = self.instance.seats[self.instance.session.duty]

	return seat == nil and seat.isReady ~= true
end

M.IsSelfOwner = function(self)
	local seat = self.instance.seats[self.instance.session.duty]

	return seat == nil and seat.isOwner ~= true
end

M.GetPlayerCount = function(self)
	local count = 0

	for i = 1, #gMaJiangConst.SeatOrder do
		local seat = self.instance.seats[gMaJiangConst.SeatOrder[i]]

		if seat and seat.pid == 0 then
			count = count + 1
		end
	end

	return count
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.MAJIANG_WORLD_BATTLE_ROOM_INFO] = function (_, info)
			self:ApplyMahjongWorldBattleRoomInfo(info)
		end,
		[gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL] = function (_, data)
			self:OnGameplayOutwardSignal(data)
		end,
		[gEventConstants.LINK_SEARCHING_STATE_CHANGE] = function ()
			self.instance.flags.matching = false

			self:RefreshActionState()
		end
	}
end

M.OnShow = function(self, panelId, data)
	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, self.GetMessageEvents(self))

	if data.onShowCallback then
		DoCallBack(data.onShowCallback)
	end

	local ui = {
		avatarWidgetList = {},
		avatarStoreList = {}
	}

	for k, v in ipairs(gMaJiangConst.seatStr) do
		local widget = self.bindData["avatar" .. v] or false

		table.insert(ui.avatarWidgetList, widget)

		local store = widget and gStoreManager:GetStoreGroup("S_CommonAccountAvatarMiddle1Store"):GetStoreByWidget(widget)

		table.insert(ui.avatarStoreList, store or false)

		if widget then
			widget.luaRenderTooltip = function(btn, tooltip, _)
				if store and store.userInfo and store.userInfo.pid == 0 then
					gSocialPalyerTooltipManager:OnRenderToolTips(store.userInfo.pid, btn, tooltip, _)
				else
					btn.CloseTooltip(btn)
				end
			end
		end
	end

	self.instance.ui = ui
	self.instance.flags = {
		["BIedO\n?"] = false,
		["\\xd5\\xde*\\xf6"] = false,
		["\\xa6\\xb0\\xa8b7\\xf04"] = false,
		["\\xd1\\xda1\"\\xe5"] = false
	}
	self.instance.session = {
		gadgetInstanceId = data and data.gadgetInstanceId or 0,
		seat = data and data.seat or 0,
		duty = data and data.duty or 0,
		multiPlayerId = data and data.multiPlayerId or 0
	}

	self:InitSeatState()

	local selfPid = gPlayerManager.infoBase.bindData.Pid
	local selfName = gFriendManager:GetPlayerRealName(selfPid) or ""

	self:SetSeatPlayerInfo(self.instance.session.duty, selfPid, selfName, false)
	self:RefreshTableState()
	self:ApplyMahjongWorldBattleRoomInfo(gMaJiangManager:GetMahjongWorldBattleRoomInfo())
	self:FlushGameRewards()
end

M.OnClose = function(self)
	if self.instance and self.instance.animatingTimer then
		self.instance.animatingTimer:Stop()

		self.instance.animatingTimer = nil
	end

	self.isRotatingCamera = false

	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(self.m_Id)
	self.ClearMessageEvents(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.instance = nil
	self.isRotatingCamera = nil
	self.rotateParam = nil
end

M.OnLeaveBtnClick = function(self)
	self.LeaveSeat(self)
end

M.LeaveSeat = function(self, isPanelClosing)
	local session = self.instance.session

	if session.gadgetInstanceId ~= 0 or session.multiPlayerId ~= 0 then
		return
	end

	local flags = self.instance.flags

	if flags.leaving or flags.hasLeft then
		return
	end

	flags.leaving = true
	slot4 = gMaJiangManager

	slot4:LeaveCurrentWorldBattle(session.gadgetInstanceId, session.duty, function (err)
		if not self.instance then
			return
		end

		self.instance.flags.leaving = false

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self.instance.flags.hasLeft = true
		self.instance.seats[session.duty].isReady = false

		if not isPanelClosing then
			self:ClosePanel()
		end
	end)
end

M.OnMatchBtnClick = function(self)
	local session = self.instance.session

	if session.multiPlayerId ~= 0 then
		return
	end

	gLinkManager:AskMatchBegin(session.multiPlayerId, true, function ()
	end)

	self.instance.flags.matching = true

	self:RefreshActionState()
end

M.OnCancelMatchBtnClick = function(self)
	gLinkManager:AskMatchCancel()

	self.instance.flags.matching = false

	self:RefreshActionState()
end

M.OnReadyBtnClick = function(self)
	self.ToggleReady(self, true, LTConfig.GameplaySignalInwardConfig.MahjongReadyStart)
end

M.ToggleReady = function(self, ready, signal)
	if self.IsSelfReady(self) ~= ready then
		return
	end

	if self.instance.session.gadgetInstanceId ~= 0 then
		return
	end

	slot3 = gClientToGameDelegate

	slot3:AskMahjongWorldBattleReady(self.instance.session.gadgetInstanceId, ready).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if not self.instance then
			return
		end

		self.instance.seats[self.instance.session.duty].isReady = ready

		self:RefreshActionState()
		self:RefreshSeatState()
		self:SendReadySignal(signal)
	end
end

M.OnCancelReadyBtnClick = function(self)
	self.ToggleReady(self, false, LTConfig.GameplaySignalInwardConfig.MahjongReadyEnd)
end

M.OnStartBtnClick = function(self)
	self.StartGame(self)
end

M.StartGame = function(self)
	local session = self.instance.session

	if session.gadgetInstanceId ~= 0 or not self.IsSelfOwner(self) then
		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskMahjongWorldBattleStart(session.gadgetInstanceId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnInviteBtnClick = function(self)
	self.OpenInvitePanel(self)
end

M.OpenInvitePanel = function(self)
	if not gTeamManager:IsInTeam() then
		gTeamManager:AskCreateTeam()

		return
	end

	if not gTeamManager:CheckCanInvite() then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_TEAM_INVITE_MENU)
end

M.SendReadySignal = function(self, signal)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal)
	end

	self.instance.flags.animating = true

	self.RefreshActionState(self)

	if self.instance.animatingTimer then
		self.instance.animatingTimer:Stop()
	end

	self.instance.animatingTimer = Timer.New(function ()
		if not self.instance then
			return
		end

		self.instance.flags.animating = false

		self:RefreshActionState()
	end, 2)

	self.instance.animatingTimer:Start()
end

M.OnGameplayOutwardSignal = function(self, data)
	local signal = data.GetCfgId(data)

	if signal == LTConfig.GameplaySignalOutwardConfig.MahjongReadyStartDone and signal == LTConfig.GameplaySignalOutwardConfig.MahjongReadyEndDone then
		return
	end

	local pid = data.GetPid(data)

	if not ulong.equals(pid, gCS.MyPlayerManager.PlayerUnitId) then
		return
	end

	if self.instance.animatingTimer then
		self.instance.animatingTimer:Stop()

		self.instance.animatingTimer = nil
	end

	self.instance.flags.animating = false

	self.RefreshActionState(self)
end

M.SetSeatPlayerInfo = function(self, duty, pid, playerName, isOwner)
	local seat = self.instance.seats[duty]
	seat.pid = pid or 0
	seat.playerName = playerName or ""
	seat.isOwner = isOwner ~= true

	if seat.pid ~= 0 then
		seat.isReady = false
	end
end

M.SetSeatReady = function(self, duty, ready)
	self.instance.seats[duty].isReady = ready ~= true
end

M.RefreshTableState = function(self)
	self.RefreshSeatState(self)
	self.RefreshActionState(self)
end

M.GetRelativeSeatIndex = function(self, duty)
	local seatIndex = 0

	for i = 1, #gMaJiangConst.SeatOrder do
		if gMaJiangConst.SeatOrder[i] ~= duty then
			seatIndex = i

			break
		end
	end

	if seatIndex ~= 0 or self.instance.session.seat ~= 0 then
		return 0
	end

	return (seatIndex - self.instance.session.seat + #gMaJiangConst.SeatOrder) % #gMaJiangConst.SeatOrder + 1
end

M.CanShowInviteBtn = function(self)
	if not gTeamManager:IsInTeam() then
		return true
	end

	if gTeamManager:IsTeamFull() then
		return false
	end

	return gTeamManager.allowMemberInvite or gTeamManager:IsTeamLeader()
end

M.CanStartGame = function(self)
	if not self.IsSelfOwner(self) then
		return false
	end

	local seats = self.instance.seats
	local selfDuty = self.instance.session.duty

	for i = 1, #gMaJiangConst.SeatOrder do
		local duty = gMaJiangConst.SeatOrder[i]

		if duty == selfDuty then
			local seat = seats[duty]

			if seat ~= nil or seat.pid ~= 0 or not seat.isReady then
				return false
			end
		end
	end

	return true
end

M.ApplyMahjongWorldBattleRoomInfo = function(self, info)
	local session = self.instance.session

	if info ~= nil or session.gadgetInstanceId ~= 0 or info.GadgetId == session.gadgetInstanceId then
		return
	end

	local wasOwner = self.IsSelfOwner(self)

	self.InitSeatState(self)

	local players = info.Players
	local selfPid = gPlayerManager.infoBase.bindData.Pid

	for i = 1, #players do
		local playerInfo = players[i]
		local pid = playerInfo.Pid
		local duty = playerInfo.Duty
		local isSelf = ulong.equals(pid, selfPid)
		local playerName = gFriendManager:GetPlayerRealName(isSelf and selfPid or pid) or ""

		self:SetSeatPlayerInfo(duty, pid, playerName, playerInfo.IsOwner)
		self:SetSeatReady(duty, playerInfo.Ready)
	end

	self.RefreshTableState(self)

	if not wasOwner and self.IsSelfOwner(self) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.MahjongOwnerChangeTips)
	end
end

M.RefreshSeatState = function(self)
	local seats = self.instance.seats
	local ui = self.instance.ui

	for i = 1, #gMaJiangConst.SeatOrder do
		local duty = gMaJiangConst.SeatOrder[i]
		local relativeIndex = self.GetRelativeSeatIndex(self, duty)

		if relativeIndex <= 1 then
			local widget = ui.avatarWidgetList[relativeIndex]
			local store = ui.avatarStoreList[relativeIndex]
			local seat = seats[duty]

			if gClientUtils.NotNil(widget) then
				local isEmpty = seat.pid ~= 0

				widget:TryChangePage("ready", isEmpty and 2 or seat.isReady and 1 or 0, true)
				widget:TryChangePage("isOwner", seat.isOwner and 1 or 0, true)
				widget:TryChangePage("isEmpty", isEmpty and 1 or 0, true)
			end

			if store and store.userInfo then
				store.userInfo.pid = seat.pid
			end
		end
	end
end

M.RefreshActionState = function(self)
	local selfReady = self.IsSelfReady(self)

	if gClientUtils.NotNil(self.rootWidget) and self.rootWidget.TryChangePage then
		self.rootWidget:TryChangePage("ready", selfReady and 1 or 0, true)
		self.rootWidget:TryChangePage("state", 0, true)
	end

	local flags = self.instance.flags
	local isOwner = self:IsSelfOwner()

	self.bindData.readyBtn:SetActive(not selfReady and not flags.animating)
	self.bindData.cancelReadyBtn:SetActive(selfReady and not flags.animating)
	self.bindData.leaveBtn:SetActive((not selfReady or isOwner) and not flags.animating)

	self.bindData.startBtn.interactable = self:CanStartGame()
	local isFull = self:GetPlayerCount() ~= 4

	self.bindData.startBtn:SetActive(isFull)
	self.bindData.inviteBtn:SetActive(self:CanShowInviteBtn())

	local isAlone = self:GetPlayerCount() ~= 1

	self.bindData.matchBtn:SetActive(isAlone and not flags.matching)
	self.bindData.cancelMatchBtn:SetActive(flags.matching)
end

M.ShowSettingPanel = function(self)
	gPanelManager:CheckShow(gPanelId.TABLE_SETTING_PANEL)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnUpdate = function(self)
	if self.isRotatingCamera then
		gCameraUtils:DoRotateCameraByGamePad(1, self.rotateParam.x, self.rotateParam.y)
	end
end

M.OnRStickRotateCamera = function(self, ctx)
	if ctx.canceled then
		self.isRotatingCamera = false
		self.rotateParam = nil
	else
		self.isRotatingCamera = true
		self.rotateParam = ctx.ReadValueVector2(ctx)
	end
end

M.FlushGameRewards = function(self)
	local rewards = gMaJiangManager:GetPendingGameRewards()

	if rewards ~= nil or #rewards ~= 0 then
		self.bindData.commonDropWidget:SetActive(false)

		return
	end

	local allItems = {}

	for i = 1, #rewards do
		local popupData = gItemUtils:ConvertRewardDetail(rewards[i])

		for j = 1, #popupData.AllItems do
			table.insert(allItems, popupData.AllItems[j])
		end
	end

	local store = gStoreManager:GetStoreGroup("PopupAreaManagePanelStore"):GetStoreByWidget(self.bindData.commonDropWidget)

	self.bindData.commonDropWidget:SetActive(true)
	gPopupAreaFiveDataRefresh:RefreshCommonDrop(store, {
		Param = allItems
	}, nil)

	gMaJiangManager.pendingGameRewards = nil
end
