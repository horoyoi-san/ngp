local DropConfig = LTConfig.DropConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
C_SpecialRewardMainPanelStore = DefClass("C_SpecialRewardMainPanelStore", C_SpecialRewardMainPanelStore, C_StoreGroup)
GroupName2Class.SpecialRewardMainPanelStore = C_SpecialRewardMainPanelStore
local M = C_SpecialRewardMainPanelStore
local ITEM_TYPE = {
	HOUSE = 3,
	COMMON = -1,
	CHARACTER = 0,
	FASHION = 2,
	VEHICLE = 1
}
local SUBTYPE2ITEM_TYPE = {
	[ConsumableTypeConfig.Character] = ITEM_TYPE.CHARACTER,
	[ConsumableTypeConfig.Vehicle] = ITEM_TYPE.VEHICLE,
	[ConsumableTypeConfig.Fashion] = ITEM_TYPE.FASHION,
	[ConsumableTypeConfig.House] = ITEM_TYPE.HOUSE
}

function M:ctor()
	self.timer = nil
	self.callbacks = {}
	self.btnCallback = nil
	self.data = {}
	self.mgr = gCommonItemManager
end

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.onTabRectRender)
	self.bindData.backGroundBtn.luaClick = self:CreateAction(self.OnDropBtnClick)
end

function M:OnShow(panelId, data)
	if table.isNilOrEmpty(data) then
		self:OnDropBtnClick()

		return
	end

	self.data = self.mgr:TryGetSpecialItemInfo(data.itemInfo)

	if table.isNilOrEmpty(self.data) then
		self:OnDropBtnClick()

		return
	end

	self.bindData.tabRect.selectedIndex = SUBTYPE2ITEM_TYPE[self.data.subType] or ITEM_TYPE.COMMON
	local duration = DropConfig.SpecialDropShowTime
	self.timer = Timer.New(function ()
		self:OnDropBtnClick()
	end, duration):Start()
end

function M:OnClose()
	return
end

local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:onTabRectRender(index, widget)
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

function M:OnClose()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function M:OnDropBtnClick(isBtn)
	if self.btnCallback and isBtn == true then
		self.btnCallback()
	end

	gPanelManager:Close(self.m_Id)

	if not table.isNilOrEmpty(self.callbacks) then
		for _, func in pairs(self.callbacks) do
			func()
		end
	end
end
