C_OnlineIngamePlayerStore = DefClass("C_OnlineIngamePlayerStore", C_OnlineIngamePlayerStore, C_StoreGroup)
GroupName2Class.OnlineIngamePlayerStore = C_OnlineIngamePlayerStore
local M = C_OnlineIngamePlayerStore

function M:ctor()
	self.mgr = gLinkManager
	self.timer = nil
	self.msgEvents = {
		[gEventConstants.PLAYER_HP_CHANGE] = self:CreateAction(self.OnUnitHpChange),
		[gEventConstants.LINK_MEMBER_CHANGE] = self:CreateAction(self.OnRefreshInfo),
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self:CreateAction(self.OnRefreshInfo),
		[gEventConstants.LINK_VEHICLE_CHANGE] = self:CreateAction(self.OnVehicleInfoChange),
		[gEventConstants.ENTER_VEHICLE_FINISH] = self:CreateAction(self.OnSelfVehicleInfoChange),
		[gEventConstants.EXIT_VEHICLE_FINISH] = self:CreateAction(self.OnSelfVehicleInfoChange),
		[gEventConstants.ONLINE_INGAME_WATCH_STATE_CHANGE] = self:CreateAction(self.OnWatchStateChange)
	}
end

function M:OnAwake()
	self.bindData.memberList.luaSimpleRenderItem = self:CreateAction(self.OnRenderMemberItem)
	self.bindData.watchBtn.luaClick = self:CreateAction("OnWatchOnlinePlayer", self.mgr)

	self:RegisterMessageEvents(self.msgEvents)

	self.memebrList = {}
end

local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:OnRenderMemberItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local pid = self.memebrList[index + 1]
	local memberInfo = self.mgr:GetMemberInfo(pid)
	local linkMemberInfo = self.mgr.LinkMemberInfo[pid]
	local headIcon, _ = gHunLunManager:GetHeadIconAndName(memberInfo.PzHeadInfo.SystemHeadId)
	local dutyInfo = self.mgr:GetDutyInfoByPid(pid)
	local unitInfo = self.mgr:GetUnitInfo(pid)
	local index = self.mgr.LinkMemberIndex[self.mgr.LinkMode][pid] or 0
	store.headIcon = headIcon
	store.nameLabel = memberInfo.Name
	store.hasDuty = BOOL2CTL[dutyInfo ~= nil]
	store.dutyIcon = dutyInfo and dutyInfo.icon or 0
	store.indexLabel = index
	store.tempLeave = BOOL2CTL[linkMemberInfo.TempLeave]

	self:RefreshVehicleState(store, pid)

	if unitInfo then
		local uId = unitInfo.Pid
		local dataSet = gDataSetManager:GetUnitData(uId)
		self.subStoreDict[uId] = store

		if dataSet then
			store.hpProgress.maxValue = dataSet.maxhp

			self:RefreshHp(unitInfo.Id, dataSet.hp)
		end
	else
		store.hpProgress.maxValue = 1

		store.hpProgress:ProgressToValue(1)
	end
end

function M:RefreshHp(pid, hp)
	local store = self.subStoreDict[pid]

	if not store then
		self:OnRefreshInfo()

		return
	end

	store.hpProgress:ProgressToValue(hp)
end

function M:RefreshVehicleState(store, pid)
	local vehicleInfo = self.mgr:GetVehicleInfo(pid)

	if table.isNilOrEmpty(vehicleInfo) then
		store.playerState = 0

		return
	end

	local inVehicle = not ulong.equals(vehicleInfo.entityId, 0) and vehicleInfo.seatIndex >= 0
	store.playerState = inVehicle and 1 or 0
end

function M:OnShow(panelId, data)
	self:OnRefreshInfo()
	self:OnWatchStateChange()
end

function M:OnWatchStateChange()
	self.bindData.watchBtn.interactable = self.mgr.watchState
end

function M:OnRefreshInfo()
	self.memebrList = {}
	self.subStoreDict = {}

	for pid, _ in pairs(self.mgr.LinkMemberInfo) do
		self.memebrList[#self.memebrList + 1] = pid
	end

	self.bindData.memberList:SetSimpleList(#self.memebrList)
end

function M:OnVehicleInfoChange(_, pid)
	local store = self.subStoreDict[pid]

	if not store then
		self:OnRefreshInfo()

		return
	end

	self:RefreshVehicleState(store, pid)
end

function M:OnSelfVehicleInfoChange()
	self:OnVehicleInfoChange(nil, gPlayerManager.infoLogin.bindData.pid)
end

function M:OnUnitHpChange(_, pid)
	local unitInfo = gDataSetManager:GetUnitData(pid)

	if not unitInfo then
		self:OnRefreshInfo()

		return
	end

	self:RefreshHp(pid, unitInfo.hp)
end

function M:OnClose()
	self:ClearMessageEvents()

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end
