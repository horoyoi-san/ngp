-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Club\OnlineClubTitlePanelStore.lua
-- Decompiled from: 01238_OnlineClubTitlePanelStore.lua_6b1fb084db94.luajit

C_OnlineClubTitlePanelStore = DefClass("C_OnlineClubTitlePanelStore", C_OnlineClubTitlePanelStore, C_StoreGroup)
GroupName2Class.OnlineClubTitlePanelStore = C_OnlineClubTitlePanelStore
local M = C_OnlineClubTitlePanelStore
local ClubJobType = UX.Game.ClubJobType
local CUSTOM_JOB_TINDEX = {
	["\\xaflb"] = 1,
	["\\xa4gd"] = 0
}

M.OnAwake = function(self)
	self.Init(self)
	self.RegisterWidget(self)

	self.msgEvents = {
		[gEventConstants.CLUB_JOB_LIST_REFRESH] = self.CreateAction(self, self.RefreshAll),
		[gEventConstants.CLUB_MEMBER_LIST_REFRESH] = self.CreateAction(self, self.RefreshAll)
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.Init = function(self)
	self.instance = {
		["@R\\xc1\\xaa\\xa5\\xbc.\\xc6\\xea"] = false,
		systemJobHolders = {}
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.ClosePanel)
	self.bindData.topList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderSystemJobItem)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderCustomJobItem)
	self.bindData.list.onGetTIndex = self.CreateAction(self, self.OnGetCustomJobTIndex)
end

M.OnShow = function(self, panelId, data)
	self.RefreshAll(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.instance = nil
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.m_Id)
end

M.RefreshAll = function(self)
	self.RefreshSystemJobList(self)
	self.RefreshCustomJobList(self)
end

M.RefreshSystemJobList = function(self)
	local clubInfo = gClubManager:GetClubInfo()
	self.instance.systemJobHolders = clubInfo and gClubUIUtils:GetClubAdminList(clubInfo) or {}

	self.bindData.topList:SetSimpleList(#self.instance.systemJobHolders)
end

M.RefreshCustomJobList = function(self)
	local jobCount = #gClubManager:GetCustomJobList()
	self.instance.showAddJob = gClubManager:CanEditClub() and jobCount <= LTConfig.ClubConfig.PositionMaxAmount

	self.bindData.list:SetSimpleList(self.instance.showAddJob and jobCount + 1 or jobCount)
end

M.OnGetCustomJobTIndex = function(self, index)
	if self.instance.showAddJob and index ~= #gClubManager:GetCustomJobList() then
		return CUSTOM_JOB_TINDEX.Add
	end

	return CUSTOM_JOB_TINDEX.Job
end

M.OnRenderSystemJobItem = function(self, widget, csIndex)
	local member = self.instance.systemJobHolders[csIndex + 1]

	if not member then
		return
	end

	local store = gClubUIUtils:GetStore(widget, "ClubAdminTemplateStore")
	store.memberType = gClubManager:GetJobDisplayName(member)
	store.memberTypeCtrl = member.ClubJob ~= ClubJobType.Admin and 1 or 0
	store.jobColor = gClubManager:GetJobColor(member)

	if store.userInfo then
		store.userInfo.pid = member.Pid
	end

	if store.commonAccountWidget then
		gClubUIUtils:RenderCommonAccount(store.commonAccountWidget, member.Pid)
	end
end

M.OnRenderCustomJobItem = function(self, widget, csIndex)
	local job = gClubManager:GetCustomJobList()[csIndex + 1]

	if not job then
		widget.luaClick = self.CreateAction(self, self.OnCreateCustomJob)

		return
	end

	local store = gClubUIUtils:GetStore(widget, "OnlineClubTitleTemplateStore")
	store.titleNameText = job.Name or ""
	store.jobColor = LTConfig.ClubConfig.CustomPositionColor
	local holder = gClubManager:GetJobHolderMember(job.Id)
	local avatarStore = gClubUIUtils:GetStore(store.avatarWidget, "S_CommonAccountAvatarMiddle1Store")

	if avatarStore and avatarStore.userInfo then
		avatarStore.userInfo.pid = holder and holder.Pid or 0
	end

	local canEdit = gClubManager:CanEditClub()

	store.deleteBtn:SetActive(canEdit)
	store.editBtn:SetActive(canEdit)

	if not canEdit then
		return
	end

	store.deleteBtn.interactable = holder ~= nil
	store.deleteBtn.luaClick = self:CreateActionWithArgs(self.OnDeleteCustomJob, job)
	store.editBtn.luaClick = self:CreateActionWithArgs(self.OnEditCustomJob, job)
end

M.OnCreateCustomJob = function(self)
	local existingNames = {}

	for _, job in ipairs(gClubManager:GetCustomJobList()) do
		existingNames[job.Name] = true
	end

	local index = 1
	local name = nil

	repeat
		name = "自定义职位" .. index
		index = index + 1
	until not existingNames[name]

	gClubManager:AskClubCreateCustomJob(name)
end

M.OnDeleteCustomJob = function(self, job)
	if not job then
		return
	end

	gClubManager:AskClubDeleteCustomJob(job.Id)
end

M.OnEditCustomJob = function(self, job)
	if not job then
		return
	end
end
