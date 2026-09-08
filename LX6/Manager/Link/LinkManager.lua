-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager.lua
-- Decompiled from: 00700_LinkManager.lua_f099a51723fc.luajit

local MessageConfig = LTConfig.MessageConfig
local gameProfile = LX6.Engine.ProfileManager.gameProfile
local LinkConfig = LTConfig.LinkConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local LinkProgressConfig = LTConfig.LinkProgressConfig
local LinkMessageType = UX.Game.LinkMessageType
local loginMgr = LX6.Manager.LoginManager
local LinkMode = UX.Game.LinkMode
local StaticProps = {
	AGAIN_STATE = {
		["l\\x89\\x83\\x86\\x98"] = 1,
		[".m\\xa1\\xa2\\xa2x"] = 3,
		["TEo"] = 2,
		["T-s^"] = 0
	}
}
C_LinkManager = DefClass("C_LinkManager", C_LinkManager, nil, StaticProps)
local M = C_LinkManager

require("LX6/Manager/Link/LinkUIHelper")
require("LX6/Manager/Link/LinkPlayerHub")
require("LX6/Manager/Link/LinkGame")
dofile("LX6/Manager/Link/LinkManager_Extension")
dofile("LX6/Manager/Link/LinkManager_GameplayDuty")
dofile("LX6/Manager/Link/LinkManager_GameplayInGamePlayer")
dofile("LX6/Manager/Link/LinkManager_GameplayMatch")
dofile("LX6/Manager/Link/LinkManager_GameplayReady")
dofile("LX6/Manager/Link/LinkManager_GameplayRoom")
dofile("LX6/Manager/Link/LinkManager_GameProgress")
dofile("LX6/Manager/Link/LinkManager_LinkBase")
dofile("LX6/Manager/Link/LinkManager_LinkState")
dofile("LX6/Manager/Link/LinkManager_UI")
dofile("LX6/Manager/Link/LinkManager_WatchGame")
dofile("LX6/Manager/Link/LinkManager_GameplayVote")
dofile("LX6/Manager/Link/LinkManager_Stage")
dofile("LX6/Manager/Link/LinkManager_GameplaySettle")
dofile("LX6/Manager/Link/LinkManager_HudControls")
dofile("LX6/Manager/Link/LinkManager_LegacyStage")

M.ctor = function(self)
	self.useNewMainPanel = true
	self.LinkData = {}
	self.baseTime = 0
	self.LinkMember = {}
	self.LinkMemberState = {}
	self.LinkMemberPosInfo = {}
	self.LinkMemberVehicleInfo = {}
	self.LinkMemberInfo = {}
	self.LinkMemberUnitInfo = {}
	self.isPSNOnly = false
	self.LinkMemberIndex = {
		[UX.Game.LinkMode.None] = {},
		[UX.Game.LinkMode.Public] = {},
		[UX.Game.LinkMode.Private] = {},
		[UX.Game.LinkMode.Match] = {}
	}
	self.PLAYER_STATE = {
		["\\xef\\xfe<4=\\xd4"] = 2,
		["2g\\xa3\\xa3\\xa2m"] = 3,
		["\\xf6\\xfd217\n\\xd4"] = 0,
		["^\\"] = 1
	}
	self.IsUnlockedLink = false
	self.HavePrivateLink = false
	self.WaitCallbacks = {}
	self.WaitHandle = nil
	self.gameStartTime = 0
	self.currentMultiPlayerId = 0
	self.enablePreparePanelEditMode = false
	self.PHONE_TOPLEFT = {
		["N'|V"] = 1,
		["\\xa3iv"] = 0
	}
	self.phoneTopLeftSelectPref = self.PHONE_TOPLEFT.Map
	self.roomSetting = {
		["\\xa3#\\xe1\\xb3D\\xc9U,\\xcd\\xef'Eu\\xc47\\xb5\\xdf"] = true
	}
	self.matchInfo = {}
	self.currentGameCfg = {}

	self:OnMatchInit()

	self.cs = LX6.Manager.LinkManager.Instance
	self.acceptPopupUpMode = {}

	for i = 1, #LinkConfig.ShowPopupMode do
		self.acceptPopupUpMode[LinkConfig.ShowPopupMode[i]] = true
	end

	local preId = 0
	self.multi2Link = {}

	for i = 0, LinkConfig.count - 1 do
		local cfg = LinkConfig.LoadAt(i)
		preId = 0

		for j = 1, #cfg.ChildItems do
			local mulId = cfg.ChildItems[j]
			local ele = {
				["t'eO"] = 0,
				parent = cfg.Id
			}
			self.multi2Link[mulId] = ele

			if preId == 0 then
				self.multi2Link[preId].next = mulId
			end

			preId = mulId
		end
	end

	self.curMultiType = 0
	self.lastSyncMultiType = 0
	self.curShortChatWheels = nil
	self.pendingLinkModePopup = nil
	self.multiTypeToChatWheelDict = {}
	self.MAX_CHAT_ITEM_COUNT = 8
	self.banChatCircleOperation = false
	self.keepSceneHandleId = nil
