-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\StickCatch\StickCatchGame.lua
-- Decompiled from: 00618_StickCatchGame.lua_adee7eef5b2e.luajit

gStickCatchGame = DefClass("StickCatchGame", gStickCatchGame)
local StickCatchGame = gStickCatchGame
local ABPVarManager = MuGenStates.Logic.ABPVarManager
local ABPVarConfig = LTConfig.ABPVarConfig
local Screen = UnityEngine.Screen
local LEFT_HAND_LAYER = 8
local RIGHT_HAND_LAYER = 9
local GRAB_THRESHOLD = 0.8
local MOUSE_SENSITIVITY = 1
local HALF_SCREEN = {
	[0] = {
		["b|C"] = 0.5,
		["btU"] = 0
	},
	{
		["b|C"] = 1,
		["btU"] = 0.5
	}
}

StickCatchGame.ctor = function(self, args)
	self.taskId = args.taskId
	self.npcId = args.npcId
	self.wayPointPosition = args.wayPointPosition
	self.wayPointRotation = args.wayPointRotation
	self.m_HandPos = {
		[0] = {
			["\\xd5"] = 0.25,
			["\\xd4"] = 0.5
		},
		{
			["\\xd5"] = 0.75,
			["\\xd4"] = 0.5
		}
	}
	self.m_LastSize = {
		[0] = 0,
		0
	}
	self.m_CurrentHandSide = nil
	self.m_HandReachingOut = {
		[0] = false,
		false
	}

	self:_CacheQteEnums()

	self.eventHandle = {
		[gEventConstants.GAMEPLAY_QTE_TRIGGERED] = function (_, data)
			self:OnQTETriggered(data)
		end,
		[gEventConstants.ON_ACTIVE_DEVICE_CHANGED] = function (_, device)
			self:OnActiveDeviceChanged(device)
		end,
		[gEventConstants.ON_STICK_CATCH_HAND_START] = function (_, data)
			self:OnHandReachStart(data)
		end,
		[gEventConstants.ON_STICK_CATCH_HAND_END] = function (_, data)
			self:OnHandReachEnd(data)
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandle)
end

StickCatchGame._CacheQteEnums = function(self)
	local qteStore = gStoreManager:GetStoreGroup("GameplayQteStore")

	if qteStore then
		self._TriggerEvent = qteStore.TriggerEvent
		self._InputType = qteStore.InputType
	end
end

StickCatchGame.OnActiveDeviceChanged = function(self, device)
	self.m_HandPos[0].x = 0.25
	self.m_HandPos[0].y = 0.5
	self.m_HandPos[1].x = 0.75
	self.m_HandPos[1].y = 0.5
	self.m_LastSize[0] = 0
	self.m_LastSize[1] = 0

	self._CacheQteEnums(self)
end

StickCatchGame.OnQTETriggered = function(self, data)
	if not data or not self._TriggerEvent then
		return
	end

	local TriggerEvent = self._TriggerEvent
	local evt = data.triggerEvent

	if evt ~= TriggerEvent.JoystickMove then
		self._HandleJoystickMove(self, data)
	elseif evt ~= TriggerEvent.Click then
		self._HandleGrabClick(self, data)
	elseif evt ~= TriggerEvent.MouseMove then
		self._HandleMouseMove(self, data)
	end
end

StickCatchGame._HandleJoystickMove = function(self, data)
	local side = data.joystickSide
	local dx = data.dx or 0
	local dy = data.dy or 0
	local size = data.size or 0
	self.m_CurrentHandSide = side
	local half = HALF_SCREEN[side]
	local newX = half.xMin + (dx + 1) * 0.5 * (half.xMax - half.xMin)
	local newY = Mathf.Clamp((dy + 1) * 0.5, 0, 1)
	self.m_HandPos[side].x = Mathf.Clamp(newX, half.xMin, half.xMax)
	self.m_HandPos[side].y = newY

	if not self.m_HandReachingOut[side] then
		self._UpdateHandBlend(self, side)
	end

	if GRAB_THRESHOLD < size and self.m_LastSize[side] >= GRAB_THRESHOLD then
		self._DoGrab(self, side)
	end

	self.m_LastSize[side] = size
