C_InspireHubPanelStore = DefClass("C_InspireHubPanelStore", C_InspireHubPanelStore, C_StoreGroup)
GroupName2Class.InspireHubPanelStore = C_InspireHubPanelStore
local M = C_InspireHubPanelStore

function M:OnAwake()
	self.instance = {
		panelId = 0,
		data = false
	}
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.exitBtn.luaClick = self:CreateAction(self.OnExitBtnClick)
end

function M:OnShow(panelId, data)
	self.instance.panelId = panelId
	self.instance.data = data
	local itemList = {
		{
			title = LTConfig.InspireHubConfig.UITabNames[1]
		}
	}

	if gGameSwitch.EnableCompetitionSeason then
		table.insert(itemList, {
			title = LTConfig.InspireHubConfig.UITabNames[1]
		})
	end

	local selectCallback = self:CreateAction(self.OnTabSelectedChange)
	local renderCallback = nil
	local commonTabSingleStore = self.SubGroup.CommonTabSingleStore

	commonTabSingleStore:SetData(itemList, nil, 0, nil, selectCallback, renderCallback)

	self.bindData.userName = LTConfig.TuiteConfig.PlayerAccountName
	self.bindData.userIdName = LTConfig.TuiteConfig.PlayerAccountID
	self.bindData.userAvatar = gSocialNetworkUtils.GetPlayerSGuiAvatarId()
end

function M:OnTabSelectedChange()
	local selectedIndex = self.SubGroup.CommonTabSingleStore:GetSelectedIndex()

	self.bindData.tabRect:SelectIndexWithClose(selectedIndex)
end

function M:OnRenderTab(_, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.instance.tabStore = store

	store:OnTabShow(self)
end

function M:OnDestroy()
	self.instance = nil
end

function M:OnExitBtnClick()
	self:ClosePanel()
end

function M:ClosePanel()
	gPanelManager:Close(self.instance.panelId)
end
