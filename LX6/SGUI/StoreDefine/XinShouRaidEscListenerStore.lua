-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\XinShouRaidEscListenerStore.lua
-- Decompiled from: 01245_XinShouRaidEscListenerStore.lua_f0759fa6f205.luajit

C_XinShouRaidEscListenerStore = DefClass("C_XinShouRaidEscListenerStore", C_XinShouRaidEscListenerStore, C_StoreGroup)
GroupName2Class.XinShouRaidEscListenerStore = C_XinShouRaidEscListenerStore
local M = C_XinShouRaidEscListenerStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnClick")
	self.actionCb = self.CreateAction(self, "OnTouchScreen")
	self.cbRegistered = false
	self.msgEvents = {
		[gEventConstants.PANEL_ON_SHOW] = self.CreateAction(self, "OnPanelShow"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose")
	}

	self.RegisterMessageEvents(self, self.msgEvents)

	self.SHOW_CONTROL = {
		["d\\x80\\x92\\x9a\\x82"] = true,
		["}\\x8f\\x8c\\x8a\\x9a"] = true
	}
	self.panelRange = {
		gPanelId.S_GUIDE_MINI_TIP_PANEL,
		gPanelId.S_GUIDE_PIC,
		gPanelId.S_GUIDE_TIP,
		gPanelId.S_SETTINGS_PANEL,
		gPanelId.XINSHOU_EXIT,
		gPanelId.GUIDE_PIC_MODAL_PANEL
	}
	self.controlPanel = {}
	self.controlCount = 0
	self.recordTime = 0
end

M.OnExitBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.XINSHOU_EXIT)
end

M.OnTouchScreen = function(self, context)
	if not self.SHOW_CONTROL.INPUT then
		self.SHOW_CONTROL.INPUT = true

		self.bindData.exitBtn:SetActive(self.SHOW_CONTROL.PANEL and self.SHOW_CONTROL.INPUT)
	end

	self.recordTime = gLogicTime.time
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnPanelShow = function(self, eventId, panelId)
	if not self.STATE_EnableOnce then
		return
	end

	if table.contains(self.panelRange, panelId) then
		self:AddControlPanel(panelId)

		local control = self.controlCount ~= 0

		if self.SHOW_CONTROL.PANEL == control then
			self.SHOW_CONTROL.PANEL = control

			self.bindData.exitBtn:SetActive(self.SHOW_CONTROL.PANEL and self.SHOW_CONTROL.INPUT)
		end
	end
end

M.OnPanelClose = function(self, eventId, panelId)
	if not self.STATE_EnableOnce then
		return
	end

	if table.contains(self.panelRange, panelId) then
		self:RemoveControlPanel(panelId)

		local control = self.controlCount ~= 0

		if self.SHOW_CONTROL.PANEL == control then
			self.SHOW_CONTROL.PANEL = control

			self.bindData.exitBtn:SetActive(self.SHOW_CONTROL.PANEL and self.SHOW_CONTROL.INPUT)
		end
	end
end

M.AddControlPanel = function(self, panel)
	if not self.controlPanel[panel] then
		self.controlPanel[panel] = true
		self.controlCount = self.controlCount + 1
	end
end

M.RemoveControlPanel = function(self, panel)
	if self.controlPanel[panel] then
		self.controlPanel[panel] = nil
		self.controlCount = self.controlCount - 1
	end
end
