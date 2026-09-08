-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQGameManager.lua
-- Decompiled from: 00675_BBQGameManager.lua_d3932c520399.luajit

C_BBQGameManager = DefClass("C_BBQGameManager", C_BBQGameManager, gBaseMiniGameManager)
local BBQGameManager = C_BBQGameManager
local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")

local GetCommonText = function(id)
	local cfg = LTConfig.TextCommonTextConfig.GetConfig(id)

	return cfg and cfg.Text or ""
end

BBQGameManager.ctor = function(self)
	self.currentGame = nil
	self.panelRef = nil
	self.m_HasShownOnlineEnd = false
	self.m_InvitedNpcCultivationIds = {}
	self.m_BBQEntityInstanceId = nil
	self.m_OnPartyInviteNpc = nil
end

BBQGameManager.RegisterInviteListener = function(self)
	if self.m_OnPartyInviteNpc then
		return
	end

	self.m_OnPartyInviteNpc = function(_, param)
		self:OnPartyInviteNpc(param)
	end

	gMessageManager:AddMessageListener(gEventConstants.ON_PARTY_INVITE_NPC, self.m_OnPartyInviteNpc)
end

BBQGameManager.UnregisterInviteListener = function(self)
	if not self.m_OnPartyInviteNpc then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.ON_PARTY_INVITE_NPC, self.m_OnPartyInviteNpc)

	self.m_OnPartyInviteNpc = nil
end

BBQGameManager.OnPartyInviteNpc = function(self, param)
	local ids = {}
	local list = param and param.entityIdList

	if list then
		for _, entityId in ipairs(list) do
			local cultivationId = self:GetNpcCultivationIdByEntityId(entityId)

			if cultivationId and cultivationId == 0 then
				table.insert(ids, cultivationId)
			end
		end
	end

	self.m_InvitedNpcCultivationIds = ids

	self:UnregisterInviteListener()
	self:DoStartSinglePlayerGame()
end

BBQGameManager.GetNpcCultivationIdByEntityId = function(self, entityId)
	local unit = gCS.SceneDataMgr.GetUnit(entityId)
	local clientData = unit and unit.ClientData

	if not clientData then
		return 0
	end

	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(clientData.cardId)

	return spiritCfg and spiritCfg.NpcCultivationRelatedId or 0
end

BBQGameManager.GetInvitedNpcCultivationIds = function(self)
	return self.m_InvitedNpcCultivationIds or {}
end

BBQGameManager.GetSinglePlayerSeatNpcMap = function(self)
	local map = {}
	local invitedIds = self:GetInvitedNpcCultivationIds()

	for i, seat in ipairs(BBQConstants.AISeatIndices) do
		map[seat] = invitedIds[i]
	end

	return map
end

BBQGameManager.BuildSinglePlayerGameArgs = function(self)
	local occupiedSeats = {
		[BBQConstants.LocalSeatIndex] = true
	}

	for seat in pairs(self:GetSinglePlayerSeatNpcMap()) do
		occupiedSeats[seat] = true
	end

	return {
		totalTime = BBQConstants.DefaultGameTime,
		prepareTime = BBQConstants.DefaultPrepareTime,
		sceneNodeGo = self.sceneNodeGo,
		occupiedSeats = occupiedSeats
	}
end

BBQGameManager.StartBBQGame = function(self, sceneNodeGo, entityInstanceId)
	if self.currentGame then
		print_warn("[BBQGameManager] 游戏已在运行中，先销毁旧游戏")
		self:DestroyGame()
	end

	self.sceneNodeGo = sceneNodeGo
	self.m_BBQEntityInstanceId = entityInstanceId

	if gLinkManager:CheckInLinkMode() then
		print_debug("[BBQGameManager] 联机模式启动占位，等待 OnSyncZoneInfo")

		return
	end

	self:RegisterInviteListener()
end

BBQGameManager.DoStartSinglePlayerGame = function(self)
	self.currentGame = gBBQGame.new(self:BuildSinglePlayerGameArgs())

	if not self.currentGame:StartGame() then
		self:StopBBQGame()

		return
	end

	self:SetPlayerMoveBanned(true)

	if self.m_BBQEntityInstanceId then
		gSpoonClientMgr:TryCallInnerSignal(self.m_BBQEntityInstanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, "BBQGameStart")
	else
		print_warn("[BBQGameManager] 缺 entityInstanceId，无法回发 BBQGameStart 信号")
	end

	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_START_PANEL, {
		callBack = function ()
			gPanelManager:CheckShow(gPanelId.BBQ_PANEL_STORE, {
				seconds = BBQConstants.DefaultGameTime
			})
		end
	})
