-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MaJiangManager_Flow.lua
-- Decompiled from: 00346_MaJiangManager_Flow.lua_33d1332026a6.luajit

local M = C_MaJiangManager
local MahjongRoomType = UX.Game.MahjongRoomType
local MahjongRoomState = UX.Game.MahjongRoomState
local MessageConfig = LTConfig.MessageConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local AgentConfig = LTConfig.AgentConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
local MahjongPveMahjongNpcTalkConfig = LTConfig.MahjongPveMahjongNpcTalkConfig

M.Temp_StopGameInitCo = function(self)
	if self.gameInitCo then
		coroutine.stop(self.gameInitCo)

		self.gameInitCo = nil
	end
end

M.Temp_CanBeginMajiangGameAfterReceiveServerData = function(self)
	local game = self.game

	if game ~= nil or game.serverRoomInfo ~= nil or game.serverGameInfo ~= nil then
		return false
	end

	if gClientUtils.IsNil(self.machine) then
		return false
	end

	if game.machineInfo == nil then
		return false
	end

	return true
end

M.Temp_TryBeginMajiangGameAfterReceiveServerData = function(self)
	local game = self.game

	if game ~= nil then
		return false
	end

	if game == nil and game.machineInfo == nil then
		return true
	end

	if self.Temp_CanBeginMajiangGameAfterReceiveServerData(self) then
		self.Temp_StopGameInitCo(self)

		game = self.game

		L18.Mahjong.MahjongUtils.DisableCheckStippleAlpha(true)
		game.BeginMajiangGameAfterReceiveServerData(game)

		return true
	end

	if self.gameInitCo == nil then
		return false
	end

	self.gameInitCo = coroutine.start(function ()
		while not self:Temp_CanBeginMajiangGameAfterReceiveServerData() do
			coroutine.step()
		end

		self.gameInitCo = nil
		local game = self.game

		if game ~= nil then
			return
		end

		L18.Mahjong.MahjongUtils.DisableCheckStippleAlpha(true)
		game.BeginMajiangGameAfterReceiveServerData(game)
	end)

	return false
end

M.AskStartMahjongGame = function(self, roomType, npcList, seatIndex, addFavor, callback, gameplayType)
	npcList = npcList or {}
	seatIndex = seatIndex or -1
	addFavor = addFavor or false

	self:DestroyGame("New Game")

	local gameType = gameplayType ~= LTConfig.NpcCultivationGameplayTypeConfig.ReachMahjong and UX.Game.MahjongGameType.Reach or UX.Game.MahjongGameType.XLCH
	self.gameType = gameType

	self:CreateGame()

	local askingStartMahjongGame = true

	self:Temp_StopGameInitCo()

	self.gameInitCo = coroutine.start(function ()
		while askingStartMahjongGame or not self:Temp_CanBeginMajiangGameAfterReceiveServerData() do
			coroutine.step()
		end

		self.gameInitCo = nil
		local game = self.game

		if game ~= nil then
			return
		end

		L18.Mahjong.MahjongUtils.DisableCheckStippleAlpha(true)
		game:BeginMajiangGameAfterReceiveServerData()
	end)

	gClientToGameDelegate:AskStartMahjongGame(roomType, npcList, seatIndex, addFavor, gameType).Callback = function (err)
		askingStartMahjongGame = false

		if err == MessageConfig.Ok then
			print_error("[Majiang-Manager] StartMahjongGame err:", gCS.Error.GetNameById(err))
			self:Temp_StopGameInitCo()
		end

		if callback then
			callback(err)
		end
	end
end

M.OnEvent_BeginPortal = function(self)
	if self.linkState then
		self.linkState.seated = false
	end
end

M.OnEvent_BeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if not self.isInServerGame or switchType ~= gSwitchSceneType.Reconnect then
		return
	end

	if self.linkState then
		self.linkState.seated = false
	end

	self.DestroyGame(self, "BeforeSwitchScene")
end

