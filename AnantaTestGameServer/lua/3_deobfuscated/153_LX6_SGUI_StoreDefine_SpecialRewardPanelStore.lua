local DropConfig = LTConfig.DropConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
C_SpecialRewardPanelStore = DefClass("C_SpecialRewardPanelStore", C_SpecialRewardPanelStore, C_StoreGroup)
GroupName2Class.SpecialRewardPanelStore = C_SpecialRewardPanelStore
local M = C_SpecialRewardPanelStore
local ITEM_TYPE = {
	HOUSE = 3,
	COMMON = 4,
	CHARACTER = 0,
	FASHION = 1,
	VEHICLE = 2
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

function M:ctor()
	self.timer = nil
	self.callbacks = {}
	self.btnCallback = nil
	self.mgr = gCommonItemManager
end

function M:OnAwake()
	self.bindData.dropBtn.luaClick = self:CreateActionWithArgs("OnDropBtnClick", true)
end

function M:OnShow(panelId, data)
	if not data then
		self:OnDropBtnClick()

		return
	end

	self.data = self.mgr:TryGetSpecialItemInfo(data.itemInfo)

	if table.isNilOrEmpty(self.data) then
		self:OnDropBtnClick()

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

	gPanelManager:Close(gPanelId.S_SPECIAL_REWARD_PANEL)

	if not table.isNilOrEmpty(self.callbacks) then
		for _, func in pairs(self.callbacks) do
			func()
		end
	end
end
