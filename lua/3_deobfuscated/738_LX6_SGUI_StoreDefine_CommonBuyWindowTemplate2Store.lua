C_CommonBuyWindowTemplate2Store = DefClass("C_CommonBuyWindowTemplate2Store", C_CommonBuyWindowTemplate2Store, C_StoreGroup)
GroupName2Class.CommonBuyWindowTemplate2Store = C_CommonBuyWindowTemplate2Store
local M = C_CommonBuyWindowTemplate2Store

function M:GetParent()
	return gStoreManager:GetStoreGroup("CommonBuyWindowPanelStore")
end

local STATE = {
	NORMAL = 0,
	SOLD_OUT = 2,
	LOCK = 1
}

function M:OnAwake()
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction(self.OnRenderCommonBuyItem)
	self.itemList = {}
end

function M:OnRenderCommonBuyItem(btn, index, data)
	local data = self.itemList[index + 1]

	gCommonItemManager:OnRenderCommonBuyItem(btn, index, data)
end

function M:OnDestroy()
	return
end

function M:OnStart()
	local data = self:GetParent().data

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
