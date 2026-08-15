C_CommonBuyWindowTemplate1Store = DefClass("C_CommonBuyWindowTemplate1Store", C_CommonBuyWindowTemplate1Store, C_StoreGroup)
GroupName2Class.CommonBuyWindowTemplate1Store = C_CommonBuyWindowTemplate1Store
local M = C_CommonBuyWindowTemplate1Store

function M:ctor(name, id, isSub)
	self.data = {}
end

local STATE = {
	NORMAL = 0,
	SOLD_OUT = 2,
	LOCK = 1
}

function M:GetParent()
	return gStoreManager:GetStoreGroup("CommonBuyWindowPanelStore")
end

function M:OnAwake()
	return
end

function M:OnDestroy()
	return
end

function M:OnStart()
	self.data = self:GetParent().data

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

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end
