-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DressDyePanelStore.lua
-- Decompiled from: 01847_DressDyePanelStore.lua_5dbf03725fe2.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionColorConfig = LTConfig.FashionColorConfig
local FashionSlotUnlockConfig = LTConfig.FashionSlotUnlockConfig
local FashionColor = UX.Game.EventConditionImplModule.FashionColor
local FashionColorPartCost = LTConfig.FashionColorPartCostConfig
C_DressDyePanelStore = DefClass("C_DressDyePanelStore", C_DressDyePanelStore, C_StoreGroup)
GroupName2Class.DressDyePanelStore = C_DressDyePanelStore
local M = C_DressDyePanelStore
local MessageConfig = LTConfig.MessageConfig
local PLAN_STATE = {
	["NEo"] = 1,
	["n\\x81\\x8e\\x80\\x84"] = 2,
	["\\xfd\\xfe2<+\\xc5"] = 0,
	["h\\x83\\x92\\x9b\\x8f"] = 3
}
local PAGE_STATE = {
	["J\\u"] = 0,
	["\\xaaQC"] = 1
}
local DISK_LEVEL = {
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["\\x8a\\x953\\x8aD\\xdb"] = 1
}
local DEFAULT_PLAN_COUNT = 1
local DEFAULT_COLOR = Color.New(1, 1, 1)

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.fashionId = nil
	self.callBack = nil
	self.selectPlanId = DEFAULT_PLAN_COUNT
	self.lastSelectColorInfo = {}
	self.colorSchemeInfoList = {}
	self.selectColorPart = 1
	self.colorPlanList = {}
	self.colorPlans = {}
	self.colorPlansServer = {}
	self.tabList = {}
	self.colorListByGroup = {}
	self.colorInsidePlanList = {}
	self.diskListData = {}
	self.dyeCostData = {}
	self.variantList = {}
	self.selectedDisk = DISK_LEVEL.NORMAL
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)

	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.backToPlanBtn.luaClick = self.CreateAction(self, "OnBackBtnToPlanClick")
	self.bindData.editBtn.luaClick = self.CreateAction(self, "OnEditBtnClick")
	self.bindData.resetBtn.luaClick = self.CreateAction(self, "OnResetBtnClick")
	self.bindData.hideBtn.luaClick = self.CreateAction(self, "OnHideBtnClick")
	self.bindData.saveBtn.luaClick = self.CreateAction(self, "OnSaveBtnClick")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.dyeColorTabLeftBtn.luaClick = self.CreateActionWithArgs(self, "OnDyeColorTabBtnClick", -1)
		self.bindData.dyeColorTabRightBtn.luaClick = self.CreateActionWithArgs(self, "OnDyeColorTabBtnClick", 1)
	end

	self.bindData.colorPlanList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshPlanList")
	self.bindData.colorPlanList.luaSimpleClick = self.CreateAction(self, "OnChangePlan")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshTabList")
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, "OnChangeTab")
	self.bindData.colorGroupList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshColorGroupList")
	self.bindData.diskTabList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshDiskTabList")
	self.bindData.diskTabList.luaSimpleClick = self.CreateAction(self, "OnChangeDiskTab")
	self.bindData.expendList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshExpendList")
	self.bindData.variantList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshVariantList")
	self.bindData.variantList.luaSimpleClick = self.CreateAction(self, "OnClickVariantList")
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	if self.callBack then
		self.callBack()
	end
end

