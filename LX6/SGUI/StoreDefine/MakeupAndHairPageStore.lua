-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MakeupAndHairPageStore.lua
-- Decompiled from: 00963_MakeupAndHairPageStore.lua_b0ab4b362c2d.luajit

local FashionConfig = LTConfig.FashionConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local FashionSpiritConfig = LTConfig.FashionSpiritConfig
C_MakeupAndHairPageStore = DefClass("C_MakeupAndHairPageStore", C_MakeupAndHairPageStore, C_StoreGroup)
GroupName2Class.MakeupAndHairPageStore = C_MakeupAndHairPageStore
local M = C_MakeupAndHairPageStore
local TabType = {
	["1I\\x9a\\x8b\\x96Q"] = 2,
	["R#tI"] = 1
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.spiritContext = nil
	self.currentTab = TabType.Hair
	self.itemList = {}
	self.selectedFashionId = 0
	self.hideCb = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.isShowSettingCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isShowToolTipCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.hidePageCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isShowSettingCtrlEnum = nil
	self.isShowToolTipCtrlEnum = nil
	self.hidePageCtrlEnum = nil
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
	gDressStack:SetDressStack(-gDressSceneManager.TabType.Makeup, false)

	if not self.spiritContext then
		return
	end

	local UnitFashionInfoModule = LX6.Units.Module.UnitFashionInfoModule
	local dummyModule = UnitFashionInfoModule.GetModule(self.spiritContext.unit)
	local playerUnit = gCS.MyPlayerManager.PlayerUnit
	local playerModule = UnitFashionInfoModule.GetModule(playerUnit)

	playerModule:SyncTryFashionsFrom(dummyModule, self.spiritContext.spiritId)
	gDressData:AskSetSpiritFashions(nil, self.spiritContext.spiritId, playerUnit)
	gMessageManager:SendMessage(gEventConstants.FASHION_CAM_SET_TYPE, "FullShot")
end

M.OnShow = function(self, data)
	local unit = data and data.unit

	if not unit then
		return
	end

	self.hideCb = data.hideCb
	self.spiritContext = gDressManager:GetSpiritContext(nil, , unit)

	if not self.spiritContext then
		return
	end

	self.bindData.isShowSettingCtrl = self.isShowSettingCtrlEnum.hide
	local cameraParams = {
		verticalButton = self.bindData.verticalButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		unitProvider = function ()
			return gDressSceneManager.currentModelUnit
		end
	}

	gDressStack:SetDressStack(-gDressSceneManager.TabType.Makeup, true, cameraParams)
	gMessageManager:SendMessage(gEventConstants.FASHION_CAM_SET_TYPE, "FaceShot")
	self:RefreshPlayerIcon()
	self:InitTab()

	self.bindData.lightNameText = gDressSceneManager:GetNextSceneName()
end

M.OnClose = function(self)
end

M.InitTab = function(self)
	self.tabList = {
		{
			id = TabType.Hair,
			title = FashionConfig.FashionHairMakeupTab[1],
			icon = FashionConfig.FashionPaneMakeupTabIcon[1]
		},
		{
			id = TabType.Makeup,
			title = FashionConfig.FashionHairMakeupTab[2],
			icon = FashionConfig.FashionPaneMakeupTabIcon[2]
		}
	}

	self.SubGroup.CommonTabSingleStore:SetData(self.tabList, nil, 0, nil, self:CreateAction(self.OnTabChanged), self:CreateAction(self.OnRenderTabItem), 1)
end

M.OnRenderTabItem = function(self, btn, index)
	local data = self.tabList[index + 1]
	local store = gStoreManager:GetStoreGroup("ShopAppearanceTabTemplate"):GetStoreByWidget(btn)

	if store and data then
		store.name = data.title
		store.icon = data.icon
	end
end

M.OnTabChanged = function(self, uList)
	local tabData = self.SubGroup.CommonTabSingleStore:GetSelectedItem()

	if not tabData then
		return
	end

	self.currentTab = tabData.id

	self.RefreshFashionList(self)
end

M.RefreshFashionList = function(self)
	self.itemList = {}
	local spiritId = self.spiritContext.spiritId
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict

	if table.isNilOrEmpty(fashionInfoDict) or fashionInfoDict.Count ~= 0 then
		self.UpdateSelectedFashionId(self)
		self.BuildListUI(self)

		return
	end

	if self.currentTab ~= TabType.Hair then
		local hairIcon = nil

		for index = 0, FashionSpiritConfig.count - 1 do
			local spiritCfg = FashionSpiritConfig.LoadAt(index)

			if spiritCfg and spiritCfg.FightSpiritId ~= spiritId then
				hairIcon = spiritCfg.HairIcon

				break
			end
		end

		table.insert(self.itemList, {
			["ZI켗\r\\x90\\xc0\\xfa"] = true,
			hairIcon = hairIcon
		})

		for _, fashionInfo in pairs(fashionInfoDict) do
			local fashionId = fashionInfo.FashionId
			local cfg = FashionConfig.GetConfig(fashionId)

			if cfg and cfg.Part ~= FashionConfig.PartType.Hair and cfg.IsShow and not cfg.IsOneTime and cfg.BelongSpiritId ~= spiritId then
				table.insert(self.itemList, {
					fashionId = fashionId,
					icon = cfg.Icon,
					quality = cfg.Quality
				})
			end
		end
	elseif self.currentTab ~= TabType.Makeup then
		table.insert(self.itemList, {
			["\\x96'2h\\x89X\\xf0#\\xaf\\xb4"] = true
		})

		for _, fashionInfo in pairs(fashionInfoDict) do
			local fashionId = fashionInfo.FashionId
			local cfg = FashionConfig.GetConfig(fashionId)

			if cfg and cfg.Part ~= FashionConfig.PartType.Makeup and cfg.IsShow and not cfg.IsOneTime and cfg.BelongSpiritId ~= spiritId then
				table.insert(self.itemList, {
					fashionId = fashionId,
					icon = cfg.Icon,
					quality = cfg.Quality
				})
			end
		end
	end

	self.UpdateSelectedFashionId(self)
	self.BuildListUI(self)
	self.SelectCurrentItem(self)

	if self.selectedFashionId ~= 0 then
		self.bindData.isShowToolTipCtrl = self.isShowToolTipCtrlEnum.show

		if self.currentTab ~= TabType.Hair then
			self.SubGroup.CommonDressTooltip:ShowDefaultInfo(FashionConfig.FashionPanelHairDefautTitle)
		else
			self.SubGroup.CommonDressTooltip:ShowDefaultInfo(FashionConfig.FashionPanelMakeupDefautTitle)
		end
	else
		self.bindData.isShowToolTipCtrl = self.isShowToolTipCtrlEnum.show

		self.SubGroup.CommonDressTooltip:ShowFashionInfo(self.selectedFashionId, {
			["\\x8c</([\\x92M\\xd52\\xa9\\xad"] = false
		})
	end

	self.OverrideTooltipPartName(self)
end

M.BuildListUI = function(self)
	self.bindData.fashionList:SetSimpleList(#self.itemList)
end

M.SelectCurrentItem = function(self)
	if self.selectedFashionId ~= 0 then
		self.bindData.fashionList:SelectItem(0, false)

		return
	end

	for i = 1, #self.itemList do
		if self.itemList[i].fashionId ~= self.selectedFashionId then
			self.bindData.fashionList:SelectItem(i - 1, false)

			return
		end
	end
end

M.OnGetTIndex = function(self, index)
	return self.currentTab ~= TabType.Hair and 0 or 1
end

M.UpdateSelectedFashionId = function(self)
	if not self.spiritContext then
		self.selectedFashionId = 0

		return
	end

	local wearList = gDressManager:GetCurrentSpritWearFashionInfoList(self.spiritContext)

	if not wearList then
		self.selectedFashionId = 0

		return
	end

	local targetPart = self.currentTab ~= TabType.Hair and FashionConfig.PartType.Hair or FashionConfig.PartType.Makeup

	for i = 0, wearList.Count - 1 do
		local fashionId = wearList[i].FashionId
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg and cfg.Part ~= targetPart then
			if cfg.IsDefaultUnderwear then
				self.selectedFashionId = 0
			else
				self.selectedFashionId = fashionId
			end

			return
		end
	end

	self.selectedFashionId = 0
end

M.RegisterWidget = function(self)
	self.bindData.hideBtn.luaClick = self.CreateAction(self, self.OnClickHideBtn)
	self.bindData.lightBtn.luaClick = self.CreateAction(self, self.OnClickLightBtn)
	self.bindData.refreshBtn.luaClick = self.CreateAction(self, self.OnClickRefreshBtn)
	self.bindData.switchBtn.luaClick = self.CreateAction(self, self.OnClickSwitchBtn)
	self.bindData.fashionList.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
	self.bindData.fashionList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderFashionListItem)
	self.bindData.fashionList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickFashionList)