end

BBQGameManager.StopBBQGame = function(self)
	if gLinkManager:CheckInLinkMode() then
		self:RpcLeaveBBQ()
	end

	if self.currentGame then
		self.currentGame:CleanupAndDestroy()
	end

	self:DestroyGame()
	gPanelManager:Close(gPanelId.S_CHALLENGE_START_PANEL)
	gPanelManager:Close(gPanelId.BBQ_PANEL_STORE)

	self.panelRef = nil

	self:SetPlayerMoveBanned(false)

	self.m_InvitedNpcCultivationIds = {}

	self:UnregisterInviteListener()

	self.m_BBQEntityInstanceId = nil
end

BBQGameManager.SetPlayerMoveBanned = function(self, banned)
	LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(not banned, gBanId.BBQ_GAME)
	LX6.GUI.GuiMgr.Instance:SetDisableJoystick(banned, gBanId.BBQ_GAME)
end

BBQGameManager.RestartBBQGame = function(self)
	local sceneNodeGo = self.sceneNodeGo

	if self.currentGame then
		self.currentGame:CleanupAndDestroy()
	end

	self:DestroyGame()

	self.sceneNodeGo = sceneNodeGo
	self.currentGame = gBBQGame.new(self:BuildSinglePlayerGameArgs())

	if not self.currentGame:StartGame() then
		self:StopBBQGame()

		return
	end

	self.m_HasShownOnlineEnd = false

	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_START_PANEL, {
		callBack = function ()
			if self.panelRef then
				self.panelRef:OnRestart()
			end
		end
	})
end

BBQGameManager.DestroyGame = function(self)
	BBQGameManager.base.DestroyGame(self)

	self.sceneNodeGo = nil
end

BBQGameManager.OnPrepareEnd = function(self)
end

BBQGameManager.OnGameTimerUp = function(self)
	if self.panelRef then
		self.panelRef:OnGameTimerUp()
	end
end

BBQGameManager.AddPlayerScore = function(self, playerId, singleScore, cookedLevel, authoritativeTotal)
	if self.panelRef then
		self.panelRef:OnPlayerScore(playerId, singleScore, cookedLevel, authoritativeTotal)
	end
end

BBQGameManager.CapturePressTarget = function(self, screenX, screenY)
	if self.currentGame and self.currentGame.CapturePressTarget then
		self.currentGame:CapturePressTarget(screenX, screenY)
	end
end

BBQGameManager.ClearPressTarget = function(self)
	if self.currentGame and self.currentGame.ClearPressTarget then
		self.currentGame:ClearPressTarget()
	end
end

BBQGameManager.OnPlayerBeginDrag = function(self)
	if self.currentGame then
		self.currentGame:OnPlayerBeginDrag()
	end
end

BBQGameManager.OnPlayerEndDrag = function(self)
	if self.currentGame then
		self.currentGame:OnPlayerEndDrag()
	end
end

BBQGameManager.OnPlayerClick = function(self)
	if self.currentGame then
		self.currentGame:OnPlayerClick()
	end
end

local GAMEPAD_PLATE_NAMES = {
	"\\x89\\x934\\x9bf?\\xea6",
	"MT\\x9dG@\\xb3\\xe6B*2/",
	"MT\\x9dG@\\xb3\\xe6B*2,",
	"MT\\x9dG@\\xb3\\xe6B*2-",
	"MT\\x9dG@\\xb3\\xe6B*2*"
}

BBQGameManager.OnGamepadPickFromPlate = function(self, plateIndex)
	if not self.currentGame then
		return
	end

	local plateName = GAMEPAD_PLATE_NAMES[plateIndex]

	if not plateName then
		return
	end

	self.currentGame:OnPlayerBeginDragFromPlate(plateName)
end

BBQGameManager.OnGamepadPickOrPlace = function(self)
	if not self.currentGame then
		return
	end

	local player = self.currentGame:GetPlayer(self.currentGame.mySeatIndex or BBQConstants.LocalSeatIndex)

	if not player then
		return
	end

	local busy = player.hasEnterDrag or self.currentGame.IsPickupInFlight and self.currentGame:IsPickupInFlight()

	if busy then
		self.currentGame:OnPlayerEndDrag()
	else
		self.currentGame:OnPlayerBeginDrag()
	end
