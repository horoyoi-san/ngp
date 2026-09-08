-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonBuyWindowTemplate2Store.lua
-- Decompiled from: 01445_CommonBuyWindowTemplate2Store.lua_9e81678a625f.luajit

C_CommonBuyWindowTemplate2Store = DefClass("C_CommonBuyWindowTemplate2Store", C_CommonBuyWindowTemplate2Store, C_StoreGroup)
GroupName2Class.CommonBuyWindowTemplate2Store = C_CommonBuyWindowTemplate2Store
local M = C_CommonBuyWindowTemplate2Store

M.GetParent = function(self)
	return gStoreManager:GetStoreGroup("CommonBuyWindowPanelStore")
end

local STATE = {
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["\\x98\\x9e)\\x8fU\\xcb"] = 2,
	["V\r^p"] = 1
}

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
	self.bindData.state = STATE.NORMAL

	if self.data.unLockDesc then
		self.bindData.unLockLabel = self.data.unLockDesc
		self.bindData.state = STATE.LOCK
	end

	self.bindData.state = self:GetParent():HasRemainItem() and self.bindData.state or STATE.SOLD_OUT

	self.bindData.itemList:SetSimpleList(#self.itemList)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end
