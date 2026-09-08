-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubblePortfolioPanelStore.lua
-- Decompiled from: 02005_BubblePortfolioPanelStore.lua_c6a88c745064.luajit

local EInvokeTime = SGUI.EInvokeTime
local UNavigationMgr = SGUI.UNavigationMgr
local SocialMediaTabConfig = LTConfig.SocialMediaTabConfig
C_BubblePortfolioPanelStore = DefClass("C_BubblePortfolioPanelStore", C_BubblePortfolioPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubblePortfolioPanelStore = C_BubblePortfolioPanelStore
local M = C_BubblePortfolioPanelStore
local BOOL2CTL = gClientConst.BOOL2CTL

M.OnAwake = function(self)
	self.mgr = gNewBubbleMgr
	self.bindData.birthBtn.luaClick = self.CreateAction(self, self.OnBirthBtnClick)
	self.bindData.nameBtn.luaClick = self.CreateAction(self, self.OnNameBtnClick)
	self.bindData.editBtn.luaClick = self.CreateAction(self, self.OnEditBtnClick)
	self.bindData.photoBtn.luaClick = self.CreateAction(self, self.OnPhotoBtnClick)
	self.bindData.signBtn.luaClick = self.CreateAction(self, self.OnSignBtnClick)
	self.bindData.dropList.luaSimpleClick = self.CreateAction(self, self.OnDropClick)
	self.bindData.friendList.luaSimpleRenderItem = self.CreateAction(self, self.OnFriendListRenderItem)
	self.bindData.friendList.onGetTIndex = self.CreateAction(self, self.OnGetFavorTIndex)
	self.bindData.friendList.luaSimpleClick = self.CreateAction(self, self.OnFriendListItemClick)
	self.bindData.dropBackGround.luaClick = self.CreateAction(self, self.OnPhotoBtnClick)
	self.bindData.homepageBtn.luaClick = self.CreateAction(self, self.OnPersonalSpaceBtnClick)
end

M.InitView = function(self, data)
	if data.isFromMainPhone then
		self.bindData.isShowEnd = 1

		self.bindData.bindWidget:InvokeCallback(EInvokeTime.User1)
	else
		self.bindData.isShowEnd = 0
	end

	self.callback = data and data.callback
	self.bindData.ismale = BOOL2CTL[gPlayerManager.infoLogin.bindData.sexType ~= UX.Game.SexType.Male]
	self.bindData.showEdit = self:CheckIsMe() and 0 or 1

	self:OnPhotoBtnClick()
	self:RefreshPage()
end

M.OnClose = function(self)
	if self.callback then
		self.callback()
	end
end

M.CheckIsMe = function(self)
	return gHunLunManager.isSelf
end

M.OnBackBtnClick = function(self)
	self.mgr:FullExit()
end

M.OnPersonalSpaceBtnClick = function(self)
	if self.CheckIsMe(self) ~= false then
		return
	end

	self.mgr:SwitchCurrentPanel({
		secondShowType = SocialMediaTabConfig.My_post
	})
end

M.OnBirthBtnClick = function(self)
	if self.CheckIsMe(self) ~= false then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_BUBBLE_TIPS_EDIT_PANEL)
end

M.OnNameBtnClick = function(self)
	if self.CheckIsMe(self) ~= false then
		return
	end

	gHunLunManager:TryStartRename()
end

M.OnSignBtnClick = function(self)
	if self.CheckIsMe(self) ~= false then
		return
	end

	gHunLunManager:ShowChangeSign()
end

M.OnEditBtnClick = function(self)
	if self.CheckIsMe(self) ~= false then
		return
	end

	self.bindData.showDrop = self.bindData.showDrop ~= 0 and 1 or 0

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.showDrop ~= 1 and self.bindData.rootNavigationArea or self.bindData.dropNavigationArea
	end
end

M.OnPhotoBtnClick = function(self)
	self.bindData.showDrop = 1
end

M.OnFriendListRenderItem = function(self, btn, index)
	local data = gHunLunManager.roleInfo.fightSpirit[index + 1]
	local agentType = gNpcFavorManager:GetAgentTypeByNpcId(data.npcId)

	self.mgr:OnRenderBubbleCover(btn, index, agentType)
end

M.OnGetFavorTIndex = function(self, index)
	local data = gHunLunManager.roleInfo.fightSpirit[index + 1]
	local agentType = data and data.npcId or 0

	return agentType ~= 0 and 1 or 0
end

M.OnFriendListItemClick = function(self, btn, index)
	local data = gHunLunManager.roleInfo.fightSpirit[index + 1]
	local agentType = gNpcFavorManager:GetAgentTypeByNpcId(data.npcId)

	self.mgr:OnClickNpcBubbleHead(agentType)
end

M.OnDropClick = function(self, btn, index)
	local data = self.actionMap[index + 1]

	if data.action then
		local action = self.CreateAction(self, data.action)

		if action then
			action()
		end

		self.OnPhotoBtnClick(self)
	end
end

M.RefreshPage = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.RefreshDrop(self)

	local roleInfo = gHunLunManager.roleInfo

	if table.isNilOrEmpty(roleInfo) then
		return
	end

	self.bindData.nameLabel = roleInfo.userName
	self.bindData.birthLabel = roleInfo.birthday
	self.bindData.signLabel = roleInfo.sign ~= "" and LTConfig.TextScriptTextConfig.GetConfig(89901081).Text or roleInfo.sign

	self.bindData.friendList:GoToIndex(0, false)
	self.bindData.friendList:DeselectAll()
	self.bindData.friendList:SetSimpleList(#roleInfo.fightSpirit)
end

M.RefreshDrop = function(self)
	self.actionMap = {}

	table.insert(self.actionMap, {
		["K\\x85\\x87\\x8cO"] = "Ȕ?\\xed\\xc4\\xe4\\xab\\xe1\\x8b##",
		label = LTConfig.TextScriptTextConfig.GetConfig(89901053).Text
	})
	table.insert(self.actionMap, {
		["K\\x85\\x87\\x8cO"] = "Ȕ\"\\xe5\\xc4\\xe4\\xab\\xe1\\x8b##",
		label = LTConfig.TextScriptTextConfig.GetConfig(89901055).Text
	})

	if gHunLunManager.roleInfo and gHunLunManager.roleInfo.changeBirthAble then
		table.insert(self.actionMap, {
			["K\\x85\\x87\\x8cO"] = "$\\xeda\\x8c\\xff\\xbc!\\xc5\\xfe\\xefw\\xf0",
			label = LTConfig.TextScriptTextConfig.GetConfig(89901058).Text
		})
	end

	self.bindData.dropList:InitSimpleList()

	for i = 1, #self.actionMap do
		self.bindData.dropList:AddSimpleLabel(0, self.actionMap[i].label)
	end

	self.bindData.dropList:RefreshList()
end
