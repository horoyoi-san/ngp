local BeginConfig = LTConfig.GameplayHudDescBeginConfig
local OptionConfig = LTConfig.GameplayHudDescBeginOptionConfig
C_CommonGameplayStartPanelStore = DefClass("C_CommonGameplayStartPanelStore", C_CommonGameplayStartPanelStore, C_StoreGroup)
GroupName2Class.CommonGameplayStartPanelStore = C_CommonGameplayStartPanelStore
local M = C_CommonGameplayStartPanelStore

function M:ctor()
	self.playId = 0
	self.mgr = gGamePlayBeginMgr
	self.DESC_TEMPLATE = {
		OPTION = 1,
		REWARD = 2,
		STR = 0
	}
	self.DATA2TEMPLATE = {
		desc = self.DESC_TEMPLATE.STR,
		option = self.DESC_TEMPLATE.OPTION,
		reward = self.DESC_TEMPLATE.REWARD
	}
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnClickBackBtn)
	self.bindData.closePanel.luaClick = self:CreateAction(self.OnClickBackBtn)
	self.bindData.startBtn.luaClick = self:CreateAction(self.OnStartBtnClick)
	self.bindData.descList.onGetTIndex = self:CreateAction(self.OnGetDescIndex)
	self.bindData.descList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderDescListItem)
	self.OnRenderItemCb = self:CreateAction(self.OnRenderItem)
	self.options = {}
	self.rewardList = {}
end

function M:OnGroupEnable()
	gMainPhoneUtils.SetSGUIGlobalBarVisible(false)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_SHOW)
end

function M:OnGroupDisable()
	gMainPhoneUtils.SetSGUIGlobalBarVisible(true)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_HIDE)
end

function M:OnShow(panelId, data)
	self.playId = data and data.playId or 0
	self.cfg = BeginConfig.GetConfig(self.playId)

	if not self.cfg then
		self:OnClickBackBtn()

		return
	end

	self:RefreshPage()
end

function M:OnClose()
	return
end

function M:OnClickBackBtn()
	gUIUtils:PlayAniClosePanel(self.bindData.closeAnimation, "S_vx_CommonGameplayStartPanel_out", self.m_Id)
end

function M:OnStartBtnClick()
	self.mgr:OnBegin(self.playId, self.options)
end

function M:OnRenderItem(btn, index)
	local data = self.rewardList[index + 1]

	if not data then
		return
	end

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

function M:OnOptionSelectedChanged(optionId, selector)
	self.options[optionId] = selector.selectedIndex

	selector:ClosePopUp()
	self:RefreshReward()
	self:RefreshRewardDisplay()
end

function M:OnSimpleRenderDescListItem(btn, index)
	local data = self.contentList[index + 1]

	if not data then
		return
	end

	local store = self:GetStoreByWidget(btn)

	if data.tIndex == self.DESC_TEMPLATE.OPTION then
		local cfg = OptionConfig.GetConfig(data.option)
		local itemList = {}

		for i = 1, #cfg.Options do
			local item = {
				label = cfg.Options[i]
			}
			itemList[i] = item
		end

		store.sorter:SetOptions(itemList)
		store.sorter:SelectOption(self.options[data.option])

		store.sorter.luaSelectedChanged = self:CreateActionWithArgs(self.OnOptionSelectedChanged, data.option)
	elseif data.tIndex == self.DESC_TEMPLATE.REWARD then
		store.rewardList.luaSimpleRenderItem = self.OnRenderItemCb
		self.currentRewardList = store.rewardList
		self.currentRewardBtn = btn

		self:RefreshRewardDisplay()
	end
end

function M:OnGetDescIndex(index)
	local data = self.contentList[index + 1]

	if not data then
		return 0
	end

	return data.tIndex
end

function M:RefreshPage()
	self.bindData.subTitle = self.cfg.SubTitle
	self.bindData.title = self.cfg.Title
	self.bindData.enterText = self.cfg.EnterStr
	self.bindData.backgroundIcon = self.cfg.BackGround
	self.contentList = {
		{
			desc = self.cfg.Desc,
			tIndex = self.DESC_TEMPLATE.STR
		}
	}

	for i = 1, #self.cfg.Options do
		self.contentList[i + 1] = {
			option = self.cfg.Options[i],
			tIndex = self.DESC_TEMPLATE.OPTION
		}
		self.options[self.cfg.Options[i]] = 0
	end

	self:RefreshReward()

	self.contentList[2 + #self.cfg.Options] = {
		tIndex = self.DESC_TEMPLATE.REWARD
	}

	self.bindData.descList:SetSimpleList(#self.contentList)
	self.bindData.descList:SetItemLabel(0, self.cfg.Desc)

	for i = 1, #self.cfg.Options do
		local cfg = OptionConfig.GetConfig(self.cfg.Options[i])

		self.bindData.descList:SetItemLabel(i, cfg.Title)
	end
end

function M:RefreshReward()
	local rewardList = self.mgr:GetRewardListByOptions(self.playId, self.options)
	local itemList = gCommonItemManager:GetItemSortedListByDropList(rewardList, true)

	for i = 1, #itemList do
		local item = itemList[i]
		local showData = gCommonItemManager:GetItemRenderData({
			itemId = item.Id,
			itemNum = item.Count
		})
		itemList[i] = showData
	end

	self.rewardList = itemList
end

function M:RefreshRewardDisplay()
	if not self.currentRewardList or not self.currentRewardBtn then
		return
	end

	self.currentRewardList:SetSimpleList(#self.rewardList)
	self.currentRewardBtn:SetActiveQuickly(#self.rewardList > 0)
end
