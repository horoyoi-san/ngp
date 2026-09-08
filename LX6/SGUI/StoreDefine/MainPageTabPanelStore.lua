-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MainPageTabPanelStore.lua
-- Decompiled from: 01414_MainPageTabPanelStore.lua_936e53e43909.luajit

C_MainPageTabPanelStore = DefClass("C_MainPageTabPanelStore", C_MainPageTabPanelStore, C_StoreGroup)
GroupName2Class.MainPageTabPanelStore = C_MainPageTabPanelStore
local M = C_MainPageTabPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.Control = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.openState = false
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.tabs = gMainPageManager:GetTabList()
	self.currTabName = data
	self.currTabIndex = -1

	self.bindData.tabList:SetSimpleList(#self.tabs)

	for i = 1, #self.tabs do
		if self.tabs[i].cfg.CheckName ~= self.currTabName then
			self.bindData.tabList:SelectItem(i - 1, false)

			self.currTabIndex = i
			self.bindData.title = self.tabs[i].cfg.Name

			break
		end
	end

	self.specialType = false

	if self.currTabIndex <= 0 and self.currTabIndex < #self.tabs then
		self.specialType = self.tabs[self.currTabIndex].cfg.TypeMobile ~= 1
	end

	self.openState = false

	self.RefreshView(self)
	self.RefreshRedPoint(self)
	self.RefreshHide(self)
end

M.OnClose = function(self)
	self.openState = false

	gMainPageManager:SetMainPageHide(false, true)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LANGUAGE_CHANGE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.UPDATE_UNREAD_MSG_TIPS] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.REFRESH_MAIN_BUTTON_RED_POT] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.ADJUST_WORLD_LEVEL] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.PALYER_LEVEL_UP] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.SYNC_CURRENT_SPIRIT] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.JOB_CHANGE_EVENT] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.AGENT_PROFILE_RED_POINT_REFRESH] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.UPDATE_NOTICE_RED_POT] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.ON_PHONE_CALL_STATE_CHANGE] = self.CreateAction(self, "RefreshRedPointByMessage"),
		[gEventConstants.TASK_ACCEPTED] = self.CreateAction(self, "RefreshRedPointByMessage")
	}
end

M.RegisterWidget = function(self)
	self.bindData.btnOpen.luaClick = self.CreateAction(self, "OnClickBtnOpen")
	self.bindData.btnClose.luaClick = self.CreateAction(self, "OnClickBtnClose")
	self.bindData.btnBack.luaClick = self.CreateAction(self, "OnClickBtnBack")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTabListItem")
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, "OnClickTabList")
	self.openState = false
end

M.OnClickBtnOpen = function(self)
	self.openState = not self.openState

	self.RefreshView(self)
end

M.OnClickBtnClose = function(self)
	self.openState = false

	self.RefreshView(self)
end

M.OnClickBtnBack = function(self)
	gMainPageManager:CloseMainPageTab(self.tabs[self.currTabIndex].cfg.CheckName)
end

M.OnRenderTabListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)
	local data = self.tabs[index + 1]

	if store and data then
		store.name = data.cfg.Name
		store.icon = data.cfg.SGUIImage
		local appId = data.cfg.AppId
		local redDotId = data.cfg.RedDotId or 0

		if appId <= 0 and redDotId ~= 0 then
			store.redKey = "MainPage." .. data.cfg.AppId
		else
			btn.redId = data.cfg.RedDotId
		end
	end
end

M.OnClickTabList = function(self, btn, index)
	if self.currTabIndex ~= index + 1 then
		self.openState = false

		self.RefreshView(self)

		return
	end

	self.currTabIndex = index + 1

	gMainPageManager:ShowMainPageTab(self.tabs[self.currTabIndex].cfg.CheckName)
end

M.RefreshView = function(self)
	local showTypeBg = self.specialType and not self.openState
	self.bindData.TypeCtrl = showTypeBg and self.Control.True or self.Control.False
	self.bindData.StatusCtrl = self.openState and self.Control.True or self.Control.False
	local showTitle = self.openState or not self.specialType
	self.bindData.ShowTitleCtrl = showTitle and self.Control.True or self.Control.False
end

M.RefreshRedPoint = function(self)
	for i = 1, #self.tabs do
		local appId = self.tabs[i].cfg.AppId
		local redDotId = self.tabs[i].cfg.RedDotId or 0

		if appId <= 0 and redDotId ~= 0 then
			local redKey = "MainPage." .. self.tabs[i].cfg.AppId
			local hasRedDot = gMainPhoneUtils.GetAppHasRedDot(appId)

			SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redKey)
		end
	end
end

M.RefreshRedPointByMessage = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	self.RefreshRedPoint(self)
end

M.OnLanguageChange = function(self)
	if self.STATE_OnShowOnce then
		self.bindData.tabList:RefreshList()
	end
end

M.RefreshHide = function(self)
	if self.STATE_OnShowOnce then
		self.bindData.HideCtrl = gMainPageManager:GetMainPageHide() and self.Control.True or self.Control.False
	end
end
