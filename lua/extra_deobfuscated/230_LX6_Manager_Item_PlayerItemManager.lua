local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local MessageConfig = LTConfig.MessageConfig
local UnitState = UX.Game.TwoDimConfig.UnitState
local ItemReason = UX.Game.ItemReason
local MapentranceConfig = LTConfig.MapentranceConfig
local M = {
	subTypes = {
		{},
		{},
		{},
		ConsumableConfig.packTab3SubType,
		ConsumableConfig.packTab4SubType,
		ConsumableConfig.packTab5SubType,
		ConsumableConfig.packTab6SubType,
		ConsumableConfig.packTab7SubType
	},
	packTabItems = {
		{},
		{},
		{},
		{},
		{},
		{},
		{},
		{}
	},
	packItems = {},
	foodMaterials = {},
	foodMaterialsMapping = {},
	lifeSkillItems = {},
	lifeSkillItemsMapping = {},
	notShowMessageType = {
		[ItemReason.Charge] = true,
		[ItemReason.Mail] = true,
		[ItemReason.RaidReward] = true,
		[ItemReason.TaskEvent] = true,
		[ItemReason.SignIn] = true,
		[ItemReason.Mall] = true,
		[ItemReason.Achievement] = true,
		[ItemReason.UseItem] = true,
		[ItemReason.FirstCharge] = true,
		[ItemReason.NpcCultivationFavor] = true,
		[ItemReason.Task] = true,
		[ItemReason.Collection] = true,
		[ItemReason.Challenge] = true,
		[ItemReason.NpcChatReward] = true,
		[ItemReason.RecycleItem] = true,
		[ItemReason.Gallery] = true,
		[ItemReason.ClawMachine] = true,
		[ItemReason.CompoundItem] = true,
		[ItemReason.Enemy] = true
	},
	OtherItemType = {},
	SpecialItemChangeType = {
		Delete = 0,
		Update = 1,
		Add = 2
	},
	SpecialCurrencyItemId = {
		ConsumableConfig.RewardExp,
		ConsumableConfig.RewardMoney,
		ConsumableConfig.RewardBindingGold,
		ConsumableConfig.RewardGold
	},
	SpecialItemId = {
		ConsumableConfig.RewardMoney,
		ConsumableConfig.RewardBindingGold,
		ConsumableConfig.RewardGold
	},
	CannotHoldMessageId = {
		Default = MessageConfig.SystemlinkBagFull,
		LiaoLi = MessageConfig.BagLiaoliFull,
		LifeSkill = MessageConfig.BagLifeSkillFull,
		LifeSkillMaterial = MessageConfig.BagLifeSkillMaterialFull,
		Ling = MessageConfig.BagLingpeiyangFull,
		Weapon = MessageConfig.BagWeaponFull,
		Matrix = MessageConfig.BagMatrixFull,
		CanHold = MessageConfig.Ok
	},
	prevPackTab = 1,
	prevPackSubTab = 1,
	prevItemsSort = {},
	lingPeiYangSubType = {
		ConsumableTypeConfig.LingPeiYang,
		ConsumableTypeConfig.CharacterLevel,
		ConsumableTypeConfig.CharacterBreakthrough,
		ConsumableTypeConfig.WeaponLevel,
		ConsumableTypeConfig.WeaponBreakthrough,
		ConsumableTypeConfig.CharacterSkillUpgrade
	},
	GetPrevItemsSort = function (self, index)
		local indexStr = tostring(index)

		if self.prevItemsSort[indexStr] == nil then
			self.prevItemsSort[indexStr] = {
				order = false,
				type = 1
			}
		end

		return self.prevItemsSort[indexStr]
	end,
	SetPrevItemsSort = function (self, index, type, order)
		local itemsSort = self:GetPrevItemsSort(index)
		itemsSort.type = type or 1
		itemsSort.order = order or false
	end,
	OnInit = function (self)
		self.OtherItemType = {}
		self.packItemDict = {}
		self.redDotHideList = {}

		for i = 1, #ConsumableConfig.OtherItemTypes do
			local subType = ConsumableTypeConfig[ConsumableConfig.OtherItemTypes[i]]

			if subType then
				table.insert(self.OtherItemType, subType)
			end
		end
	end,
	SetPlayerInfoItem = function (self, infoItem)
		self.packItems = {}
		self.packItemDict = {}
		self.packTabItems = {
			{},
			{},
			{},
			{},
			{},
			{},
			{},
			{}
		}
		gPlayerManager.infoItem.pack.lingScrollPacks = {}
		gPlayerManager.infoItem.pack.lingPeiYangPacks = {}
		gPlayerManager.infoItem.pack.otherItems = {}
		local otherItemChanged = false

		for i = 1, infoItem.PackItems.Length do
			local packItem = infoItem.PackItems[i]
			local itemCfg = ConsumableConfig.GetConfig(packItem.TemplateId)

			if itemCfg == nil then
				print_error("仓库里有物品找不到对应配表，ConsumableConfig，TemplateId=", packItem.TemplateId)
			else
				table.insert(self.packItems, packItem)

				self.packItemDict[packItem.UniqueId] = packItem
				local isOtherItem = self:SetItemToSubPack(packItem, itemCfg)
				local tabIndex = self:GetPackTabByTemplateId(packItem.TemplateId)

				if tabIndex and self.packTabItems[tabIndex] ~= nil then
					table.insert(self.packTabItems[tabIndex], packItem)
				else
					print_error("[PlayerItemManager] 背包中tab物品增加失败，TemplateId=", packItem.TemplateId)
				end

				otherItemChanged = otherItemChanged or isOtherItem
			end
		end

		gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)

		if otherItemChanged then
			gMessageManager:SendMessage(gEventConstants.OTHER_ITEM_CHANGED)
		end
	end,
	SetPackItem = function (self, addList, updateList, deleteList, reason)
		local updateDict = {}
		local otherItemChanged = false

		if #deleteList > 0 then
			for i = #self.packItems, 1, -1 do
				for j = 1, #deleteList do
					if self.packItems[i].UniqueId == deleteList[j].UniqueId then
						updateDict[self.packItems[i].UniqueId] = self.packItems[i].TemplateId
						self.packItemDict[self.packItems[i].UniqueId] = nil
						local packTabIndex = self:GetPackTabByTemplateId(self.packItems[i].TemplateId)

						if packTabIndex then
							array.remove(self.packTabItems[packTabIndex], self.packItems[i])
						end

						table.remove(self.packItems, i)

						deleteList[j].Count = 0
						otherItemChanged = self:SetItemToSubPack(deleteList[j]) or otherItemChanged

						break
					end
				end
			end
		end

		if #updateList > 0 then
			for i = 1, #updateList do
				local prevData = self.packItemDict[updateList[i].UniqueId]

				if prevData == nil then
					print_error("#NoCreateIssue 客户端不存在UniqueId=", updateList[i].UniqueId, "的物品，TemplateId=", updateList[i].TemplateId)

					break
				end

				self:UpdateItemData(updateList[i], prevData)

				updateDict[updateList[i].UniqueId] = updateList[i].TemplateId
				otherItemChanged = self:SetItemToSubPack(updateList[i]) or otherItemChanged
			end
		end

		for i = 1, #addList do
			table.insert(self.packItems, addList[i])

			self.packItemDict[addList[i].UniqueId] = addList[i]
			local packTabIndex = self:GetPackTabByTemplateId(addList[i].TemplateId)

			if packTabIndex and self.packTabItems[packTabIndex] ~= nil then
				table.insert(self.packTabItems[packTabIndex], addList[i])
			else
				print_error("[PlayerItemManager] 背包中tab物品增加失败，TemplateId=", addList[i].TemplateId)
			end

			otherItemChanged = self:SetItemToSubPack(addList[i]) or otherItemChanged
		end

		if otherItemChanged then
			gMessageManager:SendMessage(gEventConstants.OTHER_ITEM_CHANGED)
		end

		gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED, {
			addList = addList,
			updateDict = updateDict,
			changeType = gPackagePanelManager.itemType.Item
		})
	end,
	SetPackStone = function (self, addList, updateList, deleteList)
		if not gPanelManager:IsPanelShowing(gPanelId.S_INVENTORY_PANEL) then
			return
		end

		local updateDict = {}

		if deleteList then
			for i = 1, #deleteList do
				updateDict[deleteList[i]] = 1
			end
		end

		if updateList then
			for i = 1, #updateList do
				updateDict[updateList[i].InstanceId] = 1
			end
		end

		gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED, {
			addList = addList,
			updateDict = updateDict,
			changeType = gPackagePanelManager.itemType.Stone
		})
	end,
	SetItemToSubPack = function (self, packItem, itemCfg)
		local otherItemChanged = false

		if not itemCfg then
			itemCfg = ConsumableConfig.GetConfig(packItem.TemplateId)

			if not itemCfg then
				return otherItemChanged
			end
		end

		if itemCfg.SubType == ConsumableTypeConfig.LingScroll then
			gPlayerManager.infoItem.pack.lingScrollPacks[itemCfg.Id] = packItem.Count
			otherItemChanged = true
		elseif table.contains(self.lingPeiYangSubType, itemCfg.SubType) then
			gPlayerManager.infoItem.pack.lingPeiYangPacks[itemCfg.Id] = packItem.Count
			otherItemChanged = true
		end

		if table.contains(self.OtherItemType, itemCfg.SubType) then
			gPlayerManager.infoItem.pack.otherItems[itemCfg.Id] = packItem.Count
			otherItemChanged = true
		end

		return otherItemChanged
	end
}

