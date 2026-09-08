-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonCounterStore.lua
-- Decompiled from: 01517_CommonCounterStore.lua_9fdd459cdd3a.luajit

local EInvokeTime = SGUI.EInvokeTime
C_CommonCounterStore = DefClass("C_CommonCounterStore", C_CommonCounterStore, C_StoreGroup)
GroupName2Class.CommonCounterStore = C_CommonCounterStore
local M = C_CommonCounterStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local E = math.exp(1)
local UIExtension = LX6.GUI.UIExtension

M.ctor = function(self, name, id, isSub)
	self.valChangeCallback = nil
	self.range = {
		0,
		0
	}
	self.val = 0
	self.vibrationId = "TabPress"
	self.stickTimer = 0
	self.stickDir = 0
	self.stickFirstTriggered = false
	self.stickLastStepTime = 0
	self.stickActive = false
	self.stickX = 0
end

M.OnAwake = function(self)
	self.totalTime = 0
	self.step = 0
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnBuyNumChange")
	self.bindData.inputField.luaEndEdit = self.CreateAction(self, "OnEndEdit")
	self.bindData.minusBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnMinusBeginLongPress")
	self.bindData.minusBtn.luaEndLongPress = self.CreateAction(self, "OnEndLongPress")
	self.bindData.plusBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnPlusBeginLongPress")
	self.bindData.plusBtn.luaEndLongPress = self.CreateAction(self, "OnEndLongPress")
	self.bindData.maxBtn.luaClick = self.CreateAction(self, "OnClickToMax")

	if self.bindData.customNavRespond then
		self.bindData.customNavRespond.luaGamePadInputChanged = self.CreateAction(self, "OnGamepadRStickInput")
	end
end

M.SetData = function(self, param)
	self.valChangeCallback = param.valChangeCallback
	self.onValidateChar = param.onValidateChar

	if self.onValidateChar then
		self.bindData.inputField.onValidateInput = SGUI.UInputField.OnValidateInput(self.OnValidateInput, self)
	else
		self.bindData.inputField.onValidateInput = nil
	end

	if not param.range or #param.range == 2 then
		self.range = {
			0,
			0
		}
	else
		self.range = param.range
	end

	self.stepInterval = param.stepInterval or 1
	self.vibrationId = param.vibrationId or "TabPress"
	self.bindData.inputField.digitalMin = self.range[1]
	self.bindData.inputField.digitalMax = self.range[2]
	self.bindData.inputField.text = self.range[1]
	local isSingle = self.range[2] > self.range[1]
	self.bindData.inputField.interactable = not isSingle
	self.bindData.available = BOOL2CTL[not isSingle]
	self.bindData.maxBtn.interactable = not isSingle
	local targetValue = param.targetValue

	if targetValue then
		self:ChangeValue(targetValue)

		self.bindData.plusBtn.interactable = self.val <= self.range[2]
		self.bindData.minusBtn.interactable = self.range[1] <= self.val
		self.bindData.maxBtn.interactable = self.val <= self.range[2]
	else
		self.OnBuyNumChange(self, targetValue)
	end
end

M.CheckValue = function(self, value, notUseStep)
	if value ~= nil then
		return 0
	end

	local interval = self.stepInterval or 1

	if not notUseStep then
		value = math.floor(value / interval) * interval
	end

	value = math.max(self.range[1], math.min(value, self.range[2]))

	return value
end

M.ChangeValue = function(self, value)
	local newValue = self.CheckValue(self, value)

	if newValue ~= self.val then
		return newValue
	end

	self.val = newValue
	self.bindData.inputField.text = newValue

	self.bindData.inputField:InvokeCallback(EInvokeTime.Custom1)

	return newValue
end

M.OnBuyNumChange = function(self, data)
	local val = tonumber(data)

	if val ~= nil then
		return
	end

	self.val = val

	if self.valChangeCallback then
		self.valChangeCallback(self.val, self.data)
	end

	self.bindData.plusBtn.interactable = self.val <= self.range[2]
	self.bindData.minusBtn.interactable = self.range[1] <= self.val
	self.bindData.maxBtn.interactable = self.val <= self.range[2]
