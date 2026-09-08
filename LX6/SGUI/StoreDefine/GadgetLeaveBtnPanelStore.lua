-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GadgetLeaveBtnPanelStore.lua
-- Decompiled from: 01877_GadgetLeaveBtnPanelStore.lua_45109232e601.luajit

C_GadgetLeaveBtnPanelStore = DefClass("C_GadgetLeaveBtnPanelStore", C_GadgetLeaveBtnPanelStore, C_StoreGroup)
GroupName2Class.GadgetLeaveBtnPanelStore = C_GadgetLeaveBtnPanelStore
local M = C_GadgetLeaveBtnPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.btnTypeEnum = {
		["\\xe9\\xda\t!\\xe3"] = 1,
		["\\xfe\\xde%\\xfd"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.btnTypeEnum = nil
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
	self.bindData.btnType = data.BtnType

	if not self.bindData.operateId then
		self.bindData.operateId = gStoreButtonMgr:RegisterOperation({
			["\\xde\\xc9\r\\xf5"] = 24,
			["\\xca\\xcf\t\r\\xf5"] = 5,
			["O\\xba\\xac\\x86\\xb2"] = 0,
			["\\xbb\\xa3\\xa4x7\\xea*"] = 1
		})
	end
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
	self.bindData.btnExit.luaLongPress = self.CreateAction(self, self.OnClickExit)
	self.bindData.btnLeave.luaLongPress = self.CreateAction(self, self.OnClickExit)
end

M.OnClickExit = function(self)
	gPanelManager:Close(gPanelId.GADGET_LEAVE_BTN)
end