end

M.Log = function(self, ...)
	if not loginMgr.printLog and not self.printLog then
		return
	end

	print_notice("[C_LinkManager]", ...)
end

M.Debug = function(self, ...)
	if not loginMgr.printLog and not self.printLog then
		return
	end

	print_debug("[C_LinkManager]", ...)
end

M.Error = function(self, ...)
	print_error("[C_LinkManager]", ...)
end

M.OnInit = function(self)
	self.printLog = false
	self.useNewStage = true
	self.replacePrepareRoom = true
	self.LinkMode = gameProfile.LinkMode
	self.progressMgr = gLinkProgressMgr

	gLinkPlayerHub:OnInit()
	self:RefreshInitData()
	self:InitLinkGame()
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self:CreateAction(self.OnLoadingFinish))
end

M.RefreshInitData = function(self)
	self.LINK_MODE_2_LINK_MODEX_CONFIG_ID = {}

	for i = 0, LTConfig.LinkModeConfig.count - 1 do
		local cfg = LTConfig.LinkModeConfig.LoadAt(i)
		self.LINK_MODE_2_LINK_MODEX_CONFIG_ID[cfg.LinkModeCode] = cfg.Id
	end
end

M.GmUseNewStageClient = function(self, useNewStage)
	self.useNewStage = useNewStage
end

M.GmEnablePreparePanelEditMode = function(self, enable)
	self.enablePreparePanelEditMode = enable
end

M.OnBeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	gNewGamePlayProgressMgr:BeforeSwitchScene(switchType)

	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self:Clear()
	self:EndOfSearching()
	gLinkProgressMgr:Clear()
end

M.IsDisableMemberInfo = function(self)
	return self.LinkMode ~= UX.Game.LinkMode.Match and self.currentGameCfg and self.currentGameCfg.ShowMemberInfo ~= false
end

M.OnLoadingFinish = function(self, eventId, panelId)
	if panelId == gPanelId.PVP_LOADING_PANEL then
		return
	end

	if not gPlayerManager.infoLogin.bindData.pid then
		return
	end

	gTeamManager:RefreshHudUIState()

	if self.LinkMode ~= UX.Game.LinkMode.Match and self.currentGameCfg and self.currentGameCfg.FailureDieCount and self.currentGameCfg.FailureDieCount <= 0 and self.LinkFailureCount == -1 then
		gPanelManager:CheckShow(gPanelId.ONLINE_INGAME_MISSION_PANEL)
	end

	if not self.currentLinkGame then
		gPanelManager:Close(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)
	end

	local voteProgressInfo = nil

	if self.currentVoteSessionId == ulong.zero then
		voteProgressInfo = self.progressMgr:GetCurrentProgress(LinkProgressConfig.InGameVote)
	end

	self:SetMatchRoom(self.matchRoom)
	gLinkProgressMgr:Clear()
	gNewGamePlayProgressMgr:AfterLoadingPanelClosed()
	self:UpdateOnlineControls()
	gPanelManager:Close(gPanelId.ONLINE_HALF_PROGRESS)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_READY_PANEL)

	if voteProgressInfo then
		self.progressMgr:AddProgress(LinkProgressConfig.InGameVote, voteProgressInfo.startTime, voteProgressInfo.totalLength, voteProgressInfo.data)
	end

	self:FlushPendingLinkModePopup()

	if self._afterLoadingPanel then
		local cb = self._afterLoadingPanel
		self._afterLoadingPanel = nil

		cb()
	end

	gMessageManager:SendMessage(gEventConstants.LINK_CIRCLE_STATE_CHANGE)
end

M.Clear = function(self)
	self:EndExitLoading()

	self.currentMultiPlayerId = 0
	self.LinkMemberPosInfo = {}
	self.LinkMemberInfo = {}
	self.LinkMemberVehicleInfo = {}
	self.pendingLinkModePopup = nil
	self._pendingFullConfirmRoom = nil

	table.clear(self.multiTypeToChatWheelDict)

	self.curMultiType = 0
	self.lastSyncMultiType = 0

	self:OnMatchInit()
end

