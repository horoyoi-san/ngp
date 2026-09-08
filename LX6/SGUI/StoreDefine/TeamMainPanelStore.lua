-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TeamMainPanelStore.lua
-- Decompiled from: 01402_TeamMainPanelStore.lua_8379ad40ae1f.luajit

local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local GameConfig = LTConfig.GameConfig
local channel = UX.Game.MessageChannel.Team
local DriveManager = gCS.DriveManager
local CCVoiceManager = LX6.Audio.CCMini.CCVoiceManager.Instance
local ProfileManager = LX6.Engine.ProfileManager
local gameProfile = ProfileManager.gameProfile
C_TeamMainPanelStore = DefClass("C_TeamMainPanelStore", C_TeamMainPanelStore, C_StoreGroup)
GroupName2Class.TeamMainPanelStore = C_TeamMainPanelStore
local M = C_TeamMainPanelStore

M.DefineAllVariables = function(self)
	self.ActionType = {
		["\\a\\xa5cO\\xba\\xdeBk~{^"] = 3,
		["qV\\xc1\\xbe\\x8f>\\xb7\r\\xca\\xed"] = 5,
		["\\xbe$03a\\xb1D\\xd83\\xaf\\xab"] = 4,
		["\\xf2\\xd211\\xe5"] = 2,
		["D\\x94\\x93\\xbaВ\\xc94\\xaa4;\\xbd5"] = 6,
		["\\x9a\\xa4\\xbf^;\\xff>"] = 1,
		["_s\\xbedC\\xbc\\xf3KCtxC"] = 0
	}
	self.ActionName = {
		[self.ActionType.PersonalInfo] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamPersonalInfo).Text,
		[self.ActionType.QuitTeam] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.QuitTeam).Text,
		[self.ActionType.KickOut] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.KickOutTeam).Text,
		[self.ActionType.SwitchLeader] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamSwitchLeader).Text,
		[self.ActionType.ApplyLeader] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamApplyLeader).Text,
		[self.ActionType.BlockVoice] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamBlockVoice).Text,
		[self.ActionType.CancelBlockVoice] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamCancelBlockVoice).Text
	}
	self.ActionListType = {
		["1\\xebP;<\\xdf\\xb5D\\x8d_\\xa3\\xa2"] = 2,
		["\\x88\\xbd\n\\xb8o\\xf2?"] = 0,
		["Ԓ\\xfb=\\xf2\\xe5\\x86\\xc1\\x8b3<"] = 1
	}
	self.settingVoicePage = LTConfig.SoundConfig.VoiceSetPanel
	self.PlayerState = {
		["\\xaf8!&q\\x93F\\xfe6\\xa7\\xbc"] = 7,
		["fQmj[<"] = 6,
		["\\xf5\\xd4*\\xf6"] = 4,
		["\\xef\t\\xf2̉\\xe4\\x8e%,"] = 8,
		["\\x98\\xa4\\xbdc(\\xff?"] = 5,
		["2G\\x83\\x83\\x82M"] = 3,
		["\\xfd\\xc9*\\xf6"] = 2,
		["\\xf6\\xdd*\\xf4"] = 0,
		["^'|_"] = 1
	}
	self.VehicleType = {
		["~Uڲ\\x96\\xa1\\xc5\\xed"] = 3,
		["\\x8a\\xb8\\xbbf?\\xf06"] = 0,
		["\\xadit"] = 2,
		["X-|O"] = 1,
		["pRndO="] = 4
	}
	self.TEAM_STATE = {
		["\\xf0\\xf5+:?\t\\xd4"] = 2,
		["\\x84\\x841\\x94M\\xd3"] = 1,
		["T\rS~"] = 0
	}
	self.CONTROL = {
		["NH~"] = 1,
		["k\\x8f\\x8e\\x9c\\x93"] = 0
	}
	self.memberSurvivalData = {}
	self.refreshDataCountDown = 0.5
	self.refreshDataTimer = nil
	self.linkMgr = gLinkManager
	self.teamMgr = gTeamManager
	self.playerList = {}
	self.playerListStore = {}
	self.ActionList = {}
	self.myPid = gPlayerManager.infoLogin.bindData.pid
	self.UPDATE_INTERVAL = 1
	self.updateTime = 0
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TEAM_REFRESH_DATA] = self.CreateAction(self, "OnTeamRefreshData"),
		[gEventConstants.TEAM_LEAVE] = self.CreateAction(self, "OnTeamLeave"),
		[gEventConstants.TEAM_REFRESH_VOICE_TYPE] = self.CreateAction(self, "OnRefreshVoiceType"),
		[gEventConstants.MICROPHONE_MODE_CHANGED] = self.CreateAction(self, "OnRefreshVoiceType"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide"),
		[gEventConstants.LINK_VEHICLE_CHANGE] = self.CreateAction(self, "OnVehicleChange"),
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "OnLinkModeChange"),
		[gEventConstants.TEAM_MEMBER_SURVIVAL_CHANGED] = self.CreateAction(self, "OnMemberSurvivalChanged"),
		[gEventConstants.TEAM_MEMBER_RESCUE_PROGRESS] = self.CreateAction(self, "OnMemberRescueProgress"),
		[gEventConstants.LINK_MEMBER_CHANGE] = self.CreateAction(self, "OnLinkMemberChange"),
		[gEventConstants.LINK_LOADING_FINISH] = self.CreateAction(self, "OnLinkMemberChange"),
		[gEventConstants.LINK_SETTLE_DATA_CHANGED] = self.CreateAction(self, "OnSettleDataChanged"),
		[gEventConstants.PLAYER_HP_CHANGE] = self.CreateAction(self, "OnUnitHpChange"),
		[gEventConstants.SYSTEM_CONTROLS_TR_RECOMMEND_CHANGE] = self.CreateAction(self, "OnHudTopRightRecommendChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnPlayerListRenderItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnPlayerListSimpleClick")
	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetPlayerListTIndex")
	self.bindData.actionList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderActionItem")
	self.bindData.voiceList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderVoiceItem")
	self.bindData.onInviteBtn = self.CreateAction(self, "OnCreateTeamBtnClick")
	self.bindData.onQuickCreateBtn = self.CreateAction(self, "OnCreateTeamBtnClick")
	self.bindData.quitBtn.luaClick = self.CreateAction(self, "OnQuitTeamBtnClick")
	self.bindData.quitMatchBtn.luaClick = self.CreateAction(self, "OnQuitTeamSurrender")
	self.bindData.closeActionBtn.luaClick = self.CreateAction(self, "OnCloseActionBtnClick")
	self.bindData.onVoiceBtn = self.CreateAction(self, "OnVoiceBtnClick")
	self.bindData.voiceBtn.luaClick = self.CreateAction(self, "OnVoiceBtnClick")
	self.bindData.onTeamBtn = self.CreateAction(self, "OnTeamBtnClick")
	self.bindData.microphoneBtn.luaPress = self.CreateAction(self, "OnMicrophoneBtnDown")
	self.bindData.microphoneBtn.luaRelease = self.CreateAction(self, "OnMicrophoneBtnUp")
	self.bindData.microphoneBtnIn.luaPress = self.CreateAction(self, "OnMicrophoneBtnDown")
	self.bindData.microphoneBtnIn.luaRelease = self.CreateAction(self, "OnMicrophoneBtnUp")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.closeTooltipBtn.luaClick = self.CreateAction(self, "OnCloseTooltipBtnClick")
		self.bindData.teamDetailBtnPad.luaClick = self.CreateAction(self, "OnTeamDetailBtnClick")
		self.bindData.voiceCloseBtnPad.luaClick = self.CreateAction(self, "CloseAll")
		self.bindData.actionCloseBtnPad.luaClick = self.CreateAction(self, "CloseAll")
	end
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnDestroy = function(self)
	gCS.GuiUtils.SetPanelHideCursor(self.m_Id, true)

	self.msgEvents = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self)
	self:RefreshDataAll()

	self.bindData.voiceSettingType = gTeamManager.curVoiceType

	gCS.GuiUtils.SetPanelHideCursor(self.m_Id, true)

	self.bindData.hideThis = gClientUtils.CheckMainPhoneIsShowing() and self.CONTROL.TRUE or self.CONTROL.FALSE
	self.bindData.locationCtrl = gHudRecommendMgr:GetHudTopRightRecommend() and 1 or 0
