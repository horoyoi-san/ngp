-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FarmShopAppOrderPageStore.lua
-- Decompiled from: 01887_FarmShopAppOrderPageStore.lua_876e97fc6a8d.luajit

C_FarmShopAppOrderPageStore = DefClass("C_FarmShopAppOrderPageStore", C_FarmShopAppOrderPageStore, C_StoreGroup)
GroupName2Class.FarmShopAppOrderPageStore = C_FarmShopAppOrderPageStore
local M = C_FarmShopAppOrderPageStore
local FarmConfig = LTConfig.FarmConfig
local FarmOrderConfig = LTConfig.FarmOrderConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local AgentConfig = LTConfig.AgentConfig
local FarmFarmItemConfig = LTConfig.FarmFarmItemConfig
local TaskConfig = LTConfig.TaskConfig
local ORDER_STATE_CTRL = gFarmerManager.ORDER_STATE_CTRL
local TAB_CONFIG = {
	{
		title = FarmConfig.OrderTab[1]
	},
	{
		title = FarmConfig.OrderTab[2],
		filterStates = {
			[ORDER_STATE_CTRL.awaitingAccept] = true
		}
	},
	{
		title = FarmConfig.OrderTab[3],
		filterStates = {
			[ORDER_STATE_CTRL.awaitingShipment] = true,
			[ORDER_STATE_CTRL.Shipping] = true
		}
	},
	{
		title = FarmConfig.OrderTab[4],
		filterStates = {
			[ORDER_STATE_CTRL.orderCompleted] = true,
			[ORDER_STATE_CTRL.expired] = true
		}
	}
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.allOrderDataList = {}
	self.displayOrderDataList = {}
	self.currentTabIndex = 0
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

M.ShowPanel = function(self)
	self.RefreshOrderList(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.FARMER_ORDER_CHANGED] = self.CreateAction(self, self.OnOrderChanged),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, self.OnPackItemChanged)
	}
end

M.RegisterWidget = function(self)
	self.bindData.orderList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderOrderListItem)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTabListItem)
	self.bindData.orderList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickOrderList)
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTabList)
end

local endReasonToState = {
	[0] = ORDER_STATE_CTRL.orderCompleted,
	ORDER_STATE_CTRL.expired
}
local ORDER_STATE = gFarmerManager.ORDER_STATE

M.BuildOrderDataList = function(self)
	self.allOrderDataList = {}

	for configId, orderInfo in pairs(gFarmerManager.orders) do
		local cfg = FarmOrderConfig.GetConfig(configId)

		if cfg then
			local itemCfg = ConsumableConfig.GetConfig(cfg.RequireItemId)
			local state, expireTime = nil

			if orderInfo.State ~= ORDER_STATE.Active then
				state = ORDER_STATE_CTRL.awaitingAccept
				expireTime = orderInfo.ExpireTime
			elseif orderInfo.State ~= ORDER_STATE.Executing then
				state = ORDER_STATE_CTRL.awaitingShipment
				expireTime = orderInfo.ExpireTime
			else
				state = endReasonToState[orderInfo.EndReason] or ORDER_STATE_CTRL.expired
			end

			table.insert(self.allOrderDataList, {
				configId = configId,
				expireTime = expireTime,
				cfg = cfg,
				itemCfg = itemCfg,
				farmCfg = itemCfg and FarmFarmItemConfig.GetConfig(itemCfg.BindId),
				agentCfg = AgentConfig.GetConfig(cfg.AgentId),
				inventoryCount = state ~= ORDER_STATE_CTRL.awaitingAccept and gFarmerManager:CountOrderInventory(cfg.RequireItemId, cfg.RequireQuality) or 0,
				state = state
			})
		end
	end
end

M.ApplyTabFilter = function(self)
	local filterStates = TAB_CONFIG[self.currentTabIndex + 1].filterStates

	if filterStates ~= nil then
		self.displayOrderDataList = self.allOrderDataList

		return
	end

	self.displayOrderDataList = {}

	for _, order in ipairs(self.allOrderDataList) do
		if filterStates[order.state] then
			table.insert(self.displayOrderDataList, order)
		end
	end
end

M.GetTabCount = function(self, tabIndex)
	local filterStates = TAB_CONFIG[tabIndex + 1].filterStates

	if filterStates ~= nil then
		return #self.allOrderDataList
	end

	local count = 0

	for _, order in ipairs(self.allOrderDataList) do
		if filterStates[order.state] then
			count = count + 1
		end
	end

	return count
end

