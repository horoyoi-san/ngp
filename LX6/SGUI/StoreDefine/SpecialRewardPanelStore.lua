-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SpecialRewardPanelStore.lua
-- Decompiled from: 01307_SpecialRewardPanelStore.lua_ff767e513841.luajit

local DropConfig = LTConfig.DropConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
C_SpecialRewardPanelStore = DefClass("C_SpecialRewardPanelStore", C_SpecialRewardPanelStore, C_StoreGroup)
GroupName2Class.SpecialRewardPanelStore = C_SpecialRewardPanelStore
local M = C_SpecialRewardPanelStore
local ITEM_TYPE = {
	["e\\x81\\x97\\x9c\\x93"] = 3,
	["?g\\xbc\\xa3\\xaco"] = 4,
	["`oM[o=%7\n"] = 0,
	["\\xff\\xfa'57\\xdf"] = 1,
	["\\xef\\xfe<4=\\xd4"] = 2
}
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
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
	self.mgr = gCommonItemManager
end

M.OnAwake = function(self)
	self.bindData.dropBtn.luaClick = self.CreateActionWithArgs(self, "OnDropBtnClick", true)
end

M.OnShow = function(self, panelId, data)
	if not data then
		self.OnDropBtnClick(self)

		return
	end

	self.data = self.mgr:TryGetSpecialItemInfo(data.itemInfo)

	if table.isNilOrEmpty(self.data) then
		self.OnDropBtnClick(self)

		return
	end

	local itemType = SUBTYPE2ITEM_TYPE[self.data.subType] or ITEM_TYPE.COMMON
	self.bindData.itemType = itemType
	self.bindData.nameLabel = self.data.name
	self.bindData.descLabel = self.data.desc
	self.bindData.iconId = self.data.icon
	self.bindData.isSpecial = BOOL2CTL[self.data.isSpecial]
	self.bindData.subIconId = self.data.subIcon
	self.bindData.additionIcon = self.data.additionIcon
	self.bindData.quality = self.data.quality
	local duration = DropConfig.SpecialDropShowTime
	self.timer = Timer.New(function ()
		self:OnDropBtnClick()
	end, duration):Start()
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

	gPanelManager:Close(gPanelId.S_SPECIAL_REWARD_PANEL)

	if not table.isNilOrEmpty(self.callbacks) then
		for _, func in pairs(self.callbacks) do
			func()
		end
	end
end
