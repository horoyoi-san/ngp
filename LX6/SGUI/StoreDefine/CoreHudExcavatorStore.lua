-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudExcavatorStore.lua
-- Decompiled from: 01495_CoreHudExcavatorStore.lua_7d49af12c54b.luajit

C_CoreHudExcavatorStore = DefClass("C_CoreHudExcavatorStore", C_CoreHudExcavatorStore, C_StoreGroup)
GroupName2Class.CoreHudExcavatorStore = C_CoreHudExcavatorStore
local M = C_CoreHudExcavatorStore
M.MOUSE_DEADZONE = 0.0001
M.STICK_DEADZONE = 0.01

M.OnAwake = function(self)
	self.bindData.upBtn.luaPress = self.CreateAction(self, "OnUpBtnPress")
	self.bindData.upBtn.luaRelease = self.CreateAction(self, "OnUpBtnRelease")
	self.bindData.downBtn.luaPress = self.CreateAction(self, "OnDownBtnPress")
	self.bindData.downBtn.luaRelease = self.CreateAction(self, "OnDownBtnRelease")
	self.bindData.catchBtn.luaPress = self.CreateAction(self, "OnReleaseBtnPress")
	self.bindData.catchBtn.luaRelease = self.CreateAction(self, "OnReleaseBtnRelease")
	self.bindData.releaseBtn.luaPress = self.CreateAction(self, "OnCatchBtnPress")
	self.bindData.releaseBtn.luaRelease = self.CreateAction(self, "OnCatchBtnRelease")
	self.bindData.mouseMove.luaGamePadInputChanged = self.CreateAction(self, "OnMouseMoveInput")
	self.bindData.joyStick.luaValueChanged = self.CreateAction(self, "OnJoyStickValueChanged")
	self.upPress = false
	self.downPress = false
	self.catchPress = false
	self.releasePress = false
	self.joyStickInput = {
		["K\\x85\\x87\\x95D"] = false,
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.msgEvents = {
		[gEventConstants.EXCAVATOR_BUCKET_LOAD_RATIO] = self.CreateAction(self, "OnBucketLoadRatioChanged")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.msgEvents = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.currVehicleData = data
	self.IsPhoneMode = IsPhoneMode
	self.IsMainDrive = IsMainDrive
	self.bindData.progress.value = 0

	self.ResetSelectedCtrl(self)
end

M.OnClose = function(self)
	self.currVehicleData = nil
	self.upPress = false
	self.downPress = false
	self.catchPress = false
	self.releasePress = false

	if self.joyStickInput then
		self.joyStickInput.active = false
	end

	self.ResetSelectedCtrl(self)
end

M.OnUpBtnPress = function(self)
	self.upPress = true

	gMessageManager:SendMessage(gEventConstants.EXCAVATOR_ARM_RAISE, true)
end

M.OnUpBtnRelease = function(self)
	self.upPress = false

	gMessageManager:SendMessage(gEventConstants.EXCAVATOR_ARM_RAISE, false)
end

M.OnDownBtnPress = function(self)
	self.downPress = true

	gMessageManager:SendMessage(gEventConstants.EXCAVATOR_ARM_LOWER, true)
end

M.OnDownBtnRelease = function(self)
	self.downPress = false

	gMessageManager:SendMessage(gEventConstants.EXCAVATOR_ARM_LOWER, false)
end

M.OnCatchBtnPress = function(self)
	self.catchPress = true

	gMessageManager:SendMessage(gEventConstants.EXCAVATOR_BUCKET_DIG, true)
end

M.OnCatchBtnRelease = function(self)
	self.catchPress = false

	gMessageManager:SendMessage(gEventConstants.EXCAVATOR_BUCKET_DIG, false)
end

M.OnReleaseBtnPress = function(self)
	self.releasePress = true

	gMessageManager:SendMessage(gEventConstants.EXCAVATOR_BUCKET_DUMP, true)
end

M.OnReleaseBtnRelease = function(self)
	self.releasePress = false

	gMessageManager:SendMessage(gEventConstants.EXCAVATOR_BUCKET_DUMP, false)
end

M.OnMouseMoveInput = function(self, context)
	if context.canceled then
		self.StopDirInput(self)

		return
	end

	if not context.started and not context.performed then
		return
	end

	local value = context.ReadValueVector2(context)

	self.ApplyDirInput(self, value.x, value.y, self.MOUSE_DEADZONE)
end

M.OnJoyStickValueChanged = function(self, dx, dy, size)
	if size and self.STICK_DEADZONE >= size then
		self.joyStickInput.x = dx
		self.joyStickInput.y = dy
		self.joyStickInput.active = true
	else
		self.joyStickInput.active = false

		self.StopDirInput(self)
	end
end

M.ApplyDirInput = function(self, x, y, deadzone)
	if math.abs(x) >= deadzone and math.abs(y) >= deadzone then
		self.StopDirInput(self)

		return
	end

	if math.abs(y) < math.abs(x) then
		gMessageManager:SendMessage(gEventConstants.EXCAVATOR_CABIN_ROTATE, x)
		self:SetSelectedCtrl(x <= 0 and "Right" or "Left")
	else
		gMessageManager:SendMessage(gEventConstants.EXCAVATOR_ARM_REACH, y)
		self:SetSelectedCtrl(y <= 0 and "Up" or "Down")
	end
end

M.StopDirInput = function(self)
	self.ResetSelectedCtrl(self)
end

M.OnUpdate = function(self)
	if self.joyStickInput and self.joyStickInput.active then
		self.ApplyDirInput(self, self.joyStickInput.x, self.joyStickInput.y, self.STICK_DEADZONE)
	end
end

M.SetSelectedCtrl = function(self, dir)
	self.bindData.selectedCtrlUp = dir ~= "Up" and 1 or 0
	self.bindData.selectedCtrlDown = dir ~= "Down" and 1 or 0
	self.bindData.selectedCtrlRight = dir ~= "Right" and 1 or 0
	self.bindData.selectedCtrlLeft = dir ~= "Left" and 1 or 0
end

M.ResetSelectedCtrl = function(self)
	self.bindData.selectedCtrlUp = 0
	self.bindData.selectedCtrlDown = 0
	self.bindData.selectedCtrlRight = 0
	self.bindData.selectedCtrlLeft = 0
end

M.OnBucketLoadRatioChanged = function(self, eventId, ratio)
	if ratio and self.bindData and self.bindData.progress then
		self.bindData.progress.value = ratio
	end
end
