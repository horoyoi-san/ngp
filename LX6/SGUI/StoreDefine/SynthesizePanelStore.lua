-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SynthesizePanelStore.lua
-- Decompiled from: 01382_SynthesizePanelStore.lua_9942260915d5.luajit

local MoneyType = UX.Game.MoneyType
C_SynthesizePanelStore = DefClass("C_SynthesizePanelStore", C_SynthesizePanelStore, C_StoreGroup)
GroupName2Class.SynthesizePanelStore = C_SynthesizePanelStore
local M = C_SynthesizePanelStore

M.ctor = function(self)
	self.tabList = {}
	self.formulaId = 0
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRender")
end

M.OnCloseBtnClick = function(self)
	gProduceManager:UnRegisterMachine()
	gPanelManager:Close(gPanelId.S_SYNTHESIZE_PANEL)
end

M.OnShow = function(self, panelId, data)
	local tabIndex = 0

	if gProduceManager.produceId then
		self.formulaId = gProduceManager.produceId
	end

	if data then
		self.formulaId = data.formulaId and data.formulaId or 0
	end

	self:InitTab(tabIndex)
	self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)
	gProduceManager:SetPanelEnterCam()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnTabSelectedChanged = function(self, uList)
	local index = uList.selectedIndex

	self.SetTabIndex(self, index)
end

M.SetTabIndex = function(self, index)
	if self.bindData.tabIndex ~= index then
		return
	end

	self.bindData.tabIndex = index
	self.bindData.titleLabel = self.tabList[index + 1] and self.tabList[index + 1].label or ""
end

M.OnTabRender = function(self, index, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)

	if store then
		store.OnRefreshPage(store)
	end
end

M.OnTabListRender = function(self, btn, index, data, store, isSub)
	if store then
		store.guideId = data.guideId
	end
end

M.InitTab = function(self, index)
	self.tabList = gProduceManager:GetPanelTabList(1)

	self.SubGroup.CommonTabSingleStore:SetData(self.tabList, nil, 0, nil, self:CreateAction("OnTabSelectedChanged"), self:CreateAction("OnTabListRender"))
	self:SetTabIndex(index)
end
