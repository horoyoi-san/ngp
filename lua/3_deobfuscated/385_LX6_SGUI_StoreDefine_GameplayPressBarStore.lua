C_GameplayPressBarStore = DefClass("C_GameplayPressBarStore", C_GameplayPressBarStore, C_StoreGroup)
GroupName2Class.GameplayPressBarStore = C_GameplayPressBarStore
local M = C_GameplayPressBarStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.minValue = data.minValue
	self.maxValue = data.maxValue
	self.maxTime = data.maxTime
	self.randomShake = data.randomShake
	self.shakeTriggerValue = data.shakeTriggerValue
	self.shakeValue = data.shakeValue
	self.shakeStrength = data.shakeStrength
	self.completeAction = data.completeAction
	self.pressed = false
	self.pressing = false
	self.upSpeed = 1 / data.maxTime
	self.value = 0
	self.randomDir = -1
	self.triggeredShake = false

	self:RefreshBar()
end

function M:OnClose()
	if self.completeAction then
		local action = self.completeAction
		self.completeAction = nil

		action()
	end
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.btn.luaPress = self:CreateAction("OnPressBtn")
	self.bindData.btn.luaRelease = self:CreateAction("OnReleaseBtn")
end

function M:OnPressBtn()
	if not self.pressed then
		self.pressed = true
		self.pressing = true
	end
end

function M:OnReleaseBtn()
	if self.pressed and self.pressing then
		self.pressing = false

		gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	end
end

function M:OnUpdate()
	if self.pressing then
		if self.triggeredShake then
			self.delta = self.upSpeed * Time.deltaTime + self.shakeValue * self.shakeStrength * math.random(0, 100) / 100
			self.value = self.value + self.randomDir * self.delta

			if self.value <= self.shakeTriggerValue - self.shakeValue then
				self.randomDir = 1
				self.value = self.shakeTriggerValue - self.shakeValue
			elseif self.shakeTriggerValue <= self.value then
				self.randomDir = -1
				self.value = self.shakeTriggerValue
			end
		else
			self.value = self.value + self.upSpeed * Time.deltaTime

			if self.value > 1 then
				self.value = 1
			end

			if not self.triggeredShake and self.randomShake then
				self.triggeredShake = self.shakeTriggerValue <= self.value

				if self.triggeredShake then
					self.value = self.shakeTriggerValue
					self.randomDir = -1
				end
			end
		end

		self:RefreshBar()
	end
end

function M:RefreshBar()
	self.bindData.bar.value = self.value

	gGaoQiaoManager:SetCommonPressValue(self.value, self.minValue, self.maxValue)
end