end

BBQGameManager.OnGamepadFlip = function(self)
	if not self.currentGame then
		return
	end

	local player = self.currentGame:GetPlayer(self.currentGame.mySeatIndex or BBQConstants.LocalSeatIndex)

	if player and player.hasEnterDrag then
		return
	end

	self.currentGame:OnPlayerClick()
end

BBQGameManager.OnGamepadScoreToPlayer = function(self, playerId)
	if self.currentGame then
		self.currentGame:OnPlayerScoreToBowl(playerId)
	end
end

BBQGameManager.OnPlayerDropHeld = function(self)
	if self.currentGame then
		self.currentGame:OnPlayerDropHeld()
	end
end

BBQGameManager.BuildResultPanelParams = function(self, isOnline)
	local bbqConfig = LTConfig.PartyMiniGameConfig.GetConfig(LTConfig.PartyMiniGameConfig.BBQ)

	if not bbqConfig then
		return {}
	end

	local linkConfig = LTConfig.LinkMultiPlayerConfig.GetConfig(bbqConfig.MultiPlayerId)

	if not linkConfig then
		return {}
	end

	local endPanelCfg = LTConfig.LinkEndPanelTypeConfig.GetConfig(linkConfig.EndPanelType)
	local succeedTitle = ""
	local failedTitle = ""

	if endPanelCfg then
		local winTitleCfg = endPanelCfg.WinTitle and LTConfig.TextCommonTextConfig.GetConfig(endPanelCfg.WinTitle)
		succeedTitle = winTitleCfg and winTitleCfg.Text or ""
		local failTitleCfg = endPanelCfg.FailTitle and LTConfig.TextCommonTextConfig.GetConfig(endPanelCfg.FailTitle)
		failedTitle = failTitleCfg and failTitleCfg.Text or ""
	end

	local endColNameIds = endPanelCfg and endPanelCfg.EndColName or {
		0,
		0,
		0,
		0
	}
	local endColWidths = endPanelCfg and endPanelCfg.EndColWidth or {
		100,
		100,
		100,
		100
	}
	local alignments = endPanelCfg and endPanelCfg.Alignment or {
		0,
		0,
		0,
		1
	}
	local columnDefs = {
		{
			["\\xe6R<\\xd1\\xb3h\\xafR\\xb5\\xae"] = 3,
			colType = gLinkManager.COL_TYPE.RANK,
			headerName = GetCommonText(endColNameIds[1]),
			width = endColWidths[1],
			alignment = alignments[1]
		},
		{
			["\\xe6R<\\xd1\\xb3h\\xafR\\xb5\\xae"] = 2,
			colType = gLinkManager.COL_TYPE.PLAYER,
			headerName = GetCommonText(endColNameIds[2]),
			width = endColWidths[2],
			alignment = alignments[2]
		},
		{
			["\\xdd\\xda 5!\\xe8"] = "^\\xad\\xad\\xbd\\xb3",
			["\\xe6R<\\xd1\\xb3h\\xafR\\xb5\\xae"] = 1,
			colType = gLinkManager.COL_TYPE.CUSTOM_TEXT,
			headerName = GetCommonText(endColNameIds[3]),
			width = endColWidths[3],
			alignment = alignments[3]
		}
	}

	if isOnline then
		table.insert(columnDefs, {
			["\\xe6R<\\xd1\\xb3h\\xafR\\xb5\\xae"] = 7,
			colType = gLinkManager.COL_TYPE.ACTION,
			headerName = GetCommonText(endColNameIds[4]),
			width = endColWidths[4],
			alignment = alignments[4]
		})
	end

	return {
		["JT_|M+"] = true,
		succeedTitle = succeedTitle,
		failedTitle = failedTitle,
		columnDefs = columnDefs
	}
end

