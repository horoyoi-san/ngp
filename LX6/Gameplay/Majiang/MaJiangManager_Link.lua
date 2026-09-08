-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MaJiangManager_Link.lua
-- Decompiled from: 00347_MaJiangManager_Link.lua_07b88f40ba03.luajit

local M = C_MaJiangManager
local LinkDutyConfig = LTConfig.LinkDutyConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local GameplaySignalInwardConfig = LTConfig.GameplaySignalInwardConfig
local MessageConfig = LTConfig.MessageConfig

M.InitLinkState = function(self)
	self.linkState = {
		["\\xc9\\xde*\\xf6"] = false,
		["~7iB"] = 0,
		["DFhnK\n$<"] = 0,
		["M\\x90\\x9a\\x86E"] = false,
		["&\\xe6=6ڝ\\xa4\\xe0\\x9b\\x9eĕ\\x86\\xfb\\xa2\\x85\\xc1\\x92.\\x82\\x88=\\x8f\\xdb=\\xe9"] = false
	}
end

M.ResetLinkState = function(self)
	self.InitLinkState(self)
end

M.GetMahjongWorldBattleRoomInfo = function(self)
	return self.linkState and self.linkState.worldBattleRoomInfo or nil
end

M.GetSeatDirByDuty = function(self, duty)
	if LinkDutyConfig.East12119103 < duty and duty < LinkDutyConfig.North12119103 then
		return duty - LinkDutyConfig.East12119103 + 1
	else
		return -1
	end
end

M.OnSyncMahjongReadyStart = function(self, gadgetUid, duty)
	local dir = self.GetSeatDirByDuty(self, duty)

	if dir < 0 then
		print_error("[Majiang-Manager] OnSyncMahjongReadyStart invalid duty", gadgetUid, duty)
		self.ResetLinkState(self)

		return
	end

	gPanelManager:CheckShow(gPanelId.S_EMPTY_FULL_SCREEN_PANEL)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_READY_PANEL)

	local state = self.linkState

	if state.seated and state.gadgetUid ~= gadgetUid and state.duty ~= duty then
		state.pending = false
		state.takeSeatByButtonInteraction = false

		self.RequestMahjongPlayerReady(self, gadgetUid)

		return
	end

	state.gadgetUid = gadgetUid
	state.duty = duty
	state.pending = true
	state.takeSeatByButtonInteraction = false
	slot5 = L50.L50App.Scene.SpoonGadgetManager

	slot5:RegisterWaitLoad({
		gadgetUid
	}, function (_)
		gMessageManager:SendMessage(gEventConstants.MAJIANG_REQUEST_TAKE_SEAT, {
			gadgetInstanceId = gadgetUid,
			dir = dir
		})
	end)
end

M.OnSyncMahjongTimeOut = function(self, gadgetUId)
	gPanelManager:Close(gPanelId.S_EMPTY_FULL_SCREEN_PANEL)
	self:LeaveCurrentWorldBattle(gadgetUId)
end

M.IsSignalToMe = function(self, gadgetUid, duty)
	local state = self.linkState

	return state == nil and state.gadgetUid ~= gadgetUid and state.duty ~= duty
end

M.OnEvent_LogicAgentManaged = function(self, _, agentId, pid)
	if not ulong.equals(pid, gPlayerManager.infoLogin.bindData.pid) then
		return
	end

	local unit = gCS.SceneDataMgr.GetUnit(agentId)

	if not gCS.LuaUtils.IsBaseUnitValid(unit) then
		return
	end

	if unit.ClientData.SpawnType == UX.Game.AgentSpawnType.Mahjong then
		return
	end

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, GameplaySignalInwardConfig.MahjongGameStart, 1)
end

M.SendMahjongReadySignal = function(self, ready)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit ~= nil then
		print_error("[Majiang-Manager] SendMahjongReadySignal trueunit is nil")

		return
	end

	if ready then
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, GameplaySignalInwardConfig.MahjongReadyStart)
	else
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, GameplaySignalInwardConfig.MahjongReadyEnd)
	end
end

M.OnSyncMahjongWorldBattleRoomInfo = function(self, info)
	if self.linkState ~= nil then
		self.InitLinkState(self)
	end

	self.linkState.worldBattleRoomInfo = info

	gMessageManager:SendMessage(gEventConstants.MAJIANG_WORLD_BATTLE_ROOM_INFO, info)
end

M.ClearMahjongWorldBattleRoomInfo = function(self)
	if self.linkState then
		self.linkState.worldBattleRoomInfo = nil
	end

	gMessageManager:SendMessage(gEventConstants.MAJIANG_WORLD_BATTLE_ROOM_INFO, nil)
end

M.RequestMahjongPlayerReady = function(self, gadgetUid)
	slot2 = gClientToGameSceneDelegate

	slot2:MahjongPlayerReady(gadgetUid).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.Spoon_MahjongTakeSeat = function(self, gadgetUid, duty)
	self.linkState.gadgetUid = gadgetUid
	self.linkState.duty = duty
	local dir = self.GetSeatDirByDuty(self, duty)

	if dir < 0 then
		print_error("[Majiang-Manager] Spoon_MahjongTakeSeat invalid duty", gadgetUid, duty)
		self.ResetLinkState(self)

		return
	end

	slot4 = gClientToGameDelegate

	slot4:SyncWorldBattlePlayers(gadgetUid, LinkMultiPlayerConfig.NormalMahjong, true, 0, duty).Callback = function (err)
		if err ~= MessageConfig.MJ_DutyAlreadyTaken then
			return
		end

		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self.linkState.takeSeatByButtonInteraction = true

		gMessageManager:SendMessage(gEventConstants.MAJIANG_REQUEST_TAKE_SEAT, {
			gadgetInstanceId = gadgetUid,
			dir = dir
		})
	end