M.OnEvent_AfterSwitchScene = function(self, _, switchSceneEventParam)
	local switchType = switchSceneEventParam.switchSceneType

	if gSwitchSceneType.Reconnect >= switchType then
		self.ignoreInServerGame = true

		self.MahjongShowMatchBtn(self, false)
	end

	if not self.isInServerGame then
		return
	end

	if switchType ~= gSwitchSceneType.Reconnect then
		self.OnSyncMjGameReconnect(self)
	else
		self.DestroyGame(self, "AfterSwitchScene")
	end
end

M.OnEvent_CommonGameplayOutwardSignal = function(self, data)
	self:GetGameNullableCall():OnEvent_CommonGameplayOutwardSignal(data)
end

M.OnSyncMjGameReconnect = function(self)
	if self.ignoreInServerGame then
		return
	end

	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(MessageConfig.MajiangReconnect, function ()
		gClientToGameDelegate:ReconnectGame()
	end, function ()
		slot0 = gLinkManager

		slot0:ClearLinkGame()

		slot0 = self

		slot0:DestroyGame("RequestLeaveCurrentRound_AskExitFailed")

		slot0 = gClientToGameDelegate

		slot0:Exit().Callback = function (err)
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end)
end

M.RequestLeaveCurrentRound = function(self)
	local isInServerGame = self.isInServerGame
	local roomType = self:GetGameOrEmpty().serverRoomInfo.RoomType
	slot3 = gClientToGameDelegate

	slot3:Exit().Callback = function (err)
		if not isInServerGame then
			self:SendSignalToGadget("MajiangFinishInGame")
			self:DestroyGame("RequestLeaveCurrentRound_NotInServerGame")

			return
		end

		self:SetInServerGame(false)
		self:SendSignalToGadget("MajiangFinishInGame")

		if roomType ~= MahjongRoomType.Friend then
			if err == MessageConfig.Ok then
				print_warn("[Majiang-Manager] Exit without SyncMjGameOver, err=", gCS.Error.GetNameById(err))
			end

			gLinkManager:ClearLinkGame()
			self:DestroyGame("RequestLeaveCurrentRound_Friend")
			self:LeaveCurrentWorldBattle()

			return
		end

		if err ~= MessageConfig.Ok then
			return
		end

		print_warn("[Majiang-Manager] Exit without SyncMjGameOver, err=", gCS.Error.GetNameById(err))
		self:DestroyGame("RequestLeaveCurrentRound_AskExitFailed")
	end
end

M.ShowLeaveCurrentRoundDialog = function(self)
	local game = self.GetGameOrEmpty(self)
	local msgID = nil

	if game.serverRoomInfo.State ~= MahjongRoomState.Idle then
		if game.serverRoomInfo.RoomType ~= MahjongRoomType.Friend then
			msgID = MessageConfig.MahjongLeaveRoom
		end
	else
		msgID = MessageConfig.MahjongLeave
	end

	if msgID then
		slot3 = gDisplayMessageMgr

		slot3:ShowMessage(msgID, function ()
			self:RequestLeaveCurrentRound()
		end, nil)
	else
		self.RequestLeaveCurrentRound(self)
	end
end

M.AskCreateFriendModeRoom = function(self, notifyToScenePlayers)
	if not gGameSwitch.EnableMahjong or not gGameSwitch.EnableMahjongFriend then
		gDisplayMessageMgr:ShowMessage(MessageConfig.GameSwitchFunctionDisabled)

		return
	end

	if notifyToScenePlayers ~= nil then
		notifyToScenePlayers = false
	end

	if self.isInServerGame then
		slot2 = gDisplayMessageMgr

		slot2:ShowMessage(MessageConfig.MahjongReconnect, function ()
			slot0 = gClientToGameDelegate

			slot0:BackToMahjong().Callback = function (errID)
				if errID <= 0 then
					print_error("[Majiang-Manager] BackToMahjong failed, error =", gCS.Error.GetNameById(errID))

					return
				end

				gClientUtils.CloseMainPhonePanel()
				self:GetGameNullableCall():RefreshMaJiangPanel()
			end

			return true
		end, nil)

		return
	end

	slot2 = gClientToAvatarDelegate

	slot2:AskCreateFriendModeRoom(notifyToScenePlayers).Callback = function (errorId, roomID)
		self:AskCreateFriendModeRoomCallback(errorId, roomID)
	end
