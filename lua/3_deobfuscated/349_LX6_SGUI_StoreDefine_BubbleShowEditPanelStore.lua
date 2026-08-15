local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local StaticProps = {
	SHOW_TYPE = {
		HEAD = 2,
		BADGE = 1,
		CARD = 0
	}
}
C_BubbleShowEditPanelStore = DefClass("C_BubbleShowEditPanelStore", C_BubbleShowEditPanelStore, C_StoreGroup, StaticProps)
GroupName2Class.BubbleShowEditPanelStore = C_BubbleShowEditPanelStore
local M = C_BubbleShowEditPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnContentListRenderItem")
	self.bindData.contentList.luaSimpleClick = self:CreateAction("OnContentListClick")
	self.bindData.contentList.onGetTIndex = self:CreateAction("OnContentGetTIndex")
	self.bindData.cardList.luaRenderItem = self:CreateAction(self.OnFriendListRenderItem)
	self.bindData.badgeList.luaRenderItem = self:CreateAction(self.OnRenderBadgeItem)
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnChangeBtnClick")
	self.mgr = self.mgr or gNewBubbleMgr
end

function M:OnShow(panelId, data)
	self.bindData.contentType = data.showType

	if self.bindData.contentType == M.SHOW_TYPE.HEAD then
		gHunLunManager:GetHeadIconInfo(self:CreateAction("OnGetHeadInfo"))
	elseif self.bindData.contentType == M.SHOW_TYPE.BADGE then
		self.areaId = data.areaId or 1

		gHunLunManager:GetPlayerAchievementList(self:CreateAction("OnGetAchievementList"))
	elseif self.bindData.contentType == M.SHOW_TYPE.CARD then
		self:OnGetLingList()
	end
end

function M:OnBackBtnClick()
	gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
	gPanelManager:Close(gPanelId.S_BUBBLE_SHOW_EDIT_PANEL)
end

