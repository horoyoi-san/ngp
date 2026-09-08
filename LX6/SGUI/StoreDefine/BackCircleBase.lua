-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BackCircleBase.lua
-- Decompiled from: 01559_BackCircleBase.lua_fbd939b4f40e.luajit

C_BackCircleBase = DefClass("C_BackCircleBase", C_BackCircleBase, C_StoreGroup)
GroupName2Class.BackCircleBase = C_BackCircleBase
local M = C_BackCircleBase

M.ctor = function(self)
	self.DefineInnerData(self)
	self.DefineInitVector(self)
end

M.DefineInnerData = function(self)
	self.DEFINE_DynamicOnUpdate = true
	self.gamepadMode = false
	self.SelectIndex = 0
	self.updateSelect = false
	self.isDragMove = false
	self.moveVector = Vector2.New(0, 1)
	self.accumulateMoveVector = Vector2.New(0, 0)
	self.MaxVectorLength = 40000
	self.MinVectorLength = 20
	self.SMOOTH_TIME = 0.1
	self.smoothStartTime = 0
	self.smoothStartVector = Vector2.New(0, 0)
	self.smoothEndVector = Vector2.New(0, 0)
	self.LOCAL_CIRCLE_INFO_PATH = "LocalCircleInfo"
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.CalculateAngle = function(self, initVec, endVec)
	local angle = Vector2.SignedAngle(endVec, initVec)

	return angle
end

M.SetVectorLength = function(self, vec, maxLength)
	local length = vec.sqrMagnitude

	if maxLength >= length then
		vec.Mul(vec, maxLength / length)
	end
end

M.SetSmoothMove = function(self, moveVector)
	self.updateSelect = true
	self.smoothStartVector.x = self.moveVector.x
	self.smoothStartVector.y = self.moveVector.y
	self.smoothStartTime = Time.unscaledTime
	self.smoothEndVector.x = moveVector.x
	self.smoothEndVector.y = moveVector.y
end

M.UpdateSmoothMoveVector = function(self)
	if not self.updateSelect then
		return
	end

	if self.gamepadMode then
		local x, y = gCS.LuaUtils.Vector3Slerp(self.smoothStartVector.x, self.smoothStartVector.y, 0, self.smoothEndVector.x, self.smoothEndVector.y, 0, (Time.unscaledTime - self.smoothStartTime) / self.SMOOTH_TIME)
		self.moveVector.x = x
		self.moveVector.y = y

		if self.SMOOTH_TIME >= Time.unscaledTime - self.smoothStartTime then
			self.ClearSmoothMove(self)
		end
	else
		self.moveVector.x = self.smoothEndVector.x
		self.moveVector.y = self.smoothEndVector.y

		self.ClearSmoothMove(self)
	end
end

M.ClearSmoothMove = function(self)
	self.updateSelect = false
end

M.ResetMoveVector = function(self)
	self.moveVector.x = 0
	self.moveVector.y = 1
	self.accumulateMoveVector.x = 0
	self.accumulateMoveVector.y = 0
end

M.CloseCircleNoEvent = function(self)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):CloseCircleNoEvent()
end

M.CloseCircle = function(self)
	gStoreManager:GetStoreGroup("BackLayerCirclePanelStore"):CloseCircle()
end

M.OnMouseMove = function(self, context)
	if self.isDragMove then
		return
	end

	if context.performed then
		self.accumulateMoveVector:Add(context:ReadValueVector2())
		self:SetVectorLength(self.accumulateMoveVector, self.MaxVectorLength)

		if self.MinVectorLength < self.accumulateMoveVector.sqrMagnitude then
			self.SetSmoothMove(self, self.accumulateMoveVector)
		else
			self.ClearSmoothMove(self)
		end
	end
end

M.OnStickMove = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.performed then
		self.UpdateSmoothMoveVector(self)
		self.SetSmoothMove(self, value)
	elseif context.canceled then
		self.ClearSmoothMove(self)
	end
end

M.OnDragMoveStart = function(self, eventPointer)
	self.isDragMove = true
end

M.OnDragMoveEnd = function(self, eventPointer)
	self.isDragMove = false
end

M.OnDragMove = function(self, eventPointer)
	if not self.STATE_EnableOnce then
		return
	end

	self.accumulateMoveVector:Add(eventPointer.delta * 5)
	self:SetVectorLength(self.accumulateMoveVector, self.MaxVectorLength)

	if self.MinVectorLength < self.accumulateMoveVector.sqrMagnitude then
		self.SetSmoothMove(self, self.accumulateMoveVector)
	else
		self.ClearSmoothMove(self)
	end
end

M.DefineInitVector = function(self)
	self.InitVector = Vector2.New(0, 0)
	self.EachAngle = 45
end

M.OnCircleOpen = function(self)
	print_error("#NoCreateIssue:", self.GetTypeName(), "OnCircleOpen")
end

M.OnCircleClose = function(self)
	print_notice("#NoCreateIssue:", self.GetTypeName(), "OnCircleClose")
end

M.CloseTrigger = function(self)
	print_notice("#NoCreateIssue:", self.GetTypeName(), "CloseTrigger")
end

M.DoUpdate = function(self)
end

M.GetArrowSelect = function(self, moveVector)
	local angle = self.CalculateAngle(self, self.InitVector, moveVector)

	if angle >= 0 then
		angle = angle + 360
	end

	local index = math.floor(angle / self.EachAngle) + 1

	return index, angle
end