function M:GetPackItemByTemplateId(templateId)
	for i = 1, #self.packItems do
		local item = self.packItems[i]

		if item.TemplateId == templateId then
			return item
		end
	end

	return nil
end

function M:GetPackItemsByTemplateId(templateId)
	local item = self.packItems
	local result = {}

	for i = 1, #item do
		if item[i].TemplateId == templateId then
			table.insert(result, item[i])
		end
	end

	return result
end

function M:GetPackItemNum(templateId)
	local num = 0

	if table.contains(self.SpecialItemId, templateId) then
		return self:GetSpecialItemNum(templateId)
	end

	local items = self:GetPackItemsByTemplateId(templateId)

	for i = 1, #items do
		num = num + items[i].Count
	end

	return num
end

function M:GetSpecialItemNum(templateId)
	if templateId == ConsumableConfig.RewardBindingGold then
		return gPlayerManager.infoItem.bindData.bindGold
	elseif templateId == ConsumableConfig.RewardGold then
		return gPlayerManager.infoItem.bindData.gold
	elseif templateId == ConsumableConfig.RewardMoney then
		return gPlayerManager.infoItem.bindData.money
	else
		return 0
	end
end

function M:GetPackItemNumWithSubType(templateId, subType)
	local count = 0

	if not subType then
		count = self:GetPackItemNum(templateId)
	elseif subType == ConsumableTypeConfig.LingPeiYang then
		count = gPlayerManager.infoItem.pack.lingPeiYangPacks[templateId]
	elseif subType == ConsumableTypeConfig.LingScroll then
		count = gPlayerManager.infoItem.pack.lingScrollPacks[templateId]
	else
		count = self:GetPackItemNum(templateId)
	end

	if count then
		return count
	else
		return 0
	end
