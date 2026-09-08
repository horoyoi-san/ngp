-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\JumpGridPanelStore.lua
-- Decompiled from: 01771_JumpGridPanelStore.lua_47f8c433b9dc.luajit

C_JumpGridPanelStore = DefClass("C_JumpGridPanelStore", C_JumpGridPanelStore, C_StoreGroup)
GroupName2Class.JumpGridPanelStore = C_JumpGridPanelStore
local M = C_JumpGridPanelStore
local MyPlayerManager = gCS.MyPlayerManager
local UnitOperateUtils = require("LX6/Utils/UnitOperateUtils")
local ClientEventConfig = LTConfig.ClientEventConfig
local OperateType = UnitOperateUtils.OperateType

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
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.operateId = gStoreButtonMgr:RegisterOperation({
		["\\xde\\xc9\r\\xf5"] = 16,
		["\\xca\\xcf\t\r\\xf5"] = 5,
		["O\\xba\\xac\\x86\\xb2"] = 0,
		["\\xbb\\xa3\\xa4x7\\xea*"] = 1
	})
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
	self.bindData.jumpBtn.luaPress = self.CreateAction(self, self.OnPressJumpBtn)
end

M.OnClickJumpBtn = function(self)
end

M.OnPressJumpBtn = function(self)
	UnitOperateUtils.DoOperateFunc(OperateType.KeyDown, MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpPress)
		gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.ABPCCCEventConfig.JumpPress)
	end

	gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.JumpButtonClick)
end
