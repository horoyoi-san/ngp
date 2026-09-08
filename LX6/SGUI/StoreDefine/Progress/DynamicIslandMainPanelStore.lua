-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Progress\DynamicIslandMainPanelStore.lua
-- Decompiled from: 01970_DynamicIslandMainPanelStore.lua_2ccc0cda874c.luajit

local SyncValueConfig = LTConfig.SyncValueConfig
local EInvokeTime = SGUI.EInvokeTime
C_DynamicIslandMainPanelStore = DefClass("C_DynamicIslandMainPanelStore", C_DynamicIslandMainPanelStore, C_ProgressBaseStore)
GroupName2Class.DynamicIslandMainPanelStore = C_DynamicIslandMainPanelStore
local M = C_DynamicIslandMainPanelStore

M.OnInitData = function(self)
	M.base.OnInitData(self)

	self.foldMode = false
end

M.OnShow = function(self, panelId, data)
	M.base.OnShow(self, panelId, data)
	self.WaitForFold(self)
end

M.OnClose = function(self)
	M.base.OnClose(self)
	self.CloseTimer(self)
end

M.CloseTimer = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.WaitForFold = function(self)
	self.timer = Timer.New(function ()
		self.bindData.bindWidget:InvokeCallback(EInvokeTime.Custom1)

		self.foldMode = true
		self.timer = nil
	end, SyncValueConfig.dynamicIslandFoldTime):Start()
end

M.RefreshCurrentProgress = function(self)
	M.base.RefreshCurrentProgress(self)

	if self.foldMode then
		self.bindData.bindWidget:InvokeCallback(EInvokeTime.Custom2)

		self.foldMode = false

		self:CloseTimer()
		self:WaitForFold()
	end
end
