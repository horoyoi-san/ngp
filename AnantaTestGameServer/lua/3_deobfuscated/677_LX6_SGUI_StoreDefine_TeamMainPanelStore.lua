local TextCommonTextConfig = LTConfig.TextCommonTextConfig
C_TeamMainPanelStore = DefClass("C_TeamMainPanelStore", C_TeamMainPanelStore, C_StoreGroup)
GroupName2Class.TeamMainPanelStore = C_TeamMainPanelStore
local M = C_TeamMainPanelStore

function M:ctor()
	self.ActionType = {
		SwitchLeader = 3,
		KickOut = 2,
		ApplyLeader = 4,
		QuitTeam = 1,
		PersonalInfo = 0
	}
	self.ActionName = {
		[self.ActionType.PersonalInfo] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamPersonalInfo).Text,
		[self.ActionType.QuitTeam] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.QuitTeam).Text,
		[self.ActionType.KickOut] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.KickOutTeam).Text,
		[self.ActionType.SwitchLeader] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamSwitchLeader).Text,
		[self.ActionType.ApplyLeader] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamApplyLeader).Text
	}
end

function M:OnAwake()
	self.ActionList = {}
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")

	function self.bindData.list.onGetTIndex(_)
		return 0
	end

	self.bindData.actionList.luaSimpleRenderItem = self:CreateAction("OnRenderActionItem")

	function self.bindData.actionList.onGetTIndex(_)
		return 0
	end

	self.bindData.createTeamBtn.luaClick = self:CreateAction("OnCreateTeamBtnClick")
	self.bindData.quitBtn.luaClick = self:CreateAction("OnQuitTeamBtnClick")
	self.bindData.closeActionBtn.luaClick = self:CreateAction("OnCloseActionBtnClick")
	local msgEvents = {
		[gEventConstants.TEAM_REFRESH_DATA] = self:CreateAction("OnTeamRefreshData")
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnEnable()
	self:SetData()
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:SetData()
	self.bindData.isShowActionList = 0
	self.pid = gPlayerManager.infoLogin.bindData.pid
	local isInTeam = gTeamManager.members and #gTeamManager.members > 0
	self.bindData.isShowQuitBtn = isInTeam and 1 or 0

	if not isInTeam then
		self.bindData.list:SetSimpleList(0)

		return
	end

	self.bindData.list:SetSimpleList(#gTeamManager.members)
	self.bindData.list:SetItemSelected(0, true)
end

function M:OnTeamRefreshData()
	self:SetData()
end

function M:OnRenderItem(btn, index)
	local itemData = gTeamManager.members[index + 1]
	local store = gStoreManager:GetStoreGroup("TeamMemberTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.isSelf = itemData.Pid == self.pid and 1 or 0
	store.isLeader = itemData.Pid == gTeamManager.leaderPid and 1 or 0
	store.name = itemData.Name
	store.title = index + 1 .. "P"
	btn.luaClick = self:CreateActionWithArgs("OnMemberBtnClick", itemData)
end

function M:OnMemberBtnClick(itemData)
	self.bindData.isShowActionList = 1
	local isLeader = itemData.Pid == gTeamManager.leaderPid
	local isSelf = itemData.Pid == self.pid
	self.ActionList = {}
	self.curSelectPid = itemData.Pid

	table.insert(self.ActionList, self.ActionType.PersonalInfo)

	if gTeamManager.leaderPid == self.pid then
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

	self.bindData.actionList:SetSimpleList(#self.ActionList)
end

function M:OnRenderActionItem(btn, index)
	local actionId = self.ActionList[index + 1]
	local store = gStoreManager:GetStoreGroup("TeamActionTemplate"):GetStoreByWidget(btn)
	store.name = self.ActionName[actionId]
	btn.luaClick = self:CreateActionWithArgs("OnActionBtnClick", actionId)

	if actionId == self.ActionType.PersonalInfo then
		btn.interactable = false
	else
		btn.interactable = true
	end
end

function M:OnActionBtnClick(actionId)
	if actionId == self.ActionType.PersonalInfo then
		-- Nothing
	elseif actionId == self.ActionType.QuitTeam then
		self:OnQuitTeamBtnClick()
	elseif actionId == self.ActionType.KickOut then
		gTeamManager:AskKickTeamMember(self.curSelectPid)
	elseif actionId == self.ActionType.SwitchLeader then
		gTeamManager:AskChangeTeamLeader(self.curSelectPid)
	elseif actionId == self.ActionType.ApplyLeader then
		gTeamManager:AskChangeTeamLeaderApply()
	end

	self.bindData.isShowActionList = 0
end

function M:OnCreateTeamBtnClick()
	if gTeamManager.members then
		local memberCount = #gTeamManager.members

		if memberCount >= 4 then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_YourTeamIsFull)

			return
		elseif memberCount > 0 then
			gPanelManager:CheckShow(gPanelId.S_TEAM_INVITE_MENU)

			return
		end
	end

	gTeamManager:AskCreateTeam()
end

function M:OnQuitTeamBtnClick()
	local function rightCallBack()
		gClientToGameDelegate:AskLeaveTeam().Callback = function (err, data)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gTeamManager:LeaveTeam()
		end

		return true
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_IfQuitTeam, rightCallBack, nil)
end

function M:OnCloseActionBtnClick()
	self.bindData.isShowActionList = 0
end
