local ProgressConfig = LTConfig.LinkProgressConfig
C_OnlineReadyHalfStore = DefClass("C_OnlineReadyHalfStore", C_OnlineReadyHalfStore, C_StoreGroup)
GroupName2Class.OnlineReadyHalfStore = C_OnlineReadyHalfStore
local M = C_OnlineReadyHalfStore

function M:ctor()
	self.mgr = gLinkManager
	self.groupId = ProgressConfig.halfConfirm
	self.msgEvents = {
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self:CreateAction(self.OnMemberInfoChange)
	}
end

function M:OnAwake()
	self.bindData.acceptBtn.luaClick = self:CreateAction(self.OnAcceptBtnClick)
	self.bindData.rejectBtn.luaClick = self:CreateAction(self.OnRejectBtnClick)
	self.bindData.memberList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderPlayerListItem)
end

function M:OnEnable()
	self.bindData.memberList:SetSimpleList(#self.mgr.matchMemberList)
	self.mgr.progressMgr:OnRenderProgress(self.groupId, self, self.bindData.countDown)
end

function M:OnDisable()
	self.mgr.progressMgr:ClearProgress(self.groupId)
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnAcceptBtnClick()
	self.mgr.progressMgr:OnProgressConfirm(self.groupId)
end

function M:OnRejectBtnClick()
	self.mgr.progressMgr:OnProgressCancel(self.groupId)
end

function M:OnSimpleRenderPlayerListItem(btn, index)
	local data = self.mgr.matchMemberList[index + 1]

	self.mgr:OnMemberRenderItem(btn, index, data)
end

function M:OnMemberInfoChange()
	if self.mgr:CheckPlayerIsReady() then
		self.bindData.acceptBtn.interactable = false
		self.bindData.rejectBtn.interactable = false
	end

	self.bindData.memberList:RefreshLogicList()
end
