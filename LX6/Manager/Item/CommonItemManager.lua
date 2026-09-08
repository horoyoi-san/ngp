-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager.lua
-- Decompiled from: 02202_CommonItemManager.lua_246832fa3b72.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local VehicleConfig = LTConfig.VehicleConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local StaticProps = {}
C_CommonItemManager = DefClass("C_CommonItemManager", C_CommonItemManager, nil, StaticProps)
local M = C_CommonItemManager

dofile("LX6/Manager/Item/CommonItemManager_UI")
dofile("LX6/Manager/Item/CommonItemManager_Special")
dofile("LX6/Manager/Item/CommonItemManager_Money")
dofile("LX6/Manager/Item/CommonItemManager_ItemInfo")
dofile("LX6/Manager/Item/CommonItemManager_Drop")
dofile("LX6/Manager/Item/CommonItemManager_Gift")
dofile("LX6/Manager/Item/CommonItemManager_Package")
dofile("LX6/Manager/Item/CommonItemManager_Weapon")
dofile("LX6/Manager/Item/CommonItemManager_SubmitItem")
dofile("LX6/Manager/Item/CommonItemManager_TarkovChip")

M.ctor = function(self)
	self.itemCountLimitMax = {}
	self.quantumWalletStartTime = 0
	self.ITEM_TYPE = {
		["IW\\x9f_e\\x9d\\xdcxYOWx"] = 3,
		["?g\\xbc\\xa3\\xaco"] = 0,
		["\\xaf]\\xa2u\\xf1\\x87\\x9c"] = 4,
		["+m\\xb0\\xbe\\xaco"] = 5,
		["\\xff\\xfa'57\\xdf"] = 2,
		["\\xef\\xfe<4=\\xd4"] = 1
	}
	self.SUBTYPE2ITEM_TYPE = {
		[ConsumableTypeConfig.Vehicle] = self.ITEM_TYPE.VEHICLE,
		[ConsumableTypeConfig.Fashion] = self.ITEM_TYPE.FASHION,
		[ConsumableTypeConfig.PhoneTheme] = self.ITEM_TYPE.PHONE_THEME,
		[ConsumableTypeConfig.Weapon] = self.ITEM_TYPE.WEAPON
	}
	self.SUB_QUALITY_CTRL = {
		["\\xef"] = 3,
		["\\xee"] = 2,
		["\\xec"] = 4,
		["\\xe9"] = 1,
		["\\xfe"] = 5,
		["T\rS~"] = 0
	}
	self.EQUIPPED_CTRL = {
		["+m\\xb0\\xbe\\xaco"] = 2,
		["`oM[o=%7\n"] = 1,
		["T\rS~"] = 0
	}
	self.BROKEN_CTRL = {
		[">z\\xbe\\xa5\\xa6o"] = 2,
		["2g\\xa3\\xa3\\xa2m"] = 0,
		[",\\xc6~&\\xe9#\\x94s\\x8e}\\x95\\x98"] = 1
	}
	self.Template2Index = {
		["\\x98\\x94&\\x94^\\xc6"] = 1,
		["\\xadJ\\xb9~\\xf5\\x99\\x8d"] = 4,
		["{c\\xfe\\x98\\xb67\\x94-\\xe7\\xc3"] = 3,
		["\\xabW\\xab~\\xf0\\x8f\\x94"] = 9,
		["$\\xb1΀\\x98Ň\\x88\\xa3\\xf8\\xd6\r\\xe5\\xb2\\xad\\xd6"] = 12,
		["d&\\x87&\\xe8\\xda"] = 6,
		["y\\xa7\\xb6\\xa3\\xb3"] = 0,
		["5\\xc2z%\\xfe#\\x98t\\x8ct\\x95\\x84"] = 7,
		["\\xa8W\\xb3~\\xfa\\x83\\x89"] = 10,
		["\\xa8W\\xb3~\\xfd\\x99\\x9a"] = 11,
		["nfEGq*4*"] = 2,
		["tf^Gq*4*"] = 5
	}
	self.CommonItemRenderSizeCtl = {
		["2g\\xa3\\xa3\\xa2m"] = 0,
		["~\\x83\\x83\\x83\\x9a"] = 1
	}
	self.INVENTORY_MODE = {
		["/m\\xbd\\xab\\xa0u"] = 2,
		["IQw"] = 1,
		["2g\\xa3\\xa3\\xa2m"] = 0
	}
	self.INVENTORY_MODE = {
		["/m\\xbd\\xab\\xa0u"] = 2,
		["IQw"] = 1,
		["2g\\xa3\\xa3\\xa2m"] = 0
	}
	self.DropItemToFakeItem = {
		Money = ConsumableConfig.RewardMoney,
		BindingGold = ConsumableConfig.RewardBindingGold
	}
	self.SpecialItemId = {
		ConsumableConfig.RewardMoney,
		ConsumableConfig.RewardBindingGold,
		ConsumableConfig.RewardGold
	}
	self.HIDE_QUALITY = ConsumableConfig.QualityType.NoQuality
end

M.OnInit = function(self)
	self.itemLimitDict = {}
	self.viewItemList = {}
	self.enableExchange = false
	local itemSortPower = {}

	for i = 0, ConsumableTypeConfig.count - 1 do
		local typeCfg = ConsumableTypeConfig.LoadAt(i)

		if typeCfg.Order and typeCfg.Order == 0 then
			itemSortPower[typeCfg.Id] = -typeCfg.Order
		end
	end

	self.itemSortPower = itemSortPower
	self.itemToolTipRefBtn = nil

	self:OnInitMoney()
	self:OnInitPackage()
	self:OnInitSubmitItem()
	self:RefreshItemCountLimit()

	self.bindIdToConsumableId = {}

	for i = 0, ConsumableConfig.count - 1 do
		local cfg = ConsumableConfig.LoadAt(i)

		if cfg.BindId and cfg.BindId == 0 then
			self.bindIdToConsumableId[cfg.BindId] = cfg.Id
		end
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self:OnInit()
	end
end

M.GetTemplateId = function(self, data)
	if data.templateId then
		return data.templateId
	elseif data.TemplateId then
		return data.TemplateId
	elseif data.itemId then
		return data.itemId
	elseif data.ItemId then
		return data.ItemId
	elseif data.Id then
		return data.Id
	end
end

M.AddItem = function(self, itemId, count)
	local gm = require("LuaGen/AutoGen/GmToGamePlayerDelegate")
	local consumableId = self:TryConvertToConsumableId(itemId)

	if consumableId then
		gm:AddItem(consumableId, count)
	end
end

M.TryConvertToConsumableId = function(self, itemId)
	if ConsumableConfig.GetConfig(itemId) then
		return itemId
	end

	if FashionConfig.GetConfig(itemId) or FashionSuitConfig.GetConfig(itemId) then
		return self:FindConsumableIdByBindId(itemId)
	end

	if VehicleConfig.GetConfig(itemId) then
		return self:FindConsumableIdByBindId(itemId)
	end

	if SceneitemConfig.GetConfig(itemId) then
		return self:FindConsumableIdByBindId(itemId)
	end

	return nil
end

M.FindConsumableIdByBindId = function(self, bindId)
	return self.bindIdToConsumableId[bindId]
end

gCommonItemManager = gCommonItemManager or C_CommonItemManager.new()
