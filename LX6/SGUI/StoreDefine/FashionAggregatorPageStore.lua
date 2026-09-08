-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FashionAggregatorPageStore.lua
-- Decompiled from: 01902_FashionAggregatorPageStore.lua_f9598b9d2b42.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
C_FashionAggregatorPageStore = DefClass("C_FashionAggregatorPageStore", C_FashionAggregatorPageStore, C_StoreGroup)
GroupName2Class.FashionAggregatorPageStore = C_FashionAggregatorPageStore
local M = C_FashionAggregatorPageStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.spiritContext = nil
	self.fashionItemList = {}
	self.fashionPropItemList = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.isShowSettingCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isShowSettingCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	gDressStack:SetDressStack(-gDressSceneManager.TabType.Fashion, false)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, data)
	local unit = data and data.unit

	if not unit then
		return
	end

	self.spiritContext = gDressManager:GetSpiritContext(nil, , unit)

	if not self.spiritContext then
		return
	end

	local cameraParams = {
		verticalButton = self.bindData.verticalButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		unitProvider = function ()
			return gDressSceneManager.currentModelUnit
		end,
		isDummyMode = true
	}

	gDressStack:SetDressStack(-gDressSceneManager.TabType.Fashion, true, cameraParams)
	self:RefreshView()
end

M.OnClose = function(self)
end

M.RefreshView = function(self)
	local spiritId = self.spiritContext.spiritId
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict and spiritFashionsInfoDict[spiritId]

	if not spiritFashionsInfo then
		return
	end

	local wearList = spiritFashionsInfo.SpiritWearFashionsInfo and spiritFashionsInfo.SpiritWearFashionsInfo.WearFashionInfoList

	if not wearList then
		return
	end

	local matchedSuitId = self:FindCurrentWornSuit(wearList)
	self.bindData.isShowSettingCtrl = gDressManager:CheckShowSetting(self.spiritContext) and 0 or 1

	self:RefreshSuitComp(matchedSuitId)
	self:RefreshFashionList(wearList)
	self:RefreshFashionPropList(wearList)
	self:RefreshPlayerIcon()

	self.bindData.lightNameText = gDressSceneManager:GetNextSceneName()
end

M.FindCurrentWornSuit = function(self, wearList)
	local candidateSuits = {}

	for i = 1, wearList.Count do
		local fashionId = wearList[i].FashionId
		local suitIds = gDressManager:GetSuitIdByFashionId(fashionId)

		for _, suitId in ipairs(suitIds) do
			candidateSuits[suitId] = true
		end
	end

	for suitId, _ in pairs(candidateSuits) do
		local cfg = FashionSuitConfig.GetConfig(suitId)

		if cfg and gDressManager:IsFashionListMatchWore(cfg.FashionIdList, self.spiritContext) then
			return suitId
		end
	end

	return nil
end

M.RefreshSuitComp = function(self, suitId)
	local suitStore = gStoreManager:GetStoreGroup("DressTemplateSuitStore"):GetStoreByWidget(self.bindData.suitComp)

	if not suitStore then
		return
	end

	if suitId and suitId <= 0 then
		local cfg = FashionSuitConfig.GetConfig(suitId)

		if cfg then
			suitStore.icon = cfg.Icon
			suitStore.isEmptyCtrl = 0
			local firstFashionCfg = FashionConfig.GetConfig(cfg.FashionIdList[1])

			if firstFashionCfg then
				suitStore.quality = firstFashionCfg.Quality
				local brandCfg = ShopBrandConfig.GetConfig(firstFashionCfg.BelongBrand)

				if brandCfg then
					suitStore.iconBg = brandCfg.SuitBG
				end
			end

			suitStore.isAvailable = 1
		end
	else
		suitStore.isEmptyCtrl = 1
	end
end

