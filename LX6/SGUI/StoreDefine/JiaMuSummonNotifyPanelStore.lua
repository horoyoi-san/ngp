-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\JiaMuSummonNotifyPanelStore.lua
-- Decompiled from: 01768_JiaMuSummonNotifyPanelStore.lua_9d630cf495fd.luajit

C_JiaMuSummonNotifyPanelStore = DefClass("C_JiaMuSummonNotifyPanelStore", C_JiaMuSummonNotifyPanelStore, C_StoreGroup)
GroupName2Class.JiaMuSummonNotifyPanelStore = C_JiaMuSummonNotifyPanelStore
local M = C_JiaMuSummonNotifyPanelStore

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.num = data

	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end

	self.closeTimer = Timer.New(function ()
		self.closeTimer = nil

		gPanelManager:Close(gPanelId.JIA_MU_SUMMON_NOTIFY_PANEL)
	end, 2):Start()
end

M.OnClose = function(self)
	if self.closeTimer then
		self.closeTimer:Stop()

		self.closeTimer = nil
	end
end
