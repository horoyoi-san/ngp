-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GameplayMountPanelStore.lua
-- Decompiled from: 01744_GameplayMountPanelStore.lua_e619532d65d1.luajit

local ClientEventConfig = LTConfig.ClientEventConfig
local UnitOperateUtils = require("LX6/Utils/UnitOperateUtils")
local OperateType = UnitOperateUtils.OperateType
C_GameplayMountPanelStore = DefClass("C_GameplayMountPanelStore", C_GameplayMountPanelStore, C_StoreGroup)
GroupName2Class.GameplayMountPanelStore = C_GameplayMountPanelStore
local M = C_GameplayMountPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.btnHideCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.wordsCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.qteVxCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.btnHideCtrlEnum = nil
	self.wordsCtrlEnum = nil
	self.qteVxCtrlEnum = nil
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
	L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gPanelId.GAMEPLAY_CONTROLS, false)
end

M.OnGroupEnable = function(self)
	self.outOfRidingStore = gStoreManager:GetStoreByWidget(self.bindData.btnOutOfRiding)
	self.outOfRidingStore.btnId = LTConfig.HudDescConfig.BTN_OUT_OF_RIDING

	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnGroupDisable = function(self)
	self.outOfRidingStore = nil
end

M.OnShow = function(self, panelId, data)
	L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gPanelId.GAMEPLAY_CONTROLS, true)
end

M.OnClose = function(self)
	L50.L50App.L50Game.InteractBtnMgr:SetInteractHideByUI(gPanelId.GAMEPLAY_CONTROLS, false)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.btnRush.luaPress = self.CreateAction(self, "OnRushBtnPress")
	self.bindData.btnRush.luaRelease = self.CreateAction(self, "OnRushBtnRelease")
	self.bindData.btnJump.luaPress = self.CreateAction(self, "OnJumpBtnPress")
	self.bindData.btnJump.luaRelease = self.CreateAction(self, "OnJumpBtnRelease")
	self.bindData.btnOutOfRiding.luaLongPress = self.CreateAction(self, "OnBtnOutOfRidingLongPress")
end

M.OnRushBtnPress = function(self)
	gBattleMgr:OnDodgeBtnPressFunc()
end

M.OnRushBtnRelease = function(self)
	gBattleMgr:OnDodgeBtnReleaseFunc()
end

M.OnJumpBtnPress = function(self)
	UnitOperateUtils.DoOperateFunc(OperateType.KeyDown, gCS.MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpPress)
		gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.ABPCCCEventConfig.JumpPress)
	end

	gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.JumpButtonClick)
end

M.OnJumpBtnRelease = function(self)
	UnitOperateUtils.DoOperateFunc(OperateType.KeyUp, gCS.MyPlayerManager.PlayerUnit)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpRelease)
		gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.ABPCCCEventConfig.JumpRelease)
	end
end

M.OnBtnOutOfRidingLongPress = function(self)
	gCS.BaseUnitUtils.Dismount()
end
