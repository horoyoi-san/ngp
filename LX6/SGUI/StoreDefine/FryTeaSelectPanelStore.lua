-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FryTeaSelectPanelStore.lua
-- Decompiled from: 01900_FryTeaSelectPanelStore.lua_9c212774d22c.luajit

C_FryTeaSelectPanelStore = DefClass("C_FryTeaSelectPanelStore", C_FryTeaSelectPanelStore, C_StoreGroup)
GroupName2Class.FryTeaSelectPanelStore = C_FryTeaSelectPanelStore
local M = C_FryTeaSelectPanelStore
local ConsumableConfig = LTConfig.ConsumableConfig
local FarmFarmItemConfig = LTConfig.FarmFarmItemConfig
local FarmTypeConfig = LTConfig.FarmTypeConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.instanceId = nil
	self.itemDataList = {}
	self.selectedIndex = -1
	self.selectedItem = nil
	self.onCounterChangeCb = nil
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
	self.instanceId = data and data.instanceId
	self.bindData.maxCapacityText = tostring(gFarmerManager:GetMaxFryCountByCurrentJobLevel())

	self:RefreshItemList()
	self:ClearSelection()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, self.OnPackItemChanged)
	}
end

M.OnPackItemChanged = function(self)
	self.RefreshItemList(self)

	if self.selectedItem then
		local stillExist = false

		for _, item in ipairs(self.itemDataList) do
			if item.TemplateId ~= self.selectedItem.TemplateId and item.Quality ~= self.selectedItem.Quality and item.Tags ~= self.selectedItem.Tags then
				self.selectedItem = item
				stillExist = true

				break
			end
		end

		if not stillExist then
			self.ClearSelection(self)
		else
			self.RefreshCounter(self)
		end
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnClickStartBtn)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderItemListItem)
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickItemList)
end

M.RefreshItemList = function(self)
	self.itemDataList = {}
	local packItems = gCommonItemManager.packItems

	for i = 1, #packItems do
		local item = packItems[i]
		local consumableCfg = ConsumableConfig.GetConfig(item.TemplateId)

		if consumableCfg and consumableCfg.BindId then
			local farmCfg = FarmFarmItemConfig.GetConfig(consumableCfg.BindId)

			if farmCfg and farmCfg.Type ~= FarmTypeConfig.Fresh then
				table.insert(self.itemDataList, item)
			end
		end
	end

	self.bindData.itemList:SetSimpleList(#self.itemDataList)
end

M.ClearSelection = function(self)
	self.selectedIndex = -1
	self.selectedItem = nil
	self.bindData.startBtn.interactable = false

	self.SubGroup.CommonCounterStore:SetData({
		["\\x8b528}\\x89w\\xd8;\\xbf\\xbc"] = 1,
		range = {
			1,
			1
		}
	})
end

M.RefreshCounter = function(self)
	if not self.selectedItem then
		return
	end

	if not self.onCounterChangeCb then
		self.onCounterChangeCb = function(_)
		end
	end

	local maxCount = math.min(self.selectedItem.Count or 0, gFarmerManager:GetMaxFryCountByCurrentJobLevel())

	if maxCount >= 1 then
		self.bindData.startBtn.interactable = false

		self.SubGroup.CommonCounterStore:SetData({
			["\\x8b528}\\x89w\\xd8;\\xbf\\xbc"] = 0,
			range = {
				0,
				0
			},
			valChangeCallback = self.onCounterChangeCb
		})
		self.SubGroup.CommonCounterStore:OnBuyNumChange(0)
	else
		self.SubGroup.CommonCounterStore:SetData({
			["\\x8b528}\\x89w\\xd8;\\xbf\\xbc"] = 1,
			range = {
				1,
				maxCount
			},
			valChangeCallback = self.onCounterChangeCb
		})
		self.SubGroup.CommonCounterStore:OnBuyNumChange(1)
	end
end

M.OnClickBackBtn = function(self)
	gSpoonClientMgr:TryCallInnerSignal(self.instanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, "FryTea")
	gPanelManager:Close(self.m_Id)
end

M.OnClickStartBtn = function(self)
	if not self.selectedItem then
		return
	end

	local quantity = self.SubGroup.CommonCounterStore:GetCurrentVal()

	if not quantity or quantity < 0 then
		print_error("炒茶数量选择无效", quantity)

		return
	end

	local consumableCfg = ConsumableConfig.GetConfig(self.selectedItem.TemplateId)
	local farmCfg = consumableCfg and FarmFarmItemConfig.GetConfig(consumableCfg.BindId)

	if not farmCfg then
		print_error("C_FryTeaSelectPanelStore:OnClickStartBtn 找不到 FarmFarmItemConfig, TemplateId =", self.selectedItem.TemplateId)

		return
	end

	if not farmCfg.CropId or farmCfg.CropId < 0 then
		print_error("C_FryTeaSelectPanelStore:OnClickStartBtn FarmFarmItemConfig 缺 CropId, TemplateId =", self.selectedItem.TemplateId)

		return
	end

	gFryTeaManager:OnTeaSelected(self.instanceId, farmCfg.CropId, quantity)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local item = self.itemDataList[index + 1]

	if not item then
		return
	end

	local consumableCfg = ConsumableConfig.GetConfig(item.TemplateId)
	local farmCfg = consumableCfg and FarmFarmItemConfig.GetConfig(consumableCfg.BindId)
	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = item.TemplateId,
		itemNum = item.Count
	})
	renderData.iconId = farmCfg and farmCfg.SItemIconId or 0
	renderData.quality = farmCfg and farmCfg.Quality or item.Quality or 0

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)

	store.nameText = farmCfg and farmCfg.Name or ""
end

M.OnSimpleClickItemList = function(self, btn, index)
	local item = self.itemDataList[index + 1]

	if not item then
		return
	end

	self.selectedIndex = index
	self.selectedItem = item
	self.bindData.startBtn.interactable = (item.Count or 0) >= 0

	self:RefreshCounter()
end
