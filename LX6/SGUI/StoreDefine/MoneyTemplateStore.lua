-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MoneyTemplateStore.lua
-- Decompiled from: 00987_MoneyTemplateStore.lua_2c4f8fc7deb8.luajit

local MessageConfig = LTConfig.MessageConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local MoneyType = UX.Game.MoneyType
local EInvokeTime = SGUI.EInvokeTime
C_MoneyTemplateStore = DefClass("C_MoneyTemplateStore", C_MoneyTemplateStore, C_StoreGroup)
GroupName2Class.MoneyTemplateStore = C_MoneyTemplateStore
local MoneyTemplateStore = C_MoneyTemplateStore

MoneyTemplateStore.OnAwake = function(self)
	self.moneyList = {}
	self.showSwitchBtn = false
	self.handler = self.CreateAction(self, "RefreshMoney")
	self.msgEvents = {
		[gEventConstants.SPIRIT_FRAGMENT_POINT_CHANGE] = self.handler,
		[gEventConstants.PACK_ITEM_CHANGED] = self.handler,
		[gEventConstants.SWITCH_MONEY_CHANGE] = self.CreateAction(self, "InitMoney")
	}
	self.dataSetEvents = {
		{
			gPlayerManager.infoItem.bindData,
			"@\\xa1\\xac\\xaa\\xaf",
			self.handler,
			nil,
			false
		},
		{
			gPlayerManager.infoItem.bindData,
			"}-q_",
			self.handler,
			nil,
			false
		},
		{
			gPlayerManager.infoItem.bindData,
			"\\xa9\\xb8\\xafM1\\xf27",
			self.handler,
			nil,
			false
		}
	}

	self.RegisterMessageEvents(self, self.msgEvents)
	self.RegisterDataSetEvents(self, self.dataSetEvents)

	self.bindData.moneyList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.moneyList.onGetTIndex = self.CreateAction(self, "OnGetTIndex")

	self.InitShowAddMoney(self)
end

MoneyTemplateStore.OnDestroy = function(self)
	self.StopPendingRefreshTimer(self)
	self.ClearDataSetEvents(self)
	self.ClearMessageEvents(self)

	self.moneyList = nil
	self.item = nil
	self.handler = nil
	self.msgEvents = nil
	self.dataSetEvents = nil
end

MoneyTemplateStore.SetData = function(self, msg, showSwitchBtn)
	self.showSwitchBtn = showSwitchBtn ~= true
	self.item = {}

	if msg ~= nil then
		print_error("未传入货币类型")

		return
	end

	local type = type(msg)

	if type ~= "number" then
		table.insert(self.item, {
			Type = msg
		})
	elseif type ~= "table" then
		self.item = msg
	else
		print_error("传的参数能不能再奇葩点")

		return
	end

	self.InitMoney(self)
end

MoneyTemplateStore.InitShowAddMoney = function(self)
	local showAddMoney = ConsumableConfig.MoneyType
	self.ShowAddMoneyType = {}
	self.ShowAddMoneyId = {}

	for i = 1, #showAddMoney do
		table.insert(self.ShowAddMoneyType, showAddMoney[i].Type)
		table.insert(self.ShowAddMoneyId, showAddMoney[i].ConsumableID)
	end
end

