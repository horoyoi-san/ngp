local MessageConfig = LTConfig.MessageConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local MoneyType = UX.Game.MoneyType
C_MoneyTemplateStore = DefClass("C_MoneyTemplateStore", C_MoneyTemplateStore, C_StoreGroup)
GroupName2Class.MoneyTemplateStore = C_MoneyTemplateStore
local MoneyTemplateStore = C_MoneyTemplateStore

function MoneyTemplateStore:ctor()
	return
end

function MoneyTemplateStore:OnAwake()
	self.moneyList = {}
	self.handler = self:CreateAction("RefreshMoney")
	self.msgEvents = {
		[gEventConstants.SPIRIT_FRAGMENT_POINT_CHANGE] = self.handler,
		[gEventConstants.PACK_ITEM_CHANGED] = self.handler
	}
	self.dataSetEvents = {
		{
			gPlayerManager.infoItem.bindData,
			"money",
			self.handler
		},
		{
			gPlayerManager.infoItem.bindData,
			"gold",
			self.handler
		},
		{
			gPlayerManager.infoItem.bindData,
			"bindGold",
			self.handler
		}
	}

	self:RegisterMessageEvents(self.msgEvents)
	self:RegisterDataSetEvents(self.dataSetEvents)

	self.bindData.moneyList.luaSimpleRenderItem = self:CreateAction("OnRenderItem")

	self:InitShowAddMoney()
end

function MoneyTemplateStore:OnDestroy()
	self:ClearDataSetEvents()
	self:ClearMessageEvents()

	self.moneyList = nil
	self.item = nil
	self.handler = nil
end

function MoneyTemplateStore:SetData(msg)
	self.item = {}

	if msg == nil then
		print_error("未传入货币类型")

		return
	end

	local type = type(msg)

	if type == "number" then
		table.insert(self.item, {
			Type = msg
		})
	elseif type == "table" then
		self.item = msg
	else
		print_error("传的参数能不能再奇葩点")

		return
	end

	self:InitMoney()
end

function MoneyTemplateStore:InitShowAddMoney()
	local showAddMoney = ConsumableConfig.MoneyType
	self.ShowAddMoneyType = {}
	self.ShowAddMoneyId = {}

	for i = 1, #showAddMoney do
		table.insert(self.ShowAddMoneyType, showAddMoney[i].Type)
		table.insert(self.ShowAddMoneyId, showAddMoney[i].ConsumableID)
	end
end

function MoneyTemplateStore:InitMoney()
	self.moneyList = {}

	if self.item == nil then
		return
	end

	for i = 1, #self.item do
		local view = {}
		local item = self.item[i]
		view.templateId = table.contains(MoneyType, item.Type) and gUIUtils:GetMoneyConsumableId(item.Type) or item.Type
		view.disabled = item.DisableInteract
		local cfg = ConsumableConfig.GetConfig(view.templateId)

		if cfg then
			view.imageIcon = cfg.SMoneyIconId
		end

		view.isShowAdd = not item.DisableInteract and table.contains(self.ShowAddMoneyId, view.templateId) and gCommonItemManager.enableExchange
		local value = gPlayerItemManager:GetPackItemNum(view.templateId)
		view.count = view.templateId == ConsumableConfig.RewardMoney and gUIUtils:FormatMoney(value) or value
		view.tIndex = view.isShowAdd and 1 or 0

		table.insert(self.moneyList, view)
	end

	self.bindData.moneyList:SetSimpleList(#self.moneyList)
end

function MoneyTemplateStore:OnRenderItem(btn, index)
	local store = gStoreManager:GetStoreGroup("MoneyTemplateStore"):GetStoreByWidget(btn)
	local data = self.moneyList[index + 1]

	if store and data then
		store.count = data.count
		store.imageIcon = data.imageIcon
		store.iconButton.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", data, gCommonItemManager)

		if data.tIndex == 1 then
			store.button.luaClick = self:CreateActionWithArgs("ClickMoneyItem", data)
		end
	end
end

function MoneyTemplateStore:CheckMallUnlock()
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.ShopUnlock) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MallLock)

		return false
	end

	return true
end

function MoneyTemplateStore:ClickMoneyItem(item)
	if item == nil then
		return
	end

	if item.templateId == ConsumableConfig.RewardBindingGold then
		if not self:CheckMallUnlock() then
			return
		end
	elseif item.templateId == ConsumableConfig.RewardMoney then
		if not self:CheckMallUnlock() then
			return
		end

		local bindGoldCount = gPlayerItemManager:GetPackItemNum(ConsumableConfig.RewardBindingGold)

		if bindGoldCount > 0 then
			gCommonItemManager:ExchangeMoney(MoneyType.Money)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.GoldToMall, function ()
				return
			end)
		end
	elseif item.templateId == ConsumableConfig.RewardGold then
		if not self:CheckMallUnlock() then
			return
		end

		local bindGoldCount = gPlayerItemManager:GetPackItemNum(ConsumableConfig.RewardBindingGold)

		if bindGoldCount > 0 then
			gCommonItemManager:ExchangeMoney(MoneyType.Gold)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.GoldToMall, function ()
				return
			end)
		end
	end
end

function MoneyTemplateStore:ShowItemInfo(item)
	if item == nil then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemId = item.templateId
	})
end

function MoneyTemplateStore:RefreshMoney()
	for i = 1, #self.moneyList do
		local item = self.moneyList[i]
		local value = gPlayerItemManager:GetPackItemNum(item.templateId)
		item.count = item.templateId == ConsumableConfig.RewardMoney and gUIUtils:FormatMoney(value) or value
	end

	self.bindData.moneyList:SetSimpleList(#self.moneyList)
end