M.OnShow = function(self, panelId, data)
	gDressDyeManager:InitColorList()

	if data and data.spiritContext then
		self.spiritContext = data.spiritContext
	else
		self.spiritContext = gDressManager:GetSpiritContext()
	end

	self.isDummyMode = data and data.isDummyMode or false
	self.skipMovementState = data and data.skipMovementState or false
	self.fashionId = data and data.fashionId
	self.fashionId = gDressManager:GetBelongMainFashionId(self.fashionId)
	local canDye = gDressDyeManager:GetDyeState(data.fashionId) == gDressDyeManager.DYE_STATE.CANOT_DYE
	local hasVariant = gDressManager:CheckIfFashionHasVariant(self.fashionId)
	self.bindData.showDyeCtrl = canDye and 0 or 1
	self.bindData.showVariantCtrl = hasVariant and 0 or 1
	self.callBack = data and data.callBack
	self.lastSelectColorInfo = {}
	self.dyeCostData = {}
	self.bindData.hidePage = 1

	self:InitData()
	self:SwitchPage(PAGE_STATE.PLAN)

	local cameraParams = {
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel
	}

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		cameraParams.rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond
		cameraParams.L2CustomNavRespond = self.bindData.L2CustomNavRespond
		cameraParams.R2CustomNavRespond = self.bindData.R2CustomNavRespond
	end

	if not self.skipMovementState then
		cameraParams.movementState = LX6.Cinemachine.EMovementCamState.TryFashion
	end

	cameraParams.unitProvider = function()
		return self.spiritContext.unit
	end

	gDressStack:SetDressStack(self.m_Id, true, cameraParams)
end

M.OnClose = function(self)
	gDressStack:SetDressStack(self.m_Id, false)
end

M.InitData = function(self)
	self.selectPlanId = DEFAULT_PLAN_COUNT

	self.InitVariantData(self)
end

