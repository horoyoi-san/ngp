local LinkConfig = LTConfig.LinkConfig
C_ChallengeRankStore = DefClass("C_ChallengeRankStore", C_ChallengeRankStore, C_StoreGroup)
GroupName2Class.ChallengeRankStore = C_ChallengeRankStore
local M = C_ChallengeRankStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.mgr = gLinkManager
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnAwake()
	self.msgEvents = {
		[gEventConstants.ADD_CHAT_FRIEND] = self:CreateAction(self.OnLinkMemberInfoChange),
		[gEventConstants.LINK_MEMBER_CHANGE] = self:CreateAction(self.OnLinkMemberInfoChange),
		[gEventConstants.ONLINE_INGAME_WATCH_STATE_CHANGE] = self:CreateAction(self.RefreshWathState),
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self:CreateAction(self.RefreshInfo)
	}
	self.bindData.backGround.luaClick = self:CreateAction(self.OnBackBtnClick)
	self.bindData.againBtn.luaClick = self:CreateAction(self.OnAgainBtnClick)
	self.bindData.watchBtn.luaClick = self:CreateAction(self.OnWatchOnlinePlayer)
	self.bindData.rankList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRankItem)
	self.bindData.rankList.onGetTIndex = self:CreateAction(self.OnGetTIndex)
	self.bindData.countDown.luaFinished = self:CreateAction(self.OnCountDownFinished)
	self.friendInvited = {}
	self.timer = nil
end

function M:OnBackBtnClick()
	if self.bindData.isOnline == BOOL2CTL[true] then
		self.mgr:AskLeaveGame()
	end

	gChallengeManager:ExitFinalRankPanel()
end

function M:OnAgainBtnClick()
	self.bindData.backGround.interactable = false
	self.bindData.againBtn.interactable = false

	self.mgr:AskPlayGameAgain(self.bindData.againState)
end

function M:OnLinkMemberInfoChange()
	self.bindData.rankList:RefreshLogicList()
	self:RefreshInfo()
end

function M:OnWatchOnlinePlayer()
	self.mgr:OnWatchOnlinePlayer(nil, true)
end

function M:OnGetTIndex(index)
	return self.showList[index + 1].tIndex
end

function M:OnRenderRankItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.showList[index + 1]

	if not data.time or data.time == math.huge then
		store.timeLabel = LTConfig.TextScriptTextConfig.GetConfig(89901076).Text
		store.rankNum = ""
	else
		store.rankNum = gString.Format("%02d", index + 1)
		store.timeLabel = gTimeUtils:FormatTime(data.time) .. "." .. gTimeUtils:FormatMs(data.time)
	end

	local isSelf = data.id == gCarRaceManager.taskID or data.id == gPlayerManager.infoLogin.bindData.pid
	local hasAward = #data.award > 0

	if data.player then
		store.nameLabel = data.player.name
		store.playerIconId = data.player.icon
	else
		store.pid = data.id
	end

	store.carIconId = data.vehicle.icon
	store.carNameLabel = data.vehicle.name
	store.isMine = BOOL2CTL[isSelf]
	store.isFriend = self.friendInvited[data.id] and BOOL2CTL[true] or BOOL2CTL[isSelf or gFriendManager:IsFriend(data.id)]
	store.hasAward = BOOL2CTL[hasAward]
	store.againState = self.mgr.tryAgainDict[data.id] == true and self.bindData.againState or 0
	store.againLabel = self.mgr:GetBaseAgainLabel(self.bindData.againState)

	if data.tIndex == 3 then
		local dutyInfo = gLinkManager:GetDutyInfoByPid(data.id)

		if dutyInfo then
			store.dutyIconId = dutyInfo.icon
			store.dutyLabel = dutyInfo.name
		end
	end

	if store.addFriendBtn then
		function store.addFriendBtn.luaClick()
			self.friendInvited[data.id] = true
			store.isFriend = BOOL2CTL[true]

			gFriendManager:AskApplyFriend(data.id)
		end
	end
end

function M:OnShow(panelId, data)
	if table.isNilOrEmpty(data) then
		print_error("ChallengeRankStore OnShow data is nil")
		self:OnBackBtnClick()

		return
	end

	local showList = data.data or {}

	if data.title then
		self.bindData.titleLabel = data.title
	end

	self.bindData.titleType = #showList > 0 and showList[1].tIndex or 0
	self.bindData.isOnline = BOOL2CTL[data.isOnline]
	self.showList = showList

	self.bindData.rankList:SetSimpleList(#self.showList)

	self.isOnline = data and data.isOnline or false

	self:RefreshInfo()
	self:RefreshWathState()
end

function M:RefreshInfo()
	if self.isOnline then
		local againState, keyNameId = self.mgr:CheckAgainState()
		self.bindData.againState = againState

		self.bindData.againBtn:SetPCKeyInfoTipNameId(keyNameId)

		local showProgress = not table.isNilOrEmpty(self.mgr.tryAgainDict) and againState ~= C_LinkManager.AGAIN_STATE.None

		if self.bindData.showProgress ~= BOOL2CTL[showProgress] then
			self.bindData.countDown:Play(LinkConfig.ClearingMaxTime)
		end

		self.bindData.showProgress = BOOL2CTL[showProgress]
		self.bindData.againLabel = self.mgr:GetAgainLabel(self.bindData.againState)
	end
end

function M:OnCountDownFinished()
	self.bindData.showProgress = BOOL2CTL[false]
end

function M:RefreshWathState()
	self.bindData.watchBtn.interactable = self.mgr.watchState
end

function M:OnClose()
	return
end
