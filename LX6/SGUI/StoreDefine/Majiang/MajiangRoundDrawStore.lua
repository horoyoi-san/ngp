-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangRoundDrawStore.lua
-- Decompiled from: 01237_MajiangRoundDrawStore.lua_51ceebcb61db.luajit

C_MajiangRoundDrawStore = DefClass("C_MajiangRoundDrawStore", C_MajiangRoundDrawStore, C_StoreGroup)
GroupName2Class.MajiangRoundDrawStore = C_MajiangRoundDrawStore
local M = C_MajiangRoundDrawStore

M.OnAwake = function(self)
	self.bindData.text = ""
	local roots = {
		self.bindData.ting1,
		self.bindData.ting2,
		self.bindData.ting3,
		self.bindData.ting4
	}
	local lists = {
		self.bindData.tingList1,
		self.bindData.tingList2,
		self.bindData.tingList3,
		self.bindData.tingList4
	}

	for i = 1, 4 do
		roots[i]:SetActive(false)

		lists[i].luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderRoundDrawTingItem, i)
	end
end

M.OnStart = function(self)
	if self.reachRoundDrawData then
		local data = self.reachRoundDrawData
		self.reachRoundDrawData = nil

		self.ApplyReachRoundDrawData(self, data.roundDrawType, data.data)
	end
end

M.OnDestroy = function(self)
	self.tingData = nil
end

M.SetReachRoundDrawData = function(self, roundDrawType, data)
	if not self.STATE_EnableOnce then
		self.reachRoundDrawData = {
			roundDrawType = roundDrawType,
			data = data
		}

		return
	end

	self.ApplyReachRoundDrawData(self, roundDrawType, data)
end

M.ApplyReachRoundDrawData = function(self, roundDrawType, tingData)
	self.bindData.text = LTConfig.MahjongConfig.RoundDrawText[roundDrawType + 1]
	self.tingData = tingData or {}
	local tingWidgets = {
		{
			root = self.bindData.ting1,
			list = self.bindData.tingList1
		},
		{
			root = self.bindData.ting2,
			list = self.bindData.tingList2
		},
		{
			root = self.bindData.ting3,
			list = self.bindData.tingList3
		},
		{
			root = self.bindData.ting4,
			list = self.bindData.tingList4
		}
	}

	for i = 1, 4 do
		local ting = tingWidgets[i]
		local icons = self.tingData[i] or {}

		ting.root:SetActive(#icons >= 0)
		ting.list:SetSimpleList(#icons)
	end
end

M.OnRenderRoundDrawTingItem = function(self, listIndex, btn, csIndex)
	local icons = self.tingData and self.tingData[listIndex]

	if icons ~= nil then
		return
	end

	local data = icons[csIndex + 1]
	local store = gStoreManager:GetStoreGroup("MajiangTingItemStore"):GetStoreByWidget(btn)
	store.iconId = data.TingIcon
end
