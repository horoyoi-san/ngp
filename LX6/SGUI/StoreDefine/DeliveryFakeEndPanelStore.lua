-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryFakeEndPanelStore.lua
-- Decompiled from: 01872_DeliveryFakeEndPanelStore.lua_ef42e298eac8.luajit

C_DeliveryFakeEndPanelStore = DefClass("C_DeliveryFakeEndPanelStore", C_DeliveryFakeEndPanelStore, C_StoreGroup)
GroupName2Class.DeliveryFakeEndPanelStore = C_DeliveryFakeEndPanelStore
local M = C_DeliveryFakeEndPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.finishAnimation = "S_Vx_DeliveryEndPanel_open"
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
	self.bindData.duration = self:GetFormatTime(data.duration)
	self.bindData.progress = data.progress
	self.bindData.progressText = data.progress
	local duration = self.bindData.root.anim:GetClip(self.finishAnimation).length or LTConfig.DropConfig.SpecialDropShowTime

	self.bindData.root.anim:Play()
	Timer.New(function ()
		gPanelManager:Close(gPanelId.S_DELIVERY_FAKE_END_PANEL)
	end, duration):Start()
end

M.GetFormatTime = function(self, time)
	local rawMin = time < 0 and 0 or math.floor(time / 60)
	local rawSec = 0
	rawSec = time < 0 and 0 or math.floor((time - rawMin * 60) % 60)

	return gString.Format("%02d:%02d", rawMin, rawSec), rawMin, rawSec
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
