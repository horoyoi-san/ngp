-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RobotLoadingScreenPanelStore.lua
-- Decompiled from: 00891_RobotLoadingScreenPanelStore.lua_b8767b2d8872.luajit

C_RobotLoadingScreenPanelStore = DefClass("C_RobotLoadingScreenPanelStore", C_RobotLoadingScreenPanelStore, C_StoreGroup)
GroupName2Class.RobotLoadingScreenPanelStore = C_RobotLoadingScreenPanelStore
local M = C_RobotLoadingScreenPanelStore

M.ctor = function(self)
	self.loadFinish = false
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
end

M.OnGroupEnable = function(self)
	self.startTime = Time.time

	self.SetFillAmount(self, 0)
end

M.OnShow = function(self, panelId, data)
	self.needUpdate = true
end

M.OnClose = function(self)
	self.loadFinish = false
	self.needUpdate = false
	self.needClose = false
	self.lastFill = 0
end

M.SetFillAmount = function(self, fill)
	self.bindData.fillAmount = fill
	self.lastFill = fill
end

M.OnUpdate = function(self)
	if self.needClose then
		self.needClose = false

		gPanelManager:Close(gPanelId.S_ROBOT_LOADING_SCREEN_PANEL)
	end

	if self.needUpdate then
		local passTime = Time.time - self.startTime

		if passTime >= 0.8 then
			self.SetFillAmount(self, passTime)
		elseif self.loadFinish then
			if passTime <= 1 then
				self.SetFillAmount(self, 1)

				self.needClose = true
				self.needUpdate = false
			else
				self.SetFillAmount(self, passTime)
			end
		elseif passTime >= 0.9 then
			self.SetFillAmount(self, passTime)
		elseif passTime < 1 then
			self.SetFillAmount(self, 0.9 + (passTime - 0.9) / 2)
		else
			self.SetLoadFinish(self)
		end
	end
end

M.GenMessageEvents = function(self)
end

M.SetLoadFinish = function(self)
	self.loadFinish = true
end
