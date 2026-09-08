-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ItemInfoPanelStore.lua
-- Decompiled from: 01766_ItemInfoPanelStore.lua_20c14a6af886.luajit

C_ItemInfoPanelStore = DefClass("C_ItemInfoPanelStore", C_ItemInfoPanelStore, C_StoreGroup)
GroupName2Class.ItemInfoPanelStore = C_ItemInfoPanelStore
local M = C_ItemInfoPanelStore

M.ctor = function(self, name, id, isSub)
	self.Init(self)
end

M.Init = function(self)
	self.mgr = gCommonItemManager
	self.data = {}
	self.itemList = {}
	self.itemIndex = 1
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "RefreshItemNum")
	}
end

M.OnAwake = function(self)
	self.bindData.backGround.luaClick = self.CreateAction(self, "OnCloseBtnClick")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
	self.bindData.descList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderDescItem)
	self.bindData.descList.luaSimpleClick = self.CreateAction(self, self.OnDescItemClick)
	self.bindData.descList.onGetTIndex = self.CreateAction(self, self.OnGetDescIndex)
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnCommonItemRender)
	self.bindData.rewardList.luaSimpleClick = self.CreateAction(self, self.OnRewardListClick)
	self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnSwitchItem", -1)
	self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnSwitchItem", 1)
	self.bindData.tagList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderToolTipTagList)
	self.descList = {}
	self.rewardList = {}
end

M.OnRenderDescItem = function(self, btn, index)
	local data = self.descList[index + 1]

	self.mgr:OnRenderDescItem(btn, index, data)
end

M.OnDescItemClick = function(self, btn, index)
	local data = self.descList[index + 1]

	self.mgr:OnDescItemClick(btn, index, data)
end

M.OnGetDescIndex = function(self, index)
	return self.descList[index + 1].tIndex
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnRenderToolTipTagList = function(self, btn, index)
	local data = self.tagList[index + 1]

	if not data then
		return
	end

	gCommonItemManager:OnRenderToolTipTagList(btn, index, data)
end

M.OnShow = function(self, panelId, data)
	self.bindData.showList = 1

	if data then
		self.bindData.blurBg:ActiveBlur()

		if data.itemId then
			self.RefreshPage(self, data)

			return
		elseif data.itemList then
			if #data.itemList ~= 1 then
				self.RefreshPage(self, data.itemList[1])

				return
			end

			self.bindData.showList = 0
			self.itemList = data.itemList
			self.itemIndex = data.selectIndex or 1

			if self.itemIndex <= 1 or self.itemIndex <= #self.itemList then
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
	self.OnCloseBtnClick(self)
end

M.OnClose = function(self)
	self.Init(self)
end

M.OnCloseBtnClick = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.animation, "S_Vx_NewCommonWindow_Close", gPanelId.S_ITEM_INFO_PANEL)
end

M.OnCommonItemRender = function(self, btn, index)
	local data = self.itemList[index + 1]

	self.mgr:OnCommonItemRender(btn, index, data)
end

M.OnRewardListClick = function(self, btn, index)
	local data = self.itemList[index + 1]

	self.OnSwitchItem(self, data.arrayIndex - self.itemIndex)
end

M.OnSwitchItem = function(self, step)
	local itemIndex = 0

	if self.itemIndex + step >= 1 then
		itemIndex = #self.itemList
	elseif self.itemIndex + step <= #self.itemList then
		itemIndex = 1
	else
		itemIndex = self.itemIndex + step
	end

	if self.itemIndex == itemIndex then
		self.itemIndex = itemIndex

		self.RefreshPage(self, self.itemList[self.itemIndex])
		self.OnSelectItem(self)
	end
end

M.OnSelectItem = function(self)
	self.bindData.rewardList:SelectItem(self.itemIndex - 1)
	self.bindData.rewardList:GoToIndex(math.max(self.itemIndex - 4, 0), true)
end

M.RefreshPage = function(self, data)
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

	self.tagList = gCommonItemManager:GetItemTagList(self.data)

	self.bindData.tagList:SetSimpleList(#self.tagList)
end

M.RefreshSideInfo = function(self)
	self.bindData.nameLabel = self.data.name
	self.bindData.quality = self.data.quality
	self.bindData.iconId = self.data.iconId
	self.bindData.itemType = self.mgr:GetItemDisplayType(self.data.itemId)
end

M.RefreshItemNum = function(self)
	if self.data.showCount == true or self.mgr:IsItemNumDisabled(self.data.itemId) then
		return
	end

	self.bindData.hasHave = 1
	self.bindData.haveLabel = self.mgr:GetItemNum(self.data.itemId)
end
