-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GuideInfo\GuideTemp04Store.lua
-- Decompiled from: 01997_GuideTemp04Store.lua_b3b35e9fdb98.luajit

C_GuideTemp04Store = DefClass("C_GuideTemp04Store", C_GuideTemp04Store, C_GuideTempTabBaseStore)
GroupName2Class.GuideTemp04Store = C_GuideTemp04Store
local M = C_GuideTemp04Store

M.OnAwake = function(self)
	self.RegisterSingleEvent(self, gEventConstants.ON_ACTIVE_DEVICE_CHANGED, self.CreateAction(self, self.OnActiveDeviceChanged))
	self.OnActiveDeviceChanged(self, nil, gCS.LuaUtils.GetActiveDevice())
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnActiveDeviceChanged = function(self, _, device)
	local DeviceType = SGUI.GameDevice

	if device ~= DeviceType.PlayStation then
		self.bindData.typeCtrl = 1
	elseif device ~= DeviceType.Xbox then
		self.bindData.typeCtrl = 2
	else
		self.bindData.typeCtrl = 0
	end
end
