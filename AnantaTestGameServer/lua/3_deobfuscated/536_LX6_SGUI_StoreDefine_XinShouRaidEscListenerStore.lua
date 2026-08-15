C_XinShouRaidEscListenerStore = DefClass("C_XinShouRaidEscListenerStore", C_XinShouRaidEscListenerStore, C_StoreGroup)
GroupName2Class.XinShouRaidEscListenerStore = C_XinShouRaidEscListenerStore
local M = C_XinShouRaidEscListenerStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnClick")
	self.actionCb = self:CreateAction("OnTouchScreen")
	self.cbRegistered = false
	self.msgEvents = {
		[gEventConstants.PANEL_ON_SHOW] = self:CreateAction("OnPanelShow"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose")
	}

	self:RegisterMessageEvents(self.msgEvents)

	self.SHOW_CONTROL = {
		INPUT = true,
		PANEL = true
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

function M:OnExitBtnClick()
	gPanelManager:CheckShow(gPanelId.XINSHOU_EXIT)
end

function M:OnTouchScreen(context)
	if not self.SHOW_CONTROL.INPUT then
		self.SHOW_CONTROL.INPUT = true

		self.bindData.exitBtn:SetActive(self.SHOW_CONTROL.PANEL and self.SHOW_CONTROL.INPUT)
	end

	self.recordTime = gLogicTime.time
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnPanelShow(eventId, panelId)
	if not self.STATE_EnableOnce then
		return
	end

	if table.contains(self.panelRange, panelId) then
		self:AddControlPanel(panelId)

		local control = self.controlCount == 0

		if self.SHOW_CONTROL.PANEL ~= control then
			self.SHOW_CONTROL.PANEL = control

			self.bindData.exitBtn:SetActive(self.SHOW_CONTROL.PANEL and self.SHOW_CONTROL.INPUT)
		end
	end
end

function M:OnPanelClose(eventId, panelId)
	if not self.STATE_EnableOnce then
		return
	end

	if table.contains(self.panelRange, panelId) then
		self:RemoveControlPanel(panelId)

		local control = self.controlCount == 0

		if self.SHOW_CONTROL.PANEL ~= control then
			self.SHOW_CONTROL.PANEL = control

			self.bindData.exitBtn:SetActive(self.SHOW_CONTROL.PANEL and self.SHOW_CONTROL.INPUT)
		end
	end
end

function M:AddControlPanel(panel)
	if not self.controlPanel[panel] then
		self.controlPanel[panel] = true
		self.controlCount = self.controlCount + 1
	end
end

function M:RemoveControlPanel(panel)
	if self.controlPanel[panel] then
		self.controlPanel[panel] = nil
		self.controlCount = self.controlCount - 1
	end
end
