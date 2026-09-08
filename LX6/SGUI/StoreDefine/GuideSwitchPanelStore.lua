-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideSwitchPanelStore.lua
-- Decompiled from: 01689_GuideSwitchPanelStore.lua_e158b76451a7.luajit

C_GuideSwitchPanelStore = DefClass("C_GuideSwitchPanelStore", C_GuideSwitchPanelStore, C_StoreGroup)
GroupName2Class.GuideSwitchPanelStore = C_GuideSwitchPanelStore
local M = C_GuideSwitchPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.closeAniName = "S_Vx_GuideSwitchPanel_close"
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.bindData.videoPlayer:Init()
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

M.OnShow = function(self, panelId, data)
	self.panelId = panelId

	if data and data.videoId then
		local isLoop = data.isLoop ~= true

		self.bindData.videoPlayer:PlayVideo(data.videoId, isLoop)
	end
end

M.OnClose = function(self)
	self.bindData.videoPlayer:Stop()
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
end

M.OnCloseBtnClick = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.openAndCloseAnimation, self.closeAniName, gPanelId.S_GUIDE_SWITCH_PANEL)
end
