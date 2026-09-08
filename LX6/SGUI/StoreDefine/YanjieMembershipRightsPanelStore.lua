-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieMembershipRightsPanelStore.lua
-- Decompiled from: 02063_YanjieMembershipRightsPanelStore.lua_59bf84497d93.luajit

C_YanjieMembershipRightsPanelStore = DefClass("C_YanjieMembershipRightsPanelStore", C_YanjieMembershipRightsPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieMembershipRightsPanelStore = C_YanjieMembershipRightsPanelStore
local M = C_YanjieMembershipRightsPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.LIST_TEMPLATE_TYPE = {
		["\\xfa\\xf4:);\n\\xc5"] = 1,
		["y\\x87\\x96\\x83\\x93"] = 0
	}
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	self.viewDataList = self:GetBenefitViewDataList()

	self.bindData.list.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

M.GetBenefitViewDataList = function(self)
	local viewDataList = {}
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if #growthCfg.Benefit <= 0 then
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

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex ~= self.LIST_TEMPLATE_TYPE.TITLE then
		local growthCfg = LTConfig.GrowthConfig.GetConfig(data.id)
		local exp = gClientUtils.GetTargetLevelExp(growthCfg.Lv)
		store.title = LTConfig.TextScriptTextConfig.GetConfig(89901171).Text:format(exp)
	elseif data.tIndex ~= self.LIST_TEMPLATE_TYPE.CONTENT then
		local benefitIndex = data.benefitIndex
		local growthCfg = LTConfig.GrowthConfig.GetConfig(data.id)
		local benefit = growthCfg.Benefit[benefitIndex]
		store.title = benefit.benefitname
		store.description = benefit.benefitdescription
		store.iconId = growthCfg.BenefitIcon[benefitIndex] or 0
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
