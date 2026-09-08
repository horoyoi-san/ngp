-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HealthyAdviceStore.lua
-- Decompiled from: 01708_HealthyAdviceStore.lua_3fb0e259bb78.luajit

local EInvokeTime = SGUI.EInvokeTime
C_HealthyAdviceStore = DefClass("C_HealthyAdviceStore", C_HealthyAdviceStore, C_StoreGroup)
GroupName2Class.HealthyAdviceStore = C_HealthyAdviceStore
local M = C_HealthyAdviceStore

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.INIT_UI_COMPLETE] = self.CreateAction(self, self.OnInitUIComplete)
	}
	self.waitPlay = false
end

M.OnInitUIComplete = function(self)
	self.waitPlay = true

	self.BeginTimer(self)
end

M.OnAwake = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnShow = function(self, panelId, data)
	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
	self:BeginTimer()
end

M.BeginTimer = function(self)
	if not self.waitPlay then
		return
	end

	self.bindData.bindWidget:InvokeCallback(EInvokeTime.User1)
	Timer.New(function ()
		gPanelManager:Close(gPanelId.HEALTHY_ADVICE)
		gDlcDownLoadMgr:OnStartUp()
	end, 7):Start()
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)
end
