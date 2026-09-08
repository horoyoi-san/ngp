-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnantarkovHomeTabPanelStore.lua
-- Decompiled from: 01614_AnantarkovHomeTabPanelStore.lua_7f7adcc5512e.luajit

C_AnantarkovHomeTabPanelStore = DefClass("C_AnantarkovHomeTabPanelStore", C_AnantarkovHomeTabPanelStore, C_StoreGroup)
GroupName2Class.AnantarkovHomeTabPanelStore = C_AnantarkovHomeTabPanelStore
local M = C_AnantarkovHomeTabPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	self.m_Id = panelId

	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.homePageId = args.homePageId
	self.viewDataList = self.GetViewDataList(self)
end

M.GetViewDataList = function(self)
	local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(self.homePageId)
	local cardIdList = homePageCfg.IncludeCards
	local viewDataList = {}

	for _, id in ipairs(cardIdList) do
		table.insert(viewDataList, id)
	end

	return viewDataList
end

M.InitView = function(self)
	self.bindData.list:SetSimpleList(#self.viewDataList)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnClickExitButton)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
end

M.OnClickExitButton = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local id = self.viewDataList[index + 1]
	local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(id)
	store.title = homePageCfg.Name
	store.iconId = homePageCfg.Icon
	store.desc = homePageCfg.Desc
	store.unlockedTips = homePageCfg.UnlockedTips
	btn.interactable = self:CheckHasUnlocked()
end

M.CheckHasUnlocked = function(self)
	local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(self.homePageId)

	if homePageCfg.SystemUnlockId <= 0 then
		return gSystemUnlockMgr:IsUnlock(homePageCfg.SystemUnlockId)
	end

	return true
end

M.OnSimpleClickList = function(self, btn, index)
	local id = self.viewDataList[index + 1]
	local homePageCfg = LTConfig.ExtractionShooterHomePageConfig.GetConfig(id)

	gClientUtils.RunCode(homePageCfg.InteractionActions, gDialogScriptFunc)
end
