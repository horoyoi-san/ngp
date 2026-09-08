-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MoveTrainPanelStore.lua
-- Decompiled from: 01050_MoveTrainPanelStore.lua_5ae8cca07541.luajit

C_MoveTrainPanelStore = DefClass("C_MoveTrainPanelStore", C_MoveTrainPanelStore, C_StoreGroup)
GroupName2Class.MoveTrainPanelStore = C_MoveTrainPanelStore
local M = C_MoveTrainPanelStore

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

	self.bindData.leftBtn.luaPress = self.CreateAction(self, self.OnLeftPress)
	self.bindData.leftBtn.luaRelease = self.CreateAction(self, self.OnLeftRelease)
	self.bindData.rightBtn.luaPress = self.CreateAction(self, self.OnRightPress)
	self.bindData.rightBtn.luaRelease = self.CreateAction(self, self.OnRightRelease)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.stickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnStickChanged")
	end
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
	self.bindData.operateId = gStoreButtonMgr:RegisterOperation({
		["\\xde\\xc9\r\\xf5"] = 2,
		["\\xca\\xcf\t\r\\xf5"] = 5,
		["O\\xba\\xac\\x86\\xb2"] = 0,
		["\\xbb\\xa3\\xa4x7\\xea*"] = 1
	})
	self.bindData.moveState = self.MoveState.Stop
end

M.OnClose = function(self)
	if self.bindData.operateId then
		gStoreButtonMgr:UnRegisterOperation(self.bindData.operateId)

		self.bindData.operateId = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.OnStickRespondInputChanged = function(self, context)
end

M.OnLeftPress = function(self)
	self.bindData.leftPress = true

	self.RefreshState(self)
end

M.OnLeftRelease = function(self)
	self.bindData.leftPress = false

	self.RefreshState(self)
end

M.OnRightPress = function(self)
	self.bindData.rightPress = true

	self.RefreshState(self)
end

M.OnRightRelease = function(self)
	self.bindData.rightPress = false

	self.RefreshState(self)
end

M.RefreshState = function(self)
	local state = nil

	if self.bindData.leftPress and self.bindData.rightPress then
		state = self.MoveState.Stop
	elseif self.bindData.rightPress then
		state = self.MoveState.Right
	elseif self.bindData.leftPress then
		state = self.MoveState.Left
	else
		state = self.MoveState.Stop
	end

	if self.bindData.moveState == state then
		self.bindData.moveState = state

		self.OnStateChanged(self)
	end
end

M.MoveState = {
	["\\xa7\\xa5\\xa7\\xa2"] = 2,
	["V'{O"] = 1,
	I6rK = 0
}

M.OnStateChanged = function(self)
	if self.bindData.moveState ~= self.MoveState.Stop then
		print_debug("MoveTrainPanelStore:OnStateChanged Stop")
		gMessageManager:SendMessage(gEventConstants.TRAIN_MOVE_STOP)
	elseif self.bindData.moveState ~= self.MoveState.Left then
		print_debug("MoveTrainPanelStore:OnStateChanged Left")
		gMessageManager:SendMessage(gEventConstants.TRAIN_MOVE_LEFT)
	elseif self.bindData.moveState ~= self.MoveState.Right then
		print_debug("MoveTrainPanelStore:OnStateChanged Right")
		gMessageManager:SendMessage(gEventConstants.TRAIN_MOVE_RIGHT)
	end
end

M.OnStickChanged = function(self, context)
	if self.isFocus then
		return
	end

	if context.performed then
		self.controllerMoveDelta = context.ReadValueVector2(context)
		local moveState = nil

		if self.controllerMoveDelta.x >= -0.1 then
			moveState = self.MoveState.Left
		elseif self.controllerMoveDelta.x <= 0.1 then
			moveState = self.MoveState.Right
		else
			moveState = self.MoveState.Stop
		end

		if self.bindData.moveState == moveState then
			self.bindData.moveState = moveState

			self.OnStateChanged(self)
		end
	elseif context.canceled then
		if self.bindData.moveState == self.MoveState.Stop then
			self.bindData.moveState = self.MoveState.Stop

			self.OnStateChanged(self)
		end

		self.controllerMoveDelta = nil
	end
end
