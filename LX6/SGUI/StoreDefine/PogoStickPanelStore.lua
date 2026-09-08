-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PogoStickPanelStore.lua
-- Decompiled from: 00780_PogoStickPanelStore.lua_ab24c503e338.luajit

C_PogoStickPanelStore = DefClass("C_PogoStickPanelStore", C_PogoStickPanelStore, C_StoreGroup)
GroupName2Class.PogoStickPanelStore = C_PogoStickPanelStore
local M = C_PogoStickPanelStore
local MyPlayerManager = gCS.MyPlayerManager
local LogicStateMachineManager = gCS.LogicStateMachineManager
local GameplaySignalInwardConfig = LTConfig.GameplaySignalInwardConfig
local UnitOperateUtils = require("LX6/Utils/UnitOperateUtils")
local ClientEventConfig = LTConfig.ClientEventConfig
local OperateType = UnitOperateUtils.OperateType

M.ctor = function(self)
	self.INWARD_SIGNAL = {
		ENTER = GameplaySignalInwardConfig.EnterPogoStick,
		EXIT = GameplaySignalInwardConfig.ExitPogoStick
	}
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
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.isShow = true

	self:SendSignal(self.INWARD_SIGNAL.ENTER)

	self.registerOperationId = gStoreButtonMgr:RegisterOperation({
		["\\xca\\xcf\t\r\\xf5"] = 5,
		["O\\xba\\xac\\x86\\xb2"] = 0,
		["\\xbb\\xa3\\xa4x7\\xea*"] = 1,
		groupId = LTConfig.HudDescGroupConfig.Helicopter
	})
end

M.OnClose = function(self)
	self.isShow = false

	self:SendSignal(self.INWARD_SIGNAL.EXIT)
	gStoreButtonMgr:UnRegisterOperation(self.registerOperationId)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.jumpBtn.luaPress = self.CreateAction(self, self.OnPressJumpBtn)
	self.bindData.jumpBtn.luaRelease = self.CreateAction(self, self.OnReleaseJumpBtn)
end

M.OnPressJumpBtn = function(self)
	UnitOperateUtils.DoOperateFunc(OperateType.KeyDown, MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpPress)
		gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.ABPCCCEventConfig.JumpPress)
	end

	gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.JumpButtonClick)
end

M.OnReleaseJumpBtn = function(self)
	UnitOperateUtils.DoOperateFunc(OperateType.KeyUp, MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpRelease)
		gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.ABPCCCEventConfig.JumpRelease)
	end
end

M.ExitPogoStick = function(self)
	self:SendSignal(self.INWARD_SIGNAL.EXIT)

	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore then
		gameplayControlStore.StopGameplayByType(gameplayControlStore, gHUDGameplayType.POGO_STICK)
	end
end

M.SendSignal = function(self, signal)
end
