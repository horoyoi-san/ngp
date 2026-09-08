-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonBuyWindowTemplate1Store.lua
-- Decompiled from: 01444_CommonBuyWindowTemplate1Store.lua_ff1df57cb1b9.luajit

C_CommonBuyWindowTemplate1Store = DefClass("C_CommonBuyWindowTemplate1Store", C_CommonBuyWindowTemplate1Store, C_StoreGroup)
GroupName2Class.CommonBuyWindowTemplate1Store = C_CommonBuyWindowTemplate1Store
local M = C_CommonBuyWindowTemplate1Store

M.ctor = function(self, name, id, isSub)
	self.data = {}
end

local STATE = {
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["\\x98\\x9e)\\x8fU\\xcb"] = 2,
	["V\r^p"] = 1
}

M.GetParent = function(self)
	return gStoreManager:GetStoreGroup("CommonBuyWindowPanelStore")
end

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
	self.data = self.GetParent(self).data

	if table.isNilOrEmpty(self.data) then
		print_error("C_CommonBuyWindowTemplate1Store:OnStart data is nil")

		return
	end

	self.bindData.state = STATE.NORMAL

	if self.data.unLockDesc then
		self.bindData.unLockLabel = self.data.unLockDesc
		self.bindData.state = STATE.LOCK
	end

	self.bindData.descList:InitSimpleList()
	self.bindData.descList:AddSimpleLabel(0, self.data.shortDesc)
	self.bindData.descList:AddSimpleLabel(1, self.data.description)
	self.bindData.descList:RefreshList()
	self.SubGroup.CommonBuyNumSliderStore:SetData({
		data = self.data,
		range = self:GetParent().range,
		valChangeCallback = self:CreateAction("OnBuyNumChange", self:GetParent())
	})

	self.bindData.state = self:GetParent():HasRemainItem() and self.bindData.state or STATE.SOLD_OUT
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end
