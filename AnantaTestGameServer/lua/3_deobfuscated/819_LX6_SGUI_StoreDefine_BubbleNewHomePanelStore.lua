local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_BubbleNewHomePanelStore = DefClass("C_BubbleNewHomePanelStore", C_BubbleNewHomePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleNewHomePanelStore = C_BubbleNewHomePanelStore
local M = C_BubbleNewHomePanelStore

function M:ctor()
	self.Template = {
		friendList = 3,
		favorLevel = 0,
		favorList = 1,
		friendLabel = 2
	}
end

function M:OnAwake()
	self.mgr = self.mgr or gNewBubbleMgr

	self:RegisterWidget()

	self.contentList = {}
end

function M:RegisterWidget()
	self.bindData.actionpoint.luaClick = self:CreateAction("OnClickActionpoint", gNpcFavorManager)
	self.OnRenderFavorList = self:CreateAction(self.OnSimpleRenderFavorListItem)
	self.OnClickFavorList = self:CreateAction(self.OnSimpleClickFavorList)
	self.OnGetFavorListTIndex = self:CreateAction(self.OnGetFavorTIndex)
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderContentListItem)
	self.bindData.contentList.onGetTIndex = self:CreateAction(self.OnGetTIndex)
	self.bindData.contentList.luaLayoutSet = self:CreateAction(self.OnSetListLayout)
end

function M:InitView()
	self.refreshNav = true
end

function M:RefreshPage()
	local favorLevel = nil
	local isEmpty = true
	self.contentList = {}
	self.favorList, favorLevel = self.mgr:GetRoleFavorList()
	isEmpty = #self.favorList == 0

	if not isEmpty then
		table.insert(self.contentList, {
			favorLevel = favorLevel
		})
		table.insert(self.contentList, {
			favorList = true
		})
	end

	self.friendList = self.mgr:GetCurrentFavorNpcList()
	isEmpty = isEmpty and #self.friendList == 0
	local friendLabel = gString.Format(TextScriptTextConfig.GetConfig(89901287).Text, #self.friendList)

	table.insert(self.contentList, {
		friendLabel = friendLabel
	})

	self.bindData.isEmpty = self.mgr.BOOL2CTL[isEmpty]

	self.bindData.contentList:SetSimpleList(#self.contentList + #self.friendList)

	if #self.contentList >= 3 then
		self.bindData.contentList:SetItemLabel(2, friendLabel)
	end

	self.refreshNav = true

	gNpcFavorManager:OnRenderActionPoint(self.bindData.actionpoint, 0, nil)
end

function M:OnSimpleRenderFavorListItem(btn, index)
	local data = self.favorList[index + 1]
	local agentType = data and data.npcId or 0

	self.mgr:OnRenderBubbleCover(btn, index, agentType)
end

function M:OnGetFavorTIndex(index)
	local data = self.favorList[index + 1]
	local agentType = data and data.npcId or 0

	return agentType == 0 and 1 or 0
end

function M:OnSimpleClickFavorList(btn, index)
	local agentType = self.favorList[index + 1].npcId

	if agentType == 0 then
		return
	end

	self.mgr:OnClickNpcBubbleHead(agentType)

	self.refreshNav = true
end

function M:OnSimpleRenderFriendListItem(btn, index)
	local data = self.friendList[index + 1]

	self.mgr:OnRenderBubbleFriendTempalate(btn, index, data)
end

function M:OnSetListLayout()
	if not self.refreshNav then
		return
	end

	self.refreshNav = false

	self.bindData.contentList:SetNavSelectToTop(true)
	self.bindData.contentList:GoToIndex(0, true)
end

function M:OnGetTIndex(index)
	local data = self.contentList[index + 1]

	if not data then
		return self.Template.friendList
	end

	if data.favorLevel then
		return self.Template.favorLevel
	end

	if data.favorList then
		return self.Template.favorList
	end

	return self.Template.friendLabel
end

function M:OnSimpleRenderContentListItem(btn, index)
	local tIndex = self:OnGetTIndex(index)
	local data = self.contentList[index + 1]

	if not data then
		self:OnSimpleRenderFriendListItem(btn, index - #self.contentList)

		return
	end

	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	if tIndex == self.Template.favorLevel then
		store.relationState = data.favorLevel
	end

	if tIndex == self.Template.favorList then
		store.list.onGetTIndex = self.OnGetFavorListTIndex
		store.list.luaSimpleRenderItem = self.OnRenderFavorList
		store.list.luaSimpleClick = self.OnClickFavorList

		store.list:SetSimpleList(#self.favorList)
	end
end
