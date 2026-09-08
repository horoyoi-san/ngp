-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartySelectPanelStore.lua
-- Decompiled from: 02084_PartySelectPanelStore.lua_a8c8b3d62f9a.luajit

C_PartySelectPanelStore = DefClass("C_PartySelectPanelStore", C_PartySelectPanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.PartySelectPanelStore = C_PartySelectPanelStore
local M = C_PartySelectPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "CloseContentPanel")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_PARTY_CONTENT_SHOW] = function (_, args)
			self:ShowContentPanel(args)
		end,
		[gEventConstants.ON_PARTY_CONTENT_HIDE] = function (_, args)
			self:CloseContentPanel(args)
		end
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.panelId = args.panelId
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
end

M.OnRenderTab = function(self, index, widget)
	if self.panelArgs then
		gClientUtils.InitNavAreasInChildren(widget, self.panelId)
	end

	M.base.OnRenderTab(self, index, widget)
end

M.OnExitClick = function(self)
	self.OnExit(self)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end
