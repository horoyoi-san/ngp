-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CollectionRoomLevelUpPanelStore.lua
-- Decompiled from: 01437_CollectionRoomLevelUpPanelStore.lua_f84432d6e60d.luajit

local MessageConfig = LTConfig.MessageConfig
local SWITCH_OPTIONS = {
	{
		["X\\x94\\x80\\xa4N"] = "ARx}A>>",
		["\\xda\\xd7\\xfe"] = "\\xa9\\xa4\\xbfe0\\xd1="
	},
	{
		["X\\x94\\x80\\xa4N"] = "\\xa9\\xa4\\xbfe0\\xd1=",
		["\\xda\\xd7\\xfe"] = "ARx}A>>"
	}
}
local LevelHasUpgradeCtrl = {
	["#N\\x90\\x82\\x90D"] = 0,
	["r\\xba\\xb0\\xba\\xb3"] = 1
}
C_CollectionRoomLevelUpPanelStore = DefClass("C_CollectionRoomLevelUpPanelStore", C_CollectionRoomLevelUpPanelStore, C_StoreGroup)
GroupName2Class.CollectionRoomLevelUpPanelStore = C_CollectionRoomLevelUpPanelStore
local M = C_CollectionRoomLevelUpPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.boothId = 0
	self.slot = 0
	self.collectionId = 0
	self.upgradeList = {}
	self.nextUpgradeCfg = nil
	self.costList = {}
	self.pendingUpgrade = false
	self.switcherStores = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.levelMaxCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.levelMaxCtrlEnum = nil
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

