-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieMemberCenterPanelStore.lua
-- Decompiled from: 02062_YanjieMemberCenterPanelStore.lua_48d03e879d93.luajit

C_YanjieMemberCenterPanelStore = DefClass("C_YanjieMemberCenterPanelStore", C_YanjieMemberCenterPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieMemberCenterPanelStore = C_YanjieMemberCenterPanelStore
local M = C_YanjieMemberCenterPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.detailButton.luaClick = self.CreateAction(self, "OnDetailClick")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.LIST_TEMPLATE_TYPE = {
		["\\xfa\\xf4:);\n\\xc5"] = 1,
		["y\\x87\\x96\\x83\\x93"] = 0
	}
	self.CATEGORY_TYPE = {
		["\\xfa\\xee&/;\n\\xc5"] = 1,
		["TEo"] = 2
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
	gSocialNetworkUtils.RefreshPlayerExpProgressView(self.bindData.commonFansLevel)
end

M.GetBenefitViewDataList = function(self)
	local viewDataList = {}
	local currentLevel = gClientUtils.GetPlayerLevel()
	local currentBenefitViewDataList = self.GetCurrentBenefitViewDataList(self, currentLevel)
	local currentBenefitCount = #currentBenefitViewDataList

	if currentBenefitCount <= 0 then
		local growthId = gClientUtils.GetGrowthIdByLv(currentLevel)

		table.insert(viewDataList, {
			tIndex = self.LIST_TEMPLATE_TYPE.TITLE,
			type = self.CATEGORY_TYPE.CURRENT,
			benefitCount = currentBenefitCount,
			id = growthId
		})

		for _, data in ipairs(currentBenefitViewDataList) do
			table.insert(viewDataList, {
				tIndex = self.LIST_TEMPLATE_TYPE.CONTENT,
				benefitInfo = data
			})
		end
	end

	local nextBenefitViewDataList, nextGrowthId = self.GetNextBenefitViewDataList(self, currentLevel)

	if #nextBenefitViewDataList <= 0 then
		table.insert(viewDataList, {
			tIndex = self.LIST_TEMPLATE_TYPE.TITLE,
			type = self.CATEGORY_TYPE.NEXT,
			id = nextGrowthId
		})

		for _, data in ipairs(nextBenefitViewDataList) do
			table.insert(viewDataList, {
				tIndex = self.LIST_TEMPLATE_TYPE.CONTENT,
				benefitInfo = data
			})
		end
	end

	return viewDataList
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex ~= self.LIST_TEMPLATE_TYPE.TITLE then
		if data.type ~= self.CATEGORY_TYPE.CURRENT then
			store.title = LTConfig.TextScriptTextConfig.GetConfig(89901169).Text:format(data.benefitCount)
		elseif data.type ~= self.CATEGORY_TYPE.NEXT then
			store.title = LTConfig.TextScriptTextConfig.GetConfig(89901170).Text
		end
	elseif data.tIndex ~= self.LIST_TEMPLATE_TYPE.CONTENT then
		local benefitInfo = data.benefitInfo
		local benefitIndex = benefitInfo.benefitIndex
		local growthCfg = LTConfig.GrowthConfig.GetConfig(benefitInfo.id)
		local benefit = growthCfg.Benefit[benefitIndex]
		store.title = benefit.benefitname
		store.description = benefit.benefitdescription
		store.iconId = growthCfg.BenefitIcon[benefitIndex] or 0
	end
end

M.GetCurrentBenefitViewDataList = function(self, currentLevel)
	local viewDataList = {}
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if growthCfg.Lv < currentLevel and #growthCfg.Benefit <= 0 then
			local benefitList = growthCfg.Benefit

			for index, _ in ipairs(benefitList) do
				table.insert(viewDataList, {
					id = growthCfg.Id,
					benefitIndex = index
				})
			end
		end
	end

	return viewDataList
end

M.GetNextBenefitViewDataList = function(self, currentLevel)
	local viewDataList = {}
	local count = LTConfig.GrowthConfig.count
	local targetGrowthId = nil

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if currentLevel >= growthCfg.Lv and #growthCfg.Benefit <= 0 then
			local benefitList = growthCfg.Benefit

			for index, _ in ipairs(benefitList) do
				table.insert(viewDataList, {
					id = growthCfg.Id,
					benefitIndex = index
				})
			end

			targetGrowthId = growthCfg.Id

			break
		end
	end

	return viewDataList, targetGrowthId
end

M.OnDetailClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.BenefitsDetail
	})
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
