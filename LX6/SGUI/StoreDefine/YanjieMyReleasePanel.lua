-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieMyReleasePanel.lua
-- Decompiled from: 02066_YanjieMyReleasePanel.lua_1071f6e15be7.luajit

C_YanjieMyReleasePanel = DefClass("C_YanjieMyReleasePanel", C_YanjieMyReleasePanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieMyReleasePanel = C_YanjieMyReleasePanel
local M = C_YanjieMyReleasePanel

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.InitView = function(self, _)
	self.momentList = self.SubGroup.CommonNewYanjieListTemplateStore
	self.momentList.GetList = gSocialNetworkUtils.GetMyReleaseMomentList

	self.momentList:StartRequest()
end