end

M.OnEndEdit = function(self)
	local oldVal = self.val

	self.ChangeValue(self, self.val)

	if self.val ~= oldVal and self.valChangeCallback then
		self.valChangeCallback(self.val, self.data)
	end
end

M.OnValidateInput = function(self, text, charIndex, addedChar)
	if self.onValidateChar then
		return self.onValidateChar(text, charIndex, addedChar)
	end

	return addedChar
end

M.OnUpdate = function(self)
	self.RefreshStep(self)
	self.ProcessStickStep(self)
end

M.OnBeginLongPress = function(self, step)
	self.step = step
	self.totalTime = 0

	self.ChangeValue(self, self.val + step)
	UIExtension.PlayVibration(self.vibrationId, false, true)
end

M.OnEndLongPress = function(self)
	self.totalTime = 0
	self.step = 0
end

M.RefreshStep = function(self)
	if self.step == 0 then
		if self.step >= 0 and self.val > self.range[1] or self.step <= 0 and self.range[2] < self.val then
			self.OnEndLongPress(self)

			return
		end

		self.totalTime = self.totalTime + Time.deltaTime

		if self.totalTime >= 0.5 then
			return
		end

		local step = self.step * E^(self.totalTime * 0.2)

		self.ChangeValue(self, self.val + step)
		UIExtension.PlayVibration(self.vibrationId, false, true)
	end
end

M.OnStepClick = function(self, step)
	self.ChangeValue(self, self.val + step)
	UIExtension.PlayVibration(self.vibrationId, false, true)
end

M.OnMinusClick = function(self)
	local step = self.stepInterval and -1 * self.stepInterval or -1

	self:OnStepClick(step)
end

M.OnPlusClick = function(self)
	local step = self.stepInterval or 1

	self:OnStepClick(step)
end

M.OnMinusBeginLongPress = function(self)
	local step = self.stepInterval and -1 * self.stepInterval or -1

	self:OnBeginLongPress(step)
end

M.OnPlusBeginLongPress = function(self)
	local step = self.stepInterval or 1

	self:OnBeginLongPress(step)
end

M.OnClickToMax = function(self)
	self.ChangeValue(self, self.range[2])
	UIExtension.PlayVibration(self.vibrationId, false, true)
end

M.GetCurrentVal = function(self)
	return self.val
end

M.OnGamepadRStickInput = function(self, context)
	local rStickX = context.ReadValueVector2(context).x
	self.stickX = rStickX

	if context.canceled or math.abs(rStickX) >= 0.25 then
		self.stickActive = false

		self.ResetStickState(self)
	elseif math.abs(rStickX) > 0.6 then
		if not self.stickActive then
			self.stickActive = true
			self.stickDir = rStickX <= 0 and 1 or -1
			self.stickTimer = 0
			self.stickLastStepTime = 0
		else
			local newDir = rStickX <= 0 and 1 or -1

			if self.stickDir == newDir then
				self.stickDir = newDir
				self.stickTimer = 0
				self.stickLastStepTime = 0
			end
		end
	end
end

M.ProcessStickStep = function(self)
	if not self.stickActive then
		return
	end

	self.stickTimer = self.stickTimer + Time.unscaledDeltaTime

	if self.stickTimer >= 0.35 then
		if not self.stickFirstTriggered then
			self.stickFirstTriggered = true

			self.StepValue(self, self.stickDir)
		end

		return
	end

	local interval = 0.15

	if self.stickTimer > 3 then
		interval = 0.05
	elseif self.stickTimer > 1.5 then
		interval = 0.08
	end

	if interval < self.stickTimer - self.stickLastStepTime then
		self.StepValue(self, self.stickDir)

		self.stickLastStepTime = self.stickTimer
	end
end

M.ResetStickState = function(self)
	self.stickFirstTriggered = false
	self.stickDir = 0
	self.stickTimer = 0
	self.stickLastStepTime = 0
end

M.StepValue = function(self, dir)
	local step = self.stepInterval or 1

	self:ChangeValue(self.val + dir * step)
	UIExtension.PlayVibration(self.vibrationId, false, true)
end