end

M.OnClickHideBtn = function(self)
	if not self.bindData.hidePageCtrl then
		self.bindData.hidePageCtrl = 0
	else
		self.bindData.hidePageCtrl = 1 - self.bindData.hidePageCtrl
	end

	if self.hideCb then
		self.hideCb(self.bindData.hidePageCtrl)
	end
end

M.OnClickLightBtn = function(self)
	gDressSceneManager:CycleDressScene()

	self.bindData.lightNameText = gDressSceneManager:GetNextSceneName()
end

M.OnClickRefreshBtn = function(self)
	gDressManager:CheckClearFashionPart(self.spiritContext)
	self:RefreshFashionList()
end

M.OnClickSwitchBtn = function(self)
	gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER, {
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		["\\x90:,&H\\x8fD\\xcf>\\xaf\\xae"] = true,
		spiritId = self.spiritContext.spiritId,
		onSelectCallback = function (selectedSpiritId)
			gDressSceneManager:SwitchCharacterModel(selectedSpiritId, function (unit)
				self.spiritContext = gDressManager:GetSpiritContext(selectedSpiritId, nil, unit)

				self:RefreshPlayerIcon()
				self:RefreshFashionList()
			end)
		end
	})
end

M.OnSimpleRenderFashionListItem = function(self, btn, index)
	local data = self.itemList[index + 1]

	if not data then
		return
	end

	if data.isBaseHair then
		btn.isSelected = self.selectedFashionId ~= 0
	elseif data.isEmptyItem then
		btn.isSelected = self.selectedFashionId ~= 0
	else
		btn.isSelected = self.selectedFashionId ~= data.fashionId
	end

	if self.currentTab ~= TabType.Hair then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		if data.isBaseHair then
			store.qualityCtrl = 0
			store.iconId = data.hairIcon or 0
		else
			store.qualityCtrl = data.quality or 0
			store.iconId = data.icon or 0
		end
	elseif self.currentTab ~= TabType.Makeup then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		if data.isEmptyItem then
			store.isEmptyCtrl = 0
			store.qualityCtrl = 0
		else
			store.isEmptyCtrl = 1
			store.qualityCtrl = data.quality or 0
			store.iconId = data.icon or 0
		end
	end
