-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InspireFanInfoPanelStore.lua
-- Decompiled from: 01832_InspireFanInfoPanelStore.lua_786f8cffd192.luajit

C_InspireFanInfoPanelStore = DefClass("C_InspireFanInfoPanelStore", C_InspireFanInfoPanelStore, C_StoreGroup)
GroupName2Class.InspireFanInfoPanelStore = C_InspireFanInfoPanelStore
local M = C_InspireFanInfoPanelStore

M.OnAwake = function(self)
	local ClosePanel = function()
		gPanelManager:Close(gPanelId.INSPIRE_FAN_INFO_PANEL)
	end

	self.RegisterSingleEvent(self, gEventConstants.ON_YANJIE_CONTENT_CLOSE, ClosePanel)

	self.bindData.fullscreenBtn.luaClick = ClosePanel
end

M.OnShow = function(self, panelId, data)
	self.SubGroup.YanjieNewMemberCenterPanel:InitModel()
	self.SubGroup.YanjieNewMemberCenterPanel:InitView()
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end
