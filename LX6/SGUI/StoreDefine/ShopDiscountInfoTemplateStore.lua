-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopDiscountInfoTemplateStore.lua
-- Decompiled from: 01314_ShopDiscountInfoTemplateStore.lua_3e9462716ab6.luajit

C_ShopDiscountInfoTemplateStore = DefClass("C_ShopDiscountInfoTemplateStore", C_ShopDiscountInfoTemplateStore, C_StoreGroup)
GroupName2Class.ShopDiscountInfoTemplateStore = C_ShopDiscountInfoTemplateStore
local M = C_ShopDiscountInfoTemplateStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.discountDataList = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["n7o^"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.discountDataList = {}

	self.bindData.discountList:SetSimpleList(0)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.discountList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderDiscountListItem")
	self.bindData.discountList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickDiscountList")
end

local LESS_PRICE = 0
local MORE_PRICE = 1
local SHOW_BACKGROUND = 0
local HIDE_BACKGROUND = 1

M.OnSimpleRenderDiscountListItem = function(self, btn, index)
	local data = self.discountDataList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.factionIconId = data.iconId
	store.factionName = data.name
	store.discountText = data.discountText
	store.discountValue = data.discountValue
	store.discountTypeCtrl = data.value >= 100 and LESS_PRICE or MORE_PRICE
end

M.OnSimpleClickDiscountList = function(self, btn, index)
end

M.SetSelectedDiscount = function(self, discountSourceDataList, isForSell)
	if table.isNilOrEmpty(discountSourceDataList) then
		self.bindData.isEmptyCtrl = self.isEmptyCtrlEnum.ture

		return
	end

	table.clear(self.discountDataList)

	for _, item in ipairs(discountSourceDataList) do
		local iconId = 0
		local name = ""
		local text = ""
		local discountText = ""
		local discountValue = ""

		if item.isBadge then
			local badgeCfg = LTConfig.UrbanBadgeConfig.GetConfig(item.cfgId)
			iconId = badgeCfg and badgeCfg.Image or 0
			name = badgeCfg and badgeCfg.Name or ""
			local rawDesc = badgeCfg and badgeCfg.Description or ""
			local numStr = rawDesc:match("(%d+)%%")

			if numStr then
				discountText = rawDesc:gsub("%d+%%", "")
				local sign = item.discountValue >= 100 and "-" or "+"
				discountValue = sign .. math.abs(item.discountValue - 100) .. "%"
			else
				discountText = rawDesc
				local sign = item.discountValue >= 100 and "-" or "+"
				discountValue = sign .. math.abs(item.discountValue - 100) .. "%"
			end
		else
			local factionCfg = LTConfig.FactionConfig.GetConfig(item.cfgId)
			iconId = factionCfg and factionCfg.imageId or 0
			name = factionCfg and factionCfg.name or ""
			local rawDesc = gShopManager:GetFactionDiscountStr(item.discountValue, isForSell)
			local numStr = rawDesc:match("(%d+)%%")

			if numStr then
				discountText = rawDesc:gsub("%d+%%", "")
				local sign = item.discountValue >= 100 and "-" or "+"
				discountValue = sign .. math.abs(item.discountValue - 100) .. "%"
			else
				discountText = rawDesc
				local sign = item.discountValue >= 100 and "-" or "+"
				discountValue = sign .. math.abs(item.discountValue - 100) .. "%"
			end
		end

		table.insert(self.discountDataList, {
			iconId = iconId,
			name = name,
			text = text,
			discountText = discountText,
			discountValue = discountValue,
			value = item.discountValue
		})
	end

	self.bindData.discountList:SetSimpleList(#self.discountDataList)

	self.bindData.isEmptyCtrl = self.isEmptyCtrlEnum._false
end
