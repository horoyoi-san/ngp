-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FarmBuyNumSliderStore.lua
-- Decompiled from: 02078_FarmBuyNumSliderStore.lua_a758b08ab03b.luajit

C_FarmBuyNumSliderStore = DefClass("C_FarmBuyNumSliderStore", C_FarmBuyNumSliderStore, C_CommonBuyNumSliderStore)
GroupName2Class.FarmBuyNumSliderStore = C_FarmBuyNumSliderStore
local M = C_FarmBuyNumSliderStore

M.SetFarmData = function(self, param, recommendedPrice)
	self.recommendedPrice = recommendedPrice or 0

	M.base.SetData(self, param)
end

M.OnUpdateMoneyLabel = function(self)
	self.bindData.moneyNumLabel = "推荐价格" .. tostring(self.recommendedPrice or 0)
end
