-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RoguelikeItemSelectPanelStore.lua
-- Decompiled from: 00858_RoguelikeItemSelectPanelStore.lua_feddfe95654f.luajit

C_RoguelikeItemSelectPanelStore = DefClass("C_RoguelikeItemSelectPanelStore", C_RoguelikeItemSelectPanelStore, C_StoreGroup)
GroupName2Class.RoguelikeItemSelectPanelStore = C_RoguelikeItemSelectPanelStore
local M = C_RoguelikeItemSelectPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.selectType = nil
	self.itemIds = {}
	self.cardList = {}
	self.selectedIndex = 0
	self.isReporting = false
	self.LIST_TEMPLATE = {
		["X[}"] = 1,
		["+m\\xb0\\xbe\\xaco"] = 0
	}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterButtons(self)
	self.RegisterLists(self)
end

M.OnShow = function(self, panelId, data)
	if data ~= nil then
		print_error("[RoguelikeItemSelect] OnShow data is nil")

		return
	end

	self.selectType = data.selectType or gRoguelikeManager.SELECT_TYPE.BUFF
	self.itemIds = data.itemIds or {}
	self.selectedIndex = 0
	self.isReporting = false

	self:RefreshList()
	self:UpdateContinueBtn()
end

M.OnClose = function(self)
	self.selectType = nil
	self.itemIds = {}
	self.cardList = {}
	self.selectedIndex = 0
	self.isReporting = false
end

M.RegisterButtons = function(self)
	self.bindData.continueBtn.luaClick = self.CreateAction(self, "OnContinueBtnClick")
	self.bindData.skipBtn.luaClick = self.CreateAction(self, "OnSkipBtnClick")
end

M.OnSkipBtnClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnContinueBtnClick = function(self)
	if self.isReporting then
		return
	end

	if self.selectedIndex ~= 0 then
		gPanelManager:Close(self.m_Id)

		return
	end

	self.DoReport(self, self.selectedIndex - 1)
end

M.DoReport = function(self, index)
	self.isReporting = true
	self.bindData.continueBtn.interactable = false

	gRoguelikeManager:ReportSelectTempItem(self.selectType, index)
	gPanelManager:Close(self.m_Id)
end

M.RegisterLists = function(self)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.itemList.luaSelectedChanged = self.CreateAction(self, "OnClickItem")
	self.bindData.itemList.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
end

M.RefreshList = function(self)
	table.clear(self.cardList)

	for i, itemId in ipairs(self.itemIds) do
		table.insert(self.cardList, {
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			itemId = itemId,
			cardIndex = i
		})
	end

	self.bindData.itemList:SetSimpleList(#self.cardList)
end

M.OnGetTIndex = function(self, index)
	return self.selectType ~= gRoguelikeManager.SELECT_TYPE.WEAPON and self.LIST_TEMPLATE.WEAPON or self.LIST_TEMPLATE.BUFF
end

M.OnRenderItem = function(self, btn, index)
	local data = self.cardList[index + 1]

	if not data then
		return
	end

	local store = self:GetStoreById(btn.gameObject:GetInstanceID())

	if not store or not store.commonToolTip then
		return
	end

	local storeName = store.commonToolTip.Store
	local tip = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(store.commonToolTip)

	if not tip then
		return
	end

	if self.selectType ~= gRoguelikeManager.SELECT_TYPE.WEAPON then
		self.RenderWeaponTooltip(self, tip, data.itemId)
	else
		gRoguelikeManager:RenderBuffTooltip(tip, data.itemId)
	end
end

M.RenderWeaponTooltip = function(self, tip, itemId)
	local mgr = gCommonItemManager
	local itemInfo = mgr.TryGetItemInfo(mgr, {
		TemplateId = itemId
	})

	if table.isNilOrEmpty(itemInfo) then
		return
	end

	tip.nameLabel = itemInfo.name
	tip.iconId = itemInfo.iconId
	tip.quality = itemInfo.quality
	tip.typeQuality = mgr:GetItemQualityLabel(itemInfo)
	tip.showBtn = 0
	tip.showCounter = 0
	tip.showSumCtrl = 0
	tip.itemType = mgr:GetItemDisplayType(itemId)
	local descList = {}

	mgr:GetItemDescList(itemInfo, descList)

	tip.descList.luaSimpleRenderItem = function(descBtn, descIndex)
		mgr:OnRenderDescItem(descBtn, descIndex, descList[descIndex + 1])
	end

	tip.descList.onGetTIndex = function(descIndex)
		return descList[descIndex + 1].tIndex
	end

	tip.descList:SetSimpleList(#descList)

	local elementList = mgr:GetItemElementList(itemId)

	tip.elementList.luaSimpleRenderItem = function(eleBtn, eleIndex)
		mgr:OnRenderItemElementList(eleBtn, eleIndex, elementList[eleIndex + 1])
	end

	tip.elementList:SetSimpleList(#elementList)

	local tagList = mgr:GetItemTagList(itemInfo)

	tip.tagList.luaSimpleRenderItem = function(tagBtn, tagIndex)
		mgr:OnRenderToolTipTagList(tagBtn, tagIndex, tagList[tagIndex + 1])
	end

	tip.tagList:SetSimpleList(#tagList)
end

M.OnClickItem = function(self, uList)
	if self.isReporting then
		return
	end

	self.selectedIndex = uList.selectedIndex + 1

	self.UpdateContinueBtn(self)
end

M.UpdateContinueBtn = function(self)
	if self.selectedIndex <= 0 then
		self.bindData.btnStatusCtrl = 0
	else
		self.bindData.btnStatusCtrl = 1
	end
end