function M:OnGetHeadInfo(iconData)
	if not self.STATE_EnableOnce then
		return
	end

	self.useAvatar = gPlayerManager.infoLogin.bindData.infoPzHeadInfo.SystemHeadId
	self.badgeList = gHunLunManager:GetHeadIconList(iconData.UnlockedSystemHeadList)
	self.bindData.contentList.groupType = 1

	self.bindData.contentList:SetSimpleList(#self.badgeList)
	self.bindData.contentList:SetItemSelected(0, true)

	self.bindData.headIcon, self.bindData.headName = gHunLunManager:GetHeadIconAndName(self.useAvatar)
	self.bindData.isEmpty = #self.badgeList == 0 and 1 or 0
end

function M:OnGetAchievementList(badgeData)
	self.badgeList = gHunLunManager:GetBadgeList(badgeData)
	self.useBadgeList = table.clone(gHunLunManager.roleInfo.reputation[self.areaId].badgeList)
	local badgeIndexDict = {}

	for i = 1, #self.useBadgeList do
		if self.useBadgeList[i].hide ~= true then
			badgeIndexDict[self.useBadgeList[i].id] = i
		end
	end

	for i = 1, #self.badgeList do
		if badgeIndexDict[self.badgeList[i].id] then
			self.badgeList[i].selected = true
			self.badgeList[i].selectedIndex = badgeIndexDict[self.badgeList[i].id]
		end
	end

	self.bindData.contentList.groupType = 2
	self.bindData.contentList.checkMax = 3

	self.bindData.contentList:SetSimpleList(#self.badgeList)

	for i = 1, #self.badgeList do
		if self.badgeList[i].selected then
			self.bindData.contentList:SetItemSelected(i - 1, true)
		end
	end

	self.bindData.isEmpty = #self.badgeList == 0 and 1 or 0
	self.useBadgeList = table.clone(gHunLunManager.roleInfo.reputation[self.areaId].badgeList)

	self:RefreshBadgeList()
end

function M:OnGetLingList()
	self.fightSpirit = table.clone(gHunLunManager.roleInfo.fightSpirit)
	self.badgeList = self.mgr:GetBestNpcs(self.fightSpirit)
	self.bindData.contentList.groupType = 2
	self.bindData.contentList.checkMax = self.mgr:GetMaxSHowFriendLength()

	self.bindData.contentList:SetSimpleList(#self.badgeList)

	for i = 1, #self.badgeList do
		if self.badgeList[i].selected then
			self.bindData.contentList:SetItemSelected(i - 1, true)
		end
	end

	self.bindData.isEmpty = #self.badgeList == 0 and 1 or 0

	self:RefreshCardList()
end

function M:OnChangeBtnClick()
	if not gHunLunManager.isSelf then
		return
	end

	if self.bindData.contentType == M.SHOW_TYPE.HEAD then
		gHunLunManager:SendChangeHeadIcon(self.useAvatar, self:CreateAction("OnBackBtnClick"))
	end

	if self.bindData.contentType == M.SHOW_TYPE.BADGE then
		gHunLunManager:SendChangeBadge(self.useBadgeList, self.areaId, self:CreateAction("OnBackBtnClick"))
	end

	if self.bindData.contentType == M.SHOW_TYPE.CARD then
		gHunLunManager:SendChangeSpirit(self.fightSpirit, self:CreateAction("OnBackBtnClick"))
	end
end

function M:RefreshBadgeList()
	self.minSelectIndex = 0

	for i = 1, #self.useBadgeList do
		if self.useBadgeList[i].hide then
			self.minSelectIndex = i

			break
		end
	end

	self.bindData.badgeList:SetList(self.useBadgeList)
end

function M:RefreshCardList()
	self.minSelectIndex = 0

	for i = 1, #self.fightSpirit do
		if self.fightSpirit[i].hide then
			self.minSelectIndex = i

			break
		end
	end

	self.bindData.cardList:SetList(self.fightSpirit)
end

function M:OnContentGetTIndex(index)
	local luaIndex = index + 1

	if luaIndex <= #self.badgeList then
		return self.badgeList[luaIndex].tIndex
	else
		return 0
	end
end

function M:OnFriendListRenderItem(btn, index)
	local data = self.fightSpirit[index + 1]

	self.mgr:OnFriendListRenderItem(btn, index, data)
end

function M:OnRenderBadgeItem(btn, index)
	local data = self.useBadgeList[index + 1]

	self.mgr:OnRenderBadgeItem(btn, index, data)
end

function M:OnContentListRenderItem(btn, index)
	local data = self.badgeList[index + 1]

	if data.tIndex == 2 then
		self.mgr:OnFriendListRenderItem(btn, index, data)

		return
	end

	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.icon or data.sIcon

	if data.selectedIndex then
		store.selectedIndex = data.selectedIndex
	end

	if data.tIndex == 1 then
		store.isUsing = data.isUsed and 0 or 1
	end
end

function M:OnContentListClick(btn, index)
	local data = self.badgeList[index + 1]
	data.selected = not data.selected

	if data.tIndex == 1 then
		self:OnHeadIconClick(btn, index, data)
	end

	if data.tIndex == 0 then
		self:OnBadgeClick(btn, index, data)
	end

	if data.tIndex == 2 then
		self:OnSpiritClick(btn, index, data)
	end
end

function M:OnHeadIconClick(btn, index, data)
	self.bindData.headIcon = data.icon
	self.bindData.headName = data.name
	self.useAvatar = data.id
end

function M:OnBadgeClick(btn, index, data)
	if data.selected == true then
		data.selectedIndex = self.minSelectIndex
		self.useBadgeList[data.selectedIndex] = {
			hide = false,
			icon = data.icon,
			id = data.id
		}
	else
		self.useBadgeList[data.selectedIndex] = {
			id = 0,
			icon = 0,
			hide = true
		}
	end

	self:RefreshBadgeList()
	self.bindData.contentList:RefreshList()
end

function M:OnSpiritClick(btn, index, data)
	if data.selected == true then
		data.selectedIndex = self.minSelectIndex
		local cfg = NpcCultivationConfig.GetConfig(data.id)
		self.fightSpirit[data.selectedIndex] = {
			hide = false,
			tIndex = 0,
			id = data.id,
			headIcon = cfg.SImageId,
			favorLevel = data.favorLevel,
			favorAmount = data.favorAmount,
			totTime = data.totTime,
			name = data.name
		}
	else
		self.fightSpirit[data.selectedIndex] = {
			hide = true,
			tIndex = 1
		}
	end

	self:RefreshCardList()
	self.bindData.contentList:RefreshList()
end