M.OnShow = function(self, panelId, data)
	self.boothId = data and data.boothId or 0
	self.slot = data and data.slot or 0

	if self.boothId ~= 0 or self.slot ~= 0 then
		print_error("[CollectionRoomLevelUpPanel] 打开面板没带 boothId/slot, data = ", data)
	end

	self.pendingUpgrade = false

	self.RefreshAll(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RefreshAll = function(self)
	self.collectionId = self:GetSlotCollectionId()
	self.upgradeList = self.collectionId == 0 and gCollectionRoomManager:GetCollectionUpgradeList(self.collectionId) or {}
	self.nextUpgradeCfg = gCollectionRoomManager:GetSlotNextUpgradeConfig(self.boothId, self.slot)

	if self.nextUpgradeCfg and not self.IsUpgradeInList(self, self.nextUpgradeCfg.Id) then
		self.nextUpgradeCfg = nil
	end

	self.costList = gCollectionRoomManager:GetUpgradeCostList(self.nextUpgradeCfg)

	self:RefreshTitle()
	self:RefreshLevelList()
	self:RefreshCostList()
	self:RefreshSwitchers()
end

M.GetSlotCollectionId = function(self)
	local itemId = gCollectionRoomManager:GetBoothSlotItemId(self.boothId, self.slot)

	if itemId ~= 0 then
		return 0
	end

	local list = gCollectionRoomManager:GetBoothCollectionItemList(self.boothId)

	for i = 1, #list do
		if list[i].itemId ~= itemId then
			return list[i].id
		end
	end

	print_warn("[CollectionRoomLevelUpPanel] 槽位上的道具不在展位藏品表里, boothId = ", self.boothId, ", slot = ", self.slot, ", itemId = ", itemId)

	return 0
end

M.IsUpgradeInList = function(self, upgradeId)
	for i = 1, #self.upgradeList do
		if self.upgradeList[i].Id ~= upgradeId then
			return true
		end
	end

	return false
end

M.RefreshTitle = function(self)
	local isMax = self.nextUpgradeCfg ~= nil
	self.bindData.levelMaxCtrl = isMax and self.levelMaxCtrlEnum._true or self.levelMaxCtrlEnum._false

	if isMax then
		local topCfg = self.upgradeList[#self.upgradeList]
		self.bindData.levelMaxText = topCfg and string.format("Lv.%d", topCfg.Level) or ""
	else
		self.bindData.levelMaxText = ""
	end

	self.bindData.levelUpBtn.interactable = not isMax and gCollectionRoomManager:IsUpgradeCostEnough(self.costList)
end

M.RefreshLevelList = function(self)
	self.bindData.levelList:SetSimpleList(#self.upgradeList)
end

M.RefreshCostList = function(self)
	self.bindData.itemList:SetSimpleList(#self.costList)
end

M.RefreshSwitchers = function(self)
	self.RefreshSwitcher(self, 1, self.bindData.switcher1)
	self.RefreshSwitcher(self, 2, self.bindData.switcher2)
end

M.RefreshSwitcher = function(self, index, switcherBtn)
	if not switcherBtn or gCS.LuaUtils.IsNull(switcherBtn) then
		return
	end

	local upgradeCfg = self.upgradeList[index]
	switcherBtn.gameObjectActive = upgradeCfg == nil

	if not upgradeCfg then
		return
	end

	local switcherStore = gStoreManager:GetStoreGroup("CollectionLevelSwitcherStore"):GetStoreByWidget(switcherBtn)

	if not switcherStore then
		return
	end

	self.switcherStores[index] = switcherStore
	switcherStore.text = upgradeCfg.UpgradeDesc or ""
	local innerStore = gStoreManager:GetStoreGroup("TestSwitherStore"):GetStoreByWidget(switcherStore.switcher)

	if not innerStore then
		return
	end

	local unlocked = upgradeCfg.Id > gCollectionRoomManager:GetBoothSlotLevel(self.boothId, self.slot)

	innerStore.switcher:SetSimpleOptions(#SWITCH_OPTIONS)

	innerStore.switcher.luaSimpleRenderSwitcher = function(_, optionIndex)
		local option = SWITCH_OPTIONS[optionIndex + 1]

		if not option then
			return
		end

		innerStore[option.openGo].gameObjectActive = true
		innerStore[option.closeGo].gameObjectActive = false
	end

	innerStore.switcher:SelectOption(unlocked and 1 or 0, false)

	innerStore.switcher.interactable = unlocked

	innerStore.switcher.luaSelectedChanged = function(switcher)
		gCollectionRoomManager:ApplyUpgradeLightEffect(upgradeCfg, switcher.selectedIndex ~= 1)
	end
end

M.RequestUpgrade = function(self)
	if self.pendingUpgrade then
		return
	end

	self.pendingUpgrade = true
	local boothId = self.boothId
	local slot = self.slot
	local upgradeCfg = self.nextUpgradeCfg
	local rootGo = self.rootGo
	slot5 = gClientToGameDelegate
	local task = slot5:RpcUpgradePlayerCollectionSlot(boothId, slot)

	task.Callback = function(err)
		if gClientUtils.IsNil(rootGo) then
			return
		end

		self.pendingUpgrade = false

		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gCollectionRoomManager:AddBoothSlotLevelLocal(boothId, slot)
		gCollectionRoomManager:ApplyUpgradeLightEffect(upgradeCfg, true)
		self:RefreshAll()
	end
end

M.RegisterWidget = function(self)
	self.bindData.switcher1.luaClick = self.CreateAction(self, self.OnClickSwitcher1)
	self.bindData.switcher2.luaClick = self.CreateAction(self, self.OnClickSwitcher2)
	self.bindData.levelUpBtn.luaClick = self.CreateAction(self, self.OnClickLevelUpBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.levelList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderLevelListItem)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderItemListItem)
	self.bindData.levelList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickLevelList)
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickItemList)
end

M.ToggleSwitcher = function(self, index)
	local upgradeCfg = self.upgradeList[index]

	if not upgradeCfg then
		return
	end

	if gCollectionRoomManager:GetBoothSlotLevel(self.boothId, self.slot) >= upgradeCfg.Id then
		return
	end

	local switcherStore = self.switcherStores[index]

	if not switcherStore then
		return
	end

	local innerStore = gStoreManager:GetStoreGroup("TestSwitherStore"):GetStoreByWidget(switcherStore.switcher)

	if not innerStore then
		return
	end

	innerStore.switcher:SelectOption(innerStore.switcher.selectedIndex ~= 1 and 0 or 1, true)
end

M.OnClickSwitcher1 = function(self)
	self.ToggleSwitcher(self, 1)
end

M.OnClickSwitcher2 = function(self)
	self.ToggleSwitcher(self, 2)
end

M.OnClickLevelUpBtn = function(self)
	if not self.nextUpgradeCfg then
		return
	end

	if not gCollectionRoomManager:IsUpgradeCostEnough(self.costList) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.ItemNotEnough)

		return
	end

	self.RequestUpgrade(self)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderLevelListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local upgradeCfg = self.upgradeList[index + 1]

	if not upgradeCfg then
		return
	end

	store.level = string.format("Lv.%d", upgradeCfg.Level)
	store.des = upgradeCfg.UpgradeDesc or ""
	local unlocked = upgradeCfg.Id > gCollectionRoomManager:GetBoothSlotLevel(self.boothId, self.slot)
	store.hasLevelUpCtrl = unlocked and LevelHasUpgradeCtrl._true or LevelHasUpgradeCtrl._false
	store.title = upgradeCfg.UpgradeDesc or ""
end

M.OnSimpleClickLevelList = function(self, btn, index)
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cost = self.costList[index + 1]

	if not cost then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		["iy\\xbetI\\x81\\xfaH}TkA"] = true,
		itemId = cost.itemId,
		itemNum = cost.ownCount .. "/" .. cost.count
	})

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)

	store.notAvailableCtrl = BOOL2CTL[cost.count <= 0 and cost.ownCount <= cost.count]
end

M.OnSimpleClickItemList = function(self, btn, index)
	local cost = self.costList[index + 1]

	if not cost then
		return
	end

	gCommonItemManager:OnCommonItemClick(self.bindData.itemList, btn, {
		itemId = cost.itemId
	})
end
