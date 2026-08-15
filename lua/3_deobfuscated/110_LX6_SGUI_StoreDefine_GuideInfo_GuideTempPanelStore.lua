C_GuideTempPanelStore = DefClass("C_GuideTempPanelStore", C_GuideTempPanelStore, C_StoreGroup)
GroupName2Class.GuideTempPanelStore = C_GuideTempPanelStore
local M = C_GuideTempPanelStore

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.tabBtnList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTabButton)
	self.bindData.tabBtnList.luaClick = self:CreateAction(self.OnTabClick)
	self.bindData.closeBtn.luaClick = self:CreateAction(self.ClosePanel)

	self.bindData.closeBtn:SetActive(false)

	self.bindData.clickToNextTabBtn.luaClick = self:CreateAction(self.ClickToNextTab)
	self.tabCount = self.bindData.tabRect.tabUrlListCount
	self.rootWidget.renderOpacity = 0
end

function M:OnShow(panelId, params)
	self.panelId = panelId
	self.params = params

	if table.isNilOrEmpty(params) then
		self.params = {
			openedByTask = true
		}
	end

	self:InitData()
	self:InitView()
	FrameTimer.New(function ()
		if gClientUtils.NotNil(self.rootWidget) then
			self.rootWidget.renderOpacity = 1
		end
	end, 2):Start()
end

function M:InitData()
	self.currentTabInst = nil
	self.animPlayed = {}
end

function M:InitView()
	self:SetupStartPage(self.params)
	self:InitTabBtnList()
end

function M:SetupStartPage(params)
	local showPage = params.showPage or 0

	if showPage == 0 then
		self.bindData.showPageCtrl = 1

		gSoundMgr:PlaySoundByTid(70601247)
	else
		self.bindData.showPageCtrl = 2

		self.bindData.closeBtn:SetActive(true)
	end

	local showTab = params.showTab or 0
	self.bindData.tabRect.selectedIndex = showTab
	self.selectedIndex = showTab
end

function M:InitTabBtnList()
	self.btnListData = {}
	local tabBtnTexts = LTConfig.GuideConfig.GuideTempTabName

	if table.isNilOrEmpty(tabBtnTexts) or #tabBtnTexts ~= self.tabCount then
		print_error_without_stack("Guide 表 GuideTempTabName 为空，或者长度不匹配 TabRect (" .. self.tabCount .. ")，请检查")
	end

	for i, data in ipairs(tabBtnTexts) do
		self.btnListData[i] = {
			tIndex = 0,
			index = i,
			text = data
		}
	end

	self.bindData.tabBtnList:SetSimpleList(#self.btnListData)
end

function M:ClosePanel()
	if self.bindData.doClose then
		return
	end

	local ani = self.rootWidget:GetComponentInChildren(typeof(UnityEngine.Animation))

	if gClientUtils.NotNil(ani) then
		self.bindData.doClose = true

		Timer.New(function ()
			gPanelManager:Close(self.panelId)

			if self.params.openedByTask then
				local store = gStoreManager:GetStoreGroup("CoreHudSystemControlStore")

				if store.STATE_EnableOnce then
					-- Nothing
				end
			end
		end, 0.3333333333333333):Start()
	else
		gPanelManager:Close(self.panelId)
	end
end

function M:OnRenderTab(csIndex, widget)
	if not string.is_null_or_empty(widget.Store) then
		self.currentTabInst = gStoreManager:GetStoreGroup(widget.Store)
	else
		self.currentTabInst = nil
	end

	if csIndex == self.tabCount - 1 then
		self.bindData.closeBtn:SetActive(true)
	end
end

function M:OnRenderTabButton(btn, csIndex)
	local store = gStoreManager:GetStoreGroup("GuideTempTabButton"):GetStoreByWidget(btn)
	local itemData = self.btnListData[csIndex + 1]
	store.text = itemData.text
	local selected = csIndex == self.selectedIndex
	btn.isSelected = selected

	if selected then
		btn:Navigate(btn)
	end
end

function M:OnTabClick(btn, data)
	local csIndex = data.index - 1
	btn.isSelected = true
	self.bindData.tabRect.selectedIndex = csIndex
	self.selectedIndex = csIndex
end

function M:ClickToNextTab()
	if self.currentTabInst == nil then
		return
	end

	local nextIndex = self.selectedIndex + 1

	if nextIndex < self.tabCount then
		local tabBtnList = self.bindData.tabBtnList

		self:OnTabClick(tabBtnList.items[nextIndex], tabBtnList:GetData(nextIndex))
	end
end

function M:OnDestroy()
	self:ClearMessageEvents()
end
