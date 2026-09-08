-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineArcadeCenterMainPnelStore.lua
-- Decompiled from: 01099_OnlineArcadeCenterMainPnelStore.lua_c180fe8f0677.luajit

C_OnlineArcadeCenterMainPnelStore = DefClass("C_OnlineArcadeCenterMainPnelStore", C_OnlineArcadeCenterMainPnelStore, C_StoreGroup)
GroupName2Class.OnlineArcadeCenterMainPnelStore = C_OnlineArcadeCenterMainPnelStore
local M = C_OnlineArcadeCenterMainPnelStore

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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.curSelectIndex = gClientConst.ArcadeCenterShowType.Main

	self.bindData.tabRect:SelectIndexWithClose(self.curSelectIndex)

	self.subTabArgs = nil
end

M.OnClose = function(self)
	self.currentRenderStore = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_ARCADE_CENTER_SHOW_PANEL] = self.CreateAction(self, self.OnRequestNewTabOpen),
		[gEventConstants.ON_ARCADE_CENTER_CLOSE_PANEL] = self.CreateAction(self, self.OnRequestTabClose)
	}
end

M.RegisterWidget = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
end

M.OnTabRectRender = function(self, index, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.currentRenderStore = store

	store:ShowPanel(self.subTabArgs)
end

M.OnRequestNewTabOpen = function(self, eventId, args)
	if gClientUtils.IsNil(self.rootWidget) then
		return
	end

	self.subTabArgs = args

	if args.showType then
		self.bindData.tabRect.selectedIndex = args.showType
	end
end

M.OnRequestTabClose = function(self, eventId, args)
	if gClientUtils.IsNil(self.rootWidget) then
		return
	end

	self.subTabArgs = args

	if self.bindData.tabRect.selectedIndex ~= gClientConst.ArcadeCenterShowType.Main then
		gPanelManager:Close(self.m_Id)
	elseif self.bindData.tabRect.selectedIndex ~= gClientConst.ArcadeCenterShowType.Info then
		self.bindData.tabRect.selectedIndex = gClientConst.ArcadeCenterShowType.Main
	end
end