end

M.OnClose = function(self)
	table.clear(self.playerListStore)

	if self.refreshDataTimer then
		self.refreshDataTimer:Stop()

		self.refreshDataTimer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		SGUI.UNavigationMgr.Inst:UnRegisterArea(self.bindData.soloArea)
		SGUI.UNavigationMgr.Inst:UnRegisterArea(self.bindData.outgameArea)
		SGUI.UNavigationMgr.Inst:UnRegisterArea(self.bindData.ingameArea)
		self:CloseAll()
		self:OnCloseTooltipBtnClick()
	end
end

M.OnUpdate = function(self)
	self.updateTime = self.updateTime - Time.deltaTime

	if self.updateTime >= 0 then
		self.ResetUpdateTime(self)
		self.PerformUpdate(self, true, true)
	end
end

M.ResetUpdateTime = function(self)
	self.updateTime = self.UPDATE_INTERVAL
end

M.PerformUpdate = function(self, updateVoice, updateState)
	if not updateVoice and not updateState then
		return
	end

	for pid, store in pairs(self.playerListStore) do
		if updateVoice then
			self.OnPlayerListRenderVoiceState(self, store, pid)
		end

		if updateState then
			self.OnPlayerListRenderPlayerState(self, store, pid)
		end
	end
end

M.InitTeamState = function(self)
	local isInGame = gLinkManager.LinkMode ~= UX.Game.LinkMode.Match
	local isInTeam = gTeamManager:IsInTeam()

	if not isInTeam then
		self.bindData.teamState = self.TEAM_STATE.NONE
	elseif isInGame then
		self.bindData.teamState = self.TEAM_STATE.IN_GAME
	else
		self.bindData.teamState = self.TEAM_STATE.OUT_GAME
	end