M.RefreshFashionList = function(self, wearList)
	self.fashionItemList = {}
	local wornByPart = {}

	for i = 1, wearList.Count do
		local fashionId = wearList[i].FashionId
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg and not cfg.IsDefaultUnderwear and cfg.Part == gDressManager.DRESS_PART.PROP and cfg.IsShow then
			wornByPart[cfg.Part] = {
				["\\xd0\\xc810\\xe8"] = 0,
				fashionId = fashionId,
				icon = cfg.Icon,
				quality = cfg.Quality,
				part = cfg.Part
			}
		end
	end

	local tabIconList = FashionConfig.FashionChangeTabIcon

	for i = 1, #tabIconList do
		local part = tabIconList[i].part
		local worn = wornByPart[part]

		if part == gDressManager.DRESS_PART.PROP and part == gDressManager.DRESS_PART.SUITS then
			if worn then
				table.insert(self.fashionItemList, worn)
			else
				table.insert(self.fashionItemList, {
					["\\xd0\\xc810\\xe8"] = 1,
					emptyIconId = tabIconList[i].IconId,
					part = part
				})
			end
		end
	end

	self.bindData.fashionList:SetSimpleList(#self.fashionItemList)
end

M.RefreshFashionPropList = function(self, wearList)
	self.fashionPropItemList = {}
	local wornByType = {}

	for i = 1, wearList.Count do
		local fashionId = wearList[i].FashionId
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg and cfg.Part ~= gDressManager.DRESS_PART.PROP and not cfg.IsDefaultUnderwear and cfg.IsShow then
			wornByType[cfg.PropPart] = {
				["\\xd0\\xc810\\xe8"] = 0,
				fashionId = fashionId,
				icon = cfg.Icon,
				quality = cfg.Quality
			}
		end
	end

	local propTabIconList = FashionConfig.FashionChangePropTabIcon

	for i = 1, #propTabIconList do
		local propType = propTabIconList[i].type
		local worn = wornByType[propType]

		if worn then
			worn.propType = propType

			table.insert(self.fashionPropItemList, worn)
		else
			table.insert(self.fashionPropItemList, {
				["\\xd0\\xc810\\xe8"] = 1,
				emptyIconId = propTabIconList[i].IconId,
				propType = propType
			})
		end
	end

	self.bindData.fashionPropList:SetSimpleList(#self.fashionPropItemList)
end

M.RefreshPlayerIcon = function(self)
	local info = LTConfig.FightSpiritConfig.GetConfig(self.spiritContext.spiritId)

	if info then
		self.bindData.switchIconId = info.SHeadIconID
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.lightBtn.luaClick = self.CreateAction(self, self.OnClickLightBtn)
	self.bindData.settingBtn.luaClick = self.CreateAction(self, self.OnClickSettingBtn)
	self.bindData.planBtn.luaClick = self.CreateAction(self, self.OnClickPlanBtn)
	self.bindData.suitComp.luaClick = self.CreateAction(self, self.OnClickSuitComp)
	self.bindData.switchBtn.luaClick = self.CreateAction(self, self.OnClickSwitchBtn)
	self.bindData.fashionList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderFashionListItem)
	self.bindData.fashionPropList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderFashionPropListItem)
	self.bindData.fashionList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickFashionList)
	self.bindData.fashionPropList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickFashionPropList)
end

M.OnClickLightBtn = function(self)
	gDressSceneManager:CycleDressScene()

	self.bindData.lightNameText = gDressSceneManager:GetNextSceneName()
end

M.OnClickSettingBtn = function(self)
	gPanelManager:CheckShow(gPanelId.DRESS_SETTINGS_PANEL, {
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		spiritContext = self.spiritContext
	})
end

M.OnClickPlanBtn = function(self)
	gPanelManager:CheckShow(gPanelId.DRESS_PLAN_PANEL, {
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		spiritContext = self.spiritContext
	})
end

M.OnClickSuitComp = function(self)
	gPanelManager:CheckShow(gPanelId.S_FASHION_DETAIL_PANEL, {
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		["\\x96'*u\\x90X\\xf48\\xae\\xbc"] = true,
		["\\xe2M+\\xc4/\\xa3H\\xb5b\\xb1\\xb4"] = true,
		spiritContext = self.spiritContext,
		callBack = function ()
			self:RefreshView()
		end
	})
end

M.OnClickSwitchBtn = function(self)
	gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER, {
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		["\\x90:,&H\\x8fD\\xcf>\\xaf\\xae"] = true,
		spiritId = self.spiritContext.spiritId,
		onSelectCallback = function (selectedSpiritId)
			gDressSceneManager:SwitchCharacterModel(selectedSpiritId, function (unit)
				self.spiritContext = gDressManager:GetSpiritContext(selectedSpiritId, nil, unit)

				self:RefreshView()
			end)
		end
	})
end

M.OnSimpleRenderFashionListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.fashionItemList[index + 1]

	if not data then
		return
	end

	if data.isEmpty ~= 1 then
		store.isEmptyCtrl = 1
		store.emptyIconId = data.emptyIconId
	else
		store.isEmptyCtrl = 0
		store.icon = data.icon
		store.quality = data.quality
	end
end

M.OnSimpleClickFashionList = function(self, btn, index)
	local data = self.fashionItemList[index + 1]

	if not data then
		return
	end

	local params = {
		["\\x96'*u\\x90X\\xf48\\xae\\xbc"] = true,
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		spiritContext = self.spiritContext,
		callBack = function ()
			self:RefreshView()
		end
	}

	if data.isEmpty == 1 then
		params.targetFashionId = data.fashionId
	else
		params.targetPart = data.part
	end

	gPanelManager:CheckShow(gPanelId.S_FASHION_DETAIL_PANEL, params)
end

M.OnSimpleRenderFashionPropListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.fashionPropItemList[index + 1]

	if not data then
		return
	end

	if data.isEmpty ~= 1 then
		store.isEmptyCtrl = 1
		store.emptyIconId = data.emptyIconId
	else
		store.isEmptyCtrl = 0
		store.icon = data.icon
		store.quality = data.quality
	end
end

M.OnSimpleClickFashionPropList = function(self, btn, index)
	local data = self.fashionPropItemList[index + 1]

	if not data then
		return
	end

	local params = {
		["\\x96'*u\\x90X\\xf48\\xae\\xbc"] = true,
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		spiritContext = self.spiritContext,
		callBack = function ()
			self:RefreshView()
		end
	}

	if data.isEmpty == 1 then
		params.targetFashionId = data.fashionId
	else
		params.targetPart = gDressManager.DRESS_PART.PROP
		params.targetPropType = data.propType
	end

	gPanelManager:CheckShow(gPanelId.S_FASHION_DETAIL_PANEL, params)
end