end

M.OnSimpleClickFashionList = function(self, btn, index)
	local data = self.itemList[index + 1]

	if not data then
		return
	end

	if self.currentTab ~= TabType.Hair then
		if data.isBaseHair then
			local hairIds = self.GetCurrentWornHairIds(self)

			if hairIds then
				gDressManager:RemoveFashionPart(hairIds, self.spiritContext)
			end

			self.selectedFashionId = 0
			self.bindData.isShowToolTipCtrl = self.isShowToolTipCtrlEnum.show

			self.SubGroup.CommonDressTooltip:ShowDefaultInfo(FashionConfig.FashionPanelHairDefautTitle)
		else
			local conflictItems, addItems = gDressManager:CheckFashionConflict({
				data.fashionId
			}, self.spiritContext)

			table.insert(addItems, data.fashionId)
			gDressManager:SetFashionList(addItems, nil, self.spiritContext)

			self.selectedFashionId = data.fashionId
			self.bindData.isShowToolTipCtrl = self.isShowToolTipCtrlEnum.show

			self.SubGroup.CommonDressTooltip:ShowFashionInfo(data.fashionId, {
				["\\x8c</([\\x92M\\xd52\\xa9\\xad"] = false
			})
		end
	elseif self.currentTab ~= TabType.Makeup then
		if data.isEmptyItem then
			local currentMakeupId = self.GetCurrentWornMakeupId(self)

			if currentMakeupId then
				gDressManager:RemoveFashionPart({
					currentMakeupId
				}, self.spiritContext)
			end

			self.selectedFashionId = 0
			self.bindData.isShowToolTipCtrl = self.isShowToolTipCtrlEnum.show

			self.SubGroup.CommonDressTooltip:ShowDefaultInfo(FashionConfig.FashionPanelMakeupDefautTitle)
		else
			local conflictItems, addItems = gDressManager:CheckFashionConflict({
				data.fashionId
			}, self.spiritContext)

			table.insert(addItems, data.fashionId)
			gDressManager:SetFashionList(addItems, nil, self.spiritContext)

			self.selectedFashionId = data.fashionId
			self.bindData.isShowToolTipCtrl = self.isShowToolTipCtrlEnum.show

			self.SubGroup.CommonDressTooltip:ShowFashionInfo(data.fashionId, {
				["\\x8c</([\\x92M\\xd52\\xa9\\xad"] = false
			})
		end
	end

	self:OverrideTooltipPartName()
	self.bindData.fashionList:RefreshList()
end

M.OverrideTooltipPartName = function(self)
	local tabTitle = self.currentTab ~= TabType.Hair and FashionConfig.FashionHairMakeupTab[1] or FashionConfig.FashionHairMakeupTab[2]
	self.SubGroup.CommonDressTooltip.bindData.typeText = tabTitle
end

M.GetCurrentWornHairIds = function(self)
	local wearList = gDressManager:GetCurrentSpritWearFashionInfoList(self.spiritContext)

	if not wearList then
		return nil
	end

	local hairIds = {}

	for i = 0, wearList.Count - 1 do
		local fashionId = wearList[i].FashionId
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg and cfg.Part ~= FashionConfig.PartType.Hair then
			table.insert(hairIds, fashionId)
		end
	end

	if #hairIds <= 0 then
		return hairIds
	end

	return nil
end

M.GetCurrentWornMakeupId = function(self)
	local wearList = gDressManager:GetCurrentSpritWearFashionInfoList(self.spiritContext)

	if not wearList then
		return nil
	end

	for i = 0, wearList.Count - 1 do
		local fashionId = wearList[i].FashionId
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg and cfg.Part ~= FashionConfig.PartType.Makeup then
			return fashionId
		end
	end

	return nil
end

M.RefreshPlayerIcon = function(self)
	local info = FightSpiritConfig.GetConfig(self.spiritContext.spiritId)

	if info then
		self.bindData.switchIconId = info.SHeadIconID
	end
end

M.GenMessageEvents = function(self)
end
