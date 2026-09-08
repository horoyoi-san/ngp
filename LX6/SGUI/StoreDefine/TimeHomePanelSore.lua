-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimeHomePanelSore.lua
-- Decompiled from: 02094_TimeHomePanelSore.lua_7327b24b71a8.luajit

C_TimeHomePanelSore = DefClass("C_TimeHomePanelSore", C_TimeHomePanelSore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.TimeHomePanelSore = C_TimeHomePanelSore
local M = C_TimeHomePanelSore

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnExitClick")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_TIME_APP_CONTENT_SHOW] = self.CreateAction(self, "ShowContentPanel"),
		[gEventConstants.ON_TIME_APP_CONTENT_CLOSE] = self.CreateAction(self, "CloseContentPanel")
	}
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.OnRenderTab = function(self, index, widget)
	if self.panelArgs then
		gClientUtils.InitNavAreasInChildren(widget, self.panelArgs.panelId)
	end

	M.base.OnRenderTab(self, index, widget)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
