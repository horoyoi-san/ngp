-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideControllerTipStore.lua
-- Decompiled from: 01756_GuideControllerTipStore.lua_be0934ed86b1.luajit

C_GuideControllerTipStore = DefClass("C_GuideControllerTipStore", C_GuideControllerTipStore, C_StoreGroup)
GroupName2Class.GuideControllerTipStore = C_GuideControllerTipStore
local M = C_GuideControllerTipStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if not data then
		print_error("GuideControllerTipStore OnShow data is nil")

		return
	end

	local isXbox = gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.Xbox
	self.bindData.deviceCtrl = isXbox and 0 or 1

	self:SetControllerTabIndex(data.controllerTabIndex or 0)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	local isXbox = device ~= SGUI.GameDevice.Xbox
	self.bindData.deviceCtrl = isXbox and 0 or 1
end

M.GenMessageEvents = function(self)
end

M.SetControllerTabIndex = function(self, index)
	self.bindData.normalTabIndex = index
	self.bindData.dualSenseTabIndex = index
end

M.RegisterWidget = function(self)
end
