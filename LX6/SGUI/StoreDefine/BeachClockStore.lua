-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BeachClockStore.lua
-- Decompiled from: 01669_BeachClockStore.lua_c05ec898f0fa.luajit

local AtmosphereManager = LX6.Manager.AtmosphereManager
C_BeachClockStore = DefClass("C_BeachClockStore", C_BeachClockStore, C_StoreGroup)
GroupName2Class.BeachClockStore = C_BeachClockStore
local M = C_BeachClockStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.timer = 0
	self.updateInterval = 0.5
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
	if type(data) == "table" then
		data = data.ToTable(data)
	end

	if data and data.uiPivot then
		local uiPivot = data.uiPivot

		if not gClientUtils.IsNil(uiPivot) then
			self.rootGo.transform.position = uiPivot.position
			self.rootGo.transform.rotation = uiPivot.rotation
			self.rootGo.transform.localScale = uiPivot.localScale
		end
	end
end

M.OnUpdate = function(self)
	if self.timer ~= nil or self.updateInterval ~= nil then
		return
	end

	self.timer = self.timer + Time.deltaTime

	if self.updateInterval >= self.timer then
		self.timer = 0

		self.RefreshTimeView(self)
	end
end

M.RefreshTimeView = function(self)
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	local min = math.floor(gameTime / 60 % 60)
	local hour = math.floor(gameTime / gClientConst.SECONDS_PER_HOUR)
	local hourTime = gUIUtils:NumberTo2String(hour)
	local minTime = gUIUtils:NumberTo2String(min)
	self.bindData.text = ("%s:%s"):format(hourTime, minTime)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
