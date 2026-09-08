-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonGameplayStartPanelStore.lua
-- Decompiled from: 01526_CommonGameplayStartPanelStore.lua_0049f2ac162b.luajit

local BeginConfig = LTConfig.GameplayHudDescBeginConfig
local OptionConfig = LTConfig.GameplayHudDescBeginOptionConfig
C_CommonGameplayStartPanelStore = DefClass("C_CommonGameplayStartPanelStore", C_CommonGameplayStartPanelStore, C_StoreGroup)
GroupName2Class.CommonGameplayStartPanelStore = C_CommonGameplayStartPanelStore
local M = C_CommonGameplayStartPanelStore

M.ctor = function(self)
	self.playId = 0
	self.mgr = gGamePlayBeginMgr
	self.DESC_TEMPLATE = {
		["3x\\xa5\\xa7\\xaco"] = 1,
		[".m\\xa6\\xaf\\xb1e"] = 2,
		["\\xbd\\T"] = 0
	}
	self.DATA2TEMPLATE = {
		desc = self.DESC_TEMPLATE.STR,
		option = self.DESC_TEMPLATE.OPTION,
		reward = self.DESC_TEMPLATE.REWARD
	}
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.closePanel.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnStartBtnClick)
	self.bindData.descList.onGetTIndex = self.CreateAction(self, self.OnGetDescIndex)
	self.bindData.descList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderDescListItem)
	self.bindData.descList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleDynRenderDescListItem)
	self.OnRenderItemCb = self.CreateAction(self, self.OnRenderItem)
	self.options = {}
	self.optionIds = {}
	self.rewardList = {}
	self.tabOptionIndex = nil
end

M.OnGroupEnable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", true)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", true)
end

M.OnGroupDisable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", false)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", false)
end

M.OnShow = function(self, panelId, data)
	L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gPanelId.COMMON_GAMEPLAY_START_PANEL, true)

	self.playId = data and data.playId or 0
	self.cfg = BeginConfig.GetConfig(self.playId)
	self.customOptions = data and data.options
	self.refreshRewardCb = data and data.refreshRewardCb
	self.customData = data and data.customData
	self.cancelCb = data and data.cancelCb

	if not self.cfg then
		self.OnClickBackBtn(self)

		return
	end

	self.RefreshPage(self)
	self.RefreshRewardDisplay(self)
end

M.OnClose = function(self)
	L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gPanelId.COMMON_GAMEPLAY_START_PANEL, false)
end

M.OnClickBackBtn = function(self)
	local cancelCb = self.cancelCb
	self.cancelCb = nil

	if cancelCb then
		cancelCb()
	end

	gUIUtils:PlayAniClosePanel(self.bindData.closeAnimation, "S_vx_CommonGameplayStartPanel_out", self.m_Id)
end

M.OnStartBtnClick = function(self)
	self.cancelCb = nil

	self.mgr:OnBegin(self.playId, self.optionIds, self.customData)
end

M.OnRenderItem = function(self, btn, index)
	local data = self.rewardList[index + 1]

	if not data then
		return
	end

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

M.OnOptionSelectedChanged = function(self, optionData, selector)
	local selectedIndex = selector.selectedIndex
	local optionId = optionData.id
	local optionItems = optionData.options
	self.options[optionId] = selectedIndex
	self.optionIds[optionId] = optionItems[selectedIndex + 1] and optionItems[selectedIndex + 1].id or 0

	selector:ClosePopUp()
	self:RefreshDesc()
	self:RefreshReward()
	self:RefreshRewardDisplay()
end

