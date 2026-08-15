C_YanjieMembershipRightsPanelStore = DefClass("C_YanjieMembershipRightsPanelStore", C_YanjieMembershipRightsPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieMembershipRightsPanelStore = C_YanjieMembershipRightsPanelStore
local M = C_YanjieMembershipRightsPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.LIST_TEMPLATE_TYPE = {
		CONTENT = 1,
		TITLE = 0
	}
end

function M:InitView(args)
	M.base.InitView(self, args)

	self.viewDataList = self:GetBenefitViewDataList()

	function self.bindData.list.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

function M:GetBenefitViewDataList()
	local viewDataList = {}
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if #growthCfg.Benefit > 0 then
			table.insert(viewDataList, {
				tIndex = self.LIST_TEMPLATE_TYPE.TITLE,
				id = growthCfg.Id
			})

			for index, _ in ipairs(growthCfg.Benefit) do
				table.insert(viewDataList, {
					tIndex = self.LIST_TEMPLATE_TYPE.CONTENT,
					id = growthCfg.Id,
					benefitIndex = index
				})
			end
		end
	end

	return viewDataList
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex == self.LIST_TEMPLATE_TYPE.TITLE then
		local growthCfg = LTConfig.GrowthConfig.GetConfig(data.id)
		local exp = gClientUtils.GetTargetLevelExp(growthCfg.Lv)
		store.title = LTConfig.TextScriptTextConfig.GetConfig(89901171).Text:format(exp)
	elseif data.tIndex == self.LIST_TEMPLATE_TYPE.CONTENT then
		local benefitIndex = data.benefitIndex
		local growthCfg = LTConfig.GrowthConfig.GetConfig(data.id)
		local benefit = growthCfg.Benefit[benefitIndex]
		store.title = benefit.benefitname
		store.description = benefit.benefitdescription
		store.iconId = growthCfg.BenefitIcon[benefitIndex] or 0
	end
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
