-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineIngamePlayerStore.lua
-- Decompiled from: 01113_OnlineIngamePlayerStore.lua_9be65324d13b.luajit

local ParkourStateConfig = LTConfig.ParkourStateConfig
C_OnlineIngamePlayerStore = DefClass("C_OnlineIngamePlayerStore", C_OnlineIngamePlayerStore, C_StoreGroup)
GroupName2Class.OnlineIngamePlayerStore = C_OnlineIngamePlayerStore
local M = C_OnlineIngamePlayerStore

M.ctor = function(self)
	self.mgr = gLinkManager
	self.timer = nil
end

M.OnAwake = function(self)
	self.bindData.memberList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderMemberItem)
	self.bindData.watchBtn.luaClick = self.CreateAction(self, "OnWatchOnlinePlayer", self.mgr)
	self.bindData.quitBtn.luaClick = self.CreateAction(self, self.OnQuit)
	self.memebrList = {}
	self.msgEvents = {
		[gEventConstants.PLAYER_HP_CHANGE] = self.CreateAction(self, self.OnUnitHpChange),
		[gEventConstants.LINK_MEMBER_CHANGE] = self.CreateAction(self, self.OnRefreshInfo),
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self.CreateAction(self, self.OnRefreshInfo),
		[gEventConstants.LINK_VEHICLE_CHANGE] = self.CreateAction(self, self.OnMemberStateInfoChange),
		[gEventConstants.ENTER_BASE_VEHICLE_FINISH] = self.CreateAction(self, self.OnSelfVehicleInfoEnter),
		[gEventConstants.EXIT_BASE_VEHICLE_FINISH] = self.CreateAction(self, self.OnSelfVehicleInfoExit),
		[gEventConstants.ONLINE_INGAME_WATCH_STATE_CHANGE] = self.CreateAction(self, self.OnWatchStateChange),
		[gEventConstants.ON_PLAYER_STATE_CHANGE] = self.CreateAction(self, self.OnWatchStateChange),
		[gEventConstants.LINK_LOADING_FINISH] = self.CreateAction(self, self.OnMemberStateInfoChange),
		[gEventConstants.PAOKU_STATE_CHANGE] = self.CreateAction(self, self.OnWatchStateChange)
	}
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.OnRenderMemberItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local pid = self.memebrList[index + 1]
	local memberInfo = self.mgr.LinkMember[pid]

	if not memberInfo then
		return
	end

	local headIcon, _ = gHunLunManager:GetHeadIconAndName(gClientUtils.GetLinkHeadId(memberInfo))
	local dutyInfo = self.mgr:GetDutyInfoByPid(pid)
	local unitInfo = self.mgr:GetUnitInfo(pid)
	local index = self.mgr.LinkMemberIndex[self.mgr.LinkMode][pid] or 0
	store.color = self.mgr:GetColorInfo(pid)
	store.headIcon = headIcon
	store.nameLabel = gSocialFriendManager:GetPlayerDisplayName(pid, memberInfo.Name)
	store.hasDuty = BOOL2CTL[dutyInfo == nil]
	store.dutyIcon = dutyInfo and dutyInfo.icon or 0
	store.numberLabel = index

	self:RefreshPlayerState(store, pid)

	self.subStoreDict[pid] = store

	if unitInfo then
		local uId = unitInfo.Pid
		local dataSet = gDataSetManager:GetUnitData(uId)
		self.subStoreDict[uId] = store

		if dataSet then
			store.hpProgress.maxValue = dataSet.maxhp

			self.RefreshHp(self, unitInfo.Id, dataSet.hp)
		end
	else
		store.hpProgress.maxValue = 1

		store.hpProgress:ProgressToValue(1)
	end
end

M.RefreshHp = function(self, pid, hp)
	local store = self.subStoreDict[pid]

	if not store then
		self.OnRefreshInfo(self)

		return
	end

	store.hpProgress:ProgressToValue(hp)
end

M.RefreshPlayerState = function(self, store, pid)
	store.playerState = self.mgr:CheckPlayerState(pid)
end

M.OnShow = function(self, panelId, data)
	self.OnRefreshInfo(self)
	self.OnWatchStateChange(self)
end

M.OnWatchStateChange = function(self)
	if not self.mgr.watchState then
		self.bindData.watchBtn.interactable = false

		self.bindData.watchBtn:SetActive(false)

		return
	end

	local OnGround = not gCoreHudUIManager.activePlayerStates[gParkourPlayerStateType.AIR]

	if not OnGround then
		self.bindData.watchBtn.interactable = false

		self.bindData.watchBtn:SetActive(true)

		return
	end

	local clientStates = gMainMenuMgr:GetClientState()
	local interactable = true
	local visible = true
	local cfgIdx = gCS.LuaUtils.IsNonMobileAdaptive() and 1 or 2

	for _, key in pairs(clientStates) do
		local cfg = ParkourStateConfig.GetConfig(key)

		if cfg and cfg.Observe and #cfg.Observe > 2 then
			local observeCfg = cfg.Observe[cfgIdx]

			if not observeCfg.interactable or observeCfg.interactable ~= 0 then
				interactable = false
			end

			if not observeCfg.visible or observeCfg.visible ~= 0 then
				visible = false
			end
		end
	end

	self.bindData.watchBtn.interactable = interactable

	self.bindData.watchBtn:SetActive(visible)
end

M.OnRefreshInfo = function(self)
	self.memebrList = {}
	self.subStoreDict = {}
	local selfDuty = self.mgr:GetSelfDuty()

	for pid, _ in pairs(self.mgr.LinkMemberInfo) do
		if self.mgr.currentGameCfg.IsCampus then
			if selfDuty ~= self.mgr:GetTargetDuty(pid) then
				self.memebrList[#self.memebrList + 1] = pid
			end
		else
			self.memebrList[#self.memebrList + 1] = pid
		end
	end

	self.bindData.memberList:SetSimpleList(#self.memebrList)
end

M.OnMemberStateInfoChange = function(self, _, pid)
	local store = self.subStoreDict[pid]

	if not store then
		self.OnRefreshInfo(self)

		return
	end

	self.RefreshPlayerState(self, store, pid)
end

M.OnSelfVehicleInfoEnter = function(self, _, uid)
	if ulong.equals(uid, gDriveVehiclesManager.cs_manager.CurDriveVehicleUid) then
		local store = self.subStoreDict[gPlayerManager.infoLogin.bindData.pid]

		if not store then
			return
		end

		if self.mgr.PLAYER_STATE.VEHICLE >= store.playerState then
			store.playerState = self.mgr.PLAYER_STATE.VEHICLE
		end
	end
end

M.OnSelfVehicleInfoExit = function(self, _, uid)
	if ulong.equals(uid, gDriveVehiclesManager.cs_manager.CurDriveVehicleUid) then
		local store = self.subStoreDict[gPlayerManager.infoLogin.bindData.pid]

		if not store then
			return
		end

		if store.playerState ~= self.mgr.PLAYER_STATE.VEHICLE then
			store.playerState = self.mgr.PLAYER_STATE.NORMAL
		end
	end
end

M.OnUnitHpChange = function(self, _, pid)
	local unitInfo = gDataSetManager:GetUnitData(pid)

	if not unitInfo then
		self.OnRefreshInfo(self)

		return
	end

	self.RefreshHp(self, pid, unitInfo.hp)
end

M.OnClose = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.OnQuit = function(self)
	if not self.mgr:CheckCanSurrender() then
		return
	end

	self.mgr:CreateVote(UX.Game.VoteType.Surrender)
end
