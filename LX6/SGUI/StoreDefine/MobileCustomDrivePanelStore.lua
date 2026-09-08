-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MobileCustomDrivePanelStore.lua
-- Decompiled from: 00985_MobileCustomDrivePanelStore.lua_3b844dd73939.luajit

C_MobileCustomDrivePanelStore = DefClass("C_MobileCustomDrivePanelStore", C_MobileCustomDrivePanelStore, C_StoreGroup)
GroupName2Class.MobileCustomDrivePanelStore = C_MobileCustomDrivePanelStore
local M = C_MobileCustomDrivePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.mgr = SGUI.UCustomLayoutMgr.Instance
end

M.DefineAllEnumsAutoGen = function(self)
	self.FoldCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isSelectingBtnCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isDriveModeEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.hasChaseCarAlertEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isPVEnum = {
		["\\xbagv"] = 0,
		[">G\\x85\\x9a\\x8cL"] = 1
	}
	self.isArrestedEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 1,
		["\\xea\\xce7\\xe2"] = 2,
		["\\xce\\xda*\\xf6"] = 3,
		["N0h^"] = 0
	}
	self.showPoiEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.inFightCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.meTypeEnum = {
		["\\x8dit"] = 1,
		["\r"] = 0,
		["\tF\\x9a\\x80\\x8cV"] = 4,
		["X\\x98\\x8a\\x86S"] = 3,
		["I\\xbc\\xad\\xa1\\xb3"] = 2
	}
	self.boundaryCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.phoneOpenCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.droneStateEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.policeStateEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.exitBtnposCtrlEnum = {
		["\\xfd\\xde(\\xe5"] = 0,
		["c\\xa1\\x8f\\xae\\xa6"] = 1
	}
	self.PhoneOpenCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.OperationModeCtrlEnum = {
		["m1|_"] = 0,
		["\\xa1\\xbe\\xb8~7\\xfd8"] = 1
	}
	self.RaceModeCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.AutoDrivingCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.FoldCtrlEnum = nil
	self.isSelectingBtnCtrlEnum = nil
	self.isDriveModeEnum = nil
	self.hasChaseCarAlertEnum = nil
	self.isPVEnum = nil
	self.isArrestedEnum = nil
	self.showPoiEnum = nil
	self.inFightCtrlEnum = nil
	self.meTypeEnum = nil
	self.boundaryCtrlEnum = nil
	self.phoneOpenCtrlEnum = nil
	self.droneStateEnum = nil
	self.policeStateEnum = nil
	self.exitBtnposCtrlEnum = nil
	self.PhoneOpenCtrlEnum = nil
	self.OperationModeCtrlEnum = nil
	self.RaceModeCtrlEnum = nil
	self.AutoDrivingCtrlEnum = nil
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
	self.mgr = nil
end

M.OnGroupEnable = function(self)
	self.driveStore = self.GetStoreByWidget(self, self.bindData.driveRoot)
end

M.OnGroupDisable = function(self)
	self.driveStore = nil
end

M.OnShow = function(self, panelId, data)
	self.mgr:EnterEditMode()
	self.SubGroup.CustomLayoutControlPartStore:InitControl(gPanelId.MOBILE_CUSTOM_DRIVE_PANEL)

	self.driveStore.OperationModeCtrl = data and self.OperationModeCtrlEnum.joystick or self.OperationModeCtrlEnum.wsad
end

M.OnClose = function(self)
	self.mgr:ExitEditMode()
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
