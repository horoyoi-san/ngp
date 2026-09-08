-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TaskCheckPanelStore.lua
-- Decompiled from: 01409_TaskCheckPanelStore.lua_bc69d23f8a2c.luajit

C_TaskCheckPanelStore = DefClass("C_TaskCheckPanelStore", C_TaskCheckPanelStore, C_StoreGroup)
GroupName2Class.TaskCheckPanelStore = C_TaskCheckPanelStore
local M = C_TaskCheckPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.btnCtrlEnum = {
		["\\x9ai"] = 1,
		["I\\x9f\\x8d\\x86M"] = 2,
		["\\xda\\xd46\\xfc"] = 0
	}
	self.typeCtrlEnum = {
		["\\xbf\\xb4\t\\xaez1\\xec'"] = 1,
		["w#tU"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.btnCtrlEnum = nil
	self.typeCtrlEnum = nil
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
	if not data then
		return
	end

	self.backCallBack = data.backCallBack
	self.confirmCallBack = data.confirmCallBack
	self.bindData.tipsText = data.tipsText
	self.bindData.btnCtrl = data.btnCtrl
	self.bindData.typeCtrl = data.typeCtrl
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnClickConfirmBtn")
end

M.OnClickBackBtn = function(self)
	self:InvokeCallBack(self.backCallBack)

	self.backCallBack = nil

	gPanelManager:Close(gPanelId.TASK_CHECK_PANEL)
end

M.OnClickConfirmBtn = function(self)
	self:InvokeCallBack(self.confirmCallBack)

	self.confirmCallBack = nil

	gPanelManager:Close(gPanelId.TASK_CHECK_PANEL)
end

M.InvokeCallBack = function(self, cb)
	if cb ~= nil then
		return
	end

	if type(cb) ~= "userdata" then
		cb.DynamicInvoke(cb)
	else
		cb(param)
	end
end
