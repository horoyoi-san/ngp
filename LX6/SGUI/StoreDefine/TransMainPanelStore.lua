-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TransMainPanelStore.lua
-- Decompiled from: 01171_TransMainPanelStore.lua_0cc25b5e2e89.luajit

local HouseConfig = LTConfig.HouseConfig
local HouseSexConfig = LTConfig.HouseSexConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local ActionItemConfig = LTConfig.ActionItemConfig
local ClientConst = gClientConst
C_TransMainPanelStore = DefClass("C_TransMainPanelStore", C_TransMainPanelStore, C_StoreGroup)
GroupName2Class.TransMainPanelStore = C_TransMainPanelStore
local M = C_TransMainPanelStore
local SexType = {
	["W#q^"] = 0,
	[":M\\x9c\\x8f\\x8fD"] = 1
}
local TransType = {
	["\\xf4\\xde#\\xf4"] = 2,
	["gHϳ\\x97\\xac\r\\xc6\\xe6"] = 0,
	["\\xf0\\xd5-\\xf5"] = 1
}
local ConsumableType = {
	["$\\xe6R-\\xd55\\xb8W\\xa0Z\\xb9\\xb2"] = 3,
	["\\xb25,:Q\\x93W\\xd8;\\xa3\\xbd"] = 2,
	["gHϳ\\x97\\xac\r\\xc6\\xe6"] = 1,
	["T-s^"] = 0
}
local BtnType = {
	["\\xf0\\xd5-\\xf5"] = 2,
	["gHϳ\\x97\\xac\r\\xc6\\xe6"] = 1,
	["T-s^"] = 0
}
local ShowRule = {
	["\\x89\\xbe\\xa3Y6\\xf1$"] = 0,
	["wUmg]-/"] = 2,
	["\\xb6:6>t\\x94E\\xea?\\xa5\\xae"] = 1
}

M.ctor = function(self)
	self.itemMgr = gCommonItemManager
end

M.DefineAllVariables = function(self)
	self.currentSexType = nil
	self.selectedSpiritId = nil
	self.invalidItemListEmpty = nil
	self.transItemListEmpty = nil
	self.currentShowRule = nil
	self.targetLoadModelCount = nil
	self.currentLoadModelCount = nil
	self.transItemList = {}
	self.invalidItemList = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.ruleCtrlEnum = {
		["\\x9e"] = 2,
		["\\x9c"] = 0,
		["\\x9f"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.ruleCtrlEnum = nil
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	gBlackScreenManager:OpenTransition(gBlackScreenId.TRANS_MODEL_LOADING, "", false, false, 0, -1, -1, 0)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	local spiritTid = gSpiritManager:GetCurFirstSpiritTid()

	if spiritTid ~= FightSpiritConfig.DefaultMale then
		self.currentSexType = SexType.Male
	elseif spiritTid ~= FightSpiritConfig.DefaultFemale then
		self.currentSexType = SexType.Female
	else
		print_error("@lujunlin 当前主角Tid匹配错误！请确认是否为主角！")
	end

	self.bindData.modelTab.selectedIndex = 0
	self.selectedSpiritId = spiritTid
	self.invalidStore = gStoreManager:GetStoreGroup(self.bindData.invalidBtn.Store):GetStoreByWidget(self.bindData.invalidBtn)
	self.invalidStore.title = HouseConfig.SexTransitionInvalidTitle

	self:RefreshInvalidItemList()

	self.transStore = gStoreManager:GetStoreGroup(self.bindData.transBtn.Store):GetStoreByWidget(self.bindData.transBtn)
	self.transStore.title = HouseConfig.SexTransitionTransTitle

	self:RefreshTransItemList()
	self:SetRuleShowType(BtnType.None)

	self.bindData.ruleCtrl = self.currentShowRule
	self.targetLoadModelCount = 0
	self.currentLoadModelCount = 0
end

M.OnClose = function(self)
	self.currentSexType = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.transItemList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTransItemListItem)
	self.bindData.transItemList.onGetTIndex = self.CreateAction(self, self.OnTransItemListGetTIndex)
	self.bindData.invalidItemList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderInvalidItemListItem)
	self.bindData.invalidItemList.onGetTIndex = self.CreateAction(self, self.OnInvalidItemListGetTIndex)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnConfirmBtnClick)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	self.bindData.infoBtn.luaClick = self.CreateAction(self, self.OnInfoBtnClick)
	self.bindData.invalidBtn.luaClick = self.CreateAction(self, self.OnInvalidBtnClick)
	self.bindData.transBtn.luaClick = self.CreateAction(self, self.OnTransitionBtnClick)
	self.bindData.modelTab.OnRenderTab = self.CreateAction(self, "OnModelPanelDisplay")
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local data = self.itemList[index + 1]

	if not data then
		return
	end

	local transType = data.transType

	if transType ~= TransType.Transition then
		self.RenderTransItem(self, btn, data)
	elseif transType ~= TransType.Invalid then
		self.RenderInvalidItem(self, btn, data, index)
	elseif transType ~= TransType.Message then
		self.RenderDesc(self, btn, data)
	end
