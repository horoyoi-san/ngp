-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InspireHubPanelStore.lua
-- Decompiled from: 01831_InspireHubPanelStore.lua_4b73141843f2.luajit

C_InspireHubPanelStore = DefClass("C_InspireHubPanelStore", C_InspireHubPanelStore, C_StoreGroup)
GroupName2Class.InspireHubPanelStore = C_InspireHubPanelStore
local M = C_InspireHubPanelStore

M.OnAwake = function(self)
	self.instance = {
		["\\xc9\\xda\r\\xf5"] = 0,
		["~#iZ"] = false
	}
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnExitBtnClick)
end

M.OnShow = function(self, panelId, data)
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

	local selectCallback = self.CreateAction(self, self.OnTabSelectedChange)
	local renderCallback = nil
	local commonTabSingleStore = self.SubGroup.CommonTabSingleStore

	commonTabSingleStore.SetData(commonTabSingleStore, itemList, nil, 0, nil, selectCallback, renderCallback)

	self.bindData.userName = LTConfig.TuiteConfig.PlayerAccountName
	self.bindData.userIdName = LTConfig.TuiteConfig.PlayerAccountID
	self.bindData.userAvatar = gSocialNetworkUtils.GetPlayerSGuiAvatarId()
end

M.OnTabSelectedChange = function(self)
	local selectedIndex = self.SubGroup.CommonTabSingleStore:GetSelectedIndex()

	self.bindData.tabRect:SelectIndexWithClose(selectedIndex)
end

M.OnRenderTab = function(self, _, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.instance.tabStore = store

	store:OnTabShow(self)
end

M.OnDestroy = function(self)
	self.instance = nil
end

M.OnExitBtnClick = function(self)
	self.ClosePanel(self)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.instance.panelId)
end
