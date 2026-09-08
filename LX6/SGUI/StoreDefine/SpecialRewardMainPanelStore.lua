-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SpecialRewardMainPanelStore.lua
-- Decompiled from: 01292_SpecialRewardMainPanelStore.lua_29d0c25313f6.luajit

local DropConfig = LTConfig.DropConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
C_SpecialRewardMainPanelStore = DefClass("C_SpecialRewardMainPanelStore", C_SpecialRewardMainPanelStore, C_StoreGroup)
GroupName2Class.SpecialRewardMainPanelStore = C_SpecialRewardMainPanelStore
local M = C_SpecialRewardMainPanelStore
local ITEM_TYPE = {
	["e\\x81\\x97\\x9c\\x93"] = 3,
	["?g\\xbc\\xa3\\xaco"] = -1,
	["`oM[o=%7\n"] = 0,
	["\\xff\\xfa'57\\xdf"] = 2,
	["\\xef\\xfe<4=\\xd4"] = 1
}
local SUBTYPE2ITEM_TYPE = {
	[ConsumableTypeConfig.Character] = ITEM_TYPE.CHARACTER,
	[ConsumableTypeConfig.Vehicle] = ITEM_TYPE.VEHICLE,
	[ConsumableTypeConfig.Fashion] = ITEM_TYPE.FASHION,
	[ConsumableTypeConfig.House] = ITEM_TYPE.HOUSE
}

M.ctor = function(self)
	self.timer = nil
	self.callbacks = {}
	self.btnCallback = nil
	self.data = {}
	self.mgr = gCommonItemManager
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.onTabRectRender)
	self.bindData.backGroundBtn.luaClick = self.CreateAction(self, self.OnDropBtnClick)
end

M.OnShow = function(self, panelId, data)
	if table.isNilOrEmpty(data) then
		self.OnDropBtnClick(self)

		return
	end

	self.data = self.mgr:TryGetSpecialItemInfo(data.itemInfo)

	if table.isNilOrEmpty(self.data) then
		self.OnDropBtnClick(self)

		return
	end

	self.bindData.tabRect.selectedIndex = SUBTYPE2ITEM_TYPE[self.data.subType] or ITEM_TYPE.COMMON
	local duration = DropConfig.SpecialDropShowTime
	self.timer = Timer.New(function ()
		self:OnDropBtnClick()
	end, duration):Start()
end

M.OnClose = function(self)
end

local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.onTabRectRender = function(self, index, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	store.nameLabel = self.data.name
	store.descLabel = self.data.desc
	store.iconId = self.data.icon
	store.isSpecial = BOOL2CTL[self.data.isSpecial]
	store.subIconId = self.data.subIcon
	store.additionIcon = self.data.additionIcon
	store.quality = self.data.quality
end

M.OnClose = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.OnDropBtnClick = function(self, isBtn)
	if self.btnCallback and isBtn ~= true then
		self.btnCallback()
	end

	gPanelManager:Close(self.m_Id)

	if not table.isNilOrEmpty(self.callbacks) then
		for _, func in pairs(self.callbacks) do
			func()
		end
	end
end
