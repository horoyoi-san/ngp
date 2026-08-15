C_DeliveryDronePanelStore = DefClass("C_DeliveryDronePanelStore", C_DeliveryDronePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.DeliveryDronePanelStore = C_DeliveryDronePanelStore
local M = C_DeliveryDronePanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.callDroneButton.luaClick = self:CreateAction("OnCallDroneButtonClick")
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.supportConfig = args.supportConfig
end

function M:GetMessageEvents()
	return {
		[gEventConstants.SUMMON_STATE_SWITCH] = self:CreateAction(self.RefreshDroneView),
		[gEventConstants.UAV_LOGIC_STATE_CHANGE] = self:CreateAction(self.RefreshDroneState)
	}
end

function M:InitView(args)
	M.base.InitView(self, args)
	gDeliveryTaskManager.RefreshDeliveryAvatarView(self.bindData.avatarWidget, self.rootGo)
	self:RefreshDroneView()
end

function M:RefreshDroneView()
	self.bindData.callBtnState = gDeliveryTaskManager.CheckHasDroneAgent() and 1 or 0

	self:RefreshDroneState()
end

function M:RefreshDroneState()
	self.bindData.droneState = gDeliveryTaskManager.TryGetDroneState() or 0
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_DELIVERY_APP_CONTENT_CLOSE)
end

function M:OnCallDroneButtonClick()
	gDeliveryTaskManager.DoDroneSupport(self.supportConfig.functionId)
	self:RefreshDroneView()
end
