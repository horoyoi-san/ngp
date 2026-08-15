local MoneyType = UX.Game.MoneyType
C_SynthesizePanelStore = DefClass("C_SynthesizePanelStore", C_SynthesizePanelStore, C_StoreGroup)
GroupName2Class.SynthesizePanelStore = C_SynthesizePanelStore
local M = C_SynthesizePanelStore

function M:ctor()
	self.tabList = {}
	self.formulaId = 0
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnTabRender")
end

function M:OnCloseBtnClick()
	gProduceManager:UnRegisterMachine()
	gPanelManager:Close(gPanelId.S_SYNTHESIZE_PANEL)
end

function M:OnShow(panelId, data)
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

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnTabSelectedChanged(uList)
	local index = uList.selectedIndex

	self:SetTabIndex(index)
end

function M:SetTabIndex(index)
	if self.bindData.tabIndex == index then
		return
	end

	self.bindData.tabIndex = index
	self.bindData.titleLabel = self.tabList[index + 1] and self.tabList[index + 1].label or ""
end

function M:OnTabRender(index, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)

	if store then
		store:OnRefreshPage()
	end
end

function M:InitTab(index)
	self.tabList = gProduceManager:GetPanelTabList(1)

	self.SubGroup.CommonTabSingleStore:SetData(self.tabList, nil, 0, nil, self:CreateAction("OnTabSelectedChanged"))
	self:SetTabIndex(index)
end
