-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieBrandGetPanelStore.lua
-- Decompiled from: 01249_YanjieBrandGetPanelStore.lua_b324146f59fa.luajit

C_YanjieBrandGetPanelStore = DefClass("C_YanjieBrandGetPanelStore", C_YanjieBrandGetPanelStore, C_StoreGroup)
GroupName2Class.YanjieBrandGetPanelStore = C_YanjieBrandGetPanelStore
local M = C_YanjieBrandGetPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.isGetCtrlEnum = {
		["\\xaf\\xb4\\xaa2\\xeac"] = 0,
		["\\xaf\\xb4\\xaa2\\xeab"] = 1
	}
	self.showBackBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isGetCtrlEnum = nil
	self.showBackBtnCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.isResultMode = args.showGetResult ~= true
	self.stageId = args.stageId
	self.optionId = args.optionId

	if self.isResultMode then
		self.ownerOptionIdList = self.GetOwnerOptionIdList(self)
	else
		self.ownerOptionIdList = {
			self.optionId
		}
	end

	local _, index = table.find(self.ownerOptionIdList, self.optionId)
	self.currentOptionIndex = index or 1
end

M.GetOwnerOptionIdList = function(self)
	local receivedStageLvRewards = gPlayerManager.infoMinor.bindData.receivedStageLvRewards
	local stageIdList = {}

	for stageId, _ in pairs(receivedStageLvRewards) do
		table.insert(stageIdList, stageId)
	end

	table.sort(stageIdList)

	local optionIdList = {}

	for _, stageId in ipairs(stageIdList) do
		table.insert(optionIdList, receivedStageLvRewards[stageId])
	end

	return optionIdList
end

M.GetCurrentOptionId = function(self)
	return self.ownerOptionIdList[self.currentOptionIndex]
end

M.InitView = function(self, args)
	self.RefreshPanelView(self)

	if self.isResultMode then
		self.bindData.showBackBtnCtrl = 1
		self.bindData.isGetCtrl = #self.ownerOptionIdList <= 1 and 1 or 0

		self.bindData.confirmButton:SetActive(false)
	else
		self.bindData.showBackBtnCtrl = 0
		self.bindData.isGetCtrl = 0

		self.bindData.confirmButton:SetActive(true)
	end

	gPanelManager:Close(gPanelId.YANJIE_BRAND_SELECT_PANEL)
end

M.RefreshPanelView = function(self)
	local currentOptionId = self:GetCurrentOptionId()
	local endorsementOptionCfg = LTConfig.GrowthEndorsementOptionConfig.GetConfig(currentOptionId)
	self.bindData.title = endorsementOptionCfg.StateDescSigned
	self.bindData.iconId = endorsementOptionCfg.EndShow
	self.bindData.rewardText = endorsementOptionCfg.RewardDesc
	self.bindData.pageIndex.text = ("%d/%d"):format(self.currentOptionIndex, #self.ownerOptionIdList)
	self.rewardDataList = self:GetRewardDataList(currentOptionId)

	self.bindData.list:SetSimpleList(#self.rewardDataList)
end

M.GetRewardDataList = function(self, currentOptionId)
	local viewDataList = {}
	local endorsementOptionCfg = LTConfig.GrowthEndorsementOptionConfig.GetConfig(currentOptionId)
	local dropId = endorsementOptionCfg.DropId
	local dropViewDataList = gCommonItemManager:GetSingleSortedListRenderData(dropId) or {}

	for _, dropViewData in ipairs(dropViewDataList) do
		dropViewData.tIndex = 0
	end

	array.concat(viewDataList, dropViewDataList)

	local benefitIdList = endorsementOptionCfg.BenefitIds

	for _, benefitId in ipairs(benefitIdList) do
		table.insert(viewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 1,
			benefitId = benefitId
		})
	end

	return viewDataList
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnClickExitButton)
	self.bindData.confirmButton.luaClick = self.CreateAction(self, self.OnClickConfirmButton)
	self.bindData.leftButton.luaClick = self.CreateAction(self, self.OnLeftClick)
	self.bindData.rightButton.luaClick = self.CreateAction(self, self.OnRightClick)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.bindData.list.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
end

M.OnClickExitButton = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickConfirmButton = function(self)
	gPanelManager:Close(self.m_Id)
end

M.SwitchOption = function(self, step)
	local count = #self.ownerOptionIdList

	if count < 1 then
		return
	end

	self.currentOptionIndex = (self.currentOptionIndex - 1 + step) % count + 1

	self.RefreshPanelView(self)
end

M.OnLeftClick = function(self)
	self.SwitchOption(self, -1)
end

M.OnRightClick = function(self)
	self.SwitchOption(self, 1)
end

M.OnRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.rewardDataList[index + 1]

	if data.tIndex ~= 0 then
		gCommonItemManager:OnCommonItemRender(btn, nil, data)
	elseif data.tIndex ~= 1 then
		local benefitId = data.benefitId
		local benefitCfg = LTConfig.GrowthBenefitConfig.GetConfig(benefitId)
		store.iconId = benefitCfg.Icon
		store.name = benefitCfg.Name
		store.typeCtrl = 1
		store.level = gSocialNetworkUtils.GetBenefitLevel(benefitId)
		btn.luaRenderTooltip = self.CreateActionWithArgs(self, "OnBenefitToolTips", benefitId)
	end
end

M.OnBenefitToolTips = function(self, benefitId, btn, popup, popupIndex)
	gSocialNetworkUtils.RenderBenefitItemView(popup, benefitId)

	local store = gStoreManager:GetStoreGroup(popup.Store):GetStoreByWidget(popup)
	store.typeCtrl = 0
end

M.OnGetTIndex = function(self, index)
	local data = self.rewardDataList[index + 1]

	return data.tIndex
end
