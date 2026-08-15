local EInvokeTime = SGUI.EInvokeTime
C_HealthyAdviceStore = DefClass("C_HealthyAdviceStore", C_HealthyAdviceStore, C_StoreGroup)
GroupName2Class.HealthyAdviceStore = C_HealthyAdviceStore
local M = C_HealthyAdviceStore

function M:ctor()
	self.msgEvents = {
		[gEventConstants.INIT_UI_COMPLETE] = self:CreateAction(self.OnInitUIComplete)
	}
	self.waitPlay = false
end

function M:OnInitUIComplete()
	self.waitPlay = true

	self:BeginTimer()
end

function M:OnAwake()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnShow(panelId, data)
	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
	self:BeginTimer()
end

function M:BeginTimer()
	if not self.waitPlay then
		return
	end

	self.bindData.bindWidget:InvokeCallback(EInvokeTime.User1)
	Timer.New(function ()
		gPanelManager:Close(gPanelId.HEALTHY_ADVICE)
		gPanelManager:CheckShow(gPanelId.USER_LOGIN)
	end, 7):Start()
end

function M:OnClose()
	self:ClearMessageEvents()
end
