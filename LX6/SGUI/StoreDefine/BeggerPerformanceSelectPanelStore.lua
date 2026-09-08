-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BeggerPerformanceSelectPanelStore.lua
-- Decompiled from: 02095_BeggerPerformanceSelectPanelStore.lua_bb25a18891e8.luajit

C_BeggerPerformanceSelectPanelStore = DefClass("C_BeggerPerformanceSelectPanelStore", C_BeggerPerformanceSelectPanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.BeggerPerformanceSelectPanelStore = C_BeggerPerformanceSelectPanelStore
local M = C_BeggerPerformanceSelectPanelStore

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_BEGGAR_APP_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_BEGGAR_APP_CONTENT_CLOSE] = function (_, args)
			self:CloseContentPanel(args)
		end
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
end

M.OnExitClick = function(self)
	self.OnExit(self)
end

M.OnRenderTab = function(self, index, widget)
	if self.panelArgs.panelId then
		gClientUtils.InitNavAreasInChildren(widget, self.panelArgs.panelId)
	end

	M.base.OnRenderTab(self, index, widget)
end

M.OnExecuteExitAction = function(self)
	gMainPhoneUtils.CloseFrontContent()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

M.RegisterWidget = function(self)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
end
