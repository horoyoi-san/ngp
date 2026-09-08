-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CleanerMainPanelStore.lua
-- Decompiled from: 01432_CleanerMainPanelStore.lua_5f5bedd8c583.luajit

C_CleanerMainPanelStore = DefClass("C_CleanerMainPanelStore", C_CleanerMainPanelStore, C_StoreGroup)
GroupName2Class.CleanerMainPanelStore = C_CleanerMainPanelStore
local M = C_CleanerMainPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
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
	local rate = math.floor(data.CleaningProcess * 1000) * 0.1

	if rate <= 100 then
		rate = 100
	end

	self.bindData.rate = rate .. "%"
	local dropId = data.DropId
	local time = data.TotalSecond
	local second = time % 60
	local minute = math.floor(time / 60)
	local hour = math.floor(minute / 60)
	local cfg = LTConfig.DropConfig.GetConfig(dropId)
	minute = minute % 60

	if hour ~= 0 then
		self.bindData.time = string.format("%02d:%02d", minute, second)
	else
		self.bindData.time = string.format("%02d:%02d:%02d", hour, minute, second)
	end

	self.bindData.count = cfg.Money
	local itemCfg = LTConfig.ConsumableConfig.GetConfig(LTConfig.ConsumableConfig.RewardMoney)
	self.bindData.icon = itemCfg.SItemIconId

	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.S_CLEAR_MAIN)
	end, LTConfig.WasherConfig.RewardPanelDuration, nil, , true)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
