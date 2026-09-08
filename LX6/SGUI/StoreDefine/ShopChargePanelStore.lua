-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopChargePanelStore.lua
-- Decompiled from: 01313_ShopChargePanelStore.lua_d51adeff61c4.luajit

local DropConfig = LTConfig.DropConfig
local ConsumableConfig = LTConfig.ConsumableConfig
C_ShopChargePanelStore = DefClass("C_ShopChargePanelStore", C_ShopChargePanelStore, C_StoreGroup)
GroupName2Class.ShopChargePanelStore = C_ShopChargePanelStore
local M = C_ShopChargePanelStore

M.ctor = function(self)
	self.chargeListData = {}
	self.hasShownEmptyStoreMsg = false
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootGo:GetComponent("UNavigationArea")
	self.panelId = panelId

	if gCS.LuaUtils.IsOnPS5 then
		self.hasShownEmptyStoreMsg = false
	end

	self.InitMoneyDisplay(self)
	self.InitChargeData(self)
	self.RefreshChargeList(self)
end

M.InitMoneyDisplay = function(self)
	if not self.SubGroup or not self.SubGroup.MoneyTemplateStore then
		return
	end

	self.SubGroup.MoneyTemplateStore:SetData({
		{
			Type = ConsumableConfig.RewardGold
		},
		{
			Type = ConsumableConfig.RewardBindingGold
		}
	})
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SHOU_CHONG_SUCCESS] = function ()
			self:OnChargeSuccess()
		end,
		[gEventConstants.SYNC_CHARGE_INFO] = function ()
			self:OnSyncChargeInfo()
		end
	}
end

M.OnChargeSuccess = function(self)
	self.InitChargeData(self)
	self.RefreshChargeList(self)
end

M.OnSyncChargeInfo = function(self)
	self.InitChargeData(self)
	self.RefreshChargeList(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.chargeList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderChargeListItem")
	self.bindData.chargeList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickChargeList")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderChargeListItem = function(self, btn, index)
	local chargeData = self.chargeListData[index + 1]

	if not chargeData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.bgIconId = chargeData.bgIconId or 0
		btn.interactable = true

		if gCS.LuaUtils.IsOnPS5 then
			local ps5Price = LX6.Utils.PS5Utils.GetStoreProductPriceById(chargeData.id)

			if ps5Price then
				store.priceText = ps5Price
			else
				store.priceText = string.format("¥%.2f", chargeData.price or 0)
			end

			local inventory = LX6.Utils.PS5Utils.GetStoreProductInventoryById(chargeData.id)

			if inventory ~= 0 then
				if not self.hasShownEmptyStoreMsg then
					LX6.Utils.PS5Utils.ShowEmptyStoreMsgBox()
				end

				self.hasShownEmptyStoreMsg = true
				btn.interactable = false
			end
		else
			store.priceText = string.format("¥%.2f", chargeData.price or 0)
		end

		store.amountText = tostring(chargeData.gold or 0)
		store.firstChargeCtrl = chargeData.hasFirstCharge and 1 or 0

		if chargeData.hasFirstCharge then
			store.firstChargeText = chargeData.firstChargeText or ""
		end

		store.extraCtrl = chargeData.hasExtra and 1 or 0

		if chargeData.hasExtra then
			store.extraText = string.format(LTConfig.TextConfig.GetConfig(73970807).Text, chargeData.extraGold or 0)
		end
	end
end

M.OnSimpleClickChargeList = function(self, btn, index)
	local chargeData = self.chargeListData[index + 1]

	if not chargeData then
		return
	end

	if string.is_null_or_empty(chargeData.goodsId) then
		return
	end

	self:OnCheckOrder()
	gMallManager:CheckOrder(chargeData.id, 1, "")
end

M.OnCheckOrder = function(self)
end

M.IsChargeIdCharged = function(self, chargeId)
	local chargeInfo = gPlayerManager.infoMinor.bindData.ChargeInfo

	for _, id in ipairs(chargeInfo.ChargedIds) do
		if id ~= chargeId then
			return true
		end
	end

	return false
end

M.GetFirstChargeDropText = function(self, dropId)
	if not dropId or dropId ~= 0 then
		return ""
	end

	local dropCfg = DropConfig.GetConfig(dropId)

	if not dropCfg then
		return ""
	end

	if dropCfg.BindingGold and dropCfg.BindingGold == 0 then
		return string.format(LTConfig.TextConfig.GetConfig(73970803).Text, dropCfg.BindingGold)
	end

	return ""
end

M.InitChargeData = function(self)
	self.chargeListData = gMallManager:BuildAllChargeData()
end

M.RefreshChargeList = function(self)
	self.bindData.chargeList:SetSimpleList(#self.chargeListData)
end