M.OnChanegeMemberDetach = function(self, pid)
	if self.LinkMember[pid] then
		self.LinkMember[pid].OnlineState = UX.Game.PlayerState.Detached
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MEMBER_CHANGE, {
		pid = pid
	})
end

M.OnChangeMemberOnlineState = function(self, member, online, mode)
	local pid = member.Pid

	if self.LinkMember[pid] then
		self.LinkMember[pid].OnlineState = online and UX.Game.PlayerState.Online or UX.Game.PlayerState.Offline
	end

	self:AddLinkPlayerInfo(pid, member, mode)
	self:PushToPopup(pid, online and MessageConfig.LinkMemberOnline or MessageConfig.LinkMemberOffline, online and 1 or 0)
	gMessageManager:SendMessage(gEventConstants.LINK_MEMBER_CHANGE, {
		pid = pid
	})
end

M.GetMemberPosInfoByPid = function(self, pid)
	return self.LinkMemberPosInfo[pid]
end

M.GetCurrentMultiPlayerId = function(self)
	return tonumber(self.currentMultiPlayerId) or 0
end

M.OnMemberPosInfoChange = function(self, pid, agentId, name, pos, facing, raidId)
	self.LinkMemberPosInfo[pid] = {
		X = pos.X,
		Y = pos.Y,
		Z = pos.Z,
		F = facing,
		AgentId = agentId,
		RaidId = raidId
	}

	if gMapSubSystem_Player then
		gMapSubSystem_Player:FlushData("CoordChange")
	end
end

M.OnMemberVehicleInfoChange = function(self, pid, vehicleEntityId, vehicleTemplateId, seatIndex)
	local ret = {
		entityId = vehicleEntityId,
		templateId = vehicleTemplateId,
		seatIndex = seatIndex
	}
	local old = self.LinkMemberVehicleInfo[pid]
	self.LinkMemberVehicleInfo[pid] = ret

	if not old or old.entityId == vehicleEntityId then
		gMessageManager:SendMessage(gEventConstants.LINK_VEHICLE_CHANGE, pid)
	end
end

M.OnLinkMemberChange = function(self, mode, member, isAdd)
	local pid = member.Pid
	self.LinkMemberState[pid] = isAdd and mode or nil

	self:AddLinkPlayerInfo(pid, isAdd and member or nil, mode)
	self:PushToPopup(pid, isAdd and MessageConfig.LinkNewMemberEnter or MessageConfig.LinkMemberExist, isAdd and 1 or 0)
	gMessageManager:SendMessage(gEventConstants.LINK_MEMBER_CHANGE, {
		pid = pid,
		isAdd = isAdd
	})
end

M.InitLinkMember = function(self, member)
	local pidList = {}
	self.LinkMemberInfo = {}
	gLinkPlayerHub.colorDict = {}
	gLinkPlayerHub.indexDict = {}

	for i = 1, #member do
		table.insert(pidList, member[i].Pid)
		self:AddLinkPlayerInfo(member[i].Pid, member[i])
	end

	self:RequestMemberInfoByIdList(pidList, function (data)
		for i = 1, #data do
			self.LinkMemberState[data[i].Pid] = self.LinkMode
		end
	end)
end

M.ShowLinkMsg = function(self, pid, msgType)
	local realName = gFriendManager:GetPlayerRealName(pid)

	if msgType ~= LinkMessageType.MemberDetach then
		gDisplayMessageMgr:ShowMessage(MessageConfig.PlayerMatchDetachStart, nil, , realName)
	elseif msgType ~= LinkMessageType.MemberDetachToOnline then
		gDisplayMessageMgr:ShowMessage(MessageConfig.PlayerMatchDetachEnd, nil, , realName)
	end
end

M.OnGameCfgInit = function(self)
	local cfg = LinkMultiPlayerConfig.GetConfig(self.targetPlayId)

	if not cfg then
		print_error("#NoCreateIssue [LinkManager] 不存在的PlayId", self.targetPlayId)

		return false
	end

	if not self.currentGameCfg or self.currentGameCfg.Id == cfg.Id then
		self.currentGameCfg = cfg

		gMessageManager:SendMessage(gEventConstants.LINK_GAME_CFG_CHANGE)
	end

	return true
end

M.OnSyncLoadingState = function(self, pid, rate)
	self:Log("[OnSyncLoadingState]", pid, rate)

	self.lodingInfo[pid] = rate

	if rate ~= 1 then
		gMessageManager:SendMessage(gEventConstants.LINK_LOADING_FINISH, pid)
	end
end

gLinkManager = gLinkManager or C_LinkManager.new()
