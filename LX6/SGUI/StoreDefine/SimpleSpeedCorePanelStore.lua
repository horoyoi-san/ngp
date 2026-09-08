-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SimpleSpeedCorePanelStore.lua
-- Decompiled from: 01339_SimpleSpeedCorePanelStore.lua_e03f04da323a.luajit

C_SimpleSpeedCorePanelStore = DefClass("C_SimpleSpeedCorePanelStore", C_SimpleSpeedCorePanelStore, C_StoreGroup)
GroupName2Class.SimpleSpeedCorePanelStore = C_SimpleSpeedCorePanelStore
local M = C_SimpleSpeedCorePanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.OnUpdate = function(self)
	local speed = math.abs(gCS.MyPlayerManager.PlayerUnit.InputSpeed) * 3.6
	local maxSpeed = 360
	speed = math.min(math.floor(speed + 0.5), maxSpeed)
	speed = math.floor(speed + 0.5)

	if speed >= 10 then
		speed = "0" .. speed
	end

	self.bindData.speed = speed
	local percent = speed / maxSpeed
	local angle = (1 - percent) * 240
	self.bindData.keduFill = percent * 0.667 + 0.083

	self.bindData.needleTrans:SetLocalEulerAnglesZ(angle)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end