end

M.AskCreateFriendModeRoomCallback = function(self, errorId, roomID)
	if errorId <= 0 then
		gDisplayMessageMgr:DisplayServerMessageId(errorId)

		return
	end

	local game = self.GetGame(self)

	if game ~= nil then
		return
	end

	game.serverRoomInfo.RoomType = MahjongRoomType.Friend

	gClientUtils.CloseMainPhonePanel()
	game.RefreshMaJiangPanel(game)
end

M.RequestExitFinishedMahjongGame = function(self)
	local isInServerGame = self.isInServerGame
	local game = self.game
	local isFriendRoom = game and game.serverRoomInfo.RoomType ~= MahjongRoomType.Friend
	local mySeatID = game and game.mySeatID
	local entityId = self.entityId

	gClientToGameDelegate:Exit().Callback = function (err)
		if err == MessageConfig.Ok and isInServerGame then
			print_warn("[Majiang-Manager] Exit local cleanup without server game, err=", gCS.Error.GetNameById(err))
		end

		gLinkManager:ClearLinkGame()

		if isFriendRoom then
			self:ReturnToTableAndDestroyGame(entityId, mySeatID)
		else
			self:DestroyGame("RequestExitFinishedMahjongGame")
		end
	end
end

M.AskStartPveGame = function(self, callback)
	self.AskStartMahjongGame(self, MahjongRoomType.Pve, {}, -1, false, callback)
end

M.Spoon_InviteMahjong_SetInviteTimelinePos = function(self, inviteTimelinePosList)
	if inviteTimelinePosList.ToTable then
		inviteTimelinePosList = inviteTimelinePosList.ToTable(inviteTimelinePosList) or inviteTimelinePosList
	end

	self.inviteTimelinePosList = inviteTimelinePosList
end

M.Spoon_InviteMahjong_AskInviteNpcRandom = function(self)
	self.AskStartMahjongGame(self, MahjongRoomType.Npc, {}, -1)
end

M.Spoon_InviteMahjong_AskInviteNpcRide = function(self)
	local npcId = gNpcFavorManager:GetInviteRideNpcCultivationId()

	if npcId ~= 0 then
		return
	end

	local mahjongNpcList = {}
	local npcCfg = NpcCultivationConfig.GetConfig(npcId)

	table.insert(mahjongNpcList, npcCfg.MahjongTalkid)
	self.AskStartMahjongGame(self, MahjongRoomType.Npc, mahjongNpcList, -1, true)
end

M.Spoon_StopMahjongMachine = function(self)
	self:ResetLinkState()
	self:GetGameNullableCall():Spoon_StopMahjongMachine()

	self.entityId = nil
end

M.Spoon_UseMahjongMachine = function(self, machine, instance)
	L18.Mahjong.MahjongMachine.CurrentMachine = machine
	self.machine = machine
	self.entityId = instance

	machine.PrepareWall(machine, 4, 108)
	self.Temp_TryBeginMajiangGameAfterReceiveServerData(self)
end

M.StartNextRound = function(self)
	local game = self.GetGameOrEmpty(self)

	if game.serverRoomInfo ~= nil then
		return
	end

	local roomType = game.serverRoomInfo.RoomType
	local npcList = {}

	if roomType ~= MahjongRoomType.Npc and not table.isNilOrEmpty(self.pveNpcList) then
		npcList = self.pveNpcList
	end

	local gameplayType = self.gameType ~= UX.Game.MahjongGameType.Reach and LTConfig.NpcCultivationGameplayTypeConfig.ReachMahjong or nil

	game:ResetForNextRound()

	self.game = nil

	self:AskStartMahjongGame(roomType, npcList, -1, nil, , gameplayType)
	gPanelManager:Close(gPanelId.S_MA_JIANG_NEW_FINAL)
	gPanelManager:Close(gPanelId.MAJIANG_RIMA_FINAL_PANEL)
end

M.SendSignalToGadget = function(self, msg)
	if L50.L50App.Scene ~= nil then
		return
	end

	local signal = {
		signalKey = msg,
		entityInstanceId = self.entityId
	}

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, signal)
end