M.OnSimpleDynRenderDescListItem = function(self, btn, index)
	local data = self.contentList[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= self.DESC_TEMPLATE.STR then
		btn.title.text = data.desc
	end
end

M.OnSimpleRenderDescListItem = function(self, btn, index)
	local data = self.contentList[index + 1]

	if not data then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if data.tIndex ~= self.DESC_TEMPLATE.STR then
		self.bindData.descList:SetItemLabel(index, data.desc)
	elseif data.tIndex ~= self.DESC_TEMPLATE.OPTION then
		self.bindData.descList:SetItemLabel(index, data.desc)

		local optionData = data.option
		store.sorter.luaSelectedChanged = nil

		store.sorter:SetSimpleOptions(0)

		for i = 1, #optionData.options do
			store.sorter:AddSimpleOptionLabel(0, optionData.options[i].label, i ~= 1)
		end

		store.sorter.selectedIndex = self.options[optionData.id] or 0

		store.sorter:RefreshOptions()

		store.sorter.luaSelectedChanged = self:CreateActionWithArgs(self.OnOptionSelectedChanged, optionData)
	elseif data.tIndex ~= self.DESC_TEMPLATE.REWARD then
		store.rewardList.luaSimpleRenderItem = self.OnRenderItemCb
		self.currentRewardList = store.rewardList
		self.currentRewardBtn = btn

		self.RefreshRewardDisplay(self)
	end
end

M.OnGetDescIndex = function(self, index)
	local data = self.contentList[index + 1]

	if not data then
		return 0
	end

	return data.tIndex
end

M.RefreshPage = function(self)
	self.bindData.subTitle = self.cfg.SubTitle
	self.bindData.title = self.cfg.Title
	self.bindData.enterText = self.cfg.EnterStr
	self.bindData.backgroundIcon = self.cfg.BackGround
	local optionsList = table.clone(self.customOptions or self.cfg.Options)
	self.tabOptionIndex = nil

	for i = 1, #optionsList do
		local option = optionsList[i]
		local ele = {}

		if type(option) ~= "number" then
			local cfg = OptionConfig.GetConfig(option)
			ele = {
				id = option,
				title = cfg.Title,
				options = {},
				showInTab = cfg.ShowInTab
			}

			for j = 1, #cfg.Options do
				local worldLifeConfig = LTConfig.WorldLifeConfig.GetConfig(cfg.WorldLifeId[j])
				local info = {
					label = cfg.Options[j],
					drop = worldLifeConfig and worldLifeConfig.Drop or 0,
					id = j - 1,
					descOverwrite = cfg.DescOverwrite and cfg.DescOverwrite[j - 1] or ""
				}
				ele.options[j] = info
			end
		else
			ele = option
		end

		optionsList[i] = ele

		if ele.showInTab and not self.tabOptionIndex then
			self.tabOptionIndex = i
		end
	end

	for i = 1, #optionsList do
		self.options[optionsList[i].id] = 0
		self.optionIds[optionsList[i].id] = optionsList[i].options[1] and optionsList[i].options[1].id or 0
	end

	self.optionsList = optionsList
	self.defaultDesc = self.cfg.Desc

	self.RefreshReward(self)
	self.RefreshTab(self)
	self.RefreshDesc(self)
end

M.RefreshReward = function(self)
	if self.refreshRewardCb then
		self.rewardList = self.refreshRewardCb(self.optionsList, self.options) or {}

		return
	end

	self.RefreshRewardDefault(self)
end

M.RefreshDesc = function(self)
	local desc = self.defaultDesc

	for i = 1, #self.optionsList do
		local option = self.optionsList[i]
		local selectedIndex = self.options[option.id]

		if selectedIndex then
			local selectedItem = option.options[selectedIndex + 1]

			if selectedItem and not string.is_null_or_empty(selectedItem.descOverwrite) then
				desc = selectedItem.descOverwrite
			end
		end
	end

	self.contentList = {
		{
			desc = desc,
			tIndex = self.DESC_TEMPLATE.STR
		}
	}
	local descIndex = 2

	for i = 1, #self.optionsList do
		if i == self.tabOptionIndex then
			self.contentList[descIndex] = {
				option = self.optionsList[i],
				tIndex = self.DESC_TEMPLATE.OPTION,
				desc = self.optionsList[i].title
			}
			descIndex = descIndex + 1
		end
	end

	self.contentList[descIndex] = {
		tIndex = self.DESC_TEMPLATE.REWARD
	}

	self.bindData.descList:SetSimpleList(#self.contentList)
end

M.RefreshRewardDefault = function(self)
	local rewardList = self.mgr:GetRewardListByOptions(self.optionsList, self.options)
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

M.RefreshRewardDisplay = function(self)
	if not self.currentRewardList or not self.currentRewardBtn then
		return
	end

	if gCS.LuaUtils.IsNull(self.currentRewardList) or gCS.LuaUtils.IsNull(self.currentRewardBtn) then
		return
	end

	self.currentRewardList:SetSimpleList(#self.rewardList)
	self.currentRewardBtn:SetActiveQuickly(#self.rewardList >= 0)
end

M.RefreshTab = function(self)
	local tabStore = self.SubGroup.CommonTabSingleStore

	if not self.tabOptionIndex then
		tabStore.SetSimpleData(tabStore, 0, nil, 0, nil)

		return
	end

	local tabOption = self.optionsList[self.tabOptionIndex]
	local tabList = {}

	for i = 1, #tabOption.options do
		tabList[i] = {
			id = tabOption.options[i].id,
			title = tabOption.options[i].label
		}
	end

	tabStore.SetData(tabStore, tabList, nil, 0, nil, self.CreateAction(self, self.OnGameplayTabChanged))
end

M.OnGameplayTabChanged = function(self, uList)
	if not self.tabOptionIndex then
		return
	end

	local tabIndex = uList.selectedIndex
	local tabOption = self.optionsList[self.tabOptionIndex]
	self.options[tabOption.id] = tabIndex
	self.optionIds[tabOption.id] = tabOption.options[tabIndex + 1] and tabOption.options[tabIndex + 1].id or 0

	self:RefreshDesc()
	self:RefreshReward()
	self:RefreshRewardDisplay()
end