end

M.Spoon_NotifyMahjongTakeSeatFinished = function(self, gadgetUid, duty, machine)
	if not self.IsSignalToMe(self, gadgetUid, duty) then
		return
	end

	self.linkState.seated = true
	local state = self.linkState
	local takeSeatByButtonInteraction = state.takeSeatByButtonInteraction
	local dir = self.GetSeatDirByDuty(self, duty)

	if self.linkState ~= nil or self.linkState.gadgetUid == gadgetUid then
		self.ResetLinkState(self)

		self.linkState.gadgetUid = gadgetUid
	end

	self.Spoon_UseMahjongMachine(self, machine, gadgetUid)

	if takeSeatByButtonInteraction then
		gPanelManager:CheckShow(gPanelId.ONLINE_TABLE_PANEL, {
			gadgetInstanceId = gadgetUid,
			seat = dir,
			duty = duty,
			multiPlayerId = LinkMultiPlayerConfig.NormalMahjong
		})

		state.takeSeatByButtonInteraction = false
	else
		self.SendMahjongReadySignal(self, true)
		self.RequestMahjongPlayerReady(self, gadgetUid)
	end
end

M.CommonInteractLeaveSeat = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if not unit then
		return
	end

	unit.State.KeyDownDirection = unit.PlayerObj.right
	gCS.TransitionMgr.setChairUp = false
	LX6.GUI.GuiMgr.Instance.isOnJoystickMove = true

	if self.t_commonInteractLeaveSeatTimer then
		self.t_commonInteractLeaveSeatTimer:Stop()
	end

	self.t_commonInteractLeaveSeatTimer = FrameTimer.New(function ()
		LX6.GUI.GuiMgr.Instance.isOnJoystickMove = false
		self.t_commonInteractLeaveSeatTimer = nil
	end, 1)

	self.t_commonInteractLeaveSeatTimer:Start()
end

M.ReturnToTableAndDestroyGame = function(self, entityId, mySeatID)
	if entityId ~= nil or entityId ~= 0 or mySeatID ~= nil or mySeatID >= 0 then
		return
	end

	local seatDir = mySeatID + 1
	local duty = LinkDutyConfig.East12119103 + mySeatID
	local timer = nil

	local DestroyGame = function()
		if timer then
			self:DestroyGame("RequestExitFinishedMahjongGame")
			timer:Stop()

			timer = nil
		end
	end

	slot7 = Timer.New(DestroyGame, 10)
	timer = slot7:Start()
	slot7 = gPanelManager

	slot7:CheckShow(gPanelId.ONLINE_TABLE_PANEL, {
		gadgetInstanceId = entityId,
		seat = seatDir,
		duty = duty,
		multiPlayerId = LinkMultiPlayerConfig.NormalMahjong,
		onShowCallback = DestroyGame
	})

	slot7 = gClientToGameDelegate

	slot7:SyncWorldBattlePlayers(entityId, LinkMultiPlayerConfig.NormalMahjong, true, 0, duty).Callback = function (err)
		gDisplayMessageMgr:DisplayServerMessageId(err)
	end
end

M.Spoon_MahjongShowMatchBtn = function(self, isShow)
	self.MahjongShowMatchBtn(self, isShow)
end

M.MahjongShowMatchBtn = function(self, isShow)
	self.showMatchBtn = isShow

	gStoreManager:InvokeStoreMethod("CoreHudSystemControlStore", "RefreshMajiangMatchBtnState")
end

M.OnEvent_MemberRejectConfirm = function(self)
	local targetPlayId = gLinkManager.targetPlayId

	if targetPlayId == LTConfig.LinkMultiPlayerConfig.NormalMahjong and targetPlayId == LTConfig.LinkMultiPlayerConfig.RankMahjong then
		return
	end

	local state = self.linkState

	if not state or state.gadgetUid ~= 0 then
		return
	end

	local dir = self.GetSeatDirByDuty(self, state.duty)

	if dir < 0 then
		return
	end

	gPanelManager:CheckShow(gPanelId.ONLINE_TABLE_PANEL, {
		gadgetInstanceId = state.gadgetUid,
		seat = dir,
		duty = state.duty,
		multiPlayerId = targetPlayId
	})
end

M.LeaveCurrentWorldBattle = function(self, gadgetInstanceId, duty, callback)
	local gid = gadgetInstanceId or self.linkState and self.linkState.gadgetUid or 0
	local d = duty or self.linkState and self.linkState.duty or 0

	if gid ~= 0 then
		if callback then
			callback(MessageConfig.Ok)
		end

		return
	end

	self:SendMahjongReadySignal(false)

	slot6 = gClientToGameDelegate

	slot6:SyncWorldBattlePlayers(gid, LinkMultiPlayerConfig.NormalMahjong, false, 0, d).Callback = function (err)
		self:CommonInteractLeaveSeat()
		gPanelManager:Close(gPanelId.ONLINE_TABLE_PANEL)

		if err ~= MessageConfig.Ok then
			self:ClearMahjongWorldBattleRoomInfo()
			self:ResetLinkState()
		end

		if callback then
			callback(err)
		end
	end
end

M.OnGameReward = function(self, msg)
	self.pendingGameRewards = self.pendingGameRewards or {}

	table.insert(self.pendingGameRewards, msg)
	self:TryFlushGameRewards()
end

M.GetPendingGameRewards = function(self)
	return self.pendingGameRewards
end

M.TryFlushGameRewards = function(self)
	local store = gStoreManager:GetStoreGroup("OnlineTablePanelStore")

	if store and store.STATE_OnShowOnce then
		store.FlushGameRewards(store)
	end
end
