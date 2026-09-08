-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Instruments\GuitarGamepadControllerUI.lua
-- Decompiled from: 01822_GuitarGamepadControllerUI.lua_6b69f32be913.luajit

C_GuitarGamepadControllerUI = DefClass("C_GuitarGamepadControllerUI", C_GuitarGamepadControllerUI)
local M = C_GuitarGamepadControllerUI
local InstrumentConfig = LTConfig.InstrumentConfig

M.ctor = function(self, controllerWidget, config)
	self.controllerWidget = controllerWidget
	self.config = config or {}
	self.store = gStoreManager:GetStoreGroup(controllerWidget.Store):GetStoreByWidget(controllerWidget)
	self.currentPressId = 0

	self:RegisterWidget()
end

M.RegisterWidget = function(self)
	local bindData = self.store
	self.btnList = {}
	self.btnStoreList = {}

	for i = 1, self.config.buttonCount do
		local btnName = "btn" .. i
		local btn = self.store[btnName]
		self.btnList[i] = btn
		self.btnStoreList[i] = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		self:SetButtonHighlight(i, false)

		btn.luaPress = self:CreateActionWithArgs(self.OnButtonPress, i)
		btn.luaRelease = self:CreateActionWithArgs(self.OnButtonRelease, i)

		if self.config.buttonLabels and self.config.buttonLabels[i] then
			self.SetButtonLabel(self, i, self.config.buttonLabels[i])
		end
	end

	bindData.customNavRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnJoystickInput)
	self.controllerAngleTrans = bindData.controllerAngle.rectTransform

	if self.config.hasPageSwitch then
		bindData.btnL.luaClick = self.CreateAction(self, self.OnPageChangeLeft)
		bindData.btnR.luaClick = self.CreateAction(self, self.OnPageChangeRight)
	end
end

M.SetButtonLabel = function(self, index, label)
	local store = self.btnStoreList[index]

	if store then
		store.titleText = label
	end
end

M.SetButtonHighlight = function(self, index, on)
	local store = self.btnStoreList[index]

	if store then
		store.selectingActiveCtrl = on and 1 or 0
	end
end

M.RefreshButtonLabels = function(self, labels)
	self.config.buttonLabels = labels

	for i = 1, self.config.buttonCount do
		if labels and labels[i] then
			self.SetButtonLabel(self, i, labels[i])
		end
	end
end

M.SetSelectedIndex = function(self, index)
	if not self.config.keepSelected then
		return
	end

	if not self.btnList[index] then
		return
	end

	if self.selectedIndex and self.selectedIndex == index then
		self.SetButtonHighlight(self, self.selectedIndex, false)
	end

	self.selectedIndex = index

	self.SetButtonHighlight(self, index, true)
end

M.OnButtonPress = function(self, index)
	if self.config.keepSelected then
		if self.selectedIndex and self.selectedIndex == index then
			self.SetButtonHighlight(self, self.selectedIndex, false)
		end

		self.selectedIndex = index
	end

	self.SetButtonHighlight(self, index, true)

	if self.config.onButtonPress then
		self.config.onButtonPress(index)
	end
end

M.OnButtonRelease = function(self, index)
	if not self.config.keepSelected then
		self.SetButtonHighlight(self, index, false)
	end

	if self.config.onButtonRelease then
		self.config.onButtonRelease(index)
	end
end

M.OnJoystickInput = function(self, context)
	local input = context.ReadValueVector2(context)

	if not self.joystickTriggered then
		local threshold = InstrumentConfig.PianoJoystickTriggerThreshold

		if threshold >= input.x * input.x + input.y * input.y then
			self.joystickTriggered = true
			self.currentPressId = 0

			self.store.controllerAngle:SetActive(true)
		else
			return
		end
	end

	if context.performed then
		local threshold = InstrumentConfig.PianoJoystickMoveThreshold

		if threshold <= input.x * input.x + input.y * input.y then
			return
		end

		local inputVal = input * 20
		self.rotateParam = inputVal
		local rot = self.CalcRotAngle(self, self.rotateParam)
		self.controllerAngleTrans.localRotation = Quaternion.Euler(0, 0, 360 - rot)
		local pressId = self.CalcPressButtonIndex(self, rot)

		if pressId == self.currentPressId then
			if self.currentPressId and self.currentPressId <= 0 then
				self.OnButtonRelease(self, self.currentPressId)
			end

			self.currentPressId = pressId

			if self.currentPressId <= 0 then
				self.OnButtonPress(self, self.currentPressId)
			end
		end
	end

	if context.canceled then
		self.joystickTriggered = false

		self.store.controllerAngle:SetActive(false)

		self.rotateParam = nil

		if self.currentPressId and self.currentPressId <= 0 then
			self.OnButtonRelease(self, self.currentPressId)

			self.currentPressId = nil
		end
	end
end

M.CalcRotAngle = function(self, rotateParam)
	local x = rotateParam.x
	local y = rotateParam.y
	local rot = math.deg(math.atan2(x, y))

	if rot >= 0 then
		rot = rot + 360
	end

	return rot
end

M.CalcPressButtonIndex = function(self, rot)
	return math.floor((rot + 22.5) / 45) % 8 + 1
end

M.OnPageChangeLeft = function(self)
	if self.config.onPageChange then
		self.config.onPageChange(-1)
	end
end

M.OnPageChangeRight = function(self)
	if self.config.onPageChange then
		self.config.onPageChange(1)
	end
end
