-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ItemDeliveryPanelStore.lua
-- Decompiled from: 01779_ItemDeliveryPanelStore.lua_47bea3828795.luajit

local SubmitItemEventConfig = LTConfig.SubmitItemEventConfig
local ExtractionShooterConfig = LTConfig.ExtractionShooterConfig
local BOOL2CTL = gClientConst.BOOL2CTL
C_ItemDeliveryPanelStore = DefClass("C_ItemDeliveryPanelStore", C_ItemDeliveryPanelStore, C_StoreGroup)
GroupName2Class.ItemDeliveryPanelStore = C_ItemDeliveryPanelStore
local M = C_ItemDeliveryPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.submitEventId = 0
	self.submitItemList = {}
	self.canSubmit = false
	self.bringInItemList = {}
	self.selectedUniqueIds = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.hasEnoughCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.hasEnoughCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if not data then
		print_warn("ItemDeliveryPanelStore OnShow invalid data")
		self.ClosePanel(self)

		return
	end

	if data.bringInMode then
		if not data.gamePlayTypeId then
			print_warn("ItemDeliveryPanelStore OnShow bringInMode 缺少 gamePlayTypeId")
			self.ClosePanel(self)

			return
		end

		self.mode = "bringIn"
		self.gamePlayTypeId = data.gamePlayTypeId

		self.RefreshBringInPage(self)

		return
	end

	if not data.submitEventId then
		print_warn("ItemDeliveryPanelStore OnShow invalid data")
		self.ClosePanel(self)

		return
	end

	self.submitEventId = data.submitEventId
	self.mode = "submit"

	self.RefreshPage(self)
end

M.OnClose = function(self)
	self.submitEventId = 0
	self.submitItemList = {}
	self.bringInItemList = {}
	self.selectedUniqueIds = {}
	self.mode = nil
	self.gamePlayTypeId = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SUBMIT_ITEM_STATE_CHANGED] = self.CreateAction(self, "OnSubmitItemStateChanged"),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged")
	}
end

M.OnSubmitItemStateChanged = function(self)
	self.RefreshPage(self)
end

M.OnPackItemChanged = function(self)
	if self.mode ~= "bringIn" then
		self:BuildBringInItemList()
		self:RefreshBringInHasEnough()
		self.bindData.itemList:SetSimpleList(#self.bringInItemList)

		return
	end

	self.RefreshItemList(self)
	self.RefreshHasEnough(self)
end

M.RegisterWidget = function(self)
	self.bindData.backGround.luaClick = self.CreateAction(self, self.OnClickBackGround)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.submitBtn.luaClick = self.CreateAction(self, self.OnClickSubmitBtn)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderItemListItem)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickBackGround = function(self)
	self.ClosePanel(self)
end

M.OnClickBackBtn = function(self)
	self.ClosePanel(self)
end

M.OnClickSubmitBtn = function(self)
	if not self.canSubmit then
		if gCommonItemManager:GetSubmitItemCDRemaining(self.submitEventId) <= 0 then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SubmitItemCDNotReady)
		elseif gCommonItemManager:GetSubmitItemRemainingTimes(self.submitEventId) ~= 0 then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SubmitItemCountMax)
		end

		return
	end

	slot1 = gCommonItemManager

	slot1:AskSubmitItemAuto(self.submitEventId, function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			self:ClosePanel()
		end
	end)
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local info = self.submitItemList[index + 1]

	if not info then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = info.configId,
		itemNum = info.displayNum
	})

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)
end

M.RefreshPage = function(self)
	local cfg = SubmitItemEventConfig.GetConfig(self.submitEventId)

	if not cfg then
		print_warn("ItemDeliveryPanelStore RefreshPage config not found", self.submitEventId)
		self.ClearUI(self)

		return
	end

	self.bindData.itemDescLabel = cfg.EventName or ""

	self:BuildSubmitItemList(cfg)
	self:RefreshHasEnough()
	self:RefreshItemList()