end

M.InitPlayerList = function(self)
	local inMatch = gLinkManager.LinkMode ~= UX.Game.LinkMode.Match
	local isInTeam = gTeamManager:IsInTeam()

	if not inMatch and not isInTeam then
		self.bindData.list:SetSimpleList(0)

		return
	end

	if inMatch and self.linkMgr.currentGameCfg and self.linkMgr.currentGameCfg.MultiType then
		local multiTypeCfg = LTConfig.LinkMultiTypeConfig.GetConfig(self.linkMgr.currentGameCfg.MultiType)

		if not multiTypeCfg.ShowTeamPanel then
			self.bindData.list:SetSimpleList(0)

			return
		end
	end

	table.clear(self.playerList)
	table.clear(self.playerListStore)
	gTeamManager:GetOrderMembers(self.playerList)

	self.allSameDuty = self:IsAllSameDuty()

	self.bindData.list:SetSimpleList(#self.playerList)

	if #self.playerList <= 0 then
		self.bindData.list:SetItemSelected(0, true)
	end
end

M.IsAllSameDuty = function(self)
	if not self.linkMgr:CheckHasDuty() then
		return false
	end

	if #self.playerList >= 2 then
		return false
	end

	local firstDuty = self.linkMgr:GetDutyByPid(self.playerList[1])

	if not firstDuty or firstDuty ~= 0 then
		return false
	end

	for i = 2, #self.playerList do
		if self.linkMgr:GetDutyByPid(self.playerList[i]) == firstDuty then
			return false
		end
	end

	return true
end

M.RefreshDataAll = function(self)
	self.InitTeamState(self)
	self.InitPlayerList(self)
	self.ResetUpdateTime(self)
end

M.OnPhoneAppShow = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.bindData.hideThis = self.CONTROL.TRUE
end

M.OnPhoneAppHide = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.bindData.hideThis = self.CONTROL.FALSE
end

M.OnRefreshVoiceType = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.bindData.voiceSettingType = gTeamManager.curVoiceType
end

M.OnHudTopRightRecommendChange = function(self, _, isShow)
	if not self.STATE_OnShowOnce then
		return
	end

	self.bindData.locationCtrl = isShow and 1 or 0
end

M.OnLinkModeChange = function(self)
	table.clear(self.memberSurvivalData)

	if not self.STATE_OnShowOnce then
		return
	end

	self.RefreshDataAll(self)
end

M.OnTeamRefreshData = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	if self.refreshDataTimer then
		self.refreshDataTimer:Stop()

		self.refreshDataTimer = nil
	end

	self.refreshDataTimer = Timer.New(function ()
		self:RefreshDataAll()

		self.refreshDataTimer = nil
	end, self.refreshDataCountDown):Start()

	self:ResetUpdateTime()
end

M.OnTeamLeave = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.CloseAll(self)
end

M.OnVehicleChange = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.PerformUpdate(self, false, true)
end

M.OnLinkMemberChange = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.RefreshDataAll(self)
end

M.OnSettleDataChanged = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.PerformUpdate(self, false, true)
end

M.OnMemberSurvivalChanged = function(self, eventId, playerPid, isFalling, isBeingRescued)
	if isFalling then
		if not self.memberSurvivalData[playerPid] then
			self.memberSurvivalData[playerPid] = {}
		end

		local data = self.memberSurvivalData[playerPid]
		data.isFalling = true
		data.isBeingRescued = isBeingRescued
		data.rescueHealth = data.rescueHealth or 0
		data.rescueValue = data.rescueValue or 0
	else
		self.memberSurvivalData[playerPid] = nil
	end

	if not self.STATE_OnShowOnce then
		return
	end

	self.PerformUpdate(self, false, true)
end

M.OnMemberRescueProgress = function(self, eventId, playerPid, rescueHealth, rescueValue)
	local data = self.memberSurvivalData[playerPid]

	if data then
		data.rescueHealth = rescueHealth
		data.rescueValue = rescueValue
	end

	if not self.STATE_OnShowOnce then
		return
	end

	self.PerformUpdate(self, false, true)
end

M.OnUnitHpChange = function(self, _, pid)
	local unitInfo = gDataSetManager:GetUnitData(pid)

	if not self.STATE_OnShowOnce then
		return
	end

	if not unitInfo then
		return
	end

	local playerPid = unitInfo.ownerId

	if not playerPid or ulong.equals(playerPid, 0) then
		return
	end

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.Match then
		local store = self.playerListStore[playerPid]

		if store then
			self.OnPlayerListRenderHp(self, store, playerPid)
		end
	end
end

M.OnGetPlayerListTIndex = function(self)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.Match then
		return 1
	else
		return 0
	end
end

M.OnPlayerListSimpleClick = function(self, btn, index)
	local pid = self.playerList[index + 1]
	local memberInfo = self.linkMgr.LinkMember[pid]

	if not memberInfo then
		return
	end

	self.bindData.showTooltipCtrl = 1

	if self.SubGroup.SocialPalyerTooltipStore then
		self.SubGroup.SocialPalyerTooltipStore:SetData(pid)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.tooltipArea
	end
end

M.OnPlayerListRenderItem = function(self, btn, index)
	local pid = self.playerList[index + 1]
	local memberInfo = self.linkMgr.LinkMember[pid]

	if not memberInfo then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	self.playerListStore[pid] = store

	self:OnPlayerListRenderCommon(store, pid)
	self:OnPlayerListRenderPlayerState(store, pid)
	self:OnPlayerListRenderVoiceState(store, pid)

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.Match then
		self.OnPlayerListRenderInGame(self, store, pid)
		self.OnPlayerListRenderHp(self, store, pid)
	else
		self.OnPlayerListRenderOutGame(self, store, pid)
	end
end

M.OnPlayerListRenderCommon = function(self, store, pid)
	if store.userInfo then
		store.userInfo.pid = pid
	end

	store.color = self.linkMgr:GetColorStr(pid)
end

M.OnPlayerListRenderInGame = function(self, store, pid)
	local dutyInfo = self.linkMgr:GetDutyInfoByPid(pid)
	local showDuty = dutyInfo == nil and not self.allSameDuty
	store.hasDuty = showDuty and self.CONTROL.TRUE or self.CONTROL.FALSE
	store.dutyIcon = dutyInfo and dutyInfo.icon or 0
end

M.OnPlayerListRenderOutGame = function(self, store, pid)
	store.isSelf = pid ~= self.myPid and 1 or 0
	store.isLeader = pid ~= gTeamManager.leaderPid and 1 or 0
end

M.OnPlayerListRenderPlayerState = function(self, store, pid)
	local memberInfo = self.linkMgr.LinkMember[pid]

	if not memberInfo then
		return
	end

	local state = self.GetMemberLogicState(self, memberInfo)
	store.playerState = state

	if state ~= self.PlayerState.Driving then
		local vehicleInfo = self.linkMgr:GetVehicleInfo(pid)
		local vehicleCs = DriveManager:GetBaseVehicle(vehicleInfo.entityId)

		if vehicleCs then
			if vehicleCs.IsHelicopter then
				if vehicleCs.cfgId ~= 81006021 then
					store.vehicleType = self.VehicleType.Submarine
				else
					store.vehicleType = self.VehicleType.Airplane
				end
			elseif vehicleCs.IsBoat then
				store.vehicleType = self.VehicleType.Boat
			elseif vehicleCs.IsAutomobile then
				store.vehicleType = self.VehicleType.Car
			elseif vehicleCs.IsMotorcycle then
				store.vehicleType = self.VehicleType.Motorcycle
			else
				store.vehicleType = self.VehicleType.Car
			end
		elseif vehicleInfo.templateId and vehicleInfo.templateId == 0 then
			local cfg = LTConfig.VehicleConfig.GetConfig(vehicleInfo.templateId)

			if cfg then
				local vtype = cfg.VehicleType
				local T = LTConfig.VehicleConfig.VehicleTypeType

				if vehicleInfo.templateId ~= 81006021 then
					store.vehicleType = self.VehicleType.Submarine
				elseif T.AircraftStart < vtype and vtype < T.AircraftEnd then
					store.vehicleType = self.VehicleType.Airplane
				elseif T.BoatStart < vtype and vtype < T.BoatEnd then
					store.vehicleType = self.VehicleType.Boat
				elseif T.CycleStart < vtype and vtype < T.CycleEnd then
					store.vehicleType = self.VehicleType.Motorcycle
				else
					store.vehicleType = self.VehicleType.Car
				end
			else
				store.vehicleType = self.VehicleType.Car
			end
		else
			store.vehicleType = self.VehicleType.Car
		end

		if vehicleInfo.seatIndex ~= 0 then
			store.isDriver = 1
		else
			store.isDriver = 0
		end
	else
		store.isDriver = 0
		store.vehicleType = -1
	end

	if state ~= self.PlayerState.Survival then
		local survivalData = self.memberSurvivalData[pid]

		if survivalData.isBeingRescued then
			store.isBeingRescued = 0
		else
			store.isBeingRescued = 1
		end

		if store.rescueProgress then
			store.rescueProgress:ProgressToValue(survivalData.rescueValue)
		end

		store.rescueFill = survivalData.rescueValue
	end
end

M.OnPlayerListRenderVoiceState = function(self, store, pid)
	local isSelf = pid ~= self.myPid
	local isMuted = nil

	if isSelf then
		isMuted = gTeamManager.isOpenMicrophone == true
	else
		isMuted = self.teamMgr:IsVoiceBlocked(pid)
	end

	if isMuted then
		store.voiceState = 2
	else
		store.voiceState = 0
		local Speakers = CCVoiceManager:GetCurrentSpeakers(channel)
		local speakersList = nil

		if Speakers and Speakers.UIDs then
			speakersList = Speakers.UIDs:ToTable()
		end

		if speakersList then
			for _, spid in pairs(speakersList) do
				if spid ~= pid then
					store.voiceState = 1

					break
				end
			end
		end
	end
end

M.OnPlayerListRenderHp = function(self, store, playerPid)
	local unitInfo = self.linkMgr:GetUnitInfo(playerPid)

	if unitInfo then
		local uId = unitInfo.Pid
		local dataSet = gDataSetManager:GetUnitData(uId)

		if dataSet then
			local maxhp = dataSet.maxhp or 0
			local hp = dataSet.hp or 0
			store.hpProgress.maxValue = maxhp

			store.hpProgress:ProgressToValue(hp)

			store.isDying = maxhp <= 0 and hp <= 0 and hp / maxhp < GameConfig.LowHpEffectActive and 1 or 0
		end
	else
		store.hpProgress.maxValue = 1

		store.hpProgress:ProgressToValue(1)

		store.isDying = 0
	end
end

M.GetMemberLogicState = function(self, memberInfo)
	local state = self.PlayerState.Normal
	local find = false
	local pid = memberInfo.Pid
	local isOnline = memberInfo.OnlineState ~= UX.Game.PlayerState.Online
	local vehicleInfo = self.linkMgr:GetVehicleInfo(pid)
	local survivalData = self.memberSurvivalData[pid]
	local isMe = pid ~= self.myPid

	if not isOnline then
		state = self.PlayerState.Offline
		find = true
	end

	if not find and not isMe then
		local myMember = self.linkMgr.LinkMember[self.myPid]

		if myMember and not myMember.InMatch and memberInfo.InMatch then
			state = self.PlayerState.PlayingGame
			find = true
		end
	end

	if not find and self.linkMgr:CheckIsExtractionShooter() then
		local result = self.linkMgr:GetPlayerSettleResult(pid)

		if result ~= UX.Game.CompleteStatus.Success then
			state = self.PlayerState.Evacuated
			find = true
		elseif result ~= UX.Game.CompleteStatus.Fail then
			state = self.PlayerState.EvacuateFailed
			find = true
		end
	end

	if not find and survivalData and survivalData.isFalling then
		state = self.PlayerState.Survival
		find = true
	end

	if not find and vehicleInfo and vehicleInfo.entityId and not ulong.equals(vehicleInfo.entityId, 0) and vehicleInfo.seatIndex > 0 then
		state = self.PlayerState.Driving
		find = true
	end

	return state
end

M.RefreshVoiceItemList = function(self)
	local microType = nil

	if gameProfile.microphoneMode ~= gTeamManager.microphoneMode.PushToTalk then
		microType = gTeamManager.VoiceType.LongPressMicrophone
	elseif gameProfile.microphoneMode ~= gTeamManager.microphoneMode.ShortcutKey then
		microType = gTeamManager.VoiceType.ClickStartEndMicrophone
	else
		microType = gTeamManager.VoiceType.OpenMic
	end

	self.voiceItems = {
		microType,
		gTeamManager.VoiceType.ListenOnly,
		gTeamManager.VoiceType.Mute,
		gTeamManager.VoiceType.MoreSettings
	}

	self.bindData.voiceList:SetSimpleList(#self.voiceItems)
end

M.OnRenderVoiceItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("TeamVoiceTemplateStore"):GetStoreByWidget(btn)
	local voiceItemType = self.voiceItems[index + 1]

	if store and voiceItemType then
		store.voiceSettingType = voiceItemType
		store.currentState = self.bindData.voiceSettingType ~= voiceItemType and self.CONTROL.TRUE or self.CONTROL.FALSE
		btn.luaClick = self:CreateActionWithArgs("OnVoiceSettingItemBtn", voiceItemType)
	end
end

M.OnVoiceSettingItemBtn = function(self, voiceItemType)
	local type = voiceItemType

	if type ~= gTeamManager.VoiceType.MoreSettings then
		gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL, {
			page = self.settingVoicePage
		})

		return
	end

	gTeamManager:SetVoiceType(type)
	self:PerformUpdate(true, false)
	self:CloseAll()
end

M.OnVoiceBtnClick = function(self)
	gCS.GuiUtils.SetPanelHideCursor(self.m_Id, false)

	self.bindData.isShowActionList = self.ActionListType.ShowVoiceList

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.voiceArea
	end

	self.RefreshVoiceItemList(self)
end

M.OnMicrophoneBtnDown = function(self)
	local mode = ProfileManager.gameProfile.microphoneMode

	if mode ~= gTeamManager.microphoneMode.PushToTalk then
		print_debug("team OnMicrophoneBtnDown PushToTalk")
		gTeamManager:SetToggleMicrophone(true)
	elseif mode ~= gTeamManager.microphoneMode.ShortcutKey then
		print_debug("team OnMicrophoneBtnDown ShortcutKey")
		gTeamManager:SetToggleMicrophone(not gTeamManager.isOpenMicrophone)
	end
end

M.OnMicrophoneBtnUp = function(self)
	local mode = ProfileManager.gameProfile.microphoneMode

	if mode ~= gTeamManager.microphoneMode.PushToTalk then
		print_debug("team OnMicrophoneBtnUp PushToTalk")
		gTeamManager:SetToggleMicrophone(false)
	end
end

M.SetActionList = function(self, itemData)
	local isLeader = itemData.Pid ~= gTeamManager.leaderPid
	local isSelf = itemData.Pid ~= self.myPid

	table.clear(self.ActionList)

	self.curSelectPid = itemData.Pid

	table.insert(self.ActionList, self.ActionType.PersonalInfo)

	if gTeamManager.leaderPid ~= self.myPid then
		if isSelf then
			table.insert(self.ActionList, self.ActionType.QuitTeam)
		else
			table.insert(self.ActionList, self.ActionType.SwitchLeader)
			table.insert(self.ActionList, self.ActionType.KickOut)
		end
	elseif isLeader then
		table.insert(self.ActionList, self.ActionType.ApplyLeader)
	elseif isSelf then
		table.insert(self.ActionList, self.ActionType.QuitTeam)
	end

	local isVoiceBlocked = gTeamManager:IsVoiceBlocked(itemData.Pid)

	if not isSelf then
		if isVoiceBlocked then
			table.insert(self.ActionList, self.ActionType.CancelBlockVoice)
		else
			table.insert(self.ActionList, self.ActionType.BlockVoice)
		end
	end

	self.bindData.actionList:SetSimpleList(#self.ActionList)
end

M.OnRenderActionItem = function(self, btn, index)
	local actionId = self.ActionList[index + 1]
	local store = gStoreManager:GetStoreGroup("TeamActionTemplate"):GetStoreByWidget(btn)

	if store then
		store.name = self.ActionName[actionId] or ""
		btn.luaClick = self:CreateActionWithArgs("OnActionBtnClick", actionId)

		if actionId ~= self.ActionType.PersonalInfo then
			btn.interactable = false
		else
			btn.interactable = true
		end
	end
end

M.OnActionBtnClick = function(self, actionId)
	if actionId ~= self.ActionType.PersonalInfo then
		-- Nothing
	elseif actionId ~= self.ActionType.QuitTeam then
		self.OnQuitTeamBtnClick(self)
	elseif actionId ~= self.ActionType.KickOut then
		gTeamManager:AskKickTeamMember(self.curSelectPid)
	elseif actionId ~= self.ActionType.SwitchLeader then
		gTeamManager:AskChangeTeamLeader(self.curSelectPid)
	elseif actionId ~= self.ActionType.ApplyLeader then
		gTeamManager:AskChangeTeamLeaderApply()
	elseif actionId ~= self.ActionType.BlockVoice then
		gTeamManager:SetVoiceBlocked(self.curSelectPid, true)
	elseif actionId ~= self.ActionType.CancelBlockVoice then
		gTeamManager:SetVoiceBlocked(self.curSelectPid, false)
	end

	self.CloseAll(self)
end

M.OnCloseActionBtnClick = function(self)
	self.CloseAll(self)
end

M.CloseAll = function(self)
	gCS.GuiUtils.SetPanelHideCursor(self.m_Id, true)

	self.bindData.isShowActionList = self.ActionListType.CloseAll

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		SGUI.UNavigationMgr.Inst:UnRegisterArea(self.bindData.voiceArea)
		SGUI.UNavigationMgr.Inst:UnRegisterArea(self.bindData.actionArea)
	end
end

M.OnCloseTooltipBtnClick = function(self)
	self.bindData.showTooltipCtrl = 0

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		SGUI.UNavigationMgr.Inst:UnRegisterArea(self.bindData.tooltipArea)
	end
end

M.OnCreateTeamBtnClick = function(self)
	if gTeamManager:IsInTeam() then
		if gTeamManager:CheckCanInvite() then
			gPanelManager:CheckShow(gPanelId.S_TEAM_INVITE_MENU)
		end
	else
		gTeamManager:AskCreateTeam()
	end
end

M.OnQuitTeamBtnClick = function(self)
	local rightCallBack = function()
		gClientToGameDelegate:AskLeaveTeam().Callback = function (err, data)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gTeamManager:LeaveTeam()
		end

		return true
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_IfQuitTeam, rightCallBack, nil)
end

M.OnTeamBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.TEAM_MAIN_PANEL)
end