end

M.OnSimpleRenderTransItemListItem = function(self, btn, index)
	local data = self.transItemList[index + 1]

	if not data then
		return
	end

	local transType = data.transType

	if transType ~= TransType.Transition then
		self.RenderTransItem(self, btn, data)
	elseif transType ~= TransType.Message then
		self.RenderDesc(self, btn, data)
	end
end

M.OnTransItemListGetTIndex = function(self, index)
	return self.transItemList[index + 1].tIndex
end

M.OnSimpleRenderInvalidItemListItem = function(self, btn, index)
	local data = self.invalidItemList[index + 1]

	if not data then
		return
	end

	local transType = data.transType

	if transType ~= TransType.Invalid then
		self.RenderInvalidItem(self, btn, data, index)
	elseif transType ~= TransType.Message then
		self.RenderDesc(self, btn, data)
	end
end

M.OnInvalidItemListGetTIndex = function(self, index)
	return self.invalidItemList[index + 1].tIndex
end

M.OnExitBtnClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnInfoBtnClick = function(self)
	local explainId = HouseConfig.SexTransitionConfirm
	local data = {
		id = explainId
	}

	gPanelManager:CheckShow(gPanelId.COMMON_WINDOW_INFO, data)
end

M.OnConfirmBtnClick = function(self)
	self.LoadComfirmPanel(self)
end

M.OnTransitionBtnClick = function(self)
	self.SetRuleShowType(self, BtnType.Transition)
end

M.OnInvalidBtnClick = function(self)
	self.SetRuleShowType(self, BtnType.Invalid)
end

