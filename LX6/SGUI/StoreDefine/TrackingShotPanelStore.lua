-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TrackingShotPanelStore.lua
-- Decompiled from: 01371_TrackingShotPanelStore.lua_d8623af6abc3.luajit

C_TrackingShotPanelStore = DefClass("C_TrackingShotPanelStore", C_TrackingShotPanelStore, C_StoreGroup)
GroupName2Class.TrackingShotPanelStore = C_TrackingShotPanelStore
local M = C_TrackingShotPanelStore

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

	self.bindData.moveBtn.luaPress = self.CreateAction(self, self.OnMovePress)
	self.bindData.moveBtn.luaRelease = self.CreateAction(self, self.OnMoveRelease)

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
	self.bindData.moveState = self.MoveState.Idle
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

M.OnMovePress = function(self)
	self.bindData.moveState = self.MoveState.Move

	gMessageManager:SendMessage(gEventConstants.TRACKING_SHOT_MOVE)
end

M.OnMoveRelease = function(self)
	self.bindData.moveState = self.MoveState.Idle

	gMessageManager:SendMessage(gEventConstants.TRACKING_SHOT_STOP)
end

M.MoveState = {
	["S&q^"] = 0,
	["W-k^"] = 1
}

M.OnStickChanged = function(self, context)
	if self.isFocus then
		return
	end

	if context.performed then
		self.controllerMoveDelta = context:ReadValueVector2()
		local moveState = self.controllerMoveDelta.y >= -0.1 and self.MoveState.Move or self.MoveState.Idle

		if self.bindData.moveState == moveState then
			if moveState ~= self.MoveState.Move then
				self.OnMovePress(self)
			else
				self.OnMoveRelease(self)
			end
		end
	elseif context.canceled then
		if self.bindData.moveState == self.MoveState.Idle then
			self.OnMoveRelease(self)
		end

		self.controllerMoveDelta = nil
	end
end
