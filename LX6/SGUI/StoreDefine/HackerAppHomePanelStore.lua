-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerAppHomePanelStore.lua
-- Decompiled from: 02101_HackerAppHomePanelStore.lua_b9e6c91817c2.luajit

C_HackerAppHomePanelStore = DefClass("C_HackerAppHomePanelStore", C_HackerAppHomePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.HackerAppHomePanelStore = C_HackerAppHomePanelStore
local M = C_HackerAppHomePanelStore

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnExitClick")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_HACKER_APP_CONTENT_CLOSE] = self.CreateAction(self, "CloseContentPanel")
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

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