BBQGameManager.OnGameResultReady = function(self, rankListData)
	local showList = {}

	for _, item in ipairs(rankListData) do
		table.insert(showList, {
			["t\\x95\\x87\\x8fб\\xdc>\\xbb\\xbf 3"] = 0,
			customFields = {
				score = tostring(item.score)
			},
			playerName = item.playerName,
			playerHeadIcon = item.playerHeadIcon,
			playerNumber = item.playerNumber,
			playerColor = item.playerColor
		})
	end

	local params = self:BuildResultPanelParams()
	params.data = showList
	params.showAgain = true

	params.onClickAgain = function()
		gBBQGameManager:OnGameEndFromUI(1)
	end

	params.onClickBack = function()
		gBBQGameManager:OnGameEndFromUI(0)
	end

	gPanelManager:CheckShow(gPanelId.COMMON_SINGLE_TEAM_RANK, params)
end

BBQGameManager.OnGameResultReadyOnline = function(self, showList)
	local params = self:BuildResultPanelParams(true)
	params.data = showList
	params.autoLeaveTime = LTConfig.LinkConfig.ClearingMaxTime

	params.onClickBack = function()
		gBBQGameManager:OnGameEndOnlineFromUI()
	end

	gPanelManager:CheckShow(gPanelId.COMMON_TEAM_RANK, params)
end

BBQGameManager.OnGameEndOnlineFromUI = function(self)
	self:StopBBQGame()
	gPanelManager:Close(gPanelId.COMMON_TEAM_RANK)
end

BBQGameManager.OnGameEndFromUI = function(self, data)
	if data ~= 1 then
		self:RestartBBQGame()
	else
		self:StopBBQGame()
	end
end

