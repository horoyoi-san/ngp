-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonBuyWindowTemplate3Store.lua
-- Decompiled from: 01447_CommonBuyWindowTemplate3Store.lua_20901d3fbb61.luajit

C_CommonBuyWindowTemplate3Store = DefClass("C_CommonBuyWindowTemplate3Store", C_CommonBuyWindowTemplate3Store, C_StoreGroup)
GroupName2Class.CommonBuyWindowTemplate3Store = C_CommonBuyWindowTemplate3Store
local M = C_CommonBuyWindowTemplate3Store

M.GetParent = function(self)
	return gStoreManager:GetStoreGroup("CommonBuyWindowPanelStore")
end

M.OnAwake = function(self)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderCommonBuyItem)
	self.itemList = {}
end

M.OnRenderCommonBuyItem = function(self, btn, index, data)
	local data = self.itemList[index + 1]

	gCommonItemManager:OnRenderCommonBuyItem(btn, index, data)
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
	local data = self.GetParent(self).data

	if not data or not data.rewardList then
		print_error("C_CommonBuyWindowTemplate2Store:OnStart data is nil")

		return
	end

	self.itemList = data.rewardList

	self.bindData.itemList:SetSimpleList(#self.itemList)
	self.SubGroup.CommonBuyNumSliderStore:SetData({
		data = self:GetParent().data,
		range = self:GetParent().range,
		valChangeCallback = self:CreateAction("OnBuyNumChange", self:GetParent())
	})
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end