M.RefreshOrderList = function(self)
	self:BuildOrderDataList()
	self:ApplyTabFilter()
	self.bindData.orderList:SetSimpleList(#self.displayOrderDataList)
	self.bindData.tabList:SetSimpleList(#TAB_CONFIG)
	self.bindData.tabList:SetItemSelected(self.currentTabIndex, true)
end

M.OnOrderChanged = function(self)
	self.RefreshOrderList(self)
end

M.OnPackItemChanged = function(self)
	self.RefreshOrderList(self)
end

M.OnSimpleRenderOrderListItem = function(self, btn, index)
	local orderData = self.displayOrderDataList[index + 1]

	if not orderData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = orderData.cfg
	local itemCfg = orderData.itemCfg
	local agentCfg = orderData.agentCfg
	store.nameText = itemCfg and itemCfg.Name or ""
	store.moneyText = tostring(cfg.Reward)
	store.requireCountText = tostring(cfg.RequireCount)
	store.inventoryCountText = tostring(orderData.inventoryCount)
	store.consigneeNameText = agentCfg and agentCfg.Name or ""
	store.consigneeAvatarIconId = agentCfg and agentCfg.HeadIcon or 0
	store.refreshTimeText = gFarmerManager:FormatOrderRemainingTime(orderData.expireTime)
	local orderStateCtrl = orderData.state
	store.orderStateCtrl = orderStateCtrl
	store.orderTypeCtrl = cfg.IsSpecial ~= FarmOrderConfig.IsSpecialType.Monsterfram and 1 or 0
	store.deliveryTypeCtrl = gFarmerManager:GetDeliveryTypeByOrderType(cfg.DeliveryOrder)
	store.showAddressCtrl = 1
	store.takeOrderBtn.interactable = gFarmerManager:CanTakeOrder(orderData)
	store.takeOrderBtn.luaClick = self:CreateActionWithArgs(self.OnClickTakeOrderBtn, orderData)

	if orderStateCtrl ~= ORDER_STATE_CTRL.awaitingShipment then
		store.deliveryBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickDeliveryBtn, orderData)
	else
		store.deliveryBtn.luaClick = nil
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = cfg.RequireItemId,
		itemNum = cfg.RequireCount
	})
	renderData.iconId = orderData.farmCfg and orderData.farmCfg.SItemIconId or renderData.iconId

	gCommonItemManager:OnCommonItemRender(store.commonItemWidget, 0, renderData)
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local tabCfg = TAB_CONFIG[index + 1]
	store.titleText = tabCfg.title
	store.countText = tostring(self.GetTabCount(self, index))
end

M.OnSimpleClickOrderList = function(self, btn, index)
end

M.OnSimpleClickTabList = function(self, btn, index)
	if self.currentTabIndex ~= index then
		return
	end

	self.bindData.tabList:SetItemSelected(index, true)

	self.currentTabIndex = index

	self:ApplyTabFilter()
	self.bindData.orderList:SetSimpleList(#self.displayOrderDataList)
end

M.OnClickTakeOrderBtn = function(self, orderData)
	if not gFarmerManager:CanTakeOrder(orderData) then
		return
	end

	print_debug("[FarmShopApp] 请求接单 orderConfigId=", orderData.configId)

	slot2 = gClientToGameDelegate

	slot2:AskFarmerCompleteOrder(orderData.configId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			print_error("#NoCreateIssue [FarmShopAppOrderStore] AskFarmerCompleteOrder 失败 errId=", err, " err=", gCS.Error.GetNameById(err))
		end
	end
end

M.OnClickDeliveryBtn = function(self, orderData)
	if not orderData.cfg.EventId then
		print_error("[FarmShopApp] 订单配置缺少 EventId，无法跳转地图界面 orderConfigId=", orderData.configId)

		return
	end

	local eventCfg = LTConfig.TaskEventConfig.GetConfig(orderData.cfg.EventId)

	if not eventCfg or not eventCfg.StartTask then
		print_error("[FarmShopApp] 订单配置的 EventId 无效，无法跳转地图界面 orderConfigId=", orderData.configId, " eventId=", orderData.cfg.EventId)

		return
	end

	local taskId = eventCfg.StartTask
	local cfg = TaskConfig.GetConfig(taskId)
	local gpsId = nil

	if cfg and array.contains(cfg.Tags, TaskConfig.TagsType.WasherTask) then
		local gpsInfoIds = L18.Spoon.Task.TaskManager.Instance:GetTaskGpsInfoIds(taskId):ToTable()
		gpsId = gpsInfoIds and gpsInfoIds[1]
	else
		gpsId = gMapSubSystem_Task:GetFirstGpsIdByTaskId(taskId)
	end

	if not gpsId then
		print_error("[FarmShopApp] 订单配置的 EventId 无法找到对应的 GPS 点，无法跳转地图界面 orderConfigId=", orderData.configId, " eventId=", orderData.cfg.EventId, " taskId=", taskId)

		return
	end

	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = LTConfig.RaidConfig.WorldMap,
		autoSelectGpsId = gpsId
	})
end
