C_ItemInfoPanelStore = DefClass("C_ItemInfoPanelStore", C_ItemInfoPanelStore, C_StoreGroup)
GroupName2Class.ItemInfoPanelStore = C_ItemInfoPanelStore
local M = C_ItemInfoPanelStore

function M:ctor(name, id, isSub)
	self:Init()
end

function M:Init()
	self.mgr = gCommonItemManager
	self.data = {}
	self.itemList = {}
	self.itemIndex = 1
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self:CreateAction("RefreshItemNum")
	}
end

function M:OnAwake()
	self.bindData.backGround.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.descList.luaSimpleRenderItem = self:CreateAction(self.OnRenderDescItem)
	self.bindData.descList.luaSimpleClick = self:CreateAction(self.OnDescItemClick)
	self.bindData.descList.onGetTIndex = self:CreateAction(self.OnGetDescIndex)
	self.bindData.rewardList.luaSimpleRenderItem = self:CreateAction(self.OnCommonItemRender)
	self.bindData.rewardList.luaSimpleClick = self:CreateAction(self.OnRewardListClick)
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnSwitchItem", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnSwitchItem", 1)
	self.bindData.tagList.luaSimpleRenderItem = self:CreateAction(self.OnRenderToolTipTagList)
	self.descList = {}
	self.rewardList = {}
end

function M:OnRenderDescItem(btn, index)
	local data = self.descList[index + 1]

	self.mgr:OnRenderDescItem(btn, index, data)
end

function M:OnDescItemClick(btn, index)
	local data = self.descList[index + 1]

	self.mgr:OnDescItemClick(btn, index, data)
end

function M:OnGetDescIndex(index)
	return self.descList[index + 1].tIndex
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnRenderToolTipTagList(btn, index)
	local data = self.tagList[index + 1]

	if not data then
		return
	end

	gNpcFavorManager:OnRenderToolTipTagList(btn, index, data)
end

function M:OnShow(panelId, data)
	self.bindData.showList = 1

	if data then
		self.bindData.blurBg:ActiveBlur()

		if data.itemId then
			self:RefreshPage(data)

			return
		elseif data.itemList then
			if #data.itemList == 1 then
				self:RefreshPage(data.itemList[1])

				return
			end

			self.bindData.showList = 0
			self.itemList = data.itemList
			self.itemIndex = data.selectIndex or 1

			if self.itemIndex < 1 or self.itemIndex > #self.itemList then
				self.itemIndex = 1
			end

			for i = 1, #self.itemList do
				self.itemList[i].arrayIndex = i
				self.itemList[i].itemNum = ""
			end

			self:RefreshPage(self.itemList[self.itemIndex])
			self.bindData.rewardList:SetSimpleList(#self.itemList)
			self:OnSelectItem()

			return
		end
	end

	print_error("S_ITEM_INFO_PANELShowData is nil")
	self:OnCloseBtnClick()
end

function M:OnClose()
	self:Init()
end

function M:OnCloseBtnClick()
	gUIUtils:PlayAniClosePanel(self.bindData.animation, "S_Vx_NewCommonWindow_Close", gPanelId.S_ITEM_INFO_PANEL)
end

function M:OnCommonItemRender(btn, index)
	local data = self.itemList[index + 1]

	self.mgr:OnCommonItemRender(btn, index, data)
end

function M:OnRewardListClick(btn, index)
	local data = self.itemList[index + 1]

	self:OnSwitchItem(data.arrayIndex - self.itemIndex)
end

function M:OnSwitchItem(step)
	local itemIndex = 0

	if self.itemIndex + step < 1 then
		itemIndex = #self.itemList
	elseif self.itemIndex + step > #self.itemList then
		itemIndex = 1
	else
		itemIndex = self.itemIndex + step
	end

	if self.itemIndex ~= itemIndex then
		self.itemIndex = itemIndex

		self:RefreshPage(self.itemList[self.itemIndex])
		self:OnSelectItem()
	end
end

function M:OnSelectItem()
	self.bindData.rewardList:SelectItem(self.itemIndex - 1)
	self.bindData.rewardList:GoToIndex(math.max(self.itemIndex - 4, 0), true)
end

function M:RefreshPage(data)
	self.data = self.mgr:TryGetItemInfo(data)

	if table.isNilOrEmpty(self.data) then
		print_error("RefreshPage data is nil")

		return
	end

	self:RefreshSideInfo()

	self.bindData.hasHave = 0

	self:RefreshItemNum()

	self.descList = {}

	self.mgr:GetItemDescList(self.data, self.descList)
	self.bindData.descList:SetSimpleList(#self.descList)
	self.bindData.descList:SetNavSelectToTop()

	self.tagList = gNpcFavorManager:GetItemTagList(self.data)

	self.bindData.tagList:SetSimpleList(#self.tagList)
end

function M:RefreshSideInfo()
	self.bindData.nameLabel = self.data.name
	self.bindData.quality = self.data.quality
	self.bindData.iconId = self.data.iconId
	self.bindData.itemType = self.mgr:GetItemDisplayType(self.data.itemId)
end

function M:RefreshItemNum()
	if self.data.showCount ~= true or self.mgr:IsItemNumDisabled(self.data.itemId) then
		return
	end

	self.bindData.hasHave = 1
	self.bindData.haveLabel = self.mgr:GetItemNum(self.data.itemId)
end
