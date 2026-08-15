local RedDotMgr = SGUI.RedDotMgr
local EInvokeTime = SGUI.EInvokeTime
local UNavigationMgr = SGUI.UNavigationMgr
local SocialMediaTabConfig = LTConfig.SocialMediaTabConfig
C_BubblePortfolioPanelStore = DefClass("C_BubblePortfolioPanelStore", C_BubblePortfolioPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubblePortfolioPanelStore = C_BubblePortfolioPanelStore
local M = C_BubblePortfolioPanelStore
local BOOL2CTL = gClientConst.BOOL2CTL

function M:OnAwake()
	self.mgr = gNewBubbleMgr
	self.bindData.birthBtn.luaClick = self:CreateAction(self.OnBirthBtnClick)
	self.bindData.nameBtn.luaClick = self:CreateAction(self.OnNameBtnClick)
	self.bindData.editBtn.luaClick = self:CreateAction(self.OnEditBtnClick)
	self.bindData.photoBtn.luaClick = self:CreateAction(self.OnPhotoBtnClick)
	self.bindData.signBtn.luaClick = self:CreateAction(self.OnSignBtnClick)
	self.bindData.dropList.luaSimpleClick = self:CreateAction(self.OnDropClick)
	self.bindData.friendList.luaSimpleRenderItem = self:CreateAction(self.OnFriendListRenderItem)
	self.bindData.friendList.onGetTIndex = self:CreateAction(self.OnGetFavorTIndex)
	self.bindData.friendList.luaSimpleClick = self:CreateAction(self.OnFriendListItemClick)
	self.bindData.dropBackGround.luaClick = self:CreateAction(self.OnPhotoBtnClick)
	self.bindData.homepageBtn.luaClick = self:CreateAction(self.OnPersonalSpaceBtnClick)
	self.actionMap = {
		{
			action = "OnNameBtnClick",
			label = LTConfig.TextScriptTextConfig.GetConfig(89901053).Text
		},
		{
			action = "OnBirthBtnClick",
			label = LTConfig.TextScriptTextConfig.GetConfig(89901058).Text
		}
	}
end

function M:InitView(data)
	if data.isFromMainPhone then
		self.bindData.isShowEnd = 1

		self.bindData.bindWidget:InvokeCallback(EInvokeTime.User1)
	else
		self.bindData.isShowEnd = 0
	end

	self.callback = data and data.callback
	self.bindData.ismale = BOOL2CTL[gPlayerManager.infoLogin.bindData.sexType == UX.Game.SexType.Male]
	self.bindData.showEdit = self:CheckIsMe() and 0 or 1

	self:OnPhotoBtnClick()
	self:RefreshPage()
	self:RefreshDrop()
	self.bindData.signBtn:Navigate(self.bindData.signBtn)
end

function M:OnClose()
	if self.callback then
		self.callback()
	end
end

function M:CheckIsMe()
	return gHunLunManager.isSelf
end

function M:OnBackBtnClick()
	self.mgr:FullExit()
end

function M:OnPersonalSpaceBtnClick()
	if self:CheckIsMe() == false then
		return
	end

	self.mgr:SwitchCurrentPanel({
		secondShowType = SocialMediaTabConfig.My_post
	})
end

function M:OnBirthBtnClick()
	if self:CheckIsMe() == false then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_BUBBLE_TIPS_EDIT_PANEL)
end

function M:OnNameBtnClick()
	if self:CheckIsMe() == false then
		return
	end

	gHunLunManager:ShowChangeName()
end

function M:OnSignBtnClick()
	if self:CheckIsMe() == false then
		return
	end

	gHunLunManager:ShowChangeSign()
end

function M:OnEditBtnClick()
	if self:CheckIsMe() == false then
		return
	end

	self.bindData.showDrop = self.bindData.showDrop == 0 and 1 or 0

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.showDrop == 1 and self.bindData.rootNavigationArea or self.bindData.dropNavigationArea
	end
end

function M:OnPhotoBtnClick()
	self.bindData.showDrop = 1
end

function M:OnEditFriendBtnClick()
	if self:CheckIsMe() == false then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_BUBBLE_SHOW_EDIT_PANEL, {
		showType = C_BubbleShowEditPanelStore.SHOW_TYPE.CARD
	})
end

function M:OnFriendListRenderItem(btn, index)
	local data = gHunLunManager.roleInfo.fightSpirit[index + 1]
	local agentType = gNpcFavorManager:GetAgentTypeByNpcId(data.npcId)

	self.mgr:OnRenderBubbleCover(btn, index, agentType)
end

function M:OnGetFavorTIndex(index)
	local data = gHunLunManager.roleInfo.fightSpirit[index + 1]
	local agentType = data and data.npcId or 0

	return agentType == 0 and 1 or 0
end

function M:OnFriendListItemClick(btn, index)
	local data = gHunLunManager.roleInfo.fightSpirit[index + 1]
	local agentType = gNpcFavorManager:GetAgentTypeByNpcId(data.npcId)

	self.mgr:OnClickNpcBubbleHead(agentType)
end

function M:OnDropClick(btn, index)
	local data = self.actionMap[index + 1]

	if data.action then
		local action = self:CreateAction(data.action)

		if action then
			action()
		end

		self:OnPhotoBtnClick()
	end
end

function M:RefreshPage()
	if not self.STATE_EnableOnce then
		return
	end

	local roleInfo = gHunLunManager.roleInfo

	if table.isNilOrEmpty(roleInfo) then
		return
	end

	self.bindData.nameLabel = roleInfo.userName
	self.bindData.birthLabel = roleInfo.birthday
	self.bindData.signLabel = roleInfo.sign == "" and LTConfig.TextScriptTextConfig.GetConfig(89901081).Text or roleInfo.sign

	self.bindData.friendList:GoToIndex(0, false)
	self.bindData.friendList:DeselectAll()
	self.bindData.friendList:SetSimpleList(#roleInfo.fightSpirit)
end

function M:RefreshDrop()
	self.bindData.dropList:InitSimpleList()

	for i = 1, #self.actionMap do
		self.bindData.dropList:AddSimpleLabel(0, self.actionMap[i].label)
	end

	self.bindData.dropList:RefreshList()
end