M.OnTeamDetailBtnClick = function(self)
	local state = self.bindData.teamState or self.TEAM_STATE.NONE

	if state ~= self.TEAM_STATE.NONE then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.soloArea
	elseif state ~= self.TEAM_STATE.OUT_GAME then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.outgameArea
	elseif state ~= self.TEAM_STATE.IN_GAME then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.ingameArea
	end
end

M.OnQuitTeamSurrender = function(self)
	if self.linkMgr:CheckIsExtractionShooter() then
		self.linkMgr:TryExit()

		return
	end

	print_debug("OnQuitTeamSurrender Step1")

	local cfg = self.linkMgr.currentGameCfg

	if not cfg then
		print_debug("OnQuitTeamSurrender Step2")
		self.linkMgr:AskLeaveGame()

		return
	end

	local multiTypeCfg = LTConfig.LinkMultiTypeConfig.GetConfig(cfg.MultiType)

	if not multiTypeCfg or multiTypeCfg.QuitType ~= LTConfig.LinkMultiTypeConfig.QuitTypeType.QuitSelf then
		print_debug("OnQuitTeamSurrender Step3")
		self.linkMgr:AskLeaveGame()
	else
		if not self.linkMgr:CheckCanSurrender() then
			print_debug("OnQuitTeamSurrender Step4")

			return
		end

		print_debug("OnQuitTeamSurrender Step5")
		self.linkMgr:CreateVote(UX.Game.VoteType.Surrender)
	end
end