M.GetAgentIdByNpcId = function(self, npcId)
	local maJiangCfg = MahjongPveMahjongNpcTalkConfig.GetConfig(npcId)

	if not maJiangCfg then
		return 0
	end

	return maJiangCfg.AgentId
end

M.CheckAgentIsSmallBody = function(self, pid)
	local agentCfg = AgentConfig.GetConfig(pid)

	if not agentCfg then
		return false
	end

	local modelCfg = GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)

	if not modelCfg then
		return false
	end

	return table.contains(gMaJiangConst.SmallBodyType, modelCfg.BodyType)
end

M.CreateNpcInMaJiang = function(self, agentId, transform, fashionList, unitLoadCompleteCallback)
	if gClientUtils.IsNil(self.machine) or gClientUtils.IsNil(transform) then
		return
	end

	self.npcPidList = self.npcPidList or {}
	self.pidToUnit = self.pidToUnit or {}
	local pos = transform.position
	local eulerAngles = transform.eulerAngles

	local loadCompleteCallback = function(unit)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, LTConfig.GameplaySignalInwardConfig.MahjongGameStart)

		if unitLoadCompleteCallback then
			unitLoadCompleteCallback(unit)
		end
	end

	local csUnit = gCS.LuaUtils.CreateClientAgentByCfg(agentId, pos, eulerAngles, loadCompleteCallback, fashionList)

	if not csUnit then
		print_error("[Majiang-Manager] CreateNpcInMaJiang Fail AgentConfig(" .. tostring(agentId) .. ")=", AgentConfig.GetConfig(agentId))
	else
		table.insert(self.npcPidList, csUnit.Pid)

		self.pidToUnit[csUnit.Pid] = csUnit
		csUnit.forbidAetherAI = true
	end

	return csUnit
end

M.StartDestroyNpcInMaJiang = function(self)
	if self.destroyNpcCo == nil or table.isNilOrEmpty(self.toDestroyPidQueue) then
		return
	end

	self.destroyNpcCo = coroutine.start(function ()
		coroutine.step()

		while self.toDestroyPidQueue == nil and #self.toDestroyPidQueue <= 0 do
			local pid = table.remove(self.toDestroyPidQueue, 1)
			local csUnit = pid and gCS.SceneDataMgr.GetUnit(pid)

			if csUnit then
				gCS.BaseUnitUtils.DestroyAgentUnit(csUnit, true, true, true)
			end

			if #self.toDestroyPidQueue <= 0 then
				coroutine.step()
			end
		end

		self.destroyNpcCo = nil
	end)
end

M.RemoveNpcInMaJiangInstant = function(self)
	if self.destroyNpcCo then
		coroutine.stop(self.destroyNpcCo)

		self.destroyNpcCo = nil
	end

	if not string.is_null_or_empty(LTConfig.MahjongConfig.LeaveTimelineName) then
		gTimelineManager:Timeline_Stop(LTConfig.MahjongConfig.LeaveTimelineName)
	end

	local pidList = self.npcPidList
	local toDestroyPidQueue = self.toDestroyPidQueue
	self.npcPidList = nil
	self.pidToUnit = nil
	self.toDestroyPidQueue = {}

	if pidList == nil then
		for i = 1, #pidList do
			local pid = pidList[i]

			if pid then
				local csUnit = gCS.SceneDataMgr.GetUnit(pid)

				if csUnit and csUnit.CanUseRes then
					gCS.BaseUnitUtils.DestroyAgentUnit(csUnit, true, true, true)
				end
			end
		end
	end

	if toDestroyPidQueue ~= nil then
		return
	end

	for i = 1, #toDestroyPidQueue do
		local pid = toDestroyPidQueue[i]

		if pid then
			local csUnit = gCS.SceneDataMgr.GetUnit(pid)

			if csUnit and csUnit.CanUseRes then
				gCS.BaseUnitUtils.DestroyAgentUnit(csUnit, true, true, true)
			end
		end
	end
end