end

M.BuildSubmitItemList = function(self, cfg)
	self.submitItemList = {}
	local items = cfg.SubmitItem

	if not items or #items ~= 0 then
		return
	end

	for i = 1, #items do
		local item = items[i]
		local configId = item.BindId or 0
		local needCount = item.num or 0
		local ownCount = gCommonItemManager:GetPackItemNum(configId)
		local displayNum = ownCount >= needCount and "#R" .. ownCount .. "#z/" .. needCount or ownCount .. "/" .. needCount

		table.insert(self.submitItemList, {
			configId = configId,
			needCount = needCount,
			ownCount = ownCount,
			displayNum = displayNum
		})
	end
end

M.RefreshHasEnough = function(self)
	local hasEnough = self:CheckHasEnough()
	self.bindData.hasEnoughCtrl = BOOL2CTL[hasEnough]
	local canSubmit = hasEnough and gCommonItemManager:CanSubmitItem(self.submitEventId)
	self.canSubmit = canSubmit
	self.bindData.submitBtn.interactable = canSubmit
end

M.CheckHasEnough = function(self)
	for i = 1, #self.submitItemList do
		local info = self.submitItemList[i]

		if info.ownCount >= info.needCount then
			return false
		end
	end

	return #self.submitItemList >= 0
end

M.RefreshItemList = function(self)
	for i = 1, #self.submitItemList do
		local info = self.submitItemList[i]
		info.ownCount = gCommonItemManager:GetPackItemNum(info.configId)
		info.displayNum = info.ownCount >= info.needCount and "#R" .. info.ownCount .. "#z/" .. info.needCount or info.ownCount .. "/" .. info.needCount
	end

	self.bindData.itemList:SetSimpleList(#self.submitItemList)
end

M.ClearUI = function(self)
	self.submitItemList = {}
	self.canSubmit = false
	self.bindData.itemDescLabel = ""
	self.bindData.hasEnoughCtrl = BOOL2CTL[false]
	self.bindData.submitBtn.interactable = false

	self.bindData.itemList:SetSimpleList(0)
end

M.BuildBringInItemList = function(self)
	self.bringInItemList = {}

	for _, packItem in ipairs(gCommonItemManager.packItems) do
		local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(packItem.TemplateId)

		if itemCfg then
			local typeCfg = LTConfig.ExtractionShooterItemTypeConfig.GetConfig(itemCfg.Type)

			if typeCfg and typeCfg.CanBringFromOpenWorld then
				table.insert(self.bringInItemList, packItem)
			end
		end
	end
end

M.RefreshBringInPage = function(self)
	self:BuildBringInItemList()

	self.selectedUniqueIds = {}
	self.bindData.itemDescLabel = "选择需要带入战备仓库的物品"
	self.bindData.submitBtnTitle = ExtractionShooterConfig.MoveItem

	self:RefreshBringInHasEnough()

	self.bindData.submitBtn.luaClick = self:CreateAction("OnClickBringInSubmitBtn")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderBringInItem")

	self.bindData.itemList:SetSimpleList(#self.bringInItemList)
end

M.GetUsableStashBagIds = function(self)
	local mainStashId = gExtractionShooterManager.GetBagStoreSet(self.gamePlayTypeId).inventory
	local info = gExtractionShooterManager.GetExtractionShooterInfo()
	local unlockedBagIds = info and info.UnlockedBagIds or {}
	local bagIds = {}

	for _, bagId in ipairs(gExtractionShooterManager:GetTarkovStashBagConfigIds(self.gamePlayTypeId)) do
		if bagId ~= mainStashId or unlockedBagIds[bagId] then
			table.insert(bagIds, bagId)
		end
	end

	return bagIds
end

M.CheckCanMoveToStash = function(self)
	local itemsToAdd = {}

	for uniqueId in pairs(self.selectedUniqueIds) do
		local packItem = gCommonItemManager.packItemDict[uniqueId]

		if packItem then
			itemsToAdd[packItem.TemplateId] = (itemsToAdd[packItem.TemplateId] or 0) + packItem.Count
		end
	end

	local ctxList = {}

	for _, bagId in ipairs(self.GetUsableStashBagIds(self)) do
		table.insert(ctxList, gExtractionShooterUtils.BuildBagContextByConfigId(bagId))
	end

	return gExtractionShooterUtils.CheckCanAddItems(ctxList, itemsToAdd) ~= LTConfig.MessageConfig.Ok
end

M.RefreshBringInHasEnough = function(self)
	local hasSelection = next(self.selectedUniqueIds) == nil
	self.canSubmit = hasSelection and self:CheckCanMoveToStash()
	self.bindData.hasEnoughCtrl = BOOL2CTL[self.canSubmit]
	self.bindData.submitBtn.interactable = self.canSubmit

	if not hasSelection then
		self.bindData.notEnoughBtnTitle = ExtractionShooterConfig.ChooseMoveItem
	else
		self.bindData.notEnoughBtnTitle = ExtractionShooterConfig.CannotMoveToExBag
	end
end

M.OnSimpleRenderBringInItem = function(self, btn, index)
	local packItem = self.bringInItemList[index + 1]

	if not packItem then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = packItem.TemplateId,
		itemNum = packItem.Count
	})

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)

	store.isOwned = self.selectedUniqueIds[packItem.UniqueId] and 1 or 0

	btn.luaClick = function()
		if self.selectedUniqueIds[packItem.UniqueId] then
			self.selectedUniqueIds[packItem.UniqueId] = nil
		else
			local maxNum = ExtractionShooterConfig.MoveItemPerMaxNum

			if maxNum < table.count(self.selectedUniqueIds) then
				gDisplayMessageMgr:ShowMessageContent(string.format("单次最多只能转移 %d 个物品", maxNum))

				return
			end

			self.selectedUniqueIds[packItem.UniqueId] = true
		end

		self:RefreshBringInHasEnough()
		self.bindData.itemList:RefreshList()
	end
