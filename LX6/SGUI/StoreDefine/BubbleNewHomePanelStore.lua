-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubbleNewHomePanelStore.lua
-- Decompiled from: 02006_BubbleNewHomePanelStore.lua_ee5de33edf62.luajit

local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_BubbleNewHomePanelStore = DefClass("C_BubbleNewHomePanelStore", C_BubbleNewHomePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleNewHomePanelStore = C_BubbleNewHomePanelStore
local M = C_BubbleNewHomePanelStore

M.ctor = function(self)
	self.Template = {
		["UHǸ\\x8a\\x94\r\\xda\\xfc"] = 3,
		["U[ز\\x96$\\xbd\\xcc\\xe4"] = 0,
		["EFzf\\2,"] = 1,
		["\\x99&):v\\x99m\\xd85\\xaf\\xb5"] = 2
	}
end

M.OnAwake = function(self)
	self.mgr = self.mgr or gNewBubbleMgr

	self:RegisterWidget()

	self.contentList = {}
end

M.RegisterWidget = function(self)
	self.bindData.actionpoint.luaClick = self.CreateAction(self, "OnClickActionpoint", gNpcFavorManager)
	self.OnRenderFavorList = self.CreateAction(self, self.OnSimpleRenderFavorListItem)
	self.OnClickFavorList = self.CreateAction(self, self.OnSimpleClickFavorList)
	self.OnGetFavorListTIndex = self.CreateAction(self, self.OnGetFavorTIndex)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderContentListItem)
	self.bindData.contentList.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
	self.bindData.contentList.luaLayoutSet = self.CreateAction(self, self.OnSetListLayout)
end

M.InitView = function(self)
	self.refreshNav = true
end

M.RefreshPage = function(self)
	local favorLevel = nil
	local isEmpty = true
	self.contentList = {}
	self.favorList, favorLevel = self.mgr:GetRoleFavorList()
	isEmpty = #self.favorList ~= 0

	if not isEmpty then
		table.insert(self.contentList, {
			favorLevel = favorLevel
		})
		table.insert(self.contentList, {
			["EFzf\\2,"] = true
		})
	end

	self.friendList = self.mgr:GetCurrentFavorNpcList()
	isEmpty = isEmpty and #self.friendList ~= 0
	local friendLabel = gString.Format(TextScriptTextConfig.GetConfig(89901287).Text, #self.friendList)

	table.insert(self.contentList, {
		friendLabel = friendLabel
	})

	self.bindData.isEmpty = self.mgr.BOOL2CTL[isEmpty]

	self.bindData.contentList:SetSimpleList(#self.contentList + #self.friendList)

	if #self.contentList > 3 then
		self.bindData.contentList:SetItemLabel(2, friendLabel)
	end

	self.refreshNav = true

	gNpcFavorManager:OnRenderActionPoint(self.bindData.actionpoint, 0, nil)
end

M.OnSimpleRenderFavorListItem = function(self, btn, index)
	local data = self.favorList[index + 1]
	local agentType = data and data.npcId or 0

	self.mgr:OnRenderBubbleCover(btn, index, agentType)
end

M.OnGetFavorTIndex = function(self, index)
	local data = self.favorList[index + 1]
	local agentType = data and data.npcId or 0

	return agentType ~= 0 and 1 or 0
end

M.OnSimpleClickFavorList = function(self, btn, index)
	local agentType = self.favorList[index + 1].npcId

	if agentType ~= 0 then
		return
	end

	self.mgr:OnClickNpcBubbleHead(agentType)

	self.refreshNav = true
end

M.OnSimpleRenderFriendListItem = function(self, btn, index)
	local data = self.friendList[index + 1]

	self.mgr:OnRenderBubbleFriendTempalate(btn, index, data)
end

M.OnSetListLayout = function(self)
	if not self.refreshNav then
		return
	end

	self.refreshNav = false

	self.bindData.contentList:SetNavSelectToTop(true)
	self.bindData.contentList:GoToIndex(0, true)
end

M.OnGetTIndex = function(self, index)
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

M.OnSimpleRenderContentListItem = function(self, btn, index)
	local tIndex = self.OnGetTIndex(self, index)
	local data = self.contentList[index + 1]

	if not data then
		self.OnSimpleRenderFriendListItem(self, btn, index - #self.contentList)

		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	if tIndex ~= self.Template.favorLevel then
		store.relationState = data.favorLevel
	end

	if tIndex ~= self.Template.favorList then
		store.list.onGetTIndex = self.OnGetFavorListTIndex
		store.list.luaSimpleRenderItem = self.OnRenderFavorList
		store.list.luaSimpleClick = self.OnClickFavorList

		store.list:SetSimpleList(#self.favorList)
	end
end
