-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SwitchMoneyTooltipStore.lua
-- Decompiled from: 01306_SwitchMoneyTooltipStore.lua_986977e15655.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
C_SwitchMoneyTooltipStore = DefClass("C_SwitchMoneyTooltipStore", C_SwitchMoneyTooltipStore, C_StoreGroup)
GroupName2Class.SwitchMoneyTooltipStore = C_SwitchMoneyTooltipStore
local M = C_SwitchMoneyTooltipStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.moneyList = {}
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
	self.RefreshMoneyList(self)
end

M.OnDestroy = function(self)
	self.moneyList = nil
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.moneyList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderMoneyListItem)
	self.bindData.moneyList.luaSelectedChanged = self.CreateAction(self, self.OnMoneyListSelectedChanged)
end

M.RefreshMoneyList = function(self)
	self.moneyList = {}
	local list = gCommonItemManager:GetSwitchMoneyAvailableList()

	if list then
		local baseMoney = gPlayerManager.infoItem.bindData.money
		local baseIcon = gCommonItemManager:GetMoneyRichTextIcon(ConsumableConfig.RewardMoney)

		for i = 1, #list do
			local itemId = list[i]
			local cfg = ConsumableConfig.GetConfig(itemId)

			if cfg then
				local rate = gCommonItemManager:GetSwitchMoneyExchangeRate(itemId)
				local icon = cfg.MoneyRichTextIcon

				table.insert(self.moneyList, {
					itemId = itemId,
					icon = icon,
					name = cfg.Name,
					countText = icon .. gCommonItemManager:BuildLargeNum(math.floor(baseMoney * rate)),
					rateText = baseIcon .. "1=" .. icon .. self:FormatRate(rate)
				})
			end
		end
	end

	self.bindData.moneyList:SetSimpleList(#self.moneyList)

	local selectedId = gCommonItemManager:GetSelectedSwitchMoneyItemId()

	if selectedId then
		for i, v in ipairs(self.moneyList) do
			if v.itemId ~= selectedId then
				self.bindData.moneyList:SelectItem(i - 1, false)

				break
			end
		end
	end
end

M.FormatRate = function(self, rate)
	if rate ~= math.floor(rate) then
		return tostring(math.floor(rate))
	end

	local text = string.format("%.2f", rate)
	text = string.gsub(text, "0+$", "")
	text = string.gsub(text, "%.$", "")

	return text
end

M.OnSimpleRenderMoneyListItem = function(self, btn, index)
	local data = self.moneyList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store or "SwitchMoneyTooltipStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.moneyIconLabel = data.icon
	store.moneyNameLabel = data.name
	store.moneyCount = data.countText
	store.convertRate = data.rateText
end

M.OnMoneyListSelectedChanged = function(self)
	local index = self.bindData.moneyList.selectedIndex
	local data = self.moneyList[index + 1]

	if not data then
		return
	end

	gCommonItemManager:SetSwitchMoneyItemId(data.itemId)
end