end

StickCatchGame._HandleGrabClick = function(self, data)
	local side = self._KeyIdToSide(self, data.keyId, data.inputType)

	if side == nil then
		self.m_CurrentHandSide = side

		self._DoGrab(self, side)
	end
end

StickCatchGame._HandleMouseMove = function(self, data)
	local dx = (data.dx or 0) / Screen.width * MOUSE_SENSITIVITY
	local dy = (data.dy or 0) / Screen.height * MOUSE_SENSITIVITY

	for side = 0, 1 do
		self.m_CurrentHandSide = side
		local half = HALF_SCREEN[side]
		self.m_HandPos[side].x = Mathf.Clamp(self.m_HandPos[side].x + dx, half.xMin, half.xMax)
		self.m_HandPos[side].y = Mathf.Clamp(self.m_HandPos[side].y + dy, 0, 1)

		if not self.m_HandReachingOut[side] then
			self._UpdateHandBlend(self, side)
		end
	end
end

StickCatchGame._UpdateHandBlend = function(self, side)
	local pos = self.m_HandPos[side]
	local half = HALF_SCREEN[side]
	local halfCenterX = (half.xMin + half.xMax) * 0.5
	local halfWidth = (half.xMax - half.xMin) * 0.5
	local blendX = (pos.x - halfCenterX) / halfWidth
	local blendY = pos.y * 2 - 1

	print_debug("StickCatchGame blendX blendY layer", blendX, blendY, side)

	if side ~= 0 then
		ABPVarManager.SetFloat(gCS.MyPlayerManager.PlayerUnit, ABPVarConfig.CatchSticksL_X, blendX)
		ABPVarManager.SetFloat(gCS.MyPlayerManager.PlayerUnit, ABPVarConfig.CatchSticksL_Y, blendY)
	else
		ABPVarManager.SetFloat(gCS.MyPlayerManager.PlayerUnit, ABPVarConfig.CatchSticksR_X, blendX)
		ABPVarManager.SetFloat(gCS.MyPlayerManager.PlayerUnit, ABPVarConfig.CatchSticksR_Y, blendY)
	end
end

StickCatchGame._DoGrab = function(self, side)
	print_debug("StickCatchGame DoGrab", side, self.m_HandReachingOut[side])

	if self.m_HandReachingOut[side] then
		return
	end

	if side ~= 0 then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.LeftHand_reachout)
	else
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.RightHand_reachout)
	end

	gMessageManager:SendMessage(gEventConstants.ON_STICK_CATCH_HAND_START, {
		handSide = side
	})
end

StickCatchGame.OnHandReachStart = function(self, data)
	local side = data.handSide

	if self.m_HandReachingOut[side] then
		print_warn("StickCatchGame OnHandReachStart: hand already reaching out", side)
	end

	print_debug("StickCatchGame OnHandReachStart", side)

	self.m_HandReachingOut[side] = true
end

StickCatchGame.OnHandReachEnd = function(self, data)
	local side = data.handSide

	print_debug("StickCatchGame OnHandReachEnd", side)

	self.m_HandReachingOut[side] = false
end

StickCatchGame._KeyIdToSide = function(self, keyId, inputType)
	local InputType = self._InputType

	if not InputType then
		return nil
	end

	if inputType ~= InputType.PC then
		if keyId ~= 8 then
			return 0
		end

		if keyId ~= 9 then
			return 1
		end
	elseif inputType ~= InputType.Gamepad then
		if keyId ~= 9 then
			return 0
		end

		if keyId ~= 10 then
			return 1
		end
	end

	return nil
end

StickCatchGame.ForceExit = function(self)
	self.Cleanup(self)
end

StickCatchGame.Cleanup = function(self)
	if self.eventHandle then
		gMessageManager:UnregisterEventHandlers(self.eventHandle)

		self.eventHandle = nil
	end

	gPanelManager:Close(gPanelId.S_GAMEPLAY_QTE_PANEL)
end