end

M.OnClickBringInSubmitBtn = function(self)
	if not self.canSubmit then
		if next(self.selectedUniqueIds) ~= nil then
			gDisplayMessageMgr:ShowMessageContent(ExtractionShooterConfig.ChooseMoveItem)
		else
			gDisplayMessageMgr:ShowMessageContent(ExtractionShooterConfig.CannotMoveToExBag)
		end

		return
	end

	local itemList = {}

	for uniqueId, _ in pairs(self.selectedUniqueIds) do
		local packItem = gCommonItemManager.packItemDict[uniqueId]

		if packItem then
			table.insert(itemList, {
				itemId = packItem.TemplateId,
				itemNum = packItem.Count
			})
		end
	end

	gDisplayMessageMgr:ShowBomb({
		["\\xd0\\xc8=1\\xe5"] = false,
		msgType = gDisplayMessageId.SELECT,
		costItemList = itemList,
		costText = ExtractionShooterConfig.MoveItmeFromOutsideCheck,
		btnConfirmCallback = function ()
			self:DoBringInItems()
		end
	})
end

M.DoBringInItems = function(self)
	local items = {}

	for uniqueId, _ in pairs(self.selectedUniqueIds) do
		local packItem = gCommonItemManager.packItemDict[uniqueId]

		if packItem then
			local consumableId = packItem.TemplateId
			local count = packItem.Count

			if consumableId and count and count <= 0 then
				items[consumableId] = (items[consumableId] or 0) + count
			end
		end
	end

	if not next(items) then
		self.ClosePanel(self)

		return
	end

	if not gClientToGameDelegate.AskBringInItems then
		self.ClosePanel(self)

		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskBringInItems(items).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end

		self:ClosePanel()
	end
end
