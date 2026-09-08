-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HouseListPagePanel.lua
-- Decompiled from: 01806_HouseListPagePanel.lua_c72e1b2a28a2.luajit

local HouseConfig = LTConfig.HouseConfig
local STATE_CTRL = {
	["mHxKA,"] = 0,
	["2G\\xa2\\x86\\x8cQ"] = 1,
	[">G\\x84\\x89\\x8bU"] = 2
}
local MONEY_LACK_CTRL = {
	["9F\\x9e\\x9b\\x84I"] = 0,
	["V#~P"] = 1
}
C_HouseListPagePanel = DefClass("C_HouseListPagePanel", C_HouseListPagePanel, C_StoreGroup)
GroupName2Class.HouseListPagePanel = C_HouseListPagePanel
local M = C_HouseListPagePanel

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.curHouseList = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()

	self.parent = gStoreManager:GetStoreGroup("HousePropertyPanelStore")
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.InitData(self)
end

M.OnEnable = function(self)
	if self.parent and self.parent.MarkListPageOpened then
		self.parent:MarkListPageOpened()
	end

	self.RefreshHouseList(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.GenMessageEvents = function(self)
	local refresh = self.CreateAction(self, "RefreshHouseList")
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = refresh,
		[gEventConstants.ON_BUY_HOUSE_SUCCESS] = refresh
	}
end

M.InitData = function(self)
	self.curHouseList = {}

	for i = 0, HouseConfig.count - 1 do
		local cfg = HouseConfig.LoadAt(i)

		if cfg.IsShopHouse then
			table.insert(self.curHouseList, cfg)
		end
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.houseList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderHouseListItem)
	self.bindData.houseList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickHouseList)
end

M.OnClickBackBtn = function(self)
	if self.parent and self.parent.OnBackBtnClick then
		self.parent:OnBackBtnClick()
	end
end

M.RefreshHouseList = function(self)
	if not self.curHouseList then
		return
	end

	self.bindData.houseList:SetSimpleList(#self.curHouseList)
end

M.OnSimpleRenderHouseListItem = function(self, btn, index)
	local houseCfg = self.curHouseList[index + 1]
	local store = gStoreManager:GetStoreGroup("HouseInfoTemplate"):GetStoreByWidget(btn)

	if not store or not houseCfg then
		return
	end

	store.titleText = houseCfg.Name
	store.addressText = houseCfg.Location
	store.iconId = houseCfg.HouseImage
	local hasShop = houseCfg.ShopId and houseCfg.ShopId == 0
	local hasBought = gBuyHouseUtils.CheckHasBuyTheHouse(houseCfg.Id) or false

	if not hasShop then
		store.stateCtrl = STATE_CTRL.NoShop
		store.moneyText = ""
		store.moneylackCtrl = MONEY_LACK_CTRL.Enough
	elseif hasBought then
		store.stateCtrl = STATE_CTRL.Bought
		store.moneyText = ""
		store.moneylackCtrl = MONEY_LACK_CTRL.Enough
	else
		store.stateCtrl = STATE_CTRL.NotBought
		local price = gBuyHouseUtils.GetHousePrice(houseCfg.Id) or 0
		store.moneyText = "#C(jinyuebi_Text)" .. price
		local enough = gBuyHouseUtils.CheckBuyHouseMoneyEnough(houseCfg.Id)
		store.moneylackCtrl = enough and MONEY_LACK_CTRL.Enough or MONEY_LACK_CTRL.Lack
	end

	local qualityStore = gStoreManager:GetStoreGroup("HouseQualityTemplate"):GetStoreByWidget(store.houseQuality)

	if qualityStore then
		qualityStore.houseQualityCtrl = houseCfg.Quality or 0
	end
end

M.OnSimpleClickHouseList = function(self, btn, index)
	local houseCfg = self.curHouseList[index + 1]

	if not houseCfg then
		return
	end

	if self.parent and self.parent.OnSelectHouse then
		self.parent:OnSelectHouse(houseCfg.Id)
	end
end
