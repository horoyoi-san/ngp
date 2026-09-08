-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\StuntDrivingPanelStore.lua
-- Decompiled from: 01300_StuntDrivingPanelStore.lua_8c60b45c3ec0.luajit

C_StuntDrivingPanelStore = DefClass("C_StuntDrivingPanelStore", C_StuntDrivingPanelStore, C_StoreGroup)
GroupName2Class.StuntDrivingPanelStore = C_StuntDrivingPanelStore
local M = C_StuntDrivingPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.FinishStatusEnum = {
		[":I\\x98\\x82\\x86E"] = 2,
		["R+y^"] = 0,
		["\\xea\\xce7\\xe2"] = 1
	}
	self.showSubsEnum = {
		["R+y^"] = 0,
		["\\xf1\\xd2\t6\\xe8"] = 2,
		["*\\xeaL8\\xc2\\x90H\\xaf_\\xa3\\xbe"] = 3,
		["]-|W"] = 4,
		["\\xfa\\xce*\\xe5"] = 1
	}
	self.haventAchieveEnum = {
		["X-iS"] = 3,
		["4M\\x98\\x89\\x8bU"] = 2,
		["\\x8f\\xb8\\xbfk0\\xfd6"] = 1,
		["T-s^"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.FinishStatusEnum = nil
	self.showSubsEnum = nil
	self.haventAchieveEnum = nil
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
	data = data.ToTable(data)
	self.data = data

	if data.isSuccess then
		self.bindData.FinishStatus = 1
	else
		self.bindData.FinishStatus = 2
	end

	self.bindData.num = string.format(LTConfig.TextScriptTextConfig.GetConfig(89901450).Text, tostring(data.remainingNum))
	data.curDis = string.format("%.1f", data.curDis)
	data.curHeight = string.format("%.1f", data.curHeight)
	data.targetDis = string.format("%.1f", data.targetDis)
	data.targetHeight = string.format("%.1f", data.targetHeight)
	self.bindData.curDis = data.curDis .. "m"
	self.bindData.curHeight = data.curHeight .. "m"
	self.bindData.targetDis = data.targetDis .. "m"
	self.bindData.targetHeight = data.targetHeight .. "m"

	self.ShowCurUI(self)
end

M.ShowCurUI = function(self)
	self.bindData.showSubs = 1

	gLuaTimeMgrUtils.Delay(function ()
		if self.data.isSuccess then
			self:ShowRemainingNumUI()
		else
			self:ShowTargetUI()
		end
	end, 1.5, nil, , true)
end

M.ShowTargetUI = function(self)
	self.bindData.showSubs = 4

	gLuaTimeMgrUtils.Delay(function ()
		self:ShowRemainingNumUI()
	end, 1.5, nil, , true)
end

M.ShowRemainingNumUI = function(self)
	if self.data.isSkip then
		gPanelManager:Close(gPanelId.S_STUNT_DRIVING_PANEL)

		return
	end

	if self.data.remainingNum ~= 0 then
		self.bindData.showSubs = 3
	else
		self.bindData.showSubs = 2
	end

	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.S_STUNT_DRIVING_PANEL)
	end, 1.5, nil, , true)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