M.RefreshTransItemList = function(self)
	self.transItemList = {}

	table.insert(self.transItemList, {
		["a\\x9f\\x8a\\x86Y"] = 0,
		transType = TransType.Message,
		text = HouseConfig.SexTransitionTransText
	})

	for i = 0, HouseSexConfig.count - 1 do
		local cfg = HouseSexConfig.LoadAt(i)

		if cfg.Type ~= ConsumableType.Transition then
			local beforeDressItemId = self.currentSexType ~= SexType.Male and cfg.MaleConsumable or cfg.FemaleConsumable
			local afterDressItemId = self.currentSexType ~= SexType.Female and cfg.MaleConsumable or cfg.FemaleConsumable

			if self:CheckItemOwned(beforeDressItemId) then
				local element = {
					["a\\x9f\\x8a\\x86Y"] = 1,
					transType = TransType.Transition,
					beforeDressItemId = beforeDressItemId,
					afterDressItemId = afterDressItemId
				}

				table.insert(self.transItemList, element)
			end
		end
	end

	self.transItemListEmpty = true

	if #self.transItemList <= 1 then
		self.transItemListEmpty = false
	end

	self.bindData.transItemList:SetSimpleList(#self.transItemList)

	self.bindData.transBtn.interactable = not self.transItemListEmpty
	self.transStore.isEmptyCtrl = ClientConst.BOOL2CTL[self.transItemListEmpty]
end

M.RenderTransItem = function(self, btn, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local beforeCfg = self:GetFashionConfigById(data.beforeDressItemId)

	if not beforeCfg then
		return
	end

	store.beforeDressName = beforeCfg.Name
	local beforeData = gCommonItemManager:GetItemRenderData({
		itemId = data.beforeDressItemId
	})

	gCommonItemManager:OnCommonItemRender(store.beforeDressItemBtn, 0, beforeData)

	local beforeStore = gStoreManager:GetStoreGroup(store.beforeDressItemBtn.Store):GetStoreByWidget(store.beforeDressItemBtn)
	beforeStore.icon = beforeCfg.Icon
	beforeStore.quality = beforeCfg.Quality
	local afterCfg = self:GetFashionConfigById(data.afterDressItemId)

	if not afterCfg then
		return
	end

	store.afterDressName = afterCfg.Name
	local afterData = gCommonItemManager:GetItemRenderData({
		itemId = data.afterDressItemId
	})

	gCommonItemManager:OnCommonItemRender(store.afterDressItemBtn, 0, afterData)

	local afterStore = gStoreManager:GetStoreGroup(store.afterDressItemBtn.Store):GetStoreByWidget(store.afterDressItemBtn)
	afterStore.icon = afterCfg.Icon
	afterStore.quality = afterCfg.Quality
end

M.RefreshInvalidItemList = function(self)
	self.invalidItemList = {}

	table.insert(self.invalidItemList, {
		["a\\x9f\\x8a\\x86Y"] = 0,
		transType = TransType.Message,
		text = HouseConfig.SexTransitionInvalidText
	})

	local targetInvalidType = self.currentSexType ~= SexType.Male and ConsumableType.FemaleInvalid or ConsumableType.MaleInvalid

	for i = 0, HouseSexConfig.count - 1 do
		local cfg = HouseSexConfig.LoadAt(i)

		if cfg.Type ~= targetInvalidType then
			local invalidDressItemId = cfg.InvalidConsumable

			if self.CheckItemOwned(self, invalidDressItemId) then
				local element = {
					["a\\x9f\\x8a\\x86Y"] = 1,
					transType = TransType.Invalid,
					invalidDressItemId = invalidDressItemId
				}

				table.insert(self.invalidItemList, element)
			end
		end
	end

	self.invalidItemListEmpty = true

	if #self.invalidItemList <= 1 then
		self.invalidItemListEmpty = false
	end

	self.bindData.invalidItemList:SetSimpleList(#self.invalidItemList)

	self.bindData.invalidBtn.interactable = not self.invalidItemListEmpty
	self.invalidStore.isEmptyCtrl = ClientConst.BOOL2CTL[self.invalidItemListEmpty]
end

M.RenderInvalidItem = function(self, btn, data, index)
	local invalidItemData = ConsumableConfig.GetConfig(data.invalidDressItemId)

	if not invalidItemData then
		return
	end

	local invalidRenderData = self.itemMgr:GetItemRenderData({
		["\\xd0\\xcf01\\xfc"] = 0,
		itemId = invalidItemData.Id
	})

	self.itemMgr:OnCommonItemRender(btn, index, invalidRenderData)
end

M.RenderDesc = function(self, btn, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.des = data.text
end

M.LoadComfirmPanel = function(self)
	local data = {
		maleToFemale = self.currentSexType ~= SexType.Male,
		titleText = HouseConfig.SexTransitionConfirmTitle,
		explainText = HouseConfig.SexTransitionConfirmText,
		warningText = HouseConfig.SexTransitionConfirmWarning
	}

	gPanelManager:CheckShow(gPanelId.TRANS_COMFIRM_PANEL, data)
end

M.CheckItemOwned = function(self, itemId)
	if not itemId then
		return false
	end

	local itemCfg = ConsumableConfig.GetConfig(itemId)

	if not itemCfg then
		return false
	end

	local targetId = itemCfg.BindId and itemCfg.BindId <= 0 and itemCfg.BindId or itemId
	local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig

	if itemCfg.SubType ~= ConsumableTypeConfig.Fashion then
		local fashionCfg = FashionConfig.GetConfig(targetId)

		if fashionCfg then
			return gDressManager:IsFashionHad(targetId)
		else
			return gMallManager:CheckFashionSuitOwned(targetId)
		end
	elseif itemCfg.SubType ~= ConsumableTypeConfig.ActionItem then
		local id = 0

		for i = 0, ActionItemConfig.count - 1 do
			local cfg = ActionItemConfig.LoadAt(i)

			if cfg.Icon ~= itemCfg.SItemIconId then
				id = cfg.Id

				break
			end
		end

		local playerInteractionActionInfo = gPlayerManager.infoMinor.bindData.playerInteractionActionInfo

		return playerInteractionActionInfo and playerInteractionActionInfo.UnlockActionItemDict and playerInteractionActionInfo.UnlockActionItemDict[id]
	else
		return gCommonItemManager:GetPackItemNum(targetId) >= 0
	end
end

M.GetFashionConfigById = function(self, consumableId)
	local cfg = ConsumableConfig.GetConfig(consumableId)

	if not cfg then
		print_error("当前consumableId：", consumableId, "未在表中找到对应物品！")

		return
	end

	local templateId = cfg.BindId
	local data = nil
	data = FashionConfig.GetConfig(templateId)

	if data then
		return data
	end

	data = FashionSuitConfig.GetConfig(templateId)

	if data then
		return data
	end

	print_error("@lujunlin 当前comsumableId：", consumableId, "未在表中找到对应时装！")
end

M.OnModelPanelDisplay = function(self)
	self.subModelStore = gStoreManager:GetStoreGroup("TransModelViewerStore")

	if self.subModelStore then
		slot1 = self.subModelStore

		slot1:SetSceneLoadCompleteCallback(function ()
			self:PlayOpenAnimation()
		end)
	end

	self.targetLoadModelCount = 2

	self.LoadSuitModel(self, HouseConfig.SexTransitionMaleSuit, SexType.Male)
	self.LoadSuitModel(self, HouseConfig.SexTransitionFemaleSuit, SexType.Female)
end

M.PlayOpenAnimation = function(self)
end

M.LoadSuitModel = function(self, suitId, sexType)
	if not suitId or suitId ~= 0 then
		self.ClearModel(self)

		return
	end

	if not self.subModelStore then
		return
	end

	local suitCfg = FashionSuitConfig.GetConfig(suitId)

	if not suitCfg or not suitCfg.FashionIdList then
		return
	end

	local spiritId = sexType ~= SexType.Male and FightSpiritConfig.DefaultMale or FightSpiritConfig.DefaultFemale

	if not spiritId or spiritId ~= 0 then
		return
	end

	local fashionInfo = {
		WearFashionInfoList = {},
		WearFashionEditInfoList = {}
	}

	for _, fashionId in ipairs(suitCfg.FashionIdList) do
		table.insert(fashionInfo.WearFashionInfoList, {
			FashionId = fashionId
		})
	end

	slot6 = self.subModelStore

	slot6:AddPendingLoadRequest(spiritId, fashionInfo, suitId, self.selectedSpiritId ~= spiritId and function (unit)
		self.currentModelUnit = unit

		self:CloseModelLoadBlackScreen()
	end or function ()
		self:CloseModelLoadBlackScreen()
	end)
end

M.ClearModel = function(self)
	if self.subModelStore then
		self.subModelStore:ClearCharacterModel()
	end

	self.currentModelUnit = nil
end

M.CloseModelLoadBlackScreen = function(self)
	self.currentLoadModelCount = self.currentLoadModelCount + 1

	if self.targetLoadModelCount < self.currentLoadModelCount then
		gBlackScreenManager:CloseTransition(gBlackScreenId.TRANS_MODEL_LOADING, 1)
	end
end

local AREA_CLOSE = 0
local AREA_OPEN = 1

M.SetRuleShowType = function(self, btnType)
	local invalidStore = self.invalidStore
	local transStore = self.transStore

	if self.invalidItemListEmpty and self.transItemListEmpty then
		self.currentShowRule = ShowRule.BothShow
		self.bindData.ruleCtrl = self.currentShowRule

		return
	end

	if btnType ~= BtnType.None then
		self.currentShowRule = ShowRule.BothShow

		if not self.invalidItemListEmpty then
			invalidStore.areaCtrl = AREA_OPEN
		end

		if not self.transItemListEmpty then
			transStore.areaCtrl = AREA_OPEN
		end

		self.bindData.ruleCtrl = self.currentShowRule

		return
	end

	if btnType ~= BtnType.Transition then
		if self.transItemListEmpty then
			return
		end

		if self.currentShowRule ~= ShowRule.TransShow then
			self.currentShowRule = ShowRule.BothShow
			transStore.areaCtrl = AREA_OPEN

			if not self.invalidItemListEmpty then
				invalidStore.areaCtrl = AREA_OPEN
			end
		else
			self.currentShowRule = ShowRule.TransShow
			transStore.areaCtrl = AREA_OPEN
			invalidStore.areaCtrl = AREA_CLOSE
		end
	elseif btnType ~= BtnType.Invalid then
		if self.invalidItemListEmpty then
			return
		end

		if self.currentShowRule ~= ShowRule.InvalidShow then
			self.currentShowRule = ShowRule.BothShow
			invalidStore.areaCtrl = AREA_OPEN

			if not self.transItemListEmpty then
				transStore.areaCtrl = AREA_OPEN
			end
		else
			self.currentShowRule = ShowRule.InvalidShow
			invalidStore.areaCtrl = AREA_OPEN
			transStore.areaCtrl = AREA_CLOSE
		end
	end

	self.bindData.ruleCtrl = self.currentShowRule
end