BBQGameManager.OnSyncZoneInfo = function(self, uid, zoneInfo, fromRpc)
	print_debug("[BBQ] OnSyncZoneInfo uid=", uid, " fromRpc=", fromRpc, " participants=", zoneInfo and zoneInfo.ParticipantInfos and #zoneInfo.ParticipantInfos or 0)

	self._bbq_gadgetId = uid

	if zoneInfo.SyncReason ~= UX.Game.GameGroundZoneSyncReason.ReEnterFromLogin then
		print_debug("[BBQ] ReEnterFromLogin（长断线重登），无法复原，退出 BBQ")
		self:StopBBQGame()

		return
	end

	if not self.currentGame then
		local mySeatIndex = self:_FindMySeatIndex(zoneInfo)

		if mySeatIndex >= 0 then
			print_error("[BBQ] OnSyncZoneInfo 找不到本机 SeatIndex，pid=", gPlayerManager.infoLogin.bindData.pid)

			return
		end

		local args = {
			gadgetUId = uid,
			sceneNodeGo = self.sceneNodeGo,
			zoneInfo = zoneInfo
		}
		self.currentGame = gBBQGameOnline.new(args)
		self.currentGame.mySeatIndex = mySeatIndex

		if not self.currentGame:StartGame() then
			print_warn("[BBQ] OnSyncZoneInfo StartGame 失败，sceneNodeGo 已失效")
			self:StopBBQGame()

			return
		end

		self.m_HasShownOnlineEnd = false

		if zoneInfo.ParticipantInfos then
			for _, info in ipairs(zoneInfo.ParticipantInfos) do
				self.currentGame:OnServerEnterRoom(info)
			end
		end
	elseif zoneInfo.SyncReason ~= UX.Game.GameGroundZoneSyncReason.RePrepare then
		print_debug("[BBQ] OnSyncZoneInfo RePrepare — 重置游戏状态")
		self.currentGame:ResetForPlayAgain(zoneInfo)

		self.m_HasShownOnlineEnd = false
	elseif zoneInfo.ZoneState ~= UX.Game.GameGroundZoneState.GameOver then
		print_debug("[BBQ] OnSyncZoneInfo ReEnter 发现本局已 GameOver，补弹结算")
		self:OnReconnectGameOver(zoneInfo)
	elseif self.currentGame.OnSyncZoneInfo then
		self.currentGame:OnSyncZoneInfo(zoneInfo)
	end
end

BBQGameManager.OnReconnectGameOver = function(self, zoneInfo)
	if self.m_HasShownOnlineEnd then
		return
	end

	if not self.currentGame then
		return
	end

	if zoneInfo.ParticipantInfos then
		for _, info in ipairs(zoneInfo.ParticipantInfos) do
			if self.currentGame.OnServerEnterRoom then
				self.currentGame:OnServerEnterRoom(info)
			end
		end
	end

	local endInfo = {
		FinalScores = zoneInfo.PlayerScores
	}

	self:OnSyncBBQGameEnd(self._bbq_gadgetId, endInfo)
end

BBQGameManager._FindMySeatIndex = function(self, zoneInfo)
	local myPid = gPlayerManager.infoLogin.bindData.pid

	if not zoneInfo.ParticipantInfos then
		return -1
	end

	for _, info in ipairs(zoneInfo.ParticipantInfos) do
		if ulong.equals(info.Pid, myPid) then
			return info.SeatIndex
		end
	end

	return -1
end

BBQGameManager.OnServerEnterRoom = function(self, uid, participantInfo, add, remove)
	print_debug("[BBQ] OnServerEnterRoom uid=", uid, " seat=", participantInfo and participantInfo.SeatIndex, " add=", add, " remove=", remove)

	if uid == self._bbq_gadgetId then
		return
	end

	if remove and participantInfo then
		local myPid = gPlayerManager.infoLogin.bindData.pid

		if ulong.equals(participantInfo.Pid, myPid) then
			print_debug("[BBQ] 本机被移出 Zone，退出玩法")
			self:StopBBQGame()

			return
		end
	end

	if not self.currentGame then
		return
	end

	if self.currentGame.OnServerEnterRoom then
		self.currentGame:OnServerEnterRoom(participantInfo, add, remove)
	end
end

BBQGameManager.OnGameStateChange = function(self, uid, state, countDownInfo)
	print_debug("[BBQ] OnGameStateChange uid=", uid, " state=", state, " countDown=", countDownInfo)

	if uid == self._bbq_gadgetId then
		return
	end

	if not self.currentGame then
		return
	end

	if state ~= UX.Game.GameGroundZoneState.GameStart then
		self:SetPlayerMoveBanned(true)

		if self.currentGame.OnBattleStart then
			self.currentGame:OnBattleStart()
		end

		if gPanelManager:IsPanelShowing(gPanelId.BBQ_PANEL_STORE) then
			gPanelManager:Close(gPanelId.BBQ_PANEL_STORE)
		end

		local displayRemain = 0

		if countDownInfo and countDownInfo.DisplayCountDownEndTime and countDownInfo.DisplayCountDownEndTime <= 0 then
			local now = LTUtils.UXTime.GetNowUnixTime()
			displayRemain = math.max(0, countDownInfo.DisplayCountDownEndTime - now)
		end

		gPanelManager:CheckShow(gPanelId.S_CHALLENGE_START_PANEL, {
			seconds = displayRemain,
			callBack = function ()
				gPanelManager:CheckShow(gPanelId.BBQ_PANEL_STORE, {
					seconds = self.currentGame and self.currentGame.totalTime or BBQConstants.DefaultGameTime
				})
			end
		})
	elseif state ~= UX.Game.GameGroundZoneState.Dispose then
		print_debug("[BBQ] Zone Dispose — 退出 BBQ 玩法")
		self:StopBBQGame()
	end
end

BBQGameManager.OnSyncBBQMeatCreated = function(self, uid, meatInfo, creatorSeatIndex)
	print_debug("[BBQ] OnSyncBBQMeatCreated uid=", uid, " meatId=", meatInfo and meatInfo.MeatId, " creatorSeat=", creatorSeatIndex)

	if uid == self._bbq_gadgetId then
		return
	end

	if self.currentGame and self.currentGame.OnSyncMeatCreated then
		self.currentGame:OnSyncMeatCreated(meatInfo, creatorSeatIndex)
	end
end

BBQGameManager.OnSyncBBQMeatPlacedOnGrill = function(self, uid, meatId, grillPosition)
	print_debug("[BBQ] OnSyncBBQMeatPlacedOnGrill uid=", uid, " meatId=", meatId)

	if uid == self._bbq_gadgetId then
		return
	end

	if self.currentGame and self.currentGame.OnSyncMeatPlacedOnGrill then
		self.currentGame:OnSyncMeatPlacedOnGrill(meatId, grillPosition)
	end
end

BBQGameManager.OnSyncBBQMeatPickedFromGrill = function(self, uid, meatId, pickerSeatIndex, updatedInfo)
	print_debug("[BBQ] OnSyncBBQMeatPickedFromGrill uid=", uid, " meatId=", meatId, " pickerSeat=", pickerSeatIndex)

	if uid == self._bbq_gadgetId then
		return
	end

	if self.currentGame and self.currentGame.OnSyncMeatPickedFromGrill then
		self.currentGame:OnSyncMeatPickedFromGrill(meatId, pickerSeatIndex, updatedInfo)
	end
end

BBQGameManager.OnSyncBBQMeatFlipped = function(self, uid, meatId, flipperSeatIndex, updatedInfo)
	print_debug("[BBQ] OnSyncBBQMeatFlipped uid=", uid, " meatId=", meatId, " flipperSeat=", flipperSeatIndex)

	if uid == self._bbq_gadgetId then
		return
	end

	if self.currentGame and self.currentGame.OnSyncMeatFlipped then
		self.currentGame:OnSyncMeatFlipped(meatId, flipperSeatIndex, updatedInfo)
	end
end

BBQGameManager.OnSyncBBQMeatScored = function(self, uid, meatId, targetSeatIndex, result)
	print_debug("[BBQ] OnSyncBBQMeatScored uid=", uid, " meatId=", meatId, " targetSeat=", targetSeatIndex, " total=", result and result.PlayerNewTotalScore)

	if uid == self._bbq_gadgetId then
		return
	end

	if self.currentGame and self.currentGame.OnSyncMeatScored then
		self.currentGame:OnSyncMeatScored(meatId, targetSeatIndex, result)
	end
end

BBQGameManager.OnSyncBBQMeatDropped = function(self, uid, meatId)
	print_debug("[BBQ] OnSyncBBQMeatDropped uid=", uid, " meatId=", meatId)

	if uid == self._bbq_gadgetId then
		return
	end

	if self.currentGame and self.currentGame.OnSyncMeatDropped then
		self.currentGame:OnSyncMeatDropped(meatId)
	end
end

BBQGameManager.OnSyncBBQChopstickState = function(self, uid, seatIndex, state)
	if uid == self._bbq_gadgetId then
		return
	end

	if self.currentGame and self.currentGame.OnRemoteChopstick then
		self.currentGame:OnRemoteChopstick(seatIndex, state)
	end
end

BBQGameManager.OnSyncBBQGameEnd = function(self, uid, endInfo)
	print_debug("[BBQ] OnSyncBBQGameEnd uid=", uid, " finalScores=", endInfo and endInfo.FinalScores and "(dict)" or "nil")

	if uid == self._bbq_gadgetId then
		return
	end

	if self.m_HasShownOnlineEnd then
		print_debug("[BBQ] OnSyncBBQGameEnd 已结算过，忽略重复结算")

		return
	end

	self.m_HasShownOnlineEnd = true

	if self.currentGame and self.currentGame.OnGameEnd then
		self.currentGame:OnGameEnd(endInfo)
	end

	if self.panelRef and self.panelRef.OnGameEndOnline then
		self.panelRef:OnGameEndOnline(endInfo)
	end

	gPanelManager:Close(gPanelId.BBQ_PANEL_STORE)
end

local BBQ_RPC_RETRY_INTERVAL = 0.2
local BBQ_RPC_MAX_WAIT_TIME = 15

BBQGameManager.RpcPickupMeatFromPlate = function(self, meatType)
	if not self._bbq_gadgetId then
		return
	end

	self:SendBBQRpc("BBQPickupMeatFromPlate", function ()
		return gClientToGameSceneDelegate:BBQPickupMeatFromPlate(self._bbq_gadgetId, meatType)
	end, nil, function (err)
		if self.currentGame and self.currentGame.OnPickupRejected then
			self.currentGame:OnPickupRejected()
		end
	end)
end

BBQGameManager.RpcPutMeatOnGrill = function(self, meatId, grillPosition)
	if not self._bbq_gadgetId then
		return
	end

	self:SendBBQRpc("BBQPutMeatOnGrill", function ()
		return gClientToGameSceneDelegate:BBQPutMeatOnGrill(self._bbq_gadgetId, meatId, grillPosition)
	end, nil, function (err)
		if self.currentGame and self.currentGame.OnPlaceMeatRpcFailed then
			self.currentGame:OnPlaceMeatRpcFailed(meatId)
		end
	end)
end

BBQGameManager.RpcPickupMeatFromGrill = function(self, meatId)
	if not self._bbq_gadgetId then
		return
	end

	self:SendBBQRpc("BBQPickupMeatFromGrill", function ()
		return gClientToGameSceneDelegate:BBQPickupMeatFromGrill(self._bbq_gadgetId, meatId)
	end, nil, function (err)
		if self.currentGame and self.currentGame.OnPickupRejected then
			self.currentGame:OnPickupRejected()
		end
	end)
end

BBQGameManager.RpcFlipMeat = function(self, meatId)
	if not self._bbq_gadgetId then
		return
	end

	self:SendBBQRpc("BBQFlipMeat", function ()
		return gClientToGameSceneDelegate:BBQFlipMeat(self._bbq_gadgetId, meatId)
	end)
end

BBQGameManager.RpcPutMeatToBowl = function(self, meatId, targetSeatIndex)
	if not self._bbq_gadgetId then
		return
	end

	self:SendBBQRpc("BBQPutMeatToBowl", function ()
		return gClientToGameSceneDelegate:BBQPutMeatToBowl(self._bbq_gadgetId, meatId, targetSeatIndex)
	end, nil, function (err)
		if self.currentGame and self.currentGame.OnPlaceMeatRpcFailed then
			self.currentGame:OnPlaceMeatRpcFailed(meatId)
		end
	end)
end

BBQGameManager.RpcDropMeat = function(self, meatId)
	if not self._bbq_gadgetId then
		return
	end

	self:SendBBQRpc("BBQDropMeat", function ()
		return gClientToGameSceneDelegate:BBQDropMeat(self._bbq_gadgetId, meatId)
	end, nil, function (err)
		if self.currentGame and self.currentGame.OnPlaceMeatRpcFailed then
			self.currentGame:OnPlaceMeatRpcFailed(meatId)
		end
	end)
end

BBQGameManager.RpcLeaveBBQ = function(self)
	if not self._bbq_gadgetId then
		return
	end

	self:SendBBQRpc("LeaveBBQ", function ()
		return gClientToGameSceneDelegate:LeaveBBQ(self._bbq_gadgetId)
	end)
end

BBQGameManager.SendBBQRpc = function(self, rpcName, rpcFunc, onSuccess, onFail)
	if gLuaDataManager.isNetworkAvailable and gCS.NetworkManager.Instance:IsServerConnected() then
		local task = rpcFunc()

		if task then
			task.Callback = function(err, ...)
				if err ~= LTConfig.MessageConfig.Ok then
					if onSuccess then
						onSuccess(...)
					end
				else
					print_error("BBQ RPC failed: ", rpcName, " err:", err)

					if onFail then
						onFail(err)
					end
				end
			end
		else
			print_error("BBQ RPC not sent (no task): ", rpcName)

			if onFail then
				onFail(-3)
			end
		end

		print_debug("BBQ: SendRpc direct - ", rpcName)

		return
	end

	print_debug("BBQ: SendRpc waiting network - ", rpcName)
	gCoroutineManager:StartCoroutine(function ()
		local waitTime = 0

		while not gLuaDataManager.isNetworkAvailable or not gCS.NetworkManager.Instance:IsServerConnected() do
			if gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene or not self.currentGame then
				print_debug("BBQ: SendRpc aborted - ", rpcName)

				if onFail then
					onFail(-1)
				end

				return
			end

			if BBQ_RPC_MAX_WAIT_TIME < waitTime then
				print_error("BBQ: SendRpc timeout - ", rpcName, " waited:", waitTime, "s")

				if onFail then
					onFail(-2)
				end

				return
			end

			coroutine.wait(BBQ_RPC_RETRY_INTERVAL)

			waitTime = waitTime + BBQ_RPC_RETRY_INTERVAL
		end

		if not self.currentGame then
			print_debug("BBQ: SendRpc aborted after reconnect - ", rpcName)

			if onFail then
				onFail(-1)
			end

			return
		end

		local task = rpcFunc()

		if task then
			task.Callback = function(err, ...)
				if err ~= LTConfig.MessageConfig.Ok then
					if onSuccess then
						onSuccess(...)
					end
				else
					print_error("BBQ RPC failed after reconnect: ", rpcName, " err:", err)

					if onFail then
						onFail(err)
					end
				end
			end
		else
			print_error("BBQ RPC not sent after reconnect (no task): ", rpcName)

			if onFail then
				onFail(-3)
			end
		end

		print_debug("BBQ: SendRpc after reconnect - ", rpcName)
	end)
end

gBBQGameManager = gBBQGameManager or C_BBQGameManager.new()