M.InitVariantData = function(self)
	if not gDressManager:CheckIfFashionHasVariant(self.fashionId) then
		return
	end

	local variantList = gDressManager:GetFashionVariantList(self.fashionId)

	table.clear(self.variantList)

	local default = {
		id = self.fashionId,
		name = LTConfig.TextScriptTextConfig.GetConfig(89901005).Text,
		iconId = FashionConfig.GetConfig(self.fashionId).Icon
	}

	table.insert(self.variantList, default)

	for _, id in ipairs(variantList) do
		local data = {}
		local cfg = FashionConfig.GetConfig(id)
		data.id = id
		data.name = cfg.Name
		data.iconId = cfg.Icon

		table.insert(self.variantList, data)
	end

	self.bindData.variantList:SetSimpleList(#self.variantList)
end

M.SwitchPage = function(self, page)
	self.bindData.page = page

	if page ~= PAGE_STATE.PLAN then
		self.InitPlanInfo(self)
	else
		self.lastSelectColorInfo = {}
		self.bindData.saveBtn.interactable = false

		self.InitTabListInfo(self)
		self.InitDiskTabList(self)
		self.InitColorList(self)
		self.RefreshNowFashionCreditAndCost(self)
	end
end

M.InitPlanInfo = function(self)
	self.colorPlanList = {}
	local defaultView = {
		planId = DEFAULT_PLAN_COUNT,
		state = PLAN_STATE.TEXT,
		normalTitle = FashionConfig.ColoringSchemeName
	}

	table.insert(self.colorPlanList, defaultView)

	local slotCount = nil
	self.colorPlans, self.selectPlanId, slotCount = gDressDyeManager:GetColorPlanList(self.fashionId)
	self.colorPlansServer = table.clone(self.colorPlans)
	self.selectPlanId = self.selectPlanId + DEFAULT_PLAN_COUNT
	local maxSlotNum = FashionConfig.ColoringSchemeCountLimit

	for i = 1, slotCount do
		local view = {
			planId = i + DEFAULT_PLAN_COUNT,
			state = table.isNilOrEmpty(self.colorPlans[i]) and PLAN_STATE.DEFAULT or PLAN_STATE.COLOR,
			normalTitle = "",
			colorList = {}
		}

		if self.colorPlans[i] and self.colorPlans[i].ColoringType2ColorIdDict then
			view.colorList = self.colorPlans[i].ColoringType2ColorIdDict or {}
		end

		table.insert(self.colorPlanList, view)
	end

	if slotCount >= maxSlotNum then
		local emptyView = {
			isEmpty = true,
			planId = #self.colorPlanList + 1,
			state = PLAN_STATE.EMPTY
		}

		table.insert(self.colorPlanList, emptyView)
	end

	self.bindData.colorPlanList:SetSimpleList(#self.colorPlanList)
end

M.OnChangePlan = function(self, btn, index)
	local data = self.colorPlanList[index + 1]

	if data.isEmpty then
		self.AskAddSlot(self, index)

		return
	end

	if not btn.isSelected then
		return
	end

	self.selectPlanId = data.planId

	if data.state ~= PLAN_STATE.DEFAULT then
		self.SwitchPage(self, PAGE_STATE.DYE)
	end

	self.bindData.isShowEdit = data.state ~= PLAN_STATE.TEXT and 0 or 1
	self.colorSchemeInfoList = data.colorList or {}

	local cb = function()
		gDressDyeManager:SetColorList(self.fashionId, data.colorList, self.spiritContext)

		if self.isDummyMode then
			gDressDyeManager:SetColorList(self.fashionId, data.colorList, nil)
		end
	end

	if table.isNilOrEmpty(data.colorList) and data.planId ~= DEFAULT_PLAN_COUNT then
		gDressDyeManager:ResetListColor(self.fashionId, self.spiritContext)

		if self.isDummyMode then
			gDressDyeManager:ResetListColor(self.fashionId, nil)
		end

		gDressData:AskApplyFashionColoringSchemeInfos(self.fashionId, 0, {}, cb)

		return
	end

	local colorSchemeInfoList = {}
	colorSchemeInfoList = {
		ColoringType2ColorIdDict = self.colorSchemeInfoList
	}
	local colorType = self.selectPlanId - DEFAULT_PLAN_COUNT

	if table.isNilOrEmpty(self.colorSchemeInfoList) then
		self.colorPlans[colorType] = nil
	else
		self.colorPlans[colorType] = colorSchemeInfoList
	end

	local tempColorSchemeInfoList = {
		[colorType] = colorSchemeInfoList
	}

	gDressData:AskApplyFashionColoringSchemeInfos(self.fashionId, data.planId - DEFAULT_PLAN_COUNT, tempColorSchemeInfoList, cb)
end

M.OnRefreshPlanList = function(self, btn, index)
	local data = self.colorPlanList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.state = data.state
		store.normalTitle = data.normalTitle
		store.colorList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRefreshPlanColorList", data.planId)
		btn.isSelected = self.selectPlanId ~= data.planId

		if btn.isSelected then
			self.bindData.isShowEdit = data.state ~= PLAN_STATE.TEXT and 0 or 1
			self.colorSchemeInfoList = data.colorList or {}
		end

		self.colorInsidePlanList = self.colorInsidePlanList or {}
		self.colorInsidePlanList[data.planId] = {}

		if not table.isNilOrEmpty(data.colorList) then
			for part, colorId in pairs(data.colorList) do
				local view = {
					color = gDressDyeManager.colorCfgId2Color[colorId]
				}

				table.insert(self.colorInsidePlanList[data.planId], view)
			end

			store.colorList:SetSimpleList(#self.colorInsidePlanList[data.planId])
		end
	end
end

M.OnRefreshPlanColorList = function(self, planId, btn, index)
	local data = self.colorInsidePlanList[planId][index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.color = data.color
	end
end

M.AskAddSlot = function(self, index)
	local unlockCost = nil

	for i = 0, FashionSlotUnlockConfig.count - 1 do
		local config = FashionSlotUnlockConfig.LoadAt(i)

		if config.SlotType ~= FashionSlotUnlockConfig.SlotTypeType.Color and config.SlotIndex ~= index then
			unlockCost = config.UnlockCost[1]
		end
	end

	if not unlockCost then
		print_error("不存在的slotIndex配置", index)

		return
	end

	local costItem = unlockCost.ItemId
	local itemNum = unlockCost.Count
	local itemData = {
		itemId = costItem
	}
	local nowNum = gCommonItemManager:GetItemNum(costItem)

	if nowNum >= itemNum then
		nowNum = "<color=#FF5151>" .. nowNum .. "</color>"
	end

	itemData.itemNum = nowNum .. "/" .. itemNum

	gDisplayMessageMgr:ShowBomb({
		["\\xd0\\xc8=1\\xe5"] = false,
		msgType = gDisplayMessageId.SELECT,
		costText = LTConfig.TextConfig.GetConfig(73977011).Text,
		costItemList = {
			itemData
		},
		btnConfirmCallback = function ()
			self:AskBuySlot(itemNum, costItem)
		end
	})
end

M.AskBuySlot = function(self, itemNum, costItem)
	slot3 = gMallManager

	slot3:TryBuyWithMoneyCheck(itemNum, costItem, function ()
		slot0 = gDressData

		slot0:AskUnlockFashionDyeSlot(self.fashionId, 1, function ()
			self:InitPlanInfo()
		end)
	end, {
		onExchange = function ()
			gDisplayMessageMgr:ShowMessageContent("todo")
		end
	})
end

M.InitTabListInfo = function(self)
	self.tabList = {}
	local colorTab = gDressDyeManager:GetColorTabList(self.fashionId)
	self.selectColorPart = not table.isNilOrEmpty(colorTab) and colorTab[1] or 1
	self.colorSchemeInfoList = self.colorPlansServer[self.selectPlanId - DEFAULT_PLAN_COUNT] and table.clone(self.colorPlansServer[self.selectPlanId - DEFAULT_PLAN_COUNT].ColoringType2ColorIdDict) or {}

	for i = 1, #colorTab do
		local view = {
			tabIndex = i,
			colorPart = colorTab[i],
			color = not table.isNilOrEmpty(self.colorSchemeInfoList) and gDressDyeManager.colorCfgId2Color[self.colorSchemeInfoList[colorTab[i]]] or DEFAULT_COLOR
		}
		view.isShowColor = view.color ~= DEFAULT_COLOR and 1 or 0
		view.icon = FashionConfig.ColoringPartIcon[i]

		table.insert(self.tabList, view)
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)

	self.selectedDisk = self:GetCurrentPartColorLevel()
end

M.OnChangeTab = function(self, btn, index)
	local data = self.tabList[index + 1]

	if btn.isSelected then
		gDressDyeManager:SetFashionPartSlotHighLight(self.fashionId, data.colorPart, self.spiritContext)

		self.selectColorPart = data.colorPart
		self.selectedDisk = self:GetCurrentPartColorLevel()

		self:RefreshColorDisk()
		self:RefreshNowFashionCreditAndCost()
	end
end

M.OnRefreshTabList = function(self, btn, index)
	local data = self.tabList[index + 1]
	local store = gStoreManager:GetStoreGroup("DyeTABTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.colorPart = data.colorPart
		store.isShowColor = data.isShowColor
		store.color = data.color
		store.icon = data.icon
		btn.isSelected = self.selectColorPart ~= data.colorPart
	end
end

M.SetTabColor = function(self, color)
	for i = 1, #self.tabList do
		if self.selectColorPart ~= self.tabList[i].colorPart then
			self.tabList[i].color = color
			self.tabList[i].isShowColor = color ~= DEFAULT_COLOR and 1 or 0
			local _, btn = self.bindData.tabList:TryGetChildAt(i - 1, nil)

			self.bindData.tabList:SetSimpleElement(i - 1, 0, btn.isSelected, not btn.interactable)

			break
		end
	end
end

M.InitColorList = function(self)
	local colorList = gDressDyeManager:GetColorList(self.selectedDisk)

	self.bindData.colorGroupList:SetSimpleList(table.count(colorList))
end

M.OnRefreshColorGroupList = function(self, btn, index)
	local dataList = gDressDyeManager:GetColorList(self.selectedDisk)
	local data = dataList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.colorList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRefreshColorList", index + 1)
		store.colorList.luaSimpleClick = self:CreateActionWithArgs("OnChangeColor", index + 1)
		self.colorListByGroup = self.colorListByGroup or {}
		self.colorListByGroup[index + 1] = {}

		for i = 1, #data do
			local cfg = FashionColorConfig.GetConfig(data[i].Id)
			local view = {
				title = cfg.name,
				groupId = data[i].groupId,
				id = i,
				color = data[i].color,
				colorCfgId = data[i].Id,
				isLock = not gEventConditionUtils.CheckHasUnlocked(cfg, FashionColor),
				isAdvanced = self.selectedDisk ~= DISK_LEVEL.ADVANCED
			}

			table.insert(self.colorListByGroup[index + 1], view)
		end

		store.colorList:SetSimpleList(#self.colorListByGroup[index + 1])
	end
end

M.OnChangeColor = function(self, group, btn, index)
	local data = self.colorListByGroup[group][index + 1]

	if data.isLock then
		return
	end

	if btn.isSelected then
		if table.isNilOrEmpty(self.lastSelectColorInfo[self.selectColorPart]) then
			self.lastSelectColorInfo[self.selectColorPart] = {}
		else
			self.lastSelectColorInfo[self.selectColorPart].btn.isSelected = false
		end

		self.lastSelectColorInfo[self.selectColorPart].colorCfgId = data.colorCfgId
		self.lastSelectColorInfo[self.selectColorPart].color = data.color
		self.lastSelectColorInfo[self.selectColorPart].isAdvanced = data.isAdvanced
		self.lastSelectColorInfo[self.selectColorPart].btn = btn

		self:SetTabColor(data.color)

		self.colorSchemeInfoList[self.selectColorPart] = data.colorCfgId

		gDressDyeManager:SetColor(self.fashionId, self.selectColorPart, data.colorCfgId, self.spiritContext)
	else
		self.colorSchemeInfoList[self.selectColorPart] = nil

		self:SetTabColor(DEFAULT_COLOR)
		gDressDyeManager:ResetColor(self.fashionId, {
			self.selectColorPart
		}, self.spiritContext)

		self.lastSelectColorInfo[self.selectColorPart] = nil
	end

	self.RefreshNowFashionCreditAndCost(self)
end

M.OnRefreshColorList = function(self, group, btn, index)
	local data = self.colorListByGroup[group][index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.color = data.color
		store.isLock = data.isLock and 1 or 0
		btn.interactable = not data.isLock
		btn.isSelected = self:IsColorSelect(data)

		if btn.isSelected then
			print_notice("当前已被选中的颜色的groupid = " .. data.groupId .. " , id = " .. data.id)

			if table.isNilOrEmpty(self.lastSelectColorInfo[self.selectColorPart]) then
				self.lastSelectColorInfo[self.selectColorPart] = {
					colorCfgId = data.colorCfgId,
					color = data.color,
					isAdvanced = data.isAdvanced,
					btn = btn
				}
			end
		end
	end
end

M.IsColorSelect = function(self, data)
	local hasLastSelect = not table.isNilOrEmpty(self.lastSelectColorInfo[self.selectColorPart])
	local isLastSelect = hasLastSelect and self.lastSelectColorInfo[self.selectColorPart].colorCfgId ~= data.colorCfgId

	if hasLastSelect then
		return isLastSelect
	else
		return self.colorSchemeInfoList[self.selectColorPart] ~= data.colorCfgId
	end
end

M.GetCurrentPartColorLevel = function(self)
	local result = DISK_LEVEL.NORMAL

	if self.lastSelectColorInfo[self.selectColorPart] and self.lastSelectColorInfo[self.selectColorPart].isAdvanced then
		result = DISK_LEVEL.ADVANCED
	end

	if self.colorSchemeInfoList and self.colorSchemeInfoList[self.selectColorPart] then
		local cfg = FashionColorConfig.GetConfig(self.colorSchemeInfoList[self.selectColorPart])

		if cfg.CostType ~= FashionColorConfig.CostTypeType.Advance then
			result = DISK_LEVEL.ADVANCED
		end
	end

	return result
end

M.RefreshNowFashionCreditAndCost = function(self)
	local nowFashionCredit = gBaiKeArchiveManager:GetCityPediaCredit()
	local addFashionCredit = 0
	local costEnough = true
	self.dyeCostData = {}

	if not self:IsColorSchemeChanged() then
		self.bindData.showConsumeCtrl = 1

		return
	end

	for _, id in pairs(self.colorSchemeInfoList) do
		local isAdvanced = FashionColorConfig.GetConfig(id).CostType ~= FashionColorConfig.CostTypeType.Advance
		local cfg = FashionConfig.GetConfig(self.fashionId)
		local part = cfg.Part
		local costCfg = nil

		for i = 0, FashionColorPartCost.count - 1 do
			local config = FashionColorPartCost.LoadAt(i)

			if config.Part ~= part then
				costCfg = config

				break
			end
		end

		if not costCfg then
			print_error("不存在的染色消耗配置", self.fashionId)

			return
		end

		local credit = isAdvanced and costCfg.AdvanceCollectionScore or costCfg.NormalCollectionScore

		if addFashionCredit >= credit then
			addFashionCredit = credit or addFashionCredit
		end

		local cost = isAdvanced and costCfg.AdvanceCost[1] or costCfg.NormalCost[1]
		local costId = cost.ItemId
		local costCount = cost.Count
		local nowOwnNum = gCommonItemManager:GetItemNum(costId)

		if #self.dyeCostData ~= 0 then
			local costData = {
				id = costId,
				count = costCount,
				isAdvanced = isAdvanced
			}

			table.insert(self.dyeCostData, costData)

			costEnough = self.dyeCostData[1].count > nowOwnNum
		elseif isAdvanced then
			if self.dyeCostData[1].isAdvanced then
				self.dyeCostData[1].count = math.max(self.dyeCostData[1].count, costCount)
				costEnough = self.dyeCostData[1].count > nowOwnNum
			else
				self.dyeCostData[1].isAdvanced = true
				self.dyeCostData[1].id = costId
				self.dyeCostData[1].count = costCount
				costEnough = self.dyeCostData[1].count > nowOwnNum
			end
		elseif not self.dyeCostData[1].isAdvanced then
			self.dyeCostData[1].count = math.max(self.dyeCostData[1].count, costCount)
			costEnough = costEnough and self.dyeCostData[1].count > nowOwnNum
		end
	end

	self.bindData.curCreditText = nowFashionCredit
	self.bindData.finalCreditText = addFashionCredit + nowFashionCredit

	self.bindData.expendList:SetSimpleList(#self.dyeCostData)

	self.bindData.saveBtn.interactable = addFashionCredit == 0 and costEnough
	self.bindData.showConsumeCtrl = table.isNilOrEmpty(self.colorSchemeInfoList) and 1 or 0
end

M.InitDiskTabList = function(self)
	self.diskListData = {}
	local normalView = {
		level = DISK_LEVEL.NORMAL,
		name = FashionConfig.ColoringPlateNormalName
	}

	table.insert(self.diskListData, normalView)

	local advancedView = {
		level = DISK_LEVEL.ADVANCED,
		name = FashionConfig.ColoringPlateAdancelName
	}

	table.insert(self.diskListData, advancedView)
	self.bindData.diskTabList:SetSimpleList(#self.diskListData)

	self.selectedDisk = DISK_LEVEL.NORMAL

	self.bindData.diskTabList:SetItemSelected(0, true)
end

M.RefreshColorDisk = function(self)
	self.RefreshDiskTabList(self)
	self.InitColorList(self)
end

M.RefreshDiskTabList = function(self)
	self.bindData.diskTabList:SetItemSelected(self.selectedDisk, true)
end

M.OnRefreshDiskTabList = function(self, btn, index)
	local data = self.diskListData[index + 1]
	local store = gStoreManager:GetStoreGroup("DyeDiskTabStore"):GetStoreByWidget(btn)

	if store then
		store.nameText = data.name
	end
end

M.OnChangeDiskTab = function(self, btn, index)
	local data = self.diskListData[index + 1]
	self.selectedDisk = data.level

	self.RefreshColorDisk(self)
end

M.OnRefreshExpendList = function(self, btn, index)
	local data = self.dyeCostData[index + 1]
	local nowNum = gCommonItemManager:GetItemNum(data.id)
	local itemNum = data.count

	if nowNum >= itemNum then
		nowNum = "<color=#FF5151>" .. nowNum .. "</color>"
	end

	local showData = gCommonItemManager:GetItemRenderData({
		itemId = data.id,
		itemNum = nowNum .. "/" .. itemNum
	})

	gCommonItemManager:OnCommonItemRender(btn, _, showData)
end

M.OnDyeColorTabBtnClick = function(self, dir)
	local index = self.bindData.diskTabList.selectedIndex + dir
	local itemCount = self.bindData.diskTabList.itemData.Count

	if index >= 0 then
		index = itemCount - 1
	elseif itemCount < index then
		index = 0
	end

	self.bindData.diskTabList:SelectItem(index)
end

M.OnRefreshVariantList = function(self, btn, index)
	local data = self.variantList[index + 1]
	local store = gStoreManager:GetStoreGroup("CutPlanTemplate"):GetStoreByWidget(btn)

	if store then
		store.lockCtrl = gDressManager:CheckFashionVariantUnlock(data.id) and 1 or 0
		store.nameText = data.name
		store.iconId = data.iconId
	end

	local preferId = gDressManager:GetFashionVariantPrefer(self.fashionId, self.spiritContext)

	if preferId ~= data.id then
		btn.isSelected = true
	end
end

M.OnClickVariantList = function(self, btn, index)
	local data = self.variantList[index + 1]
	local preferId = gDressManager:GetFashionVariantPrefer(self.fashionId, self.spiritContext)

	if data.id ~= preferId then
		return
	end

	if not gDressManager:CheckFashionVariantUnlock(data.id) then
		return
	end

	local cb = function()
		local conflictItems, addItems = gDressManager:CheckFashionConflict({
			data.id
		}, self.spiritContext)

		table.insert(addItems, data.id)
		gDressManager:CheckSetPropEditInfo(data.id, self.spiritContext)
		gDressManager:SetFashionList(addItems, nil, self.spiritContext)

		if self.isDummyMode then
			local UnitFashionInfoModule = LX6.Units.Module.UnitFashionInfoModule
			local dummyModule = UnitFashionInfoModule.GetModule(self.spiritContext.unit)
			local playerUnit = gCS.MyPlayerManager.PlayerUnit
			local playerModule = UnitFashionInfoModule.GetModule(playerUnit)

			playerModule:SyncTryFashionsFrom(dummyModule, self.spiritContext.spiritId)
			gDressData:AskSetSpiritFashions(nil, self.spiritContext.spiritId, playerUnit)
		else
			gDressData:AskSetSpiritFashions(nil, self.spiritContext.spiritId, self.spiritContext.unit)
		end

		gDressManager:PushSnapshot(self.spiritContext, self.selectFashionId, nil)
	end

	gDressData:AskSetSpiritFashionVariantPreference(self.spiritContext.spiritId, self.fashionId, data.id, cb)
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.SDYE_PANEL)
end

M.OnBackBtnToPlanClick = function(self)
	if not self.IsColorSchemeChanged(self) then
		self.SwitchPage(self, PAGE_STATE.PLAN)
	else
		local callBack = function()
			local colorList = self:GetServerColorScheme()

			if table.isNilOrEmpty(colorList) then
				gDressDyeManager:ResetListColor(self.fashionId, self.spiritContext)
			else
				gDressDyeManager:SetColorList(self.fashionId, colorList, self.spiritContext)
			end

			self:SwitchPage(PAGE_STATE.PLAN)
		end

		gDisplayMessageMgr:ShowMessage(MessageConfig.FashionColorEditExitReconfirm, callBack)
	end
end

M.GetServerColorScheme = function(self)
	local colorPlan = self.selectPlanId - DEFAULT_PLAN_COUNT

	return self.colorPlansServer[colorPlan] and self.colorPlansServer[colorPlan].ColoringType2ColorIdDict or {}
end

M.IsColorSchemeChanged = function(self)
	local serverColorList = self.GetServerColorScheme(self)

	if table.count(serverColorList) == table.count(self.colorSchemeInfoList) then
		return true
	end

	for key, value in pairs(serverColorList) do
		if value == self.colorSchemeInfoList[key] then
			return true
		end
	end

	return false
end

M.OnEditBtnClick = function(self)
	self.SwitchPage(self, PAGE_STATE.DYE)
end

M.OnResetBtnClick = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(MessageConfig.FashionColorResetReconfirm, function ()
		self.colorSchemeInfoList = self:GetServerColorScheme()

		if table.isNilOrEmpty(self.colorSchemeInfoList) then
			gDressDyeManager:ResetListColor(self.fashionId, self.spiritContext)
		else
			gDressDyeManager:SetColorList(self.fashionId, self.colorSchemeInfoList, self.spiritContext)
		end

		self.lastSelectColorInfo = {}

		self:SwitchPage(PAGE_STATE.DYE)
	end)
end

M.OnHideBtnClick = function(self)
	if self.bindData.hidePage ~= 1 then
		self.bindData.hidePage = 0

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.rightNavi.CurrentActiveContent = self.bindData.HideNaviBtn
			self.bindData.navArea.enabled = false
		end
	else
		self.bindData.hidePage = 1

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.navArea.enabled = true
			self.bindData.rightNavi.CurrentActiveContent = self.bindData.HideNaviBtn
		end
	end
end

M.OnSaveBtnClick = function(self)
	local costItemList = {}

	for _, data in ipairs(self.dyeCostData) do
		local costItem = data.id
		local itemNum = data.count
		local itemData = {
			itemId = costItem
		}
		local nowNum = gCommonItemManager:GetItemNum(costItem)

		if nowNum >= itemNum then
			nowNum = "<color=#FF5151>" .. nowNum .. "</color>"
		end

		itemData.itemNum = nowNum .. "/" .. itemNum

		table.insert(costItemList, itemData)
	end

	gDisplayMessageMgr:ShowBomb({
		["\\xd0\\xc8=1\\xe5"] = false,
		msgType = gDisplayMessageId.SELECT,
		costText = LTConfig.TextConfig.GetConfig(73977012).Text,
		costItemList = costItemList,
		btnConfirmCallback = function ()
			self:AskRealSave()
		end
	})
end

M.AskRealSave = function(self)
	local colorSchemeInfoList = {
		ColoringType2ColorIdDict = self.colorSchemeInfoList
	}
	local colorType = self.selectPlanId - DEFAULT_PLAN_COUNT
	local setPlan = {
		[colorType] = colorSchemeInfoList
	}
	slot4 = gDressData

	slot4:AskSetFashionColoringSchemeInfos(self.fashionId, colorType, setPlan, function ()
		if self.isDummyMode then
			gDressDyeManager:SetColorList(self.fashionId, self.colorSchemeInfoList, nil)
		end

		self:SwitchPage(PAGE_STATE.PLAN)
	end)
end