end

function M:GetLingScrollNum(templateId)
	return self:GetPackItemNumWithSubType(templateId, ConsumableTypeConfig.LingScroll)
end

function M:QueryItemById(templateId)
	local items = self:GetPackItemsByTemplateId(templateId)

	for i = 1, #items do
		if items[i].TemplateId == templateId and self:CheckItemCanUse(items[i]) then
			return true, items[i]
		end
	end

	return false
end

function M:CheckItemCanUse(item)
	if self:GetUseTimes(item.TemplateId) ~= 0 then
		return true
	else
		return false
	end
end

function M:GetUseTimes(templateId)
	local result = ""
	local consumableCfg = ConsumableConfig.GetConfig(templateId)

	if consumableCfg and consumableCfg.DailyCount ~= -1 then
		local times = gPlayerManager.infoItem.pack.itemUseTimes[templateId] or 0
		result = consumableCfg.DailyCount - times
	end

	return result
end

function M:HideRedDot(uniqueId)
	if not self.packItemDict[uniqueId] or not self.packItemDict[uniqueId].IsNew then
		return
	end

	self.packItemDict[uniqueId].IsNew = false

	table.insert(self.redDotHideList, uniqueId)

	if self.waitHideRedDot then
		return
	end

	self.waitHideRedDot = Timer.New(function ()
		self:_HideRedDot()

		self.waitHideRedDot = nil
	end, 0.5):Start()
