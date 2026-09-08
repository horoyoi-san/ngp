-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CinemaEndPanelStore.lua
-- Decompiled from: 01429_CinemaEndPanelStore.lua_0013427f677e.luajit

C_CinemaEndPanelStore = DefClass("C_CinemaEndPanelStore", C_CinemaEndPanelStore, C_StoreGroup)
GroupName2Class.CinemaEndPanelStore = C_CinemaEndPanelStore
local M = C_CinemaEndPanelStore

M.OnAwake = function(self)
	self.bindData.alpha = 0
end

M.OnShow = function(self, panelId, data)
	self.startTime = Time.unscaledTime
	self.needUpdate = true

	if data then
		self.OnAnimStop = data.OnAnimStopCallback
	end
end

M.OnClose = function(self)
	self.startTime = nil
	self.needUpdate = nil
	self.OnAnimStop = nil
end

M.OnUpdate = function(self)
	if not self.needUpdate then
		return
	end

	if Time.unscaledTime - self.startTime <= 2 then
		self.needUpdate = false
		self.bindData.alpha = 1

		if self.OnAnimStop then
			self.OnAnimStop()

			self.OnAnimStop = nil
		end
	else
		self.bindData.alpha = (Time.unscaledTime - self.startTime) / 2
	end
end
