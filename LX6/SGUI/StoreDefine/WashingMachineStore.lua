-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WashingMachineStore.lua
-- Decompiled from: 01164_WashingMachineStore.lua_338f4d80a1ac.luajit

C_WashingMachineStore = DefClass("C_WashingMachineStore", C_WashingMachineStore, C_StoreGroup)
GroupName2Class.WashingMachineStore = C_WashingMachineStore
local M = C_WashingMachineStore
local InputActionBind = SGUI.InputActionBind

M.ctor = function(self)
	self.moveData = {
		["GN~lM\n6"] = 0,
		["F\\x90\\x8c\\x8fD"] = false
	}
	self.hasMoveDir = false
	self.animX = 0
	self.animY = 0
	self.targetX = 0
	self.targetY = 0
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
	self.currentDevice = InputActionBind.activeGameDevice
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	local stopData = {
		["GN~lM\n6"] = 0,
		["F\\x90\\x8c\\x8fD"] = false
	}

	gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_UP_DOWN_SIDE, stopData)
	gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_LEFT_RIGHT_SIDE, stopData)

	self.moveData = {
		["GN~lM\n6"] = 0,
		["F\\x90\\x8c\\x8fD"] = false
	}
	self.hasMoveDir = false
	self.animX = 0
	self.animY = 0
	self.targetX = 0
	self.targetY = 0
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.moveData = {
		["GN~lM\n6"] = 0,
		["F\\x90\\x8c\\x8fD"] = false
	}
	self.hasMoveDir = false
	self.animX = 0
	self.animY = 0
	self.targetX = 0
	self.targetY = 0
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.currentDevice = InputActionBind.activeGameDevice
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.OnUpdate = function(self)
	self.UpdateAnimatorParams(self)
end

M.UpdateAnimatorParams = function(self)
	if self.animX ~= self.targetX and self.animY ~= self.targetY then
		return
	end

	local maxStep = gMiniGameDataManager.curWashingSpeed * Time.deltaTime
	self.animX = self.MoveTowards(self, self.animX, self.targetX, maxStep)
	self.animY = self.MoveTowards(self, self.animY, self.targetY, maxStep)
	self.animX = math.max(-1, math.min(1, self.animX))
	self.animY = math.max(-1, math.min(1, self.animY))

	if gMiniGameDataManager.hasSetWashingLayer then
		gCS.AnimationManager.SetAnimatorParams(gCS.MyPlayerManager.PlayerUnit, self.animX, self.animY, gMiniGameDataManager.curWashingLayer)
	end
end

M.MoveTowards = function(self, current, target, maxDelta)
	local diff = target - current

	if math.abs(diff) < maxDelta then
		return target
	end

	if diff <= 0 then
		return current + maxDelta
	else
		return current - maxDelta
	end
end

M.RegisterWidget = function(self)
	self.bindData.WKey.luaPress = self.CreateAction(self, "OnClickWKey")
	self.bindData.AKey.luaPress = self.CreateAction(self, "OnClickAKey")
	self.bindData.SKey.luaPress = self.CreateAction(self, "OnClickSKey")
	self.bindData.DKey.luaPress = self.CreateAction(self, "OnClickDKey")
	self.bindData.WKey.luaRelease = self.CreateAction(self, "OnReleaseWKey")
	self.bindData.AKey.luaRelease = self.CreateAction(self, "OnReleaseAKey")
	self.bindData.SKey.luaRelease = self.CreateAction(self, "OnReleaseSKey")
	self.bindData.DKey.luaRelease = self.CreateAction(self, "OnReleaseDKey")
	self.bindData.backBtn.luaLongPress = self.CreateAction(self, "OnClickBackBtn")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.joyStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnJoyStickControl")
	end
end

M.OnJoyStickControl = function(self, context)
	if not self.gamepadMode then
		return
	end

	local value = context.ReadValueVector2(context)

	if context.started or context.performed then
		if value.y <= 0 then
			self.moveData.enable = true
			self.moveData.direction = 1

			gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_UP_DOWN_SIDE, self.moveData)

			self.targetY = 1
		elseif value.y >= 0 then
			self.moveData.enable = true
			self.moveData.direction = -1

			gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_UP_DOWN_SIDE, self.moveData)

			self.targetY = -1
		end

		if value.x <= 0 then
			self.moveData.enable = true
			self.moveData.direction = 1

			gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_LEFT_RIGHT_SIDE, self.moveData)

			self.targetX = 1
		elseif value.x >= 0 then
			self.moveData.enable = true
			self.moveData.direction = -1

			gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_LEFT_RIGHT_SIDE, self.moveData)

			self.targetX = -1
		end
	end

	if context.canceled then
		local stopData = {
			["GN~lM\n6"] = 0,
			["F\\x90\\x8c\\x8fD"] = false
		}

		gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_UP_DOWN_SIDE, stopData)
		gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_LEFT_RIGHT_SIDE, stopData)

		self.targetX = self.animX
		self.targetY = self.animY
	end
end

M.OnClickWKey = function(self)
	if self.hasMoveDir then
		return
	end

	self.hasMoveDir = true
	self.moveData.enable = true
	self.moveData.direction = 1

	gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_UP_DOWN_SIDE, self.moveData)

	self.targetY = 1
end

M.OnClickAKey = function(self)
	if self.hasMoveDir then
		return
	end

	self.hasMoveDir = true
	self.moveData.enable = true
	self.moveData.direction = -1

	gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_LEFT_RIGHT_SIDE, self.moveData)

	self.targetX = -1
end

M.OnClickSKey = function(self)
	if self.hasMoveDir then
		return
	end

	self.hasMoveDir = true
	self.moveData.enable = true
	self.moveData.direction = -1

	gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_UP_DOWN_SIDE, self.moveData)

	self.targetY = -1
end

M.OnClickDKey = function(self)
	if self.hasMoveDir then
		return
	end

	self.hasMoveDir = true
	self.moveData.enable = true
	self.moveData.direction = 1

	gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_LEFT_RIGHT_SIDE, self.moveData)

	self.targetX = 1
end

M.OnReleaseWKey = function(self)
	self.hasMoveDir = false
	self.moveData.enable = false
	self.moveData.direction = 0

	gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_UP_DOWN_SIDE, self.moveData)

	self.targetY = 0
end

M.OnReleaseAKey = function(self)
	self.hasMoveDir = false
	self.moveData.enable = false
	self.moveData.direction = 0

	gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_LEFT_RIGHT_SIDE, self.moveData)

	self.targetX = 0
end

M.OnReleaseSKey = function(self)
	self.hasMoveDir = false
	self.moveData.enable = false
	self.moveData.direction = 0

	gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_UP_DOWN_SIDE, self.moveData)

	self.targetY = 0
end

M.OnReleaseDKey = function(self)
	self.hasMoveDir = false
	self.moveData.enable = false
	self.moveData.direction = 0

	gMessageManager:SendMessage(gEventConstants.WASHING_MACHINE_LEFT_RIGHT_SIDE, self.moveData)

	self.targetX = 0
end

M.OnClickBackBtn = function(self)
	gMiniGameDataManager:StopWashingMachine()
end