end

function M:_HideRedDot()
	local realList = table.clone(self.redDotHideList)
	self.redDotHideList = {}

	gClientToGameDelegate:AskClearRedPointList(realList).Callback = function (err, info)
		if err ~= MessageConfig.Ok then
			for i = 1, #realList do
				local uniqueId = self.redDotHideList[i]
				self.packItemDict[uniqueId].IsNew = true
			end
		end
	end
end

function M:GetPackTabByTemplateId(templateId)
	local cfg = ConsumableConfig.GetConfig(templateId)

	if not cfg then
		return
	end

	for i = 4, #self.subTypes do
		local subTypeList = self.subTypes[i]

		for j = 1, #subTypeList do
			local subTab = subTypeList[j]

			if ConsumableTypeConfig[subTab] == cfg.SubType then
				return i
			end
		end
	end
end

function M:UseItemByTemplateId(templateId, itemCount, callBack)
	local items = self:GetPackItemsByTemplateId(templateId)

	if items == nil or #items == 0 then
		self:UseItem(nil, templateId, itemCount, callBack)
	else
		for i = 1, #items do
			if itemCount <= items[i].Count then
				self:UseItem(items[i].UniqueId, templateId, itemCount, callBack)

				return
			end
		end
	end
end

function M:UseItem(uniqueId, templateId, itemCount, callBack)
	if not self:UseItemPrecheck(templateId) then
		callBack()

		return
	end

	gClientToGameDelegate:AskUseItems(uniqueId, itemCount).Callback = function (err)
		if err == MessageConfig.Ok then
			-- Nothing
		elseif err == MessageConfig.ItemNotEnough then
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900872).Text)
		else
			print_warn("AskUseItems Fail", gCS.Error.GetNameById(err))
		end

		if callBack then
			callBack(err)
		end
	end

	return true
end

function M:UseItemPrecheck(templateId)
	if not self:IsAutoUseItem(templateId) and gCS.MyPlayerManager.CheckEventForbidden(UnitState.UseItem) then
		return false
	end

	if templateId == ConsumableConfig.Portal and gMapSubSystem_Entrance.portalPosition then
		gMapSubSystem_Entrance:TryTeleport(MapentranceConfig.PortalItem)

		return false
	end

	local consumableCfg = ConsumableConfig.GetConfig(templateId)

	if consumableCfg and consumableCfg.DailyCount ~= -1 and gPlayerManager.infoItem.pack.itemUseTimes[templateId] and consumableCfg.DailyCount <= gPlayerManager.infoItem.pack.itemUseTimes[templateId] then
		gDisplayMessageMgr:ShowMessage(MessageConfig.DailyCountFull)

		return
	end

	return true
end

function M:IsAutoUseItem(templateId)
	local cfg = ConsumableConfig.GetConfig(templateId)
	local consumableTypeCfg = cfg and ConsumableTypeConfig.GetConfig(cfg.SubType) or nil

	if consumableTypeCfg then
		return consumableTypeCfg.AutoUse
	else
		return false
	end
end

function M:UpdateItemData(newData, prevData)
	prevData.UniqueId = newData.UniqueId
	prevData.Count = newData.Count
	prevData.ExpiryTime = newData.ExpiryTime
	prevData.IsNew = newData.IsNew
	prevData.RemindState = newData.RemindState
	prevData.SubType = newData.SubType
	prevData.TemplateId = newData.TemplateId
	prevData.CDFinishTime = newData.CDFinishTime
end

gPlayerItemManager = M
