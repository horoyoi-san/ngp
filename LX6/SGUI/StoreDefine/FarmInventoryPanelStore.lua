-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FarmInventoryPanelStore.lua
-- Decompiled from: 01851_FarmInventoryPanelStore.lua_02ac370ced58.luajit

C_FarmInventoryPanelStore = DefClass("C_FarmInventoryPanelStore", C_FarmInventoryPanelStore, C_StoreGroup)
GroupName2Class.FarmInventoryPanelStore = C_FarmInventoryPanelStore
local M = C_FarmInventoryPanelStore
local FarmFarmItemConfig = LTConfig.FarmFarmItemConfig
local FarmTypeConfig = LTConfig.FarmTypeConfig
local ConsumableConfig = LTConfig.ConsumableConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.targetSlotIndex = nil
	self.displayItemList = {}
	self.pendingAutoSelectFirst = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.isEmptyEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.ShowMainPageCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isEmptyEnum = nil
	self.ShowMainPageCtrlEnum = nil
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
	self.targetSlotIndex = data and data.slotIndex
	self.pendingAutoSelectFirst = data == nil and data.autoSelectFirst ~= true

	self:RefreshItemList()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, self.RefreshItemList)
	}
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.fullScreenBackBtn = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderItemListItem)
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickItemList)
end

M.RefreshItemList = function(self)
	self.displayItemList = {}

	for _, item in ipairs(gCommonItemManager.packItems) do
		local consumableCfg = ConsumableConfig.GetConfig(item.TemplateId)
		local farmCfg = consumableCfg and FarmFarmItemConfig.GetConfig(consumableCfg.BindId)
		local typeCfg = farmCfg and FarmTypeConfig.GetConfig(farmCfg.Type)

		if typeCfg and typeCfg.CanDirectSell then
			table.insert(self.displayItemList, {
				item = item,
				farmCfg = farmCfg
			})
		end
	end

	local isEmpty = #self.displayItemList ~= 0
	self.bindData.isEmpty = isEmpty and 1 or 0

	self.bindData.itemList:SetSimpleList(#self.displayItemList)
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local entry = self.displayItemList[index + 1]

	if not entry then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = entry.item.TemplateId,
		itemNum = entry.item.Count
	})
	renderData.iconId = entry.farmCfg.SItemIconId
	renderData.quality = entry.item.Quality or 0

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)

	btn.luaRenderTooltip = self:CreateActionWithArgs(self.OnRenderItemTooltip, entry)

	if index ~= 0 and self.pendingAutoSelectFirst then
		self.pendingAutoSelectFirst = false

		btn.OpenTooltip(btn, 0)
	end
end

M.OnSimpleClickItemList = function(self, btn, index)
	btn.OpenTooltip(btn, 0)
end

M.OnRenderItemTooltip = function(self, entry, btn, popup, popupIndex)
	local store = gStoreManager:GetStoreGroup(popup.Store)

	if not store then
		return
	end

	local item = entry.item
	local farmCfg = entry.farmCfg

	store.InitFarmItem(store, item, farmCfg)

	store.bindData.confirmBtn.luaClick = function()
		local count = store:GetCurrentVal()

		if not count or count < 0 then
			return
		end

		print_debug("[FarmShopApp] 请求上架 slotIndex=", self.targetSlotIndex, " itemId=", item.TemplateId, " quality=", item.Quality or 0, " count=", count, " price=", store:GetCurrentPrice())

		gClientToGameDelegate:AskFarmerShopPlaceItem(self.targetSlotIndex, item.TemplateId, item.Quality or 0, item.Tags or 0, count, store:GetCurrentPrice()).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				print_error("#NoCreateIssue [FarmInventoryPanelStore] AskFarmerShopPlaceItem 失败 errId=", err, " err=", gCS.Error.GetNameById(err))
			end
		end

		btn:CloseTooltip(true)
		gPanelManager:Close(gPanelId.FARM_INVENTORY_PANEL)
	end
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(gPanelId.FARM_INVENTORY_PANEL)
end