M.RemoveNpcInMaJiang = function(self)
	if self.npcPidList ~= nil then
		return
	end

	if self.inviteTimelinePosList ~= nil or gClientUtils.IsNil(self.machine) then
		self.RemoveNpcInMaJiangInstant(self)

		return
	end

	self.PlayLeaveNpcTL(self, function ()
		local pidList = self.npcPidList

		if pidList ~= nil then
			return
		end

		self.npcPidList = nil
		self.pidToUnit = nil

		for i = 1, #pidList do
			local pid = pidList[i]

			if pid then
				local csUnit = gCS.SceneDataMgr.GetUnit(pid)

				if csUnit then
					gCS.BaseUnitUtils.SetUnitLogicalHidden(csUnit, true, LX6.Units.LogicalHiddenCause.GamePlay)
				end

				table.insert(self.toDestroyPidQueue, pid)
			end
		end

		self:StartDestroyNpcInMaJiang()
	end)
end

M.PlayLeaveNpcTL = function(self, callback)
	if string.is_null_or_empty(LTConfig.MahjongConfig.LeaveTimelineName) then
		if callback then
			callback()
		end

		return
	end

	local timelineData = gTimelineManager:Timeline_CreateTimelineData()
	local bindUnitInfos = {}
	local agentList = {}
	local srcModelList = {
		"v'{O",
		"M\\x9f\\x9a\\x86S",
		"_\\xa7\\xa5\\xa7\\xa2"
	}
	local smallAgent = 0

	for i = 1, #self.pveNpcList do
		local npcId = self.pveNpcList[i]
		local agentId = self.GetAgentIdByNpcId(self, npcId)

		if self.CheckAgentIsSmallBody(self, agentId) and i == 2 then
			smallAgent = i
		end

		agentList[i] = agentId
	end

	for i, pid in ipairs(self.npcPidList) do
		local csUnit = gCS.SceneDataMgr.GetUnit(pid)

		if csUnit and csUnit.CanUseRes then
			local bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, pid, srcModelList[i], nil)
			bindUnitInfos[i] = bindInfo
		end
	end

	if smallAgent <= 0 and smallAgent == 2 then
		bindUnitInfos[smallAgent] = bindUnitInfos[2]
		bindUnitInfos[2] = bindUnitInfos[smallAgent]
	end

	timelineData = LX6.TimelineScript.TimelineUtils.Runtime_SetDynamicModelNameAndPersonality(timelineData, agentList)
	timelineData.bindUnitInfos = bindUnitInfos
	timelineData.allmoveTfs = self.inviteTimelinePosList

	if callback then
		timelineData.onFinishCallback = function(t)
			callback()
		end
	end

	timelineData.onLoadFailedCallback = function(_)
		print_error("[Majiang-Manager] Leave Timeline_LoadAndPlay failed")

		if callback then
			callback()
		end
	end

	gTimelineManager:Timeline_LoadAndPlay(LTConfig.MahjongConfig.LeaveTimelineName, timelineData)
end

M.PlayInviteNpcTL = function(self, callback)
	local npcCultivationList = self.npcCultivationList

	if #npcCultivationList == 3 then
		print_error("[Majiang-Manager] PlayInviteNpcTL Fail, npcCultivationList=", npcCultivationList)

		return
	end

	self.GetNpcRandomWearFashions(self, npcCultivationList[1], function (fashionList1)
		slot1 = self

		slot1:GetNpcRandomWearFashions(npcCultivationList[2], function (fashionList2)
			slot1 = self

			slot1:GetNpcRandomWearFashions(npcCultivationList[3], function (fashionList3)
				self:PlayInviteNpcTLImpl(callback, {
					fashionList1,
					fashionList2,
					fashionList3
				})
			end)
		end)
	end)
end

M.GetNpcRandomWearFashions = function(self, npcCultivationId, callback)
	local cfg = LTConfig.NpcCultivationConfig.GetConfig(npcCultivationId)
	local spiritId = cfg.FightSpiritID
	slot5 = gClientToGameDelegate

	slot5:AskGetNpcRandomWearFashions(spiritId).Callback = function (err, list)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			callback({})

			return
		end

		callback(list)
	end
end

