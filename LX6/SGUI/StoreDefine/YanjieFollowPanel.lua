-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieFollowPanel.lua
-- Decompiled from: 02059_YanjieFollowPanel.lua_b02f9fd70a17.luajit

C_YanjieFollowPanel = DefClass("C_YanjieFollowPanel", C_YanjieFollowPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieFollowPanel = C_YanjieFollowPanel
local M = C_YanjieFollowPanel

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.InitView = function(self, _)
	self.momentList = self.SubGroup.CommonNewYanjieListTemplateStore
	self.momentList.GetList = gSocialNetworkUtils.GetFollowList

	self.momentList:StartRequest()
end
