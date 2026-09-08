-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieNew2MemberRightsPanel.lua
-- Decompiled from: 01254_YanjieNew2MemberRightsPanel.lua_b5bd83d538af.luajit

C_YanjieNew2MemberRightsPanel = DefClass("C_YanjieNew2MemberRightsPanel", C_YanjieNew2MemberRightsPanel, C_StoreGroup)
GroupName2Class.YanjieNew2MemberRightsPanel = C_YanjieNew2MemberRightsPanel
local M = C_YanjieNew2MemberRightsPanel

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.InitView(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnClickExitButton)
end

M.OnClickExitButton = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderListItem = function(self, btn, index)
end

M.OnSimpleClickList = function(self, btn, index)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

M.InitModel = function(self)
	self.tabDataList = self.GetTabDataList(self)
	self.currentTab = 0
end

M.GetTabDataList = function(self)
	local viewDataList = {}
	local currentLv = gPlayerManager.infoMinor.bindData.level

	for i = 1, currentLv do
		local id = gClientUtils.GetGrowthIdByLv(i)
		local growthCfg = LTConfig.GrowthConfig.GetConfig(id)

		for _, benefitId in ipairs(growthCfg.BenefitId) do
			if gSocialNetworkUtils.CheckGrowthConfigValid(currentLv, id, benefitId) then
				table.insert(viewDataList, benefitId)
			end
		end
	end

	local benefitTypeMap = {}

	for _, benefitId in ipairs(viewDataList) do
		local benefitCfg = LTConfig.GrowthBenefitConfig.GetConfig(benefitId)
		local benefitIdList = benefitTypeMap[benefitCfg.Type] or {}

		table.insert(benefitIdList, benefitId)

		benefitTypeMap[benefitCfg.Type] = benefitIdList
	end

	local targetViewDataList = {}
	local allBenefitIdList = {}

	for typeId, benefitIdList in pairs(benefitTypeMap) do
		table.sort(benefitIdList, gSocialNetworkUtils.SortBenefitFunction)
		array.concat(allBenefitIdList, benefitIdList)
		table.insert(targetViewDataList, {
			typeId = typeId,
			benefitIdList = benefitIdList
		})
	end

	table.sort(targetViewDataList, function (data1, data2)
		return data1.typeId <= data2.typeId
	end)
	table.sort(allBenefitIdList, gSocialNetworkUtils.SortBenefitFunction)
	table.insert(targetViewDataList, 1, {
		["Q\\x81\\x8b\\xaaE"] = -1,
		benefitIdList = allBenefitIdList
	})

	return targetViewDataList
end

M.InitView = function(self)
	self.InitTabListView(self)
end

M.InitTabListView = function(self)
	self.SubGroup.CommonTabSingleStore:SetData(self.tabDataList, nil, self.currentTab, nil, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))
end

M.OnChangeTab = function(self)
	local selectedIndex = self.SubGroup.CommonTabSingleStore:GetSelectedIndex()
	local tabData = self.tabDataList[selectedIndex + 1]
	local benefitIdList = tabData.benefitIdList

	self.bindData.list.luaSimpleRenderItem = function(btn, index)
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		local benefitId = benefitIdList[index + 1]

		gSocialNetworkUtils.RenderBenefitItemView(btn, benefitId)

		store.typeCtrl = 1
	end

	self.bindData.list:SetSimpleList(#benefitIdList)
end

M.OnRenderTabItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.tabDataList[index + 1]
	local typeId = data.typeId
	local title = nil

	if typeId ~= -1 then
		title = LTConfig.TextScriptTextConfig.GetConfig(89900400).Text
	else
		title = LTConfig.GrowthConfig.BenefitTypeName[typeId]
	end

	store.title = title
end
