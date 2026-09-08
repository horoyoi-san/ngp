-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GameplayPressBarHudStore.lua
-- Decompiled from: 01746_GameplayPressBarHudStore.lua_65dc856f7eb0.luajit

C_GameplayPressBarHudStore = DefClass("C_GameplayPressBarHudStore", C_GameplayPressBarHudStore, C_StoreGroup)
GroupName2Class.GameplayPressBarHudStore = C_GameplayPressBarHudStore
local M = C_GameplayPressBarHudStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.minValue = data.minValue
	self.maxValue = data.maxValue
	self.maxTime = data.maxTime
	self.randomShake = data.randomShake
	self.shakeTriggerValue = data.shakeTriggerValue
	self.shakeValue = data.shakeValue
	self.shakeStrength = data.shakeStrength
	self.pressed = false
	self.pressing = false
	self.upSpeed = 1 / data.maxTime
	self.value = 0
	self.randomDir = -1
	self.triggeredShake = false
	self.isReleaseClose = false

	self.RefreshBar(self)
end

M.OnClose = function(self)
	if not self.isReleaseClose then
		gGaoQiaoManager:SetCommonPressValue(0, 0, 0)
	end

	gMessageManager:SendMessage(gEventConstants.ON_COMMON_PROGRESS_BAR_FINISH)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.btn.luaPress = self.CreateAction(self, "OnPressBtn")
	self.bindData.btn.luaRelease = self.CreateAction(self, "OnReleaseBtn")
end

M.OnPressBtn = function(self)
	if not self.pressed then
		self.pressed = true
		self.pressing = true

		gMessageManager:SendMessage(gEventConstants.ON_COMMON_PROGRESS_BAR_PRESS)
	end
end

M.OnReleaseBtn = function(self)
	if self.pressed and self.pressing then
		self.pressing = false
		self.isReleaseClose = true

		gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	end
end

M.OnUpdate = function(self)
	if self.pressing then
		if self.triggeredShake then
			self.delta = self.upSpeed * Time.deltaTime + self.shakeValue * self.shakeStrength * math.random(0, 100) / 100
			self.value = self.value + self.randomDir * self.delta

			if self.value < self.shakeTriggerValue - self.shakeValue then
				self.randomDir = 1
				self.value = self.shakeTriggerValue - self.shakeValue
			elseif self.shakeTriggerValue < self.value then
				self.randomDir = -1
				self.value = self.shakeTriggerValue
			end
		else
			self.value = self.value + self.upSpeed * Time.deltaTime

			if self.value <= 1 then
				self.value = 1
			end

			if not self.triggeredShake and self.randomShake then
				self.triggeredShake = self.shakeTriggerValue > self.value

				if self.triggeredShake then
					self.value = self.shakeTriggerValue
					self.randomDir = -1
				end
			end
		end

		self.RefreshBar(self)
	end
end

M.RefreshBar = function(self)
	self.bindData.bar.value = self.value

	gGaoQiaoManager:SetCommonPressValue(self.value, self.minValue, self.maxValue)
end