M.PlayInviteNpcTLImpl = function(self, callback, fashionListOfList)
	if gClientUtils.IsNil(self.machine) then
		print_error("[Majiang-Manager] 机关状态不对！self.machine=", self.machine, "可能是 Spoon_UseMahjongMachine 节点没有触发或者机关已经被销毁了")

		return
	end

	self:RemoveNpcInMaJiangInstant()

	local timelineData = gTimelineManager:Timeline_CreateTimelineData()
	local bindUnitInfos = {}
	local agentList = {}
	local srcModelList = {
		"v'{O",
		"M\\x9f\\x9a\\x86S",
		"_\\xa7\\xa5\\xa7\\xa2"
	}
	local smallAgent = 0

	for i = 1, #self.pveNpcList do
		local npcId = self.pveNpcList[i]
		local agentId = self.GetAgentIdByNpcId(self, npcId)

		if self.CheckAgentIsSmallBody(self, agentId) and i == 2 then
			smallAgent = i
		end

		agentList[i] = agentId
	end

	self.npcPidList = {}
	self.pidToUnit = {
		[gCS.MyPlayerManager.PlayerUnitId] = gCS.MyPlayerManager.PlayerUnit
	}

	for i, v in ipairs(agentList) do
		local csUnit = self:CreateNpcInMaJiang(v, self.inviteTimelinePosList and self.inviteTimelinePosList[1], fashionListOfList[i] or 0)

		if csUnit then
			local instanceId = csUnit.Pid
			local bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, instanceId, srcModelList[i], nil)
			bindUnitInfos[i] = bindInfo

			gCS.BaseUnitUtils.SetUnitLogicalHidden(csUnit, true, LX6.Units.LogicalHiddenCause.GamePlay)
		end
	end

	if smallAgent <= 0 and smallAgent == 2 then
		bindUnitInfos[smallAgent] = bindUnitInfos[2]
		bindUnitInfos[2] = bindUnitInfos[smallAgent]
	end

	timelineData = LX6.TimelineScript.TimelineUtils.Runtime_SetDynamicModelNameAndPersonality(timelineData, agentList)
	timelineData.bindUnitInfos = bindUnitInfos
	timelineData.allmoveTfs = self.inviteTimelinePosList

	if callback then
		timelineData.onFinishCallback = function(t)
			callback()
		end
	end

	timelineData.onPlayCallback = function(t)
		if gClientUtils.NotNil(self.machine) then
			self.machine.isInDesk = true

			self.machine:ClearMachine()
		end

		for _, v in ipairs(self.npcPidList) do
			local csUnit = gCS.SceneDataMgr.GetUnit(v)

			if csUnit and csUnit.CanUseRes then
				gCS.BaseUnitUtils.SetUnitLogicalHidden(csUnit, false, LX6.Units.LogicalHiddenCause.GamePlay)
			end
		end

		gPanelManager:CheckShow(gPanelId.S_EMPTY_FULL_SCREEN_PANEL)
	end

	timelineData.onLoadFailedCallback = function(_)
		print_error("[Majiang-Manager] Timeline_LoadAndPlay failed")
	end

	gTimelineManager:Timeline_LoadAndPlay(LTConfig.MahjongConfig.InviteTimelineName, timelineData)
end

M.AskInviteNpcFromChat = function(self, npcList, gameplayType)
	if npcList ~= nil or #npcList == 3 then
		print_error("[Majiang-Manager] AskInviteNpcFromChat bad npcList=", npcList)

		return
	end

	self.RemoveNpcInMaJiangInstant(self)

	local mahjongNpcList = {}

	for i = 1, #npcList do
		local npc = npcList[i]

		if npc == nil then
			local npcCfg = NpcCultivationConfig.GetConfig(npc)

			if npcCfg == nil then
				table.insert(mahjongNpcList, npcCfg.MahjongTalkid)
			else
				print_error("[Majiang-Manager] NpcCultivationConfig to MajiangTalkConfig failed, npcId =", npc, "@wangpeizhi@corp.netease.com")
			end
		end
	end

	self.npcCultivationList = npcList
	self.pveNpcList = mahjongNpcList

	self.PlayInviteNpcTL(self, function ()
		self:AskStartMahjongGame(UX.Game.MahjongRoomType.Npc, self.pveNpcList, -1, nil, , gameplayType)
	end)
end
