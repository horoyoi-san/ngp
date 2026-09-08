-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WireRiggingControlsPanelStore.lua
-- Decompiled from: 01162_WireRiggingControlsPanelStore.lua_88dd8e7cb8d1.luajit

C_WireRiggingControlsPanelStore = DefClass("C_WireRiggingControlsPanelStore", C_WireRiggingControlsPanelStore, C_StoreGroup)
GroupName2Class.WireRiggingControlsPanelStore = C_WireRiggingControlsPanelStore
local M = C_WireRiggingControlsPanelStore

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
	self.ClearBanButton(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.SetBanButton(self)
end

M.OnClose = function(self)
	self.ClearBanButton(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.roll.luaPress = self.CreateAction(self, self.OnPressRollBtn)
	self.bindData.roll.luaRelease = self.CreateAction(self, self.OnReleaseRollBtn)
	self.bindData.kick.luaPress = self.CreateAction(self, self.OnPressKickBtn)
	self.bindData.kick.luaRelease = self.CreateAction(self, self.OnReleaseKickBtn)
	self.bindData.flyKiss.luaPress = self.CreateAction(self, self.OnPressFlyKissBtn)
	self.bindData.flyKiss.luaRelease = self.CreateAction(self, self.OnReleaseFlyKissBtn)
end

M.SetBanButton = function(self)
	if not self.buttonBanId then
		self.buttonBanId = gStoreButtonMgr:RegisterOperation({
			["\\xca\\xcf\t\r\\xf5"] = 5,
			["\\xbb\\xa3\\xa4x7\\xea*"] = 0,
			groupId = LTConfig.HudDescGroupConfig.SystemControlsGroup
		})
	end
end

M.ClearBanButton = function(self)
	if self.buttonBanId then
		gStoreButtonMgr:UnRegisterOperation(self.buttonBanId)

		self.buttonBanId = nil
	end
end

M.OnPressRollBtn = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.TaffyWireRoll_press)
end

M.OnReleaseRollBtn = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.TaffyWireRoll_release)
end

M.OnPressKickBtn = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.TaffyWireKick_press)
end

M.OnReleaseKickBtn = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.TaffyWireKick_release)
end

M.OnPressFlyKissBtn = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.TaffyWireKiss_press)
end

M.OnReleaseFlyKissBtn = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.TaffyWireKiss_release)
end