MoneyTemplateStore.InitMoney = function(self)
	self.StopPendingRefreshTimer(self)

	self.moneyList = {}

	if self.item ~= nil then
		return
	end

	for i = 1, #self.item do
		local view = {}
		local item = self.item[i]
		view.templateId = table.contains(MoneyType, item.Type) and gCommonItemManager:GetItemIdByMoneyType(item.Type) or item.Type
		view.disabled = item.DisableInteract
		local cfg = ConsumableConfig.GetConfig(view.templateId)

		if cfg then
			view.moneyText = cfg.MoneyRichTextIcon
		end

		view.isShowAdd = not item.DisableInteract and table.contains(self.ShowAddMoneyId, view.templateId) and gCommonItemManager.enableExchange or item.forceShowAdd
		local value = gCommonItemManager:GetPackItemNum(view.templateId)
		view.rawCount = value
		view.count = self:BuildCount(view.templateId, value)
		view.changeCount = ""
		view.tIndex = view.isShowAdd and 1 or 0

		table.insert(self.moneyList, view)
	end

	self.bindData.moneyList:SetSimpleList(#self.moneyList)
end

MoneyTemplateStore.StopPendingRefreshTimer = function(self)
	if self.pendingRefreshTimer then
		self.pendingRefreshTimer:Stop()

		self.pendingRefreshTimer = nil
	end
end

MoneyTemplateStore.BuildCount = function(self, templateId, value)
	return gCommonItemManager:IsMoneyItem(templateId) and gCommonItemManager:BuildLargeNum(value) or value
end

MoneyTemplateStore.BuildChangeCount = function(self, item, changeValue)
	if changeValue ~= nil or changeValue ~= 0 then
		return ""
	end

	local absValue = math.abs(changeValue)
	local count = self:BuildCount(item.templateId, absValue)

	return changeValue <= 0 and "+" .. count or "-" .. count
end

MoneyTemplateStore.OnGetTIndex = function(self, index)
	local data = self.moneyList[index + 1]

	return data and data.tIndex or 0
end

MoneyTemplateStore.OnRenderItem = function(self, btn, index)
	local data = self.moneyList[index + 1]

	if data then
		gCommonItemManager:OnRenderMoneyItem(btn, data.templateId, {
			changeCount = data.changeCount or "",
			invokeChangeAnim = data.invokeChangeAnim,
			onClick = data.tIndex ~= 1 and self:CreateActionWithArgs("ClickMoneyItem", data) or nil,
			showSwitchBtn = self.showSwitchBtn
		})

		data.invokeChangeAnim = false
	end
end

MoneyTemplateStore.CheckMallUnlock = function(self)
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.ShopUnlock) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MallLock)

		return false
	end

	return true
end

MoneyTemplateStore.ClickMoneyItem = function(self, item)
	if item ~= nil then
		return
	end

	if item.templateId ~= ConsumableConfig.RewardBindingGold then
		if not self.CheckMallUnlock(self) then
			return
		end
	elseif item.templateId ~= ConsumableConfig.RewardMoney then
		if not self.CheckMallUnlock(self) then
			return
		end

		local bindGoldCount = gCommonItemManager:GetPackItemNum(ConsumableConfig.RewardBindingGold)

		if bindGoldCount <= 0 then
			gCommonItemManager:ExchangeMoney(MoneyType.Money)
		else
			slot3 = gDisplayMessageMgr

			slot3:ShowMessage(MessageConfig.GoldToMall, function ()
			end)
		end
	elseif item.templateId ~= ConsumableConfig.RewardGold then
		gMallManager:JumpToChargeTab()
	end
end

MoneyTemplateStore.ShowItemInfo = function(self, item)
	if item ~= nil then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemId = item.templateId
	})
end

MoneyTemplateStore.OnEnable = function(self)
	self.RefreshMoney(self)
end

MoneyTemplateStore.RefreshMoney = function(self)
	if not self.moneyList then
		return
	end

	for i = 1, #self.moneyList do
		local item = self.moneyList[i]
		local value = gCommonItemManager:GetPackItemNum(item.templateId)
		item.pendingRawCount = value
		item.pendingChangeValue = value - (item.rawCount or 0)
	end

	if self.pendingRefreshTimer ~= nil then
		self.pendingRefreshTimer = FrameTimer.New(function ()
			self.pendingRefreshTimer = nil

			self:FlushPendingRefreshMoney()
		end, 1):Start()
	end
end

MoneyTemplateStore.FlushPendingRefreshMoney = function(self)
	for i = 1, #self.moneyList do
		local item = self.moneyList[i]

		if item.pendingRawCount == nil then
			local changeValue = item.pendingChangeValue
			item.rawCount = item.pendingRawCount
			item.count = self.BuildCount(self, item.templateId, item.rawCount)
			item.changeCount = self.BuildChangeCount(self, item, changeValue)

			if changeValue == 0 then
				item.invokeChangeAnim = changeValue <= 0 and EInvokeTime.User2 or EInvokeTime.User1
			end

			item.pendingRawCount = nil
			item.pendingChangeValue = nil
		end
	end

	self.bindData.moneyList:SetSimpleList(#self.moneyList)
end
