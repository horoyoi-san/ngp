C_CommonBuyWindowTemplate3Store = DefClass("C_CommonBuyWindowTemplate3Store", C_CommonBuyWindowTemplate3Store, C_StoreGroup)
GroupName2Class.CommonBuyWindowTemplate3Store = C_CommonBuyWindowTemplate3Store
local M = C_CommonBuyWindowTemplate3Store

function M:GetParent()
	return gStoreManager:GetStoreGroup("CommonBuyWindowPanelStore")
end

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

	self.bindData.itemList:SetSimpleList(#self.itemList)
	self.SubGroup.CommonBuyNumSliderStore:SetData({
		data = self:GetParent().data,
		range = self:GetParent().range,
		valChangeCallback = self:CreateAction("OnBuyNumChange", self:GetParent())
	})
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
